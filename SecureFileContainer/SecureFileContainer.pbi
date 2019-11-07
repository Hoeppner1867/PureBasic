;/ ==================================
;/ =    SecureFileContainer.pbi    =
;/ ==================================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/
;/ © 2019 Thorsten1867 (08/2019)
;/

; Last Update: 7.11.2019
;
; BugFix: IsProgID()
;

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


;{ _____ SecureFileContainer.pbi - Commands _____

; SFC::Create()            - create a new file container
; SFC::Open()              - open an existing file container
; SFC::Close()             - close the file container
  
; SFC::AddFile()           - add a file to the file container
; SFC::UseFile()           - use the file (=> decrypt it and extract it from the container)

; SFC::AddXML()            - add XML as file to the container
; SFC::UseXML()            - load XML directly from the container 
  
; SFC::AddJSON()           - add JSON as file to the container
; SFC::UseJSON()           - load JSON directly from the container 
  
; SFC::AddImage()          - add Image as file to the container
; SFC::UseImage()          - load Image directly from the container 
  
; SFC::AddText()           - add string as file to the container
; SFC::UseText(s)          - load string directly from the container 
  
; SFC::ProgressProcedure() - define procedure to show progress
  
; SFC::IsProgID()          - check whether the container has the correct ProgID.
; SFC::IsCorrectKey()      - check if the key is correct.
  
; SFC::GetInfo()           - get container infos (ProgID/Author/Titel/Subject/Creator)
; SFC::SetInfo()           - change container infos (ProgID/Author/Titel/Subject/Creator)

;}


