;/ ============================
;/ =    LEDGadgetModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ LED-Gadget
;/
;/ © 2020  by Thorsten Hoeppner (04/2020)
;/

; Last Update: 04.04.2020

;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;}


;{ _____ LED - Commands _____

; LED::AttachPopupMenu()    - adds a popup menu
; LED::Gadget()             - new LED gadget
; LED::GetData()            - similar to 'GetGadgetData()'
; LED::GetID()              - similar to 'GetGadgetData()', but string
; LED::Hide()               - similar to 'HideGadget()'
; LED::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; LED::SetAttribute()       - similar to 'SetGadgetAttribute()'
; LED::SetColor()           - similar to 'SetGadgetColor()'
; LED::SetData()            - similar to 'SetGadgetData()'
; LED::SetID()              - similar to 'SetGadgetData()', but string
; LED::SetState()           - similar to 'SetGadgetState()'
;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule LED
  
  #Version  = 20040400
  #ModuleEx = 19112100
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	;{ _____ Constants _____
	EnumerationBinary ;{ GadgetFlags
		#AutoResize ; Automatic resizing of the gadget
		#Border     ; Draw border
		#ToolTips   ; Show tooltips
		#UseExistingCanvas ; e.g. for dialogs
	EndEnumeration ;}

	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}
	
	Enumeration       ;{ Attribute
	  #Corner
	  #Padding
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
		#GradientColor
		#StateColor
	EndEnumeration ;}

	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget = ModuleEx::#Event_Gadget
		#Event_Theme  = ModuleEx::#Event_Theme
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
			#Event_Gadget
		EndEnumeration

	CompilerEndIf
	;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
	
	Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare   SetData(GNum.i, Value.q)
	Declare   SetID(GNum.i, String.s)
	
  Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i, State.i=1)
  Declare   SetState(GNum.i, State.i)
  
EndDeclareModule

