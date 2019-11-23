;/ =====================
;/ =    UnPackEx.pb    =
;/ =====================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/ 
;/ © 2019 Thorsten1867 (08/2019)
;/

XIncludeFile "ResourcesModule.pbi"
XIncludeFile "PackExModule.pbi"
XIncludeFile "ListExModule.pbi"
XIncludeFile "AppRegistryModule.pbi"
XIncludeFile "ProgressBarExModule.pbi"
XIncludeFile "ResizeExModule.pbi"

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

UsePNGImageDecoder()

UseZipPacker()
UseLZMAPacker()
UseTARPacker()

;- _____ Constants _____

#Pack = 1
#HKey = 1
#Resource = 1

Enumeration 1
  #Window_PackEx
  #Window_Language
  #Menu
EndEnumeration

Enumeration 1
  
  #Menu_SelectAll
  #Menu_Unselect
  
  #ProgressBar
  
  ;{ #Window_PackEx
  #Gadget_PackEx_Frame
  #Gadget_PackEx_ExplorerTree
  #Gadget_PackEx_Tx_Archive
  #Gadget_PackEx_SG_Archive
  #Gadget_PackEx_Bt_Content
  #Gadget_PackEx_Bt_Extract
  #Gadget_PackEx_LI_Files
  ;}
  
  ;{ #Window_Language
  #Gadget_Language_ComboBox
  #Gadget_Language_OK
  ;}
  
EndEnumeration

Enumeration 1
  #Font_Arial9B
  #Font_Arial11B
EndEnumeration

Enumeration 1
  #IMG_Show
  #IMG_Extract
  #IMG_OK
EndEnumeration

Global NewMap Msg.s()


;- _____ Windows _____

