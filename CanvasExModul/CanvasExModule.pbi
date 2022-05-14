;/ ============================
;/ =    CanvasExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Extends the CanvasGadget with new functions:
;/ - ScrollBars
;/
;/ © 2022  by Thorsten Hoeppner (05/2022)
;/


;{ ===== MIT License =====
;
; Copyright (c) 2022 Thorsten Hoeppner
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

;{ _____ CanvasEx - Commands _____

; CanvasEx::Background()       - Clear/draw background
; --------------------------------------------------------------
; CanvasEx::AddEventArea()     - Adds an event area to the CanvasGadget
; --------------------------------------------------------------
; CanvasEx::AutoResize()       - Adds AutoResize to CanvasGadget
; --------------------------------------------------------------
; CanvasEx::ScrollBar()        - Adds ScrollBars to CanvasGadget
; CanvasEx::SetScrollBar()     - Defines Minimum , Maximum and PageLength
; CanvasEx::GetItemAttribute() - Gets Scrollbars attributes [Item: #Horizontal/#Vertical]
; CanvasEx::HideScrollBar()    - Hides ScrollBar(s) [#Horizontal|#Vertical]
; CanvasEx::SetItemAttribute() - Sets Scrollbars attributes [Item: #Horizontal/#Vertical]
; CanvasEx::GetState()         - Gets ScrollBar position [Type: #Horizontal/#Vertical]
; CanvasEx::SetState()         - Sets ScrollBar position [Type: #Horizontal/#Vertical]
; --------------------------------------------------------------
; CanvasEx::GetAttribute()     - Gets Attribute for Canvas or Scrollbars [#Width/#Height or #Size/#Delay]
; CanvasEx::SetAttribute()     - Sets Attribute for both ScrollBars [#Size/#Delay]
;

;}

DeclareModule CanvasEx
  
  #Version  = 22050700
  #ModuleEx = 22050900
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  EnumerationBinary ;{ Canvas Flags
    #Vertical    = #PB_ScrollBar_Vertical
    #Horizontal

    #MoveX
    #MoveY
    #KeepWidth
    #KeepHeight
    
    #Style_RoundThumb
    #Style_Win11
	EndEnumeration ;}
	
	#ResizeCanvas = 0
	#MoveCanvas   = #MoveX|#MoveY|#KeepWidth|#KeepHeight
	
	Enumeration       ;{ Attribute
	  #Canvas     ; = 0
	  ; ---------
	  #Minimum    = #PB_ScrollBar_Minimum    ; = 1
	  #Maximum    = #PB_ScrollBar_Maximum    ; = 2
	  #PageLength = #PB_ScrollBar_PageLength ; = 3
	  ; ---------
	  #Scrollbar
	  ; Canvas
	  #Width
	  #Height
	  ; Scrollbar
	  #Position
	  #Size
	  #Delay
	EndEnumeration ;}
	
	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget = ModuleEx::#Event_Gadget
		#Event_Theme  = ModuleEx::#Event_Theme
		#Event_Timer  = ModuleEx::#Event_Timer
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
		  #Event_Gadget
		  #Event_Timer
		  #Event_CanvasArea
		EndEnumeration

	CompilerEndIf
	
	
	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
	
	Declare   Background(Canvas.i, Color.i=#White)
	
	Declare.i AddEventArea(Canvas.i, Id.i, X.i, Y.i, Width.i, Height.i, Cursor.i=#PB_Cursor_Default, Flags.i=#False, Window.i=#PB_Default)
	
	Declare.i AutoResize(Canvas.i, Flags.i=#False, Window.i=#PB_Default)
	
  Declare.i ScrollBar(Canvas.i, Flags.i=#Horizontal, Window.i=#PB_Default)
  
  Declare   HideScrollBar(Canvas.i, State.i, Flags.i=#Horizontal)
  
  Declare.i GetAttribute(Canvas.i, Attribute.i, Type.i=#Canvas)
  Declare.i GetItemAttribute(Canvas.i, Type.i, Attribute.i)
  Declare.i GetState(Canvas.i, Type.i=#Horizontal) 
  
  Declare   SetAttribute(Canvas.i, Attribute.i, Value.i, Type.i=#Scrollbar)
  Declare   SetItemAttribute(Canvas.i, Type.i, Attribute.i, Value.i)
  Declare   SetScrollBar(Canvas.i, Type.i, Minimum.i, Maximum.i, PageLength.i)
  Declare   SetState(Canvas.i, Value.i, Type.i=#Horizontal) 
  
EndDeclareModule

Module CanvasEx

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#ScrollBarSize   = 16
	
	#AutoScrollTimer = 1867
	#Frequency       = 100  ; 100ms
	#TimerDelay      = 3    ; 100ms * 3
	
	EnumerationBinary ;{ Internal Flags
	  #AutoResize 
	  #EventArea 
	  #MouseEvents
	EndEnumeration ;}
	
	Enumeration 1     ;{ Mouse State
	  #Focus
	  #Click
	  #Hover
	EndEnumeration ;}
	
	Enumeration 1     ;{ Direction
	  #Up
	  #Left
	  #Right
	  #Down
	  #Forwards
	  #Backwards
	EndEnumeration ;}
	
	;- ============================================================================
	;-   Module - Structures & Global
	;- ============================================================================
	
	Structure Area_Structure                ;{
	  X.i
	  Y.i
	  Width.i
	  Height.i
	EndStructure ;}  
	
	Structure Size_Structure                ;{
	  Width.i
	  Height.i
	EndStructure ;}
	
	
	Structure ScrollBar_Thumb_Structure     ;{ CanvasEx()\HScroll\Forwards\Thumb\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollBar_Button_Structure    ;{ CanvasEx()\HScroll\Buttons\...
	  Width.i
	  Height.i
	  ; forward: right & down
	  fX.i
	  fY.i
	  fState.i
	  ; backward: left & up
	  bX.i
	  bY.i
	  bState.i
	EndStructure ;}
	
	Structure ScrollBar_Color_Structure     ;{ CanvasEx()\HScroll\Color\...
	  Front.i
	  Back.i
		Button.i
		Focus.i
		Hover.i
		Arrow.i
	EndStructure ;}

	
	Structure CanvasEx_ScrollBar_Structure  ;{ CanvasEx()\HScroll\...
	  X.i
	  Y.i
	  Width.i
	  Height.i  
	  
	  Pos.i        ; Scrollbar position
	  minPos.i     ; max. Position
	  maxPos.i     ; min. Position
	  Range.i      ; maxPos - minPos
	  Ratio.f      ; PageLength / Maximum
	  Factor.f     ; (ScrollbarArea - ThumbSize) / Range
	  
	  Focus.i      ; Scrollbar Focus
	  CursorPos.i  ; Last Cursor Position
	  Timer.i      ; AutoScroll Timer
	  Delay.i      ; AutoScroll Delay
	  
	  Hide.i       ; Hide Scrollbar
	  Minimum.i    ; min. Value
	  Maximum.i    ; max. Value
	  PageLength.i ; Visible Size
	  
	  Area.Area_Structure                  ; Area between scroll buttons
	  Buttons.ScrollBar_Button_Structure  ; right & down
	  Thumb.ScrollBar_Thumb_Structure      ; thumb position & size
	EndStructure ;}

	Structure CanvasEx_ScrollBars_Structure ;{ CanvasEx()\ScrollBar\...
	  Color.ScrollBar_Color_Structure
	  Size.i       ; Scrollbar width (vertical) / height (horizontal)
	  TimerDelay.i ; Autoscroll Delay
	  Flags.i      ; Flag: #Vertical | #Horizontal
	EndStructure ;}
	
	
	Structure CanvasEx_Event_Structure      ;{ CanvasEx()\Event("Id")\...
	  Id.i
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  OffSetX.i
	  OffSetY.i
	  EventType.i
	  CanvasCursor.i
	  AreaCursor.i
	  Reset.i
	  Flags.i
	EndStructure ;}
	
	
	Structure CanvasEx_Color_Structure      ;{ CanvasEx()\HScroll\Color\...
	  Front.i
	  Back.i
		Gadget.i
	EndStructure  ;}

	Structure CanvasEx_Structure            ;{ CanvasEx()\...
	  Gadget.i
	  Window.i

	  ; ----- CanvasGadget ------ 
	  Color.CanvasEx_Color_Structure
	  Area.Area_Structure ; available area
	  
	  ; ----- Scrollbars -----
	  Scrollbar.CanvasEx_ScrollBars_Structure
	  HScroll.CanvasEx_ScrollBar_Structure
	  VScroll.CanvasEx_ScrollBar_Structure
	  
	  ; ---- AutoResize -----
	  Size.Area_Structure   ; needed for resizing
	  Resize.Size_Structure ; needed for resizing
	  
	  ; ---- AreaEvents -----
	  Map EventArea.CanvasEx_Event_Structure()
	  ; ---------------------
	  Internal.i
	  Flags.i
	EndStructure ;}
	Global NewMap CanvasEx.CanvasEx_Structure()
	
	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================
	
	; ----- MacOS System Colors ------
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
	
	; ----- GetGadgetWindow() ------
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
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
	
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
	
	
	Procedure   CalcScrollBar_()
	  Define.i Width, Height, ScrollbarSize
	  
	  ; current canvas ScrollbarSize
	  Width         = GadgetWidth(CanvasEx()\Gadget)
	  Height        = GadgetHeight(CanvasEx()\Gadget)
	  ScrollbarSize = CanvasEx()\Scrollbar\Size
	  
	  ;{ Calc available canvas area
	  If CanvasEx()\Scrollbar\Flags & #Horizontal And CanvasEx()\Scrollbar\Flags & #Vertical
	    If CanvasEx()\HScroll\Hide
	      CanvasEx()\Area\Width  = Width  - ScrollbarSize - 1
        CanvasEx()\Area\Height = Height
	    ElseIf CanvasEx()\VScroll\Hide
	      CanvasEx()\Area\Width  = Width
        CanvasEx()\Area\Height = Height - ScrollbarSize - 1
	    Else
	      CanvasEx()\Area\Width  = Width  - ScrollbarSize - 1
        CanvasEx()\Area\Height = Height - ScrollbarSize - 1
	    EndIf  
	  ElseIf CanvasEx()\Scrollbar\Flags & #Horizontal
      CanvasEx()\Area\Width  = Width
      CanvasEx()\Area\Height = Height - ScrollbarSize - 1
    ElseIf CanvasEx()\Scrollbar\Flags & #Vertical
      CanvasEx()\Area\Width  = Width - ScrollbarSize - 1
      CanvasEx()\Area\Height = Height
    Else
      CanvasEx()\Area\Width  = Width
      CanvasEx()\Area\Height = Height
    EndIf ;}
    
    ;{ Calc scrollbar size
    If CanvasEx()\Scrollbar\Flags & #Horizontal And CanvasEx()\Scrollbar\Flags & #Vertical
      If CanvasEx()\HScroll\Hide      ;{ only vertical visible
        
        CanvasEx()\VScroll\X        = Width - ScrollbarSize
        CanvasEx()\VScroll\Y        = 0
        CanvasEx()\VScroll\Width    = ScrollbarSize
        CanvasEx()\VScroll\Height   = Height
        ;}
      ElseIf CanvasEx()\VScroll\Hide  ;{ only horizontal visible
        
        CanvasEx()\HScroll\X        = 0
        CanvasEx()\HScroll\Y        = Height - ScrollbarSize
        CanvasEx()\HScroll\Width    = Width
        CanvasEx()\HScroll\Height   = ScrollbarSize
        ;}
      Else                            ;{ both scrollbars visible
        
        CanvasEx()\HScroll\X        = 0
        CanvasEx()\HScroll\Y        = Height - ScrollbarSize
        CanvasEx()\HScroll\Width    = Width  - ScrollbarSize
        CanvasEx()\HScroll\Height   = ScrollbarSize
        
        CanvasEx()\VScroll\X        = Width - ScrollbarSize
        CanvasEx()\VScroll\Y        = 0
        CanvasEx()\VScroll\Width    = ScrollbarSize
        CanvasEx()\VScroll\Height   = Height - ScrollbarSize
        ;}
      EndIf  
    ElseIf CanvasEx()\Scrollbar\Flags & #Horizontal        ;{ only horizontal availible
      
      CanvasEx()\HScroll\X        = 0
      CanvasEx()\HScroll\Y        = Height - ScrollbarSize
      CanvasEx()\HScroll\Width    = Width
      CanvasEx()\HScroll\Height   = ScrollbarSize
      ;}
    ElseIf CanvasEx()\Scrollbar\Flags & #Vertical          ;{ only vertical availible
      
      CanvasEx()\VScroll\X        = Width - ScrollbarSize
      CanvasEx()\VScroll\Y        = 0
      CanvasEx()\VScroll\Width    = ScrollbarSize
      CanvasEx()\VScroll\Height   = Height
      ;}
    EndIf ;} 
    
    ;{ Calc scroll buttons
    If CanvasEx()\Scrollbar\Flags & #Horizontal
      CanvasEx()\HScroll\Buttons\Width  = ScrollbarSize
      CanvasEx()\HScroll\Buttons\Height = ScrollbarSize
      ; forward: right
      CanvasEx()\HScroll\Buttons\fX     = CanvasEx()\HScroll\Width - ScrollbarSize
      CanvasEx()\HScroll\Buttons\fY     = CanvasEx()\HScroll\Y
      ; backward: left
      CanvasEx()\HScroll\Buttons\bX     = 0
      CanvasEx()\HScroll\Buttons\bY     = CanvasEx()\HScroll\Y
    EndIf
    
    If CanvasEx()\Scrollbar\Flags & #Vertical
      CanvasEx()\VScroll\Buttons\Width  = ScrollbarSize
      CanvasEx()\VScroll\Buttons\Height = ScrollbarSize
      ; forward: down
      CanvasEx()\VScroll\Buttons\fX     = CanvasEx()\VScroll\X
      CanvasEx()\VScroll\Buttons\fY     = CanvasEx()\VScroll\Height - ScrollbarSize
      ; backward: up
      CanvasEx()\VScroll\Buttons\bX     = CanvasEx()\VScroll\X
      CanvasEx()\VScroll\Buttons\bY     = 0
    EndIf
    ;}
    
    ;{ Calc scroll area between buttons
    If CanvasEx()\Scrollbar\Flags & #Horizontal
      CanvasEx()\HScroll\Area\X      = ScrollbarSize
  		CanvasEx()\HScroll\Area\Y      = CanvasEx()\HScroll\Y
  		CanvasEx()\HScroll\Area\Width  = CanvasEx()\HScroll\Width - (ScrollbarSize * 2)
  		CanvasEx()\HScroll\Area\Height = ScrollbarSize
    EndIf   
    
    If CanvasEx()\Scrollbar\Flags & #Vertical
      CanvasEx()\VScroll\Area\X      = CanvasEx()\VScroll\X
  		CanvasEx()\VScroll\Area\Y      = ScrollbarSize 
  		CanvasEx()\VScroll\Area\Width  = ScrollbarSize
  		CanvasEx()\VScroll\Area\Height = CanvasEx()\VScroll\Height - (ScrollbarSize * 2)
    EndIf  		
    ;}

    ;{ Calc thumb size
    If CanvasEx()\Scrollbar\Flags & #Horizontal

		  CanvasEx()\HScroll\Thumb\Y      = CanvasEx()\HScroll\Area\Y
		  CanvasEx()\HScroll\Thumb\Width  = Round(CanvasEx()\HScroll\Area\Width * CanvasEx()\HScroll\Ratio, #PB_Round_Nearest)
		  CanvasEx()\HScroll\Thumb\Height = ScrollbarSize
		  CanvasEx()\HScroll\Factor       = (CanvasEx()\HScroll\Area\Width - CanvasEx()\HScroll\Thumb\Width) / CanvasEx()\HScroll\Range
		  
		  If CanvasEx()\Scrollbar\Flags & #Style_Win11
		    CanvasEx()\HScroll\Thumb\Height - 10
		    CanvasEx()\HScroll\Thumb\Y      +  5 
		  Else
		    CanvasEx()\HScroll\Thumb\Height - 4
		    CanvasEx()\HScroll\Thumb\Y      + 2 
		  EndIf
		  
    EndIf
    
    If CanvasEx()\Scrollbar\Flags & #Vertical
      
      CanvasEx()\VScroll\Thumb\X      = CanvasEx()\VScroll\Area\X
		  CanvasEx()\VScroll\Thumb\Width  = ScrollbarSize
		  CanvasEx()\VScroll\Thumb\Height = Round(CanvasEx()\VScroll\Area\Height * CanvasEx()\VScroll\Ratio, #PB_Round_Nearest) 
		  CanvasEx()\VScroll\Factor       = (CanvasEx()\VScroll\Area\Height - CanvasEx()\VScroll\Thumb\Height) /  CanvasEx()\VScroll\Range
		  
		  If CanvasEx()\Scrollbar\Flags & #Style_Win11
		    CanvasEx()\VScroll\Thumb\Width - 10
		    CanvasEx()\VScroll\Thumb\X     +  5 
		  Else
		    CanvasEx()\VScroll\Thumb\Width - 4
		    CanvasEx()\VScroll\Thumb\X     + 2 
		  EndIf
		  
    EndIf  
    ;}
    
	EndProcedure
	
	Procedure   CalcScrollRange_()
	  
		If CanvasEx()\Scrollbar\Flags & #Horizontal
		  
		  If CanvasEx()\HScroll\PageLength
        CanvasEx()\HScroll\Pos    = CanvasEx()\HScroll\Minimum
  		  CanvasEx()\HScroll\minPos = CanvasEx()\HScroll\Minimum
  		  CanvasEx()\HScroll\maxPos = CanvasEx()\HScroll\Maximum - CanvasEx()\HScroll\PageLength + 1
  		  CanvasEx()\HScroll\Ratio  = CanvasEx()\HScroll\PageLength / CanvasEx()\HScroll\Maximum
  		  CanvasEx()\HScroll\Range  = CanvasEx()\HScroll\maxPos - CanvasEx()\HScroll\minPos
  		EndIf 
  		
    EndIf
    
    If CanvasEx()\Scrollbar\Flags & #Vertical
      
      If CanvasEx()\VScroll\PageLength
        CanvasEx()\VScroll\Pos    = CanvasEx()\VScroll\Minimum
  		  CanvasEx()\VScroll\minPos = CanvasEx()\VScroll\Minimum
  		  CanvasEx()\VScroll\maxPos = CanvasEx()\VScroll\Maximum - CanvasEx()\VScroll\PageLength + 1
  		  CanvasEx()\VScroll\Ratio  = CanvasEx()\VScroll\PageLength / CanvasEx()\VScroll\Maximum
  		  CanvasEx()\VScroll\Range  = CanvasEx()\VScroll\maxPos - CanvasEx()\VScroll\minPos
  		EndIf
  		
    EndIf 
    
    CalcScrollBar_()
    
    CanvasEx()\HScroll\Thumb\X = CanvasEx()\HScroll\Area\X
  	CanvasEx()\VScroll\Thumb\Y = CanvasEx()\VScroll\Area\Y
    
	EndProcedure
	
	
	Procedure.i GetThumbPosX_(X.i)   ; Horizontal Scrollbar
	  Define.i Delta, Pos
	  
	  Delta = X - CanvasEx()\HScroll\CursorPos
	  CanvasEx()\HScroll\Thumb\X + Delta 
	  
	  If CanvasEx()\HScroll\Thumb\X < CanvasEx()\HScroll\Area\X
	    CanvasEx()\HScroll\Thumb\X = CanvasEx()\HScroll\Area\X
	  EndIf 
	  
	  If CanvasEx()\HScroll\Thumb\X + CanvasEx()\HScroll\Thumb\Width > CanvasEx()\HScroll\Area\X + CanvasEx()\HScroll\Area\Width
	    CanvasEx()\HScroll\Thumb\X = CanvasEx()\HScroll\Area\X + CanvasEx()\HScroll\Area\Width - CanvasEx()\HScroll\Thumb\Width
	  EndIf

	  Pos = Round((CanvasEx()\HScroll\Thumb\X - CanvasEx()\HScroll\Area\X) * CanvasEx()\HScroll\Factor, #PB_Round_Nearest)
	  
	  If CanvasEx()\HScroll\Pos > CanvasEx()\HScroll\maxPos : CanvasEx()\HScroll\Pos = CanvasEx()\HScroll\maxPos : EndIf
  	If CanvasEx()\HScroll\Pos < CanvasEx()\HScroll\minPos : CanvasEx()\HScroll\Pos = CanvasEx()\HScroll\minPos : EndIf
	  
	  ProcedureReturn Pos
	EndProcedure  
	
	Procedure.i GetThumbPosY_(Y.i)   ; Vertical Scrollbar
	  Define.i Delta, Pos

	  Delta = Y - CanvasEx()\VScroll\CursorPos
	  CanvasEx()\VScroll\Thumb\Y + Delta 
	  
	  If CanvasEx()\VScroll\Thumb\Y < CanvasEx()\VScroll\Area\Y
	    CanvasEx()\VScroll\Thumb\Y =  CanvasEx()\VScroll\Area\Y
	  EndIf 
	  
	  If CanvasEx()\VScroll\Thumb\Y + CanvasEx()\VScroll\Thumb\Height >  CanvasEx()\VScroll\Area\Y + CanvasEx()\VScroll\Area\Height
	    CanvasEx()\VScroll\Thumb\Y =  CanvasEx()\VScroll\Area\Y + CanvasEx()\VScroll\Area\Height - CanvasEx()\VScroll\Thumb\Height
	  EndIf
	  
	  
	  Pos = Round((CanvasEx()\VScroll\Thumb\Y -  CanvasEx()\VScroll\Area\Y) * CanvasEx()\VScroll\Factor, #PB_Round_Nearest)
	  
	  If CanvasEx()\VScroll\Pos > CanvasEx()\VScroll\maxPos : CanvasEx()\VScroll\Pos = CanvasEx()\VScroll\maxPos : EndIf
  	If CanvasEx()\VScroll\Pos < CanvasEx()\VScroll\minPos : CanvasEx()\VScroll\Pos = CanvasEx()\VScroll\minPos : EndIf
	  
	  ProcedureReturn Pos
	EndProcedure  
	
	
	Procedure   SetThumbPosX_(Pos.i) ; Horizontal Scrollbar
	  Define.i  Offset
	  
	  CanvasEx()\HScroll\Pos = Pos

	  If CanvasEx()\HScroll\Pos < CanvasEx()\HScroll\minPos : CanvasEx()\HScroll\Pos = CanvasEx()\HScroll\minPos : EndIf
	  If CanvasEx()\HScroll\Pos > CanvasEx()\HScroll\maxPos : CanvasEx()\HScroll\Pos = CanvasEx()\HScroll\maxPos : EndIf
	  
    Offset = Round((CanvasEx()\HScroll\Pos - CanvasEx()\HScroll\minPos) * CanvasEx()\HScroll\Factor, #PB_Round_Nearest)
    CanvasEx()\HScroll\Thumb\X = CanvasEx()\HScroll\Area\X + Offset

	EndProcedure
	
	Procedure   SetThumbPosY_(Pos.i) ; Vertical Scrollbar
	  Define.i  Offset
	  
	  CanvasEx()\VScroll\Pos = Pos

	  If CanvasEx()\VScroll\Pos < CanvasEx()\VScroll\minPos : CanvasEx()\VScroll\Pos = CanvasEx()\VScroll\minPos : EndIf
	  If CanvasEx()\VScroll\Pos > CanvasEx()\VScroll\maxPos : CanvasEx()\VScroll\Pos = CanvasEx()\VScroll\maxPos : EndIf
	  
    Offset = Round((CanvasEx()\VScroll\Pos - CanvasEx()\VScroll\minPos) * CanvasEx()\VScroll\Factor, #PB_Round_Nearest)
    CanvasEx()\VScroll\Thumb\Y = CanvasEx()\VScroll\Area\Y + Offset

	EndProcedure
	
	
  ;- ============================================================================
	;-   Module - Drawing
	;- ============================================================================	
	
	Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i, Round.i=#False)
	  
	  If Round
	    RoundBox(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), dpiX(Round), dpiY(Round), Color)  
  	Else
  		Box(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), Color)
  	EndIf
  	
  EndProcedure	
  
  
	Procedure   DrawBackground_(Color.i)

	  If StartDrawing(CanvasOutput(CanvasEx()\Gadget))
	    
	    DrawingMode(#PB_2DDrawing_Default)

	    Box_(0, 0, CanvasEx()\Area\Width, CanvasEx()\Area\Height, Color)
	    
	    StopDrawing()
	  EndIf

	EndProcedure
	
	
  Procedure   DrawArrow_(Color.i, Direction.i)
	  Define.i X, Y, Width, Height, aWidth, aHeight, aColor
	  
	  aColor= RGBA(Red(Color), Green(Color), Blue(Color), 255)
	  
	  Select Direction ;{ Position & Size
	    Case #Down
	      X       = CanvasEx()\VScroll\Buttons\fX
	      Y       = CanvasEx()\VScroll\Buttons\fY
	      Width   = CanvasEx()\VScroll\Buttons\Width
	      Height  = CanvasEx()\VScroll\Buttons\Height
	    Case #Up
	      X       = CanvasEx()\VScroll\Buttons\bX
	      Y       = CanvasEx()\VScroll\Buttons\bY
	      Width   = CanvasEx()\VScroll\Buttons\Width
	      Height  = CanvasEx()\VScroll\Buttons\Height
	    Case #Left
	      X       = CanvasEx()\HScroll\Buttons\bX
	      Y       = CanvasEx()\HScroll\Buttons\bY
	      Width   = CanvasEx()\HScroll\Buttons\Width
	      Height  = CanvasEx()\HScroll\Buttons\Height
	    Case #Right
	      X       = CanvasEx()\HScroll\Buttons\fX
	      Y       = CanvasEx()\HScroll\Buttons\fY
	      Width   = CanvasEx()\HScroll\Buttons\Width
	      Height  = CanvasEx()\HScroll\Buttons\Height 
	  EndSelect ;}
	  
	  If CanvasEx()\Scrollbar\Flags & #Style_Win11 ;{ Arrow Size
	    
	    If Direction = #Down Or Direction = #Up 
	      aWidth  = 10
    	  aHeight =  7
	    Else
	      aWidth  =  7
        aHeight = 10  
	    EndIf   
	    
	    If CanvasEx()\HScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If CanvasEx()\HScroll\Buttons\fState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	    If CanvasEx()\VScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If CanvasEx()\VScroll\Buttons\fState= #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	  Else
	    
	    If Direction = #Down Or Direction = #Up
  	    aWidth  = dpiX(8)
  	    aHeight = dpiX(4)
  	  Else
        aWidth  = dpiX(4)
        aHeight = dpiX(8)   
	    EndIf  
      ;}
	  EndIf  
	  
	  X + ((Width  - aWidth) / 2)
    Y + ((Height - aHeight) / 2)
	  
	  If StartVectorDrawing(CanvasVectorOutput(CanvasEx()\Gadget))

      If CanvasEx()\Scrollbar\Flags & #Style_Win11 ;{ solid

        Select Direction
          Case #Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
            ClosePath()
          Case #Down 
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
            ClosePath()
          Case #Left
            MovePathCursor(dpiX(X + aWidth), dpiY(Y))
            AddPathLine(dpiX(X), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
            ClosePath()
          Case #Right
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X), dpiY(Y + aHeight))
            ClosePath()
        EndSelect
        
        VectorSourceColor(aColor)
        FillPath()
        StrokePath(1)
        ;}
      Else                               ;{ /\

        Select Direction
          Case #Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
          Case #Down 
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
          Case #Left
            MovePathCursor(dpiX(X + aWidth), dpiY(Y))
            AddPathLine(dpiX(X), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
          Case #Right
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X), dpiY(Y + aHeight))
        EndSelect
        
        VectorSourceColor(aColor)
        StrokePath(2, #PB_Path_RoundCorner)
        ;}
      EndIf
      
	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
  
	Procedure   DrawButton_(Scrollbar.i, Type.i)
	  Define.i X, Y, Width, Height
	  Define.i ArrowColor, ButtonColor, Direction, State
	  
	  Select Scrollbar ;{ Position, Size, State & Direction
	    Case #Horizontal
	      
        Width  = CanvasEx()\HScroll\Buttons\Width
        Height = CanvasEx()\HScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X      = CanvasEx()\HScroll\Buttons\fX
            Y      = CanvasEx()\HScroll\Buttons\fY
            State  = CanvasEx()\HScroll\Buttons\fState
            Direction = #Right
  	      Case #Backwards
  	        X     = CanvasEx()\HScroll\Buttons\bX
            Y     = CanvasEx()\HScroll\Buttons\bY
            State = CanvasEx()\HScroll\Buttons\bState
            Direction = #Left
  	    EndSelect 
        
      Case #Vertical
        
        Width  = CanvasEx()\VScroll\Buttons\Width
        Height = CanvasEx()\VScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X     = CanvasEx()\VScroll\Buttons\fX
            Y     = CanvasEx()\VScroll\Buttons\fY
            State = CanvasEx()\VScroll\Buttons\fState
            Direction = #Down
  	      Case #Backwards
  	        X     = CanvasEx()\VScroll\Buttons\bX
            Y     = CanvasEx()\VScroll\Buttons\bY
            State = CanvasEx()\VScroll\Buttons\bState
            Direction = #Up
        EndSelect
        ;}
    EndSelect    
    
    ;{ ----- Colors -----
    If CanvasEx()\Scrollbar\Flags & #Style_Win11
      
      ButtonColor = CanvasEx()\Scrollbar\Color\Back
      
      Select State
	      Case #Focus
	        ArrowColor = CanvasEx()\Scrollbar\Color\Focus
	      Case #Hover
	        ArrowColor = CanvasEx()\Scrollbar\Color\Hover
	      Case #Click  
	        ArrowColor = CanvasEx()\Scrollbar\Color\Arrow
	      Default
	        ArrowColor = #PB_Default
	    EndSelect    

    Else
      
      Select State
	      Case #Hover
	        ButtonColor  = BlendColor_(CanvasEx()\Scrollbar\Color\Focus, CanvasEx()\Scrollbar\Color\Button, 10)
	      Case #Click
	        ButtonColor  = BlendColor_(CanvasEx()\Scrollbar\Color\Focus, CanvasEx()\Scrollbar\Color\Button, 20)
	      Default
	        ButtonColor  = CanvasEx()\Scrollbar\Color\Button
	    EndSelect  
	    
	    ArrowColor = CanvasEx()\Scrollbar\Color\Arrow
	    
	  EndIf 
	  ;}
    
	  ;{ ----- Draw button -----
	  If StartDrawing(CanvasOutput(CanvasEx()\Gadget))
	    
	    DrawingMode(#PB_2DDrawing_Default)

	    Box_(X, Y, Width, Height, ButtonColor)
	    
	    StopDrawing()
	  EndIf ;}
	  
	  ;{ ----- Draw Arrows -----
	  If ArrowColor <> #PB_Default
	    DrawArrow_(ArrowColor, Direction)
	  EndIf ;} 

	EndProcedure
	
	Procedure   DrawThumb_(Scrollbar.i)
	  Define.i BackColor, ThumbColor, ThumbState, Round
	  Define.i OffsetPos, OffsetSize
	  
	  ;{ ----- Thumb cursor state -----
	  Select Scrollbar 
	    Case #Horizontal
	      ThumbState = CanvasEx()\HScroll\Thumb\State
  	  Case #Vertical
  	    ThumbState = CanvasEx()\VScroll\Thumb\State
  	EndSelect ;}    
  	
  	;{ ----- Colors -----
	  If CanvasEx()\Scrollbar\Flags & #Style_Win11 
	    
	    BackColor = CanvasEx()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = CanvasEx()\Scrollbar\Color\Focus
	      Case #Hover
	        ThumbColor = CanvasEx()\Scrollbar\Color\Hover
	      Case #Click
	        ThumbColor = CanvasEx()\Scrollbar\Color\Hover
	      Default
	        ThumbColor = CanvasEx()\Scrollbar\Color\Focus
	    EndSelect 
	    
	    If ThumbState ;{ Thumb size
	      Round = 4
	    Else
	      OffsetPos  =  2
	      OffsetSize = -4
	      Round = 0
  	    ;}
	    EndIf

	  Else
	    
	    BackColor = CanvasEx()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = BlendColor_(CanvasEx()\Scrollbar\Color\Focus, CanvasEx()\Scrollbar\Color\Front, 10)
	      Case #Hover
	        ThumbColor = BlendColor_(CanvasEx()\Scrollbar\Color\Focus, CanvasEx()\Scrollbar\Color\Hover, 10)
	      Case #Click
	        ThumbColor = BlendColor_(CanvasEx()\Scrollbar\Color\Focus, CanvasEx()\Scrollbar\Color\Front, 20)
	      Default
	        ThumbColor = CanvasEx()\Scrollbar\Color\Front
	    EndSelect 
	    
	    If CanvasEx()\Scrollbar\Flags & #Style_RoundThumb
	      Round = 4
	    Else
	      Round = #False
	    EndIf
	    
	  EndIf ;}  
	  
	  If StartDrawing(CanvasOutput(CanvasEx()\Gadget))
	    
	    DrawingMode(#PB_2DDrawing_Default)

	    Select Scrollbar 
  	    Case #Horizontal
  	      
  	      Box_(CanvasEx()\HScroll\Area\X, CanvasEx()\HScroll\Area\Y, CanvasEx()\HScroll\Area\Width, CanvasEx()\HScroll\Area\Height, BackColor)
  	      
      	  Box_(CanvasEx()\HScroll\Thumb\X, CanvasEx()\HScroll\Thumb\Y + OffsetPos, CanvasEx()\HScroll\Thumb\Width, CanvasEx()\HScroll\Thumb\Height + OffsetSize, ThumbColor, Round)
      	  
      	Case #Vertical

      	  Box_(CanvasEx()\VScroll\Area\X, CanvasEx()\VScroll\Area\Y, CanvasEx()\VScroll\Area\Width, CanvasEx()\VScroll\Area\Height, BackColor)

      	  Box_(CanvasEx()\VScroll\Thumb\X + OffsetPos, CanvasEx()\VScroll\Thumb\Y, CanvasEx()\VScroll\Thumb\Width + OffsetSize, CanvasEx()\VScroll\Thumb\Height, ThumbColor, Round)

  	  EndSelect

  	  StopDrawing()
	  EndIf  
  	
	EndProcedure  
	
	Procedure   DrawScrollBar_(Hide.i=#False)
		Define.i OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		CalcScrollBar_()

  	;{ ----- thumb position -----
		If CanvasEx()\Scrollbar\Flags & #Horizontal
		  OffsetX = Round((CanvasEx()\HScroll\Pos - CanvasEx()\HScroll\minPos) * CanvasEx()\HScroll\Factor, #PB_Round_Nearest)
		  CanvasEx()\HScroll\Thumb\X = CanvasEx()\HScroll\Area\X + OffsetX
  	EndIf
		
		If CanvasEx()\Scrollbar\Flags & #Vertical
		  OffsetY = Round((CanvasEx()\VScroll\Pos - CanvasEx()\VScroll\minPos) * CanvasEx()\VScroll\Factor, #PB_Round_Nearest)
		  CanvasEx()\VScroll\Thumb\Y = CanvasEx()\VScroll\Area\Y + OffsetY
		EndIf ;}
		
		If StartDrawing(CanvasOutput(CanvasEx()\Gadget)) ; Draw scrollbar background
      
		  DrawingMode(#PB_2DDrawing_Default)
		  
		  If CanvasEx()\Scrollbar\Flags & #Horizontal
		    
		    If CanvasEx()\HScroll\Hide
		      Box_(0, CanvasEx()\HScroll\Y, GadgetWidth(CanvasEx()\Gadget), CanvasEx()\HScroll\Height, CanvasEx()\Color\Back)
		    Else  
		      Box_(0, CanvasEx()\HScroll\Y, GadgetWidth(CanvasEx()\Gadget), CanvasEx()\HScroll\Height, CanvasEx()\Color\Gadget)
		    EndIf
		    
		  EndIf   
		  
		  If CanvasEx()\Scrollbar\Flags & #Vertical

		    If CanvasEx()\VScroll\Hide
		      Box_(CanvasEx()\VScroll\X, 0, CanvasEx()\VScroll\Width, GadgetHeight(CanvasEx()\Gadget), CanvasEx()\Color\Back)
		    Else
		      Box_(CanvasEx()\VScroll\X, 0, CanvasEx()\VScroll\Width, GadgetHeight(CanvasEx()\Gadget), CanvasEx()\Color\Gadget)
		    EndIf
		    
		  EndIf  
		  
		  StopDrawing()
		EndIf
		
		If CanvasEx()\Scrollbar\Flags & #Horizontal And CanvasEx()\HScroll\Hide = #False
		  DrawButton_(#Horizontal, #Forwards)
		  DrawButton_(#Horizontal, #Backwards)
		  DrawThumb_(#Horizontal)
		EndIf
		
		If CanvasEx()\Scrollbar\Flags & #Vertical And CanvasEx()\VScroll\Hide = #False
		  DrawButton_(#Vertical, #Forwards)
		  DrawButton_(#Vertical, #Backwards)
		  DrawThumb_(#Vertical)
		EndIf  

	EndProcedure
	

	;- ============================================================================
	;-   Module - Events
	;- ============================================================================	
	
	Procedure _AutoScroll()
    Define.i X, Y

    ForEach CanvasEx()

      If CanvasEx()\HScroll\Timer ;{ Horizontal Scrollbar
        
        If CanvasEx()\HScroll\Delay
          CanvasEx()\HScroll\Delay - 1
          Continue
        EndIf  
        
        Select CanvasEx()\HScroll\Timer
          Case #Left
            SetThumbPosX_(CanvasEx()\HScroll\Pos - 1)
          Case #Right
            SetThumbPosX_(CanvasEx()\HScroll\Pos + 1)
        EndSelect
        
        DrawThumb_(#Horizontal)
        
  			PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Horizontal)
  			;}
      EndIf   
      
      If CanvasEx()\VScroll\Timer ;{ Vertical Scrollbar
        
        If CanvasEx()\VScroll\Delay
          CanvasEx()\VScroll\Delay - 1
          Continue
        EndIf  
        
        Select CanvasEx()\VScroll\Timer
          Case #Up
            SetThumbPosY_(CanvasEx()\VScroll\Pos - 1)
          Case #Down
            SetThumbPosY_(CanvasEx()\VScroll\Pos + 1)
  			EndSelect
  			
  			DrawThumb_(#Vertical)
  			
  			PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Vertical)
  			;}
      EndIf   
      
    Next
    
  EndProcedure
  
	
	Procedure _LeftButtonDownHandler()
	  Define.i GNum = EventGadget()
		Define.i X, Y

		If FindMapElement(CanvasEx(), Str(GNum))

			X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX)) ; DPI?
			Y = DesktopUnscaledY(GetGadgetAttribute(GNum, #PB_Canvas_MouseY)) ; DPI?

			If CanvasEx()\Flags & #Horizontal ;{ Horizontal Scrollbar
			  
			  CanvasEx()\HScroll\CursorPos = #PB_Default
			  
			  If CanvasEx()\HScroll\Focus
			    
  			  If X > CanvasEx()\HScroll\Buttons\bX And  X < CanvasEx()\HScroll\Buttons\bX + CanvasEx()\HScroll\Buttons\Width
  			    
  			    ; --- Backwards Button ---
  			    If CanvasEx()\HScroll\Buttons\bState <> #Click
  			      CanvasEx()\HScroll\Delay = CanvasEx()\Scrollbar\TimerDelay
  			      CanvasEx()\HScroll\Timer = #Left
  			      CanvasEx()\HScroll\Buttons\bState = #Click
  			      DrawButton_(#Horizontal, #Backwards)
  			    EndIf
  			    
  			  ElseIf X > CanvasEx()\HScroll\Buttons\fX And  X < CanvasEx()\HScroll\Buttons\fX + CanvasEx()\HScroll\Buttons\Width
  			    
  			    ; --- Forwards Button ---
  			    If CanvasEx()\HScroll\Buttons\fState <> #Click
  			      CanvasEx()\HScroll\Delay = CanvasEx()\Scrollbar\TimerDelay
  			      CanvasEx()\HScroll\Timer = #Right
  			      CanvasEx()\HScroll\Buttons\fState = #Click
  			      DrawButton_(#Horizontal, #Forwards)
  			    EndIf
  			    
  			  ElseIf  X > CanvasEx()\HScroll\Thumb\X And X < CanvasEx()\HScroll\Thumb\X + CanvasEx()\HScroll\Thumb\Width
  			    
  			    ; --- Thumb Button ---
  			    If CanvasEx()\HScroll\Thumb\State <> #Click
  			      CanvasEx()\HScroll\Thumb\State = #Click
  			      CanvasEx()\HScroll\CursorPos = X
  			      DrawThumb_(#Horizontal)
  			    EndIf
			    
  			  EndIf
  			  
  			EndIf
  			;}
			EndIf 
			
			If CanvasEx()\Flags & #Vertical   ;{ Horizontal Scrollbar
			  
			  CanvasEx()\VScroll\CursorPos = #PB_Default
			  
			  If CanvasEx()\VScroll\Focus
			    
			    If Y > CanvasEx()\VScroll\Buttons\bY And Y < CanvasEx()\VScroll\Buttons\bY + CanvasEx()\VScroll\Buttons\Height

			      If CanvasEx()\VScroll\Buttons\bState <> #Click
			        ; --- Backwards Button ---
  			      CanvasEx()\VScroll\Delay = CanvasEx()\Scrollbar\TimerDelay
  			      CanvasEx()\VScroll\Timer = #Up
  			      CanvasEx()\VScroll\Buttons\bState = #Click
  			      DrawButton_(#Vertical, #Backwards)
  			    EndIf
  			    
			    ElseIf Y > CanvasEx()\VScroll\Buttons\fY And Y < CanvasEx()\VScroll\Buttons\fY + CanvasEx()\VScroll\Buttons\Height
			      
			      ; --- Forwards Button ---
  			    If CanvasEx()\VScroll\Buttons\fState <> #Click
  			      CanvasEx()\VScroll\Delay = CanvasEx()\Scrollbar\TimerDelay
  			      CanvasEx()\VScroll\Timer = #Down
  			      CanvasEx()\VScroll\Buttons\fState = #Click
  			      DrawButton_(#Vertical, #Forwards)
  			    EndIf
			      
			    ElseIf  Y > CanvasEx()\VScroll\Thumb\Y And Y < CanvasEx()\VScroll\Thumb\Y + CanvasEx()\VScroll\Thumb\Height
			      
			      ; --- Thumb Button ---
  			    If CanvasEx()\VScroll\Thumb\State <> #Click
  			      CanvasEx()\VScroll\Thumb\State = #Click
  			      CanvasEx()\VScroll\CursorPos = Y
  			      DrawThumb_(#Vertical)
  			    EndIf
			      
			    EndIf  

			  EndIf
			  ;}
			EndIf
			
			If CanvasEx()\Internal & #EventArea         ;{ Event Area
			  
			  ForEach CanvasEx()\EventArea()
			    
			    If X > CanvasEx()\EventArea()\X And X < CanvasEx()\EventArea()\X + CanvasEx()\EventArea()\Width
			      If Y > CanvasEx()\EventArea()\Y And Y < CanvasEx()\EventArea()\Y + CanvasEx()\EventArea()\Height

			        If CanvasEx()\EventArea()\EventType <> #PB_EventType_LeftButtonDown
			          CanvasEx()\EventArea()\EventType = #PB_EventType_LeftButtonDown
    			      PostEvent(#Event_CanvasArea, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_LeftButtonDown, CanvasEx()\EventArea()\Id)
			        EndIf  
			        
			        ProcedureReturn #True
			      EndIf 
			    EndIf

			  Next
			  ;}
			EndIf
			
		EndIf

	EndProcedure
	
	Procedure _LeftButtonUpHandler()
	  Define.i GNum = EventGadget()
		Define.i X, Y

		If FindMapElement(CanvasEx(), Str(GNum))

			X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX)) ; DPI?
			Y = DesktopUnscaledY(GetGadgetAttribute(GNum, #PB_Canvas_MouseY)) ; DPI?

			If CanvasEx()\Flags & #Horizontal   ;{ Horizontal Scrollbar
			  
			  CanvasEx()\HScroll\CursorPos = #PB_Default
			  CanvasEx()\HScroll\Timer     = #False
			  
			  If CanvasEx()\HScroll\Focus
			    
  			  If X > CanvasEx()\HScroll\Buttons\bX And  X < CanvasEx()\HScroll\Buttons\bX + CanvasEx()\HScroll\Buttons\Width
  			    
  			    ; --- Backwards Button ---
  			    SetThumbPosX_(CanvasEx()\HScroll\Pos - 1)
  			   
  			    DrawThumb_(#Horizontal)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Horizontal)
  			    
  			  ElseIf X > CanvasEx()\HScroll\Buttons\fX And  X < CanvasEx()\HScroll\Buttons\fX + CanvasEx()\HScroll\Buttons\Width
  			    
  			    ; --- Forwards Button ---
  			    SetThumbPosX_(CanvasEx()\HScroll\Pos + 1)
  			    
  			    DrawThumb_(#Horizontal)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Horizontal)
  			    
  			  ElseIf X > CanvasEx()\HScroll\Area\X And X < CanvasEx()\HScroll\Thumb\X
  			    
  			    ; --- Page left ---
  			    SetThumbPosX_(CanvasEx()\HScroll\Pos - CanvasEx()\HScroll\PageLength)
  			    
  			    DrawThumb_(#Horizontal)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Horizontal)
  			    
  			  ElseIf X > CanvasEx()\HScroll\Thumb\X + CanvasEx()\HScroll\Thumb\Width And X < CanvasEx()\HScroll\Area\X + CanvasEx()\HScroll\Area\Width
  			    
  			    ; --- Page right ---
  			    SetThumbPosX_(CanvasEx()\HScroll\Pos + CanvasEx()\HScroll\PageLength)
  			 
  			    DrawThumb_(#Horizontal)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Horizontal)
  			    
  			  EndIf
    			
  			EndIf 
			  ;}
			EndIf   
		
      If CanvasEx()\Flags & #Vertical     ;{ Vertical Scrollbar
			  
			  CanvasEx()\VScroll\CursorPos = #PB_Default
			  CanvasEx()\VScroll\Timer     = #False
			  
			  If CanvasEx()\VScroll\Focus
			    
  			  If Y > CanvasEx()\VScroll\Buttons\bY And  Y < CanvasEx()\VScroll\Buttons\bY + CanvasEx()\VScroll\Buttons\Height
  			    
  			    ; --- Backwards Button ---
  			    SetThumbPosY_(CanvasEx()\VScroll\Pos - 1)

  			    DrawThumb_(#Vertical)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Vertical)
  			    
  			  ElseIf Y > CanvasEx()\VScroll\Buttons\fY And  Y < CanvasEx()\VScroll\Buttons\fY + CanvasEx()\VScroll\Buttons\Height
  			    
  			    ; --- Forwards Button ---
  			    SetThumbPosY_(CanvasEx()\VScroll\Pos + 1)
  			    
  			    DrawThumb_(#Vertical)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Vertical)
  			    
  			  ElseIf Y > CanvasEx()\VScroll\Area\Y And Y < CanvasEx()\VScroll\Thumb\Y
  			    
  			    ; --- Page up ---
  			    SetThumbPosY_(CanvasEx()\VScroll\Pos - CanvasEx()\VScroll\PageLength)

  			    DrawThumb_(#Vertical)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Vertical)
  			    
  			  ElseIf Y > CanvasEx()\VScroll\Thumb\Y + CanvasEx()\VScroll\Thumb\Height And Y < CanvasEx()\VScroll\Area\Y + CanvasEx()\VScroll\Area\Height
  			    
  			    ; --- Page down ---
  			    SetThumbPosY_(CanvasEx()\VScroll\Pos + CanvasEx()\VScroll\PageLength)

  			    DrawThumb_(#Vertical)
  			    
  			    PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Vertical)
  			    
  			  EndIf
    			
  			EndIf 
			  ;}
			EndIf
			
			If CanvasEx()\Internal & #EventArea ;{ Event Area
			  
			  ForEach CanvasEx()\EventArea()
			    
			    If X > CanvasEx()\EventArea()\X And X < CanvasEx()\EventArea()\X + CanvasEx()\EventArea()\Width
			      If Y > CanvasEx()\EventArea()\Y And Y < CanvasEx()\EventArea()\Y + CanvasEx()\EventArea()\Height

			        If CanvasEx()\EventArea()\EventType <> #PB_EventType_LeftButtonUp
			          CanvasEx()\EventArea()\EventType = #PB_EventType_LeftButtonUp
    			      PostEvent(#Event_CanvasArea, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_LeftButtonUp, CanvasEx()\EventArea()\Id)
			        EndIf  
			        
			        ProcedureReturn #True
			      EndIf 
			    EndIf

			  Next
			  ;}
			EndIf
			
		EndIf

	EndProcedure
		
	Procedure _MouseLeaveHandler()
	  Define.i GNum = EventGadget()
	  
	  If FindMapElement(CanvasEx(), Str(GNum))
	    
	    If CanvasEx()\Scrollbar\Flags & #Horizontal ;{ Horizontal Scrollbar
	      
	      CanvasEx()\HScroll\Buttons\bState = #False
        CanvasEx()\HScroll\Buttons\fState = #False
        CanvasEx()\HScroll\Thumb\State    = #False
	      ;}
	    EndIf
	    
	    If CanvasEx()\Scrollbar\Flags & #Vertical   ;{ Vertikal Scrollbar
	      
        CanvasEx()\VScroll\Buttons\bState = #False
        CanvasEx()\VScroll\Buttons\fState = #False
        CanvasEx()\VScroll\Thumb\State    = #False
	      ;}
      EndIf
      
      If CanvasEx()\Internal & #EventArea         ;{ Event Area
			  
			  ForEach CanvasEx()\EventArea()

			    If CanvasEx()\EventArea()\EventType And CanvasEx()\EventArea()\EventType <> #PB_EventType_MouseLeave
			      CanvasEx()\EventArea()\EventType = #PB_EventType_MouseLeave
			      PostEvent(#Event_CanvasArea, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_MouseLeave, CanvasEx()\EventArea()\Id)
			    EndIf
			    
			  Next
			  ;}
			EndIf
      
      DrawScrollBar_() 
      
	  EndIf
	  
	EndProcedure
	
	Procedure _MouseMoveHandler()
		Define.i X, Y, Backwards, Forwards, CursorPos, Thumb, Offset, Delta
		Define.i GNum = EventGadget()

		If FindMapElement(CanvasEx(), Str(GNum))

			X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX)) ; DPI?
			Y = DesktopUnscaledY(GetGadgetAttribute(GNum, #PB_Canvas_MouseY)) ; DPI?

			If CanvasEx()\Scrollbar\Flags & #Horizontal ;{ Horizontal Scrollbar
			  
			  CanvasEx()\HScroll\Focus = #False
			  
			  Backwards = CanvasEx()\HScroll\Buttons\bState
			  Forwards  = CanvasEx()\HScroll\Buttons\fState
			  Thumb     = CanvasEx()\HScroll\Thumb\State
			  
			  If Y > CanvasEx()\HScroll\Y And Y < CanvasEx()\HScroll\Y + CanvasEx()\HScroll\Height
			    If X > CanvasEx()\HScroll\X And X < CanvasEx()\HScroll\X + CanvasEx()\HScroll\Width
			      
			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
			      
			      ; --- Focus Scrollbar ---  
			      CanvasEx()\HScroll\Buttons\bState = #Focus
			      CanvasEx()\HScroll\Buttons\fState = #Focus
			      CanvasEx()\HScroll\Thumb\State    = #Focus
			      
			      ; --- Hover Buttons & Thumb ---
			      If X > CanvasEx()\HScroll\Buttons\bX And  X < CanvasEx()\HScroll\Buttons\bX + CanvasEx()\HScroll\Buttons\Width
			        
			        CanvasEx()\HScroll\Buttons\bState = #Hover
			        
			      ElseIf X > CanvasEx()\HScroll\Buttons\fX And  X < CanvasEx()\HScroll\Buttons\fX + CanvasEx()\HScroll\Buttons\Width
			        
			        CanvasEx()\HScroll\Buttons\fState = #Hover
			        
			      ElseIf X > CanvasEx()\HScroll\Thumb\X And X < CanvasEx()\HScroll\Thumb\X + CanvasEx()\HScroll\Thumb\Width
			        
			        CanvasEx()\HScroll\Thumb\State = #Hover
			        
			        ;{ --- Move thumb with cursor 
			        If CanvasEx()\HScroll\CursorPos <> #PB_Default
			          
			          CursorPos = CanvasEx()\HScroll\Pos
			          
  			        CanvasEx()\HScroll\Pos = GetThumbPosX_(X)
  			        CanvasEx()\HScroll\CursorPos = X
  			        
  			        If CursorPos <> CanvasEx()\HScroll\Pos
  			          
  			          DrawThumb_(#Horizontal)
  			          
  			          PostEvent(#Event_Gadget,    CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Horizontal)
  			          
  			        EndIf  
  			        
  			      EndIf ;}
			        
  			    EndIf
  			    
			      CanvasEx()\HScroll\Focus = #True
    			EndIf
    		EndIf
    		
    		If Not CanvasEx()\HScroll\Focus
    		  
	        CanvasEx()\HScroll\Buttons\bState = #False
	        CanvasEx()\HScroll\Buttons\fState = #False
	        CanvasEx()\HScroll\Thumb\State    = #False
	        
	        CanvasEx()\HScroll\Timer = #False
	      EndIf
    		
    		If Backwards <> CanvasEx()\HScroll\Buttons\bState : DrawButton_(#Horizontal, #Backwards) : EndIf 
		    If Forwards  <> CanvasEx()\HScroll\Buttons\fState : DrawButton_(#Horizontal, #Forwards)  : EndIf 
		    If Thumb     <> CanvasEx()\HScroll\Thumb\State    : DrawThumb_(#Horizontal)              : EndIf 
    	
    		If CanvasEx()\HScroll\Focus : ProcedureReturn #True : EndIf
			  ;}
			EndIf   
		
			If CanvasEx()\Scrollbar\Flags & #Vertical   ;{ Vertikal Scrollbar
			  
			  CanvasEx()\VScroll\Focus = #False
			  
			  Backwards = CanvasEx()\VScroll\Buttons\bState
			  Forwards  = CanvasEx()\VScroll\Buttons\fState
			  Thumb     = CanvasEx()\VScroll\Thumb\State
			  
			  If X > CanvasEx()\VScroll\X And X < CanvasEx()\VScroll\X + CanvasEx()\VScroll\Width
			    If Y > CanvasEx()\VScroll\Y And Y < CanvasEx()\VScroll\Y + CanvasEx()\VScroll\Height
			     
			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
			      
			      ; --- Focus Scrollbar ---  
			      CanvasEx()\VScroll\Buttons\bState = #Focus
			      CanvasEx()\VScroll\Buttons\fState = #Focus
			      CanvasEx()\VScroll\Thumb\State    = #Focus
			      
			      ; --- Hover Buttons & Thumb ---
			      If Y > CanvasEx()\VScroll\Buttons\bY And Y < CanvasEx()\VScroll\Buttons\bY + CanvasEx()\VScroll\Buttons\Height
			        
			        CanvasEx()\VScroll\Buttons\bState = #Hover
			        
			      ElseIf Y > CanvasEx()\VScroll\Buttons\fY And Y < CanvasEx()\VScroll\Buttons\fY + CanvasEx()\VScroll\Buttons\Height
			        
			        CanvasEx()\VScroll\Buttons\fState = #Hover

			      ElseIf Y > CanvasEx()\VScroll\Thumb\Y And Y < CanvasEx()\VScroll\Thumb\Y + CanvasEx()\VScroll\Thumb\Height
			        
			        CanvasEx()\VScroll\Thumb\State = #Hover
			        
			        ;{ --- Move thumb with cursor 
			        If CanvasEx()\VScroll\CursorPos <> #PB_Default
			          
			          CursorPos = CanvasEx()\VScroll\Pos
			          
  			        CanvasEx()\VScroll\Pos       = GetThumbPosY_(Y)
  			        CanvasEx()\VScroll\CursorPos = Y
  			        
  			        If CursorPos <> CanvasEx()\VScroll\Pos
  			          
  			          DrawThumb_(#Vertical)
  			          
  			          PostEvent(#Event_Gadget, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_Change, #Horizontal)
  			          
  			        EndIf
  			        
  			      EndIf ;}

  			    EndIf   
  			    
            CanvasEx()\VScroll\Focus = #True
    			EndIf
    		EndIf
    		
    		If Not CanvasEx()\VScroll\Focus

          CanvasEx()\VScroll\Buttons\bState = #False
          CanvasEx()\VScroll\Buttons\fState = #False
          CanvasEx()\VScroll\Thumb\State    = #False
          
          CanvasEx()\VScroll\Timer = #False
          
        EndIf   
        
        If Backwards <> CanvasEx()\VScroll\Buttons\bState : DrawButton_(#Vertical, #Backwards) : EndIf 
        If Forwards  <> CanvasEx()\VScroll\Buttons\fState : DrawButton_(#Vertical, #Forwards)  : EndIf 
        If Thumb     <> CanvasEx()\VScroll\Thumb\State    : DrawThumb_(#Vertical)              : EndIf 
        
        If CanvasEx()\VScroll\Focus : ProcedureReturn #True : EndIf
			  ;}
			EndIf 
			
			If CanvasEx()\Internal & #EventArea         ;{ Event Area
			  
			  ForEach CanvasEx()\EventArea()
			    
			    If X > CanvasEx()\EventArea()\X And X < CanvasEx()\EventArea()\X + CanvasEx()\EventArea()\Width
			      If Y > CanvasEx()\EventArea()\Y And Y < CanvasEx()\EventArea()\Y + CanvasEx()\EventArea()\Height

			        If CanvasEx()\EventArea()\EventType = #False Or CanvasEx()\EventArea()\EventType = #PB_EventType_MouseLeave
			          
			          CanvasEx()\EventArea()\EventType = #PB_EventType_MouseEnter
			          
			          CanvasEx()\EventArea()\CanvasCursor = GetGadgetAttribute(CanvasEx()\Gadget, #PB_Canvas_Cursor) 
			          SetGadgetAttribute(CanvasEx()\Gadget, #PB_Canvas_Cursor, CanvasEx()\EventArea()\AreaCursor)
			          
			          PostEvent(#Event_CanvasArea, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_MouseEnter, CanvasEx()\EventArea()\Id)
			        EndIf  

			        ProcedureReturn #True
			      EndIf 
			    EndIf
			    
			    If CanvasEx()\EventArea()\EventType And CanvasEx()\EventArea()\EventType <> #PB_EventType_MouseLeave
			      
			      CanvasEx()\EventArea()\EventType = #PB_EventType_MouseLeave
			      
			      SetGadgetAttribute(CanvasEx()\Gadget, #PB_Canvas_Cursor, CanvasEx()\EventArea()\CanvasCursor)
			      
			      PostEvent(#Event_CanvasArea, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_MouseLeave, CanvasEx()\EventArea()\Id)
			    EndIf
			    
			  Next
			  ;}
			EndIf
			
		EndIf

	EndProcedure
	
	Procedure _RightClickHandler()
	  Define.i GNum = EventGadget()
		Define.i X, Y

		If FindMapElement(CanvasEx(), Str(GNum))

			X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX)) ; DPI?
			Y = DesktopUnscaledY(GetGadgetAttribute(GNum, #PB_Canvas_MouseY)) ; DPI?
			
			If CanvasEx()\Internal & #EventArea ;{ Event Area
			  
			  ForEach CanvasEx()\EventArea()
			    
			    If X > CanvasEx()\EventArea()\X And X < CanvasEx()\EventArea()\X + CanvasEx()\EventArea()\Width
			      If Y > CanvasEx()\EventArea()\Y And Y < CanvasEx()\EventArea()\Y + CanvasEx()\EventArea()\Height

			        If CanvasEx()\EventArea()\EventType <> #PB_EventType_RightClick
			          CanvasEx()\EventArea()\EventType = #PB_EventType_RightClick
    			      PostEvent(#Event_CanvasArea, CanvasEx()\Window, CanvasEx()\Gadget, #PB_EventType_RightClick, CanvasEx()\EventArea()\Id)
			        EndIf  
			        
			        ProcedureReturn #True
			      EndIf 
			    EndIf

			  Next
			  ;}
			EndIf
			
		EndIf
		
	EndProcedure  
	
	Procedure _MouseWheelHandler()
    Define.i GNum = EventGadget()
    Define.i Delta, Offset

    If FindMapElement(CanvasEx(), Str(GNum))
      
      Delta = GetGadgetAttribute(GNum, #PB_Canvas_WheelDelta)
      
      If CanvasEx()\Scrollbar\Flags & #Horizontal ;{ Horizontal Scrollbar
        
        If CanvasEx()\HScroll\Focus And CanvasEx()\HScroll\Hide = #False
          
          CanvasEx()\HScroll\Pos - Delta
          
          If CanvasEx()\HScroll\Pos > CanvasEx()\HScroll\maxPos : CanvasEx()\HScroll\Pos = CanvasEx()\HScroll\maxPos : EndIf
          If CanvasEx()\HScroll\Pos < CanvasEx()\HScroll\minPos : CanvasEx()\HScroll\Pos = CanvasEx()\HScroll\minPos : EndIf
          
          Offset = Round((CanvasEx()\HScroll\Pos - CanvasEx()\HScroll\minPos) * CanvasEx()\HScroll\Factor, #PB_Round_Nearest)
          
          CanvasEx()\HScroll\Thumb\X = CanvasEx()\HScroll\Area\X + Offset
          
          DrawThumb_(#Horizontal)
          
        EndIf  
        ;}
      EndIf
      
      If CanvasEx()\Scrollbar\Flags & #Vertical   ;{ Vertical Scrollbar
        
        If CanvasEx()\VScroll\Focus And CanvasEx()\VScroll\Hide = #False
          
           CanvasEx()\VScroll\Pos - Delta
          
          If CanvasEx()\VScroll\Pos > CanvasEx()\VScroll\maxPos : CanvasEx()\VScroll\Pos = CanvasEx()\VScroll\maxPos : EndIf
          If CanvasEx()\VScroll\Pos < CanvasEx()\VScroll\minPos : CanvasEx()\VScroll\Pos = CanvasEx()\VScroll\minPos : EndIf
          
          Offset = Round((CanvasEx()\VScroll\Pos - CanvasEx()\VScroll\minPos) * CanvasEx()\VScroll\Factor, #PB_Round_Nearest)
          
          CanvasEx()\VScroll\Thumb\Y = CanvasEx()\VScroll\Area\Y + Offset
          
          DrawThumb_(#Vertical)
          
        EndIf
        ;}
      EndIf
      
    EndIf
    
  EndProcedure
  
	
	Procedure _ResizeHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(CanvasEx(), Str(GNum))
		  DrawScrollBar_()
		EndIf

	EndProcedure
	
	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach CanvasEx()
		  
		  If CanvasEx()\Internal & #AutoResize
		    
		    If IsWindow(CanvasEx()\Window)
		      
			    If IsGadget(CanvasEx()\Gadget)

					  OffSetX = WindowWidth(CanvasEx()\Window)  - CanvasEx()\Resize\Width
						OffsetY = WindowHeight(CanvasEx()\Window) - CanvasEx()\Resize\Height
						
						X      = #PB_Ignore
						Y      = #PB_Ignore
						Height = CanvasEx()\Size\Height + OffSetY
						Width  = CanvasEx()\Size\Width  + OffSetX
						
						If CanvasEx()\Flags & #MoveX : X = CanvasEx()\Size\X + OffSetX : EndIf
						If CanvasEx()\Flags & #MoveY : Y = CanvasEx()\Size\Y + OffSetY : EndIf  
						If CanvasEx()\Flags & #KeepWidth  : Width  = #PB_Ignore : EndIf
						If CanvasEx()\Flags & #KeepHeight : Height = #PB_Ignore : EndIf

						ResizeGadget(CanvasEx()\Gadget, X, Y, Width, Height)

					EndIf

				EndIf

			EndIf

		Next

	EndProcedure
	
	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
	
  Procedure   Background(Canvas.i, Color.i=#White)
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
	    DrawBackground_(Color)
	    
	  EndIf
	  
	EndProcedure
	
	; ----- EventArea -----
	
	Procedure.i AddEventArea(Canvas.i, Id.i, X.i, Y.i, Width.i, Height.i, Cursor.i=#PB_Cursor_Default, Flags.i=#False, Window.i=#PB_Default)
	  ; Flags: #MoveX | #MoveY | #KeepWidth | #KeepHeight
	  Define.i MapElement
	  
	  CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
	  
	  If GadgetType(Canvas) = #PB_GadgetType_Canvas
	    
	    If Window = #PB_Default : Window = GetGadgetWindow() : EndIf
      
      If IsWindow(Window)
	    
    	  If FindMapElement(CanvasEx(), Str(Canvas))
          MapElement = #True
        Else
          MapElement = AddMapElement(CanvasEx(), Str(Canvas))
        EndIf   
        
        If MapElement
          
          CanvasEx()\Window = Window
          CanvasEx()\Gadget = Canvas
          
          If AddMapElement(CanvasEx()\EventArea(), Str(Id))
            
            CanvasEx()\EventArea()\Id     = Id
            
            CanvasEx()\EventArea()\X      = X
            CanvasEx()\EventArea()\Y      = Y
            CanvasEx()\EventArea()\Width  = Width
            CanvasEx()\EventArea()\Height = Height
            
            CanvasEx()\EventArea()\AreaCursor = Cursor
            CanvasEx()\EventArea()\Flags      = Flags
            
            CanvasEx()\Internal | #EventArea
            
            If CanvasEx()\Internal & #MouseEvents = #False
              
              BindGadgetEvent(CanvasEx()\Gadget, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
      				BindGadgetEvent(CanvasEx()\Gadget, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
      				BindGadgetEvent(CanvasEx()\Gadget, @_MouseMoveHandler(),      #PB_EventType_MouseMove)
      				BindGadgetEvent(CanvasEx()\Gadget, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)
      				
      				CanvasEx()\Internal | #MouseEvents
    				
      			EndIf
      			
      			BindGadgetEvent(CanvasEx()\Gadget, @_RightClickHandler(), #PB_EventType_RightClick)
      			
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      EndIf
      
  	EndIf
  	
  	ProcedureReturn  #False
	EndProcedure  
	
	; ----- AutoResize -----
	
	Procedure.i AutoResize(Canvas.i, Flags.i=#False, Window.i=#PB_Default)
	  ; Flags: #MoveCanvas / #ResizeCanvas or #MoveX | #MoveY | #KeepWidth | #KeepHeight
	  Define.i MapElement
	  
	  CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If GadgetType(Canvas) = #PB_GadgetType_Canvas

      If Window = #PB_Default : Window = GetGadgetWindow() : EndIf
      
      If IsWindow(Window)
        
        If FindMapElement(CanvasEx(), Str(Canvas))
          MapElement = #True
        Else
          MapElement = AddMapElement(CanvasEx(), Str(Canvas))
        EndIf   
        
        If MapElement
          
          CanvasEx()\Window = Window
          CanvasEx()\Gadget = Canvas
          
          CanvasEx()\Size\X        = GadgetX(Canvas)
          CanvasEx()\Size\Y        = GadgetY(Canvas)
          CanvasEx()\Size\Width    = GadgetWidth(Canvas)
          CanvasEx()\Size\Height   = GadgetHeight(Canvas)
          
          CanvasEx()\Resize\Width  = WindowWidth(Window)
          CanvasEx()\Resize\Height = WindowHeight(Window)
          
          CanvasEx()\Flags    | Flags
          CanvasEx()\Internal | #AutoResize
          
          BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), Window)
          
          ProcedureReturn #True
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False
	EndProcedure  
	
	; ----- Scrollbars -----
	
	Procedure.i ScrollBar(Canvas.i, Flags.i=#Horizontal, Window.i=#PB_Default)
	  ; Flags: #Horizontal | #Vertical
	  Define.i MapElement
	  
	  CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If GadgetType(Canvas) = #PB_GadgetType_Canvas

      If Window = #PB_Default : Window = GetGadgetWindow() : EndIf
      
      If IsWindow(Window)
        
        If FindMapElement(CanvasEx(), Str(Canvas))
          MapElement = #True
        Else
          MapElement = AddMapElement(CanvasEx(), Str(Canvas))
        EndIf  
        
        If MapElement
          
          CanvasEx()\Window = Window
          CanvasEx()\Gadget = Canvas

          CanvasEx()\Flags | Flags
          
          If Flags & #Horizontal
            CanvasEx()\Scrollbar\Flags | #Horizontal
            CanvasEx()\HScroll\CursorPos      = #PB_Default
            CanvasEx()\HScroll\Buttons\fState = #PB_Default
            CanvasEx()\HScroll\Buttons\bState = #PB_Default
          EndIf 
          
          If Flags & #Vertical
            CanvasEx()\Scrollbar\Flags | #Vertical
            CanvasEx()\VScroll\CursorPos      = #PB_Default
            CanvasEx()\VScroll\Buttons\fState = #PB_Default
            CanvasEx()\VScroll\Buttons\bState = #PB_Default
          EndIf  
          
          CanvasEx()\Scrollbar\Size       = #ScrollBarSize
          CanvasEx()\Scrollbar\TimerDelay = #TimerDelay
          
          ; ----- Styles -----
          If Flags & #Style_Win11      : CanvasEx()\Scrollbar\Flags | #Style_Win11      : EndIf
          If Flags & #Style_RoundThumb : CanvasEx()\Scrollbar\Flags | #Style_RoundThumb : EndIf
          
          ;{ ----- Colors -----
          CanvasEx()\Scrollbar\Color\Front  = $C8C8C8
          CanvasEx()\Scrollbar\Color\Back   = $F0F0F0
				  CanvasEx()\Scrollbar\Color\Button = $F0F0F0
				  CanvasEx()\Scrollbar\Color\Focus  = $D77800
				  CanvasEx()\Scrollbar\Color\Hover  = $666666
				  CanvasEx()\Scrollbar\Color\Arrow  = $696969
				  
				  CanvasEx()\Color\Front  = GetGadgetColor(Canvas, #PB_Gadget_FrontColor)
          CanvasEx()\Color\Back   = GetGadgetColor(Canvas, #PB_Gadget_BackColor)
				  CanvasEx()\Color\Gadget = $C8C8C8
				  
				  CompilerSelect #PB_Compiler_OS
  				  CompilerCase #PB_OS_Windows
  						CanvasEx()\Scrollbar\Color\Front  = GetSysColor_(#COLOR_SCROLLBAR)
  						CanvasEx()\Scrollbar\Color\Back   = GetSysColor_(#COLOR_MENU)
  						CanvasEx()\Scrollbar\Color\Button = GetSysColor_(#COLOR_BTNFACE)
  						CanvasEx()\Scrollbar\Color\Focus  = GetSysColor_(#COLOR_MENUHILIGHT)
  						CanvasEx()\Scrollbar\Color\Hover  = GetSysColor_(#COLOR_ACTIVEBORDER)
  						CanvasEx()\Scrollbar\Color\Arrow  = GetSysColor_(#COLOR_GRAYTEXT)
  						CanvasEx()\Color\Gadget           = GetSysColor_(#COLOR_MENU)
  					CompilerCase #PB_OS_MacOS
  						CanvasEx()\Scrollbar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
  						CanvasEx()\Scrollbar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
  						CanvasEx()\Scrollbar\Color\Button = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
  						CanvasEx()\Scrollbar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
  						CanvasEx()\Scrollbar\Color\Hover  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
  						CanvasEx()\Color\Gadget           = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
  						CanvasEx()\Scrollbar\Color\Arrow  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
  					CompilerCase #PB_OS_Linux
  
  				CompilerEndSelect
  				
  				If OSVersion() = #PB_OS_Windows_10 Or Flags & #Style_Win11
  				  CanvasEx()\Scrollbar\Color\Hover = $666666
  				  CanvasEx()\Scrollbar\Color\Focus = $8C8C8C
  				EndIf   
          ;}
  				
  				If CanvasEx()\Internal & #MouseEvents = #False
  				  
  				  BindGadgetEvent(CanvasEx()\Gadget, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
  				  BindGadgetEvent(CanvasEx()\Gadget, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
  				  BindGadgetEvent(CanvasEx()\Gadget, @_MouseMoveHandler(),      #PB_EventType_MouseMove)
  				  BindGadgetEvent(CanvasEx()\Gadget, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)
  				  
  				  CanvasEx()\Internal | #MouseEvents
  				  
    			EndIf

  				BindGadgetEvent(CanvasEx()\Gadget, @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
  				BindGadgetEvent(CanvasEx()\Gadget, @_ResizeHandler(),         #PB_EventType_Resize)
  				
  				AddWindowTimer(CanvasEx()\Window, #AutoScrollTimer, #Frequency)
				  BindEvent(#PB_Event_Timer, @_AutoScroll(), CanvasEx()\Window)
  				
  				CalcScrollBar_()

				  DrawScrollBar_()
  				
          ProcedureReturn #True
        EndIf
        
      Else
        Debug "Error: Window not found"
      EndIf
      
    Else  
      Debug "Error: No CanvasGadget"
    EndIf
    
    ProcedureReturn #False
	EndProcedure
	
	
	Procedure   HideScrollBar(Canvas.i, State.i, Flags.i=#Horizontal)
	  ; Flags: #Horizontal | #Vertical
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
	    If Flags & #Horizontal
	      CanvasEx()\HScroll\Hide = State
	    EndIf
	    
	    If Flags & #Vertical
	      CanvasEx()\VScroll\Hide = State
	    EndIf
	    
	    DrawScrollBar_(State)
	    
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetScrollBar(Canvas.i, Type.i, Minimum.i, Maximum.i, PageLength.i)
	  ; Type: #Horizontal / #Vertical
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
	    Select Type
	      Case #Horizontal  
	        CanvasEx()\HScroll\Minimum    = Minimum
	        CanvasEx()\HScroll\Maximum    = Maximum
	        CanvasEx()\HScroll\PageLength = PageLength
	        CalcScrollRange_()
	        DrawThumb_(#Horizontal)
	      Case #Vertical
	        CanvasEx()\VScroll\Minimum    = Minimum
	        CanvasEx()\VScroll\Maximum    = Maximum
	        CanvasEx()\VScroll\PageLength = PageLength  
	        CalcScrollRange_()
	        DrawThumb_(#Vertical)
	    EndSelect

	  EndIf
	  
	EndProcedure
	
	; ------------------------------------------------------------

	Procedure.i GetAttribute(Canvas.i, Attribute.i, Type.i=#Canvas)
	  ; #Canvas:    #Width / #Height
    ; #Scrollbar: #Size / #Delay
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
	    Select Type
	      Case #Scrollbar
	        Select Attribute
	          Case #Size  ; ScrollBar size 
	            ProcedureReturn CanvasEx()\Scrollbar\Size
	          Case #Delay ; AutoScroll Delay (Value * 100ms)
	            ProcedureReturn CanvasEx()\Scrollbar\TimerDelay
	        EndSelect
  	    Case #Canvas
  	      Select Attribute
  	        Case #Width  ; available width for drawing
  	          ProcedureReturn CanvasEx()\Area\Width
  	        Case #Height ; available height for drawing
  	          ProcedureReturn CanvasEx()\Area\Height
  	      EndSelect
  	  EndSelect 
  	  
  	EndIf
  	
	EndProcedure  
	
	Procedure.i GetItemAttribute(Canvas.i, Type.i, Attribute.i)
	  ; Type: #Horizontal / #Vertical
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
	    Select Type
	      Case #Horizontal ;{ Horizontal Scrollbar
	        
	        Select Attribute
	          Case #Minimum
	            ProcedureReturn CanvasEx()\HScroll\Minimum
	          Case #Maximum
	            ProcedureReturn CanvasEx()\HScroll\Maximum
	          Case #PageLength  
	            ProcedureReturn CanvasEx()\HScroll\PageLength
	          Case #Position
	            ProcedureReturn CanvasEx()\HScroll\Pos
	        EndSelect
	        ;}
	      Case #Vertical   ;{ Vertical Scrollbar
	        
  	      Select Attribute
	          Case #Minimum
	            ProcedureReturn CanvasEx()\VScroll\Minimum
	          Case #Maximum
	            ProcedureReturn CanvasEx()\VScroll\Maximum
	          Case #PageLength  
	            ProcedureReturn CanvasEx()\VScroll\PageLength
	          Case #Position  
	            ProcedureReturn CanvasEx()\VScroll\Pos
	        EndSelect
	        ;}  
  	  EndSelect
  	  
	  EndIf 
	  
	EndProcedure	
	
	Procedure.i GetState(Canvas.i, Type.i=#Horizontal) 
	  ; Type: #Horizontal / #Vertical
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
  	  Select Type
  	    Case #Horizontal
  	      ProcedureReturn CanvasEx()\HScroll\Pos
  	    Case #Vertical  
  	      ProcedureReturn CanvasEx()\VScroll\Pos
  	  EndSelect
  	  
  	EndIf
  	
	EndProcedure  
	
	
	Procedure   SetAttribute(Canvas.i, Attribute.i, Value.i, Type.i=#Scrollbar)
	  ; #Scrollbar: #Size / #Delay
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
	    Select Type
	      Case #Scrollbar
	        
	        Select Attribute
	          Case #Size  ; ScrollBar size 
	            CanvasEx()\Scrollbar\Size = Value
	          Case #Delay ; AutoScroll Delay (Value * 100ms)
	            CanvasEx()\Scrollbar\TimerDelay = Value
	        EndSelect
  	      
  	  EndSelect 
  	  
  	EndIf
  	
	EndProcedure    

	Procedure   SetItemAttribute(Canvas.i, Type.i, Attribute.i, Value.i)
	  ; Type: #Horizontal / #Vertical
	  
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
	    Select Type
	      Case #Horizontal ;{ Horizontal Scrollbar
	        
	        Select Attribute
	          Case #Minimum
	            CanvasEx()\HScroll\Minimum = Value
	            CalcScrollRange_()
	            DrawThumb_(#Horizontal)
	          Case #Maximum
	            CanvasEx()\HScroll\Maximum = Value
	            CalcScrollRange_()
	            DrawThumb_(#Horizontal)
	          Case #PageLength  
	            CanvasEx()\HScroll\PageLength = Value
	            CalcScrollRange_()
	            DrawThumb_(#Horizontal)
	          Case #Position
	            SetThumbPosX_(Value)
	            DrawThumb_(#Horizontal)
	        EndSelect
	        ;}
  	    Case #Vertical   ;{ Vertical Scrollbar
  	      Select Attribute
	          Case #Minimum
	            CanvasEx()\VScroll\Minimum = Value
	            CalcScrollRange_()
	            DrawThumb_(#Vertical)
	          Case #Maximum
	            CanvasEx()\VScroll\Maximum = Value
	            CalcScrollRange_()
	            DrawThumb_(#Vertical)
	          Case #PageLength  
	            CanvasEx()\VScroll\PageLength = Value
	            CalcScrollRange_()
	            DrawThumb_(#Vertical)
	          Case #Position  
	            SetThumbPosY_(Value)
      	      DrawThumb_(#Vertical)
	        EndSelect
	        ;}  
	    EndSelect    

	  EndIf  
	  
	EndProcedure
	
  Procedure   SetState(Canvas.i, Value.i, Type.i=#Horizontal) 
    ; Type: #Horizontal / #Vertical
    
	  If FindMapElement(CanvasEx(), Str(Canvas))
	    
  	  Select Type
  	    Case #Horizontal ;{ Scrollbar position
  	      SetThumbPosX_(Value)
      	  DrawThumb_(#Horizontal)
  	      ;}
  	    Case #Vertical   ;{ Scrollbar position
  	      SetThumbPosY_(Value)
      	  DrawThumb_(#Vertical)
  	      ;}
  	  EndSelect
  	  
  	EndIf
  	
	EndProcedure 

	
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Define.i Position
  
  Enumeration 
    #Window
    #Canvas
    #Font
  EndEnumeration
  
  #BoxID  = 1937
  #TextID = 1967
  
  LoadFont(#Font, "Arial", 14)

  Procedure DrawCanvasBox(Canvas.i)
    
    If StartDrawing(CanvasOutput(Canvas)) 

      DrawingMode(#PB_2DDrawing_Outlined )
      
      Box(50, 50, 80, 40, #Red)

      StopDrawing()
    EndIf
    
  EndProcedure  
  
  Procedure DrawCanvasText(Canvas.i, Color.i)
    Define.s Text$
    
    Text$ = "Example Text"
    
    If StartDrawing(CanvasOutput(Canvas)) 

      DrawingMode(#PB_2DDrawing_Default)
      
      DrawingFont(FontID(#Font))
      
      ; Debug "Text Width: "  + Str(TextWidth(Text$))
      ; Debug "Text Height: " + Str(TextHeight(Text$))
      
      DrawText(50, 150, Text$, Color, #White)

      StopDrawing()
    EndIf
    
  EndProcedure
  
  
  If OpenWindow(#Window, 0, 0, 300, 280, "Module - Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    
    If CanvasGadget(#Canvas, 10, 10, 280, 260)
      ; ----- Scrollbars for CanvasGadget -----
      CanvasEx::ScrollBar(#Canvas,    CanvasEx::#Horizontal|CanvasEx::#Vertical) ; |CanvasEx::#Style_RoundThumb
      CanvasEx::SetScrollBar(#Canvas, CanvasEx::#Horizontal, 1, 100, 80)
      CanvasEx::SetScrollBar(#Canvas, CanvasEx::#Vertical,   1, 100, 30)
    EndIf
    
    ; ----- Autoresize CanvasGadget -----
    CanvasEx::AutoResize(#Canvas) ; , CanvasEx::#MoveCanvas
    
    ; ----- Add event area -----
    DrawCanvasBox(#Canvas) ; Draws a box on canvas
    CanvasEx::AddEventArea(#Canvas, #BoxID, 50, 50, 80, 40, #PB_Cursor_Hand)
    
    DrawCanvasText(#Canvas, #Black)
    CanvasEx::AddEventArea(#Canvas, #TextID, 50, 150, 116, 22, #PB_Cursor_Hand)
    
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_SizeWindow        ;{ Redraw your CanvasGadget
          Debug "You must redraw the CanvasGadget: " + Str(#Canvas)
          ;}
        Case CanvasEx::#Event_CanvasArea ;{ Canvas Area Events
          
          Select EventData()
            Case #BoxID  ;{ EventArea - Box
              Select EventType()
                Case #PB_EventType_MouseEnter
                  Debug "-> Mouse enter ("+Str(EventData())+")"
                Case #PB_EventType_MouseLeave
                  Debug "-> Mouse leave ("+Str(EventData())+")"
                Case #PB_EventType_LeftButtonDown  
                  Debug "-> Mouse button down ("+Str(EventData())+")"
                Case #PB_EventType_LeftButtonUp
                  Debug "-> Mouse button up ("+Str(EventData())+")"
                  ;CanvasEx::Background(#Canvas)
                Case #PB_EventType_RightClick
                  Debug "-> Mouse right click ("+Str(EventData())+")"  
              EndSelect ;}
            Case #TextID ;{ EventArea - Text
              Select EventType()
                Case #PB_EventType_MouseEnter
                  DrawCanvasText(#Canvas, #Blue) 
                Case #PB_EventType_MouseLeave
                  DrawCanvasText(#Canvas, #Black)
                Case #PB_EventType_LeftButtonDown
                  DrawCanvasText(#Canvas, #Red)
                Case #PB_EventType_LeftButtonUp
                  DrawCanvasText(#Canvas, #Blue)  
              EndSelect    
              ;}
          EndSelect    
          ;}
        Case CanvasEx::#Event_Gadget     ;{ Module Events
          Select EventGadget()  
            Case #Canvas
              If EventType() = #PB_EventType_Change 
                Select EventData()  
                  Case CanvasEx::#Horizontal
                    Position = CanvasEx::GetState(#Canvas, CanvasEx::#Horizontal)
                    Debug "Horizontal Scrollbar: " + Str(Position)
                  Case CanvasEx::#Vertical
                    Position = CanvasEx::GetState(#Canvas, CanvasEx::#Vertical)
                    Debug "Vertical Scrollbar: " + Str(Position)
                EndSelect    
              EndIf  
          EndSelect ;} 
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 2319
; FirstLine = 281
; Folding = MCAwAgHAAACAACJAQAAi6
; EnableXP