Module LED

	EnableExplicit

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================

	Structure LED_Color_Structure   ;{ LED()\Color\...
		Front.i
		Back.i
		Border.i
		Gadget.i
		Gradient.i
	EndStructure  ;}

	Structure LED_Window_Structure  ;{ LED()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure LED_Size_Structure    ;{ LED()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}


	Structure LED_Structure         ;{ LED()\...
		CanvasNum.i
		PopupNum.i
		
		ID.s
		Quad.i
		
		Radius.i
		Padding.i
    State.i
		Hide.i

		Flags.i

		Color.LED_Color_Structure
		Window.LED_Window_Structure
		Size.LED_Size_Structure
		
    Map StateColor.i()
	EndStructure ;}
	Global NewMap LED.LED_Structure()

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================
	
	Declare.i BlendColor_(Color1.i, Color2.i, Factor.i=50) 
	
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
	  
		; Addition of mk-soft

		Procedure OSX_NSColorToRGBA(NSColor)
			Protected.cgfloat red, green, blue, alpha
			Protected nscolorspace, rgba
			nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
			If nscolorspace
				CocoaMessage(@red, nscolorspace, "redComponent")
				CocoaMessage(@green, nscolorspace, "greenComponent")
				CocoaMessage(@blue, nscolorspace, "blueComponent")
				CocoaMessage(@alpha, nscolorspace, "alphaComponent")
				rgba = RGBA(red * 255.9, green * 255.9, blue * 255.9, alpha * 255.)
				ProcedureReturn rgba
			EndIf
		EndProcedure

		Procedure OSX_NSColorToRGB(NSColor)
			Protected.cgfloat red, green, blue
			Protected r, g, b, a
			Protected nscolorspace, rgb
			nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
			If nscolorspace
				CocoaMessage(@red, nscolorspace, "redComponent")
				CocoaMessage(@green, nscolorspace, "greenComponent")
				CocoaMessage(@blue, nscolorspace, "blueComponent")
				rgb = RGB(red * 255.0, green * 255.0, blue * 255.0)
				ProcedureReturn rgb
			EndIf
		EndProcedure
		
		Procedure OSX_NSColorByNameToRGB(NSColorName.s)
      Protected.cgfloat red, green, blue
      Protected nscolorspace, rgb
      nscolorspace = CocoaMessage(0, CocoaMessage(0, 0, "NSColor " + NSColorName), "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
      If nscolorspace
        CocoaMessage(@red, nscolorspace, "redComponent")
        CocoaMessage(@green, nscolorspace, "greenComponent")
        CocoaMessage(@blue, nscolorspace, "blueComponent")
        rgb = RGB(red * 255.0, green * 255.0, blue * 255.0)
        ProcedureReturn rgb
      EndIf
    EndProcedure
		
		Procedure OSX_GadgetColor()
		  Define.i UserDefaults, NSString
		  
		  UserDefaults = CocoaMessage(0, 0, "NSUserDefaults standardUserDefaults")
      NSString = CocoaMessage(0, UserDefaults, "stringForKey:$", @"AppleInterfaceStyle")
      If NSString And PeekS(CocoaMessage(0, NSString, "UTF8String"), -1, #PB_UTF8) = "Dark"
        ProcedureReturn BlendColor_(OSX_NSColorByNameToRGB("controlBackgroundColor"), #White, 85)
      Else
        ProcedureReturn BlendColor_(OSX_NSColorByNameToRGB("windowBackgroundColor"), #White, 85)
      EndIf 
      
		EndProcedure  
		
	CompilerEndIf
	
  Procedure.f dpiX(Num.i)
	  If Num > 0  
	    ProcedureReturn DesktopScaledX(Num)
	  EndIf   
	EndProcedure

	Procedure.f dpiY(Num.i)
	  If Num > 0  
	    ProcedureReturn DesktopScaledY(Num)
	  EndIf  
	EndProcedure

	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
	Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i)
  
    If LED()\Radius
  		RoundBox(X, Y, Width, Height, LED()\Radius, LED()\Radius, Color)
  	Else
  		Box(X, Y, Width, Height, Color)
  	EndIf
  	
  EndProcedure
	
	Procedure   Draw_()
		Define.i X, Y, Width, Height, Radius
		Define.i Color, BorderColor, BackColor, GradientColor
		
		If LED()\Hide : ProcedureReturn #False : EndIf 

		Width  = dpiX(GadgetWidth(LED()\CanvasNum)) 
		Height = dpiY(GadgetHeight(LED()\CanvasNum))

		If StartDrawing(CanvasOutput(LED()\CanvasNum))
		  
			;{ _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  BackColor = LED()\Color\Gadget
		  Box(0, 0, dpiX(GadgetWidth(LED()\CanvasNum)), dpiY(GadgetHeight(LED()\CanvasNum)), LED()\Color\Gadget)
		  If LED()\Color\Back <> #PB_Default 
		    BackColor = LED()\Color\Back
		    Box_(0, 0, dpiX(GadgetWidth(LED()\CanvasNum)), dpiY(GadgetHeight(LED()\CanvasNum)), LED()\Color\Gadget)
		  EndIf  
			;}

			;{ _____ Border ____
			If LED()\Flags & #Border
				DrawingMode(#PB_2DDrawing_Outlined)
				Box_(0, 0, dpiX(GadgetWidth(LED()\CanvasNum)), dpiY(GadgetHeight(LED()\CanvasNum)), LED()\Color\Border)
			EndIf ;}

			StopDrawing()
		EndIf
		
		If StartVectorDrawing(CanvasVectorOutput(LED()\CanvasNum))
		  
		  X = Width / 2
		  Y = Height / 2
		  
		  If Width > Height
		    Radius = (Height - dpiY(LED()\Padding * 2)) / 2
		  Else
		    Radius = (Width - dpiX(LED()\Padding * 2)) / 2
		  EndIf  
		  
		  Color         = LED()\StateColor(Str(LED()\State))
		  BorderColor   = BlendColor_(Color, LED()\Color\Front, 95)
		  If LED()\State
		    GradientColor = BlendColor_(Color, LED()\Color\Gradient, 50)
		  Else
		    GradientColor = BlendColor_(Color, $DCDCDC, 60)
		  EndIf  

		  VectorSourceCircularGradient(X, Y, Radius) 
		  AddPathCircle(X, Y, Radius)
		  VectorSourceGradientColor(RGBA(Red(Color), Green(Color), Blue(Color), 255), 1)
		  VectorSourceGradientColor(RGBA(Red(GradientColor), Green(GradientColor), Blue(GradientColor), 255), 0)	  
		  FillPath()

		  AddPathCircle(X, Y, Radius)
		  VectorSourceColor(RGBA(Red(BorderColor), Green(BorderColor), Blue(BorderColor), 255))
		  StrokePath(2)
      
		  StopVectorDrawing()
		EndIf   
		
	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach LED()

        LED()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
				LED()\Color\Border       = ModuleEx::ThemeGUI\BorderColor
				LED()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor

        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
	
	Procedure _RightClickHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(LED(), Str(GNum))

			X = GetGadgetAttribute(LED()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(LED()\CanvasNum, #PB_Canvas_MouseY)


			If X > = LED()\Size\X And X <= LED()\Size\X + LED()\Size\Width
				If Y >= LED()\Size\Y And Y <= LED()\Size\Y + LED()\Size\Height

					If IsWindow(LED()\Window\Num) And IsMenu(LED()\PopUpNum)
					  DisplayPopupMenu(LED()\PopUpNum, WindowID(LED()\Window\Num))
					EndIf

				EndIf
			EndIf

		EndIf

	EndProcedure

	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(LED(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach LED()

			If IsGadget(LED()\CanvasNum)

				If LED()\Flags & #AutoResize

					If IsWindow(LED()\Window\Num)

						OffSetX = WindowWidth(LED()\Window\Num)  - LED()\Window\Width
						OffsetY = WindowHeight(LED()\Window\Num) - LED()\Window\Height

						If LED()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If LED()\Size\Flags & #MoveX  : X = LED()\Size\X + OffSetX : EndIf
							If LED()\Size\Flags & #MoveY  : Y = LED()\Size\Y + OffSetY : EndIf
							If LED()\Size\Flags & #Width  : Width  = LED()\Size\Width + OffSetX : EndIf
							If LED()\Size\Flags & #Height : Height = LED()\Size\Height + OffSetY : EndIf

							ResizeGadget(LED()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(LED()\CanvasNum, #PB_Ignore, #PB_Ignore, LED()\Size\Width + OffSetX, LED()\Size\Height + OffsetY)
						EndIf

						Draw_()
					EndIf

				EndIf

			EndIf

		Next

	EndProcedure

	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================

	Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)

		If FindMapElement(LED(), Str(GNum))
			LED()\PopupNum = PopUpNum
		EndIf

	EndProcedure
	
	

	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
		Define DummyNum, Result.i
		
		CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
		
		If Flags & #UseExistingCanvas ;{ Use an existing CanvasGadget
      If IsGadget(GNum)
        Result = #True
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else
      Result = CanvasGadget(GNum, X, Y, Width, Height)
    EndIf
		
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(LED(), Str(GNum))

				LED()\CanvasNum = GNum

				CompilerIf Defined(ModuleEx, #PB_Module) ; WindowNum = #Default
					If WindowNum = #PB_Default
						LED()\Window\Num = ModuleEx::GetGadgetWindow()
					Else
						LED()\Window\Num = WindowNum
					EndIf
				CompilerElse
					If WindowNum = #PB_Default
						LED()\Window\Num = GetActiveWindow()
					Else
						LED()\Window\Num = WindowNum
					EndIf
				CompilerEndIf

				LED()\Size\X = X
				LED()\Size\Y = Y
				LED()\Size\Width  = Width
				LED()\Size\Height = Height
				
				LED()\Padding = 6
				LED()\Flags   = Flags
				
				LED()\StateColor("0") = $808080
				LED()\StateColor("1") = $32CD32
				
				LED()\Color\Front        = $000000
				LED()\Color\Back         = #PB_Default
				LED()\Color\Gadget       = $F0F0F0
				LED()\Color\Border       = $A0A0A0
				LED()\Color\Gradient     = $00D7FF
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						LED()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
						LED()\Color\Border = GetSysColor_(#COLOR_ACTIVEBORDER)
						LED()\Color\Gadget = GetSysColor_(#COLOR_MENU)
					CompilerCase #PB_OS_MacOS
						LED()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						LED()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						LED()\Color\Gadget = OSX_GadgetColor()
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(LED()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent(LED()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(LED()\Window\Num)
						LED()\Window\Width  = WindowWidth(LED()\Window\Num)
						LED()\Window\Height = WindowHeight(LED()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), LED()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(LED(), Str(GNum))
	    ProcedureReturn LED()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(LED(), Str(GNum))
	    ProcedureReturn LED()\ID
	  EndIf
	  
	EndProcedure
	
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(LED(), Str(GNum))
	    
	    If State
	      LED()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      LED()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(LED(), Str(GNum))
      
      Select Attribute
        Case #Corner
          LED()\Radius  = Value
        Case #Padding
          LED()\Padding = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure	
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(LED(), Str(GNum))
      
      LED()\Size\Flags = Flags
      LED()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i, State.i=1)
    
    If FindMapElement(LED(), Str(GNum))
    
      Select ColorTyp
        Case #StateColor
          LED()\StateColor(Str(State)) = Value
        Case #FrontColor
          LED()\Color\Front  = Value
        Case #BackColor
          LED()\Color\Back   = Value
        Case #BorderColor
          LED()\Color\Border = Value
        Case #GradientColor
          LED()\Color\Gradient = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(LED(), Str(GNum))
	    LED()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(LED(), Str(GNum))
	    LED()\ID = String
	  EndIf
	  
	EndProcedure

  Procedure   SetState(GNum.i, State.i) 
    
    If FindMapElement(LED(), Str(GNum))
      
      LED()\State = State
      
      Draw_()
    EndIf
    
  EndProcedure 
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #LED1
    #LED2
    #LED3
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 110, 70, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If LED::Gadget(#LED1, 10, 20, 25, 25, LED::#Border)
      LED::SetState(#LED1, 1)
    EndIf
    GadgetToolTip(#LED1, "Green")
    
    If LED::Gadget(#LED2, 45, 20, 25, 25, LED::#Border)
      LED::SetAttribute(#LED2, LED::#Corner, 4)
      LED::SetColor(#LED2, LED::#StateColor, $0000FF, 2)
      LED::SetState(#LED2, 2)
    EndIf
    GadgetToolTip(#LED2, "Red")
    
    If LED::Gadget(#LED3, 80, 20, 25, 25)
      LED::SetColor(#LED3, LED::#StateColor, $00A5FF, 3)
      LED::SetAttribute(#LED3, LED::#Padding, 5)
      LED::SetState(#LED3, 3)
    EndIf
    GadgetToolTip(#LED3, "Orange")
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 236
; FirstLine = 110
; Folding = OYkhNEHE-
; EnableXP
; DPIAware