;/ ============================
;/ =    ContainerExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ ContainerEx - Gadget
;/
;/ © 2019  by Thorsten Hoeppner (11/2019)
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


;{ _____ ContainerEx - Commands _____

; ContainerEx::Close()              - similar to 'CloseGadgetList()'
; ContainerEx::DisableReDraw()      - disable redraw
; ContainerEx::Gadget()             - similar to 'ContainerGadget()'
; ContainerEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; ContainerEx::SetColor()           - similar to 'SetGadgetColor()'
; ContainerEx::SetFont()            - similar to 'SetGadgetFont()'
; ContainerEx::SetText()            - similar to 'SetGadgetText()'

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule ContainerEx

	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  ;{ _____ Constants _____
  EnumerationBinary ;{ GadgetFlags
    #Border = #PB_Container_Flat ; Draw a border
    #Center
    #Right
		#AutoResize                  ; Automatic resizing of the gadget
		#ToolTips                    ; Show tooltips
	EndEnumeration ;}
	#Left = 0
	
	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}

	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
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
	
	Declare   Close(GNum.i)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetFont(GNum.i, FontID.i) 
  Declare   SetText(GNum.i, Text.s, Flags.i=#False)
  
EndDeclareModule

Module ContainerEx

	EnableExplicit

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================

	Structure ContainerEx_Color_Structure   ;{ ContainerEx()\Color\...
		Front.i
		Back.i
		Gadget.i
		Border.i
	EndStructure  ;}

	Structure ContainerEx_Window_Structure  ;{ ContainerEx()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure ContainerEx_Size_Structure    ;{ ContainerEx()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}

	Structure ContainerEx_Structure         ;{ ContainerEx()\...
		CanvasNum.i

		FontID.i
		
		Text.s
		
		ReDraw.i

		Flags.i

		ToolTip.i
		ToolTipText.s

		Color.ContainerEx_Color_Structure
		Window.ContainerEx_Window_Structure
		Size.ContainerEx_Size_Structure
		
		Map  PopUpItem.s()

	EndStructure ;}
	Global NewMap ContainerEx.ContainerEx_Structure()

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

	Procedure   Draw_()
		Define.i X, Y, Width, Height, TextHeight, TextWidth
		Define.i BorderColor
		
		Width  = dpiX(GadgetWidth(ContainerEx()\CanvasNum))
		Height = dpiY(GadgetHeight(ContainerEx()\CanvasNum))

		If StartDrawing(CanvasOutput(ContainerEx()\CanvasNum))

			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			Box(0, 0, dpiX(GadgetWidth(ContainerEx()\CanvasNum)), dpiY(GadgetHeight(ContainerEx()\CanvasNum)), ContainerEx()\Color\Gadget)
			;}
			
			If ContainerEx()\Flags & #Border
			
  			DrawingFont(ContainerEx()\FontID)
  			
  			If ContainerEx()\Text
  			  TextHeight = TextHeight(ContainerEx()\Text)
  			  TextWidth  = TextWidth(ContainerEx()\Text)
    			Y = Round(TextHeight / 2, #PB_Round_Down)
    			Height - Y
    		EndIf
    		
    		If ContainerEx()\Color\Back <> #PB_Default
    		  DrawingMode(#PB_2DDrawing_Default)
    		  Box(X, Y, Width, Height, ContainerEx()\Color\Back)
    		EndIf
    		
  			DrawingMode(#PB_2DDrawing_Outlined)
  			Box(X, Y, Width, Height, ContainerEx()\Color\Border)
  			
  			If ContainerEx()\Text
    			If ContainerEx()\Flags & #Center
    			  X = (Width - TextWidth - dpiX(4)) / 2
    			ElseIf ContainerEx()\Flags & #Right
    			  X = Width - TextWidth - dpiX(14)
    			Else
    			  X = dpiX(10)
    			EndIf  
    			
    			Line(X, Y, TextWidth + dpiX(4), 1, ContainerEx()\Color\Gadget)
    			
    			DrawingMode(#PB_2DDrawing_Transparent)
    			DrawText(X + dpiX(2), 0, ContainerEx()\Text, ContainerEx()\Color\Front, ContainerEx()\Color\Back)
    			
    		EndIf
    		
			EndIf 
			
			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ContainerEx()
        
        ContainerEx()\Color\Front  = ModuleEx::ThemeGUI\FrontColor
				ContainerEx()\Color\Back   = ModuleEx::ThemeGUI\BackColor
				ContainerEx()\Color\Border = ModuleEx::ThemeGUI\BorderColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 

	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(ContainerEx(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach ContainerEx()

			If IsGadget(ContainerEx()\CanvasNum)

				If ContainerEx()\Flags & #AutoResize

					If IsWindow(ContainerEx()\Window\Num)

						OffSetX = WindowWidth(ContainerEx()\Window\Num)  - ContainerEx()\Window\Width
						OffsetY = WindowHeight(ContainerEx()\Window\Num) - ContainerEx()\Window\Height

						If ContainerEx()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If ContainerEx()\Size\Flags & #MoveX  : X = ContainerEx()\Size\X + OffSetX : EndIf
							If ContainerEx()\Size\Flags & #MoveY  : Y = ContainerEx()\Size\Y + OffSetY : EndIf
							If ContainerEx()\Size\Flags & #Width  : Width  = ContainerEx()\Size\Width + OffSetX : EndIf
							If ContainerEx()\Size\Flags & #Height : Height = ContainerEx()\Size\Height + OffSetY : EndIf

							ResizeGadget(ContainerEx()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(ContainerEx()\CanvasNum, #PB_Ignore, #PB_Ignore, ContainerEx()\Size\Width + OffSetX, ContainerEx()\Size\Height + OffsetY)
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

	Procedure   DisableReDraw(GNum.i, State.i=#False)

		If FindMapElement(ContainerEx(), Str(GNum))

			If State
				ContainerEx()\ReDraw = #False
			Else
				ContainerEx()\ReDraw = #True
				Draw_()
			EndIf

		EndIf

	EndProcedure

	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
		Define DummyNum, Result.i

		Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Container)
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(ContainerEx(), Str(GNum))

				ContainerEx()\CanvasNum = GNum

				CompilerIf Defined(ModuleEx, #PB_Module) ; WindowNum = #Default
					If WindowNum = #PB_Default
						ContainerEx()\Window\Num = ModuleEx::GetGadgetWindow()
					Else
						ContainerEx()\Window\Num = WindowNum
					EndIf
				CompilerElse
					If WindowNum = #PB_Default
						ContainerEx()\Window\Num = GetActiveWindow()
					Else
						ContainerEx()\Window\Num = WindowNum
					EndIf
				CompilerEndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						ContainerEx()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							ContainerEx()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						ContainerEx()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				ContainerEx()\Size\X = X
				ContainerEx()\Size\Y = Y
				ContainerEx()\Size\Width  = Width
				ContainerEx()\Size\Height = Height

				ContainerEx()\Flags  = Flags

				ContainerEx()\ReDraw = #True

				ContainerEx()\Color\Front  = $000000
				ContainerEx()\Color\Border = $A0A0A0
				ContainerEx()\Color\Gadget = $EDEDED
				ContainerEx()\Color\Back   = #PB_Default
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						ContainerEx()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
						ContainerEx()\Color\Border = GetSysColor_(#COLOR_WINDOWFRAME)
						ContainerEx()\Color\Gadget = GetSysColor_(#COLOR_MENU)
					CompilerCase #PB_OS_MacOS
						ContainerEx()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						ContainerEx()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						ContainerEx()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(ContainerEx()\Window\Num)
						ContainerEx()\Window\Width  = WindowWidth(ContainerEx()\Window\Num)
						ContainerEx()\Window\Height = WindowHeight(ContainerEx()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ContainerEx()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	Procedure   Close(GNum.i)
	  
	  If FindMapElement(ContainerEx(), Str(GNum))
	    CloseGadgetList()
	  EndIf
	  
	EndProcedure  
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ContainerEx(), Str(GNum))
      
      ContainerEx()\Size\Flags = Flags
      ContainerEx()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(ContainerEx(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          ContainerEx()\Color\Front  = Value
        Case #BackColor
          ContainerEx()\Color\Back   = Value
        Case #BorderColor
          ContainerEx()\Color\Border = Value
      EndSelect
      
      If ContainerEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i) 
    
    If FindMapElement(ContainerEx(), Str(GNum))
      
      ContainerEx()\FontID = FontID
      
      If ContainerEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetText(GNum.i, Text.s, Flags.i=#False)
    
    If FindMapElement(ContainerEx(), Str(GNum))
      
      ContainerEx()\Text = Text
      ContainerEx()\Flags | Flags
      
      If ContainerEx()\ReDraw : Draw_() : EndIf
    EndIf  
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #Container
    #Button
    #Font
  EndEnumeration
  
  LoadFont(#Font, "Arial", 10, #PB_Font_Bold)
  
  If OpenWindow(#Window, 0, 0, 300, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If ContainerEx::Gadget(#Container, 10, 10, 280, 180, ContainerEx::#Border|ContainerEx::#AutoResize, #Window)
      
      ContainerEx::SetText(#Container, "ContainerEx", ContainerEx::#Left)
      ContainerEx::SetFont(#Container, FontID(#Font))
      ContainerEx::SetColor(#Container, ContainerEx::#FrontColor, $800000)
      ContainerEx::SetColor(#Container, ContainerEx::#BackColor,  $FFFFFF)
      
      ButtonGadget(#Button, 20, 30, 90, 25, "Gadget")
      
      ContainerEx::Close(#Container)
    EndIf
    
    Repeat
      Event = WaitWindowEvent()       
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 39
; FirstLine = 79
; Folding = MEAAAA9
; EnableXP
; DPIAware