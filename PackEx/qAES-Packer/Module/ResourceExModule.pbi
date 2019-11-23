;/ ==========================
;/ =    ResourceExModule.pbi    =
;/ ==========================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/
;/ Encryption based on code of Werner Albus - www.nachtoptik.de
;/ 
;/ © 2019 Thorsten1867 (08/2019)
;/


; Last Update: 


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
; Copyright (c) 2019 Werner Albus - www.nachtoptik.de
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


;{ _____ ResourceEx - Commands _____


;}


DeclareModule ResourceEx

  ;- ==================================
	;-   DeclareModule
  ;- ==================================
  
  Declare.s CreateSecureKey(Key.s, Loops.i=2048)
  Declare   Close(ID.i)
  Declare.i UseImage(ID.i, Image.i, FileName.s)
  Declare.i UseJSON(ID.i, JSON.i, FileName.s, Flags.i=#False)
  Declare.i UseMusic(ID.i, Music.i, FileName.s, Flags.i=#False)
  Declare.s UseText(ID.i, FileName.s, Flags.i=#PB_UTF8)
  Declare.i UseSound(ID.i, Sound.i, FileName.s)
  Declare.i UseXML(ID.i, XML.i, FileName.s, Flags.i=#False, Encoding.i=#PB_UTF8)
  Declare.i Open(ID.i, File.s, Key.s="")
  
EndDeclareModule

Module ResourceEx
  
  EnableExplicit
  
  UseSHA3Fingerprint()
  
  ;- ==================================
	;-   Module - Constants
	;- ==================================
  
  Enumeration
    #Binary
    #Ascii
    #Unicode
  EndEnumeration

  #qAES  = 113656983
  #Salt$ = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"
  
  ;- ==================================
  ;-   Module - Structure
	;- ==================================

  Structure AES_Structure         ;{ qAES\...
    Salt.s
    KeyStretching.i
    Loops.i
    Hash.s
    *ProcPtr
  EndStructure ;}
  Global qAES.AES_Structure
  
  Structure ResEx_File_Structure ;{ ResEx()\Files('file')...
    Size.q
    Hash.s
  EndStructure ;}
  
  Structure ResEx_Structure      ;{ ResEx('pack')\...
    ID.i
    File.s
    Key.s
    TempDir.s
    Map Files.ResEx_File_Structure()
  EndStructure ;}
  Global NewMap ResEx.ResEx_Structure()
    
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
  
  
	Procedure.i DecryptMemory_(*Buffer, Size.i, Key.s, ProgressBar.i=#False)
	  Define.q Counter, qAES_ID
	  
	  Counter   = PeekQ(*Buffer + Size - 8)
    qAES_ID   = PeekQ(*Buffer + Size - 16)
    qAES\Hash = DecodeHash_(Counter, *Buffer + Size - 48, #False)
    
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    If qAES_ID = #qAES
      
      Size - 48
      
      SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
      
      If qAES\Hash <> Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        ProcedureReturn #False
      EndIf

    EndIf 
    
	  ProcedureReturn Size
	EndProcedure

	Procedure   ReadContent_()
	  
	  ClearMap(ResEx()\Files())
    
    If ExaminePack(ResEx()\ID)
      While NextPackEntry(ResEx()\ID)
        If AddMapElement(ResEx()\Files(), PackEntryName(ResEx()\ID))
          ResEx()\Files()\Size       = PackEntrySize(ResEx()\ID, #PB_Packer_UncompressedSize)
        EndIf
      Wend
    EndIf
    
	EndProcedure
	
	Procedure.i TempDir_(ID.i)
	  
	  ResEx()\TempDir = GetTemporaryDirectory() + "ResEx" + RSet(Str(ID), 4, "0") + #PS$
    If CreateDirectory(ResEx()\TempDir)
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
      
      If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
       
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
  
  Procedure.s CreateSecureKey(Key.s, Loops.i=2048)
    ProcedureReturn KeyStretching_(Key, Loops)
  EndProcedure
  
  
  Procedure.i Open(ID.i, File.s, Key.s="")
    
    If ID = #PB_Any
      ID = 1 : While FindMapElement(ResEx(), Str(ID)) : ID + 1 : Wend
    EndIf
    
    If AddMapElement(ResEx(), Str(ID))
      
      ResEx()\ID   = OpenPack(#PB_Any, File, #PB_PackerPlugin_Lzma)
      ResEx()\File = File
      ResEx()\Key  = Key
      
      ReadContent_()
      
      TempDir_(ID)
      
      ProcedureReturn ResEx()\ID
    EndIf
    
  EndProcedure
  
  
  Procedure.i UseXML(ID.i, XML.i, FileName.s, Flags.i=#False, Encoding.i=#PB_UTF8)
    Define   *Buffer
    Define.i Size, Result 
    
    If FindMapElement(ResEx(), Str(ID))
      
      If FindMapElement(ResEx()\Files(), FileName)
       
        Size = ResEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
            Size   = DecryptMemory_(*Buffer, Size, ResEx()\Key)
            Result = CatchXML(XML, *Buffer, Size, Flags, Encoding)
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
       
      EndIf

    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i UseJSON(ID.i, JSON.i, FileName.s, Flags.i=#False)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(ResEx(), Str(ID))
      
      If FindMapElement(ResEx()\Files(), FileName)
       
        Size = ResEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
            Size   = DecryptMemory_(*Buffer, Size, ResEx()\Key)
            Result = CatchJSON(JSON, *Buffer, Size, Flags)
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure

  Procedure.i UseImage(ID.i, Image.i, FileName.s)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(ResEx(), Str(ID))
      
      If FindMapElement(ResEx()\Files(), FileName)
        
        Size = ResEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
            Size = DecryptMemory_(*Buffer, Size, ResEx()\Key)
            Result = CatchImage(Image, *Buffer, Size)
          EndIf

          FreeMemory(*Buffer)
        EndIf
       
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.s UseText(ID.i, FileName.s, Flags.i=#PB_UTF8)
    Define   *Buffer
    Define.i Size
    Define.s String
    
    If FindMapElement(ResEx(), Str(ID))
      
      If FindMapElement(ResEx()\Files(), FileName)
      
        Size = ResEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer

          If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
            Size   = DecryptMemory_(*Buffer, Size, ResEx()\Key)
            String = PeekS(*Buffer, Size, Flags) 
          EndIf

          FreeMemory(*Buffer)
        EndIf
       
      EndIf
     
    EndIf
    
    ProcedureReturn String
  EndProcedure
  
  Procedure.i UseSound(ID.i, Sound.i, FileName.s)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(ResEx(), Str(ID))
      
      If FindMapElement(ResEx()\Files(), FileName)
          
          Size = ResEx()\Files()\Size
      
          *Buffer = AllocateMemory(Size)
          If *Buffer

            If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
              Size = DecryptMemory_(*Buffer, Size, ResEx()\Key)
              Result = CatchSound(Sound, *Buffer, Size)
            EndIf

            FreeMemory(*Buffer)
          EndIf
          
      EndIf
     
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i UseSprite(ID.i, Sprite.i, FileName.s, Flags.i=#False)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(ResEx(), Str(ID))
      
      If FindMapElement(ResEx()\Files(), FileName)
          
          Size = ResEx()\Files()\Size
      
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
              If DecryptMemory_(*Buffer, Size, ResEx()\Key)
                Result = CatchSprite(Sprite, *Buffer, Flags)
              EndIf
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
      EndIf
     
    EndIf
    
    ProcedureReturn Result
  EndProcedure

  Procedure.i UseMusic(ID.i, Music.i, FileName.s, Flags.i=#False)
    Define   *Buffer
    Define.i Size, Result
    
    If FindMapElement(ResEx(), Str(ID))
      
      If FindMapElement(ResEx()\Files(), FileName)
          
          Size = ResEx()\Files()\Size
      
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If UncompressPackMemory(ResEx()\ID, *Buffer, Size, FileName) <> -1
              Size = DecryptMemory_(*Buffer, Size, ResEx()\Key)
              Result = CatchMusic(Music, *Buffer, Size)
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
      EndIf
     
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure   Close(ID.i)
    
    If FindMapElement(ResEx(), Str(ID))
      
      ClosePack(ResEx()\ID)
      
      DeleteMapElement(ResEx())
    EndIf
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #ResEx = 1
  #XML   = 1
  #JSON  = 1
  #Image = 1
  
  UseJPEGImageDecoder()
  UseLZMAPacker()

  Key$  = "18qAES07PW67"
  
  If ResourceEx::Open(#ResEx, "Test.res", Key$)
    
    If ResourceEx::UseXML(#ResEx, #XML, "Test.xml")
      FormatXML(#XML, #PB_XML_ReFormat)
      Debug ComposeXML(#XML)
    EndIf
    
    If ResourceEx::UseJSON(#ResEx, #JSON, "Test.json")
      Debug ComposeJSON(#JSON)
    EndIf
    
    Debug " "
    
    Debug ResourceEx::UseText(#ResEx, "Test.txt")
    
    Debug " "
    
    If ResourceEx::UseImage(#ResEx, #Image, "Test.jpg")
      If IsImage(#Image) : SaveImage(#Image, "Decrypted.jpg") : EndIf
    EndIf
    
    ResourceEx::Close(#ResEx)
  EndIf
  
  
  
CompilerEndIf  
; IDE Options = PureBasic 5.71 LTS (Windows - x86)
; CursorPosition = 671
; FirstLine = 112
; Folding = uwHAA+
; EnableXP
; DPIAware