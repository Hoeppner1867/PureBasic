;/ ===========================
;/ =    UseIconModule.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / all OS]
;/ 
;/ © 2020 Thorsten Hoeppner (04/2020)
;/ 

;{ ===== MIT License =====
;
; Copyright (c) 2020 Thorsten Hoeppner
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

;{ _____ Module - Commands _____

; Icon::Save()      - similar to 'SaveImage()'   [#MacOS|#Windows|#Cursor] 
; Icon::Encode()    - similar to 'EncodeImage()' [#ImagePlugin_ICO|#ImagePlugin_ICNS] 
;
; Icon::Create()    - create a new icon with several sizes [#Windows|#MacOS]
; Icon::AddImage()  - add an image to the icon
; Icon::Close()     - close and create the icon

;}

DeclareModule Icon
  
  #Version  = 20042001
  #ModuleEx = 20041700
  
  EnumerationBinary ; Flags
    #Icon
    #Cursor
    #Windows
    #MacOS
  EndEnumeration
  
  #ImagePlugin_ICO  = #Windows
  #ImagePlugin_ICNS = #MacOS
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i Save(Image.i, File.s, Flags.i=#Icon, HotspotX.i=0, HotspotY.i=0)
  
  Declare.i Encode(Image.i, ImagePlugin.i, Flags.i=#False) 
  
  Declare.i Create(ID.i, File.s, Flags.i=#False) 
  Declare.i AddImage(ID.i, Image.i, Size.i=#PB_Default)
  Declare   Close(ID.i)
  
EndDeclareModule

Module Icon
  
  EnableExplicit
  
  UsePNGImageEncoder()
  
  ;- ============================================================================
  ;-   Module - Constants / Structures
  ;- ============================================================================  
  
  #CreateIcon   = 1
  #CreateCursor = 2
  
  #WinHeaderSize = 6
  #MacHeaderSize = 8
  
  #ImageDirSize = 16 
  #IconDataSize = 8
  
  #Icns16$   = "icp4"
  #Icns32$   = "icp5"
  #Icns64$   = "icp6"
  #Icns128$  = "ic07"
  #Icns256$  = "ic08"
  #Icns512$  = "ic09"
  #Icns1024$ = "ic10"
  
  Structure ImageDir_Structure ;{ Icon()\ImageDir()\...
    *Buffer
    Width.b        ; image width in pixels
    Height.b       ; image height in pixels
    NumOfColors.b  ; number of colors in the color palette
    ColorPlanes.w  ; color planes (ICO)   / hotspot X (CUR)
    BitsPerPixel.w ; bits per pixel (ICO) / hotspot Y (CUR)
    Size.l         ; size of image date in byte
    Offset.l       ; offset of image data from beginning of ICO/CUR file
  EndStructure ;}
  
  Structure IconData_Structure ;{ Icon()\IconData()\...
    *Buffer
    Size.i
    Type.s
  EndStructure ;}
  
  Structure Icon_Structure     ;{ Icon()\...
    File.s
    Number.i
    Type.i
    Flags.i
    List ImageDir.ImageDir_Structure() ; Windows (ICO)
    List IconData.IconData_Structure() ; MacOS   (ICNS)
  EndStructure ;}
  Global NewMap Icon.Icon_Structure()
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Procedure.q Long(Value.l, BigEndian.i=#True)
    If BigEndian
      ProcedureReturn (Value>>24&$FF) | (Value>>8&$FF00) | (Value<<8&$FF0000) | (Value<<24&$FF000000)
    Else
      ProcedureReturn Value
    EndIf  
  EndProcedure
  
  Procedure.s GetMacIconType(Size.i)
    ; https://en.wikipedia.org/wiki/Apple_Icon_Image_format#Icon_types
    Select Size
      Case 16
        ProcedureReturn #Icns16$
      Case 32
        ProcedureReturn #Icns32$
      Case 64
        ProcedureReturn #Icns64$
      Case 128
        ProcedureReturn #Icns128$
      Case 256
        ProcedureReturn #Icns256$
      Case 512
        ProcedureReturn #Icns512$
      Case 1024  
        ProcedureReturn #Icns1024$
    EndSelect    
    
  EndProcedure  
  
  Procedure.i ValidIconSize(Size.i, Type.i=#Windows)
    
    Select Size
      Case 16, 32, 64, 128, 256
        ProcedureReturn Size
      Case 24, 48
        If Type = #Windows
          ProcedureReturn Size
        EndIf  
      Case 512, 1024
        If Type = #MacOS
          ProcedureReturn Size
        EndIf  
    EndSelect
    
    ProcedureReturn #False
  EndProcedure  
  
  
  Procedure   WriteWinHeader_(FileNum.i, Type.w=#CreateIcon, Number.w=1)
    
    WriteWord(FileNum, 0)      ; Offset 00: Reserved = 0
    WriteWord(FileNum, Type)   ; Offset 02: Image type (1 = Icon / 2 = Cursor) 
    WriteWord(FileNum, Number) ; Offset 04: Number of images
    
  EndProcedure 
  
  Procedure   WriteMacHeader_(FileNum.i, Size.i)
    
    WriteByte(FileNum, $69)        ; Offset 00: Magic literal
    WriteByte(FileNum, $63)        ; Offset 01: Magic literal
    WriteByte(FileNum, $6E)        ; Offset 02: Magic literal
    WriteByte(FileNum, $73)        ; Offset 03: Magic literal
    WriteLong(FileNum, Long(Size)) ; Offset 04: Length of file (MSB first)
    
  EndProcedure 
  
  
  Procedure   WriteImageDir_(FileNum.i, List ImageDir.ImageDir_Structure())
    
    ForEach ImageDir()
      WriteByte(FileNum, ImageDir()\Width)        ; Offset 00: 0 - 255
      WriteByte(FileNum, ImageDir()\Height)       ; Offset 01: 0 - 255
      WriteByte(FileNum, ImageDir()\NumOfColors)  ; Offset 02: 0 without color palette
      WriteByte(FileNum, 0)                       ; Offset 03: Reserved (should be 0)
      WriteWord(FileNum, ImageDir()\ColorPlanes)  ; Offset 04: 0 or 1 (ICO) / X pixel from left (CUR)
      WriteWord(FileNum, ImageDir()\BitsPerPixel) ; Offset 06: Bits per pixel (ICO) / Y pixel from top (CUR)
      WriteLong(FileNum, ImageDir()\Size)         ; Offset 08: Bytes of image data
      WriteLong(FileNum, ImageDir()\Offset)       ; Offset 12: Offset from beginning
    Next
    
  EndProcedure
  
  Procedure   WriteImageData_(FileNum.i, List ImageDir.ImageDir_Structure())
    
    ForEach ImageDir()
      WriteData(FileNum, ImageDir()\Buffer, ImageDir()\Size)
      FreeMemory(ImageDir()\Buffer)
    Next 
    
  EndProcedure
  
  Procedure   WriteIconData_(FileNum.i, List IconData.IconData_Structure()) 
    Define.i t, Size
    
    ForEach IconData()
      
      Size = IconData()\Size + #IconDataSize

      If IconData()\Type             ;{ Offset 00: Icon Type (-> OSType)
        For t=1 To 4
          WriteByte(FileNum, Asc(Mid(IconData()\Type, t, 1)))
        Next   
      Else
        Continue
      EndIf ;}
      
      WriteLong(FileNum, Long(Size)) ;  Offset 04: Length of data + 8 Byte (MSB first)
      WriteData(FileNum, IconData()\Buffer, IconData()\Size)
      
      FreeMemory(IconData()\Buffer)
    Next
    
  EndProcedure  
  
  
  Procedure.i CalcOffset_(List ImageDir.ImageDir_Structure())
    Define.i Offset
    
    Offset = #WinHeaderSize 
    Offset + (#ImageDirSize * ListSize(ImageDir()))
    
    ForEach ImageDir()
      ImageDir()\Offset = Offset
      Offset + ImageDir()\Size
    Next
    
    ProcedureReturn Offset
  EndProcedure
  
  Procedure.i CalcIcnsSize_(List IconData.IconData_Structure())
    Define.i Size
    
    Size = #MacHeaderSize
    
    ForEach IconData()
      Size + IconData()\Size + #IconDataSize
    Next
    
    ProcedureReturn Size
  EndProcedure  
  
  
  Procedure.i SquareImage_(ImageNum.i)
    Define.i Width, Height, SquareNum.i, Offset
    
    Width  = ImageWidth(ImageNum)
    Height = ImageHeight(ImageNum)
    
    If Width > Height
      
      Offset = (Width - Height) / 2
      
      SquareNum = CreateImage(#PB_Any, Width, Width, 32, #PB_Image_Transparent)
      If SquareNum
        If StartDrawing(ImageOutput(SquareNum)) 
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          DrawImage(ImageNum, Offset, 0)
          StopDrawing()
        EndIf
      EndIf
      
    ElseIf Width < Height  
      
      Offset = (Height - Width) / 2
      
      SquareNum = CreateImage(#PB_Any, Height, Height, 32, #PB_Image_Transparent)
      If SquareNum
        If StartDrawing(ImageOutput(SquareNum)) 
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          DrawImage(ImageNum, 0, Offset)
          StopDrawing()
        EndIf
      EndIf
      
    EndIf  
    
    If IsImage(SquareNum)
      FreeImage(ImageNum)
      ProcedureReturn CopyImage(SquareNum, #PB_Any)
    EndIf   
    
  EndProcedure   
  
  
  Procedure.i AddWinImage_(ImageNum.i, List ImageDir.ImageDir_Structure(), OffSet.i=#False, CursorX.i=-1, CursorY.i=-1)
    Define *Image, Size.i
    
    *Image = EncodeImage(ImageNum, #PB_ImagePlugin_PNG, #False, 32)
    If *Image 
     
      Size = MemorySize(*Image)
      
      If AddElement(ImageDir())
        
        ImageDir()\Buffer = *Image
 
        ImageDir()\Width  = ImageWidth(ImageNum)
        ImageDir()\Height = ImageHeight(ImageNum)
        
        ImageDir()\NumOfColors  =  0   ; Number of colors in the color palette (0 without color palette)
        
        If CursorX >= 0
          ImageDir()\ColorPlanes = CursorX ; Hotspot X: Pixel from left (CUR)
        Else
          ImageDir()\ColorPlanes =  1      ; Color Planes: 0 or 1 (ICO)
        EndIf  
        
        If CursorY >= 0
          ImageDir()\BitsPerPixel = CursorY ; Hotspot Y: Pixel from top (CUR)
        Else  
          ImageDir()\BitsPerPixel = 32      ; Bits per Pixel (ICO)
        EndIf 
        
        ImageDir()\Size = Size ; Bytes of image data
        
        If OffSet : ImageDir()\Offset = Offset : EndIf
        
        ProcedureReturn Size
      EndIf
      
    EndIf
  
  EndProcedure 
  
  Procedure.i AddMacImage_(ImageNum.i, Type.s, List IconData.IconData_Structure()) 
    Define *Image, Size.i, Type.s
    
    *Image = EncodeImage(ImageNum, #PB_ImagePlugin_PNG, #False, 32)
    If *Image 
     
      Size = MemorySize(*Image)
      
      If AddElement(IconData())
        
        IconData()\Buffer = *Image
        IconData()\Size   = Size
        IconData()\Type   = Type
        
        ProcedureReturn Size
      EndIf  
      
    EndIf
    
  EndProcedure
  

  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure.i Save(Image.i, File.s, Flags.i=#Icon, HotspotX.i=0, HotspotY.i=0)
    Define.i FileNum, Result, Width, Height, Type, Size
    Define.s Type$, Path$
    
    NewList ImageDir.ImageDir_Structure()
    NewList IconData.IconData_Structure()
    
    If IsImage(Image)
      
      Width  = ImageWidth(Image)
      Height = ImageHeight(Image)
      
      If Width <> Height : Image = SquareImage_(Image) : EndIf
     
      Size = ImageWidth(Image)
      
      If Flags & #MacOS And Flags & #Windows ;{ MacOS (ICNS) / Windows (ICO)
        
        Type$ = GetMacIconType(Size)
        If Type$
          If AddMacImage_(Image, Type$, IconData()) : Result = #True : EndIf
        EndIf
        
        If AddWinImage_(Image, ImageDir(), #WinHeaderSize + #ImageDirSize)
          Type   = #CreateIcon
          Result = #True
        EndIf  
        ;}
      ElseIf Flags & #MacOS      ;{ MacOS (ICNS)
        
        Type$ = GetMacIconType(Size)
        If Type$
          Result = AddMacImage_(Image, Type$, IconData()) 
        EndIf        
        ;}
      Else                       ;{ Windows (ICO/CUR)
        
        If Flags & #Cursor
          Type   = #CreateCursor
          Result = AddWinImage_(Image, ImageDir(), #WinHeaderSize + #ImageDirSize, HotspotX, HotspotY)
        Else
          Type   = #CreateIcon
          Result = AddWinImage_(Image, ImageDir(), #WinHeaderSize + #ImageDirSize)
        EndIf
        ;}
      EndIf
      
      If Result
        
        If Flags & #MacOS And Flags & #Windows ;{ MacOS (ICNS) / Windows (ICO)
          
          Path$ = GetPathPart(File)
          
          If ListSize(IconData())
            
            Size = CalcIcnsSize_(IconData())
            
            FileNum = CreateFile(#PB_Any, Path$ + GetFilePart(File, #PB_FileSystem_NoExtension) + ".icns")
            If FileNum
              WriteMacHeader_(FileNum, Size)
              WriteIconData_(FileNum, IconData()) 
              CloseFile(FileNum)
            EndIf
            
          EndIf
          
          If ListSize(ImageDir())
            
            CalcOffset_(ImageDir())
            
            FileNum = CreateFile(#PB_Any, Path$ + GetFilePart(File, #PB_FileSystem_NoExtension) + ".ico")
            If FileNum
              WriteWinHeader_(FileNum, Type, ListSize(ImageDir()))
              WriteImageDir_(FileNum, ImageDir())
              WriteImageData_(FileNum, ImageDir())
              CloseFile(FileNum)
            EndIf
            
          EndIf  
          ;}
        ElseIf Flags & #MacOS      ;{ MacOS (ICNS)

          If ListSize(IconData())
            
            Size = CalcIcnsSize_(IconData())

            FileNum = CreateFile(#PB_Any, File)
            If FileNum
              WriteMacHeader_(FileNum, Size)
              WriteIconData_(FileNum, IconData()) 
              CloseFile(FileNum)
            EndIf
            
          EndIf
          ;}
        Else                       ;{ Windows (ICO/CUR)  
          
          If ListSize(ImageDir())
            
            CalcOffset_(ImageDir())
            
            FileNum = CreateFile(#PB_Any, File)
            If FileNum
              WriteWinHeader_(FileNum, Type, ListSize(ImageDir()))
              WriteImageDir_(FileNum, ImageDir())
              WriteImageData_(FileNum, ImageDir())
              CloseFile(FileNum)
            EndIf
            
          EndIf  
          ;}
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i Encode(Image.i, ImagePlugin.i, Flags.i=#False) 
    Define.i Result, Width, Height, OffSet, Type, Size, t
    Define.s Type$
    Define   *Icon, *Pointer
    
    NewList ImageDir.ImageDir_Structure()
    NewList IconData.IconData_Structure()
    
    If IsImage(Image)
      
      Width  = ImageWidth(Image)
      Height = ImageHeight(Image)
      
      If Width <> Height ;{ Image non-square

        If Width < Height
          Result = ResizeImage(Image, Width, Width, #PB_Image_Smooth)
          Size   = Width
        Else
          Result = ResizeImage(Image, Height, Height, #PB_Image_Smooth)
          Size   = Height
        EndIf  
        
        If Not Result : ProcedureReturn #False : EndIf
        ;}
      Else
        Size = Width
      EndIf
      
      If Flags & #ImagePlugin_ICNS ;{ MacOS (ICNS)
        
        Type$ = GetMacIconType(Size)
        If Type$
          Result = AddMacImage_(Image, Type$, IconData()) 
        EndIf 
        ;}
      Else                         ;{ Windows (ICO/CUR)

        Type   = #CreateIcon       
        Result = AddWinImage_(Image, ImageDir(), #WinHeaderSize + #ImageDirSize)
        ;}
      EndIf 
      
      If Result
        
        If Flags & #ImagePlugin_ICNS ;{ MacOS (ICNS)
          
          If ListSize(IconData())
            
            Size = CalcIcnsSize_(IconData())
            
            *Icon = AllocateMemory(Size)
            If *Icon
              
              *Pointer = *Icon
              
              PokeB(*Pointer, $69)            ; Offset 00: Magic literal
              PokeB(*Pointer + 1, $63)        ; Offset 01: Magic literal
              PokeB(*Pointer + 2, $6E)        ; Offset 02: Magic literal
              PokeB(*Pointer + 3, $73)        ; Offset 03: Magic literal
              PokeL(*Pointer + 4, Long(Size)) ; Offset 04: Length of file (MSB first)
              
              *Pointer + 8
              
              ForEach IconData()
      
                If IconData()\Type             ;{ Offset 00: Icon Type (-> OSType)
                  For t=0 To 3
                    PokeB(*Pointer + t, Asc(Mid(IconData()\Type, t+1, 1)))
                  Next   
                Else
                  Continue
                EndIf ;}
                
                PokeL(*Pointer + 4, Long(IconData()\Size + #IconDataSize))  ;  Offset 04: Length of data + 8 Byte (MSB first)
                CopyMemory(IconData()\Buffer, *Pointer + 4, IconData()\Size)

                *Pointer + IconData()\Size + #IconDataSize
                
                FreeMemory(IconData()\Buffer)
              Next

            EndIf
            
          EndIf  
          ;}
        Else                         ;{ Windows (ICO/CUR)
          
          If ListSize(ImageDir())
            
            Size = CalcOffset_(ImageDir())
            
            *Icon = AllocateMemory(Size)
            If *Icon
              
              *Pointer = *Icon
              
              PokeW(*Pointer, 0)                        ; Offset 00: Reserved = 0
              PokeW(*Pointer + 2, #CreateIcon)          ; Offset 02: Image type (1 = Icon / 2 = Cursor) 
              PokeW(*Pointer + 4, ListSize(ImageDir())) ; Offset 04: Number of images
              
              *Pointer + 6
              
              ForEach ImageDir()
                PokeB(*Pointer,      ImageDir()\Width)        ; Offset 00: 0 - 255
                PokeB(*Pointer +  1, ImageDir()\Height)       ; Offset 01: 0 - 255
                PokeB(*Pointer +  2, ImageDir()\NumOfColors)  ; Offset 02: 0 without color palette
                PokeB(*Pointer +  3, 0)                       ; Offset 03: Reserved (should be 0)
                PokeW(*Pointer +  4, ImageDir()\ColorPlanes)  ; Offset 04: 0 or 1 (ICO) / X pixel from left (CUR)
                PokeW(*Pointer +  6, ImageDir()\BitsPerPixel) ; Offset 06: Bits per pixel (ICO) / Y pixel from top (CUR)
                PokeL(*Pointer +  8, ImageDir()\Size)         ; Offset 08: Bytes of image data
                PokeL(*Pointer + 12, ImageDir()\Offset)       ; Offset 12: Offset from beginning
                *Pointer + 16
              Next
              
              ForEach ImageDir()
                
                CopyMemory(ImageDir()\Buffer, *Pointer, ImageDir()\Size)
                FreeMemory(ImageDir()\Buffer)
                
                *Pointer + ImageDir()\Size
              Next 
              
            EndIf
            
          EndIf  
          ;}  
        EndIf
        
      EndIf  
      
    EndIf
    
    ProcedureReturn *Icon
  EndProcedure
  
  
  Procedure.i Create(ID.i, File.s, Flags.i=#False)
    Define.i Count = 1
    
    If ID = #PB_Any ;{ #PB_Any
      
      If FindMapElement(Icon(), Str(Count))
        Count + 1
      Else
        ID = Count
      EndIf 
      ;}
    EndIf  
    
    If AddMapElement(Icon(), Str(ID))
      
      Icon()\File  = File
      Icon()\Type  = #CreateIcon
      Icon()\Flags = Flags
      
    Else
      ProcedureReturn -1
    EndIf
    
    If ID
      ProcedureReturn ID
    Else
      ProcedureReturn #True
    EndIf
    
  EndProcedure
  
  Procedure.i AddImage(ID.i, Image.i, Size.i=#PB_Default)
    Define.i Result, Width, Height
    Define.s Type$

    If FindMapElement(Icon(), Str(ID))
      
      If IsImage(Image)
        
        Width  = ImageWidth(Image)
        Height = ImageHeight(Image)
        
        If Width <> Height : Image = SquareImage_(Image) : EndIf

        If Size <> #PB_Default ;{ Resize

          If ResizeImage(Image, Size, Size) = #False
            ProcedureReturn #False
          EndIf  
        Else
          Size = ImageWidth(Image)
          ;}
        EndIf

        If Icon()\Flags & #MacOS And Icon()\Flags & #Windows ;{ MacOS (ICNS) / Windows (ICO)

          Type$ = GetMacIconType(Size)
          If Type$
            If AddMacImage_(Image, Type$, Icon()\IconData()) : Result = #True : EndIf 
          EndIf

          If ValidIconSize(Size)
            If AddWinImage_(Image, Icon()\ImageDir()) : Result = #True : EndIf 
          EndIf
          ;}
        ElseIf Icon()\Flags & #MacOS                         ;{ MacOS (ICNS)

          Type$ = GetMacIconType(Size)
          If Type$
            If AddMacImage_(Image, Type$, Icon()\IconData())
              ProcedureReturn #True
            EndIf  
          EndIf
          ;}
        Else                                                 ;{ Windows (ICO/CUR)  

          If ValidIconSize(Size)
            If AddWinImage_(Image, Icon()\ImageDir())
              ProcedureReturn #True
            EndIf 
          EndIf
          ;}
        EndIf  
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
 
  Procedure   Close(ID.i)
    Define.i FileNum, Size
    Define.s Path$
    
    If FindMapElement(Icon(), Str(ID))
      
      If Icon()\Flags & #MacOS And Icon()\Flags & #Windows ;{ MacOS (ICNS) / Windows (ICO)
        
        Path$ = GetPathPart(Icon()\File)
        
        If ListSize(Icon()\IconData())
          
          Size = CalcIcnsSize_(Icon()\IconData())
          
          FileNum = CreateFile(#PB_Any, Path$ + GetFilePart(Icon()\File, #PB_FileSystem_NoExtension) + ".icns")
          If FileNum
            WriteMacHeader_(FileNum, Size)
            WriteIconData_(FileNum, Icon()\IconData()) 
            CloseFile(FileNum)
          EndIf
          
        EndIf
        
        If ListSize(Icon()\ImageDir())
          
          CalcOffset_(Icon()\ImageDir())
          
          FileNum = CreateFile(#PB_Any, Path$ + GetFilePart(Icon()\File, #PB_FileSystem_NoExtension) + ".ico")
          If FileNum
            WriteWinHeader_(FileNum, Icon()\Type, ListSize(Icon()\ImageDir()))
            WriteImageDir_(FileNum, Icon()\ImageDir())
            WriteImageData_(FileNum, Icon()\ImageDir())
            CloseFile(FileNum)
          EndIf
          
        EndIf
        ;}
      ElseIf Icon()\Flags & #MacOS      ;{ MacOS (ICNS)
        
        If ListSize(Icon()\IconData())
          
          Size = CalcIcnsSize_(Icon()\IconData())
          
          FileNum = CreateFile(#PB_Any, Icon()\File)
          If FileNum
            WriteMacHeader_(FileNum, Size)
            WriteIconData_(FileNum, Icon()\IconData()) 
            CloseFile(FileNum)
          EndIf
          
        EndIf
        ;}
      Else                              ;{ Windows (ICO/CUR)
        
        If ListSize(Icon()\ImageDir())
          
          CalcOffset_(Icon()\ImageDir())
          
          FileNum = CreateFile(#PB_Any, Icon()\File)
          If FileNum
            WriteWinHeader_(FileNum, Icon()\Type, ListSize(Icon()\ImageDir()))
            WriteImageDir_(FileNum, Icon()\ImageDir())
            WriteImageData_(FileNum, Icon()\ImageDir())
            CloseFile(FileNum)
          EndIf
        EndIf
        ;}
      EndIf
      
      DeleteMapElement(Icon())
      
    EndIf
    
  EndProcedure  
  
EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  Define.i quitWindow = #False
  
  #Example = 1
  
  ; 1: Icon::Save()
  ; 2: Icon::Create()
  ; 3: Icon::Encode()
  
  UseJPEGImageDecoder()
  UsePNGImageDecoder()

  Enumeration 1
    #Icon
    #Image
    #Image1
    #Image2
    #File
  EndEnumeration
  
  Select #Example
    Case 1 ;{ Icon::Save()
      
      If LoadImage(#Image, "Test32.png")
    
        Icon::Save(#Image, "Test32.ico",  Icon::#Windows|Icon::#MacOS)
        
        FreeImage(#Image)
      EndIf 
      ;}
    Case 2 ;{ Icon::Create()
      
      If Icon::Create(#Icon, "Test3264.ico", Icon::#Windows|Icon::#MacOS)
        
        If LoadImage(#Image1, "Test64.png")
          Icon::AddImage(#Icon, #Image1)
          FreeImage(#Image1)
        EndIf  
        
        If LoadImage(#Image2, "Test32.png")
          Icon::AddImage(#Icon, #Image2)
          FreeImage(#Image2)
        EndIf
        
        Icon::Close(#Icon)  
      EndIf
      ;}
    Case 3 ;{ Icon::Encode()

      If LoadImage(#Image, "Test32.png")
        
        *Memory = Icon::Encode(#Image, Icon::#ImagePlugin_ICO) ; #ImagePlugin_ICNS
        If *Memory
          
          Size.i = MemorySize(*Memory)
          
          If CreateFile(#File, "Encoded.ico")
            WriteData(#File, *Memory, Size)
            CloseFile(#File)
          EndIf
          
          FreeMemory(*Memory)
        EndIf
        
        FreeImage(#Image)
      EndIf
      
      ;}
  EndSelect    
  
CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 733
; FirstLine = 164
; Folding = KIAAAMOT0
; EnableXP
; DPIAware