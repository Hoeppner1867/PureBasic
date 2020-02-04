;/ ==================================
;/ =    MarkDownEditor.pbi    =
;/ ==================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/  Gadget to display MarkDown languages
;/
;/ © 2020  by Thorsten Hoeppner (02/2020)
;/

; Last Update: 

;{ ===== Tea & Pizza Ware =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}

XIncludeFile "AppRegistryModule.pbi"
XIncludeFile "ResizeExModule.pbi"
XIncludeFile "ResourceExModule.pbi"
XIncludeFile "MarkDownModule.pbi"
XIncludeFile "EditorExModule.pbi"
XIncludeFile "TreeExModule.pbi"

EnableExplicit

UsePNGImageDecoder()
UseLZMAPacker()

;- __________ Constants __________

#AppReg = 1
#ResEx  = 1
#JSON   = 1
#Pack   = 1
#XML    = 1
#Dir    = 1

;{ Menu Constants
Enumeration 1
  #PopupMenu
EndEnumeration  
;}

;{ Window Constants
Enumeration 1
  #Window_MarkDown
  #Window_NewEntry
  #Window_Settings
EndEnumeration
;}

;{ Gadget Constants
Enumeration 1
  
  ;{ Menue items
  #Menu_Copy
  #Menu_Cut
  #Menu_Paste
  #Menu_H1
  #Menu_H2
  #Menu_H3
  #Menu_H4
  #Menu_H5
  #Menu_H6
  #Menu_Bold
  #Menu_Italic
  #Menu_BoldItalic
  #Menu_Strikethrough
  #Menu_Highlight
  #Menu_Code
  #Menu_SubScript
  #Menu_SuperScript
  #Menu_Keystroke
  #Menu_Footnote
  #Menu_URL
  #Menu_Link
  #Menu_LinkRef
  #Menu_Image
  #Menu_ImageRef
  #Menu_Abbreviation
  #Menu_Ref_Footnote
  #Menu_Ref_Link
  #Menu_Ref_Image  
  #Emoji_Bookmark
  #Emoji_Date
  #Emoji_Mail
  #Emoji_Memo
  #Emoji_Pencil
  #Emoji_Phone
  #Emoji_Bulb
  #Emoji_Clip
  #Emoji_Magnifier
  #Emoji_Warning
  ;}
  
  ;{ #Window_Settings
  #Gadget_Settings_Frame
  #Gadget_Settings_Tx_Language
  #Gadget_Settings_CB_Code
  #Gadget_Settings_OG_SpellCheck
  #Gadget_Settings_CB_Dictionary
  #Gadget_Settings_Bt_Apply
  ;}
  
  ;{ #Window_NewEntry
  #Gadget_NewEntry_Frame
  #Gadget_NewEntry_Tx_Title
  #Gadget_NewEntry_SG_Title
  #Gadget_NewEntry_TX_Label
  #Gadget_NewEntry_SG_Label
  #Gadget_NewEntry_Tx_Level
  #Gadget_NewEntry_SpG_Level
  #Gadget_NewEntry_Bt_OK
  ;}
  
  ;{ #Window_MarkDown  
  #Gadget_MarkDown_Tree
  #Gadget_MarkDown_Editor
  #Gadget_MarkDown_Viewer
  #Gadget_MarkDown_Add
  #Gadget_MarkDown_Edit
  #Gadget_MarkDown_Delete
  #Gadget_MarkDown_Frame
  #Gadget_MarkDown_Up
  #Gadget_MarkDown_Down
  #Gadget_MarkDown_Bt_Preview
  #Gadget_MarkDown_Bt_New
  #Gadget_MarkDown_Bt_Open
  #Gadget_MarkDown_Bt_Save
  #Gadget_MarkDown_Bt_Create
  #Gadget_MarkDown_Bt_Settings
  ;}

EndEnumeration
;}

;- __________ Fonts __________

;{ Font Constants
Enumeration 1
  #Font_Arial8
  #Font_Arial8B
  #Font_Arial9
  #Font_Arial9B
  #Font_Arial11
EndEnumeration  
;}

