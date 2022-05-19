;/ ===========================
;/ =    OpenWith - Module.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / all OS ]
;/
;/ based on code of Sicro (2018)
;/
;/ Module by Thorsten Hoeppner (10/2019)
;/

;{ ===== MIT License =====
;
; Copyright (c) 2018 Sicro
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

;{ _____ OpenWith - Commands _____

; OpenWith::Program() - Open file with the default program for this file type


;}

DeclareModule OpenWith
  
  Declare.i Program(File.s)
  Declare.i EMail(Recipient.s, Subject.s="", Body.s="", CcRecipient.s="", BccRecipient.s="", AttachFile.s="")
  
EndDeclareModule


Module OpenWith
  
  EnableExplicit
  
  Procedure.s MultiParameter(Parameter.s, Value.s)
    Define.i i, Count
    
    Count = CountString(Value, ",")
    If Count = 0
      ProcedureReturn Parameter + #DQUOTE$ + Value + #DQUOTE$
    Else
      For i = 1 To Count + 1
        ProcedureReturn Parameter + #DQUOTE$ + StringField(Value, i, ",") + #DQUOTE$
      Next
    EndIf
 
  EndProcedure

  ;- ==================================
  ;-   Module - Declared Procedures
  ;- ================================== 
  
  Procedure.i Program(File.s)
    Define.i Result

    File = #DQUOTE$ + File + #DQUOTE$ ; Avoid problems with paths containing spaces
   
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shellexecutew
        Result = Bool(ShellExecute_(0, "open", File, #Null, #Null, #SW_SHOW) > 32)
      CompilerCase #PB_OS_Linux
        ; https://portland.freedesktop.org/doc/xdg-open.html
        Result = RunProgram("xdg-open", File, GetCurrentDirectory())
      CompilerCase #PB_OS_MacOS
        Result = RunProgram("open", File, GetCurrentDirectory())
    CompilerEndSelect
   
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i EMail(Recipient.s, Subject.s="", Body.s="", CcRecipient.s="", BccRecipient.s="", AttachFile.s="")
    Define.i Result, Prog
    Define.s Parameter$

    If Recipient = "" : ProcedureReturn #False : EndIf
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux
        ; https://portland.freedesktop.org/doc/xdg-email.html
        
        Parameter$ = " --utf8"
        
        If Subject      : Parameter$ + " --subject " + #DQUOTE$ + Subject + #DQUOTE$ : EndIf
        If Body         : Parameter$ + " --body "    + #DQUOTE$ + ReplaceString(Body, #CRLF$, #CR$) + #DQUOTE$ : EndIf
        If AttachFile   : Parameter$ + MultiParameter(" --attach ", AttachFile)   : EndIf
        If CcRecipient  : Parameter$ + MultiParameter(" --cc ",     CcRecipient)  : EndIf
        If BccRecipient : Parameter$ + MultiParameter(" --bcc ",    BccRecipient) : EndIf  
        
        Parameter$ +  + MultiParameter(" ", Recipient)
        
        Prog = RunProgram("xdg-email", Parameter$, GetCurrentDirectory(), #PB_Program_Open)
        If Prog
          WaitProgram(Prog)
          Result = Bool(ProgramExitCode(Prog) = 0)
          CloseProgram(Prog)
        EndIf
        
      CompilerDefault ; #PB_OS_Windows / #PB_OS_MacOS
        ; https://tools.ietf.org/html/rfc6068
        
        If Subject      : Parameter$ + "&subject=" + Subject      : EndIf 
        If Body         : Parameter$ + "&body="    + Body         : EndIf
        If CcRecipient  : Parameter$ + "&cc="      + CcRecipient  : EndIf
        If BccRecipient : Parameter$ + "&bcc="     + BccRecipient : EndIf
        If AttachFile   : Parameter$ + "&attach="  + AttachFile : EndIf
        ; The "mailto" protocol does not support file attachments
        
        If Parameter$ : Parameter$ = "?" + LTrim(Parameter$, "&") : EndIf
        
        CompilerSelect #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shellexecutew
            Result = Bool(ShellExecute_(0, "open", "mailto:" + URLEncoder(Recipient + Parameter$), #Null, #Null, #SW_SHOW) > 32)
          CompilerCase #PB_OS_MacOS
            Result = RunProgram("open", "mailto:" + URLEncoder(Recipient + Parameter$), GetCurrentDirectory())
        CompilerEndSelect
        
    CompilerEndSelect

    ProcedureReturn Result
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  ;OpenWith::Program("https://www.purebasic.com")
  
  PictureFilePath$ = #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp"
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ReplaceString(PictureFilePath$, "/", "\", #PB_String_InPlace)
  CompilerEndIf
  
  ;OpenWith::Program(PictureFilePath$)

  Recipient$    = "FirstName Surname <aaa@mailserver.com>,bbb@mailserver.com"
  Subject$      = "A test email"
  Body$         = "Ladies and gentlemen," + #CRLF$ + #CRLF$ + "this is a test." + #CRLF$ + #CRLF$ + "With kind regards" + #CRLF$ + "The Tester"
  CCRecipient$  = "cc1@test.de,FirstName Surname <cc2@test.de>"
  BCCRecipient$ = "FirstName Surname <bcc1@test.de>,bcc2@test.de"
  
  OpenWith::EMail(Recipient$, Subject$, Body$, CCRecipient$, BCCRecipient$)
  
CompilerEndIf  
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 163
; FirstLine = 29
; Folding = O+
; EnableXP
; DPIAware