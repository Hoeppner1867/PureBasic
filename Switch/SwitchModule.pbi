;/ ============================
;/ =    SwitchModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Switch - Gadget
;/
;/ © 2019 by Thorsten Hoeppner ({12/2019)
;/

; Last Update:


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

;{ ===== Tea & Pizza Ware =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ Switch - Commands _____
; Switch::Gadget()             - similar to 'ButtonGadget()'
; Switch::GetData()            - similar to 'GetGadgetData()'
; Switch::GetID()              - similar to 'GetGadgetData()', but it uses a string
; Switch::GetState()           - similar to 'GetGadgetState()'
; Switch::Hide()               - similar to 'HideGadget()'
; Switch::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; Switch::SetAttribute()       - similar to 'SetGadgetAttribute()'
; Switch::SetColor()           - similar to 'SetGadgetColor()'
; Switch::SetData()            - similar to 'SetGadgetData()'
; Switch::SetFont()            - similar to 'SetGadgetFont()'
; Switch::SetID()              - similar to 'SetGadgetData()', but it uses a string
; Switch::SetState()           - similar to 'SetGadgetState()'
;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule Switch
  
  #Version  = 19112900
  #ModuleEx = 19112100
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	;{ _____ Constants _____
	EnumerationBinary ;{ GadgetFlags
		#AutoResize        ; Automatic resizing of the gadget
		#Borderless        ; Draw no border
		#ColorText         ; enable on/off text color
		#ColorBack         ; enable on/off back color
		#ToolTips          ; Show tooltips
		#UseExistingCanvas ; e.g. for dialogs
	EndEnumeration ;}

	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}
	
	Enumeration 1     ;{ Attribute
	  #Corner
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
		#OnColor
		#OffColor
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

  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, ON.s="", OFF.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.q GetData(GNum.i)
  Declare.s GetID(GNum.i)
  Declare.i GetState(GNum.i)
  Declare   Hide(GNum.i, State.i=#True) 
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontID.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetState(GNum.i, State.i)
  
EndDeclareModule

Module Switch

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	Structure Switch_Text_Structure    ;{ Switch()\Text\...
	  ON.s
	  OFF.s
	EndStructure ;}
	
	Structure Switch_Color_Structure   ;{ Switch()\Color\...
		Front.i
		Back.i
		Border.i
		Button.i
		Gadget.i
		Focus.i
		On.i
		Off.i
		DisableFront.i
		DisableBack.i
	EndStructure  ;}

	Structure Switch_Window_Structure  ;{ Switch()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure Switch_Size_Structure    ;{ Switch()\Size\...
		X.i
		Y.i
		Width.i
		Height.i
		Button.i
		Flags.i
	EndStructure ;}


	Structure Switch_Structure         ;{ Switch()\...
		CanvasNum.i
		PopupNum.i
		
		ID.s
		Quad.i
		
		FontID.i
		
    Radius.i
		Hide.i
		Disable.i
		
		State.i
		
		Flags.i

		ToolTip.i
		ToolTipText.s
		
		Text.Switch_Text_Structure
		
		Color.Switch_Color_Structure
		Window.Switch_Window_Structure
		Size.Switch_Size_Structure

	EndStructure ;}
	Global NewMap Switch.Switch_Structure()

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================

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

	CompilerEndIf
	
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure.i GetGadgetWindow()
      ProcedureReturn ModuleEx::GetGadgetWindow()
    EndProcedure
    
  CompilerElse  
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      ; Thanks to mk-soft
      Import ""
        PB_Object_EnumerateStart(PB_Objects)
        PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
        PB_Object_EnumerateAbort( PB_Objects )
        PB_Window_Objects.i
      EndImport
    CompilerElse
      ImportC ""
        PB_Object_EnumerateStart( PB_Objects )
        PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
        PB_Object_EnumerateAbort( PB_Objects )
        PB_Window_Objects.i
      EndImport
    CompilerEndIf
    
    Procedure.i GetGadgetWindow()
      ; Thanks to mk-soft
      Define.i WindowID, Window, Result = #PB_Default
      
      WindowID = UseGadgetList(0)
      
      PB_Object_EnumerateStart(PB_Window_Objects)
      
      While PB_Object_EnumerateNext(PB_Window_Objects, @Window)
        If WindowID = WindowID(Window)
          Result = Window
          Break
        EndIf
      Wend
      
      PB_Object_EnumerateAbort(PB_Window_Objects)
      
      ProcedureReturn Result
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
  
    If Switch()\Radius
  		RoundBox(X, Y, Width, Height, Switch()\Radius, Switch()\Radius, Color)
  	Else
  		Box(X, Y, Width, Height, Color)
  	EndIf
  	
  EndProcedure
	
	Procedure   Draw_()
		Define.i X, Y, Width, Height, OffsetX, OffSetY
		Define.i FrontColor, BackColor, ButtonColor, BorderColor
		Define.s Text
		
		If Switch()\Hide : ProcedureReturn #False : EndIf 
		
		X = 0
		Y = 0

		Width   = dpiX(GadgetWidth(Switch()\CanvasNum)) 
		Height  = dpiY(GadgetHeight(Switch()\CanvasNum))
		
		Switch()\Size\Button = Width / 2
		
		If StartDrawing(CanvasOutput(Switch()\CanvasNum))
		  
		  FrontColor  = Switch()\Color\Front
		  BackColor   = BlendColor_(Switch()\Color\Gadget, Switch()\Color\Border, 75)
		  ButtonColor = Switch()\Color\Back
		  BorderColor = Switch()\Color\Border
		  
		  If Switch()\State
		    If Switch()\Flags & #ColorText : FrontColor = Switch()\Color\On : EndIf
		    If Switch()\Flags & #ColorBack : BackColor  = BlendColor_(Switch()\Color\On,  Switch()\Color\Gadget, 10) : EndIf
		  Else
		    If Switch()\Flags & #ColorText : FrontColor = Switch()\Color\Off : EndIf
		    If Switch()\Flags & #ColorBack : BackColor  = BlendColor_(Switch()\Color\Off, Switch()\Color\Gadget, 10) : EndIf
		  EndIf  
		  
		  If Switch()\Disable
		    FrontColor  = Switch()\Color\DisableFront
		    BackColor   = Switch()\Color\DisableBack
		    BorderColor = Switch()\Color\DisableFront
		  EndIf  
		  
			;{ _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  Box(0, 0, Width, Height, Switch()\Color\Gadget)
		  Box_(0, 0, Width, Height, BackColor)
			;}

			DrawingFont(Switch()\FontID)
			
			If Switch()\State
			  X = Switch()\Size\Button
			  Text = Switch()\Text\ON
			Else
			  X = 0
			  Text = Switch()\Text\OFF
			EndIf 
			
			;{ _____ Switch _____
			Box_(X, 0, Switch()\Size\Button, Height, ButtonColor)
			Line(Switch()\Size\Button, 0, dpiX(1), Height, BorderColor)
			;}			
			
			;{ _____ Text _____
			If Text
			  OffsetX = (Switch()\Size\Button - TextWidth(Text)) / 2
			  OffsetY = (Height - TextHeight(Text)) / 2
			  DrawingMode(#PB_2DDrawing_Transparent)
			  DrawText(X + OffsetX, Y + OffsetY, Text, FrontColor)
			EndIf  
			;}
			
			;{ _____ Border ____
			If Switch()\Flags & #Borderless = #False
				DrawingMode(#PB_2DDrawing_Outlined)
				Box_(0, 0, Width, Height, BorderColor)
			EndIf ;}

			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach Switch()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          Switch()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf

        Switch()\Color\Front        = ModuleEx::ThemeGUI\Button\FrontColor
				Switch()\Color\Back         = ModuleEx::ThemeGUI\Button\BackColor
				Switch()\Color\Border       = ModuleEx::ThemeGUI\Button\BorderColor
				Switch()\Color\Button       = ModuleEx::ThemeGUI\Button\SwitchColor
				Switch()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
				Switch()\Color\Focus        = ModuleEx::ThemeGUI\Focus\BackColor
				Switch()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
		    Switch()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
				
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
  
  
	Procedure _LeftClickHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(Switch(), Str(GNum))
		  Switch()\State ! #True
      Draw_()
		EndIf

	EndProcedure



	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(Switch(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)



			Switch()\ToolTip = #False
			GadgetToolTip(GNum, "")

			SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure


	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(Switch(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach Switch()

			If IsGadget(Switch()\CanvasNum)

				If Switch()\Flags & #AutoResize

					If IsWindow(Switch()\Window\Num)

						OffSetX = WindowWidth(Switch()\Window\Num)  - Switch()\Window\Width
						OffsetY = WindowHeight(Switch()\Window\Num) - Switch()\Window\Height

						If Switch()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If Switch()\Size\Flags & #MoveX  : X = Switch()\Size\X + OffSetX : EndIf
							If Switch()\Size\Flags & #MoveY  : Y = Switch()\Size\Y + OffSetY : EndIf
							If Switch()\Size\Flags & #Width  : Width  = Switch()\Size\Width + OffSetX : EndIf
							If Switch()\Size\Flags & #Height : Height = Switch()\Size\Height + OffSetY : EndIf

							ResizeGadget(Switch()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(Switch()\CanvasNum, #PB_Ignore, #PB_Ignore, Switch()\Size\Width + OffSetX, Switch()\Size\Height + OffsetY)
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

	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(Switch(), Str(GNum))

      Switch()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 	
	

	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, ON.s="", OFF.s="", Flags.i=#False, WindowNum.i=#PB_Default)
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

			If AddMapElement(Switch(), Str(GNum))

				Switch()\CanvasNum = GNum
				
				If WindowNum = #PB_Default
          Switch()\Window\Num = GetGadgetWindow()
        Else
          Switch()\Window\Num = WindowNum
        EndIf
				
				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						Switch()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							Switch()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						Switch()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				Switch()\Size\X = X
				Switch()\Size\Y = Y
				Switch()\Size\Width  = Width
				Switch()\Size\Height = Height
				
				Switch()\Text\ON  = ON
				Switch()\Text\OFF = OFF
				
				Switch()\Flags  = Flags

				Switch()\Color\Front        = $000000
				Switch()\Color\Back         = $E3E3E3
				Switch()\Color\Gadget       = $F0F0F0
				Switch()\Color\Border       = $A0A0A0
				Switch()\Color\Button       = $C8C8C8
				Switch()\Color\Focus        = $D77800
				Switch()\Color\On           = $228B22 
				Switch()\Color\Off          = $0000FF
				Switch()\Color\DisableFront = $72727D
				Switch()\Color\DisableBack  = $CCCCCA
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						Switch()\Color\Front  = GetSysColor_(#COLOR_BTNTEXT)
						Switch()\Color\Back   = GetSysColor_(#COLOR_3DLIGHT)
						Switch()\Color\Button = GetSysColor_(#COLOR_SCROLLBAR)
						Switch()\Color\Border = GetSysColor_(#COLOR_WINDOWFRAME)
						Switch()\Color\Gadget = GetSysColor_(#COLOR_MENU)
						Switch()\Color\Focus  = GetSysColor_(#COLOR_MENUHILIGHT)
					CompilerCase #PB_OS_MacOS
						Switch()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						Switch()\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
						Switch()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						Switch()\Color\Button = 
						Switch()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						Switch()\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(Switch()\CanvasNum,  @_ResizeHandler(),    #PB_EventType_Resize)
				BindGadgetEvent(Switch()\CanvasNum,  @_MouseMoveHandler(), #PB_EventType_MouseMove)
				BindGadgetEvent(Switch()\CanvasNum,  @_LeftClickHandler(), #PB_EventType_LeftClick)
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(Switch()\Window\Num)
						Switch()\Window\Width  = WindowWidth(Switch()\Window\Num)
						Switch()\Window\Height = WindowHeight(Switch()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), Switch()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(Switch(), Str(GNum))
	    ProcedureReturn Switch()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(Switch(), Str(GNum))
	    ProcedureReturn Switch()\ID
	  EndIf
	  
	EndProcedure
	
  Procedure.i GetState(GNum.i)
	  
	  If FindMapElement(Switch(), Str(GNum))
	    ProcedureReturn Switch()\State
	  EndIf  
	  
	EndProcedure	
	
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(Switch(), Str(GNum))
	    
	    If State
	      Switch()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      Switch()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(Switch(), Str(GNum))
      
      Select Attribute
        Case #Corner
          Switch()\Radius  = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure	
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(Switch(), Str(GNum))
      
      Switch()\Size\Flags = Flags
      Switch()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(Switch(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          Switch()\Color\Front  = Value
        Case #BackColor
          Switch()\Color\Back   = Value
        Case #BorderColor
          Switch()\Color\Border = Value
        Case #OnColor
          Switch()\Color\On     = Value  
        Case #OffColor
          Switch()\Color\Off    = Value  
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(Switch(), Str(GNum))
	    Switch()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(Switch(), Str(GNum))
	    Switch()\ID = String
	  EndIf
	  
	EndProcedure

  Procedure   SetFont(GNum.i, Font.i) 
    
    If FindMapElement(Switch(), Str(GNum))
      
      If IsFont(Font)
        Switch()\FontID = FontID(Font)
        Draw_()
      EndIf
    
    EndIf
    
  EndProcedure  
  
  Procedure.i SetState(GNum.i, State.i)
	  
	  If FindMapElement(Switch(), Str(GNum))
	    Switch()\State = State
	    Draw_()
	  EndIf  
	  
	EndProcedure	
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #Switch1
    #Switch2
    #Font
  EndEnumeration
  
  LoadFont(#Font, "Arial", 8, #PB_Font_Bold)
  
  If OpenWindow(#Window, 0, 0, 180, 60, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If Switch::Gadget(#Switch1, 20, 20, 60, 20, "ON", "OFF", Switch::#ColorText|Switch::#ColorBack) ; 
      Switch::SetFont(#Switch1, #Font)
    EndIf
    
    If Switch::Gadget(#Switch2, 100, 20, 60, 20, "ON", "OFF", Switch::#ColorText|Switch::#ColorBack) ; 
      Switch::SetFont(#Switch2, #Font)
      Switch::SetAttribute(#Switch2, Switch::#Corner, 4)
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case Switch::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #Switch1
            Case #Switch2
          EndSelect ;}
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 56
; FirstLine = 18
; Folding = cQAAAAAAA5
; EnableXP
; DPIAware