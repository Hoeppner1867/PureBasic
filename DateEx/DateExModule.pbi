;/ ============================
;/ =    DateExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ DateEx - Gadget
;/
;/ © 2019  by Thorsten Hoeppner (12/2019)
;/

; Last Update: 03.12.2019

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

;{ ===== Additional tea & pizza license =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ DateEx - Commands _____
; DateEx::GetData()            - similar to 'GetGadgetData()'
; DateEx::GetID()              - similar to 'GetGadgetData()', but it uses a string
; DateEx::SetData()            - similar to 'SetGadgetData()'
; DateEx::SetID()              - similar to 'SetGadgetData()', but it uses a string
; DateEx::DisableReDraw()      - deaktivate/aktivate redrawing
; DateEx::Gadget()             - similar to 'DateGadget()'
; DateEx::GetState()           - similar to 'GetGadgetState()'
; DateEx::GetText()            - similar to 'GetGadgetText()'
; DateEx::Hide()               - similar to 'HideGadget()'
; DateEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; DateEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; DateEx::SetColor()           - similar to 'SetGadgetColor()'
; DateEx::SetFont()            - similar to 'SetGadgetFont()'
; DateEx::SetState()           - similar to 'SetGadgetState()'
; DateEx::SetText()            - similar to 'SetGadgetText()'
;}

; XIncludeFile "ModuleEx.pbi"

