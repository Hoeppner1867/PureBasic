;/ ========================
;/ =    qAES-Packer.pb    =
;/ ========================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/ 
;/ © 2019 Thorsten1867 (08/2019)
;/

; Last Update: 


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
; Copyright (c) 2019 Werner Albus - www.nachtoptik.de

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


EnableExplicit

UsePNGImageDecoder()
UseJPEGImageDecoder()

UseZipPacker()
UseLZMAPacker()
UseTARPacker()

XIncludeFile "ModuleEx.pbi"
XIncludeFile "AppRegistryModule.pbi"
XIncludeFile "ResourceExModule.pbi"
XIncludeFile "ResizeExModule.pbi"
XIncludeFile "ListExModule.pbi"
XIncludeFile "PackExModule.pbi"
XIncludeFile "StringExModule.pbi"
XIncludeFile "ButtonExModule.pbi"
XIncludeFile "ProgressBarExModule.pbi"
XIncludeFile "PreviewModule.pbi"

;- ====================================
;-  Constants
;- ====================================

#HKey     = 1
#Pack     = 1
#File     = 1
#LNG      = 1
#Resource = 1

#Language = "qAES-Packer.lng"

#Pattern_ZIP$  = "ZIP (*.zip)|*.zip;*.jar"
#Pattern_LZMA$ = "LZMA (*.7z)|*.7z;*.lzma"
#Pattern_TAR$  = "TAR (*.tar)|*.tar;*.gzip;*.bzip2;*.bz2"
#Pattern_RES$  = "Resources (*.res)|*.res"

EnumerationBinary
  #Create
  #Open
  #Add
  #Replace
  #Remove
  #Encrypt
  #Decrypt
  #Packed
EndEnumeration

Enumeration 1
  #ZIP
  #LZMA
  #TAR
  #RES
EndEnumeration

Enumeration 
  #Image
  #Text
  #XML
  #JSON
EndEnumeration

#PopupMenu = 1
#DropDown  = 2

;{ ___ Window Constants ___
Enumeration 1
  #Window_PackerEx
  #Window_Key
  #Window_Preview
  #Window_OpenAs
  #Window_Language
EndEnumeration ;}

;{ ___ Gadget Constants ___
Enumeration 1
  
  #Return
  
  ;{ --- #PopupMenu ---
  #PopupMenu_SelectAll
  #PopupMenu_SelectNone
  #PopupMenu_RemoveFile
  ;}
  
  ;{ --- #DropDown ---
  #DropDown_TAR
  #DropDown_LZMA
  #DropDown_ZIP
  #DropDown_RES
  ;}
  
  ;{ --- #Window_PackerEx ---
  #Gadget_PackerEx_Tx_Archive
  #Gadget_PackerEx_SG_Archive
  #Gadget_PackerEx_Bt_OpenArchiv
  #Gadget_PackerEx_Bt_NewArchive
  #Gadget_PackerEx_FileList
  #Gadget_PackerEx_Bt_AddFile
  #Gadget_PackerEx_Bt_CryptFile
  #Gadget_PackerEx_Bt_RemoveFile
  #Gadget_PackerEx_Bt_Create
  #Gadget_PackerEx_Bt_Extract
  #Gadget_PackerEx_Frame
  ;}
  
  ;{ --- #Window_Key ---
  #Gadget_Key_SG_Key
  #Gadget_Key_OK
  #Gadget_Key_O_SecureKey
  #Gadget_Key_SG_SecureKey
  #Gadget_Key_ProgressBar
  ;}
  
  ;{ --- #Window_Preview ---
  #Gadget_Preview
  ;}
  
  ;{ --- #Window_OpenAs ---
  #Gadget_OpenAs_SG_File
  #Gadget_OpenAs_CB_Type
  #Gadget_OpenAs_OK
  #Gadget_OpenAs_ProgressBar
  ;}
  
  ;{ --- #Window_Language ---
  #Gadget_Language_ComboBox
  #Gadget_Language_OK
  ;}
  
EndEnumeration ;}

;{ ___ Font Constants ___
Enumeration 1
  #Font_Arial8
  #Font_Arial9B
  #Font_Arial10B
EndEnumeration  
;}

;{ ___ Image Constants ___
Enumeration 1
  #IMG_Add
  #IMG_AddCrypt
  #IMG_Create
  #IMG_Crypt
  #IMG_CryptPacked
  #IMG_Decrypted
  #IMG_Encrypted
  #IMG_Extract
  #IMG_Key
  #IMG_ListAdd
  #IMG_ListRemove
  #IMG_NoCrypt
  #IMG_OK
  #IMG_Open
  #IMG_Packed
  #IMG_Remove
  #IMG_SelectAll
  #IMG_SelectNone
  #IMG_Valid
  #IMG_ZIP
  #IMG_LZMA
  #IMG_TAR
  #IMG_RES
EndEnumeration  
;}

