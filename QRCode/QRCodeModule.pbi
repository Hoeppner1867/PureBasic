;/ ============================
;/ =    QRCodeModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x - V6x / 64Bit / All OS / DPI ]
;/
;/ Based on the code of infratec (2020)
;/ 
;/ © 2022  by Thorsten Hoeppner (05/2022)
;/

; Last Update: 21.05.2022
; 
; Added: Decode QRCodes (image)
;


;{ ===== MIT License =====
;
; Copyright (c) 2010-2012 Daniel Beer (quirc library)
;
; Copyright (c) 2020 Project Nayuki
; https://www.nayuki.io/page/qr-code-generator-library
; 
; Copyright (c) 2020 infratec (Converted To PB)
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


;{ _____ QRCode - Commands _____

; ----- Image -----
; QRCode::Create()             - Create an image with the QRCode
; QRCode::SetDefaults()        - Change defaults for Create()

; ----- Gadget -----
; QRCode::Gadget()             - Gadget for QRCodes

; QRCode::GetText()            - similar to 'GetGadgetText()'
; QRCode::GetColor()           - similar to 'GetGadgetColor()'

; QRCode::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]

; QRCode::SetAttribute()       - similar to 'SetGadgetAttribute()'
; QRCode::SetColor()           - similar to 'SetGadgetColor()'
; QRCode::SetText()            - similar to 'SetGadgetText()'

; ----- Decode -----
; QRCode::Decode()              - decodes an image with QRCode

;}


