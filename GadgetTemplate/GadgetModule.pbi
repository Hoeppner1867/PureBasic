;/ ============================
;/ =    {Gadget}Module.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ {Gadget} - Gadget
;/
;/ © {Year}  by {Name} ({Month}/{Year})
;/

; TODO: Replace {Gadget} with your gadget name


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


;{ _____ {Gadget} - Commands _____

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule {Gadget}
  
  #Version  = 19112000
  #ModuleEx = 19111702
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	;{ _____ Constants _____
	EnumerationBinary ;{ GadgetFlags
		#AutoResize ; Automatic resizing of the gadget
		#Border     ; Draw a border
		#ToolTips   ; Show tooltips
		#UseExistingCanvas ; e.g. for dialogs
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

  Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetFont(GNum.i, FontID.i) 
  
EndDeclareModule

Module {Gadget}

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================

	#Value$ = "{Value}"

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================

	Structure {Gadget}_Margins_Structure ;{ {Gadget}()\Margin\...
		Top.i
		Left.i
		Right.i
		Bottom.i
	EndStructure ;}

	Structure {Gadget}_Color_Structure   ;{ {Gadget}()\Color\...
		Front.i
		Back.i
		Border.i
	EndStructure  ;}

	Structure {Gadget}_Window_Structure  ;{ {Gadget}()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure {Gadget}_Size_Structure    ;{ {Gadget}()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}


	Structure {Gadget}_Structure         ;{ {Gadget}()\...
		CanvasNum.i
		PopupNum.i

		FontID.i

		ReDraw.i
		Hide.i
		
		Flags.i

		ToolTip.i
		ToolTipText.s

		Color.{Gadget}_Color_Structure
		Margin.{Gadget}_Margins_Structure
		Window.{Gadget}_Window_Structure
		Size.{Gadget}_Size_Structure
		
		Map  PopUpItem.s()

	EndStructure ;}
	Global NewMap {Gadget}.{Gadget}_Structure()

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


	Procedure.s GetPopUpText_(Text.s)
		Define.f Percent
		Define.s Text$ = ""

		If Text
			Text$ = ReplaceString(Text$, #Value$, "") ; <<<
		EndIf

		ProcedureReturn Text$
	EndProcedure

	Procedure   UpdatePopUpMenu_()
		Define.s Text$

		ForEach {Gadget}()\PopUpItem()
			Text$ = GetPopUpText_({Gadget}()\PopUpItem())
			SetMenuItemText({Gadget}()\PopupNum, Val(MapKey({Gadget}()\PopUpItem())), Text$)
		Next

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
		Define.i X, Y, Width, Height
		
		If {Gadget}()\Hide : ProcedureReturn #False : EndIf 
		
		X = dpiX({Gadget}()\Margin\Left)
		Y = dpiY({Gadget}()\Margin\Top)

		Width  = dpiX(GadgetWidth({Gadget}()\CanvasNum))  - dpiX({Gadget}()\Margin\Left) - dpiX({Gadget}()\Margin\Right)
		Height = dpiY(GadgetHeight({Gadget}()\CanvasNum)) - dpiY({Gadget}()\Margin\Top)  - dpiY({Gadget}()\Margin\Bottom)

		If StartDrawing(CanvasOutput({Gadget}()\CanvasNum))

			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			Box(0, 0, dpiX(GadgetWidth({Gadget}()\CanvasNum)), dpiY(GadgetHeight({Gadget}()\CanvasNum)))
			;}

			DrawingFont({Gadget}()\FontID)

			;{ _____ Border ____
			If {Gadget}()\Flags & #Border
				DrawingMode(#PB_2DDrawing_Outlined)
				Box(0, 0, dpiX(GadgetWidth({Gadget}()\CanvasNum)), dpiY(GadgetHeight({Gadget}()\CanvasNum)), {Gadget}()\Color\Border)
			EndIf ;}

			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach {Gadget}()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          {Gadget}()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf

        {Gadget}()\Color\Front  = ModuleEx::ThemeGUI\FrontColor
				{Gadget}()\Color\Back   = ModuleEx::ThemeGUI\BackColor
				{Gadget}()\Color\Border = ModuleEx::ThemeGUI\BorderColor
				
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
	
	
	Procedure _LeftDoubleClickHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement({Gadget}(), Str(GNum))

			X = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseY)

		EndIf

	EndProcedure

	Procedure _RightClickHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement({Gadget}(), Str(GNum))

			X = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseY)


			If X > = {Gadget}()\Size\X And X <= {Gadget}()\Size\X + {Gadget}()\Size\Width
				If Y >= {Gadget}()\Size\Y And Y <= {Gadget}()\Size\Y + {Gadget}()\Size\Height

					If IsWindow({Gadget}()\Window\Num) And IsMenu({Gadget}()\PopUpNum)
						UpdatePopUpMenu_()
						DisplayPopupMenu({Gadget}()\PopUpNum, WindowID({Gadget}()\Window\Num))
					EndIf

				EndIf
			EndIf

		EndIf

	EndProcedure

	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement({Gadget}(), Str(GNum))

			X = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseY)


		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, Y, Angle
		Define.i GNum = EventGadget()

		If FindMapElement({Gadget}(), Str(GNum))

			X = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute({Gadget}()\CanvasNum, #PB_Canvas_MouseY)


		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement({Gadget}(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)



			{Gadget}()\ToolTip = #False
			GadgetToolTip(GNum, "")

			SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure


	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement({Gadget}(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach {Gadget}()

			If IsGadget({Gadget}()\CanvasNum)

				If {Gadget}()\Flags & #AutoResize

					If IsWindow({Gadget}()\Window\Num)

						OffSetX = WindowWidth({Gadget}()\Window\Num)  - {Gadget}()\Window\Width
						OffsetY = WindowHeight({Gadget}()\Window\Num) - {Gadget}()\Window\Height

						If {Gadget}()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If {Gadget}()\Size\Flags & #MoveX  : X = {Gadget}()\Size\X + OffSetX : EndIf
							If {Gadget}()\Size\Flags & #MoveY  : Y = {Gadget}()\Size\Y + OffSetY : EndIf
							If {Gadget}()\Size\Flags & #Width  : Width  = {Gadget}()\Size\Width + OffSetX : EndIf
							If {Gadget}()\Size\Flags & #Height : Height = {Gadget}()\Size\Height + OffSetY : EndIf

							ResizeGadget({Gadget}()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget({Gadget}()\CanvasNum, #PB_Ignore, #PB_Ignore, {Gadget}()\Size\Width + OffSetX, {Gadget}()\Size\Height + OffsetY)
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

		If FindMapElement({Gadget}(), Str(GNum))
			{Gadget}()\PopupNum = PopUpNum
		EndIf

	EndProcedure

	Procedure   DisableReDraw(GNum.i, State.i=#False)

		If FindMapElement({Gadget}(), Str(GNum))

			If State
				{Gadget}()\ReDraw = #False
			Else
				{Gadget}()\ReDraw = #True
				Draw_()
			EndIf

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

			If AddMapElement({Gadget}(), Str(GNum))

				{Gadget}()\CanvasNum = GNum

				CompilerIf Defined(ModuleEx, #PB_Module) ; WindowNum = #Default
					If WindowNum = #PB_Default
						{Gadget}()\Window\Num = ModuleEx::GetGadgetWindow()
					Else
						{Gadget}()\Window\Num = WindowNum
					EndIf
				CompilerElse
					If WindowNum = #PB_Default
						{Gadget}()\Window\Num = GetActiveWindow()
					Else
						{Gadget}()\Window\Num = WindowNum
					EndIf
				CompilerEndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						{Gadget}()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							{Gadget}()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						{Gadget}()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				{Gadget}()\Size\X = X
				{Gadget}()\Size\Y = Y
				{Gadget}()\Size\Width  = Width
				{Gadget}()\Size\Height = Height

				{Gadget}()\Margin\Left   = 10
				{Gadget}()\Margin\Right  = 10
				{Gadget}()\Margin\Top    = 10
				{Gadget}()\Margin\Bottom = 10

				{Gadget}()\Flags  = Flags

				{Gadget}()\ReDraw = #True

				{Gadget}()\Color\Front  = $000000
				{Gadget}()\Color\Back   = $EDEDED
				{Gadget}()\Color\Border = $A0A0A0

				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						{Gadget}()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
						{Gadget}()\Color\Back          = GetSysColor_(#COLOR_MENU)
						{Gadget}()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
					CompilerCase #PB_OS_MacOS
						{Gadget}()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						{Gadget}()\Color\Back          = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						{Gadget}()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent({Gadget}()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent({Gadget}()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
				BindGadgetEvent({Gadget}()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
				BindGadgetEvent({Gadget}()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
				BindGadgetEvent({Gadget}()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
				BindGadgetEvent({Gadget}()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow({Gadget}()\Window\Num)
						{Gadget}()\Window\Width  = WindowWidth({Gadget}()\Window\Num)
						{Gadget}()\Window\Height = WindowHeight({Gadget}()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), {Gadget}()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement({Gadget}(), Str(GNum))
	    
	    If State
	      {Gadget}()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      {Gadget}()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement({Gadget}(), Str(GNum))
      
      {Gadget}()\Size\Flags = Flags
      {Gadget}()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement({Gadget}(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          {Gadget}()\Color\Front  = Value
        Case #BackColor
          {Gadget}()\Color\Back   = Value
        Case #BorderColor
          {Gadget}()\Color\Border = Value
      EndSelect
      
      If {Gadget}()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i) 
    
    If FindMapElement({Gadget}(), Str(GNum))
      
      {Gadget}()\FontID = FontID
      
      If {Gadget}()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #{Gadget}
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 300, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If {Gadget}::Gadget(#{Gadget}, 10, 10, 280, 180, {Gadget}::#Border)
      
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case {Gadget}::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #{Gadget}
              Select EventType()
                Case #PB_EventType_LeftClick       ;{ Left mouse click
                  Debug "Left Click"
                  ;}
                Case #PB_EventType_LeftDoubleClick ;{ LeftDoubleClick
                  Debug "Left DoubleClick"
                  ;}
                Case #PB_EventType_RightClick      ;{ Right mouse click
                  Debug "Right Click"
                  ;}
              EndSelect
          EndSelect ;}
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 48
; FirstLine = 5
; Folding = EEAwGACNh
; EnableXP
; DPIAware