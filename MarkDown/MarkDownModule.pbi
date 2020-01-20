;/ ==================================
;/ =    MarkDownLanguageModule.pbi    =
;/ ==================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/  Gadget to display MarkDown languages
;/
;/ © 2020 by Thorsten Hoeppner (12/2019)
;/

; Last Update: 20.01.2020
;
; - Internal structure of the parser completely changed
; - Added: Keystrokes "[[Ctrl]] [[C]]"
; - Added: Abbreviations "*[HTML]: Hypertext Markup Language"
; - Added: Inline Emphasis (Lists/Tables/Footnotes/...)
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

; MarkDown::Clear()              - similar to 'ClearGadgetItems()'
; MarkDown::Convert()            - convert markdown to HTML or PDF (without gadget)
; MarkDown::EventValue()         - returns links
; MarkDown::Export()             - export to HTML or PDF 
; MarkDown::Gadget()             - new MarkDown gadget
; MarkDown::GetData()            - similar to 'GetGadgetData()'
; MarkDown::GetID()              - similar to 'GetGadgetData()', but string
; MarkDown::Hide()               - similar to 'HideGadget()'
; MarkDown::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; MarkDown::SetAttribute()       - similar to 'SetGadgetAttribute()'
; MarkDown::SetColor()           - similar to 'SetGadgetColor()'
; MarkDown::SetData()            - similar to 'SetGadgetData()'
; MarkDown::SetFont()            - similar to 'SetGadgetFont()'
; MarkDown::SetID()              - similar to 'SetGadgetData()', but string
; MarkDown::SetMargins()         - defines the margins
; MarkDown::SetText()            - similar to 'SetGadgetText()'

;}

;{ _____ Emoji _____

; :bookMark: / :date: / :mail: / :memo: / :pencil: / :phone: 
; :angry: / :cool: / :eyes: / :laugh: / / :rofl: / :sad: / :smile: / :smirk: / :wink: / :worry:

;}

; XIncludeFile "ModuleEx.pbi"

