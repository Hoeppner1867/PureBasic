;/ =========================
;/ =    SmartCrypter.pb    =
;/ =========================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/ 
;/ © 2019 Thorsten1867 (08/2019)
;/

; Last Update: 17.08.2019
;
; Bugfix:   Clear list
:
; Bugfixes: Remove File(s)
; Added:    Popupmenu (e.g. Copy Hash)
; Added:    Check the integrity of the file
; Added:    Check if files were encrypted
; Added:    Multilingual support (German/English/French)

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

XIncludeFile "qAES_Module.pbi"
XIncludeFile "AppRegistryModule.pbi"
XIncludeFile "ResourcesModule.pbi"
XIncludeFile "ResizeExModule.pbi"
XIncludeFile "ListExModule.pbi"
XIncludeFile "ProgressBarExModule.pbi"

UsePNGImageDecoder()

;- ====================================
;-  Constants
;- ====================================

#Resource = 1
#HKey = 1

;{ ___ Images ___
Enumeration 1
  #IMG_Add
  #IMG_OK
  #IMG_Remove
  #IMG_Check
  #IMG_Validate
  #IMG_Encrypted
  #IMG_Decrypted
  #IMG_Valid
  #IMG_Broken
  #IMG_Key
EndEnumeration ;}

;{ ___ Windows ___
Enumeration 1
  #Window_Crypter
  #Window_Language
  #Window_Key
EndEnumeration ;}

#PopupMenu = 1

;{ ___ Gadgets ___
Enumeration 1
  #Return
  ; --- #PopupMenu ---
  #PopupMenu_Clear
  #PopupMenu_Reset
  #PopupMenu_Hash
  ; --- #Window_Language ---
  #Gadget_Language_ComboBox
  #Gadget_Language_OK
  ; --- #Window_Crypter ---
  #Gadget_Crypter_O_Protect
  #Gadget_Crypter_Sp_Protect
  #Gadget_Crypter_O_FakeLength
  #Gadget_Crypter_O_Extension
  #Gadget_Crypter_SG_Extension
  #Gadget_Crypter_LI_Files
  #Gadget_Crypter_Bt_Encrypt
  #Gadget_Crypter_Bt_Decrypt
  #Gadget_Crypter_Bt_Check
  #Gadget_Crypter_Bt_Validate
  #Gadget_Crypter_Bt_Add
  #Gadget_Crypter_Bt_Remove
  ; --- #Window_Key ---
  #Gadget_Key_SG_Key
  #Gadget_Key_SG_checkKey
  #Gadget_Key_OK
  #Gadget_Key_O_SecureKey
  #Gadget_Key_SG_SecureKey
  #Gadget_Key_ProgressBar
EndEnumeration ;}

;{ ___ Fonts ___
Enumeration 1
  #Font_Arial8
  #Font_Arial9B
  #Font_Arial10B
EndEnumeration
;}

;- ====================================
;-  Windows
;- ====================================

Global NewMap Msg.s()

