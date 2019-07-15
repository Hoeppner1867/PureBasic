;/ =================================
;/ =    ThreadControlModule.pbi    =
;/ =================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Version 1.05
;/
;/ © 2019 by  mk-soft (07/2019)
;/ 
;/ Module by Thorsten1867
;/

; Last Update: 15.7.2019

;{ ===== MIT License =====
;
; Copyright (c) 2019 mk-soft
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

;{ _____ ThreadControl - Commands _____

; Thread::Start()
; Thread::Stop()
; Thread::Pause()
; Thread::Resume()
; Thread::GetState()
; Thread::Free() 

;}

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Use Compiler-Option ThreadSafe!"
CompilerEndIf

DeclareModule Thread
  
  ;- ==========================================================================
	;-   DeclareModule - Structure
  ;- ==========================================================================  
  
  Structure Control_Structure ;{ Thread::Control_Structure
    ID.i
    UserID.i
    Signal.i
    Pause.i
    Exit.i
  EndStructure ;}
  
  ;- ==========================================================================
	;-   DeclareModule
  ;- ==========================================================================
  
  Declare.i Start(ID.i, *Procedure, *Data.Control_Structure)
  Declare   Stop(ID.i, Wait.i=1000)
  Declare   Pause(ID.i)
  Declare   Resume(ID.i)
  Declare.i GetState(ID.i)
  Declare.i Free(ID.i, Stop.i=#True, Wait.i=1000)
  
EndDeclareModule  

Module Thread
  
  EnableExplicit
  
  ;- ==========================================================================
	;-   Module - Structures
  ;- ==========================================================================
  
  Structure ThreadControl_Structure ;{ Thread('UserID')\...
    ID.i
    *Data
  EndStructure ;}
  Global NewMap Thread.ThreadControl_Structure()
  
  Global Mutex.i = CreateMutex()
  
  ;- ==========================================================================
	;-   Module - Internal
  ;- ==========================================================================
  
  ;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================  
  
  Procedure.i Start(ID.i, *Procedure, *Data.Control_Structure)
    Define.i ThreadID
    
    LockMutex(Mutex)
    
    If AddMapElement(Thread(), Str(ID))
      
      If Not IsThread(Thread()\ID)
        Thread()\ID      = CreateThread(*Procedure, *Data)
        Thread()\Data    = *Data
        *Data\ID = Thread()\ID
        *Data\UserID = ID
      Else
        ThreadID = Thread()\ID
      EndIf
      
    EndIf
    
    UnlockMutex(Mutex)
    
    ProcedureReturn ThreadID
  EndProcedure
  
  Procedure   Stop(ID.i, Wait.i=1000)
    Define *Data.Control_Structure

    If FindMapElement(Thread(), Str(ID))

      If IsThread(Thread()\ID)
        
        *Data = Thread()\Data
        
        LockMutex(Mutex)

        *Data\Exit = #True
        
        If *Data\Pause
          *Data\Pause = #False
          SignalSemaphore(*Data\Signal)
        EndIf
        
        If WaitThread(*Data\ID, Wait) = 0
          KillThread(*Data\ID)
        EndIf
        
        *Data\ID    = #False
        *Data\Pause = #False
        *Data\Exit  = #False
        
        If *Data\Signal
          FreeSemaphore(*Data\Signal)
          *Data\Signal = #False
        EndIf
        
        UnlockMutex(Mutex)
        
      EndIf   
      
    EndIf

  EndProcedure
  
  Procedure   Pause(ID.i)
    Define *Data.Control_Structure

    If FindMapElement(Thread(), Str(ID))

      If IsThread(Thread()\ID)
        
        *Data = Thread()\Data
      
        LockMutex(Mutex)
        
        If Not *Data\Signal
          *Data\Signal = CreateSemaphore()
        EndIf
        
        If Not *Data\Pause
          *Data\Pause = #True
        EndIf
        
        UnlockMutex(Mutex)
        
      EndIf

    EndIf 

  EndProcedure
  
  Procedure   Resume(ID.i)
    Define *Data.Control_Structure
   
    If FindMapElement(Thread(), Str(ID))
      
      If IsThread(Thread()\ID)
        
        *Data = Thread()\Data
        
        LockMutex(Mutex)
        
        If *Data\Pause
          *Data\Pause = #False
          SignalSemaphore(*Data\Signal)
        EndIf
        
        UnlockMutex(Mutex)
        
      EndIf
      
    EndIf

  EndProcedure
  
  Procedure.i GetState(ID.i)
    Define *Data.Control_Structure

    If FindMapElement(Thread(), Str(ID))
      
      If IsThread(Thread()\ID)
        
        *Data = Thread()\Data
        
        LockMutex(Mutex)
        
        If *Data\Pause
          ProcedureReturn #False
        Else
          ProcedureReturn #True
        EndIf
        
        UnlockMutex(Mutex)
        
      EndIf
    
    EndIf  

  EndProcedure  
 
  Procedure.i Free(ID.i, Stop.i=#True, Wait.i=1000)
    Define *Data.Control_Structure
    
    If FindMapElement(Thread(), Str(ID))
      
      *Data = Thread()\Data
      
      LockMutex(Mutex)
      
      If IsThread(Thread()\ID)
        
        If Stop
          Stop(ID, Wait)
          FreeStructure(*Data)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
        
      Else
        
        If *Data\Signal
          FreeSemaphore(*Data\Signal)
        EndIf
        
        FreeStructure(*Data)
        DeleteMapElement(Thread())
        
        ProcedureReturn #True
      EndIf
      
      UnlockMutex(Mutex)
      
    EndIf  

  EndProcedure 
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 1
    #Window
    #Start1
    #Start2
    #Pause1
    #Pause2
    #Stop1
    #Stop2
  EndEnumeration  
  
  Enumeration 1
    #Thread1
    #Thread2
  EndEnumeration
  
  Enumeration #PB_Event_FirstCustomValue
    #MyEvent_ThreadFinished
  EndEnumeration
  
  Structure FileData_Structure
    Name.s
    Result.s
    Image.i
  EndStructure
  
  Structure ThreadData_Structure Extends Thread::Control_Structure
    ; Data
    Window.i
    Gadget.i
    Event.i
    List Files.FileData_Structure()
  EndStructure
  
  
  Procedure _ThreadHandler(*Thread.ThreadData_Structure)
    Protected c
    
    Debug "Init Thread " + *Thread\UserID
    Delay(500)
    Debug "Start Thread " + *Thread\UserID
   
    ForEach *Thread\Files()
      
      ; Query on Thread Pause
      If *Thread\Pause
        Debug "Pause Thread " + *Thread\UserID
        WaitSemaphore(*Thread\Signal)
        Debug "Resume Thread " + *Thread\UserID
      EndIf
      
      ; Cancel query on thread
      If *Thread\Exit : Break : EndIf
      ;TODO
      Debug "Busy Thread " + *Thread\UserID + ": File " + *Thread\Files()\Name
      Delay(500)
      *Thread\Files()\Result = "Ready."
    Next
    
    If *Thread\Exit
      ;TODO Cancel Thread
      Debug "Cancel Thread " + *Thread\UserID
    Else
      ;TODO Exit Thread
      Debug "Shutdown Thread " + *Thread\UserID
      PostEvent(*Thread\Event, *Thread\Window, 0, 0, *Thread)
    EndIf
    
    Debug "Exit Thread " + *Thread\UserID
    If Not *Thread\Exit
      *Thread\ID = 0 ; Only if the thread terminates itself
    EndIf

  EndProcedure
  
  ; Dummy Data  
  Global *Thread1.ThreadData_Structure = AllocateStructure(ThreadData_Structure)
  *Thread1\UserID = 1
  *Thread1\Window = 1
  *Thread1\Event = #MyEvent_ThreadFinished
  For i = 10 To 30
    AddElement(*Thread1\Files())
    *Thread1\Files()\Name = "File_" + i
  Next
  
  Global *Thread2.ThreadData_Structure = AllocateStructure(ThreadData_Structure)
  *Thread2\UserID = 2
  *Thread2\Window = 1
  *Thread2\Event = #MyEvent_ThreadFinished
  For i = 31 To 60
    AddElement(*Thread2\Files())
    *Thread2\Files()\Name = "File_" + i
  Next
  
  ; Output Data
  Procedure Output(*Data.ThreadData_Structure)
    Debug "Thread Finished UserID " + *Data\UserID
    MessageRequester("Thread Message", "Thread Finished UserID " + *Data\UserID)
    ForEach *Data\Files()
      Debug *Data\Files()\Name + " - Result " + *Data\Files()\Result
    Next
  EndProcedure
  
  
  If OpenWindow(#Window, 0, 0, 222, 250, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered)
    
    ButtonGadget(#Start1, 10,  10, 200, 30, "Start 1")
    ButtonGadget(#Start2, 10,  50, 200, 30, "Start 2")
    ButtonGadget(#Pause1, 10,  90, 200, 30, "Pause 1")
    ButtonGadget(#Pause2, 10, 130, 200, 30, "Pause 2")
    ButtonGadget(#Stop1,  10, 170, 200, 30, "Stop 1")
    ButtonGadget(#Stop2,  10, 210, 200, 30, "Stop 2")
    
    Repeat
      Select WaitWindowEvent() 
        Case #PB_Event_CloseWindow
          Thread::Stop(#Thread1)
          Thread::Free(#Thread1)
          Thread::Stop(#Thread2)
          Thread::Free(#Thread2)
          Break
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Start1
              Thread::Start(#Thread1, @_ThreadHandler(), *Thread1)
            Case #Start2
              Thread::Start(#Thread2, @_ThreadHandler(), *Thread2)
            Case #Pause1
              If Thread::GetState(#Thread1) 
                Thread::Pause(#Thread1)
                SetGadgetText(#Pause1, "Resume 1")
              Else
                Thread::Resume(#Thread1)
                SetGadgetText(#Pause1, "Pause 1")
              EndIf
            Case #Pause2
              If Thread::GetState(#Thread2) 
                Thread::Pause(#Thread2)
                SetGadgetText(#Pause2, "Resume 2")
              Else
                Thread::Resume(#Thread2)
                SetGadgetText(#Pause2, "Pause 2")
              EndIf
            Case #Stop1
              Thread::Stop(#Thread1)
              SetGadgetText(#Pause1, "Pause 1")
            Case #Stop2
              Thread::Stop(#Thread2)
              SetGadgetText(#Pause2, "Pause 2")
          EndSelect
          
        Case #MyEvent_ThreadFinished
          Output(EventData())
          
      EndSelect
    ForEver
    
    CloseWindow(#Window)  
  EndIf
  
CompilerEndIf
  
; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 73
; FirstLine = 78
; Folding = tA5
; EnableThread
; EnableXP
; DPIAware