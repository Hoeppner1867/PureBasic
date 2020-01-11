;/ ==================================
;/ =    MarkDownLanguageModule.pbi    =
;/ ==================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/  Gadget to display MarkDown languages
;/
;/ © 2019  by Thorsten Hoeppner (12/2019)
;/

; Last Update: 08.01.2020
;
; - Added:     MarkDown::SetMargins()
; - Attribute: #LeftMargin / #RightMargin / #TopMargin / #BottomMargin
;
; - New parser
; - Added: Highlight
; - Added: Definition List
; - Added: Code Blocks / Fenced Code Blocks
; - Added: SuperScript & SubScript
; - Added: Emojis
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
  
  #Version  = 20010201
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
	  #LeftMargin
	  #RightMargin
	  #TopMargin
	  #BottomMargin
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#BackColor
		#BlockQuoteColor
		#BorderColor
		#FrontColor
		#HighlightColor
		#HintColor
		#LinkColor
		#LinkHighlightColor
		#LineColor
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
    #HLine
    #Image
    #Italic
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
  
  Structure Hint_Structure               ;{ MarkDown()\Hint()\...
    X.i
    Y.i
    Width.i
    Height.i
    String.s
  EndStructure ;}
  
  Structure SubItem_Structure            ;{ MarkDown()\SubItem()\...
    Type.i
    String.s
    Index.i
  EndStructure ;}
  
  Structure Item_Structure               ;{ MarkDown()\Row()\Item()\...
    Type.i
    String.s
    Level.i
    State.i
    Index.i
    List SubItem.SubItem_Structure()
  EndStructure ;}
  
  Structure Row_Structure                ;{ MarkDown()\Row()\...
    X.i
    Y.i
    Width.i
    Height.i
    Type.i
    Level.i
    String.s
    Index.i
    BlockQuote.i
    ID.s
    List Item.Item_Structure()
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
    FootNoteText.i
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
		Front.i
		Back.i
		Border.i
		Gadget.i
		Highlight.i
		Hint.i
		Link.i
		LinkHighlight.i
		Line.i
		BlockQuote.i
		DisableFront.i
		DisableBack.i
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

		Map  FootLabel.s()
		Map  Label.Label_Structure()
    List Footnote.Footnote_Structure()
    List Image.Image_Structure()
    List Link.Link_Structure()
    List Row.Row_Structure()
		
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
	
	
	Procedure   FreeFonts_()
	  
	  If IsFont(MarkDown()\Font\Normal)       : FreeFont(MarkDown()\Font\Normal)       : EndIf
	  If IsFont(MarkDown()\Font\Bold)         : FreeFont( MarkDown()\Font\Bold)        : EndIf
	  If IsFont(MarkDown()\Font\Italic)       : FreeFont(MarkDown()\Font\Italic)       : EndIf
	  If IsFont(MarkDown()\Font\BoldItalic)   : FreeFont(MarkDown()\Font\BoldItalic)   : EndIf
	  If IsFont(MarkDown()\Font\Code)         : FreeFont(MarkDown()\Font\Code)         : EndIf
	  If IsFont(MarkDown()\Font\FootNote)     : FreeFont(MarkDown()\Font\FootNote)     : EndIf
	  If IsFont(MarkDown()\Font\FootNoteText) : FreeFont(MarkDown()\Font\FootNoteText) : EndIf
	  
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
	  
	  MarkDown()\Font\FootNote     = LoadFont(#PB_Any, Name, Round(Size / 1.5, #PB_Round_Up))
	  MarkDown()\Font\FootNoteText = LoadFont(#PB_Any, Name, Size - 2)
	  
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
	  ClearList(MarkDown()\Footnote())
	  ClearList(MarkDown()\Image())
	  ClearList(MarkDown()\Link())
	  ClearList(MarkDown()\Row())

	EndProcedure

	Procedure   AddText_(Row.s, BQ.i)
    
    If ListSize(MarkDown()\Row()) = 0 Or MarkDown()\Row()\Type <> #Text
      If AddElement(MarkDown()\Row())
        MarkDown()\Row()\Type       = #Text
        MarkDown()\Row()\String     = Row
        MarkDown()\Row()\BlockQuote = BQ
      Else
        If AddElement(MarkDown()\Row()\Item())
          MarkDown()\Row()\Item()\Type   = #Text
          MarkDown()\Row()\Item()\String = Row
        EndIf   
      EndIf
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
  
  Procedure.s ExportHTML_(Title.s="")
    Define.i Level, c, ColWidth, Cols, tBody, Class, BlockQuote, DefList
    Define.s HTML$, endTag$, Align$, Indent$, Syntax$, ID$, Link$, Title$, String$
    
    HTML$ = "<!DOCTYPE html>" + #LF$ + "<html>" + #LF$ + "<head>" + #LF$ + "<title>" + Title + "</title>" + #LF$ + "</head>" + #LF$ + "<body>" + #LF$
    
    ForEach MarkDown()\Row()
      
      Select MarkDown()\Row()\BlockQuote ;{ Blockquotes
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
      
      Select MarkDown()\Row()\Type
        Case #Heading          ;{ Heading
          If MarkDown()\Row()\ID
            ID$ = " id=" + #DQUOTE$ + MarkDown()\Row()\ID + #DQUOTE$
            HTML$ + "<h"+Str(MarkDown()\Row()\Level) + ID$ + ">" + EscapeHTML_(MarkDown()\Row()\String) + "</h"+Str(MarkDown()\Row()\Level) + ">" + #LF$
          Else  
            HTML$ + "<h"+Str(MarkDown()\Row()\Level) + ">" + EscapeHTML_(MarkDown()\Row()\String) + "</h"+Str(MarkDown()\Row()\Level) + ">" + #LF$
          EndIf
          ;}
        Case #List|#Ordered    ;{ Ordered List
          
          Level = 0
          
          HTML$ + "<ol>" + #LF$
          
          ForEach MarkDown()\Row()\Item()
            
            Indent$ = ""
            
            If MarkDown()\Row()\Item()\Level = 1 : Indent$ = Space(4) : EndIf 
            
            If Level = 0 And MarkDown()\Row()\Item()\Level = 1
              If MarkDown()\Row()\Item()\Type = #List|#Unordered
                HTML$ + Indent$ + "<ul>" + #LF$
                endTag$ = "</ul>"
              Else
                HTML$ + Indent$ + "<ol>" + #LF$
                endTag$ = "</ol>"
              EndIf  
              Level = 1
            ElseIf Level = 1 And MarkDown()\Row()\Item()\Level = 0
              HTML$ + Space(4) + endTag$ + #LF$
              Level = 0
            EndIf  
            
            HTML$ + Indent$ + Space(2) + "<li>"+EscapeHTML_(MarkDown()\Row()\Item()\String)+"</li>" + #LF$
    
          Next  
          
          If Level = 1
            If MarkDown()\Row()\Item()\Type = #List|#Unordered
              HTML$ + Indent$ + "</ul>" + #LF$
            Else
              HTML$ + Indent$ + "</ol>" + #LF$
            EndIf    
          EndIf 
          
          HTML$ + "</ol>" + #LF$
          ;}
        Case #List|#Unordered  ;{ Unordered List
          
          Level = 0
          
          HTML$ + "<ul>" + #LF$
          
          ForEach MarkDown()\Row()\Item()
            
            Indent$ = ""
            If MarkDown()\Row()\Item()\Level = 1 : Indent$ = "    " : EndIf 
            
            If Level = 0 And MarkDown()\Row()\Item()\Level = 1
              If MarkDown()\Row()\Item()\Type = #List|#Ordered
                HTML$ + Indent$ + "<ol>" + #LF$
                endTag$ = "</ol>"
              Else
                HTML$ + Indent$ + "<ul>" + #LF$
                endTag$ = "</ul>"
              EndIf  
              Level = 1
            ElseIf Level = 1 And MarkDown()\Row()\Item()\Level = 0
              HTML$ + Space(4) + endTag$ + #LF$
              Level = 0
            EndIf  
            
            HTML$ + Indent$ + Space(2) + "<li>"+EscapeHTML_(MarkDown()\Row()\Item()\String)+"</li>" + #LF$
    
          Next  
          
          If Level = 1
            If MarkDown()\Row()\Item()\Type = #List|#Ordered
              HTML$ + Space(2) + "</ol>" + #LF$
            Else
              HTML$ + Space(2) + "</ul>" + #LF$
            EndIf    
          EndIf 
          
          HTML$ + "</ul>" + #LF$
          ;}
        Case #List|#Definition ;{ Definition List
          ; TODO: Kombinieren der Elemente
          HTML$ + "<dl>" + #LF$
          HTML$ + Space(2) + "<dt>" + MarkDown()\Row()\String + "</dt>" + #LF$
          
          ForEach MarkDown()\Row()\Item()
            HTML$ + Space(2) + "<dd>" + MarkDown()\Row()\Item()\String + "</dd>" + #LF$
          Next
          
          HTML$ + "</dl>" + #LF$
			    ;}  
        Case #HLine            ;{ Horizontal Rule
          HTML$ + "<hr />" + #LF$
          ;}
        Case #Paragraph        ;{ Paragraph
          HTML$ + "<br>" + #LF$
          ;}
        Case #List|#Task       ;{ Task List
          
          ForEach MarkDown()\Row()\Item()
            If MarkDown()\Row()\Item()\State
              HTML$ + "<input type=" + #DQUOTE$ + "checkbox" + #DQUOTE$ + " checked=" + #DQUOTE$ + "checked" + #DQUOTE$ + ">" + #LF$
            Else  
              HTML$ + "<input type=" + #DQUOTE$ + "checkbox" + #DQUOTE$ + ">" + #LF$
            EndIf
            HTML$ + EscapeHTML_(MarkDown()\Row()\Item()\String) + #LF$
            HTML$ + "<br>"
          Next
          ;}
        Case #Table            ;{ Table
          
          Align$ = MarkDown()\Row()\String
          
          HTML$ + "<table>"  + #LF$
          
          ForEach MarkDown()\Row()\Item()
            
            Cols = CountString(MarkDown()\Row()\Item()\String, "|") + 1
            
            Select  MarkDown()\Row()\Item()\Type 
              Case #Table|#Header ;{ Table Header
                
                HTML$ + "<thead>" + #LF$ + "<tr class=" + #DQUOTE$ + "header" + #DQUOTE$ + ">" + #LF$
                
                For c=1 To Cols
                  Select StringField(Align$, c, "|")
                    Case "C"
                      HTML$ + "<th style=" + #DQUOTE$ + "text-align: center;" + #DQUOTE$ + ">" + EscapeHTML_(Trim(StringField(MarkDown()\Row()\Item()\String, c, "|"))) + " &nbsp; </th>" + #LF$
                    Case "R"
                      HTML$ + "<th style=" + #DQUOTE$ + "text-align: right;"  + #DQUOTE$ + ">" + EscapeHTML_(Trim(StringField(MarkDown()\Row()\Item()\String, c, "|"))) + " &nbsp; </th>" + #LF$
                    Default  
                      HTML$ + "<th style=" + #DQUOTE$ + "text-align: left"    + #DQUOTE$ + ">" + EscapeHTML_(Trim(StringField(MarkDown()\Row()\Item()\String, c, "|"))) + " &nbsp; </th>" + #LF$
                  EndSelect
                Next
                
                HTML$ + "</tr>" + #LF$ + "</thead>" + #LF$
                ;}
              Default      ;{ Table Body
                
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
                  Select StringField(Align$, c, "|")
                    Case "C"
                      HTML$ + "<td style=" + #DQUOTE$ + "text-align: center;" + #DQUOTE$ + ">" + EscapeHTML_(Trim(StringField(MarkDown()\Row()\Item()\String, c, "|"))) + " &nbsp; </td>" + #LF$
                    Case "R"
                      HTML$ + "<td style=" + #DQUOTE$ + "text-align: right;"  + #DQUOTE$ + ">" + EscapeHTML_(Trim(StringField(MarkDown()\Row()\Item()\String, c, "|"))) + " &nbsp; </td>" + #LF$
                    Default  
                      HTML$ + "<td style=" + #DQUOTE$ + "text-align: left;"   + #DQUOTE$ + ">" + EscapeHTML_(Trim(StringField(MarkDown()\Row()\Item()\String, c, "|"))) + " &nbsp; </td>" + #LF$
                  EndSelect
                Next
                
                HTML$ + "</tr>" + #LF$
                ;}
            EndSelect
            
          Next
          
          HTML$+ "</tbody>" + #LF$ + "</table>" + #LF$
          ;}
        Case #Code             ;{ Code Block
          
          Syntax$ = MarkDown()\Row()\String

          HTML$ + "<pre>" + #LF$
          
          If Syntax$
            HTML$ + "  <code class=" + #DQUOTE$ + "language-" + Syntax$ + #DQUOTE$ +  ">" + #LF$
          Else
            HTML$ + "  <code>" + #LF$
          EndIf
          
          ForEach MarkDown()\Row()\Item()
            HTML$ + Space(4) + EscapeHTML_(MarkDown()\Row()\Item()\String) + #LF$
          Next
          
          HTML$ + "  </code>" + #LF$ + "</pre>" + #LF$
          ;}
        Default                ;{ Text
          
          HTML$ + MarkDown()\Row()\String
          
          ForEach MarkDown()\Row()\Item()
            Select MarkDown()\Row()\Item()\Type
              Case #Bold        ;{ Emphasis
                HTML$ + "<strong>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</strong>"
              Case #Italic
                HTML$ + "<em>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</em>"
              Case #Bold|#Italic 
                HTML$ + "<strong><em>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</em></strong>"
              Case #StrikeThrough
                HTML$ + " <del>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</del>"
                ;}
              Case #Code        ;{ Code
                HTML$ + "<code>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</code>"  
                ;}
              Case #AutoLink         ;{ URL / EMail
                If CountString(MarkDown()\Row()\Item()\String, "@") = 1
                  HTML$ + "<a href=" + #DQUOTE$ + "mailto:" + URLDecoder(MarkDown()\Row()\Item()\String) + #DQUOTE$ + ">" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</a>" 
                Else  
                  HTML$ + "<a href=" + #DQUOTE$ + URLDecoder(MarkDown()\Row()\Item()\String) + #DQUOTE$ + ">" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</a>" 
                EndIf ;}
              Case #Link        ;{ Link
                If SelectElement(MarkDown()\Link(), MarkDown()\Row()\Item()\Index)
                  
                  If MarkDown()\Link()\Label
                    If FindMapElement(MarkDown()\Label(), MarkDown()\Link()\Label)
                      Link$   = MarkDown()\Label()\Destination
                      Title$  = MarkDown()\Label()\Title
                      String$ = MarkDown()\Label()\String
                    EndIf  
                  Else
                    Link$   = MarkDown()\Link()\URL
                    Title$  = MarkDown()\Link()\Title
                    String$ = MarkDown()\Row()\Item()\String
                  EndIf
                
                  If MarkDown()\Link()\Title
                    HTML$ + "<a href=" + #DQUOTE$ + URLDecoder(Link$) + #DQUOTE$ + " title=" + #DQUOTE$ + EscapeHTML_(Title$) + #DQUOTE$ + ">" + EscapeHTML_(String$) + " </a>"
                  Else  
                    HTML$ + "<a href=" + #DQUOTE$ + URLDecoder(Link$) + #DQUOTE$ + ">" + EscapeHTML_(String$) + "</a>"
                  EndIf 
                EndIf ;}
              Case #Image       ;{ Image
                If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Item()\Index)
                  Debug "> "+MarkDown()\Image()\Source
                  If MarkDown()\Image()\Title
                    HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Row()\Item()\String) + #DQUOTE$ + " title=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Image()\Title) + #DQUOTE$ + " />"
                  Else  
                    HTML$ + "<img src=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Row()\Item()\String) + #DQUOTE$ + " />"
                  EndIf
                EndIf ;}
              Case #FootNote    ;{ Footnote
                HTML$ + "<sup>"+EscapeHTML_(MarkDown()\Row()\Item()\String)+"</sup>" + #LF$
                ;}
              Case #Superscript ;{ #SuperScript
                HTML$ + "<sup>"+EscapeHTML_(MarkDown()\Row()\Item()\String)+"</sup>" + #LF$
                ;}
              Case #Subscript   ;{ SubScript
                HTML$ + "<sub>"+EscapeHTML_(MarkDown()\Row()\Item()\String)+"</sub>" + #LF$
                ;}
              Case #Emoji       ;{ Emoji
                Select MarkDown()\Row()\Item()\String
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
                ;}
              Default           ;{ Text
                HTML$ + EscapeHTML_(MarkDown()\Row()\Item()\String) ;}
            EndSelect
          Next
          
          HTML$ + "<br>" + #LF$
          ;}
      EndSelect
      
    Next
    
    If BlockQuote
      HTML$ + "</blockquote>" + #LF$
      BlockQuote = #False
    EndIf
    
    If ListSize(MarkDown()\Footnote()) ;{ Footnotes
      
      HTML$ + "<br>"
      HTML$ + "<section class=" + #DQUOTE$ + "footnotes" + #DQUOTE$ + ">" + #LF$
      HTML$ + "<hr />" + #LF$
      ForEach MarkDown()\Footnote()
        HTML$ + "<sup>" + EscapeHTML_(MarkDown()\FootNote()\Label) + "</sup> " + EscapeHTML_(MarkDown()\FootLabel(MarkDown()\FootNote()\Label)) + "<br>" + #LF$
      Next
		  HTML$ + "</section>"+ #LF$
		  ;}
		EndIf  
    
    HTML$ + "</body>" + #LF$ + "</html>"

    ProcedureReturn HTML$
    
  EndProcedure
  
  
  CompilerIf Defined(PDF, #PB_Module)
    
    Procedure.i TextPDF_(PDF.i, Text.s, WrapPos.i, Indent.i=0, maxCol.i=0, Link.i=#PB_Default, Flag.i=#False) ; WordWrap
      Define.i w, Words, OffsetY, maxWidth, LinkPDF
      Define.f X, Y, PosX, txtWidth, WordWidth
      Define.s Word$, Link$
      
      If Text = "" :  ProcedureReturn #False : EndIf 
      
      X = PDF::GetPosX(PDF)
      
      If maxCol
        maxWidth = maxCol - 5
      Else
        maxWidth = WrapPos
      EndIf
      
      txtWidth = PDF::GetStringWidth(PDF, Text)
      
      If X + txtWidth > maxWidth

        If Link = #PB_Default ;{ WordWrap
        
          Words = CountString(Text, " ") + 1
          
          For w = 1 To Words
            
            Word$ = StringField(Text, w, " ")

            WordWidth = PDF::GetStringWidth(PDF, Word$)
            
            If PDF::GetPosX(PDF) + WordWidth > maxWidth

              PDF::Ln(PDF, 4.5)
              
              If maxCol
                PDF::SetPosX(PDF, X)
              ElseIf Indent
                PDF::SetPosX(PDF, 10 + Indent)
              EndIf 

            EndIf
            
            If w < Words : Word$ + " " : EndIf
            
            If Word$ = "" : Continue : EndIf
            
            If Flag = #StrikeThrough
              PDF::DividingLine(PDF, PDF::GetPosX(PDF), PDF::GetPosY(PDF) + 2, PDF::GetStringWidth(PDF, Word$))
            EndIf 
            
            If Flag = #Highlight
              PDF::Cell(PDF, Word$, PDF::GetStringWidth(PDF, Word$), #PB_Default, #False, PDF::#Right, "", #True)
            Else  
              PDF::Cell(PDF, Word$, PDF::GetStringWidth(PDF, Word$))
            EndIf
            
          Next
          ;}
        Else                  ;{ Move to next line
          
          If SelectElement(MarkDown()\Link(), MarkDown()\Row()\Item()\Index)
            
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
            
          EndIf

          PDF::Ln(PDF)
          PDF::SetPosX(PDF, 10)
          
          If Flag = #Highlight
            PDF::Cell(PDF, Text, txtWidth, #PB_Default, #False, PDF::#Right, "", #True, "", LinkPDF)
          Else  
            PDF::Cell(PDF, Text, txtWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
          EndIf  
          ;}
        EndIf
  
      Else
        
        If Flag = #StrikeThrough
          PDF::DividingLine(PDF, PDF::GetPosX(PDF), PDF::GetPosY(PDF) + 2, txtWidth)
        EndIf         
        
        If Link = #PB_Default
          
          PDF::Cell(PDF, Text, txtWidth)
          
        Else
          
          If SelectElement(MarkDown()\Link(), MarkDown()\Row()\Item()\Index)
            
            If Left(MarkDown()\Link()\URL, 1) = "#"
              PDF::AddGotoLabel(PDF, MarkDown()\Link()\URL)
              LinkPDF = PDF::#NoLink
            Else
              LinkPDF = PDF::AddLinkURL(PDF, URLDecoder(MarkDown()\Link()\URL))
            EndIf
            
          EndIf
          
          PDF::Cell(PDF, Text, txtWidth, #PB_Default, #False, PDF::#Right, "", #False, "", LinkPDF)
          
        EndIf
        
      EndIf  
     
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

    Procedure.s ExportPDF_(File.s, Title.s="")
      Define.i PDF, Num, X, Y, RowY, TextWidth, Link
      Define.i c, Cols, ColWidth, OffSetX, Width, Height
      Define.s Bullet$, Align$
      
      PDF = PDF::Create(#PB_Any)
      If PDF

        PDF::AddPage(PDF)
        
        PDF::SetMargin(PDF, PDF::#TopMargin, 10)
        PDF::SetMargin(PDF, PDF::#LeftMargin, 10)
        PDF::SetMargin(PDF, PDF::#CellMargin, 0)
        
        ForEach MarkDown()\Image() ;{ Images
          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
          If IsImage(MarkDown()\Image()\Num)
            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
            FreeImage(MarkDown()\Image()\Num)
          EndIf ;}
        Next   
        
        ForEach MarkDown()\Row()
          
          PDF::SetFont(PDF, "Arial", "", 11)
          PDF::SetPosX(PDF, 10)
          
          Select MarkDown()\Row()\Type
            Case #Heading          ;{ Heading
              Select MarkDown()\Row()\Level
                Case 1
                  PDF::SetFont(PDF, "Arial", "B", 17)
                Case 2
                  PDF::SetFont(PDF, "Arial", "B", 16)
                Case 3
                  PDF::SetFont(PDF, "Arial", "B", 15)
                Case 4  
                  PDF::SetFont(PDF, "Arial", "B", 14)
                Case 5
                  PDF::SetFont(PDF, "Arial", "B", 13)
                Case 6
                  PDF::SetFont(PDF, "Arial", "B", 12)
              EndSelect
              
              If MarkDown()\Row()\ID
                PDF::Cell(PDF, Trim(MarkDown()\Row()\String), #PB_Default, #PB_Default, #False, PDF::#NextLine, "", #False, MarkDown()\Row()\ID) 
              Else
                PDF::Cell(PDF, Trim(MarkDown()\Row()\String), #PB_Default, #PB_Default, #False, PDF::#NextLine)
              EndIf
              
              PDF::Ln(PDF, 2)
              ;}
            Case #List|#Ordered    ;{ Ordered List
              
              Num = 0
              
              PDF::Ln(PDF, 3)
              
              ForEach MarkDown()\Row()\Item()
                
                Bullet$ = #Bullet$
                
                If MarkDown()\Row()\Item()\Level
                  Bullet$ = "- "
                  PDF::SetPosX(PDF, 15 + (5 * MarkDown()\Row()\Item()\Level))
                Else  
                  PDF::SetPosX(PDF, 15)
                EndIf 
                
                If MarkDown()\Row()\Item()\Type = #List|#Unordered
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Bullet$ + " ") 
                Else
                  Num + 1
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Str(Num)+". ") 
                EndIf  
                
              Next 
              
              PDF::Ln(PDF, 3)
              ;}
            Case #List|#Unordered  ;{ Unordered List
              
              Num = 0
              
              PDF::Ln(PDF, 3)
              
              ForEach MarkDown()\Row()\Item()
                
                Bullet$ = #Bullet$
                
                If MarkDown()\Row()\Item()\Level
                  Bullet$ = "- "
                  PDF::SetPosX(PDF, 15 + (5 * MarkDown()\Row()\Item()\Level))
                Else  
                  PDF::SetPosX(PDF, 15)
                EndIf 
                
                If MarkDown()\Row()\Item()\Type = #List|#Ordered
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Str(Num) + ". ") 
                Else
                  Num + 1
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Bullet$ + " ") 
                EndIf  
                
              Next 
              
              PDF::Ln(PDF, 3)
              ;}
            Case #List|#Task       ;{ Task List
              
              PDF::Ln(PDF, 3)
              
              PDF::SetMargin(PDF, PDF::#CellMargin, 0)
              
              ForEach MarkDown()\Row()\Item()
                
                Y = PDF::GetPosY(PDF)
                PDF::SetPosXY(PDF, 15, Y + 0.9)
                
                If MarkDown()\Row()\Item()\State
                  ;PDF::ButtonField(PDF, MarkDown()\Row()\Item()\String, #True, PDF::#Form_CheckBox, #PB_Default, 6, PDF::#NextLine)
                  PDF::Cell(PDF, "x", 3.8, 3.8, #True, PDF::#Right, PDF::#CenterAlign)
                Else
                  ;PDF::ButtonField(PDF, MarkDown()\Row()\Item()\String, #True, PDF::#Form_CheckBox, #PB_Default, 6, PDF::#NextLine)
                  PDF::Cell(PDF, " ", 3.8, 3.8, #True, PDF::#Right, PDF::#CenterAlign)
                EndIf
                
                PDF::SetPosXY(PDF, 19.2, Y)
                
                PDF::Cell(PDF, MarkDown()\Row()\Item()\String, #PB_Default, 6, #False, PDF::#NextLine)

              Next
              
              PDF::SetMargin(PDF, PDF::#CellMargin, 1)
              
              PDF::Ln(PDF, 3)
              ;}
            Case #List|#Definition ;{ Definition List

              PDF::SetFont(PDF, "Arial", "B", 11)
              PDF::SetPosX(PDF, 10)
              PDF::Cell(PDF, MarkDown()\Row()\String, 180, 5, #False, PDF::#NextLine)
             
              PDF::SetFont(PDF, "Arial", "", 11)
              ForEach MarkDown()\Row()\Item()
                PDF::SetPosX(PDF, 15)
                PDF::MultiCell(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign) 
              Next 
			        ;}  
            Case #HLine            ;{ Horizontal Rule
              PDF::Ln(PDF, 3)
              PDF::DividingLine(PDF)
              PDF::Ln(PDF, 3)
              ;}
            Case #Paragraph        ;{ Paragraph
              PDF::Ln(PDF, 3)
              ;}
            Case #Table            ;{ Table  
              
              Align$ = MarkDown()\Row()\String
              
              PDF::Ln(PDF, 3)
              
              ForEach MarkDown()\Row()\Item()
                
                RowY = 0
                Cols = CountString(MarkDown()\Row()\Item()\String, "|") + 1
                ColWidth = 170 / Cols
                
                Select  MarkDown()\Row()\Item()\Type 
                  Case #Table|#Header ;{ Table Header
                    
                    PDF::SetFont(PDF, "Arial", "B", 11)
                    
                    Y = PDF::GetPosY(PDF)
                    
                    For c=1 To Cols
                      
                      PDF::SetPosXY(PDF, 20 + ColWidth * (c-1), Y)

                      Select StringField(Align$, c, "|")
                        Case "C"
                          PDF::MultiCell(PDF, Trim(StringField(MarkDown()\Row()\Item()\String, c, "|")), ColWidth, 5, #False, PDF::#CenterAlign)
                        Case "R"
                          PDF::MultiCell(PDF, Trim(StringField(MarkDown()\Row()\Item()\String, c, "|")), ColWidth, 5, #False, PDF::#RightAlign)
                        Default  
                          PDF::MultiCell(PDF, Trim(StringField(MarkDown()\Row()\Item()\String, c, "|")), ColWidth, 5, #False, PDF::#LeftAlign)
                      EndSelect
                      
                      If PDF::GetPosY(PDF) > RowY : RowY = PDF::GetPosY(PDF) : EndIf 
                      
                    Next
                    
                    PDF::SetPosY(PDF, RowY)
                    
                    PDF::Ln(PDF, 2)
                    PDF::DividingLine(PDF, 20, #PB_Default, 170)
                    PDF::Ln(PDF, 2)
                    ;}
                  Default      ;{ Text
                    
                    PDF::SetFont(PDF, "Arial", "", 11)
                    
                    Y = PDF::GetPosY(PDF)
                    
                    For c=1 To Cols
                      
                      PDF::SetPosXY(PDF, 20 + ColWidth * (c-1), Y)
                      
                      Select StringField(Align$, c, "|")
                        Case "C"
                          PDF::MultiCell(PDF, Trim(StringField(MarkDown()\Row()\Item()\String, c, "|")), ColWidth, 5, #False, PDF::#CenterAlign)
                        Case "R"
                          PDF::MultiCell(PDF, Trim(StringField(MarkDown()\Row()\Item()\String, c, "|")), ColWidth, 5, #False, PDF::#RightAlign)
                        Default  
                          PDF::MultiCell(PDF, Trim(StringField(MarkDown()\Row()\Item()\String, c, "|")), ColWidth, 5, #False, PDF::#LeftAlign)
                      EndSelect
                      
                      If PDF::GetPosY(PDF) > RowY : RowY = PDF::GetPosY(PDF) : EndIf 
                      
                    Next
                    
                    PDF::SetPosY(PDF, RowY)
                    ;}
                EndSelect
                
              Next
              
              PDF::Ln(PDF, 3)
              ;}
            Case #Code             ;{ Code Block

              PDF::SetFont(PDF, "Courier New", "", 11)
              
              PDF::Ln(PDF, 3)
              
              ForEach MarkDown()\Row()\Item()
                PDF::SetPosX(PDF, 15)
                PDF::MultiCell(PDF, MarkDown()\Row()\Item()\String, 180, 5) 
              Next
              
              PDF::Ln(PDF, 3)
              ;}
            Default                ;{ Text

              PDF::SetFont(PDF, "Arial", "", 11)
              TextPDF_(PDF, MarkDown()\Row()\String, 200)
              
              ForEach MarkDown()\Row()\Item()

                Select MarkDown()\Row()\Item()\Type
                  Case #Bold        ;{ Emphasis
                    PDF::SetFont(PDF, "Arial", "B", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200) 
                  Case #Italic
                    PDF::SetFont(PDF, "Arial", "I", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200)
                  Case #Bold|#Italic 
                    PDF::SetFont(PDF, "Arial", "BI", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200)
                  Case #StrikeThrough  
                    PDF::SetFont(PDF, "Arial", "", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200, 0, 0, #PB_Default, #StrikeThrough)
                    ;}
                  Case #Code        ;{ Code
                    PDF::SetFont(PDF, "Courier New", "", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200)
                    ;}
                  Case #AutoLink         ;{ URL / EMail
                    PDF::SetFont(PDF, "Arial", "U", 11)
                    PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 255)
                    If CountString(MarkDown()\Row()\Item()\String, "@") = 1
                      TextPDF_(PDF, "mailto:" + MarkDown()\Row()\Item()\String, 200, 0, 0, MarkDown()\Row()\Item()\Index)
                    Else  
                      TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200, 0, 0, MarkDown()\Row()\Item()\Index)
                    EndIf
                    PDF::SetColorRGB(PDF, PDF::#TextColor, 0)
                    ;}
                  Case #Link        ;{ Link
                    PDF::SetFont(PDF, "Arial", "U", 11)
                    PDF::SetColorRGB(PDF, PDF::#TextColor, 0, 0, 255)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200, 0, 0, MarkDown()\Row()\Item()\Index)
                    PDF::SetColorRGB(PDF, PDF::#TextColor, 0)
                    ;}  
                  Case #FootNote    ;{ Footnote
                    PDF::SubWrite(PDF, MarkDown()\Row()\Item()\String, 4.5, 7, 5)
                    ;}
                  Case #Highlight   ;{ Highlighted text 
                    PDF::SetFont(PDF, "Arial", "", 11)
                    PDF::SetColorRGB(PDF, PDF::#FillColor, 252, 248, 227)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200, 0, 0, #PB_Default, #Highlight)
                    PDF::SetColorRGB(PDF, PDF::#FillColor, 255, 255, 255)
                    ;}
                  Case #Image       ;{ Image
                    
                    If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Item()\Index)
                      
                      X = PDF::GetPosX(PDF)
                      Y = PDF::GetPosY(PDF)
                      Width  = mm_(MarkDown()\Image()\Width)
                      Height = mm_(MarkDown()\Image()\Height)
                      
                      PDF::Image(PDF, MarkDown()\Image()\Source, X, Y, Width, Height)
                      PDF::SetPosY(PDF, Y + Height)

                      If MarkDown()\Row()\Item()\String
                        PDF::Ln(PDF, 1)
                        PDF::Cell(PDF, MarkDown()\Row()\Item()\String, Width, #PB_Default, #False, PDF::#NextLine, PDF::#CenterAlign)
                        PDF::Ln(PDF)
                      EndIf
                      
                    EndIf
                    ;}  
                  Case #Subscript   ;{ SubScript 
                    PDF::SubWrite(PDF, MarkDown()\Row()\Item()\String, 4.5, 7, 0)
                    ;}
                  Case #Superscript ;{ SuperScript
                    PDF::SubWrite(PDF, MarkDown()\Row()\Item()\String, 4.5, 7, 5)
                    ;}
                  Case #Emoji       ;{ Emoji
                    PDF::SetFont(PDF, "Arial", "", 11)
                    X = PDF::GetPosX(PDF)
                    EmojiPDF_(PDF, MarkDown()\Row()\Item()\String, X, #PB_Default, 4)
                    PDF::SetPosX(PDF, X + 4)
                    ;}
                  Default           ;{ Text
                    PDF::SetFont(PDF, "Arial", "", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200)
                    ;}
                EndSelect
                
              Next
              
              PDF::Ln(PDF, 4.5)
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
            TextPDF_(PDF, MarkDown()\FootLabel(MarkDown()\Footnote()\Label), 200, PDF::GetStringWidth(PDF, MarkDown()\FootLabel(MarkDown()\Footnote()\Label) + " "))
            PDF::Ln(PDF, 4)
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
  
  
  Procedure.i AddSubItemText_(sPos.i, Pos.i, Row.s, FirstItem.i)
    
    If sPos <= Pos 
      If FirstItem 
        MarkDown()\Row()\Item()\String = LTrim(Mid(Row, sPos, Pos - sPos))
        FirstItem = #False
      ElseIf AddElement(MarkDown()\Row()\Item()\SubItem())
        MarkDown()\Row()\Item()\SubItem()\Type   = #Text
        MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, sPos, Pos - sPos)
      EndIf   
    EndIf
    
    ProcedureReturn FirstItem
  EndProcedure 
  
  Procedure.i AddItemText_(sPos.i, Pos.i, Row.s, FirstItem.i)
    
    If sPos <= Pos 
      If FirstItem 
        MarkDown()\Row()\String = LTrim(Mid(Row, sPos, Pos - sPos))
        FirstItem = #False
      ElseIf AddElement(MarkDown()\Row()\Item())
        MarkDown()\Row()\Item()\Type   = #Text
        MarkDown()\Row()\Item()\String = Mid(Row, sPos, Pos - sPos)
      EndIf   
    EndIf
    
    ProcedureReturn FirstItem
  EndProcedure  
  
  Procedure.i AddTypeRow_(Type.i, BlockQuote.i)
    
    If ListSize(MarkDown()\Row()) = 0 Or MarkDown()\Row()\Type <> Type
      If AddElement(MarkDown()\Row())
        MarkDown()\Row()\Type       = Type
        MarkDown()\Row()\BlockQuote = BlockQuote
        ProcedureReturn #True
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
  
  ; Abbreviation: *[HTML]: Hyper Text Markup Language
  
  ; KeyStrokes: [[Esc]] [[z]]
  
  Procedure   ParseInline_(Row.s)
    Define.i Pos, sPos, ePos, nPos, Length, FirstItem, Left, Right
    Define.s String$, Start$, Char$
    
    Pos = 1 : sPos = 1 : FirstItem = #True
    Length = Len(Row)
    
    Repeat
      
      ePos = 0
    
      Select Mid(Row, Pos, 1)
        Case "\"
          ;{ ___ Backslash escapes ___          [6.1]
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
          ;{ ___ Code spans ___                 [6.3] 
          If Mid(Row, Pos, 2) = "``"  ;{ " ``code`` "
            
            ePos = FindString(Row, "``", Pos + 2)
            If ePos
              
              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              
              If AddElement(MarkDown()\Row()\Item()\SubItem())
                MarkDown()\Row()\Item()\SubItem()\Type = #Code
                MarkDown()\Row()\Item()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                If Left(MarkDown()\Row()\Item()\SubItem()\String, 1) = " " : MarkDown()\Row()\Item()\SubItem()\String = Mid(MarkDown()\Row()\Item()\SubItem()\String, 2) : EndIf ; Remove 1 leading space
              EndIf
              
              ePos + 1
            EndIf
            
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
            ;}
          Else                        ;{ " `code` "
            
            ePos = FindString(Row, "`",  Pos + 1)
            If ePos

              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              
              If AddElement(MarkDown()\Row()\Item()\SubItem())
                MarkDown()\Row()\Item()\SubItem()\Type = #Code
                MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                If Left(MarkDown()\Row()\Item()\SubItem()\String, 1) = " " : MarkDown()\Row()\Item()\SubItem()\String = Mid(MarkDown()\Row()\Item()\SubItem()\String, 2) : EndIf ; Remove 1 leading space
              EndIf
              
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
                  FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
                  If AddElement(MarkDown()\Row()\Item()\SubItem())
                    MarkDown()\Row()\Item()\SubItem()\Type   = #Bold|#Italic
                    MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 3, ePos - Pos - 3)
                    ePos + 2
                  EndIf
                EndIf
                ;}
              Case "**", "__"   ;{ #Bold
                
                ePos = FindString(Row, Start$, Pos + 2)
                If ePos
                  FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
                  If AddElement(MarkDown()\Row()\Item()\SubItem())
                    MarkDown()\Row()\Item()\SubItem()\Type   = #Bold
                    MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                    ePos + 1
                  EndIf
                EndIf
                ;}
              Case "*", "_"     ;{ #Italic
                
                ePos = FindString(Row, Start$, Pos + 1)
                If ePos
                  FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
                  If AddElement(MarkDown()\Row()\Item()\SubItem())
                    MarkDown()\Row()\Item()\SubItem()\Type   = #Italic
                    MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                  EndIf
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
          
          FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
          
          ePos = FindString(Row, "][", Pos + 1)
          If ePos
            ;{ Reference link
            FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
            
            If AddElement(MarkDown()\Row()\Item()\SubItem())
              
              MarkDown()\Row()\Item()\SubItem()\Type   = #Image
              MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
              
              nPos = ePos + 2
              If AddElement(MarkDown()\Image())
               
                MarkDown()\Row()\Item()\SubItem()\Index = ListIndex(MarkDown()\Image())
                
                ePos = FindString(Row, "]", nPos)
                If ePos
                  MarkDown()\Image()\Label = Mid(Row, Pos + 1, ePos - Pos - 1)
                EndIf
                
              EndIf  
             
            EndIf
            ;}
          Else
            ;{ Inline link
            ePos = FindString(Row, "](", Pos + 1)
            If ePos
              
              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              
              If AddElement(MarkDown()\Row()\Item()\SubItem())
                
                MarkDown()\Row()\Item()\SubItem()\Type   = #Image
                MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
               
                nPos = ePos + 2
                
                ePos = FindString(Row, ")", nPos)
                If ePos
                  
                  If AddElement(MarkDown()\Image())
                    
                    MarkDown()\Row()\Item()\SubItem()\Index = ListIndex(MarkDown()\Image())
                    
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

            EndIf
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
            ;}
          EndIf
          
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
        EndIf   
        ;}
        Case "["
          ;{ ___ Footnotes / Links
          If Mid(Row, Pos, 2) = "[^"
            ;{ ___ Footnote ___
            ePos = FindString(Row, "]", Pos + 1)
            If ePos
              
              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              
              If AddElement(MarkDown()\Row()\Item())
                
                MarkDown()\Row()\Item()\Type   = #FootNote
                MarkDown()\Row()\Item()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                
                If AddElement(MarkDown()\Footnote())
                  MarkDown()\Footnote()\Label   = MarkDown()\Row()\Item()\String
                  MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Footnote())
                EndIf
                
              EndIf
              
            EndIf 
          
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf  
            ;}
          Else  
            ;{ ___ Links  ___                     [6.5]
            ePos = FindString(Row, "][", Pos + 1)
            If ePos
              ;{ Reference link
              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              
              If AddElement(MarkDown()\Row()\Item())
                
                MarkDown()\Row()\Item()\Type   = #Link
                MarkDown()\Row()\Item()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                
                nPos = ePos + 2
                If AddElement(MarkDown()\Link())
                 
                  MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Link())
                  
                  ePos = FindString(Row, "]", nPos)
                  If ePos
                    MarkDown()\Link()\Label = Mid(Row, Pos + 1, ePos - Pos - 1)
                  EndIf
                  
                EndIf  
              
              EndIf
              If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
              ;}
            Else
              ;{ Inline link
              ePos = FindString(Row, "](", Pos + 1)
              If ePos
                
                FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
                
                If AddElement(MarkDown()\Row()\Item())
                  
                  MarkDown()\Row()\Item()\Type   = #Link
                  MarkDown()\Row()\Item()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
                  
                  nPos = ePos + 2
                  
                  ePos = FindString(Row, ")", nPos)
                  If ePos
                    
                    If AddElement(MarkDown()\Link())
                      
                      MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Link())
                      
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
                          MarkDown()\Link()\Title = Mid(String$, 2, nPos - 1)
                        EndIf 
                      EndIf ;}
                      
                    EndIf
                    
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
          
            FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
            
            If AddElement(MarkDown()\Row()\Item()\SubItem())
              
              MarkDown()\Row()\Item()\SubItem()\Type   = #AutoLink
              MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 1, ePos - Pos - 1) 
              
              If AddElement(MarkDown()\Link())
                MarkDown()\Row()\Item()\SubItem()\Index = ListIndex(MarkDown()\Link())
                MarkDown()\Link()\URL = MarkDown()\Row()\Item()\SubItem()\String
              EndIf
              
            EndIf
              
            If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
          EndIf  
          ;}
        Case "~" 
          ;{ ___ Strikethrough / Subscript ___
          If Mid(Row, Pos, 2) = "~~" ;{ Strikethrough
            ePos = FindString(Row, "~~", Pos + 1)
            If ePos
              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              If AddElement(MarkDown()\Row()\Item()\SubItem())
                MarkDown()\Row()\Item()\SubItem()\Type   = #StrikeThrough
                MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
                ePos + 1
              EndIf
            EndIf ;}
          Else                        ;{ Subscript 
            ePos = FindString(Row, "~", Pos + 1)
            If ePos
              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              If AddElement(MarkDown()\Row()\Item()\SubItem())
                MarkDown()\Row()\Item()\SubItem()\Type   = #Subscript
                MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
              EndIf
            EndIf ;}
          EndIf 
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
          ;}
        Case "^"
          ;{ ___ Superscript ___
          ePos = FindString(Row, "^", Pos + 1)
          If ePos
            FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
            If AddElement(MarkDown()\Row()\Item()\SubItem())
              MarkDown()\Row()\Item()\SubItem()\Type   = #Superscript
              MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
            EndIf
          EndIf
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
          ;}
        Case "="
          ;{ ___ Highlight ___
          If Mid(Row, Pos, 2) = "=="
            ePos = FindString(Row, "==", Pos + 2)
            If ePos
              FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
              If AddElement(MarkDown()\Row()\Item()\SubItem())
                MarkDown()\Row()\Item()\SubItem()\Type   = #Highlight
                MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos + 2, ePos - Pos - 2)
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
            
            FirstItem = AddSubItemText_(sPos, Pos, Row, FirstItem)
            
            If AddElement(MarkDown()\Row()\Item()\SubItem())
              MarkDown()\Row()\Item()\SubItem()\Type   = #Emoji
              MarkDown()\Row()\Item()\SubItem()\String = Mid(Row, Pos, ePos - Pos + 1)
            EndIf
            
          EndIf
          If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf
          ;}  
      EndSelect
      
      Pos + 1
    Until Pos > Length  

    AddSubItemText_(sPos, Pos, Row, FirstItem)
    
  EndProcedure
  
  Procedure   ParseMD_(Text.s)
    ; -------------------------------------------------------------------------
    ; <https://spec.commonmark.org> - Version 0.29 (2019-04-06) John MacFarlane
    ; -------------------------------------------------------------------------
    Define.i r, Rows, Pos, sPos, ePos, nPos, Length, Left, Right
    Define.i NewLine, Type,  BlockQuote, StartNum, Indent, FirstItem
    Define.i c, Cols
    Define.s Row$, tRow$, String$, Char$, Start$, Close$, Label$, Col$
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
          BlockQuote = 2
        ElseIf Left(tRow$, 1) = ">" 
          Pos  = FindString(Row$, ">")
          Row$ = LTrim(Mid(Row$, Pos + 1))
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
            If AddDocRow_(tRow$, #HLine) : Continue : EndIf 
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
        
        ;{ _____ Footnote reference definitions _____
        If Left(tRow$, 2) = "[^"
          
          ePos = FindString(tRow$, "]:", 3)
          If ePos
            
            Label$ = Mid(tRow$, 3, ePos - 3)
            If Label$
              
              If AddMapElement(MarkDown()\FootLabel(), Label$)
                MarkDown()\FootLabel() = Trim(Mid(Row$, ePos + 2))
              EndIf 
              
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
    ClearList(MarkDown()\Row())
    
    ForEach Document()
      
      Select Document()\Type
        ;{ _____ Thematic breaks _____            [4.1]  
        Case #HLine
          If AddElement(MarkDown()\Row())
            MarkDown()\Row()\Type = #HLine
          EndIf
          ;}
        ;{ _____ ATX headings _____               [4.2]
        Case #Heading
          If AddElement(MarkDown()\Row())
            MarkDown()\Row()\Type   = #Heading
            MarkDown()\Row()\Level  = CountString(Document()\String, "#")
            MarkDown()\Row()\String = Trim(LTrim(Document()\String, "#"))
          EndIf  
          ;}
        ;{ _____ Paragraphs _____                 [4.8]  
        Case #Paragraph
          ; TODO: Remove initial and final whitespace.
          If AddElement(MarkDown()\Row())
            MarkDown()\Row()\Type = #Paragraph 
          EndIf ;}
        ;{ _____ Lists _____                      [5.3]
        Case #List|#Ordered    ;{ Ordered List
          
          StartNum = AddTypeRow_(#List|#Ordered, Document()\BlockQuote)
          
          If AddElement(MarkDown()\Row()\Item())
            
            MarkDown()\Row()\Item()\Type = #List|#Ordered
            
            If StartNum : MarkDown()\Row()\Item()\State = Val(Left(LTrim(Document()\String), 1)) : EndIf
            
            MarkDown()\Row()\Item()\Level  = Document()\Level
            MarkDown()\Row()\Item()\String = Trim(Mid(LTrim(Document()\String), 4)) ; '1. ' or '1) '
            
            StartNum = #False
            
          EndIf
          ;}
        Case #List|#Unordered  ;{ Unordered List
          
          AddTypeRow_(#List|#Unordered, Document()\BlockQuote)
          
          If AddElement(MarkDown()\Row()\Item())
            MarkDown()\Row()\Item()\Type   = #List|#Unordered
            MarkDown()\Row()\Item()\Level  = Document()\Level
            MarkDown()\Row()\Item()\String = Trim(Mid(LTrim(Document()\String), 3)) ; '- ' or '+ ' or '* '
          EndIf
          ;}
        Case #List|#Definition ;{ Definition List

          If MarkDown()\Row()\Type = #Text : MarkDown()\Row()\Type = #List|#Definition : EndIf
          
          If AddElement(MarkDown()\Row()\Item())
            MarkDown()\Row()\Item()\Type   = #List|#Definition
            MarkDown()\Row()\Item()\Level  = Document()\Level
            MarkDown()\Row()\Item()\String = Trim(Mid(LTrim(Document()\String), 3)) ; '- ' or '+ ' or '* '
          EndIf
          ;}
        Case #List|#Task       ;{ Task List
          
          AddTypeRow_(#List|#Task, Document()\BlockQuote)
          
          If AddElement(MarkDown()\Row()\Item())
            
            MarkDown()\Row()\Item()\Type = #List|#Task

            MarkDown()\Row()\Item()\Level  = Document()\Level
            
            String$ = Trim(Mid(LTrim(Document()\String), 3)) ; '- ' or '+ ' or '* '
            
            Select Left(String$, 3)
              Case "[ ]", "[] "
                MarkDown()\Row()\Item()\State = #False
              Case "[X]", "[x]"
                MarkDown()\Row()\Item()\State = #True
            EndSelect
            
            nPos = FindString(String$, "]", 2)
            If nPos
              MarkDown()\Row()\Item()\String = Mid(String$, nPos + 1) 
            EndIf
            
          EndIf ;}    
        ;}
        ;{ _____ Code blocks _____                [4.4] / [4.5]
        Case #Code|#Header
          
          If AddElement(MarkDown()\Row())
            MarkDown()\Row()\Type       = #Code
            MarkDown()\Row()\String     = Document()\String
            MarkDown()\Row()\BlockQuote = Document()\BlockQuote
          EndIf 
          
        Case #Code 
          
          AddTypeRow_(#Code, Document()\BlockQuote)
          
          If AddElement(MarkDown()\Row()\Item())
            MarkDown()\Row()\Item()\Type   = #Code
            MarkDown()\Row()\Item()\String = Document()\String
          EndIf  
        ;}  
        ;{ _____ Tables _____
        Case #Table
          
          AddTypeRow_(#Table, Document()\BlockQuote)
 
          String$ = Trim(Trim(Document()\String, "|"))
          
          If Left(String$, 3) = "---" Or Left(String$, 4) = ":---" ;{ Header 
            
            If FirstElement(MarkDown()\Row()\Item())
              
              MarkDown()\Row()\Item()\Type | #Header
              MarkDown()\Row()\String = ""
              
              Cols = CountString(String$, "|") + 1
              For c=1 To Cols
                Col$ = Trim(StringField(String$, c, "|"))
                If Left(Col$, 1) = ":" And Right(Col$, 1) = ":"
                  MarkDown()\Row()\String + "C|"
                ElseIf Right(Col$, 1) = ":"
                  MarkDown()\Row()\String + "R|"
                Else
                  MarkDown()\Row()\String + "L|"
                EndIf
              Next
              
              MarkDown()\Row()\String = RTrim(MarkDown()\Row()\String, "|")
              
              LastElement(MarkDown()\Row()\Item())
            EndIf
            ;}
          Else
            If AddElement(MarkDown()\Row()\Item())
              MarkDown()\Row()\Item()\Type   = #Table
              MarkDown()\Row()\Item()\String = String$
            EndIf  
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
          If AddElement(MarkDown()\Row())
            MarkDown()\Row()\Type       = #Text
            MarkDown()\Row()\BlockQuote = Document()\BlockQuote
            FirstItem = #True
          EndIf ;}
          
          Repeat
            
            ePos = 0
            
            Select Mid(Row$, Pos, 1)
              Case "\"
                ;{ ___ Backslash escapes ___            [6.1]
                Select Mid(Row$, Pos, 2)
                  Case "\+", "\-", "\=", "\<", "\>", "\~", "\:", "\.", "\,", "\;", "\!", "\?"
                    Row$ = RemoveString(Row$, "\", #PB_String_CaseSensitive, Pos, 1)
                    Pos + 1
                  Case "\@", "\*", "\#", "\$", "\%", "\&", "\^", "\`", "\'", "\"+#DQUOTE$ 
                    Row$ = RemoveString(Row$, "\", #PB_String_CaseSensitive, Pos, 1)
                    Pos + 1
                  Case "\{", "\}", "\[", "\]", "\(", "\)", "\_","\\", "\|", "\/"
                    Row$ = RemoveString(Row$, "\", #PB_String_CaseSensitive, Pos, 1)
                    Pos + 1
                EndSelect
                ;}
              Case "`"
                ;{ ___ Code spans ___                   [6.3] 
                If Mid(Row$, Pos, 2) = "``"  ;{ " ``code`` "
                  
                  ePos = FindString(Row$, "``", Pos + 2)
                  If ePos
                    
                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    
                    If AddElement(MarkDown()\Row()\Item())
                      MarkDown()\Row()\Item()\Type = #Code
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 2, ePos - Pos - 2)
                      If Left(MarkDown()\Row()\Item()\String, 1) = " " : MarkDown()\Row()\Item()\String = Mid(MarkDown()\Row()\Item()\String, 2) : EndIf ; Remove 1 leading space
                    EndIf
                    
                    ePos + 1
                  EndIf
                  
                  If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                  ;}
                Else                         ;{ " `code` "
                  
                  ePos = FindString(Row$, "`",  Pos + 1)
                  If ePos

                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    
                    If AddElement(MarkDown()\Row()\Item())
                      MarkDown()\Row()\Item()\Type = #Code
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1)
                      If Left(MarkDown()\Row()\Item()\String, 1) = " " : MarkDown()\Row()\Item()\String = Mid(MarkDown()\Row()\Item()\String, 2) : EndIf ; Remove 1 leading space
                    EndIf
                    
                  EndIf
                  
                  If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                  ;}
                EndIf
                ;}
              Case "*", "_"
                ;{ ___ Emphasis and strong emphasis ___ [6.4]
                String$ = Mid(Row$, Pos)
                Start$  = GetChars_(String$, Mid(Row$, Pos, 1))

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
                        
                        ePos = FindString(Row$, Start$, Pos + 3)
                        If ePos
                          FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                          If AddElement(MarkDown()\Row()\Item())
                            MarkDown()\Row()\Item()\Type   = #Bold|#Italic
                            MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 3, ePos - Pos - 3)
                            ePos + 2
                          EndIf
                        EndIf
                        ;}
                      Case "**", "__"   ;{ #Bold
                        
                        ePos = FindString(Row$, Start$, Pos + 2)
                        If ePos
                          FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                          If AddElement(MarkDown()\Row()\Item())
                            MarkDown()\Row()\Item()\Type   = #Bold
                            MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 2, ePos - Pos - 2)
                            ePos + 1
                          EndIf
                        EndIf
                        ;}
                      Case "*", "_"     ;{ #Italic
                        
                        ePos = FindString(Row$, Start$, Pos + 1)
                        If ePos
                          FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                          If AddElement(MarkDown()\Row()\Item())
                            MarkDown()\Row()\Item()\Type   = #Italic
                            MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1)
                          EndIf
                        EndIf
                        ;}
                    EndSelect 
                    
                    If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                  EndIf
                
                EndIf
                ;}
              Case "!"
                ;{ ___ Images ___                       [6.6]
                If Mid(Row$, Pos, 2) = "!["
                  
                  FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                  
                  ePos = FindString(Row$, "][", Pos + 1)
                  If ePos
                    ;{ Reference link
                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    
                    If AddElement(MarkDown()\Row()\Item())
                      
                      MarkDown()\Row()\Item()\Type   = #Image
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 2, ePos - Pos - 2)
                      
                      nPos = ePos + 2
                      If AddElement(MarkDown()\Image())
                       
                        MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Image())
                        
                        ePos = FindString(Row$, "]", nPos)
                        If ePos
                          MarkDown()\Image()\Label = Mid(Row$, Pos + 1, ePos - Pos - 1)
                        EndIf
                        
                      EndIf  
                     
                    EndIf
                    ;}
                  Else
                    ;{ Inline link
                    ePos = FindString(Row$, "](", Pos + 1)
                    If ePos
                      
                      FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                      
                      If AddElement(MarkDown()\Row()\Item())
                        
                        MarkDown()\Row()\Item()\Type   = #Image
                        MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 2, ePos - Pos - 2)
                       
                        nPos = ePos + 2
                        
                        ePos = FindString(Row$, ")", nPos)
                        If ePos
                          
                          If AddElement(MarkDown()\Image())
                            
                            MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Image())
                            
                            ;{ Source
                            String$ = Trim(Mid(Row$, nPos, ePos - nPos))
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
  
                    EndIf
                    If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                    ;}
                  EndIf
                  
                  If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                EndIf   
                ;}
              Case "["
                ;{ ___ Footnotes / Links
                If Mid(Row$, Pos, 2) = "[^"
                  ;{ ___ Footnote ___
                  ePos = FindString(Row$, "]", Pos + 1)
                  If ePos
                    
                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    
                    If AddElement(MarkDown()\Row()\Item())
                      
                      MarkDown()\Row()\Item()\Type   = #FootNote
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 2, ePos - Pos - 2)
                      
                      If AddElement(MarkDown()\Footnote())
                        MarkDown()\Footnote()\Label   = MarkDown()\Row()\Item()\String
                        MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Footnote())
                      EndIf
                      
                    EndIf
                    
                  EndIf 
                
                  If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf  
                  ;}
                Else  
                  ;{ ___ Links  ___                     [6.5]
                  ePos = FindString(Row$, "][", Pos + 1)
                  If ePos
                    ;{ Reference link
                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    
                    If AddElement(MarkDown()\Row()\Item())
                      
                      MarkDown()\Row()\Item()\Type   = #Link
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1)
                      
                      nPos = ePos + 2
                      If AddElement(MarkDown()\Link())
                       
                        MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Link())
                        
                        ePos = FindString(Row$, "]", nPos)
                        If ePos
                          MarkDown()\Link()\Label = Mid(Row$, Pos + 1, ePos - Pos - 1)
                        EndIf
                        
                      EndIf  
                    
                    EndIf
                    If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                    ;}
                  Else
                    ;{ Inline link
                    ePos = FindString(Row$, "](", Pos + 1)
                    If ePos
                      
                      FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                      
                      If AddElement(MarkDown()\Row()\Item())
                        
                        MarkDown()\Row()\Item()\Type   = #Link
                        MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1)
                        
                        nPos = ePos + 2
                        
                        ePos = FindString(Row$, ")", nPos)
                        If ePos
                          
                          If AddElement(MarkDown()\Link())
                            
                            MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Link())
                            
                            ;{ Destination
                            String$ = Trim(Mid(Row$, nPos, ePos - nPos))
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
                                MarkDown()\Link()\Title = Mid(String$, 2, nPos - 1)
                              EndIf 
                            EndIf ;}
                            
                          EndIf
                          
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
                ePos = FindString(Row$, ">", Pos + 1)
                If ePos
                
                  FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                  
                  If AddElement(MarkDown()\Row()\Item())
                    
                    MarkDown()\Row()\Item()\Type   = #AutoLink
                    MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1) 
                    
                    If AddElement(MarkDown()\Link())
                      MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Link())
                      MarkDown()\Link()\URL = MarkDown()\Row()\Item()\String
                    EndIf
                    
                  EndIf
                    
                  If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                EndIf  
                ;}
              Case "~" 
                ;{ ___ Strikethrough / Subscript ___
                If Mid(Row$, Pos, 2) = "~~" ;{ Strikethrough
                  ePos = FindString(Row$, "~~", Pos + 1)
                  If ePos
                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    If AddElement(MarkDown()\Row()\Item())
                      MarkDown()\Row()\Item()\Type   = #StrikeThrough
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 2, ePos - Pos - 2)
                      ePos + 1
                    EndIf
                  EndIf ;}
                Else                        ;{ Subscript 
                  ePos = FindString(Row$, "~", Pos + 1)
                  If ePos
                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    If AddElement(MarkDown()\Row()\Item())
                      MarkDown()\Row()\Item()\Type   = #Subscript
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1)
                    EndIf
                  EndIf ;}
                EndIf 
                If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                ;}
              Case "^"
                ;{ ___ Superscript ___
                ePos = FindString(Row$, "^", Pos + 1)
                If ePos
                  FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                  If AddElement(MarkDown()\Row()\Item())
                    MarkDown()\Row()\Item()\Type   = #Superscript
                    MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1)
                  EndIf
                EndIf
                If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf 
                ;}
              Case "="
                ;{ ___ Highlight ___
                If Mid(Row$, Pos, 2) = "=="
                  ePos = FindString(Row$, "==", Pos + 2)
                  If ePos
                    FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                    If AddElement(MarkDown()\Row()\Item())
                      MarkDown()\Row()\Item()\Type   = #Highlight
                      MarkDown()\Row()\Item()\String = Mid(Row$, Pos + 2, ePos - Pos - 2)
                      ePos + 1
                    EndIf
                  EndIf
                EndIf
                If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf
                ;}
              Case ":"  
                ;{ ___ Emoji ___
                ePos = Emoji_(Row$, Pos)
                If ePos
                  
                  FirstItem = AddItemText_(sPos, Pos, Row$, FirstItem)
                  
                  If AddElement(MarkDown()\Row()\Item())
                    MarkDown()\Row()\Item()\Type   = #Emoji
                    MarkDown()\Row()\Item()\String = Mid(Row$, Pos, ePos - Pos + 1)
                  EndIf
                  
                EndIf
                If ePos : Pos  = ePos : sPos = Pos + 1 : EndIf
                ;}
            EndSelect
            
            Pos + 1
          Until Pos > Length  
          
          AddItemText_(sPos, Pos, Row$, FirstItem)
          ;}
      EndSelect
      
    Next ;}
    
    ;{ ===== Phase 3 =====
    ForEach MarkDown()\Row()
      Select MarkDown()\Row()\Type
        Case #List|#Ordered    ;{ Ordered List
          ForEach MarkDown()\Row()\Item()
            String$ = MarkDown()\Row()\Item()\String
            ParseInline_(String$)
          Next   
          ;}
        Case #List|#Unordered  ;{ Unordered List
          ForEach MarkDown()\Row()\Item()
            String$ = MarkDown()\Row()\Item()\String
            ParseInline_(String$)
          Next 
          ;}
        Case #List|#Definition ;{ Definition List
          ForEach MarkDown()\Row()\Item()
            String$ = MarkDown()\Row()\Item()\String
            ParseInline_(String$)
          Next 
          ;}
        Case #List|#Task       ;{ Task List
          ForEach MarkDown()\Row()\Item()
            String$ = MarkDown()\Row()\Item()\String
            ParseInline_(String$)
          Next 
          ;}
      EndSelect    
    Next  
    ;}
    
  EndProcedure  
  
  
	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
	
	Procedure   DashLine_(X.i, Y.i, Width.i, Color.i)
	  Define.i  i
	  
	  For i=1 To Width Step 2
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

  
  Procedure.i DrawText_(X.i, Y.i, Text.s, FrontColor.i, Indent.i=0, maxCol.i=0, Idx.i=#PB_Default, Flag.i=#False)
    Define.i w, PosX, txtWidth, txtHeight, Words, Rows, bqY, OffsetY, OffSetBQ, maxWidth, LastX, LastY
    Define.s Word$

    If MarkDown()\BlockQuote : OffSetBQ = dpiX(10) * MarkDown()\BlockQuote : EndIf 
    
    X + OffSetBQ
    Y + MarkDown()\WrapHeight
    
    txtHeight = TextHeight("Abc")
    OffsetY   = txtHeight / 2
    
    bqY = Y
    
    If maxCol
      maxWidth = maxCol - dpiX(5)
    Else
      maxWidth = MarkDown()\WrapPos
    EndIf

    If X + TextWidth(Text) > maxWidth
      
      Rows = 1
      
      If Flag = #Link          ;{ Move to next line
        PosX = MarkDown()\LeftBorder + Indent + OffSetBQ
        Y + TextHeight(Text)
        Rows + 1
        MarkDown()\WrapHeight + txtHeight
        
        If SelectElement(MarkDown()\Link(), Idx)
          MarkDown()\Link()\X      = PosX
          MarkDown()\Link()\Y      = Y
          MarkDown()\Link()\Width  = TextWidth(Text)
          MarkDown()\Link()\Height = txtHeight
          If MarkDown()\Link()\State : FrontColor = MarkDown()\Color\LinkHighlight : EndIf 
        EndIf

        DrawingMode(#PB_2DDrawing_Transparent)
        PosX = DrawText(PosX, Y, Text, FrontColor)
        ;}
      Else                     ;{ WordWrap
      
        PosX  = X

        Words = CountString(Text, " ") + 1
  
        For w = 1 To Words
          
          Word$ = StringField(Text, w, " ")
          
          If PosX + TextWidth(Word$) > maxWidth
            
            If maxCol
              PosX = X
            Else  
              PosX = MarkDown()\LeftBorder + Indent + OffSetBQ
            EndIf 
            
            Rows + 1
            Y + txtHeight
            
            MarkDown()\WrapHeight + txtHeight
          EndIf
          
          If w < Words : Word$ + " " : EndIf

          If Flag = #FootNote ;{ Footnote
            If SelectElement(MarkDown()\Footnote(), Idx)
              MarkDown()\Footnote()\X = PosX
              MarkDown()\Footnote()\Y = Y
              MarkDown()\Footnote()\Width  = TextWidth(Word$) 
              MarkDown()\Footnote()\Height = TextHeight(Word$)
            EndIf
          EndIf ;}
          
          LastX = PosX : LastY = Y
          
          If Flag = #Highlight
            DrawingMode(#PB_2DDrawing_Default)
            PosX = DrawText(PosX, Y, Word$, FrontColor, MarkDown()\Color\Highlight)
          Else 
            DrawingMode(#PB_2DDrawing_Transparent)
            PosX = DrawText(PosX, Y, Word$, FrontColor)
          EndIf
          
          If Flag = #StrikeThrough : Line(LastX, LastY + OffsetY, TextWidth(Word$), 1, FrontColor) : EndIf 
          
        Next
        ;}
      EndIf
      
      If MarkDown()\BlockQuote ;{ BlockQuote
        DrawingMode(#PB_2DDrawing_Default)
        Box(MarkDown()\LeftBorder, bqY, dpiX(5), txtHeight * Rows, MarkDown()\Color\BlockQuote)
        If MarkDown()\BlockQuote = 2
          Box(MarkDown()\LeftBorder + dpiX(10), bqY, dpiX(5), txtHeight * Rows, MarkDown()\Color\BlockQuote)
        EndIf ;}
      EndIf 
      
      ProcedureReturn PosX - OffSetBQ
    Else

      Select Flag
        Case #Link     ;{ Link
          If SelectElement(MarkDown()\Link(), Idx)
            MarkDown()\Link()\X      = X
            MarkDown()\Link()\Y      = Y
            MarkDown()\Link()\Width  = TextWidth(Text)
            MarkDown()\Link()\Height = TextHeight(Text)
            If MarkDown()\Link()\State : FrontColor = MarkDown()\Color\LinkHighlight : EndIf 
          EndIf ;}
        Case #FootNote ;{ Footnote
          If SelectElement(MarkDown()\Footnote(), Idx)
            MarkDown()\Footnote()\X = X
            MarkDown()\Footnote()\Y = Y
            MarkDown()\Footnote()\Width  = TextWidth(Text) 
            MarkDown()\Footnote()\Height = TextHeight(Text)
          EndIf 
          ;}
      EndSelect
      
      LastX = X : LastY = Y
      
      If Flag = #Highlight
        DrawingMode(#PB_2DDrawing_Default)
        X = DrawText(X, Y, Text, FrontColor, MarkDown()\Color\Highlight)
      Else 
        DrawingMode(#PB_2DDrawing_Transparent)
        X = DrawText(X, Y, Text, FrontColor)
      EndIf 
      
      If Flag = #StrikeThrough : Line(LastX, LastY + OffsetY, TextWidth(Text), 1, FrontColor) : EndIf 
      
      ; DashLine_(LastX, LastY + MarkDown()\Hint()\Height, MarkDown()\Hint()\Width, MarkDown()\Color\Hint)
      
      If MarkDown()\BlockQuote                ;{ BlockQuote
        DrawingMode(#PB_2DDrawing_Default)
        Box(MarkDown()\LeftBorder, bqY, dpiX(5), TextHeight(Text), MarkDown()\Color\BlockQuote)
        If MarkDown()\BlockQuote = 2
          Box(MarkDown()\LeftBorder + dpiX(10), bqY, dpiX(5), TextHeight(Text), MarkDown()\Color\BlockQuote)
        EndIf ;}
      EndIf  
     
      ProcedureReturn X - OffSetBQ
    EndIf  

    
  EndProcedure
  
  Procedure.i DrawInline_(X.i, Y.i, FrontColor)
    Define.i TextHeight, ImgSize, OffSetY, OffSetX, LinkColor
    
    If ListSize(MarkDown()\Row()\Item()\SubItem())
      
      ForEach MarkDown()\Row()\Item()\SubItem()
        
        Select MarkDown()\Row()\Item()\SubItem()\Type
          Case #Bold          ;{ Emphasis
            DrawingFont(FontID(MarkDown()\Font\Bold))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
          Case #Italic
            DrawingFont(FontID(MarkDown()\Font\Italic))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
          Case #Bold|#Italic 
            DrawingFont(FontID(MarkDown()\Font\BoldItalic))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
            ;}
          Case #Code          ;{ Code
            DrawingFont(FontID(MarkDown()\Font\Code))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
            ;}
          Case #Emoji         ;{ Emojis
            DrawingFont(FontID(MarkDown()\Font\Normal))
            TextHeight = TextHeight("Abc")
            If TextHeight <= dpiY(16)
              ImgSize = TextHeight - dpiY(1)
            Else
              ImgSize = dpiY(TextHeight)
            EndIf  
            OffSetY = (TextHeight - ImgSize) / 2
            If IsImage(Emoji(MarkDown()\Row()\Item()\SubItem()\String))
              DrawingMode(#PB_2DDrawing_AlphaBlend)
		          DrawImage(ImageID(Emoji(MarkDown()\Row()\Item()\SubItem()\String)), X, Y + OffSetY, ImgSize, ImgSize)
		          X + ImgSize
            EndIf
            ;}
          Case #FootNote      ;{ Footnote
            DrawingFont(FontID(MarkDown()\Font\FootNote))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor, 0, 0, MarkDown()\Row()\Item()\SubItem()\Index, #FootNote)
            ;}                
          Case #Image         ;{ Image
            
            If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Item()\SubItem()\Index)
        
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
			          
			          If MarkDown()\Row()\Item()\SubItem()\String
			            
			            Y + (TextHeight / 4)
			            
			            OffSetX = (MarkDown()\Image()\Width - TextWidth(MarkDown()\Row()\Item()\SubItem()\String)) / 2
			            
			            DrawingMode(#PB_2DDrawing_Transparent)
			            DrawText(X + OffSetX, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
			            
			            Y + TextHeight(MarkDown()\Row()\Item()\SubItem()\String)
			          EndIf
			          
			        ElseIf MarkDown()\Row()\Item()\SubItem()\String
			          
			          OffSetX = (MarkDown()\Image()\Width - TextWidth(MarkDown()\Row()\Item()\SubItem()\String)) / 2
			          
		            DrawingMode(#PB_2DDrawing_Transparent)
		            DrawText(X + OffSetX, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
		            
		            Y + TextHeight(MarkDown()\Row()\Item()\SubItem()\String)
		            
			        EndIf 
			        
			        If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
			        
			      EndIf
			      
            ;}
          Case #Link          ;{ Link
            DrawingFont(FontID(MarkDown()\Font\Normal))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, LinkColor, #False, 0, MarkDown()\Row()\Item()\SubItem()\Index, #Link)  
            ;}
          Case #Highlight     ;{ Highlight
            DrawingFont(FontID(MarkDown()\Font\Normal))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor, 0, 0, #PB_Default, #Highlight)
            ;}
          Case #StrikeThrough ;{ StrikeThrough  
            DrawingFont(FontID(MarkDown()\Font\Normal))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor, 0, 0, #PB_Default, #StrikeThrough)
            ;}
          Case #Subscript     ;{ SubScript
            DrawingFont(FontID(MarkDown()\Font\Normal))
            TextHeight = TextHeight("Abc")
            DrawingFont(FontID(MarkDown()\Font\FootNote))
            OffSetY = TextHeight - TextHeight(MarkDown()\Row()\Item()\SubItem()\String) + dpiY(2)
            X = DrawText_(X, Y + OffSetY, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
            ;}
          Case #Superscript   ;{ SuperScript
            DrawingFont(FontID(MarkDown()\Font\FootNote))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
            ;}
          Case #AutoLink      ;{ URL / EMail
            DrawingFont(FontID(MarkDown()\Font\Normal))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, LinkColor, #False, 0, MarkDown()\Row()\Item()\SubItem()\Index, #Link)
            ;}  
          Default             ;{ Text
            DrawingFont(FontID(MarkDown()\Font\Normal))
            X = DrawText_(X, Y, MarkDown()\Row()\Item()\SubItem()\String, FrontColor)
            ;}
        EndSelect
        
      Next

    EndIf
    
		ProcedureReturn X
  EndProcedure
  
	Procedure   Draw_()
	  Define.i X, Y, Width, Height, LeftBorder, WrapPos, TextHeight, Cols
	  Define.i Indent, Level, Offset, OffSetX, OffSetY, maxCol, ImgSize
	  Define.i c, OffsetList, NumWidth, ColWidth, TableWidth
		Define.i FrontColor, BackColor, BorderColor, LinkColor
		Define.s Text$, Num$, ColText$
		
		NewMap ListNum.i()
		
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
			MarkDown()\Scroll\Height = TextHeight("Abc")
		  
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

			ForEach MarkDown()\Row()
	
			  DrawingFont(FontID(MarkDown()\Font\Normal))
			  TextHeight = TextHeight("Abc")
			  
			  X = MarkDown()\LeftBorder
			  
			  MarkDown()\BlockQuote = MarkDown()\Row()\BlockQuote
			  MarkDown()\WrapHeight = 0
			  
			  Select MarkDown()\Row()\Type
			    Case #Heading          ;{ Heading  

			      DrawingMode(#PB_2DDrawing_Transparent)
			      Select MarkDown()\Row()\Level
			        Case 1
			          DrawingFont(FontID(MarkDown()\Font\H1))
			        Case 2
			          DrawingFont(FontID(MarkDown()\Font\H2))
			        Case 3
			          DrawingFont(FontID(MarkDown()\Font\H3))
			        Case 4
			          DrawingFont(FontID(MarkDown()\Font\H4))
			        Case 5
			          DrawingFont(FontID(MarkDown()\Font\H5))
			        Case 6
			          DrawingFont(FontID(MarkDown()\Font\H6))
			      EndSelect
			      
			      DrawText_(X, Y, MarkDown()\Row()\String, FrontColor)
			      
			      If TextWidth(MarkDown()\Row()\String) > MarkDown()\Required\Width : MarkDown()\Required\Width = TextWidth(MarkDown()\Row()\String) : EndIf 
			      
			      Y + TextHeight(MarkDown()\Row()\String) + MarkDown()\WrapHeight + (TextHeight / 3)
            ;}
			    Case #List|#Ordered    ;{ Ordered List  
			      
			      ClearMap(ListNum())
			      
			      DrawingMode(#PB_2DDrawing_Transparent)

			      NumWidth   = Len(Str(ListSize(MarkDown()\Row()\Item()))) * TextWidth("0")
			      
			      Y + (TextHeight / 2)
			      
			      ForEach MarkDown()\Row()\Item()
			        
			        Offset = 0
			        X      = MarkDown()\LeftBorder
			        Level  = MarkDown()\Row()\Item()\Level
			        Indent = (NumWidth + TextWidth(". ")) * (Level)
			        
			        If Level
			          If MarkDown()\Row()\Item()\Type = #List
			            Num$ = "- "
			          Else  
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level-1))) + "." + Str(ListNum(Str(Level))) + ". "
			          EndIf 
			        Else
			          If MarkDown()\Row()\Item()\Type = #List
			            Num$ = #Bullet$
			            Offset = NumWidth - TextWidth(Num$) + TextWidth(".")
			            Num$ + "  "
			          Else
  			          ListNum(Str(Level)) + 1
  			          Num$ = Str(ListNum(Str(Level)))
  			          Offset = NumWidth - TextWidth(Num$)
  			          Num$ + ". "
  			        EndIf  
			        EndIf

			        X = DrawText_(X + Offset + MarkDown()\Indent + Indent, Y, Num$ + MarkDown()\Row()\Item()\String, FrontColor, Offset + MarkDown()\Indent + Indent + TextWidth(Num$))
			        X = DrawInline_(X, Y, FrontColor)

			        Y + TextHeight
			      Next
			      
			      Y + MarkDown()\WrapHeight + (TextHeight / 2)
			      ;}
			    Case #List|#Unordered  ;{ Unordered List
			      
			      ClearMap(ListNum())
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      NumWidth   = TextWidth("0")

			      Y + (TextHeight / 2)
			      
			      ForEach MarkDown()\Row()\Item()
			        
			        X      = MarkDown()\LeftBorder
			        Level  = MarkDown()\Row()\Item()\Level
			        Indent = TextWidth(#Bullet$ + " ") * MarkDown()\Row()\Item()\Level
			        
			        If Level
			          If MarkDown()\Row()\Item()\Type = #List|#Ordered
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level))) + ". "
			          Else  
			            Num$ = "- "
			          EndIf
			        Else
			          If MarkDown()\Row()\Item()\Type = #List|#Ordered
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level))) + ". "
			          Else  
			            Num$ = #Bullet$ + " "
			          EndIf 
			        EndIf  
			        
			        DrawingMode(#PB_2DDrawing_Transparent)
			        X = DrawText_(X + MarkDown()\Indent + Indent, Y, Num$ + MarkDown()\Row()\Item()\String, FrontColor, MarkDown()\Indent + Indent + TextWidth(Num$))
			        X = DrawInline_(X, Y, FrontColor)
			        
			        Y + TextHeight
			      Next
			      
			      Y + MarkDown()\WrapHeight + (TextHeight / 2)
			      ;}
			    Case #List|#Task       ;{ Task List 
			      
			      Y + (TextHeight / 2)
			      
			      NumWidth = TextHeight + TextWidth(" ")

			      ForEach MarkDown()\Row()\Item()
			        
			        X = MarkDown()\LeftBorder
			        
			        CheckBox_(X + MarkDown()\Indent, Y + dpiY(1), TextHeight - dpiY(2), FrontColor, BackColor, MarkDown()\Row()\Item()\State)
			      
			        DrawingMode(#PB_2DDrawing_Transparent)
			        X = DrawText_(X + MarkDown()\Indent + TextHeight, Y, MarkDown()\Row()\Item()\String, FrontColor, MarkDown()\Indent + NumWidth)
			        X = DrawInline_(X, Y, FrontColor)
			        
			        Y + TextHeight + dpiY(2)
			      Next
			      
			      Y + (TextHeight / 2)
			      ;}
			    Case #List|#Definition ;{ Definition List
			      
			      
			      DrawingMode(#PB_2DDrawing_Transparent)  
			      
			      DrawingFont(FontID(MarkDown()\Font\Bold))
			      DrawText_(X, Y, MarkDown()\Row()\String, FrontColor)
			      
			      Y + (TextHeight * 1.1)
			      
			      DrawingFont(FontID(MarkDown()\Font\Normal))
			      ForEach MarkDown()\Row()\Item()
			        
			        X = MarkDown()\LeftBorder
			        
			        X = DrawText_(X + MarkDown()\Indent, Y, MarkDown()\Row()\Item()\String, FrontColor, MarkDown()\Indent)
			        X = DrawInline_(X, Y, FrontColor)
			        
			        Y + (TextHeight * 1.1)
			      Next
			      
			      Y + MarkDown()\WrapHeight
			      ;}
			    Case #HLine            ;{ Horizontal Rule  

			      OffSetY = TextHeight / 2

			      DrawingMode(#PB_2DDrawing_Default)
			      Box(X, Y + OffSetY, Width, 2, MarkDown()\Color\Line)
			      
			      Y + TextHeight
			      ;}
			    Case #Paragraph        ;{ Paragraph  
			      Y + (TextHeight / 2)
			      ;}
			    Case #Table            ;{ Table
	
			      DrawingFont(FontID(MarkDown()\Font\Normal))
			      TextHeight = TextHeight("Abc")
			      
			      X = MarkDown()\LeftBorder + dpiX(20)
			      Y + (TextHeight / 2)
			      
			      TableWidth = Width - dpiX(40)
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      ForEach MarkDown()\Row()\Item()
			        
			        Text$ = MarkDown()\Row()\Item()\String
			        
			        Cols     = CountString(Text$, "|") + 1
			        ColWidth = TableWidth / Cols

			        If MarkDown()\Row()\Item()\Type = #Table|#Header
			          DrawingFont(FontID(MarkDown()\Font\Bold))
			        Else
			          DrawingFont(FontID(MarkDown()\Font\Normal))
			        EndIf  
			        
			        For c=0 To Cols - 1
			          
			          ColText$ = Trim(StringField(Text$, c+1, "|"))

			          Select StringField(MarkDown()\Row()\String, c+1, "|")
			            Case "C"
			              OffSetX = (ColWidth - dpiX(5) - TextWidth(ColText$)) / 2
			            Case "R"  
			              OffSetX = ColWidth - dpiX(5)  - TextWidth(ColText$) 
			            Default
			              OffSetX = 0
			          EndSelect
			          
			          maxCol = ColWidth * (c + 1)
		            DrawText_(X + (ColWidth * c) + OffSetX, Y, ColText$, FrontColor, 0, maxCol + OffSetX)
		          Next 
		          
		          Y + TextHeight + MarkDown()\WrapHeight
		          
		          If MarkDown()\Row()\Item()\Type = #Table|#Header
  		          OffSetY = TextHeight / 2
  		          Line(X, Y + OffSetY, TableWidth, 1, FrontColor)
  		          Y + TextHeight 
			        EndIf  
			        
			      Next
			      
			      Y + (TextHeight / 2)
			      ;}
			    Case #Code             ;{ Code Block
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      Y + (TextHeight / 2)
			      
			      DrawingFont(FontID(MarkDown()\Font\Code))
			      TextHeight = TextHeight("Abc")
			      
			      ForEach MarkDown()\Row()\Item()
              DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
			        Y + TextHeight
			      Next
			      
			      Y + MarkDown()\WrapHeight + (TextHeight / 2)
			      ;}
			    Default                ;{ Text
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      DrawingFont(FontID(MarkDown()\Font\Normal))
			      
			      TextHeight = TextHeight("Abc")
            
			      If MarkDown()\Row()\String
			        X = DrawText_(X, Y, MarkDown()\Row()\String, FrontColor)
  			    EndIf
			    
			      ForEach MarkDown()\Row()\Item()
			        
			        Select MarkDown()\Row()\Item()\Type
                Case #Bold          ;{ Emphasis
                  DrawingFont(FontID(MarkDown()\Font\Bold))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
                Case #Italic
                  DrawingFont(FontID(MarkDown()\Font\Italic))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
                Case #Bold|#Italic 
                  DrawingFont(FontID(MarkDown()\Font\BoldItalic))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
                  ;}
                Case #Code          ;{ Code
                  DrawingFont(FontID(MarkDown()\Font\Code))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
                  ;}
                Case #Emoji         ;{ Emojis
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  TextHeight = TextHeight("Abc")
                  If TextHeight <= dpiY(16)
                    ImgSize = TextHeight - dpiY(1)
                  Else
                    ImgSize = dpiY(TextHeight)
                  EndIf  
                  OffSetY = (TextHeight - ImgSize) / 2
                  If IsImage(Emoji(MarkDown()\Row()\Item()\String))
                    DrawingMode(#PB_2DDrawing_AlphaBlend)
    			          DrawImage(ImageID(Emoji(MarkDown()\Row()\Item()\String)), X, Y + OffSetY, ImgSize, ImgSize)
    			          X + ImgSize
                  EndIf
                  ;}
                Case #FootNote      ;{ Footnote
                  DrawingFont(FontID(MarkDown()\Font\FootNote))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor, 0, 0, MarkDown()\Row()\Item()\Index, #FootNote)
                  ;}                
                Case #Image         ;{ Image
                  
                  If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Item()\Index)
			        
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
      			          
      			          If MarkDown()\Row()\Item()\String
      			            
      			            Y + (TextHeight / 4)
      			            
      			            OffSetX = (MarkDown()\Image()\Width - TextWidth(MarkDown()\Row()\Item()\String)) / 2
      			            
      			            DrawingMode(#PB_2DDrawing_Transparent)
      			            DrawText(X + OffSetX, Y, MarkDown()\Row()\Item()\String, FrontColor)
      			            
      			            Y + TextHeight(MarkDown()\Row()\Item()\String)
      			          EndIf
      			          
      			        ElseIf MarkDown()\Row()\Item()\String
      			          
      			          OffSetX = (MarkDown()\Image()\Width - TextWidth(MarkDown()\Row()\Item()\String)) / 2
      			          
      		            DrawingMode(#PB_2DDrawing_Transparent)
      		            DrawText(X + OffSetX, Y, MarkDown()\Row()\Item()\String, FrontColor)
      		            
      		            Y + TextHeight(MarkDown()\Row()\Item()\String)
      		            
      			        EndIf 
      			        
      			        If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
      			        
      			      EndIf
      			      
                  ;}
                Case #Link          ;{ Link
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, LinkColor, #False, 0, MarkDown()\Row()\Item()\Index, #Link)  
                  ;}
                Case #Highlight     ;{ Highlight
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor, 0, 0, #PB_Default, #Highlight)
                  ;}
                Case #StrikeThrough ;{ StrikeThrough  
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor, 0, 0, #PB_Default, #StrikeThrough)
                  ;}
                Case #Subscript     ;{ SubScript
                  DrawingFont(FontID(MarkDown()\Font\Normal))
			            TextHeight = TextHeight("Abc")
                  DrawingFont(FontID(MarkDown()\Font\FootNote))
                  OffSetY = TextHeight - TextHeight(MarkDown()\Row()\Item()\String) + dpiY(2)
                  X = DrawText_(X, Y + OffSetY, MarkDown()\Row()\Item()\String, FrontColor)
                  ;}
                Case #Superscript   ;{ SuperScript
                  DrawingFont(FontID(MarkDown()\Font\FootNote))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
                  ;}
                Case #AutoLink      ;{ URL / EMail
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, LinkColor, #False, 0, MarkDown()\Row()\Item()\Index, #Link)
                  ;}  
                Default             ;{ Text
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
                  ;}
              EndSelect

            Next 
            
            Y + TextHeight + MarkDown()\WrapHeight
			      ;}
			  EndSelect

			Next  
			
			If ListSize(MarkDown()\Footnote()) ;{ Footnotes
			  
			  X = MarkDown()\LeftBorder
			  MarkDown()\WrapHeight = 0

			  DrawingFont(FontID(MarkDown()\Font\Normal))
			  TextHeight = TextHeight("Abc")
			  Y + (TextHeight / 2)
			  
			  DrawingFont(FontID(MarkDown()\Font\FootNoteText))
			  TextHeight = TextHeight("Abc")
			  
			  OffSetY = TextHeight / 2
			  Line(X, Y + OffSetY, Width / 3, 1, MarkDown()\Color\Line)

			  Y + TextHeight
			  
			  ForEach MarkDown()\Footnote()
			    
          DrawingFont(FontID(MarkDown()\Font\FootNote))
          X = DrawText_(MarkDown()\LeftBorder, Y, MarkDown()\FootNote()\Label + " ", FrontColor)
          Indent = TextWidth(MarkDown()\FootNote()\Label + "  ")
          
          DrawingFont(FontID(MarkDown()\Font\FootNoteText))
          DrawText_(X, Y, MarkDown()\FootLabel(MarkDown()\Footnote()\Label), FrontColor, Indent)
          
			    Y + TextHeight
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
			        GadgetToolTip(GNum, MarkDown()\FootLabel(MarkDown()\Footnote()\Label))
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
	    
	    ParseMD_(MarkDown)
	    
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
				
				MarkDown()\Indent = 10
				
				MarkDown()\Flags  = Flags

				MarkDown()\Color\Back          = $FFFFFF
				MarkDown()\Color\BlockQuote    = $C0C0C0
				MarkDown()\Color\Border        = $E3E3E3
				MarkDown()\Color\DisableFront  = $72727D
				MarkDown()\Color\DisableBack   = $CCCCCA
				MarkDown()\Color\Front         = $000000
				MarkDown()\Color\Gadget        = $F0F0F0
				MarkDown()\Color\Highlight     = $E3F8FC
				MarkDown()\Color\Hint          = $578B2E
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
        Case #TopMargin
          MarkDown()\Margin\Top    = Value
        Case #LeftMargin
          MarkDown()\Margin\Left   = Value
        Case #RightMargin
          MarkDown()\Margin\Right  = Value
        Case #BottomMargin
          MarkDown()\Margin\Bottom = Value
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
        Case #BackColor
          MarkDown()\Color\Back          = Value
        Case #BlockQuoteColor 
          MarkDown()\Color\BlockQuote    = Value   
        Case #BorderColor
          MarkDown()\Color\Border        = Value
        Case #FrontColor
          MarkDown()\Color\Front         = Value  
        Case #HighlightColor
          MarkDown()\Color\Highlight     = Value    
        Case #HintColor
          MarkDown()\Color\Hint          = Value 
        Case #LineColor
          MarkDown()\Color\Line          = Value  
        Case #LinkColor
          MarkDown()\Color\Link          = Value  
        Case #LinkHighlightColor
          MarkDown()\Color\LinkHighlight = Value    
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
	    
	    ParseMD_(Text)

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
      Text$ + "This ==word== is highlighted.  "+ #LF$
      Text$ + "-----------------------------------------" + #LF$
      Text$ + "#### Code ####" + #LF$
      Text$ + "At the command prompt, type ``nano``."+ #LF$
    Case 3
      Text$ = "#### Ordered List ####"  + #LF$
      Text$ + "1. First list item"+#LF$+"   2. Second list item"+#LF$+"   3. Third list item"+#LF$+"4. Fourth list item"+ #LF$
      Text$ + "-----" + #LF$
      Text$ + "#### Unordered List ####"  + #LF$
      Text$ + "- First list item" + #LF$ + "  - Second list item:" + #LF$ + "  - Third list item" + #LF$ + "- Fourth list item" + #LF$ 
    Case 4
      Text$ = "#### Links & URLs ####" + #LF$ 
      Text$ + "URL: <https://www.markdownguide.org>  "+ #LF$
      Text$ + "EMail: <fake@example.com>  "+ #LF$
      Text$ + "Link:  [Duck Duck Go](https://duckduckgo.com "+#DQUOTE$+"My search engine!"+#DQUOTE$+")  "+ #LF$
    Case 5
      Text$ = "#### Image ####"  + #LF$
      Text$ + " ![Programmer](Test.png " + #DQUOTE$ + "Programmer Image" + #DQUOTE$ + ")"
    Case 6
      Text$ = "#### Table ####"  + #LF$
      Text$ + "| Syntax    | Description |" + #LF$
      Text$ + "| :-------- | ----------: |" + #LF$
      Text$ + "| Header    | Title       |" + #LF$ 
      Text$ + "| Paragraph | Text        |" + #LF$ 
    Case 7
      Text$ = "#### Footnotes ####" + #LF$ + #LF$
      Text$ + "Here's a simple footnote,[^1] and here's a longer one.[^bignote]" + #LF$
      Text$ + "[^1]: This is the first footnote." + #LF$
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
      Text$ + ": This is one definition of the second term." + #LF$
      Text$ + ": This is another definition of the second term." + #LF$
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
      Text$ + "The [HTML] specification is maintained by the [>W3C]." + #LF$
      Text$ + "[HTML]: Hypertext Markup Language" + #LF$
      Text$ + "[W3C]:  World Wide Web Consortium" + #LF$
    Default  
      Text$ = "### MarkDown ###" + #LF$ + #LF$
      Text$ + "> The gadget can display text formatted with the [MarkDown Syntax](https://www.markdownguide.org/basic-syntax/).  "+ #LF$
      Text$ + "> Markdown[^1] is a lightweight MarkUp language that you can use to add formatting elements to plaintext text documents."+ #LF$
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
; CursorPosition = 4967
; FirstLine = 413
; Folding = 5RCAAAAAAAQAABAAAAAAAc9ICAAAAEAAAAAAAAEQAAAAAAASQgRy
; Markers = 2785
; EnableXP
; DPIAware