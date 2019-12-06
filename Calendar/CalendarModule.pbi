;/ ============================
;/ =    CalendarModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Calendar - Gadget 
;/
;/ © 2019 Thorsten1867 (11/2019)
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


;{ _____ Calendar - Commands _____

; Calendar::DefaultCountry()     - set default language for all gadgets
; Calendar::Disable()            - similar to 'DisableGadget()'
; Calendar::DisableReDraw()      - disable/enable redrawing of the gadget
; Calendar::Gadget()             - similar to 'CalendarGadget()'
; Calendar::GetAttribute()       - similar to 'GetGadgetAttribute()'
; Calendar::GetData()            - similar to 'GetGadgetData()'
; Calendar::GetDate()            - similar to 'Date()', but 64Bit
; Calendar::GetDay()             - returns selected day
; Calendar::GetID()              - similar to 'GetGadgetData()', but string instead of quad
; Calendar::GetMonth()           - returns selected month
; Calendar::GetState()           - similar to 'GetGadgetState()'
; Calendar::GetText()            - similar to 'GetGadgetText()'
; Calendar::GetYear()            - returns selected year
; Calendar::Hide()               - similar to 'HideGadget()'
; Calendar::MonthName()          - returns name of month in the current language
; Calendar::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; Calendar::SetColor()           - similar to 'SetGadgetColor()'
; Calendar::SetData()            - similar to 'SetGadgetData()'
; Calendar::SetDate()            - set date
; Calendar::SetFont()            - similar to 'SetGadgetFont()'
; Calendar::SetID()              - similar to 'SetGadgetData()', but string instead of quad
; Calendar::SetState()           - similar to 'SetGadgetState()'
; Calendar::WeekDayName()        - returns name of weekday in the current language

;}

;XIncludeFile "ModuleEx.pbi"

