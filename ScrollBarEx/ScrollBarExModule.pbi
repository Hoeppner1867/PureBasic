;/ ============================
;/ =    ScrollBarExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ ScrollBarEx - Gadget
;/
;/ © 2020  by Thorsten Hoeppner (02/2020)
;/

; - Adjust scrollbar length if vertical and horizontal are displayed
; - Support of the mouse wheel when the cursor is over the scrollbar
; - Automatic size adjustment
; - Appearance customization
; - Support for rounded corners
; - Full color support

; Last Update: 29.02.2020
;
; - Added: AutoScroll for buttons   (hold button)
; - Added: Scroll page width/height (click gap)
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


;{ _____ ScrollEx - Commands _____

; ScrollEx::Gadget()       - similar to ScrollBarGadget()
; ScrollEx::GetAttribute() - similar to GetGadgetAttribute()
; ScrollEx::GetData()      - similar to GetGadgetData()
; ScrollEx::GetID()        - similar to GetGadgetData(), but string instead of integer
; ScrollEx::GetState()     - similar to GetGadgetState()
; ScrollEx::Hide()         - similar to HideGadget()
; ScrollEx::SetAttribute() - similar to SetGadgetAttribute()
; ScrollEx::SetColor()     - similar to SetGadgetColor()
; ScrollEx::SetData()      - similar to SetGadgetData()
; ScrollEx::SetID()        - similar to SetGadgetData() , but string instead of integer
; ScrollEx::SetState()     - similar to SetGadgetState()
;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule ScrollEx
  
  #Version  = 20022900
  #ModuleEx = 20022800
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	;{ _____ Constants _____
  EnumerationBinary ;{ Gadget Flags
    #Vertical = #PB_ScrollBar_Vertical
		#AutoResize        ; Automatic resizing of the gadget
		#Border            ; Draw gadget border
		#ButtonBorder      ; Draw button borders
		#ThumbBorder       ; Draw thumb border
		#DragLines         ; Draw drag lines
		#UseExistingCanvas ; e.g. for dialogs
	EndEnumeration ;}
	
	Enumeration 1     ;{ Attribute
	  #Minimum    = #PB_ScrollBar_Minimum
    #Maximum    = #PB_ScrollBar_Maximum
    #PageLength = #PB_ScrollBar_PageLength
    #Adjust     ; Adjusting the scrollbar length when both scrollbars are displayed
    #Corner     ; Rounded corners
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
		#ButtonColor
		#FocusColor
		#GadgetColor
		#ScrollBarColor
	EndEnumeration ;}
	
	Enumeration 1     ;{ Direction
	  #Up
	  #Down
	  #Left
	  #Right
	EndEnumeration ;}
	
	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget = ModuleEx::#Event_Gadget
		#Event_Theme  = ModuleEx::#Event_Theme
		#Event_Timer  = ModuleEx::#Event_Timer
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
		  #Event_Gadget
		  #Event_Timer
		EndEnumeration

	CompilerEndIf
	;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================

  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Minimum.i, Maximum.i, PageLength.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.q GetData(GNum.i)
  Declare.s GetID(GNum.i)
  Declare.i GetState(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetID(GNum.i, String.s)
  Declare   SetState(GNum.i, State.i)
  
EndDeclareModule

Module ScrollEx

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#ButtonSize = 18
	
	#Frequency  = 100
	#TimerDelay = 3
	
	Enumeration 1  ;{ Button
	  #Forwards
	  #Backwards
	  #Focus
	  #Click
	EndEnumeration ;}
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	Structure Timer_Thread_Structure ;{
    Num.i
    Active.i
    Exit.i
  EndStructure ;}
	
	Structure Button_Structure           ;{ ScrollEx()\Button\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollEx_Thumb_Structure   ;{ ScrollEx()\Thumb\...
	  Pos.i
	  minPos.i
	  maxPos.i
	  Ratio.f
	  Factor.f
	  Size.i
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollEx_Button_Structure  ;{ ScrollEx()\Button\...
	  Backwards.Button_Structure
	  Forwards.Button_Structure
	EndStructure ;}
	
	Structure ScrollEx_Area_Structure    ;{ ScrollEx()\Area\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	EndStructure ;}
	
	Structure ScrollEx_Color_Structure   ;{ ScrollEx()\Color\...
		Front.i
		Back.i
		Border.i
		Button.i
		Focus.i
		Gadget.i
		ScrollBar.i
		DisableFront.i
		DisableBack.i
	EndStructure  ;}

	Structure ScrollEx_Window_Structure  ;{ ScrollEx()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure ScrollEx_Size_Structure    ;{ ScrollEx()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
	EndStructure ;}

	Structure ScrollEx_Structure         ;{ ScrollEx()\...
		CanvasNum.i

		ID.s
		Quad.i

    Radius.i
		Hide.i
		Disable.i
		
		Cursor.i
		
		Adjust.i
		Minimum.i
		Maximum.i
		PageLength.i
		
		Timer.i
		TimerDelay.i
		
		Flags.i
		
		Thumb.ScrollEx_Thumb_Structure
		Button.ScrollEx_Button_Structure
		Area.ScrollEx_Area_Structure
		Color.ScrollEx_Color_Structure
		Window.ScrollEx_Window_Structure
		Size.ScrollEx_Size_Structure

	EndStructure ;}
	Global NewMap ScrollEx.ScrollEx_Structure()
	
	Global Thread.Timer_Thread_Structure
	
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

	Procedure.i CalcThumb()
	  Define.i Size, Range
	  
	  ScrollEx()\Thumb\minPos = ScrollEx()\Minimum
	  ScrollEx()\Thumb\maxPos = ScrollEx()\Maximum - ScrollEx()\PageLength + 1
	  ScrollEx()\Thumb\Ratio  = ScrollEx()\PageLength / ScrollEx()\Maximum
	  ScrollEx()\Thumb\Pos    = ScrollEx()\Minimum
	  
	  Range = ScrollEx()\Thumb\maxPos - ScrollEx()\Thumb\minPos
	  
	  If ScrollEx()\Flags & #Vertical
	    ScrollEx()\Area\X       = 0
  	  ScrollEx()\Area\Y       = dpiY(#ButtonSize) + dpiY(1)
  	  ScrollEx()\Area\Width   = dpiX(GadgetWidth(ScrollEx()\CanvasNum))
  	  ScrollEx()\Area\Height  = dpiY(GadgetHeight(ScrollEx()\CanvasNum)) - dpiY(ScrollEx()\Adjust) - dpiY(#ButtonSize * 2) - dpiY(2)
  	  ScrollEx()\Thumb\Y      = ScrollEx()\Area\Y
  	  ScrollEx()\Thumb\Size   = ScrollEx()\Area\Height * ScrollEx()\Thumb\Ratio
  	  ScrollEx()\Thumb\Factor = (ScrollEx()\Area\Height - ScrollEx()\Thumb\Size) / Range
	  Else
	    ScrollEx()\Area\X       = dpiX(#ButtonSize) + dpiX(1)
  	  ScrollEx()\Area\Y       = 0
  	  ScrollEx()\Area\Width   = dpiX(GadgetWidth(ScrollEx()\CanvasNum)) - dpiX(ScrollEx()\Adjust) - dpiX(#ButtonSize * 2) - dpiX(2)
  	  ScrollEx()\Area\Height  = dpiY(GadgetHeight(ScrollEx()\CanvasNum))
  	  ScrollEx()\Thumb\X      = ScrollEx()\Area\X
  	  ScrollEx()\Thumb\Size   = ScrollEx()\Area\Width * ScrollEx()\Thumb\Ratio
  	  ScrollEx()\Thumb\Factor = (ScrollEx()\Area\Width - ScrollEx()\Thumb\Size) / Range
	  EndIf

	EndProcedure
	
	Procedure.i GetSteps_(Cursor.i)
	  Define.i Steps
	  
	  Steps = (Cursor - ScrollEx()\Cursor) / ScrollEx()\Thumb\Factor
	  
	  If Steps = 0
	    If Cursor < ScrollEx()\Cursor
	      Steps = -1
	    Else
	      Steps = 1
	    EndIf
	  EndIf
	  
	  ProcedureReturn Steps
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
  
    If ScrollEx()\Radius
  		RoundBox(X, Y, Width, Height, ScrollEx()\Radius, ScrollEx()\Radius, Color)
  	Else
  		Box(X, Y, Width, Height, Color)
  	EndIf
  	
  EndProcedure
  
  Procedure   DrawArrow_(X.i, Y.i, Width.i, Height.i, Color.i, Flag.i)
	  Define.i aWidth, aHeight, aColor

	  If StartVectorDrawing(CanvasVectorOutput(ScrollEx()\CanvasNum))

      aColor  = RGBA(Red(Color), Green(Color), Blue(Color), 255)
      
      If Flag = #Up Or Flag = #Down
  	    aWidth  = dpiX(8)
  	    aHeight = dpiX(4)
  	  Else
        aWidth  = dpiX(4)
        aHeight = dpiX(8)  
  	  EndIf  

      X + ((Width  - aWidth) / 2)
      Y + ((Height - aHeight) / 2)
      
      Select Flag
        Case #Up
          MovePathCursor(X, Y + aHeight)
          AddPathLine(X + aWidth / 2, Y)
          AddPathLine(X + aWidth, Y + aHeight)
        Case #Down 
          MovePathCursor(X, Y)
          AddPathLine(X + aWidth / 2, Y + aHeight)
          AddPathLine(X + aWidth, Y)
        Case #Left
          MovePathCursor(X + aWidth, Y)
          AddPathLine(X, Y + aHeight / 2)
          AddPathLine(X + aWidth, Y + aHeight)
        Case #Right
          MovePathCursor(X, Y)
          AddPathLine(X + aWidth, Y + aHeight / 2)
          AddPathLine(X, Y + aHeight)
      EndSelect
      
      VectorSourceColor(aColor)
      StrokePath(2, #PB_Path_RoundCorner)

	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
	
	Procedure   DrawButton_(X.i, Y.i, Width.i, Height.i, Type.i, State.i=#False)
	  Define.i Color, Border
	  
	  If StartDrawing(CanvasOutput(ScrollEx()\CanvasNum))
	    
	    DrawingMode(#PB_2DDrawing_Default)
	    
	    Select State
	      Case #Focus
	        Color  = BlendColor_(ScrollEx()\Color\Focus, ScrollEx()\Color\Button, 10)
	        Border = BlendColor_(ScrollEx()\Color\Focus, ScrollEx()\Color\Border, 10)
	      Case #Click
	        Color  = BlendColor_(ScrollEx()\Color\Focus, ScrollEx()\Color\Button, 20)
	        Border = BlendColor_(ScrollEx()\Color\Focus, ScrollEx()\Color\Border, 20)
	      Default
	        Color  = ScrollEx()\Color\Button
	        Border = ScrollEx()\Color\Border
	    EndSelect    
	    
	    Select Type
	      Case #Forwards
	        Box_(ScrollEx()\Button\Forwards\X,  ScrollEx()\Button\Forwards\Y,  ScrollEx()\Button\Forwards\Width,  ScrollEx()\Button\Forwards\Height,  Color)
	      Case #Backwards
	        Box_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, Color)
	    EndSelect    
	    
	    If ScrollEx()\Flags & #ButtonBorder
	      
	      DrawingMode(#PB_2DDrawing_Outlined)
	      
	      Select Type
	        Case #Forwards
	          If ScrollEx()\Flags & #Vertical
	            Box_(ScrollEx()\Button\Forwards\X - dpiX(1), ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width + dpiX(2), ScrollEx()\Button\Forwards\Height + dpiY(1), Border)
	          Else
	            Box_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y - dpiY(1), ScrollEx()\Button\Forwards\Width + dpiX(1), ScrollEx()\Button\Forwards\Height + dpiY(2), Border)
	          EndIf  
  	      Case #Backwards
  	        If ScrollEx()\Flags & #Vertical
  	          Box_(ScrollEx()\Button\Backwards\X - dpiX(1), ScrollEx()\Button\Backwards\Y - dpiY(1), ScrollEx()\Button\Backwards\Width + dpiX(2), ScrollEx()\Button\Backwards\Height + dpiY(1), Border)
  	        Else
	            Box_(ScrollEx()\Button\Backwards\X - dpiX(1), ScrollEx()\Button\Backwards\Y - dpiY(1), ScrollEx()\Button\Backwards\Width + dpiX(1), ScrollEx()\Button\Backwards\Height + dpiY(2), Border)
	          EndIf   
  	    EndSelect 
  	    
	    EndIf  
	    
	    StopDrawing()
	  EndIf
	  
	  ;{ ----- Draw Arrows -----
	  Select Type
      Case #Forwards
        If ScrollEx()\Flags & #Vertical
          DrawArrow_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, ScrollEx()\Color\Front, #Down)
        Else
          DrawArrow_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, ScrollEx()\Color\Front, #Right)
        EndIf  
      Case #Backwards
        If ScrollEx()\Flags & #Vertical
      		DrawArrow_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, ScrollEx()\Color\Front, #Up)
      	Else
      	  DrawArrow_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, ScrollEx()\Color\Front, #Left)
      	EndIf  
    EndSelect ;}

	EndProcedure
	
	Procedure   Draw_()
		Define.i X, Y, Width, Height, Offset, OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		If ScrollEx()\Hide : ProcedureReturn #False : EndIf 
		
		X = 0
		Y = 0
		
		Width  = dpiX(GadgetWidth(ScrollEx()\CanvasNum)) 
		Height = dpiY(GadgetHeight(ScrollEx()\CanvasNum))
	
		;{ ----- Buttons -----
		If ScrollEx()\Flags & #Vertical
  		ScrollEx()\Button\Forwards\X = dpiX(1)
  		ScrollEx()\Button\Forwards\Y = Height - dpiY(#ButtonSize) - dpiY(ScrollEx()\Adjust) - dpiY(1)
  		ScrollEx()\Button\Forwards\Width  = Width - dpiX(2)
  		ScrollEx()\Button\Forwards\Height = dpiY(#ButtonSize)
  		
  		ScrollEx()\Button\Backwards\X = dpiX(1)
  		ScrollEx()\Button\Backwards\Y = dpiY(1)
  		ScrollEx()\Button\Backwards\Width  = Width - dpiX(2)
  		ScrollEx()\Button\Backwards\Height = dpiY(#ButtonSize)
  	Else
  	  ScrollEx()\Button\Forwards\X = Width - dpiX(#ButtonSize) - dpiX(ScrollEx()\Adjust) - dpiY(1)
  		ScrollEx()\Button\Forwards\Y = dpiY(1)
  		ScrollEx()\Button\Forwards\Width  = dpiX(#ButtonSize)
  		ScrollEx()\Button\Forwards\Height = Height - dpiY(2)
  		
  		ScrollEx()\Button\Backwards\X = dpiX(1)
  		ScrollEx()\Button\Backwards\Y = dpiY(1)
  		ScrollEx()\Button\Backwards\Width  = dpiX(#ButtonSize)
  		ScrollEx()\Button\Backwards\Height = Height - dpiY(2)
  	EndIf ;}
  	
  	;{ ----- ScrollArea -----
  	If ScrollEx()\Flags & #Vertical
  	  ScrollEx()\Area\X = 0
  	  ScrollEx()\Area\Y = dpiY(#ButtonSize) + dpiY(1)
  	  ScrollEx()\Area\Width  = Width
  	  ScrollEx()\Area\Height = Height - dpiY(#ButtonSize * 2) - dpiY(2)
  	Else
  	  ScrollEx()\Area\X = dpiX(#ButtonSize) + dpiX(1)
  	  ScrollEx()\Area\Y = 0
  	  ScrollEx()\Area\Width  = Width - dpiX(#ButtonSize * 2) - dpiX(2)
  	  ScrollEx()\Area\Height = Height
  	EndIf  
  	;}
  	
  	;{ ----- Thumb -----
  	Offset = (ScrollEx()\Thumb\Pos - ScrollEx()\Thumb\minPos) * ScrollEx()\Thumb\Factor
  	
  	If ScrollEx()\Flags & #Vertical
  	  ScrollEx()\Thumb\X      = 0
  	  ScrollEx()\Thumb\Y      = ScrollEx()\Area\Y + Offset
  	  ScrollEx()\Thumb\Width  = Width
  	  ScrollEx()\Thumb\Height = ScrollEx()\Thumb\Size
  	  If ScrollEx()\Flags & #ButtonBorder
  	    ScrollEx()\Thumb\Y + dpiY(1)
  	    ScrollEx()\Thumb\Height - dpiY(2)
  	  EndIf  
  	Else
  	  ScrollEx()\Thumb\X      = ScrollEx()\Area\X + Offset
  	  ScrollEx()\Thumb\Y      = 0
  	  ScrollEx()\Thumb\Width  = ScrollEx()\Thumb\Size
  	  ScrollEx()\Thumb\Height = Height
  	  If ScrollEx()\Flags & #ButtonBorder
  	    ScrollEx()\Thumb\X + dpiX(1)
  	    ScrollEx()\Thumb\Width - dpiX(2)
  	  EndIf
  	EndIf  
    ;}
  	
		If StartDrawing(CanvasOutput(ScrollEx()\CanvasNum))
		  
		  ;{ _____ Color _____
		  FrontColor  = ScrollEx()\Color\Front
		  BackColor   = ScrollEx()\Color\Back
		  BorderColor = ScrollEx()\Color\Border
		  
		  If ScrollEx()\Disable
		    FrontColor  = ScrollEx()\Color\DisableFront
		    BackColor   = ScrollEx()\Color\DisableBack
		    BorderColor = ScrollEx()\Color\DisableFront ; or ScrollEx()\Color\DisableBack
		  EndIf
		  ;}
		  
		  DrawingMode(#PB_2DDrawing_Default)
		  
		  ;{ _____ Background _____
		  Box(0, 0, Width, Height, ScrollEx()\Color\Gadget) ; needed for rounded corners
		  Box(ScrollEx()\Area\X, ScrollEx()\Area\Y, ScrollEx()\Area\Width, ScrollEx()\Area\Height, ScrollEx()\Color\Back)
			;}
			
			;{ _____ Thumb _____
			Select ScrollEx()\Thumb\State
			  Case #Focus
			    Box_(ScrollEx()\Thumb\X, ScrollEx()\Thumb\Y, ScrollEx()\Thumb\Width, ScrollEx()\Thumb\Height, BlendColor_(ScrollEx()\Color\Focus, ScrollEx()\Color\ScrollBar, 10))
			  Case #Click
			    Box_(ScrollEx()\Thumb\X, ScrollEx()\Thumb\Y, ScrollEx()\Thumb\Width, ScrollEx()\Thumb\Height, BlendColor_(ScrollEx()\Color\Focus, ScrollEx()\Color\ScrollBar, 20))
			  Default
			    Box_(ScrollEx()\Thumb\X, ScrollEx()\Thumb\Y, ScrollEx()\Thumb\Width, ScrollEx()\Thumb\Height, ScrollEx()\Color\ScrollBar)
			EndSelect
			
			If ScrollEx()\Flags & #DragLines ;{ Drag Lines
			  
			  If ScrollEx()\Flags & #Vertical
			  
			    If ScrollEx()\Thumb\Size > dpiY(10)
			      OffsetY = (ScrollEx()\Thumb\Size - dpiY(7)) / 2			      
			      Line(ScrollEx()\Thumb\X + dpiX(4), ScrollEx()\Thumb\Y + OffsetY, ScrollEx()\Thumb\Width - dpiX(8), dpiY(1), ScrollEx()\Color\Front)
			      Line(ScrollEx()\Thumb\X + dpiX(4), ScrollEx()\Thumb\Y + OffsetY + dpiY(3), ScrollEx()\Thumb\Width - dpiX(8), dpiY(1), ScrollEx()\Color\Front)
			      Line(ScrollEx()\Thumb\X + dpiX(4), ScrollEx()\Thumb\Y + OffsetY + dpiY(6), ScrollEx()\Thumb\Width - dpiX(8), dpiY(1), ScrollEx()\Color\Front)
  			  EndIf

  		  Else
  		  
  		    If ScrollEx()\Thumb\Size > dpiX(10)
    		    OffsetX = (ScrollEx()\Thumb\Size - dpiX(7)) / 2
    		    Line(ScrollEx()\Thumb\X + OffsetX, ScrollEx()\Thumb\Y + dpiX(4), dpiX(1), ScrollEx()\Thumb\Height - dpiY(8), ScrollEx()\Color\Front)
			      Line(ScrollEx()\Thumb\X + OffsetX + dpiX(3), ScrollEx()\Thumb\Y + dpiX(4), dpiX(1), ScrollEx()\Thumb\Height - dpiY(8), ScrollEx()\Color\Front)
			      Line(ScrollEx()\Thumb\X + OffsetX + dpiX(6), ScrollEx()\Thumb\Y + dpiX(4), dpiX(1), ScrollEx()\Thumb\Height - dpiY(8), ScrollEx()\Color\Front)
    		  EndIf
    		  
    		EndIf
    		;}
  		EndIf
  		
			If ScrollEx()\Flags & #ThumbBorder
			  DrawingMode(#PB_2DDrawing_Outlined)
			  Box_(ScrollEx()\Thumb\X, ScrollEx()\Thumb\Y, ScrollEx()\Thumb\Width, ScrollEx()\Thumb\Height, ScrollEx()\Color\Border)
			EndIf  
			;}
			
			;{ _____ Border ____
			If ScrollEx()\Flags & #Border
				DrawingMode(#PB_2DDrawing_Outlined)
				Box_(0, 0, dpiX(GadgetWidth(ScrollEx()\CanvasNum)), dpiY(GadgetHeight(ScrollEx()\CanvasNum)), BorderColor)
			EndIf ;}

			StopDrawing()
		EndIf
		
	  DrawButton_(ScrollEx()\Button\Forwards\X,  ScrollEx()\Button\Forwards\Y,  ScrollEx()\Button\Forwards\Width,  ScrollEx()\Button\Forwards\Height,  #Forwards,  ScrollEx()\Button\Forwards\State)
	  DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards, ScrollEx()\Button\Backwards\State)
		
	EndProcedure
		
	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ScrollEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ScrollEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf

        ScrollEx()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
				ScrollEx()\Color\Back         = ModuleEx::ThemeGUI\BackColor
				ScrollEx()\Color\Border       = ModuleEx::ThemeGUI\BorderColor
				ScrollEx()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
				ScrollEx()\Color\Focus        = ModuleEx::ThemeGUI\FocusBack
				ScrollEx()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
		    ScrollEx()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
				
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
  
  Procedure _TimerThread(Frequency.i)
    Define.i ElapsedTime
    
    Repeat
      
      If ElapsedTime >= Frequency
        PostEvent(#Event_Timer)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until Thread\Exit
    
  EndProcedure
  
  Procedure _AutoScroll()
    Define.i X, Y
    
    ForEach ScrollEx()
      
      If ScrollEx()\Timer
        
        If ScrollEx()\TimerDelay
          ScrollEx()\TimerDelay - 1
          Continue
        EndIf  
        
        Select ScrollEx()\Timer
          Case #Up, #Left
            ScrollEx()\Thumb\Pos - 1
            If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
            PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, ScrollEx()\Timer)
            PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, ScrollEx()\Timer)
            Draw_()
          Case #Down, #Right
            ScrollEx()\Thumb\Pos + 1
            If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
            PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, ScrollEx()\Timer)
            PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, ScrollEx()\Timer)
            Draw_()
  			EndSelect
  			
      EndIf   
      
    Next
    
  EndProcedure
  
	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(ScrollEx(), Str(GNum))

			X = GetGadgetAttribute(ScrollEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ScrollEx()\CanvasNum, #PB_Canvas_MouseY)
			
			ScrollEx()\Cursor = #PB_Default
			
			;{ ----- Button Click -----
			If ScrollEx()\Flags & #Vertical

			  If Y <= ScrollEx()\Button\Backwards\Y + ScrollEx()\Button\Backwards\Height
			    ;{ Backwards Button
			    If ScrollEx()\Button\Backwards\State <> #Click
			      DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards, #Click)
			      ScrollEx()\TimerDelay = #TimerDelay
			      ScrollEx()\Timer      = #Up
			      ScrollEx()\Button\Backwards\State = #Click
			    EndIf ;}
			  ElseIf Y >= ScrollEx()\Button\Forwards\Y
			    ;{ Forwards Button
			    If ScrollEx()\Button\Forwards\State <> #Click
			      DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards, #Click)
			      ScrollEx()\TimerDelay = #TimerDelay
			      ScrollEx()\Timer      = #Down
			      ScrollEx()\Button\Forwards\State = #Click
			    EndIf ;}
			  ElseIf Y >= ScrollEx()\Thumb\Y And Y <= ScrollEx()\Thumb\Y + ScrollEx()\Thumb\Height
			    ;{ Thumb Button
			    If ScrollEx()\Thumb\State <> #Click
			      ScrollEx()\Thumb\State = #Click
			      ScrollEx()\Cursor = Y
			      Draw_()
			    EndIf ;} 
			  EndIf
			  
			Else

			  If X <= ScrollEx()\Button\Backwards\X + ScrollEx()\Button\Backwards\Width
			    ;{ Backwards Button
			    If ScrollEx()\Button\Backwards\State <> #Click
			      DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards, #Click)
			      ScrollEx()\TimerDelay = #TimerDelay
			      ScrollEx()\Timer      = #Left
			      ScrollEx()\Button\Backwards\State = #Click
			    EndIf ;}
			  ElseIf X >= ScrollEx()\Button\Forwards\X
			    ;{ Forwards Button
			    If ScrollEx()\Button\Forwards\State <> #Click
			      DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards, #Click)
			      ScrollEx()\TimerDelay = #TimerDelay
			      ScrollEx()\Timer      = #Right
			      ScrollEx()\Button\Forwards\State = #Click
			    EndIf ;}
			  ElseIf X >= ScrollEx()\Thumb\X And X <= ScrollEx()\Thumb\X + ScrollEx()\Thumb\Width
			    ;{ Thumb Button
			    If ScrollEx()\Thumb\State <> #Click
			      ScrollEx()\Thumb\State = #Click
			      ScrollEx()\Cursor = X
			      Draw_()
			    EndIf ;} 
			  EndIf
			  
			EndIf ;}

		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, Y, Angle
		Define.i GNum = EventGadget()

		If FindMapElement(ScrollEx(), Str(GNum))

			X = GetGadgetAttribute(ScrollEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ScrollEx()\CanvasNum, #PB_Canvas_MouseY)
			
			ScrollEx()\Cursor = #PB_Default
			ScrollEx()\Timer  = #False
			
			If ScrollEx()\Flags & #Vertical
			  
			  If Y <= ScrollEx()\Button\Backwards\Y + ScrollEx()\Button\Backwards\Height
			    ScrollEx()\Thumb\Pos - 1
			    If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Up)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Up)
			    Draw_()
			    ProcedureReturn #True
			  ElseIf Y >= ScrollEx()\Button\Forwards\Y
			    ScrollEx()\Thumb\Pos + 1
			    If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Down)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Down)
			    Draw_()
			    ProcedureReturn #True
			  ElseIf Y < ScrollEx()\Thumb\Y
			    ScrollEx()\Thumb\Pos - ScrollEx()\PageLength
			    If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Up)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Up)
			    Draw_()
			    ProcedureReturn #True
			  ElseIf Y > ScrollEx()\Thumb\Y + ScrollEx()\Thumb\Height
			    ScrollEx()\Thumb\Pos + ScrollEx()\PageLength
			    If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Down)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Down)
			    Draw_()
			    ProcedureReturn #True
			  EndIf
			  
			Else
			  
			  If X <= ScrollEx()\Button\Backwards\X + ScrollEx()\Button\Backwards\Width
			    ScrollEx()\Thumb\Pos - 1
			    If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Left)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Left)
			    Draw_()
			    ProcedureReturn #True
			  ElseIf X >= ScrollEx()\Button\Forwards\X
			    ScrollEx()\Thumb\Pos + 1
			    If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Right)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Right)
			    Draw_()
			    ProcedureReturn #True
			  ElseIf X < ScrollEx()\Thumb\X
			    ScrollEx()\Thumb\Pos - ScrollEx()\PageLength
			    If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Left)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Left)
			    Draw_()
			    ProcedureReturn #True
			  ElseIf X > ScrollEx()\Thumb\X + ScrollEx()\Thumb\Width
			    ScrollEx()\Thumb\Pos + ScrollEx()\PageLength
			    If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
			    PostEvent(#Event_Gadget,    ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Right)
			    PostEvent(#PB_Event_Gadget, ScrollEx()\Window\Num, ScrollEx()\CanvasNum, #PB_EventType_Change, #Right)
			    Draw_()
			    ProcedureReturn #True
			  EndIf
			  
			EndIf
			
			
		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(ScrollEx(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
			
			;{ ----- Button Focus -----
			If ScrollEx()\Flags & #Vertical
			  
			  If Y <= ScrollEx()\Button\Backwards\Y + ScrollEx()\Button\Backwards\Height
			    ;{ Backwards Button
			    If ScrollEx()\Button\Backwards\State <> #Focus
			      
			      ScrollEx()\Button\Backwards\State = #Focus
			      
			      If ScrollEx()\Thumb\State <> #False
			        ScrollEx()\Thumb\State = #False
			        Draw_()
			      Else 
			        DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards, #Focus)
			      EndIf 
			      
			    EndIf ;}
			    ProcedureReturn #True
			  ElseIf Y >= ScrollEx()\Button\Forwards\Y
			    ;{ Forwards Button
			    If ScrollEx()\Button\Forwards\State <> #Focus
			      
			      ScrollEx()\Button\Forwards\State = #Focus
			      
			      If ScrollEx()\Thumb\State <> #False
			        ScrollEx()\Thumb\State = #False
			        Draw_()
			      Else 
			        DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards, #Focus)
			      EndIf
			      
			    EndIf ;}
			    ProcedureReturn #True
			  EndIf
			  
			  ScrollEx()\Timer = #False
			  
			  If ScrollEx()\Button\Backwards\State <> #False ;{ Backwards Button
			    ScrollEx()\Button\Backwards\State = #False
			    DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards)
  			  ;}
  			EndIf
  			
  			If ScrollEx()\Button\Forwards\State <> #False  ;{ Forwards Button
  			  ScrollEx()\Button\Forwards\State = #False
  			  DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards)
  			  ;}
  			EndIf

			  If Y >= ScrollEx()\Thumb\Y And Y <= ScrollEx()\Thumb\Y + ScrollEx()\Thumb\Height
			    ;{ Move Thumb
			    If ScrollEx()\Cursor <> #PB_Default
			      
			      ScrollEx()\Thumb\Pos + GetSteps_(Y)
			      
			      If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
			      If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
			      
			      ScrollEx()\Cursor = Y
		        
		        Draw_()
		        ProcedureReturn #True
		      EndIf ;}
			    ;{ Thumb Focus
			    If ScrollEx()\Thumb\State <> #Focus
			      ScrollEx()\Thumb\State = #Focus
			      Draw_()
			    EndIf ;} 
			    ProcedureReturn #True
			  EndIf
			  
			Else
			  
			  If X <= ScrollEx()\Button\Backwards\X + ScrollEx()\Button\Backwards\Width
			    ;{ Backwards Button
			    If ScrollEx()\Button\Backwards\State <> #Focus
			      DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards, #Focus)
			      ScrollEx()\Button\Backwards\State = #Focus
			    EndIf ;}
			    ProcedureReturn #True
			  ElseIf X >= ScrollEx()\Button\Forwards\X
			    ;{ Forwards Button
			    If ScrollEx()\Button\Forwards\State <> #Focus
			      DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards, #Focus)
			      ScrollEx()\Button\Forwards\State = #Focus
			    EndIf ;}
			    ProcedureReturn #True
			  EndIf
			  
			  ScrollEx()\Timer = #False
			  
  			If ScrollEx()\Button\Backwards\State <> #False ;{ Backwards Button
  			  DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards)
  			  ScrollEx()\Button\Backwards\State = #False
  			  ;}
  			EndIf
  			
  			If ScrollEx()\Button\Forwards\State <> #False  ;{ Forwards Button
  			  DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards)
  			  ScrollEx()\Button\Forwards\State = #False
  			  ;}
  			EndIf
			  
			  If X >= ScrollEx()\Thumb\X And X <= ScrollEx()\Thumb\X + ScrollEx()\Thumb\Width
			    ;{ Thumb Button
			    If ScrollEx()\Cursor <> #PB_Default

		        ScrollEx()\Thumb\Pos + GetSteps_(X)
		        
		        If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
		        If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
		        
		        ScrollEx()\Cursor = X
		        
		        Draw_()
		        ProcedureReturn #True
		      EndIf ;}
			    ;{ Thumb Focus
			    If ScrollEx()\Thumb\State <> #Focus
			      ScrollEx()\Thumb\State = #Focus
			      Draw_()
			    EndIf ;} 
			    ProcedureReturn #True
			  EndIf
			  
			EndIf ;}
			
			If ScrollEx()\Button\Backwards\State <> #False ;{ Backwards Button
			  DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards)
			  ScrollEx()\Button\Backwards\State = #False
			  ;}
			EndIf
			
			If ScrollEx()\Button\Forwards\State <> #False  ;{ Forwards Button
			  DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards)
			  ScrollEx()\Button\Forwards\State = #False
			  ;}
			EndIf
			
			If ScrollEx()\Thumb\State <> #False            ;{ Thumb Button
			  ScrollEx()\Thumb\State = #False
			  Draw_()
			  ;}
			EndIf
			
			SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure
	
	Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta

    If FindMapElement(ScrollEx(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      ScrollEx()\Thumb\Pos - Delta

      If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
      If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf

      Draw_()
    EndIf
    
  EndProcedure
	
	Procedure _MouseLeaveHandler()
	  Define.i GNum = EventGadget()
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    
	    If ScrollEx()\Button\Backwards\State <> #False
			  DrawButton_(ScrollEx()\Button\Backwards\X, ScrollEx()\Button\Backwards\Y, ScrollEx()\Button\Backwards\Width, ScrollEx()\Button\Backwards\Height, #Backwards)
			  ScrollEx()\Button\Backwards\State = #False
			EndIf
			
			If ScrollEx()\Button\Forwards\State <> #False
			  DrawButton_(ScrollEx()\Button\Forwards\X, ScrollEx()\Button\Forwards\Y, ScrollEx()\Button\Forwards\Width, ScrollEx()\Button\Forwards\Height, #Forwards)
			  ScrollEx()\Button\Forwards\State = #False
			EndIf
			
	    If ScrollEx()\Thumb\State <> #False
	      ScrollEx()\Thumb\State = #False
	      Draw_()
	    EndIf  
			
	  EndIf
	  
	EndProcedure
	
	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(ScrollEx(), Str(GadgetID))
		  CalcThumb()
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach ScrollEx()

			If IsGadget(ScrollEx()\CanvasNum)

				If ScrollEx()\Flags & #AutoResize

					If IsWindow(ScrollEx()\Window\Num)

						OffSetX = WindowWidth(ScrollEx()\Window\Num)  - ScrollEx()\Window\Width
						OffsetY = WindowHeight(ScrollEx()\Window\Num) - ScrollEx()\Window\Height
						
						X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
						
						If ScrollEx()\Flags & #Vertical

							X      = ScrollEx()\Size\X      + OffSetX
							Height = ScrollEx()\Size\Height + OffSetY

							ResizeGadget(ScrollEx()\CanvasNum, X, Y, Width, Height)
						Else

							Y     = ScrollEx()\Size\Y     + OffSetY
							Width = ScrollEx()\Size\Width + OffSetX
						  
							ResizeGadget(ScrollEx()\CanvasNum, X, Y, Width, Height)
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
    
    If FindMapElement(ScrollEx(), Str(GNum))

      ScrollEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 	
  
  
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Minimum.i, Maximum.i, PageLength.i, Flags.i=#False, WindowNum.i=#PB_Default)
		Define Result.i
		
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
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard)
    EndIf
		
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(ScrollEx(), Str(GNum))

				ScrollEx()\CanvasNum = GNum
				
				If WindowNum = #PB_Default
          ScrollEx()\Window\Num = GetGadgetWindow()
        Else
          ScrollEx()\Window\Num = WindowNum
        EndIf
        
        If Thread\Active = #False 
          Thread\Exit   = #False
          Thread\Num    = CreateThread(@_TimerThread(), #Frequency)
          Thread\Active = #True
        EndIf
        
				ScrollEx()\Size\X = X
				ScrollEx()\Size\Y = Y
				ScrollEx()\Size\Width  = Width
				ScrollEx()\Size\Height = Height
				
				ScrollEx()\Minimum    = Minimum
				ScrollEx()\Maximum    = Maximum
				ScrollEx()\PageLength = PageLength
				
				ScrollEx()\Cursor = #PB_Default
				
				ScrollEx()\Button\Forwards\State  = #PB_Default
				ScrollEx()\Button\Backwards\State = #PB_Default
				
				ScrollEx()\Flags  = Flags

				ScrollEx()\Color\Back         = $F0F0F0
				ScrollEx()\Color\Border       = $A0A0A0
				ScrollEx()\Color\Button       = $F0F0F0
				ScrollEx()\Color\Focus        = $D77800
				ScrollEx()\Color\Front        = $646464
				ScrollEx()\Color\Gadget       = $F0F0F0
				ScrollEx()\Color\ScrollBar    = $C8C8C8
				ScrollEx()\Color\DisableFront = $72727D
				ScrollEx()\Color\DisableBack  = $CCCCCA
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						ScrollEx()\Color\Front     = GetSysColor_(#COLOR_GRAYTEXT)
						ScrollEx()\Color\Back      = GetSysColor_(#COLOR_MENU)
						ScrollEx()\Color\Border    = GetSysColor_(#COLOR_3DSHADOW)
						ScrollEx()\Color\Gadget    = GetSysColor_(#COLOR_MENU)
						ScrollEx()\Color\Focus     = GetSysColor_(#COLOR_MENUHILIGHT)
						ScrollEx()\Color\ScrollBar = GetSysColor_(#COLOR_SCROLLBAR)
					CompilerCase #PB_OS_MacOS
						ScrollEx()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						ScrollEx()\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						ScrollEx()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						ScrollEx()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						ScrollEx()\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
						; ScrollEx()\Color\ScrollBar = 
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(ScrollEx()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent(ScrollEx()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
				BindGadgetEvent(ScrollEx()\CanvasNum,  @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
				BindGadgetEvent(ScrollEx()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
				BindGadgetEvent(ScrollEx()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
				
				BindGadgetEvent(ScrollEx()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
				
				BindEvent(#Event_Timer, @_AutoScroll())
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(ScrollEx()\Window\Num)
						ScrollEx()\Window\Width  = WindowWidth(ScrollEx()\Window\Num)
						ScrollEx()\Window\Height = WindowHeight(ScrollEx()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ScrollEx()\Window\Num)
					EndIf
				EndIf ;}
				
				CalcThumb()
				
				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
  Procedure.i GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(ScrollEx(), Str(GNum))
      
      Select Attribute
        Case #Minimum
          ProcedureReturn ScrollEx()\Minimum
        Case #Maximum
          ProcedureReturn ScrollEx()\Maximum
        Case #PageLength
          ProcedureReturn ScrollEx()\PageLength
        Case #Adjust
          ProcedureReturn ScrollEx()\Adjust
        Case #Corner
          ProcedureReturn ScrollEx()\Radius
      EndSelect

    EndIf
    
  EndProcedure
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    ProcedureReturn ScrollEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    ProcedureReturn ScrollEx()\ID
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetState(GNum.i)
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    ProcedureReturn ScrollEx()\Thumb\Pos
	  EndIf
	  
	EndProcedure  
	
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    
	    If State
	      ScrollEx()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      ScrollEx()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(ScrollEx(), Str(GNum))
      
      Select Attribute
        Case #Adjust
          If Value = #PB_Default
            If ScrollEx()\Flags & #Vertical
              Value = GadgetWidth(ScrollEx()\CanvasNum)
            Else  
              Value = GadgetHeight(ScrollEx()\CanvasNum)
            EndIf  
          EndIf 
          ScrollEx()\Adjust     = Value
          CalcThumb()
        Case #Minimum
          ScrollEx()\Minimum    = Value
          CalcThumb()
        Case #Maximum
          ScrollEx()\Maximum    = Value
          CalcThumb()
        Case #PageLength
          ScrollEx()\PageLength = Value
          CalcThumb()
        Case #Corner
          ScrollEx()\Radius     = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure	
	
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(ScrollEx(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          ScrollEx()\Color\Front     = Value
        Case #BackColor
          ScrollEx()\Color\Back      = Value
        Case #BorderColor
          ScrollEx()\Color\Border    = Value
        Case #ButtonColor  
          ScrollEx()\Color\Button    = Value
        Case #FocusColor
          ScrollEx()\Color\Focus     = Value
		    Case #GadgetColor  
		      ScrollEx()\Color\Gadget    = Value
		    Case #ScrollBarColor
		      ScrollEx()\Color\ScrollBar = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    ScrollEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    ScrollEx()\ID = String
	  EndIf
	  
	EndProcedure
	
	Procedure   SetState(GNum.i, State.i)
	  
	  If FindMapElement(ScrollEx(), Str(GNum))
	    ScrollEx()\Thumb\Pos = State
	    If ScrollEx()\Thumb\Pos > ScrollEx()\Thumb\maxPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\maxPos : EndIf
      If ScrollEx()\Thumb\Pos < ScrollEx()\Thumb\minPos : ScrollEx()\Thumb\Pos = ScrollEx()\Thumb\minPos : EndIf
	    Draw_()
	  EndIf
	  
	EndProcedure
	
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #VScrollEx
    #HScrollEx
    #VScroll
    #HScroll
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 200, 180, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    ;ScrollBarGadget(#VScroll, 160, 0, 20, 160, 1, 100, 30, #PB_ScrollBar_Vertical)
    
    If ScrollEx::Gadget(#VScrollEx, 180, 0, 20, 180, 1, 100, 30, ScrollEx::#AutoResize|ScrollEx::#Vertical|ScrollEx::#ThumbBorder|ScrollEx::#ButtonBorder|ScrollEx::#DragLines)
      ; |ScrollEx::#ThumbBorder|ScrollEx::#ButtonBorder|ScrollEx::#DragLines|ScrollEx::#Border
      ScrollEx::SetColor(#VScrollEx, ScrollEx::#ButtonColor, $E3E3E3)
      ScrollEx::SetColor(#VScrollEx, ScrollEx::#BackColor,   $FAFAFA)
      ScrollEx::SetAttribute(#VScrollEx, ScrollEx::#Adjust, #PB_Default) ; Adjusting the scrollbar length when both scrollbars are displayed
      ; ScrollEx::SetAttribute(#VScrollEx, ScrollEx::#Corner, 3)
    EndIf
    
    If ScrollEx::Gadget(#HScrollEx, 0, 160, 200, 20, 1, 100, 80, ScrollEx::#AutoResize|ScrollEx::#ThumbBorder|ScrollEx::#ButtonBorder|ScrollEx::#DragLines)
      ; |ScrollEx::#ThumbBorder|ScrollEx::#ButtonBorder|ScrollEx::#DragLines|ScrollEx::#Border|
      ScrollEx::SetColor(#HScrollEx, ScrollEx::#ButtonColor, $E3E3E3)
      ScrollEx::SetColor(#HScrollEx, ScrollEx::#BackColor,   $FAFAFA)
      ScrollEx::SetAttribute(#HScrollEx, ScrollEx::#Adjust, #PB_Default) ; Adjusting the scrollbar length when both scrollbars are displayed
      ; ScrollEx::SetAttribute(#HScrollEx, ScrollEx::#Corner, 3)
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case ScrollEx::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #VScrollEx
              If EventType() = #PB_EventType_Change 
                Select EventData()
                  Case ScrollEx::#Up
                    Debug "ScrollBar: Up"
                  Case ScrollEx::#Down
                    Debug "ScrollBar: Down"
                EndSelect    
              EndIf
            Case #HScrollEx
              If EventType() = #PB_EventType_Change
                Select EventData()
                  Case ScrollEx::#Left
                    Debug "ScrollBar: Left"
                  Case ScrollEx::#Right
                    Debug "ScrollBar: Right"
                EndSelect 
              EndIf  
          EndSelect ;} 
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 75
; FirstLine = 18
; Folding = 9QAAAAAm5GjgAYAA+
; EnableXP
; DPIAware