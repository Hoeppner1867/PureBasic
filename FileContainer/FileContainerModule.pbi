;/ ============================
;/ =   FileContainerModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ File Container
;/
;/ © 2019 Thorsten1867 (04/2019)
;/

; Last Update: 17.07.2019
; 
; Prevent the archive from being damaged in the event of a crash
; 


; - Groups all files of a program in one container. 
; - The files in the container are encrypted when a container password is assigned.
; - Files are unpacked only when they are needed and are then automatically moved back into the container when the container is closed.
; - Resources can be loaded directly from the container
; - XML and JSON can be read directly from the container or written to the container.


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


;{ _____ FileContainer - Commands _____

; Container::AddFile()       - add a new file to the container
; Container::CheckPassword() - checks if the password is correct and sets the password for opening the container
; Container::Close()         - moves all open files back to the container
; Container::Create()        - creates a new container
; Container::GetInfo()       - get container info (#Program / #Description / #Author)
; Container::GetFileInfo()   - get file info (#FileSize / #Modified)
; Container::IsOpen()        - checks whether the container is open.
; Container::Load()          - load directly from the container (#XML / #JSON / #Image / #Sound / #Sprite)
; Container::Open()          - opens the container (password is not required if CheckPassword() is used)
; Container::RemoveFile()    - removes a file form the container
; Container::Save()          - save directly to the container (#XML / #JSON)
; Container::UpdateFile()    - update file in container
; Container::UseFile()       - unpack a file to use it

;}

DeclareModule Container
  
  Enumeration
    #Image
    #Sound
    #XML
    #JSON
    #Sprite
  EndEnumeration
  
  Enumeration 
    #Program
    #Description
    #Author
    #FileSize
    #Modified
  EndEnumeration
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i AddFile(ID.i, File.s, FileName.s="", Flag.i=#False)
  Declare.i CheckPassword(ID.i, Password.s) 
  Declare.i Close(ID.i)
  Declare.i Create(ID.i, File.s, Program.s="", Description.s="", Author.s="", Password.s="")
  Declare.s GetInfo(ID.i, Attribute.i)
  Declare.s GetErrorMessage(Language.s="")
  Declare.i GetFileInfo(ID.i, FileName.s, Attribute.i)
  Declare.i IsOpen(ID.i)
  Declare.i Load(ID.i, pbNum.i, Type.i, FileName.s)
  Declare.i Open(ID.i, File.s, TargetPath.s="", Password.s="")
  Declare.i RemoveFile(ID.i, FileName.s)  
  Declare.i Save(ID.i, pbNum.i, Type.i, FileName.s)
  Declare.i UpdateFile(ID.i, FileName.s)
  Declare.i UseFile(ID.i, FileName.s, Path.s="")
  
EndDeclareModule

  
Module Container

  EnableExplicit
  
  UseLZMAPacker()
  UseSHA2Fingerprint()
  UseCRC32Fingerprint()

  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================  
  
  #DESKey      = "18FC67"
  #ContentFile = "Content.xml"
  #InitVector = "ã¬‹â´£é‘æžŠá«¾â¦"
  
  EnumerationBinary Flag
    #Create  ; new archive created
    #Open    ; existing archive opened
    #AES     ; Encrypt file
  EndEnumeration
  
  EnumerationBinary
    #Remove
    #Move
    #Memory
    #Extract
    #Close
  EndEnumeration
  
  Enumeration Error
    #Error
    #Error_AddPackFile
    #Error_AddPackMemory
    #Error_CreatePack
    #Error_ExaminePack
    #Error_FileExist
    #Error_MemoryBuffer
    #Error_OpenPack
    #Error_ReBuildArchive
    #Error_UncompressPackMemory
  EndEnumeration
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure Content_File_Structure     ;{ FC()\Content\File()\...
    Size.i
    Modified.i
  EndStructure ;}
  
  Structure Container_Content_File     ;{ FC()\Content\...
    Program.s
    Description.s
    Author.s
    DES.s
    Map File.Content_File_Structure()
  EndStructure ;}
  
  Structure Container_Files_Structure  ;{ FC()\Files()\...
    Path.s
    Size.i
    CRC32.s
    Num.i
    Type.i
    Flags.i
  EndStructure ;}
  
  Structure Container_Structure        ;{ FC()\...
    ID.i
    Pack.i
    File.s
    Path.s
    Error.i
    Password.s
    DES.s
    Temp.s
    Flags.i
    Content.Container_Content_File
    Map Files.Container_Files_Structure()
  EndStructure ;}
  Global NewMap FC.Container_Structure()
  
  Global Error.i
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Procedure.s ValidName(Value$)
    Value$ = ReplaceString(Value$, "ä", "ae")
    Value$ = ReplaceString(Value$, "ö", "oe")
    Value$ = ReplaceString(Value$, "ü", "ue")
    Value$ = ReplaceString(Value$, "Ä", "Ae")
    Value$ = ReplaceString(Value$, "Ö", "Oe")
    Value$ = ReplaceString(Value$, "Ü", "Ue")
    Value$ = ReplaceString(Value$, "ß", "S")
    ProcedureReturn Value$
  EndProcedure
  
  
  Procedure   RepairContent(ID.i)
    
    If FindMapElement(FC(), Str(ID))
      
      If ExaminePack(FC()\Pack)
        While NextPackEntry(FC()\Pack)
          
          If PackEntryName(FC()\Pack) = #ContentFile : Continue : EndIf 
          
          If AddMapElement(FC()\Content\File(), PackEntryName(FC()\Pack))
            FC()\Content\File()\Size     = PackEntrySize(FC()\Pack, #PB_Packer_UncompressedSize)
            FC()\Content\File()\Modified = Date()
          EndIf
          
        Wend
      EndIf
      
      If FC()\DES
        FC()\Content\DES = FC()\DES
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i LoadContent(ID.i)
    Define.i Size, XML, Result = #False
    Define   *Buffer
    Define   Load.Container_Content_File
    
    If FindMapElement(FC(), Str(ID))
      
      If ExaminePack(FC()\Pack)
        While NextPackEntry(FC()\Pack)
          If PackEntryName(FC()\Pack) = #ContentFile
            Size = PackEntrySize(FC()\Pack)
            *Buffer = AllocateMemory(Size)
            If *Buffer
              If UncompressPackMemory(FC()\Pack, *Buffer, Size)
                XML = CatchXML(#PB_Any, *Buffer, Size)
                If XML
                  ExtractXMLStructure(MainXMLNode(XML), @Load, Container_Content_File)
                  FreeXML(XML)
                  Result = #True
                EndIf
              EndIf
              FreeMemory(*Buffer)
            EndIf
            Break
          EndIf
        Wend
      EndIf
      
      FC()\Content\Program     = Load\Program
      FC()\Content\Description = Load\Description
      FC()\Content\Author      = Load\Author
      FC()\Content\DES         = Load\DES
      
      CopyMap(Load\File(), FC()\Content\File())

    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure   SaveContent(ID.i)
    Define.i Size, XML
    Define   *Buffer
    
    If FindMapElement(FC(), Str(ID))
      
      XML = CreateXML(#PB_Any)
      If XML
        InsertXMLStructure(RootXMLNode(XML), @FC()\Content, Container_Content_File)
        Size = ExportXMLSize(XML)
        *Buffer = AllocateMemory(Size)
        If *Buffer
          If ExportXML(XML, *Buffer, Size)
            If FC()\Pack : AddPackMemory(FC()\Pack, *Buffer, Size, #ContentFile) : EndIf
          EndIf
          FreeMemory(*Buffer)
        EndIf
        FreeXML(XML)
      EndIf

    EndIf
    
  EndProcedure
  
  
  Procedure.i EncryptMemory(ID.i, *Memory, Size.i, FileName.s) 
    Define.i Result, Size
    Define.s InitVector = #InitVector
    Define   *AES
    
    If *Memory = 0 Or Size <= 0 : ProcedureReturn #False : EndIf
    
    FileName + ".aes"
    
    If FindMapElement(FC(), Str(ID))
      
      *AES = AllocateMemory(Size)
      If *AES
        If AESEncoder(*Memory, *AES, Size, @FC()\Password, 128, @InitVector, #PB_Cipher_CBC)
          Result = AddPackMemory(FC()\Pack, *AES, Size, FileName)
        EndIf
        FreeMemory(*AES)
      EndIf 
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure

  Procedure.i EncryptFile(ID.i, File.s, FileName.s="") 
    Define.i Result, FileID, Size
    Define.s InitVector = #InitVector
    Define   *File, *AES 
    
    If FileSize(File) <= 0 : ProcedureReturn #False : EndIf
   
    If FileName = "" : FileName = GetFilePart(File) : EndIf
    FileName + ".aes"
    
    If FindMapElement(FC(), Str(ID))
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        Size = Lof(FileID)
        *File = AllocateMemory(Size)
        If *File
          If ReadData(FileID, *File, Size)
            *AES = AllocateMemory(Size)
            If *AES
              If AESEncoder(*File, *AES, MemorySize(*File), @FC()\Password, 128, @InitVector, #PB_Cipher_CBC)
                Result = AddPackMemory(FC()\Pack, *AES, MemorySize(*AES), FileName)
              EndIf
              FreeMemory(*AES)
            EndIf
            CloseFile(FileID)
          EndIf
          FreeMemory(*File)
        EndIf
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure  
  
  Procedure.i DecryptFile(ID.i, File.s, Size.i, FileName.s="") 
    Define.i Result, FileID, Size
    Define.s InitVector = #InitVector
    Define   *File, *AES 

    If FileName = "" : FileName = GetFilePart(File) : EndIf
    FileName + ".aes"
    
    If FindMapElement(FC(), Str(ID))
      
      If FC()\Pack
        *AES = AllocateMemory(Size)
        If *AES
          If UncompressPackMemory(FC()\Pack, *AES, Size, FileName) <> - 1
            *File = AllocateMemory(Size)
            If *File
              If AESDecoder(*AES, *File, Size, @FC()\Password, 128, @InitVector, #PB_Cipher_CBC)
                FileID = CreateFile(#PB_Any, File)
                If FileID
                  Result = WriteData(FileID, *File, MemorySize(*File))
                  CloseFile(FileID)
                EndIf
              EndIf
              FreeMemory(*File)
            EndIf
          EndIf
          FreeMemory(*AES)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure   AddToContent(ID.i, File.s)
    Define.s FileName
    
    FileName = GetFilePart(File)
    
    If FindMapElement(FC(), Str(ID))
      
      If FindMapElement(FC()\Content\File(), FileName)
        FC()\Content\File()\Size     = FileSize(File)
        FC()\Content\File()\Modified = GetFileDate(File, #PB_Date_Modified)
      Else
        If AddMapElement(FC()\Content\File(), FileName)
        FC()\Content\File()\Size     = FileSize(File)
        FC()\Content\File()\Modified = GetFileDate(File, #PB_Date_Modified)
        EndIf 
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure   ReBuild_(ID.i)
    Define.i Pack, Size, pResult, ContentXML, Result = #True
    Define.s FileName, PackName, File, RebuildFile
    Define   *Archive
    
    If FindMapElement(FC(), Str(ID))
      
      ;If ClosePack(FC()\Pack)
      
      RebuildFile = FC()\Temp + GetFilePart(FC()\File)
      
      FC()\Pack = CreatePack(#PB_Any, RebuildFile, #PB_PackerPlugin_Lzma)
      If FC()\Pack

        ;{ Read archive file and repack files
        Pack = OpenPack(#PB_Any, FC()\File, #PB_PackerPlugin_Lzma)
        If Pack
          
          If ExaminePack(Pack) 
            
            While NextPackEntry(Pack)
              
              PackName = PackEntryName(Pack)
              If Right(PackName, 4) = ".aes"
                FileName = Left(PackName, Len(PackName) - 4)
              Else
                FileName = PackName
              EndIf
              
              If FileName = #ContentFile : Continue : EndIf
              
              Select PackEntryType(Pack)
                Case #PB_Packer_Directory ; ignore directories
                  Continue  
                Case #PB_Packer_File
                  ;{ File currently open (unpacked)
                  If FindMapElement(FC()\Files(), FileName) 
                    If FC()\Files()\Flags & #Remove      ;{ Remove file from container
                      If FC()\Files()\Flags & #Extract
                        DeleteFile(FC()\Files()\Path + MapKey(FC()\Files()), #PB_FileSystem_Force)
                      EndIf
                      DeleteMapElement(FC()\Files())
                      Continue
                      ;}
                    ElseIf FC()\Files()\Flags & #Memory  ;{ XML or JSON in memory
                      Select FC()\Files()\Type
                        Case #JSON
                          If IsJSON(FC()\Files()\Num)
                            Continue
                          Else 
                            DeleteMapElement(FC()\Files())
                          EndIf
                        Case #XML 
                          If IsXML(FC()\Files()\Num)
                            Continue
                          Else
                            DeleteMapElement(FC()\Files())
                          EndIf
                        Default
                          DeleteMapElement(FC()\Files())
                      EndSelect
                      ;}
                    ElseIf FC()\Files()\Flags & #Extract ;{ Replace file in container
                      Continue
                      ;}
                    EndIf 
                  EndIf ;} 
                  ;{ File currently not opened (in the archive)
                  Size = PackEntrySize(Pack, #PB_Packer_UncompressedSize)
                  If Size
                    *Archive = AllocateMemory(Size)
                    If *Archive
                      If UncompressPackMemory(Pack, *Archive, Size) <> -1
                        pResult = AddPackMemory(FC()\Pack, *Archive, Size, PackName)
                      Else
                        Result = #False
                        Error   = #Error_UncompressPackMemory  
                      EndIf
                      FreeMemory(*Archive)
                    EndIf
                  EndIf 
                  If pResult = #False : Result = #False : EndIf
                  ;}
              EndSelect
              
            Wend
            
          Else
            Result = #False
            Error  = #Error_ExaminePack
          EndIf
          
          ClosePack(Pack)
        Else
          Result = #False
          Error  = #Error_OpenPack
        EndIf ;}
        
        ;{ Adding files to the archive
        ForEach FC()\Files()
          
          If FC()\Files()\Flags & #Memory

            Select FC()\Files()\Type
              Case #JSON ;{ JSON in memory
                If IsJSON(FC()\Files()\Num)
                  FC()\Files()\Size = ExportJSONSize(FC()\Files()\Num)
                  If FC()\Files()\Size
                    *Archive = AllocateMemory(FC()\Files()\Size)
                    If *Archive
                      If ExportJSON(FC()\Files()\Num, *Archive, FC()\Files()\Size) = #False
                        *Archive = #False
                      EndIf
                    EndIf
                  EndIf
                EndIf ;}
              Case #XML  ;{ XML in memory
                If IsXML(FC()\Files()\Num)
                  FC()\Files()\Size = ExportXMLSize(FC()\Files()\Num)
                  If FC()\Files()\Size
                    *Archive = AllocateMemory(FC()\Files()\Size)
                    If *Archive
                      If ExportXML(FC()\Files()\Num, *Archive, FC()\Files()\Size) = #False
                        *Archive = #False
                      EndIf 
                    EndIf
                  EndIf 
                EndIf ;}
            EndSelect
            
            If *Archive And FC()\Files()\Size > 0
              
              If FC()\Flags & #AES
                pResult = EncryptMemory(ID, *Archive, FC()\Files()\Size, MapKey(FC()\Files())) 
              Else
                pResult = AddPackMemory(FC()\Pack, *Archive, FC()\Files()\Size, MapKey(FC()\Files()))
              EndIf 
              
              If pResult
                FC()\Content\File(MapKey(FC()\Files()))\Size = FC()\Files()\Size
              EndIf
              
              FreeMemory(*Archive)
              
            Else
              Error  = #Error_MemoryBuffer
              Result = #False
            EndIf 
            
            
          ElseIf FC()\Files()\Flags & #Extract Or FC()\Files()\Flags & #Close
            
            pResult = #False

            File = FC()\Files()\Path + MapKey(FC()\Files())
           
            If FileSize(File) > 0
            
              If FC()\Flags & #AES
                pResult = EncryptFile(ID, File, MapKey(FC()\Files()))
              Else
                pResult = AddPackFile(FC()\Pack, File, MapKey(FC()\Files()))
              EndIf

            Else
              Error  = #Error_FileExist
              Result = #False
            EndIf
            
            If pResult = #False : Result = #False : EndIf
            
          EndIf 
          
        Next ;}
        
        ;{ Add content file
        ContentXML = CreateXML(#PB_Any)
        If ContentXML
          InsertXMLStructure(RootXMLNode(ContentXML), @FC()\Content, Container_Content_File)
          Size = ExportXMLSize(ContentXML)
          *Archive = AllocateMemory(Size)
          If *Archive
            If ExportXML(ContentXML, *Archive, Size)
              If FC()\Pack : AddPackMemory(FC()\Pack, *Archive, Size, #ContentFile) : EndIf
            EndIf
            FreeMemory(*Archive)
          EndIf
          FreeXML(ContentXML)
        EndIf ;}

        ClosePack(FC()\Pack)
      Else
        Result = #False
        Error  = #Error_CreatePack
      EndIf  

      If Result ;{ Replace archive with rebuild file
        
        If CopyFile(RebuildFile, FC()\File)
          
          ForEach FC()\Files() ; Delete files with flag #Move Or #Close
            If FC()\Files()\Flags & #Move Or FC()\Files()\Flags & #Close
              If DeleteFile(FC()\Files()\Path + MapKey(FC()\Files()), #PB_FileSystem_Force)
                DeleteMapElement(FC()\Files())
              EndIf
            EndIf
          Next
          
        EndIf
        ;}
      Else
        Error = #Error_ReBuildArchive
      EndIf
      
    EndIf
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure.i AddFile(ID.i, File.s, FileName.s="", Flag.i=#False)
    Define Result.i
    
    If FileName = "" : FileName = GetFilePart(File) : EndIf
    FileName = ValidName(FileName)
    
    If FindMapElement(FC(), Str(ID))
      
      If FC()\Flags & #Create
        
        If FindMapElement(FC()\Files(), FileName) ;{ File already exists in archive
          FC()\Files()\Path = GetPathPart(File)
          FC()\Files()\Size = FileSize(File)
          If Flag & #Move
            FC()\Files()\Flags = #Move|#Extract
          Else
            FC()\Files()\Flags = #Extract
          EndIf
          Result = #True
          ;}
        Else                                      ;{ File does not yet exist in the archive
          
          FC()\Pack = OpenPack(#PB_Any, FC()\File, #PB_PackerPlugin_Lzma)
          If FC()\Pack 
            
            If FC()\Flags & #AES
              Result = EncryptFile(ID, File, FileName)
            Else
              Result = AddPackFile(FC()\Pack, File, FileName)
            EndIf 
            
            If Result
              If AddMapElement(FC()\Files(), FileName)
                FC()\Files()\Path  = GetPathPart(File)
                FC()\Files()\Size  = FileSize(File)
                If Flag & #Move
                  FC()\Files()\Flags = #Move|#Extract
                Else
                  FC()\Files()\Flags = #Extract
                EndIf
              EndIf
            EndIf
            
            ClosePack(FC()\Pack)
          EndIf  
          ;}
        EndIf
        
        If Result
          AddToContent(ID, File) 
        Else
          Error = #Error_AddPackFile 
        EndIf
      
        ProcedureReturn Result
        
      ElseIf FC()\Flags & #Open
        
        If FindMapElement(FC()\Files(), FileName) ;{ File already exists in archive
          FC()\Files()\Path = GetPathPart(File)
          FC()\Files()\Size = FileSize(File)
          If Flag & #Move
            FC()\Files()\Flags = #Move|#Extract
          Else
            FC()\Files()\Flags = #Extract
          EndIf
          ;}
        Else                                      ;{ File does not yet exist in the archive
          If AddMapElement(FC()\Files(), FileName)
            FC()\Files()\Path  = GetPathPart(File)
            FC()\Files()\Size  = FileSize(File)
            If Flag & #Move
              FC()\Files()\Flags = #Move|#Extract
            Else
              FC()\Files()\Flags = #Extract
            EndIf
          EndIf
          ;}
        EndIf
        
        AddToContent(ID, File) 
        
        ProcedureReturn #True
      EndIf
      
    EndIf 
    
    ProcedureReturn Result
  EndProcedure  
  
  Procedure.i CheckPassword(ID.i, Password.s)
    
    If FindMapElement(FC(), Str(ID))
      
      If FC()\Content\DES = DESFingerprint(Password, #DESKey)
        
        FC()\Password = StringFingerprint(Password, #PB_Cipher_SHA2)
        FC()\DES      = DESFingerprint(Password, #DESKey)
        FC()\Flags | #AES
        
        ProcedureReturn #True
      Else
        FC()\Password = ""
        FC()\Flags & ~#AES
        
        ProcedureReturn #False
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i Create(ID.i, File.s, Program.s="", Description.s="", Author.s="", Password.s="")
    Define   *InitVector
    Define.s TempDir
    
    If ID = #PB_Any
      ID = 1 : While FindMapElement(FC(), Str(ID)) : ID + 1 : Wend
    EndIf
    
    If AddMapElement(FC(), Str(ID))
      
      FC()\ID       = ID
      FC()\File     = File
      FC()\Password = StringFingerprint(Password, #PB_Cipher_SHA2)
      
      FC()\Content\Program     = Program
      FC()\Content\Description = Description
      FC()\Content\Author      = Author
      
      FC()\Pack = CreatePack(#PB_Any, File, #PB_PackerPlugin_Lzma)
      If FC()\Pack
        
        If Password
          FC()\Content\DES = DESFingerprint(Password, #DESKey)
          FC()\Flags | #AES 
        EndIf
        
        FC()\Flags | #Create
        
        FC()\Temp = GetTemporaryDirectory() + "FC" + Str(FC()\Pack) + #PS$
        
        ClosePack(FC()\Pack)
        
        If CreateDirectory(FC()\Temp)
          ProcedureReturn #True
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.i Close(ID.i)
    
    If FindMapElement(FC(), Str(ID))
      
      ForEach FC()\Files()
        If FC()\Files()\Flags & #Extract
          FC()\Files()\Flags | #Close
        EndIf
      Next
      
      ReBuild_(ID)
      
      ;SaveContent(ID)
      ;ClosePack(FC()\Pack)
      
      DeleteDirectory(FC()\Temp, "*.*", #PB_FileSystem_Force)
      DeleteMapElement(FC())
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.s GetErrorMessage(Language.s="")
    
    Select Language
      Case "DEU" ;{ Deutsch
        Select Error
          Case #Error_AddPackFile
            ProcedureReturn "Hinfügen der Datei zum Archiv fehlgeschlagen."
          Case #Error_AddPackMemory
            ProcedureReturn "Hinzufügen der Datei aus dem Speicherpuffer fehlgeschlagen."
          Case #Error_CreatePack
            ProcedureReturn "Archiv konnte nicht erstellt werden."
          Case #Error_ExaminePack
            ProcedureReturn "Die Archiv-Informationen konnten nicht ausgelesen werden."
          Case #Error_FileExist
            ProcedureReturn "Die hinzuzufügende Datei wurde nicht gefunden."
          Case #Error_MemoryBuffer
            ProcedureReturn "Der hinzuzufügende Speicherpuffer ist ungültig."
          Case #Error_OpenPack
            ProcedureReturn "Das Öffnen des Archives ist fehlgeschlagen."
          Case #Error_ReBuildArchive
            ProcedureReturn "Der Rebuild des Archivs ist fehlgeschlagen."
          Case #Error_UncompressPackMemory
            ProcedureReturn "Das Enpacken in den Speicher ist fehlgeschlagen."
          Default
            ProcedureReturn ""
        EndSelect ;}
      Default    ;{ English
        Select Error
          Case #Error_AddPackFile
            ProcedureReturn "Adding the file to the archive failed."
          Case #Error_AddPackMemory
            ProcedureReturn "Adding the file from memory buffer failed."
          Case #Error_CreatePack
            ProcedureReturn "Archive could not be created."
          Case #Error_ExaminePack
            ProcedureReturn "The archive information could not be read out."
          Case #Error_FileExist
            ProcedureReturn "The file to be added was not found."
          Case #Error_MemoryBuffer
            ProcedureReturn "The memory buffer to be added is invalid."
          Case #Error_OpenPack
            ProcedureReturn "Opening the archive failed."
          Case #Error_ReBuildArchive
            ProcedureReturn "The archive rebuild failed."
          Case #Error_UncompressPackMemory
            ProcedureReturn "The unpacking to memory failed."
          Default
            ProcedureReturn ""
        EndSelect ;}
    EndSelect
    
  EndProcedure
  
  Procedure.i GetFileInfo(ID.i, FileName.s, Attribute.i)
    
    If FindMapElement(FC(), Str(ID))
      
      If FindMapElement(FC()\Content\File(), FileName)
        Select Attribute
          Case #FileSize
            ProcedureReturn FC()\Content\File()\Size
          Case #Modified
            ProcedureReturn FC()\Content\File()\Modified
        EndSelect
      EndIf 
      
    EndIf
    
  EndProcedure 
  
  Procedure.s GetInfo(ID.i, Attribute.i)
    
    If FindMapElement(FC(), Str(ID))
      
      Select Attribute
        Case #Program
          ProcedureReturn FC()\Content\Program
        Case #Description
          ProcedureReturn FC()\Content\Description
        Case #Author
          ProcedureReturn FC()\Content\Author
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.i IsOpen(ID.i)
    
    If FindMapElement(FC(), Str(ID))
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i Load(ID.i, pbNum.i, Type.i, Name.s)
    Define.i Result, Size
    Define.s PackName, InitVector = #InitVector
    Define   *Buffer, *Memory
    
    If FindMapElement(FC(), Str(ID))
      If FindMapElement(FC()\Content\File(), Name)
        
        FC()\Pack = OpenPack(#PB_Any, FC()\File, #PB_PackerPlugin_Lzma)
        If FC()\Pack 
          
          Size = FC()\Content\File()\Size
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If FC()\Flags & #AES
              PackName = Name + ".aes"
            Else  
              PackName = Name
            EndIf
            
            If UncompressPackMemory(FC()\Pack, *Buffer, Size, PackName) <> -1
              
              If FC()\Flags & #AES ;{ Decode AES
                *Memory = AllocateMemory(Size)
                If *Memory
                  If AESDecoder(*Buffer, *Memory, Size, @FC()\Password, 128, @InitVector, #PB_Cipher_CBC)
                    CopyMemory(*Memory, *Buffer, Size)
                    FreeMemory(*Memory)
                  EndIf 
                EndIf
              EndIf ;}
              
              Select Type
                Case #Image  ;{ Catch image
                  Result = CatchImage(pbNum,  *Buffer, Size)
                  ;}
                Case #JSON   ;{ Catch JSON
                  Result = CatchJSON(pbNum,   *Buffer, Size)
                  If Result
                    If AddMapElement(FC()\Files(), Name)
                      FC()\Files()\Num   = pbNum
                      FC()\Files()\Type  = #JSON
                      FC()\Files()\Flags = #Memory
                    EndIf
                  EndIf ;}
                Case #Sprite ;{ Catch sprite
                  Result = CatchSprite(pbNum, *Buffer, Size)
                  ;}
                Case #Sound  ;{ Catch sound
                  Result = CatchSound(pbNum,  *Buffer, Size)
                  ;}
                Case #XML    ;{ Catch XML
                  Result = CatchXML(pbNum,    *Buffer, Size)
                  If Result
                    If AddMapElement(FC()\Files(), Name)
                      FC()\Files()\Num   = pbNum
                      FC()\Files()\Type  = #XML
                      FC()\Files()\Flags = #Memory
                    EndIf
                  EndIf ;}
              EndSelect
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
          ClosePack(FC()\Pack)
        EndIf
        
      EndIf
    EndIf
    
    
    ProcedureReturn Result
  EndProcedure  

  Procedure.i Open(ID.i, File.s, TargetPath.s="", Password.s="")
    Define.i Result
    Define.s TempDir
    
    If ID = #PB_Any
      ID = 1 : While FindMapElement(FC(), Str(ID)) : ID + 1 : Wend
    EndIf
    
    If AddMapElement(FC(), Str(ID))
      
      FC()\ID       = ID
      FC()\File     = File
      
      FC()\Pack = OpenPack(#PB_Any, File, #PB_PackerPlugin_Lzma)
      If FC()\Pack

        If TargetPath
          FC()\Path = TargetPath
          If Right(TargetPath, 1) <> #PS$ : TargetPath + #PS$ : EndIf
        Else
          FC()\Path = GetPathPart(File)
        EndIf
        
        FC()\Flags | #Open
        
        Result = LoadContent(ID)
        
        If Password <> ""
          FC()\Password = StringFingerprint(Password, #PB_Cipher_SHA2)
          FC()\DES      = DESFingerprint(Password, #DESKey)
          FC()\Flags | #AES
        EndIf
        
        If Result = #False
          RepairContent(ID)
        EndIf   
        
        ClosePack(FC()\Pack)
        
        FC()\Temp = GetTemporaryDirectory() + "FC" + Str(FC()\Pack) + #PS$
        
        If CreateDirectory(FC()\Temp)
          ProcedureReturn Result
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i RemoveFile(ID.i, FileName.s)
    Define Result.i
    
    If FindMapElement(FC(), Str(ID))
      
      FileName = ValidName(FileName)
      
      If FindMapElement(FC()\Files(), FileName)
        
        FC()\Files()\Flags = #Remove
        If DeleteMapElement(FC()\Content\File(), FileName)
          Rebuild_(ID)
          ProcedureReturn #True
        EndIf
        
      Else
        
        If AddMapElement(FC()\Files(), FileName)
          FC()\Files()\Flags = #Remove
          If DeleteMapElement(FC()\Content\File(), FileName)
            Rebuild_(ID)
            ProcedureReturn #True
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i Save(ID.i, pbNum.i, Type.i, Name.s)
    Define.i Result, Size
    
    If FindMapElement(FC(), Str(ID))
      
      Select Type 
        Case #JSON ;{ JSON
          If IsJSON(pbNum)
            FC()\Files(Name)\Type  = #JSON
            FC()\Files(Name)\Num   = pbNum
            FC()\Files(Name)\Flags = #Memory
            FC()\Content\File(Name)\Modified = Date()
          Else
            DeleteMapElement(FC()\Files(), Name)
          EndIf ;}  
        Case #XML  ;{ XML
          If IsXML(pbNum)
            FC()\Files(Name)\Type  = #XML
            FC()\Files(Name)\Num   = pbNum
            FC()\Files(Name)\Flags = #Memory
            FC()\Content\File(Name)\Modified = Date()
          Else
            DeleteMapElement(FC()\Files(), Name)
          EndIf ;}
      EndSelect

      Rebuild_(ID)

    EndIf  
    
  EndProcedure  
  
  Procedure.i UpdateFile(ID.i, FileName.s)
    
    If FindMapElement(FC(), Str(ID))
      
      If FindMapElement(FC()\Files(), FileName)
        
        If FC()\Files()\Flags & #Extract
          ReBuild_(ID)
        EndIf

      EndIf
    
    EndIf
    
    ProcedureReturn #False
  EndProcedure  

  Procedure.i UseFile(ID.i, FileName.s, Path.s="")
    
    If FindMapElement(FC(), Str(ID))
      
      FileName = ValidName(FileName)
      
      If Path = "" : Path = FC()\Path : EndIf
      
      If FindMapElement(FC()\Content\File(), FileName) 
        
        FC()\Pack = OpenPack(#PB_Any, FC()\File, #PB_PackerPlugin_Lzma)
        If FC()\Pack 
        
          If FC()\Flags & #AES ;{ Decode AES
            
            If DecryptFile(ID, Path + FileName, FC()\Content\File()\Size, FileName)
              If AddMapElement(FC()\Files(), FileName)
                FC()\Files()\Path  = Path
                FC()\Files()\Size  = FC()\Content\File()\Size
                FC()\Files()\CRC32 = FileFingerprint(Path + FileName, #PB_Cipher_CRC32)
                FC()\Files()\Flags = #Extract
                ProcedureReturn #True
              EndIf
            EndIf
            ;}
          Else                 ;{ uncompress only

            If UncompressPackFile(FC()\Pack, Path + FileName, FileName)
              If AddMapElement(FC()\Files(), FileName)
                FC()\Files()\Path  = Path
                FC()\Files()\Size  = FC()\Content\File()\Size
                FC()\Files()\CRC32 = FileFingerprint(Path + FileName, #PB_Cipher_CRC32)
                FC()\Files()\Flags = #Extract
                ProcedureReturn #True
              EndIf
            EndIf
            ;}
          EndIf

          ClosePack(FC()\Pack)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 1
    #ID
    #Map
    #Image
    #Window
    #Gadget
  EndEnumeration
  
  NewMap Code.s()
  
  Code("EN") = "English"
  Code("DE") = "German"
  Code("ES") = "Spanish"
  Code("FR") = "French"
  
  If Container::Create(#ID, "Test.kdc", "ProgName", "Description", "T.H.", "Password") ; 

    Container::AddFile(#ID, #PB_Compiler_Home + "Examples" + #PS$ + "Sources" + #PS$ + "Data" + #PS$ + "Drive.bmp")
    Container::AddFile(#ID, #PB_Compiler_Home + "Examples" + #PS$ + "Sources" + #PS$ + "Data" + #PS$ + "File.bmp")
    Container::AddFile(#ID, #PB_Compiler_Home + "Examples" + #PS$ + "Sources" + #PS$ + "Data" + #PS$ + "PureBasic.bmp")
    
    If CreateXML(#Map)
      InsertXMLMap(RootXMLNode(#Map), Code())
      Container::Save(#ID, #Map, Container::#XML, "CodeMap.xml")
      FreeXML(#Map)
    EndIf

    Container::Close(#ID)
  EndIf
  
  ClearMap(Code())
  
  If Container::Open(#ID, "Test.kdc")
    
    Password$ = InputRequester("Example", "Enter your password", "Password", #PB_InputRequester_Password)
    If Container::CheckPassword(#ID, Password$)
      
      Container::UseFile(#ID, "File.bmp")
      Container::RemoveFile(#ID, "Drive.bmp")
      Container::Load(#ID, #Image, Container::#Image, "PureBasic.bmp")
      
      If Container::Load(#ID, #Map, Container::#XML, "CodeMap.xml")
        ExtractXMLMap(MainXMLNode(#Map), Code())
        FreeXML(#Map)
      EndIf
      
      Debug "Language: " + Code("EN")
      
      MessageRequester("Example", "Close container", #PB_MessageRequester_Ok)
    Else
      Debug "Wrong Password"
    EndIf  
   
    Container::Close(#ID)
  EndIf
  
  Debug Container::GetErrorMessage()
  
  If OpenWindow(#Window, 0, 0, 400, 80, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    ImageGadget(#Gadget, 10, 10, 381, 68, ImageID(#Image), #PB_Image_Border) 

    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf

CompilerEndIf

; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 416
; FirstLine = 181
; Folding = eAQAQHAA5y
; EnableXP
; DPIAware