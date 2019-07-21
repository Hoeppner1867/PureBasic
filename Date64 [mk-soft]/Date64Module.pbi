;/ ============================
;/ =    Date64Module.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS ]
;/
;/ based on 'Module Date64' by mk-soft / Sicro / ts-soft
;/
;/ adapted from Thorsten Hoeppner (07/2019)
;/

;{ ===== MIT License =====
;
; Copyright (c) 2012 mk-soft
; Copyright (c) 2013-2017 Sicro
; Copyright (c) 2014 ts-soft
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


;{ _____ Date64 - Commands _____

; Date64::AddDate_()    - similar to AddDate()
; Date64::Date_()       - similar to Date()
; Date64::Day_()        - similar to Day()
; Date64::DayOfWeek_()  - similar to DayOfWeek() 
; Date64::DayOfYear_()  - similar to DayOfYear()
; Date64::FormatDate_() - similar to FormatDate()
; Date64::Minute_()     - similar to Minute()
; Date64::Month_()      - similar to Month()
; Date64::Hour_()       - similar to Hour()
; Date64::ParseDate_()  - similar to ParseDate()
; Date64::Second_()     - similar to Second()
; Date64::Year_()       - similar to Year()

;}

DeclareModule Date64

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
  
  Declare.q AddDate_(Date.q, Type.i, Value.i)
  Declare.q Date_(Year.i=#PB_Default, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
  Declare.i Day_(Date.q)
  Declare.i DayOfWeek_(Date.q)
  Declare.i DayOfYear_(Date.q)
  Declare.s FormatDate_(Mask.s, Date.q) 
  Declare.i Minute_(Date.q)
  Declare.i Month_(Date.q)
  Declare.i Hour_(Date.q)
  Declare.q ParseDate_(Mask.s, Date.s)
  Declare.i Second_(Date.q)
  Declare.i Year_(Date.q)

EndDeclareModule

Module Date64

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	; Seconds
  #Seconds_Hour = 60 * 60                  ; Seconds in an hour
  #Seconds_Day  = #Seconds_Hour * 24       ; Seconds in a day
  
  ; Nanoseconds
  #Nano100_Second     = 10000000           ; hundred nanoseconds in a second.
  #Nano100_1601To1970 = 116444736000000000 ; hundred nanoseconds from 1. Jan. 1601 to 1. Jan. 1970

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
  CompilerSelect #PB_Compiler_OS ;{ OS specific structure
    CompilerCase #PB_OS_Windows
     
    CompilerCase #PB_OS_Linux
      
      If Not Defined(tm, #PB_Structure)
        Structure tm Align #PB_Structure_AlignC
          tm_sec.l 
          tm_min.l
          tm_hour.l
          tm_mday.l
          tm_mon.l
          tm_year.l
          tm_wday.l
          tm_yday.l
          tm_isdst.l
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
            tm_gmtoff.l
            *tm_zone    
          CompilerElse
            tm_zone.l 
            tm_gmtoff.l
            *tm_zone64
          CompilerEndIf
        EndStructure
      EndIf
      
    CompilerCase #PB_OS_MacOS
      
      If Not Defined(tm, #PB_Structure)
        Structure tm Align #PB_Structure_AlignC
          tm_sec.l
          tm_min.l
          tm_hour.l
          tm_mday.l
          tm_mon.l
          tm_year.l
          tm_wday.l
          tm_yday.l
          tm_isdst.l 
           tm_zone.l
          tm_gmtoff.l
          *tm_zone64
        EndStructure
      EndIf
      
  CompilerEndSelect ;}

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================
  
  CompilerSelect #PB_Compiler_OS ;{ OS specific procedure
    CompilerCase #PB_OS_Windows
      
    CompilerDefault
      
      Procedure.i GMTOffset(Date.q)
        Define tm.tm
        Define.i OffSet
        localtime_r_(@Date, @tm)
        If TM\tm_isdst
          OffSet = 3600
        EndIf
        ProcedureReturn OffSet
      EndProcedure
      
  CompilerEndSelect ;}
  
  Procedure.i IsLeapYear(Year.i)
    If Year < 1600
      ProcedureReturn Bool(Year % 4 = 0)
    Else
      ProcedureReturn Bool((Year % 4 = 0 And Year % 100 <> 0) Or Year % 400 = 0)
    EndIf
  EndProcedure
  
  Procedure.i DaysInMonth(Year.i, Month.i)
    
    While Month > 12 : Month - 12 : Wend
   
    Select Month
      Case 0, 1, 3, 5, 7, 8, 10, 12 ; Bugfixes for AddDate() with result 0
        ProcedureReturn 31
      Case 4, 6, 9, 11
        ProcedureReturn 30
      Case 2
        ProcedureReturn 28 + IsLeapYear(Year)
    EndSelect
    
  EndProcedure
  
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================

  Procedure.q Date_(Year.i=#PB_Default, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define st.SYSTEMTIME
        Define ft.FILETIME
       
        If Year > #PB_Default
          
          ;{ Correct incorrect data
          While Second > 59
            Minute + 1
            Second - 60
          Wend
         
          While Minute > 59
            Hour + 1
            Minute - 60
          Wend
         
          While Hour > 23
            Day + 1
            Hour - 24
          Wend
         
          While Day > DaysInMonth(Year, Month)
            Day - DaysInMonth(Year, Month)
            Month + 1
          Wend
         
          While Month > 12
            Year + 1
            Month - 12
            
          Wend
         
          While Second < 0
            Minute - 1
            Second + 59
          Wend
         
          While Minute < 0
            Hour - 1
            Minute + 59
          Wend
         
          While Hour < 0
            Day - 1
            Hour + 23
          Wend
         
          While Day < 0
            Day + DaysInMonth(Year, Month)
            Month - 1
          Wend
         
          While Month < 0
            Year - 1
            Month + 12
          Wend
          
          ; Bugfixes for AddDate() with result 0
          If Day = 0
            Month - 1
            Day = DaysInMonth(Year, Month)
          EndIf

          If Month = 0
            Year - 1
            Month = 12
          EndIf
          ;}
          
          st\wYear   = Year
          st\wMonth  = Month
          st\wDay    = Day
          st\wHour   = Hour
          st\wMinute = Minute
          st\wSecond = Second
         
          SystemTimeToFileTime_(@st, @ft)
         
          ProcedureReturn (PeekQ(@ft) - #Nano100_1601To1970) / #Nano100_Second
        Else
          
          GetLocalTime_(@st)
          SystemTimeToFileTime_(@st, @ft)
         
          ProcedureReturn (PeekQ(@ft) - #Nano100_1601To1970) / #Nano100_Second
        EndIf
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define tm.tm
        Define.q time
       
        If Year > #PB_Default
          
          tm\tm_year  = Year - 1900 
          tm\tm_mon   = Month - 1
          tm\tm_mday  = Day
          tm\tm_hour  = Hour
          tm\tm_min   = Minute
          tm\tm_sec   = Second

          time = mktime_(@tm)
          If time >= 0
            localtime_r_(@time, @tm)
            time = mktime_(@tm)
            ProcedureReturn time
          Else
            ProcedureReturn #False
          EndIf
         
        Else
         
          time = time_(0)
          If time >= 0
            localtime_r_(@time, @tm)
            time = mktime_(@tm)
            ProcedureReturn time
          Else
            ProcedureReturn #False
          EndIf
         
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
  
  Procedure.i Year_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define st.SYSTEMTIME
       
        Date = Date * #Nano100_Second + #Nano100_1601To1970
        FileTimeToSystemTime_(@Date, @st)
       
        ProcedureReturn st\wYear
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define   *Memory_localtime.tm
        Define.i Year
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          Year = *Memory_localtime\tm_year + 1900
          FreeMemory(*Memory_localtime)
          ProcedureReturn Year
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
  
  Procedure.i Month_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows  ;{ Windows
        Define st.SYSTEMTIME
       
        Date = Date * #Nano100_Second + #Nano100_1601To1970
        FileTimeToSystemTime_(@Date, @st)
       
        ProcedureReturn st\wMonth
        ;}
      CompilerDefault              ;{ Linux / MacOS
        Define *Memory_localtime.tm
        Define.i Month
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          Month = *Memory_localtime\tm_mon + 1
          FreeMemory(*Memory_localtime)
          ProcedureReturn Month
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
  
  Procedure.i Day_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define st.SYSTEMTIME
       
        Date = Date * #Nano100_Second + #Nano100_1601To1970
        FileTimeToSystemTime_(@Date, @st)
        
        ProcedureReturn st\wDay
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define *Memory_localtime.tm
        Define.i  Day
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          Day = *Memory_localtime\tm_mday
          FreeMemory(*Memory_localtime)
          ProcedureReturn Day
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
  
  Procedure.i Hour_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define st.SYSTEMTIME
       
        Date = Date * #Nano100_Second + #Nano100_1601To1970
        FileTimeToSystemTime_(@Date, @st)
       
        ProcedureReturn st\wHour
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define *Memory_localtime.tm
        Define.i  Hour
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          Hour = *Memory_localtime\tm_hour
          FreeMemory(*Memory_localtime)
          ProcedureReturn Hour
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
 
  Procedure.i Minute_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define st.SYSTEMTIME
       
        Date = Date * #Nano100_Second + #Nano100_1601To1970
        FileTimeToSystemTime_(@Date, @st)
       
        ProcedureReturn st\wMinute
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define *Memory_localtime.tm
        Define.i Minute
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          Minute = *Memory_localtime\tm_min
          FreeMemory(*Memory_localtime)
          ProcedureReturn Minute
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
 
  Procedure.i Second_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define st.SYSTEMTIME
       
        Date = Date * #Nano100_Second + #Nano100_1601To1970
        FileTimeToSystemTime_(@Date, @st)
       
        ProcedureReturn st\wSecond
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define *Memory_localtime.tm
        Define.i Second
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          Second = *Memory_localtime\tm_sec
          FreeMemory(*Memory_localtime)
          ProcedureReturn Second
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
  
  Procedure.i DayOfWeek_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define st.SYSTEMTIME
       
        Date = Date * #Nano100_Second + #Nano100_1601To1970
        FileTimeToSystemTime_(@Date, @st)
       
        ProcedureReturn st\wDayOfWeek
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define *Memory_localtime.tm
        Define.i DayOfWeek
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          DayOfWeek = *Memory_localtime\tm_wday
          FreeMemory(*Memory_localtime)
          ProcedureReturn DayOfWeek
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
 
  Procedure.i DayOfYear_(Date.q)
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows ;{ Windows
        Define.q yearDate
       
        yearDate = Date_(Year_(Date))
       
        ProcedureReturn (Date - yearDate) / #Seconds_Day + 1
        ;}
      CompilerDefault             ;{ Linux / MacOS
        Define *Memory_localtime.tm
        Define.i  DayOfYear
       
        Date - GMTOffset(Date)
       
        *Memory_localtime = AllocateMemory(SizeOf(tm))
        If *Memory_localtime
          localtime_r_(@Date, *Memory_localtime)
          DayOfYear = *Memory_localtime\tm_yday
          FreeMemory(*Memory_localtime)
          ProcedureReturn DayOfYear + 1
        Else
          ProcedureReturn #PB_Default
        EndIf
        ;}
    CompilerEndSelect
    
  EndProcedure
  
  Procedure.q AddDate_(Date.q, Type.i, Value.i)
    Define.i Day, Month, Year
   
    Select Type
      Case #PB_Date_Year
        ProcedureReturn Date_(Year_(Date) + Value, Month_(Date), Day_(Date), Hour_(Date), Minute_(Date), Second_(Date))
      Case #PB_Date_Month
        Day   = Day_(Date)
        Month = Month_(Date) + Value
        Year  = Year_(Date)
        If Day > DaysInMonth(Year, Month) : Day = DaysInMonth(Year, Month) : EndIf
        ProcedureReturn Date_(Year_(Date), Month, Day, Hour_(Date), Minute_(Date), Second_(Date))
      Case #PB_Date_Week
        ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date) + Value * 7, Hour_(Date), Minute_(Date), Second_(Date))
      Case #PB_Date_Day
        ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date) + Value, Hour_(Date), Minute_(Date), Second_(Date))
      Case #PB_Date_Hour
        ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date), Hour_(Date) + Value, Minute_(Date), Second_(Date))
      Case #PB_Date_Minute
        ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date), Hour_(Date), Minute_(Date) + Value, Second_(Date))
      Case #PB_Date_Second
        ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date), Hour_(Date), Minute_(Date), Second_(Date) + Value)
    EndSelect
    
  EndProcedure
 
  Procedure.s FormatDate_(Mask.s, Date.q)
    Define.s String
   
    String = ReplaceString(Mask,   "%yyyy", RSet(Str(Year_(Date)),   4, "0"))
    String = ReplaceString(String, "%yy",   RSet(Right(Str(Year_(Date)), 2), 2, "0"))
    String = ReplaceString(String, "%mm",   RSet(Str(Month_(Date)),  2, "0"))
    String = ReplaceString(String, "%dd",   RSet(Str(Day_(Date)),    2, "0"))
    String = ReplaceString(String, "%hh",   RSet(Str(Hour_(Date)),   2, "0"))
    String = ReplaceString(String, "%ii",   RSet(Str(Minute_(Date)), 2, "0"))
    String = ReplaceString(String, "%ss",   RSet(Str(Second_(Date)), 2, "0"))
   
    ProcedureReturn String
  EndProcedure
 
  Procedure.q ParseDate_(Mask.s, Date.s)
    Define.i i, DatePos, IsVariableFound, Year, Month, Day, Hour, Minute, Second
    Define.s MaskChar, DateChar
    
    DatePos = 1
    Month   = 1
    Day     = 1

    For i = 1 To Len(Mask)
      
      MaskChar = Mid(Mask, i, 1)
      DateChar = Mid(Date, DatePos, 1)
     
      If MaskChar <> DateChar
        If MaskChar = "%"
          If Mid(Mask, i, 5) = "%yyyy"
            IsVariableFound = #True
            Year = Val(Mid(Date, DatePos, 4))
            DatePos + 4 
            i + 4 
            Continue
          ElseIf Mid(Mask, i, 3) = "%yy"
            IsVariableFound = #True
            Year = Val(Mid(Date, DatePos, 2))
            DatePos + 2
            i + 2
            Continue
          EndIf
         
          If Mid(Mask, i, 3) = "%mm"
            IsVariableFound = #True
            Month = Val(Mid(Date, DatePos, 2))
            DatePos + 2
            i + 2
            Continue
          EndIf
         
          If Mid(Mask, i, 3) = "%dd"
            IsVariableFound = #True
            Day = Val(Mid(Date, DatePos, 2))
            DatePos + 2 
            i + 2
            Continue
          EndIf
         
          If Mid(Mask, i, 3) = "%hh"
            IsVariableFound = #True
            Hour = Val(Mid(Date, DatePos, 2))
            DatePos + 2
            i + 2
            Continue
          EndIf
         
          If Mid(Mask, i, 3) = "%ii"
            IsVariableFound = #True
            Minute = Val(Mid(Date, DatePos, 2))
            DatePos + 2
            i + 2
            Continue
          EndIf
         
          If Mid(Mask, i, 3) = "%ss"
            IsVariableFound = #True
            Second = Val(Mid(Date, DatePos, 2))
            DatePos + 2
            i + 2 
            Continue
          EndIf
         
          If Not IsVariableFound
            ProcedureReturn #False
          EndIf
        Else
          ProcedureReturn #False
        EndIf
      EndIf
     
      DatePos + 1
    Next
   
    ProcedureReturn Date_(Year, Month, Day, Hour, Minute, Second)
  EndProcedure
  
EndModule
  
;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Define Event.i, Date.q
  
  Enumeration 
    #Window
    #Date
    #Button
    #Date64
    #Date32
    #Text
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 220, 70, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    StringGadget(#Date64, 10, 10, 70, 20, "", #PB_String_ReadOnly)
    StringGadget(#Date32, 10, 40, 70, 20, "", #PB_String_ReadOnly)
    DateGadget(#Date, 85, 10, 80, 20, "%mm/%dd/%yyyy", Date())
    ButtonGadget(#Button, 170, 10, 30, 20, "OK")
    TextGadget(#Text, 85, 43, 100, 14, "( Date with 32-Bit )")
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button
              Date = Date64::ParseDate_("%mm/%dd/%yyyy", GetGadgetText(#Date))
              SetGadgetText(#Date64, Date64::FormatDate_("%mm/%dd/%yyyy", Date))
              Date = ParseDate("%mm/%dd/%yyyy", GetGadgetText(#Date))
              SetGadgetText(#Date32, FormatDate("%mm/%dd/%yyyy", Date))
          EndSelect
      EndSelect
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 37
; FirstLine = 263
; Folding = 95BAAAk-
; EnableXP
; DPIAware