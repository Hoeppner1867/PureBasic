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

; PNG::AddFrames()         ; comparable with 'AddImageFrame()', but for all frames of the APNG

; PNG::ResetFrames()       ; sets the frame index before the first frame
; PNG::DrawFrame()         ; draws the current frame
; PNG::ScaleFrames()       ; scales the output of the frames

; PNG::Load()              ; comparable with 'LoadImage()'
; PNG::Save()              ; comparable with 'SaveImage()', but with all frames

; PNG::FrameCount()        ; comparable with 'ImageFrameCount()'
; PNG::FrameID()           ; comparable with 'ImageID()', but for the current Frame of the image

; PNG::GetFrame()          ; comparable with 'GetImageFrame()'
; PNG::GetFrameDelay()     ; comparable with 'GetImageFrameDelay()'
; PNG::GetFrameWidth()     ; comparable with 'ImageWidth'
; PNG::GetFrameHeight()    ; comparable with 'ImageHeight'
; PNG::GetFrameAttribute() ; [#OffsetX/#OffSetY/#Dispos/#Blend/#DelayNum/#DelayDen]

; PNG::GetLoop()           ; returns current loop
; PNG::LoopCount()         ; returns number of times to loop OR 0 for infinite loop

; PNG::SetFrame()          ; comparable with 'SetImageFrame()'
; PNG::SetTimer()          ; changes the delay of the timer
  
; PNG::StartTimer()        ; starts the timer to play the frames
; PNG::PauseTimer()        ; pauses or resumes the timer
; PNG::StopTimer()         ; stops the timer

;}

