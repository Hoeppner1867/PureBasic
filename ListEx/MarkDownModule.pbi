;/ ============================
;/ =    MarkDownModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x - V6.0 / 64Bit / All OS / DPI ]
;/
;/  Gadget, Requester, Tooltips, 2D Drawing & HelpWindow for Markdown
;/
;/ © 2022 by Thorsten Hoeppner (12/2019)
;/

; Last Update: 16.05.2022
;
; - New Scrollbar
; - New DPI managment
; - Bugfixes
;
; - Added: ToolTip() -  Tooltips with Markdown
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

;{ ===== Tea & Pizza Ware =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ MarkDown - Commands _____

; MarkDown::UsedImages()         - determines all images used in the markdown text
; MarkDown::InsertAsPDF()        - Insert converted markdown text into PDF
; MarkDown::InsertAsHTML()       - Insert converted markdown text into HTML
; MarkDown::SetPath()            - set path for images without path name

; ----- Gadget (#Enable_Gadget)-----

; MarkDown::AttachPopupMenu()
; MarkDown::Clear()              - similar to 'ClearGadgetItems()'
; MarkDown::Convert()            - convert markdown to HTML or PDF (without gadget)
; MarkDown::EventValue()         - returns links
; MarkDown::Export()             - export to HTML or PDF 
; MarkDown::Gadget()             - new MarkDown gadget
; MarkDown::GetData()            - similar to 'GetGadgetData()'
; MarkDown::GetText()            - similar to 'GetGadgetText()' [#MarkDown/#HTML]
; MarkDown::GetID()              - similar to 'GetGadgetData()', but string
; MarkDown::GotoHeading()        - goto heading with this ID
; MarkDown::Hide()               - similar to 'HideGadget()'
; MarkDown::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; MarkDown::SetAttribute()       - similar to 'SetGadgetAttribute()'
; MarkDown::SetColor()           - similar to 'SetGadgetColor()'
; MarkDown::SetData()            - similar to 'SetGadgetData()'
; MarkDown::SetFont()            - similar to 'SetGadgetFont()'
; MarkDown::SetID()              - similar to 'SetGadgetData()', but string
; MarkDown::SetMargins()         - defines the margins
; MarkDown::SetPath()            - Set the path to the Markdown file, for relative path names
; MarkDown::SetText()            - similar to 'SetGadgetText()'
; MarkDown::UseImage()           - uses an already loaded image

; ----- Requester (#Enable_Requester) -----

; MarkDown::Requester()

; ----- Help Window (#Enable_HelpWindow) -----

; MarkDown::Help()
; MarkDown::ChangeHelpTopic()
; MarkDown::EventLabel()

; ----- Tooltip (#Enable_Tooltips) -----

; MarkDown::Tooltip()
; MarkDown::TooltipColor()
; MarkDown::TooltipFont()

; ----- Draw Markdown on CanvasGadget  (#Enable_DrawCanvas) -----

; MarkDown::Text()
; MarkDown::LoadFonts()
; MarkDown::Height()
; MarkDown::Width()

;}


;{ _____ Available Emojis _____

; :bookmark: / :date: / :mail: / :memo: / :pencil: / :phone: / :warning: / :bulb: / :paperclip: / :mag:
; :angry: / :cool: / :eyes: / :laugh: / / :rofl: / :sad: / :smile: / :smirk: / :wink: / :worry:

;}


; XIncludeFile "ModuleEx.pbi"
; XIncludeFile "TreeExModule.pbi"
; XIncludeFile "NamedPipeModule.pbi"

; ***** If no PDF is required, this line can be commented out. *****
;CompilerIf Not Defined(PDF, #PB_Module) : XIncludeFile "pbPDFModule.pbi" : CompilerEndIf


DeclareModule MarkDown
  
  #Version  = 22042800
  #ModuleEx = 20041700
  
  #Enable_Gadget      = #False
  #Enable_Requester   = #False
  #Enable_Tooltips    = #False
  #Enable_HelpWindow  = #False
  #Enable_CreateHelp  = #False
  #Enable_Emoji       = #True
  #Enable_ExportHTML  = #False
  #Enable_DrawCanvas  = #True
  
	;- ===========================================================================
	;-   DeclareModule - Constants
  ;- ===========================================================================
	
  Enumeration 1 ;{ ScrollBar
    #Vertical   = #PB_ScrollBar_Vertical
    #Horizontal
	  #ScrollBar_Up
	  #ScrollBar_Down
	  #ScrollBar_Left
	  #ScrollBar_Right
	EndEnumeration ;}
	
  ;{ _____ Constants _____
  #Bullet$ = "•"
  
  #Help = -1
  
	EnumerationBinary ;{ Gadget Flags
		#AutoResize        ; Automatic resizing of the gadget
		#Borderless        ; Draw no border
		#UseExistingCanvas ; e.g. for dialogs
		#IgnorePath
		#CompletePath
		; Requester
		#YesNo
	  #YesNoCancel
	  #Info
	  #Question
	  #Error 
	  #Warning
	  ; Scrollbaar
	  #Style_Win11
	  #Style_RoundThumb
	  ; Window
	  #KeywordsOnly  ; Search: Only keywords, no topics 
	EndEnumeration ;}
	
	Enumeration       ;{ Type
	  #Gadget
	  #Requester
	  #ToolTip
	  #DrawCanvas
	  #HelpWindow
	EndEnumeration  ;}
	
	Enumeration 1     ;{ Format
	  #MarkDown
	  #HTML
	  #PDF
	  #List
	  #Tree
	EndEnumeration ;}
	
	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}
	
	Enumeration 1     ;{ Attribute
	  #Margin_Left
	  #Margin_Right
	  #Margin_Top
	  #Margin_Bottom
	  #Indent
	  #LineSpacing
	  #ScrollBar
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#Color_Back
		#Color_BlockQuote
		#Color_Border
		#Color_Code
		#Color_Front
		#Color_HighlightBack
		#Color_Tooltip
		#Color_KeyStroke
		#Color_KeystrokeBack
		#Color_Keyword
		#Color_Line
		#Color_Link
		#Color_HighlightLink
		#Color_LineColor
		#Color_HeaderBack
		#ScrollBar_FrontColor
    #ScrollBar_BackColor 
    #ScrollBar_BorderColor
    #ScrollBar_ButtonColor
    #ScrollBar_ThumbColor
	EndEnumeration ;}
	
	EnumerationBinary ;{ Convert
	  #Create
	  #Content
	  #Close
	EndEnumeration ;}  
	
	Enumeration 1   ;{ Cursor States
	  #Focus
    #Click
    #Hover
  EndEnumeration ;}
	
	CompilerIf #Enable_Requester
	  
	  #ButtonWidth  = 70
	  #ButtonHeight = 20
	  
	  #OK = 0

	  Enumeration 2   ;{ Result
    	#Result_Yes
    	#Result_No
    	#Result_Cancel
    EndEnumeration ;}
	  
	CompilerEndIf
	
	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget   = ModuleEx::#Event_Gadget
		#Event_Theme    = ModuleEx::#Event_Theme
		#Event_Timer    = ModuleEx::#Event_Timer
		#Event_Message  = ModuleEx::#Event_Message
		#Event_ToolTip  = ModuleEX::#Event_ToolTip
		#EventType_Link = ModuleEx::#EventType_Link
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
		  #Event_Gadget
		  #Event_Timer
		  #Event_ToolTip
		  #Event_Message
		EndEnumeration
		
		Enumeration #PB_EventType_FirstCustomValue
      #EventType_Link
    EndEnumeration
		
	CompilerEndIf
	;}
	
  ;- ===========================================================================
	;-   DeclareModule - Structure
  ;- ===========================================================================
	
	Structure Item_Structure               ;{ Help\Item()\...
    Titel.s
    Label.s
    Text.s
    Level.i
  EndStructure ;}
  
	Structure Words_Structure              ;{ Word Structure
    Font.i
    String.s
    Index.i
    Width.i
    Flag.i
  EndStructure ;}
  
  Structure Links_Structure              ;{ ...\Links\...
    String.s
    Destination.s
    Label.s
    Valid.i
  EndStructure ;}
  
  Structure TOC_Structure                ;{ ...\TOC()\...
    ID.s
    Level.i
    Label.s
    X.i
    Y.i
    Width.i
    Height.i
    List Words.Words_Structure()
  EndStructure ;}
 
  Structure Glossary_Structure           ;{ ...\Glossary()\...
    Label.s
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Keyword_Label_Structure      ;{ ...\Keyword()\...
    Name.s
    Page.i
    HeadingID.s
  EndStructure
  
  Structure Keywords_Structure           
    List Label.Keyword_Label_Structure()
  EndStructure ;}
  
	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
	
	Declare.i UsedImages(Markdown.s, Path.s, Map Images.s(), Flags.i=#False)
	Declare   Convert(MarkDown.s, Type.i, Path.s, File.s="", Title.s="")
	Declare   InsertAsPDF(PDF.i, MarkDown.s, LeftMargin.i=10, RightMargin.i=10, FontSize.i=12)
	Declare.s InsertAsHTML(MarkDown.s)
	Declare   SetPath(GNum.i, Path.s)
	Declare   SetText(GNum.i, Text.s, Path.s="")

	CompilerIf #Enable_Gadget
    Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
    Declare   Clear(GNum.i)    
    Declare.s EventValue(GNum.i)
	  Declare.s EventLabel(GNum.i)
    Declare   Export(GNum.i, Type.i, File.s="", Title.s="")
    Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Declare.q GetData(GNum.i)
    Declare.s GetID(GNum.i)
    Declare.s GetText(GNum.i, Type.i=#MarkDown, Title.s="")
    Declare   GotoHeading(GNum.i, ID.s)
    Declare   Hide(GNum.i, State.i=#True) 
    Declare   SetAutoResizeFlags(GNum.i, Flags.i)
    Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
    Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
    Declare   SetData(GNum.i, Value.q)
    Declare   SetFont(GNum.i, Name.s, Size.i) 
    Declare   SetID(GNum.i, String.s)
    Declare   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
    Declare   UseImage(GNum.i, FileName.s, ImageNum.i)
  CompilerEndIf  

  CompilerIf #Enable_Requester
    
    Declare.i AddRequesterButton(Label.s, Text.s="", Result.i=#PB_Default, Width.i=#PB_Default)  
    Declare   AddRequesterImage(Label.s, Image.i) 
    
    Declare   RequesterButtons(TextOK.s, TextYes.s="", TextNo.s="", TextCancel.s="", ButtonWidth.i=#PB_Default)
    Declare   RequesterPadding(Padding.i)
    Declare.i Requester(Title.s, Text.s, Flags.i=#False, Parent.i=#PB_Default, Image.s="", Buttons.s="")
    
  CompilerEndIf
  
  CompilerIf #Enable_Tooltips
    
    Declare.i Tooltip(Gadget.i, Text.s, Window.i)
    
    Declare   TooltipColor(ColorTyp.i, Value.i)
    Declare   TooltipFont(Name.s, Size.i)
    
  CompilerEndIf  
  
  CompilerIf #Enable_HelpWindow

    CompilerIf Defined(PDF, #PB_Module)
      Declare.s Help2PDF(Title.s, File.s, FilePDF.s="", Orientation.s="P", Format.s="")
    CompilerEndIf  
    
    CompilerIf #Enable_ExportHTML
      Declare.s Help2HTML(Title.s, File.s, Folder.s="HTML", FileHTML.s="")
    CompilerEndIf
    
    Declare   SetAppDataDir(Path.s)
    Declare   SetAppDataName(FileName.s)
    Declare   SetHelpFont(Font.i, Type.i=#False)
    Declare   ChangeHelpTopic(Label.s)
    Declare.s Help(Title.s, File.s, Label.s="", Flags.i=#False, Parent.i=#PB_Default)
    
  CompilerEndIf
  
  CompilerIf #Enable_CreateHelp

    Declare.i CreateHelp(File.s)
    Declare.i AddHelpItem(Title.s, Markdown.s, Label.s="", Level.i=0)
    Declare   SaveHelp()
    
  CompilerEndIf 
  
  CompilerIf #Enable_DrawCanvas
    
    Declare   Text(X.i, Y.i, Text.s, FrontColor.i=#PB_Default, BackColor.i=#PB_Default, Width.i=#PB_Default, Height.i=#PB_Default)
    Declare   LoadFonts(Name.s, Size.i)
    Declare.i Height(Canvas.i, Text.s="")
    Declare.i Width(Canvas.i,  Text.s="")
    
  CompilerEndIf  
  
  ;{ Internal
  Declare MergeHelp(List Items.Item_Structure(), List TOC.TOC_Structure(), Map Glossary.Glossary_Structure(), Map Keywords.Keywords_Structure(), List Links.Links_Structure())
  Declare UpdateHelp(GNum.i, List TOC.TOC_Structure(), Map Glossary.Glossary_Structure(), List Found.s(), Export.i=#False)
  ;}
  
EndDeclareModule

Module MarkDown

	EnableExplicit
	
	UsePNGImageDecoder()
	UseJPEGImageDecoder()
	
	CompilerIf #Enable_HelpWindow Or #Enable_CreateHelp
	  UseZipPacker()
	CompilerEndIf  
	
	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	

  #ScrollBarSize   = 16
	
	#AutoScrollTimer = 1867
	#Frequency       = 100  ; 100ms
	#TimerDelay      = 3    ; 100ms * 3
	
	Enumeration 1     ;{ Direction
	  #Up
	  #Left
	  #Right
	  #Down
	  #Forwards
	  #Backwards
	EndEnumeration ;}
	
	
	#Return = 0
  
  #Caution$ = Chr($26A0)
  #Circle$  = Chr($26AA)
  #Cut$     = Chr($2026)
  #CodeBlock = 2
  #Parse     = 0
  
  Enumeration 1 ;{ MarkDown
    #Abbreviation
    #BlockQuote
    #Block
    #Bold
    #BoldItalic
    #Code
    #CodeHeader
    #DefinitionList
    #Emoji
    #FootNote
    #Glossary
    #Heading
    #Highlight
    #Note
    #NoteHeader
    #Line
    #Image
    #Italic
    #Keystroke
    #Keyword
    #LineBreak
    #Link
    #OrderedList
    #Paragraph
    #StrikeThrough
    #Subscript
    #Superscript
    #Table
    #TableHeader
    #TaskList
    #Text
    #Underline
    #UnorderedList
    #AutoLink
    #InsertGlossary
    #InsertKeywords
    #InsertTOC
  EndEnumeration ;}
  
  Enumeration 1 ;{ Font
    #Font_Normal
	  #Font_Bold
	  #Font_Italic
	  #Font_BoldItalic
	  #Font_Code
	  #Font_FootNote
	  #Font_FootText
	  #Font_FootBold
	  #Font_FootItalic
	  #Font_FootBoldItalic
	  #FontNote
	  #Font_H6
	  #Font_H5
	  #Font_H4
	  #Font_H3
	  #Font_H2
	  #Font_H1
  EndEnumeration ;} 
  
  Enumeration 1
    #UseDraw
    #UsePDF
  EndEnumeration  
  
  CompilerIf #Enable_Tooltips
    
    Enumeration 1
      #MouseX
      #MouseY
    EndEnumeration
  
    EnumerationBinary
      #MouseEnter
      #MouseLeave
      #MouseMove
    EndEnumeration
    
    #MouseEvents = #MouseEnter|#MouseLeave|#MouseMove
    
    #TooltipTimer    = 1867
	  #MouseEventTimer = 1868
    
  CompilerEndIf
  
  CompilerIf #Enable_DrawCanvas
    #DrawText = "DrawMD"
  CompilerEndIf  
  
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================	
  
  ; ----- ScrollBar -----
  
	Structure Area_Structure                ;{
	  X.i
	  Y.i
	  Width.i
	  Height.i
	EndStructure ;}  
	
	Structure Size_Structure                ;{
	  Width.i
	  Height.i
	EndStructure ;}
	
	
	Structure ScrollBar_Thumb_Structure     ;{ MarkDown()\HScroll\Forwards\Thumb\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollBar_Button_Structure    ;{ MarkDown()\HScroll\Buttons\...
	  Width.i
	  Height.i
	  ; forward: right & down
	  fX.i
	  fY.i
	  fState.i
	  ; backward: left & up
	  bX.i
	  bY.i
	  bState.i
	EndStructure ;}
	
	Structure ScrollBar_Color_Structure     ;{ MarkDown()\HScroll\Color\...
	  Front.i
	  Back.i
		Button.i
		Focus.i
		Hover.i
		Arrow.i
	EndStructure ;}

	
	Structure MarkDown_ScrollBar_Structure  ;{ MarkDown()\HScroll\...
	  X.i
	  Y.i
	  Width.i
	  Height.i  
	  
	  Pos.i        ; Scrollbar position
	  minPos.i     ; max. Position
	  maxPos.i     ; min. Position
	  Range.i      ; maxPos - minPos
	  Ratio.f      ; PageLength / Maximum
	  Factor.f     ; (ScrollbarArea - ThumbSize) / Range
	  
	  Focus.i      ; Scrollbar Focus
	  CursorPos.i  ; Last Cursor Position
	  Timer.i      ; AutoScroll Timer
	  Delay.i      ; AutoScroll Delay
	  
	  Hide.i       ; Hide Scrollbar
	  Minimum.i    ; min. Value
	  Maximum.i    ; max. Value
	  PageLength.i ; Visible Size
	  
	  Area.Area_Structure                  ; Area between scroll buttons
	  Buttons.ScrollBar_Button_Structure  ; right & down
	  Thumb.ScrollBar_Thumb_Structure      ; thumb position & size
	EndStructure ;}

	Structure MarkDown_ScrollBars_Structure ;{ MarkDown()\ScrollBar\...
	  Color.ScrollBar_Color_Structure
	  Size.i       ; Scrollbar width (vertical) / height (horizontal)
	  TimerDelay.i ; Autoscroll Delay
	  Flags.i      ; Flag: #Vertical | #Horizontal
	EndStructure ;}

  ; ---------------------
  
  
  CompilerIf #Enable_HelpWindow
    
    Structure Help_Font_Structure
      Tree.i
      ListView.i
      Name.s
      Size.i
    EndStructure
    
    Structure Help_Sort_Structure
      Topic.s
      Index.i
    EndStructure
    
    Structure Help_Image_Structure
      GoHome.i
      GoNext.i
      GoPrevious.i
      Search.i
      Close.i
    EndStructure
    
    Structure Help_Window_Structure
      X.i
      Y.i
      Width.i
      Height.i
    EndStructure
    
    Structure Help_Structure
      TreeNum.i
      CanvasNum.i
      HomeNum.i
      NextNum.i
      PrevNum.i
      SearchNum.i
      InputNum.i
      ListNum.i
      Search.i
      File.s
      DataDir.s
      DataName.s
      Font.Help_Font_Structure
      Window.Help_Window_Structure
      Image.Help_Image_Structure
      Map  Label.i()
      List History.i()
      List Item.Item_Structure()
    EndStructure  
    Global Help.Help_Structure
    
  CompilerEndIf  
 
  CompilerIf #Enable_Requester
    
    Structure MarkDown_Requester_Image_Structure  ;{ MarkDown()\Requester\Image\...
  	  Num.i
  	  Width.i
  	  Height.i
  	EndStructure ;}
    
    Structure MarkDown_Requester_Button_Structure ;{ MarkDown()\Requester\Button\...
  	  X.i
  	  Text.s
  	  Width.i
  	  State.i
  	  Result.i
  	  Visible.i
  	EndStructure ;}
    
    Structure MarkDown_Requester_Structure        ;{ MarkDown()\Requester\...
      FontID.i
      Padding.i
      ButtonY.i
      Result.i
      UserButtons.s
      ButtonsWidth.i
      Image.MarkDown_Requester_Image_Structure
      Map Button.MarkDown_Requester_Button_Structure()
    EndStructure ;} 
    
    Structure Requester_Button_Structure
      Text.s
      Result.i
      Width.i
    EndStructure
    
    Structure Requester_Structure
      LastResult.i
      ButtonWidth.i
      Padding.i
      Map Image.MarkDown_Requester_Image_Structure()
      Map Button.Requester_Button_Structure()
    EndStructure
    Global Requester.Requester_Structure
    
  CompilerEndIf
  
  CompilerIf #Enable_Tooltips
    
    Structure ToolTips_Style_Structure    ;{ TooltypStyle()\...
      FontName.s
      FontSize.i
      FrontColor.i
      BackColor.i
      BorderColor.i
    EndStructure ;}
    Global TooltypStyle.ToolTips_Style_Structure
    
    ;{ Defaults TooltipStyle
    TooltypStyle\FontName    = ""
    TooltypStyle\FontSize    = #PB_Default
    TooltypStyle\FrontColor  = #PB_Default
    TooltypStyle\BackColor   = #PB_Default
    TooltypStyle\BorderColor = #PB_Default
    ;}
    
    Structure MouseEvent_Window_Structure ;{ MouseEvent()\Window\...
      Num.i
      MouseX.i
      MouseY.i
    EndStructure ;}
    
    Structure MouseEvent_Gadget_Structure ;{ MouseEvent()\Gadget('num')\...
      Num.i
      MouseX.i
      MouseY.i
    EndStructure ;}
    
    Structure MouseEvent_Structure        ;{ MouseEvent('Window')\...
      Window.MouseEvent_Window_Structure
      Map Gadget.MouseEvent_Gadget_Structure()
      lastGadget.i
      lastHandle.i
      Flags.i
    EndStructure ;}
    Global NewMap MouseEvent.MouseEvent_Structure()
    
    Structure Timer_Structure             ;{ Timer()\...
  	  GadgetNum.i
  	  WindowNum.i
  	  Focus.i
  	  State.i
  	  Active.i
  	  Delay.i
  	  Value.i
  	EndStructure ;}
  	Global NewMap Timer.Timer_Structure()

    Structure Tooltips_Structure          ;{ Tooltips()\...
      WindowNum.i ; Tooltip Window
      CanvasNum.i ; Markdown Canvas
      Window.i
      Gadget.i
      PosX.i
      PosY.i
      MouseX.i
      MouseY.i
      Visible.i
    EndStructure ;}
    Global NewMap Tooltips.Tooltips_Structure()
    
    Global Mutex.i = CreateMutex()
    
    Structure MarkDown_Tooltip_Structure  ;{ Tooltips()\...
      Gadget.i
      Window.i
    EndStructure ;}
    
  CompilerEndIf
  
  Structure CellBorder_Structure          ;{ Map CellBorder()
    X.i
    Width.i
    Border.i
  EndStructure ;}
  
  Structure List_Structure                ;{ Lists\...
    Marker.s ; ul: - or + or * / ol: . or ) 
    Indent.i
    Start.i
    Level.i
  EndStructure ;}
  
  Structure Document_Structure            ;{ Document()\...
    Type.i
    BlockQuote.i
    Marker.s
    Level.i
    String.s
  EndStructure ;}
  Global NewList Document.Document_Structure()
  
  
  Structure Note_Rows_Structure           ;{ MarkDown()\Note()\Words()\...
    Width.i
    Height.i
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Note_Structure                ;{ MarkDown()\Note()\...
    Type.s
    Width.i
    Height.i
    List Row.Note_Rows_Structure()
  EndStructure ;}
  
  Structure Block_Structure               ;{ MarkDown()\Block()\...
    Font.i
    String.s
    List Row.s()
  EndStructure ;}

  Structure FootLabel_Structure           ;{ MarkDown()\FootLabel('label')\...
    Width.i
    Height.i
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Label_Structure               ;{ MarkDown()\Label('label')\...
    Destination.s
    Title.s
    String.s
  EndStructure ;}

  Structure Keyword_Structure             ;{ MarkDown()\Keyword('keyword')\...
    Found.i
    List HeadingID.s()
  EndStructure ;}
  
  Structure Footnote_Structure            ;{ MarkDown()\Footnote()\...
    X.i
    Y.i
    Width.i
    Height.i
    Label.s
  EndStructure ;}

  Structure Abbreviation_Structure        ;{ MarkDown()\Abbreviation()\...
    String.s
  EndStructure ;}
  
  Structure Word_Link_Structure           ;{ MarkDown()\...\...
    X.i
    Y.i
    Width.i
    Height.i
    Word.s
  EndStructure ;}
  
  Structure Image_Structure               ;{ MarkDown()\Image()\...
    X.i
    Y.i
    Width.i
    Height.i
    Label.s
    Source.s
    Title.s
  EndStructure ;}
  
  Structure Link_Structure                ;{ MarkDown()\Link()\...
    X.i
    Y.i
    Width.i
    Height.i
    URL.s
    Title.s
    String.s
    Label.s
    State.i
  EndStructure ;}

  Structure Lists_Row_Structure           ;{ MarkDown()\Lists()\Row()\...
    BlockQuote.i
    Width.i
    Height.i
    Level.i
    State.i
    String.s
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Lists_Structure               ;{ MarkDown()\Lists()\..
    Start.i
    List Row.Lists_Row_Structure()
  EndStructure ;}
  
  Structure Margin_Structure              ;{ MarkDown()\Margin\...
		Top.i
		Left.i
		Right.i
		Bottom.i
	EndStructure ;}

  Structure Table_Item_Structure          ;{ MarkDown()\Table()\Row()\Col('num')\Item()\...
    Type.i
    String.s
    Index.i
  EndStructure ;}
  
  Structure Table_Cols_Structure          ;{ MarkDown()\Table()\Row()\Col('num')\...
    Width.i
    Span.i
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Table_Row_Structure           ;{ MarkDown()\Table()\Row()\...
    Type.i
    Height.i
    Map Col.Table_Cols_Structure()
  EndStructure ;}
  
  Structure Table_Column_Structure        ;{ MarkDown()\Table()\Column\...
    Align.s
    Width.i
  EndStructure ;}
  
  Structure Table_Structure               ;{ MarkDown()\Table()\...
    Cols.i
    Width.i
    Map Column.Table_Column_Structure()
    List Row.Table_Row_Structure()
  EndStructure ;}
  
  Structure MarkDown_Items_Structure      ;{ MarkDown()\Items()\...
    ID.s
    Type.i
    Level.i
    BlockQuote.i
    Width.i
    Height.i
    Index.i
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure MarkDown_ImageMem_Structure   ;{ MarkDown()\ImageMem()\...
    Type.i
    *Buffer
    Size.i
  EndStructure ;}
  
  Structure MarkDown_Required_Structure   ;{ MarkDown()\Required\...
    Width.i
    Height.i
  EndStructure ;}
  
  Structure MarkDown_Font_Structure       ;{ MarkDown()\Font\...
    ; FontNums
    Normal.i
    Bold.i
    Italic.i
    BoldItalic.i
    Code.i
    Note.i
    FootNote.i
    FootText.i
    FootBold.i
    FootItalic.i
    FootBoldItalic.i
    H1.i
    H2.i
    H3.i
    H4.i
    H5.i
    H6.i
  EndStructure ;}
  
	Structure MarkDown_Color_Structure      ;{ MarkDown()\Color\...
	  Back.i
	  BlockQuote.i
	  Border.i
	  Button.i
		Code.i
		DisableBack.i
		DisableFront.i
		Focus.i
		Front.i
		Found.i
		FoundBack.i
		Gadget.i
		HeaderBack.i
		Highlight.i
		Hint.i
		Keystroke.i
		KeyStrokeBack.i
		Keyword.i
		Link.i
		LinkHighlight.i
		Line.i
	EndStructure  ;}
	
	Structure MarkDown_Scroll_Structure     ;{ MarkDown()\ScrollBar\Item()\...
	  Num.i
	  MinPos.i
    MaxPos.i
    Offset.i
    Height.i
    Hide.i
  EndStructure ;}
	
	Structure MarkDown_Window_Structure     ;{ MarkDown()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure MarkDown_Size_Structure       ;{ MarkDown()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}
	
	
	Structure MarkDown_Structure            ;{ MarkDown()\...
		CanvasNum.i
		PopupNum.i
		
		ID.s
		Quad.i
		PageLabel.s
		
		Type.i
		Path.s
		Text.s
		
		BlockQuote.i
		LeftBorder.i
		WrapPos.i
		WrapHeight.i
		
		Indent.i
		LineSpacing.f
		
		Hide.i
		Disable.i
		ToolTip.i
		
		EventValue.s
		EventLabel.s
		
		; --- Scrollbar ---
    Area.Area_Structure ; available area
	  Scrollbar.MarkDown_ScrollBars_Structure
	  HScroll.MarkDown_ScrollBar_Structure
	  VScroll.MarkDown_ScrollBar_Structure
	  ScrollOffsetY.i
	  ScrollOffsetX.i
	  ScrollH.i
	  ScrollV.i
    ; ---------
		
		Flags.i

		Color.MarkDown_Color_Structure
		Font.MarkDown_Font_Structure
		Margin.Margin_Structure
		Required.MarkDown_Required_Structure
		Size.MarkDown_Size_Structure
		Window.MarkDown_Window_Structure
		
		CompilerIf #Enable_Tooltips
		  Tooltips.MarkDown_Tooltip_Structure
		CompilerEndIf  
		
		CompilerIf #Enable_Requester
		  Requester.MarkDown_Requester_Structure
		CompilerEndIf  
		
		Map  Abbreviation.Abbreviation_Structure()
		Map  FootLabel.FootLabel_Structure()
		Map  Glossary.Glossary_Structure()
		Map  ImageMem.MarkDown_ImageMem_Structure()
		Map  ImageNum.i()
		Map  Label.Label_Structure()
		Map  Keyword.Keyword_Structure()
		Map  HeadingID.i()
		
		List AbbrevWord.Word_Link_Structure()
		List Block.Block_Structure()
		List Footnote.Footnote_Structure()
		List GlossaryWord.Word_Link_Structure()
		List Image.Image_Structure()
		List Items.MarkDown_Items_Structure()
    List Link.Link_Structure()
    List Lists.Lists_Structure()
    List Table.Table_Structure()
    List TOC.TOC_Structure()
    List Note.Note_Structure()
    
	EndStructure ;}
	Global NewMap MarkDown.MarkDown_Structure()
	
	Global NewMap Emoji.i()
	
	Global Mutex.i = CreateMutex()
	
	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================

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
		
		#NSApplicationActivateAllWindows = 1 << 0
    #NSApplicationActivateIgnoringOtherApps = 1 << 1
		
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
        PB_Gadget_Objects.i
      EndImport
    CompilerElse
      ImportC ""
        PB_Object_EnumerateStart( PB_Objects )
        PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
        PB_Object_EnumerateAbort( PB_Objects )
        PB_Window_Objects.i
        PB_Gadget_Objects.i
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
  
	
	Procedure TextHeight_(Text.s)
	  ProcedureReturn DesktopUnscaledY(TextHeight(Text))
	EndProcedure
	
	Procedure TextWidth_(Text.s)
	  ProcedureReturn DesktopUnscaledX(TextWidth(Text))
	EndProcedure  
	
	Procedure DrawText_(X.i, Y.i, Text.s, FrontColor.i=#PB_Default, BackColor.i=#PB_Default)
	  Define.i PosX
	  
	  If FrontColor = #PB_Default
	    PosX = DrawText(dpiX(X), dpiY(Y), Text)
	    ProcedureReturn DesktopUnscaledX(PosX)
	  ElseIf BackColor = #PB_Default
	    PosX = DrawText(dpiX(X), dpiY(Y), Text, FrontColor)
	    ProcedureReturn DesktopUnscaledX(PosX)
	  Else
	    PosX = DrawText(dpiX(X), dpiY(Y), Text, FrontColor, BackColor)
	    ProcedureReturn DesktopUnscaledX(PosX)
	  EndIf 
	  
	EndProcedure  
	
	Procedure LineXY_(x1.i, y1.i, x2.i, y2.i, Color.i=#PB_Default)
	  If Color.i=#PB_Default
	    LineXY(dpiX(x1), dpiY(y1), dpiX(x2), dpiY(y2))
	  Else
	    LineXY(dpiX(x1), dpiY(y1), dpiX(x2), dpiY(y2), Color)
	  EndIf   
	EndProcedure
	
	Procedure Line_(X.i, Y.i, Width.i, Height.i, Color.i=#PB_Default)
	  If Color = #PB_Default
	    Line(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height))
	  Else  
	    Line(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), Color)
	  EndIf   
	EndProcedure  
	
	Procedure DrawImage_(ImageID.i, X.i, Y.i, Width.i=#PB_Default, Height.i=#PB_Default)
	  If Width = #PB_Default And Height = #PB_Default
	    DrawImage(ImageID, dpiX(X), dpiY(Y))
	  Else
	    DrawImage(ImageID, dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height))
	  EndIf  
	EndProcedure  
	
	
	Procedure ClipOutput_(X, Y, Width, Height)
    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
      ClipOutput(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height)) 
    CompilerEndIf
  EndProcedure
  
  Procedure UnclipOutput_()
    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
      UnclipOutput() 
    CompilerEndIf
  EndProcedure
	
	
	Procedure.i mm_(Pixel.i)
	  ;px = mm * 96 / 25,4mm
	  ProcedureReturn Round(Pixel * 25.4 / 96, #PB_Round_Nearest)
	EndProcedure
	
	
	Procedure.s GetAbsolutePath_(Path.s, File.s, Flags.i=#False)
    Define.i i, PS
    Define.s PathPart$, Path$
    
    If Flags & #IgnorePath
      ProcedureReturn GetFilePart(File)
    EndIf  
    
    PathPart$ = GetPathPart(File)
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      PathPart$ = ReplaceString(PathPart$, "/", "\")
    CompilerElse
      PathPart$ = ReplaceString(PathPart$, "\", "/")
    CompilerEndIf  
    
    If PathPart$
      
      If CountString(PathPart$, ":" + #PS$) = 1 Or Left(PathPart$, 2) = #PS$ + #PS$ ;{ Absolute path name
        
        ProcedureReturn File
        ;}
      Else                                                                          ;{ Relative path name
        
        If Left(PathPart$, 3) = ".." + #PS$    ;{ A relative path to a file in a directory that is a peer of the current directory
  
          Path$ = ""
          Path  = ReplaceString(Path, #PS$ + #PS$, "|" + #PS$)
          
          PS = CountString(Path, #PS$)
          If PS > 1
            For i=1 To PS - 1
              Path$ + StringField(Path, i, #PS$) + #PS$
            Next
            ProcedureReturn ReplaceString(Path$, "|", #PS$) + Mid(File, 4)
          Else
            ProcedureReturn ReplaceString(Path,  "|", #PS$) + Mid(File, 4)
          EndIf  
          ;}
        ElseIf Left(PathPart$, 2) = "." + #PS$ ;{ A relative path to a file in the current directory    
          ProcedureReturn Path + Mid(File, 3)
          ;}
        ElseIf Left(PathPart$, 1) = #PS$       ;{ An absolute path from the root of the current drive
  
          Path  = ReplaceString(Path, #PS$ + #PS$, "|" + #PS$)
          Path$ = StringField(Path, 1, #PS$) + #PS$
          
          ProcedureReturn ReplaceString(Path$, "|", #PS$) + Mid(File, 2)
          ;}
        ElseIf Mid(PathPart$, 2, 1) = ":"      ;{ A relative path from the current directory of the drive
          
          Path$ = Left(PathPart$, 2) + Mid(Path, 3)
          
          ProcedureReturn  Path$ + Mid(File, 3)
          ;}  
        Else                                   ;{ A relative path to a file in a subdirectory of the current directory
          ProcedureReturn Path + File
          ;}
        EndIf
        ;}
      EndIf
      
    Else
      ProcedureReturn Path + File
    EndIf  
    
  EndProcedure  
  
  Procedure.s AdjustImagePath(File.s) 
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      ProcedureReturn ReplaceString(File, "/", "\")
    CompilerElse
      ProcedureReturn ReplaceString(File, "\", "/")
    CompilerEndIf

  EndProcedure
  
  
	Procedure.s WordOnly_(Word.s)
    ; word with or without punctuation etc.
    Define.i i 
    Define.s Char$, Diff1$, Diff2$
    
    Word = Trim(Word)

    For i=1 To 2
      Char$ = Left(Word, 1)
      Select Char$
        Case "{", "[", "(", "<"
          Word = LTrim(Word, Char$)
        Case Chr(34), "'", "«", "»"
          Word = LTrim(Word, Char$)
        Default
          Break
      EndSelect
    Next
    
    For i=1 To 2
      Char$ = Right(Word, 1)
      Select Char$
        Case ".", ":", ",", ";", "!", "?"
          Word = RTrim(Word, Char$)
        Case  ")", "]", "}", ">"
          Word = RTrim(Word, Char$)
        Case Chr(34), "'", "«", "»"
          Word = RTrim(Word, Char$)
        Case " "
          Word = LTrim(Word, Char$)
        Default
          Break
      EndSelect
    Next

    ProcedureReturn Word
  EndProcedure
  
	Procedure   FreeFonts_()
	  
	  If IsFont(MarkDown()\Font\Normal)         : FreeFont(MarkDown()\Font\Normal)         : EndIf
	  If IsFont(MarkDown()\Font\Bold)           : FreeFont(MarkDown()\Font\Bold)           : EndIf
	  If IsFont(MarkDown()\Font\Italic)         : FreeFont(MarkDown()\Font\Italic)         : EndIf
	  If IsFont(MarkDown()\Font\BoldItalic)     : FreeFont(MarkDown()\Font\BoldItalic)     : EndIf
	  If IsFont(MarkDown()\Font\Code)           : FreeFont(MarkDown()\Font\Code)           : EndIf
	  If IsFont(MarkDown()\Font\FootNote)       : FreeFont(MarkDown()\Font\FootNote)       : EndIf
	  If IsFont(MarkDown()\Font\FootText)       : FreeFont(MarkDown()\Font\FootText)       : EndIf
	  If IsFont(MarkDown()\Font\FootBold)       : FreeFont(MarkDown()\Font\FootBold)       : EndIf
	  If IsFont(MarkDown()\Font\FootItalic)     : FreeFont(MarkDown()\Font\FootItalic)     : EndIf
	  If IsFont(MarkDown()\Font\FootBoldItalic) : FreeFont(MarkDown()\Font\FootBoldItalic) : EndIf
	  
	  If IsFont(MarkDown()\Font\H6) : FreeFont(MarkDown()\Font\H6) : EndIf
	  If IsFont(MarkDown()\Font\H5) : FreeFont(MarkDown()\Font\H5) : EndIf
	  If IsFont(MarkDown()\Font\H4) : FreeFont(MarkDown()\Font\H4) : EndIf
	  If IsFont(MarkDown()\Font\H3) : FreeFont(MarkDown()\Font\H3) : EndIf
	  If IsFont(MarkDown()\Font\H2) : FreeFont(MarkDown()\Font\H2) : EndIf
	  If IsFont(MarkDown()\Font\H1) : FreeFont(MarkDown()\Font\H1) : EndIf
	  
	EndProcedure
	
	Procedure   LoadFonts_(Name.s, Size.i)
    
	  MarkDown()\Font\Normal     = LoadFont(#PB_Any, Name, Size)
	  MarkDown()\Font\Bold       = LoadFont(#PB_Any, Name, Size, #PB_Font_Bold)
	  MarkDown()\Font\Italic     = LoadFont(#PB_Any, Name, Size, #PB_Font_Italic)
	  MarkDown()\Font\BoldItalic = LoadFont(#PB_Any, Name, Size, #PB_Font_Bold|#PB_Font_Italic)
	  MarkDown()\Font\Code       = LoadFont(#PB_Any, "Courier New", Size + 1)
	  MarkDown()\Font\Note       = LoadFont(#PB_Any, "Arial", Size + 4, #PB_Font_Bold)
	  
	  MarkDown()\Font\FootNote       = LoadFont(#PB_Any, Name, Round(Size / 1.5, #PB_Round_Up), #PB_Font_Bold)
	  MarkDown()\Font\FootText       = LoadFont(#PB_Any, Name, Size - 2)
	  MarkDown()\Font\FootBold       = LoadFont(#PB_Any, Name, Size - 2, #PB_Font_Bold)
	  MarkDown()\Font\FootItalic     = LoadFont(#PB_Any, Name, Size - 2, #PB_Font_Italic)
	  MarkDown()\Font\FootBoldItalic = LoadFont(#PB_Any, Name, Size - 2, #PB_Font_Bold|#PB_Font_Italic)
	  
	  MarkDown()\Font\H6 = LoadFont(#PB_Any, Name, Size - 4,  #PB_Font_Bold)
	  MarkDown()\Font\H5 = LoadFont(#PB_Any, Name, Size - 2,  #PB_Font_Bold)
	  MarkDown()\Font\H4 = LoadFont(#PB_Any, Name, Size,      #PB_Font_Bold)
	  MarkDown()\Font\H3 = LoadFont(#PB_Any, Name, Size + 2,  #PB_Font_Bold)
	  MarkDown()\Font\H2 = LoadFont(#PB_Any, Name, Size + 6,  #PB_Font_Bold)
	  MarkDown()\Font\H1 = LoadFont(#PB_Any, Name, Size + 12, #PB_Font_Bold)
	  
	EndProcedure
	
	Procedure   LoadEmojis_()
	  
    CompilerIf Defined(PDF, #PB_Module)
	    Emoji(":check0:")    = CatchImage(#PB_Any, ?Check0, 145)
	    Emoji(":check1:")    = CatchImage(#PB_Any, ?Check1, 276)
	  CompilerEndIf

	  CompilerIf #Enable_Emoji
  	  Emoji(":angry:")     = CatchImage(#PB_Any, ?Angry, 540)
  	  Emoji(":bookmark:")  = CatchImage(#PB_Any, ?BookMark, 334)
  	  Emoji(":cool:")      = CatchImage(#PB_Any, ?Cool, 629)
  	  Emoji(":date:")      = CatchImage(#PB_Any, ?Calendar, 485)
  	  Emoji(":eyes:")      = CatchImage(#PB_Any, ?Eyes, 583)
  	  Emoji(":laugh:")     = CatchImage(#PB_Any, ?Laugh, 568)
      Emoji(":mail:")      = CatchImage(#PB_Any, ?Mail, 437)  
      Emoji(":memo:")      = CatchImage(#PB_Any, ?Memo, 408) 
      Emoji(":pencil:")    = CatchImage(#PB_Any, ?Pencil, 480)
      Emoji(":phone:")     = CatchImage(#PB_Any, ?Phone, 383)
      Emoji(":rolf:")      = CatchImage(#PB_Any, ?Rofl, 636)
      Emoji(":sad:")       = CatchImage(#PB_Any, ?Sad, 521)
      Emoji(":smile:")     = CatchImage(#PB_Any, ?Smile, 512)
      Emoji(":smirk:")     = CatchImage(#PB_Any, ?Smirk, 532)
      Emoji(":wink:")      = CatchImage(#PB_Any, ?Wink, 553)
      Emoji(":worry:")     = CatchImage(#PB_Any, ?Worry, 554)
      Emoji(":warning:")   = CatchImage(#PB_Any, ?Attention, 565)
      Emoji(":bulb:")      = CatchImage(#PB_Any, ?Bulb, 396)
      Emoji(":paperclip:") = CatchImage(#PB_Any, ?Clip, 474)
      Emoji(":mag:")       = CatchImage(#PB_Any, ?Magnifier, 520)
      Emoji(":magnifier:") = Emoji(":mag:")
    CompilerEndIf
    
  EndProcedure

  ;- ----- ScrollBar -----
  
	Procedure   CalcScrollBar_()
	  Define.i Width, Height, ScrollbarSize
	  
	  ; current canvas ScrollbarSize
	  Width         = GadgetWidth(MarkDown()\CanvasNum)
	  Height        = GadgetHeight(MarkDown()\CanvasNum)
	  ScrollbarSize = MarkDown()\Scrollbar\Size
	  
	  ;{ Calc available canvas area
	  MarkDown()\Area\X = 1
	  MarkDown()\Area\Y = 1
	  
    If MarkDown()\HScroll\Hide And MarkDown()\VScroll\Hide
      MarkDown()\Area\Width  = Width
      MarkDown()\Area\Height = Height
    ElseIf MarkDown()\HScroll\Hide
      MarkDown()\Area\Width  = Width  - ScrollbarSize - 3
      MarkDown()\Area\Height = Height
    ElseIf MarkDown()\VScroll\Hide
      MarkDown()\Area\Width  = Width
      MarkDown()\Area\Height = Height - ScrollbarSize - 3
    Else
      MarkDown()\Area\Width  = Width  - ScrollbarSize - 3
      MarkDown()\Area\Height = Height - ScrollbarSize - 3
    EndIf ;}
    
    ;{ Calc scrollbar size
    If MarkDown()\HScroll\Hide      ;{ only vertical visible
      
      MarkDown()\VScroll\X        = Width - ScrollbarSize - 1
      MarkDown()\VScroll\Y        = 1
      MarkDown()\VScroll\Width    = ScrollbarSize
      MarkDown()\VScroll\Height   = Height - 2
      ;}
    ElseIf MarkDown()\VScroll\Hide  ;{ only horizontal visible
      
      MarkDown()\HScroll\X        = 1
      MarkDown()\HScroll\Y        = Height - ScrollbarSize - 1
      MarkDown()\HScroll\Width    = Width - 2
      MarkDown()\HScroll\Height   = ScrollbarSize
      ;}
    Else                            ;{ both scrollbars visible
      
      MarkDown()\HScroll\X        = 1
      MarkDown()\HScroll\Y        = Height - ScrollbarSize - 1
      MarkDown()\HScroll\Width    = Width  - ScrollbarSize - 2
      MarkDown()\HScroll\Height   = ScrollbarSize
      
      MarkDown()\VScroll\X        = Width - ScrollbarSize - 1
      MarkDown()\VScroll\Y        = 1
      MarkDown()\VScroll\Width    = ScrollbarSize
      MarkDown()\VScroll\Height   = Height - ScrollbarSize - 2
      ;}
    EndIf ;}
    
    ;{ Calc scroll buttons
    MarkDown()\HScroll\Buttons\Width  = ScrollbarSize
    MarkDown()\HScroll\Buttons\Height = ScrollbarSize
    ; forward: right
    MarkDown()\HScroll\Buttons\fX     = MarkDown()\HScroll\X + MarkDown()\HScroll\Width - ScrollbarSize
    MarkDown()\HScroll\Buttons\fY     = MarkDown()\HScroll\Y
    ; backward: left
    MarkDown()\HScroll\Buttons\bX     = MarkDown()\HScroll\X
    MarkDown()\HScroll\Buttons\bY     = MarkDown()\HScroll\Y

    MarkDown()\VScroll\Buttons\Width  = ScrollbarSize
    MarkDown()\VScroll\Buttons\Height = ScrollbarSize
    ; forward: down
    MarkDown()\VScroll\Buttons\fX     = MarkDown()\VScroll\X
    MarkDown()\VScroll\Buttons\fY     = MarkDown()\HScroll\Y + MarkDown()\VScroll\Height - ScrollbarSize
    ; backward: up
    MarkDown()\VScroll\Buttons\bX     = MarkDown()\VScroll\X
    MarkDown()\VScroll\Buttons\bY     = MarkDown()\HScroll\Y
    ;}
    
    ;{ Calc scroll area between buttons
    MarkDown()\HScroll\Area\X      = MarkDown()\HScroll\X + ScrollbarSize
		MarkDown()\HScroll\Area\Y      = MarkDown()\HScroll\Y
		MarkDown()\HScroll\Area\Width  = MarkDown()\HScroll\Width - (ScrollbarSize * 2)
		MarkDown()\HScroll\Area\Height = ScrollbarSize  
    
    MarkDown()\VScroll\Area\X      = MarkDown()\VScroll\X
		MarkDown()\VScroll\Area\Y      = MarkDown()\HScroll\Y + ScrollbarSize 
		MarkDown()\VScroll\Area\Width  = ScrollbarSize
		MarkDown()\VScroll\Area\Height = MarkDown()\VScroll\Height - (ScrollbarSize * 2)	
    ;}

    ;{ Calc thumb size
	  MarkDown()\HScroll\Thumb\Y      = MarkDown()\HScroll\Area\Y
	  MarkDown()\HScroll\Thumb\Width  = Round(MarkDown()\HScroll\Area\Width * MarkDown()\HScroll\Ratio, #PB_Round_Nearest)
	  MarkDown()\HScroll\Thumb\Height = ScrollbarSize
	  MarkDown()\HScroll\Factor       = (MarkDown()\HScroll\Area\Width - MarkDown()\HScroll\Thumb\Width) / MarkDown()\HScroll\Range
	  
	  If MarkDown()\Scrollbar\Flags & #Style_Win11
	    MarkDown()\HScroll\Thumb\Height - 10
	    MarkDown()\HScroll\Thumb\Y      +  5 
	  Else
	    MarkDown()\HScroll\Thumb\Height - 4
	    MarkDown()\HScroll\Thumb\Y      + 2 
	  EndIf

    MarkDown()\VScroll\Thumb\X      = MarkDown()\VScroll\Area\X
	  MarkDown()\VScroll\Thumb\Width  = ScrollbarSize
	  MarkDown()\VScroll\Thumb\Height = Round(MarkDown()\VScroll\Area\Height * MarkDown()\VScroll\Ratio, #PB_Round_Nearest) 
	  MarkDown()\VScroll\Factor       = (MarkDown()\VScroll\Area\Height - MarkDown()\VScroll\Thumb\Height) /  MarkDown()\VScroll\Range
	  
	  If MarkDown()\Scrollbar\Flags & #Style_Win11
	    MarkDown()\VScroll\Thumb\Width - 10
	    MarkDown()\VScroll\Thumb\X     +  5 
	  Else
	    MarkDown()\VScroll\Thumb\Width - 4
	    MarkDown()\VScroll\Thumb\X     + 2 
	  EndIf
    ;}
    
	EndProcedure
	
	Procedure   CalcScrollRange_()

	  If MarkDown()\HScroll\PageLength
      MarkDown()\HScroll\Pos    = MarkDown()\HScroll\Minimum
		  MarkDown()\HScroll\minPos = MarkDown()\HScroll\Minimum
		  MarkDown()\HScroll\maxPos = MarkDown()\HScroll\Maximum - MarkDown()\HScroll\PageLength + 1
		  MarkDown()\HScroll\Ratio  = MarkDown()\HScroll\PageLength / MarkDown()\HScroll\Maximum
		  MarkDown()\HScroll\Range  = MarkDown()\HScroll\maxPos - MarkDown()\HScroll\minPos
		EndIf 

    If MarkDown()\VScroll\PageLength
      MarkDown()\VScroll\Pos    = MarkDown()\VScroll\Minimum
		  MarkDown()\VScroll\minPos = MarkDown()\VScroll\Minimum
		  MarkDown()\VScroll\maxPos = MarkDown()\VScroll\Maximum - MarkDown()\VScroll\PageLength + 1
		  MarkDown()\VScroll\Ratio  = MarkDown()\VScroll\PageLength / MarkDown()\VScroll\Maximum
		  MarkDown()\VScroll\Range  = MarkDown()\VScroll\maxPos - MarkDown()\VScroll\minPos
		EndIf

    CalcScrollBar_()
    
    MarkDown()\HScroll\Thumb\X = MarkDown()\HScroll\Area\X
  	MarkDown()\VScroll\Thumb\Y = MarkDown()\VScroll\Area\Y
    
	EndProcedure
	
	
	Procedure.i GetThumbPosX_(X.i)   ; Horizontal Scrollbar
	  Define.i Delta, Offset
	  
	  Delta = X - MarkDown()\HScroll\CursorPos
	  MarkDown()\HScroll\Thumb\X + Delta 
	  
	  If MarkDown()\HScroll\Thumb\X < MarkDown()\HScroll\Area\X
	    MarkDown()\HScroll\Thumb\X = MarkDown()\HScroll\Area\X
	  EndIf 
	  
	  If MarkDown()\HScroll\Thumb\X + MarkDown()\HScroll\Thumb\Width > MarkDown()\HScroll\Area\X + MarkDown()\HScroll\Area\Width
	    MarkDown()\HScroll\Thumb\X = MarkDown()\HScroll\Area\X + MarkDown()\HScroll\Area\Width - MarkDown()\HScroll\Thumb\Width
	  EndIf

	  Offset = MarkDown()\HScroll\Thumb\X - MarkDown()\HScroll\Area\X
	  MarkDown()\HScroll\Pos = Round(Offset / MarkDown()\HScroll\Factor, #PB_Round_Nearest) + MarkDown()\HScroll\minPos
	  
	  If MarkDown()\HScroll\Pos > MarkDown()\HScroll\maxPos : MarkDown()\HScroll\Pos = MarkDown()\HScroll\maxPos : EndIf
  	If MarkDown()\HScroll\Pos < MarkDown()\HScroll\minPos : MarkDown()\HScroll\Pos = MarkDown()\HScroll\minPos : EndIf
	  
	  ProcedureReturn MarkDown()\HScroll\Pos
	EndProcedure  
	
	Procedure.i GetThumbPosY_(Y.i)   ; Vertical Scrollbar
	  Define.i Delta, Offset

	  Delta = Y - MarkDown()\VScroll\CursorPos
	  MarkDown()\VScroll\Thumb\Y + Delta 
	  
	  If MarkDown()\VScroll\Thumb\Y < MarkDown()\VScroll\Area\Y
	    MarkDown()\VScroll\Thumb\Y =  MarkDown()\VScroll\Area\Y
	  EndIf 
	  
	  If MarkDown()\VScroll\Thumb\Y + MarkDown()\VScroll\Thumb\Height >  MarkDown()\VScroll\Area\Y + MarkDown()\VScroll\Area\Height
	    MarkDown()\VScroll\Thumb\Y =  MarkDown()\VScroll\Area\Y + MarkDown()\VScroll\Area\Height - MarkDown()\VScroll\Thumb\Height
	  EndIf
	  
	  Offset = MarkDown()\VScroll\Thumb\Y - MarkDown()\VScroll\Area\Y
	  MarkDown()\VScroll\Pos = Round(Offset / MarkDown()\VScroll\Factor, #PB_Round_Nearest) + MarkDown()\VScroll\minPos
	  
	  If MarkDown()\VScroll\Pos > MarkDown()\VScroll\maxPos : MarkDown()\VScroll\Pos = MarkDown()\VScroll\maxPos : EndIf
  	If MarkDown()\VScroll\Pos < MarkDown()\VScroll\minPos : MarkDown()\VScroll\Pos = MarkDown()\VScroll\minPos : EndIf
	  
	  ProcedureReturn MarkDown()\VScroll\Pos
	EndProcedure  
	
	
	Procedure   SetThumbPosX_(Pos.i) ; Horizontal Scrollbar
	  Define.i  Offset
	  
	  MarkDown()\HScroll\Pos = Pos

	  If MarkDown()\HScroll\Pos < MarkDown()\HScroll\minPos : MarkDown()\HScroll\Pos = MarkDown()\HScroll\minPos : EndIf
	  If MarkDown()\HScroll\Pos > MarkDown()\HScroll\maxPos : MarkDown()\HScroll\Pos = MarkDown()\HScroll\maxPos : EndIf
	  
    Offset = Round((MarkDown()\HScroll\Pos - MarkDown()\HScroll\minPos) * MarkDown()\HScroll\Factor, #PB_Round_Nearest)
    MarkDown()\HScroll\Thumb\X = MarkDown()\HScroll\Area\X + Offset

	EndProcedure
	
	Procedure   SetThumbPosY_(Pos.i) ; Vertical Scrollbar
	  Define.i  Offset
	  
	  MarkDown()\VScroll\Pos = Pos

	  If MarkDown()\VScroll\Pos < MarkDown()\VScroll\minPos : MarkDown()\VScroll\Pos = MarkDown()\VScroll\minPos : EndIf
	  If MarkDown()\VScroll\Pos > MarkDown()\VScroll\maxPos : MarkDown()\VScroll\Pos = MarkDown()\VScroll\maxPos : EndIf
	  
    Offset = Round((MarkDown()\VScroll\Pos - MarkDown()\VScroll\minPos) * MarkDown()\VScroll\Factor, #PB_Round_Nearest)
    MarkDown()\VScroll\Thumb\Y = MarkDown()\VScroll\Area\Y + Offset

	EndProcedure
	
  
	Procedure.i AdjustScrollBars_()
	  Define.i Height, Width
    Define.i VScroll, HScroll, ScrollbarSize
    
    Width   = GadgetWidth(MarkDown()\CanvasNum)  - (MarkDown()\Margin\Left + MarkDown()\Margin\Right)
		Height  = GadgetHeight(MarkDown()\CanvasNum) - (MarkDown()\Margin\Top  + MarkDown()\Margin\Bottom)
    
    ScrollbarSize = MarkDown()\Scrollbar\Size
    
    If MarkDown()\Type = #Requester 
  		Height - 33
  	EndIf
    
    ; --- Size without Scrollbars ---
    If MarkDown()\Required\Height > Height
      Width - ScrollbarSize
    EndIf  
    
    If MarkDown()\Type <> #Requester
      
      If MarkDown()\Required\Width > Width
        Height - ScrollbarSize
      EndIf
      
    EndIf
    
    ; --- Size with Scrollbars ---
    If MarkDown()\Required\Height > Height ; Vertical Scrollbar
      MarkDown()\VScroll\Minimum    = 0
      MarkDown()\VScroll\Maximum    = MarkDown()\Required\Height
      MarkDown()\VScroll\PageLength = Height
      MarkDown()\VScroll\Hide       = #False
    Else
      MarkDown()\VScroll\Minimum    = 0
      MarkDown()\VScroll\Maximum    = 0
      MarkDown()\VScroll\PageLength = 0
      MarkDown()\VScroll\Hide       = #True
    EndIf  
    
    If MarkDown()\Type <> #Requester
    
      If MarkDown()\Required\Width > Width ; Horizontal Scrollbar
        MarkDown()\HScroll\Minimum    = 0
        MarkDown()\HScroll\Maximum    = MarkDown()\Required\Width
        MarkDown()\HScroll\PageLength = Width
        MarkDown()\HScroll\Hide       = #False
      Else
        MarkDown()\HScroll\Maximum    = 0
        MarkDown()\HScroll\Maximum    = 0
        MarkDown()\HScroll\PageLength = 0
        MarkDown()\HScroll\Hide       = #True
      EndIf
      
    EndIf
    
    CalcScrollRange_()
    
	EndProcedure
	
	;- ---------------------
	
	Procedure   Clear_(Image.i=#False)
	  
	  If Image : ClearMap(MarkDown()\ImageNum()) : EndIf  
	  
	  ClearMap(MarkDown()\Abbreviation())
	  ClearMap(MarkDown()\FootLabel())
	  ClearMap(MarkDown()\Label())
	  
    ClearList(MarkDown()\AbbrevWord())
	  ClearList(MarkDown()\Block())
	  ClearList(MarkDown()\Footnote())
	  ClearList(MarkDown()\Image())
	  ClearList(MarkDown()\Items())
	  ClearList(MarkDown()\Link())
	  ClearList(MarkDown()\Lists())
	  ClearList(MarkDown()\Table())
	  ClearList(MarkDown()\TOC())
	  
	EndProcedure
	
	Procedure.i GetSpanWidth_(Idx.i, Span.i, Map ColWidth.i(), PDF.i=#False)
    Define.i i, Width
    
    For i=Idx To Idx + Span - 1
      If PDF
        Width + mm_(ColWidth(Str(i))) + 4
      Else 
        Width + ColWidth(Str(i))
      EndIf 
    Next
    
    ProcedureReturn Width
  EndProcedure  
	
  Procedure.i DrawingFont_(Font.i)

    Select Font
      Case #Font_Bold
        DrawingFont(FontID(MarkDown()\Font\Bold))
      Case #Font_Italic
        DrawingFont(FontID(MarkDown()\Font\Italic))
      Case #Font_BoldItalic  
        DrawingFont(FontID(MarkDown()\Font\BoldItalic))
      Case #Font_FootNote
        DrawingFont(FontID(MarkDown()\Font\FootNote))
      Case #Font_FootText
        DrawingFont(FontID(MarkDown()\Font\FootText))
      Case #Font_FootBold
        DrawingFont(FontID(MarkDown()\Font\FootBold))
      Case #Font_FootItalic
        DrawingFont(FontID(MarkDown()\Font\FootItalic))
      Case #Font_FootBoldItalic
        DrawingFont(FontID(MarkDown()\Font\FootBoldItalic))
      Case #Font_Code
        DrawingFont(FontID(MarkDown()\Font\Code))
      Case #Font_H6
        DrawingFont(FontID(MarkDown()\Font\H6))
      Case #Font_H5
        DrawingFont(FontID(MarkDown()\Font\H5))
      Case #Font_H4
        DrawingFont(FontID(MarkDown()\Font\H4))
      Case #Font_H3
        DrawingFont(FontID(MarkDown()\Font\H3))
      Case #Font_H2
        DrawingFont(FontID(MarkDown()\Font\H2))
      Case #Font_H1 
        DrawingFont(FontID(MarkDown()\Font\H1))
      Default
        DrawingFont(FontID(MarkDown()\Font\Normal))
    EndSelect
    
    ProcedureReturn Font
  EndProcedure
 
  Procedure.i DetermineTextSize_(NoGadget.i=#False)
    Define.i TextHeight, Image, Output, OutputNum
    Define.i Key$, Image$, File$

    MarkDown()\Required\Width  = 0
    MarkDown()\Required\Height = 0
    
    If NoGadget
      OutputNum = CreateImage(#PB_Any, 10, 10)
      If OutputNum
        Output = ImageOutput(OutputNum)
      Else
        ProcedureReturn #False
      EndIf  
    ElseIf IsGadget(MarkDown()\CanvasNum)
      Output = CanvasOutput(MarkDown()\CanvasNum)
    Else
      ProcedureReturn #False
    EndIf  
    
    If MarkDown()\LineSpacing <= 0 : MarkDown()\LineSpacing = 1.06 : EndIf
    
    If StartDrawing(Output)
      
      ;{ _____ Items _____
      ForEach MarkDown()\Items()
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\Items()\Width  = 0
        MarkDown()\Items()\Height = TextHeight_("X")
        
        ForEach MarkDown()\Items()\Words()
          
          DrawingFont_(MarkDown()\Items()\Words()\Font)
          
          Select MarkDown()\Items()\Words()\Flag
            Case #Emoji     ;{ Emoji (16x16)
              TextHeight = 16
              MarkDown()\Items()\Words()\Width = 16
              ;}
            Case #Image     ;{ Image

              If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Words()\Index)
                
                Image$ = GetFilePart(MarkDown()\Image()\Source)
                File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)

                If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                  If AddMapElement(MarkDown()\ImageNum(), Image$)
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$) 
                  EndIf
                EndIf
                
                If IsImage(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
  			          TextHeight = MarkDown()\Image()\Height
  			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
  			        EndIf
 
  			      EndIf
  			      ;}
  			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
  			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
  			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
  			      ;}
  			    Default  
              TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
              MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String)
          EndSelect
          
          MarkDown()\Items()\Width + MarkDown()\Items()\Words()\Width
          If TextHeight > MarkDown()\Items()\Height : MarkDown()\Items()\Height = TextHeight : EndIf
          
        Next
        
        If MarkDown()\Items()\Type = #Image
          
          Image$ = GetFilePart(MarkDown()\Image()\Source)
          File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
          
          If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
            If AddMapElement(MarkDown()\ImageNum(), Image$)
              MarkDown()\ImageNum() = LoadImage(#PB_Any, File$) 
            EndIf
          EndIf
          
          If IsImage(MarkDown()\ImageNum())
	          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
	          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
	        EndIf
	        
	        MarkDown()\Required\Height + MarkDown()\Image()\Height
          If MarkDown()\Image()\Width  > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width  : EndIf 

        Else
          
          MarkDown()\Required\Height + MarkDown()\Items()\Height
          If MarkDown()\Items()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Items()\Width : EndIf 
          
          MarkDown()\Items()\Height * MarkDown()\LineSpacing

        EndIf

      Next ;}
      
      ;{ _____ Lists _____
      
      ForEach MarkDown()\Lists()
        
        TextHeight = 0
        
        ForEach MarkDown()\Lists()\Row() ;{ List rows
          
          DrawingFont(FontID(MarkDown()\Font\Normal))
          
          MarkDown()\Lists()\Row()\Width  = 0
          MarkDown()\Lists()\Row()\Height = TextHeight_("X")
          
          ForEach MarkDown()\Lists()\Row()\Words()
        
            DrawingFont_(MarkDown()\Lists()\Row()\Words()\Font)
            
            Select MarkDown()\Lists()\Row()\Words()\Flag
              Case #Emoji     ;{ Emoji (16x16)
                TextHeight = 16
                MarkDown()\Lists()\Row()\Words()\Width = 16
                ;}
              Case #Image     ;{ Image
                
                If SelectElement(MarkDown()\Image(), MarkDown()\Lists()\Row()\Words()\Index)
                  
                  Image$ = GetFilePart(MarkDown()\Image()\Source)
                  File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                  
                  If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                    If AddMapElement(MarkDown()\ImageNum(), Image$)
                      MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                    EndIf
                  EndIf
                  
                  If IsImage(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    			          TextHeight = MarkDown()\Image()\Height
    			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
    			        EndIf
    			        
    			      EndIf
    			      ;}
    			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
    			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
    			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
    			      ;}
    			    Default  
                TextHeight = TextHeight_(MarkDown()\Lists()\Row()\Words()\String)
                MarkDown()\Lists()\Row()\Words()\Width = TextWidth_(MarkDown()\Lists()\Row()\Words()\String)
            EndSelect
           
            MarkDown()\Lists()\Row()\Width + MarkDown()\Lists()\Row()\Words()\Width
            If TextHeight > MarkDown()\Lists()\Row()\Height : MarkDown()\Lists()\Row()\Height = TextHeight : EndIf
            
          Next
         
          MarkDown()\Lists()\Row()\Height * MarkDown()\LineSpacing
          MarkDown()\Required\Height + MarkDown()\Lists()\Row()\Height
          
          If MarkDown()\Lists()\Row()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Lists()\Row()\Width : EndIf
          ;}
        Next

      Next ;} 

      ;{ _____ Tables _____
      ForEach MarkDown()\Table()
        
        TextHeight = 0
        
        ForEach MarkDown()\Table()\Column() : MarkDown()\Table()\Column()\Width = 0 : Next  
        
        ForEach MarkDown()\Table()\Row()
          
          DrawingFont(FontID(MarkDown()\Font\Normal))
        
          MarkDown()\Table()\Row()\Height = TextHeight_("X")
          
          ForEach MarkDown()\Table()\Row()\Col() ;{ Columns
            
            Key$ = MapKey(MarkDown()\Table()\Row()\Col())
            
            MarkDown()\Table()\Row()\Col()\Width = 0 
            
            ForEach MarkDown()\Table()\Row()\Col()\Words() ;{ Words

              DrawingFont_(MarkDown()\Table()\Row()\Col()\Words()\Font)       
              
              Select MarkDown()\Table()\Row()\Col()\Words()\Flag
                Case #Emoji     ;{ Emoji (16x16)
                  TextHeight = 16
                  MarkDown()\Table()\Row()\Col()\Words()\Width = 16
                  ;}
                Case #Image     ;{ Image
                  
                  If SelectElement(MarkDown()\Image(), MarkDown()\Table()\Row()\Col()\Words()\Index)
                    
                    Image$ = GetFilePart(MarkDown()\Image()\Source)
                    File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                    
                    If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                      If AddMapElement(MarkDown()\ImageNum(), Image$) 
                        MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                      EndIf
                    EndIf
                    
                    If IsImage(MarkDown()\ImageNum())
      			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
      			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
      			          TextHeight = MarkDown()\Image()\Height
      			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
      			        EndIf
      			        
      			      EndIf
      			      ;}
      			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
      			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
      			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
      			      ;}
      			    Default  
                  TextHeight = TextHeight_(MarkDown()\Table()\Row()\Col()\Words()\String)
                  MarkDown()\Table()\Row()\Col()\Words()\Width = TextWidth_(MarkDown()\Table()\Row()\Col()\Words()\String)
              EndSelect
            
              MarkDown()\Table()\Row()\Col()\Width + MarkDown()\Table()\Row()\Col()\Words()\Width
              If TextHeight > MarkDown()\Table()\Row()\Height : MarkDown()\Table()\Row()\Height = TextHeight : EndIf
              ;}
            Next
            
            If MarkDown()\Table()\Row()\Col()\Width > MarkDown()\Table()\Column(Key$)\Width : MarkDown()\Table()\Column(Key$)\Width = MarkDown()\Table()\Row()\Col()\Width : EndIf
            ;}
          Next          
          
          MarkDown()\Table()\Row()\Height * MarkDown()\LineSpacing
          MarkDown()\Required\Height + MarkDown()\Table()\Row()\Height
        Next
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\Table()\Width = 0

        ForEach MarkDown()\Table()\Column()
          MarkDown()\Table()\Column()\Width + 10
          MarkDown()\Table()\Width + MarkDown()\Table()\Column()\Width
        Next
        
        If MarkDown()\Table()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Table()\Width : EndIf
        
      Next  
      ;}
      
      ;{ _____ Notes _____
      ForEach MarkDown()\Note()

        TextHeight = 0
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        MarkDown()\Note()\Height = TextHeight_("X")
        
        ForEach MarkDown()\Note()\Row()
  
          MarkDown()\Note()\Row()\Width = 0
          
          ForEach MarkDown()\Note()\Row()\Words()
          
            DrawingFont_(MarkDown()\Note()\Row()\Words()\Font)
            
            Select MarkDown()\Note()\Row()\Words()\Flag
              Case #Emoji     ;{ Emoji (16x16)
                TextHeight = 16
                MarkDown()\Note()\Row()\Words()\Width = 16
                ;}
              Case #Image     ;{ Image
                
                If SelectElement(MarkDown()\Image(), MarkDown()\Note()\Row()\Words()\Index)
                  
                  Image$ = GetFilePart(MarkDown()\Image()\Source)
                  File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                  
                  If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                    If AddMapElement(MarkDown()\ImageNum(), Image$)
                      MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                    EndIf
                  EndIf
                  
                  If IsImage(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    			          TextHeight = MarkDown()\Image()\Height
    			          MarkDown()\Note()\Row()\Words()\Width = MarkDown()\Image()\Width  
    			        EndIf
   
    			      EndIf
    			      ;}
    			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
    			      TextHeight = TextHeight_(MarkDown()\Note()\Row()\Words()\String)
    			      MarkDown()\Note()\Row()\Words()\Width = TextWidth_(MarkDown()\Note()\Row()\Words()\String) + 10
    			      ;}
    			    Default  
                TextHeight = TextHeight_(MarkDown()\Note()\Row()\Words()\String)
                MarkDown()\Note()\Row()\Words()\Width = TextWidth_(MarkDown()\Note()\Row()\Words()\String)
            EndSelect
            
            MarkDown()\Note()\Row()\Width + MarkDown()\Note()\Row()\Words()\Width
            
            If TextHeight > MarkDown()\Note()\Row()\Height : MarkDown()\Note()\Row()\Height = TextHeight : EndIf
            
          Next

          MarkDown()\Note()\Row()\Height * MarkDown()\LineSpacing
          MarkDown()\Note()\Height + MarkDown()\Note()\Row()\Height 
          
        Next

        If MarkDown()\Note()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Note()\Width : EndIf 
        
      Next
      
      If ListSize(MarkDown()\Note()) : MarkDown()\Required\Height + MarkDown()\Note()\Height : EndIf
      ;}
      
      ;{ _____ Footnotes _____
      ForEach MarkDown()\FootLabel()
        
        TextHeight = 0

        DrawingFont(FontID(MarkDown()\Font\FootText))
        MarkDown()\FootLabel()\Width  = 0
        MarkDown()\FootLabel()\Height = TextHeight_("X")
        
        MarkDown()\Required\Height + MarkDown()\FootLabel()\Height
        
        ForEach MarkDown()\FootLabel()\Words()
          
          DrawingFont_(MarkDown()\FootLabel()\Words()\Font)

          Select MarkDown()\FootLabel()\Words()\Flag
            Case #Emoji     ;{ Emoji (16x16)
              TextHeight = 16
              MarkDown()\FootLabel()\Words()\Width = 16
              ;}
            Case #Image     ;{ Image
              
              If SelectElement(MarkDown()\Image(), MarkDown()\FootLabel()\Words()\Index)
                
                Image$ = GetFilePart(MarkDown()\Image()\Source)
                File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                
  			        If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
  			          If AddMapElement(MarkDown()\ImageNum(), Image$) 
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                  EndIf
                EndIf
                
                If IsImage(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
  			          TextHeight = MarkDown()\Image()\Height
  			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
  			        EndIf
  			        
  			      EndIf
  			      ;}
  			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
  			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
  			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
  			      ;}  
  			    Default  
              TextHeight = TextHeight_(MarkDown()\FootLabel()\Words()\String)
              MarkDown()\FootLabel()\Words()\Width = TextWidth_(MarkDown()\FootLabel()\Words()\String)
          EndSelect
          
          MarkDown()\FootLabel()\Width + MarkDown()\FootLabel()\Words()\Width
          If TextHeight > MarkDown()\FootLabel()\Height : MarkDown()\FootLabel()\Height = TextHeight : EndIf
          
        Next
        
        MarkDown()\Required\Height + MarkDown()\FootLabel()\Height
        If MarkDown()\FootLabel()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\FootLabel()\Width : EndIf 
        
      Next ;}
      
      ;{ _____ Table of Contents _____
      ForEach MarkDown()\TOC()
        
        TextHeight = 0
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\TOC()\Height = TextHeight_("X")
        MarkDown()\TOC()\Width  = 0
        
        ForEach MarkDown()\TOC()\Words()
          
          DrawingFont_(MarkDown()\TOC()\Words()\Font)
        
          MarkDown()\TOC()\Width + TextWidth_(MarkDown()\TOC()\Words()\String)
          
          TextHeight = TextHeight_(MarkDown()\TOC()\Words()\String)
          If TextHeight > MarkDown()\TOC()\Height : MarkDown()\TOC()\Height = TextHeight : EndIf
          
        Next
        
        MarkDown()\TOC()\Height * 1.3
        
      Next
      ;}
      
      StopDrawing()
		EndIf
		
		If NoGadget
		  FreeImage(OutputNum)
		EndIf   
		
  EndProcedure	
  
  Procedure.s GetString_(List Words.Words_Structure())
	  Define.s Text$
	  
	  ForEach Words()
	    Text$ + Words()\String
	  Next
	  
	  ProcedureReturn Text$
	EndProcedure
	
	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
	;- __________ Draw on a CanvasGadget __________	
	
	CompilerIf #Enable_DrawCanvas
	  
  	Procedure   DrawingTextSize_()
  	  Define.i TextHeight, Image, Output, OutputNum
      Define.i Key$, Image$, File$
  
      MarkDown()\Required\Width  = 0
      MarkDown()\Required\Height = 0
      
      If MarkDown()\LineSpacing <= 0 : MarkDown()\LineSpacing = 1.06 : EndIf
      
      ;{ _____ Items _____
      ForEach MarkDown()\Items()
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\Items()\Width  = 0
        MarkDown()\Items()\Height = TextHeight_("X")
        
        ForEach MarkDown()\Items()\Words()
          
          DrawingFont_(MarkDown()\Items()\Words()\Font)
          
          Select MarkDown()\Items()\Words()\Flag
            Case #Emoji     ;{ Emoji (16x16)
              TextHeight = 16
              MarkDown()\Items()\Words()\Width = 16
              ;}
            Case #Image     ;{ Image

              If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Words()\Index)
                
                Image$ = GetFilePart(MarkDown()\Image()\Source)
                File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)

                If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                  If AddMapElement(MarkDown()\ImageNum(), Image$)
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$) 
                  EndIf
                EndIf
                
                If IsImage(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
  			          TextHeight = MarkDown()\Image()\Height
  			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
  			        EndIf
 
  			      EndIf
  			      ;}
  			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
  			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
  			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
  			      ;}
  			    Default  
              TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
              MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String)
          EndSelect
          
          MarkDown()\Items()\Width + MarkDown()\Items()\Words()\Width
          If TextHeight > MarkDown()\Items()\Height : MarkDown()\Items()\Height = TextHeight : EndIf
          
        Next
        
        If MarkDown()\Items()\Type = #Image
          
          Image$ = GetFilePart(MarkDown()\Image()\Source)
          File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
          
          If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
            If AddMapElement(MarkDown()\ImageNum(), Image$)
              MarkDown()\ImageNum() = LoadImage(#PB_Any, File$) 
            EndIf
          EndIf
          
          If IsImage(MarkDown()\ImageNum())
	          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
	          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
	        EndIf
	        
	        MarkDown()\Required\Height + MarkDown()\Image()\Height
          If MarkDown()\Image()\Width  > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width  : EndIf 

        Else
          
          MarkDown()\Required\Height + MarkDown()\Items()\Height
          If MarkDown()\Items()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Items()\Width : EndIf 
          
          MarkDown()\Items()\Height * MarkDown()\LineSpacing

        EndIf
        
      Next ;}
      
      ;{ _____ Lists _____
      
      ForEach MarkDown()\Lists()
        
        TextHeight = 0
        
        ForEach MarkDown()\Lists()\Row() ;{ List rows
          
          DrawingFont(FontID(MarkDown()\Font\Normal))
          
          MarkDown()\Lists()\Row()\Width  = 0
          MarkDown()\Lists()\Row()\Height = TextHeight_("X")
          
          ForEach MarkDown()\Lists()\Row()\Words()
        
            DrawingFont_(MarkDown()\Lists()\Row()\Words()\Font)
            
            Select MarkDown()\Lists()\Row()\Words()\Flag
              Case #Emoji     ;{ Emoji (16x16)
                TextHeight = 16
                MarkDown()\Lists()\Row()\Words()\Width = 16
                ;}
              Case #Image     ;{ Image
                
                If SelectElement(MarkDown()\Image(), MarkDown()\Lists()\Row()\Words()\Index)
                  
                  Image$ = GetFilePart(MarkDown()\Image()\Source)
                  File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                  
                  If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                    If AddMapElement(MarkDown()\ImageNum(), Image$)
                      MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                    EndIf
                  EndIf
                  
                  If IsImage(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    			          TextHeight = MarkDown()\Image()\Height
    			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
    			        EndIf
    			        
    			      EndIf
    			      ;}
    			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
    			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
    			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
    			      ;}
    			    Default  
                TextHeight = TextHeight_(MarkDown()\Lists()\Row()\Words()\String)
                MarkDown()\Lists()\Row()\Words()\Width = TextWidth_(MarkDown()\Lists()\Row()\Words()\String)
            EndSelect
           
            MarkDown()\Lists()\Row()\Width + MarkDown()\Lists()\Row()\Words()\Width
            If TextHeight > MarkDown()\Lists()\Row()\Height : MarkDown()\Lists()\Row()\Height = TextHeight : EndIf
            
          Next
         
          MarkDown()\Lists()\Row()\Height * MarkDown()\LineSpacing
          MarkDown()\Required\Height + MarkDown()\Lists()\Row()\Height
          
          If MarkDown()\Lists()\Row()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Lists()\Row()\Width : EndIf
          ;}
        Next

      Next ;} 

      ;{ _____ Tables _____
      ForEach MarkDown()\Table()
        
        TextHeight = 0
        
        ForEach MarkDown()\Table()\Column() : MarkDown()\Table()\Column()\Width = 0 : Next  
        
        ForEach MarkDown()\Table()\Row()
          
          DrawingFont(FontID(MarkDown()\Font\Normal))
        
          MarkDown()\Table()\Row()\Height = TextHeight_("X")
          
          ForEach MarkDown()\Table()\Row()\Col() ;{ Columns
            
            Key$ = MapKey(MarkDown()\Table()\Row()\Col())
            
            MarkDown()\Table()\Row()\Col()\Width = 0 
            
            ForEach MarkDown()\Table()\Row()\Col()\Words() ;{ Words

              DrawingFont_(MarkDown()\Table()\Row()\Col()\Words()\Font)       
              
              Select MarkDown()\Table()\Row()\Col()\Words()\Flag
                Case #Emoji     ;{ Emoji (16x16)
                  TextHeight = 16
                  MarkDown()\Table()\Row()\Col()\Words()\Width = 16
                  ;}
                Case #Image     ;{ Image
                  
                  If SelectElement(MarkDown()\Image(), MarkDown()\Table()\Row()\Col()\Words()\Index)
                    
                    Image$ = GetFilePart(MarkDown()\Image()\Source)
                    File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                    
                    If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                      If AddMapElement(MarkDown()\ImageNum(), Image$) 
                        MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                      EndIf
                    EndIf
                    
                    If IsImage(MarkDown()\ImageNum())
      			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
      			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
      			          TextHeight = MarkDown()\Image()\Height
      			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
      			        EndIf
      			        
      			      EndIf
      			      ;}
      			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
      			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
      			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
      			      ;}
      			    Default  
                  TextHeight = TextHeight_(MarkDown()\Table()\Row()\Col()\Words()\String)
                  MarkDown()\Table()\Row()\Col()\Words()\Width = TextWidth_(MarkDown()\Table()\Row()\Col()\Words()\String)
              EndSelect
            
              MarkDown()\Table()\Row()\Col()\Width + MarkDown()\Table()\Row()\Col()\Words()\Width
              If TextHeight > MarkDown()\Table()\Row()\Height : MarkDown()\Table()\Row()\Height = TextHeight : EndIf
              ;}
            Next
            
            If MarkDown()\Table()\Row()\Col()\Width > MarkDown()\Table()\Column(Key$)\Width : MarkDown()\Table()\Column(Key$)\Width = MarkDown()\Table()\Row()\Col()\Width : EndIf
            ;}
          Next          
          
          MarkDown()\Table()\Row()\Height * MarkDown()\LineSpacing
          MarkDown()\Required\Height + MarkDown()\Table()\Row()\Height
        Next
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\Table()\Width = 0

        ForEach MarkDown()\Table()\Column()
          MarkDown()\Table()\Column()\Width + 10
          MarkDown()\Table()\Width + MarkDown()\Table()\Column()\Width
        Next
        
        If MarkDown()\Table()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Table()\Width : EndIf
        
      Next  
      ;}
      
      ;{ _____ Notes _____
      ForEach MarkDown()\Note()

        TextHeight = 0
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        MarkDown()\Note()\Height = TextHeight_("X")
        
        ForEach MarkDown()\Note()\Row()
  
          MarkDown()\Note()\Row()\Width = 0
          
          ForEach MarkDown()\Note()\Row()\Words()
          
            DrawingFont_(MarkDown()\Note()\Row()\Words()\Font)
            
            Select MarkDown()\Note()\Row()\Words()\Flag
              Case #Emoji     ;{ Emoji (16x16)
                TextHeight = 16
                MarkDown()\Note()\Row()\Words()\Width = 16
                ;}
              Case #Image     ;{ Image
                
                If SelectElement(MarkDown()\Image(), MarkDown()\Note()\Row()\Words()\Index)
                  
                  Image$ = GetFilePart(MarkDown()\Image()\Source)
                  File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                  
                  If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                    If AddMapElement(MarkDown()\ImageNum(), Image$)
                      MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                    EndIf
                  EndIf
                  
                  If IsImage(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    			          TextHeight = MarkDown()\Image()\Height
    			          MarkDown()\Note()\Row()\Words()\Width = MarkDown()\Image()\Width  
    			        EndIf
   
    			      EndIf
    			      ;}
    			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
    			      TextHeight = TextHeight_(MarkDown()\Note()\Row()\Words()\String)
    			      MarkDown()\Note()\Row()\Words()\Width = TextWidth_(MarkDown()\Note()\Row()\Words()\String) + 10
    			      ;}
    			    Default  
                TextHeight = TextHeight_(MarkDown()\Note()\Row()\Words()\String)
                MarkDown()\Note()\Row()\Words()\Width = TextWidth_(MarkDown()\Note()\Row()\Words()\String)
            EndSelect
            
            MarkDown()\Note()\Row()\Width + MarkDown()\Note()\Row()\Words()\Width
            
            If TextHeight > MarkDown()\Note()\Row()\Height : MarkDown()\Note()\Row()\Height = TextHeight : EndIf
            
          Next

          MarkDown()\Note()\Row()\Height * MarkDown()\LineSpacing
          MarkDown()\Note()\Height + MarkDown()\Note()\Row()\Height 
          
        Next

        If MarkDown()\Note()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Note()\Width : EndIf 
        
      Next
      
      If ListSize(MarkDown()\Note()) : MarkDown()\Required\Height + MarkDown()\Note()\Height : EndIf
      ;}
      
      ;{ _____ Footnotes _____
      ForEach MarkDown()\FootLabel()
        
        TextHeight = 0

        DrawingFont(FontID(MarkDown()\Font\FootText))
        MarkDown()\FootLabel()\Width  = 0
        MarkDown()\FootLabel()\Height = TextHeight_("X")
        
        MarkDown()\Required\Height + MarkDown()\FootLabel()\Height
        
        ForEach MarkDown()\FootLabel()\Words()
          
          DrawingFont_(MarkDown()\FootLabel()\Words()\Font)

          Select MarkDown()\FootLabel()\Words()\Flag
            Case #Emoji     ;{ Emoji (16x16)
              TextHeight = 16
              MarkDown()\FootLabel()\Words()\Width = 16
              ;}
            Case #Image     ;{ Image
              
              If SelectElement(MarkDown()\Image(), MarkDown()\FootLabel()\Words()\Index)
                
                Image$ = GetFilePart(MarkDown()\Image()\Source)
                File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                
  			        If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
  			          If AddMapElement(MarkDown()\ImageNum(), Image$) 
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                  EndIf
                EndIf
                
                If IsImage(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
  			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
  			          TextHeight = MarkDown()\Image()\Height
  			          MarkDown()\Items()\Words()\Width = MarkDown()\Image()\Width  
  			        EndIf
  			        
  			      EndIf
  			      ;}
  			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
  			      TextHeight = TextHeight_(MarkDown()\Items()\Words()\String)
  			      MarkDown()\Items()\Words()\Width = TextWidth_(MarkDown()\Items()\Words()\String) + 10
  			      ;}  
  			    Default  
              TextHeight = TextHeight_(MarkDown()\FootLabel()\Words()\String)
              MarkDown()\FootLabel()\Words()\Width = TextWidth_(MarkDown()\FootLabel()\Words()\String)
          EndSelect
          
          MarkDown()\FootLabel()\Width + MarkDown()\FootLabel()\Words()\Width
          If TextHeight > MarkDown()\FootLabel()\Height : MarkDown()\FootLabel()\Height = TextHeight : EndIf
          
        Next
        
        MarkDown()\Required\Height + MarkDown()\FootLabel()\Height
        If MarkDown()\FootLabel()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\FootLabel()\Width : EndIf 
        
      Next ;}
      
      ;{ _____ Table of Contents _____
      ForEach MarkDown()\TOC()
        
        TextHeight = 0
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\TOC()\Height = TextHeight_("X")
        MarkDown()\TOC()\Width  = 0
        
        ForEach MarkDown()\TOC()\Words()
          
          DrawingFont_(MarkDown()\TOC()\Words()\Font)
        
          MarkDown()\TOC()\Width + TextWidth_(MarkDown()\TOC()\Words()\String)
          
          TextHeight = TextHeight_(MarkDown()\TOC()\Words()\String)
          If TextHeight > MarkDown()\TOC()\Height : MarkDown()\TOC()\Height = TextHeight : EndIf
          
        Next
        
        MarkDown()\TOC()\Height * 1.3
        
      Next
      ;}
     
  	EndProcedure 
  	
  CompilerEndIf
  
  ;- ============================================================================
	;-   Module - Convert to HTML & PDF
  ;- ============================================================================	
  
  CompilerIf #Enable_ExportHTML
    
    Procedure.s StyleCSS()
      Define.s Style$
      
      Style$ + "ul, ol { padding-left: 1em; }" + #LF$
      Style$ + "code { color:#006400; }" + #LF$
      Style$ + "blockquote { margin: 0 auto; padding: 0 0 0 0.5em; border-left: 5px solid #999; }" + #LF$ ; padding: 1em; 
      Style$ + "table { border-collapse: collapse; }" + #LF$
      Style$ + "td, th { border: 1px solid black; }" + #LF$
      Style$ + "dt { margin: 4px 2px 0 0; }" + #LF$ 
      Style$ + "dd { margin: 0 0 0 10px; }" + #LF$
      Style$ + ".footsup { font-weight: bold; }" + #LF$
      Style$ + ".tocul { List-style-type: none; padding: 0 0 4px 20px; }" + #LF$
      Style$ + ".tocli { padding: 3px; }" + #LF$
      Style$ + ".para { display: block; margin-bottom: 1em; }" + #LF$
      Style$ + ".center { display: block; margin-left: auto; margin-right: auto; }" + #LF$
      Style$ + ".bordered { background-color: #F6F6F6 ; border: 1px solid #848484; border-radius: 4px; padding: 1px 4px 1px 4px; }" + #LF$
      Style$ + ".footnote { font-size: 10pt; }" + #LF$
      Style$ + ".boxtitle { border: 2px solid #E3E3E3; border-radius: 10px 10px 0 0;  border-bottom: 1px solid #E3E3E3; padding: 10px; position: relative; }" + #LF$
      Style$ + ".box { border: 2px solid #E3E3E3; border-radius: 0 0 10px 10px; border-top: 1px solid #E3E3E3; padding: 10px; }" + #LF$
      Style$ + ".symbol { font-size:1.8em; margin: 0; position: absolute; top: 49%; -ms-transform: translateY(-50%); transform: translateY(-50%); }" + #LF$
      Style$ + ".note { position: relative; padding: 0 0 0 2.3em; }" + #LF$
      ProcedureReturn  Style$
    EndProcedure
    
    Procedure.s EscapeHTML_(String.s)
  	  Define.i c
  	  Define.s Char$, HTML$
  	  
  	  For c=1 To Len(String)
  	    
  	    Char$ = Mid(String, c, 1)
  	    Select Char$
  	      Case "&"
  	        HTML$ + "&amp;"
  	      Case "ß"
  	        HTML$ + "&szlig;"
  	      Case "©"
  	        HTML$ + "&copy;"
  	      Case "®"
  	        HTML$ + "&reg;"
  	      Case "™"
  	        HTML$ + "&trade;"
  	      Case "«"
  	        HTML$ + "&laquo;"
  	      Case "»"
  	        HTML$ + "&raquo;"
  	      Case "→"
  	        HTML$ + "&rarr;"
  	      Case "⇒"
  	        HTML$ + "&rArr;"
  	      Case "▸"
  	        HTML$ + "&blacktriangleright;"
  	      Case "·"
  	        HTML$ + "&middot;"
  	      Case "•"
  	        HTML$ + "&bull;"
  	      Case "…"
  	        HTML$ + "&hellip;"
  	      Case "✓"
  	        HTML$ + "&check;"
  	      Case "✗"
  	        HTML$ + "&cross;"
  	      Case "♪"
  	        HTML$ + "&sung;"
  	      Case "♥"
  	        HTML$ + "&hearts;"
  	      Case "★"
  	        HTML$ + "&bigstar;"
  	      Case "☎"
  	        HTML$ + "&phone;"
  	      Case "§"
  	        HTML$ + "&sect;"
  	      Case "¶"
  	        HTML$ + "&para;"
  	      Case "†"
  	        HTML$ + "&dagger;"
  	      Case "°"
  	        HTML$ + "&deg;"
  	      Case "¦"
  	        HTML$ + "&brvbar;"
  	      Case "'"
  	        HTML$ + "&apos;"
  	      Case "<"
  	        HTML$ + "&lt;"
  	      Case ">"
  	        HTML$ + "&gt;"
  	      Case #DQUOTE$
  	        HTML$ + "&quot;"
  	      Case "Ä"  
  	        HTML$ + "&Auml;"
  	      Case "ä"
  	        HTML$ + "&auml;"
  	      Case "Ë"
  	        HTML$ + "&Euml;"
  	      Case "ë"
  	        HTML$ + "&euml;"
  	      Case "Ï"
  	        HTML$ + "&Iuml;"
  	      Case "ï"
  	        HTML$ + "&iuml;"
  	      Case "Ö"
  	        HTML$ + "&Ouml;"
  	      Case "ö"
  	        HTML$ + "&ouml;"
  	      Case "Ü"
  	        HTML$ + "&Uuml;"
  	      Case "ü"
  	        HTML$ + "&uuml;"
  	      Case "Ÿ"
  	        HTML$ + "&Yuml;"
  	      Case "ÿ"
  	        HTML$ + "&yuml;"
  	      Case "¢"
  	        HTML$ + "&cent;"
  	      Case "€" 
  	        HTML$ + "&euro;"
  	      Case "£"
  	        HTML$ + "&pound;"
  	      Case "¤"
  	        HTML$ + "&curren;"
  	      Case "¥"
  	        HTML$ + "&yen;"
  	      Case "ƒ"
  	        HTML$ + "&fnof;"
  	      Case "!"
  	        HTML$ + "&excl;"
  	      Case "#"
  	        HTML$ + "&num;"
  	      Case "$"
  	        HTML$ + "&dollar;"
  	      Case "%"
  	        HTML$ + "&percnt;"
  	      Case "("
  	        HTML$ + "&lpar;"
  	      Case ")"
  	        HTML$ + "&rpar;"
  	      Case "*"
  	        HTML$ + "&ast;"
  	      Case "+"
  	        HTML$ + "&plus;"
  	      Case ","
  	        HTML$ + "&comma;"
  	      Case "/"
  	        HTML$ + "&sol;"
  	      Case ":"
  	        HTML$ + "&colon;"
  	      Case ";"
  	        HTML$ + "&semi;"
  	      Case "="
  	        HTML$ + "&equals;"
  	      Case "?"
  	        HTML$ + "&quest;"
  	      Case "@"
  	        HTML$ + "&commat;"
  	      Case "["
  	        HTML$ + "&lbrack;"
  	      Case "]"
  	        HTML$ + "&rbrack;"
  	      Case "\"
  	        HTML$ + "&bsol"  
  	      Case "^"
  	        HTML$ + "&Hat;"
  	      Case "_"
  	        HTML$ + "&lowbar;"
  	      Case "`"
  	        HTML$ + "&grave;"
  	      Case "{"
  	        HTML$ + "&lbrace;"  
  	      Case "}"
  	        HTML$ + "&rbrace;"
  	      Case "|"
  	        HTML$ + "&vert;" 
  	      Case "’"
  	        HTML$ + "&#96;"  
  	      Default
  	        HTML$ + Char$
  	    EndSelect
  	    
  	  Next  
  	  
  	  ProcedureReturn HTML$
  	EndProcedure
  	
  	Procedure.s StringHTML_(List Words.Words_Structure())
  	  Define.s Text$
  	  
  	  ForEach Words()
  	    Text$ + Words()\String
  	  Next
  	  
  	  ProcedureReturn EscapeHTML_(Text$)
  	EndProcedure
  	
  	Procedure.s TextHTML_(List Words.Words_Structure())
  	  Define.i Font, Flag
  	  Define.s HTML$, endTag$, Link$, Title$, String$, Image$, Size$
  	  
  	  ForEach Words()
  	    
  	    If Flag <> Words()\Flag
  	      
    	    HTML$ + endTag$
  
    	    Select Words()\Flag
    	      Case #Bold         ;{ Emphasis
    	        HTML$ + "<strong>" + EscapeHTML_(Words()\String)
    	        endTag$ = "</strong>"
    	      Case #Italic
    	        HTML$ + "<em>" + EscapeHTML_(Words()\String)
    	        endTag$ = "</em>"
    	      Case #BoldItalic
    	        HTML$ + "<strong><em>" + EscapeHTML_(Words()\String)
    	        endTag$ = "</strong></em>"
    	      Case #StrikeThrough
    	        HTML$ + "<del>" + EscapeHTML_(Words()\String)
    	        endTag$ = "</del>"
    	        ;}
    	      Case #Code         ;{ Code
    	        HTML$ + "<code class='codestyle'>" + EscapeHTML_(Words()\String)
    	        endTag$ = "</code>"
    	        ;}
    	      Case #AutoLink     ;{ URL / EMail
    	        
    	        If CountString(Words()\String, "@") = 1
                HTML$ + "<a href=" + #DQUOTE$ + "mailto:" + URLDecoder(Words()\String) + #DQUOTE$ + ">" + EscapeHTML_(Words()\String)
              Else  
                HTML$ + "<a href=" + #DQUOTE$ + URLDecoder(Words()\String) + #DQUOTE$ + ">" + EscapeHTML_(Words()\String)
              EndIf
              
              endTag$ = "</a>"
              ;}
    	      Case #Link         ;{ Links

    	        ; Take me to <a href="#pookie">pookie</a>
              ; <a name="pookie">this is pookie</a>
    	        
    	        If SelectElement(MarkDown()\Link(), Words()\Index)
              
                If MarkDown()\Link()\Label
                  If FindMapElement(MarkDown()\Label(), MarkDown()\Link()\Label)
                    Link$   = URLDecoder(MarkDown()\Label()\Destination)
                    Title$  = EscapeHTML_(MarkDown()\Label()\Title)
                    String$ = EscapeHTML_(MarkDown()\Label()\String)
                  EndIf  
                Else
                  Link$   = URLDecoder(MarkDown()\Link()\URL)
                  Title$  = EscapeHTML_(MarkDown()\Link()\Title)
                  String$ = EscapeHTML_(Words()\String)
                EndIf
                
                If Left(Link$, 1) = "#" : Link$ = Mid(Link$, 2) + ".html" : EndIf  
  
                If MarkDown()\Link()\Title
                  HTML$ + "<a href=" + #DQUOTE$ + Link$ + #DQUOTE$ + " title=" + #DQUOTE$ + Title$ + #DQUOTE$ + ">" + String$
                Else  
                  HTML$ + "<a href=" + #DQUOTE$ + Link$ + #DQUOTE$ + ">" + String$
                EndIf
                
              EndIf
              
              endTag$ = "</a>"
              ;}
            Case #Glossary     ;{ Glossary
              Title$ = StringHTML_(MarkDown()\Glossary(Words()\String)\Words())
              HTML$ + "<a href=#" + #DQUOTE$ + Words()\String + #DQUOTE$ + " title=" + #DQUOTE$ + Title$ + #DQUOTE$ + ">" + EscapeHTML_(Words()\String) + "</a>"
              endTag$ = ""
              ;}
            Case #Highlight    ;{ Highlight
              If Right(Words()\String, 1) = " "
                HTML$ + "<mark>" + EscapeHTML_(RTrim(Words()\String))
                endTag$ = "</mark> "
              Else  
                HTML$ + "<mark>" + EscapeHTML_(Words()\String)
                endTag$ = "</mark>"
              EndIf
              ;}
            Case #Image        ;{ Images
  
              If SelectElement(MarkDown()\Image(), Words()\Index)
                
                If MarkDown()\Image()\Width And MarkDown()\Image()\Height
                  Image$ = " width=" + #DQUOTE$ + Str(MarkDown()\Image()\Width) + #DQUOTE$ + " height=" + #DQUOTE$ + Str(MarkDown()\Image()\Height) + #DQUOTE$ 
                Else
                  Image$ = ""
                EndIf
                
                If MarkDown()\Image()\Title
                  HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(Words()\String) + #DQUOTE$ + Image$ + " title=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Image()\Title) + #DQUOTE$ + " />"
                Else  
                  HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(Words()\String) + #DQUOTE$ + Image$ + " />"
                EndIf
              EndIf
              
    	        endTag$ = ""
    	        ;}
    	      Case #Keyword      ;{ KeyWord
    	        HTML$ + EscapeHTML_(Words()\String)
    	        endTag$ = "" 
    	        ;}
    	      Case #FootNote     ;{ Footnotes
    	        HTML$ + "<sup class=" + #DQUOTE$ + "footsup" + #DQUOTE$ + ">"  + EscapeHTML_(Words()\String) + "</sup>"
    	        endTag$ = ""
    	        ;}
    	      Case #Superscript  ;{ SuperScript
    	        HTML$ + "<sup>" + EscapeHTML_(Words()\String) + "</sup>" 
    	        endTag$ = ""
    	        ;}
    	      Case #Subscript    ;{ SubScript
    	        HTML$ + "<sub>" + EscapeHTML_(Words()\String) + "</sub>"
    	        endTag$ = ""
    	        ;}
    	      Case #Underline    ;{ Underline
    	        HTML$ + "<u>" + EscapeHTML_(Words()\String)
    	        endTag$ = "</u>"
    	        ;}
    	      Case #Emoji        ;{ Emoji
    	        
              Select Words()\String
                Case ":laugh:", ":smiley:"
                  HTML$ + "&#128512;"
                Case ":smile:", ":simple_smile:"
                  HTML$ + "&#128578;"
                Case ":sad:"
                  HTML$ + "&#128577;"
                Case ":angry:"
                  HTML$ + "&#128544;"
                Case ":cool:", ":sunglasses:"
                  HTML$ + "&#128526;"
                Case ":smirk:"
                  HTML$ + "&#128527;"
                Case ":worry:", ":worried:"
                  HTML$ + "&#128543;"
                Case ":wink:"
                  HTML$ + "&#128521;"
                Case ":rolf:"
                  HTML$ + "&#129315;"
                Case ":eyes:", ":flushed:" 
                  HTML$ + "&#128580;"
                Case ":phone:" , ":telephone_receiver:"
                  HTML$ + "&#128222;"
                Case ":mail:", ":envelope:"
                  HTML$ + "&#9993;"
                Case ":date:", ":calendar:"
                  HTML$ + "&#128198;"
                Case ":memo:"
                  HTML$ + "&#128221;"
                Case ":pencil:", ":pencil2:"    
                  HTML$ + "&#9999;"
                Case ":bookmark:"
                  HTML$ + "&#128278;"
                Case ":clip:", ":paperclip:"
                  HTML$ + "&#128206"
                Case ":mag:", ":magnifier:"
                  HTML$ + "&#128270"
                Case ":bulb:"
                  HTML$ + "&#128161"
                Case ":warning:"  
                  HTML$ + "&#9888;"
              EndSelect
              
              endTag$ = "" 
              ;} 
            Case #Keystroke    ;{ Keystroke
              HTML$ + "<strong class=" + #DQUOTE$ + "bordered" + #DQUOTE$ + ">" +  EscapeHTML_(Words()\String) + "</strong>"
              ;}
            Default 
    	        HTML$ + EscapeHTML_(Words()\String)
    	        endTag$ = ""
    	    EndSelect
    	    
    	    Flag = Words()\Flag
    	    
    	  Else
    	    
    	    HTML$ + EscapeHTML_(Words()\String)
    	    
    	  EndIf
    	  
    	Next 
    
    	HTML$ + endTag$
  	
  	  ProcedureReturn HTML$
  	EndProcedure
  	
  	Procedure.s ConvertHTML_()
  	  Define.i Level, c, ColWidth, Cols, tBody, Class, BlockQuote, DL
      Define.s HTML$, Style$, endTag$, Align$, Indent$, ID$, Link$, Title$, String$, Num$, ColSpan$, Image$, File$, Size$, Class$, BackColor$, Symbol$
      
      ForEach MarkDown()\Image() ;{ Images
       
        Image$ = GetFilePart(MarkDown()\Image()\Source)
        File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
        
        If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
          If AddMapElement(MarkDown()\ImageNum(), Image$)
            MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
          EndIf
        EndIf
        
        If IsImage(MarkDown()\ImageNum())
          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
        EndIf
        ;}
      Next   
      
      ForEach MarkDown()\Items()
        
        Select MarkDown()\Items()\BlockQuote ;{ Blockquotes
          Case 1, 2
            If Not BlockQuote
              HTML$ + "<blockquote>" + #LF$
              BlockQuote = #True
            EndIf  
          Case 0
            If BlockQuote
              HTML$ + "</blockquote>" + #LF$
              BlockQuote = #False
            EndIf ;}
        EndSelect
        
        If DL And MarkDown()\Items()\Type <> #DefinitionList
          HTML$ + "</dl>" + #LF$
          DL = #False
        EndIf
        
        Select MarkDown()\Items()\Type
          Case #Heading          ;{ Heading
            If MarkDown()\Items()\ID
              ID$ = " id=" + #DQUOTE$ + MarkDown()\Items()\ID + #DQUOTE$
              HTML$ + "<h"+Str(MarkDown()\Items()\Level) + ID$ + ">" + StringHTML_(MarkDown()\Items()\Words()) + "</h"+Str(MarkDown()\Items()\Level) + ">" + #LF$
            Else  
              HTML$ + "<h"+Str(MarkDown()\Items()\Level) + ">" + StringHTML_(MarkDown()\Items()\Words()) + "</h"+Str(MarkDown()\Items()\Level) + ">" + #LF$
            EndIf
            ;}
          Case #OrderedList      ;{ Ordered List
            
            Level = 0
            
            If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
              If MarkDown()\Lists()\Start
                HTML$ + "<ol start=" + #DQUOTE$ + Str(MarkDown()\Lists()\Start) + #DQUOTE$ + ">" + #LF$
              Else
                HTML$ + "<ol>" + #LF$
              EndIf  
              
              ForEach MarkDown()\Lists()\Row()
                
                If Level < MarkDown()\Lists()\Row()\Level
                  HTML$ + "<ol>" + #LF$
                  endTag$ = "</ol>"
                  Level = MarkDown()\Lists()\Row()\Level
                ElseIf Level > MarkDown()\Lists()\Row()\Level
                  HTML$ + endTag$ + #LF$
                  Level = MarkDown()\Lists()\Row()\Level
                EndIf  
                
                HTML$ + "<li>" + TextHTML_( MarkDown()\Lists()\Row()\Words()) + "</li>" + #LF$
                
              Next
              
              HTML$ + "</ol>" + #LF$
              
            EndIf
            ;}
          Case #UnorderedList    ;{ Unordered List
            
            Level = 0
            
            If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
  
              HTML$ + "<ul>" + #LF$
              
              ForEach MarkDown()\Lists()\Row()
                
                If Level < MarkDown()\Lists()\Row()\Level
                  HTML$ + "<ul>" + #LF$
                  endTag$ = "</ul>"
                  Level = MarkDown()\Lists()\Row()\Level
                ElseIf Level > MarkDown()\Lists()\Row()\Level
                  HTML$ + endTag$ + #LF$
                  Level = MarkDown()\Lists()\Row()\Level
                EndIf  
                
                HTML$ + "<li>" + TextHTML_( MarkDown()\Lists()\Row()\Words()) + "</li>" + #LF$
                
              Next
              
              HTML$ + "</ul>" + #LF$
              
            EndIf
            ;}
          Case #DefinitionList   ;{ Definition List
  
            If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
              If Not DL
                HTML$ + "<dl>" + #LF$
                DL = #True
              EndIf
              
              HTML$ + "<dt><strong>" + StringHTML_(MarkDown()\Items()\Words()) + "</strong></dt>" + #LF$
              ForEach MarkDown()\Lists()\Row()
                HTML$ + "<dd>" + TextHTML_(MarkDown()\Lists()\Row()\Words()) + "</dd>" + #LF$
              Next
              
            EndIf  
  			    ;}  
          Case #Glossary         ;{ Glossary
            
            If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
              HTML$ + "<dl>" + #LF$
              ForEach MarkDown()\Lists()\Row()
                HTML$ + "<dt><strong id=" + #DQUOTE$ + MarkDown()\Lists()\Row()\String + #DQUOTE$ + ">" + MarkDown()\Lists()\Row()\String + "</strong></dt>" + #LF$
                HTML$ + "<dd>" + TextHTML_(MarkDown()\Lists()\Row()\Words()) + "</dd>" + #LF$
              Next
              HTML$ + "</dl>" + #LF$
              
            EndIf 
            ;}
          Case #Line             ;{ Horizontal Rule
            HTML$ + "<hr />" + #LF$
            ;}
          Case #Paragraph        ;{ Paragraph
            HTML$ + "<span class=" + #DQUOTE$ + "para" + #DQUOTE$ + "></span>" + #LF$
            ;}
          Case #Image            ;{ Image
            
            If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
             
              String$ = ""
              ForEach MarkDown()\Items()\Words()
                String$ + MarkDown()\Items()\Words()\String
              Next   
              
              If MarkDown()\Image()\Width And MarkDown()\Image()\Height
                Image$ = " width=" + #DQUOTE$ + Str(MarkDown()\Image()\Width) + #DQUOTE$ + " height=" + #DQUOTE$ + Str(MarkDown()\Image()\Height) + #DQUOTE$ 
              Else
                Image$ = ""
              EndIf
              
              Class$ = " class="  + #DQUOTE$ + "center" + #DQUOTE$
              
              If MarkDown()\Image()\Title
                HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(String$) + #DQUOTE$ + Image$ + " title=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Image()\Title) + #DQUOTE$ + Class$ + " />"
              Else  
                HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(String$) + #DQUOTE$ + Image$ + Class$ + " />"
              EndIf
              HTML$ + "<center>" + EscapeHTML_(String$) + "</center> <br>"
              
            EndIf
            ;}
          Case #TaskList         ;{ Task List
            
            If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
              ForEach MarkDown()\Lists()\Row()
                
                If MarkDown()\Lists()\Row()\State
                  HTML$ + "<input type=" + #DQUOTE$ + "checkbox" + #DQUOTE$ + " checked=" + #DQUOTE$ + "checked" + #DQUOTE$ + ">" + #LF$
                Else
                  HTML$ + "<input type=" + #DQUOTE$ + "checkbox" + #DQUOTE$ + ">" + #LF$
                EndIf
                
                HTML$ + TextHTML_(MarkDown()\Lists()\Row()\Words()) + "<br>"
                
              Next
              
            EndIf
            ;}
          Case #Table            ;{ Table
            
            If SelectElement(MarkDown()\Table(), MarkDown()\Items()\Index)
  
              Cols = MarkDown()\Table()\Cols
              
              HTML$ + "<table>"  + #LF$ ;  border='1'
              
  		        ForEach MarkDown()\Table()\Row()
  
  		          If MarkDown()\Table()\Row()\Type = #TableHeader ;{ Table Header
  		            
  		            HTML$ + "<thead>" + #LF$ + "<tr class=" + #DQUOTE$ + "header" + #DQUOTE$ + ">" + #LF$
                  
  		            For c=1 To Cols
  		              
  		              Num$ = Str(c)
  		              
                    Select MarkDown()\Table()\Column(Str(c))\Align
                      Case "C"
                        HTML$ + "<th style=" + #DQUOTE$ + "text-align: center;" + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </th>" + #LF$
                      Case "R"
                        HTML$ + "<th style=" + #DQUOTE$ + "text-align: right;"  + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </th>" + #LF$
                      Default  
                        HTML$ + "<th style=" + #DQUOTE$ + "text-align: left"    + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </th>" + #LF$
                    EndSelect
                    
                  Next
                  
                  HTML$ + "</tr>" + #LF$ + "</thead>" + #LF$
  		            ;}
  			        Else                                              ;{ Table Body
  			          
  			          If Not tBody
                    HTML$ + "<tbody>" + #LF$
                    tBody = #True
                  EndIf
                  
                  Class ! #True
                  If Class
                    HTML$ + "<tr class=" + #DQUOTE$ + "odd" + #DQUOTE$ + ">" + #LF$
                  Else
                    HTML$ + "<tr class=" + #DQUOTE$ + "even" + #DQUOTE$ + ">" + #LF$
                  EndIf 
  
                  For c=1 To Cols
                    
                    Num$ = Str(c)
                    
                    If MarkDown()\Table()\Row()\Col(Num$)\Span = 0 : Continue : EndIf
                    
                    If MarkDown()\Table()\Row()\Col(Num$)\Span > 1
                      ColSpan$ = " colspan=" + #DQUOTE$ + Str(MarkDown()\Table()\Row()\Col(Num$)\Span) + #DQUOTE$
                    Else
                      ColSpan$ = ""
                    EndIf
                    
                    Select MarkDown()\Table()\Column(Str(c))\Align
                      Case "C"
                        HTML$ + "<td" + ColSpan$ + " style=" + #DQUOTE$ + "text-align: center;" + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </td>" + #LF$
                      Case "R"
                        HTML$ + "<td" + ColSpan$ + " style=" + #DQUOTE$ + "text-align: right;"  + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </td>" + #LF$
                      Default  
                        HTML$ + "<td" + ColSpan$ + " style=" + #DQUOTE$ + "text-align: left;"   + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </td>" + #LF$
                    EndSelect
                  Next
                  
                  HTML$ + "</tr>" + #LF$
  			          ;}
  			        EndIf
  
  			      Next
  			      
  			      HTML$+ "</tbody>" + #LF$ + "</table>" + #LF$
  			     
  		      EndIf
            ;}
          Case #Code             ;{ Code Block
            
            If SelectElement(MarkDown()\Block(), MarkDown()\Items()\Index)
    
              HTML$ + "<pre class=" + #DQUOTE$ + "code" + #DQUOTE$ + ">" + #LF$
              
              If MarkDown()\Block()\String
                HTML$ + "  <code class=" + #DQUOTE$ + "language-" + MarkDown()\Block()\String + #DQUOTE$ +  ">" + #LF$
              Else
                HTML$ + "  <code>" + #LF$
              EndIf
              
              ForEach MarkDown()\Block()\Row()
                HTML$ + Space(4) + EscapeHTML_(MarkDown()\Block()\Row()) + #LF$
              Next
  
              HTML$ + "  </code>" + #LF$ + "</pre>" + #LF$
              
            EndIf
            ;}
          Case #Note             ;{ Note
            
            If SelectElement(MarkDown()\Note(), MarkDown()\Items()\Index)
            
              Select MarkDown()\Note()\Type
                Case "info"  
                  Symbol$    = "<strong class=" + #DQUOTE$ + "symbol" + #DQUOTE$ + " style=" + #DQUOTE$ + "color:#4682B4" + #DQUOTE$ + ">&#x1F6C8; </strong>"
                  BackColor$ = "background-color:#C7D9E8"
                Case "question" 
                  Symbol$    = "<strong class=" + #DQUOTE$ + "symbol" + #DQUOTE$ + " style=" + #DQUOTE$ + "color:#9ACD32" + #DQUOTE$ + ">&nbsp;?</strong>"
                  BackColor$ = "background-color:#E1F0C1"
                Case "error"
                  Symbol$    = "<strong class=" + #DQUOTE$ + "symbol" + #DQUOTE$ + " style=" + #DQUOTE$ + "color:#B22222" + #DQUOTE$ + ">&nbsp;!</strong>"
                  BackColor$ = "background-color:#E8BDBD"
                Case "caution"
                  Symbol$    = "<strong class=" + #DQUOTE$ + "symbol" + #DQUOTE$ + " style=" + #DQUOTE$ + "color:#FF8C32" + #DQUOTE$ + ">&#x26A0; </strong>"
                  BackColor$ = "background-color:#FFDCB2"
              EndSelect
              
              HTML$ + "<div class=" + #DQUOTE$ + "boxtitle" + #DQUOTE$ + " style=" + #DQUOTE$ + BackColor$ + #DQUOTE$ + ">"
              HTML$ + Symbol$ + " <strong class=" + #DQUOTE$ + "note" + #DQUOTE$ + ">"
              HTML$ + TextHTML_(MarkDown()\Items()\Words())
              HTML$ + "</strong>"
              HTML$ + "</div>"
              
              HTML$ + "<div class=" + #DQUOTE$ + "box" + #DQUOTE$ + ">"
              ForEach MarkDown()\Note()\Row()
                HTML$ + TextHTML_(MarkDown()\Note()\Row()\Words())
                HTML$ + "<br>" + #LF$
              Next
              HTML$ + "</div>"
              
            EndIf  
            ;}
          Case #InsertTOC        ;{ Table of Contents
            
            Level = 0

            HTML$ + "<ul class="+ #DQUOTE$ + "tocul" + #DQUOTE$ + ">" + #LF$

            ForEach MarkDown()\TOC()
              
              If Level < MarkDown()\TOC()\Level
                HTML$ + "<ul class="+ #DQUOTE$ + "tocul" + #DQUOTE$ + ">" + #LF$
                Level = MarkDown()\TOC()\Level
              ElseIf Level > MarkDown()\TOC()\Level
                HTML$ + "</ul>" + #LF$
                Level = MarkDown()\TOC()\Level
              EndIf  
              
              If MarkDown()\TOC()\Label
                HTML$ + "<li class="+ #DQUOTE$ + "tocli" + #DQUOTE$ + "><a href=" + #DQUOTE$ + MarkDown()\TOC()\Label + ".html" + #DQUOTE$ + ">" + StringHTML_(MarkDown()\TOC()\Words()) + "</a></li>" + #LF$
              ElseIf MarkDown()\TOC()\ID
                HTML$ + "<li class="+ #DQUOTE$ + "tocli" + #DQUOTE$ + "><a href=#" + #DQUOTE$ + MarkDown()\TOC()\ID + #DQUOTE$ + ">" + StringHTML_(MarkDown()\TOC()\Words()) + "</a></li>" + #LF$
              EndIf
              
            Next 
            
            HTML$ + "</ul>" + #LF$
            ;}
          Default                ;{ Text
            
            HTML$ + TextHTML_(MarkDown()\Items()\Words())
            HTML$ + "<br>" + #LF$
            ;}
        EndSelect
  
      Next
      
      If DL : HTML$ + "</dl>" + #LF$ : EndIf
      
      If BlockQuote
        HTML$ + "</blockquote>" + #LF$
        BlockQuote = #False
      EndIf
      
      If ListSize(MarkDown()\Footnote()) ;{ Footnotes
        
        HTML$ + "<br>"
        HTML$ + "<section class=" + #DQUOTE$ + "footnote" + #DQUOTE$ + ">" + #LF$
        HTML$ + "<hr />" + #LF$
        ForEach MarkDown()\Footnote()
          HTML$ + "<sup class=" + #DQUOTE$ + "footsup" + #DQUOTE$ + ">" + EscapeHTML_(MarkDown()\FootNote()\Label) + "</sup> " + TextHTML_(MarkDown()\FootLabel(MarkDown()\FootNote()\Label)\Words()) + "<br>" + #LF$
        Next
  		  HTML$ + "</section>"+ #LF$
  		  ;}
  		EndIf
      
  	  ProcedureReturn HTML$
  	EndProcedure
  	
    Procedure.s ExportHTML_(Title.s="", FileCSS.s="")
      Define.s HTML$, Style$
      
      If FileCSS
        
        Style$ = "<link rel=" + #DQUOTE$ + "stylesheet" + #DQUOTE$ + " type=" + #DQUOTE$ + "text/css" + #DQUOTE$ + " href=" + #DQUOTE$ + FileCSS + #DQUOTE$ + ">"
        
        HTML$ = "<!DOCTYPE html>" + #LF$ + "<html>" + #LF$ + "<head>" + #LF$ + "<meta charset=" + #DQUOTE$ + "utf-8" + #DQUOTE$ + ">" + #LF$ + "<title>" + Title + "</title>" + #LF$ + Style$ + #LF$ + "</head>" + #LF$
        
      Else
        
        Style$ = "<style>" + #LF$
        Style$ + StyleCSS()
        Style$ + "</style>" + #LF$
  
        HTML$ = "<!DOCTYPE html>" + #LF$ + "<html>" + #LF$ + "<head>" + #LF$ + "<meta charset=" + #DQUOTE$ + "utf-8" + #DQUOTE$ + ">" + #LF$ + "<title>" + Title + "</title>" + #LF$ + Style$ + #LF$ + "</head>" + #LF$

      EndIf
      
      HTML$ + "<body>" + #LF$
      
      HTML$ + ConvertHTML_()
      
      HTML$ + "</body>" + #LF$ + "</html>" + #LF$ 
  
      ProcedureReturn HTML$
      
    EndProcedure
    
  CompilerEndIf

  
  CompilerIf Defined(PDF, #PB_Module)
    
    Procedure.i FontPDF_(PDF.i, Font.i, Underline.i=#False, FontSize.i=12)

      Select Font
        Case #FontNote
          PDF::SetFont(PDF, "Arial", "B", FontSize + 4)
        Case #Font_Bold
          If Underline
            PDF::SetFont(PDF, "Arial", "BU", FontSize)
          Else  
            PDF::SetFont(PDF, "Arial", "B", FontSize)
          EndIf  
        Case #Font_Italic
          If Underline
            PDF::SetFont(PDF, "Arial", "IU", FontSize)
          Else
            PDF::SetFont(PDF, "Arial", "I", FontSize)
          EndIf
        Case #Font_BoldItalic 
          If Underline
            PDF::SetFont(PDF, "Arial", "BIU", FontSize)
          Else
            PDF::SetFont(PDF, "Arial", "BI", FontSize)
          EndIf  
        Case #Font_FootText
          If Underline
            PDF::SetFont(PDF, "Arial", "U", FontSize - 3)
          Else
            PDF::SetFont(PDF, "Arial", "", FontSize - 3)
          EndIf  
        Case #Font_FootBold
          If Underline
            PDF::SetFont(PDF, "Arial", "BU", FontSize - 3)
          Else
            PDF::SetFont(PDF, "Arial", "B", FontSize - 3)
          EndIf  
        Case #Font_FootItalic
          If Underline
            PDF::SetFont(PDF, "Arial", "IU", FontSize - 3) 
          Else
            PDF::SetFont(PDF, "Arial", "I", FontSize - 3) 
          EndIf  
        Case #Font_FootBoldItalic
          If Underline
            PDF::SetFont(PDF, "Arial", "BIU", FontSize - 3)
          Else
            PDF::SetFont(PDF, "Arial", "BI", FontSize -3)
          EndIf  
        Case #Font_Code
          If Underline
            PDF::SetFont(PDF, "Courier New", "U", FontSize)
          Else
            PDF::SetFont(PDF, "Courier New", "", FontSize)
          EndIf  
        Case #Font_H6
          PDF::SetFont(PDF, "Arial", "B", FontSize - 4)
        Case #Font_H5
          PDF::SetFont(PDF, "Arial", "B", FontSize - 2)
        Case #Font_H4
          PDF::SetFont(PDF, "Arial", "B", FontSize)
        Case #Font_H3
          PDF::SetFont(PDF, "Arial", "B", FontSize + 2)
        Case #Font_H2
          PDF::SetFont(PDF, "Arial", "B", FontSize + 6)
        Case #Font_H1 
          PDF::SetFont(PDF, "Arial", "B", FontSize + 12)
        Default
          If Underline
            PDF::SetFont(PDF, "Arial", "U", FontSize)
          Else
            PDF::SetFont(PDF, "Arial", "", FontSize)
          EndIf   
      EndSelect
      ProcedureReturn Font
    EndProcedure
    
    Procedure.i EmojiPDF_(PDF.i, Emoji.s, X.i, Y.i, ImgSize.i)
  
      Select Emoji
        Case ":check0:"
          PDF::ImageMemory(PDF, "CheckBox0.png", ?Check0,    145, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":check1:"
          PDF::ImageMemory(PDF, "CheckBox1.png", ?Check1,    276, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        CompilerIf #Enable_Emoji  
  	    Case ":date:", ":calendar:"
  	      PDF::ImageMemory(PDF, "Date.png",      ?Calendar,  485, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":mail:", ":envelope:"
          PDF::ImageMemory(PDF, "Mail.png",      ?Mail,      437, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":bookmark:"
          PDF::ImageMemory(PDF, "BookMark.png",  ?BookMark,  334, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":memo:"
          PDF::ImageMemory(PDF, "Memo.png",      ?Memo,      408, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":pencil:", ":pencil2:"
          PDF::ImageMemory(PDF, "Pencil.png",    ?Pencil,    480, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":phone:", ":telephone_receiver:"
          PDF::ImageMemory(PDF, "Phone.png",     ?Phone,     383, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case  ":warning:"
          PDF::ImageMemory(PDF, "Warning.png",   ?Attention, 565, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":bulb:"  
          PDF::ImageMemory(PDF, "Bulb.png",      ?Bulb,      396, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":paperclip:", ":clip:" 
          PDF::ImageMemory(PDF, "Clip.png",      ?Clip,      474, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":mag:", ":magnifier:"
          PDF::ImageMemory(PDF, "Mag.png",       ?Magnifier, 520, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":laugh:", ":smiley:"
          PDF::ImageMemory(PDF, "Laugh.png",     ?Laugh,     568, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":smile:", ":simple_smile:"
          PDF::ImageMemory(PDF, "Smile.png",     ?Smile,     512, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":sad:"
          PDF::ImageMemory(PDF, "Sad.png",       ?Sad,       521, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":angry:"
          PDF::ImageMemory(PDF, "Angry.png",     ?Angry,     540, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":cool:", ":sunglasses:"
          PDF::ImageMemory(PDF, "Cool.png",      ?Cool,     629, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":smirk:"
          PDF::ImageMemory(PDF, "Smirk.png",     ?Smirk,    532, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":eyes:", ":flushed:"
          PDF::ImageMemory(PDF, "Eyes.png",      ?Eyes,      583, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":rolf:"
          PDF::ImageMemory(PDF, "Rofl.png",      ?Rofl,      636, PDF::#Image_PNG, X, Y, ImgSize, ImgSize) 
        Case ":wink:"
          PDF::ImageMemory(PDF, "Wink.png",      ?Wink,      553, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":worry:", ":worried:"
          PDF::ImageMemory(PDF, "Worry.png",     ?Worry,     554, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        CompilerEndIf  
      EndSelect
        
    EndProcedure    

  	Procedure.i AlignOffsetPDF_(PDF.i, WordIdx.i, Width.i, Align.s, List Words.Words_Structure())
      Define.i TextWidth, OffsetX
      
      PushListPosition(Words())
      
      ForEach Words()
        
        If ListIndex(Words()) >= WordIdx
          
          If TextWidth + PDF::GetStringWidth(PDF, Words()\String) > Width
            Break
          Else  
            TextWidth + PDF::GetStringWidth(PDF, Words()\String)
          EndIf  
          
        EndIf
        
      Next
      
      PopListPosition(Words())
      
      Select Align
        Case "C"
          OffsetX = (Width - TextWidth) / 2
        Case "R"
          OffsetX = Width - TextWidth - 1
        Default
          OffsetX = 1
      EndSelect    
      
      ProcedureReturn OffsetX
    EndProcedure
  
    Procedure.i RowPDF_(PDF.i, X.i, BlockQuote.i, List Words.Words_Structure(), ColWidth.i=#False, Align.s="L", ID.s="", FontSize.i=12)
      Define.i PosX, PosY, Width, Height, Font, TextWidth, ImgSize, Image, WordIdx, bqY, bqHeight 
      Define.i OffSetX, OffSetY, OffSetBQ, LinkPDF
      Define.s Link$, ID$, File$
      
      If BlockQuote : OffSetBQ = 3 * BlockQuote : EndIf
      
      X + OffSetBQ

      WordIdx = 0

      If ColWidth
        OffSetX = AlignOffsetPDF_(PDF, WordIdx, ColWidth, Align, Words())
      EndIf
      
      PDF::SetPosX(PDF, X + OffSetX)
      bqY = PDF::GetPosY(PDF)
      
      ForEach Words()
        
        If Font <> Words()\Font : Font = FontPDF_(PDF, Words()\Font, #False, FontSize) : EndIf
        
        If Words()\Flag = #Underline
          FontPDF_(PDF, Words()\Font, #True, FontSize)
          Font = #PB_Default
        EndIf
        
        TextWidth = PDF::GetStringWidth(PDF, Words()\String)
        
        If PDF::GetPosX(PDF) + TextWidth > MarkDown()\WrapPos
          
          WordIdx = ListIndex(Words())
          
          If ColWidth
            OffSetX = AlignOffsetPDF_(PDF, WordIdx, ColWidth, Align, Words())
          EndIf
          
          PDF::Ln(PDF, 4.5)
          PDF::SetPosX(PDF, X + OffSetX)

          If BlockQuote
            bqHeight = PDF::GetPosY(PDF) - bqY
            PDF::SetColorRGB(PDF, PDF::#FillColor, 169, 169, 169)
            PDF::DrawRectangle(PDF, X - OffSetBQ, bqY, 1.4, bqHeight, PDF::#FillOnly)
            PDF::SetColorRGB(PDF, PDF::#FillColor, 255, 255, 255)
          EndIf
          
          bqY = PDF::GetPosY(PDF)

        EndIf

        Select Words()\Flag
          Case #Code           ;{ Code
            PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 100, 0)
            PDF::Cell(PDF, Words()\String, TextWidth)
            PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 0)
            ;} 
          Case #Glossary       ;{ Glossary
            PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 128)
            PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, "Glossary")
            PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 0)
            ;}
          Case #AutoLink       ;{ AutoLink
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              
              PDF::SetFont(PDF, "Arial", "U", FontSize)
              PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 255)
              
              If CountString(Words()\String, "@") = 1
                LinkPDF = PDF::AddLinkURL(PDF, URLDecoder("mailto:" + MarkDown()\Link()\URL))
                PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
              Else  
                LinkPDF = PDF::AddLinkURL(PDF, URLDecoder(MarkDown()\Link()\URL))
                PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
              EndIf

              PDF::SetColorRGB(PDF, PDF::#TextColor, 0)
              FontPDF_(PDF, Words()\Font, #False, FontSize)
              
            EndIf
            ;}             
          Case #Emoji          ;{ Emoji 
            X = PDF::GetPosX(PDF)
            EmojiPDF_(PDF, Words()\String, X, #PB_Default, 4)
            PDF::SetPosX(PDF, X + 4)
            ;}  
          Case #FootNote       ;{ Footnote
            FontPDF_(PDF, #Font_FootBold, #False, FontSize)
            PDF::SubWrite(PDF, Words()\String, 4.5, 7, 5)
            ;}
          Case #Highlight      ;{ Highlighted text
            PDF::SetColorRGB(PDF, PDF::#FillColor, 252, 248, 227)
            PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #True)
            PDF::SetColorRGB(PDF, PDF::#FillColor, 255, 255, 255)
            ;}
          Case #Image          ;{ Image
        
            If SelectElement(MarkDown()\Image(), Words()\Index)
              
              PosX   = PDF::GetPosX(PDF)
              PosY   = PDF::GetPosY(PDF)
              Width  = mm_(MarkDown()\Image()\Width)
              Height = mm_(MarkDown()\Image()\Height)
              
              File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
              
              If FindMapElement(MarkDown()\ImageMem(), GetFilePart(MarkDown()\Image()\Source))
                PDF::ImageMemory(PDF, GetFilePart(MarkDown()\Image()\Source), MarkDown()\ImageMem()\Buffer, MarkDown()\ImageMem()\Size, MarkDown()\ImageMem()\Type, PosX, PosY, Width, Height)
              Else  
                PDF::Image(PDF, File$, PosX, PosY, Width, Height)
              EndIf  
              
              PDF::SetPosY(PDF, PosY + Height)

            EndIf
            ;}    
          Case #Link           ;{ Link
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              
              PDF::SetFont(PDF, "Arial", "U", FontSize)
              PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 255)
              
              If MarkDown()\Link()\Label
                Link$ = Trim(MarkDown()\Label(MarkDown()\Link()\Label)\Destination)
              Else
                Link$ = Trim(MarkDown()\Link()\URL)
              EndIf 

              If Left(Link$, 1) = "#"
                PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, Link$)
              Else
                LinkPDF = PDF::AddLinkURL(PDF, URLDecoder(Link$))
                PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
              EndIf

              PDF::SetColorRGB(PDF, PDF::#TextColor, 0)
              FontPDF_(PDF, Words()\Font, #False, FontSize)
              
            EndIf
            ;}
          Case #Keyword        ;{ Keyword  
            PDF::Cell(PDF, Words()\String, TextWidth)
            ;}
          Case #Keystroke      ;{ Keystroke
            PDF::SetMargin(PDF, PDF::#CellMargin, 1)
            PDF::SetColorRGB(PDF, PDF::#FillColor, 245, 245, 245)
            PosY = PDF::GetPosY(PDF)
            PDF::SetPosY(PDF, PosY - 0.2)
            PDF::Cell(PDF, Words()\String, TextWidth + 2, 4.4, #True, PDF::#Right, "", #True)
            PDF::SetColorRGB(PDF, PDF::#FillColor, 255, 255, 255)
            PDF::SetMargin(PDF, PDF::#CellMargin, 0)
            PDF::SetPosY(PDF, PosY)
            ;}
          Case #StrikeThrough  ;{ Strikethrough text
            PDF::DividingLine(PDF, PDF::GetPosX(PDF), PDF::GetPosY(PDF) + 2, TextWidth)
            PDF::Cell(PDF, Words()\String, TextWidth)
            ;}
          Case #Superscript    ;{ Superscripted text
            PDF::SubWrite(PDF, Words()\String, 4.5, 7, 5.4)
            ;}
          Case #Subscript      ;{ Subscripted text
            PDF::SubWrite(PDF, Words()\String, 4.5, 7, -1)
            ;}  
          Default
            If ID
              PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, ID) 
            Else  
              PDF::Cell(PDF, Words()\String, TextWidth)
            EndIf
        EndSelect

      Next

      PDF::Ln(PDF)
      PDF::Ln(PDF, 0.5)
      
      If BlockQuote
        bqHeight = PDF::GetPosY(PDF) - bqY
        PDF::SetColorRGB(PDF, PDF::#FillColor, 169, 169, 169)
        PDF::DrawRectangle(PDF, X - OffSetBQ, bqY, 1.4, bqHeight, PDF::#FillOnly)
        PDF::SetColorRGB(PDF, PDF::#FillColor, 255, 255, 255)
      EndIf

    EndProcedure
    
    Procedure.i SymbolPDF(PDF.i, Char.s, X.i, Y.i, Height.i, Color.i, Triangle.i=#False)
      Define.f cWidth, OffsetX, OffsetY
      
      cWidth = (Height - 2.8) / 2
      
      OffsetX = cWidth / 2
      OffsetY = (Height / 2)
      
      If Triangle
        PDF::DrawTriangle(PDF, X - OffsetX, Y + (Height - 1.4), X + OffsetX, Y + 1.4, X + (cWidth + OffsetX), Y + (Height - 1.4))
      Else
        PDF::DrawCircle(PDF, X + OffsetX, Y + OffsetY, cWidth) 
      EndIf  

      OffsetX = (cWidth - PDF::GetStringWidth(PDF, Char)) / 2
      
      PDF::SetColorRGB(PDF, PDF::#TextColor, Red(Color), Green(Color), Blue(Color))
      
      If Triangle
        PDF::SetPosXY(PDF, X + OffsetX, Y + 0.7)
      Else  
        PDF::SetPosXY(PDF, X + OffsetX, Y + 0.2)
      EndIf
      
      PDF::Cell(PDF, Char, cWidth, Height)
      
      PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 0)
      
      ProcedureReturn X + (cWidth * 2)
    EndProcedure
    
    Procedure.i NotePDF(PDF.i, Index.i, X.i, Y.i, Width, FontSize.i) 
      Define.i PosX, Height, HeaderHeight, OffsetX, OffsetY, BackColor
      Define.s Symbol$, Char$
      
      If SelectElement(MarkDown()\Note(), Index)
        
        FontPDF_(PDF, #Font_Bold, #False, FontSize)
        
        Height = (ListSize(MarkDown()\Note()\Row()) + 1) * PDF::GetStringHeight(PDF) + 8
        HeaderHeight = PDF::GetStringHeight(PDF) + 4
        
        PDF::SetLineThickness(PDF, 0.4)
        
        Select MarkDown()\Note()\Type
          Case "info"  
            BackColor = BlendColor_($B48246, $FFFFFF, 30)
          Case "question"  
            BackColor = BlendColor_($32CD9A, $FFFFFF, 30)
          Case "error"
            BackColor = BlendColor_($2222B2, $FFFFFF, 30)
          Case "caution"
            BackColor = BlendColor_($008CFF, $FFFFFF, 30)
        EndSelect
        
        PDF::SetColorRGB(PDF, PDF::#FillColor, Red(BackColor), Green(BackColor), Blue(BackColor))

        PDF::DrawRoundedRectangle(PDF, X, Y, Width, HeaderHeight + 2, 2, PDF::#FillOnly)
        
        PDF::SetColorRGB(PDF, PDF::#FillColor, 255, 255, 255)
        PDF::DrawRectangle(PDF, X, Y + HeaderHeight, Width, 2, PDF::#FillOnly)
        
        PDF::SetColorRGB(PDF, PDF::#DrawColor, 227, 227, 227)
        
        PDF::DrawRoundedRectangle(PDF, X, Y, Width, Height, 2)
        PDF::DividingLine(PDF, X, Y + HeaderHeight, Width)
        
        Select MarkDown()\Note()\Type
          Case "info"
            PDF::SetColorRGB(PDF, PDF::#DrawColor, 70, 130, 180)
            PosX = SymbolPDF(PDF, "i", 14, Y, HeaderHeight, $B48246)
          Case "question"
            PDF::SetColorRGB(PDF, PDF::#DrawColor, 154, 205, 50)
            PosX = SymbolPDF(PDF, "?", 14, Y, HeaderHeight, $32CD9A)
          Case "error"
            PDF::SetColorRGB(PDF, PDF::#DrawColor, 178, 34, 34)
            PosX = SymbolPDF(PDF, "!", 14, Y, HeaderHeight, $2222B2)
          Case "caution"
            PDF::SetColorRGB(PDF, PDF::#DrawColor, 255, 140, 0)
            PosX = SymbolPDF(PDF, "!", 14, Y, HeaderHeight, $008CFF, #True)
        EndSelect   

        PDF::SetLineThickness(PDF, 0.2)
        
        PDF::SetPosY(PDF, Y + 2)
        
        RowPDF_(PDF, PosX + 1, #False, MarkDown()\Items()\Words(), Width, "L", "", FontSize)
        
        PDF::Ln(PDF, 3)
        
        ForEach MarkDown()\Note()\Row()
          RowPDF_(PDF, 13, #False, MarkDown()\Note()\Row()\Words(), Width, "L", "", FontSize)
        Next
        
        PDF::SetColorRGB(PDF, PDF::#DrawColor, 0, 0, 0)
        
        PDF::SetPosY(PDF, Y + Height)
      EndIf
      
    EndProcedure
    
    Procedure   ConvertPDF_(PDF.i, LeftMargin.i=10, RightMargin.i=10, FontSize.i=12, Level.i=#PB_Default)
      Define.i PosX, PosY, X, Y, Width, Height, LastX, LastWidth, TextWidth, Link
      Define.i RowX, RowY, TableWidth, RowHeight, maxWidth, Count, Sum
      Define.i c, Cols, ColWidth, OffSetX, Width, Height, PageWidth, cutWidth
      Define.f Factor
      Define.s Bullet$, Align$, Text$, Level$, Image$, File$, Num$
      
      NewMap ListNum.i()
      NewMap ColWidth.i()
      NewMap ColX.i()
      NewMap CellBorder.CellBorder_Structure()
      
      If PDF
        
        PDF::SetMargin(PDF, PDF::#TopMargin,  LeftMargin)
        PDF::SetMargin(PDF, PDF::#LeftMargin, RightMargin)
        
        PDF::SetMargin(PDF, PDF::#CellMargin, 0)
        
        PageWidth = PDF::GetPageWidth(PDF)
        
        ForEach MarkDown()\Image() ;{ Images
          
          Image$ = GetFilePart(MarkDown()\Image()\Source)
          File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
          
          If Not FindMapElement(MarkDown()\ImageNum(), Image$) Or IsImage(MarkDown()\ImageNum()) = #False
            
            If AddMapElement(MarkDown()\ImageNum(), Image$)
              If FindMapElement(MarkDown()\ImageMem(), Image$)
                MarkDown()\ImageNum() = CatchImage(#PB_Any, MarkDown()\ImageMem()\Buffer, MarkDown()\ImageMem()\Size)
              Else  
                MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
              EndIf 
            EndIf
            
          EndIf
          
          If IsImage(MarkDown()\ImageNum())
	          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
	          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
	        EndIf
          ;}
        Next   
        
        ForEach MarkDown()\Items()
          
          MarkDown()\WrapPos = PageWidth - PDF::GetMargin(PDF, PDF::#RightMargin)
          
          FontPDF_(PDF, #Font_Normal, #False, FontSize)
          
          Select MarkDown()\Items()\Type
            Case #Heading        ;{ Heading
              
              If MarkDown()\Type <> #HelpWindow
                If Level <> #PB_Default
                  If Level <= 3 : PDF::AddEntryTOC(PDF, GetString_(MarkDown()\Items()\Words()), Level) : EndIf
                ElseIf MarkDown()\Items()\Level <= 3
                  PDF::AddEntryTOC(PDF, GetString_(MarkDown()\Items()\Words()), MarkDown()\Items()\Level)
                EndIf
              EndIf
            
              If MarkDown()\Items()\ID
                RowPDF_(PDF, LeftMargin, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words(), #False, "L", MarkDown()\Items()\ID, FontSize)
              Else
                RowPDF_(PDF, LeftMargin, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words(), #False, "L", "", FontSize)
              EndIf  

              PDF::Ln(PDF, 3)
              ;}
            Case #Image          ;{ Image
              If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
                
                PDF::Ln(3)
                
                PosY   = PDF::GetPosY(PDF)
                Width  = mm_(MarkDown()\Image()\Width)
                Height = mm_(MarkDown()\Image()\Height)
                
                PosX = (PageWidth - Width) / 2
               
                File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
                
                If FindMapElement(MarkDown()\ImageMem(), GetFilePart(MarkDown()\Image()\Source))
                  PDF::ImageMemory(PDF, GetFilePart(MarkDown()\Image()\Source), MarkDown()\ImageMem()\Buffer, MarkDown()\ImageMem()\Size, MarkDown()\ImageMem()\Type, PosX, PosY, Width, Height)
                Else  
                  PDF::Image(PDF, File$, PosX, PosY, Width, Height)
                EndIf  

                PDF::SetPosY(PDF, PosY + Height)

                If ListSize(MarkDown()\Items()\Words())
                  PDF::SetPosY(PDF, PosY + Height + 1)
                  RowPDF_(PDF, 10, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words(), PageWidth - 20, "C", "", FontSize - 2)
                Else  
                  PDF::SetPosY(PDF, PosY + Height)
    	          EndIf
    	          
    	          PDF::Ln(3)
    	          
              EndIf
              ;}
            Case #OrderedList    ;{ Ordered List
              
              ClearMap(ListNum())
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
                ForEach MarkDown()\Lists()\Row()
                  
                  FontPDF_(PDF, #Font_Normal, #False, FontSize)
                  
                  Level$ = Str(MarkDown()\Lists()\Row()\Level)
                  
                  ListNum(Level$) + 1
                  
                  TextWidth = PDF::GetStringWidth(PDF, Str(ListNum(Level$)) + ". ")
                  
                  If MarkDown()\Lists()\Row()\Level
                    PDF::SetPosX(PDF, LeftMargin + 5 + (TextWidth * MarkDown()\Lists()\Row()\Level))
                  Else  
                    PDF::SetPosX(PDF, LeftMargin + 5)
                  EndIf 

                  PDF::Cell(PDF, Str(ListNum(Level$)) + ". ", TextWidth)
                  
                  X = PDF::GetPosX(PDF)
                  RowPDF_(PDF, X, #False, MarkDown()\Lists()\Row()\Words(), #False, "L", "", FontSize)
                  
                Next 
                
              EndIf
              ;}
            Case #UnorderedList  ;{ Unordered List
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
                ForEach MarkDown()\Lists()\Row()
                  
                  FontPDF_(PDF, #Font_Normal, #False, FontSize)
                  
                  Bullet$ = #Bullet$
                  
                  TextWidth = PDF::GetStringWidth(PDF, Bullet$ + " ")
                  
                  If MarkDown()\Lists()\Row()\Level
                    PDF::SetPosX(PDF, LeftMargin + 5 + (TextWidth * MarkDown()\Lists()\Row()\Level))
                  Else  
                    PDF::SetPosX(PDF, LeftMargin + 5)
                  EndIf 

                  PDF::Cell(PDF, Bullet$ + " ", TextWidth)
                  
                  X = PDF::GetPosX(PDF)
                  RowPDF_(PDF, X, #False, MarkDown()\Lists()\Row()\Words(), #False, "L", "", FontSize)
                  
                Next 
                
              EndIf
              ;}
            Case #TaskList       ;{ Task List

              PDF::Ln(PDF, 3)

              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
                ForEach MarkDown()\Lists()\Row()
                  
                  FontPDF_(PDF, #Font_Normal, #False, FontSize)
                  
                  X = PDF::GetPosX(PDF)
                  PDF::SetPosX(PDF, LeftMargin + 5)
                  
                  If MarkDown()\Lists()\Row()\State
                    EmojiPDF_(PDF, ":check1:", X, #PB_Default, 4)
                  Else
                    EmojiPDF_(PDF, ":check0:", X, #PB_Default, 4)
                  EndIf

                  X = PDF::GetPosX(PDF) + PDF::GetStringWidth(PDF, " ")
                  
                  RowPDF_(PDF, X, MarkDown()\Items()\BlockQuote, MarkDown()\Lists()\Row()\Words(), #False, "L", "", FontSize)
                  
                  PDF::Ln(PDF, 0.5)
                Next
                
              EndIf
              
              PDF::Ln(PDF, 3)
              ;}
            Case #DefinitionList ;{ Definition List
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
                
                RowPDF_(PDF, LeftMargin, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words(), #False, "L", "", FontSize)
                
                PDF::Ln(PDF, 1)
                
                ForEach MarkDown()\Lists()\Row()
                  FontPDF_(PDF, #Font_Normal, #False, FontSize)
                  RowPDF_(PDF, LeftMargin + 5, MarkDown()\Items()\BlockQuote, MarkDown()\Lists()\Row()\Words(), #False, "L", "", FontSize)
                Next
                
                PDF::Ln(PDF, 2)
                
              EndIf  
              ;} 
            Case #Glossary       ;{ Glossary 
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
                
                PDF::AddGotoLabel(PDF, "Glossary")
                
                PDF::Ln(PDF, 2)
                
                ForEach MarkDown()\Lists()\Row()
                  
                  PDF::SetPosX(PDF, 10)
                  FontPDF_(PDF, #Font_Bold, #False, FontSize - 2)
                  PDF::Cell(PDF, MarkDown()\Lists()\Row()\String, PDF::GetStringWidth(PDF, MarkDown()\Lists()\Row()\String), #PB_Default, #False, PDF::#NextLine) 
   
                  RowPDF_(PDF, LeftMargin + 5, MarkDown()\Items()\BlockQuote, MarkDown()\Lists()\Row()\Words(), #False, "L", "", FontSize- 2)
                  PDF::Ln(PDF, 1.5)
                  
                Next
                
                PDF::Ln(PDF, 2)
                
              EndIf    
              ;}  
            Case #Line           ;{ Horizontal Rule
              PDF::Ln(PDF, 3)
              PDF::DividingLine(PDF)
              PDF::Ln(PDF, 3)
              ;}
            Case #Paragraph      ;{ Paragraph
              PDF::Ln(PDF, 3)
              ;}
            Case #Table          ;{ Table  

              If SelectElement(MarkDown()\Table(), MarkDown()\Items()\Index)
                
                Cols = MarkDown()\Table()\Cols
                
                ClearMap(ColX())
                ClearMap(ColWidth())
                ClearMap(CellBorder())
                
                ;{ ___ Columns ___
                For c=1 To Cols
                  ColWidth(Str(c)) = mm_(MarkDown()\Table()\Column(Str(c))\Width) + 4
                  TableWidth + ColWidth(Str(c))
                Next
                
                maxWidth = PageWidth - (LeftMargin + RightMargin)

                If TableWidth > maxWidth
                  
                  Count = 0
                  Sum   = 0
                  
                  cutWidth = TableWidth - maxWidth

                  ColWidth = maxWidth / Cols
                  For c=1 To Cols
                    If ColWidth(Str(c)) > ColWidth
                      Sum   + (ColWidth(Str(c)) - ColWidth)
                      Count + 1
                    EndIf  
                  Next

                  
                  For c=1 To Cols
                    If ColWidth(Str(c)) > ColWidth
                      Factor = (ColWidth(Str(c)) - ColWidth) / Sum
                      ColWidth(Str(c)) - (cutWidth * Factor)
                    EndIf
                  Next   
                  
                EndIf  
                
                X = LeftMargin
                For c=1 To Cols
                  ColX(Str(c)) = X
                  X + ColWidth(Str(c))
                Next
                ;}
                
                PDF::SetLineThickness(PDF, 0.3)
                
  			        ForEach MarkDown()\Table()\Row()
  			          
  			          LastX = #PB_Default
  			          RowY  = 0
  			          LastWidth = 0
  			          
  			          Y = PDF::GetPosY(PDF)

  			          If MarkDown()\Table()\Row()\Type = #TableHeader ;{ Header
  			            
  			            FontPDF_(PDF, #Font_Bold, #False, FontSize)
  			            
  			            PDF::SetColorRGB(PDF, PDF::#FillColor, 245, 245, 245)
                    For c=1 To Cols
                      
                      ColWidth = ColWidth(Str(c))
                      
                      
                      If MarkDown()\Table()\Row()\Col(Str(c))\Span = 0 : Continue : EndIf 

                      X = ColX(Str(c))
                      
                      PDF::SetPosXY(PDF, X, Y)
                      PDF::DrawRectangle(PDF, X, Y, ColWidth, PDF::GetStringHeight(PDF) + 1.8, PDF::#DrawAndFill)
                      
                      PDF::SetPosY(PDF, Y + 1)
                      
                      If FindMapElement(MarkDown()\Table()\Row()\Col(), Str(c))
                        RowPDF_(PDF, X, #False, MarkDown()\Table()\Row()\Col()\Words(), ColWidth, MarkDown()\Table()\Column(Str(c))\Align, "", FontSize)
                      EndIf
                      
                      If PDF::GetPosY(PDF)> RowY : RowY = PDF::GetPosY(PDF) : EndIf 

                    Next
                    
                    PDF::SetPosY(PDF, RowY)
                    
                    PDF::SetColorRGB(PDF, PDF::#FillColor, 255, 255, 255)
                    ;}
    			        Else                                            ;{ Content
    			          
    			          FontPDF_(PDF, #Font_Normal, #False, FontSize)

                    For c=1 To Cols
                      
                      Num$ = Str(c)
                      
                      CellBorder(Num$)\Border = #False
                      
                      X = ColX(Num$)

                      If MarkDown()\Table()\Row()\Col(Num$)\Span = 0 ;{ ColSpan
 
                        If c=1
                          LastX = X
                          LastWidth = GetSpanWidth_(1, MarkDown()\Table()\Row()\Col("2")\Span, ColWidth(), #True)
                          Continue
                        ElseIf LastX >= 0
                          LastWidth = GetSpanWidth_(1, MarkDown()\Table()\Row()\Col(Str(c + 1))\Span, ColWidth(), #True)
                        EndIf

                        Continue
                        
                      ElseIf LastX >= 0
                        X = LastX
                        colWidth = LastWidth
                        LastX = #PB_Default
                      ElseIf MarkDown()\Table()\Row()\Col(Str(c))\Span > 1
                        colWidth = GetSpanWidth_(c, MarkDown()\Table()\Row()\Col(Str(c))\Span, ColWidth(), #True)
                      Else
                        colWidth = ColWidth(Str(c))
                        ;}
                      EndIf 
                      
                      CellBorder(Str(c))\Border = #True
                      CellBorder(Str(c))\X      = X
                      CellBorder(Str(c))\Width  = ColWidth
                      
                      MarkDown()\WrapPos = X + colWidth - 1

                      PDF::SetPosXY(PDF, X, Y + 1.4)
                      
                      If FindMapElement(MarkDown()\Table()\Row()\Col(), Str(c))
                        RowPDF_(PDF, X, #False, MarkDown()\Table()\Row()\Col()\Words(), ColWidth, MarkDown()\Table()\Column(Num$)\Align, "", FontSize)
                      EndIf
                      
                      PDF::Ln(PDF, 0.4)
                      
                      If PDF::GetPosY(PDF) > RowY : RowY = PDF::GetPosY(PDF) : EndIf 
                      
                    Next
                    
                    RowHeight = RowY - Y + 0.3
                    
                    For c=1 To Cols
                      If CellBorder(Str(c))\Border
                        PDF::DrawRectangle(PDF, CellBorder(Str(c))\X, Y, CellBorder(Str(c))\Width, RowHeight)
                      EndIf
                    Next
                  
                    MarkDown()\WrapPos = PageWidth - PDF::GetMargin(PDF, PDF::#RightMargin)
                    
                    PDF::SetPosY(PDF, RowY)
    			          ;}
    			        EndIf

    			      Next
    			      
    			      MarkDown()\WrapPos = PageWidth - PDF::GetMargin(PDF, PDF::#RightMargin)
    			      
    			      PDF::SetLineThickness(PDF, 0.2)
    			      
  			      EndIf
              ;}
            Case #Code           ;{ Code Block

              PDF::Ln(PDF, 3)
              
              If SelectElement(MarkDown()\Block(), MarkDown()\Items()\Index)
                
                FontPDF_(PDF, #Font_Code, #False, FontSize)
                PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 100, 0)
                ForEach MarkDown()\Block()\Row()
                  PDF::Cell(PDF, MarkDown()\Block()\Row(), #PB_Default, #PB_Default, #False, PDF::#NextLine)  
                Next
                PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 0)
              EndIf 
            
              PDF::Ln(PDF, 3)
              ;}
            Case #Note           ;{ Note
              
              Y = PDF::GetPosY(PDF)
              NotePDF(PDF, MarkDown()\Items()\Index, LeftMargin, Y, PageWidth - 40, FontSize) 
            ;}  
            Case #InsertTOC      ;{ Table of Contents
              PDF::InsertTOC(PDF, #False, "", #False, 10, "Arial")
              ;}
            Default              ;{ Text
              RowPDF_(PDF, LeftMargin, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words(), #False, "L", "", FontSize)
              ;}  
          EndSelect
          
        Next
        
        If ListSize(MarkDown()\Footnote()) ;{ Footnotes
          
          PDF::Ln(PDF, 5)
          PDF::DividingLine(PDF, #PB_Default, #PB_Default, 60)
          PDF::Ln(PDF, 2)
          
          ForEach MarkDown()\Footnote()
            FontPDF_(PDF, #Font_FootBold, #False, FontSize)
            PDF::SubWrite(PDF, MarkDown()\FootNote()\Label + " ", 4.5, 7, 5)
            FontPDF_(PDF, #Font_FootNote, #False, FontSize)
            X = PDF::GetPosX(PDF)
            If FindMapElement(MarkDown()\FootLabel(), MarkDown()\FootNote()\Label)
              RowPDF_(PDF, X, #False, MarkDown()\FootLabel()\Words(), #False, "L", "", FontSize)
            EndIf
          Next
    		  ;}
    		EndIf
    		
    		PDF::SetMargin(PDF, PDF::#CellMargin, 1)
    		
      EndIf  
      
    EndProcedure
    
    Procedure   ExportPDF_(File.s, Title.s="", LeftMargin.i=10, RightMargin.i=10)
      Define.i PDF

      PDF = PDF::Create(#PB_Any)
      If PDF
        
        If Title : PDF::SetInfo(PDF, PDF::#Title, Title) : EndIf

        PDF::AddPage(PDF)
        
        ConvertPDF_(PDF, 10, 10)

        PDF::Close(PDF, File)
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  ;- ============================================================================
	;-   Module - Markdown Parser
  ;- ============================================================================	
  
  CompilerIf #Enable_Emoji
    
    Procedure.i Emoji_(Row.s, sPos.i)
      Define.i ePos
      
      ePos = FindString(Row, ":", sPos + 1)
      If ePos
        
        Select Mid(Row, sPos, ePos - sPos + 1)
          Case ":laugh:", ":smiley:"
            ProcedureReturn ePos
          Case ":smile:", ":simple_smile:"
            ProcedureReturn ePos
          Case ":sad:"
            ProcedureReturn ePos
          Case ":angry:"
            ProcedureReturn ePos
          Case ":cool:", ":sunglasses:"
            ProcedureReturn ePos
          Case ":smirk:"
            ProcedureReturn ePos
          Case ":eyes:", ":flushed:"
            ProcedureReturn ePos
          Case ":rolf:", ":joy:"
            ProcedureReturn ePos
          Case ":wink:"
            ProcedureReturn ePos
          Case ":worry:", ":worried:"
            ProcedureReturn ePos
          Case ":phone:", ":telephone_receiver:" 
            ProcedureReturn ePos
          Case ":mail:", ":envelope:"
            ProcedureReturn ePos
          Case ":date:"
            ProcedureReturn ePos
          Case ":memo:"  
            ProcedureReturn ePos
          Case ":pencil:", ":pencil2:"
            ProcedureReturn ePos
          Case ":bookmark:", ":pencil2:"
            ProcedureReturn ePos  
          Case ":warning:"
            ProcedureReturn ePos 
          Case ":paperclip:", ":clip:"
            ProcedureReturn ePos 
          Case ":bulb:"
            ProcedureReturn ePos 
          Case ":mag:", ":magnifier:"   
            ProcedureReturn ePos 
        EndSelect
        
      EndIf
      
      ProcedureReturn #False  
    EndProcedure  
    
  CompilerEndIf
  
  Procedure.i IsPunctationChar(Char.s)
    
    Select Char
      Case "+", "-", ".", ",", ":", ";", "<", ">", "?"
        ProcedureReturn #True
      Case "#", "$", "%", "&", "*", "@", "^", "|", "/"
        ProcedureReturn #True
      Case "'", "`", #DQUOTE$
        ProcedureReturn #True
    EndSelect
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.s GetChars_(String.s, Char.s)
    Define.i c
    Define.s Chars$
    
    For c=1 To Len(String)
      
      If Mid(String, c, 1) = Char
        Chars$ + Char
      Else
        Break
      EndIf  
      
    Next
    
    ProcedureReturn Chars$
  EndProcedure
  
  Procedure.i CountSpan_(String.s, Pos.i)
    Define.i c, Span
 
    For c=Pos To Len(String)
      
      If Mid(String, c, 1) = "|"
        Span + 1
      Else
        Break
      EndIf  
      
    Next
    
    ProcedureReturn Span
  EndProcedure
  
  ; ------------------------------------------------

	Procedure.i ListLevelDoc_(Pos.i, Indent, *Lists.List_Structure) 
    Define.i Offset, iDiff

    If *Lists\Indent

      Offset = Indent - Pos
      
      If Pos > *Lists\Indent
        iDiff = Pos - *Lists\Indent
        If iDiff < 4
          *Lists\Level + 1
          ProcedureReturn #True
        EndIf
      
      ElseIf Pos < *Lists\Indent

        If Pos < (*Lists\Indent - Offset)
          *Lists\Level - 1
          ProcedureReturn #True
        Else
          ProcedureReturn #True
        EndIf  
        
      EndIf

    EndIf
    
    ProcedureReturn #False
  EndProcedure 
	
  Procedure.i AddDocRow_(String.s, Type.i)
    
    If AddElement(Document())
      Document()\Type   = Type
      Document()\String = String
      ProcedureReturn #True
    EndIf 
    
  EndProcedure 	

	Procedure.i AddItemByType_(Type.i, BlockQuote.i)
    
    If ListSize(MarkDown()\Items()) = 0 Or MarkDown()\Items()\Type <> Type
      If AddElement(MarkDown()\Items())
        MarkDown()\Items()\Type       = Type
        MarkDown()\Items()\BlockQuote = BlockQuote
        ProcedureReturn #True
      EndIf  
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i AddWords_(String.s, List Words.Words_Structure(), Font.i=#Font_Normal, Flag.i=#False, Index.i=#PB_Default)
    Define.i w, Number
    Define.s Word$, LSpace$, RSpace$
    
    If String = "" : ProcedureReturn #False : EndIf
    
    If Left(String, 1) = " "
      LSpace$ = " "
      String = Mid(String, 2)
    EndIf  
    
    If Right(String, 1) = " "
      RSpace$ = " "
      String = Left(String, Len(String) - 1)
    EndIf  
    
	  Number = CountString(String, " ") + 1
	  For w=1 To Number
	    
	    Word$ = StringField(String, w, " ")

	    If AddElement(Words())
	      
	      If w = 1 : Word$ = LSpace$ + Word$ : EndIf 
	      
	      If w = Number
	        Word$ + RSpace$
	      Else  
	        Word$ + " "
	      EndIf  
	      
        Words()\String = Word$
        Words()\Font   = Font
        Words()\Index  = Index
        Words()\Flag   = Flag 
        
      EndIf

	  Next
	  
	  ProcedureReturn #True
	EndProcedure
  
	Procedure.i AddStringBefore_(sPos.i, Pos.i, Row.s, FirstItem.i, List Words.Words_Structure())

	  If sPos <= Pos
	    
	    If FirstItem
	      AddWords_(LTrim(Mid(Row, sPos, Pos - sPos)), Words(), #Font_Normal, #Text)
	      FirstItem = #False
	    Else
	      AddWords_(Mid(Row, sPos, Pos - sPos), Words(), #Font_Normal, #Text)
	    EndIf
	    
    EndIf
    
    ProcedureReturn FirstItem
  EndProcedure  
  
  
  Procedure.i ParseString_(String.s, Font.i, Type.i, List Words.Words_Structure(), LastHeading.s)
    Define.i ePos, nPos
    Define.s Strg$
    
    If Left(String, 1) = "<"  ;{ Autolinks

      ePos = FindString(String, ">", 2)
      If ePos

        If AddElement(MarkDown()\Link())
          
          If AddElement(Words())
            Words()\String = Mid(String, 2, ePos - 2)
            Words()\Font   = Font
            Words()\Index  = ListIndex(MarkDown()\Link())
            Words()\Flag   = #AutoLink
          EndIf
          
          MarkDown()\Link()\String = Words()\String
          MarkDown()\Link()\URL    = Words()\String
          
          ProcedureReturn #True
        EndIf

      EndIf  
      ;}
    EndIf 

    If Left(String, 2) = "[>"     ;{ Visible Keyword
      
      ePos = FindString(String, "]", 3)
      If ePos

        Strg$ = Mid(String, 3, ePos - 4)
        
        If AddElement(MarkDown()\Keyword(Strg$)\HeadingID())
          
          If AddElement(Words())
            Words()\String = Strg$
            Words()\Font   = Font
            Words()\Index  = ListIndex(MarkDown()\Keyword(Strg$)\HeadingID())
            Words()\Flag   = #Keyword
          EndIf
          
          MarkDown()\Keyword(Strg$)\HeadingID() = LastHeading
        EndIf
        
        ProcedureReturn #True
      EndIf
      ;}
    ElseIf Left(String, 1) = "["   ;{ Links

      ePos = FindString(String, "][", 2)
      If ePos
        ;{ Reference link
        If AddElement(MarkDown()\Link())
          
          If AddElement(Words())
            Words()\String = Mid(String, 2, ePos - 3)
            Words()\Font   = Font
            Words()\Index  = ListIndex(MarkDown()\Link())
            Words()\Flag   = #Link 
          EndIf
          
          MarkDown()\Link()\String = Words()\String
          
          nPos = ePos + 2
          
          ePos = FindString(String, "]", nPos)
          If ePos
            MarkDown()\Link()\Label = Mid(String, nPos + 1, nPos - 2)
          EndIf
          
          ProcedureReturn #True
        EndIf
        ;}
      Else
        ;{ Inline link
        ePos = FindString(String, "](", 2)
        If ePos

          If AddElement(MarkDown()\Link())
            
            If AddElement(Words())
              Words()\String = Mid(String, 2, ePos - 2)
              Words()\Font   = Font
              Words()\Index  = ListIndex(MarkDown()\Link())
              Words()\Flag   = #Link 
            EndIf
            
            MarkDown()\Link()\String = Words()\String
            
            nPos = ePos + 2
            
            ePos = FindString(String, ")", nPos)
            If ePos

              ;{ Destination
              Strg$ = Trim(Mid(String, nPos, ePos - nPos))
              If Left(Strg$, 1) = "<"
                nPos = FindString(Strg$, ">", 2)
                If nPos
                  MarkDown()\Link()\URL = Mid(Strg$, 2, nPos - 1)
                  Strg$ = Trim(Mid(Strg$, nPos + 1))
                EndIf 
              Else
                MarkDown()\Link()\URL = StringField(Strg$, 1, " ")
                Strg$ = Trim(Mid(Strg$, Len(MarkDown()\Link()\URL) + 1))
              EndIf ;}
              
              ;{ Title
              If Strg$
                Select Left(Strg$, 1)
                  Case #DQUOTE$
                    nPos = FindString(Strg$, #DQUOTE$, 2)  
                  Case "'" 
                    nPos = FindString(Strg$, "'", 2)
                EndSelect
                If nPos
                  MarkDown()\Link()\Title = Mid(Strg$, 2, nPos - 2)
                EndIf 
              EndIf ;}
              
              ProcedureReturn #True
            EndIf
            
          EndIf

        EndIf
        ;}
      EndIf  
      ;}
    EndIf  

    If Left(String, 2) = "~~" ;{ StrikeThrough

      ePos = FindString(String, "~~", 3)
      If ePos
        
        AddWords_(Mid(String, 3, ePos - 3), Words(), Font, #StrikeThrough)
        
        ProcedureReturn #True
      EndIf
      ;}
    EndIf
    
    If Left(String, 2) = "==" ;{ Highlight

      ePos = FindString(String, "==", 3)
      If ePos

        AddWords_(Mid(String, 3, ePos - 3), Words(), Font, #Highlight)

        ProcedureReturn #True
      EndIf
      ;}
    EndIf
    
    If Left(String, 2) = "++" ;{ Underline

      ePos = FindString(String, "++", 3)
      If ePos

        AddWords_(Mid(String, 3, ePos - 3), Words(), Font, #Underline)

        ProcedureReturn #True
      EndIf
      ;}
    EndIf
    
    AddWords_(String, Words(), Font, Type)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure   ParseInline_(Row.s, List Words.Words_Structure(), LastHeading.s="")
    Define.i Pos, sPos, ePos, nPos, Length, FirstItem
    Define.i Left, Right
    Define.s String$, Start$, Char$
    
    Pos = 1 : sPos = 1
    
    Length = Len(Row)
    
    FirstItem = #True
    
    Repeat
      
      ePos = 0
      
      Select Mid(Row, Pos, 1)
        Case "\"
          ;{ ___ Backslash escapes ___            [6.1]
          Select Mid(Row, Pos, 2)
            Case "\+", "\-", "\=", "\<", "\>", "\~", "\:", "\.", "\,", "\;", "\!", "\?"
              Row = RemoveString(Row, "\", #PB_String_CaseSensitive, Pos, 1)
              Pos + 1
            Case "\@", "\*", "\#", "\$", "\%", "\&", "\^", "\`", "\'", "\"+#DQUOTE$ 
              Row = RemoveString(Row, "\", #PB_String_CaseSensitive, Pos, 1)
              Pos + 1
            Case "\{", "\}", "\[", "\]", "\(", "\)", "\_","\\", "\|", "\/"
              Row = RemoveString(Row, "\", #PB_String_CaseSensitive, Pos, 1)
              Pos + 1
          EndSelect
          ;}
        Case "`"
          ;{ ___ Code spans ___                   [6.3] 
          If Mid(Row, Pos, 2) = "``"  ;{ " ``code`` "
            
            ePos = FindString(Row, "``", Pos + 2)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())

              String$ = Mid(Row, Pos + 2, ePos - Pos - 2)
              If Left(String$, 1) = " " : String$ = Mid(String$, 2) : EndIf ; Remove 1 leading space
              
              AddWords_(String$, Words(), #Font_Code, #Code)
              
              ePos + 1
            EndIf
            
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
            ;}
          Else                         ;{ " `code` "
            
            ePos = FindString(Row, "`",  Pos + 1)
            If ePos

              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              String$ = Mid(Row, Pos + 1, ePos - Pos - 1)
              If Left(String$, 1) = " " : String$ = Mid(String$, 2) : EndIf ; Remove 1 leading space
              
              AddWords_(String$, Words(), #Font_Code, #Code)
              
            EndIf
            
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
            ;}
          EndIf
          ;}
        Case "*", "_"
          ;{ ___ Emphasis and strong emphasis ___ [6.4]
          String$ = Mid(Row, Pos)
          Start$  = GetChars_(String$, Mid(Row, Pos, 1))

          ;{ left-flanking delimiter run [6.4] ?
          Left = #False
          Char$ = Mid(String$, Len(Start$) + 1, 1)
          If Char$ <> " "
            If IsPunctationChar(Char$)
              Char$ = Mid(String$, Len(Start$) + 2, 1)
              If Char$ <> " " And IsPunctationChar(Char$) = #False
                Left = #True
              EndIf   
            Else
              Left = #True
            EndIf
          EndIf ;}
          
          If Left
            
            String$ = LTrim(String$, Left(Start$, 1))
            
            ;{ right-flanking delimiter run [6.4] ?
            Right = #False
            ePos = FindString(String$, Start$)
            If ePos
              Char$ = Mid(String$, ePos - 1, 1)
              If Char$ <> " "
                If IsPunctationChar(Char$)
                  Char$ = Mid(String$, ePos - 2, 1)
                  If Char$ <> " " And IsPunctationChar(Char$) = #False
                    Right = #True
                  EndIf
                Else
                  Right = #True
                EndIf
              EndIf
            EndIf
            ;}
            
            If Right
              
              ePos = 0
              
              Select Start$
                Case "***", "___" ;{ #BoldItalic
                  
                  ePos = FindString(Row, Start$, Pos + 3)
                  If ePos
                    
                    FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                    
                    If ParseString_(Mid(Row, Pos + 3, ePos - Pos - 3), #Font_BoldItalic, #BoldItalic, Words(), LastHeading)
                      ePos + 2
                    EndIf
                    
                  EndIf
                  ;}
                Case "**", "__"   ;{ #Bold
                  
                  ePos = FindString(Row, Start$, Pos + 2)
                  If ePos
                    
                    FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                    
                    If ParseString_(Mid(Row, Pos + 2, ePos - Pos - 2), #Font_Bold, #Bold, Words(), LastHeading)
                      ePos + 1
                    EndIf
                    
                  EndIf
                  ;}
                Case "*", "_"     ;{ #Italic
                  
                  ePos = FindString(Row, Start$, Pos + 1)
                  If ePos
                    
                    FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                    
                    ParseString_(Mid(Row, Pos + 1, ePos - Pos - 1), #Font_Italic, #Italic, Words(), LastHeading)
                    
                  EndIf
                  ;}
              EndSelect 
              
              If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
            EndIf
          
          EndIf
          ;}
        Case "!"
          ;{ ___ Images ___                       [6.6]
          If Mid(Row, Pos, 2) = "!["

            ePos = FindString(Row, "][", Pos + 1)
            If ePos
              ;{ Reference link
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(MarkDown()\Image())
                
                If AddElement(Words())
                  Words()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                  Words()\Font   = #Font_Normal
                  Words()\Index  = ListIndex(MarkDown()\Image())
                  Words()\Flag   = #Image 
                EndIf
                
                nPos = ePos + 2
                
                ePos = FindString(Row, "]", nPos)
                If ePos
                  MarkDown()\Image()\Label = Mid(Row, Pos + 1, ePos - Pos - 1)
                EndIf
                
              EndIf  
              ;}
            Else
              ;{ Inline link
              ePos = FindString(Row, "](", Pos + 1)
              If ePos
                
                FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                
                If AddElement(MarkDown()\Image())
                
                  If AddElement(Words())
                    Words()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                    Words()\Font   = #Font_Normal
                    Words()\Index  = ListIndex(MarkDown()\Image())
                    Words()\Flag   = #Image 
                  EndIf
                  
                  nPos = ePos + 2
                  
                  ePos = FindString(Row, ")", nPos)
                  If ePos
                  
                    ;{ Source
                    String$ = Trim(Mid(Row, nPos, ePos - nPos))
                    If Left(String$, 1) = "<"
                      nPos = FindString(String$, ">", 2)
                      If nPos
                        MarkDown()\Image()\Source = AdjustImagePath(Trim(Mid(String$, 2, nPos - 1), #DQUOTE$))
                        String$ = Trim(Mid(String$, nPos + 1))
                      EndIf 
                    Else
                      MarkDown()\Image()\Source = AdjustImagePath(Trim(StringField(String$, 1, " "), #DQUOTE$))
                      String$ = Trim(Mid(String$, Len(MarkDown()\Image()\Source) + 1))
                    EndIf ;}
                    
                    ;{ Title
                    If String$
                      Select Left(String$, 1)
                        Case #DQUOTE$
                          nPos = FindString(String$, #DQUOTE$, 2)  
                        Case "'" 
                          nPos = FindString(String$, "'", 2)
                      EndSelect
                      If nPos
                        MarkDown()\Image()\Title = Mid(String$, 2, nPos - 2)
                      EndIf 
                    EndIf ;}
                    
                  EndIf
                  
                EndIf
                
              EndIf
              ;}
            EndIf
            
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
          EndIf   
          ;}
        Case "["
          ;{ ___ Footnotes / Glossary / Keystrokes / Links
          If Mid(Row, Pos, 2) = "[^"
            ;{ ___ Footnote ___
            ePos = FindString(Row, "]", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(MarkDown()\Footnote())
                
                If AddElement(Words())
                  Words()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                  Words()\Font   = #Font_FootNote
                  Words()\Index  = ListIndex(MarkDown()\Footnote())
                  Words()\Flag   = #FootNote 
                EndIf
                
                MarkDown()\Footnote()\Label = Words()\String

              EndIf
              
            EndIf 
          
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf  
            ;}
          ElseIf Mid(Row, Pos, 2) = "[?"  
            ;{ ___ Glossary ___
            ePos = FindString(Row, "]", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(MarkDown()\GlossaryWord())
                
                If AddElement(Words())
                  Words()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                  Words()\Font   = #Font_Normal
                  Words()\Index  = ListIndex(MarkDown()\GlossaryWord())
                  Words()\Flag   = #Glossary
                EndIf
                
                MarkDown()\GlossaryWord()\Word = Words()\String

              EndIf
              
            EndIf 
          
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf  
            ;}
          ElseIf Mid(Row, Pos, 2) = "[>" 
            ;{ ___ Visible Keyword ___
            ePos = FindString(Row, "]", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              String$ = Mid(Row, Pos + 2, ePos - Pos - 2)
              
              If AddElement(MarkDown()\Keyword(String$)\HeadingID())
                
                If AddElement(Words())
                  Words()\String = String$
                  Words()\Font   = #Font_Normal
                  Words()\Index  = ListIndex(MarkDown()\Keyword(String$)\HeadingID())
                  Words()\Flag   = #Keyword
                EndIf
                
                MarkDown()\Keyword(String$)\HeadingID() = LastHeading
              EndIf
              
            EndIf
            
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf  
            ;}
          ElseIf Mid(Row, Pos, 2) = "[<"  
            ;{ ___ Invisible Keyword ___
            ePos = FindString(Row, "]", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              String$ = Mid(Row, Pos + 2, ePos - Pos - 2)
              If AddElement(MarkDown()\Keyword(String$)\HeadingID())
                MarkDown()\Keyword(String$)\HeadingID() = LastHeading
              EndIf
              
            EndIf
            
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf  
            ;}  
          ElseIf Mid(Row, Pos, 2) = "[["
            ;{ ___ Keystroke ___
            ePos = FindString(Row, "]]", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(Words())
                Words()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                Words()\Font   = #Font_Bold
                Words()\Flag   = #Keystroke
                ePos + 1
              EndIf
            EndIf  
            
            If ePos : Pos = ePos + 1 : sPos = Pos : EndIf   
            ;}
          Else  
            ;{ ___ Links  ___                     [6.5]
            ePos = FindString(Row, "][", Pos + 1)
            If ePos
              ;{ Reference link
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(MarkDown()\Link())
                
                If AddElement(Words())
                  Words()\String = Trim(Mid(Row, Pos + 1, ePos - Pos - 1))
                  Words()\Font   = #Font_Normal
                  Words()\Index  = ListIndex(MarkDown()\Link())
                  Words()\Flag   = #Link 
                EndIf
                
                MarkDown()\Link()\String = Words()\String
                
                nPos = ePos + 2
                
                ePos = FindString(Row, "]", nPos)
                If ePos
                  MarkDown()\Link()\Label = Trim(Mid(Row, nPos + 1, ePos - nPos - 1))
                EndIf
                
              EndIf
              
              If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
              ;}
            Else
              ;{ Inline link
              ePos = FindString(Row, "](", Pos + 1)
              If ePos
                
                FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                
                If AddElement(MarkDown()\Link())
                  
                  If AddElement(Words())
                    Words()\String = Trim(Mid(Row, Pos + 1, ePos - Pos - 1))
                    Words()\Font   = #Font_Normal
                    Words()\Index  = ListIndex(MarkDown()\Link())
                    Words()\Flag   = #Link 
                  EndIf
                  
                  MarkDown()\Link()\String = Words()\String
                  
                  nPos = ePos + 2
                  
                  ePos = FindString(Row, ")", nPos)
                  If ePos

                    ;{ Destination
                    String$ = Trim(Mid(Row, nPos, ePos - nPos))
                    If Left(String$, 1) = "<"
                      nPos = FindString(String$, ">", 2)
                      If nPos
                        MarkDown()\Link()\URL = Trim(Mid(String$, 2, nPos - 1))
                        String$ = Trim(Mid(String$, nPos + 1))
                      EndIf 
                    Else
                      MarkDown()\Link()\URL = Trim(StringField(String$, 1, " "))
                      String$ = Trim(Mid(String$, Len(MarkDown()\Link()\URL) + 1))
                    EndIf ;}
                    
                    ;{ Title
                    If String$
                      Select Left(String$, 1)
                        Case #DQUOTE$
                          nPos = FindString(String$, #DQUOTE$, 2)  
                        Case "'" 
                          nPos = FindString(String$, "'", 2)
                      EndSelect
                      If nPos
                        MarkDown()\Link()\Title = Trim(Mid(String$, 2, nPos - 2))
                      EndIf 
                    EndIf ;}
                  
                  EndIf
                  
                EndIf

              EndIf
              
              If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
              ;}
            EndIf  
            ;}
          EndIf 
          ;}
        Case "<"
          ;{ ___ Autolinks ___                    [6.7] 
          ePos = FindString(Row, ">", Pos + 1)
          If ePos
          
            FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
            
            If AddElement(MarkDown()\Link())
              
              If AddElement(Words())
                Words()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                Words()\Font   = #Font_Normal
                Words()\Index  = ListIndex(MarkDown()\Link())
                Words()\Flag   = #AutoLink 
              EndIf
              
              MarkDown()\Link()\URL    = Words()\String
              MarkDown()\Link()\String = Words()\String
              
            EndIf

            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
          EndIf  
          ;}
        Case "~" 
          ;{ ___ Strikethrough / Subscript ___
          If Mid(Row, Pos, 2) = "~~" ;{ Strikethrough
            
            ePos = FindString(Row, "~~", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())

              If AddWords_(Mid(Row, Pos + 2, ePos - Pos - 2), Words(), #Font_Normal, #StrikeThrough)
                ePos + 1
              EndIf
              
            EndIf
            ;}
          Else                        ;{ Subscript 
            
            ePos = FindString(Row, "~", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(Words())
                Words()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                Words()\Font   = #Font_FootNote
                Words()\Flag   = #Subscript 
              EndIf
              
            EndIf
            ;}
          EndIf 
          
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
          ;}
        Case "^"
          ;{ ___ Superscript ___
          ePos = FindString(Row, "^", Pos + 1)
          If ePos
            
            FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
            
            If AddElement(Words())
              Words()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
              Words()\Font   = #Font_FootNote
              Words()\Flag   = #Superscript 
            EndIf
            
          EndIf
          
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
          ;}
        Case "="
          ;{ ___ Highlight ___
          If Mid(Row, Pos, 2) = "=="
            
            ePos = FindString(Row, "==", Pos + 2)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())

              If AddWords_(Mid(Row, Pos + 2, ePos - Pos - 2), Words(), #Font_Normal, #Highlight)
                ePos + 1
              EndIf
              
            EndIf
            
          EndIf
          
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf
          ;}
        Case "+"
          ;{ ___ Underline ___
          If Mid(Row, Pos, 2) = "++"
            
            ePos = FindString(Row, "++", Pos + 2)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())

              If AddWords_(Mid(Row, Pos + 2, ePos - Pos - 2), Words(), #Font_Normal, #Underline)
                ePos + 1
              EndIf
              
            EndIf
            
          EndIf
          
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf
          ;}  
        CompilerIf #Enable_Emoji  
          Case ":"  
            ;{ ___ Emoji ___
            ePos = Emoji_(Row, Pos)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(Words())
                Words()\String = Mid(Row, Pos, ePos - Pos + 1)
                Words()\Font   = #PB_Default
                Words()\Flag   = #Emoji 
              EndIf
  
            EndIf
            
            If ePos : Pos = ePos : sPos = Pos + 1 : EndIf
            ;}
        CompilerEndIf  
 
      EndSelect
      
      Pos + 1
    Until Pos > Length  
    
    AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
    
  EndProcedure
  
  Procedure   Parse_(Text.s)
    ; -------------------------------------------------------------------------
    ; <https://spec.commonmark.org> - Version 0.29 (2019-04-06) John MacFarlane
    ; -------------------------------------------------------------------------
    Define.i r, Rows, Pos, sPos, ePos, nPos, Length, Left, Right
    Define.i NewLine, Type,  BlockQuote, StartNum, Indent, Counter
    Define.i c, Column, Cols, ListIdx, ColSpan 
    Define.s Row$, tRow$, String$, Char$, Start$, Close$, Label$, Col$, Num$, LastID$
    Define   Lists.List_Structure
    
    NewList Sort.s()
    
    If Text = "" : ProcedureReturn #False : EndIf 
    
    Text = ReplaceString(Text, #CRLF$, #LF$)
    Text = ReplaceString(Text, #CR$, #LF$)
    
    Rows = CountString(Text, #LF$) + 1
    
    ;{ ===== Phase 1 =====
    ClearList(Document())
    
    For r = 1 To Rows
      
      Row$  = ReplaceString(StringField(Text, r, #LF$), #TAB$, Space(4))
      tRow$ = LTrim(Row$)

      Select Type
        Case #Code ;{ Add to codeblock
          
          If Left(tRow$, 4) = Space(4)
            AddDocRow_(Row$, #Code)
            Continue
          Else
            If Trim(Row$) = Close$
              Type = #False
              Continue
            Else
              AddDocRow_(Row$, #Code)
              Continue
            EndIf
          EndIf ;}
        Case #Note ;{ Add to note block  
          If Trim(Row$) = Close$
            Type = #False
            Continue
          Else
            AddDocRow_(Row$, #Note)
            Continue
          EndIf
          ;}
      EndSelect    
      
      ;{ _____ BlockQuotes _____            [5.1]
      If Left(Row$, 4) <> Space(4)
        If Left(tRow$, 2) = ">>"
          Pos  = FindString(Row$, ">>")
          Row$ = LTrim(Mid(Row$, Pos + 2))
          tRow$ = LTrim(Row$)
          BlockQuote = 2
        ElseIf Left(tRow$, 1) = ">" 
          Pos  = FindString(Row$, ">")
          Row$ = LTrim(Mid(Row$, Pos + 1))
          tRow$ = LTrim(Row$)
          BlockQuote = 1
        Else
          BlockQuote = #False
        EndIf
      EndIf   
      ;}

      ;{ _____ Task Lists _____
      Select Left(tRow$, 5)
        Case "- [ ]", "+ [ ]", "* [ ]", "- [X]", "+ [X]", "* [X]", "- [x]", "+ [x]", "* [x]"
          
          Pos    = FindString(Row$, Left(tRow$, 2))
          Indent = Pos + 1
          
          If Lists\Indent = 0 : Lists\Indent = Indent : EndIf
          
          If ListLevelDoc_(Pos, Indent, @Lists) 
            Lists\Marker = Left(tRow$, 2)
            Lists\Indent = Indent
          Else
            Lists\Marker = ""
            Lists\Indent = 0
          EndIf
          
        Default
          
          If Lists\Indent And Type = #TaskList And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect
      
      If Lists\Marker
        
        If AddElement(Document()) 
          
          Document()\Type = #TaskList
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(2 * Document()\Level) + tRow$

          Document()\Marker     = Left(Lists\Marker, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #TaskList
          
          Continue
        EndIf 

      EndIf  
      ;}
      
      ;{ _____ Unordered Lists _____        [5.3]
      Select Left(tRow$, 2)
        Case "- ", "+ ", "* "

          Pos    = FindString(Row$, Left(tRow$, 2))
          Indent = Pos + 1
          
          If Lists\Indent = 0 : Lists\Indent = Indent : EndIf
          
          If ListLevelDoc_(Pos, Indent, @Lists) 
            Lists\Marker = Left(tRow$, 2)
            Lists\Indent = Indent
          Else
            Lists\Marker = ""
            Lists\Indent = 0
          EndIf 
          
        Default
          
          If Lists\Indent And Type = #UnorderedList And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect
      
      If Lists\Marker
        
        If AddElement(Document()) 
          
          Document()\Type = #UnorderedList
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(2 * Document()\Level) + tRow$

          Document()\Marker     = Left(Lists\Marker, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #UnorderedList
          
          Continue
        EndIf 
        
      EndIf  
      ;}
      
      ;{ _____ Ordered Lists _____          [5.3]
      Select Left(tRow$, 3)
        Case "1. ", "2. ", "3. ", "4. ",  "5. ", "6. ", "7. ", "8. ", "9. ", "0. "
          
          Pos    = FindString(Row$, Left(tRow$, 3))
          Indent = Pos + 2
          
          If Lists\Indent = 0 : Lists\Indent = Indent : EndIf

          If ListLevelDoc_(Pos, Indent, @Lists) 
            Lists\Marker = Left(tRow$, 2)
            Lists\Indent = Indent
          Else
            Lists\Marker = ""
            Lists\Indent = 0
          EndIf 

        Case "1) ", "2) ", "3) ", "4) ",  "5) ", "6) ", "7) ", "8) ", "9) ", "0) "
          
          Pos    = FindString(Row$, Left(tRow$, 3))
          Indent = Pos + 2
          
          If Lists\Indent = 0 : Lists\Indent = Indent : EndIf
          
          If ListLevelDoc_(Pos, Indent, @Lists) 
            Lists\Marker = Left(tRow$, 2)
            Lists\Indent = Indent
          Else
            Lists\Marker = ""
            Lists\Indent = 0
          EndIf
          
        Default
          
          If Lists\Indent And Type = #OrderedList And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect    
    
      If Lists\Marker
        
        If AddElement(Document())
          
          Document()\Type = #OrderedList
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(3 * Document()\Level) + tRow$
          
          Document()\Marker = Mid(Lists\Marker, 2, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #OrderedList
          
          Continue
        EndIf 
        
      EndIf  
      ;}
      
      ;{ _____ Definition Lists _____
      Select Left(tRow$, 2)
        Case ": "
        
          Pos    = FindString(Row$, Left(tRow$, 2))
          Indent = Pos + 1
          
          If Lists\Indent = 0 : Lists\Indent = Indent : EndIf
          
          If ListLevelDoc_(Pos, Indent, @Lists) 
            Lists\Marker = Left(tRow$, 2)
            Lists\Indent = Indent
          Else
            Lists\Marker = ""
            Lists\Indent = 0
          EndIf
          
        Default
          
          If Lists\Indent And Type = #DefinitionList And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect 
      
      If Lists\Marker
        
        If AddElement(Document()) 
          
          Document()\Type = #DefinitionList
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(2 * Document()\Level) + tRow$
  
          Document()\Marker     = Left(Lists\Marker, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #DefinitionList
          
          Continue
        EndIf
        
      EndIf
      ;}
      
      Lists\Marker = ""
      Lists\Indent = 0
      
      If Left(Row$, 4) = Space(4)
        
        ;{ _____ Indented code blocks _____ [4.4]
        If AddDocRow_(Mid(Row$, 5), #Block) : Continue : EndIf
        
      ElseIf Left(Row$, 1) = #TAB$
        
        If AddDocRow_(Mid(Row$, 2), #Block) : Continue : EndIf ;}
        
      Else

        ;{ _____ Setext headings _____      [4.3]
        If ListSize(Document()) And Trim(Document()\String) And Document()\Type = #Parse And Not NewLine 

          If Left(tRow$, 1) = "=" And CountString(Trim(Row$), "=") = Len(Trim(Row$))
            
            Document()\Type   = #Heading
            Document()\String = "# " + Trim(Document()\String)
            
            Continue
          ElseIf Left(tRow$, 2) = "--" And CountString(Trim(Row$), "-") = Len(Trim(Row$))
            
            Document()\Type   = #Heading
            Document()\String = "## " + Trim(Document()\String)

            Continue
          EndIf
          
        EndIf ;}
        
        ;{ _____ ATX headings _____         [4.2]
        If Left(tRow$, 7) = "###### "
          If AddDocRow_(tRow$, #Heading)
            Document()\String = RTrim(Trim(Document()\String), "#")
            Continue
          EndIf 
        ElseIf Left(tRow$, 6) = "##### "
          If AddDocRow_(tRow$, #Heading)
            Document()\String = RTrim(Trim(Document()\String), "#")
            Continue
          EndIf 
        ElseIf Left(tRow$, 5) = "#### "
          If AddDocRow_(tRow$, #Heading)
            Document()\String = RTrim(Trim(Document()\String), "#")
            Continue
          EndIf 
        ElseIf Left(tRow$, 4) = "### "
          If AddDocRow_(tRow$, #Heading)
            Document()\String = RTrim(Trim(Document()\String), "#")
            Continue
          EndIf 
        ElseIf Left(tRow$, 3) = "## "
          If AddDocRow_(tRow$, #Heading)
            Document()\String = RTrim(Trim(Document()\String), "#")
            Continue
          EndIf 
        ElseIf Left(tRow$, 2) = "# "
          If AddDocRow_(tRow$, #Heading)
            Document()\String = RTrim(Trim(Document()\String), "#")
            Continue
          EndIf 
        Else ;{ Empty heading
          
          Select Trim(tRow$)
            Case "######"
              If AddDocRow_(Trim(tRow$), #Heading) : Continue : EndIf 
            Case "#####"
              If AddDocRow_(Trim(tRow$), #Heading) : Continue : EndIf 
            Case "####"
              If AddDocRow_(Trim(tRow$), #Heading) : Continue : EndIf 
            Case "###"
              If AddDocRow_(Trim(tRow$), #Heading) : Continue : EndIf 
            Case "##"
              If AddDocRow_(Trim(tRow$), #Heading) : Continue : EndIf 
            Case "#"
              If AddDocRow_(Trim(tRow$), #Heading) : Continue : EndIf 
          EndSelect
          ;}
        EndIf ;}
        
        ;{ _____ Thematic breaks _____      [4.1]
        Select Left(RemoveString(tRow$, " "), 3) 
          Case "---", "***", "___"
            If AddDocRow_(tRow$, #Line) : Continue : EndIf 
        EndSelect ;}        
        
        ;{ _____ Paragraphs _____           [4.8]
        If Trim(tRow$) = "" And (ListIndex(Document()) = -1 Or Document()\String)
          If AddDocRow_("", #Paragraph) : Continue : EndIf 
        EndIf ;} 
        
        ;{ _____ Fenced code blocks _____   [4.5]
        Select Left(tRow$, 3)
          Case "```"
            Close$ = GetChars_(tRow$, "`")
            If AddDocRow_(Mid(tRow$, Len(Close$) + 1), #CodeHeader) : Type = #Code : EndIf
            Continue
          Case "~~~" 
            Close$ = GetChars_(tRow$, "~")
            If AddDocRow_(Mid(tRow$, Len(Close$) + 1), #CodeHeader) : Type = #Code : EndIf
            Continue
        EndSelect
        ;}
        
        ;{ _____ Note _____
        If Left(tRow$, 3) = "!!!"
          Close$ = GetChars_(tRow$, "!")
          If AddDocRow_(Trim(Mid(tRow$, Len(Close$) + 1)), #NoteHeader) : Type = #Note : EndIf
          Continue
        EndIf  
        ;}
        
        ;{ _____ Tables _____
        If Left(tRow$, 2) = "| " Or Left(tRow$, 2) = "||"
          AddDocRow_(Trim(tRow$), #Table)
          Continue  
        EndIf     
        ;}
        
        ;{ _____ Image _____                [6.6]
        If Left(tRow$, 2) = "!["
          
          ePos = FindString(tRow$, "][", Pos + 1)
          If ePos
            ;{ Reference link
            If Right(Trim(Row$), 1) = "]"
              AddDocRow_(Trim(Row$), #Image)
              Continue
            EndIf  
            ;}
          Else
            ;{ Inline link
            ePos = FindString(tRow$, "](", Pos + 1)
            If ePos
              If Right(Trim(Row$), 1) = ")"
                AddDocRow_(Trim(Row$), #Image)
                Continue
              EndIf
            EndIf
            ;}
          EndIf
          
        EndIf   
        ;}
        
        ;{ _____ Abbreviation _____
        If Left(tRow$, 2) = "*["
          
          ePos = FindString(tRow$, "]:", 3)
          If ePos
            
            Label$ = Mid(tRow$, 3, ePos - 3)
            If Label$
              
              If AddMapElement(MarkDown()\Abbreviation(), Label$)
                MarkDown()\Abbreviation()\String = Trim(Mid(Row$, ePos + 2))
              EndIf
              
              Continue
            EndIf
            
          EndIf 
          
        EndIf
        ;}
        
        ;{ _____ Footnote reference definitions _____
        If Left(tRow$, 2) = "[^"
          
          ePos = FindString(tRow$, "]:", 3)
          If ePos
            
            Label$ = Mid(tRow$, 3, ePos - 3)
            If Label$
              
              If AddMapElement(MarkDown()\FootLabel(), Label$)
                ParseInline_(Trim(Mid(Row$, ePos + 2)), MarkDown()\FootLabel()\Words(), LastID$)
              EndIf 
              
              ForEach MarkDown()\FootLabel()\Words()
                
                Select MarkDown()\FootLabel()\Words()\Font
                  Case #Font_Bold
                    MarkDown()\FootLabel()\Words()\Font = #Font_FootBold
                  Case #Font_Italic
                    MarkDown()\FootLabel()\Words()\Font = #Font_FootItalic
                  Case #Font_BoldItalic
                    MarkDown()\FootLabel()\Words()\Font = #Font_FootBoldItalic
                  Default
                    MarkDown()\FootLabel()\Words()\Font = #Font_FootText
                EndSelect
                
              Next  
              
              Continue
            EndIf
            
          EndIf 
          
        EndIf
        ;}
        
        ;{ _____ Glossary reference definitions _____
        If Left(tRow$, 2) = "[?"
          
          ePos = FindString(tRow$, "]:", 3)
          If ePos
            
            Label$ = Mid(tRow$, 3, ePos - 3)
            If Label$
              If AddMapElement(MarkDown()\Glossary(), Label$)
                ParseInline_(Trim(Mid(Row$, ePos + 2)), MarkDown()\Glossary()\Words(), LastID$)
              EndIf 
              Continue
            EndIf
            
          EndIf 
          
        EndIf
        ;}
        
        ;{ _____ Glossary _____
        If Left(tRow$, 12) = "{{Glossary}}"
          If AddElement(Document())
            Document()\Type = #InsertGlossary
            Continue
          EndIf
        EndIf  
        ;}
        
        ;{ _____ Keywords _____
        If Left(tRow$, 12) = "{{Keywords}}"
          If AddElement(Document())
            Document()\Type = #InsertKeywords
            Continue
          EndIf
        EndIf  
        ;}
        
        ;{ _____ TOC _____
        If Left(tRow$, 7) = "{{TOC}}"
          If AddElement(Document())
            Document()\Type = #InsertTOC
            Continue
          EndIf
        EndIf  
        ;}
        
        ;{ _____ Default _____
        If ListSize(Document()) = 0 Or Document()\Type <> #Parse Or NewLine
          If AddElement(Document())
            Document()\Type = #Parse
            Document()\BlockQuote = BlockQuote
          EndIf 
        EndIf
        
        If NewLine
          Document()\String + " " + LTrim(Row$)
        Else
          Document()\String + " " + Row$
        EndIf  
        
        If Right(tRow$, 2) = Space(2) Or Right(tRow$, 1) = "\"
          NewLine = #True
        Else
          NewLine = #False
        EndIf
        ;}
        
      EndIf
      
    Next ;}

    ;{ ===== Phase 2 =====
    ClearList(MarkDown()\Items())
    
    ForEach Document()
      
      Select Document()\Type
        ;{ _____ Thematic breaks _____            [4.1]  
        Case #Line
 
          If AddElement(MarkDown()\Items())
            MarkDown()\Items()\Type = #Line
          EndIf
          ;}
        ;{ _____ ATX headings _____               [4.2]
        Case #Heading
          
          String$ = Trim(Document()\String)
          
          If AddElement(MarkDown()\Items())
            
            MarkDown()\Items()\Type = #Heading
            MarkDown()\Items()\BlockQuote = Document()\BlockQuote
            
            Pos = FindString(String$, "{")
            If Pos
              ePos = FindString(String$, "}")
              If ePos
                MarkDown()\Items()\ID = "HDG:" + Mid(String$, Pos + 1, ePos - Pos - 1)
                String$ = Left(String$, Pos - 1)
              EndIf  
            EndIf  
            
            Select CountString(Left(String$, 6), "#")
              Case 1
                MarkDown()\Items()\Level = 1
                AddWords_(Trim(LTrim(String$, "#")), MarkDown()\Items()\Words(), #Font_H1)
              Case 2
                MarkDown()\Items()\Level = 2
                AddWords_(Trim(LTrim(String$, "#")), MarkDown()\Items()\Words(), #Font_H2)
              Case 3
                MarkDown()\Items()\Level = 3
                AddWords_(Trim(LTrim(String$, "#")), MarkDown()\Items()\Words(), #Font_H3)
              Case 4
                MarkDown()\Items()\Level = 4
                AddWords_(Trim(LTrim(String$, "#")), MarkDown()\Items()\Words(), #Font_H4)
              Case 5
                MarkDown()\Items()\Level = 5
                AddWords_(Trim(LTrim(String$, "#")), MarkDown()\Items()\Words(), #Font_H5)
              Case 6
                MarkDown()\Items()\Level = 6
                AddWords_(Trim(LTrim(String$, "#")), MarkDown()\Items()\Words(), #Font_H6)
            EndSelect
            
            If MarkDown()\Items()\ID = ""
              Counter + 1
              MarkDown()\Items()\ID = "HDG:" + RSet(Str(Counter), 3, "0")
            EndIf 
            
            If LCase(MarkDown()\Items()\ID) = "ignore"
              MarkDown()\Items()\ID = ""
            Else  
              If AddElement(MarkDown()\TOC())
                MarkDown()\TOC()\Level = MarkDown()\Items()\Level
                MarkDown()\TOC()\ID    = MarkDown()\Items()\ID
                CopyList(MarkDown()\Items()\Words(), MarkDown()\TOC()\Words())
                ForEach MarkDown()\TOC()\Words()
                  MarkDown()\TOC()\Words()\Flag = #InsertTOC
                  MarkDown()\TOC()\Words()\Font = #Font_Normal 
                Next
              EndIf
              LastID$ = MarkDown()\Items()\ID
            EndIf  
            
          EndIf
          ;}
        ;{ _____ Paragraphs _____                 [4.8]  
        Case #Paragraph
          ; TODO: Remove initial and final whitespace.
          If AddElement(MarkDown()\Items())
            MarkDown()\Items()\Type = #Paragraph
          EndIf
          ;}
        ;{ _____ Lists _____                      [5.3]
        Case #OrderedList    ;{ Ordered List
          
          If AddItemByType_(#OrderedList, Document()\BlockQuote) ;{ New list

            If AddElement(MarkDown()\Lists())
              MarkDown()\Items()\Index = ListIndex(MarkDown()\Lists())
              MarkDown()\Lists()\Start = Val(Left(LTrim(Document()\String), 1))
            EndIf
            ;}
          EndIf
          
          If ListSize(MarkDown()\Lists())
            
            If AddElement(MarkDown()\Lists()\Row())
              
              MarkDown()\Lists()\Row()\Level      = Document()\Level
              MarkDown()\Lists()\Row()\BlockQuote = Document()\BlockQuote
              
              If Document()\BlockQuote > MarkDown()\Items()\BlockQuote : MarkDown()\Items()\BlockQuote = Document()\BlockQuote : EndIf
              
              String$ = Trim(Mid(LTrim(Document()\String), 4)) ; '1. ' or '1) '
              ParseInline_(String$, MarkDown()\Lists()\Row()\Words(), LastID$)
              
            EndIf
            
          EndIf
          ;}
        Case #UnorderedList  ;{ Unordered List
          
          If AddItemByType_(#UnorderedList, Document()\BlockQuote)
            
            If AddElement(MarkDown()\Lists())
              MarkDown()\Items()\Index = ListIndex(MarkDown()\Lists())
            EndIf
            
          EndIf
          
          If ListSize(MarkDown()\Lists())
            
            If AddElement(MarkDown()\Lists()\Row())
              
              MarkDown()\Lists()\Row()\Level      = Document()\Level
              MarkDown()\Lists()\Row()\BlockQuote = Document()\BlockQuote
              
              If Document()\BlockQuote > MarkDown()\Items()\BlockQuote : MarkDown()\Items()\BlockQuote = Document()\BlockQuote : EndIf
              
              String$ = Trim(Mid(LTrim(Document()\String), 3)) ; '- ' or '+ ' or '* '
              ParseInline_(String$, MarkDown()\Lists()\Row()\Words(), LastID$)
              
            EndIf 
            
          EndIf
          ;}
        Case #DefinitionList ;{ Definition List
          
          If MarkDown()\Items()\Type = #Text
            
            MarkDown()\Items()\Type = #DefinitionList
            
            ForEach MarkDown()\Items()\Words()
              MarkDown()\Items()\Words()\Font = #Font_Bold
            Next
            
            If AddElement(MarkDown()\Lists())
              MarkDown()\Items()\Index = ListIndex(MarkDown()\Lists())
            EndIf
            
          EndIf
          
          If ListSize(MarkDown()\Lists())
            
            If AddElement(MarkDown()\Lists()\Row())
              
              MarkDown()\Lists()\Row()\Level      = Document()\Level
              MarkDown()\Lists()\Row()\BlockQuote = Document()\BlockQuote
              
              If Document()\BlockQuote > MarkDown()\Items()\BlockQuote : MarkDown()\Items()\BlockQuote = Document()\BlockQuote : EndIf
              
              String$ = Trim(Mid(LTrim(Document()\String), 3)) ; ': '
              ParseInline_(String$, MarkDown()\Lists()\Row()\Words(), LastID$)
              
            EndIf
            
          EndIf
          ;}
        Case #TaskList       ;{ Task List
          
          If AddItemByType_(#TaskList, Document()\BlockQuote)
            
            If AddElement(MarkDown()\Lists())
              MarkDown()\Items()\Index = ListIndex(MarkDown()\Lists())
            EndIf
            
          EndIf
          
          If ListSize(MarkDown()\Lists())
          
            If AddElement(MarkDown()\Lists()\Row())
              
              MarkDown()\Lists()\Row()\Level      = Document()\Level
              MarkDown()\Lists()\Row()\BlockQuote = Document()\BlockQuote
              
              If Document()\BlockQuote > MarkDown()\Items()\BlockQuote : MarkDown()\Items()\BlockQuote = Document()\BlockQuote : EndIf
              
              String$ = Trim(Mid(LTrim(Document()\String), 3)) ; '- ' or '+ ' or '* '
              Select Left(String$, 3)
                Case "[ ]", "[] "
                  MarkDown()\Lists()\Row()\State = #False
                Case "[X]", "[x]"
                  MarkDown()\Lists()\Row()\State = #True
              EndSelect
              
              nPos = FindString(String$, "]", 2)
              If nPos
                String$ = Mid(String$, nPos + 1)
                ParseInline_(String$, MarkDown()\Lists()\Row()\Words(), LastID$)
              EndIf
              
            EndIf 
          
          EndIf
          ;}
        ;}  
        ;{ _____ Intended Code Blocks _____       [4.4]
        Case #Block
          If AddElement(MarkDown()\Items())
            MarkDown()\Items()\Type = #Block
            MarkDown()\Items()\BlockQuote = Document()\BlockQuote
            AddWords_(Document()\String, MarkDown()\Items()\Words(), #Font_Code, #Code)
          EndIf  
          ;}
        ;{ _____ Fenced Code blocks _____         [4.5]
        Case #CodeHeader
          
          If AddElement(MarkDown()\Items())
            
            MarkDown()\Items()\Type = #Code
            MarkDown()\Items()\BlockQuote = Document()\BlockQuote
            
            If AddElement(MarkDown()\Block())
              MarkDown()\Items()\Index  = ListIndex(MarkDown()\Block())
              MarkDown()\Block()\Font   = #Font_Code
              MarkDown()\Block()\String = Document()\String
            EndIf  
            
          EndIf
          
        Case #Code 
          
          If ListSize(MarkDown()\Block())
            If AddElement(MarkDown()\Block()\Row())
              MarkDown()\Block()\Row() = Document()\String
            EndIf  
          EndIf  
          ;} 
        ;{ _____ Note _____
        Case #NoteHeader
          
          If AddElement(MarkDown()\Items())
            
            MarkDown()\Items()\Type = #Note
            MarkDown()\Items()\BlockQuote = Document()\BlockQuote
            
            If AddElement(MarkDown()\Note())
              
              MarkDown()\Items()\Index  = ListIndex(MarkDown()\Note())
              
              MarkDown()\Note()\Type = LCase(StringField(Document()\String, 1, " "))
              
              Pos = FindString(Document()\String, " ")
              If Pos
                ParseInline_(Trim(Mid(Document()\String, Pos + 1)), MarkDown()\Items()\Words(), LastID$)
              EndIf
            EndIf
            
          EndIf
          
        Case #Note
          
          If ListSize(MarkDown()\Note())
            If AddElement(MarkDown()\Note()\Row())
              ParseInline_(Document()\String, MarkDown()\Note()\Row()\Words(), LastID$)
            EndIf  
          EndIf 
          ;}  
        ;{ _____ Image _____                      [6.6]
        Case #Image  
          
          If AddElement(MarkDown()\Items())
            
            MarkDown()\Items()\Type = #Image
            MarkDown()\Items()\BlockQuote = Document()\BlockQuote
            
            ePos = FindString(Document()\String, "][", 3)
            If ePos
              ;{ Reference link
              If AddElement(MarkDown()\Image())
                
                MarkDown()\Items()\Index = ListIndex(MarkDown()\Image())
                
                ParseInline_(Mid(Document()\String, 3, ePos - 3), MarkDown()\Items()\Words(), LastID$)

                MarkDown()\Image()\Label = RTrim(Mid(Document()\String, ePos + 2), "]")
                
              EndIf  
              ;}
            Else  
              ;{ Inline link
              ePos = FindString(Document()\String, "](", 3)
              If ePos
                
                If AddElement(MarkDown()\Image())
                  
                  MarkDown()\Items()\Index = ListIndex(MarkDown()\Image())
                  
                  ParseInline_(Mid(Document()\String, 3, ePos - 3), MarkDown()\Items()\Words(), LastID$)

                  String$ = Trim(RTrim(Mid(Document()\String, ePos + 2), ")"))
                  
                  ;{ Source 
                  If Left(String$, 1) = "<"
                    nPos = FindString(String$, ">", 2)
                    If nPos
                      MarkDown()\Image()\Source = AdjustImagePath(Trim(Mid(String$, 2, nPos - 1), #DQUOTE$))
                      String$ = Trim(Mid(String$, nPos + 1))
                    EndIf 
                  Else
                    MarkDown()\Image()\Source = AdjustImagePath(Trim(StringField(String$, 1, " "), #DQUOTE$))
                    String$ = Trim(Mid(String$, Len(MarkDown()\Image()\Source) + 1))
                  EndIf ;}
                  
                  ;{ Title
                  If String$
                    Select Left(String$, 1)
                      Case #DQUOTE$
                        nPos = FindString(String$, #DQUOTE$, 2)  
                      Case "'" 
                        nPos = FindString(String$, "'", 2)
                    EndSelect
                    If nPos
                      MarkDown()\Image()\Title = Mid(String$, 2, nPos - 2)
                    EndIf 
                  EndIf ;}
   
                EndIf
                
              EndIf
              ;}
            EndIf
            
          EndIf ;}  
        ;{ _____ Tables _____
        Case #Table
          
          If AddItemByType_(#Table, Document()\BlockQuote) ;{ New Table

            If AddElement(MarkDown()\Table())
              MarkDown()\Items()\Index = ListIndex(MarkDown()\Table())
            EndIf
            ;}
          EndIf
          
          String$ = Trim(Document()\String)
          If Left(String$, 1)  = "|" : String$ = Mid(String$, 2) : EndIf 
          If Right(String$, 1) = "|" : String$ = Left(String$, Len(String$) - 1) : EndIf 
          
          If ListSize(MarkDown()\Table())
            
            Cols = CountString(String$, "|") + 1
            ColSpan = 0
            
            If Left(Trim(String$), 2) = "--" Or Left(Trim(String$), 3) = ":--" ;{ Header 
              
              If FirstElement(MarkDown()\Table()\Row())
                
                MarkDown()\Table()\Row()\Type = #TableHeader
                
                ForEach MarkDown()\Table()\Row()\Col() ;{ Change Font
                  
                  ForEach MarkDown()\Table()\Row()\Col()\Words()
                    MarkDown()\Table()\Row()\Col()\Words()\Font = #Font_Bold
                  Next
                  ;}
                Next  
                
                For c=1 To Cols
                  Num$ = Str(c)
                  Col$ = Trim(StringField(String$, c, "|"))
                  If Left(Col$, 1) = ":" And Right(Col$, 1) = ":"
                    MarkDown()\Table()\Column(Num$)\Align = "C"
                  ElseIf Right(Col$, 1) = ":"
                    MarkDown()\Table()\Column(Num$)\Align = "R"
                  Else
                    MarkDown()\Table()\Column(Num$)\Align = "L"
                  EndIf
                Next
                
                LastElement(MarkDown()\Table()\Row())
              EndIf
              ;}
            Else                                                               ;{ Table row

              If AddElement(MarkDown()\Table()\Row())
                
                MarkDown()\Table()\Row()\Type = #Table
                
                For c=1 To Cols
                  Col$ = StringField(String$, c, "|")
                  If Col$ = ""
                    If c=1
                      ColSpan = CountSpan_(String$, 1) + 1
                      MarkDown()\Table()\Row()\Col(Str(ColSpan))\Span = 1
                    Else  
                      MarkDown()\Table()\Row()\Col(Num$)\Span + 1
                    EndIf  
                    Continue
                  Else
                    Num$ = Str(c)
                    MarkDown()\Table()\Row()\Col(Num$)\Span + 1
                  EndIf
                  
                  If Trim(Col$) = ""
                    Col$ = " "
                  Else
                    Col$ = Trim(Col$)
                  EndIf
                  
                  ParseInline_(Col$, MarkDown()\Table()\Row()\Col(Num$)\Words(), LastID$)
                Next
                
              EndIf 
              ;}
            EndIf  
            
            If MarkDown()\Table()\Cols < Cols : MarkDown()\Table()\Cols = Cols : EndIf
            
          EndIf
          ;}
        ;{ _____ TOC _____
        Case #InsertTOC
          If AddElement(MarkDown()\Items())
            MarkDown()\Items()\Type = #InsertTOC
          EndIf
         ;}
        ;{ _____ Glossary _____
        Case #InsertGlossary
          If AddElement(MarkDown()\Items())
            MarkDown()\Items()\Type = #InsertGlossary
          EndIf
         ;}
        Default
          Row$ = Document()\String
          ;{ _____ Link reference definitions _____ [4.7] 
          tRow$ = LTrim(Document()\String)

          If Left(tRow$, 1) = "["
            
            Pos = FindString(tRow$, "]:", 2)
            If Pos
              
              Label$ = Mid(tRow$, 2, Pos - 2)
              If Label$
                
                If AddMapElement(MarkDown()\Label(), Label$)
                  
                  String$ = Trim(Mid(tRow$, ePos + 1))
                  
                  MarkDown()\Label()\Destination = Trim(StringField(String$, 1, " "))
                  
                  String$ = Trim(StringField(String$, 2, " "))
                  If CountString(String$, #DQUOTE$) = 2
                    MarkDown()\Label()\Title = Trim(Trim(String$, #DQUOTE$))
                  ElseIf CountString(StringField(String$, 2, " "), "'") = 2
                    MarkDown()\Label()\Title = Trim(Trim(String$, "'"))
                  EndIf

                  Continue
                EndIf
                
              EndIf
              
            EndIf
            
          EndIf
          ;}
          ;{ _____ Inlines _____                    [6] 
          Pos = 1 : sPos = 1
          Length = Len(Row$)
          
          ;{ Add new row
          If AddElement(MarkDown()\Items())
            MarkDown()\Items()\Type = #Text
            MarkDown()\Items()\BlockQuote = Document()\BlockQuote
          EndIf ;}
          
          ParseInline_(Row$, MarkDown()\Items()\Words(), LastID$)
          ;}
      EndSelect
      
    Next ;}
    
    ;{ ===== Phase 3 =====
    If MapSize(MarkDown()\Glossary())
      
      ;{ Sort Glossary
      ForEach MarkDown()\Glossary()
        If AddElement(Sort())
          Sort() = MapKey(MarkDown()\Glossary())
        EndIf  
      Next 
      SortList(Sort(), #PB_Sort_Ascending|#PB_Sort_NoCase)
      ;}
      
      ForEach MarkDown()\Items()

        If MarkDown()\Items()\Type = #InsertGlossary ;{ Insert Glossary
          
          MarkDown()\Items()\Type = #Glossary
          
          If AddElement(MarkDown()\Lists())
            
            MarkDown()\Items()\Index = ListIndex(MarkDown()\Lists())
            
            ForEach Sort()
              If FindMapElement(MarkDown()\Glossary(), Sort())
                If AddElement(MarkDown()\Lists()\Row())
                  MarkDown()\Lists()\Row()\String = MapKey(MarkDown()\Glossary())
                  CopyList(MarkDown()\Glossary()\Words(), MarkDown()\Lists()\Row()\Words())
                EndIf 
              EndIf
            Next
            
          EndIf  
          ;}
        EndIf  
        
      Next
      
    EndIf
    
    If MapSize(MarkDown()\Keyword())
      
      ForEach MarkDown()\Keyword()
        
        SortList(MarkDown()\Keyword()\HeadingID(), #PB_Sort_Ascending|#PB_Sort_NoCase)
        
        String$ = ""
        
        ForEach MarkDown()\Keyword()\HeadingID()
          If MarkDown()\Keyword()\HeadingID() = String$
            DeleteElement(MarkDown()\Keyword()\HeadingID())
          EndIf  
          String$ = MarkDown()\Keyword()\HeadingID()
        Next  
        
      Next
      
    EndIf  
    ;}
    
  EndProcedure  
  
	;- ============================================================================
	;-   Module - Tools
  ;- ============================================================================	
  
  Declare   Draw_(ScrollBar.i=#False)
  
  Procedure MergeHelp(List Items.Item_Structure(), List TOC.TOC_Structure(), Map Glossary.Glossary_Structure(), Map Keywords.Keywords_Structure(), List Links.Links_Structure())
    Define.i Result, Counter
    Define.s GNum$, Keyword$  

    ClearList(TOC())
    ClearList(Links())
    ClearMap(Glossary())
    ClearMap(Keywords())
    
    PushMapPosition(MarkDown())
    
    ForEach Items()
      
      If AddMapElement(MarkDown(), "Parse")
        
        Parse_(Items()\Text)
        
        If Items()\Label = ""
          Counter + 1
          Items()\Label = "Help" + RSet(Str(Counter), 3, "0")
        EndIf
        
        ForEach MarkDown()\TOC()       ;{ TOC
          
          If AddElement(TOC())
    	      TOC()\ID     = MarkDown()\TOC()\ID
    	      TOC()\Label  = Items()\Label
    	      TOC()\Level  = Items()\Level
    	      TOC()\X      = MarkDown()\TOC()\X
    	      TOC()\Y      = MarkDown()\TOC()\Y
    	      TOC()\Width  = MarkDown()\TOC()\Width
    	      TOC()\Height = MarkDown()\TOC()\Height
    	      CopyList(MarkDown()\TOC()\Words(), TOC()\Words())
    	      Break
    	    EndIf
    	    ;}
        Next
        
        ForEach MarkDown()\Glossary()  ;{ Glossary
        
          If AddMapElement(Glossary(), MapKey(MarkDown()\Glossary()))
    	      Glossary()\Label = Items()\Label
    	      CopyList(MarkDown()\Glossary()\Words(), Glossary()\Words())
    	    EndIf
    	    ;}
        Next
        
        ForEach MarkDown()\Keyword()   ;{ Keywords
          
          Keyword$ = MapKey(MarkDown()\Keyword())
          
          ForEach MarkDown()\Keyword()\HeadingID()
            If AddElement(Keywords(Keyword$)\Label())
              Keywords(Keyword$)\Label()\Name      = Items()\Label
              Keywords(Keyword$)\Label()\HeadingID = MarkDown()\Keyword()\HeadingID()
            EndIf  
          Next  
          ;}
        Next
        
        ForEach MarkDown()\Link()      ;{ Links

          If AddElement(Links())
            
            Links()\String = MarkDown()\Link()\String

            If MarkDown()\Link()\Label
              Links()\Destination = MarkDown()\Label(MarkDown()\Link()\Label)\Destination
            Else 
              Links()\Destination = MarkDown()\Link()\URL 
            EndIf  
            
            Links()\Label = Items()\Label
            
          EndIf
          ;}
        Next  
        
      EndIf
      
    Next
    
    PopMapPosition(MarkDown())
    
  EndProcedure

  Procedure UpdateHelp(GNum.i, List TOC.TOC_Structure(), Map Glossary.Glossary_Structure(), List Found.s(), Export.i=#False)
 
    NewList Sort.s() 
    
    PushMapPosition(MarkDown())
    
    If FindMapElement(MarkDown(), Str(GNum))
      
      CopyList(TOC(), MarkDown()\TOC())
      
      CopyMap(Glossary(), MarkDown()\Glossary())
      
      If MapSize(MarkDown()\Glossary())
      
        ;{ Sort Glossary
        ForEach MarkDown()\Glossary()
          If AddElement(Sort())
            Sort() = MapKey(MarkDown()\Glossary())
          EndIf  
        Next 
        SortList(Sort(), #PB_Sort_Ascending|#PB_Sort_NoCase)
        ;}
      
        ForEach MarkDown()\Items()
          If MarkDown()\Items()\Type = #InsertGlossary ;{ Insert Glossary
            
            MarkDown()\Items()\Type = #Glossary
            
            If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
              ClearList(MarkDown()\Lists()\Row())
              
              ForEach Sort()
                If FindMapElement(MarkDown()\Glossary(), Sort())
                  If AddElement(MarkDown()\Lists()\Row())
                    MarkDown()\Lists()\Row()\String = MapKey(MarkDown()\Glossary())
                    CopyList(MarkDown()\Glossary()\Words(), MarkDown()\Lists()\Row()\Words())
                  EndIf 
                EndIf
              Next
              
            EndIf  
            ;}
          EndIf
        Next
        
      EndIf  
      
      ForEach Found()
        MarkDown()\Keyword(Found())\Found = #True
      Next  
      
      If Export = #False
        If ListSize(MarkDown()\TOC()) Or MapSize(MarkDown()\Glossary())
          DetermineTextSize_()
          AdjustScrollBars_()
          Draw_(#Vertical|#Horizontal)
        EndIf
      EndIf
      
    EndIf
    
    PopMapPosition(MarkDown())
    
  EndProcedure
 
  ;- ============================================================================
	;-   Module - Drawing
	;- ============================================================================

	Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i, Round.i=#False)
	  
	  If Round
	    RoundBox(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), dpiX(Round), dpiY(Round), Color)  
  	Else
  		Box(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), Color)
  	EndIf
  	
  EndProcedure	
 
  Procedure   DrawArrow_(Color.i, Direction.i)
	  Define.i X, Y, Width, Height, aWidth, aHeight, aColor
	  
	  aColor= RGBA(Red(Color), Green(Color), Blue(Color), 255)
	  
	  Select Direction ;{ Position & Size
	    Case #Down
	      X       = MarkDown()\VScroll\Buttons\fX
	      Y       = MarkDown()\VScroll\Buttons\fY
	      Width   = MarkDown()\VScroll\Buttons\Width
	      Height  = MarkDown()\VScroll\Buttons\Height
	    Case #Up
	      X       = MarkDown()\VScroll\Buttons\bX
	      Y       = MarkDown()\VScroll\Buttons\bY
	      Width   = MarkDown()\VScroll\Buttons\Width
	      Height  = MarkDown()\VScroll\Buttons\Height
	    Case #Left
	      X       = MarkDown()\HScroll\Buttons\bX
	      Y       = MarkDown()\HScroll\Buttons\bY
	      Width   = MarkDown()\HScroll\Buttons\Width
	      Height  = MarkDown()\HScroll\Buttons\Height
	    Case #Right
	      X       = MarkDown()\HScroll\Buttons\fX
	      Y       = MarkDown()\HScroll\Buttons\fY
	      Width   = MarkDown()\HScroll\Buttons\Width
	      Height  = MarkDown()\HScroll\Buttons\Height 
	  EndSelect ;}
	  
	  If MarkDown()\Scrollbar\Flags & #Style_Win11 ;{ Arrow Size
	    
	    If Direction = #Down Or Direction = #Up 
	      aWidth  = 10
    	  aHeight =  7
	    Else
	      aWidth  =  7
        aHeight = 10  
	    EndIf   
	    
	    If MarkDown()\HScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If MarkDown()\HScroll\Buttons\fState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	    If MarkDown()\VScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If MarkDown()\VScroll\Buttons\fState= #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	  Else
	    
	    If Direction = #Down Or Direction = #Up
  	    aWidth  = dpiX(8)
  	    aHeight = dpiX(4)
  	  Else
        aWidth  = dpiX(4)
        aHeight = dpiX(8)   
	    EndIf  
      ;}
	  EndIf  
	  
	  X + ((Width  - aWidth) / 2)
    Y + ((Height - aHeight) / 2)
	  
	  If StartVectorDrawing(CanvasVectorOutput(MarkDown()\CanvasNum))

      If MarkDown()\Scrollbar\Flags & #Style_Win11 ;{ solid

        Select Direction
          Case #Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
            ClosePath()
          Case #Down 
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
            ClosePath()
          Case #Left
            MovePathCursor(dpiX(X + aWidth), dpiY(Y))
            AddPathLine(dpiX(X), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
            ClosePath()
          Case #Right
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X), dpiY(Y + aHeight))
            ClosePath()
        EndSelect
        
        VectorSourceColor(aColor)
        FillPath()
        StrokePath(1)
        ;}
      Else                               ;{ /\

        Select Direction
          Case #Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
          Case #Down 
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
          Case #Left
            MovePathCursor(dpiX(X + aWidth), dpiY(Y))
            AddPathLine(dpiX(X), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
          Case #Right
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X), dpiY(Y + aHeight))
        EndSelect
        
        VectorSourceColor(aColor)
        StrokePath(2, #PB_Path_RoundCorner)
        ;}
      EndIf
      
	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
  
	Procedure   DrawButton_(Scrollbar.i, Type.i)
	  Define.i X, Y, Width, Height
	  Define.i ArrowColor, ButtonColor, Direction, State
	  
	  Select Scrollbar ;{ Position, Size, State & Direction
	    Case #Horizontal
	      
	      If MarkDown()\HScroll\Hide : ProcedureReturn #False : EndIf
	      
        Width  = MarkDown()\HScroll\Buttons\Width
        Height = MarkDown()\HScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X      = MarkDown()\HScroll\Buttons\fX
            Y      = MarkDown()\HScroll\Buttons\fY
            State  = MarkDown()\HScroll\Buttons\fState
            Direction = #Right
  	      Case #Backwards
  	        X     = MarkDown()\HScroll\Buttons\bX
            Y     = MarkDown()\HScroll\Buttons\bY
            State = MarkDown()\HScroll\Buttons\bState
            Direction = #Left
  	    EndSelect 
        
      Case #Vertical
        
        If MarkDown()\VScroll\Hide : ProcedureReturn #False : EndIf
        
        Width  = MarkDown()\VScroll\Buttons\Width
        Height = MarkDown()\VScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X     = MarkDown()\VScroll\Buttons\fX
            Y     = MarkDown()\VScroll\Buttons\fY
            State = MarkDown()\VScroll\Buttons\fState
            Direction = #Down
  	      Case #Backwards
  	        X     = MarkDown()\VScroll\Buttons\bX
            Y     = MarkDown()\VScroll\Buttons\bY
            State = MarkDown()\VScroll\Buttons\bState
            Direction = #Up
        EndSelect
        ;}
    EndSelect    
    
    ;{ ----- Colors -----
    If MarkDown()\Scrollbar\Flags & #Style_Win11
      
      ButtonColor = MarkDown()\Scrollbar\Color\Back
      
      Select State
	      Case #Focus
	        ArrowColor = MarkDown()\Scrollbar\Color\Focus
	      Case #Hover
	        ArrowColor = MarkDown()\Scrollbar\Color\Hover
	      Case #Click  
	        ArrowColor = MarkDown()\Scrollbar\Color\Arrow
	      Default
	        ArrowColor = #PB_Default
	    EndSelect    

    Else
      
      Select State
	      Case #Hover
	        ButtonColor  = BlendColor_(MarkDown()\Scrollbar\Color\Focus, MarkDown()\Scrollbar\Color\Button, 10)
	      Case #Click
	        ButtonColor  = BlendColor_(MarkDown()\Scrollbar\Color\Focus, MarkDown()\Scrollbar\Color\Button, 20)
	      Default
	        ButtonColor  = MarkDown()\Scrollbar\Color\Button
	    EndSelect  
	    
	    ArrowColor = MarkDown()\Scrollbar\Color\Arrow
	    
	  EndIf 
	  ;}
    
	  ;{ ----- Draw button -----
	  If StartDrawing(CanvasOutput(MarkDown()\CanvasNum))
	    
	    DrawingMode(#PB_2DDrawing_Default)

	    Box_(X, Y, Width, Height, ButtonColor)
	    
	    StopDrawing()
	  EndIf ;}
	  
	  ;{ ----- Draw Arrows -----
	  If ArrowColor <> #PB_Default
	    DrawArrow_(ArrowColor, Direction)
	  EndIf ;} 

	EndProcedure
	
	Procedure   DrawThumb_(Scrollbar.i)
	  Define.i BackColor, ThumbColor, ThumbState, Round
	  Define.i OffsetPos, OffsetSize
	  
	  ;{ ----- Thumb cursor state -----
	  Select Scrollbar 
	    Case #Horizontal
	      
	      If MarkDown()\HScroll\Hide : ProcedureReturn #False : EndIf
	      
	      ThumbState = MarkDown()\HScroll\Thumb\State
	      
	    Case #Vertical
	      
	      If MarkDown()\VScroll\Hide : ProcedureReturn #False : EndIf
	      
  	    ThumbState = MarkDown()\VScroll\Thumb\State
  	    
  	EndSelect ;}    
  	
  	;{ ----- Colors -----
	  If MarkDown()\Scrollbar\Flags & #Style_Win11 
	    
	    BackColor = MarkDown()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = MarkDown()\Scrollbar\Color\Focus
	      Case #Hover
	        ThumbColor = MarkDown()\Scrollbar\Color\Hover
	      Case #Click
	        ThumbColor = MarkDown()\Scrollbar\Color\Hover
	      Default
	        ThumbColor = MarkDown()\Scrollbar\Color\Focus
	    EndSelect 
	    
	    If ThumbState ;{ Thumb size
	      Round = 4
	    Else
	      OffsetPos  =  2
	      OffsetSize = -4
	      Round = 0
  	    ;}
	    EndIf

	  Else
	    
	    BackColor = MarkDown()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = BlendColor_(MarkDown()\Scrollbar\Color\Focus, MarkDown()\Scrollbar\Color\Front, 10)
	      Case #Hover
	        ThumbColor = BlendColor_(MarkDown()\Scrollbar\Color\Focus, MarkDown()\Scrollbar\Color\Hover, 10)
	      Case #Click
	        ThumbColor = BlendColor_(MarkDown()\Scrollbar\Color\Focus, MarkDown()\Scrollbar\Color\Front, 20)
	      Default
	        ThumbColor = MarkDown()\Scrollbar\Color\Front
	    EndSelect 
	    
	    If MarkDown()\Scrollbar\Flags & #Style_RoundThumb
	      Round = 4
	    Else
	      Round = #False
	    EndIf
	    
	  EndIf ;}  
	  
	  If StartDrawing(CanvasOutput(MarkDown()\CanvasNum))
	    
	    DrawingMode(#PB_2DDrawing_Default)

	    Select Scrollbar 
  	    Case #Horizontal
  	      
  	      Box_(MarkDown()\HScroll\Area\X, MarkDown()\HScroll\Area\Y, MarkDown()\HScroll\Area\Width, MarkDown()\HScroll\Area\Height, BackColor)
  	      
      	  Box_(MarkDown()\HScroll\Thumb\X, MarkDown()\HScroll\Thumb\Y + OffsetPos, MarkDown()\HScroll\Thumb\Width, MarkDown()\HScroll\Thumb\Height + OffsetSize, ThumbColor, Round)
      	  
      	Case #Vertical

      	  Box_(MarkDown()\VScroll\Area\X, MarkDown()\VScroll\Area\Y, MarkDown()\VScroll\Area\Width, MarkDown()\VScroll\Area\Height, BackColor)

      	  Box_(MarkDown()\VScroll\Thumb\X + OffsetPos, MarkDown()\VScroll\Thumb\Y, MarkDown()\VScroll\Thumb\Width + OffsetSize, MarkDown()\VScroll\Thumb\Height, ThumbColor, Round)

  	  EndSelect

  	  StopDrawing()
	  EndIf  
  	
	EndProcedure  
	
  
  Procedure   DrawScrollBar_(ScrollBar.i=#False)
		Define.i OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		CalcScrollBar_()

  	;{ ----- thumb position -----
		If MarkDown()\Scrollbar\Flags & #Horizontal
		  OffsetX = Round((MarkDown()\HScroll\Pos - MarkDown()\HScroll\minPos) * MarkDown()\HScroll\Factor, #PB_Round_Nearest)
		  MarkDown()\HScroll\Thumb\X = MarkDown()\HScroll\Area\X + OffsetX
  	EndIf
		
		If MarkDown()\Scrollbar\Flags & #Vertical
		  OffsetY = Round((MarkDown()\VScroll\Pos - MarkDown()\VScroll\minPos) * MarkDown()\VScroll\Factor, #PB_Round_Nearest)
		  MarkDown()\VScroll\Thumb\Y = MarkDown()\VScroll\Area\Y + OffsetY
		EndIf ;}
		
		If StartDrawing(CanvasOutput(MarkDown()\CanvasNum)) ; Draw scrollbar background
      
		  DrawingMode(#PB_2DDrawing_Default)
		  
		  If ScrollBar = #Horizontal|#Vertical
		    
		    If MarkDown()\Type = #Requester
		      
		      If MarkDown()\HScroll\Hide = #False
  		      Box_(1, MarkDown()\HScroll\Y, GadgetWidth(MarkDown()\CanvasNum) - 2, MarkDown()\HScroll\Height - 33, MarkDown()\Color\Gadget)
  		    EndIf
  
  		    If MarkDown()\VScroll\Hide = #False
  		      Box_(MarkDown()\VScroll\X, 1, MarkDown()\VScroll\Width, GadgetHeight(MarkDown()\CanvasNum) - 35, MarkDown()\Color\Gadget)
  		    EndIf
		      
		    Else
		      
		      If MarkDown()\HScroll\Hide = #False
  		      Box_(MarkDown()\HScroll\Y, MarkDown()\HScroll\Y, GadgetWidth(MarkDown()\CanvasNum) - 2, MarkDown()\HScroll\Height, MarkDown()\Color\Gadget)
  		    EndIf
  
  		    If MarkDown()\VScroll\Hide = #False
  		      Box_(MarkDown()\VScroll\X, MarkDown()\VScroll\Y, MarkDown()\VScroll\Width, GadgetHeight(MarkDown()\CanvasNum) - 2, MarkDown()\Color\Gadget)
  		    EndIf

		    EndIf   

		  EndIf  
		  
		  StopDrawing()
		EndIf
		
		Select ScrollBar
		  Case #Horizontal  
		    DrawThumb_(#Horizontal) 
		  Case #Vertical
		    DrawThumb_(#Vertical)
		  Case #Scrollbar_Left
		    DrawThumb_(#Horizontal)
		    DrawButton_(#Horizontal, #Backwards)
		  Case #Scrollbar_Right
		    DrawThumb_(#Horizontal)
		    DrawButton_(#Horizontal, #Forwards)
		  Case #Scrollbar_Up
		    DrawThumb_(#Vertical)
		    DrawButton_(#Vertical, #Backwards)
		  Case #Scrollbar_Down
		    DrawThumb_(#Vertical)
		    DrawButton_(#Vertical, #Forwards)
		  Case #Horizontal|#Vertical

		    If MarkDown()\HScroll\Hide = #False
    		  DrawButton_(#Horizontal, #Forwards)
    		  DrawButton_(#Horizontal, #Backwards)
    		  DrawThumb_(#Horizontal)
    		EndIf
    		
    		If MarkDown()\VScroll\Hide = #False
    		  DrawButton_(#Vertical, #Forwards)
    		  DrawButton_(#Vertical, #Backwards)
    		  DrawThumb_(#Vertical)
    		EndIf 
    		
		EndSelect

	EndProcedure

  
	CompilerIf #Enable_Requester
	  
  	Procedure Button_(Key.s, X.i, Y.i)
  	  Define.i Width, Height, OffSetX, OffsetY
  	  Define.i BackColor, BorderColor
  	  Define.s Text
  	  
  	  
  	  Width  = MarkDown()\Requester\Button(Key)\Width
  	  
  	  Height = #ButtonHeight
  	  
  	  Text = MarkDown()\Requester\Button(Key)\Text
  	  
  	  Select MarkDown()\Requester\Button(Key)\State
  	    Case #Focus
  	      BackColor   = BlendColor_(MarkDown()\Color\Focus, MarkDown()\Color\Button, 10)
  	      BorderColor = MarkDown()\Color\Border
  	    Case #Click
  	      BackColor   = BlendColor_(MarkDown()\Color\Focus, MarkDown()\Color\Button, 20)
  	      BorderColor = MarkDown()\Color\Focus
  	    Default
  	      BackColor   = MarkDown()\Color\Button
  	      BorderColor = MarkDown()\Color\Border
  	  EndSelect
  	  
    	;{ _____ Background _____
  	  DrawingMode(#PB_2DDrawing_Default)
  	  Box_(X, Y, Width, Height, BackColor)
  		;}
  	  
  	  MarkDown()\Requester\Button(Key)\X = X
  	  
  	  OffSetX = (Width - TextWidth_(Text)) / 2
  	  OffsetY = (Height - TextHeight_(Text)) / 2
  	  
  	  DrawingMode(#PB_2DDrawing_Transparent)
  	  DrawText_(X + OffSetX, Y + OffsetY, Text, MarkDown()\Color\Front)
  
  	  ;{ _____ Border _____
  	  DrawingMode(#PB_2DDrawing_Outlined)
  	  Box_(X, Y, Width, Height, BorderColor)
  	  ;}
  	  
  	EndProcedure
  	
  CompilerEndIf

	Procedure.i Keystroke_(X.i, Y.i, Key.s)
	  Define.i Width, Height
	  
	  Width  = TextWidth_(Key) + 10
	  Height = TextHeight_(Key)
	  
	  DrawingMode(#PB_2DDrawing_Default)
	  Box_(X, Y, Width, Height, MarkDown()\Color\KeyStrokeBack, 4)
	  DrawingMode(#PB_2DDrawing_Outlined)
	  Box_(X, Y, Width, Height, MarkDown()\Color\Border, 4)
	  DrawingMode(#PB_2DDrawing_Transparent)
	  DrawText_(X + 5, Y, Key, MarkDown()\Color\KeyStroke)
	  
	  ProcedureReturn X + Width
	EndProcedure  

	Procedure   DashLine_(X.i, Y.i, Width.i, Color.i)
	  Define.i  i
	  
	  If Y < GadgetHeight(MarkDown()\CanvasNum)
  	  For i=0 To Width - 1 Step 2
  	    Plot(dpiX(X + i), dpiY(Y), Color)
  	  Next
  	EndIf
  	
	EndProcedure  
	
	Procedure   CheckBox_(X.i, Y.i, boxWidth.i, FrontColor.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
      
      Box_(X, Y, boxWidth, boxWidth, BackColor)
      
      LineColor = BlendColor_(FrontColor, BackColor, 60)
      
      If State

        bColor = BlendColor_(LineColor, FrontColor)
        
        X1 = X + 1
        X2 = X + boxWidth - 2
        Y1 = Y + 1
        Y2 = Y + boxWidth - 2
        
        LineXY_(X1 + 1, Y1, X2 + 1, Y2, bColor)
        LineXY_(X1 - 1, Y1, X2 - 1, Y2, bColor)
        LineXY_(X2 + 1, Y1, X1 + 1, Y2, bColor)
        LineXY_(X2 - 1, Y1, X1 - 1, Y2, bColor)
        LineXY_(X2, Y1, X1, Y2, LineColor)
        LineXY_(X1, Y1, X2, Y2, LineColor)
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      
      Box_(X + 2, Y + 2, boxWidth - 4, boxWidth - 4, BlendColor_(LineColor, BackColor, 5))
      Box_(X + 1, Y + 1, boxWidth - 2, boxWidth - 2, BlendColor_(LineColor, BackColor, 25))
      Box_(X, Y, boxWidth, boxWidth, LineColor)
    
  EndProcedure


  Procedure.i GetAlignOffset_(WordIdx.i, Width.i, Align.s, List Words.Words_Structure())
    Define.i TextWidth, OffsetX
    
    PushListPosition(Words())
    
    ForEach Words()
      
      If ListIndex(Words()) >= WordIdx
        
        If TextWidth + Words()\Width > Width
          Break
        Else  
          TextWidth + Words()\Width
        EndIf  
        
      EndIf
      
    Next

    PopListPosition(Words())
    
    Select Align
      Case "C"
        OffsetX = (Width - TextWidth) / 2
      Case "R"
        OffsetX = Width - TextWidth - 5
      Default
        OffsetX = 5
    EndSelect    
    
    ProcedureReturn OffsetX
  EndProcedure
  
  
  Procedure.i DrawRow_(X.i, Y.i, Width.i, Height.i, BlockQuote.i, List Words.Words_Structure(), ColWidth.i=#False, Align.s="L")
    Define.i c, TextWidth, ImgSize, Image, WordIdx
    Define.i Pos, PosX, PosY, lX, lY, OffSetX, OffSetY, OffSetBQ
    Define.s Word$, WordOnly$, Image$, File$
    
    If BlockQuote : OffSetBQ = 10 * BlockQuote : EndIf 
    
    X + OffSetBQ

    PosX = X
    PosY = Y

    DrawingMode(#PB_2DDrawing_Transparent)
    
    If X + Width > MarkDown()\WrapPos ;{ Wrap Text

      lY = PosY
      
      WordIdx = 0
      
      If ColWidth : PosX + GetAlignOffset_(0, ColWidth, Align, Words()) : EndIf
    
      ForEach Words()
        
        Word$ = Words()\String
        
        DrawingFont_(Words()\Font)
        
        If ColWidth And Words()\Width > ColWidth - 10
        
          PosX - GetAlignOffset_(0, ColWidth, Align, Words())
          
          For c = Len(Word$) - 1 To 0 Step -1
            If TextWidth_(Left(Word$, c) + #Cut$) <= ColWidth - 10
              Word$ = Left(Word$, c) + #Cut$
              Break
            EndIf   
          Next
          
          PosX + 5
          
        EndIf
          
        If PosX + TextWidth_(Word$) > MarkDown()\WrapPos ;{ New row

          Word$ = LTrim(Word$)
          
          PosX = X
          PosY + Height
          
          WordIdx = ListIndex(Words())
          
          If ColWidth : PosX + GetAlignOffset_(WordIdx, ColWidth, Align, Words()) : EndIf

          If BlockQuote            ;{ BlockQuote
            DrawingMode(#PB_2DDrawing_Default)
            Box_(MarkDown()\LeftBorder, lY, 5, Height, MarkDown()\Color\BlockQuote)
            If BlockQuote = 2
              Box_(MarkDown()\LeftBorder + 10, lY, 5, Height, MarkDown()\Color\BlockQuote)
            EndIf
            DrawingMode(#PB_2DDrawing_Transparent) ;}
          EndIf

          lY = PosY
          ;}
        EndIf
        
        lX = PosX
        
        Select Words()\Flag
          Case #Code            ;{ Draw Code
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Code)
            ;}
          Case #Emoji           ;{ Draw emoji  
            If Height <= 16
              ImgSize = Height - 1
            Else
              ImgSize = 16
            EndIf  
            OffSetY = (Height - ImgSize) / 2
            Image = Emoji(Word$)
            If IsImage(Image)
              DrawingMode(#PB_2DDrawing_AlphaBlend)
		          DrawImage_(ImageID(Image), PosX, PosY + OffSetY, ImgSize, ImgSize)
		          PosX + ImgSize
		        EndIf
		        DrawingMode(#PB_2DDrawing_Transparent)
            ;}  
          Case #FootNote        ;{ Draw footnote
            
            If SelectElement(MarkDown()\Footnote(), Words()\Index)
              MarkDown()\Footnote()\X      = PosX
              MarkDown()\Footnote()\Y      = PosY
              MarkDown()\Footnote()\Width  = TextWidth_(Word$)
              MarkDown()\Footnote()\Height = Height
            EndIf 
            
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Hint)
            ;}
          Case #Glossary        ;{ Draw Glossary
            If SelectElement(MarkDown()\GlossaryWord(), Words()\Index)
              MarkDown()\GlossaryWord()\X = PosX
              MarkDown()\GlossaryWord()\Y = PosY
              MarkDown()\GlossaryWord()\Width  = TextWidth_(Word$)
              MarkDown()\GlossaryWord()\Height = Height
            EndIf
            
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Hint)
            ;}
          Case #Highlight       ;{ Draw highlighted text
            DrawingMode(#PB_2DDrawing_Default)
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Front, MarkDown()\Color\Highlight)
            DrawingMode(#PB_2DDrawing_Transparent)
            ;}
          Case #Underline       ;{ Draw underlined text
            lX   = PosX
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Front)
            Line_(lX, PosY + TextHeight_(Word$) - 1, TextWidth_(Word$), 1, MarkDown()\Color\Front)
            ;} 
          Case #Image           ;{ Draw image
            
            If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
              
              ;{ Load Image
              Image$ = GetFilePart(MarkDown()\Image()\Source)
              File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)

              If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                If AddMapElement(MarkDown()\ImageNum(), Image$) 
                  
                  If IsImage(MarkDown()\ImageNum()) = #False
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$) 
                  EndIf
                  
                  If IsImage(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    			          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    			        EndIf
    			        
                EndIf
              EndIf ;}
    	        
    	        If IsImage(MarkDown()\ImageNum())
    	          
    	          MarkDown()\Image()\X = PosX
    	          MarkDown()\Image()\Y = PosY
    	          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    	          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    	          
    	          DrawingMode(#PB_2DDrawing_AlphaBlend)
    	          DrawImage_(ImageID(MarkDown()\ImageNum()), PosX, PosY)
    	          
    	          PosX + MarkDown()\Image()\Width

    	        EndIf 
    	        
    	        ;If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
    	        
    	      EndIf
            ;}
    	    Case #Keystroke       ;{ Draw keystroke
    	      PosX = Keystroke_(PosX, PosY, Word$)
    	      ;}
    	    Case #Keyword         ;{ Draw keyword
    	      If MarkDown()\Keyword(Trim(Word$))\Found
    	        DrawingMode(#PB_2DDrawing_Default)
    	        PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Found, MarkDown()\Color\FoundBack)
    	        DrawingMode(#PB_2DDrawing_Transparent)
    	      Else
    	        PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Keyword)
    	      EndIf   
    	      ;}
    	    Case #Link, #AutoLink ;{ Draw link
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              MarkDown()\Link()\X      = PosX
              MarkDown()\Link()\Y      = PosY
              MarkDown()\Link()\Width  = TextWidth_(Word$)
              MarkDown()\Link()\Height = Height
              If MarkDown()\Link()\State
                Line_(PosX, PosY + TextHeight_(Word$) - 1, TextWidth_(Word$), 1, MarkDown()\Color\LinkHighlight)
                PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\LinkHighlight)
              Else
                Line_(PosX, PosY + TextHeight_(Word$) - 1, TextWidth_(Word$), 1, MarkDown()\Color\Link)
                PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Link)
              EndIf
            EndIf
            ;}
          Case #StrikeThrough   ;{ Draw strikethrough text
            lX   = PosX
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Front)
            Line_(lX, PosY + Round(Height / 2, #PB_Round_Up), TextWidth_(Word$), 1, MarkDown()\Color\Front)
            ;}
          Case #Subscript       ;{ Draw subscripted text
            OffSetY = Height - TextHeight_(Word$) + 2
            PosX = DrawText_(PosX, PosY + OffSetY, Word$, MarkDown()\Color\Front)
            ;}    
          Case #InsertTOC             ;{ Table of Contents
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Link)
            ;}
          Default 
            PosX = DrawText_(PosX, PosY, Word$, MarkDown()\Color\Front)
        EndSelect

        ;{ Abbreviation
        If MapSize(MarkDown()\Abbreviation())
          
          WordOnly$ = WordOnly_(Word$)
          
          If FindMapElement(MarkDown()\Abbreviation(), WordOnly$)
            
            If AddElement(MarkDown()\AbbrevWord())
              
              MarkDown()\AbbrevWord()\Word = WordOnly$
              
              Pos = FindString(Word$, WordOnly$)
              If Pos > 1
                MarkDown()\AbbrevWord()\X = lX + TextWidth_(Left(Word$, Pos - 1) )
              Else
                MarkDown()\AbbrevWord()\X = lX  
              EndIf
              
              MarkDown()\AbbrevWord()\Y = lY
              MarkDown()\AbbrevWord()\Width  = TextWidth_(WordOnly$)
              MarkDown()\AbbrevWord()\Height = TextHeight_(WordOnly$)
            EndIf
            
            DashLine_(MarkDown()\AbbrevWord()\X, lY + MarkDown()\AbbrevWord()\Height - 1, MarkDown()\AbbrevWord()\Width, MarkDown()\Color\Hint)
          EndIf
          
        EndIf ;}
        
      Next
      ;}
    Else

      lY = PosY
      
      If ColWidth : PosX + GetAlignOffset_(0, ColWidth, Align, Words()) : EndIf
      
      ForEach Words()
        
        DrawingFont_(Words()\Font)
        
        lX = PosX
        
        Select Words()\Flag
          Case #Code            ;{ Draw Code
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Code)  
            ;}
          Case #Emoji           ;{ Draw emoji  
            If Height <= 16
              ImgSize = Height - 1
            Else
              ImgSize = 16
            EndIf  
            OffSetY = (Height - ImgSize) / 2
            Image = Emoji(Words()\String)
            If IsImage(Image)
              DrawingMode(#PB_2DDrawing_AlphaBlend)
		          DrawImage_(ImageID(Image), PosX, PosY + OffSetY, ImgSize, ImgSize)
		          PosX + ImgSize
		        EndIf
		        DrawingMode(#PB_2DDrawing_Transparent)
            ;}  
          Case #FootNote        ;{ Draw footnote
            
            If SelectElement(MarkDown()\Footnote(), Words()\Index)
              MarkDown()\Footnote()\X      = PosX
              MarkDown()\Footnote()\Y      = PosY
              MarkDown()\Footnote()\Width  = TextWidth_(Words()\String)
              MarkDown()\Footnote()\Height = Height
            EndIf 
            
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Hint)
            ;}
          Case #Glossary        ;{ Draw Glossary
            If SelectElement(MarkDown()\GlossaryWord(), Words()\Index)
              MarkDown()\GlossaryWord()\X = PosX
              MarkDown()\GlossaryWord()\Y = PosY
              MarkDown()\GlossaryWord()\Width  = TextWidth_(Words()\String)
              MarkDown()\GlossaryWord()\Height = Height
            EndIf
            
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Hint)
            ;}  
          Case #Highlight       ;{ Draw highlighted text
            DrawingMode(#PB_2DDrawing_Default)
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Front, MarkDown()\Color\Highlight)
            DrawingMode(#PB_2DDrawing_Transparent)
            ;}
          Case #Image           ;{ Draw image
            
            If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
              
              ;{ Load Image
              Image$ = GetFilePart(MarkDown()\Image()\Source)
              File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
              
              If FindMapElement(MarkDown()\ImageNum(), Image$) = #False
                If AddMapElement(MarkDown()\ImageNum(), Image$)
                  
                  If IsImage(MarkDown()\ImageNum()) = #False
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$) 
                  EndIf
    			        
                EndIf
              EndIf ;}
    	        
    	        If IsImage(MarkDown()\ImageNum())
    	          
    	          DrawingMode(#PB_2DDrawing_AlphaBlend)
    	          DrawImage_(ImageID(MarkDown()\ImageNum()), PosX, PosY)
    	          
    	          MarkDown()\Image()\X = PosX
    	          MarkDown()\Image()\Y = PosY
    	          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    	          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    	          
    	          PosX + MarkDown()\Image()\Width
  
    	        EndIf 
      	     
    	        ;If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
    	        
    	      EndIf   
            ;}  
    	    Case #Keystroke       ;{ Draw keystroke
    	      PosX = Keystroke_(PosX, PosY, Words()\String)
    	      ;}  
    	    Case #Keyword         ;{ Draw keyword
    	      If MarkDown()\Keyword(Trim(Words()\String))\Found
    	        DrawingMode(#PB_2DDrawing_Default)
    	        PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Found, MarkDown()\Color\FoundBack)
    	        DrawingMode(#PB_2DDrawing_Transparent)
    	      Else
    	        PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Keyword)
    	      EndIf
    	      ;}
    	    Case #Link, #AutoLink ;{ Draw link
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              MarkDown()\Link()\X      = PosX
              MarkDown()\Link()\Y      = PosY
              MarkDown()\Link()\Width  = TextWidth_(Words()\String)
              MarkDown()\Link()\Height = Height
              If MarkDown()\Link()\State
                Line_(PosX, PosY + TextHeight_(Words()\String) - 1, TextWidth_(Words()\String), 1, MarkDown()\Color\LinkHighlight)
                PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\LinkHighlight)
              Else
                Line_(PosX, PosY + TextHeight_(Words()\String) - 1, TextWidth_(Words()\String), 1, MarkDown()\Color\Link)
                PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Link)
              EndIf
            EndIf
            ;}
          Case #StrikeThrough   ;{ Draw strikethrough text
            lX   = PosX
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Front)
            Line_(lX, PosY + Round(Height / 2, #PB_Round_Up), TextWidth_(Words()\String), 1, MarkDown()\Color\Front)
            ;} 
          Case #Subscript       ;{ Draw subscripted text
            OffSetY = Height - TextHeight_(Words()\String) + 2
            PosX = DrawText_(PosX, PosY + OffSetY, Words()\String, MarkDown()\Color\Front)
            ;}
          Case #Underline       ;{ Draw underlined text
            lX   = PosX
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Front)
            Line_(lX, PosY + TextHeight_(Words()\String) - 1, TextWidth_(Words()\String), 1, MarkDown()\Color\Front)
            ;}   
          Case #InsertTOC       ;{ Table of Contents
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Link)
            ;}  
          Default
            PosX = DrawText_(PosX, PosY, Words()\String, MarkDown()\Color\Front)
        EndSelect
        
        ;{ Abbreviation
        If MapSize(MarkDown()\Abbreviation())
          
          WordOnly$ = WordOnly_(Words()\String)
          
          If FindMapElement(MarkDown()\Abbreviation(), WordOnly$)
            
            If AddElement(MarkDown()\AbbrevWord())
              
              MarkDown()\AbbrevWord()\Word = WordOnly$
              
              Pos = FindString(Words()\String, WordOnly$)
              If Pos > 1
                MarkDown()\AbbrevWord()\X = lX + TextWidth_(Left(Words()\String, Pos - 1) )
              Else
                MarkDown()\AbbrevWord()\X = lX  
              EndIf
              
              MarkDown()\AbbrevWord()\Y = lY
              MarkDown()\AbbrevWord()\Width  = TextWidth_(WordOnly$)
              MarkDown()\AbbrevWord()\Height = TextHeight_(WordOnly$)
            EndIf
            
            DashLine_(MarkDown()\AbbrevWord()\X, lY + MarkDown()\AbbrevWord()\Height - 1, MarkDown()\AbbrevWord()\Width, MarkDown()\Color\Hint)
          EndIf
          
        EndIf ;}
        
      Next

    EndIf
    
    If BlockQuote            ;{ BlockQuote
      DrawingMode(#PB_2DDrawing_Default)
      Box_(MarkDown()\LeftBorder, lY, 5, Height, MarkDown()\Color\BlockQuote)
      If BlockQuote = 2
        Box_(MarkDown()\LeftBorder + 10, lY, 5, Height, MarkDown()\Color\BlockQuote)
      EndIf ;}
    EndIf
    
    ProcedureReturn PosY + Height
  EndProcedure
  
  Procedure.i DrawSymbol(Char.s, X.i, Y.i, Height.i, Color.i)
    Define.i OffsetX, OffsetY, cWidth
    
    DrawingFont(FontID(MarkDown()\Font\Note))
    cWidth  = TextWidth_(#Circle$) 
    OffsetY = (Height - TextHeight_(#Circle$)) / 2
    
    DrawText_(X, Y + OffsetY, #Circle$, Color)
    
    DrawingFont(FontID(MarkDown()\Font\Bold))
    OffsetX = (cWidth - TextWidth_(Char)) / 2 
    OffsetY = (Height - TextHeight_(Char)) / 2
    
    DrawText_(X + OffsetX, Y + OffsetY + 1, Char, Color)
    
    ProcedureReturn X + cWidth
  EndProcedure
  
  Procedure.i DrawNote(Index.i, X.i, Y.i, Width) 
    Define.i PosX, HeaderHeight, OffsetX, OffsetY, BackColor
    Define.s Symbol$, Char$
    
    If SelectElement(MarkDown()\Note(), Index)
      
      Select MarkDown()\Note()\Type
        Case "info"  
          BackColor = BlendColor_($B48246, $FFFFFF, 30)
        Case "question"  
          BackColor = BlendColor_($32CD9A, $FFFFFF, 30)
        Case "error"
          BackColor = BlendColor_($2222B2, $FFFFFF, 30)
        Case "caution"
          BackColor = BlendColor_($008CFF, $FFFFFF, 30)
      EndSelect
    
      DrawingMode(#PB_2DDrawing_Default)
      Box_(X, Y, Width, MarkDown()\Items()\Height + 14, BackColor, 4)
      Box_(X, Y + MarkDown()\Items()\Height + 10, Width, 8, $FFFFFF)
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(X, Y, Width, MarkDown()\Note()\Height + 20, MarkDown()\Color\Border, 4)
      Line_(X, Y + MarkDown()\Items()\Height + 10, Width, 1, MarkDown()\Color\Border)
      
      PosX = X + 10
      HeaderHeight = MarkDown()\Items()\Height + 10
      
      DrawingMode(#PB_2DDrawing_Transparent)
      
      Select MarkDown()\Note()\Type
        Case "info"  
          PosX = DrawSymbol("i", PosX, Y, HeaderHeight, $B48246)
        Case "question"
          PosX = DrawSymbol("?", PosX, Y, HeaderHeight, $32CD9A)
        Case "error"
          PosX = DrawSymbol("!", PosX, Y, HeaderHeight, $2222B2)
        Case "caution"
          DrawingFont(FontID(MarkDown()\Font\Note))
          OffsetY = (HeaderHeight - TextHeight_(#Caution$)) / 2
          DrawText_(PosX, Y + OffsetY, #Caution$, $008CFF)
          PosX + TextWidth_(#Caution$)
      EndSelect
      
      DrawingFont(FontID(MarkDown()\Font\Bold))
      
      OffsetY = (MarkDown()\Items()\Height + 10 - TextHeight_("X")) / 2
      
      Y = DrawRow_(PosX + 10, Y + OffsetY, MarkDown()\Items()\Width, MarkDown()\Items()\Height, #False, MarkDown()\Items()\Words())
      Y + 10
      
      ForEach MarkDown()\Note()\Row()
        Y = DrawRow_(X + 10, Y, Width - 30, MarkDown()\Note()\Row()\Height, #False, MarkDown()\Note()\Row()\Words())
      Next
      
      ProcedureReturn Y + 5
    EndIf  
    
  EndProcedure
  
  Procedure.i DrawTOC(X.i, Y.i)
    Define.i OffsetX
    
    ForEach MarkDown()\TOC()
     
      OffsetX = MarkDown()\TOC()\Level * 15 
    
      MarkDown()\TOC()\X = X + OffsetX
      MarkDown()\TOC()\Y = Y
      
      Y = DrawRow_(MarkDown()\TOC()\X, MarkDown()\TOC()\Y, MarkDown()\TOC()\Width, MarkDown()\TOC()\Height, #False, MarkDown()\TOC()\Words())

    Next
    
    ProcedureReturn Y
  EndProcedure
  
  Procedure.i DrawList_(Index.i, Type.i, Map ListNum.i(), X.i, Y.i, Width.i, Height.i, BlockQuote.i)
    Define.i PosX, bqY, OffSetBQ, Indent, Level
    Define.s Chars$

    If BlockQuote
      OffSetBQ = 10 * BlockQuote
      OffSetBQ - 5
    EndIf 
    
    X + OffSetBQ

    If SelectElement(MarkDown()\Lists(), Index)
      
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(MarkDown()\Font\Normal))

      Y + 3

      If Type = #DefinitionList
        DrawingFont(FontID(MarkDown()\Font\Bold))
        Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, #False, MarkDown()\Items()\Words())
      EndIf
      
      ForEach MarkDown()\Lists()\Row()
        
        PosX = X
        bqY  = Y

        Select Type
          Case #OrderedList    ;{ Ordered list
            
            Level = MarkDown()\Lists()\Row()\Level 
            If FindMapElement(ListNum(), Str(Level)) = #False : ListNum(Str(Level)) = MarkDown()\Lists()\Start - 1 : EndIf 
            
            ListNum(Str(Level)) + 1
            Chars$ = Str(ListNum(Str(Level))) + ". "
            Indent = TextWidth_(Chars$) * MarkDown()\Lists()\Row()\Level + MarkDown()\Indent
            PosX   = DrawText_(PosX + Indent, Y, Chars$, MarkDown()\Color\Front)
            
            ListNum(Str(Level + 1)) = 0
            
            ;}
          Case #DefinitionList ;{ Definition list
            Indent = MarkDown()\Indent * MarkDown()\Lists()\Row()\Level
            PosX + Indent + MarkDown()\Indent
            ;}
          Case #TaskList       ;{ Task list
            Indent = (MarkDown()\Lists()\Row()\Height + TextWidth_(" ")) * (MarkDown()\Lists()\Row()\Level + 1) + MarkDown()\Indent
            CheckBox_(PosX + MarkDown()\Indent, Y + 1, MarkDown()\Lists()\Row()\Height - 2, MarkDown()\Color\Front, MarkDown()\Color\Back, MarkDown()\Lists()\Row()\State)
            PosX + Indent
            ;}
          Case #Glossary       ;{ Glossary 
            DrawingFont(FontID(MarkDown()\Font\Bold))
            DrawText_(PosX, Y, MarkDown()\Lists()\Row()\String, MarkDown()\Color\Front)
            Y + TextHeight_(MarkDown()\Lists()\Row()\String)
            Indent = MarkDown()\Indent * MarkDown()\Lists()\Row()\Level
            PosX + Indent + MarkDown()\Indent
            ;}
          Default              ;{ Unordered list
            Chars$ = #Bullet$ + " "
            Indent = TextWidth_(Chars$) * MarkDown()\Lists()\Row()\Level + MarkDown()\Indent
            PosX   = DrawText_(PosX + Indent, Y, Chars$, MarkDown()\Color\Front)
            ;}
        EndSelect 
        
        Y = DrawRow_(PosX, Y, MarkDown()\Lists()\Row()\Width, MarkDown()\Lists()\Row()\Height, #False, MarkDown()\Lists()\Row()\Words())
        
        If MarkDown()\Lists()\Row()\BlockQuote ;{ BlockQuote
          DrawingMode(#PB_2DDrawing_Default)
          Box_(MarkDown()\LeftBorder, bqY, 5, MarkDown()\Lists()\Row()\Height, MarkDown()\Color\BlockQuote)
          If MarkDown()\Lists()\Row()\BlockQuote = 2
            Box_(MarkDown()\LeftBorder + 10, bqY, 5, Y - bqY, MarkDown()\Color\BlockQuote)
          EndIf
          DrawingMode(#PB_2DDrawing_Transparent) ;}
        EndIf

      Next
      
      Y + 3
      
    EndIf
    
    ProcedureReturn Y
  EndProcedure  
  
  Procedure.i DrawTable_(Index.i, X.i, Y.i, BlockQuote.i) 
    Define.i c, PosX, PosY, ColY, OffSetY, OffSetBQ, colWidth, colHeight, LastX, LastWidth, SpanPos, Width
    Define.i TableWidth, RowY, RowHeight, Count, Sum, cutWidth
    Define.f Factor
    Define.s Num$
    
    NewMap ColX.i()
    NewMap ColWidth.i()
    NewMap CellBorder.CellBorder_Structure()
    
    If SelectElement(MarkDown()\Table(), Index)
      
      If BlockQuote : OffSetBQ = 10 * BlockQuote : EndIf 
    
      X + OffSetBQ
      
      Width = GadgetWidth(MarkDown()\CanvasNum) - (X +  MarkDown()\Margin\Right)
      
      ;{ ___ Columns ___
      For c=1 To MarkDown()\Table()\Cols
        ColWidth(Str(c)) = MarkDown()\Table()\Column(Str(c))\Width
        TableWidth + ColWidth(Str(c))
      Next
      
      If TableWidth > Width

        cutWidth = TableWidth - Width

        colWidth = Width / MarkDown()\Table()\Cols
        For c=1 To MarkDown()\Table()\Cols
          If ColWidth(Str(c)) > colWidth
            Sum   + (ColWidth(Str(c)) - colWidth)
            Count + 1
          EndIf  
        Next

        For c=1 To MarkDown()\Table()\Cols
          If ColWidth(Str(c)) > colWidth
            Factor = (ColWidth(Str(c)) - colWidth) / Sum
            ColWidth(Str(c)) - (cutWidth * Factor)
          EndIf
        Next   
        
      EndIf  
      
      PosX = X
      
      For c=1 To MarkDown()\Table()\Cols
        ColX(Str(c)) = PosX
        PosX + ColWidth(Str(c))
      Next
      ;}
      
      ForEach MarkDown()\Table()\Row()
        
        PosY = Y
        
        SpanPos   = 1
        LastX     = #PB_Default
        LastWidth = 0
        
        DrawingMode(#PB_2DDrawing_Default)
        
        For c=1 To MarkDown()\Table()\Cols
          
          Num$ = Str(c)
          
          CellBorder(Num$)\Border = #False
          
          PosX = ColX(Num$)
          
          If MarkDown()\Table()\Row()\Col(Num$)\Span = 0     ;{ Ignored cell
            
            If c = 1
              LastX     = PosX
              LastWidth = GetSpanWidth_(1, MarkDown()\Table()\Row()\Col("2")\Span, ColWidth())
            ElseIf LastX >= 0
              LastWidth = GetSpanWidth_(1, MarkDown()\Table()\Row()\Col(Str(c + 1))\Span, ColWidth())
            EndIf
            
            Continue
            ;}
          ElseIf LastX >= 0                                  ;{ Colspan & Column 1
            
            PosX     = LastX
            colWidth = LastWidth
            
            LastX = #PB_Default
            LastWidth = 0
            ;}
          ElseIf MarkDown()\Table()\Row()\Col(Num$)\Span > 1 ;{ Colspan
            colWidth = GetSpanWidth_(c, MarkDown()\Table()\Row()\Col(Num$)\Span, ColWidth())
            ;}
          Else
            colWidth = ColWidth(Num$)
          EndIf 
          
          CellBorder(Str(c))\Border = #True
          CellBorder(Str(c))\X      = PosX
          CellBorder(Str(c))\Width  = ColWidth + 1
          
          colHeight = MarkDown()\Table()\Row()\Height + 6
          
          MarkDown()\WrapPos = PosX + colWidth - 3
          
          If MarkDown()\Table()\Row()\Type = #TableHeader
            DrawingMode(#PB_2DDrawing_Default)
            Box_(PosX, PosY, colWidth, colHeight, MarkDown()\Color\HeaderBack)
          EndIf   
          
          ;DrawingMode(#PB_2DDrawing_Outlined)
          ;Box_(PosX, PosY, colWidth + 1, colHeight + 1, MarkDown()\Color\Front)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          ColY = DrawRow_(PosX, PosY + 3, ColWidth(Num$), MarkDown()\Table()\Row()\Height, BlockQuote, MarkDown()\Table()\Row()\Col(Num$)\Words(), colWidth, MarkDown()\Table()\Column(Num$)\Align)
          
          ColY + 3
          
          If ColY > Y : Y = ColY : EndIf
        Next
        
        RowHeight = Y - PosY + 1.3
        
        DrawingMode(#PB_2DDrawing_Outlined)
        For c=1 To MarkDown()\Table()\Cols
          If CellBorder(Str(c))\Border
            Box_(CellBorder(Str(c))\X, PosY, CellBorder(Str(c))\Width, RowHeight, MarkDown()\Color\Front)
          EndIf
        Next
        
      Next
      
      MarkDown()\WrapPos = GadgetWidth(MarkDown()\CanvasNum) - MarkDown()\Margin\Right
      
    EndIf
    
    ProcedureReturn Y
  EndProcedure
  
  
  CompilerIf #Enable_DrawCanvas
    
    Procedure   DrawTextMD_()
  	  Define.i X, Y, Width, Height, LeftBorder, WrapPos, TextWidth, TextHeight, MsgHeight, Cols
  	  Define.i b, Indent, Level, Offset, OffSetX, OffSetY, maxCol, ImgSize
  	  Define.i c, OffsetList, NumWidth, ColWidth, TableWidth
  		Define.i FrontColor, BackColor, BorderColor, LinkColor
  		Define.s Text$, Num$, ColText$, Label$, Image$, File$

  		NewMap ListNum.i()
  		
  		X = MarkDown()\Size\X
  		Y = MarkDown()\Size\Y
  		
  		If MarkDown()\Size\Width = #PB_Default
  		  Width = MarkDown()\Required\Width
  		Else
  		  Width = MarkDown()\Size\Width
  		EndIf   
  		
  		If MarkDown()\Size\Height = #PB_Default
  		  Height = MarkDown()\Required\Height
  		Else
  		  Height = MarkDown()\Size\Height
  		EndIf
  		
  		MarkDown()\LeftBorder = 0
  		MarkDown()\WrapPos    = X + Width

		  ; _____ Colors _____
		  FrontColor  = MarkDown()\Color\Front
		  BackColor   = MarkDown()\Color\Back
		  LinkColor   = MarkDown()\Color\Link

			; _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  Box_(X, Y, Width, Height, MarkDown()\Color\Back)

      ;  _____ MarkDown _____
			ForEach MarkDown()\Items()
			  
			  DrawingFont(FontID(MarkDown()\Font\Normal))
			  
			  TextHeight = TextHeight_("X")
			  
			  Select MarkDown()\Items()\Type
			    Case #Code             ;{ Code block
			      
			      Y + (TextHeight / 4)
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      DrawingFont_(MarkDown()\Block()\Font)
			      
			      If SelectElement(MarkDown()\Block(), MarkDown()\Items()\Index)
			        ForEach MarkDown()\Block()\Row()
			          DrawText_(X, Y, MarkDown()\Block()\Row(), MarkDown()\Color\Code)
			          Y + MarkDown()\Items()\Height
			        Next
			      EndIf
			      
			      Y + (TextHeight / 4)
			      ;}
			    Case #Heading          ;{ Headings
			      If MarkDown()\Items()\ID : MarkDown()\HeadingID(MarkDown()\Items()\ID) = Y : EndIf
			      Y + (TextHeight / 4)
			      Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
			      Y + (TextHeight / 4)
			      ;}
			    Case #Image            ;{ Images
			      
			      If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
			        
			        ;{ Load Image
              Image$ = GetFilePart(MarkDown()\Image()\Source)
              File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)

              If FindMapElement(MarkDown()\ImageNum(),  Image$) = #False
                If AddMapElement(MarkDown()\ImageNum(), Image$) 
                  
                  If IsImage(MarkDown()\ImageNum()) = #False
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                  EndIf
    			        
                EndIf
              EndIf ;}

    	        If IsImage(MarkDown()\ImageNum())
   
    	          OffSet = (Width - ImageWidth(MarkDown()\ImageNum())) / 2
    	          
    	          Y + (TextHeight / 2)
    	          
    	          DrawingMode(#PB_2DDrawing_AlphaBlend)
    	          DrawImage_(ImageID(MarkDown()\ImageNum()), X + OffSet, Y)
    	          
    	          MarkDown()\Image()\X = X + OffSet
    	          MarkDown()\Image()\Y = Y
    	          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    	          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    	          
    	          Y + MarkDown()\Image()\Height
    	          
    	          If ListSize(MarkDown()\Items()\Words())
    	            
    	            Y + (TextHeight / 4)
    	            
    	            OffSetX = (MarkDown()\Image()\Width - MarkDown()\Items()\Width) / 2
    	            
    	            DrawingMode(#PB_2DDrawing_Transparent)
    	            Y = DrawRow_(MarkDown()\Image()\X + OffSetX, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())

    	          EndIf
    	          
    	          Y + (TextHeight / 2)
    	          
    	        ElseIf ListSize(MarkDown()\Items()\Words())
    	          
    	          OffSetX = (Width - MarkDown()\Items()\Width) / 2
    	          
                DrawingMode(#PB_2DDrawing_Transparent)
    	          Y = DrawRow_(X + OffSetX, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
               
    	        EndIf 
    	        
    	        If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
    	        
    	      EndIf
			      ;}
			    Case #Line             ;{ Horizontal rule  
			  
			      OffSetY = TextHeight / 2
			      
			      DrawingMode(#PB_2DDrawing_Default)
			      Box_(X, Y + OffSetY, Width, 2, MarkDown()\Color\Line)
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      Y + TextHeight
			      ;}
			    Case #DefinitionList   ;{ Definition list
			      
			      Y = DrawList_(MarkDown()\Items()\Index, #DefinitionList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Case #OrderedList      ;{ Ordered list
			      
            Y = DrawList_(MarkDown()\Items()\Index, #OrderedList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
            ;}
			    Case #TaskList         ;{ Task list
			      
            Y = DrawList_(MarkDown()\Items()\Index, #TaskList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
          Case #UnorderedList    ;{ Unordered list
            Y = DrawList_(MarkDown()\Items()\Index, #UnorderedList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
          Case #Glossary         ;{ Glossary
            Y = DrawList_(MarkDown()\Items()\Index, #Glossary, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote)
            ;}
          Case #Note             ;{ Note
            Y = DrawNote(MarkDown()\Items()\Index, X, Y, Width) 
            ;}
          Case #Paragraph        ;{ Paragraph
			       Y + (TextHeight / 2)
			      ;}
			    Case #Table            ;{ Table
			      Y = DrawTable_(MarkDown()\Items()\Index, X, Y, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Case #InsertTOC        ;{ Table of Contents
			      Y = DrawTOC(X, Y)
			      ;}
			    Default                ;{ Text

			      Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
			      ;}
			  EndSelect
			  
			  If MarkDown()\Items()\Type <> #OrderedList And MarkDown()\Items()\Type <> #UnorderedList
			    ClearMap(ListNum())
			  EndIf   
			  
			Next

  	EndProcedure

  CompilerEndIf    
  
  
	Procedure   Draw_(ScrollBar.i=#False)
	  Define.i X, Y, Width, Height, LeftBorder, WrapPos, TextWidth, TextHeight, MsgHeight, Cols
	  Define.i b, Indent, Level, Offset, OffSetX, OffSetY, maxCol, ImgSize
	  Define.i c, OffsetList, NumWidth, ColWidth, TableWidth
		Define.i FrontColor, BackColor, BorderColor, LinkColor
		Define.s Text$, Num$, ColText$, Label$, Image$, File$

		If MarkDown()\Hide : ProcedureReturn #False : EndIf 
		
		NewMap ListNum.i()
		
		X = MarkDown()\Margin\Left
		Y = MarkDown()\Margin\Top

		Width   = MarkDown()\Area\Width  - (MarkDown()\Margin\Left + MarkDown()\Margin\Right)
		Height  = MarkDown()\Area\Height - (MarkDown()\Margin\Top  + MarkDown()\Margin\Bottom)
		
		CompilerIf #Enable_Requester
		  
  		If MarkDown()\Type = #Requester
  		  
  		  Height - 33
  		  
  		  MsgHeight = GadgetHeight(MarkDown()\CanvasNum) - 33
  		  
  		  If IsImage(MarkDown()\Requester\Image\Num)
  		    Width - (MarkDown()\Requester\Image\Width + MarkDown()\Requester\Padding)
  		    X + MarkDown()\Requester\Image\Width + MarkDown()\Requester\Padding
  		  EndIf  
  		  
  		EndIf
  		
  	CompilerEndIf
  	
		MarkDown()\LeftBorder = X
		MarkDown()\WrapPos    = MarkDown()\Area\Width - MarkDown()\Margin\Right
		
		If MarkDown()\VScroll\Hide
		  MarkDown()\ScrollOffsetY = 0
		Else  
		  MarkDown()\ScrollOffsetY = MarkDown()\VScroll\Pos
		EndIf   
		
		If MarkDown()\HScroll\Hide
		  MarkDown()\ScrollOffsetX = 0
		Else  
		  MarkDown()\ScrollOffsetX = MarkDown()\HScroll\Pos
		EndIf
		
		If StartDrawing(CanvasOutput(MarkDown()\CanvasNum))

		  X - MarkDown()\ScrollOffsetX
		  Y - MarkDown()\ScrollOffsetY
		  
		  ;{ _____ Colors _____
		  FrontColor  = MarkDown()\Color\Front
		  BackColor   = MarkDown()\Color\Back
		  BorderColor = MarkDown()\Color\Border
		  LinkColor   = MarkDown()\Color\Link
		  
		  If MarkDown()\Disable
		    FrontColor  = MarkDown()\Color\DisableFront
		    LinkColor   = MarkDown()\Color\DisableFront
		    BackColor   = MarkDown()\Color\DisableBack
		    BorderColor = MarkDown()\Color\DisableFront ; or MarkDown()\Color\DisableBack
		  EndIf ;} 
		  
		  ;{ _____ Background _____
		  If MarkDown()\Type = #Requester
		    Box_(0, 0, MarkDown()\Area\Width, MarkDown()\Area\Height - 30, BackColor)
		  Else
		    Box_(0, 0, MarkDown()\Area\Width, MarkDown()\Area\Height, BackColor) ; BackColor
		  EndIf 
		  ;}
		  
		  ClipOutput_(MarkDown()\Area\X, MarkDown()\Area\Y, MarkDown()\Area\Width, MarkDown()\Area\Height)
		 
		  DrawingFont(FontID(MarkDown()\Font\Normal))
			MarkDown()\ScrollV = TextHeight("X")
		  
			ForEach MarkDown()\Items()
			  
			  DrawingFont(FontID(MarkDown()\Font\Normal))
			  
			  TextHeight = TextHeight("X")
			  
			  Select MarkDown()\Items()\Type
			    Case #Code             ;{ Code block
			      
			      Y + (TextHeight / 4)
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      DrawingFont_(MarkDown()\Block()\Font)
			      
			      If SelectElement(MarkDown()\Block(), MarkDown()\Items()\Index)
			        ForEach MarkDown()\Block()\Row()
			          DrawText(X, Y, MarkDown()\Block()\Row(), MarkDown()\Color\Code)
			          Y + MarkDown()\Items()\Height
			        Next
			      EndIf
			      
			      Y + (TextHeight / 4)
			      ;}
			    Case #Heading          ;{ Headings
			      If MarkDown()\Items()\ID : MarkDown()\HeadingID(MarkDown()\Items()\ID) = Y : EndIf
			      Y + (TextHeight / 4)
			      Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
			      Y + (TextHeight / 4)
			      ;}
			    Case #Image            ;{ Images
			      
			      If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
			        
			        ;{ Load Image
              Image$ = GetFilePart(MarkDown()\Image()\Source)
              File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)

              If FindMapElement(MarkDown()\ImageNum(),  Image$) = #False
                If AddMapElement(MarkDown()\ImageNum(), Image$) 
                  
                  If IsImage(MarkDown()\ImageNum()) = #False
                    MarkDown()\ImageNum() = LoadImage(#PB_Any, File$)
                  EndIf
    			        
                EndIf
              EndIf ;}

    	        If IsImage(MarkDown()\ImageNum())
   
    	          OffSet = (Width - ImageWidth(MarkDown()\ImageNum())) / 2
    	          
    	          Y + (TextHeight / 2)
    	          
    	          DrawingMode(#PB_2DDrawing_AlphaBlend)
    	          DrawImage(ImageID(MarkDown()\ImageNum()), X + OffSet, Y)
    	          
    	          MarkDown()\Image()\X = X + OffSet
    	          MarkDown()\Image()\Y = Y
    	          MarkDown()\Image()\Width  = ImageWidth(MarkDown()\ImageNum())
    	          MarkDown()\Image()\Height = ImageHeight(MarkDown()\ImageNum())
    	          
    	          Y + MarkDown()\Image()\Height
    	          
    	          If ListSize(MarkDown()\Items()\Words())
    	            
    	            Y + (TextHeight / 4)
    	            
    	            OffSetX = (MarkDown()\Image()\Width - MarkDown()\Items()\Width) / 2
    	            
    	            DrawingMode(#PB_2DDrawing_Transparent)
    	            Y = DrawRow_(MarkDown()\Image()\X + OffSetX, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())

    	          EndIf
    	          
    	          Y + (TextHeight / 2)
    	          
    	        ElseIf ListSize(MarkDown()\Items()\Words())
    	          
    	          OffSetX = (Width - MarkDown()\Items()\Width) / 2
    	          
                DrawingMode(#PB_2DDrawing_Transparent)
    	          Y = DrawRow_(X + OffSetX, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
               
    	        EndIf 
    	        
    	        ;If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
    	        
    	      EndIf
			      ;}
			    Case #Line             ;{ Horizontal rule  
			  
			      OffSetY = TextHeight / 2
			      
			      DrawingMode(#PB_2DDrawing_Default)
			      Box(X, Y + OffSetY, Width, 2, MarkDown()\Color\Line)
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      Y + TextHeight
			      ;}
			    Case #DefinitionList   ;{ Definition list
			      
			      Y = DrawList_(MarkDown()\Items()\Index, #DefinitionList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Case #OrderedList      ;{ Ordered list
			      
            Y = DrawList_(MarkDown()\Items()\Index, #OrderedList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
            ;}
			    Case #TaskList         ;{ Task list
			      
            Y = DrawList_(MarkDown()\Items()\Index, #TaskList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
          Case #UnorderedList    ;{ Unordered list
            Y = DrawList_(MarkDown()\Items()\Index, #UnorderedList, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
          Case #Glossary         ;{ Glossary
            Y = DrawList_(MarkDown()\Items()\Index, #Glossary, ListNum(), X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote)
            ;}
          Case #Note             ;{ Note
            Y = DrawNote(MarkDown()\Items()\Index, X, Y, Width) 
            ;}
          Case #Paragraph        ;{ Paragraph
			       Y + (TextHeight / 2)
			      ;}
			    Case #Table            ;{ Table
			      Y = DrawTable_(MarkDown()\Items()\Index, X, Y, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Case #InsertTOC        ;{ Table of Contents
			      Y = DrawTOC(X, Y)
			      ;}
			    Default                ;{ Text

			      Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
			      ;}
			  EndSelect
			  
			  If MarkDown()\Items()\Type <> #OrderedList And MarkDown()\Items()\Type <> #UnorderedList
			    ClearMap(ListNum())
			  EndIf   
			  
			Next
			
			If MarkDown()\Type = #Gadget And ListSize(MarkDown()\Footnote()) ;{ Footnotes
			  
			  DrawingMode(#PB_2DDrawing_Transparent)
			  
			  X = MarkDown()\LeftBorder
			  MarkDown()\WrapHeight = 0

			  DrawingFont(FontID(MarkDown()\Font\Normal))
			  TextHeight = TextHeight("Abc")
			  Y + (TextHeight / 2)
			  
			  DrawingFont(FontID(MarkDown()\Font\FootText))
			  TextHeight = TextHeight("Abc")
			  
			  OffSetY = TextHeight / 2
			  Line(X, Y + OffSetY, Width / 3, 1, MarkDown()\Color\Line)

			  Y + TextHeight
			  
			  ForEach MarkDown()\Footnote()
			    
			    DrawingFont(FontID(MarkDown()\Font\FootNote))
			    
			    Label$ = MarkDown()\FootNote()\Label
          
			    X = MarkDown()\LeftBorder
          X = DrawText(X, Y, Label$ + " ", MarkDown()\Color\Hint)
          
          If FindMapElement(MarkDown()\FootLabel(), Label$)
            Y = DrawRow_(X, Y, MarkDown()\FootLabel()\Width, MarkDown()\FootLabel()\Height, #False, MarkDown()\FootLabel()\Words())
          EndIf
        
        Next
			  ;}
			EndIf  
      
			UnclipOutput_()
			
			CompilerIf #Enable_Requester
			  
			  If MarkDown()\Type = #Requester
			  
  			  If IsImage(MarkDown()\Requester\Image\Num)
  			    OffsetY = (MsgHeight - MarkDown()\Requester\Image\Height) / 2
      		  DrawingMode(#PB_2DDrawing_AlphaBlend)
      		  DrawImage_(ImageID(MarkDown()\Requester\Image\Num), MarkDown()\Margin\Left, OffsetY, MarkDown()\Requester\Image\Width, MarkDown()\Requester\Image\Height)
  			  EndIf  
  			  
  			  DrawingFont(FontID(MarkDown()\Font\Normal))
  			  
  			  MarkDown()\Requester\ButtonY = MsgHeight + 6
  			  
  			  DrawingMode(#PB_2DDrawing_Default)
		      Box(0, MsgHeight, GadgetWidth(MarkDown()\CanvasNum), 40, MarkDown()\Color\Gadget) ; 
		      
		      If MarkDown()\Requester\UserButtons
		        
		        X = (GadgetWidth(MarkDown()\CanvasNum) - MarkDown()\Requester\ButtonsWidth) / 2

		        For b=1 To CountString(MarkDown()\Requester\UserButtons, "|") + 1
		          
		          Label$ = StringField(MarkDown()\Requester\UserButtons, b, "|")
		          
		          If FindMapElement(MarkDown()\Requester\Button(), Label$)
		            Button_(Label$, X, MarkDown()\Requester\ButtonY)
      			    X + MarkDown()\Requester\Button()\Width + 7
		          EndIf   
		          
		        Next
		        
		      Else
		        
    			  If MarkDown()\Flags & #YesNo ;{ Buttons
      			  X = (GadgetWidth(MarkDown()\CanvasNum) - MarkDown()\Requester\ButtonsWidth) / 2
      			  Button_("Yes", X, MarkDown()\Requester\ButtonY)
      			  X + MarkDown()\Requester\Button("Yes")\Width + 7
      			  Button_("No", X, MarkDown()\Requester\ButtonY)
      			ElseIf MarkDown()\Flags & #YesNoCancel
      			  X = 7
      			  Button_("Yes", X, MarkDown()\Requester\ButtonY)
      			  X + MarkDown()\Requester\Button("Yes")\Width + 7
      			  Button_("No", X, MarkDown()\Requester\ButtonY)
      			  X = GadgetWidth(MarkDown()\CanvasNum) - MarkDown()\Requester\Button("Cancel")\Width - 7
      			  Button_("Cancel", X, MarkDown()\Requester\ButtonY)
      			Else
      			  X = (GadgetWidth(MarkDown()\CanvasNum) - MarkDown()\Requester\ButtonsWidth) / 2
      			  Button_("OK", X, MarkDown()\Requester\ButtonY)
      			EndIf
      			
      		EndIf
      		
    		EndIf	;}
			  
			CompilerEndIf  
			
			
			
			;{ _____ Border ____
			If MarkDown()\Flags & #Borderless = #False
			  DrawingMode(#PB_2DDrawing_Outlined)
			  Box_(0, 0, GadgetWidth(MarkDown()\CanvasNum), GadgetHeight(MarkDown()\CanvasNum), BorderColor)
			  If MarkDown()\Type = #Requester
			    Box_(0, 0, GadgetWidth(MarkDown()\CanvasNum), GadgetHeight(MarkDown()\CanvasNum) - 33, BorderColor)
			  EndIf   
			EndIf ;}

			StopDrawing()
		EndIf

		DrawScrollBar_(ScrollBar)
		
	EndProcedure
	
	
	;- ============================================================================
	;-   Module - Tools
  ;- ============================================================================	
	
	Procedure   GotoHeading_(ID.s)
    
	  If FindMapElement(MarkDown()\HeadingID(), ID)
	    
	    MarkDown()\ScrollOffsetY = MarkDown()\HeadingID()
	    
      SetThumbPosY_(MarkDown()\ScrollOffsetY)
 
      Draw_(#Vertical)
    EndIf
    
  EndProcedure  
  
  CompilerIf #Enable_Tooltips
    
    Procedure.i AddMouseEvents_(Window.i, Gadget.i=#PB_Default, Flags.i=#MouseEvents)
    
      If IsWindow(Window)
        
        If FindMapElement(MouseEvent(), Str(Window)) = #False
          AddMapElement(MouseEvent(), Str(Window))
        EndIf 
  
        MouseEvent()\Window\Num = Window
        
        If IsGadget(Gadget)
          MouseEvent()\Gadget(Str(Gadget))\Num = Gadget
        Else
          MouseEvent()\Gadget(Str(Gadget))\Num = #PB_Default
        EndIf
        
        MouseEvent()\Flags = Flags
        
        ; Code by mk-soft
        AddWindowTimer(MouseEvent()\Window\Num, #MouseEventTimer, 100)
  
        ProcedureReturn #True
      EndIf
      
    EndProcedure
    
    Procedure.i GetMouseEventAttribute_(Window.i, Attribute.i, Gadget.i=#PB_Default)
      
      If FindMapElement(MouseEvent(), Str(Window))
        
        If Gadget = #PB_Default Or MouseEvent()\lastGadget = Gadget
          
          Select Attribute
            Case #MouseX
              ProcedureReturn MouseEvent()\Gadget(Str(Gadget))\MouseX
            Case #MouseY
              ProcedureReturn MouseEvent()\Gadget(Str(Gadget))\MouseY
            Case #Gadget
              ProcedureReturn MouseEvent()\lastGadget
          EndSelect
  
        EndIf  
        
      EndIf
      
      ProcedureReturn #PB_Default
    EndProcedure
    
    Procedure   TooltipPosition_(dX.i, dY.i) ; uses DPI
  	  Define.i gX, gY, wX, wY, gWidth, gHeight, wWidth, wHeight, cWidth, cHeight, PosX, PosY, Reverse
  	  
  	  If IsGadget(ToolTips()\Gadget)
    	  wX = dpiX(GadgetX(ToolTips()\Gadget, #PB_Gadget_ScreenCoordinate))
    	  wY = dpiY(GadgetY(ToolTips()\Gadget, #PB_Gadget_ScreenCoordinate))
    	  gX = dpiX(GadgetX(ToolTips()\Gadget, #PB_Gadget_WindowCoordinate))
    	  gY = dpiY(GadgetY(ToolTips()\Gadget, #PB_Gadget_WindowCoordinate))
    	  gWidth  = dpiX(GadgetWidth(ToolTips()\Gadget))
    	  gHeight = dpiY(GadgetHeight(ToolTips()\Gadget)) 
    	EndIf 
    	
    	If IsWindow(ToolTips()\Window)
    	  wWidth  = dpiX(WindowWidth(ToolTips()\Window))
    	  wHeight = dpiY(WindowHeight(ToolTips()\Window))
    	EndIf
    	
    	If IsGadget(ToolTips()\CanvasNum)
    	  cWidth  = dpiX(GadgetWidth(ToolTips()\CanvasNum))
    	  cHeight = dpiY(GadgetHeight(ToolTips()\CanvasNum))
    	EndIf   
    	
    	PosX = dX + gX + cWidth
    	PosY = dY + gY
    	
    	If PosX < wWidth
    	  ToolTips()\PosX = dX + wX
    	Else
    	  ToolTips()\PosX = dX + wX - cWidth
    	  Reverse = #True
    	EndIf

    	If PosY - cHeight  > 0 
    	  ToolTips()\PosY = dY + wY - cHeight  + dpiY(1)
    	  ToolTips()\PosX + dpiX(2)
    	ElseIf PosY + dpiY(GadgetHeight(ToolTips()\CanvasNum))  > wHeight
    	  ToolTips()\PosY = dY + wY - cHeight  + dpiY(1)
    	  ToolTips()\PosX + dpiX(2)
    	Else
    	  ToolTips()\PosY = dY + wY + dpiY(2)
    	  If Reverse = #False
    	    ToolTips()\PosX + dpiX(8)
    	  EndIf
    	EndIf
    	
  	EndProcedure
    
  CompilerEndIf
  
  CompilerIf #Enable_HelpWindow

	  Procedure   AddToHistory_(Index.i)
	    
	    LastElement(Help\History())
      If AddElement(Help\History())
        Help\History() = Index
      EndIf   
      
	  EndProcedure  
	  
	  Procedure   EnableSearch_(State.i)
	    
	    If State
	      SetGadgetAttribute(Help\HomeNum, #PB_Button_Image, ImageID(Help\Image\Close))
	      CompilerIf Defined(ListView, #PB_Module)
	        ListView::Hide(Help\ListNum, #False)
	      CompilerElse  
	        HideGadget(Help\ListNum, #False)
	      CompilerEndIf  
        HideGadget(Help\TreeNum, #True)
        HideGadget(Help\PrevNum, #True)
        HideGadget(Help\NextNum, #True)
        ResizeGadget(Help\InputNum, #PB_Ignore, #PB_Ignore, 147, #PB_Ignore)
        ResizeGadget(Help\SearchNum, 190, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      Else
        SetGadgetAttribute(Help\HomeNum, #PB_Button_Image, ImageID(Help\Image\GoHome))
        CompilerIf Defined(ListView, #PB_Module)
          ListView::Hide(Help\ListNum, #True)
        CompilerElse    
          HideGadget(Help\ListNum, #True)
        CompilerEndIf    
        HideGadget(Help\TreeNum, #False)
        HideGadget(Help\PrevNum, #False)
        HideGadget(Help\NextNum, #False)
        ResizeGadget(Help\InputNum, #PB_Ignore, #PB_Ignore, 92, #PB_Ignore)
        ResizeGadget(Help\SearchNum, 135, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndIf
      
	  EndProcedure
	  
	  Procedure.i Search_(String.s, Map Keywords.Keywords_Structure(), List Found.s(),Flags.i=#False)
	    Define.i Index, LastIndex
	    
	    ClearList(Found())
	    
	    NewList Sort.Help_Sort_Structure()
	    
	    CompilerIf Defined(ListView, #PB_Module)
	      ListView::ClearItems(Help\ListNum)
	    CompilerElse
	      ClearGadgetItems(Help\ListNum)
	    CompilerEndIf
	    
	    If Flags & #KeywordsOnly = #False
	      
	      String = LCase(Trim(String))
	      
	      If Left(String, 1) = "*" And Right(String, 1) = "*"
	        
	        String = Trim(String, "*")
 
	        ForEach Help\Item() ;{ Search Topic
	          If CountString(LCase(Help\Item()\Titel), String)
	            Index = ListIndex(Help\Item())
  	          If AddElement(Sort())
                Sort()\Index = Index
                Sort()\Topic = Help\Item()\Titel
              EndIf
            EndIf 
	        Next ;}
	        
	        ForEach Keywords()  ;{ Search  Keywords
	          If CountString(LCase(MapKey(Keywords())), String)
	            If AddElement(Found()) : Found() = MapKey(Keywords()) : EndIf
              ForEach Keywords()\Label()
                If FindMapElement(Help\Label(), Keywords()\Label()\Name)
                  If SelectElement(Help\Item(), Help\Label())
                    Index = ListIndex(Help\Item())
                    If AddElement(Sort())
                      Sort()\Index = Index
                      Sort()\Topic = Help\Item()\Titel
                    EndIf
                  EndIf
                EndIf 
              Next  
            EndIf  
          Next ;}
	        
        ElseIf Left(String,  1) = "*"
          
          String = LTrim(String, "*")
          
          ForEach Help\Item() ;{ Search Topic
            If Right(LCase(Help\Item()\Titel), Len(String)) = String
              Index = ListIndex(Help\Item())
  	          If AddElement(Sort())
                Sort()\Index = Index
                Sort()\Topic = Help\Item()\Titel
              EndIf
            EndIf
          Next ;}
          
          ForEach Keywords()  ;{ Search  Keywords
            If Right(LCase(MapKey(Keywords())), Len(String)) = String
              If AddElement(Found()) : Found() = MapKey(Keywords()) : EndIf
              ForEach Keywords()\Label()
                If FindMapElement(Help\Label(), Keywords()\Label()\Name)
                  If SelectElement(Help\Item(), Help\Label())
                    Index = ListIndex(Help\Item())
                    If AddElement(Sort())
                      Sort()\Index = Index
                      Sort()\Topic = Help\Item()\Titel
                    EndIf
                  EndIf
                EndIf 
              Next  
            EndIf  
          Next ;}
        
        ElseIf Right(String, 1) = "*"
          
          String = RTrim(String, "*")
          
          ForEach Help\Item() ;{ Search Topic
            If Left(LCase(Help\Item()\Titel), Len(String)) = String
              Index = ListIndex(Help\Item())
  	          If AddElement(Sort())
                Sort()\Index = Index
                Sort()\Topic = Help\Item()\Titel
              EndIf
            EndIf
          Next ;}  
          
          ForEach Keywords()  ;{ Search  Keywords
            If Left(LCase(MapKey(Keywords())), Len(String)) = String
              If AddElement(Found()) : Found() = MapKey(Keywords()) : EndIf
              ForEach Keywords()\Label()
                If FindMapElement(Help\Label(), Keywords()\Label()\Name)
                  If SelectElement(Help\Item(), Help\Label())
                    Index = ListIndex(Help\Item())
                    If AddElement(Sort())
                      Sort()\Index = Index
                      Sort()\Topic = Help\Item()\Titel
                    EndIf
                  EndIf
                EndIf 
              Next  
            EndIf  
          Next ;}
          
        Else
          
          ForEach Help\Item() ;{ Search Topic
            If Left(LCase(Help\Item()\Titel), Len(String)) = String
              Index = ListIndex(Help\Item())
              If AddElement(Sort())
                Sort()\Index = Index
                Sort()\Topic = Help\Item()\Titel
              EndIf
            EndIf
          Next ;}
          
          ForEach Keywords() ;{ Search  Keywords
            If LCase(MapKey(Keywords())) = String
              If AddElement(Found()) : Found() = MapKey(Keywords()) : EndIf
              ForEach Keywords()\Label()
                If FindMapElement(Help\Label(), Keywords()\Label()\Name)
                  If SelectElement(Help\Item(), Help\Label())
                    Index = ListIndex(Help\Item())
                    If AddElement(Sort())
                      Sort()\Index = Index
                      Sort()\Topic = Help\Item()\Titel
                    EndIf
                  EndIf
                EndIf 
              Next  
            EndIf  
          Next ;}
          
        EndIf
 
	    EndIf
	    
	    SortStructuredList(Sort(), #PB_Sort_Ascending, OffsetOf(Help_Sort_Structure\Index), TypeOf(Help_Sort_Structure\Index))
	    
	    LastIndex = -1
	    
	    ForEach Sort()
	      If Sort()\Index = LastIndex : DeleteElement(Sort()) : EndIf
	      LastIndex = Sort()\Index
	    Next  
	    
      SortStructuredList(Sort(), #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf(Help_Sort_Structure\Topic), TypeOf(Help_Sort_Structure\Topic))
      
      ForEach Sort()
        CompilerIf Defined(ListView, #PB_Module)
          ListView::AddItem(Help\ListNum, ListIndex(Sort()), Sort()\Topic)
          ListView::SetItemData(Help\ListNum, ListIndex(Sort()), Sort()\Index)
  	    CompilerElse
          AddGadgetItem(Help\ListNum, ListIndex(Sort()), Sort()\Topic)
          SetGadgetItemData(Help\ListNum, ListIndex(Sort()), Sort()\Index)
  	    CompilerEndIf
      Next
      
      EnableSearch_(#True)
      Help\Search = #True
      
      ProcedureReturn ListSize(Sort())
	  EndProcedure  
	  
  CompilerEndIf  
  
  
	;- ============================================================================
	;-   Module - Events
  ;- ============================================================================	
  
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()
      
      ForEach MarkDown()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          MarkDown()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        If ModuleEx::ThemeGUI\ScrollBar : MarkDown()\ScrollBar\Flags = ModuleEx::ThemeGUI\ScrollBar : EndIf 
        
        MarkDown()\Color\Front               = ModuleEx::ThemeGUI\FrontColor
				MarkDown()\Color\Back                = ModuleEx::ThemeGUI\BackColor
				MarkDown()\Color\Border              = ModuleEx::ThemeGUI\BorderColor
				MarkDown()\Color\Gadget              = ModuleEx::ThemeGUI\GadgetColor
				MarkDown()\Color\Button              = ModuleEx::ThemeGUI\Button\BackColor
			  MarkDown()\Color\Focus               = ModuleEx::ThemeGUI\Focus\BackColor
				MarkDown()\Color\DisableFront        = ModuleEx::ThemeGUI\Disable\FrontColor
		    MarkDown()\Color\DisableBack         = ModuleEx::ThemeGUI\Disable\BackColor
		    
		    MarkDown()\ScrollBar\Color\Front     = ModuleEx::ThemeGUI\FrontColor
  			MarkDown()\ScrollBar\Color\Back      = ModuleEx::ThemeGUI\BackColor
  			MarkDown()\ScrollBar\Color\Border    = ModuleEx::ThemeGUI\BorderColor
  			MarkDown()\ScrollBar\Color\Gadget    = ModuleEx::ThemeGUI\GadgetColor
  			MarkDown()\ScrollBar\Color\Focus     = ModuleEx::ThemeGUI\FocusBack
        MarkDown()\ScrollBar\Color\Button    = ModuleEx::ThemeGUI\Button\BackColor
        MarkDown()\ScrollBar\Color\ScrollBar = ModuleEx::ThemeGUI\ScrollbarColor
		    
        Draw_(#Horizontal|#Vertical)
      Next
      
    EndProcedure
    
  CompilerEndIf 
  
  
  Procedure _AutoScroll()
    Define.i X, Y
    
    LockMutex(Mutex)
    
    ForEach MarkDown()

      If MarkDown()\HScroll\Timer ;{ Horizontal Scrollbar
        
        If MarkDown()\HScroll\Delay
          MarkDown()\HScroll\Delay - 1
          Continue
        EndIf  
        
        Select MarkDown()\HScroll\Timer
          Case #Left
            SetThumbPosX_(MarkDown()\HScroll\Pos - 1 - MarkDown()\ScrollH)
          Case #Right
            SetThumbPosX_(MarkDown()\HScroll\Pos + 1 + MarkDown()\ScrollH)
        EndSelect
        
        Draw_(#Horizontal)
   			;}
      EndIf   
      
      If MarkDown()\VScroll\Timer ;{ Vertical Scrollbar
        
        If MarkDown()\VScroll\Delay
          MarkDown()\VScroll\Delay - 1
          Continue
        EndIf  
        
        Select MarkDown()\VScroll\Timer
          Case #Up
            SetThumbPosY_(MarkDown()\VScroll\Pos - MarkDown()\ScrollV)
          Case #Down
            SetThumbPosY_(MarkDown()\VScroll\Pos + MarkDown()\ScrollV)
  			EndSelect
  			
  			Draw_(#Vertical)
  			;}
      EndIf   
      
    Next
    
    UnlockMutex(Mutex)
    
  EndProcedure
  
  
	Procedure _RightClickHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			If IsWindow(MarkDown()\Window\Num) And IsMenu(MarkDown()\PopUpNum)
				DisplayPopupMenu(MarkDown()\PopUpNum, WindowID(MarkDown()\Window\Num))
			EndIf

		EndIf

	EndProcedure

	Procedure _LeftButtonDownHandler()
		Define.i X, Y, dX, dY
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			dX = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseX)
			dY = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseY)
			
			X = DesktopUnscaledX(dX)
			Y = DesktopUnscaledY(dY)
			

		  ;{ Horizontal Scrollbar
		  If MarkDown()\HScroll\Hide = #False
		    
		    If dY > dpiX(MarkDown()\HScroll\Y) And dY < dpiX(MarkDown()\HScroll\Y + MarkDown()\HScroll\Height)
			    If dX > dpiX(MarkDown()\HScroll\X) And dX < dpiX(MarkDown()\HScroll\X + MarkDown()\HScroll\Width)
		    
    			  MarkDown()\HScroll\CursorPos = #PB_Default
    			  
    			  If MarkDown()\HScroll\Focus
    			    
      			  If dX > dpiX(MarkDown()\HScroll\Buttons\bX) And  dX < dpiX(MarkDown()\HScroll\Buttons\bX + MarkDown()\HScroll\Buttons\Width)
      			    
      			    ; --- Backwards Button ---
      			    If MarkDown()\HScroll\Buttons\bState <> #Click
      			      MarkDown()\HScroll\Delay = MarkDown()\Scrollbar\TimerDelay
      			      MarkDown()\HScroll\Timer = #Left
      			      MarkDown()\HScroll\Buttons\bState = #Click
      			      DrawButton_(#Horizontal, #Backwards)
      			    EndIf
      			    
      			  ElseIf dX > dpiX(MarkDown()\HScroll\Buttons\fX) And  dX < dpiX(MarkDown()\HScroll\Buttons\fX + MarkDown()\HScroll\Buttons\Width)
      			    
      			    ; --- Forwards Button ---
      			    If MarkDown()\HScroll\Buttons\fState <> #Click
      			      MarkDown()\HScroll\Delay = MarkDown()\Scrollbar\TimerDelay
      			      MarkDown()\HScroll\Timer = #Right
      			      MarkDown()\HScroll\Buttons\fState = #Click
      			      DrawButton_(#Horizontal, #Forwards)
      			    EndIf
      			    
      			  ElseIf  dX > dpiX(MarkDown()\HScroll\Thumb\X) And dX < dpiX(MarkDown()\HScroll\Thumb\X + MarkDown()\HScroll\Thumb\Width)
      			    
      			    ; --- Thumb Button ---
      			    If MarkDown()\HScroll\Thumb\State <> #Click
      			      MarkDown()\HScroll\Thumb\State = #Click
      			      MarkDown()\HScroll\CursorPos = X
      			      Draw_(#Horizontal)
      			    EndIf
    			    
      			  EndIf
      			  
      			EndIf
      			
      			ProcedureReturn #True
      		EndIf
      	EndIf	
  			
  		EndIf ;}

		  ;{ Vertical Scrollbar
		  If MarkDown()\VScroll\Hide = #False
		    
		    If dX > dpiX(MarkDown()\VScroll\X) And dX < dpiX(MarkDown()\VScroll\X + MarkDown()\VScroll\Width)
			    If dY > dpiY(MarkDown()\VScroll\Y) And dY < dpiY(MarkDown()\VScroll\Y + MarkDown()\VScroll\Height)
		    
    			  MarkDown()\VScroll\CursorPos = #PB_Default
    			  
    			  If MarkDown()\VScroll\Focus
    			    
    			    If dY > dpiY(MarkDown()\VScroll\Buttons\bY) And dY < dpiY(MarkDown()\VScroll\Buttons\bY + MarkDown()\VScroll\Buttons\Height)
    
    			      If MarkDown()\VScroll\Buttons\bState <> #Click
    			        ; --- Backwards Button ---
      			      MarkDown()\VScroll\Delay = MarkDown()\Scrollbar\TimerDelay
      			      MarkDown()\VScroll\Timer = #Up
      			      MarkDown()\VScroll\Buttons\bState = #Click
      			      DrawButton_(#Vertical, #Backwards)
      			    EndIf
      			    
    			    ElseIf dY > dpiY(MarkDown()\VScroll\Buttons\fY) And dY < dpiY(MarkDown()\VScroll\Buttons\fY + MarkDown()\VScroll\Buttons\Height)
    			      
    			      ; --- Forwards Button ---
      			    If MarkDown()\VScroll\Buttons\fState <> #Click
      			      MarkDown()\VScroll\Delay = MarkDown()\Scrollbar\TimerDelay
      			      MarkDown()\VScroll\Timer = #Down
      			      MarkDown()\VScroll\Buttons\fState = #Click
      			      DrawButton_(#Vertical, #Forwards)
      			    EndIf
    			      
    			    ElseIf  dY > dpiY(MarkDown()\VScroll\Thumb\Y) And dY < dpiY(MarkDown()\VScroll\Thumb\Y + MarkDown()\VScroll\Thumb\Height)
    			      
    			      ; --- Thumb Button ---
      			    If MarkDown()\VScroll\Thumb\State <> #Click
      			      MarkDown()\VScroll\Thumb\State = #Click
      			      MarkDown()\VScroll\CursorPos = Y
      			      Draw_(#Vertical)
      			    EndIf
    			      
    			    EndIf  
    
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf
    		EndIf
    		
			EndIf ;}
			
			
			ForEach MarkDown()\Link() ;{ Click link
			  If dY >= dpiY(MarkDown()\Link()\Y) And dY <= dpiY(MarkDown()\Link()\Y + MarkDown()\Link()\Height) 
			    If dX >= dpiX(MarkDown()\Link()\X) And dX <= dpiX(MarkDown()\Link()\X + MarkDown()\Link()\Width)
			      MarkDown()\Link()\State = #True
			      Draw_()
  			    ProcedureReturn #True
  			  EndIf
			  EndIf ;}
			Next  
			
			CompilerIf #Enable_Requester
		  
		    ForEach MarkDown()\Requester\Button() ;{ Click Button
		      
		      If Not MarkDown()\Requester\Button()\Visible : Continue : EndIf
		      
		      If dY >= dpiY(MarkDown()\Requester\ButtonY) And dY <= dpiY(MarkDown()\Requester\ButtonY + #ButtonHeight)  
    			  If dX >= dpiX(MarkDown()\Requester\Button()\X) And dX <= dpiX(MarkDown()\Requester\Button()\X + MarkDown()\Requester\Button()\Width)
    			    If MarkDown()\Requester\Button()\State <> #Click
    			      MarkDown()\Requester\Button()\State = #Click
    			      Draw_()
    			    EndIf
  			      ProcedureReturn #True 
    			  EndIf
    			EndIf 
          ;}
  			Next 
  			
  		CompilerEndIf
			
		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, Y, dX, dY, Angle
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			dX = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseX)
			dY = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseY)
			
			X = DesktopUnscaledX(dX)
			Y = DesktopUnscaledY(dY)
			
		  ;{ Horizontal Scrollbar
		  If MarkDown()\HScroll\Hide = #False
		    
		    If dY > dpiY(MarkDown()\HScroll\Y) And dY < dpiY(MarkDown()\HScroll\Y + MarkDown()\HScroll\Height)
			    If dX > dpiX(MarkDown()\HScroll\X) And dX < dpiX(MarkDown()\HScroll\X + MarkDown()\HScroll\Width)
		    
    			  MarkDown()\HScroll\CursorPos = #PB_Default
    			  MarkDown()\HScroll\Timer     = #False
    			  
    			  If MarkDown()\HScroll\Focus
    			    
      			  If dX > dpiX(MarkDown()\HScroll\Buttons\bX) And  dX < dpiX(MarkDown()\HScroll\Buttons\bX + MarkDown()\HScroll\Buttons\Width)
      			    
      			    ; --- Backwards Button ---
      			    SetThumbPosX_(MarkDown()\HScroll\Pos - 1)
      			   
      			    Draw_(#Horizontal)

      			  ElseIf dX > dpiX(MarkDown()\HScroll\Buttons\fX) And  dX < dpiX(MarkDown()\HScroll\Buttons\fX + MarkDown()\HScroll\Buttons\Width)
      			    
      			    ; --- Forwards Button ---
      			    SetThumbPosX_(MarkDown()\HScroll\Pos + 1)
      			    
      			    Draw_(#Horizontal)

      			  ElseIf dX > dpiX(MarkDown()\HScroll\Area\X) And dX < dpiX(MarkDown()\HScroll\Thumb\X)
      			    
      			    ; --- Page left ---
      			    SetThumbPosX_(MarkDown()\HScroll\Pos - MarkDown()\HScroll\PageLength)
      			    
      			    Draw_(#Horizontal)

      			  ElseIf dX > dpiX(MarkDown()\HScroll\Thumb\X + MarkDown()\HScroll\Thumb\Width) And dX < dpiX(MarkDown()\HScroll\Area\X + MarkDown()\HScroll\Area\Width)
      			    
      			    ; --- Page right ---
      			    SetThumbPosX_(MarkDown()\HScroll\Pos + MarkDown()\HScroll\PageLength)
      			 
      			    Draw_(#Horizontal)
      			    
      			  EndIf
        			
      			EndIf 
      			
      			ProcedureReturn #True
      		EndIf
      	EndIf
      	
  		EndIf ;}
 
      ;{ Vertical Scrollbar
      If MarkDown()\VScroll\Hide = #False
        
        If dX > dpiX(MarkDown()\VScroll\X) And dX < dpiX(MarkDown()\VScroll\X + MarkDown()\VScroll\Width)
			    If dY > dpiY(MarkDown()\VScroll\Y) And dY < dpiY(MarkDown()\VScroll\Y + MarkDown()\VScroll\Height)
        
    			  MarkDown()\VScroll\CursorPos = #PB_Default
    			  MarkDown()\VScroll\Timer     = #False
    			  
    			  If MarkDown()\VScroll\Focus
    			    
      			  If dY > dpiY(MarkDown()\VScroll\Buttons\bY) And  dY < dpiY(MarkDown()\VScroll\Buttons\bY + MarkDown()\VScroll\Buttons\Height)
      			    
      			    ; --- Backwards Button ---
      			    SetThumbPosY_(MarkDown()\VScroll\Pos - MarkDown()\ScrollV)
    
      			    Draw_(#Vertical)

      			  ElseIf dY > dpiY(MarkDown()\VScroll\Buttons\fY) And  dY < dpiY(MarkDown()\VScroll\Buttons\fY + MarkDown()\VScroll\Buttons\Height)
      			    
      			    ; --- Forwards Button ---
      			    SetThumbPosY_(MarkDown()\VScroll\Pos + MarkDown()\ScrollV)
      			    
      			    Draw_(#Vertical)

      			  ElseIf dY > dpiY(MarkDown()\VScroll\Area\Y) And dY < dpiY(MarkDown()\VScroll\Thumb\Y)
      			    
      			    ; --- Page up ---
      			    SetThumbPosY_(MarkDown()\VScroll\Pos - MarkDown()\VScroll\PageLength)
    
      			    Draw_(#Vertical)

      			  ElseIf dY > dpiY(MarkDown()\VScroll\Thumb\Y + MarkDown()\VScroll\Thumb\Height) And dY < dpiY(MarkDown()\VScroll\Area\Y + MarkDown()\VScroll\Area\Height)
      			    
      			    ; --- Page down ---
      			    SetThumbPosY_(MarkDown()\VScroll\Pos + MarkDown()\VScroll\PageLength)
    
      			    Draw_(#Vertical)
 
      			  EndIf
        			
      			EndIf 
      			
      			ProcedureReturn #True
      		EndIf
      	EndIf
      	
  		EndIf ;}

			
			ForEach MarkDown()\TOC()  ;{ Table of Contents
			  If dY >= dpiY(MarkDown()\TOC()\Y) And dY <= dpiY(MarkDown()\TOC()\Y + MarkDown()\TOC()\Height)
			    If dX >= dpiX(MarkDown()\TOC()\X) And dX <= dpiX(MarkDown()\TOC()\X + MarkDown()\TOC()\Width)
			      
			      MarkDown()\EventValue = MarkDown()\TOC()\ID
			      MarkDown()\EventLabel = MarkDown()\TOC()\Label
			      
			      PostEvent(#Event_Gadget,    MarkDown()\Window\Num, MarkDown()\CanvasNum, #EventType_Link)
			      PostEvent(#PB_Event_Gadget, MarkDown()\Window\Num, MarkDown()\CanvasNum, #EventType_Link)
			      
			      ProcedureReturn #True
			    EndIf
			  EndIf  
			  ;}  
			Next
			
			ForEach MarkDown()\Link() ;{ Link
			  
			  If dY >= dpiY(MarkDown()\Link()\Y) And dY <= dpiY(MarkDown()\Link()\Y + MarkDown()\Link()\Height) 
			    If dX >= dpiX(MarkDown()\Link()\X) And dX <= dpiX(MarkDown()\Link()\X + MarkDown()\Link()\Width)

			      If MarkDown()\Link()\Label
			        If FindMapElement(MarkDown()\Label(), MarkDown()\Link()\Label)
			          MarkDown()\EventValue = Trim(MarkDown()\Label()\Destination)
			        EndIf  
			      Else  
			        MarkDown()\EventValue = Trim(MarkDown()\Link()\URL)
			      EndIf
			      
			      If Left(MarkDown()\EventValue, 4) = "HDG:"
			        If FindMapElement(MarkDown()\HeadingID(), MarkDown()\EventValue)
			          GotoHeading_(MarkDown()\EventValue)
			        EndIf  
			        MarkDown()\EventLabel = ""
			      ElseIf Left(MarkDown()\EventValue, 1) = "#" ; Page Link
			        MarkDown()\EventLabel = LTrim(MarkDown()\EventValue, "#")
			      EndIf  

			      PostEvent(#Event_Gadget,    MarkDown()\Window\Num, MarkDown()\CanvasNum, #EventType_Link)
			      PostEvent(#PB_Event_Gadget, MarkDown()\Window\Num, MarkDown()\CanvasNum, #EventType_Link)
			      
			      MarkDown()\Link()\State = #False
			      
			      Draw_()
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
  			;}
			Next  
			
			ForEach MarkDown()\Link()
			  MarkDown()\Link()\State = #False
			Next
			
			Draw_()
			
			CompilerIf #Enable_Requester
		  
		    ForEach MarkDown()\Requester\Button() ;{ Click Button
		      
		      If Not MarkDown()\Requester\Button()\Visible : Continue : EndIf
		      
		      If dY >= dpiY(MarkDown()\Requester\ButtonY) And dY <= dpiY(MarkDown()\Requester\ButtonY + #ButtonHeight)  
    			  If dX >= dpiX(MarkDown()\Requester\Button()\X) And dX <= dpiX(MarkDown()\Requester\Button()\X + MarkDown()\Requester\Button()\Width)
    			    
    			    MarkDown()\Requester\Button()\State = #Focus
    			    MarkDown()\Requester\Result = MarkDown()\Requester\Button()\Result
    			    Draw_()
    			    
    			    PostEvent(#Event_Gadget, MarkDown()\Window\Num, MarkDown()\CanvasNum, #PB_EventType_LeftClick, MarkDown()\Requester\Result)
    			    
  			      ProcedureReturn #True 
    			  EndIf
    			EndIf 
          ;}
  			Next 
  			
  		CompilerEndIf

		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
	  Define.i X, Y, dX, dY, Backwards, Forwards, Thumb, CursorPos
	  Define.s ToolTip$
		Define.i GNum = EventGadget()
		
		CompilerIf #Enable_Tooltips
		  
			If FindMapElement(Tooltips(), Str(GNum))
			  
			  If GadgetType(GNum) = #PB_GadgetType_Canvas
          X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
          Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
        Else
          X = GetMouseEventAttribute_(Tooltips()\Window, #MouseX, GNum)
          Y = GetMouseEventAttribute_(Tooltips()\Window, #MouseY, GNum)
        EndIf

        If X <> Tooltips()\MouseX Or Y <> Tooltips()\MouseY
          
          Tooltips()\MouseX = X
          Tooltips()\MouseY = Y
          
          ;{ Cursor move
          LockMutex(Mutex)
          
          Timer(Str(GNum))\Active = #True
          Timer(Str(GNum))\Value  = 0
          
          UnlockMutex(Mutex)
  
          If ToolTips()\Visible
        
            LockMutex(Mutex)
      	    Timer(Str(GNum))\Focus  = #False
      	    Timer(Str(GNum))\Active = #True
      	    Timer(Str(GNum))\Value  = 0
      	    Timer(Str(GNum))\State  = #False
      	    UnlockMutex(Mutex)
  	    
      	    Tooltips()\MouseX  = #PB_Default
      	    Tooltips()\MouseY  = #PB_Default
      	    ToolTips()\Visible = #False
      	    
            HideWindow(ToolTips()\WindowNum, #True)
            
            SetActiveWindow(ToolTips()\Window)
            
          Else  
            
            TooltipPosition_(X, Y)
            
            LockMutex(Mutex)
      	    Timer(Str(GNum))\State = #True
      	    UnlockMutex(Mutex)
      	    
      	    ProcedureReturn #True
          EndIf ;}
          
          LockMutex(Mutex)
    	    Timer(Str(GNum))\State = #True
    	    UnlockMutex(Mutex)
          
        EndIf

			EndIf 
			
	  CompilerEndIf

		If FindMapElement(MarkDown(), Str(GNum))

			dX = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseX)
			dY = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseY)
			
			X = DesktopUnscaledX(dX)
			Y = DesktopUnscaledY(dY)

			
		  ;{ Horizontal Scrollbar
		  If MarkDown()\HScroll\Hide = #False
		  
			  MarkDown()\HScroll\Focus = #False
			  
			  Backwards = MarkDown()\HScroll\Buttons\bState
			  Forwards  = MarkDown()\HScroll\Buttons\fState
			  Thumb     = MarkDown()\HScroll\Thumb\State
			  
			  If dY > dpiY(MarkDown()\HScroll\Y) And dY < dpiY(MarkDown()\HScroll\Y + MarkDown()\HScroll\Height)
			    If dX > dpiX(MarkDown()\HScroll\X) And dX < dpiX(MarkDown()\HScroll\X + MarkDown()\HScroll\Width)
			      
			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
			      
			      ; --- Focus Scrollbar ---  
			      MarkDown()\HScroll\Buttons\bState = #Focus
			      MarkDown()\HScroll\Buttons\fState = #Focus
			      MarkDown()\HScroll\Thumb\State    = #Focus
			      
			      ; --- Hover Buttons & Thumb ---
			      If dX > dpiX(MarkDown()\HScroll\Buttons\bX) And  dX < dpiX(MarkDown()\HScroll\Buttons\bX + MarkDown()\HScroll\Buttons\Width)
			        
			        MarkDown()\HScroll\Buttons\bState = #Hover
			        
			      ElseIf dX > dpiX(MarkDown()\HScroll\Buttons\fX) And  dX < dpiX(MarkDown()\HScroll\Buttons\fX + MarkDown()\HScroll\Buttons\Width)
			        
			        MarkDown()\HScroll\Buttons\fState = #Hover
			        
			      ElseIf dX > dpiX(MarkDown()\HScroll\Thumb\X) And dX < dpiX(MarkDown()\HScroll\Thumb\X + MarkDown()\HScroll\Thumb\Width)
			        
			        MarkDown()\HScroll\Thumb\State = #Hover
			        
			        ;{ --- Move thumb with cursor 
			        If MarkDown()\HScroll\CursorPos <> #PB_Default
			          
			          CursorPos = MarkDown()\HScroll\Pos
			          
  			        MarkDown()\HScroll\Pos = GetThumbPosX_(X)
  			        MarkDown()\HScroll\CursorPos = X
  			        
  			        If CursorPos <> MarkDown()\HScroll\Pos
  			          
  			          Draw_(#Horizontal)

  			        EndIf
  			        
  			      EndIf ;}
  			      
			      EndIf
			      
			      MarkDown()\HScroll\Focus = #True
			      
    		    If Backwards <> MarkDown()\HScroll\Buttons\bState : DrawButton_(#Horizontal, #Backwards) : EndIf 
    		    If Forwards  <> MarkDown()\HScroll\Buttons\fState : DrawButton_(#Horizontal, #Forwards)  : EndIf 
    		    If Thumb     <> MarkDown()\HScroll\Thumb\State    : DrawThumb_(#Horizontal)              : EndIf
    		    
    		    ProcedureReturn #True
			    EndIf
  			EndIf
  		
    		If Not MarkDown()\HScroll\Focus
    		  
	        MarkDown()\HScroll\Buttons\bState = #False
	        MarkDown()\HScroll\Buttons\fState = #False
	        MarkDown()\HScroll\Thumb\State    = #False
	        
	        MarkDown()\HScroll\Timer = #False
	      EndIf
    		
    		If Backwards <> MarkDown()\HScroll\Buttons\bState : DrawButton_(#Horizontal, #Backwards) : EndIf 
		    If Forwards  <> MarkDown()\HScroll\Buttons\fState : DrawButton_(#Horizontal, #Forwards)  : EndIf 
		    If Thumb     <> MarkDown()\HScroll\Thumb\State    : DrawThumb_(#Horizontal)              : EndIf 
		    
		    MarkDown()\VScroll\CursorPos = #PB_Default
		    
		  EndIf  ;} 
		  
		  ;{ Vertikal Scrollbar
		  If MarkDown()\VScroll\Hide = #False
		    
  		  MarkDown()\VScroll\Focus = #False
  		  
  		  Backwards = MarkDown()\VScroll\Buttons\bState
  		  Forwards  = MarkDown()\VScroll\Buttons\fState
  		  Thumb     = MarkDown()\VScroll\Thumb\State
  		  
  		  If dX > dpiX(MarkDown()\VScroll\X) And dX < dpiX(MarkDown()\VScroll\X + MarkDown()\VScroll\Width)
  		    If dY > dpiY(MarkDown()\VScroll\Y) And dY < dpiY(MarkDown()\VScroll\Y + MarkDown()\VScroll\Height)
  		     
  		      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
  		      
  		      ; --- Focus Scrollbar ---  
  		      MarkDown()\VScroll\Buttons\bState = #Focus
  		      MarkDown()\VScroll\Buttons\fState = #Focus
  		      MarkDown()\VScroll\Thumb\State    = #Focus
  		      
  		      ; --- Hover Buttons & Thumb ---
  		      If dY > dpiY(MarkDown()\VScroll\Buttons\bY) And dY < dpiY(MarkDown()\VScroll\Buttons\bY + MarkDown()\VScroll\Buttons\Height)
  		        
  		        MarkDown()\VScroll\Buttons\bState = #Hover
  		        
  		      ElseIf dY > dpiY(MarkDown()\VScroll\Buttons\fY) And dY < dpiY(MarkDown()\VScroll\Buttons\fY + MarkDown()\VScroll\Buttons\Height)
  		        
  		        MarkDown()\VScroll\Buttons\fState = #Hover
  
  		      ElseIf dY > dpiY(MarkDown()\VScroll\Thumb\Y) And dY < dpiY(MarkDown()\VScroll\Thumb\Y + MarkDown()\VScroll\Thumb\Height)
  		        
  		        MarkDown()\VScroll\Thumb\State = #Hover
  		        
  		        ;{ --- Move thumb with cursor 
  		        If MarkDown()\VScroll\CursorPos <> #PB_Default
  		          
  		          CursorPos = MarkDown()\VScroll\Pos
  		          
  			        MarkDown()\VScroll\Pos       = GetThumbPosY_(Y)
  			        MarkDown()\VScroll\CursorPos = Y
  			        
  			        If CursorPos <> MarkDown()\VScroll\Pos
  			          Draw_(#Vertical)
  			        EndIf
  			        
  			      EndIf ;}
  
  			    EndIf   
  			    
  			    MarkDown()\VScroll\Focus = #True
  			    
  			    If Backwards <> MarkDown()\VScroll\Buttons\bState : DrawButton_(#Vertical, #Backwards) : EndIf 
            If Forwards  <> MarkDown()\VScroll\Buttons\fState : DrawButton_(#Vertical, #Forwards)  : EndIf 
            If Thumb     <> MarkDown()\VScroll\Thumb\State    : DrawThumb_(#Vertical)              : EndIf 
            
            ProcedureReturn #True
    			EndIf
    		EndIf
    		
    		If Not MarkDown()\VScroll\Focus

          MarkDown()\VScroll\Buttons\bState = #False
          MarkDown()\VScroll\Buttons\fState = #False
          MarkDown()\VScroll\Thumb\State    = #False
          
          MarkDown()\VScroll\Timer = #False
          
        EndIf   
        
        If Backwards <> MarkDown()\VScroll\Buttons\bState : DrawButton_(#Vertical, #Backwards) : EndIf 
        If Forwards  <> MarkDown()\VScroll\Buttons\fState : DrawButton_(#Vertical, #Forwards)  : EndIf 
        If Thumb     <> MarkDown()\VScroll\Thumb\State    : DrawThumb_(#Vertical)              : EndIf 
        
        MarkDown()\VScroll\CursorPos = #PB_Default
        
  		EndIf ;}
			
			
			ForEach MarkDown()\Link()         ;{ Links
			  
			  If dY >= dpiY(MarkDown()\Link()\Y) And dY <= dpiY(MarkDown()\Link()\Y + MarkDown()\Link()\Height)
			    If dX >= dpiX(MarkDown()\Link()\X) And dX <= dpiX(MarkDown()\Link()\X + MarkDown()\Link()\Width)
			      
			      SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			      
			      If MarkDown()\Link()\Title
			        ToolTip$ = MarkDown()\Link()\Title
			      Else
			        ToolTip$ = MarkDown()\Link()\URL
			      EndIf
			      
			      If ToolTip$
			        If MarkDown()\ToolTip = #False
  			        GadgetToolTip(GNum, ToolTip$)
  			        MarkDown()\ToolTip = #True
      			  EndIf
      			EndIf 

  			    ProcedureReturn #True
  			  EndIf
  			EndIf
  			;}
			Next  
			
			ForEach MarkDown()\Footnote()     ;{ FootNotes
			  
			  If dY >= dpiY(MarkDown()\Footnote()\Y) And dY <= dpiY(MarkDown()\Footnote()\Y + MarkDown()\Footnote()\Height)
			    If dX >= dpiX(MarkDown()\Footnote()\X) And dX <= dpiX(MarkDown()\Footnote()\X + MarkDown()\Footnote()\Width)
			      
			      SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			      
			      If MarkDown()\ToolTip = #False
			        
			        ToolTip$ = ""
			        
			        If FindMapElement(MarkDown()\FootLabel(), MarkDown()\Footnote()\Label)
			          ForEach MarkDown()\FootLabel()\Words() : ToolTip$ + MarkDown()\FootLabel()\Words()\String + " " : Next
			          GadgetToolTip(GNum, Trim(ToolTip$))
			          MarkDown()\ToolTip  = #True
			        EndIf
			        
			      EndIf
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
  			;}
			Next  
			
			ForEach MarkDown()\AbbrevWord()   ;{ Abbreviations
			  
			  If dY >= dpiY(MarkDown()\AbbrevWord()\Y) And dY <= dpiY(MarkDown()\AbbrevWord()\Y + MarkDown()\AbbrevWord()\Height) 
			    If dX >= dpiX(MarkDown()\AbbrevWord()\X) And dX <= dpiX(MarkDown()\AbbrevWord()\X + MarkDown()\AbbrevWord()\Width)
			      
			      SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			      
			      If MarkDown()\ToolTip = #False
		          GadgetToolTip(GNum, Trim(MarkDown()\Abbreviation(MarkDown()\AbbrevWord()\Word)\String))
		          MarkDown()\ToolTip  = #True
			      EndIf
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
			  ;}
			Next  
			
			ForEach MarkDown()\GlossaryWord() ;{ Glossary
			  
			  If dY >= dpiY(MarkDown()\GlossaryWord()\Y) And dY <= dpiY(MarkDown()\GlossaryWord()\Y + MarkDown()\GlossaryWord()\Height)
			    If dX >= dpiX(MarkDown()\GlossaryWord()\X) And dX <= dpiX(MarkDown()\GlossaryWord()\X + MarkDown()\GlossaryWord()\Width)
			      
			      SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			      
			      If MarkDown()\ToolTip = #False
			        ToolTip$ = Trim(GetString_(MarkDown()\Glossary(MarkDown()\GlossaryWord()\Word)\Words()))
		          GadgetToolTip(GNum, ToolTip$)
		          MarkDown()\ToolTip  = #True
			      EndIf
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
			  ;}
			Next  
			
			ForEach MarkDown()\TOC()          ;{ Table of Contents
			  If dY >= dpiY(MarkDown()\TOC()\Y) And dY <= dpiY(MarkDown()\TOC()\Y + MarkDown()\TOC()\Height) 
			    If dX >= dpiX(MarkDown()\TOC()\X) And dX <= dpiX(MarkDown()\TOC()\X + MarkDown()\TOC()\Width)
			      
			      SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			      
			      ProcedureReturn #True
			    EndIf
			  EndIf  
			  ;}  
			Next
			
			ForEach MarkDown()\Image()        ;{ Images
			  
			  If MarkDown()\Image()\Title = "" : Continue : EndIf 
			  
			  If dY >= dpiY(MarkDown()\Image()\Y) And dY <= dpiY(MarkDown()\Image()\Y + MarkDown()\Image()\Height)
			    If dX >= dpiX(MarkDown()\Image()\X) And dX <= dpiX(MarkDown()\Image()\X + MarkDown()\Image()\Width)
			      
			      If MarkDown()\ToolTip = #False
			        GadgetToolTip(GNum, MarkDown()\Image()\Title)
			        MarkDown()\ToolTip  = #True
			      EndIf
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
			  ;}
			Next  
			
			MarkDown()\ToolTip = #False
			GadgetToolTip(GNum, "")
			
		  CompilerIf #Enable_Requester
		  
		    ForEach MarkDown()\Requester\Button()
		      
		      If Not MarkDown()\Requester\Button()\Visible : Continue : EndIf
		      
		      If dY >= dpiY(MarkDown()\Requester\ButtonY) And dY <= dpiY(MarkDown()\Requester\ButtonY + #ButtonHeight)
    			  If dX >= dpiX(MarkDown()\Requester\Button()\X) And dX <= dpiX(MarkDown()\Requester\Button()\X + MarkDown()\Requester\Button()\Width)
    			    If MarkDown()\Requester\Button()\State <> #Focus
    			      MarkDown()\Requester\Button()\State = #Focus
    			      Draw_()
    			    EndIf
  			      ProcedureReturn #True 
    			  EndIf
    			EndIf 
    			
    			If MarkDown()\Requester\Button()\State
  			    MarkDown()\Requester\Button()\State = #False
  			    Draw_()
  			  EndIf
    			
  			Next 
  			
  		CompilerEndIf

			SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure
	
	Procedure _MouseWheelHandler()
    Define.i GNum = EventGadget()
    Define.i Delta, Offset

    If FindMapElement(MarkDown(), Str(GNum))
      
      Delta = GetGadgetAttribute(GNum, #PB_Canvas_WheelDelta)

      If MarkDown()\VScroll\Hide = #False
        SetThumbPosY_(MarkDown()\VScroll\Pos - (Delta * MarkDown()\ScrollV))
        Draw_(#Vertical)
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  CompilerIf #Enable_Tooltips
    
    Procedure _TimerEventHandler()
      Define.i X, Y, Handle, Window, Gadget, GadgetNum
  
      Window = GetActiveWindow()
      
      Select EventTimer()
        Case #TooltipTimer    ;{ Tooltip Delay
          
          LockMutex(Mutex)
          
          ForEach Timer()
            
            If Timer()\Focus And Timer()\State 
              
              If Timer()\Active
                
                Timer()\Value + 200
                
                If Timer()\Value >= Timer()\Delay
                  
                  If FindMapElement(ToolTips(), Str(Timer()\GadgetNum))
                    
                    SetGadgetData(ToolTips()\CanvasNum, Timer()\GadgetNum)
                    ResizeWindow(ToolTips()\WindowNum, ToolTips()\PosX, ToolTips()\PosY, #PB_Ignore, #PB_Ignore)
  	                ResizeWindow(ToolTips()\WindowNum, ToolTips()\PosX, ToolTips()\PosY, #PB_Ignore, #PB_Ignore)
	                
  	                If FindMapElement(MarkDown(), Str(ToolTips()\CanvasNum))
  	                  Draw_()
  	                EndIf  
                  
                    ToolTips()\Visible = #True
                  
                    HideWindow(ToolTips()\WindowNum, #False)
                  
                    SetActiveWindow(ToolTips()\Window)
                    
                  EndIf
                  
    	            Timer()\Value  = 0
    	            Timer()\Active = #False
    	          EndIf
    	          
    	        EndIf
    	        
    	      EndIf
    	      
    	    Next
    	    
    	    UnlockMutex(Mutex)           
          ;}
        Case #MouseEventTimer ;{ MouseEvents
          
          If FindMapElement(MouseEvent(), Str(Window))
      
            X = WindowMouseX(Window)
            Y = WindowMouseY(Window)
            
            If X <> MouseEvent()\Window\MouseX Or Y <> MouseEvent()\Window\MouseY
              
              MouseEvent()\Window\MouseX = X
              MouseEvent()\Window\MouseY = Y
              
              ; Get Handle under mouse (mk-soft)
              CompilerSelect #PB_Compiler_OS
                CompilerCase #PB_OS_Windows ;{ Windows
                  Protected.i DesktopX, DesktopY
                  
                  DesktopX = DesktopMouseX()
                  Desktopy = DesktopMouseY()
                  Handle   = WindowFromPoint_(DesktopY << 32 | DesktopX)
                  ;}
                CompilerCase #PB_OS_MacOS   ;{ MacOS
                  Protected WinID.i, WinCV.i, pt.NSPoint
                  
                  WinID = WindowID(Window)
                  WinCV = CocoaMessage(0, WinID, "contentView")
                  CocoaMessage(@pt, WinID, "mouseLocationOutsideOfEventStream")
                  Handle = CocoaMessage(0, WinCV, "hitTest:@", @pt)
                  ;}
                CompilerCase #PB_OS_Linux   ;{ Linux
                  Protected DesktopX.i, DesktopY.i, *GdkWindow.GdkWindowObject
                  
                  *GdkWindow.GdkWindowObject = gdk_window_at_pointer_(@DesktopX,@Desktopy)
                  If *GdkWindow
                    gdk_window_get_user_data_(*GdkWindow, @Handle)
                  Else
                    Handle = #False
                  EndIf
                  ;} 
              CompilerEndSelect
              
              If Handle <> MouseEvent()\lastHandle
                
                ;{ ___ Event: MouseLeave ___ (mk-soft)
                If IsGadget(MouseEvent()\lastGadget)
                
                  If MouseEvent()\Flags & #MouseLeave
                    If GadgetType(MouseEvent()\lastGadget) <> #PB_GadgetType_Canvas
                      ForEach MouseEvent()\Gadget()
                        If MouseEvent()\Gadget()\Num = #PB_Default Or MouseEvent()\lastGadget = MouseEvent()\Gadget()\Num
                          PostEvent(#PB_Event_Gadget, MouseEvent()\Window\Num, MouseEvent()\lastGadget, #PB_EventType_MouseLeave)
                          Break
                        EndIf
                      Next
                    EndIf
                  EndIf
                  
                  MouseEvent()\lastGadget = #PB_Default
                  
                EndIf ;}
                
                ; Find GadgetID over Handle (mk-soft)
                PB_Object_EnumerateStart(PB_Gadget_Objects)
                
                While PB_Object_EnumerateNext(PB_Gadget_Objects, @Gadget)
                  
                  If Handle = GadgetID(Gadget)
                    
                    MouseEvent()\lastGadget = Gadget
                    
                    ;{ ___ Event: MouseEnter ___ (mk-soft)
                    If MouseEvent()\Flags & #MouseEnter
                      If GadgetType(MouseEvent()\lastGadget) <> #PB_GadgetType_Canvas
                        ForEach MouseEvent()\Gadget()
                          If MouseEvent()\Gadget()\Num = #PB_Default Or MouseEvent()\lastGadget = MouseEvent()\Gadget()\Num
                            PostEvent(#PB_Event_Gadget, MouseEvent()\Window\Num, MouseEvent()\lastGadget, #PB_EventType_MouseEnter)
                            Break
                          EndIf  
                        Next
                      EndIf
                    EndIf ;}
                    
                    PB_Object_EnumerateAbort(PB_Gadget_Objects)
                    Break
                  EndIf
                  
                Wend
                
                MouseEvent()\lastHandle = Handle
              EndIf
              
              ;{ ___ Event: MouseMove ___ (mk-soft)
              If MouseEvent()\Flags & #MouseMove
                
                If IsGadget(MouseEvent()\lastGadget)
                  If GadgetType(MouseEvent()\lastGadget) <> #PB_GadgetType_Canvas
                    ForEach MouseEvent()\Gadget()
                      If MouseEvent()\Gadget()\Num = #PB_Default Or MouseEvent()\lastGadget = MouseEvent()\Gadget()\Num
                        MouseEvent()\Gadget()\MouseX = MouseEvent()\Window\MouseX - GadgetX(MouseEvent()\lastGadget, #PB_Gadget_WindowCoordinate)
                        MouseEvent()\Gadget()\MouseY = MouseEvent()\Window\MouseY - GadgetY(MouseEvent()\lastGadget, #PB_Gadget_WindowCoordinate)
                        PostEvent(#PB_Event_Gadget, MouseEvent()\Window\Num, MouseEvent()\lastGadget, #PB_EventType_MouseMove)
                        Break
                      EndIf 
                    Next
                  EndIf
                EndIf
                
              EndIf ;}
              
            EndIf
            
          EndIf
        ;}
      EndSelect
    
    EndProcedure
    
    Procedure _MouseEnterHandler()
  	  Define.i GNum = EventGadget()
  	 
  	  If FindMapElement(ToolTips(), Str(GNum))
  	    
  	    LockMutex(Mutex)
  	    Timer(Str(GNum))\Focus = #True
  	    Timer(Str(GNum))\Value = 0
  	    Timer(Str(GNum))\State = #False
  	    UnlockMutex(Mutex)

  	  EndIf
  	  
  	EndProcedure
	
  	Procedure _MouseLeaveHandler()
  	  Define.i GNum = EventGadget()
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    
  	    ;{ Horizontal Scrollbar
	      MarkDown()\HScroll\Buttons\bState = #False
        MarkDown()\HScroll\Buttons\fState = #False
        MarkDown()\HScroll\Thumb\State    = #False
        MarkDown()\HScroll\CursorPos      = #PB_Default
	      ;}
  	    
  	    ;{ Vertikal Scrollbar
        MarkDown()\VScroll\Buttons\bState = #False
        MarkDown()\VScroll\Buttons\fState = #False
        MarkDown()\VScroll\Thumb\State    = #False
        MarkDown()\VScroll\CursorPos      = #PB_Default
	      ;}
        
        Draw_(#Horizontal|#Vertical)
  	    
  	  EndIf  
  	  
  	  If FindMapElement(Tooltips(), Str(GNum))

  	    LockMutex(Mutex)
  	    
  	    Timer(Str(GNum))\Focus  = #False
  	    Timer(Str(GNum))\Active = #True
  	    Timer(Str(GNum))\Value  = 0
  	    Timer(Str(GNum))\State  = #False
  	    
  	    UnlockMutex(Mutex)
  	    
  	    Tooltips()\MouseX  = #PB_Default
  	    Tooltips()\MouseY  = #PB_Default
  	    Tooltips()\Visible = #False
  	    
  	    HideWindow(Tooltips()\WindowNum, #True)
        
  	    SetActiveWindow(Tooltips()\Window)
  	  EndIf
  	  
  	EndProcedure
  	
	  Procedure _MouseLeftClickHandler()
      Define.i GNum, CanvasNum = EventGadget()
      
      GNum = GetGadgetData(CanvasNum)
      
      If FindMapElement(ToolTips(), Str(GNum))
        
        LockMutex(Mutex)
  	    Timer(Str(GNum))\Focus  = #False
  	    Timer(Str(GNum))\Active = #True
  	    Timer(Str(GNum))\Value  = 0
  	    Timer(Str(GNum))\State  = #False
  	    UnlockMutex(Mutex)
  	    
  	    ToolTips()\MouseX  = #PB_Default
  	    ToolTips()\MouseY  = #PB_Default
  	    ToolTips()\Visible = #False
  	    
  	    HideWindow(ToolTips()\WindowNum, #True)
  	    
  	    SetActiveWindow(ToolTips()\Window)

  	  EndIf
  	  
  	  PostEvent(#PB_Event_Gadget, ToolTips()\Window, ToolTips()\Gadget, #PB_EventType_LeftClick)
  	  
    EndProcedure
  
    Procedure _MouseRightClickHandler()
      Define.i GNum, CanvasNum = EventGadget()
      
      GNum = GetGadgetData(CanvasNum)
      
      If FindMapElement(ToolTips(), Str(GNum))
        
        LockMutex(Mutex)
  	    Timer(Str(GNum))\Focus  = #False
  	    Timer(Str(GNum))\Active = #True
  	    Timer(Str(GNum))\Value  = 0
  	    Timer(Str(GNum))\State  = #False
  	    UnlockMutex(Mutex)
  	    
  	    ToolTips()\MouseX  = #PB_Default
  	    ToolTips()\MouseY  = #PB_Default
  	    ToolTips()\Visible = #False
  	    
  	    HideWindow(ToolTips()\WindowNum, #True)
  	    
  	    SetActiveWindow(ToolTips()\Window)
        
  	    PostEvent(#PB_Event_Gadget, ToolTips()\Window, ToolTips()\Gadget, #PB_EventType_RightClick)
  	    
      EndIf  
      
    EndProcedure

  CompilerEndIf
  
  
	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(MarkDown(), Str(GadgetID))

		  AdjustScrollBars_()

		  Draw_(#Vertical|#Horizontal)
		  
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY
		
		ForEach MarkDown()

			If IsGadget(MarkDown()\CanvasNum)

				If MarkDown()\Flags & #AutoResize

					If IsWindow(MarkDown()\Window\Num)

						OffSetX = WindowWidth(MarkDown()\Window\Num)  - MarkDown()\Window\Width
						OffsetY = WindowHeight(MarkDown()\Window\Num) - MarkDown()\Window\Height

						If MarkDown()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If MarkDown()\Size\Flags & #MoveX  : X = MarkDown()\Size\X + OffSetX : EndIf
							If MarkDown()\Size\Flags & #MoveY  : Y = MarkDown()\Size\Y + OffSetY : EndIf
							If MarkDown()\Size\Flags & #Width  : Width  = MarkDown()\Size\Width + OffSetX : EndIf
							If MarkDown()\Size\Flags & #Height : Height = MarkDown()\Size\Height + OffSetY : EndIf

							ResizeGadget(MarkDown()\CanvasNum, X, Y, Width, Height)
	
						Else
							ResizeGadget(MarkDown()\CanvasNum, #PB_Ignore, #PB_Ignore, MarkDown()\Size\Width + OffSetX, MarkDown()\Size\Height + OffsetY)
						EndIf
						
						CompilerIf #Enable_HelpWindow
						  
						  If MarkDown()\Type = #HelpWindow
						    If IsGadget(Help\TreeNum) : ResizeGadget(Help\TreeNum, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetHeight(MarkDown()\CanvasNum) - 30) : EndIf
						    If IsGadget(Help\ListNum) : ResizeGadget(Help\ListNum, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetHeight(MarkDown()\CanvasNum) - 30) : EndIf
						  EndIf
						  
						CompilerEndIf
						
					EndIf

				EndIf

			EndIf

		Next
		
	EndProcedure
	
  Procedure _CloseWindowHandler()
    Define.i WindowNum = EventWindow()
    
    ForEach MarkDown()
      
      Select MarkDown()\Type
        Case #ToolTip ;{ Tooltips
          
          CompilerIf #Enable_Tooltips
            If MarkDown()\Tooltips\Window = WindowNum
              
              RemoveWindowTimer(MarkDown()\Window\Num, #TooltipTimer)
              RemoveWindowTimer(MarkDown()\Window\Num, #MouseEventTimer)
              
              If IsWindow(MarkDown()\Window\Num)
                CloseWindow(MarkDown()\Window\Num)
              EndIf
              
              DeleteMapElement(MouseEvent(), Str(MarkDown()\Tooltips\Window))
              DeleteMapElement(Tooltips(),   Str(MarkDown()\Tooltips\Gadget))
              DeleteMapElement(Timer(),      Str(MarkDown()\Tooltips\Gadget))
              DeleteMapElement(MarkDown())
              
            EndIf
          CompilerEndIf  
          ;}
        Case #Gadget  ;{ Gadget
          
          If MarkDown()\Window\Num = WindowNum
            DeleteMapElement(MarkDown())
          EndIf  
          ;}
        Default
          Continue
      EndSelect    
      
    Next  
    
  EndProcedure 

	;- ============================================================================
	;-   Module - Init & Scrollbar
	;- ============================================================================	
	
	Procedure InitDefault_()

	  ;{ _____ Color _____
		MarkDown()\Color\Back          = $FFFFFF
		MarkDown()\Color\BlockQuote    = $C0C0C0
		MarkDown()\Color\Border        = $E3E3E3
		MarkDown()\Color\Code          = $006400
		MarkDown()\Color\DisableFront  = $72727D
		MarkDown()\Color\DisableBack   = $CCCCCA
		MarkDown()\Color\Front         = $000000
		MarkDown()\Color\Gadget        = $F0F0F0
		MarkDown()\Color\Highlight     = $E3F8FC
		MarkDown()\Color\Hint          = $800000
		MarkDown()\Color\Keystroke     = $650000
		MarkDown()\Color\KeyStrokeBack = $F6F6F6 
		MarkDown()\Color\Line          = $A9A9A9
		MarkDown()\Color\Link          = $8B0000
		MarkDown()\Color\LinkHighlight = $FF0000
		MarkDown()\Color\HeaderBack    = $F5F5F5
    MarkDown()\Color\Button        = $E3E3E3
    MarkDown()\Color\Focus         = $D77800
    MarkDown()\Color\Keyword       = $82004B
    MarkDown()\Color\Found         = $004B00
    MarkDown()\Color\FoundBack     = $00F6FF
    
		CompilerSelect #PB_Compiler_OS 
			CompilerCase #PB_OS_Windows
				MarkDown()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
				MarkDown()\Color\Back   = GetSysColor_(#COLOR_WINDOW)
				MarkDown()\Color\Border = GetSysColor_(#COLOR_ACTIVEBORDER)
				MarkDown()\Color\Gadget = GetSysColor_(#COLOR_MENU)
				MarkDown()\Color\Button = GetSysColor_(#COLOR_3DLIGHT)
		    MarkDown()\Color\Focus  = GetSysColor_(#COLOR_HIGHLIGHT)
			CompilerCase #PB_OS_MacOS
				MarkDown()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
				MarkDown()\Color\Back   = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
				MarkDown()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				MarkDown()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				MarkDown()\Color\Button = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
		    MarkDown()\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor keyboardFocusIndicatorColor"))
			CompilerCase #PB_OS_Linux

		CompilerEndSelect ;}
		
		;{ _____ Margins _____
		Select MarkDown()\Type
		  Case #Requester
  		  MarkDown()\Margin\Top    = 10
    		MarkDown()\Margin\Left   = 10
    		MarkDown()\Margin\Right  = 10
    		MarkDown()\Margin\Bottom = 5
    	Case #ToolTip
    	  MarkDown()\Margin\Top    = 3
    		MarkDown()\Margin\Left   = 5
    		MarkDown()\Margin\Right  = 5
    		MarkDown()\Margin\Bottom = 3
    	Case #HelpWindow
    	  MarkDown()\Margin\Top    = 10
    		MarkDown()\Margin\Left   = 10
    		MarkDown()\Margin\Right  = 10
    		MarkDown()\Margin\Bottom = 10
    	Default
    	  MarkDown()\Margin\Top    = 5
    		MarkDown()\Margin\Left   = 5
    		MarkDown()\Margin\Right  = 5
    		MarkDown()\Margin\Bottom = 5
		EndSelect
		;}		
		
		MarkDown()\Indent      = 10
	  MarkDown()\LineSpacing = 1.06

	EndProcedure  

  Procedure.i ScrollBar()
	  Define.i MapElement

    MarkDown()\VScroll\CursorPos      = #PB_Default
    MarkDown()\VScroll\Buttons\fState = #PB_Default
    MarkDown()\VScroll\Buttons\bState = #PB_Default
    
    MarkDown()\Scrollbar\Size       = #ScrollBarSize
    MarkDown()\Scrollbar\TimerDelay = #TimerDelay
    
    ; ----- Styles -----
    If MarkDown()\Flags & #Style_Win11      : MarkDown()\Scrollbar\Flags | #Style_Win11      : EndIf
    If MarkDown()\Flags & #Style_RoundThumb : MarkDown()\Scrollbar\Flags | #Style_RoundThumb : EndIf
    
    CompilerIf #PB_Compiler_Version >= 600
      If OSVersion() = #PB_OS_Windows_11  : MarkDown()\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerElse
      If OSVersion() >= #PB_OS_Windows_10 : MarkDown()\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerEndIf  

    ;{ ----- Colors -----
    MarkDown()\Scrollbar\Color\Front  = $C8C8C8
    MarkDown()\Scrollbar\Color\Back   = $F0F0F0
	  MarkDown()\Scrollbar\Color\Button = $F0F0F0
	  MarkDown()\Scrollbar\Color\Focus  = $D77800
	  MarkDown()\Scrollbar\Color\Hover  = $666666
	  MarkDown()\Scrollbar\Color\Arrow  = $696969
	  
	  CompilerSelect #PB_Compiler_OS
		  CompilerCase #PB_OS_Windows
				MarkDown()\Scrollbar\Color\Front  = GetSysColor_(#COLOR_SCROLLBAR)
				MarkDown()\Scrollbar\Color\Back   = GetSysColor_(#COLOR_MENU)
				MarkDown()\Scrollbar\Color\Button = GetSysColor_(#COLOR_BTNFACE)
				MarkDown()\Scrollbar\Color\Focus  = GetSysColor_(#COLOR_MENUHILIGHT)
				MarkDown()\Scrollbar\Color\Hover  = GetSysColor_(#COLOR_ACTIVEBORDER)
				MarkDown()\Scrollbar\Color\Arrow  = GetSysColor_(#COLOR_GRAYTEXT)
			CompilerCase #PB_OS_MacOS
				MarkDown()\Scrollbar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				MarkDown()\Scrollbar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				MarkDown()\Scrollbar\Color\Button = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				MarkDown()\Scrollbar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				MarkDown()\Scrollbar\Color\Hover  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				MarkDown()\Scrollbar\Color\Arrow  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
			CompilerCase #PB_OS_Linux

		CompilerEndSelect
		
		If MarkDown()\Scrollbar\Flags & #Style_Win11
		  MarkDown()\Scrollbar\Color\Hover = $666666
		  MarkDown()\Scrollbar\Color\Focus = $8C8C8C
		EndIf   
    ;}

	  ;BindGadgetEvent(MarkDown()\Gadget, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
	  ;BindGadgetEvent(MarkDown()\Gadget, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
	  ;BindGadgetEvent(MarkDown()\Gadget, @_MouseMoveHandler(),      #PB_EventType_MouseMove)
	  ;BindGadgetEvent(MarkDown()\Gadget, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)

		;BindGadgetEvent(MarkDown()\Gadget, @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
		;BindGadgetEvent(MarkDown()\Gadget, @_ResizeHandler(),         #PB_EventType_Resize)

		;AddWindowTimer(MarkDown()\Window, #AutoScrollTimer, #Frequency)
	  ;BindEvent(#PB_Event_Timer, @_AutoScroll(), MarkDown()\Window)
  
		CalcScrollBar_()

	  DrawScrollBar_()
		
	EndProcedure


	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  Procedure   InsertAsPDF(PDF.i, MarkDown.s, LeftMargin.i=10, RightMargin.i=10, FontSize.i=12)
	  
	  If AddMapElement(MarkDown(), "Parse")
	    
	    Parse_(MarkDown)
	    
	    DetermineTextSize_()
	    
	    CompilerIf Defined(PDF, #PB_Module)
	      ConvertPDF_(PDF, LeftMargin, RightMargin)
	    CompilerEndIf
	    
	    DeleteMapElement(MarkDown())
	  EndIf  
	 
	EndProcedure 
	
	Procedure.s InsertAsHTML(MarkDown.s)
	  Define.s HTML$
	  
	  If AddMapElement(MarkDown(), "Parse")
	    
	    Parse_(MarkDown)
	    
	    DetermineTextSize_()
	    
	    CompilerIf #Enable_ExportHTML
	      HTML$ = ConvertHTML_()
	    CompilerEndIf
	    
	    DeleteMapElement(MarkDown())
	  EndIf  
	  
	  ProcedureReturn HTML$
	EndProcedure 
	
	Procedure   Convert(MarkDown.s, Type.i, Path.s, File.s="", Title.s="")
	  Define.i FileID
	  Define.s String
	  
	  If AddMapElement(MarkDown(), "Parse")
	    
	    MarkDown()\Path = Path
	    
	    LoadFonts_("Arial", 11)
	    
	    Parse_(MarkDown)
	    
	    DetermineTextSize_()
	    
	    Select Type
	      Case #HTML 
	        
	        CompilerIf #Enable_ExportHTML
      	    String = ExportHTML_(Title)
      	    
      	    FileID = CreateFile(#PB_Any, File, #PB_UTF8)
      	    If FileID
      	      WriteStringFormat(FileID,   #PB_UTF8)
      	      WriteString(FileID, String, #PB_UTF8)
      	      CloseFile(FileID)
      	    EndIf
      	  CompilerEndIf
    	  
    	  Case #PDF
    	    
    	    CompilerIf Defined(PDF, #PB_Module)
    	      ExportPDF_(File, Title)
    	    CompilerEndIf 
    	    
    	EndSelect
    	
	    DeleteMapElement(MarkDown())
	  EndIf  
	 
	EndProcedure  	
	
	Procedure   SetText(GNum.i, Text.s, Path.s="")
   
	  If FindMapElement(MarkDown(), Str(GNum))
	    
	    If Path : SetPath(GNum, Path) : EndIf 
	    
	    If MarkDown()\Type = #HelpWindow
	      Clear_()
	    Else
	      Clear_(#True)
	    EndIf  
	    
	    MarkDown()\Text = Text
	    
	    Parse_(Text)
	    DetermineTextSize_()
	    AdjustScrollBars_()
	    
	    Draw_(#Vertical|#Horizontal)
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetPath(GNum.i, Path.s)
	  
	  If FindMapElement(MarkDown(), Str(GNum))
	    
	    If Right(Path, 1) <> #PS$ : Path + #PS$ : EndIf  
	    MarkDown()\Path = Path
	    
	  EndIf
	  
	EndProcedure  
	
	Procedure.i UsedImages(Markdown.s, Path.s, Map Images.s(), Flags.i=#False)
	  Define.s Image$, File$

    If AddMapElement(MarkDown(), "Parse")
      
	    Parse_(MarkDown)
	    
	    ForEach MarkDown()\Image()
	      Image$ = GetFilePart(MarkDown()\Image()\Source)
	      
	      If Flags & #CompletePath
	        Images(Image$) = GetAbsolutePath_(Path, MarkDown()\Image()\Source)
	      ElseIf Flags & #IgnorePath
	        Images(Image$) = GetFilePart(MarkDown()\Image()\Source)
	      Else  
	        Images(Image$) = MarkDown()\Image()\Source
	      EndIf
	      
	    Next
	    
	    DeleteMapElement(MarkDown())
	    
	    ProcedureReturn MapSize(Images())
	  EndIf
	  
	EndProcedure
	
	;- ---------------------------------------
	;- Gadget 
	;- ---------------------------------------
	
	CompilerIf #Enable_Gadget
	  
  	Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)
  
  		If FindMapElement(MarkDown(), Str(GNum))
  			MarkDown()\PopupNum = PopUpNum
  		EndIf
  
  	EndProcedure
  	
  	Procedure   Clear(GNum.i)
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    
  	    Clear_(#True)
  	    
  	    AdjustScrollBars_()
  	    
  	    Draw_(#Vertical|#Horizontal)
  	  EndIf
  	  
  	EndProcedure  
  	
  	Procedure   Disable(GNum.i, State.i=#True)
      
      If FindMapElement(MarkDown(), Str(GNum))
  
        MarkDown()\Disable = State
        DisableGadget(GNum, State)
        
        Draw_(#Horizontal|#Vertical)
      EndIf  
      
    EndProcedure 	
    
    Procedure   Export(GNum.i, Type.i, File.s="", Title.s="")
  	  Define.i FileID
  	  Define.s String
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    
  	    Select Type
  	      Case #HTML
  	        
  	        CompilerIf #Enable_ExportHTML
  	          
        	    String = ExportHTML_(Title)
        	    
        	    FileID = CreateFile(#PB_Any, File, #PB_UTF8)
        	    If FileID
        	      WriteStringFormat(FileID,   #PB_UTF8)
        	      WriteString(FileID, String, #PB_UTF8)
        	      CloseFile(FileID)
        	    EndIf
        	    
        	  CompilerEndIf
        	  
      	  Case #PDF
      	    
      	    CompilerIf Defined(PDF, #PB_Module)
      	      ExportPDF_(File, Title)
      	    CompilerEndIf 
      	    
      	EndSelect
  
  	  EndIf  
  	 
  	EndProcedure 
    
  	Procedure.s EventValue(GNum.i)
      
      If FindMapElement(MarkDown(), Str(GNum))
        ProcedureReturn MarkDown()\EventValue
      EndIf  
      
    EndProcedure  
    
    Procedure.s EventLabel(GNum.i)
      
      If FindMapElement(MarkDown(), Str(GNum))
        ProcedureReturn MarkDown()\EventLabel
      EndIf  
      
    EndProcedure
    
  	Procedure.q GetData(GNum.i)
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    ProcedureReturn MarkDown()\Quad
  	  EndIf  
  	  
  	EndProcedure	
  	
  	Procedure.s GetID(GNum.i)
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    ProcedureReturn MarkDown()\ID
  	  EndIf
  	  
  	EndProcedure
  	
  	Procedure.s GetText(GNum.i, Type.i=#MarkDown, Title.s="")
      
      If FindMapElement(MarkDown(), Str(GNum))
        
        Select Type
          Case #HTML
            
            CompilerIf #Enable_ExportHTML
              ProcedureReturn ExportHTML_()
            CompilerEndIf
            
          Case #MarkDown
            ProcedureReturn MarkDown()\Text
        EndSelect    
        
      EndIf
      
    EndProcedure
    
    Procedure   GotoHeading(GNum.i, ID.s)
      
      If FindMapElement(MarkDown(), Str(GNum))

        GotoHeading_(ID)
        
      EndIf  
      
    EndProcedure
  	
  	Procedure   Hide(GNum.i, State.i=#True)
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    
  	    If State
  	      MarkDown()\Hide = #True
  	      HideGadget(GNum, #True)
  	    Else
  	      MarkDown()\Hide = #False
  	      HideGadget(GNum, #False)
  	      Draw_(#Horizontal|#Vertical)
  	    EndIf  
  	    
  	  EndIf  
  	  
  	EndProcedure
  	
  	
  	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
      
      If FindMapElement(MarkDown(), Str(GNum))
        
        Select Attribute
          Case #Margin_Top
            MarkDown()\Margin\Top    = Value
          Case #Margin_Left
            MarkDown()\Margin\Left   = Value
          Case #Margin_Right
            MarkDown()\Margin\Right  = Value
          Case #Margin_Bottom
            MarkDown()\Margin\Bottom = Value
          Case #Indent
            MarkDown()\Indent        = Value
          Case #LineSpacing
            MarkDown()\LineSpacing   = Value
          Case #ScrollBar
            ;MarkDown()\ScrollBar\Flags = Value    
        EndSelect
        
        Draw_(#Horizontal|#Vertical)
      EndIf
      
    EndProcedure	
    
    Procedure   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
      
      If FindMapElement(MarkDown(), Str(GNum))
        
        MarkDown()\Margin\Top    = Top
    		MarkDown()\Margin\Left   = Left
    		MarkDown()\Margin\Right  = Right
    		MarkDown()\Margin\Bottom = Bottom
    		If MarkDown()\Margin\Right  = #PB_Default : MarkDown()\Margin\Right  = MarkDown()\Margin\Left : EndIf
    		If MarkDown()\Margin\Bottom = #PB_Default : MarkDown()\Margin\Bottom = MarkDown()\Margin\Top  : EndIf
    		
      EndIf
      
    EndProcedure  
    
  	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
      
      If FindMapElement(MarkDown(), Str(GNum))
        
        MarkDown()\Size\Flags = Flags
        MarkDown()\Flags | #AutoResize
        
      EndIf  
     
    EndProcedure
    
    Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
      
      If FindMapElement(MarkDown(), Str(GNum))
      
        Select ColorTyp 
          Case #Color_Back
            MarkDown()\Color\Back          = Value
          Case #Color_BlockQuote
            MarkDown()\Color\BlockQuote    = Value   
          Case #Color_Border
            MarkDown()\Color\Border        = Value
          Case #Color_Code 
            MarkDown()\Color\Code          = Value
          Case #Color_Front
            MarkDown()\Color\Front         = Value  
          Case #Color_HeaderBack
            MarkDown()\Color\HeaderBack    = Value
          Case #Color_HighlightBack
            MarkDown()\Color\Highlight     = Value    
          Case #Color_Tooltip
            MarkDown()\Color\Hint          = Value 
          Case #Color_Line
            MarkDown()\Color\Line          = Value  
          Case #Color_Link
            MarkDown()\Color\Link          = Value  
          Case #Color_HighlightLink
            MarkDown()\Color\LinkHighlight = Value  
          Case #Color_KeyStroke
            MarkDown()\Color\Keystroke     = Value  
          Case #Color_KeystrokeBack  
            MarkDown()\Color\KeyStrokeBack = Value  
          Case #Color_Keyword
            MarkDown()\Color\Keyword       = Value  
          Case #ScrollBar_FrontColor
            ;MarkDown()\ScrollBar\Color\Front     = Value
          Case #ScrollBar_BackColor 
            ;MarkDown()\ScrollBar\Color\Back      = Value
          Case #ScrollBar_BorderColor
            ;MarkDown()\ScrollBar\Color\Border    = Value
          Case #ScrollBar_ButtonColor
            ;MarkDown()\ScrollBar\Color\Button    = Value
          Case #ScrollBar_ThumbColor
            ;MarkDown()\ScrollBar\Color\ScrollBar = Value    
        EndSelect
        
        Draw_(#Horizontal|#Vertical)
      EndIf
      
    EndProcedure
    
    Procedure   SetData(GNum.i, Value.q)
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    MarkDown()\Quad = Value
  	  EndIf  
  	  
  	EndProcedure
  	
  	Procedure   SetFont(GNum.i, Name.s, Size.i) ; GNum: #Help (= Help Window)
  	  
  	  If GNum = #Help
  	    
  	    CompilerIf #Enable_HelpWindow
  	      Help\Font\Name = Name
  	      Help\Font\Size = Size
  	    CompilerEndIf
  	    
      ElseIf FindMapElement(MarkDown(), Str(GNum))
        
        FreeFonts_()
        
        LoadFonts_(Name, Size)
        
        DetermineTextSize_()
        AdjustScrollBars_()
        
        Draw_(#Vertical|#Horizontal)
      EndIf
      
    EndProcedure
    
  	Procedure   SetID(GNum.i, String.s)
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    MarkDown()\ID = String
  	  EndIf
  	  
  	EndProcedure

  	Procedure   UseImage(GNum.i, FileName.s, ImageNum.i)
  	  Define.s Image$
  	  
  	  If FindMapElement(MarkDown(), Str(GNum))
  	    
  	    If IsImage(ImageNum)
  	      
  	      Image$ = GetFilePart(FileName)
  	      
    	    If AddMapElement(MarkDown()\ImageNum(), Image$)
    	      MarkDown()\ImageNum() = ImageNum
    	    EndIf
    	    
    	  EndIf
    	  
  	  EndIf  
  	 
  	EndProcedure	

  	; ----- MakrDown::Gadget ------ 
  	
  	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
      ; Flags: #AutoResize | #Borderless | #UseExistingCanvas
  		Define Result.i
  		
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
        Result = CanvasGadget(GNum, X, Y, Width, Height)
      EndIf
  		
  		If Result
  
  			If GNum = #PB_Any : GNum = Result : EndIf
  
  			If AddMapElement(MarkDown(), Str(GNum))
  			  
  			  MarkDown()\Type = #Gadget
  			  
  				MarkDown()\CanvasNum = GNum
  				
  				If WindowNum = #PB_Default
            MarkDown()\Window\Num = GetGadgetWindow()
          Else
            MarkDown()\Window\Num = WindowNum
          EndIf

  				MarkDown()\Size\X = X
  				MarkDown()\Size\Y = Y
  				MarkDown()\Size\Width  = Width
  				MarkDown()\Size\Height = Height
  				
  				MarkDown()\VScroll\Hide   = #True
  				MarkDown()\HScroll\Hide   = #True
  				MarkDown()\Scrollbar\Size = #ScrollBarSize
  				
          ScrollBar()

  				MarkDown()\Flags  = Flags
  
          InitDefault_()
  
  				BindGadgetEvent(MarkDown()\CanvasNum,  @_ResizeHandler(),         #PB_EventType_Resize)
  				BindGadgetEvent(MarkDown()\CanvasNum,  @_RightClickHandler(),     #PB_EventType_RightClick)
  				BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
  				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
  				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
  				BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseWheelHandler(),     #PB_EventType_MouseWheel)

  				CompilerIf Defined(ModuleEx, #PB_Module)
            BindEvent(#Event_Theme, @_ThemeHandler())
          CompilerEndIf
  				
  				If Flags & #AutoResize ;{ Enabel AutoResize
  					If IsWindow(MarkDown()\Window\Num)
  						MarkDown()\Window\Width  = WindowWidth(MarkDown()\Window\Num)
  						MarkDown()\Window\Height = WindowHeight(MarkDown()\Window\Num)
  						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), MarkDown()\Window\Num)
  					EndIf
  				EndIf ;}
  				
  				If IsWindow(MarkDown()\Window\Num)
  				  BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), MarkDown()\Window\Num)
  				EndIf
  				
  				AddWindowTimer(MarkDown()\Window\Num, #AutoScrollTimer, #Frequency)
				  BindEvent(#PB_Event_Timer, @_AutoScroll(), MarkDown()\Window\Num)
  				
  				LoadFonts_("Arial", 11)
  				
  				Draw_(#Horizontal|#Vertical)

  				ProcedureReturn GNum
  			EndIf
  
  		EndIf
  
  	EndProcedure
  	
	CompilerEndIf
	
	;- ---------------------------------------
	;- Requester 
  ;- ---------------------------------------
	
	CompilerIf #Enable_Requester
	  
	  Procedure   AddRequesterImage(Label.s, Image.i)   
	    
	    If IsImage(Image)
	      
	      If AddMapElement(Requester\Image(), Label)
	        Requester\Image()\Num    = Image
	        Requester\Image()\Width  = ImageWidth(Image)
	        Requester\Image()\Height = ImageHeight(Image)
	      EndIf
	      
	    EndIf
	    
	  EndProcedure  
	  
	  Procedure   AddRequesterButton(Label.s, Text.s="", Result.i=#PB_Default, Width.i=#PB_Default)   
	    
	    If Not Requester\LastResult : Requester\LastResult = #Result_Cancel : EndIf 
	    
	    If AddMapElement(Requester\Button(), Label)
	      
        If Text
          Requester\Button()\Text = Text
        Else
          Requester\Button()\Text = Label
        EndIf
        
        If Result = #PB_Default
          Requester\LastResult + 1
          Requester\Button()\Result = Requester\LastResult
        Else
          Requester\Button()\Result = Result
        EndIf 
        
        Requester\Button()\Width = Width
        
	    EndIf
	    
	    ProcedureReturn Requester\Button()\Result
	  EndProcedure 
	  
	  Procedure   RequesterButtons(TextOK.s, TextYes.s="", TextNo.s="", TextCancel.s="", ButtonWidth.i=#PB_Default)
	    Requester\Button("OK")\Text     = TextOK
	    Requester\Button("Yes")\Text    = TextYes
	    Requester\Button("No")\Text     = TextNo
	    Requester\Button("Cancel")\Text = TextCancel
	    Requester\ButtonWidth = ButtonWidth
	  EndProcedure
	  
	  Procedure   RequesterPadding(Padding.i)
	    Requester\Padding = Padding
	  EndProcedure  
	  
	  Procedure.i Requester(Title.s, Text.s, Flags.i=#False, Parent.i=#PB_Default, Image.s="", Buttons.s="")
	    ; Flags: #YesNo / #YesNoCancel | #Info / #Question / #Error / #Warning
	    ; Buttons: "Button1|Button2"
	    Define.i GNum, WindowNum, quitWindow, b, Number
	    Define.i Width, Height, wButtons, buttonWidth, Result
	    Define.s Label$
	    
	    CompilerIf Defined(ModuleEx, #PB_Module)
        If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
      CompilerEndIf
      
  	  If Parent = #PB_Default
  	    WindowNum = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_Tool|#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
  	  Else
  	    WindowNum = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_Tool|#PB_Window_SystemMenu|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(Parent))
  	  EndIf
  	  
  	  If WindowNum
  	    
  	    ;{ _____ Open Window _____
  	    SetWindowTitle(WindowNum, " " + Title)
  	    
  	    GNum = CanvasGadget(#PB_Any, 0, 0, 0, 0) ; , #PB_Canvas_Container
  	    If GNum
  	      
  	      If AddMapElement(MarkDown(), Str(GNum))
  	        
  	        MarkDown()\Window\Num = WindowNum
  	        MarkDown()\CanvasNum  = GNum

  	        MarkDown()\Type  = #Requester
				    MarkDown()\Flags = Flags
				    
				    
            MarkDown()\VScroll\Hide   = #True
    				MarkDown()\HScroll\Hide   = #True
    				MarkDown()\Scrollbar\Size = #ScrollBarSize
    				
            ScrollBar()

  	        ;{ _____ Buttons _____
  	        If Requester\ButtonWidth > 0 
  	          buttonWidth = Requester\ButtonWidth
  	        Else
  	          buttonWidth = #ButtonWidth
  	        EndIf  

  	        If AddMapElement(MarkDown()\Requester\Button(), "OK")
  	          If Requester\Button("OK")\Text
  	            MarkDown()\Requester\Button()\Text = Requester\Button("OK")\Text
  	          Else
  	            MarkDown()\Requester\Button()\Text = "OK"
  	          EndIf 
  	          MarkDown()\Requester\Button()\Width  = buttonWidth
        		  MarkDown()\Requester\Button()\Result = #True
        		EndIf
        		
        		If AddMapElement(MarkDown()\Requester\Button(), "Yes")
        		  If Requester\Button("Yes")\Text
        		    MarkDown()\Requester\Button()\Text = Requester\Button("Yes")\Text
        		  Else
        		    MarkDown()\Requester\Button()\Text = "Yes"
        		  EndIf  
        		  MarkDown()\Requester\Button()\Width  = buttonWidth
        		  MarkDown()\Requester\Button()\Result = #Result_Yes
        		EndIf 
        		
        		If AddMapElement(MarkDown()\Requester\Button(), "No")  
        		  If Requester\Button("No")\Text
        		    MarkDown()\Requester\Button()\Text = Requester\Button("No")\Text
        		  Else
        		    MarkDown()\Requester\Button()\Text = "No"
        		  EndIf  
        		  MarkDown()\Requester\Button()\Width  = buttonWidth
        		  MarkDown()\Requester\Button()\Result = #Result_No
        		EndIf 
        		
        		If AddMapElement(MarkDown()\Requester\Button(), "Cancel")  
        		  If Requester\Button("Cancel")\Text
        		    MarkDown()\Requester\Button()\Text = Requester\Button("Cancel")\Text
        		  Else
        		    MarkDown()\Requester\Button()\Text = "Cancel" 
        		  EndIf   
        		  MarkDown()\Requester\Button()\Width  = buttonWidth
        		  MarkDown()\Requester\Button()\Result = #Result_Cancel
        		EndIf   
        		
        		If Buttons
        		  
        		  MarkDown()\Requester\UserButtons = Buttons
        		  
        		  MarkDown()\Requester\Button("OK")\Visible     = #False
    				  MarkDown()\Requester\Button("Yes")\Visible    = #False
    				  MarkDown()\Requester\Button("No")\Visible     = #False
    				  MarkDown()\Requester\Button("Cancel")\Visible = #False
        		  
        		  Number = CountString(Buttons, "|") + 1
        		  
        		  For b=1 To Number
        		    
        		    Label$ = StringField(Buttons, b, "|")
        		    
        		    If FindMapElement(MarkDown()\Requester\Button(), Label$)
        		      
        		      MarkDown()\Requester\Button()\Visible = #True
        		      
        		      wButtons + MarkDown()\Requester\Button()\Width + 7
        		      
        		    ElseIf FindMapElement(Requester\Button(), Label$)
        		      
          		    If AddMapElement(MarkDown()\Requester\Button(), Label$) 
          		      MarkDown()\Requester\Button()\Text    = Requester\Button()\Text
          		      If Requester\Button()\Width > 0
          		        MarkDown()\Requester\Button()\Width = Requester\Button()\Width
          		      Else  
          		        MarkDown()\Requester\Button()\Width = buttonWidth
          		      EndIf  
          		      MarkDown()\Requester\Button()\Result  = Requester\Button()\Result
          		      MarkDown()\Requester\Button()\Visible = #True
          		      wButtons + buttonWidth + 7
          		    EndIf
          		    
          		  EndIf
        		  
        		  Next
        		  
        		  If wButtons : wButtons - 7 : EndIf
        		  
        		  MarkDown()\Requester\ButtonsWidth = wButtons
        		  
        		Else
        		  
      				If Flags & #YesNo 
      				  MarkDown()\Requester\Button("OK")\Visible     = #False
      				  MarkDown()\Requester\Button("Yes")\Visible    = #True
      				  MarkDown()\Requester\Button("No")\Visible     = #True
      				  MarkDown()\Requester\Button("Cancel")\Visible = #False
      				  wButtons = MarkDown()\Requester\Button("Yes")\Width + MarkDown()\Requester\Button("No")\Width + 7
      				ElseIf Flags & #YesNoCancel
      				  MarkDown()\Requester\Button("OK")\Visible     = #False
      				  MarkDown()\Requester\Button("Yes")\Visible    = #True
      				  MarkDown()\Requester\Button("No")\Visible     = #True
      				  MarkDown()\Requester\Button("Cancel")\Visible = #True		 
      				  wButtons = MarkDown()\Requester\Button("Yes")\Width + MarkDown()\Requester\Button("No")\Width + MarkDown()\Requester\Button("Cancel")\Width + 21
      				Else
      				  MarkDown()\Requester\Button("OK")\Visible     = #True
      				  MarkDown()\Requester\Button("Yes")\Visible    = #False
      				  MarkDown()\Requester\Button("No")\Visible     = #False
      				  MarkDown()\Requester\Button("Cancel")\Visible = #False
      				  wButtons = MarkDown()\Requester\Button("OK")\Width
      				EndIf
      				
      				MarkDown()\Requester\ButtonsWidth = wButtons
      				
      			EndIf ;}
    				
    				LoadFonts_("Arial", 9)
    				
    				InitDefault_()
    				
    				If Requester\Padding
    				  MarkDown()\Requester\Padding = Requester\Padding
    				Else  
    				  MarkDown()\Requester\Padding = 10
    				EndIf  
    				
    				;{ _____ Image _____
    				If Image And FindMapElement(Requester\Image(), Image)
    				  
    				  If IsImage(Requester\Image()\Num)
    				    MarkDown()\Requester\Image\Num    = Requester\Image()\Num
    				    MarkDown()\Requester\Image\Width  = Requester\Image()\Width
        		    MarkDown()\Requester\Image\Height = Requester\Image()\Height
    				  EndIf
    				  
    				Else
    				  
      				If MarkDown()\Flags & #Info
      				  MarkDown()\Requester\Image\Num = CatchImage(#PB_Any, ?Information, 2128)
      				ElseIf MarkDown()\Flags & #Question
      				  MarkDown()\Requester\Image\Num = CatchImage(#PB_Any, ?Question, 2196)
      				ElseIf MarkDown()\Flags & #Error
        		    MarkDown()\Requester\Image\Num = CatchImage(#PB_Any, ?Error, 1782)
        		  ElseIf MarkDown()\Flags & #Warning
        		    MarkDown()\Requester\Image\Num = CatchImage(#PB_Any, ?Warning, 1699)
        		  Else  
        		    MarkDown()\Requester\Image\Num = #PB_Default
        		  EndIf
        		  
        		  If IsImage(MarkDown()\Requester\Image\Num)
        		    MarkDown()\Requester\Image\Width  = ImageWidth(MarkDown()\Requester\Image\Num)
        		    MarkDown()\Requester\Image\Height = ImageHeight(MarkDown()\Requester\Image\Num)
        		  EndIf
        		  
        		EndIf  
      		  ;}
        		
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
    				
    				CompilerIf Defined(ModuleEx, #PB_Module)
              BindEvent(#Event_Theme, @_ThemeHandler())
            CompilerEndIf

				  EndIf
				  
				  HideWindow(MarkDown()\Window\Num, #False)
				  
  	    EndIf ;}  
  	    
  	    Parse_(Text)
  	    
  	    DetermineTextSize_()
  	    
  	    ;{ _____ Image _____
  	    If IsImage(MarkDown()\Requester\Image\Num)
  	      If MarkDown()\Requester\Image\Height > MarkDown()\Required\Height
  	        MarkDown()\Required\Height = MarkDown()\Requester\Image\Height
  	      EndIf 
  	    EndIf ;}
  	    
  	    If wButtons > MarkDown()\Required\Width : MarkDown()\Required\Width = wButtons : EndIf

  	    Width  = MarkDown()\Required\Width  + MarkDown()\Margin\Left + MarkDown()\Margin\Right
  	    Height = MarkDown()\Required\Height + MarkDown()\Margin\Top  + MarkDown()\Margin\Bottom + 33
  	    
  	    If IsImage(MarkDown()\Requester\Image\Num)
  	      Width + MarkDown()\Requester\Image\Width + MarkDown()\Requester\Padding
  	    EndIf
  	    
  	    ResizeWindow(MarkDown()\Window\Num, #PB_Ignore, #PB_Ignore, Width, Height)
        ResizeGadget(MarkDown()\CanvasNum, 0, 0, Width, Height)
        
        AdjustScrollBars_()
        
        Draw_(#Horizontal|#Vertical)

  	    Repeat
          Select WaitWindowEvent()
            Case #PB_Event_CloseWindow           ;{ Close window
              If EventWindow() = WindowNum
                quitWindow = #True
              EndIf ;}
            Case #Event_Gadget
              Select EventGadget()  
                Case GNum
                  Select EventType()
                    Case #PB_EventType_LeftClick ;{ Left mouse click
                      quitWindow = #True
                      ;}
                  EndSelect
              EndSelect
          EndSelect
        Until quitWindow
        
        If FindMapElement(MarkDown(), Str(GNum))

          Result = MarkDown()\Requester\Result
          
          UnbindGadgetEvent(MarkDown()\CanvasNum,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
  				UnbindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
  				UnbindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
  				UnbindGadgetEvent(MarkDown()\CanvasNum,  @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
  
          CloseWindow(MarkDown()\Window\Num)
          
          DeleteMapElement(MarkDown(), Str(MarkDown()\CanvasNum))
        EndIf
        
  	  EndIf
  	  
      ProcedureReturn Result
	  EndProcedure

	CompilerEndIf
	
	;- ---------------------------------------
	;- Tooltips 
  ;- ---------------------------------------
	
	CompilerIf #Enable_Tooltips
	  
	  Procedure   TooltipColor(ColorTyp.i, Value.i)
	    
	    Select ColorTyp 
	      Case #Color_Back
	        TooltypStyle\BackColor   = Value
        Case #Color_Border
          TooltypStyle\BorderColor = Value     
        Case #Color_Front
          TooltypStyle\FrontColor  = Value  
      EndSelect
      
      ForEach Tooltips()
        
        If FindMapElement(Markdown(), Str(Tooltips()\CanvasNum))
          
          If TooltypStyle\FrontColor <> #PB_Default
            MarkDown()\Color\Front = TooltypStyle\FrontColor
          EndIf   
          
          If TooltypStyle\BackColor <> #PB_Default
            MarkDown()\Color\Back = TooltypStyle\BackColor
          EndIf
          
          If TooltypStyle\BorderColor <> #PB_Default
            MarkDown()\Color\Border = TooltypStyle\BorderColor
          EndIf
          
          Draw_(#Horizontal|#Vertical)
          
        EndIf
        
      Next  
      
	  EndProcedure  
	  
	  Procedure   TooltipFont(Name.s, Size.i)
	    
	    If Name And Size
	      
  	    TooltypStyle\FontName = Name
  	    TooltypStyle\FontSize = Size
  	    
  	    ForEach Tooltips()
  	      
  	      If FindMapElement(Markdown(), Str(Tooltips()\CanvasNum))
  	        
  	        FreeFonts_()
          
            LoadFonts_(TooltypStyle\FontName, TooltypStyle\FontSize)
            
            DetermineTextSize_()
  
  	        Draw_(#Horizontal|#Vertical)
  	        
  	      EndIf
  	      
  	    Next  
  	    
  	  EndIf  
  	 
	  EndProcedure  
	  
	  Procedure.i Tooltip(Gadget.i, Text.s, Window.i)
	    Define.i GNum, WindowNum, Width, Height, Result
    
	    CompilerIf Defined(ModuleEx, #PB_Module)
        If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
      CompilerEndIf
      
      If IsWindow(Window) And IsGadget(Gadget)
        
        WindowNum = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_BorderLess|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(Window))
        If WindowNum
          
          GNum = CanvasGadget(#PB_Any, 0, 0, 0, 0)
  	      If GNum
  	      
  	        If AddMapElement(MarkDown(), Str(GNum))
  	          
  	          MarkDown()\Window\Num      = WindowNum
  	          MarkDown()\CanvasNum       = GNum
  	          MarkDown()\Tooltips\Gadget = Gadget
  	          MarkDown()\Tooltips\Window = Window
    	        MarkDown()\Type            = #ToolTip 
    	        
    	        MarkDown()\Margin\Left   = 1
    	        MarkDown()\Margin\Right  = 1
    	        MarkDown()\Margin\Top    = 1
    	        MarkDown()\Margin\Bottom = 1
    	        
    	        If AddMapElement(Tooltips(), Str(Gadget))
    	          Tooltips()\WindowNum  = WindowNum
    	          Tooltips()\CanvasNum  = GNum
      	        Tooltips()\Window     = Window
      	        Tooltips()\Gadget     = Gadget
      	      EndIf
      	      
      	      If AddMapElement(Timer(), Str(Gadget))
                Timer()\Delay     = 600
                Timer()\GadgetNum = ToolTips()\Gadget
                Timer()\WindowNum = Tooltips()\Window
              EndIf
              
              If TooltypStyle\FontName = "" Or TooltypStyle\FontSize = #PB_Default
                LoadFonts_("Arial", 9)
              Else  
      	        LoadFonts_(TooltypStyle\FontName, TooltypStyle\FontSize)
      	      EndIf
    	      
    	        InitDefault_()
    	        
    	        If TooltypStyle\FrontColor <> #PB_Default
    	          MarkDown()\Color\Front = TooltypStyle\FrontColor
    	        EndIf   
    	        
    	        If TooltypStyle\BackColor <> #PB_Default
    	          MarkDown()\Color\Back = TooltypStyle\BackColor
    	        EndIf
    	        
    	        If TooltypStyle\BorderColor <> #PB_Default
    	          MarkDown()\Color\Border = TooltypStyle\BorderColor
    	        EndIf
    	        
    	        If GadgetType(ToolTips()\Gadget) <> #PB_GadgetType_Canvas
          		  AddMouseEvents_(ToolTips()\Window, ToolTips()\Gadget)
          		EndIf
          		
          		If IsGadget(ToolTips()\Gadget)
          		  BindGadgetEvent(ToolTips()\Gadget, @_MouseEnterHandler(), #PB_EventType_MouseEnter)
          		  BindGadgetEvent(ToolTips()\Gadget, @_MouseLeaveHandler(), #PB_EventType_MouseLeave)
          		  BindGadgetEvent(ToolTips()\Gadget, @_MouseMoveHandler(),  #PB_EventType_MouseMove)
          		EndIf   
          		
          		If IsGadget(ToolTips()\CanvasNum)
          		  SetGadgetData(ToolTips()\CanvasNum, ToolTips()\Gadget)
          		  BindGadgetEvent(ToolTips()\CanvasNum, @_MouseLeftClickHandler(),  #PB_EventType_LeftClick)
  		          BindGadgetEvent(ToolTips()\CanvasNum, @_MouseRightClickHandler(), #PB_EventType_RightClick)
          		EndIf   
          		
          		If IsWindow(ToolTips()\Window)
                AddWindowTimer(ToolTips()\Window, #TooltipTimer, 200)
                BindEvent(#PB_Event_Timer,       @_TimerEventHandler(),  ToolTips()\Window)
                BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), ToolTips()\Window)
              EndIf

    	        CompilerIf Defined(ModuleEx, #PB_Module)
                BindEvent(#Event_Theme, @_ThemeHandler())
              CompilerEndIf

    	        Parse_(Text)
    	    
    	        DetermineTextSize_()
    	        
    	        Width  = MarkDown()\Required\Width  + MarkDown()\Margin\Left + MarkDown()\Margin\Right  + 2
    	        Height = MarkDown()\Required\Height + MarkDown()\Margin\Top  + MarkDown()\Margin\Bottom + 2
    	        
    	        ResizeWindow(MarkDown()\Window\Num, #PB_Ignore, #PB_Ignore, Width, Height)
    	        ResizeGadget(MarkDown()\CanvasNum, 0, 0, Width, Height)
    	        
              MarkDown()\Area\X       = 0
              MarkDown()\Area\Y       = 0
              MarkDown()\Area\Width  = MarkDown()\Required\Width
              MarkDown()\Area\Height = MarkDown()\Required\Height
              
              Draw_()
              
              If IsWindow(ToolTips()\Window)
                SetActiveWindow(Window)
              EndIf
              
              Result = #True
            EndIf 
            
  	      EndIf
  	      
  
        EndIf
        
      EndIf
      
      ProcedureReturn Result
	  EndProcedure  
	  
	CompilerEndIf  
	
	;- ---------------------------------------
	;- Draw on Canvas
  ;- ---------------------------------------
	
  CompilerIf #Enable_DrawCanvas
	  
	  Procedure   Text(X.i, Y.i, Text.s, FrontColor.i=#PB_Default, BackColor.i=#PB_Default, Width.i=#PB_Default, Height.i=#PB_Default)
	    Define.i MapElement
	    
	    If FindMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    ElseIf AddMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    EndIf  
	    
      If MapElement
        
        MarkDown()\Type = #DrawCanvas
        
        MarkDown()\Size\X = X
				MarkDown()\Size\Y = Y
				MarkDown()\Size\Width  = Width
				MarkDown()\Size\Height = Height

				MarkDown()\Color\Front = FrontColor
				MarkDown()\Color\Back  = BackColor
				
				MarkDown()\LineSpacing = 1.06
				
				If FrontColor = #PB_Default : MarkDown()\Color\Front = $000000 : EndIf 
				If BackColor  = #PB_Default : MarkDown()\Color\Back  = $FFFFFF : EndIf 
				
				If MarkDown()\Font\Normal = #False
				  Debug "Error: No fonts loaded"
				  ProcedureReturn #False
				EndIf
				
				MarkDown()\Text = Text
    
				Parse_(Text)
				
        DrawingTextSize_()
        
        DrawTextMD_()
        
        ProcedureReturn #True
      EndIf  

	  EndProcedure
	  
	  Procedure   LoadFonts(Name.s, Size.i) ; Use it before StartDrawing()
  	  Define.i MapElement
	    
	    If FindMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    ElseIf AddMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    EndIf  
	    
	    If MapElement
	      
	      MarkDown()\Type = #DrawCanvas
	      
	      FreeFonts_()
        
        LoadFonts_(Name, Size)
        
        DrawingTextSize_()
	      
	    EndIf
      
    EndProcedure
	  
	  Procedure.i Height(Canvas.i, Text.s="")
	    Define.i MapElement
	    
	    If FindMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    ElseIf AddMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    EndIf  
	    
	    If MapElement
	      
	      MarkDown()\Type = #DrawCanvas
	      
	      If MarkDown()\Font\Normal = #False
				  Debug "Error: No fonts loaded"
				  ProcedureReturn #False
				EndIf
	      
				If Text
				  
	        MarkDown()\Text = Text
	        
	        Parse_(Text)
	        
          DrawingTextSize_()
          
          ProcedureReturn MarkDown()\Required\Height
	      Else
	        ProcedureReturn MarkDown()\Required\Height
	      EndIf   
	      
	    EndIf   
	    
	  EndProcedure
	  
	  Procedure.i Width(Canvas.i, Text.s="")
	    Define.i MapElement
	    
	    If FindMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    ElseIf AddMapElement(MarkDown(), #DrawText)
	      MapElement = #True
	    EndIf  
	    
	    If MapElement
	      
	      MarkDown()\Type = #DrawCanvas
	      
	      If MarkDown()\Font\Normal = #False
				  Debug "Error: No fonts loaded"
				  ProcedureReturn #False
				EndIf
	      
				If Text
				  
				  MarkDown()\Text = Text
				  
				  Parse_(Text)
				  
				  DrawingTextSize_()
				  
          ProcedureReturn MarkDown()\Required\Width
	      Else
	        ProcedureReturn MarkDown()\Required\Width
	      EndIf   
	      
	    EndIf 
	    
	  EndProcedure  
	  
	CompilerEndIf
	
	;- ---------------------------------------
	;- Help - Window
  ;- ---------------------------------------
	
	CompilerIf #Enable_CreateHelp
	  
	  Procedure.i CreateHelp(File.s)
	    
	    ClearList(Help\Item())
	    Help\File = File
	    
	    ProcedureReturn #True
	  EndProcedure  
	  
	  Procedure.i AddHelpItem(Title.s, Markdown.s, Label.s="", Level.i=0)
	    
	    If AddElement(Help\Item())
	      Help\Item()\Titel = Title
	      Help\Item()\Text  = Markdown
	      Help\Item()\Label = Label
	      Help\Item()\Level = Level
	    EndIf  
	    
	  EndProcedure

	  Procedure   SaveHelp() 
	    Define.i Pack, JSON, Size
	    Define.s File$
	    Define   *Buffer
	    
	    If CreatePack(Pack, Help\File, #PB_PackerPlugin_Zip)
    
        If CreateJSON(JSON)  ;{ Save Markdown
          
          InsertJSONList(JSONValue(JSON), Help\Item())
          
          Size = ExportJSONSize(JSON)
          If Size
            *Buffer = AllocateMemory(Size)
            If *Buffer
              If ExportJSON(JSON, *Buffer, Size)
                AddPackMemory(JSON, *Buffer, Size, "Help.json")
              EndIf
              FreeMemory(*Buffer)
            EndIf
          EndIf
         
          FreeJSON(JSON)
          ;}
        EndIf
        
        ForEach Help\Item()  ;{ Look for images
          
          If AddMapElement(MarkDown(), "Parse")
	    
	          Parse_(Help\Item()\Text)
	        
	          ForEach MarkDown()\Image()
	            File$  = GetAbsolutePath_(MarkDown()\Path, MarkDown()\Image()\Source)
	            AddPackFile(Pack, File$, GetFilePart(File$))
  	        Next 
  	        
  	        DeleteMapElement(MarkDown())
  	      EndIf
  	      ;}
  	    Next
  	    
        ClosePack(Pack)
      EndIf

	  EndProcedure

	CompilerEndIf
	
	CompilerIf #Enable_HelpWindow

	  CompilerIf Defined(PDF, #PB_Module)
	  
  	  Procedure.s Help2PDF(Title.s, File.s, FilePDF.s="", Orientation.s="P", Format.s="")
  	    Define.i PDF, Pack, JSON, Size, Counter
  	    Define.s FileName$, String$
  	    Define   *Buffer
  	    
  	    NewList TOC.TOC_Structure()
  	    NewMap  Keywords.Keywords_Structure()
  	    NewMap  Glossary.Glossary_Structure()
  	    NewList Item.Item_Structure()
  	    NewList Found.s()
  	    NewList Links.Links_Structure()
  	    
  	    If AddMapElement(MarkDown(), "Help")
  	      
  	      MarkDown()\Type = #HelpWindow

  	      ;{ _____ Load Help File _____
    	    Pack = OpenPack(#PB_Any, File, #PB_PackerPlugin_Zip)
    	    If Pack
    	      
    	      ClearMap(MarkDown()\ImageMem())
    	      
    	      If ExaminePack(Pack)
        
              While NextPackEntry(Pack)
                
                FileName$ = PackEntryName(Pack)
                
                Size = PackEntrySize(Pack, #PB_Packer_UncompressedSize)
                
                *Buffer = AllocateMemory(Size)
                If *Buffer
                  If UncompressPackMemory(Pack, *Buffer, Size, FileName$) <> -1
                    Select FileName$
                      Case "Help.json" ;{ Help file
                        JSON = CatchJSON(#PB_Any, *Buffer, Size)
                        If JSON
                          ExtractJSONList(JSONValue(JSON), Item())
                          FreeJSON(JSON)
                        EndIf ;}
                      Default ;{ Image
                        If AddMapElement(MarkDown()\ImageMem(), FileName$) 
                          MarkDown()\ImageMem()\Buffer = *Buffer
                          MarkDown()\ImageMem()\Size   = Size
                          Select GetExtensionPart(FileName$)
                            Case "jpg", "jpeg"
                              MarkDown()\ImageMem()\Type = PDF::#Image_JPEG
                            Case "png"
                              MarkDown()\ImageMem()\Type = PDF::#Image_PNG
                          EndSelect    
                        EndIf ;}
                    EndSelect
                  EndIf
                EndIf
                
              Wend
              
            EndIf
            
            ClosePack(Pack)
    	    EndIf ;}
    	    
    	    MergeHelp(Item(), TOC(), Glossary(), Keywords(), Links())

    	    PDF = PDF::Create(#PB_Any, Orientation, "", Format)
          If PDF
            
            PDF::SetInfo(PDF, PDF::#Title, Title)
            
            PDF::SetMargin(PDF, PDF::#TopMargin,  10)
            PDF::SetMargin(PDF, PDF::#LeftMargin, 10)
            
            PDF::EnableTOCNums(PDF, #False)

            If Title
              PDF::AddPage(PDF)
              PDF::SetPageNumbering(PDF, #False)
              PDF::SetFont(PDF, "Arial", "B", 20)
              PDF::Cell(PDF, Title, #PB_Default, #PB_Default, #False, PDF::#NextLine, PDF::#CenterAlign)
              PDF::Ln(PDF, 10)
              
              PDF::SetFont(PDF, "Arial", "B", 10)
              PDF::SetColorRGB(PDF, PDF::#TextColor, 70, 130, 180)
              
              ForEach TOC()
                If TOC()\Level = 0
                  String$ = GetString_(TOC()\Words())
                  PDF::Cell(PDF, String$, #PB_Default, #PB_Default, #False, PDF::#NextLine, "", #False, "#" + TOC()\Label)
                  PDF::Ln(PDF, 1)
                EndIf
              Next
              
              PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 0)
              
            EndIf
            
            PDF::EnableTOCNums(PDF, #True)
            
            LoadFonts_("Arial", 12)
            
            ForEach Item()

              PDF::AddPage(PDF)

              PDF::SetPageNumbering(PDF, #True)
              
              PDF::AddEntryTOC(PDF, Item()\Titel, Item()\Level)
              
              Clear_()
              
              Parse_(Item()\Text)
              DetermineTextSize_(#True)
              AdjustScrollBars_()
              
              UpdateHelp(#PB_Default, TOC(), Glossary(), Found(), #True)
              
              PDF::BookMark(PDF, Item()\Titel, Item()\Level)
              
              If Item()\Label
                PDF::AddGotoLabel(PDF, "#" + Item()\Label)
              EndIf

              ConvertPDF_(PDF, 10, 10, 12, Item()\Level)

            Next
            
            If FilePDF = "" : FilePDF = GetPathPart(File) + GetFilePart(File, #PB_FileSystem_NoExtension) + ".pdf" : EndIf 
            
            PDF::Close(PDF, FilePDF)
          EndIf

    	  EndIf
    	  
    	  ProcedureReturn FilePDF
  	  EndProcedure
  	  
  	CompilerEndIf 
  	
  	CompilerIf #Enable_ExportHTML 
  	
  	  Procedure.s Help2HTML(Title.s, File.s, Folder.s="HTML", FileHTML.s="")
  	    Define.i PDF, FileID, Pack, JSON, Size, Counter, Level
  	    Define.s File$, FileName$, HtmlFile$, HTML$, Style$, Label$, Start$, Image$, ImagePath$, Path$
  	    Define   *Buffer
  	    
  	    NewMap  Image.s()
  	    NewMap  Keywords.Keywords_Structure()
  	    NewMap  Glossary.Glossary_Structure()
  	    NewList TOC.TOC_Structure()
  	    NewList Item.Item_Structure()
  	    NewList Found.s()
  	    NewList Links.Links_Structure()
  	    
	      ;{ _____ Filename & Folder _____
	      If FileHTML = "" : FileHTML = GetPathPart(File) + GetFilePart(File, #PB_FileSystem_NoExtension) + ".html" : EndIf 
        
        If Folder
          File$ = GetPathPart(FileHTML) + Folder + #PS$ + GetFilePart(FileHTML)
        Else
          File$ = FileHTML
        EndIf
        
        If GetPathPart(FileHTML)
          Path$ = GetPathPart(GetAbsolutePath_(GetPathPart(File$), File$))
        Else
          Path$ = GetPathPart(GetAbsolutePath_(GetCurrentDirectory(), File$))
        EndIf
        
        If FileSize(GetPathPart(File$)) <> -2 : CreateDirectory(GetPathPart(File$)) : EndIf
        ;}  	    
        
  	    If AddMapElement(MarkDown(), "Help")
  	      
  	      MarkDown()\Type = #HelpWindow
  	      
  	      ;{ _____ Load Help File _____
    	    Pack = OpenPack(#PB_Any, File, #PB_PackerPlugin_Zip)
    	    If Pack
    	      
    	      ClearMap(MarkDown()\ImageMem())
    	      
    	      If ExaminePack(Pack)
              While NextPackEntry(Pack)
                FileName$ = PackEntryName(Pack)
                Size = PackEntrySize(Pack, #PB_Packer_UncompressedSize)
                Select FileName$
                  Case "Help.json" ;{ Help file
                    *Buffer = AllocateMemory(Size)
                    If *Buffer
                      If UncompressPackMemory(Pack, *Buffer, Size, FileName$) <> -1
                        JSON = CatchJSON(#PB_Any, *Buffer, Size)
                        If JSON
                          ExtractJSONList(JSONValue(JSON), Item())
                          FreeJSON(JSON)
                        EndIf
                      EndIf
                    EndIf  
                    ;}
                  Default          ;{ Image
                    UncompressPackFile(Pack, GetPathPart(File$) + FileName$)
                    MarkDown()\ImageNum(FileName$) = LoadImage(#PB_Any, GetPathPart(File$) + FileName$)
                    ;}
                EndSelect
              Wend 
            EndIf

            ClosePack(Pack)
    	    EndIf ;}  
    	    
    	    MergeHelp(Item(), TOC(), Glossary(), Keywords(), Links())

    	    ;{ _____ Frames File _____
    	    ForEach Item()
    	      If Item()\Label
    	        Start$ = EscapeHTML_(Item()\Label) + ".html"
    	        Break
    	      EndIf  
    	    Next
    	    HTML$ = "<!DOCTYPE html>" + #LF$ + "<html>" + #LF$ + "<head>" + #LF$ + "<meta charset=" + #DQUOTE$ + "utf-8" + #DQUOTE$ + ">" + #LF$ + "<title>" + Title + "</title>" + #LF$ + Style$ + #LF$ + "</head>" + #LF$
          HTML$ + "<frameset cols=" + #DQUOTE$ + "25%,75%" + #DQUOTE$ +">" + #LF$
          HTML$ + "<frame src=" + #DQUOTE$ + "Navigation.html" + #DQUOTE$ + " name=" + #DQUOTE$ + "Navigation"+ #DQUOTE$ + ">" + #LF$
          HTML$ + "<frame src=" + #DQUOTE$ + Start$ + #DQUOTE$ + " name=" + #DQUOTE$ + "Content" + #DQUOTE$ + ">" + #LF$
          HTML$ + "</frameset>"+ #LF$

  	      FileID = CreateFile(#PB_Any, File$, #PB_UTF8)
          If FileID
    	      WriteStringFormat(FileID,  #PB_UTF8)
    	      WriteString(FileID, HTML$, #PB_UTF8)
    	      CloseFile(FileID)
    	    EndIf
    	    ;}
    	   
    	    ;{ _____ Menu File _____
    	    Style$ = "<style>" + #LF$
    	    Style$ + "ul { List-style-type: none; padding: 0 0 4px 20px; }" + #LF$
    	    Style$ + "li { padding: 3px; }" + #LF$
          Style$ + "</style>" + #LF$
    	    
    	    HTML$ = "<!DOCTYPE html>" + #LF$ + "<html>" + #LF$ + "<head>" + #LF$ + "<meta charset=" + #DQUOTE$ + "utf-8" + #DQUOTE$ + ">" + #LF$ + "<title>" + Title + "</title>" + #LF$ + Style$ + #LF$ + "</head>" + #LF$ + "<body>" + #LF$

    	    ;{ Navigation
    	    Level = 0
    	    
    	    HTML$ + "<ul>" + #LF$

          ForEach Item()
            If Item()\Label
              If Level < Item()\Level
                HTML$ + "<ul>" + #LF$
                Level = Item()\Level
              ElseIf Level > Item()\Level
                HTML$ + "</ul>" + #LF$
                Level = Item()\Level
              EndIf  
              HTML$ + "<li><a href=" + #DQUOTE$ + Item()\Label + ".html" + #DQUOTE$ + " target=" + #DQUOTE$ + "Content" + #DQUOTE$ + ">" + EscapeHTML_(Item()\Titel) + "</a></li>" + #LF$
    	      EndIf 
    	    Next
    	    
    	    HTML$ + "</ul>" + #LF$
    	    ;}
    	    
    	    HTML$ + "</body>" + #LF$ + "</html>"
    	    
    	    If Folder
            HtmlFile$ = GetPathPart(FileHTML) + Folder + #PS$ + "Navigation.html"
          Else
            HtmlFile$ = "Navigation.html"
          EndIf
    	    
  	      FileID = CreateFile(#PB_Any, HtmlFile$, #PB_UTF8)
          If FileID
    	      WriteStringFormat(FileID,  #PB_UTF8)
    	      WriteString(FileID, HTML$, #PB_UTF8)
    	      CloseFile(FileID)
    	    EndIf
    	    ;}
    	    
    	    ;{ _____ CSS File _____
    	    If Folder
            HtmlFile$ = GetPathPart(FileHTML) + Folder + #PS$ + "Markdown.css"
          Else
            HtmlFile$ = "Markdown.css"
          EndIf
          
          Style$ = StyleCSS()
          
    	    FileID = CreateFile(#PB_Any, HtmlFile$, #PB_UTF8)
          If FileID
    	      WriteStringFormat(FileID,  #PB_UTF8)
    	      WriteString(FileID, Style$, #PB_UTF8)
    	      CloseFile(FileID)
    	    EndIf
    	    ;}
    	    
    	    ;{ _____ Create Help Files _____
          ForEach Item()
            
            Clear_()
            
            Parse_(Item()\Text)
            
            UpdateHelp(#PB_Default, TOC(), Glossary(), Found(), #True)
            
            HTML$  = ExportHTML_(Title, "Markdown.css")
            
            Label$ = Item()\Label
            
            If Folder
              HtmlFile$ = GetPathPart(File) + Folder + #PS$ + Label$ + ".html"
            Else
              HtmlFile$ = Label$ + ".html"
            EndIf
            
            FileID = CreateFile(#PB_Any, LCase(HtmlFile$), #PB_UTF8)
            If FileID
      	      WriteStringFormat(FileID,  #PB_UTF8)
      	      WriteString(FileID, HTML$, #PB_UTF8)
      	      CloseFile(FileID)
      	    EndIf
      	    
      	    ForEach MarkDown()\Image()
      	      Image$ = GetFilePart(MarkDown()\Image()\Source)
              Image(Image$) = GetAbsolutePath_(Path$, MarkDown()\Image()\Source)
      	    Next
      	    
          Next
          ;}
          
          ForEach Image()
            
            Image$     = Image()
            ImagePath$ = GetPathPart(Image$)
            
            If ImagePath$ <> Path$
              If FileSize(ImagePath$) <> -2 : CreateDirectory(ImagePath$) : EndIf
              RenameFile(Path$ + GetFilePart(Image$), Image$)
            EndIf  
          Next
          
    	  EndIf
    	  
    	  ProcedureReturn Path$ + GetFilePart(File$)
  	  EndProcedure
  	  
  	CompilerEndIf
  	
  	Procedure   SetAppDataDir(Path.s)
  	  Help\DataDir = Path
  	EndProcedure
  	
  	Procedure   SetAppDataName(FileName.s)
  	  Help\DataName = FileName
  	EndProcedure
  	
  	Procedure   SetHelpFont(Font.i, Type.i=#False)
  	  
  	  If IsFont(Font)
  	    
  	    Select Type
  	      Case #List
  	        Help\Font\ListView = Font
  	      Case #Tree
  	        Help\Font\Tree     = Font
  	      Default
  	        Help\Font\Tree     = Font
  	        Help\Font\ListView = Font
  	    EndSelect    

  	  EndIf
  	  
  	EndProcedure  
  	
  	Procedure   ChangeHelpTopic(Label.s)
	    
  	  CompilerIf Defined(NamedPipe, #PB_Module)
  	    NamedPipe::SendMessage("mdHelp", Label)
  	  CompilerEndIf 
  	  
  	EndProcedure
  	
	  Procedure.s Help(Title.s, File.s, Label.s="", Flags.i=#False, Parent.i=#PB_Default)
	    ; Flags: #AutoResize | #FindKeywords
	    Define.i WindowNum, WindowFlags, quitWindow, cApp
	    Define.i Pack, JSON, Size, Selected, SearchResult, Index
	    Define.s FileName$, Link$, Label$, Search$, AppDataName$
	    Define   *Buffer
	    
	    NewList Found.s()
	    NewList Links.Links_Structure()
	    NewList TOC.TOC_Structure()
	    NewMap  Glossary.Glossary_Structure()
	    NewMap  Keywords.Keywords_Structure()
	    
	    CompilerIf Defined(ModuleEx, #PB_Module)
        If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
      CompilerEndIf
      
      Help\Window\X      = #PB_Ignore
      Help\Window\Y      = #PB_Ignore
      Help\Window\Width  = #PB_Ignore
      Help\Window\Height = #PB_Ignore
      
      If Help\DataDir = "" Or FileSize(Help\DataDir) <> -2
        If Left(GetCurrentDirectory(), Len(GetUserDirectory(#PB_Directory_Programs))) = GetUserDirectory(#PB_Directory_Programs)
          Help\DataDir = GetUserDirectory(#PB_Directory_ProgramData) + GetFilePart(ProgramFilename(), #PB_FileSystem_NoExtension) + #PS$
        Else
          Help\DataDir = GetCurrentDirectory()
        EndIf 
      EndIf
      
      If Help\DataDir
        AppDataName$ = Help\DataDir
      Else
        AppDataName$ = "Help"
      EndIf  
      
      WindowFlags = #PB_Window_Tool|#PB_Window_SystemMenu|#PB_Window_Invisible
      If Flags & #AutoResize : WindowFlags | #PB_Window_SizeGadget : EndIf
      
      If Parent = #PB_Default
  	    WindowNum = OpenWindow(#PB_Any, 0, 0, 630, 520, "",  WindowFlags | #PB_Window_ScreenCentered)
  	  Else
  	    WindowNum = OpenWindow(#PB_Any, 0, 0, 630, 520, "",  WindowFlags | #PB_Window_WindowCentered, WindowID(Parent))
  	  EndIf
  	  
  	  If WindowNum

  	    WindowBounds(WindowNum, 445, 280, #PB_Default, #PB_Default)  

  	    SetWindowTitle(WindowNum, " " + Title)

  	    ;{ _____ Images _____
  	    Help\Image\GoHome     = CatchImage(#PB_Any, ?Home, 460)
        Help\Image\GoNext     = CatchImage(#PB_Any, ?Next, 433)
        Help\Image\GoPrevious = CatchImage(#PB_Any, ?Previous, 461)
        Help\Image\Close      = CatchImage(#PB_Any, ?Close, 540)
        Help\Image\Search     = CatchImage(#PB_Any, ?Search, 506)
  	    ;}
  	    
  	    ;{ _____ TreeGadget _____
  	    CompilerIf Defined(TreeEx, #PB_Module)
  	      Help\TreeNum = TreeEx::Gadget(#PB_Any, 10, 40, 205, 470, "", TreeEx::#AlwaysShowSelection, WindowNum)
  	      TreeEx::SetColor(Help\TreeNum, TreeEx::#FrontColor, $701919)
  	      If IsFont(Help\Font\Tree) : TreeEx::SetFont(Help\TreeNum, FontID(Help\Font\Tree)) : EndIf 
  	    CompilerElse
  	      Help\TreeNum = TreeGadget(#PB_Any, 10, 40, 205, 470, #PB_Tree_AlwaysShowSelection)
  	      SetGadgetColor(Help\TreeNum, #PB_Gadget_FrontColor, $701919)
  	      If IsFont(Help\Font\Tree) : SetGadgetFont(Help\TreeNum, FontID(Help\Font\Tree)) : EndIf 
  	    CompilerEndIf  
  	    ;}
  	    
  	    Help\InputNum = StringGadget(#PB_Any, 40, 12, 92, 21, "")
  	    
  	    CompilerIf Defined(ListView, #PB_Module)
  	      Help\ListNum = ListView::Gadget(#PB_Any, 10, 40, 205, 470, ListView::#GridLines, WindowNum)
  	      ListView::SetColor(Help\ListNum, ListView::#FrontColor, $004B00)
  	      ListView::Hide(Help\ListNum, #True)
  	      If IsFont(Help\Font\ListView) : ListView::SetFont(Help\ListNum, FontID(Help\Font\ListView)) : EndIf 
  	    CompilerElse  
    	    Help\ListNum = ListViewGadget(#PB_Any, 10, 40, 205, 470)
    	    SetGadgetColor(Help\ListNum, #PB_Gadget_FrontColor, $004B00)
      	  HideGadget(Help\ListNum, #True)
      	  If IsFont(Help\Font\ListView) : SetGadgetFont(Help\ListNum, FontID(Help\Font\ListView)) : EndIf 
    	  CompilerEndIf
  	  
  	    ;{ _____ Buttons _____
  	    Help\HomeNum   = ButtonImageGadget(#PB_Any, 10,  10, 25, 25, ImageID(Help\Image\GoHome))
  	    Help\SearchNum = ButtonImageGadget(#PB_Any, 135, 11, 23, 23, ImageID(Help\Image\Search))
  	    Help\PrevNum   = ButtonImageGadget(#PB_Any, 163, 10, 25, 25, ImageID(Help\Image\GoPrevious))
  	    Help\NextNum   = ButtonImageGadget(#PB_Any, 190, 10, 25, 25, ImageID(Help\Image\GoNext))
  	    ;}

  	    ;{ _____ CanvasGadget _____
  	    Help\CanvasNum = CanvasGadget(#PB_Any, 220, 10, 400, 500)
  	    If Help\CanvasNum

  	      If AddMapElement(MarkDown(), Str(Help\CanvasNum))
  	        
  	        MarkDown()\Type = #HelpWindow
  	        
  	        MarkDown()\Window\Num  = WindowNum
  	        MarkDown()\CanvasNum   = Help\CanvasNum

  	        MarkDown()\Path = GetPathPart(File)
  	        If MarkDown()\Path = "" : MarkDown()\Path = GetPathPart(GetCurrentDirectory()) : EndIf

  	        MarkDown()\Size\X      = 220
  				  MarkDown()\Size\Y      = 10
  				  MarkDown()\Size\Width  = 400
  				  MarkDown()\Size\Height = 500
				    MarkDown()\Flags       = Flags | #IgnorePath
				    
          
            MarkDown()\VScroll\Hide   = #True
    				MarkDown()\HScroll\Hide   = #True
    				MarkDown()\Scrollbar\Size = #ScrollBarSize
    				
            ScrollBar()

  	        
  	        If Help\Font\Name And Help\Font\Size
  	          LoadFonts_(Help\Font\Name, Help\Font\Size)
  	        Else  
  				    LoadFonts_("Arial", 11)
  				  EndIf
				  
    				InitDefault_()
    				
    				MarkDown()\Color\Keyword = $000000
    				
				    BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
    				BindGadgetEvent(MarkDown()\CanvasNum,  @_ResizeHandler(),         #PB_EventType_Resize)

				    CompilerIf Defined(ModuleEx, #PB_Module)
              BindEvent(#Event_Theme, @_ThemeHandler())
            CompilerEndIf
            
            If Flags & #AutoResize ;{ Enable AutoResize
    					If IsWindow(MarkDown()\Window\Num)
    						MarkDown()\Window\Width  = WindowWidth(MarkDown()\Window\Num)
    						MarkDown()\Window\Height = WindowHeight(MarkDown()\Window\Num)
    						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), MarkDown()\Window\Num)
    					EndIf
    				EndIf ;}
            
				  EndIf
				  
  	    EndIf
  	    ;}

  	    ;{ _____ Load help file _____
  	    Pack = OpenPack(#PB_Any, File, #PB_PackerPlugin_Zip)
  	    If Pack
  	      
  	      If ExaminePack(Pack)
      
            While NextPackEntry(Pack)
              
              FileName$ = PackEntryName(Pack)
              
              Size = PackEntrySize(Pack, #PB_Packer_UncompressedSize)
              
              *Buffer = AllocateMemory(Size)
              If *Buffer
                If UncompressPackMemory(Pack, *Buffer, Size, FileName$) <> -1
                  Select FileName$
                    Case "Help.json" ;{ Help file
                      JSON = CatchJSON(#PB_Any, *Buffer, Size)
                      If JSON
                        ExtractJSONList(JSONValue(JSON), Help\Item())
                        FreeJSON(JSON)
                      EndIf ;}
                    Default          ;{ Image
                      If AddMapElement(MarkDown()\ImageNum(), FileName$) 
                        MarkDown()\ImageNum() = CatchImage(#PB_Any, *Buffer, Size)
                      EndIf ;}
                  EndSelect
                EndIf
                FreeMemory(*Buffer)
              EndIf
              
            Wend
            
          EndIf
          
          ClosePack(Pack)
  	    EndIf  
  	    ;}
  	    
  	    MergeHelp(Help\Item(), TOC(), Glossary(), Keywords(), Links())
  	  
  	    ForEach Help\Item()
  	      
  	      If Help\Item()\Label : Help\Label(Help\Item()\Label) = ListIndex(Help\Item()) : EndIf

  	      CompilerIf Defined(TreeEx, #PB_Module)
  	        TreeEx::AddItem(Help\TreeNum, TreeEx::#LastRow, Help\Item()\Titel, Help\Item()\Label, #False, Help\Item()\Level)
  	      CompilerElse
  	        AddGadgetItem(Help\TreeNum, -1, Help\Item()\Titel, #False, Help\Item()\Level)
  	      CompilerEndIf

  	    Next 
  	    
  	    If FindMapElement(MarkDown(), Str(Help\CanvasNum))
  	      
  	      If Label ;{ Select start item
  	        If FindMapElement(Help\Label(), Label)
  	          If SelectElement(Help\Item(), Help\Label())
                CompilerIf Defined(TreeEx, #PB_Module) 
                  TreeEx::SetState(Help\TreeNum, Help\Label())
                CompilerElse 
                  SetGadgetState(Help\TreeNum, Help\Label())
                CompilerEndIf
                SetText(Help\CanvasNum, Help\Item()\Text)
                MarkDown()\PageLabel = Help\Item()\Label
                UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found()) 
              EndIf
            EndIf
  	      EndIf ;}
  	      
  	      AddKeyboardShortcut(WindowNum, #PB_Shortcut_Return, #Return)
  	      
  	      AdjustScrollBars_()
  	      Draw_(#Vertical|#Horizontal)
  	      
  	      JSON = LoadJSON(#PB_Any, Help\DataDir + AppDataName$ + ".win")
          If JSON
            ExtractJSONStructure(JSONValue(JSON), @Help\Window, Help_Window_Structure)
            FreeJSON(JSON)
          EndIf
  	      
  	      If Help\Window\Width >= 445 And Help\Window\Height >= 280
    	      ResizeWindow(WindowNum, Help\Window\X, Help\Window\Y, Help\Window\Width, Help\Window\Height)
    	    EndIf
  	      
  	      HideWindow(WindowNum, #False)
  	      
  	      CompilerIf Defined(NamedPipe, #PB_Module)
  	        NamedPipe::Create("mdHelp", #Event_Message)
  	      CompilerEndIf
  	      
    	    Repeat
            Select WaitWindowEvent()
              Case #PB_Event_CloseWindow ;{ Close window
                If EventWindow() = WindowNum
                  
                  If GetWindowState(WindowNum) = #PB_Window_Normal
                    Help\Window\X      = WindowX(WindowNum)
                    Help\Window\Y      = WindowY(WindowNum)
                    Help\Window\Width  = WindowWidth(WindowNum)
                    Help\Window\Height = WindowHeight(WindowNum)
                  EndIf
                
                  quitWindow = #True
                EndIf ;}
              CompilerIf Defined(NamedPipe, #PB_Module)
                Case #Event_Message ;{ Change label

                  If NamedPipe::EventPipe() = "mdHelp"
                    
                    Label$ = Trim(NamedPipe::GetEventMessage("mdHelp"))
                    
                    If FindMapElement(MarkDown(), Str(Help\CanvasNum))

                      If FindMapElement(Help\Label(), Label$)
                        If SelectElement(Help\Item(), Help\Label())
                          CompilerIf Defined(TreeEx, #PB_Module)
                            TreeEx::SetState(Help\TreeNum, Help\Label())
                          CompilerElse  
                            SetGadgetState(Help\TreeNum, Help\Label())
                          CompilerEndIf
                          SetText(Help\CanvasNum, Help\Item()\Text)
                          MarkDown()\PageLabel = MarkDown()\EventLabel
                          UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found())  
                          AddToHistory_(Help\Label())
                          CompilerIf #PB_Compiler_OS = #PB_OS_Windows
                            SendMessage_(#HWND_BROADCAST, #WM_SYSCOMMAND, #SC_HOTKEY, WindowID(WindowNum))
                          CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
                            ; Thanks to Wolfram
                            cApp = CocoaMessage(0, 0, "NSRunningApplication currentApplication")
                            CocoaMessage(0, cApp, "activateWithOptions:", #NSApplicationActivateAllWindows|#NSApplicationActivateIgnoringOtherApps)
                          CompilerEndIf
                          SetActiveWindow(WindowNum)
                        EndIf
                      EndIf
                      
                    EndIf
                    
                  EndIf
                  ;}
              CompilerEndIf 
              Case #PB_Event_Menu        ;{ Return - Search
              
                If EventMenu() = #Return
                  
                  If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                    If Search_(GetGadgetText(Help\InputNum), Keywords(), Found(), Flags) = #PB_Default
                      UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found())
                    EndIf  
                  EndIf 
                  
                EndIf   
                ;}
              Case #PB_Event_Gadget                
                Select EventGadget() 
                  Case Help\CanvasNum ;{ Links
                    If EventType() = #EventType_Link
                      
                      If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                        If MarkDown()\EventLabel ;{ Table of Contents
                          If FindMapElement(Help\Label(), MarkDown()\EventLabel)
                            If SelectElement(Help\Item(), Help\Label())
                              CompilerIf Defined(TreeEx, #PB_Module) 
                                TreeEx::SetState(Help\TreeNum, Help\Label())
                              CompilerElse 
                                SetGadgetState(Help\TreeNum, Help\Label())
                              CompilerEndIf
                              SetText(Help\CanvasNum, Help\Item()\Text)
                              MarkDown()\PageLabel = MarkDown()\EventLabel
                              UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found())  
                              AddToHistory_(Help\Label())
                            EndIf
                          EndIf
                          GotoHeading_(MarkDown()\EventValue)
                          ;}
                        Else                     ;{ Internal Link
                          If Left(MarkDown()\EventValue, 1) = "#"
                            Label = LTrim(MarkDown()\EventValue, "#")
                            If FindMapElement(Help\Label(), Label)
                              If SelectElement(Help\Item(), Help\Label())
                                CompilerIf Defined(TreeEx, #PB_Module) 
                                  TreeEx::SetState(Help\TreeNum, Help\Label())
                                CompilerElse 
                                  SetGadgetState(Help\TreeNum, Help\Label())
                                CompilerEndIf
                                SetText(Help\CanvasNum, Help\Item()\Text)
                                MarkDown()\PageLabel = Help\Item()\Label
                                UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found()) 
                                AddToHistory_(Help\Label())
                              EndIf
                            EndIf
                          Else
                            RunProgram(MarkDown()\EventValue)
                          EndIf ;}
                        EndIf
                      EndIf
                      
                    EndIf ;}
                  Case Help\TreeNum   ;{ Show item text
                    Select EventType()
                    CompilerIf Defined(TreeEx, #PB_Module)   
                      Case TreeEx::#EventType_Row    
                        If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                          MarkDown()\ScrollOffsetY = 0
                          Selected = TreeEx::GetState(Help\TreeNum)
                          If Selected <> -1
                            If SelectElement(Help\Item(), Selected)
                              SetText(Help\CanvasNum, Help\Item()\Text)
                              MarkDown()\PageLabel = Help\Item()\Label
                              UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found()) 
                              AddToHistory_(Selected)
                            EndIf  
                          EndIf
                        EndIf
                    CompilerElse  
                      Case #PB_EventType_Change
                        If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                          MarkDown()\ScrollOffsetY = 0
                          Selected = GetGadgetState(Help\TreeNum)
                          If Selected <> -1
                            If SelectElement(Help\Item(), Selected)
                              SetText(Help\CanvasNum, Help\Item()\Text)
                              MarkDown()\PageLabel = Help\Item()\Label
                              UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found()) 
                              AddToHistory_(Selected)
                            EndIf  
                          EndIf
                        EndIf  
                      CompilerEndIf    
                    EndSelect   
                    ;}
                  Case Help\HomeNum   ;{ Button - Home
                    
                    If EventType() = #PB_EventType_LeftClick
                      
                      If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                        
                        If Help\Search ;{ Close Search List
                          
                          EnableSearch_(#False)
                          Help\Search = #False
                          ClearList(Found())
                          ;}
                        Else           ;{ Home Button
                          
                          MarkDown()\ScrollOffsetY = 0
                          
                          If FirstElement(Help\Item())
                            SetText(Help\CanvasNum, Help\Item()\Text)
                            MarkDown()\PageLabel = Help\Item()\Label
                            UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found()) 
                            CompilerIf Defined(TreeEx, #PB_Module)
                              TreeEx::SetState(Help\TreeNum, 0)
                            CompilerElse
                              SetGadgetState(Help\TreeNum, 0)
                            CompilerEndIf 
                          EndIf
                          ;}
                        EndIf
                        
                      EndIf
                      
                    EndIf  
                    ;}
                  Case Help\NextNum   ;{ Button - Next
                    
                    If EventType() = #PB_EventType_LeftClick
                      If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                        If NextElement(Help\History())
                          If SelectElement(Help\Item(), Help\History())
                            SetText(Help\CanvasNum, Help\Item()\Text)
                            MarkDown()\PageLabel = Help\Item()\Label
                            UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found()) 
                            CompilerIf Defined(TreeEx, #PB_Module) 
                              TreeEx::SetState(Help\TreeNum, Help\History())
                            CompilerElse 
                              SetGadgetState(Help\TreeNum, Help\History())
                            CompilerEndIf
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                    ;}
                  Case Help\PrevNum   ;{ Button - Previous
                    If EventType() = #PB_EventType_LeftClick
                      If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                        If PreviousElement(Help\History())
                          If SelectElement(Help\Item(), Help\History())
                            SetText(Help\CanvasNum, Help\Item()\Text)
                            MarkDown()\PageLabel = Help\Item()\Label
                            UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found())
                            CompilerIf Defined(TreeEx, #PB_Module) 
                              TreeEx::SetState(Help\TreeNum, Help\History())
                            CompilerElse 
                              SetGadgetState(Help\TreeNum, Help\History())
                            CompilerEndIf
                          EndIf  
                        EndIf  
                      EndIf
                    EndIf   
                    ;} 
                  Case Help\SearchNum ;{ Button - Search
                    
                    If FindMapElement(MarkDown(), Str(Help\CanvasNum))
                      
                      If Search_(GetGadgetText(Help\InputNum), Keywords(), Found(), Flags) = #PB_Default
                        UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found())
                      EndIf  
                    
                    EndIf   
                    ;}  
                  Case Help\ListNum   ;{ Search List
                    
                    If EventType() = #PB_EventType_LeftClick
                      
                      CompilerIf Defined(ListView, #PB_Module)
                        Index = ListView::GetItemData(Help\ListNum, ListView::GetState(Help\ListNum))
                      CompilerElse
                        Index = GetGadgetItemData(Help\ListNum, GetGadgetState(Help\ListNum))
                      CompilerEndIf

                      If Index <> -1
                        If SelectElement(Help\Item(), Index)
                          SetText(Help\CanvasNum, Help\Item()\Text)
                          MarkDown()\PageLabel = Help\Item()\Label
                          UpdateHelp(Help\CanvasNum, TOC(), Glossary(), Found()) 
                          CompilerIf Defined(TreeEx, #PB_Module) 
                            TreeEx::SetState(Help\TreeNum, ListIndex(Help\Item()))
                          CompilerElse 
                            SetGadgetState(Help\TreeNum, ListIndex(Help\Item()))
                          CompilerEndIf
                        EndIf
                      EndIf
    
                    EndIf
                    ;}
                EndSelect
            EndSelect
          Until quitWindow
          
          JSON = CreateJSON(#PB_Any)
          If JSON
            InsertJSONStructure(JSONValue(JSON), @Help\Window, Help_Window_Structure)
            SaveJSON(JSON, Help\DataDir + AppDataName$ + ".win")
            FreeJSON(JSON)
          EndIf
          
          CompilerIf Defined(NamedPipe, #PB_Module)
            NamedPipe::Close("mdHelp")
          CompilerEndIf
          
        EndIf

  	    CloseWindow(WindowNum)

        DeleteMapElement(MarkDown(), Str(Help\CanvasNum))
      EndIf
      
      If IsImage(Help\Image\GoHome)     : FreeImage(Help\Image\GoHome)     : EndIf 
      If IsImage(Help\Image\GoNext)     : FreeImage(Help\Image\GoNext)     : EndIf
      If IsImage(Help\Image\GoPrevious) : FreeImage(Help\Image\GoPrevious) : EndIf
      If IsImage(Help\Image\Search)     : FreeImage(Help\Image\Search)     : EndIf
      If IsImage(Help\Image\Close)      : FreeImage(Help\Image\Close)      : EndIf
      
      ProcedureReturn Label
    EndProcedure
    
	CompilerEndIf
	
	;- ==========================================================================
	;- Module - DataSection
	;- ==========================================================================
	
	;{ _____ Load Emoji _____
	CompilerIf #Enable_Emoji
  	LoadEmojis_()
  CompilerEndIf 
  ;}
  
  ;{ _____ DataSection _____
  ; Author:   Emily Jäger
  ; License:	CC BY-SA 4.0 <https://creativecommons.org/licenses/by-sa/4.0/>
  ; Source:   <https://openmoji.org>
  
  CompilerIf Defined(PDF, #PB_Module)
    
    DataSection
      Check0:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$6891900000000208,$5948700900000036,$2E0000232E000073,
             $0000763FA5780123,$DA78544144494300,$FC1A206464646063,$AA07AF11441FFFFF,$F7F868B00FC2C201,$5881B6481A691FEF,
             $6A6A06D2D31F100D,$1A7C24E241B70E40,$40049033E8780208,$C6122D000893FE1A,$0000007C71B33E4E,$6042AE444E454900
      Data.b $82
      Check1:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$6891900000000208,$414449DB00000036,$830DEB929DDA7854,
             $0AC1043B09840C30,$93AC03B2812C04B0,$0808C043004B101D,$5C0FA2415FA40EC1,$C5F3BE3B223FD6AA,$CE7394A532779476,
             $C20F62FDE57B8C93,$59450C30A69A7251,$5D7514517DF7D081,$EEE733CF38404107,$D2CB2D9659D2040B,$273CF39024924D34,
             $C265F7DF638E3F05,$6BE148B5ADA40C30,$7E48A28AAAAB09AD,$AF2940521C775512,$385B6DA776141337,$D34BF4D34E8101A0,
             $B83467840B7D02A2,$8E3D807B91B92CB2,$0C10423AEBA631A3,$C2A3ED0C4A63850A,$A5F5D75B01EF3881,$B9299A6E29CCD607,
             $2053DF174BFAFECD,$1B84FEF569EF405C,$B30899A7E1CE01A8,$444E454900000000
      Data.b $AE,$42,$60,$82
    EndDataSection
    
  CompilerEndIf
  
	CompilerIf #Enable_Emoji

    DataSection
      Worry:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449DC01,$FAFC043FEFFFF863,$36E1D1C9ECF663F5,$3109BA49A9869171,$9FD5EDED66C1E1FA,
             $EA100C030FFE7F3F,$16EBC63E011B8DC6,$CEB5FFF5A97AFFAB,$7DFF695F7F3AD7BF,$CE8FA056BB6C79AD,$BCDE6FAA113B7DDE,
             $9FC68EFEF1A7E419,$20EA80FF45405A97,$3354FEFC9026B5E8,$D5204DF6C7735933,$737935F7F1FCFE7F,$2F843A3C41B3BB5B,
             $D2880D5DEDF05E2D,$4CC28130D8916CD2,$5FB50342D48F2F91,$15ECF178B0C57ABD,$17A8ED561E2FD573,$01102A6C12370DFB,
             $F253325F932CB645,$D88614E2D2B511CA,$B93D86404F6F8748,$F2265752C62E2EA2,$04F9A473A592E617,$42237082566D0F98,
             $7D6E410CA36219F4,$CF0BA7B6B1F5F3AD,$2A7627D570D2899C,$F10AA33ADCF1D8B8,$16944C43169E714F,$9A82D7AF6A3F1A5C,
             $53C7E8803310410D,$4B28A3286BE0844D,$A813DBE9DA36219B,$E3F982A2156B3DA2,$F9C2E304A2920423,$6B8192CE96F883C3,
             $C162B15867D50F0B,$507F3E6090CAC9FC,$753180C38433C7E9,$55ECCFF824229772,$5FEFF7F864CEA9A9,$F6689AEBF3F98050,
             $1F00F2D0317243FE,$D1F2E2823FEFF7F5,$58EAABD3CE4047A3,$F2946C5691E5F73D,$4E9A0A2981FBC391,$6736681A12793C9E,
             $F3FE71E11C303292,$3ABE012AE596C685,$00405549409ECE67,$1C62138BB5DAD274,$69815423A2F52263,$9FEE8CD66ADC3A30,
             $98CE0000D5C27F3F,$0000E96325D4A7A5,$42AE444E45490000
      Data.b $60,$82
      Wink:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449DB01,$20FFBFFFFFFFF863,$24966B35BFDFEFF0,$6847451B45C4BAC6,$9F4ED844C7E8C427,
             $C030FF8FC7E3FDDE,$40D0C3E1F0FA5100,$FAD13DBE5553F9B3,$DED2BF7E821B4AFB,$A9E4F757C8254AB6,$F07DFFFFFFD550A3,
             $EA1BF3FAAFBF81E0,$5A213FA808C87570,$FF7FD520BDC1D0E5,$E353717B37F40DFE,$3CBF94FBB3AD4BD7,$EFF19425E7FD9A82,
             $1ABE815A678FF695,$C162B15863BDDEEF,$F9066A6EAF2AE9A2,$830819018BD475F1,$CFB206AB03FE6B5F,$8B88674CAAAD501F,
             $EAE25DB135DA0472,$379CD6BC37144561,$6F8FD8204C363A45,$1E885848A0392AFB,$F99AC55C21946C43,$7B7E2EC8E20D9DB2,
             $DC8055A79BC2E417,$B82D48D8862D6CE2,$7F99F9F9B86C5D2B,$0827A669EEEFD981,$DCD1033D010B2765,$5200691310C5AF5E,
             $D1E34B7D7FC41AFD,$5AFD3D40F7347525,$8FEFEEE40B4730BB,$35FA02321D86B0B5,$AAA70B26141F543C,$2E9153C364E31DC2,
             $6F612593592A51DE,$B3DAC40685F3FDCC,$1DE140B2AB2B54FB,$B100B49A8F0E6014,$E6BDFAF605ED4B1E,$00EB5EFF4276615A,
             $41357C3029FDF31D,$68FA5C50218C0DE1,$85F3FD5406AEBB3F,$8B12D98D72A9AAE6,$6D63EBE0A920E5FB,$60E093A587FE5C44,
             $3E602A41945379CB,$009572CB7352F5FB,$09D3C18FA7539D5F,$25D63E34B35FAC02,$46B109AC1818C63E,$FAFCF46633B69151,
             $A3CF100000AE0BF5,$000000295C0A08A5,$6042AE444E454900
      Data.b $82
      Smirk:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449C601,$5FFEFF7F030FF863,$B45C43B47C4E64B2,$90218C7C56B87441,$180940BF82E96CBD,
             $F60EDEEF77508060,$AD33C7E54B3A5937,$9204D6BEFFB4AFBF,$1814A59B2E6A9FDF,$F52906A845940260,$9D1BEFE34B7D78D3,
             $4BCFE8C1AAC12F3F,$4FC83353757AD220,$40DFBFCFE181A203,$A808984530A520DD,$4BA58624E806A801,$926DEA14001D02E7,
             $707FE60A88110E88,$0864148A01D5C80E,$3EDD0847C608C4A7,$F3E5F2F2A674B6AB,$F6FBEE81EC22A219,$D477378562ED6B44,
             $01DCF5364453AEF7,$00D35D9F94FBB3A5,$328F8864718849AA,$AAAC320D7BFE8A00,$D509FAE181818450,$D5825A5240A5607F,
             $0C4A1813A2138CCA,$9F579C1E93085171,$BFD20B9437FA5133,$80DB506D91FCA56D,$4AF021A03A80192A,$D8235E4C22036203,
             $1D023944C76620FF,$CBE66B9D100E198D,$58D8FB0906A73FDE,$A59B2DE6CB658667,$603912DD68A60FF2,$4B17A8EC91EF4CE0,
             $1CF9F9174FC8158B,$804C282AA664BE24,$544288604B0C08A1,$C9F28F7A79A5BCBF,$A7BBBCAB0F178A5D,$503320E0F56F0B09,
             $C0DBBDCEE8630378,$E4175AF7F86882D8,$57C6A220EBCC503F,$E77274887BBDDEE3,$BA0028C00DA02DCE,$003A019A6074EE0F,
             $0D38354229442A68,$2125DA3621FA05FE,$E38D0698123638DA,$00834E456E819C62,$AE42D9F4FDA9B8BD,$444E454900000000
      Data.b $AE,$42,$60,$82
      Smile:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449B201,$F8307FEFFFFFF863,$62124B359ADFEFF7,$93B422628CA3E39C,$EF4FA7AC22630CE2,
             $8060187FC7E3F1FE,$5B340D0C3E1F0F50,$AFBFAD13DBF54D30,$2BEDCD4BD7E821B4,$FA3A9E4E747D0255,$0F0783F5441C680F,
             $AB8750DF9E35BCFC,$FA80DAA12F3FA203,$540FDC1D0E55A213,$B37F40DFEFF7F0CE,$6BD0229590353717,$AFA066A9FDF9204D,
             $58AC5618EF77BBC6,$6BDFEE440ABA68B0,$08B80CA1AFA9901D,$9D32AAB5407F3C90,$B7D7D6E211CA2E21,$FFC46B5B58E41434,
             $4A5E4CB2DD2A82BE,$207EA0255ECCED9C,$10CA362197442C37,$F735BD9691E5F722,$29B64791B8096EB4,$510AA13F5D72985A,
             $03A91B10CDAB9450,$BB874E180DC82277,$8F9C36640B5EBDAA,$1CC2DC80643508A2,$8630E46748B8862D,$AA1E19412C6BDF06,
             $6B2EA15385930A0F,$553F9C11894B10AA,$0BA5B365857ADF6A,$7DD9D4885C818432,$0A0EF0A05995D5AA,$B737EAC40D460730,
             $1A45379855AD7735,$03FC43A92E8F2018,$DFEFB7CD3F20EF0C,$2E2D1357D7D2E341,$DAC7D7C67402F121,$A785EE0E87CAD109,
             $F396C1C10D40BF93,$2FDF9EC409D340A6,$39D5F009572CB6B4,$C1A482AA4A38E67D,$C7C6BBC7C6976BB5,$4519C7C56A46C718,
             $E7F3F3D198CDD947,$57B03D7C001AB84F,$000000004E77B2BB,$826042AE444E4549
      Sad:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449BB01,$9AFF7F3F030FF863,$A46C4DB874627B3D,$784E8C5256927A4E,$9FCFE7E55B476988,
             $579B8DD420186AE1,$F5FD562DD7F47C02,$BA3A386D2BEFEB52,$1DDEDF6357D0354D,$500A08DD6EB7D508,$FD101D5903577B7F,
             $4CCAD33C7F220D79,$9FF5480B73B5DD56,$51DCDF0D7CFC7F3F,$DB4D075AF7FA2B87,$5FAF9A41A11A17CF,$D9AAC668B45862BE,
             $4A86FC54815F7F2A,$531EAE3184FF5423,$FBB48D8862492D2D,$5D45727FC81354FE,$74AE044CAEA58C54,$9B43E67E7E292CE9,
             $D886431088DC2095,$4F6D63F3E7087D28,$062E41A513399E17,$BE3B17254EF8F5FB,$74F38A0A20D567DB,$87FD0E20B4A26218,
             $F9203F509AD7D6EC,$346312E80B5EBDA4,$F5028F0C7FD1013F,$7D3B46C4336B6417,$B90AEB603705A27B,$40B0C168C4FE20D0,
             $EB5F6B50D23D69C1,$55AAC311A8445100,$383D0881554FE68B,$88600C0A25945EAF,$00AB5AEC4B76A603,$4CEA9AB55ECCFB31,
             $3E580505FEFF7F86,$FEFA381EE986AEBB,$F7FBFDE34FC02B58,$AF8051E8F47CB8A0,$797E9558AA6BD3D6,$01E8E476A51095A4,
             $E3F1EA40D520B9A0,$7DA927735681C1C7,$37342FEF9C088C7D,$E6733DD1F7F1532F,$A02FA683FC9D2C14,$02B8C5C596EB759E,
             $04D621335C2E2943,$F3F9FDECCE671E98,$B0797E00020D3C27,$0000008A4D372739,$6042AE444E454900
      Data.b $82
      Rofl:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA78544144492E02,$6CACD77F008FF863,$F50F150E8ED28B88,$9D570D8B110A8C17,$15708FB7FBF52531,
             $77FBBFDFEFFC400C,$FD229BCFCBFB064E,$F410DA57DFD689ED,$3EFEB255F6D6A5EB,$77BEA8422F0EC7A2,$9A9BABD8978078E7,
             $C48D13DBE8C87570,$FF5482667BFDA128,$F4AE0647C02BF3F9,$12ED89AD22B86BCF,$6A9FDF3AD7BFC640,$6191FFFBFE4A2466,
             $26E06433C5F2A2E9,$C8995D49750979FD,$561B30D520F235CE,$6A00D70E88634B2F,$5979751DCDFDB345,$907106EEC1189496,
             $421C15D305CD6BC8,$722A2024C26218A3,$448BAB05A3124553,$0746F79904D0BE7F,$73FDD06400F0F8C8,$C431AB04071F406A,
             $3C5C3442B5000986,$28AB5178A2E202AC,$ED53FBF6474F5D5B,$970BA18019348F6F,$621D4B7978110E8B,$0729961BDA57EFF5,
             $5C4A40B45A2C1AFA,$1965D3C5A57ACF60,$A57DFE3681D4C2A2,$022F20678FFBF403,$F6BFBF8A8678B1BD,$02D219D9F9DDE9F4,
             $4469AECF828A765C,$F5FCB7BD3C324B04,$A15B6CEA08700D75,$6CBB61131DAA9598,$9E21496C82E2BCD9,$FEC9D6BE03C95550,
             $337B57D629772722,$3332D5D2C7BBDEEC,$535362B98D836403,$8C4F10ACBA9EB993,$FA4EC5D730E3F486,$0B7805E740C276C1,
             $A2203EC194FCFA7F,$1BA04B40CF47E2FF,$D48CE3139155ECCE,$1AA56ADFA7645C90,$960C052357DC2A6C,$E28016C713C170B8,
             $7ABE974981E978B2,$9A68B21879BC4587,$AD2AF6679A7BBBCC,$67D7EA8F7A7F245F,$9E4B7A06CA971B9A,$02BD6C4E9A02BE3A,
             $FEFFBA3B9BF312FC,$4E8C42635D71BDFD,$4844C4613024B86C,$F5FD959BCDA94624,$001240A5607FC7C7,$AF89F049FF7C5E1C,
             $444E454900000000
      Data.b $AE,$42,$60,$82
      Phone:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA78544144493101,$BD1850834EBD528D,$40913B600E0860CF,$5C0165011E0763A4,$81BC369B3A148480,
             $8C06FB682183BE21,$FA16968C1B4C9D6A,$8D2424F101898428,$E7387726E4BF011A,$4105CF3C92E7E77E,$BACF99BA97165960,
             $A74D65964924886D,$BC18307A1B420FCE,$02043FE1F2E59BC5,$77041378E24B21C4,$94BE85D451454514,$DB6D89F74BCF3C2F,
             $D34D58272B75A69A,$9EC47E7ABAFD7AF4,$971C70104138DD1E,$1A0F7AEBADBC3BA5,$A28820CB2CA69A63,$31A1755D75B7FBE8,
             $7DF6EDDD75D8F1E3,$55741E9BFDF33C38,$8F924EBB3669A855,$522CC6D5555CE8D1,$04B2CB53BE4AC63A,$2AE95DDD349C71C1,
             $207B1C9D4506C34C,$5E1E3524036176BF,$C58E0C8D89934F56,$AC425234C1F53F91,$86FB8B17A68F6C87,$4EA690C30AC2DA40,
             $0C30C1038A39F3E7,$285145BA4749E79E,$1F3E12FE0C30C28A,$8D500C1CD7017C94,$49000000001A2BD6
      Data.b $45,$4E,$44,$AE,$42,$60,$82
      Pencil:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400004E04000073,
             $0000FC938B42014E,$DA78544144499201,$7D1B9B53060FF863,$1FFFF678BC3E34B4,$6CE0FF7FBFFFE044,$1D0D4D29E2006038,
             $04C4D6ECFC170656,$EA00063FE5FAFFFE,$B6AEA930CAD60BFC,$689BFB9475F8DACF,$6FE61636162E698F,$30058FF8A901BF5F,
             $7AA80EC036701D00,$7B7B405070459382,$A1AFB7DBCD8D8DAB,$DAE9ECF0FEA9A2A6,$41C1E1168E89FF68,$59667B339ECF67B3,
             $2FB787DC86BE8959,$B5B17EBE220D98B0,$667B3D9B68E8E8B4,$09D9CE8D878B5B5B,$44BCDE1F6A8E61E6,$DCFE7F3D42019C33,
             $CE9DA7AA680ACACA,$995E39565F76C58B,$1FE1B404A0EC1562,$B685E2F178206AA6,$1D2B6F8B7ED9CC8A,$38845AA61A41AA81,
             $30AE1401893B232A,$1BC53B60A3C5F6F0,$6C433A57AA40AD53,$44A00FE680C0D640,$1B1096A9B5EAB398,$958DEDB20472AF3E,
             $C348354580FA7D3F,$5F45402A4EA1A7EB,$8BB52ACC35013B57,$46A98668EEEDB7F2,$31F2F77E205FF8F1,$B32DCD59A7D749D0,
             $E3E5695A5EF24C2F,$6F0FF6886CDD8E62,$A4BD6DE1101D019F,$EA8DB785A56972C2,$50324570195BADD6,$3E4DED5DCFE7F3F0,
             $EA3AFAAA965E962E,$0AB846CDD8191919,$E2E2E2DB6DB6D26C,$BA04755301F5F5F4,$0000000002047E82,$826042AE444E4549
      Memo:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$2E0000232E000073,
             $0000763FA5780123,$DA78544144494A01,$C826C3FC038FF863,$2A2A018E5E6E6E60,$EA847777776CE02A,$5903FFC69C2CACAC,
             $C861FEE303959990,$E31619ECF67CCCCC,$A1B5FAFD7C3640CB,$7F3F5F9BEDCEE1A1,$CF970FF8C4366021,$FA7DF9F8C59AD9B7,
             $5959766E1AA409F4,$F07A5D2E97BBB219,$BB3726877B4741E0,$B3504ECE81AEA10B,$D6322FD7DB0361DF,$737B475B63B9D951,
             $EC86369EC6D3A793,$8302EF3F9FCFECEC,$6BEDC7E3F1F030DD,$1767993DAB05E617,$C170BF18989A6AE8,$A377AA8073BB883C,
             $7EA98596260B9582,$D190239565F4E95A,$DF7B408212895ADD,$20607BEDF6F77DBF,$F5FA4D4F4170B85C,$54838A1D2B4FFB62,
             $5F144D0F099AAF37,$23E25353A9D4C102,$7C334D5D42CCD23B,$875757545C6D7654,$28282BFDFEFE7633,$7CBB6EE7EB25A468,
             $B37402B208A07CC9,$FF73D3D3D3B9DCEF,$C25C582C8AB87DFE,$9883FD412B8BFECD,$A5E3025555250FFD,$B02AA4802B1CA2AC,
             $ACE354040002FF2F,$00000000CC33896C,$826042AE444E4549
      Mail:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$2E0000232E000073,
             $0000763FA5780123,$DA78544144496701,$0513FEFF060FF863,$B558255223FDFE18,$4444786464428282,$8A8A8916402A2444,
             $717066D6D6D1AA02,$F4F6773E8D8B8E72,$9791079C2F67F385,$0B980CEE7F3D9DCE,$A5A58A52526E4045,$B3B9BCDC5C5C4325,
             $5605399ECF43C3C3,$0A0D01101D591A7A,$F7F7F32B2B2F0F0F,$ECFE7F3F8D8D8865,$9CCF4343420BF9C2,$85E2EEA21B31093E,
             $A80FF40F1F4E6773,$3548267B3D9AAAAA,$7C8B25D2C4886CD0,$CF7104391E8E7C7C,$E1E83E1C8FE77385,$520A540B5F5F51E1,
             $31071F1B10CDE01D,$329D9D9D6DB6DB69,$F772001D0F873232,$D8D8DD25232DDDED,$7B370D5501D5D5D8,$8EC792D2D2E9F4FA,
             $84848482693C9E1E,$0A6D369C902DBDBD,$F2CACAA929292AD0,$24994EA7AA607359,$E7CB8ED77BB92125,$28147E389E7501CF,
             $0F079D8809D4FA72,$05CFCFCE969693EC,$1D0E7207D7D7D6A9,$A31740D3840B0FDC,$E4E4E587C3E1E085,$7C0C0C0C19D5D5D4,
             $082828206183BCFC,$3E7E7E02460D0CC6,$751FF863580C9540,$0354B8BFC13609D2,$1D1541BFD109A500,$4E4549000000004D
      Data.b $44,$AE,$42,$60,$82
      Laugh:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449EA01,$5DFEFF7F030FF863,$B45C43B47C4E64B2,$97B204902EB84C41,$12B83FDFEFFB9D2E,
             $7F60EDEEF77D0806,$FAD33C7E54B3A593,$A67F7D182FFB4AF7,$5019BFB072A664BE,$4FC834A2018CA216,$2F3FA288356DF5E3,
             $9BABD10034C2FEB5,$181AC0F79A7E419A,$034B7D7D4D00F680,$A81D53757A1A0559,$00E64BC58654E806,$C3675AF7FA14001D,
             $ACA2B86114ECB912,$65EC21E54B8DA144,$1910CF9F2F9654B3,$D3C84426A9FDF0EE,$106DCDE191919F99,$0BCAE5ED901B6817,
             $91C621235CF1FA91,$7CBEA161B877E801,$FDDC811E5F8C6CEC,$0068431B2B26A1F1,$4318F8F5E80A441F,$561E2EFB8428B886,
             $4D345DCE06433C59,$92A817381521D2E6,$EB52F5FAC803A801,$F6D9882260506A17,$6B6F245FAD689EDF,$9DA1131A6D1B15A3,
             $094401A09A93A096,$1A56D64611313A31,$189D6312DFA05940,$D5C7AB930C05B180,$3333CD1C3CF94424,$6ADA3A3B3B3B3AD2,
             $2C1DDDF30A8B6B6B,$325D509FAE05C4A4,$860450C026141553,$7572C583D20A3025,$43A4D422D4F5AB15,$95750B4595822454,
             $E18044825294F40A,$B4586F0A0A68141D,$192F9CD1A6BF3E6B,$AB67D0A96E562A66,$94D22C621F2D6151,$7FB8D3F60F140127,
             $9A06E981E6340EEF,$59DEEF83032A664E,$FD519D6E943B938D,$A9A0550CE97350FC,$80CFFBFFFF4AC0F7,$ED1B179B2D97069C,
             $0C05A91B1A6D1094,$28173E5F2C746001,$B48477CD0003570E,$000000006B90C72D,$826042AE444E4549
      Eyes:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449F901,$5BFDFEFF030FF863,$B45C4BAC624966B3,$4C41AC6276844C51,$FE7F3FDDE9F4ED84,
             $3E1F0F508061AB86,$DBE5553F9B340D0C,$EFE881B4AF7FAD13,$52ADB6B52F5FED2B,$5C28EA793FD5F209,$6B79F81E0F07DFF5,
             $0748A417FEA1BF3C,$10836609AD79FE48,$7B83A1CAB4427F50,$7B3008080E81AA41,$E6A1F1F128035371,$EB5EFF45105A979F,
             $9FD691E5FDAD79FC,$6AFA066A9FDF3AD7,$058AC5618EF77BBC,$EAEAA03F9F2BA68B,$F9A3EFE52F20A1A2,$4D68C4C8C41AA2F0,
             $4B0D8D1B5B597575,$E219D32A2A0A81D5,$97FAA19112811CA2,$E572BBF3F3F15EAF,$76FE86D036B2464A,$6C2424277607FDD5,
             $33C7FCC0282DB6DB,$6348D8863D10B0AD,$0160A0D651B149A0,$90522800D226257B,$DFC8B02BD5EAFEAD,$728B35375788DCBC,
             $5529AD0E41AA81B5,$5B2F97CBD668B45F,$E4E1F9014FE6CB9B,$9F4FA7FF44A4950E,$EFE342262BBFDBEE,$28D8862D7AF6CD6B,
             $AD4B3A5AC0E07FC3,$B338D0F064140F34,$2A97526B50B4A557,$C8168E616E40A9D0,$034055C3AB1F5FDD,$A0FAA1E1410B9504,
             $D8D21E194D385930,$AD53EECF34300E90,$D02FF7FBF862CCAE,$354675BED1A8B0CB,$AC0E856284004E35,$DE18105039060457,
             $C501BDDEEFDA7E41,$80D70CC1812E303C,$888DAC7D7E6B5E82,$379EB209093A784B,$65B274B0BFA1EA05,$C7D3A9CEAF804AB9,
             $BB5C1A521FE4E9A0,$318C7C5BAC7C6976,$6D22A28CE3E35830,$3C27F3F9F9E8CC67,$FF73A8685800020D,$4900000000FD67D3
      Data.b $45,$4E,$44,$AE,$42,$60,$82
      Cool:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA78544144492702,$FBFFFEFF010FF863,$2EB189259ACD6FF7,$D1713AD1F18651B1,$FE4FE7F3B6517146,
             $2A0060187FF7FBFD,$B40E0FDFEFF75202,$BFAD13DBF55D3798,$1FAD4BCFE881B4AF,$D5F20E522F56B4CF,$206A883FECE978BF,
             $CBC69F806EF77BBE,$FE95C36B5E7F9A5B,$F0F8D4BF6203A57D,$A3E9D4FE58323340,$35F409FCFE7FD520,$B5FFF72813537579,
             $EB04D6BD0835440E,$55F7F4D63EBFB101,$330582C333F9FCFF,$959538E41514DBFA,$34842CACC48D8C04,$38D4B444728BD8D5,
             $D535C40C8D04740D,$69924DE638141405,$BB3FB30888642E69,$C1C1C1C0544C515F,$9884448535B40C1E,$5E564061EDF8E415,
             $063D10B0F96AC768,$2EAEA1A6BF3C0860,$4E73B9143533970D,$2E6E622E10455D55,$431A92467298F57F,$82E6D665D02E8C42,
             $8686969696C6A6A6,$26695EFFC291099A,$AC4500A8E8E988C7,$D0BF7EF92C6C8CAC,$95EFFD99055529AA,$B12962855597D036,
             $EE7B02FDC8E7CBE2,$2281E40B95ED2BF7,$4503AAAF4FA245D5,$7E1DC322183452B2,$E42BF7FDF884D0BE,$A868558501164410,
             $542ED753B9DCC33E,$0B27648B14D5C887,$92D2B368732F9CAD,$302E408249E9D299,$A953B139D6BDFE12,$BEFEB1180190A1A9,
             $6818C2406AEF6F26,$B7A4FBB3F2A5C6E9,$6014C417C60794AD,$09F4FA7FA8F80704,$D7F60CDE6F37F314,$037703A7281B777A,
             $2E3B46A3035E8234,$0798D083D1D8E542,$AF9805056EB75B82,$40D5701B4C09AB98,$77ABE01AA15D6EEF,$86AB03C27009ECE6,
             $7678BC58126018A4,$945C498C624B947C,$F4EDA454718C7C56,$41A784FE7F3FDDE9,$1236E84872E7E800,$4E45490000000008
      Data.b $44,$AE,$42,$60,$82
      Calendar:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$2E0000232E000073,
             $0000763FA5780123,$DA78544144499701,$5E5F2F97030FF863,$4C0FF0247FC572BE,$100B85C2EAB55AAE,$D7CF96533290032E,
             $A6CDD93C64E95B57,$4B5721474F394740,$38F9A695B5F28211,$533357D3CAB774AF,$95A65FEFF7F86652,$00F33B72F728EBC9,
             $BA455E8803202D7D,$B40DFDB085728EBD,$D9647B44DF8CAD8B,$19783734CECC839A,$711D1599EBEF1EED,$1D44279475F1D039,
             $2C222B21D8257190,$DB3AAA00A819DDDE,$BA7ED7D6B7280F4C,$37B0CD021D4C198B,$AD5509D40166E35C,$616F98616F9C212E,
             $4C6CF28D2C0B240C,$0AC820EDF32DECF3,$590D49005AD9E648,$5094028282EA9069,$783F5450CA8001C0,$3A9E4816D6D6C0F0,
             $7D3D3D3925292A75,$3B9EA970FF2D96CB,$B7DBEDDB5B5B6E77,$A05FEFF7F89C4E27,$6081B34E2E6E6E48,$A6F610D540C9E4F2,
             $EA944198CC669B4D,$BB221616174FA7D3,$B75BEA8B1F3F3F3B,$793939377BBDDD6E,$1919BEFEFEBDDEEF,$7A11111119191969,
             $F5DAED77AAE87A7A,$9494A6A6A6ABD5EA,$F53A9D4D566B35B4,$29292D6D6DB3F9FC,$0C8D57437DBEDF29,$E4C1F0F87B7DBEDE,
             $404440964B25C4E4,$CBCBCBCBADADADAA,$4949494151CACACA,$FAE0F77BBDD85858,$BDBAA327BEEB4301,$4E45490000000059
      Data.b $44,$AE,$42,$60,$82
      BookMark:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$2E0000232E000073,
             $0000763FA5780123,$DA78544144490001,$A4585858048FF863,$5F904648C1A4F804,$5C1FE98595878F92,$14040318067FDFFA,
             $CBD043B9475F8585,$DC3C0ABA166BF768,$858514732031C6C8,$879E5AA80881AAE0,$5CDCD514576ABF03,$811616534E61AA18,
             $3FEFFAA489137BA8,$3303AD9AA30B665C,$5F20224AD5162FFB,$60BF92E6C37689BE,$EBCBEE83E1E0FFD5,$FF66A0FFD5707A96,
             $C7AEC1B370261BC3,$3FC98723784A3774,$D408BCBE70BFEAB0,$B55EEF40363EE3EC,$3B05FEFFFF821AC4,$348CCB17A012E808,
             $66C0B48C2BD8D839,$F24636299D8BE0F3,$9190517CBE5FE252,$AC3FE5C48596526E,$DF858525D9D979AA,$01494903640B7DBE,
             $28BFF92456165E41,$03B9DCEF393939AA,$C8228177BBDDC9F7,$4F9DBFD863A5000A,$454900000000FF5C
      Data.b $4E,$44,$AE,$42,$60,$82
      Angry:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0F0000000F000000,$02B4B40000000208,$594870090000001D,$0400009D04000073,
             $0000A16B347C019D,$DA7854414449CE01,$9AFD7EBF030FF863,$A46C5DB874627B3D,$784E8C5256927A4E,$9F8FE7E55B476988,
             $D71B8DD420186AE0,$F5FD562DD7F47C02,$F7FA206D2BEFF352,$54DB63ED2BDFE75A,$0FFEDFEFF6357D03,$5E6F377FBFDFFAA2,
             $A203477F7F500A0F,$AC9999A17CFD0D0E,$7F3FEA9066C773BA,$39ADBBBE1AFAF8FE,$6F0D7439FEEA4BAD,$8435018BD4746AEF,
             $D1618AF57ABE6906,$1E2500A8E62B19A2,$132BAC11894F579C,$9FC43A45379D2B81,$51CAFB20255ECCF7,$BB48D8862492D295,
             $F658BF5D6EA14FEF,$E5BAA06AB84526E0,$237081D13DBE6473,$9C21F4A36219F442,$4262181818D567DB,$9B6272F883FE8105,
             $82887922FD645014,$302D08F8862D3CE2,$675BD902ED62A407,$9EF6F55A86BEFF94,$B40A21B340D992E6,$83C21B6680B5EBDB,
             $55C1A8606D6BCFEC,$68D8866D6C82A1A3,$88916FEA206EB827,$204C36377A03E10E,$901BDFF3A208432F,$172B95864310F082,
             $024C1E3502AA9FCE,$9AB55ECCF834C06D,$3F980484EC504CEA,$9FDF118876DD8EBF,$1EFF7FBC69F8076A,$D5F00A3D1E8FF314,
             $7A045DEE1D55767A,$DA94425691E5F9AD,$E3F1E4E91007A391,$00692773B64121C7,$18110383FE8A80E5,$9EE8FBF8A9979B85,
             $7FC32FEAAC0A7B3E,$D718B8B2DD6EB024,$5884CD70B8E348D8,$7F7B33999B70E8A3,$000051075409FCFE,$C5904085B0AA7155,
             $444E454900000000
      Data.b $AE,$42,$60,$82
      Attention:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$6891900000000208,$414449FC01000036,$3FFFFFFC63DA7854,
             $962B0C8C99001C03,$C2BB2B2667B7DCCD,$5118585998ABC9C4,$7C30303451181924,$D76661C0A4B1F8FC,$139AFABF7FFB9DEF,
             $3435D00A80CB989F,$62D7D36D3BF817D6,$6731C79890C8C7FB,$3FCCB036363631C1,$32FE1A8119FF2590,$A1F0F87F54413030,
             $4692EFF3627ECCB2,$BDFE3FEFBF90B8E6,$0DA714B33D2522F7,$85847BDE915935B5,$941E54B5951A4B99,$7B9BCDB3E74430E7,
             $AFB7868B13939394,$F7FE684D3AD634DF,$7FA7E386B85FFDFA,$F7035F9B9B1DBB9F,$D84A525979434235,$90400D6456796551,
             $2E2E31F66332C050,$BDF503FEFF0D982E,$01B7B5D9B3A2F178,$9C3450EF37862BE8,$D2928885F0FDFF3E,$A19919197F0CFFD6,
             $519C276745E61436,$0FF86D91B2056592,$53099612D4C6170A,$E8F0FD43F2F2F20E,$50355DDEBD49A3D1,$C8AFDF2A683441B7,
             $1DB6BF6BE5DA4685,$A4037A02EEACA809,$9CA2FD34AC3B3721,$3EEF8C6D903FDB14,$5E7A3732952B49FC,$4B295A61F70CC596,
             $FBC64141417EFF77,$0E5CD3E29ECFEFF7,$578B18802050060E,$0CCE252FFBB673FF,$E5DCAF7E77DBCD0F,$B82B2731913F5751,
             $7FC31330988AEF3A,$E32A3FF3FEFDF468,$23131D8B831C7A7F,$8053407F863FD323,$CBDCEE6E60AEC93E,$4407EBA338689A98,
             $0CFFDFFFE1945035,$56FEFB07FF535D4C,$EC043E8704636396,$636307531BE5FFDC,$18EA408787D3D67D,$264C2134948261A1,
             $16FFBFFF25A04606,$0411F13D11B09DEC,$6D3F347505FB9700,$4E4549000000007E
      Data.b $44,$AE,$42,$60,$82
      Bulb:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$6891900000000208,$4144495301000036,$3FFFFFFC63DA7854,
             $1D8EC34D11802903,$6160E763E84C263B,$9389EFF7FBF0CFFC,$61303030A8A8AAA6,$677379B6DB6DB0D7,$C3267DF4C9565CAF,
             $7B8BF57FDE1F4BDF,$EC59097129DD66BF,$FAAFADB75DDDDC1A,$D5E4F826198F2DF7,$608FEB75D11A82EF,$27CE76B1E01010D7,
             $0C8C8C12409FFFC6,$1BAC09417FC63940,$7753CBC1AEC45CB6,$78DF2BE28D2022CB,$1410D7634EDBADCE,$8D814554FD51D8E0,
             $9E779FBAD969A611,$EAF0D76074343707,$C658B4B334ACABD5,$F8873289893F1B35,$0EFDBCDFFEB756F3,$2F3F0202508E1313,
             $D1FAD9AEFF0B0DFD,$8D3C358246539F58,$3FE1E3B863E6C37F,$AB89ED8788527243,$FCBB9C7329AA7EB7,$1403253936B74357,
             $94D1E8F4786CB800,$616365FF7FBFBDA9,$7644EE6969656665,$B15FBFDFEF0D160F,$929ACACACD840562,$35FAFD7C69204292,
             $DEC805CDCDC72727,$68097339BCDF77BD,$72B95E974BA58200,$B1B1B5F6F6F0C809,$000359203F01AC21,$5D963243E1B0C5CB,
             $444E454900000000
      Data.b $AE,$42,$60,$82
      Clip:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$6891900000000208,$414449A101000036,$41AB4B9295DA7854,
             $B92065CACF861851,$C13F948C0DB91764,$06425BB6944F600F,$4A06465290924606,$EA6262184DB94452,$13281801F8A1900F,
             $713B4EB39EF3D703,$FD9EFAD6B66F939C,$3EDDBB725EFDFB7E,$F8F1E32E5CB229DE,$5162C5A54A957AF5,$5A8E1C3803FCD1A3,
             $468D1162C5BE86AD,$B00BFDAB56AEDDBB,$AB561E90E1C3EDDB,$BD7A3A74E9122455,$71C71413C315B9FE,$D033DCB162DA74E9,
             $72E5C5CB9774E9D1,$BFBB4142850D1A35,$9729E3C78D9B3614,$BFED3A74F9B366CB,$3A74CE86DDBB4C0B,$54A95F7EFD93264D,
             $4652DDBB74048CFE,$8EBD7ACE9D3B56AD,$CC3060CB56AD304B,$84328F5EBD303366,$254A9776EDC60ADA,$1152A57F7EFC6186,
             $4C98F3004081C58B,$54A8C1270E7CF9A6,$64C991D781EFC22A,$70820409D60F9F3E,$9823468D366CDC38,$E2FDC80C18312244,
             $4289122AB56A981E,$264F1E3C7AF510A1,$7AF5E07869B0F213,$F28D1A376EDD99EF,$0D1CF234B15E3CF9,$78F060C1E5CB919E,
             $2786CD9B1932663C,$8367E259AFC96596,$0FD2142859F3E7D7,$A0607C2AF23162C5,$EB8E2B56ACA54A93,$025E1428533F1AF5,
             $190E5CB90E1C3FB8,$459B364912253443,$08F004FEF1BBC820,$000031BB71DB8FF6,$42AE444E45490000
      Data.b $60,$82
      Magnifier:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$6891900000000208,$414449CF01000036,$3FFFFFFC63DA7854,
             $6464646490030303,$34B5365E2F578300,$CFE989899CF97CBF,$B9D9D9F68E8E7F9F,$CC0B2006A8465970,$BE8E4E4E61F0F87F,
             $B97979D7EBF5FEBE,$ECF8AF2F2BFDFEFF,$40F443E773B993D9,$2E19151590004035,$9D9D98A8A8A32525,$F48CA7D3E9F1540D,
             $D48505055925451C,$EDDEEF770D7454D4,$59ECC7EBF5FBEBEB,$C9E679DC42368173,$56BFBFC63CF2EE87,$361B0DA4EE8158AC,
             $2A24C8D0C8723D1C,$DBBF57C9CA6E0A2A,$B2592D7E9979520A,$DEEFB7DBED86DD0C,$0323232D4D4D5BBD,$FEF7E5BFDFEFF222,
             $74B7FE61E649AAAC,$BFDE2B600D2452E9,$E7F3F9FC5254577D,$8503333332572B95,$57E5C4E9BBFCBD4F,$A2D175FEF8FE66DB,
             $994949410036E845,$8AB2376BB5EF20A0,$E8783DEF4A735F4A,$89896292B2C5B6CE,$FCFC345896969689,$0A4A4A59393933F9,
             $E0A0A097EBF5F8C8,$82811D1D1C8F47A3,$777FBFDF0100F128,$E206058D8D8A7272,$533A801A80EB75BA,$106AE05454545252,
             $C7E3D2D2D28C801A,$0B85C2E2F178BF8F,$C34200D80CBCBCBC,$5A8C09A181B7DBED,$1C0666E6E6EF6F6F,$B7DBE5C5C5C1A100,
             $04E2713EFF7FBF6F,$DE6F379869F08824,$9E4F27AA81D3E9F4,$35401B80CB6B6B6C,$B9E807F3F9FD1500,$0D5005E033178BC5,
             $BCD93C9E4F111111,$4F0061E11C303379,$E1FED7150000C8D2,$000000007062FD76,$826042AE444E4549
    EndDataSection
    
  CompilerEndIf
  
  CompilerIf #Enable_Requester
    
    ; License: http://creativecommons.org/licenses/GPL/2.0/
    ; Source:  www.inkscape.org / GNOME-Colors
    
    DataSection
      Error:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$59487009000000F4,$0D0000D70D000073,
             $0000789B284201D7,$DA7854414449A806,$C61457544C7997B5,$21B88288E9D00CDF,$C59017051101004A,$7DF71505F7DF710D,
             $8468D6B1A5468DDF,$0DB1AB1FF6269358,$2C80AAC4151154AE,$85C0DD62DA8CBAC5,$2692323AC40B5045,$40AB0DF73B9DFA7A,
             $CF7BDC992FC930D3,$51BCDEFBDCEF7DF7,$59BADDA908694888,$011903BF3F749081,$7AD30B3D9EF48601,$A060467BF86728F4,
             $B5E1AF00FFDFDD21,$5F5F35C177ADD50D,$3198D6F18023043D,$1D137A7E773BE7C6,$89292EF47171A54D,$F473B9E9532725DE,
             $9F37CDFE7A51E8E6,$DDDEED4C6B1D8D6E,$F8A402BFFB5C35C8,$BCDE6B24A84184F8,$67B3DBD14EA7C50F,$2F77B57A41E0F8A9,
             $51B6DB8549DCED15,$BD176BB454EDF6E1,$2DE88743E2A28A8E,$F9FCD650C4C714C2,$3FEC37D7C536B81F,$91F48359DCEE4807,
             $3D2C3057A6A1A199,$B5FCA0EC768A9C7E,$B0D82A3ADD60A96B,$9369B3346E360A81,$708BD7EBE3CEFE19,$8987C3EBD04E27A5,
             $900A0D9AC515A035,$C61AC795C1ADEDE4,$ED5E8C76392B2F8F,$8ADE5397CB794DDE,$5EAFE52572BF9415,$E0353088D66BF94D,
             $2A9DC04AB55F9E71,$65889D0B58927939,$95975EC4880486ED,$2E1772CAE25F9F60,$12C96F298BC5BCA4,$C357C9844CB65BCA,
             $BA5BAF2C22E30754,$42F899BCDCBCD454,$EAA3BDBD92CA3670,$382D2C33D3C5700C,$CA2B80597B06F4D8,$DCA3CDE772973B9D,
             $2A8B45DC9045F3F9,$79E31E19526C30C2,$5B796A20582FD620,$6265EAF5A476C2FE,$5FD0F0F65C035A8F,$DFCB6D0F24B1D8E9,
             $67CF499CCD9E85B2,$398BD367B317A2CD,$544D86616186AA73,$B86A2D78679E31D4,$C882A56EB60A7596,$DDC019AAF60F6248,
             $47DBED15326D023D,$633A780E53A7D3D9,$CE7984B70F0B3D06,$C75E7982CFA06461,$DA298759EB8EB9EB,$55110084C2B79FBF,
             $DDC5FAB373725C02,$9B453D0F67B798DD,$A54EA64F42994C9F,$12CD3699CA30B0EC,$B9C81AA86481C046,$B2759EB8EB94D2A7,
             $B30E8F935B0CF7A1,$84B8BA24025A7B17,$C3C023E6320A0B5C,$68F489C4D1E81309,$184572793C7A24D2,$86AB6433EA12C819,
             $8F431E759EB8EB80,$59EC5E1520100B75,$CC7C66337B81C039,$60F4B1D8E7F46DC1,$98457C7E307A38DC,$563C6AB04454814A,
             $A10F3ACA694354CD,$8785EF2070CF9AC7,$86AEAE008ACF647F,$1A8D65D6887F3047,$81C0FC500603F145,$783322E090683094,
             $D60FD48643322530,$EF40E856B28BFAF1,$5EC55B08F4D1E8FE,$F0B9D9D1700969EC,$F0FBF84859649E09,$A08C463F9F58D4E1,
             $69EC2F9E3646E8FB,$5B839E54E4EF1009,$D057177461B0DEEF,$CC0B8A87437B9F58,$1C1700969EC92DC1,$6D077E39E31FCB1D,
             $AD83B9F58D55A033,$25A7B00E827C0BE0,$7EDC2CC2C74779C0,$0168D21215BC2406,$8FBE5D019286876E,$6369B4022B3D91DB,
             $FA7D1BC9E1B6E030,$7EBF66E97DBECDD0,$AB6E9FDFE8240E02,$AC8A96E6B04EA840,$77491C8C35D07A17,$96B8804B4F607CF1,
             $BF11FFEFF5A40F2D,$EAF7AE98383D745A,$060DD37BBD31BF45,$E568323AAC1C04A1,$8023AC01A9675E31,$8FD0D0F4C21C1DE6,
             $4879BCDB100969EC,$101AFD93919B9B82,$20A0CCA40C0CC820,$5AC04B1102A50881,$07A10D4BD795F310,$804B4F62F621BCF0,
             $C6F6F6B156767633,$8FBDE3D22640E89B,$5029ECF4CDFDFC32,$64E6DA82A200D583,$B00E8A5BC995AAAD,$4440C231F9567B17,
             $A9161E06E9A7A7A2,$7BAD28A75E12BB5D,$8419D2087A3D3377,$E01AA9D456B917AB,$F6265E5E89B29E26,$FEADADB3F86BF1AA,
             $783038E925A6D374,$F185285D2EE4A027,$8419AFAF8C6BA1F1,$02D75798833F5263,$C4F7B006703267AE,$934C490BEB55EC1E,
             $78E9650E0EB16126,$04BCBD5703A0A714,$2416F6F1993A9D49,$416F39155CEE74AB,$600CF033EAE0A5D6,$AF462C95F3A8F66D,
             $9C54FBF5BADB3C8F,$0F19827BC1102B85,$CB5D45EA68DE010F,$A3ACF57434B0455C,$BE75B7FD7AE3FBE3,$A2EC5154D363E192,
             $25945A2DD384BA75,$9972FC08465CE0E1,$5ED7840D4BA57571,$2D9699E10E127986,$9454BF12E9D27ECB,$F002353EC668F0D6,
             $7BF5C5F06D03B020,$E03F6D6D27839B1B,$8C108B859C65D0D0,$EBEDF698128ED76F,$BE3596B9DF639844,$A09D28AD6239B1B3,
             $007ABAC7D2FAC2ED,$BA0EE027039A5404,$FEB6B51CB76AD16C,$0743BE3CAECEC63B,$1726041C09425DC2,$3CEFE02A71F89C9C,
             $A7F5A026985BFB86,$6DDFADADA3CBEDEC,$49EB3F9682BF6AD0,$64076CFBA3E9275D,$EC84A2ADADD02F52,$C74D6AD6887F6AD2,
             $714F870769D33A74,$6779CC2DB021CC6C,$6B0E7896DB6B8A67,$6AD6BE99595B443E,$8EB1046850D0847F,$EDA9A0DBC03B53D4,
             $7015A5031C01580C,$7A515E9FB9321E06,$DC4D1A51959456CF,$12534688FB268D41,$39631DFC30FF28AD,$8B594570F9CD1A91,
             $BD64EB9826A28656,$F9D51B1D5D63D487,$96C85A0269064CD7,$C8AF23E06F1148B9,$C8FB8E4FC556B64F,$ABEC544D0EB21E75,
             $0F8AB731DFF8371B,$B5838C52B6233C8C,$BDC95B5B656DE296,$E9F5B4017FC3266D,$60EB4F4720350BFF,$454900000000E15A
      Data.b $4E,$44,$AE,$42,$60,$82
      Information:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$59487009000000F4,$0D0000D70D000073,
             $0000789B284201D7,$DA78544144490208,$C619E755507997A5,$698E3B49A68D1223,$30414624A690E9B5,$905054B441716457,
             $422C8B2AFB2AC9B0,$655910205C045944,$4A8A02E0555937DF,$63AC46A082088A34,$47FA926754B89A4C,$CF7DF4FA33A6404B,
             $CCF4C94628DCF73D,$CF3EFBDF7C7EE6FC,$E006BC39C2E77DF3,$30933B57E7A0E9B5,$61B82AB79C3C0C36,$DD407E81FEA828D8,
             $9F56DC339E63C324,$1B57DD5D3B5C35C7,$378DAFF7D1CCD6FB,$4B18E84FB31BAFF0,$BA1DFBD2DA791A6B,$47D11FCDC2E3EF87,
             $0EF85C8E27F91C9C,$31D3D96E9E574DE9,$FBDC3DC637501066,$A12476ADF3D0057F,$DC0FB71E67594147,$83BF9FD443C8F745,
             $F485B8EAC8DBEE82,$F93C2E34D9029BD6,$87D5D4E0EF7A1A0D,$5EE1EA608BBA5F90,$3355DE6401D5F8D6,$4CB54599A4D5F856,
             $23EE976D16FD9ED4,$DC91D78D890B7E53,$B4C7D8A3CDBD8A34,$F3CF089F627EC0DC,$EA7A8FBC1F6A073A,$ACE95A41323A8F35,
             $FA19CAAF3200AD39,$DBC6BB925CC7357E,$DD5C46BEBA87D768,$5FF5F10AFE1DC435,$F4930E0175C34F61,$E4C754096BC73C1C,
             $6F65C1EE414DB89F,$E8032BF6B26B38D7,$1F8E752639A556F9,$55F5676EEC27BFEB,$D86BDAAEC55CD4C4,$14CC32882962414D,
             $A4F72D453AD8B5C4,$489D04E95A3BFD1C,$6799601A5FD3B493,$73FA8986B0FAE3B9,$A20AF2A3B47610FF,$EC8294F82BAAE888,
             $EF7E7BA2298551AC,$2639E634C502E35F,$D4513DCE0E1AA186,$86987BF7A9A6B7CB,$F32C030BC7B04E37,$DB9478AAF3239B28,
             $0C96845196948A36,$1187CA2232F4AC21,$8FEEE6184CF23159,$8668B3663C5E50E3,$11F28899EB94D8D6,$E40DE8F5230D9784,
             $0094D7B07B00DC75,$4E7724BBC5967B1F,$08FDF96D85BF1D14,$8B4220D17040182A,$881C42C30C5DB107,$0E63C00AA0FCEF45,
             $19765E13548608C9,$213A42123787A9DB,$C95C35FDDC509785,$3256E3A0099EBD83,$75EB7658E9479973,$FE0FB72FC20E9644,
             $0CC29FAF30222E87,$A1CC54208090C228,$F87FEF89BF259086,$8D78CD921CC78049,$DEA36CF5107C386B,$954445DE4050DA40,
             $9EC5EC147DB7210F,$C34D8D8B5BA58052,$C1CE333C28C029EA,$93E17AB3BC3CF32B,$162050C0130A417D,$99857C853C2C50E3,
             $9CDF7EE3E85FB0C2,$6037E573358B413E,$5D00529EC630D61A,$D93D4FCFFF3C92B7,$F6E16769AD88395D,$E30A4E783F7097F9,
             $041739BE40CA8D45,$D79E7859F7263F41,$E7199EFDC8694EB9,$7D5F1BA4EE7A41E1,$9FCF613F4F078119,$EC8087D255DE1807,
             $17EA7381E94A7073,$D6CC295C0CECF970,$57F3CC22C1103174,$C6A28144C135F36A,$2B94DE7EA374345D,$EC5E9CB6EE90B9E9,
             $AAC325EE6588BB2E,$0072BE20F45AE05B,$B624F7BF607B535B,$78E1A7FD87053BEC,$4A388A19481547A0,$D805287F5FCFF77F,
             $E1A8A022614570DF,$70D042F94E73EE5A,$3DF5A774D05A703C,$E76D00529EC09755,$9E26D841EAC4C982,$DB4FA1B0139EF580,
             $2902949F25D86EA4,$65DD52469D822943,$E79610B0DD524029,$9EF7EC7B861AC51D,$7B4D05BB92EC3412,$014A7B021DAE4CFA,
             $AC58E96327F39CB4,$F4CD89DB19613AE2,$538E124F85DF1569,$214926CA11512220,$3D5095E5605024C2,$3D88DBAD564830A4,
             $3412E84AB1D621BC,$F9EC1FA2BE33E9AD,$50CE73420F0500B3,$8C6363B4C7980E80,$03BBB161C9769B1C,$0AF1CDA8521DB116,
             $5B100A407CB62611,$96F5C75C30192031,$246D6913635886E2,$097EE5844E84EB4D,$4AF61FCA700554F6,$C31D46987271B4A1,
             $0DB4F981B15BA2DF,$0C5DB3BE60DB3B66,$55A5F43130882ED6,$8635C49BC0E63C5E,$D61D2335EA3319EB,$0DDA9DE00A1B5D62,
             $679438762C0294F6,$6B0BA921C4FCD519,$88EB047112605BC3,$31CC1DD7F14791F5,$2BD855131C329821,$6A8D319E72B1E005,
             $74D6187597B9EA95,$EC27E6E8CB0E3E4A,$E7AC639F64580529,$42AB1BA07EE63C51,$E3086B09B43AB11A,$B0DAC66B0E30CDED,
             $88C0422381304516,$A189D78F23AFD53C,$D608FA15AC44CD79,$D8374A67A690C359,$D267B2EC01553D8B,$9BC2EB1C824398C4,
             $B01A82623076EF41,$04E10982146E0992,$63C00A56739A109A,$F508D424D2102D0E,$EB5AC1A15832B7D4,$C88F81D894E05A23,
             $97687D18799F3D8B,$DB1B613A55E06F1D,$275FE15814A97A0A,$495020C058701FA0,$994100A47A32823D,$1CD5579A4368423D,
             $76B8DB1D24EAFB16,$A794D7B04D94FA18,$CDB43E73993607E1,$F5A12611B231B47A,$D4CBE3396354F990,$A3A1AFCB1489E808,
             $114E798F00295BEF,$DB759D63ECA7555C,$5EC1EC09AA29B11B,$71C33AC0F9217C2F,$F2342A0B71EC96C9,$80A544155EC7C1AF,
             $AF174BF0AA66F18C,$B06A028D7A94A8A9,$B38CE4B64B19BA39,$D233AD34C95F4BC7,$01A23CC9FA1D3A96,$AE832F75D0153EFA,
             $815FF299423D1947,$AA74E612A7DF4FA2,$D2F19E9569A9A43A,$F7359B575EBA3257,$24E8B4BB532DF7ED,$F402B7C0C2D707D6,
             $3E39E809408E84E8,$D487D77A90D6A83D,$038B7DFC6721DB42,$6F1E43BF67D4D427,$4DBC493C0094CFB1,$1B1A7BFA9A867EFC,
             $E46C7C1CD9164AE2,$8BDC2B747ED58A53,$B576B82D3852EDA1,$34358194FA56257F,$ADA447E69255774C,$DE01F3FA8FA2FAC1,
             $6842FE242C477E20,$F7F8D3A18DF4302D,$1862CF7D49CCBB62,$971D045EE6429778,$02E7BFE7CE752C02,$272C42D71D67E94B,
             $F625DAA031AA4363,$F0AC3F9FFBD49399,$2EEA27ACE5AD2048,$498809E2FF667D14,$F8DF39BFAFBA1117,$32916CFF4B426B8F,
             $F6439684D9F569A1,$A10ADCC83C975D53,$51AF1CF31E186147,$4AB82AB85DAE63CD,$3AC061A40DBCEE7D,$78CC36F804F29EA2,
             $3E621BF1266077D1,$FBA32E4C534227F1,$26BBC855969E72B7,$B7BF6F12CC34DA3B,$63C32FFA3223DF71,$79F291B5DDE6FB9A,
             $509967D4D5C22C4B,$1EA29AFD89F7218F,$266BFE97A366CEEB,$434C8F13CC4B9906,$89923B8B684C5914,$758B6BCE2644AB47,
             $1BCFB7E202DF629A,$C2FE2A3E63BFFB4F,$F60E31453791DF88,$E2F9D63C40BE288E,$7B508B3F0C4B7DBD,$3E8EB99C00FFFE95,
             $00000000B4F408D5,$826042AE444E4549
      Question:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$59487009000000F4,$0D0000D70D000073,
             $0000789B284201D7,$DA78544144494608,$8619E755500997A5,$698E3A49A6AD1A23,$31514624A690E9B5,$5481BA86882E2C88,
             $5045956459510116,$56440846809B2A31,$BD1365477D916459,$46608A820A0BEE2A,$49335A3B460D134D,$EFFBEFDBC2A25709,
             $9E667276AB4507B9,$FBEFBDF7FFFEE7B9,$E001BEE73DCCE7FF,$613070BDCF41D78D,$B4A7DD329C55E86C,$5167BE8EE4BBC8C5,
             $24AAB8663CE7C30F,$6D5F7575F6B86B85,$D430A3DF5C3056EC,$2BAEAC26CBA8A3C0,$5077D4F2AFB5BCA6,$0CE3EFAFE9C6DCB4,
             $1DFD3EEC07F5B071,$D75CD92DF62FCB62,$FBDC3DC5D459E065,$D091DBE5B9E8029B,$7DCE6B0FA384EF03,$85BC9C945DEB450F,
             $6C435DD4240DC534,$F83F4F3A4482D7D5,$774BA1C2DD4F4A0D,$F70F50F87BFE7B51,$DE6577401DFFC6B2,$2B02F33105EEA9A0,
             $B7F3EA89FEC78595,$105765E10D7B5F11,$CAD8ED152D8EDE59,$8F04AB620BE07654,$128DBA69AA073CF3,$B15A495BB81F9DEA,
             $07725D74015AF9AC,$EFAC8875EC17BBE9,$908EBFA8EF55A6AE,$4968436E2908CBA2,$889870115E97361B,$931D5185CF18F001,
             $96C384E90506E07A,$D00657ED64D66EFA,$BDD7D88BB18BCB73,$25FE436EAC53B1B7,$1197854D84B82C6C,$73CC3A8829824144,
             $89EE5AAA45C17348,$A4F683B4551573DA,$79D9300D2FB1DA49,$89C96552FF1CDD97,$20445EE5D68AC56F,$1B20A73E22EF3EB1,
             $4FE6EDAAAD1A4828,$41EE7FF71BAF79B8,$1F87D27E3C13CF77,$981C80E7F5C5281E,$29A5F2F5204F7383,$F64A6501A613753F,
             $75C3D94EC9806178,$AA23B757241E725D,$BACFF0CD997E1DB2,$55A736B05ABB3580,$B8EABC6FF6BC6904,$B33C39EAD136414D,
             $BD105BB2022B5766,$F60F601D752903A7,$0EA1D9CEA7C02E7A,$AAC35FF73B94FB91,$CECF839DA77846D4,$398535613465F826,
             $3CAD1EE4D92FF6D2,$7CD5BC33B175FF75,$8F71D938FA98F09F,$E217802D35602F4C,$B8A191E7E9BE3A4B,$9804CF5EC1E4658E,
             $AEACA764F07322B4,$F704D59B582BAAC4,$295E1671D8F033E4,$11F4F3089CE6148D,$F08A7EAF08597C56,$3FF313EDEDE8CB92,
             $2AE9937BC22AFD76,$459CA67905A2F5EA,$BD83B4D72466AEE0,$B1867971300E53D8,$DC73876805097FA9,$5384CAC49FC4B809,
             $BF1F51872D3C4D70,$7C207858A115EE3E,$361921E9FA1D881F,$B4233A4B77EE3E8A,$A5FEA603B6B93358,$999159D00729EC5D,
             $26DCA0DEA1D5F1E2,$871D5F1586398F2C,$3C6A17187213F6E3,$7F609E8F3D1776DE,$49FB92677410A773,$F0E006D53E8ABDAA,
             $9DC73BF721B23BC5,$FE686E9239E91384,$4F9ECBDC3F6D7805,$899E067994D96807,$47D1A580D51F6027,$CB30A32C51E5F0E0,
             $C149388B0440A563,$A19B731B06405458,$8865D09FCC2C79EC,$A82B3DC01628BE2C,$77481CF48CB5179F,$64C59F650429D255,
             $E76CB04BFE96CCC7,$00DD1E5873DCD09D,$D821EB64B1072D9B,$03FA1ADB7618717E,$E3288547608943A9,$79CC22FFEF3A6142,
             $EE08CCAAAFEBD203,$3B6DD86844751A5B,$79DE7377A91D342C,$9EB4D2C2601CA7B0,$E2C01F855826FCF0,$0A11569F496007CD,
             $A943A903941E4758,$7CA742E28069A982,$C3549D875C36147F,$3AC3424396CD8F70,$B0B233E86D342152,$DA9A5ED00729EC19,
             $E60FB21162DB4C13,$EB422D3E88B0FBC1,$57088814FDB08FF1,$29C2A889508CB285,$4ED6E1C7D5A14610,$BC3D4A5BCFF64558,
             $8B9A17AB08B1D620,$54F9EC11A73433E9,$402947497E3BB480,$B58D82C1AC6FE61D,$3075416616A9B858,$89550A2D4393AE0B,
             $87C7EAADF33AA9A8,$EB9C7901E475812E,$242C6B105A5CDEB8,$FC1F6C38B9A405AD,$A7D803FB3D838F93,$985A90DA5144B8B6,
             $2E6157D7DFC5EE06,$FCC6A86DE63579F3,$70C2211AB052350D,$D67601147EB7ABC0,$D70C734A17DF115E,$16B0E91E77A8F333,
             $B00AD19580525AEB,$F3148EED9C601CA7,$0ACC7A88DB5E8AC0,$CC4D98DD9AC984A8,$8AF663AD9F07BB59,$026FD11E6A70EA60,
             $0D37199EC709DE1F,$D6187597B9EB92AC,$BD15F5F30FDC8FB4,$AC64936B180729EC,$E9814DB8E5D194E7,$84998E57E19865BE,
             $966057FB180AEAF1,$501CB760982AA57F,$9E19DF11AA0A2C7D,$333AC11F456A9133,$D8BD80528E74D219,$E81A60E275803FB3,
             $D00A80ECC5AB0DB2,$634C52EF188C1DBB,$2E504E113044CA7C,$53A76A939E10BE42,$59CD6B06951F34DF,$5E427C3AF0FB0953,
             $C4EB63E8C3CCF9EC,$157055A52C970350,$A048A3D53052A5E8,$025352F0302C59EF,$A6BFAC6800D56643,$6A42AC75922BEA58,
             $9EE7AF64AD9AE860,$2AD8FF0FC6591F86,$2BF13065B582C1E1,$4C6E30A63E6BAE81,$808857088D4F4081,$73D687573E02A3E4,
             $D5ECCEB1F753AFEF,$AF60F60E58185865,$6ECE38B47C90BE17,$F2342A336EC492FC,$40AE44392EA7C028,$1A13FC09E4C95997,
             $E4FDE3D5CF807BE4,$BEB458059E46BDCA,$4BC7B3752497E302,$B44CC5C716B4C95F,$77D0A535FCCBF1DF,$B29C7436638E81CD,
             $3B8BF192ECCA11E9,$A854E7A7F3E00724,$75769F31735DF4FA,$F4BDC6C4596A6912,$788E8635378E8C95,$89DA6D7AE8F343E7,
             $3D01CB7030853E39,$0B8E7A099049313A,$E0215DBBE1331C74,$EF521AD50CB8F573,$FEEA4DB04C42DF1C,$DEC3218D01DB6CD0,
             $3C00B9E7D9B78F23,$90C69071FC43BC48,$DCB58E6486E7340F,$E9DC330B35C8D0FE,$6BFA438260663852,$35CD31723C33B5C1,
             $349729BA69A1AC1B,$867C97D64D6D213F,$18C40FE23BF00C0C,$8DB74368F6846FE2,$D1EF8EB38F3F1BB4,$3AE82CCAC180CE77,
             $9A5C4C348724C4EE,$D27DF48982E7BFCA,$31AA4363214C74B2,$FBD43DF136F1DAA0,$29AD230A754D3F9F,$FD867C918EE927AC,
             $DE74258E92901DCF,$65FA679FF1946B7C,$A5F165A94A2CD5FD,$0521C74FB136DB52,$3E186147A1D22BBA,$3B5C879AA39E31E7,
             $E7231190DE4FBA66,$1DEA7A48EB018692,$60C0F745E830CBE0,$96842FE228C4F7E2,$DA91B4DFAE975C94,$9CD6ABAC9BEFBE16,
             $901F5B0583E37E17,$F79BEC69CF8623D1,$402CDE391DADAD67,$3EE431EA1350C863,$6C61DD63D24B5FA9,$C411905266BFD2F4,
             $C471912534CB6948,$D1AAD6D2BA456904,$DF525A754827C695,$EFFDAFC681DDE268,$791EE9186F8AB798,$A3E249EF60E3124B,
             $A5B7DB5D251D6DA5,$17FFE9578D0943F0,$7EAC38F3D09DF64F,$444E454900000000
      Data.b $AE,$42,$60,$82
      Warning:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$59487009000000F4,$0D0000D70D000073,
             $0000789B284201D7,$DA78544144495506,$C718574C700B96BD,$DA359E314888224F,$EA3186BD43A31578,$764119E20FA63555,
             $89092911208F12F3,$48BC884D9EB45044,$AB4A3C4225084122,$23C689B24D915112,$77BD9508317D319E,$B7773BF7F9BDDDEF,
             $B3FE676B20E94C61,$EFBEFFF9EDF39EF7,$A8EBD80061EEE77E,$CD9581DBDE98CB44,$75DD7B193D4ACC68,$009C20090C9CCF5E,
             $0791556009100244,$8C038C6E99003B7B,$C814BAC821EB08AD,$C01027198CA86945,$7A95EA0036F73E78,$2F8F90B1790A57DA,
             $5C1485E2142C7C81,$A014D9CF83F9720A,$E8CA9F30D22C329C,$6607482485D3452F,$7BBB86DC2A60FC90,$9BDA77E61A258D83,
             $3DC38FA941A014D9,$7B290C5F1F2C6523,$90210AA87343A41E,$0243EBA43970338A,$2F1A9ECF0009B470,$2242E9A37778F7E8,
             $BF542E8F904123A4,$41E1C7CE987F2CA5,$857BAA198D44B856,$4EE9B2E70015785E,$799AB1AD5A5D258F,$4840E1D20AB502CE,
             $013547A4B2B81925,$7A76DA028053AD34,$E53256B267FE5B2D,$737E5A967074846D,$FDFB96F145CC2271,$A5A1E1E1D773903E,
             $B2A71775834FA972,$4189A3365168053A,$C85F7EDE34B4482A,$E92AB8F2A6A3E647,$5E7DC616A642F530,$408FBC22A3B70B90,
             $3EC96F4004EA6D00,$808C9F2C97AA5EFA,$7CCA1ABDA40A6331,$30139DC010EE6A2B,$9089AEE371D562EB,$F32E6C5ACC3E6B68,
             $A004EAC69C2E4C75,$89B794A296FF45DD,$ACE40273B8C1260C,$598FCC8475B9A899,$183F41F2073B70AA,$22A1376749555CD3,
             $A008DE9D0048AFA2,$5AA97BF480203284,$EE3067CA63346F33,$859EBA40C7194D18,$646F90BDA41974DF,$548FB7E65B364553,
             $A7D4A560FED5531F,$974011BD86B17651,$8872D4E9446D79F2,$BF9E8236DC602349,$377EBEE3F6373506,$AA327DD931DDDDDC,
             $69F690F7D8D0662E,$D2043098830E2620,$F401227E855465C9,$C3B27BD9F5002D7A,$621DC329143D53F7,$D617CC30785A40DC,
             $703DB5CA0322A6A3,$7AE91349B7089B73,$8B8960DC2E6F7AAF,$FA651E1C7D290FED,$497E2DCC774D94D7,$76C0A5CFA00CBC2F,
             $90FB9B8802C8F1A2,$053972824DF352FA,$CFC27757283495CA,$BB1528375ABE1DDB,$99ED2153C69D3EE8,$A87AEFC417A63108,
             $8600816F445AF55B,$7DCFCEA6270012BE,$9B8BB2A446B93298,$55F9F309EE8C43BA,$204EDA5CA113CA50,$69ACC160D00D08C9,
             $6093CAC69972B5EA,$D0D8421FF14D582E,$069B4A3C20FC6205,$45E17A8BD95D97BD,$998C18BB072F4300,$675D610F6DBE109E,
             $72818B294347BB48,$58F148E35F940B71,$27192D60A88BEE17,$C98C037E9CF8C658,$1D89618470886143,$09AA1D45D5C28F5D,
             $C1F801FFEC5115C0,$CD563495565FCA82,$30F6DAC216DD585A,$E94A1EB252852FE7,$6CFD6BB30AB45246,$940D68A502990FAC,
             $614B49220A5095C2,$60020770860F3D3E,$405F8947856EBE10,$0E5FEC009B7769EF,$9742EAFA30048440,$83379610E7EA636A,
             $583248D43505B2B0,$45185DF2D2B74501,$7D2E830FCA52F446,$1F39438414AA6AA6,$DB4850A42597E506,$B8C7FC625C00ABFA,
             $957983C4A1B3B8BE,$A97D803CF547F73F,$E66A91B8AA8DDD97,$5039A3299CA3196A,$442E72842D22BFF2,$2B845B6287E53035,
             $8556C5FBA78C57D2,$39E7F9842DCFE65A,$09BCB0AA5A1B2210,$7BBD77A9428C271E,$96A3D4013FFD2FFC,$6E2D5F6A2C547986,
             $92800F252F4B501D,$8202ECE50F9A4817,$DE683412F2415608,$A9AABE9D92AAB9A2,$90F9D9DC79E7C80A,$DC6F4C42AD3D0652,
             $7F9F042F5022EB0A,$0D87E4C9FB58FCE6,$89530EC71EBFFB6F,$07E8FD308E65F255,$019EF3B9285CCCE5,$A0FF747F1CDDC209,
             $E627551F7B767A1D,$C78E3CF32C834D5A,$22059394420B34FF,$4FBD027DC49E11B2,$B1F33D84D004C7FD,$A19B80B2A6EBD923,
             $63BF66D5E379AA1D,$CC367395267F9520,$499006E4829FFC67,$2B0099F26CD48C00,$8F1C53CF9C65A058,$27AED487D293BFE7,
             $4EA2AEC8CA8AE86C,$8FB337AB4F70D6CB,$FD55EABDE99ACE1A,$03FB54E9164A85BD,$3A61683F4C3C7B39,$550F926F29D309E9,
             $F3CCAA661D3497C4,$E93F8F1C78AAE3E2,$EB2CC21864CE5305,$5441D893C7D69619,$159DACD18EC28685,$4337E16773CFD582,
             $92B6E6BFE13913DE,$F3947784EE03B6B0,$151A01CDEE58B2A7,$5841BAABFBFCB078,$C1E39B2B00F6DAD5,$37B89761A851DD37,
             $05AE32CAE03E7007,$D2DC437BA2193536,$D173ADAEA7EEF2CF,$D4D81EB83E9886BA,$1C3BF793658E3D9C,$04E8F8362B57A9C0,
             $4ED6B1737E674156,$ED6B151367ACF129,$D1ED5D9E3391EE15,$21A01CC6EF270D92,$D3EC0E8E47D25DE9,$1A46D5C90C6C4E96,
             $2DA917ABC9231E43,$935A4958380391C9,$17286C9D491D485C,$0E8BDD5BD5B397AB,$672C6C4D83E086D6,$C400FFF601DF17AB,
             $0057A0D0DD88D6E4,$AE444E4549000000
      Data.b $42,$60,$82
    EndDataSection
    
  CompilerEndIf 
  
  CompilerIf #Enable_HelpWindow
    
    ; License: 	http://creativecommons.org/licenses/GPL/2.0/
    ; Source:   http://art.gnome.org/

    DataSection
      Home:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$5948700900000061,$2E0000232E000073,
             $0000763FA5780123,$DA78544144497E01,$EF28CFF81DA06063,$E205C0DBE52456D5,$DA5130C20BB779C9,$FEBBFCD4FABB7C55,
             $E0A219009F77FAAB,$883BEBAFD55FFED5,$34D72BBBD959A826,$8FFF6EBB39B7EA6E,$B4FBBFC543F75DA8,$FFEFFB85FFE76FB2,
             $4EBF876F82806827,$EFFDAE9BC9B7FF68,$8177DDECFFFD7F5C,$00D048D201FFAC86,$AFAEFF557336AF05,$FD775CEFFC2FAB5D,
             $5F162BFFF3FCD17F,$01BF01B0DD121B04,$1F9D7E2A2AEDEECA,$C6F9BFD7F89E16EA,$D17CB8E0E779C2FF,$60BFF9DE76B3FF85,
             $6C0DA1DA01B03DDF,$FD9584DB03A59A28,$BDD3FEEFF5649EBA,$67FF2799ECFFEAFE,$9FFF4E73F9C540CD,$DFA582CF7FE6EDB6,
             $31010DC2F7BAFD94,$F9AE55064EBBFC54,$4729D4FFCAFEB3D9,$CC1715823A4F27FF,$76FFE5ED7BBFF93E,$D827760302BEF319,
             $81672025F6EF4510,$BD31FFD9D961B942,$0E9F651A9062F1FB,$0522D63ABC1457B0,$87FE27F9B2FFFB60,$06B06A418BC2EFB6,
             $7EFFA1EA6B304824,$069C1A9062F0DB8D,$11BD5EEFFEECF7C4,$D3504069C1A9062F,$9062F06BA50EFF96,$0A25AC56B8069C1A,
             $0007D30C148034E3,$947CE5A519883284,$444E454900000000
      Data.b $AE,$42,$60,$82
      Next:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$5948700900000061,$2E0000232E000073,
             $0000763FA5780123,$DA78544144496301,$AC2E033FFFFFF863,$19841E4F859ED5E0,$2663BBD145F01808,$71A6EF80D7226690,
             $B36402D90D03BED3,$1DFF4394FE406593,$F3E403390C83E633,$FF8819F128003563,$4079FFCEBF5563A3,$B791EFFC1D27B203,
             $6971407B90D017E4,$7FE0789ACF7C066C,$42053B9C7043E4CE,$E5BD5BEFFEEFB6C7,$CB253EFFBEDF5A7F,$D7AA06BC777828FF,
             $EF7FFF7FAD2030C2,$9063B12B3DFFCDAA,$ABE501FF9ED7625C,$8B6C5C8074FA29FF,$858EFFCEC7424062,$286AF083E7DBFE6B,
             $0B8800B8401DF086,$2DDFF5DF6F8FFF57,$0C58815F8BC8096F,$6966FFE6C344406E,$FD89C12EA49BFF4B,$5FFD5F2BF7FC372B,
             $05C503D9A413B7C9,$466FD787FF1B35C1,$AD15BBFF9B7561C1,$B3DFFF58ADF66B01,$C5B0EDF3A87FC570,$37F9DBE2AC741FC2,
             $FF75F2EF7FFD6AA0,$27E00603FC97725D,$62076058B609B8A0,$FFDAE957BBF82C0E,$03BF3502FE0B1976,$41B309894F4875F2,
             $C4A4E42AD9025F9A,$B92CB4804FCD406F,$8DC928AA2810E179,$840AA80033B2843C,$0000004888D8CF25,$6042AE444E454900
      Data.b $82
      Previous:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$5948700900000061,$2E0000232E000073,
             $0000763FA5780123,$DA78544144497F01,$AC3E033FFFFFF863,$E4B8BCC4031ED5E0,$07FE6A00A8EE6809,$A8C0D400192402C4,
             $57F26A30DD31DDE8,$54001924DF8E9F25,$FA7E3CD9BCD40ECC,$77F9ABFE87A9FCB7,$A07E42A000DA20FD,$4F67BFB3A9B6D3E6,
             $BAFFE1EA6F3FF03C,$6071FFE2807FFD61,$9D77CD40D2CD6401,$3FFFDBEB4AFE17B3,$FF9DD688FFEB76A0,$1D053B9FFA1F27B3,
             $C14B59A60CBB861F,$C93FD2C167B5E3BB,$EFF96F54FBFE7BDD,$E07098CE2719B959,$9F9000C4275FAABF,$097F9CEA6DA9F881,
             $EFFDAD173BFEBBED,$7861F3ED8C06B050,$93A4076FF9AF1435,$7140EDF657FF76BA,$960A3D1F05D03181,$6D34DFF8DEAA0BFD,
             $69BA38DC54937FC9,$030F40FCEC607FEB,$EBFE2F653ADE3790,$FFD2DA59BFE1B55F,$FA6DD687FEAB05CE,$80B61B8219BF5E1F,
             $86A0034C16E36471,$FF3E9B61790D0128,$D74081FFFAC56FB7,$C1FF8A02FCF40468,$A00D8B001863FF82,$AFF2FF66922C8F21,
             $93641DBBD15FF0DC,$51297C63A0731038,$FC67638CB7A51814,$69005E7240201A84,$333254E611721A02,$00DB25EF10373B53,
             $0792E0B2FF2021A8,$45626DAC66459C00,$4E4549000000008D
      Data.b $44,$AE,$42,$60,$82
      Close:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$5948700900000061,$010000B101000073,
             $00000E28986101B1,$DA7854414449CE01,$9825033FFFFFF863,$3A306065AC06AA81,$278B0B3D6AFB1099,$27D28AA5D89042BA,
             $D89401580D583520,$FFFB677DE5F5A26F,$78303157BF3E6153,$FDFE71F09E79C920,$AFFB7751FFEBB7A1,$8188B01B810C902B,
             $72CFFFC48CFDC2E1,$D87FFD2B2B3FFF73,$3EAF06061CF7E1CB,$9E7F56CE4DFF0606,$FE76F65EE5821716,$63D8A80030C5A907,
             $FF21E1CBEFFCB6B3,$F89C9EBFFD85872F,$A31B6A9FC99DA17F,$12D762C0E29257BF,$EC1907B2F3EFFF62,$ABD62500660C3581,
             $A4FFFF62ED3AFF4B,$0FFF5E7ED3FFDD9D,$FFF6E6E33FFC7AF9,$BF6A86CDFFC26A72,$81130B1AC6692066,$696A3AFF88AB560A,
             $56C3FFF1B190FFF4,$265FFF1A5BF7FF56,$06AC669A226BF027,$75FA13952D150174,$3EF4A05EFFEB9050,$0C845D6241B10620,
             $EBFC2F22582A0768,$63A9400BFFCF1082,$225B120D9438FA40,$801A17971DABFA2F,$617DD7EA5144B551,$0585B7C2818FFFFE,
             $94548BFF4A2B47FE,$5F762C10445B77F9,$ED5FB96512FFE844,$89CBD40618DE7C7C,$502BFFF5AFAA7DDD,$DFFCB29661503DE8,
             $A086062C8086063C,$C18545EFBF85652C,$D6D34FFE740D4F72,$65E5734605CD8EBE,$ACA0DFFDD2353D3E,$A432072619A407F8,
             $483FEF48D4F62811,$49A4330484B6034D,$7A2043032E5EFA45,$ACF9E5EC390C8160,$0008DCB01E525701,$310739031F6E8130,
             $444E454900000000
      Data.b $AE,$42,$60,$82
      Search:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$5948700900000061,$010000B101000073,
             $00000E28986101B1,$DA7854414449AC01,$9825033FFFFFF863,$72CA9B2A7006AE81,$91F3990831155ACA,$7198A29DBC87006C,
             $D4F9FF15F6CC9BD4,$6D12F35888306F7D,$B55798D32966C800,$FFDEEA7D5FFEB6B3,$F7BD5479FFA5E6A4,$6B239D6F29C018A0,
             $8A2279D14F95FF19,$17A8D359694B1966,$0274D94FFE2B3D05,$8F3397FC57BBF38C,$5B32D64B803702BC,$FF95C4C95FECB7DF,
             $4D3929F3FF9A125D,$9AC84A982B738900,$7EBFF59BAA4F3D86,$3CDE9C4075FFA6F6,$193667F841A8BFFF,$B7A1869201B83D73,
             $FB996F4FFDA6AB62,$7C90EB7FF671B53F,$9F7C8CA4D3F621A0,$079D6CCFFFB61687,$24CA5FF19DAA4B96,$204A31B99CAB2BEC,
             $FE6478E9F7DBCB72,$E53E5D1FFF6ECC0F,$513EA6FFACED427F,$CE35A7FEAAB37DFF,$F5727FE730D29FFF,$A559DFC1A632FFE4,
             $ED9C972346B02DCD,$9D59FEFFD8B75D02,$9B2A8FFF260A43FF,$82B0FFF66CBA3FFE,$194BFF2BE25DFF29,$9BC1B1B294E4FDBA,
             $04B96857AC15B80E,$66BE3FF69FCA0FFF,$7203FF3586A4FFC5,$90E6FC381B8BFF3B,$59C8F1212A2476B6,$65325FFF09F6306D,
             $0C25FF658E8CFFEF,$9D11B9594BB0FEED,$9B7CDE5B91808112,$3FFB13697FDC5059,$90652724DE56F2EC,$3CFCD85956B25C21,
             $1EA000061B0999B0,$0000648185AB4C85,$42AE444E45490000
      Data.b $60,$82
    EndDataSection

  CompilerEndIf
  ;}
  
  
EndModule

;- ========  Module - Example ========

; Abbreviations: PDF / HTML

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Example = 12
  
  ; === Gadget ===
  ;  1: Headings
  ;  2: Emphasis
  ;  3: Lists
  ;  4: URL and Links
  ;  5: Image
  ;  6: Table
  ;  7: Footnote
  ;  8: TaskLists
  ;  9: Definition List
  ; 10: Subscript / Superscript
  ; 11: Fenced Code Block
  ; 12: Emoji
  ; 13: Abbreviations
  ; 14: Keystrokes
  ; 15: Intended Code Block
  ; 16: Glossary
  ; 17: Notes
  ; === Draw on Canvas ===
  ; 19  MarkDown::Text()
  ; === Requester ===
  ; 20: Message Requester
  ; 21: User image
  ; 22: User buttons
  ; === Help ===
  ; 30: Help Window
  ; 31: Help to PDF
  ; 32: Help to HTML
  
  Define.s Text$
 
  Select #Example
    Case 1       ;{ Headings
      Text$ = "Heading level 1"+ #LF$ 
      Text$ + "==============="+ #LF$
      Text$ + "Heading level 2"+ #LF$
      Text$ + "---------------"+ #LF$
      Text$ + "### Heading level 3 ###"  + #LF$
      Text$ + "#### Heading level 4 ####"  + #LF$
      Text$ + "##### Heading level 5 #####"  + #LF$
      Text$ + "###### Heading level 6 #####"  + #LF$ + #LF$
      ;}
    Case 2       ;{ Emphasis
      Text$ = "## Emphasis ##" + #LF$
      Text$ + "I just love **bold text**." + #LF$
      Text$ + "Italicized text is the *cat's meow*."+ #LF$
      Text$ + "This text is ___really important___.  "+ #LF$
      Text$ + "The world is *~~flat~~* round.  "+ #LF$
      Text$ + "This ++text++ has been underlined.  "+ #LF$
      Text$ + "This == word == is highlighted.  "+ #LF$
      Text$ + "-----------------------------------------" + #LF$
      Text$ + "## Code ##" + #LF$
      Text$ + "At the command prompt, type ``nano``."+ #LF$
      ;}
    Case 3       ;{ Lists
      Text$ = "## Ordered List ##" + #LF$
      Text$ + "1. List item"+#LF$+"   2. List item"+#LF$+"   3. List item"+#LF$+"4. List item"+ #LF$+ #LF$
      Text$ + "-----" + #LF$+ #LF$
      Text$ + "## Unordered List ##" + #LF$
      Text$ + "- First list item" + #LF$ + "  - Second list item:" + #LF$ + "  - Third list item" + #LF$ + " - Fourth list item" + #LF$ 
      ;}
    Case 4       ;{ URL and Links
      Text$ = "## Links & URLs ##" + #LF$  + #LF$ 
      Text$ + "URL: <https://www.markdownguide.org>" + #LF$ + #LF$
      Text$ + "EMail: <fake@example.com>  " + #LF$ + #LF$
      Text$ + "Link: [Duck Duck Go](https://duckduckgo.com "+#DQUOTE$+"My search engine!"+#DQUOTE$+") "+ #LF$
      ;}
    Case 5       ;{ Image
      Text$ = "## Image ##"  + #LF$
      Text$ + "![Programmer](Test.png " + #DQUOTE$ + "Programmer Image" + #DQUOTE$ + ")" + #LF$
      ;}
    Case 6       ;{ Table
      Text$ = "## Table ##"  + #LF$
      Text$ + "| Syntax    | Description   | Column 3 |" + #LF$
      Text$ + "| :-------- | :-----------: | -------: |" + #LF$
      Text$ + "| *Header*  | Title         | Subject  |" + #LF$ 
      Text$ + "||| Very long cell                     |" + #LF$
      Text$ + "| Cell      | Long cell               ||" + #LF$
      Text$ + "| Paragraph | **Text**      | *Table*  |" + #LF$ 
      ;}
    Case 7       ;{ Footnote
      Text$ = "## Footnotes ##" + #LF$ + #LF$
      Text$ + "Here's a simple footnote,[^1] and here's a longer one.[^bignote]" + #LF$
      Text$ + "[^1]: This is the **first** footnote." + #LF$
      Text$ + "[^bignote]: Here's one with multiple paragraphs and code."
      ;}
    Case 8       ;{ TaskLists
      Text$ = "## Task List ##" + #LF$
      Text$ + "- [ ] Write the press release"+ #LF$
      Text$ + "- [X] Update the website"+ #LF$
      Text$ + "- [ ] Contact the media"+ #LF$
      ;}
    Case 9       ;{ Definition List
      Text$ = "## Definition List ##" + #LF$ + #LF$
      Text$ + "First Term" + #LF$
      Text$ + ": This is the definition of the first term." + #LF$
      Text$ + "Second Term"+ #LF$
      Text$ + ": This is one definition of the *second term*." + #LF$
      Text$ + ": This is another definition of the **second term**." + #LF$
      ;}
    Case 10      ;{ Subscript / Superscript
      Text$ = "## SubScript / SuperScript ##" + #LF$  + #LF$
      Text$ + "Chemical formula for water: H~2~O  " + #LF$
      Text$ + "The area is 10m^2^  " + #LF$
      ;}
    Case 11      ;{ Fenced Code Block
      Text$ = "## Fenced Code Block ##" + #LF$
      Text$ + "```" + #LF$
      Text$ + "{" + #LF$
      Text$ + "  " + #DQUOTE$ + "firstName" + #DQUOTE$ + ": " + #DQUOTE$ + "John"  + #DQUOTE$ + "," + #LF$
      Text$ + "  " + #DQUOTE$ + "lastName"  + #DQUOTE$ + ": " + #DQUOTE$ + "Smith" + #DQUOTE$ + "," + #LF$
      Text$ + "  " + #DQUOTE$ + "age"       + #DQUOTE$ + ": 25" + #LF$
      Text$ + "}" + #LF$
      Text$ + "```" + #LF$
      ;}
    Case 12      ;{ Emoji
      Text$ = "## Emoji ##" + #LF$  + #LF$
      Text$ + ":phone:  telephone receiver  " + #LF$ + #LF$
      Text$ + ":mail:  envelope  " + #LF$ + #LF$
      Text$ + ":date:  calendar  " + #LF$ + #LF$
      Text$ + ":memo:  memo  " + #LF$ + #LF$
      Text$ + ":pencil:  pencil  " + #LF$ + #LF$
      Text$ + ":bookmark:  bookmark  " + #LF$ + #LF$
      Text$ + ":bulb:  bulb  " + #LF$ + #LF$
      Text$ + ":mag:  magnifier  " + #LF$ + #LF$
      Text$ + ":paperclip:  paperclip  " + #LF$ + #LF$
      Text$ + ":warning:  warning  " + #LF$ + #LF$
      Text$ + ":laugh:  grinning face with big eyes  " + #LF$ + #LF$
      Text$ + ":smile:  slightly smiling face  " + #LF$ + #LF$
      Text$ + ":smirk:  smirking face  " + #LF$ + #LF$
      Text$ + ":cool:  smiling face with sunglasses  " + #LF$ + #LF$
      Text$ + ":sad:  slightly frowning face  " + #LF$ + #LF$
      Text$ + ":angry:  angry face  "   + #LF$ + #LF$
      Text$ + ":worry:  worried face  " + #LF$ + #LF$
      Text$ + ":wink:  winking face  "  + #LF$ + #LF$
      Text$ + ":rolf:  rolling on the floor laughing  " + #LF$ + #LF$
      Text$ + ":eyes:  face with rolling eyes  " + #LF$
      ;}
    Case 13      ;{ Abbreviations
      Text$ = "## Hint / Tooltip ##" + #LF$  + #LF$
      Text$ + "The HTML specification is maintained by the W3C." + #LF$
      Text$ + "*[HTML]: Hypertext Markup Language" + #LF$
      Text$ + "*[W3C]:  World Wide Web Consortium" + #LF$
      ;}
    Case 14      ;{ Keystrokes
      Text$ = "## Keystrokes ##" + #LF$ + #LF$ 
      Text$ + "Copy text with [[Ctrl]] [[C]]." + #LF$
      ;}
    Case 15      ;{ Code Block
      Text$ = "## Code Block ##" + #LF$
      Text$ + Space(4) + "{" + #LF$
      Text$ + Space(4) + "  " + #DQUOTE$ + "firstName" + #DQUOTE$ + ": " + #DQUOTE$ + "John"  + #DQUOTE$ + "," + #LF$
      Text$ + Space(4) + "  " + #DQUOTE$ + "lastName"  + #DQUOTE$ + ": " + #DQUOTE$ + "Smith" + #DQUOTE$ + "," + #LF$
      Text$ + Space(4) + "  " + #DQUOTE$ + "age"       + #DQUOTE$ + ": 25" + #LF$
      Text$ + Space(4) + "}" + #LF$
      ;}
    Case 16      ;{ Glossary 
      Text$ = "## Glossary ##" + #LF$ + #LF$
      Text$ + "[?Glossary] is a glossary term." + #LF$ + #LF$
      Text$ + "[?Glossary]: The glossary collects information about important terms used in your document." + #LF$ + #LF$
      Text$ + "-----------------------------------------" + #LF$ + #LF$
      Text$ + "{{Glossary}}" + #LF$
      ;}
    Case 17      ;{ Notes
      Text$ = "## Notes ##" + #LF$ + #LF$
      Text$ + "!!! info **Note**" + #LF$
      Text$ + "Lorem ipsum" + #LF$
      Text$ + "!!!" + #LF$ + #LF$
      Text$ + "!!! question **Note**" + #LF$
      Text$ + "Lorem ipsum" + #LF$
      Text$ + "!!!" + #LF$ + #LF$
      Text$ + "!!! error **Note**" + #LF$
      Text$ + "Lorem ipsum" + #LF$
      Text$ + "!!!" + #LF$ + #LF$
      Text$ + "!!! caution **Note**" + #LF$
      Text$ + "Lorem ipsum" + #LF$
      Text$ + "!!!" + #LF$ + #LF$
      ;}
    Case 20      ;{ Reqester
      Text$ = "Just a **short** information text.  " + #LF$
      Text$ + "*Second requester line*" + #LF$
      Text$ + "![](Test.jpg)" + #LF$
      ;}
    Case 21, 22  ;{ Reqester - UserImage 
      Text$ = "Just a **short** information text.  " + #LF$
      Text$ + "*Second requester line*" + #LF$
      ;}
    Default      ;{ Example text
      Text$ = "## MarkDown ##" + #LF$ + #LF$
      Text$ + "> The gadget can display text formatted with the [MarkDown Syntax](https://www.markdownguide.org/basic-syntax/).  "+ #LF$
      Text$ + "> Markdown[^1] is a lightweight [>MarkUp] language that you can use to add formatting elements to plaintext text documents."+ #LF$ + #LF$
      Text$ + "- Markdown files can be read even if it isn’t rendered."  + #LF$
      Text$ + "- Markdown is portable." + #LF$ + "- Markdown is platform independent." + #LF$
      Text$ + "[^1]: Created by John Gruber in 2004."
      ;Text$ = "## Überschrift 1" + #LF$ + "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. " + #LF$ + #LF$ + "## Tabelle" + #LF$ + "| S1 | S2 |" + #LF$ + "| :--- | :--- |" + #LF$ + "| A  |  B  |" + #LF$ + #LF$ + "## Überschrift 2" + #LF$ + "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat."
      ;}
  EndSelect
  
  CompilerIf #Example = 19 ; Draw on a CanvasGadget
    
    CompilerIf MarkDown::#Enable_DrawCanvas
    
    Enumeration 
      #Window
      #Canvas
    EndEnumeration
    
    If OpenWindow(#Window, 0, 0, 300, 280, "MarkDown - Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)

      If CanvasGadget(#Canvas, 10, 10, 280, 260)
        
        MarkDown::LoadFonts("Arial", 12)
      
        If StartDrawing(CanvasOutput(#Canvas)) 
    
          DrawingMode(#PB_2DDrawing_Default)
  
          MarkDown::Text(20,  90, "This is a **MarkDown** example, "  + #LF$)
          MarkDown::Text(20, 110, "drawn on a *CanvasGadget*. :wink:" + #LF$)
          
          StopDrawing()
        EndIf
        
      EndIf  
      
      Repeat
        Event = WaitWindowEvent()
      Until Event = #PB_Event_CloseWindow
  
      CloseWindow(#Window)
    EndIf 
    
    CompilerEndIf

  CompilerElseIf #Example < 20     ; Markdown - Gadget
    
    ; Examples - Gadget
    CompilerIf MarkDown::#Enable_Gadget
      
      Enumeration 
        #Font 
        #Window
        #MarkDown
        #Editor
        #Button1
        #Button2
        #Button3
        #Button4
      EndEnumeration
    
      LoadFont(#Font, "Arial", 10)
      
      If OpenWindow(#Window, 0, 0, 300, 315, "Example", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
        
        EditorGadget(#Editor, 10, 10, 280, 275)
        SetGadgetFont(#Editor, FontID(#Font))
        HideGadget(#Editor, #True)
        SetGadgetText(#Editor, Text$)
        
        ButtonGadget(#Button2, 10, 290, 60, 20, "View")
        ButtonGadget(#Button1, 75, 290, 60, 20, "Edit")
        
        ButtonGadget(#Button3, 205, 290, 40, 20, "PDF")
        ButtonGadget(#Button4, 250, 290, 40, 20, "HTML")
  
        DisableGadget(#Button2, #True)
        
        If MarkDown::Gadget(#MarkDown, 10, 10, 280, 275, MarkDown::#AutoResize)
          MarkDown::SetText(#MarkDown, Text$)
          MarkDown::SetFont(#MarkDown, "Arial", 10)
        EndIf
        
        CompilerIf MarkDown::#Enable_Tooltips
          
          MarkDown::TooltipColor(MarkDown::#Color_Back,   $F0FFFF)
          MarkDown::TooltipColor(MarkDown::#Color_Border, $8CE6F0)
          
          MarkDown::Tooltip(#Button1, "Edit **Markdown**-Text", #Window)
          MarkDown::Tooltip(#Button2, ":mag: View *Markdown*",        #Window) 
          MarkDown::Tooltip(#Button3, "Export as **PDF**",      #Window)
          MarkDown::Tooltip(#Button4, "Export as *HTML*",       #Window)
          
          SetActiveWindow(#Window)
          
        CompilerEndIf  
  
        Repeat
          Event = WaitWindowEvent()
          Select Event
            Case MarkDown::#Event_Gadget ;{ Module Events
              Select EventGadget()  
                Case #MarkDown
                  Select EventType()
                    Case MarkDown::#EventType_Link ;{ Left mouse click
                      RunProgram(MarkDown::EventValue(#MarkDown))
                      ;}
                  EndSelect
              EndSelect ;}
            Case #PB_Event_Gadget  
              Select EventGadget()  
                Case #Button1            ;{ Edit
                  
                  If EventType() = #PB_EventType_LeftClick
                    HideGadget(#Editor,   #False)
                    HideGadget(#MarkDown, #True)
                    DisableGadget(#Button1, #True)
                    DisableGadget(#Button2, #False)
                  EndIf   
                  ;}
                Case #Button2            ;{ View
                  
                  If EventType() = #PB_EventType_LeftClick
                    MarkDown::SetText(#MarkDown, GetGadgetText(#Editor))
                    HideGadget(#Editor,     #True)
                    HideGadget(#MarkDown,   #False)
                    DisableGadget(#Button1, #False)
                    DisableGadget(#Button2, #True)
                  EndIf   
                  ;}
                Case #Button3            ;{ PDF
                  If EventType() = #PB_EventType_LeftClick
                    CompilerIf Defined(PDF, #PB_Module)
                      MarkDown::SetText(#MarkDown, GetGadgetText(#Editor))
                      MarkDown::Export(#MarkDown, MarkDown::#PDF, "Export.pdf", "PDF")
                      RunProgram("Export.pdf")
                    CompilerEndIf
                  EndIf
                  ;}
                Case #Button4            ;{ HTML
                  If EventType() = #PB_EventType_LeftClick
                    MarkDown::Export(#MarkDown, MarkDown::#HTML, "Export.htm", "HTML")
                    RunProgram("Export.htm")
                  EndIf   
                  ;}
              EndSelect
          EndSelect        
        Until Event = #PB_Event_CloseWindow
    
        CloseWindow(#Window)
      EndIf
      
    CompilerEndIf  
   
  CompilerElseIf #Example < 30 ; Markdown - Requester
    
    #Image = 1
    
    CompilerIf MarkDown::#Enable_Requester
      
      CompilerSelect #Example
        CompilerCase 21
          
          If LoadImage(#Image, "Symbol.png")
            MarkDown::AddRequesterImage("Bug", #Image)
          EndIf
          
          MarkDown::Requester("Markdown - Requester", Text$, #False, #PB_Default, "Bug")
        CompilerCase 22
          
          Button1 = MarkDown::AddRequesterButton("Bt1", "Button 1")
          Button2 = MarkDown::AddRequesterButton("Bt2", "Button 2")
          
          Result =  MarkDown::Requester("Markdown - Requester", Text$, MarkDown::#Warning, #PB_Default, "", "Bt1|Bt2")
          
          Select Result
            Case Button1
              Debug ">>> Button 1"
            Case Button2
              Debug ">>> Button 2"
          EndSelect    
          
        CompilerDefault  
 
          MarkDown::RequesterButtons("Klar", "Ja", "Nein", "Abbrechen")
          ;MarkDown::RequesterPadding(20)
    
          MarkDown::Requester("Markdown - Requester", Text$, MarkDown::#Info|MarkDown::#YesNo)
        
      CompilerEndSelect

    CompilerEndIf
  
  CompilerElse                 ; Help Window
    
    Select #Example
      Case 30 
        CompilerIf MarkDown::#Enable_HelpWindow
          MarkDown::Help(" Help", "Help.mdh", "Module", MarkDown::#AutoResize)
        CompilerEndIf   
      Case 31
        CompilerIf MarkDown::#Enable_HelpWindow
          MarkDown::Help2PDF("Markdown Module", "Help.mdh", "", "P", PDF::#Format_A5) 
          RunProgram("Help.pdf")
        CompilerEndIf  
      Case 32
        CompilerIf MarkDown::#Enable_HelpWindow
          HTML$ = MarkDown::Help2HTML("Markdown Module", "Help.mdh", "HTML", "Index.html") 
          RunProgram(HTML$)
        CompilerEndIf  
    EndSelect
    
  CompilerEndIf
  
CompilerEndIf

; IDE Options = PureBasic 6.00 Beta 7 (Windows - x64)
; CursorPosition = 137
; FirstLine = 24
; Folding = QAAAAIAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAEAAgh-5oAyAAAAAAJAAAgAAeAAAAAAAAAAAAAABEAAAA-
; Markers = 5143
; EnableXP
; DPIAware