LoadFont(#Font_Arial10B, "Arial", 10, 256)
LoadFont(#Font_Arial9B,  "Arial",  9, 256)
LoadFont(#Font_Arial8,   "Arial",  8,   0)

Procedure.i Window_Language()
  If OpenWindow(#Window_Language, 0, 0,170,45, "Select Language", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_Invisible)
      ComboBoxGadget(#Gadget_Language_ComboBox, 10, 10, 120, 24)
        SetGadgetFont(#Gadget_Language_ComboBox, FontID(#Font_Arial10B))
      ButtonImageGadget(#Gadget_Language_OK, 136, 10, 24, 24, ImageID(#IMG_OK))
      HideWindow(#Window_Language, #False)
    ProcedureReturn WindowID(#Window_Language)
  EndIf
EndProcedure

Procedure.i Window_Crypter()
  Define.i Width, Offset
  
  If OpenWindow(#Window_Crypter, 0, 0, 455, 325, "qAES - SmartCrypter", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget|#PB_Window_Invisible)
    
    If CreatePopupMenu(#PopupMenu)
      MenuItem(#PopupMenu_Hash,  "Copy hash to clipboard")
      MenuBar()
      MenuItem(#PopupMenu_Reset, "Reset file list")
      MenuItem(#PopupMenu_Clear, "Clear file list")
    EndIf
    
    CheckBoxGadget(#Gadget_Crypter_O_Protect, 10, 10, 87, 20, Msg("Protect"))
      SetGadgetFont(#Gadget_Crypter_O_Protect, FontID(#Font_Arial9B))
    
    Width = GadgetWidth(#Gadget_Crypter_O_Protect, #PB_Gadget_RequiredSize)
    ResizeGadget(#Gadget_Crypter_O_Protect, #PB_Ignore, #PB_Ignore, Width, #PB_Ignore)
    Offset = Width - 87
    
    SpinGadget(#Gadget_Crypter_Sp_Protect, 98 + Offset, 10, 36, 20, 0, 99, #PB_Spin_Numeric)
    
    CheckBoxGadget(#Gadget_Crypter_O_FakeLength, 151 + Offset, 10, 84, 20, Msg("FakeLength"))
      SetGadgetFont(#Gadget_Crypter_O_FakeLength, FontID(#Font_Arial9B))
      GadgetToolTip(#Gadget_Crypter_O_FakeLength, Msg("Tooltip_Randomize"))
    
    Width = GadgetWidth(#Gadget_Crypter_O_FakeLength, #PB_Gadget_RequiredSize)
    ResizeGadget(#Gadget_Crypter_O_FakeLength, #PB_Ignore, #PB_Ignore, Width, #PB_Ignore)
    
    CheckBoxGadget(#Gadget_Crypter_O_Extension, 307, 10, 72, 20, Msg("Extension"))
      SetGadgetFont(#Gadget_Crypter_O_Extension, FontID(#Font_Arial9B))
    
    Width = GadgetWidth(#Gadget_Crypter_O_Extension, #PB_Gadget_RequiredSize)
    Offset = Width - 72
    ResizeGadget(#Gadget_Crypter_O_Extension, 307 - Offset, #PB_Ignore, Width, #PB_Ignore)
    StringGadget(#Gadget_Crypter_SG_Extension, 380, 10, 65, 20, "")
    
    ListEx::Gadget(#Gadget_Crypter_LI_Files, 10, 35, 435, 250, " " + Msg("File"), 235, "files", ListEx::#GridLines|ListEx::#MultiSelect|ListEx::#AutoResize, #Window_Crypter)
    ListEx::DisableReDraw(#Gadget_Crypter_LI_Files, #True)
    ListEx::AddColumn(#Gadget_Crypter_LI_Files, 1, "", 24, "image")
    ListEx::AddColumn(#Gadget_Crypter_LI_Files, 2, " " + Msg("Size"), 100, "size")
    ListEx::AddColumn(#Gadget_Crypter_LI_Files, 3, " " + Msg("Progress"), 120, "progress", ListEx::#ProgressBar)
    ListEx::SetProgressBarFlags(#Gadget_Crypter_LI_Files, ListEx::#ShowPercent)
    ListEx::SetColorTheme(#Gadget_Crypter_LI_Files, ListEx::#Theme_Blue)
    ListEx::SetFont(#Gadget_Crypter_LI_Files, FontID(#Font_Arial9B), ListEx::#HeaderFont)
    ListEx::SetHeaderAttribute(#Gadget_Crypter_LI_Files, ListEx::#Align, ListEx::#Center, 2)
    ListEx::SetHeaderAttribute(#Gadget_Crypter_LI_Files, ListEx::#Align, ListEx::#Center, 3)
    ListEx::SetColumnAttribute(#Gadget_Crypter_LI_Files, 2, ListEx::#Align, ListEx::#Right)
    ListEx::SetColumnAttribute(#Gadget_Crypter_LI_Files, 3, ListEx::#Align, ListEx::#Center)
    ListEx::SetColor(#Gadget_Crypter_LI_Files, ListEx::#FrontColor,       $701919, 3)
    ListEx::SetColor(#Gadget_Crypter_LI_Files, ListEx::#ProgressBarColor, $AD7D43, 3)
    ListEx::SetColor(#Gadget_Crypter_LI_Files, ListEx::#GradientColor,    $D3B691, 3)
    ListEx::SetAutoResizeColumn(#Gadget_Crypter_LI_Files, 0, 100)
    ListEx::AttachPopupMenu(#Gadget_Crypter_LI_Files, #PopupMenu)
    ListEx::DisableReDraw(#Gadget_Crypter_LI_Files, #False)
    
    ButtonGadget(#Gadget_Crypter_Bt_Encrypt, 10, 290, 70, 25, Msg("Encrypt"))
      SetGadgetFont(#Gadget_Crypter_Bt_Encrypt, FontID(#Font_Arial10B))
    ButtonGadget(#Gadget_Crypter_Bt_Decrypt, 90, 290, 70, 25, Msg("Decrypt"))
      SetGadgetFont(#Gadget_Crypter_Bt_Decrypt, FontID(#Font_Arial10B))
    
    Width = GadgetWidth(#Gadget_Crypter_Bt_Encrypt, #PB_Gadget_RequiredSize)
    If Width < GadgetWidth(#Gadget_Crypter_Bt_Decrypt, #PB_Gadget_RequiredSize)
      Width = GadgetWidth(#Gadget_Crypter_Bt_Decrypt, #PB_Gadget_RequiredSize)
    EndIf
    
    ResizeGadget(#Gadget_Crypter_Bt_Encrypt, #PB_Ignore, #PB_Ignore, Width, #PB_Ignore)
    Offset = Width - 70
    ResizeGadget(#Gadget_Crypter_Bt_Decrypt, 90 + Offset, #PB_Ignore, Width, #PB_Ignore)
    Offset + Offset
    
    ButtonImageGadget(#Gadget_Crypter_Bt_Check, 180 + Offset, 290, 24, 24, ImageID(#IMG_Check))
      GadgetToolTip(#Gadget_Crypter_Bt_Check, Msg("Tooltip_Encrypted"))
    ButtonImageGadget(#Gadget_Crypter_Bt_Validate, 214 + Offset, 290, 24, 24, ImageID(#IMG_Validate))
      GadgetToolTip(#Gadget_Crypter_Bt_Validate, Msg("Tooltip_Integrity"))
    
    ButtonImageGadget(#Gadget_Crypter_Bt_Add,    391, 290, 25, 25, ImageID(#IMG_Add))
      GadgetToolTip(#Gadget_Crypter_Bt_Add, Msg("Tooltip_Add"))
    ButtonImageGadget(#Gadget_Crypter_Bt_Remove, 420, 290, 25, 25, ImageID(#IMG_Remove))
      GadgetToolTip(#Gadget_Crypter_Bt_Remove, Msg("Tooltip_Remove"))

    EnableGadgetDrop(#Gadget_Crypter_LI_Files, #PB_Drop_Files, #PB_Drag_Copy)
    
    DisableGadget(#Gadget_Crypter_SG_Extension, #True)
    DisableGadget(#Gadget_Crypter_Sp_Protect, #True)
    
    If Resize::AddWindow(#Window_Crypter, 440, 325)
      Resize::AddGadget(#Gadget_Crypter_O_FakeLength, Resize::#MoveX)
      Resize::AddGadget(#Gadget_Crypter_O_Extension,  Resize::#MoveX)
      Resize::AddGadget(#Gadget_Crypter_SG_Extension, Resize::#MoveX)
      Resize::AddGadget(#Gadget_Crypter_Bt_Encrypt,  Resize::#MoveY)
      Resize::AddGadget(#Gadget_Crypter_Bt_Decrypt,  Resize::#MoveY)
      Resize::AddGadget(#Gadget_Crypter_Bt_Check,  Resize::#MoveY)
      Resize::AddGadget(#Gadget_Crypter_Bt_Validate,  Resize::#MoveY)
      Resize::AddGadget(#Gadget_Crypter_Bt_Add,      Resize::#MoveX|Resize::#MoveY)
      Resize::AddGadget(#Gadget_Crypter_Bt_Remove,   Resize::#MoveX|Resize::#MoveY)
    EndIf
    
    HideWindow(#Window_Crypter, #False)
   
    ProcedureReturn WindowID(#Window_Crypter)
  EndIf
  
EndProcedure

Procedure.i Window_Key(Encrypt.i)
  Define.i OffsetY, OffsetX
  
  If Encrypt : OffsetY = 27 : EndIf
  
  If OpenWindow(#Window_Key, 0, 0, 265, 70 + OffsetY, " " + Msg("EnterKey"), #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible)
    
    If Encrypt
      StringGadget(#Gadget_Key_SG_checkKey, 10, 11, 216, 22, "", #PB_String_Password)
    EndIf
    
    StringGadget(#Gadget_Key_SG_Key, 10, 11 + OffsetY, 216, 22, "", #PB_String_Password)
    ButtonImageGadget(#Gadget_Key_OK, 231, 10 + OffsetY, 24, 24, ImageID(#IMG_OK))
    
    CheckBoxGadget(#Gadget_Key_O_SecureKey, 10, 40 + OffsetY, 84, 20, Msg("SecureKey"))
      SetGadgetFont(#Gadget_Key_O_SecureKey, FontID(#Font_Arial9B))
    
    Width = GadgetWidth(#Gadget_Key_O_SecureKey, #PB_Gadget_RequiredSize)
    ResizeGadget(#Gadget_Key_O_SecureKey, #PB_Ignore, #PB_Ignore, Width, #PB_Ignore)
    OffsetX = Width - 84
    
    StringGadget(#Gadget_Key_SG_SecureKey, 95 + OffsetX, 40 + OffsetY, 50, 20, "", #PB_String_Numeric)

    ProgressEx::Gadget(#Gadget_Key_ProgressBar, 150 + OffsetX, 40 + OffsetY, 105 - OffsetX, 20, 0, 100, ProgressEx::#Border|ProgressEx::#ShowPercent, #Window_Key)
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

;- ====================================
;-  Structures
;- ====================================

Structure File_Structure ;{ File()\...
  Name.s
  Path.s
  Hash.s
  Size.q
EndStructure ;}
Global NewList File.File_Structure()

Global enterKey$

;- ====================================
;-  Procedures
;- ====================================

Procedure   Language(Language.s="")
  
  Select Language
    Case "Deutsch"  
      Msg("Tooltip_Randomize") = "Randomisieren der Dateigröße mittels Zufallsdaten."
      Msg("Tooltip_Integrity") = "Überprüfen der Integrität der Dateien."
      Msg("Tooltip_Encrypted") = "Überprüfen, ob Dateien verschlüsselt wurden."
      Msg("Tooltip_Add")       = "Dateien zur Liste hinzufügen."
      Msg("Tooltip_Remove")    = "Dateien aus der Liste löschen."
      Msg("Encrypt")    = "Verschlüsseln"
      Msg("Decrypt")    = "Entschlüsseln"
      Msg("File")       = "Datei"
      Msg("Size")       = "Größe"
      Msg("Progress")   = "Fortschritt"
      Msg("Protect")    = "nur Schutz"
      Msg("Extension")  = "Erweiterung"
      Msg("FakeLength") = "Fake-Länge"
      Msg("EnterKey")   = "Geben Sie den Schlüssel ein"
      Msg("SecureKey")  = "Sicherer Schlüssel"
      Msg("KeysMatch")  = "Die eingegebenen Schlüssel stimmen nicht überein."
    Case "Français"
      Msg("Tooltip_Randomize") = "Randomiser la taille du fichier en utilisant des données aléatoires."
      Msg("Tooltip_Integrity") = "Vérifier l'intégrité des fichiers."
      Msg("Tooltip_Encrypted") = "Vérifiez si les fichiers ont été cryptés."
      Msg("Tooltip_Add")       = "Ajouter des fichiers à la liste."
      Msg("Tooltip_Remove")    = "Supprimer des fichiers de la liste."
      Msg("Encrypt")    = "Chiffrer"
      Msg("Decrypt")    = "Décrypter"
      Msg("File")       = "Fichier"
      Msg("Size")       = "Taille"
      Msg("Progress")   = "Progrès réalisés"
      Msg("Protect")    = "Protection seule"
      Msg("Extension")  = "Extension"
      Msg("FakeLength") = "Fausse longueur"
      Msg("EnterKey")   = "Entrer la clé"
      Msg("SecureKey")  = "Clé sécurisée"
      Msg("KeysMatch")  = "Les touches saisies ne correspondent pas."
    Default
      Msg("Tooltip_Randomize") = "Randomize the file size using random data."
      Msg("Tooltip_Integrity") = "Check the integrity of the files."
      Msg("Tooltip_Encrypted") = "Check if files were encrypted."
      Msg("Tooltip_Add")       = "Add files to list."
      Msg("Tooltip_Remove")    = "Remove files from list."
      Msg("Encrypt")    = "Encrypt"
      Msg("Decrypt")    = "Decrypt"
      Msg("File")       = "File"
      Msg("Size")       = "Size"
      Msg("Progress")   = "Progress"
      Msg("Protect")    = "Protect only"
      Msg("Extension")  = "Extension"
      Msg("FakeLength") = "Fake length"
      Msg("EnterKey")   = "Enter the key"
      Msg("SecureKey")  = "Secure key"
      Msg("KeysMatch")  = "The keys entered do not match."
  EndSelect
  
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

Procedure.s EnterKeyWindow(Encrypt.i=#False)
  Define.s Key$
  Define.q Loops
  Define.i Result, quitWindow = #False
  
  If Window_Key(Encrypt)
    
    AddKeyboardShortcut(#Window_Key, #PB_Shortcut_Return, #Return)
    
    If Encrypt
      SetActiveGadget(#Gadget_Key_SG_checkKey)
    Else
      SetActiveGadget(#Gadget_Key_SG_Key)
      Result = #True
    EndIf 

    SetGadgetText(#Gadget_Key_SG_Key, enterKey$)
    SetGadgetText(#Gadget_Key_SG_SecureKey, AppReg::GetValue(#HKey, "SecureKey", "Loops", "2048"))
    
    If Encrypt : SetGadgetText(#Gadget_Key_SG_checkKey, enterKey$) : EndIf 
    
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
              enterKey$ = ""
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
              
              If Encrypt ;{ Check Key
                If GetGadgetText(#Gadget_Key_SG_Key) = GetGadgetText(#Gadget_Key_SG_checkKey)
                  Result = #True
                Else
                  MessageRequester(" " + Msg("EnterKey"), Msg("KeysMatch"), #PB_MessageRequester_Ok|#PB_MessageRequester_Warning)
                EndIf ;}
              EndIf
              
              If Result
                
                enterKey$ = GetGadgetText(#Gadget_Key_SG_Key)
                
                If GetGadgetState(#Gadget_Key_O_SecureKey)
                  HideGadget(#Gadget_Key_ProgressBar, #False)
                  Key$ = qAES::CreateSecureKey(GetGadgetText(#Gadget_Key_SG_Key), ValF(GetGadgetText(#Gadget_Key_SG_SecureKey)), #Gadget_Key_ProgressBar)
                  AppReg::SetInteger(#HKey, "SecureKey", "State", #True)
                  AppReg::SetValue(#HKey,   "SecureKey", "Loops", GetGadgetText(#Gadget_Key_SG_SecureKey))
                Else
                  Key$ = GetGadgetText(#Gadget_Key_SG_Key)
                  AppReg::SetInteger(#HKey, "SecureKey", "State", #False)
                EndIf
                
                quitWindow = #True
              EndIf ;}
          EndSelect
        Case #PB_Event_Menu
          Select EventMenu()
            Case #Return  ;{ Apply
              
              If Encrypt ;{ Check Key
                If GetGadgetText(#Gadget_Key_SG_Key) = GetGadgetText(#Gadget_Key_SG_checkKey)
                  Result = #True
                Else
                  MessageRequester(" " + Msg("EnterKey"), Msg("KeysMatch"), #PB_MessageRequester_Ok|#PB_MessageRequester_Warning)
                EndIf ;}
              EndIf
              
              If Result
                
                enterKey$ = GetGadgetText(#Gadget_Key_SG_Key)
                
                If GetGadgetState(#Gadget_Key_O_SecureKey)
                  HideGadget(#Gadget_Key_ProgressBar, #False)
                  Key$ = qAES::CreateSecureKey(GetGadgetText(#Gadget_Key_SG_Key), ValF(GetGadgetText(#Gadget_Key_SG_SecureKey)), #Gadget_Key_ProgressBar)
                  AppReg::SetInteger(#HKey, "SecureKey", "State", #True)
                  AppReg::SetValue(#HKey,   "SecureKey", "Loops", GetGadgetText(#Gadget_Key_SG_SecureKey))
                Else
                  Key$ = GetGadgetText(#Gadget_Key_SG_Key)
                  AppReg::SetInteger(#HKey, "SecureKey", "State", #False)
                EndIf
                
                quitWindow = #True
              EndIf ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_Key)
  EndIf
  
  ProcedureReturn Key$
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

Procedure   UpdateFileList()
  
  ListEx::DisableReDraw(#Gadget_Crypter_LI_Files, #True)
  ListEx::ClearItems(#Gadget_Crypter_LI_Files)
  ForEach File()
    Row = ListEx::AddItem(#Gadget_Crypter_LI_Files, ListEx::#LastItem, File()\Name + #LF$ + #LF$ + FormatBytes(File()\Size))
    ListEx::SetItemData(#Gadget_Crypter_LI_Files, Row, ListIndex(File()))
  Next
  ListEx::SetItemImage(#Gadget_Crypter_LI_Files, ListEx::#Header, 1, 16, 16, #False, ListEx::#Center)
  ListEx::DisableReDraw(#Gadget_Crypter_LI_Files, #False)
  
EndProcedure

Procedure UpdateProgressBar()
  
  Select qAES::Progress\Flag
    Case qAES::#SecureKey
      ProgressEx::SetState(qAES::Progress\Gadget, qAES::Progress\State)
    Case qAES::#SmartFileCoder
      ListEx::SetCellState(qAES::Progress\Gadget, qAES::Progress\Row, qAES::Progress\Label, qAES::Progress\State)
  EndSelect
  
EndProcedure
qAES::ProgressProcedure(@UpdateProgressBar())

;- ====================================
;-  Main Loop
;- ====================================

Define.s File$, Files$, Filename$, Extension$, Key$
Define.i Idx, i, Flags, Counter, Row, Progress
Define.i quitWindow = #False

;{ ___ Load images ___
If Resource::Open(#Resource, "SmartCrypter.res")
  Resource::GetImage(#Resource, #IMG_Add,       "ADD.png")
  Resource::GetImage(#Resource, #IMG_OK,        "OK.png")
  Resource::GetImage(#Resource, #IMG_Remove,    "DEL.png")
  Resource::GetImage(#Resource, #IMG_Check,     "Check.png")
  Resource::GetImage(#Resource, #IMG_Validate,  "Validate.png")
  Resource::GetImage(#Resource, #IMG_Encrypted, "Encrypted.png")
  Resource::GetImage(#Resource, #IMG_Decrypted, "Decrypted.png")
  Resource::GetImage(#Resource, #IMG_Valid,     "Valid.png")
  Resource::GetImage(#Resource, #IMG_Broken,    "Broken.png")
  Resource::GetImage(#Resource, #IMG_Key,       "Key.png")
  Resource::Close(#Resource)
EndIf ;}

AppReg::Open(#HKey, "SmartCrypter.reg", "SmartCrypter", "Thorsten Hoeppner")

Language$ = AppReg::GetValue(#HKey, "Internal", "Language", "")
If Language$ = "" : Language$ = SelectLanguage() : EndIf

Language(Language$)

If Window_Crypter()

  ListEx::HideColumn(#Gadget_Crypter_LI_Files, 1, #True)
  ListEx::HideColumn(#Gadget_Crypter_LI_Files, 3, #True)
  
  SetGadgetState(#Gadget_Crypter_Sp_Protect, AppReg::GetInteger(#HKey, "Protect", "Counter", 18))
  
  If AppReg::GetInteger(#HKey, "Protect", "State", #False)
    SetGadgetState(#Gadget_Crypter_O_Protect, #True)
    DisableGadget(#Gadget_Crypter_Sp_Protect, #False)
    SetGadgetText(#Gadget_Crypter_SG_Extension, AppReg::GetValue(#HKey, "Extension", "Text", " [protected]"))
  Else
    SetGadgetText(#Gadget_Crypter_SG_Extension, AppReg::GetValue(#HKey, "Extension", "Text", " [encrypted]"))
  EndIf
  
  If AppReg::GetInteger(#HKey, "FakeLength", "State", #False)
    SetGadgetState(#Gadget_Crypter_O_FakeLength, #True)
  EndIf
  
  If AppReg::GetInteger(#HKey, "Extension", "State", #False)
    SetGadgetState(#Gadget_Crypter_O_Extension, #True)
    DisableGadget(#Gadget_Crypter_SG_Extension, #False)
  EndIf
  
  qAES::Progress\Label = "progress"
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow           ;{ Close Window
        Select EventWindow()
          Case #Window_Crypter
            quitWindow = #True
        EndSelect ;}
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gadget_Crypter_O_Protect   ;{ Protect only
            If GetGadgetState(#Gadget_Crypter_O_Protect)
              DisableGadget(#Gadget_Crypter_Sp_Protect, #False)
              If GetGadgetState(#Gadget_Crypter_O_Extension)
                SetGadgetText(#Gadget_Crypter_SG_Extension, AppReg::GetValue(#HKey, "Extension", "Protected", " [protected]"))
              EndIf  
            Else
              DisableGadget(#Gadget_Crypter_Sp_Protect, #True)
              If GetGadgetState(#Gadget_Crypter_O_Extension)
                SetGadgetText(#Gadget_Crypter_SG_Extension, AppReg::GetValue(#HKey, "Extension", "Encrypted", " [encrypted]"))
              EndIf 
            EndIf
            ;}
          Case #Gadget_Crypter_O_Extension ;{ Extension
            If GetGadgetState(#Gadget_Crypter_O_Extension)
              DisableGadget(#Gadget_Crypter_SG_Extension, #False)
              If GetGadgetState(#Gadget_Crypter_O_Protect)
                SetGadgetText(#Gadget_Crypter_SG_Extension, AppReg::GetValue(#HKey, "Extension", "Protected", " [protected]"))
              Else
                SetGadgetText(#Gadget_Crypter_SG_Extension, AppReg::GetValue(#HKey, "Extension", "Encrypted", " [encrypted]"))
              EndIf
            Else
              DisableGadget(#Gadget_Crypter_SG_Extension, #True)
            EndIf ;}
          Case #Gadget_Crypter_LI_Files    ;{ File List
            Select EventType()
              Case #PB_EventType_LeftDoubleClick
              Case #PB_EventType_RightDoubleClick
              Case #PB_EventType_RightClick
              Default
            EndSelect ;}
          Case #Gadget_Crypter_Bt_Encrypt  ;{ Encrypt Files

            Count = ListEx::CountItems(#Gadget_Crypter_LI_Files)
            If Count
              
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 1, #True)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 2, #True)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 3, #False)
              
              UpdateFileList()
              
              Key$ = EnterKeyWindow(#True)
              If Key$
                
                If GetGadgetState(#Gadget_Crypter_O_Extension)  ;{ Extension
                  Extension$ = GetGadgetText(#Gadget_Crypter_SG_Extension)
                Else  
                  Extension$ = "" ;}
                EndIf
    
                If GetGadgetState(#Gadget_Crypter_O_FakeLength) ;{ Fake Length
                  Flags = qAES::#EnlargeSize|qAES::#RandomizeSize
                Else
                  Flags = #False ;}
                EndIf 

                If GetGadgetState(#Gadget_Crypter_O_Protect) ;{ Protect
                  Counter = GetGadgetState(#Gadget_Crypter_Sp_Protect)
                  For i=0 To Count - 1
                    Idx = ListEx::GetItemData(#Gadget_Crypter_LI_Files, i) 
                    If Idx >= 0 And SelectElement(File(), Idx)
                      qAES::Progress\Row = i
                      qAES::SmartFileCoder(qAES::#Protect, File()\Path + File()\Name, Key$, Extension$, Flags, Counter, #Gadget_Crypter_LI_Files)
                      File()\Hash = qAES::GetHash()
                      If GetGadgetState(#Gadget_Crypter_O_Extension) And CountString(File()\Name, Extension$) = 0
                        File$ = GetFilePart(File()\Name, #PB_FileSystem_NoExtension) + Extension$ + "." + GetExtensionPart(File()\Name)
                        ListEx::SetCellText(#Gadget_Crypter_LI_Files, i, "files", File$)
                        File()\Name = File$
                      EndIf
                    EndIf
                  Next
                  AppReg::SetValue(#HKey, "Extension", "Protected", GetGadgetText(#Gadget_Crypter_SG_Extension))
                  ;}
                Else                                         ;{ Encrypt
                  For i=0 To Count - 1
                    Idx = ListEx::GetItemData(#Gadget_Crypter_LI_Files, i)
                    If Idx >= 0 And SelectElement(File(), ListEx::GetItemData(#Gadget_Crypter_LI_Files, i)) 
                      qAES::Progress\Row = i
                      qAES::SmartFileCoder(qAES::#Encrypt, File()\Path + File()\Name, Key$, Extension$, Flags, #False, #Gadget_Crypter_LI_Files)
                      File()\Hash = qAES::GetHash()
                      If GetGadgetState(#Gadget_Crypter_O_Extension) And CountString(File()\Name, Extension$) = 0
                        File$ = GetFilePart(File()\Name, #PB_FileSystem_NoExtension) + Extension$ + "." + GetExtensionPart(File()\Name)
                        ListEx::SetCellText(#Gadget_Crypter_LI_Files, i, "files", File$)
                        File()\Name = File$
                      EndIf
                    EndIf  
                  Next
                  AppReg::SetValue(#HKey, "Extension", "Encrypted", GetGadgetText(#Gadget_Crypter_SG_Extension))
                  ;}
                EndIf 
                
              EndIf
              
            EndIf
            ;}
          Case #Gadget_Crypter_Bt_Decrypt  ;{ Decrypt Files

            Count = ListEx::CountItems(#Gadget_Crypter_LI_Files)
            If Count
              
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 1, #False)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 2, #True)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 3, #False)
              
              UpdateFileList()
              
              Key$ = EnterKeyWindow()
              If Key$
                
                ListEx::SetItemImage(#Gadget_Crypter_LI_Files, ListEx::#Header, 1, 16, 16, #IMG_Validate, ListEx::#Center)
                
                If GetGadgetState(#Gadget_Crypter_O_Extension)  ;{ Extension
                  Extension$ = GetGadgetText(#Gadget_Crypter_SG_Extension)
                Else  
                  Extension$ = "" ;}
                EndIf

                If GetGadgetState(#Gadget_Crypter_O_Protect) ;{ Unprotect
                  Counter = GetGadgetState(#Gadget_Crypter_Sp_Protect)
                  For i=0  To Count - 1
                    Idx = ListEx::GetItemData(#Gadget_Crypter_LI_Files, i) 
                    If Idx >= 0 And SelectElement(File(), Idx)
                      qAES::Progress\Row = i
                      If qAES::SmartFileCoder(qAES::#Unprotect, File()\Path + File()\Name, Key$, Extension$, Flags, Counter, #Gadget_Crypter_LI_Files)
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Valid, ListEx::#Center)
                      Else
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Broken, ListEx::#Center)
                      EndIf 
                      If GetGadgetState(#Gadget_Crypter_O_Extension)
                        File$ = RemoveString(File()\Name, Extension$)
                        ListEx::SetCellText(#Gadget_Crypter_LI_Files, i, "files", File$)
                        File()\Name = File$
                      EndIf
                    EndIf
                  Next
                  AppReg::SetValue(#HKey, "Extension", "Protected", GetGadgetText(#Gadget_Crypter_SG_Extension))
                  ;}
                Else                                         ;{ Decrypt
                  For i=0 To Count - 1
                    Idx = ListEx::GetItemData(#Gadget_Crypter_LI_Files, i) 
                    If Idx >= 0 And SelectElement(File(), Idx)
                      qAES::Progress\Row = i
                      If qAES::SmartFileCoder(qAES::#Decrypt, File()\Path + File()\Name, Key$, Extension$, Flags, #False, #Gadget_Crypter_LI_Files)
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Valid, ListEx::#Center)
                      Else  
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Broken, ListEx::#Center)
                      EndIf  
                      If GetGadgetState(#Gadget_Crypter_O_Extension)
                        File$ = RemoveString(File()\Name, Extension$)
                        ListEx::SetCellText(#Gadget_Crypter_LI_Files, i, "files", File$)
                        File()\Name = File$
                      EndIf
                    EndIf
                  Next
                  AppReg::SetValue(#HKey, "Extension", "Encrypted", GetGadgetText(#Gadget_Crypter_SG_Extension))
                  ;}
                EndIf
                
              EndIf
              
            EndIf  
            ;}
          Case #Gadget_Crypter_Bt_Check    ;{ Check if files were encrypted
            
            Count = ListEx::CountItems(#Gadget_Crypter_LI_Files)
            If Count
              
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 3, #True)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 2, #False)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 1, #False)
              
              UpdateFileList()
              
              Key$ = EnterKeyWindow()
              If Key$
                
                If GetGadgetState(#Gadget_Crypter_O_Extension)  ;{ Extension
                  Extension$ = GetGadgetText(#Gadget_Crypter_SG_Extension)
                Else  
                  Extension$ = "" ;}
                EndIf

                ListEx::SetItemImage(#Gadget_Crypter_LI_Files, ListEx::#Header, 1, 15, 15, #IMG_Key, ListEx::#Center)
                
                For i=0 To Count - 1
                  Idx = ListEx::GetItemData(#Gadget_Crypter_LI_Files, i) 
                  If Idx >= 0 And SelectElement(File(), Idx)
                    qAES::Progress\Row = i
                    If GetGadgetState(#Gadget_Crypter_O_Protect)
                      If qAES::IsProtected(File()\Path + File()\Name, Key$, Extension$, GetGadgetState(#Gadget_Crypter_Sp_Protect))
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Encrypted, ListEx::#Center)
                      Else
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Decrypted, ListEx::#Center)
                      EndIf
                    Else
                      If qAES::IsEncrypted(File()\Path + File()\Name, Key$, Extension$)
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Encrypted, ListEx::#Center)
                      Else
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Decrypted, ListEx::#Center)
                      EndIf
                    EndIf 
                  EndIf
                Next
                
                AppReg::SetValue(#HKey, "Extension", "Encrypted", GetGadgetText(#Gadget_Crypter_SG_Extension))
                
              EndIf

            EndIf 
            ;}
          Case #Gadget_Crypter_Bt_Validate ;{ Check the integrity of the files
            
            Count = ListEx::CountItems(#Gadget_Crypter_LI_Files)
            If Count
              
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 2, #True)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 1, #False)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 3, #False)
              
              UpdateFileList()
              
              Key$ = EnterKeyWindow()
              If Key$
                
                If GetGadgetState(#Gadget_Crypter_O_Extension)  ;{ Extension
                  Extension$ = GetGadgetText(#Gadget_Crypter_SG_Extension)
                Else  
                  Extension$ = "" ;}
                EndIf

                ListEx::SetItemImage(#Gadget_Crypter_LI_Files, ListEx::#Header, 1, 16, 16, #IMG_Validate, ListEx::#Center)

                For i=0 To Count - 1
                  Idx = ListEx::GetItemData(#Gadget_Crypter_LI_Files, i) 
                  If Idx >= 0 And SelectElement(File(), Idx)
                    qAES::Progress\Row = i
                    If GetGadgetState(#Gadget_Crypter_O_Protect)
                      If qAES::CheckIntegrity(File()\Path + File()\Name, Key$, Extension$, GetGadgetState(#Gadget_Crypter_Sp_Protect), #Gadget_Crypter_LI_Files)
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Valid, ListEx::#Center)
                      Else
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Broken, ListEx::#Center)
                      EndIf
                    Else
                      If qAES::CheckIntegrity(File()\Path + File()\Name, Key$, Extension$, #False, #Gadget_Crypter_LI_Files)
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Valid, ListEx::#Center)
                      Else
                        ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #IMG_Broken, ListEx::#Center)
                      EndIf
                    EndIf 
                  EndIf
                Next
                
                AppReg::SetValue(#HKey, "Extension", "Encrypted", GetGadgetText(#Gadget_Crypter_SG_Extension))
                
              EndIf

            EndIf
            ;}
          Case #Gadget_Crypter_Bt_Add      ;{ Add File(s)
            Files$ = OpenFileRequester("Add File(s)", "", "(*.*)|*.*", 0, #PB_Requester_MultiSelection)
            While Files$ 
              Filename$ = GetFilePart(Files$)
              If AddElement(File())
                File()\Name = Filename$
                File()\Path = GetPathPart(Files$)
                File()\Size = FileSize(Files$)
                Row = ListEx::AddItem(#Gadget_Crypter_LI_Files, ListEx::#LastItem, Filename$ + #LF$ + #LF$ + FormatBytes(File()\Size))
                ListEx::SetItemData(#Gadget_Crypter_LI_Files, Row, ListIndex(File()))
              EndIf
              Files$ = NextSelectedFileName()
            Wend 
            UpdateFileList()
            ;}
          Case #Gadget_Crypter_Bt_Remove   ;{ Remove File(s)
            If ListEx::CountItems(#Gadget_Crypter_LI_Files, ListEx::#Selected)
              For i = ListEx::CountItems(#Gadget_Crypter_LI_Files) - 1 To 0 Step -1
                If ListEx::GetItemState(#Gadget_Crypter_LI_Files, i) & ListEx::#Selected
                  Idx = ListEx::GetItemData(#Gadget_Crypter_LI_Files, i)
                  If Idx >= 0 And SelectElement(File(), Idx)
                    DeleteElement(File())
                    ListEx::RemoveItem(#Gadget_Crypter_LI_Files, i)
                  EndIf  
                EndIf
              Next
              ListEx::SetState(#Gadget_Crypter_LI_Files)
            Else
              Row = ListEx::GetState(#Gadget_Crypter_LI_Files)
              If Row
                If SelectElement(File(), ListEx::GetItemData(#Gadget_Crypter_LI_Files, Row))
                  DeleteElement(File())
                  ListEx::RemoveItem(#Gadget_Crypter_LI_Files, Row)
                EndIf  
              EndIf 
            EndIf
            UpdateFileList() ;}
        EndSelect
      Case #PB_Event_Menu
        Select EventMenu() 
          Case #PopupMenu_Hash  ;{ Copy Hash to ClipBoard
            Idx = ListEx::GetState(#Gadget_Crypter_LI_Files)
            If Idx >= 0
              If SelectElement(File(), Idx)
                SetClipboardText(File()\Hash)
              EndIf
            EndIf ;}
          Case #PopupMenu_Reset ;{ Reset File List
            Count = ListEx::CountItems(#Gadget_Crypter_LI_Files)
            If Count
              ListEx::DisableReDraw(#Gadget_Crypter_LI_Files, #True)
              For i=0 To Count - 1
                ListEx::SetCellState(#Gadget_Crypter_LI_Files, i, "progress", 0)
                ListEx::SetItemImage(#Gadget_Crypter_LI_Files, i, 1, 16, 16, #False, ListEx::#Center)
              Next
              ListEx::SetItemImage(#Gadget_Crypter_LI_Files, ListEx::#Header, 1, 16, 16, #False, ListEx::#Center)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 2, #False)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 1, #True)
              ListEx::HideColumn(#Gadget_Crypter_LI_Files, 3, #True)
              ListEx::DisableReDraw(#Gadget_Crypter_LI_Files, #False)
            EndIf ;}
          Case #PopupMenu_Clear ;{ Clear File List
            ListEx::ClearItems(#Gadget_Crypter_LI_Files)
            ClearList(File())
            ;}
        EndSelect
      Case #PB_Event_GadgetDrop            ;{ Drag & Drop
        Select EventGadget()
          Case #Gadget_Crypter_LI_Files   
            Files$ = EventDropFiles()
            Count  = CountString(Files$, #LF$) + 1
            For i = 1 To Count
              File$ = StringField(Files$, i, #LF$)
              If FileSize(File$) < 0 : Continue : EndIf
              Filename$ = GetFilePart(File$)
              If AddElement(File())
                File()\Name = Filename$
                File()\Path = GetPathPart(File$)
                File()\Size = FileSize(File$)
                Row = ListEx::AddItem(#Gadget_Crypter_LI_Files, ListEx::#LastItem, Filename$ + #LF$ + #LF$ + FormatBytes(File()\Size))
                ListEx::SetItemData(#Gadget_Crypter_LI_Files, Row, ListIndex(File()))
              EndIf
            Next i
            UpdateFileList()
        EndSelect ;}
    EndSelect
  Until quitWindow
  
  AppReg::SetInteger(#HKey, "FakeLength", "State", GetGadgetState(#Gadget_Crypter_O_FakeLength))
  AppReg::SetInteger(#HKey, "Extension", "State",  GetGadgetState(#Gadget_Crypter_O_Extension))
  AppReg::SetInteger(#HKey, "Protect", "Counter",  GetGadgetState(#Gadget_Crypter_Sp_Protect))
  AppReg::SetInteger(#HKey, "Protect", "State",    GetGadgetState(#Gadget_Crypter_O_Protect))
  
  CloseWindow(#Window_Crypter)
EndIf

AppReg::Close(#HKey)


End

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 11
; Folding = gDAUAwQ1
; EnableXP
; DPIAware
; UseIcon = Crypt.ico
; Executable = SmartCrypter.exe