;/ =============================
;/ =    NamedPipeModule.pbi    =
;/ =============================
;/
;/ [ PB V5.7x / 64Bit / Windows ]
;/
;/ NamedPipe - Module
;/
;/ © 2020  by Thorsten Hoeppner (04/2020)
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


;{ _____ NamedPipe - Commands _____

; NamedPipe::GetFullName()     ; Path and name of the pipe

; ----- Server -----
; NamedPipe::GetEventMessage() ; Querying the message after #Event_Message
; NamedPipe::Create()          ; Creates a pipe with the name and starts a thread to read the pipe
; NamedPipe::Pause()           ; Pause the thread to read the pipe
; NamedPipe::Resume()          ; Pause the thread to read the pipe
; NamedPipe::Close()           ; Close the pipe and exit the thread
; NamedPipe::SetMessageReply() ; Set a reply to the receipt of a message.
	
; ----- Client -----
; NamedPipe::SendMessage()     ; Send a message
; NamedPipe::GetReply()        ; Get the answer to the message

;}
	
	
DeclareModule NamedPipe
  
  #Version = 20040600
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  ;{ _____ Constants _____
  #PipePath = "\\.\pipe\"
  
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
	
	Declare.s GetFullName(Name.s)
	
	; ----- Server -----
	Declare.s GetEventMessage()
	Declare.i Create(Name.s)
	Declare   Pause()
	Declare   Resume()
	Declare   Close()
	Declare   SetMessageReply(String.s)
	
	; ----- Client -----
	Declare.i SendMessage(Name.s, Text.s)
	Declare.s GetReply()
	
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
	
	Structure Thread_Structure    ;{ Thread
	  Active.i
	  Msg.i
    Exit.i
  EndStructure ;}
  Global Thread.Thread_Structure

	Structure NamedPipe_Structure ;{ NamedPipe()\...
	  Handle.i
	  Message.s
	  Reply.s
	  Answer.s
	  Thread.i
	EndStructure ;}
	Global NamedPipe.NamedPipe_Structure

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================

	;- __________ Thread __________
	
	Procedure Thread_NamedPipe(pHandle.i)
    Define.i pConnect, BytesAvailable, BytesRead, BytesSend
    Define.s String$, Reply$
    
    Reply$ = NamedPipe\Reply
    
    Repeat
      
      pConnect = ConnectNamedPipe_(pHandle, #Null)
      If pConnect
        
        Thread\Msg = #Msg_Connected
        
        PeekNamedPipe_(pHandle, 0, 0, 0, @BytesAvailable, 0)
        
        If BytesAvailable
          String$ = Space(BytesAvailable)
          ReadFile_(pHandle, @String$, BytesAvailable, @BytesRead, 0)
          FlushFileBuffers_(pHandle)
          If Reply$
            WriteFile_(pHandle, @Reply$, StringByteLength(Reply$), @BytesSend, 0)
            FlushFileBuffers_(pHandle)
          EndIf
          NamedPipe\Message = String$
        EndIf

        If DisconnectNamedPipe_(pHandle)
          Thread\Msg = #Msg_Disconnected
        Else
          CloseHandle_(pHandle)
          Thread\Msg = #Msg_ConnectionFailed
        EndIf
        
        PostEvent(#Event_Message)
        
      EndIf
      
      Delay(1000)
      
    Until Thread\Exit
  
  EndProcedure
	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  Procedure.s GetFullName(Name.s)
    ProcedureReturn #PipePath + Name
  EndProcedure  
  
  
  Procedure.i Create(Name.s)
		Define.i pHandle
		Define.s nPipe$
		
		nPipe$ = #PipePath + Name
		
		pHandle = CreateNamedPipe_(nPipe$, #PIPE_ACCESS_DUPLEX, #PIPE_TYPE_MESSAGE|#PIPE_READMODE_MESSAGE, #PIPE_UNLIMITED_INSTANCES, #BUFFERSIZE, #BUFFERSIZE, 0, #Null)
		If pHandle <> #INVALID_HANDLE_VALUE
		  
		  NamedPipe\Handle = pHandle
		  NamedPipe\Thread = CreateThread(@Thread_NamedPipe(), pHandle)
		  
		  If IsThread(NamedPipe\Thread)
		    Thread\Active = #True
		  EndIf
		  
		  ProcedureReturn pHandle
		EndIf

	EndProcedure
	
	Procedure   Pause()
	  
	  If IsThread(NamedPipe\Thread) And Thread\Active
	    PauseThread(NamedPipe\Thread)
	    Thread\Active = #False
	  EndIf
	  
	EndProcedure  
	
	Procedure   Resume()
	  
	  If IsThread(NamedPipe\Thread) And Thread\Active = #False
	    ResumeThread(NamedPipe\Thread)
	    Thread\Active = #True
	  EndIf
	  
	EndProcedure 
	
	Procedure   Close()
	  
	  Thread\Exit = #True
	  
	  Delay(100)
	  
	  If IsThread(NamedPipe\Thread) : KillThread(NamedPipe\Thread) : EndIf
	  
    Thread\Active = #False
    
    CloseHandle_(NamedPipe\Handle)
    
	EndProcedure
	
	Procedure   SetMessageReply(String.s)
	  NamedPipe\Reply = String
	EndProcedure
	
	Procedure.s GetEventMessage()
    ProcedureReturn NamedPipe\Message
  EndProcedure
  
  
  Procedure.i SendMessage(Name.s, Text.s)
    Define.i Result, fHandle, BytesAvailable, BytesWrite, BytesRead
    Define.s nPipe$, Reply$
    
    nPipe$ = #PipePath + Name
    
    Result = WaitNamedPipe_(nPipe$, #Null)
    If Result
      
      fHandle = CreateFile_(nPipe$, #GENERIC_READ |#GENERIC_WRITE, 0, #Null, #OPEN_EXISTING,0, #Null)
      If fHandle
        
        WriteFile_(fHandle , @Text, StringByteLength(Text), @BytesWrite, 0)
        
        FlushFileBuffers_(fHandle)
        
        PeekNamedPipe_(fHandle, 0, 0, 0, @BytesAvailable, 0)
        
        If BytesAvailable
          Reply$ = Space(BytesAvailable)
          ReadFile_(fHandle, @Reply$, BytesAvailable, @BytesRead, 0)
          NamedPipe\Answer = Reply$
        Else
          NamedPipe\Answer = ""
        EndIf
      
        CloseHandle_(fHandle)
      EndIf

      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  
  EndProcedure
  
  Procedure.s GetReply()
    ProcedureReturn NamedPipe\Answer
  EndProcedure  
  
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
      
      Define.i nPipe
      Define.s Pipe$
      
      If OpenWindow(#Window, 0, 0, 400, 400, "Named Pipe Server", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
        
        Pipe$ = NamedPipe::GetFullName("MyPipe")
        
        EditorGadget (#Editor, 10, 40, 380, 350, #PB_Editor_ReadOnly)
        StringGadget(#String,  10, 10, 150,  20, Pipe$, #PB_String_ReadOnly)
        ButtonGadget(#Button, 170, 10, 50,  20, "Start")
        ButtonGadget(#Pause,  225, 10, 50,  20, "Pause")
        ButtonGadget(#Resume, 280, 10, 50,  20, "Resume")
        
        DisableGadget(#Pause,  #True)
        DisableGadget(#Resume, #True)
        
        NamedPipe::SetMessageReply("OK")
        
        Repeat
          Select WaitWindowEvent()
            Case #PB_Event_CloseWindow
              quitWindow = #True  
            Case NamedPipe::#Event_Message
              AddGadgetItem(#Editor, -1, ">>> " + NamedPipe::GetEventMessage())
            Case #PB_Event_Gadget
              Select EventGadget()
                Case #Button ;{ Start Server
                  If Not nPipe
                    nPipe = NamedPipe::Create("MyPipe")
                    If nPipe
                      AddGadgetItem(#Editor, -1, "Waiting for connection ...")
                      DisableGadget(#Button, #True)
                      DisableGadget(#Pause,  #False)
                    EndIf  
                  EndIf ;}
                Case #Pause
                  NamedPipe::Pause()
                  AddGadgetItem(#Editor, -1, "Pause Server ...")
                  DisableGadget(#Pause,  #True)
                  DisableGadget(#Resume, #False)
                Case #Resume
                  NamedPipe::Resume()
                  AddGadgetItem(#Editor, -1, "Resume Server ...")
                  DisableGadget(#Pause,  #False)
                  DisableGadget(#Resume, #True)
              EndSelect
            
          EndSelect
         
        Until quitWindow
        
        NamedPipe::Close()
        
        CloseWindow(#Window)
      EndIf
      ;}
    CompilerCase #Client ;{ Client
      
      Define.s Pipe$, Reply$
      
      If OpenWindow(#Window, 0, 0, 400, 250, "Named Pipe Client", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

        Pipe$ = NamedPipe::GetFullName("MyPipe")
        
        EditorGadget(#Editor, 10, 40, 380, 200, #PB_Editor_ReadOnly)
        StringGadget(#String, 10, 10, 150, 20, Pipe$, #PB_String_ReadOnly)
        StringGadget(#Text, 170, 10, 165, 20, "Hello Pipe!")
        ButtonGadget(#Button, 340, 9, 50, 22, "Send")
        
        Repeat
          Select WaitWindowEvent()
            Case #PB_Event_CloseWindow  
              quitWindow = #True
            Case #PB_Event_Gadget
              Select EventGadget()
                Case #Button
                  If NamedPipe::SendMessage("MyPipe", GetGadgetText(#Text))
                    AddGadgetItem(#Editor, -1, "Send: " + GetGadgetText(#Text))
                    Reply$ = NamedPipe::GetReply()
                    If Reply$ : AddGadgetItem(#Editor, -1, ">>> " + Reply$): EndIf 
                    SetGadgetText(#Text, "")
                  EndIf   
              EndSelect
          EndSelect
      
        Until quitWindow
          
        CloseWindow(#Window)  
      EndIf
      ;}
  CompilerEndSelect
 
CompilerEndIf

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 330
; FirstLine = 145
; Folding = eAi-
; EnableThread
; EnableXP
; DPIAware