DeclareModule SFC
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- ===========================================================================  
  
  Enumeration 1                ;{ Info
    #ProgID
    #Author
    #Title
    #Subject
    #Creator
  EndEnumeration ;}
  
  Enumeration 1
    #MoveBack
    #Update
  EndEnumeration
  
  Enumeration 1                ;{ Progress\Flags
    #SecureKey
    #Compress
    #Encrypt
    #Finished
    #Rebuild
  EndEnumeration ;}
  
  Enumeration 1                ;{ Error Messages
    #ERROR_CANT_CREATE_COUNTER
    #ERROR_CANT_CREATE_PACK
    #ERROR_CANT_OPEN_PACK
    #ERROR_CANT_UNCOMPRESS_FILE
    #ERROR_CANT_UNCOMPRESS_PACKMEMORY
    #ERROR_FILE_NOT_EXIST
    #ERROR_CANT_OPEN_FILE
    #ERROR_ENCODING_FAILS
    #ERROR_NOT_ENCRYPTED
    #ERROR_REBUILD_FAILED
    #ERROR_INTEGRITY_CORRUPTED
  EndEnumeration ;}
  
  Structure Progress_Structure ;{ Progress\...
    Gadget.i
    State.i
    Row.i
    Index.i
    Label.s
    Compress.s
    Encrypt.s
    Flags.i
  EndStructure ;}
  Global Progress.Progress_Structure
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i Create(ID.i, File.s, ProgID.s="", Key.s="")
  Declare.i Open(ID.i, File.s, Key.s="")
  Declare   Close(ID.i, Flags.i=#MoveBack)
  
  Declare.i AddFile(ID.i, File.s)
  Declare.i AddXML(ID.i, XML.i, FileName.s)
  
  Declare.i UseFile(ID.i, File.s)
  Declare.i UseXML(ID.i, XML.i, FileName.s, Flags.i=#False, Encoding.i=#PB_UTF8)
  
  Declare.i AddJSON(ID.i, JSON.i, FileName.s)
  Declare.i UseJSON(ID.i, JSON.i, FileName.s, Flags.i=#False)
  
  Declare.i AddImage(ID.i, Image.i, FileName.s)
  Declare.i UseImage(ID.i, Image.i, FileName.s)
  
  Declare.i AddText(ID.i, String.s, Filename.s)
  Declare.s UseText(ID.i, FileName.s)
  
  Declare.i Remove(ID.i, FileName.s)
  
  Declare   ProgressProcedure(*ProcAddress)
  
  Declare.i IsOpen(ID.i)
  Declare.i IsProgID(ID.i, ProgID.s)
  Declare.i IsCorrectKey(ID.i, Key.s) 
  
  Declare.s GetInfo(ID.i, Type.i)
  Declare   SetInfo(ID.i, Type.i, Value.s)
  
EndDeclareModule


Module SFC
  
  EnableExplicit
  
  UseLZMAPacker()
  UseSHA3Fingerprint()  
  
  ;- ==================================
	;-   Module - Constants
	;- ==================================
  
  Enumeration
    #Binary
    #Ascii
    #Unicode
  EndEnumeration
  
  EnumerationBinary ;{ Internal
    #Create
    #Open
    #Add
    #Remove
    #Memory
    #File
    #XML
    #JSON
    #IMAGE
  EndEnumeration ;}
  
  #SFC   = 1867
  #qAES  = 113656983
  #Salt$ = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"
  
  
  ;- ==================================
  ;-   Module - Structure
	;- ==================================
  
  Global Error.i
  
  Structure Content_Structure     ;{ Content\..
    ProgID.s
    Author.s
    Titel.s
    Subject.s
    Creator.s
    idSFC.s
  EndStructure ;}
  Global Content.Content_Structure
  
  Structure AES_Structure         ;{ qAES\...
    Salt.s
    KeyStretching.i
    Loops.i
    Hash.s
    *ProcPtr
  EndStructure ;}
  Global qAES.AES_Structure
  
  Structure PackEx_File_Structure ;{ PackEx()\Files('file')...
    ID.i
    Size.q
    Compressed.q
    Type.i
    Path.s
    Hash.s
    Flags.i
  EndStructure ;}
  
  Structure PackEx_Structure      ;{ PackEx('pack')\...
    ID.i
    Mode.i
    File.s
    Key.s
    idSFC.s
    TempDir.s
    ProgressBar.i
    Map Files.PackEx_File_Structure()
  EndStructure ;}
  Global NewMap PackEx.PackEx_Structure()
  
  
  ;- ==================================
	;-   Module - Internal Procedures
  ;- ==================================
  
  Procedure.q GetCounter_()
	  Define.q Counter
	  
	  If OpenCryptRandom()
      CryptRandomData(@Counter, 8)
    Else
      RandomData(@Counter, 8)
    EndIf
    
    ProcedureReturn Counter
	EndProcedure  
	
	Procedure.s KeyStretching_(Key.s, Loops.i, ProgressBar.i=#PB_Default)
    ; Author Werner Albus - www.nachtoptik.de
    Define.i i, Timer
    Define.s Salt$
    
    If qAES\Salt = "" 
	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  Else  
	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  EndIf
    
    If IsGadget(ProgressBar)
      Timer = ElapsedMilliseconds()
      SetGadgetState(ProgressBar, 0)
      While WindowEvent() : Wend
    EndIf
    
    For i=1 To Loops
      
      Key = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512)
      
      If IsGadget(ProgressBar)
        If ElapsedMilliseconds() > Timer + 100
          SetGadgetState(ProgressBar, 100 * i / Loops)
          Timer = ElapsedMilliseconds()
          While WindowEvent() : Wend
        EndIf
      EndIf
      
    Next
    
    Key = ReverseString(Key) + Salt$ + Key + ReverseString(Key)
    Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512) ; Finalize
    
    If IsGadget(ProgressBar)
      SetGadgetState(ProgressBar, 100)
      While WindowEvent() : Wend
    EndIf
    
    ProcedureReturn Key
  EndProcedure
  
  
  Procedure   CountPackFiles_()
	  Define.i Count = 0
	  
	  If ExaminePack(PackEx()\ID)
	    While NextPackEntry(PackEx()\ID)
	      Count + 1
	    Wend  
	  EndIf
	  
	  ProcedureReturn Count
	EndProcedure
  
  Procedure   SetProgressState_(Gadget.i, State.i, Flag.i)
    
    If IsGadget(Gadget)
      
      If qAES\ProcPtr
        Progress\Gadget = Gadget
        Progress\State  = State
        Progress\Flags   = Flag
        CallFunctionFast(qAES\ProcPtr)
      Else
        SetGadgetState(Gadget, State)
      EndIf
    
      While WindowEvent() : Wend
    EndIf
    
  EndProcedure
  
  Procedure   SetProgressText_(Gadget.i, Flags.i)
    
    If IsGadget(Gadget) And (Progress\Compress Or Progress\Encrypt)
      
      If qAES\ProcPtr
        
        Progress\Gadget = Gadget
        Progress\Flags  = Flags
        CallFunctionFast(qAES\ProcPtr)
        
      Else
        
        If Flags & #Finished
          SetGadgetText(Gadget, "")
        ElseIf Flags & #Encrypt
          SetGadgetText(Gadget, Progress\Encrypt)
        Else
          SetGadgetText(Gadget, Progress\Compress)
        EndIf
        
      EndIf
      
      While WindowEvent() : Wend
    EndIf

  EndProcedure
  
  
	Procedure.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
	  ; Author: Werner Albus - www.nachtoptik.de (No warranty whatsoever - Use at your own risk)
    ; CounterKey: If you cipher a file blockwise, always set the current block number with this counter (consecutive numbering).
    ; CounterAES: This counter will be automatically used by the coder, but you can change the startpoint.
	  Define.i i, ii, iii, cStep
	  Define.q Rounds, Remaining
	  Define.s Hash$, Salt$
	  Define   *aRegister.ascii, *wRegister.word, *aBufferIn.ascii, *aBufferOut.ascii, *qBufferIn.quad, *qBufferOut.quad
	  Static   FixedKey${64}
	  Static   Dim Register.q(3)
	  
	  If qAES\Salt = ""
	    Salt$ = #Salt$
	  Else
	    Salt$ = qAES\Salt + #Salt$   
	  EndIf
	  
	  Hash$     = Salt$ + Key + Str(CounterKey) + ReverseString(Salt$)
	  FixedKey$ = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, 256)	  
	  
	  cStep     = SizeOf(character) << 1
	  Rounds    = Size >> 4
	  Remaining = Size % 16
	  
	  For ii = 0 To 31
	    PokeA(@Register(0) + ii, Val("$" + PeekS(@FixedKey$ + iii, 2)))
	    iii + cStep
	  Next
	  
	  Register(1) + CounterAES

	  Select Mode
	    Case #Binary  ;{ Binary content
	      
	      *qBufferIn  = *Input
	      *qBufferOut = *Output
	      
	      If Size < 16 ;{ Size < 16
	        
	        *aBufferOut = *qBufferOut
	        *aBufferIn  = *qBufferIn
	        *aRegister  = @register(0)
	        
	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
	          Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
          For ii=0 To Size - 1
            *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
          Next
          
          ProcedureReturn #True
          ;}
        EndIf
        
        While i < Rounds ;{ >= 16 Byte
          
          If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
            Error = #ERROR_ENCODING_FAILS
            ProcedureReturn #False
          EndIf
          
          *qBufferOut\q=*qBufferIn\q ! register(0)
          *qBufferIn  + 8
          *qBufferOut + 8
          *qBufferOut\q = *qBufferIn\q ! register(1)
          *qBufferIn  + 8
          *qBufferOut + 8
          
          i + 1
        Wend ;}
        
        If Remaining
          
          *aBufferOut = *qBufferOut
          *aBufferIn  = *qBufferIn
          *aRegister  = @Register(0)
          
          If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
            Error = #ERROR_ENCODING_FAILS
            ProcedureReturn #False
          EndIf
          
          For ii=0 To Remaining - 1
            *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
          Next
          
        EndIf
	      ;}
	    Case #Ascii   ;{ Ascii content
	      
	      *aBufferIn  = *Input
	      *aBufferOut = *Output
	      
	      Repeat
	        
	        If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
	          Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
	        *aRegister = @Register(0)
	        
	        For ii=0 To 15
	          
            If *aBufferIn\a And *aBufferIn\a ! *aRegister\a
              *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            Else
              *aBufferOut\a = *aBufferIn\a
            EndIf
            
            If i > Size - 2 : Break 2 : EndIf
            
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
            
            i + 1
          Next ii
          
        ForEver
  	    ;}
	    Case #Unicode ;{ Unicode content
	      
	      Repeat
	        
	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
	          Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
	        *wRegister = @Register(0)
          
	        For ii=0 To 15 Step 2
	          
            If *Input\w And *Input\w ! *wRegister\w
              *Output\w = *Input\w ! *wRegister\w
            Else
              *Output\w = *Input\w
            EndIf
            
            If i > Size - 3 : Break 2 : EndIf
            
            *Input + 2
            *Output + 2
            *wRegister + 2
            
            i + 2
          Next ii
          
        ForEver
	      
	      ;}
	  EndSelect
	  
	  ProcedureReturn #True
	EndProcedure
	
  Procedure   CryptBlockwise(*Input, *Output, Size.i, Key.s, Counter.q)
    Define.i BlockSize, Bytes
    
    Define.q Timer, CounterAES
    BlockSize = 4096 << 2
	  Bytes = 0
	  
    ;{ ___ ProgressBar ___
    If IsGadget(PackEx()\ProgressBar)
      Timer = ElapsedMilliseconds()
      SetProgressState_(PackEx()\ProgressBar, 0, #Encrypt)
    EndIf ;}
	  
	  Repeat
	    
	    If Bytes + BlockSize <= Size
	      SmartCoder(#Binary, *Input + Bytes, *Output + Bytes, BlockSize, Key, Counter, CounterAES)
	    Else
	      SmartCoder(#Binary, *Input + Bytes, *Output + Bytes, Size - Bytes, Key, Counter, CounterAES)
	    EndIf 
	    
	    ;{ ___ ProgressBar ___
      If IsGadget(PackEx()\ProgressBar)
        If ElapsedMilliseconds() > Timer + 30
          SetProgressState_(PackEx()\ProgressBar, 100 * Bytes / Size, #Encrypt)
          Timer = ElapsedMilliseconds()
        EndIf
      EndIf ;}
	    
	    Bytes + BlockSize
	    
	    Counter + 1
	    CounterAES + 1
	    
	  Until Bytes >= Size
	  
	  ;{ ___ ProgressBar ___
	  If IsGadget(PackEx()\ProgressBar)
      SetProgressState_(PackEx()\ProgressBar, 100, #Encrypt)
    EndIf ;}
	  
  EndProcedure	
  
  
  Procedure   SaveContentXML(PackID.i)
    Define.i XML, Size
    Define   *Buffer
    
    XML = CreateXML(#PB_Any)
    If XML
      InsertXMLStructure(RootXMLNode(XML), @Content, Content_Structure)
      FormatXML(XML, #PB_XML_ReFormat)
      Size = ExportXMLSize(XML)
      If Size
        *Buffer = AllocateMemory(Size)
        If *Buffer
          If ExportXML(XML, *Buffer, Size)
            AddPackMemory(PackID, *Buffer, Size, "Content.xml")
          EndIf
          FreeMemory(*Buffer)
        EndIf
      EndIf
      FreeXML(XML)
    EndIf

  EndProcedure
  
  Procedure   LoadContentXML(PackID.i, Size.i) 
    Define.i XML
    Define   *Buffer
    
    If Size = 0 : ProcedureReturn  #False : EndIf 
    
    *Buffer = AllocateMemory(Size)
    If *Buffer
      If UncompressPackMemory(PackID, *Buffer, Size, "Content.xml") <> -1
        XML = CatchXML(#PB_Any, *Buffer, Size)
        If XML
          ExtractXMLStructure(MainXMLNode(XML), @Content, Content_Structure)
          FreeXML(XML)
        EndIf 
      EndIf 
      FreeMemory(*Buffer)  
    EndIf 
    
  EndProcedure
  
  
	Procedure   EncodeHash_(Hash.s, Counter.q, *Hash)
    Define.i i
    
    Static Dim Hash.q(31)
    
    For i=0 To 31
      PokeA(@Hash(0) + i, Val("$" + PeekS(@Hash + i * SizeOf(character) << 1, 2)))
    Next
    
    SmartCoder(#Binary, @Hash(0), *Hash, 32, Str(Counter))
    
  EndProcedure

  Procedure.s DecodeHash_(Counter.q, *Hash, FreeMemory.i=#True)
    Define.i i
    Define.s Hash$
    
    Static Dim Hash.q(31)
    
    If *Hash
      
      SmartCoder(#Binary, *Hash, @Hash(0), 32, Str(Counter))
      
      For i = 0 To 31
        Hash$ + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
      Next i
      
      If FreeMemory : FreeMemory(*Hash) : EndIf
    EndIf
    
    ProcedureReturn LCase(Hash$)
  EndProcedure
  
  
	Procedure.i DecryptMemory_(*Buffer, Size.i, Key.s)
	  Define.q Counter, qAES_ID
	  
	  Counter   = PeekQ(*Buffer + Size - 8)
    qAES_ID   = PeekQ(*Buffer + Size - 16)
    qAES\Hash = DecodeHash_(Counter, *Buffer + Size - 48, #False)
    
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    If qAES_ID = #qAES
      
      Size - 48
      
      CryptBlockwise(*Buffer, *Buffer, Size, Key, Counter)
      
      If qAES\Hash <> Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        Error = #ERROR_INTEGRITY_CORRUPTED
        qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        ProcedureReturn #False
      EndIf
      
    Else
      Error = #ERROR_NOT_ENCRYPTED
    EndIf 
    
	  ProcedureReturn Size
	EndProcedure
	
	Procedure.i AddCryptMemory_(PackID, *Buffer, Size.i, PackedFileName.s, Key.s)
	  Define.i Size, Result
	  Define.q Counter,qAES_ID = #qAES
	  Define   *Buffer, *Hash

	  Counter = GetCounter_()
    
    qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
    *Hash = AllocateMemory(32)
    If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
    
    CryptBlockwise(*Buffer, *Buffer, Size, Key, Counter)
    
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    CopyMemory(*Hash, *Buffer + Size, 32)
    PokeQ(*Buffer + Size + 32, qAES_ID)
    PokeQ(*Buffer + Size + 40, Counter)

    Size + 48
    
    SetProgressText_(PackEx()\ProgressBar, #Compress)
    Result = AddPackMemory(PackID, *Buffer, Size, PackedFileName)
    SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
    
    ProcedureReturn Result
	EndProcedure
	
	Procedure.i AddCryptFile_(PackID, File.s, PackedFileName.s, Key.s) 
	  Define.i FileID, Size, Result
    Define.q Counter, cCounter, checkID, qAES_ID = #qAES
    Define   *Buffer, *Hash
    
    Counter = GetCounter_()
    
    FileID = ReadFile(#PB_Any, File)
    If FileID
      
      Size = Lof(FileID)
      If Size > 0
        
        *Buffer  = AllocateMemory(Size + 48)
        If *Buffer

          If ReadData(FileID, *Buffer, Size)
            
            CloseFile(FileID)
          
            checkID  = PeekQ(*Buffer + Size - 16)
            cCounter = PeekQ(*Buffer + Size - 8)
            SmartCoder(#Binary, @checkID, @checkID, 8, Str(cCounter))
            
            If checkID <> #qAES
              
              qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
              *Hash = AllocateMemory(32)
              If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
              
              CryptBlockwise(*Buffer, *Buffer, Size, Key, Counter)
              
              SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
              
              CopyMemory(*Hash, *Buffer + Size, 32)
              PokeQ(*Buffer + Size + 32, qAES_ID)
              PokeQ(*Buffer + Size + 40, Counter)
              
              Size + 48
            EndIf
            
            SetProgressText_(PackEx()\ProgressBar, #Compress)
            Result = AddPackMemory(PackID, *Buffer, Size, PackedFileName)
            SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
    EndIf  
    
    If Result : ProcedureReturn Size : EndIf
    
	  ProcedureReturn #False
	EndProcedure
	

	Procedure.i AddMemory2Pack_(*Buffer, Size.i, PackedFileName.s, Key.s) ; only OpenPack()
	  Define.i PackID, PackEntrySize, Size, pResult, Result, Files, Count
	  Define.s PackFile, PackEntryName
	  Define   *Buffer, *File
	  
	  PackFile = PackEx()\TempDir + GetFilePart(PackEx()\File)
	  
	  PackID = CreatePack(#PB_Any, PackFile, #PB_PackerPlugin_Lzma)
	  If PackID
	    
	    If IsGadget(PackEx()\ProgressBar) : Files = CountPackFiles_() : EndIf
	    
	    If ExaminePack(PackEx()\ID)
	      
	      Result = #True
	      
	      SetProgressState_(PackEx()\ProgressBar, 0, #Rebuild)
	      SetProgressText_(PackEx()\ProgressBar, #Rebuild)
	      
	      While NextPackEntry(PackEx()\ID)
	        
	        PackEntryName = PackEntryName(PackEx()\ID)
	        
	        If PackEntryName = PackedFileName
	          Continue
          ElseIf PackEntryName = "Content.xml" ;{ Save 'Content.xml'
            
            SaveContentXML(PackID)
            ;}
	        Else                                 ;{ Copy other files
	          
	          PackEntrySize = PackEntrySize(PackEx()\ID)
	          
	          *File = AllocateMemory(PackEntrySize)
	          If *File
	            
	            If UncompressPackMemory(PackEx()\ID, *File, PackEntrySize, PackEntryName) <> -1
	              pResult = AddPackMemory(PackID, *File, PackEntrySize, PackEntryName)
	              If Not pResult : Result = #False : EndIf
	            Else
	              Result = #False
                Error  = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
              EndIf

	            FreeMemory(*File)
	          EndIf
  	        ;}
	        EndIf
	        
	        If Files
            Count + 1
            SetProgressState_(PackEx()\ProgressBar, 100 * Count / Files, #Rebuild)
          EndIf  
	        
	      Wend
	      
	      SetProgressText_(PackEx()\ProgressBar, #Rebuild|#Finished)
	      SetProgressState_(PackEx()\ProgressBar, 100, #Rebuild)

	      ClosePack(PackEx()\ID)
	    EndIf
	    
	    ; Add *Buffer to new pack
	    If Key
	      pResult = AddCryptMemory_(PackID, *Buffer, Size, PackedFileName, Key)
	    Else
	      SetProgressText_(PackEx()\ProgressBar, #Compress)
	      pResult = AddPackMemory(PackID, *Buffer, Size, PackedFileName)
	      SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
	    EndIf
	    
	    If Not pResult : Result = #False : EndIf
	    
	    ClosePack(PackID)
	  EndIf
	  
	  If Result : CopyFile(PackFile, PackEx()\File) : EndIf
	  
	  PackEx()\ID = OpenPack(#PB_Any, PackEx()\File, #PB_PackerPlugin_Lzma)
	  
	  If Result : ProcedureReturn pResult : EndIf
 
	  ProcedureReturn #False
	EndProcedure
	
	Procedure.i AddFile2Pack_(File.s, PackedFileName.s, Key.s)            ; only OpenPack()
	  Define.i PackID, PackEntrySize, Size, pResult, Result, Files, Count
	  Define.s PackFile, PackEntryName
	  Define   *Buffer
	  
	  PackFile = PackEx()\TempDir + GetFilePart(PackEx()\File)
	  
	  PackID = CreatePack(#PB_Any, PackFile, #PB_PackerPlugin_Lzma)
	  If PackID
	    
	    If IsGadget(PackEx()\ProgressBar) : Files = CountPackFiles_() : EndIf
	    
	    If ExaminePack(PackEx()\ID)
	      
	      Result = #True
	      
	      SetProgressState_(PackEx()\ProgressBar, 0, #Rebuild)
	      SetProgressText_(PackEx()\ProgressBar, #Rebuild)
	      
	      While NextPackEntry(PackEx()\ID)
	        
	        PackEntryName = PackEntryName(PackEx()\ID)

	        If PackEntryName = PackedFileName ;{ Ignore PackedFileName
	          Continue                        ;}
	        ElseIf PackEntryName = "Content.xml"
	          SaveContentXML(PackID)
	        Else                              ;{ Copy other files
	          
	          PackEntrySize = PackEntrySize(PackEx()\ID)
	          
	          *Buffer = AllocateMemory(PackEntrySize)
	          If *Buffer
	            
	            If UncompressPackMemory(PackEx()\ID, *Buffer, PackEntrySize, PackEntryName) <> -1
	              pResult = AddPackMemory(PackID, *Buffer, PackEntrySize, PackEntryName)
	              If Not pResult : Result = #False : EndIf
	            Else
	              Result = #False
                Error  = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
              EndIf
              
	            FreeMemory(*Buffer)
	          EndIf
  	        ;}
	        EndIf
	        
	        If Files
            Count + 1
            SetProgressState_(PackEx()\ProgressBar, 100 * Count / Files, #Rebuild)
          EndIf 
	        
	      Wend
	      
	      SetProgressText_(PackEx()\ProgressBar, #Rebuild|#Finished)
	      SetProgressState_(PackEx()\ProgressBar, 100, #Rebuild)
	      
	      ClosePack(PackEx()\ID)
	    EndIf
	    
	    ; Add file to new pack
	    If Key
	      pResult = AddCryptFile_(PackID, File, PackedFileName, Key)
	      Size = pResult
	    Else
	      pResult = AddPackFile(PackID, File, PackedFileName)
	      Size = FileSize(File)
	    EndIf
	    
	    If Not pResult : Result = #False : EndIf
	    
	    ClosePack(PackID)
	  EndIf
	  
	  If Result : CopyFile(PackFile, PackEx()\File) : EndIf
	  
	  PackEx()\ID = OpenPack(#PB_Any, PackEx()\File, #PB_PackerPlugin_Lzma)
	  
	  If Result : ProcedureReturn Size : EndIf
	  
	  ProcedureReturn #False
	EndProcedure

	Procedure.i RemoveFile_(PackedFileName.s)                             ; only OpenPack()
	  Define.i PackID, PackEntrySize, Size, pResult, Result, Files, Count
	  Define.s PackFile, PackEntryName
	  Define   *Buffer
	  
	  If PackEx()\Mode = #Create : ProcedureReturn #False : EndIf 
	  
	  PackFile = PackEx()\TempDir + GetFilePart(PackEx()\File)
	  
	  PackID = CreatePack(#PB_Any, PackFile, #PB_PackerPlugin_Lzma)
	  If PackID
	    
	    If IsGadget(PackEx()\ProgressBar) : Files = CountPackFiles_() : EndIf
	    
	    If ExaminePack(PackEx()\ID)
	      
	      Result = #True
	      
	      SetProgressState_(PackEx()\ProgressBar, 0, #Rebuild)
	      SetProgressText_(PackEx()\ProgressBar, #Rebuild)
	      
	      While NextPackEntry(PackEx()\ID)
	        
	        PackEntryName = PackEntryName(PackEx()\ID)

	        If PackEntryName = PackedFileName ;{ Ignore PackedFileName
	          Continue                        ;}
	        ElseIf PackEntryName = "Content.xml" 
	          SaveContentXML(PackID)
	        Else                              ;{ Copy other files
	          
	          PackEntrySize = PackEntrySize(PackEx()\ID)
	          
	          *Buffer = AllocateMemory(PackEntrySize)
	          If *Buffer
	            
	            If UncompressPackMemory(PackEx()\ID, *Buffer, PackEntrySize, PackEntryName) <> -1
	              pResult = AddPackMemory(PackID, *Buffer, PackEntrySize, PackEntryName)
	              If Not pResult : Result = #False : EndIf
	            Else
	              Result = #False
                Error  = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
              EndIf
              
	            FreeMemory(*Buffer)
	          EndIf
  	        ;}
	        EndIf
	        
	        If Files
            Count + 1
            SetProgressState_(PackEx()\ProgressBar, 100 * Count / Files, #Rebuild)
          EndIf 
	        
	      Wend
	      
	      SetProgressText_(PackEx()\ProgressBar, #Rebuild|#Finished)
	      SetProgressState_(PackEx()\ProgressBar, 100, #Rebuild)
	      
	      ClosePack(PackEx()\ID)
	    EndIf
	    
	    ClosePack(PackID)
	  EndIf
	  
	  If Result : CopyFile(PackFile, PackEx()\File) : EndIf
	  
	  PackEx()\ID = OpenPack(#PB_Any, PackEx()\File, #PB_PackerPlugin_Lzma)
	  
	  If Result : ProcedureReturn #True : EndIf
	  
	  ProcedureReturn #False
	EndProcedure
	
	
	Procedure   ReadContent_()
	  
	  ClearMap(PackEx()\Files())
    
    If ExaminePack(PackEx()\ID)
      While NextPackEntry(PackEx()\ID)
        If AddMapElement(PackEx()\Files(), PackEntryName(PackEx()\ID))
          PackEx()\Files()\Size       = PackEntrySize(PackEx()\ID, #PB_Packer_UncompressedSize)
          PackEx()\Files()\Compressed = PackEntrySize(PackEx()\ID, #PB_Packer_CompressedSize)
          PackEx()\Files()\Type       = PackEntryType(PackEx()\ID)
        EndIf
      Wend
    EndIf
    
	EndProcedure
	
	Procedure.i TempDir_(Pack.i)
	  
	  PackEx()\TempDir = GetTemporaryDirectory() + "PackEx" + RSet(Str(Pack), 4, "0") + #PS$
    If CreateDirectory(PackEx()\TempDir)
      ProcedureReturn #True
    EndIf
	  
	EndProcedure
	
	
	Procedure.i IsEncrypted_(FileName.s, Size.i)
    Define.i Result = -1
    Define.q Counter, qAES_ID
    Define   *Buffer  
    
    If Size <= 0 : ProcedureReturn #False : EndIf 
    
    *Buffer = AllocateMemory(Size)
    If *Buffer
      
      If UncompressPackMemory(PackEx()\ID, *Buffer, Size, FileName) <> -1
       
        qAES_ID = PeekQ(*Buffer + Size - 16)
        Counter = PeekQ(*Buffer + Size - 8)
        SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
        
        If qAES_ID = #qAES
          Result = #True
        Else
          Result = #False
        EndIf 
       
      EndIf
      
      FreeMemory(*Buffer)
    EndIf
      
    ProcedureReturn Result
  EndProcedure
	
 
  ;- ==================================
	;-   Module - Declared Procedures
	;- ==================================
  
  Procedure   ProgressProcedure(*ProcAddress)
    
    qAES\ProcPtr = *ProcAddress
    
  EndProcedure
  

	Procedure.i Create(ID.i, File.s, ProgID.s="", Key.s="")
	  
	  If ID = #PB_Any
      ID = 1 : While FindMapElement(PackEx(), Str(ID)) : ID + 1 : Wend
    EndIf
	  
    If AddMapElement(PackEx(), Str(ID))
      
      PackEx()\ID     = CreatePack(#PB_Any, File, #PB_PackerPlugin_Lzma)
      PackEx()\File   = File
      PackEx()\Mode   = #Create

      If Key
        PackEx()\Key = KeyStretching_(Key, 256)
        PackEx()\idSFC  = KeyStretching_(StringFingerprint(Key, #PB_Cipher_SHA3), #SFC)
      EndIf
    
      Content\ProgID  = ProgID
      Content\Creator = "Secure FileContainer"
      Content\idSFC   = PackEx()\idSFC

      TempDir_(ID)
      
      ProcedureReturn PackEx()\ID
    EndIf
    
  EndProcedure  

  Procedure.i Open(ID.i, File.s, Key.s="")
    
    If ID = #PB_Any
      ID = 1 : While FindMapElement(PackEx(), Str(ID)) : ID + 1 : Wend
    EndIf
    
    If AddMapElement(PackEx(), Str(ID))
      
      PackEx()\ID     = OpenPack(#PB_Any, File, #PB_PackerPlugin_Lzma)
      PackEx()\File   = File
      PackEx()\Mode   = #Open
      
      If Key
        PackEx()\Key    = KeyStretching_(Key, 256)
        PackEx()\idSFC  = KeyStretching_(StringFingerprint(Key, #PB_Cipher_SHA3), #SFC)
      EndIf

      ReadContent_()
      
      LoadContentXML(PackEx()\ID, PackEx()\Files("Content.xml")\Size)

      TempDir_(ID)
      
      ProcedureReturn PackEx()\ID
    EndIf
    
  EndProcedure
  
  
  Procedure.i AddFile(ID.i, File.s)
    Define.i FileID, Size
    Define.s PackedFileName
    
    If FindMapElement(PackEx(), Str(ID))
      
      PackedFileName = GetFilePart(File)
      
      If PackEx()\Mode = #Open
        
        Size = AddFile2Pack_(File, PackedFileName, PackEx()\Key)
        
      Else    ; #Create
        
        If PackEx()\Key ; encrypt & pack file
          Size = AddCryptFile_(PackEx()\ID, File, PackedFileName, PackEx()\Key)
        Else   ; pack file
          SetProgressText_(PackEx()\ProgressBar, #Compress)
          If AddPackFile(PackEx()\ID, File, PackedFileName)
            Size = FileSize(File)
          EndIf
          SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
        EndIf
        
      EndIf
      
      If Size
        PackEx()\Files(PackedFileName)\Size = Size
        PackEx()\Files(PackedFileName)\Type = #PB_Packer_File
        PackEx()\Files(PackedFileName)\Flags | #File
      EndIf
    
    EndIf
    
    ProcedureReturn Size
  EndProcedure
  
  Procedure.i UseFile(ID.i, File.s)
    Define.i FileID, Size, Result = -1
    Define.s PackedFileName
    Define   *Buffer
    
    If FindMapElement(PackEx(), Str(ID))
      
      PackedFileName = GetFilePart(File)
      
      If PackEx()\Key  ;{ decrypt & pack file

        If FindMapElement(PackEx()\Files(), PackedFileName)
          
          Size = PackEx()\Files()\Size
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            SetProgressText_(PackEx()\ProgressBar, #Compress)
            
            If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
              
              SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
              
              If DecryptMemory_(*Buffer, Size, PackEx()\Key)
                
                Size - 48
              
                FileID = CreateFile(#PB_Any, File)
                If FileID 
                  If WriteData(FileID, *Buffer, Size)
                    Result = Size
                  EndIf
                  CloseFile(FileID)
                EndIf
                
              EndIf

            Else
              Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
            EndIf
            
            SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
            
            FreeMemory(*Buffer)
          EndIf

        EndIf
        ;}
      Else    ;{ pack file
        
        SetProgressText_(PackEx()\ProgressBar, #Compress)
        Result = UncompressPackFile(PackEx()\ID, File, PackedFileName)
        SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
        ;}
      EndIf
      
      If Result
        PackEx()\Files(PackedFileName)\Path = GetPathPart(File)
        PackEx()\Files(PackedFileName)\Flags | #Open | #File
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddXML(ID.i, XML.i, FileName.s)
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID = #qAES
    Define.i Size, Result
 
    If FindMapElement(PackEx(), Str(ID))
      
      If IsXML(XML)
        
        Size = ExportXMLSize(XML)
        If Size
          
          *Buffer = AllocateMemory(Size + 48)
          If *Buffer
            
            If ExportXML(XML, *Buffer, Size)
              
              If PackEx()\Mode = #Open
         
                Result = AddMemory2Pack_(*Buffer, Size, FileName, PackEx()\Key)
                If Result And PackEx()\Key : Size + 48 : EndIf

              Else
                
                If PackEx()\Key
                  Result = AddCryptMemory_(PackEx()\ID, *Buffer, Size, FileName, PackEx()\Key)
                  If Result : Size + 48 : EndIf
                Else
                  Result = AddPackMemory(PackEx()\ID, *Buffer, Size, FileName)
                EndIf
              
              EndIf
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf  

        EndIf
        
        If Result
          PackEx()\Files(FileName)\Size = Size
          PackEx()\Files(FileName)\Type = #PB_Packer_File
          PackEx()\Files(FileName)\ID   = XML
          PackEx()\Files(FileName)\Flags | #Add | #XML
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i UseXML(ID.i, XML.i, FileName.s, Flags.i=#False, Encoding.i=#PB_UTF8)
    Define   *Buffer
    Define.i Size, Result 
    
    If FindMapElement(PackEx(), Str(ID))
      
      If FindMapElement(PackEx()\Files(), FileName)
       
        Size = PackEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, FileName) <> -1
            
            If DecryptMemory_(*Buffer, Size, PackEx()\Key)

              Result = CatchXML(XML, *Buffer, Size - 48, Flags, Encoding)
              If XML = #PB_Any : XML = Result : EndIf
              
            EndIf
          
          Else
            Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
       
      EndIf
      
      If Result
        PackEx()\Files(FileName)\ID = XML
        PackEx()\Files(FileName)\Flags | #Open | #XML
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddJSON(ID.i, JSON.i, FileName.s)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(ID))
      
      If IsJSON(JSON)
        
        Size = ExportJSONSize(JSON)
        If Size
          
          *Buffer = AllocateMemory(Size + 48)
          If *Buffer
            
            If ExportJSON(JSON, *Buffer, Size)
              
              If PackEx()\Mode = #Open
                
                Result = AddMemory2Pack_(*Buffer, Size, FileName, PackEx()\Key)
                If Result And PackEx()\Key : Size + 48 : EndIf
                
              Else
                
                If PackEx()\Key
                  Result = AddCryptMemory_(PackEx()\ID, *Buffer, Size, FileName, PackEx()\Key)
                  If Result : Size + 48 : EndIf
                Else
                  Result = AddPackMemory(PackEx()\ID, *Buffer, Size, FileName)
                EndIf
              
              EndIf
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf  

        EndIf
        
        If Result
          PackEx()\Files(FileName)\Size = Size
          PackEx()\Files(FileName)\Type = #PB_Packer_File
          PackEx()\Files(FileName)\ID   = JSON
          PackEx()\Files(FileName)\Flags | #Add | #JSON
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i UseJSON(ID.i, JSON.i, FileName.s, Flags.i=#False)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(ID))
      
      If FindMapElement(PackEx()\Files(), FileName)
       
        Size = PackEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, FileName) <> -1
            
            If DecryptMemory_(*Buffer, Size, PackEx()\Key)

              Result = CatchJSON(JSON, *Buffer, Size - 48, Flags)
              If JSON = #PB_Any : JSON = Result : EndIf
              
            EndIf
            
          Else
            Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      If Result
        PackEx()\Files(FileName)\ID = JSON
        PackEx()\Files(FileName)\Flags | #Open | #JSON
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddImage(ID.i, Image.i, FileName.s)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(ID))
      
      If IsImage(Image)

        *Buffer = EncodeImage(Image)
        If *Buffer
          
          Size = MemorySize(*Buffer)

          If PackEx()\Key  ;{ encrypt & pack file
            
            *Buffer = ReAllocateMemory(*Buffer, Size + 48)
            If *Buffer

              If PackEx()\Mode = #Open
                Result = AddMemory2Pack_(*Buffer, Size, FileName, PackEx()\Key)
              Else
                Result = AddCryptMemory_(PackEx()\ID, *Buffer, Size, FileName, PackEx()\Key)
              EndIf
              
              Size + 48
              
            EndIf  
            ;}
          Else    ;{ pack file
            
            If PackEx()\Mode = #Open 
              Result = AddMemory2Pack_(*Buffer, Size, FileName, "")
            Else
              SetProgressText_(PackEx()\ProgressBar, #Compress)
              Result = AddPackMemory(PackEx()\ID, *Buffer, Size, FileName)
              SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
            EndIf
            ;}
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
        If Result
          PackEx()\Files(FileName)\Size = Size
          PackEx()\Files(FileName)\Type = #PB_Packer_File
          PackEx()\Files(FileName)\ID   = Image
          PackEx()\Files(FileName)\Flags | #Add | #IMAGE
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i UseImage(ID.i, Image.i, FileName.s)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(ID))
      
      If FindMapElement(PackEx()\Files(), FileName)
        
        Size = PackEx()\Files()\Size
        
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          SetProgressText_(PackEx()\ProgressBar, #Compress)
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, FileName) <> -1
            
            SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
            
            Size = DecryptMemory_(*Buffer, Size, PackEx()\Key)
           
            If Size
              Result = CatchImage(Image, *Buffer, Size)
              If Image = #PB_Any : Image = Result : EndIf
            EndIf 
          
          Else
            Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
          EndIf
          
          SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
          
          FreeMemory(*Buffer)
        EndIf
       
      EndIf
      
      If Result
        PackEx()\Files(FileName)\ID = Image
        PackEx()\Files(FileName)\Flags | #Open | #Image
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddText(ID.i, String.s, Filename.s)
    Define.i Size, Result
    Define   *Buffer
    
    If FindMapElement(PackEx(), Str(ID))
      
      If String
        
        Size = StringByteLength(String)
        If Size
          
          *Buffer = AllocateMemory(Size + 48)
          If *Buffer
            
            CopyMemory(@String, *Buffer, Size)
            
            If PackEx()\Key  ;{ encrypt & pack file

              If PackEx()\Mode = #Open
                Result = AddMemory2Pack_(*Buffer, Size, FileName, PackEx()\Key)
              Else
                Result = AddCryptMemory_(PackEx()\ID, *Buffer, Size, FileName, PackEx()\Key)
              EndIf
              
              Size + 48  
              ;}
            Else    ;{ pack file
              
              If PackEx()\Mode = #Open 
                Result = AddMemory2Pack_(*Buffer, Size, FileName, "")
              Else
                SetProgressText_(PackEx()\ProgressBar, #Compress)
                Result = AddPackMemory(PackEx()\ID, *Buffer, Size, FileName)
                SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
              EndIf
              ;}
            EndIf

            FreeMemory(*Buffer)
          EndIf
          
          If Result
            PackEx()\Files(FileName)\Size = Size
            PackEx()\Files(FileName)\Type = #PB_Packer_File
            PackEx()\Files(FileName)\Flags | #Add | #IMAGE
          EndIf
          
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.s UseText(ID.i, FileName.s)
    Define   *Buffer
    Define.i Size
    Define.s String
    
    If FindMapElement(PackEx(), Str(ID))
      
      If FindMapElement(PackEx()\Files(), FileName)
        
        Size   = PackEx()\Files()\Size
        If Size <= 0 : ProcedureReturn "" : EndIf
        
        String = Space(Size / SizeOf(character))

        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, FileName) <> -1
            
            SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
            
            Size = DecryptMemory_(*Buffer, Size, PackEx()\Key)
            If Size
              CopyMemory(*Buffer, @String, Size)
            EndIf
          
          Else
            Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
          EndIf
          
          SetProgressText_(PackEx()\ProgressBar, #Compress|#Finished)
          
          FreeMemory(*Buffer)
        EndIf
          
      EndIf
     
    EndIf
    
    ProcedureReturn String
  EndProcedure
  
  
  Procedure.i Remove(ID.i, FileName.s)
    
    If FindMapElement(PackEx(), Str(ID))
      
      If FindMapElement(PackEx()\Files(), FileName)
        
        If RemoveFile_(FileName) 
          DeleteMapElement(PackEx()\Files())
          ProcedureReturn #True
        EndIf
      
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  
  Procedure   Close(ID.i, Flags.i=#MoveBack)
    Define.s File
    
    If FindMapElement(PackEx(), Str(ID))
      
      If Flags & #MoveBack Or Flags & #Update
        
        ForEach PackEx()\Files()
          
          If PackEx()\Files()\Flags & #Open
            
            If Flags & #File And PackEx()\Files()\Flags & #File ;{ MoveBack files
              
              File = PackEx()\Files()\Path + MapKey(PackEx()\Files())
              
              If FileSize(File) > 0
                
                If AddFile(ID, File)
                  
                  If Flags & #MoveBack : DeleteFile(File) : EndIf
                  
                EndIf
                
              EndIf
              ;}
            EndIf
            
          EndIf 
          
        Next
        
        SaveContentXML(PackEx()\ID)
        
      EndIf
      
      ClosePack(PackEx()\ID)
      
      DeleteMapElement(PackEx())
    EndIf
    
  EndProcedure
  
  
  Procedure.i IsOpen(ID.i)
    
    If FindMapElement(PackEx(), Str(ID))
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf  
    
  EndProcedure  
  
  Procedure.i IsProgID(ID.i, ProgID.s)
    
    If FindMapElement(PackEx(), Str(ID))
      
      If ProgID = Content\ProgID
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i IsCorrectKey(ID.i, Key.s) 

    If FindMapElement(PackEx(), Str(ID))
      
      If Key : Key = KeyStretching_(StringFingerprint(Key, #PB_Cipher_SHA3), #SFC) : EndIf
      
      If Content\idSFC = Key
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  
  Procedure.s GetInfo(ID.i, Type.i)
    
    If FindMapElement(PackEx(), Str(ID))
      
      Select Type
        Case #Author
          ProcedureReturn Content\Author
        Case #Title
          ProcedureReturn Content\Titel
        Case #Subject
          ProcedureReturn Content\Subject
        Case #Creator 
          ProcedureReturn Content\Creator
        Case #ProgID
          ProcedureReturn Content\ProgID
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure   SetInfo(ID.i, Type.i, Value.s)
    
    If FindMapElement(PackEx(), Str(ID))
      
      Select Type
        Case #Author
          Content\Author  = Value
        Case #Title
          Content\Titel   = Value
        Case #Subject
          Content\Subject = Value
        Case #Creator 
          Content\Creator = Value
        Case #ProgID
          Content\ProgID  = Value
      EndSelect
      
    EndIf
    
  EndProcedure
  
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 1
  
  ; 1: Create Container
  ; 2: Load XML
  ; 3: Load JSON
  ; 4: Load Image
  ; 5: Text
  
  #SFC   = 1
  #XML   = 1
  #JSON  = 1
  #Image = 2
  
  #Key$ = "12TH34"
  
  CompilerSelect #Example
    CompilerCase 1 ;{ Create container
      
      If SFC::Create(#SFC, "Test.sfc", "SFC") ; , #Key$
        SFC::AddFile(#SFC, "Test.jpg")
        SFC::AddFile(#SFC, "Test.xml")
        SFC::AddFile(#SFC, "Test.json")
        SFC::Close(#SFC, SFC::#Update)
      EndIf
      ;}
    CompilerCase 2 ;{ XML
      
      If SFC::Open(#SFC, "Test.sfc", #Key$)
        If SFC::UseXML(#SFC, #XML, "Test.xml")
          Debug ComposeXML(#XML)
          FreeXML(#XML)
        EndIf 
        SFC::Close(#SFC, SFC::#Update)
      EndIf
      ;}
    CompilerCase 3 ;{ JSON
      
      If SFC::Open(#SFC, "Test.sfc", #Key$)
        If SFC::UseJSON(#SFC, #JSON, "Test.json")
          Debug ComposeJSON(#JSON)
          FreeJSON(#JSON)
        EndIf 
        SFC::Close(#SFC, SFC::#Update)
      EndIf
      ;}
    CompilerCase 4 ;{ Image
      
      UseJPEGImageDecoder()
      
      If SFC::Open(#SFC, "Test.sfc") ; , #Key$
        If SFC::UseImage(#SFC, #Image, "Test.jpg")
          SaveImage(#Image, "DecryptedImage.jpg")
          FreeImage(#Image)
        EndIf 
        SFC::Close(#SFC, SFC::#Update)
      EndIf
      ;}
    CompilerCase 5 ;{ Text 
      
      String$ = "This is a test file for SecureFileContainer."
      
      If SFC::Create(#SFC, "Text.sfc", "SFC", #Key$)
        SFC::AddText(#SFC, String$, "Text.txt")
        SFC::Close(#SFC, SFC::#Update)
      EndIf
      
      If SFC::Open(#SFC, "Text.sfc", #Key$)
        String$ = SFC::UseText(#SFC, "Text.txt")
        If String$
          Debug String$
        EndIf 
        SFC::Close(#SFC, SFC::#Update)
      EndIf
      ;}
  CompilerEndSelect

CompilerEndIf  
; IDE Options = PureBasic 5.71 LTS (Windows - x86)
; CursorPosition = 1762
; FirstLine = 260
; Folding = MGB+eAYAQAYED9
; EnableXP
; DPIAware
; EnablePurifier