CompilerIf Not Defined(PDF, #PB_Module) : XIncludeFile "pbPDFModule.pbi" : CompilerEndIf

DeclareModule MarkDown
  
  #Version  = 20200200
  #ModuleEx = 19112100
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  ;{ _____ Constants _____
  #Bullet$ = "•"
  
	EnumerationBinary ;{ GadgetFlags
		#AutoResize        ; Automatic resizing of the gadget
		#Borderless        ; Draw no border
		#ToolTips          ; Show tooltips
		#UseExistingCanvas ; e.g. for dialogs
	EndEnumeration ;}
	
	Enumeration 1     ;{ Format
	  #MarkDown
	  #HTML
	  #PDF
	EndEnumeration ;}
	
	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}
	
	Enumeration 1     ;{ Attribute
	  #Corner
	  #Margin_Left
	  #Margin_Right
	  #Margin_Top
	  #Margin_Bottom
	  #Indent
	  #LineSpacing
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
		#Color_Line
		#Color_Link
		#Color_HighlightLink
		#Color_LineColor
	EndEnumeration ;}

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
	;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================

  Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
  Declare   Clear(GNum.i)
  Declare   Convert(MarkDown.s, Type.i, File.s="", Title.s="")
  Declare.s EventValue(GNum.i)
  Declare   Export(GNum.i, Type.i, File.s="", Title.s="")
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.q GetData(GNum.i)
  Declare.s GetID(GNum.i)
  Declare.s GetText(GNum.i, Type.i=#MarkDown, Title.s="")
  Declare   Hide(GNum.i, State.i=#True) 
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, Name.s, Size.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
  Declare   SetText(GNum.i, Text.s)
  
EndDeclareModule

Module MarkDown

	EnableExplicit
	
	UsePNGImageDecoder()
	UseJPEGImageDecoder()

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
  ;{ OS specific contants
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #ScrollBarSize  = 18
    CompilerCase #PB_OS_MacOS
      #ScrollBarSize  = 18
    CompilerCase #PB_OS_Linux
      #ScrollBarSize  = 18
  CompilerEndSelect ;}
  
  #CodeBlock = 2

  #Parse  = 0
  
  EnumerationBinary ;{ MarkDown
    #Abbreviation
    #BlockQuote
    #Bold
    #Code
    #Definition
    #Emoji
    #FootNote
    #Header
    #Heading
    #Highlight
    #Hint
    #Line
    #Image
    #Italic
    #Keystroke
    #LineBreak
    #Link
    #List
    #Ordered
    #Paragraph
    #StrikeThrough
    #Subscript
    #Superscript
    #Table
    #Task
    #Text
    #Unordered
    #AutoLink
  EndEnumeration ;}
  
  Enumeration 1     ;{ Font
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
  
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================	
  
  Structure List_Structure               ;{ Lists\...
    Marker.s ; ul: - or + or * / ol: . or ) 
    Indent.i
    Start.i
    Level.i
  EndStructure ;}
  
  Structure Document_Structure           ;{ Document()\...
    Type.i
    BlockQuote.i
    Marker.s
    Level.i
    String.s
  EndStructure ;}
  Global NewList Document.Document_Structure()
  
  
  Structure Words_Structure              ;{ Word Structure
    Font.i
    String.s
    Index.i
    Width.i
    Flag.i
  EndStructure ;}
  
  Structure Block_Structure              ;{ MarkDown()\Block()\...
    Font.i
    String.s
    List Row.s()
  EndStructure ;}

  Structure FootLabel_Structure          ;{ MarkDown()\FootLabel('label')\...
    Width.i
    Height.i
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Label_Structure              ;{ MarkDown()\Label('label')\...
    Destination.s
    Title.s
    String.s
  EndStructure ;}

  Structure Footnote_Structure           ;{ MarkDown()\Footnote()\...
    X.i
    Y.i
    Width.i
    Height.i
    Label.s
  EndStructure ;}
  
  Structure Abbreviation_Structure       ;{ MarkDown()\Abbreviation()\...
    X.i
    Y.i
    Width.i
    Height.i
    String.s
  EndStructure ;}
  
  Structure Image_Structure              ;{ MarkDown()\Image()\...
    Num.i
    X.i
    Y.i
    Width.i
    Height.i
    Label.s
    Source.s
    Title.s
  EndStructure ;}
  
  Structure Link_Structure               ;{ MarkDown()\Link()\...
    X.i
    Y.i
    Width.i
    Height.i
    URL.s
    Title.s
    Label.s
    State.i
  EndStructure ;}

  Structure Lists_Row_Structure          ;{ MarkDown()\Lists()\Row()\...
    BlockQuote.i
    Width.i
    Height.i
    Level.i
    State.i
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Lists_Structure              ;{ MarkDown()\Lists()\..
    Start.i
    List Row.Lists_Row_Structure()
  EndStructure ;}
  
  
  Structure Table_Item_Structure         ;{ MarkDown()\Table()\Row()\Col('num')\Item()\...
    Type.i
    String.s
    Index.i
  EndStructure ;}
  
  Structure Table_Cols_Structure         ;{ MarkDown()\Table()\Row()\Col('num')\...
    Width.i
    List Words.Words_Structure()
  EndStructure ;}
  
  Structure Table_Row_Structure          ;{ MarkDown()\Table()\Row()\...
    Type.i
    Height.i
    Map Col.Table_Cols_Structure()
  EndStructure ;}
  
  Structure Table_Column_Structure       ;{ MarkDown()\Table()\Column\...
    Align.s
    Width.i
  EndStructure ;}
  
  Structure Table_Structure              ;{ MarkDown()\Table()\...
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
  
  
  Structure MarkDown_Required_Structure  ;{ MarkDown()\Required\...
    Width.i
    Height.i
  EndStructure ;}
  
  Structure MarkDown_Font_Structure      ;{ MarkDown()\Font\...
    ; FontNums
    Normal.i
    Bold.i
    Italic.i
    BoldItalic.i
    Code.i
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
	
	Structure MarkDown_Margin_Structure    ;{ MarkDown()\Margin\...
		Top.i
		Left.i
		Right.i
		Bottom.i
	EndStructure ;}
	
	Structure MarkDown_Color_Structure     ;{ MarkDown()\Color\...
		
	  Back.i
	  BlockQuote.i
		Border.i
		Code.i
		DisableBack.i
		DisableFront.i
		Front.i
		Gadget.i
		Highlight.i
		Hint.i
		Keystroke.i
		KeyStrokeBack.i
		Link.i
		LinkHighlight.i
		Line.i
	EndStructure  ;}
	
	Structure MarkDown_Scroll_Structure    ;{ MarkDown()\Scroll\...
	  Num.i
	  MinPos.i
    MaxPos.i
    Offset.i
    Height.i
    Hide.i
  EndStructure ;}
	
	Structure MarkDown_Window_Structure    ;{ MarkDown()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure MarkDown_Size_Structure      ;{ MarkDown()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}
	
	
	Structure MarkDown_Structure           ;{ MarkDown()\...
		CanvasNum.i
		PopupNum.i
		
		ID.s
		Quad.i
		
		Text.s
		
		BlockQuote.i
		LeftBorder.i
		WrapPos.i
		WrapHeight.i
		
		Indent.i
		LineSpacing.f
		
    Radius.i

		Hide.i
		Disable.i
		ToolTip.i
		EventValue.s
		
		Flags.i

		Color.MarkDown_Color_Structure
		Font.MarkDown_Font_Structure
		Margin.MarkDown_Margin_Structure
		Required.MarkDown_Required_Structure
		Size.MarkDown_Size_Structure
		Scroll.MarkDown_Scroll_Structure
		Window.MarkDown_Window_Structure
		
		Map  FootLabel.FootLabel_Structure()
		Map  Abbreviation.Abbreviation_Structure()
		Map  Label.Label_Structure()
		List Block.Block_Structure()
		List Footnote.Footnote_Structure()
    List Image.Image_Structure()
    List Link.Link_Structure()
    List Lists.Lists_Structure()
    List Table.Table_Structure()
    
    List Items.MarkDown_Items_Structure()
    
	EndStructure ;}
	Global NewMap MarkDown.MarkDown_Structure()
	
	Global NewMap Emoji.i()
	
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
	  If Num > 0  
	    ProcedureReturn DesktopScaledX(Num)
	  EndIf   
	EndProcedure

	Procedure.f dpiY(Num.i)
	  If Num > 0  
	    ProcedureReturn DesktopScaledY(Num)
	  EndIf  
	EndProcedure
	
	Procedure.i mm_(Pixel.i)
	  ;px = mm * 96 / 25,4mm
	  ProcedureReturn Round(Pixel * 25.4 / 96, #PB_Round_Nearest)
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
	  
	  MarkDown()\Font\FootNote       = LoadFont(#PB_Any, Name, Round(Size / 1.5, #PB_Round_Up), #PB_Font_Bold)
	  MarkDown()\Font\FootText       = LoadFont(#PB_Any, Name, Size - 2)
	  MarkDown()\Font\FootBold       = LoadFont(#PB_Any, Name, Size - 2, #PB_Font_Bold)
	  MarkDown()\Font\FootItalic     = LoadFont(#PB_Any, Name, Size - 2, #PB_Font_Italic)
	  MarkDown()\Font\FootBoldItalic = LoadFont(#PB_Any, Name, Size - 2, #PB_Font_Bold|#PB_Font_Italic)
	  
	  MarkDown()\Font\H6 = LoadFont(#PB_Any, Name, Size + 1, #PB_Font_Bold)
	  MarkDown()\Font\H5 = LoadFont(#PB_Any, Name, Size + 2, #PB_Font_Bold)
	  MarkDown()\Font\H4 = LoadFont(#PB_Any, Name, Size + 3, #PB_Font_Bold)
	  MarkDown()\Font\H3 = LoadFont(#PB_Any, Name, Size + 4, #PB_Font_Bold)
	  MarkDown()\Font\H2 = LoadFont(#PB_Any, Name, Size + 5, #PB_Font_Bold)
	  MarkDown()\Font\H1 = LoadFont(#PB_Any, Name, Size + 6, #PB_Font_Bold)
	  
	EndProcedure
	
	Procedure   LoadEmojis_()
	  
	  Emoji(":angry:")    = CatchImage(#PB_Any, ?Angry, 540)
	  Emoji(":bookmark:") = CatchImage(#PB_Any, ?BookMark, 334)
	  Emoji(":cool:")     = CatchImage(#PB_Any, ?Cool, 629)
	  Emoji(":date:")     = CatchImage(#PB_Any, ?Calendar, 485)
	  Emoji(":eyes:")     = CatchImage(#PB_Any, ?Eyes, 583)
	  Emoji(":laugh:")    = CatchImage(#PB_Any, ?Laugh, 568)
    Emoji(":mail:")     = CatchImage(#PB_Any, ?Mail, 437)  
    Emoji(":memo:")     = CatchImage(#PB_Any, ?Memo, 408) 
    Emoji(":pencil:")   = CatchImage(#PB_Any, ?Pencil, 480)
    Emoji(":phone:")    = CatchImage(#PB_Any, ?Phone, 383)
    Emoji(":rolf:")     = CatchImage(#PB_Any, ?Rofl, 636)
    Emoji(":sad:")      = CatchImage(#PB_Any, ?Sad, 521)
    Emoji(":smile:")    = CatchImage(#PB_Any, ?Smile, 512)
    Emoji(":smirk:")    = CatchImage(#PB_Any, ?Smirk, 532)
    Emoji(":wink:")     = CatchImage(#PB_Any, ?Wink, 553)
    Emoji(":worry:")    = CatchImage(#PB_Any, ?Worry, 554)

	EndProcedure
	
	
	Procedure.i AdjustScrollBars_()
	  Define.i Height
	  
	  If IsGadget(MarkDown()\Scroll\Num)
	    
	    Height = GadgetHeight(MarkDown()\CanvasNum) 
	    
	    If MarkDown()\Required\Height > Height
	      
	      If MarkDown()\Scroll\Hide
	        
	        ResizeGadget(MarkDown()\Scroll\Num, GadgetWidth(MarkDown()\CanvasNum) - #ScrollBarSize - 1, 1, #ScrollBarSize, GadgetHeight(MarkDown()\CanvasNum) - 2)
	        
	        SetGadgetAttribute(MarkDown()\Scroll\Num, #PB_ScrollBar_Minimum,    0)
          SetGadgetAttribute(MarkDown()\Scroll\Num, #PB_ScrollBar_Maximum,    MarkDown()\Required\Height)
          SetGadgetAttribute(MarkDown()\Scroll\Num, #PB_ScrollBar_PageLength, Height)
          
          MarkDown()\Scroll\MinPos = 0
          MarkDown()\Scroll\MaxPos = MarkDown()\Required\Height - Height + 1
          
          HideGadget(MarkDown()\Scroll\Num, #False)
          
          MarkDown()\Scroll\Hide = #False
          
          ProcedureReturn #True
        Else 
          
          ResizeGadget(MarkDown()\Scroll\Num, GadgetWidth(MarkDown()\CanvasNum) - #ScrollBarSize - 1, 1, #ScrollBarSize, GadgetHeight(MarkDown()\CanvasNum) - 2)
          
          SetGadgetAttribute(MarkDown()\Scroll\Num, #PB_ScrollBar_Maximum,    MarkDown()\Required\Height)
          SetGadgetAttribute(MarkDown()\Scroll\Num, #PB_ScrollBar_PageLength, Height)
          
          MarkDown()\Scroll\MaxPos = MarkDown()\Required\Height - Height + 1
          
          ProcedureReturn #True
	      EndIf   
	      
	    Else
	      
	      If MarkDown()\Scroll\Hide = #False
	        HideGadget(MarkDown()\Scroll\Num, #True)
	        MarkDown()\Scroll\Hide = #True
	      EndIf  
	      
	      ProcedureReturn #True
	    EndIf
	    
	  EndIf
	  
	  ProcedureReturn #False
	EndProcedure  

	Procedure   Clear_()
	  
	  ClearMap(MarkDown()\FootLabel())
	  ClearMap(MarkDown()\Label())
	  
	  ClearList(MarkDown()\Block())
	  ClearList(MarkDown()\Footnote())
	  ClearList(MarkDown()\Image())
	  ClearList(MarkDown()\Items())
	  ClearList(MarkDown()\Link())
	  ClearList(MarkDown()\Lists())
	  ClearList(MarkDown()\Table())

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
 
  Procedure.i DetermineTextSize_()
    Define.i Font, TextHeight
    Define.i Key$
    
    Font = #PB_Default

    If StartDrawing(CanvasOutput(MarkDown()\CanvasNum))
      
      ;{ _____ Items _____
      ForEach MarkDown()\Items()
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\Items()\Width  = 0
        MarkDown()\Items()\Height = TextHeight("X")

        ForEach MarkDown()\Items()\Words()
        
          If Font <> MarkDown()\Items()\Words()\Font : Font = DrawingFont_(MarkDown()\Items()\Words()\Font) : EndIf
          
          Select MarkDown()\Items()\Words()\Flag
            Case #Emoji     ;{ Emoji (16x16)
              TextHeight = dpiY(16)
              MarkDown()\Items()\Words()\Width = dpiX(16)
              ;}
            Case #Image     ;{ Image
              
              If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Words()\Index)
                
  			        If MarkDown()\Image()\Num = #False ;{ Load Image
  			          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
  			          If MarkDown()\Image()\Num
  			            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
  			            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
  			          EndIf ;}
  			        EndIf
  			        
  			        If IsImage(MarkDown()\Image()\Num)
  			          TextHeight = dpiY(MarkDown()\Image()\Height)
  			          MarkDown()\Items()\Words()\Width = dpiX(MarkDown()\Image()\Width)
  			        EndIf
  			        
  			      EndIf
  			      ;}
  			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
  			      TextHeight = TextHeight(MarkDown()\Items()\Words()\String)
  			      MarkDown()\Items()\Words()\Width = TextWidth(MarkDown()\Items()\Words()\String) + dpiX(10)
  			      ;}
  			    Default  
              TextHeight = TextHeight(MarkDown()\Items()\Words()\String)
              MarkDown()\Items()\Words()\Width = TextWidth(MarkDown()\Items()\Words()\String)
          EndSelect
          
          MarkDown()\Items()\Width + MarkDown()\Items()\Words()\Width
          If TextHeight > MarkDown()\Items()\Height : MarkDown()\Items()\Height = TextHeight : EndIf
          
        Next
        
        MarkDown()\Items()\Height * MarkDown()\LineSpacing

      Next ;}
      
      ;{ _____ Lists _____
      ForEach MarkDown()\Lists()

        ForEach MarkDown()\Lists()\Row() ;{ List rows
          
          DrawingFont(FontID(MarkDown()\Font\Normal))
          
          MarkDown()\Lists()\Row()\Width  = 0
          MarkDown()\Lists()\Row()\Height = TextHeight("X")
          
          ForEach MarkDown()\Lists()\Row()\Words()
        
            If Font <> MarkDown()\Lists()\Row()\Words()\Font : Font = DrawingFont_(MarkDown()\Lists()\Row()\Words()\Font) : EndIf
            
            Select MarkDown()\Lists()\Row()\Words()\Flag
              Case #Emoji     ;{ Emoji (16x16)
                TextHeight = dpiY(16)
                MarkDown()\Lists()\Row()\Words()\Width = dpiX(16)
                ;}
              Case #Image     ;{ Image
                
                If SelectElement(MarkDown()\Image(), MarkDown()\Lists()\Row()\Words()\Index)
                  
    			        If MarkDown()\Image()\Num = #False ;{ Load Image
    			          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
    			          If MarkDown()\Image()\Num
    			            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
    			            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
    			          EndIf ;}
    			        EndIf
    			        
    			        If IsImage(MarkDown()\Image()\Num)
    			          TextHeight = dpiY(MarkDown()\Image()\Height)
    			          MarkDown()\Lists()\Row()\Words()\Width = dpiX(MarkDown()\Image()\Width)
    			        EndIf
    			        
    			      EndIf
    			      ;}
    			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
    			      TextHeight = TextHeight(MarkDown()\Items()\Words()\String)
    			      MarkDown()\Items()\Words()\Width = TextWidth(MarkDown()\Items()\Words()\String) + dpiX(10)
    			      ;}
    			    Default  
                TextHeight = TextHeight(MarkDown()\Lists()\Row()\Words()\String)
                MarkDown()\Lists()\Row()\Words()\Width = TextWidth(MarkDown()\Lists()\Row()\Words()\String)
            EndSelect
           
            MarkDown()\Lists()\Row()\Width + MarkDown()\Lists()\Row()\Words()\Width
            If TextHeight > MarkDown()\Lists()\Row()\Height : MarkDown()\Lists()\Row()\Height = TextHeight : EndIf
            
          Next
         
          MarkDown()\Lists()\Row()\Height * MarkDown()\LineSpacing
          ;}
        Next

      Next ;} 
      
      ;{ _____ Tables _____
      ForEach MarkDown()\Table()
        
        ForEach MarkDown()\Table()\Column() : MarkDown()\Table()\Column()\Width = 0 : Next  
        
        ForEach MarkDown()\Table()\Row()
          
          DrawingFont(FontID(MarkDown()\Font\Normal))
        
          MarkDown()\Table()\Row()\Height = TextHeight("X")
          
          ForEach MarkDown()\Table()\Row()\Col() ;{ Columns
            
            Key$ = MapKey(MarkDown()\Table()\Row()\Col())
            
            MarkDown()\Table()\Row()\Col()\Width = 0 
            
            ForEach MarkDown()\Table()\Row()\Col()\Words()
              
              If Font <> MarkDown()\Table()\Row()\Col()\Words()\Font : Font = MarkDown()\Table()\Row()\Col()\Words()\Font : EndIf
              
              Select MarkDown()\Table()\Row()\Col()\Words()\Flag
                Case #Emoji     ;{ Emoji (16x16)
                  TextHeight = dpiY(16)
                  MarkDown()\Table()\Row()\Col()\Words()\Width = dpiX(16)
                  ;}
                Case #Image     ;{ Image
                  
                  If SelectElement(MarkDown()\Image(), MarkDown()\Table()\Row()\Col()\Words()\Index)
                    
      			        If MarkDown()\Image()\Num = #False ;{ Load Image
      			          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
      			          If MarkDown()\Image()\Num
      			            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
      			            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
      			          EndIf ;}
      			        EndIf
      			        
      			        If IsImage(MarkDown()\Image()\Num)
      			          TextHeight = dpiY(MarkDown()\Image()\Height)
      			          MarkDown()\Table()\Row()\Col()\Words()\Width = dpiX(MarkDown()\Image()\Width)
      			        EndIf
      			        
      			      EndIf
      			      ;}
      			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
      			      TextHeight = TextHeight(MarkDown()\Items()\Words()\String)
      			      MarkDown()\Items()\Words()\Width = TextWidth(MarkDown()\Items()\Words()\String) + dpiX(10) 
      			      ;}
      			    Default  
                  TextHeight = TextHeight(MarkDown()\Table()\Row()\Col()\Words()\String)
                  MarkDown()\Table()\Row()\Col()\Words()\Width = TextWidth(MarkDown()\Table()\Row()\Col()\Words()\String)
              EndSelect
            
              MarkDown()\Table()\Row()\Col()\Width + MarkDown()\Table()\Row()\Col()\Words()\Width
              If TextHeight > MarkDown()\Table()\Row()\Height : MarkDown()\Table()\Row()\Height = TextHeight : EndIf
              
            Next
            
            If MarkDown()\Table()\Row()\Col()\Width > MarkDown()\Table()\Column(Key$)\Width : MarkDown()\Table()\Column(Key$)\Width = MarkDown()\Table()\Row()\Col()\Width : EndIf
            ;}
          Next          
          
          MarkDown()\Table()\Row()\Height * MarkDown()\LineSpacing
          
        Next
        
        DrawingFont(FontID(MarkDown()\Font\Normal))
        
        MarkDown()\Table()\Width = 0

        ForEach MarkDown()\Table()\Column()
          MarkDown()\Table()\Column()\Width + dpiX(10)
          MarkDown()\Table()\Width + MarkDown()\Table()\Column()\Width
        Next
        
      Next  
      ;}
      
      ;{ _____ Footnotes _____
      ForEach MarkDown()\FootLabel()
        
        Font = #PB_Default
        
        DrawingFont(FontID(MarkDown()\Font\FootText))
        MarkDown()\FootLabel()\Width  = 0
        MarkDown()\FootLabel()\Height = TextHeight("X")
        
        ForEach MarkDown()\FootLabel()\Words()
          
          If Font <> MarkDown()\FootLabel()\Words()\Font : Font = DrawingFont_(MarkDown()\FootLabel()\Words()\Font) : EndIf
          
          Select MarkDown()\FootLabel()\Words()\Flag
            Case #Emoji     ;{ Emoji (16x16)
              TextHeight = dpiY(16)
              MarkDown()\FootLabel()\Words()\Width = dpiX(16)
              ;}
            Case #Image     ;{ Image
              
              If SelectElement(MarkDown()\Image(), MarkDown()\FootLabel()\Words()\Index)
                
  			        If MarkDown()\Image()\Num = #False ;{ Load Image
  			          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
  			          If MarkDown()\Image()\Num
  			            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
  			            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
  			          EndIf ;}
  			        EndIf
  			        
  			        If IsImage(MarkDown()\Image()\Num)
  			          TextHeight = dpiY(MarkDown()\Image()\Height)
  			          MarkDown()\FootLabel()\Words()\Width = dpiX(MarkDown()\Image()\Width)
  			        EndIf
  			        
  			      EndIf
  			      ;}
  			    Case #Keystroke ;{ Keystroke (5 + Key + 5)  
  			      TextHeight = TextHeight(MarkDown()\Items()\Words()\String)
  			      MarkDown()\Items()\Words()\Width = TextWidth(MarkDown()\Items()\Words()\String) + dpiX(10) 
  			      ;}  
  			    Default  
              TextHeight = TextHeight(MarkDown()\FootLabel()\Words()\String)
              MarkDown()\FootLabel()\Words()\Width = TextWidth(MarkDown()\FootLabel()\Words()\String)
          EndSelect
          
          MarkDown()\FootLabel()\Width + MarkDown()\FootLabel()\Words()\Width
          If TextHeight > MarkDown()\FootLabel()\Height : MarkDown()\FootLabel()\Height = TextHeight : EndIf
          
        Next
        
      Next ;}

      StopDrawing()
		EndIf
    
  EndProcedure	

  ;- __________ Convert __________
  
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
	  Define.s HTML$, endTag$, Link$, Title$, String$
	  
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
  	      Case #Bold|#Italic
  	        HTML$ + "<strong><em>" + EscapeHTML_(Words()\String)
  	        endTag$ = "</strong></em>"
  	      Case #StrikeThrough
  	        HTML$ + "<del>" + EscapeHTML_(Words()\String)
  	        endTag$ = "</del>"
  	        ;}
  	      Case #Code         ;{ Code
  	        HTML$ + "<code>" + EscapeHTML_(Words()\String)
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
            
              If MarkDown()\Link()\Title
                HTML$ + "<a href=" + #DQUOTE$ + Link$ + #DQUOTE$ + " title=" + #DQUOTE$ + Title$ + #DQUOTE$ + ">" + String$
              Else  
                HTML$ + "<a href=" + #DQUOTE$ + Link$ + #DQUOTE$ + ">" + String$
              EndIf
              
            EndIf
            
            endTag$ = "</a>"
            ;}
          Case #Image        ;{ Images
            
            If SelectElement(MarkDown()\Image(), Words()\Index)
              If MarkDown()\Image()\Title
                HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(Words()\String) + #DQUOTE$ + " title=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Image()\Title) + #DQUOTE$ + " />"
              Else  
                HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(Words()\String) + #DQUOTE$ + " />"
              EndIf
            EndIf
            
  	        endTag$ = ""
  	        ;}
  	      Case #FootNote     ;{ Footnotes
  	        HTML$ + "<sup>"  + EscapeHTML_(Words()\String) + "</sup>"
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
            EndSelect
            
            endTag$ = "" 
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
	
  Procedure.s ExportHTML_(Title.s="")
    Define.i Level, c, ColWidth, Cols, tBody, Class, BlockQuote, DefList
    Define.s HTML$, endTag$, Align$, Indent$, ID$, Link$, Title$, String$, Num$
    
    HTML$ = "<!DOCTYPE html>" + #LF$ + "<html>" + #LF$ + "<head>" + #LF$ + "<title>" + Title + "</title>" + #LF$ + "</head>" + #LF$ + "<body>" + #LF$
    
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
      
      If DefList And MarkDown()\Items()\Type <> #List|#Definition
        HTML$ + "</dl>" + #LF$
        DefList = #False
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
        Case #List|#Ordered    ;{ Ordered List
          
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
        Case #List|#Unordered  ;{ Unordered List
          
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
        Case #List|#Definition ;{ Definition List

          If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
            
            If Not Deflist
              HTML$ + "<dl>" + #LF$
              Deflist = #True
            EndIf
            
             HTML$ + Space(2) + "<dt>" + StringHTML_(MarkDown()\Items()\Words()) + "</dt>" + #LF$
            ForEach MarkDown()\Lists()\Row()
              HTML$ + "<dd>" + TextHTML_(MarkDown()\Lists()\Row()\Words()) + "</dd>" + #LF$
            Next
            
          EndIf  
			    ;}  
        Case #Line             ;{ Horizontal Rule
          HTML$ + "<hr />" + #LF$
          ;}
        Case #Paragraph        ;{ Paragraph
          HTML$ + "<br>" + #LF$
          ;}
        Case #List|#Task       ;{ Task List
          
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
            
            HTML$ + "<table>"  + #LF$
            
		        ForEach MarkDown()\Table()\Row()

		          If MarkDown()\Table()\Row()\Type = #Table|#Header ;{ Table Header
		            
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
                  Select MarkDown()\Table()\Column(Str(c))\Align
                    Case "C"
                      HTML$ + "<td style=" + #DQUOTE$ + "text-align: center;" + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </td>" + #LF$
                    Case "R"
                      HTML$ + "<td style=" + #DQUOTE$ + "text-align: right;"  + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </td>" + #LF$
                    Default  
                      HTML$ + "<td style=" + #DQUOTE$ + "text-align: left;"   + #DQUOTE$ + ">" + TextHTML_(MarkDown()\Table()\Row()\Col(Num$)\Words()) + " &nbsp; </td>" + #LF$
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
  
            HTML$ + "<pre>" + #LF$
            
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
        Default                ;{ Text
          
          HTML$ + TextHTML_(MarkDown()\Items()\Words())
          HTML$ + "<br>" + #LF$
          ;}
      EndSelect

    Next
    
    If DefList : HTML$ + "</dl>" + #LF$ : EndIf
    
    If BlockQuote
      HTML$ + "</blockquote>" + #LF$
      BlockQuote = #False
    EndIf
    
    If ListSize(MarkDown()\Footnote()) ;{ Footnotes
      
      HTML$ + "<br>"
      HTML$ + "<section class=" + #DQUOTE$ + "footnotes" + #DQUOTE$ + ">" + #LF$
      HTML$ + "<hr />" + #LF$
      ForEach MarkDown()\Footnote()
        HTML$ + "<sup>" + EscapeHTML_(MarkDown()\FootNote()\Label) + "</sup> " + TextHTML_(MarkDown()\FootLabel(MarkDown()\FootNote()\Label)\Words()) + "<br>" + #LF$
      Next
		  HTML$ + "</section>"+ #LF$
		  ;}
		EndIf  
    
    HTML$ + "</body>" + #LF$ + "</html>"

    ProcedureReturn HTML$
    
  EndProcedure
  
  
  CompilerIf Defined(PDF, #PB_Module)
    
    Procedure.i FontPDF_(PDF.i, Font.i)

      Select Font
        Case #Font_Bold
          PDF::SetFont(PDF, "Arial", "B", 11)
        Case #Font_Italic
          PDF::SetFont(PDF, "Arial", "I", 11)
        Case #Font_BoldItalic  
          PDF::SetFont(PDF, "Arial", "BI", 11) 
        Case #Font_FootText
          PDF::SetFont(PDF, "Arial", "", 9)
        Case #Font_FootBold
          PDF::SetFont(PDF, "Arial", "B", 9)  
        Case #Font_FootItalic
          PDF::SetFont(PDF, "Arial", "I", 9)    
        Case #Font_FootBoldItalic
          PDF::SetFont(PDF, "Arial", "BI", 9)     
        Case #Font_Code
          PDF::SetFont(PDF, "Courier New", "", 11)
        Case #Font_H6
          PDF::SetFont(PDF, "Arial", "B", 12)
        Case #Font_H5
          PDF::SetFont(PDF, "Arial", "B", 13)
        Case #Font_H4
          PDF::SetFont(PDF, "Arial", "B", 14)
        Case #Font_H3
          PDF::SetFont(PDF, "Arial", "B", 15)
        Case #Font_H2
          PDF::SetFont(PDF, "Arial", "B", 16)
        Case #Font_H1 
          PDF::SetFont(PDF, "Arial", "B", 17)
        Default
          PDF::SetFont(PDF, "Arial", "", 11)
      EndSelect
      
      ProcedureReturn Font
    EndProcedure
    
    Procedure.i EmojiPDF_(PDF.i, Emoji.s, X.i, Y.i, ImgSize.i)
      Define.i *Image
      
  	  Select Emoji
  	    Case ":date:", ":calendar:"
  	      PDF::ImageMemory(PDF, "Date.png",     ?Calendar, 485, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":mail:", ":envelope:"
          PDF::ImageMemory(PDF, "Mail.png",     ?Mail,     437, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":bookmark:"
          PDF::ImageMemory(PDF, "BookMark.png", ?BookMark, 334, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":memo:"
          PDF::ImageMemory(PDF, "Memo.png",     ?Memo,     408, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":pencil:", ":pencil2:"
          PDF::ImageMemory(PDF, "Pencil.png",   ?Pencil,   480, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":phone:", ":telephone_receiver:"
          PDF::ImageMemory(PDF, "Phone.png",    ?Phone,    383, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
  	    Case ":laugh:", ":smiley:"
          PDF::ImageMemory(PDF, "Laugh.png",    ?Laugh,    568, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":smile:", ":simple_smile:"
          PDF::ImageMemory(PDF, "Smile.png",    ?Smile,    512, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":sad:"
          PDF::ImageMemory(PDF, "Sad.png",      ?Sad,      521, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":angry:"
          PDF::ImageMemory(PDF, "Angry.png",    ?Angry,    540, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":cool:", ":sunglasses:"
          PDF::ImageMemory(PDF, "Cool.png",     ?Cool,     629, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":smirk:"
          PDF::ImageMemory(PDF, "Smirk.png",    ?Smirk,    532, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":eyes:", ":flushed:"
          PDF::ImageMemory(PDF, "Eyes.png",     ?Eyes,     583, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":rolf:"
          PDF::ImageMemory(PDF, "Rofl.png",     ?Rofl,     636, PDF::#Image_PNG, X, Y, ImgSize, ImgSize) 
        Case ":wink:"
          PDF::ImageMemory(PDF, "Wink.png",     ?Wink,     553, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
        Case ":worry:", ":worried:"
          PDF::ImageMemory(PDF, "Worry.png",    ?Worry,    554, PDF::#Image_PNG, X, Y, ImgSize, ImgSize)
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
          OffsetX = Width - TextWidth
      EndSelect    
      
      ProcedureReturn OffsetX
    EndProcedure

    Procedure.i RowPDF_(PDF.i, X.i, BlockQuote.i, List Words.Words_Structure(), ColWidth.i=#False, Align.s="L", ID.s="")
      Define.i PosX, PosY, Width, Height, Font, TextWidth, ImgSize, Image, WordIdx
      Define.i OffSetX, OffSetY, OffSetBQ, LinkPDF
      Define.s Link$, ID$
      
      ;If BlockQuote : OffSetBQ = dpiX(10) * BlockQuote : EndIf 
      
      X + OffSetBQ

      WordIdx = 0
      
      If ColWidth
        OffSetX = AlignOffsetPDF_(PDF, WordIdx, ColWidth, Align, Words())
      EndIf
      
      PDF::SetPosX(PDF, X + OffSetX)
      
      ForEach Words()
        
        If Font <> Words()\Font : Font = FontPDF_(PDF, Words()\Font) : EndIf
        
        TextWidth = PDF::GetStringWidth(PDF, Words()\String)
        
        If PDF::GetPosX(PDF) + TextWidth > MarkDown()\WrapPos
          
          WordIdx = ListIndex(Words())
          
          If ColWidth
            OffSetX = AlignOffsetPDF_(PDF, WordIdx, ColWidth, Align, Words())
          EndIf
          
          PDF::Ln(PDF, 4.5)
          PDF::SetPosX(PDF, X + OffSetX)
          
          ;If BlockQuote            ;{ BlockQuote
          ;   ;}
          ;EndIf

        EndIf

        Select Words()\Flag
          Case #AutoLink       ;{ AutoLink
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              
              PDF::SetFont(PDF, "Arial", "U", 11)
              PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 255)
              
              If CountString(Words()\String, "@") = 1
                LinkPDF = PDF::AddLinkURL(PDF, URLDecoder("mailto:" + MarkDown()\Link()\URL))
                PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
              Else  
                LinkPDF = PDF::AddLinkURL(PDF, URLDecoder(MarkDown()\Link()\URL))
                PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
              EndIf

              PDF::SetColorRGB(PDF, PDF::#TextColor, 0)
              FontPDF_(PDF, Words()\Font)
              
            EndIf
            ;}             
          Case #Emoji          ;{ Emoji  
            X = PDF::GetPosX(PDF)
            EmojiPDF_(PDF,  Words()\String, X, #PB_Default, 4)
            PDF::SetPosX(PDF, X + 4)
            ;}  
          Case #FootNote       ;{ Footnote
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
              
              PDF::Image(PDF, MarkDown()\Image()\Source, PosX, PosY, Width, Height)
              PDF::SetPosY(PDF, PosY + Height)

            EndIf
            ;}    
          Case #Link           ;{ Link
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              
              PDF::SetFont(PDF, "Arial", "U", 11)
              PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 255)
              
              If MarkDown()\Link()\Label
                Link$ = MarkDown()\Label(MarkDown()\Link()\Label)\Destination
              Else
                Link$ = MarkDown()\Link()\URL
              EndIf 
              
              If Left(Link$, 1) = "#"
                PDF::AddGotoLabel(PDF, URLDecoder(Link$))
                LinkPDF = PDF::#NoLink
              Else
                LinkPDF = PDF::AddLinkURL(PDF, URLDecoder(Link$))
              EndIf
              
              PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
              
              PDF::SetColorRGB(PDF, PDF::#TextColor, 0)
              FontPDF_(PDF, Words()\Font)
              
            EndIf
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
            PDF::SubWrite(PDF, Words()\String, 4.5, 7, 5)
            ;}
          Case #Subscript      ;{ Subscripted text
            PDF::SubWrite(PDF, Words()\String, 4.5, 7, 0)
            ;}  
          Default
            If ID$
              PDF::Cell(PDF, Words()\String, TextWidth, #PB_Default, #False, PDF::#NextLine, "", #False, ID$) 
            Else  
              PDF::Cell(PDF, Words()\String, TextWidth)
            EndIf
        EndSelect

      Next

      PDF::Ln(PDF)
      PDF::Ln(PDF, 0.5)
      
      ;If BlockQuote            ;{ BlockQuote
      ;   ;}
      ;EndIf

    EndProcedure

    Procedure.s ExportPDF_(File.s, Title.s="")
      Define.i PDF, X, Y, RowY, TextWidth, Link
      Define.i c, Cols, ColWidth, OffSetX, Width, Height
      Define.s Bullet$, Align$, Text$, Level$
      
      NewMap ListNum.i()
      
      PDF = PDF::Create(#PB_Any)
      If PDF

        PDF::AddPage(PDF)
        
        PDF::SetMargin(PDF, PDF::#TopMargin,  10)
        PDF::SetMargin(PDF, PDF::#LeftMargin, 10)
        PDF::SetMargin(PDF, PDF::#CellMargin,  0)
        
        ForEach MarkDown()\Image() ;{ Images
          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
          If IsImage(MarkDown()\Image()\Num)
            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
            FreeImage(MarkDown()\Image()\Num)
          EndIf ;}
        Next   
        
        ForEach MarkDown()\Items()
          
          MarkDown()\WrapPos = 200
          
          PDF::SetFont(PDF, "Arial", "", 11)
          
          Select MarkDown()\Items()\Type
            Case #Heading          ;{ Heading
              
              If MarkDown()\Items()\ID
                RowPDF_(PDF, 10, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words(), #False, "L", MarkDown()\Items()\ID)
              Else
                RowPDF_(PDF, 10, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
              EndIf  

              PDF::Ln(PDF, 3)
              ;}
            Case #List|#Ordered    ;{ Ordered List
              
              ClearMap(ListNum())
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
                ForEach MarkDown()\Lists()\Row()
                  
                  Level$ = Str(MarkDown()\Lists()\Row()\Level)
                  
                  ListNum(Level$) + 1
                  
                  TextWidth = PDF::GetStringWidth(PDF, Str(ListNum(Level$)) + ". ")
                  
                  If MarkDown()\Lists()\Row()\Level
                    PDF::SetPosX(PDF, 15 + (TextWidth * MarkDown()\Lists()\Row()\Level))
                  Else  
                    PDF::SetPosX(PDF, 15)
                  EndIf 

                  PDF::Cell(PDF, Str(ListNum(Level$)) + ". ", TextWidth)
                  
                  X = PDF::GetPosX(PDF)
                  RowPDF_(PDF, X, #False, MarkDown()\Lists()\Row()\Words())
                  
                Next 
                
              EndIf
              ;}
            Case #List|#Unordered  ;{ Unordered List
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
                ForEach MarkDown()\Lists()\Row()
                
                  Bullet$ = #Bullet$
                  
                  TextWidth = PDF::GetStringWidth(PDF, Bullet$ + " ")
                  
                  If MarkDown()\Lists()\Row()\Level
                    PDF::SetPosX(PDF, 15 + (TextWidth * MarkDown()\Lists()\Row()\Level))
                  Else  
                    PDF::SetPosX(PDF, 15)
                  EndIf 

                  PDF::Cell(PDF, Bullet$ + " ", TextWidth)
                  
                  X = PDF::GetPosX(PDF)
                  RowPDF_(PDF, X, #False, MarkDown()\Lists()\Row()\Words())
                  
                Next 
                
              EndIf
              ;}
            Case #List|#Task       ;{ Task List

              PDF::Ln(PDF, 3)
              
              PDF::SetMargin(PDF, PDF::#CellMargin, 0)
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)
              
                ForEach MarkDown()\Lists()\Row()
                
                  Y = PDF::GetPosY(PDF)
                  PDF::SetPosXY(PDF, 15, Y)
                  
                  If MarkDown()\Lists()\Row()\State
                    PDF::Cell(PDF, "x", 3.8, 3.8, #True, PDF::#Right, PDF::#CenterAlign)
                  Else
                    PDF::Cell(PDF, " ", 3.8, 3.8, #True, PDF::#Right, PDF::#CenterAlign)
                  EndIf
                  
                  PDF::SetPosY(PDF, Y + 0.2)
                  
                  X = 24.8 + PDF::GetStringWidth(PDF, " ")
                  
                  RowPDF_(PDF, X, MarkDown()\Items()\BlockQuote, MarkDown()\Lists()\Row()\Words())

                Next
                
              EndIf
              
              PDF::SetMargin(PDF, PDF::#CellMargin, 1)
              
              PDF::Ln(PDF, 3)
              ;}
            Case #List|#Definition ;{ Definition List
              
              If SelectElement(MarkDown()\Lists(), MarkDown()\Items()\Index)

                RowPDF_(PDF, 10, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
                
                ForEach MarkDown()\Lists()\Row()
                  RowPDF_(PDF, 15, MarkDown()\Items()\BlockQuote, MarkDown()\Lists()\Row()\Words())
                Next
                
              EndIf  
			        ;}  
            Case #Line             ;{ Horizontal Rule
              PDF::Ln(PDF, 3)
              PDF::DividingLine(PDF)
              PDF::Ln(PDF, 3)
              ;}
            Case #Paragraph        ;{ Paragraph
              PDF::Ln(PDF, 3)
              ;}
            Case #Table            ;{ Table  
              
              If SelectElement(MarkDown()\Table(), MarkDown()\Items()\Index)
                
                PDF::Ln(PDF, 3)
                
                Cols = MarkDown()\Table()\Cols
                
  			        ForEach MarkDown()\Table()\Row()
  			          
  			          RowY = 0
  			          
  			          If MarkDown()\Table()\Row()\Type = #Table|#Header
  			            
  			            PDF::SetFont(PDF, "Arial", "B", 11)
                    
                    Y = PDF::GetPosY(PDF)
                    
                    For c=1 To Cols
                      
                      ColWidth = mm_(MarkDown()\Table()\Column(Str(c))\Width) + 5
                      
                      PDF::SetPosXY(PDF, 20 + ColWidth * (c-1), Y)
                      
                      X = PDF::GetPosX(PDF)
                      
                      If FindMapElement(MarkDown()\Table()\Row()\Col(), Str(c))
                        RowPDF_(PDF, X, #False, MarkDown()\Table()\Row()\Col()\Words(), ColWidth - 2, MarkDown()\Table()\Column(Str(c))\Align)
                      EndIf
                    
                      If PDF::GetPosY(PDF) > RowY : RowY = PDF::GetPosY(PDF) : EndIf 

                    Next
                    
                    PDF::SetPosY(PDF, RowY)
                    
                    Width = 0
                    For c=1 To Cols : Width + mm_(MarkDown()\Table()\Column(Str(c))\Width) + 5 : Next
                    
                    PDF::Ln(PDF, 2)
                    PDF::DividingLine(PDF, 20, #PB_Default, Width)
                    PDF::Ln(PDF, 2)
  			            
    			        Else
    			          
    			          PDF::SetFont(PDF, "Arial", "", 11)
                    
                    Y = PDF::GetPosY(PDF)
                    
                    For c=1 To Cols
                      
                      ColWidth = mm_(MarkDown()\Table()\Column(Str(c))\Width) + 5
                      
                      PDF::SetPosXY(PDF, 20 + ColWidth * (c-1), Y)
                      
                      X = PDF::GetPosX(PDF)
                      
                      If FindMapElement(MarkDown()\Table()\Row()\Col(), Str(c))
                        RowPDF_(PDF, X, #False, MarkDown()\Table()\Row()\Col()\Words(), ColWidth - 2, MarkDown()\Table()\Column(Str(c))\Align)
                      EndIf
                      
                      If PDF::GetPosY(PDF) > RowY : RowY = PDF::GetPosY(PDF) : EndIf 
                      
                    Next
                    
                    PDF::SetPosY(PDF, RowY)
    			          
    			        EndIf

    			      Next
    			      
    			      PDF::Ln(PDF, 3)
    			      
  			      EndIf
              ;}
            Case #Code             ;{ Code Block

              PDF::Ln(PDF, 3)
              
              If SelectElement(MarkDown()\Block(), MarkDown()\Items()\Index)
                
                PDF::SetFont(PDF, "Courier New", "", 11)
                
                ForEach MarkDown()\Block()\Row()
                  PDF::Cell(PDF, MarkDown()\Block()\Row(), #PB_Default, #PB_Default, #False, PDF::#NextLine)  
                Next
                
              EndIf 
            
              PDF::Ln(PDF, 3)
              ;}
            Default                ;{ Text
              
              RowPDF_(PDF, 10, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
              ;}  
          EndSelect
          
        Next
        
        If ListSize(MarkDown()\Footnote()) ;{ Footnotes
          
          PDF::Ln(PDF, 5)
          PDF::DividingLine(PDF, #PB_Default, #PB_Default, 60)
          PDF::Ln(PDF, 2)
          
          ForEach MarkDown()\Footnote()
            PDF::SubWrite(PDF, MarkDown()\FootNote()\Label + " ", 4.5, 7, 5)
            PDF::SetFont(PDF, "Arial", "", 9)
            X = PDF::GetPosX(PDF)
            If FindMapElement(MarkDown()\FootLabel(), MarkDown()\FootNote()\Label)
              RowPDF_(PDF, X, #False, MarkDown()\FootLabel()\Words())
            EndIf
          Next
    		  ;}
    		EndIf 
        
        PDF::Close(PDF, File)
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  
  ;- __________ MarkDown Parser __________
  
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
      EndSelect
      
    EndIf
    
    ProcedureReturn #False  
  EndProcedure  

  Procedure.i IsPunctationChar(Char.s)
    
    Select Char
      Case "+", "-", ".", ",", ":", ";", "<", "=", ">", "?"
        ProcedureReturn #True
      Case "#", "$", "%", "&", "*", "@", "^", "~", "_", "|", "/"
        ProcedureReturn #True
      Case "(", ")", "[", "]", "{", "}", "'", "`", #DQUOTE$
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
  
  ; Table Description
  ; KeyStrokes: [[Esc]] [[z]]
  
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
  
  
  Procedure   ParseInline_(Row.s, List Words.Words_Structure())
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
                Case "***", "___" ;{ #Bold|#Italic
                  
                  ePos = FindString(Row, Start$, Pos + 3)
                  If ePos
                    
                    FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                    
                    If AddWords_(Mid(Row, Pos + 3, ePos - Pos - 3), Words(), #Font_BoldItalic, #Bold|#Italic)
                      ePos + 2
                    EndIf
                    
                  EndIf
                  ;}
                Case "**", "__"   ;{ #Bold
                  
                  ePos = FindString(Row, Start$, Pos + 2)
                  If ePos
                    
                    FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                    
                    If AddWords_(Mid(Row, Pos + 2, ePos - Pos - 2), Words(), #Font_Bold, #Bold)
                      ePos + 1
                    EndIf
                    
                  EndIf
                  ;}
                Case "*", "_"     ;{ #Italic
                  
                  ePos = FindString(Row, Start$, Pos + 1)
                  If ePos
                    
                    FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
                    
                    AddWords_(Mid(Row, Pos + 1, ePos - Pos - 1), Words(), #Font_Italic, #Italic)
                    
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
                        MarkDown()\Image()\Source = Mid(String$, 2, nPos - 1)
                        String$ = Trim(Mid(String$, nPos + 1))
                      EndIf 
                    Else
                      MarkDown()\Image()\Source = StringField(String$, 1, " ")
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
          ;{ ___ Footnotes / Keystrokes / Links
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
          ElseIf Mid(Row, Pos, 2) = "[["
            ;{ ___ Keystroke ___
            ePos = FindString(Row, "]]", Pos + 1)
            If ePos
              
              FirstItem = AddStringBefore_(sPos, Pos, Row, FirstItem, Words())
              
              If AddElement(Words())
                Words()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                Words()\Font   = #Font_Normal
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
                  Words()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                  Words()\Font   = #Font_Normal
                  Words()\Index  = ListIndex(MarkDown()\Link())
                  Words()\Flag   = #Link 
                EndIf
                
                nPos = ePos + 2
                
                ePos = FindString(Row, "]", nPos)
                If ePos
                  MarkDown()\Link()\Label = Mid(Row, Pos + 1, ePos - Pos - 1)
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
                    Words()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                    Words()\Font   = #Font_Normal
                    Words()\Index  = ListIndex(MarkDown()\Link())
                    Words()\Flag   = #Link 
                  EndIf
                  
                  nPos = ePos + 2
                  
                  ePos = FindString(Row, ")", nPos)
                  If ePos

                    ;{ Destination
                    String$ = Trim(Mid(Row, nPos, ePos - nPos))
                    If Left(String$, 1) = "<"
                      nPos = FindString(String$, ">", 2)
                      If nPos
                        MarkDown()\Link()\URL = Mid(String$, 2, nPos - 1)
                        String$ = Trim(Mid(String$, nPos + 1))
                      EndIf 
                    Else
                      MarkDown()\Link()\URL = StringField(String$, 1, " ")
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
                        MarkDown()\Link()\Title = Mid(String$, 2, nPos - 2)
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
              
              MarkDown()\Link()\URL = Words()\String
              
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
    Define.i NewLine, Type,  BlockQuote, StartNum, Indent
    Define.i c, Cols, ListIdx
    Define.s Row$, tRow$, String$, Char$, Start$, Close$, Label$, Col$, Num$
    Define   Lists.List_Structure
    
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
      Select Left(tRow$, 3)
        Case "- [", "+ [", "* ["
          
          If FindString(tRow$, "]", 4)
            
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
            
          Else
            Lists\Marker = ""
            Lists\Indent = 0
          EndIf
          
        Default
          
          If Lists\Indent And Type = #List|#Task And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect
      
      If Lists\Marker
        
        If AddElement(Document()) 
          
          Document()\Type = #List|#Task
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(2 * Document()\Level) + tRow$

          Document()\Marker     = Left(Lists\Marker, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #List|#Task
          
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
          
          If Lists\Indent And Type = #List|#Unordered And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect
      
      If Lists\Marker
        
        If AddElement(Document()) 
          
          Document()\Type = #List|#Unordered
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(2 * Document()\Level) + tRow$

          Document()\Marker     = Left(Lists\Marker, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #List|#Unordered
          
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
          
          If Lists\Indent And Type = #List|#Ordered And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect    
    
      If Lists\Marker
        
        If AddElement(Document())
          
          Document()\Type = #List|#Ordered
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(3 * Document()\Level) + tRow$
          
          Document()\Marker = Mid(Lists\Marker, 2, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #List|#Ordered
          
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
          
          If Lists\Indent And Type = #List|#Definition And Left(Row$, Lists\Indent) = Space(Lists\Indent)
            Document()\String + " " + tRow$
            Continue
          EndIf 
          
          Lists\Marker = ""
          
      EndSelect 
      
      If Lists\Marker
        
        If AddElement(Document()) 
          
          Document()\Type = #List|#Definition
          
          If Lists\Level < 0 : Lists\Level = 0 : EndIf 
          Document()\Level  = Lists\Level
          
          Document()\String = Space(2 * Document()\Level) + tRow$
  
          Document()\Marker     = Left(Lists\Marker, 1)
          Document()\BlockQuote = BlockQuote
          
          Type = #List|#Definition
          
          Continue
        EndIf
        
      EndIf
      ;}
      
      Lists\Marker = ""
      Lists\Indent = 0
      
      If Left(Row$, 4) = Space(4)
        
        ;{ _____ Indented code blocks _____ [4.4]
        If AddDocRow_(Mid(Row$, 5), #Code) : Continue : EndIf
        
      ElseIf Left(Row$, 1) = #TAB$
        
        If AddDocRow_(Mid(Row$, 2), #Code) : Continue : EndIf ;}
        
      Else
        
        ;{ _____ Setext headings _____      [4.3]
        If ListSize(Document()) And Document()\Type = #Parse And Not NewLine

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
        ElseIf Left(tRow$, 4) = "## "
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
        
        ;{ _____ Paragraphs _____           [4.8]
        If tRow$ = "" And Document()\String
          If AddDocRow_("", #Paragraph) : Continue : EndIf 
        EndIf ;} 
        
        ;{ _____ Thematic breaks _____      [4.1]
        Select Left(RemoveString(tRow$, " "), 3) 
          Case "---", "***", "___"
            If AddDocRow_(tRow$, #Line) : Continue : EndIf 
        EndSelect ;}
        
        ;{ _____ Fenced code blocks _____   [4.5]
        Select Left(tRow$, 3)
          Case "```"
            Close$ = GetChars_(tRow$, "`")
            If AddDocRow_(Mid(tRow$, Len(Close$) + 1), #Code|#Header) : Type = #Code : EndIf
            Continue
          Case "~~~" 
            Close$ = GetChars_(tRow$, "~")
            If AddDocRow_(Mid(tRow$, Len(Close$) + 1), #Code|#Header) : Type = #Code : EndIf
            Continue
        EndSelect
        ;}

        ;{ _____ Tables _____
        If Left(tRow$, 2) = "| "
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
                ParseInline_(Trim(Mid(Row$, ePos + 2)), MarkDown()\FootLabel()\Words())
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
                MarkDown()\Items()\ID = Mid(String$, Pos + 1, ePos - Pos - 1)
                Debug "ID: " + MarkDown()\Items()\ID
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
        Case #List|#Ordered    ;{ Ordered List
          
          If AddItemByType_(#List|#Ordered, Document()\BlockQuote) ;{ New list

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
              ParseInline_(String$, MarkDown()\Lists()\Row()\Words())
              
            EndIf
            
          EndIf
          ;}
        Case #List|#Unordered  ;{ Unordered List
          
          If AddItemByType_(#List|#Unordered, Document()\BlockQuote)
            
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
              ParseInline_(String$, MarkDown()\Lists()\Row()\Words())
              
            EndIf 
            
          EndIf
          ;}
        Case #List|#Definition ;{ Definition List
          
          If MarkDown()\Items()\Type = #Text
            
            MarkDown()\Items()\Type = #List|#Definition
            
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
              ParseInline_(String$, MarkDown()\Lists()\Row()\Words())
              
            EndIf
            
          EndIf
          ;}
        Case #List|#Task       ;{ Task List
          
          If AddItemByType_(#List|#Task, Document()\BlockQuote)
            
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
                ParseInline_(String$, MarkDown()\Lists()\Row()\Words())
              EndIf
              
            EndIf 
          
          EndIf
          ;}
        ;}  
        ;{ _____ Code blocks _____                [4.4] / [4.5]
        Case #Code|#Header
          
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
                
                ParseInline_(Mid(Document()\String, 3, ePos - 3), MarkDown()\Items()\Words())

                MarkDown()\Image()\Label = RTrim(Mid(Document()\String, ePos + 2), "]")
                
              EndIf  
              ;}
            Else  
              ;{ Inline link
              ePos = FindString(Document()\String, "](", 3)
              If ePos
                
                If AddElement(MarkDown()\Image())
                  
                  MarkDown()\Items()\Index = ListIndex(MarkDown()\Image())
                  
                  ParseInline_(Mid(Document()\String, 3, ePos - 3), MarkDown()\Items()\Words())

                  String$ = Trim(RTrim(Mid(Document()\String, ePos + 2), ")"))
                  
                  ;{ Source 
                  If Left(String$, 1) = "<"
                    nPos = FindString(String$, ">", 2)
                    If nPos
                      MarkDown()\Image()\Source = Mid(String$, 2, nPos - 1)
                      String$ = Trim(Mid(String$, nPos + 1))
                    EndIf 
                  Else
                    MarkDown()\Image()\Source = StringField(String$, 1, " ")
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
          
          String$ = Trim(Trim(Document()\String, "|"))
          
          If ListSize(MarkDown()\Table())
            
            Cols = CountString(String$, "|") + 1
            
            If Left(String$, 3) = "---" Or Left(String$, 4) = ":---" ;{ Header 
              
              If FirstElement(MarkDown()\Table()\Row())
                
                MarkDown()\Table()\Row()\Type = #Table|#Header
                
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
            Else                                                     ;{ Table row

              If AddElement(MarkDown()\Table()\Row())
                
                MarkDown()\Table()\Row()\Type = #Table
                
                For c=1 To Cols
                  Num$ = Str(c)
                  ParseInline_(Trim(StringField(String$, c, "|")), MarkDown()\Table()\Row()\Col(Num$)\Words())
                Next
                
              EndIf 
              ;}
            EndIf  
            
            If MarkDown()\Table()\Cols < Cols : MarkDown()\Table()\Cols = Cols : EndIf
            
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
                  
                  MarkDown()\Label()\Destination = StringField(String$, 1, " ")
                  
                  String$ = Trim(StringField(String$, 2, " "))
                  If CountString(String$, #DQUOTE$) = 2
                    MarkDown()\Label()\Title = Trim(String$, #DQUOTE$)
                  ElseIf CountString(StringField(String$, 2, " "), "'") = 2
                    MarkDown()\Label()\Title = Trim(String$, "'")
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
          
          ParseInline_(Row$, MarkDown()\Items()\Words())
          ;}
      EndSelect
      
    Next ;}
    
    ;{ ===== Phase 3 =====

    ;}
    
    DetermineTextSize_()
    
  EndProcedure  
  
  
	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
	
	Procedure.i Keystroke_(X.i, Y.i, Key.s)
	  Define.i Width, Height
	  
	  Width  = TextWidth(Key) + dpiX(10)
	  Height = TextHeight(Key)
	  
	  DrawingMode(#PB_2DDrawing_Default)
	  RoundBox(X, Y, Width, Height, 4, 4, MarkDown()\Color\KeyStrokeBack)
	  DrawingMode(#PB_2DDrawing_Outlined)
	  RoundBox(X, Y, Width, Height, 4, 4, MarkDown()\Color\KeyStroke)
	  DrawingMode(#PB_2DDrawing_Transparent)
	  DrawText(X + dpiX(5), Y, Key, MarkDown()\Color\KeyStroke)
	  
	  ProcedureReturn X + Width
	EndProcedure  

	Procedure   DashLine_(X.i, Y.i, Width.i, Color.i)
	  Define.i  i
	  
	  For i=0 To Width - 1 Step 2
	    Plot(X + i, Y, Color)
	  Next
	  
	EndProcedure  
	
	Procedure   CheckBox_(X.i, Y.i, boxWidth.i, FrontColor.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
      
      Box(X, Y, boxWidth, boxWidth, BackColor)
      
      LineColor = BlendColor_(FrontColor, BackColor, 60)
      
      If State

        bColor = BlendColor_(LineColor, FrontColor)
        
        X1 = X + 1
        X2 = X + boxWidth - 2
        Y1 = Y + 1
        Y2 = Y + boxWidth - 2
        
        LineXY(X1 + 1, Y1, X2 + 1, Y2, bColor)
        LineXY(X1 - 1, Y1, X2 - 1, Y2, bColor)
        LineXY(X2 + 1, Y1, X1 + 1, Y2, bColor)
        LineXY(X2 - 1, Y1, X1 - 1, Y2, bColor)
        LineXY(X2, Y1, X1, Y2, LineColor)
        LineXY(X1, Y1, X2, Y2, LineColor)
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X + 2, Y + 2, boxWidth - 4, boxWidth - 4, BlendColor_(LineColor, BackColor, 5))
      Box(X + 1, Y + 1, boxWidth - 2, boxWidth - 2, BlendColor_(LineColor, BackColor, 25))
      Box(X, Y, boxWidth, boxWidth, LineColor)
    
  EndProcedure

	Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i)
  
    If MarkDown()\Radius
  		RoundBox(X, Y, Width, Height, MarkDown()\Radius, MarkDown()\Radius, Color)
  	Else
  		Box(X, Y, Width, Height, Color)
  	EndIf
  	
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
        OffsetX = Width - TextWidth
    EndSelect    
    
    ProcedureReturn OffsetX
  EndProcedure
  
  
  Procedure.i DrawRow_(X.i, Y.i, Width.i, Height.i, BlockQuote.i, List Words.Words_Structure(), ColWidth.i=#False, Align.s="L")
    Define.i Font, TextWidth, ImgSize, Image, WordIdx
    Define.i Pos, PosX, PosY, lX, lY, OffSetX, OffSetY, OffSetBQ
    Define.s Word$
    
    If BlockQuote : OffSetBQ = dpiX(10) * BlockQuote : EndIf 
    
    X + OffSetBQ

    PosX = X
    PosY = Y

    DrawingMode(#PB_2DDrawing_Transparent)
    
    If X + Width > MarkDown()\WrapPos
      
      lY = PosY
      
      WordIdx = 0
      
      If ColWidth
        OffSetX = GetAlignOffset_(0, ColWidth - dpiX(10), Align, Words())
      EndIf
    
      ForEach Words()
        
        If Font <> Words()\Font : Font = DrawingFont_(Words()\Font) : EndIf
       
        If PosX + Words()\Width > MarkDown()\WrapPos
          
          PosX = X
          PosY + Height
          
          WordIdx = ListIndex(Words())
          
          If BlockQuote            ;{ BlockQuote
            DrawingMode(#PB_2DDrawing_Default)
            Box(MarkDown()\LeftBorder, lY, dpiX(5), Height, MarkDown()\Color\BlockQuote)
            If BlockQuote = 2
              Box(MarkDown()\LeftBorder + dpiX(10), lY, dpiX(5), Height, MarkDown()\Color\BlockQuote)
            EndIf
            DrawingMode(#PB_2DDrawing_Transparent) ;}
          EndIf
          
          lY = PosY
          
        EndIf
        
        lX = PosX
        
        Select Words()\Flag
          Case #Emoji           ;{ Draw emoji  
            If Height <= dpiY(16)
              ImgSize = Height - dpiY(1)
            Else
              ImgSize = dpiY(16)
            EndIf  
            OffSetY = (Height - ImgSize) / 2
            Image = Emoji(Words()\String)
            If IsImage(Image)
              DrawingMode(#PB_2DDrawing_AlphaBlend)
		          DrawImage(ImageID(Image), PosX, PosY + OffSetY, ImgSize, ImgSize)
		          PosX + ImgSize
		        EndIf
		        DrawingMode(#PB_2DDrawing_Transparent)
            ;}  
          Case #FootNote        ;{ Draw footnote
            
            If SelectElement(MarkDown()\Footnote(), Words()\Index)
              MarkDown()\Footnote()\X      = PosX
              MarkDown()\Footnote()\Y      = PosY
              MarkDown()\Footnote()\Width  = TextWidth(Words()\String)
              MarkDown()\Footnote()\Height = Height
            EndIf 
            
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Hint)
            ;}
          Case #Highlight       ;{ Draw highlighted text
            DrawingMode(#PB_2DDrawing_Default)
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Front, MarkDown()\Color\Highlight)
            DrawingMode(#PB_2DDrawing_Transparent)
            ;}
          Case #Image           ;{ Draw image
            
            If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
    
			        If MarkDown()\Image()\Num = #False ;{ Load Image
    	          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
    	          If MarkDown()\Image()\Num
    	            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
    	            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
    	          EndIf ;}
    	        EndIf
    	        
    	        If IsImage(MarkDown()\Image()\Num)
    	          
    	          DrawingMode(#PB_2DDrawing_AlphaBlend)
    	          DrawImage(ImageID(MarkDown()\Image()\Num), PosX, PosY)
    	          
    	          MarkDown()\Image()\X = PosX
    	          MarkDown()\Image()\Y = PosY
    	          MarkDown()\Image()\Width  = MarkDown()\Image()\Width
    	          MarkDown()\Image()\Height = MarkDown()\Image()\Height
    	          
    	          PosX + MarkDown()\Image()\Width

    	        EndIf 
    	        
    	        If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
    	        
    	      EndIf
            ;}
    	    Case #Keystroke       ;{ Draw keystroke
    	      PosX = Keystroke_(PosX, PosY, Words()\String)
    	      ;}
    	    Case #Link, #AutoLink ;{ Draw link
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              MarkDown()\Link()\X      = PosX
              MarkDown()\Link()\Y      = PosY
              MarkDown()\Link()\Width  = TextWidth(Words()\String)
              MarkDown()\Link()\Height = Height
              If MarkDown()\Link()\State
                Line(PosX, PosY + TextHeight(Words()\String) - 1, TextWidth(Words()\String), 1, MarkDown()\Color\LinkHighlight)
                PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\LinkHighlight)
              Else
                Line(PosX, PosY + TextHeight(Words()\String) - 1, TextWidth(Words()\String), 1, MarkDown()\Color\Link)
                PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Link)
              EndIf
            EndIf
            ;}
          Case #StrikeThrough   ;{ Draw strikethrough text
            lX   = PosX
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Front)
            Line(lX, PosY + Round(Height / 2, #PB_Round_Up), TextWidth(Words()\String), 1, MarkDown()\Color\Front)
            ;}
          Case #Subscript       ;{ Draw subscripted text
            OffSetY = Height - TextHeight(Words()\String) + dpiY(2)
            PosX = DrawText(PosX, PosY + OffSetY, Words()\String, MarkDown()\Color\Front)
            ;}    
          Default 
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Front)
        EndSelect

        ;{ Abbreviation
        If MapSize(MarkDown()\Abbreviation())
          
          Word$ = WordOnly_(Words()\String)
          
          If FindMapElement(MarkDown()\Abbreviation(), Word$)
            
            Pos = FindString(Words()\String, Word$)
            If Pos > 1
              MarkDown()\Abbreviation()\X = lX + TextWidth(Left(Words()\String, Pos - 1) )
            Else
              MarkDown()\Abbreviation()\X = lX  
            EndIf
            
            MarkDown()\Abbreviation()\Y = lY
            MarkDown()\Abbreviation()\Width  = TextWidth(Word$)
            MarkDown()\Abbreviation()\Height = TextHeight(Word$)
            
            DashLine_(MarkDown()\Abbreviation()\X, lY + MarkDown()\Abbreviation()\Height - 1, MarkDown()\Abbreviation()\Width, MarkDown()\Color\Hint)
          EndIf
          
        EndIf ;}
        
      Next

    Else

      lY = PosY
      
      If ColWidth ;{ Table
        
        PosX + GetAlignOffset_(0, ColWidth - dpiX(10), Align, Words())

        ;}
      EndIf
      
      ForEach Words()
        
        If Font <> Words()\Font : Font = DrawingFont_(Words()\Font) : EndIf
        
        lX = PosX
        
        Select Words()\Flag
          Case #Emoji           ;{ Draw emoji  
            If Height <= dpiY(16)
              ImgSize = Height - dpiY(1)
            Else
              ImgSize = dpiY(16)
            EndIf  
            OffSetY = (Height - ImgSize) / 2
            Image = Emoji(Words()\String)
            If IsImage(Image)
              DrawingMode(#PB_2DDrawing_AlphaBlend)
		          DrawImage(ImageID(Image), PosX, PosY + OffSetY, ImgSize, ImgSize)
		          PosX + ImgSize
		        EndIf
		        DrawingMode(#PB_2DDrawing_Transparent)
            ;}  
          Case #FootNote        ;{ Draw footnote
            
            If SelectElement(MarkDown()\Footnote(), Words()\Index)
              MarkDown()\Footnote()\X      = PosX
              MarkDown()\Footnote()\Y      = PosY
              MarkDown()\Footnote()\Width  = TextWidth(Words()\String)
              MarkDown()\Footnote()\Height = Height
            EndIf 
            
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Hint)
            ;}
          Case #Highlight       ;{ Draw highlighted text
            DrawingMode(#PB_2DDrawing_Default)
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Front, MarkDown()\Color\Highlight)
            DrawingMode(#PB_2DDrawing_Transparent)
            ;}
          Case #Image           ;{ Draw image
            
            If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
    
			        If MarkDown()\Image()\Num = #False ;{ Load Image
    	          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
    	          If MarkDown()\Image()\Num
    	            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
    	            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
    	          EndIf ;}
    	        EndIf
    	        
    	        If IsImage(MarkDown()\Image()\Num)
    	          
    	          DrawingMode(#PB_2DDrawing_AlphaBlend)
    	          DrawImage(ImageID(MarkDown()\Image()\Num), PosX, PosY)
    	          
    	          MarkDown()\Image()\X = PosX
    	          MarkDown()\Image()\Y = PosY
    	          MarkDown()\Image()\Width  = MarkDown()\Image()\Width
    	          MarkDown()\Image()\Height = MarkDown()\Image()\Height
    	          
    	          PosX + MarkDown()\Image()\Width

    	        EndIf 
    	        
    	        If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
    	        
    	      EndIf
            ;}  
    	    Case #Keystroke       ;{ Draw keystroke
    	      PosX = Keystroke_(PosX, PosY, Words()\String)
    	      ;}  
    	    Case #Link, #AutoLink ;{ Draw link
            
            If SelectElement(MarkDown()\Link(), Words()\Index)
              MarkDown()\Link()\X      = PosX
              MarkDown()\Link()\Y      = PosY
              MarkDown()\Link()\Width  = TextWidth(Words()\String)
              MarkDown()\Link()\Height = Height
              If MarkDown()\Link()\State
                Line(PosX, PosY + TextHeight(Words()\String) - 1, TextWidth(Words()\String), 1, MarkDown()\Color\LinkHighlight)
                PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\LinkHighlight)
              Else
                Line(PosX, PosY + TextHeight(Words()\String) - 1, TextWidth(Words()\String), 1, MarkDown()\Color\Link)
                PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Link)
              EndIf
            EndIf
            ;}
          Case #StrikeThrough   ;{ Draw strikethrough text
            lX   = PosX
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Front)
            Line(lX, PosY + Round(Height / 2, #PB_Round_Up), TextWidth(Words()\String), 1, MarkDown()\Color\Front)
            ;} 
          Case #Subscript       ;{ Draw subscripted text
            OffSetY = Height - TextHeight(Words()\String) + dpiY(2)
            PosX = DrawText(PosX, PosY + OffSetY, Words()\String, MarkDown()\Color\Front)
            ;}
          Default  
            PosX = DrawText(PosX, PosY, Words()\String, MarkDown()\Color\Front)
        EndSelect
        
        ;{ Abbreviation
        If MapSize(MarkDown()\Abbreviation())
          
          Word$ = WordOnly_(Words()\String)
          
          If FindMapElement(MarkDown()\Abbreviation(), Word$)
            
            Pos = FindString(Words()\String, Word$)
            If Pos > 1
              MarkDown()\Abbreviation()\X = lX + TextWidth(Left(Words()\String, Pos - 1) )
            Else
              MarkDown()\Abbreviation()\X = lX  
            EndIf
            
            MarkDown()\Abbreviation()\Y = lY
            MarkDown()\Abbreviation()\Width  = TextWidth(Word$)
            MarkDown()\Abbreviation()\Height = TextHeight(Word$)
            
            DashLine_(MarkDown()\Abbreviation()\X, lY + MarkDown()\Abbreviation()\Height - 1, MarkDown()\Abbreviation()\Width, MarkDown()\Color\Hint)
          EndIf
          
        EndIf ;}
        
      Next

    EndIf
    
    If BlockQuote            ;{ BlockQuote
      DrawingMode(#PB_2DDrawing_Default)
      Box(MarkDown()\LeftBorder, lY, dpiX(5), Height, MarkDown()\Color\BlockQuote)
      If BlockQuote = 2
        Box(MarkDown()\LeftBorder + dpiX(10), lY, dpiX(5), Height, MarkDown()\Color\BlockQuote)
      EndIf ;}
    EndIf
    
    ProcedureReturn PosY + Height
  EndProcedure
  
  Procedure.i DrawList_(Index.i, Type.i, X.i, Y.i, Width.i, Height.i, BlockQuote.i)
    Define.i PosX, bqY, OffSetBQ, Indent
    Define.s Chars$, Level$
    
    NewMap ListNum.i()
    
    If BlockQuote
      OffSetBQ = dpiX(10) * BlockQuote
      OffSetBQ - dpiX(5)
    EndIf 
    
    X + OffSetBQ

    If SelectElement(MarkDown()\Lists(), Index)
      
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(MarkDown()\Font\Normal))
      
      ListNum("1") = MarkDown()\Lists()\Start - 1
      
      If Type = #List|#Definition
        DrawingFont(FontID(MarkDown()\Font\Bold))
        Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, #False, MarkDown()\Items()\Words())
      EndIf
      
      ForEach MarkDown()\Lists()\Row()
        
        PosX = X
        bqY  = Y
        
        Select Type
          Case #List|#Ordered    ;{ Ordered list
            Level$ = Str(MarkDown()\Lists()\Row()\Level)
            ListNum(Level$) + 1
            Chars$ = Str(ListNum(Level$)) + ". "
            Indent = TextWidth(Chars$) * MarkDown()\Lists()\Row()\Level + MarkDown()\Indent
            PosX   = DrawText(PosX + Indent, Y, Chars$, MarkDown()\Color\Front)
            ;}
          Case #List|#Definition ;{ Definition list
            
            Indent = MarkDown()\Indent * MarkDown()\Lists()\Row()\Level
            PosX + Indent + MarkDown()\Indent
            ;}
          Case #List|#Task       ;{ Task list
            Indent = (MarkDown()\Lists()\Row()\Height + TextWidth(" ")) * (MarkDown()\Lists()\Row()\Level + 1) + MarkDown()\Indent
            CheckBox_(PosX + MarkDown()\Indent, Y + dpiY(1), MarkDown()\Lists()\Row()\Height - dpiY(2), MarkDown()\Color\Front, MarkDown()\Color\Back, MarkDown()\Lists()\Row()\State)
            PosX + Indent
            ;}
          Default                ;{ Unordered list
            Chars$ = #Bullet$ + " "
            Indent = TextWidth(Chars$) * MarkDown()\Lists()\Row()\Level + MarkDown()\Indent
            PosX   = DrawText(PosX + Indent, Y, Chars$, MarkDown()\Color\Front)
            ;}
        EndSelect 
        
        Y = DrawRow_(PosX, Y, MarkDown()\Lists()\Row()\Width, MarkDown()\Lists()\Row()\Height, #False, MarkDown()\Lists()\Row()\Words())
        
        If MarkDown()\Lists()\Row()\BlockQuote ;{ BlockQuote
          DrawingMode(#PB_2DDrawing_Default)
          Box(MarkDown()\LeftBorder, bqY, dpiX(5), MarkDown()\Lists()\Row()\Height, MarkDown()\Color\BlockQuote)
          If MarkDown()\Lists()\Row()\BlockQuote = 2
            Box(MarkDown()\LeftBorder + dpiX(10), bqY, dpiX(5), Y - bqY, MarkDown()\Color\BlockQuote)
          EndIf
          DrawingMode(#PB_2DDrawing_Transparent) ;}
        EndIf

      Next

    EndIf
    
    ProcedureReturn Y
  EndProcedure  
  
  Procedure.i DrawTable_(Index.i, X.i, Y.i, BlockQuote.i) 
    Define.i c, PosX, PosY, ColY, OffSetY, OffSetBQ
    Define.s Num$
    
    NewMap ColX.i()
    
    If SelectElement(MarkDown()\Table(), Index)
      
      If BlockQuote : OffSetBQ = dpiX(10) * BlockQuote : EndIf 
    
      X + OffSetBQ

      ;{ ___ Columns ___
      PosX = X
      
      For c=1 To MarkDown()\Table()\Cols
        
        Num$ = Str(c)
        
        ColX(Num$) = PosX 
        
        PosX + MarkDown()\Table()\Column(Num$)\Width
      Next
      ;}
      
      ForEach MarkDown()\Table()\Row()
        
        PosY = Y
        
        For c=1 To MarkDown()\Table()\Cols
          
          Num$ = Str(c)
          
          PosX = ColX(Num$)
          
          MarkDown()\WrapPos = PosX + MarkDown()\Table()\Column(Num$)\Width
          
          ColY = DrawRow_(PosX, PosY, MarkDown()\Table()\Row()\Col(Num$)\Width, MarkDown()\Table()\Row()\Height, BlockQuote, MarkDown()\Table()\Row()\Col(Num$)\Words(), MarkDown()\Table()\Column(Num$)\Width, MarkDown()\Table()\Column(Num$)\Align)
          
          If ColY > Y : Y = ColY : EndIf
        Next
        
        If MarkDown()\Table()\Row()\Type = #Table|#Header ;{ Header line
          OffSetY = MarkDown()\Table()\Row()\Height / 2
          Line(X, Y + OffSetY, MarkDown()\Table()\Width, 1, MarkDown()\Color\Line)
          Y + MarkDown()\Table()\Row()\Height ;}
        EndIf 
      
      Next
      
    EndIf
    
    ProcedureReturn Y
  EndProcedure
  
  
	Procedure   Draw_()
	  Define.i X, Y, Width, Height, LeftBorder, WrapPos, TextWidth, TextHeight, Cols
	  Define.i Indent, Level, Offset, OffSetX, OffSetY, maxCol, ImgSize
	  Define.i c, OffsetList, NumWidth, ColWidth, TableWidth
		Define.i FrontColor, BackColor, BorderColor, LinkColor
		Define.s Text$, Num$, ColText$, Label$

		If MarkDown()\Hide : ProcedureReturn #False : EndIf 
		
		X = dpiX(MarkDown()\Margin\Left)
		Y = dpiY(MarkDown()\Margin\Top)

		Width   = dpiX(GadgetWidth(MarkDown()\CanvasNum))  - dpiX(MarkDown()\Margin\Left + MarkDown()\Margin\Right)
		Height  = dpiY(GadgetHeight(MarkDown()\CanvasNum)) - dpiY(MarkDown()\Margin\Top  + MarkDown()\Margin\Bottom)
		
		If Not MarkDown()\Scroll\Hide : Width - dpiX(#ScrollBarSize) : EndIf 
		
		MarkDown()\LeftBorder = X
		MarkDown()\WrapPos    = dpiX(GadgetWidth(MarkDown()\CanvasNum)) - dpiX(MarkDown()\Margin\Right)
		
		If Not MarkDown()\Scroll\Hide : MarkDown()\WrapPos - dpiX(#ScrollBarSize) : EndIf 
		
		If StartDrawing(CanvasOutput(MarkDown()\CanvasNum))
		  
		  DrawingFont(FontID(MarkDown()\Font\Normal))
		  TextHeight = TextHeight("X")
			MarkDown()\Scroll\Height = TextHeight
		  
		  Y - MarkDown()\Scroll\Offset
		  
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
		  DrawingMode(#PB_2DDrawing_Default)
		  Box(0, 0, dpiX(GadgetWidth(MarkDown()\CanvasNum)), dpiY(GadgetHeight(MarkDown()\CanvasNum)), MarkDown()\Color\Gadget) ; needed for rounded corners
			Box_(0, 0, dpiX(GadgetWidth(MarkDown()\CanvasNum)), dpiY(GadgetHeight(MarkDown()\CanvasNum)), BackColor)
			;}
			
			ForEach MarkDown()\Items()
			  
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
			      
			      Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
			      Y + (TextHeight / 4)
			      ;}
			    Case #Image            ;{ Images
			      
			      If SelectElement(MarkDown()\Image(), MarkDown()\Items()\Index)
    
			        If MarkDown()\Image()\Num = #False ;{ Load Image
    	          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
    	          If MarkDown()\Image()\Num
    	            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
    	            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
    	          EndIf ;}
    	        EndIf
    	        
    	        If IsImage(MarkDown()\Image()\Num)
    	          
    	          DrawingMode(#PB_2DDrawing_AlphaBlend)
    	          DrawImage(ImageID(MarkDown()\Image()\Num), X, Y)
    	          
    	          MarkDown()\Image()\X = X
    	          MarkDown()\Image()\Y = Y
    	          MarkDown()\Image()\Width  = MarkDown()\Image()\Width
    	          MarkDown()\Image()\Height = MarkDown()\Image()\Height
    	          
    	          Y + MarkDown()\Image()\Height
    	          
    	          If ListSize(MarkDown()\Items()\Words())
    	            
    	            Y + (TextHeight / 4)
    	            
    	            OffSetX = (MarkDown()\Image()\Width - MarkDown()\Items()\Width) / 2
    	            
    	            DrawingMode(#PB_2DDrawing_Transparent)
    	            Y = DrawRow_(X + OffSetX, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())

    	          EndIf
    	          
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
			      Box(X, Y + OffSetY, Width, 2, MarkDown()\Color\Line)
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      Y + TextHeight
			      ;}
			    Case #List|#Definition ;{ Definition list
			      
			      Y = DrawList_(MarkDown()\Items()\Index, #List|#Definition, X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Case #List|#Ordered    ;{ Ordered list
			      
            Y = DrawList_(MarkDown()\Items()\Index, #List|#Ordered, X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Case #List|#Task       ;{ Task list
			      
            Y = DrawList_(MarkDown()\Items()\Index, #List|#Task, X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
          Case #List|#Unordered  ;{ Unordered list
            
            Y = DrawList_(MarkDown()\Items()\Index, #List|#Unordered, X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Case #Paragraph        ;{ Paragraph
			       Y + (TextHeight / 2)
			      ;}
			    Case #Table            ;{ Table
			      
			      Y = DrawTable_(MarkDown()\Items()\Index, X, Y, MarkDown()\Items()\BlockQuote) 
			      ;}
			    Default                ;{ Text

			      Y = DrawRow_(X, Y, MarkDown()\Items()\Width, MarkDown()\Items()\Height, MarkDown()\Items()\BlockQuote, MarkDown()\Items()\Words())
			      ;}
			  EndSelect
			  
			Next
			
			If ListSize(MarkDown()\Footnote()) ;{ Footnotes
			  
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
			
			MarkDown()\Required\Width + MarkDown()\Margin\Left + MarkDown()\Margin\Right
			MarkDown()\Required\Height = Y + MarkDown()\Margin\Bottom
			
			;{ _____ Border ____
			If MarkDown()\Flags & #Borderless = #False
				DrawingMode(#PB_2DDrawing_Outlined)
				Box_(0, 0, dpiX(GadgetWidth(MarkDown()\CanvasNum)), dpiY(GadgetHeight(MarkDown()\CanvasNum)), BorderColor)
			EndIf ;}

			StopDrawing()
		EndIf

	EndProcedure
	
	Procedure   ReDraw()
	  
	  Draw_()
	 
	  If AdjustScrollBars_() : Draw_() : EndIf 
	
	EndProcedure  
	
	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach MarkDown()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          MarkDown()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf

        MarkDown()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
				MarkDown()\Color\Back         = ModuleEx::ThemeGUI\BackColor
				MarkDown()\Color\Border       = ModuleEx::ThemeGUI\BorderColor
				MarkDown()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
				MarkDown()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
		    MarkDown()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
				
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
	
	Procedure _RightClickHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			If IsWindow(MarkDown()\Window\Num) And IsMenu(MarkDown()\PopUpNum)
				DisplayPopupMenu(MarkDown()\PopUpNum, WindowID(MarkDown()\Window\Num))
			EndIf

		EndIf

	EndProcedure

	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			X = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseY)
			
			ForEach MarkDown()\Link()
			  If Y >= MarkDown()\Link()\Y And Y <= MarkDown()\Link()\Y + MarkDown()\Link()\Height 
			    If X >= MarkDown()\Link()\X And X <= MarkDown()\Link()\X + MarkDown()\Link()\Width
			      MarkDown()\Link()\State = #True
			      Draw_()
  			    ProcedureReturn #True
  			  EndIf
			  EndIf
			Next  
			
		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, Y, Angle
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			X = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_MouseY)

			ForEach MarkDown()\Link()
			  
			  If Y >= MarkDown()\Link()\Y And Y <= MarkDown()\Link()\Y + MarkDown()\Link()\Height 
			    If X >= MarkDown()\Link()\X And X <= MarkDown()\Link()\X + MarkDown()\Link()\Width
			      
			      If MarkDown()\Link()\Label
			        If FindMapElement(MarkDown()\Label(), MarkDown()\Link()\Label)
			          MarkDown()\EventValue = MarkDown()\Label()\Destination
			        EndIf  
			      Else  
			        MarkDown()\EventValue = MarkDown()\Link()\URL
			      EndIf
			      
			      PostEvent(#Event_Gadget,    MarkDown()\Window\Num, MarkDown()\CanvasNum, #EventType_Link)
			      PostEvent(#PB_Event_Gadget, MarkDown()\Window\Num, MarkDown()\CanvasNum, #EventType_Link)
			      
			      MarkDown()\Link()\State = #False
			      
			      Draw_()
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
  			
			Next  
			
			ForEach MarkDown()\Link()
			  MarkDown()\Link()\State = #False
			Next
			
			Draw_()
			
		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
	  Define.i X, Y
	  Define.s ToolTip$
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)

			ForEach MarkDown()\Link()     ;{ Links
			  
			  If Y >= MarkDown()\Link()\Y And Y <= MarkDown()\Link()\Y + MarkDown()\Link()\Height 
			    If X >= MarkDown()\Link()\X And X <= MarkDown()\Link()\X + MarkDown()\Link()\Width
			      
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
			
			ForEach MarkDown()\Footnote() ;{ FootNotes
			  
			  If Y >= MarkDown()\Footnote()\Y And Y <= MarkDown()\Footnote()\Y + MarkDown()\Footnote()\Height 
			    If X >= MarkDown()\Footnote()\X And X <= MarkDown()\Footnote()\X + MarkDown()\Footnote()\Width
			      
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
			
			ForEach MarkDown()\Abbreviation() ;{ Abbreviations
			  
			  If Y >= MarkDown()\Abbreviation()\Y And Y <= MarkDown()\Abbreviation()\Y + MarkDown()\Abbreviation()\Height 
			    If X >= MarkDown()\Abbreviation()\X And X <= MarkDown()\Abbreviation()\X + MarkDown()\Abbreviation()\Width
			      
			      SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			      
			      If MarkDown()\ToolTip = #False
		          GadgetToolTip(GNum, Trim(MarkDown()\Abbreviation()\String))
		          MarkDown()\ToolTip  = #True
			      EndIf
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
			  ;}
			Next  
			
			ForEach MarkDown()\Image()    ;{ Images
			  
			  If MarkDown()\Image()\Title = "" : Continue : EndIf 
			  
			  If Y >= MarkDown()\Image()\Y And Y <= MarkDown()\Image()\Y + MarkDown()\Image()\Height 
			    If X >= MarkDown()\Image()\X And X <= MarkDown()\Image()\X + MarkDown()\Image()\Width
			      
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
			
			SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure
	
	Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta, ScrollPos
    
    If FindMapElement(MarkDown(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(MarkDown()\Scroll\Num) And MarkDown()\Scroll\Hide = #False
        
        ScrollPos = GetGadgetState(MarkDown()\Scroll\Num) - (MarkDown()\Scroll\Height * Delta)

        If ScrollPos > MarkDown()\Scroll\MaxPos : ScrollPos = MarkDown()\Scroll\MaxPos : EndIf
        If ScrollPos < MarkDown()\Scroll\MinPos : ScrollPos = MarkDown()\Scroll\MinPos : EndIf

        MarkDown()\Scroll\Offset = ScrollPos
        
        SetGadgetState(MarkDown()\Scroll\Num, ScrollPos)

        Draw_()
      EndIf

    EndIf
    
  EndProcedure
	
	Procedure _SynchronizeScrollBar()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.i X, Y, ScrollPos
    
    If FindMapElement(MarkDown(), Str(GadgetNum))

      ScrollPos = GetGadgetState(ScrollNum)
      If ScrollPos <> MarkDown()\Scroll\Offset
        
        If ScrollPos < MarkDown()\Scroll\Offset
          ScrollPos - MarkDown()\Scroll\Height
        ElseIf ScrollPos > MarkDown()\Scroll\Offset
          ScrollPos + MarkDown()\Scroll\Height
        EndIf
      
        If ScrollPos > MarkDown()\Scroll\MaxPos : ScrollPos = MarkDown()\Scroll\MaxPos : EndIf
        If ScrollPos < MarkDown()\Scroll\MinPos : ScrollPos = MarkDown()\Scroll\MinPos : EndIf
        
        MarkDown()\Scroll\Offset = ScrollPos
        
        SetGadgetState(MarkDown()\Scroll\Num, ScrollPos)

        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure 

	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(MarkDown(), Str(GadgetID))
		  
		  ReDraw()
		  
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
						
					EndIf

				EndIf

			EndIf

		Next

	EndProcedure

	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================

	Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)

		If FindMapElement(MarkDown(), Str(GNum))
			MarkDown()\PopupNum = PopUpNum
		EndIf

	EndProcedure
	
	Procedure   Clear(GNum.i)
	  
	  If FindMapElement(MarkDown(), Str(GNum))
	    
	    Clear_()
	    
	    ReDraw()
	  EndIf
	  
	EndProcedure  
	
	Procedure   Convert(MarkDown.s, Type.i, File.s="", Title.s="")
	  Define.i FileID
	  Define.s String
	  
	  If AddMapElement(MarkDown(), "Convert")
	    
	    Parse_(MarkDown)
	    
	    Select Type
	      Case #HTML  
    	    String = ExportHTML_(Title)
    	    
    	    FileID = CreateFile(#PB_Any, File, #PB_UTF8)
    	    If FileID
    	      WriteStringFormat(FileID,   #PB_UTF8)
    	      WriteString(FileID, String, #PB_UTF8)
    	      CloseFile(FileID)
    	    EndIf
    	  Case #PDF
    	    
    	    CompilerIf Defined(PDF, #PB_Module)
    	      ExportPDF_(File, Title)
    	    CompilerEndIf 
    	    
    	EndSelect
    	
	    DeleteMapElement(MarkDown())
	  EndIf  
	 
	EndProcedure  
	
	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(MarkDown(), Str(GNum))

      MarkDown()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
    EndIf  
    
  EndProcedure 	
  
  Procedure   Export(GNum.i, Type.i, File.s="", Title.s="")
	  Define.i FileID
	  Define.s String
	  
	  If FindMapElement(MarkDown(), Str(GNum))
	    
	    Select Type
	      Case #HTML
	        
    	    String = ExportHTML_(Title)
    	    
    	    FileID = CreateFile(#PB_Any, File, #PB_UTF8)
    	    If FileID
    	      WriteStringFormat(FileID,   #PB_UTF8)
    	      WriteString(FileID, String, #PB_UTF8)
    	      CloseFile(FileID)
    	    EndIf
    	    
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
  
  
  Procedure.s GetText(GNum.i, Type.i=#MarkDown, Title.s="")
    
    If FindMapElement(MarkDown(), Str(GNum))
      
      Select Type
        Case #HTML
          ProcedureReturn ExportHTML_()
        Case #MarkDown
          ProcedureReturn MarkDown()\Text
      EndSelect    
      
    EndIf
    
  EndProcedure
  
  
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
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
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Container)
    EndIf
		
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(MarkDown(), Str(GNum))

				MarkDown()\CanvasNum = GNum
				
				If WindowNum = #PB_Default
          MarkDown()\Window\Num = GetGadgetWindow()
        Else
          MarkDown()\Window\Num = WindowNum
        EndIf

				MarkDown()\Scroll\Num = ScrollBarGadget(#PB_Any, 0, 0, 0, Height, 0, Height, Height, #PB_ScrollBar_Vertical)
				If MarkDown()\Scroll\Num
				  SetGadgetData(MarkDown()\Scroll\Num, MarkDown()\CanvasNum)
				  HideGadget(MarkDown()\Scroll\Num, #True)
				   MarkDown()\Scroll\Hide = #True
				EndIf
				
				CloseGadgetList()
				
				LoadFonts_("Arial", 9)
				
				MarkDown()\Size\X = X
				MarkDown()\Size\Y = Y
				MarkDown()\Size\Width  = Width
				MarkDown()\Size\Height = Height
				
				MarkDown()\Margin\Top    = 5
				MarkDown()\Margin\Left   = 5
				MarkDown()\Margin\Right  = 5
				MarkDown()\Margin\Bottom = 5
				
				MarkDown()\Indent      = 10
				MarkDown()\LineSpacing = 1.06
				
				MarkDown()\Flags  = Flags

				MarkDown()\Color\Back          = $FFFFFF
				MarkDown()\Color\BlockQuote    = $C0C0C0
				MarkDown()\Color\Border        = $E3E3E3
				MarkDown()\Color\Code          = $808000
				MarkDown()\Color\DisableFront  = $72727D
				MarkDown()\Color\DisableBack   = $CCCCCA
				MarkDown()\Color\Front         = $000000
				MarkDown()\Color\Gadget        = $F0F0F0
				MarkDown()\Color\Highlight     = $E3F8FC
				MarkDown()\Color\Hint          = $006400
				MarkDown()\Color\Keystroke     = $650000
				MarkDown()\Color\KeyStrokeBack = $F5F5F5
				MarkDown()\Color\Line          = $A9A9A9
				MarkDown()\Color\Link          = $8B0000
				MarkDown()\Color\LinkHighlight = $FF0000

				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						MarkDown()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
						MarkDown()\Color\Back   = GetSysColor_(#COLOR_WINDOW)
						MarkDown()\Color\Border = GetSysColor_(#COLOR_ACTIVEBORDER)
						MarkDown()\Color\Gadget = GetSysColor_(#COLOR_MENU)
					CompilerCase #PB_OS_MacOS
						MarkDown()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						MarkDown()\Color\Back   = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
						MarkDown()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						MarkDown()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(MarkDown()\CanvasNum,  @_ResizeHandler(),         #PB_EventType_Resize)
				BindGadgetEvent(MarkDown()\CanvasNum,  @_RightClickHandler(),     #PB_EventType_RightClick)
				BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
				BindGadgetEvent(MarkDown()\CanvasNum,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
				BindGadgetEvent(MarkDown()\CanvasNum,  @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
				
				BindGadgetEvent(MarkDown()\Scroll\Num, @_SynchronizeScrollBar(),  #PB_All) 
				
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

				Draw_()

				ProcedureReturn GNum
			EndIf

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
	
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(MarkDown(), Str(GNum))
	    
	    If State
	      MarkDown()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      MarkDown()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(MarkDown(), Str(GNum))
      
      Select Attribute
        Case #Corner
          MarkDown()\Radius        = Value
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
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure	
  
  Procedure   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
    
    If FindMapElement(MarkDown(), Str(GNum))
      
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
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(MarkDown(), Str(GNum))
	    MarkDown()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetFont(GNum.i, Name.s, Size.i) 
    
    If FindMapElement(MarkDown(), Str(GNum))
      
      FreeFonts_()
      
      LoadFonts_(Name, Size)
      
      ReDraw()
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(MarkDown(), Str(GNum))
	    MarkDown()\ID = String
	  EndIf
	  
	EndProcedure

	Procedure   SetText(GNum.i, Text.s)
	  
	  If FindMapElement(MarkDown(), Str(GNum))

	    Clear_()
	    
	    MarkDown()\Text = Text
	    
	    Parse_(Text)

	    ReDraw()
	  EndIf
	  
	EndProcedure
  

	LoadEmojis_()

	;{ _____ DataSection _____
	; Author:   Emily Jäger
  ; License:	CC BY-SA 4.0 <https://creativecommons.org/licenses/by-sa/4.0/>
	; Source:   <https://openmoji.org>
	
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
EndDataSection ;}
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 0
  
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
  ; 11: Code Block
  ; 12: Emoji
  ; 13: Abbreviations
  ; 14: Keystrokes
  
  Define.s Text$
 
  Select #Example
    Case 1   
      Text$ = "Heading level 1"+ #LF$ 
      Text$ + "==============="+ #LF$
      Text$ + "Heading level 2"+ #LF$
      Text$ + "---------------"+ #LF$
      Text$ + "### Heading level 3 ###"  + #LF$
      Text$ + "#### Heading level 4 ####"  + #LF$
      Text$ + "##### Heading level 5 #####"  + #LF$
      Text$ + "###### Heading level 6 #####"  + #LF$ + #LF$
    Case 2
      Text$ = "#### Emphasis ####" + #LF$
      Text$ + "I just love **bold text**." + #LF$
      Text$ + "Italicized text is the *cat's meow*."+ #LF$
      Text$ + "This text is ___really important___.  "+ #LF$
      Text$ + "The world is ~~flat~~ round.  "+ #LF$
      Text$ + "This == word == is highlighted.  "+ #LF$
      Text$ + "-----------------------------------------" + #LF$
      Text$ + "#### Code ####" + #LF$
      Text$ + "At the command prompt, type ``nano``."+ #LF$
    Case 3
      Text$ = "#### Ordered List ####" + #LF$
      Text$ + "1. List item"+#LF$+"   2. List item"+#LF$+"   3. List item"+#LF$+"4. List item"+ #LF$
      Text$ + "-----" + #LF$
      Text$ + "#### Unordered List ####" + #LF$
      Text$ + "- First list item" + #LF$ + "  - Second list item:" + #LF$ + "  - Third list item" + #LF$ + " - Fourth list item" + #LF$ 
    Case 4
      Text$ = "#### Links & URLs ####" + #LF$ 
      Text$ + "URL: <https://www.markdownguide.org>  " + #LF$ + #LF$
      Text$ + "EMail: <fake@example.com>  " + #LF$ + #LF$
      Text$ + "Link:  [Duck Duck Go](https://duckduckgo.com "+#DQUOTE$+"My search engine!"+#DQUOTE$+")  "+ #LF$
    Case 5
      Text$ = "#### Image ####"  + #LF$
      Text$ + " ![Programmer](Test.png " + #DQUOTE$ + "Programmer Image" + #DQUOTE$ + ")"
    Case 6
      Text$ = "#### Table ####"  + #LF$
      Text$ + "| Syntax    | Description   |" + #LF$
      Text$ + "| :-------- | ------------: |" + #LF$
      Text$ + "| *Header*  | Title         |" + #LF$ 
      Text$ + "| Paragraph | *Text*        |" + #LF$ 
    Case 7
      Text$ = "#### Footnotes ####" + #LF$ + #LF$
      Text$ + "Here's a simple footnote,[^1] and here's a longer one.[^bignote]" + #LF$
      Text$ + "[^1]: This is the **first** footnote." + #LF$
      Text$ + "[^bignote]: Here's one with multiple paragraphs and code."
    Case 8
      Text$ = "#### Task List ####" + #LF$
      Text$ + "- [ ] Write the press release"+ #LF$
      Text$ + "- [X] Update the website"+ #LF$
      Text$ + "- [ ] Contact the media"+ #LF$
    Case 9  
      Text$ = "#### Definition List ####" + #LF$ + #LF$
      Text$ + "First Term" + #LF$
      Text$ + ": This is the definition of the first term." + #LF$
      Text$ + #LF$
      Text$ + "Second Term"+ #LF$
      Text$ + ": This is one definition of the *second term*." + #LF$
      Text$ + ": This is another definition of the **second term**." + #LF$
    Case 10
      Text$ = "#### SubScript / SuperScript ####" + #LF$  + #LF$
      Text$ + "Chemical formula for water: H~2~O  " + #LF$
      Text$ + "The area is 10m^2^  " + #LF$
    Case 11  
      Text$ = "#### Code Block ####" + #LF$
      Text$ + "```json" + #LF$
      Text$ + "{" + #LF$
      Text$ + "  " + #DQUOTE$ + "firstName" + #DQUOTE$ + ": " + #DQUOTE$ + "John"  + #DQUOTE$ + "," + #LF$
      Text$ + "  " + #DQUOTE$ + "lastName"  + #DQUOTE$ + ": " + #DQUOTE$ + "Smith" + #DQUOTE$ + "," + #LF$
      Text$ + "  " + #DQUOTE$ + "age"       + #DQUOTE$ + ": 25" + #LF$
      Text$ + "}" + #LF$
      Text$ + "```" + #LF$
    Case 12
      Text$ = "#### Emoji ####" + #LF$  + #LF$
      Text$ + ":phone:  telephone receiver  " + #LF$ + #LF$
      Text$ + ":mail:  envelope  " + #LF$ + #LF$
      Text$ + ":date:  calendar  " + #LF$ + #LF$
      Text$ + ":memo:  memo  " + #LF$ + #LF$
      Text$ + ":pencil:  pencil  " + #LF$ + #LF$
      Text$ + ":bookmark:  bookmark  " + #LF$ + #LF$
      Text$ + ":laugh:  grinning face with big eyes  " + #LF$ + #LF$
      Text$ + ":smile:  slightly smiling face  " + #LF$ + #LF$
      Text$ + ":smirk:  smirking face  " + #LF$ + #LF$
      Text$ + ":cool:  smiling face with sunglasses  " + #LF$ + #LF$
      Text$ + ":sad:  slightly frowning face  " + #LF$ + #LF$
      Text$ + ":angry:  angry face  " + #LF$ + #LF$
      Text$ + ":worry:  worried face  " + #LF$ + #LF$
      Text$ + ":wink:  winking face  " + #LF$ + #LF$
      Text$ + ":rolf:  rolling on the floor laughing  " + #LF$ + #LF$
      Text$ + ":eyes:  face with rolling eyes  " + #LF$
    Case 13  
      Text$ = "#### Hint / Tooltip ####" + #LF$  + #LF$
      Text$ + "The HTML specification is maintained by the W3C." + #LF$
      Text$ + "*[HTML]: Hypertext Markup Language" + #LF$
      Text$ + "*[W3C]:  World Wide Web Consortium" + #LF$
     Case 14  
      Text$ = "#### Keystrokes ####" + #LF$ + #LF$ 
      Text$ + "Copy text with [[Ctrl]] [[C]]." + #LF$
    Default  
      Text$ = "### MarkDown ###" + #LF$ + #LF$
      Text$ + "> The gadget can display text formatted with the [MarkDown Syntax](https://www.markdownguide.org/basic-syntax/).  "+ #LF$
      Text$ + "> Markdown[^1] is a lightweight MarkUp language that you can use to add formatting elements to plaintext text documents."+ #LF$ + #LF$
      Text$ + "- Markdown files can be read even if it isn’t rendered."  + #LF$
      Text$ + "- Markdown is portable." + #LF$ + "- Markdown is platform independent." + #LF$
      Text$ + "[^1]: Created by John Gruber in 2004."
  EndSelect

  Enumeration 
    #Window
    #MarkDown
    #Editor
    #Button1
    #Button2
    #Button3
    #Button4
    #Font 
  EndEnumeration
  
  LoadFont(#Font, "Arial", 10)
  
  If OpenWindow(#Window, 0, 0, 300, 290, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    EditorGadget(#Editor, 10, 10, 280, 250)
    SetGadgetFont(#Editor, FontID(#Font))
    HideGadget(#Editor, #True)
    SetGadgetText(#Editor, Text$)
    
    ButtonGadget(#Button2, 10, 265, 60, 20, "View")
    ButtonGadget(#Button1, 75, 265, 60, 20, "Edit")
    
    ButtonGadget(#Button3, 205, 265, 40, 20, "PDF")
    ButtonGadget(#Button4, 250, 265, 40, 20, "HTML")
    
    DisableGadget(#Button2, #True)
    
    If MarkDown::Gadget(#MarkDown, 10, 10, 280, 250, MarkDown::#AutoResize)
      MarkDown::SetText(#MarkDown, Text$)
      MarkDown::SetFont(#MarkDown, "Arial", 10)
    EndIf

    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case MarkDown::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #MarkDown
              Select EventType()
                Case MarkDown::#EventType_Link       ;{ Left mouse click
                  Debug "Link: " + MarkDown::EventValue(#MarkDown)
                  RunProgram(MarkDown::EventValue(#MarkDown))
                  ;}
              EndSelect
          EndSelect ;}
        Case #PB_Event_Gadget  
          Select EventGadget()  
            Case #Button1
              HideGadget(#Editor,   #False)
              HideGadget(#MarkDown, #True)
              DisableGadget(#Button1, #True)
              DisableGadget(#Button2, #False)
            Case #Button2
              HideGadget(#Editor,   #True)
              HideGadget(#MarkDown, #False)
              DisableGadget(#Button1, #False)
              DisableGadget(#Button2, #True)
            Case #Button3
              CompilerIf Defined(PDF, #PB_Module)
                MarkDown::Export(#MarkDown, MarkDown::#PDF, "Export.pdf", "PDF")
                RunProgram("Export.pdf")
              CompilerEndIf
            Case #Button4
              MarkDown::Export(#MarkDown, MarkDown::#HTML, "Export.htm", "HTML")
              RunProgram("Export.htm")
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 5528
; FirstLine = 813
; Folding = whKAAAEAAAQCAIAAAAERCAAA1DCbgIAAAACMgCAAAAAQAAEAAQSACw-
; Markers = 5528
; EnableXP
; DPIAware