;{ ___ Resoures ___
If ResourceEx::Open(#Resource, "qAES-Packer.res")
  ResourceEx::UseImage(#Resource, #IMG_Add,         "Add.png")
  ResourceEx::UseImage(#Resource, #IMG_AddCrypt,    "AddCrypt.png")
  ResourceEx::UseImage(#Resource, #IMG_Create,      "Create.png")
  ResourceEx::UseImage(#Resource, #IMG_Crypt,       "Crypt.png")
  ResourceEx::UseImage(#Resource, #IMG_CryptPacked, "CryptPacked.png")
  ResourceEx::UseImage(#Resource, #IMG_Decrypted,   "Decrypted.png")
  ResourceEx::UseImage(#Resource, #IMG_Encrypted,   "Encrypted.png")
  ResourceEx::UseImage(#Resource, #IMG_Extract,     "Extract.png")
  ResourceEx::UseImage(#Resource, #IMG_Key,         "Key.png")
  ResourceEx::UseImage(#Resource, #IMG_ListAdd,     "ListAdd.png")
  ResourceEx::UseImage(#Resource, #IMG_ListRemove,  "ListRemove.png")
  ResourceEx::UseImage(#Resource, #IMG_NoCrypt,     "NoCrypt.png")
  ResourceEx::UseImage(#Resource, #IMG_OK,          "OK.png")
  ResourceEx::UseImage(#Resource, #IMG_Open,        "Open.png")
  ResourceEx::UseImage(#Resource, #IMG_Packed,      "Packed.png")
  ResourceEx::UseImage(#Resource, #IMG_Remove,      "Remove.png")
  ResourceEx::UseImage(#Resource, #IMG_SelectAll,   "SelectAll.png")
  ResourceEx::UseImage(#Resource, #IMG_SelectNone,  "SelectNone.png")
  ResourceEx::UseImage(#Resource, #IMG_Valid,       "Valid.png")
  ResourceEx::UseImage(#Resource, #IMG_ZIP,         "ZIP.png")
  ResourceEx::UseImage(#Resource, #IMG_LZMA,        "LZMA.png")
  ResourceEx::UseImage(#Resource, #IMG_TAR,         "TAR.png")
  ResourceEx::UseImage(#Resource, #IMG_RES,         "RES.png")
  ResourceEx::Close(#Resource)
EndIf ;}

;- ====================================
;-  Windows
;- ====================================

LoadFont(#Font_Arial8,   "Arial",  8)
LoadFont(#Font_Arial9B,  "Arial",  9, 256)
LoadFont(#Font_Arial10B, "Arial", 10, 256)

Global NewMap Msg.s()

Procedure.i Window_PackerEx()
  Define.i Width, Offset
  
  If OpenWindow(#Window_PackerEx, 0, 0, 400, 404, " qAES - Packer", #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_ScreenCentered|#PB_Window_Invisible)
    
    If CreatePopupImageMenu(#PopupMenu)
      MenuItem(#PopupMenu_SelectAll,  Msg("Menu_SelectAll"),  ImageID(#IMG_SelectAll))
      MenuItem(#PopupMenu_SelectNone, Msg("Menu_SelectNone"), ImageID(#IMG_SelectNone))
      MenuBar()
      MenuItem(#PopupMenu_RemoveFile, Msg("Menu_Remove"),     ImageID(#IMG_ListRemove))
    EndIf
    
    If CreatePopupImageMenu(#DropDown)
      MenuItem(#DropDown_ZIP,  Msg("Menu_ZIP"),  ImageID(#IMG_ZIP))
      MenuItem(#DropDown_LZMA, Msg("Menu_LZMA"), ImageID(#IMG_LZMA))
      MenuItem(#DropDown_TAR, Msg("Menu_TAR"),   ImageID(#IMG_TAR))
      MenuBar()
      MenuItem(#DropDown_RES, Msg("Menu_RES"),   ImageID(#IMG_RES))
    EndIf
    
    TextGadget(#Gadget_PackerEx_Tx_Archive, 10, 14, 54, 16, Msg("Archive") + ":")
      SetGadgetFont(#Gadget_PackerEx_Tx_Archive, FontID(#Font_Arial10B))
    
    Width = GadgetWidth(#Gadget_PackerEx_Tx_Archive, #PB_Gadget_RequiredSize)
    ResizeGadget(#Gadget_PackerEx_Tx_Archive, #PB_Ignore, #PB_Ignore, Width, #PB_Ignore)
    Offset = Width - 54
    
    StringGadget(#Gadget_PackerEx_SG_Archive, 68 + Offset, 12, 243 - Offset, 20, "", #PB_String_ReadOnly)
      SetGadgetFont(#Gadget_PackerEx_SG_Archive, FontID(#Font_Arial9B))
      SetGadgetColor(#Gadget_PackerEx_SG_Archive, #PB_Gadget_FrontColor, $800000)

    ButtonImageGadget(#Gadget_PackerEx_Bt_OpenArchiv, 317, 10, 25, 24, ImageID(#IMG_Open))
    ButtonEx::Gadget(#Gadget_PackerEx_Bt_NewArchive, 347, 10, 42, 24, "", #False, #Window_PackerEx) ; ImageID(#IMG_Add)
    ButtonEx::AddDropDown(#Gadget_PackerEx_Bt_NewArchive, #DropDown)
    ButtonEx::AddImage(#Gadget_PackerEx_Bt_NewArchive, #IMG_Add, 16, 16, ButtonEx::#Center)
    
    ListEx::Gadget(#Gadget_PackerEx_FileList, 10, 42, 380, 318, " " + Msg("Files") , 235, "files", ListEx::#GridLines|ListEx::#MultiSelect|ListEx::#AutoResize, #Window_PackerEx)
    ListEx::DisableReDraw(#Gadget_PackerEx_FileList, #True)
    ListEx::AddColumn(#Gadget_PackerEx_FileList, 1, "", 24, "image")
    ListEx::AddColumn(#Gadget_PackerEx_FileList, 2, " " + Msg("Size"), 80, "size")
    ListEx::AddColumn(#Gadget_PackerEx_FileList, 3, " " + Msg("Progress"), 120, "progress", ListEx::#ProgressBar)
    ListEx::SetProgressBarFlags(#Gadget_PackerEx_FileList, ListEx::#ShowPercent)
    ListEx::SetColorTheme(#Gadget_PackerEx_FileList, ListEx::#Theme_Blue)
    ListEx::SetFont(#Gadget_PackerEx_FileList, FontID(#Font_Arial9B), ListEx::#HeaderFont)
    ListEx::SetColumnAttribute(#Gadget_PackerEx_FileList, 3, ListEx::#Font, #Font_Arial8)
    ListEx::SetHeaderAttribute(#Gadget_PackerEx_FileList, ListEx::#Align, ListEx::#Center, 2)
    ListEx::SetHeaderAttribute(#Gadget_PackerEx_FileList, ListEx::#Align, ListEx::#Center, 3)
    ListEx::SetColumnAttribute(#Gadget_PackerEx_FileList, 2, ListEx::#Align, ListEx::#Right)
    ListEx::SetColumnAttribute(#Gadget_PackerEx_FileList, 3, ListEx::#Align, ListEx::#Center)
    ListEx::SetColor(#Gadget_PackerEx_FileList, ListEx::#FrontColor, $701919, 3)
    ListEx::SetAutoResizeColumn(#Gadget_PackerEx_FileList, 0, 100)
    ListEx::AttachPopupMenu(#Gadget_PackerEx_FileList, #PopupMenu)
    ListEx::HideColumn(#Gadget_PackerEx_FileList, 3, #True)
    ListEx::DisableReDraw(#Gadget_PackerEx_FileList, #False)
    
    FrameGadget(#Gadget_PackerEx_Frame, 295, 359, 95, 39, "")
    ButtonImageGadget(#Gadget_PackerEx_Bt_AddFile, 300, 369, 25, 24,    ImageID(#IMG_Add))
      GadgetToolTip(#Gadget_PackerEx_Bt_AddFile, Msg("Tip_AddFile")) 
    ButtonImageGadget(#Gadget_PackerEx_Bt_CryptFile, 330, 369, 25, 24,  ImageID(#IMG_Encrypted))
      GadgetToolTip(#Gadget_PackerEx_Bt_CryptFile, Msg("Tip_EncryptFile")) 
    ButtonImageGadget(#Gadget_PackerEx_Bt_RemoveFile, 360, 369, 25, 24, ImageID(#IMG_Remove))
      GadgetToolTip(#Gadget_PackerEx_Bt_RemoveFile, Msg("Tip_RemoveFile")) 
    ButtonImageGadget(#Gadget_PackerEx_Bt_Create,  10, 366, 32, 32,     ImageID(#IMG_Create))
      GadgetToolTip(#Gadget_PackerEx_Bt_Create, Msg("Tip_CreateArchive")) 
    ButtonImageGadget(#Gadget_PackerEx_Bt_Extract, 50, 366, 32, 32,     ImageID(#IMG_Extract))
      GadgetToolTip(#Gadget_PackerEx_Bt_Extract, Msg("Tip_ExtractFile")) 
      
    EnableGadgetDrop(#Gadget_PackerEx_FileList,   #PB_Drop_Files, #PB_Drag_Copy)
    EnableGadgetDrop(#Gadget_PackerEx_SG_Archive, #PB_Drop_Files, #PB_Drag_Copy)
    
    If Resize::AddWindow(#Window_PackerEx, 300, 200)
      Resize::AddGadget(#Gadget_PackerEx_Bt_OpenArchiv, Resize::#MoveX)
      Resize::AddGadget(#Gadget_PackerEx_Bt_NewArchive, Resize::#MoveX)
      Resize::AddGadget(#Gadget_PackerEx_SG_Archive,    Resize::#Width)
      Resize::AddGadget(#Gadget_PackerEx_Bt_Create,     Resize::#MoveY)
      Resize::AddGadget(#Gadget_PackerEx_Bt_Extract,    Resize::#MoveY)
      Resize::AddGadget(#Gadget_PackerEx_Frame,         Resize::#MoveX|Resize::#MoveY)
      Resize::AddGadget(#Gadget_PackerEx_Bt_AddFile,    Resize::#MoveX|Resize::#MoveY)
      Resize::AddGadget(#Gadget_PackerEx_Bt_CryptFile,  Resize::#MoveX|Resize::#MoveY)
      Resize::AddGadget(#Gadget_PackerEx_Bt_RemoveFile, Resize::#MoveX|Resize::#MoveY)
    EndIf
    
    DisableGadget(#Gadget_PackerEx_Bt_Create,     #True)
    DisableGadget(#Gadget_PackerEx_Bt_Extract,    #True)
    DisableGadget(#Gadget_PackerEx_Bt_CryptFile,  #True)
    DisableGadget(#Gadget_PackerEx_Bt_AddFile,    #True)  
    DisableGadget(#Gadget_PackerEx_Bt_RemoveFile, #True)
    
    HideWindow(#Window_PackerEx, #False)
  
    ProcedureReturn WindowID(#Window_PackerEx)
  EndIf
  
EndProcedure

Procedure.i Window_Key()
  Define.i OffsetX, Width
  
  If OpenWindow(#Window_Key, 0, 0, 265, 70, " " + Msg("Win_EnterKey"), #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(#Window_PackerEx))
    
    StringEx::Gadget(#Gadget_Key_SG_Key, 10, 11, 216, 22, "", StringEx::#Password|StringEx::#ShowButton, #Window_Key)
    
    ButtonImageGadget(#Gadget_Key_OK, 231, 10, 24, 24, ImageID(#IMG_OK))
    
    CheckBoxGadget(#Gadget_Key_O_SecureKey, 10, 40, 84, 20, " " + Msg("SecureKey"))
      SetGadgetFont(#Gadget_Key_O_SecureKey, FontID(#Font_Arial9B))
      GadgetToolTip(#Gadget_Key_O_SecureKey, Msg("Tip_Attention")) 
    
    Width = GadgetWidth(#Gadget_Key_O_SecureKey, #PB_Gadget_RequiredSize)
    ResizeGadget(#Gadget_Key_O_SecureKey, #PB_Ignore, #PB_Ignore, Width, #PB_Ignore)
    OffsetX = Width - 84
    
    StringGadget(#Gadget_Key_SG_SecureKey, 95 + OffsetX, 40, 50, 20, "", #PB_String_Numeric)
      GadgetToolTip(#Gadget_Key_O_SecureKey, Msg("Tip_NumberLoops") ) 
    ProgressEx::Gadget(#Gadget_Key_ProgressBar, 150 + OffsetX, 40, 105 - OffsetX, 20, 0, 100, ProgressEx::#Border|ProgressEx::#ShowPercent, #Window_Key)
    ProgressEx::SetFont(#Gadget_Key_ProgressBar, #Font_Arial9B)
    ProgressEx::SetColor(#Gadget_Key_ProgressBar, ProgressEx::#FrontColor,       $701919)
    ProgressEx::SetColor(#Gadget_Key_ProgressBar, ProgressEx::#ProgressBarColor, $AD7D43)
    ProgressEx::SetColor(#Gadget_Key_ProgressBar, ProgressEx::#GradientColor,    $D3B691)
    
    DisableGadget(#Gadget_Key_SG_SecureKey, #True)
    HideGadget(#Gadget_Key_ProgressBar,  #True)
    
    HideWindow(#Window_Key, #False)
  
    ProcedureReturn WindowID(#Window_Key)
  EndIf
  
EndProcedure

Procedure.i Window_Preview()
  
  If OpenWindow(#Window_Preview, 0, 0, 400, 400, " " + Msg("Win_Preview"), #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_SizeGadget|#PB_Window_Invisible, WindowID(#Window_PackerEx))
    
    PreView::Gadget(#Gadget_Preview, 10, 10, 380, 380, PreView::#Border|PreView::#ResizeWindow|PreView::#AutoResize, #Window_Preview)

    HideWindow(#Window_Preview, #False)
  
    ProcedureReturn WindowID(#Window_Preview)
  EndIf
  
EndProcedure

Procedure.i Window_OpenAs()
  
  If OpenWindow(#Window_OpenAs, 0, 0, 275, 70, " " + Msg("Win_OpenAs") + " .....", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(#Window_PackerEx))
    
    StringGadget(#Gadget_OpenAs_SG_File, 10, 12, 160, 20, "", #PB_String_ReadOnly)
    ComboBoxGadget(#Gadget_OpenAs_CB_Type, 175, 12, 60, 20)
    ButtonImageGadget(#Gadget_OpenAs_OK, 241, 10, 24, 24, ImageID(#IMG_OK))
   
    ProgressEx::Gadget(#Gadget_OpenAs_ProgressBar, 10, 40, 255, 20, 0, 100, ProgressEx::#Border|ProgressEx::#ShowPercent, #Window_OpenAs)
    ProgressEx::SetFont(#Gadget_OpenAs_ProgressBar, #Font_Arial9B)
    ProgressEx::SetColor(#Gadget_OpenAs_ProgressBar, ProgressEx::#FrontColor,       $701919)
    ProgressEx::SetColor(#Gadget_OpenAs_ProgressBar, ProgressEx::#ProgressBarColor, $AD7D43)
    ProgressEx::SetColor(#Gadget_OpenAs_ProgressBar, ProgressEx::#GradientColor,    $D3B691)
   
    HideWindow(#Window_OpenAs, #False)
   
    ProcedureReturn WindowID(#Window_OpenAs)
  EndIf
  
EndProcedure

Procedure.i Window_Language()
  If OpenWindow(#Window_Language, 0, 0,170,45, "Select Language", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_Invisible)
      ComboBoxGadget(#Gadget_Language_ComboBox, 10, 10, 120, 24)
        SetGadgetFont(#Gadget_Language_ComboBox, FontID(#Font_Arial10B))
      ButtonImageGadget(#Gadget_Language_OK, 136, 10, 24, 24, ImageID(#IMG_OK))
      HideWindow(#Window_Language, #False)
    ProcedureReturn WindowID(#Window_Language)
  EndIf
EndProcedure

;- ====================================
;-  Structures / Variables
;- ====================================

Structure Language_Structure
  Map Strg.s()
EndStructure

Structure Preview_Structure ;{ Preview\...
  Type.i
  ID.i
  String.s
EndStructure ;}

Structure File_Structure    ;{ Archive\File()\...
  Name.s
  Path.s
  Size.q
  Encrypted.i
  Flags.i
EndStructure ;}

Structure Archive_Structure ;{ Archiv\...
  Name.s
  Path.s
  Plugin.i
  Mode.i
  Changed.i
  Map Idx.i()
  List File.File_Structure()
EndStructure ;}
Global Archive.Archive_Structure

Global Remember$

;- ====================================
;-  Procedures
;- ====================================

Procedure.s EnterKeyWindow()
  Define.s Key$
  Define.q Loops
  Define.i quitWindow = #False
  
  If Window_Key()
    
    AddKeyboardShortcut(#Window_Key, #PB_Shortcut_Return, #Return)

    StringEx::SetText(#Gadget_Key_SG_Key, Remember$)
    SetGadgetText(#Gadget_Key_SG_SecureKey, AppReg::GetValue(#HKey, "SecureKey", "Loops", "2048"))
    
    SetActiveGadget(#Gadget_Key_SG_Key)
    
    If AppReg::GetInteger(#HKey, "SecureKey", "State", #False)
      SetGadgetState(#Gadget_Key_O_SecureKey,  #True)
      DisableGadget(#Gadget_Key_SG_SecureKey, #False)
    EndIf
  
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow        ;{ Close Window
          Select EventWindow()
            Case #Window_Key
              Key$ = ""
              Remember$ = ""
              quitWindow = #True
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_Key_O_SecureKey  ;{ Secure Key
              If GetGadgetState(#Gadget_Key_O_SecureKey)
                DisableGadget(#Gadget_Key_SG_SecureKey, #False)
              Else
                DisableGadget(#Gadget_Key_SG_SecureKey, #True)
              EndIf ;}
            Case #Gadget_Key_OK           ;{ Apply
              
              Remember$ = StringEx::GetText(#Gadget_Key_SG_Key)
              
              If GetGadgetState(#Gadget_Key_O_SecureKey)
                HideGadget(#Gadget_Key_ProgressBar, #False)
                Key$ = PackEx::CreateSecureKey(StringEx::GetText(#Gadget_Key_SG_Key), ValF(GetGadgetText(#Gadget_Key_SG_SecureKey)), #Gadget_Key_ProgressBar)
                AppReg::SetInteger(#HKey, "SecureKey", "State", #True)
                AppReg::SetValue(#HKey,   "SecureKey", "Loops", GetGadgetText(#Gadget_Key_SG_SecureKey))
              Else
                Key$ = StringEx::GetText(#Gadget_Key_SG_Key)
                AppReg::SetInteger(#HKey, "SecureKey", "State", #False)
              EndIf
              
              quitWindow = #True
              ;}
          EndSelect
        Case #PB_Event_Menu
          Select EventMenu()
            Case #Return  ;{ Apply
  
              Remember$ = GetGadgetText(#Gadget_Key_SG_Key)
              
              If GetGadgetState(#Gadget_Key_O_SecureKey)
                HideGadget(#Gadget_Key_ProgressBar, #False)
                Key$ = PackEx::CreateSecureKey(GetGadgetText(#Gadget_Key_SG_Key), ValF(GetGadgetText(#Gadget_Key_SG_SecureKey)), #Gadget_Key_ProgressBar)
                AppReg::SetInteger(#HKey, "SecureKey", "State", #True)
                AppReg::SetValue(#HKey,   "SecureKey", "Loops", GetGadgetText(#Gadget_Key_SG_SecureKey))
              Else
                Key$ = GetGadgetText(#Gadget_Key_SG_Key)
                AppReg::SetInteger(#HKey, "SecureKey", "State", #False)
              EndIf
              
              quitWindow = #True
              ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_Key)
  EndIf
  
  ProcedureReturn Key$
EndProcedure


Procedure   PreviewWindow(Type.i, ID.i=#False, String.s="")
  Define.i quitWindow = #False
  
  If Window_Preview()
    
    Select Type
      Case #Image
        If IsImage(ID)
          PreView::Image(#Gadget_Preview, ID)
        Else
          quitWindow = #True
        EndIf 
      Case #XML
        If IsXML(ID)
          PreView::XML(#Gadget_Preview, ID)
        Else
          quitWindow = #True
        EndIf 
      Case #JSON
        If IsJSON(ID)
          PreView::JSON(#Gadget_Preview, ID)
        Else
          quitWindow = #True
        EndIf 
      Default
        If String
          Preview::Text(#Gadget_Preview, String)
        EndIf
    EndSelect

    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow        ;{ Close Window
          Select EventWindow()
            Case #Window_Preview
              
              Select Type
                Case #Image
                  If IsImage(ID) : FreeImage(ID) : EndIf 
                Case #XML
                  If IsXML(ID) : FreeXML(ID) : EndIf 
                Case #JSON
                  If IsJSON(ID) : FreeJSON(ID) : EndIf 
              EndSelect
              
              quitWindow = #True
          EndSelect ;}
      EndSelect
    Until quitWindow

    CloseWindow(#Window_Preview)
  EndIf  
  
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


Procedure   CreateResourceFile(File.s, PackFile.s) 
  
  If CreateFile(#File, File, #PB_UTF8)
    
    WriteStringN(#File, "#ResEx = 1")
    
    WriteStringN(#File, "")
    
    WriteStringN(#File, "Enumeration 1")
    ForEach Archive\File()
      Select GetExtensionPart(Archive\File()\Name)
        Case "jpg", "jpeg", "png", "gif", "tga", "tif", "bmp"
          WriteStringN(#File, "  #IMG_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-"))
      EndSelect      
    Next  
    WriteStringN(#File, "EndEnumeration")
    
    WriteStringN(#File, "")
    
    WriteStringN(#File, "Enumeration 1")
    ForEach Archive\File()
      Select GetExtensionPart(Archive\File()\Name)
        Case "xml"
          WriteStringN(#File, "  #XML_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-"))
        Case "json", "jsn"
          WriteStringN(#File, "  #JSON_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-"))
        Case "wav"
          WriteStringN(#File, "  #WAV_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-"))
        Case "ogg"
          WriteStringN(#File, "  #OGG_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-"))
        Case "mod"
          WriteStringN(#File, "  #MOD_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-"))  
      EndSelect      
    Next  
    WriteStringN(#File, "EndEnumeration")
    
    WriteStringN(#File, "")
    
    WriteStringN(#File, "If ResourceEx::Open(#ResEx, " + Chr(34) + GetFilePart(PackFile) + Chr(34) + ")")
    
    ForEach Archive\File()
      If GetExtensionPart(Archive\File()\Name)
        Select GetExtensionPart(Archive\File()\Name)
          Case "jpg", "jpeg", "png", "gif", "tga", "tif"
            WriteStringN(#File, "  ResourceEx::UseImage(#ResEx, #IMG_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-") + ", " + Chr(34) + Archive\File()\Name + Chr(34) + ")")
          Case "xml"  
            WriteStringN(#File, "  ResourceEx::UseXML(#ResEx, #XML_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-") + ", " + Chr(34) + Archive\File()\Name + Chr(34) + ")")
          Case "json", "jsn"
            WriteStringN(#File, "  ResourceEx::UseJSON(#ResEx, #JSON_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-") + ", " + Chr(34) + Archive\File()\Name + Chr(34) + ")")
          Case "wav"
            WriteStringN(#File, "  ResourceEx::UseSound(#ResEx, #WAV_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-") + ", " + Chr(34) + Archive\File()\Name + Chr(34) + ")")
          Case "ogg"
            WriteStringN(#File, "  ResourceEx::UseSound(#ResEx, #OGG_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-") + ", " + Chr(34) + Archive\File()\Name + Chr(34) + ")")
          Case "mod"
            WriteStringN(#File, "  ResourceEx::UseMusic(#ResEx, #MOD_" + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-") + ", " + Chr(34) + Archive\File()\Name + Chr(34) + ")")
          Case "txt"
            WriteStringN(#File, "  " + RemoveString(GetFilePart(Archive\File()\Name, #PB_FileSystem_NoExtension), "-") + "$ = " + "ResourceEx::UseText(#ResEx, " + Chr(34) + Archive\File()\Name + Chr(34) + ")")
        EndSelect
      EndIf 
    Next  
    
    WriteStringN(#File, "EndIf")
    
    CloseFile(#File)
  EndIf
  
EndProcedure


Procedure.s StrD_(Value.d)
  If Value < 10
    ProcedureReturn RTrim(RTrim(StrD(Value, 2), "0"), ".")
  ElseIf Value < 100
    ProcedureReturn RTrim(RTrim(StrD(Value, 1), "0"), ".")
  Else
    ProcedureReturn RTrim(RTrim(StrD(Value, 0), "0"), ".")
  EndIf
EndProcedure 

Procedure.s FormatBytes(Size.q)
  Define i.i, Calc.d
  Define.s Units = "KB|MB|GB"
  
  If Size < 1024
    ProcedureReturn Str(Size) + " Byte"  
  EndIf
  
  Calc = Size / 1024
  
  For i=1 To 3
    If Calc < 1024
      ProcedureReturn StrD_(Calc) + " " + StringField(Units, i, "|")
    EndIf
    Calc / 1024
  Next 
  
  ProcedureReturn StrD_(Calc) + " TB"
EndProcedure


Procedure.i RemoveFile_(FileName.s) 
  
  If FindMapElement(Archive\Idx(), FileName)
    
    If SelectElement(Archive\File(), Archive\Idx())
      
      If Archive\File()\Flags & #Add
        DeleteElement(Archive\File())
        DeleteMapElement(Archive\Idx())
      Else  
        Archive\Changed = #True
        Archive\File()\Flags = #Remove
      EndIf 
      
      SetGadgetColor(#Gadget_PackerEx_SG_Archive, #PB_Gadget_FrontColor, $3C14DC)
     
      DisableGadget(#Gadget_PackerEx_Bt_Create,  #False)
      DisableGadget(#Gadget_PackerEx_Bt_Extract, #True)
      
    EndIf 
    
  EndIf 
  
EndProcedure


Procedure.i LoadContent(PackFile.s, Plugin.i=#PB_PackerPlugin_Zip)
  Define.i Row, Result = #False
  
  If PackEx::Open(#Pack, PackFile, Plugin)
    PackEx::ReadContent(#Pack)
    Result = #True
    PackEx::Close(#Pack)
  EndIf
  
  ClearList(Archive\File())
  ListEx::ClearItems(#Gadget_PackerEx_FileList)
  ;ListEx::SetItemImage(#Gadget_PackerEx_FileList, ListEx::#Header, 1, 14, 14, #IMG_Key, ListEx::#Center)
  
  ForEach PackEx::Content()
    
    If AddElement(Archive\File())

      Archive\File()\Name  = PackEx::Content()\FileName
      Archive\File()\Path  = ""
      Archive\File()\Size  = PackEx::Content()\Size
      Archive\File()\Flags = #Packed
      
      Archive\Idx(Archive\File()\Name) = ListIndex(Archive\File())
      
      Row = ListEx::AddItem(#Gadget_PackerEx_FileList, ListEx::#LastItem, PackEx::Content()\FileName + #LF$ + #LF$ + FormatBytes(PackEx::Content()\Size), PackEx::Content()\FileName)
      ListEx::SetItemData(#Gadget_PackerEx_FileList, Row, ListIndex(Archive\File()))
      If PackEx::Content()\Encrypted
        ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $007CE1, 0)
        ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 15, 15, #IMG_CryptPacked, ListEx::#Center)
        Archive\File()\Encrypted = #True
      Else 
        ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $701919, 0)
        ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 14, 14, #IMG_Packed, ListEx::#Center)
        Archive\File()\Encrypted = #False
      EndIf
      
    EndIf
    
  Next
  
  ProcedureReturn Result
EndProcedure

Procedure   UpdateFileList()
  Define. i Row
  
  ListEx::ClearItems(#Gadget_PackerEx_FileList)
  ;ListEx::SetItemImage(#Gadget_PackerEx_FileList, ListEx::#Header, 1, 14, 14, #IMG_Key, ListEx::#Center)
  
  ForEach Archive\File()
    
    Row = ListEx::AddItem(#Gadget_PackerEx_FileList, ListEx::#LastItem, Archive\File()\Name + #LF$ + #LF$ + FormatBytes(Archive\File()\Size), Archive\File()\Name)
    ListEx::SetItemData(#Gadget_PackerEx_FileList, Row, ListIndex(Archive\File()))
    
    If Archive\File()\Flags & #Remove
      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $0000FF, 0)
      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 14, 14, #IMG_ListRemove, ListEx::#Center)
    ElseIf Archive\File()\Flags & #Add And Archive\File()\Flags & #Encrypt
      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $008000, 0)
      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 14, 14, #IMG_AddCrypt, ListEx::#Center)
    ElseIf Archive\File()\Encrypted And Archive\File()\Flags & #Packed
      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $007CE1, 0)
      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 14, 14, #IMG_CryptPacked, ListEx::#Center)
    ElseIf Archive\File()\Encrypted
      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $007CE1, 0)
      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 14, 14, #IMG_Encrypted, ListEx::#Center)
    ElseIf Archive\File()\Flags & #Add Or Archive\File()\Flags & #Replace
      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $008000, 0)
      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 14, 14, #IMG_ListAdd, ListEx::#Center)
    ElseIf Archive\File()\Flags & #Packed
      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $701919, 0)
      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 15, 15, #IMG_Packed, ListEx::#Center)
    Else  
      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $701919, 0)
      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 14, 14, #False, ListEx::#Center)
    EndIf
    
  Next
  
EndProcedure

Procedure.i IsArchive(File.s)
  
  Select LCase(GetExtensionPart(File))
    Case "zip", "7z", "lzma"
      ProcedureReturn #True
    Case "tar", "gzip", "bzip2", "bz2"
      ProcedureReturn #True
    Default
      ProcedureReturn #False
  EndSelect
  
EndProcedure


Procedure   Language(Language.s)
  NewMap Lng.Language_Structure() 
  
  ClearMap(Msg())
  
  If LoadXML(#LNG, #Language)
    ExtractXMLMap(MainXMLNode(#LNG), Lng())
    CopyMap(Lng(Language)\Strg(), Msg())
    FreeXML(#LNG)
  EndIf
  
EndProcedure


Procedure.i PreviewAsWindow(Key.s, *Preview.Preview_Structure)
  Define.i Image, XML, JSON, Result = #False
  Define.s String
  Define.i quitWindow = #False
  
  If Window_OpenAs()
    
    SetGadgetText(#Gadget_OpenAs_SG_File, Archive\File()\Name)
    
    ;{ --- ComboBox ---
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 0, "Text")
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 1, "XML")
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 2, "JSON")
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 3, "Image")
    
    Select LCase(GetExtensionPart(Archive\File()\Name))
      Case "jpg", "png"
        SetGadgetState(#Gadget_OpenAs_CB_Type, 3)
      Case "xml", "html", "htm"
        SetGadgetState(#Gadget_OpenAs_CB_Type, 1)
      Case "json"
        SetGadgetState(#Gadget_OpenAs_CB_Type, 2)
      Default
        SetGadgetState(#Gadget_OpenAs_CB_Type, 0)
    EndSelect ;}
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow ;{ Close Window
          Select EventWindow()
            Case #Window_OpenAs
              quitWindow = #True
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_OpenAs_OK ;{ Apply
              
              If PackEx::Open(#Pack, Archive\Path + Archive\Name, Archive\Plugin)
                
                PackEx::Progress\Compress = Msg("Uncompressing") + " ....."
                
                Select GetGadgetState(#Gadget_OpenAs_CB_Type)
                  Case 1  ;{ Preview XML
                    
                    If Archive\File()\Encrypted
                      If Key = "" : Key = EnterKeyWindow() : EndIf
                      If Key
                        XML = PackEx::DecompressXML(#Pack, #PB_Any, Archive\File()\Name, Key, #Gadget_OpenAs_ProgressBar)
                        If XML
                          *Preview\ID   = XML
                          *Preview\Type = #XML
                        EndIf
                      EndIf
                    Else
                      XML = PackEx::DecompressXML(#Pack, #PB_Any, Archive\File()\Name, "", #Gadget_OpenAs_ProgressBar)
                      If XML
                        *Preview\ID   = XML
                        *Preview\Type = #XML
                      EndIf 
                    EndIf
                    ;}
                  Case 2  ;{ Preview JSON
                    
                    If Archive\File()\Encrypted
                      If Key = "" : Key = EnterKeyWindow() : EndIf
                      If Key
                        JSON = PackEx::DecompressJSON(#Pack, #PB_Any, Archive\File()\Name, Key, #Gadget_OpenAs_ProgressBar)
                        If JSON
                          *Preview\ID   = JSON
                          *Preview\Type = #JSON
                        EndIf
                      EndIf
                    Else
                      JSON = PackEx::DecompressJSON(#Pack, #PB_Any, Archive\File()\Name, "", #Gadget_OpenAs_ProgressBar)
                      If JSON
                        *Preview\ID   = JSON
                        *Preview\Type = #JSON
                      EndIf 
                    EndIf
                    ;}
                  Case 3  ;{ Preview Image
                    
                    If Archive\File()\Encrypted
                      If Key = "" : Key = EnterKeyWindow() : EndIf
                      If Key
                        Image = PackEx::DecompressImage(#Pack, #PB_Any, Archive\File()\Name, Key, #Gadget_OpenAs_ProgressBar)
                        If Image
                          *Preview\ID   = Image
                          *Preview\Type = #Image
                        EndIf
                      EndIf
                    Else
                      Image = PackEx::DecompressImage(#Pack, #PB_Any, Archive\File()\Name, "", #Gadget_OpenAs_ProgressBar)
                      If Image
                        *Preview\ID   = Image
                        *Preview\Type = #Image
                      EndIf 
                    EndIf
                    ;}
                  Default ;{ Preview Text
                    
                    If Archive\File()\Encrypted
                      If Key = "" : Key = EnterKeyWindow() : EndIf
                      If Key
                        String = PackEx::DecompressText(#Pack, Archive\File()\Name, Key, #Gadget_OpenAs_ProgressBar)
                        If String
                          *Preview\String = String
                          *Preview\Type   = #Text
                        EndIf
                      EndIf
                    Else
                      String = PackEx::DecompressText(#Pack, Archive\File()\Name, "", #Gadget_OpenAs_ProgressBar)
                      If String
                        *Preview\String = String
                        *Preview\Type   = #Text
                      EndIf 
                    EndIf
                    ;}
                EndSelect
                
                Result = #True
                
                PackEx::Close(#Pack)
              EndIf
              
              quitWindow = #True
              ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_OpenAs)
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure.i OpenAsWindow(PackFile.s, NewArchiv.i=#False)
  Define.i Extension, Result = #PB_Default
  Define.i quitWindow = #False
  
  If Window_OpenAs()
    
    HideGadget(#Gadget_OpenAs_ProgressBar, #True)
    ResizeWindow(#Window_OpenAs, #PB_Ignore, #PB_Ignore, #PB_Ignore, 42)
    
    If Not NewArchiv : SetWindowTitle(#Window_OpenAs, " " + Msg("Win_CreateAs")) : EndIf
    
    SetGadgetText(#Gadget_OpenAs_SG_File, GetFilePart(PackFile))
    
    Extension = AppReg::GetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), 1)
    
    ;{ --- ComboBox ---
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 0, "ZIP")
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 1, "LZMA")
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 2, "TAR")
    AddGadgetItem(#Gadget_OpenAs_CB_Type, 3, "RES")
    ;}
    SetGadgetState(#Gadget_OpenAs_CB_Type, Extension - 1)
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow ;{ Close Window
          Select EventWindow()
            Case #Window_OpenAs
              quitWindow = #True
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_OpenAs_OK ;{ Apply
              
              If NewArchiv
                
                Select GetGadgetState(#Gadget_OpenAs_CB_Type)
                  Case 0  ;{ ZIP
                    Archive\Plugin = #PB_PackerPlugin_Zip
                    AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #ZIP)
                    Result = #ZIP
                    ;}
                  Case 1  ;{ LZMA
                    Archive\Plugin = #PB_PackerPlugin_Lzma
                    AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #LZMA)
                    Result = #LZMA
                    ;}
                  Case 2  ;{ TAR
                    Archive\Plugin = #PB_PackerPlugin_Tar
                    AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #TAR)
                    Result = #TAR
                    ;}
                  Case 3  ;{ Resource
                    Archive\Plugin = #PB_PackerPlugin_Lzma
                    AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #RES)
                    Result = #RES
                    ;}
                EndSelect
                
              Else
                
                Select GetGadgetState(#Gadget_OpenAs_CB_Type)
                  Case 0  ;{ ZIP
                    If LoadContent(PackFile, #PB_PackerPlugin_Zip)
                      Archive\Plugin = #PB_PackerPlugin_Zip
                      AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #ZIP)
                      Result = #ZIP
                    EndIf
                    ;}
                  Case 1  ;{ LZMA
                    If LoadContent(PackFile, #PB_PackerPlugin_Lzma)
                      Archive\Plugin = #PB_PackerPlugin_Lzma
                      AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #LZMA)
                      Result = #LZMA
                    EndIf
                    ;}
                  Case 2  ;{ TAR
                    If LoadContent(PackFile, #PB_PackerPlugin_Tar)
                      Archive\Plugin = #PB_PackerPlugin_Tar
                      AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #TAR)
                      Result = #TAR
                    EndIf
                    ;}
                  Case 3  ;{ Resource
                    If LoadContent(PackFile, #PB_PackerPlugin_Lzma)
                      Archive\Plugin = #PB_PackerPlugin_Lzma
                      AppReg::SetInteger(#HKey, "Extension", LCase(GetExtensionPart(PackFile)), #RES)
                      Result = #RES
                    EndIf
                    ;}
                EndSelect
                
              EndIf
              
              quitWindow = #True
              ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_OpenAs)
  EndIf
  
  ProcedureReturn Result
EndProcedure


Procedure   OpenPackFile_(PackFile.s)
  Define.i Result
  
  Archive\Mode    = #Open
  Archive\Changed = #False
  
  Archive\Name   = GetFilePart(PackFile)
  Archive\Path   = GetPathPart(PackFile)
  SetGadgetText(#Gadget_PackerEx_SG_Archive, Archive\Name)
  SetGadgetColor(#Gadget_PackerEx_SG_Archive, #PB_Gadget_FrontColor, $8B0000)

  Select LCase(GetExtensionPart(PackFile))
    Case "zip", "jar"
      If LoadContent(PackFile, #PB_PackerPlugin_Zip)
        Archive\Plugin = #PB_PackerPlugin_Zip
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #ZIP)
      EndIf 
    Case "7z", "lzma"
      If LoadContent(PackFile, #PB_PackerPlugin_Lzma)
        Archive\Plugin = #PB_PackerPlugin_Lzma
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #LZMA)
      EndIf
    Case "tar", "gzip", "bzip2", "bz2"
      If LoadContent(PackFile, #PB_PackerPlugin_Tar)
        Archive\Plugin = #PB_PackerPlugin_Tar
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #TAR)
      EndIf
    Case "res"
      If LoadContent(PackFile, #PB_PackerPlugin_Lzma)
        Archive\Plugin = #PB_PackerPlugin_Lzma
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #RES)
      EndIf
    Default
      
      Result = OpenAsWindow(PackFile)
      If Result >= 0
        AppReg::SetInteger(#HKey, "Archive", "Pattern", 0)
      Else  
        Archive\Mode   = #False
        Archive\Name   = ""
        Archive\Path   = ""
        SetGadgetText(#Gadget_PackerEx_SG_Archive, "")
      EndIf
      
  EndSelect
  
  DisableGadget(#Gadget_PackerEx_Bt_Create,     #True)
  DisableGadget(#Gadget_PackerEx_Bt_Extract,    #False)
  DisableGadget(#Gadget_PackerEx_Bt_AddFile,    #False) 
  DisableGadget(#Gadget_PackerEx_Bt_CryptFile,  #True)
  DisableGadget(#Gadget_PackerEx_Bt_RemoveFile, #False)
  
EndProcedure

Procedure.s NewArchive_(Pattern.i)
  Define.i Result
  Define.s PackFile$
  
  PackFile$ = SaveFileRequester(Msg("Msg_CreatArchiv"), AppReg::GetValue(#HKey, "Archive", "Path", "C:\") + "*.*", Msg("AllFiles")+" (*.*)|*.*; |"+#Pattern_ZIP$+"|"+#Pattern_LZMA$+"|"+#Pattern_TAR$+"|"+#Pattern_RES$, Pattern)
  
  If GetExtensionPart(PackFile$) = "" ;{ Missing Extension Part
    Select SelectedFilePattern()
      Case #ZIP
        PackFile$ + ".zip"
      Case #LZMA
        PackFile$ + ".7z"
      Case #TAR
        PackFile$ + ".tar"
      Case #RES
        PackFile$ + ".res"
    EndSelect ;}
  EndIf  
  
  If PackFile$
    AppReg::SetValue(#HKey, "Archive", "Path", GetPathPart(PackFile$))
    
    ListEx::ClearItems(#Gadget_PackerEx_FileList)
    ClearList(Archive\File())
    
    Archive\Mode    = #Create
    Archive\Changed = #False
    
    Archive\Name   = GetFilePart(PackFile$)
    Archive\Path   = GetPathPart(PackFile$)
    SetGadgetText(#Gadget_PackerEx_SG_Archive, Archive\Name)
    SetGadgetColor(#Gadget_PackerEx_SG_Archive, #PB_Gadget_FrontColor, $8B0000)
    
    Select SelectedFilePattern()
      Case #ZIP
        Archive\Plugin = #PB_PackerPlugin_Zip
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #ZIP)
      Case #LZMA
        Archive\Plugin = #PB_PackerPlugin_Lzma
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #LZMA)
      Case #TAR
        Archive\Plugin = #PB_PackerPlugin_Tar
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #TAR)
      Case #RES
        Archive\Plugin = #PB_PackerPlugin_Lzma
        AppReg::SetInteger(#HKey, "Archive", "Pattern", #RES)
      Default
        Result = OpenAsWindow(PackFile$, #True)
        If Result >= 0
          AppReg::SetInteger(#HKey, "Archive", "Pattern", 0)
        Else
          Archive\Mode   = #False
          Archive\Name   = ""
          Archive\Path   = ""
          SetGadgetText(#Gadget_PackerEx_SG_Archive, "")
        EndIf 
    EndSelect
    
    DisableGadget(#Gadget_PackerEx_Bt_Create,     #False)
    DisableGadget(#Gadget_PackerEx_Bt_Extract,    #True)
    DisableGadget(#Gadget_PackerEx_Bt_CryptFile,  #False)
    DisableGadget(#Gadget_PackerEx_Bt_AddFile,    #False)  
    DisableGadget(#Gadget_PackerEx_Bt_RemoveFile, #False)
    
  EndIf
  
  ProcedureReturn PackFile$
EndProcedure


Procedure UpdateProgressBar()
  
  
  If PackEx::Progress\Flags & PackEx::#Encrypt
    
    If PackEx::Progress\Gadget = #Gadget_OpenAs_ProgressBar
      ProgressEx::SetState(#Gadget_OpenAs_ProgressBar, PackEx::Progress\State)
    Else
      ListEx::SetCellState(PackEx::Progress\Gadget, PackEx::Progress\Row, PackEx::Progress\Label, PackEx::Progress\State)
    EndIf
  EndIf
  
  If PackEx::Progress\Flags & PackEx::#Compress
    If PackEx::Progress\Gadget = #Gadget_OpenAs_ProgressBar
      ProgressEx::SetText(#Gadget_OpenAs_ProgressBar, PackEx::Progress\Compress)
    Else
      ListEx::SetCellText(PackEx::Progress\Gadget, PackEx::Progress\Row, PackEx::Progress\Label, PackEx::Progress\Compress)
    EndIf
  EndIf
  
  If PackEx::Progress\Flags & PackEx::#SecureKey
    
    ProgressEx::SetState(#Gadget_Key_ProgressBar, PackEx::Progress\State)
    
  EndIf 
  
EndProcedure
PackEx::ProgressProcedure(@UpdateProgressBar())

;- ====================================
;-  Main Loop
;- ====================================

Define.i i, Idx, r, Rows, Row, Count, CountAll, EnterKey
Define.s PackFile$, Files$, File$, Path$, FileName$, Key$, Language$
Define   Preview.Preview_Structure

Window::Load("qAES-Packer.win")
AppReg::Open(#HKey, "qAES-Packer.reg", "qAES-Packer", "Thorsten Hoeppner")

Language$ = AppReg::GetValue(#HKey, "Internal", "Language", "")
If Language$ = "" : Language$ = SelectLanguage() : EndIf

Language(Language$)

If Window_PackerEx()
  Define quitWindow = #False
  
  Window::RestoreSize(#Window_PackerEx, Window::#IgnoreState)
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow ;{ Close Window
        Select EventWindow()
          Case #Window_PackerEx
            If Archive\Changed
              If MessageRequester(" " + Msg("Msg_CloseWindow"), Msg("Msg_NotSaved") + #LF$ + Msg("Msg_CloseProgram"), #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning) = #PB_MessageRequester_Yes
                quitWindow = #True
              EndIf
            Else
              quitWindow = #True
            EndIf
        EndSelect ;}
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gadget_PackerEx_SG_Archive
          Case #Gadget_PackerEx_Bt_OpenArchiv    ;{ Open archive
            PackFile$ = OpenFileRequester(Msg("Win_OpenArchive"), AppReg::GetValue(#HKey, "Archive", "Path", "C:\") + "*.*", Msg("AllFiles")+"(*.*)|*.*; |"+#Pattern_ZIP$+"|"+#Pattern_LZMA$+"|"+#Pattern_TAR$+"|"+#Pattern_RES$, AppReg::GetInteger(#HKey, "Archive", "Pattern", 0))
            If PackFile$
              AppReg::SetValue(#HKey, "Archive", "Path", GetPathPart(PackFile$))
              OpenPackFile_(PackFile$)
            EndIf ;}
          Case #Gadget_PackerEx_Bt_AddFile       ;{ Add file to archive
            Files$ = OpenFileRequester(Msg("Msg_AddFile") , AppReg::GetValue(#HKey, "Files", "Path", AppReg::GetValue(#HKey, "Archive", "Path", "C:\")), Msg("AllFiles")+"(*.*)|*.*", 0, #PB_Requester_MultiSelection)
            AppReg::SetValue(#HKey, "Files", "Path", GetPathPart(Files$))
            
            While Files$ 
              If AddElement(Archive\File())
                Archive\File()\Name = GetFilePart(Files$)
                Archive\File()\Path = GetPathPart(Files$)
                Archive\File()\Size = FileSize(Files$)
                If FindMapElement(Archive\Idx(), Archive\File()\Name)
                  Archive\File()\Flags = #Replace
                Else
                  Archive\File()\Flags = #Add
                EndIf
                Archive\Idx(Archive\File()\Name) = ListIndex(Archive\File())
                Archive\Changed = #True
              EndIf
              Files$ = NextSelectedFileName()
            Wend 
            
            SetGadgetColor(#Gadget_PackerEx_SG_Archive, #PB_Gadget_FrontColor, $3C14DC)
          
            DisableGadget(#Gadget_PackerEx_Bt_Create,    #False)
            DisableGadget(#Gadget_PackerEx_Bt_CryptFile, #False)
            DisableGadget(#Gadget_PackerEx_Bt_Extract,   #True)

            UpdateFileList()
            ;}
          Case #Gadget_PackerEx_Bt_CryptFile     ;{ Set Encryption for file(s)
            Rows = ListEx::CountItems(#Gadget_PackerEx_FileList)
            If Rows
              If ListEx::CountItems(#Gadget_PackerEx_FileList, ListEx::#Selected)
                For r = Rows - 1 To 0 Step -1
                  If ListEx::GetItemState(#Gadget_PackerEx_FileList, r) & ListEx::#Selected
                    Idx = ListEx::GetItemData(#Gadget_PackerEx_FileList, r)
                    If SelectElement(Archive\File(), Idx)
                      If Archive\File()\Flags & #Add
                        If Archive\File()\Flags & #Encrypt
                          Archive\File()\Flags & ~#Encrypt
                        Else
                          Archive\File()\Flags | #Encrypt
                        EndIf 
                        Archive\Changed = #True
                      EndIf 
                    EndIf 
                  EndIf 
                Next
              Else
                Row = ListEx::GetState(#Gadget_PackerEx_FileList)
                If Row >= 0 
                  Idx = ListEx::GetItemData(#Gadget_PackerEx_FileList, Row)
                  If SelectElement(Archive\File(), Idx)
                    If Archive\File()\Flags & #Add
                      If Archive\File()\Flags & #Encrypt
                          Archive\File()\Flags & ~#Encrypt
                        Else
                          Archive\File()\Flags | #Encrypt
                        EndIf 
                      Archive\Changed = #True
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
    
            UpdateFileList()
            ;}
          Case #Gadget_PackerEx_Bt_RemoveFile    ;{ Remove file from list or archive
            
            Rows = ListEx::CountItems(#Gadget_PackerEx_FileList)
            If Rows
              If ListEx::CountItems(#Gadget_PackerEx_FileList, ListEx::#Selected)
                For r = Rows - 1 To 0 Step -1
                  If ListEx::GetItemState(#Gadget_PackerEx_FileList, r) & ListEx::#Selected
                    FileName$ = ListEx::GetRowLabel(#Gadget_PackerEx_FileList, r)
                    RemoveFile_(FileName$) 
                  EndIf 
                Next
              Else
                Row = ListEx::GetState(#Gadget_PackerEx_FileList)
                If Row >= 0
                  FileName$ = ListEx::GetRowLabel(#Gadget_PackerEx_FileList, Row)
                  RemoveFile_(FileName$) 
                EndIf
              EndIf
            EndIf
 
            UpdateFileList()
            ;}
          Case #Gadget_PackerEx_Bt_Create        ;{ Create archiv
            
            Key$  = ""
            Count = 0
            
            PackEx::Progress\Label    = "progress"
            PackEx::Progress\Compress = "Compressing ..."
            
            ListEx::HideColumn(#Gadget_PackerEx_FileList, 2, #True)
            ListEx::HideColumn(#Gadget_PackerEx_FileList, 3, #False)
            
            If Archive\Mode = #Create  ;{ Create Archive
              
              If PackEx::Create(#Pack, Archive\Path + Archive\Name, Archive\Plugin)
                
                EnterKey = #False
                
                ForEach Archive\File()
                  
                  Row = ListEx::GetRowFromLabel(#Gadget_PackerEx_FileList, Archive\File()\Name)
                  
                  If Archive\File()\Flags & #Encrypt
                    
                    If Key$ = "" And EnterKey = #False
                      Key$ = EnterKeyWindow()
                      EnterKey = #True
                    EndIf
                    
                    If Key$
                      PackEx::Progress\Row = Row
                      If PackEx::AddFile(#Pack, Archive\File()\Path + Archive\File()\Name, Archive\File()\Name, Key$, #Gadget_PackerEx_FileList)
                        Archive\File()\Flags & ~#Add
                        Archive\File()\Flags & ~#Encrypt
                        Archive\File()\Flags | #Packed
                        ListEx::RemoveItemState(#Gadget_PackerEx_FileList, Row, ListEx::#Selected)
                        ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $701919, 0)
                        ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 15, 15, #IMG_Valid, ListEx::#Center)
                        Archive\File()\Encrypted = #True
                        Count + 1
                      EndIf
                    EndIf
                    
                  Else
                    
                    If PackEx::AddFile(#Pack, Archive\File()\Path + Archive\File()\Name, Archive\File()\Name)
                      Archive\File()\Flags & ~#Add
                      Archive\File()\Flags | #Packed
                      ListEx::RemoveItemState(#Gadget_PackerEx_FileList, Row, ListEx::#Selected)
                      ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $701919, 0)
                      ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 15, 15, #IMG_Valid, ListEx::#Center)
                      Count + 1
                    EndIf
                    
                    ListEx::SetItemState(#Gadget_PackerEx_FileList, Row, 100, 3)
                    
                  EndIf

                Next

                MessageRequester(" Create Archive", "Packed: " + Str(Count) + "/" + Str(ListSize(Archive\File())) + " files", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
                
                Archive\Mode    = #Open
                Archive\Changed = #False
                
                PackEx::Close(#Pack)
              EndIf
              ;}
            Else                       ;{ ReBuild Archive
              
              If PackEx::Open(#Pack, Archive\Path + Archive\Name, Archive\Plugin)
                
                EnterKey = #False
                
                ForEach Archive\File()
                  
                  Row = ListEx::GetRowFromLabel(#Gadget_PackerEx_FileList, Archive\File()\Name)
                  
                  If Archive\File()\Flags & #Remove
                    
                    If PackEx::RemoveFile(#Pack, Archive\File()\Name)
                      DeleteMapElement(Archive\Idx(), Archive\File()\Name)
                      DeleteElement(Archive\File())
                    EndIf
                    
                  ElseIf Archive\File()\Flags & #Add Or Archive\File()\Flags & #Replace
                    
                    If Archive\File()\Flags & #Encrypt
                      
                      If Key$ = "" And EnterKey = #False
                        Key$ = EnterKeyWindow()
                        EnterKey = #True
                      EndIf
                      
                      If Key$
                        PackEx::Progress\Row = Row
                        If PackEx::AddFile(#Pack, Archive\File()\Path + Archive\File()\Name, Archive\File()\Name, Key$, #Gadget_PackerEx_FileList)
                          Archive\File()\Flags & ~#Add
                          Archive\File()\Flags & ~#Replace
                          ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $701919, 0)
                          ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 15, 15, #IMG_Valid, ListEx::#Center)
                          Count + 1
                        EndIf
                      EndIf
                      
                    Else
                      
                      If PackEx::AddFile(#Pack, Archive\File()\Path + Archive\File()\Name, Archive\File()\Name)
                        ListEx::SetItemColor(#Gadget_PackerEx_FileList, Row, ListEx::#FrontColor, $701919, 0)
                        ListEx::SetItemImage(#Gadget_PackerEx_FileList, Row, 1, 15, 15, #IMG_Valid, ListEx::#Center)
                        Archive\File()\Flags & ~#Add
                        Archive\File()\Flags & ~#Replace
                        Count + 1
                      EndIf
                      
                      ListEx::SetItemState(#Gadget_PackerEx_FileList, Row, 100, 3)
                      
                    EndIf 

                  EndIf
                
                Next

                MessageRequester(" Save Archive", "Packed: " + Str(Count) + "/" + Str(ListSize(Archive\File())) + " files", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
                
                Archive\Changed = #False
                
                PackEx::Close(#Pack) 
              EndIf
              ;}
            EndIf 
            
            If GetExtensionPart(Archive\Name) = "res"
              CreateResourceFile(Archive\Path + "Resource.pbi", Archive\Name)
            EndIf 
            
            ListEx::HideColumn(#Gadget_PackerEx_FileList, 2, #False)
            ListEx::HideColumn(#Gadget_PackerEx_FileList, 3, #True)
            
            SetGadgetColor(#Gadget_PackerEx_SG_Archive, #PB_Gadget_FrontColor, $8B0000)
           
            DisableGadget(#Gadget_PackerEx_Bt_Create,     #True)
            DisableGadget(#Gadget_PackerEx_Bt_Extract,    #False)
            
            UpdateFileList()
            ;}
          Case #Gadget_PackerEx_Bt_Extract       ;{ Extract files from archive
            
            Rows = ListEx::CountItems(#Gadget_PackerEx_FileList)
            If Rows
              
              Count = 0
              Key$  = ""
              
              PackEx::Progress\Compress = "Uncompressing"
              PackEx::Progress\Label    = "progress"

              If PackEx::Open(#Pack, Archive\Path + Archive\Name, Archive\Plugin)
                
                PackEx::ReadContent(#Pack)
                
                CountAll = ListEx::CountItems(#Gadget_PackerEx_FileList, ListEx::#Selected)
                If CountAll  ;{ MultiSelect
                  
                  Path$ = PathRequester(" Enter TargetPath", AppReg::GetValue(#HKey, "Path", "Target", Archive\Path))
                  If Path$
                    
                    ListEx::HideColumn(#Gadget_PackerEx_FileList, 2, #True)
                    ListEx::HideColumn(#Gadget_PackerEx_FileList, 3, #False)

                    AppReg::SetValue(#HKey, "Path", "Target", Path$)
                    
                    EnterKey = #False
                    
                    For r = 0 To Rows
                      
                      If ListEx::GetItemState(#Gadget_PackerEx_FileList, r) & ListEx::#Selected
                        
                        FileName$ = ListEx::GetRowLabel(#Gadget_PackerEx_FileList, r)
                        If FindMapElement(PackEx::Content(), FileName$)
                          
                          If PackEx::Content()\Encrypted
                            If Key$ = "" And EnterKey = #False
                              Key$ = EnterKeyWindow()
                              EnterKey = #True
                            EndIf
                            
                            If Key$
                              PackEx::Progress\Row = r
                              If PackEx::DecompressFile(#Pack, Path$ + FileName$, FileName$, Key$, #Gadget_PackerEx_FileList) : Count + 1 : EndIf
                            EndIf 
                            
                          Else
                            
                            If PackEx::DecompressFile(#Pack, Path$ + FileName$, FileName$) : Count + 1 : EndIf
                            
                            ListEx::SetItemState(#Gadget_PackerEx_FileList, r, 100, 3)
                            
                          EndIf
                          
                          ListEx::RemoveItemState(#Gadget_PackerEx_FileList, r, ListEx::#Selected)
                          
                        EndIf
                        
                      EndIf
                      
                    Next
                    
                  EndIf
                  ;}
                Else         ;{ FocusRow
                  
                  Path$ = PathRequester(" Enter TargetPath", AppReg::GetValue(#HKey, "Path", "Target", Archive\Path))
                  If Path$
                    
                    ListEx::HideColumn(#Gadget_PackerEx_FileList, 2, #True)
                    ListEx::HideColumn(#Gadget_PackerEx_FileList, 3, #False)
                   
                    AppReg::SetValue(#HKey, "Path", "Target", Path$)
                    
                    Row = ListEx::GetState(#Gadget_PackerEx_FileList)
                    If Row >= 0
                      
                      CountAll  = 1
                      
                      FileName$ = ListEx::GetRowLabel(#Gadget_PackerEx_FileList, Row)
                      If FindMapElement(PackEx::Content(), FileName$)
                        
                        If PackEx::Content()\Encrypted
                          
                          If Key$ = "" : Key$ = EnterKeyWindow() : EndIf
                          
                          If Key$
                            If PackEx::DecompressFile(#Pack, Path$ + FileName$, FileName$, Key$, #Gadget_PackerEx_FileList) : Count + 1 : EndIf
                          EndIf 
                        
                        Else
                          
                          If PackEx::DecompressFile(#Pack, Path$ + FileName$, FileName$) : Count + 1 : EndIf
                          
                        EndIf 
                        
                      EndIf
                      
                      ListEx::RemoveItemState(#Gadget_PackerEx_FileList, Row, ListEx::#Selected)
                      
                    Else
                      MessageRequester(" Extract Files", "No files have been selected.", #PB_MessageRequester_Ok|#PB_MessageRequester_Warning)
                    EndIf
                    
                  EndIf
                  ;}
                EndIf                
                
                MessageRequester(" Extract Archive", "Extracted: " + Str(Count) + "/" + Str(CountAll) + " files", #PB_MessageRequester_Info|#PB_MessageRequester_Ok)
                
                ListEx::HideColumn(#Gadget_PackerEx_FileList, 2, #False)
                ListEx::HideColumn(#Gadget_PackerEx_FileList, 3, #True)
                
                PackEx::Close(#Pack)
              EndIf
              
            EndIf ;}
        EndSelect
      Case ModuleEx::#Event_Gadget               ;{ Module Events
        Select EventGadget()
          Case #Gadget_PackerEx_FileList         ;{ File list
            Select EventType()
              Case #PB_EventType_LeftDoubleClick ;{ LeftDoubleClick
                Row = EventData()
                If Row >= 0
                  Idx = ListEx::GetItemData(#Gadget_PackerEx_FileList, Row)
                  If SelectElement(Archive\File(), Row)
                    If PreviewAsWindow(Key$, @Preview)
                      PreviewWindow(Preview\Type, Preview\ID, Preview\String)
                    EndIf   
                  EndIf
                EndIf ;}
              Case #PB_EventType_RightClick      ;{ RightClick
                ;}
            EndSelect ;}
          Case #Gadget_PackerEx_Bt_NewArchive    ;{ Create new archive
            Select EventType()
              Case ButtonEx::#EventType_Button
                PackFile$ = NewArchive_(AppReg::GetInteger(#HKey, "Archive", "Pattern", 0))
            EndSelect    
            ;}
        EndSelect ;}
      Case #PB_Event_GadgetDrop                  ;{ Drag & Drop
        Select EventGadget()
          Case #Gadget_PackerEx_FileList   ;{ Add files
            Files$ = EventDropFiles()
            If Files$
              Count = CountString(Files$, #LF$) + 1
              If Count = 1 And IsArchive(Files$)
                If GetGadgetText(#Gadget_PackerEx_SG_Archive) = ""
                  AppReg::SetValue(#HKey, "Archive", "Path", GetPathPart(Files$))
                  OpenPackFile_(Files$) 
                EndIf  
              Else
                AppReg::SetValue(#HKey, "Files", "Path", GetPathPart(StringField(Files$, 1, #LF$)))
                For i = 1 To Count
                  File$ = StringField(Files$, i, #LF$)
                  If AddElement(Archive\File())
                    Archive\File()\Name = GetFilePart(File$)
                    Archive\File()\Path = GetPathPart(File$)
                    Archive\File()\Size = FileSize(File$)
                    If FindMapElement(Archive\Idx(), Archive\File()\Name)
                      Archive\File()\Flags = #Replace
                    Else
                      Archive\File()\Flags = #Add
                      Archive\Idx(Archive\File()\Name) = ListIndex(Archive\File())
                    EndIf
                    Archive\Changed = #True
                  EndIf
                Next
                
                SetGadgetColor(#Gadget_PackerEx_SG_Archive, #PB_Gadget_FrontColor, $3C14DC)
                
                DisableGadget(#Gadget_PackerEx_Bt_Create,    #False)
                DisableGadget(#Gadget_PackerEx_Bt_CryptFile, #False)
                DisableGadget(#Gadget_PackerEx_Bt_Extract,   #True)
                
                UpdateFileList()
              EndIf
            EndIf ;}
          Case #Gadget_PackerEx_SG_Archive ;{ Add Archive
            PackFile$ = StringField(EventDropFiles(), 1, #LF$)
            If PackFile$
              AppReg::SetValue(#HKey, "Archive", "Path", GetPathPart(PackFile$))
              OpenPackFile_(PackFile$)
            EndIf  ;}
        EndSelect ;}
      Case #PB_Event_Menu                        ;{ PopupMenu
        Select EventMenu()
          Case #PopupMenu_SelectAll              ;{ Select all/none 
            ListEx::SelectItems(#Gadget_PackerEx_FileList, ListEx::#All)
          Case #PopupMenu_SelectNone  
            ListEx::SelectItems(#Gadget_PackerEx_FileList, ListEx::#None)
            ;}
          Case #PopupMenu_RemoveFile             ;{ Remove file
            Row = ListEx::GetState(#Gadget_PackerEx_FileList)
            If Row >= 0
              FileName$ = ListEx::GetRowLabel(#Gadget_PackerEx_FileList, Row)
              RemoveFile_(FileName$)
              UpdateFileList()
            EndIf
            ;}
          Case #DropDown_ZIP
            PackFile$ = NewArchive_(#ZIP)
          Case #DropDown_LZMA
            PackFile$ = NewArchive_(#LZMA)
          Case #DropDown_TAR 
            PackFile$ = NewArchive_(#TAR)
          Case #DropDown_RES    
            PackFile$ = NewArchive_(#RES)
        EndSelect ;}
    EndSelect
  Until quitWindow
  
  Window::StoreSize(#Window_PackerEx)
  
  CloseWindow(#Window_PackerEx)
EndIf

AppReg::Close(#HKey)
Window::Save("qAES-Packer.win")

End

; IDE Options = PureBasic 5.71 LTS (Windows - x86)
; CursorPosition = 1521
; FirstLine = 481
; Folding = YAAwjA9PeIMXWj
; EnableXP
; DPIAware
; UseIcon = qAES-Packer.ico
; Executable = ..\qAES-Packer.exe