CompilerIf Not Defined(Date64, #PB_Module)  : XIncludeFile "Date64Module.pbi" : CompilerEndIf

DeclareModule Calendar
  
  #Version  = 19120600
  #ModuleEx = 19120600

  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  EnumerationBinary ;{ GadgetFlags
    #AutoResize        ; Automatic resizing of the gadget
    #BorderLess        ; Draw no border  
    #UseExistingCanvas
  EndEnumeration ;}
  
  Enumeration 1     ;{ Attribute
    #Spacing ; Horizontal spacing for month name
  EndEnumeration ;}
  
  Enumeration 1     ;{ FontType
    #Font_Gadget
    #Font_Month
    #Font_WeekDays
  EndEnumeration ;}
  
  Enumeration 1     ;{ FlagType
    #Year
    #Month
    #Gadget
  EndEnumeration ;}
  
  EnumerationBinary ;{ AutoResize
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration ;} 
  
  Enumeration 1     ;{ Color
    #ArrowColor
    #BackColor
    #BorderColor
    #FocusColor
    #FrontColor
    #TodayColor
    #GreyTextColor
    #LineColor
    #Month_FrontColor
    #Month_BackColor
    #Week_FrontColor
    #Week_BackColor
  EndEnumeration ;}

  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Cursor     = ModuleEx::#Event_Cursor
    #Event_Gadget     = ModuleEx::#Event_Gadget
    #Event_Theme      = ModuleEx::#Event_Theme
    
    #EventType_Select = ModuleEx::#EventType_Select
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Select
    EndEnumeration
    
  CompilerEndIf


  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================

  Declare   DefaultCountry(Code.s)
  Declare   Disable(GNum.i, State.i=#True)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i=#PB_Default, Height.i=#PB_Default, Date.i=#PB_Default, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.q GetData(GNum.i)
  Declare.q GetDate(Day.i, Month.i, Year.i, Hour.i=0, Minute.i=0, Second.i=0)
  Declare.i GetDay(GNum.i)
  Declare.i GetMonth(GNum.i)
  Declare.s GetID(GNum.i)
  Declare.i GetState(GNum.i)
  Declare.s GetText(GNum.i, Mask.s="")
  Declare.i GetYear(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   MonthName(Month.i, Name.s)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetDate(GNum.i, Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
  Declare   SetFont(GNum.i, FontNum.i, FontType.i=#Font_Gadget)
  Declare   SetID(GNum.i, String.s)
  Declare   SetState(GNum.i, Date.q)
  Declare   WeekDayName(WeekDay.i, Name.s)
  
EndDeclareModule

Module Calendar
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================ 
  
  #CursorFrequency = 600

  #ScrollBarSize = 16
  
  #NotValid = -1
  
  #MonthOfYear = 1
  #WeekDays    = 2
  
  #Previous = 1
  #Next     = 2
  #Change   = 1
 
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================

  Structure Border_Structure              ;{
    Day.i
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure ;}

  Structure Font_Structure                ;{ \Font\...
    Num.i
    Name.s
    Size.i
    Style.i
  EndStructure ;}
  
  Structure Color_Structure               ;{ ...\Color\...
    Front.i
    Back.i
    Grid.i
  EndStructure  ;}
  
  Structure Cursor_Thread_Structure       ;{ Thread\...
    Num.i
    Active.i
    Exit.i
  EndStructure ;}
  
  
  Structure ListView_Scroll_Structure     ;{ Calendar()\ListView\Scroll\...
    Num.i
    Position.f
    Hide.i
  EndStructure ;}
  
  Structure ListView_Item_Structure       ;{ Calendar()\ListView\Item()\...
    ID.s
    Y.i
    String.s
  EndStructure ;}
  
  Structure Calendar_ListView_Structure   ;{ Calendar()\ListView\...
    X.f
    Y.f
    Width.f
    Height.f
    Offset.i
    RowHeight.i
    FontID.i
    FrontColor.i
    Focus.i
    State.i
    Visible.i
    ScrollBar.ListView_Scroll_Structure
    List Item.ListView_Item_Structure()
  EndStructure ;}
  
  
  Structure Calendar_Cursor_Structure     ;{ Calendar()\Cursor\...
    X.i
    Y.i
    Pos.i
    Height.i
    State.i
    Frequency.i
    Thread.i
    FrontColor.i
    BackColor.i
  EndStructure ;}
  
  Structure Calendar_String_Structure     ;{ Calendar()\String\...
    X.f
    Y.f
    Width.f
    Height.f
    Text.s
    CursorPos.i
    FontID.i
    FrontColor.i
    Visible.i
  EndStructure ;}
  
  
  Structure Button_Size_Structure        ;{ Calendar()\Button\...
    prevX.i
    nextX.i
    Y.i
    Width.i
    Height.i
  EndStructure  ;}

  Structure Calendar_Day_Structure       ;{ Calendar()\Day\...
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure ;}
  
  Structure Calendar_Month_Structure     ;{ Calendar()\Month\...
    X.i
    Y.i
    Width.i
    Height.i
    listY.i
    Spacing.i
    Font.i
    Flags.i
    State.i
    Color.Color_Structure
    Map Name.s()
  EndStructure ;}
  
  Structure Calendar_Year_Structure      ;{ Calendar()\Year\...
    X.i
    Y.i
    Width.i
    Height.i
    Minimum.i
    Maximum.i
    State.i
    Flags.i
  EndStructure ;}
  
  Structure Calendar_Week_Structure      ;{ Calendar()\Week\...
    Y.i
    Height.i
    Font.i
    Color.Color_Structure
    Map Day.s()
  EndStructure ;}
  
  Structure Calendar_Current_Structure   ;{ Calendar()\Current\...
    Date.q
    Focus.i
    Month.i
    Year.i
  EndStructure ;}
  
  Structure Calendar_Color_Structure     ;{ Calendar()\Color\...
    Front.i
    Back.i
    Border.i
    Gadget.i
    Grid.i
    Arrow.i
    FocusBack.i
    FocusText.i
    GreyText.i
    Today.i
    DisableFront.i
    DisableBack.i
  EndStructure  ;}
  
  Structure Calendar_Window_Structure    ;{ Calendar()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure Calendar_Size_Structure      ;{ Calendar()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Flags.i
  EndStructure ;} 
  
  Structure Calendar_Structure           ;{ Calendar()\...
    ID.s
		Quad.i
    
    CanvasNum.i
    
    FontID.i

    ReDraw.i
    Disable.i
    Hide.i
    
    Flags.i
    
    Size.Calendar_Size_Structure
    Window.Calendar_Window_Structure
    Color.Calendar_Color_Structure
    
    Current.Calendar_Current_Structure
    Year.Calendar_Year_Structure
    Month.Calendar_Month_Structure
    Week.Calendar_Week_Structure
    
    
    Button.Button_Size_Structure
    Cursor.Calendar_Cursor_Structure
    String.Calendar_String_Structure
    ListView.Calendar_ListView_Structure
    
    Map Day.Calendar_Day_Structure()
    Map PopUpItem.s()
    
  EndStructure ;}
  Global NewMap Calendar.Calendar_Structure()
  
  Global CountryCode.s
  Global NewMap NameOfMonth.s(), NewMap NameOfWeekDay.s()
  
  Global Thread.Cursor_Thread_Structure
  
  ;- ============================================================================
  ;-   Module - Date 32Bit / 64Bit
  ;- ============================================================================  
  
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
    
  CompilerEndIf
  
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

  
  Procedure   MonthNames_(Code.s="")
	  
    Select Code
      Case "AT"
	      Calendar()\Month\Name("1")  = "Jänner"
	      Calendar()\Month\Name("2")  = "Februar"
	      Calendar()\Month\Name("3")  = "März"
	      Calendar()\Month\Name("4")  = "April"
	      Calendar()\Month\Name("5")  = "Mai"
	      Calendar()\Month\Name("6")  = "Juni"
	      Calendar()\Month\Name("7")  = "Juli"
	      Calendar()\Month\Name("8")  = "August"
	      Calendar()\Month\Name("9")  = "September"
	      Calendar()\Month\Name("10") = "Oktober"
	      Calendar()\Month\Name("11") = "November"
	      Calendar()\Month\Name("12") = "Dezember"  
	    Case "DE"
	      Calendar()\Month\Name("1")  = "Januar"
	      Calendar()\Month\Name("2")  = "Februar"
	      Calendar()\Month\Name("3")  = "März"
	      Calendar()\Month\Name("4")  = "April"
	      Calendar()\Month\Name("5")  = "Mai"
	      Calendar()\Month\Name("6")  = "Juni"
	      Calendar()\Month\Name("7")  = "Juli"
	      Calendar()\Month\Name("8")  = "August"
	      Calendar()\Month\Name("9")  = "September"
	      Calendar()\Month\Name("10") = "Oktober"
	      Calendar()\Month\Name("11") = "November"
	      Calendar()\Month\Name("12") = "Dezember"
	    Case "ES"
	      Calendar()\Month\Name("1")  = "enero"
	      Calendar()\Month\Name("2")  = "febrero"
	      Calendar()\Month\Name("3")  = "marzo"
	      Calendar()\Month\Name("4")  = "abril"
	      Calendar()\Month\Name("5")  = "mayo"
	      Calendar()\Month\Name("6")  = "junio"
	      Calendar()\Month\Name("7")  = "julio"
	      Calendar()\Month\Name("8")  = "agosto"
	      Calendar()\Month\Name("9")  = "septiembre"
	      Calendar()\Month\Name("10") = "octubre"
	      Calendar()\Month\Name("11") = "noviembre"
	      Calendar()\Month\Name("12") = "diciembre"
	    Case "FR"
	      Calendar()\Month\Name("1")  = "Janvier"
	      Calendar()\Month\Name("2")  = "Février"
	      Calendar()\Month\Name("3")  = "Mars"
	      Calendar()\Month\Name("4")  = "Avril"
	      Calendar()\Month\Name("5")  = "Mai"
	      Calendar()\Month\Name("6")  = "Juin"
	      Calendar()\Month\Name("7")  = "Juillet"
	      Calendar()\Month\Name("8")  = "Août"
	      Calendar()\Month\Name("9")  = "Septembre"
	      Calendar()\Month\Name("10") = "Octobre"
	      Calendar()\Month\Name("11") = "Novembre"
	      Calendar()\Month\Name("12") = "Décembre"
	    Case "GB", "US"
        Calendar()\Month\Name("1")  = "January"
	      Calendar()\Month\Name("2")  = "February"
	      Calendar()\Month\Name("3")  = "March"
	      Calendar()\Month\Name("4")  = "April"
	      Calendar()\Month\Name("5")  = "May"
	      Calendar()\Month\Name("6")  = "June"
	      Calendar()\Month\Name("7")  = "July"
	      Calendar()\Month\Name("8")  = "August"
	      Calendar()\Month\Name("9")  = "September"
	      Calendar()\Month\Name("10") = "October"
	      Calendar()\Month\Name("11") = "November"
	      Calendar()\Month\Name("12") = "December"
	    Default
	      If MapSize(NameOfMonth())
	        Calendar()\Month\Name("1")  = NameOfMonth("1")
  	      Calendar()\Month\Name("2")  = NameOfMonth("2")
  	      Calendar()\Month\Name("3")  = NameOfMonth("3")
  	      Calendar()\Month\Name("4")  = NameOfMonth("4")
  	      Calendar()\Month\Name("5")  = NameOfMonth("5")
  	      Calendar()\Month\Name("6")  = NameOfMonth("6")
  	      Calendar()\Month\Name("7")  = NameOfMonth("7")
  	      Calendar()\Month\Name("8")  = NameOfMonth("8")
  	      Calendar()\Month\Name("9")  = NameOfMonth("9")
  	      Calendar()\Month\Name("10") = NameOfMonth("10")
  	      Calendar()\Month\Name("11") = NameOfMonth("11")
  	      Calendar()\Month\Name("12") = NameOfMonth("12")
	      Else
  	      Calendar()\Month\Name("1")  = "January"
  	      Calendar()\Month\Name("2")  = "February"
  	      Calendar()\Month\Name("3")  = "March"
  	      Calendar()\Month\Name("4")  = "April"
  	      Calendar()\Month\Name("5")  = "May"
  	      Calendar()\Month\Name("6")  = "June"
  	      Calendar()\Month\Name("7")  = "July"
  	      Calendar()\Month\Name("8")  = "August"
  	      Calendar()\Month\Name("9")  = "September"
  	      Calendar()\Month\Name("10") = "October"
  	      Calendar()\Month\Name("11") = "November"
  	      Calendar()\Month\Name("12") = "December"
	      EndIf
	  EndSelect
	  
	EndProcedure
  
  Procedure   WeekDayNames_(Code.s="")
	  
	  Select Code
	    Case "DE", "AT"
	      Calendar()\Week\Day("1") = "Mo."
	      Calendar()\Week\Day("2") = "Di."
	      Calendar()\Week\Day("3") = "Mi."
	      Calendar()\Week\Day("4") = "Do."
	      Calendar()\Week\Day("5") = "Fr."
	      Calendar()\Week\Day("6") = "Sa."
	      Calendar()\Week\Day("7") = "So."
	    Case "ES"
	      Calendar()\Week\Day("1") = "Lun"
	      Calendar()\Week\Day("2") = "Mar"
	      Calendar()\Week\Day("3") = "Mié"
	      Calendar()\Week\Day("4") = "Jue"
	      Calendar()\Week\Day("5") = "Vie"
	      Calendar()\Week\Day("6") = "Sáb"
	      Calendar()\Week\Day("7") = "Dom"
	    Case "FR"
	      Calendar()\Week\Day("1") = "Lu."
	      Calendar()\Week\Day("2") = "Ma."
	      Calendar()\Week\Day("3") = "Me."
	      Calendar()\Week\Day("4") = "Je."
	      Calendar()\Week\Day("5") = "Ve."
	      Calendar()\Week\Day("6") = "Sa."
	      Calendar()\Week\Day("7") = "Di."
	    Case "GB", "US"
        Calendar()\Week\Day("1") = "Mon"
	      Calendar()\Week\Day("2") = "Tue"
	      Calendar()\Week\Day("3") = "Wed"
	      Calendar()\Week\Day("4") = "Thu"
	      Calendar()\Week\Day("5") = "Fri"
	      Calendar()\Week\Day("6") = "Sat"
	      Calendar()\Week\Day("7") = "Sun"
	    Default
	      If MapSize(NameOfWeekDay())
	        Calendar()\Week\Day("1") = NameOfWeekDay("1")
  	      Calendar()\Week\Day("2") = NameOfWeekDay("2") 
  	      Calendar()\Week\Day("3") = NameOfWeekDay("3") 
  	      Calendar()\Week\Day("4") = NameOfWeekDay("4") 
  	      Calendar()\Week\Day("5") = NameOfWeekDay("5") 
  	      Calendar()\Week\Day("6") = NameOfWeekDay("6") 
  	      Calendar()\Week\Day("7") = NameOfWeekDay("7") 
	      Else
  	      Calendar()\Week\Day("1") = "Mo."
  	      Calendar()\Week\Day("2") = "Tu."
  	      Calendar()\Week\Day("3") = "We."
  	      Calendar()\Week\Day("4") = "Th."
  	      Calendar()\Week\Day("5") = "Fr."
  	      Calendar()\Week\Day("6") = "Sa."
  	      Calendar()\Week\Day("7") = "Su."
  	    EndIf
  	    
  	    Calendar()\Week\Day("0") = Calendar()\Week\Day("1")
  	    
	  EndSelect
	  
	EndProcedure
	
	
	Procedure.i GetColor_(Color.i, DefaultColor.i)
	  
	  If Color = #PB_Default
	    ProcedureReturn DefaultColor
	  Else
	    ProcedureReturn Color
	  EndIf
	  
	EndProcedure
	
	Procedure   SetFont_(FontNum.i)
	  
	  If IsFont(FontNum)
	    DrawingFont(FontID(FontNum))
	  Else
	    DrawingFont(Calendar()\FontID)
	  EndIf
	  
	EndProcedure
	
	Procedure.q FirstCalendarDay(Month.i, Year.i)
	  Define.i DayDiff
	  Define.q FirstDay, FirstCalendarDay
	  
	  FirstDay = Date_(Year, Month, 1, 0, 0, 0)
	  
	  DayDiff  = -DayOfWeek_(firstDay) + 1
	  If DayDiff > 0 : DayDiff - 7 : EndIf
	  
	  ProcedureReturn Day_(AddDate_(FirstDay, #PB_Date_Day, DayDiff))
  EndProcedure 
	
  Procedure.i LastDayOfMonth_(Month.i, Year.i)
    Define.q Date
    
    Date = Date_(Year, Month, 1, 0, 0, 0)

	  ProcedureReturn Day_(AddDate_(AddDate_(Date, #PB_Date_Month, 1), #PB_Date_Day, -1))
	EndProcedure
	
	Procedure.i FirstWeekDay_(Month.i, Year.i)
	  Define.i DayOfWeek
	  
	  DayOfWeek = DayOfWeek_(Date_(Year, Month, 1, 0, 0, 0))
	  If DayOfWeek = 0 : DayOfWeek = 7 : EndIf
	  
	  ProcedureReturn DayOfWeek
	EndProcedure
	
	Procedure.i Today_(Month.i, Year.i) 
	  Define.q tDate = Date()
	  
	  If Year_(tDate) = Year
	    If Month_(tDate) = Month
	      ProcedureReturn Day_(tDate)
	    EndIf  
	  EndIf 
	  
	  ProcedureReturn #False
	EndProcedure
	
	Procedure.s DeleteStringPart_(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf
    
    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure
  
	;- ______ Drawing __________
	
  Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
    Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
    Define.f Blend = Factor / 100
    
    Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
    Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)
    
    ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
  EndProcedure	
  
	Procedure.i Arrow_(X.i, Y.i, Width.i, Height.i, Direction.i, Color.i=#False)
	  Define.i Color
	  
	  If Color = #False : Color = Calendar()\Color\Arrow : EndIf

	 
    Calendar()\Button\Width  = dpiX(3)
    Calendar()\Button\Height = dpiX(6)
    
    Calendar()\Button\Y = Y + (Height - Calendar()\Button\Height) / 2
    
    If Calendar()\Button\Width < Width And Calendar()\Button\Height < Height 
      
      Select Direction
        Case #Previous

          Calendar()\Button\prevX = X + Calendar()\Month\Spacing

          DrawingMode(#PB_2DDrawing_Default)
          LineXY(Calendar()\Button\prevX, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Calendar()\Button\prevX + Calendar()\Button\Width, Calendar()\Button\Y, Color)
          LineXY(Calendar()\Button\prevX, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Calendar()\Button\prevX + Calendar()\Button\Width, Calendar()\Button\Y + Calendar()\Button\Height, Color)
          Line(Calendar()\Button\prevX + Calendar()\Button\Width, Calendar()\Button\Y, 1, Calendar()\Button\Height, Color)
          FillArea(Calendar()\Button\prevX + Calendar()\Button\Width - dpix(2), Calendar()\Button\Y + (Calendar()\Button\Height / 2), -1, Color)
          
        Case #Next

          Calendar()\Button\nextX = X + Width - Calendar()\Button\Width - Calendar()\Month\Spacing

          DrawingMode(#PB_2DDrawing_Default)
          Line(Calendar()\Button\nextX, Calendar()\Button\Y, 1, Calendar()\Button\Height, Color)
          LineXY(Calendar()\Button\nextX, Calendar()\Button\Y, Calendar()\Button\nextX + Calendar()\Button\Width, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Color)
          LineXY(Calendar()\Button\nextX, Calendar()\Button\Y + Calendar()\Button\Height, Calendar()\Button\nextX + Calendar()\Button\Width, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Color)
          FillArea(Calendar()\Button\nextX + dpix(2), Calendar()\Button\Y + (Calendar()\Button\Height / 2), -1, Color)
          
      EndSelect

    EndIf
    
  EndProcedure
  
  Procedure   DrawListView_()
    Define.i X, Y, RowHeight, maxHeight, PageRows, sX, sY
    Define.i FrontColor, BackColor, BorderColor
    
    If Calendar()\ListView\Visible = #False : ProcedureReturn #False : EndIf 
    
    ;{ --- Color --- 
    FrontColor  = Calendar()\ListView\FrontColor
    BackColor   = Calendar()\Color\Back
    BorderColor = BlendColor_(Calendar()\Color\Border, Calendar()\Color\FocusBack)
    ;}
    
    If StartDrawing(CanvasOutput(Calendar()\CanvasNum))
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(Calendar()\ListView\X, Calendar()\ListView\Y, Calendar()\ListView\Width, Calendar()\ListView\Height, BackColor)
      ;}
      
      X = Calendar()\ListView\X + dpiX(5)
      Y = Calendar()\ListView\Y + dpiY(1)
      
      DrawingFont(Calendar()\ListView\FontID)
      
      ;{ _____ ScrollBar _____
      RowHeight = TextHeight("Abc")
      PageRows  = Calendar()\ListView\Height / RowHeight

      If PageRows < 12
        
        If Calendar()\ListView\ScrollBar\Hide
          
          If IsGadget(Calendar()\ListView\ScrollBar\Num)
            sX = DesktopUnscaledX(Calendar()\ListView\X  + Calendar()\ListView\Width) - #ScrollBarSize - 1
            sY = DesktopUnscaledY(Calendar()\ListView\Y) + 1
            SetGadgetAttribute(Calendar()\ListView\ScrollBar\Num, #PB_ScrollBar_PageLength, PageRows)
            ResizeGadget(Calendar()\ListView\ScrollBar\Num, sX, sY, #PB_Ignore, DesktopUnscaledY(Calendar()\ListView\Height) - 2)
            HideGadget(Calendar()\ListView\ScrollBar\Num, #False)
            Calendar()\ListView\ScrollBar\Hide = #False
          EndIf
          
        EndIf  
        
      EndIf ;}
      
      ;{ _____ Rows _____
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(Calendar()\ListView\X, Calendar()\ListView\Y, Calendar()\ListView\Width - dpiX(3), Calendar()\ListView\Height) 
      CompilerEndIf
      
      DrawingMode(#PB_2DDrawing_Transparent)

      ForEach Calendar()\ListView\Item()

        If ListIndex(Calendar()\ListView\Item()) < Calendar()\ListView\Offset - 1
          Calendar()\ListView\Item()\Y = 0
          Continue
        EndIf  
        
        If Calendar()\ListView\State = ListIndex(Calendar()\ListView\Item())
          Box(X - dpiX(2), Y, Calendar()\ListView\Width - dpiX(6), RowHeight, Calendar()\Color\FocusBack)
          DrawText(X, Y, Calendar()\ListView\Item()\String, Calendar()\Color\FocusText)
        Else
          If Calendar()\ListView\Focus = ListIndex(Calendar()\ListView\Item())
            Box(X - dpiX(3), Y, TextWidth(Calendar()\ListView\Item()\String) + dpiX(6), RowHeight, BlendColor_(Calendar()\Color\FocusBack, BackColor, 10))
          EndIf
          DrawText(X, Y, Calendar()\ListView\Item()\String, FrontColor)
        EndIf
        
        Calendar()\ListView\Item()\Y = Y
        Y + RowHeight
        If Y > Calendar()\ListView\Y + Calendar()\ListView\Height : Break : EndIf
      Next
      
      Calendar()\ListView\RowHeight = RowHeight
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput() 
      CompilerEndIf
      ;}

      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(Calendar()\ListView\X, Calendar()\ListView\Y, Calendar()\ListView\Width, Calendar()\ListView\Height, BorderColor)
      ;}
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  Procedure   DrawString_()
    Define.i p, PosX, PosY, txtHeight, CursorX
    Define.i FrontColor, BackColor, BorderColor
    Define.s Text
    
    If Calendar()\String\Visible = #False : ProcedureReturn #False : EndIf 
    
    ;{ --- Color --- 
    FrontColor  = Calendar()\String\FrontColor
    BackColor   = Calendar()\Color\Back
    BorderColor = BlendColor_(Calendar()\Color\Border, Calendar()\Color\FocusBack, 10)
    ;}
    
    If StartDrawing(CanvasOutput(Calendar()\CanvasNum))
      
      DrawingFont(Calendar()\String\FontID)

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(Calendar()\String\X, Calendar()\String\Y, Calendar()\String\Width, Calendar()\String\Height, BackColor)
      ;}
      
      Text      = Calendar()\String\Text
      txtHeight = TextHeight(Calendar()\String\Text)
      
      PosX    = Calendar()\String\X + dpiX(3)
      PosY    = Calendar()\String\Y + ((Calendar()\String\Height - txtHeight) / 2) 
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(Calendar()\String\X, Calendar()\String\Y, Calendar()\String\Width, Calendar()\String\Height) 
      CompilerEndIf
    
      Calendar()\Cursor\X          = PosX + TextWidth(Left(Text, Calendar()\String\CursorPos)) - 1
      Calendar()\Cursor\Pos        = Calendar()\String\CursorPos
      Calendar()\Cursor\Y          = PosY
      Calendar()\Cursor\Height     = txtHeight
      Calendar()\Cursor\FrontColor = FrontColor
      Calendar()\Cursor\BackColor  = BackColor

      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(PosX, PosY, Text, FrontColor)

      Line(Calendar()\Cursor\X, PosY, 1, txtHeight, Calendar()\Color\Front)
      Calendar()\Cursor\State = #True
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput()
      CompilerEndIf
      
      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(Calendar()\String\X, Calendar()\String\Y, Calendar()\String\Width, Calendar()\String\Height, BorderColor)
      ;}
      
      StopDrawing()
    EndIf
  
  EndProcedure  
  
  Procedure   Draw_()
    Define.i X, Y, Width, Height, PosX, PosY, txtX, txtY, TextHeight, calcHeight
    Define.i c, r, Column, Row, ColumnWidth, RowHeight, bWidth, bHeight
    Define.i Date, Month, Year, Day, GreyDay, FirstWeekDay, LastDay, CurrentDate, Entries
    Define.i FrontColor, BackColor, BorderColor, MonthColor, WeekColor, GridColor 
    Define.s Text$, Month$, Year$, ToolTipMask$
    Define Focus.Border_Structure, Today.Border_Structure
    
    If Calendar()\Hide : ProcedureReturn #False : EndIf

    Width  = dpiX(GadgetWidth(Calendar()\CanvasNum))
    Height = dpiY(GadgetHeight(Calendar()\CanvasNum))

    If StartDrawing(CanvasOutput(Calendar()\CanvasNum))
      
      ;{ _____ Color _____
      FrontColor  = Calendar()\Color\Front
      BackColor   = Calendar()\Color\Back
      BorderColor = Calendar()\Color\Border
      MonthColor  = Calendar()\Month\Color\Back
      WeekColor   = Calendar()\Week\Color\Back
      GridColor   = Calendar()\Color\Grid
      
      If Calendar()\Disable
        FrontColor  = Calendar()\Color\DisableFront
        BackColor   = BlendColor_(Calendar()\Color\DisableBack, Calendar()\Color\Gadget, 10)
        BorderColor = Calendar()\Color\DisableFront
        GridColor   = Calendar()\Color\DisableFront
        MonthColor  = BackColor
        WeekColor   = BackColor
      EndIf ;}
      
      ColumnWidth = Round(Width  / 7, #PB_Round_Down)  ; Days of week
      Width       = ColumnWidth *  7
      
      DrawingFont(Calendar()\FontID)
      
      ;{ _____ Calc Height _____
      TextHeight = TextHeight("Abc")
      
      Calendar()\Year\Height  = TextHeight + dpiY(6)
      Calendar()\Month\Height = TextHeight + dpiY(6)
      Calendar()\Week\Height  = TextHeight + dpiY(4)

      calcHeight = Height - Calendar()\Month\Height - Calendar()\Week\Height
      RowHeight  = Round(calcHeight / 6, #PB_Round_Down)

      Calendar()\Month\Height + (calcHeight - (RowHeight * 6))
      ;}
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, dpiX(GadgetWidth(Calendar()\CanvasNum)), dpiY(GadgetHeight(Calendar()\CanvasNum)), Calendar()\Color\Gadget)
      Box(0, 0, Width, Height, BackColor)
      ;}

      Month = Calendar()\Current\Month
      Year  = Calendar()\Current\Year
      
      FirstWeekDay = FirstWeekDay_(Month, Year)
      LastDay      = LastDayOfMonth_(Month, Year)
      GreyDay      = FirstCalendarDay(Month.i, Year.i)
      
      If Calendar()\Disable
        Focus\Day = 0
        Today\Day = 0
      Else  
        Focus\Day = Day_(Calendar()\Current\Focus)
        Today\Day = Today_(Month, Year)
      EndIf
      
      Focus\X = #NotValid
      Focus\Y = #NotValid
      
      PosY = Y
      Day  = 1
      
      PushMapPosition(Calendar()\Day())
      
      For r=1 To 8
        
        If r < 8
          bHeight = RowHeight + dpiY(1)
        Else
          bHeight = RowHeight
        EndIf 
        
        Select r
          Case #MonthOfYear ;{ Month & Year
            SetFont_(Calendar()\Month\Font)

            Month$ = Calendar()\Month\Name(Str(Calendar()\Current\Month))
            Year$  = Str(Calendar()\Current\Year)
            
            PosX = (Width - TextWidth(Month$) - dpiX(5) - TextWidth(Year$)) / 2
            txtY = (Calendar()\Month\Height - TextHeight) / 2
            
            If Not Calendar()\Disable
              FrontColor = GetColor_(Calendar()\Month\Color\Front, FrontColor)
            EndIf
          
            If Calendar()\Month\Color\Back <> #PB_Default
              DrawingMode(#PB_2DDrawing_Default)
              Box(X, PosY, Width, Calendar()\Month\Height, MonthColor)
            EndIf

            Calendar()\Month\X = PosX
            Calendar()\Month\Y = PosY
            Calendar()\Month\Width = TextWidth(Month$)
            Calendar()\Month\listY = PosY+ txtY + TextHeight + dpiY(1)
            
            DrawingMode(#PB_2DDrawing_Transparent) 
            PosX = DrawText(PosX, PosY + txtY, Month$, FrontColor)
            PosX + dpiX(5)
            
            Calendar()\Year\X = PosX
            Calendar()\Year\Y = PosY
            Calendar()\Year\Width = TextWidth(Year$)
            
            DrawText(PosX, PosY + txtY, Year$, FrontColor)
            
            DrawingMode(#PB_2DDrawing_Outlined) 
            Box(X, PosY, Width, Calendar()\Month\Height + dpiY(1), GridColor)
            
            PosY + Calendar()\Month\Height
            ;}
          Case #WeekDays    ;{ Weekdays
            
            SetFont_(Calendar()\Week\Font)

            PosX = X
            TextHeight = TextHeight("Abc")
            txtY       = (Calendar()\Week\Height - TextHeight) / 2
            
            If Not Calendar()\Disable
              FrontColor = GetColor_(Calendar()\Week\Color\Front, Calendar()\Color\Front)
            EndIf 
            
            If Calendar()\Month\Color\Back <> #PB_Default
              DrawingMode(#PB_2DDrawing_Default)
              Box(X, PosY, Width, Calendar()\Week\Height, WeekColor)
            EndIf
            
            For c=1 To 7

              Text$ = Calendar()\Week\Day(Str(c))
              txtX  = (ColumnWidth - TextWidth(Text$)) / 2 + dpiY(1)
              
              DrawingMode(#PB_2DDrawing_Transparent) 
              DrawText(PosX + txtX, PosY + txtY, Text$, FrontColor)
              
              If Not Calendar()\Disable
                If Calendar()\Week\Color\Grid <> #PB_Default
                  BorderColor = Calendar()\Week\Color\Grid
                Else
                  BorderColor = GridColor
                EndIf  
              EndIf
              
              DrawingMode(#PB_2DDrawing_Outlined) 
              If c =  7
                Box(PosX, PosY, ColumnWidth, Calendar()\Week\Height + dpiY(1), BorderColor)
              Else
                Box(PosX, PosY, ColumnWidth + dpiX(1), Calendar()\Week\Height + dpiY(1), BorderColor)
              EndIf   
              
              PosX + ColumnWidth
            Next
            
            PosY + Calendar()\Week\Height
            ;}
          Default           ;{ Days

            PosX = X

            For c=1 To 7
              
              If c < 7 
                bWidth = ColumnWidth + dpiX(1)
              Else
                bWidth = ColumnWidth
              EndIf   

              txtY = (RowHeight - TextHeight) / 2

              If Day = 1 And c <> FirstWeekDay ;{ Skip weekdays < day 

                Text$ = Str(GreyDay)
                txtX  = (ColumnWidth - TextWidth("33")) / 2 + (TextWidth("33") - TextWidth(Text$))
                DrawingMode(#PB_2DDrawing_Transparent) 
                DrawText(PosX + txtX, PosY + txtY, Text$, Calendar()\Color\GreyText)
                GreyDay + 1

                DrawingMode(#PB_2DDrawing_Outlined) 
                Box(PosX, PosY, ColumnWidth + dpiX(1), RowHeight + dpiY(1), GridColor)
                
                PosX + ColumnWidth
                Continue 
              EndIf ;}

              If Day <= LastDay
                
                Text$ = Str(Day)
                txtX  = (ColumnWidth - TextWidth("33")) / 2 + (TextWidth("33") - TextWidth(Text$))
                
                If Not Calendar()\Disable
                  FrontColor = Calendar()\Color\Front
                  BackColor  = Calendar()\Color\Back
                EndIf
                
                If Day = Today\Day
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(PosX, PosY, bWidth, bHeight, BlendColor_(Calendar()\Color\Today, BackColor, 6))
                  Today\X = PosX
                  Today\Y = PosY
                  Today\Width  = bWidth
                  Today\Height = bHeight
                EndIf 
                
                If Day = Focus\Day ;{ Draw focus
                  If Month = Month_(Calendar()\Current\Focus) And Year = Year_(Calendar()\Current\Focus)
                    DrawingMode(#PB_2DDrawing_Default)
                    Box(PosX, PosY, bWidth, bHeight, BlendColor_(Calendar()\Color\FocusBack, BackColor, 10))
                    Focus\X = PosX
                    Focus\Y = PosY
                    Focus\Width  = bWidth
                    Focus\Height = bHeight
                  EndIf
                EndIf ;}

                DrawingMode(#PB_2DDrawing_Transparent) 
                DrawText(PosX + txtX, PosY + txtY, Text$, FrontColor)

                Calendar()\Day(Str(Day))\X      = PosX
                Calendar()\Day(Str(Day))\Y      = PosY
                Calendar()\Day(Str(Day))\Width  = ColumnWidth
                Calendar()\Day(Str(Day))\Height = RowHeight
                
                If Day = LastDay : GreyDay = 1 : EndIf
                
                Day + 1
              Else
                
                Calendar()\Day(Str(Day))\X = #False
                Calendar()\Day(Str(Day))\Y = #False
                Calendar()\Day(Str(Day))\Width  = #False
                Calendar()\Day(Str(Day))\Height = #False

                Text$ = Str(GreyDay)
                txtX  = (ColumnWidth - TextWidth("33")) / 2 + (TextWidth("33") - TextWidth(Text$))
                DrawingMode(#PB_2DDrawing_Transparent) 
                DrawText(PosX + txtX + dpiY(1), PosY + txtY, Text$, Calendar()\Color\GreyText)
                GreyDay + 1
                
                Day + 1
              EndIf

              DrawingMode(#PB_2DDrawing_Outlined) 
              Box(PosX, PosY, bWidth, bHeight, GridColor)   
              
              PosX + ColumnWidth
            Next

            PosY + RowHeight
            ;}
        EndSelect

      Next
      
      PopMapPosition(Calendar()\Day())
      
      If Today\Day
        DrawingMode(#PB_2DDrawing_Outlined) 
        Box(Today\X, Today\Y, Today\Width, Today\Height, BlendColor_(Calendar()\Color\Today, GridColor, 40))
      EndIf 
      
      ;{ Draw Focus Border
      If Focus\X <> #NotValid And Focus\Y <> #NotValid 
        DrawingMode(#PB_2DDrawing_Outlined) 
        Box(Focus\X, Focus\Y, Focus\Width, Focus\Height, BlendColor_(Calendar()\Color\FocusBack, GridColor, 60))
      EndIf
      ;}
      
      Arrow_(X, Y, Width, Calendar()\Month\Height, #Previous)
      Arrow_(X, Y, Width, Calendar()\Month\Height, #Next)

      ;{ _____ Border ____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, Width, Height, GridColor)
      If Not Calendar()\Flags & #BorderLess
        If Calendar()\Disable
          Box(0, 0, dpiX(GadgetWidth(Calendar()\CanvasNum)), dpiY(GadgetHeight(Calendar()\CanvasNum)), BorderColor)
        Else
          Box(0, 0, dpiX(GadgetWidth(Calendar()\CanvasNum)), dpiY(GadgetHeight(Calendar()\CanvasNum)), Calendar()\Color\Border)
        EndIf  
      EndIf ;}
      
      StopDrawing()
    EndIf 
    
  EndProcedure
  
  ;- __________ Event Procedures __________
  
  
  Procedure  ChangeYear_(State.i=#True)
    Define.i Year, OffsetY, FontID
    
    If State
      
      OffsetY = (Calendar()\Month\Height - Calendar()\Year\Height + dpiY(2)) / 2
      
      Calendar()\String\X          = Calendar()\Year\X - dpiX(2)
      Calendar()\String\Y          = Calendar()\Year\Y + OffsetY
      Calendar()\String\Width      = Calendar()\Year\Width + dpiX(6)
      Calendar()\String\Height     = Calendar()\Year\Height - dpiY(2)
      Calendar()\String\Text       = Str(Calendar()\Current\Year)
      Calendar()\String\FrontColor = Calendar()\Color\Front
      Calendar()\String\Visible       = #True

      If IsFont(Calendar()\Month\Font)
        Calendar()\String\FontID = FontID(Calendar()\Month\Font)
      Else
        Calendar()\String\FontID = Calendar()\FontID
      EndIf
      
      DrawString_()
      
      Calendar()\Year\State = #Change
    Else
      
      Year = Val(Calendar()\String\Text)
      If Year > 1600 And Year < 2100
        
        Calendar()\String\Visible = #False

        Calendar()\Current\Year  = Year
        Calendar()\Current\Date  = Date_(Year, Calendar()\Current\Month, 1, 0, 0, 0)
        
        Calendar()\Year\State = #False
        
        Draw_()

      Else
        Calendar()\String\FrontColor = #Red
        DrawString_()
      EndIf 
    
    EndIf
    
  EndProcedure
  
  Procedure  ChangeMonth_(State.i=#True)
    Define.i Month
    
    If State
      
      Calendar()\ListView\X              = Calendar()\Month\X
      Calendar()\ListView\Y              = Calendar()\Month\listY
      Calendar()\ListView\Width          = dpiX(90)
      Calendar()\ListView\Height         = dpiY(GadgetHeight(Calendar()\CanvasNum)) - Calendar()\Month\Height - dpiY(5)
      Calendar()\ListView\FrontColor     = Calendar()\Color\Front
      Calendar()\ListView\FontID         = Calendar()\FontID
      Calendar()\ListView\Visible        = #True
      Calendar()\ListView\State          = Calendar()\Current\Month - 1
      Calendar()\ListView\Focus          = #PB_Default
      Calendar()\ListView\ScrollBar\Hide = #True
      
      DrawListView_()
      
      Calendar()\Month\State = #Change
      
    Else
      
      Calendar()\ListView\Visible = #False
      Calendar()\Month\State      = #False
      
      HideGadget(Calendar()\ListView\ScrollBar\Num, #True)
      
      Month = Calendar()\ListView\State + 1
      If Month >= 1 And Month <= 12
        Calendar()\Current\Month = Month
        Calendar()\Current\Date  = Date_(Calendar()\Current\Year, Month, 1, 0, 0, 0)
      EndIf

      Draw_()
    EndIf 
    
  EndProcedure
 
  ;- __________ Events __________
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach Calendar()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          Calendar()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        Calendar()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
        Calendar()\Color\Back         = ModuleEx::ThemeGUI\BackColor
        Calendar()\Color\Grid         = ModuleEx::ThemeGUI\LineColor
        Calendar()\Color\Arrow        = ModuleEx::ThemeGUI\Button\BackColor
        Calendar()\Color\FocusText    = ModuleEx::ThemeGUI\Focus\FrontColor
        Calendar()\Color\FocusBack    = ModuleEx::ThemeGUI\Focus\BackColor
        Calendar()\Month\Color\Front  = ModuleEx::ThemeGUI\Title\FrontColor
        Calendar()\Month\Color\Back   = ModuleEx::ThemeGUI\Title\BackColor
        Calendar()\Week\Color\Front   = ModuleEx::ThemeGUI\Header\FrontColor
        Calendar()\Week\Color\Back    = ModuleEx::ThemeGUI\Header\LightColor
        Calendar()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
        Calendar()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
        Calendar()\Color\GreyText     = ModuleEx::ThemeGUI\GreyTextColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure _CursorDrawing() ; Trigger from Thread (PostEvent Change)
    Define.i WindowNum = EventWindow()
    
    ForEach Calendar()

      If Calendar()\String\Visible

        Calendar()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(Calendar()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          If Calendar()\Cursor\State
            Line(Calendar()\Cursor\X, Calendar()\Cursor\Y, 1, Calendar()\Cursor\Height, Calendar()\Cursor\FrontColor)
          Else
            Line(Calendar()\Cursor\X, Calendar()\Cursor\Y, 1, Calendar()\Cursor\Height, Calendar()\Cursor\BackColor)
          EndIf
          StopDrawing()
        EndIf

      EndIf
      
    Next
    
  EndProcedure 
  
  Procedure _CursorThread(Frequency.i)
    Define.i ElapsedTime
    
    Repeat
      
      If ElapsedTime >= Frequency
        PostEvent(#Event_Cursor)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until Thread\Exit
    
  EndProcedure
  
  Procedure _InputHandler()
    Define   Char.i, Char$
    Define.i GNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GNum))

      If Calendar()\String\Visible

        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
        If Char >= 48 And Char <= 57
          
          Char$ = Chr(Char)
          
          If Len(Calendar()\String\Text) = 4
            
            If Calendar()\String\CursorPos < 4
              Calendar()\String\Text = Left(Calendar()\String\Text, Calendar()\String\CursorPos) + Char$ + Mid(Calendar()\String\Text, Calendar()\String\CursorPos + 2)
              Calendar()\String\CursorPos + 1  
            EndIf   

          Else 
            Calendar()\String\CursorPos + 1  
            Calendar()\String\Text = InsertString(Calendar()\String\Text, Char$, Calendar()\String\CursorPos)
          EndIf
          
          If Len(Calendar()\String\Text) = 4
            If Val(Calendar()\String\Text) > 1600 And Val(Calendar()\String\Text) < 2100
              Calendar()\String\FrontColor = Calendar()\Color\Front
            Else
              Calendar()\String\FrontColor = #Red
            EndIf   
          Else
            Calendar()\String\FrontColor = Calendar()\Color\Front
          EndIf  
          
          DrawString_()
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure   
  
  Procedure _KeyDownHandler()
    Define.i Key
    Define.i GNum = EventGadget()

    If FindMapElement(Calendar(), Str(GNum))
      
      Key= GetGadgetAttribute(GNum, #PB_Canvas_Key)
      
      Select Key
        Case #PB_Shortcut_Left     ;{ Left
          If Calendar()\String\CursorPos > 0
            Calendar()\String\CursorPos - 1
          EndIf
          ;}
        Case #PB_Shortcut_Right    ;{ Right
          If Calendar()\String\CursorPos < Len(Calendar()\String\Text)
            Calendar()\String\CursorPos + 1
          EndIf  
          ;}
        Case #PB_Shortcut_Home     ;{ Home
          Calendar()\String\CursorPos = 0
          ;}
        Case #PB_Shortcut_End      ;{ End
          Calendar()\String\CursorPos = Len(Calendar()\String\Text)
          ;}
        Case #PB_Shortcut_Back     ;{ Delete Back
          If Calendar()\String\CursorPos > 0
            Calendar()\String\Text = DeleteStringPart_(Calendar()\String\Text, Calendar()\String\CursorPos)
            Calendar()\String\CursorPos - 1
          EndIf  
          ;}
        Case #PB_Shortcut_Delete   ;{ Delete
          If Calendar()\String\CursorPos < Len(Calendar()\String\Text)
            Calendar()\String\Text = DeleteStringPart_(Calendar()\String\Text, Calendar()\String\CursorPos + 1)
          EndIf
          ;} 
        Case #PB_Shortcut_Return   ;{ Return
          ChangeYear_(#False) 
          ;}
      EndSelect
      
      If Calendar()\String\Visible
        If Len(Calendar()\String\Text) = 4
          If Val(Calendar()\String\Text) > 1600 And Val(Calendar()\String\Text) < 2100
            Calendar()\String\FrontColor = Calendar()\Color\Front
          Else
            Calendar()\String\FrontColor = #Red
          EndIf 
        Else
          Calendar()\String\FrontColor = Calendar()\Color\Front
        EndIf  
        DrawString_()
      Else  
        Draw_()
      EndIf   

    EndIf
    
  EndProcedure

  Procedure _LeftButtonDownHandler()
    Define.i X, Y
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseY) 
      
      If Calendar()\ListView\Visible
        
        If X > Calendar()\ListView\X And X < Calendar()\ListView\X + Calendar()\ListView\Width
          If Y > Calendar()\ListView\Y And Y < Calendar()\ListView\Y + Calendar()\ListView\Height
            
            ForEach Calendar()\ListView\Item()
              If Y >= Calendar()\ListView\Item()\Y And Y <= Calendar()\ListView\Item()\Y + Calendar()\ListView\RowHeight
                Calendar()\ListView\Focus = ListIndex(Calendar()\ListView\Item())
                DrawListView_()
                ProcedureReturn #True
              EndIf   
            Next
            
          EndIf  
        EndIf
        
      EndIf

    EndIf
    
  EndProcedure

  Procedure _LeftButtonUpHandler()  
    Define.i X, Y, Angle
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseY)
      
      If Calendar()\ListView\Visible
        
        If X > Calendar()\ListView\X And X < Calendar()\ListView\X + Calendar()\ListView\Width
          If Y > Calendar()\ListView\Y And Y < Calendar()\ListView\Y + Calendar()\ListView\Height
            
            ForEach Calendar()\ListView\Item()
              If Y >= Calendar()\ListView\Item()\Y And Y <= Calendar()\ListView\Item()\Y + Calendar()\ListView\RowHeight
                Calendar()\ListView\State = ListIndex(Calendar()\ListView\Item())
                ChangeMonth_(#False)
                ProcedureReturn #True
              EndIf   
            Next

          EndIf  
        EndIf

      EndIf  
      
      If Calendar()\Month\State = #Change : ChangeMonth_(#False) : EndIf
      If Calendar()\Year\State  = #Change : ChangeYear_(#False)  : EndIf
      
      ;{ Buttons: Previous & Next
      If Y >= Calendar()\Button\Y And Y <= Calendar()\Button\Y + Calendar()\Button\Height
        If X >= Calendar()\Button\prevX And X <= Calendar()\Button\prevX + Calendar()\Button\Width
          Calendar()\Current\Date  = AddDate_(Calendar()\Current\Date, #PB_Date_Month, -1)
          Calendar()\Current\Month = Month_(Calendar()\Current\Date)
          Calendar()\Current\Year  = Year_(Calendar()\Current\Date)
          Draw_()
          ProcedureReturn #True
        ElseIf X >= Calendar()\Button\nextX And X <= Calendar()\Button\nextX + Calendar()\Button\Width
          Calendar()\Current\Date  = AddDate_(Calendar()\Current\Date, #PB_Date_Month, 1)
          Calendar()\Current\Month = Month_(Calendar()\Current\Date)
          Calendar()\Current\Year  = Year_(Calendar()\Current\Date)
          Draw_()
          ProcedureReturn #True
        EndIf
      EndIf ;}
      
      ;{ Click: Month & Year
      If Y >= Calendar()\Month\Y And Y <= Calendar()\Month\Y + Calendar()\Month\Height
        If X >= Calendar()\Month\X And X <= Calendar()\Month\X + Calendar()\Month\Width
          ChangeMonth_()
          ProcedureReturn #True 
        ElseIf X >= Calendar()\Year\X And X <= Calendar()\Year\X + Calendar()\Year\Width
          ChangeYear_(#True) 
          ProcedureReturn #True
        EndIf
      EndIf ;} 
      
      ;{ Click: Days of Month
      If Y > Calendar()\Week\Y + Calendar()\Week\Height
        ForEach Calendar()\Day()
          If Y >= Calendar()\Day()\Y And Y <= Calendar()\Day()\Y + Calendar()\Day()\Height
            If X >= Calendar()\Day()\X And X <= Calendar()\Day()\X + Calendar()\Day()\Width
              Calendar()\Current\Focus = Date_(Calendar()\Current\Year, Calendar()\Current\Month, Val(MapKey(Calendar()\Day())), 0, 0, 0)
              PostEvent(#PB_Event_Gadget, Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Select, Calendar()\Current\Focus)
              PostEvent(#Event_Gadget,    Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Select, Calendar()\Current\Focus)
              Draw_()
              Break
            EndIf
          EndIf
        Next
      EndIf   
      ;}

    EndIf
    
  EndProcedure

  Procedure _MouseMoveHandler()
    Define.i X, Y, Width
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)
      
      ;{ ListView: Focus
      If Calendar()\ListView\Visible
        
        Width = Calendar()\ListView\Width
        
        If Calendar()\ListView\ScrollBar\Hide = #False
          Width - dpiX(#ScrollBarSize)
        EndIf 
       
        If X > Calendar()\ListView\X And X < Calendar()\ListView\X + Width
          If Y > Calendar()\ListView\Y And Y < Calendar()\ListView\Y + Calendar()\ListView\Height
            
            ForEach Calendar()\ListView\Item()
              If Y >= Calendar()\ListView\Item()\Y And Y <= Calendar()\ListView\Item()\Y + Calendar()\ListView\RowHeight
                If Calendar()\ListView\Focus <> ListIndex(Calendar()\ListView\Item())
                  ;Calendar()\ListView\Focus = ListIndex(Calendar()\ListView\Item())
                  ;DrawListView_()
                EndIf  
                ProcedureReturn #True
              EndIf   
            Next
            
          EndIf  
        EndIf  
        
        ;Calendar()\ListView\Focus = #PB_Default
        ;DrawListView_()
      EndIf ;}
      
      ;{ Buttons: Previous & Next
      If Y >= Calendar()\Button\Y And Y <= Calendar()\Button\Y + Calendar()\Button\Height
        If X >= Calendar()\Button\prevX And X <= Calendar()\Button\prevX + Calendar()\Button\Width
          SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          ProcedureReturn #True
        ElseIf X >= Calendar()\Button\nextX And X <= Calendar()\Button\nextX + Calendar()\Button\Width
          SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          ProcedureReturn #True
        EndIf
      EndIf ;}
      
      ;{ Month & Year
      If Y > Calendar()\Month\Y And Y < Calendar()\Month\Y + Calendar()\Month\Height
        If X > Calendar()\Month\X And X < Calendar()\Month\X + Calendar()\Month\Width
          SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          ProcedureReturn #True
        ElseIf X > Calendar()\Year\X And X < Calendar()\Year\X + Calendar()\Year\Width 
          SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          ProcedureReturn #True
        EndIf
      EndIf ;}
      
      SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
      
      ;{ Days of Month
      If Y > Calendar()\Week\Y + Calendar()\Week\Height

        ForEach Calendar()\Day()
          
          If Y >= Calendar()\Day()\Y And Y <= Calendar()\Day()\Y + Calendar()\Day()\Height
            If X >= Calendar()\Day()\X And X <= Calendar()\Day()\X + Calendar()\Day()\Width

              SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
             
              ProcedureReturn #True
            EndIf
          EndIf
          
        Next
        
      EndIf ;}
      
      SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
     
    EndIf
    
  EndProcedure  
  
  Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta, ScrollPos
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(Calendar()\ListView\ScrollBar\Num) And Calendar()\ListView\ScrollBar\Hide = #False
        
        ScrollPos = GetGadgetState(Calendar()\ListView\ScrollBar\Num) - Delta
        
        If ScrollPos <> Calendar()\ListView\ScrollBar\Position

          Calendar()\ListView\ScrollBar\Position = ScrollPos
          Calendar()\ListView\Offset             = ScrollPos
          
          SetGadgetState(Calendar()\ListView\ScrollBar\Num, ScrollPos)
          
          DrawListView_()      
  
        EndIf

      EndIf

    EndIf
    
  EndProcedure
  
  
  Procedure _SynchronizeScrollBar()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.i ScrollPos
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      If Calendar()\ListView\Visible
        
        ScrollPos = GetGadgetState(ScrollNum)
        If ScrollPos <> Calendar()\ListView\ScrollBar\Position
          
          Calendar()\ListView\ScrollBar\Position = ScrollPos
          Calendar()\ListView\Offset             = ScrollPos
          
          DrawListView_()      
        EndIf
        
      EndIf 
      
    EndIf
    
  EndProcedure 
  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetID))
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.i FontSize, FontNum
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach Calendar()
      
      If IsGadget(Calendar()\CanvasNum)
        
        If Calendar()\Flags & #AutoResize
          
          If IsWindow(Calendar()\Window\Num)
            
            OffSetX = WindowWidth(Calendar()\Window\Num)  - Calendar()\Window\Width
            OffsetY = WindowHeight(Calendar()\Window\Num) - Calendar()\Window\Height

            If Calendar()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If Calendar()\Size\Flags & #MoveX : X = Calendar()\Size\X + OffSetX : EndIf
              If Calendar()\Size\Flags & #MoveY : Y = Calendar()\Size\Y + OffSetY : EndIf
              If Calendar()\Size\Flags & #Width  : Width  = Calendar()\Size\Width   + OffSetX : EndIf
              If Calendar()\Size\Flags & #Height : Height = Calendar()\Size\Height  + OffSetY : EndIf
              
              ResizeGadget(Calendar()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(Calendar()\CanvasNum, #PB_Ignore, #PB_Ignore, Calendar()\Size\Width + OffSetX, Calendar()\Size\Height + OffsetY)
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

  Procedure   DefaultCountry(Code.s)
    CountryCode = Code
  EndProcedure
  
  Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(Calendar(), Str(GNum))
  
      Calendar()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 
  
  Procedure   DisableReDraw(GNum.i, State.i=#False)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If State
        Calendar()\ReDraw = #False
      Else
        Calendar()\ReDraw = #True
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i=#PB_Default, Height.i=#PB_Default, Date.i=#PB_Default, Flags.i=#False, WindowNum.i=#PB_Default)
    Define d, m, DummyNum, Result.i
    
    CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If Width  = #PB_Default : Width  = 210 : EndIf
    If Height = #PB_Default : Height = 160 : EndIf
    
    If Flags & #UseExistingCanvas ;{ Use an existing CanvasGadget
      If IsGadget(GNum)
        Result = #True
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Container|#PB_Canvas_Keyboard)
    EndIf

    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      If AddMapElement(Calendar(), Str(GNum))
        
        Calendar()\CanvasNum = GNum
        
        Calendar()\ListView\ScrollBar\Num = ScrollBarGadget(#PB_Any, 0, 0, #ScrollBarSize, 0, 1, 12, 0, #PB_ScrollBar_Vertical)
        If IsGadget(Calendar()\ListView\ScrollBar\Num)
          SetGadgetData(Calendar()\ListView\ScrollBar\Num, GNum)
          HideGadget(Calendar()\ListView\ScrollBar\Num, #True)
        EndIf
        
        CompilerIf Defined(ModuleEx, #PB_Module) ; WindowNum = #Default
          If WindowNum = #PB_Default
            Calendar()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            Calendar()\Window\Num = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            Calendar()\Window\Num = GetActiveWindow()
          Else
            Calendar()\Window\Num = WindowNum
          EndIf
        CompilerEndIf
        
        CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
          CompilerCase #PB_OS_Windows
            Calendar()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If DummyNum
              Calendar()\FontID = GetGadgetFont(DummyNum)
              FreeGadget(DummyNum)
            EndIf
          CompilerCase #PB_OS_Linux
            Calendar()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        CompilerIf Defined(ModuleEx, #PB_Module)
      
          If ModuleEx::AddWindow(Calendar()\Window\Num, ModuleEx::#Tabulator|ModuleEx::#CursorEvent)
            ModuleEx::AddGadget(GNum, Calendar()\Window\Num)
          EndIf
          
        CompilerElse
          
          If Thread\Active = #False
            Thread\Exit   = #False
            Thread\Num    = CreateThread(@_CursorThread(), #CursorFrequency)
            Thread\Active = #True
          EndIf
          
        CompilerEndIf
        
        MonthNames_(CountryCode)
        WeekDayNames_(CountryCode)
        
        For m=1 To 12
          If AddElement(Calendar()\ListView\Item())
            Calendar()\ListView\Item()\String = Calendar()\Month\Name(Str(m))
          EndIf 
        Next
        
        CloseGadgetList()
        
        Calendar()\Size\X = X
        Calendar()\Size\Y = Y
        Calendar()\Size\Width  = Width
        Calendar()\Size\Height = Height

        Calendar()\Month\Spacing     = dpiY(8)
        Calendar()\Month\Color\Front = #PB_Default
        Calendar()\Month\Color\Back  = #PB_Default
        Calendar()\Month\Color\Grid  = #PB_Default
        
        Calendar()\Week\Color\Front  = #PB_Default
        Calendar()\Week\Color\Back   = #PB_Default
        Calendar()\Week\Color\Grid   = #PB_Default
        
        If Date <= 0 : Date = Date() : EndIf
        
        Calendar()\Current\Date  = Date
        Calendar()\Current\Focus = Date
        Calendar()\Current\Month = Month_(Date)
        Calendar()\Current\Year  = Year_(Date)
        
        Calendar()\Flags  = Flags

        Calendar()\ReDraw = #True
        
        Calendar()\Color\Arrow        = $696969
        Calendar()\Color\Back         = $FFFFFF
        Calendar()\Color\Border       = $A0A0A0
        Calendar()\Color\Gadget       = $EDEDED
        Calendar()\Color\GreyText     = $6D6D6D
        Calendar()\Color\FocusBack    = $D77800
        Calendar()\Color\FocusText    = $FFFFFF
        Calendar()\Color\Front        = $000000
        Calendar()\Color\Grid         = $B4B4B4
        Calendar()\Color\Today        = $0000FF
        Calendar()\Color\DisableFront = $72727D
        Calendar()\Color\DisableBack  = $CCCCCA
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            Calendar()\Color\Back       = GetSysColor_(#COLOR_WINDOW)
            Calendar()\Color\Border     = GetSysColor_(#COLOR_WINDOWFRAME)
            Calendar()\Color\FocusBack  = GetSysColor_(#COLOR_MENUHILIGHT)
            Calendar()\Color\Front      = GetSysColor_(#COLOR_WINDOWTEXT)
            Calendar()\Color\Gadget     = GetSysColor_(#COLOR_MENU)
            Calendar()\Color\Grid       = GetSysColor_(#COLOR_ACTIVEBORDER)
          CompilerCase #PB_OS_MacOS
            Calendar()\Color\Back       = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            Calendar()\Color\Border     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            Calendar()\Color\Gadget     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            Calendar()\Color\FocusBack  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
            Calendar()\Color\Front      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            Calendar()\Color\Grid       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;} 
        
        BindGadgetEvent(Calendar()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
        BindGadgetEvent(Calendar()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        BindGadgetEvent(Calendar()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
        BindGadgetEvent(Calendar()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
        BindGadgetEvent(Calendar()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        BindGadgetEvent(Calendar()\CanvasNum,  @_KeyDownHandler(),         #PB_EventType_KeyDown)  
        BindGadgetEvent(Calendar()\CanvasNum,  @_InputHandler(),           #PB_EventType_Input)
        
        BindGadgetEvent(Calendar()\ListView\ScrollBar\Num, @_SynchronizeScrollBar(), #PB_All) 
        
        BindEvent(#Event_Cursor, @_CursorDrawing())
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
      
        If Flags & #AutoResize ;{ Enabel AutoResize
          If IsWindow(Calendar()\Window\Num)
            Calendar()\Window\Width  = WindowWidth(Calendar()\Window\Num)
            Calendar()\Window\Height = WindowHeight(Calendar()\Window\Num)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), Calendar()\Window\Num)
          EndIf  
        EndIf ;}
        
        Draw_()
        
        ProcedureReturn Calendar()\CanvasNum
      EndIf
     
    EndIf
    
  EndProcedure    
  
  
  Procedure   GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Select Attribute
        Case #Spacing
          ProcedureReturn DesktopUnscaledX(Calendar()\Month\Spacing)
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf  
    
  EndProcedure
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(Calendar(), Str(GNum))
	    ProcedureReturn Calendar()\Quad
	  EndIf  
	  
	EndProcedure	  
  
  Procedure.q GetDate(Day.i, Month.i, Year.i, Hour.i=0, Minute.i=0, Second.i=0)
 
    ProcedureReturn Date_(Year, Month, Day, Hour, Minute, Second)

  EndProcedure
  
  Procedure.i GetDay(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Day_(Calendar()\Current\Focus)
    EndIf
    
  EndProcedure
  
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(Calendar(), Str(GNum))
	    ProcedureReturn Calendar()\ID
	  EndIf
	  
	EndProcedure  
  
  Procedure.i GetMonth(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Month_(Calendar()\Current\Focus)
    EndIf
    
  EndProcedure
  
  Procedure.i GetYear(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Year_(Calendar()\Current\Focus)
    EndIf
    
  EndProcedure
  
  Procedure.i GetState(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Calendar()\Current\Focus
    EndIf
    
  EndProcedure  
  
  Procedure.s GetText(GNum.i, Mask.s="")
    Define.s String
    
    If Mask = "" : Mask = "%yyy/%mm/%dd" : EndIf 
    
    If FindMapElement(Calendar(), Str(GNum))
      String = ReplaceString(Mask,   "%yyyy", Str(Year_(Calendar()\Current\Focus)))
      
      String = ReplaceString(String, "%yy",   Right(Str(Year_(Calendar()\Current\Focus)), 2))
      String = ReplaceString(String, "%mm",   Str(Month_(Calendar()\Current\Focus)))
      String = ReplaceString(String, "%dd",   Str(Day_(Calendar()\Current\Focus)))
      
      ProcedureReturn String
    EndIf
    
  EndProcedure
  
  
  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If State
        Calendar()\Hide = #True
        HideGadget(GNum, #True)
      Else
        Calendar()\Hide = #False
        HideGadget(GNum, #False)
        Draw_()
      EndIf  
      
    EndIf  
    
  EndProcedure
  
  Procedure   MonthName(Month.i, Name.s)
    If Month >= 1 And Month <= 12
      NameOfMonth(Str(Month)) = Name
    EndIf
  EndProcedure  
  
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Select Attribute
        Case #Spacing
          Calendar()\Month\Spacing = dpiX(Value)
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf  
    
  EndProcedure
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Calendar()\Size\Flags = Flags
      Calendar()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Value.i)
    
    If FindMapElement(Calendar(), Str(GNum))
    
      Select ColorType
        Case #ArrowColor
          Calendar()\Color\Arrow       = Value  
        Case #BackColor
          Calendar()\Color\Back        = Value
        Case #BorderColor
          Calendar()\Color\Border      = Value          
        Case #FrontColor
          Calendar()\Color\Front       = Value        
        Case #FocusColor
          Calendar()\Color\FocusBack       = Value
        Case #TodayColor
          Calendar()\Color\Today       = Value  
        Case #GreyTextColor
          Calendar()\Color\GreyText    = Value
        Case #LineColor
          Calendar()\Color\Grid        = Value
        Case #Month_FrontColor
          Calendar()\Month\Color\Front = Value
        Case #Month_BackColor
          Calendar()\Month\Color\Back  = Value
        Case #Week_FrontColor
          Calendar()\Week\Color\Front  = Value
        Case #Week_BackColor  
          Calendar()\Week\Color\Back   = Value
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
	Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(Calendar(), Str(GNum))
	    Calendar()\Quad = Value
	  EndIf  
	  
	EndProcedure
  
  Procedure   SetDate(GNum.i, Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)

    If FindMapElement(Calendar(), Str(GNum))
      
      Calendar()\Current\Date  = Date_(Year, Month, Day, Hour, Minute, Second)
      Calendar()\Current\Focus = Calendar()\Current\Date
      Calendar()\Current\Month = Month_(Calendar()\Current\Date)
      Calendar()\Current\Year  = Year_(Calendar()\Current\Date)
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure

  Procedure   SetFont(GNum.i, FontNum.i, FontType.i=#Font_Gadget) 
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Select FontType
        Case #Font_Month
          Calendar()\Month\Font  = FontNum
        Case #Font_Weekdays
          Calendar()\Week\Font   = FontNum
        Default
          Calendar()\FontID      = FontID(FontNum)
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(Calendar(), Str(GNum))
	    Calendar()\ID = String
	  EndIf
	  
	EndProcedure  
  
  Procedure   SetState(GNum.i, Date.q) 
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Calendar()\Current\Date  = Date
      Calendar()\Current\Focus = Date
      Calendar()\Current\Month = Month_(Date)
      Calendar()\Current\Year  = Year_(Date)

      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  
  Procedure   WeekDayName(WeekDay.i, Name.s)
    If WeekDay >= 0 And WeekDay <= 7
      If WeekDay = 0
        NameOfWeekDay("7") = Name
      Else
        NameOfWeekDay(Str(WeekDay)) = Name
      EndIf
    EndIf
  EndProcedure

EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile

  ;Calendar::DefaultCountry("DE")
  
  Enumeration 1
    #Window
    #Calendar
  EndEnumeration

  If OpenWindow(#Window, 0, 0, 230, 180, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    Calendar::Gadget(#Calendar, 10, 10, #PB_Default, #PB_Default, #PB_Default, #Window)

    ;ModuleEx::SetTheme(ModuleEx::#Theme_Blue)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case Calendar::#Event_Gadget ;{ Module Events
          If EventType() = Calendar::#EventType_Select
            Debug "Module Event: " + Date64::FormatDate_("%yyyy/%mm/%dd", EventData())
          EndIf ;}
        Case #PB_Event_Gadget        ;{ Gadget Event
          If EventType() = Calendar::#EventType_Select
            Debug "Gadget Event: Date selected"
          EndIf ;}
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 2312
; FirstLine = 319
; Folding = YABAAAAAAAQYBKMDAAAAiBAAg-
; Markers = 964,2230
; EnableXP
; DPIAware