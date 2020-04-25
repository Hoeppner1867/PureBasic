;/ ==========================
;/ =    UseAPNGodule.pbi    =
;/ ==========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Animated PNG - Module
;/
;/ © 2020  by Thorsten Hoeppner (04/2020)
;/

; Last Update: 25.04.2020
;
; Added: PNG::Save()
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

;{ ===== Tea & Pizza Ware =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ APNG - Commands _____

; PNG::Load()              ; comparable with 'LoadImage()'
; PNG::Save()              ; comparable with 'SaveImage()', but with all frames

; PNG::FrameCount()        ; comparable with 'ImageFrameCount()'
; PNG::FrameID()           ; comparable with 'ImageID()', but for the current Frame of the image

; PNG::GetFrame()          ; comparable with 'GetImageFrame()'
; PNG::GetFrameDelay()     ; comparable with 'GetImageFrameDelay()'
; PNG::GetFrameWidth()     ; comparable with 'ImageWidth'
; PNG::GetFrameHeight()    ; comparable with 'ImageHeight'
; PNG::GetFrameAttribute() ; [#OffsetX/#OffSetY/#Dispos/#Blend/#DelayNum/#DelayDen]

; PNG::LoopCount()         ; returns number of times to loop OR 0 for infinite loop

; PNG::SetFrame()          ; comparable with 'SetImageFrame()'

;}

DeclareModule PNG
  
  ;- ===========================================================================
	;-   DeclareModule - Constants
  ;- ===========================================================================
  
  ; ___ Frame Attribute ___
  
  Enumeration 1
    #OffsetX  ; Offset X
    #OffSetY  ; Offset Y
    #Dispos   ; Dispose output buffer
    #Blend    ; Alpha blend into output buffer
    #DelayNum ; Frame delay fraction numerator   (0: as quickly as possible)
    #DelayDen ; Frame delay fraction denominator (0: 1/100ths of a second)
  EndEnumeration  
  
  ; ___ Dispose output buffer (end of delay) ___
  
  #APNG_Dispos_OP_None       = 0 ; No disposal is done on this frame before rendering the next (contents of the output buffer are left as is)
  #APNG_Dispos_OP_Background = 1 ; Frame's region of the output buffer is to be cleared to fully transparent black before rendering the next frame
  #APNG_Dispos_OP_Previous   = 2 ; Frame's region of the output buffer is to be reverted to the previous contents before rendering the next frame
  
  ; ___ Is the Frame to be alpha blended  into the curret output buffer content ___
  
  #APNG_Blend_OP_Source      = 0 ; All color components of the frame, including alpha, overwrite the current contents of the frame's output buffer region
  #APNG_Blend_OP_Over        = 1 ; The frame should be composited onto the output buffer based on its alpha

  ;- ======================================================
	;-   DeclareModule
	;- ======================================================
  
  Declare.i AddFrames(ImageNum.i)
  
  Declare.i Load(ImageNum.i, File.s, Flags.i=#False) 
  
  Declare.i FrameCount(ImageNum.i)
  Declare.i FrameID(ImageNum.i, Index.i=#PB_Default) 
  
  Declare.i GetFrame(ImageNum.i)
  Declare.i GetFrameDelay(ImageNum.i, Index.i=#PB_Default)
  Declare.i GetFrameWidth(ImageNum.i, Index.i=#PB_Default)
  Declare.i GetFrameHeight(ImageNum.i, Index.i=#PB_Default)
  Declare.i GetFrameAttribute(ImageNum.i, Attribute.i, Index.i=#PB_Default)

  Declare.i LoopCount(ImageNum.i)
  
  Declare   Save(ImageNum.i, File.s)
  
  Declare   SetFrame(ImageNum.i, Index.i)
  
EndDeclareModule

Module PNG

  EnableExplicit
  
  UsePNGImageEncoder()
  UseCRC32Fingerprint()
  
	;- ======================================================
	;-   Module - Constants
	;- ======================================================
  
  #Timer = 67
  
  #PNG$    = "89504E470D0A1A0A"
  #JPEG$   = "FFD8FF"
  #BMP$    = "424D"
  #GIF87a$ = "474946383761"
  #GIF89a$ = "474946383961"
  #ICO$    = "00000100"
  #ICNS$   = "69636E73"
  
  ; ___ Bytes ___
  
  #BlockHeader =  8
	#Signature   =  8
	#Sequence    =  4
	#CRC         =  4
  #IEND        = 12
  
	;- ======================================================
	;-   Module - Structures
	;- ======================================================
  
  Structure fdAT_Structure  ;{ *aPNG\Frame\fdAT\...
    Index.i    ; 00: Sequence number of animation chunk starting from 0 (unsigned int)
    *Pointer   ; 04: Frame data
    Size.i
  EndStructure ;}
  
  Structure fcTL_Structure  ;{ *aPNG\Frame\fcTL\...
    Index.i    ; 00: Sequence number starting form 0  (unsigned int)
    Width.i    ; 04: Width of frame  > 0              (unsigned int)
    Height.i   ; 08: Height of frame > 0              (unsigned int)
    OffsetX.i  ; 12: X position to render >= 0        (unsigned int)
    ; OffsetX + Width  <= 'IHDR' WidthAPNG_BLEND_OP_OVER
    OffsetY.i  ; 16: Y position to render >= 0        (unsigned int)
    ; OffsetY + Height <= 'IHDR' Height
    DelayNum.i ; 20: Frame delay fraction numerator   (unsigned short)
    DelayDen.i ; 22: Frame delay fraction denominator (unsigned short)
    Dispose.b  ; 24: Type of frame area disposal to be done after rendering (Byte)
    ; Dispose: 0 = APNG_DISPOSE_OP_NONE / 1 = APNG_DISPOSE_OP_BACKGROUND / 2 = APNG_DISPOSE_OP_PREVIOUS
    Blend.b    ; 25: Type of frame area rendering for this frame            (Byte)
    ; Blend:   0 = APNG_BLEND_OP_SOURCE / 1 = APNG_BLEND_OP_OVER
  EndStructure ;}
  
  Structure StreamPNG_Frame_Structure ;{ *aPNG\Frame\...
    Image.i
    fcTL.fcTL_Structure
    List fdAT.fdAT_Structure()
  EndStructure ;}
  
  
  Structure acTL_Structure  ;{ *aPNG\acTL\...
    Frames.i ; 00: Number of frames (unsigned int)
    Loops.i  ; 04: Number of times to loop or 0 for infinite looping (unsigned int)
  EndStructure ;}
  
  Structure IHDR_Structure  ;{ *aPNG\IHDR\...
    *Pointer
    Size.i
    Width.q
    Height.q
    ColorSpace.w
    BitDepth.w
    Compression.w
    Prediktor.w
    Interlacing.w
  EndStructure ;}
  
  Structure PLTE_Structure  ;{ *aPNG\PLTE\...
    *Pointer
    Size.i
  EndStructure ;}
  
  Structure IEND_Structrue  ;{ *aPNG\IEND\... 
    *Pointer
    Size.i
  EndStructure ;}
  
  Structure IDAT_Structure  ;{ *aPNG\IDAT\...
    *Pointer
    Size.i
  EndStructure ;}  
  
  Structure StreamPNG_Structure ;{ *aPNG\...
    Signature.s
    Header.i
    IHDR.IHDR_Structure
    PLTE.PLTE_Structure
    IEND.IEND_Structrue
    acTL.acTL_Structure
    List IDAT.IDAT_Structure()
    List Frame.StreamPNG_Frame_Structure()
  EndStructure ;}
  
  
  Structure Image_Frame_Structure ;{ Image()\Frame()\...
    ImageNum.i
    OffsetX.i
    OffsetY.i
    Width.i
    Height.i
    Delay.i     ; Delay in milliseconds
    Delay_Num.i ; Specify together with 'Delay_Den' a fraction indicating the time to display the current frame, in seconds (fraction numerator)
    Delay_Den.i ; Specify together with 'Delay_Num' a fraction indicating the time to display the current frame, in seconds ()
    Dispose.i   ; Specifies how the output buffer should be changed at the end of the delay (before rendering the next frame)
    Blend.i     ; Specifies whether the frame is to be alpha blended into the current output buffer content, or whether it should completely replace its region in the output buffer
  EndStructure ;}
  
  Structure Image_Structure       ;{ Image()\...
    ImageNum.i
    Frames.i
    Loops.i
    List Frame.Image_Frame_Structure()
  EndStructure ;}
  Global NewMap Image.Image_Structure()


  ;- ======================================================
  ;-   Internal
  ;- ======================================================
  
  
  Procedure.q EndianL(val.l)
    ProcedureReturn (val>>24&$FF) | (val>>8&$FF00) | (val<<8&$FF0000) | (val<<24&$FF000000)
  EndProcedure
  
  Procedure.q EndianQ(val.q)
    ProcedureReturn (EndianL(val>>32)&$FFFFFFFF) | (EndianL(val&$FFFFFFFF)<<32)
  EndProcedure
  
  
  Procedure.w uint8(Value.b)
    ProcedureReturn Value & $FF
  EndProcedure
  
  Procedure.i uint16(Value.w, BigEndian.i=#True)
  
    If BigEndian
      ProcedureReturn (Value>>8&$FF) | (Value<<8&$FF00)
    Else
      ProcedureReturn Value & $FFFF
    EndIf
    
  EndProcedure
  
  Procedure.q uint32(Value.i, BigEndian.i=#True)
  
    If BigEndian
      ProcedureReturn (Value>>24&$FF) | (Value>>8&$FF00) | (Value<<8&$FF0000) | (Value<<24&$FF000000)
    Else
      ProcedureReturn Value & $FFFFFFFF
    EndIf
    
  EndProcedure

  Procedure   IDAT_(*Memory, Size.i, List IDAT.IDAT_Structure())
    Define.i BlockLen
    Define.s BlockTyp
    Define *MemPtr
    
    If *Memory

      *MemPtr = *Memory + #Signature

      Repeat
        
        BlockLen = uint32(PeekL(*MemPtr))
        BlockTyp = PeekS(*MemPtr + 4, 4, #PB_Ascii)
        
        Select BlockTyp
          Case  "IDAT"
            If AddElement(IDAT())
              IDAT()\Pointer = *MemPtr
              IDAT()\Size    = BlockLen
            EndIf 
          Case "IEND"
            Break
        EndSelect
       
        *MemPtr + BlockLen + #BlockHeader + #CRC

      Until *MemPtr >= *Memory + Size

    EndIf
    
    ProcedureReturn ListSize(IDAT())
  EndProcedure 
  
  Procedure   PokeBlockType(*Pointer, Type.s)
    Define.i c
    
    For c=0 To 3
      PokeB(*Pointer + c, Asc(Mid(Type, c + 1, 1)))
    Next
    
  EndProcedure
  
  Procedure.s AnalyzeStream_(*Stream, Size.i, *aPNG.StreamPNG_Structure)
    Define.i BlockSize, Index 
    Define.s BlockTyp$
    Define   *Pointer
    
    If *Stream

      *Pointer = *Stream
      
      *aPNG\Signature = Hex(EndianQ(PeekQ(*Pointer)), #PB_Quad)
      
      If *aPNG\Signature = #PNG$
      
        *Pointer + #Signature
        
        Repeat
          
          BlockSize = uint32(PeekL(*Pointer))
          
          *Pointer + 4
          
          BlockTyp$ = PeekS(*Pointer, 4, #PB_Ascii)
          
          *Pointer + 4
          
          Select BlockTyp$
            Case "IHDR" ;{ IHDR
              *aPNG\IHDR\Pointer     = *Pointer - #BlockHeader
              *aPNG\IHDR\Width       = uint32(PeekL(*Pointer))
              *aPNG\IHDR\Height      = uint32(PeekL(*Pointer + 4))
              *aPNG\IHDR\BitDepth    = uint8(PeekB(*Pointer  + 8))
              *aPNG\IHDR\ColorSpace  = uint8(PeekB(*Pointer  + 9))
              *aPNG\IHDR\Compression = uint8(PeekB(*Pointer  + 10))
              *aPNG\IHDR\Prediktor   = uint8(PeekB(*Pointer  + 11))
              *aPNG\IHDR\Interlacing = uint8(PeekB(*Pointer  + 12))
              *aPNG\IHDR\Size        = BlockSize + #BlockHeader + #CRC
              ;}
            Case "PLTE" ;{ PLTE
              *aPNG\PLTE\Pointer = *Pointer  - #BlockHeader
              *aPNG\PLTE\Size    = BlockSize + #BlockHeader + #CRC
              ;}
            Case "IDAT" ;{ IDAT
              
              If AddElement(*aPNG\IDAT())
                *aPNG\IDAT()\Pointer = *Pointer  - #BlockHeader
                *aPNG\IDAT()\Size    = BlockSize + #BlockHeader + #CRC
              EndIf
              
              If ListIndex(*aPNG\Frame()) <> -1
                If AddElement(*aPNG\Frame()\fdAT())
                  *aPNG\Frame()\fdAT()\Index   = 0
                  *aPNG\Frame()\fdAT()\Pointer = *Pointer         ; OffSet 08: only BlockData
                  *aPNG\Frame()\fdAT()\Size    = BlockSize + #CRC
                EndIf
              EndIf
              ;}
            Case "IEND" ;{ IEND
              
              *aPNG\IEND\Pointer = *Pointer - #BlockHeader
              *aPNG\IEND\Size    = #IEND
              ;}
            Case "acTL" ;{ acTL
              *aPNG\acTL\Frames = uint32(PeekL(*Pointer))     ; OffSet 00: Number of frames
              *aPNG\acTL\Loops  = uint32(PeekL(*Pointer + 4)) ; Offset 04: Number of times to loop
              ;}
            Case "fcTL" ;{ fcTL (-> new Frame)
              If AddElement(*aPNG\Frame())
                *aPNG\Frame()\fcTL\Index    = uint32(PeekL(*Pointer))
                *aPNG\Frame()\fcTL\Width    = uint32(PeekL(*Pointer +  4))
                *aPNG\Frame()\fcTL\Height   = uint32(PeekL(*Pointer +  8))
                *aPNG\Frame()\fcTL\OffsetX  = uint32(PeekL(*Pointer + 12))
                *aPNG\Frame()\fcTL\OffsetY  = uint32(PeekL(*Pointer + 16))
                *aPNG\Frame()\fcTL\DelayNum = uint16(PeekW(*Pointer + 20)) 
                *aPNG\Frame()\fcTL\DelayDen = uint16(PeekW(*Pointer + 22)) 
                *aPNG\Frame()\fcTL\Dispose  = uint8(PeekB(*Pointer  + 24))
                *aPNG\Frame()\fcTL\Blend    = uint8(PeekB(*Pointer  + 25))
              EndIf 
              ;}
            Case "fdAT" ;{ fdAT
              If ListIndex(*aPNG\Frame()) <> -1
                If AddElement(*aPNG\Frame()\fdAT())
                  *aPNG\Frame()\fdAT()\Index   = uint32(PeekL(*Pointer))
                  *aPNG\Frame()\fdAT()\Pointer = *Pointer + 4 ; OffSet 12: BlockData without sequence number 
                  *aPNG\Frame()\fdAT()\Size    = BlockSize
                EndIf 
              EndIf 
              ;}
          EndSelect
          
          *Pointer + BlockSize + #CRC
          
        Until *Pointer >= *Stream + Size
  
      EndIf
      
    EndIf
    
    ProcedureReturn *aPNG\Signature
  EndProcedure 
  
  Procedure.i LoadFrames_(*Stream, *aPNG.StreamPNG_Structure)
    Define.i FrameSize, Frame
    Define.s CRC
    Define  *Frame, *Pointer
    
    ForEach *aPNG\Frame()

      FrameSize = #Signature + *aPNG\IHDR\Size + #IEND
      ForEach *aPNG\Frame()\fdAT() : FrameSize + *aPNG\Frame()\fdAT()\Size + 8 : Next
      
      *Frame = AllocateMemory(FrameSize)
      If *Frame
        
        *Pointer = *Frame
        
        CopyMemory(*Stream, *Pointer, #Signature)
        *Pointer + #Signature
        
        ;{ IHDR
        CopyMemory(*aPNG\IHDR\Pointer, *Pointer, 8)
        
        PokeL(*Pointer +  8, uint32(*aPNG\Frame()\fcTL\Width))
        PokeL(*Pointer + 12, uint32(*aPNG\Frame()\fcTL\Height))
        
        CopyMemory(*aPNG\IHDR\Pointer + 16, *Pointer + 16, 5)
        
        CRC = Fingerprint(*Pointer + 4, 17, #PB_Cipher_CRC32)
        PokeL(*Pointer + 21, uint32(Val("$" + CRC)))
        *Pointer + *aPNG\IHDR\Size
        ;}
        
        ;{ IDAT
        ForEach *aPNG\Frame()\fdAT()
         
          PokeL(*Pointer, uint32(*aPNG\Frame()\fdAT()\Size - 4)) ; 00
          PokeB(*Pointer + 4, $49) ; 04
          PokeB(*Pointer + 5, $44) ; 05
          PokeB(*Pointer + 6, $41) ; 06
          PokeB(*Pointer + 7, $54) ; 07
          *Pointer + 8
          
          CopyMemory(*aPNG\Frame()\fdAT()\Pointer, *Pointer, *aPNG\Frame()\fdAT()\Size - 4) ; 08: BlockSize + CRC
          
          CRC = Fingerprint(*Pointer - 4, *aPNG\Frame()\fdAT()\Size, #PB_Cipher_CRC32)
          PokeL(*Pointer + *aPNG\Frame()\fdAT()\Size - 4, uint32(Val("$" + CRC)))
         
          *Pointer + *aPNG\Frame()\fdAT()\Size
        Next ;}
        
        CopyMemory(*aPNG\IEND\Pointer, *Pointer, *aPNG\IEND\Size)
        
        If AddElement(Image()\Frame())
          
          Image()\Frame()\ImageNum  = CatchImage(#PB_Any, *Frame, FrameSize)
          Image()\Frame()\OffsetX   = *aPNG\Frame()\fcTL\OffsetX
          Image()\Frame()\OffsetY   = *aPNG\Frame()\fcTL\OffsetY
          Image()\Frame()\Width     = *aPNG\Frame()\fcTL\Width
          Image()\Frame()\Delay_Num = *aPNG\Frame()\fcTL\DelayNum
          Image()\Frame()\Delay_Den = *aPNG\Frame()\fcTL\DelayDen
          Image()\Frame()\Height    = *aPNG\Frame()\fcTL\Height
          Image()\Frame()\Dispose   = *aPNG\Frame()\fcTL\Dispose
          
          If Image()\Frame()\Delay_Num  = 0
            Image()\Frame()\Delay = 0
          ElseIf Image()\Frame()\Delay_Den = 0
            Image()\Frame()\Delay = (1000 * Image()\Frame()\Delay_Num) / 100
          Else
            Image()\Frame()\Delay = (1000 * Image()\Frame()\Delay_Num) / Image()\Frame()\Delay_Den
          EndIf

        EndIf
      
        FreeMemory(*Frame)
      EndIf
      
    Next
    
    ProcedureReturn Frame
  EndProcedure
  
  ;- ======================================================
	;-   Module - Declared Procedures
	;- ======================================================
  
  Procedure.i AddFrames(ImageNum.i)

    If FindMapElement(Image(), Str(ImageNum))
      
      PushListPosition(Image()\Frame())
      
      ForEach Image()\Frame()
        
        If AddImageFrame(ImageNum)

          If StartDrawing(ImageOutput(ImageNum))
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            DrawAlphaImage(ImageID(Image()\Frame()\ImageNum), Image()\Frame()\OffsetX, Image()\Frame()\OffsetY)
            StopDrawing()
          EndIf
        
          SetImageFrameDelay(ImageNum, Image()\Frame()\Delay)
          
        EndIf
        
      Next
      
      PopListPosition(Image()\Frame())
      
    EndIf 
    
    ProcedureReturn ImageFrameCount(ImageNum)
  EndProcedure
  
  
  Procedure.i GetFrame(ImageNum.i)
    
    If FindMapElement(Image(), Str(ImageNum))
      ProcedureReturn ListIndex(Image()\Frame())
    EndIf  
    
  EndProcedure
  
  Procedure.i GetFrameDelay(ImageNum.i, Index.i=#PB_Default)
    Define.i Delay
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If Index <> #PB_Default
        
        PushListPosition(Image()\Frame())
        
        If SelectElement(Image()\Frame(), Index)
          Delay = Image()\Frame()\Delay
        EndIf
        
        PopListPosition(Image()\Frame())
        
      Else
        
        If ListIndex(Image()\Frame()) <> -1
          Delay = Image()\Frame()\Delay
        EndIf
        
      EndIf

      ProcedureReturn Delay
    EndIf  
    
  EndProcedure
  
  Procedure.i GetFrameAttribute(ImageNum.i, Attribute.i, Index.i=#PB_Default)
    Define.i Value
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If Index <> #PB_Default
        
        PushListPosition(Image()\Frame())
        
        If SelectElement(Image()\Frame(), Index)
          
          Select Attribute
            Case #OffsetX
              Value = Image()\Frame()\OffsetX
            Case #OffSetY
              Value = Image()\Frame()\OffsetY
            Case #DelayNum
              Value = Image()\Frame()\Delay_Num
            Case #DelayDen
              Value = Image()\Frame()\Delay_Den
            Case #Dispos
              Value = Image()\Frame()\Dispose
            Case #Blend
              Value = Image()\Frame()\Blend
          EndSelect
          
        EndIf
        
        PopListPosition(Image()\Frame())
        
      Else
        
        If ListIndex(Image()\Frame()) <> -1
          
          Select Attribute
            Case #OffsetX
              Value = Image()\Frame()\OffsetX
            Case #OffSetY
              Value = Image()\Frame()\OffsetY
            Case #DelayNum
              Value = Image()\Frame()\Delay_Num
            Case #DelayDen
              Value = Image()\Frame()\Delay_Den
            Case #Dispos
              Value = Image()\Frame()\Dispose
            Case #Blend
              Value = Image()\Frame()\Blend
          EndSelect
          
        EndIf
        
      EndIf
      
      ProcedureReturn Value
    EndIf   
  
  EndProcedure  
  
  Procedure.i GetFrameWidth(ImageNum.i, Index.i=#PB_Default)
    Define.i Width
    
    If FindMapElement(Image(), Str(ImageNum))

      If Index <> #PB_Default
        
        PushListPosition(Image()\Frame())
        
        If SelectElement(Image()\Frame(), Index)
          Width = Image()\Frame()\Width
        EndIf
        
        PopListPosition(Image()\Frame())
        
      Else
        
        If ListIndex(Image()\Frame()) <> -1
          Width = Image()\Frame()\Width
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Width
  EndProcedure
  
  Procedure.i GetFrameHeight(ImageNum.i, Index.i=#PB_Default)
    Define.i Height
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If FindMapElement(Image(), Str(ImageNum))

        If Index <> #PB_Default
          
          PushListPosition(Image()\Frame())
          
          If SelectElement(Image()\Frame(), Index)
            Height = Image()\Frame()\Height
          EndIf
          
          PopListPosition(Image()\Frame())
          
        Else
          
          If ListIndex(Image()\Frame()) <> -1 
            Height = Image()\Frame()\Height
          EndIf
        
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Height
  EndProcedure
  
  
  Procedure.i FrameID(ImageNum.i, Index.i=#PB_Default) 
    Define.i FrameNum
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If FindMapElement(Image(), Str(ImageNum))

        If Index <> #PB_Default
          
          PushListPosition(Image()\Frame())
          
          If SelectElement(Image()\Frame(), Index)
            FrameNum = Image()\Frame()\ImageNum
          EndIf
          
          PopListPosition(Image()\Frame())
          
        Else
          
          If ListIndex(Image()\Frame()) <> -1 
            FrameNum = Image()\Frame()\ImageNum
          EndIf
        
        EndIf
        
      EndIf
      
      If IsImage(FrameNum)
        ProcedureReturn ImageID(FrameNum)
      EndIf
      
    EndIf

    ProcedureReturn #PB_Default
  EndProcedure
  
  Procedure.i FrameCount(ImageNum.i)
    
    If FindMapElement(Image(), Str(ImageNum))
      ProcedureReturn Image()\Frames
    EndIf  
    
  EndProcedure
  
  Procedure.i LoopCount(ImageNum.i)
    ; Number of times to loop OR 0 for infinite loop
    
    If FindMapElement(Image(), Str(ImageNum))
      ProcedureReturn Image()\Loops
    EndIf  
    
  EndProcedure
  
  
  Procedure.i Load(ImageNum.i, File.s, Flags.i=#False)
    Define.i FileNum, FileSize, Result
    Define   *Stream
    Define   ImgData.StreamPNG_Structure
    
    Result = LoadImage(ImageNum, File)
    If ImageNum =#PB_Any : ImageNum = Result  : EndIf
    
    If AddMapElement(Image(), Str(ImageNum))
      
      Image()\ImageNum = ImageNum
      
      FileNum = ReadFile(#PB_Any, File)
      If FileNum
        
        FileSize = Lof(FileNum)
        
        *Stream = AllocateMemory(FileSize)
        If *Stream
          
          If ReadData(FileNum, *Stream, FileSize)
            
            AnalyzeStream_(*Stream, FileSize, @ImgData)
            
            Image()\Frames = ImgData\acTL\Frames
            Image()\Loops  = ImgData\acTL\Loops
            
            LoadFrames_(*Stream, @ImgData)
            
          EndIf
          
          FreeMemory(*Stream)
        EndIf
        
        CloseFile(FileNum)
      EndIf   
      
      FirstElement(Image()\Frame())
      
    EndIf
    
    ProcedureReturn ImageNum
  EndProcedure
  
  Procedure   Save(ImageNum.i, File.s)
    Define.i f, FileNum, Frames, ImageSize, FrameSize
    Define.i BlockSize, Index, Width, Height, Delay, DelayDen
    Define.s CRC
    Define   *Stream, *Frame, *Block
    Define   ImgData.StreamPNG_Structure
    
    NewList Frame.IDAT_Structure()
    
    If IsImage(ImageNum)
      
      Frames = ImageFrameCount(ImageNum)
      Width  = ImageWidth(ImageNum)
      Height = ImageHeight(ImageNum)
      
      *Stream = EncodeImage(ImageNum, #PB_ImagePlugin_PNG)
      If *Stream
        
        ImageSize = MemorySize(*Stream)
        
        AnalyzeStream_(*Stream, ImageSize, @ImgData)

        FileNum = CreateFile(#PB_Any, File)
        If FileNum
          
          WriteData(FileNum, *Stream, #Signature)
          WriteData(FileNum, ImgData\IHDR\Pointer, ImgData\IHDR\Size)
       
          If Frames > 1
            
            SetImageFrame(ImageNum, 0)
            
            ;{ Write acTL: Animation Control Chunk
            BlockSize = 8
            *Block = AllocateMemory(#BlockHeader + BlockSize + #CRC)
            If *Block
              PokeL(*Block, uint32(BlockSize))  ; Block size
              PokeBlockType(*Block + 4, "acTL") ; Block type
              PokeL(*Block + 8, uint32(Frames)) ; Number of frames       (unsigned int)
              PokeL(*Block + 12, 0)             ; 0 for infinite looping (unsigned int)
              WriteData(FileNum, *Block, #BlockHeader + BlockSize)
              CRC = Fingerprint(*Block + 4, BlockSize + 4, #PB_Cipher_CRC32)
              FreeMemory(*Block) 
            EndIf
            
            WriteLong(FileNum, uint32(Val("$" + CRC)))
            ;}
            
            ;{ Write fcTL: Frame Control Chunk
            Delay = GetImageFrameDelay(ImageNum)
            
            If Delay = 0 : Delay = 20 : EndIf 
            DelayDen  = 100
            
            BlockSize = 26
            
            *Block = AllocateMemory(#BlockHeader + BlockSize + #CRC)
            If *Block
              PokeL(*Block, uint32(BlockSize))       ; Block size
              PokeBlockType(*Block + 4, "fcTL")      ; Block type
              PokeL(*Block +  8, uint32(Index))      ; 00: Sequence number starting form 0  (unsigned int)
              PokeL(*Block + 12, uint32(Width))      ; 04: Width of frame  > 0              (unsigned int)
              PokeL(*Block + 16, uint32(Height))     ; 08: Height of frame > 0              (unsigned int)
              PokeL(*Block + 20, uint32(0))          ; 12: X position to render >= 0        (unsigned int)
              PokeL(*Block + 24, uint32(0))          ; 16: Y position to render >= 0        (unsigned int)
              PokeW(*Block + 28, uint16(1))          ; 20: Frame delay fraction numerator   (unsigned short)
              PokeW(*Block + 30, uint16(DelayDen))   ; 22: Frame delay fraction denominator (unsigned short)
              PokeB(*Block + 32, 1)                  ; 24: Type of frame area disposal to be done after rendering (Byte)
              PokeB(*Block + 33, 1)                  ; 25: Type of frame area rendering for this frame            (Byte)
              WriteData(FileNum, *Block, #BlockHeader + BlockSize)
              CRC = Fingerprint(*Block + 4, BlockSize + 4, #PB_Cipher_CRC32)
              FreeMemory(*Block) 
            EndIf
            
            WriteLong(FileNum, uint32(Val("$" + CRC)))
            
            Index + 1
            ;}
         
            ;{ Write IDAT
            ForEach ImgData\IDAT()
              WriteData(FileNum, ImgData\IDAT()\Pointer, ImgData\IDAT()\Size)
            Next  
            ;}
            
            For f=1 To Frames - 1
              
              SetImageFrame(ImageNum, f)
              
              ClearList(Frame())
              
              ;{ Write fcTL: Frame Control Chunk
              Delay = GetImageFrameDelay(ImageNum)
              If Delay = 0 : Delay = 10 : EndIf 
              
              DelayDen = 1000 / Delay
              
              BlockSize = 26
              
              *Block = AllocateMemory(#BlockHeader + BlockSize + #CRC)
              If *Block
                PokeL(*Block, uint32(BlockSize))  ; Block size
                PokeBlockType(*Block + 4, "fcTL") ; Block type
                PokeL(*Block +  8, uint32(Index))      ; 00: Sequence number starting form 0  (unsigned int)
                PokeL(*Block + 12, uint32(Width))      ; 04: Width of frame  > 0              (unsigned int)
                PokeL(*Block + 16, uint32(Height))     ; 08: Height of frame > 0              (unsigned int)
                PokeL(*Block + 20, uint32(0))          ; 12: X position to render >= 0        (unsigned int)
                PokeL(*Block + 24, uint32(0))          ; 16: Y position to render >= 0        (unsigned int)
                PokeW(*Block + 28, uint16(1))          ; 20: Frame delay fraction numerator   (unsigned short)
                PokeW(*Block + 30, uint16(DelayDen))   ; 22: Frame delay fraction denominator (unsigned short)
                PokeB(*Block + 32, 1)                  ; 24: Type of frame area disposal to be done after rendering (Byte)
                PokeB(*Block + 33, 1)                  ; 25: Type of frame area rendering for this frame            (Byte)
                WriteData(FileNum, *Block, #BlockHeader + BlockSize)
                CRC = Fingerprint(*Block + 4, BlockSize + 4, #PB_Cipher_CRC32)
                FreeMemory(*Block) 
              EndIf
              
              WriteLong(FileNum, uint32(Val("$" + CRC)))
              
              Index + 1
              ;}

              ;{ Write fdAT: Frame Data Chunk
              *Frame = EncodeImage(ImageNum, #PB_ImagePlugin_PNG)
              If *Frame

                IDAT_(*Frame, MemorySize(*Frame), Frame())
                
                ForEach Frame()
                  
                  BlockSize = Frame()\Size + 4
                  
                  *Block = AllocateMemory(#BlockHeader + BlockSize)
                  If *Block
                    
                    PokeL(*Block, uint32(BlockSize))  ; 00: Block size
                    
                    PokeBlockType(*Block + 4, "fdAT") ; 04: Block type
                    
                    PokeL(*Block + 8, uint32(Index))  ; 08: Sequence number 
                    
                    CopyMemory(Frame()\Pointer + #BlockHeader, *Block + 12, Frame()\Size)
                    WriteData(FileNum, *Block, #BlockHeader + BlockSize)
                    CRC = Fingerprint(*Block + 4, BlockSize + 4, #PB_Cipher_CRC32)
                    FreeMemory(*Block)
                  EndIf 

                  WriteLong(FileNum, uint32(Val("$" + CRC)))
                  
                  Index + 1
                Next
                
                FreeMemory(*Frame)
              EndIf
              ;}
              
            Next  
          
          EndIf
          
          WriteData(FileNum, ImgData\IEND\Pointer, ImgData\IEND\Size)
          
          CloseFile(FileNum)
        EndIf
        
        FreeMemory(*Stream)
      EndIf
      
    EndIf
    
  EndProcedure
  
 
  Procedure   SetFrame(ImageNum.i, Index.i)
    
    If FindMapElement(Image(), Str(ImageNum))
      ProcedureReturn SelectElement(Image()\Frame(), Index)
    EndIf  
    
  EndProcedure

EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 0
  
  ; 0: internal frames
  ; 1: PNG::AddFrames()
  
  UsePNGImageDecoder()
  
  #File  = 1
  #Image = 1
  #Frame = 2	

  #Window = 1
  #Gadget  = 1
  #Timer   = 1

  File$ = "Elephant.png"
  
  Define.i OffsetX, OffsetY
  
  PNG::Load(#Image, File$)
  PNG::AddFrames(#Image)

  If OpenWindow(#Window, 0, 0, 500, 420, "ImageGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    CanvasGadget(#Gadget, 10, 10, 480, 400)

    AddWindowTimer(#Window, #Timer, 1)

    Frame = 0
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event
        Case #PB_Event_Timer 
          
          If EventTimer() = #Timer
            
            If #Example = 1 ;{ PNG::AddFrames()

              SetImageFrame(#Image, Frame)
              
              RemoveWindowTimer(#Window, #Timer)
              AddWindowTimer(#Window, #Timer, PNG::GetFrameDelay(#Image))
              
              If StartDrawing(CanvasOutput(#Gadget))
                DrawingMode(#PB_2DDrawing_Default)
                Box(0, 0, GadgetWidth(#Gadget), GadgetHeight(#Gadget), $FFFFFF)
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                DrawImage(ImageID(#Image), 0, 0)
                StopDrawing()
              EndIf
              
              Frame + 1
            
              If Frame >= PNG::FrameCount(#Image) : Frame = 0 : EndIf 
              ;}
            Else 
              
              PNG::SetFrame(#Image, Frame)
  
              RemoveWindowTimer(#Window, #Timer)
              AddWindowTimer(#Window, #Timer, PNG::GetFrameDelay(#Image))
              
              If StartDrawing(CanvasOutput(#Gadget))
                DrawingMode(#PB_2DDrawing_Default)
                Box(0, 0, GadgetWidth(#Gadget), GadgetHeight(#Gadget), $FFFFFF)
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                DrawImage(PNG::FrameID(#Image), PNG::GetFrameAttribute(#Image, PNG::#OffsetX), PNG::GetFrameAttribute(#Image, PNG::#OffsetY))
                StopDrawing()
              EndIf
              
              Frame + 1
            
              If Frame >= PNG::FrameCount(#Image) : Frame = 0 : EndIf 
              
            EndIf
            
          EndIf 
          
      EndSelect
      
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf
  
  
CompilerEndIf  
  
 
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 13
; Folding = YAAAAAAEo
; EnableXP
; DPIAware