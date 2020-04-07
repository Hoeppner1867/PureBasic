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

; Last Update: 07.04.2020

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
  
  #Version = 20040700
  
  #Enable_Send    = #True
  #Enable_Recieve = #True
  
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
	CompilerIf #Enable_Recieve
  	Declare.s EventPipe()
  	Declare.s GetEventMessage(Name.s)
  	Declare.i Create(Name.s)
  	Declare.i Use(Name.s)
  	Declare   Pause(Name.s)
  	Declare   Resume(Name.s)
  	Declare   Close(Name.s)
  	Declare   SetMessageReply(Name.s, String.s)
	CompilerEndIf
	
	; ----- Client -----
	CompilerIf #Enable_Send
	  Declare.s SendMessage(Name.s, Text.s)
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
	
	Structure Thread_Structure    ;{ NamedPipe()\Thread\...
	  Pipe.s
	  Handle.i
	  Active.i
	  StatusMsg.i
	  Message.s
	  Reply.s
    Exit.i
  EndStructure ;}
  
  Global EventPipe.s
  
	Structure NamedPipe_Structure ;{ NamedPipe('name')\...
	  Handle.i
	  ThreadNum.i
	  Thread.Thread_Structure
	EndStructure ;}
	Global NewMap NamedPipe.NamedPipe_Structure()

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================

	;- __________ Thread __________
	
	CompilerIf #Enable_Recieve
	  
  	Procedure Thread_NamedPipe(*Thread.Thread_Structure)
      Define.i pConnect, BytesAvailable, BytesRead, BytesSend
      Define.s String$, Reply$
  
      Repeat
        
        pConnect = ConnectNamedPipe_(*Thread\Handle, #Null)
        If pConnect
          
          *Thread\StatusMsg = #Msg_Connected
          
          PeekNamedPipe_(*Thread\Handle, 0, 0, 0, @BytesAvailable, 0)
          
          If BytesAvailable
            String$ = Space(BytesAvailable)
            ReadFile_(*Thread\Handle, @String$, BytesAvailable, @BytesRead, 0)
            FlushFileBuffers_(*Thread\Handle)
            Reply$ = *Thread\Reply
            If Reply$
              WriteFile_(*Thread\Handle, @Reply$, StringByteLength(Reply$), @BytesSend, 0)
              FlushFileBuffers_(*Thread\Handle)
            EndIf
            *Thread\Message = String$
          EndIf
  
          If DisconnectNamedPipe_(*Thread\Handle)
            *Thread\StatusMsg = #Msg_Disconnected
          Else
            CloseHandle_(*Thread\Handle)
            *Thread\StatusMsg = #Msg_ConnectionFailed
          EndIf
          
          EventPipe = *Thread\Pipe
          PostEvent(#Event_Message)
          
        EndIf
        
        Delay(1000)
        
      Until *Thread\Exit
    
    EndProcedure
    
  CompilerEndIf
  
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  Procedure.s GetFullName(Name.s)
    ProcedureReturn #PipePath + Name
  EndProcedure  
  
  CompilerIf #Enable_Recieve
    
    Procedure.i Create(Name.s)
  		Define.s nPipe$
  		
  		CompilerIf #PB_Compiler_Thread = #False
        CompilerError "Use Compileroption Threadsafe!"
      CompilerEndIf	
  		
  		If FindMapElement(NamedPipe(), Name)
  		  ProcedureReturn NamedPipe()\Handle
  		EndIf  
  		
  		If AddMapElement(NamedPipe(), Name)
  		  
    		nPipe$ = #PipePath + Name
    		
    		NamedPipe()\Handle = CreateNamedPipe_(nPipe$, #PIPE_ACCESS_DUPLEX, #PIPE_TYPE_MESSAGE|#PIPE_READMODE_MESSAGE, #PIPE_UNLIMITED_INSTANCES, #BUFFERSIZE, #BUFFERSIZE, 0, #Null)
    		If NamedPipe()\Handle <> #INVALID_HANDLE_VALUE
    		  
    		  NamedPipe()\Thread\Pipe   = Name
    		  NamedPipe()\Thread\Handle = NamedPipe()\Handle
    		  
    		  NamedPipe()\ThreadNum = CreateThread(@Thread_NamedPipe(), @NamedPipe()\Thread)
    		  
    		  If IsThread(NamedPipe()\ThreadNum)
    		    NamedPipe()\Thread\Active = #True
    		  EndIf
    		  
    		  ProcedureReturn NamedPipe()\Handle
    		EndIf
    		
    	EndIf 
    	
  	EndProcedure
  	
  	Procedure.i Use(Name.s)
  		Define.s nPipe$
  		
  		CompilerIf #PB_Compiler_Thread = #False
        CompilerError "Use Compileroption Threadsafe!"
      CompilerEndIf	
  		
  		If FindMapElement(NamedPipe(), Name)
  		  ProcedureReturn NamedPipe()\Handle
  		EndIf  
  		
  		If AddMapElement(NamedPipe(), Name)
  		  
    		nPipe$ = #PipePath + Name
    		
    		NamedPipe()\Handle = CreateFile_(nPipe$, #GENERIC_READ |#GENERIC_WRITE, 0, #Null, #OPEN_EXISTING,0, #Null)
    		If NamedPipe()\Handle <> #INVALID_HANDLE_VALUE
    		  
    		  NamedPipe()\Thread\Pipe   = Name
    		  NamedPipe()\Thread\Handle = NamedPipe()\Handle
    		  
    		  NamedPipe()\ThreadNum = CreateThread(@Thread_NamedPipe(), @NamedPipe()\Thread)
    		  
    		  If IsThread(NamedPipe()\ThreadNum)
    		    NamedPipe()\Thread\Active = #True
    		  EndIf
    		  
    		  ProcedureReturn NamedPipe()\Handle
    		EndIf
    		
    	EndIf 
    	
  	EndProcedure
  	
  	Procedure   Pause(Name.s)
  	  
  	  If FindMapElement(NamedPipe(), Name.s)
  	    
    	  If IsThread(NamedPipe()\ThreadNum) And NamedPipe()\Thread\Active
    	    PauseThread(NamedPipe()\ThreadNum)
    	    NamedPipe()\Thread\Active = #False
    	  EndIf
    	  
    	EndIf
  	
  	EndProcedure  
  	
  	Procedure   Resume(Name.s)
  	  
  	  If FindMapElement(NamedPipe(), Name)
  	    
    	  If IsThread(NamedPipe()\ThreadNum) And NamedPipe()\Thread\Active = #False
    	    ResumeThread(NamedPipe()\ThreadNum)
    	    NamedPipe()\Thread\Active = #True
    	  EndIf
    	  
    	EndIf
  	
  	EndProcedure 
  	
  	Procedure   Close(Name.s)
  	  
  	  If FindMapElement(NamedPipe(), Name)
  	    
    	  NamedPipe()\Thread\Exit = #True
    	  
    	  Delay(100)
    	  
    	  If IsThread(NamedPipe()\ThreadNum) : KillThread(NamedPipe()\ThreadNum) : EndIf
    	  
        NamedPipe()\Thread\Active = #False
        
        CloseHandle_(NamedPipe()\Handle)
      EndIf
      
  	EndProcedure
  	
  	Procedure   SetMessageReply(Name.s, String.s)
  	  
  	  If FindMapElement(NamedPipe(), Name)
  	   	NamedPipe()\Thread\Reply = String
  	  EndIf
  	  
  	EndProcedure
  	
  	Procedure.s EventPipe()
  	  ProcedureReturn EventPipe
  	EndProcedure  
  	
  	Procedure.s GetEventMessage(Name.s)
  	  
  	  If FindMapElement(NamedPipe(), Name)
  	    ProcedureReturn NamedPipe()\Thread\Message
  	  EndIf
  	  
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #Enable_Send
    
    Procedure.s SendMessage(Name.s, Text.s)
      Define.i Result, fHandle, BytesAvailable, BytesWrite, BytesRead
      Define.s nPipe$, Reply$
      
      nPipe$ = #PipePath + Name
      
      Result = WaitNamedPipe_(nPipe$, #Null)
      If Result
        
        If FindMapElement(NamedPipe(), Name)
          
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
          
          Pipe$ = NamedPipe::GetFullName("MyPipe")
          
          EditorGadget (#Editor, 10, 40, 380, 350, #PB_Editor_ReadOnly)
          StringGadget(#String,  10, 10, 150,  20, Pipe$, #PB_String_ReadOnly)
          ButtonGadget(#Button, 170, 10, 50,  20, "Start")
          ButtonGadget(#Pause,  225, 10, 50,  20, "Pause")
          ButtonGadget(#Resume, 280, 10, 50,  20, "Resume")
          
          DisableGadget(#Pause,  #True)
          DisableGadget(#Resume, #True)
  
          Repeat
            Select WaitWindowEvent()
              Case #PB_Event_CloseWindow
                quitWindow = #True  
              Case NamedPipe::#Event_Message
                Select NamedPipe::EventPipe()
                  Case "MyPipe"
                    AddGadgetItem(#Editor, -1, ">>> " + NamedPipe::GetEventMessage("MyPipe"))
                EndSelect  
              Case #PB_Event_Gadget
                Select EventGadget()
                  Case #Button ;{ Start Server
                    If Not nPipe
                      nPipe = NamedPipe::Create("MyPipe")
                      If nPipe
                        NamedPipe::SetMessageReply("MyPipe", "OK")
                        AddGadgetItem(#Editor, -1, "Waiting for connection ...")
                        DisableGadget(#Button, #True)
                        DisableGadget(#Pause,  #False)
                      EndIf  
                    EndIf
                    ;}
                  Case #Pause
                    NamedPipe::Pause("MyPipe")
                    AddGadgetItem(#Editor, -1, "Pause Server ...")
                    DisableGadget(#Pause,  #True)
                    DisableGadget(#Resume, #False)
                  Case #Resume
                    NamedPipe::Resume("MyPipe")
                    AddGadgetItem(#Editor, -1, "Resume Server ...")
                    DisableGadget(#Pause,  #False)
                    DisableGadget(#Resume, #True)
                EndSelect
              
            EndSelect
           
          Until quitWindow
          
          NamedPipe::Close("MyPipe")
          CloseWindow(#Window)
        EndIf
        
      CompilerEndIf  
      ;}
    CompilerCase #Client ;{ Client
      
      CompilerIf NamedPipe::#Enable_Send
        
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
                    Reply$ = NamedPipe::SendMessage("MyPipe", GetGadgetText(#Text))
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
; CursorPosition = 51
; FirstLine = 12
; Folding = MJBgm+
; EnableThread
; EnableXP
; DPIAware