LoadFont(#Font_Arial8,   "Arial",  8)
LoadFont(#Font_Arial8B,  "Arial",  8, #PB_Font_Bold)
LoadFont(#Font_Arial9,   "Arial",  9)
LoadFont(#Font_Arial9B,  "Arial",  9, #PB_Font_Bold)
LoadFont(#Font_Arial11,  "Arial", 11)

;- __________ Images __________

;{ Image Constants
Enumeration 1
  #IMG_Copy
  #IMG_Cut
  #IMG_Paste
  #IMG_OK
  #IMG_Add
  #IMG_Edit
  #IMG_Delete
  #IMG_Create
  #IMG_Up
  #IMG_Down
  #IMG_New
  #IMG_Open
  #IMG_Save
  #IMG_Update
  #IMG_Settings
  #IMG_Bookmark
  #IMG_Date
  #IMG_Mail
  #IMG_Memo
  #IMG_Pencil
  #IMG_Phone
  #IMG_Bold
  #IMG_Italic
  #IMG_BoldItalic
  #IMG_Strikethrough
  #IMG_Subscript
  #IMG_Superscript
  #IMG_LinkAdd
  #IMG_Link
  #IMG_LinkInline
  #IMG_Highlight
  #IMG_Image
  #IMG_ImageInline
  #IMG_ImageLink
  #IMG_Autolink
  #IMG_Keystroke
  #IMG_Footnote
  #IMG_H1
  #IMG_Code
  #IMG_Warning
  #IMG_Bulb
  #IMG_Clip
  #IMG_Magnifier
EndEnumeration
;}

;{ Load images
If ResourceEx::Open(#ResEx, "EasyHelpEditor.res")
  ResourceEx::UseImage(#ResEx, #IMG_Copy,          "Copy.png")
  ResourceEx::UseImage(#ResEx, #IMG_Cut,           "Cut.png")
  ResourceEx::UseImage(#ResEx, #IMG_Paste,         "Paste.png")
  ResourceEx::UseImage(#ResEx, #IMG_Warning,       "Warning.png")
  ResourceEx::UseImage(#ResEx, #IMG_Bulb,          "Bulb.png")
  ResourceEx::UseImage(#ResEx, #IMG_Clip,          "Clip.png")
  ResourceEx::UseImage(#ResEx, #IMG_Magnifier,     "Magnifier.png")
  ResourceEx::UseImage(#ResEx, #IMG_OK,            "OK.png")
  ResourceEx::UseImage(#ResEx, #IMG_Add,           "Add.png")
  ResourceEx::UseImage(#ResEx, #IMG_Edit,          "Edit.png")
  ResourceEx::UseImage(#ResEx, #IMG_Delete,        "Remove.png")
  ResourceEx::UseImage(#ResEx, #IMG_Up,            "Up.png")
  ResourceEx::UseImage(#ResEx, #IMG_Down,          "Down.png")
  ResourceEx::UseImage(#ResEx, #IMG_New,           "New.png")
  ResourceEx::UseImage(#ResEx, #IMG_Open,          "Open.png")
  ResourceEx::UseImage(#ResEx, #IMG_Save,          "Save.png")
  ResourceEx::UseImage(#ResEx, #IMG_Update,        "Update.png")
  ResourceEx::UseImage(#ResEx, #IMG_Settings,      "Settings.png")
  ResourceEx::UseImage(#ResEx, #IMG_Create,        "Create.png")
  ResourceEx::UseImage(#ResEx, #IMG_Bookmark,      "BookMark.png")
  ResourceEx::UseImage(#ResEx, #IMG_Date,          "Date.png")
  ResourceEx::UseImage(#ResEx, #IMG_Mail,          "Mail.png")
  ResourceEx::UseImage(#ResEx, #IMG_Memo,          "Memo.png")
  ResourceEx::UseImage(#ResEx, #IMG_Pencil,        "Pencil.png")
  ResourceEx::UseImage(#ResEx, #IMG_Phone,         "Phone.png")
  ResourceEx::UseImage(#ResEx, #IMG_Bold,          "Bold.png")
  ResourceEx::UseImage(#ResEx, #IMG_Italic,        "Italic.png")
  ResourceEx::UseImage(#ResEx, #IMG_BoldItalic,    "BoldItalic.png")
  ResourceEx::UseImage(#ResEx, #IMG_Strikethrough, "Strikethrough.png")
  ResourceEx::UseImage(#ResEx, #IMG_Subscript,     "Subscript.png")
  ResourceEx::UseImage(#ResEx, #IMG_Superscript,   "Superscript.png")
  ResourceEx::UseImage(#ResEx, #IMG_LinkAdd,       "LinkAdd.png")
  ResourceEx::UseImage(#ResEx, #IMG_Link,          "Link.png")
  ResourceEx::UseImage(#ResEx, #IMG_LinkInline,    "LinkInline.png")
  ResourceEx::UseImage(#ResEx, #IMG_Image,         "Image.png")
  ResourceEx::UseImage(#ResEx, #IMG_ImageInline,   "ImageInline.png")
  ResourceEx::UseImage(#ResEx, #IMG_ImageLink,     "ImageLink.png")
  ResourceEx::UseImage(#ResEx, #IMG_Autolink,      "AutoLink.png")
  ResourceEx::UseImage(#ResEx, #IMG_Highlight,     "Highlight.png")
  ResourceEx::UseImage(#ResEx, #IMG_Keystroke,     "KeyStroke.png")
  ResourceEx::UseImage(#ResEx, #IMG_Footnote,      "FootNote.png")
  ResourceEx::UseImage(#ResEx, #IMG_H1,            "H1.png")
  ResourceEx::UseImage(#ResEx, #IMG_Code,          "Code.png")
EndIf ;}

;- __________ Structures __________

Structure Language_Structure 
  Map Strg.s()
EndStructure
Global NewMap Language.Language_Structure()

Global NewMap Lng.s()
Global NewMap Label.i()

Structure Topic_Structure ;{ Topic()\...
  Titel.s
  Label.s
  Text.s
  Level.i
EndStructure ;}
Global NewList Topic.Topic_Structure()

Global Path$

;- __________ Windows __________

Procedure.i Window_Settings()
  Define.i gWidth
  
  If OpenWindow(#Window_Settings, 0, 0, 180, 157, " " + Lng("Settings"), #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(#Window_MarkDown))
    
    FrameGadget(#Gadget_Settings_Frame, 10, 5, 160, 112, "")
    
    TextGadget(#Gadget_Settings_Tx_Language, 25, 28, 55, 18, Lng("Language") + ": ")
      SetGadgetFont(#Gadget_Settings_Tx_Language, FontID(#Font_Arial9))
      gWidth = GadgetWidth(#Gadget_Settings_Tx_Language, #PB_Gadget_RequiredSize)
      ResizeGadget(#Gadget_Settings_Tx_Language, #PB_Ignore, #PB_Ignore, gWidth, #PB_Ignore)
    ComboBoxGadget(#Gadget_Settings_CB_Code, gWidth + 25, 25, 40, 22)
      SetGadgetFont(#Gadget_Settings_CB_Code, FontID(#Font_Arial9B))
    CheckBoxGadget(#Gadget_Settings_OG_SpellCheck, 25, 57, 125, 15, " " + Lng("Spellcheck"))
      SetGadgetFont(#Gadget_Settings_OG_SpellCheck, FontID(#Font_Arial9))
    ComboBoxGadget(#Gadget_Settings_CB_Dictionary, 25, 80, 130, 22)
      SetGadgetFont(#Gadget_Settings_CB_Dictionary, FontID(#Font_Arial9B))
    
    ButtonGadget(#Gadget_Settings_Bt_Apply, 50, 122, 80, 25, Lng("Apply"))
    
    DisableGadget(#Gadget_Settings_CB_Dictionary, #True)
    
    HideWindow(#Window_Settings, #False)
    
    ProcedureReturn WindowID(#Window_Settings)
  EndIf
EndProcedure

Procedure.i Window_NewEntry()
  
  If OpenWindow(#Window_NewEntry, 0, 0, 170, 150, " " + Lng("Title_NewEntry"), #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(#Window_MarkDown))
    
    FrameGadget(#Gadget_NewEntry_Frame, 10, 5, 150, 110, "")
    
    TextGadget(#Gadget_NewEntry_Tx_Title, 25, 20, 60, 15, Lng("Title"))
      SetGadgetFont(#Gadget_NewEntry_Tx_Title, FontID(#Font_Arial8B))
    StringGadget(#Gadget_NewEntry_SG_Title, 25, 35, 120, 20, "")
    
    TextGadget(#Gadget_NewEntry_TX_Label, 25, 65, 60, 15, Lng("Label"))
    StringGadget(#Gadget_NewEntry_SG_Label, 25, 80, 75, 20, "")
    
    TextGadget(#Gadget_NewEntry_Tx_Level,  110, 65, 35, 15, Lng("Level"))
    SpinGadget(#Gadget_NewEntry_SpG_Level, 110, 80, 35, 20, 0, 5, #PB_Spin_ReadOnly|#PB_Spin_Numeric)
    
    ButtonGadget(#Gadget_NewEntry_Bt_OK, 45, 120, 80, 25, Lng("Apply"))
   
    HideWindow(#Window_NewEntry, #False)
   
    ProcedureReturn WindowID(#Window_NewEntry)
  EndIf
  
EndProcedure

Procedure.i Window_MarkDown()
  
  If OpenWindow(#Window_MarkDown, 0, 0, 630, 580, " EasyHelp - Editor", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered|#PB_Window_Invisible)
    
    If CreatePopupImageMenu(#PopupMenu) ;{ PopupMenu
      MenuItem(#Menu_Copy,  Lng("Copy"),  ImageID(#IMG_Copy))
      MenuItem(#Menu_Cut,   Lng("Cut"),   ImageID(#IMG_Cut))
      MenuItem(#Menu_Paste, Lng("Paste"), ImageID(#IMG_Paste))
      MenuBar()
      OpenSubMenu(Lng("Headings"), ImageID(#IMG_H1))
        MenuItem(#Menu_H1, "H1")
        MenuItem(#Menu_H2, "H2")
        MenuItem(#Menu_H3, "H3")
        MenuItem(#Menu_H4, "H4")
        MenuItem(#Menu_H5, "H5")
        MenuItem(#Menu_H6, "H6")
      CloseSubMenu()
      MenuBar()
      MenuItem(#Menu_Code, Lng("Code"),                     ImageID(#IMG_Code))  
      OpenSubMenu(Lng("Emphasis"), ImageID(#IMG_BoldItalic))
        MenuItem(#Menu_Bold,         Lng("Bold"),           ImageID(#IMG_Bold))
        MenuItem(#Menu_Italic,       Lng("Italic"),         ImageID(#IMG_Italic))
        MenuItem(#Menu_BoldItalic,   Lng("Bold")+"/"+Lng("Italic"), ImageID(#IMG_BoldItalic))
        MenuBar()
        MenuItem(#Menu_Highlight,    Lng("Highlight"),      ImageID(#IMG_Highlight))
      CloseSubMenu() 
      MenuItem(#Menu_Strikethrough,  Lng("Strikethrough"),  ImageID(#IMG_Strikethrough))
      MenuBar()
      MenuItem(#Menu_SubScript,      Lng("SubScript"),      ImageID(#IMG_Subscript))
      MenuItem(#Menu_SuperScript,    Lng("SuperScript"),    ImageID(#IMG_Superscript))
      MenuBar()
      MenuItem(#Menu_Keystroke,      Lng("Keystroke"),      ImageID(#IMG_Keystroke))
      MenuBar()
      MenuItem(#Menu_Footnote,       Lng("Footnote"),       ImageID(#IMG_Footnote))
      MenuItem(#Menu_URL,            "URL/" + Lng("EMail"), ImageID(#IMG_Autolink))
      OpenSubMenu(Lng("Link"), ImageID(#IMG_LinkAdd))
        MenuItem(#Menu_Link,         Lng("Inline"),         ImageID(#IMG_LinkInline))
        MenuItem(#Menu_LinkRef,      Lng("Reference"),      ImageID(#IMG_Link))
      CloseSubMenu()
      OpenSubMenu(Lng("Image"), ImageID(#IMG_Image))
        MenuItem(#Menu_Image,        Lng("Inline"),         ImageID(#IMG_ImageInline))
        MenuItem(#Menu_ImageRef,     Lng("Reference"),      ImageID(#IMG_ImageLink))
      CloseSubMenu()
      MenuBar()
      MenuItem(#Menu_Abbreviation,   Lng("Abbreviation"))
      OpenSubMenu(Lng("Reference"))
        MenuItem(#Menu_Ref_Footnote, Lng("Footnote"),       ImageID(#IMG_Footnote))
        MenuItem(#Menu_Ref_Link,     Lng("Link"),           ImageID(#IMG_Link))
        MenuItem(#Menu_Ref_Image,    Lng("Image"),          ImageID(#IMG_Image))
      CloseSubMenu()
      MenuBar()
      OpenSubMenu(Lng("Emoji"))
        MenuItem(#Emoji_Bookmark,    Lng("Bookmark"),       ImageID(#IMG_Bookmark))
        MenuItem(#Emoji_Bulb,        Lng("Bulb"),           ImageID(#IMG_Bulb))
        MenuItem(#Emoji_Date,        Lng("Date"),           ImageID(#IMG_Date))
        MenuItem(#Emoji_Magnifier,   Lng("Magnifier"),      ImageID(#IMG_Magnifier))
        MenuItem(#Emoji_Mail,        Lng("Mail"),           ImageID(#IMG_Mail))
        MenuItem(#Emoji_Memo,        Lng("Memo"),           ImageID(#IMG_Memo))
        MenuItem(#Emoji_Clip,        Lng("Paperclip"),      ImageID(#IMG_Clip))
        MenuItem(#Emoji_Pencil,      Lng("Pencil"),         ImageID(#IMG_Pencil))
        MenuItem(#Emoji_Phone,       Lng("Phone"),          ImageID(#IMG_Phone))
        MenuItem(#Emoji_Warning,     Lng("Warning"),        ImageID(#IMG_Warning))
      CloseSubMenu()
    EndIf ;}
    
    TreeEx::Gadget(#Gadget_MarkDown_Tree, 10, 10, 180, 525, "", TreeEx::#AlwaysShowSelection, #Window_MarkDown)
    
    If EditEx::Gadget(#Gadget_MarkDown_Editor, 200, 10, 420, 525, EditEx::#WordWrap, #Window_MarkDown)
      EditEx::DisableSuggestions(#Gadget_MarkDown_Editor, #True)
      EditEx::SetColor(#Gadget_MarkDown_Editor, EditEx::#BackColor, $FBFFFF)
      EditEx::SetFont(#Gadget_MarkDown_Editor, FontID(#Font_Arial11))
    EndIf 
    
    If MarkDown::Gadget(#Gadget_MarkDown_Viewer, 200, 10, 420, 525)
      MarkDown::SetFont(#Gadget_MarkDown_Viewer, "Arial", 11)
      MarkDown::SetMargins(#Gadget_MarkDown_Viewer, 10, 10)
    EndIf
    
    ButtonImageGadget(#Gadget_MarkDown_Add,     10, 542, 25, 26, ImageID(#IMG_Add))
    ButtonImageGadget(#Gadget_MarkDown_Edit,    40, 542, 25, 26, ImageID(#IMG_Edit))
    ButtonImageGadget(#Gadget_MarkDown_Delete,  70, 542, 25, 26, ImageID(#IMG_Delete))

    ButtonImageGadget(#Gadget_MarkDown_Up,     140, 545, 22, 20, ImageID(#IMG_Up))
    ButtonImageGadget(#Gadget_MarkDown_Down,   163, 545, 22, 20, ImageID(#IMG_Down))
    FrameGadget(#Gadget_MarkDown_Frame, 135, 535, 55, 35, "")
    
    ButtonImageGadget(#Gadget_MarkDown_Bt_Preview,  200, 540, 30, 30, ImageID(#IMG_Update), #PB_Button_Toggle)
    ButtonImageGadget(#Gadget_MarkDown_Bt_New,      245, 540, 30, 30, ImageID(#IMG_New))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Open,     280, 540, 30, 30, ImageID(#IMG_Open))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Save,     315, 540, 30, 30, ImageID(#IMG_Save))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Create,   545, 540, 30, 30, ImageID(#IMG_Create))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Settings, 590, 540, 30, 30, ImageID(#IMG_Settings))
    
    If Resize::AddWindow(#Window_MarkDown, 445, 330)
      Resize::AddGadget(#Gadget_MarkDown_Tree,        Resize::#Height)
      Resize::AddGadget(#Gadget_MarkDown_Editor,      Resize::#Width|Resize::#Height)
      Resize::AddGadget(#Gadget_MarkDown_Viewer,      Resize::#Width|Resize::#Height)
      Resize::AddGadget(#Gadget_MarkDown_Add,         Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Edit,        Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Delete,      Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Up,          Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Down,        Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Frame,       Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_Preview,  Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_New,      Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_Open,     Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_Save,     Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_Create,      Resize::#MoveX|Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_Settings, Resize::#MoveX|Resize::#MoveY)
    EndIf
    
    EditEx::Disable(#Gadget_MarkDown_Editor, #True)
    
    DisableGadget(#Gadget_MarkDown_Bt_Save, #True)
    DisableGadget(#Gadget_MarkDown_Bt_Create,  #True)
    DisableGadget(#Gadget_MarkDown_Add,     #True)
    DisableGadget(#Gadget_MarkDown_Edit,    #True)
    DisableGadget(#Gadget_MarkDown_Delete,  #True)
    
    HideGadget(#Gadget_MarkDown_Viewer, #True)
    
    HideWindow(#Window_MarkDown, #False)
    
    ProcedureReturn WindowID(#Window_MarkDown)
  EndIf
  
EndProcedure

;- __________ Procedures __________

Procedure   SaveEntry()
  
  If ListIndex(Topic()) >= 0
    Topic()\Text = ReplaceString(EditEx::GetText(#Gadget_MarkDown_Editor), #CRLF$, #LF$)
  EndIf
  
EndProcedure

Procedure   ListEntries(Index.i=#PB_Default)
  Define.i Row
  
  SaveEntry()
  
  PushListPosition(Topic())
  
  TreeEx::ClearItems(#Gadget_MarkDown_Tree)
  
  ClearMap(Label())
  
  ForEach Topic()
    TreeEx::AddItem(#Gadget_MarkDown_Tree, TreeEx::#LastRow, Topic()\Titel, Topic()\Label, #False, Topic()\Level)
    If Topic()\Label : Label(Topic()\Label) = ListIndex(Topic()) : EndIf
  Next
  
  PopListPosition(Topic())
  
  If Index <> #PB_Default
    
    If SelectElement(Topic(), Index)
      TreeEx::SetState(#Gadget_MarkDown_Tree,    Index)
      EditEx::SetText(#Gadget_MarkDown_Editor,   Topic()\Text)
      Markdown::SetText(#Gadget_MarkDown_Viewer, Topic()\Text)
    EndIf
    
  EndIf  
  
  If ListSize(Topic())
    DisableGadget(#Gadget_MarkDown_Edit,    #False)
    DisableGadget(#Gadget_MarkDown_Delete,  #False)
  Else
    DisableGadget(#Gadget_MarkDown_Edit,    #True)
    DisableGadget(#Gadget_MarkDown_Delete,  #True)
  EndIf   
  
EndProcedure  


Procedure   SelectLink(Link.s)
  
  If FindMapElement(Label(), Link)
    
    If SelectElement(Topic(), Label())
      TreeEx::SetState(#Gadget_MarkDown_Tree, Label())
      Markdown::SetText(#Gadget_MarkDown_Viewer, Topic()\Text)
      EditEx::SetText(#Gadget_MarkDown_Editor,   Topic()\Text)
    EndIf
  
  EndIf  
  
EndProcedure  

Procedure   SelectEntry(Index.i)
  
  SaveEntry()
  
  If Index >= 0
    
    If SelectElement(Topic(), Index)
      EditEx::SetText(#Gadget_MarkDown_Editor,   Topic()\Text)
      Markdown::SetText(#Gadget_MarkDown_Viewer, Topic()\Text)
    EndIf   
    
  EndIf  
  
EndProcedure


Procedure   Create(File$)
  Define.i Size, Result
  Define   *Buffer
  
  NewMap Images.s()
  
  SaveEntry()
  
  If CreatePack(#Pack, File$, #PB_PackerPlugin_Lzma)
    
    If CreateJSON(#JSON)  ;{ Save Markdown
      
      InsertJSONList(JSONValue(#JSON), Topic())
      
      Size = ExportJSONSize(#JSON)
      If Size
        *Buffer = AllocateMemory(Size)
        If *Buffer
          If ExportJSON(#JSON, *Buffer, Size)
            Result = AddPackMemory(#JSON, *Buffer, Size, "Help.json")
          EndIf
          FreeMemory(*Buffer)
        EndIf
      EndIf
     
      FreeJSON(#JSON)
      ;}
    EndIf
    
    ForEach Topic()       ;{ Look for images
      Markdown::UsedImages(Topic()\Text, Images())
      ;}
    Next
    
    If MapSize(Images()) ;{ Save images
      
      ForEach Images()
        AddPackFile(#Pack, Path$ +  GetFilePart(Images()), GetFilePart(Images()))
      Next  
      ;}
    EndIf  
    
    ClosePack(#Pack)
  EndIf
  
  ProcedureReturn Result
EndProcedure  


Procedure.s Load_()
  Define.s File$, Last$
  
  Last$ = AppReg::GetValue(#AppReg, "Last", "Path", GetPathPart(ProgramFilename())) 
  
  File$ = OpenFileRequester(Lng("Msg_Load"), Last$, "Markdown (*.md)|*.md;*.txt", 0)
  If File$
    
    Path$ = GetPathPart(File$)
    
    AppReg::SetValue(#AppReg, "Last", "Path", Path$)
    
    If LoadJSON(#JSON, File$)
      ExtractJSONList(JSONValue(#JSON), Topic())
      FreeJSON(#JSON)
    EndIf  
    
    Markdown::SetImagePath(#Gadget_MarkDown_Viewer, Path$)
    
    ResetList(Topic()) 
    
    ListEntries(0)
    
  EndIf
  
  ProcedureReturn GetFilePart(File$)
EndProcedure

Procedure.s Save_(FileName.s, SaveAs.i=#True)
  Define.s Text$, File$, Last$
  
  SaveEntry()
  
  If FileName = "" : SaveAs = #True : EndIf 

  Last$ = AppReg::GetValue(#AppReg, "Last", "Path", GetPathPart(ProgramFilename()))
  
  If SaveAs
    
    File$ = SaveFileRequester(Lng("Msg_Save"), Last$ + FileName, "Markdown (*.md)|*.md;*.txt", 0)
    If File$
      
      If GetExtensionPart(File$) = "mdh" : File$ = GetPathPart(File$) + GetFilePart(File$, #PB_FileSystem_NoExtension) + ".md" : EndIf
      If GetExtensionPart(File$) = "" : File$ + ".md" : EndIf
      
      AppReg::SetValue(#AppReg, "Last", "Path", GetPathPart(File$))
      
      If CreateJSON(#JSON)
        InsertJSONList(JSONValue(#JSON), Topic())
        SaveJSON(#JSON, File$)
        FreeJSON(#JSON)
      EndIf
      
      ResetList(Topic()) 
      
      ProcedureReturn GetFilePart(File$)
    EndIf
    
  Else
    
    If CreateJSON(#JSON)
      InsertJSONList(JSONValue(#JSON), Topic())
      SaveJSON(#JSON, Last$ + FileName)
      FreeJSON(#JSON)
    EndIf
    
    ResetList(Topic()) 
    
    ProcedureReturn FileName
  EndIf
  
EndProcedure  

Procedure.s New_(FileName.s)
  Define.s Last$, File$
  
  If FileName
    If MessageRequester(Lng("Title_New"), Lng("Msg_Close"), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
      Save_(FileName, #False)
    EndIf
  EndIf
  
  MarkDown::Clear(#Gadget_MarkDown_Viewer)
  EditEx::SetText(#Gadget_MarkDown_Editor, "")
  
  ClearList(Topic())
  
  Last$ = AppReg::GetValue(#AppReg, "Last", "Path", GetPathPart(ProgramFilename()))
  
  File$ = SaveFileRequester(Lng("Msg_Save"), Last$, "Markdown (*.md)|*.md;*.txt", 0)
  If File$
    
    Path$ = GetPathPart(File$)
    
    If GetExtensionPart(File$) = "" : File$ + ".md" : EndIf
    
    AppReg::SetValue(#AppReg, "Last", "Path", Path$)
    
    Markdown::SetImagePath(#Gadget_MarkDown_Viewer, Path$)
    
    ProcedureReturn File$
  EndIf 
  
EndProcedure


Procedure   PopupMenu_(sStrg.s, eStrg.s)
  Define.s String$
  
  If EditEx::IsSelected(#Gadget_MarkDown_Editor)
    String$ = sStrg + EditEx::GetSelection(#Gadget_MarkDown_Editor, #False) + eStrg
  Else
    String$ = sStrg + " " + eStrg
  EndIf
  
  EditEx::InsertText(#Gadget_MarkDown_Editor, String$)
  
EndProcedure

;- __________ Window - Procedures __________

Procedure   SettingsWindow()
  Define.i quitWindow = #False
  Define.s Code$
  
  If Window_Settings()
    
    ;{ Language
    ForEach Language()
      AddGadgetItem(#Gadget_Settings_CB_Code, -1, MapKey(Language()))
    Next
    SetGadgetText(#Gadget_Settings_CB_Code, AppReg::GetValue(#AppReg, "Settings", "Language", "GB") )
    ;}
    
    ;{ Dictionary
    If ExamineDirectory(#Dir, GetCurrentDirectory(), "*.dic")  
      
      While NextDirectoryEntry(#Dir)
        If DirectoryEntryType(#Dir) = #PB_DirectoryEntry_File
          AddGadgetItem(#Gadget_Settings_CB_Dictionary, -1, GetFilePart(DirectoryEntryName(#Dir)))
        EndIf
      Wend
      
      FinishDirectory(#Dir)
    EndIf
    
    SetGadgetText(#Gadget_Settings_CB_Dictionary, AppReg::GetValue(#AppReg, "Settings", "Dictionary"))
    
    SetGadgetState(#Gadget_Settings_OG_SpellCheck, AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #False))
    If AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #False)
      SetGadgetState(#Gadget_Settings_OG_SpellCheck, #True)
      DisableGadget(#Gadget_Settings_CB_Dictionary, #False)
    EndIf 
    ;}
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow               ;{ Close Window
          Select EventWindow()
            Case #Window_Settings
              quitWindow = #True
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_Settings_OG_SpellCheck  ;{ SpellCheck
              
              If GetGadgetState(#Gadget_Settings_OG_SpellCheck)
                DisableGadget(#Gadget_Settings_CB_Dictionary, #False)
              Else
                DisableGadget(#Gadget_Settings_CB_Dictionary, #True)
              EndIf
              ;}
            Case #Gadget_Settings_Bt_Apply       ;{ Apply Settings
              
              ;{ Language
              Code$ = GetGadgetText(#Gadget_Settings_CB_Code)
              If FindMapElement(Language(), Code$)
                AppReg::SetValue(#AppReg, "Settings", "Language", Code$)
                CopyMap(Language()\Strg(), Lng())
              EndIf ;}
              
              ;{ Spellchecking
              If GetGadgetState(#Gadget_Settings_OG_SpellCheck)
                AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #True)
                If GetGadgetText(#Gadget_Settings_CB_Dictionary)
                  AppReg::SetValue(#AppReg, "Settings", "Dictionary", GetGadgetText(#Gadget_Settings_CB_Dictionary))
                  EditEx::LoadDictionary(GetGadgetText(#Gadget_Settings_CB_Dictionary))
                  EditEx::EnableAutoSpellCheck(#True)
                EndIf 
              Else
                AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #False)
                EditEx::EnableAutoSpellCheck(#False)
              EndIf
              ;}
              
              quitWindow = #True
              ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_Settings)
  EndIf
  
EndProcedure  

Procedure.i NewEntryWindow(Idx.i=#PB_Default)
  Define.i quitWindow = #False
  
  If Window_NewEntry()
    
    SetGadgetText(#Gadget_NewEntry_SpG_Level, "0")
    
    If Idx <> #PB_Default ;{ Edit Entry
      
      If SelectElement(Topic(), Idx) 
        SetGadgetText(#Gadget_NewEntry_SG_Title,  Topic()\Titel)
        SetGadgetText(#Gadget_NewEntry_SG_Label,  Topic()\Label)
        SetGadgetText(#Gadget_NewEntry_SpG_Level, Str(Topic()\Level))
      EndIf
      ;}  
    EndIf  
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow      ;{ Close Window
          Select EventWindow()
            Case #Window_NewEntry
              quitWindow = #True
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_NewEntry_Bt_OK ;{ Apply
              
              If Idx = #PB_Default
                
                If AddElement(Topic())
                  Topic()\Titel = GetGadgetText(#Gadget_NewEntry_SG_Title)
                  Topic()\Label = GetGadgetText(#Gadget_NewEntry_SG_Label)
                  Topic()\Level = GetGadgetState(#Gadget_NewEntry_SpG_Level)
                EndIf
                
                ResetList(Topic())

              Else
                
                If SelectElement(Topic(), Idx)
                  Topic()\Titel = GetGadgetText(#Gadget_NewEntry_SG_Title)
                  Topic()\Label = GetGadgetText(#Gadget_NewEntry_SG_Label)
                  Topic()\Level = GetGadgetState(#Gadget_NewEntry_SpG_Level)
                EndIf
              
              EndIf
              
              quitWindow = #True
              ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_NewEntry)
  EndIf
  
EndProcedure  

;- __________ Main - Loop __________

Define.i Current, Selected
Define.i quitWindow = #False
Define.s FileName$, file$, Last$, Code$, String$, Link$
Define   *Relative

AppReg::Open(#AppReg, "EasyHelpEditor.reg", "EasyHelp", "Thorsten Hoeppner")

;{ Load language file
If LoadXML(#XML, "EasyHelpEditor.lng")
  ExtractXMLMap(MainXMLNode(#XML), Language())
  FreeXML(#XML)
EndIf ;}

;{ Load dictionary

If AppReg::GetValue(#AppReg, "Settings", "SpellCheck")
  If FileSize(AppReg::GetValue(#AppReg, "Settings", "Dictionary"))
    EditEx::LoadDictionary(AppReg::GetValue(#AppReg, "Settings", "Dictionary"))
    EditEx::EnableAutoSpellCheck(#True)
  EndIf
EndIf
;}

Code$ = AppReg::GetValue(#AppReg, "Settings", "Language", "GB") 
If FindMapElement(Language(), Code$)
  CopyMap(Language()\Strg(), Lng())
EndIf  

Window::Load("EasyHelpEditor.win")

If Window_MarkDown()
  
  Window::RestoreSize(#Window_MarkDown)
  
  Current = #PB_Default
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow   ;{ Close Window
        Select EventWindow()
          Case #Window_MarkDown
            If FileName$
               If Markdown::Requester(Lng("Title_DelEntry"), Lng("Msg_Close") + "  " + #LF$ + "\[ **"+FileName$+"** \]", Markdown::#YesNo|Markdown::#Question, #Window_MarkDown) = Markdown::#Result_Yes
                Save_(FileName$, #False)
              EndIf
            EndIf 
            quitWindow = #True
        EndSelect ;}
      Case #PB_Event_Menu
        Select EventMenu()
          Case #Menu_Copy          ;{ Copy & Paste
            EditEx::Copy(#Gadget_MarkDown_Editor)
          Case #Menu_Cut 
            EditEx:: Cut(#Gadget_MarkDown_Editor)
          Case #Menu_Paste
            EditEx::Paste(#Gadget_MarkDown_Editor)
            ;}
          Case #Menu_H1            ;{ Headings
            PopupMenu_("# ", " #")
          Case #Menu_H2
            PopupMenu_("## ", " ##")
          Case #Menu_H3
            PopupMenu_("### ", " ###")
          Case #Menu_H4
            PopupMenu_("#### ", " ####")
          Case #Menu_H5
            PopupMenu_("##### ", " #####")
          Case #Menu_H6
            PopupMenu_("###### ", " ######")
            ;}
          Case #Menu_Code          ;{ Code
            PopupMenu_("`", "`")       
            ;}
          Case #Menu_Bold          ;{ Emphasis
            PopupMenu_("**", "**")
          Case #Menu_Italic
            PopupMenu_("*", "*")
          Case #Menu_BoldItalic
            PopupMenu_("***", "***")
          Case #Menu_Highlight
            PopupMenu_("==", "==")
            ;}
          Case #Menu_Strikethrough ;{ Strikethrough
            PopupMenu_("~~", "~~")
            ;}
          Case #Menu_SubScript     ;{ SubScript/SuperScript
            PopupMenu_("~", "~")
          Case #Menu_SuperScript
            PopupMenu_("^", "^")
            ;}
          Case #Menu_Keystroke     ;{ Keystroke
            PopupMenu_("[[", "]]")
            ;}
          Case #Menu_Footnote      ;{ Footnote
            PopupMenu_("[^", "]")
            ;}
          Case #Menu_URL           ;{ URL/EMail
            PopupMenu_("<", ">")
            ;}
          Case #Menu_Link          ;{ Links
            PopupMenu_("[](", " " + #DQUOTE$ + #DQUOTE$ + ")")
          Case #Menu_LinkRef
            PopupMenu_("[", "][]")
            ;}
          Case #Menu_Image         ;{ Images
            PopupMenu_("![](", " " + #DQUOTE$ + #DQUOTE$ + ")")
          Case #Menu_ImageRef
            PopupMenu_("![", "][]")
            ;}
          Case #Menu_Abbreviation  ;{ Abbreviation
            PopupMenu_("*[", "]: ")
            ;}
          Case #Menu_Ref_Footnote  ;{ Reference
            PopupMenu_("[^", "]: ")
          Case #Menu_Ref_Image
            PopupMenu_("![", "]: ")
          Case #Menu_Ref_Link
            PopupMenu_("[", "]: ")
            ;}
          Case #Emoji_Bookmark     ;{ Emoji
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":bookmark:")
          Case #Emoji_Bulb 
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":bulb:")
          Case #Emoji_Clip  
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":paperclip:")
          Case #Emoji_Date
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":date:")
          Case #Emoji_Magnifier
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":magnifier:")
          Case #Emoji_Mail
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":mail:")
          Case #Emoji_Memo
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":memo:")
          Case #Emoji_Pencil
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":pencil:")
          Case #Emoji_Phone  
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":phone:")
          Case #Emoji_Warning
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":warning:")
            ;}
        EndSelect    
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gadget_MarkDown_Tree        ;{ Select entry
            Select EventType()
              Case TreeEx::#EventType_Row
                Current = SelectEntry(EventData()) 
            EndSelect ;}
          Case #Gadget_MarkDown_Editor      ;{ PopupMenu
            Select EventType()
              Case #PB_EventType_RightClick
                DisplayPopupMenu(#PopupMenu, WindowID(#Window_MarkDown))  
            EndSelect ;}
          Case #Gadget_MarkDown_Viewer      ;{ Links    
            Select EventType()
              Case Markdown::#EventType_Link
                Link$ = MarkDown::EventValue(#Gadget_MarkDown_Viewer)
                If Link$
                  If Left(Link$, 1) = "#"
                    SelectLink(LTrim(Link$, "#"))
                  Else
                    RunProgram(Link$)
                  EndIf
                EndIf  
            EndSelect ;}
          Case #Gadget_MarkDown_Bt_New      ;{ New document
            FileName$ = New_(FileName$)
            EditEx::Disable(#Gadget_MarkDown_Editor,  #False)
            DisableGadget(#Gadget_MarkDown_Bt_Save,   #False)
            DisableGadget(#Gadget_MarkDown_Bt_Create, #False)
            DisableGadget(#Gadget_MarkDown_Add,       #False)
            ;}
          Case #Gadget_MarkDown_Bt_Open     ;{ Open document
            FileName$ = Load_()
            EditEx::Disable(#Gadget_MarkDown_Editor,  #False)
            DisableGadget(#Gadget_MarkDown_Bt_Save,   #False)
            DisableGadget(#Gadget_MarkDown_Bt_Create, #False)
            DisableGadget(#Gadget_MarkDown_Add,       #False)
            ;}
          Case #Gadget_MarkDown_Bt_Save     ;{ Save document
            FileName$ = Save_(FileName$)
            ;}
          Case #Gadget_MarkDown_Bt_Create   ;{ Create help file
            
            Last$ = AppReg::GetValue(#AppReg, "Last", "Create", GetPathPart(ProgramFilename()))
            
            File$ = SaveFileRequester(Lng("Msg_Create"), Last$, Lng("HelpFile") + " (*.mdh)|*.mdh", 0)
            If File$
              
              If GetExtensionPart(File$) <> "mdh" : File$ = GetPathPart(File$) + GetFilePart(File$, #PB_FileSystem_NoExtension) + ".mdh" : EndIf
              
              AppReg::SetValue(#AppReg, "Last", "Create", GetPathPart(File$))
              
              Create(File$)
            EndIf            
            ;}
          Case #Gadget_MarkDown_Bt_Preview  ;{ Preview Markdown
            
            SaveEntry()
            
            If ListIndex(Topic()) >= 0
              Markdown::SetText(#Gadget_MarkDown_Viewer, Topic()\Text)
            EndIf  
            
            If GetGadgetState(#Gadget_MarkDown_Bt_Preview)
              HideGadget(#Gadget_MarkDown_Viewer, #False)
              HideGadget(#Gadget_MarkDown_Editor, #True)
            Else
              HideGadget(#Gadget_MarkDown_Viewer, #True)
              HideGadget(#Gadget_MarkDown_Editor, #False)
            EndIf
            ;}
          Case #Gadget_MarkDown_Bt_Settings ;{ Settings
            SettingsWindow()
            ;}
          Case #Gadget_MarkDown_Add         ;{ Add new topic entry
            SaveEntry()
            Current = NewEntryWindow()
            ListEntries(Current)
            ;}
          Case #Gadget_MarkDown_Edit        ;{ Edit topic entry
            
            SaveEntry()
            
            Selected = TreeEx::GetState(#Gadget_MarkDown_Tree)
            If Selected <> -1
              NewEntryWindow(Selected)
              ListEntries(Selected)
            EndIf
            ;}
          Case #Gadget_MarkDown_Delete      ;{ Delete topic entry
            If ListIndex(Topic()) >= 0
              If Markdown::Requester(Lng("Title_DelEntry"), Lng("Msg_DelEntry") + "  " + #LF$ + "'**"+Topic()\Titel+"**'", Markdown::#YesNo|Markdown::#Warning, #Window_MarkDown) = Markdown::#Result_Yes
                DeleteElement(Topic())
                ListEntries(Current)
              EndIf
            EndIf
            ;}
          Case #Gadget_MarkDown_Up          ;{ Move up
            
            SaveEntry()

            Selected = TreeEx::GetState(#Gadget_MarkDown_Tree)
            If Selected <> -1
              If SelectElement(Topic(), Selected)
                *Relative = @Topic()
                PreviousElement(Topic())
                MoveElement(Topic(), #PB_List_After, *Relative) 
                ListEntries(Selected - 1)
              EndIf 
            EndIf
            ;}
          Case #Gadget_MarkDown_Down        ;{ Move down
            
            SaveEntry()
            
            Selected = TreeEx::GetState(#Gadget_MarkDown_Tree)
            If Selected <> -1
              If SelectElement(Topic(), Selected)
                *Relative = @Topic()
                NextElement(Topic())
                MoveElement(Topic(), #PB_List_Before, *Relative) 
                ListEntries(Selected + 1)
              EndIf 
            EndIf
            ;}
        EndSelect
    EndSelect
  Until quitWindow
  
  Window::Save("EasyHelpEditor.win")
  
  CloseWindow(#Window_MarkDown)
EndIf

AppReg::Close(#AppReg)

End
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 572
; FirstLine = 109
; Folding = JAIkApKAAAAg
; EnableXP
; DPIAware
; UseIcon = EasyHelp.ico
; Executable = EasyHelpEditor.exe