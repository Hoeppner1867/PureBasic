;/ ============================
;/ =     EditExModule.pbi     =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2022 Thorsten1867 (03/2019)
;/

; Last Update: 26.04.2022
;
; Bugfixes
;

;{ ===== MIT License =====
;
; Copyright (c) 2018 Thorsten Hoeppner
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


; ----- Description ------------------------------------------------------------------------------
; - WordWrap & Hyphenation          | Automatischer Zeilenumbruch & Silbentrennung (Ctrl-Minus)
; - Soft-Hyphen (Ctrl-Minus)        | 'Weiches' Trennzeichen bzw. bedingter Trennstrich
; - Automatic hiding of scrollbars  | Automatisches Ausblenden der Scrollbars
; - Automatic resizing              | Automatische Größenanpassung
; - Undo/Redo - function            | Undo/Redo - Funktion
; - Simple syntax highlighting      | Einfache Syntax-Hervorhebung (z.B. für Rechtschreibkontrolle)
; - Automatic spell checking        | automatische Rechtschreibkorrektur
; - Suggested corrections           | Korrekturvorschläge
; -------------------------------------------------------------------------------------------------


;{ -----ShortCuts -----
; Home         - Move cursor to start of row
; End          - Move cursor to end of row
; Shft-Del     - Cut & copy selected text to clipboard
; Shft-Insert  - Paste clipboard at cursor position
; Crtl-A       - Select all
; Crtl-C       - Copy selected text to clipboard
; Crtl-D       - Delete selected text
; Crtl-V       - Paste clipboard at cursor position
; Crtl-X       - Cut & copy selected text to clipboard
; Ctrl-Z       - Perform Undo
; Ctrl-End     - Move the cursor to the end of the last row
; Ctrl-Down    - Move the cursor to the beginning of the next paragraph
; Ctrl-Home    - Move the cursor to the beginning of the first row
; Crtl-Insert  - Copy selected text to clipboard 
; Crtl-Left    - Move the cursor to the beginning of the previous word
; Crtl-Minus   - Insert at cursor position a 'Soft-Hyphen'
; Crtl-Right   - Move the cursor to the beginning of the next word.
; Crtl-Up      - Move the cursor to the beginning of the previous paragraph.
;}


;{ _____ EditEx Commands _____ 

  ; EditEx::AddItem()                - Add text row at 'Position' (or #FirstRow / #LastRow)
  ; EditEx::AddToUserDictionary()    - Add a new word to user dictionary
  ; EditEx::AddWord()                - Add word to syntax highlighting
  ; EditEx::AttachPopup()            - Attach 'PopUpMenu' to gadget
  ; EditEx::ClearWords()             - Delete the list with the words for syntax highlighting
  ; EditEx::ClearUndo()              - Delete the list with Undo/Redo steps
  ; EditEx::Copy()                   - Copy selected text to clipboard
  ; EditEx::Cut()                    - Cut the selected text and copy it to the clipboard
  ; EditEx::CountItems()             - Returns number of rows
  ; EditEx::DeleteSelection()        - Delete selected text (Remove selection: #True/#False)
  ; EditEx::DeleteWord()             - Delete word from syntax highlighting
  ; EditEx::DisableSpellCheck()      - Disable auto spellcheck for this gadget
  ; EditEx::DisableSuggestions()     - Disable correction suggestions for this gadget
  ; EditEx::EnableAutoSpellCheck()   - Activate automatic spell checking (all gadgets)
  ; EditEx::FreeDictionary()         - Removes the loaded dictionary from memory
  ; EditEx::Free()                   - Free gadget (delete map element)
  ; EditEx::FreeGadgets()            - Free all gadgets of the window (delete map elements)
  ; EditEx::GetAttribute()           - Returns value of attribute (#ReadOnly/#WordWrap/#Hyphenation/#Border/#CtrlChars)
  ; EditEx::GetColor()               - Returns color of attribute (#FrontColor/#BackColor/#SpellCheckColor/#SelectionColor)
  ; EditEx::GetItemText()            - Returns text row at 'Position'
  ; EditEx::GetSelection()           - Returns selected text (Remove selection: #True/#False)
  ; EditEx::GetText()                - Returns all text rows seperated by 'Seperator'
  ; EditEx::GetSuggestions()         - Retruns a list of suggested corrections
  ; EditEx::InsertText()             - Insert text at cursor position (or replace selection)
  ; EditEx::IsRedo()                 - Checks if an redo is possible
  ; EditEx::IsSelected()             - Returns whether a selection exists
  ; EditEx::IsUndo()                 - Checks if an undo is possible
  ; EditEx::LoadDictionary()         - Load the dictionary for spell checking (all gadgets)
  ; EditEx::LoadHyphenationPattern() - Load hyphenation pattern for selected language (#Deutsch/#English/#French)
  ; EditEx::Redo()                   - Perform Redo
  ; EditEx::ReDraw()                 - Redraw the gadget
  ; EditEx::RemoveGadget()           - Releases the used memory and deletes the cursor thread
  ; EditEx::Paste()                  - Inserting text from the clipboard
  ; EditEx::SaveUserDictionary()     - Save user dictionary
  ; EditEx::SetAutoResizeFlags()     - [#MoveX|#MoveY|#Width|#Height]
  ; EditEx::SetAttribute()           - Enable/Disable attribute (#ReadOnly/#WordWrap/#Hyphenation/#Border/#CtrlChars)
  ; EditEx::SetColor()               - Set or change color of attribute (#FrontColor/#BackColor/#SpellCheckColor/#SelectionColor)
  ; EditEx::SetFont()                - Set or change font FontID(#Font)
  ; EditEx::SetFlags()               - Set gadget flags
  ; EditEx::SetItemText()            - Replace text row at 'Position'
  ; EditEx::SetSyntaxHighlight()     - [#CaseSensitiv/#NoCase]
  ; EditEx::SetText()                - Set or replace all text rows
  ; EditEx::SetTextWidth()           - Set text width for wordwrap and hyphenation (pt/px/in/cm/mm)
  ; EditEx::SetUndoSteps()           - Set max. steps for undo
  ; EditEx::SpellCheck()             - Checks the spelling of the word (returns: #True/#False)
  ; EditEx::SpellChecking()          - Check the spelling in the editor gadget (#Highlight/#WrongWords)
  ; EditEx::Undo()                   - Perform Undo
  ; -----------------------
  ; EditEx::Gadget()                 - Creates an editor gadget
  ; -----------------------
  
;} ===========================

; XIncludeFile "ModuleEx.pbi"

DeclareModule EditEx
  
  #Version  = 22042601
  #ModuleEx = 20010800
  
  ;- ============================================================================
  ;-   DeclareModule - Constants
  ;- ============================================================================
  
  #Enable_Hyphenation     = #True  ; Requires file with hyphenation patterns => LoadHyphenationPattern()
  #Enable_SpellChecking   = #True  ; Requires file with dictionary           => LoadDictionary()
  #Enable_SyntaxHighlight = #True
  #Enable_UndoRedo        = #True 
  
  ;{ _____ ScrollBar Constants _____
  EnumerationBinary         ; ScrollBar
		#ScrollBar_Border       ; Draw gadget border
		#ScrollBar_ButtonBorder ; Draw button borders
		#ScrollBar_ThumbBorder  ; Draw thumb border
		#ScrollBar_DragLines    ; Draw drag lines
	EndEnumeration
	
	Enumeration 1             ; ScrollBar Buttons
	  #ScrollBar_Up
	  #ScrollBar_Down
	  #ScrollBar_Left
	  #ScrollBar_Right
	EndEnumeration
	
	#ScrollBar_Default   = #False
	#ScrollBar_Frame     = #ScrollBar_Border
	#ScrollBar_DragPoint = #ScrollBar_ButtonBorder|#ScrollBar_ThumbBorder|#ScrollBar_DragLines|#ScrollBar_Border 
	;}  
	
  ;{ _____ Constants _____
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #NL$ = #CRLF$
    CompilerCase #PB_OS_MacOS
      #NL$ = #LF$
    CompilerCase #PB_OS_Linux
      #NL$ = #LF$
  CompilerEndSelect
  
  Enumeration 1     ;{ Language
    #Deutsch
    #English
    #French
  EndEnumeration ;}
  
  EnumerationBinary ;{ Gadget Flags
    #ReadOnly
    #ReadWrite
    #AutoResize
    #WordWrap
    #Hyphenation
    #MaxTextWidth
    #Borderless
    #CtrlChars
    #AutoSpellCheck
    #Suggestions
    #mm
    #cm
    #inch
    #ScrollBar_Horizontal
    #ScrollBar_Vertical
    #UseExistingCanvas
    #Corner
    #ScrollBar
  EndEnumeration ;}
  
  EnumerationBinary ;{ SpellCheck
    #Highlight
    #WrongWords
  EndEnumeration ;}
  
  Enumeration 1     ;{ Color 
    #FrontColor
    #BackColor
    #SpellCheckColor
    #SelectTextColor
    #SelectionColor
    #ScrollBar_FrontColor
    #ScrollBar_BackColor 
    #ScrollBar_BorderColor
    #ScrollBar_ButtonColor
    #ScrollBar_ThumbColor
  EndEnumeration ;}

  EnumerationBinary ;{ SyntaxHighlight
    #CaseSensitiv ; must be 1
    #NoCase       ; must be 2
    #Punctation
    #Brackets
    #QuotationMarks
    #WordOnly
    #Parse
  EndEnumeration ;}
  
  EnumerationBinary ;{ AutoResize
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration ;}
  
  ; --- UTF-8 ---
  #Space$      = "·"
  #SoftHyphen$ = Chr(173)
  #Paragraph$  = Chr(182)
  #Hyphen$     = Chr(8722)
  #BlockChar$  = "·/·"
  
  ; --- AddItem ---
  #FirstRow =  0
  #LastRow  = -1
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Gadget        = ModuleEx::#Event_Gadget
    #Event_Cursor        = ModuleEx::#Event_Cursor
    #Event_Theme         = ModuleEx::#Event_Theme
    #Event_Timer         = ModuleEx::#Event_Timer
    
    #EventType_Focus     = ModuleEx::#EventType_Focus
    #EventType_LostFocus = ModuleEx::#EventType_LostFocus
    #EventType_Change    = ModuleEx::#EventType_Change
    #EventType_NewLine   = ModuleEx::#EventType_NewLine
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
      #Event_Gadget
      #Event_Timer
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Change
      #EventType_NewLine
      #EventType_Focus
      #EventType_LostFocus
    EndEnumeration
    
  CompilerEndIf
  
  
  CompilerIf #Enable_Hyphenation
    
    #PAT_Deutsch = "german.pat"
    #PAT_English = "english.pat"
    #PAT_French  = "french.pat"
    
  CompilerEndIf
  
  CompilerIf #Enable_SpellChecking
    
    #DIC_Deutsch = "german.dic"
    #DIC_English = "english.dic"
    #DIC_French  = "french.dic"
    
    Global NewList WrongWords.s()  ; <= SpellChecking(GNum, #WrongWords)
    
  CompilerEndIf
  ;}
  
  ;- ============================================================================
  ;-   DeclareModule
  ;- ============================================================================
  
  CompilerIf #Enable_SyntaxHighlight
    Declare   AddWord(GNum.i, Word.s, Color.i)          ; Add word to syntax highlighting
    Declare   ClearWords(GNum.i)                        ; Delete the list with the words for syntax highlighting
    Declare   DeleteWord(GNum.i, Word.s)                ; Delete word from syntax highlighting
    Declare   SetSyntaxHighlight(GNum.i, Flag.i)        ; Enable syntax highlighting (#CaseSensitiv/#NoCase)
  CompilerEndIf
  
  CompilerIf #Enable_Hyphenation
    Declare LoadHyphenationPattern(File.s=#PAT_Deutsch)        ; Load hyphenation pattern for selected language (ALL gadgets)
  CompilerEndIf
  
  CompilerIf #Enable_SpellChecking
    Declare   LoadDictionary(DicFile.s, AddDicFile.s="")           ; Load the dictionary for spell checking (all gadgets)
    Declare   EnableAutoSpellCheck(State.i=#True)                  ; Activate automatic spell checking (all gadgets)
    Declare   DisableSpellCheck(GNum.i, State.i=#True)             ; Disable autospellcheck for this gadget
    Declare   DisableSuggestions(GNum.i, State.i=#True)            ; Disable correction suggestions for this gadget
    Declare   SpellCheck(Word.s)                                   ; Checks the spelling of the word (returns: #True/#False)
    Declare.i SpellCheckText(Text.s, List Mistake.s())             ; Checks the spelling of the text (returns: number of mistakes)
    Declare   SpellChecking(GNum.i, Flag.i=#Highlight)             ; Check the spelling in the editor gadget
    Declare   GetSuggestions(GNum.i, Word.s, List Suggestions.s()) ; Returns list with correction suggestions
    Declare   AddToUserDictionary(GNum.i, Word.s)                  ; Add a new word to user dictionary
    Declare   SaveUserDictionary()                                 ; Save user dictionary
    Declare   FreeDictionary()                                     ; Removes the loaded dictionary from memory
  CompilerEndIf
  
  CompilerIf #Enable_UndoRedo
    
    Declare ClearUndo(GNum.i)
    Declare SetUndoSteps(GNum.i, MaxSteps.i)
    Declare Undo(GNum.i)
    Declare Redo(GNum.i)
    Declare IsUndo(GNum.i)
    Declare IsRedo(GNum.i)
    
  CompilerEndIf
  
  Declare   AddItem(GNum.i, Position.i, Text.s)
  Declare   AttachPopup(GNum.i, PopUpMenu.i)
  Declare   Copy(GNum.i)
  Declare   Cut(GNum.i)
  Declare.i CountItems(GNum.i)
  Declare   DeleteSelection(GNum.i, Remove.i=#True)
  Declare   Disable(GNum.i, State.i=#True)
  Declare   Free(GNum.i)
  Declare   FreeGadgets(WindowNum.i)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.i GetColor(GNum.i, Attribute.i)
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare.s GetItemText(GNum.i, Position.i)
  Declare.s GetSelection(GNum.i, Remove.i=#True)
  Declare.s GetText(GNum.i, Flags.i=#False)
  Declare   InsertText(GNum.i, Text.s)
  Declare.i IsSelected(GNum.i) 
  Declare   Hide(GNum.i, State.i=#True)
  Declare   Paste(GNum.i)
  Declare   ReDraw(GNum.i)
  Declare   ResetSelection(GNum.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, Attribute.i, Color.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFlags(GNum.i, Flags.i)
  Declare   SetFont(GNum.i, FontID.i)
  Declare   SetID(GNum.i, String.s)
  Declare   SetItemText(GNum.i, Position.i, Text.s)
  Declare   SetText(GNum.i, Text.s)
  Declare   SetTextWidth(GNum.i, Value.f, unit.s="px")
  Declare.s WrapText(Text.s, Width.i, Font.i, Flags.i=#WordWrap)
  
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  
EndDeclareModule

Module EditEx
  
  EnableExplicit
  
  UseCRC32Fingerprint()
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================  
  
  ;- _____ OS specific definitions _____
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #Scroll_Width = 17
    CompilerCase #PB_OS_MacOS
      #Scroll_Width = 18
    CompilerCase #PB_OS_Linux
      #Scroll_Width = 18
  CompilerEndSelect
  
  ;{ _____ ScrollBar Constants _____
  #ScrollBar_ButtonSize = 18

  #ScrollBar_Timer      = 800
	#ScrollBar_TimerDelay = 1
	
	Enumeration 1             ; ScrollBar Buttons
	  #ScrollBar_Forwards
	  #ScrollBar_Backwards
	  #ScrollBar_Focus
	  #ScrollBar_Click
	EndEnumeration
	;}
  
  ;{ _____ Constants _____
  #CursorFrequency = 600

  Enumeration Cursor 1
    #Cursor_Up
    #Cursor_Down
  EndEnumeration
  
  Enumeration MouseMove
    #Mouse_Move   ; just changing the cursor ...
    #Mouse_Select ; selecting
  EndEnumeration
  
  Enumeration Selection
    #NoSelection
    #StartSelection
    #Selected
  EndEnumeration
  
  Enumeration ScrollBar 1
    #Vertical
    #Horizontal
  EndEnumeration
  
  #CurrentCursor = -1
  #Scroll_Max    = 10000
  
  #PB_Shortcut_Hyphen = 189
  ;}
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================   
  
  ;{ _____ ScrollBar Structures _____  
  Structure ScrollBar_Timer_Thread_Structure ;{ Thread\...
    Num.i
    Active.i
    Exit.i
  EndStructure ;}
  Global TimerThread.ScrollBar_Timer_Thread_Structure
  
  Structure ScrollBar_Button_Structure       ;{ ...\ScrollBar\Item()\Buttons\Forwards\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollBar_Buttons_Structure      ;{ ...\ScrollBar\Item()\Buttons\...
	  Backwards.ScrollBar_Button_Structure
	  Forwards.ScrollBar_Button_Structure
	EndStructure ;}
	
	Structure ScrollBar_Thumb_Structure        ;{ ...\ScrollBar\Item()\Thumb\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  Factor.f
	  Size.i
	  State.i
	EndStructure ;}
	
  Structure ScrollBar_Area_Structure         ;{ ...\ScrollBar\Item()\Area\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	EndStructure ;}
  
	Structure ScrollBar_Item_Structure         ;{ ...\ScrollBar\Item()\...
	  Num.i
	  
	  Type.i
    
    Pos.i
	  minPos.i
	  maxPos.i
	  Ratio.f
	  
		Minimum.i
		Maximum.i
		PageLength.i
		
		X.i
		Y.i
		Width.i
		Height.i
		
		Timer.i
	  TimerDelay.i
	  
	  Cursor.i
	  
	  Disable.i
		Hide.i

		Thumb.ScrollBar_Thumb_Structure
		Buttons.ScrollBar_Buttons_Structure
		Area.ScrollBar_Area_Structure

	EndStructure ;}  
	
	Structure ScrollBar_Color_Structure        ;{ ...\ScrollBar\Color\...
		Front.i
		Back.i
		Border.i
		Button.i
		Focus.i
		Gadget.i
		ScrollBar.i
		DisableFront.i
		DisableBack.i
	EndStructure  ;}
	
	Structure ScrollBar_Structure              ;{ ...\ScrollBar\...

	  Adjust.i
	  Radius.i

	  Flags.i
	  
	  Color.ScrollBar_Color_Structure

    Map Item.ScrollBar_Item_Structure()
  EndStructure ;}
  ;}
  
  ;{ _____ Structures _____
  Structure Cursor_Thread_Structure ;{ Cursor-Thread
    Num.i
    Active.i
    Exit.i
  EndStructure ;}
  Global Thread.Cursor_Thread_Structure
  
  CompilerIf #Enable_Hyphenation    
    
    Structure HyphenStructure       ;{ Hyphenation
      Chars.s
      Pattern.s
    EndStructure ;}
    
    Structure Hyphenation_Structure
      Path.s
      List Item.HyphenStructure()
      Flags.i
    EndStructure
    Global Hypenation.Hyphenation_Structure
    
  CompilerEndIf
  
  CompilerIf #Enable_SpellChecking
    
    Structure Dictionary_Structure
      Stem.s
      Endings.s
      UCase.i
    EndStructure
    
    Structure Words_Structure
      checked.i
      misspelled.i
    EndStructure
    
    Structure SpellCheck_Structure
      Path.s
      Button.s
      ToolTip.s
      List Dictionary.Dictionary_Structure()
      List UserDic.Dictionary_Structure()
      Map  Words.Words_Structure()
      Flags.i
    EndStructure
    Global SpellCheck.SpellCheck_Structure
    
  CompilerEndIf
  
  CompilerIf #Enable_UndoRedo
    
    Structure Redo_Structure
      CursorPos.i
      Text.s
    EndStructure
    
    Structure Undo_Diff_Structure    ;{ EditEx()\Undo\Item()\DiffText()\..
      CursorPos.i
      Text.s
      Length.i
      CRC32.s
    EndStructure ;}
    
    Structure Undo_Item_Structure    ;{ EditEx()\Undo\Item()\...
      CursorPos.i
      Text_1.s
      Length_1.i
      CRC32_1.s
      Text_2.s
      Length_2.i
      CRC32_2.s
      List DiffText.Undo_Diff_Structure()
    EndStructure ;}
    
    Structure Undo_Structure         ;{ EditEx()\Undo\...
      CursorPos.i
      Redo.Redo_Structure
      List Item.Undo_Item_Structure()
      MaxSteps.i
    EndStructure ;}
    
  CompilerEndIf
  
  Structure Selection_Structure
    X.i
    String.s
    State.i
  EndStructure
  
  Structure Highlight_Structure
    X.i
    String.s
    Color.i
    Check.i
  EndStructure
  
  Structure Select_Structure         ;{ EditEx()\Selection
    Pos1.i
    Pos2.i
    Flag.i
  EndStructure ;}
  
  Structure Paragraph_Structure      ;{ ...\Paragraph\...
    Pos.i
    Len.i
  EndStructure ;}
 
  Structure EditEx_Mistake_Structure ;{ EditEx()\Mistake\...
    List Pos.i()
    Len.i
  EndStructure ;}
  
  Structure EditEx_Visible_Structure ;{ EditEx()\Visible\...
    RowOffset.i
    PosOffset.i
    CtrlChars.i
    Width.i
    Height.i
    CharW.i
    WordList.i
  EndStructure ;}

  Structure EditEx_Text_Structure    ;{ EditEx()\Text\...
    Width.i       ; maximum width for hyphenation
    Height.i      ; text height of rows
    MaxRowWidth.i ; maximum length of rows 
    Len.i
  EndStructure ;}
  
  Structure EditEx_Mouse_Structure   ;{ EditEx()\Mouse\...
    DeltaX.i ; will be used to relativise absolute X,Y
    DeltaY.i
    Cursor.i
    LeftButton.i
    Status.i
  EndStructure ;}

  Structure EditEx_Cursor_Structure  ;{ EditEx()\Cursor\...
    ; 0: "|abc" / 1: "a|bc" / 2: "ab|c"  / 3: "abc|"
    Pos.i
    Row.i
    X.i
    Y.i
    Height.i
    BackChar.s
    FrontColor.i
    BackColor.i
    LastX.i
    LastPos.i
    Pause.i
    State.i
  EndStructure ;}
  
  Structure EditEx_Color_Structure   ;{ EditEx()\Color\...
    Front.i
    Back.i
    Cursor.i
    Gadget.i
    SpellCheck.i
    SyntaxHighlight.i
    Highlight.i
    HighlightText.i
    ReadOnly.i
    ScrollBar.i
    Border.i
    DisableFront.i
    DisableBack.i
  EndStructure ;}
  
  Structure EditEx_Window_Structure  ;{ EditEx()\Window\...
    Num.i
    Width.i
    Height.i
  EndStructure ;}
  
  Structure EditEx_Size_Structure    ;{ EditEx()\Size\...
    X.i
    Y.i
    Width.i
    Height.i
    PaddingX.i
    PaddingY.i
    Flags.i
  EndStructure ;}
  
  Structure EditEx_Row_Structure     ;{ EditEx()\Row()\...
    X.i
    Y.i
    Pos.i
    Len.i
    Width.i
    WordWrap.s
    Selection.Selection_Structure
    List Highlight.Highlight_Structure()
  EndStructure ;}
  
  ; ----- EditEx - Structure -----
  
  Structure EditEx_Structure         ;{ EditEx(#gadget)\...
    CanvasNum.i
    ListNum.i
    ButtonNum.i
    WinNum.i
    PopupMenu.i
    
    Quad.q
    ID.s
    FontID.i
    
    SyntaxHighlight.i
    
    Text$
    
    Disable.i
    Hide.i
    
    Flags.i
    ; ----------------
    Window.EditEx_Window_Structure
    Visible.EditEx_Visible_Structure
    Color.EditEx_Color_Structure
    Text.EditEx_Text_Structure
    Mouse.EditEx_Mouse_Structure
    ScrollBar.ScrollBar_Structure
    Size.EditEx_Size_Structure
    Selection.Select_Structure
    Cursor.EditEx_Cursor_Structure
    CompilerIf #Enable_UndoRedo
      Undo.Undo_Structure
    CompilerEndIf
    ; ---------------
    Map  Syntax.i()
    Map  Mistake.i()
    List Suggestions.s()
    List Row.EditEx_Row_Structure()
  EndStructure ;}
  Global NewMap EditEx.EditEx_Structure()

  ;} ------------------------------
  
  ;- ============================================================================
  ;-   Module - Internal   [ -> Selected EditEx() map element required ]
  ;- ============================================================================
  
  Declare   Draw_()
  Declare   ReDraw_(OffSet.i=#True)
  Declare   CalcRows_()
  Declare.s DeleteStringPart(String.s, Position.i, Length.i=1)
  Declare.i WordStart_(String.s, Position.i, Flags.i=#WordOnly)
  Declare   DrawScrollBar_(ScrollBar.s)
  
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

  ;- ----- Strings -----
 
  Procedure.s StringSegment(String.s, Pos1.i, Pos2.i=#PB_Ignore)
    ; Return String from Pos1 to Pos2 
    Define.i Length
    
    Length = Pos2 - Pos1
    
    If Pos2 = #PB_Ignore
      ProcedureReturn Mid(String, Pos1 , Len(String) - Pos1)
    Else
      ProcedureReturn Mid(String, Pos1, Pos2 - Pos1)
    EndIf
    
  EndProcedure 

  Procedure.s DeleteStringPart(String.s, Position.i, Length.i=1)
    ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf
    
    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure
  
  ; ----- Text / TextArea -----
  
  Procedure   IsTextArea_(X.i, Y.i)
  
    If X <= dpiX(EditEx()\Size\PaddingX) Or X > dpiX(EditEx()\Size\PaddingX + EditEx()\Visible\Width)
      ProcedureReturn #False
    ElseIf Y <= dpiY(EditEx()\Size\PaddingY) Or Y > dpiY(EditEx()\Size\PaddingY + EditEx()\Visible\Height)
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure

  Procedure.i Paragraph_(Direction.i)
    ; cursor pos of previeous/next paragraph
    Define.i p, Pos, lfPos, Count

    Pos = 1

    Count = CountString(EditEx()\Text$, #LF$) + 1
    For p=1 To Count
      
      lfPos = FindString(EditEx()\Text$, #LF$, Pos + 1)
      If lfPos = 0 : lfPos = EditEx()\Text\Len : EndIf

      Select Direction
        Case #Cursor_Up
          If EditEx()\Cursor\Pos > Pos And EditEx()\Cursor\Pos <= lfPos + 1
            ProcedureReturn Pos
          EndIf  
        Case #Cursor_Down  
          If EditEx()\Cursor\Pos >= Pos And EditEx()\Cursor\Pos <= lfPos
            ProcedureReturn lfPos + 1
          EndIf  
      EndSelect 
      
      Pos = lfPos + 1
      
    Next
    
    ProcedureReturn Pos
  EndProcedure
  
  Procedure.i PageRows_(ScrollBar = #True)
    ; Number of visible rows
    Define.i Rows
    
    If EditEx()\Text\Height
      If ScrollBar
        ProcedureReturn EditEx()\Visible\Height / EditEx()\Text\Height
      Else
        ProcedureReturn (GadgetHeight(EditEx()\CanvasNum) - (EditEx()\Size\PaddingY * 2)) / EditEx()\Text\Height
      EndIf 
    EndIf

  EndProcedure

  ;- ----- Mouse -----
  
  Procedure   ChangeMouseCursor_(GNum.i, CursorX.i, Y.i)
    
    If IsTextArea_(CursorX, Y)
      If EditEx()\Mouse\Cursor <> #PB_Cursor_IBeam
        SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
        EditEx()\Mouse\Cursor = #PB_Cursor_IBeam
      EndIf
    Else
      If EditEx()\Mouse\Cursor <> #PB_Cursor_Default
        SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
        EditEx()\Mouse\Cursor = #PB_Cursor_Default
      EndIf
    EndIf
    
  EndProcedure  

  ;- ----- Cursor -----
    
  Procedure.i CursorUpDown_(Direction.i)
    ; Change cursor row (up/down)
    Define.i Row, c, CursorPos, PosX, PosY
    
    Select Direction
      Case #Cursor_Up
        Row = EditEx()\Cursor\Row - 1
      Case #Cursor_Down
        Row = EditEx()\Cursor\Row + 1
    EndSelect
    
    If Row >= 0 And Row <= ListSize(EditEx()\Row())

      If SelectElement(EditEx()\Row(), Row)
        
        PosX = EditEx()\Row()\X - dpiX(EditEx()\Visible\PosOffset)
        PosY = EditEx()\Row()\Y

        If StartDrawing(CanvasOutput(EditEx()\CanvasNum))
          
          If EditEx()\Cursor\X < PosX + EditEx()\Row()\Width
  
            If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf
            
            For c=0 To EditEx()\Row()\Len - 1
              If TextWidth(Mid(EditEx()\Text$, EditEx()\Row()\Pos, c + 1)) >= EditEx()\Cursor\X
                EditEx()\Cursor\Pos = EditEx()\Row()\Pos + c
                Break
              EndIf  
            Next
  
          Else
            
            If EditEx()\Row()\Len
              EditEx()\Cursor\Pos = EditEx()\Row()\Pos + EditEx()\Row()\Len - 1
            Else  
              EditEx()\Cursor\Pos = EditEx()\Row()\Pos
            EndIf
          
          EndIf

          StopDrawing()
        EndIf
      
      EndIf
      
    EndIf
    
    ReDraw_()    
    
    ProcedureReturn CursorPos
  EndProcedure 

  Procedure.i CursorPos_(CursorX.i, Y.i, Change.i=#True)
    ; Determine cursor position based on X/Y position
    Define.i PosX, PosY, c, CursorPos, RowOffsetH
    
    RowOffsetH = EditEx()\Visible\RowOffset * EditEx()\Text\Height
    
    ForEach EditEx()\Row()
      
      PosX = EditEx()\Row()\X
      PosY = EditEx()\Row()\Y - RowOffsetH

      If Y >= PosY And Y <= PosY + EditEx()\Text\Height

        If StartDrawing(CanvasOutput(EditEx()\CanvasNum)) 
        
          If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf
          
          For c=0 To EditEx()\Row()\Len - 1
            
            If TextWidth(Mid(EditEx()\Text$, EditEx()\Row()\Pos, c + 1)) > CursorX + dpiX(EditEx()\Visible\PosOffset)
              
              CursorPos = EditEx()\Row()\Pos + c
              
              If Change
                EditEx()\Cursor\X   = EditEx()\Row()\X + TextWidth(RTrim(Mid(EditEx()\Text$, EditEx()\Row()\Pos, c), #LF$)) - dpiX(EditEx()\Visible\PosOffset)
                EditEx()\Cursor\Y   = PosY
                EditEx()\Cursor\Pos = CursorPos
                EditEx()\Cursor\Row = ListIndex(EditEx()\Row())
                EditEx()\Cursor\BackChar = Mid(EditEx()\Text$, EditEx()\Cursor\Pos, 1)
              EndIf
              
              Break
            EndIf  
            
          Next
          
          If CursorPos = 0
            
            If EditEx()\Row()\Len
              CursorPos = EditEx()\Row()\Pos + EditEx()\Row()\Len
              If Mid(EditEx()\Text$, CursorPos - 1, 1) = #LF$ : CursorPos - 1 : EndIf 
            Else
              CursorPos = EditEx()\Row()\Pos
            EndIf
            
            If Change
              EditEx()\Cursor\X   = PosX + TextWidth(RTrim(StringSegment(EditEx()\Text$, EditEx()\Row()\Pos, CursorPos), #LF$))
              EditEx()\Cursor\Y   = PosY
              EditEx()\Cursor\Pos = CursorPos
              EditEx()\Cursor\Row = ListIndex(EditEx()\Row())
              EditEx()\Cursor\BackChar = ""
            EndIf  
            
          EndIf  
          
          StopDrawing()
        EndIf

        Break
      EndIf
      
    Next
    
    ProcedureReturn CursorPos
  EndProcedure
  
  ;- ----- Scrolling -----
  
  Procedure.i CalcScrollBarThumb_(ScrollBar.s, Reset.i=#True)
	  Define.i Size, Range, HRange
	  
	  If FindMapElement(EditEx()\ScrollBar\Item(), ScrollBar)
	    
  	  EditEx()\ScrollBar\Item()\minPos   = EditEx()\ScrollBar\Item()\Minimum
  	  EditEx()\ScrollBar\Item()\maxPos   = EditEx()\ScrollBar\Item()\Maximum - EditEx()\ScrollBar\Item()\PageLength + 1
  	  EditEx()\ScrollBar\Item()\Ratio    = EditEx()\ScrollBar\Item()\PageLength / EditEx()\ScrollBar\Item()\Maximum
  	  If Reset : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\Minimum : EndIf 
  	  
  	  Range = EditEx()\ScrollBar\Item()\maxPos - EditEx()\ScrollBar\Item()\minPos
  	  
  	  If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	    EditEx()\ScrollBar\Item()\Area\X       = EditEx()\ScrollBar\Item()\X
    	  EditEx()\ScrollBar\Item()\Area\Y       = EditEx()\ScrollBar\Item()\Y + dpiY(#ScrollBar_ButtonSize) + dpiY(1)
    	  EditEx()\ScrollBar\Item()\Area\Width   = EditEx()\ScrollBar\Item()\Width
    	  EditEx()\ScrollBar\Item()\Area\Height  = EditEx()\ScrollBar\Item()\Height - dpiY(EditEx()\ScrollBar\Adjust) - dpiY(#ScrollBar_ButtonSize * 2) - dpiY(2)
    	  EditEx()\ScrollBar\Item()\Thumb\Y      = EditEx()\ScrollBar\Item()\Area\Y
    	  EditEx()\ScrollBar\Item()\Thumb\Size   = Round(EditEx()\ScrollBar\Item()\Area\Height * EditEx()\ScrollBar\Item()\Ratio, #PB_Round_Down)
    	  EditEx()\ScrollBar\Item()\Thumb\Factor = (EditEx()\ScrollBar\Item()\Area\Height - EditEx()\ScrollBar\Item()\Thumb\Size) / Range
  	  Else
  	    EditEx()\ScrollBar\Item()\Area\X       = EditEx()\ScrollBar\Item()\X + dpiX(#ScrollBar_ButtonSize) + dpiX(1)
    	  EditEx()\ScrollBar\Item()\Area\Y       = EditEx()\ScrollBar\Item()\Y
    	  EditEx()\ScrollBar\Item()\Area\Width   = EditEx()\ScrollBar\Item()\Width - dpiX(EditEx()\ScrollBar\Adjust) - dpiX(#ScrollBar_ButtonSize * 2) - dpiX(2)
    	  EditEx()\ScrollBar\Item()\Area\Height  = EditEx()\ScrollBar\Item()\Height
    	  EditEx()\ScrollBar\Item()\Thumb\X      = EditEx()\ScrollBar\Item()\Area\X
    	  EditEx()\ScrollBar\Item()\Thumb\Size   = Round(EditEx()\ScrollBar\Item()\Area\Width * EditEx()\ScrollBar\Item()\Ratio, #PB_Round_Down)
    	  EditEx()\ScrollBar\Item()\Thumb\Factor = (EditEx()\ScrollBar\Item()\Area\Width - EditEx()\ScrollBar\Item()\Thumb\Size) / Range
  	  EndIf  
  	  
  	  If EditEx()\ScrollBar\Item()\Thumb\Size < 0 : EditEx()\ScrollBar\Item()\Thumb\Size = 0 : EndIf 
  	  
	  EndIf   

	EndProcedure  
  
  Procedure.i GetScrollStateMax_(Flag.i)
    ; Maximum state of the scrollbar
    
    Select  Flag
      Case #Vertical
        ProcedureReturn ListSize(EditEx()\Row()) - PageRows_()
      Case #Horizontal
        ProcedureReturn EditEx()\Text\maxRowWidth - EditEx()\Visible\Width + 1
    EndSelect
    
  EndProcedure
  
  Procedure.i AdjustScrolls_()
    ; hide/show scrollbars
    Define.i Rows, Changed
    Define.i HScroll, VScroll, Changed

    If EditEx()\Flags & #ScrollBar_Horizontal : HScroll = #True : EndIf
    If EditEx()\Flags & #ScrollBar_Vertical   : VScroll = #True : EndIf
    
    If EditEx()\Text\maxRowWidth <= dpiX(GadgetWidth(EditEx()\CanvasNum)) - dpiX(EditEx()\Size\PaddingX * 2)
      HScroll = #False
    EndIf
    
    Rows = ListSize(EditEx()\Row())
    If Rows <= PageRows_(#False)
      VScroll = #False
    EndIf
    
    If VScroll And HScroll ;{ Both scrollbars necessary
      EditEx()\Visible\Width  = GadgetWidth(EditEx()\CanvasNum)  - (EditEx()\Size\PaddingX * 2) - #Scroll_Width - 1
      EditEx()\Visible\Height = GadgetHeight(EditEx()\CanvasNum) - (EditEx()\Size\PaddingY * 2) - #Scroll_Width - 1
      ;}
    ElseIf HScroll         ;{ Horizontal scrollbar necessary
      EditEx()\Visible\Height = GadgetHeight(EditEx()\CanvasNum) - (EditEx()\Size\PaddingY * 2) - #Scroll_Width - 1
      If EditEx()\Flags & #ScrollBar_Vertical And Rows > PageRows_()
        EditEx()\Visible\Width = GadgetWidth(EditEx()\CanvasNum) - (EditEx()\Size\PaddingX * 2) - #Scroll_Width - 1
        VScroll = #True 
      Else
        EditEx()\Visible\Width = GadgetWidth(EditEx()\CanvasNum) - (EditEx()\Size\PaddingX * 2)
      EndIf ;}
    ElseIf VScroll         ;{ Vertical scrollbar necessary
      EditEx()\Visible\Width = GadgetWidth(EditEx()\CanvasNum)  - (EditEx()\Size\PaddingX * 2) - #Scroll_Width - 1
      If EditEx()\Flags & #ScrollBar_Horizontal And EditEx()\Text\maxRowWidth > EditEx()\Visible\Width
        EditEx()\Visible\Height = GadgetHeight(EditEx()\CanvasNum) - (EditEx()\Size\PaddingY * 2) - #Scroll_Width - 1
        HScroll = #True
      Else
        EditEx()\Visible\Height = GadgetHeight(EditEx()\CanvasNum) - (EditEx()\Size\PaddingY * 2)
      EndIf ;}
    Else                   ;{ No scrollbars necessary
      EditEx()\Visible\Width  = GadgetWidth(EditEx()\CanvasNum)  - (EditEx()\Size\PaddingX * 2) - 1
      EditEx()\Visible\Height = GadgetHeight(EditEx()\CanvasNum) - (EditEx()\Size\PaddingY * 2) - 1
      ;}
    EndIf
    
    If FindMapElement(EditEx()\ScrollBar\Item(), "HScroll") ;{ Horizontal Scrollbar
      
      ;EditEx()\ScrollBar\Item()\maxPos = GetScrollStateMax_(#Horizontal)

      If EditEx()\ScrollBar\Item()\maxPos <= #Scroll_Max
        
        If HScroll And EditEx()\ScrollBar\Item()\Hide
          EditEx()\ScrollBar\Item()\Hide = #False
          CalcScrollBarThumb_("HScroll")
          Changed = #True
        ElseIf Not HScroll  And Not EditEx()\ScrollBar\Item()\Hide
          EditEx()\ScrollBar\Item()\Hide = #True
          EditEx()\Visible\PosOffset = 0
          Changed = #True
        EndIf
        
        EditEx()\ScrollBar\Item()\Maximum    = EditEx()\Text\maxRowWidth
        EditEx()\ScrollBar\Item()\PageLength = EditEx()\Visible\Width

      EndIf
      ;}
    EndIf
    
    If FindMapElement(EditEx()\ScrollBar\Item(), "VScroll") ;{ Vertical Scrollbar
      
      ;EditEx()\ScrollBar\Item()\maxPos = GetScrollStateMax_(#Vertical)
      
      If EditEx()\ScrollBar\Item()\maxPos <= #Scroll_Max
        
        If VScroll And EditEx()\ScrollBar\Item()\Hide
          EditEx()\ScrollBar\Item()\Hide = #False
          CalcScrollBarThumb_("VScroll")
          Changed = #True
        ElseIf VScroll = #False And EditEx()\ScrollBar\Item("VScroll")\Hide = #False
          EditEx()\ScrollBar\Item()\Hide = #True
          EditEx()\Visible\RowOffset = 0
          Changed = #True
        EndIf
        
        EditEx()\ScrollBar\Item()\Maximum    = Rows
        EditEx()\ScrollBar\Item()\PageLength = PageRows_() + 1
        
      EndIf 
      ;}
    EndIf
    
    If VScroll : EditEx()\ScrollBar\Item("VScroll")\Hide = #False :  Else : EditEx()\ScrollBar\Item("VScroll")\Hide = #True : EndIf 
    If HScroll : EditEx()\ScrollBar\Item("HScroll")\Hide = #False :  Else : EditEx()\ScrollBar\Item("HScroll")\Hide = #True : EndIf
    
    If VScroll And HScroll
      EditEx()\ScrollBar\Adjust = #Scroll_Width
    Else  
      EditEx()\ScrollBar\Adjust = 0
    EndIf 

    If Changed : CalcRows_() : EndIf
    
    ProcedureReturn Changed
  EndProcedure

	Procedure.i GetSteps_(Cursor.i)
	  Define.i Steps
	  
	  Steps = (Cursor - EditEx()\ScrollBar\Item()\Cursor) / EditEx()\ScrollBar\Item()\Thumb\Factor
	  
	  If Steps = 0
	    If Cursor < EditEx()\ScrollBar\Item()\Cursor
	      Steps = -1
	    Else
	      Steps = 1
	    EndIf
	  EndIf
	  
	  ProcedureReturn Steps
	EndProcedure
	
  ;- ----- Selection -----
  
  Procedure   RemoveSelection_()
    ; Remove & Reset Selection 
    
    If EditEx()\Selection\Flag = #Selected
      
      EditEx()\Selection\Flag = #NoSelection
      EditEx()\Selection\Pos1 = #PB_Default
      EditEx()\Selection\Pos2 = #PB_Default
      EditEx()\Mouse\Status   = #False
      
    EndIf
    
    ForEach EditEx()\Row()
      EditEx()\Row()\Selection\X      = 0
      EditEx()\Row()\Selection\String = ""
      EditEx()\Row()\Selection\State  = #False
    Next
    
  EndProcedure
  
  Procedure.i DeleteSelection_(Remove.i=#True)
    ; Delete selected text (Remove selection: #True/#False)
    Define.i Pos1, Pos2

    If EditEx()\Selection\Flag = #Selected
      
      If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
        Pos1 = EditEx()\Selection\Pos2
        Pos2 = EditEx()\Selection\Pos1
      Else
        Pos1 = EditEx()\Selection\Pos1
        Pos2 = EditEx()\Selection\Pos2
      EndIf 
      
      EditEx()\Text$ = Left(EditEx()\Text$, Pos1 - 1) + Mid(EditEx()\Text$, Pos2)
      EditEx()\Cursor\Pos = Pos1
      
      If Remove : RemoveSelection_() : EndIf
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s GetSelection_(Remove.i=#True)
    ; Return selected text (Remove selection: #True/#False)
    Define.i Pos1, Pos2
    Define.s Text$
    
    If EditEx()\Selection\Flag = #Selected      
      
      If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
        Pos1 = EditEx()\Selection\Pos2
        Pos2 = EditEx()\Selection\Pos1
      Else
        Pos1 = EditEx()\Selection\Pos1
        Pos2 = EditEx()\Selection\Pos2
      EndIf
      
      Text$ = StringSegment(EditEx()\Text$, Pos1, Pos2)
      
      If Remove : RemoveSelection_() : EndIf
      
      ProcedureReturn Text$
    EndIf
  
  EndProcedure
  
  ;- ----- Words etc. -----
  
  Procedure   AddItem_(Position.i, Text.s)
    
    EditEx()\Text$ = InsertString(EditEx()\Text$, Text, Position)

  EndProcedure
  
  Procedure.s GetWord_(Word.s, Flags.i=#WordOnly)
    Define.i i, sPos, ePos 
    Define.s Char$, Diff1$, Diff2$
    
    Word = RTrim(Trim(Word), #LF$)

    If Flags & #WordOnly
      
      For i=1 To Len(Word)
        
        Char$ = Mid(Word, i, 1)
        
        Select Asc(Char$)
          Case 35, 47, 62, 63, 92
            sPos = i
            Break  
          Case 0 To 64, 91 To 96, 123 To 192
            Diff1$ + Char$
          Case 247, 248
            Diff1$ + Char$
          Default
            sPos = i
            Break 
        EndSelect
        
      Next
      
      For i=Len(Word) To 1 Step -1
        
        Char$ = Mid(Word, i, 1)
        
        Select Asc(Char$)
          Case 47, 92
            sPos = i
            Break    
          Case 0 To 64, 91 To 96, 123 To 192
            Diff2$ = Char$ + Diff2$
          Case 247, 248
            Diff2$ = Char$ + Diff2$
          Default
            ePos = i
            Break 
        EndSelect
        
      Next
      
      Word = Mid(Word, sPos, ePos - sPos + 1)

    Else
      
      For i=1 To 2
        Char$ = Left(Word, 1)
        Select Char$
          Case "!", "?", "*"
            If Flags & #Brackets
              Word = LTrim(Word, Char$)
              Diff1$ + Char$
            EndIf  
          Case "{", "[", "(", "<"
            If Flags & #Brackets
              Word = LTrim(Word, Char$)
              Diff1$ + Char$
            EndIf
          Case Chr(34), "'", "«", "»"
            If Flags & #QuotationMarks
              Word = LTrim(Word, Char$)
              Diff1$ + Char$
            EndIf
          Case #LF$;, #Paragraph$
            Word = LTrim(Word, Char$)
          Default
            Break
        EndSelect
      Next
      
      For i=1 To 2
        Char$ = Right(Word, 1)
        Select Char$
          Case ".", ":", ",", ";", "!", "?"
            If Flags & #Punctation
              Word = RTrim(Word, Char$)
              Diff2$ + Char$
            EndIf
          Case  ")", "]", "}", ">"
            If Flags & #Brackets
              Word = RTrim(Word, Char$)
              Diff2$ + Char$
            EndIf
          Case Chr(34), "'", "«", "»"
            If Flags & #QuotationMarks
              Word = RTrim(Word, Char$)
              Diff2$ + Char$
            EndIf  
          Case " ", #LF$;, #Paragraph$
            Word = LTrim(Word, Char$)
          Default
            Break
        EndSelect
      Next
      
    EndIf  

    If Flags & #Parse
      ProcedureReturn Diff1$+"|"+Word+"|"+Diff2$
    Else  
      ProcedureReturn Word
    EndIf
    
  EndProcedure
  
  Procedure.s SplitWords_(Word.s)
    Define.i i, sPos, Count = 0
    Define.s Words$
  
    sPos = 1
    
    For i=1 To Len(Word)
      Select Mid(Word, i, 1)
        Case ")", "]", "}"
          Words$ + GetWord_(Mid(Word, sPos, i - sPos + 1)) + "|"
          sPos = i + 1
      EndSelect
    Next
    
    Words$ + GetWord_(Mid(Word, sPos, i - sPos + 1))
  
    ProcedureReturn RTrim(Words$, "|")
  EndProcedure
  
  
  Procedure.i WordStart_(String.s, Position.i, Flags.i=#WordOnly)
    ; Position of the first letter of the word
    Define.i p
    
    For p = Position - 1 To 1 Step -1
      Select Mid(String, p, 1)
        Case " ", #CR$, #LF$, #LF$
          If p + 1 <> Position : ProcedureReturn p + 1 : EndIf 
        Case ".", ":", ",", ";", "!", "?"
          If Flags & #Punctation Or Flags & #WordOnly
            If p + 1 <> Position : ProcedureReturn p + 1 : EndIf 
          EndIf
        Case "{", "[", "(", "<"
          If Flags & #Brackets Or Flags & #WordOnly
           If p + 1 <> Position : ProcedureReturn p + 1 : EndIf 
          EndIf
        Case Chr(34), "'", "«", "»"
          If Flags & #QuotationMarks Or Flags & #WordOnly
            If p + 1 <> Position : ProcedureReturn p + 1 : EndIf 
          EndIf
      EndSelect
    Next
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure.i WordEnd_(String.s, Position.i, Flags.i=#WordOnly)
    ; Position of the last letter of the word
    Define.i p
    
    For p = Position + 1 To Len(String)
      Select Mid(String, p, 1)
        Case " ", #CR$, #LF$, #LF$
          If p <> Position : ProcedureReturn p : EndIf
        Case ".", ":", ",", ";", "!", "?"
          If Flags & #Punctation Or Flags & #WordOnly
            If p <> Position : ProcedureReturn p : EndIf
          EndIf
        Case ")", "]", "}", ">"
          If Flags & #Brackets Or Flags & #WordOnly
            If p <> Position : ProcedureReturn p : EndIf
          EndIf
        Case Chr(34), "'", "»", "«"
          If Flags & #QuotationMarks Or Flags & #WordOnly
            If p <> Position : ProcedureReturn p : EndIf
          EndIf  
      EndSelect
    Next
    
    ProcedureReturn p
  EndProcedure
  
  
  Procedure.i SpaceStart_(String.s, Position.i)
    ; start position of multiple space
    Define.i p
    
    For p = Position To 1 Step -1
      If Mid(String, p, 1) <> " "
        ProcedureReturn p + 1
      EndIf 
    Next
    
    ProcedureReturn 1
  EndProcedure  
  
  Procedure.i SpaceEnd_(String.s, Position.i)
    ; end position of multiple space
    Define.i p
    
    For p = Position To Len(String)
      
      If Mid(String, p, 1) <> " "
        ProcedureReturn p
      EndIf
      
    Next
    
    ProcedureReturn p
  EndProcedure
  
  
  ;----------------------------------------------------------------------------- 
  ;-   SpellChecking
  ;-----------------------------------------------------------------------------  
  
  CompilerIf #Enable_SpellChecking
  
    Procedure   ResizeList_(Pos.i)
      Define.i X, Y, sX, sY, RowOffSet
      
      If StartDrawing(CanvasOutput(EditEx()\CanvasNum)) 
      
        If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf
        
        RowOffSet = EditEx()\Visible\RowOffset * EditEx()\Text\Height
        
        ForEach EditEx()\Row()

          If Pos >= EditEx()\Row()\Pos And Pos < EditEx()\Row()\Pos + EditEx()\Row()\Len
            X = DesktopUnscaledX(EditEx()\Row()\X + TextWidth(StringSegment(EditEx()\Text$, EditEx()\Row()\Pos, Pos))) - EditEx()\Visible\PosOffset
            Y = DesktopUnscaledY(EditEx()\Row()\Y - RowOffset + EditEx()\Text\Height)
            Break
          EndIf
          
        Next
        
        StopDrawing()
      EndIf
      
      sX = GadgetX(EditEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
      sY = GadgetY(EditEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
      
    	ResizeWindow(EditEx()\WinNum, sX + X, sY + Y, #PB_Ignore, #PB_Ignore)
    	
    EndProcedure
    
    Procedure.s UCase_(Word.s)
      ProcedureReturn UCase(Left(Word, 1)) + Mid(Word, 2)
    EndProcedure
    
    Procedure.i SearchFirstLetters(Word.s)
      Define.i ListPos, StartPos, EndPos
      Define.s Chars
      
      StartPos = 0
      EndPos   = ListSize(SpellCheck\Dictionary()) - 1
      
      Chars = LCase(Left(Word, 2))
      
      Repeat
        ListPos = StartPos + Round((EndPos - StartPos)  / 2, #PB_Round_Up)
        If SelectElement(SpellCheck\Dictionary(), ListPos)
          If Chars = Left(SpellCheck\Dictionary()\Stem, 2)
            Break
          ElseIf Chars < Left(SpellCheck\Dictionary()\Stem, 2)
            EndPos   = ListPos - 1
          ElseIf Chars > Left(SpellCheck\Dictionary()\Stem, 2)
            StartPos = ListPos + 1
          EndIf  
        EndIf
      Until (EndPos - StartPos) < 0
      
      While PreviousElement(SpellCheck\Dictionary())
        If Chars <> Left(SpellCheck\Dictionary()\Stem, 2)
          ProcedureReturn ListIndex(SpellCheck\Dictionary()) + 1
        EndIf
      Wend
      
      ProcedureReturn ListIndex(SpellCheck\Dictionary())
    EndProcedure
    
    Macro D(i,j) ; DamerauLevenshteinDistance
      D_(i+1,j+1)
    EndMacro

    Procedure   DamerauLevenshteinDistance(String1$, String2$)
      Define.i m, n, i, j, k, l, db, min, value, cost, maxDist
      
      NewMap DA.i()
      
      m = Len(String1$)
      n = Len(String2$)
      
      Dim D_(m+1,n+1)
      
      maxDist = m + n
      D(-1,-1) = maxDist 
    
      For i=0 To m
        D( i,-1) = maxDist
        D( i, 0) = i
      Next
    
      For j=0 To n
        D(-1, j) = maxDist
        D( 0, j) = j
      Next
      
      For i=1 To m
        
        db = 0
        
        For j=1 To n
          
          k = DA(Mid(String2$, j, 1))
          l = db
          
          If Mid(String1$, i, 1) = Mid(String2$, j, 1)
            cost = 0
            db = j
          Else
            cost = 1
          EndIf
          
          min   = D(i-1,j-1) + cost ; a substitution
          value = D(i  ,j-1) + 1    ; an insertion
          If value < min : min = value : EndIf
          value = D(i-1,j  ) + 1    ; a deletion
          If value < min : min = value : EndIf
          value = D(k-1,l-1) + (i-k-1) + 1 + (j-l-1) ; transposition
          If value < min : min = value : EndIf
          D(i,j) = min
          
        Next
        
        DA(Mid(String1$, i, 1)) = i
        
      Next  
      
      ProcedureReturn D(m,n)
    EndProcedure

    Procedure.i CorrectionSuggestions_(Word.s)
      Define.i i, Index, UCase, Count
      Define.s FirstChars, dicWord$
      
      FirstChars = LCase(Left(Word, 2))
      
      If Left(Word, 1) = UCase(Left(Word, 1)) : UCase = #True : EndIf
      
      ClearList(EditEx()\Suggestions())
      
      Index = SearchFirstLetters(Word)
      If SelectElement(SpellCheck\Dictionary(), Index)
        
        Repeat
  
          If Left(SpellCheck\Dictionary()\Stem, 2) <> FirstChars : Break : EndIf
          
          If SpellCheck\Dictionary()\UCase = 1 And UCase = #False
            Continue
          EndIf
          
          If UCase
            dicWord$ = UCase_(SpellCheck\Dictionary()\Stem)
          Else
            dicWord$ = SpellCheck\Dictionary()\Stem
          EndIf
          
          If DamerauLevenshteinDistance(Word, dicWord$) = 1
            AddElement(EditEx()\Suggestions())
            EditEx()\Suggestions() = dicWord$
          EndIf  
          
          If SpellCheck\Dictionary()\Endings
            
            Count = CountString(SpellCheck\Dictionary()\Endings, "|") + 1
            
            For i=1 To Count
              
              If DamerauLevenshteinDistance(Word, dicWord$ + StringField(SpellCheck\Dictionary()\Endings, i, "|")) = 1
                AddElement(EditEx()\Suggestions())
                EditEx()\Suggestions() = dicWord$ + StringField(SpellCheck\Dictionary()\Endings, i, "|")
              EndIf
              
            Next
            
          EndIf
          
        Until NextElement(SpellCheck\Dictionary()) = #False
        
      EndIf

      ProcedureReturn ListSize(EditEx()\Suggestions())
    EndProcedure
    
    
    Procedure   UpdateWordList_()
      Define.i s, Spaces
      Define.s Word$, Text$
 
      Text$ = RemoveString(EditEx()\Text$, #Hyphen$)
      Text$ = RemoveString(Text$, #SoftHyphen$)
      Text$ = ReplaceString(Text$, #LF$, " ")
      
      Spaces = CountString(Text$, " ")
      For s=1 To Spaces + 1
        Word$ = GetWord_(StringField(Text$, s, " "))
        If Word$
          If FindMapElement(SpellCheck\Words(), Word$) = #False
            AddMapElement(SpellCheck\Words(), Word$)
          EndIf
        EndIf
      Next
      
    EndProcedure
    

    Procedure   SpellCheckEndings_(Position.i, Word.s, Length.i=4)
      Define.i i, StartPos, Count
      Define.s Pattern$ = LCase(Left(Word, Length))
      NewMap CheckWords.i()
      
      ;{ Search starting position
      StartPos = Position
      While PreviousElement(SpellCheck\Dictionary())
        If Left(SpellCheck\Dictionary()\Stem, Length) <> Pattern$ : Break : EndIf
        StartPos - 1
      Wend ;}
      
      ;{ Search to end position & expand endings
      If SelectElement(SpellCheck\Dictionary(), StartPos)
        Repeat
          If Left(SpellCheck\Dictionary()\Stem, Length) <> Pattern$ : Break : EndIf
          CheckWords(SpellCheck\Dictionary()\Stem) = SpellCheck\Dictionary()\UCase
          If SpellCheck\Dictionary()\Endings
            Count = CountString(SpellCheck\Dictionary()\Endings, "|") + 1
            For i=1 To Count
              CheckWords(SpellCheck\Dictionary()\Stem + StringField(SpellCheck\Dictionary()\Endings, i, "|")) = SpellCheck\Dictionary()\UCase
            Next
          EndIf
        Until NextElement(SpellCheck\Dictionary()) = #False
      EndIf ;}
      
      If FindMapElement(CheckWords(), LCase(Word))
        If CheckWords() ; Upper case required
          If Left(Word, 1) = UCase(Left(Word, 1))
            ProcedureReturn #True
          EndIf
        Else            ; No capitalization required
          ProcedureReturn #True
        EndIf
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure   SpellCheck_(Word.s)
      Define.i ListPos, StartPos, EndPos
      Define.s LWord$ = LCase(Word)
      
      StartPos = 0
      EndPos   = ListSize(SpellCheck\Dictionary()) - 1
      
      Repeat
        ListPos = StartPos + Round((EndPos - StartPos)  / 2, #PB_Round_Up)
        If SelectElement(SpellCheck\Dictionary(), ListPos)
          If SpellCheck\Dictionary()\Stem  = LWord$                      ;{ direct hit
            If SpellCheck\Dictionary()\UCase ; Upper case required
              If Left(Word, 1) = UCase(Left(Word, 1))
                ProcedureReturn #True
              Else
                ProcedureReturn #False
              EndIf
            Else           ; No capitalization required
              ProcedureReturn #True
            EndIf ;}
          ElseIf Left(LWord$, 4) < Left(SpellCheck\Dictionary()\Stem, 4) ;{ word smaller than current word
            EndPos   = ListPos - 1
            ;}
          ElseIf Left(LWord$, 4) > Left(SpellCheck\Dictionary()\Stem, 4) ;{ word greater than current word
            StartPos = ListPos + 1
            ;}
          Else                                          ;{ Search by word endings
            If SpellCheckEndings_(ListPos, Word)
              ProcedureReturn #True
            Else
              ProcedureReturn #False
            EndIf ;}
          EndIf
        EndIf
      Until (EndPos - StartPos) < 0
      
      ProcedureReturn #False
    EndProcedure
    
    
    Procedure   SpellChecking_(Highlight.i = #True)
      Define.s Word$
      
      ClearMap(EditEx()\Mistake())
      
      If MapSize(SpellCheck\Words()) > 0
        
        ForEach SpellCheck\Words()
          
          Word$ = MapKey(SpellCheck\Words())
          
          If SpellCheck\Words()\checked = #False
            If SpellCheck(Word$) = #False
              SpellCheck\Words()\misspelled = #True
            EndIf
            SpellCheck\Words()\checked = #True
          EndIf
          
          If SpellCheck\Words()\misspelled = #True
            If Highlight : EditEx()\Mistake(Word$) = EditEx()\Color\SpellCheck : EndIf 
          EndIf
          
        Next
        
      EndIf
      
    EndProcedure
    
    
    Procedure AddToUserDictionary_(Word.s)
      
      If SpellCheck(Word) = #False
        
        DeleteMapElement(EditEx()\Syntax(), Word)
        SpellCheck\Words(Word)\misspelled = #False

        If AddElement(SpellCheck\UserDic())
          SpellCheck\UserDic()\Stem    = LCase(Word)
          SpellCheck\UserDic()\Endings = ""
          If Left(Word, 1)  = UCase(Left(Word, 1))
            SpellCheck\UserDic()\UCase  = #True
          Else
            SpellCheck\UserDic()\UCase  = #False
          EndIf
        EndIf
        
        If AddElement(SpellCheck\Dictionary())
          SpellCheck\Dictionary()\Stem    = LCase(Word)
          SpellCheck\Dictionary()\Endings = ""
          If Left(Word, 1) = UCase(Left(Word, 1))
            SpellCheck\Dictionary()\UCase  = #True
          Else
            SpellCheck\Dictionary()\UCase  = #False
          EndIf
        EndIf
        
        SortStructuredList(SpellCheck\Dictionary(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))
        
        If EditEx()\Flags & #AutoSpellCheck
          UpdateWordList_()
          SpellChecking_(#True)
          ReDraw_()
        EndIf

      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  ;----------------------------------------------------------------------------- 
  ;-   Hyphenation / WordWrap
  ;-----------------------------------------------------------------------------
  
  CompilerIf #Enable_Hyphenation
    ;/ ===== Word Hy-phen-a-tion =====
    ;/ Algorithm of Frankling Mark Liang (1983)
    ;/ based on "hyphenator for HTML" (Mathias Nater, Zürich)
    
    Procedure.s HyphenateWord(Word.s, Separator.s=#SoftHyphen$)
      Define.i c, i, ins 
      Define.i WordLen, WordIdx, Digits
      Define LWord.s, Char.s{1}
      
      If ListSize(Hypenation\Item()) = 0
        Debug "ERROR: Hyphen patterns are required => LoadHyphenationPattern()"
        ProcedureReturn Word
      EndIf
      
      Word    = "_"+Word+"_" ; Mark start and end of word
      LWord   = LCase(Word)  ; Lowercase word
      WordLen = Len(Word)    ; Word length
      
      Dim Hypos.s(WordLen)
      
      ForEach Hypenation\Item()  ;{ Evaluate pattern
        
        WordIdx = FindString(LWord, Hypenation\Item()\Chars, 1)
        If WordIdx
          
          Digits = 1
          
          For c = 1 To Len(Hypenation\Item()\Pattern)
            
            Char = Mid(Hypenation\Item()\Pattern, c, 1)
            If Char >= "0" And Char <= "9"
              
              If c = 1
                i = WordIdx
              Else
                i = WordIdx + c - Digits
              EndIf
              
              If Hypos(i) = "" Or Hypos(i) < Char ; Overwrite a smaller number
                Hypos(i) = Char
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
        If Val(Hypos(c))
          Word = InsertString(Word, Hypos(c), c + ins)
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
      
      If Mid(Word, 2, 1) = Separator : Word = Left(Word, 1) + Mid(Word, 3) : EndIf
      
      ProcedureReturn Word
    EndProcedure
    
  CompilerEndIf
  
  ;----------------------------------------------------------------------------- 
  ;-   Undo / Redo
  ;-----------------------------------------------------------------------------
  
  CompilerIf #Enable_UndoRedo
    
    Procedure.s GetCRC32(Text.s) 
      ProcedureReturn StringFingerprint(Text, #PB_Cipher_CRC32)
    EndProcedure
    
    Procedure   AddRedo_()
      
      EditEx()\Undo\Redo\CursorPos = EditEx()\Cursor\Pos
      EditEx()\Undo\Redo\Text      = EditEx()\Text$
      
    EndProcedure
    
    Procedure.s GetLastRedo_()
      
      If EditEx()\Undo\Redo\Text
        EditEx()\Undo\CursorPos = EditEx()\Undo\Redo\CursorPos
        ProcedureReturn EditEx()\Undo\Redo\Text
      EndIf
      
      EditEx()\Undo\CursorPos = EditEx()\Cursor\Pos
      
      ProcedureReturn EditEx()\Text$
    EndProcedure
    
    Procedure   ClearRedo_()
      
      EditEx()\Undo\Redo\CursorPos = 0
      EditEx()\Undo\Redo\Text      = ""
      
    EndProcedure
    
    Procedure   ChangeUndoCursor_()
      
      If LastElement(EditEx()\Undo\Item())
        
        If LastElement(EditEx()\Undo\Item()\DiffText())
          EditEx()\Undo\Item()\DiffText()\CursorPos = EditEx()\Cursor\Pos
        Else
          EditEx()\Undo\Item()\CursorPos = EditEx()\Cursor\Pos
        EndIf
        
        EditEx()\Cursor\BackChar = Mid(EditEx()\Text$, EditEx()\Cursor\Pos, 1)
        
      EndIf 

    EndProcedure  
    
    Procedure   AddUndo_()
      Define.i Lenght_1, Lenght_2
      Define.s Diff$, CRC32_1$, CRC32_2$
      
      ;{ MaxSteps
      
      If EditEx()\Undo\MaxSteps And ListSize(EditEx()\Undo\Item()) >= EditEx()\Undo\MaxSteps
        If FirstElement(EditEx()\Undo\Item())
          DeleteElement(EditEx()\Undo\Item())
        EndIf
      EndIf ;}
      
      If LastElement(EditEx()\Undo\Item())
        
        ;{ Compare with last entry    
        If LastElement(EditEx()\Undo\Item()\DiffText())
          Lenght_1 = EditEx()\Undo\Item()\DiffText()\Length
          CRC32_1$ = EditEx()\Undo\Item()\DiffText()\CRC32
        Else
          Lenght_1 = EditEx()\Undo\Item()\Length_1
          CRC32_1$ = EditEx()\Undo\Item()\CRC32_1
        EndIf
        
        Lenght_2 = EditEx()\Undo\Item()\Length_2
        CRC32_2$ = EditEx()\Undo\Item()\CRC32_2
        
        If CRC32_1$ = GetCRC32(Left(EditEx()\Text$, Lenght_1)) And CRC32_2$ = GetCRC32(Right(EditEx()\Text$, Lenght_2))
          
          ;{ Remember differential text
          Diff$ = Mid(EditEx()\Text$, Lenght_1 + 1, EditEx()\Text\Len - Lenght_1 - Lenght_2)
          If Diff$
            
            If AddElement(EditEx()\Undo\Item()\DiffText())
              EditEx()\Undo\Item()\DiffText()\CursorPos = EditEx()\Cursor\Pos
              EditEx()\Undo\Item()\DiffText()\Text      = Diff$
              EditEx()\Undo\Item()\DiffText()\Length    = Lenght_1 + Len(Diff$)
              EditEx()\Undo\Item()\DiffText()\CRC32     = GetCRC32(Left(EditEx()\Text$, EditEx()\Undo\Item()\DiffText()\Length))
            EndIf 
            
          EndIf ;}
          
        Else
          
          If AddElement(EditEx()\Undo\Item()) ;{ Remember full text
            EditEx()\Undo\Item()\CursorPos = EditEx()\Cursor\Pos
            EditEx()\Undo\Item()\Text_1    = Left(EditEx()\Text$, EditEx()\Cursor\Pos - 1)
            EditEx()\Undo\Item()\Length_1  = Len(EditEx()\Undo\Item()\Text_1)
            EditEx()\Undo\Item()\CRC32_1   = GetCRC32(EditEx()\Undo\Item()\Text_1)
            EditEx()\Undo\Item()\Text_2    = Mid(EditEx()\Text$, EditEx()\Cursor\Pos)
            EditEx()\Undo\Item()\Length_2  = Len(EditEx()\Undo\Item()\Text_2)
            EditEx()\Undo\Item()\CRC32_2   = GetCRC32(EditEx()\Undo\Item()\Text_2)
          EndIf ;}
          
        EndIf ;}
        
      Else
      
        If AddElement(EditEx()\Undo\Item()) ;{ First entry
          EditEx()\Undo\Item()\CursorPos = EditEx()\Cursor\Pos
          EditEx()\Undo\Item()\Text_1    = Left(EditEx()\Text$, EditEx()\Cursor\Pos - 1)
          EditEx()\Undo\Item()\Length_1  = Len(EditEx()\Undo\Item()\Text_1)
          EditEx()\Undo\Item()\CRC32_1   = GetCRC32(EditEx()\Undo\Item()\Text_1)
          EditEx()\Undo\Item()\Text_2    = Mid(EditEx()\Text$, EditEx()\Cursor\Pos)
          EditEx()\Undo\Item()\Length_2  = Len(EditEx()\Undo\Item()\Text_2)
          EditEx()\Undo\Item()\CRC32_2   = GetCRC32(EditEx()\Undo\Item()\Text_2)
        EndIf ;}
      
      EndIf

      
    EndProcedure
    
    Procedure.s GetLastUndo_(Redo.i=#False)
      Define.s Text1$, Text2$, LastDiff$

      AddRedo_()
      
      If LastElement(EditEx()\Undo\Item())
        
        Text1$ = EditEx()\Undo\Item()\Text_1
        Text2$ = EditEx()\Undo\Item()\Text_2
        
        If LastElement(EditEx()\Undo\Item()\DiffText()) ; Differential text
          
          EditEx()\Undo\CursorPos = EditEx()\Undo\Item()\DiffText()\CursorPos
          
          LastDiff$ = EditEx()\Undo\Item()\DiffText()\Text
          
          DeleteElement(EditEx()\Undo\Item()\DiffText())
          
          If FirstElement(EditEx()\Undo\Item()\DiffText())
            
            Repeat
              Text1$ + EditEx()\Undo\Item()\DiffText()\Text
            Until NextElement(EditEx()\Undo\Item()\DiffText()) = #False
            
          EndIf
          
          ProcedureReturn Text1$ + LastDiff$ + Text2$
        Else ; Complete text
          
          EditEx()\Undo\CursorPos = EditEx()\Undo\Item()\CursorPos
          
          If ListSize(EditEx()\Undo\Item()) > 1 : DeleteElement(EditEx()\Undo\Item()) : EndIf
          
          ProcedureReturn Text1$ + Text2$
        EndIf  

      EndIf
      
      EditEx()\Undo\CursorPos = EditEx()\Cursor\Pos
      
      ProcedureReturn EditEx()\Text$
    EndProcedure
    
    Procedure   Undo_()
      Define.s Text$
    
      Text$ = GetLastUndo_()

      If Trim(Text$) = Trim(EditEx()\Text$)
        EditEx()\Text$      = GetLastUndo_()
        EditEx()\Cursor\Pos = EditEx()\Undo\CursorPos
      Else  
        EditEx()\Text$      = Text$
        EditEx()\Cursor\Pos = EditEx()\Undo\CursorPos
      EndIf
      
      PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
      
    EndProcedure
    
  CompilerEndIf
  
  ;- __________ Drawing __________
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure.i AddRow_(Pos.i, X.i, Y.i) 

    If AddElement(EditEx()\Row())
      EditEx()\Row()\Pos = Pos
      EditEx()\Row()\X   = X
      EditEx()\Row()\Y   = Y
      ProcedureReturn #True
    EndIf
  
    ProcedureReturn #False    
  EndProcedure
  
  
  CompilerIf #Enable_SyntaxHighlight
    
    Procedure.s CalcSyntaxHighlight_(Word$, Pos.i, X.i, Part$="", LastWord.s="", WordPos.i=#True)
      Define.i w, PosX, wPos, DiffW, Words, Found, Check, posOffset
      Define.s sWord$, mapWord$, splitWord$

      sWord$ = GetWord_(Word$)
      sWord$ = SplitWords_(sWord$)
      
      If Trim(sWord$) = "" : ProcedureReturn "" : EndIf 
      
      If EditEx()\SyntaxHighlight = #NoCase
        mapWord$ = LCase(sWord$)
      Else
        mapWord$ = sWord$
      EndIf  

      Words = CountString(sWord$, "|") + 1 
      
      posOffset = 1
      
      For w=1 To Words
        
        PosX  = X
        Check = #False
        Found = #False
        
        splitWord$ = StringField(sWord$, w, "|")
        
        If LastWord ;{ "Word1_..._Word"
         
          If FindMapElement(EditEx()\Syntax(), LastWord + "_" + StringField(mapWord$, w, "|") + "_") ; another word part to highlight

            LastWord + "_" + StringField(mapWord$, w, "|")
            
            Check = 1
            Found = #True
          ElseIf FindMapElement(EditEx()\Syntax(), LastWord + "_" + StringField(mapWord$, w, "|"))   ; last word part to highlight
            
            ForEach EditEx()\Row() ;{ all word parts are found => highlight
              ForEach EditEx()\Row()\Highlight()
                EditEx()\Row()\Highlight()\Check = #False
              Next
            Next ;}
            
            LastWord = ""
            Found    = #True
          Else
            
            Found = FindMapElement(EditEx()\Syntax(), StringField(mapWord$, w, "|"))
            
            ForEach EditEx()\Row() ;{ remove all previous word parts
              ForEach EditEx()\Row()\Highlight()
                If EditEx()\Row()\Highlight()\Check
                  DeleteElement(EditEx()\Row()\Highlight())
                EndIf  
              Next
            Next ;}
            
            LastWord = ""
          EndIf  
          ;}
        Else
          
          If FindMapElement(EditEx()\Syntax(), StringField(mapWord$, w, "|") + "_")  ; "Word1_"
            LastWord = StringField(mapWord$, w, "|")
            Check    = 1
            Found    = #True
          Else  
            Found = FindMapElement(EditEx()\Syntax(), StringField(mapWord$, w, "|")) ; "Word1"
            LastWord = ""
          EndIf
          
        EndIf  

        If Found

          If Part$ : splitWord$ = Part$ : EndIf
          
          If WordPos
            wPos = FindString(Word$, splitWord$, posOffset) 
            If wPos > 1 : PosX + TextWidth(Left(Word$, wPos - 1)) : EndIf
          EndIf 
          
          If AddElement(EditEx()\Row()\Highlight())
            EditEx()\Row()\Highlight()\X = PosX
            EditEx()\Row()\Highlight()\String = splitWord$
            EditEx()\Row()\Highlight()\Color  = EditEx()\Syntax()
            EditEx()\Row()\Highlight()\Check  = Check
          EndIf
          
          If EditEx()\Cursor\Pos >= Pos + wPos - 1 And EditEx()\Cursor\Pos < Pos + wPos + Len(splitWord$)
            EditEx()\Cursor\FrontColor = EditEx()\Syntax()
            EditEx()\Cursor\BackColor  = EditEx()\Color\Back
          EndIf

        EndIf
        
        posOffset + Len(splitWord$)
        
      Next
      
      ProcedureReturn LastWord
    EndProcedure

  CompilerEndIf
  
  CompilerIf #Enable_SpellChecking

    Procedure   CalcSpellCheck_(Word$, Pos, X, Part$="")
      Define.i wPos
      Define.s sWord$
      
      sWord$ = GetWord_(Word$)

      If FindMapElement(EditEx()\Mistake(), sWord$)
 
        If Part$
          Word$  = Part$
          sWord$ = GetWord_(Part$)
        EndIf
        
        wPos = FindString(Word$, sWord$)
        If wPos > 1 : X + TextWidth(Left(Word$, wPos - 1)) : EndIf

        If AddElement(EditEx()\Row()\Highlight())
          EditEx()\Row()\Highlight()\X = X
          EditEx()\Row()\Highlight()\String = RTrim(sWord$, #LF$)
          EditEx()\Row()\Highlight()\Color  = EditEx()\Mistake()
        EndIf  

        If EditEx()\Cursor\Pos >= Pos + wPos - 1 And EditEx()\Cursor\Pos < Pos + wPos + Len(sWord$)
          EditEx()\Cursor\FrontColor = EditEx()\Mistake()
          EditEx()\Cursor\BackColor  = EditEx()\Color\Back
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure   CalcCtrlChars(Word$, X)
    Define.i DiffW, wPos

    Word$ = RemoveString(Word$, #LF$)
    
    wPos = FindString(Word$, " ")
    If wPos
      DiffW = Round((TextWidth(" ") - TextWidth(#Space$)) / 2, #PB_Round_Nearest)
      If AddElement(EditEx()\Row()\Highlight())
        EditEx()\Row()\Highlight()\X      = X + TextWidth(Left(Word$, wPos - 1)) + DiffW
        EditEx()\Row()\Highlight()\String = #Space$
        EditEx()\Row()\Highlight()\Color  = $B48246
      EndIf
    EndIf

    wPos = FindString(Word$, #Paragraph$)
    If wPos
      If AddElement(EditEx()\Row()\Highlight())
        EditEx()\Row()\Highlight()\X      = X + TextWidth(Left(Word$, wPos - 1))
        EditEx()\Row()\Highlight()\String = #Paragraph$
        EditEx()\Row()\Highlight()\Color  = $578B2E
      EndIf
    EndIf
    
    wPos = FindString(Word$, #SoftHyphen$)
    If wPos
      If AddElement(EditEx()\Row()\Highlight())
        EditEx()\Row()\Highlight()\X      = X + TextWidth(Left(Word$, wPos - 1))
        EditEx()\Row()\Highlight()\String = #SoftHyphen$
        EditEx()\Row()\Highlight()\Color  = $7280FA
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure   CalcSelection_(X, Pos.i, Len.i, Pos1.i, Pos2.i)
    Define.i PosX
    Define.s Text$

    If Pos2 >= Pos And Pos1 <= Pos + Len

      If Pos1 <= Pos
        
        PosX = X
        
        If Pos2 >= Pos + Len
          Text$ = StringSegment(EditEx()\Text$, Pos, Pos + Len)
        Else
          Text$ = StringSegment(EditEx()\Text$, Pos, Pos2)
        EndIf

      Else
        
        PosX = X + TextWidth(StringSegment(EditEx()\Text$, Pos, Pos1))
        
        If Pos2 >= Pos + Len
          Text$ = StringSegment(EditEx()\Text$, Pos1, Pos + Len)
        Else
          Text$ = StringSegment(EditEx()\Text$, Pos1, Pos2)
        EndIf

      EndIf
      
      If EditEx()\Row()\Selection\State  = #True
        EditEx()\Row()\Selection\String + RTrim(Text$, #LF$)
      Else  
        EditEx()\Row()\Selection\X      = PosX
        EditEx()\Row()\Selection\String = RTrim(Text$, #LF$)
        EditEx()\Row()\Selection\State  = #True
      EndIf 
      
      If EditEx()\Cursor\Pos >= Pos1 And EditEx()\Cursor\Pos < Pos2
        EditEx()\Cursor\FrontColor = EditEx()\Color\HighlightText
        EditEx()\Cursor\BackColor  = EditEx()\Color\Highlight
      EndIf
      
    EndIf 

  EndProcedure  
  
  
	Procedure   DrawScrollArrow_(X.i, Y.i, Width.i, Height.i, Color.i, Flag.i)
	  Define.i aWidth, aHeight, aColor

	  If StartVectorDrawing(CanvasVectorOutput(EditEx()\ScrollBar\Item()\Num))

      aColor  = RGBA(Red(Color), Green(Color), Blue(Color), 255)
      
      If Flag = #ScrollBar_Up Or Flag = #ScrollBar_Down
  	    aWidth  = dpiX(8)
  	    aHeight = dpiX(4)
  	  Else
        aWidth  = dpiX(4)
        aHeight = dpiX(8)  
  	  EndIf  

      X + ((Width  - aWidth) / 2)
      Y + ((Height - aHeight) / 2)
      
      Select Flag
        Case #ScrollBar_Up
          MovePathCursor(X, Y + aHeight)
          AddPathLine(X + aWidth / 2, Y)
          AddPathLine(X + aWidth, Y + aHeight)
        Case #ScrollBar_Down 
          MovePathCursor(X, Y)
          AddPathLine(X + aWidth / 2, Y + aHeight)
          AddPathLine(X + aWidth, Y)
        Case #ScrollBar_Left
          MovePathCursor(X + aWidth, Y)
          AddPathLine(X, Y + aHeight / 2)
          AddPathLine(X + aWidth, Y + aHeight)
        Case #ScrollBar_Right
          MovePathCursor(X, Y)
          AddPathLine(X + aWidth, Y + aHeight / 2)
          AddPathLine(X, Y + aHeight)
      EndSelect
      
      VectorSourceColor(aColor)
      StrokePath(2, #PB_Path_RoundCorner)

	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
	
	Procedure   DrawScrollButton_(X.i, Y.i, Width.i, Height.i, ScrollBar.s, Type.i, State.i=#False)
	  Define.i Color, Border
    
	  If StartDrawing(CanvasOutput(EditEx()\ScrollBar\Item()\Num))
	    
	    DrawingMode(#PB_2DDrawing_Default)
	    
	    Select State
	      Case #ScrollBar_Focus
	        Color  = BlendColor_(EditEx()\ScrollBar\Color\Focus, EditEx()\ScrollBar\Color\Button, 10)
	        Border = BlendColor_(EditEx()\ScrollBar\Color\Focus, EditEx()\ScrollBar\Color\Border, 10)
	      Case #ScrollBar_Click
	        Color  = BlendColor_(EditEx()\ScrollBar\Color\Focus, EditEx()\ScrollBar\Color\Button, 20)
	        Border = BlendColor_(EditEx()\ScrollBar\Color\Focus, EditEx()\ScrollBar\Color\Border, 20)
	      Default
	        Color  = EditEx()\ScrollBar\Color\Button
	        Border = EditEx()\ScrollBar\Color\Border
	    EndSelect    
	    
	    If FindMapElement(EditEx()\ScrollBar\Item(), ScrollBar)
	      
	      If EditEx()\ScrollBar\Item()\Hide : ProcedureReturn #False : EndIf 
	      
	      Select Type
  	      Case #ScrollBar_Forwards
  	        If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	          Box(EditEx()\ScrollBar\Item()\Buttons\Forwards\X,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Y,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height,  Color)
  	        Else
  	          Box(EditEx()\ScrollBar\Item()\Buttons\Forwards\X,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Y,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Width,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Height,  Color)
  	        EndIf  
  	      Case #ScrollBar_Backwards
  	        If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	          Box(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, Color)
  	        Else
  	          Box(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, Color)
  	        EndIf   
  	    EndSelect    
	      
	      If EditEx()\ScrollBar\Flags & #ScrollBar_ButtonBorder
	      
  	      DrawingMode(#PB_2DDrawing_Outlined)
  	      
  	      Select Type
  	        Case #ScrollBar_Forwards
  	          If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	            Box(EditEx()\ScrollBar\Item()\Buttons\Forwards\X - dpiX(1), EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width + dpiX(2), EditEx()\ScrollBar\Item()\Buttons\Forwards\Height + dpiY(2), Border)
  	          Else
  	            Box(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y - dpiY(1), EditEx()\ScrollBar\Item()\Buttons\Forwards\Width + dpiX(2), EditEx()\ScrollBar\Item()\Buttons\Forwards\Height + dpiY(2), Border)
  	          EndIf  
    	      Case #ScrollBar_Backwards
    	        If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
    	          Box(EditEx()\ScrollBar\Item()\Buttons\Backwards\X - dpiX(1), EditEx()\ScrollBar\Item()\Buttons\Backwards\Y - dpiY(1), EditEx()\ScrollBar\Item()\Buttons\Backwards\Width + dpiX(2), EditEx()\ScrollBar\Item()\Buttons\Backwards\Height + dpiY(1), Border)
    	        Else
  	            Box(EditEx()\ScrollBar\Item()\Buttons\Backwards\X - dpiX(1), EditEx()\ScrollBar\Item()\Buttons\Backwards\Y - dpiY(1), EditEx()\ScrollBar\Item()\Buttons\Backwards\Width + dpiX(1), EditEx()\ScrollBar\Item()\Buttons\Backwards\Height + dpiY(2), Border)
  	          EndIf   
    	    EndSelect 
    	    
  	    EndIf 
	    
	    EndIf

	    StopDrawing()
	  EndIf
	  
	  ;{ ----- Draw Arrows -----
	  If FindMapElement(EditEx()\ScrollBar\Item(), ScrollBar)
	    
  	  Select Type
        Case #ScrollBar_Forwards
          If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
            DrawScrollArrow_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, EditEx()\ScrollBar\Color\Front, #ScrollBar_Down)
          Else
            DrawScrollArrow_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, EditEx()\ScrollBar\Color\Front, #ScrollBar_Right)
          EndIf  
        Case #ScrollBar_Backwards
          If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
        		DrawScrollArrow_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, EditEx()\ScrollBar\Color\Front, #ScrollBar_Up)
        	Else
        	  DrawScrollArrow_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, EditEx()\ScrollBar\Color\Front, #ScrollBar_Left)
        	EndIf  
      EndSelect
    
    EndIf ;}

	EndProcedure
	
	Procedure   DrawScrollBar_(ScrollBar.s)
		Define.i X, Y, Width, Height, Offset, OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		If FindMapElement(EditEx()\ScrollBar\Item(), ScrollBar)
		  
      If EditEx()\ScrollBar\Item()\Hide : ProcedureReturn #False : EndIf 
  	 
      ;{ ----- Size -----
		  X      = EditEx()\ScrollBar\Item()\X
		  Y      = EditEx()\ScrollBar\Item()\Y
		  Width  = EditEx()\ScrollBar\Item()\Width 
		  Height = EditEx()\ScrollBar\Item()\Height
		  ;}
		  
		  Offset = (EditEx()\ScrollBar\Item()\Pos - EditEx()\ScrollBar\Item()\minPos) * EditEx()\ScrollBar\Item()\Thumb\Factor
		  
		  If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
		    
        ;{ ----- Buttons -----
  		  EditEx()\ScrollBar\Item()\Buttons\Forwards\X       = X + dpiX(1)
    		EditEx()\ScrollBar\Item()\Buttons\Forwards\Y       = Y + Height - dpiY(#ScrollBar_ButtonSize) - dpiY(EditEx()\ScrollBar\Adjust) - dpiY(1)
    		EditEx()\ScrollBar\Item()\Buttons\Forwards\Width   = Width - dpiX(2)
    		EditEx()\ScrollBar\Item()\Buttons\Forwards\Height  = dpiY(#ScrollBar_ButtonSize)	
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\X      = X + dpiX(1)
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\Y      = Y + dpiY(1)
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\Width  = Width - dpiX(2)
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\Height = dpiY(#ScrollBar_ButtonSize)
    		;}
        ;{ ----- ScrollArea -----
    		EditEx()\ScrollBar\Item()\Area\X = X
    	  EditEx()\ScrollBar\Item()\Area\Y = Y + dpiY(#ScrollBar_ButtonSize) + dpiY(1)
    	  EditEx()\ScrollBar\Item()\Area\Width  = Width
    	  EditEx()\ScrollBar\Item()\Area\Height = Height - dpiY(#ScrollBar_ButtonSize * 2) - dpiY(2)
    	  ;}
        ;{ ----- Thumb -----
    	  EditEx()\ScrollBar\Item()\Thumb\X      = X
    	  EditEx()\ScrollBar\Item()\Thumb\Y      = EditEx()\ScrollBar\Item()\Area\Y + Offset
    	  EditEx()\ScrollBar\Item()\Thumb\Width  = Width
    	  EditEx()\ScrollBar\Item()\Thumb\Height = EditEx()\ScrollBar\Item()\Thumb\Size
    	  If EditEx()\ScrollBar\Flags & #ScrollBar_ButtonBorder
    	    EditEx()\ScrollBar\Item()\Thumb\Y + dpiY(1)
    	    EditEx()\ScrollBar\Item()\Thumb\Height - dpiY(2)
    	  EndIf ;}
    	  
    	Else
    	  
  		  ;{ ----- Buttons -----
  		  EditEx()\ScrollBar\Item()\Buttons\Forwards\X       = X + Width - dpiX(#ScrollBar_ButtonSize) - dpiX(EditEx()\ScrollBar\Adjust) - dpiY(1)
    		EditEx()\ScrollBar\Item()\Buttons\Forwards\Y       = Y + dpiY(1)
    		EditEx()\ScrollBar\Item()\Buttons\Forwards\Width   = dpiX(#ScrollBar_ButtonSize)
    		EditEx()\ScrollBar\Item()\Buttons\Forwards\Height  = Height - dpiY(2)
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\X      = X + dpiX(1)
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\Y      = Y + dpiY(1)
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\Width  = dpiX(#ScrollBar_ButtonSize)
    		EditEx()\ScrollBar\Item()\Buttons\Backwards\Height = Height - dpiY(2)
    		;}
    		;{ ----- ScrollArea -----
    		EditEx()\ScrollBar\Item()\Area\X = X + dpiX(#ScrollBar_ButtonSize) + dpiX(1)
    	  EditEx()\ScrollBar\Item()\Area\Y = Y
    	  EditEx()\ScrollBar\Item()\Area\Width  = Width - dpiX(#ScrollBar_ButtonSize * 2) - dpiX(2)
    	  EditEx()\ScrollBar\Item()\Area\Height = Height
    	  ;}
    	  ;{ ----- Thumb -----
    	  EditEx()\ScrollBar\Item()\Thumb\X      = EditEx()\ScrollBar\Item()\Area\X + Offset
    	  EditEx()\ScrollBar\Item()\Thumb\Y      = Y
    	  EditEx()\ScrollBar\Item()\Thumb\Width  = EditEx()\ScrollBar\Item()\Thumb\Size
    	  EditEx()\ScrollBar\Item()\Thumb\Height = Height
    	  If EditEx()\ScrollBar\Flags & #ScrollBar_ButtonBorder
    	    EditEx()\ScrollBar\Item()\Thumb\X + dpiX(1)
    	    EditEx()\ScrollBar\Item()\Thumb\Width - dpiX(2)
    	  EndIf ;}	
  	  
		  EndIf

		  If StartDrawing(CanvasOutput(EditEx()\ScrollBar\Item()\Num))
		    
  		  ;{ _____ Color _____
  		  FrontColor  = EditEx()\ScrollBar\Color\Front
  		  BackColor   = EditEx()\ScrollBar\Color\Back
  		  BorderColor = EditEx()\ScrollBar\Color\Border
  		  
  		  If EditEx()\ScrollBar\Item()\Disable
  		    FrontColor  = EditEx()\ScrollBar\Color\DisableFront
  		    BackColor   = EditEx()\ScrollBar\Color\DisableBack
  		    BorderColor = EditEx()\ScrollBar\Color\DisableFront
  		  EndIf
  		  ;}
  		  
  		  DrawingMode(#PB_2DDrawing_Default)
  		  
  		  ;{ _____ Background _____
  		  Box(X, Y, Width, Height, EditEx()\ScrollBar\Color\Gadget) ; needed for rounded corners
  		  Box(EditEx()\ScrollBar\Item()\Area\X, EditEx()\ScrollBar\Item()\Area\Y, EditEx()\ScrollBar\Item()\Area\Width, EditEx()\ScrollBar\Item()\Area\Height, EditEx()\ScrollBar\Color\Back)
  			;}
  			
  		  ;{ _____ Draw Thumb _____
  		  If EditEx()\ScrollBar\Item()\Thumb\Size
  		    
    		  Select EditEx()\ScrollBar\Item()\Thumb\State
    			  Case #ScrollBar_Focus
    			    Box(EditEx()\ScrollBar\Item()\Thumb\X, EditEx()\ScrollBar\Item()\Thumb\Y, EditEx()\ScrollBar\Item()\Thumb\Width, EditEx()\ScrollBar\Item()\Thumb\Height, BlendColor_(EditEx()\ScrollBar\Color\Focus, EditEx()\ScrollBar\Color\ScrollBar, 10))
    			  Case #ScrollBar_Click
    			    Box(EditEx()\ScrollBar\Item()\Thumb\X, EditEx()\ScrollBar\Item()\Thumb\Y, EditEx()\ScrollBar\Item()\Thumb\Width, EditEx()\ScrollBar\Item()\Thumb\Height, BlendColor_(EditEx()\ScrollBar\Color\Focus, EditEx()\ScrollBar\Color\ScrollBar, 20))
    			  Default
    			    Box(EditEx()\ScrollBar\Item()\Thumb\X, EditEx()\ScrollBar\Item()\Thumb\Y, EditEx()\ScrollBar\Item()\Thumb\Width, EditEx()\ScrollBar\Item()\Thumb\Height, EditEx()\ScrollBar\Color\ScrollBar)
    			EndSelect
    			
    		  If EditEx()\ScrollBar\Flags & #ScrollBar_DragLines   ;{ Drag Lines
    		    
    		    If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
    		      
      			  If EditEx()\ScrollBar\Item()\Thumb\Size > dpiY(10)
      		      OffsetY = (EditEx()\ScrollBar\Item()\Thumb\Size - dpiY(7)) / 2			      
      		      Line(EditEx()\ScrollBar\Item()\Thumb\X + dpiX(4), EditEx()\ScrollBar\Item()\Thumb\Y + OffsetY, EditEx()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), EditEx()\ScrollBar\Color\Front)
      		      Line(EditEx()\ScrollBar\Item()\Thumb\X + dpiX(4), EditEx()\ScrollBar\Item()\Thumb\Y + OffsetY + dpiY(3), EditEx()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), EditEx()\ScrollBar\Color\Front)
      		      Line(EditEx()\ScrollBar\Item()\Thumb\X + dpiX(4), EditEx()\ScrollBar\Item()\Thumb\Y + OffsetY + dpiY(6), EditEx()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), EditEx()\ScrollBar\Color\Front)
      		    EndIf
      		    
      		  Else
    
      			  If EditEx()\ScrollBar\Item()\Thumb\Size > dpiX(10)
        		    OffsetX = (EditEx()\ScrollBar\Item()\Thumb\Size - dpiX(7)) / 2
        		    Line(EditEx()\ScrollBar\Item()\Thumb\X + OffsetX, EditEx()\ScrollBar\Item()\Thumb\Y + dpiX(4), dpiX(1), EditEx()\ScrollBar\Item()\Thumb\Height - dpiY(8), EditEx()\ScrollBar\Color\Front)
    			      Line(EditEx()\ScrollBar\Item()\Thumb\X + OffsetX + dpiX(3), EditEx()\ScrollBar\Item()\Thumb\Y + dpiX(4), dpiX(1), EditEx()\ScrollBar\Item()\Thumb\Height - dpiY(8), EditEx()\ScrollBar\Color\Front)
    			      Line(EditEx()\ScrollBar\Item()\Thumb\X + OffsetX + dpiX(6), EditEx()\ScrollBar\Item()\Thumb\Y + dpiX(4), dpiX(1), EditEx()\ScrollBar\Item()\Thumb\Height - dpiY(8), EditEx()\ScrollBar\Color\Front)
    			    EndIf
    			    
    			  EndIf
    			  ;}
    			EndIf
    			
    			If EditEx()\ScrollBar\Flags & #ScrollBar_ThumbBorder ;{ Thumb Border
    			  DrawingMode(#PB_2DDrawing_Outlined)
    			  Box(EditEx()\ScrollBar\Item()\Thumb\X, EditEx()\ScrollBar\Item()\Thumb\Y, EditEx()\ScrollBar\Item()\Thumb\Width, EditEx()\ScrollBar\Item()\Thumb\Height, EditEx()\ScrollBar\Color\Border)
    			  ;}
    			EndIf
    			
  			EndIf
  			;}
  			
  			;{ _____ Border ____
  			If EditEx()\ScrollBar\Flags & #ScrollBar_Border
  			  DrawingMode(#PB_2DDrawing_Outlined)
  			  Box(X, Y, Width, Height, BorderColor)
  			  If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  			    Line(X, Height - dpiY(EditEx()\ScrollBar\Adjust), Width, 1, BorderColor)
  			  Else
  			    Line(Width - dpiX(EditEx()\ScrollBar\Adjust), Y, 1, Height, BorderColor)
  			  EndIf   
  			EndIf ;}
  
  			StopDrawing()
  		EndIf	
  		
    	DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Y,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Width,  EditEx()\ScrollBar\Item()\Buttons\Forwards\Height,  ScrollBar, #ScrollBar_Forwards,  EditEx()\ScrollBar\Item()\Buttons\Forwards\State)
    	DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, EditEx()\ScrollBar\Item()\Buttons\Backwards\State)

    EndIf
    
	EndProcedure  
	
  
  Procedure   CalcRows_() 
    Define.i r, w, h, X, Y, PosX, PosY, Pos, Pos1, Pos2, WordLen, maxTextWidth
    Define.i Rows, Words, Hyphen, SyntaxHighlight, AutoSpellCheck, SoftHyphen, PosOffset, RowOffset
    Define.s Row$, Word$, hWord$, WordOnly$, WordMask$, Part$, LastWord$
    
    ;{ _____ Selection position _____
    If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
      Pos1 = EditEx()\Selection\Pos2
      Pos2 = EditEx()\Selection\Pos1
    Else
      Pos1 = EditEx()\Selection\Pos1
      Pos2 = EditEx()\Selection\Pos2
    EndIf ;}
    
    EditEx()\Cursor\FrontColor = EditEx()\Color\Front
    EditEx()\Cursor\BackColor  = EditEx()\Color\Back
    
    If MapSize(EditEx()\Syntax())  : SyntaxHighlight = #True : EndIf
    If MapSize(EditEx()\Mistake()) : AutoSpellCheck  = #True : EndIf
    
    If StartDrawing(CanvasOutput(EditEx()\CanvasNum)) 
      
      If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf
      
      ;{ _____ Rows _____
      ClearList(EditEx()\Row())
      EditEx()\Text\maxRowWidth = 0

      EditEx()\Text\Height   = TextHeight("Abc")
      EditEx()\Cursor\Height = EditEx()\Text\Height
      
      X = dpiX(EditEx()\Size\PaddingX)
      Y = dpiY(EditEx()\Size\PaddingY)

      If EditEx()\Text\Width
        maxTextWidth = dpiX(EditEx()\Text\Width)
      Else
        maxTextWidth = dpiX(EditEx()\Visible\Width)
      EndIf

      EditEx()\Text\Len = Len(EditEx()\Text$)
      If EditEx()\Text\Len : Pos = 1 : EndIf
      
      PosY = Y
      
      Rows = CountString(EditEx()\Text$, #LF$) + 1 
      For r=1 To Rows
        
        PosX = X
        
        Row$ = StringField(EditEx()\Text$, r, #LF$)
        If r <> Rows : Row$ + #LF$ : EndIf
        
        If EditEx()\Flags & #WordWrap Or EditEx()\Flags & #Hyphenation ;{ WordWrap / Hyphenation
          
          AddRow_(Pos, PosX, PosY) 
          
          Words = CountString(Row$, " ") + 1
          For w=1 To Words
            
            Word$ = StringField(Row$, w, " ")
            If w <> Words : Word$ + " " : EndIf
            
            Part$ = ""
            
            If PosX + TextWidth(RTrim(Word$)) > maxTextWidth

              CompilerIf #Enable_Hyphenation
                
                If EditEx()\Flags & #Hyphenation ;{ Hyphenation
                  
                  WordOnly$ = GetWord_(Word$)
                  
                  If WordOnly$ <> Word$
                    WordMask$ = ReplaceString(Word$, WordOnly$, "$")
                  Else
                    WordMask$ = ""
                  EndIf
                  
                  SoftHyphen = CountString(WordOnly$, #SoftHyphen$)
                  If SoftHyphen
                    Hyphen = SoftHyphen
                    hWord$ = WordOnly$
                  Else  
                    hWord$ = HyphenateWord(WordOnly$)
                    Hyphen = CountString(hWord$, #SoftHyphen$)
                  EndIf
                  
                  If Hyphen

                    If WordMask$ : hWord$ = ReplaceString(WordMask$, "$", hWord$) : EndIf
                  
                    For h=1 To Hyphen + 1
                      If PosX + TextWidth(RTrim(Part$ + StringField(hWord$, h, #SoftHyphen$))) > maxTextWidth
                        Break
                      Else
                        Part$ + StringField(hWord$, h, #SoftHyphen$)
                      EndIf  
                    Next
                    
                    If Part$
                      
                      hWord$  = RemoveString(hWord$, #SoftHyphen$)
                      WordLen = Len(Part$) + SoftHyphen
                      
                      CompilerIf #Enable_SpellChecking
                        If EditEx()\Flags & #AutoSpellCheck
                          If AutoSpellCheck : CalcSpellCheck_(Word$, Pos, PosX, Part$ + "-") : EndIf
                        EndIf  
                      CompilerEndIf
                      
                      CompilerIf #Enable_SyntaxHighlight
                        If SyntaxHighlight : LastWord$ = CalcSyntaxHighlight_(Word$, Pos, PosX, Part$ + "-", LastWord$) : EndIf
                      CompilerEndIf
                      
                      If EditEx()\Selection\Flag = #Selected : CalcSelection_(PosX, Pos, WordLen, Pos1, Pos2) : EndIf
                      
                      EditEx()\Row()\Len   + WordLen
                      EditEx()\Row()\Width + TextWidth(Part$)
                      EditEx()\Row()\WordWrap = "-" + #LF$
                      
                      If EditEx()\Row()\Width > EditEx()\Text\maxRowWidth
                        EditEx()\Text\maxRowWidth = EditEx()\Row()\Width
                      EndIf 
                      
                      Part$ = Mid(hWord$, Len(Part$) + 1)
                      
                      Pos + WordLen
                    EndIf
                    
                  EndIf
                  ;}
                EndIf
                
              CompilerEndIf
              
              If EditEx()\Row()\WordWrap = "" : EditEx()\Row()\WordWrap = #LF$ : EndIf
              
              PosX = X
              PosY + EditEx()\Text\Height
              AddRow_(Pos, PosX, PosY)
              
            EndIf
            
            CompilerIf #Enable_SpellChecking
              
              If EditEx()\Flags & #AutoSpellCheck
                If AutoSpellCheck : CalcSpellCheck_(Word$, Pos, PosX, Part$) : EndIf
              EndIf  
              
            CompilerEndIf
            
            CompilerIf #Enable_SyntaxHighlight
              
              If SyntaxHighlight
                If Part$
                  LastWord$ = CalcSyntaxHighlight_(Word$, Pos, PosX, Part$, LastWord$, #False)
                Else
                  LastWord$ = CalcSyntaxHighlight_(Word$, Pos, PosX, "", LastWord$)
                EndIf
              EndIf
              
            CompilerEndIf 
     
            If Part$
              WordLen = Len(Part$)
              If EditEx()\Selection\Flag = #Selected : CalcSelection_(PosX, Pos, WordLen, Pos1, Pos2) : EndIf
              If EditEx()\Flags & #CtrlChars : CalcCtrlChars(RTrim(Part$, #LF$), PosX) : EndIf 
              PosX + TextWidth(RTrim(Part$, #LF$))
              EditEx()\Row()\Width + TextWidth(Part$)
            Else
              WordLen = Len(Word$)
              If EditEx()\Selection\Flag = #Selected : CalcSelection_(PosX, Pos, WordLen, Pos1, Pos2) : EndIf
              If EditEx()\Flags & #CtrlChars : CalcCtrlChars(RTrim(Word$, #LF$), PosX) : EndIf 
              PosX + TextWidth(RTrim(Word$, #LF$))
              EditEx()\Row()\Width + TextWidth(Word$)
            EndIf
            
            If EditEx()\Row()\Width > EditEx()\Text\maxRowWidth
              EditEx()\Text\maxRowWidth = EditEx()\Row()\Width
            EndIf
            
            EditEx()\Row()\Len + WordLen

            Pos + WordLen
          Next
          
          PosY + EditEx()\Text\Height
          ;}
        Else                                                           ;{ no WordWrap
          
          AddRow_(Pos, PosX, PosY) 
          
          Words = CountString(Row$, " ") + 1
          For w=1 To Words
            
            Word$ = StringField(Row$, w, " ")
            If w <> Words : Word$ + " " : EndIf
            
            CompilerIf #Enable_SpellChecking
              
              If EditEx()\Flags & #AutoSpellCheck
                If AutoSpellCheck : CalcSpellCheck_(Word$, Pos, PosX) : EndIf
              EndIf  
              
            CompilerEndIf
            
            CompilerIf #Enable_SyntaxHighlight
              
              If SyntaxHighlight : LastWord$ = CalcSyntaxHighlight_(Word$, Pos, PosX, "", LastWord$) : EndIf
              
            CompilerEndIf 
            
            If EditEx()\Flags & #CtrlChars : CalcCtrlChars(RTrim(Word$, #LF$), PosX) : EndIf 

            WordLen = Len(Word$)
            
            If EditEx()\Selection\Flag = #Selected : CalcSelection_(PosX, Pos, WordLen, Pos1, Pos2) : EndIf
            
            PosX + TextWidth(RTrim(Word$, #LF$))
            
            EditEx()\Row()\Len   + WordLen
            EditEx()\Row()\Width + TextWidth(Word$)
            
            If EditEx()\Row()\Width > EditEx()\Text\maxRowWidth
              EditEx()\Text\maxRowWidth = EditEx()\Row()\Width
            EndIf
            
            Pos + WordLen
          Next

          PosY + EditEx()\Text\Height
          ;}
        EndIf

      Next
      
      EditEx()\Visible\CharW = TextWidth(StringSegment(EditEx()\Text$, EditEx()\Cursor\Pos, EditEx()\Cursor\Pos + 1))
      ;}
      
      ;{ _____ Cursor _____
      PosOffset = dpiX(EditEx()\Visible\PosOffset)
      RowOffset = EditEx()\Visible\RowOffset * EditEx()\Text\Height
      
      If EditEx()\Cursor\Pos = 0                     ;{ Empty text
        EditEx()\Cursor\Pos = 1
        EditEx()\Cursor\X   = dpiX(EditEx()\Size\PaddingX)
        EditEx()\Cursor\Y   = dpiY(EditEx()\Size\PaddingY)
        EditEx()\Cursor\Row = 0
        EditEx()\Cursor\BackChar = ""
        ;}
      ElseIf EditEx()\Cursor\Pos > EditEx()\Text\Len ;{ After last character
        
        If LastElement(EditEx()\Row())
          
          If Mid(EditEx()\Text$, EditEx()\Cursor\Pos - 1, 1) = #LF$
            EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset
          Else
            EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset + TextWidth(Mid(EditEx()\Text$, EditEx()\Row()\Pos))
          EndIf
          
          EditEx()\Cursor\Y = EditEx()\Row()\Y - RowOffset
          EditEx()\Cursor\Row = ListIndex(EditEx()\Row())
          EditEx()\Cursor\BackChar = ""
          
        EndIf
        ;}
      Else                                           ;{ Normal Cursor position
        
        ForEach EditEx()\Row()
          
          If EditEx()\Cursor\Pos >= EditEx()\Row()\Pos And EditEx()\Cursor\Pos <= EditEx()\Row()\Pos + EditEx()\Row()\Len
            
            If EditEx()\Cursor\Pos = EditEx()\Row()\Pos + EditEx()\Row()\Len
              
              If ListIndex(EditEx()\Row()) = ListSize(EditEx()\Row()) - 1
                EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset + TextWidth(RTrim(StringSegment(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Cursor\Pos), #LF$))
                EditEx()\Cursor\BackChar = ""
              Else
                If NextElement(EditEx()\Row())
                  EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset
                  EditEx()\Cursor\BackChar = Mid(EditEx()\Text$, EditEx()\Cursor\Pos, 1)
                EndIf
              EndIf  
    
            Else  
              EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset + TextWidth(RTrim(StringSegment(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Cursor\Pos), #LF$))
              EditEx()\Cursor\BackChar = Mid(EditEx()\Text$, EditEx()\Cursor\Pos, 1)
            EndIf
            
            EditEx()\Cursor\Y   = EditEx()\Row()\Y - RowOffset
            EditEx()\Cursor\Row = ListIndex(EditEx()\Row())
            
            Break  
          EndIf  
          
        Next
        ;}
      EndIf
      ;}      
      
      StopDrawing()
    EndIf
    
    ForEach EditEx()\Row()
      ForEach EditEx()\Row()\Highlight() ;{ remove all obsolete word parts
        If EditEx()\Row()\Highlight()\Check
          DeleteElement(EditEx()\Row()\Highlight())
        EndIf   
      Next ;}
    Next
    
  EndProcedure

  Procedure   CalcCursorOffset()
    Define.i PosOffSet, RowOffSet, PageRows, Changed
    
    PosOffSet = EditEx()\Visible\PosOffset
    RowOffSet = EditEx()\Visible\RowOffset
    
    If EditEx()\Flags &  #ScrollBar_Horizontal
      
      If EditEx()\Cursor\X < EditEx()\Size\PaddingX
        EditEx()\Visible\PosOffset = EditEx()\Cursor\X - EditEx()\Size\PaddingX
      ElseIf EditEx()\Cursor\X + EditEx()\Visible\CharW >= EditEx()\Visible\Width + EditEx()\Size\PaddingX
        EditEx()\Visible\PosOffset = EditEx()\Cursor\X + EditEx()\Visible\CharW - (EditEx()\Visible\Width + EditEx()\Size\PaddingX)
      EndIf 
      
    EndIf
    
    If EditEx()\Flags &  #ScrollBar_Vertical

      If EditEx()\Cursor\Row < EditEx()\Visible\RowOffset
        EditEx()\Visible\RowOffset = EditEx()\Cursor\Row
        If EditEx()\Visible\RowOffset < 0 : EditEx()\Visible\RowOffset = 0 : EndIf
      EndIf
      
      PageRows = Round(EditEx()\Visible\Height / EditEx()\Text\Height, #PB_Round_Down)
      If EditEx()\Cursor\Row => PageRows
        EditEx()\Visible\RowOffset = EditEx()\Cursor\Row - PageRows + 1
      EndIf
      
    EndIf
    
    If PosOffSet <> EditEx()\Visible\PosOffset Or RowOffSet <> EditEx()\Visible\RowOffset
      ProcedureReturn #True
    EndIf   
    
    ProcedureReturn #False
  EndProcedure
  
 
  Procedure   Draw_()
    Define.i PosX, PosY, PosOffset, RowOffsetH, Width, Height
    Define.i FrontColor.i, BackColor.i, BorderColor.i
    Define.s Row$
    
    If EditEx()\Hide : ProcedureReturn #False : EndIf
    
    If StartDrawing(CanvasOutput(EditEx()\CanvasNum)) 
      
      Width  = dpiX(GadgetWidth(EditEx()\CanvasNum))
      Height = dpiY(GadgetHeight(EditEx()\CanvasNum))
      
      If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf
      
      FrontColor  = EditEx()\Color\Front
      BackColor   = EditEx()\Color\Back
      BorderColor = EditEx()\Color\Border
      
      If EditEx()\Disable
        FrontColor  = EditEx()\Color\DisableFront
        BackColor   = BlendColor_(EditEx()\Color\DisableBack, EditEx()\Color\Gadget, 10)
        BorderColor = EditEx()\Color\DisableFront
      EndIf  
      
      ;{ _____ ScrollBars _____
      If EditEx()\ScrollBar\Item("VScroll")\Hide = #False
        If EditEx()\ScrollBar\Flags = #False
          EditEx()\ScrollBar\Item("VScroll")\X      = Width - dpiX(#Scroll_Width) - dpiX(1)
          EditEx()\ScrollBar\Item("VScroll")\Y      = dpiY(1)
          EditEx()\ScrollBar\Item("VScroll")\Width  = dpiX(#Scroll_Width)
          EditEx()\ScrollBar\Item("VScroll")\Height = Height - dpiY(2)
        Else
          EditEx()\ScrollBar\Item("VScroll")\X      = Width - dpiX(#Scroll_Width)
          EditEx()\ScrollBar\Item("VScroll")\Y      = 0
          EditEx()\ScrollBar\Item("VScroll")\Width  = dpiX(#Scroll_Width)
          EditEx()\ScrollBar\Item("VScroll")\Height = Height
        EndIf

        CalcScrollBarThumb_("VScroll", #False)
        
      EndIf
      
      If EditEx()\ScrollBar\Item("HScroll")\Hide = #False
        EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item("HScroll")\Pos
        If EditEx()\ScrollBar\Flags = #False
          EditEx()\ScrollBar\Item("HScroll")\X      = dpiX(1)
          EditEx()\ScrollBar\Item("HScroll")\Y      = Height - dpiY(#Scroll_Width) - dpiY(1)
          EditEx()\ScrollBar\Item("HScroll")\Width  = Width - dpiX(2)
          EditEx()\ScrollBar\Item("HScroll")\Height = dpiY(#Scroll_Width)
        Else
          EditEx()\ScrollBar\Item("HScroll")\X      = 0
          EditEx()\ScrollBar\Item("HScroll")\Y      = Height - dpiY(#Scroll_Width)
          EditEx()\ScrollBar\Item("HScroll")\Width  = Width
          EditEx()\ScrollBar\Item("HScroll")\Height = dpiY(#Scroll_Width)
        EndIf 
        CalcScrollBarThumb_("HScroll", #False)
      EndIf ;}
      
      ;{ _____ Draw Background _____
      DrawingMode(#PB_2DDrawing_Default) 
      Box(0, 0, Width, Height, BackColor)  
      ;}
      
      PosOffset = dpiX(EditEx()\Visible\PosOffset)
      RowOffsetH = EditEx()\Visible\RowOffset * EditEx()\Text\Height

      ;{ _____ Draw Text _____
      ForEach EditEx()\Row()
        
        PosX = EditEx()\Row()\X - PosOffset
        PosY = EditEx()\Row()\Y - RowOffsetH
        
        DrawingMode(#PB_2DDrawing_Transparent)
        
        If PosY + EditEx()\Text\Height < 0 : Continue : EndIf
        
        Row$ = Mid(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Row()\Len)
        If Left(EditEx()\Row()\WordWrap, 1) = "-" : Row$ + "-" : EndIf
        
        If EditEx()\Flags & #CtrlChars : Row$ = ReplaceString(Row$, #LF$, #Paragraph$) : EndIf

        DrawText(PosX, PosY, RTrim(Row$, #LF$), FrontColor)
        
        DrawingMode(#PB_2DDrawing_Default)
        
        If Not EditEx()\Disable
          ForEach EditEx()\Row()\Highlight()
            PosX = EditEx()\Row()\Highlight()\X - PosOffset
            DrawText(PosX, PosY, EditEx()\Row()\Highlight()\String, EditEx()\Row()\Highlight()\Color, BackColor)
          Next  
        EndIf
        
        If Not EditEx()\Disable
          If EditEx()\Selection\Flag & #Selected And EditEx()\Row()\Selection\State
            PosX = EditEx()\Row()\Selection\X - PosOffset
            DrawText(PosX, PosY, EditEx()\Row()\Selection\String, EditEx()\Color\HighlightText, EditEx()\Color\Highlight)
          EndIf  
        EndIf
        
        If PosY + EditEx()\Text\Height > dpiY(EditEx()\Visible\Height) : Break : EndIf
        
      Next ;}
      
      ;{ _____ Cursor _____
      If EditEx()\Cursor\Pos = 0                     ;{ Empty text
        EditEx()\Cursor\X   = dpiX(EditEx()\Size\PaddingX)
        EditEx()\Cursor\Y   = dpiY(EditEx()\Size\PaddingY)
        EditEx()\Cursor\Row = 0
        EditEx()\Cursor\BackChar = ""
        ;}
      ElseIf EditEx()\Cursor\Pos > EditEx()\Text\Len ;{ After last character
       
        If LastElement(EditEx()\Row())
          
          If Mid(EditEx()\Text$, EditEx()\Cursor\Pos - 1, 1) = #LF$
            EditEx()\Cursor\X = EditEx()\Row()\X  - PosOffset
          Else
            EditEx()\Cursor\X = EditEx()\Row()\X  - PosOffset + TextWidth(Mid(EditEx()\Text$, EditEx()\Row()\Pos))
          EndIf

          EditEx()\Cursor\Y   = EditEx()\Row()\Y - RowOffsetH
          EditEx()\Cursor\Row = ListIndex(EditEx()\Row())
          EditEx()\Cursor\BackChar = ""
          
        EndIf
        ;}
      Else                                           ;{ Normal Cursor position
        
        ForEach EditEx()\Row()
          
          If EditEx()\Cursor\Pos >= EditEx()\Row()\Pos And EditEx()\Cursor\Pos <= EditEx()\Row()\Pos + EditEx()\Row()\Len
            
            If EditEx()\Cursor\Pos = EditEx()\Row()\Pos + EditEx()\Row()\Len
              
              If ListIndex(EditEx()\Row()) = ListSize(EditEx()\Row()) - 1
                EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset + TextWidth(RTrim(StringSegment(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Cursor\Pos), #LF$))
                EditEx()\Cursor\BackChar = ""
              Else
                If NextElement(EditEx()\Row())
                  EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset
                  EditEx()\Cursor\BackChar = Mid(EditEx()\Text$, EditEx()\Cursor\Pos, 1)
                EndIf
              EndIf  
    
            Else  
              EditEx()\Cursor\X = EditEx()\Row()\X - PosOffset + TextWidth(RTrim(StringSegment(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Cursor\Pos), #LF$))
              EditEx()\Cursor\BackChar = Mid(EditEx()\Text$, EditEx()\Cursor\Pos, 1)
            EndIf
            
            EditEx()\Cursor\Y   = EditEx()\Row()\Y - RowOffsetH
            EditEx()\Cursor\Row = ListIndex(EditEx()\Row())
            
            Break  
          EndIf  
          
        Next
        ;}
      EndIf
      ;}
      
      ;{ _____ Padding _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, Height - EditEx()\Size\PaddingY, Width, dpiY(EditEx()\Size\PaddingY), BackColor)
      Box(Width - EditEx()\Size\PaddingX, 0, dpiX(EditEx()\Size\PaddingX), Height, BackColor)
      If EditEx()\ScrollBar\Item("VScroll")\Hide = #False
        Box(Width - dpiX(#Scroll_Width), dpiX(1), dpiX(#Scroll_Width), Height - dpiY(2), EditEx()\Color\ScrollBar)
      EndIf
      If EditEx()\ScrollBar\Item("HScroll")\Hide = #False
        Box(dpiX(1), Height - dpiX(#Scroll_Width), Width - dpiY(2), dpiX(#Scroll_Width), EditEx()\Color\ScrollBar)
      EndIf
      ;}
      
      ;{ _____ Border _____
      If EditEx()\Flags & #Borderless = #False
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(0, 0, Width, Height, BorderColor)
      EndIf ;}

      StopDrawing()
    EndIf
    
    If EditEx()\ScrollBar\Item("VScroll")\Hide = #False : DrawScrollBar_("VScroll") : EndIf
    If EditEx()\ScrollBar\Item("HScroll")\Hide = #False : DrawScrollBar_("HScroll") : EndIf
    
  EndProcedure
  
  
  Procedure   ReDraw_(OffSet.i=#True)
    
    CalcRows_()
    
    AdjustScrolls_()
    
    If OffSet : CalcCursorOffset() : EndIf
    
    Draw_()
    
  EndProcedure

  ;- __________ Events __________
  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach EditEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          EditEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        If ModuleEx::ThemeGUI\ScrollBar : EditEx()\ScrollBar\Flags = ModuleEx::ThemeGUI\ScrollBar : EndIf 
        
        EditEx()\Color\Front         = ModuleEx::ThemeGUI\FrontColor
        EditEx()\Color\Back          = ModuleEx::ThemeGUI\BackColor
        EditEx()\Color\Border        = ModuleEx::ThemeGUI\BorderColor
        EditEx()\Color\Cursor        = ModuleEx::ThemeGUI\FrontColor
        EditEx()\Color\HighlightText = ModuleEx::ThemeGUI\Focus\FrontColor
        EditEx()\Color\Highlight     = ModuleEx::ThemeGUI\Focus\BackColor
        EditEx()\Color\ScrollBar     = ModuleEx::ThemeGUI\ScrollbarColor
        EditEx()\Color\DisableFront  = ModuleEx::ThemeGUI\Disable\FrontColor
        EditEx()\Color\DisableBack   = ModuleEx::ThemeGUI\Disable\BackColor
        
        EditEx()\ScrollBar\Color\Front     = ModuleEx::ThemeGUI\FrontColor
  			EditEx()\ScrollBar\Color\Back      = ModuleEx::ThemeGUI\BackColor
  			EditEx()\ScrollBar\Color\Border    = ModuleEx::ThemeGUI\BorderColor
  			EditEx()\ScrollBar\Color\Gadget    = ModuleEx::ThemeGUI\GadgetColor
  			EditEx()\ScrollBar\Color\Focus     = ModuleEx::ThemeGUI\FocusBack
        EditEx()\ScrollBar\Color\Button    = ModuleEx::ThemeGUI\Button\BackColor
        EditEx()\ScrollBar\Color\ScrollBar = ModuleEx::ThemeGUI\ScrollbarColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf    
  
  
  Procedure _TimerThread(Frequency.i)
    Define.i ElapsedTime
    
    Repeat
      
      If ElapsedTime >= Frequency
        PostEvent(#Event_Timer)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until TimerThread\Exit
    
  EndProcedure
  
  Procedure _AutoScroll()
    Define.i X, Y
    
    ForEach EditEx()
      
      If GetActiveGadget() <> EditEx()\CanvasNum : Continue : EndIf
      
      ForEach EditEx()\ScrollBar\Item()
        
        If EditEx()\ScrollBar\Item()\Hide : Continue : EndIf
        
        If EditEx()\ScrollBar\Item()\Timer
          
          If EditEx()\ScrollBar\Item()\TimerDelay
            EditEx()\ScrollBar\Item()\TimerDelay - 1
            Continue
          EndIf  

          Select EditEx()\ScrollBar\Item()\Timer
            Case #ScrollBar_Left   
              EditEx()\ScrollBar\Item()\Pos - 1
              If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos
                EditEx()\ScrollBar\Item()\Pos   = EditEx()\ScrollBar\Item()\minPos
                EditEx()\ScrollBar\Item()\Timer = #False
              EndIf
              EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item()\Pos
              Draw_()
            Case #ScrollBar_Up 
              EditEx()\ScrollBar\Item()\Pos - 1
              If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos
                EditEx()\ScrollBar\Item()\Pos   = EditEx()\ScrollBar\Item()\minPos
                EditEx()\ScrollBar\Item()\Timer = #False
              EndIf
              EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
              Draw_()
            Case #ScrollBar_Down 
              EditEx()\ScrollBar\Item()\Pos + 1
              If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos
                EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos
                EditEx()\ScrollBar\Item()\Timer = #False
              EndIf
              EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
              Draw_()
            Case #ScrollBar_Right
              EditEx()\ScrollBar\Item()\Pos + 1
              If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos
                EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos
                EditEx()\ScrollBar\Item()\Timer = #False
              EndIf
              EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item()\Pos
              Draw_()
            Default
              EditEx()\ScrollBar\Item()\Timer = #False
          EndSelect

    		EndIf 
    		
      Next
      
    Next
    
  EndProcedure
  
  
  Procedure _ListViewHandler()
    Define.i GNum, Selected
    Define.i ListNum.i = EventGadget()
    
    If IsGadget(ListNum)
      
      GNum = GetGadgetData(ListNum)
      If FindMapElement(EditEx(), Str(GNum))
        
        HideWindow(EditEx()\WinNum, #True)
        
        If GetGadgetState(ListNum) <> -1
          EditEx()\Cursor\Pos = EditEx()\Selection\Pos1
          DeleteSelection_()
          EditEx()\Text$ = InsertString(EditEx()\Text$, GetGadgetText(ListNum), EditEx()\Cursor\Pos)
          ReDraw_()
        EndIf  
        
        EditEx()\Visible\WordList = #False
      EndIf
      
    EndIf
    
  EndProcedure
  
  CompilerIf #Enable_SpellChecking
    
    Procedure _ButtonHandler()
      Define.i GNum
      Define.s Word$
      Define.i ButtonNum.i = EventGadget()
      
      GNum = GetGadgetData(ButtonNum)
      If FindMapElement(EditEx(), Str(GNum))
        
        HideWindow(EditEx()\WinNum, #True)
        
        Word$ = GetSelection_()
        If Word$ : AddToUserDictionary_(Word$) : EndIf
  
        EditEx()\Visible\WordList = #False
        
        ReDraw_()
      EndIf
  
    EndProcedure
    
  CompilerEndIf
  
  ;- --- Cursor-Handler ---  
  
  Procedure _CursorDrawing() ; Trigger from Thread (PostEvent Change)
    Define.i WindowNum = EventWindow()
    
    ForEach EditEx()
      
      If IsGadget(EditEx()\CanvasNum) = #False : Continue : EndIf
      
      If EditEx()\Cursor\Pause = #False
        
        EditEx()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(EditEx()\CanvasNum)) 
          
          DrawingMode(#PB_2DDrawing_Default)
          
          If EditEx()\Cursor\State
            
            Line(EditEx()\Cursor\X, EditEx()\Cursor\Y, 1, EditEx()\Cursor\Height, EditEx()\Color\Cursor)
            
          Else
            
            If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf

            If EditEx()\Cursor\BackChar
              DrawText(EditEx()\Cursor\X, EditEx()\Cursor\Y, EditEx()\Cursor\BackChar, EditEx()\Cursor\FrontColor, EditEx()\Cursor\BackColor)
            Else
              Line(EditEx()\Cursor\X, EditEx()\Cursor\Y, 1, EditEx()\Cursor\Height, EditEx()\Color\Back)
            EndIf
            
          EndIf
          StopDrawing()
        EndIf
        
      ElseIf EditEx()\Cursor\State
        
        If StartDrawing(CanvasOutput(EditEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          Line(EditEx()\Cursor\X, EditEx()\Cursor\Y, 1, EditEx()\Cursor\Height, EditEx()\Color\Back)
          StopDrawing()
        EndIf
      
      EndIf
      
    Next
    
  EndProcedure 
 
  Procedure _CursorThread(Frequency.i)
    Define.i ElapsedTime
    
    Repeat
      
      If ElapsedTime >= Frequency
        PostEvent(#Event_Cursor)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until Thread\Exit
    
  EndProcedure
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      EditEx()\Cursor\Pause = #False
      EditEx()\Cursor\State = #False
      
      PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Focus)
    EndIf  
 
  EndProcedure
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      EditEx()\Cursor\Pause = #True
      _CursorDrawing()
      
      ;PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_LostFocus)
    EndIf
    
  EndProcedure  
  
  ;- --- Key-Handler ---  
  
  Procedure _KeyDownHandler() ; Handle Shortcuts
    Define.i GNum = EventGadget()
    Define.i Key, Modifier, CursorRow, CursorPos, Pos1, Pos2, ReDraw
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Key       = GetGadgetAttribute(GNum, #PB_Canvas_Key)
      Modifier  = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
      
      CursorPos = EditEx()\Cursor\Pos
      CursorRow = EditEx()\Cursor\Row
      
      ;{ Selection
      If EditEx()\Selection\Flag = #Selected
        If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
          Pos1 = EditEx()\Selection\Pos2
          Pos2 = EditEx()\Selection\Pos1
        Else
          Pos1 = EditEx()\Selection\Pos1
          Pos2 = EditEx()\Selection\Pos2
        EndIf 
      EndIf ;}
      
      Select Key
        Case #PB_Shortcut_Left     ;{ Left
          
          If Modifier & #PB_Canvas_Shift And Modifier & #PB_Canvas_Control ;{ Selection up to the beginning of the word

            EditEx()\Cursor\Pos = WordStart_(EditEx()\Text$, CursorPos)
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Shift                               ;{ Selection left
            
            If EditEx()\Cursor\Pos > 1
              
              EditEx()\Cursor\Pos - 1 
              
              If EditEx()\Selection\Flag = #NoSelection
                EditEx()\Selection\Pos1 = CursorPos
                EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
                EditEx()\Selection\Flag = #Selected
              Else
                EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EndIf

            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control                             ;{ Start of word
            
            EditEx()\Cursor\Pos = WordStart_(EditEx()\Text$, CursorPos)
            
            If EditEx()\Selection\Flag = #Selected
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          Else                                                             ;{ Cursor left
            
            If CursorPos > 1
              EditEx()\Cursor\Pos - 1
            EndIf
            
            RemoveSelection_()
            ;}
          EndIf
          
          ReDraw = #True
          ;}
        Case #PB_Shortcut_Right    ;{ Right
          
          If Modifier & #PB_Canvas_Shift And Modifier & #PB_Canvas_Control ;{ Selection up to the end of the word
            
            EditEx()\Cursor\Pos = WordEnd_(EditEx()\Text$, CursorPos)
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Shift                               ;{ Selection right
            
            If EditEx()\Cursor\Pos < EditEx()\Text\Len
              
              EditEx()\Cursor\Pos + 1 
              
              If EditEx()\Selection\Flag = #NoSelection
                EditEx()\Selection\Pos1 = CursorPos
                EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
                EditEx()\Selection\Flag = #Selected
              Else
                EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EndIf

            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control                             ;{ End of word
            
            EditEx()\Cursor\Pos = WordEnd_(EditEx()\Text$, CursorPos)
            
            If EditEx()\Selection\Flag = #Selected
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          Else                                                             ;{ Cursor right

            If CursorPos <= EditEx()\Text\Len
              EditEx()\Cursor\Pos + 1
            EndIf
            
            RemoveSelection_()
            ;}
          EndIf
          
          ReDraw = #True
          ;}
        Case #PB_Shortcut_Up       ;{ Up
          
          If Modifier & #PB_Canvas_Shift       ;{ Selection up
            
            CursorUpDown_(#Cursor_Up)
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control ;{ Previous paragraph
            
            EditEx()\Cursor\Pos = Paragraph_(#Cursor_Up)
            
            RemoveSelection_() 
            ;}
          Else                                 ;{ Cursor  up
            
            CursorUpDown_(#Cursor_Up)
            
            RemoveSelection_()
            ;}
          EndIf
          
          ReDraw = #True
          ;}
        Case #PB_Shortcut_Down     ;{ Down
          
          If Modifier & #PB_Canvas_Shift       ;{ Selection down
            
            CursorUpDown_(#Cursor_Down)
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control ;{ Next paragraph
            
            EditEx()\Cursor\Pos = Paragraph_(#Cursor_Down)
            
            RemoveSelection_()
            ;}
          Else                                 ;{ Cursor down

            CursorUpDown_(#Cursor_Down)
            
            RemoveSelection_()
            ;}
          EndIf
          
          ReDraw = #True
          ;}
        Case #PB_Shortcut_PageUp   ;{ PageUp
          
          CursorRow = EditEx()\Cursor\Row - PageRows_() + 1
          If CursorRow < 0 : CursorRow = 0 : EndIf
          
          If SelectElement(EditEx()\Row(), CursorRow)
            EditEx()\Cursor\Pos = EditEx()\Row()\Pos
          EndIf  
          
          RemoveSelection_()
          ReDraw = #True
          ;}
        Case #PB_Shortcut_PageDown ;{ PageDown
          
          CursorRow = EditEx()\Cursor\Row + PageRows_() + 1
          If CursorRow >= ListSize(EditEx()\Row()) : CursorRow = ListSize(EditEx()\Row()) - 1 : EndIf
          
          If SelectElement(EditEx()\Row(), CursorRow)
            EditEx()\Cursor\Pos = EditEx()\Row()\Pos
          EndIf 
          
          RemoveSelection_()
          ReDraw = #True
          ;}
        Case #PB_Shortcut_Home     ;{ Home / Pos1
          
          If Modifier & #PB_Canvas_Control
           
            EditEx()\Cursor\Pos = 1

            RemoveSelection_()
            
          ElseIf Modifier & #PB_Canvas_Shift
            
            If SelectElement(EditEx()\Row(), EditEx()\Cursor\Row)
              EditEx()\Cursor\Pos = EditEx()\Row()\Pos
            EndIf
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            
          Else
            
            If SelectElement(EditEx()\Row(), EditEx()\Cursor\Row)
              EditEx()\Cursor\Pos = EditEx()\Row()\Pos
            EndIf
            
            RemoveSelection_()
          EndIf
          
          ReDraw = #True
          ;}
        Case #PB_Shortcut_End      ;{ End
          
          If Modifier & #PB_Canvas_Control
            
            EditEx()\Cursor\Pos = EditEx()\Text\Len + 1
            
            RemoveSelection_()
            
          ElseIf Modifier & #PB_Canvas_Shift
            
            If SelectElement(EditEx()\Row(), EditEx()\Cursor\Row)
              EditEx()\Cursor\Pos = EditEx()\Row()\Pos + EditEx()\Row()\Len
            EndIf
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            
          Else
            
            If SelectElement(EditEx()\Row(), EditEx()\Cursor\Row)
              EditEx()\Cursor\Pos = EditEx()\Row()\Pos + EditEx()\Row()\Len
              If Mid(EditEx()\Text$, EditEx()\Cursor\Pos - 1, 1) = #LF$
                EditEx()\Cursor\Pos - 1
              EndIf  
            EndIf

            RemoveSelection_()
          EndIf
          
          ReDraw = #True
          ;}
        Case #PB_Shortcut_Return   ;{ Return
          
          If EditEx()\Flags & #ReadOnly = #False
            
            EditEx()\Text$    = InsertString(EditEx()\Text$, #LF$, EditEx()\Cursor\Pos)
            EditEx()\Text\Len = Len(EditEx()\Text$)
            EditEx()\Cursor\Pos + 1
            
            RemoveSelection_()

            CompilerIf #Enable_SpellChecking
              
              If EditEx()\Flags & #AutoSpellCheck
                UpdateWordList_()
                SpellChecking_(#True)
              EndIf
              
            CompilerEndIf 
            
            CompilerIf #Enable_UndoRedo
              AddUndo_()
            CompilerEndIf
            
            PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_NewLine)
            PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_NewLine)
            
            ReDraw = #True
          EndIf
          ;}
        Case #PB_Shortcut_Delete   ;{ Delete / Cut (Shift)
          
          If EditEx()\Flags & #ReadOnly = #False
            
            If Modifier & #PB_Canvas_Shift ;{ Cut selected text to clipboard
              
              If EditEx()\Selection\Flag = #Selected
                SetClipboardText(GetSelection_(#False))
                DeleteSelection_(#False)
              EndIf
              ;}
            Else                           ;{ Delete text/character

              If EditEx()\Selection\Flag = #Selected ; And (CursorPos >= Pos1 And CursorPos <= Pos2)
                DeleteSelection_(#False)
              Else 
                EditEx()\Text$ = DeleteStringPart(EditEx()\Text$, EditEx()\Cursor\Pos)
              EndIf
              ;}
            EndIf
            
            PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            
            RemoveSelection_()
            
            ReDraw = #True
          EndIf
          ;}
        Case #PB_Shortcut_Back     ;{ Back
          
          If EditEx()\Flags & #ReadOnly = #False
            
            If CursorPos > 1
              
              If EditEx()\Selection\Flag = #Selected ;And (CursorPos > Pos1 And CursorPos <= Pos2)
                
                DeleteSelection_(#False)
                
              Else
                
                EditEx()\Text$ = DeleteStringPart(EditEx()\Text$, EditEx()\Cursor\Pos - 1)
                
                EditEx()\Cursor\Pos - 1
                If EditEx()\Cursor\Pos < 1 : EditEx()\Cursor\Pos = 1 : EndIf

              EndIf
              
            EndIf
            
            PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            
            RemoveSelection_()
            
            ReDraw = #True
          EndIf
          ;}
        Case #PB_Shortcut_C        ;{ Copy  (Ctrl)
          
          If Modifier & #PB_Canvas_Control
            
            If EditEx()\Selection\Flag = #Selected
              SetClipboardText(GetSelection_())
            EndIf
            
          EndIf
          ;}
        Case #PB_Shortcut_V        ;{ Paste (Ctrl)
          
          If EditEx()\Flags & #ReadOnly = #False
            
            If Modifier & #PB_Canvas_Control
              
              Text$ = GetClipboardText()
              Text$ = ReplaceString(Text$, #CRLF$, #LF$)
              Text$ = ReplaceString(Text$, #CR$, #LF$)
              
              If EditEx()\Selection\Flag = #Selected
                DeleteSelection_()
              EndIf
              
              EditEx()\Text$ = InsertString(EditEx()\Text$, Text$, EditEx()\Cursor\Pos)
              EditEx()\Cursor\Pos + Len(Text$)
              
              CompilerIf #Enable_UndoRedo
                AddUndo_()
              CompilerEndIf
              
              PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              
              ReDraw = #True
            EndIf
            
          EndIf
          ;}
        Case #PB_Shortcut_X        ;{ Cut   (Ctrl)
          
          If EditEx()\Flags & #ReadOnly = #False
            
            If Modifier & #PB_Canvas_Control
              
              If EditEx()\Selection\Flag = #Selected

                SetClipboardText(GetSelection_(#False))
                DeleteSelection_(#False)
                
                CompilerIf #Enable_UndoRedo
                  AddUndo_()
                CompilerEndIf
                
              EndIf
              
              PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              
              RemoveSelection_()
              
              ReDraw = #True
            EndIf 
            
          EndIf
          ;}
        Case #PB_Shortcut_Insert   ;{ Copy  (Ctrl) / Paste (Shift)
          
          If EditEx()\Flags & #ReadOnly = #False
            
            If Modifier & #PB_Canvas_Shift
              
              Text$ = GetClipboardText()
              Text$ = ReplaceString(Text$, #CRLF$, #LF$)
              Text$ = ReplaceString(Text$, #CR$, #LF$)
              
              If EditEx()\Selection\Flag = #Selected
                DeleteSelection_()
              EndIf
              
              EditEx()\Text$ = InsertString(EditEx()\Text$, Text$, EditEx()\Cursor\Pos)
              EditEx()\Cursor\Pos + Len(Text$)
              
              PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              
              CompilerIf #Enable_UndoRedo
                AddUndo_()
              CompilerEndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If EditEx()\Selection\Flag = #Selected
                
                Text$ = GetSelection_()
                
                SetClipboardText(Text$)
                
              EndIf
              
            EndIf
            
            ReDraw = #True
          EndIf 
          ;}
        Case #PB_Shortcut_Hyphen   ;{ Minus (Ctrl)   
          
          If Modifier & #PB_Canvas_Control
            
            EditEx()\Text$ = InsertString(EditEx()\Text$, #SoftHyphen$, EditEx()\Cursor\Pos)
            EditEx()\Cursor\Pos + 1
            
            PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            
            ReDraw = #True
          EndIf
          ;}
        Case #PB_Shortcut_A        ;{ Ctrl-A (Select all)
          
          If Modifier & #PB_Canvas_Control
            
            EditEx()\Cursor\Pos     = EditEx()\Text\Len + 1
            EditEx()\Selection\Flag = #Selected
            EditEx()\Selection\Pos1 = 1
            EditEx()\Selection\Pos2 = EditEx()\Text\Len + 1
            
            ReDraw = #True
          EndIf
          ;}
        Case #PB_Shortcut_Z        ;{ Crtl-Z (Undo)
          
          CompilerIf #Enable_UndoRedo
            
            If Modifier & #PB_Canvas_Control
              Undo_()
              PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
              ReDraw = #True
            EndIf 

          CompilerEndIf
          ;}
        Case #PB_Shortcut_D        ;{ Ctrl-D (Delete selection)
          
          If Modifier & #PB_Canvas_Control
            DeleteSelection_()
            EditEx()\Cursor\Pos = Pos1
            PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
            ReDraw = #True
          EndIf
          ;}
      EndSelect
      
      If ReDraw : ReDraw_() : EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _InputHandler()   ; Input character
    Define.i GNum = EventGadget()
    Define.i Char
    
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\Flags & #ReadOnly = #False

        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
        
        DeleteSelection_(#False)
        
        If EditEx()\Cursor\Pos = 0 : EditEx()\Cursor\Pos = 1 : EndIf
        
        EditEx()\Text$ = InsertString(EditEx()\Text$, Chr(Char), EditEx()\Cursor\Pos)
        
        EditEx()\Cursor\Pos + 1

        RemoveSelection_()
        
        CompilerIf #Enable_UndoRedo
          
          Select Char
            Case 32, 33, 58, 59, 63
              AddUndo_()
          EndSelect
          
        CompilerEndIf
        
        CompilerIf #Enable_SpellChecking
          
          If EditEx()\Flags & #AutoSpellCheck
            
            Select Char
              Case 32, 33, 41, 44, 46
                UpdateWordList_()
                SpellChecking_(#True)
              Case 58, 59, 63, 93, 125
                UpdateWordList_()
                SpellChecking_(#True)
            EndSelect
            
          EndIf
          
        CompilerEndIf
        
        PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
        PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
        
        ReDraw_()
        
      EndIf
      
    EndIf
    
  EndProcedure 
  
  ;- --- Mouse-Handler ---
  
  Procedure _RightClickHandler()
    Define.i GNum = EventGadget()
    Define.i X, Y, CursorPos, sWord, eWord
    Define.s Word$
    
    If FindMapElement(EditEx(), Str(GNum))

      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      CompilerIf #Enable_SpellChecking
        
        If EditEx()\Visible\WordList = #True
          HideWindow(EditEx()\WinNum, #True)
          EditEx()\Visible\WordList = #False
        EndIf 
        
        If EditEx()\Flags & #Suggestions
          
          CursorPos = CursorPos_(X, Y, #False)
          If CursorPos
            
            sWord = WordStart_(EditEx()\Text$, CursorPos)
            eWord = WordEnd_(EditEx()\Text$ , CursorPos)
            Word$ = StringSegment(EditEx()\Text$, sWord, eWord)
            
            ForEach EditEx()\Mistake()
              
              If Word$ = MapKey(EditEx()\Mistake())
                EditEx()\Selection\Pos1 = sWord
                EditEx()\Selection\Pos2 = eWord
                EditEx()\Selection\Flag = #Selected
                EditEx()\Cursor\Pos = EditEx()\Selection\Pos2
                ReDraw_(#False)
                
                CorrectionSuggestions_(Word$)
                ResizeList_(sWord)
                ClearGadgetItems(EditEx()\ListNum)
                ForEach EditEx()\Suggestions()
                  AddGadgetItem(EditEx()\ListNum, -1, EditEx()\Suggestions())
                Next  
                EditEx()\Visible\WordList = #True
                HideWindow(EditEx()\WinNum, #False)
                
                ProcedureReturn #True
              EndIf   
              
            Next
            
          EndIf
          
        EndIf
        
      CompilerEndIf
      
      If IsMenu(EditEx()\PopupMenu) 
        If IsTextArea_(X, Y)
          DisplayPopupMenu(EditEx()\PopupMenu, WindowID(EditEx()\Window\Num))
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure

  Procedure _LeftButtonDownHandler()
    Define.i GNum = EventGadget()
    Define.i X, Y, CursorPos
    Define.s ScrollBar
    
    If FindMapElement(EditEx(), Str(GNum))
      
      X   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      EditEx()\Mouse\LeftButton = #True
      
      ForEach EditEx()\ScrollBar\Item() ;{ ScrollBar
      
        If EditEx()\ScrollBar\Item()\Hide : Continue : EndIf 
        
        EditEx()\ScrollBar\Item()\Cursor = #PB_Default
        
        ScrollBar = MapKey(EditEx()\ScrollBar\Item())
  
  			If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  			  
  			  If X >= EditEx()\ScrollBar\Item()\X And X <= EditEx()\ScrollBar\Item()\X + EditEx()\ScrollBar\Item()\Width
  			    
    			  If Y >= EditEx()\ScrollBar\Item()\Buttons\Backwards\Y And Y <= EditEx()\ScrollBar\Item()\Buttons\Backwards\Y + EditEx()\ScrollBar\Item()\Buttons\Backwards\Height
    			    ;{ Backwards Button
    			    If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Click)
    			      EditEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      EditEx()\ScrollBar\Item()\Timer      = #ScrollBar_Up
    			      EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Click 
    			    EndIf ;}
    			  ElseIf Y >= EditEx()\ScrollBar\Item()\Buttons\Forwards\Y And Y <= EditEx()\ScrollBar\Item()\Buttons\Forwards\Y + EditEx()\ScrollBar\Item()\Buttons\Forwards\Height
    			    ;{ Forwards Button
    			    If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Click)
    			      EditEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      EditEx()\ScrollBar\Item()\Timer      = #ScrollBar_Down
    			      EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Click
    			    EndIf ;}
    			  ElseIf Y >= EditEx()\ScrollBar\Item()\Thumb\Y And Y <= EditEx()\ScrollBar\Item()\Thumb\Y + EditEx()\ScrollBar\Item()\Thumb\Height
    			    ;{ Thumb Button
    			    If EditEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Click
    			      EditEx()\ScrollBar\Item()\Thumb\State = #ScrollBar_Click
    			      EditEx()\ScrollBar\Item()\Cursor = Y
    			      DrawScrollBar_(ScrollBar)
    			    EndIf ;} 
    			  EndIf

    			  ProcedureReturn #True
  			  EndIf
  			  
  			Else
  			  
  			  If Y >= EditEx()\ScrollBar\Item()\Y And Y <= EditEx()\ScrollBar\Item()\Y + EditEx()\ScrollBar\Item()\Height
  			    
    			  If X >= EditEx()\ScrollBar\Item()\Buttons\Backwards\X And X <= EditEx()\ScrollBar\Item()\Buttons\Backwards\X + EditEx()\ScrollBar\Item()\Buttons\Backwards\Width
    			    ;{ Backwards Button
    			    If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Click)
    			      EditEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      EditEx()\ScrollBar\Item()\Timer      = #ScrollBar_Left
    			      EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Click
    			    EndIf ;}
    			  ElseIf X >= EditEx()\ScrollBar\Item()\Buttons\Forwards\X And X <= EditEx()\ScrollBar\Item()\Buttons\Forwards\X + EditEx()\ScrollBar\Item()\Buttons\Forwards\Height
    			    ;{ Forwards Button
    			    If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Click)
    			      EditEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      EditEx()\ScrollBar\Item()\Timer      = #ScrollBar_Right
    			      EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Click
    			    EndIf ;}
    			  ElseIf X >= EditEx()\ScrollBar\Item()\Thumb\X And X <= EditEx()\ScrollBar\Item()\Thumb\X + EditEx()\ScrollBar\Item()\Thumb\Width
    			    ;{ Thumb Button
    			    If EditEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Click
    			      EditEx()\ScrollBar\Item()\Thumb\State = #ScrollBar_Click
    			      EditEx()\ScrollBar\Item()\Cursor = X
    			      DrawScrollBar_(ScrollBar)
    			    EndIf ;} 
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf
    			
  			EndIf
        ;}
      Next 
      
      CompilerIf #Enable_SpellChecking
        If EditEx()\Visible\WordList = #True
          HideWindow(EditEx()\WinNum, #True)
          EditEx()\Visible\WordList = #False
        EndIf  
      CompilerEndIf
      
      CursorPos = CursorPos_(X, Y)
      If CursorPos
        
        If GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)

          If CursorPos <> EditEx()\Cursor\LastPos
            EditEx()\Selection\Pos1 = EditEx()\Cursor\LastPos
            EditEx()\Selection\Pos2 = CursorPos
            EditEx()\Selection\Flag = #Selected
          EndIf
          
        Else  
          
          EditEx()\Selection\Pos1 = #PB_Default
          RemoveSelection_() 
          
        EndIf  
        
        EditEx()\Cursor\LastPos = CursorPos
        EditEx()\Cursor\LastX   = EditEx()\Cursor\X ; last cursor position for cursor up/down

        ReDraw_(#False)

      EndIf
    
      CompilerIf #Enable_UndoRedo
        ChangeUndoCursor_()
      CompilerEndIf

    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonUpHandler()
    Define.i GNum = EventGadget()
    Define.i CursorPos, X, Y
    Define.s ScrollBar
    
    If FindMapElement(EditEx(), Str(GNum))

      X   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)

      ForEach EditEx()\ScrollBar\Item()
        
        EditEx()\ScrollBar\Item()\Timer = #False
        
  		  If EditEx()\ScrollBar\Item()\Hide : Continue : EndIf 
  		  
  			EditEx()\ScrollBar\Item()\Cursor = #PB_Default
  			
  			ScrollBar = MapKey(EditEx()\ScrollBar\Item())

  			If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical ;{ Vertical Scrollbar
 
  			  If X >= EditEx()\ScrollBar\Item()\X And X <= EditEx()\ScrollBar\Item()\X + EditEx()\ScrollBar\Item()\Width
  			    
    			  If Y >= EditEx()\ScrollBar\Item()\Buttons\Backwards\Y And Y <= EditEx()\ScrollBar\Item()\Buttons\Backwards\Y + EditEx()\ScrollBar\Item()\Buttons\Backwards\Height
    			    EditEx()\ScrollBar\Item()\Pos - 1
    			    If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\minPos : EndIf
    			    EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  ElseIf Y >= EditEx()\ScrollBar\Item()\Buttons\Forwards\Y And Y <= EditEx()\ScrollBar\Item()\Buttons\Forwards\Y + EditEx()\ScrollBar\Item()\Buttons\Forwards\Height
    			    EditEx()\ScrollBar\Item()\Pos + 1
    			    If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos : EndIf
    			    EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  ElseIf Y < EditEx()\ScrollBar\Item()\Thumb\Y
    			    EditEx()\ScrollBar\Item()\Pos - EditEx()\ScrollBar\Item()\PageLength
    			    If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\minPos : EndIf
    			    EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  ElseIf Y > EditEx()\ScrollBar\Item()\Thumb\Y + EditEx()\ScrollBar\Item()\Thumb\Height
    			    EditEx()\ScrollBar\Item()\Pos + EditEx()\ScrollBar\Item()\PageLength
    			    If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos : EndIf
    			    EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf  
  			  ;}
  			Else                                                    ;{ Horizontal Scrollbar
  			  
  			  If Y >= EditEx()\ScrollBar\Item()\Y And Y <= EditEx()\ScrollBar\Item()\Y + EditEx()\ScrollBar\Item()\Height
  			    
    			  If X <= EditEx()\ScrollBar\Item()\Buttons\Backwards\X + EditEx()\ScrollBar\Item()\Buttons\Backwards\Width
    			    EditEx()\ScrollBar\Item()\Pos - 1
    			    If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\minPos : EndIf
    			    EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  ElseIf X >= EditEx()\ScrollBar\Item()\Buttons\Forwards\X
    			    EditEx()\ScrollBar\Item()\Pos + 1
    			    If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos : EndIf
    			    EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  ElseIf X < EditEx()\ScrollBar\Item()\Thumb\X
    			    EditEx()\ScrollBar\Item()\Pos - EditEx()\ScrollBar\Item()\PageLength
    			    If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\minPos : EndIf
    			    EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  ElseIf X > EditEx()\ScrollBar\Item()\Thumb\X + EditEx()\ScrollBar\Item()\Thumb\Width
    			    EditEx()\ScrollBar\Item()\Pos + EditEx()\ScrollBar\Item()\PageLength
    			    If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos : EndIf
    			    EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item()\Pos
    			    Draw_()
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf  
  			  ;}
  			EndIf
  			
  		Next
     
      If EditEx()\Mouse\Status = #Mouse_Select
        
        CursorPos = CursorPos_(X, Y)
        If CursorPos
          EditEx()\Selection\Pos2 = CursorPos
          EditEx()\Cursor\LastX   = EditEx()\Cursor\X ; last cursor position for cursor up/down
          ReDraw_(#False)
        EndIf
        
        EditEx()\Mouse\Status = #Mouse_Move
      EndIf
      
      EditEx()\Mouse\LeftButton = #False
    EndIf
    
  EndProcedure  
  
  Procedure _LeftDoubleClickHandler()
    Define.i GNum = EventGadget()
    Define.i X, Y, CursorPos
    Define.s Word$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      X   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)

      CursorPos = CursorPos_(X, Y)
      
      CompilerIf #Enable_SpellChecking
        If EditEx()\Visible\WordList = #True
          HideWindow(EditEx()\WinNum, #True)
          EditEx()\Visible\WordList = #False
        EndIf 
      CompilerEndIf
      
      If Mid(EditEx()\Text$, CursorPos, 1) = " "
        
        EditEx()\Selection\Pos1 = SpaceStart_(EditEx()\Text$, CursorPos)
        EditEx()\Selection\Pos2 = SpaceEnd_(EditEx()\Text$,   CursorPos)
        
      Else
        
        EditEx()\Selection\Pos1 = WordStart_(EditEx()\Text$, CursorPos)
        EditEx()\Selection\Pos2 = WordEnd_(EditEx()\Text$,   CursorPos)
        
      EndIf  
      
      If EditEx()\Selection\Pos1 <> EditEx()\Selection\Pos2
        
        EditEx()\Selection\Flag = #Selected
        EditEx()\Cursor\Pos     = EditEx()\Selection\Pos2
        
        CompilerIf #Enable_SpellChecking
          
          If EditEx()\Flags & #AutoSpellCheck
            
            Word$ = GetSelection_(#False)
            Word$ = GetWord_(Word$)
            If SpellCheck\Words(Word$)\checked = #False
              If SpellCheck(Word$) = #False
                SpellCheck\Words(Word$)\misspelled = #True
              EndIf
              SpellCheck\Words(Word$)\checked = #True
            EndIf
            
            If SpellCheck\Words(Word$)\misspelled = #True
              EditEx()\Mistake(Word$) = EditEx()\Color\SpellCheck
            EndIf
            
          EndIf
          
        CompilerEndIf
        
        ReDraw_(#False)
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseMoveHandler()
    Define.i GNum = EventGadget()
    Define.i CursorPos, LastCursorPos, X, Y
    Define.s ScrollBar
    
    If FindMapElement(EditEx(), Str(GNum))
      
      X   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      ForEach EditEx()\ScrollBar\Item() ;{ ScrollBars
      
  	    If EditEx()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(EditEx()\ScrollBar\Item())
  	    
  	    If EditEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical        ;{ Vertical Scrollbar

  	      If X >= EditEx()\ScrollBar\Item()\X And X <= EditEx()\ScrollBar\Item()\X + EditEx()\ScrollBar\Item()\Width
  	        
  	        If Y <= EditEx()\ScrollBar\Item()\Buttons\Backwards\Y + EditEx()\ScrollBar\Item()\Buttons\Backwards\Height
    			    ;{ Backwards Button
    			    If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Focus
    			      
    			      EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Focus
    			      
    			      If EditEx()\ScrollBar\Item()\Thumb\State <> #False
    			        EditEx()\ScrollBar\Item()\Thumb\State = #False
    			        DrawScrollBar_(ScrollBar)
    			      Else 
    			        DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Focus)
    			      EndIf 
    			      
    			    EndIf
  			      ;}
    			    ProcedureReturn #True
    			  ElseIf Y >= EditEx()\ScrollBar\Item()\Buttons\Forwards\Y
    			    ;{ Forwards Button
    			    If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Focus
    			      
    			      EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Focus
    			      
    			      If EditEx()\ScrollBar\Item()\Thumb\State <> #False
    			        EditEx()\ScrollBar\Item()\Thumb\State = #False
    			        DrawScrollBar_(ScrollBar)
    			      Else 
    			        DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Focus)
    			      EndIf
    			      
    			    EndIf ;}
    			    ProcedureReturn #True
    			  EndIf

    			  EditEx()\ScrollBar\Item()\Timer = #False
    			  
    			  If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
    			    EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
    			    DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
      			  ;}
      			EndIf
      			
      			If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
      			  EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
      			  DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
      			  ;}
      			EndIf
    
    			  If Y >= EditEx()\ScrollBar\Item()\Thumb\Y And Y <= EditEx()\ScrollBar\Item()\Thumb\Y + EditEx()\ScrollBar\Item()\Thumb\Height
    			    ;{ Move Thumb
    			    If EditEx()\ScrollBar\Item()\Cursor <> #PB_Default
    			      
    			      EditEx()\ScrollBar\Item()\Pos + GetSteps_(Y)
    			      
    			      If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos : EndIf
    			      If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\minPos : EndIf
    			      
    			      EditEx()\ScrollBar\Item()\Cursor = Y
    			      
    			      EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
    			      
    			      Draw_()
    			      
    		        ProcedureReturn #True
    		      EndIf ;}
    			    ;{ Thumb Focus
    			    If EditEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Focus
    			      EditEx()\ScrollBar\Item()\Thumb\State = #ScrollBar_Focus
    			      DrawScrollBar_(ScrollBar)
    			    EndIf ;} 
    			    ProcedureReturn #True
    			  EndIf
    			  
    			  EditEx()\ScrollBar\Item()\Timer = #False
    			  
    			  ProcedureReturn #True
    			EndIf  
  			  ;}
  	    Else                                                           ;{ Horizontal Scrollbar
  	      
  	      If Y >= EditEx()\ScrollBar\Item()\Y And Y <= EditEx()\ScrollBar\Item()\Y + EditEx()\ScrollBar\Item()\Height
  	      
    	      If X <= EditEx()\ScrollBar\Item()\Buttons\Backwards\X + EditEx()\ScrollBar\Item()\Buttons\Backwards\Width
    			    ;{ Backwards Button
    	        If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Focus
    			      DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Focus)
    			      EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Focus
    			    EndIf ;}
    			    ProcedureReturn #True
    			  ElseIf X >= EditEx()\ScrollBar\Item()\Buttons\Forwards\X
    			    ;{ Forwards Button
    			    If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Focus
    			      DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Focus)
    			      EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Focus
    			    EndIf ;}
    			    ProcedureReturn #True
    			  EndIf

    			  EditEx()\ScrollBar\Item()\Timer = #False
    			  
    			  If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
      			  DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
      			  EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
      			  ;}
      			EndIf
      			
      			If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
      			  DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
      			  EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
      			  ;}
      			EndIf
    			  
    			  If X >= EditEx()\ScrollBar\Item()\Thumb\X And X <= EditEx()\ScrollBar\Item()\Thumb\X + EditEx()\ScrollBar\Item()\Thumb\Width
    			    ;{ Thumb Button
    			    If EditEx()\ScrollBar\Item()\Cursor <> #PB_Default
    
    		        EditEx()\ScrollBar\Item()\Pos + GetSteps_(X)
    		        
    		        If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos : EndIf
    		        If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\minPos : EndIf
    		        
    		        EditEx()\ScrollBar\Item()\Cursor = X
    		        
    		        EditEx()\Visible\PosOffset = EditEx()\ScrollBar\Item()\Pos
    		        
    		        Draw_()
    		        
    		        ProcedureReturn #True
    		      EndIf ;}
    			    ;{ Thumb Focus
    			    If EditEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Focus
    			      EditEx()\ScrollBar\Item()\Thumb\State = #ScrollBar_Focus
    			      DrawScrollBar_(ScrollBar)
    			    EndIf ;} 
    			    ProcedureReturn #True
    			  EndIf
    			  
    			  EditEx()\ScrollBar\Item()\Timer = #False
    			  
    			  ProcedureReturn #True
  			  EndIf
  			  ;}
  			EndIf
  			
  			If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
  			  DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
  			  EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
  			  ;}
  			EndIf
  			
  			If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
  			  DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
  			  EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
  			  ;}
  			EndIf
  			
  			If EditEx()\ScrollBar\Item()\Thumb\State <> #False             ;{ Thumb Button
  			  EditEx()\ScrollBar\Item()\Thumb\State = #False
  			  DrawScrollBar_(ScrollBar)
  			  ;}
  			EndIf
  			
  			EditEx()\ScrollBar\Item()\Timer = #False
        ;}
  		Next

      LastCursorPos = EditEx()\Cursor\Pos
      
      If EditEx()\Mouse\LeftButton ;{ Left Mouse Button
        
        Select EditEx()\Mouse\Status
          Case #Mouse_Move   ;{ Start Selection
            
            If EditEx()\Selection\Flag = #NoSelection
              
              CursorPos = CursorPos_(X, Y)
              If CursorPos 

                If LastCursorPos <> CursorPos
               
                  EditEx()\Selection\Pos1 = LastCursorPos
                  EditEx()\Selection\Pos2 = CursorPos
                  EditEx()\Selection\Flag = #Selected
                  EditEx()\Mouse\Status   = #Mouse_Select
                  
                  ReDraw_(#False)
                EndIf
                
              EndIf
              
            EndIf  
            ;}
          Case #Mouse_Select ;{ Continue Selection
            
            If EditEx()\Selection\Flag = #Selected
              
              CursorPos = CursorPos_(X, Y)
              If CursorPos 
                
                If LastCursorPos <> CursorPos
                  EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
                  ReDraw_()
                EndIf
                
              EndIf
              
            EndIf  
            ;}
        EndSelect
        ;}
      Else
        EditEx()\Mouse\Status = #Mouse_Move 
      EndIf
      
      ChangeMouseCursor_(GNum, X, Y)
      
    EndIf  
  
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i GNum = EventGadget()
    Define.i Delta, ScrollPos
    Define.s ScrollBar
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Delta = GetGadgetAttribute(EditEx()\CanvasNum, #PB_Canvas_WheelDelta)
	  
  	  If FindMapElement(EditEx()\ScrollBar\Item(), "VScroll")
        
  	    If EditEx()\ScrollBar\Item()\Hide = #False

  	      EditEx()\ScrollBar\Item()\Pos - Delta
  
          If EditEx()\ScrollBar\Item()\Pos > EditEx()\ScrollBar\Item()\maxPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\maxPos : EndIf
          If EditEx()\ScrollBar\Item()\Pos < EditEx()\ScrollBar\Item()\minPos : EditEx()\ScrollBar\Item()\Pos = EditEx()\ScrollBar\Item()\minPos : EndIf

          EditEx()\Visible\RowOffset = EditEx()\ScrollBar\Item()\Pos
          
          Draw_() 
  	    EndIf
	    
	    EndIf
      
    EndIf
    
  EndProcedure
    
  Procedure _MouseLeaveHandler()
    Define.s ScrollBar
    Define.i GNum = EventGadget()

    If FindMapElement(EditEx(), Str(GNum))
      
      ForEach EditEx()\ScrollBar\Item()
        
  	    If EditEx()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(EditEx()\ScrollBar\Item())
  	    
  	    If EditEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False
  			  DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Backwards\X, EditEx()\ScrollBar\Item()\Buttons\Backwards\Y, EditEx()\ScrollBar\Item()\Buttons\Backwards\Width, EditEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
  			  EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
  			EndIf
  			
  			If EditEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False
  			  DrawScrollButton_(EditEx()\ScrollBar\Item()\Buttons\Forwards\X, EditEx()\ScrollBar\Item()\Buttons\Forwards\Y, EditEx()\ScrollBar\Item()\Buttons\Forwards\Width, EditEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
  			  EditEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
  			EndIf
  			
  	    If EditEx()\ScrollBar\Item()\Thumb\State <> #False
  	      EditEx()\ScrollBar\Item()\Thumb\State = #False
  	      DrawScrollBar_(ScrollBar)
  	    EndIf  
  	    
  	  Next
  	  
    EndIf
    
	EndProcedure
  
  ;- --- Resize Gadget ---
  
	Procedure _ResizeHandler()
	  Define.s ScrollBar
    Define.i GNum = EventGadget()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      ForEach EditEx()\ScrollBar\Item()
      
	      If EditEx()\ScrollBar\Item()\Hide : Continue : EndIf
	    
  	    ScrollBar = MapKey(EditEx()\ScrollBar\Item())
  	    
  	    CalcScrollBarThumb_(ScrollBar)
  		  DrawScrollBar_(ScrollBar)
  		  
  	  Next
      
      ReDraw_()
      
    EndIf
    
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.i  OffSetX, OffsetY

    ForEach EditEx()
      
      If IsGadget(EditEx()\CanvasNum)
        
        If EditEx()\Flags & #AutoResize
          
          If IsWindow(EditEx()\Window\Num)
            
            OffSetX = WindowWidth(EditEx()\Window\Num)  - EditEx()\Window\Width
            OffsetY = WindowHeight(EditEx()\Window\Num) - EditEx()\Window\Height
            
            If EditEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width  = #PB_Ignore : Height = #PB_Ignore
              
              If EditEx()\Size\Flags & #MoveX : X = EditEx()\Size\X + OffSetX : EndIf
              If EditEx()\Size\Flags & #MoveY : Y = EditEx()\Size\Y + OffSetY : EndIf
              If EditEx()\Size\Flags & #Width  : Width  = EditEx()\Size\Width  + OffSetX : EndIf
              If EditEx()\Size\Flags & #Height : Height = EditEx()\Size\Height + OffSetY : EndIf

              ResizeGadget(EditEx()\CanvasNum, X, Y, Width, Height)
              
            Else

              ResizeGadget(EditEx()\CanvasNum, #PB_Ignore, #PB_Ignore, EditEx()\Size\Width + OffSetX,  EditEx()\Size\Height + OffSetY)
              
            EndIf

          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure  
  
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach EditEx()
    
      If EditEx()\Window\Num = Window
        
        CompilerIf Defined(ModuleEx, #PB_Module) = #False
          If MapSize(EditEx()) = 1
            Thread\Exit = #True
            Delay(100)
            If IsThread(Thread\Num) : KillThread(Thread\Num) : EndIf
            Thread\Active = #False
          EndIf
        CompilerEndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  ;- ----- ScrollBar ----- 
 
	Procedure InitScrollBar_(Flags.i=#False)

	  EditEx()\ScrollBar\Flags = Flags
	  
	  If TimerThread\Active = #False 
      TimerThread\Exit   = #False
      TimerThread\Num    = CreateThread(@_TimerThread(), #ScrollBar_Timer)
      TimerThread\Active = #True
    EndIf
	  
		EditEx()\ScrollBar\Color\Back         = $F0F0F0
		EditEx()\ScrollBar\Color\Border       = $A0A0A0
		EditEx()\ScrollBar\Color\Button       = $F0F0F0
		EditEx()\ScrollBar\Color\Focus        = $D77800
		EditEx()\ScrollBar\Color\Front        = $646464
		EditEx()\ScrollBar\Color\Gadget       = $F0F0F0
		EditEx()\ScrollBar\Color\ScrollBar    = $C8C8C8
		EditEx()\ScrollBar\Color\DisableFront = $72727D
		EditEx()\ScrollBar\Color\DisableBack  = $CCCCCA
		
		CompilerSelect #PB_Compiler_OS ;{ Color
			CompilerCase #PB_OS_Windows
				EditEx()\ScrollBar\Color\Front     = GetSysColor_(#COLOR_GRAYTEXT)
				EditEx()\ScrollBar\Color\Back      = GetSysColor_(#COLOR_MENU)
				EditEx()\ScrollBar\Color\Border    = GetSysColor_(#COLOR_3DSHADOW)
				EditEx()\ScrollBar\Color\Gadget    = GetSysColor_(#COLOR_MENU)
				EditEx()\ScrollBar\Color\Focus     = GetSysColor_(#COLOR_MENUHILIGHT)
				EditEx()\ScrollBar\Color\ScrollBar = GetSysColor_(#COLOR_SCROLLBAR)
			CompilerCase #PB_OS_MacOS
				EditEx()\ScrollBar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				EditEx()\ScrollBar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				EditEx()\ScrollBar\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				EditEx()\ScrollBar\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				EditEx()\ScrollBar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				; EditEx()\ScrollBar\Color\ScrollBar = 
			CompilerCase #PB_OS_Linux

		CompilerEndSelect ;}
    
		BindEvent(#Event_Timer, @_AutoScroll())
		
	EndProcedure
	
  Procedure CreateScrollBar_(Label.s, CanvasNum.i, X.i, Y.i, Width.i, Height.i, Minimum.i, Maximum.i, PageLength.i, Type.i=#False)
    
    If AddMapElement(EditEx()\ScrollBar\Item(), Label)
      
      EditEx()\ScrollBar\Item()\Num = CanvasNum
      EditEx()\ScrollBar\Item()\X          = dpiX(X)
      EditEx()\ScrollBar\Item()\Y          = dpiY(Y)
      EditEx()\ScrollBar\Item()\Width      = dpiX(Width)
      EditEx()\ScrollBar\Item()\Height     = dpiY(Height)
      EditEx()\ScrollBar\Item()\Minimum    = Minimum
      EditEx()\ScrollBar\Item()\Maximum    = Maximum
      EditEx()\ScrollBar\Item()\PageLength = PageLength
      EditEx()\ScrollBar\Item()\Hide       = #True
      EditEx()\ScrollBar\Item()\Type       = Type
      
      EditEx()\ScrollBar\Item()\Cursor = #PB_Default
		
			EditEx()\ScrollBar\Item()\Buttons\Forwards\State  = #PB_Default
			EditEx()\ScrollBar\Item()\Buttons\Backwards\State = #PB_Default
			
			CalcScrollBarThumb_(Label)
			
		  DrawScrollBar_(Label)
			
    EndIf
    
  EndProcedure 
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 

  ;- ===== Spell Checking =====
  
  CompilerIf #Enable_SpellChecking
    
    Procedure   LoadDictionary(DicFile.s, AddDicFile.s="")
      Define.i FileID
      Define.s Word$, Path$, Language$
      
      Language$ = LCase(GetFilePart(DicFile, #PB_FileSystem_NoExtension))
      Select Language$
        Case "german", "deutsch"  
          SpellCheck\Button  = "Hinzufügen"
          SpellCheck\ToolTip = "Zum Benutzerwörterbuch hinzufügen."
        Case "french", "français"
          SpellCheck\Button  = "Ajouter"
          SpellCheck\ToolTip = "Ajouter au dictionnaire utilisateur."
        Case "italian", "italiano"
          SpellCheck\Button  = "Sommare"
          SpellCheck\ToolTip = "Aggiungi al dizionario utente."
        Case "spanish", "español"
          SpellCheck\Button  = "Añadir"
          SpellCheck\ToolTip = "Añadir al diccionario del usuario."
        Case "portuguese", "português"
          SpellCheck\Button  = "Adicionar"
          SpellCheck\ToolTip = "Adicionar ao dicionário do usuário."
        Case "dutch", "nederlands"
          SpellCheck\Button = "Toevoegen"
          SpellCheck\ToolTip = "Toevoegen aan gebruikerswoordenboek."
        Default
          SpellCheck\Button  = "Add Word"
          SpellCheck\ToolTip = "Add to user dictionary."
      EndSelect    

      ClearList(SpellCheck\Dictionary())
      
      SpellCheck\Path = GetPathPart(DicFile)
      
      FileID = ReadFile(#PB_Any, DicFile)
      If FileID
        While Eof(FileID) = #False
          Word$ = ReadString(FileID)
          AddElement(SpellCheck\Dictionary())
          SpellCheck\Dictionary()\Stem = StringField(Word$, 1, Chr(127))
          If CountString(Word$, Chr(127)) = 2
            SpellCheck\Dictionary()\Endings = StringField(Word$, 2, Chr(127))
            SpellCheck\Dictionary()\UCase    = Val(StringField(Word$, 3, Chr(127)))
          Else
            SpellCheck\Dictionary()\Endings = ""
            SpellCheck\Dictionary()\UCase    = Val(StringField(Word$, 3, Chr(127)))
          EndIf
        Wend
        CloseFile(FileID)
      EndIf
      
      If AddDicFile
        
        FileID = ReadFile(#PB_Any, AddDicFile)
        If FileID
          While Eof(FileID) = #False
            Word$ = ReadString(FileID)
            AddElement(SpellCheck\Dictionary())
            SpellCheck\Dictionary()\Stem = StringField(Word$, 1, Chr(127))
            If CountString(Word$, Chr(127)) = 2
              SpellCheck\Dictionary()\Endings = StringField(Word$, 2, Chr(127))
              SpellCheck\Dictionary()\UCase    = Val(StringField(Word$, 3, Chr(127)))
            Else
              SpellCheck\Dictionary()\Endings = ""
              SpellCheck\Dictionary()\UCase    = Val(StringField(Word$, 3, Chr(127)))
            EndIf
          Wend
          CloseFile(FileID)
        EndIf
      EndIf
      
      ;{ Dictionary is required
      If ListSize(SpellCheck\Dictionary()) = 0
        Debug "ERROR: No dictionary found"
        ProcedureReturn #False
      EndIf ;}
      
      ClearList(SpellCheck\UserDic())
      
      FileID = ReadFile(#PB_Any, SpellCheck\Path + "user.dic")
      If FileID
        
        While Eof(FileID) = #False
          Word$ = ReadString(FileID)
          AddElement(SpellCheck\UserDic())
          SpellCheck\UserDic()\Stem = StringField(Word$, 1, Chr(127))
          If CountString(Word$, Chr(127)) = 2
            SpellCheck\UserDic()\Endings = StringField(Word$, 2, Chr(127))
            SpellCheck\UserDic()\UCase    = Val(StringField(Word$, 3, Chr(127)))
          Else
            SpellCheck\UserDic()\Endings = ""
            SpellCheck\UserDic()\UCase    = Val(StringField(Word$, 3, Chr(127)))
          EndIf
        Wend
        
        MergeLists(SpellCheck\UserDic(), SpellCheck\Dictionary())
        
        CloseFile(FileID)
      EndIf
      
      SortStructuredList(SpellCheck\Dictionary(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))  
      
    EndProcedure
    
    Procedure   FreeDictionary()
      ClearList(SpellCheck\Dictionary())
      SpellCheck\Flags & ~#AutoSpellCheck
      SpellCheck\Flags & ~#Suggestions
    EndProcedure
    
    Procedure   EnableAutoSpellCheck(State.i=#True)

      ;{ Dictionary is required
      If State And ListSize(SpellCheck\Dictionary()) = 0
        Debug "ERROR: Dictionary is required => LoadSpellCheck\Dictionary()"
        ProcedureReturn #False
      EndIf ;}
      
      If State
        SpellCheck\Flags | #AutoSpellCheck
        SpellCheck\Flags | #Suggestions
      Else
        SpellCheck\Flags & ~#AutoSpellCheck
        SpellCheck\Flags & ~#Suggestions
      EndIf 

    EndProcedure
    
    
    Procedure   DisableSpellCheck(GNum.i, State.i=#True)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If State
          EditEx()\Flags & ~#AutoSpellCheck
        Else
          EditEx()\Flags | #AutoSpellCheck
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure   DisableSuggestions(GNum.i, State.i=#True)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If State
          EditEx()\Flags & ~#Suggestions
        Else
          EditEx()\Flags | #Suggestions
        EndIf
        
      EndIf
      
    EndProcedure
    
    
    Procedure   SpellCheck(Word.s)
      ProcedureReturn SpellCheck_(Word)
    EndProcedure
    
    Procedure.i SpellCheckText(Text.s, List Mistake.s())
      Define.i r, w, Rows, Words
      Define.s Row$, Word$
      
      ClearList(Mistake())
      
      Text = ReplaceString(Text, #CRLF$, #LF$)
      Text = ReplaceString(Text, #CR$, #LF$)
      
      Rows = CountString(Text, #LF$) + 1
      For r=1 To Rows
        
        Row$ = StringField(Text, r, #LF$)
        
        Words = CountString(Row$, " ") + 1
        For w=1 To Words
          
          Word$ = GetWord_(StringField(Row$, w, " "))
          If SpellCheck_(Word$)
            If AddElement(Mistake()) : Mistake() = Word$ : EndIf
          EndIf
          
        Next
        
      Next
      
      ProcedureReturn ListSize(Mistake())
    EndProcedure
    
    Procedure   SpellChecking(GNum.i, Flag.i=#Highlight)
      
      ;{ Dictionary is required
      If ListSize(SpellCheck\Dictionary()) = 0
        Debug "ERROR: Dictionary is required => LoadSpellCheck\Dictionary()"
        ProcedureReturn #False
      EndIf ;}
      
      If FindMapElement(EditEx(), Str(GNum))
        
        EditEx()\SyntaxHighlight = #CaseSensitiv
        
        UpdateWordList_()
        
        If Flag & #Highlight
          SpellChecking_(#True)
        Else
          SpellChecking_(#False)
        EndIf
        
        If Flag & #WrongWords
          ClearList(WrongWords())
          ForEach SpellCheck\Words()
            If SpellCheck\Words()\misspelled = #True
              If AddElement(WrongWords())
                WrongWords() = MapKey(SpellCheck\Words())
              EndIf  
              DeleteMapElement(SpellCheck\Words())
            EndIf
          Next
        EndIf

        If Flag & #Highlight : ReDraw_() : EndIf
        
      EndIf
      
    EndProcedure
    
    
    Procedure   SaveUserDictionary()
      Define.i FileID
      Define.s File$, Word$
      
      File$ = SpellCheck\Path + "user.dic"
      
      If ListSize(SpellCheck\UserDic()) = 0 : ProcedureReturn #False : EndIf
      
      FileID = CreateFile(#PB_Any, File$)
      If FileID
        
        SortStructuredList(SpellCheck\UserDic(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))
        
        ForEach SpellCheck\UserDic()
          Word$ = SpellCheck\UserDic()\Stem + Chr(127) + SpellCheck\UserDic()\Endings + Chr(127) + SpellCheck\UserDic()\UCase
          WriteStringN(FileID, Word$, #PB_UTF8)
        Next
        
        CloseFile(FileID)
      EndIf
      
    EndProcedure
    
    Procedure   AddToUserDictionary(GNum.i, Word.s)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        AddToUserDictionary_(Word)
        
      EndIf
      
    EndProcedure
    
    
    Procedure   ClearCheckedWords()
      
      ClearMap(SpellCheck\Words())
      
    EndProcedure

    Procedure   GetSuggestions(GNum.i, Word.s, List Suggestions.s())
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If CorrectionSuggestions_(Word)
          CopyList(EditEx()\Suggestions(), Suggestions())
        EndIf
        
      EndIf
      
    EndProcedure
   
  CompilerEndIf  
  
  ;- ===== Hyphenation =====
  
  CompilerIf #Enable_Hyphenation
  
    Procedure   LoadHyphenationPattern(File.s=#PAT_Deutsch) ; [ ALL gadgets ]
      Define.i FileID
      Define.s Pattern 
      
      Hypenation\Path = GetPathPart(File)
      
      ClearList(Hypenation\Item())
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        While Eof(FileID) = #False
          Pattern = Trim(ReadString(FileID, #PB_UTF8))
          AddElement(Hypenation\Item())
          Hypenation\Item()\Chars   = StringField(Pattern, 1, ":")
          Hypenation\Item()\Pattern = StringField(Pattern, 2, ":")
        Wend 
        
        CloseFile(FileID)
        
        Hypenation\Flags = #Hyphenation
        
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
      
    EndProcedure

  CompilerEndIf
  
  ;- ===== Syntax Highlighting =====
  
  CompilerIf #Enable_SyntaxHighlight
    
    Procedure SetSyntaxHighlight(GNum.i, Flag.i) ; #CaseSensitiv/#NoCase
      
      If FindMapElement(EditEx(), Str(GNum))
        
        EditEx()\SyntaxHighlight = Flag

        ReDraw_()
        
      EndIf
      
    EndProcedure
  
    Procedure AddWord(GNum.i, Word.s, Color.i)
      Define.i w, Spaces
      Define.s Word$, sWord$
      
      If FindMapElement(EditEx(), Str(GNum))
        
        Spaces = CountString(Word, " ")
        
        For w=1 To Spaces + 1
          
          sWord$ = GetWord_(StringField(Word, w, " "))
          
          If w = 1
            If Spaces
              Word$ = sWord$ + "_"
            Else  
              Word$ = sWord$
            EndIf
          ElseIf w <= Spaces
            Word$ + sWord$ + "_"
          Else
            Word$ + sWord$
          EndIf  

          If EditEx()\SyntaxHighlight = #NoCase
            EditEx()\Syntax(LCase(Word$)) = Color
          Else
            EditEx()\Syntax(Word$) = Color
          EndIf  
        Next  

        ReDraw_()
      EndIf
    
    EndProcedure
  
    Procedure DeleteWord(GNum.i, Word.s)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        DeleteMapElement(EditEx()\Syntax(), Word) 
        
        ReDraw_()
      EndIf  
   
    EndProcedure
  
    Procedure ClearWords(GNum.i)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        ClearMap(EditEx()\Syntax())
        
        ReDraw_()
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  ;- ===== Undo / Redo =====
  
  CompilerIf #Enable_UndoRedo

    Procedure SetUndoSteps(GNum.i, MaxSteps.i)
      
      If FindMapElement(EditEx(), Str(GNum))
        EditEx()\Undo\MaxSteps = MaxSteps
      EndIf
      
    EndProcedure  
    
    Procedure Undo(GNum.i)
      Define r.i, Text$, CurrentText$
      
      If FindMapElement(EditEx(), Str(GNum))
        Undo_()
        ReDraw_()
      EndIf
      
    EndProcedure
    
    Procedure Redo(GNum.i)
      Define Text$
      
      If FindMapElement(EditEx(), Str(GNum))

        Text$ = GetLastRedo_()
        If Text$

          ClearRedo_()
          
          EditEx()\Text$ = Text$
          EditEx()\Cursor\Pos = EditEx()\Undo\CursorPos
          
          PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
          
          ReDraw_()
          
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure IsUndo(GNum.i)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If ListSize(EditEx()\Undo\Item())
          ProcedureReturn #True
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure IsRedo(GNum.i)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If EditEx()\Undo\Redo\Text
          ProcedureReturn #True
        EndIf
        
        ProcedureReturn #False
      EndIf
      
    EndProcedure
    
    Procedure ClearUndo(GNum.i)  
      
      If FindMapElement(EditEx(), Str(GNum))
        ClearList(EditEx()\Undo\Item())
        ClearRedo_()
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  ;- ===== Selection / Cursor =====
  
  Procedure.i IsSelected(GNum.i)                         ; Returns whether a selection exists
    
    If FindMapElement(EditEx(), Str(GNum))
      If EditEx()\Selection\Flag = #Selected
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure   DeleteSelection(GNum.i, Remove.i=#True)    ; Delete selected text (Remove selection: #True/#False)
    Define row.i, CurrentRow, Text.s
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\Flags & #ReadOnly = #False

        If DeleteSelection_(Remove)
          
          CompilerIf #Enable_UndoRedo
            AddUndo_()
          CompilerEndIf
          
          PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
          
          ReDraw_()
        EndIf
        
        
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.s GetSelection(GNum.i, Remove.i=#True)       ; Return selected text (Remove selection: #True/#False)
    Define row.i, Text.s
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Text = GetSelection_(Remove)      
      If Remove : ReDraw_() : EndIf
      
      ProcedureReturn Text
    EndIf
  
  EndProcedure
  
  Procedure   InsertText(GNum.i, Text.s)                 ; Insert text at cursor position (or replace selection)

    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\Flags & #ReadOnly = #False  
        
        If EditEx()\Selection\Flag = #Selected
          DeleteSelection_()
        EndIf
        
        EditEx()\Text$ = InsertString(EditEx()\Text$, Text, EditEx()\Cursor\Pos + 1)
        EditEx()\Cursor\Pos + Len(Text)
        
        CompilerIf #Enable_UndoRedo
          AddUndo_()
        CompilerEndIf
        
        PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
        PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
        
        ReDraw_()
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   ResetSelection(GNum.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      RemoveSelection_()
      ReDraw_()
    EndIf
    
  EndProcedure  
  
  ;- ===== Clipboard =====
  
  Procedure  Copy(GNum.i)
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\Selection\Flag = #Selected
        
        Text$ = GetSelection_()
        If Text$
          Text$ = ReplaceString(Text$, #LF$, #NL$)
          SetClipboardText(Text$)
        EndIf
        
      EndIf
      
    EndIf

  EndProcedure
  
  Procedure  Cut(GNum.i)
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\Selection\Flag = #Selected
        
        Text$ = GetSelection_(#False)
        If Text$
          Text$ = ReplaceString(Text$, #LF$, #NL$)
          SetClipboardText(Text$)
          DeleteSelection_()
           CompilerIf #Enable_UndoRedo
            AddUndo_()
          CompilerEndIf
          PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
        EndIf

        ReDraw_()
        
      EndIf
      
    EndIf 
    
  EndProcedure
  
  Procedure  Paste(GNum.i)
    Define.s Text
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\Flags & #ReadOnly = #False
        
        Text = ReplaceString(GetClipboardText(), #CRLF$, #LF$)
        Text = ReplaceString(Text, #CR$, #LF$)
        
        If EditEx()\Selection\Flag = #Selected
          DeleteSelection_()
        EndIf
        
        EditEx()\Text$ = InsertString(EditEx()\Text$, Text, EditEx()\Cursor\Pos)
        EditEx()\Cursor\Pos + Len(Text)
        
        CompilerIf #Enable_SpellChecking

          If EditEx()\Flags & #AutoSpellCheck
            UpdateWordList_()
            SpellChecking_(#True)
          EndIf 
          
        CompilerEndIf
        
        CompilerIf #Enable_UndoRedo
          AddUndo_()
        CompilerEndIf
        
        PostEvent(#Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
        PostEvent(#PB_Event_Gadget, EditEx()\Window\Num, EditEx()\CanvasNum, #EventType_Change)
        
        ReDraw_()
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  ;- =====================

  Procedure   AddItem(GNum.i, Position.i, Text.s)        ; Add text row at 'Position' (or #FirstRow / #LastRow)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      AddItem_(Position, Text)
      
      CompilerIf #Enable_SpellChecking
        
        If EditEx()\Flags & #AutoSpellCheck
          UpdateWordList_()
          SpellChecking_(#True)
        EndIf
        
      CompilerEndIf 
      
      CompilerIf #Enable_UndoRedo
        AddUndo_()
      CompilerEndIf
      
      ReDraw_()
      
    EndIf
    
    ProcedureReturn ListSize(EditEx()\Row())
  EndProcedure
  
  Procedure   AttachPopup(GNum.i, PopUpMenu.i)           ; Attach 'PopUpMenu' to gadget 
    If FindMapElement(EditEx(), Str(GNum))
      EditEx()\PopupMenu = PopUpMenu
    EndIf
  EndProcedure   
  
  Procedure.i CountItems(GNum.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      ProcedureReturn ListSize(EditEx()\Row())
    EndIf  
    
  EndProcedure
  
  Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(EditEx(), Str(GNum))
  
      EditEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 	
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)          ; Similar to GetGadgetAttribute()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Select Attribute
        Case #CtrlChars
          ProcedureReturn EditEx()\Visible\CtrlChars
        Case #MaxTextWidth  
          ProcedureReturn EditEx()\Text\Width
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.i GetColor(GNum.i, Attribute.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Select Attribute
        Case #FrontColor
          ProcedureReturn EditEx()\Color\Front
        Case #BackColor
          ProcedureReturn EditEx()\Color\Back
        Case #SpellCheckColor
          ProcedureReturn EditEx()\Color\SpellCheck
        Case #SelectionColor
          ProcedureReturn EditEx()\Color\Highlight
        Case #SelectTextColor
          ProcedureReturn EditEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure 
 
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(EditEx(), Str(GNum))
	    ProcedureReturn EditEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(EditEx(), Str(GNum))
	    ProcedureReturn EditEx()\ID
	  EndIf
	  
	EndProcedure
 
  Procedure.s GetItemText(GNum.i, Row.i)                 ; Return text row from 'Position'
    Define.i Count
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If SelectElement(EditEx()\Row(), Row)
        
        If EditEx()\Flags & #Hyphenation Or EditEx()\Flags & #WordWrap
          Text$ = Mid(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Row()\Len) + EditEx()\Row()\WordWrap
          ProcedureReturn ReplaceString(Text$, #LF$, #NL$)
        Else  
          Text$ = Mid(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Row()\Len)
          ProcedureReturn ReplaceString(Text$, #LF$, #NL$)
        EndIf
        
      EndIf

    EndIf
    
  EndProcedure  
  
  Procedure.s GetText(GNum.i, Flags.i=#False)
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If Flags & #Hyphenation
        
        ForEach EditEx()\Row()
          Text$ + Mid(EditEx()\Text$, EditEx()\Row()\Pos, EditEx()\Row()\Len) + EditEx()\Row()\WordWrap
        Next  
        
        Text$ = RemoveString(Text$, #SoftHyphen$)
        
        ProcedureReturn ReplaceString(Text$, #LF$, #NL$)
      Else
        
        Text$ = RemoveString(EditEx()\Text$, #SoftHyphen$)
        
        ProcedureReturn ReplaceString(Text$, #LF$, #NL$)
      EndIf  
      
    EndIf
    
  EndProcedure
  
  
  Procedure   ReDraw(GNum.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      ReDraw_()
    EndIf
    
  EndProcedure  
  
  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If State
        EditEx()\Hide = #True
        HideGadget(GNum, #True)
      Else
        EditEx()\Hide = #False
        HideGadget(GNum, #False)
        Draw_()
      EndIf  
      
    EndIf  
    
  EndProcedure
  
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i) ; Similar to SetGadgetAttribute()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Select Attribute
        Case #WordWrap, #PB_Editor_WordWrap
          If Value
            EditEx()\Flags | #WordWrap
            EditEx()\Flags & ~#ScrollBar_Horizontal
          Else
            EditEx()\Flags & ~#WordWrap
          EndIf  
        Case #ReadOnly, #PB_Editor_ReadOnly
          If Value
            EditEx()\Flags | #ReadOnly
          Else
            EditEx()\Flags & ~#ReadOnly
          EndIf  
        Case #MaxTextWidth  
          EditEx()\Text\Width = Value
        Case #CtrlChars
          If Value
            EditEx()\Flags | #CtrlChars 
          Else
            EditEx()\Flags & ~#CtrlChars
          EndIf 
         Case #ScrollBar
          EditEx()\ScrollBar\Flags = Value
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      EditEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure  
  
  Procedure   SetColor(GNum.i, Attribute.i, Color.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Select Attribute
        Case #FrontColor, #PB_Gadget_FrontColor
          EditEx()\Color\Front = Color
        Case #BackColor, #PB_Gadget_BackColor
          EditEx()\Color\Back  = Color
        Case #SpellCheckColor
          EditEx()\Color\SpellCheck = Color
        Case #SelectTextColor
          EditEx()\Color\HighlightText = Color
        Case #SelectionColor
          EditEx()\Color\Highlight = Color
        Case #ScrollBar_FrontColor
          EditEx()\ScrollBar\Color\Front     = Color
        Case #ScrollBar_BackColor 
          EditEx()\ScrollBar\Color\Back      = Color
        Case #ScrollBar_BorderColor
          EditEx()\ScrollBar\Color\Border    = Color
        Case #ScrollBar_ButtonColor
          EditEx()\ScrollBar\Color\Button    = Color
        Case #ScrollBar_ThumbColor
          EditEx()\ScrollBar\Color\ScrollBar = Color  
      EndSelect
    EndIf
    
    ReDraw_()
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(EditEx(), Str(GNum))
	    EditEx()\Quad = Value
	  EndIf  
	  
	EndProcedure

  Procedure   SetFlags(GNum.i, Flags.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If Flags & #WordWrap
        EditEx()\Flags | #WordWrap
        EditEx()\Flags & ~#ScrollBar_Horizontal
      EndIf  
      
      If Flags & #Hyphenation
        EditEx()\Flags | #Hyphenation
        EditEx()\Flags & ~#ScrollBar_Horizontal
      EndIf
      
      If Flags & #ReadOnly
        EditEx()\Flags | #ReadOnly
      ElseIf Flags & #ReadWrite
        EditEx()\Flags & ~#ReadOnly
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If FontID
        EditEx()\FontID   = FontID
      Else
        EditEx()\FontID   = GetGadgetFont(GNum)
      EndIf
      
      ReDraw_()
      
    EndIf
    
  EndProcedure  
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(EditEx(), Str(GNum))
	    EditEx()\ID = String
	  EndIf
	  
	EndProcedure  
  
  Procedure   SetItemText(GNum.i, Row.i, Text.s)         ; Replace text row at 'Position'
    Define.i Count, Pos1, Pos2
    
    If FindMapElement(EditEx(), Str(GNum))

      Count = ListSize(EditEx()\Row())
      If Count And Row < Count

        If SelectElement(EditEx()\Row(), Row)
          
          Pos1 = EditEx()\Row()\Pos - 1
          If Pos1 < 1 : Pos1 = 1 : EndIf
          
          Pos2 = EditEx()\Row()\Pos + EditEx()\Row()\Len + 1
          If Pos2 > EditEx()\Text\Len + 1 : Pos2 = EditEx()\Text\Len + 1 : EndIf
          
          EditEx()\Text$ = Left(EditEx()\Text$, Pos1) + Text + Mid(EditEx()\Text$, Pos2)
          
          CompilerIf #Enable_UndoRedo
            AddUndo_()
          CompilerEndIf
      
        EndIf
        
      EndIf
      
      ReDraw_()
      
      CompilerIf #Enable_SpellChecking
        
        If EditEx()\Flags & #AutoSpellCheck
          UpdateWordList_()
          SpellChecking_(#True)
        EndIf
      
      CompilerEndIf
      
      CompilerIf #Enable_UndoRedo
       AddUndo_()
      CompilerEndIf
      
    EndIf  

  EndProcedure
  
  Procedure   SetText(GNum.i, Text.s)
    Define.i r, Rows
    
    If FindMapElement(EditEx(), Str(GNum))
      
      EditEx()\Text$ = Text
      
      CompilerIf #Enable_SpellChecking
        
        If EditEx()\Flags & #AutoSpellCheck
          UpdateWordList_()
          SpellChecking_(#True)
        EndIf
        
      CompilerEndIf
      
      CompilerIf #Enable_UndoRedo
        AddUndo_()
      CompilerEndIf
      
      EditEx()\Selection\Flag = #NoSelection
      EditEx()\Selection\Pos1 = #PB_Default
      EditEx()\Selection\Pos2 = #PB_Default
      EditEx()\Mouse\Status   = #False

      ReDraw_()
      
    EndIf 
    
  EndProcedure
  
  Procedure   SetTextWidth(GNum.i, Value.f, unit.s="px")
    ; px = mm * 96 / 25,4mm
    Define.i Pixel
    
    If FindMapElement(EditEx(), Str(GNum))
    
      Select Unit
        Case "pt"
          EditEx()\Text\Width = Round(Value * 96 / 72, #PB_Round_Nearest)
        Case "mm"
          EditEx()\Text\Width = Round(Value * 96 / 25.4, #PB_Round_Nearest)
        Case "cm"
          EditEx()\Text\Width = Round(Value * 96 / 2.54, #PB_Round_Nearest)
        Case "in"
          EditEx()\Text\Width = Round(Value * 96, #PB_Round_Nearest)
        Default
          EditEx()\Text\Width = Value
      EndSelect

    EndIf
    
  EndProcedure
  
  
  Procedure.s WrapText(Text.s, Width.i, Font.i, Flags.i=#WordWrap) ; Flags: #WordWrap/#Hyphenation | #mm/#cm/#inch
    Define.i r, w, h, Pos, PosX, ImgNum, maxTextWidth, Rows, Words, Hyphen, SoftHyphen
    Define.s Row$, Word$, Part$, WordOnly$, WordMask$, hWord$, wrapText$
    
    If Flags & #mm
      maxTextWidth= Round(Width * 96 / 25.4, #PB_Round_Nearest)
    ElseIf Flags & #cm
      maxTextWidth = Round(Width * 96 / 2.54, #PB_Round_Nearest)
    ElseIf Flags & #inch
      maxTextWidth = Round(Width * 96, #PB_Round_Nearest)
    Else
      maxTextWidth = Width
    EndIf
    
    ImgNum = CreateImage(#PB_Any, 16, 16)
    If ImgNum
    
      If StartDrawing(ImageOutput(ImgNum)) 
        
        If IsFont(Font) : DrawingFont(FontID(Font)) : EndIf
    
        Pos = 1
    
        Rows = CountString(Text, #LF$) + 1 
        For r=1 To Rows
    
          PosX = 0
          
          Row$ = StringField(Text, r, #LF$)
          If r <> Rows : Row$ + #LF$ : EndIf
    
          Words = CountString(Row$, " ") + 1
          For w=1 To Words
            
            Word$ = StringField(Row$, w, " ")
            If w <> Words : Word$ + " " : EndIf
            
            Part$ = ""
            
            If PosX + TextWidth(RTrim(Word$)) > maxTextWidth
    
              CompilerIf #Enable_Hyphenation
             
                If Flags & #Hyphenation ;{ Hyphenation
                
                  WordOnly$ = GetWord_(Word$)
                
                  If WordOnly$ <> Word$
                    WordMask$ = ReplaceString(Word$, WordOnly$, "$")
                  Else
                    WordMask$ = ""
                  EndIf
                  
                  SoftHyphen = CountString(WordOnly$, #SoftHyphen$)
                  If SoftHyphen
                    Hyphen = SoftHyphen
                    hWord$ = WordOnly$
                  Else  
                    hWord$ = HyphenateWord(WordOnly$)
                    Hyphen = CountString(hWord$, #SoftHyphen$)
                  EndIf
                  
                  If Hyphen
    
                    If WordMask$ : hWord$ = ReplaceString(WordMask$, "$", hWord$) : EndIf
                  
                    For h=1 To Hyphen + 1
                      If PosX + TextWidth(RTrim(Part$ + StringField(hWord$, h, #SoftHyphen$))) > maxTextWidth
                        Break
                      Else
                        Part$ + StringField(hWord$, h, #SoftHyphen$)
                      EndIf  
                    Next
                    
                    If Part$
                      
                      wrapText$ + Part$ + "-"
    
                      Part$ = Mid(RemoveString(hWord$, #SoftHyphen$), Len(Part$) + 1)
    
                    EndIf
                    
                  EndIf
                  ;}
                EndIf
              
              CompilerEndIf
              
              wrapText$ + #LF$
              
              PosX = 0
              
            EndIf
    
            If Part$
              wrapText$ + Part$
              PosX + TextWidth(RTrim(Part$, #LF$))
            Else
              wrapText$ + Word$
              PosX + TextWidth(RTrim(Word$, #LF$))
            EndIf
    
          Next
    
        Next
    
        StopDrawing()
      EndIf
      
    EndIf
    
    ProcedureReturn wrapText$
  EndProcedure
  
  ;- ===== Gadget =====
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum, WNum, GadgetList
    
    CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If Flags & #WordWrap Or Flags & #Hyphenation
      Flags | #ScrollBar_Vertical
    ElseIf Flags & #ScrollBar_Horizontal = #False And  Flags & #ScrollBar_Vertical = #False
      Flags | #ScrollBar_Horizontal
      Flags | #ScrollBar_Vertical
    EndIf
    
    If Flags & #PB_Editor_WordWrap
      Flags | #WordWrap
      Flags & ~#PB_Editor_WordWrap
    EndIf
    
    If Flags & #UseExistingCanvas ;{ Use an existing CanvasGadget
      If IsGadget(GNum)
        Result = #True
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard|#PB_Canvas_Container|#PB_Canvas_ClipMouse)
    EndIf

    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      If AddMapElement(EditEx(), Str(GNum))
     
        EditEx()\CanvasNum = GNum
        
        EditEx()\Size\X = X
        EditEx()\Size\Y = Y
        EditEx()\Size\Width     = Width
        EditEx()\Size\Height    = Height
        EditEx()\Size\PaddingX  = 4
        EditEx()\Size\PaddingY  = 2
        EditEx()\Visible\Width  = Width  - 8
        EditEx()\Visible\Height = Height - 4
        
        EditEx()\Selection\Flag = #NoSelection
        EditEx()\Selection\Pos1 = #PB_Default
        EditEx()\Selection\Pos2 = #PB_Default
        EditEx()\Mouse\Status   = #False
        
        If WindowNum = #PB_Default
          EditEx()\Window\Num = GetGadgetWindow()
        Else
          EditEx()\Window\Num = WindowNum
        EndIf

        CompilerIf Defined(ModuleEx, #PB_Module)
          
          If ModuleEx::AddWindow(EditEx()\Window\Num, ModuleEx::#Tabulator|ModuleEx::#CursorEvent)
            ModuleEx::AddGadget(GNum, EditEx()\Window\Num, ModuleEx::#UseTabulator)
          EndIf
          
        CompilerElse  
          
          If Thread\Active = #False
            
            Thread\Exit   = #False
            Thread\Num    = CreateThread(@_CursorThread(), #CursorFrequency)
            Thread\Active = #True

          EndIf
          
        CompilerEndIf
        
        EditEx()\Cursor\Pause = #True
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            EditEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              EditEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            EditEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        EditEx()\Flags = Flags
        
        CompilerIf #Enable_SpellChecking
          If SpellCheck\Flags & #AutoSpellCheck : EditEx()\Flags | #AutoSpellCheck : EndIf
          If SpellCheck\Flags & #Suggestions    : EditEx()\Flags | #Suggestions    : EndIf
        CompilerEndIf
        
        CompilerIf #Enable_Hyphenation
          If Hypenation\Flags & #Hyphenation 
            EditEx()\Flags | #Hyphenation
            EditEx()\Flags & ~#ScrollBar_Horizontal
          EndIf        
        CompilerEndIf
        
        EditEx()\SyntaxHighlight = #CaseSensitiv
        
        ;{ Scrollbars
        InitScrollBar_()

        CreateScrollBar_("VScroll", GNum, Width - #Scroll_Width - 1, 1, #Scroll_Width, Height - #Scroll_Width - 2, 0, 0, 0, #ScrollBar_Vertical)
        CreateScrollBar_("HScroll", GNum, 1, Height - #Scroll_Width - 1, Width - #Scroll_Width - 2,  #Scroll_Width, 0, 0, 0)
        
        EditEx()\ScrollBar\Item("VScroll")\Minimum = 0
        EditEx()\ScrollBar\Item("HScroll")\Minimum = 0
        ;}
        
      Else
        ProcedureReturn #False
      EndIf

      ;{ ----- Set colors -------------------------
     
      EditEx()\Color\Front         = $000000
      EditEx()\Color\Back          = $FFFFFF
      EditEx()\Color\ReadOnly      = $F5F5F5
      EditEx()\Color\Gadget        = $EDEDED
      EditEx()\Color\Cursor        = $000000
      EditEx()\Color\HighlightText = $FFFFFF
      EditEx()\Color\Highlight     = $D77800
      EditEx()\Color\ScrollBar     = $C8C8C8
      EditEx()\Color\Border        = $E3E3E3
      EditEx()\Color\DisableFront = $72727D
      EditEx()\Color\DisableBack  = $CCCCCA
      
      CompilerSelect  #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          EditEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
          EditEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
          EditEx()\Color\ReadOnly      = GetSysColor_(#COLOR_3DLIGHT)
          EditEx()\Color\Gadget        = GetSysColor_(#COLOR_MENU)
          EditEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
          EditEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
          EditEx()\Color\Cursor        = GetSysColor_(#COLOR_WINDOWTEXT)
          EditEx()\Color\ScrollBar     = GetSysColor_(#COLOR_MENU)
          EditEx()\Color\Border        = GetSysColor_(#COLOR_ACTIVEBORDER)
        CompilerCase #PB_OS_MacOS  
          EditEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
          EditEx()\Color\Back          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 97)
          EditEx()\Color\ReadOnly      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
          EditEx()\Color\Gadget        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
          EditEx()\Color\HighlightText = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
          EditEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextBackgroundColor"))
          EditEx()\Color\Cursor        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
          EditEx()\Color\ScrollBar     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
          EditEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
        CompilerCase #PB_OS_Linux
      
      CompilerEndSelect
      
      If EditEx()\Flags & #ReadOnly
        EditEx()\Color\Back = EditEx()\Color\ReadOnly
      EndIf
      
      EditEx()\Color\SpellCheck = $0000E6
      ;}

      EditEx()\Visible\RowOffset = 0
      EditEx()\Visible\PosOffset = 0
      
      BindGadgetEvent(GNum, @_RightClickHandler(),       #PB_EventType_RightClick)
      BindGadgetEvent(GNum, @_LeftDoubleClickHandler(),  #PB_EventType_LeftDoubleClick)
      BindGadgetEvent(GNum, @_LeftButtonDownHandler(),   #PB_EventType_LeftButtonDown)
      BindGadgetEvent(GNum, @_LeftButtonUpHandler(),     #PB_EventType_LeftButtonUp)
      BindGadgetEvent(GNum, @_MouseMoveHandler(),        #PB_EventType_MouseMove)
      BindGadgetEvent(GNum, @_MouseWheelHandler(),       #PB_EventType_MouseWheel)
      BindGadgetEvent(GNum, @_MouseLeaveHandler(),       #PB_EventType_MouseLeave)
      BindGadgetEvent(GNum, @_KeyDownHandler(),          #PB_EventType_KeyDown)
      BindGadgetEvent(GNum, @_InputHandler(),            #PB_EventType_Input)
      BindGadgetEvent(GNum, @_LostFocusHandler(),        #PB_EventType_LostFocus)
      BindGadgetEvent(GNum, @_FocusHandler(),            #PB_EventType_Focus)
      BindGadgetEvent(GNum, @_ResizeHandler(),           #PB_EventType_Resize)
      
      BindEvent(#Event_Cursor, @_CursorDrawing())
      
      CompilerIf Defined(ModuleEx, #PB_Module)
        BindEvent(#Event_Theme, @_ThemeHandler())
      CompilerEndIf
      
      If IsWindow(EditEx()\Window\Num)
        
        EditEx()\Window\Width  = WindowWidth(EditEx()\Window\Num)
        EditEx()\Window\Height = WindowHeight(EditEx()\Window\Num)
        
        If Flags & #AutoResize
          BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), EditEx()\Window\Num)
        EndIf
        
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), EditEx()\Window\Num)
      EndIf
      
      CloseGadgetList()
      
      CompilerIf #Enable_SpellChecking ; ListView
       
        If IsWindow(WindowNum)
          WNum = OpenWindow(#PB_Any, X, Y, 100, 80, "Suggestions", #PB_Window_BorderLess|#PB_Window_Invisible|#PB_Window_NoGadgets, WindowID(WindowNum))
        Else
          WNum = OpenWindow(#PB_Any, X, Y, 100, 80, "Suggestions", #PB_Window_BorderLess|#PB_Window_Invisible|#PB_Window_NoGadgets)
        EndIf
        
        If WNum

	        StickyWindow(WNum, #True) 
	        EditEx()\WinNum = WNum
	        
	        GadgetList = UseGadgetList(WindowID(WNum))
	        
	        EditEx()\ListNum   = ListViewGadget(#PB_Any, 0, 0, 100, 60)
          If IsGadget(EditEx()\ListNum)
            SetGadgetData(EditEx()\ListNum, GNum)
            BindGadgetEvent(EditEx()\ListNum, @_ListViewHandler(), #PB_EventType_LeftDoubleClick)
          EndIf
          
          If SpellCheck\Button
            EditEx()\ButtonNum = ButtonGadget(#PB_Any, 0, 60, 100, 20, SpellCheck\Button)
            If EditEx()\ButtonNum : GadgetToolTip(EditEx()\ButtonNum, SpellCheck\ToolTip) : EndIf
          Else
            EditEx()\ButtonNum = ButtonGadget(#PB_Any, 0, 60, 100, 20, "Add Word")
            If EditEx()\ButtonNum : GadgetToolTip(EditEx()\ButtonNum, "Add to user dictionary.") : EndIf
          EndIf

          If IsGadget(EditEx()\ButtonNum)
            SetGadgetData(EditEx()\ButtonNum, GNum)
            BindGadgetEvent(EditEx()\ButtonNum, @_ButtonHandler())
          EndIf
          
          UseGadgetList(GadgetList)
          
          HideWindow(EditEx()\WinNum, #True)
        EndIf
        
      CompilerEndIf
      
    EndIf
    
    
    CalcRows_()
    Draw_()
    
    ProcedureReturn GNum
  EndProcedure
  
  Procedure   Free(GNum.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      If IsWindow(EditEx()\WinNum) : CloseWindow(EditEx()\WinNum) : EndIf
      DeleteMapElement(EditEx())
    EndIf
    
  EndProcedure
  
  Procedure   FreeGadgets(WindowNum.i)
    
    ForEach EditEx()
    
      If EditEx()\Window\Num = WindowNum
        If IsWindow(EditEx()\WinNum) : CloseWindow(EditEx()\WinNum) : EndIf
        DeleteMapElement(EditEx())
      EndIf 
      
    Next
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile

  Define.i Language = EditEx::#Deutsch  ; #Deutsch / #English / #French
  Define.s Text
  Define.i QuitWindow.i
  
  Enumeration 
    #Window
    #Editor
    #EditEx
    #PopupMenu
    #MenuItem_1
    #MenuItem_2
    #MenuItem_3
    #MenuItem_4
    #MenuItem_5
  EndEnumeration
  
  Select Language
    Case EditEx::#Deutsch
      Text = "Die Schule ist ein schönes Ding." + #LF$ + "Man braucht sie, das ist wahr." + #LF$ + "Auf einem umgestürzten Baum saß eine Affenschar."
      Text + #LF$ + "Man hatte sie dorthin geschickt, zu bilden den Verstand." + #LF$ + "Der Lehrer war drei Tonnen schwer, ein gescheiter Elefant."
      Text + #LF$ + "Der Lehrer nahm mit seinem Rüssel die Schüler bei den Ohren." + #LF$ + "Sie lernten nichts, sie lärmten nur, alle Mühe war verloren."
    Case EditEx::#English
      Text = "School is a beautiful thing." + #LF$ + "You need it, that's true." + #LF$ + "There was a group of monkeys sitting on a fallen tree."
      Text + #LF$ + "They had been sent there to make up the mind." + #LF$ + "The teacher was three tons heavy, a clever elephant."
      Text + #LF$ + "The teacher took the students by the ears with his trunk." + #LF$ + "They didn't learn anything, they just made noise, all effort was lost."
    Case EditEx::#French
      Text = "L'école est une belle chose." + #LF$ + "Tu en as besoin, c'est vrai." + #LF$ + "Sur un arbre tombé, un troupeau de singes était assis."
      Text + #LF$ + "Ils avaient été envoyés là-bas pour se décider."  + #LF$ + "Le professeur pesait trois tonnes, un éléphant intelligent."
      Text + #LF$ + "Le professeur a pris les élèves par les oreilles avec son coffre." + #LF$ + "Ils n'ont rien appris, ils ont juste fait du bruit, tous les efforts ont été perdus."
  EndSelect

  #Font = 1
  
  LoadFont(#Font, "Arial", 11)
  
  CompilerIf EditEx::#Enable_Hyphenation
    
    Select Language
      Case EditEx::#Deutsch
        EditEx::LoadHyphenationPattern(EditEx::#PAT_Deutsch) ; or: "german.pat"
      Case EditEx::#English
        EditEx::LoadHyphenationPattern(EditEx::#PAT_English) ; or: "english.pat"
      Case EditEx::#French
        EditEx::LoadHyphenationPattern(EditEx::#PAT_French)  ; or: "french.pat"
    EndSelect
    
  CompilerEndIf
  
  CompilerIf EditEx::#Enable_SpellChecking
    
    Select Language
      Case EditEx::#Deutsch
        EditEx::LoadDictionary(EditEx::#DIC_Deutsch) ; or: "german.dic"
      Case EditEx::#English
        EditEx::LoadDictionary(EditEx::#DIC_English) ; or: "english.dic"
      Case EditEx::#French
        EditEx::LoadDictionary(EditEx::#DIC_French)  ; or: "french.dic"
    EndSelect
    
    EditEx::EnableAutoSpellCheck()
    
  CompilerEndIf
  
  If OpenWindow(#Window, 0, 0, 322, 287, "EditorGadget", #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
    
    If CreatePopupMenu(#PopupMenu) ;{ Creation of the pop-up menu begins.
      MenuItem(#MenuItem_1, "Copy")
      MenuItem(#MenuItem_2, "Paste")
      MenuItem(#MenuItem_3, "Cut")
      CompilerIf EditEx::#Enable_UndoRedo
        MenuBar()
        MenuItem(#MenuItem_4, "Undo")
        MenuItem(#MenuItem_5, "Redo")
      CompilerEndIf
    EndIf ;}
    
    EditorGadget(#Editor, 8, 8, 306, 133, #PB_Editor_WordWrap)
    SetGadgetText(#Editor, Text)
    SetGadgetFont(#Editor, FontID(#Font))
    
    EditEx::Gadget(#EditEx, 8, 146, 306, 133, EditEx::#AutoResize|EditEx::#WordWrap, #Window) 
    EditEx::SetFont(#EditEx, FontID(#Font))

    ; Test WordWrap and Hyphenation
    CompilerIf EditEx::#Enable_Hyphenation = #False
      EditEx::SetFlags(#EditEx, EditEx::#WordWrap)    ; Test WordWrap
    CompilerEndIf

    EditEx::AttachPopup(#EditEx, #PopupMenu)
    
    ;EditEx::SetAttribute(#EditEx, EditEx::#CtrlChars, #True)
    
    ; --- Add Text ---
    EditEx::SetText(#EditEx, Text)
    ; ----------------
    
    CompilerIf EditEx::#Enable_SpellChecking
      ;EditEx::AddToUserDictionary(#EditEx, "Affenschar")
    CompilerEndIf
    
    CompilerIf EditEx::#Enable_SyntaxHighlight
      
      EditEx::AddWord(#EditEx, "Schule", #Blue)
      EditEx::AddWord(#EditEx, "ein",    #Yellow)
      EditEx::AddWord(#EditEx, "bilden", #Green)
      EditEx::ReDraw(#EditEx)
      
      ; EditEx::DeleteWord(#EditEx, "ein")
      
    CompilerEndIf
    
    ;EditEx::SetTextWidth(#EditEx, 283)
    
    ;Debug EditEx::WrapText(Text, 283, #Font, EditEx::#Hyphenation)
    ;Debug EditEx::GetText(#EditEx, EditEx::#Hyphenation)
    
    ;ModuleEx::SetTheme(ModuleEx::#Theme_Green)
    
    ;EditEx::SetAttribute(#EditEx, EditEx::#Corner, 4)
    ;EditEx::Disable(#EditEx)
    
    QuitWindow = #False
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow ;{ Close Window
          QuitWindow = #True
          ;}
        Case #PB_Event_Menu        ;{ Popup-Menue
          Select EventMenu()
            Case #MenuItem_1       ;{ Copy
              EditEx::Copy(#EditEx)
              ;}
            Case #MenuItem_2       ;{ Paste
              EditEx::Paste(#EditEx)
              ;}
            Case #MenuItem_3       ;{ Cut
              EditEx::Cut(#EditEx)
              ;}
            CompilerIf EditEx::#Enable_UndoRedo  
              Case #MenuItem_4     ;{ Undo
                EditEx::Undo(#EditEx)
                ;}
              Case #MenuItem_5     ;{ Redo
                EditEx::Redo(#EditEx)
                ;}
            CompilerEndIf
          EndSelect ;}
      EndSelect
    Until QuitWindow
    
    CompilerIf EditEx::#Enable_SpellChecking
      ;EditEx::SaveUserDictionary()
    CompilerEndIf
    
    CloseWindow(#Window)  
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 3376
; FirstLine = 396
; Folding = xBCMAkQAgAAICDAGwAEA+ADIA1ECjMGIAQIEAYABQxB+QhCB2IIQIAICCAAIgXXUW-+
; Markers = 1360,2226,3279,5308
; EnableXP
; DPIAware