LoadFont(#Font_Arial9B,  "Arial", 9, 256)
LoadFont(#Font_Arial11B, "Arial", 10, 256)

Procedure.i Window_Language()
  If OpenWindow(#Window_Language, 0, 0,170,45, "Select Language", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_Invisible)
      ComboBoxGadget(#Gadget_Language_ComboBox, 10, 10, 120, 24)
        SetGadgetFont(#Gadget_Language_ComboBox, FontID(#Font_Arial11B))
      ButtonImageGadget(#Gadget_Language_OK, 136, 10, 24, 24, ImageID(#IMG_OK))
      HideWindow(#Window_Language, #False)
    ProcedureReturn WindowID(#Window_Language)
  EndIf
EndProcedure

Procedure.i Window_PackEx()
  Define.i Offset
  
  If OpenWindow(#Window_PackEx, 0, 0, 555, 460, " " + Msg("Titel") + " (qAES)", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered|#PB_Window_Invisible)
    
    If CreatePopupMenu(#Menu) 
      MenuItem(#Menu_SelectAll, "Select all")
      MenuItem(#Menu_Unselect,  "Remove selection")
    EndIf  
    
    ExplorerTreeGadget(#Gadget_PackEx_ExplorerTree, 5, 50, 220, 380, "")
    
    FrameGadget(#Gadget_PackEx_Frame, 5, 0, 545, 45, "")
    TextGadget(#Gadget_PackEx_Tx_Archive, 15, 17, 45, 16, Msg("Archive") + ": ")
      SetGadgetFont(#Gadget_PackEx_Tx_Archive, FontID(#Font_Arial9B))
    Offset = GadgetWidth(#Gadget_PackEx_Tx_Archive, #PB_Gadget_RequiredSize) - 45
    If Offset > 0 : ResizeGadget(#Gadget_PackEx_Tx_Archive, #PB_Ignore, #PB_Ignore, Offset + 45, #PB_Ignore) : EndIf
    StringGadget(#Gadget_PackEx_SG_Archive, 60 + Offset, 15, 425 - Offset, 20, "", #PB_String_ReadOnly)
      SetGadgetColor(#Gadget_PackEx_SG_Archive, #PB_Gadget_FrontColor, $701919)
      SetGadgetFont(#Gadget_PackEx_SG_Archive, FontID(#Font_Arial9B))
    ButtonImageGadget(#Gadget_PackEx_Bt_Content, 491, 13, 24, 24, ImageID(#IMG_Show))
    ButtonImageGadget(#Gadget_PackEx_Bt_Extract, 520, 13, 24, 24, ImageID(#IMG_Extract))
    
    ListEx::Gadget(#Gadget_PackEx_LI_Files, 230, 50, 320, 380, "", 25, "check", ListEx::#GridLines|ListEx::#CheckBoxes|ListEx::#AutoResize, #Window_PackEx)
    ListEx::AddColumn(#Gadget_PackEx_LI_Files, 1, " " + Msg("File"), 215, "files")
    ListEx::AddColumn(#Gadget_PackEx_LI_Files, 2, Msg("Size"), 80, "size")
    ListEx::SetColorTheme(#Gadget_PackEx_LI_Files, ListEx::#Theme_Blue)
    ListEx::SetFont(#Gadget_PackEx_LI_Files, FontID(#Font_Arial9B), ListEx::#HeaderFont)
    ListEx::SetHeaderAttribute(#Gadget_PackEx_LI_Files, ListEx::#Align, ListEx::#Center, 2)
    ListEx::SetColumnAttribute(#Gadget_PackEx_LI_Files, 2, ListEx::#Align, ListEx::#Right)
    ListEx::AttachPopupMenu(#Gadget_PackEx_LI_Files, #Menu)
    ListEx::SetAutoResizeColumn(#Gadget_PackEx_LI_Files, 1, 100)
    
    ProgressEx::Gadget(#ProgressBar, 5, 435, 545, 20, 0, 100, ProgressEx::#Border|ProgressEx::#ShowPercent|ProgressEx::#AutoResize, #Window_PackEx)
    ProgressEx::SetAutoResizeFlags(#ProgressBar, ProgressEx::#Width|ProgressEx::#MoveY)
    ProgressEx::SetFont(#ProgressBar, #Font_Arial9B)
    ProgressEx::SetColor(#ProgressBar, ProgressEx::#FrontColor, $006400)
    
    If Resize::AddWindow(#Window_PackEx, 555, 460)
      Resize::AddGadget(#Gadget_PackEx_Frame,  Resize::#Width)
      Resize::AddGadget(#Gadget_PackEx_ExplorerTree, Resize::#Height)
      Resize::AddGadget(#Gadget_PackEx_SG_Archive, Resize::#Width)
      Resize::AddGadget(#Gadget_PackEx_Bt_Content, Resize::#MoveX)
      Resize::AddGadget(#Gadget_PackEx_Bt_Extract, Resize::#MoveX)
    EndIf
    
    HideWindow(#Window_PackEx, #False)
    
    ProcedureReturn WindowID(#Window_PackEx)
  EndIf
  
EndProcedure

;- ___ Internal Procedures ___

Procedure   Language(Code.s="")
  
  Select Code
    Case "Deutsch"  
      Msg("Titel")            = "Entpacker für verschlüsselte Dateien"
      Msg("Enter TargetPath") = "Bitte Zielpfad eingeben"
      Msg("Enter Key")        = "Bitte Passwot eingeben:"
      Msg("Encrypted File")   = "Verschlüsselte Datei"
      Msg("Extract Archive")  = "Archiv entpacken"
      Msg("files")            = "Dateien"
      Msg("Extracted")        = "Entpackt:"
      Msg("Archive")          = "Archiv"
      Msg("File")             = "Datei"
      Msg("Size")             = "Größe"
    Case "Français"
      Msg("Titel")            = "Décompresseur pour fichiers cryptés"
      Msg("Enter TargetPath") = "Veuillez entrer le chemin d'accès cible"
      Msg("Enter Key")        = "Veuillez entrer votre clé:"
      Msg("Encrypted File")   = "Fichier crypté"
      Msg("Extract Archive")  = "Extrait d'archive"
      Msg("files")            = "fichiers"
      Msg("Extracted")        = "Déballé:"
      Msg("Archive")          = "Archives"
      Msg("File")             = "Fichier"
      Msg("Size")             = "Taille"
    Default
      Msg("Titel")            = "Unpacker for encrypted files"
      Msg("Enter TargetPath") = "Please enter target path"
      Msg("Enter Key")        = "Please enter your key:"
      Msg("Encrypted File")   = "Encrypted File"
      Msg("Extract Archive")  = "Extract Archive"
      Msg("files")            = "files"
      Msg("Extracted")        = "Extracted:"
      Msg("Archive")          = "Archive"
      Msg("File")             = "File"
      Msg("Size")             = "Size"
  EndSelect
  
EndProcedure

Procedure.i LoadContent(PackFile.s, Plugin.i=#PB_PackerPlugin_Zip)
  Define.i Row, Result = #False
  
  If PackEx::Open(#Pack, PackFile, Plugin)
    PackEx::ReadContent(#Pack)
    Result = #True
    PackEx::Close(#Pack)
  EndIf
  
  ListEx::ClearItems(#Gadget_PackEx_LI_Files)
  
  ForEach PackEx::Content()
    Row = ListEx::AddItem(#Gadget_PackEx_LI_Files, ListEx::#LastItem, PackEx::Content()\FileName + #LF$ + PackEx::FormatBytes(PackEx::Content()\Size), PackEx::Content()\FileName)
    If PackEx::Content()\Encrypted
      ListEx::SetItemColor(#Gadget_PackEx_LI_Files, Row, ListEx::#FrontColor, $3C14DC, 1)
    Else
      ListEx::SetItemColor(#Gadget_PackEx_LI_Files, Row, ListEx::#FrontColor, $701919, 1)
    EndIf
  Next
  
  ProcedureReturn Result
EndProcedure

Procedure.s SelectLanguage()
  Define.s Language$
  Define quitWindow = #False
  
  If Window_Language()
    
    AddGadgetItem(#Gadget_Language_ComboBox, 0, "English")
    AddGadgetItem(#Gadget_Language_ComboBox, 1, "Deutsch")
    AddGadgetItem(#Gadget_Language_ComboBox, 2, "Français")
    SetGadgetState(#Gadget_Language_ComboBox, 0)
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          Select EventWindow()
            Case #Window_Language
              quitWindow = #True
          EndSelect
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_Language_OK
              Language$ = GetGadgetText(#Gadget_Language_ComboBox)
              AppReg::SetValue(#HKey, "Internal", "Language", Language$)
              quitWindow = #True
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_Language)
  EndIf
  ProcedureReturn Language$
EndProcedure


;- _____ Main Loop ___

Define.s Language$

Window::Load("UnPackEx.win")

AppReg::Open(#HKey, "UnPackEx.reg", "UnPackEx", "Thorsten Hoeppner")

If Resource::Open(#Resource, "UnPackEx.res")
  Resource::GetImage(#Resource, #IMG_Show,    "Show.png")
  Resource::GetImage(#Resource, #IMG_Extract, "Extract.png")
  Resource::GetImage(#Resource, #IMG_OK,      "OK.png")
  Resource::Close(#Resource)
EndIf

Language$ = AppReg::GetValue(#HKey, "Internal", "Language", "")
If Language$ = "" : Language$ = SelectLanguage() : EndIf

Language(Language$)

If Window_PackEx()
  Define.s PackFile$, Key$, FileName$, Path$
  Define.i r, Plugin, Rows, Count, Checked, quitWindow = #False
  
  Window::RestoreSize(#Window_PackEx)
  
  SetGadgetText(#Gadget_PackEx_ExplorerTree, AppReg::GetValue(#HKey, "Path", "PackFile", "C:\"))

  Repeat
    
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow            ;{ Close Window
        Select EventWindow()
          Case #Window_PackEx 
            quitWindow = #True
        EndSelect ;}
      Case #PB_Event_Menu                   ;{ Popup menu entries
        Select EventMenu()
          Case #Menu_SelectAll
            Rows = ListEx::CountItems(#Gadget_PackEx_LI_Files)
            For r=0 To Rows - 1
              ListEx::SetItemState(#Gadget_PackEx_LI_Files, r, ListEx::#Checked)
            Next
          Case #Menu_Unselect
            Rows = ListEx::CountItems(#Gadget_PackEx_LI_Files)
            For r=0 To Rows - 1
              ListEx::SetItemState(#Gadget_PackEx_LI_Files, r, #False)
            Next
        EndSelect ;}
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gadget_PackEx_ExplorerTree  ;{ ExplorerTree
            Select EventType()
              Case #PB_EventType_LeftDoubleClick ;{ Show content
                If PackFile$
                  AppReg::SetValue(#HKey, "Path", "PackFile", GetPathPart(PackFile$))
                  Select LCase(GetExtensionPart(PackFile$))
                    Case "zip"
                      Plugin = #PB_PackerPlugin_Zip
                      LoadContent(PackFile$, #PB_PackerPlugin_Zip)
                    Case "7z", "lzma"
                      Plugin = #PB_PackerPlugin_Lzma
                      LoadContent(PackFile$, #PB_PackerPlugin_Lzma)
                    Case "tar", "gzip", "bzip2", "bz2"
                      Plugin = #PB_PackerPlugin_Tar
                      LoadContent(PackFile$, #PB_PackerPlugin_Tar)
                  EndSelect
                EndIf ;}
              Default                            ;{ Select pack
                If GetGadgetState(#Gadget_PackEx_ExplorerTree) = #PB_Explorer_File
                  PackFile$ = GetGadgetText(#Gadget_PackEx_ExplorerTree)
                  Select LCase(GetExtensionPart(PackFile$))
                    Case "zip", "7z", "lzma", "tar", "gzip", "bzip2", "bz2"
                      AppReg::SetValue(#HKey, "Path", "PackFile", GetPathPart(PackFile$))
                      SetGadgetText(#Gadget_PackEx_SG_Archive, GetFilePart(PackFile$))
                    Default
                      SetGadgetText(#Gadget_PackEx_SG_Archive, "")
                      ClearGadgetItems(#Gadget_PackEx_LI_Files)
                  EndSelect
                Else
                  SetGadgetText(#Gadget_PackEx_SG_Archive, "")
                  ClearGadgetItems(#Gadget_PackEx_LI_Files)
                EndIf ;}
            EndSelect ;}
          Case #Gadget_PackEx_Bt_Content    ;{ Show Content
            If PackFile$
              Select LCase(GetExtensionPart(PackFile$))
                Case "zip"
                  LoadContent(PackFile$, #PB_PackerPlugin_Zip)
                Case "7z", "lzma"
                  LoadContent(PackFile$, #PB_PackerPlugin_Lzma)
                Case "tar", "gzip", "bzip2", "bz2"
                  LoadContent(PackFile$, #PB_PackerPlugin_Tar)
              EndSelect
            EndIf ;}
          Case #Gadget_PackEx_Bt_Extract    ;{ Extract Files
            
            Rows = ListEx::CountItems(#Gadget_PackEx_LI_Files)
            If Rows

              Key$ = ""
              
              If PackEx::Open(#Pack, PackFile$, Plugin)
 
                Path$ = PathRequester(Msg("Enter TargetPath"), AppReg::GetValue(#HKey, "Path", "Target", "C:\"))
                If Path$
                  
                  AppReg::SetValue(#HKey, "Path", "Target", Path$)
                  
                  Checked = ListEx::CountItems(#Gadget_PackEx_LI_Files, ListEx::#Checked)
                  
                  For r=0 To Rows - 1
                    
                    If ListEx::GetItemState(#Gadget_PackEx_LI_Files, r) & ListEx::#Checked = #False : Continue : EndIf 
                    
                    FileName$ = ListEx::GetRowLabel(#Gadget_PackEx_LI_Files, r)
                    
                    ProgressEx::SetText(#ProgressBar, " " + FileName$ + "  ("+ProgressEx::#Progress$+")")
                    ProgressEx::SetState(#ProgressBar, (100 / Checked) * r)
                    
                    If PackEx::Content(FileName$)\Encrypted
                      If Key$ = ""
                        Key$ = InputRequester(Msg("Encrypted File"), Msg("Enter Key"), "", #PB_InputRequester_Password)
                      EndIf
                      If PackEx::DecompressFile(#Pack, Path$ + FileName$, FileName$, Key$) : Count + 1 : EndIf
                    Else
                      If PackEx::DecompressFile(#Pack, Path$ + FileName$, FileName$) : Count + 1 : EndIf
                    EndIf    

                  Next
                  
                  ProgressEx::SetState(#ProgressBar, 100)
                  
                  MessageRequester(" " + Msg("Extract Archive"), Msg("Extracted") + " " + Str(Count) + " " + Msg("files"), #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
                  
                  ProgressEx::SetState(#ProgressBar, 0)
                  
                EndIf
                
                PackEx::Close(#Pack)
              EndIf
              
            EndIf
            ;}
        EndSelect

    EndSelect
  Until quitWindow
  
  Window::StoreSize(#Window_PackEx)
  
  CloseWindow(#Window_PackEx)
EndIf

Window::Save("UnPackEx.win")
AppReg::Close(#HKey)

End
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 166
; FirstLine = 79
; Folding = oc5
; EnableXP
; DPIAware
; UseIcon = UnPackEx.ico
; Executable = UnPackEx.exe