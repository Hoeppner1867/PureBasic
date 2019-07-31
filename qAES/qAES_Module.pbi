;/ ===================================
;/ =    qAES_SmartCoderModule.pbi    =
;/ ===================================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/
;/ based on code of Werner Albus - www.nachtoptik.de
;/ 
;/ < No warranty whatsoever - Use at your own risk >
;/
;/ adapted from Thorsten Hoeppner (07/2019) 
;/

; - This coder go always forward, an extra decoder isn't necessary, just use exactly the same calling convention for encrypting and decrypting!
; - This coder can handle automatic string termination for any strings - In compiler mode ASCII and UNICODE !
; - The coder works with all data lengths, also < 16 Byte

; Last Update:
;{ _____ qAES - Commands _____

; qAES::KeyStretching()          - use keystretching to make brute force attacks more difficult
; qAES::SetAttribute()           - [#EnlargeBytes/#HashLength/#ProtectedMarker/#CryptMarker]
; qAES::SetSalt()                - define your own salt
; qAES::GetErrorMessage() - returns error message 
; ----- qAES::SmartCoder() -----
; qAES::SmartCoder()             - encrypt / decrypt ascii strings, unicode strings and binary data (#Binary/#Ascii/#Unicode)
; qAES::File()                   - File:   encrypt / decrypt only with SmartCoder()
; qAES::String()                 - String: encrypt / decrypt only with SmartCoder()
; ----- qAES::SmartFileCoder() -----
; qAES::SmartFileCoder()  - encrypting or decrypting file (high security)
; qAES::CheckIntegrity()  - checks the integrity of a encrypted file           [SmartFileCoder]
; qAES::IsEncrypted()     - checks if a file is already encrypted or protected [SmartFileCoder]

;}


DeclareModule qAES

	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  Enumeration
    #Binary  ; Mode BINARY, you can encrypt binary data, don't use this for on demand string encryption, it break the string termination!
    #Ascii   ; Mode ASCII, you can encrypt mixed data, string and binary - This ignore the encryption of zero bytes, recommended for mixed datea with ASCII strings.
    #Unicode ; Mode UNICODE, you can encrypt mixed data, ascii strings, unicode strings and binary - This ignore the encryption of zero bytes.
  EndEnumeration
  
  Enumeration 1
    #CryptMarker     ; preset crypt marker
    #EnlargeBytes    ; enlarge file length bytes
    #HashLength      ; (224, 256, 384, 512)
    #ProtectedMarker ; preset protected marker
  EndEnumeration
  
  Enumeration 1
    #ERROR_CAN_NOT_CREATE_COUNTER
    #ERROR_FINGERPRINT_FAILS
    #ERROR_FILE_NOT_EXIST
    #ERROR_CAN_NOT_OPEN_FILE
    #ERROR_ENCODING_FAILS
  EndEnumeration
  
	;- ===========================================================================
	;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i CheckIntegrity(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  Declare.i File(File.s, outFile.s, Key.s, KeyStretching.i=#False)
  Declare.i SmartFileCoder(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  Declare.i IsEncrypted(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  Declare.s KeyStretching(Key.s, Loops.i, ProgressBarID.i=#PB_Default, WindowID.i=#PB_Default)
  Declare   SetAttribute(Attribute.i, Value.i)
  Declare   SetSalt(String.s)
  Declare.s GetErrorMessage(Error.i)
  Declare.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
  Declare.s String(String.s, Key.s, KeyStretching.i=#False) 
  
EndDeclareModule

Module qAES

	EnableExplicit
	
	UseSHA3Fingerprint()
	
	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#Hints$ = "QUICK-AES-256 (QAES) AES256 KFB crypter" + #LF$ + "No warranty whatsever - Use at your own risk" + #LF$ + #LF$
  #Salt$  = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"
  
	;- ============================================================================
  ;-   Module - Structure
	;- ============================================================================
	
	Structure AES_Structure ;{ qAES\...
	  CryptExtLength.i
	  EnlargeBytes.i
	  HashLength.i
	  ProtectedMarker.q
	  CryptMarker.q
	  Salt.s
	  Error.i
	EndStructure ;}
	Global qAES.AES_Structure

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Linux
	  
	  Procedure.q FixWriteData(File.i, *Adress, Length.q) ; Workaround for Linux PB560
	    Define.q Location, Bytes

      Location = Loc(File)
      Bytes    = WriteData(File, *Adress, Length)
      
      FileSeek(file, Location + Bytes)
    
      ProcedureReturn Bytes
    EndProcedure
 
    Macro WriteData(File, Buffer, Size)
      FixWriteData(File, Buffer, Size)
    EndMacro
    
  CompilerEndIf
	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  ;- _____ Tools _____
  
  Procedure.s KeyStretching(Key.s, Loops.i, ProgressBarID.i=#PB_Default, WindowID.i=#PB_Default)
    Define.i i, Time.q, Progress
    
    If ProgressBarID <> #PB_Default And WindowID <> #PB_Default
      Progress = #True
      Time = ElapsedMilliseconds()
    EndIf 
    
    For i=1 To Loops ; Iterations
      
      Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512)
      Key = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
      
      If Progress 
        If ElapsedMilliseconds() > Time + 100
          If IsGadget(ProgressBarID) : SetGadgetState(ProgressBarID, 100 * i / Loops) : EndIf
          Time = ElapsedMilliseconds()  
        EndIf
      EndIf
      
    Next
    
    Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512) ; Finalize
    
    If Progress
      If IsGadget(ProgressBarID) : SetGadgetState(ProgressBarID, 100) : EndIf
      Delay(100)
    EndIf
    
    ProcedureReturn Key
  EndProcedure
  
  Procedure.s GetErrorMessage(Error.i)
    
    Select Error
      Case #ERROR_CAN_NOT_CREATE_COUNTER
        ProcedureReturn "Error: Can't create counter."
      Case #ERROR_FINGERPRINT_FAILS
        ProcedureReturn "Error: Fingerprint not valid."
      Case #ERROR_FILE_NOT_EXIST
        ProcedureReturn "Error: File not found."
      Case #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn "Error: Can't open file."
      Case #ERROR_ENCODING_FAILS
        ProcedureReturn "No error found."
    EndSelect
    
    ProcedureReturn "No error found."
  EndProcedure
  
  ;- _____ Settings _____
  
  Procedure   SetAttribute(Attribute.i, Value.i)
    
    Select Attribute
      Case #EnlargeBytes
        qAES\EnlargeBytes = Value
      Case #HashLength
        qAES\HashLength = Value
      Case #ProtectedMarker
        qAES\ProtectedMarker = Value
      Case #CryptMarker
        qAES\CryptMarker = Value
    EndSelect
    
  EndProcedure

  Procedure   SetSalt(String.s)
	  qAES\Salt = String
	EndProcedure
	
	;- _____ SmartCoder _____
	
	Procedure.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
	  ; Author: Werner Albus - www.nachtoptik.de (No warranty whatsoever - Use at your own risk)
    ; CounterKey: If you cipher a file blockwise, always set the current block number with this counter (consecutive numbering).
    ; CounterAES: This counter will be automatically used by the coder, but you can change the startpoint.
	  Define.i i, ii, iii, cStep
	  Define.q Rounds, Remaining
	  Define.s Hash$
	  Define   *aRegister.ascii, *wRegister.word, *aBufferIn.ascii, *aBufferOut.ascii, *qBufferIn.quad, *qBufferOut.quad
	  Static   FixedKey${64}
	  Static   Dim Register.q(3)
	  
	  If qAES\Salt = "" : qAES\Salt = #Salt$ : EndIf
	  
	  Hash$     = qAES\Salt + Key + Str(CounterKey) + ReverseString(qAES\Salt)
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
	          qAES\Error = #ERROR_ENCODING_FAILS
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
            qAES\Error = #ERROR_ENCODING_FAILS
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
            qAES\Error = #ERROR_ENCODING_FAILS
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
	          qAES\Error = #ERROR_ENCODING_FAILS
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
	          qAES\Error = #ERROR_ENCODING_FAILS
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

	Procedure.i SmartFileCoder(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
	  ; Set ProtectionMode <> 0 activates the file protection mode (adds Hash and so on)
	  ; Set on this variable to define the CounterAES from the universal crypter
    ; This protect a file, but dont encrypt the file. Mostly files you can normaly use protected
	  Define.i i, CryptRandom, EncryptedFileFound, HashBytes
	  Define.i FileID, BlockSize, Blocks, BlockCounter, Remaining
	  Define.q Counter, cCounter, spCounter, Magic
	  Define.q FileSize, fCounter, ReadBytes, WritenBytes, fMagic ; File data
	  Define.s Key$, Hash$, cHash$
	  Define   *Buffer
	  
	  If CryptExtension
	    If FileSize(GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)) > 0
	      File = GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)
	    EndIf
	  EndIf
	  
	  If FileSize(File) <= 0
	    qAES\Error = #ERROR_FILE_NOT_EXIST
	    ProcedureReturn #False
	  EndIf
	  
	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
	  If qAES\EnlargeBytes    = 0 : qAES\EnlargeBytes    = 128    : EndIf
	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
	  If qAES\Salt = ""           : qAES\Salt            = #Salt$ : EndIf
	  
	  qAES\CryptExtLength = 8 + 8 + qAES\HashLength >> 3
	  Dim Hash.q(qAES\HashLength >> 3 - 1)
	  
	  If ProtectionMode ;{ Counter / Magic
	    
      Counter = ProtectionMode
      Magic   = qAES\ProtectedMarker
      
    Else
      
      If OpenCryptRandom()
        CryptRandom = #True
        CryptRandomData(@Counter, 8)
      Else
        CryptRandom = #False
        RandomData(@Counter, 8)
      EndIf
      
      Magic = qAES\CryptMarker
      
      If Not Counter 
        qAES\Error = #ERROR_CAN_NOT_CREATE_COUNTER
        ProcedureReturn #False
      EndIf
      ;}
    EndIf
    
    If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2 ; Check Fingerprint
      qAES\Error = #ERROR_FINGERPRINT_FAILS
      ProcedureReturn #False
    EndIf
    
    Key$  = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
    Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
    
    SmartCoder(#Binary, @Magic, @Magic, 8, qAES\Salt + ReverseString(Key$) + Str(Magic) + Key$)

    FileID = OpenFile(#PB_Any, File)
    If FileID
      
      FileSize = Lof(FileID)
      
      BlockSize = 4096 << 2
      FileBuffersSize(FileID, BlockSize)
      
      *Buffer = AllocateMemory(BlockSize)
      If *Buffer
        
        FileSeek(FileID, FileSize - qAES\CryptExtLength)
        
        ;{ Read file header
        ReadData(FileID, @fCounter, 8)
        ReadData(FileID, @fMagic, 8)
        ReadData(FileID, @Hash(0), qAES\HashLength >> 3)
        FileSeek(FileID, 0)
        ;}
        
        ;{ Decrypt file header
        SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
        SmartCoder(#Binary, @fMagic, @fMagic, 8, ReverseString(Key$) + Key$, fCounter)
        SmartCoder(#Binary, @Hash(0), @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), fCounter)
        ;}
        
        If fMagic = Magic ;{ File encrypted?
        
          cCounter = fCounter
          EncryptedFileFound = #True
          
        Else
  
          SmartCoder(#Binary, @Magic, @Magic, 8, ReverseString(Key$) + Key$, Counter) ; Encrypt magic
          cCounter = Counter
          ;}
        EndIf
        
        Blocks    = (FileSize - qAES\CryptExtLength) / BlockSize
        Remaining = FileSize - (BlockSize * Blocks)
        
        If EncryptedFileFound : Remaining - qAES\CryptExtLength : EndIf
        
        Repeat 
          
          ReadBytes = ReadData(FileID, *Buffer, BlockSize)
      
          If EncryptedFileFound ;{ File encrypted
          
            HashBytes = ReadBytes - qAES\CryptExtLength
        
            If ReadBytes = BlockSize : HashBytes = ReadBytes : EndIf

            If HashBytes > 0
              
              BlockCounter + 1
              
              If Remaining 
                If BlockCounter > Remaining : HashBytes = Remaining : EndIf
              Else
                HashBytes = FileSize - qAES\CryptExtLength
              EndIf
              
              Hash$  = Fingerprint(*buffer, HashBytes, #PB_Cipher_SHA3, qAES\HashLength)
              Hash$ + Key$ + cHash$ + Str(cCounter)
              Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
              cHash$ = Hash$
              
            EndIf

            If Not ProtectionMode
              SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
            EndIf
            ;}
          Else                  ;{ File not encrypted
            
            If Not ProtectionMode
              SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
            EndIf
            
            If ReadBytes > 0
              Hash$  = Fingerprint(*Buffer, ReadBytes, #PB_Cipher_SHA3, qAES\HashLength)
              Hash$ + Key$ + cHash$ + Str(cCounter)
              Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
              cHash$ = Hash$ 
            EndIf
            ;}
          EndIf
          
          FileSeek(FileID, -ReadBytes, #PB_Relative)
          WritenBytes + WriteData(FileID, *Buffer, ReadBytes)
          
          cCounter  + 1
          spCounter + 1
          
        Until ReadBytes = 0
        
        Hash$ + Key$ + qAES\Salt ; Finishing fingerprint
        Hash$ = LCase(Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength))
        
        If EncryptedFileFound ;{ File encrypted
          
          FileSeek(FileID, -qAES\CryptExtLength, #PB_Relative)
          TruncateFile(FileID)
          
          ;}
        Else                  ;{ File not encrypted
          
          For i=0 To qAES\HashLength >> 3 - 1
            PokeA(@Hash(0) + i, Val("$" + PeekS(@Hash$ + i *SizeOf(character) << 1, 2)))
          Next
          
          ;{ Crypt file header
          SmartCoder(#Binary, @Hash(0), @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), Counter)
          SmartCoder(#Binary, @Counter, @Counter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
          ;}
          
          WritenBytes + WriteData(FileID, @Counter, 8)
          WritenBytes + WriteData(FileID, @Magic, 8)
          WritenBytes + WriteData(FileID, @Hash(0), qAES\HashLength >> 3)
          Debug "FileCoder: " + Hash(0)
          ;}
        EndIf
        
        FreeMemory(*Buffer)
      EndIf
      
      CloseFile(FileID)
      
      If CryptExtension
        
        If EncryptedFileFound
          RenameFile(File, RemoveString(File, CryptExtension))
        Else
          RenameFile(File, GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File))
        EndIf
        
      Else
        
        If EncryptedFileFound
          RenameFile(File, RemoveString(File, ".aes", #PB_String_NoCase, Len(File) - 4))
        Else
          RenameFile(File, File + ".aes")
        EndIf
        
      EndIf
      
    Else 
      qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
      ProcedureReturn #False
    EndIf
    
	EndProcedure
	
  Procedure.i CheckIntegrity(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
	  Define.q FileSize, Counter, fCounter, cCounter, spCounter, ReadBytes, WritenBytes, Magic, fMagic
	  Define.i FileID, CryptRandom, EncryptedFileFound, CheckIntegrity, FileBroken
	  Define.i i, Blocks, BlockSize, Remaining, HashBytes, BlockCounter
	  Define.s Key$, Hash$, fHash$, cHash$
	  Define   *Buffer
	  
	  If CryptExtension ;{
	    If FileSize(GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)) > 0
	      File = GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)
	    EndIf ;}
	  EndIf
	  
	  If FileSize(File) <= 0
	    qAES\Error = #ERROR_FILE_NOT_EXIST
	    ProcedureReturn #False
	  EndIf
	  
	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
	  If qAES\Salt = "" : qAES\Salt = #Salt$ : EndIf
	  
	  qAES\CryptExtLength = 8 + 8 + qAES\HashLength >> 3
	  Dim Hash.q(qAES\HashLength >> 3 - 1)
	  
	  If ProtectionMode ;{ Counter / Magic
	    
      Counter = ProtectionMode
      Magic   = qAES\ProtectedMarker
      
    Else
      
      If OpenCryptRandom()
        CryptRandom = #True
        CryptRandomData(@Counter, 8)
      Else
        CryptRandom = #False
        RandomData(@Counter, 8)
      EndIf
      
      Magic = qAES\CryptMarker
      
      If Not Counter 
        qAES\Error = #ERROR_CAN_NOT_CREATE_COUNTER
        ProcedureReturn #False
      EndIf
      ;}
    EndIf
    
    If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2
      qAES\Error = #ERROR_FINGERPRINT_FAILS
      ProcedureReturn #False
    EndIf
    
    Key$  = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
    Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
    
    SmartCoder(#Binary, @Magic, @Magic, 8, qAES\Salt + ReverseString(Key$) + Str(Magic) + Key$)
    
	  FileID = ReadFile(#PB_Any, File)
	  If FileID
	    
	    FileSize = Lof(FileID)
	    
	    BlockSize = 4096 << 2
      FileBuffersSize(FileID, BlockSize)
      
      *Buffer = AllocateMemory(BlockSize)
      If *Buffer
	    
  	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
  	    
  	    ;{ Read file header
  	    ReadData(FileID, @fCounter, 8)
  	    ReadData(FileID, @fMagic, 8)
  	    ReadData(FileID, @Hash(0), qAES\HashLength >> 3)
        FileSeek(FileID, 0)
        ;}

        ;{ Decrypt file header
  	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
        SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
        SmartCoder(#Binary, @Hash(0),  @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), fCounter)
        ;}
        
        If fMagic = Magic ;{ File encrypted
          
          EncryptedFileFound = #True
          cCounter = fCounter
          
          For i = 0 To qAES\HashLength >> 3 - 1
            fHash$ + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
          Next i
          fHash$ = LCase(fHash$)
          ;}
        Else              ;{ File not encrypted
          
          SmartCoder(#Binary, @Magic, @Magic, 8, ReverseString(Key$) + Key$, Counter)
          cCounter = Counter
         
          ;}
        EndIf    
        
        Blocks    = (FileSize - qAES\CryptExtLength) / BlockSize
        Remaining = FileSize - (BlockSize * Blocks)
       
        If EncryptedFileFound : Remaining - qAES\CryptExtLength : EndIf
        
        Repeat 
          
          ReadBytes = ReadData(FileID, *Buffer, BlockSize)
          
          If EncryptedFileFound ;{ File encrypted
            
            HashBytes = ReadBytes - qAES\CryptExtLength
        
            If ReadBytes = BlockSize : HashBytes = ReadBytes : EndIf
            
            If HashBytes > 0
              
              BlockCounter + 1
              
              If Remaining 
                If BlockCounter > Remaining : HashBytes = Remaining : EndIf
              Else
                HashBytes = FileSize - qAES\CryptExtLength
              EndIf
              
              Hash$  = Fingerprint(*Buffer, HashBytes, #PB_Cipher_SHA3, qAES\HashLength)
              Hash$ + Key$ + cHash$ + Str(cCounter)
              Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
              cHash$ = Hash$

            EndIf
            
            If Not ProtectionMode
              SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
            EndIf
            ;}
          Else                  ;{ File not encrypted  
            
            If Not ProtectionMode
              SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
            EndIf
            
            If ReadBytes > 0
              Hash$  = Fingerprint(*Buffer, ReadBytes, #PB_Cipher_SHA3, qAES\HashLength)
              Hash$ + Key$ + cHash$ + Str(cCounter)
              Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
              cHash$ = Hash$ 
            EndIf
            ;}
          EndIf
          
          WritenBytes + ReadBytes
          
          cCounter  + 1
          spCounter + 1
          
        Until ReadBytes = 0
        
        Hash$ + Key$ + qAES\Salt ; Finishing fingerprint
        Hash$ = LCase(Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength))
        
        If EncryptedFileFound
          If Hash$ <> fHash$ : FileBroken = #True : EndIf
        EndIf
        
        FreeMemory(*Buffer)
      EndIf
      
      CloseFile(FileID)
    Else 
      qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
      ProcedureReturn #False  
	  EndIf
	  
	  If FileBroken
	    ProcedureReturn #False
	  Else
	    ProcedureReturn #True
	  EndIf
	  
	EndProcedure
	
	Procedure.i IsEncrypted(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
	  Define.q FileSize, Counter, fCounter, Magic, fMagic
	  Define.i FileID, CryptRandom, EncryptedFileFound
	  Define.s Key$
	  
	  If CryptExtension
	    If FileSize(GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)) > 0
	      File = GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)
	    EndIf
	  EndIf
	  
	  If FileSize(File) <= 0
	    qAES\Error = #ERROR_FILE_NOT_EXIST
	    ProcedureReturn #False
	  EndIf
	  
	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
	  If qAES\Salt = "" : qAES\Salt = #Salt$ : EndIf
	  
	  qAES\CryptExtLength = 8 + 8 + qAES\HashLength >> 3
	  
	  If ProtectionMode ;{ Counter / Magic
	    
      Counter = ProtectionMode
      Magic   = qAES\ProtectedMarker
      
    Else
      
      If OpenCryptRandom()
        CryptRandom = #True
        CryptRandomData(@Counter, 8)
      Else
        CryptRandom = #False
        RandomData(@Counter, 8)
      EndIf
      
      Magic = qAES\CryptMarker
      
      If Not Counter 
        qAES\Error = #ERROR_CAN_NOT_CREATE_COUNTER
        ProcedureReturn #False
      EndIf
      ;}
    EndIf
    
    If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2
      qAES\Error = #ERROR_FINGERPRINT_FAILS
      ProcedureReturn #False
    EndIf
    
    Key$  = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
    Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
    
    SmartCoder(#Binary, @Magic, @Magic, 8, qAES\Salt + ReverseString(Key$) + Str(Magic) + Key$)
    
	  FileID = ReadFile(#PB_Any, File)
	  If FileID
	    
	    FileSize = Lof(FileID)
	    
	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
	    
	    ReadData(FileID, @fCounter, 8)
	    ReadData(FileID, @fMagic, 8)
	    
	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
      SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
      
      If fMagic = Magic 
        EncryptedFileFound = #True
      EndIf    
   
      CloseFile(FileID)
    Else 
      qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
      ProcedureReturn #False  
	  EndIf
	  
	  ProcedureReturn EncryptedFileFound
	EndProcedure
	
	;- _____ Encode / Decode only _____
	
  Procedure.s String(String.s, Key.s, KeyStretching.i=#False) 
    ; KeyStretching: number of loops for KeyStretching()
    Define   *Input, *Output
    Define.i StrgSize
    Define.s Output$
    
    If KeyStretching
      Key = KeyStretching(Key, KeyStretching)
    EndIf     
    
    *Input = @String
    If *Input
      CompilerIf #PB_Compiler_Unicode
  
        StrgSize = StringByteLength(String, #PB_Unicode) + 2
        If StrgSize
          *Output = AllocateMemory(StrgSize)
          If *Output
            SmartCoder(#Unicode, *Input, *Output, StrgSize, Key)
            Output$ = PeekS(*Output, StrgSize, #PB_Unicode)
            FreeMemory(*Output)
          EndIf
        EndIf
        
      CompilerElse
        
        StrgSize = StringByteLength(String, #PB_Ascii) + 1
        If StrgSize
          *Output = AllocateMemory(StrgSize)
          If *Output
            SmartCoder(#Ascii, *Input, *Output, StrgSize, Key)
            Output$ = PeekS(*Output, StrgSize, #PB_Ascii)
            FreeMemory(*Output)
          EndIf
        EndIf
        
      CompilerEndIf
    EndIf
    
    ProcedureReturn Output$
  EndProcedure
  
  Procedure.i File(File.s, outFile.s, Key.s, KeyStretching.i=#False) 
    Define   *Input, *Output
    Define.i FileID, FileSize, Result
    
    If KeyStretching
      Key = KeyStretching(Key, KeyStretching)
    EndIf 
    
    FileID = ReadFile(#PB_Any, File)
    If FileID
      
      FileSize = Lof(FileID)
      
      *Input  = AllocateMemory(FileSize)
      If *Input
        
        If ReadData(FileID, *Input, FileSize)
          
          CloseFile(FileID)
          
          *Output = AllocateMemory(FileSize)
          If *Output
            
            SmartCoder(#Binary, *Input, *Output, FileSize, Key)
            
            FileID = CreateFile(#PB_Any, outFile)
            If FileID 
              Result = WriteData(FileID, *Output, FileSize)
              CloseFile(FileID)
            EndIf
            
            FreeMemory(*Output)
          EndIf
          
        EndIf
        
        FreeMemory(*Input)
      EndIf
      
    Else
      qAES\Error = #ERROR_FILE_NOT_EXIST
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn Result
  EndProcedure  

EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 1
  
  ; 1: String
  ; 2: File (only encrypt / decrypt)
  ; 3: FileCoder
  ; 4: FileCoder with CryptExtension
  ; 5: Check integrity
  
  Enumeration 1
    #Window
    #ProgressBar
    #Image
  EndEnumeration

  #CryptExtension$ = " [encrypted]"
  
  Key$  = "18qAES07PW67"
  
  CompilerSelect #Example
    CompilerCase 1 
      
      Text$ = "This is a test text for the qAES-Module."
  
      encText$ = qAES::String(Text$, Key$) 
      Debug encText$
      
      decText$ = qAES::String(encText$, Key$)
      Debug decText$
      
    CompilerCase 2 
      
      qAES::File("PureBasic.jpg", "PureBasic.jpg.aes", Key$) 
      qAES::File("PureBasic.jpg.aes", "Test.jpg", Key$) 
      
    CompilerCase 3
      
      qAES::FileCoder("PureBasic.jpg", Key$)
      ;qAES::FileCoder("PureBasic.jpg.aes", Key$)
      
    CompilerCase 4  
      
      qAES::FileCoder("PureBasic.jpg", Key$, #CryptExtension$)
      If qAES::IsEncrypted("PureBasic.jpg", Key$, #CryptExtension$)
        Debug "File is encrypted"
      Else
        Debug "File is not encrypted"
      EndIf
      
    CompilerCase 5
      
      qAES::FileCoder("PureBasic.jpg", Key$, #CryptExtension$)
      If qAES::CheckIntegrity("PureBasic.jpg", Key$, #CryptExtension$)
        Debug "File integrity succesfully checked"
      Else
        Debug "File hash not valid"
      EndIf 
      
  CompilerEndSelect

CompilerEndIf

; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 996
; Folding = GABBkAq-
; Markers = 480,694
; EnableXP
; DPIAware