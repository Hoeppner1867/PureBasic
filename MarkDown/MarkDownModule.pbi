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

; Last Update: 01.01.2020
;
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
; MarkDown::SetText()            - similar to 'SetGadgetText()'

;}

;{ _____ Emoji _____

; :laugh: / :smile: / :sad: / :angry: / :cool: / :smirk: / :worry: / :wink: / :rolf: / :eyes:

;}

; XIncludeFile "ModuleEx.pbi"

CompilerIf Not Defined(PDF, #PB_Module) : XIncludeFile "pbPDFModule.pbi" : CompilerEndIf

DeclareModule MarkDown
  
  #Version  = 20010101
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
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
		#LinkColor
		#LinkHighlightColor
		#BlockQuoteColor
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
  Declare   SetText(GNum.i, Text.s)
  
EndDeclareModule

Module MarkDown

	EnableExplicit
	
	UsePNGImageDecoder()
	UseJPEGImageDecoder()

	UseZipPacker()
	
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
	
  Enumeration 1 ;{ MarkDown
    #Bold
    #BoldItalic
    #Code
    #Emoji
    #FootNote
    #Header
    #Heading
    #HLine
    #Image
    #Italic
    #LineBreak
    #Link
    #List
    #OrderedList
    #Paragraph
    #StrikeThrough
    #Subscript
    #Superscript
    #Table
    #TaskList
    #Text
    #URL
  EndEnumeration ;}

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================	
	
  Structure Footnote_Structure         ;{ MarkDown()\Footnote()\...
    Note.s
    String.s
  EndStructure ;}

  Structure Image_Structure            ;{ MarkDown()\Image()\...
    Num.i
    Width.i
    Height.i
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
    State.i
  EndStructure ;}
  
  Structure Item_Structure               ;{ MarkDown()\Row()\Item()\...
    Type.i
    String.s
    Level.i
    State.i
    Index.i
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
		Link.i
		LinkHighlight.i
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
		
		EventValue.s
		
		Flags.i

		Color.MarkDown_Color_Structure
		Font.MarkDown_Font_Structure
		Margin.MarkDown_Margin_Structure
		Required.MarkDown_Required_Structure
		Size.MarkDown_Size_Structure
		Scroll.MarkDown_Scroll_Structure
		Window.MarkDown_Window_Structure

    Map  FootIdx.i()
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
	  Define *Buffer

	  *Buffer = AllocateMemory(457)
	  If *Buffer
      UncompressMemory(?Laugh, 375, *Buffer, 457)
      Emoji(":laugh:") = CatchImage(#PB_Any, *Buffer, 457)
      FreeMemory(*Buffer)
    EndIf
    
    *Buffer = AllocateMemory(447)
	  If *Buffer
      UncompressMemory(?Smile, 362, *Buffer, 447)
      Emoji(":smile:") = CatchImage(#PB_Any, *Buffer, 447)
      FreeMemory(*Buffer)
    EndIf
    
    *Buffer = AllocateMemory(446)
	  If *Buffer
      UncompressMemory(?Sad, 360, *Buffer, 446)
      Emoji(":sad:") = CatchImage(#PB_Any, *Buffer, 446)
      FreeMemory(*Buffer)
    EndIf    
 
    *Buffer = AllocateMemory(448)
	  If *Buffer
      UncompressMemory(?Angry, 364, *Buffer, 448)
      Emoji(":angry:") = CatchImage(#PB_Any, *Buffer, 448)
      FreeMemory(*Buffer)
    EndIf
    
    *Buffer = AllocateMemory(457)
	  If *Buffer
      UncompressMemory(?Cool, 375, *Buffer, 457)
      Emoji(":cool:") = CatchImage(#PB_Any, *Buffer, 457)
      FreeMemory(*Buffer)
    EndIf
    
    *Buffer = AllocateMemory(452)
	  If *Buffer
      UncompressMemory(?Smirk, 371, *Buffer, 452)
      Emoji(":smirk:") = CatchImage(#PB_Any, *Buffer, 452)
      FreeMemory(*Buffer)
    EndIf    
    
    *Buffer = AllocateMemory(448)
	  If *Buffer
      UncompressMemory(?Eyes, 366, *Buffer, 448)
      Emoji(":eyes:") = CatchImage(#PB_Any, *Buffer, 448)
      FreeMemory(*Buffer)
    EndIf   
    
    *Buffer = AllocateMemory(457)
	  If *Buffer
      UncompressMemory(?rofl, 370, *Buffer, 457)
      Emoji(":rolf:") = CatchImage(#PB_Any, *Buffer, 457)
      FreeMemory(*Buffer)
    EndIf  
    
    *Buffer = AllocateMemory(456)
	  If *Buffer
      UncompressMemory(?Wink, 374, *Buffer, 456)
      Emoji(":wink:") = CatchImage(#PB_Any, *Buffer, 456)
      FreeMemory(*Buffer)
    EndIf  
    
    *Buffer = AllocateMemory(452)
	  If *Buffer
      UncompressMemory(?Worry, 364, *Buffer, 452)
      Emoji(":worry:") = CatchImage(#PB_Any, *Buffer, 452)
      FreeMemory(*Buffer)
    EndIf  
    
	EndProcedure
	
	
	Procedure.i AdjustScrollBars_()
	  Define.i Height
	  
	  If IsGadget(MarkDown()\Scroll\Num)
	    
	    Height = GadgetHeight(MarkDown()\CanvasNum) 
	    
	    If MarkDown()\Required\Height > Height
	      
	      If MarkDown()\Scroll\Hide
	        Debug "Height: " + Str(Height) + " < " + Str(MarkDown()\Required\Height)
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
	  
	  ClearMap(MarkDown()\FootIdx())
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
    Define.i Level, c, ColWidth, Cols, tBody, Class, BlockQuote
    Define.s HTML$, endTag$, Align$, Indent$
    
    HTML$ = "<!DOCTYPE html>" + #LF$ + "<html>" + #LF$ + "<head>" + #LF$ + "<title>" + Title + "</title>" + #LF$ + "</head>" + #LF$ + "<body>" + #LF$
    
    ForEach MarkDown()\Row()
      
      Select MarkDown()\Row()\BlockQuote
        Case 1, 2
          If Not BlockQuote
            HTML$ + "<blockquote>" + #LF$
            BlockQuote = #True
          EndIf  
        Case 0
          If BlockQuote
            HTML$ + "</blockquote>" + #LF$
            BlockQuote = #False
          EndIf
      EndSelect
      
      Select MarkDown()\Row()\Type
        Case #Heading     ;{ Heading
          HTML$ + "<h"+Str(MarkDown()\Row()\Level)+">" + EscapeHTML_(MarkDown()\Row()\String) + "</h"+Str(MarkDown()\Row()\Level)+">" + #LF$
          ;}
        Case #OrderedList ;{ Ordered List
          
          Level = 0
          
          HTML$ + "<ol>" + #LF$
          
          ForEach MarkDown()\Row()\Item()
            
            Indent$ = ""
            
            If MarkDown()\Row()\Item()\Level = 1 : Indent$ = Space(4) : EndIf 
            
            If Level = 0 And MarkDown()\Row()\Item()\Level = 1
              If MarkDown()\Row()\Item()\Type = #List
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
            If MarkDown()\Row()\Item()\Type = #List
              HTML$ + Indent$ + "</ul>" + #LF$
            Else
              HTML$ + Indent$ + "</ol>" + #LF$
            EndIf    
          EndIf 
          
          HTML$ + "</ol>" + #LF$
          ;}
        Case #List        ;{ Unordered List
          
          Level = 0
          
          HTML$ + "<ul>" + #LF$
          
          ForEach MarkDown()\Row()\Item()
            
            Indent$ = ""
            If MarkDown()\Row()\Item()\Level = 1 : Indent$ = "    " : EndIf 
            
            If Level = 0 And MarkDown()\Row()\Item()\Level = 1
              If MarkDown()\Row()\Item()\Type = #OrderedList
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
            If MarkDown()\Row()\Item()\Type = #OrderedList
              HTML$ + Space(2) + "</ol>" + #LF$
            Else
              HTML$ + Space(2) + "</ul>" + #LF$
            EndIf    
          EndIf 
          
          HTML$ + "</ul>" + #LF$
          ;}
        Case #HLine       ;{ Horizontal Rule
          HTML$ + "<hr />" + #LF$
          ;}
        Case #Paragraph   ;{ Paragraph
          HTML$ + "<br>" + #LF$
          ;}
        Case #Image       ;{ Image
          
          If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Index)
            HTML$ + "<img src="+#DQUOTE$+MarkDown()\Image()\Source+#DQUOTE$+" alt="+#DQUOTE$+MarkDown()\Row()\String+#DQUOTE$+" title="+#DQUOTE$+MarkDown()\Image()\Title+#DQUOTE$+" />" + #LF$  
          EndIf
          ;}
        Case #TaskList    ;{ Task List
          
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
        Case #Table       ;{ Table
          
          Align$ = MarkDown()\Row()\String
          
          HTML$ + "<table>"  + #LF$
          
          ForEach MarkDown()\Row()\Item()
            
            Cols = CountString(MarkDown()\Row()\Item()\String, "|") + 1
            
            Select  MarkDown()\Row()\Item()\Type 
              Case #Header ;{ Table Header
                
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
        Default           ;{ Text
          
          HTML$ + MarkDown()\Row()\String
          
          ForEach MarkDown()\Row()\Item()
            Select MarkDown()\Row()\Item()\Type
              Case #Bold        ;{ Emphasis
                HTML$ + "<strong>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</strong>"
              Case #Italic
                HTML$ + "<em>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</em>"
              Case #BoldItalic 
                HTML$ + "<strong><em>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</em></strong>"
              Case #StrikeThrough
                HTML$ + " <del>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</del>"
                ;}
              Case #Code        ;{ Code
                HTML$ + "<code>" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</code>"  
                ;}
              Case #URL         ;{ URL / EMail
                If CountString(MarkDown()\Row()\Item()\String, "@") = 1
                  HTML$ + "<a href=" + #DQUOTE$ + "mailto:" + URLDecoder(MarkDown()\Row()\Item()\String) + #DQUOTE$ + ">" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</a>" 
                Else  
                  HTML$ + "<a href=" + #DQUOTE$ + URLDecoder(MarkDown()\Row()\Item()\String) + #DQUOTE$ + ">" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</a>" 
                EndIf ;}
              Case #Link        ;{ Link
                If SelectElement(MarkDown()\Link(), MarkDown()\Row()\Item()\Index)
                  If MarkDown()\Link()\Title
                    HTML$ + "<a href=" + #DQUOTE$ + URLDecoder(MarkDown()\Link()\URL) + #DQUOTE$ + " title=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Link()\Title) + #DQUOTE$ + ">" + EscapeHTML_(MarkDown()\Row()\Item()\String) + " </a>"
                  Else  
                    HTML$ + "<a href=" + #DQUOTE$ + URLDecoder(MarkDown()\Link()\URL) + #DQUOTE$ + ">" + EscapeHTML_(MarkDown()\Row()\Item()\String) + "</a>"
                  EndIf 
                EndIf ;}
              Case #Image       ;{ Image
                If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Item()\Index)
                  If MarkDown()\Image()\Title
                    HTML$ + "<img scr=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Row()\Item()\String) + #DQUOTE$ + " title=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Image()\Title) + #DQUOTE$ + " />"
                  Else  
                    HTML$ + "<img scr=" + #DQUOTE$ + MarkDown()\Image()\Source + #DQUOTE$ + " alt=" + #DQUOTE$ + EscapeHTML_(MarkDown()\Row()\Item()\String) + #DQUOTE$ + " />"
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
                  Case ":laugh:"
                    HTML$ + "&#128512;"
                  Case ":smile:"
                    HTML$ + "&#128578;"
                  Case ":sad:"
                    HTML$ + "&#128577;"
                  Case ":angry:"
                    HTML$ + "&#128544;"
                  Case ":cool:"
                    HTML$ + "&#128526;"
                  Case ":smirk:"
                    HTML$ + "&#128527;"
                  Case ":worry:"
                    HTML$ + "&#128543;"
                  Case ":wink:"
                    HTML$ + "&#128521;"
                  Case ":rolf:"
                    HTML$ + "&#129315;"
                  Case ":eyes:" 
                    HTML$ + "&#128580;"
                EndSelect    
                ;}
              Default
                HTML$ + EscapeHTML_(MarkDown()\Row()\Item()\String)
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
        HTML$ + "<sup>" + EscapeHTML_(MarkDown()\Footnote()\Note) + "</sup> " + EscapeHTML_(MarkDown()\Footnote()\String) + "<br>" + #LF$
      Next
		  HTML$ + "</section>"+ #LF$
		  ;}
		EndIf  
    
    HTML$ + "</body>" + #LF$ + "</html>"

    ProcedureReturn HTML$
    
  EndProcedure
  
  
  CompilerIf Defined(PDF, #PB_Module)
    
    Procedure.i TextPDF_(PDF.i, Text.s, WrapPos.i, Indent.i=0, maxCol.i=0, Link.i=#PB_Default, Flag.i=#False) ; WordWrap
      Define.i w, Words, OffsetY, maxWidth, Link
      Define.f X, Y, PosX, txtWidth, WordWidth
      Define.s Word$
      
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
            
            PDF::Cell(PDF, Word$, PDF::GetStringWidth(PDF, Word$))
            
          Next
          ;}
        Else                  ;{ Move to next line
          
          If SelectElement(MarkDown()\Link(), MarkDown()\Row()\Item()\Index)
            Link = PDF::AddLinkURL(PDF, URLDecoder(MarkDown()\Link()\URL))
          EndIf

          PDF::Ln(PDF)
          PDF::SetPosX(PDF, 10)
  
          PDF::Cell(PDF, Text, txtWidth, #PB_Default, #False, PDF::#Right, "", #False, "", Link)
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
            Link = PDF::AddLinkURL(PDF, URLDecoder(MarkDown()\Link()\URL))
          EndIf
          
          PDF::Cell(PDF, Text, txtWidth, #PB_Default, #False, PDF::#Right, "", #False, "", Link)
          
        EndIf
        
      EndIf  
     
    EndProcedure    
    
    Procedure.i EmojiPDF_(PDF.i, Emoji.s, X.i, Y.i, ImgSize.i)
  	  Define *Buffer
  	  
  	  Select Emoji
  	    Case ":laugh:"
  	      *Buffer = AllocateMemory(457)
      	  If *Buffer
            UncompressMemory(?Laugh, 375, *Buffer, 457)
            PDF::ImageMemory(PDF, "Laugh.jpg", *Buffer, 457, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf
        Case ":smile:"
          *Buffer = AllocateMemory(447)
      	  If *Buffer
            UncompressMemory(?Smile, 362, *Buffer, 447)
            PDF::ImageMemory(PDF, "Smile.jpg", *Buffer, 447, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf
        Case ":sad:"
          *Buffer = AllocateMemory(446)
      	  If *Buffer
            UncompressMemory(?Sad, 360, *Buffer, 446)
            PDF::ImageMemory(PDF, "Sad.jpg", *Buffer, 446, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf 
        Case ":angry:"
          *Buffer = AllocateMemory(448)
      	  If *Buffer
            UncompressMemory(?Angry, 364, *Buffer, 448)
            PDF::ImageMemory(PDF, "Angry.jpg", *Buffer, 448, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf
        Case ":cool:"  
          *Buffer = AllocateMemory(457)
      	  If *Buffer
            UncompressMemory(?Cool, 375, *Buffer, 457)
            PDF::ImageMemory(PDF, "Cool.jpg", *Buffer, 457, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf
        Case ":smirk:"
          *Buffer = AllocateMemory(452)
      	  If *Buffer
            UncompressMemory(?Smirk, 371, *Buffer, 452)
            PDF::ImageMemory(PDF, "Smirk.jpg", *Buffer, 452, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf
        Case ":eyes:"
          *Buffer = AllocateMemory(448)
      	  If *Buffer
            UncompressMemory(?Eyes, 366, *Buffer, 448)
            PDF::ImageMemory(PDF, "Eyes.jpg", *Buffer, 448, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf
        Case ":rolf:"
          *Buffer = AllocateMemory(457)
      	  If *Buffer
            UncompressMemory(?rofl, 370, *Buffer, 457)
            PDF::ImageMemory(PDF, "Rofl.jpg", *Buffer, 457, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf  
        Case ":wink:"
          *Buffer = AllocateMemory(456)
      	  If *Buffer
            UncompressMemory(?Wink, 374, *Buffer, 456)
            PDF::ImageMemory(PDF, "Wink.jpg", *Buffer, 456, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf  
        Case ":worry:"
          *Buffer = AllocateMemory(452)
      	  If *Buffer
            UncompressMemory(?Worry, 364, *Buffer, 452)
            PDF::ImageMemory(PDF, "Worry.jpg", *Buffer, 452, PDF::#Image_JPEG, X, Y, ImgSize, ImgSize)
          EndIf  
      EndSelect
      
  	EndProcedure

    Procedure.s ExportPDF_(File.s, Title.s="")
      Define.i PDF, Num, X, Y, RowY, TextWidth, Link
      Define.i c, Cols, ColWidth
      Define.s Bullet$, Align$
      
      PDF = PDF::Create(#PB_Any)
      If PDF

        PDF::AddPage(PDF)
       
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
            Case #Heading     ;{ Heading
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
              
              PDF::Cell(PDF, MarkDown()\Row()\String) 
              
              PDF::Ln(PDF)
              PDF::Ln(PDF, 2)
              ;}
            Case #OrderedList ;{ Ordered List
              
              Num = 0
              
              PDF::Ln(PDF, 3)
              
              ForEach MarkDown()\Row()\Item()
                
                Bullet$ = #Bullet$
                
                If MarkDown()\Row()\Item()\Level
                  Bullet$ = "-"
                  PDF::SetPosX(PDF, 15 + (5 * MarkDown()\Row()\Item()\Level))
                Else  
                  PDF::SetPosX(PDF, 15)
                EndIf 
                
                If MarkDown()\Row()\Item()\Type = #List
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Bullet$) 
                Else
                  Num + 1
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Str(Num)+".") 
                EndIf  
                
              Next 
              
              PDF::Ln(PDF, 3)
              ;}
            Case #List        ;{ Unordered List
              
              Num = 0
              
              PDF::Ln(PDF, 3)
              
              ForEach MarkDown()\Row()\Item()
                
                Bullet$ = #Bullet$
                
                If MarkDown()\Row()\Item()\Level
                  Bullet$ = "-"
                  PDF::SetPosX(PDF, 15 + (5 * MarkDown()\Row()\Item()\Level))
                Else  
                  PDF::SetPosX(PDF, 15)
                EndIf 
                
                If MarkDown()\Row()\Item()\Type = #OrderedList
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Str(Num) + ".") 
                Else
                  Num + 1
                  PDF::MultiCellList(PDF, MarkDown()\Row()\Item()\String, 180, 5, #False, PDF::#LeftAlign, #False, Bullet$) 
                EndIf  
                
              Next 
              
              PDF::Ln(PDF, 3)
              ;}
            Case #TaskList    ;{ Task List
              
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
            Case #HLine       ;{ Horizontal Rule
              PDF::Ln(PDF, 3)
              PDF::DividingLine(PDF)
              PDF::Ln(PDF, 3)
              ;}
            Case #Paragraph   ;{ Paragraph
              PDF::Ln(PDF, 3)
              ;}
            Case #Image       ;{ Image
              
              PDF::Ln(PDF, 3)
              
              If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Index)
                
                X = (210 - mm_(MarkDown()\Image()\Width)) / 2
                Y = PDF::GetPosY(PDF)
                
                PDF::Image(PDF, MarkDown()\Image()\Source, X - 15, Y)
                
                PDF::SetPosY(PDF, Y + mm_(MarkDown()\Image()\Height))
                PDF::Ln(PDF, 10)
                
                If MarkDown()\Row()\String
                  PDF::Ln(PDF, 1)
                  PDF::Cell(PDF, MarkDown()\Row()\String, #PB_Default, #PB_Default, #False, PDF::#NextLine, PDF::#CenterAlign) 
                  PDF::Ln(PDF)
                EndIf
                
              EndIf
              
              PDF::Ln(PDF, 3)
              ;}
            Case #Table       ;{ Table  
              
              Align$ = MarkDown()\Row()\String
              
              PDF::Ln(PDF, 3)
              
              ForEach MarkDown()\Row()\Item()
                
                RowY = 0
                Cols = CountString(MarkDown()\Row()\Item()\String, "|") + 1
                ColWidth = 170 / Cols
                
                Select  MarkDown()\Row()\Item()\Type 
                  Case #Header ;{ Table Header
                    
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
            Default           ;{ Text
              
              PDF::SetMargin(PDF, PDF::#CellMargin, 0)
              
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
                  Case #BoldItalic 
                    PDF::SetFont(PDF, "Arial", "BI", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200)
                  Case #StrikeThrough  
                    PDF::SetFont(PDF, "Arial", "", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200, 0, #PB_Default, #StrikeThrough)
                    ;}
                  Case #Code        ;{ Code
                    PDF::SetFont(PDF, "Courier New", "", 11)
                    TextPDF_(PDF, MarkDown()\Row()\Item()\String, 200)
                    ;}
                  Case #URL         ;{ URL / EMail
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
              
              PDF::SetMargin(PDF, PDF::#CellMargin, 1)
              ;}  
          EndSelect
          
        Next
        
        If ListSize(MarkDown()\Footnote()) ;{ Footnotes
          
          PDF::Ln(PDF, 5)
          PDF::DividingLine(PDF, #PB_Default, #PB_Default, 60)
          PDF::Ln(PDF, 2)
          
          ForEach MarkDown()\Footnote()
            PDF::SubWrite(PDF, MarkDown()\Footnote()\Note + " ", 4.5, 7, 5)
            PDF::SetFont(PDF, "Arial", "", 9)
            TextPDF_(PDF, MarkDown()\Footnote()\String, 200, PDF::GetStringWidth(PDF, MarkDown()\Footnote()\Note + " "))
            PDF::Ln(PDF, 4)
          Next
    		  
    		  ;}
    		EndIf 
        
        PDF::Close(PDF, File)
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  ;- __________ MarkDown __________

  Procedure.i Footnote_(Row.s, sPos.i)
    Define.s Note$
    Define.i ePos
    
    ePos = FindString(Row, "]:", sPos + 2)
    If ePos
      Note$ = Mid(Row, sPos + 2, ePos - sPos - 2)
      If AddElement(MarkDown()\FootNote())
        MarkDown()\FootNote()\Note   = Note$
        MarkDown()\FootNote()\String = Mid(Row, ePos + 2)
        MarkDown()\FootIdx(Note$) = ListIndex(MarkDown()\FootNote())
      EndIf
      ePos = Len(Row)
    Else
      ePos = FindString(Row, "]", sPos + 2)
      If AddElement(MarkDown()\Row()\Item())
        MarkDown()\Row()\Item()\Type   = #FootNote
        MarkDown()\Row()\Item()\String = Mid(Row, sPos + 2, ePos - sPos - 2)
      EndIf
    EndIf
    
    ProcedureReturn ePos
  EndProcedure
  
  Procedure   Image_(Row.s, sPos.i) 
    Define.i ePos
    Define.s Image$
    
    MarkDown()\Row()\Type = #Image
    
    ePos = FindString(Row, "]", sPos + 1)
    MarkDown()\Row()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
    
    sPos = FindString(Row, "(", ePos + 1)
    ePos = FindString(Row, ")", sPos + 1)
    
    Image$ = Mid(Row, sPos + 1, ePos - sPos - 1)
    
    If AddElement(MarkDown()\Image())
      MarkDown()\Row()\Index    = ListIndex(MarkDown()\Image())
      MarkDown()\Image()\Source = StringField(Image$, 1, " " + #DQUOTE$)
      MarkDown()\Image()\Title  = RTrim(StringField(Image$, 2, " " + #DQUOTE$), #DQUOTE$)
    EndIf 
    
  EndProcedure
 
  Procedure.i TextImage_(Row.s, sPos.i) 
    Define.i ePos
    Define.s Image$
    
    MarkDown()\Row()\Item()\Type = #Image
    
    ePos = FindString(Row, "]", sPos + 1)
    MarkDown()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
    
    sPos = FindString(Row, "(", ePos + 1)
    ePos = FindString(Row, ")", sPos + 1)
    
    Image$ = Mid(Row, sPos + 1, ePos - sPos - 1)
    
    If AddElement(MarkDown()\Image())
      MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Image())
      MarkDown()\Image()\Source = StringField(Image$, 1, " " + #DQUOTE$)
      MarkDown()\Image()\Title  = RTrim(StringField(Image$, 2, " " + #DQUOTE$), #DQUOTE$)
    EndIf 
    
    ProcedureReturn ePos
  EndProcedure

  Procedure.i Link_(Row.s, sPos.i) 
    Define.i ePos
    Define.s Link$
    
    MarkDown()\Row()\Item()\Type = #Link
    
    ePos = FindString(Row, "]", sPos + 1)
    MarkDown()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
    
    sPos = FindString(Row, "(", ePos + 1)
    ePos = FindString(Row, ")", sPos + 1)
    
    Link$ = Mid(Row, sPos + 1, ePos - sPos - 1)
    
    If AddElement(MarkDown()\Link())
      MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Link())
      MarkDown()\Link()\URL   = StringField(Link$, 1, " " + #DQUOTE$)
      MarkDown()\Link()\Title = RTrim(StringField(Link$, 2, " " + #DQUOTE$), #DQUOTE$)
    EndIf
    
    ProcedureReturn ePos
  EndProcedure
  
  Procedure.i URL_(Row.s, sPos.i) 
    Define.i ePos
    
    MarkDown()\Row()\Item()\Type = #URL
    
    ePos = FindString(Row, ">", sPos + 1)
    
    ProcedureReturn ePos
  EndProcedure
  
  Procedure.i Code_(Row.s, sPos.i) 
    Define.i ePos
    
    MarkDown()\Row()\Item()\Type = #Code
    
    If Mid(Row, sPos, 2) = "``"
      
      ePos = FindString(Row, "``", sPos + 2)
      If ePos
        MarkDown()\Row()\Item()\String = Mid(Row, sPos + 2, ePos - sPos - 2)
      EndIf
      
    Else  

      ePos = FindString(Row, "`", sPos + 1)
      If ePos
        MarkDown()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
      EndIf

    EndIf
    
    ProcedureReturn ePos
  EndProcedure
 
  Procedure.i Headings_(Row.s) 
    Define.i ePos
    
    MarkDown()\Row()\Type = #Heading
    
    If Left(Row, 6) = "######"
      MarkDown()\Row()\Level = 6
      MarkDown()\Row()\String = RTrim(Mid(Row, 7), "#")
    ElseIf Left(Row, 5) = "#####"
      MarkDown()\Row()\Level = 5
      MarkDown()\Row()\String = RTrim(Mid(Row, 6), "#")
    ElseIf Left(Row, 4) = "####"
      MarkDown()\Row()\Level = 4
      MarkDown()\Row()\String = RTrim(Mid(Row, 5), "#")
    ElseIf Left(Row, 3) = "###"
      MarkDown()\Row()\Level = 3
      MarkDown()\Row()\String = RTrim(Mid(Row, 4), "#")
    ElseIf Left(Row, 2) = "##"  
      MarkDown()\Row()\Level = 2
      MarkDown()\Row()\String = RTrim(Mid(Row, 3), "#")
    Else
      MarkDown()\Row()\Level = 1
      MarkDown()\Row()\String = RTrim(Mid(Row, 2), "#")
    EndIf
    
    ProcedureReturn Len(Row)
  EndProcedure
  
  Procedure.i Emphasis_(Row.s, sPos.i)
    Define.i ePos
    
    If Mid(Row, sPos, 3) = "***"
      MarkDown()\Row()\Item()\Type = #BoldItalic
      ePos = FindString(Row, "***", sPos + 3)
      MarkDown()\Row()\Item()\String = Mid(Row, sPos + 3, ePos - sPos - 3)
      ProcedureReturn ePos + 2
    ElseIf Mid(Row, sPos, 2) = "**"
      MarkDown()\Row()\Item()\Type = #Bold
      ePos = FindString(Row, "**", sPos + 2)
      MarkDown()\Row()\Item()\String = Mid(Row, sPos + 2, ePos - sPos - 2)
      ProcedureReturn ePos + 1
    Else 
      MarkDown()\Row()\Item()\Type = #Italic
      ePos = FindString(Row, "*", sPos + 1)
      MarkDown()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
      ProcedureReturn ePos
    EndIf  
    
  EndProcedure
  
  Procedure.i StrikeThrough_(Row.s, sPos.i) 
    Define.i ePos
    
    ePos = FindString(Row, "~~", sPos + 2)
    If ePos
      MarkDown()\Row()\Item()\Type   = #StrikeThrough
      MarkDown()\Row()\Item()\String = Mid(Row, sPos + 2, ePos - (sPos + 2))
      ProcedureReturn ePos + 1
    Else
      ePos = FindString(Row, "~", sPos + 1)
      If ePos
        MarkDown()\Row()\Item()\Type   = #Subscript
        MarkDown()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - (sPos + 1))
        ProcedureReturn ePos
      EndIf  
    EndIf

  EndProcedure
 
  ; TODO: ToolTip: *[HTML]: 
  
  Procedure.i AddItemText(sPos.i, Pos.i, Row.s, newRow.i)
    
    If sPos <= Pos 
      If newRow 
        MarkDown()\Row()\String = Mid(Row, sPos, Pos - sPos)
        newRow = #False
      ElseIf AddElement(MarkDown()\Row()\Item())
        MarkDown()\Row()\Item()\Type   = #Text
        MarkDown()\Row()\Item()\String = Mid(Row, sPos, Pos - sPos)
      EndIf   
    EndIf
    
    ProcedureReturn newRow
  EndProcedure  
  
  Procedure.i ParseText_(Row.s, BQ.i, LineBreak.i)
    Define.i Pos, sPos, ePos, newRow, Length
    
    Pos = 1 :  sPos = 1 : newRow = 0 
    
    Length = Len(Row)
    
    If LineBreak = #False : Row = RTrim(Row) + " " : EndIf  
    
    If ListSize(MarkDown()\Row()) = 0 Or MarkDown()\Row()\Type <> #Text
      If AddElement(MarkDown()\Row())
        MarkDown()\Row()\Type       = #Text
        MarkDown()\Row()\BlockQuote = BQ
        newRow = #True
      EndIf
    EndIf
    
    Repeat
    
      Select Mid(Row, Pos, 1)
        Case "\" ;{ EscapingCharacters 
          
          Select Mid(Row, Pos, 2)
            Case "\\", "\`", "\*", "\_", "\#", "\+", "\-", "\.", "\!", "\|"
              Row = RemoveString(Row, "\", #PB_String_CaseSensitive, Pos, 1)
              Pos + 1
            Case "\{", "\}", "\[", "\]", "\(", "\)"
              Row = RemoveString(Row, "\", #PB_String_CaseSensitive, Pos, 1)
              Pos + 1
          EndSelect
          ;}
        Case "*" ;{ Emphasis
          
          newRow = AddItemText(sPos, Pos, Row, newRow)

          If AddElement(MarkDown()\Row()\Item())
            ePos = Emphasis_(Row, Pos)
            If ePos : Pos = ePos : EndIf
          EndIf

          sPos = Pos + 1
          ;}
        Case "`" ;{ Code
          
          newRow = AddItemText(sPos, Pos, Row, newRow)
          
          If AddElement(MarkDown()\Row()\Item())
            ePos = Code_(Row, Pos)
            If ePos : Pos = ePos : EndIf
          EndIf

          sPos = Pos + 1
          ;}
        Case "[" ;{ Links / Footnote

          newRow = AddItemText(sPos, Pos, Row, newRow)
          
          If Mid(Row, Pos, 2) = "[^" ;{ Footnote
            
            ePos = Footnote_(Row, Pos)
            If ePos : Pos = ePos : EndIf
            ;}
          Else                        ;{ Links
            
            If AddElement(MarkDown()\Row()\Item())
              ePos = Link_(Row, Pos)
              If ePos : Pos = ePos : EndIf
            EndIf
            ;}
          EndIf
          
          sPos = Pos + 1
          ;}
        Case "<" ;{ URL / Email

          newRow = AddItemText(sPos, Pos, Row, newRow)
          
          If AddElement(MarkDown()\Row()\Item())
            
            ePos = URL_(Row, Pos)
            
            MarkDown()\Row()\Item()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
            
            If AddElement(MarkDown()\Link())
              MarkDown()\Row()\Item()\Index = ListIndex(MarkDown()\Link())
              MarkDown()\Link()\URL = MarkDown()\Row()\Item()\String
            EndIf
            
            If ePos : Pos = ePos : EndIf
          EndIf

          sPos = Pos + 1
          ;}
        Case "!" ;{ Image
          
          If Mid(Row, Pos, 2) = "!["

            newRow = AddItemText(sPos, Pos, Row, newRow)
            
            Pos + 1
            
            If AddElement(MarkDown()\Row()\Item())
              ePos = TextImage_(Row, Pos)
              If ePos : Pos = ePos : EndIf
            EndIf

            sPos = Pos + 1
          EndIf  
          ;}
        Case "^" ;{ Superscript
          
          newRow = AddItemText(sPos, Pos, Row, newRow)
          
          If AddElement(MarkDown()\Row()\Item())
            ePos = FindString(Row, "^", Pos + 1)
            If ePos
              MarkDown()\Row()\Item()\Type   = #Superscript
              MarkDown()\Row()\Item()\String = Mid(Row, Pos + 1, ePos - Pos - 1)
              Pos = ePos
            EndIf
          EndIf

          sPos = Pos + 1                
          ;}
        Case "~" ;{ Subscript / Strikethrough
          
          newRow = AddItemText(sPos, Pos, Row, newRow)
          
          If AddElement(MarkDown()\Row()\Item())
            ePos = StrikeThrough_(Row, Pos)
            If ePos : Pos = ePos : EndIf
          EndIf

          sPos = Pos + 1
          ;}
        Case ":" ;{ Emoji
          
          newRow = AddItemText(sPos, Pos, Row, newRow)
          
          If AddElement(MarkDown()\Row()\Item())
            ePos = FindString(Row, ":", Pos + 1)
            If ePos
              MarkDown()\Row()\Item()\Type   = #Emoji
              MarkDown()\Row()\Item()\String = Mid(Row, Pos, ePos - Pos + 1)
              Pos = ePos
            EndIf
          EndIf
          
          sPos = Pos + 1
          ;}
      EndSelect
      
      Pos + 1
      
    Until Pos > Length
    
    If sPos <= Pos  ;{ Remaining text
      If newRow And MarkDown()\Row()\String = ""
        MarkDown()\Row()\String = Mid(Row, sPos)
      Else
        If AddElement(MarkDown()\Row()\Item())
          MarkDown()\Row()\Item()\Type   = #Text
          MarkDown()\Row()\Item()\String = Mid(Row, sPos)
        EndIf
      EndIf ;}
    EndIf
    
    If LineBreak
      MarkDown()\Row()\Type = #LineBreak
      LineBreak = #False
    EndIf
    
    ProcedureReturn LineBreak
  EndProcedure
  
  Procedure   Parse_(Text.s)
    Define.i r, Rows, c, Cols, Length, Pos, sPos, ePos, BQ, newRow, LineBreak, Type
    Define.s Row$, Num$, trimRow$, Col$, Text$
    
    Text = ReplaceString(Text, #CRLF$, #LF$)
    Text = ReplaceString(Text, #CR$, #LF$)
    Text = ReplaceString(Text, "_", "*")
    
    Rows = CountString(Text, #LF$) + 1
    
    For r = 1 To Rows
      
      BQ = 0
      
      Row$   = StringField(Text, r, #LF$)

      If Right(Row$, 2) = "  "
        Row$ = RTrim(Row$)
        LineBreak = #True
      EndIf
      
      If Left(Row$, 3) = ">> "
        BQ = 2
        Row$ = Mid(Row$, 4)
      ElseIf Left(Row$, 2) = "> "
        BQ = 1
        Row$ = Mid(Row$, 3)
      EndIf 
    
      Select Left(Row$, 1)
        Case "#"         ;{ Headings
          
          ; TODO: HeadingID: ### My Great Heading {#custom-id} / <h3 id="custom-id">My Great Heading</h3>
     
          If AddElement(MarkDown()\Row())
            Headings_(Row$)
            If Left(MarkDown()\Row()\String, 1)  = " " : MarkDown()\Row()\String = Mid(MarkDown()\Row()\String, 2) : EndIf 
            If Right(MarkDown()\Row()\String, 1) = " " : MarkDown()\Row()\String = Left(MarkDown()\Row()\String, Len(MarkDown()\Row()\String) - 1) : EndIf
            MarkDown()\Row()\BlockQuote = BQ
          EndIf
          ;}        
        Case "="         ;{ Heading level 1
          
          If ListSize(MarkDown()\Row()) And MarkDown()\Row()\Type = #Text And CountString(Row$, "=") = Len(Row$)
            MarkDown()\Row()\Type  = #Heading
            MarkDown()\Row()\Level = 1
          Else
            LineBreak = ParseText_(Row$, BQ, LineBreak)
          EndIf
          ;}
        Case "-"         ;{ Heading level 2 / Unordered Lists
          
          If CountString(Row$, "-") = Len(Row$) ;{ Heading level 2
            
            If ListSize(MarkDown()\Row()) : Type = MarkDown()\Row()\Type : EndIf
    
            Select Type
              Case #Text
                
                If ListSize(MarkDown()\Row()\Item())
                  MarkDown()\Row()\Type = #LineBreak
                  LastElement(MarkDown()\Row()\Item())
                  Text$ = MarkDown()\Row()\Item()\String
                  DeleteElement(MarkDown()\Row()\Item())
                  If AddElement(MarkDown()\Row())
                    MarkDown()\Row()\String = Text$
                  EndIf  
                EndIf
                
                MarkDown()\Row()\Type  = #Heading
                MarkDown()\Row()\Level = 2
                
              Default
                
                If AddElement(MarkDown()\Row())
                  MarkDown()\Row()\Type = #HLine
                EndIf 
                
            EndSelect  
            ;}
          Else                                  ;{ Unordered Lists
            
            If Left(Row$, 5) = "- [ ]"
              
              If ListSize(MarkDown()\Row()) = #False Or MarkDown()\Row()\Type <> #TaskList
                AddElement(MarkDown()\Row())
                MarkDown()\Row()\Type = #TaskList
                MarkDown()\Row()\BlockQuote = BQ
              EndIf  
              
              If AddElement(MarkDown()\Row()\Item())
                MarkDown()\Row()\Item()\Type   = #TaskList
                MarkDown()\Row()\Item()\String = RTrim(Mid(Row$, 6))
                MarkDown()\Row()\Item()\State  = #False
              EndIf
              
            ElseIf UCase(Left(Row$, 5)) = "- [X]"
              
              If ListSize(MarkDown()\Row()) = #False Or MarkDown()\Row()\Type <> #TaskList
                AddElement(MarkDown()\Row())
                MarkDown()\Row()\Type = #TaskList
                MarkDown()\Row()\BlockQuote = BQ
              EndIf 
              
              If AddElement(MarkDown()\Row()\Item())
                MarkDown()\Row()\Item()\Type   = #TaskList
                MarkDown()\Row()\Item()\String = RTrim(Mid(Row$, 6))
                MarkDown()\Row()\Item()\State  = #True
              EndIf
              
            ElseIf Left(Row$, 2) = "- "
              
              If ListSize(MarkDown()\Row()) = #False Or (MarkDown()\Row()\Type <> #List And MarkDown()\Row()\Type <> #OrderedList)
                AddElement(MarkDown()\Row())
                MarkDown()\Row()\Type = #List
                MarkDown()\Row()\BlockQuote = BQ
              EndIf  
              
              If AddElement(MarkDown()\Row()\Item())
                MarkDown()\Row()\Item()\Type   = #List
                MarkDown()\Row()\Item()\String = LTrim(Mid(Row$, 3))
                MarkDown()\Row()\Item()\Level  = 0
              EndIf
              
            Else
              
              LineBreak = ParseText_(Row$, BQ, LineBreak)
              
            EndIf  
            ;}
          EndIf  
          ;}  
        Case "*", "+"    ;{ Unordered Lists
    
          If Left(Row$, 2) = "* " Or Left(Row$, 2) = "+ "
            
            If ListSize(MarkDown()\Row()) = #False Or (MarkDown()\Row()\Type <> #List And MarkDown()\Row()\Type <> #OrderedList)
              AddElement(MarkDown()\Row())
              MarkDown()\Row()\Type = #List
              MarkDown()\Row()\BlockQuote = BQ
            EndIf  
            
            If AddElement(MarkDown()\Row()\Item())
              MarkDown()\Row()\Item()\Type   = #List
              MarkDown()\Row()\Item()\String = LTrim(Mid(Row$, 3))
              MarkDown()\Row()\Item()\Level  = 0
            EndIf
            
          ElseIf CountString(Row$, Left(Row$, 1)) = Len(Row$)
            
            MarkDown()\Row()\Type = #HLine
            
          Else
            
            LineBreak = ParseText_(Row$, BQ, LineBreak)
            
          EndIf  
          ;}
        Case "1", "2", "3", "4", "5", "6", "7", "8", "9" ;{ Ordered List
          
          Num$ = StringField(Row$, 1, " ")
          If Right(Num$, 1) = "."
            
            If ListSize(MarkDown()\Row()) = #False Or (MarkDown()\Row()\Type <> #List And MarkDown()\Row()\Type <> #OrderedList)
              AddElement(MarkDown()\Row())
              MarkDown()\Row()\Type = #OrderedList
              MarkDown()\Row()\BlockQuote = BQ
            EndIf  
            
            If AddElement(MarkDown()\Row()\Item())
              MarkDown()\Row()\Item()\Type   = #OrderedList
              MarkDown()\Row()\Item()\String = Mid(Row$, Len(Num$) + 1)
              MarkDown()\Row()\Item()\Level  = 0
            EndIf
            
          Else
            
            LineBreak = ParseText_(Row$, BQ, LineBreak)
            
          EndIf
          
          ; TODO: Parse remaining text 
          
          ;}
        Case "!"         ;{ Image
          
          If Left(Row$, 2) = "!["
            If AddElement(MarkDown()\Row())
              Image_(Row$, 2)
            EndIf
          EndIf
          ;}
        Case "|"         ;{ Table
          
          If ListSize(MarkDown()\Row()) = 0 Or MarkDown()\Row()\Type <> #Table
            AddElement(MarkDown()\Row())
            MarkDown()\Row()\Type = #Table
            MarkDown()\Row()\BlockQuote = BQ
          EndIf
          
          trimRow$ = Trim(RTrim(Mid(Row$, 2), "|"))
          
          If Left(trimRow$, 3) = "---" Or Left(trimRow$, 4) = ":---" ;{ Header 
            If FirstElement(MarkDown()\Row()\Item())
              MarkDown()\Row()\Item()\Type = #Header
              MarkDown()\Row()\String = ""
              Cols = CountString(trimRow$, "|") + 1
              For c=1 To Cols
                Col$ = Trim(StringField(trimRow$, c, "|"))
                If Left(Col$, 1) = ":" And Right(Col$, 1) = ":"
                  MarkDown()\Row()\String + "C|"
                ElseIf Right(Col$, 1) = ":"
                  MarkDown()\Row()\String + "R|"
                Else
                  MarkDown()\Row()\String + "L|"
                EndIf
              Next 
              MarkDown()\Row()\String = RTrim(MarkDown()\Row()\String, "|")
            EndIf  
            ;}
          Else                                                       ;{ Table rows
            
            If AddElement(MarkDown()\Row()\Item())
              MarkDown()\Row()\Item()\Type   = #Table 
              MarkDown()\Row()\Item()\String = trimRow$
            EndIf  
            ;}
          EndIf
          ;}
        Case "["         ;{ Footnote text
          ePos = FindString(Row$, "]:", 2)
          If ePos
            Text$ = Mid(Row$, 3, ePos - 3)
            If AddElement(MarkDown()\FootNote())
              MarkDown()\FootNote()\Note   = Text$
              MarkDown()\FootNote()\String = Mid(Row$, ePos + 2)
              MarkDown()\FootIdx(Text$) = ListIndex(MarkDown()\FootNote())
            EndIf
          EndIf  
          ;}
        Case " ", #TAB$  ;{ Indented
          
          trimRow$ = LTrim(Row$, #TAB$)
          trimRow$ = LTrim(trimRow$)
          
          If Left(Row$, 4) = "    " Or Left(Row$, 1) = #TAB$
            Select Mid(Row$, 5, 1)
              Case "-", "+", "*"                               ;{ Unordered Lists (indented)
                
                If ListSize(MarkDown()\Row()) = #False Or (MarkDown()\Row()\Type <> #List And MarkDown()\Row()\Type <> #OrderedList)
                  AddElement(MarkDown()\Row())
                  MarkDown()\Row()\Type = #List
                  MarkDown()\Row()\BlockQuote = BQ
                EndIf
                
                If AddElement(MarkDown()\Row()\Item())
                  MarkDown()\Row()\Item()\Type   = #List
                  MarkDown()\Row()\Item()\String = LTrim(Mid(trimRow$, 3))
                  MarkDown()\Row()\Item()\Level  = 1
                EndIf
                ;}
              Case "1", "2", "3", "4", "5", "6", "7", "8", "9" ;{ Ordered List    (indented)
                Num$ = StringField(trimRow$, 1, " ")
                If Right(Num$, 1) = "."
                  
                  If ListSize(MarkDown()\Row()) = #False Or (MarkDown()\Row()\Type <> #List And MarkDown()\Row()\Type <> #OrderedList)
                    AddElement(MarkDown()\Row())
                    MarkDown()\Row()\Type = #OrderedList
                    MarkDown()\Row()\BlockQuote = BQ
                  EndIf  
                  
                  If AddElement(MarkDown()\Row()\Item())
                    MarkDown()\Row()\Item()\Type   = #OrderedList
                    MarkDown()\Row()\Item()\String = Mid(trimRow$, Len(Num$) + 1)
                    MarkDown()\Row()\Item()\Level  = 1
                  EndIf
                  
                Else
                  
                  If AddElement(MarkDown()\Row()\Item())
                    MarkDown()\Row()\Item()\Type = #Text
                    MarkDown()\Row()\String      = Row$
                  EndIf 
                  
                EndIf
                ;}
              Default                                          ;{ Text
                LineBreak = ParseText_(Row$, BQ, LineBreak)
                ;}
            EndSelect
          ElseIf Left(trimRow$, 2) = "!["                      ;{ Image
            
            If AddElement(MarkDown()\Row())
              Image_(trimRow$, 2)
            EndIf
            ;}
          Else                                                 ;{ Text
            LineBreak = ParseText_(Row$, BQ, LineBreak)
            ;}
          EndIf 
          ;}
        Case ""          ;{ Paragraph
          
          If AddElement(MarkDown()\Row())
            MarkDown()\Row()\Type = #Paragraph
            MarkDown()\Row()\BlockQuote = BQ
          EndIf  
          ;}
        Default          ;{ Text (Emphasis / ...)
          
          LineBreak = ParseText_(Row$, BQ, LineBreak)
          ;}
      EndSelect
      
    Next
    
  EndProcedure  
  
	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
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
  
  
  Procedure.i DrawText_(X.i, Y.i, Text.s, FrontColor.i, Indent.i=0, maxCol.i=0, Link.i=#PB_Default, Flag.i=#False) ; WordWrap
    Define.i w, PosX, txtWidth, txtHeight, Words, Rows, bqY, OffsetY, OffSetBQ, maxWidth
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
    
    DrawingMode(#PB_2DDrawing_Transparent)
    
    If X + TextWidth(Text) > maxWidth
      
      Rows = 1
      
      If Link = #PB_Default ;{ WordWrap
      
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
          
          If Flag = #StrikeThrough : Line(PosX, Y + OffsetY, TextWidth(Word$), 1, FrontColor) : EndIf 
          
          PosX = DrawText(PosX, Y, Word$, FrontColor)
  
        Next
        ;}
      Else                  ;{ Move to next line
        
        PosX = MarkDown()\LeftBorder + Indent + OffSetBQ
        Y + TextHeight(Text)
        Rows + 1
        MarkDown()\WrapHeight + TextHeight("Abc")
        
        If SelectElement(MarkDown()\Link(), Link)
          MarkDown()\Link()\X      = PosX
          MarkDown()\Link()\Y      = Y
          MarkDown()\Link()\Width  = TextWidth(Text)
          MarkDown()\Link()\Height = TextHeight(Text)
          If MarkDown()\Link()\State : FrontColor = MarkDown()\Color\LinkHighlight : EndIf 
        EndIf
        
        If Flag = #StrikeThrough : Line(PosX, Y + OffsetY, TextWidth(Text), 1, FrontColor) : EndIf 
        
        PosX = DrawText(PosX, Y, Text, FrontColor)
        ;}
      EndIf
      
      If MarkDown()\BlockQuote
        DrawingMode(#PB_2DDrawing_Default)
        Box(MarkDown()\LeftBorder, bqY, dpiX(5), txtHeight * Rows, MarkDown()\Color\BlockQuote)
        If MarkDown()\BlockQuote = 2
          Box(MarkDown()\LeftBorder + dpiX(10), bqY, dpiX(5), txtHeight * Rows, MarkDown()\Color\BlockQuote)
        EndIf  
      EndIf 
      
      ProcedureReturn PosX - OffSetBQ
    Else

      If Link <> #PB_Default
        If SelectElement(MarkDown()\Link(), Link)
          MarkDown()\Link()\X      = X
          MarkDown()\Link()\Y      = Y
          MarkDown()\Link()\Width  = TextWidth(Text)
          MarkDown()\Link()\Height = TextHeight(Text)
          If MarkDown()\Link()\State : FrontColor = MarkDown()\Color\LinkHighlight : EndIf 
        EndIf
      EndIf
      
      If Flag = #StrikeThrough : Line(X, Y + OffsetY, TextWidth(Text), 1, FrontColor) : EndIf 
     
      X = DrawText(X, Y, Text, FrontColor)
      
      If MarkDown()\BlockQuote
        DrawingMode(#PB_2DDrawing_Default)
        Box(MarkDown()\LeftBorder, bqY, dpiX(5), TextHeight(Text), MarkDown()\Color\BlockQuote)
        If MarkDown()\BlockQuote = 2
          Box(MarkDown()\LeftBorder + dpiX(10), bqY, dpiX(5), TextHeight(Text), MarkDown()\Color\BlockQuote)
        EndIf 
      EndIf  
     
      ProcedureReturn X - OffSetBQ
    EndIf  

    
  EndProcedure
  
	Procedure   Draw_()
	  Define.i X, Y, Width, Height, LeftBorder, WrapPos, TextHeight, Cols
	  Define.i Indent, Level, Offset, OffSetX, OffSetY, maxCol, ImgSize
	  Define.i c, OffsetList, NumWidth, ColWidth, TableWidth
		Define.i FrontColor, BackColor, BorderColor, LinkColor
		Define.s Text$, Num$
		
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
			    Case #Heading     ;{ Heading  
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
			      
			      Y + TextHeight(MarkDown()\Row()\String) + MarkDown()\WrapHeight
            ;}
			    Case #OrderedList ;{ Ordered List  
			      
			      ClearMap(ListNum())
			      
			      DrawingMode(#PB_2DDrawing_Transparent)

			      NumWidth   = Len(Str(ListSize(MarkDown()\Row()\Item()))) * TextWidth("0")
			      
			      Y + (TextHeight / 2)
			      
			      ForEach MarkDown()\Row()\Item()
			        
			        Offset = 0
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

			        DrawText_(X + Offset + MarkDown()\Indent + Indent, Y, Num$ + MarkDown()\Row()\Item()\String, FrontColor, Offset + MarkDown()\Indent + Indent + TextWidth(Num$))

			        Y + TextHeight
			      Next
			      
			      Y + MarkDown()\WrapHeight + (TextHeight / 2)
			      ;}
			    Case #List        ;{ Unordered List
			      
			      ClearMap(ListNum())
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      NumWidth   = TextWidth("0")

			      Y + (TextHeight / 2)
			      
			      ForEach MarkDown()\Row()\Item()
			        
			        Level  = MarkDown()\Row()\Item()\Level
			        Indent = TextWidth(#Bullet$ + " ") * MarkDown()\Row()\Item()\Level
			        
			        If Level
			          If MarkDown()\Row()\Item()\Type = #OrderedList
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level))) + ". "
			          Else  
			            Num$ = "- "
			          EndIf
			        Else
			          If MarkDown()\Row()\Item()\Type = #OrderedList
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level))) + ". "
			          Else  
			            Num$ = #Bullet$ + " "
			          EndIf 
			        EndIf  
			        
			        DrawText_(X + MarkDown()\Indent + Indent, Y, Num$ + MarkDown()\Row()\Item()\String, FrontColor, MarkDown()\Indent + Indent + TextWidth(Num$))
			        
			        Y + TextHeight
			      Next
			      
			      Y + MarkDown()\WrapHeight + (TextHeight / 2)
			      ;}
			    Case #TaskList    ;{  
			      
			      Y + (TextHeight / 2)
			      
			      NumWidth = TextHeight + TextWidth(" ")

			      ForEach MarkDown()\Row()\Item()
			        
			        CheckBox_(X + MarkDown()\Indent, Y + dpiY(1), TextHeight - dpiY(2), FrontColor, BackColor, MarkDown()\Row()\Item()\State)
			      
			        DrawingMode(#PB_2DDrawing_Transparent)
			        DrawText_(X + MarkDown()\Indent + TextHeight, Y, MarkDown()\Row()\Item()\String, FrontColor, MarkDown()\Indent + NumWidth)
			      
			        Y + TextHeight + dpiY(2)
			      Next
			      
			      Y + (TextHeight / 2)
			      ;}
			    Case #HLine       ;{ Horizontal Rule  

			      OffSetY = TextHeight / 2
			      Line(X, Y + OffSetY, Width, 1, FrontColor)
			      
			      Y + TextHeight
			      ;}
			    Case #Paragraph   ;{ Paragraph  
			      Y + TextHeight
			      ;}
			    Case #Image       ;{ Image
			      If SelectElement(MarkDown()\Image(), MarkDown()\Row()\Index)
			        
			        If MarkDown()\Image()\Num = #False ;{ Load Image
			          MarkDown()\Image()\Num = LoadImage(#PB_Any, MarkDown()\Image()\Source)
			          If MarkDown()\Image()\Num
			            MarkDown()\Image()\Width  = ImageWidth(MarkDown()\Image()\Num)
			            MarkDown()\Image()\Height = ImageHeight(MarkDown()\Image()\Num)
			          EndIf ;}
			        EndIf
			        
			        If IsImage(MarkDown()\Image()\Num)
			          
			          OffSetX = (Width - MarkDown()\Image()\Width) / 2
			          
			          DrawingMode(#PB_2DDrawing_AlphaBlend)
			          DrawImage(ImageID(MarkDown()\Image()\Num), X + OffSetX, Y)
			          Y + MarkDown()\Image()\Height
			          
			          If MarkDown()\Row()\String
			            Y + (TextHeight / 4)
			            OffSetX = (Width - TextWidth(MarkDown()\Row()\String)) / 2
			            DrawingMode(#PB_2DDrawing_Transparent)
			            DrawText(X + OffSetX, Y, MarkDown()\Row()\String, FrontColor)
			            Y + TextHeight(MarkDown()\Row()\String)
			          EndIf
			          
			        ElseIf MarkDown()\Image()\Title
			          OffSetX = (Width - TextWidth(MarkDown()\Image()\Title)) / 2
		            DrawingMode(#PB_2DDrawing_Transparent)
		            DrawText(X + OffSetX, Y, MarkDown()\Image()\Title, FrontColor)
		            Y + TextHeight(MarkDown()\Image()\Title)
			        EndIf 
			        
			        If MarkDown()\Image()\Width > MarkDown()\Required\Width : MarkDown()\Required\Width = MarkDown()\Image()\Width : EndIf 
			        
			      EndIf  
			      ;}
			    Case #Table       ;{ Table
	
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

			        If MarkDown()\Row()\Item()\Type = #Header
			          DrawingFont(FontID(MarkDown()\Font\Bold))
			        Else
			          DrawingFont(FontID(MarkDown()\Font\Normal))
			        EndIf  
			        
			        For c=0 To Cols - 1
			          maxCol = ColWidth * (c + 1)
		            DrawText_(X + (ColWidth * c), Y, Trim(StringField(Text$, c+1, "|")), FrontColor, 0, maxCol)
		          Next 
		          
		          Y + TextHeight + MarkDown()\WrapHeight
		          
		          If MarkDown()\Row()\Item()\Type = #Header
  		          OffSetY = TextHeight / 2
  		          Line(X, Y + OffSetY, TableWidth, 1, FrontColor)
  		          Y + TextHeight 
			        EndIf  
			        
			      Next
			      
			      Y + (TextHeight / 2)
			      ;}
			    Default           ;{ Text
			      
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
                Case #BoldItalic 
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
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, FrontColor)
                  ;}                
                Case #Link          ;{ Link
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, LinkColor, #False, 0, MarkDown()\Row()\Item()\Index)  
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
                Case #URL           ;{ URL / EMail
                  DrawingFont(FontID(MarkDown()\Font\Normal))
                  X = DrawText_(X, Y, MarkDown()\Row()\Item()\String, LinkColor, #False, 0, MarkDown()\Row()\Item()\Index)
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
			  Line(X, Y + OffSetY, Width / 3, 1, FrontColor)

			  Y + TextHeight
			  
			  ForEach MarkDown()\Footnote()
			    
          DrawingFont(FontID(MarkDown()\Font\FootNote))
          X = DrawText_(MarkDown()\LeftBorder, Y, MarkDown()\Footnote()\Note + " ", FrontColor)
          Indent = TextWidth(MarkDown()\Footnote()\Note + "  ")
          
          DrawingFont(FontID(MarkDown()\Font\FootNoteText))
          DrawText_(X, Y, MarkDown()\Footnote()\String, FrontColor, Indent)
          
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
			      
			      MarkDown()\EventValue = MarkDown()\Link()\URL
			      
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
		Define.i GNum = EventGadget()

		If FindMapElement(MarkDown(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)

			ForEach MarkDown()\Link()
			  If Y >= MarkDown()\Link()\Y And Y <= MarkDown()\Link()\Y + MarkDown()\Link()\Height 
			    If X >= MarkDown()\Link()\X And X <= MarkDown()\Link()\X + MarkDown()\Link()\Width
  			    SetGadgetAttribute(MarkDown()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
  			    ProcedureReturn #True
  			  EndIf
			  EndIf
			Next  
			
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
				
				MarkDown()\Indent = 10
				
				MarkDown()\Flags  = Flags

				MarkDown()\Color\Front         = $000000
				MarkDown()\Color\Back          = $FFFFFF
				MarkDown()\Color\Gadget        = $F0F0F0
				MarkDown()\Color\Border        = $A0A0A0
				MarkDown()\Color\Link          = $8B0000
				MarkDown()\Color\LinkHighlight = $FF0000
				MarkDown()\Color\BlockQuote    = $C0C0C0
				MarkDown()\Color\DisableFront  = $72727D
				MarkDown()\Color\DisableBack   = $CCCCCA
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						MarkDown()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
						MarkDown()\Color\Back   = GetSysColor_(#COLOR_WINDOW)
						MarkDown()\Color\Border = GetSysColor_(#COLOR_WINDOWFRAME)
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
          MarkDown()\Radius  = Value
      EndSelect
      
      Draw_()
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
        Case #FrontColor
          MarkDown()\Color\Front       = Value
        Case #BackColor
          MarkDown()\Color\Back        = Value
        Case #BorderColor
          MarkDown()\Color\Border      = Value
        Case #LinkColor
          MarkDown()\Color\Link        = Value  
        Case #LinkHighlightColor
          MarkDown()\Color\LinkHighlight = Value    
        Case #BlockQuoteColor 
          MarkDown()\Color\BlockQuote  = Value 
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
    Angry:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$4EC0C41847FFC641,$2571406C2C4C0645,
           $4626064666260601,$208B3313232C9856,$A19288B09B2290AB,$0656BA288D502063,$566636A0413956B0,$4516066641466124,
           $316FFF89C7431161,$B064166415CC80F0,$0BCBC6F0BA63B867,$B9D0BF1EE64717D3,$C302B6A677A555AC,$9E16992C97AE660A,
           $11CCB6F498125477,$E5B0CBF07177717B,$1ACD3A6B195E6D06,$DECF8B5E3A32F67F,$EDF83C323F32C8D7,$69A64BAF8D50CB3E,
           $32BCAC39CD33DD69,$DB0109FB1D897E55,$065AA216BBC676FA,$CBF6548568E7DB35,$E5913DEA2AEB4517,$3FE4CB717DB2E7DA,
           $FDBF65C7EEB5E612,$5131E7F3DFCF745C,$0009BFFF5E5F1983
    Data.b $03,$99,$6D,$17
    Cool:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$4EC0C41847FFC641,$1571406C2C4C0645,
           $8566646020260601,$B22A08B331323389,$2A888A1B0BB109B2,$666BA28955022639,$6664606413966B00,$6432141466124661,
           $7FFE3116640C5260,$6602E8119987818B,$7FDE93CD867B0641,$F7FE3CF61BC37D8A,$B1A6457DEA7B4994,$7D6030B35AE9AD77,
           $1B73CDE169C18E47,$F3DA3E2ABEE3C41B,$527395DB34D9BBDE,$754CFEDC9F1BC5D5,$F353911092C23F13,$0FABA7CAE3AF89A0,
           $52156CF9E8391B5E,$E27AA9B4E0595A48,$0EA38B4CDC6D89BF,$EAA3F47A63DE5BD8,$ECFCDA792735A2EF,$67B89B712D6D3FCA,
           $93078BC303A0998D,$72AB7BEB9E30FF0E,$254549E8EDEB9D77,$FFAD1E4EA2934C9D
    Data.b $7F,$13,$00,$C6,$D5,$78,$3E
    Eyes:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$4EC0C41847FFC641,$1571406C2C4C0645,
           $6636264626260601,$AB208B33132324B8,$92A3B2A2B09B0310,$66BA2895500AA061,$664606413966B006,$2141064661246616,
           $FFC7634540C31126,$320932A6807818B7,$E5EB98DC33D8320B,$CAD98B5D6760F79B,$FBEB91CDA9562F13,$3ED95DE3C3D4CCB0,
           $F237302FE27FBFEF,$57365B2E2C764FED,$C63316DAF25224C6,$0A8F8C5E41A229C8,$62A5F8DADEFF19CE,$73C78535A2CBC877,
           $72DEBD4DF7A9320E,$D90E1E4D1697F1FA,$2F03193CE78C7CFD,$111BC2672BF67C3F,$CE4D2F2A45EBFB55,$659D9874555AF7EC,
           $7634CBB6E91BD7DA,$7579DA7B746D79EC,$6FFF5383374EF71F
    Data.b $02,$00,$38,$46,$71,$C3
    Laugh:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$1819C41847FFC641,$2B0B130190191998,
           $859181804142501B,$4599899192490989,$D0C958514D885590,$C01449E41442A809,$CCCAC0C0C828D602,$A42822C4C8CE2C8A,
           $FFF1B89814ACC868,$CC824CA1A01E062D,$9BCC4FB70CF60C82,$3F3E0E4CF04FE733,$ECCEE66FBEB590BF,$CAE61FE5C4BDE868,
           $E64581D4BFC93754,$7F19FB53D9E761C7,$FCE17C6455E4784C,$B53B0176A8C6392A,$0A0AD7962FC76C93,$95AD95532CFA48CF,
           $AB0E8D9302E2B7AE,$292FAFB349A703D5,$77901EEFB8646313,$AD314DF1EC9F7192,$A9EF4CE652A7DC9D,$B9DAF3D237355968,
           $FE2654B3D8DF5C15,$A6F17016A49D8864,$FB9DCFDF76D7AEA5,$FF995CB2C48AE503
    Data.b $DF,$04,$00,$53,$2A,$6E,$AB
    rofl:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$4E81441847FFC641,$2561406CCC014065,
           $3309866030260601,$B2290A0AB0B33132,$B4811B288A3B0A19,$17956901656BA232,$6A0612466365AA04,$6C2C74356A016065,
           $68119987818B7FFC,$3FDEC33D8320B33F,$4E734FFB66572AB3,$B744536AE9FD3E8A,$A7C78DC6844094AB,$C8628FAF9DDA6E3B,
           $D796E88A16678D4C,$E2763F9B3698AB11,$5C38D6AB7C5685CE,$E745F1BEFDB1CE54,$2EF2DE3F5FBB9DEC,$36B0E54F1AD7A360,
           $E03E4A1FAFF3CEB7,$82FAC19FF09EBDCF,$7F928AF6F6C314B5,$B2F93FBBAD3E498E,$317F64EE0B572574,$F46EEB5BA7C33661,
           $329A8D4DBED7473B,$94D8DDC6A8F5585B,$BA69DEB75A960FCF,$49570026FFFF2A67
    Data.b $76,$BB
    Sad:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$4E81441847FFC641,$0561406C4C014065,
           $8446662616460601,$22AB208B33132324,$234823A19092B09B,$417946901646BA23,$00A06124760646A0,$C4E3A188B08B22B3,
           $023330F0316FFF83,$F7D867B06416676D,$3D47A7A54D54DF2E,$B1335AD9F044F3B5,$5D1D84554B192123,$C0C0C1BECCA97704,
           $07E3BF33D9F1F1E7,$3D34CBA42C92DB6A,$1290DDA69918839C,$23AF70A5D80DB109,$A75AB78DE3F8E532,$26FC950C50537ED6,
           $BB78C2CD8346F0B6,$737DB14ACFEB1E83,$A7614F69F37C3008,$6293B65AEDEBF7E4,$76BF8A28E40AB7E2,$5F46F775C7FAD4EB,
           $18DF669B8EDD4E9F,$D6EBF794FAD9E75F,$4D6CEEF70009BFFF
    Smile:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$4EC0C41847FFC641,$2571406C4C8C0645,
           $1646260666260601,$22AB208B33388466,$226392A198B0909B,$90160656BA288D50,$5666664606417956,$A288B08B00906124,
           $F0316FFF83C4E263,$60C82CC01D023330,$2D30E7E3FABF70CF,$36E7BADDA79713FF,$AD04A6D37B62E04B,$D69E15EE02CD7225,
           $CAD9DB27D5181837,$4969B0F92B53DEEE,$0209AE2FD4D66593,$304FF9B99DE58F86,$2F961951D7BC70EE,$89AF5EDDED7526D1,
           $B44EB924E8E6A693,$8DDAF1ACDADD78F7,$4B3F411907DEFBF9,$FCA7BF367B6DD6D9,$0A27B8CE2B09DAE6,$F3FC3A4C3224B03A,
           $83C79FD0995957DE,$7D665BDDB0BE192A,$5C5E004DFFFEB73C
    Data.b $6F,$CC
    Wink:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$1819C41847FFC641,$1B33130050191998,
           $9185918180454250,$22CCC4C8CB210599,$E86C26C8A2242AC8,$0A25540464AA20C8,$10566901600A28F2,$1612476266646064,
           $161160643456EA04,$0F0316FFF87C0C71,$7B06416641265CD0,$7692526751F93B86,$687AE2AA53E670CE,$BB80A8DAD72B6BF4,
           $D7266CBC19FF2DA1,$A5BBC0E35DF87EAD,$7FCB5AEF71AD1E8F,$13FAE795ADE3373C,$22741F8E4CAD7D5E,$C595FBBE07AA8FCC,
           $95E97729C572E81C,$2E19A5D31DECAF48,$2AB98C654C848967,$EAC1F0F443CF3CAB,$92561CFEBA2B05D5,$C22E9DE0E5362F54,
           $21E66B2AE768A2DB,$F7F9E13AE5965FC3,$905FE4374726BF15,$FFFECF372D589791
    Data.b $4D,$00,$0E,$83,$6D,$C7
    Worry:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$4EC0C41847FFC641,$4571406C2C4C0645,
           $324B866010260601,$B10AB22A08B33132,$889502063A192B09,$641054EB0064EBA2,$0466124762666460,$68A22C22C8ECC75A,
           $330F0316FFF85818,$64B6E19EC1904458,$6B57F36D56CD714E,$DFE7ADBB19279557,$D820996A192E2164,$0601DB7C74915CA1,
           $F44FAAE3F2E57146,$B928E51C5EBF9743,$816D8509498CE36A,$6C3CC40E6A224C93,$DB2F1AAD3D097764,$466EC3E6CF6735A6,
           $5EB77D7A9C3E4B61,$751FEC94EEEE49B4,$69FE1E3C2D31CEFF,$E9EDD26D92D86F15,$B7A3799D4CA5B667,$D7932C1B86C8EFC5,
           $EBF8E7B1CAF39C1F,$9D3FBE5DB3D6C61D,$0137FFFEDA7CB9CC
    Data.b $5C,$F3,$73,$77
    Smirk:
    Data.q $0603FFE37FFB9C78,$464606374F372F01,$9B7FF86420390646,$8D9D8D8D838199C1,$8393939D9D9D8395,$479B9B879784478B,
           $5E4A56445F984852,$4F454146464A564E,$C34646594749415D,$44C4C4D0C0C7535C,$CF46C8C2D6D2DD5E,$272723086408C4D8,
           $84AF2F048F370F27,$FFE0C911A28CA291,$7E067E060E410601,$6646412606254666,$1819C41847FFC641,$1B0B130050191998,
           $0409819180514250,$82CC2C4C8CE26198,$4686A2C28A6C42AC,$00A25F20A225408E,$564646A041594EB0,$1606456641466124,
           $7818B7FFC0C31161,$D8320B320931F680,$1DF5DBF3BA7EDC33,$44F87DB8D54CFE7F,$57C7D13F6AC906CF,$9E92BE0B743924A7,
           $B376D602F2F43132,$E7CD71DB39D7771F,$E3D34FB79E51D2D5,$8E3C7835AFF994F8,$57BFD6F90DAF1D39,$A68757D1F3996635,
           $ED351FA6195E0EDE,$5597877C867AB321,$577BCEE5D2C2E390,$F1D4AF6BCACBA4C8,$676FC99CC76DF35D,$A0A6B8D13C75F39D,
           $EAFAE7F83591C783,$E639BE77AF8D2720,$A1C456A3FBF25D9D,$DC0004DFFFE7DBE4
    Data.b $05,$75,$EA        
  EndDataSection ;}
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 10
  
  ;  1: Headings
  ;  2: Emphasis
  ;  3: Lists
  ;  4: URL and Links
  ;  5: Image
  ;  6: Table
  ;  7: Footnote
  ;  8: TaskLists
  ;  9: Subscript / Superscript
  ; 10: Emoji
  
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
      Text$ + "###### Heading level 6 #####"  + #LF$
    Case 2
      Text$ = "#### Emphasis ####" + #LF$ + #LF$
      Text$ + "I just love **bold text**." + #LF$
      Text$ + "Italicized text is the *cat's meow*."+ #LF$
      Text$ + "This text is __*really important*__.  "+ #LF$
      Text$ + "The world is ~~flat~~ round.  "+ #LF$ + #LF$
      Text$ + "#### Code ####" + #LF$ + #LF$
      Text$ + "At the command prompt, type ``nano``."+ #LF$
    Case 3
      Text$ = "#### Ordered List ####"  + #LF$
      Text$ + "1. First list item"+#LF$+"    2. Second list item"+#LF$+"    3. Third list item"+#LF$+"4. Fourth list item"+ #LF$
      Text$ + "-----" + #LF$
      Text$ + "#### Unordered List ####"  + #LF$
      Text$ + "- First list item" + #LF$ + "    - Second list item" + #LF$ + "    - Third list item" + #LF$ + "- Fourth list item" + #LF$ 
    Case 4
      Text$ = "#### Links & URLs ####" + #LF$ + #LF$
      Text$ + "URL: <https://www.markdownguide.org>  "+ #LF$
      Text$ + "EMail: <fake@example.com>  "+ #LF$
      Text$ + "Link:  [Duck Duck Go](https://duckduckgo.com "+#DQUOTE$+"My search engine!"+#DQUOTE$+")  "+ #LF$
    Case 5
      Text$ + " ![Programmer](Test.png " + #DQUOTE$ + "Programmer Image" + #DQUOTE$ + ")"
    Case 6
      Text$ = "#### Table ####"  + #LF$
      Text$ + "| Syntax    | Description |" + #LF$
      Text$ + "| :-------- | :---------: |" + #LF$
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
      Text$ = "#### SubScript / SuperScript ####" + #LF$  + #LF$
      Text$ + "Chemical formula for water: H~2~O  " + #LF$
      Text$ + "The area is 10m^2^  " + #LF$
    Case 10
      Text$ = "#### Emoji ####" + #LF$  + #LF$
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
    Default  
      Text$ = "### MarkDown ###" + #LF$ + #LF$
      Text$ + "> The gadget can display text formatted with the [MarkDown Syntax](https://www.markdownguide.org/basic-syntax/).  "+ #LF$
      Text$ + "> Markdown[^1] is a lightweight MarkDown language that you can use to add formatting elements to plaintext text documents."+ #LF$
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
              MarkDown::Export(#MarkDown, MarkDown::#HTML, "Export.htm", "PDF")
              RunProgram("Export.htm")
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 81
; FirstLine = 22
; Folding = wBCAAgARAIgFAACAAACAAAAgBAGAIAgkQAQ0
; EnableXP
; DPIAware