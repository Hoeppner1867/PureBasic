;/ ===============================
;/ =    MouseEventsModule.pbi    =
;/ ===============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ MouseEvents - Module (MouseEnter, MouseLeave, MouseMove)
;/
;/ based on 'MyEvents' by mk-soft
;/
;/ adapted from Thorsten Hoeppner (07/2019)
;/

; Last Update:

;{ ===== MIT License =====
;
; Copyright (c) 2015 - 2017 mk-soft
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

DeclareModule MouseEvent
  
  Enumeration 1
    #MouseX
    #MouseY
    #Gadget
  EndEnumeration

  EnumerationBinary
    #MouseEnter
    #MouseLeave
    #MouseMove
  EndEnumeration
  
  #MouseEvents = #MouseEnter|#MouseLeave|#MouseMove
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i Add(Window.i, Gadget.i=#PB_Default, Flags.i=#MouseEvents)
  Declare.i GetAttribute(Window.i, Attribute.i, Gadget.i=#PB_Default)
  
EndDeclareModule

Module MouseEvent
  
  EnableExplicit
  
  #MouseEventTimer = 20000
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure Window_Structure     ;{ MouseEvent()\Window\...
    Num.i
    MouseX.i
    MouseY.i
  EndStructure ;}
  
  Structure Gadget_Structure     ;{ MouseEvent()\Gadget\...
    Num.i
    MouseX.i
    MouseY.i
    Last.i
  EndStructure ;}
  
  Structure MouseEvent_Structure ;{ MouseEvent('Window')\...
    Gadget.Gadget_Structure
    Window.Window_Structure
    lastHandle.i
    Flags.i
  EndStructure ;}
  Global NewMap MouseEvent.MouseEvent_Structure()
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================

  ;- _____ Import internal function _____
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; Code by mk-soft
    
    Import ""
      PB_Object_EnumerateStart( PB_Objects )
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      PB_Gadget_Objects.i
    EndImport
    
  CompilerElse
    
    ImportC ""
      PB_Object_EnumerateStart( PB_Objects )
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      PB_Gadget_Objects.i
    EndImport
    
  CompilerEndIf
  
  ;- _____ Events _____
  
  Procedure _MouseEventHandler()
    Define.i X, Y, Handle, Window, Gadget
    
    Window = GetActiveWindow()
    If FindMapElement(MouseEvent(), Str(Window))
    
      X = WindowMouseX(Window)
      Y = WindowMouseY(Window)
      
      If X <> MouseEvent()\Window\MouseX Or Y <> MouseEvent()\Window\MouseY
        
        MouseEvent()\Window\MouseX = X
        MouseEvent()\Window\MouseY = Y
        
        ; Get Handle under mouse (mk-soft)
        CompilerSelect #PB_Compiler_OS
          CompilerCase #PB_OS_Windows ;{ Windows
            Protected.i DesktopX, DesktopY
            
            DesktopX = DesktopMouseX()
            Desktopy = DesktopMouseY()
            Handle   = WindowFromPoint_(DesktopY << 32 | DesktopX)
            ;}
          CompilerCase #PB_OS_MacOS   ;{ MacOS
            Protected WinID.i, WinCV.i, pt.NSPoint
            
            WinID = WindowID(Window)
            WinCV = CocoaMessage(0, WinID, "contentView")
            CocoaMessage(@pt, WinID, "mouseLocationOutsideOfEventStream")
            Handle = CocoaMessage(0, WinCV, "hitTest:@", @pt)
            ;}
          CompilerCase #PB_OS_Linux   ;{ Linux
            Protected DesktopX.i, DesktopY.i, *GdkWindow.GdkWindowObject
            
            *GdkWindow.GdkWindowObject = gdk_window_at_pointer_(@DesktopX,@Desktopy)
            If *GdkWindow
              gdk_window_get_user_data_(*GdkWindow, @Handle)
            Else
              Handle = #False
            EndIf
            ;} 
        CompilerEndSelect
        
        If Handle <> MouseEvent()\lastHandle
          
          ;{ ___ Event: MouseLeave ___ (mk-soft)
          If IsGadget(MouseEvent()\Gadget\Last)
          
            If MouseEvent()\Flags & #MouseLeave
              If GadgetType(MouseEvent()\Gadget\Last) <> #PB_GadgetType_Canvas
                If MouseEvent()\Gadget\Num = #PB_Default Or MouseEvent()\Gadget\Last = MouseEvent()\Gadget\Num
                  PostEvent(#PB_Event_Gadget, MouseEvent()\Window\Num, MouseEvent()\Gadget\Last, #PB_EventType_MouseLeave)
                EndIf
              EndIf
            EndIf
            
            MouseEvent()\Gadget\Last = #PB_Default
            
          EndIf ;}
          
          ; Find GadgetID over Handle (mk-soft)
          PB_Object_EnumerateStart(PB_Gadget_Objects)
          
          While PB_Object_EnumerateNext(PB_Gadget_Objects, @Gadget)
            
            If Handle = GadgetID(Gadget)
              
              MouseEvent()\Gadget\Last = Gadget
              
              ;{ ___ Event: MouseEnter ___ (mk-soft)
              If MouseEvent()\Flags & #MouseEnter
                If GadgetType(MouseEvent()\Gadget\Last) <> #PB_GadgetType_Canvas
                  If MouseEvent()\Gadget\Num = #PB_Default Or MouseEvent()\Gadget\Last = MouseEvent()\Gadget\Num
                    PostEvent(#PB_Event_Gadget, MouseEvent()\Window\Num, MouseEvent()\Gadget\Last, #PB_EventType_MouseEnter)
                  EndIf  
                EndIf
              EndIf ;}
              
              PB_Object_EnumerateAbort(PB_Gadget_Objects)
              Break
            EndIf
            
          Wend
          
          MouseEvent()\lastHandle = Handle
        EndIf
        
        ;{ ___ Event: MouseMove ___ (mk-soft)
        If MouseEvent()\Flags & #MouseMove
          
          If IsGadget(MouseEvent()\Gadget\Last)
            If GadgetType(MouseEvent()\Gadget\Last) <> #PB_GadgetType_Canvas
              If MouseEvent()\Gadget\Num = #PB_Default Or MouseEvent()\Gadget\Last = MouseEvent()\Gadget\Num
                MouseEvent()\Gadget\MouseX = MouseEvent()\Window\MouseX - GadgetX(MouseEvent()\Gadget\Last)
                MouseEvent()\Gadget\MouseY = MouseEvent()\Window\MouseY - GadgetY(MouseEvent()\Gadget\Last)
                PostEvent(#PB_Event_Gadget, MouseEvent()\Window\Num, MouseEvent()\Gadget\Last, #PB_EventType_MouseMove)
              EndIf  
            EndIf
          EndIf
          
        EndIf ;}
        
      EndIf
      
    EndIf

  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================
  
  Procedure.i Add(Window.i, Gadget.i=#PB_Default, Flags.i=#MouseEvents)
    
    If IsWindow(Window)
      
      If AddMapElement(MouseEvent(), Str(Window))
        
        MouseEvent()\Window\Num = Window
        
        If IsGadget(Gadget)
          MouseEvent()\Gadget\Num = Gadget
        Else
          MouseEvent()\Gadget\Num = #PB_Default
        EndIf
        
        MouseEvent()\Flags = Flags
        
        ; Code by mk-soft
        AddWindowTimer(MouseEvent()\Window\Num, #MouseEventTimer, 100)
        BindEvent(#PB_Event_Timer, @_MouseEventHandler())
        
        ProcedureReturn #True
      EndIf

    EndIf
    
  EndProcedure
  
  Procedure.i GetAttribute(Window.i, Attribute.i, Gadget.i=#PB_Default)
    
    If FindMapElement(MouseEvent(), Str(Window))
      
      If Gadget = #PB_Default Or MouseEvent()\Gadget\Last = Gadget
        
        Select Attribute
          Case #MouseX
            ProcedureReturn MouseEvent()\Gadget\MouseX
          Case #MouseY
            ProcedureReturn MouseEvent()\Gadget\MouseY
          Case #Gadget
            ProcedureReturn MouseEvent()\Gadget\Last
        EndSelect

      EndIf  
      
    EndIf
    
    ProcedureReturn #PB_Default
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #Button
    #CheckBox
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 140, 100, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    ButtonGadget(#Button, 20, 20, 100, 30, "Button")
    CheckBoxGadget(#CheckBox, 20, 65, 100, 20, "CheckBoxGadget")
    
    MouseEvent::Add(#Window)

    quitWindow = #False
    
    Repeat
      Select WaitWindowEvent() 
        Case #PB_Event_CloseWindow
          quitWindow = #True
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button
              Select EventType()
                Case #PB_EventType_MouseEnter
                  Debug "MouseEnter: #Button"
                Case #PB_EventType_MouseLeave
                  Debug "MouseLeave: #Button"
                Case #PB_EventType_MouseMove
                  Debug "MouseMove (#Button): " +  Str(MouseEvent::GetAttribute(#Window, MouseEvent::#MouseX)) + " / " + Str(MouseEvent::GetAttribute(#Window, MouseEvent::#MouseY))
              EndSelect  
            Case #CheckBox
              Select EventType()
                Case #PB_EventType_MouseEnter
                  Debug "MouseEnter: #CheckBox"
                Case #PB_EventType_MouseLeave
                  Debug "MouseLeave: #CheckBox"
                Case #PB_EventType_MouseMove
                  Debug "MouseMove (#CheckBox): " +  Str(MouseEvent::GetAttribute(#Window, MouseEvent::#MouseX)) + " / " + Str(MouseEvent::GetAttribute(#Window, MouseEvent::#MouseY))
              EndSelect
          EndSelect
      EndSelect  
    Until quitWindow
    
    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 64
; FirstLine = 10
; Folding = CAg
; EnableXP
; DPIAware