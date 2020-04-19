
UseLZMAPacker()
UseZipPacker()

#Pack = 1

Define.i Size

Structure Pack_Structure
  File.s
  Size.i
  *Buffer
EndStructure  
NewList Pack.Pack_Structure()

File$ = OpenFileRequester("RePack - Resource & Help files", "", "File (*.res,*.mdh)|*.res;*.mdh", 0)
If File$
  
  
  
  If OpenPack(#Pack, File$, #PB_PackerPlugin_Lzma)
   
    If ExaminePack(#Pack)
      
      While NextPackEntry(#Pack)
        
        If AddElement(Pack())
          
          Pack()\File = PackEntryName(#Pack)
          Pack()\Size = PackEntrySize(#Pack)

          Pack()\Buffer = AllocateMemory(Pack()\Size)
          If Pack()\Buffer
            UncompressPackMemory(#Pack, Pack()\Buffer, Pack()\Size, Pack()\File)
          EndIf
          
        EndIf
        
      Wend
      
    EndIf

    ClosePack(#Pack)
  EndIf  

  If ListSize(Pack())
    
    RenameFile(File$, File$ + ".old")
  
    If CreatePack(#Pack, File$, #PB_PackerPlugin_Zip)
      
      ForEach Pack() 
        If AddPackMemory(#Pack, Pack()\Buffer, Pack()\Size, Pack()\File)
          FreeMemory(Pack()\Buffer)
        EndIf  
      Next
    
      ClosePack(#Pack)
    EndIf
    
  EndIf
  
EndIf 

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 27
; FirstLine = 24
; EnableXP
; DPIAware
; Executable = RePack.exe