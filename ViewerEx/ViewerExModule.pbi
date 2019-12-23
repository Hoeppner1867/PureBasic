;/ ============================
;/ =     ViewerExModule.pbi   =
;/ ============================
;/
;/ [ PB V5.7x / All OS / DPI / 64Bit ]
;/
;/ Module by Thorsten1867 (04/2019)
;/
;/ Algorithmus für Silbentrennung von Frankling Mark Liang (1983)
;/ Pattern based on (http://tug.org/tex-hyphen/)
;/

; Last Update: 23.12.19
;
; Added: Content Tree
; Added: Link and URL are underlined
; Added: #UseExistingCanvas
;

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

;{ ===== Additional tea & pizza license =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ ViewerEx - Commands _____

;  ViewerEx::ClearContent()       - clear gadget content
;  ViewerEx::EventValue()         - return string value for the event (e.g. URL)
;  ViewerEx::Gadget()             - new gadget
;  ViewerEx::Load()               - load contents for the gadget from a file
;  ViewerEx::SetAutoResizeFlags() - automatically adjust gadget to window size.
;  ViewerEx::SetContent()         - select or change content using its label
;  ViewerEx::SetHeadingOffset()   - offset for numbering headings

;  ----- #Enable_AddViewerContent & #Enable_CreateViewerContent -----

;  ViewerEx::UseFont()    - specify the character set to be used.
;  ViewerEx::UseImage()   - specify images to be used
;  ViewerEx::UsePattern() - set hyphenation patterns to be used

;  ----- #Enable_AddViewerContent (add content directly) -----
;  ViewerEx::AddHeading()      - insert numbered headline into gadget
;  ViewerEx::AddImage()        - insert image into gadget
;  ViewerEx::AddImageText()    - insert text next no an image into gadget
;  ViewerEx::AddLink()         - insert internal link into gadget
;  ViewerEx::AddListing()      - insert a listing with bullets
;  ViewerEx::AddSpacing()      - insert space between the items
;  ViewerEx::AddText()         - insert text into gadget
;  ViewerEx::AddURL()          - insert URL into gadget
;  ViewerEx::DefineHeading()   - define the appearance of headings
;  ViewerEx::DefineStyle()     - define the appearance of texts
;  ViewerEx::DisableReDraw()   - temporarily disable content redrawing
;  ViewerEx::Save()            - save the current content of the gadget with all required resources
;  ViewerEx::SetHyphenation()  - activate hyphenation for the corresponding language (pattern).
;  ViewerEx::SetMargin()       - define page margins

;  ----- #Enable_CreateViewerContent -----

;  ViewerEx::Create()            - create a new page with content under this label.
;  ViewerEx::Clear()             - clear all content
;  ViewerEx::Close()             - close the page with the corresponding label.
;  ViewerEx::CopyContent()       - copy generated content into a ViewerEx - Gadget.
;  ViewerEx::Export()            - export generated pages with content and save them with all resources in one file.
;  ViewerEx::Heading()           - add a numbered heading.
;  ViewerEx::HeadingDefinition() - defining the appearance of headings.
;  ViewerEx::Hyphenation()       - activate hyphenation for the corresponding language (pattern).
;  ViewerEx::Image()             - add a image.
;  ViewerEx::ImageText()         - add text next to an image
;  ViewerEx::Link()              - add a internal link.
;  ViewerEx::Listing()           - add a listing with bullets
;  ViewerEx::Margin()            - define page margins.
;  ViewerEx::Spacing()           - add space between items.
;  ViewerEx::StyleDefinition()   - define the appearance of texts.
;  ViewerEx::Text()              - add text.
;  ViewerEx::URL()               - add a URL.

;} -----------------------------

; XIncludeFile "ModuleEx.pbi"

DeclareModule ViewerEx
  
  #Version  = 19122300
  #ModuleEx = 19111702
  
  #Enable_Hyphenation         = #True
  #Enable_AddViewerContent    = #True ; Set it to #False to enable buttons
  #Enable_CreateViewerContent = #True
  #Enable_ContentTree         = #True
  
  EnumerationBinary Gadget
    #AutoResize
    #Borderless
    #UseExistingCanvas
  EndEnumeration
  
  EnumerationBinary Flags
    #AutoIndent
    #Center
    #Justified
    #Middle
    #Left
    #Right
    #Top
    #Bottom 
  EndEnumeration
  
  EnumerationBinary AutoResize
    #MoveX
    #MoveY
    #ResizeWidth
    #ResizeHeight
  EndEnumeration 
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Gadget   = ModuleEx::#Event_Gadget
    #Event_Theme    = ModuleEx::#Event_Theme
    
    #EventType_Link = ModuleEx::#EventType_Link

  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Link
    EndEnumeration
    
  CompilerEndIf
  
  CompilerIf #Enable_ContentTree
    
    Structure Content_Tree_Structure 
      Label.s
      Title.s
      Level.i
    EndStructure
    
  CompilerEndIf
  
  ;- ============================================================================
  ;-   DeclareModule
  ;- ============================================================================
  
  CompilerIf #Enable_AddViewerContent Or #Enable_CreateViewerContent
    Declare.s UseFont(Name.s, Size.i, Flags.i=#False, FontKey.s="")
    Declare.s UseImage(File.s, ImageKey.s="")
    Declare.s UsePattern(File.s, PatternKey.s="")
  CompilerEndIf
  
  CompilerIf #Enable_AddViewerContent
    Declare.i AddHeading(GNum.i, Text.s, HeadingKey.s, Flags.i=#Left)
    Declare.i AddImage(GNum.i, File.s, Width.i=#PB_Default, Height.i=#PB_Default, Indent.i=0, Flags.i=#False)
    Declare.i AddImageText(GNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#Left)
    Declare.i AddImageListing(GNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#False)
    Declare.i AddLink(GNum.i, Text.s, Label.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)   
    Declare.i AddListing(GNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#False)
    Declare   AddSpacing(GNum.i, Height.i)
    Declare.i AddText(GNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)
    Declare.i AddURL(GNum.i, URL.s, StyleKey.s="", String.s="", Indent.i=0, Flags.i=#Left)
    Declare.i DefineHeading(GNum.i, HeadingKey.s, FontKey.s, Level.i=0, Spacing.i=0, Ident.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default, Flags.i=#Left)
    Declare.i DefineStyle(GNum.i, Name.s, FontKey.s="", Indent.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default)
    Declare   Save(GNum.i, File.s)
    Declare   SetHyphenation(GNum.i, PatternKey.s)
    Declare   SetMargin(GNum.i, Attribute.i, Value.i)
  CompilerEndIf
  
  CompilerIf #Enable_CreateViewerContent
    Declare.i Create(CNum.i, Label.s)   
    Declare   Clear(CNum.i)
    Declare   Close(CNum.i)
    Declare   CopyContent(CNum.i, GNum.i)
    Declare.i Export(CNum.i, File.s)
    Declare.i Heading(GNum.i, Text.s, HeadingKey.s, Flags.i=#Left)
    Declare.i HeadingDefinition(CNum.i, HeadingKey.s, FontKey.s, Level.i=0, Spacing.i=0, Indent.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default, Flags.i=#Left)
    Declare   Hyphenation(CNum.i, PatternKey.s)
    Declare.i Image(CNum.i, ImageKey.s, Width=#PB_Default, Height.i=#PB_Default, Indent.i=0, Flags.i=#False)
    Declare.i ImageText(CNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#Left)
    Declare.i ImageListing(CNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#False)
    Declare.i Link(CNum.i, Text.s, Label.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)
    Declare.i Listing(GNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#False)
    Declare   Margin(CNum.i, Attribute.i, Value.i)
    Declare   Spacing(CNum.i, Height.i)
    Declare.i StyleDefinition(CNum.i, StyleKey.s, FontKey.s="", Indent.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default) 
    Declare.i Text(CNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)
    Declare.i URL(CNum.i, URL.s, StyleKey.s="", String.s="", Spacing.i=0, Flags.i=#Left)
    
    CompilerIf #Enable_ContentTree
      Declare.i AddTreeItem(CNum.i, Title.s, Label.s, Level.i=0) 
    CompilerEndIf
    
  CompilerEndIf
  
  CompilerIf #Enable_ContentTree
  	Declare.s GetContentTree(GNum.i, List ContentTree.Content_Tree_Structure())
  CompilerEndIf
  
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare   SetData(GNum.i, Value.q)
	Declare   SetID(GNum.i, String.s)
	Declare   ClearContent(GNum.i)
	Declare   DisableReDraw(GNum.i, State.i=#True)
  Declare.s EventValue(GNum.i)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Hide(GNum.i, State.i=#True)
  Declare.i Load(GNum.i, File.s)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetContent(GNum.i, Label.s="")
  Declare   SetHeadingOffset(GNum.i, Value.i, Level.i=0)
  
EndDeclareModule

Module ViewerEx
  
  EnableExplicit
  
  UseLZMAPacker()
  UsePNGImageDecoder()

  #Scroll_Width = 17
  
  #ViewerContentFile$ = "Content.json"
  
  Enumeration Type 1
    #Heading
    #Image
    #Text
    #Spacing
    #URL
    #Link
    #List
  EndEnumeration
  
  #Bullet$ = "•"
  #Hyphen$ = Chr(8722)
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================ 
  
  Structure Pattern_Structure
    FileName.s
    Size.i
  EndStructure
  
  Structure Hyphenation_Structure         ;{ Hyphen('DE')\...
    FileName.s
    List Pattern.s()
  EndStructure ;}
  
  Global NewMap Hyphen.Hyphenation_Structure()
  
  Structure Resources_Font_Structure     ;{ Resource\Font('key')\...
    Num.i
    Name.s
    Size.i
    Flags.i
  EndStructure ;}
  
  Structure Resources_Image_Structure    ;{ Resource\Image('key')\...
    Num.i
    File.s
    Size.i
  EndStructure ;}
  
  Structure Resources_Structure          ;{ Resource\...
    Map Font.Resources_Font_Structure ()
    Map Image.Resources_Image_Structure()
  EndStructure ;}
  Global Resource.Resources_Structure
  
  Structure ViewerEx_Color_Structure     ;{ VGEx()\Color\...
    Front.i
    Back.i
    ScrollBar.i
    Border.i
  EndStructure ;}  
  
  Structure ViewerEx_Window_Structure    ;{ VGEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure ViewerEx_ScrollBar_Structure ;{ VGEx()\ScrollBar\...
    Num.i
    Pos.i
    Hide.i
  EndStructure ;}
  
  Structure ViewerEx_Size_Structure      ;{ VGEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    OffSet.i
    Content.i
    Flags.i
  EndStructure ;}
  

  Structure Content_Margins_Structure    ;{ VGEx()\Content\Margin\...
    Top.i
    Left.i
    Right.i
    Bottom.i
  EndStructure ;} 
  
  Structure Content_Font_Structure       ;{ VGEx()\Content\Font\...
    Name.s
    Size.i
    Flags.i
  EndStructure ;}
  
  Structure Content_Style_Structure      ;{ VGEx()\Content\Style\...
    FontKey.s
    Indent.i
    BackColor.i
    FrontColor.i
  EndStructure ;}
  
  Structure Content_Heading_Structure    ;{ VGEx()\Content\Heading('key')\...
    FontKey.s
    BackColor.i
    FrontColor.i
    Spacing.i
    Indent.i
    Level.i
    Flags.i
  EndStructure ;}
  
  Structure Content_Image_Structure      ;{ VGEx()\Content\Image()\...
    Key.s
    FileName.s
    Size.i
    Width.i
    Height.i
    Indent.i
    Flags.i
  EndStructure ;}
  
  Structure Content_Link_Structure       ;{ VGEx()\Content\Link()\...
    String.s
    Url.s
    Label.s
    X.i
    Y.i
    Width.i
    Height.i
    Style.s
    Flags.i
  EndStructure ;}
  
  Structure Content_Text_Structure       ;{ VGEx()\Content\Text\...
    String.s
    Style.s
    ImageKey.s
    Padding.i
    Flags.i
  EndStructure ;}

  Structure Content_Label_Item_Structure ;{ VGEx()\Content\Label('key')\Item()\...
    Type.i
    Idx.i
    Spacing.i
  EndStructure ;}
  
  Structure Content_Label_Structure      ;{ VGEx()\Content\Label('key')\...
    Pattern.s
    File.s
    Size.i
    List Item.Content_Label_Item_Structure()
    List Link.Content_Link_Structure()
    Map  Offset.i() ; Offset for heading numbering 
    Margin.Content_Margins_Structure
  EndStructure ;}  
  
  
  Structure ViewerEx_Content_Structure   ;{ VGEx()\Content\...
    List Image.Content_Image_Structure()
    List Text.Content_Text_Structure()
    List Tree.Content_Tree_Structure()
    Map  Font.Content_Font_Structure()
    Map  Heading.Content_Heading_Structure()
    Map  Style.Content_Style_Structure()
    Map  Label.Content_Label_Structure()
  EndStructure ;}
  
  Structure ViewerEx_Structure           ;{ VGEx('GNum')\...
    ID.s
    Quad.i
    
    CanvasNum.i

    FontID.i
    Indent.i
    ReDraw.i
    Cursor.i
    Hide.i
    
    EventValue.s
    Label.s ; Label for current content
    Pattern.s  ; Language code for hyphenation

    Color.ViewerEx_Color_Structure
    Content.ViewerEx_Content_Structure
    ScrollBar.ViewerEx_ScrollBar_Structure
    Size.ViewerEx_Size_Structure
    Window.ViewerEx_Window_Structure
    
    Map  Heading.i()
    
    Flags.i
  EndStructure ;}
  Global NewMap VGEx.ViewerEx_Structure()
  
  CompilerIf #Enable_CreateViewerContent

    Global NewMap Label.s()
    Global NewMap Content.ViewerEx_Content_Structure()   ; Content('CNum')\...
    
    Global Color.ViewerEx_Color_Structure
    
    Color\Front     = $000000
    Color\Back      = $FFFFFF
    Color\ScrollBar = $C8C8C8
    Color\Border    = $E3E3E3
    
    CompilerSelect  #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
        Color\Back          = GetSysColor_(#COLOR_WINDOW)
        Color\ScrollBar     = GetSysColor_(#COLOR_MENU)
        Color\Border        = GetSysColor_(#COLOR_ACTIVEBORDER)
      CompilerCase #PB_OS_MacOS  
        Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
        Color\Back          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
        Color\ScrollBar     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
        Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
      CompilerCase #PB_OS_Linux
    
    CompilerEndSelect
    
  CompilerEndIf
  
  ;- ==========================================================================
  ;-   Module - Internal 
  ;- ==========================================================================  
  
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
  
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  Procedure.i LoadPackImage_(Pack.i, FileName.s, Size.i)
    Define.i ImgNum
    Define *Buffer
    
    If Size
      *Buffer = AllocateMemory(Size)
      If *Buffer
        If UncompressPackMemory(Pack, *Buffer, Size, FileName) <> -1
          ImgNum = CatchImage(#PB_Any, *Buffer, Size)
        EndIf
        FreeMemory(*Buffer)
      EndIf  
    EndIf
    
    ProcedureReturn ImgNum
  EndProcedure
  
  ;- __________ WordWrap __________
  
  CompilerIf #Enable_Hyphenation
    ;/ ===== Word Hy-phen-a-tion =====
    ;/ Algorithm of Frankling Mark Liang (1983)
    ;/ based on "hyphenator for HTML" (Mathias Nater, Zürich)
    
    Procedure.s HyphenateWord_(Word.s, Separator.s=#Hyphen$)
      Define.i c, i, ins 
      Define.i WordLen, WordIdx, Digits
      Define.s LWord, Chars, Pattern
      Define   Char.s{1}

      If FindMapElement(Hyphen(), VGEx()\Pattern) = #False
        Debug "ERROR: Hyphen patterns are required"
        ProcedureReturn Word
      EndIf
      
      Word    = "_"+Word+"_" ; Mark start and end of word
      LWord   = LCase(Word)  ; Lowercase word
      WordLen = Len(Word)    ; Word length
      
      Dim hyphPos.s(WordLen)
      
      ForEach Hyphen()\Pattern()  ;{ Evaluate pattern
        
        Chars   = StringField(Hyphen()\Pattern(), 1, ":")
        Pattern = StringField(Hyphen()\Pattern(), 2, ":")
        
        WordIdx = FindString(LWord, Chars, 1)
        If WordIdx
          
          Digits = 1
          
          For c = 1 To Len(Pattern)
            Char = Mid(Pattern, c, 1)
            If Char >= "0" And Char <= "9"
              
              If c = 1
                i = WordIdx
              Else
                i = WordIdx + c - Digits
              EndIf
              
              If hyphPos(i) = "" Or hyphPos(i) < Char ; Overwrite a smaller number
                hyphPos(i) = Char
              EndIf
              
              Digits + 1
            EndIf 
          Next
          
        EndIf
        ;}
      Next
      
      ;{ Create separation pattern
      ins = 0               
      For c = 3 To WordLen - 2
        If Val(hyphPos(c))
          Word = InsertString(Word, hyphPos(c), c + ins)
          ins + 1
        EndIf
      Next ;}
      
      Word = Trim(Word, "_") ; Remove marker for beginning and end of word
      For c = 1 To 9         ;{ Determine separation points (odd numbers)
        If (c % 2)
          ; separation point
          Word = ReplaceString(Word, Str(c), Separator)
        Else                
          ; no separation point
          Word = RemoveString(Word, Str(c))
        EndIf
      Next ;}
      
      ProcedureReturn Word
    EndProcedure
    
    Procedure   Hyphenation_(Text.s, Width.i, List Rows.s())
      Define.i w, h, Words, Hyphen, Pos, HyphenPos
      Define.s Word$, Part$, HyphenWord$, LF$
      
      ClearList(Rows())
      
      If AddElement(Rows())
        Words = CountString(Text, " ") + 1
        If Words > 1
          
          For w=1 To Words
            
            Word$ = StringField(Text, w, " ")
            If Right(Word$, 1) = #LF$
              Word$ = RTrim(Word$, #LF$)
              LF$ = #LF$
            Else
              LF$ = ""
            EndIf
            
            If TextWidth(Rows() + " " + Word$) > Width
              
              HyphenWord$ = HyphenateWord_(Word$, #Hyphen$)
              
              Hyphen = CountString(HyphenWord$, #Hyphen$)
              If Hyphen And TextWidth(Rows() + " " + StringField(HyphenWord$, 1, #Hyphen$) + "-") <= Width

                HyphenPos = 0
                Part$ = ""
                
                For h = 1 To Hyphen
                  Pos = FindString(HyphenWord$, #Hyphen$, HyphenPos + 1)
                  Part$ = RemoveString(Left(HyphenWord$, Pos), #Hyphen$)
                  If TextWidth(Rows() + " " + Part$ + "-") <= Width
                    HyphenPos = Pos
                    Word$ = Part$ + "-"
                  Else
                    Rows() + " " + Word$ + LF$
                    If AddElement(Rows()) : Rows() = RemoveString(Mid(HyphenWord$, HyphenPos), #Hyphen$) + LF$ :  EndIf
                    Break
                  EndIf
                Next
                
              Else
                If AddElement(Rows()) : Rows() = Word$ + LF$ :  EndIf
              EndIf
              
            Else
              Rows() + " " + Word$ + LF$
            EndIf         
          Next
          
        Else
          Rows() = Text + LF$
        EndIf
      EndIf 
      
    EndProcedure

  CompilerEndIf
  
  Procedure WordWrap_(Text.s, Width.i, List Rows.s())
    Define.i w, Words
    Define.s Word$
    
    ClearList(Rows())
    
    If AddElement(Rows())
      Words = CountString(Text, " ") + 1
      If Words > 1
        For w=1 To Words
          Word$ = StringField(Text, w, " ")
          If TextWidth(Rows() + " " + Word$) > Width
            If AddElement(Rows()) : Rows() = Word$ :  EndIf
          Else
            Rows() + " " + Word$
          EndIf         
        Next
      Else
        Rows() = Text
      EndIf
    EndIf 
    
  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure.f Justified_(Text.s, Indent.i=0)
    Define.i Spaces, Width
    Define.f sWidth
    
    Width = VGEx()\Size\Width - Indent - VGEx()\Content\Label()\Margin\Left - VGEx()\Content\Label()\Margin\Right
    
    Spaces = CountString(Text, " ")
    
    If Spaces
      sWidth = (Width - TextWidth(Text)) / Spaces
      If Right(Text, 1) <> #LF$
        ProcedureReturn sWidth
      EndIf
    EndIf
    
    ProcedureReturn 0
  EndProcedure
  
  Procedure.f AlignX_(Text.s, Indent.i=0, Flags.i=#Left)
    Define.i Width, Margin.i
    
    Width = VGEx()\Size\Width - Indent - VGEx()\Content\Label()\Margin\Left - VGEx()\Content\Label()\Margin\Right
    
    If Flags & #Center
      ProcedureReturn (Width - TextWidth(Text)) / 2
    ElseIf Flags & #Right
      ProcedureReturn Width - TextWidth(Text) - VGEx()\Content\Label()\Margin\Right - VGEx()\Size\X 
    Else
      ProcedureReturn Indent + VGEx()\Content\Label()\Margin\Left
    EndIf  
    
  EndProcedure  
  
  Procedure   DrawingFont_(FontKey.s)
    
    If FindMapElement(Resource\Font(), FontKey)
      If IsFont(Resource\Font()\Num)
        DrawingFont(FontID(Resource\Font()\Num))
      Else
        DrawingFont(VGEx()\FontID)
      EndIf
    Else
      DrawingFont(VGEx()\FontID)
    EndIf
    
  EndProcedure
  
  Procedure   DrawText_(X.i, Y.i, Text.s, FrontColor.i, BackColor.i)
    
    
    If BackColor <> #PB_Default
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(X, Y, Text, FrontColor)
    Else  
      DrawingMode(#PB_2DDrawing_Default)
      DrawText(X, Y, Text, FrontColor, BackColor)
    EndIf
    
  EndProcedure 
  
  Procedure   Draw_(visible.i=#True)
    Define.i X, Y, aX, txtHeight, sWidth, txtWidth, itemHeight, imgOffset
    Define.i p, w, i, Paragraphs, Items, Row, Words, Level, Indent, listIdent
    Define.i Image, imgX, imgY, imgWidth, imgHeight
    Define.i FrontColor, BackColor
    Define.f Factor
    Define.s Text, Word, Number
    
    NewList Rows.s()
    
    If VGEx()\Hide : ProcedureReturn #False : EndIf
    
    If StartDrawing(CanvasOutput(VGEx()\CanvasNum))
      
      If FindMapElement(VGEx()\Content\Label(), VGEx()\Label)
      
        X = VGEx()\Size\X + VGEx()\Content\Label()\Margin\Left
        Y = VGEx()\Size\Y + VGEx()\Content\Label()\Margin\Top - VGEx()\Size\OffSet
        
        ClearMap(VGEx()\Heading())
        ForEach VGEx()\Content\Label()\Offset()
          VGEx()\Heading(MapKey(VGEx()\Content\Label()\Offset())) = VGEx()\Content\Label()\Offset()
        Next
      
        ;{ _____ BackGround _____
        If visible 
          DrawingMode(#PB_2DDrawing_Default)
          Box(0, 0, dpiX(GadgetWidth(VGEx()\CanvasNum)), dpiY(GadgetHeight(VGEx()\CanvasNum)), VGEx()\Color\Back)
        EndIf
        ;}
      
        ForEach VGEx()\Content\Label()\Item()
          
          Image      = 0
          imgOffset  = 0
          itemHeight = 0
          
          Select VGEx()\Content\Label()\Item()\Type
            Case #Heading    ;{ draw Heading
              
              If SelectElement(VGEx()\Content\Text(), VGEx()\Content\Label()\Item()\Idx)
                
                If FindMapElement(VGEx()\Content\Heading(), VGEx()\Content\Text()\Style) = #False
                  FindMapElement(VGEx()\Content\Heading(), Str(#PB_Default))
                EndIf
                
                If VGEx()\Content\Heading()\FrontColor <> #PB_Default
                  FrontColor = VGEx()\Content\Heading()\FrontColor
                Else
                  FrontColor = VGEx()\Color\Front
                EndIf  
                
                DrawingFont_(VGEx()\Content\Heading()\FontKey)
                
                Text  = VGEx()\Content\Text()\String
                Level = VGEx()\Content\Heading()\Level
                
                VGEx()\Heading(Str(Level)) + 1
                
                Number = Str(VGEx()\Heading("0")) + "." ;{ Number for Heading
                If Level 
                  For i=1 To Level
                    Number + Str(VGEx()\Heading(Str(i))) + "."
                  Next
                  Number = RTrim(Number, ".")
                EndIf ;}
                Text   = Number + " " + Text
                
                txtHeight = TextHeight(Text)
                
                aX = AlignX_(Text, VGEx()\Content\Heading()\Indent, VGEx()\Content\Text()\Flags)
                If visible : DrawText_(X + aX, Y, Text, FrontColor, BackColor) : EndIf 
                
                VGEx()\Indent = VGEx()\Content\Heading()\Indent + TextWidth(Number + " ")
                
                Y + txtHeight + VGEx()\Content\Heading()\Spacing
              EndIf
              ;}
            Case #Image      ;{ draw image
              
              If SelectElement(VGEx()\Content\Image(), VGEx()\Content\Label()\Item()\Idx)
                If FindMapElement(Resource\Image(), VGEx()\Content\Image()\Key)
                  
                  If IsImage(Resource\Image()\Num)
                    
                    Indent = VGEx()\Content\Image()\Indent
                    If VGEx()\Content\Image()\Flags & #AutoIndent : Indent = VGEx()\Indent : EndIf
                    
                    If VGEx()\Content\Image()\Flags & #Center
                      aX = (VGEx()\Size\Width - Indent - VGEx()\Content\Image()\Width) / 2
                    ElseIf VGEx()\Content\Image()\Flags & #Right
                      aX = VGEx()\Size\Width - VGEx()\Content\Image()\Width - VGEx()\Size\X
                    Else
                      aX = Indent
                    EndIf
                    
                    If visible
                      DrawingMode(#PB_2DDrawing_AlphaBlend)
                      DrawImage(ImageID(Resource\Image()\Num), X + aX, Y, VGEx()\Content\Image()\Width, VGEx()\Content\Image()\Height)
                    EndIf
                    
                    Y + VGEx()\Content\Image()\Height
                  EndIf
                  
                EndIf 
              EndIf
              ;}
            Case #List       ;{ draw list
              
              If SelectElement(VGEx()\Content\Text(), VGEx()\Content\Label()\Item()\Idx)
                
                If FindMapElement(VGEx()\Content\Style(), VGEx()\Content\Text()\Style) = #False
                  FindMapElement(VGEx()\Content\Style(), Str(#PB_Default))
                EndIf
                
                If VGEx()\Content\Style()\FrontColor <> #PB_Default
                  FrontColor = VGEx()\Content\Style()\FrontColor
                Else
                  FrontColor = VGEx()\Color\Front
                EndIf  
                
                If  VGEx()\Content\Style()\BackColor <> #PB_Default
                  BackColor = VGEx()\Content\Style()\BackColor
                Else
                  BackColor = VGEx()\Color\Back
                EndIf  
                
                DrawingFont_(VGEx()\Content\Style()\FontKey)
                
                Indent = VGEx()\Content\Style()\Indent
                If VGEx()\Content\Text()\Flags & #AutoIndent : Indent = VGEx()\Indent : EndIf
                
                listIdent = TextWidth(#Bullet$ + " ")
                txtHeight = TextHeight("Abc")
                txtWidth  = VGEx()\Size\Width - Indent - VGEx()\Content\Label()\Margin\Left - VGEx()\Content\Label()\Margin\Right - listIdent
                
                If FindMapElement(Resource\Image(), VGEx()\Content\Text()\ImageKey)
                  If IsImage(Resource\Image()\Num)
                    Image     = Resource\Image()\Num
                    imgX      = X + Indent
                    
                    If dpiY(ImageHeight(Resource\Image()\Num)) <= txtHeight
                      imgHeight = dpiY(ImageHeight(Resource\Image()\Num))
                      imgWidth  = dpiX(ImageWidth(Resource\Image()\Num))
                    Else  
                      imgHeight = txtHeight
                      Factor    = imgHeight / dpiY(ImageHeight(Resource\Image()\Num))
                      imgWidth  = dpiX(ImageWidth(Resource\Image()\Num)) * Factor
                    EndIf
                    
                    imgOffset = dpiX(VGEx()\Content\Text()\Padding) + imgWidth
                    listIdent = imgOffset + TextWidth(" ")
                    txtWidth  - imgOffset
                  EndIf
                EndIf  
                
                Items = CountString(VGEx()\Content\Text()\String, #LF$) + 1
                For p=1 To Items
                  
                  imgY = Y
                  
                  DrawingMode(#PB_2DDrawing_Transparent)
                  
                  Text = StringField(VGEx()\Content\Text()\String, p, #LF$)

                  If TextWidth(Text) > txtWidth ;{ Text length greater than page width
                    
                    CompilerIf #Enable_Hyphenation
  
                      If FindMapElement(Hyphen(), VGEx()\Pattern)
                        Hyphenation_(Text + #LF$, txtWidth, Rows())
                      Else
                        WordWrap_(Text + #LF$, txtWidth, Rows())
                      EndIf
                      
                    CompilerElse
                      
                      WordWrap_(Text + #LF$, txtWidth, Rows())
                      
                    CompilerEndIf
                  
                    ForEach Rows()

                      Rows() = LTrim(Rows())
                      
                      If VGEx()\Content\Text()\Flags & #Justified
                        
                        aX     = Indent
                        Words  = CountString(Rows(), " ") + 1
                        sWidth = Justified_(Rows(), Indent + listIdent)
                        
                        Rows() = RemoveString(Rows(), #LF$)
                        
                        If ListIndex(Rows()) = 0
                          If visible And Not Image
                            DrawText_(X + aX, Y, #Bullet$ + " ", FrontColor, BackColor)  
                          EndIf
                        EndIf
                        
                        ax + listIdent
                        
                        For w=1 To Words
                          Word = StringField(Rows(), w, " ")
                          If visible : DrawText_(X + aX, Y, Word, FrontColor, BackColor) : EndIf
                          ax + TextWidth(Word + " ") + sWidth
                        Next
  
                      Else
                        
                        Rows() = RemoveString(Rows(), #LF$)

                        aX = Indent
                        
                        If ListIndex(Rows()) = 0
                          If visible And Not Image
                            DrawText_(X + aX, Y, #Bullet$ + " ", FrontColor, BackColor)
                          EndIf
                        EndIf
                        
                        ax + listIdent
                        
                        If visible : DrawText_(X + aX, Y, Rows(), FrontColor, BackColor) : EndIf
                        
                      EndIf
                      
                      Y + txtHeight
                    Next
                    ;}
                  Else                          ;{ Text length smaller than page width
                    
                    If VGEx()\Content\Text()\Flags & #Justified
                      
                      Text = RemoveString(Text, #LF$)
                      
                      aX     = Indent
                      Words  = CountString(Text, " ") + 1
                      sWidth = Justified_(Text, Indent + listIdent)
                      
                      If visible And Not Image
                        DrawText_(X + aX, Y, #Bullet$ + " ", FrontColor, BackColor)
                      EndIf
                      ax + listIdent
                      
                      For w=1 To Words
                        Word = StringField(Text, w, " ")
                        If visible : DrawText_(X + aX, Y, Word, FrontColor, BackColor) : EndIf
                        ax + TextWidth(Word) + sWidth
                      Next
                  
                    Else
                      
                      Text = RemoveString(Text, #LF$)
                      
                      aX = AlignX_(Text, Indent, VGEx()\Content\Text()\Flags)

                      If visible And Not Image
                        DrawText_(X + aX, Y, #Bullet$ + " ", FrontColor, BackColor)
                      EndIf
                      
                      ax + listIdent
                      
                      If visible : DrawText_(X + aX, Y, Text, FrontColor, BackColor) : EndIf
                      
                    EndIf
                    
                    Y + txtHeight
                    ;}
                  EndIf
                  
                  If Image
                    DrawingMode(#PB_2DDrawing_AlphaBlend)
                    DrawImage(ImageID(Image), imgX, imgY, imgWidth, imgHeight)
                  EndIf 

                Next

                If VGEx()\Content\Label()\Item()\Spacing = #PB_Default
                  Y + txtHeight
                Else
                  Y + VGEx()\Content\Label()\Item()\Spacing
                EndIf
                
              EndIf
              ;}
            Case #Spacing    ;{ row spacing
              Y + VGEx()\Content\Label()\Item()\Spacing
              ;}
            Case #Text       ;{ draw text
              
              If SelectElement(VGEx()\Content\Text(), VGEx()\Content\Label()\Item()\Idx)
                
                If FindMapElement(VGEx()\Content\Style(), VGEx()\Content\Text()\Style) = #False
                  FindMapElement(VGEx()\Content\Style(), Str(#PB_Default))
                EndIf
                
                If VGEx()\Content\Style()\FrontColor <> #PB_Default
                  FrontColor = VGEx()\Content\Style()\FrontColor
                Else
                  FrontColor = VGEx()\Color\Front
                EndIf  
                
                If  VGEx()\Content\Style()\BackColor <> #PB_Default
                  BackColor = VGEx()\Content\Style()\BackColor
                Else
                  BackColor = VGEx()\Color\Back
                EndIf  
                
                DrawingFont_(VGEx()\Content\Style()\FontKey)
                
                Indent = VGEx()\Content\Style()\Indent
                If VGEx()\Content\Text()\Flags & #AutoIndent : Indent = VGEx()\Indent : EndIf
                
                txtWidth = VGEx()\Size\Width - Indent - VGEx()\Content\Label()\Margin\Left - VGEx()\Content\Label()\Margin\Right
                
                If FindMapElement(Resource\Image(), VGEx()\Content\Text()\ImageKey)
                  If IsImage(Resource\Image()\Num)
                    Image     = Resource\Image()\Num
                    imgX      = X + Indent
                    imgY      = Y
                    imgWidth  = dpiX(ImageWidth(Resource\Image()\Num))
                    imgHeight = dpiY(ImageHeight(Resource\Image()\Num))
                    imgOffset = dpiX(VGEx()\Content\Text()\Padding) + imgWidth
                    txtWidth  - imgOffset
                  EndIf
                EndIf  
                
                DrawingMode(#PB_2DDrawing_Transparent)
                
                Paragraphs = CountString(VGEx()\Content\Text()\String, #LF$) + 1
                For p=1 To Paragraphs
                  
                  Text = StringField(VGEx()\Content\Text()\String, p, #LF$)
                  txtHeight = TextHeight(Text)
                  
                  If TextWidth(Text) > txtWidth ;{ Text length greater than page width
                    
                    CompilerIf #Enable_Hyphenation
  
                      If FindMapElement(Hyphen(), VGEx()\Pattern)
                        Hyphenation_(Text + #LF$, txtWidth, Rows())
                      Else
                        WordWrap_(Text + #LF$, txtWidth, Rows())
                      EndIf
                      
                    CompilerElse
                      
                      WordWrap_(Text + #LF$, txtWidth, Rows())
                      
                    CompilerEndIf
                  
                    ForEach Rows()

                      Rows() = LTrim(Rows())
                      
                      If VGEx()\Content\Text()\Flags & #Justified
                        
                        aX     = Indent + imgOffset
                        Words  = CountString(Rows(), " ") + 1
                        sWidth = Justified_(Rows(), Indent)
                        
                        Rows() = RemoveString(Rows(), #LF$)
                        
                        For w=1 To Words
                          Word = StringField(Rows(), w, " ")
                          If visible : DrawText_(X + aX, Y, Word, FrontColor, BackColor) : EndIf
                          ax + TextWidth(Word + " ") + sWidth
                        Next
  
                      Else
                        
                        Rows() = RemoveString(Rows(), #LF$)
                        
                        aX = AlignX_(LTrim(Rows()), Indent + imgOffset, VGEx()\Content\Text()\Flags)
                        If visible : DrawText_(X + aX, Y, Rows(), FrontColor, BackColor) : EndIf
                        
                      EndIf
                      
                      itemHeight + txtHeight
                      
                      Y + txtHeight
                    Next
                    ;}
                  Else                          ;{ Text length smaller than page width

                    If VGEx()\Content\Text()\Flags & #Justified
                      
                      aX     = Indent + imgOffset
                      Words  = CountString(Text, " ") + 1
                      sWidth = Justified_(Text, Indent)
                      
                      Text = RemoveString(Text, #LF$)
                      
                      For w=1 To Words
                        Word = StringField(Text, w, " ")
                        If visible : DrawText_(X + aX, Y, Word, FrontColor, BackColor) : EndIf
                        ax + TextWidth(Word) + sWidth
                      Next
                  
                    Else
                      
                      Text = RemoveString(Text, #LF$)
                      
                      aX = AlignX_(Text, Indent + imgOffset, VGEx()\Content\Text()\Flags)
                      If visible : DrawText_(X + aX, Y, Text, FrontColor, BackColor) : EndIf
                      
                    EndIf
                    
                    itemHeight + txtHeight
                    
                    Y + txtHeight
                    ;}
                  EndIf
  
                Next
                
                If Image
                  
                  If VGEx()\Content\Text()\Flags & #Middle
                    ImgY + ((itemHeight - imgHeight) / 2)
                  ElseIf VGEx()\Content\Text()\Flags & #Bottom
                    imgY + itemHeight - imgHeight
                  EndIf  
                  
                  DrawingMode(#PB_2DDrawing_AlphaBlend)
                  DrawImage(ImageID(Image), imgX, imgY)
                EndIf   
                
                If VGEx()\Content\Label()\Item()\Spacing = #PB_Default
                  Y + txtHeight
                Else
                  Y + VGEx()\Content\Label()\Item()\Spacing
                EndIf 
                
              EndIf
              ;}
            Case #URL, #Link ;{ draw url / link
           
              If SelectElement(VGEx()\Content\Label()\Link(), VGEx()\Content\Label()\Item()\Idx)
                
                If FindMapElement(VGEx()\Content\Style(), VGEx()\Content\Label()\Link()\Style) = #False
                  FindMapElement(VGEx()\Content\Style(), Str(#PB_Default))
                EndIf
                
                If VGEx()\Content\Style()\FrontColor <> #PB_Default
                  FrontColor = VGEx()\Content\Style()\FrontColor
                Else
                  FrontColor = VGEx()\Color\Front
                EndIf
                
                If  VGEx()\Content\Style()\BackColor <> #PB_Default
                  BackColor = VGEx()\Content\Style()\BackColor
                Else
                  BackColor = VGEx()\Color\Back
                EndIf  
                
                DrawingFont_(VGEx()\Content\Style()\FontKey)
                
                Indent = VGEx()\Content\Style()\Indent
                If VGEx()\Content\Label()\Link()\Flags & #AutoIndent : Indent = VGEx()\Indent : EndIf
                
                Text      = RemoveString(VGEx()\Content\Label()\Link()\String, #LF$)
                txtHeight = TextHeight(Text)
                txtWidth  = VGEx()\Size\Width - Indent - VGEx()\Content\Label()\Margin\Left - VGEx()\Content\Label()\Margin\Right

                aX = AlignX_(Text, Indent, VGEx()\Content\Label()\Link()\Flags)
                If visible
                  DrawText_(X + aX, Y, Text, FrontColor, BackColor)
                  Line(X + aX, Y + txtHeight - 1, TextWidth(Text), 1, FrontColor)
                EndIf
                
                VGEx()\Content\Label()\Link()\X = X + aX
                VGEx()\Content\Label()\Link()\Y = Y
                VGEx()\Content\Label()\Link()\Width  = TextWidth(Text)
                VGEx()\Content\Label()\Link()\Height = txtHeight
                
                If VGEx()\Content\Label()\Item()\Spacing = #PB_Default
                  Y + txtHeight
                Else
                  Y + VGEx()\Content\Label()\Item()\Spacing
                EndIf
                
                Y + txtHeight
                
              EndIf
              ;}
          EndSelect
          
        Next
      
        VGEx()\Size\Content = Y + VGEx()\Size\OffSet + VGEx()\Content\Label()\Margin\Bottom
        
        If IsGadget(VGEx()\ScrollBar\Num)
          SetGadgetAttribute(VGEx()\ScrollBar\Num, #PB_ScrollBar_Maximum, VGEx()\Size\Content)
        EndIf
      
        ;{ _____ Bottom margin _____
        If visible
          DrawingMode(#PB_2DDrawing_Default)
          Box(0, dpiY(GadgetHeight(VGEx()\CanvasNum) - VGEx()\Content\Label()\Margin\Bottom - 4), dpiX(GadgetWidth(VGEx()\CanvasNum)), dpiY(VGEx()\Content\Label()\Margin\Bottom + 4), VGEx()\Color\Back)
        EndIf ;}
      
        ;{ _____ Border ____
        If VGEx()\Flags & #Borderless = #False
          If visible
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(1, 1, dpiX(GadgetWidth(VGEx()\CanvasNum)) - 2, dpiY(GadgetHeight(VGEx()\CanvasNum)) - 2, VGEx()\Color\Back)
            Box(0, 0, dpiX(GadgetWidth(VGEx()\CanvasNum)), dpiY(GadgetHeight(VGEx()\CanvasNum)), VGEx()\Color\Border)
          EndIf
        EndIf
        ;}      
        
      EndIf  
     
      StopDrawing()
    EndIf  
    
  EndProcedure  
  
  Procedure   ReDraw_()
 
    If VGEx()\ReDraw
      
      Draw_(#False) ; Calc only
      
      If IsGadget(VGEx()\ScrollBar\Num)
        If VGEx()\ScrollBar\Hide And VGEx()\Size\Content > VGEx()\Size\Height - VGEx()\Content\Label(VGEx()\Label)\Margin\Bottom
          VGEx()\Size\Width = dpiX(GadgetWidth(VGEx()\CanvasNum) - #Scroll_Width - 10)
          HideGadget(VGEx()\ScrollBar\Num, #False)  
          VGEx()\ScrollBar\Hide = #False
        ElseIf Not VGEx()\ScrollBar\Hide And VGEx()\Size\Content <= VGEx()\Size\Height - VGEx()\Content\Label(VGEx()\Label)\Margin\Bottom
          VGEx()\Size\Width = dpiX(GadgetWidth(VGEx()\CanvasNum) - 8)
          HideGadget(VGEx()\ScrollBar\Num, #True)
          VGEx()\Size\OffSet    = 0
          VGEx()\ScrollBar\Hide = #True
        EndIf
        SetGadgetAttribute(VGEx()\ScrollBar\Num, #PB_ScrollBar_PageLength, VGEx()\Size\Height + dpiX(8))
      EndIf
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  ;- __________ Events __________  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach VGEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          VGEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        VGEx()\Color\Front     = ModuleEx::ThemeGUI\FrontColor
        VGEx()\Color\Back      = ModuleEx::ThemeGUI\BackColor
        VGEx()\Color\ScrollBar = ModuleEx::ThemeGUI\ScrollbarColor
        VGEx()\Color\Border    = ModuleEx::ThemeGUI\BorderColor

        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf   
  
  
  Procedure _LeftClickHandler()
    Define.i X, Y
    Define.i GNum = EventGadget()
    
    X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
    Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
    
    If FindMapElement(VGEx(), Str(GNum))
      If FindMapElement(VGEx()\Content\Label(), VGEx()\Label)
        ForEach VGEx()\Content\Label()\Link()
          If Y >= VGEx()\Content\Label()\Link()\Y And Y < VGEx()\Content\Label()\Link()\Y + VGEx()\Content\Label()\Link()\Height
            If X >= VGEx()\Content\Label()\Link()\X And X < VGEx()\Content\Label()\Link()\X + VGEx()\Content\Label()\Link()\Width
              If IsWindow(VGEx()\Window\Num)
                If VGEx()\Content\Label()\Link()\Url
                  VGEx()\EventValue = VGEx()\Content\Label()\Link()\Url
                  PostEvent(#PB_Event_Gadget, VGEx()\Window\Num, VGEx()\CanvasNum, #EventType_Link)
                ElseIf VGEx()\Content\Label()\Link()\Label
                  VGEx()\Label   = VGEx()\Content\Label()\Link()\Label
                  VGEx()\Pattern = VGEx()\Content\Label(VGEx()\Label)\Pattern
                  ReDraw_()
                EndIf  
              EndIf
              Break
            EndIf
          EndIf
        Next
      EndIf
    EndIf 
  
  EndProcedure
  
  Procedure _MouseMoveHandler()
    Define.i X, Y, Cursor
    Define.i GNum = EventGadget()
    
    X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
    Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
    
    If FindMapElement(VGEx(), Str(GNum))
      If FindMapElement(VGEx()\Content\Label(), VGEx()\Label)
        
        Cursor = #PB_Cursor_Default
        
        ForEach VGEx()\Content\Label()\Link()
          If Y >= VGEx()\Content\Label()\Link()\Y And Y < VGEx()\Content\Label()\Link()\Y + VGEx()\Content\Label()\Link()\Height
            If X >= VGEx()\Content\Label()\Link()\X And X < VGEx()\Content\Label()\Link()\X + VGEx()\Content\Label()\Link()\Width
              Cursor = #PB_Cursor_Hand
              Break
            EndIf
          EndIf
        Next
        
        If VGEx()\Cursor <> Cursor
          SetGadgetAttribute(GNum, #PB_Canvas_Cursor, Cursor)
          VGEx()\Cursor = Cursor
        EndIf
        
      EndIf
    EndIf  
    
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i GNum = EventGadget()
    Define.i ScrollPos, Delta, maxOffset
    
    If FindMapElement(VGEx(), Str(GNum))
      
      Delta = GetGadgetAttribute(GNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(VGEx()\ScrollBar\Num)
        
        maxOffset = VGEx()\Size\Content - VGEx()\Size\Height - dpiY(8) + 1
        If maxOffset < 0 : maxOffset = 0 : EndIf
        
        VGEx()\Size\OffSet = GetGadgetState(VGEx()\ScrollBar\Num) - Delta * dpiY(10)

        If VGEx()\Size\OffSet < 0 : VGEx()\Size\OffSet = 0 : EndIf
        If VGEx()\Size\OffSet > maxOffset : VGEx()\Size\OffSet = maxOffset : EndIf
        
        If VGEx()\Size\OffSet <> VGEx()\ScrollBar\Pos
          VGEx()\ScrollBar\Pos = VGEx()\Size\OffSet
          SetGadgetState(VGEx()\ScrollBar\Num, VGEx()\Size\OffSet)
          Draw_()
        EndIf
        
      EndIf

    EndIf
    
  EndProcedure
  
  Procedure _ResizeHandler()
    Define.i OffsetX, OffSetY
    Define.i GNum = EventGadget()
    
    If FindMapElement(VGEx(), Str(GNum))
      
      If VGEx()\ScrollBar\Hide
        VGEx()\Size\Width  = dpiX(GadgetWidth(GNum)  - 8)
        VGEx()\Size\Height = dpiY(GadgetHeight(GNum) - 8)
      Else
        VGEx()\Size\Width  = dpiX(GadgetWidth(GNum) - #Scroll_Width - 10)
        VGEx()\Size\Height = dpiY(GadgetHeight(GNum) - 8)
      EndIf
      
      If IsGadget(VGEx()\ScrollBar\Num)
        ResizeGadget(VGEx()\ScrollBar\Num, GadgetWidth(GNum) - #Scroll_Width - 2, 2, #Scroll_Width, GadgetHeight(GNum) - 4)
        SetGadgetAttribute(VGEx()\ScrollBar\Num, #PB_ScrollBar_PageLength, GadgetHeight(GNum))
      EndIf
      
      ReDraw_()
      
    EndIf
    
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.i OffSetX, OffsetY

    ForEach VGEx()
      
      If IsGadget(VGEx()\CanvasNum)
       
        If VGEx()\Flags & #AutoResize
          
          If IsWindow(VGEx()\Window\Num)
            
            OffSetX = WindowWidth(VGEx()\Window\Num)  - VGEx()\Window\Width
            OffsetY = WindowHeight(VGEx()\Window\Num) - VGEx()\Window\Height
            
            VGEx()\Window\Width  = WindowWidth(VGEx()\Window\Num)
            VGEx()\Window\Height = WindowHeight(VGEx()\Window\Num)
            
            If VGEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width  = #PB_Ignore : Height = #PB_Ignore
              
              If VGEx()\Size\Flags & #MoveX : X = GadgetX(VGEx()\CanvasNum) + OffSetX : EndIf
              If VGEx()\Size\Flags & #MoveY : Y = GadgetY(VGEx()\CanvasNum) + OffSetY : EndIf
              If VGEx()\Size\Flags & #ResizeWidth  : Width  = GadgetWidth(VGEx()\CanvasNum)  + OffSetX : EndIf
              If VGEx()\Size\Flags & #ResizeHeight : Height = GadgetHeight(VGEx()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(VGEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              
              ResizeGadget(VGEx()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(VGEx()\CanvasNum) + OffSetX, GadgetHeight(VGEx()\CanvasNum) + OffsetY)
              
            EndIf
            
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure _SynchronizeScrollBar()
    Define.i ScrollBar = EventGadget()
    Define.i GNum = GetGadgetData(ScrollBar)
    Define.i ScrollPos, OffSet, maxOffset, Margins
    
    If FindMapElement(VGEx(), Str(GNum))
      
      Margins  = VGEx()\Content\Label(VGEx()\Label)\Margin\Top + VGEx()\Content\Label(VGEx()\Label)\Margin\Bottom + dpiY(8)
      
      maxOffset = VGEx()\Size\Content - VGEx()\Size\Height - Margins + 1
      If maxOffset < 0 : maxOffset = 0 : EndIf
      
      ScrollPos = GetGadgetState(ScrollBar)
      If ScrollPos <> VGEx()\ScrollBar\Pos
        
        If ScrollPos < VGEx()\ScrollBar\Pos
          VGEx()\Size\OffSet = ScrollPos - dpiY(10)
        ElseIf ScrollPos > VGEx()\ScrollBar\Pos
          VGEx()\Size\OffSet = ScrollPos + Margins + dpiY(10)
        EndIf
        
        If VGEx()\Size\OffSet < 0 : VGEx()\Size\OffSet = 0 : EndIf
        If VGEx()\Size\OffSet > maxOffset : VGEx()\Size\OffSet = maxOffset : EndIf
        
        VGEx()\ScrollBar\Pos = VGEx()\Size\OffSet
        
        SetGadgetState(ScrollBar, VGEx()\Size\OffSet)
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  

  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  ;- _____ Add Ressources _____ 
  
  CompilerIf #Enable_AddViewerContent Or #Enable_CreateViewerContent

    Procedure.s UseImage(File.s, ImageKey.s="") 
      Define.i ImgNum
      
      If ImageKey = "" : ImageKey = GetFilePart(File) : EndIf 
      
      ImgNum = LoadImage(#PB_Any, File)
      If ImgNum
        If AddMapElement(Resource\Image(), ImageKey)
          Resource\Image()\Num  = ImgNum
          Resource\Image()\File = File
          Resource\Image()\Size = FileSize(File)
          ProcedureReturn ImageKey
        EndIf 
      EndIf
      
      ProcedureReturn ""
    EndProcedure  

    Procedure.s UseFont(Name.s, Size.i, Flags.i=#False, FontKey.s="")
      Define.i FontNum
      
      If FontKey = "" : FontKey = Name + "|" + Str(Size) + "|" + Str(Flags) : EndIf
      
      FontNum = LoadFont(#PB_Any, Name, Size, Flags)
      If FontNum
        If AddMapElement(Resource\Font(), FontKey)
          Resource\Font()\Num   = FontNum
          Resource\Font()\Name  = Name
          Resource\Font()\Size  = Size
          Resource\Font()\Flags = Flags
          ProcedureReturn FontKey
        EndIf 
      EndIf
      
      ProcedureReturn ""
    EndProcedure    
    
  CompilerEndIf  
  
  ;- _____ Add Viewer Content _____ 
  
  CompilerIf #Enable_AddViewerContent

    Procedure.i AddHeading(GNum.i, Text.s, HeadingKey.s, Flags.i=#Left)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())

          VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #Heading
          
          If AddElement(VGEx()\Content\Text())
            
            VGEx()\Content\Label(VGEx()\Label)\Item()\Idx = ListIndex(VGEx()\Content\Text())
            VGEx()\Content\Text()\String = Text
            VGEx()\Content\Text()\Flags  = Flags
            
            If FindMapElement(VGEx()\Content\Heading(), HeadingKey)
              VGEx()\Content\Text()\Style = HeadingKey
            Else
              VGEx()\Content\Text()\Style = Str(#PB_Default)
            EndIf
            
            ReDraw_()
            
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn #False 
    EndProcedure      
    
    Procedure.i AddImage(GNum.i, ImageKey.s, Width.i=#PB_Default, Height.i=#PB_Default, Indent.i=0, Flags.i=#False)
      Define.i ImageNum
      
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If FindMapElement(Resource\Image(), ImageKey)

          If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())
            
            VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #Image
            
            If IsImage(Resource\Image()\Num)
              If Width  = #PB_Default : Width  = ImageWidth(Resource\Image()\Num)  : EndIf
              If Height = #PB_Default : Height = ImageHeight(Resource\Image()\Num) : EndIf
            EndIf
          
            If AddElement(VGEx()\Content\Image())
              
              VGEx()\Content\Label(VGEx()\Label)\Item()\Idx = ListIndex(VGEx()\Content\Image())
              VGEx()\Content\Image()\Key    = ImageKey
              VGEx()\Content\Image()\Width  = dpiX(Width)
              VGEx()\Content\Image()\Height = dpiY(Height)
              VGEx()\Content\Image()\Indent = dpiX(Indent)
              VGEx()\Content\Image()\Flags  = Flags
              
              ReDraw_()
              
              ProcedureReturn #True
            EndIf
            
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i AddImageText(GNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#Left)
      ; Spacing: #PB_Default = row height
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If Padding = #PB_Default : Padding = 10 : EndIf
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())

          VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #Text
          
          If AddElement(VGEx()\Content\Text())
            
            VGEx()\Content\Label(VGEx()\Label)\Item()\Idx     = ListIndex(VGEx()\Content\Text())
            VGEx()\Content\Label(VGEx()\Label)\Item()\Spacing = Spacing
            VGEx()\Content\Text()\String   = Text
            VGEx()\Content\Text()\ImageKey = ImageKey
            VGEx()\Content\Text()\Padding  = Padding
            VGEx()\Content\Text()\Flags    = Flags
            
            If FindMapElement(VGEx()\Content\Style(), StyleKey)
              VGEx()\Content\Text()\Style = StyleKey
            Else
              VGEx()\Content\Text()\Style = Str(#PB_Default)
            EndIf
            
            ReDraw_()
            
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i AddImageListing(GNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#False)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())

          VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #List
          
          If AddElement(VGEx()\Content\Text())
            
            VGEx()\Content\Label(VGEx()\Label)\Item()\Idx     = ListIndex(VGEx()\Content\Text())
            VGEx()\Content\Label(VGEx()\Label)\Item()\Spacing = Spacing
            VGEx()\Content\Text()\String   = Text
            VGEx()\Content\Text()\ImageKey = ImageKey
            VGEx()\Content\Text()\Padding  = Padding
            VGEx()\Content\Text()\Flags    = Flags
            
            If FindMapElement(VGEx()\Content\Style(), StyleKey)
              VGEx()\Content\Text()\Style = StyleKey
            Else
              VGEx()\Content\Text()\Style = Str(#PB_Default)
            EndIf
            
            ReDraw_()
            
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i AddLink(GNum.i, Text.s, Label.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())
          
          VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #URL
          
          If FindMapElement(VGEx()\Content\Label(), VGEx()\Label)
            If AddElement(VGEx()\Content\Label()\Link())
              
              VGEx()\Content\Label()\Item()\Idx     = ListIndex(VGEx()\Content\Label()\Link())
              VGEx()\Content\Label()\Item()\Spacing = Spacing
              VGEx()\Content\Label()\Link()\Label   = Label
              VGEx()\Content\Label()\Link()\String  = Text
              VGEx()\Content\Label()\Link()\Style   = StyleKey
              VGEx()\Content\Label()\Link()\Flags   = Flags
              
              ReDraw_()
              
              ProcedureReturn #True
            EndIf  
          EndIf
        EndIf
        
      EndIf
    EndProcedure
    
    Procedure.i AddListing(GNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#False)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())

          VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #List
          
          If AddElement(VGEx()\Content\Text())
            
            VGEx()\Content\Label(VGEx()\Label)\Item()\Idx     = ListIndex(VGEx()\Content\Text())
            VGEx()\Content\Label(VGEx()\Label)\Item()\Spacing = Spacing
            VGEx()\Content\Text()\String  = Text
            VGEx()\Content\Text()\Flags   = Flags
            
            If FindMapElement(VGEx()\Content\Style(), StyleKey)
              VGEx()\Content\Text()\Style = StyleKey
            Else
              VGEx()\Content\Text()\Style = Str(#PB_Default)
            EndIf
            
            ReDraw_()
            
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i AddURL(GNum.i, URL.s, StyleKey.s="", String.s="", Spacing.i=0, Flags.i=#Left)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If String = "" : String = URL : EndIf
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())
          
          VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #URL
          
          If FindMapElement(VGEx()\Content\Label(), VGEx()\Label)
            If AddElement(VGEx()\Content\Label()\Link())
              
              VGEx()\Content\Label()\Item()\Idx     = ListIndex(VGEx()\Content\Label()\Link())
              VGEx()\Content\Label()\Item()\Spacing = Spacing
              VGEx()\Content\Label()\Link()\Url     = URL
              VGEx()\Content\Label()\Link()\String  = String
              VGEx()\Content\Label()\Link()\Style   = StyleKey
              VGEx()\Content\Label()\Link()\Flags   = Flags
              
              ReDraw_()
              
              ProcedureReturn #True
            EndIf  
          EndIf
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure   AddSpacing(GNum.i, Height.i)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())
          
          VGEx()\Content\Label(VGEx()\Label)\Item()\Type    = #Spacing
          VGEx()\Content\Label(VGEx()\Label)\Item()\Spacing = Height
          
          ReDraw_()
        EndIf 
        
      EndIf
      
    EndProcedure    
    
    Procedure.i AddText(GNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)
      ; Spacing: #PB_Default = row height
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If AddElement(VGEx()\Content\Label(VGEx()\Label)\Item())

          VGEx()\Content\Label(VGEx()\Label)\Item()\Type = #Text
          
          If AddElement(VGEx()\Content\Text())
            
            VGEx()\Content\Label(VGEx()\Label)\Item()\Idx     = ListIndex(VGEx()\Content\Text())
            VGEx()\Content\Label(VGEx()\Label)\Item()\Spacing = Spacing
            VGEx()\Content\Text()\String  = Text
            VGEx()\Content\Text()\Flags   = Flags
            
            If FindMapElement(VGEx()\Content\Style(), StyleKey)
              VGEx()\Content\Text()\Style = StyleKey
            Else
              VGEx()\Content\Text()\Style = Str(#PB_Default)
            EndIf
            
            ReDraw_()
            
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    

    Procedure.i DefineHeading(GNum.i, HeadingKey.s, FontKey.s, Level.i=0, Spacing.i=0, Indent.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default, Flags.i=#Left)
      
      If FindMapElement(VGEx(), Str(GNum))
 
        If AddMapElement(VGEx()\Content\Heading(), HeadingKey)
          
          If FindMapElement(Resource\Font(), FontKey)
            VGEx()\Content\Heading()\FontKey = FontKey
            VGEx()\Content\Font(FontKey)\Name  = Resource\Font()\Name
            VGEx()\Content\Font(FontKey)\Size  = Resource\Font()\Size
            VGEx()\Content\Font(FontKey)\Flags = Resource\Font()\Flags
          Else
            VGEx()\Content\Heading()\FontKey = Str(#PB_Default)
          EndIf
          
          VGEx()\Content\Heading()\FrontColor = FrontColor
          VGEx()\Content\Heading()\BackColor  = BackColor
          VGEx()\Content\Heading()\Level      = Level
          VGEx()\Content\Heading()\Spacing    = dpiY(Spacing)
          VGEx()\Content\Heading()\Indent     = dpiX(Indent)
          VGEx()\Content\Heading()\Flags      = Flags
          
          ProcedureReturn #True
        EndIf

      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i DefineStyle(GNum.i, StyleKey.s, FontKey.s="", Indent.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        If AddMapElement(VGEx()\Content\Style(), StyleKey)

          If FindMapElement(Resource\Font(), FontKey)
            VGEx()\Content\Style()\FontKey = FontKey
            VGEx()\Content\Font(FontKey)\Name  = Resource\Font()\Name
            VGEx()\Content\Font(FontKey)\Size  = Resource\Font()\Size
            VGEx()\Content\Font(FontKey)\Flags = Resource\Font()\Flags
          Else
            VGEx()\Content\Style()\FontKey = Str(#PB_Default)
          EndIf
          
          VGEx()\Content\Style()\Indent     = dpiX(Indent)
          VGEx()\Content\Style()\FrontColor = FrontColor
          VGEx()\Content\Style()\BackColor  = BackColor
          
          ProcedureReturn #True
        EndIf
        
      EndIf
      
      ProcedureReturn #False 
    EndProcedure

    Procedure.i Save(GNum.i, File.s)
      Define.i JSON, Pack, Size, Result = #False
      Define   *Buffer
      
      NewMap Pattern.Pattern_Structure()
      
      If FindMapElement(VGEx(), Str(GNum))
        
        Pack = CreatePack(#PB_Any, File, #PB_PackerPlugin_Lzma)
        If Pack
          
          ;{ Pattern
          ForEach VGEx()\Content\Label()
            If VGEx()\Content\Label()\Pattern <> "" 
              Pattern(VGEx()\Content\Label()\Pattern)\Size = 0 ; add each pattern only one time (=> MAP!)
            EndIf
          Next
          
          ForEach Pattern()
            If FindMapElement(Hyphen(), MapKey(Pattern()))
              Pattern()\FileName = "Pattern_" + StringField(Hyphen()\FileName, 1, ".") + ".json"
              JSON = CreateJSON(#PB_Any)
              If JSON
                InsertJSONList(JSONValue(JSON), Hyphen()\Pattern())
                Pattern()\Size = ExportJSONSize(JSON)
                If Pattern()\Size
                  *Buffer = AllocateMemory(Pattern()\Size)
                  If *Buffer
                    If ExportJSON(JSON, *Buffer, Pattern()\Size)
                      AddPackMemory(Pack, *Buffer, Pattern()\Size, Pattern()\FileName)
                    EndIf
                    FreeMemory(*Buffer)
                  EndIf
                EndIf
                FreeJSON(JSON)
              EndIf 
            EndIf
          Next
          
          ForEach VGEx()\Content\Label() ; Update
            If VGEx()\Content\Label()\Pattern <> ""
              VGEx()\Content\Label()\File = Pattern(VGEx()\Content\Label()\Pattern)\FileName
              VGEx()\Content\Label()\Size = Pattern(VGEx()\Content\Label()\Pattern)\Size
            EndIf
          Next
          ;}
          
          ;{ Images
          ForEach VGEx()\Content\Image()
            If FindMapElement(Resource\Image(), VGEx()\Content\Image()\Key)
              If AddPackFile(Pack, Resource\Image()\File, GetFilePart(Resource\Image()\File))
                VGEx()\Content\Image()\FileName = GetFilePart(Resource\Image()\File)
                VGEx()\Content\Image()\Size     = Resource\Image()\Size
              EndIf
            EndIf 
          Next ;}
          
          ;{ Viewer Content
          JSON = CreateJSON(#PB_Any)
          If JSON
            InsertJSONStructure(JSONValue(JSON), @VGEx()\Content, ViewerEx_Content_Structure)
            Size = ExportJSONSize(JSON)
            If Size 
              *Buffer = AllocateMemory(Size)
              If *Buffer
                If ExportJSON(JSON, *Buffer, Size)
                  Result = AddPackMemory(Pack, *Buffer, Size, #ViewerContentFile$)
                EndIf
                FreeMemory(*Buffer)
              EndIf
            EndIf
            FreeJSON(JSON)
          EndIf ;}
          
          ClosePack(Pack)
        EndIf 
        
      EndIf 
      
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure   SetHyphenation(GNum.i, PatternKey.s)
      
      If FindMapElement(VGEx(), Str(GNum))
        
        VGEx()\Pattern = PatternKey
        VGEx()\Content\Label(VGEx()\Label)\Pattern = PatternKey
        
      EndIf 
    
    EndProcedure  
    
    Procedure   SetMargin(GNum.i, Attribute.i, Value.i) 
      
      If FindMapElement(VGEx(), Str(GNum))
    
        Select Attribute
          Case #Top
            VGEx()\Content\Label(VGEx()\Label)\Margin\Top    = dpiY(Value)
          Case #Left
            VGEx()\Content\Label(VGEx()\Label)\Margin\Left   = dpiX(Value)
          Case #Right
            VGEx()\Content\Label(VGEx()\Label)\Margin\Right  = dpiX(Value)
          Case #Bottom
            VGEx()\Content\Label(VGEx()\Label)\Margin\Bottom = dpiY(Value)
        EndSelect
        
        ReDraw_()
      EndIf  
      
    EndProcedure  
    
  CompilerEndIf
  
  ;- _____ Create Viewer Content _____
  
  CompilerIf #Enable_CreateViewerContent
    
    Procedure.i Create(CNum.i, Label.s)
      
      If FindMapElement(Content(), Str(CNum)) = #False
        AddMapElement(Content(), Str(CNum))
      EndIf 
      
      If AddMapElement(Content()\Style(), Str(#PB_Default))
        Content()\Style()\FontKey    = Str(#PB_Default)
        Content()\Style()\Indent     = 0
        Content()\Style()\FrontColor = $000000
        Content()\Style()\BackColor  = $FFFFFF
      EndIf  
      
      If AddMapElement(Content()\Heading(), Str(#PB_Default))
        Content()\Heading()\FontKey    = Str(#PB_Default)
        Content()\Heading()\FrontColor = $000000
        Content()\Heading()\BackColor  = $FFFFFF
        Content()\Heading()\Level  = 0
        Content()\Heading()\Indent = 0
        Content()\Heading()\Flags  = #Left
      EndIf

      If AddMapElement(Content()\Label(), Label)
        Label(Str(CNum)) = Label
        ProcedureReturn #True
      EndIf

      ProcedureReturn #False
    EndProcedure
    
    Procedure   Close(CNum.i) 
      Label(Str(CNum)) = Str(#PB_Default)
    EndProcedure
    
    Procedure   Clear(CNum.i)
      DeleteMapElement(Content(), Str(CNum))
      DeleteMapElement(Label(), Str(CNum))
    EndProcedure  
    
    Procedure   CopyContent(CNum.i, GNum.i)

      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(VGEx(), Str(GNum))
          
          ;{ Copy content lists
          CopyList(Content()\Image(), VGEx()\Content\Image())
          CopyList(Content()\Text(),  VGEx()\Content\Text())
          CopyList(Content()\Tree(),  VGEx()\Content\Tree())
          ;}
          
          ;{ Copy content maps
          CopyMap(Content()\Label(),   VGEx()\Content\Label())
          CopyMap(Content()\Style(),   VGEx()\Content\Style())
          CopyMap(Content()\Heading(), VGEx()\Content\Heading())
          CopyMap(Content()\Font(),    VGEx()\Content\Font())
          ;}

        EndIf
      EndIf
      
    EndProcedure
    
    Procedure.i Export(CNum.i, File.s)
      Define.i JSON, Pack, Size, Result = #False
      Define.s File
      Define   *Buffer
      
      NewMap ImageFile.Resources_Image_Structure()
      NewMap Pattern.Pattern_Structure()
      
      If FindMapElement(Content(), Str(CNum))
        
        Pack = CreatePack(#PB_Any, File, #PB_PackerPlugin_Lzma)
        If Pack
          
          ;{ Defaults
          If AddMapElement(Content()\Style(), Str(#PB_Default))
            Content()\Style()\FontKey    = Str(#PB_Default)
            Content()\Style()\FrontColor = Color\Front
            Content()\Style()\BackColor  = Color\Back
          EndIf
          
          If AddMapElement(Content()\Heading(), Str(#PB_Default))
            Content()\Heading()\FontKey    = Str(#PB_Default)
            Content()\Heading()\FrontColor = Color\Front
            Content()\Heading()\BackColor  = Color\Back
            Content()\Heading()\Flags  = #Left
          EndIf
          ;}
          
          ;{ Images
          ForEach Content()\Image()
            
            If FindMapElement(Resource\Image(), Content()\Image()\Key)
              If AddMapElement(ImageFile(), GetFilePart(Resource\Image()\File))
                ImageFile()\File = Resource\Image()\File
                ImageFile()\Size = Resource\Image()\Size
              EndIf  
            EndIf
            
          Next
          
          ForEach ImageFile()
            If AddPackFile(Pack, ImageFile()\File, GetFilePart(ImageFile()\File))
              Content()\Image()\FileName = GetFilePart(ImageFile()\File)
              Content()\Image()\Size     = ImageFile()\Size
            EndIf
          Next ;}
          
          ;{ Pattern
          ForEach Content()\Label()
            If Content()\Label()\Pattern <> "" 
              Pattern(Content()\Label()\Pattern)\Size = 0 ; add each pattern only one time (=> MAP!)
            EndIf
          Next
          
          ForEach Pattern()
            If FindMapElement(Hyphen(), MapKey(Pattern()))
              Pattern()\FileName = "Pattern_" + StringField(Hyphen()\FileName, 1, ".") + ".json"
              JSON = CreateJSON(#PB_Any)
              If JSON
                InsertJSONList(JSONValue(JSON), Hyphen()\Pattern())
                Pattern()\Size = ExportJSONSize(JSON)
                If Pattern()\Size
                  *Buffer = AllocateMemory(Pattern()\Size)
                  If *Buffer
                    If ExportJSON(JSON, *Buffer, Pattern()\Size)
                      AddPackMemory(Pack, *Buffer, Pattern()\Size, Pattern()\FileName)
                    EndIf
                    FreeMemory(*Buffer)
                  EndIf
                EndIf
                FreeJSON(JSON)
              EndIf 
            EndIf
          Next
          
          ForEach Content()\Label() ; Update
            If Content()\Label()\Pattern <> ""
              Content()\Label()\File = Pattern(Content()\Label()\Pattern)\FileName
              Content()\Label()\Size = Pattern(Content()\Label()\Pattern)\Size
            EndIf
          Next
          ;}
          
          ;{ Viewer Content
          JSON = CreateJSON(#PB_Any)
          If JSON
            InsertJSONStructure(JSONValue(JSON), @Content(), ViewerEx_Content_Structure)
            Size = ExportJSONSize(JSON)
            If Size 
              *Buffer = AllocateMemory(Size)
              If *Buffer
                If ExportJSON(JSON, *Buffer, Size)
                  Result = AddPackMemory(Pack, *Buffer, Size, #ViewerContentFile$)
                EndIf
                FreeMemory(*Buffer)
              EndIf
            EndIf
            FreeJSON(JSON)
          EndIf ;}
          
          ClosePack(Pack)
        EndIf

      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i Heading(CNum.i, Text.s, HeadingKey.s, Flags.i=#Left)
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
        
          If AddElement(Content()\Label()\Item())
  
            Content()\Label()\Item()\Type = #Heading
            
            If AddElement(Content()\Text())
              
              Content()\Label()\Item()\Idx = ListIndex(Content()\Text())
              Content()\Text()\String = Text
              Content()\Text()\Flags  = Flags
              
              If FindMapElement(Content()\Heading(), HeadingKey)
                Content()\Text()\Style = HeadingKey
              Else
                Content()\Text()\Style = Str(#PB_Default)
              EndIf
              
              ProcedureReturn #True
            EndIf
            
          EndIf
          
        EndIf 
      EndIf
      
      ProcedureReturn #False 
    EndProcedure     
    
    Procedure.i HeadingDefinition(CNum.i, HeadingKey.s, FontKey.s, Level.i=0, Spacing.i=0, Indent.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default, Flags.i=#Left)
      
      If FindMapElement(Content(), Str(CNum)) = #False
        AddMapElement(Content(), Str(CNum))
      EndIf
      
      If FindMapElement(Content(), Str(CNum))
        
        If AddMapElement(Content()\Heading(), HeadingKey)
          
          If FindMapElement(Resource\Font(), FontKey)
            Content()\Heading()\FontKey = FontKey
            Content()\Font(FontKey)\Name  = Resource\Font()\Name
            Content()\Font(FontKey)\Size  = Resource\Font()\Size
            Content()\Font(FontKey)\Flags = Resource\Font()\Flags
          Else
            Content()\Heading()\FontKey = Str(#PB_Default)
          EndIf
          
          Content()\Heading()\FrontColor = FrontColor
          Content()\Heading()\BackColor  = BackColor
          Content()\Heading()\Level      = Level
          Content()\Heading()\Spacing    = dpiY(Spacing)
          Content()\Heading()\Indent     = dpiX(Indent)
          Content()\Heading()\Flags      = Flags
          
          ProcedureReturn #True
        EndIf
        
      EndIf
      
      ProcedureReturn #False  
    EndProcedure

    Procedure   Hyphenation(CNum.i, PatternKey.s)
      
      If FindMapElement(Content(), Str(CNum))

        Content()\Label(Label(Str(CNum)))\Pattern = PatternKey
        
      EndIf 
    
    EndProcedure  
    
    Procedure.i Image(CNum.i, ImageKey.s, Width=#PB_Default, Height.i=#PB_Default, Indent.i=0, Flags.i=#False)
      Define.i ImageNum
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
          
          If FindMapElement(Resource\Image(), ImageKey)

            If AddElement(Content()\Label()\Item())
              
              Content()\Label()\Item()\Type = #Image
              
              If IsImage(Resource\Image()\Num)
                If Width  = #PB_Default : Width  = ImageWidth(Resource\Image()\Num)  : EndIf
                If Height = #PB_Default : Height = ImageHeight(Resource\Image()\Num) : EndIf
              EndIf
            
              If AddElement(Content()\Image())
                Content()\Label()\Item()\Idx = ListIndex(Content()\Image())
                Content()\Image()\Key    = ImageKey
                Content()\Image()\Width  = dpiX(Width)
                Content()\Image()\Height = dpiY(Height)
                Content()\Image()\Indent = dpiX(Indent)
                Content()\Image()\Flags  = Flags
                ProcedureReturn #True
              EndIf
              
            EndIf
            
          EndIf
          
        EndIf
      EndIf
      
      ProcedureReturn #False
    EndProcedure    
    
    Procedure.i ImageText(CNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#Left)
      ; Spacing: #PB_Default = row height

      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
          
          If Padding = #PB_Default : Padding = 10 : EndIf
          
          If AddElement(Content()\Label()\Item())
  
            Content()\Label()\Item()\Type = #Text
            
            If AddElement(Content()\Text())
              
              Content()\Label()\Item()\Idx     = ListIndex(Content()\Text())
              Content()\Label()\Item()\Spacing = Spacing
              Content()\Text()\String   = Text
              Content()\Text()\ImageKey = ImageKey
              Content()\Text()\Padding  = Padding
              Content()\Text()\Flags    = Flags
              
              If FindMapElement(Content()\Style(), StyleKey)
                Content()\Text()\Style = StyleKey
              Else
                Content()\Text()\Style = Str(#PB_Default)
              EndIf
              
              ProcedureReturn #True
            EndIf
            
          EndIf 
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i ImageListing(CNum.i, Text.s, ImageKey.s, StyleKey.s="", Padding.i=#PB_Default, Spacing.i=0, Flags.i=#False)
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
          
          If AddElement(Content()\Label()\Item())
  
            Content()\Label()\Item()\Type = #List
            
            If AddElement(Content()\Text())
              
              Content()\Label()\Item()\Idx     = ListIndex(Content()\Text())
              Content()\Label()\Item()\Spacing = Spacing
              Content()\Text()\String          = Text
              Content()\Text()\ImageKey        = ImageKey
              Content()\Text()\Padding         = Padding
              Content()\Text()\Flags           = Flags
              
              If FindMapElement(Content()\Style(), StyleKey)
                Content()\Text()\Style = StyleKey
              Else
                Content()\Text()\Style = Str(#PB_Default)
              EndIf
              
              ProcedureReturn #True
            EndIf
            
          EndIf
          
        EndIf
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i Link(CNum.i, Text.s, Label.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
          
          If AddElement(Content()\Label()\Item())
            
            Content()\Label()\Item()\Type = #Link
            
            If AddElement(Content()\Label()\Link())
              
              Content()\Label()\Item()\Idx     = ListIndex(Content()\Label()\Link())
              Content()\Label()\Item()\Spacing = Spacing
              Content()\Label()\Link()\String  = Text
              Content()\Label()\Link()\Label   = Label
              Content()\Label()\Link()\Style   = StyleKey
              Content()\Label()\Link()\Flags   = Flags
              
              ProcedureReturn #True
            EndIf  
            
          EndIf
          
        EndIf
      EndIf
      
      ProcedureReturn #False
    EndProcedure    
    
    Procedure.i Listing(CNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#False)
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
          
          If AddElement(Content()\Label()\Item())
  
            Content()\Label()\Item()\Type = #List
            
            If AddElement(Content()\Text())
              
              Content()\Label()\Item()\Idx     = ListIndex(Content()\Text())
              Content()\Label()\Item()\Spacing = Spacing
              Content()\Text()\String          = Text
              Content()\Text()\Flags           = Flags
              
              If FindMapElement(Content()\Style(), StyleKey)
                Content()\Text()\Style = StyleKey
              Else
                Content()\Text()\Style = Str(#PB_Default)
              EndIf
              
              ProcedureReturn #True
            EndIf
            
          EndIf
          
        EndIf
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure   Margin(CNum.i, Attribute.i, Value.i) 
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
          
          Select Attribute
            Case #Top
              Content()\Label()\Margin\Top    = dpiY(Value)
            Case #Left
              Content()\Label()\Margin\Left   = dpiX(Value)
            Case #Right
              Content()\Label()\Margin\Right  = dpiX(Value)
            Case #Bottom
              Content()\Label()\Margin\Bottom = dpiY(Value)
          EndSelect

        EndIf  
      EndIf
      
    EndProcedure  
    
    Procedure   Spacing(CNum.i, Height.i)
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
        
          If AddElement(Content()\Label()\Item())
            Content()\Label()\Item()\Type    = #Spacing
            Content()\Label()\Item()\Spacing = Height
          EndIf
          
        EndIf
      EndIf
      
    EndProcedure
    
    Procedure.i StyleDefinition(CNum.i, StyleKey.s, FontKey.s="", Indent.i=0, FrontColor.i=#PB_Default, BackColor.i=#PB_Default)    
      
      If FindMapElement(Content(), Str(CNum)) = #False
        AddMapElement(Content(), Str(CNum))
      EndIf
      
      If FindMapElement(Content(), Str(CNum))
        
        If AddMapElement(Content()\Style(), StyleKey)
         
          If FindMapElement(Resource\Font(), FontKey)
            Content()\Style()\FontKey = FontKey
            Content()\Font(FontKey)\Name  = Resource\Font()\Name
            Content()\Font(FontKey)\Size  = Resource\Font()\Size
            Content()\Font(FontKey)\Flags = Resource\Font()\Flags
          Else
            Content()\Style()\FontKey = Str(#PB_Default)
          EndIf
          
          Content()\Style()\Indent     = dpiX(Indent)
          Content()\Style()\FrontColor = FrontColor
          Content()\Style()\BackColor  = BackColor
          
          ProcedureReturn #True
        EndIf
        
      EndIf
    
      ProcedureReturn #False
    EndProcedure
    
    Procedure.i Text(CNum.i, Text.s, StyleKey.s="", Spacing.i=0, Flags.i=#Left)
      ; Spacing: #PB_Default = row height
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
          
          If AddElement(Content()\Label()\Item())
  
            Content()\Label()\Item()\Type = #Text
            
            If AddElement(Content()\Text())
              
              Content()\Label()\Item()\Idx     = ListIndex(Content()\Text())
              Content()\Label()\Item()\Spacing = Spacing
              Content()\Text()\String  = Text
              Content()\Text()\Flags   = Flags
              
              If FindMapElement(Content()\Style(), StyleKey)
                Content()\Text()\Style = StyleKey
              Else
                Content()\Text()\Style = Str(#PB_Default)
              EndIf
              
              ProcedureReturn #True
            EndIf
            
          EndIf 
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    CompilerIf #Enable_ContentTree
    
      Procedure.i AddTreeItem(CNum.i, Title.s, Label.s, Level.i=0) 
        
        If FindMapElement(Content(), Str(CNum)) = #False
          AddMapElement(Content(), Str(CNum))
        EndIf
        
        If FindMapElement(Content(), Str(CNum))
          If AddElement(Content()\Tree())
            Content()\Tree()\Title = Title
            Content()\Tree()\Label = Label
            Content()\Tree()\Level = Level
            ProcedureReturn ListIndex(Content()\Tree())
          EndIf
         
        EndIf 
        
      EndProcedure
    
    CompilerEndIf
    
    Procedure.i URL(CNum.i, URL.s, StyleKey.s="", String.s="", Spacing.i=0, Flags.i=#Left)
      
      If FindMapElement(Content(), Str(CNum))
        If FindMapElement(Content()\Label(), Label(Str(CNum)))
        
          If String = "" : String = URL : EndIf
          
          If AddElement(Content()\Label()\Item())
            
            Content()\Label()\Item()\Type = #URL
            
            If AddElement(Content()\Label()\Link())
              
              Content()\Label()\Item()\Idx     = ListIndex(Content()\Label()\Link())
              Content()\Label()\Item()\Spacing = Spacing
              Content()\Label()\Link()\Url     = URL
              Content()\Label()\Link()\String  = String
              Content()\Label()\Link()\Style   = StyleKey
              Content()\Label()\Link()\Flags   = Flags
              
              ProcedureReturn #True
            EndIf  
            
          EndIf
          
        EndIf
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
  CompilerEndIf
  
  ;- _____ Add Hyphenation _____
  
  CompilerIf #Enable_Hyphenation
    
    Procedure.s UsePattern(File.s, PatternKey.s="")
      Define.i FileNum 
      
      If PatternKey = "" : PatternKey = StringField(GetFilePart(File), 1, ".") : EndIf 
    
      If AddMapElement(Hyphen(), PatternKey)
        FileNum = ReadFile(#PB_Any, File)
        If FileNum
          Hyphen()\FileName = GetFilePart(File)
          While Eof(FileNum) = #False
            If AddElement(Hyphen()\Pattern())
              Hyphen()\Pattern() = Trim(ReadString(FileNum, #PB_UTF8))
            EndIf
          Wend 
          CloseFile(FileNum)
        EndIf
      EndIf
      
      ProcedureReturn PatternKey
    EndProcedure

  CompilerEndIf

  ;- _____ ViewerEx Gadget _____
	
	Procedure   ClearContent(GNum.i)
    
    If FindMapElement(VGEx(), Str(GNum))
      
      VGEx()\Label = ""
      ReDraw_()
      
    EndIf 
    
  EndProcedure
	
	Procedure   DisableReDraw(GNum.i, State.i=#True)
   
    If FindMapElement(VGEx(), Str(GNum))
      Select State
        Case #True
          VGEx()\ReDraw = #False
        Case #False
          VGEx()\ReDraw = #True
          ReDraw_() 
      EndSelect
    EndIf  
    
  EndProcedure
  
  Procedure.s EventValue(GNum.i)
    
    If FindMapElement(VGEx(), Str(GNum))
      ProcedureReturn VGEx()\EventValue
    EndIf  
    
  EndProcedure  
  
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, Num
    
    CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If Flags & #UseExistingCanvas ;{ Use an existing CanvasGadget
      If IsGadget(GNum)
        Result = #True
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard|#PB_Canvas_Container)
    EndIf
    
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      If AddMapElement(VGEx(), Str(GNum))
        
        VGEx()\CanvasNum = GNum
        VGEx()\Flags     = Flags
        
        VGEx()\ScrollBar\Num = ScrollBarGadget(#PB_Any, Width - #Scroll_Width - 2, 2, #Scroll_Width, Height - 4, 0, 0, 0, #PB_ScrollBar_Vertical)
        If VGEx()\ScrollBar\Num
          SetGadgetData(VGEx()\ScrollBar\Num, GNum)
          SetGadgetAttribute(VGEx()\ScrollBar\Num, #PB_ScrollBar_PageLength, dpiY(Height))
          SetGadgetAttribute(VGEx()\ScrollBar\Num, #PB_ScrollBar_Maximum,    dpiY(Height))
          BindGadgetEvent(VGEx()\ScrollBar\Num, @_SynchronizeScrollBar(), #PB_All)
          HideGadget(VGEx()\ScrollBar\Num, #True)
          VGEx()\ScrollBar\Hide = #True
        EndIf
        
  			If WindowNum = #PB_Default
          VGEx()\Window\Num = GetGadgetWindow()
        Else
          VGEx()\Window\Num = WindowNum
        EndIf  
        
        If IsWindow(VGEx()\Window\Num)
          VGEx()\Window\Width  = WindowWidth(VGEx()\Window\Num)
          VGEx()\Window\Height = WindowHeight(VGEx()\Window\Num)
          If Flags & #AutoResize
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), VGEx()\Window\Num)
          EndIf
        EndIf

        VGEx()\Size\X = dpiX(4)
        VGEx()\Size\Y = dpiY(4)
        VGEx()\Size\Width  = dpiX(Width  - 8)
        VGEx()\Size\Height = dpiY(Height - 8)
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            VGEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
           Num = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If Num
              VGEx()\FontID = GetGadgetFont(Num)
              FreeGadget(Num)
            EndIf
          CompilerCase #PB_OS_Linux
            VGEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        VGEx()\Cursor = #PB_Cursor_Default
        
        VGEx()\Color\Front     = $000000
        VGEx()\Color\Back      = $FFFFFF
        VGEx()\Color\ScrollBar = $C8C8C8
        VGEx()\Color\Border    = $E3E3E3
        
        CompilerSelect  #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            VGEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            VGEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
            VGEx()\Color\ScrollBar     = GetSysColor_(#COLOR_MENU)
            VGEx()\Color\Border        = GetSysColor_(#COLOR_3DDKSHADOW) ; #COLOR_ACTIVEBORDER
          CompilerCase #PB_OS_MacOS  
            VGEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            VGEx()\Color\Back          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            VGEx()\Color\ScrollBar     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            VGEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux
        
        CompilerEndSelect
        
        If AddMapElement(VGEx()\Content\Label(), Str(#PB_Default))
          VGEx()\Label = Str(#PB_Default)
        EndIf
      
        If AddMapElement(VGEx()\Content\Style(), Str(#PB_Default))
          VGEx()\Content\Style()\FontKey    = Str(#PB_Default)
          VGEx()\Content\Style()\Indent     = 0
          VGEx()\Content\Style()\FrontColor = VGEx()\Color\Front
          VGEx()\Content\Style()\BackColor  = VGEx()\Color\Back
        EndIf  
        
        If AddMapElement(VGEx()\Content\Heading(), Str(#PB_Default))
          VGEx()\Content\Heading()\FontKey    = Str(#PB_Default)
          VGEx()\Content\Heading()\FrontColor = VGEx()\Color\Front
          VGEx()\Content\Heading()\BackColor  = VGEx()\Color\Back
          VGEx()\Content\Heading()\Level  = 0
          VGEx()\Content\Heading()\Indent = 0
          VGEx()\Content\Heading()\Flags  = #Left
        EndIf
        
        BindGadgetEvent(GNum, @_ResizeHandler(),     #PB_EventType_Resize)
        BindGadgetEvent(GNum, @_MouseWheelHandler(), #PB_EventType_MouseWheel)
        BindGadgetEvent(GNum, @_MouseMoveHandler(),  #PB_EventType_MouseMove)
        BindGadgetEvent(GNum, @_LeftClickHandler(),  #PB_EventType_LeftClick)
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf        
        
        VGEx()\ReDraw = #True
        
      EndIf
      
      CloseGadgetList()
    Else
      ProcedureReturn #False  
    EndIf
    
    Draw_()
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(VGEx(), Str(GNum))
	    ProcedureReturn VGEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(VGEx(), Str(GNum))
	    ProcedureReturn VGEx()\ID
	  EndIf
	  
	EndProcedure
	
	
	CompilerIf #Enable_ContentTree
	  
  	Procedure.s GetContentTree(GNum.i, List ContentTree.Content_Tree_Structure())
  	  
  	  If FindMapElement(VGEx(), Str(GNum))
  	    CopyList(VGEx()\Content\Tree(), ContentTree())
  	  EndIf 
  	  
  	EndProcedure  
  	
  CompilerEndIf
  
  
  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(VGEx(), Str(GNum))
      
      If State
        VGEx()\Hide = #True
        HideGadget(GNum, #True)
      Else
        VGEx()\Hide = #False
        HideGadget(GNum, #False)
        Draw_()
      EndIf  
      
    EndIf  
    
  EndProcedure 
  
  Procedure.i Load(GNum.i, File.s)
    Define.i JSON, Pack, Size, Result = #False
    Define  *Buffer
    Define   Content.ViewerEx_Content_Structure
    
    If FindMapElement(VGEx(), Str(GNum))
      
      Pack = OpenPack(#PB_Any, File, #PB_PackerPlugin_Lzma)
      If Pack
        
        ;{ Load viewer content 
        If ExaminePack(Pack)
          While NextPackEntry(Pack)
            If PackEntryName(Pack) = #ViewerContentFile$
              Size = PackEntrySize(Pack)
            EndIf
          Wend
        EndIf
        
        If Size
          *Buffer = AllocateMemory(Size)
          If *Buffer
            If UncompressPackMemory(Pack, *Buffer, Size, #ViewerContentFile$) <> -1
              JSON = CatchJSON(#PB_Any, *Buffer, Size)
              If JSON
                ExtractJSONStructure(JSONValue(JSON), @Content, ViewerEx_Content_Structure)
                FreeJSON(JSON)
                Result = #True
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        EndIf ;}
        
        If Result
          
          ;{ Copy content lists
          CopyList(Content\Image(), VGEx()\Content\Image())
          CopyList(Content\Text(),  VGEx()\Content\Text())
          CopyList(Content\Tree(),  VGEx()\Content\Tree())
          ;}
          
          ;{ Copy content maps
          CopyMap(Content\Label(),   VGEx()\Content\Label())
          CopyMap(Content\Style(),   VGEx()\Content\Style())
          CopyMap(Content\Heading(), VGEx()\Content\Heading())
          CopyMap(Content\Font(),    VGEx()\Content\Font())
          ;}
          
          If MapSize(VGEx()\Content\Font())   ;{ Load fonts
            ForEach VGEx()\Content\Font()
              If FindMapElement(Resource\Font(), MapKey(VGEx()\Content\Font()))
                If IsFont(Resource\Font()\Num) = #False
                  Resource\Font()\Num = LoadFont(#PB_Any, Resource\Font()\Name, Resource\Font()\Size, Resource\Font()\Flags)
                EndIf 
              Else
                If AddMapElement(Resource\Font(), MapKey(VGEx()\Content\Font()))
                  Resource\Font()\Name  = VGEx()\Content\Font()\Name
                  Resource\Font()\Size  = VGEx()\Content\Font()\Size
                  Resource\Font()\Flags = VGEx()\Content\Font()\Flags
                  Resource\Font()\Num = LoadFont(#PB_Any, Resource\Font()\Name, Resource\Font()\Size, Resource\Font()\Flags)
                EndIf
              EndIf
            Next ;}
          EndIf
          
          If ListSize(VGEx()\Content\Image()) ;{ Load images
            ForEach VGEx()\Content\Image()
              If FindMapElement(Resource\Image(), VGEx()\Content\Image()\Key)
                If IsImage(Resource\Image()\Num) = #False
                  Resource\Image()\Num = LoadPackImage_(Pack, GetFilePart(Resource\Image()\File), Resource\Image()\Size)
                EndIf 
              Else
                If AddMapElement(Resource\Image(), VGEx()\Content\Image()\Key)
                  Resource\Image()\File = VGEx()\Content\Image()\FileName
                  Resource\Image()\Size = VGEx()\Content\Image()\Size
                  Resource\Image()\Num  = LoadPackImage_(Pack, Resource\Image()\File, Resource\Image()\Size)
                EndIf
              EndIf 
            Next ;}
          EndIf 
          
          ForEach VGEx()\Content\Label()      ;{ Pattern
            
            If FindMapElement(Hyphen(), VGEx()\Content\Label()\Pattern) = #False
              
              If AddMapElement(Hyphen(), VGEx()\Content\Label()\Pattern)
                If VGEx()\Content\Label()\File And VGEx()\Content\Label()\Size
                  
                  Hyphen()\FileName = VGEx()\Content\Label()\File
                  
                  *Buffer = AllocateMemory(VGEx()\Content\Label()\Size)
                  If *Buffer
                    If UncompressPackMemory(Pack, *Buffer, VGEx()\Content\Label()\Size, VGEx()\Content\Label()\File) <> -1
                      JSON = CatchJSON(#PB_Any, *Buffer, VGEx()\Content\Label()\Size)
                      If JSON
                        ExtractJSONList(JSONValue(JSON), Hyphen()\Pattern())
                        FreeJSON(JSON)
                      EndIf
                    EndIf
                    FreeMemory(*Buffer)
                  EndIf
                  
                EndIf
              EndIf
              
            EndIf
            
          Next ;}
          
        EndIf        
        
        ClosePack(Pack)
      EndIf
      
      ReDraw_()
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(VGEx(), Str(GNum))
      
      VGEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetContent(GNum.i, Label.s="")
    
    If Label = "" : Label = Str(#PB_Default) : EndIf 
    
    If FindMapElement(VGEx(), Str(GNum))
      
      If FindMapElement(VGEx()\Content\Label(), Label)
        VGEx()\Label   = Label
        VGEx()\Pattern = VGEx()\Content\Label()\Pattern
      Else
        VGEx()\Label = Str(#PB_Default)
        VGEx()\Pattern = ""
      EndIf
      
      ReDraw_()
    EndIf
    
  EndProcedure

	Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(VGEx(), Str(GNum))
	    VGEx()\Quad = Value
	  EndIf  
	  
	EndProcedure

  Procedure   SetHeadingOffset(GNum.i, Value.i, Level.i=0)
    
    If FindMapElement(VGEx(), Str(GNum))
      
      VGEx()\Content\Label(VGEx()\Label)\Offset(Str(Level)) = Value
      
      ReDraw_()
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(VGEx(), Str(GNum))
	    VGEx()\ID = String
	  EndIf
	  
	EndProcedure

EndModule

;- ========  Module - Example ========
CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  Enumeration 
    #Window
    #Viewer
    #Content
    #Button1
    #Button2
    #Button3
  EndEnumeration
  
  Text.s = "School is a beautiful thing." + #LF$ + "You need it, that's true." + #LF$ + "There was a group of monkeys sitting on a fallen tree."
  Text + #LF$ + "They had been sent there to make up the mind." + #LF$ + "The teacher was three tons heavy, a clever elephant."
  Text + #LF$ + "The teacher took the students by the ears with his trunk." + #LF$ + "They didn't learn anything, they just made noise, all effort was lost."
  
  CompilerIf ViewerEx::#Enable_AddViewerContent Or ViewerEx::#Enable_CreateViewerContent
    ; Resources used
    ViewerEx::UseFont("Arial", 12, #PB_Font_Bold, "Arial_12B")      ; Default key: "Arial|12|255"
    ViewerEx::UseFont("Arial", 11, #PB_Font_Bold, "Arial_11B")      ; Default key: "Arial|11|255"
    ViewerEx::UseFont("Arial", 11, #PB_Font_Underline, "Arial_11U") ; Default key: "Arial|11|4"
    ViewerEx::UseFont("Arial", 11, #False, "Arial_11")              ; Default key: "Arial|11|0"
    ViewerEx::UsePattern("english.pat", "english")                  ; Default key: "english"
    ViewerEx::UseImage("Programmer.bmp", "IMG_Prog")                ; Default key: "PureBasicLogo.bmp"
    ViewerEx::UseImage("Pen.png", "IMG_Pen")
    ViewerEx::UseImage("Bullet.png", "IMG_Bullet")
  CompilerEndIf
  
  CompilerIf ViewerEx::#Enable_CreateViewerContent
    ; Create and export content independently of the program
    
    ViewerEx::UseFont("Arial", 16, #PB_Font_Bold, "Arial_16B")
    
    If ViewerEx::Create(#Content, "About")
      
      ViewerEx::StyleDefinition(#Content, "Titel",   "Arial_16B", 0, $5D4A3F)
      ViewerEx::StyleDefinition(#Content, "Version", "Arial_11")
      ViewerEx::StyleDefinition(#Content, "Author",  "Arial_11B")
      ViewerEx::StyleDefinition(#Content, "Link",    "Arial_11U", 0, $8B0000)
      
      ViewerEx::Spacing(#Content, 10)
      ViewerEx::Image(#Content, "IMG_Prog", #PB_Default, #PB_Default, 0, ViewerEx::#Center)
      ViewerEx::Spacing(#Content, 30)
      ViewerEx::Text(#Content, "ViewerEx - Module", "Titel", 10, ViewerEx::#Center)
      ViewerEx::Text(#Content, "PureBasic V 5.7x (all OS / 64Bit / DPI)", "Version", 20, ViewerEx::#Center)
      ViewerEx::Text(#Content, "© 2019 by Thorsten Hoeppner ", "Author", 20, ViewerEx::#Center)
      ViewerEx::Link(#Content, "Show license", "License", "Link", 0, ViewerEx::#Center)
      
    EndIf
    
    If ViewerEx::Create(#Content, "License")
      
      ViewerEx::Hyphenation(#Content, "english")
      
      ViewerEx::Margin(#Content, ViewerEx::#Left,  10)
      ViewerEx::Margin(#Content, ViewerEx::#Right,  8)
      ViewerEx::Margin(#Content, ViewerEx::#Bottom, 8)
      
      ViewerEx::StyleDefinition(#Content, "Titel2", "Arial_12B", 0, $701919)
      ViewerEx::StyleDefinition(#Content, "Text",   "Arial_11")
      ViewerEx::StyleDefinition(#Content, "BlueText", "Arial_11", 0, $701919)
      ViewerEx::StyleDefinition(#Content, "RedText",  "Arial_11", 0, $0000DD)
      
      ViewerEx::Spacing(#Content, 10)
      
      ViewerEx::Text(#Content, "MIT License", "Titel2", 10, ViewerEx::#Center)
      
      ViewerEx::Text(#Content, "Copyright © 2019 Thorsten Hoeppner", "Author", 10)
      
      Text2.s = "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), "
      Text2 + "to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, " 
      Text2 + "and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:" + #LF$
      ViewerEx::Text(#Content, Text2, "BlueText", 8, ViewerEx::#Justified)
      
      Text2 = "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software." + #LF$
      ViewerEx::Text(#Content, Text2, "Text", 8, ViewerEx::#Justified)
      
      Text2 = "THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS Or IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF MERCHANTABILITY, "
      Text2 + "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, "
      Text2 + "WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE." + #LF$
      ViewerEx::Text(#Content, Text2, "RedText", 5, ViewerEx::#Justified)
      
    EndIf  
    
    ViewerEx::Export(#Content, "Export.jvc")
    
    ViewerEx::Close(#Content)
  CompilerEndIf
  
  
  If OpenWindow(#Window, 0, 0, 430, 354, "Example", #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_ScreenCentered)
    
    If ViewerEx::Gadget(#Viewer, 10, 10, 410, 300, ViewerEx::#AutoResize, #Window)
      
      CompilerIf ViewerEx::#Enable_AddViewerContent
        ; Add content within the program
        
        ViewerEx::DisableReDraw(#Viewer, #True)
        
        ViewerEx::SetHyphenation(#Viewer, "english")
        
        ViewerEx::DefineStyle(#Viewer,   "Text", "Arial_11")
        ViewerEx::DefineStyle(#Viewer,   "Link", "Arial_11U", 0, $8B0000) ; 
        ViewerEx::DefineHeading(#Viewer, "H1",   "Arial_12B", 0, 3)
        ViewerEx::DefineHeading(#Viewer, "H2",   "Arial_11B", 1, 3)
        
        ViewerEx::AddHeading(#Viewer, "Heading H1", "H1")
        ViewerEx::AddHeading(#Viewer, "Heading H2 (Image)", "H2")
        ViewerEx::AddImage(#Viewer,   "IMG_Prog", #PB_Default, #PB_Default, 0, ViewerEx::#Center)
        ViewerEx::AddSpacing(#Viewer, 5)
        ViewerEx::AddURL(#Viewer, "https://www.purebasic.com", "Link", "", 10, ViewerEx::#Center)  
        ViewerEx::AddImageText(#Viewer, "Text next to an image (row 1)" + #LF$ + "Text next to an image (row 2)", "IMG_Pen", "Text", 5, 10, ViewerEx::#Middle)
        ViewerEx::AddHeading(#Viewer, "Heading H2 (#Left)", "H2")
        ;ViewerEx::AddImageListing(#Viewer, Text, "IMG_Bullet", "Text", 0, 5, ViewerEx::#AutoIndent)
        ViewerEx::AddListing(#Viewer, Text, "Text", 5, ViewerEx::#AutoIndent)
        ViewerEx::AddHeading(#Viewer, "Heading H2 (#Justified)", "H2")
        ViewerEx::AddText(#Viewer, ReplaceString(Text, #LF$, " "), "Text", 5, ViewerEx::#AutoIndent|ViewerEx::#Justified)
        
        ViewerEx::DisableReDraw(#Viewer, #False)
        
        ;ViewerEx::Save(#Viewer, "Save.jvc")
        
      CompilerElse
        
        ;ViewerEx::Load(#Viewer, "Save.jvc")
        
      CompilerEndIf
      
      ViewerEx::SetHeadingOffset(#Viewer, 1) ; Heading begins with 2. 
      
    EndIf
    
    ButtonGadget(#Button1,  10, 315, 90, 34, "About")
    ButtonGadget(#Button2, 110, 315, 90, 34, "License")
    ButtonGadget(#Button3, 210, 315, 90, 34, "Clear")
    
    DisableGadget(#Button1, #True)
    DisableGadget(#Button2, #True)
    
    CompilerIf ViewerEx::#Enable_CreateViewerContent And ViewerEx::#Enable_AddViewerContent = #False
      
      ViewerEx::CopyContent(#Content, #Viewer)
      ;ViewerEx::Load(#Viewer, "Export.jvc")
      
      DisableGadget(#Button1, #False)
      DisableGadget(#Button2, #False)
      
    CompilerEndIf
    
;    ModuleEx::SetTheme(ModuleEx::#Theme_Dark)
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow ;{ Close Window
          QuitWindow = #True
          ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Viewer
              If EventType() = ViewerEx::#EventType_Link
                RunProgram(ViewerEx::EventValue(#Viewer))
              EndIf 
            Case #Button1
              ViewerEx::SetContent(#Viewer, "About")
            Case #Button2
              ViewerEx::SetContent(#Viewer, "License")
            Case #Button3
              ViewerEx::ClearContent(#Viewer)
          EndSelect
      EndSelect
    Until QuitWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 109
; Folding = 5gAAAYADApFAAkAAggQAABmAAgl
; Markers = 2101
; EnableXP
; DPIAware