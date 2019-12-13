;/ ===================================
;/ =    GradualProgressModule.pbi    =
;/ ===================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ GradualProgress - Gadget
;/
;/ based on the idea of Oliver13 ('Step Wizard')
;/
;/ © 2019  by Thorsten (11/2019)
;/

; Last Update: 08.12.19
;
; Added: #UseExistingCanvas
;

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


;{ _____ Gradual - Commands _____

; Gradual::DisableReDraw()      - disable/enable redrawing
; Gradual::Gadget()             - create a new gadget
; Gradual::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; Gradual::SetColor()           - similar to SetGadgetColor()
; Gradual::SetFont()            - similar to SetGadgetFont()
; Gradual::SetItemText()        - similar to SetGadgetItemText()
; Gradual::SetItemTooltip()     - defines the text for tooltips
; Gradual::SetState()           - similar to SetGadgetState()

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule Gradual
  
  #Version  = 19120800
  #ModuleEx = 19111702
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  ;{ _____ Constants _____
	EnumerationBinary ;{ GadgetFlags
	  #AutoResize   ; Automatic resizing of the gadget
	  #Border       ; Show borders
	  #PostEvents   ; Send events for left click
	  #ChangeCursor ; change the cursor for clickable areas
	  #ToolTips     ; Show tooltips
	  #UseExistingCanvas
	EndEnumeration ;}

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
		#ActiveBackColor
		#InActiveBackColor
		#ActiveFrontColor
		#InActiveFrontColor
	EndEnumeration ;}
	
	#Complete = -1
	
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

  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Steps.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontID.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetItemText(GNum.i, Item.i, Text.s)
  Declare   SetItemTooltip(GNum.i, Item.i, Text.s)
  Declare   SetState(GNum.i, State.i)
  
EndDeclareModule

Module Gradual

	EnableExplicit

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================

	Structure Gradual_Color_Structure   ;{ Gradual()\Color\...
	  Front.i
	  Back.i
		Border.i
	  ActiveBack.i
	  InActiveBack.i
	  ActiveFront.i
	  InActiveFront.i
	EndStructure  ;}

	Structure Gradual_Window_Structure  ;{ Gradual()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure Gradual_Size_Structure    ;{ Gradual()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}
	
	Structure Gradual_Steps_Structure   ;{ Gradual()\Steps\...
	  Number.i
	  Width.i
	  Triangle.i
	  Progress.i
	EndStructure ;}
	
	Structure Gradual_Item_Structure    ;{ Gradual()\Item()\...
	  X.i
	  Width.i
	  Text.s
	  Tooltip.s
	EndStructure ;}
	
	Structure Gradual_Structure         ;{ Gradual()\...
		CanvasNum.i
		
		Quad.q
		ID.s
		
		FontID.i
		
		ReDraw.i
		Number.i
		Flags.i

		ToolTip.i

		Color.Gradual_Color_Structure
		Window.Gradual_Window_Structure
		Size.Gradual_Size_Structure
		Steps.Gradual_Steps_Structure
		
		Map Item.Gradual_Item_Structure()
		
	EndStructure ;}
	Global NewMap Gradual.Gradual_Structure()

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

	Procedure   TriangleTip_(X.f, Y.f, Width.f, Height.f, Reverse.i=#False)
	  
	  If Reverse
	    AddPathLine(X + Width, Y + Round(Height / 2, #PB_Round_Nearest))
      AddPathLine(X, Y)
	  Else
      AddPathLine(X + Width, Y + Round(Height / 2, #PB_Round_Nearest))
      AddPathLine(X, Y + Height)
    EndIf
    
  EndProcedure
	
	Procedure   Draw_()
		Define.i s, X, Y, Width, Height, stepWidth, tipWidth, txtHeight, OffsetX, OffsetY
		Define.q ActiveBack, InActiveBack, ActiveBorder, InActiveBorder, Color
		Define.s Text

		Width  = dpiX(GadgetWidth(Gradual()\CanvasNum))
		Height = dpiY(GadgetHeight(Gradual()\CanvasNum))
		
		tipWidth  = dpiX(Gradual()\Steps\Triangle)
		stepWidth = dpiX(Gradual()\Steps\Width)

		If StartDrawing(CanvasOutput(Gradual()\CanvasNum))

			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			Box(0, 0, Width, Height, Gradual()\Color\Back)
			;}
			
		  StopDrawing()
		EndIf

		If StartVectorDrawing(CanvasVectorOutput(Gradual()\CanvasNum))	
		  
		  ActiveBack   = RGBA(Red(Gradual()\Color\ActiveBack), Green(Gradual()\Color\ActiveBack), Blue(Gradual()\Color\ActiveBack), 255)
		  InActiveBack = RGBA(Red(Gradual()\Color\InActiveBack), Green(Gradual()\Color\InActiveBack), Blue(Gradual()\Color\InActiveBack), 255)
		  
		  If Gradual()\Flags & #Border
		    Color          = BlendColor_(InActiveBack, Gradual()\Color\Border, 30)
		    InActiveBorder = RGBA(Red(Color), Green(Color), Blue(Color), 255)
		    Color          = BlendColor_(Gradual()\Color\ActiveBack, Gradual()\Color\Border, 30)
		    ActiveBorder   = RGBA(Red(Color), Green(Color), Blue(Color), 255)
		  Else
		    InActiveBorder = RGBA(Red(Gradual()\Color\Back), Green(Gradual()\Color\Back), Blue(Gradual()\Color\Back), 255)
		    ActiveBorder   = InActiveBorder
		  EndIf  

		  X = 1
		  Y = 1

		  ;{ ----- First Step -----
		  MovePathCursor(X, Y + Height - 2)
		  AddPathLine(X, Y)
		  AddPathLine(X + stepWidth, Y)
		  TriangleTip_(X + stepWidth, Y, tipWidth, Height - 2)
		  ClosePath()

		  If Gradual()\Steps\Progress >= 1
		    VectorSourceColor(ActiveBack)
		    FillPath(#PB_Path_Preserve)
		    VectorSourceColor(ActiveBorder)
		    StrokePath(2, #PB_Path_RoundCorner)
		  Else
		    VectorSourceColor(InActiveBack)
		    FillPath(#PB_Path_Preserve)
		    VectorSourceColor(InActiveBorder)
		    StrokePath(2, #PB_Path_RoundCorner)
		  EndIf  
		  
		  X + stepWidth
		  ;}
		  
		  ;{ ----- Steps -----
		  For s=2 To Gradual()\Steps\Number
		    
		    MovePathCursor(X, Y + Height - 2)
		    TriangleTip_(X, Y, tipWidth, Height - 2, #True)
		    
		    X + stepWidth
		    
		    AddPathLine(X, Y)
		    TriangleTip_(X, Y, tipWidth, Height - 2)
		    ClosePath()
		    
		    If s <= Gradual()\Steps\Progress
		      VectorSourceColor(ActiveBack)
  		    FillPath(#PB_Path_Preserve)
  		    VectorSourceColor(ActiveBorder)
  		    StrokePath(2, #PB_Path_RoundCorner)
  		  Else
  		    VectorSourceColor(InActiveBack)
  		    FillPath(#PB_Path_Preserve)
  		    VectorSourceColor(InActiveBorder)
  		    StrokePath(2, #PB_Path_RoundCorner)
  		  EndIf 

			Next ;}
			
			;{ ----- Complete -----
			stepWidth = Width - (stepWidth * Gradual()\Steps\Number) - 2
			
			MovePathCursor(X, Y + Height - 2)
			TriangleTip_(X, Y, tipWidth, Height - 2, #True)

			AddPathLine(X + stepWidth, Y)
		  AddPathLine(X + stepWidth, Y + Height - 2)
		  ClosePath()
		  
		  If Gradual()\Steps\Progress = Gradual()\Steps\Number + 1
		    VectorSourceColor(ActiveBack)
		    FillPath(#PB_Path_Preserve)
		    VectorSourceColor(ActiveBorder)
		    StrokePath(2, #PB_Path_RoundCorner)
		  Else
  		  VectorSourceColor(InActiveBack)
		    FillPath(#PB_Path_Preserve)
		    VectorSourceColor(InActiveBorder)
		    StrokePath(2, #PB_Path_RoundCorner)  
		  EndIf 
		  ;}
		  
			StopVectorDrawing()
		EndIf
		
		If StartDrawing(CanvasOutput(Gradual()\CanvasNum))	
		  
		  DrawingMode(#PB_2DDrawing_Transparent)
		  
		  DrawingFont(Gradual()\FontID)
		  
		  X = 0
		  
		  stepWidth = dpiX(Gradual()\Steps\Width)
		  txtHeight = TextHeight("Abc")
		  OffsetY   = (Height - txtHeight) / 2
		  
		  ;{ ----- First Step -----
		  Text = Gradual()\Item("1")\Text
		  If Text = "" : Text = "1" : EndIf
		  
		  Gradual()\Item("1")\X     = 0
		  Gradual()\Item("1")\Width = stepWidth
		  
		  OffsetX = (stepWidth + tipWidth - TextWidth(Text)) / 2
		  
		  If Gradual()\Steps\Progress >= 1
  		  DrawText(X + OffsetX, OffsetY, Text, Gradual()\Color\ActiveFront)
  		Else
  		  DrawText(X + OffsetX, OffsetY, Text, Gradual()\Color\InActiveFront)
  		EndIf

		  X + stepWidth
		  ;}
		  
		  ;{ ----- Steps -----
		  For s=2 To Gradual()\Steps\Number
		    
		    Text = Gradual()\Item(Str(s))\Text
		    If Text = "" : Text = Str(s) : EndIf
		    
		    Gradual()\Item(Str(s))\X     = X + tipWidth
		    Gradual()\Item(Str(s))\Width = stepWidth - tipWidth
		    
		    OffsetX = (stepWidth - TextWidth(Text)) / 2
		    
		    If s <= Gradual()\Steps\Progress
		      DrawText(X + tipWidth + OffsetX, OffsetY, Text, Gradual()\Color\ActiveFront)
		    Else
		      DrawText(X + tipWidth + OffsetX, OffsetY, Text, Gradual()\Color\InActiveFront)
		    EndIf
		    
		    X + stepWidth
		  Next ;}
		  
		  ;{ ----- Complete -----
		  stepWidth = Width - (stepWidth * Gradual()\Steps\Number) - tipWidth
		  
		  Text = Gradual()\Item(Str(Gradual()\Steps\Number + 1))\Text
		  If Text = "" : Text = "Complete" : EndIf
		  
		  Gradual()\Item(Str(Gradual()\Steps\Number + 1))\X     = X + tipWidth
		  Gradual()\Item(Str(Gradual()\Steps\Number + 1))\Width = stepWidth
		  
		  OffsetX = (stepWidth - TextWidth(Text)) / 2
		  
		  If Gradual()\Steps\Progress = Gradual()\Steps\Number + 1
		    DrawText(X + tipWidth + OffsetX, OffsetY, Text, Gradual()\Color\ActiveFront)
		  Else
		    DrawText(X + tipWidth + OffsetX, OffsetY, Text, Gradual()\Color\InActiveFront)
		  EndIf
		  ;}
		  
			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach Gradual()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        Gradual()\Color\Front         = ModuleEx::ThemeGUI\FrontColor
				Gradual()\Color\Back          = ModuleEx::ThemeGUI\BackColor
				Gradual()\Color\Border        = ModuleEx::ThemeGUI\BorderColor
				Gradual()\Color\ActiveBack    = ModuleEx::ThemeGUI\Progress\GradientColor
				
				Gradual()\Color\InActiveBack  = BlendColor_(Gradual()\Color\ActiveBack, ModuleEx::ThemeGUI\GadgetColor, 25)
				Gradual()\Color\ActiveFront   = ModuleEx::ThemeGUI\Progress\FrontColor
				Gradual()\Color\InActiveFront = BlendColor_(Gradual()\Color\ActiveBack, ModuleEx::ThemeGUI\GadgetColor, 70)

        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf  
  
	
	Procedure _LeftClickHandler()
		Define.i s, X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(Gradual(), Str(GNum))

			X = GetGadgetAttribute(Gradual()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(Gradual()\CanvasNum, #PB_Canvas_MouseY)
			
			For s=1 To Gradual()\Steps\Number + 1
			  
			  If X > Gradual()\Item(Str(s))\X And X < Gradual()\Item(Str(s))\X + Gradual()\Item(Str(s))\Width
			  
			    If Gradual()\Flags & #PostEvents
			      PostEvent(#Event_Gadget, Gradual()\Window\Num, GNum, #PB_EventType_LeftClick, s)
			    EndIf

  		    ProcedureReturn #True
  		  EndIf 
		  
			Next

		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
		Define.i s, X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(Gradual(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
 
			For s=1 To Gradual()\Steps\Number + 1
			  
			  If X > Gradual()\Item(Str(s))\X And X < Gradual()\Item(Str(s))\X + Gradual()\Item(Str(s))\Width
			  
			    If Gradual()\Flags & #ChangeCursor
			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
  		    EndIf
  		    
  		    If Gradual()\Flags & #ToolTips
  		      If Gradual()\ToolTip = #False
  		        GadgetToolTip(GNum, Gradual()\Item(Str(s))\Tooltip)
  		        Gradual()\ToolTip = #True
  		      EndIf  
  		    EndIf
  		    
  		    ProcedureReturn #True
  		  EndIf 
		  
			Next

			Gradual()\ToolTip = #False
			GadgetToolTip(GNum, "")

			SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure

	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(Gradual(), Str(GadgetID))
		  
		  Gradual()\Steps\Width    = GadgetWidth(GadgetID) / (Gradual()\Steps\Number + 1)
		  Gradual()\Steps\Triangle = GadgetHeight(GadgetID) / 3
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach Gradual()

			If IsGadget(Gradual()\CanvasNum)

				If Gradual()\Flags & #AutoResize

					If IsWindow(Gradual()\Window\Num)

						OffSetX = WindowWidth(Gradual()\Window\Num)  - Gradual()\Window\Width
						OffsetY = WindowHeight(Gradual()\Window\Num) - Gradual()\Window\Height

						If Gradual()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If Gradual()\Size\Flags & #MoveX  : X = Gradual()\Size\X + OffSetX : EndIf
							If Gradual()\Size\Flags & #MoveY  : Y = Gradual()\Size\Y + OffSetY : EndIf
							If Gradual()\Size\Flags & #Width  : Width  = Gradual()\Size\Width + OffSetX : EndIf
							If Gradual()\Size\Flags & #Height : Height = Gradual()\Size\Height + OffSetY : EndIf

							ResizeGadget(Gradual()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(Gradual()\CanvasNum, #PB_Ignore, #PB_Ignore, Gradual()\Size\Width + OffSetX, Gradual()\Size\Height + OffsetY)
						EndIf

					EndIf

				EndIf

			EndIf

		Next

	EndProcedure

	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================

	Procedure   DisableReDraw(GNum.i, State.i=#False)

		If FindMapElement(Gradual(), Str(GNum))

			If State
				Gradual()\ReDraw = #False
			Else
				Gradual()\ReDraw = #True
				Draw_()
			EndIf

		EndIf

	EndProcedure

	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Steps.i, Flags.i=#False, WindowNum.i=#PB_Default)
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

			If AddMapElement(Gradual(), Str(GNum))

				Gradual()\CanvasNum = GNum

				If WindowNum = #PB_Default
          Gradual()\Window\Num = GetGadgetWindow()
        Else
          Gradual()\Window\Num = WindowNum
        EndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						Gradual()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							Gradual()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						Gradual()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				Gradual()\Size\X = X
				Gradual()\Size\Y = Y
				Gradual()\Size\Width  = Width
				Gradual()\Size\Height = Height
				
				Gradual()\Steps\Number   = Steps
				Gradual()\Steps\Width    = Width / (Steps + 1)
				Gradual()\Steps\Triangle = Height / 3
				
				Gradual()\Flags  = Flags

				Gradual()\ReDraw = #True

				Gradual()\Color\Front         = $000000
				Gradual()\Color\Back          = $EDEDED
				Gradual()\Color\Border        = $A0A0A0
				Gradual()\Color\ActiveBack    = $00CC99
				Gradual()\Color\InActiveBack  = BlendColor_($00CC99, $EDEDED, 25)
				Gradual()\Color\ActiveFront   = BlendColor_($FFFFFF, $00CC99, 90)
				Gradual()\Color\InActiveFront = BlendColor_($00CC99, $EDEDED, 70)
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						Gradual()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
						Gradual()\Color\Back   = GetSysColor_(#COLOR_MENU)
						Gradual()\Color\Border = GetSysColor_(#COLOR_WINDOWFRAME)
					CompilerCase #PB_OS_MacOS
						Gradual()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						Gradual()\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						Gradual()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(Gradual()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent(Gradual()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
				BindGadgetEvent(Gradual()\CanvasNum,  @_LeftClickHandler(),       #PB_EventType_LeftClick)
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enable AutoResize
					If IsWindow(Gradual()\Window\Num)
						Gradual()\Window\Width  = WindowWidth(Gradual()\Window\Num)
						Gradual()\Window\Height = WindowHeight(Gradual()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), Gradual()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(Gradual(), Str(GNum))
	    ProcedureReturn Gradual()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(Gradual(), Str(GNum))
	    ProcedureReturn Gradual()\ID
	  EndIf
	  
	EndProcedure
	
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(Gradual(), Str(GNum))
      
      Gradual()\Size\Flags = Flags
      Gradual()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(Gradual(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          Gradual()\Color\Front         = Value
        Case #BackColor
          Gradual()\Color\Back          = Value
        Case #BorderColor
          Gradual()\Color\Border        = Value  
        Case #ActiveBackColor
          Gradual()\Color\ActiveBack    = Value
          Gradual()\Color\InActiveBack  = BlendColor_(Value, Gradual()\Color\Back, 25)
          Gradual()\Color\ActiveFront   = BlendColor_($FFFFFF, Value, 90)
				  Gradual()\Color\InActiveFront = BlendColor_(Value, Gradual()\Color\Back, 70)
        Case #InActiveBackColor
          Gradual()\Color\InActiveBack  = Value  
        Case #ActiveFrontColor
          Gradual()\Color\ActiveFront   = Value
        Case #InActiveFrontColor
          Gradual()\Color\InActiveFront = Value
      EndSelect
      
      If Gradual()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(Gradual(), Str(GNum))
	    Gradual()\Quad = Value
	  EndIf  
	  
	EndProcedure  
  
  Procedure   SetFont(GNum.i, FontID.i) 
    
    If FindMapElement(Gradual(), Str(GNum))
      
      Gradual()\FontID = FontID
      
      If Gradual()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(Gradual(), Str(GNum))
	    Gradual()\ID = String
	  EndIf
	  
	EndProcedure	  
  
  Procedure   SetItemText(GNum.i, Item.i, Text.s)
    
    If FindMapElement(Gradual(), Str(GNum))
      
      If Item = #Complete : Item = Gradual()\Steps\Number + 1 : EndIf
      
      If Item >= 1 And Item <= Gradual()\Steps\Number + 1
        Gradual()\Item(Str(Item))\Text = Text
      EndIf  
      
      If Gradual()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetItemTooltip(GNum.i, Item.i, Text.s)
    
    If FindMapElement(Gradual(), Str(GNum))
      
      If Item = #Complete : Item = Gradual()\Steps\Number + 1 : EndIf
      
      If Item >= 1 And Item <= Gradual()\Steps\Number + 1
        Gradual()\Item(Str(Item))\Tooltip = Text
      EndIf  

    EndIf
    
  EndProcedure
  
  Procedure   SetState(GNum.i, State.i)
    
    If FindMapElement(Gradual(), Str(GNum))
      
      If State = #Complete : State = Gradual()\Steps\Number + 1 : EndIf
      
      If State >= 0 And State <= Gradual()\Steps\Number + 1
        Gradual()\Steps\Progress = State
      EndIf 
      
      If Gradual()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Define.i Progress, Steps = 3
  
  Enumeration 
    #Window
    #Next
    #Previous
    #Gradual
    #Font
  EndEnumeration
  
  LoadFont(#Font, "Arial", 14, #PB_Font_Bold)
  
  If OpenWindow(#Window, 0, 0, 580, 125, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If Gradual::Gadget(#Gradual, 10, 10, 560, 60, Steps, Gradual::#ToolTips|Gradual::#ChangeCursor|Gradual::#PostEvents) ; , Gradual::#Border|Gradual::#AutoResize|Gradual::#ChangeCursor
      
      Gradual::SetFont(#Gradual, FontID(#Font))
      
      ;Gradual::SetColor(#Gradual, Gradual::#ActiveBackColor, $B48246)
      
      
      Gradual::SetItemText(#Gradual, 1, "Step 1")
      Gradual::SetItemText(#Gradual, 2, "Step 2")
      Gradual::SetItemText(#Gradual, 3, "Step 3")
      Gradual::SetItemText(#Gradual, Gradual::#Complete, "Finished")
      
      Gradual::SetItemTooltip(#Gradual, 1, "This is step 1")
      Gradual::SetItemTooltip(#Gradual, 2, "This is step 2")
      Gradual::SetItemTooltip(#Gradual, 3, "This is step 3")
      Gradual::SetItemTooltip(#Gradual, Gradual::#Complete, "All steps completed")
      
    EndIf
    
    ButtonGadget(#Previous, 10, 90, 80, 25, "Previous")
    ButtonGadget(#Next,    490, 90, 80, 25, "Next")
    
    ;ModuleEx::SetTheme(ModuleEx::#Theme_Blue) 
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case Gradual::#Event_Gadget ;{ Module Events
          Select EventGadget() 
            Case #Gradual
              Select EventType()
                Case #PB_EventType_LeftClick       ;{ Left mouse click
                  Debug "Left Click on step " + Str(EventData())
                  ;}
                Case #PB_EventType_LeftDoubleClick ;{ LeftDoubleClick
                  Debug "Left DoubleClick on step " + Str(EventData())
                  ;}
              EndSelect
          EndSelect ;}
        Case #PB_Event_Gadget       ;{ Gadget Events
          Select EventGadget() 
            Case #Previous  
              Progress - 1
              If Progress < 0 : Progress = 0 : EndIf
              Gradual::SetState(#Gradual, Progress)
            Case #Next
              Progress + 1
              If Progress > Steps + 1 : Progress = Steps + 1 : EndIf
              Gradual::SetState(#Gradual, Progress)
          EndSelect ;}   
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 49
; Folding = 5NAAA9Bjmj4
; EnableXP
; DPIAware