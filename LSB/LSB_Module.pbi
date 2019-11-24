;/ =========================
;/ =    LSB_Module.pbi    =
;/ =========================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/
;/ © 2019 Thorsten Hoeppner (09/2019) 
;/

; Last Update: 


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
; Copyright (c) 2019 Werner Albus (encryption)
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


;{ _____ LSB - Commands _____

; LSB::Create()        - create a image with LSB embedded files or data
; LSB::Open()          - open a image with LSB embedded files or data
  
; LSB::EmbedFile()     - embed file in image
; LSB::ExtractFile()   - extract file from image
; LSB::EmbedXML()      - embed XML in image
; LSB::ExtractXML()    - extract XML from image
; LSB::EmbedJSON()     - embed JSON in image
; LSB::ExtractJSON()   - extract JSON from image
; LSB::EmbedString()   - embed string in image
; LSB::ExtractString() - extract string from image
  
; LSB::Save()          - save image with LSB embedded files or data
; LSB::Close()         - close 
  
; LSB::GetSpace()      - [#Image/#Available/#Used]
  ;} ___________________________
  
  
DeclareModule LSB
  
  #Version  = 19112300
  
  #Enable_KeyCard = #True
  
  EnumerationBinary ;{ Text Flags
	  #Center = #PB_Text_Center
	  #Right  = #PB_Text_Right
	  #Left
	  #Top
	  #Middle
	  #Bottom
	  #FitText
	  #FixPadding
	EndEnumeration ;}
  
  Enumeration 1
    #Image
    #Available
    #Used
  EndEnumeration  

  Global NewList File.s() ; embedded files
  
  ;- ===========================================================================
	;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i Create(ID.i, ImageFile.s, Key.s="", Plugin.i=#PB_ImagePlugin_PNG)
  Declare.i Open(ID.i, ImageFile.s, Key.s="")
  
  Declare.i EmbedFile(ID.i, File.s)
  Declare.i ExtractFile(ID.i, File.s="")
  Declare.i EmbedXML(ID.i, XML.i, Label.s)
  Declare.i ExtractXML(ID.i, XML.i, Label.s)
  Declare.i EmbedJSON(ID.i, JSON.i, Label.s)
  Declare.i ExtractJSON(ID.i, JSON.i, Label.s)
  Declare.i EmbedString(ID.i, String.s, Label.s)
  Declare.s ExtractString(ID.i, Label.s) 
  
  Declare.i Save(ID.i, ImageFile.s="")
  Declare   Close(ID.i)
  
  Declare.i GetSpace(ID.i, Type.i=#Available)
  
  CompilerIf #Enable_KeyCard
    
    Declare.i KeyCard(ID.i, KeyCode.s)
    Declare.i AddCardText(ID.i, Text.s, FontNum.i, Color.i=$000000, Flags.i=#False)
    Declare.i AddCardInfo(ID.i, Label.s, Value.s)
    
  CompilerEndIf
  
EndDeclareModule

Module LSB
  
  EnableExplicit
  
  UseSHA3Fingerprint()
  
  #Binary  = 0  
  #Ascii   = 1 
  #Unicode = 2
  
	#Salt$ = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"
  
  Enumeration 1
    #Write
    #Read
  EndEnumeration
  
  Structure Memory_Structure      ;{ Memory\...
	  *Buffer
	  Size.q
	  Compressed.q
	EndStructure ;}
	
	Structure KeyCard_Margins_Structure ;{ ImageEx()\Card\...
		Top.i
		Left.i
		Right.i
		Bottom.i
	EndStructure ;}
	
	Structure KeyCard_Item_Structure ;{ LSB()\Card\Item\...
	  Text.s
	  Color.i
	  Font.i
	  Flags.i
	EndStructure ;}
	
	Structure LSB_KeyCard_Structure  ;{ LSB()\Card\...
	  *Buffer
	  Size.i
	  Label.s
	  Key.s
	  Map  Entry.s()
	  List Item.KeyCard_Item_Structure()
	  Margin.KeyCard_Margins_Structure
	  ;Flags.i
	EndStructure ;}
	
	Structure LSB_Item_Structure     ;{ LSB()\Item()\...
	  *Buffer
	  Size.q
	  OffSet.q
	  Compressed.q
	EndStructure ;}

	Structure LSB_Structure          ;{ LSB('id')\...
	  Image.i
	  FileName.s
	  Plugin.i
	  Key.s
	  Mode.i
	  Map Item.LSB_Item_Structure()
	  Card.LSB_KeyCard_Structure
	  KeyCard.i
	  UsedSize.i
	  EmbedSize.i
	EndStructure ;}
	Global NewMap LSB.LSB_Structure()
	
  ;- ==========================================================================
	;-   Module - Internal Procedures
	;- ==========================================================================
	
  Procedure.s KeyStretching_(Key.s, Loops.i, ProgressBar.i=#PB_Default)
    ; Author Werner Albus - www.nachtoptik.de
    Define.i i, Timer
    Define.s Salt$

	  Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
    
    For i=1 To Loops
      Key = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512)
    Next
    
    Key = ReverseString(Key) + Salt$ + Key + ReverseString(Key)
    Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512) ; Finalize
    
    ProcedureReturn Key
  EndProcedure
	
  Procedure.q GetCounter_()
	  Define.q Counter
	  
	  If OpenCryptRandom()
        CryptRandomData(@Counter, 8)
    Else
      RandomData(@Counter, 8)
    EndIf
    
    ProcedureReturn Counter
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
	  
	  Salt$ = #Salt$
	  
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
	
	
  Procedure.q CompressBuffer_(*Buffer, Size.q) 
	  Define.q Compressed
	  Define   *Compress
	  
	  If *Buffer And Size
	    
	    *Compress = AllocateMemory(Size)
	    If *Compress
	      
	      Compressed = CompressMemory(*Buffer, Size, *Compress, Size, #PB_PackerPlugin_Lzma, 9)
	      If Compressed
	        CopyMemory(*Compress, *Buffer, Compressed)
	        FreeMemory(*Compress)  
	      EndIf
	      
	    EndIf
	    
	  EndIf
	  
	  ProcedureReturn Compressed
	EndProcedure  
	
	Procedure.i CompressJSON_(JSON.i, *Memory.Memory_Structure)
	  Define.q Size, Compressed  
	  Define   *JSON
	  
	  If IsJSON(JSON)
	    
  	  Size = ExportJSONSize(JSON)
      If Size
        
        *JSON = AllocateMemory(Size + 16)
        If *JSON
          
          If ExportJSON(JSON, *JSON + 16, Size)
            
            Compressed = CompressBuffer_(*JSON + 16, Size) 
            If Compressed
              PokeQ(*JSON, Compressed + 8)
              PokeQ(*JSON + 8, Size)
              *Memory\Buffer     = ReAllocateMemory(*JSON, Compressed + 16)
              *Memory\Size       = Size + 16
              *Memory\Compressed = Compressed + 16
            Else
              PokeQ(*JSON, Size + 8)
              PokeQ(*JSON + 8, 0)
              *Memory\Buffer     = *JSON
              *Memory\Size       = Size + 16
              *Memory\Compressed = Size + 16
            EndIf
            
            ProcedureReturn *Memory\Compressed
          EndIf  
    	    
        EndIf
        
      EndIf
      
    EndIf
    
  	ProcedureReturn #False
	EndProcedure
	
  Procedure.i WriteLSB_(*Buffer, Size.q, Bit.b=1)
    Define.i b, i, EmbedSize, Result
    Define.a iByte, bByte
    Define   *Image
    
    If IsImage(LSB()\Image)
      
      If StartDrawing(ImageOutput(LSB()\Image))
        
        *Image = DrawingBuffer()
        If *Image
          
          For b=1 To Size
            
            bByte = PeekA(*Buffer)
            
            For i=0 To 7
              iByte = PeekA(*Image)
              iByte & ~Bit
              If Bool(bByte & (1 << i)) : iByte | Bit : EndIf
              PokeA(*Image, iByte)
              *Image + 1
            Next
            
            *Buffer + 1
          Next
          
          Result = #True
        EndIf

        StopDrawing()
      EndIf

    EndIf
    
    ProcedureReturn  Result
  EndProcedure
  
  
  Procedure.i Embed_(*Buffer, Size.q, *Memory.Memory_Structure) 
    Define.i Bytes
    Define.q Compressed, Counter
    Define   *Compress
    
    Bytes = 16
    If LSB()\Key : Bytes + 8 : EndIf
    
    *Compress =  AllocateMemory(Size)
    If *Compress
    
      Compressed = CompressMemory(*Buffer, Size, *Compress, Size, #PB_PackerPlugin_Lzma)
      If Compressed
        
        *Memory\Buffer = AllocateMemory(Compressed + Bytes)
        If *Memory\Buffer
          PokeQ(*Memory\Buffer, Compressed + Bytes - 8)
          PokeQ(*Memory\Buffer + 8, Size)
          CopyMemory(*Compress, *Memory\Buffer + 16, Compressed)
          *Memory\Size       = Compressed + Bytes
          *Memory\Compressed = Size + Bytes
        EndIf
      
      Else  
        
        *Memory\Buffer = AllocateMemory(Size + Bytes)
        If *Memory\Buffer
          PokeQ(*Memory\Buffer, Size + Bytes - 8)
          PokeQ(*Memory\Buffer + 8, 0)
          CopyMemory(*Buffer, *Memory\Buffer + 16, Size)
          *Memory\Size       = Size + Bytes
          *Memory\Compressed = Size + Bytes
        EndIf
        
      EndIf
      
      FreeMemory(*Compress)
    EndIf 
    
    If LSB()\Key
      
      If *Memory\Buffer  
        Counter = GetCounter_()
        SmartCoder(#Binary, *Memory\Buffer + 16, *Memory\Buffer + 16, *Memory\Size - 24, LSB()\Key, Counter)
        PokeQ(*Memory\Buffer + *Memory\Size - 8, Counter)
      EndIf
    
    EndIf
    
    ProcedureReturn LSB()\Item()\Compressed
  EndProcedure  
  
  Procedure.i Extract_(*Memory.Memory_Structure, ImageOffset.q=0, Bit.b=1) 
    Define.q Size, Compressed, Counter
    Define.i m, i
    Define.a iByte, mByte
    Define   *Image, *Pointer, *Buffer
 
    If IsImage(LSB()\Image)
    
      If StartDrawing(ImageOutput(LSB()\Image))

        *Image = DrawingBuffer()
        If *Image
          
          *Image + (ImageOffset * 8)
          
          ;{ Read Size (Quad)
          For i=0 To 63
            iByte = PeekA(*Image)
            If iByte & Bit : Size | 1 << i : EndIf 
            *Image + 1
          Next ;}
         
          If Size + 8 > 0 And Size + 8 < LSB()\EmbedSize
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
            
              *Pointer = *Buffer
              
              ;{ Extract from image
              For m=1 To Size
                
                mByte = 0
                
                For i=0 To 7
                  iByte = PeekA(*Image)
                  If iByte & Bit : mByte | 1 << i : EndIf 
                  *Image + 1
                Next
                
                PokeA(*Pointer, mByte)
                
                *Pointer + 1
                
                If m > LSB()\EmbedSize : Break : EndIf 
              Next ;}
              
              *Pointer = *Buffer
              Compressed = PeekQ(*Buffer)
              Size - 8
              *Pointer + 8
              
              If LSB()\Key And Bit = 1
                Counter = PeekQ(*Buffer + Size)
                Size - 8
                SmartCoder(#Binary, *Pointer, *Pointer, Size, LSB()\Key, Counter)
              EndIf
              
              ;{ Uncompress Memory
              If Compressed
                
                *Memory\Buffer = AllocateMemory(Compressed)
                If *Memory\Buffer
                  UncompressMemory(*Pointer, Size, *Memory\Buffer, Compressed, #PB_PackerPlugin_Lzma)
                  *Memory\Size = Compressed
                  FreeMemory(*Buffer)
                EndIf 
                
              Else
                
                *Memory\Buffer = AllocateMemory(Size)
                If *Memory\Buffer
                  CopyMemory(*Pointer, *Memory\Buffer, Size)
                  *Memory\Size = Size
                  FreeMemory(*Buffer)
                EndIf
                
              EndIf ;}
              
            EndIf
            
          EndIf 
          
        EndIf
        
        StopDrawing()
      EndIf
    
    EndIf
 
    ProcedureReturn *Memory\Size
  EndProcedure
  
  
  Procedure.i ReadContent_()
    Define.i j, JSON, jFile, jSize, Elements
    Define.q Size
    Define.s File
    Define   Memory.Memory_Structure
    
    If IsImage(LSB()\Image)
      
      ClearList(File())
      ClearMap(LSB()\Item())
      
      If Extract_(@Memory, 0, 2)
        
        JSON = CatchJSON(#PB_Any, Memory\Buffer, Memory\Size)
        If JSON
          
          jFile = GetJSONMember(JSONValue(JSON), "F")
          jSize = GetJSONMember(JSONValue(JSON), "S")
          
          For j=0 To JSONArraySize(jFile) - 1
            File = GetJSONString(GetJSONElement(jFile, j))
            If AddMapElement(LSB()\Item(), File)
              LSB()\Item()\Size = GetJSONQuad(GetJSONElement(jSize, j))
              LSB()\Item()\OffSet = Size
              If AddElement(File()) : File() = File : EndIf
              Size + LSB()\Item()\Size
            EndIf
          Next
  
          FreeJSON(JSON)
        EndIf
        
        FreeMemory(Memory\Buffer)
      EndIf
      
    EndIf
    
  EndProcedure  
  
  CompilerIf #Enable_KeyCard
    
    Procedure DrawKeyCard_()
      Define.i X, Y, tY, bY
      
      If IsImage(LSB()\Image)
      
        If StartDrawing(ImageOutput(LSB()\Image))
          
          tY = LSB()\Card\Margin\Top
          bY = OutputHeight() - LSB()\Card\Margin\Bottom
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          ForEach LSB()\Card\Item()
            DrawingFont(LSB()\Card\Item()\Font)
            
            If LSB()\Card\Item()\Flags & #Center
              X = (OutputWidth() - TextWidth(LSB()\Card\Item()\Text)) / 2
            ElseIf LSB()\Card\Item()\Flags & #Right
              X = OutputWidth() - LSB()\Card\Margin\Right - TextWidth(LSB()\Card\Item()\Text)
            Else
              X = LSB()\Card\Margin\Left
            EndIf  
            
            If LSB()\Card\Item()\Flags & #Bottom
              Y = bY - TextHeight(LSB()\Card\Item()\Text)
            ElseIf LSB()\Card\Item()\Flags & #Middle
              Y =  (OutputHeight() - TextHeight(LSB()\Card\Item()\Text)) / 2
            Else  
              Y = tY
            EndIf
            
            DrawText(X, Y, LSB()\Card\Item()\Text, LSB()\Card\Item()\Color)
            
            If LSB()\Card\Item()\Flags & #Bottom
              bY - TextHeight(LSB()\Card\Item()\Text)
            ElseIf LSB()\Card\Item()\Flags & #Center
              Continue
            Else  
              tY + TextHeight(LSB()\Card\Item()\Text)
            EndIf  
            
          Next
          
          StopDrawing()
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf  
  
  ;- ================================
	;-   Module - Declared Procedures
	;- ================================
  
	Procedure.i Create(ID.i, ImageFile.s, Key.s="", Plugin.i=#PB_ImagePlugin_PNG) 
	  
	  If FindMapElement(LSB(), Str(ID))
	    Debug "ID already exists"
	    ProcedureReturn #False
	  EndIf
	  
	  If Plugin = #PB_ImagePlugin_JPEG Or Plugin = #PB_ImagePlugin_JPEG2000
	    Debug "Image formats with lossy compression cannot be used."
	    ProcedureReturn #False  
	  EndIf
	  
	  If AddMapElement(LSB(), Str(ID))
	    
	    Key = KeyStretching_(Key, 1024)
	    
	    LSB()\Image = LoadImage(#PB_Any, ImageFile)
	    If LSB()\Image
	      
	      LSB()\Mode     = #Write
	      LSB()\FileName = GetFilePart(ImageFile)
	      LSB()\Key      = Key
	      LSB()\Plugin   = Plugin
	      
	      Select ImageDepth(LSB()\Image)
	        Case 24
	          LSB()\EmbedSize = (ImageWidth(LSB()\Image) * ImageHeight(LSB()\Image) * 3) / 8
	        Case 32
	          LSB()\EmbedSize = (ImageWidth(LSB()\Image) * ImageHeight(LSB()\Image) * 4) / 8
	      EndSelect
	      
	      ProcedureReturn LSB()\Image
	    EndIf
	    
	    DeleteMapElement(LSB())
	  EndIf
	  
	  ProcedureReturn #False
  EndProcedure  
  
	Procedure.i Open(ID.i, ImageFile.s, Key.s="") 
	  
	  If FindMapElement(LSB(), Str(ID))
	    Debug "ID already exists"
	    ProcedureReturn #False
	  EndIf
	  
	  If AddMapElement(LSB(), Str(ID))
	    
	    Key = KeyStretching_(Key, 1024)
	    
	    LSB()\Image = LoadImage(#PB_Any, ImageFile)
	    If LSB()\Image
	      
	      LSB()\Mode     = #Read
	      LSB()\FileName = GetFilePart(ImageFile)
	      LSB()\Key      = Key
	      
	      Select ImageDepth(LSB()\Image)
	        Case 24
	          LSB()\EmbedSize = (ImageWidth(LSB()\Image) * ImageHeight(LSB()\Image) * 3) / 8
	        Case 32
	          LSB()\EmbedSize = (ImageWidth(LSB()\Image) * ImageHeight(LSB()\Image) * 4) / 8
	      EndSelect
	      
	      ReadContent_()
	      
	      ProcedureReturn LSB()\Image
	    EndIf
	    
	    DeleteMapElement(LSB())
	  EndIf
	  
	  ProcedureReturn #False
  EndProcedure
  
  ; ------------------------------------------------------------------------------------
  
  Procedure.i EmbedFile(ID.i, File.s)              ; returns still available space
    Define.s FileName
    Define   FileID.i, Size.q
    Define   Memory.Memory_Structure
    Define   *File
    
    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Read : ProcedureReturn #False : EndIf
      
      FileName = GetFilePart(File)
      
      If AddMapElement(LSB()\Item(), FileName)

        FileID = ReadFile(#PB_Any, File)
        If FileID
          
          Size = Lof(FileID)
          
          *File = AllocateMemory(Size)
          If *File
            
            If ReadData(FileID, *File, Size)
              
              CloseFile(FileID)
              
              Size = Embed_(*File, Size, @Memory) 
              
              LSB()\Item()\Buffer     = Memory\Buffer
              LSB()\Item()\Size       = Memory\Size
              LSB()\Item()\Compressed = Memory\Compressed
              
              LSB()\UsedSize + Size

            EndIf
            
            FreeMemory(*File)
          EndIf

          ProcedureReturn LSB()\EmbedSize - LSB()\UsedSize
        EndIf  

        DeleteMapElement(LSB()\Item())
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i ExtractFile(ID.i, File.s="")         ; returns number of files
    Define.i FileID, Count
    Define.s FileName
    Define   Memory.Memory_Structure
    
    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Write : ProcedureReturn #False : EndIf
      
      FileName = GetFilePart(File)
      
      If File
        
        If FindMapElement(LSB()\Item(), FileName)
      
          If Extract_(@Memory, LSB()\Item()\OffSet)
            FileID = CreateFile(#PB_Any, File)
            If FileID
              WriteData(FileID, Memory\Buffer, Memory\Size)
              Count = 1
              CloseFile(FileID)
            EndIf
            FreeMemory(Memory\Buffer)
          EndIf
          
        EndIf 
        
      Else
        
        ForEach LSB()\Item()
          
          If Extract_(@Memory, LSB()\Item()\OffSet)
            FileID = CreateFile(#PB_Any, MapKey(LSB()\Item()))
            If FileID
              WriteData(FileID, Memory\Buffer, Memory\Size)
              Count + 1
              CloseFile(FileID)
            EndIf 
          EndIf 
          
        Next
        
      EndIf
      
    EndIf
    
    ProcedureReturn Count
  EndProcedure
  
  
  Procedure.i EmbedXML(ID.i, XML.i, Label.s)       ; returns still available space
    Define.i Size
    Define   Memory.Memory_Structure
    Define   *XML
    
    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Read : ProcedureReturn #False : EndIf
      
      If IsXML(XML)
        
        If AddMapElement(LSB()\Item(), Label)
          
          Size = ExportXMLSize(XML)
          If Size
            
            *XML = AllocateMemory(Size)
            If *XML
              
              If ExportXML(XML, *XML, Size)
                
                Size = Embed_(*XML, Size, @Memory) 
                
                LSB()\Item()\Buffer     = Memory\Buffer
                LSB()\Item()\Size       = Memory\Size
                LSB()\Item()\Compressed = Memory\Compressed
                
                LSB()\UsedSize + Size
              
              EndIf
              
              FreeMemory(*XML)
            EndIf
            
            ProcedureReturn LSB()\EmbedSize - LSB()\UsedSize
          EndIf
          
          DeleteMapElement(LSB()\Item())
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.i ExtractXML(ID.i, XML.i, Label.s)     ; returns result of CatchXML()
    Define.i Result
    Define   Memory.Memory_Structure

    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Write : ProcedureReturn #False : EndIf
      
      If FindMapElement(LSB()\Item(), Label)
        
        If Extract_(@Memory, LSB()\Item()\OffSet)
          Result = CatchXML(XML, Memory\Buffer, Memory\Size)
          FreeMemory(Memory\Buffer)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i EmbedJSON(ID.i, JSON.i, Label.s)     ; returns still available space
    Define.i Image, Size
    Define   Memory.Memory_Structure
    Define   *JSON
    
    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Read : ProcedureReturn #False : EndIf
      
      If IsJSON(JSON)
        
        If AddMapElement(LSB()\Item(), Label)
          
          Size = ExportJSONSize(JSON)
          If Size
            
            *JSON = AllocateMemory(Size)
            If *JSON
              
              If ExportJSON(JSON, *JSON, Size)
                
                Size = Embed_(*JSON, Size, @Memory) 
                
                LSB()\Item()\Buffer     = Memory\Buffer
                LSB()\Item()\Size       = Memory\Size
                LSB()\Item()\Compressed = Memory\Compressed
                
                LSB()\UsedSize + Size
              
              EndIf
              
              FreeMemory(*JSON)
            EndIf
            
            ProcedureReturn LSB()\EmbedSize - LSB()\UsedSize
          EndIf
          
          DeleteMapElement(LSB()\Item())
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.i ExtractJSON(ID.i, JSON.i, Label.s)   ; returns result of CatchJSON()
    Define.i Result
    Define   Memory.Memory_Structure

    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Write : ProcedureReturn #False : EndIf
      
      If FindMapElement(LSB()\Item(), Label)
        
        If Extract_(@Memory, LSB()\Item()\OffSet)
          Result = CatchJSON(JSON, Memory\Buffer, Memory\Size)
          FreeMemory(Memory\Buffer)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i EmbedString(ID.i, String.s, Label.s) ; returns still available space
    Define.i Image, Size
    Define   Memory.Memory_Structure
    Define   *String
    
    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Read : ProcedureReturn #False : EndIf
      
      If String
        
        If AddMapElement(LSB()\Item(), Label)
           
          Size = StringByteLength(String)
          If Size
            
            *String = AllocateMemory(Size)
            If *String
              
              CopyMemory(@String, *String, Size)
             
              Size = Embed_(*String, Size, @Memory) 
              
              LSB()\Item()\Buffer     = Memory\Buffer
              LSB()\Item()\Size       = Memory\Size
              LSB()\Item()\Compressed = Memory\Compressed
              
              LSB()\UsedSize + Size
              
              FreeMemory(*String)
            EndIf
            
            ProcedureReturn LSB()\EmbedSize - LSB()\UsedSize
          EndIf
          
          DeleteMapElement(LSB()\Item())
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.s ExtractString(ID.i, Label.s)         ; returns string
    Define.s String
    Define   Memory.Memory_Structure

    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Write : ProcedureReturn "" : EndIf
      
      If FindMapElement(LSB()\Item(), Label)
        
        If Extract_(@Memory, LSB()\Item()\OffSet)
          String = Space(Memory\Size / SizeOf(character))
          CopyMemory(Memory\Buffer, @String, Memory\Size)
          FreeMemory(Memory\Buffer)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn String
  EndProcedure
  
  ; ------------------------------------------------------------------------------------
  
  Procedure.i Save(ID.i, ImageFile.s="")
    Define.i JSON, jObject, jFile, jSize, jMember, Result
    Define.q Size
    Define   Memory.Memory_Structure
    Define   *Buffer, *Pointer
    
    If FindMapElement(LSB(), Str(ID))
      
      If LSB()\Mode = #Read : ProcedureReturn #False : EndIf
      
      If ImageFile = "" : ImageFile = LSB()\FileName : EndIf
      
      If LSB()\KeyCard ;{ Create KeyCard
        
        CompilerIf #Enable_KeyCard
          
          DrawKeyCard_()
          
          JSON = CreateJSON(#PB_Any)
          If JSON
            jObject = SetJSONObject(JSONValue(JSON))
            SetJSONString(AddJSONMember(jObject, "KeyCode"), LSB()\Card\Key)
            jMember = SetJSONObject(AddJSONMember(jObject, "Entries"))
            ForEach LSB()\Card\Entry()
              SetJSONString(AddJSONMember(jMember, MapKey(LSB()\Card\Entry())), LSB()\Card\Entry())
            Next
            FreeJSON(JSON)
          EndIf
          
          CompressJSON_(JSON, @Memory)
    
          WriteLSB_(Memory\Buffer, Memory\Size, 1)
          
        CompilerEndIf
        ;}
      Else             ;{ Embed Files  
      
        JSON = CreateJSON(#PB_Any)
        If JSON
          
          jObject = SetJSONObject(JSONValue(JSON))
          
          jFile = SetJSONArray(AddJSONMember(jObject, "F"))
          jSize = SetJSONArray(AddJSONMember(jObject, "S"))
          
          ForEach LSB()\Item()
            SetJSONString(AddJSONElement(jFile), MapKey(LSB()\Item()))
            SetJSONQuad(AddJSONElement(jSize), LSB()\Item()\Compressed)
            Size + LSB()\Item()\Compressed
          Next
          
          If Size
          
            CompressJSON_(JSON, @Memory)
    
            WriteLSB_(Memory\Buffer, Memory\Size, 2)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              *Pointer = *Buffer
              
              ForEach LSB()\Item()
                If LSB()\Item()\Buffer
                  CopyMemory(LSB()\Item()\Buffer, *Pointer, LSB()\Item()\Compressed)
                  FreeMemory(LSB()\Item()\Buffer)
                  *Pointer + LSB()\Item()\Compressed
                EndIf
              Next  
              
              WriteLSB_(*Buffer, Size)
              
              FreeMemory(*Buffer)
            EndIf
            
          EndIf
          
          FreeJSON(JSON)
        EndIf
        ;}
      EndIf
      
      Result = SaveImage(LSB()\Image, ImageFile, LSB()\Plugin)
      If Result : ClearMap(LSB()\Item()) : EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure   Close(ID.i)
    
    If FindMapElement(LSB(), Str(ID))
      FreeImage(LSB()\Image)
      DeleteMapElement(LSB())
    EndIf   
    
  EndProcedure  
  
  ; ------------------------------------------------------------------------------------
  
  Procedure.i GetSpace(ID.i, Type.i=#Available)
    
    If FindMapElement(LSB(), Str(ID))
      
      Select Type
        Case #Image
          ProcedureReturn LSB()\EmbedSize
        Case #Available
          ProcedureReturn LSB()\EmbedSize - LSB()\UsedSize
        Case #Used
          ProcedureReturn LSB()\UsedSize
      EndSelect
      
    EndIf
    
  EndProcedure
  
  ; ------------------------------------------------------------------------------------
  
  CompilerIf #Enable_KeyCard
    
    Procedure.i KeyCard(ID.i, KeyCode.s) ; Label: "KeyCode" 
      
      If FindMapElement(LSB(), Str(ID))
        
        LSB()\KeyCard    = #True
        LSB()\Card\Key   = KeyCode
        LSB()\Card\Margin\Left   = 10
        LSB()\Card\Margin\Top    = 10
        LSB()\Card\Margin\Bottom = 10
        LSB()\Card\Margin\Right  = 10
        
        ProcedureReturn #True
      EndIf  
      
    EndProcedure
    
    Procedure   AddCardText(ID.i, Text.s, FontNum.i, Color.i=$000000, Flags.i=#False)
      
      If FindMapElement(LSB(), Str(ID))
        
        If AddElement(LSB()\Card\Item())
          
          LSB()\Card\Item()\Text  = Text
          LSB()\Card\Item()\Color = Color
          LSB()\Card\Item()\Font  = FontNum
          LSB()\Card\Item()\Flags = Flags
          
          ProcedureReturn #True
        EndIf  
        
      EndIf  
      
    EndProcedure
    
    Procedure   AddCardInfo(ID.i, Label.s, Value.s)
      
      If FindMapElement(LSB(), Str(ID))
        
        LSB()\Card\Entry(Label) = Value
        
        ProcedureReturn #True
      EndIf 
      
    EndProcedure
    
  CompilerEndIf
 
EndModule

;- =======  Example =======

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 6
  
  ; 1: Embed files
  ; 2: Extract files
  ; 3: XML
  ; 4: JSON
  ; 5: String
  
  UsePNGImageDecoder()
  UsePNGImageEncoder()
  
  #LSB  = 1
  #Font = 1
  
  Key$ = "18P07W67"
  
  Select #Example
    Case 1 ;{ embed files

      If LSB::Create(#LSB, "Test.png", Key$)
        LSB::EmbedFile(#LSB, "Test.txt")
        LSB::EmbedFile(#LSB, "Test.xml")
        LSB::Save(#LSB, "LSB.png")
        LSB::Close(#LSB)
      EndIf 
      ;}
    Case 2 ;{ extract files
      
      If LSB::Open(#LSB, "LSB.png", Key$)
        LSB::ExtractFile(#LSB, "") 
        LSB::Close(#LSB)
      EndIf
      ;}
    Case 3 ;{ XML
      
      #XML = 1

      NewList Shapes$()
      AddElement(Shapes$()): Shapes$() = "square"
      AddElement(Shapes$()): Shapes$() = "circle"
      AddElement(Shapes$()): Shapes$() = "triangle"
     
      If CreateXML(#XML)
        InsertXMLList(RootXMLNode(#XML), Shapes$())
        
        If LSB::Create(#LSB, "Test.png", Key$)
          LSB::EmbedXML(#LSB, #XML, "Shapes")
          LSB::Save(#LSB, "LSB.png")
          LSB::Close(#LSB)
        EndIf  
        
        FreeXML(#XML)
      EndIf
      
      If LSB::Open(#LSB, "LSB.png", Key$)
        If LSB::ExtractXML(#LSB, #XML, "Shapes")
          FormatXML(#XML, #PB_XML_ReFormat)
          Debug ComposeXML(#XML)
          FreeXML(#XML)
        EndIf
        LSB::Close(#LSB)
      EndIf
      ;}
    Case 4 ;{ JSON
      
      #JSON = 1
 
      If CreateJSON(#JSON)
        Person.i = SetJSONObject(JSONValue(#JSON))
        SetJSONString(AddJSONMember(Person, "FirstName"), "John")
        SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
        SetJSONInteger(AddJSONMember(Person, "Age"), 42)
        
        If LSB::Create(#LSB, "Test.png", Key$)
          LSB::EmbedJSON(#LSB, #JSON, "Person")
          LSB::Save(#LSB, "LSB.png")
          LSB::Close(#LSB)
        EndIf
        
        FreeJSON(#JSON)
      EndIf
      
      If LSB::Open(#LSB, "LSB.png", Key$)
        If LSB::ExtractJSON(#LSB, #JSON, "Person")
          Debug ComposeJSON(#JSON)
          FreeJSON(#JSON)
        EndIf
        LSB::Close(#LSB)
      EndIf
      ;}
    Case 5 ;{ String
      
      String$ = "Least Significant Bit Embedding (LSB) is a general steganographic technique."
      
      If LSB::Create(#LSB, "Test.png", Key$)
        LSB::EmbedString(#LSB, String$, "LSB")
        LSB::Save(#LSB, "LSB.png")
        LSB::Close(#LSB)
      EndIf
      
      If LSB::Open(#LSB, "LSB.png", Key$)
        Debug LSB::ExtractString(#LSB, "LSB")
        LSB::Close(#LSB)
      EndIf
      ;}
    Case 6 ;{ KeyCard  
      CompilerIf LSB::#Enable_KeyCard
        
        LoadFont(#Font, "Arial", 16)
        
        If LSB::Create(#LSB, "Test.png", Key$)
          If LSB::KeyCard(#LSB, "T8690352CJ2P1")
            LSB::AddCardText(#LSB, "Thorsten Hoeppner", #Font, 0, LSB::#Center)
          EndIf  
          LSB::Save(#LSB, "LSB.png")
          LSB::Close(#LSB)
        EndIf 
        
      CompilerEndIf  
      ;}
  EndSelect
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 60
; FirstLine = 4
; Folding = 9A5BCBABBg
; Markers = 92,945
; EnableXP
; DPIAware