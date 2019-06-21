;/ ========================
;/ =    MetaModule.pbi    =
;/ ========================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; - Manage tabulator shortcut (#Tabulator) and gadgets can use the tab key if they have the focus (#UseTabulator).
; - Creates cursor events for gadgets of a window (#CursorEvent)
; - Provides event types for PostEvent() for other modules

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


;{ _____ ModuleEx - Commands _____

; ModuleEx::AddGadget()                - add a gadget for tabulator handling  (#UseTabulator|#IgnoreTabulator)
; ModuleEx::AddWindow()                - enables the tabulator handling for this window  (#Tabulator|#CursorEvent)
; ModuleEx::CursorFrequency()          - changes the cursor frequency (default: 600ms)
; ModuleEx::ExitCursorThread()         - exit cursor thread

;}


DeclareModule ModuleEx
  
  #ButtonExGadget = "ButtonExModule.pbi"
  #ListExGadget   = "ListExModule.pbi"
  #StatusBarEx    = "StatusBarExModule.pbi"
  #StringExGadget = "StringExModule.pbi"
  #TextExGadget   = "TextExModule.pbi"
  #TimeExGadget   = "TimeExModule.pbi"
  #ToolBarEx      = "ToolBarExModule.pbi"
  
  EnumerationBinary Flags
    #Tabulator
    #CursorEvent
    #UseTabulator
    #IgnoreTabulator
  EndEnumeration
  
  Enumeration #PB_Event_FirstCustomValue
    #Event_Gadget
    #Event_Cursor
  EndEnumeration
  
  Enumeration #PB_EventType_FirstCustomValue
    #EventType_Button
    #EventType_CheckBox
    #EventType_ComboBox
    #EventType_Date
    #EventType_DropDown
    #EventType_Header
    #EventType_HyperLink
    #EventType_ImageButton
    #EventType_Link
    #EventType_SpinBox
    #EventType_String
    #EventType_Row
  EndEnumeration
  
  #Event_Tabulator      = 64000
  #Event_ShiftTabulator = 63999
  
  ;- ============================================================================
  ;-   DeclareModule
  ;- ============================================================================
  
  Declare.i AddGadget(GNum.i, WindowNum.i, Flags.i=#False)
  Declare.i AddWindow(WindowNum.i, Flags.i=#False)
  Declare   CursorFrequency(Frequency.i)
  Declare   ExitCursorThread() 
  Declare.i GetGadgetWindow()
  
EndDeclareModule

Module ModuleEx

  EnableExplicit  
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================    
  
  #CursorFrequency = 600
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================    
  
  Structure ModuleEx_Thread_Structure        ;{ ModuleEx\Thread\...
    Num.i
    Active.i
    Frequency.i
    Exit.i
  EndStructure ;}
  
  Structure ModuleEx_Gadget_Structure        ;{ ModuleEx\Gadget()\...
    Window.i
    Idx.i
    Flags.i
  EndStructure ;}
  
  Structure ModuleEx_Window_Gadget_Structure ;{ ModuleEx\Window()\Gadget()\...
    List Gadget.i()
  EndStructure ;}
  
  Structure ModuleEx_Active_Structure        ;{ ModuleEx\Active\...
    Window.i
    Gadget.i
  EndStructure ;}
  
  Structure ModuleEx_Structure               ;{ ModuleEx\...
    
    Menu.i

    Active.ModuleEx_Active_Structure
    Thread.ModuleEx_Thread_Structure
    
    Map Window.ModuleEx_Window_Gadget_Structure()
    Map Gadget.ModuleEx_Gadget_Structure()
    
  EndStructure ;}
  Global ModuleEx.ModuleEx_Structure
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================
  
   CompilerIf #PB_Compiler_OS = #PB_OS_Windows  ; Thanks to mk-soft
    Import ""
      PB_Object_EnumerateStart(PB_Objects)
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      ;PB_Object_GetObject( PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      ;PB_Gadget_Objects.i
      ;PB_Image_Objects.i
    EndImport
  CompilerElse
    ImportC ""
      PB_Object_EnumerateStart( PB_Objects )
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      ;PB_Object_GetObject( PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      ;PB_Gadget_Objects.i
      ;PB_Image_Objects.i
    EndImport
  CompilerEndIf
  
  
  ;- __________ Events __________
  
  Procedure _CursorThread(ElapsedTime.i)

    Repeat
      
      If ElapsedTime >= ModuleEx\Thread\Frequency
        PostEvent(#Event_Cursor)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until ModuleEx\Thread\Exit
    
  EndProcedure
  
  Procedure _TabulatorHandler()
    Define.i Window.i, Gadget, NextGadget
    
    Window = GetActiveWindow()
    If IsWindow(Window)
      
      If FindMapElement(ModuleEx\Window(), Str(Window))
        If NextElement(ModuleEx\Window()\Gadget())
          If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
        Else
          FirstElement(ModuleEx\Window()\Gadget())
          If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _ShiftTabulatorHandler()
    Define.i Window.i, Gadget, NextGadget
    
    Window = GetActiveWindow()
    If IsWindow(Window)
      
      If FindMapElement(ModuleEx\Window(), Str(Window))
        If PreviousElement(ModuleEx\Window()\Gadget())
          If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
        Else
          LastElement(ModuleEx\Window()\Gadget())
          If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ModuleEx\Gadget(), Str(GNum))

      If ModuleEx\Gadget()\Flags & #UseTabulator
        
        If IsMenu(ModuleEx\Menu)
          UnbindMenuEvent(ModuleEx\Menu, #Event_Tabulator,       @_TabulatorHandler())
          UnbindMenuEvent(ModuleEx\Menu, #Event_ShiftTabulator,  @_ShiftTabulatorHandler())
        EndIf 
        
        If IsWindow(ModuleEx\Gadget()\Window)
          RemoveKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Tab)
          RemoveKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Shift|#PB_Shortcut_Tab)
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ModuleEx\Gadget(), Str(GNum))
      
      If ModuleEx\Gadget()\Flags & #UseTabulator
        
        If IsWindow(ModuleEx\Gadget()\Window)
          AddKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Tab, #Event_Tabulator)
          AddKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Shift|#PB_Shortcut_Tab, #Event_ShiftTabulator)
        EndIf
        
        If IsMenu(ModuleEx\Menu)
          BindMenuEvent(ModuleEx\Menu, #Event_Tabulator,      @_TabulatorHandler())
          BindMenuEvent(ModuleEx\Menu, #Event_ShiftTabulator, @_ShiftTabulatorHandler())
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    If FindMapElement(ModuleEx\Window(), Str(Window))
      
      If ModuleEx\Thread\Active
        If MapSize(ModuleEx\Window()) = 1
          ModuleEx\Thread\Exit  = #True
          ModuleEx\Thread\Active      = #False
        EndIf
      EndIf
      
      ForEach ModuleEx\Gadget()
        If ModuleEx\Gadget()\Window = Window
          DeleteMapElement(ModuleEx\Gadget())
        EndIf
      Next
      
      DeleteMapElement(ModuleEx\Window())
      
      If ModuleEx\Thread\Exit
        Delay(100)
        If IsThread(ModuleEx\Thread\Num)
          KillThread(ModuleEx\Thread\Num)
        EndIf
      EndIf
      
    EndIf 
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================      

  Procedure.i AddGadget(GNum.i, WindowNum.i, Flags.i=#False)
    ; Flags: #UseTabulator    - Gadget uses the tab key when it has the focus.
    ; Flags: #IgnoreTabulator - Gadget is ignored when tab key is used to jump to the next gadget
    
    If AddMapElement(ModuleEx\Gadget(), Str(GNum))
      
      ModuleEx\Gadget()\Window = WindowNum
      ModuleEx\Gadget()\Flags  = Flags
      
      If Flags & #IgnoreTabulator
        ModuleEx\Gadget()\Idx = -1
      Else
        If AddElement(ModuleEx\Window(Str(WindowNum))\Gadget())
          ModuleEx\Window(Str(WindowNum))\Gadget() = GNum
          ModuleEx\Gadget()\Idx = ListIndex(ModuleEx\Window(Str(WindowNum))\Gadget())
        EndIf
      EndIf
      
      If IsGadget(GNum)
        BindGadgetEvent(GNum, @_FocusHandler(),     #PB_EventType_Focus)
        BindGadgetEvent(GNum, @_LostFocusHandler(), #PB_EventType_LostFocus)
      EndIf
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i AddWindow(WindowNum.i, Flags.i=#False)
    ; Flags: #Tabulator   - create cursor event for gadgets in this window
    ; Flags: #CursorEvent - tabulator shortcut for this window
    
    If IsWindow(WindowNum)
      
      If FindMapElement(ModuleEx\Window(), Str(WindowNum))
        ProcedureReturn #True
      Else
        
        If AddMapElement(ModuleEx\Window(), Str(WindowNum))
          
          If Flags & #CursorEvent ;{ Create cursor event for gadgets in this window
            
            If ModuleEx\Thread\Frequency = 0 : ModuleEx\Thread\Frequency = #CursorFrequency : EndIf
            
            If ModuleEx\Thread\Active = #False
              ModuleEx\Thread\Active = #True
              ModuleEx\Thread\Exit   = #False
              ModuleEx\Thread\Num    = CreateThread(@_CursorThread(), ModuleEx\Thread\Frequency)
            EndIf
            ;}  
          EndIf
          
          If Flags & #Tabulator   ;{ Manage tabulator shortcut for this window
            
            ModuleEx\Menu = CreateMenu(#PB_Any, WindowID(WindowNum))
            If IsMenu(ModuleEx\Menu)
              
              RemoveKeyboardShortcut(WindowNum, #PB_Shortcut_Tab)
              RemoveKeyboardShortcut(WindowNum, #PB_Shortcut_Shift|#PB_Shortcut_Tab)
              
              AddKeyboardShortcut(WindowNum, #PB_Shortcut_Tab, #Event_Tabulator)
              AddKeyboardShortcut(WindowNum, #PB_Shortcut_Shift|#PB_Shortcut_Tab, #Event_ShiftTabulator)
              
              BindMenuEvent(ModuleEx\Menu, #Event_Tabulator,       @_TabulatorHandler())
              BindMenuEvent(ModuleEx\Menu, #Event_ShiftTabulator,  @_ShiftTabulatorHandler())
      
            EndIf
            ;}
          EndIf
          
          BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), WindowNum)
          
          ProcedureReturn #True
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetGadgetWindow() ; Thanks to mk-soft
    Define.i WindowID, Window, Result = #PB_Default
    
    WindowID = UseGadgetList(0)
    
    PB_Object_EnumerateStart(PB_Window_Objects)
    
    While PB_Object_EnumerateNext(PB_Window_Objects, @Window)
      If WindowID = WindowID(Window)
        result = Window
        Break
      EndIf
    Wend
    
    PB_Object_EnumerateAbort(PB_Window_Objects)
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure   CursorFrequency(Frequency.i)
    
    If Frequency < 100 : Frequency = 100 : EndIf 
    
    ModuleEx\Thread\Frequency = Frequency
    
  EndProcedure
  
  Procedure   ExitCursorThread() 
    
    ModuleEx\Thread\Exit   = #True
    ModuleEx\Thread\Active = #False
    
    If ModuleEx\Thread\Exit
      Delay(100)
      If IsThread(ModuleEx\Thread\Num) 
        KillThread(ModuleEx\Thread\Num)
      EndIf
    EndIf
    
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Window  = 1
  
  Enumeration 1 
    #String
    #Button
    #Combo
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 310, 60, "Meta - Module", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    ButtonGadget(#Button,   10,  15,  80, 24, "Button") 
    StringGadget(#String,  110, 15,  80, 24, "") 
    ComboBoxGadget(#Combo, 210, 15, 90, 24)
    AddGadgetItem(#Combo, -1, "Test")
    SetGadgetState(#Combo, 0)
    
    Debug #Window
    Debug ModuleEx::GetGadgetWindow()
    
    If ModuleEx::AddWindow(#Window, ModuleEx::#Tabulator)
      ModuleEx::AddGadget(#Button, #Window)
      ModuleEx::AddGadget(#String, #Window) ; , ModuleEx::#IgnoreTabulator
      ModuleEx::AddGadget(#Combo,  #Window)
    EndIf
   
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button
              
            Case #String
              
            Case #Combo
              
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 69
; FirstLine = 35
; Folding = OAAg-
; EnableXP
; DPIAware