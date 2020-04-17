;/ =============================
;/ =    NamedPipeModule.pbi    =
;/ =============================
;/
;/ [ PB V5.7x / 64Bit / Windows ]
;/
;/ NamedPipe - Module (needs Compileroption Threadsafe)
;/
;/ © 2020  by Thorsten Hoeppner (04/2020)
;/

; Last Update: 17.04.2020

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


;{ _____ NamedPipe - Commands _____

; NamedPipe::GetFullName()     ; Path and name of the pipe

; ----- Server -----
; NamedPipe::EventPipe()       ; Returns the name of the pipe after #Event_Message
; NamedPipe::GetEventMessage() ; Querying the message after #Event_Message
; NamedPipe::Create()          ; Creates a pipe with the name and starts a thread to read the pipe
; NamedPipe::Use()             ; Use an existing pipe and starts a thread to read the pipe
; NamedPipe::Pause()           ; Pause the thread to read the pipe
; NamedPipe::Resume()          ; Resume the thread to read the pipe
; NamedPipe::Close()           ; Close the pipe and exit the thread
; NamedPipe::SetMessageReply() ; Set a reply to the receipt of a message.
	
; ----- Client -----
; NamedPipe::SendMessage()     ; Send a message (Return: Reply)

;}
	

DeclareModule NamedPipe
  
  #Version = 20041700
  
  #Enable_Send    = #True
  #Enable_Recieve = #True
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  ;{ _____ Constants _____
  CompilerSelect  #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #PipePath = "\\.\pipe\"
    CompilerCase #PB_OS_MacOS 
      #PipePath = "notification."
  CompilerEndSelect
  
  Enumeration 1
    #Msg_Connected
    #Msg_Disconnected
    #Msg_ConnectionFailed
  EndEnumeration  
  
	Enumeration #PB_Event_FirstCustomValue
		#Event_Message
	EndEnumeration
	;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
	
	Declare.s GetFullName(pName.s)
	
	; ----- Server -----
	CompilerIf #Enable_Recieve
	  
	  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	    Declare   Pause(pName.s)
	    Declare   Resume(pName.s)
	    Declare   SetMessageReply(pName.s, String.s)
	  CompilerEndIf  
	  
  	Declare.s EventPipe()
  	Declare.s GetEventMessage(pName.s)
  	
  	Declare.i Create(pName.s, Event.i=#Event_Message)
  	Declare.i Use(pName.s)
  	Declare   Close(pName.s)

	CompilerEndIf
	
	; ----- Client -----
	CompilerIf #Enable_Send
	  Declare.s SendMessage(pName.s, Text.s)
	CompilerEndIf
	
EndDeclareModule

Module NamedPipe

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#BUFFERSIZE = 4096

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	  
	Structure NamedPipe_Event_Structure
	  Num.i
    Pipe.s
    Message.s
	  Reply.s
  EndStructure
  
	Structure NamedPipe_Structure ;{ NamedPipe('pName')\...
	  Handle.i
	  ThreadNum.i
	  Event.NamedPipe_Event_Structure
	EndStructure ;}
	Global NewMap NamedPipe.NamedPipe_Structure()
	
	Global EventPipe$
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	  
	  Structure Thread_Structure    ;{ Thread('pHandle')\...
  	  Pipe.s
  	  Active.i
  	  StatusMsg.i
      Exit.i
    EndStructure ;}
    Global NewMap Thread.Thread_Structure()
	  
	  Global Mutex.i = CreateMutex()
	CompilerEndIf  

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================
	
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
	  
	  ; Thanks to wilbert
	  
	  #CFNotificationSuspensionBehaviorDeliverImmediately = 4
	  
	  ImportC "-framework CoreFoundation"
      CFNotificationCenterAddObserver(center, observer, callBack, name, object, suspensionBehavior)
      CFNotificationCenterGetDistributedCenter()
      CFNotificationCenterPostNotification(center, name, object, userInfo, deliverImmediately)
      CFRelease(cf)
      CFStringCreateWithCString(alloc, cStr.p-utf8, encoding = $8000100)
    EndImport
    
	CompilerEndIf
	
	;- __________ Thread / Callback __________
	
	CompilerIf #Enable_Recieve
	  
	  CompilerSelect  #PB_Compiler_OS
	    CompilerCase #PB_OS_Windows
	      
      	Procedure Thread_NamedPipe(pHandle.i)
          Define.i pConnect, BytesAvailable, BytesRead, BytesSend
          Define.s String$, Reply$, pHnd$
      
          Repeat
            
            pConnect = ConnectNamedPipe_(pHandle, #Null)
            If pConnect
              
              LockMutex(Mutex)
              
              ForEach NamedPipe()
                
                If NamedPipe()\Handle = pHandle
                  
                  pHnd$ = Str(pHandle)
                  
                  Thread(pHnd$)\StatusMsg = #Msg_Connected
                  
                  PeekNamedPipe_(pHandle, 0, 0, 0, @BytesAvailable, 0)
                  
                  If BytesAvailable
                    String$ = Space(BytesAvailable)
                    ReadFile_(pHandle, @String$, BytesAvailable, @BytesRead, 0)
                    FlushFileBuffers_(pHandle)
                    Reply$ = NamedPipe()\Event\Reply
                    If Reply$
                      WriteFile_(pHandle, @Reply$, StringByteLength(Reply$), @BytesSend, 0)
                      FlushFileBuffers_(pHandle)
                    EndIf
                    NamedPipe()\Event\Message = String$
                  EndIf
          
                  If DisconnectNamedPipe_(pHandle)
                    Thread(pHnd$)\StatusMsg = #Msg_Disconnected
                  Else
                    CloseHandle_(pHandle)
                    Thread(pHnd$)\StatusMsg = #Msg_ConnectionFailed
                  EndIf
                  
                  EventPipe$ = NamedPipe()\Event\Pipe
                  
                  PostEvent(NamedPipe()\Event\Num, 0, 0, 0, pHandle)

                  Break
                EndIf
              
              Next
              
              UnlockMutex(Mutex)
              
            EndIf
            
            Delay(600)
            
          Until Thread(Str(pHandle))\Exit
        
        EndProcedure
        
      CompilerCase #PB_OS_MacOS
        
        ProcedureC Callback(Center, Observer, Name, Object, UserInfo)
          Define.s nPipe$

          nPipe$ = PeekS(CocoaMessage(0, Object, "UTF8String"), -1, #PB_UTF8)
          If nPipe$
            
            ForEach NamedPipe()
              
              If #PipePath + NamedPipe()\Event\Pipe = nPipe$
                
                NamedPipe()\Event\Message = PeekS(CocoaMessage(0, Name, "UTF8String"), -1, #PB_UTF8)
                
                EventPipe$ = StringField(nPipe$, 2, ".")
                
                PostEvent(NamedPipe()\Event\Num)
                
                Break
              EndIf
              
            Next
            
          EndIf
          
        EndProcedure

    CompilerEndSelect
    
  CompilerEndIf
  
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  Procedure.s EventPipe()
    Define.s Event$
    
    If EventPipe$
      Event$     = EventPipe$
      EventPipe$ = ""
    EndIf
    
    ProcedureReturn Event$
  EndProcedure
  
  Procedure.s GetFullName(pName.s)
    ProcedureReturn #PipePath + pName
  EndProcedure 
  
  Procedure.s GetEventMessage(pName.s)
    Define.s Event$
    
    If FindMapElement(NamedPipe(), pName)
      Event$ = NamedPipe()\Event\Message
	    NamedPipe()\Event\Message = ""
	  EndIf
	  
	  ProcedureReturn Event$
  EndProcedure
  
  
  CompilerIf #Enable_Recieve
    
    CompilerSelect  #PB_Compiler_OS
	    CompilerCase #PB_OS_Windows
    
        Procedure.i Create(pName.s, Event.i=#Event_Message)
      		Define.s nPipe$

      		If FindMapElement(NamedPipe(), pName)
      		  ProcedureReturn NamedPipe()\Handle
      		EndIf  
      		
      		If AddMapElement(NamedPipe(), pName)
      		  
        		nPipe$ = #PipePath + pName
        		
        		NamedPipe()\Handle = CreateNamedPipe_(nPipe$, #PIPE_ACCESS_DUPLEX, #PIPE_TYPE_MESSAGE|#PIPE_READMODE_MESSAGE, #PIPE_UNLIMITED_INSTANCES, #BUFFERSIZE, #BUFFERSIZE, 0, #Null)
        		If NamedPipe()\Handle <> #INVALID_HANDLE_VALUE
        		  
        		  NamedPipe()\Event\Num  = Event
        		  NamedPipe()\Event\Pipe = pName
        		  NamedPipe()\ThreadNum  = CreateThread(@Thread_NamedPipe(), NamedPipe()\Handle)
        		  
        		  If IsThread(NamedPipe()\ThreadNum)
        		    Thread(Str(NamedPipe()\Handle))\Active = #True
        		  EndIf
        		  
        		  ProcedureReturn NamedPipe()\Handle
        		EndIf
        		
        	EndIf 
        	
      	EndProcedure
      	
      	Procedure.i Use(pName.s)
      		Define.s nPipe$
      		
      		If FindMapElement(NamedPipe(), pName)
      		  ProcedureReturn NamedPipe()\Handle
      		EndIf  
      		
      		If AddMapElement(NamedPipe(), pName)
      		  
        		nPipe$ = #PipePath + pName
        		
        		NamedPipe()\Handle = CreateFile_(nPipe$, #GENERIC_READ |#GENERIC_WRITE, 0, #Null, #OPEN_EXISTING,0, #Null)
        		If NamedPipe()\Handle <> #INVALID_HANDLE_VALUE
        		  
        		  NamedPipe()\Event\Pipe = pName
        		  NamedPipe()\ThreadNum  = CreateThread(@Thread_NamedPipe(), NamedPipe()\Handle)
        		  
        		  If IsThread(NamedPipe()\ThreadNum)
        		    Thread(Str(NamedPipe()\Handle))\Active = #True
        		  EndIf
        		  
        		  ProcedureReturn NamedPipe()\Handle
        		EndIf
        		
        	EndIf 
        	
      	EndProcedure
      	
      	Procedure   Pause(pName.s)
      	  Define.s pHnd$
      	  
      	  If FindMapElement(NamedPipe(), pName.s)
      	    
      	    pHnd$ = Str(NamedPipe()\Handle)
      	    
        	  If IsThread(NamedPipe()\ThreadNum) And Thread(pHnd$)\Active
        	    PauseThread(NamedPipe()\ThreadNum)
        	    Thread(pHnd$)\Active = #False
        	  EndIf
        	  
        	EndIf
      	
      	EndProcedure  
      	
      	Procedure   Resume(pName.s)
      	  Define.s pHnd$
      	  
      	  If FindMapElement(NamedPipe(), pName)
      	    
      	    pHnd$ = Str(NamedPipe()\Handle)
      	    
        	  If IsThread(NamedPipe()\ThreadNum) And Thread(pHnd$)\Active = #False
        	    ResumeThread(NamedPipe()\ThreadNum)
        	    Thread(pHnd$)\Active = #True
        	  EndIf
        	  
        	EndIf
      	
      	EndProcedure 
      	
      	Procedure   Close(pName.s)
      	  Define.s pHnd$
      	  
      	  If FindMapElement(NamedPipe(), pName)
      	    
      	    pHnd$ = Str(NamedPipe()\Handle)
      	    
        	  Thread(pHnd$)\Exit = #True
        	  
        	  Delay(100)
        	  
        	  If IsThread(NamedPipe()\ThreadNum) : KillThread(NamedPipe()\ThreadNum) : EndIf
        	  
            Thread(pHnd$)\Active = #False
            
            CloseHandle_(NamedPipe()\Handle)
            
            DeleteMapElement(NamedPipe())
            DeleteMapElement(Thread(), pHnd$)
          EndIf
          
      	EndProcedure
      	
      	Procedure   SetMessageReply(pName.s, String.s)
      	  
      	  If FindMapElement(NamedPipe(), pName)
      	   	NamedPipe()\Event\Reply = String
      	  EndIf
      	  
      	EndProcedure

      CompilerCase #PB_OS_MacOS

        Procedure.i Create(pName.s, Event.i=#Event_Message)
          Define.i dCenter, nObject
      		Define.s nPipe$
      		
      		If FindMapElement(NamedPipe(), pName)
      		  ProcedureReturn #False
      		EndIf  
      		
      		If AddMapElement(NamedPipe(), pName)
      		  
        		nPipe$ = #PipePath + pName

        		nObject = CFStringCreateWithCString(0, nPipe$) ; Thanks to wilbert
        		If nObject

        		  dCenter = CFNotificationCenterGetDistributedCenter()
        		  CFNotificationCenterAddObserver(dCenter, #Null, @Callback(), #Null, nObject, #CFNotificationSuspensionBehaviorDeliverImmediately)
        		  
        		  NamedPipe()\Event\Num  = Event
        		  NamedPipe()\Event\Pipe = pName
        		  
        		  ProcedureReturn #True
        		EndIf
        		
        	EndIf 
        	
      	EndProcedure
      	
      	Procedure.i Use(pName.s)
          Define.i dCenter, nObject
      		Define.s nPipe$

      		If FindMapElement(NamedPipe(), pName)
      		  ProcedureReturn #False
      		EndIf  
      		
      		If AddMapElement(NamedPipe(), pName)
      		  
        		nPipe$ = #PipePath + pName

        		nObject = CFStringCreateWithCString(0, nPipe$) ; Thanks to wilbert
        		If nObject
        		  
        		  dCenter = CFNotificationCenterGetDistributedCenter()
        		  CFNotificationCenterAddObserver(dCenter, #Null, @Callback(), #Null, nObject, #CFNotificationSuspensionBehaviorDeliverImmediately)
        		  
        		  NamedPipe()\Event\Pipe = pName
        		  
        		  ProcedureReturn #True
        		EndIf
        		
        	EndIf 
        	
        EndProcedure
        
        Procedure   Close(pName.s)
      	  
      	  If FindMapElement(NamedPipe(), pName)
            DeleteMapElement(NamedPipe())
          EndIf
          
      	EndProcedure

    CompilerEndSelect

  CompilerEndIf
  
  CompilerIf #Enable_Send
    
    CompilerSelect  #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        
        Procedure.s SendMessage(pName.s, Text.s)
          Define.i Result, fHandle, BytesAvailable, BytesWrite, BytesRead
          Define.s nPipe$, Reply$
          
          nPipe$ = #PipePath + pName
          
          Result = WaitNamedPipe_(nPipe$, #Null)
          If Result
            
            If FindMapElement(NamedPipe(), pName)
              
              WriteFile_(NamedPipe()\Handle , @Text, StringByteLength(Text), @BytesWrite, 0)
              
              FlushFileBuffers_(NamedPipe()\Handle)
              
              PeekNamedPipe_(NamedPipe()\Handle, 0, 0, 0, @BytesAvailable, 0)
              
              If BytesAvailable
                Reply$ = Space(BytesAvailable)
                ReadFile_(NamedPipe()\Handle, @Reply$, BytesAvailable, @BytesRead, 0)
              Else
                Reply$ = ""
              EndIf
              
            Else
              
              fHandle = CreateFile_(nPipe$, #GENERIC_READ |#GENERIC_WRITE, 0, #Null, #OPEN_EXISTING,0, #Null)
              If fHandle
                
                WriteFile_(fHandle , @Text, StringByteLength(Text), @BytesWrite, 0)
                
                FlushFileBuffers_(fHandle)
                
                PeekNamedPipe_(fHandle, 0, 0, 0, @BytesAvailable, 0)
                
                If BytesAvailable
                  Reply$ = Space(BytesAvailable)
                  ReadFile_(fHandle, @Reply$, BytesAvailable, @BytesRead, 0)
                Else
                  Reply$ = ""
                EndIf
              
                CloseHandle_(fHandle)
              EndIf
              
            EndIf
            
            ProcedureReturn Reply$
          EndIf
      
        EndProcedure
        
      CompilerCase #PB_OS_MacOS
        
        Procedure.s SendMessage(pName.s, Text.s)
          Define.i dCenter, Object, nObject
          Define.s nPipe$
          
          nPipe$ = #PipePath + pName
          
          ; Thanks to wilbert
          
          dCenter = CFNotificationCenterGetDistributedCenter()
          Object  = CFStringCreateWithCString(0, nPipe$)
          
          If Text
          
            nObject = CFStringCreateWithCString(0, Text)
            If nObject
              CFNotificationCenterPostNotification(dCenter, nObject, Object, #Null, #True)
              CFRelease(nObject)
            EndIf
            
          EndIf
          
        EndProcedure
        
    CompilerEndSelect
    
  CompilerEndIf
  
EndModule 
  
;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Server = 1
  #Client = 2
  
  #Example = #Server
  
  Enumeration 
    #Window
    #Editor
    #Button
    #String
    #Text
    #Pause
    #Resume
  EndEnumeration
  
  Define.i quitWindow = #False
  
  CompilerSelect #Example
    CompilerCase #Server ;{ Server
      
      CompilerIf NamedPipe::#Enable_Recieve
        
        Define.i nPipe
        Define.s Pipe$
        
        If OpenWindow(#Window, 0, 0, 400, 400, "Named Pipe Server", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
          
          Pipe$ = NamedPipe::GetFullName("mdHelp")
          
          EditorGadget (#Editor, 10, 40, 380, 350, #PB_Editor_ReadOnly)
          StringGadget(#String,  10, 10, 150,  20, Pipe$, #PB_String_ReadOnly)
          ButtonGadget(#Button, 170, 10, 60,  20, "Start")
          ButtonGadget(#Pause,  235, 10, 60,  20, "Pause")
          ButtonGadget(#Resume, 300, 10, 60,  20, "Resume")
          
          DisableGadget(#Pause,  #True)
          DisableGadget(#Resume, #True)
          
          CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
            HideGadget(#Pause,  #True)
            HideGadget(#Resume, #True)
          CompilerEndIf
  
          Repeat
            Select WaitWindowEvent()
              Case #PB_Event_CloseWindow
                quitWindow = #True  
              Case NamedPipe::#Event_Message
                Select NamedPipe::EventPipe()
                  Case "mdHelp"
                    AddGadgetItem(#Editor, -1, ">>> " + NamedPipe::GetEventMessage("mdHelp"))
                EndSelect  
              Case #PB_Event_Gadget
                Select EventGadget()
                  Case #Button ;{ Start Server
                    If Not nPipe
                      nPipe = NamedPipe::Create("mdHelp")
                      If nPipe
                        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
                          NamedPipe::SetMessageReply("mdHelp", "OK")
                        CompilerEndIf  
                        AddGadgetItem(#Editor, -1, "Waiting for connection ...")
                        DisableGadget(#Button, #True)
                        DisableGadget(#Pause,  #False)
                      EndIf  
                    EndIf
                    ;}
                  CompilerIf #PB_Compiler_OS = #PB_OS_Windows    
                    Case #Pause
                      NamedPipe::Pause("mdHelp")
                      AddGadgetItem(#Editor, -1, "Pause Server ...")
                      DisableGadget(#Pause,  #True)
                      DisableGadget(#Resume, #False)
                    Case #Resume
                      NamedPipe::Resume("mdHelp")
                      AddGadgetItem(#Editor, -1, "Resume Server ...")
                      DisableGadget(#Pause,  #False)
                      DisableGadget(#Resume, #True)
                  CompilerEndIf    
                EndSelect
              
            EndSelect
           
          Until quitWindow
          
          NamedPipe::Close("mdHelp")
          CloseWindow(#Window)
        EndIf
        
      CompilerEndIf  
      ;}
    CompilerCase #Client ;{ Client
      
      CompilerIf NamedPipe::#Enable_Send
        
        Define.s Pipe$, Reply$
        
        If OpenWindow(#Window, 0, 0, 400, 250, "Named Pipe Client", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  
          Pipe$ = NamedPipe::GetFullName("mdHelp")
          
          EditorGadget(#Editor, 10, 40, 380, 200, #PB_Editor_ReadOnly)
          StringGadget(#String, 10, 10, 150, 20, Pipe$, #PB_String_ReadOnly)
          StringGadget(#Text, 170, 10, 160, 20, "Hello Pipe!")
          ButtonGadget(#Button, 335, 9, 55, 22, "Send")
          
          Repeat
            Select WaitWindowEvent()
              Case #PB_Event_CloseWindow  
                quitWindow = #True
              Case #PB_Event_Gadget
                Select EventGadget()
                  Case #Button
                    Reply$ = NamedPipe::SendMessage("mdHelp", GetGadgetText(#Text))
                    AddGadgetItem(#Editor, -1, "Send: " + GetGadgetText(#Text))
                    If Reply$ : AddGadgetItem(#Editor, -1, ">>> " + Reply$): EndIf 
                    SetGadgetText(#Text, "")  
                EndSelect
            EndSelect
        
          Until quitWindow
          
          CloseWindow(#Window)  
        EndIf
        
      CompilerEndIf  
      ;}
  CompilerEndSelect
 
CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 105
; FirstLine = 39
; Folding = 1HHDAk4
; EnableThread
; EnableXP
; DPIAware