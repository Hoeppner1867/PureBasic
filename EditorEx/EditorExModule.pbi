;/ ============================
;/ =     EditExModule.pbi     =
;/ ============================
;/
;/ [ PB V5.7x / All OS ]
;/
;/ Module by Thorsten1867 (11/2018)
;/
;/ Algorithmus für Silbentrennung von Frankling Mark Liang (1983)
;/ Pattern based on (http://tug.org/tex-hyphen/)
;/

; Last Update:  01.07.2019
;
; Bugfix: Cursor

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

; ----- Description ------------------------------------------------------------------------------
; - WordWrap & Hyphenation          | Automatischer Zeilenumbruch & Silbentrennung (Ctrl-Minus)
; - Soft-Hyphen (Ctrl-Minus)        | 'Weiches' Trennzeichen bzw. bedingter Trennstrich
; - Automatic hiding of scrollbars  | Automatisches Ausblenden der Scrollbars
; - Undo/Redo - function            | Undo/Redo - Funktion
; - Simple syntax highlighting      | Einfache Syntax-Hervorhebung (z.B. für Rechtschreibkontrolle)
; - Automatic spell checking        | automatische Rechtschreibkorrektur
; -------------------------------------------------------------------------------------------------

;{ ----- History -----
; [23/11/18] Spellchecking & Bugfixes
; [24/11/18] WordWrap and Hyphenation revised & Bugfixes
; [02/12/18] Continuous text for hyphenation and wordwrap & Resize Handler & many Bugfixes
; [03/12/18] Syntax highlighting revised & Bugfixes
; [05/12/18] Undo/Redo feature & Copy / Cut / Paste & Bugfixes
; [06/12/18] Bugfixes (e.g. Undo) & IsUndo() / IsRedo()
; [09/12/18] Scroll and drawing routines completely revised & flashing cursor & mouse wheel & Shortcuts added & Bugfixes
; [11/12/18] Fixed fundamental problem in selection & Bugfixes
; [12/12/18] Automatic spell checking & Bugfixes
; [01/04/19] DPI
;} -------------------

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
  ; EditEx::DeleteSelection()        - Delete selected text (Remove selection: #True/#False)
  ; EditEx::DeleteWord()             - Delete word from syntax highlighting
  ; EditEx::EnableAutoSpellCheck()   - Activate automatic spelling correction
  ; EditEx::EnableSyntaxHighlight()  - Enable syntax highlighting (#False/#CaseSensitiv/#NoCase)
  ; EditEx::EnableUndoRedo()         - Enable 'Undo/Redo' function (#True/#False)
  ; EditEx::FreeDictionary()         - Removes the loaded dictionary from memory
  ; EditEx::GetAttribute()           - Returns value of attribute (#ReadOnly/#WordWrap/#Hyphenation/#AutoHide/#Border/#CtrlChars)
  ; EditEx::GetColor()               - Returns color of attribute (#FrontColor/#BackColor/#SyntaxColor/#SelectionColor)
  ; EditEx::GetItemText()            - Returns text row at 'Position'
  ; EditEx::GetSelection()           - Returns selected text (Remove selection: #True/#False)
  ; EditEx::GetText()                - Returns all text rows seperated by 'Seperator'
  ; EditEx::InsertText()             - Insert text at cursor position (or replace selection)
  ; EditEx::IsRedo()                 - Checks if an redo is possible
  ; EditEx::IsSelected()             - Returns whether a selection exists
  ; EditEx::IsUndo()                 - Checks if an undo is possible
  ; EditEx::LoadDictionary()         - Load the dictionary for spell checking
  ; EditEx::LoadHyphenationPattern() - Load hyphenation pattern for selected language (#Deutsch/#English/#French)
  ; EditEx::Redo()                   - Perform Redo
  ; EditEx::ReDraw_()                 - Redraw the gadget
  ; EditEx::RemoveGadget()           - Releases the used memory and deletes the cursor thread
  ; EditEx::Paste()                  - Inserting text from the clipboard
  ; EditEx::SaveUserDictionary()     - Save user dictionary
  ; EditEx::SetAttribute()           - Enable/Disable attribute (#ReadOnly/#WordWrap/#Hyphenation/#AutoHide/#Border/#CtrlChars)
  ; EditEx::SetColor()               - Set or change color of attribute (#FrontColor/#BackColor/#SyntaxColor/#SelectionColor)
  ; EditEx::SetFont()                - Set or change font FontID(#Font)
  ; EditEx::SetItemText()            - Replace text row at 'Position'
  ; EditEx::SetText()                - Set or replace all text rows
  ; EditEx::SpellCheck()             - Checks the spelling of the word (returns: #True/#False)
  ; EditEx::SpellChecking()          - Check the spelling in the editor gadget (#Highlight/#WrongWords)
  ; EditEx::Undo()                   - Perform Undo
  ; -----------------------
  ; EditEx::Gadget()                 - Creates an editor gadget
  ; -----------------------
  
;} ===========================

DeclareModule EditEx
  
  ;- ============================================================================
  ;-   DeclareModule - Constants
  ;- ============================================================================
  
  #Enable_Hyphenation     = #True  ; Requires file with hyphenation patterns => LoadHyphenationPattern()
  #Enable_SpellChecking   = #True  ; Requires file with dictionary           => LoadDictionary()
  #Enable_SyntaxHighlight = #True  ; Needed for spell checking!
  #Enable_UndoRedo        = #True 
  
  ;{ _____ Constants _____
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #NL$ = #CRLF$
    CompilerCase #PB_OS_MacOS
      #NL$ = #LF$
    CompilerCase #PB_OS_Linux
      #NL$ = #LF$
  CompilerEndSelect
  
  Enumeration Language 1
    #Deutsch
    #English
    #French
  EndEnumeration
  
  EnumerationBinary GadgetFlags
    #ReadOnly ; must be 1 (!)
    #WordWrap
    #Hyphenation
    #MaxTextWidth
    #AutoHide
    #Borderless
    #CtrlChars
    #SyntaxHighlight
    #ScrollBars
    #ScrollBar_Vertical
    #ScrollBar_Horizontal
  EndEnumeration
  
  Enumeration Color 1
    #FrontColor
    #BackColor
    #SyntaxColor
    #SelectTextColor
    #SelectionColor
  EndEnumeration
  
  EnumerationBinary SpellCheck
    #Highlight
    #WrongWords
  EndEnumeration 
  
  EnumerationBinary
    #CaseSensitiv ; must be 1
    #NoCase       ; must be 2
    #Punctation
    #Brackets
    #QuotationMarks
    #WordOnly
    #Parse
  EndEnumeration

  ; --- UTF-8 ---
  #Space$      = Chr(184)
  #SoftHyphen$ = Chr(173)
  #LineBreak$  = #LF$
  #Paragraph$  = Chr(182)
  #Hyphen$     = Chr(8722)
  #NbSp$       = Chr(160)
  #BlockChar$  = "·/·"
  
  ; --- AddItem ---
  #FirstRow = 0
  #LastRow  = -1
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Cursor = ModuleEx::#Event_Cursor
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
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
    
  CompilerEndIf
  ;}
  
  ;- ============================================================================
  ;-   DeclareModule
  ;- ============================================================================
  
  CompilerIf #Enable_SyntaxHighlight
    Declare   AddWord(GNum.i, Word.s, Color.i=#False)                   ; Add word to syntax highlighting
    Declare   ClearWords(GNum.i)                                        ; Delete the list with the words for syntax highlighting
    Declare   DeleteWord(GNum.i, Word.s)                                ; Delete word from syntax highlighting
    Declare   EnableSyntaxHighlight(GNum.i, Flag.i=#True)               ; Enable syntax highlighting ((#False/#CaseSensitiv/#NoCase)
  CompilerEndIf
  
  CompilerIf #Enable_Hyphenation
    Declare LoadHyphenationPattern(File.s=#PAT_Deutsch)                     ; Load hyphenation pattern for selected language (ALL gadgets)
  CompilerEndIf
  
  CompilerIf #Enable_SpellChecking
    Declare LoadDictionary(DicFile.s, AddDicFile.s="")                      ; Load the dictionary for spell checking (ALL gadgets)
    Declare EnableAutoSpellCheck(GNum.i, Flag.i=#True)                  ; Activate automatic spelling correction
    Declare SpellCheck(Word.s)                                              ; Checks the spelling of the word (returns: #True/#False)
    Declare SpellChecking(GNum.i, Flag.i=#Highlight)                    ; Check the spelling in the editor gadget
    Declare AddToUserDictionary(Word.s)                                     ; Add a new word to user dictionary
    Declare SaveUserDictionary()                                            ; Save user dictionary
    Declare FreeDictionary()                                                ; Removes the loaded dictionary from memory
    Global NewList WrongWords.s()                                           ; <= SpellChecking(GNum, #WrongWords)
  CompilerEndIf
  
  CompilerIf #Enable_UndoRedo
    
    Declare ClearUndo(GNum.i)
    Declare EnableUndoRedo(GNum.i, Flag.i=#True, MaxSteps.i=#False)
    Declare Undo(GNum.i)
    Declare Redo(GNum.i)
    Declare IsUndo(GNum.i)
    Declare IsRedo(GNum.i)
    
  CompilerEndIf
  
  Declare   AddItem(GNum.i, Position.i, Text.s)
  Declare   AttachPopup(GNum.i, PopUpMenu.i)
  Declare   Copy(GNum.i)
  Declare   Cut(GNum.i)
  Declare   DeleteSelection(GNum.i, Remove.i=#True)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.i GetColor(GNum.i, Attribute.i)
  Declare.s GetItemText(GNum.i, Position.i)
  Declare.s GetSelection(GNum.i, Remove.i=#True)
  Declare.s GetText(GNum.i, Seperator.s=#NL$)
  Declare   InsertText(GNum.i, Text.s)
  Declare.i IsSelected(GNum.i) 
  Declare   Paste(GNum.i)
  Declare.i Pixel(Value.i, Unit.s="mm")
  Declare   ReDraw_(GNum.i)
  Declare   RemoveGadget(GNum.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, Attribute.i, Color.i)
  Declare   SetFont(GNum.i, FontID.i)
  Declare   SetItemText(GNum.i, Position.i, Text.s)
  Declare   SetText(GNum.i, Text.s, Seperator.s=#NL$)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  
EndDeclareModule

Module EditEx
  
  EnableExplicit
  
  UseCRC32Fingerprint()
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================  
  
  ;-_____ OS specific definitions _____
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #Scroll_Width     = 17
    CompilerCase #PB_OS_MacOS
      #Scroll_Width     = 18
    CompilerCase #PB_OS_Linux
      #Scroll_Width     = 18
  CompilerEndSelect
  
  ;{ _____ Constants _____
  #CursorFrequency = 600
  #File = 0
  
  Enumeration Cursor 1
    #Cursor_Left
    #Cursor_Right
    #Cursor_Up
    #Cursor_Down
    #Cursor_PageUp
    #Cursor_PageDown
    #Cursor_Home
    #Cursor_End
    #Cursor_Back
    #Cursor_CtrlHome
    #Cursor_CtrlEnd
    #Cursor_CtrlLeft
    #Cursor_CtrlRight
    #Cursor_CtrlUp
    #Cursor_CtrlDown
    #Cursor_Return
    #Left
    #Right
  EndEnumeration
  
  EnumerationBinary 
    #Move_Up
    #Move_Down
    #Move_Left
    #Move_Right
  EndEnumeration
  
  Enumeration MouseMove
    #Mouse_Move ; just changing the cursor ...
    #Mouse_Select  ; selecting
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
  
  #NoElement     = -1
  #CurrentCursor = -1
  #LastCursorX   = -2
  
  #Scroll_Max   = 10000
  
  #PB_Shortcut_Hyphen = 189
  ;}
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================   
  
  ;{ _____ Structures _____
  Structure Cursor_Thread_Structure ;{ Cursor-Thread
    Num.i
    Active.i
    Exit.i
  EndStructure ;}
  
  CompilerIf #Enable_Hyphenation    
    
    Structure HyphenStructure       ;{ Hyphenation
      chars.s
      pattern.s
    EndStructure ;}
    Global NewList HyphPattern.HyphenStructure()
    
  CompilerEndIf
  
  CompilerIf #Enable_SpellChecking
    
    Structure Dictionary_Structure
      Stem.s
      Endings.s
      Flag.i
    EndStructure
    
    Structure Spellcheck_Structure
      checked.i
      misspelled.i
    EndStructure
    
    Global NewList Dictionary.Dictionary_Structure()
    Global NewList UserDic.Dictionary_Structure()
    Global NewMap  Words.Spellcheck_Structure()
  CompilerEndIf
  
  CompilerIf #Enable_UndoRedo
    
    Structure Redo_Structure
      CursorPos.i
      CursorRow.i
      Text.s
    EndStructure
    
    Structure Undo_Diff_Structure ;{ EditEx()\Undo\Item()\DiffText()\..
      CursorPos.i
      CursorRow.i
      Text.s
      Length.i
      CRC32.s
    EndStructure ;}
    
    Structure Undo_Item_Structure ;{ EditEx()\Undo\Item()\...
      CursorPos.i
      CursorRow.i
      Text_1.s
      Length_1.i
      CRC32_1.s
      Text_2.s
      Length_2.i
      CRC32_2.s
      List DiffText.Undo_Diff_Structure()
    EndStructure ;}
    
    Structure Undo_Structure ;{ EditEx()\Undo\...
      CursorPos.i
      CursorRow.i
      Redo.Redo_Structure
      List Item.Undo_Item_Structure()
      MaxSteps.i
    EndStructure ;}
    
  CompilerEndIf
  
  Structure Font_Structure           ;{ Font(#Font)\...
    ID.i                             ; FontID(#Font)
    Height.i
    Map Char.i()
  EndStructure ;}
  Global NewMap Font.Font_Structure()
  
  Structure Select_Structure         ;{ Selection
    Row1.i
    Row2.i
    Pos1.i
    Pos2.i
    Flag.i
  EndStructure ;}
  
  ; ------------------------------
  Structure Text_Structure           ;{ Text\...
    CursorRow.i
    CursorPos.i
    Map Paragraph.s()
  EndStructure ;}
  ; ------------------------------
  
  Structure Path_Structure           ;{ Path\...
    Dictionary.s
    Pattern.s
  EndStructure ;}
  Global Path.Path_Structure
  
  Structure Words_List_Structure     ;{ EditEx()\Words()\Item()\...
    X.i
    Row.i
    Pos.i
    String.s
  EndStructure ;}
  
  Structure EditEx_Words_Structure   ;{ EditEx()\Words()\...
    ; Color.i
    List Item.Words_List_Structure()
    ; Flags.i
  EndStructure ;}
  
  Structure EditEx_Visible_Structure ;{ EditEx()\Visible\...
    RowOffset.i
    PosOffset.i
    CtrlChars.i
  EndStructure ;}
  
  Structure EditEx_Scroll_Structure  ;{ EditEx()\VScroll\...
    ID.i
    MinPos.i  ; FirstTop
    MaxPos.i  ; LastTop
    Position.i ; TopCell
    Hide.i
  EndStructure ;}

  Structure EditEx_Item_Structure    ;{ EditEx()\Items()\...
    String.s
    Y.i
  EndStructure ;}
  
  Structure EditEx_Text_Structure    ;{ EditEx()\Text\...
    X.i
    Y.i
    Width.i       ; maximum width for hyphenation
    Height.i      ; text height of rows
    Hyphen.i      ; character width
    Space.i       ; character width
    Rows.i
    RowOffset.i
    PosOffset.i
    MaxRowWidth.i ; maximum length of rows 
    Complete.i
  EndStructure ;}
  
  Structure EditEx_Mouse_Structure   ;{ EditEx()\Mouse\...
    ;X.i
    ;Y.i
    DeltaX.i ; will be used to relativise absolute X,Y
    DeltaY.i
    Cursor.i
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
    Pause.i
    State.i
  EndStructure ;}
  
  Structure EditEx_Color_Structure   ;{ EditEx()\Color\...
    Front.i
    Back.i
    Cursor.i
    SpellCheck.i
    SyntaxHighlight.i
    Highlight.i
    HighlightText.i
    ReadOnly.i
    ScrollBar.i
    Border.i
  EndStructure ;}
  
  Structure EditEx_Window_Structure  ;{ EditEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure EditEx_Size_Structure    ;{ EditEx()\Size\...
    X.f
    Y.f
    Width.i
    Height.i
  EndStructure ;}
  
  ; ----- EditEx - Structure -----
  
  Structure EditEx_Structure        ;{ EditEx(#gadget)\...
    gData.i
    CanvasNum.i
    FontID.i
    PopupMenu.i
    ; --- Flags ---
    Border.i
    ScrollBars.i 
    WordWrap.i
    SpellCheck.i
    AutoSpellCheck.i
    Hyphenation.i
    UndoRedo.i
    ReadOnly.i
    AutoHide.i
    SyntaxHighlight.i
    Flags.i
    ; ----------------
    Window.EditEx_Window_Structure
    Visible.EditEx_Visible_Structure
    Color.EditEx_Color_Structure
    Text.EditEx_Text_Structure
    Mouse.EditEx_Mouse_Structure
    HScroll.EditEx_Scroll_Structure
    VScroll.EditEx_Scroll_Structure
    Size.EditEx_Size_Structure
    Selection.Select_Structure
    Cursor.EditEx_Cursor_Structure
    CompilerIf #Enable_UndoRedo
      Undo.Undo_Structure
    CompilerEndIf
    ; ---------------
    Map  Syntax.i()
    Map  WordXY.EditEx_Words_Structure()
    List Items.EditEx_Item_Structure()
  EndStructure ;}
  
  Global NewMap EditEx.EditEx_Structure()
  
  Global Thread.Cursor_Thread_Structure
  
  ;} ------------------------------
  
  Global Time.i, Time1.i, Time2.i
  
  ;- ============================================================================
  ;-   Module - Internal   [ -> Selected EditEx() map element required ]
  ;- ============================================================================
  
  Declare   IsSelectedArea_(X.i, Y.i)
  Declare.i CursorRow_() 
  Declare   UpdateScrollBar_()
  Declare   Draw_(GNum.i)
  Declare.s DeleteStringPart(String.s, Position.i, Length.i=1)
  Declare.i GetWordStart(String.s, Position.i, Flags.i=#WordOnly)
  
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
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  Procedure.i Pixel_(pt.i)
    ProcedureReturn Round((pt * 96) / 72, #PB_Round_Nearest)
  EndProcedure
  
  ; ----- Text / TextArea -----
  
  Procedure   IsTextArea_(X.i, Y.i)
  
    If X <= EditEx()\Size\X Or X > EditEx()\Size\X + EditEx()\Size\Width
      ProcedureReturn #False
    ElseIf Y <= EditEx()\Size\Y Or Y > EditEx()\Size\Y + EditEx()\Size\Height
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i TextAreaWidth_()
    Define.i Width
    
    Width = dpiX(GadgetWidth(EditEx()\CanvasNum) - 8)
    If EditEx()\ScrollBars & #ScrollBar_Vertical And EditEx()\VScroll\Hide = #False
      Width - dpiX(#Scroll_Width + 1)
    EndIf
    
    ProcedureReturn Width - 4
  EndProcedure  
  
  Procedure.i TextAreaHeight_()
    Define.i Height
    
    Height = dpiY(GadgetHeight(EditEx()\CanvasNum) - 2)
    If EditEx()\ScrollBars & #ScrollBar_Horizontal And EditEx()\HScroll\Hide = #False
      Height - dpiY(#Scroll_Width + 1)
    EndIf
    
    ProcedureReturn Height - 4
  EndProcedure 
  
  Procedure.i TextWidth_(Text.s, Position.i=#PB_Default)
    Define.i p, Width, CharW
    
    If FindMapElement(Font(), Str(EditEx()\FontID))
      
      If Position = #PB_Default : Position = Len(Text) : EndIf
      
      If Position > 0
      
        For p=1 To Position
          Width + Font()\Char(Mid(Text, p, 1))
        Next
        
        ProcedureReturn Width
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure  
 
  Procedure.i CharPosX_(Flag.i, Position.i=#CurrentCursor, Row.i=#CurrentCursor, Offset.i=#True) ; Determine character X position based on position (Flag: #Left/#Right)
    Define.i p, CharX, X, Width
    Define.s Text$
    
    If ListSize(EditEx()\Items()) > 0
      
      If Row      = #CurrentCursor : Row      = EditEx()\Cursor\Row : EndIf
      If Position = #CurrentCursor : Position = EditEx()\Cursor\Pos : EndIf
      
      If FindMapElement(Font(), Str(EditEx()\FontID))
        
        PushListPosition(EditEx()\Items())
  
        If SelectElement(EditEx()\Items(), Row)
          
          If Offset
            X = EditEx()\Size\X - EditEx()\Visible\PosOffset
          Else
            X = EditEx()\Size\X
          EndIf
          
          Width = X
          Text$ = EditEx()\Items()\String
          
          For p = 1 To Position + 1
            CharX = Font()\Char(Mid(Text$, p, 1))
            Width + CharX
          Next
          
          If Flag & #Left : Width - CharX : EndIf
          
        EndIf
        
        PopListPosition(EditEx()\Items())
        
      EndIf
      
    EndIf
    
    ProcedureReturn Width
  EndProcedure
  
  Procedure.s TrimRow(Text.s)
    Text = RTrim(Text, #LineBreak$)
    ProcedureReturn RTrim(Text, #Hyphen$)
  EndProcedure
  
  Procedure.i GetNextSpace(String.s, Position.i)
    Define.i p
    
    For p = Position To Len(String)
      Select Mid(String, p, 1)
        Case " "
          ProcedureReturn p
        Case "{", "[", "(", "<"
          ProcedureReturn p + 1
        Case Chr(34), "'", "»", "«"
          ProcedureReturn p + 1 
      EndSelect
    Next
    
    If p >= Len(String) : p = Position : EndIf
    
    ProcedureReturn p
  EndProcedure
  
  Procedure.i GetNextParagraph_(Row.i)
    Define.i ParaRow
    
    PushListPosition(EditEx()\Items())
    
    If SelectElement(EditEx()\Items(), Row)
      Repeat
        If Right(EditEx()\Items()\String, 1) = #LineBreak$
          ParaRow = ListIndex(EditEx()\Items()) + 1
          Break
        EndIf 
      Until NextElement(EditEx()\Items()) = #False
    EndIf
    
    PopListPosition(EditEx()\Items())
    
    If ParaRow > ListSize(EditEx()\Items())-1 : ParaRow = #NoElement : EndIf
    
    ProcedureReturn ParaRow
  EndProcedure
  
  Procedure.i GetPrevParagraph_(Row.i)
    Define.i ParaRow
    
    PushListPosition(EditEx()\Items())
    
    If SelectElement(EditEx()\Items(), Row)
      While PreviousElement(EditEx()\Items())
        If Right(EditEx()\Items()\String, 1) = #LineBreak$
          ParaRow = ListIndex(EditEx()\Items())
          Break
        EndIf
      Wend
    EndIf
    
    PopListPosition(EditEx()\Items())
    
    If ParaRow = Row : ParaRow = 0 : EndIf
    
    ProcedureReturn ParaRow
  EndProcedure
  
  Procedure.i GetPageRows_(ScrollBar = #True)
    Define.i Rows
    
    If EditEx()\Text\Height
      If ScrollBar
        ProcedureReturn EditEx()\Size\Height / EditEx()\Text\Height
      Else
        ProcedureReturn dpiY(GadgetHeight(EditEx()\CanvasNum) - 4) / EditEx()\Text\Height
      EndIf 
    EndIf

  EndProcedure
  
  ;- ----- Mouse -----
  
  Procedure   ChangeMouseCursor_(GNum.i, CursorX.i, CursorY.i) 
    
    If IsTextArea_(CursorX, CursorY)
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
  
  ;- ----- Position (X) / Row (Y)  -----
  
  Procedure.i LastVisibleX_()
    ProcedureReturn EditEx()\Size\X + EditEx()\Size\Width
  EndProcedure
  
  Procedure.i LastVisibleY_()
    ProcedureReturn EditEx()\Size\Y + EditEx()\Size\Height
  EndProcedure    
  
  Procedure.i IsRowVisible_(Row.i)
    Define.i Y1, Y2
    
    Y1 = EditEx()\Size\Y + (Row * EditEx()\Text\Height) ; Top of row
    Y2 = Y1 + EditEx()\Text\Height - 1                ; Bottom of Row
    
    If Y1 >= EditEx()\Size\Y And Y2 <= LastVisibleY_()
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure 
  
  Procedure.i LastRow_()
    ProcedureReturn ListSize(EditEx()\Items()) - 1
  EndProcedure  
  
  Procedure.i GetRow_(Y.i, Offset.i=#True) ; Row at Y-Position
    Define.i Row
    If Offset
      Row = Int((Y - EditEx()\Size\Y) / EditEx()\Text\Height) + EditEx()\Visible\RowOffset
    Else
      Row = Int((Y - EditEx()\Size\Y) / EditEx()\Text\Height)
    EndIf
    If Row < 0 : Row = 0 : EndIf
    If Row >= ListSize(EditEx()\Items()) : Row = ListSize(EditEx()\Items()) - 1 : EndIf
    ProcedureReturn Row
  EndProcedure
  
  Procedure   GetY_(Row.i)
    
    ProcedureReturn  EditEx()\Size\Y + (Row * EditEx()\Text\Height)
    
  EndProcedure
  
  ;- ----- Cursor -----
  
  Procedure.i CursorRow_()                                                 ; Current row = ListIndex()
    Define.i Row
    
    Row = ListIndex(EditEx()\Items())
    If Row = #NoElement
      LastElement(EditEx()\Items())
      Row = ListSize(EditEx()\Items()) - 1
    EndIf 
  
    ProcedureReturn Row
  EndProcedure 
  
  Procedure.i CursorPos_(Row.i=#CurrentCursor, CursorX.i=#CurrentCursor)   ; Determine cursor position based on X position (#CurrentCursor / #LastCursorX)
    Define.i p, X, CharX, Width, Position = 0
    Define.s Text$
    
    If ListSize(EditEx()\Items()) > 0
      
      If FindMapElement(Font(), Str(EditEx()\FontID))
        
        If Row = #CurrentCursor : Row = CursorRow_() : EndIf
        
        If CursorX = #CurrentCursor ;{ CursorX
          CursorX = EditEx()\Cursor\X
        ElseIf CursorX = #LastCursorX
          CursorX = EditEx()\Cursor\LastX
          ;}
        EndIf 
        
        PushListPosition(EditEx()\Items())
        
        If SelectElement(EditEx()\Items(), Row)
  
          Text$ = EditEx()\Items()\String
          Width = EditEx()\Size\X - EditEx()\Visible\PosOffset
          
          If CursorX >= Width
          
            For p = 1 To Len(Text$)
              
              CharX = Font()\Char(Mid(Text$, p, 1))
  
              If Width + CharX >= CursorX : Break : EndIf
              
              Width + CharX
              
              Position = p ; Cursor to the left of the letter
            Next
        
            If CursorX - Width > (Width + CharX) - CursorX
              Position + 1 ; Cursor to the right of the letter
            EndIf
            
            Text$ = RTrim(Text$, #LineBreak$)
            If Position > Len(Text$) : Position = Len(Text$) : EndIf
            
          Else
            
            Position = 0
            
          EndIf  
          
        EndIf
  
        PopListPosition(EditEx()\Items())
        
      EndIf
      
    EndIf
    
    ProcedureReturn Position  
  EndProcedure
  
  Procedure.i CursorX_(Row.i=#CurrentCursor, Position.i=#CurrentCursor, Offset.i=#True)    ; #CurrentCursor
    ; Pos 0: '|abc' / Pos1: 'a|bc'
    Define.i X, Width
    Define.s Text$ 
    
    If ListSize(EditEx()\Items()) > 0
      
      If Row      = #CurrentCursor : Row      = EditEx()\Cursor\Row      : EndIf
      If Position = #CurrentCursor : Position = EditEx()\Cursor\Pos : EndIf
      
      If Offset
        X = EditEx()\Size\X - EditEx()\Visible\PosOffset
      Else
        X = EditEx()\Size\X
      EndIf
      
      PushListPosition(EditEx()\Items())
      
      If SelectElement(EditEx()\Items(), Row) 
        Width = TextWidth_(Left(EditEx()\Items()\String, Position))
      EndIf
      
      PopListPosition(EditEx()\Items())
      
      ProcedureReturn Width + X
    EndIf
    
  EndProcedure

  Procedure.i CursorY_(Row.i=#CurrentCursor, Offset.i=#True) 
    Define.i CursorY
    
    If Row = #CurrentCursor : Row = CursorRow_() : EndIf
    
    If Offset
      Row - EditEx()\Visible\RowOffset
    EndIf
    
    CursorY = EditEx()\Size\Y + (Row * EditEx()\Text\Height)

    ProcedureReturn CursorY
  EndProcedure  
  
  ;- ----- Scrolling -----
  
  Procedure.i GetTextSize_(Flag.i)        ; Get the size of of the (visible and invisible) text
    Select  Flag
      Case #Vertical
        ProcedureReturn ListSize(EditEx()\Items()) * EditEx()\Text\Height
      Case #Horizontal
        ProcedureReturn EditEx()\Text\MaxRowWidth
    EndSelect  
  EndProcedure
  
  Procedure.i GetScrollStateMax_(Flag.i)  ; Maximum state of the scrollbar
    Define.i PageSize
    Select  Flag
      Case #Vertical
        
        ProcedureReturn LastRow_() - GetPageRows_() + 1
        
      Case #Horizontal
        
        ProcedureReturn GetTextSize_(#Horizontal) - EditEx()\Size\Width + 1
        
    EndSelect
  EndProcedure
  
  Procedure.i AdjustScrolls_(ReDraw.i=#True)
    Define.i GNum, PageSize, TextSize, PageRows, MaxRows, MaxPos
    Define.i HScroll, VScroll
    
    TextSize = EditEx()\Text\MaxRowWidth
    MaxRows  = ListSize(EditEx()\Items())
    If MaxRows < 0 : MaxRows = 0 : EndIf
    
    If EditEx()\Flags & #ScrollBar_Horizontal : HScroll = #True : EndIf
    If EditEx()\Flags & #ScrollBar_Vertical   : VScroll = #True : EndIf

    If TextSize <= dpiX(GadgetWidth(EditEx()\CanvasNum) - 8) : HScroll = #False : EndIf
    If MaxRows  <= GetPageRows_(#False) : VScroll = #False : EndIf
    
    If VScroll And HScroll ;{ Both scrollbars necessary
      EditEx()\Size\Width  = dpiX(GadgetWidth(EditEx()\CanvasNum)  - #Scroll_Width - 8) 
      EditEx()\Size\Height = dpiY(GadgetHeight(EditEx()\CanvasNum) - #Scroll_Width - 4)
      ;}
    ElseIf HScroll         ;{ Horizontal scrollbar necessary
      EditEx()\Size\Height = dpiY(GadgetHeight(EditEx()\CanvasNum) - #Scroll_Width - 4)
      If MaxRows > GetPageRows_()
        EditEx()\Size\Width = dpiX(GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 8) 
        VScroll = #True 
      EndIf ;}
    ElseIf VScroll         ;{ Vertical scrollbar necessary
      EditEx()\Size\Width = dpiX(GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 8)
      If TextSize > EditEx()\Size\Width
        EditEx()\Size\Height = dpiY(GadgetHeight(EditEx()\CanvasNum) - #Scroll_Width - 4)
        HScroll = #True
      EndIf ;}
    Else                   ;{ No scrollbars necessary
      
      EditEx()\Size\Width  = dpiX(GadgetWidth(EditEx()\CanvasNum)  - 8) 
      EditEx()\Size\Height = dpiY(GadgetHeight(EditEx()\CanvasNum) - 4)
      ;}
    EndIf
    
    If IsGadget(EditEx()\HScroll\ID) ;{ Horizontal Scrollbar
      
      GNum = GetGadgetData(EditEx()\HScroll\ID)
      
      If GetScrollStateMax_(#Horizontal) <= #Scroll_Max
        
        If HScroll And EditEx()\HScroll\Hide
          HideGadget(EditEx()\HScroll\ID, #False)
          If VScroll
            ResizeGadget(EditEx()\HScroll\ID, 2, GadgetHeight(EditEx()\CanvasNum) - #Scroll_Width - 1, GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 2, #Scroll_Width)
          Else
            ResizeGadget(EditEx()\HScroll\ID, 2, GadgetHeight(EditEx()\CanvasNum) - #Scroll_Width - 1, GadgetWidth(EditEx()\CanvasNum) - 2, #Scroll_Width)
          EndIf
        ElseIf Not HScroll And Not EditEx()\HScroll\Hide
          HideGadget(EditEx()\HScroll\ID, #True)
        EndIf

        SetGadgetAttribute(EditEx()\HScroll\ID, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(EditEx()\HScroll\ID, #PB_ScrollBar_PageLength, EditEx()\Size\Width)
        SetGadgetAttribute(EditEx()\HScroll\ID, #PB_ScrollBar_Maximum,    TextSize)
        
        EditEx()\HScroll\MinPos   = 1
        EditEx()\HScroll\MaxPos   = GetScrollStateMax_(#Horizontal)
        
      EndIf
      ;}
    EndIf
    
    If IsGadget(EditEx()\VScroll\ID) ;{ Vertical Scrollbar
     
      GNum = GetGadgetData(EditEx()\VScroll\ID)
      
      MaxPos = GetScrollStateMax_(#Vertical)
      If MaxPos <= #Scroll_Max
        If VScroll And EditEx()\VScroll\Hide
          HideGadget(EditEx()\VScroll\ID, #False)
          If HScroll
            ResizeGadget(EditEx()\VScroll\ID, GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 1, 2, #Scroll_Width, GadgetHeight(EditEx()\CanvasNum) - #Scroll_Width - 2) 
          Else
            ResizeGadget(EditEx()\VScroll\ID, GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 1, 2, #Scroll_Width, GadgetHeight(EditEx()\CanvasNum) - 4)
          EndIf 
        ElseIf Not VScroll And Not EditEx()\VScroll\Hide
          HideGadget(EditEx()\VScroll\ID, #True)
        EndIf
        
        SetGadgetAttribute(EditEx()\VScroll\ID, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(EditEx()\VScroll\ID, #PB_ScrollBar_PageLength, GetPageRows_() + 1)
        SetGadgetAttribute(EditEx()\VScroll\ID, #PB_ScrollBar_Maximum,    MaxRows)
        
        EditEx()\VScroll\MinPos = 0
        EditEx()\VScroll\MaxPos = MaxPos
        
      EndIf 
      ;}
    EndIf
    
    If VScroll : EditEx()\VScroll\Hide = #False :  Else : EditEx()\VScroll\Hide = #True : EndIf 
    If HScroll : EditEx()\HScroll\Hide = #False :  Else : EditEx()\HScroll\Hide = #True : EndIf
    
    If IsGadget(GNum) And ReDraw : Draw_(GNum) : EndIf
  EndProcedure
  
  Procedure   SetHScrollPosition_()
    Define.i ScrollPos
    
    If IsGadget(EditEx()\HScroll\ID)
      ScrollPos = EditEx()\Visible\PosOffset
      If ScrollPos < EditEx()\HScroll\MinPos : ScrollPos = EditEx()\HScroll\MinPos : EndIf
      EditEx()\HScroll\Position = ScrollPos
      SetGadgetState(EditEx()\HScroll\ID, ScrollPos)
    EndIf
    
  EndProcedure 
  
  Procedure   SetVScrollPosition_()
    Define.i ScrollPos
    
    If IsGadget(EditEx()\VScroll\ID)
      ScrollPos = EditEx()\Visible\RowOffset
      If ScrollPos > EditEx()\VScroll\MaxPos : ScrollPos = EditEx()\VScroll\MaxPos : EndIf
      EditEx()\VScroll\Position = ScrollPos
      SetGadgetState(EditEx()\VScroll\ID, ScrollPos)
    EndIf
    
  EndProcedure  
  
  Procedure   UpdateScrollBar_()
    ; Pos 0: '|abc' / Pos1: 'a|bc'
    Define.i fvX, lvX, CharX
    Define.i ScrollBarPos, CursorRow, PageRows, CharX
    Define.s Text
    
    If IsGadget(EditEx()\HScroll\ID) ;{ Horizontal Scrollbar

      CharX = CharPosX_(#Left, #CurrentCursor, #CurrentCursor, #False)
      If CharX - EditEx()\Visible\PosOffset <= EditEx()\Size\X
        EditEx()\Visible\PosOffset = CharX - EditEx()\Size\X
        SetGadgetState(EditEx()\HScroll\ID, EditEx()\Visible\PosOffset)
      EndIf
      
      CharX = CharPosX_(#Right, #CurrentCursor, #CurrentCursor, #False)
      If CharX >= LastVisibleX_()
        EditEx()\Visible\PosOffset = CharX - LastVisibleX_()
        SetGadgetState(EditEx()\HScroll\ID, EditEx()\Visible\PosOffset)
      EndIf

      SetHScrollPosition_()
      ;}
    EndIf
  
    If IsGadget(EditEx()\VScroll\ID) ;{ Vertical Scrollbar
      
      CursorRow = EditEx()\Cursor\Row
      PageRows  = GetPageRows_() - 1
      
      If CursorRow < EditEx()\Visible\RowOffset
        EditEx()\Visible\RowOffset = CursorRow
        If EditEx()\Visible\RowOffset < 0 : EditEx()\Visible\RowOffset = 0 : EndIf
        SetGadgetState(EditEx()\VScroll\ID, EditEx()\VScroll\Position)
      EndIf
     
      If CursorRow > PageRows
        EditEx()\Visible\RowOffset = CursorRow - PageRows
        SetGadgetState(EditEx()\VScroll\ID, EditEx()\VScroll\Position)
      EndIf
 
      SetVScrollPosition_()
      ;}
    EndIf

    AdjustScrolls_(#False)
    
  EndProcedure
  
  ;- ----- Strings -----
  
  Procedure.s StringSegment(String.s, Pos1.i, Pos2.i=#PB_Ignore) ; Return String from Pos1 to Pos2 
    Define.i Length = Pos2 - Pos1
    If Pos2 = #PB_Ignore
      ProcedureReturn Mid(String, Pos1 + 1 , Len(String) - Pos1)
    Else
      ProcedureReturn Mid(String, Pos1 + 1, Pos2 - Pos1)
    EndIf
  EndProcedure 

  Procedure.s DeleteStringPart(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf
    
    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure
 
  Procedure.i FindNextSpace(Text.s)
    Define.i c
    
    For c = Len(Text) To 1 Step -1
      If Mid(Text, c, 1) = " "
        ProcedureReturn c
      EndIf
    Next
    
  EndProcedure
  
  ;- ----- Selection -----
  
  Procedure   IsSelectedChar(Row.i, Pos.i)
    ; Pos 0: '|abc' / Pos1: 'a|bc'
    Define.i Row1, Row2
    Define.i Result = #False

    If EditEx()\Selection\Flag = #Selected
      
      If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
        Row1 = EditEx()\Selection\Row2
        Row2 = EditEx()\Selection\Row1
      Else
        Row1 = EditEx()\Selection\Row1
        Row2 = EditEx()\Selection\Row2
      EndIf
      
      If Row >= Row1 And Row <= Row2
        
        PushListPosition(EditEx()\Items())
        
        If SelectElement(EditEx()\Items(), Row)
          
          If Row1 = Row2 ;{ Single Row
            If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
              If Pos >= EditEx()\Selection\Pos2 And Pos < EditEx()\Selection\Pos1
                Result = #True
              EndIf
            Else
              If Pos >= EditEx()\Selection\Pos1 And Pos < EditEx()\Selection\Pos2
                Result = #True
              EndIf
            EndIf
            ;}
          Else           ;{ Multiple Rows
            Select Row
              Case Row1
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  If Pos >= EditEx()\Selection\Pos2
                    Result = #True
                  EndIf
                Else
                  If Pos >= EditEx()\Selection\Pos1
                    Result = #True
                  EndIf
                EndIf
              Case Row2
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  If Pos < EditEx()\Selection\Pos1
                    Result = #True
                  EndIf
                Else
                  If Pos < EditEx()\Selection\Pos2
                    Result = #True
                  EndIf
                EndIf
              Default
                Result = #True
            EndSelect ;}
          EndIf  
          
        EndIf

        PopListPosition(EditEx()\Items())  
  
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
 
  Procedure   IsSelectedArea_(X.i, Y.i)
    Define.i Row, Pos, Row1, Row2
    Define.i Result = #False
    
    If EditEx()\Selection\Flag = #Selected
      
      Row = GetRow_(Y)
      
      If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
        Row1 = EditEx()\Selection\Row2
        Row2 = EditEx()\Selection\Row1
      Else
        Row1 = EditEx()\Selection\Row1
        Row2 = EditEx()\Selection\Row2
      EndIf
      
      If Row >= Row1 And Row <= Row2
        
        PushListPosition(EditEx()\Items())
        
        If SelectElement(EditEx()\Items(), Row)
          
          Pos = CursorPos_(Row, X)
          
          If Row1 = Row2 ;{ Single Row
            If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
              If Pos >= EditEx()\Selection\Pos2 And Pos <= EditEx()\Selection\Pos1
                Result = #True
              EndIf
            Else
              If Pos >= EditEx()\Selection\Pos1 And Pos <= EditEx()\Selection\Pos2
                Result = #True
              EndIf
            EndIf
            ;}
          Else           ;{ Multiple Rows
            Select Row
              Case Row1
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  If Pos >= EditEx()\Selection\Pos2
                    Result = #True
                  EndIf
                Else
                  If Pos >= EditEx()\Selection\Pos1
                    Result = #True
                  EndIf
                EndIf
              Case Row2
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  If Pos <= EditEx()\Selection\Pos1
                    Result = #True
                  EndIf
                Else
                  If Pos <= EditEx()\Selection\Pos2
                    Result = #True
                  EndIf
                EndIf
              Default
                Result = #True
            EndSelect ;}
          EndIf  
          
        EndIf

        PopListPosition(EditEx()\Items())  
  
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure   RemoveSelection_()               ; Remove & Reset Selection 
    
    If EditEx()\Selection\Flag = #Selected
      EditEx()\Selection\Flag = #NoSelection
      EditEx()\Selection\Row1 = #False
      EditEx()\Selection\Pos1 = #False
      EditEx()\Selection\Row2 = #False
      EditEx()\Selection\Pos2 = #False
      EditEx()\Text\Complete  = #True
    EndIf
    
  EndProcedure

  Procedure   ReFormat_()
    Define.s Text$
    
    If EditEx()\WordWrap = #False And EditEx()\Hyphenation = #False
      
      PushListPosition(EditEx()\Items())
      
      If FirstElement(EditEx()\Items())
        
        Repeat
          
          If Right(EditEx()\Items()\String, 1) <> #LF$
            
            If NextElement(EditEx()\Items())
              Text$ = EditEx()\Items()\String
              If DeleteElement(EditEx()\Items())
                EditEx()\Items()\String = RTrim(EditEx()\Items()\String, #LineBreak$)
                EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                EditEx()\Items()\String = EditEx()\Items()\String + Text$
              EndIf
            EndIf  
            
            
          EndIf
          
        Until NextElement(EditEx()\Items()) = #False
        
      EndIf
      
      PopListPosition(EditEx()\Items())
      
      EditEx()\Text\Complete = #True
    EndIf
    
  EndProcedure
  
  Procedure.i DeleteSelection_(Remove.i=#True) ; Delete selected text (Remove selection: #True/#False)
    Define.i r, Row1, Row2, CurrentRow 
    Define.s Text

    If EditEx()\Selection\Flag = #Selected
      
      If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
        Row1 = EditEx()\Selection\Row2
        Row2 = EditEx()\Selection\Row1
      Else
        Row1 = EditEx()\Selection\Row1
        Row2 = EditEx()\Selection\Row2
      EndIf
      
      If Row1 = Row2 ;{ Single row
        If SelectElement(EditEx()\Items(), Row1)
          Text = EditEx()\Items()\String
          If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
            EditEx()\Items()\String = Left(Text, EditEx()\Selection\Pos2) + Mid(Text, EditEx()\Selection\Pos1 + 1)
          Else
            EditEx()\Items()\String = Left(Text, EditEx()\Selection\Pos1) + Mid(Text, EditEx()\Selection\Pos2 + 1)
          EndIf 
        EndIf ;}
      Else                                             ;{ Multiple rows
        CurrentRow = Row1
        For r = Row1 To Row2
          If SelectElement(EditEx()\Items(), CurrentRow)
            Select r
              Case Row1
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  EditEx()\Items()\String = Left(EditEx()\Items()\String, EditEx()\Selection\Pos2)
                Else
                  EditEx()\Items()\String = Left(EditEx()\Items()\String, EditEx()\Selection\Pos1)
                EndIf
              Case Row2
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  Text = Mid(EditEx()\Items()\String, EditEx()\Selection\Pos1 + 1)
                Else
                  Text = Mid(EditEx()\Items()\String, EditEx()\Selection\Pos2 + 1)
                EndIf
                If DeleteElement(EditEx()\Items())
                  EditEx()\Items()\String + Text
                EndIf
              Default
                If DeleteElement(EditEx()\Items())
                  CurrentRow - 1
                EndIf
            EndSelect
          EndIf 
          CurrentRow + 1
        Next ;}
      EndIf
      
      ReFormat_()
      
      If SelectElement(EditEx()\Items(), Row1)
        If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
          EditEx()\Cursor\Pos = EditEx()\Selection\Pos2
        Else
          EditEx()\Cursor\Pos = EditEx()\Selection\Pos1
        EndIf
      EndIf

      If Remove : RemoveSelection_() : EndIf
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s GetSelection_(Remove.i=#True)    ; Return selected text (Remove selection: #True/#False)
    Define.i r, Row1, Row2
    Define.s Text.s
    
    If EditEx()\Selection\Flag = #Selected      
      
      PushListPosition(EditEx()\Items())
      
      If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
        Row1 = EditEx()\Selection\Row2
        Row2 = EditEx()\Selection\Row1
      Else
        Row1 = EditEx()\Selection\Row1
        Row2 = EditEx()\Selection\Row2
      EndIf
      
      If Row1 = Row2 ;{ Single row
        If SelectElement(EditEx()\Items(), Row1)
          If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
            Text = StringSegment(EditEx()\Items()\String, EditEx()\Selection\Pos2, EditEx()\Selection\Pos1)
          Else
            Text = StringSegment(EditEx()\Items()\String, EditEx()\Selection\Pos1, EditEx()\Selection\Pos2)
          EndIf
        EndIf ;}
      Else  ;{ Multiple rows
        
        
        For r = Row1 To Row2
          If SelectElement(EditEx()\Items(), r)
            Select r
              Case Row1
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  Text = StringSegment(EditEx()\Items()\String, EditEx()\Selection\Pos2, #PB_Ignore)
                Else
                  Text = StringSegment(EditEx()\Items()\String, EditEx()\Selection\Pos1, #PB_Ignore)
                EndIf 
                If Right(Text, 1) <> #LineBreak$ And Right(Text, 1) <> " " : Text + " " : EndIf
              Case Row2
                If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                  Text + StringSegment(EditEx()\Items()\String, 0, EditEx()\Selection\Pos1)
                Else
                  Text + StringSegment(EditEx()\Items()\String, 0, EditEx()\Selection\Pos2)
                EndIf
              Default
                Text + EditEx()\Items()\String
                If Right(Text, 1) <> #LineBreak$ And Right(Text, 1) <> " " : Text + " " : EndIf
            EndSelect
          EndIf
        Next ;}
      EndIf
      
      PopListPosition(EditEx()\Items())
      
      If Remove : RemoveSelection_() : EndIf
      
      ProcedureReturn Text
    EndIf
  
  EndProcedure
  
  ;- ----- Text / Words -----
  
  Procedure   AddItem_(Position.i, Text.s)
    
    Select Position
      Case 0
        ResetList(EditEx()\Items())
        If AddElement(EditEx()\Items())
          EditEx()\Items()\String = Text
          ProcedureReturn #True
        EndIf
      Case -1
        LastElement(EditEx()\Items())
        If AddElement(EditEx()\Items())
          EditEx()\Items()\String = Text
          ProcedureReturn #True
        EndIf
      Default
        If Position < ListSize(EditEx()\Items())
          If SelectElement(EditEx()\Items(), Position)
            If InsertElement(EditEx()\Items())
              EditEx()\Items()\String = Text
              ProcedureReturn #True
            EndIf
          EndIf
        EndIf
    EndSelect
    
    ProcedureReturn #False
  EndProcedure

  Procedure.i GetWordStart(String.s, Position.i, Flags.i=#WordOnly) ; Position of the first letter of the word
    Define.i p
    
    For p = Position To 1 Step -1
      Select Mid(String, p, 1)
        Case " ", #CR$, #LF$, #LineBreak$
          ProcedureReturn p
        Case ".", ":", ",", ";", "!", "?"
          If Flags & #Punctation Or Flags & #WordOnly
            ProcedureReturn p
          EndIf
        Case "{", "[", "(", "<"
          If Flags & #Brackets Or Flags & #WordOnly
            ProcedureReturn p
          EndIf
        Case Chr(34), "'", "«", "»"
          If Flags & #QuotationMarks Or Flags & #WordOnly
            ProcedureReturn p
          EndIf
      EndSelect
    Next
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure.i GetWordEnd(String.s, Position.i, Flags.i=#WordOnly)   ; Position of the last letter of the word
    Define.i p
    
    For p = Position To Len(String)
      Select Mid(String, p, 1)
        Case " ", #CR$, #LF$, #LineBreak$
          ProcedureReturn p-1
        Case ".", ":", ",", ";", "!", "?"
          If Flags & #Punctation Or Flags & #WordOnly
            ProcedureReturn p-1
          EndIf
        Case ")", "]", "}", ">"
          If Flags & #Brackets Or Flags & #WordOnly
            ProcedureReturn p-1
          EndIf
        Case Chr(34), "'", "»", "«"
          If Flags & #QuotationMarks Or Flags & #WordOnly
            ProcedureReturn p-1
          EndIf  
      EndSelect
    Next
    
    ProcedureReturn p
  EndProcedure
  
  Procedure.i GetSpaceStart(String.s, Position.i) 
    Define.i p
    
    For p = Position To 1 Step -1
      If Mid(String, p, 1) <> " "
        ProcedureReturn p
      EndIf 
    Next
    
    ProcedureReturn 1
  EndProcedure  
  
  Procedure.i GetSpaceEnd(String.s, Position.i)
    Define.i p
    
    For p = Position To Len(String)
      
      If Mid(String, p, 1) <> " "
        ProcedureReturn p-1
      EndIf
      
    Next
    
    ProcedureReturn p
  EndProcedure
  
  Procedure.s GetWord(Word.s, Flags.i=#WordOnly)
    Define i.i, Char$, Diff1$, Diff2$

    Word = RTrim(Trim(Word), #LineBreak$)
    If EditEx()\Visible\CtrlChars : Word = RTrim(Word, #Paragraph$) : EndIf
    
    For i=1 To 2
      Char$ = Left(Word, 1)
      Select Char$
        Case "{", "[", "(", "<"
          If Flags & #Brackets Or Flags & #WordOnly
            Word = LTrim(Word, Char$)
            Diff1$ + Char$
          EndIf
        Case Chr(34), "'", "«", "»"
          If Flags & #QuotationMarks Or Flags & #WordOnly
            Word = LTrim(Word, Char$)
            Diff1$ + Char$
          EndIf
        Case #SoftHyphen$, #LineBreak$, #Paragraph$
          Word = LTrim(Word, Char$)
        Default
          Break
      EndSelect
    Next
    
    For i=1 To 2
      Char$ = Right(Word, 1)
      Select Char$
        Case ".", ":", ",", ";", "!", "?"
          If Flags & #Punctation Or Flags & #WordOnly
            Word = RTrim(Word, Char$)
            Diff2$ + Char$
          EndIf
        Case  ")", "]", "}", ">"
          If Flags & #Brackets Or Flags & #WordOnly
            Word = RTrim(Word, Char$)
            Diff2$ + Char$
          EndIf
        Case Chr(34), "'", "«", "»"
          If Flags & #QuotationMarks Or Flags & #WordOnly
            Word = RTrim(Word, Char$)
            Diff2$ + Char$
          EndIf  
        Case " ", #SoftHyphen$, #LineBreak$
          Word = LTrim(Word, Char$)
        Default
          Break
      EndSelect
    Next
    If Flags & #Parse
      ProcedureReturn Diff1$+"|"+Word+"|"+Diff2$
    Else  
      ProcedureReturn Word
    EndIf
  EndProcedure
  
  Procedure   GetWordXY_()
    Define.i i, Spaces, StartRow, EndRow
    Define.s Text$, Word$, LWord$, Draw$, SplitWord$, Parse$, Diff$
    Define SplitWord.Words_List_Structure
    
    ClearMap(EditEx()\WordXY())
    
    StartRow = EditEx()\Visible\RowOffset
    EndRow   = GetPageRows_() + EditEx()\Visible\RowOffset
    
    If SelectElement(EditEx()\Items(), StartRow)

      Repeat
      
        Text$  = EditEx()\Items()\String
        
        If EditEx()\Visible\CtrlChars
          Text$ = ReplaceString(Text$, #LineBreak$, #Paragraph$)
        Else
          Text$ = RemoveString(Text$, #SoftHyphen$)
        EndIf
        
        Draw$  = ""
        Spaces = CountString(Text$, " ")
        
        For i = 1 To Spaces + 1
          
          Word$  = GetWord(StringField(Text$, i, " "), #Punctation)
          LWord$ = Word$
          Parse$ = GetWord(Word$, #WordOnly|#Parse)
          Diff$  = StringField(Parse$, 1, "|")
          
          If EditEx()\SyntaxHighlight & #NoCase : LWord$ = LCase(LWord$) : EndIf
      
          If Right(LWord$, 1) = #Hyphen$ And i = Spaces + 1 ;{ Hyphenated word
            
            SplitWord\String = Word$
            SplitWord\X      = TextWidth(Draw$)  
            SplitWord\Row    = ListIndex(EditEx()\Items())
            
          ElseIf SplitWord\String <> "" And i = 1
            
            SplitWord$ = RTrim(SplitWord\String, #Hyphen$) + LWord$
            
            LWord$ = SplitWord$
            If EditEx()\SyntaxHighlight & #NoCase : LWord$ = LCase(LWord$) : EndIf
            
            If AddElement(EditEx()\WordXY(LWord$)\Item()) ;{ word part 1
              EditEx()\WordXY(LWord$)\Item()\String = SplitWord\String
              EditEx()\WordXY(LWord$)\Item()\X      = SplitWord\X
              EditEx()\WordXY(LWord$)\Item()\Row    = SplitWord\Row
              ;}
            EndIf
            
            If AddElement(EditEx()\WordXY(LWord$)\Item()) ;{ word part 2
              EditEx()\WordXY(LWord$)\Item()\String = Word$
              EditEx()\WordXY(LWord$)\Item()\X      = TextWidth(Draw$)
              EditEx()\WordXY(LWord$)\Item()\Row    = ListIndex(EditEx()\Items())
              ;}
            EndIf
            
            Parse$ = GetWord(SplitWord$, #WordOnly|#Parse)
            Diff$  = StringField(Parse$, 1, "|")
            If Diff$ <> ""
              
              LWord$ = StringField(Parse$, 2, "|")
              If EditEx()\SyntaxHighlight = #NoCase : LWord$ = LCase(LWord$) : EndIf
              
              If AddElement(EditEx()\WordXY(LWord$)\Item()) ;{ word part 1
                EditEx()\WordXY(LWord$)\Item()\String = GetWord(SplitWord\String)
                EditEx()\WordXY(LWord$)\Item()\X      = SplitWord\X  + TextWidth(Diff$)
                EditEx()\WordXY(LWord$)\Item()\Row    = SplitWord\Row
                ;}
              EndIf
              
              If AddElement(EditEx()\WordXY(LWord$)\Item()) ;{ word part 2
                EditEx()\WordXY(LWord$)\Item()\String = GetWord(Word$)
                EditEx()\WordXY(LWord$)\Item()\X      = TextWidth(Draw$)
                EditEx()\WordXY(LWord$)\Item()\Row    = ListIndex(EditEx()\Items())
                ;}
              EndIf
              
            EndIf
            
            SplitWord\String = ""
            ;}
          Else                                              ;{ Complete word   
            
            If AddElement(EditEx()\WordXY(LWord$)\Item())
              EditEx()\WordXY(LWord$)\Item()\String = Word$
              EditEx()\WordXY(LWord$)\Item()\X      = TextWidth(Draw$)
              EditEx()\WordXY(LWord$)\Item()\Pos    = Len(Draw$) + 1
              EditEx()\WordXY(LWord$)\Item()\Row    = ListIndex(EditEx()\Items())
            EndIf
            
            Parse$ = GetWord(Word$, #WordOnly|#Parse)
            Diff$  = StringField(Parse$, 1, "|")
            If Diff$ <> ""
              Word$  = StringField(Parse$, 2, "|")
              LWord$ = Word$
              If EditEx()\SyntaxHighlight = #NoCase : LWord$ = LCase(Word$) : EndIf
              If AddElement(EditEx()\WordXY(LWord$)\Item())
                EditEx()\WordXY(LWord$)\Item()\X      = TextWidth(Draw$ + Diff$)
                EditEx()\WordXY(LWord$)\Item()\Row    = ListIndex(EditEx()\Items())
                EditEx()\WordXY(LWord$)\Item()\Pos    = Len(Draw$ + Diff$) + 1
                EditEx()\WordXY(LWord$)\Item()\String = Word$
              EndIf
            EndIf
            ;}
          EndIf
          
          Draw$ = Draw$ + StringField(Text$, i, " ") + " "
          
        Next
        
        If EditEx()\Visible\CtrlChars ;{
          If Right(Text$, 1) = #Paragraph$
            If AddElement(EditEx()\WordXY(#Paragraph$)\Item())
              EditEx()\WordXY(#Paragraph$)\Item()\String = #Paragraph$
              EditEx()\WordXY(#Paragraph$)\Item()\X      = TextWidth(RTrim(Text$, #Paragraph$))
              EditEx()\WordXY(#Paragraph$)\Item()\Pos    = Len(RTrim(Text$, #Paragraph$))
              EditEx()\WordXY(#Paragraph$)\Item()\Row    = ListIndex(EditEx()\Items())
            EndIf
          EndIf ;}
        EndIf
        
        If ListIndex(EditEx()\Items()) > EndRow : Break : EndIf
        
      Until NextElement(EditEx()\Items()) = 0

    EndIf 
    
  EndProcedure
  
  Procedure.s GetText_(Split.i=#False)
    Define CursorRow.i, CursorPos.i, Text$
    
    CursorRow = ListIndex(EditEx()\Items())
    CursorPos = EditEx()\Cursor\Pos
    
    PushListPosition(EditEx()\Items())

    ForEach EditEx()\Items()
      If ListIndex(EditEx()\Items()) = ListSize(EditEx()\Items()) - 1
        If Split And ListIndex(EditEx()\Items()) = CursorRow
          Text$ + InsertString(EditEx()\Items()\String, Chr(30), CursorPos+1)
        Else
          Text$ + EditEx()\Items()\String
        EndIf 
      Else
        If Split And ListIndex(EditEx()\Items()) = CursorRow
          Text$ + InsertString(EditEx()\Items()\String, Chr(30), CursorPos+1)
        Else
          Text$ + EditEx()\Items()\String
        EndIf   
      EndIf
    Next

    PopListPosition(EditEx()\Items())
    
    ProcedureReturn Text$
    
  EndProcedure
  
  Procedure   UpdateWordList_()
    Define.i s, ParaCount, ParaPos, HyphPos, Spaces, LastPos
    Define.s Word$, Text$
    NewMap Paragraph.s()
    
    If EditEx()\SpellCheck = #True
      
      ParaCount = 0
  
      ;{ ----- Determine text paragraphs -----
      PushListPosition(EditEx()\Items())
      
      ForEach EditEx()\Items()
        Text$ = EditEx()\Items()\String
        ParaPos = FindString(Text$, #LineBreak$)
        If ParaPos 
          Paragraph(Str(ParaCount)) + Left(Text$, ParaPos)
          ParaCount + 1
          Paragraph(Str(ParaCount)) = Mid(Text$, ParaPos + 1)
        Else
          HyphPos = FindString(Text$, #Hyphen$)
          If HyphPos Or ListIndex(EditEx()\Items()) = ListSize(EditEx()\Items()) - 1
            Paragraph(Str(ParaCount)) + Text$
          Else
            Paragraph(Str(ParaCount)) + Text$ + " "
          EndIf
        EndIf
      Next
    
      PopListPosition(EditEx()\Items())
      ;}
  
      ;{ ----- Determine the words -----
      ForEach Paragraph()
        Paragraph()  = RemoveString(Paragraph(), #Hyphen$)
        Paragraph()  = RemoveString(Paragraph(), #SoftHyphen$)
        Spaces = CountString(Paragraph(), " ")
        For s = 0 To Spaces
          Word$ = GetWord(StringField(Paragraph(), s+1, " "))
          If Word$
            If FindMapElement(Words(), Word$) = #False
              AddMapElement(Words(), Word$)
            EndIf
          EndIf
        Next
      Next ;}
      
    EndIf
    
  EndProcedure

  Procedure   GetFlowText_(*Text.Text_Structure, Flag.i=#False)
    Define.i s, ParaCount, ParaPos, HyphPos, CursorMove, CursorRow, CursorPos, Spaces, LastPos
    Define.s Word$, Text$

    ParaCount = 0
    
    *Text\CursorRow = CursorRow_()
    *Text\CursorPos = EditEx()\Cursor\Pos
    
    ;{ ----- Determine text paragraphs -----
    ClearMap(*Text\Paragraph())
    
    PushListPosition(EditEx()\Items())
    
    CursorPos = *Text\CursorPos
    
    ForEach EditEx()\Items()
      
      Text$ = EditEx()\Items()\String
      
      If ListIndex(EditEx()\Items()) = *Text\CursorRow
        CursorPos + Len(*Text\Paragraph(Str(ParaCount))) ; Letters in front of the line with the cursor
        CursorRow = ParaCount
      EndIf
      
      ParaPos = FindString(Text$, #LineBreak$)
      If ParaPos ;{ Line break found
        *Text\Paragraph(Str(ParaCount)) + Left(Text$, ParaPos)
        ParaCount + 1
        *Text\Paragraph(Str(ParaCount)) = Mid(Text$, ParaPos + 1)
        ;}
      Else       ;{ Add to paragraph
        HyphPos = FindString(Text$, #Hyphen$)
        If HyphPos Or ListIndex(EditEx()\Items()) = ListSize(EditEx()\Items()) - 1
          *Text\Paragraph(Str(ParaCount)) + Text$
        Else
          *Text\Paragraph(Str(ParaCount)) + Text$ + " "
        EndIf
        ;}
      EndIf

    Next
    
    PopListPosition(EditEx()\Items())
    
    *Text\CursorPos = CursorPos
    *Text\CursorRow = CursorRow
    ;Debug "=> "+InsertString(*Text\Paragraph(Str(*Text\CursorRow)), "|", *Text\CursorPos + 1) + " ("+Str(*Text\CursorRow)+"/"+Str(*Text\CursorPos)+")"
    ;}

    ;{ ----- Determine the words -----
    If Flag = #True Or (EditEx()\AutoSpellCheck = #True And EditEx()\SpellCheck = #True)
      
      ForEach *Text\Paragraph()
        Text$  = RemoveString(*Text\Paragraph(), #Hyphen$)
        Text$  = RemoveString(Text$, #SoftHyphen$)
        Spaces = CountString(Text$, " ")
        For s = 0 To Spaces
          Word$ = GetWord(StringField(Text$, s+1, " "))
          If Word$
            If FindMapElement(Words(), Word$) = #False
              AddMapElement(Words(), Word$)
            EndIf
          EndIf
        Next
      Next
      
    EndIf ;}
    
  EndProcedure
  
  ;----------------------------------------------------------------------------- 
  ;-   SpellChecking
  ;-----------------------------------------------------------------------------  
  
  CompilerIf #Enable_SpellChecking
    
    Procedure SpellCheckEndings(Position.i, Word.s, Length.i=4)
      Define.i i, StartPos, Count
      Define.s Pattern$ = LCase(Left(Word, Length))
      NewMap CheckWords.i()
      
      ;{ Search starting position
      StartPos = Position
      While PreviousElement(Dictionary())
        If Left(Dictionary()\Stem, Length) <> Pattern$ : Break : EndIf
        StartPos - 1
      Wend ;}
      
      ;{ Search to end position & expand endings
      If SelectElement(Dictionary(), StartPos)
        Repeat
          If Left(Dictionary()\Stem, Length) <> Pattern$ : Break : EndIf
          CheckWords(Dictionary()\Stem) = Dictionary()\Flag
          If Dictionary()\Endings
            Count = CountString(Dictionary()\Endings, "|") + 1
            For i=1 To Count
              CheckWords(Dictionary()\Stem + StringField(Dictionary()\Endings, i, "|")) = Dictionary()\Flag
            Next
          EndIf
        Until NextElement(Dictionary()) = #False
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
    
    Procedure SpellChecking_(Flag.i = #True)
      Define.s Word$
      
      If Flag : ClearMap(EditEx()\Syntax()) : EndIf
      
      If MapSize(Words()) > 0
        
        ForEach Words()
          
          Word$ = MapKey(Words())
          
          If Words()\checked = #False
            If SpellCheck(Word$) = #False
              Words()\misspelled = #True
            EndIf
            Words()\checked = #True
          EndIf
          
          If Flag And Words()\misspelled = #True
            EditEx()\Syntax(Word$) = EditEx()\Color\SyntaxHighlight
          EndIf
          
        Next
        
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
      
      If ListSize(HyphPattern()) = 0
        Debug "ERROR: Hyphen patterns are required => LoadHyphenationPattern()"
        ProcedureReturn Word
      EndIf
      
      Word    = "_"+Word+"_" ; Mark start and end of word
      LWord   = LCase(Word)  ; Lowercase word
      WordLen = Len(Word)    ; Word length
      
      Dim Hypos.s(WordLen)
      
      ForEach HyphPattern()  ;{ Evaluate pattern
        
        WordIdx = FindString(LWord, HyphPattern()\chars, 1)
        If WordIdx
          
          Digits = 1
          
          For c = 1 To Len(HyphPattern()\pattern)
            
            Char = Mid(HyphPattern()\pattern, c, 1)
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
      
      ProcedureReturn Word
    EndProcedure
    
    Procedure   Hyphenation_()
      Define.i CharW, TextWidth, LastSpaceWidth, MaxTextWidth
      Define.i c, CharPos, StartPos, LastPos, LastSpace, LastHyphen, HyphenPos
      Define.i WordStart, WordEnd, WordLen
      Define.s Char$, Word$, HyphenWord$, Text$
      Define.i p, CursorPos, CursorRow
      Define   Text.Text_Structure
      
      If EditEx()\Hyphenation
        
        GetFlowText_(@Text, #False)

        CursorPos = Text\CursorPos
        
        If FindMapElement(Font(), Str(EditEx()\FontID))
        
          MaxTextWidth = EditEx()\Text\Width
          If MaxTextWidth = #False
            MaxTextWidth = TextAreaWidth_()
          EndIf
          
          ClearList(EditEx()\Items())
          
          For p=0 To MapSize(Text\Paragraph()) - 1 ; Process all text paragraphs
            
            If FindMapElement(Text\Paragraph(), Str(p))
              
              CharPos   = 1
              LastSpace = 1
              StartPos  = 1
              LastPos   = Len(Text\Paragraph())
              
              TextWidth      = EditEx()\Size\Y
              LastSpaceWidth = TextWidth

              Repeat                               ; Get line breaks in this paragraph
                
                Char$ = Mid(Text\Paragraph(), CharPos, 1)
                CharW = Font()\Char(Char$)
                
                Select Char$
                  Case #LineBreak$  ;{ Line break
                    
                    If AddElement(EditEx()\Items())
                      
                      Text$ = Mid(Text\Paragraph(), StartPos, CharPos - StartPos + 1)

                      HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                      If HyphenPos <> 0
                        Text$ = RemoveString(Text$, #Hyphen$)
                        If p = Text\CursorRow And HyphenPos + CharPos < Text\CursorPos : CursorPos - 1 : EndIf
                      EndIf ;}
                      
                      EditEx()\Items()\String = Text$

                      If p < Text\CursorRow ;{ Adjust cursor position
                        CursorRow + 1
                      ElseIf p = Text\CursorRow And StartPos <=  Text\CursorPos + 1
                        CursorPos = Text\CursorPos - StartPos + 1
                      EndIf ;}
                      
                      StartPos = CharPos + 1
                      
                      Break
                    EndIf 
                    
                    Continue ;}
                  Case #SoftHyphen$ ;{ Last soft hyphen (­) before line break
                    If TextWidth + Font()\Char(#Hyphen$) < MaxTextWidth
                      LastSpace = CharPos
                      LastSpaceWidth = TextWidth
                    EndIf ;}
                  Case " "          ;{ Last space before line break
                    If TextWidth < MaxTextWidth ; TextWidth + CharW
                      LastSpace      = CharPos
                      LastSpaceWidth = TextWidth
                    EndIf
                    ;}
                EndSelect
                
                If TextWidth + CharW > MaxTextWidth ;{ Line break necessary
                  
                  WordStart = LastSpace + 1
                  WordEnd   = GetWordEnd(Text\Paragraph(), WordStart)
                  Word$     = Mid(Text\Paragraph(), WordStart, WordEnd - WordStart + 1) 
                  Word$     = RemoveString(Word$, #Hyphen$)
                  
                  If Word$ = " " Or Word$ = ""    ;{ No word to separate available
                    If AddElement(EditEx()\Items())
                      
                      EditEx()\Items()\String = Mid(Text\Paragraph(), StartPos, LastSpace - StartPos)
                      
                      HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                      If HyphenPos <> 0
                        Text$ = RemoveString(Text$, #Hyphen$)
                        If p = Text\CursorRow And HyphenPos + LastSpace < Text\CursorPos : CursorPos - 1 : EndIf
                      EndIf ;}
                      
                      If Mid(Text\Paragraph(), LastSpace, 1) = #SoftHyphen$
                        EditEx()\Items()\String + #Hyphen$
                      EndIf
                      
                      StartPos = LastSpace + 1
                      
                      If p < Text\CursorRow ;{ Adjust cursor position
                        CursorRow + 1
                      ElseIf p = Text\CursorRow And LastSpace < Text\CursorPos
                        CursorRow + 1
                        CursorPos - LastSpace
                      EndIf ;}
                      
                    EndIf ;}
                  Else                            ;{ Check if hyphenation is possible
                    
                    HyphenWord$ = HyphenateWord(Word$, #Hyphen$)
                    WordLen     = 1
                    LastHyphen  = 0
                    
                    For c = 1 To Len(HyphenWord$) ;{ Search separator
                      Char$ = Mid(HyphenWord$, c, 1)
                      CharW = Font()\Char(Char$)
                      If LastSpaceWidth + CharW > MaxTextWidth : Break : EndIf
                      If Char$ = #Hyphen$
                        If LastSpaceWidth + CharW < MaxTextWidth
                          LastHyphen = WordLen
                        EndIf
                      Else
                        WordLen + 1
                        LastSpaceWidth + CharW
                      EndIf ;}
                    Next
                   
                    If LastHyphen = #False        ;{ No hyphenation possible
                      If AddElement(EditEx()\Items())
                        
                        Text$ = Mid(Text\Paragraph(), StartPos, LastSpace - StartPos)
                        
                        HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                        If HyphenPos <> 0
                          Text$ = RemoveString(Text$, #Hyphen$)
                          If p = Text\CursorRow And HyphenPos + LastSpace < Text\CursorPos : CursorPos - 1 : EndIf
                        EndIf ;}
                        
                        EditEx()\Items()\String = Text$
                        
                        If Mid(Text\Paragraph(), LastSpace, 1) = #SoftHyphen$
                          EditEx()\Items()\String + #Hyphen$
                          If p = Text\CursorRow And LastSpace < Text\CursorPos : CursorPos + 1 : EndIf
                        EndIf
                        
                        If p < Text\CursorRow ;{ Adjust cursor position
                          CursorRow + 1
                        ElseIf p = Text\CursorRow
                          If LastSpace < Text\CursorPos + 1
                            CursorRow + 1
                            CursorPos - LastSpace
                          EndIf
                        EndIf ;}
                        
                        StartPos = LastSpace + 1
                        CharPos  = LastSpace + 1
                        
                      EndIf ;}
                    Else                          ;{ Hyphenation
                      If AddElement(EditEx()\Items())
                        CharPos = LastSpace + LastHyphen
                        
                        Text$ = Mid(Text\Paragraph(), StartPos, CharPos - StartPos)
                        
                        If Mid(Text\Paragraph(), CharPos, 1) = #Hyphen$
                          CharPos + 1
                        EndIf
                        
                        HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                        If HyphenPos <> 0
                          Text$ = RemoveString(Text$, #Hyphen$)
                          If p = Text\CursorRow And HyphenPos + CharPos < Text\CursorPos : CursorPos - 1 : EndIf
                        EndIf ;}
                        
                        EditEx()\Items()\String = Text$ + #Hyphen$ 
                        
                        If p < Text\CursorRow ;{ Adjust cursor position
                          CursorRow + 1
                        ElseIf p = Text\CursorRow
                          If StartPos <  Text\CursorPos + 1 : CursorPos = Text\CursorPos - StartPos + 1 : EndIf
                          If CharPos  <= Text\CursorPos + 1 : CursorRow + 1 : EndIf
                        EndIf ;}
                        
                        StartPos  = CharPos
                        TextWidth + CharW
                        
                      EndIf ;}
                    EndIf
                    ;}
                  EndIf
                  
                  ; Reset for the next line
                  LastSpace      = StartPos
                  CharW          = 0
                  TextWidth      = EditEx()\Size\Y
                  LastSpaceWidth = TextWidth
                  ;}
                EndIf  

                CharPos   + 1
                TextWidth + CharW
                
              Until CharPos > LastPos
              
            EndIf
            
            If StartPos < CharPos
              
              If AddElement(EditEx()\Items())
              
                Text$ = Mid(Text\Paragraph(), StartPos, CharPos - StartPos)
                
                HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                If HyphenPos <> 0
                  Text$ = RemoveString(Text$, #Hyphen$)
                  If p = Text\CursorRow And HyphenPos + CharPos < Text\CursorPos + 1 : CursorPos - 1 : EndIf
                EndIf ;}
                
                EditEx()\Items()\String = Text$
                
                If p < Text\CursorRow ;{ Adjust cursor position
                  CursorRow + 1
                ElseIf p = Text\CursorRow 
                  If StartPos <= Text\CursorPos + 1
                    CursorPos = Text\CursorPos - StartPos + 1
                  EndIf
                  If CharPos < Text\CursorPos + 1 : CursorRow + 1 : EndIf
                EndIf ;}

              EndIf
              
            EndIf
            
          Next

          If SelectElement(EditEx()\Items(), CursorRow)
            EditEx()\Cursor\Pos = CursorPos
          EndIf

        EndIf
        
      EndIf
      
    EndProcedure

  CompilerEndIf
  
  Procedure WordWrap_()
    Define.i CharW, TextWidth, MaxTextWidth, LastSpaceWidth
    Define.i CharPos, LastPos, StartPos, LastPos, HyphenPos, LastSpace
    Define.i p, CursorPos, CursorRow
    Define.s Char$, Text$, TruncText$
    Define Text.Text_Structure
    
    If EditEx()\WordWrap
      
      GetFlowText_(@Text, #False)

      CursorPos = Text\CursorPos
      
      If FindMapElement(Font(), Str(EditEx()\FontID))
      
        MaxTextWidth = EditEx()\Text\Width
        If MaxTextWidth = #False
          MaxTextWidth = TextAreaWidth_()
        EndIf
        
        ClearList(EditEx()\Items())
        
        For p=0 To MapSize(Text\Paragraph()) - 1 ; Process all text paragraphs
          
          If FindMapElement(Text\Paragraph(), Str(p))
            
            CharPos   = 1
            LastSpace = 1
            StartPos  = 1
            LastPos   = Len(Text\Paragraph())
            
            TextWidth      = EditEx()\Size\Y
            LastSpaceWidth = TextWidth

            Repeat                               ; Get line breaks in this paragraph
              
              Char$ = Mid(Text\Paragraph(), CharPos, 1)
              CharW = Font()\Char(Char$)
              
              Select Char$
                Case #LineBreak$  ;{ Line break
                  
                  If AddElement(EditEx()\Items())
                    
                    Text$ = Mid(Text\Paragraph(), StartPos, CharPos - StartPos + 1)

                    HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                    If HyphenPos <> 0
                      Text$ = RemoveString(Text$, #Hyphen$)
                      If p = Text\CursorRow And HyphenPos + CharPos < Text\CursorPos : CursorPos - 1 : EndIf
                    EndIf ;}
                    
                    EditEx()\Items()\String = Text$
                    
                    If p < Text\CursorRow ;{ Adjust cursor position
                      CursorRow + 1
                    ElseIf p = Text\CursorRow And StartPos <=  Text\CursorPos + 1
                      CursorPos = Text\CursorPos - StartPos + 1
                    EndIf ;}
                    
                    StartPos = CharPos + 1
                    Break
                    
                  EndIf 
                  
                  Continue ;}
                Case #SoftHyphen$ ;{ Last soft hyphen (­) before line break
                  If TextWidth + Font()\Char(#Hyphen$) < MaxTextWidth
                    LastSpace = CharPos
                    LastSpaceWidth = TextWidth
                  EndIf ;}
                Case " "          ;{ Last space before line break
                  If TextWidth < MaxTextWidth
                    LastSpace      = CharPos
                    LastSpaceWidth = TextWidth
                  EndIf ;}
              EndSelect
              
              If TextWidth + CharW > MaxTextWidth ;{ Line break necessary

                If AddElement(EditEx()\Items())

                  Text$ = Mid(Text\Paragraph(), StartPos, LastSpace - StartPos)
                  
                  HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                  If HyphenPos <> 0
                    Text$ = RemoveString(Text$, #Hyphen$)
                    If p = Text\CursorRow And HyphenPos + LastSpace < Text\CursorPos : CursorPos - 1 : EndIf
                  EndIf ;}
                  
                  EditEx()\Items()\String = Text$
                  
                  If Mid(Text\Paragraph(), LastSpace, 1) = #SoftHyphen$
                    EditEx()\Items()\String + #Hyphen$
                  EndIf
                  
                  If p < Text\CursorRow ;{ Adjust cursor position
                    CursorRow + 1
                  ElseIf p = Text\CursorRow
                    ;Debug " ( "+Str(StartPos)+" / "+Str(LastSpace)+" / "+Str(Text\CursorPos)+" )"
                    If StartPos <= Text\CursorPos + 1
                      CursorPos = Text\CursorPos - StartPos + 1
                    EndIf
                    If LastSpace < Text\CursorPos + 1 : CursorRow + 1 : EndIf
                  EndIf ;}
                  
                  StartPos = LastSpace + 1
                  
                EndIf
            
                ; Reset for the next line
                LastSpace      = StartPos
                CharW          = 0
                TextWidth      = EditEx()\Size\Y
                LastSpaceWidth = TextWidth
              
              EndIf ;}  

              CharPos   + 1
              TextWidth + CharW
              
            Until CharPos > LastPos
            
            If StartPos < CharPos ;{ Remaining text
              If AddElement(EditEx()\Items())
                Text$ = Mid(Text\Paragraph(), StartPos, CharPos - StartPos)
             
                HyphenPos = FindString(Text$, #Hyphen$) ;{ Remove hyphen and adjust cursor position
                If HyphenPos <> 0
                  Text$ = RemoveString(Text$, #Hyphen$)
                  If p = Text\CursorRow And HyphenPos + CharPos < Text\CursorPos : CursorPos - 1 : EndIf
                EndIf ;}
                
                EditEx()\Items()\String = Text$
                ;Debug "3: "+Text$
                If Mid(Text\Paragraph(), CharPos, 1) = #SoftHyphen$
                  EditEx()\Items()\String + #Hyphen$
                EndIf
                
                If p < Text\CursorRow ;{ Adjust cursor position
                  CursorRow + 1
                ElseIf p = Text\CursorRow
                  If StartPos <= Text\CursorPos + 1
                    CursorPos = Text\CursorPos - StartPos + 1
                  EndIf
                  If CharPos < Text\CursorPos + 1 : CursorRow + 1 : EndIf
                EndIf ;}

              EndIf ;}
            EndIf
            
          EndIf
          
        Next

        If SelectElement(EditEx()\Items(), CursorRow)
          EditEx()\Cursor\Pos = CursorPos
        EndIf 
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  ;----------------------------------------------------------------------------- 
  ;-   Undo / Redo
  ;-----------------------------------------------------------------------------
  
  CompilerIf #Enable_UndoRedo
    
    Procedure.s GetCRC32(Text.s) 
      Text = ReplaceString(Text, #LF$, " ")
      ProcedureReturn StringFingerprint(Text, #PB_Cipher_CRC32)
    EndProcedure
    
    Procedure   AddRedo_()
      Define.s Text$
      
      If EditEx()\UndoRedo
        
        Text$ = GetText_()
        
        EditEx()\Undo\Redo\CursorPos = EditEx()\Cursor\Pos
        EditEx()\Undo\Redo\CursorRow = CursorRow_()
        EditEx()\Undo\Redo\Text      = Text$
        
      EndIf
      
    EndProcedure
    
    Procedure.s GetLastRedo_()
      
      If EditEx()\UndoRedo
        
        EditEx()\Undo\CursorPos = EditEx()\Undo\Redo\CursorPos
        EditEx()\Undo\CursorRow = EditEx()\Undo\Redo\CursorRow

        ProcedureReturn EditEx()\Undo\Redo\Text
      EndIf
      
    EndProcedure
    
    Procedure   ClearRedo_()
      
      EditEx()\Undo\Redo\CursorPos = 0
      EditEx()\Undo\Redo\CursorRow = 0
      EditEx()\Undo\Redo\Text      = ""
      
    EndProcedure
    
    Procedure   ChangeUndoCursor_()
      
      If EditEx()\UndoRedo
        
        If LastElement(EditEx()\Undo\Item())
          
          If LastElement(EditEx()\Undo\Item()\DiffText())
            EditEx()\Undo\Item()\DiffText()\CursorPos = EditEx()\Cursor\Pos
            EditEx()\Undo\Item()\DiffText()\CursorRow = CursorRow_()
          Else
            EditEx()\Undo\Item()\CursorPos = EditEx()\Cursor\Pos
            EditEx()\Undo\Item()\CursorRow = CursorRow_()
          EndIf
          
        EndIf
        
      EndIf 

    EndProcedure  
    
    Procedure   AddUndo_()
      Define.i Lenght_1, Lenght_2
      Define.s Text$, SplitText$, Diff$, CRC32_1$, CRC32_2$
      
      If EditEx()\UndoRedo
        
        ;{ MaxSteps
        
        If EditEx()\Undo\MaxSteps And ListSize(EditEx()\Undo\Item()) >= EditEx()\Undo\MaxSteps
          If FirstElement(EditEx()\Undo\Item())
            DeleteElement(EditEx()\Undo\Item())
          EndIf
        EndIf ;}
        
        SplitText$ = GetText_(#True)
        Text$      = RemoveString(SplitText$, Chr(30))
        
        If LastElement(EditEx()\Undo\Item())
          ;{ Compare with last entry
          If Trim(Text$)
            
            If LastElement(EditEx()\Undo\Item()\DiffText())
              Lenght_1 = EditEx()\Undo\Item()\DiffText()\Length
              CRC32_1$ = EditEx()\Undo\Item()\DiffText()\CRC32
            Else
              Lenght_1 = EditEx()\Undo\Item()\Length_1
              CRC32_1$ = EditEx()\Undo\Item()\CRC32_1
            EndIf
            
            Lenght_2 = EditEx()\Undo\Item()\Length_2
            CRC32_2$ = EditEx()\Undo\Item()\CRC32_2
            
            If CRC32_1$ = GetCRC32(Left(Text$, Lenght_1)) And CRC32_2$ = GetCRC32(Right(Text$, Lenght_2))
              ;{ Remember differential text
              Diff$ = Mid(Text$, Lenght_1 + 1, Len(Text$) - Lenght_1 - Lenght_2)
              If Diff$
                If AddElement(EditEx()\Undo\Item()\DiffText())
                  EditEx()\Undo\Item()\DiffText()\CursorPos = EditEx()\Cursor\Pos
                  EditEx()\Undo\Item()\DiffText()\CursorRow = CursorRow_()
                  EditEx()\Undo\Item()\DiffText()\Text      = Diff$
                  EditEx()\Undo\Item()\DiffText()\Length    = Lenght_1 + Len(Diff$)
                  EditEx()\Undo\Item()\DiffText()\CRC32     = GetCRC32(Left(Text$, EditEx()\Undo\Item()\DiffText()\Length))
                EndIf 
              EndIf ;}
            Else
              ;{ Remember full text
              If AddElement(EditEx()\Undo\Item())
                EditEx()\Undo\Item()\CursorPos = EditEx()\Cursor\Pos
                EditEx()\Undo\Item()\CursorRow = CursorRow_()
                EditEx()\Undo\Item()\Text_1    = StringField(SplitText$, 1, Chr(30))
                EditEx()\Undo\Item()\Length_1  = Len(EditEx()\Undo\Item()\Text_1)
                EditEx()\Undo\Item()\CRC32_1   = GetCRC32(EditEx()\Undo\Item()\Text_1)
                EditEx()\Undo\Item()\Text_2    = StringField(SplitText$, 2, Chr(30))
                EditEx()\Undo\Item()\Length_2  = Len(EditEx()\Undo\Item()\Text_2)
                EditEx()\Undo\Item()\CRC32_2   = GetCRC32(EditEx()\Undo\Item()\Text_2)
              EndIf ;}
            EndIf
            
          EndIf
          ;}
        Else
          ;{ First entry
          If Trim(Text$)
            If AddElement(EditEx()\Undo\Item())
              EditEx()\Undo\Item()\CursorPos = EditEx()\Cursor\Pos
              EditEx()\Undo\Item()\CursorRow = CursorRow_()
              EditEx()\Undo\Item()\Text_1    = StringField(SplitText$, 1, Chr(30))
              EditEx()\Undo\Item()\Length_1  = Len(EditEx()\Undo\Item()\Text_1)
              EditEx()\Undo\Item()\CRC32_1   = GetCRC32(EditEx()\Undo\Item()\Text_1)
              EditEx()\Undo\Item()\Text_2    = StringField(SplitText$, 2, Chr(30))
              EditEx()\Undo\Item()\Length_2  = Len(EditEx()\Undo\Item()\Text_2)
              EditEx()\Undo\Item()\CRC32_2   = GetCRC32(EditEx()\Undo\Item()\Text_2)
            EndIf
          EndIf
          ;}
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure.s GetLastUndo_(Redo.i=#False)
      Define.i ListIdx
      Define.s Text1$, Text2$, LastDiff$
      
      If EditEx()\UndoRedo
       
        AddRedo_()
        
        If LastElement(EditEx()\Undo\Item())
          
          Text1$ = EditEx()\Undo\Item()\Text_1
          Text2$ = EditEx()\Undo\Item()\Text_2
          
          If LastElement(EditEx()\Undo\Item()\DiffText()) ; Differential text
            
            EditEx()\Undo\CursorPos = EditEx()\Undo\Item()\DiffText()\CursorPos
            EditEx()\Undo\CursorRow = EditEx()\Undo\Item()\DiffText()\CursorRow
            
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
            EditEx()\Undo\CursorRow = EditEx()\Undo\Item()\CursorRow
            
            If ListSize(EditEx()\Undo\Item()) > 1 : DeleteElement(EditEx()\Undo\Item()) : EndIf
            
            ProcedureReturn Text1$ + Text2$
          EndIf  

        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure   Undo_()
      Define r.i, Text$
    
      Text$ = GetLastUndo_()
      
      If Trim(Text$)
        
        If Trim(GetText_()) = Trim(Text$)
          Text$ = GetLastUndo_()
          If Trim(Text$) = "" : ProcedureReturn #False : EndIf
        EndIf 
        
        ClearList(EditEx()\Items())
        
        For r=0 To CountString(Text$, #LineBreak$)
        
          If AddElement(EditEx()\Items())
            EditEx()\Items()\String = StringField(Text$, r+1, #LineBreak$) + #LineBreak$
          EndIf
          
        Next
        
        If SelectElement(EditEx()\Items(), EditEx()\Undo\CursorRow)
          EditEx()\Cursor\Pos = EditEx()\Undo\CursorPos
        EndIf
        
      EndIf
      
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
  
  Procedure Draw_(GNum.i)
    Define.f X, Y, TextWidth, MaxTextWidth, MaxRowWidth
    Define.i StartX, EndX, StartY, EndY, RowY, StartRow, EndRow, CursorRow, a, r
    Define.i sRow1, sRow2
    Define.s FontID, Text$, Word$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If StartDrawing(CanvasOutput(EditEx()\CanvasNum)) 
        
        If EditEx()\FontID ;{ Drawing Font
        
          DrawingFont(EditEx()\FontID)
        
          If FindMapElement(Font(), Str(EditEx()\FontID)) = #False
            ;{ --- Pixel width of the characters ---
            If AddMapElement(Font(), Str(EditEx()\FontID))
              Font()\Height = TextHeight("Abc")
              For a = 32 To 255
                Font()\Char(Chr(a)) = TextWidth(Chr(a))
              Next
              Font()\Char(#Hyphen$)    = TextWidth(#Hyphen$)
              Font()\Char(#NbSp$)      = TextWidth(#NbSp$)
              Font()\Char(#BlockChar$) = TextWidth(#BlockChar$)
            EndIf
            ;} -------------------------
          EndIf
        
          If EditEx()\Visible\CtrlChars = #True ;{ Control Characters
            Font()\Char(#CR$) = TextWidth(#CR$)
            Font()\Char(#LF$) = TextWidth(#LF$)
            Font()\Char(#LineBreak$)  = TextWidth(#LineBreak$)
            Font()\Char(#SoftHyphen$) = TextWidth(#SoftHyphen$)
          Else
            Font()\Char(#CR$) = 0
            Font()\Char(#LF$) = 0
            Font()\Char(#LineBreak$)  = 0
            Font()\Char(#SoftHyphen$) = 0
            ;}
          EndIf
          
          EditEx()\Text\Space  = Font()\Char(" ")
          ;} 
        EndIf
        
        EditEx()\Text\Height = TextHeight("Abc")
        
        EditEx()\Cursor\FrontColor = EditEx()\Color\Front
        EditEx()\Cursor\BackColor  = EditEx()\Color\Back
        EditEx()\Cursor\BackChar   = ""
        
        ;{ --- Draw Background ---
        DrawingMode(#PB_2DDrawing_Default)
        Box(0, 0, dpiX(GadgetWidth(EditEx()\CanvasNum)), dpiY(GadgetHeight(EditEx()\CanvasNum)), EditEx()\Color\Back)  
        ;} ------------------
        
        If ListSize(EditEx()\Items()) > 0

          ; --- Hyphenation / WordWrap ---
          CompilerIf #Enable_Hyphenation
            
            If EditEx()\Hyphenation
              Hyphenation_()
            ElseIf EditEx()\WordWrap
              WordWrap_()
            Else
              If EditEx()\AutoSpellCheck And EditEx()\SpellCheck
                UpdateWordList_()
              EndIf
            EndIf
            
          CompilerElse
            
            If EditEx()\WordWrap
              WordWrap_()
            Else
              If EditEx()\AutoSpellCheck And EditEx()\SpellCheck
                UpdateWordList_()
              EndIf
            EndIf
            
          CompilerEndIf
          
          ; --- AutoSpellCheck -----
          CompilerIf #Enable_SpellChecking
            
            If EditEx()\AutoSpellCheck And EditEx()\SpellCheck
              SpellChecking_(#True)
              EditEx()\SpellCheck = #False
            EndIf
            
          CompilerEndIf
          
          X = EditEx()\Size\X - EditEx()\Visible\PosOffset
          Y = EditEx()\Size\Y
          
          CursorRow = CursorRow_()
          
          PushListPosition(EditEx()\Items())
          
          ;{ ===== Draw Text =====
          MaxRowWidth = 0
          
          DrawingMode(#PB_2DDrawing_Transparent)

          StartRow = EditEx()\Visible\RowOffset
          EndRow   = GetPageRows_() + EditEx()\Visible\RowOffset

          If SelectElement(EditEx()\Items(), StartRow)

            Repeat
              
              Text$ = EditEx()\Items()\String
              
              If ListIndex(EditEx()\Items()) = EditEx()\Cursor\Row
                If EditEx()\Cursor\Pos < Len(RTrim(Text$, #LineBreak$))
                  EditEx()\Cursor\BackChar = Mid(Text$, EditEx()\Cursor\Pos + 1, 1)
                Else
                  EditEx()\Cursor\BackChar = " "
                EndIf
              EndIf  
                
                If EditEx()\Visible\CtrlChars
                  Text$ = ReplaceString(Text$, #LineBreak$, #Paragraph$)
                Else
                  Text$ = RemoveString(Text$, #SoftHyphen$)
                EndIf
                
                DrawText(X, Y, RTrim(Text$, #LineBreak$), EditEx()\Color\Front)
                
                EditEx()\Items()\Y      = Y
                
              Y + EditEx()\Text\Height

              TextWidth = TextWidth(Text$)
              If TextWidth > MaxRowWidth ;{ Find maximum text width
                MaxRowWidth = TextWidth
                ;} 
              EndIf
              
              If ListIndex(EditEx()\Items()) > EndRow : Break : EndIf
              
            Until NextElement(EditEx()\Items()) = 0

          EndIf
          ;}
          
          ;DrawingMode(#PB_2DDrawing_Outlined)
          ;Box(EditEx()\Size\X, EditEx()\Size\Y, EditEx()\Size\Width, EditEx()\Size\Height, #Blue)
          
          ; --- Syntax Highlightning ---
          CompilerIf #Enable_SyntaxHighlight
            
            If EditEx()\SyntaxHighlight
              
              GetWordXY_() 
              
              DrawingMode(#PB_2DDrawing_Default)
              
              ForEach EditEx()\Syntax()
                
                Word$ = MapKey(EditEx()\Syntax())
                
                If EditEx()\SyntaxHighlight = #NoCase : Word$ = LCase(Word$) :  EndIf
                If EditEx()\Syntax() = #False : EditEx()\Syntax() = EditEx()\Color\SyntaxHighlight : EndIf
                
                If FindMapElement(EditEx()\WordXY(), Word$)
                  ForEach EditEx()\WordXY()\Item()
                    If EditEx()\WordXY()\Item()\Row >= StartRow And EditEx()\WordXY()\Item()\Row <= EndRow
                      RowY = GetY_(EditEx()\WordXY()\Item()\Row - EditEx()\Visible\RowOffset)
                      DrawText(EditEx()\WordXY()\Item()\X + X, RowY, EditEx()\WordXY()\Item()\String, EditEx()\Syntax(), EditEx()\Color\Back)
                      If EditEx()\WordXY()\Item()\Row = EditEx()\Cursor\Row
                        If EditEx()\Cursor\Pos >= EditEx()\WordXY()\Item()\Pos - 1 And EditEx()\Cursor\Pos <= EditEx()\WordXY()\Item()\Pos + Len(EditEx()\WordXY()\Item()\String) - 2
                          EditEx()\Cursor\FrontColor = EditEx()\Syntax()
                          EditEx()\Cursor\BackColor  = EditEx()\Color\Back
                        EndIf
                      EndIf
                    EndIf
                  Next
                EndIf
                
              Next
              
              If EditEx()\Visible\CtrlChars ;{ Control character
                If FindMapElement(EditEx()\WordXY(), #Paragraph$)
                  ForEach EditEx()\WordXY()\Item()
                    If EditEx()\WordXY()\Item()\Row >= StartRow And EditEx()\WordXY()\Item()\Row <= EndRow
                      RowY = GetY_(EditEx()\WordXY()\Item()\Row - EditEx()\Visible\RowOffset)
                      DrawText(EditEx()\WordXY()\Item()\X + X, RowY, EditEx()\WordXY()\Item()\String, EditEx()\Color\Front, EditEx()\Color\Back)
                    EndIf
                  Next
                EndIf ;}
              EndIf
              
            EndIf
            
          CompilerEndIf
          
          If IsSelectedChar(EditEx()\Cursor\Row, EditEx()\Cursor\Pos)
            EditEx()\Cursor\FrontColor = EditEx()\Color\HighlightText
            EditEx()\Cursor\BackColor  = EditEx()\Color\Highlight
          EndIf
          
          ;{ --- Draw Selection ---
          If EditEx()\Selection\Flag = #Selected
            DrawingMode(#PB_2DDrawing_Default)
            
            If EditEx()\Selection\Row1 = EditEx()\Selection\Row2 ;{ Single Row

              If SelectElement(EditEx()\Items(), EditEx()\Selection\Row1)
                
                Text$  = EditEx()\Items()\String
                StartY = CursorY_(EditEx()\Selection\Row1)
                
                If EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
                  StartX = CursorX_(EditEx()\Selection\Row1, EditEx()\Selection\Pos2)
                  Text$  = StringSegment(Text$, EditEx()\Selection\Pos2, EditEx()\Selection\Pos1)
                Else
                  StartX = CursorX_(EditEx()\Selection\Row1, EditEx()\Selection\Pos1)
                  Text$  = StringSegment(Text$, EditEx()\Selection\Pos1, EditEx()\Selection\Pos2)
                EndIf
                Text$  = ReplaceString(Text$, #LineBreak$, #NbSp$)
                DrawText(StartX, StartY, Text$, EditEx()\Color\HighlightText, EditEx()\Color\Highlight)
                
              EndIf
              ;}
            Else                                                 ;{ Multiple rows
              
              If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                sRow1 = EditEx()\Selection\Row2
                sRow2 = EditEx()\Selection\Row1
              Else
                sRow1 = EditEx()\Selection\Row1
                sRow2 = EditEx()\Selection\Row2
              EndIf
              
              For r = sRow1 To sRow2
                If SelectElement(EditEx()\Items(), r)
                  Text$  = EditEx()\Items()\String
                  StartY = CursorY_(r)
                  Select r
                    Case sRow1
                      If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                        StartX = CursorX_(sRow1, EditEx()\Selection\Pos2)
                        Text$  = StringSegment(Text$, EditEx()\Selection\Pos2, #PB_Ignore)
                      Else
                        StartX = CursorX_(sRow1, EditEx()\Selection\Pos1)
                        Text$  = StringSegment(Text$, EditEx()\Selection\Pos1, #PB_Ignore)
                      EndIf
                      Text$  = RTrim(Text$, #LineBreak$)
                      DrawText(StartX, StartY, Text$, EditEx()\Color\HighlightText, EditEx()\Color\Highlight)
                    Case sRow2
                      If EditEx()\Selection\Row1 > EditEx()\Selection\Row2
                        Text$ = StringSegment(Text$, 0, EditEx()\Selection\Pos1)
                      Else
                        Text$ = StringSegment(Text$, 0, EditEx()\Selection\Pos2)
                      EndIf  
                      Text$  = RTrim(Text$, #LineBreak$)
                      DrawText(X, StartY, Text$, EditEx()\Color\HighlightText, EditEx()\Color\Highlight)
                    Default
                      Text$  = RTrim(Text$, #LineBreak$)
                      DrawText(X, StartY, Text$, EditEx()\Color\HighlightText, EditEx()\Color\Highlight)
                  EndSelect
                EndIf
              Next ;}
            EndIf            
            
          EndIf
          ;} ----------------------
          
          PopListPosition(EditEx()\Items())
          
          EditEx()\Text\Rows      = ListSize(EditEx()\Items())
          EditEx()\Text\RowOffset = EditEx()\Visible\RowOffset
          EditEx()\Text\PosOffset = EditEx()\Visible\PosOffset

          ;{ --- Draw Cursor ---
          EditEx()\Cursor\Y = CursorY_()
          EditEx()\Cursor\X = CursorX_()
          EditEx()\Cursor\Height = EditEx()\Text\Height
          If EditEx()\Cursor\X < EditEx()\Size\X And EditEx()\Visible\PosOffset = 0 : EditEx()\Cursor\X = EditEx()\Size\X : EndIf

          If EditEx()\Cursor\State
            Line(EditEx()\Cursor\X, EditEx()\Cursor\Y, dpiX(1), EditEx()\Cursor\Height, EditEx()\Color\Cursor)
          Else
            DrawText(EditEx()\Cursor\X, EditEx()\Cursor\Y, EditEx()\Cursor\BackChar, EditEx()\Cursor\FrontColor, EditEx()\Cursor\BackColor)
          EndIf
          ;}
          
          ;{ --- Maximum text width ---
          If MaxRowWidth <> EditEx()\Text\MaxRowWidth
            EditEx()\Text\MaxRowWidth = MaxRowWidth
          EndIf ;}
          
          ;{ --- Draw text-free borders ---
          DrawingMode(#PB_2DDrawing_Default)
          
          If EditEx()\VScroll\Hide
            Box(dpiX(GadgetWidth(EditEx()\CanvasNum) - 4), 0, dpiX(4), dpiY(GadgetHeight(EditEx()\CanvasNum)), EditEx()\Color\Back)
          Else
            Box(EditEx()\Size\Width + dpiX(6), 0, dpiX(2), dpiY(GadgetHeight(EditEx()\CanvasNum)), EditEx()\Color\Back)
          EndIf
          
          If EditEx()\HScroll\Hide
            Box(0, dpiX(GadgetHeight(EditEx()\CanvasNum) - 2), dpiY(GadgetWidth(EditEx()\CanvasNum)), dpiY(2), EditEx()\Color\Back)
          Else
            Box(0, EditEx()\Size\Height + dpiY(2), EditEx()\Size\Width + dpiX(6), dpiY(2), EditEx()\Color\Back)
          EndIf
          
          Box(0, 0, dpiX(4), dpiY(GadgetHeight(EditEx()\CanvasNum)), EditEx()\Color\Back)
          ;}
         
          ;{ --- Both ScrollBars ---
          DrawingMode(#PB_2DDrawing_Default)
          
          If EditEx()\VScroll\Hide = #False
            Box(dpiX(GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 1), dpiY(2), dpiX(#Scroll_Width), dpiY(GadgetHeight(EditEx()\CanvasNum) - 2), EditEx()\Color\ScrollBar)
          EndIf
       
          If EditEx()\HScroll\Hide = #False
            Box(dpiX(2), dpiY(GadgetHeight(EditEx()\CanvasNum) - #Scroll_Width - 1), dpiX(GadgetWidth(EditEx()\CanvasNum) - 2), dpiY(#Scroll_Width + 1), EditEx()\Color\ScrollBar)
          EndIf
          ;}

        EndIf  
        
        ;{ _____ Border ____
        If EditEx()\Flags & #Borderless = #False
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(1, 1, dpiX(GadgetWidth(EditEx()\CanvasNum)) - 2, dpiY(GadgetHeight(EditEx()\CanvasNum)) - 2, EditEx()\Color\Back)
          Box(0, 0, dpiX(GadgetWidth(EditEx()\CanvasNum)), dpiY(GadgetHeight(EditEx()\CanvasNum)), EditEx()\Color\Border)
        EndIf ;}
        
        AdjustScrolls_(#False)
        
        StopDrawing()

      EndIf
      
    EndIf

  EndProcedure
  
  ;- __________ Events __________
  
  ; --- Cursor-Handler ---  
  
  Procedure _CursorDrawing()
    Define.i WindowNum = EventWindow()
    Define.i GadgetNum = EventGadget()
    
    If EditEx()\Window\Num = WindowNum
      
      PushMapPosition(EditEx())
      
      If FindMapElement(EditEx(), Str(GadgetNum))
        
        If EditEx()\Cursor\Pause = #False
          
          EditEx()\Cursor\State ! #True
          
          If StartDrawing(CanvasOutput(EditEx()\CanvasNum))
            If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf 
            DrawingMode(#PB_2DDrawing_Default)
            If EditEx()\Cursor\State
              Line(EditEx()\Cursor\X, EditEx()\Cursor\Y, dpiX(1), EditEx()\Cursor\Height, EditEx()\Color\Cursor)
            Else
              DrawText(EditEx()\Cursor\X, EditEx()\Cursor\Y, EditEx()\Cursor\BackChar, EditEx()\Cursor\FrontColor, EditEx()\Cursor\BackColor)
              If EditEx()\VScroll\Hide
                Box(dpiX(GadgetWidth(EditEx()\CanvasNum) - 4), dpiY(2), dpiX(4), EditEx()\Size\Height + dpiY(3), EditEx()\Cursor\BackColor)
                Line(dpiX(GadgetWidth(EditEx()\CanvasNum) - 1), 0, dpiX(1), dpiY(GadgetHeight(EditEx()\CanvasNum)), EditEx()\Color\Border)
              Else
                Box(dpiX(GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 2), dpiY(2), dpiX(2), EditEx()\Size\Height + dpiY(3), EditEx()\Cursor\BackColor)
              EndIf  
            EndIf
            StopDrawing()
          EndIf
          
        ElseIf EditEx()\Cursor\State
          
          If StartDrawing(CanvasOutput(EditEx()\CanvasNum))
            If EditEx()\FontID : DrawingFont(EditEx()\FontID) : EndIf 
            DrawingMode(#PB_2DDrawing_Default)
            DrawText(EditEx()\Cursor\X, EditEx()\Cursor\Y, EditEx()\Cursor\BackChar, EditEx()\Cursor\FrontColor, EditEx()\Cursor\BackColor)
            If EditEx()\VScroll\Hide
              Box(dpiX(GadgetWidth(EditEx()\CanvasNum)  - 4), dpiY(2), dpiX(4), dpiY(GadgetHeight(EditEx()\CanvasNum) - 2), EditEx()\Cursor\BackColor)
              Line(dpiX(GadgetWidth(EditEx()\CanvasNum) - 1), 0, dpiX(2), dpiY(GadgetHeight(EditEx()\CanvasNum)), EditEx()\Color\Border)
            Else
              Box(dpiX(GadgetWidth(EditEx()\CanvasNum) - #Scroll_Width - 2), dpiY(2), dpiX(2), EditEx()\Size\Height + dpiY(3), EditEx()\Cursor\BackColor)
            EndIf
            StopDrawing()
          EndIf
          
        EndIf
        
      EndIf
      
      PopMapPosition(EditEx())
      
    EndIf
    
  EndProcedure
  
  Procedure _CursorThread(Frequency.i)
    Define.i ElapsedTime
    
    Repeat
      
      If ElapsedTime >= Frequency
        
        PushMapPosition(EditEx())
        
        ForEach EditEx()
          If IsGadget(EditEx()\CanvasNum)
            If EditEx()\Cursor\Pause = #False Or EditEx()\Cursor\State = #True
              PostEvent(#Event_Cursor, EditEx()\Window\Num, EditEx()\CanvasNum)
            EndIf
          EndIf
        Next
        
        PopMapPosition(EditEx())
        
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
      ;_CursorDrawing()
      
    EndIf  
 
  EndProcedure
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      EditEx()\Cursor\Pause = #True
      _CursorDrawing()
      
    EndIf
    
  EndProcedure  
  
  
  Procedure _KeyDownHandler()
    Define.i GNum = EventGadget()
    Define.i Key, Modifier, Row, Rows, CursorRow, CursorPos
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
      Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
      
      CursorPos = EditEx()\Cursor\Pos
      CursorRow = EditEx()\Cursor\Row
      
      Select Key
        Case #PB_Shortcut_Left     ;{ Left
          If Modifier & #PB_Canvas_Shift       ;{ Selection left
            
            If CursorPos 
              EditEx()\Cursor\Pos - 1
            Else
              If PreviousElement(EditEx()\Items())
                EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EndIf  
            EndIf 
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Row1 = CursorRow
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control ;{ Start of word
            EditEx()\Cursor\Pos = GetWordStart(EditEx()\Items()\String, CursorPos)
            If EditEx()\Selection\Flag = #Selected
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          Else                                 ;{ Cursor left
            If CursorPos
              EditEx()\Cursor\Pos - 1
            Else
              If PreviousElement(EditEx()\Items())
                EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EndIf  
            EndIf 
            RemoveSelection_() ;}
          EndIf 
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_Right    ;{ Right
          If Modifier & #PB_Canvas_Shift       ;{ Selection right
            If CursorPos < Len(RTrim(EditEx()\Items()\String, #LineBreak$))
              EditEx()\Cursor\Pos + 1
            Else
              If NextElement(EditEx()\Items())
                EditEx()\Cursor\Pos = 0
                EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EndIf  
            EndIf
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Row1 = CursorRow
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control ;{ End of word
            EditEx()\Cursor\Pos = GetWordEnd(EditEx()\Items()\String, CursorPos)
            ; EditEx()\Cursor\Pos = GetNextSpace(EditEx()\Items()\String, CursorPos)
            If EditEx()\Selection\Flag = #Selected
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
            ;}
          Else                                 ;{ Cursor right
            If CursorPos < Len(RTrim(EditEx()\Items()\String, #LineBreak$))
              EditEx()\Cursor\Pos + 1
            Else
              If NextElement(EditEx()\Items())
                EditEx()\Cursor\Pos = 0
                EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EndIf  
            EndIf
            RemoveSelection_() ;}
          EndIf
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_Up       ;{ Up
          If Modifier & #PB_Canvas_Shift       ;{ Selection up
            
            If PreviousElement(EditEx()\Items())
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EditEx()\Cursor\Pos = CursorPos_(EditEx()\Cursor\Row, EditEx()\Cursor\X)
            EndIf
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Row1 = CursorRow
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control ;{ Previous paragraph
            
            Row = GetPrevParagraph_(CursorRow)
            If SelectElement(EditEx()\Items(), Row)
              EditEx()\Cursor\Pos = 0
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf
            
            RemoveSelection_() 
            ;}
          Else                                 ;{ Cursor  up
            
            If PreviousElement(EditEx()\Items())
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EditEx()\Cursor\Pos = CursorPos_(EditEx()\Cursor\Row, EditEx()\Cursor\X)
            EndIf

            RemoveSelection_() ;}
          EndIf
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_Down     ;{ Down
          If Modifier & #PB_Canvas_Shift       ;{ Selection down
            
            If NextElement(EditEx()\Items())
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EditEx()\Cursor\Pos = CursorPos_(EditEx()\Cursor\Row, EditEx()\Cursor\X)
            EndIf
            
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Row1 = CursorRow
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
            EndIf
            ;}
          ElseIf Modifier & #PB_Canvas_Control ;{ Next paragraph
            
            Row = GetNextParagraph_(CursorRow)
            If SelectElement(EditEx()\Items(), Row)
              EditEx()\Cursor\Pos = 0
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf
            
            RemoveSelection_() ;}
          Else                                 ;{ Cursor down
            If NextElement(EditEx()\Items())
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
              EditEx()\Cursor\Pos = CursorPos_(EditEx()\Cursor\Row, EditEx()\Cursor\X)
            EndIf
            RemoveSelection_() ;}
          EndIf
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_PageUp   ;{ PageUp
          Rows = GetPageRows_() + 1
          If CursorRow - Rows >= 0
            If SelectElement(EditEx()\Items(), CursorRow - Rows)
              EditEx()\Cursor\Pos = CursorPos_(CursorRow - Rows, EditEx()\Cursor\X)
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf
          Else
            If FirstElement(EditEx()\Items())
              EditEx()\Cursor\Pos = CursorPos_(0, EditEx()\Cursor\X)
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf
          EndIf
          RemoveSelection_() 
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_PageDown ;{ PageDown
          Rows = GetPageRows_() + 1
          If CursorRow + Rows <= LastRow_()
            If SelectElement(EditEx()\Items(), CursorRow + Rows)
              EditEx()\Cursor\Pos = CursorPos_(CursorRow + Rows, EditEx()\Cursor\X)
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf
          Else
            If LastElement(EditEx()\Items())
              EditEx()\Cursor\Pos = CursorPos_(LastRow_(), EditEx()\Cursor\X)
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf
          EndIf
          RemoveSelection_()
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_Home     ;{ Home/Pos1
          If Modifier & #PB_Canvas_Control
            If FirstElement(EditEx()\Items())
              EditEx()\Cursor\Pos = 0
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf
            RemoveSelection_()
          ElseIf Modifier & #PB_Canvas_Shift
            EditEx()\Cursor\Pos = 0
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Row1 = CursorRow
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
            EndIf
          Else
            EditEx()\Cursor\Pos = 0
            RemoveSelection_()
          EndIf 
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_End      ;{ End
          If Modifier & #PB_Canvas_Control
            If LastElement(EditEx()\Items())
              EditEx()\Cursor\Pos = Len(RTrim(EditEx()\Items()\String, #LineBreak$))
              EditEx()\Cursor\Row = ListIndex(EditEx()\Items())
            EndIf 
            RemoveSelection_()
          ElseIf Modifier & #PB_Canvas_Shift
            EditEx()\Cursor\Pos = Len(RTrim(EditEx()\Items()\String, #LineBreak$))
            If EditEx()\Selection\Flag = #NoSelection
              EditEx()\Selection\Pos1 = CursorPos
              EditEx()\Selection\Row1 = CursorRow
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
              EditEx()\Selection\Flag = #Selected
            Else
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
              EditEx()\Selection\Row2 = EditEx()\Cursor\Row
            EndIf
          Else
            EditEx()\Cursor\Pos = Len(RTrim(EditEx()\Items()\String, #LineBreak$))
            RemoveSelection_()
          EndIf
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_Return   ;{ Return
          If EditEx()\ReadOnly = #False
            
            Text$ = EditEx()\Items()\String
            If CursorPos > 0
              
              EditEx()\Items()\String = Left(Text$, CursorPos)
              If CursorRow_() <= LastRow_()
                EditEx()\Items()\String = RTrim(EditEx()\Items()\String, #LineBreak$) + #LineBreak$
              EndIf
              If AddElement(EditEx()\Items())
                EditEx()\Items()\String = LTrim(Mid(Text$, CursorPos + 1))
              EndIf
              
            Else
              
              EditEx()\Items()\String = #LineBreak$
              If AddElement(EditEx()\Items())
                EditEx()\Items()\String = Text$
              EndIf
              
            EndIf
            
            EditEx()\Cursor\Pos    = 0
            EditEx()\Cursor\Row    = ListIndex(EditEx()\Items())
            EditEx()\Text\Complete = #True
            
            RemoveSelection_()
            
            CompilerIf #Enable_SpellChecking
              EditEx()\SpellCheck = #True
            CompilerEndIf 
            CompilerIf #Enable_UndoRedo
              AddUndo_()
            CompilerEndIf

            UpdateScrollBar_()
          EndIf ;}
        Case #PB_Shortcut_Delete   ;{ Delete / Cut (Shift)
          If EditEx()\ReadOnly = #False
            If Modifier & #PB_Canvas_Shift ;{ Cut selected text
              If EditEx()\Selection\Flag = #Selected
                Text$ = GetSelection_(#False)
                DeleteSelection_(#False)
                SetClipboardText(Text$)
                EditEx()\Text\Complete = #True
              EndIf
              ;}
            Else
              If EditEx()\Selection\Flag = #Selected And EditEx()\Cursor\Pos = EditEx()\Selection\Pos2 And EditEx()\Selection\Pos1 > EditEx()\Selection\Pos2
                DeleteSelection_(#False)
                EditEx()\Text\Complete = #True
                EditEx()\Cursor\Pos = EditEx()\Selection\Pos2
              Else                                   ;{ Delete character
                If EditEx()\Cursor\Pos >= Len(RTrim(EditEx()\Items()\String, #LineBreak$))
                  If EditEx()\WordWrap Or EditEx()\Hyphenation
                    EditEx()\Items()\String = RTrim(EditEx()\Items()\String, #LineBreak$)
                    EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                  Else
                    If NextElement(EditEx()\Items())
                      Text$ = EditEx()\Items()\String
                      If DeleteElement(EditEx()\Items())
                        EditEx()\Items()\String = RTrim(EditEx()\Items()\String, #LineBreak$)
                        EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                        EditEx()\Items()\String = EditEx()\Items()\String + Text$
                      EndIf
                    EndIf  
                  EndIf
                  EditEx()\Text\Complete = #True
                Else
                  EditEx()\Items()\String = DeleteStringPart(EditEx()\Items()\String, EditEx()\Cursor\Pos + 1)
                EndIf
                ;}
              EndIf
            EndIf
            RemoveSelection_()
            UpdateScrollBar_()
          EndIf ;}
        Case #PB_Shortcut_Back     ;{ Back
          If EditEx()\ReadOnly = #False
            If EditEx()\Selection\Flag = #Selected And EditEx()\Cursor\Pos = EditEx()\Selection\Pos2 And EditEx()\Selection\Pos1 < EditEx()\Selection\Pos2
              DeleteSelection_(#False)
              EditEx()\Cursor\Pos = EditEx()\Selection\Pos1
              EditEx()\Text\Complete = #True
            Else
              If EditEx()\Cursor\Pos = 0
                If CursorRow > 0
                  If EditEx()\WordWrap Or EditEx()\Hyphenation
                    If PreviousElement(EditEx()\Items())
                      Select Right(EditEx()\Items()\String, 1)
                        Case #Hyphen$
                          EditEx()\Cursor\Pos = Len(RTrim(EditEx()\Items()\String, #Hyphen$))
                        Case #LineBreak$
                          EditEx()\Items()\String = RTrim(EditEx()\Items()\String, #LineBreak$)
                          EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                        Default
                          EditEx()\Items()\String = Left(EditEx()\Items()\String, Len(EditEx()\Items()\String) - 1)
                          EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                      EndSelect
                    EndIf
                  Else
                    Text$ = EditEx()\Items()\String
                    If DeleteElement(EditEx()\Items())
                      If Right(EditEx()\Items()\String, 1)
                        EditEx()\Items()\String = RTrim(EditEx()\Items()\String, #LineBreak$) + " "
                        EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                      Else
                        EditEx()\Items()\String = Left(EditEx()\Items()\String, Len(EditEx()\Items()\String) - 1)
                        EditEx()\Cursor\Pos = Len(EditEx()\Items()\String)
                      EndIf
                      EditEx()\Items()\String + Text$
                    EndIf
                  EndIf
                  EditEx()\Text\Complete = #True 
                EndIf
              Else
                EditEx()\Items()\String = DeleteStringPart(EditEx()\Items()\String, EditEx()\Cursor\Pos)
                EditEx()\Cursor\Pos = EditEx()\Cursor\Pos - 1
              EndIf
            EndIf
            RemoveSelection_()
            UpdateScrollBar_()
          EndIf;}
        Case #PB_Shortcut_C        ;{ Copy  (Ctrl)
          If Modifier & #PB_Canvas_Control
            If EditEx()\Selection\Flag = #Selected
              Text$ = GetSelection_()
              SetClipboardText(Text$)
            EndIf
          EndIf ;}
        Case #PB_Shortcut_V        ;{ Paste (Ctrl)
          If EditEx()\ReadOnly = #False
            If Modifier & #PB_Canvas_Control
              Text$ = GetClipboardText()
              If EditEx()\Selection\Flag = #Selected
                DeleteSelection_(#False)
              EndIf
              EditEx()\Items()\String = InsertString(EditEx()\Items()\String, Text$, EditEx()\Cursor\Pos + 1)
              EditEx()\Cursor\Pos + Len(Text$)
              CompilerIf #Enable_UndoRedo
                AddUndo_()
              CompilerEndIf
              EditEx()\Text\Complete = #True 
              UpdateScrollBar_()
            EndIf 
          EndIf;}
        Case #PB_Shortcut_X        ;{ Cut   (Ctrl)
          If EditEx()\ReadOnly = #False
            If Modifier & #PB_Canvas_Control
              If EditEx()\Selection\Flag = #Selected
                Text$ = GetSelection_(#False)
                DeleteSelection_(#False)
                SetClipboardText(Text$)
                CompilerIf #Enable_UndoRedo
                  AddUndo_()
                CompilerEndIf
                EditEx()\Text\Complete = #True 
              EndIf
              RemoveSelection_()
              UpdateScrollBar_()
            EndIf 
          EndIf ;}
        Case #PB_Shortcut_Insert   ;{ Copy  (Ctrl) / Paste (Shift)
          If EditEx()\ReadOnly = #False
            If Modifier & #PB_Canvas_Shift
              Text$ = GetClipboardText()
              If EditEx()\Selection\Flag = #Selected
                DeleteSelection_(#False)
              EndIf
              EditEx()\Items()\String = InsertString(EditEx()\Items()\String, Text$, EditEx()\Cursor\Pos + 1)
              EditEx()\Cursor\Pos + Len(Text$)
              EditEx()\Text\Complete = #True 
              CompilerIf #Enable_UndoRedo
                AddUndo_()
              CompilerEndIf
              EditEx()\Text\Complete = #True 
            ElseIf Modifier & #PB_Canvas_Control
              If EditEx()\Selection\Flag = #Selected
                Text$ = GetSelection_()
                SetClipboardText(Text$)
              EndIf
            EndIf
          EndIf 
          UpdateScrollBar_() ;}
        Case #PB_Shortcut_Hyphen   ;{ Minus (Ctrl)           
          If Modifier & #PB_Canvas_Control
            EditEx()\Cursor\Pos + 1
            EditEx()\Items()\String = InsertString(EditEx()\Items()\String, #SoftHyphen$, EditEx()\Cursor\Pos)
          EndIf ;}
        Case #PB_Shortcut_A        ;{ Ctrl-A (Select all)
          If Modifier & #PB_Canvas_Control
            If LastElement(EditEx()\Items())
              EditEx()\Cursor\Pos = Len(RTrim(EditEx()\Items()\String, #LineBreak$))
              EditEx()\Selection\Flag = #Selected
              EditEx()\Selection\Row1 = 0
              EditEx()\Selection\Row2 = LastRow_()
              EditEx()\Selection\Pos1 = 1
              EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
            EndIf
          EndIf ;}
        Case #PB_Shortcut_Z        ;{ Crtl-Z (Undo)
          CompilerIf #Enable_UndoRedo
            If Modifier & #PB_Canvas_Control
              Undo_()
            EndIf 
            UpdateScrollBar_() ;}
          CompilerEndIf
        Case #PB_Shortcut_D        ;{ Ctrl-D (Delete selection)
          If Modifier & #PB_Canvas_Control
            DeleteSelection_()
            UpdateScrollBar_()
          EndIf ;}
      EndSelect

      UpdateScrollBar_()
      
      Draw_(GNum)
      
      AdjustScrolls_()
      
    EndIf
    
  EndProcedure
  
  Procedure _InputHandler()
    Define.i GNum = EventGadget()
    Define   Char.i
    
    If EditEx()\ReadOnly = #False
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If ListSize(EditEx()\Items()) = 0 ;{ Add first row
          AddElement(EditEx()\Items())
          EditEx()\Cursor\Pos = 0
        EndIf ;}
        
        If ListIndex(EditEx()\Items()) = #NoElement : LastElement(EditEx()\Items()) : EndIf
       
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
        
        DeleteSelection_(#False)
        
        EditEx()\Cursor\Pos + 1
        
        EditEx()\Items()\String = InsertString(EditEx()\Items()\String, Chr(Char), EditEx()\Cursor\Pos)
        
        RemoveSelection_()
        
        CompilerIf #Enable_UndoRedo
          
          Select Char
            Case 32, 33, 58, 59, 63
              AddUndo_()
          EndSelect
          
        CompilerEndIf
        
        CompilerIf #Enable_SpellChecking
          If EditEx()\AutoSpellCheck
            Select Char
              Case 32, 33, 41, 44, 46
                EditEx()\SpellCheck = #True
              Case 58, 59, 63, 93, 125
                EditEx()\SpellCheck = #True
            EndSelect
          EndIf
          
        CompilerEndIf
        
        Draw_(GNum)
        
      EndIf
      
    EndIf
    
  EndProcedure 
  
  ; --- Scrollbar ---
  
  Procedure _SynchronizeScrollPos()
    Define.i ScrollID = EventGadget()
    Define.i GNum = GetGadgetData(ScrollID)
    Define.i ScrollPos, OffSet
    
    If FindMapElement(EditEx(), Str(GNum))
      
      ScrollPos = GetGadgetState(ScrollID)
      If ScrollPos <> EditEx()\HScroll\Position
        
        If ScrollPos < EditEx()\Visible\PosOffset
          EditEx()\Visible\PosOffset = ScrollPos - EditEx()\Text\Space * 3
        ElseIf ScrollPos > EditEx()\Visible\PosOffset
          EditEx()\Visible\PosOffset = ScrollPos + EditEx()\Text\Space * 3
        EndIf
        
        If EditEx()\Visible\PosOffset < EditEx()\HScroll\MinPos : EditEx()\Visible\PosOffset = EditEx()\HScroll\MinPos : EndIf
        If EditEx()\Visible\PosOffset > EditEx()\HScroll\MaxPos : EditEx()\Visible\PosOffset = EditEx()\HScroll\MaxPos : EndIf
        
        SetGadgetState(ScrollID, EditEx()\Visible\PosOffset)
        
        SetHScrollPosition_()
        Draw_(GNum)
      EndIf
      
    EndIf
    
  EndProcedure
 
  Procedure _SynchronizeScrollRows()
    Define.i ScrollID = EventGadget()
    Define.i GNum = GetGadgetData(ScrollID)
    Define   ScrollPos.i, OffSet.i, Calc.f
    
    If FindMapElement(EditEx(), Str(GNum))
      
      ScrollPos = GetGadgetState(ScrollID)
      If ScrollPos <> EditEx()\VScroll\Position
        EditEx()\Visible\RowOffset = ScrollPos
        SetVScrollPosition_()
        Draw_(GNum)
      EndIf
      
    EndIf
    
  EndProcedure 
  
  ; --- Mouse-Handler ---
  
  Procedure _RightClickHandler()
    Define.i GNum = EventGadget()
    Define.i X, Y
    
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If ListSize(EditEx()\Items()) = #False : ProcedureReturn #False : EndIf
      
      If IsMenu(EditEx()\PopupMenu)

        X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
        Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
        
        If IsTextArea_(X, Y)
          DisplayPopupMenu(EditEx()\PopupMenu, WindowID(EditEx()\Window\Num))
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonDownHandler()
    Define.i GNum = EventGadget()
    Define.i CursorX, CursorY, CursorRow
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If ListSize(EditEx()\Items()) = #False : ProcedureReturn #False : EndIf
      
      CursorX   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      CursorY   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      CursorRow = GetRow_(CursorY)

      If SelectElement(EditEx()\Items(), CursorRow)
        
        EditEx()\Cursor\Pos   = CursorPos_(CursorRow, CursorX)
        EditEx()\Cursor\Row   = CursorRow
        EditEx()\Cursor\LastX = CursorX_(CursorRow, EditEx()\Cursor\Pos)
        
        CompilerIf #Enable_UndoRedo
          ChangeUndoCursor_()
        CompilerEndIf
        
        RemoveSelection_()
        
        Delay(50)
        
        Draw_(GNum)
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonUpHandler()
    Define.i GNum = EventGadget()
    Define.i CursorX, CursorY, CursorRow
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If ListSize(EditEx()\Items()) = #False : ProcedureReturn #False : EndIf
      
      CursorX   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      CursorY   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      CursorRow = GetRow_(CursorY)
      
      If CursorRow <> CursorRow_() ;{ Button up in a another row
        If SelectElement(EditEx()\Items(), CursorRow)
          EditEx()\Cursor\Pos = CursorPos_(CursorRow, CursorX)
          EditEx()\Cursor\Row = CursorRow
          EditEx()\Cursor\LastX = CursorX_(CursorRow, EditEx()\Cursor\Pos)
        EndIf
      EndIf ;}
      
      If EditEx()\Mouse\Status = #Mouse_Select
        EditEx()\Selection\Pos2 = CursorPos_(CursorRow, CursorX)
        EditEx()\Selection\Row2 = CursorRow
        EditEx()\Mouse\Status = #Mouse_Move
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure _LeftDoubleClickHandler()
    Define.i GNum = EventGadget()
    Define.i CursorX, CursorY, CursorRow, CursorPos
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If ListSize(EditEx()\Items()) = #False : ProcedureReturn #False : EndIf
      
      If ListIndex(EditEx()\Items()) >= 0
        
        Text$ = EditEx()\Items()\String
        
        CursorX   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
        CursorY   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
        CursorRow = GetRow_(CursorY)
        CursorPos = CursorPos_(CursorRow, CursorX)
        
        If Mid(Text$ , CursorPos, 1) = " "
          EditEx()\Selection\Row1    = CursorRow
          EditEx()\Selection\Pos1    = GetSpaceStart(Text$, CursorPos)
          EditEx()\Selection\Row2    = CursorRow
          EditEx()\Selection\Pos2    = GetSpaceEnd(Text$, CursorPos)
        Else
          EditEx()\Selection\Row1    = CursorRow
          EditEx()\Selection\Pos1    = GetWordStart(Text$, CursorPos)
          EditEx()\Selection\Row2    = CursorRow
          EditEx()\Selection\Pos2    = GetWordEnd(Text$, CursorPos)
        EndIf  
      
        If EditEx()\Selection\Pos1 <> EditEx()\Selection\Pos2
          EditEx()\Selection\Flag = #Selected
          EditEx()\Cursor\Pos = EditEx()\Selection\Pos2
          Draw_(GNum)
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseMoveHandler()
    Define.i GNum = EventGadget()
    Define.i CursorPos, CursorX, CursorY, CursorRow, Flag, Result
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If ListSize(EditEx()\Items()) = #False : ProcedureReturn #False : EndIf
      
      CursorX   = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      CursorY   = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      CursorRow = GetRow_(CursorY)
      
      If GetGadgetAttribute(GNum, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton ;{ Left Mouse Button
        
        If ListIndex(EditEx()\Items()) >= 0
          
          If CursorRow <> CursorRow_()
            Result = SelectElement(EditEx()\Items(), CursorRow)
          Else  
            Result = #True
          EndIf
          
          If Result

            Select EditEx()\Mouse\Status
              Case #Mouse_Move   ;{ Start Selection
                If EditEx()\Selection\Flag = #NoSelection
                  EditEx()\Selection\Pos1 = EditEx()\Cursor\Pos
                  EditEx()\Selection\Row1 = EditEx()\Cursor\Row
                  EditEx()\Selection\Pos2 = CursorPos_(CursorRow, CursorX)
                  EditEx()\Selection\Row2 = CursorRow
                  EditEx()\Selection\Flag = #Selected
                  EditEx()\Mouse\Status = #Mouse_Select
                  Draw_(GNum)
                EndIf
                ;}
              Case #Mouse_Select ;{ Continue Selection
                EditEx()\Cursor\Pos = CursorPos_(CursorRow, CursorX)
                EditEx()\Cursor\Row = CursorRow
                EditEx()\Selection\Pos2 = EditEx()\Cursor\Pos
                EditEx()\Selection\Row2 = EditEx()\Cursor\Row
                Draw_(GNum)
                ;}
            EndSelect
            
          EndIf

        EndIf
        ;}
      Else
        EditEx()\Mouse\Status = #Mouse_Move
      EndIf
      
      ChangeMouseCursor_(GNum, CursorX, CursorY)
      
    EndIf  
  
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i GNum = EventGadget()
    Define.i Delta, ScrollPos
    
    If FindMapElement(EditEx(), Str(GNum))

      Delta = GetGadgetAttribute(GNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(EditEx()\VScroll\ID)
        
        ScrollPos = GetGadgetState(EditEx()\VScroll\ID) - Delta
        
        If ScrollPos > EditEx()\VScroll\MaxPos : ScrollPos = EditEx()\VScroll\MaxPos : EndIf
        If ScrollPos < EditEx()\VScroll\MinPos : ScrollPos = EditEx()\VScroll\MinPos : EndIf
        
        If ScrollPos <> EditEx()\VScroll\Position
          EditEx()\Visible\RowOffset = ScrollPos
          SetVScrollPosition_()
          Draw_(GNum)
        EndIf
      
      EndIf

    EndIf
    
  EndProcedure
  
  ; --- Resize Gadget ---
  
  Procedure _ResizeHandler()
    Define.i GNum = EventGadget()
    Define.f X, Y, Width, Height
    
    If FindMapElement(EditEx(), Str(GNum))
      X      = GadgetX(GNum)
      Y      = GadgetY(GNum)
      Width  = GadgetWidth(GNum)
      Height = GadgetHeight(GNum)
      
      If EditEx()\Border
        Width  = Width  - 4
        Height = Height - 4
      EndIf
      
      If EditEx()\ScrollBars & #ScrollBar_Vertical Or EditEx()\ScrollBars & #ScrollBar_Horizontal  ;{ Scrollbar Gadgets
        
        If EditEx()\ScrollBars & #ScrollBar_Horizontal : Height - #Scroll_Width - 1 : EndIf
        If EditEx()\ScrollBars & #ScrollBar_Vertical   : Width  - #Scroll_Width - 1 : EndIf
        
        If EditEx()\ScrollBars & #ScrollBar_Horizontal And EditEx()\ScrollBars & #ScrollBar_Vertical
          ResizeGadget(EditEx()\HScroll\ID, 1, Height, Width - 1, #Scroll_Width)
          ResizeGadget(EditEx()\VScroll\ID, Width, 1, #Scroll_Width, Height - 1)
        ElseIf EditEx()\ScrollBars & #ScrollBar_Horizontal  
          ResizeGadget(EditEx()\HScroll\ID, 1, Height, Width - 1, #Scroll_Width)
        ElseIf EditEx()\ScrollBars & #ScrollBar_Vertical
          ResizeGadget(EditEx()\VScroll\ID, Width, 1, #Scroll_Width, Height - 1)
        EndIf
 
      EndIf ;}
      
      EditEx()\Size\Width  = dpiX(Width  - 4)
      EditEx()\Size\Height = dpiY(Height - 4)
      
      EditEx()\HScroll\Hide = #False
      EditEx()\VScroll\Hide = #False
      
      Draw_(GNum)
      AdjustScrolls_()
      
    EndIf
    
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
        
        DeleteMapElement(EditEx())
        
      EndIf
      
    Next
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  
  Procedure.i Pixel(Value.i, Unit.s="mm")
    Define.f ScaleFactor, Pt
    
    Select Unit
      Case "pt"
        ScaleFactor = 1
      Case "mm"
        ScaleFactor = 72 / 25.4
      Case "cm"
       ScaleFactor  = 72 / 2.54
      Case "in"
        ScaleFactor = 72
      Default
        ScaleFactor = 72 / 25.4
    EndSelect
    
    pt = Value * ScaleFactor
    
    ProcedureReturn Pixel(Pt)
  EndProcedure
  
  Procedure   ReDraw_(GNum.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If FontID
        EditEx()\FontID   = FontID
      Else
        EditEx()\FontID   = GetGadgetFont(GNum)
      EndIf
      
      Draw_(GNum)
      
    EndIf
    
  EndProcedure  
  
  ;- ===== Spell Checking =====
  
  CompilerIf #Enable_SpellChecking
    
    Procedure LoadDictionary(DicFile.s, AddDicFile.s="")
      Define Word$, Path$
      
      ClearList(Dictionary())
      
      Path\Dictionary = GetPathPart(DicFile)
      
      If ReadFile(#File, DicFile)
        While Eof(#File) = #False
          Word$ = ReadString(#File)
          AddElement(Dictionary())
          Dictionary()\Stem = StringField(Word$, 1, Chr(127))
          If CountString(Word$, Chr(127)) = 2
            Dictionary()\Endings = StringField(Word$, 2, Chr(127))
            Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
          Else
            Dictionary()\Endings = ""
            Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
          EndIf
        Wend
        CloseFile(#File)
      EndIf
      
      If AddDicFile
        
        If ReadFile(#File, AddDicFile)
          While Eof(#File) = #False
            Word$ = ReadString(#File)
            AddElement(Dictionary())
            Dictionary()\Stem = StringField(Word$, 1, Chr(127))
            If CountString(Word$, Chr(127)) = 2
              Dictionary()\Endings = StringField(Word$, 2, Chr(127))
              Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
            Else
              Dictionary()\Endings = ""
              Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
            EndIf
          Wend
          CloseFile(#File)
        EndIf
      EndIf
      
      ;{ Dictionary is required
      If ListSize(Dictionary()) = 0
        Debug "ERROR: No dictionary found"
        ProcedureReturn #False
      EndIf ;}
      
      ClearList(UserDic())
      
      If ReadFile(#File, Path\Dictionary + "user.dic")
        While Eof(#File) = #False
          Word$ = ReadString(#File)
          AddElement(UserDic())
          UserDic()\Stem = StringField(Word$, 1, Chr(127))
          If CountString(Word$, Chr(127)) = 2
            UserDic()\Endings = StringField(Word$, 2, Chr(127))
            UserDic()\Flag    = Val(StringField(Word$, 3, Chr(127)))
          Else
            UserDic()\Endings = ""
            UserDic()\Flag    = Val(StringField(Word$, 3, Chr(127)))
          EndIf
        Wend
        
        MergeLists(UserDic(), Dictionary())
        
        CloseFile(#File)
      EndIf
      
      SortStructuredList(Dictionary(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))  
      
    EndProcedure
    
    Procedure FreeDictionary()
      ClearList(Dictionary())
    EndProcedure
    
    Procedure EnableAutoSpellCheck(GNum.i, Flag.i=#True)
      
      ;{ Syntax highlighting is required
      If #Enable_SyntaxHighlight = #False
        Debug "ERROR: Syntax highlighting is required => #Enable_SyntaxHighlight = #True"
        ProcedureReturn #False
      EndIf ;}
      
      ;{ Dictionary is required
      If ListSize(Dictionary()) = 0
        Debug "ERROR: Dictionary is required => LoadDictionary()"
        ProcedureReturn #False
      EndIf ;}
      
      EditEx()\SyntaxHighlight = #CaseSensitiv
      
      If FindMapElement(EditEx(), Str(GNum))
        EditEx()\AutoSpellCheck = Flag
      EndIf
      
    EndProcedure
    
    Procedure SpellCheck(Word.s)
      Define.i ListPos, StartPos, EndPos
      Define.s LWord$ = LCase(Word)
      
      StartPos = 0
      EndPos   = ListSize(Dictionary()) - 1
      
      Repeat
        ListPos = StartPos + Round((EndPos - StartPos)  / 2, #PB_Round_Up)
        If SelectElement(Dictionary(), ListPos)
          If Dictionary()\Stem  = LWord$                      ;{ direct hit
            If Dictionary()\Flag ; Upper case required
              If Left(Word, 1) = UCase(Left(Word, 1))
                ProcedureReturn #True
              Else
                ProcedureReturn #False
              EndIf
            Else           ; No capitalization required
              ProcedureReturn #True
            EndIf ;}
          ElseIf Left(LWord$, 4) < Left(Dictionary()\Stem, 4) ;{ word smaller than current word
            EndPos   = ListPos - 1
            ;}
          ElseIf Left(LWord$, 4) > Left(Dictionary()\Stem, 4) ;{ word greater than current word
            StartPos = ListPos + 1
            ;}
          Else                                          ;{ Search by word endings
            If SpellCheckEndings(ListPos, Word)
              ProcedureReturn #True
            Else
              ProcedureReturn #False
            EndIf ;}
          EndIf
        EndIf
      Until (EndPos - StartPos) < 0
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure SpellChecking(GNum.i, Flag.i=#Highlight)
      
      ;{ Syntax highlighting is required
      If #Enable_SyntaxHighlight = #False
        Debug "ERROR: Syntax highlighting is required => #Enable_SyntaxHighlight = #True"
        ProcedureReturn #False
      EndIf ;}
      
      ;{ Dictionary is required
      If ListSize(Dictionary()) = 0
        Debug "ERROR: Dictionary is required => LoadDictionary()"
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
          ForEach Words()
            If Words()\misspelled = #True
              AddElement(WrongWords())
              WrongWords() = MapKey(Words())
              DeleteMapElement(Words())
            EndIf
          Next
        EndIf
        
        If Flag & #Highlight : Draw_(GNum) : EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure SaveUserDictionary()
      Define.s File$, Word$
      
      File$ = Path\Dictionary + "user.dic"
      
      If ListSize(UserDic()) = 0 : ProcedureReturn #False : EndIf
      
      If CreateFile(#File, File$)
        
        SortStructuredList(UserDic(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))
        
        ForEach UserDic()
          Word$ = UserDic()\Stem + Chr(127) + UserDic()\Endings + Chr(127) + UserDic()\Flag
          WriteStringN(#File, Word$, #PB_UTF8)
        Next
        
        CloseFile(#File)
      EndIf
      
    EndProcedure
    
    Procedure AddToUserDictionary(Word.s)
      
      If SpellCheck(Word) = #False
        
        If AddElement(UserDic())
          UserDic()\Stem    = LCase(Word)
          UserDic()\Endings = ""
          If Left(Word, 1) = UCase(Left(Word, 1))
            UserDic()\Flag  = #True
          Else
            UserDic()\Flag  = #False
          EndIf
        EndIf
        
        If AddElement(Dictionary())
          Dictionary()\Stem    = LCase(Word)
          Dictionary()\Endings = ""
          If Left(Word, 1) = UCase(Left(Word, 1))
            Dictionary()\Flag  = #True
          Else
            Dictionary()\Flag  = #False
          EndIf
        EndIf
        
        SortStructuredList(Dictionary(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))
        
      EndIf
      
    EndProcedure
    
    Procedure ClearCheckedWords()
      
      ClearMap(Words())
      
    EndProcedure
    
  CompilerEndIf  
  
  ;- ===== Hyphenation =====
  
  CompilerIf #Enable_Hyphenation
  
    Procedure   LoadHyphenationPattern(File.s=#PAT_Deutsch) ; [ ALL gadgets ]
      Define.s Pattern 
      
      Path\Pattern = GetPathPart(File)
      
      ClearList(HyphPattern())
      
      If ReadFile(#File, File)
        While Eof(#File) = #False
          Pattern = Trim(ReadString(#File, #PB_UTF8))
          AddElement(HyphPattern())
          HyphPattern()\chars   = StringField(Pattern, 1, ":")
          HyphPattern()\pattern = StringField(Pattern, 2, ":")
        Wend 
        CloseFile(#File)
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
      
    EndProcedure

  CompilerEndIf
  
  ;- ===== Syntax Highlighting =====
  
  CompilerIf #Enable_SyntaxHighlight
    
    Procedure EnableSyntaxHighlight(GNum.i, Flag.i=#CaseSensitiv) ; #False/#CaseSensitiv/#NoCase
      
      If FindMapElement(EditEx(), Str(GNum))
        
        EditEx()\SyntaxHighlight = Flag
        
        Draw_(GNum)
        
      EndIf
      
    EndProcedure
  
    Procedure AddWord(GNum.i, Word.s, Color.i=#False)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        EditEx()\Syntax(Word)  = Color
        
      EndIf
    
  EndProcedure
  
    Procedure DeleteWord(GNum.i, Word.s)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        DeleteMapElement(EditEx()\Syntax(), Word) 
  
      EndIf  
   
    EndProcedure
  
    Procedure ClearWords(GNum.i)
      
      If FindMapElement(EditEx(), Str(GNum))
        
        ClearMap(EditEx()\Syntax())
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  ;- ===== Undo / Redo =====
  
  CompilerIf #Enable_UndoRedo

    Procedure EnableUndoRedo(GNum.i, Flag.i=#True, MaxSteps.i=#False) ; #True / #False
      
      If FindMapElement(EditEx(), Str(GNum))
        
        EditEx()\UndoRedo      = Flag
        EditEx()\Undo\MaxSteps = MaxSteps
        
      EndIf
      
    EndProcedure  
    
    Procedure Undo(GNum.i)
      Define r.i, Text$, CurrentText$
      
      If FindMapElement(EditEx(), Str(GNum))
        
        Undo_()
       
        Draw_(GNum)
        AdjustScrolls_()
        
      EndIf
      
    EndProcedure
    
    Procedure Redo(GNum.i)
      Define r.i, Text$
      
      If FindMapElement(EditEx(), Str(GNum))
        
        Text$ = GetLastRedo_()
        If Trim(Text$)
          
          ClearList(EditEx()\Items())
          
          For r=0 To CountString(Text$, #LineBreak$)
        
            If AddElement(EditEx()\Items())
              EditEx()\Items()\String = StringField(Text$, r+1, #LineBreak$) + #LineBreak$
            EndIf
            
          Next
          
          ClearRedo_()
          
          If SelectElement(EditEx()\Items(), EditEx()\Undo\CursorRow)
            EditEx()\Cursor\Pos = EditEx()\Undo\CursorPos
          EndIf
          
          Draw_(GNum)
          AdjustScrolls_()
          
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
  
  Procedure.i IsSelected(GNum.i)                      ; Returns whether a selection exists
    
    If FindMapElement(EditEx(), Str(GNum))
      If EditEx()\Selection\Flag = #Selected
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure   DeleteSelection(GNum.i, Remove.i=#True) ; Delete selected text (Remove selection: #True/#False)
    Define row.i, CurrentRow, Text.s
    
    If EditEx()\ReadOnly = #False
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If DeleteSelection_(Remove)
          Draw_(GNum)
        EndIf
      
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.s GetSelection(GNum.i, Remove.i=#True)    ; Return selected text (Remove selection: #True/#False)
    Define row.i, Text.s
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Text = GetSelection_(Remove)      
      If Remove : Draw_(GNum) : EndIf
      
      ProcedureReturn Text
    EndIf
  
  EndProcedure
  
  Procedure   InsertText(GNum.i, Text.s)              ; Insert text at cursor position (or replace selection)
    
    If EditEx()\ReadOnly = #False
      
      If FindMapElement(EditEx(), Str(GNum))
        
        If EditEx()\Selection\Flag = #Selected
          DeleteSelection_()
        EndIf
        
        EditEx()\Items()\String = InsertString(EditEx()\Items()\String, Text, EditEx()\Cursor\Pos + 1)
        EditEx()\Cursor\Pos + Len(Text)
        
        Draw_(GNum)
        
        AdjustScrolls_()

      EndIf
      
    EndIf
    
  EndProcedure

  ;- ===== Clipboard =====
  
  Procedure  Copy(GNum.i)
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\Selection\Flag = #Selected
        
        Text$ = GetSelection_()
        If Text$
          Text$ = ReplaceString(Text$, #LineBreak$, #NL$)
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
          Text$ = ReplaceString(Text$, #LineBreak$, #NL$)
          SetClipboardText(Text$)
          DeleteSelection_()
        EndIf
        
        Draw_(GNum)
        AdjustScrolls_()
        
      EndIf
      
    EndIf 
    
  EndProcedure
  
  Procedure  Paste(GNum.i)
    Define.s Text$
    
    If FindMapElement(EditEx(), Str(GNum))
      
      If EditEx()\ReadOnly = #False
        
        Text$ = ReplaceString(GetClipboardText(), #NL$, #LineBreak$)

        If EditEx()\Selection\Flag = #Selected
          DeleteSelection_()
        EndIf
        
        EditEx()\Items()\String = InsertString(EditEx()\Items()\String, Text$, EditEx()\Cursor\Pos + 1)
        EditEx()\Cursor\Pos + Len(Text$)
        
        CompilerIf #Enable_SpellChecking
          EditEx()\SpellCheck = #True
        CompilerEndIf
        
        Draw_(GNum)
        AdjustScrolls_()
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  ;- ===== Text Handling =====
  
  Procedure   AddItem(GNum.i, Position.i, Text.s)       ; Add text row at 'Position' (or #FirstRow / #LastRow)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      AddItem_(Position.i, Text.s)
      
      CompilerIf #Enable_SpellChecking
        EditEx()\SpellCheck = #True
      CompilerEndIf
      
      Draw_(GNum)
      
      AdjustScrolls_()

    EndIf
    
    ProcedureReturn ListIndex(EditEx()\Items())
  EndProcedure
  
  Procedure   SetItemText(GNum.i, Position.i, Text.s)   ; Replace text row at 'Position'
    Define Count.i
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Count = ListSize(EditEx()\Items())
      If Count And Position < Count
        If SelectElement(EditEx()\Items(), Position)
          EditEx()\Items()\String = Text
        EndIf
      EndIf
      
      Draw_(GNum)
      
      CompilerIf #Enable_SpellChecking
        EditEx()\SpellCheck = #True
      CompilerEndIf
      
      CompilerIf #Enable_UndoRedo
        If EditEx()\UndoRedo : AddUndo_() : EndIf
      CompilerEndIf
      
    EndIf  

  EndProcedure
  
  
  Procedure.s GetItemText(GNum.i, Position.i)           ; Return text row from 'Position'
    Define Count.i, Text.s
    
    If FindMapElement(EditEx(), Str(GNum))
      
      PushListPosition(EditEx()\Items())
      
      Count = ListSize(EditEx()\Items())
      If Count And Position < Count
        SelectElement(EditEx()\Items(), Position)
        Text = EditEx()\Items()\String
      EndIf
      
      PopListPosition(EditEx()\Items())
      
      ProcedureReturn Text
    EndIf
    
  EndProcedure
  
  Procedure   SetText(GNum.i, Text.s, Seperator.s=#NL$) ; Set/Replace all text rows
    Define r.i
    
    If FindMapElement(EditEx(), Str(GNum))
      
      ClearList(EditEx()\Items())
      
      For r=0 To CountString(Text, Seperator)
        
        If AddElement(EditEx()\Items())
          EditEx()\Items()\String = StringField(Text, r+1, Seperator) + #LineBreak$
        EndIf
        
      Next

      FirstElement(EditEx()\Items()) 

      CompilerIf #Enable_SpellChecking
        EditEx()\SpellCheck = #True
      CompilerEndIf
      
      CompilerIf #Enable_UndoRedo
        If EditEx()\UndoRedo : AddUndo_() : EndIf
      CompilerEndIf
      
      Draw_(GNum)
      
      AdjustScrolls_()
      
    EndIf 
    
  EndProcedure
  
  Procedure.s GetText(GNum.i, Seperator.s=#NL$)         ; Get all text seperated by 'Seperator'
    Define.s Text
    
    If FindMapElement(EditEx(), Str(GNum))
      
      PushListPosition(EditEx()\Items())
      
      ForEach EditEx()\Items()
        If ListIndex(EditEx()\Items()) = ListSize(EditEx()\Items()) - 1
          Text + EditEx()\Items()\String
        Else
          Text + EditEx()\Items()\String + Seperator
        EndIf
      Next
      
      Text = ReplaceString(Text, #LineBreak$, #NL$)
      
      PopListPosition(EditEx()\Items())
      
      ProcedureReturn Text
    EndIf
    
  EndProcedure
  
  ;- ===== Customize Gadget =====
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i) ; Similar to SetGadgetAttribute()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Select Attribute
        Case #ReadOnly, #PB_Editor_ReadOnly
          EditEx()\ReadOnly = Value
        Case #WordWrap, #PB_Editor_WordWrap
          EditEx()\WordWrap = Value
        Case #Hyphenation
          EditEx()\Hyphenation = Value
        Case #MaxTextWidth  
          EditEx()\Text\Width  = Value
        Case #AutoHide
          EditEx()\AutoHide = Value
          AdjustScrolls_()
        Case #CtrlChars
          EditEx()\Visible\CtrlChars = Value
          If Value = #True
            Font()\Char(#CR$) = 0
            Font()\Char(#LF$) = 0
            Font()\Char(#LineBreak$)  = 0
            Font()\Char(#SoftHyphen$) = 0
          EndIf
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)          ; Similar to GetGadgetAttribute()
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Select Attribute
        Case #ReadOnly, #PB_Editor_ReadOnly
          ProcedureReturn EditEx()\ReadOnly
        Case #WordWrap, #PB_Editor_WordWrap
          ProcedureReturn EditEx()\WordWrap
        Case #Hyphenation
          ProcedureReturn EditEx()\Hyphenation
        Case #AutoHide
          ProcedureReturn EditEx()\AutoHide
        Case #CtrlChars
          ProcedureReturn EditEx()\Visible\CtrlChars
        Case #MaxTextWidth  
          ProcedureReturn EditEx()\Text\Width
      EndSelect
      
    EndIf
    
  EndProcedure
  
  
  Procedure   SetColor(GNum.i, Attribute.i, Color.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      Select Attribute
        Case #FrontColor, #PB_Gadget_FrontColor
          EditEx()\Color\Front = Color
        Case #BackColor, #PB_Gadget_BackColor
          EditEx()\Color\Back  = Color
        Case #SyntaxColor
          EditEx()\Color\SyntaxHighlight = Color
        Case #SelectTextColor
          EditEx()\Color\HighlightText = Color
        Case #SelectionColor
          EditEx()\Color\Highlight = Color
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
        Case #SyntaxColor
          ProcedureReturn EditEx()\Color\SyntaxHighlight
        Case #SelectionColor
          ProcedureReturn EditEx()\Color\Highlight
        Case #SelectTextColor
          ProcedureReturn EditEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure   AttachPopup(GNum.i, PopUpMenu.i)           ; Attach 'PopUpMenu' to gadget 
    If FindMapElement(EditEx(), Str(GNum))
      EditEx()\PopupMenu = PopUpMenu
    EndIf
  EndProcedure  
  
  ;- ===== Gadget =====
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum
    
    If Flags & #Scrollbars ;{ Scrollbars
      Flags & ~#Scrollbars
      Flags | #ScrollBar_Horizontal
      Flags | #ScrollBar_Vertical
    EndIf ;}
    
    Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard|#PB_Canvas_Container|#PB_Canvas_ClipMouse)
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      If AddMapElement(EditEx(), Str(GNum))
     
        EditEx()\CanvasNum = GNum
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          
          If WindowNum = #PB_Default
            EditEx()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            EditEx()\Window\Num = WindowNum
          EndIf
          
        CompilerElse
          
          If WindowNum = #PB_Default
            EditEx()\Window\Num = GetActiveWindow()
          Else
            EditEx()\Window\Num = WindowNum
          EndIf
        
        CompilerEndIf
        
        If IsWindow(EditEx()\Window\Num)
          EditEx()\Window\Width  = WindowWidth(EditEx()\Window\Num)
          EditEx()\Window\Height = WindowHeight(EditEx()\Window\Num)
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

        If Flags & #WordWrap Or Flags & #PB_Editor_WordWrap
          EditEx()\WordWrap = #True
          Flags & ~#ScrollBar_Horizontal
        EndIf
    
        If Flags & #ScrollBar_Vertical Or Flags & #ScrollBar_Horizontal  ;{ Scrollbar Gadgets
          
          If Flags & #ScrollBar_Horizontal : Height - dpiY(#Scroll_Width) - 1 : EndIf
          If Flags & #ScrollBar_Vertical   : Width  - dpiX(#Scroll_Width) - 1 : EndIf
          
          If Flags & #ScrollBar_Horizontal And Flags & #ScrollBar_Vertical
            EditEx()\HScroll\ID = ScrollBarGadget(#PB_Any, 1, Height, Width - 1, #Scroll_Width, 0, 0, 0)
            EditEx()\VScroll\ID = ScrollBarGadget(#PB_Any, Width, 1, #Scroll_Width, Height - 1, 0, 0, 0, #PB_ScrollBar_Vertical)
            EditEx()\ScrollBars = #ScrollBar_Vertical | #ScrollBar_Horizontal
            SetGadgetData(EditEx()\VScroll\ID, GNum)
            SetGadgetData(EditEx()\HScroll\ID, GNum)
            BindGadgetEvent(EditEx()\HScroll\ID, @_SynchronizeScrollPos(),  #PB_All)
            BindGadgetEvent(EditEx()\VScroll\ID, @_SynchronizeScrollRows(), #PB_All) 
          ElseIf Flags & #ScrollBar_Horizontal
            EditEx()\HScroll\ID = ScrollBarGadget(#PB_Any, 1, Height, Width-1, #Scroll_Width, 0, 0, 0)
            EditEx()\ScrollBars = #ScrollBar_Horizontal
            SetGadgetData(EditEx()\HScroll\ID, GNum)
            BindGadgetEvent(EditEx()\HScroll\ID, @_SynchronizeScrollPos(), #PB_All)
          ElseIf Flags & #ScrollBar_Vertical
            EditEx()\VScroll\ID = ScrollBarGadget(#PB_Any, Width, 1, #Scroll_Width, Height - 1, 0, 0, 0, #PB_ScrollBar_Vertical)
            EditEx()\ScrollBars = #ScrollBar_Vertical
            SetGadgetData(EditEx()\VScroll\ID, GNum)
            BindGadgetEvent(EditEx()\VScroll\ID, @_SynchronizeScrollRows(), #PB_All)
          EndIf
          
        Else
          EditEx()\HScroll\Hide = #True
          EditEx()\VScroll\Hide = #True
          EditEx()\HScroll\ID = #PB_Default
          EditEx()\VScroll\ID = #PB_Default
          EditEx()\ScrollBars = #False
        EndIf ;}
        
        EditEx()\Flags = Flags
        
        SetGadgetData(EditEx()\CanvasNum, GNum)
        
        AddElement(EditEx()\Items())
        
      Else
        ProcedureReturn #False
      EndIf
      
      EditEx()\Size\X = dpiX(4)
      EditEx()\Size\Y = dpiY(2)
      EditEx()\Size\Width  = dpiX(Width  - 8)
      EditEx()\Size\Height = dpiY(Height - 4)
      
      If Flags & #ReadOnly Or Flags & #PB_Editor_ReadOnly
        EditEx()\ReadOnly = #True
      EndIf
    
      ;{ ----- Set colors -------------------------
      
      EditEx()\Color\Front         = $000000
      EditEx()\Color\Back          = $FFFFFF
      EditEx()\Color\ReadOnly      = $FEFEFE
      EditEx()\Color\Cursor        = $000000
      EditEx()\Color\HighlightText = $FFFFFF
      EditEx()\Color\Highlight     = $D77800
      EditEx()\Color\ScrollBar     = $C8C8C8
      EditEx()\Color\Border        = $E3E3E3
      
      CompilerSelect  #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
          EditEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
          EditEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
          EditEx()\Color\ReadOnly      = GetSysColor_(#COLOR_3DLIGHT)
          EditEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
          EditEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
          EditEx()\Color\Cursor        = GetSysColor_(#COLOR_WINDOWTEXT)
          EditEx()\Color\ScrollBar     = GetSysColor_(#COLOR_MENU)
          EditEx()\Color\Border        = GetSysColor_(#COLOR_ACTIVEBORDER)
        CompilerCase #PB_OS_MacOS  
          EditEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
          EditEx()\Color\Back          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
          EditEx()\Color\ReadOnly      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
          EditEx()\Color\HighlightText = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
          EditEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextBackgroundColor"))
          EditEx()\Color\Cursor        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
          EditEx()\Color\ScrollBar     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
          EditEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
        CompilerCase #PB_OS_Linux
      
      CompilerEndSelect ;}
      
      If EditEx()\ReadOnly
        EditEx()\Color\Back = EditEx()\Color\ReadOnly
      EndIf
      
      EditEx()\Color\SyntaxHighlight = $0000E6
    
      ; -----------------------------------------
      
      EditEx()\Visible\RowOffset = 0
      EditEx()\Visible\PosOffset = 0
      
      BindGadgetEvent(GNum, @_RightClickHandler(),      #PB_EventType_RightClick)
      BindGadgetEvent(GNum, @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
      BindGadgetEvent(GNum, @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
      BindGadgetEvent(GNum, @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
      BindGadgetEvent(GNum, @_MouseMoveHandler(),       #PB_EventType_MouseMove)
      BindGadgetEvent(GNum, @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
      BindGadgetEvent(GNum, @_KeyDownHandler(),         #PB_EventType_KeyDown)
      BindGadgetEvent(GNum, @_InputHandler(),           #PB_EventType_Input)
      BindGadgetEvent(GNum, @_LostFocusHandler(),       #PB_EventType_LostFocus)
      BindGadgetEvent(GNum, @_FocusHandler(),           #PB_EventType_Focus)
      BindGadgetEvent(GNum, @_ResizeHandler(),          #PB_EventType_Resize)
      
      BindEvent(#Event_Cursor, @_CursorDrawing(), EditEx()\Window\Num, GNum)
      BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), EditEx()\Window\Num)
      
      CloseGadgetList()
    EndIf
    
    AdjustScrolls_()

    Draw_(GNum)
    
    ProcedureReturn GNum
  EndProcedure
  
  Procedure RemoveGadget(GNum.i)
    
    If FindMapElement(EditEx(), Str(GNum))
      
      CompilerIf Defined(ModuleEx, #PB_Module) = #False
        If MapSize(EditEx()) = 1
          Thread\Exit = #True
          Delay(100)
          If IsThread(Thread\Num) : KillThread(Thread\Num) : EndIf
          Thread\Active = #False
        EndIf
      CompilerEndIf
      
      DeleteMapElement(EditEx())
      
    EndIf 
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Language = EditEx::#Deutsch  ; #Deutsch / #English / #French
  
  Define.s Text
  Define.i QuitWindow.i
  
  Enumeration 
    #Win
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
      ;Text + #LF$ + "The teacher took the students by the ears with his trunk." + #LF$ + "They didn't learn anything, they just made noise, all effort was lost."
    Case EditEx::#French
      Text = "L'école est une belle chose." + #LF$ + "Tu en as besoin, c'est vrai." + #LF$ + "Sur un arbre tombé, un troupeau de singes était assis."
      Text + #LF$ + "Ils avaient été envoyés là-bas pour se décider."  + #LF$ + "Le professeur pesait trois tonnes, un éléphant intelligent."
      ;Text + #LF$ + "Le professeur a pris les élèves par les oreilles avec son coffre." + #LF$ + "Ils n'ont rien appris, ils ont juste fait du bruit, tous les efforts ont été perdus."
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
    
  CompilerEndIf
  
  If OpenWindow(#Win, 0, 0, 322, 287, "EditorGadget", #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
    
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
    
    EditEx::Gadget(#EditEx, 8, 146, 306, 133, EditEx::#ScrollBars, #Win)
    EditEx::SetFont(#EditEx, FontID(#Font))
    
    EditEx::SetAttribute(#EditEx, EditEx::#AutoHide, #True)    ; Test AutoHide Scrollbars
    
    ; Test WordWrap and Hyphenation
    CompilerIf EditEx::#Enable_Hyphenation
      EditEx::SetAttribute(#EditEx, EditEx::#Hyphenation, #True) ; Test Hyphenation
    CompilerElse
      EditEx::SetAttribute(#EditEx, EditEx::#WordWrap, #True)    ; Test WordWrap
    CompilerEndIf
    
    CompilerIf EditEx::#Enable_UndoRedo
      EditEx::EnableUndoRedo(#EditEx, #True)
    CompilerEndIf
    
    EditEx::AttachPopup(#EditEx, #PopupMenu)
    
    ;EditEx::SetAttribute(#EditEx, EditEx::#CtrlChars, #True)
    
    ; --- Add Text ---
    EditEx::SetText(#EditEx, Text, #LF$)
    ; ----------------
    
    CompilerIf EditEx::#Enable_SpellChecking

      EditEx::AddToUserDictionary("Affenschar")
      
      EditEx::EnableAutoSpellCheck(#EditEx)
    
    CompilerElseIf EditEx::#Enable_SyntaxHighlight
      
      EditEx::EnableSyntaxHighlight(#EditEx)
      EditEx::AddWord(#EditEx, "Schule")
      EditEx::AddWord(#EditEx, "ein")
      EditEx::AddWord(#EditEx, "Affenschar", #Blue)
      EditEx::AddWord(#EditEx, "bilden",     #Green)
      EditEx::ReDraw_(#EditEx)
      
      ; EditEx::DeleteWord(#EditEx, "ein")
      
    CompilerEndIf
    
    ;ResizeGadget(#EditEx, #PB_Ignore, #PB_Ignore, 290, 100) ; Test ResizeHandler
    
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
      EditEx::SaveUserDictionary()
    CompilerEndIf
    
    EditEx::RemoveGadget(#EditEx)
    
    CloseWindow(#Win)  
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 11
; Folding = 5BOIAIIZNAgggGAAAAAsMMCgDIoBAAHAAmAAAAAQAAoJxP5ABABAAwOCBA-
; Markers = 1061,2844,3305
; EnableThread
; EnableXP
; DPIAware