;/ ============================
;/ =    ImagePluginQOI.pbi    =
;/ ============================
;/
;/ [ PB V5.7x - V6.0 / 64Bit / All OS / DPI ]
;/
;/ ImagePlugin for "Quite Ok Image" - Format
;/
;/ Based on codes of infratec, wilbert
;/
;/ © 2022  by Thorsten Hoeppner (04/2020)
;/


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

;{ _____ QOIF - Commands _____

; QOIF::UseImageDecoder() - Use QOI Decoder
; QOIF::UseImageEncoder() - Use QOI Encoder
;
; QOIF::#PB_ImagePlugin   - constant for ImagePlugin
;

;}

DeclareModule QOIF
  
  ;- ======================================================
	;-   DeclareModule - Constants
  ;- ======================================================
  
  #PB_ImagePlugin = $514F49
  
  ;- ======================================================
	;-   DeclareModule
	;- ======================================================
  
  Declare   UseImageDecoder()
  Declare   UseImageEncoder()

EndDeclareModule  

Module QOIF
  
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
  
  ;{ ----- ImagePlungin (wilbert) -----
  #PB_ImageDecoder_File     = 0
  #PB_ImageDecoder_Memory   = 1
  #PB_ImageDecoder_ReverseY = 2
  ;}
  
  ;- ======================================================
	;-   Module - Structures
	;- ======================================================
  
  ;{ ----- ImagePlungin (wilbert) -----
  Structure PB_ImageDecoder Align #PB_Structure_AlignC
    *Check
    *Decode
    *Cleanup
    ID.l
  EndStructure
  
  Structure PB_ImageDecoderGlobals Align #PB_Structure_AlignC
    *Decoder.PB_ImageDecoder
    *Filename
    *File
    *Buffer
    Length.l
    Mode.l
    Width.l
    Height.l
    Depth.l
    Flags.l
    Data.i[8]
    OriginalDepth.l
  EndStructure
  
  Structure PB_ImageEncoder Align #PB_Structure_AlignC
    ID.l
    *Encode24
    *Encode32
  EndStructure
  ;}
  
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
  
  Structure QOI_Header_Structure ;{ Header\...
    Magic.s{4}    ; magic bytes "qoif"
    Width.q       ; image widht in pixel (BE)
    Height.q      ; image height in Pixel (BE)
    Channels.a    ; 3 = RGB, 4 = RGBA
    Colorspace.a  ; 0 = sRGB with linear alpha / 1 = all channels linear
  EndStructure ;}
  Global Header.QOI_Header_Structure

  ;- ======================================================
  ;-   Internal
  ;- ====================================================== 
  
  ;{ ----- ImagePlungin (wilbert) -----
  IsImage(0); Make sure PB Image functionality is included
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows And #PB_Compiler_Processor = #PB_Processor_x86  
    Import ""
      PB_ImageDecoder_Register(*ImageDecoder.PB_ImageDecoder) As "_PB_ImageDecoder_Register@4"
      PB_ImageEncoder_Register(*ImageEncoder.PB_ImageEncoder) As "_PB_ImageEncoder_Register@4"
    EndImport
  CompilerElse
    ImportC ""
      PB_ImageDecoder_Register(*ImageDecoder.PB_ImageDecoder)
      PB_ImageEncoder_Register(*ImageEncoder.PB_ImageEncoder)
    EndImport
  CompilerEndIf
  ;}
  
  Procedure.q EndianL(val.l)
    ProcedureReturn (val>>24&$FF) | (val>>8&$FF00) | (val<<8&$FF0000) | (val<<24&$FF000000)
  EndProcedure
  
  Procedure.q uint32(Value.i, BigEndian.i=#True)
  
    If BigEndian
      ProcedureReturn (Value>>24&$FF) | (Value>>8&$FF00) | (Value<<8&$FF0000) | (Value<<24&$FF000000)
    Else
      ProcedureReturn Value & $FFFFFFFF
    EndIf
    
  EndProcedure  
  
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
  
  ;- ======================================================
  ;-   Image -Encoder
  ;- ======================================================  
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    
    Procedure EncodeQOI_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
      Define   *Memory, *Bytes.Ascii
      Define   *Pixels.RGBA_T_Structure, *Pixel.RGBA_DB_Structure
      Define   PX.RGBA_T_Structure, prevPX.RGBA_T_Structure
      Define.i Row_Len, Row_Pos, Pixel_Len, Pixel_End, Pixel_Pos, Index_Pos, MemorySize, ImageSize, Channels
      Define.i vR, vG, vB, vA, vG_r, vG_b
      Define.i Result, FileID, i, Run = 0
      Define.s FileName
      
      Dim Index.RGBA_T_Structure(63)
      Dim QOI_Padding.a(7) : QOI_Padding(7) = 1
      
      If *Filename
        FileName = PeekS(*Filename)
      EndIf
    
      Channels   = RequestedDepth / 8

      Header\Magic      = #QOI_Magic
      Header\Width      = Width
      Header\Height     = Height
      Header\Channels   = Channels
      Header\Colorspace = 0
      
      Row_Len    = Width * Channels
      Pixel_Len  = Width * Height * Channels
      Pixel_End  = Pixel_Len - Channels
      
      MemorySize = Pixel_Len + #QOI_Footer_Size + #QOI_Header_Size + 1

      *Memory = AllocateMemory(MemorySize)
      If *Memory
  
        *Bytes  = *Memory
        
        ; --- QOI - Header ---
        
        PokeS(*Bytes, #QOI_Magic, 4, #PB_Ascii) : *Bytes + 4
        PokeL(*Bytes, EndianL(Width))  : *Bytes + 4
        PokeL(*Bytes, EndianL(Height)) : *Bytes + 4
        PokeA(*Bytes, Channels)        : *Bytes + 1
        PokeA(*Bytes, 0)               : *Bytes + 1
        
        ; --- Image - Data ---
        
        If Flags & #PB_ImageDecoder_ReverseY
          *Pixel = *Buffer + LinePitch * (Height - 1)
          LinePitch  = -LinePitch
        Else
          *Pixel = *Buffer
        EndIf 

        PX\RGBA\R = 0
        PX\RGBA\G = 0
        PX\RGBA\B = 0
        PX\RGBA\A = 255
        
        prevPX\RGBA\R = 0
        prevPX\RGBA\G = 0
        prevPX\RGBA\B = 0
        prevPX\RGBA\A = 255
        
        While Pixel_Pos < Pixel_Len
          
          *Pixels = *Pixel + Row_Pos
          
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

      		  Index_Pos = (PX\RGBA\R * 3 + PX\RGBA\G * 5 + PX\RGBA\B * 7 + PX\RGBA\A * 11) % 64
      		  
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
		
      		Pixel_Pos + Channels
      		Row_Pos   + Channels
      		
      		If Row_Pos >= Row_Len
            *Pixel + LinePitch 
            Row_Pos = 0
          EndIf
      		
        Wend  
       
        ; --- Footer ---
        
        For i = 0 To 7
      	  *Bytes\a = QOI_Padding(i) : *Bytes + 1
      	Next
        
        ImageSize = *Bytes - *Memory
        *Memory = ReAllocateMemory(*Memory, ImageSize)

        If FileName
         
          FileID = CreateFile(#PB_Any, FileName)
          If FileID
            Result = WriteData(FileID, *Memory, ImageSize)
            CloseFile(FileID)
          EndIf   
          
          FreeMemory(*Memory)
          
          ProcedureReturn Result
        Else
          ProcedureReturn *Memory
        EndIf  

      EndIf

    EndProcedure
    
  CompilerElse  
    
    ProcedureC EncodeQOI_(*Filename, *Buffer, Width.l, Height.l, LinePitch.l, Flags.l, EncoderFlags.l, RequestedDepth.l)
      Define   *Memory, *Bytes.Ascii
      Define   *Pixels.RGBA_T_Structure, *Pixel.RGBA_DB_Structure
      Define   PX.RGBA_T_Structure, prevPX.RGBA_T_Structure
      Define.i Row_Len, Row_Pos, Pixel_Len, Pixel_End, Pixel_Pos, Index_Pos, ImageSize, Channels
      Define.i vR, vG, vB, vA, vG_r, vG_b
      Define.i Result, FileID, i, Run = 0
      Define.s FileName
      
      Dim Index.RGBA_T_Structure(63)
      Dim QOI_Padding.a(7) : QOI_Padding(7) = 1
      
      If *Filename
        FileName = PeekS(*Filename, -1, #PB_UTF8)
      EndIf
    
      Channels   = RequestedDepth / 8
      
      Header\Magic      = #QOI_Magic
      Header\Width      = Width
      Header\Height     = Height
      Header\Channels   = Channels
      Header\Colorspace = 0
      
      Row_Len    = Width * Channels
      Pixel_Len  = Width * Height * Channels
      Pixel_End  = Pixel_Len - Channels

      *Memory = AllocateMemory(#QOI_Header_Size + Pixel_Len + #QOI_Footer_Size + 1)
      If *Memory
        
        *Bytes  = *Memory
        
        ; --- QOI - Header ---
        
        PokeS(*Bytes, #QOI_Magic, 4, #PB_Ascii) : *Bytes + 4
        PokeL(uint32(*Bytes), Width)  : *Bytes + 4
        PokeL(uint32(*Bytes), Height) : *Bytes + 4
        PokeA(*Bytes, Channels)       : *Bytes + 1
        PokeA(*Bytes, 0)              : *Bytes + 1
        
        ; --- Image - Data ---
        
        If Flags & #PB_ImageDecoder_ReverseY
          *Pixel = *Buffer + LinePitch * (Height - 1)
          LinePitch  = -LinePitch
        Else
          *Pixel = *Buffer
        EndIf 

        PX\RGBA\R = 0
        PX\RGBA\G = 0
        PX\RGBA\B = 0
        PX\RGBA\A = 255
        
        prevPX\RGBA\R = 0
        prevPX\RGBA\G = 0
        prevPX\RGBA\B = 0
        prevPX\RGBA\A = 255
        
        While Pixel_Pos < Pixel_Len
          
          *Pixels = *Pixel + Row_Pos
          
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

      		  Index_Pos = (PX\RGBA\R * 3 + PX\RGBA\G * 5 + PX\RGBA\B * 7 + PX\RGBA\A * 11) % 64
      		  
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
		
      		Pixel_Pos + Channels
      		Row_Pos   + Channels
      		
      		If Row_Pos >= Row_Len
            *Pixel + LinePitch 
            Row_Pos = 0
          EndIf
      		
        Wend  
        
        ; --- Footer ---
        
        For i = 0 To 7
      	  *Bytes\a = QOI_Padding(i) : *Bytes + 1
      	Next
        
        ImageSize = *Bytes - *Memory
        
        If *Filename
          
          FileID = CreateFile(#PB_Any, FileName, )
          If FileID
            Result = WriteData(FileID, *Bytes, ImageSize)
            CloseFile(FileID)
          EndIf   
          
          ProcedureReturn Result
        Else
          ProcedureReturn ReAllocateMemory(*Memory, ImageSize)
        EndIf  

      EndIf
    EndProcedure
    
  CompilerEndIf
  
  ;- ======================================================
  ;-   Image -Decoder
  ;- ======================================================  
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows ;{ Windows
  
    Procedure   CleanupQOI_(*Globals.PB_ImageDecoderGlobals)
      
      If *Globals\Mode = #PB_ImageDecoder_File And *Globals\Buffer
        FreeMemory(*Globals\Buffer) : *Globals\Buffer = #Null : *Globals\Length = 0
      EndIf
    
    EndProcedure
    
    Procedure.i CheckQOI_(*Globals.PB_ImageDecoderGlobals)
      Define.i FileID
      Define   *Pointer
      
      If *Globals\Mode = #PB_ImageDecoder_File    ;{ File Mode
        
        FileID = ReadFile(#PB_Any, PeekS(*Globals\Filename, -1, #PB_UTF8))
        If FileID
          
          *Globals\Length = Lof(FileID)
          
          If *Globals\Length >= #QOI_Header_Size
            
            *Globals\Buffer = AllocateMemory(*Globals\Length, #PB_Memory_NoClear)
            If *Globals\Buffer
              
              ; --- Read Header ---
              ReadData(FileID, *Globals\Buffer, #QOI_Header_Size)
              
              *Pointer = *Globals\Buffer
              
              Header\Magic = PeekS(*Pointer, 4, #PB_Ascii)
              
              If Header\Magic = #QOI_Magic
                
                *Pointer + 4
                
                Header\Width      = uint32(PeekL(*Pointer)) : *Pointer + 4
                Header\Height     = uint32(PeekL(*Pointer)) : *Pointer + 4
                Header\Channels   = PeekA(*Pointer)         : *Pointer + 1
                Header\Colorspace = PeekA(*Pointer)         : *Pointer + 1
                
                *Globals\Width  = Header\Width
                *Globals\Height = Header\Height
                
                ; --- Image Data ---
                If *Globals\Width And *Globals\Height
                  ReadData(FileID, *Globals\Buffer + #QOI_Header_Size, *Globals\Length - #QOI_Header_Size)
                Else
                  CleanupQOI_(*Globals)
                EndIf
                
              EndIf
              
            EndIf
            
          EndIf

          CloseFile(FileID)
        EndIf
        ;}
      ElseIf *Globals\Length >= #QOI_Header_Size  ;{ Memory Mode
        
        *Pointer = *Globals\Buffer
        
        Header\Magic      = PeekS(*Pointer, 4, #PB_Ascii) : *Pointer + 4
        Header\Width      = uint32(PeekL(*Pointer))       : *Pointer + 4
        Header\Height     = uint32(PeekL(*Pointer))       : *Pointer + 4
        Header\Channels   = PeekA(*Pointer)               : *Pointer + 1
        Header\Colorspace = PeekA(*Pointer)               : *Pointer + 1
        
        *Globals\Width    = Header\Width
        *Globals\Height   = Header\Height
        ;}
      EndIf
      
      If *Globals\Width And *Globals\Height
        *Globals\Depth         = 32
        *Globals\OriginalDepth = Header\Channels * 8
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
      
    EndProcedure

    Procedure.i DecodeQOI_(*Globals.PB_ImageDecoderGlobals, *Buffer, Pitch.l, Flags.l)
      Define   *Bytes.Ascii
      Define   PX.RGBA_T_Structure, *Pixels.RGBA_DB_Structure, *Pixel.RGBA_DB_Structure
      Define.i Byte1, Byte2, VG, Run = 0
      Define.i Hash, Pixel_Pos, Chunks_Len, Channels, Row_Len
      
      Dim Index.RGBA_T_Structure(63)
      
      Channels   = *Globals\Depth / 8  
      Chunks_Len = *Globals\Length - #QOI_FOOTER_SIZE
      Row_Len   = (*Globals\Width * Channels)
      
      If Flags & #PB_ImageDecoder_ReverseY
        *Pixel = *Buffer + Pitch * (*Globals\Height - 1)
        Pitch  = -Pitch
      Else
        *Pixel = *Buffer
      EndIf  

      PX\RGBA\R = 0
      PX\RGBA\G = 0
      PX\RGBA\B = 0
      PX\RGBA\A = 255
      
      *Bytes = *Globals\Buffer + #QOI_Header_Size
      
      While *Bytes < Chunks_Len + *Globals\Buffer
        
        If Run > 0
          Run - 1
        ElseIf *Bytes < Chunks_Len + *Globals\Buffer
          
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
          
          Hash = (PX\RGBA\R * 3 + PX\RGBA\G * 5 + PX\RGBA\B * 7 + PX\RGBA\A * 11)
          Index(Hash % 64)\V = PX\V
          
        EndIf

        *Pixels = *Pixel + Pixel_Pos 

        If Channels = 4
          *Pixels\R = PX\RGBA\R
          *Pixels\G = PX\RGBA\G
          *Pixels\B = PX\RGBA\B
          *Pixels\A = PX\RGBA\A
        Else
          *Pixels\R = PX\RGBA\R
          *Pixels\G = PX\RGBA\G
          *Pixels\B = PX\RGBA\B
        EndIf  
        
        Pixel_Pos + Channels
        
        If Pixel_Pos >= Row_Len
          *Pixel + Pitch 
          Pixel_Pos = 0
        EndIf

      Wend 

      CleanupQOI_(*Globals)
      
      ProcedureReturn #True
    EndProcedure
    ;}
  CompilerElse ;{ MacOS / Linux
    
    ProcedureC   CleanupQOI_(*Globals.PB_ImageDecoderGlobals)
      
      If *Globals\Mode = #PB_ImageDecoder_File And *Globals\Buffer
        FreeMemory(*Globals\Buffer) : *Globals\Buffer = #Null : *Globals\Length = 0
      EndIf
    
    EndProcedure
    
    ProcedureC.i CheckQOI_(*Globals.PB_ImageDecoderGlobals)
      Define.i FileID
      Define   *Pointer
      
      If *Globals\Mode = #PB_ImageDecoder_File    ;{ File Mode
        
        FileID = ReadFile(#PB_Any, PeekS(*Globals\Filename, -1, #PB_UTF8))
        If FileID
          
          *Globals\Length = Lof(FileID)
          
          If *Globals\Length >= #QOI_Header_Size
            
            *Globals\Buffer = AllocateMemory(*Globals\Length, #PB_Memory_NoClear)
            If *Globals\Buffer
              
              ; --- Read Header ---
              ReadData(FileID, *Globals\Buffer, #QOI_Header_Size)
              
              *Pointer = *Globals\Buffer
              
              Header\Magic = PeekS(*Pointer, 4, #PB_Ascii)
              
              If Header\Magic = #QOI_Magic
                
                *Pointer + 4
                
                Header\Width      = uint32(PeekL(*Pointer)) : *Pointer + 4
                Header\Height     = uint32(PeekL(*Pointer)) : *Pointer + 4
                Header\Channels   = PeekA(*Pointer)         : *Pointer + 1
                Header\Colorspace = PeekA(*Pointer)         : *Pointer + 1
                
                *Globals\Width  = Header\Width
                *Globals\Height = Header\Height
                
                ; --- Image Data ---
                If *Globals\Width And *Globals\Height
                  ReadData(FileID, *Globals\Buffer + #QOI_Header_Size, *Globals\Length - #QOI_Header_Size)
                Else
                  CleanupQOI_(*Globals)
                EndIf
                
              EndIf
              
            EndIf
            
          EndIf

          CloseFile(FileID)
        EndIf
        ;}
      ElseIf *Globals\Length >= #QOI_Header_Size  ;{ Memory Mode
        
        *Pointer = *Globals\Buffer
        
        Header\Magic      = PeekS(*Pointer, 4, #PB_Ascii) : *Pointer + 4
        Header\Width      = uint32(PeekL(*Pointer))       : *Pointer + 4
        Header\Height     = uint32(PeekL(*Pointer))       : *Pointer + 4
        Header\Channels   = PeekA(*Pointer)               : *Pointer + 1
        Header\Colorspace = PeekA(*Pointer)               : *Pointer + 1
        
        *Globals\Width    = Header\Width
        *Globals\Height   = Header\Height
        ;}
      EndIf
      
      If *Globals\Width And *Globals\Height
        *Globals\Depth         = 32
        *Globals\OriginalDepth = Header\Channels * 8
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
      
    EndProcedure
    
    ProcedureC.i DecodeQOI_(*Globals.PB_ImageDecoderGlobals, *Buffer, Pitch.l, Flags.l)
      Define   *Bytes.Ascii
      Define   PX.RGBA_T_Structure, *Pixels.RGBA_DB_Structure, *Pixel.RGBA_DB_Structure
      Define.i Byte1, Byte2, VG, Run = 0
      Define.i Hash, Pixel_Pos, Chunks_Len, Channels, Row_Len
      
      Dim Index.RGBA_T_Structure(63)
      
      Channels   = *Globals\Depth / 8  
      Chunks_Len = *Globals\Length - #QOI_FOOTER_SIZE
      Row_Len   = (*Globals\Width * Channels)
      
      If Flags & #PB_ImageDecoder_ReverseY
        *Pixel = *Buffer + Pitch * (*Globals\Height - 1)
        Pitch  = -Pitch
      Else
        *Pixel = *Buffer
      EndIf  

      PX\RGBA\R = 0
      PX\RGBA\G = 0
      PX\RGBA\B = 0
      PX\RGBA\A = 255
      
      *Bytes = *Globals\Buffer + #QOI_Header_Size
      
      While *Bytes < Chunks_Len + *Globals\Buffer
        
        If Run > 0
          Run - 1
        ElseIf *Bytes < Chunks_Len + *Globals\Buffer
          
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
          
          Hash = (PX\RGBA\R * 3 + PX\RGBA\G * 5 + PX\RGBA\B * 7 + PX\RGBA\A * 11)
          Index(Hash % 64)\V = PX\V
          
        EndIf

        *Pixels = *Pixel + Pixel_Pos 

        If Channels = 4
          *Pixels\R = PX\RGBA\R
          *Pixels\G = PX\RGBA\G
          *Pixels\B = PX\RGBA\B
          *Pixels\A = PX\RGBA\A
        Else
          *Pixels\R = PX\RGBA\R
          *Pixels\G = PX\RGBA\G
          *Pixels\B = PX\RGBA\B
        EndIf  
        
        Pixel_Pos + Channels
        
        If Pixel_Pos >= Row_Len
          *Pixel + Pitch 
          Pixel_Pos = 0
        EndIf

      Wend 

      CleanupQOI_(*Globals)
      
      ProcedureReturn #True
    EndProcedure
    ;}
  CompilerEndIf
  
  ;- ======================================================
	;-   Module - Declared Procedures
	;- ======================================================
  
  Procedure UseImageDecoder()
    Static DecoderQOI.PB_ImageDecoder, Registered
    If Not Registered
      DecoderQOI\ID       = #PB_ImagePlugin
      DecoderQOI\Check    = @CheckQOI_()
      DecoderQOI\Cleanup  = @CleanupQOI_()
      DecoderQOI\Decode   = @DecodeQOI_()
      PB_ImageDecoder_Register(DecoderQOI)
      Registered = #True
    EndIf
    ProcedureReturn Registered
  EndProcedure
  
  Procedure UseImageEncoder()
    Static EncoderQOI.PB_ImageEncoder, Registered
    If Not Registered
      EncoderQOI\ID       = #PB_ImagePlugin
      EncoderQOI\Encode24 = @EncodeQOI_()
      EncoderQOI\Encode32 = @EncodeQOI_()
      PB_ImageEncoder_Register(EncoderQOI)
      Registered = #True
    EndIf
    ProcedureReturn Registered
  EndProcedure
  
EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 0
  
  ; 0: Load QOI-Image
  ; 1: Save image as QOI
  
  Enumeration 1 ;{
    #Window
    #Gadget
    #Image
    #File
  EndEnumeration ;}

  Select #Example
    Case 1  ;{ Save image as QOI
      
      UsePNGImageDecoder()
      QOIF::UseImageEncoder()
      
      File$ = "TestCard.png"
      
      If LoadImage(#Image, File$)
        SaveImage(#Image, ReplaceString(File$, ".png", ".qoi"), QOIF::#PB_ImagePlugin)
      EndIf
      ;}
    Default ;{ Load QOI-Image
      
      QOIF::UseImageDecoder()
      
      If OpenWindow(#Window, 0, 0, 532, 532, " Example - Quite OK Image", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        
        File$ = "baboon.qoi"
        
        If LoadImage(#Image, File$)
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
; IDE Options = PureBasic 6.00 Beta 9 (Windows - x64)
; CursorPosition = 845
; FirstLine = 186
; Folding = 9QAVPw-
; EnableXP
; DPIAware