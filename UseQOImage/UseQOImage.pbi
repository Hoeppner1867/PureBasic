;/ ==========================
;/ =    UseQOIModule.pbi    =
;/ ==========================
;/
;/ [ PB V5.7x - V6.0 / 64Bit / All OS / DPI ]
;/
;/ Use Quite OK Images
;/
;/ Based on codes of infratec & wilbert
;/
;/ © 2022  by Thorsten Hoeppner (04/2020)
;/

; Last Update: 
;


;{ ===== MIT License =====
;
; Copyright (c) 2022 Thorsten Hoeppner
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


;{ _____ QOI - Commands _____
;
; QOI::Catch()  - similar to CatchImage()
; QOI::Load()   - similar to LoadImage(9
; QOI::Save()   - similar to SaveImage()
; QOI::Free()   - similar to FreeImage()
;
;}

DeclareModule QOI
  
  #Version  = 22060600

  ;- ===========================================================================
	;-   DeclareModule - Constants
  ;- =========================================================================
  
  #QOI_sRGB   = 0
  #QOI_Linear = 1
  
  ;- ======================================================
	;-   DeclareModule
	;- ======================================================

  Declare.i Catch(Image.i, *Memory, Size.i)
  Declare.i Load(Image.i, File.s, Flags.i=#False)
  Declare.i Save(Image.i, File.s)
  
  Declare   Free(Image.i)
  
EndDeclareModule

Module QOI
  
  EnableExplicit
  
	;- ======================================================
	;-   Module - Constants
	;- ======================================================

  #QOI_Magic       = "qoif"
  #QOI_Header_Size = 14
  #QOI_Footer_Size = 8
  
  #QOI_OP_Index    = $00 ; 00xxxxxx
  #QOI_OP_Diff     = $40 ; 01xxxxxx
  #QOI_OP_Luma     = $80 ; 10xxxxxx
  #QOI_OP_Run      = $c0 ; 11xxxxxx
  #QOI_OP_RGB      = $fe ; 11111110
  #QOI_OP_RGBA     = $ff ; 11111111
  
  #QOI_Mask_2      = $c0 ; 11000000
  
  #QOI_Pixels_Max  = 400000000 

  ;- ======================================================
	;-   Module - Structures
	;- ======================================================
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    
    ; DrawingBuffer
    
    Structure RGBA_DB_Structure
      B.a
      G.a
      R.a
      A.a
    EndStructure
    
  CompilerElse  
    
    Structure RGBA_DB_Structure
      R.a
      G.a
      B.a
      A.a
    EndStructure
    
  CompilerEndIf
 
  Structure RGBA_Structure   ;{ RGBA
    R.a
    G.a
    B.a
    A.a
  EndStructure ;}
  
  Structure RGBA_T_Structure ;{ RGBA_T
    StructureUnion
      RGBA.RGBA_Structure
      V.i
    EndStructureUnion
  EndStructure ;}

  Structure QOI_Header_Structure ;{ Image()\Header\...
    Magic.s{4}    ; magic bytes "qoif"
    Width.q       ; image widht in pixel (BE)
    Height.q      ; image height in Pixel (BE)
    Channels.a    ; 3 = RGB, 4 = RGBA
    Colorspace.a  ; 0 = sRGB with linear alpha / 1 = all channels linear
  EndStructure ;}
  
  Structure QOI_Image_Structure  ;{ Image()\...
    Num.i
    *DataQOI
    *Pixels.RGBA_T_Structure
    Size.i
    Header.QOI_Header_Structure ; qoi_desc
  EndStructure ;}
  Global NewMap Image.QOI_Image_Structure()
  
  Global *ImagePixels.RGBA_Structure
  Global Mutex = CreateMutex()
  
  ;- ======================================================
  ;-   Internal
  ;- ======================================================  
 
  Procedure.q uint32(Value.i, BigEndian.i=#True)
  
    If BigEndian
      ProcedureReturn (Value>>24&$FF) | (Value>>8&$FF00) | (Value<<8&$FF0000) | (Value<<24&$FF000000)
    Else
      ProcedureReturn Value & $FFFFFFFF
    EndIf
    
  EndProcedure  
  
  Procedure.i Color_Hash(R.i, G.i, B.i, A.i=255) 
    ProcedureReturn (R * 3 + G * 5 + B * 7 + A * 11)
  EndProcedure
 
  Procedure.i Check_Header_()
    
    If Image()\Header\Magic <> #QOI_Magic
      ProcedureReturn #False
    ElseIf Image()\Header\Width = 0 Or Image()\Header\Height = 0
      ProcedureReturn #False
    ElseIf Image()\Header\Channels < 3 Or Image()\Header\Channels > 4
      ProcedureReturn #False
    ElseIf Image()\Header\Height >= (#QOI_Pixels_Max / Image()\Header\Width)
      ProcedureReturn #False
    EndIf   
    
    ProcedureReturn #True
  EndProcedure 
  
  ;- ======================================================
  ;-   Image -Decode
  ;- ======================================================  

  Procedure   DecodeFilterCallback(X.i, Y.i, Channels.i, TargetColor.i)
    *ImagePixels + Channels
    ProcedureReturn RGBA(*ImagePixels\R, *ImagePixels\G, *ImagePixels\B, *ImagePixels\A)
  EndProcedure
  
  Procedure   DrawDecodedImage_()

    If IsImage(Image()\Num)
    
      ResizeImage(Image()\Num,  Image()\Header\Width, Image()\Header\Height, #PB_Image_Raw)
      
      If Image()\Pixels
      
        If StartDrawing(ImageOutput(Image()\Num))
          
          *ImagePixels = Image()\Pixels - Image()\Header\Channels
          
          DrawingMode(#PB_2DDrawing_CustomFilter)
          CustomFilterCallback(@DecodeFilterCallback())
          Box(0, 0, Image()\Header\Width, Image()\Header\Height, Image()\Header\Channels)
          
          StopDrawing()
        EndIf
        
        If Image()\Pixels
          FreeMemory(Image()\Pixels)
          Image()\Pixels = #False
        EndIf  
        
      EndIf
      
    EndIf
    
  EndProcedure  

  Procedure   CatchImage_() 
    Define   *Buffer, *Bytes.Ascii
    Define   PX.RGBA_T_Structure, *Pixel.RGBA_DB_Structure, *Pixel_End.RGBA_DB_Structure
    Define.i Byte1, Byte2, VG, Run = 0
    Define.i Width, Height, Pitch, Hash, Chunks_Len, Channels
    
    Dim Index.RGBA_T_Structure(63)
    
    If Check_Header_()
      
      If IsImage(Image()\Num)
    
        ResizeImage(Image()\Num,  Image()\Header\Width, Image()\Header\Height, #PB_Image_Raw)
        
        Width      = Image()\Header\Width
        Height     = Image()\Header\Height
        Chunks_Len = Image()\Size - #QOI_Footer_Size
        
        PX\RGBA\R = 0
        PX\RGBA\G = 0
        PX\RGBA\B = 0
        PX\RGBA\A = 255
        
        *Bytes = Image()\DataQOI
        
        If StartDrawing(ImageOutput(Image()\Num))
          
          If DrawingBufferPixelFormat() & #PB_PixelFormat_ReversedY  
            *Buffer =  DrawingBuffer() + DrawingBufferPitch() * (Height - 1)
            Pitch   = -DrawingBufferPitch()
          Else
            *Buffer = DrawingBuffer()
            Pitch   = DrawingBufferPitch()
          EndIf
          
          While Height
            
            *Pixel = *Buffer
            *Pixel_End = *Pixel + Width << 2

            While *Pixel < *Pixel_End
              
              If Run > 0 
                Run - 1
              ElseIf *Bytes < Chunks_Len + Image()\DataQOI
                
                Byte1 = *Bytes\a : *Bytes + 1
                
                If Byte1 = #QOI_OP_RGB
                  PX\RGBA\R = *Bytes\a : *Bytes + 1
                  PX\RGBA\G = *Bytes\a : *Bytes + 1
                  PX\RGBA\B = *Bytes\a : *Bytes + 1
                ElseIf Byte1 = #QOI_OP_RGBA
                  PX\RGBA\R = *Bytes\a : *Bytes + 1
                  PX\RGBA\G = *Bytes\a : *Bytes + 1
                  PX\RGBA\B = *Bytes\a : *Bytes + 1
                  PX\RGBA\A = *Bytes\a : *Bytes + 1
                ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Index
                  PX\V = Index(Byte1)\V
                ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Diff 
                  PX\RGBA\R + ((Byte1 >> 4) & $03) - 2
                  PX\RGBA\G + ((Byte1 >> 2) & $03) - 2
                  PX\RGBA\B +  (Byte1 & $03) - 2
                ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Luma  
                  Byte2 = *Bytes\a : *Bytes + 1
                  VG    = (Byte1 & $3f) - 32
                  PX\RGBA\R + VG - 8 + ((Byte2 >> 4) & $0f)
                  PX\RGBA\G + VG
                  PX\RGBA\B + VG - 8 + (Byte2 & $0f)
                ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Run
                  Run = (Byte1 & $3f)
                EndIf
                
                Hash = Color_Hash(PX\RGBA\R, PX\RGBA\G, PX\RGBA\B, PX\RGBA\A)
                Index(Hash % 64)\V = PX\V
                
              EndIf
              
              *Pixel\R = PX\RGBA\R
              *Pixel\G = PX\RGBA\G
              *Pixel\B = PX\RGBA\B
              *Pixel\A = PX\RGBA\A 

              *Pixel + 4
            Wend

            *Buffer + Pitch
            
            Height - 1
          Wend
          
          StopDrawing()
        EndIf
        
      EndIf

    EndIf
    
  EndProcedure
  
  Procedure.i DecodeImage_(Channels.i=0)
    Define   *Bytes.Ascii
    Define   *Pixels.RGBA_T_Structure
    Define   PX.RGBA_T_Structure
    Define.i Pixel_Len, Chunks_Len, Pixel_Pos, Hash
    Define.a Byte1, Byte2, VG
    Define.i Run = 0
    
    Dim Index.RGBA_T_Structure(63)

    If Channels = 0 : Channels = Image()\Header\Channels : EndIf
    
    If Check_Header_()
    
      Pixel_Len  = Image()\Header\Width * Image()\Header\Height * Channels
      Chunks_Len = Image()\Size - #QOI_Footer_Size
      
      Image()\Pixels = AllocateMemory(Pixel_Len)
      If Image()\Pixels
      
        PX\RGBA\R = 0
        PX\RGBA\G = 0
        PX\RGBA\B = 0
        PX\RGBA\A = 255
        
        *Bytes = Image()\DataQOI
        
        While Pixel_Pos < Pixel_Len
          
          If Run > 0
            Run - 1
          ElseIf *Bytes < Chunks_Len + Image()\DataQOI
            
            Byte1 = *Bytes\a : *Bytes + 1
            
            If Byte1 = #QOI_OP_RGB
              PX\RGBA\R = *Bytes\a : *Bytes + 1
              PX\RGBA\G = *Bytes\a : *Bytes + 1
              PX\RGBA\B = *Bytes\a : *Bytes + 1
            ElseIf Byte1 = #QOI_OP_RGBA
              PX\RGBA\R = *Bytes\a : *Bytes + 1
              PX\RGBA\G = *Bytes\a : *Bytes + 1
              PX\RGBA\B = *Bytes\a : *Bytes + 1
              PX\RGBA\A = *Bytes\a : *Bytes + 1
            ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Index
              PX\V = Index(Byte1)\V
            ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Diff 
              PX\RGBA\R + ((Byte1 >> 4) & $03) - 2
              PX\RGBA\G + ((Byte1 >> 2) & $03) - 2
              PX\RGBA\B +  (Byte1 & $03) - 2
            ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Luma  
              Byte2 = *Bytes\a : *Bytes + 1
              VG    = (Byte1 & $3f) - 32
              PX\RGBA\R + VG - 8 + ((Byte2 >> 4) & $0f)
              PX\RGBA\G + VG
              PX\RGBA\B + VG - 8 + (Byte2 & $0f)
            ElseIf (Byte1 & #QOI_Mask_2) = #QOI_OP_Run
              Run = (Byte1 & $3f)
            EndIf
            
            Hash = Color_Hash(PX\RGBA\R, PX\RGBA\G, PX\RGBA\B, PX\RGBA\A)
            Index(Hash % 64)\V = PX\V
            
          EndIf
          
          *Pixels = Image()\Pixels + Pixel_Pos
          
          If Channels = 4
            *Pixels\RGBA\R = PX\RGBA\R
            *Pixels\RGBA\G = PX\RGBA\G
            *Pixels\RGBA\B = PX\RGBA\B
            *Pixels\RGBA\A = PX\RGBA\A
          Else
            *Pixels\RGBA\R = PX\RGBA\R
            *Pixels\RGBA\G = PX\RGBA\G
            *Pixels\RGBA\B = PX\RGBA\B
          EndIf  
          
          Pixel_Pos + Channels
        Wend 
      
        If Image()\DataQOI
          FreeMemory(Image()\DataQOI)
          Image()\DataQOI = #False
        EndIf
        
      EndIf
      
      ProcedureReturn Image()\Pixels
    EndIf
    
  EndProcedure

  Procedure.i LoadImage_(File.s)
    Define.i BOM, FileID
    Define.q FileSize
    
    FileID = ReadFile(#PB_Any, File)
    If FileID
      
      BOM = ReadStringFormat(FileID)
      
      FileSize = Lof(FileID)
      
      Image()\Header\Magic      = ReadString(FileID, BOM, 4)
      Image()\Header\Width      = uint32(ReadLong(FileID))
      Image()\Header\Height     = uint32(ReadLong(FileID))
      Image()\Header\Channels   = ReadAsciiCharacter(FileID)
      Image()\Header\Colorspace = ReadAsciiCharacter(FileID)
      
      If Check_Header_()
        
        Image()\Size = FileSize - #QOI_Header_Size
        
        Image()\DataQOI = AllocateMemory(Image()\Size)
        If Image()\DataQOI
          ReadData(FileID, Image()\DataQOI, Image()\Size)
        EndIf
         
      Else  
        
        Image()\Header\Magic      = ""
        Image()\Header\Width      = #False
        Image()\Header\Height     = #False
        Image()\Header\Channels   = #False
        Image()\Header\Colorspace = #False
        Image()\DataQOI           = #False
        Image()\Size              = #False
        
      EndIf
      
      CloseFile(FileID)
    EndIf

    ProcedureReturn Image()\Size
  EndProcedure
  
  ;- ======================================================
  ;-   Image -Encode
  ;- ======================================================  
  
  Procedure   EncodeFilterCallback(X.i, Y.i, Channels.i, TargetColor.i)
  
    *ImagePixels + Channels
    
    *ImagePixels\R = Red(TargetColor)
    *ImagePixels\G = Green(TargetColor)
    *ImagePixels\B = Blue(TargetColor)
    *ImagePixels\A = Alpha(TargetColor)
    
    ProcedureReturn TargetColor
  EndProcedure
  
  Procedure   ImageToPixels_()
    
    Image()\Size = Image()\Header\Width * Image()\Header\Height * Image()\Header\Channels
    
    Image()\Pixels = AllocateMemory(Image()\Size)
    If Image()\Pixels
      
      LockMutex(Mutex)
      
      If StartDrawing(ImageOutput(Image()\Num))
        
        *ImagePixels = Image()\Pixels - Image()\Header\Channels
        
        DrawingMode(#PB_2DDrawing_CustomFilter)
        CustomFilterCallback(@EncodeFilterCallback())
        Box(0, 0, Image()\Header\Width, Image()\Header\Height, Image()\Header\Channels)

        StopDrawing()
      EndIf
      
      UnlockMutex(Mutex)
      
    EndIf  
    
  EndProcedure
  
  Procedure.i EncodeImage_() 
    Define   *Bytes.Ascii
    Define   *Pixels.RGBA_T_Structure
    Define   PX.RGBA_T_Structure, prevPX.RGBA_T_Structure
    Define.i Pixel_Len, Pixel_End, Pixel_Pos, Index_Pos, Channels
    Define.i vR, vG, vB, vA, vG_r, vG_b
    Define.i i, Run = 0
    
    Dim Index.RGBA_T_Structure(63)
    Dim QOI_Padding.a(7) : QOI_Padding(7) = 1

    If Check_Header_()
      
      Pixel_Len  = Image()\Header\Width * Image()\Header\Height * Image()\Header\Channels
      Pixel_End  = Pixel_Len - Image()\Header\Channels
      Channels   = Image()\Header\Channels
      
      Image()\DataQOI = AllocateMemory(Pixel_Len + #QOI_Footer_Size + 1)
      If Image()\DataQOI
        
        *Bytes  = Image()\DataQOI
        *Pixels = Image()\Pixels
        
        PX\RGBA\R = 0
        PX\RGBA\G = 0
        PX\RGBA\B = 0
        PX\RGBA\A = 255
        
        prevPX\RGBA\R = 0
        prevPX\RGBA\G = 0
        prevPX\RGBA\B = 0
        prevPX\RGBA\A = 255
        
        While Pixel_Pos < Pixel_Len
          
          If Channels = 4
            PX\RGBA\R = *Pixels\RGBA\R
            PX\RGBA\G = *Pixels\RGBA\G
            PX\RGBA\B = *Pixels\RGBA\B
            PX\RGBA\A = *Pixels\RGBA\A
          Else
            PX\RGBA\R = *Pixels\RGBA\R
            PX\RGBA\G = *Pixels\RGBA\G
            PX\RGBA\B = *Pixels\RGBA\B
          EndIf  
          
          If PX\V = prevPX\V
            
            Run + 1
            
      		  If Run = 62 Or Pixel_Pos = Pixel_End
      		    *Bytes\a = #QOI_OP_RUN | (Run - 1) : *Bytes + 1
      				Run = 0
      			EndIf
      			
      		Else 
      		  
      		  If Run > 0
      		    *Bytes\a = #QOI_OP_RUN | (Run - 1) : *Bytes + 1
      		    Run = 0
      		  EndIf

      		  Index_Pos = Color_Hash(PX\RGBA\R, PX\RGBA\G, PX\RGBA\B, PX\RGBA\A) % 64
      		  
      		  If Index(Index_Pos)\V = PX\V
      		    
      		    *Bytes\a = #QOI_OP_INDEX | Index_Pos : *Bytes + 1
      		    
      		  Else
      		    
      		    Index(Index_Pos)\V = PX\V
      		    
      		    If PX\RGBA\A = prevPX\RGBA\a
      		    
        		    vR = PX\RGBA\R - prevPX\RGBA\R
      				  vG = PX\RGBA\G - prevPX\RGBA\G
      				  vB = PX\RGBA\B - prevPX\RGBA\B
      				  
      				  vG_r = vR - vG
      				  vG_b = vB - vG
        		    
      				  If vR > -3 And vR < 2 And vG > -3 And vG < 2 And vB > -3 And vB < 2
      				    
      				    *Bytes\a = #QOI_OP_DIFF | ((vR + 2) << 4) | (vG + 2) << 2 | (vB + 2) : *Bytes + 1
      				    
      				  ElseIf vG_r > -9 And vG_r < 8 And vG > -33 And vG < 32 And vG_b > -9 And vG_b < 8
      				    
      					  *Bytes\a = #QOI_OP_LUMA    | (vG   + 32) : *Bytes + 1
      					  *Bytes\a = (vG_r + 8) << 4 | (vG_b +  8) : *Bytes + 1
      					  
      					Else
      					  
      					  *Bytes\a = #QOI_OP_RGB : *Bytes + 1
      					  *Bytes\a = PX\RGBA\R   : *Bytes + 1
      					  *Bytes\a = PX\RGBA\G   : *Bytes + 1
      					  *Bytes\a = PX\RGBA\B   : *Bytes + 1
      					  
      					EndIf
      					
      				Else
      				  
            		*Bytes\a = #QOI_OP_RGBA : *Bytes + 1
      					*Bytes\a = PX\RGBA\R    : *Bytes + 1
      					*Bytes\a = PX\RGBA\G    : *Bytes + 1
      					*Bytes\a = PX\RGBA\B    : *Bytes + 1
      					*Bytes\a = px\rgba\a    : *Bytes + 1
      				  
      				EndIf
      				
      		  EndIf  
      		  
          EndIf  
          
          prevPX\V = PX\V
		
      		*Pixels   + Channels
      		Pixel_Pos + Channels
          
        Wend  
        
        For i = 0 To 7
      	  *Bytes\a = qoi_padding(i) : *Bytes + 1
      	Next
        
        Image()\Size = *Bytes - Image()\DataQOI
        
        If Image()\Pixels
          FreeMemory(Image()\Pixels)
          Image()\Pixels = #False
        EndIf   
        
        ProcedureReturn Image()\DataQOI
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SaveImage_(File.s)
    Define.i FileID
    
    FileID = CreateFile(#PB_Any, File)
    If FileID
      
      WriteString(FileID, Image()\Header\Magic)
      WriteLong(FileID, uint32(Image()\Header\Width))
      WriteLong(FileID, uint32(Image()\Header\Height))
      WriteAsciiCharacter(FileID, Image()\Header\Channels)
      WriteAsciiCharacter(FileID, Image()\Header\Colorspace)
      WriteData(FileID, Image()\DataQOI, Image()\Size)
      
      CloseFile(FileID)
    EndIf
    
    If Image()\DataQOI
      FreeMemory(Image()\DataQOI)
      Image()\DataQOI = #False
    EndIf  
    
    ProcedureReturn Image()\Size + #QOI_Header_Size
  EndProcedure
  
  ;- ======================================================
	;-   Module - Declared Procedures
	;- ======================================================
  
  Procedure.i Catch(Image.i, *Memory, Size.i)
    Define.i  Result
    
    Result = CreateImage(Image, 10, 10, 32)
    If Image = #PB_Any : Image = Result : EndIf 

    If AddMapElement(Image(), Str(Image))
      
      Image()\Num = Image
      
      If *Memory And Size
        
        Image()\Header\Magic      = PeekS(*Memory, 4, #PB_Ascii) : *Memory + 4
        Image()\Header\Width      = uint32(PeekL(*Memory)) : *Memory + 4
        Image()\Header\Height     = uint32(PeekL(*Memory)) : *Memory + 4
        Image()\Header\Channels   = PeekA(*Memory)         : *Memory + 1
        Image()\Header\Colorspace = PeekA(*Memory)         : *Memory + 1
        
        Image()\DataQOI = *Memory
        Image()\Size    = Size - #QOI_Header_Size
        
        CatchImage_()

      EndIf  
      
      ProcedureReturn Image()\Num
    EndIf
    
  EndProcedure
  
  Procedure.i Save(Image.i, File.s)
    
    If IsImage(Image)
     
      If AddMapElement(Image(), Str(Image))
        
        Image()\Num = Image
        
        Image()\Header\Magic      = #QOI_Magic
        Image()\Header\Width      = ImageWidth(Image)
        Image()\Header\Height     = ImageHeight(Image)
        Image()\Header\Channels   = ImageDepth(Image) / 8
        Image()\Header\Colorspace = 0
        
        ImageToPixels_()
        EncodeImage_() 
        SaveImage_(File)
        
        ProcedureReturn Image()\Size
      EndIf  
      
    EndIf
    
  EndProcedure
  
  Procedure.i Load(Image.i, File.s, Flags.i=#False)
    Define.i  Result
    
    Result = CreateImage(Image, 10, 10, 32)
    If Image = #PB_Any : Image = Result : EndIf 
    
    If AddMapElement(Image(), Str(Image))
      
      Image()\Num = Image
      
      If LoadImage_(File)
        DecodeImage_()
        DrawDecodedImage_()
      EndIf
      
    EndIf  

    ProcedureReturn Image
  EndProcedure
  
  Procedure   Free(Image.i)
    
    If FindMapElement(Image(), Str(Image))
      
      If Image()\Pixels  : FreeMemory(Image()\Pixels)  : EndIf
      If Image()\DataQOI : FreeMemory(Image()\DataQOI) : EndIf
      
      If IsImage(Image()\Num) : FreeImage(Image()\Num) : EndIf 

      DeleteMapElement(Image())
      
    EndIf  
    
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 2
  
  ; 0: Load QOI-Image
  ; 1: Save image as QOI
  ; 2: Catch QOI image
  
  UsePNGImageDecoder()
  
  Enumeration 1 ;{
    #Window
    #Gadget
    #Image
    #File
  EndEnumeration ;}

  Select #Example
    Case 1  ;{ Save image as QOI
      
      File$ = "TestCard.png"
      
      If LoadImage(#Image, File$)
        QOI::Save(#Image, ReplaceString(File$, ".png", ".qoi"))
      EndIf
      ;}
    Case 2  ;{ Catch image
      
      If OpenWindow(#Window, 0, 0, 532, 532, " Example - Quite OK Image", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        
        File$ = "D:\Entwicklung\Projekte\Module\UseQOImage\baboon.qoi"

        If ReadFile(#File, File$) ;{ Load image to memory
          BOM.i = ReadStringFormat(#File)
          FileSize.i = Lof(#File)
          *Memory = AllocateMemory(FileSize)
          If *Memory
            ReadData(#File, *Memory, FileSize)
          EndIf
          CloseFile(#File) ;}
        EndIf  
        
        If QOI::Catch(#Image, *Memory, FileSize)
          ImageGadget(#Gadget, 10, 10, 512, 512, ImageID(#Image))
          FreeMemory(*Memory)
        EndIf

        Repeat
          Event = WaitWindowEvent()
        Until Event = #PB_Event_CloseWindow

        CloseWindow(#Window)
      EndIf
      
      ;}
    Default ;{ Load QOI-Image
      
      If OpenWindow(#Window, 0, 0, 532, 532, " Example - Quite OK Image", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        
        File$ = "baboon.qoi"
        
        If QOI::Load(#Image, File$)
          ImageGadget(#Gadget, 10, 10, 512, 512, ImageID(#Image))
        EndIf

        Repeat
          Event = WaitWindowEvent()
        Until Event = #PB_Event_CloseWindow

        CloseWindow(#Window)
      EndIf
      ;}
  EndSelect    

CompilerEndIf  
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 99
; FirstLine = 108
; Folding = OAAAE+
; EnableXP
; DPIAware