DeclareModule PNG
  
  ;- ===========================================================================
	;-   DeclareModule - Constants
  ;- ===========================================================================
  
  #Timer = $494D47
  
  ; ___ Drawing Output ___
  
  Enumeration 1
    #Window
    #Screen
    #Sprite
    #Image
    #Canvas
  EndEnumeration
  
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
  
  Declare   ResetFrames(ImageNum.i)
  Declare.i DrawFrame(ImageNum.i, OutputID.i, X.i=0, Y.i=0, Index.i=#PB_Default, BackColor.i=#PB_Default) 
  Declare   ScaleFrames(ImageNum.i, FactorX.f, FactorY.f)
  
  Declare.i Load(ImageNum.i, File.s, Flags.i=#False) 
  
  Declare.i FrameCount(ImageNum.i)
  Declare.i FrameID(ImageNum.i, Index.i=#PB_Default) 
  
  Declare.i GetFrame(ImageNum.i)
  Declare.i GetFrameDelay(ImageNum.i, Index.i=#PB_Default)
  Declare.i GetFrameWidth(ImageNum.i, Index.i=#PB_Default)
  Declare.i GetFrameHeight(ImageNum.i, Index.i=#PB_Default)
  Declare.i GetFrameAttribute(ImageNum.i, Attribute.i, Index.i=#PB_Default)
  Declare.i GetLoop(ImageNum.i)
  
  Declare.i LoopCount(ImageNum.i)
  
  Declare   Save(ImageNum.i, File.s)
  
  Declare   SetFrame(ImageNum.i, Index.i)
  Declare   SetTimer(ImageNum.i, Delay.i, Timer.i=#PB_Default)
  
  Declare   StartTimer(ImageNum.i, Window.i, Loops.i=#PB_Default, Timer.i=#PB_Default)
  Declare   PauseTimer(ImageNum.i, Timer.i=#PB_Default)
  Declare   StopTimer(ImageNum.i, Timer.i=#PB_Default)
  
EndDeclareModule

Module PNG

  EnableExplicit
  
  UsePNGImageEncoder()
  UseCRC32Fingerprint()
  
	;- ======================================================
	;-   Module - Constants
	;- ======================================================

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
  
  Structure fdAT_Structure        ;{ *aPNG\Frame\fdAT\...
    Index.i    ; 00: Sequence number of animation chunk starting from 0 (unsigned int)
    *Pointer   ; 04: Frame data
    Size.i
  EndStructure ;}
  
  Structure fcTL_Structure       ;{ *aPNG\Frame\fcTL\...
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
  
  Structure Stream_Frame_Structure ;{ *aPNG\Frame\...
    Image.i
    fcTL.fcTL_Structure
    List fdAT.fdAT_Structure()
  EndStructure ;}
  
  
  Structure acTL_Structure        ;{ *aPNG\acTL\...
    Frames.i ; 00: Number of frames (unsigned int)
    Loops.i  ; 04: Number of times to loop or 0 for infinite looping (unsigned int)
  EndStructure ;}
  
  Structure IHDR_Structure        ;{ *aPNG\IHDR\...
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
  
  Structure Block_Structure        ;{ *aPNG\PLTE\...
    *Pointer
    Size.i
  EndStructure ;}
  
  Structure IEND_Structrue        ;{ *aPNG\IEND\... 
    *Pointer
    Size.i
  EndStructure ;}
  
  Structure IDAT_Structure        ;{ *aPNG\IDAT\...
    *Pointer
    Size.i
  EndStructure ;}  
  
  Structure Stream_Structure      ;{ *aPNG\...
    Signature.s
    Header.i
    IHDR.IHDR_Structure
    cHRM.Block_Structure
    gAMA.Block_Structure
    iCCP.Block_Structure
    sBit.Block_Structure
    sRGB.Block_Structure
    PLTE.Block_Structure
    tRNS.Block_Structure
    hIST.Block_Structure
    bKGD.Block_Structure
    pHYs.Block_Structure
    IEND.IEND_Structrue
    acTL.acTL_Structure
    List sPLT.Block_Structure()
    List IDAT.IDAT_Structure()
    List Frame.Stream_Frame_Structure()
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
  
  
  Structure Previous_Structure    ;{ Image()\PrevImage\...
    Num.i
    X.i
    Y.i
  EndStructure ;}
  
  Structure Image_Structure       ;{ Image()\...
    Num.i
    Frames.i
    Loops.i
    Delay.i
    Timer.i
    ScaleX.f
    ScaleY.f
    Width.i
    Height.i
    CurrentLoop.i
    BackColor.i
    Window.i
    PrevImage.Previous_Structure
    List Frame.Image_Frame_Structure()
  EndStructure ;}
  Global NewMap Image.Image_Structure()


  ;- ======================================================
  ;-   Internal
  ;- ======================================================

  Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
  
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
		; Addition of mk-soft

		Procedure OSX_NSColorToRGBA(NSColor)
			Protected.cgfloat red, green, blue, alpha
			Protected nscolorspace, rgba
			nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
			If nscolorspace
				CocoaMessage(@red, nscolorspace, "redComponent")
				CocoaMessage(@green, nscolorspace, "greenComponent")
				CocoaMessage(@blue, nscolorspace, "blueComponent")
				CocoaMessage(@alpha, nscolorspace, "alphaComponent")
				rgba = RGBA(red * 255.9, green * 255.9, blue * 255.9, alpha * 255.)
				ProcedureReturn rgba
			EndIf
		EndProcedure

		Procedure OSX_NSColorToRGB(NSColor)
			Protected.cgfloat red, green, blue
			Protected r, g, b, a
			Protected nscolorspace, rgb
			nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
			If nscolorspace
				CocoaMessage(@red, nscolorspace, "redComponent")
				CocoaMessage(@green, nscolorspace, "greenComponent")
				CocoaMessage(@blue, nscolorspace, "blueComponent")
				rgb = RGB(red * 255.0, green * 255.0, blue * 255.0)
				ProcedureReturn rgb
			EndIf
		EndProcedure
		
		Procedure OSX_NSColorByNameToRGB(NSColorName.s)
      Protected.cgfloat red, green, blue
      Protected nscolorspace, rgb
      nscolorspace = CocoaMessage(0, CocoaMessage(0, 0, "NSColor " + NSColorName), "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
      If nscolorspace
        CocoaMessage(@red, nscolorspace, "redComponent")
        CocoaMessage(@green, nscolorspace, "greenComponent")
        CocoaMessage(@blue, nscolorspace, "blueComponent")
        rgb = RGB(red * 255.0, green * 255.0, blue * 255.0)
        ProcedureReturn rgb
      EndIf
    EndProcedure
		
		Procedure OSX_GadgetColor()
		  Define.i UserDefaults, NSString
		  
		  UserDefaults = CocoaMessage(0, 0, "NSUserDefaults standardUserDefaults")
      NSString = CocoaMessage(0, UserDefaults, "stringForKey:$", @"AppleInterfaceStyle")
      If NSString And PeekS(CocoaMessage(0, NSString, "UTF8String"), -1, #PB_UTF8) = "Dark"
        ProcedureReturn BlendColor_(OSX_NSColorByNameToRGB("controlBackgroundColor"), #White, 85)
      Else
        ProcedureReturn BlendColor_(OSX_NSColorByNameToRGB("windowBackgroundColor"), #White, 85)
      EndIf 
      
		EndProcedure  
		
	CompilerEndIf
  
  
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
  
  
  Procedure   FilterCallback(X.i, Y.i, sColor.i, tColor.i)
    If sColor = $FF100000 Or sColor = $FF100000
      ProcedureReturn $00000000
    Else
      ProcedureReturn sColor
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
  
  Procedure.s AnalyzeStream_(*Stream, Size.i, *aPNG.Stream_Structure)
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
            Case "sRGB" ;{ sRGB
              *aPNG\sRGB\Pointer = *Pointer  - #BlockHeader
              *aPNG\sRGB\Size    = BlockSize + #BlockHeader + #CRC
              ;}
            Case "iCCP" ;{ iCCP
              *aPNG\iCCP\Pointer = *Pointer  - #BlockHeader
              *aPNG\iCCP\Size    = BlockSize + #BlockHeader + #CRC
              ;}
            Case "gAMA" ;{ gAMA
              *aPNG\gAMA\Pointer = *Pointer  - #BlockHeader
              *aPNG\gAMA\Size    = BlockSize + #BlockHeader + #CRC
              ;}
            Case "cHRM" ;{ cHRM
              *aPNG\cHRM\Pointer = *Pointer  - #BlockHeader
              *aPNG\cHRM\Size    = BlockSize + #BlockHeader + #CRC
              ;}              
            Case "sBit" ;{ sBit
              *aPNG\sBit\Pointer = *Pointer  - #BlockHeader
              *aPNG\sBit\Size    = BlockSize + #BlockHeader + #CRC
              ;}
            Case "PLTE" ;{ PLTE
              *aPNG\PLTE\Pointer = *Pointer  - #BlockHeader
              *aPNG\PLTE\Size    = BlockSize + #BlockHeader + #CRC
            Case "tRNS" 
              *aPNG\tRNS\Pointer = *Pointer  - #BlockHeader
              *aPNG\tRNS\Size    = BlockSize + #BlockHeader + #CRC
            Case "hIST"  
              *aPNG\hIST\Pointer = *Pointer  - #BlockHeader
              *aPNG\hIST\Size    = BlockSize + #BlockHeader + #CRC
            Case "bKGD"   
              *aPNG\bKGD\Pointer = *Pointer  - #BlockHeader
              *aPNG\bKGD\Size    = BlockSize + #BlockHeader + #CRC
              ;}
            Case "pHYs" ;{ pHYs
              *aPNG\pHYs\Pointer = *Pointer  - #BlockHeader
              *aPNG\pHYs\Size    = BlockSize + #BlockHeader + #CRC
              ;}
            Case "sPLT" ;{ sPLT
              If ListIndex(*aPNG\Frame()) <> -1
                If AddElement(*aPNG\sPLT())
                  *aPNG\sPLT()\Pointer = *Pointer  - #BlockHeader
                  *aPNG\sPLT()\Size    = BlockSize + #BlockHeader + #CRC
                EndIf
              EndIf
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
              Break
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
  
  Procedure.i LoadFrames_(*Stream, *aPNG.Stream_Structure)
    Define.i FrameSize, Frame, ColorSpace
    Define.s CRC
    Define  *Frame, *Pointer, *Image
    
    ColorSpace = *aPNG\IHDR\ColorSpace
    
    ForEach *aPNG\Frame()
      
      FrameSize = #Signature + *aPNG\IHDR\Size + #IEND

      If *aPNG\sRGB\Pointer : FrameSize + *aPNG\sRGB\Size : EndIf
      If *aPNG\iCCP\Pointer : FrameSize + *aPNG\iCCP\Size : EndIf
      If *aPNG\gAMA\Pointer : FrameSize + *aPNG\gAMA\Size : EndIf
      If *aPNG\cHRM\Pointer : FrameSize + *aPNG\cHRM\Size : EndIf 
      If *aPNG\sBIT\Pointer : FrameSize + *aPNG\sBIT\Size : EndIf
      If *aPNG\PLTE\Pointer : FrameSize + *aPNG\PLTE\Size : EndIf
      If *aPNG\tRNS\Pointer : FrameSize + *aPNG\tRNS\Size : EndIf
      If *aPNG\hIST\Pointer : FrameSize + *aPNG\hIST\Size : EndIf
      If *aPNG\bKGD\Pointer : FrameSize + *aPNG\bKGD\Size : EndIf
      If *aPNG\pHYs\Pointer : FrameSize + *aPNG\pHYs\Size : EndIf
      
      ForEach *aPNG\sPLT() : FrameSize + *aPNG\sPLT()\Size : Next
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
        
        ;{ other blocks
        If *aPNG\cHRM\Pointer
          CopyMemory(*aPNG\cHRM\Pointer, *Pointer, *aPNG\cHRM\Size)
          *Pointer + *aPNG\cHRM\Size
        EndIf
        
        If *aPNG\gAMA\Pointer
          CopyMemory(*aPNG\gAMA\Pointer, *Pointer, *aPNG\gAMA\Size)
          *Pointer + *aPNG\gAMA\Size
        EndIf
        
        If *aPNG\iCCP\Pointer
          CopyMemory(*aPNG\iCCP\Pointer, *Pointer, *aPNG\iCCP\Size)
          *Pointer + *aPNG\iCCP\Size
        EndIf        
        
        If *aPNG\sRGB\Pointer
          CopyMemory(*aPNG\sRGB\Pointer, *Pointer, *aPNG\sRGB\Size)
          *Pointer + *aPNG\sRGB\Size
        EndIf
        
        If *aPNG\sBIT\Pointer
          CopyMemory(*aPNG\sBIT\Pointer, *Pointer, *aPNG\sBIT\Size)
          *Pointer + *aPNG\sBIT\Size
        EndIf
        ;}
        
        ;{ PLTE
        If *aPNG\PLTE\Pointer
          CopyMemory(*aPNG\PLTE\Pointer, *Pointer, *aPNG\PLTE\Size)
          *Pointer + *aPNG\PLTE\Size
        EndIf
        
        If *aPNG\tRNS\Pointer
          CopyMemory(*aPNG\tRNS\Pointer, *Pointer, *aPNG\tRNS\Size)
          *Pointer + *aPNG\tRNS\Size
        EndIf
        
        If *aPNG\hIST\Pointer
          CopyMemory(*aPNG\hIST\Pointer, *Pointer, *aPNG\hIST\Size)
          *Pointer + *aPNG\hIST\Size
        EndIf
        
        If *aPNG\bKGD\Pointer
          CopyMemory(*aPNG\bKGD\Pointer, *Pointer, *aPNG\bKGD\Size)
          *Pointer + *aPNG\bKGD\Size
        EndIf
        
        If *aPNG\bKGD\Pointer
          CopyMemory(*aPNG\bKGD\Pointer, *Pointer, *aPNG\bKGD\Size)
          *Pointer + *aPNG\bKGD\Size
        EndIf
        ;}
        
        ;{ pHYs
        If *aPNG\pHYs\Pointer
          CopyMemory(*aPNG\pHYs\Pointer, *Pointer, *aPNG\pHYs\Size)
          *Pointer + *aPNG\pHYs\Size
        EndIf ;}
        
        ;{ sPLT
        ForEach *aPNG\sPLT()
          CopyMemory(*aPNG\sPLT()\Pointer, *Pointer, *aPNG\sPLT()\Size)
          *Pointer + *aPNG\sPLT()\Size
        Next ;}
        
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
          
          Image()\Frame()\OffsetX   = *aPNG\Frame()\fcTL\OffsetX
          Image()\Frame()\OffsetY   = *aPNG\Frame()\fcTL\OffsetY
          Image()\Frame()\Width     = *aPNG\Frame()\fcTL\Width
          Image()\Frame()\Height    = *aPNG\Frame()\fcTL\Height
          Image()\Frame()\Delay_Num = *aPNG\Frame()\fcTL\DelayNum
          Image()\Frame()\Delay_Den = *aPNG\Frame()\fcTL\DelayDen
          Image()\Frame()\Dispose   = *aPNG\Frame()\fcTL\Dispose
          Image()\Frame()\Blend     = *aPNG\Frame()\fcTL\Blend

          Image()\Frame()\ImageNum = CatchImage(#PB_Any, *Frame, FrameSize)

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
  
  
  Procedure   SetTimer_(Delay.i, Timer.i)

    If Delay <> Image()\Delay
      
      If IsWindow(Image()\Window)
        RemoveWindowTimer(Image()\Window, Timer)
        AddWindowTimer(Image()\Window, Timer, Image()\Delay)
      EndIf 
      
      Image()\Delay = Delay
      Image()\Timer = Timer
      
    EndIf

  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure   DrawFrame_(OutputID.i, X.i, Y.i)
	  Define.i X, Y, Width, Height, Delay, OffsetX, OffsetY

		If StartDrawing(OutputID)
		  
		  If ListIndex(Image()\Frame()) <> -1
		    
		    OffsetX = Image()\Frame()\OffsetX * Image()\ScaleX
        OffsetY = Image()\Frame()\OffsetY * Image()\ScaleY
        Width   = Image()\Frame()\Width   * Image()\ScaleX
        Height  = Image()\Frame()\Height  * Image()\ScaleY
		    
		    Select Image()\Frame()\Dispose    ; Dispose Output Buffer
          Case #APNG_Dispos_OP_None       ;{ None
            ;}
          Case #APNG_Dispos_OP_Background ;{ Background
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            Box(X + OffsetX, Y + OffsetY, Width, Height, $00000000) 
            ;}
          Case #APNG_Dispos_OP_Previous   ;{ Previous
            If IsImage(Image()\PrevImage\Num)
              DrawingMode(#PB_2DDrawing_Default)
              DrawImage(ImageID(Image()\PrevImage\Num), Image()\PrevImage\X, Image()\PrevImage\Y)
            EndIf ;}
        EndSelect

      EndIf
      
      If NextElement(Image()\Frame()) = #False
        FirstElement(Image()\Frame())
        Image()\CurrentLoop + 1
      EndIf
      
      OffsetX = Image()\Frame()\OffsetX * Image()\ScaleX
      OffsetY = Image()\Frame()\OffsetY * Image()\ScaleY
      Width   = Image()\Frame()\Width   * Image()\ScaleX
      Height  = Image()\Frame()\Height  * Image()\ScaleY
      
      If IsImage(Image()\PrevImage\Num) : FreeImage(Image()\PrevImage\Num) : EndIf

      Image()\PrevImage\Num = GrabDrawingImage(#PB_Any, X + OffsetX, Y + OffsetY, Width, Height)
      Image()\PrevImage\X   = X + OffsetX
      Image()\PrevImage\Y   = Y + OffsetY
      
      If IsImage(Image()\Num)

        Select Image()\Frame()\Blend ; Blend Output Buffer
          Case #APNG_Blend_OP_Over   ;{ Over
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            DrawImage(ImageID(Image()\Frame()\ImageNum), X + OffsetX, Y + OffsetY, Width, Height)
            ;}
          Case #APNG_Blend_OP_Source ;{ Source
            DrawingMode(#PB_2DDrawing_Default)
            Box(X, Y, Image()\Width, Image()\Height, Image()\BackColor)
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            DrawImage(ImageID(Image()\Frame()\ImageNum), X + OffsetX, Y + OffsetY, Width, Height)
            ;}
        EndSelect

        Delay = Image()\Frame()\Delay
      EndIf

		  StopDrawing()
		EndIf  

  	ProcedureReturn Delay
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
  
  Procedure   ResetFrames(ImageNum.i)
    
    If FindMapElement(Image(), Str(ImageNum))
      
      Image()\Loops = 0
      Image()\Delay = 0
      
      ResetList(Image()\Frame())
      
    EndIf
    
  EndProcedure
  
  Procedure   ScaleFrames(ImageNum.i, FactorX.f, FactorY.f)
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If FactorX = 0 : FactorX = 1 : EndIf
      If FactorY = 0 : FactorY = 1 : EndIf
      
      Image()\ScaleX = FactorX
      Image()\ScaleY = FactorY
      
    EndIf
    
  EndProcedure
  
  
  Procedure.i DrawFrame(ImageNum.i, OutputID.i, X.i=0, Y.i=0, Index.i=#PB_Default, BackColor.i=#PB_Default) 
    Define.i OutputID, Delay
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If BackColor <> #PB_Default : Image()\BackColor = BackColor : EndIf
      
      If Index = #PB_Default

        Delay = DrawFrame_(OutputID, X, Y)
        If Delay = 0 : Delay = 10 : EndIf
        
        If Image()\Timer : SetTimer_(Delay + 20, Image()\Timer) : EndIf 
        
      Else
        
        If Index > 0
          SelectElement(Image()\Frame(), Index - 1)
        Else
          ResetList(Image()\Frame())
        EndIf  

        Delay = DrawFrame_(OutputID, X, Y)
        If Delay = 0 : Delay = 10 : EndIf
        
        If Image()\Timer : SetTimer_(Delay + 20, Image()\Timer) : EndIf 

      EndIf
      
    EndIf
    
    ProcedureReturn Delay
  EndProcedure
  
  
  Procedure.i GetFrame(ImageNum.i)
    
    If FindMapElement(Image(), Str(ImageNum))
      ProcedureReturn ListIndex(Image()\Frame())
    EndIf  
    
  EndProcedure
  
  Procedure.i GetLoop(ImageNum.i)
    
    If FindMapElement(Image(), Str(ImageNum))
      ProcedureReturn Image()\CurrentLoop
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

          If ListIndex(Image()\Frame()) = -1
            If FirstElement(Image()\Frame())
              FrameNum = Image()\Frame()\ImageNum
            EndIf  
          Else  
            FrameNum = Image()\Frame()\ImageNum
          EndIf
        
        EndIf
        
      EndIf
      
      If IsImage(FrameNum)
        ProcedureReturn ImageID(FrameNum)
      EndIf
      
    EndIf

    ProcedureReturn #False
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
    Define   ImgData.Stream_Structure
    
    Result = LoadImage(ImageNum, File)
    If ImageNum =#PB_Any : ImageNum = Result  : EndIf

    If AddMapElement(Image(), Str(ImageNum))
      
      Image()\Num = ImageNum
      
      FileNum = ReadFile(#PB_Any, File)
      If FileNum
        
        FileSize = Lof(FileNum)
        
        *Stream = AllocateMemory(FileSize)
        If *Stream
          
          If ReadData(FileNum, *Stream, FileSize)
            
            AnalyzeStream_(*Stream, FileSize, @ImgData)
            
            Image()\Frames = ImgData\acTL\Frames
            Image()\Loops  = ImgData\acTL\Loops
            Image()\Width  = ImgData\IHDR\Width
            Image()\Height = ImgData\IHDR\Height
            
            LoadFrames_(*Stream, @ImgData)
            
          EndIf
          
          FreeMemory(*Stream)
        EndIf
        
        CloseFile(FileNum)
      EndIf   
      
      Image()\ScaleX = 1
      Image()\ScaleY = 1
      Image()\Window = #PB_Default
      
      CompilerSelect #PB_Compiler_OS ;{ Color
				CompilerCase #PB_OS_Windows
					Image()\BackColor = GetSysColor_(#COLOR_MENU)
				CompilerCase #PB_OS_MacOS
					Image()\BackColor = OSX_GadgetColor()
				CompilerDefault
          Image()\BackColor = $F0F0F0
			CompilerEndSelect ;}
      
      FirstElement(Image()\Frame())
      
    EndIf
    
    ProcedureReturn ImageNum
  EndProcedure
  
  Procedure   Save(ImageNum.i, File.s)
    Define.i f, FileNum, Frames, ImageSize, FrameSize
    Define.i BlockSize, Index, Width, Height, Delay, DelayDen
    Define.s CRC
    Define   *Stream, *Frame, *Block
    Define   ImgData.Stream_Structure
    
    NewList Frame.IDAT_Structure()
    
    If IsImage(ImageNum)
      
      Frames = ImageFrameCount(ImageNum)
      Width  = ImageWidth(ImageNum)
      Height = ImageHeight(ImageNum)
      
      *Stream = EncodeImage(ImageNum, #PB_ImagePlugin_PNG, #False, 32)
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
              If Delay = 0 : Delay = 100: EndIf 
              
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
              *Frame = EncodeImage(ImageNum, #PB_ImagePlugin_PNG, #False, 32)
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
      
      If Index > 0
        ProcedureReturn SelectElement(Image()\Frame(), Index - 1)
      Else
        ResetList(Image()\Frame())
        ProcedureReturn #True
      EndIf  

    EndIf  
    
  EndProcedure
  
  Procedure   SetTimer(ImageNum.i, Delay.i, Timer.i=#PB_Default)
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If Timer = #PB_Default : Timer = #Timer : EndIf 
      
      SetTimer_(Delay, Timer)

    EndIf 
    
  EndProcedure
  
  
  Procedure   StartTimer(ImageNum.i, Window.i, Loops.i=#PB_Default, Timer.i=#PB_Default)
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If Timer = #PB_Default  : Timer = #Timer : EndIf 
      If Loops <> #PB_Default : Image()\Loops = Loops : EndIf 
      
      If Image()\Timer : RemoveWindowTimer(Window, Timer) : EndIf
      
      If IsWindow(Window) : AddWindowTimer(Window, Timer, 1) : EndIf 
      
      Image()\Window = Window
      Image()\Timer = Timer
      Image()\Delay = 100

    EndIf 
    
  EndProcedure
  
  Procedure   PauseTimer(ImageNum.i, Timer.i=#PB_Default)
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If Timer = #PB_Default : Timer = #Timer : EndIf 
      
      If Image()\Timer
        If IsWindow(Image()\Window) : AddWindowTimer(Image()\Window, Timer, 1) : EndIf 
        Image()\Timer = Timer
      Else
        If IsWindow(Image()\Window) : RemoveWindowTimer(Image()\Window, Timer) : EndIf
        Image()\Timer = #False
      EndIf
    
    EndIf 
    
  EndProcedure
  
  Procedure   StopTimer(ImageNum.i, Timer.i=#PB_Default)
    
    If FindMapElement(Image(), Str(ImageNum))
      
      If Timer = #PB_Default : Timer = #Timer : EndIf 
      
      If IsWindow(Image()\Window) : RemoveWindowTimer(Image()\Window, Timer) : EndIf 
      
      Image()\Timer = #False
      Image()\Loops = 0
      Image()\Delay = 0
      
      ResetList(Image()\Frame())
      
    EndIf 
    
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 0
  
  ; 0: Use PNG::DrawFram()
  ; 1: PNG::AddFrames()
  ; 2: Convert GIF
  
  UsePNGImageDecoder()
  
  #File  = 1
  #Image = 1
  #Frame = 2	

  #Window  = 1
  #Gadget  = 1
  #Timer   = 1
  
  File$ = "Elephant.png" ; Elephant.png  grace-hoppers-107th-birthday.png clock.png bugbuckbunny.png
  GIF$  = "Chicken.gif"
  
  If OpenWindow(#Window, 0, 0, 500, 420, "ImageGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    CanvasGadget(#Gadget, 10, 10, 480, 400)
  
    Select #Example
      Case 1  ;{ Use PB image frames
        
        Frame = 0
        
        PNG::Load(#Image, File$)
        PNG::AddFrames(#Image)

        AddWindowTimer(#Window, #Timer, 1)
        ;}
      Case 2  ;{ Convert GIF
        
        UseGIFImageDecoder()
      
        If LoadImage(#Image, GIF$)
          PNG::Save(#Image, GetFilePart(GIF$, #PB_FileSystem_NoExtension) + ".png")
          FreeImage(#Image)
        EndIf
        
        If PNG::Load(#Image, GetFilePart(GIF$, #PB_FileSystem_NoExtension) + ".png")
          AddWindowTimer(#Window, #Timer, 1)
        EndIf
        ;}
      Default ;{ Use internal frames
        
        PNG::Load(#Image, File$)
        
        ;PNG::ScaleFrames(#Image, 0.5, 0.5)
        
        PNG::ResetFrames(#Image)
        PNG::StartTimer(#Image, #Window)
        ;}
    EndSelect

    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Timer  ;{ Timer
          
          If EventTimer() = PNG::#Timer
            Select #Example
              Case 1  ;{ PNG::AddFrames()

                SetImageFrame(#Image, Frame)
                
                Delay = GetImageFrameDelay(#Image)
                If Delay = 0 : Delay = 100 : EndIf
               
                RemoveWindowTimer(#Window, #Timer)
                AddWindowTimer(#Window, #Timer, Delay)
                
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
              Default ;{ Internal frames
                
                PNG::DrawFrame(#Image, CanvasOutput(#Gadget))

                If PNG::LoopCount(#Image)
                  If PNG::GetLoop(#Image) >= PNG::LoopCount(#Image)
                    PNG::StopTimer(#Image, #Window)
                  EndIf 
                EndIf  
                
                ;}  
            EndSelect
          EndIf 
          ;}  
      EndSelect
    Until Event = #PB_Event_CloseWindow
  
    CloseWindow(#Window)
  EndIf
 
CompilerEndIf  
  
 
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 1516
; FirstLine = 328
; Folding = YAAgCAAAAgAAGAk6
; EnableXP
; DPIAware