DeclareModule QRCode
  
  #Version  = 22052000
  #ModuleEx = 19120100
  
  #Enable_Gadget = #True  ; needs #Enable_Generate_QRCodes
  
  #Enable_Generate_QRCodes   = #True
  #Enable_Decode_QRCodes     = #True
  
  ;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  EnumerationBinary       ;{ Gadget Flags
    #Code_39
    #UPC_A
    #Label
    #AutoResize
    #MoveX
		#MoveY
		#Width
		#Height
		#Border
		#Raised
		#DumpCells
		#DumpData
		#Quiet
  EndEnumeration ;}
  
  Enumeration 1           ;{ Gadget Color
    #FrontColor
    #BackColor
    #TextColor
  EndEnumeration ;}
  
  Enumeration 1           ;{ Gadget Attribute
    #ErrCorLvl
	  #BoostEcl
	  #MinVersion
	  #MaxVersion
	  #Mask
	  #QuietZone
  EndEnumeration ;}
  
  
  CompilerIf #Enable_Generate_QRCodes
  
    Enumeration QRCode_ECC  ;{ 
      ; Must be declared in ascending order of error protection
      ; so that an internal QRCode function works properly
      #Ecc_LOW      ; The QR Code can tolerate about  7% erroneous codewords
      #Ecc_MEDIUM   ; The QR Code can tolerate about 15% erroneous codewords
      #Ecc_QUARTILE ; The QR Code can tolerate about 25% erroneous codewords
      #Ecc_HIGH     ; The QR Code can tolerate about 30% erroneous codewords
    EndEnumeration ;}
    
    Enumeration QRCode_Mask ;{ 
      ; A special value To tell the QR Code encoder To
      ; automatically Select an appropriate mask pattern
      #Mask_AUTO = -1
      ; The eight actual mask patterns
      #Mask_0 = 0
      #Mask_1
      #Mask_2
      #Mask_3
      #Mask_4
      #Mask_5
      #Mask_6
      #Mask_7
    EndEnumeration ;}
    
    #VERSION_MIN = 1  ; The minimum version number supported in the QR Code Model 2 standard
    #VERSION_MAX = 40 ; The maximum version number supported in the QR Code Model 2 standard
    
    Structure Ascii_Structure
      a.a[0]
    EndStructure
  
    ; Calculates the number of bytes needed To store any QR Code up To And including the given version number,
    ; As a compile-time constant. For example, 'uint8_t buffer[QRCode_BUFFER_LEN_FOR_VERSION(25)];'
    ; can store any single QR Code from version 1 To 25 (inclusive). The result fits in an Int (Or int16).
    ; Requires QRCode_VERSION_MIN <= n <= QRCode_VERSION_MAX.
    Macro BUFFER_LEN_FOR_VERSION(n)
      ((((n) * 4 + 17) * ((n) * 4 + 17) + 7) / 8 + 1)
    EndMacro
    
    ; The worst-Case number of bytes needed To store one QR Code, up To And including
    ; version 40. This value equals 3918, which is just under 4 kilobytes.
    ; Use this more convenient value To avoid calculating tighter memory bounds For buffers.
    #BUFFER_LEN_MAX = BUFFER_LEN_FOR_VERSION(#VERSION_MAX)
    
  CompilerEndIf
  
  
	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
  
  CompilerIf #Enable_Generate_QRCodes
  
    Declare.i Create(ImageNum.i, Text.s, Width.i=#PB_Default, Height.i=#PB_Default)
    Declare   SetDefaults(ErrCorLvl.i=#Ecc_LOW, BoostEcl.i=#True, MinVersion.i=#VERSION_MIN, MaxVersion.i=#VERSION_MAX, Mask.i=#Mask_AUTO, QuietZone.i=2)
    
    CompilerIf #Enable_Gadget
      
      Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
      
      Declare.s GetText(GNum.i)
      Declare.i GetColor(GNum.i, ColorTyp.i)
      
      Declare   SetText(GNum.i, Text.s, Flags.i=#Code_39)
      Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
      
      Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
      
      Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  
    CompilerEndIf
    
  CompilerEndIf
  
  CompilerIf #Enable_Decode_QRCodes
    
    Declare.s Decode(Image.i, Flags.i=#False)
    
  CompilerEndIf  
  
EndDeclareModule 


Module QRCode
  
  EnableExplicit
  
  ;- ============================================================================
	;- Module - Structures
	;- ============================================================================  
  
  CompilerIf #Enable_Generate_QRCodes
  
    #INT16_MAX = $7fff
    #SIZE_MAX  = $ffffffff
    #LONG_MAX  = $7fffffff
    
    Enumeration QRCode_Mode
      #Mode_NUMERIC      = $1
      #Mode_ALPHANUMERIC = $2
      #Mode_BYTE         = $4
      #Mode_KANJI        = $8
      #Mode_ECI          = $7
    EndEnumeration
  
    #REED_SOLOMON_DEGREE_MAX = 30
    #ALPHANUMERIC_CHARSET$   = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:" + #DQUOTE$ + ";"
    
    ; For automatic mask pattern selection.
    #PENALTY_N1 =  3
    #PENALTY_N2 =  3
    #PENALTY_N3 = 40
    #PENALTY_N4 = 10
    
  CompilerEndIf
  
  CompilerIf #Enable_Decode_QRCodes
    
    #UINT8_MAX  = $FF
    #UINT16_MAX = $FFFF
    #INT_MAX    = $7FFF
    
    #MAX_POLY   = 64
    
    #FORMAT_MAX_ERROR = 3
    #FORMAT_SYNDROMES = (#FORMAT_MAX_ERROR * 2)
    #FORMAT_BITS      = 15
    
    #FLOOD_FILL_MAX_DEPTH = 4096
    
    CompilerIf Not Defined(QUIRC_MAX_REGIONS, #PB_Constant)
      #QUIRC_MAX_REGIONS = 254
    CompilerEndIf
    
    #QUIRC_MAX_CAPSTONES = 32
    #QUIRC_MAX_GRIDS     = 8
    #QUIRC_PERSPECTIVE_PARAMS = 8
    
    CompilerIf Not Defined(QUIRC_MAX_REGIONS, #PB_Constant)
      #QUIRC_MAX_REGIONS = 254
    CompilerEndIf
    
    CompilerIf #QUIRC_MAX_REGIONS < #UINT8_MAX
      #QUIRC_PIXEL_ALIAS_IMAGE = #True
      Macro quirc_pixel_ptr
        Ascii
      EndMacro
      Macro quirc_pixel_type
        a
      EndMacro
      Macro quirc_pixel_array
        AsciiArrayStructure
      EndMacro
    CompilerElseIf #QUIRC_MAX_REGIONS < #UINT16_MAX
      #QUIRC_PIXEL_ALIAS_IMAGE = #False
      Macro quirc_pixel_ptr
        Unicode
      EndMacro
      Macro quirc_pixel_type
        u
      EndMacro
      Macro quirc_pixel_array
        UnicodeArrayStructure
      EndMacro
    CompilerElse
      CompilerError "QUIRC_MAX_REGIONS > 65534 is not supported"
    CompilerEndIf
    
    ; Limits on the maximum size of QR-codes And their content.
    #QUIRC_MAX_VERSION   = 40
    #QUIRC_MAX_GRID_SIZE = (#QUIRC_MAX_VERSION * 4 + 17)
    #QUIRC_MAX_BITMAP    = (((#QUIRC_MAX_GRID_SIZE * #QUIRC_MAX_GRID_SIZE) + 7) / 8)
    #QUIRC_MAX_PAYLOAD   = 8896
    #QUIRC_MAX_ALIGNMENT = 7
    
    #QUIRC_PIXEL_WHITE  = 0
    #QUIRC_PIXEL_BLACK  = 1
    #QUIRC_PIXEL_REGION = 2
    
    ; QR-code Data types.
    #QUIRC_DATA_TYPE_NUMERIC = 1
    #QUIRC_DATA_TYPE_ALPHA   = 2
    #QUIRC_DATA_TYPE_BYTE    = 4
    #QUIRC_DATA_TYPE_KANJI   = 8
    
    ; QR-code ECC types.
    #QUIRC_ECC_LEVEL_M = 0
    #QUIRC_ECC_LEVEL_L = 1
    #QUIRC_ECC_LEVEL_H = 2
    #QUIRC_ECC_LEVEL_Q = 3
    
    ; Common character encodings
    #QUIRC_ECI_ISO_8859_1  =  1
    #QUIRC_ECI_IBM437      =  2
    #QUIRC_ECI_ISO_8859_2  =  4
    #QUIRC_ECI_ISO_8859_3  =  5
    #QUIRC_ECI_ISO_8859_4  =  6
    #QUIRC_ECI_ISO_8859_5  =  7
    #QUIRC_ECI_ISO_8859_6  =  8
    #QUIRC_ECI_ISO_8859_7  =  9
    #QUIRC_ECI_ISO_8859_8  = 10
    #QUIRC_ECI_ISO_8859_9  = 11
    #QUIRC_ECI_WINDOWS_874 = 13
    #QUIRC_ECI_ISO_8859_13 = 15
    #QUIRC_ECI_ISO_8859_15 = 17
    #QUIRC_ECI_SHIFT_JIS   = 20
    #QUIRC_ECI_UTF_8       = 26
    
    ; This enum describes the various decoder errors which may occur.
    Enumeration
      #QUIRC_SUCCESS = 0
      #QUIRC_ERROR_INVALID_GRID_SIZE
      #QUIRC_ERROR_INVALID_VERSION
      #QUIRC_ERROR_FORMAT_ECC
      #QUIRC_ERROR_DATA_ECC
      #QUIRC_ERROR_UNKNOWN_DATA_TYPE
      #QUIRC_ERROR_DATA_OVERFLOW
      #QUIRC_ERROR_DATA_UNDERFLOW
    EndEnumeration

  CompilerEndIf  
  
  ;- =================================================
	;-   Module - Structures & Global
	;- =================================================
  
  CompilerIf #Enable_Generate_QRCodes
  
    Structure Segment_Structure ;{
      ; The mode indicator of this segment.
      mode.i
     
      ; The length of this segment's unencoded data. Measured in characters for
      ; numeric/alphanumeric/kanji mode, bytes For byte mode, And 0 For ECI mode.
      ; Always zero Or positive. Not the same As the Data's bit length.
      numChars.i
     
      ; The Data bits of this segment, packed in bitwise big endian.
      ; Can be null If the bit length is zero.
      *data.Ascii_Structure
     
      ; The number of valid Data bits used in the buffer. Requires
      ; 0 <= bitLength <= 32767, And bitLength <= (capacity of Data Array) * 8.
      ; The character count (numChars) must agree With the mode And the bit buffer length.
      bitLength.i
      ;}
    EndStructure
    
  CompilerEndIf
  
  CompilerIf #Enable_Decode_QRCodes
    
    Prototype span_func_t(*user_data, y.i, left.i, right.i)
    

    Structure rgba           ;{
      b.a
      g.a
      r.a
      a.a
    EndStructure ;}
  
    Structure AsciiArrayStructure ;{ Array Structures
      v.a[0]
    EndStructure
    
    Structure UnicodeArrayStructure
      v.u[0]
    EndStructure
    
    Structure IntegerArrayStructure
      v.i[0]
    EndStructure
    
    Structure DoubleArrayStructure
      v.d[0]
    EndStructure ;}
    
    Structure datastream  ;{
      raw.a[#QUIRC_MAX_PAYLOAD]
      data_bits.i
      ptr.i
      
      Data_.a[#QUIRC_MAX_PAYLOAD]
    EndStructure ;}
    
    Structure galois_field ;{
      p.i
      *log.AsciiArrayStructure
      *exp.AsciiArrayStructure
    EndStructure ;}
    
    
    Structure neighbour ;{
      index.i
      distance.d
    EndStructure ;}
  
    Structure neighbour_list ;{
      n.neighbour[#QUIRC_MAX_CAPSTONES]
      count.i
    EndStructure ;}
    
    
    Structure quirc_rs_params ;{
      bs.a  ; Small block size
      dw.a  ; Small data words
      ns.a  ; Number of small blocks
    EndStructure ;}
    
    Structure quirc_version_info ;{
      data_bytes.u
      apat.a[#QUIRC_MAX_ALIGNMENT]
      ecc.quirc_rs_params[4]
    EndStructure ;}
    
    Structure quirc_data     ;{
      ; This Structure holds the decoded QR-code Data
      ; Various parameters of the QR-code. These can mostly be
      ; ignored If you only care about the Data.
      version.i
      ecc_level.i
      mask.i
      
      ; This field is the highest-valued Data type found in the QR
      ; code.
      data_type.i
      
      ; Data payload. For the Kanji datatype, payload is encoded As
      ; Shift-JIS. For all other datatypes, payload is ASCII text.
      payload.a[#QUIRC_MAX_PAYLOAD]
      payload_len.i
      
      ; ECI assignment number
      eci.l
    EndStructure ;}
    
    Structure quirc_point    ;{
      x.i
      y.i
    EndStructure ;}  
    
    Structure quirc_pointArrayStructure ;{
      v.quirc_point[0]
    EndStructure ;}
    
    Structure quirc_code     ;{
      ; This Structure is used To Return information about detected QR codes
      ; in the input image.
      ; The four corners of the QR-code, from top left, clockwise
      corners.quirc_point[4]
      
      ; The number of cells across in the QR-code. The cell bitmap
      ; is a bitmask giving the actual values of cells. If the cell
      ; at (x, y) is black, then the following bit is set:
      ;
      ;     cell_bitmap(i >> 3) & (1 << (i & 7))
      ;
      ; where i = (y * size) + x.
      size.i
      cell_bitmap.a[#QUIRC_MAX_BITMAP]
    EndStructure ;}
    
    Structure quirc_grid     ;{
      ; Capstone indices
      caps.i[3]
      
      ; Alignment pattern region And corner
      align_region.i
      align.quirc_point
      
      ; Timing pattern endpoints
      tpep.quirc_point[3]
      hscan.i
      vscan.i
      
      ; Grid size And perspective transform
      grid_size.i
      c.d[#QUIRC_PERSPECTIVE_PARAMS]
    EndStructure ;}
  
    Structure quirc_capstone ;{
      ring.i
      stone.i
      
      corners.quirc_point[4]
      center.quirc_point
      c.d[#QUIRC_PERSPECTIVE_PARAMS]
      
      qr_grid.i
    EndStructure ;}
   
    Structure quirc_region   ;{
      seed.quirc_point
      count.i
      capstone.i
    EndStructure ;}
    
    Structure quirc          ;{
      *image.Ascii
      *pixels.quirc_pixel_array
      w.i
      h.i
      
      num_regions.i
      regions.quirc_region[#QUIRC_MAX_REGIONS]
      
      num_capstones.i
      capstones.quirc_capstone[#QUIRC_MAX_CAPSTONES]
      
      num_grids.i
      grids.quirc_grid[#QUIRC_MAX_GRIDS]
    EndStructure ;}
    
    Structure polygon_score_data ;{
      ref.quirc_point
      
      scores.i[4]
      corners.quirc_point[4]
    EndStructure ;}
    
    
    Global gf16.galois_field
    gf16\p = 15
    gf16\exp = ?gf16_exp
    gf16\log = ?gf16_log
    
    Global gf256.galois_field
    gf256\p = 255
    gf256\exp = ?gf256_exp
    gf256\log = ?gf256_log
  
  CompilerEndIf 
  
  
  Structure QRCode_Color_Structure  ;{ QRCode()\Color\...
		Front.i
		Back.i
		Gadget.i
	EndStructure  ;}
  
  Structure QRCode_Size_Structure   ;{ QRCode()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}
	
  Structure QRCode_Structure        ;{ QRCode()\...
    
    Window.i
    Gadget.i
    Image.i
    
	  WinWidth.i
	  WinHeight.i
	  
	  Text.s
	  
	  Hide.i
	  Flags.i
	  
	  ErrCorLvl.i
	  BoostEcl.i
	  MinVersion.i
	  MaxVersion.i
	  Mask.i
	  QuietZone.i
	  
	  Color.QRCode_Color_Structure
	  Size.QRCode_Size_Structure
	  
	EndStructure ;}
	Global NewMap QRCode.QRCode_Structure() 
  

  ;- ============================================================================
	;- Module - Internal
	;- ============================================================================
	
	CompilerIf #Enable_Generate_QRCodes
	
  	CompilerIf #Enable_Gadget
  	
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
    
    	CompilerEndIf
    	
      CompilerIf Defined(ModuleEx, #PB_Module)
        
        Procedure.i GetGadgetWindow()
          ProcedureReturn ModuleEx::GetGadgetWindow()
        EndProcedure
        
      CompilerElse  
        
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          ; Thanks to mk-soft
          Import ""
            PB_Object_EnumerateStart(PB_Objects)
            PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
            PB_Object_EnumerateAbort( PB_Objects )
            PB_Window_Objects.i
          EndImport
        CompilerElse
          ImportC ""
            PB_Object_EnumerateStart( PB_Objects )
            PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
            PB_Object_EnumerateAbort( PB_Objects )
            PB_Window_Objects.i
          EndImport
        CompilerEndIf
        
        Procedure.i GetGadgetWindow()
          ; Thanks to mk-soft
          Define.i WindowID, Window, Result = #PB_Default
          
          WindowID = UseGadgetList(0)
          
          PB_Object_EnumerateStart(PB_Window_Objects)
          
          While PB_Object_EnumerateNext(PB_Window_Objects, @Window)
            If WindowID = WindowID(Window)
              Result = Window
              Break
            EndIf
          Wend
          
          PB_Object_EnumerateAbort(PB_Window_Objects)
          
          ProcedureReturn Result
        EndProcedure
        
      CompilerEndIf		
    	
    	Procedure.i dpiX(Num.i)
    	  ProcedureReturn DesktopScaledX(Num) 
    	EndProcedure
    
    	Procedure.i dpiY(Num.i)
    	  ProcedureReturn DesktopScaledY(Num)
    	EndProcedure
    	
    CompilerEndIf

  	;- QRCode - Generation
  	
    Procedure.i getSize(*QRCode.Ascii_Structure)
      Protected result.i
  
      ;assert(qrcode != NULL);
      result = *QRCode\a[0]
      ;assert((QRCode_VERSION_MIN * 4 + 17) <= result   && result <= (QRCode_VERSION_MAX * 4 + 17));
     
      ProcedureReturn result
    EndProcedure
  
    Procedure.i getBit(x.i, i.i)
      ; Returns true iff the i'th bit of x is set to 1. Requires x >= 0 and 0 <= i <= 14.
      ProcedureReturn Bool(((x >> i) & 1) <> 0)
    EndProcedure
    
    
    Procedure.i internal_getModule(*QRCode.Ascii_Structure, x.i, y.i)
      ; Gets the module at the given coordinates, which must be in bounds.
      Protected QRSize.i, index.i
     
      QRSize = *QRCode\a[0]
      ;assert(21 <= QRSize && QRSize <= 177 && 0 <= x && x < QRSize && 0 <= y && y < QRSize);
      index = y * QRSize + x
     
      ProcedureReturn getBit(*QRCode\a[(index >> 3) + 1], index & 7)
    EndProcedure
    
    Procedure.i getModule(*QRCode.Ascii_Structure, x.i, y.i)
      Protected QRSize.i
  
      ;assert(qrcode != NULL);
      QRSize = *QRCode\a[0]
     
      ProcedureReturn Bool((0 <= x And x < QRSize And 0 <= y And y < QRSize) And internal_getModule(*QRCode, x, y))
    EndProcedure
    
    
    Procedure   setModule(*QRCode.Ascii_Structure, x.i, y.i, isBlack.i)
      ; Sets the module at the given coordinates, which must be in bounds.
      Protected QRSize.i, index.i, bitIndex.i, byteIndex.i
     
      QRSize = *QRCode\a[0]
      ;assert(21 <= QRSize && QRSize <= 177 && 0 <= x && x < QRSize && 0 <= y && y < QRSize);
      index = y * QRSize + x
      bitIndex = index & 7
      byteIndex = (index >> 3) + 1
      If isBlack
        *QRCode\a[byteIndex] = *QRCode\a[byteIndex] | (1 << bitIndex)
      Else
        *QRCode\a[byteIndex] = *QRCode\a[byteIndex] & ((1 << bitIndex) ! $FF)
      EndIf
     
    EndProcedure
   
    Procedure   setModuleBounded(*QRCode.Ascii_Structure, x.i, y.i, isBlack.i)
      ; Sets the module at the given coordinates, doing nothing if out of bounds.
      Protected QRSize.i
  
      QRSize = *QRCode\a[0]
      If 0 <= x And x < QRSize And 0 <= y And y < QRSize
        setModule(*QRCode, x, y, isBlack)
      EndIf
     
    EndProcedure
    
    
    Procedure.i getAlignmentPatternPositions(version.i, Array result.a(1))
      ; Calculates And stores an ascending List of positions of alignment patterns
      ; For this version number, returning the length of the List (in the range [0,7]).
      ; Each position is in the range [0,177), And are used on both the x And y axes.
      ; This could be implemented As lookup table of 40 variable-length lists of unsigned bytes.
      Protected numAlign.i, Stepi.i, i.i, pos.i
     
      If version <> 1
       
        numAlign = version / 7 + 2
        If version = 32
          Stepi = 26
        Else
          Stepi = (version*4 + numAlign*2 + 1) / (numAlign*2 - 2) * 2
        EndIf
        ;For (int i = numAlign - 1, pos = version * 4 + 10; i >= 1; i--, pos -= step)
        pos = version * 4 + 10
        For i = numAlign - 1 To 1 Step -1
          result(i) = pos
          pos - stepi
        Next i
        result(0) = 6
      EndIf
     
      ProcedureReturn numAlign
    EndProcedure
    
    
    Procedure   applyMask(*functionModules.Ascii_Structure, *QRCode.Ascii_Structure, mask.i)
      ; XORs the codeword modules in this QR Code With the given mask pattern.
      ; The function modules must be marked And the codeword bits must be drawn
      ; before masking. Due To the arithmetic of XOr, calling applyMask() With
      ; the same mask value a second time will undo the mask. A final well-formed
      ; QR Code needs exactly one (Not zero, two, etc.) mask applied.
      Protected QRSize.i, x.i, y.i, invert.i, val.i
  
      ;assert(0 <= (int)mask && (int)mask <= 7);  // Disallows QRCode_Mask_AUTO
      QRSize = getSize(*QRCode)
      For y = 0 To QRSize - 1
        For x = 0 To QRSize - 1
          If internal_getModule(*functionModules, x, y)
            Continue
          EndIf
          Select mask
            Case 0:  invert = Bool((x + y) % 2 = 0)
            Case 1:  invert = Bool(y % 2 = 0)
            Case 2:  invert = Bool(x % 3 = 0)
            Case 3:  invert = Bool((x + y) % 3 = 0)
            Case 4:  invert = Bool((x / 3 + y / 2) % 2 = 0)
            Case 5:  invert = Bool((x * y) % 2 + (x * y) % 3 = 0)
            Case 6:  invert = Bool(((x * y) % 2 + (x * y) % 3) % 2 = 0)
            Case 7:  invert = Bool(((x + y) % 2 + (x * y) % 3) % 2 = 0)
            Default:
              ;assert(false);
              ;Return       ;
              Break 2
          EndSelect         
          val = internal_getModule(*QRCode, x, y)
          setModule(*QRCode, x, y, val ! invert)
        Next x
      Next y
     
    EndProcedure
    
  
    Procedure   finderPenaltyAddHistory(currentRunLength.i, Array runHistory.i(1), QRSize.i)
      ; Pushes the given value to the front and drops the last value. A helper function for getPenaltyScore().
      Protected i.i
  
      If runHistory(0) = 0
        currentRunLength + QRSize ; Add white border to initial run
      EndIf
      ;memmove(&runHistory[1], &runHistory[0], 6 * SizeOf(runHistory[0]));
      MoveMemory(@runHistory(0), @runHistory(1), 6 * SizeOf(Integer))
      runHistory(0) = currentRunLength
     
    EndProcedure  
    
    Procedure.i finderPenaltyCountPatterns(Array runHistory.i(1), QRSize.i)
      ; Can only be called immediately after a white run is added, And
      ; returns either 0, 1, Or 2. A helper function For getPenaltyScore().
      Protected n.i, core.i, Result.i
     
      n = runHistory(1)
      ;assert(n <= QRSize * 3);
      core = Bool(n > 0 And runHistory(2) = n And runHistory(3) = n * 3 And runHistory(4) = n And runHistory(5) = n)
      ; The maximum QR Code size is 177, hence the black run length n <= 177.
      ; Arithmetic is promoted To int, so n*4 will Not overflow.
      ;Return (core && runHistory[0] >= n * 4 && runHistory[6] >= n ? 1 : 0) + (core && runHistory[6] >= n * 4 && runHistory[0] >= n ? 1 : 0);
      If core And runHistory(0) >= n * 4 And runHistory(6) >= n
        Result + 1
      EndIf
      If core And runHistory(6) >= n * 4 And runHistory(0) >= n
        Result + 1
      EndIf
     
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i finderPenaltyTerminateAndCount(currentRunColor.i, currentRunLength.i, Array runHistory.i(1), QRSize.i)
      ; Must be called at the end of a line (row or column) of modules. A helper function for getPenaltyScore().
      If currentRunColor  ; Terminate black run
        finderPenaltyAddHistory(currentRunLength, runHistory(), QRSize)
        currentRunLength = 0
      EndIf
      currentRunLength + QRSize;  // Add white border to final run
      finderPenaltyAddHistory(currentRunLength, runHistory(), QRSize)
     
      ProcedureReturn finderPenaltyCountPatterns(runHistory(), QRSize)
    EndProcedure  
    
    
    Procedure.i getPenaltyScore(*QRCode.Ascii_Structure)
      ; Calculates And returns the penalty score based on state of the given QR Code's current modules.
      ; This is used by the automatic mask choice algorithm To find the mask pattern that yields the lowest score.
      Protected QRSize.i, result.i, x.i, y.i, runColor.i, runX.i, runY.i, color.i, black.i, total.i, k.i
     
      QRSize = getSize(*QRCode)
     
      ; Adjacent modules in row having same color, And finder-like patterns
      For y = 0 To QRSize - 1
        runColor = #False
        runX = 0
        Dim runHistory.i(7)
        For x = 0 To QRSize - 1
          If internal_getModule(*QRCode, x, y) = runColor
            runX + 1
            If runX = 5
              result + #PENALTY_N1
            ElseIf runX > 5
              result + 1
            EndIf
          Else
            finderPenaltyAddHistory(runX, runHistory(), QRSize)
            If Not runColor
              result + finderPenaltyCountPatterns(runHistory(), QRSize) * #PENALTY_N3
            EndIf
            runColor = internal_getModule(*QRCode, x, y)
            runX = 1
          EndIf
        Next x
        result + finderPenaltyTerminateAndCount(runColor, runX, runHistory(), QRSize) * #PENALTY_N3
      Next y
     
      ; Adjacent modules in column having same color, And finder-like patterns
      For x = 0 To QRSize - 1
        runColor = #False
        runY = 0
        Dim runHistory.i(7)
        For y = 0 To QRSize - 1
          If internal_getModule(*QRCode, x, y) = runColor
            runY + 1
            If runY = 5
              result + #PENALTY_N1
            ElseIf runY > 5
              result + 1
            EndIf
          Else
            finderPenaltyAddHistory(runY, runHistory(), QRSize)
            If Not runColor
              result + finderPenaltyCountPatterns(runHistory(), QRSize) * #PENALTY_N3
            EndIf
            runColor = internal_getModule(*QRCode, x, y)
            runY = 1
          EndIf
        Next y
        result + finderPenaltyTerminateAndCount(runColor, runY, runHistory(), QRSize) * #PENALTY_N3
      Next x
     
      ; 2*2 blocks of modules having same color
      For y = 0 To QRSize - 2
        For x = 0 To QRSize - 2
          color = internal_getModule(*QRCode, x, y)
          If color = internal_getModule(*QRCode, x + 1, y) And color = internal_getModule(*QRCode, x, y + 1) And color = internal_getModule(*QRCode, x + 1, y + 1)
            result + #PENALTY_N2
          EndIf
        Next x
      Next y
     
      ; Balance of black And white modules
      black = 0
      For y = 0 To QRSize - 1
        For x = 0 To QRSize - 1
          If internal_getModule(*QRCode, x, y)
            black + 1
          EndIf
        Next x
      Next y
      total = QRSize * QRSize ; Note that size is odd, so black/total != 1/2
                              ; Compute the smallest integer k >= 0 such that (45-5k)% <= black/total <= (55+5k)%
      k = Int((Abs(black * 20 - total * 10) + total - 1) / total) - 1
      result + (k * #PENALTY_N4)
     
      ProcedureReturn result
    EndProcedure
    
  CompilerEndIf
  
  ;- ============================================================================
	;- Module - Drawing Tools
	;- ============================================================================
  
  CompilerIf #Enable_Generate_QRCodes
  
    Procedure   fillRectangle(left.i, top.i, width.i, height.i, *QRCode.Ascii_Structure)
      ; Sets every pixel in the range [left : left + width] * [top : top + height] to black.
      Protected dy.i, dx.i
  
      For dy = 0 To height - 1
        For dx = 0 To width - 1
          setModule(*QRCode, left + dx, top + dy, #True)
        Next dx
      Next dy
     
    EndProcedure
    
    Procedure   initializeFunctionModules(version.i, *QRCode.Ascii_Structure)
      ; Clears the given QR Code grid With white modules For the given
      ; version's size, then marks every function module as black.
      Protected QRSize.i, numAlign.i, i.i, j.i
     
      ; Initialize QR Code
      QRSize = version * 4 + 17
      ;memset(qrcode, 0, (size_t)((QRSize * QRSize + 7) / 8 + 1) * SizeOf(qrcode[0]));
      FillMemory(*QRCode, ((QRSize * QRSize + 7) / 8 + 1) * 1, 0)
      *QRCode\a[0] = QRSize
     
      ; Fill horizontal And vertical timing patterns
      fillRectangle(6, 0, 1, QRSize, *QRCode)
      fillRectangle(0, 6, QRSize, 1, *QRCode)
     
      ; Fill 3 finder patterns (all corners except bottom right) And format bits
      fillRectangle(0, 0, 9, 9, *QRCode)
      fillRectangle(QRSize - 8, 0, 8, 9, *QRCode)
      fillRectangle(0, QRSize - 8, 9, 8, *QRCode)
     
      ; Fill numerous alignment patterns
      ;uint8_t alignPatPos[7];
      Dim alignPatPos.a(7)
      numAlign = getAlignmentPatternPositions(version, alignPatPos())
      For i = 0 To numAlign - 1
        For j = 0 To numAlign - 1
          ; Don't draw on the three finder corners
          If Not ((i = 0 And j = 0) Or (i = 0 And j = numAlign - 1) Or (i = numAlign - 1 And j = 0))
            fillRectangle(alignPatPos(i) - 2, alignPatPos(j) - 2, 5, 5, *QRCode)
          EndIf
        Next j
      Next i
     
      ; Fill version blocks
      If version >= 7
        fillRectangle(QRSize - 11, 0, 3, 6, *QRCode)
        fillRectangle(0, QRSize - 11, 6, 3, *QRCode)
      EndIf
     
    EndProcedure
    
    
    Procedure   drawFormatBits(ecl.i, mask.i, *QRCode.Ascii_Structure)
      ; Draws two copies of the format bits (With its own error correction code) based
      ; on the given mask And error correction level. This always draws all modules of
      ; the format bits, unlike drawWhiteFunctionModules() which might skip black modules.
      Protected dataI.i, rem.i, i.i, bits.i, QRSize.i
      Protected Dim table.i(3)
        
      ; Calculate error correction code And pack bits
      ;assert(0 <= (int)mask && (int)mask <= 7);
      table(0) = 1
      table(1) = 0
      table(2) = 3
      table(3) = 2
      dataI = table(ecl) << 3 | mask  ; errCorrLvl is uint2, mask is uint3
      rem = dataI
      For i = 0 To 9
        rem = (rem << 1) ! ((rem >> 9) * $537)
      Next i
      bits = (dataI << 10 | rem) ! $5412  ;  // uint15
                                          ;assert(bits >> 15 == 0);
     
      ; Draw first copy
      For i = 0 To 5
        setModule(*QRCode, 8, i, getBit(bits, i))
      Next i
      setModule(*QRCode, 8, 7, getBit(bits, 6))
      setModule(*QRCode, 8, 8, getBit(bits, 7))
      setModule(*QRCode, 7, 8, getBit(bits, 8))
      For i = 9 To 14
        setModule(*QRCode, 14 - i, 8, getBit(bits, i))
      Next i
     
      ; Draw second copy
      QRSize = getSize(*QRCode)
      For i = 0 To 7
        setModule(*QRCode, QRSize - 1 - i, 8, getBit(bits, i))
      Next i
      For i = 8 To 14
        setModule(*QRCode, 8, QRSize - 15 + i, getBit(bits, i))
      Next i
      setModule(*QRCode, 8, QRSize - 8, #True) ;  // Always black
     
    EndProcedure
    
    Procedure   drawCodewords(*data.Ascii_Structure, dataLen.i, *QRCode.Ascii_Structure)
      ; Draws the raw codewords (including Data And ECC) onto the given QR Code. This requires the initial state of
      ; the QR Code To be black at function modules And white at codeword modules (including unused remainder bits).
      Protected QRSize.i, i.i, right.i, vert.i, j.i, x.i, upward.i, y.i, black.i
     
      QRSize = getSize(*QRCode)
     
      ; Do the funny zigzag scan
      For right = QRSize - 1 To 1 Step -2 ; Index of right column in each column pair
        If right = 6
          right = 5
        EndIf
        For vert = 0 To QRSize - 1  ; Vertical counter
          For j = 0 To 1
            x = right - j ; Actual x coordinate
            upward = Bool((right + 1) & 2 = 0)
            ; Actual y coordinate
            If upward
              y = QRSize - 1 - vert
            Else
              y = vert
            EndIf
            If (Not internal_getModule(*QRCode, x, y)) And i < dataLen * 8
              black = getBit(*data\a[i >> 3], 7 - (i & 7))
              setModule(*QRCode, x, y, black)
              i + 1
            EndIf
            ; If this QR Code has any remainder bits (0 To 7), they were assigned As
            ; 0/false/white by the constructor And are left unchanged by this method
          Next j
        Next vert
      Next right
      ;assert(i == dataLen * 8);
    EndProcedure
   
    Procedure   drawWhiteFunctionModules(*QRCode.Ascii_Structure, version.i)
    ; Draws white function modules And possibly some black modules onto the given QR Code, without changing
    ; non-function modules. This does Not draw the format bits. This requires all function modules To be previously
    ; marked black (namely by initializeFunctionModules()), because this may skip redrawing black function modules.
    Protected QRSize.i, i.i, dx.i, dy.i, dist.i, numAlign.i, j.i, rem.i, bits.i, k.i  
   
    ; Draw horizontal And vertical timing patterns
    QRSize = getSize(*QRCode)
    For i = 7 To QRSize - 8 Step 2
      setModule(*QRCode, 6, i, #False)
      setModule(*QRCode, i, 6, #False)
    Next i
   
    ; Draw 3 finder patterns (all corners except bottom right; overwrites some timing modules)
    For dy = -4 To 4
      For dx = -4 To 4
        dist = Abs(dx)
        If Abs(dy) > dist
          dist = Abs(dy)
        EndIf
        If dist = 2 Or dist = 4
          setModuleBounded(*QRCode, 3 + dx, 3 + dy, #False)
          setModuleBounded(*QRCode, QRSize - 4 + dx, 3 + dy, #False)
          setModuleBounded(*QRCode, 3 + dx, QRSize - 4 + dy, #False)
        EndIf
      Next dx
    Next dy
   
    ; Draw numerous alignment patterns
    Dim alignPatPos.a(7)
    numAlign = getAlignmentPatternPositions(version, alignPatPos())
    For i = 0 To numAlign - 1
      For j = 0 To numAlign - 1
        If (i = 0 And j = 0) Or (i = 0 And j = numAlign - 1) Or (i = numAlign - 1 And j = 0)
          Continue;  // Don't draw on the three finder corners
        EndIf
        For dy = -1 To 1
          For dx = -1 To 1
            setModule(*QRCode, alignPatPos(i) + dx, alignPatPos(j) + dy, Bool(dx = 0 And dy = 0))
          Next dx
        Next dy
      Next j
    Next i
   
    ; Draw version blocks
    If version >= 7
      ; Calculate error correction code And pack bits
      rem = version ; version is uint6, in the range [7, 40]
      For i = 0 To 11
        rem = (rem << 1) ! ((rem >> 11) * $1F25)
      Next i
      bits = version << 12 | rem;  // uint18
                                ;assert(bits >> 18 == 0);
     
      ; Draw two copies
      For i = 0 To 5
        For j = 0 To 2
          k = QRSize - 11 + j
          setModule(*QRCode, k, i, Bool((bits & 1) <> 0))
          setModule(*QRCode, i, k, Bool((bits & 1) <> 0))
          bits = bits >> 1
        Next j
      Next i
    EndIf
   
  EndProcedure
    
  CompilerEndIf

	;- ============================================================================
	;- Module - QRCode Generation
	;- ============================================================================
  
  CompilerIf #Enable_Generate_QRCodes
    
    Declare appendBitsToBuffer(val.i, numBits.i, *buffer.Ascii_Structure, *bitLen.Integer)
    
    ;---- Reed-Solomon ECC generator functions
    
    Procedure.a reedSolomonMultiply(x.a, y.a)
      ; Returns the product of the two given field elements modulo GF(2^8/0x11D).
      ; All inputs are valid. This could be implemented As a 256*256 lookup table.
      Protected z.a, i.i
     
      ; Russian peasant multiplication
     
      For i = 7 To 0 Step -1
        z = (z << 1) ! ((z >> 7) * $11D)
        z = z ! (((y >> i) & 1) * x)
      Next i
     
      ProcedureReturn z
    EndProcedure  
    
    Procedure   reedSolomonComputeRemainder(*data.Ascii_Structure, dataLen.i, *generator.Ascii_Structure, degree.i, *result.Ascii_Structure)
      ; Computes the Reed-Solomon error correction codeword For the given Data And divisor polynomials.
      ; The remainder when Data[0 : dataLen] is divided by divisor[0 : degree] is stored in result[0 : degree].
      ; All polynomials are in big endian, And the generator has an implicit leading 1 term.
      Protected i.i, factor.a, j.i
     
      ;assert(1 <= degree && degree <= QRCode_REED_SOLOMON_DEGREE_MAX);
      ;memset(result, 0, (size_t)degree * SizeOf(result[0]));
      FillMemory(*result, degree * 1, 0)
      For i = 0 To dataLen - 1  ; Polynomial division
        factor = *data\a[i] ! *result\a[0]
        ;memmove(&result[0], &result[1], (size_t)(degree - 1) * SizeOf(result[0]));
        MoveMemory(@*result\a[1], @*result\a[0], (degree - 1) * 1)
        *result\a[degree - 1] = 0
        For j = 0 To degree - 1
          *result\a[j] = *result\a[j] ! reedSolomonMultiply(*generator\a[j], factor)
        Next j
      Next i
     
    EndProcedure
  
    Procedure   reedSolomonComputeDivisor(degree.i, *result.Ascii_Structure)
      ; Computes a Reed-Solomon ECC generator polynomial For the given degree, storing in result[0 : degree].
      ; This could be implemented As a lookup table over all possible parameter values, instead of As an algorithm.
      Protected root.a, i.i, j.i
     
      ;assert(1 <= degree && degree <= QRCode_REED_SOLOMON_DEGREE_MAX);
      ; Polynomial coefficients are stored from highest To lowest power, excluding the leading term which is always 1.
      ; For example the polynomial x^3 + 255x^2 + 8x + 93 is stored As the uint8 Array {255, 8, 93}.
      ;memset(result, 0, (size_t)degree * SizeOf(result[0]));
      FillMemory(*result, degree * 1, 0)
      *result\a[degree - 1] = 1 ; Start off with the monomial x^0
     
      ; Compute the product polynomial (x - r^0) * (x - r^1) * (x - r^2) * ... * (x - r^{degree-1}),
      ; drop the highest monomial term which is always 1x^degree.
      ; Note that r = 0x02, which is a generator element of this field GF(2^8/0x11D).
      root = 1
      For i = 0 To degree - 1
        ; Multiply the current product by (x - r^i)
        For j = 0 To degree - 1
          *result\a[j] = reedSolomonMultiply(*result\a[j], root)
          If j + 1 < degree
            *result\a[j] = *result\a[j] ! *result\a[j + 1]
          EndIf
        Next j
        root = reedSolomonMultiply(root, $02)
      Next i
     
    EndProcedure
    
    ;---- Error correction code generation functions
    
    Procedure.i getNumRawDataModules(ver.i)
      ; Returns the number of Data bits that can be stored in a QR Code of the given version number, after
      ; all function modules are excluded. This includes remainder bits, so it might Not be a multiple of 8.
      ; The result is in the range [208, 29648]. This could be implemented As a 40-entry lookup table.
      Protected result.i, numAlign.i
     
      ;assert(QRCode_VERSION_MIN <= ver && ver <= QRCode_VERSION_MAX);
      result = (16 * ver + 128) * ver + 64
      If ver >= 2
        numAlign = ver / 7 + 2
        result - ((25 * numAlign - 10) * numAlign - 55)
        If ver >= 7
          result - 36
        EndIf
      EndIf
      ;assert(208 <= result && result <= 29648);
     
      ProcedureReturn result
    EndProcedure
  
    Procedure.i getNumDataCodewords(version.i, ecl.i)
      ; Returns the number of 8-bit codewords that can be used For storing Data (Not ECC),
      ; For the given version number And error correction level. The result is in the range [9, 2956].
      Protected v.i, e.i
     
      v = version
      e = ecl
      ;assert(0 <= e && e < 4);
      ;ProcedureReturn getNumRawDataModules(v) / 8 - ECC_CODEWORDS_PER_BLOCK[e][v] * NUM_ERROR_CORRECTION_BLOCKS[e][v]
      ProcedureReturn getNumRawDataModules(v) / 8 - PeekB(?ECC_CODEWORDS_PER_BLOCK + e * 41 + v) * PeekB(?NUM_ERROR_CORRECTION_BLOCKS + e * 41 + v)
    EndProcedure  
   
    Procedure   addEccAndInterleave(*data.Ascii_Structure, version.i, ecl.i, *result.Ascii_Structure)
      ; Appends error correction bytes To each block of the given Data Array, then interleaves
      ; bytes from the blocks And stores them in the result Array. Data[0 : dataLen] contains
      ; the input Data. Data[dataLen : rawCodewords] is used As a temporary work area And will
      ; be clobbered by this function. The final answer is stored in result[0 : rawCodewords].
      Protected numBlocks.i, blockEccLen.i, rawCodewords.i, dataLen.i, numShortBlocks.i, shortBlockDataLen.i
      Protected *dat.Ascii_Structure, i.i, j.i, k.i, *ecc.Ascii_Structure, datLen.i
      Protected *rsdiv.Ascii_Structure
     
      ; Calculate parameter numbers
      ;assert(0 <= (int)ecl && (int)ecl < 4 && QRCode_VERSION_MIN <= version && version <= QRCode_VERSION_MAX);
      numBlocks = PeekB(?NUM_ERROR_CORRECTION_BLOCKS + ecl * 41 + version)
      blockEccLen = PeekB(?ECC_CODEWORDS_PER_BLOCK + ecl * 41 + version)
      rawCodewords = getNumRawDataModules(version) / 8
      dataLen = getNumDataCodewords(version, ecl)
      numShortBlocks = numBlocks - rawCodewords % numBlocks
      shortBlockDataLen = rawCodewords / numBlocks - blockEccLen
     
      ; Split Data into blocks, calculate ECC, And interleave
      ; (Not concatenate) the bytes into a single sequence
      *rsdiv = AllocateMemory(#REED_SOLOMON_DEGREE_MAX)
      If *rsdiv
        reedSolomonComputeDivisor(blockEccLen, *rsdiv)
        *dat = *data
        For i = 0 To numBlocks - 1
          If i < numShortBlocks
            datLen = shortBlockDataLen
          Else
            datLen = shortBlockDataLen + 1
          EndIf
          *ecc = @*data\a[dataLen]                                     ; Temporary storage
          reedSolomonComputeRemainder(*dat, datLen, *rsdiv, blockEccLen, *ecc);
          k = i
          For j = 0 To datLen - 1 ; Copy Data
            If j = shortBlockDataLen
              k - numShortBlocks
            EndIf
            *result\a[k] = *dat\a[j]
            k + numBlocks
          Next j
         
          k = dataLen + i
          For j = 0 To blockEccLen - 1 ; Copy ECC
            *result\a[k] = *ecc\a[j]
            k + numBlocks
          Next j
          *dat + datLen
        Next i
        FreeMemory(*rsdiv)
      EndIf
     
    EndProcedure
   
    ;---- Segment handling
    
    Procedure.i QRCode_isAlphanumeric(*text.Character)
      Protected Result.i
  
      Result = #True
      ;assert(text != NULL);
      While *text\c
        If FindString(#ALPHANUMERIC_CHARSET$, Chr(*text\c)) = 0
          Result = #False
          Break
        EndIf
        *text + 2
      Wend
     
      ProcedureReturn Result
    EndProcedure
  
    Procedure.i QRCode_isNumeric(*text.Character)
     
      Protected Result.i
     
     
      Result = #True
      While *text\c
        If *text\c < '0' Or *text\c > '9'
          Result = #False
          Break
        EndIf
        *text + 2
      Wend
     
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.i numCharCountBits(mode.i, version.i)
      ; Returns the bit width of the character count field For a segment in the given mode
      ; in a QR Code at the given version number. The result is in the range [0, 16].
      Protected i.i, Result.i
     
      ;assert(QRCode_VERSION_MIN <= version && version <= QRCode_VERSION_MAX);
      i = (version + 7) / 17
      Select mode
        Case #Mode_NUMERIC
          Select i
            Case 0 : Result = 10
            Case 1 : Result = 12
            Case 2 : Result = 14
            Default : Result = -1
          EndSelect
        Case #Mode_ALPHANUMERIC
          Select i
            Case 0 : Result = 9
            Case 1 : Result = 11
            Case 2 : Result = 13
            Default : Result = -1
          EndSelect
        Case #Mode_BYTE
          Select i
            Case 0 : Result = 8
            Case 1 : Result = 16
            Case 2 : Result = 16
            Default : Result = -1
          EndSelect
        Case #Mode_KANJI
          Select i
            Case 0 : Result = 8
            Case 1 : Result = 10
            Case 2 : Result = 12
            Default : Result = -1
          EndSelect
        Case #Mode_ECI
          Result = 0
        Default:
          ;assert(false);
          Result = -1 ;  // Dummy value
      EndSelect
     
      ProcedureReturn Result
    EndProcedure
   
    Procedure.i calcSegmentBitLength(mode.i, numChars.i)
      ; Returns the number of Data bits needed To represent a segment
      ; containing the given number of characters using the given mode. Notes:
      ; - Returns -1 on failure, i.e. numChars > INT16_MAX Or
      ;   the number of needed bits exceeds INT16_MAX (i.e. 32767).
      ; - Otherwise, all valid results are in the range [0, INT16_MAX].
      ; - For byte mode, numChars measures the number of bytes, Not Unicode code points.
      ; - For ECI mode, numChars must be 0, And the worst-Case number of bits is returned.
      ;   An actual ECI segment can have shorter Data. For non-ECI modes, the result is exact.
      Protected result.i
     
      ; All calculations are designed To avoid overflow on all platforms
      If numChars > #INT16_MAX
        result = -1
      Else
        result = numChars
        If mode = #Mode_NUMERIC
          result = (result * 10 + 2) / 3  ; ceil(10/3 * n)
        ElseIf mode = #Mode_ALPHANUMERIC
          result = (result * 11 + 1) / 2  ; ceil(11/2 * n)
        ElseIf mode = #Mode_BYTE
          result = result * 8
        ElseIf mode = #Mode_KANJI
          result = result * 13
        ElseIf mode = #Mode_ECI And numChars = 0
          result = 3 * 8
        Else  ; Invalid argument
              ;assert(false)
          Result = -1
        EndIf
        ;assert(result >= 0);
        If result > #INT16_MAX
          result = -1
        EndIf
      EndIf
     
      ProcedureReturn result
    EndProcedure
    
    
    Procedure.i QRCode_calcSegmentBufferSize(mode.i, numChars.i)
      Protected Result.i, temp.i
     
      temp = calcSegmentBitLength(mode, numChars)
      If temp = -1
        Result = #SIZE_MAX
      Else
        ;assert(0 <= temp && temp <= INT16_MAX)
        Result = (temp + 7) / 8
      EndIf
     
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i QRCode_makeAlphanumeric(text$, *buf.Ascii_Structure)
      Protected len.i, bitLen.i, accumData.i, accumCount.i, temp.i
      Static result.Segment_Structure
      Protected *text.Character
     
      ;assert(text != NULL);
      len = Len(text$)
      result\mode = #Mode_ALPHANUMERIC
      bitLen = calcSegmentBitLength(result\mode, len)
      ;assert(bitLen != -1);
      result\numChars = len
      If bitLen > 0
        ;memset(buf, 0, ((size_t)bitLen + 7) / 8 * SizeOf(buf[0]));
        FillMemory(*buf, (bitLen + 7) / 8 * 1, 0)
      EndIf
      result\bitLength = 0
     
      ;For (; *text != '\0'; text++) {
      *text = @text$
      While *text\c
        temp = FindString(#ALPHANUMERIC_CHARSET$, Chr(*text\c))
        ;assert(temp != NULL);
        accumData = accumData * 45 + temp - 1
        accumCount + 1
        If accumCount = 2
          appendBitsToBuffer(accumData, 11, *buf, @result\bitLength)
          accumData = 0
          accumCount = 0
        EndIf
        *text + 2
      Wend
      If accumCount > 0 ; 1 character remaining
        appendBitsToBuffer(accumData, 6, *buf, @result\bitLength)
      EndIf
      ;assert(result.bitLength == bitLen);
      result\Data = *buf
     
      ProcedureReturn @result
    EndProcedure
    
    Procedure.i QRCode_makeNumeric(digits$, *buf.Ascii_Structure)
      Protected len.i, bitLen.i, accumData.i, accumCount.i
      Static result.Segment_Structure
      Protected *digits.Character
     
      ;assert(digits != NULL)
     
      len = Len(digits$)
      result\mode = #Mode_NUMERIC
      bitLen = calcSegmentBitLength(result\mode, len)
      ;assert(bitLen != -1)
      result\numChars = len
      If bitLen > 0
        ;memset(buf, 0, ((size_t)bitLen + 7) / 8 * SizeOf(buf[0]))
        FillMemory(*buf, (bitLen + 7) / 8 * 1, 0)
      EndIf
      result\bitLength = 0
     
      *digits = @digits$
      While *digits\c
        ;assert('0' <= c && c <= '9');
        accumData = accumData * 10 + (*digits\c - '0')
        accumCount + 1
        If accumCount = 3
          appendBitsToBuffer(accumData, 10, *buf, @result\bitLength)
          accumData = 0
          accumCount = 0
        EndIf
        *digits + 2
      Wend
      If accumCount > 0 ; 1 Or 2 digits remaining
        appendBitsToBuffer(accumData, accumCount * 3 + 1, *buf, @result\bitLength)
      EndIf
      ;assert(result.bitLength == bitLen)
      result\Data = *buf
     
      ProcedureReturn @result
    EndProcedure
    
    
    Procedure.i getTotalBits(Array segs.Segment_Structure(1), len.i, version.i)
      ; Calculates the number of bits needed To encode the given segments at the given version.
      ; Returns a non-negative number If successful. Otherwise returns -1 If a segment has too
      ; many characters To fit its length field, Or the total bits exceeds INT16_MAX.
      Protected i.i, result.i, numChars.i, bitLength.i, ccbits.i
     
      ;assert(segs != NULL || len == 0);
     
      For i = 0 To len - 1
        numChars = segs(i)\numChars
        bitLength = segs(i)\bitLength
        ;assert(0 <= numChars  && numChars  <= INT16_MAX);
        ;assert(0 <= bitLength && bitLength <= INT16_MAX);
        ccbits = numCharCountBits(segs(i)\mode, version)
        ;assert(0 <= ccbits && ccbits <= 16);
        If numChars >= (1 << ccbits)
          result = -1 ; The segment's length doesn't fit the field's bit width
          Break
        EndIf
        result + 4 + ccbits + bitLength
        If result > #INT16_MAX
          result = -1 ; The sum might overflow an int type
          Break
        EndIf
      Next i
      ;assert(0 <= result && result <= INT16_MAX);
      ProcedureReturn result
    EndProcedure
    
    
    ;---- Low-level QR Code encoding functions
  
    Procedure.i encodeSegmentsAdvanced(Array segs.Segment_Structure(1), len.i, ecl.i, minVersion.i, maxVersion.i, mask.i, boostEcl.i, *tempBuffer.Ascii_Structure, *QRCode.Ascii_Structure)
      Protected version.i, dataUsedBits.i, dataCapacityBits.i, terminatorBits.i, padByte.i
      Protected i.i, bitLen.i, bit.i, j.i, minPenalty.i, msk.i, penalty.i
      Protected *seg.Segment_Structure
     
      ;assert(segs != NULL || len == 0);
      ;assert(QRCode_VERSION_MIN <= minVersion && minVersion <= maxVersion && maxVersion <= QRCode_VERSION_MAX);
      ;assert(0 <= (int)ecl && (int)ecl <= 3 && -1 <= (int)mask && (int)mask <= 7);
     
      ; Find the minimal version number To use
      version = minVersion
      Repeat
        dataCapacityBits = getNumDataCodewords(version, ecl) * 8 ; Number of data bits available
        dataUsedBits = getTotalBits(segs(), len, version)
        If dataUsedBits <> -1 And dataUsedBits <= dataCapacityBits
          Break ; This version number is found to be suitable
        EndIf
        If version >= maxVersion  ; All versions in the range could Not fit the given Data
          *QRCode\a[0] = 0        ; Set size to invalid value for safety
          ProcedureReturn #False
        EndIf
        version + 1
      ForEver
      ;assert(dataUsedBits != -1);
     
      ; Increase the error correction level While the Data still fits in the current version number
      For i = #Ecc_MEDIUM To #Ecc_HIGH  ; From low to high
        If boostEcl And dataUsedBits <= getNumDataCodewords(version, i) * 8
          ecl = i
        EndIf
      Next i
     
      ; Concatenate all segments To create the Data bit string
      ;memset(qrcode, 0, (size_t)QRCode_BUFFER_LEN_FOR_VERSION(version) * SizeOf(qrcode[0]));
      FillMemory(*QRCode, QRCode::BUFFER_LEN_FOR_VERSION(version) * 1, 0)
      For i = 0 To len - 1
        *seg = @segs(i)
        appendBitsToBuffer(*seg\mode, 4, *QRCode, @bitLen)
        appendBitsToBuffer(*seg\numChars, numCharCountBits(*seg\mode, version), *QRCode, @bitLen)
        For j = 0 To *seg\bitLength - 1
          bit = (*seg\Data\a[j >> 3] >> (7 - (j & 7))) & 1
          appendBitsToBuffer(bit, 1, *QRCode, @bitLen)
        Next j
      Next i
      ;assert(bitLen == dataUsedBits);
     
      ; Add terminator And pad up To a byte If applicable
      dataCapacityBits = getNumDataCodewords(version, ecl) * 8
      ;assert(bitLen <= dataCapacityBits)
      terminatorBits = dataCapacityBits - bitLen;
      If terminatorBits > 4
        terminatorBits = 4
      EndIf
      appendBitsToBuffer(0, terminatorBits, *QRCode, @bitLen)
      appendBitsToBuffer(0, (8 - bitLen % 8) % 8, *QRCode, @bitLen)
      ;assert(bitLen % 8 == 0);
     
      ; Pad With alternating bytes Until Data capacity is reached
      ;For (uint8_t padByte = 0xEC; bitLen < dataCapacityBits; padByte ^= 0xEC ^ 0x11)
      padByte = $EC
      While bitLen < dataCapacityBits
        appendBitsToBuffer(padByte, 8, *QRCode, @bitLen)
        ;padByte = padByte ! ($EC ! $11)
        If padByte = $EC
          padByte = $11
        Else
          padByte = $EC
        EndIf
      Wend
     
      ; Draw function And Data codeword modules
      addEccAndInterleave(*QRCode, version, ecl, *tempBuffer)
      initializeFunctionModules(version, *QRCode)
      drawCodewords(*tempBuffer, getNumRawDataModules(version) / 8, *QRCode)
      drawWhiteFunctionModules(*QRCode, version)
      initializeFunctionModules(version, *tempBuffer)
     
      ; Handle masking
      If mask = #Mask_AUTO  ; Automatically choose best mask
        minPenalty = #LONG_MAX
        For i = #Mask_0 To #Mask_7
          msk = i
          applyMask(*tempBuffer, *QRCode, msk)
          drawFormatBits(ecl, msk, *QRCode)
          penalty = getPenaltyScore(*QRCode)
          If penalty < minPenalty
            mask = msk
            minPenalty = penalty
          EndIf
          applyMask(*tempBuffer, *QRCode, msk) ; Undoes the mask due to XOR
        Next i
      EndIf
      ;assert(0 <= (int)mask && (int)mask <= 7);
     
      applyMask(*tempBuffer, *QRCode, mask)
      drawFormatBits(ecl, mask, *QRCode)
     
      ProcedureReturn #True
    EndProcedure
   
    Procedure.i encodeSegments(Array segs.Segment_Structure(1), len.i, ecl.i, *tempBuffer.Ascii_Structure, *QRCode.Ascii_Structure)
      ProcedureReturn encodeSegmentsAdvanced(segs(), len, ecl, #VERSION_MIN, #VERSION_MAX, #Mask_AUTO, #True, *tempBuffer, *QRCode)
    EndProcedure
    
    
    ;---- High-level QR Code encoding functions
    
    Procedure   appendBitsToBuffer(val.i, numBits.i, *buffer.Ascii_Structure, *bitLen.Integer)
      Protected i.i
     
      ;assert(0 <= numBits && numBits <= 16 && (unsigned long)val >> numBits == 0)
      ;For (int i = numBits - 1; i >= 0; i--, (*bitLen)++)
      ;  buffer[*bitLen >> 3] |= ((val >> i) & 1) << (7 - (*bitLen & 7));
     
      ;   i = numBits - 1
      ;   While i
      ;     PokeA(*buffer + *bitLen\i >> 3, PeekA(*buffer + *bitLen\i >> 3) | ((val >> i) & 1) << (7 - (*bitLen\i & 7)))
      ;     i - 1
      ;     *bitLen\i + 1
      ;   Wend
      For i = numBits - 1 To 0 Step -1
        *buffer\a[*bitLen\i >> 3] = *buffer\a[*bitLen\i >> 3] | (((val >> i) & 1) << (7 - (*bitLen\i & 7)))
        *bitLen\i + 1
      Next i
     
    EndProcedure
    
    Procedure.i encodeText(text$, *tempBuffer.Ascii_Structure, *QRCode.Ascii_Structure, ecl.i, minVersion.i, maxVersion.i, mask.i, boostEcl.i)
      Protected Result.i, textLen.i, bufLen.i, i.i
      Protected Dim seg.Segment_Structure(0)
      Protected *seg.Segment_Structure
     
      textLen = Len(text$)
      If textLen = 0
        Dim Dummy.Segment_Structure(0)
        Result = encodeSegmentsAdvanced(Dummy(), 0, ecl, minVersion, maxVersion, mask, boostEcl, *tempBuffer, *QRCode)
      Else
        bufLen = QRCode::BUFFER_LEN_FOR_VERSION(maxVersion)
        If QRCode_isNumeric(@text$)
          If QRCode_calcSegmentBufferSize(#Mode_NUMERIC, textLen) > bufLen
            ;Goto fail
            *QRCode\a[0] = 0
            ProcedureReturn #False
          EndIf
          *seg = QRCode_makeNumeric(text$, *tempBuffer)
          CopyStructure(*seg, @seg(0), Segment_Structure)
        ElseIf QRCode_isAlphanumeric(@text$)
          If QRCode_calcSegmentBufferSize(#Mode_ALPHANUMERIC, textLen) > bufLen
            *QRCode\a[0] = 0
            ProcedureReturn #False
          EndIf
          *seg = QRCode_makeAlphanumeric(Text$, *tempBuffer)
          CopyStructure(*seg, @seg(0), Segment_Structure)
        Else
          If textLen > bufLen
            *QRCode\a[0] = 0
            ProcedureReturn #False
          EndIf
          For i = 0 To textLen - 1
            *tempBuffer\a[i] = Asc(Mid(text$, i + 1, 1))
          Next i
          seg(0)\mode = #Mode_BYTE
          seg(0)\bitLength = calcSegmentBitLength(seg(0)\mode, textLen)
          If seg(0)\bitLength = -1
            *QRCode\a[0] = 0
            ProcedureReturn #False
          EndIf
          seg(0)\numChars = textLen
          seg(0)\Data = *tempBuffer
        EndIf
      EndIf
     
      ProcedureReturn encodeSegmentsAdvanced(seg(), 1, ecl, minVersion, maxVersion, mask, boostEcl, *tempBuffer, *QRCode)
    EndProcedure
    
  CompilerEndIf
  
  
	;- ============================================================================
	;- Module - QRCode Decoding
	;- ============================================================================  
  
  CompilerIf #Enable_Decode_QRCodes
    
    Procedure.a otsu(*q.quirc)
      Protected.i numPixels, length, value, sum, i, sumb, q1, threshold, q2
      Protected.d max, m1, m2, m1m2, variance
      Protected Dim histogram.i(#UINT8_MAX)
      Protected *ptr.Ascii
      
      numPixels = *q\w * *q\h
      
      ; Calculate histogram
      
      *ptr = *q\image
      length = numPixels
      While length
        value = *ptr\a
        *ptr + 1
        histogram(value) + 1
        length - 1
      Wend
      
      ; Calculate weighted sum of histogram values
      For i = 0 To #UINT8_MAX
        sum + (i * histogram(i))
      Next i
      
      ; Compute threshold
      For i = 0 To #UINT8_MAX
        ; Weighted background
        q1 + histogram(i)
        If q1 = 0
          Continue
        EndIf
        
        ; Weighted foreground
        q2 = numPixels - q1
        If q2 = 0
          Break
        EndIf
        
        sumB + (i * histogram(i))
        m1 = sumB / q1
        m2 = (sum - sumB) / q2
        m1m2 = m1 - m2
        variance = m1m2 * m1m2 * q1 * q2
        If variance >= max
          threshold = i
          max = variance
        EndIf
      Next i
      
      ProcedureReturn threshold
    EndProcedure  
  
    Procedure.a poly_eval(*s.AsciiArrayStructure, x.a, *gf.galois_field)
      Protected.a sum, log_x, c
      Protected.i i
      
      
      log_x = *gf\log\v[x]
      
      If Not x
        ProcedureReturn *s\v[0]
      EndIf
      
      For i = 0 To #MAX_POLY - 1
        c = *s\v[i]
        
        If Not c
          Continue
        EndIf
        
        sum ! *gf\exp\v[(*gf\log\v[c] + log_x * i) % *gf\p]
      Next i
      
      ProcedureReturn sum
    EndProcedure
    
    Procedure   poly_add(*dst.AsciiArrayStructure, *src.AsciiArrayStructure, c.a, shift.i, *gf.galois_field)
      Protected.a v
      Protected.i i, log_c, p
      
      
      log_c = *gf\log\v[c]
      
      If Not c
        ProcedureReturn
      EndIf
      
      For i = 0 To #MAX_POLY - 1
        p = i + shift
        v = *src\v[i]
        
        If p < 0 Or p >= #MAX_POLY
          Continue
        EndIf
        
        If Not v
          Continue
        EndIf
        
        *dst\v[p] ! *gf\exp\v[(*gf\log\v[v] + log_c) % *gf\p]
      Next i
      
    EndProcedure
    
    Procedure   eloc_poly(*omega.AsciiArrayStructure, *s.AsciiArrayStructure, *sigma.AsciiArrayStructure, npar.i)
      Protected.a a, log_a, b
      Protected.i i, j
      Protected.AsciiArrayStructure *gf256_exp, *gf256_log
      
      *gf256_exp = ?gf256_exp
      *gf256_log = ?gf256_log
      FillMemory(*omega, #MAX_POLY, 0)
      
      For i = 0 To npar - 1
        a = *sigma\v[i]
        log_a = *gf256_log\v[a]
        
        If Not a
          Continue
        EndIf
        
        For j = 0 To #MAX_POLY - 2
          b = *s\v[j + 1]
          
          If i + j >= npar
            Break
          EndIf
          
          If Not b
            Continue
          EndIf
          
          *omega\v[i + j] ! *gf256_exp\v[(log_a + *gf256_log\v[b]) % 255]
        Next j
      Next i
      
    EndProcedure
    
    
    Procedure   berlekamp_massey(*s.AsciiArrayStructure, N.i, *gf.galois_field, *sigma.AsciiArrayStructure)
      ; Berlekamp-Massey algorithm For finding error locator polynomials.
      Protected.a b, d, mult
      Protected.i L, m, n_, i
      Protected.AsciiArrayStructure *C, *B, *T
      
      
      *C = AllocateMemory(#MAX_POLY)
      *B = AllocateMemory(#MAX_POLY)
      *T = AllocateMemory(#MAX_POLY)
      
      m = 1
      b = 1
      
      *B\v[0] = 1
      *C\v[0] = 1
      
      For n_ = 0 To N - 1
        d = *s\v[n_]
        
        For i = 1 To L
          If Not (*C\v[i] And *s\v[n_ - i])
            Continue
          EndIf
          d ! (*gf\exp\v[(*gf\log\v[*C\v[i]] + *gf\log\v[*s\v[n_ - i]]) % *gf\p])
        Next i
        
        mult = *gf\exp\v[(*gf\p - *gf\log\v[b] + *gf\log\v[d]) % *gf\p]
        
        If Not d
          m + 1
        ElseIf L * 2 <= n_
          CopyMemory(*C, *T, MemorySize(*T))
          poly_add(*C, *B, mult, m, *gf)
          CopyMemory(*T, *B, MemorySize(*B))
          L = n_ + 1 - L
          b = d
          m = 1
        Else
          poly_add(*C, *B, mult, m, *gf)
          m + 1
        EndIf
      Next n_
      
      CopyMemory(*C, *sigma, #MAX_POLY)
      
    EndProcedure
    
    
    Procedure.i take_bits(*ds.datastream, len.i)
      Protected.a b
      Protected.i ret, bitpos
      
      While Len And (*ds\ptr < *ds\data_bits)
        b = *ds\Data_[*ds\ptr >> 3]
        bitpos = *ds\ptr & 7
        
        ret = ret << 1
        If (b << bitpos) & $80
          ret | 1
        EndIf
        
        *ds\ptr + 1
        len - 1
      Wend
      
      ProcedureReturn ret
    EndProcedure
    
    Procedure.i bits_remaining(*ds.datastream)
      ProcedureReturn *ds\data_bits - *ds\ptr
    EndProcedure
    
    Procedure.i grid_bit(*code.quirc_code, x.i, y.i)
      Protected.i p
      
      p = y * *code\size + x
      
      ProcedureReturn (*code\cell_bitmap[p >> 3] >> (p & 7)) & 1
    EndProcedure
    
    
    Procedure.i alpha_tuple(*Data.quirc_data, *ds.datastream, bits.i, digits.i)
      Protected.i tuple, i
      
      If bits_remaining(*ds) < bits
        ProcedureReturn -1
      EndIf
      
      tuple = take_bits(*ds, bits)
      
      For i = 0 To digits - 1
        *Data\payload[*Data\payload_len + digits - i - 1] = PeekA(?alpha_map + (tuple % 45))
        tuple / 45
      Next i
      
      *Data\payload_len + digits
      
      ProcedureReturn #False                  ;
    EndProcedure 
    
    Procedure.i numeric_tuple(*Data.quirc_data, *ds.datastream, bits.i, digits.i)
      Protected.i tuple, i
      
      
      If bits_remaining(*ds) < bits
        ProcedureReturn -1
      EndIf
      
      tuple = take_bits(*ds, bits)
      
      For i = digits - 1 To 0 Step -1
        *Data\payload[*Data\payload_len + i] = tuple % 10 + '0'
        tuple / 10
      Next i
      
      *Data\payload_len + digits
      
      ProcedureReturn #False
    EndProcedure
    
    
    Procedure   area_count(*user_data, y.i, left.i, right.i)
      Protected *ptr.quirc_region
      
      *ptr = *user_data
      *ptr\count + (right - left + 1)
      
    EndProcedure
    
    
    Procedure.i block_syndromes(*Data.AsciiArrayStructure, bs.i, npar.i, *s.AsciiArrayStructure)
      ; Generator polynomial For GF(2^8) is x^8 + x^4 + x^3 + x^2 + 1
      Protected.a c
      Protected.i nonzero, i, j
      Protected.AsciiArrayStructure *gf256_exp, *gf256_log
      
      *gf256_exp = ?gf256_exp
      *gf256_log = ?gf256_log
      FillMemory(*s, #MAX_POLY, 0)
      
      For i = 0 To npar - 1
        For j = 0 To bs - 1
          c = *Data\v[bs - j - 1]
          
          If Not c
            Continue
          EndIf
          
          *s\v[i] ! *gf256_exp\v[(*gf256_log\v[c] + i * j) % 255]
        Next j
        
        If *s\v[i]
          nonzero = 1
        EndIf
      Next i
      
      ProcedureReturn nonzero
    EndProcedure
    
    Procedure.i format_syndromes(u.u, *s.AsciiArrayStructure)
      Protected.i i, nonzero, j
      Protected.AsciiArrayStructure *gf16_exp
      
      
      *gf16_exp = ?gf16_exp
      
      FillMemory(*s, #MAX_POLY, 0)
      
      For i = 0 To #FORMAT_SYNDROMES - 1
        *s\v[i] = 0
        For j = 0 To #FORMAT_BITS - 1
          If u & (1 << j)
            *s\v[i] ! *gf16_exp\v[((i + 1) * j) % 15]
          EndIf
        Next j
        
        If *s\v[i]
          nonzero = 1
        EndIf
      Next i
      
      ProcedureReturn nonzero
    EndProcedure
    
    
    Procedure.i correct_block(*Data.AsciiArrayStructure, *ecc.quirc_rs_params)
      Protected.a xinv, sd_x, omega_x, error
      Protected.i npar, i
      Protected.AsciiArrayStructure *s, *sigma, *sigma_deriv, *omega, *gf256_exp, *gf256_log
      
      *gf256_exp = ?gf256_exp
      *gf256_log = ?gf256_log
      
      npar = *ecc\bs - *ecc\dw
      *s = AllocateMemory(#MAX_POLY)
      *sigma = AllocateMemory(#MAX_POLY)
      *sigma_deriv = AllocateMemory(#MAX_POLY)
      *omega = AllocateMemory(#MAX_POLY)
      
      ; Compute syndrome vector
      If Not block_syndromes(*Data, *ecc\bs, npar, *s)
        ProcedureReturn #QUIRC_SUCCESS
      EndIf
      
      berlekamp_massey(*s, npar, @gf256, *sigma)
      
      ; Compute derivative of sigma
      FillMemory(*sigma_deriv, #MAX_POLY, 0)
      For i = 0 To #MAX_POLY - 1 Step 2
        *sigma_deriv\v[i] = *sigma\v[i + 1]
      Next i
      
      ; Compute error evaluator polynomial
      eloc_poly(*omega, *s, *sigma, npar - 1)
      
      ; Find error locations And magnitudes
      For i = 0 To *ecc\bs - 1
        xinv = *gf256_exp\v[255 - i]
        
        If Not poly_eval(*sigma, xinv, @gf256)
          sd_x = poly_eval(*sigma_deriv, xinv, @gf256)
          omega_x = poly_eval(*omega, xinv, @gf256)
          error = *gf256_exp\v[(255 - *gf256_log\v[sd_x] + *gf256_log\v[omega_x]) % 255]
          
          *Data\v[*ecc\bs - i - 1] ! error
        EndIf
      Next i
      
      If block_syndromes(*Data, *ecc\bs, npar, *s)
        ProcedureReturn #QUIRC_ERROR_DATA_ECC
      EndIf
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure  
    
    Procedure.i correct_format(*f_ret.Unicode)
      Protected.u u
      Protected.i i
      Protected.AsciiArrayStructure *s, *sigma, *gf16_exp
      
      
      *gf16_exp = ?gf16_exp
      u = *f_ret\u
      
      *s = AllocateMemory(#MAX_POLY)
      
      ; Evaluate U (received codeword) at each of alpha_1 .. alpha_6
      ; To get S_1 .. S_6 (but we index them from 0).
      If Not format_syndromes(u, *s)
        FreeMemory(*s)
        ProcedureReturn #QUIRC_SUCCESS
      EndIf
      
      *sigma = AllocateMemory(#MAX_POLY)
      berlekamp_massey(*s, #FORMAT_SYNDROMES, @gf16, *sigma)
      
      ; Now, find the roots of the polynomial
      For i = 0 To 14
        If Not poly_eval(*sigma, *gf16_exp\v[15 - i], @gf16)
          u ! (1 << i)
        EndIf
      Next i
      
      If format_syndromes(u, *s)
        FreeMemory(*s)
        FreeMemory(*sigma)
        ProcedureReturn #QUIRC_ERROR_FORMAT_ECC
      EndIf
      
      *f_ret\u = u
      
      FreeMemory(*s)
      FreeMemory(*sigma)
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
    
  
    Procedure.i line_intersect(*p0.quirc_point, *p1.quirc_point, *q0.quirc_point, *q1.quirc_point, *r.quirc_point)
      Protected.i a, b, c, d, e, f, det
      
      ; (a, b) is perpendicular To line p
      a = -(*p1\y - *p0\y)
      b = *p1\x - *p0\x
      
      ; (c, d) is perpendicular To line q
      c = -(*q1\y - *q0\y)
      d = *q1\x - *q0\x
      
      ; e And f are dot products of the respective vectors With p And q
      e = a * *p1\x + b * *p1\y
      f = c * *q1\x + d * *q1\y
      
      ; Now we need To solve:
      ;     (a b) (rx)   (e)
      ;     (c d) (ry) = (f)
      ;
      ; We do this by inverting the matrix And applying it To (e, f):
      ;       ( d -b) (e)   (rx)
      ; 1/det (-c  a) (f) = (ry)
      ;
      det = (a * d) - (b * c)
      
      If Not det
        ProcedureReturn 0
      EndIf
      
      *r\x = (d * e - b * f) / det
      *r\y = (-c * e + a * f) / det
      
      ProcedureReturn #True
    EndProcedure
    
  
    Procedure   perspective_unmap(*c.DoubleArrayStructure, *in.quirc_point, *u.Double, *v.Double)
      Protected.d x, y, den
      
      x = *in\x
      y = *in\y
      den = -*c\v[0] * *c\v[7] * y + *c\v[1] * *c\v[6] * y + (*c\v[3] * *c\v[7] - *c\v[4] * *c\v[6])*x + *c\v[0] * *c\v[4] - *c\v[1] * *c\v[3]
      
      *u\d = -(*c\v[1] * (y-*c\v[5]) - *c\v[2] * *c\v[7] * y + (*c\v[5] * *c\v[7] - *c\v[4]) * x + *c\v[2] * *c\v[4]) / den
      *v\d = (*c\v[0] * (y-*c\v[5]) - *c\v[2] * *c\v[6] * y + (*c\v[5] * *c\v[6] - *c\v[3]) * x + *c\v[2] * *c\v[3]) / den
      
    EndProcedure
    
    Procedure   perspective_map(*c.DoubleArrayStructure, u.d, v.d, *ret.quirc_point)
      Protected.d den, x, y
      
      
      den = *c\v[6]*u + *c\v[7]*v + 1.0
      x = (*c\v[0]*u + *c\v[1]*v + *c\v[2]) / den
      y = (*c\v[3]*u + *c\v[4]*v + *c\v[5]) / den
      
      *ret\x = Round(x, #PB_Round_Nearest)
      *ret\y = Round(y, #PB_Round_Nearest)
      
    EndProcedure
    
    Procedure   perspective_setup(*c.DoubleArrayStructure, *rect.quirc_pointArrayStructure, w.d, h.d)
      Protected.d x0, y0, x1, y1, x2, y2, x3, y3, wden, hden
      
      
      x0 = *rect\v[0]\x
      y0 = *rect\v[0]\y
      x1 = *rect\v[1]\x
      y1 = *rect\v[1]\y
      x2 = *rect\v[2]\x
      y2 = *rect\v[2]\y
      x3 = *rect\v[3]\x
      y3 = *rect\v[3]\y
      
      wden = w * (x2*y3 - x3*y2 + (x3-x2)*y1 + x1*(y2-y3))
      hden = h * (x2*y3 + x1*(y2-y3) - x3*y2 + (x3-x2)*y1)
      
      *c\v[0] = (x1*(x2*y3-x3*y2) + x0*(-x2*y3+x3*y2+(x2-x3)*y1) +   x1*(x3-x2)*y0) / wden
      *c\v[1] = -(x0*(x2*y3+x1*(y2-y3)-x2*y1) - x1*x3*y2 + x2*x3*y1 + (x1*x3-x2*x3)*y0) / hden
      *c\v[2] = x0
      *c\v[3] = (y0*(x1*(y3-y2)-x2*y3+x3*y2) + y1*(x2*y3-x3*y2) + x0*y1*(y2-y3)) / wden
      *c\v[4] = (x0*(y1*y3-y2*y3) + x1*y2*y3 - x2*y1*y3 + y0*(x3*y2-x1*y2+(x2-x3)*y1)) / hden
      *c\v[5] = y0
      *c\v[6] = (x1*(y3-y2) + x0*(y2-y3) + (x2-x3)*y1 + (x3-x2)*y0) / wden
      *c\v[7] = (-x2*y3 + x1*y3 + x3*y2 + x0*(y1-y2) - x3*y1 + (x2-x1)*y0) /   hden
      
    EndProcedure
    
  
    Procedure.i fitness_cell(*q.quirc, index.i, x.i, y.i)
      Protected.i score, u, v
      Protected *qr.quirc_grid
      Protected p.quirc_point
      Protected Dim offsets.d(2)
      
      
      *qr = @*q\grids[index]
      
      offsets(0) = 0.3
      offsets(1) = 0.5
      offsets(2) = 0.7
      
      For v = 0 To 2
        For u = 0 To 2
          
          perspective_map(@*qr\c, x + offsets(u), y + offsets(v), @p)
          If p\y < 0 Or p\y >= *q\h Or p\x < 0 Or p\x >= *q\w
            Continue
          EndIf
          
          If *q\pixels\v[p\y * *q\w + p\x]
            score + 1
          Else
            score - 1
          EndIf
        Next u
      Next v
      
      ProcedureReturn score
    EndProcedure  
    
    Procedure.i fitness_ring(*q.quirc, index.i, cx.i, cy.i, radius.i)
      Protected.i i, score
      
      For i = 0 To radius * 2 - 1
        score + fitness_cell(*q, index, cx - radius + i, cy - radius)
        score + fitness_cell(*q, index, cx - radius, cy + radius - i)
        score + fitness_cell(*q, index, cx + radius, cy - radius + i)
        score + fitness_cell(*q, index, cx + radius - i, cy + radius)
      Next i
      
      ProcedureReturn score
    EndProcedure    
    
    Procedure.i fitness_apat(*q.quirc, index.i, cx.i, cy.i)
      ProcedureReturn fitness_cell(*q, index, cx, cy) - fitness_ring(*q, index, cx, cy, 1) + fitness_ring(*q, index, cx, cy, 2)
    EndProcedure  
    
    Procedure.i fitness_capstone(*q.quirc, index.i, x.i, y.i)
      
      x + 3
      y + 3
      
      ProcedureReturn fitness_cell(*q, index, x, y) + fitness_ring(*q, index, x, y, 1) - fitness_ring(*q, index, x, y, 2) + fitness_ring(*q, index, x, y, 3)
    EndProcedure  
   
    Procedure.i fitness_all(*q.quirc, index.i)
      Protected.i version, score, i, j, ap_count, expect
      Protected *qr.quirc_grid
      Protected *info.quirc_version_info
      
      
      *qr = @*q\grids[index]
      version = (*qr\grid_size - 17) / 4
      *info = ?quirc_version_db_0 + version * SizeOf(quirc_version_info)
      
      ; Check the timing pattern
      For i = 0 To *qr\grid_size - 15
        If i & 1
          expect = 1
        Else
          expect = -1
        EndIf
        
        score + fitness_cell(*q, index, i + 7, 6) * expect
        score + fitness_cell(*q, index, 6, i + 7) * expect
      Next i
      
      ; Check capstones
      score + fitness_capstone(*q, index, 0, 0)
      score + fitness_capstone(*q, index, *qr\grid_size - 7, 0)
      score + fitness_capstone(*q, index, 0, *qr\grid_size - 7)
      
      If version < 0 Or version > #QUIRC_MAX_VERSION
        ProcedureReturn score
      EndIf
      
      ; Check alignment patterns
      ap_count = 0
      While (ap_count < #QUIRC_MAX_ALIGNMENT) And *info\apat[ap_count]
        ap_count + 1
      Wend
      
      For i = 1 To ap_count - 2
        score + fitness_apat(*q, index, 6, *info\apat[i])
        score + fitness_apat(*q, index, *info\apat[i], 6)
      Next i
      
      For i = 1 To ap_count - 1
        For j = 1 To ap_count - 1
          score + fitness_apat(*q, index, *info\apat[i], *info\apat[j])
        Next j
      Next i
      
      ProcedureReturn score
    EndProcedure
    
    
    Procedure   jiggle_perspective(*q.quirc, index.i)
      Protected.i pass, i, best, j, test
      Protected.d old, step_, new
      Protected *qr.quirc_grid
      Protected Dim adjustments.d(7)
      
      
      *qr = @*q\grids[index]
      best = fitness_all(*q, index)
      
      For i = 0 To 7
        adjustments(i) = *qr\c[i] * 0.02
      Next i
      
      For pass = 0 To 4
        For i = 0 To 15
          j = i >> 1
          old = *qr\c[j]
          Step_ = adjustments(j)
          
          If i & 1
            new = old + Step_
          Else
            new = old - Step_
          EndIf
          
          *qr\c[j] = new
          test = fitness_all(*q, index)
          
          If test > best
            best = test
          Else
            *qr\c[j] = old
          EndIf
        Next i
        
        For i = 0 To 7
          adjustments(i) * 0.5
        Next i
      Next pass
      
    EndProcedure  
    
   
    Procedure.i timing_scan(*q.quirc, *p0.quirc_point, *p1.quirc_point)
      ; Do a Bresenham scan from one point To another And count the number
      ; of black/white transitions.
      Protected.i n, d, x, y, dom_step, nondom_step, a, run_length, count, swap_, pixel, i
      Protected *dom.Integer, *nondom.Integer
      
      
      n = *p1\x - *p0\x
      d = *p1\y - *p0\y
      x = *p0\x
      y = *p0\y
      
      If *p0\x < 0 Or *p0\y < 0 Or *p0\x >= *q\w Or *p0\y >= *q\h
        ProcedureReturn -1
      EndIf
      
      If *p1\x < 0 Or *p1\y < 0 Or *p1\x >= *q\w Or *p1\y >= *q\h
        ProcedureReturn -1
      EndIf
      
      If Abs(n) > Abs(d)
        Swap_ = n
        
        n = d
        d = Swap_
        
        *dom = @x
        *nondom = @y
      Else
        *dom = @y
        *nondom = @x
      EndIf
      
      If n < 0
        n = -n
        nondom_step = -1
      Else
        nondom_step = 1
      EndIf
      
      If d < 0
        d = -d
        dom_step = -1
      Else
        dom_step = 1
      EndIf
      
      x = *p0\x
      y = *p0\y
      For i = 0 To d
        
        If y < 0 Or y >= *q\h Or x < 0 Or x >= *q\w
          Break;
        EndIf
        
        pixel = *q\pixels\v[y * *q\w + x]
        
        If pixel
          If run_length >= 2
            count + 1
          EndIf
          run_length = 0
        Else
          run_length + 1
        EndIf
        
        a + n
        *dom\i + dom_step
        If a >= d
          *nondom\i + nondom_step
          a - d
        EndIf
      Next i
      
      ProcedureReturn count
    EndProcedure
    
    Procedure.i measure_timing_pattern(*q.quirc, index.i)
      ; Try the measure the timing pattern For a given QR code. This does
      ; Not require the Global perspective To have been set up, but it
      ; does require that the capstone corners have been set To their
      ; canonical rotation.
      ;
      ; For each capstone, we find a point in the middle of the ring band
      ; which is nearest the centre of the code. Using these points, we do
      ; a horizontal And a vertical timing scan.
      Protected.i i, scan, ver, size
      Protected *qr.quirc_grid
      Protected *cap.quirc_capstone
      Protected Dim us.d(2)
      Protected Dim vs.d(2)
      
      
      *qr = @*q\grids[index]
      
      us(0) = 6.5
      us(1) = 6.5
      us(2) = 0.5
      
      vs(0) = 0.5
      vs(1) = 6.5
      vs(2) = 6.5
      
      For i = 0 To 2
        *cap = @*q\capstones[*qr\caps[i]]
        perspective_map(@*cap\c, us(i), vs(i), @*qr\tpep[i])
      Next i
      
      *qr\hscan = timing_scan(*q, @*qr\tpep[1], @*qr\tpep[2])
      *qr\vscan = timing_scan(*q, @*qr\tpep[1], @*qr\tpep[0])
      
      scan = *qr\hscan
      If *qr\vscan > scan
        scan = *qr\vscan
      EndIf
      
      ; If neither scan worked, we can't go any further.
      If scan < 0
        ProcedureReturn -1
      EndIf
      
      ; Choose the nearest allowable grid size
      size = scan * 2 + 13
      ver = (size - 15) / 4
      If ver > #QUIRC_MAX_VERSION
        ProcedureReturn -1
      EndIf
      
      *qr\grid_size = ver * 4 + 17
      
      ProcedureReturn #False
    EndProcedure
  
    
    Procedure   setup_qr_perspective(*q.quirc, index.i)
      Protected *qr.quirc_grid
      Protected *rect.quirc_pointArrayStructure
      
      *qr = @*q\grids[index]
      *rect = AllocateMemory(SizeOf(quirc_point) * 4)
      If *rect
        
        ; Set up the perspective Map For reading the grid
        CopyMemory(@*q\capstones[*qr\caps[1]]\corners[0], @*rect\v[0], SizeOf(quirc_point))
        CopyMemory(@*q\capstones[*qr\caps[2]]\corners[0], @*rect\v[1], SizeOf(quirc_point))
        CopyMemory(@*qr\align, @*rect\v[2], SizeOf(quirc_point))
        CopyMemory(@*q\capstones[*qr\caps[0]]\corners[0], @*rect\v[3], SizeOf(quirc_point))
        
        perspective_setup(@*qr\c, *rect, *qr\grid_size - 7, *qr\grid_size - 7)
        
        jiggle_perspective(*q, index)
        FreeMemory(*rect)
      EndIf
      
    EndProcedure
    
    Procedure   pixels_setup(*q.quirc, threshold.a)
      Protected.a value
      Protected.i length
      Protected *source.Ascii
      Protected *dest.quirc_pixel_array
      
      
      If #QUIRC_PIXEL_ALIAS_IMAGE
        *q\pixels = *q\image
      EndIf
      
      *source = *q\image
      *dest = *q\pixels
      length = *q\w * *q\h
      While length
        value = *source\a
        *source + 1
        If value < threshold
          *dest\v = #QUIRC_PIXEL_BLACK
        Else
          *dest\v = #QUIRC_PIXEL_WHITE
        EndIf
        *dest + SizeOf(quirc_pixel_ptr)
        length - 1
      Wend
      
    EndProcedure
    
  
    Procedure   flood_fill_seed(*q.quirc, x.i, y.i, from.i, To_.i, func.span_func_t, *user_data, depth.i)
      Protected.i left, right, i
      Protected *row.quirc_pixel_array
      
      
      left = x
      right = x
      *row = *q\pixels + y * *q\w
      
      If depth >= #FLOOD_FILL_MAX_DEPTH
        ProcedureReturn
      EndIf
      
      While left > 0 And *row\v[left - 1] = from
        left - 1
      Wend 
      
      While right < *q\w - 1 And *row\v[right + 1] = from
        right + 1
      Wend
      
      ; Fill the extent
      For i = left To right
        *row\v[i] = To_
      Next i
      
      If func
        func(*user_data, y, left, right)
      EndIf
      
      ; Seed new flood-fills
      If y > 0
        *row = *q\pixels + (y - 1) * *q\w
        
        For i = left To right
          If *row\v[i] = from
            flood_fill_seed(*q, i, y - 1, from, To_, func, *user_data, depth + 1)
          EndIf
        Next i
      EndIf
      
      If y < *q\h - 1
        *row = *q\pixels + (y + 1) * *q\w
        
        For i = left To right
          If *row\v[i] = from
            flood_fill_seed(*q, i, y + 1, from, To_, func, *user_data, depth + 1)
          EndIf
        Next i
      EndIf
      
    EndProcedure
    
    Procedure.i region_code(*q.quirc, x.i, y.i)
      Protected.i pixel, region
      Protected *box.quirc_region
      
      
      If x < 0 Or y < 0 Or x >= *q\w Or y >= *q\h
        ProcedureReturn -1
      EndIf
      
      pixel = *q\pixels\v[y * *q\w + x]
      
      If pixel >= #QUIRC_PIXEL_REGION
        ProcedureReturn pixel
      EndIf
      
      If pixel = #QUIRC_PIXEL_WHITE
        ProcedureReturn -1
      EndIf
      
      If *q\num_regions >= #QUIRC_MAX_REGIONS
        ProcedureReturn -1
      EndIf
      
      region = *q\num_regions
      *box = @*q\regions[*q\num_regions]
      *q\num_regions + 1
      
      FillMemory(*box, SizeOf(*box), 0)
      
      *box\seed\x = x
      *box\seed\y = y
      *box\capstone = -1
      
      flood_fill_seed(*q, x, y, pixel, region, @area_count(), *box, 0)
      
      ProcedureReturn region
    EndProcedure  
    
    
    Procedure   find_leftmost_to_line(*user_data, y.i, left.i, right.i)
      Protected.i i, d
      Protected *psd.polygon_score_data
      Protected Dim xs.i(1)
      
      
      *psd = *user_data
      xs(0) = left
      xs(1) = right
      
      For i = 0 To 1
        d = -*psd\ref\y * xs(i) + *psd\ref\x * y
        
        If d < *psd\scores[0]
          *psd\scores[0] = d
          *psd\corners[0]\x = xs(i)
          *psd\corners[0]\y = y
        EndIf
      Next i
      
    EndProcedure
    
    Procedure   find_alignment_pattern(*q.quirc, index.i)
      Protected.i size_estimate, step_size, dir, i, code
      Protected.d u, v
      Protected.quirc_grid *qr
      Protected.quirc_capstone *c0, *c2
      Protected.quirc_point a, b, c
      Protected.quirc_region *reg
      Protected Dim dx_map.i(3)
      Protected Dim dy_map.i(3)
      
      
      *qr = *q\grids[index]
      *c0 = *q\capstones[*qr\caps[0]]
      *c2 = *q\capstones[*qr\caps[2]]
      
      step_size = 1
      
      ; Grab our previous estimate of the alignment pattern corner
      CopyMemory(*qr\align, @b, SizeOf(quirc_point))
      
      ; Guess another two corners of the alignment pattern so that we
      ; can estimate its size.
      perspective_unmap(@*c0\c, @b, @u, @v)
      perspective_map(@*c0\c, u, v + 1.0, @a)
      perspective_unmap(@*c2\c, @b, @u, @v)
      perspective_map(@*c2\c, u + 1.0, v, @c)
      
      size_estimate = Abs((a\x - b\x) * -(c\y - b\y) + (a\y - b\y) * (c\x - b\x))
      
      ; Spiral outwards from the estimate point Until we find something
      ; roughly the right size. Don't look too far from the estimate
      ; point.
      
      dx_map(0) = 1
      dx_map(1) = 0
      dx_map(2) = -1
      dx_map(3) = 0
      
      dy_map(0) = 0
      dy_map(1) = -1
      dy_map(2) = 0
      dy_map(3) = 1
      
      While step_size * step_size < size_estimate * 100
        
        For i = 0 To step_size - 1
          code = region_code(*q, b\x, b\y)
          
          If code >= 0
            *reg = @*q\regions[code]
            
            If *reg\count >= size_estimate / 2 And *reg\count <= size_estimate * 2
              *qr\align_region = code
              ProcedureReturn
            EndIf
          EndIf
          
          b\x + dx_map(dir)
          b\y + dy_map(dir)
        Next i
        
        dir = (dir + 1) % 4
        If Not dir & 1
          step_size + 1
        EndIf
      Wend
      
    EndProcedure
  
    Procedure   find_other_corners(*user_data, y.i, left.i, right.i)
      Protected.i i, up, j
      Protected *psd.polygon_score_data
      Protected Dim xs.i(1)
      Protected Dim scores.i(3)
      
      
      *psd = *user_data
      xs(0) = Left
      xs(1) = Right
      
      For i = 0 To 1
        up = xs(i) * *psd\ref\x + y * *psd\ref\y
        right = xs(i) * -*psd\ref\y + y * *psd\ref\x
        scores(0) = up
        scores(1) = right
        scores(2) = -up
        scores(3) = -right
        
        For j = 0 To 3
          If scores(j) > *psd\scores[j]
            *psd\scores[j] = scores(j)
            *psd\corners[j]\x = xs(i)
            *psd\corners[j]\y = y
          EndIf
        Next j
      Next i
      
    EndProcedure
    
    Procedure   find_one_corner(*user_data, y.i, left.i, right.i)
      Protected.i dy, i, dx, d
      Protected *psd.polygon_score_data
      Protected Dim xs.i(1)
      
      
      *psd = *user_data
      xs(0) = Left
      xs(1) = Right
      
      dy = y - *psd\ref\y
      
      For i = 0 To 1
        dx = xs(i) - *psd\ref\x
        d = dx * dx + dy * dy
        
        If d > *psd\scores[0]
          *psd\scores[0] = d
          *psd\corners[0]\x = xs(i)
          *psd\corners[0]\y = y
        EndIf
      Next i
      
    EndProcedure
    
    Procedure   find_region_corners(*q.quirc, rcode.i, *ref.quirc_point, *corners.quirc_pointArrayStructure)
      Protected.i i
      Protected *region.quirc_region
      Protected psd.polygon_score_data
      
      
      *region = @*q\regions[rcode]
      
      ;psd\corners = *corners
      CopyMemory(@*corners\v[0], @psd\corners[0], SizeOf(psd\corners))
      
      CopyMemory(*ref, @psd\ref, SizeOf(psd\ref))
      psd\scores[0] = -1
      flood_fill_seed(*q, *region\seed\x, *region\seed\y, rcode, #QUIRC_PIXEL_BLACK, @find_one_corner(), @psd, 0)
      
      psd\ref\x = psd\corners[0]\x - psd\ref\x
      psd\ref\y = psd\corners[0]\y - psd\ref\y
      
      For i = 0 To 3
        CopyMemory(@*region\seed, @psd\corners[i], SizeOf(quirc_point))
      Next i
      
      i = *region\seed\x * psd\ref\x + *region\seed\y * psd\ref\y
      psd\scores[0] = i
      psd\scores[2] = -i
      i = *region\seed\x * -psd\ref\y + *region\seed\y * psd\ref\x
      psd\scores[1] = i
      psd\scores[3] = -i
      
      flood_fill_seed(*q, *region\seed\x, *region\seed\y, #QUIRC_PIXEL_BLACK, rcode, @find_other_corners(), @psd, 0)
      
      CopyMemory(@psd\corners[0], @*corners\v[0], SizeOf(psd\corners))
      
    EndProcedure
   
  
    Procedure   rotate_capstone(*cap.quirc_capstone, *h0.quirc_point, *hd.quirc_point)
      ; Rotate the capstone With so that corner 0 is the leftmost With respect
      ; To the given reference line.
      Protected.i j, best, best_score, score
      Protected *p.quirc_point
      Protected Dim copy.quirc_point(3)
      
      
      best_score = #INT_MAX
      
      For j = 0 To 3
        *p = @*cap\corners[j]
        score = (*p\x - *h0\x) * -*hd\y +   (*p\y - *h0\y) * *hd\x
        
        If Not j Or score < best_score
          best = j
          best_score = score
        EndIf
      Next j
      
      ; Rotate the capstone
      For j = 0 To 3
        CopyMemory(@*cap\corners[(j + best) % 4], @copy(j), SizeOf(quirc_point))
      Next j
      CopyMemory(@copy(), *cap\corners, SizeOf(*cap\corners))
      perspective_setup(@*cap\c, @*cap\corners, 7.0, 7.0)
      
    EndProcedure
    
    
    Procedure   record_qr_grid(*q.quirc, a.i, b.i, c.i) 
      Protected.i i, qr_index, swap_
      Protected.quirc_point h0, hd
      Protected *qr.quirc_grid
      Protected *cap.quirc_capstone
      Protected psd.polygon_score_data
      Protected *reg.quirc_region
      
      
      If *q\num_grids >= #QUIRC_MAX_GRIDS
        ProcedureReturn
      EndIf
      
      ; Construct the hypotenuse line from A To C. B should be To
      ; the left of this line.
      CopyMemory(@*q\capstones[a]\center, @h0, SizeOf(h0))
      hd\x = *q\capstones[c]\center\x - *q\capstones[a]\center\x
      hd\y = *q\capstones[c]\center\y - *q\capstones[a]\center\y
      
      ; Make sure A-B-C is clockwise
      If (*q\capstones[b]\center\x - h0\x) * -hd\y + (*q\capstones[b]\center\y - h0\y) * hd\x > 0
        swap_ = a
        
        a = c
        c = swap_
        hd\x = -hd\x
        hd\y = -hd\y
      EndIf
      
      ; Record the grid And its components
      qr_index = *q\num_grids
      *qr = @*q\grids[*q\num_grids]
      *q\num_grids + 1
      
      FillMemory(*qr, SizeOf(quirc_grid), 0)
      *qr\caps[0] = a
      *qr\caps[1] = b
      *qr\caps[2] = c
      *qr\align_region = -1
      
      ; Rotate each capstone so that corner 0 is top-left With respect
      ; To the grid.
      For i = 0 To 2
        *cap = @*q\capstones[*qr\caps[i]]
        
        rotate_capstone(*cap, @h0, @hd)
        *cap\qr_grid = qr_index
      Next i
      
      ; Check the timing pattern. This doesn't require a perspective
      ; transform.
      If measure_timing_pattern(*q, qr_index) < 0
        ; We've been unable to complete setup for this grid. Undo what we've
        ; recorded And pretend it never happened.
        For i = 0 To 2
          *q\capstones[*qr\caps[i]]\qr_grid = -1
        Next i
        *q\num_grids - 1
        ProcedureReturn
      EndIf
      
      ; Make an estimate based For the alignment pattern based on extending
      ; lines from capstones A And C.
      If Not line_intersect(@*q\capstones[a]\corners[0], @*q\capstones[a]\corners[1], @*q\capstones[c]\corners[0], @*q\capstones[c]\corners[3], @*qr\align)
        ; We've been unable to complete setup for this grid. Undo what we've
        ; recorded And pretend it never happened.
        For i = 0 To 2
          *q\capstones[*qr\caps[i]]\qr_grid = -1
        Next i
        *q\num_grids - 1
        ProcedureReturn
      EndIf
      
      ; On V2+ grids, we should use the alignment pattern.
      If *qr\grid_size > 21
        ; Try To find the actual location of the alignment pattern.
        find_alignment_pattern(*q, qr_index)
        
        ; Find the point of the alignment pattern closest To the
        ; top-left of the QR grid.
        If *qr\align_region >= 0
          *reg = @*q\regions[*qr\align_region]
          
          ; Start from some point inside the alignment pattern
          CopyMemory(@*reg\seed, @*qr\align, SizeOf(*qr\align))
          
          CopyMemory(@hd, @psd\ref, SizeOf(psd\ref))
          ;psd\corners = @*qr\align
          CopyMemory(@*qr\align, @psd\corners, SizeOf(quirc_point))
          psd\scores[0] = -hd\y * *qr\align\x + hd\x * *qr\align\y
          
          flood_fill_seed(*q, *reg\seed\x, *reg\seed\y, *qr\align_region, #QUIRC_PIXEL_BLACK, #Null, #Null, 0)
          flood_fill_seed(*q, *reg\seed\x, *reg\seed\y, #QUIRC_PIXEL_BLACK, *qr\align_region, @find_leftmost_to_line(), @psd, 0)
        EndIf
      EndIf
      
      setup_qr_perspective(*q, qr_index)
      
    EndProcedure
    
    Procedure   record_capstone(*q.quirc, ring.i, stone.i)
      Protected.i cs_index
      Protected.quirc_region *stone_reg, *ring_reg
      Protected.quirc_capstone *capstone
      
      
      *stone_reg = @*q\regions[stone]
      *ring_reg = @*q\regions[ring]
      
      If *q\num_capstones >= #QUIRC_MAX_CAPSTONES
        ProcedureReturn
      EndIf
      
      cs_index = *q\num_capstones
      *capstone = @*q\capstones[*q\num_capstones]
      *q\num_capstones + 1
      
      FillMemory(*capstone, SizeOf(quirc_capstone), 0)
      
      *capstone\qr_grid = -1
      *capstone\ring = ring
      *capstone\stone = stone
      *stone_reg\capstone = cs_index
      *ring_reg\capstone = cs_index
      
      ; Find the corners of the ring
      find_region_corners(*q, ring, @*stone_reg\seed, @*capstone\corners)
      
      ; Set up the perspective transform And find the center
      perspective_setup(@*capstone\c, @*capstone\corners, 7.0, 7.0)
      perspective_map(@*capstone\c, 3.5, 3.5, @*capstone\center)
      
    EndProcedure
    
    
    Procedure   test_capstone(*q.quirc, x.i, y.i, *pb.IntegerArrayStructure)
      Protected.i ring_right, stone, ring_left, ratio
      Protected.quirc_region *stone_reg, *ring_reg
      
      
      ring_right = region_code(*q, x - *pb\v[4], y)
      stone = region_code(*q, x - *pb\v[4] - *pb\v[3] - *pb\v[2], y)
      ring_left = region_code(*q, x - *pb\v[4] - *pb\v[3] - *pb\v[2] - *pb\v[1] - *pb\v[0], y)
      
      If ring_left < 0 Or ring_right < 0 Or stone < 0
        ProcedureReturn
      EndIf
      
      ; Left And ring of ring should be connected
      If ring_left <> ring_right
        ProcedureReturn
      EndIf
      
      ; Ring should be disconnected from stone
      If ring_left = stone
        ProcedureReturn
      EndIf
      
      *stone_reg = @*q\regions[stone]
      *ring_reg = @*q\regions[ring_left]
      
      ; Already detected
      If *stone_reg\capstone >= 0 Or *ring_reg\capstone >= 0
        ProcedureReturn
      EndIf
      
      ; Ratio should ideally be 37.5
      ratio = *stone_reg\count * 100 / *ring_reg\count
      If ratio < 10 Or ratio > 70
        ProcedureReturn
      EndIf
      
      record_capstone(*q, ring_left, stone)
      
    EndProcedure
    
    Procedure   test_neighbours(*q.quirc, i.i, *hlist.neighbour_list, *vlist.neighbour_list)
      Protected.i j, k, best_h, best_v
      Protected.d best_score, score
      Protected.neighbour *hn, *vn
      
      best_h = -1
      best_v = -1
      
      ; Test each possible grouping
      For j = 0 To *hlist\count - 1
        For k = 0 To *vlist\count - 1
          *hn = @*hlist\n[j]
          *vn = @*vlist\n[k]
          score = Abs(1.0 - *hn\distance / *vn\distance)
          
          If score > 2.5
            Continue
          EndIf
          
          If best_h < 0 Or score < best_score
            best_h = *hn\index
            best_v = *vn\index
            best_score = score
          EndIf
        Next k
      Next j
      
      If best_h < 0 Or best_v < 0
        ProcedureReturn
      EndIf
      
      record_qr_grid(*q, best_h, i, best_v)
      
    EndProcedure
    
    Procedure   test_grouping(*q.quirc, i.i)
      Protected.i j
      Protected.d u, v
      Protected.quirc_capstone *c1, *c2
      Protected.neighbour_list hlist, vlist
      Protected.neighbour *n
      
      
      *c1 = @*q\capstones[i]
      
      If *c1\qr_grid >= 0
        ProcedureReturn
      EndIf
      
      ; Look For potential neighbours by examining the relative gradients
      ; from this capstone To others.
      For j = 0 To *q\num_capstones - 1
        *c2 = @*q\capstones[j]
        
        If i = j Or *c2\qr_grid >= 0
          Continue
        EndIf
        
        perspective_unmap(@*c1\c, @*c2\center, @u, @v)
        
        u = Abs(u - 3.5)
        v = Abs(v - 3.5)
        
        If u < 0.2 * v
          *n = @hlist\n[hlist\count]
          hlist\count + 1
          
          *n\index = j
          *n\distance = v
        EndIf
        
        If v < 0.2 * u
          *n = @vlist\n[vlist\count]
          vlist\count + 1
          
          *n\index = j
          *n\distance = u
        EndIf
      Next j
      
      If Not (hlist\count And vlist\count)
        ProcedureReturn
      EndIf
      
      test_neighbours(*q, i, @hlist, @vlist)
      
    EndProcedure
  
  
    Procedure   finder_scan(*q.quirc, y.i)
      Protected.i x, last_color, run_length, run_count, color, avg, err, i, ok
      Protected *row.quirc_pixel_array
      Protected *pb.IntegerArrayStructure
      Protected Dim check.i(4)
      
      
      *row = *q\pixels + y * *q\w
      
      *pb = AllocateMemory(5 * SizeOf(Integer))
      
      For x = 0 To *q\w - 1
        If *row\v[x]
          color = 1
        Else
          color = 0
        EndIf
        
        If x And color <> last_color
          ;memmove(pb, pb + 1, SizeOf(pb[0]) * 4)
          MoveMemory(*pb + SizeOf(Integer), *pb, SizeOf(Integer) * 4)
          *pb\v[4] = run_length
          run_length = 0
          run_count + 1
          
          If Not color And run_count >= 5
            check(0) = 1
            check(1) = 1
            check(2) = 3
            check(3) = 1
            check(4) = 1
            
            ok = 1
            
            avg = (*pb\v[0] + *pb\v[1] + *pb\v[3] + *pb\v[4]) / 4
            err = avg * 3 / 4
            
            For i = 0 To 4
              If *pb\v[i] < check(i) * avg - err Or *pb\v[i] > check(i) * avg + err
                ok = 0
              EndIf
            Next i
            
            If ok
              test_capstone(*q, x, y, *pb)
            EndIf
          EndIf
        EndIf
        
        run_length + 1
        last_color = color
      Next x
      
    EndProcedure
    
    
    Procedure.i decode_eci(*Data.quirc_data, *ds.datastream)
      
      If bits_remaining(*ds) < 8
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      
      *Data\eci = take_bits(*ds, 8)
      
      If (*Data\eci & $c0) = $80
        If bits_remaining(*ds) < 8
          ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
        EndIf
        
        *Data\eci = (*Data\eci << 8) | take_bits(*ds, 8)
      ElseIf (*Data\eci & $e0) = $c0
        If bits_remaining(*ds) < 16
          ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
        EndIf
        
        *Data\eci = (*Data\eci << 16) | take_bits(*ds, 16)
      EndIf
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
    
    Procedure.i decode_kanji(*Data.quirc_data, *ds.datastream)
      Protected.u sjw
      Protected.i bits, count, i, d, msB, lsB, intermediate
      
      bits = 12
      
      If *Data\version < 10
        bits = 8
      ElseIf *Data\version < 27
        bits = 10
      EndIf
      
      count = take_bits(*ds, bits)
      If *Data\payload_len + count * 2 + 1 > #QUIRC_MAX_PAYLOAD
        ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
      EndIf
      If bits_remaining(*ds) < count * 13
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      
      For i = 0 To count - 1
        d = take_bits(*ds, 13)
        msB = d / $c0
        lsB = d % $c0
        intermediate = (msB << 8) | lsB
        
        If intermediate + $8140 <= $9ffc
          ; bytes are in the range 0x8140 To 0x9FFC
          sjw = intermediate + $8140
        Else
          ; bytes are in the range 0xE040 To 0xEBBF
          sjw = intermediate + $c140
        EndIf
        
        *Data\payload[*Data\payload_len] = sjw >> 8
        *Data\payload_len + 1
        *Data\payload[*Data\payload_len] = sjw & $ff
        *Data\payload_len + 1
      Next i
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
    
    Procedure.i decode_byte(*Data.quirc_data, *ds.datastream)
      Protected.i bits, count, i
      
      bits = 16
      
      If *Data\version < 10
        bits = 8
      EndIf
      
      count = take_bits(*ds, bits)
      If *Data\payload_len + count + 1 > #QUIRC_MAX_PAYLOAD
        ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
      EndIf
      If bits_remaining(*ds) < count * 8
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      
      For i = 0 To count - 1
        *Data\payload[*Data\payload_len] = take_bits(*ds, 8)
        *Data\payload_len + 1
      Next i
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
    
    Procedure.i decode_alpha(*Data.quirc_data, *ds.datastream)
      Protected.i bits, count
  
      bits = 13
      
      If *Data\version < 10
        bits = 9
      ElseIf *Data\version < 27
        bits = 11
      EndIf
      
      count = take_bits(*ds, bits)
      If *Data\payload_len + count + 1 > #QUIRC_MAX_PAYLOAD
        ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
      EndIf
      
      While count >= 2
        If alpha_tuple(*Data, *ds, 11, 2) < 0
          ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
        EndIf
        count - 2
      Wend
      
      If count
        If alpha_tuple(*Data, *ds, 6, 1) < 0
          ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
        EndIf
        count - 1
      EndIf
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure  
    
    Procedure.i decode_numeric(*Data.quirc_data, *ds.datastream)
      Protected.i bits, count
  
      bits = 14
      
      If *Data\version < 10
        bits = 10
      ElseIf *Data\version < 27
        bits = 12
      EndIf
      
      count = take_bits(*ds, bits)
      If *Data\payload_len + count + 1 > #QUIRC_MAX_PAYLOAD
        ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
      EndIf
      
      While count >= 3
        If numeric_tuple(*Data, *ds, 10, 3) < 0
          ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
        EndIf
        count - 3
      Wend
      
      If count >= 2
        If numeric_tuple(*Data, *ds, 7, 2) < 0
          ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
        EndIf
        count - 2
      EndIf
      
      If count
        If numeric_tuple(*Data, *ds, 4, 1) < 0
          ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
        EndIf
        count - 1
      EndIf
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
    
    Procedure.i decode_payload(*Data.quirc_data, *ds.datastream)
      Protected.i err, type
      
      While bits_remaining(*ds) >= 4
        err = #QUIRC_SUCCESS
        type = take_bits(*ds, 4)
        
        Select type
          Case #QUIRC_DATA_TYPE_NUMERIC : err = decode_numeric(*Data, *ds)
          Case #QUIRC_DATA_TYPE_ALPHA : err = decode_alpha(*Data, *ds)
          Case #QUIRC_DATA_TYPE_BYTE : err = decode_byte(*Data, *ds)
          Case #QUIRC_DATA_TYPE_KANJI : err = decode_kanji(*Data, *ds)
          Case 7: err = decode_eci(*Data, *ds)
          Default
            ; Add nul terminator To all payloads
            If *Data\payload_len >= SizeOf(*Data\payload)
              *Data\payload_len - 1
            EndIf
            *Data\payload[*Data\payload_len] = 0
            
            ProcedureReturn #QUIRC_SUCCESS
        EndSelect
        
        If err
          ProcedureReturn err
        EndIf
        
        If Not (type & (type - 1)) And (type > *Data\data_type)
          *Data\data_type = type
        EndIf
      Wend
      ; Add nul terminator To all payloads
      If *Data\payload_len >= SizeOf(*Data\payload)
        *Data\payload_len - 1
      EndIf
      *Data\payload[*Data\payload_len] = 0
      
      ProcedureReturn #QUIRC_SUCCESS   
    EndProcedure
    
    
    Procedure.i reserved_cell(version.i, i.i, j.i)
      Protected.i size, ai, aj, a, p
      Protected *ver.quirc_version_info
      
      
      *ver = ?quirc_version_db_0 + version * SizeOf(quirc_version_info)
      size = version * 4 + 17
      ai = -1
      aj = -1
      
      ; Finder + format: top left
      If i < 9 And j < 9
        ProcedureReturn #True
      EndIf
      
      ; Finder + format: bottom left
      If i + 8 >= size And j < 9
        ProcedureReturn #True
      EndIf
      
      ; Finder + format: top right
      If i < 9 And j + 8 >= size
        ProcedureReturn #True
      EndIf
      
      ; Exclude timing patterns
      If i = 6 Or j = 6
        ProcedureReturn #True
      EndIf
      
      ; Exclude version info, If it exists. Version info sits adjacent To
      ; the top-right And bottom-left finders in three rows, bounded by
      ; the timing pattern.
      If version >= 7
        If i < 6 And j + 11 >= size
          ProcedureReturn #True
        EndIf
        If i + 11 >= size And j < 6
          ProcedureReturn #True
        EndIf
      EndIf
      
      ; Exclude alignment patterns
      While a < #QUIRC_MAX_ALIGNMENT And *ver\apat[a]
        p = *ver\apat[a]
        
        If Abs(p - i) < 3
          ai = a
        EndIf
        If Abs(p - j) < 3
          aj = a
        EndIf
        a + 1
      Wend
      
      If ai >= 0 And aj >= 0
        a - 1
        If ai > 0 And ai < a
          ProcedureReturn #True
        EndIf
        If aj > 0 And aj < a
          ProcedureReturn #True
        EndIf
        If aj = a And ai = a
          ProcedureReturn #True
        EndIf
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i codestream_ecc(*Data.quirc_data, *ds.datastream)
      Protected.i lb_count, bc, ecc_offset, dst_offset, i, num_ec, err, j
      Protected *ver.quirc_version_info
      Protected.quirc_rs_params *sb_ecc, lb_ecc, *ecc
      Protected.AsciiArrayStructure *dst
      
      
      *ver = ?quirc_version_db_0 + *Data\version * SizeOf(quirc_version_info)
      *sb_ecc = @*ver\ecc[*Data\ecc_level]
      lb_count = (*ver\data_bytes - *sb_ecc\bs * *sb_ecc\ns) / (*sb_ecc\bs + 1)
      bc = lb_count + *sb_ecc\ns
      ecc_offset = *sb_ecc\dw * bc + lb_count
      
      CopyMemory(*sb_ecc, @lb_ecc, SizeOf(lb_ecc))
      lb_ecc\dw + 1
      lb_ecc\bs + 1
      
      For i = 0 To bc - 1
        *dst = @*ds\Data_[0] + dst_offset
        If i < *sb_ecc\ns
          *ecc = *sb_ecc
        Else
          *ecc = @lb_ecc
        EndIf
        num_ec = *ecc\bs - *ecc\dw
        
        For j = 0 To *ecc\dw - 1
          *dst\v[j] = *ds\raw[j * bc + i]
        Next j
        For j = 0 To num_ec - 1
          *dst\v[*ecc\dw + j] = *ds\raw[ecc_offset + j * bc + i]
        Next j
        
        err = correct_block(*dst, *ecc)
        If err
          ProcedureReturn err
        EndIf
        
        dst_offset + *ecc\dw
      Next i
      
      *ds\data_bits = dst_offset * 8
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
    
    
    Procedure.s data_type_str(dt.i)
      Protected Result$
  
      Select dt
        Case #QUIRC_DATA_TYPE_NUMERIC : Result$ = "NUMERIC"
        Case #QUIRC_DATA_TYPE_ALPHA :   Result$ = "ALPHA"
        Case #QUIRC_DATA_TYPE_BYTE :    Result$ = "BYTE"
        Case #QUIRC_DATA_TYPE_KANJI :   Result$ = "KANJI"
        Default : Result$ = "unknown"
      EndSelect
      
      ProcedureReturn Result$
    EndProcedure
    
    Procedure   dump_data(*Data.quirc_data)
      Debug "    Version: " + Str(*Data\version)
      Debug "    ECC level: " + Str(*Data\ecc_level)
      Debug "    Mask: " + Str(*Data\mask)
      Debug "    Data type: " + Str(*Data\data_type) + " (" + data_type_str(*Data\data_type) + ")"
      Debug "    Length: " + Str(*Data\payload_len)
      Debug "    Payload: " + PeekS(@*Data\payload[0], *Data\payload_len, #PB_Ascii)
      
      If *Data\eci
        Debug "    ECI: " + Str(*Data\eci)
      EndIf
      
    EndProcedure
    
    Procedure   dump_cells(*code.quirc_code)
      Protected.i u, v, p
      Protected Line$
      
      Line$ = #LF$ + "    " + Str(*code\size) + " cells, corners:"
      For u = 0 To 3
        Line$ + " (" + Str(*code\corners[u]\x) + "," + Str(*code\corners[u]\y) + ")"
      Next u
      Debug Line$
      
      For v = 0 To *code\size - 1
        Line$ = "    "
        For u = 0 To *code\size - 1
          p = v * *code\size + u
          
          If *code\cell_bitmap[p >> 3] & (1 << (p & 7))
            Line$ + "[]"
          Else
            Line$ + "  "
          EndIf
        Next u
        Debug Line$
      Next v
      
    EndProcedure
    
    
    Procedure.i mask_bit(mask.i, i.i, j.i)
      Protected Result.i
      
      Select mask
        Case 0: Result = ((i + j) % 2)
        Case 1: Result = (i % 2)
        Case 2: Result = (j % 3)
        Case 3: Result = ((i + j) % 3)
        Case 4: Result = (((i / 2) + (j / 3)) % 2)
        Case 5: Result = ((i * j) % 2 + (i * j) % 3)
        Case 6: Result = (((i * j) % 2 + (i * j) % 3) % 2)
        Case 7: Result = (((i * j) % 3 + (i + j) % 2) % 2)
        Default : Result = 0
      EndSelect
      
      If mask <= 7
        If Result > 0
          Result = 0
        Else
          Result = 1
        EndIf
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure   read_bit(*code.quirc_code, *Data.quirc_data, *ds.datastream, i.i, j.i)
      Protected.i bitpos, bytepos, v
      
      bitpos = *ds\data_bits & 7
      bytepos = *ds\data_bits >> 3
      v = grid_bit(*code, j, i)
      
      If mask_bit(*Data\mask, i, j)
        v ! 1
      EndIf
      
      If v
        *ds\raw[bytepos] | ($80 >> bitpos)
      EndIf
      
      *ds\data_bits + 1
      
    EndProcedure
    
    Procedure   read_data(*code.quirc_code, *Data.quirc_data, *ds.datastream)
      Protected.i y, x, dir
      
      y = *code\size - 1
      x = *code\size - 1
      dir = -1
      
      While x > 0
        If x = 6
          x - 1
        EndIf
        
        If Not reserved_cell(*Data\version, y, x)
          read_bit(*code, *Data, *ds, y, x)
        EndIf
        
        If Not reserved_cell(*Data\version, y, x - 1)
          read_bit(*code, *Data, *ds, y, x - 1)
        EndIf
        
        y + dir
        If y < 0 Or y >= *code\size
          dir = -dir
          x - 2
          y + dir
        EndIf
      Wend
      
    EndProcedure
    
    Procedure.i read_format(*code.quirc_code, *Data.quirc_data, which.i)
      Protected.u format, fdata
      Protected.i i, err
      Protected.AsciiArrayStructure *xs, *ys
      
      
      DataSection
        xs:
        Data.a 8, 8, 8, 8, 8, 8, 8, 8, 7, 5, 4, 3, 2, 1, 0
        ys:
        Data.a 0, 1, 2, 3, 4, 5, 7, 8, 8, 8, 8, 8, 8, 8, 8
      EndDataSection
      
      *xs = ?xs
      *ys = ?ys
      
      If which
        For i = 0 To 6
          format = (format << 1) | grid_bit(*code, 8, *code\size - 1 - i)
        Next i
        For i = 0 To 7
          format = (format << 1) | grid_bit(*code, *code\size - 8 + i, 8)
        Next i
      Else
        For i = 14 To 0 Step -1
          format = (format << 1) | grid_bit(*code, *xs\v[i], *ys\v[i])
        Next i
      EndIf
      
      format ! $5412
      
      err = correct_format(@format)
      If err
        ProcedureReturn err
      EndIf
      
      fdata = format >> 10
      *Data\ecc_level = fdata >> 3
      *Data\mask = fdata & 7
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
  
    Procedure.i read_cell(*q.quirc, index.i, x.i, y.i)
      ; Read a cell from a grid using the currently set perspective
      ; transform. Returns +/- 1 For black/white, 0 For cells which are
      ; out of image bounds.
      Protected *qr.quirc_grid, p.quirc_point
      
  
      *qr = @*q\grids[index]
      
      perspective_map(@*qr\c, x + 0.5, y + 0.5, @p)
      If p\y < 0 Or p\y >= *q\h Or p\x < 0 Or p\x >= *q\w
        ProcedureReturn 0
      EndIf
      
      If *q\pixels\v[p\y * *q\w + p\x]
        ProcedureReturn 1
      Else
        ProcedureReturn -1
      EndIf
      
    EndProcedure  
    
    
    Procedure.s quirc_version()
      ProcedureReturn "1.0"
    EndProcedure
    
    Procedure.s quirc_strerror(err.i)
      Protected Error$
  
      Select err
        Case #QUIRC_SUCCESS : Error$ = "Success"
        Case #QUIRC_ERROR_INVALID_GRID_SIZE : Error$ = "Invalid grid size"
        Case #QUIRC_ERROR_INVALID_VERSION : Error$ = "Invalid version"
        Case #QUIRC_ERROR_FORMAT_ECC : Error$ = "Format data ECC failure"
        Case #QUIRC_ERROR_DATA_ECC : Error$ = "ECC failure"
        Case #QUIRC_ERROR_UNKNOWN_DATA_TYPE : Error$ = "Unknown data type"
        Case #QUIRC_ERROR_DATA_OVERFLOW : Error$ = "Data overflow"
        Case #QUIRC_ERROR_DATA_UNDERFLOW : Error$ = "Data underflow"
        Default : Error$ = "Unknown error"
      EndSelect
      
      ProcedureReturn Error$
    EndProcedure
  
    Procedure   quirc_destroy(*q.quirc)
      
      FreeMemory(*q\image)
      ; q->pixels may alias q->image when their type representation is of the
      ;   same size, so we need To be careful here To avoid a double free
      If Not #QUIRC_PIXEL_ALIAS_IMAGE
        FreeMemory(*q\pixels)
      EndIf
      FreeMemory(*q)
      
    EndProcedure
    
    Procedure   quirc_flip(*code.quirc_code)
      Protected.i offset, y, x
      Protected flipped.quirc_code
      
      
      For y = 0 To *code\size - 1
        For x = 0 To *code\size - 1
          If grid_bit(*code, y, x)
            flipped\cell_bitmap[offset >> 3] | (1 << (offset & 7))
          EndIf
          offset + 1
        Next x
      Next y
      
      CopyMemory(@flipped\cell_bitmap, @*code\cell_bitmap, SizeOf(flipped\cell_bitmap))
      
    EndProcedure
    
    Procedure.i quirc_decode(*code.quirc_code, *Data.quirc_data)
      Protected.i err
      Protected ds.datastream
      
  
      If (*code\size - 17) % 4
        ProcedureReturn #QUIRC_ERROR_INVALID_GRID_SIZE
      EndIf
      
      FillMemory(*Data, SizeOf(*data), 0)
      FillMemory(@ds, SizeOf(ds), 0)
      
      *Data\version = (*code\size - 17) / 4
      
      If *Data\version < 1 Or *Data\version > #QUIRC_MAX_VERSION
        ProcedureReturn #QUIRC_ERROR_INVALID_VERSION
      EndIf
      
      ; Read format information -- try both locations
      err = read_format(*code, *Data, 0)
      If err
        err = read_format(*code, *Data, 1)
        If err
          ProcedureReturn err
        EndIf
      EndIf
      
      read_data(*code, *Data, @ds)
      err = codestream_ecc(*Data, @ds)
      If err
        ProcedureReturn err
      EndIf
      
      err = decode_payload(*Data, @ds)
      If err
        ProcedureReturn err
      EndIf
      
      ProcedureReturn #QUIRC_SUCCESS
    EndProcedure
    
    Procedure   quirc_extract(*q.quirc, index.i, *code.quirc_code)
      Protected.i y, i, x
      Protected *qr.quirc_grid
      
      
      *qr = @*q\grids[index]
      
      If index < 0 Or index > *q\num_grids
        ProcedureReturn 
      EndIf
      
      FillMemory(*code, SizeOf(*code), 0)
      
      perspective_map(@*qr\c, 0.0, 0.0, @*code\corners[0])
      perspective_map(@*qr\c, *qr\grid_size, 0.0, @*code\corners[1])
      perspective_map(@*qr\c, *qr\grid_size, *qr\grid_size, @*code\corners[2])
      perspective_map(@*qr\c, 0.0, *qr\grid_size, @*code\corners[3])
      
      *code\size = *qr\grid_size
      
      For y = 0 To *qr\grid_size - 1
        For x = 0 To *qr\grid_size - 1
          If read_cell(*q, index, x, y) > 0
            *code\cell_bitmap[i >> 3] | (1 << (i & 7))
          EndIf
          i + 1
        Next x
      Next y
      
    EndProcedure
    
    Procedure.i quirc_count(*q.quirc)
      ProcedureReturn *q\num_grids
    EndProcedure  
    
    Procedure   quirc_end(*q.quirc)
      Protected.a threshold
      Protected.i i
      
      
      threshold = otsu(*q)
      pixels_setup(*q, threshold)
      
      For i = 0 To *q\h - 1
        finder_scan(*q, i)
      Next i
      
      For i = 0 To *q\num_capstones - 1
        test_grouping(*q, i)
      Next i
      
    EndProcedure
    
    Procedure.i quirc_begin(*q.quirc, *w.Integer, *h.Integer)
      
      
      *q\num_regions = #QUIRC_PIXEL_REGION
      *q\num_capstones = 0
      *q\num_grids = 0
      
      If *w
        *w\i = *q\w
      EndIf
      
      If *h
        *h\i = *q\h
      EndIf
      
      ProcedureReturn *q\image
      
    EndProcedure
    
    Procedure.i quirc_resize(*q.quirc, w.i, h.i)
      Protected olddim.i, newdim.i, min.i
      Protected *image.Ascii
      Protected *pixels.quirc_pixel_ptr
      
      
      ; XXX: w And h should be size_t (Or at least unsigned) As negatives
      ; values would Not make much sense. The downside is that it would Break
      ; both the API And ABI. Thus, at the moment, let's just do a sanity
      ; check.
      If w <= 0 Or h <= 0
        ProcedureReturn -1
      EndIf
      
      ; alloc a new buffer For q->image. We avoid realloc(3) because we want
      ; on failure To be leave `q` in a consistant, unmodified state.
      *image = AllocateMemory(w * h)
      If Not *image
        ProcedureReturn -1
      EndIf
      
      ; compute the "old" (i.e. currently allocated) And the "new"
      ; (i.e. requested) image dimensions
      olddim = *q\w * *q\h
      newdim = w * h
      If olddim < newdim
        min = olddim
      Else
        min = newdim
      EndIf
      
      ; copy the Data into the new buffer, avoiding (a) To Read beyond the
      ; old buffer when the new size is greater And (b) To write beyond the
      ; new buffer when the new size is smaller, hence the min computation.
      If *q\image
        CopyMemory(*q\image, *image, min)
      EndIf
      
      ; alloc a new buffer For q->pixels If needed
      If Not #QUIRC_PIXEL_ALIAS_IMAGE
        *pixels = AllocateMemory(newdim * SizeOf(quirc_pixel_ptr))
        If Not *pixels
          FreeMemory(*image)
          ProcedureReturn -1
        EndIf
      EndIf
      
      ; alloc succeeded, update `q` With the new size And buffers */
      *q\w = w
      *q\h = h
      If *q\image
        FreeMemory(*q\image)
      EndIf
      *q\image = *image
      If Not #QUIRC_PIXEL_ALIAS_IMAGE
        FreeMemory(*q\pixels)
        *q\pixels = *pixels
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i quirc_new()
      ProcedureReturn AllocateMemory(SizeOf(quirc))
    EndProcedure
    
    
    Procedure.i ImageToGrayScaleBuffer(Img.i)
      Protected.i ImgWidth, ImgHeight, PixelBytes, LinePadBytes, X, Y
      Protected *Buffer, *BufferPos.Ascii, *ImgPos.rgba
      
      If IsImage(Img)
        
        If StartDrawing(ImageOutput(Img))
          
          ImgWidth = ImageWidth(Img)
          ImgHeight = ImageHeight(Img)
          
          *Buffer = AllocateMemory(ImgWidth * ImgHeight, #PB_Memory_NoClear)
          If *Buffer
            PixelBytes = 3
            *ImgPos = DrawingBuffer()
            
            If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_RGB : PixelBytes = 4 : EndIf
            If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_BGR : PixelBytes = 4 : EndIf
            LinePadBytes = DrawingBufferPitch() - (ImgWidth * PixelBytes)
            
            ;Debug "PixelBytes: " + Str(PixelBytes)
            
            ImgWidth - 1
            ImgHeight - 1
            
            *BufferPos = *Buffer
            
            For Y = 0 To ImgHeight
              For X = 0 To ImgWidth
                ;Debug Hex(*ImgPos\a) + " " + Hex(*ImgPos\r) + " " + Hex(*ImgPos\g) + " " + Hex(*ImgPos\b)
                If PixelBytes = 3
                  *BufferPos\a = (*ImgPos\r + *ImgPos\g  + *ImgPos\b) / 3
                Else
                  ;*BufferPos\a = (*ImgPos\r + *ImgPos\g  + *ImgPos\b + *ImgPos\a) / 4
                  If *ImgPos\a > 127
                    *BufferPos\a = (*ImgPos\r + *ImgPos\g  + *ImgPos\b) / 3
                  Else
                    *BufferPos\a = $FF
                  EndIf
                EndIf
                ;*BufferPos\a = 0.2990 * *ImgPos\r + 0.5870 * *ImgPos\g  + 0.1140 * *ImgPos\b ; TV
                ;*BufferPos\a = 0.2126 * *ImgPos\r + 0.7152 * *ImgPos\g  + 0.0722 * *ImgPos\b ; ITU-R BT.709 HDTV and CIE 1931 sRGB
                ;*BufferPos\a = 0.2627 * *ImgPos\r + 0.6780 * *ImgPos\g  + 0.0593 * *ImgPos\b ; ITU-R BT.2100 HDR
                *BufferPos + 1
                *ImgPos + PixelBytes
              Next X
              *ImgPos + LinePadBytes
            Next Y
            
          EndIf
          StopDrawing()
        EndIf
        
      EndIf
      
      ProcedureReturn *Buffer
      
    EndProcedure
  
  CompilerEndIf
  
  ;- ============================================================================
	;- Module - Drawing
	;- ============================================================================
  
  CompilerIf #Enable_Generate_QRCodes
  
    Procedure.i CreateQRCode_(ImageNum.i=#PB_Any)
      Define.i X, Y, BufferLen, QRSize
      Define   *QRCode, *Buffer
      
      If IsImage(QRCode()\Image) : FreeImage(QRCode()\Image) : EndIf
      
      BufferLen = BUFFER_LEN_FOR_VERSION(QRCode()\MaxVersion)
      
      *QRCode = AllocateMemory(BufferLen)
      If *QRCode
        
        *Buffer = AllocateMemory(BufferLen)
        If *Buffer
          
          If encodeText(QRCode()\Text, *Buffer, *QRCode, QRCode()\errCorLvl, QRCode()\MinVersion, QRCode()\MaxVersion, QRCode()\Mask, QRCode()\BoostEcl)
            
            QRSize = getSize(*QRCode)
            If QRSize > 0
              
              If ImageNum = #PB_Any
                QRCode()\Image = CreateImage(#PB_Any, QRSize + (QRCode()\QuietZone * 2), QRSize + (QRCode()\QuietZone * 2))
              Else  
                QRCode()\Image = ImageNum
                CreateImage(ImageNum, QRSize + (QRCode()\QuietZone * 2), QRSize + (QRCode()\QuietZone * 2))
              EndIf 
              
              If IsImage(QRCode()\Image)
  
                If StartDrawing(ImageOutput(QRCode()\Image))
                
                  Box(0, 0, QRSize + (QRCode()\QuietZone * 2), QRSize + (QRCode()\QuietZone * 2), QRCode()\Color\Back)
                  
                  For Y=0 To QRSize - 1
                    For X=0 To QRSize - 1
                      If getModule(*QRCode, X, Y)
                        Plot(X + QRCode()\QuietZone, Y + QRCode()\QuietZone, QRCode()\Color\Front)
                      EndIf
                    Next
                  Next
                
                  StopDrawing()
                EndIf
      
              EndIf
              
            EndIf
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
        FreeMemory(*QRCode)
      EndIf
      
      ProcedureReturn QRCode()\Image
    EndProcedure  

    CompilerIf #Enable_Gadget
    
      Procedure   Draw_()
        Define.i Width, Height, Size, X, Y
        
        Width  = GadgetWidth(QRCode()\Gadget)
        Height = GadgetHeight(QRCode()\Gadget)
        
        If Width < Height
          Size = Width
        Else
          Size = Height
        EndIf 
        
        If IsImage(QRCode()\Image) : ResizeImage(QRCode()\Image, dpiX(Size), dpiY(Size), #PB_Image_Raw) : EndIf
        
        If StartDrawing(CanvasOutput(QRCode()\Gadget))
          
          X = (Width - Size) / 2
          Y = (Height - Size) / 2
          
          If X < 0 : X = 0 : EndIf
          If Y < 0 : Y = 0 : EndIf
          
          Box(0, 0, dpiX(Width), dpiY(Height), QRCode()\Color\Back)
          
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          DrawImage(ImageID(QRCode()\Image), X, Y)
          
          StopDrawing()
        EndIf
        
      EndProcedure
      
    CompilerEndIf
  
  CompilerEndIf
  
  ;- =================================================
	;-   Module - Events
	;- =================================================
  
  CompilerIf #Enable_Generate_QRCodes
  
    CompilerIf #Enable_Gadget
    
    	Procedure _ResizeHandler()
    		Define.i GadgetID = EventGadget()
    		
    		If FindMapElement(QRCode(), Str(GadgetID))
    		  CreateQRCode_()
    		  Draw_()
    		EndIf
    
    	EndProcedure
    	
    	Procedure _ResizeWindowHandler()
    		Define.f X, Y, Width, Height
    		Define.f OffSetX, OffSetY
    
    		ForEach QRCode()
    
    			If IsGadget(QRCode()\Gadget)
    
    				If QRCode()\Flags & #AutoResize
    
    					If IsWindow(QRCode()\Window)
    
    						OffSetX = WindowWidth(QRCode()\Window)  - QRCode()\WinWidth
    						OffsetY = WindowHeight(QRCode()\Window) - QRCode()\WinHeight
    
    						If QRCode()\Size\Flags
    
    							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
    
    							If QRCode()\Size\Flags & #MoveX  : X = QRCode()\Size\X + OffSetX : EndIf
    							If QRCode()\Size\Flags & #MoveY  : Y = QRCode()\Size\Y + OffSetY : EndIf
    							If QRCode()\Size\Flags & #Width  : Width  = QRCode()\Size\Width  + OffSetX : EndIf
    							If QRCode()\Size\Flags & #Height : Height = QRCode()\Size\Height + OffSetY : EndIf
    							
    							ResizeGadget(QRCode()\Gadget, X, Y, Width, Height)
    						Else
    						  ResizeGadget(QRCode()\Gadget, #PB_Ignore, #PB_Ignore, QRCode()\Size\Width + OffSetX, QRCode()\Size\Height + OffsetY)
    						EndIf
    
    					EndIf
    
    				EndIf
    
    			EndIf
    
    		Next
    
    	EndProcedure
    	
    	Procedure _CloseWindowHandler()
      Define.i Window = EventWindow()
      
      ForEach QRCode()
       
        If QRCode()\Window = Window
          
          If IsImage(QRCode()\Image) : FreeImage(QRCode()\Image) : EndIf
          
          DeleteMapElement(QRCode())
          
        EndIf
        
      Next
      
    EndProcedure
    
    CompilerEndIf
    
  CompilerEndIf
  
	;- ==========================================================================
	;- Module - Declared Procedures
	;- ==========================================================================  
  
  CompilerIf #Enable_Generate_QRCodes
    
    Procedure.i Create(ImageNum.i, Text.s, Width.i=#PB_Default, Height.i=#PB_Default)
      Define.i Size, MapElement
      
      If FindMapElement(QRCode(), "QRCode")
        MapElement = #True
      Else
        MapElement = AddMapElement(QRCode(), "QRCode")
      EndIf
      
      If MapElement
        
        QRCode()\Text        = Text
        
        QRCode()\Size\Width  = Width
        QRCode()\Size\Height = Height
        
        QRCode()\ErrCorLvl   = #Ecc_LOW
        QRCode()\BoostEcl    = #True
        QRCode()\MinVersion  = #VERSION_MIN
        QRCode()\MaxVersion  = #VERSION_MAX
        QRCode()\Mask        = #Mask_AUTO
        QRCode()\QuietZone   = 2
        
        QRCode()\Color\Front         = $000000
  			QRCode()\Color\Back          = $FFFFFF
        
        CreateQRCode_(ImageNum)
  
        If Width <> #PB_Default And Height <> #PB_Default
          
          If Width < Height
            Size = Width
          Else
            Size = Height
          EndIf 
          
          If IsImage(QRCode()\Image) : ResizeImage(QRCode()\Image, Size, Size, #PB_Image_Raw) : EndIf
          
        EndIf
      
        ProcedureReturn QRCode()\Image
      EndIf
      
    EndProcedure
    
    Procedure   SetDefaults(ErrCorLvl.i=#Ecc_LOW, BoostEcl.i=#True, MinVersion.i=#VERSION_MIN, MaxVersion.i=#VERSION_MAX, Mask.i=#Mask_AUTO, QuietZone.i=2)
      Define.i MapElement
      
      If FindMapElement(QRCode(), "QRCode")
        MapElement = #True
      Else
        MapElement = AddMapElement(QRCode(), "QRCode")
      EndIf
      
      If MapElement
        QRCode()\ErrCorLvl  = ErrCorLvl
        QRCode()\BoostEcl   = BoostEcl
        QRCode()\MinVersion = MinVersion
        QRCode()\MaxVersion = MaxVersion
        QRCode()\Mask       = Mask
        QRCode()\QuietZone  = QuietZone
      EndIf
  
    EndProcedure
    
    CompilerIf #Enable_Gadget
    
      Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
        Define.i Result, Border = #False
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
        CompilerEndIf
        
        Result = CanvasGadget(GNum, X, Y, Width, Height)
        If Result
      
          If GNum = #PB_Any : GNum = Result : EndIf
          
          If AddMapElement(QRCode(), Str(GNum))
            
            QRCode()\Gadget = GNum
            
            If WindowNum = #PB_Default
              QRCode()\Window = GetGadgetWindow()
            Else
              QRCode()\Window = WindowNum
            EndIf
            
            If Flags & #AutoResize
              If IsWindow(QRCode()\Window)
                QRCode()\WinWidth  = WindowWidth(QRCode()\Window)
                QRCode()\WinHeight = WindowHeight(QRCode()\Window)
                BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), QRCode()\Window)
              EndIf   
            EndIf 
            
            QRCode()\ErrCorLvl   = #Ecc_LOW
            QRCode()\BoostEcl    = #True
            QRCode()\MinVersion  = #VERSION_MIN
            QRCode()\MaxVersion  = #VERSION_MAX
            QRCode()\Mask        = #Mask_AUTO
            QRCode()\QuietZone   = 2
            
            QRCode()\Flags       = Flags
            
            QRCode()\Size\X      = X
            QRCode()\Size\Y      = Y
            QRCode()\Size\Width  = Width
            QRCode()\Size\Height = Height
    
            ;{ Color
            QRCode()\Color\Front         = $000000
    				QRCode()\Color\Back          = $FFFFFF
    				QRCode()\Color\Gadget        = $F0F0F0
            
            CompilerSelect #PB_Compiler_OS 
    					CompilerCase #PB_OS_Windows
    						QRCode()\Color\Front     = GetSysColor_(#COLOR_WINDOWTEXT)
    						QRCode()\Color\Back      = GetSysColor_(#COLOR_WINDOW)
    						QRCode()\Color\Gadget    = GetSysColor_(#COLOR_MENU)
    					CompilerCase #PB_OS_MacOS
    						QRCode()\Color\Front     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
    						QRCode()\Color\Back      = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
    						QRCode()\Color\Gadget    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
    					CompilerCase #PB_OS_Linux
    
    				CompilerEndSelect ;}
    				
    				BindGadgetEvent(QRCode()\Gadget, @_ResizeHandler(), #PB_EventType_Resize)
    				
    				BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), QRCode()\Window)
    				
    				ProcedureReturn QRCode()\Gadget
          EndIf
          
    		EndIf
    		
      EndProcedure  
      
    
      Procedure.s GetText(GNum.i)
        
        If FindMapElement(QRCode(), Str(GNum))
          ProcedureReturn QRCode()\Text
        EndIf  
        
      EndProcedure  
      
      Procedure.i GetColor(GNum.i, ColorTyp.i)
        
        If FindMapElement(QRCode(), Str(GNum))
        
          Select ColorTyp
            Case #FrontColor
              ProcedureReturn QRCode()\Color\Front
            Case #BackColor
              ProcedureReturn QRCode()\Color\Back
          EndSelect
    
        EndIf
        
      EndProcedure
      
      
      Procedure   SetText(GNum.i, Text.s, Flags.i=#Code_39)
        
        If FindMapElement(QRCode(), Str(GNum))
          
          QRCode()\Text = UCase(Text)
          
          CreateQRCode_()
          
          Draw_()
    
        EndIf  
        
      EndProcedure  
      
      Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
        
        If FindMapElement(QRCode(), Str(GNum))
        
          Select ColorTyp
            Case #FrontColor
              QRCode()\Color\Front  = Value
            Case #BackColor
              QRCode()\Color\Back   = Value
          EndSelect
          
          CreateQRCode_()
          
          Draw_()
          
        EndIf
        
      EndProcedure
      
      Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
        
        If FindMapElement(QRCode(), Str(GNum))
          
          Select Attribute
            Case #ErrCorLvl
              QRCode()\ErrCorLvl  = Value
            Case #BoostEcl
              QRCode()\BoostEcl   = Value
            Case #MinVersion
              QRCode()\MinVersion = Value
            Case #MaxVersion
              QRCode()\MaxVersion = Value
            Case #Mask
              QRCode()\Mask       = Value
            Case #QuietZone  
              QRCode()\QuietZone  = Value
          EndSelect
          
        EndIf  
        
      EndProcedure  
      
      Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
        
        If FindMapElement(QRCode(), Str(GNum))
          QRCode()\Size\Flags = Flags
        EndIf  
       
      EndProcedure
      
    CompilerEndIf
    
  CompilerEndIf
  
  CompilerIf #Enable_Decode_QRCodes
    
    Procedure.s Decode(Image.i, Flags.i=#False) ; max. 600px
      ; Flags: #DumpCells | #DumpData | #Quiet
      Protected PayLoad$
      Protected.i width, height, count, i, err
      Protected *qr.quirc, *ImgBuffer
      Protected qcode.quirc_code, qdata.quirc_data
      Protected.f WFactor, HFactor
      
      If IsImage(Image)
        
        ;{ Resize Image
        WFactor = 1.0
        If ImageWidth(Image) > 800
          WFactor = 800 / ImageWidth(Image)
        EndIf
        
        HFactor = 1.0
        If ImageHeight(Image) > 600
          HFactor = 600 / ImageHeight(Image)
        EndIf
        
        If WFactor <> 1 Or HFactor <> 1
          If WFactor < HFactor
            ResizeImage(Image, ImageWidth(Image) * WFactor, ImageHeight(Image) * WFactor)
          Else
            ResizeImage(Image, ImageWidth(Image) * HFactor, ImageHeight(Image) * HFactor)
          EndIf
        EndIf
        ;}
        
        *ImgBuffer = ImageToGrayScaleBuffer(Image)
        If *ImgBuffer
          
          *qr = quirc_new()
          If *qr
            
            If quirc_resize(*qr, ImageWidth(Image), ImageHeight(Image)) >= 0
              
              If quirc_begin(*qr, @width, @height)
                
                CopyMemory(*ImgBuffer, *qr\image, MemorySize(*ImgBuffer))
                
                quirc_end(*qr)
                
                count = quirc_count(*qr)
                
                For i = 0 To count - 1
                  
                  quirc_extract(*qr, i, @qcode)
                  
                  err = quirc_decode(@qcode, @qdata)
                  If err = #QUIRC_ERROR_DATA_ECC
                    quirc_flip(@qcode)
                    err = quirc_decode(@qcode, @qData)
                  EndIf
                  
                  If Flags & #DumpCells : dump_cells(@qcode) : EndIf  
                  
                  If err = #QUIRC_SUCCESS
                    If Flags & #DumpData : dump_data(@qdata) : EndIf 
                    PayLoad$ = PeekS(@qData\payload[0], qData\payload_len, #PB_Ascii)
                  Else
                    If Flags & #Quiet = #False : Debug quirc_strerror(err) : EndIf
                  EndIf
                  
                Next i
                
              EndIf
              
              quirc_destroy(*qr)
            Else
              If Flags & #Quiet = #False : Debug "Was not able to resize quirc" : EndIf
            EndIf
          Else
            If Flags & #Quiet = #False : Debug "Was not able to init quirc" : EndIf
          EndIf
          
          FreeMemory(*ImgBuffer)
        EndIf
        
      EndIf
      
      ProcedureReturn PayLoad$
    EndProcedure

  CompilerEndIf
  
  ;- ============================================================================
	;- Module - DataSection
	;- ============================================================================  
  
  CompilerIf #Enable_Generate_QRCodes
  
    DataSection
      ECC_CODEWORDS_PER_BLOCK: ; [4][41]
      Data.b -1,  7, 10, 15, 20, 26, 18, 20, 24, 30, 18, 20, 24, 26, 30, 22, 24, 28, 30, 28, 28, 28, 28, 30, 30, 26, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
      Data.b -1, 10, 16, 26, 18, 24, 16, 18, 22, 22, 26, 30, 22, 22, 24, 24, 28, 28, 26, 26, 26, 26, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28
      Data.b -1, 13, 22, 18, 26, 18, 24, 18, 22, 20, 24, 28, 26, 24, 20, 30, 24, 28, 28, 26, 30, 28, 30, 30, 30, 30, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
      Data.b -1, 17, 28, 22, 16, 22, 28, 26, 26, 24, 28, 24, 28, 22, 24, 24, 30, 28, 28, 26, 28, 30, 24, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
    EndDataSection
    
    DataSection
      NUM_ERROR_CORRECTION_BLOCKS: ; [4][41]
      Data.b -1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 4,  4,  4,  4,  4,  6,  6,  6,  6,  7,  8,  8,  9,  9, 10, 12, 12, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 24, 25
      Data.b -1, 1, 1, 1, 2, 2, 4, 4, 4, 5, 5,  5,  8,  9,  9, 10, 10, 11, 13, 14, 16, 17, 17, 18, 20, 21, 23, 25, 26, 28, 29, 31, 33, 35, 37, 38, 40, 43, 45, 47, 49
      Data.b -1, 1, 1, 2, 2, 4, 4, 6, 6, 8, 8,  8, 10, 12, 16, 12, 17, 16, 18, 21, 20, 23, 23, 25, 27, 29, 34, 34, 35, 38, 40, 43, 45, 48, 51, 53, 56, 59, 62, 65, 68
      Data.b -1, 1, 1, 2, 4, 4, 4, 5, 6, 8, 8, 11, 11, 16, 16, 18, 16, 19, 21, 25, 25, 25, 34, 30, 32, 35, 37, 40, 42, 45, 48, 51, 54, 57, 60, 63, 66, 70, 74, 77, 81
    EndDataSection
    
  CompilerEndIf
  
  CompilerIf #Enable_Decode_QRCodes

    DataSection ;{ alpha_map
      alpha_map:
      Data.a '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
      Data.a 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
      Data.a ' ', '$', '%', '*', '+', '-', '.', '/', ':'
    EndDataSection ;}
    
    DataSection ;{ gf16_exp / gf16_log / gf256_exp / gf256_log
      gf16_exp:
      Data.a $01, $02, $04, $08, $03, $06, $0c, $0b, $05, $0a, $07, $0e, $0f, $0d, $09, $01
      gf16_log:
      Data.a $00, $0f, $01, $04, $02, $08, $05, $0a, $03, $0e, $09, $07, $06, $0d, $0b, $0c
      gf256_exp:
      Data.a $01, $02, $04, $08, $10, $20, $40, $80
      Data.a $1d, $3a, $74, $e8, $cd, $87, $13, $26
      Data.a $4c, $98, $2d, $5a, $b4, $75, $ea, $c9
      Data.a $8f, $03, $06, $0c, $18, $30, $60, $c0
      Data.a $9d, $27, $4e, $9c, $25, $4a, $94, $35
      Data.a $6a, $d4, $b5, $77, $ee, $c1, $9f, $23
      Data.a $46, $8c, $05, $0a, $14, $28, $50, $a0
      Data.a $5d, $ba, $69, $d2, $b9, $6f, $de, $a1
      Data.a $5f, $be, $61, $c2, $99, $2f, $5e, $bc
      Data.a $65, $ca, $89, $0f, $1e, $3c, $78, $f0
      Data.a $fd, $e7, $d3, $bb, $6b, $d6, $b1, $7f
      Data.a $fe, $e1, $df, $a3, $5b, $b6, $71, $e2
      Data.a $d9, $af, $43, $86, $11, $22, $44, $88
      Data.a $0d, $1a, $34, $68, $d0, $bd, $67, $ce
      Data.a $81, $1f, $3e, $7c, $f8, $ed, $c7, $93
      Data.a $3b, $76, $ec, $c5, $97, $33, $66, $cc
      Data.a $85, $17, $2e, $5c, $b8, $6d, $da, $a9
      Data.a $4f, $9e, $21, $42, $84, $15, $2a, $54
      Data.a $a8, $4d, $9a, $29, $52, $a4, $55, $aa
      Data.a $49, $92, $39, $72, $e4, $d5, $b7, $73
      Data.a $e6, $d1, $bf, $63, $c6, $91, $3f, $7e
      Data.a $fc, $e5, $d7, $b3, $7b, $f6, $f1, $ff
      Data.a $e3, $db, $ab, $4b, $96, $31, $62, $c4
      Data.a $95, $37, $6e, $dc, $a5, $57, $ae, $41
      Data.a $82, $19, $32, $64, $c8, $8d, $07, $0e
      Data.a $1c, $38, $70, $e0, $dd, $a7, $53, $a6
      Data.a $51, $a2, $59, $b2, $79, $f2, $f9, $ef
      Data.a $c3, $9b, $2b, $56, $ac, $45, $8a, $09
      Data.a $12, $24, $48, $90, $3d, $7a, $f4, $f5
      Data.a $f7, $f3, $fb, $eb, $cb, $8b, $0b, $16
      Data.a $2c, $58, $b0, $7d, $fa, $e9, $cf, $83
      Data.a $1b, $36, $6c, $d8, $ad, $47, $8e, $01
      gf256_log:
      Data.a $00, $ff, $01, $19, $02, $32, $1a, $c6
      Data.a $03, $df, $33, $ee, $1b, $68, $c7, $4b
      Data.a $04, $64, $e0, $0e, $34, $8d, $ef, $81
      Data.a $1c, $c1, $69, $f8, $c8, $08, $4c, $71
      Data.a $05, $8a, $65, $2f, $e1, $24, $0f, $21
      Data.a $35, $93, $8e, $da, $f0, $12, $82, $45
      Data.a $1d, $b5, $c2, $7d, $6a, $27, $f9, $b9
      Data.a $c9, $9a, $09, $78, $4d, $e4, $72, $a6
      Data.a $06, $bf, $8b, $62, $66, $dd, $30, $fd
      Data.a $e2, $98, $25, $b3, $10, $91, $22, $88
      Data.a $36, $d0, $94, $ce, $8f, $96, $db, $bd
      Data.a $f1, $d2, $13, $5c, $83, $38, $46, $40
      Data.a $1e, $42, $b6, $a3, $c3, $48, $7e, $6e
      Data.a $6b, $3a, $28, $54, $fa, $85, $ba, $3d
      Data.a $ca, $5e, $9b, $9f, $0a, $15, $79, $2b
      Data.a $4e, $d4, $e5, $ac, $73, $f3, $a7, $57
      Data.a $07, $70, $c0, $f7, $8c, $80, $63, $0d
      Data.a $67, $4a, $de, $ed, $31, $c5, $fe, $18
      Data.a $e3, $a5, $99, $77, $26, $b8, $b4, $7c
      Data.a $11, $44, $92, $d9, $23, $20, $89, $2e
      Data.a $37, $3f, $d1, $5b, $95, $bc, $cf, $cd
      Data.a $90, $87, $97, $b2, $dc, $fc, $be, $61
      Data.a $f2, $56, $d3, $ab, $14, $2a, $5d, $9e
      Data.a $84, $3c, $39, $53, $47, $6d, $41, $a2
      Data.a $1f, $2d, $43, $d8, $b7, $7b, $a4, $76
      Data.a $c4, $17, $49, $ec, $7f, $0c, $6f, $f6
      Data.a $6c, $a1, $3b, $52, $29, $9d, $55, $aa
      Data.a $fb, $60, $86, $b1, $bb, $cc, $3e, $5a
      Data.a $cb, $59, $5f, $b0, $9c, $a9, $a0, $51
      Data.a $0b, $f5, $16, $eb, $7a, $75, $2c, $d7
      Data.a $4f, $ae, $d5, $e9, $e6, $e7, $ad, $e8
      Data.a $74, $d6, $f4, $ea, $a8, $50, $58, $af
    EndDataSection ;}
    
    DataSection ;{ quirc_version_db
      quirc_version_db_0:
      Data.u 0
      Data.a 0, 0, 0, 0, 0, 0, 0
      Data.a 0, 0, 0
      Data.a 0, 0, 0
      Data.a 0, 0, 0
      Data.a 0, 0, 0
      
      quirc_version_db_1:
      Data.u 26
      Data.a 0, 0, 0, 0, 0, 0, 0
      Data.a 26, 16, 1
      Data.a 26, 19, 1
      Data.a 26, 9, 1
      Data.a 26, 13, 1
      
      quirc_version_db_2:
      Data.u 44
      Data.a 6, 18, 0, 0, 0, 0, 0
      Data.a 44, 28, 1
      Data.a 44, 34, 1
      Data.a 44, 16, 1
      Data.a 44, 22, 1
      
      quirc_version_db_3:
      Data.u 70
      Data.a 6, 22, 0, 0, 0, 0, 0
      Data.a 70, 44, 1
      Data.a 70, 55, 1
      Data.a 35, 13, 2
      Data.a 35, 17, 2
      
      quirc_version_db_4:
      Data.u 100
      Data.a 6, 26, 0, 0, 0, 0, 0
      Data.a 50, 32, 2
      Data.a 100, 80, 1
      Data.a 25, 9, 4
      Data.a 50, 24, 2
      
      quirc_version_db_5:
      Data.u 134
      Data.a 6, 30, 0, 0, 0, 0, 0
      Data.a 67, 43, 2
      Data.a 134, 108, 1
      Data.a 33, 11, 2
      Data.a 33, 15, 2
      
      quirc_version_db_6:
      Data.u 172
      Data.a 6, 34, 0, 0, 0, 0, 0
      Data.a 43, 27, 4
      Data.a 86, 68, 2
      Data.a 43, 15, 4
      Data.a 43, 19, 4
      
      quirc_version_db_7:
      Data.u 196
      Data.a 6, 22, 38, 0, 0, 0, 0
      Data.a 49, 31, 4
      Data.a 98, 78, 2
      Data.a 39, 13, 4
      Data.a 32, 14, 2
      
      quirc_version_db_8:
      Data.u 242
      Data.a 6, 24, 42, 0, 0, 0, 0
      Data.a 60, 38, 2
      Data.a 121, 97, 2
      Data.a 40, 14, 4
      Data.a 40, 18, 4
      
      quirc_version_db_9:
      Data.u 292
      Data.a 6, 22, 46, 0, 0, 0, 0
      Data.a 58, 36, 3
      Data.a 146, 116, 2
      Data.a 36, 12, 4
      Data.a 36, 16, 4
      
      quirc_version_db_10:
      Data.u 346
      Data.a 6, 28, 50, 0, 0, 0, 0
      Data.a 69, 43, 4
      Data.a 86, 68, 2
      Data.a 43, 15, 6
      Data.a 43, 19, 6
      
      quirc_version_db_11:
      Data.u 404
      Data.a 6, 30, 54, 0, 0, 0, 0
      Data.a 80, 50, 1
      Data.a 101, 81, 4
      Data.a 36, 12, 3
      Data.a 50, 22, 4
      
      quirc_version_db_12:
      Data.u 466
      Data.a 6, 32, 58, 0, 0, 0, 0
      Data.a 58, 36, 6
      Data.a 116, 92, 2
      Data.a 42, 14, 7
      Data.a 46, 20, 4
      
      quirc_version_db_13:
      Data.u 532
      Data.a 6, 34, 62, 0, 0, 0, 0
      Data.a 59, 37, 8
      Data.a 133, 107, 4
      Data.a 33, 11, 12
      Data.a 44, 20, 8
      
      quirc_version_db_14:
      Data.u 581
      Data.a 6, 26, 46, 66, 0, 0, 0
      Data.a 64, 40, 4
      Data.a 145, 115, 3
      Data.a 36, 12, 11
      Data.a 36, 16, 11
      
      quirc_version_db_15:
      Data.u 655
      Data.a 6, 26, 48, 70, 0, 0, 0
      Data.a 65, 41, 5
      Data.a 109, 87, 5
      Data.a 36, 12, 11
      Data.a 54, 24, 5
      
      quirc_version_db_16:
      Data.u 733
      Data.a 6, 26, 50, 74, 0, 0, 0
      Data.a 73, 45, 7
      Data.a 122, 98, 5
      Data.a 45, 15, 3
      Data.a 43, 19, 15
      
      quirc_version_db_17:
      Data.u 815
      Data.a 6, 30, 54, 78, 0, 0, 0
      Data.a 74, 46, 10
      Data.a 135, 107, 1
      Data.a 42, 14, 2
      Data.a 50, 22, 1
      
      quirc_version_db_18:
      Data.u 901
      Data.a 6, 30, 56, 82, 0, 0, 0
      Data.a 69, 43, 9
      Data.a 150, 120, 5
      Data.a 42, 14, 2
      Data.a 50, 22, 17
      
      quirc_version_db_19:
      Data.u 991
      Data.a 6, 30, 58, 86, 0, 0, 0
      Data.a 70, 44, 3
      Data.a 141, 113, 3
      Data.a 39, 13, 9
      Data.a 47, 21, 17
      
      quirc_version_db_20:
      Data.u 1085
      Data.a 6, 34, 62, 90, 0, 0, 0
      Data.a 67, 41, 3
      Data.a 135, 107, 3
      Data.a 43, 15, 15
      Data.a 54, 24, 15
      
      quirc_version_db_21:
      Data.u 1156
      Data.a 6, 28, 50, 72, 92, 0, 0
      Data.a 68, 42, 17
      Data.a 144, 116, 4
      Data.a 46, 16, 19
      Data.a 50, 22, 17
      
      quirc_version_db_22:
      Data.u 1258
      Data.a 6, 26, 50, 74, 98, 0, 0
      Data.a 74, 46, 17
      Data.a 139, 111, 2
      Data.a 37, 13, 34
      Data.a 54, 24, 7
      
      quirc_version_db_23:
      Data.u 1364
      Data.a 6, 30, 54, 78, 102, 0, 0
      Data.a 75, 47, 4
      Data.a 151, 121, 4
      Data.a 45, 15, 16
      Data.a 54, 24, 11
      
      quirc_version_db_24:
      Data.u 1474
      Data.a 6, 28, 54, 80, 106, 0, 0
      Data.a 73, 45, 6
      Data.a 147, 117, 6
      Data.a 46, 16, 30
      Data.a 54, 24, 11
      
      quirc_version_db_25:
      Data.u 1588
      Data.a 6, 32, 58, 84, 110, 0, 0
      Data.a 75, 47, 8
      Data.a 132, 106, 8
      Data.a 45, 15, 22
      Data.a 54, 24, 7
      
      quirc_version_db_26:
      Data.u 1706
      Data.a 6, 30, 58, 86, 114, 0, 0
      Data.a 74, 46, 19
      Data.a 142, 114, 10
      Data.a 46, 16, 33
      Data.a 50, 22, 28
      
      quirc_version_db_27:
      Data.u 1828
      Data.a 6, 34, 62, 90, 118, 0, 0
      Data.a 73, 45, 22
      Data.a 152, 122, 8
      Data.a 45, 15, 12
      Data.a 53, 23, 8
      
      quirc_version_db_28:
      Data.u 1921
      Data.a 6, 26, 50, 74, 98, 122, 0
      Data.a 73, 45, 3
      Data.a 147, 117, 3
      Data.a 45, 15, 11
      Data.a 54, 24, 4
      
      quirc_version_db_29:
      Data.u 2051
      Data.a 6, 30, 54, 78, 102, 126, 0
      Data.a 73, 45, 21
      Data.a 146, 116, 7
      Data.a 45, 15, 19
      Data.a 53, 23, 1
      
      quirc_version_db_30:
      Data.u 2185
      Data.a 6, 26, 52, 78, 104, 130, 0
      Data.a 75, 47, 19
      Data.a 145, 115, 5
      Data.a 45, 15, 23
      Data.a 54, 24, 15
      
      quirc_version_db_31:
      Data.u 2323
      Data.a 6, 30, 56, 82, 108, 134, 0
      Data.a 74, 46, 2
      Data.a 145, 115, 13
      Data.a 45, 15, 23
      Data.a 54, 24, 42
      
      quirc_version_db_32:
      Data.u 2465
      Data.a 6, 34, 60, 86, 112, 138, 0
      Data.a 74, 46, 10
      Data.a 145, 115, 17
      Data.a 45, 15, 19
      Data.a 54, 24, 10
      
      quirc_version_db_33:
      Data.u 2611
      Data.a 6, 30, 58, 86, 114, 142, 0
      Data.a 74, 46, 14
      Data.a 145, 115, 17
      Data.a 45, 15, 11
      Data.a 54, 24, 29
      
      quirc_version_db_34:
      Data.u 2761
      Data.a 6, 34, 62, 90, 118, 146, 0
      Data.a 74, 46, 14
      Data.a 145, 115, 13
      Data.a 46, 16, 59
      Data.a 54, 24, 44
      
      quirc_version_db_35:
      Data.u 2876
      Data.a 6, 30, 54, 78, 102, 126, 150
      Data.a 75, 47, 12
      Data.a 151, 121, 12
      Data.a 45, 15, 22
      Data.a 54, 24, 39
      
      quirc_version_db_36:
      Data.u 3034
      Data.a 6, 24, 50, 76, 102, 128, 154
      Data.a 75, 47, 6
      Data.a 151, 121, 6
      Data.a 45, 15, 2
      Data.a 54, 24, 46
      
      quirc_version_db_37:
      Data.u 3196
      Data.a 6, 28, 54, 80, 106, 132, 158
      Data.a 74, 46, 29
      Data.a 152, 122, 17
      Data.a 45, 15, 24
      Data.a 54, 24, 49
      
      quirc_version_db_38:
      Data.u 3362
      Data.a 6, 32, 58, 84, 110, 136, 162
      Data.a 74, 46, 13
      Data.a 152, 122, 4
      Data.a 45, 15, 42
      Data.a 54, 24, 48
      
      quirc_version_db_39:
      Data.u 3532
      Data.a 6, 26, 54, 82, 110, 138, 166
      Data.a 75, 47, 40
      Data.a 147, 117, 20
      Data.a 45, 15, 10
      Data.a 54, 24, 43
      
      quirc_version_db_40:
      Data.u 3706
      Data.a 6, 30, 58, 86, 114, 142, 170
      Data.a 75, 47, 18
      Data.a 148, 118, 19
      Data.a 45, 15, 20
      Data.a 54, 24, 34
    EndDataSection ;}

  CompilerEndIf
  
EndModule


CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 0
  
  ; 0: QRCode::Gadget()
  ; 1: QRCode::Create()
  ; 2: QRCode::Decode()
  
  Enumeration 1
    #Window
    #Gadget
    #Image
  EndEnumeration
  
  
  CompilerSelect #Example
    CompilerCase 1  ; QRCode::Create()
      
      CompilerIf QRCode::#Enable_Generate_QRCodes
        
        UsePNGImageEncoder()
        
        If OpenWindow(#Window, 0, 0, 200, 200, "QRCode - Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered)
  
          ImageGadget(#Gadget, 10, 10, 180, 18, #False)
  
          QRCode::Create(#Image, "Hello World", 180, 180)
          
          SetGadgetState(#Gadget, ImageID(#Image))
          
          Repeat
            Event = WaitWindowEvent()
          Until Event = #PB_Event_CloseWindow
          
          SaveImage(#Image, "QRCode.png", #PB_ImagePlugin_PNG)
  
        EndIf   
      
      CompilerEndIf 
      
    CompilerCase 2
      
      CompilerIf QRCode::#Enable_Decode_QRCodes

        UsePNGImageDecoder()
        UseJPEGImageDecoder()

        File$ = OpenFileRequester("Choose an image with a QR-Code inside", "", "IMG|*.bmp;*.png;*.jpg", 0)
        If File$
         
          If LoadImage(#Image, File$)
            
            Text$ = QRCode::Decode(#Image)
            If Text$
               Debug "--------------------"
               Debug "QRCode: '" + Text$ + "'" 
               Debug "--------------------"
            Else
              Debug "--------------------"
              Debug "No QR-Code detected!"
              Debug "--------------------"
            EndIf  
            
            FreeImage(#Image)
          EndIf
          
        EndIf
        
      CompilerEndIf
      
    CompilerDefault ; QRCode::Gadget()
      
      CompilerIf QRCode::#Enable_Generate_QRCodes
      
        CompilerIf QRCode::#Enable_Gadget
        
          If OpenWindow(#Window, 0, 0, 200, 200, "QRCode - Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
            QRCode::Gadget(#Gadget, 10, 10, 180, 180, QRCode::#AutoResize)
            QRCode::SetText(#Gadget, "Hello World")
            ;QRCode::SetColor(#Gadget, QRCode::#FrontColor, $800000)
            ;QRCode::SetAutoResizeFlags(#Gadget, QRCode::#MoveX|QRCode::#MoveY)
          EndIf   
          
          Repeat
            Event = WaitWindowEvent()
          Until Event = #PB_Event_CloseWindow
          
        CompilerEndIf 

      CompilerEndIf  
      
  CompilerEndSelect

CompilerEndIf
; IDE Options = PureBasic 6.00 Beta 7 (Windows - x64)
; CursorPosition = 14
; Folding = EIy-BAAAAAAAAAAAAAAAAAAAAAAAIAMQAx
; EnableXP