CompilerIf Not Defined(Date64, #PB_Module)   : XIncludeFile "Date64Module.pbi"   : CompilerEndIf
CompilerIf Not Defined(Calendar, #PB_Module) : XIncludeFile "CalendarModule.pbi" : CompilerEndIf

DeclareModule DateEx
  
  #Version  = 19120300
  #ModuleEx = 19112100
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	;{ _____ Constants _____
	EnumerationBinary ;{ GadgetFlags
		#AutoResize        ; Automatic resizing of the gadget
		#BorderLess        ; Draw no border
		#NoButton          ; No calendar button
		#UseExistingCanvas ; e.g. for dialogs
	EndEnumeration ;}

	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}
	
	Enumeration 1     ;{ Attribute
	  #Day
	  #Month
	  #Year
	  #Hour
	  #Minute
	  #Second
	  #Corner
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
		#FocusColor
    #HighlightColor
    #HighlightTextColor
	EndEnumeration ;}

	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget     = ModuleEx::#Event_Gadget
		#Event_Theme      = ModuleEx::#Event_Theme
		
		#EventType_Change = ModuleEx::#EventType_Change
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
			#Event_Gadget
		EndEnumeration
		
		Enumeration #PB_EventType_FirstCustomValue
      #EventType_Change
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
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Mask.s="", Date.i=#False, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.q GetState(GNum.i)
  Declare.s GetText(GNum.i, Mask.s="")
  Declare   Hide(GNum.i, State.i=#True)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetFont(GNum.i, FontID.i)
  Declare   SetState(GNum.i, Date.q)
  Declare   SetText(GNum.i, Mask.s)
  
EndDeclareModule

Module DateEx

	EnableExplicit
	
	UsePNGImageDecoder()
  UseZipPacker()
	
	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#ButtonWidth = 25
	
	EnumerationBinary ;{ Button State
    #Focus
    #Click
  EndEnumeration ;}
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	Structure Calendar_Structure        ;{ Calendar\...
	  WindowNum.i
	  GadgetNum.i
	  ImageNum.i
	EndStructure ;} 
	Global Calendar.Calendar_Structure
	
	Calendar\WindowNum = #PB_Default
	

	Structure DateEx_Calendar_Structure ;{ DateEx()\Calendar\...
	  Num.i
	  Window.i
	  X.i
	  Y.i
	  Visible.i
	EndStructure ;}
	
	Structure DateEx_Button_Structure   ;{ DateEx()\Button\...
    X.f
    State.i
    ImgNum.i
    Width.f
    Height.f
    Event.i
  EndStructure ;} 
	
	Structure DateEx_Mask_Structure     ;{ DateEx()\Mask\...
	  Type.i
	  String.s
	  X.i
	  Width.i
	EndStructure ;}
	
	Structure DateEx_Date_Structure     ;{ DateEx()\...\...
	  X.i
	  Width.i
	  Value.i
	EndStructure ;} 
	
	Structure DateEx_Color_Structure    ;{ DateEx()\Color\...
		Front.i
		Back.i
		Border.i
		Gadget.i
		Focus.i
		Button.i
    Highlight.i
    HighlightText.i
		DisableFront.i
		DisableBack.i
	EndStructure  ;}

	Structure DateEx_Window_Structure   ;{ DateEx()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure DateEx_Size_Structure     ;{ DateEx()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}


	Structure DateEx_Structure          ;{ DateEx()\...
	  ID.s
		Quad.i
		
	  CanvasNum.i
	  
		FontID.i
		
    Radius.i
		ReDraw.i
		Hide.i
		Disable.i
		
		DateMask.s
		StartDate.i
		
		Input.i
		Focus.i
		
		Flags.i

		Calendar.DateEx_Calendar_Structure
		Button.DateEx_Button_Structure
		
		Color.DateEx_Color_Structure
		Window.DateEx_Window_Structure
		Size.DateEx_Size_Structure
		
		
		List Mask.DateEx_Mask_Structure()
		Map  MaskIdx.i()
		Map  Date.s()
		
	EndStructure ;}
	Global NewMap DateEx.DateEx_Structure()

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
    Debug "GetGadgetWindow()"
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
	
	
  CompilerIf Defined(Date64, #PB_Module)
    
    Procedure.q AddDate_(Date.q, Type.i, Value.i)
      ProcedureReturn Date64::AddDate_(Date, Type, Value)
    EndProcedure
    
    Procedure.q Date_(Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
      ProcedureReturn Date64::Date_(Year, Month, Day, Hour, Minute, Second)
    EndProcedure
    
    Procedure.i Day_(Date.q)
      ProcedureReturn Date64::Day_(Date)
    EndProcedure
    
    Procedure.i DayOfWeek_(Date.q)
      ProcedureReturn Date64::DayOfWeek_(Date)
    EndProcedure
    
    Procedure.s FormatDate_(Mask.s, Date.q)
      ProcedureReturn Date64::FormatDate_(Mask, Date)
    EndProcedure
    
    Procedure.i Month_(Date.q)
      ProcedureReturn Date64::Month_(Date)
    EndProcedure
    
    Procedure.i Year_(Date.q)
      ProcedureReturn Date64::Year_(Date)
    EndProcedure
    
    Procedure.i Hour_(Date.q) 
      ProcedureReturn Date64::Hour_(Date)
    EndProcedure
    
    Procedure.i Minute_(Date.q) 
      ProcedureReturn Date64::Minute_(Date)
    EndProcedure
    
    Procedure.i Second_(Date.q) 
      ProcedureReturn Date64::Second_(Date)
    EndProcedure
    
  CompilerElse
    
    Procedure.q AddDate_(Date.q, Type.i, Value.i)
      ProcedureReturn AddDate(Date, Type, Value)
    EndProcedure
    
    Procedure.q Date_(Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
      ProcedureReturn Date(Year, Month, Day, Hour, Minute, Second)
    EndProcedure
    
    Procedure.i Day_(Date.q)
      ProcedureReturn Day(Date)
    EndProcedure
    
    Procedure.i DayOfWeek_(Date.q)
      ProcedureReturn DayOfWeek(Date)
    EndProcedure
    
    Procedure.s FormatDate_(Mask.s, Date.q)
      ProcedureReturn FormatDate(Mask, Date)
    EndProcedure
    
    Procedure.i Month_(Date.q)
      ProcedureReturn Month(Date)
    EndProcedure
    
    Procedure.i Year_(Date.q)
      ProcedureReturn Year(Date)
    EndProcedure
    
    Procedure.i Hour_(Date.q) 
      ProcedureReturn Hour(Date)
    EndProcedure
    
    Procedure.i Minute_(Date.q) 
      ProcedureReturn Minute(Date)
    EndProcedure
    
    Procedure.i Second_(Date.q) 
      ProcedureReturn Second(Date)
    EndProcedure
    
  CompilerEndIf
  
  Procedure.i GetDaysOfMonth_(Month.i, Year.i)
    If CountString(DateEx()\DateMask, "%yyyy") = 0 : Year + 2000 : EndIf
    
    If Month = 2 ; 28 or 29 days
      If (Year % 4 = 0 And Year % 100 <> 0) Or Year % 400 = 0 
        ProcedureReturn 29
      Else
        ProcedureReturn 28
      EndIf
    ElseIf (Month < 8 And Month % 2 <> 0) Or (Month > 7 And Month % 2 = 0) ; 31 days
      ProcedureReturn 31
    Else ; 30 days
      ProcedureReturn 30
    EndIf
  
  EndProcedure

  Procedure   ParseDateMask_(Mask.s)
    Define.i p, Pos
    
    ClearList(DateEx()\Mask())
    
    Pos = 1
    
    For p=1 To Len(Mask)
      
      If Mid(Mask, Pos, 1) = "%"
        
        If Mid(Mask, Pos, 5) = "%yyyy" ;{ Year
          
          If AddElement(DateEx()\Mask())
            DateEx()\Mask()\Type   = #Year
            DateEx()\Mask()\String = Mid(Mask, Pos, 5)
            DateEx()\MaskIdx(Str(#Year)) = ListIndex(DateEx()\Mask())
          EndIf 
          
          Pos + 5 ;}
        Else                           ;{ other
          
          If AddElement(DateEx()\Mask())
            Select Mid(Mask, Pos, 3)
              Case "%yy"
                DateEx()\Mask()\Type         = #Year
                DateEx()\Mask()\String       = Mid(Mask, Pos, 3)
                DateEx()\MaskIdx(Str(#Year)) = ListIndex(DateEx()\Mask())
              Case "%mm"
                DateEx()\Mask()\Type          = #Month
                DateEx()\Mask()\String        = Mid(Mask, Pos, 3)
                DateEx()\MaskIdx(Str(#Month)) = ListIndex(DateEx()\Mask())
              Case "%dd"
                DateEx()\Mask()\Type    = #Day
                DateEx()\Mask()\String  = Mid(Mask, Pos, 3)
                DateEx()\MaskIdx(Str(#Day)) = ListIndex(DateEx()\Mask())
              Case "%hh"
                DateEx()\Mask()\Type         = #Hour
                DateEx()\Mask()\String       = Mid(Mask, Pos, 3)
                DateEx()\MaskIdx(Str(#Hour)) = ListIndex(DateEx()\Mask())
              Case "%ii"
                DateEx()\Mask()\Type           = #Minute
                DateEx()\Mask()\String         = Mid(Mask, Pos, 3)
                DateEx()\MaskIdx(Str(#Minute)) = ListIndex(DateEx()\Mask())
              Case "%ss"
                DateEx()\Mask()\Type           = #Second
                DateEx()\Mask()\String         = Mid(Mask, Pos, 3)
                DateEx()\MaskIdx(Str(#Second)) = ListIndex(DateEx()\Mask())
            EndSelect
          EndIf
          Pos + 3 ;}
        EndIf
        
      Else
        If AddElement(DateEx()\Mask())
          DateEx()\Mask()\Type   = #PB_Default
          DateEx()\Mask()\String = Mid(Mask, Pos, 1)
        EndIf  
        Pos + 1
      EndIf
      
      If Pos > Len(Mask) : Break : EndIf
      
    Next
    
  EndProcedure
  
  Procedure   SetDate_(Date.i)
	  
	  DateEx()\Date("%yyyy") = Str(Year_(Date))
	  DateEx()\Date("%yy")   = Right(DateEx()\Date("%yyyy"), 2)
	  DateEx()\Date("%mm")   = RSet(Str(Month_(Date)), 2, "0")
	  DateEx()\Date("%dd")   = RSet(Str(Day_(Date)), 2, "0")
	  DateEx()\Date("%hh")   = RSet(Str(Hour_(Date)), 2, "0")
	  DateEx()\Date("%ii")   = RSet(Str(Minute_(Date)), 2, "0")
	  DateEx()\Date("%ss")   = RSet(Str(Second_(Date)), 2, "0")
	  
	EndProcedure
	
  ;- _____ Calendar ___

	Procedure OpenCalendar_()
	  Define.i Year, Month, Day, Hour, Minute, Second
	  Define.i X, Y
	  
	  X = GadgetX(DateEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
	  Y = GadgetY(DateEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
	  
	  X + DateEx()\Calendar\X
	  Y + DateEx()\Calendar\Y - 1

	  ResizeWindow(DateEx()\Calendar\Window, X, Y, #PB_Ignore,#PB_Ignore )
	  HideWindow(DateEx()\Calendar\Window, #False)
	  
	  SetGadgetData(DateEx()\Calendar\Num, DateEx()\CanvasNum)
	  
  	Year   = Val(DateEx()\Date("%yyyy"))
    Month  = Val(DateEx()\Date("%mm"))
    Day    = Val(DateEx()\Date("%dd"))
    Hour   = Val(DateEx()\Date("%hh"))
    Minute = Val(DateEx()\Date("%ii"))
    Second = Val(DateEx()\Date("%ss"))
	
    Calendar::SetState(DateEx()\Calendar\Num, Date_(Year, Month, Day, Hour, Minute, Second)) 

	  DateEx()\Calendar\Visible = #True
	  
	EndProcedure
	
	Procedure CloseCalendar_()

	  HideWindow(DateEx()\Calendar\Window, #True)
	  DateEx()\Calendar\Visible = #False
	  
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
  
    If DateEx()\Radius
  		RoundBox(X, Y, Width, Height, DateEx()\Radius, DateEx()\Radius, Color)
  	Else
  		Box(X, Y, Width, Height, Color)
  	EndIf
  	
  EndProcedure
	
	Procedure   Button_()
	  Define.i X, Y, BorderColor

    DateEx()\Button\X = dpiX(GadgetWidth(DateEx()\CanvasNum) - #ButtonWidth)

    If DateEx()\Button\State & #Click
      
      DrawingMode(#PB_2DDrawing_Default)
      If DateEx()\Radius
        Line(DateEx()\Button\X, 0, dpiX(1), dpiY(GadgetHeight(DateEx()\CanvasNum)), BorderColor)
        FillArea(DateEx()\Button\X + dpiX(1), dpiX(1), BorderColor, BlendColor_(DateEx()\Color\Focus, DateEx()\Color\Back, 20))
      Else
        Box(DateEx()\Button\X, 0, dpiX(#ButtonWidth), dpiY(GadgetHeight(DateEx()\CanvasNum)), BlendColor_(DateEx()\Color\Focus, DateEx()\Color\Back, 20))
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(DateEx()\Button\X, 0, dpiX(#ButtonWidth), dpiY(GadgetHeight(DateEx()\CanvasNum)), DateEx()\Color\Focus)
      EndIf 
      
    ElseIf DateEx()\Button\State & #Focus
      
      DrawingMode(#PB_2DDrawing_Default)
      If DateEx()\Radius
        DrawingMode(#PB_2DDrawing_Default)
        Line(DateEx()\Button\X, 0, dpiX(1), dpiY(GadgetHeight(DateEx()\CanvasNum)), BorderColor)
        FillArea(DateEx()\Button\X + dpiX(1), dpiX(1), BorderColor, BlendColor_(DateEx()\Color\Focus, DateEx()\Color\Back, 10))
      Else
        Box(DateEx()\Button\X, 0, dpiX(#ButtonWidth), dpiY(GadgetHeight(DateEx()\CanvasNum)), BlendColor_(DateEx()\Color\Focus, DateEx()\Color\Back, 10))
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(DateEx()\Button\X, 0, dpiX(#ButtonWidth), dpiY(GadgetHeight(DateEx()\CanvasNum)), DateEx()\Color\Focus)
      EndIf
    EndIf 
    
    If IsImage(DateEx()\Button\ImgNum)
      X = DateEx()\Button\X + ((dpiX(#ButtonWidth) - DateEx()\Button\Width)  / 2)
      Y = (dpiY(GadgetHeight(DateEx()\CanvasNum))  - DateEx()\Button\Height) / 2
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      DrawImage(ImageID(DateEx()\Button\ImgNum), X, Y, DateEx()\Button\Width, DateEx()\Button\Height)
    EndIf

  EndProcedure

	Procedure   Draw_()
		Define.i X, Y, Width, Height, TextHeight, TextWidth, OffsetX
		Define.i FrontColor.i, BackColor.i, BorderColor.i
		Define.s Text$
		
		If DateEx()\Hide : ProcedureReturn #False : EndIf 

		Width  = dpiX(GadgetWidth(DateEx()\CanvasNum))
		Height = dpiY(GadgetHeight(DateEx()\CanvasNum))

		If StartDrawing(CanvasOutput(DateEx()\CanvasNum))
		  
		  FrontColor  = DateEx()\Color\Front
		  BackColor   = DateEx()\Color\Back
		  BorderColor = DateEx()\Color\Border
		  
		  If DateEx()\Disable
		    FrontColor  = DateEx()\Color\DisableFront
		    BackColor   = DateEx()\Color\DisableBack
		    BorderColor = DateEx()\Color\DisableFront ; or DateEx()\Color\DisableBack
		  EndIf  
		  
			;{ _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  Box(0,  0, Width, Height, DateEx()\Color\Gadget) ; needed for rounded corners
			Box_(0, 0, Width, Height, BackColor)
			;}
			
			CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(0, 0, Width, Height) 
      CompilerEndIf
			
			DrawingFont(DateEx()\FontID)
			
			TextHeight = TextHeight("Abc")
			
			X = dpiX(5)
			Y = (Height - TextHeight) / 2

			ForEach DateEx()\Mask()
			  
			  Select DateEx()\Mask()\Type
			    Case #Year, #Month, #Day
			      Text$ = DateEx()\Date(DateEx()\Mask()\String)
			      DateEx()\Mask()\X = X
			      DateEx()\Mask()\Width = TextWidth(Text$)
			    Case #Hour, #Minute, #Second 
			      Text$ = DateEx()\Date(DateEx()\Mask()\String)
			      DateEx()\Mask()\X = X
			      DateEx()\Mask()\Width = TextWidth(Text$)
			    Default
			      Text$ = DateEx()\Mask()\String
			  EndSelect
			  
			  If DateEx()\Input = DateEx()\Mask()\Type
			    DrawingMode(#PB_2DDrawing_Default)
			    DrawText(X, Y, Text$, DateEx()\Color\HighlightText, DateEx()\Color\Highlight)
			  Else  
  			  DrawingMode(#PB_2DDrawing_Transparent)
  			  DrawText(X, Y, Text$, FrontColor)
			  EndIf
			  
        X + TextWidth(Text$)
			Next  

			;{ _____ Border ____
			If Not DateEx()\Flags & #BorderLess
				DrawingMode(#PB_2DDrawing_Outlined)
				Box_(0, 0, dpiX(GadgetWidth(DateEx()\CanvasNum)), dpiY(GadgetHeight(DateEx()\CanvasNum)), BorderColor)
			EndIf ;}
			
			If Not DateEx()\Flags & #NoButton
			  DateEx()\Button\Height = dpiY(16)
			  DateEx()\Button\Width  = dpiX(16)
			  Button_()
			EndIf
			
			CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput()
      CompilerEndIf
      
			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach DateEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          DateEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf

        DateEx()\Color\Front         = ModuleEx::ThemeGUI\FrontColor
				DateEx()\Color\Back          = ModuleEx::ThemeGUI\BackColor
				DateEx()\Color\Border        = ModuleEx::ThemeGUI\BorderColor
				DateEx()\Color\Gadget        = ModuleEx::ThemeGUI\GadgetColor
				DateEx()\Color\Button        = ModuleEx::ThemeGUI\Button\BackColor
				DateEx()\Color\Focus         = ModuleEx::ThemeGUI\Focus\BackColor
				DateEx()\Color\Highlight     = ModuleEx::ThemeGUI\Focus\BackColor
        DateEx()\Color\HighlightText = ModuleEx::ThemeGUI\Focus\FrontColor
				DateEx()\Color\DisableFront  = ModuleEx::ThemeGUI\Disable\FrontColor
		    DateEx()\Color\DisableBack   = ModuleEx::ThemeGUI\Disable\BackColor
				
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
  
  Procedure _CalendarHandler()
    Define.i CalNum = EventGadget()
    Define.i GNum 
    Define.i Date
    
    If CalNum = Calendar\GadgetNum
      
      GNum = GetGadgetData(CalNum)
      
      If EventType() = Calendar::#EventType_Select

        If FindMapElement(DateEx(), Str(GNum))
          
          Date = Calendar::GetState(CalNum) 
          SetDate_(Date)
          
          CloseCalendar_()
          
          PostEvent(#Event_Gadget,    DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
          
          Draw_()
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure  
  
  
  Procedure _InputHandler()
    Define.s Num$
    Define.i Char, Value, Days
    Define.i GNum = EventGadget()
    
    If FindMapElement(DateEx(), Str(GNum))
      
      If DateEx()\Input ; Item selected
        
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
        If Char >= 48 And Char <= 57
          
          Num$ = Chr(Char)
          
          If FindMapElement(DateEx()\MaskIdx(), Str(DateEx()\Input))
            If SelectElement(DateEx()\Mask(), DateEx()\MaskIdx())
              
              If DateEx()\Mask()\String = "%yyyy"
                If Len(DateEx()\Date("%yyyy")) >= 4 : DateEx()\Date("%yyyy") = "" : EndIf
              Else  
                If Len(DateEx()\Date(DateEx()\Mask()\String)) >= 2 : DateEx()\Date(DateEx()\Mask()\String) = "" : EndIf
              EndIf
              
              Value = Val(DateEx()\Date(DateEx()\Mask()\String) + Num$)
             
              Select DateEx()\Mask()\Type
                Case #Year   ;{ Year
                  If CountString(DateEx()\DateMask, "%yyyy")
                    If Value < 2100
                      DateEx()\Date("%yyyy") + Num$
                      If Len(DateEx()\Date("%yyyy")) = 4 And Value < 1601
                        DateEx()\Date("%yyyy") = "1601"
                      EndIf 
                      DateEx()\Date("%yy") = Right(DateEx()\Date("%yyyy"), 2)
                    Else
                      DateEx()\Date("%yyyy") = "2099"
                      DateEx()\Date("%yy")  = "99"
                    EndIf  
                  Else 
                    If Value < 100
                      DateEx()\Date("%yy") + Num$
                      If Len(DateEx()\Date("%yy")) = 1
                        DateEx()\Date("%yyyy") = "200" + Len(DateEx()\Date("%yy"))
                      Else  
                        DateEx()\Date("%yyyy") = "20"  + Len(DateEx()\Date("%yy"))
                      EndIf  
                    Else
                      DateEx()\Date("%yyyy") = "2099"
                      DateEx()\Date("%yy")   = "99"
                    EndIf 
                  EndIf
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Val(DateEx()\Date("%dd")) > Days : DateEx()\Date("%dd") = Str(Days): EndIf 
                  ;}
                Case #Month  ;{ Month
                  If Value <= 12
                    DateEx()\Date("%mm") + Num$
                  Else   
                    DateEx()\Date("%mm") = "12"
                  EndIf
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Val(DateEx()\Date("%dd")) > Days : DateEx()\Date("%dd") = Str(Days): EndIf 
                  ;}
                Case #Day    ;{ Day
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Value <= Days
                    DateEx()\Date("%dd") + Num$
                  Else
                    DateEx()\Date("%dd") = Str(Days)
                  EndIf ;} 
                Case #Hour   ;{ Hour
                  If Value <= 24
                    DateEx()\Date("%hh") + Num$
                  Else
                    DateEx()\Date("%hh") = "24"
                  EndIf ;}
                Case #Minute ;{ Minute
                  If Value < 60
                    DateEx()\Date("%ii") + Num$
                  Else
                    DateEx()\Date("%ii") = "59"
                  EndIf ;}
                Case #Second ;{ Second
                  If Value < 60
                    DateEx()\Date("%ss") + Num$
                  Else
                    DateEx()\Date("%ss") = "59"
                  EndIf ;}
              EndSelect 
              
              PostEvent(#Event_Gadget,    DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
              
            EndIf
          EndIf    

          Draw_()
        EndIf
        
      EndIf   
        
    EndIf
    
  EndProcedure
  
  Procedure _KeyDownHandler()
    Define.i Key, Modifier, Value, Days
    Define.i GNum = EventGadget()
    
    If FindMapElement(DateEx(), Str(GNum))
      
      Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
      Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
      
      If FindMapElement(DateEx()\MaskIdx(), Str(DateEx()\Input))
        If SelectElement(DateEx()\Mask(), DateEx()\MaskIdx())
        
          Select Key
            Case #PB_Shortcut_Left      ;{ Cursor left
              While PreviousElement(DateEx()\Mask()) 
                If DateEx()\Mask()\Type <> #PB_Default
                  DateEx()\Input = DateEx()\Mask()\Type
                  Break
                EndIf
              Wend
              ;}
            Case #PB_Shortcut_Right     ;{ Cursor right
              While NextElement(DateEx()\Mask()) 
                If DateEx()\Mask()\Type <> #PB_Default
                  DateEx()\Input = DateEx()\Mask()\Type
                  Break
                EndIf
              Wend
              ;} 
            Case #PB_Shortcut_Up        ;{ Cursor up

              Value = Val(DateEx()\Date(DateEx()\Mask()\String)) - 1
             
              Select DateEx()\Mask()\Type
                Case #Year   ;{ Year
                  If CountString(DateEx()\DateMask, "%yyyy")
                    If Value < 1601 : Value = 1601 : EndIf 
                    If Value < 2100
                      DateEx()\Date("%yyyy") = RSet(Str(Value), 4, "0")
                      DateEx()\Date("%yy")   = Right(DateEx()\Date("%yyyy"), 2)
                    Else
                      DateEx()\Date("%yyyy") = "2099"
                      DateEx()\Date("%yy")   = "99"
                    EndIf  
                  Else 
                    If Value < 0 : Value = 0 : EndIf 
                    If Value < 100
                      DateEx()\Date("%yy") = RSet(Str(Value), 2, "0")
                      If Len(DateEx()\Date("%yy")) = 1
                        DateEx()\Date("%yyyy") = "200" + Len(DateEx()\Date("%yy"))
                      Else  
                        DateEx()\Date("%yyyy") = "20"  + Len(DateEx()\Date("%yy"))
                      EndIf  
                    Else
                      DateEx()\Date("%yyyy") = "2099"
                      DateEx()\Date("%yy")   = "99"
                    EndIf 
                  EndIf
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Val(DateEx()\Date("%dd")) > Days : DateEx()\Date("%dd") = Str(Days): EndIf 
                  ;}
                Case #Month  ;{ Month
                  If Value < 1 : Value = 1 : EndIf
                  If Value <= 12
                    DateEx()\Date("%mm") = RSet(Str(Value), 2, "0")
                  Else   
                    DateEx()\Date("%mm") = "12"
                  EndIf
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Val(DateEx()\Date("%dd")) > Days : DateEx()\Date("%dd") = Str(Days): EndIf 
                  ;}
                Case #Day    ;{ Day
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Value < 1 : Value = 1 : EndIf
                  If Value <= Days
                    DateEx()\Date("%dd") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%dd") = Str(Days)
                  EndIf ;} 
                Case #Hour   ;{ Hour
                  If Value < 1 : Value = 1 : EndIf
                  If Value <= 24
                    DateEx()\Date("%hh") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%hh") = "24"
                  EndIf ;}
                Case #Minute ;{ Minute
                  If Value < 0 : Value = 0 : EndIf
                  If Value < 60
                    DateEx()\Date("%ii") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%ii") = "59"
                  EndIf ;}
                Case #Second ;{ Second
                  If Value < 0 : Value = 0 : EndIf
                  If Value < 60
                    DateEx()\Date("%ss") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%ss") = "59"
                  EndIf ;}
              EndSelect 
              
              PostEvent(#Event_Gadget,    DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
           
              Draw_()
              ;}
            Case #PB_Shortcut_Down      ;{ Cursor down
              
              Value = Val(DateEx()\Date(DateEx()\Mask()\String)) + 1
             
              Select DateEx()\Mask()\Type
                Case #Year   ;{ Year
                  If CountString(DateEx()\DateMask, "%yyyy")
                    If Value < 2100
                      If Value < 1601
                        DateEx()\Date("%yyyy") = "1601"
                      Else
                        DateEx()\Date("%yyyy") = RSet(Str(Value), 4, "0")
                      EndIf 
                      DateEx()\Date("%yy") = Right(DateEx()\Date("%yyyy"), 2)
                    Else
                      DateEx()\Date("%yyyy") = "2099"
                      DateEx()\Date("%yy")   = "99"
                    EndIf  
                  Else 
                    If Value < 100
                      DateEx()\Date("%yy") = RSet(Str(Value), 2, "0")
                      If Len(DateEx()\Date("%yy")) = 1
                        DateEx()\Date("%yyyy") = "200" + Len(DateEx()\Date("%yy"))
                      Else  
                        DateEx()\Date("%yyyy") = "20"  + Len(DateEx()\Date("%yy"))
                      EndIf  
                    Else
                      DateEx()\Date("%yyyy") = "2099"
                      DateEx()\Date("%yy")   = "99"
                    EndIf 
                  EndIf
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Val(DateEx()\Date("%dd")) > Days : DateEx()\Date("%dd") = Str(Days): EndIf 
                  ;}
                Case #Month  ;{ Month
                  If Value <= 12
                    DateEx()\Date("%mm") = RSet(Str(Value), 2, "0")
                  Else   
                    DateEx()\Date("%mm") = "12"
                  EndIf
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Val(DateEx()\Date("%dd")) > Days : DateEx()\Date("%dd") = Str(Days): EndIf 
                  ;}
                Case #Day    ;{ Day
                  Days = GetDaysOfMonth_(Val(DateEx()\Date("%mm")), Val(DateEx()\Date("%yyyy")))
                  If Value <= Days
                    DateEx()\Date("%dd") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%dd") = Str(Days)
                  EndIf ;} 
                Case #Hour   ;{ Hour
                  If Value <= 24
                    DateEx()\Date("%hh") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%hh") = "24"
                  EndIf ;}
                Case #Minute ;{ Minute
                  If Value < 60
                    DateEx()\Date("%ii") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%ii") = "59"
                  EndIf ;}
                Case #Second ;{ Second
                  If Value < 60
                    DateEx()\Date("%ss") = RSet(Str(Value), 2, "0")
                  Else
                    DateEx()\Date("%ss") = "59"
                  EndIf ;}
              EndSelect 
              
              PostEvent(#Event_Gadget,    DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, DateEx()\Window\Num, DateEx()\CanvasNum, #EventType_Change)
           
              Draw_()
              ;}
          EndSelect
        
        EndIf
      EndIf
      
      Draw_()
      
    EndIf

  EndProcedure
  
  
	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(DateEx(), Str(GNum))

			X = GetGadgetAttribute(DateEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(DateEx()\CanvasNum, #PB_Canvas_MouseY)
			
			If Not DateEx()\Flags & #NoButton
			  
			  If X > DateEx()\Button\X And X < DateEx()\Button\X + dpiX(#ButtonWidth)
			    
			    If DateEx()\Button\State <> #Click
  			    DateEx()\Button\State = #Click
  			    Draw_()
  			  EndIf
			  
			    ProcedureReturn #True
			  EndIf
			  
			  If DateEx()\Button\State <> #False
			    DateEx()\Button\State = #False
			    Draw_()
			  EndIf
			  
			  If DateEx()\Calendar\Visible
			    CloseCalendar_()
			  EndIf   
			  
			EndIf  
			
			ForEach DateEx()\Mask()
			  
			  If X > DateEx()\Mask()\X And X < DateEx()\Mask()\X + DateEx()\Mask()\Width
			    DateEx()\Input = DateEx()\Mask()\Type
			    Draw_()
			    ProcedureReturn #True
			  EndIf
			  
			Next

			DateEx()\Input = #False
			
			Draw_()
		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, Y, Angle
		Define.i GNum = EventGadget()

		If FindMapElement(DateEx(), Str(GNum))

			X = GetGadgetAttribute(DateEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(DateEx()\CanvasNum, #PB_Canvas_MouseY)
			
			If Not DateEx()\Flags & #NoButton
			  
			  If X > DateEx()\Button\X And X < DateEx()\Button\X + dpiX(#ButtonWidth)
			    
			    If DateEx()\Calendar\Visible = #False
			      OpenCalendar_()
			    EndIf
			    
			  EndIf
			  
			  If DateEx()\Button\State <> #False
			    DateEx()\Button\State = #False
			    Draw_()
			  EndIf
			  
			EndIf  
      
		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(DateEx(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
			
			If Not DateEx()\Flags & #NoButton
			  
			  If X > DateEx()\Button\X And X < DateEx()\Button\X + dpiX(#ButtonWidth)
			    
			    If DateEx()\Button\State <> #Focus
  			    DateEx()\Button\State = #Focus
  			    Draw_()
  			  EndIf
			  
			    ProcedureReturn #True
			  EndIf
			  
			  If DateEx()\Button\State <> #False
			    DateEx()\Button\State = #False
			    Draw_()
			  EndIf
			  
			EndIf  
			
			ForEach DateEx()\Mask()
			  If X > DateEx()\Mask()\X And X < DateEx()\Mask()\X + DateEx()\Mask()\Width
			    If Not DateEx()\Focus
			      DateEx()\Focus = DateEx()\Mask()\Type
			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			    EndIf
			    ProcedureReturn #True
			  EndIf
			Next

		  If DateEx()\Focus
		    DateEx()\Focus = #False
		    SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
		  EndIf  

		EndIf

	EndProcedure
	
	Procedure _MouseLeaveHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(DateEx(), Str(GNum))

      If DateEx()\Button\State <> #False
		    DateEx()\Button\State = #False
		    Draw_()
		  EndIf 
		  
    EndIf
    
  EndProcedure 
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(DateEx(), Str(GNum))
      
      If DateEx()\Calendar\Visible
        CloseCalendar_()
        Draw_()
			EndIf
		  
    EndIf
    
  EndProcedure 
  
	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(DateEx(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach DateEx()

			If IsGadget(DateEx()\CanvasNum)

				If DateEx()\Flags & #AutoResize

					If IsWindow(DateEx()\Window\Num)

						OffSetX = WindowWidth(DateEx()\Window\Num)  - DateEx()\Window\Width
						OffsetY = WindowHeight(DateEx()\Window\Num) - DateEx()\Window\Height

						If DateEx()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If DateEx()\Size\Flags & #MoveX  : X = DateEx()\Size\X + OffSetX : EndIf
							If DateEx()\Size\Flags & #MoveY  : Y = DateEx()\Size\Y + OffSetY : EndIf
							If DateEx()\Size\Flags & #Width  : Width  = DateEx()\Size\Width + OffSetX : EndIf
							If DateEx()\Size\Flags & #Height : Height = DateEx()\Size\Height + OffSetY : EndIf

							ResizeGadget(DateEx()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(DateEx()\CanvasNum, #PB_Ignore, #PB_Ignore, DateEx()\Size\Width + OffSetX, DateEx()\Size\Height + OffsetY)
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
	
	Procedure.i InitCalendar_()
	  Define *Buffer
	  
    If IsImage(Calendar\ImageNum) = #False
  	  
  	  *Buffer = AllocateMemory(1124)
  	  If *Buffer
  	    If UncompressMemory(?Image, 991, *Buffer, 1124) <> -1
  	      Calendar\ImageNum = CatchImage(#PB_Any, *Buffer, 1124)
  	    EndIf
  	    FreeMemory(*Buffer)
  	  EndIf 
  	  
  	EndIf
  	
    DateEx()\Calendar\Window = OpenWindow(#PB_Any, 0, 0, 210, 160, "", #PB_Window_BorderLess|#PB_Window_Invisible, WindowID(DateEx()\Window\Num))
    If DateEx()\Calendar\Window
      
      DateEx()\Calendar\Num = Calendar::Gadget(#PB_Any, 0, 0, #PB_Default, #PB_Default, #PB_Default, DateEx()\Calendar\Window)
	    If DateEx()\Calendar\Num
	      DateEx()\Button\ImgNum = Calendar\ImageNum
	    EndIf
	    
	  EndIf  
  	
	EndProcedure  	
	
	
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(DateEx(), Str(GNum))
	    ProcedureReturn DateEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(DateEx(), Str(GNum))
	    ProcedureReturn DateEx()\ID
	  EndIf
	  
	EndProcedure

  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(DateEx(), Str(GNum))
	    DateEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(DateEx(), Str(GNum))
	    DateEx()\ID = String
	  EndIf
	  
	EndProcedure
	
	
	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(DateEx(), Str(GNum))

      DateEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 	
	
	Procedure   DisableReDraw(GNum.i, State.i=#False)

		If FindMapElement(DateEx(), Str(GNum))

			If State
				DateEx()\ReDraw = #False
			Else
				DateEx()\ReDraw = #True
				Draw_()
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Mask.s="", Date.i=#False, Flags.i=#False, WindowNum.i=#PB_Default)
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
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard)
    EndIf
		
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(DateEx(), Str(GNum))

				DateEx()\CanvasNum = GNum
				
				InitCalendar_()
				
				If WindowNum = #PB_Default
          DateEx()\Window\Num = GetGadgetWindow()
        Else
          DateEx()\Window\Num = WindowNum
        EndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						DateEx()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							DateEx()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						DateEx()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				DateEx()\Size\X = X
				DateEx()\Size\Y = Y
				DateEx()\Size\Width  = Width 
				DateEx()\Size\Height = Height
				
				DateEx()\Calendar\X  = 0
				DateEx()\Calendar\Y  = Height
				
				If Mask
				  DateEx()\DateMask = Mask
				Else  
				  DateEx()\DateMask = "%dd.%mm.%yyyy"
				EndIf
				ParseDateMask_(DateEx()\DateMask)
				
				If Date
				  DateEx()\StartDate = Date
				Else
				  DateEx()\StartDate = Date()
				EndIf
				SetDate_(DateEx()\StartDate)
				
				DateEx()\Flags  = Flags

				DateEx()\ReDraw = #True

				DateEx()\Color\Front         = $000000
				DateEx()\Color\Back          = $FFFFFF
				DateEx()\Color\Gadget        = $F0F0F0
				DateEx()\Color\Border        = $A0A0A0
				DateEx()\Color\Button        = $E3E3E3
				DateEx()\Color\Focus         = $D77800
				DateEx()\Color\Highlight     = $D77800
        DateEx()\Color\HighlightText = $FFFFFF
				DateEx()\Color\DisableFront  = $72727D
				DateEx()\Color\DisableBack   = $CCCCCA
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						DateEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
						DateEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
						DateEx()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
						DateEx()\Color\Gadget        = GetSysColor_(#COLOR_MENU)
						DateEx()\Color\Button        = GetSysColor_(#COLOR_3DLIGHT)
						DateEx()\Color\Focus         = GetSysColor_(#COLOR_HIGHLIGHT)
				    DateEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
            DateEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
					CompilerCase #PB_OS_MacOS
						DateEx()\Color\Front     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						DateEx()\Color\Back      = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
						DateEx()\Color\Border    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						DateEx()\Color\Button    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
						DateEx()\Color\Gadget    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						DateEx()\Color\Focus     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				    DateEx()\Color\Highlight = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(DateEx()\CanvasNum, @_ResizeHandler(),         #PB_EventType_Resize)
				BindGadgetEvent(DateEx()\CanvasNum, @_MouseMoveHandler(),      #PB_EventType_MouseMove)
				BindGadgetEvent(DateEx()\CanvasNum, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)
				BindGadgetEvent(DateEx()\CanvasNum, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
				BindGadgetEvent(DateEx()\CanvasNum, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
				BindGadgetEvent(DateEx()\CanvasNum, @_InputHandler(),          #PB_EventType_Input)
				BindGadgetEvent(DateEx()\CanvasNum, @_KeyDownHandler(),        #PB_EventType_KeyDown)
				BindGadgetEvent(DateEx()\CanvasNum, @_LostFocusHandler(),      #PB_EventType_LostFocus)

				BindEvent(Calendar::#Event_Gadget, @_CalendarHandler())
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(DateEx()\Window\Num)
						DateEx()\Window\Width  = WindowWidth(DateEx()\Window\Num)
						DateEx()\Window\Height = WindowHeight(DateEx()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), DateEx()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.q GetState(GNum.i)
	  Define.i Year, Month, Day, Hour, Minute, Second
	  
	  If FindMapElement(DateEx(), Str(GNum))
	    
	    Year   = Val(DateEx()\Date("%yyyy"))
	    Month  = Val(DateEx()\Date("%mm"))
	    Day    = Val(DateEx()\Date("%dd"))
	    Hour   = Val(DateEx()\Date("%hh"))
	    Minute = Val(DateEx()\Date("%ii"))
	    Second = Val(DateEx()\Date("%ss"))
	    
      ProcedureReturn Date_(Year, Month, Day, Hour, Minute, Second)
    EndIf
    
  EndProcedure  
  
  Procedure.s GetText(GNum.i, Mask.s="")
    Define.s Date$
    
    If FindMapElement(DateEx(), Str(GNum))
      
      If Mask = "" : Mask = DateEx()\DateMask : EndIf 
      
      Date$ = ReplaceString(Mask,  "%yyyy", DateEx()\Date("%yyyy"))
      Date$ = ReplaceString(Date$, "%yy",   DateEx()\Date("%yy"))
      Date$ = ReplaceString(Date$, "%mm",   DateEx()\Date("%mm"))
      Date$ = ReplaceString(Date$, "%dd",   DateEx()\Date("%dd"))
      Date$ = ReplaceString(Date$, "%hh",   DateEx()\Date("%hh"))
      Date$ = ReplaceString(Date$, "%ii",   DateEx()\Date("%ii"))
      Date$ = ReplaceString(Date$, "%ss",   DateEx()\Date("%ss"))
      
      ProcedureReturn Date$
    EndIf
    
  EndProcedure 
  
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(DateEx(), Str(GNum))
	    
	    If State
	      DateEx()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      DateEx()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(DateEx(), Str(GNum))
      
      Select Attribute
        Case #Corner
          DateEx()\Radius  = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure	
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(DateEx(), Str(GNum))
      
      DateEx()\Size\Flags = Flags
      DateEx()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(DateEx(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          DateEx()\Color\Front  = Value
        Case #BackColor
          DateEx()\Color\Back   = Value
        Case #BorderColor
          DateEx()\Color\Border = Value
      EndSelect
      
      If DateEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i) 
    
    If FindMapElement(DateEx(), Str(GNum))
      
      DateEx()\FontID = FontID
      
      If DateEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetState(GNum.i, Date.q)
    
    If FindMapElement(DateEx(), Str(GNum))
      
      SetDate_(Date)
      
      If DateEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetText(GNum.i, Mask.s)
    
    If FindMapElement(DateEx(), Str(GNum))
      
      DateEx()\DateMask = Mask
			ParseDateMask_(DateEx()\DateMask)
      
      If DateEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  ;{ _____ Image _____
  ; Source:  Oxygen Icons - http://www.oxygen-icons.org/
  ; License: http://creativecommons.org/licenses/by-sa/3.0/ or http://creativecommons.org/licenses/LGPL/2.1/
  
  DataSection
    Image:
    Data.q $E5E773F00CEB9C78,$F4F5E0606062E292,$C1CC2002D2020970,$52044FFF3FE52406,$1B0C0C8EBE8EE92C,$8CF902B224FFB9FB,
           $C9CEEB0C4EEE41C5,$7C823D92147204BC,$5A1A1818D4AA1819,$305E1A85017E1818,$604ABC30301A9430,$305E20C0C19AB060,
           $C92D82500DA05767,$EF3A7E0C0185DDDB,$C5911E059C5207AE,$C693A33083AFAB40,$3A63815960900AEC,$661ED6C7310C21CC,
           $B10C7174F5926060,$A3B0B66392773D38,$36CF37BBCDFAF1C8,$6BE82150B815DAD9,$05432B979122FF10,$9A6FF6F55C96E5F8,
           $AFAA861FC07DEB77,$5FAABCB51D9CB342,$BDA4B2A23D14D52C,$6EA6AF758B905D89,$4F37DD9325F7945B,$FD5E9049376BCDE6,
           $B3CDB1B57EEDBE48,$DD37040498F369FF,$399CC674B1A0C35C,$7929E99CCF173221,$1E1B3B6FCAE572B4,$D13BB18D48DFF5A9,
           $E9E769A37C71155C,$45181C050BCB4C7B,$D3F7EE97096A7E95,$D36F5582BBC4E99A,$576733EBD17D2D11,$E662B96A70FB7DD8,
           $BEFEE44E8E9B65AA,$0F3EE9E5C7BA6AC5,$DA3DED4E3B59B367,$1EBF93A3E9EA4375,$7355AEF4FAAA8ACC,$91F9E8E9053E71D6,
           $D2EE7BA97642D33C,$8BDB1CE76EB7EA5F,$09C833DE9697F9DE,$5BDBD56B2F315F2B,$E8533D5EAF8CD572,$7B5B82C1F071DA7B,
           $DF703D389A2AF88F,$305CC47F6A27CB61,$4EDFCFB9EEC66531,$DFCDE1FF76F9EF37,$2CCD1EDFACDE73CB,$BC1EF7DFEDE773A3,
           $C54C03257B0E855A,$EC28FBA6DD1D6F6C,$980F3C26D9D585CC,$B02C6DB3D7D85F7D,$A3407CE7FE72AFEE,$369FA7E0808374A1,
           $C8F614653BC5E20E,$A7985ABBA85DCE2D,$571E79C9F92243BB,$BE3EF3D8141F2995,$42E44358372DBB7E,$9EB70BD3F4E1B954,
           $7A7BB4717BA3B3FD,$41671E553E8B43CF,$130206E3A9134CC1,$EA0C6E9CF79A9A1D,$8BFB577AF1D8DA4A,$3BCC574FA7D3B94A,
           $CDBDDFADCB2FE7FA,$238F9D4C1C2A5D1A,$0E8ACFB34FDBEE6A,$D1953A7A9DCD8A8A,$D72DD52F14CC976D,$196B7A0F23226362,
           $34645A32B2369F95,$7FF10BC547EC47D3,$AAAAA94F6DB7F7AE,$88603512EF28F312,$5AE9957F12FFE2C9,$1CF9EFFCC773DDE3,
           $62980E273C289C9E,$528B924A235C4B54,$8304805375524B13,$AEA1A1AEA5818191,$918195B9A18869A1,$B0619001AE89B195,
           $A548034C109F79ED,$AE81A18350174415,$95A5818861835001,$E703442991958991,$29F9B90D140CD495,$DE745435B8956999,
           $93E0D20E90D402BD,$5190CA9C579A9C99,$2BB60FAFA5605252,$3F37373F39352CB3,$073F5D28BF2F58AF,$38B752A93F58A4A2,
           $BF215F40CF58DF51,$3E01EE3E1D188148,$36FDD1FA867A46FA,$0A14879C423730C9,$864621E646BA1606,$06BA66465686A656,
           $0F3EEEAB2A374066,$5A5F9C10D20C20D4,$9E99515FE0CA9C94,$8DE6B40C99E0A79A,$4847506676603AC4,$5E517CC0F90687C7,
           $999BAD560F97AE5E,$41A755F37BD4730C,$539D65CFD5D3DC79
    Data.b $42,$13,$00,$AF,$39,$AA,$D5
    ImageEnd:
  EndDataSection ;}
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #Date
    #DateEx
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 220, 45, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    DateGadget(#Date, 10, 10, 100, 25, "%yyyy/%mm/%dd")
    
    If DateEx::Gadget(#DateEx, 120, 10, 90, 25, "%yyyy/%mm/%dd")
      
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case DateEx::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #DateEx
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
    
    ;Debug DateEx::GetText(#DateEx)
    
    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 134
; FirstLine = 64
; Folding = 5hPAMQAAAGAKAQofAACAAi
; EnableXP
; DPIAware