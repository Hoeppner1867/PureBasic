;/ ===========================
;/ =    ListEx-Module.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ Editable and sortable ListGadget
;/
;/ © 2019 Thorsten1867 (03/2019)
;/
 
; Last Update: 16.11.2019
;
; - Added: gadget number '#Theme' (#PB_Default) changes all gadgets for suitable commands
;
; - Bugfix: #LockCell and Drag & Drop
;
; - Bugfix: Cash
; - Added: CSV support (file/clipboard)
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


;{ _____ ListEx - Commands _____

; ListEx::AddCells()                - adds a new row and insert text in cells with label
; ListEx::AddColumn()               - similar to 'AddGadgetColumn()'
; ListEx::AddComboBoxItems()        - add items to the comboboxes of the column (items seperated by #LF$)
; ListEx::AddItem()                 - similar to 'AddGadgetItem()'
; ListEx::CountItems()              - similar to 'CountGadgetItems()' [#Selected/#Checked/#Inbetween]
; ListEx::ChangeCountrySettings()   - change default settings
; ListEx::ClearComboBoxItems()      - clear items of the comboboxes of the column
; ListEx::ClearItems()              - similar to 'ClearGadgetItems()'
; ListEx::ClipBoard()               - copy selected items to clipboard (CSV)
; ListEx::DisableEditing()          - disable editing for the complete list
; ListEx::DisableReDraw()           - disable redraw
; ListEx::EventColumn()             - column of event (Event: ListEx::#Event_Module)
; ListEx::EventRow()                - row of event    (Event: ListEx::#Event_Module)
; ListEx::EventState()              - returns state   (e.g. CheckBox / DateGadget)
; ListEx::EventValue()              - returns value   (string)
; ListEx::EventID()                 - returns row ID or header label 
; ListEx::ExportCSV()               - export CSV-file from list
; ListEx::Gadget()                  - [#GridLines|#NumberedColumn|#NoRowHeader]
; ListEx::GetAttribute()            - similar to 'GetGadgetAttribute()'
; ListEx::GetCellText()             - similar to 'GetGadgetItemText()' with labels
; ListEx::GetCellState()            - similar to 'GetGadgetItemState()' with labels
; ListEx::GetChangedState()         - check whether entries have been edited
; ListEx::GetColumnAttribute()      - similar to 'GetGadgetItemAttribute()'
; ListEx::GetColumnFromLabel()      - returns column number for this label
; ListEx::GetColumnLabel()          - returns the label of the column
; ListEx::GetColumnState()          - similar to 'GetGadgetItemState()' for a specific column
; ListEx::GetItemData()             - similar to 'GetGadgetItemData()'
; ListEx::GetItemID()               - similar to 'GetGadgetItemData()' but with string data
; ListEx::GetItemState()            - similar to 'GetGadgetItemState()' [#Selected/#Checked/#Inbetween]
; ListEx::GetItemText()             - similar to 'GetGadgetItemText()'
; ListEx::GetRowFromLabel()         - returns row number for this label
; ListEx::GetRowLabel()             - returns the label of the row
; ListEx::GetState(GNum.i)          - similar to 'GetGadgetState()'
; ListEx::Hide()                    - similar to 'HideGadget()', but disables redrawing of the canvas gadget
; ListEx::HideColumn()              - hides a column
; ListEx::ImportCSV()               - import CSV-file to list
; ListEx::Refresh()                 - redraw gadget
; ListEx::RemoveCellFlag()          - removes a flag
; ListEx::RemoveColumn()            - similar to 'RemoveGadgetColumn()'
; ListEx::RemoveColumnFlag()        - removes a column flag
; ListEx::RemoveFlag()              - removes a gadget flag
; ListEx::RemoveItem()              - similar to 'RemoveGadgetItem()'
; ListEx::RemoveItemState()         - removes #Selected / #Checked / #Inbetween
; ListEx::ResetChangedState()       - reset to not edited
; ListEx::SelectItems()             - select all rows [#All/#None]
; ListEx::SetAttribute()            - similar to SetGadgetAttribute()  [#Padding] 
; ListEx::SetAutoResizeColumn()     - column that is reduced when the vertical scrollbar is displayed.
; ListEx::SetAutoResizeFlags()      - [#MoveX|#MoveY|#Width|#Height]
; ListEx::SetCellFlags()            - [#LockCell|#Strings|#ComboBoxes|#Dates]
; ListEx::SetCellState()            - similar to 'SetGadgetItemState()' with labels
; ListEx::SetCellText()             - similar to 'SetGadgetItemText()'  with labels
; ListEx::SetColor()                - similar to 'SetGadgetColor()'
; ListEx::SetColorTheme()           - change the color theme
; ListEx::SetColumnAttribute()      - [#Align/#ColumnWidth/#Font]
; ListEx::SetColumnFlags()          - [#FitColumn | #Left/#Right/#Center]
; ListEx::SetColumnState()          - similar to 'SetGadgetItemState()' for a specific column
; ListEx::SetCurrency()             - 
; ListEx::SetDateMask()             - similar to 'SetGadgetText()' and 'DateGadget()'
; ListEx::SetDateAttribute()        - similar to 'SetGadgetAttribute()' and 'DateGadget()'
; ListEx::SetFlags()                - set gadget flags
; ListEx::SetFont()                 - similar to 'SetGadgetFont()'
; ListEx::SetHeaderAttribute()      - [#Align]
; ListEx::SetHeaderHeight()         - set header height
; ListEx::SetHeaderSort()           - enable sort by header column [#Sort_Ascending|#Sort_Descending|#Sort_NoCase|#Sort_SwitchDirection]
; ListEx::SetItemAttribute()        - similar to 'SetGadgetItemAttribute()'
; ListEx::SetItemColor()            - similar to 'SetGadgetItemColor()'
; ListEx::SetItemData()             - similar to 'SetGadgetItemData()'
; ListEx::SetItemFont()             - change font of row or header [#Header]
; ListEx::SetItemID()               - similar to 'SetGadgetItemData()' but with string data
; ListEx::SetItemImage( )           - add a image at row/column
; ListEx::SetItemState()            - similar to 'SetGadgetItemState()' [#Selected/#Checked/#Inbetween]
; ListEx::SetItemText()             - similar to 'SetGadgetItemText()'
; ListEx::SetProgressBarAttribute() - set minimum or maximum value for progress bars
; ListEx::SetProgressBarFlags()     - set flags for progressbar (#ShowPercent)
; ListEx::SetRowsHeight()           - change height of rows
; ListEx::SetTimeMask()             - change mask for time (sorting)
; ListEx::Sort()                    - sort rows by column [#SortString|#SortNumber|#SortFloat|#SortDate|#SortBirthday|#SortTime|#SortCash / #Deutsch]

;} -----------------------------

;XIncludeFile "ModuleEx.pbi"

DeclareModule ListEx
  
  #Version = 15111900
  
  #Enable_Validation  = #True
  #Enable_MarkContent = #True
  #Enable_ProgressBar = #True
  #Enable_DragAndDrop = #True
  #Enable_CSV_Support = #True
  #Enable_GUI_Theme   = #True
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #Theme = -1
  
  #FirstItem = 0
  #LastItem  = -1
  
  #All  = 1
  #None = 0
  
  #Header   = -1
  #NotValid = -2 
  
  #Ascending   = #PB_Sort_Ascending
  #Descending  = #PB_Sort_Descending
  #SortNoCase  = #PB_Sort_NoCase
  
  #ColumnCount = #PB_ListIcon_ColumnCount

  #Minimum     = #PB_Date_Minimum
  #Maximum     = #PB_Date_Maximum
  
  #Progress$ = "{Percent}"
  
  EnumerationBinary 
    #Selected   = #PB_ListIcon_Selected
    #Checked    = #PB_ListIcon_Checked
    #Inbetween  = #PB_ListIcon_Inbetween
    #HeaderRow
  EndEnumeration
  
  EnumerationBinary ; ProgressBars
    #ShowPercent
  EndEnumeration
  
  EnumerationBinary ; Sort Header
    #Left   = 1
    #Right  = 1<<1
    #Center = 1<<2
    #Deutsch
    #Lexikon
    #Namen
    #SortString
    #SortNumber
    #SortDate
    #SortBirthday
    #SortTime
    #SortCash
    #SortFloat
    #HeaderSort
    #SortArrows
    #SwitchDirection
  EndEnumeration  
  
  Enumeration ; Attribute
    #Align
    #Font
    #FontID
    #ColumnWidth
    #HeaderHeight
    #Padding
    #Gadget
    #HeaderFont
    #GadgetFont
  EndEnumeration
  
  EnumerationBinary Flags
    #Left    = 1
    #Right   = 1<<1
    #Center  = 1<<2
    #ChBFlag = 1<<3
    ; ---Gadget ---
    #GridLines
    #NoRowHeader
    #NumberedColumn
    #SingleClickEdit
    #AutoResize
    #ResizeColumn
    #UseExistingCanvas
    #ThreeState
    #MultiSelect
    #FitColumn
    ; --- Color ---
    #ActiveLinkColor
    #BackColor
    #ButtonColor
    #ButtonBorderColor
    #ProgressBarColor
    #GradientColor
    #EditColor
    #FocusColor
    #FrontColor
    #GadgetBackColor
    #LineColor
    #LinkColor
    #HeaderFrontColor
    #HeaderBackColor
    #HeaderLineColor
    #AlternateRowColor
  EndEnumeration

  EnumerationBinary ColumnFlags
    #Left    = 1
    #Right   = 1<<1
    #Center  = 1<<2
    #CheckBoxes = #ChBFlag
    #ComboBoxes
    #Dates
    #Strings
    #Editable = #Strings
    #Buttons
    #Links
    #Image
    #ProgressBar
    #MarkContent
    #Hide
    #CellFont
    #CellFront
    #CellBack
    #CellLine
    #LockCell
    ; --------
    #Cash
    #Float
    #Grades
    #Integer
    #Number     ; unsigned Integer
    #Time
    #Text
  EndEnumeration  
  
  EnumerationBinary
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration 
  
  Enumeration 1
    #Currency
    #Clock
    #TimeSeperator
    #DateSeperator
    #DecimalSeperator
  EndEnumeration
  
  Enumeration
    #Theme_Default
    #Theme_Custom
    #Theme_Blue  
    #Theme_Green
  EndEnumeration
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Cursor       = ModuleEx::#Event_Cursor
    #Event_Gadget       = ModuleEx::#Event_Gadget
    #Event_Theme        = ModuleEx::#Event_Theme
    
    #EventType_Button   = ModuleEx::#EventType_Button
    #EventType_String   = ModuleEx::#EventType_String
    #EventType_CheckBox = ModuleEx::#EventType_CheckBox
    #EventType_ComboBox = ModuleEx::#EventType_ComboBox
    #EventType_Date     = ModuleEx::#EventType_Date
    #EventType_Header   = ModuleEx::#EventType_Header
    #EventType_Link     = ModuleEx::#EventType_Link
    #EventType_Row      = ModuleEx::#EventType_Row
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Button
      #EventType_String
      #EventType_CheckBox
      #EventType_ComboBox
      #EventType_Date
      #EventType_Header
      #EventType_Link
      #EventType_Row
    EndEnumeration
    
  CompilerEndIf
  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================

  Declare.i AddColumn(GNum.i, Column.i, Title.s, Width.f, Label.s="", Flags.i=#False)
  Declare.i AddComboBoxItems(GNum.i, Column.i, Text.s)
  Declare.i AddCells(GNum.i, Row.i=-1, Labels.s="", Text.s="", RowID.s="", Flags.i=#False) 
  Declare.i AddItem(GNum.i, Row.i=-1, Text.s="", Label.s="", Flags.i=#False)
  Declare   AttachPopupMenu(GNum.i, Popup.i)
  Declare   ChangeCountrySettings(GNum.i, CountryCode.s, Currency.s="", Clock.s="", DecimalSeperator.s="", TimeSeperator.s="", DateSeperator.s="")
  Declare   ClearComboBoxItems(GNum.i, Column.i)
  Declare   ClearItems(GNum.i)
  Declare   CloseEdit(GNum.i)
  Declare   DebugList(GNum.i)
  Declare.i CountItems(GNum.i, Flag.i=#False)
  Declare   DisableEditing(GNum.i, State.i=#True)
  Declare   DisableReDraw(GNum.i, State.i=#True)
  Declare.i EventColumn(GNum)
  Declare.s EventID(GNum.i)
  Declare.i EventRow(GNum.i)
  Declare.i EventState(GNum.i)
  Declare.s EventValue(GNum.i)
  Declare.i Gadget(GNum.i, X.f, Y.f, Width.f, Height.f, ColTitle.s, ColWidth.f, ColLabel.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.s GetCellText(GNum.i, Row.i, Label.s)
  Declare.i GetCellState(GNum.i, Row.i, Label.s) 
  Declare.i GetChangedState(GNum.i)
  Declare.i GetColumnAttribute(GNum.i, Column.i, Attribute.i)
  Declare.i GetColumnFromLabel(GNum.i, Label.s)
  Declare.s GetColumnLabel(GNum.i, Column.i)
  Declare.i GetColumnState(GNum.i, Row.i, Column.i)
  Declare.i GetItemData(GNum.i, Row.i)
  Declare.s GetItemID(GNum.i, Row.i)
  Declare.i GetItemState(GNum.i, Row.i, Column.i=#PB_Ignore)
  Declare.s GetItemText(GNum.i, Row.i, Column.i)
  Declare.i GetRowFromLabel(GNum.i, Label.s)
  Declare.s GetRowLabel(GNum.i, Row.i)
  Declare.i GetState(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare.i HideColumn(GNum.i, Column.i, State.i=#True)
  Declare   LoadColorTheme(GNum.i, File.s)
  Declare   Refresh(GNum.i)
  Declare   RemoveCellFlag(GNum.i, Row.i, Column.i, Flag.i)
  Declare   RemoveColumn(GNum.i, Column.i)
  Declare   RemoveColumnFlag(GNum.i, Column.i, Flag.i)
  Declare   RemoveFlag(GNum.i, Flag.i)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   RemoveItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore)
  Declare   ResetChangedState(GNum.i)
  Declare   SaveColorTheme(GNum.i, File.s)
  Declare.i SelectItems(GNum.i, Flag.i=#All)
  Declare   SetAttribute(GNum.i, Attrib.i, Value.i)
  Declare   SetAutoResizeColumn(GNum.i, Column.i, minWidth.f=#PB_Default, maxWidth.f=#PB_Default)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetCellFlags(GNum.i, Row.i, Column.i, Flags.i)
  Declare   SetCellState(GNum.i, Row.i, Label.s, State.i)
  Declare   SetCellText(GNum.i, Row.i, Label.s, Text.s)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
  Declare   SetColorTheme(GNum.i, Theme.i=#Theme_Default, File.s="") 
  Declare   SetColumnAttribute(GNum.i, Column.i, Attrib.i, Value.i)
  Declare   SetColumnFlags(GNum.i, Column.i, Flags.i)
  Declare   SetColumnState(GNum.i, Row.i, Column.i, State.i)
  Declare   SetCurrency(GNum.i, String.s, Column.i=#PB_Ignore)
  Declare   SetFlags(GNum.i, Flags.i)
  Declare   SetFont(GNum.i, FontID.i, Type.i=#False, Column.i=#PB_Ignore)   
  Declare   SetDateAttribute(GNum.i, Column.i, Attrib.i, Value.i)
  Declare   SetDateMask(GNum.i, Mask.s, Column.i=#PB_Ignore)
  Declare   SetHeaderAttribute(GNum.i, Attrib.i, Value.i, Column.i=#PB_Ignore)
  Declare   SetHeaderHeight(GNum.i, Height.i)
  Declare   SetHeaderSort(GNum.i, Column.i, Direction.i=#PB_Sort_Ascending, Flag.i=#True)
  Declare   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
  Declare   SetItemData(GNum.i, Row.i, Value.i)
  Declare   SetItemFont(GNum.i, Row.i, FontID.i, Column.i=#PB_Ignore)
  Declare   SetItemID(GNum.i, Row.i, String.s)
  Declare   SetItemImage(GNum.i, Row.i, Column.i, Width.f, Height.f, Image.i, Align.i=#Left)
  Declare   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore)
  Declare   SetItemText(GNum.i, Row.i, Text.s , Column.i)
  Declare   SetRowsHeight(GNum.i, Height.f)
  Declare   SetState(GNum.i, Row.i=#PB_Default)
  Declare   SetTimeMask(GNum.i, Mask.s, Column.i=#PB_Ignore)
  Declare   Sort(GNum.i, Column.i, Direction.i, Flags.i)
  
  CompilerIf #Enable_MarkContent
    Declare MarkContent(GNum.i, Column.i, Term.s, Color1.i=#PB_Default, Color2.i=#PB_Default, FontID.i=#PB_Default)
  CompilerEndIf
  
  CompilerIf #Enable_ProgressBar
    Declare   SetProgressBarAttribute(GNum.i, Attrib.i, Value.i)
    Declare   SetProgressBarFlags(GNum.i, Flags.i)
  CompilerEndIf
  
  CompilerIf #Enable_CSV_Support
    Declare   ClipBoard(GNum.i, Flags.i=#False, Separator.s=";", DQuote.s=#DQUOTE$)
    Declare   ExportCSV(GNum.i, File.s, Flags.i=#False, Separator.s=";", DQuote.s=#DQUOTE$)
    Declare   ImportCSV(GNum.i, File.s, Flags.i=#False, Separator.s=";", DQuote.s=#DQUOTE$)
  CompilerEndIf
  
EndDeclareModule

Module ListEx

  EnableExplicit
  
  UsePNGImageDecoder()
  
  ;{ OS specific contants
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #ScrollBar_Width  = 18
    CompilerCase #PB_OS_MacOS
      #ScrollBar_Width  = 18
    CompilerCase #PB_OS_Linux
      #ScrollBar_Width  = 18
  CompilerEndSelect ;}
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================  
  
  #DefaultCountry          = "DE"
  #DefaultDateMask         = "%dd.%mm.%yyyy"
  #DefaultTimeMask         = "%hh:%ii:%ss"
  #DefaultCurrency         = "€"
  #DefaultClock            = "Uhr"
  #DefaultTimeSeparator    = ":"
  #DefaultDateSeparator    = "."
  #DefaultDecimalSeperator = ","
  
  #CursorFrequency = 600
  
  #NoFocus = -1
  #NotSelected = -1
  
  #Cursor_Default = #PB_Cursor_Default
  #Cursor_Edit    = #PB_Cursor_Hand
  #Cursor_Sort    = #PB_Cursor_Hand
  #Cursor_Click   = #PB_Cursor_Hand
  #Cursor_Button  = #PB_Cursor_Default
  
  Enumeration ColorFlag 1
    #Focus
    #Click
  EndEnumeration
  
  Enumeration Grades 1
    #Grades_Number
    #Grades_Character
    #Grades_Points
  EndEnumeration
  
  Enumeration 1
    #Key_Return
    #Key_Escape
    #Key_Tab
    #Key_ShiftTab
  EndEnumeration
  
  #Condition1 = 1
  #Condition2 = 2
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================  
  
  ; ===== Structures =====
  
  Structure Cursor_Thread_Structure     ;{ Thread\...
    Num.i
    Active.i
    Exit.i
  EndStructure ;}

  Structure ListEx_Cursor_Structure     ;{ ListEx()\Cursor\...
    Pos.i ; 0: "|abc" / 1: "a|bc" / 2: "ab|c"  / 3: "abc|"
    X.i
    Y.i
    Height.i
    ClipX.i
    State.i
    Frequency.i
    Thread.i
    BackColor.i
  EndStructure ;}
  
  Structure ListEx_Mark_Structure       ;{ ListEx()\Mark()\...
    Term.s
    Color1.i
    Color2.i
    FontID.i
  EndStructure ;}
  
  Structure Country_Structure           ;{ ListEx()\Country\...
    Code.s
    Currency.s
    Clock.s
    TimeSeparator.s
    DateSeperator.s
    DecimalSeperator.s
    DateMask.s
    TimeMask.s
  EndStructure ;}
  
  Structure Grades_Structure            ;{ Grades()\...
    Best.i
    Worst.i
    Term.s
    Flag.i    ; #Number/#Character/#Points
    Map Notation.s()
  EndStructure ;}
  
  Structure Font_Structure              ;{ Font()\...
    ID.i
    Name.s
    Style.i
    Size.i
    Map DPI.i()
  EndStructure ;}
  
  Structure Color_Structure             ;{ ...\Color\...
    Front.i
    Back.i
    Line.i
  EndStructure ;}
  
  Structure Image_Structure             ;{ ListEx()\Rows()\Column('label')\Image\...
    ID.i
    Width.f
    Height.f
    Flags.i
  EndStructure ;}
  
  Structure Cols_Header_Structure       ;{ ListEx()\Cols()\Header\...
    Title.s
    Direction.i
    Sort.i
    Align.i
    FontID.i
    Image.Image_Structure
    FrontColor.i
    BackColor.i
    Flags.i
  EndStructure ;}
  
  Structure ComboBox_Item_Structure     ;{ ListEx()\ComboBox\Column('num')\...
    List Items.s()
  EndStructure ;}
  
  Structure Date_Structure              ;{ ListEx()\Date\Column('num')\...
    Min.i
    Max.i
    Mask.s
  EndStructure ;}
  
  Structure Event_Structure             ;{ ListEx()\Event\...
    Type.i
    Row.i
    Column.i
    Value.s
    State.i
    ID.s
  EndStructure  ;}
  
  Structure Rows_Column_Structure       ;{ ListEx()\Rows()\Column('label')\...
    Value.s
    FontID.i
    State.i ; e.g. CheckBoxes
    Flags.i
    Image.Image_Structure
    Color.Color_Structure
  EndStructure ;}
  
  Structure ListEx_Sort_Structure       ;{ ListEx()\Sort\...
    Column.i
    Label.s
    Direction.i
    Flags.i
  EndStructure ;}
  
  Structure ListEx_AutoResize_Structure ;{ ListEx()\AutoResize\...
    Column.i
    Width.f
    minWidth.f
    maxWidth.f
  EndStructure ;}
  
  Structure ListEx_Color_Structure      ;{ ListEx()\Color\...
    AlternateRow.i
    Front.i
    Back.i
    Line.i
    HeaderFront.i
    HeaderBack.i
    HeaderLine.i
    Canvas.i
    Focus.i
    Edit.i
    ButtonBack.i
    ButtonBorder.i
    ProgressBar.i
    Gradient.i
    Link.i
    ActiveLink.i
    ScrollBar.i
    WrongFront.i
    WrongBack.i
    Mark1.i
    Mark2.i
  EndStructure ;}
  
  Structure ListEx_Col_Structure        ;{ ListEx()\Col\...
    Current.i
    Number.i
    Width.f
    Padding.i
    OffsetX.f
    MouseX.i
    Resize.i
    CheckBoxes.i
  EndStructure ;}
  
  Structure ListEx_Cols_Structure       ;{ ListEx()\Cols()\...
    Type.i
    X.f
    Key.s
    Width.f
    Align.i
    FontID.i
    Mask.s
    MaxWidth.i
    Currency.s
    Flags.i
    FrontColor.i
    BackColor.i
    Header.Cols_Header_Structure
  EndStructure ;}  
  
  Structure ListEx_ProgressBar          ;{ ListEx()\ProgressBar\...
    Minimum.i
    Maximum.i
    Flags.i
  EndStructure ;}
  
  Structure ListEx_String_Structure     ;{ ListEx()\String\...
    Row.i
    Col.i
    X.f
    Y.f
    Width.f
    Height.f
    Label.s
    Text.s
    CursorPos.i
    FontID.i
    Wrong.i
    Flag.i
  EndStructure ;}
  
  Structure ListEx_Button_Structure     ;{ ListEx()\Button\...
    Row.i
    Col.i
    RowID.s
    Value.s
    Label.s
    Pressed.i
    Focus.s
  EndStructure ;}
  
  Structure ListEx_Link_Structure       ;{ ListEx()\Link\...
    Row.i
    Col.i
    RowID.s
    Value.s
    Label.s
    Pressed.i
  EndStructure ;}
  
  Structure ListEx_ComboBox_Structure   ;{ ListEx()\ComboBox\...
    Row.i
    Col.i
    X.f
    Y.f
    Width.f
    Height.f
    Label.s
    Text.s
    State.i
    Flag.i
    Map Column.ComboBox_Item_Structure()
  EndStructure ;}
  
  Structure ListEx_CheckBox_Structure   ;{ ListEx()\CheckBox\...
    Row.i
    Col.i
    Label.s
    State.i
  EndStructure ;}
  
  Structure ListEx_Date_Structure       ;{ ListEx()\String\...
    Row.i
    Col.i
    X.f
    Y.f
    Width.f
    Height.f
    Mask.s
    Label.s
    Flag.i
    Map Column.Date_Structure()
  EndStructure ;}
  
  Structure ListEx_Header_Structure     ;{ ListEx()\Header\...
    Col.i
    Height.f
    Align.i
    FontID.i
  EndStructure ;}   
  
  Structure ListEx_Row_Structure        ;{ ListEx()\Row\...
    Current.i
    CurrentKey.i
    Number.i
    Height.f
    FontID.i
    Offset.i
    OffSetY.f
    Focus.i
    StartSelect.i
    Color.Color_Structure ; Default colors
  EndStructure ;}  
  
  Structure ListEx_Rows_Structure       ;{ ListEx()\Rows()\...
    ID.s
    iData.i
    Y.f
    Height.f
    FontID.i
    Sort.s
    iSort.i
    fSort.f
    State.i
    Color.Color_Structure
    Map Column.Rows_Column_Structure()
  EndStructure ;}  
  
  Structure ListEx_Scroll_Structure     ;{ ListEx()\VScroll\...
    MinPos.f
    MaxPos.f
    Position.f
    Hide.i
  EndStructure ;}
  
  Structure ListEx_Size_Structure       ;{ ListEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Rows.f
    Cols.f
    Flags.i
  EndStructure ;}
  
  Structure ListEx_Window_Structure     ;{ ListEx()\Window\...
    Num.i
    Width.f
    Height.i
  EndStructure ;}

  Structure ListEx_Structure            ;{ ListEx()\...
    
    Window.ListEx_Window_Structure
    
    CanvasNum.i
    ComboNum.i
    DateNum.i
    PopUpID.i
    HScrollNum.i
    VScrollNum.i
    ShortCutID.i

    Editable.i
    ReDraw.i
    Hide.i
    
    CanvasCursor.i
    Cursor.ListEx_Cursor_Structure
    
    Focus.i
    MultiSelect.i
    Changed.i
    FitCols.i
    Flags.i
    
    Size.ListEx_Size_Structure
    
    VScroll.ListEx_Scroll_Structure
    HScroll.ListEx_Scroll_Structure
    AutoResize.ListEx_AutoResize_Structure
    
    Header.ListEx_Header_Structure
    Row.ListEx_Row_Structure
    Col.ListEx_Col_Structure
    
    Color.ListEx_Color_Structure
    
    Sort.ListEx_Sort_Structure

    Button.ListEx_Button_Structure
    CheckBox.ListEx_CheckBox_Structure
    ComboBox.ListEx_ComboBox_Structure
    ProgressBar.ListEx_ProgressBar
    Country.Country_Structure
    Date.ListEx_Date_Structure
    Event.Event_Structure
    Link.ListEx_Link_Structure
    String.ListEx_String_Structure
    
    Map Mark.ListEx_Mark_Structure()
    
    List Cols.ListEx_Cols_Structure()
    List Rows.ListEx_Rows_Structure()
    
  EndStructure ;}
  Global NewMap ListEx.ListEx_Structure()
  
  Global NewMap Font.Font_Structure()
  Global NewMap Grades.Grades_Structure()
  
  Global Thread.Cursor_Thread_Structure

  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Declare AdjustScrollBars_(Force.i=#False)
  Declare BindShortcuts_(Flag.i=#True)
  Declare BindTabulator_(Flag.i=#True)
  Declare CloseString_(Escape.i=#False)
  Declare CloseComboBox_(Escape.i=#False)
  Declare CloseDate_(Escape.i=#False)

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
  
  
  Procedure   IsNumber_(String$)
    Define.i c
    
    String$ = Trim(String$)
    If String$ = "" : ProcedureReturn #False : EndIf
    
    For c=1 To Len(String$)
      Select Asc(Mid(String$, c, 1))
        Case 48 To 57
          Continue
        Case 44, 45, 46
          Continue
        Default
          ProcedureReturn #False
      EndSelect
    Next
  
    If CountString(String$, ".") > 1 Or CountString(String$, "-") > 1
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  
  Procedure   UpdateColumnX_()
    
    ListEx()\Size\Cols = 0
    
    ForEach ListEx()\Cols()
      If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
      ListEx()\Cols()\X  = ListEx()\Size\Cols
      ListEx()\Size\Cols + ListEx()\Cols()\Width
    Next  
     
  EndProcedure
  
  Procedure   UpdateRowY_()
    
    ListEx()\Size\Rows   = 0
    ListEx()\Row\OffSetY = 0
    
    ForEach ListEx()\Rows()
      
      If ListIndex(ListEx()\Rows()) < ListEx()\Row\Offset
        ListEx()\Row\OffSetY + ListEx()\Rows()\Height
      EndIf
      
      
      If ListEx()\Flags & #NoRowHeader
        ListEx()\Rows()\Y  = ListEx()\Size\Rows
      Else
        ListEx()\Rows()\Y  = ListEx()\Size\Rows + ListEx()\Header\Height
      EndIf
      
      ListEx()\Size\Rows + ListEx()\Rows()\Height
      
    Next
    
  EndProcedure
  
  Procedure.i GetPageRows_()    ; all visible Rows
    ProcedureReturn Int((ListEx()\Size\Height - ListEx()\Header\Height) / ListEx()\Row\Height)
  EndProcedure  
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  Procedure.i GetRow_(Y.f)
    
    Y = DesktopUnscaledY(Y)
    
    If Y > ListEx()\Size\Y And Y < ListEx()\Size\Rows + ListEx()\Header\Height
      
      If Y < ListEx()\Header\Height
        ProcedureReturn #Header 
      Else
        
        ListEx()\Row\OffsetY = 0
        
        ForEach ListEx()\Rows()
          
          If ListIndex(ListEx()\Rows()) < ListEx()\Row\Offset
            ListEx()\Row\OffsetY + ListEx()\Rows()\Height
          Else
            If ListEx()\Rows()\Y > Y + ListEx()\Row\OffsetY
              ProcedureReturn ListIndex(ListEx()\Rows()) - 1
            EndIf
          EndIf
        Next
        
        ProcedureReturn ListIndex(ListEx()\Rows())
      EndIf
      
    Else
      ProcedureReturn #NotValid
    EndIf
    
  EndProcedure
  
  Procedure.i GetColumn_(X.i)
    
    X = DesktopUnscaledX(X)
    
    If X > ListEx()\Size\X And X < ListEx()\Size\Cols
      
      ForEach ListEx()\Cols()
        If ListEx()\Cols()\X >= X + ListEx()\Col\OffsetX
          ProcedureReturn ListIndex(ListEx()\Cols()) - 1
        EndIf
      Next
      
      ProcedureReturn ListIndex(ListEx()\Cols())
    Else
      ProcedureReturn #NotValid
    EndIf
    
  EndProcedure
  
  Procedure.s DeleteStringPart_(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf
    
    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure
  
  Procedure.i AddItem_(Row.i, Text.s, Label.s, Flags.i) 
    Define.i i, nc, FitColumn, Result
    
    ;{ Add item
    Select Row
      Case #FirstItem
        FirstElement(ListEx()\Rows())
        Result = InsertElement(ListEx()\Rows()) 
      Case #LastItem
        LastElement(ListEx()\Rows())
        Result = AddElement(ListEx()\Rows())
      Default
        If SelectElement(ListEx()\Rows(), Row)
          Result = InsertElement(ListEx()\Rows()) 
        Else
          LastElement(ListEx()\Rows())
          Result = AddElement(ListEx()\Rows())
        EndIf
    EndSelect ;}
   
    If Result
      
      ListEx()\Row\Number    = ListSize(ListEx()\Rows())
      ListEx()\Rows()\ID     = Label
      ListEx()\Rows()\Height = ListEx()\Row\Height
      ListEx()\Rows()\Color\Front = #PB_Default
      ListEx()\Rows()\Color\Back  = #PB_Default
      ListEx()\Rows()\Color\Line  = ListEx()\Color\Line
      
      If Text <> ""
        
        If ListEx()\Flags & #NumberedColumn Or ListEx()\Flags & #CheckBoxes
          nc = 0
        Else
          nc = 1
        EndIf
        
        For i=1 To CountString(Text, #LF$) + 1
          If SelectElement(ListEx()\Cols(), i - nc)
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value = StringField(Text, i, #LF$)
          EndIf
        Next
        
      EndIf

    EndIf

    ProcedureReturn ListIndex(ListEx()\Rows())
  EndProcedure 
  
  ;- _____ CSV - Support _____
  
  CompilerIf #Enable_CSV_Support
    
    Procedure.s Export_CSV_Header(Separator.s, DQuote.s)
      Define.s CSV$ 
      
      ForEach ListEx()\Cols()
        
        If ListIndex(ListEx()\Cols()) = 1
          CSV$ = DQuote + ListEx()\Cols()\Header\Title
        Else  
          CSV$ + DQuote + Separator + DQuote + ListEx()\Cols()\Header\Title
        EndIf
      Next

      ProcedureReturn CSV$ + DQuote
    EndProcedure
    
    Procedure.s Export_CSV_Row(Separator.s, DQuote.s)
      Define.s Key$, CSV$ 
      
      ForEach ListEx()\Cols()
        Key$ = ListEx()\Cols()\Key
        If ListIndex(ListEx()\Cols()) = 1
          CSV$ = DQuote + ListEx()\Rows()\Column(Key$)\Value
        Else  
          CSV$ + DQuote + Separator + DQuote + ListEx()\Rows()\Column(Key$)\Value
        EndIf
      Next

      ProcedureReturn CSV$ + DQuote
    EndProcedure
    
    Procedure.i Import_CSV_Header(String.s, Separator.s, DQuote.s)
      Define.i idx = 1
      Define.s Column$
      
      String = ReplaceString(Trim(String, DQuote), DQuote + Separator + DQuote, #LF$)
      
      ForEach ListEx()\Cols()
        
        Column$ = StringField(String, idx, #LF$)
        If Column$
          ListEx()\Cols()\Header\Title = Column$
        EndIf  
        
        idx + 1
      Next
    
    EndProcedure
    
    Procedure.i Import_CSV_Row(String.s, Separator.s, DQuote.s)

      String = ReplaceString(String, DQuote + Separator + DQuote, #LF$)
      String = Trim(String, DQuote)
      
      ProcedureReturn AddItem_(-1, String, "", #False)
    EndProcedure
    
  CompilerEndIf  
  
  ;- _____ Check Content _____
  
  CompilerIf #Enable_Validation
    
    Procedure   LoadGrades()
      
      If AddMapElement(Grades(), "DE")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 1
        Grades()\Worst  = 6
        Grades()\Term   = "Beyond{3|4}"
      EndIf
      
      If AddMapElement(Grades(), "AT")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 1
        Grades()\Worst  = 5
        Grades()\Term   = "Beyond{3|3}"
      EndIf
      
      If AddMapElement(Grades(), "IT")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 10
        Grades()\Worst  = 0
        Grades()\Term   = "Beyond{6|7}"
      EndIf
      
      If AddMapElement(Grades(), "ES")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 10
        Grades()\Worst  = 0
        Grades()\Term   = "Beyond{5|6}"
      EndIf
      
      If AddMapElement(Grades(), "US")
        Grades()\Flag   = #Grades_Character
        Grades()\Best   = 1
        Grades()\Worst  = 5
        Grades()\Term   = "Beyond{3|4}"
        Grades()\Notation("1") = "A"
        Grades()\Notation("2") = "B"
        Grades()\Notation("3") = "C"
        Grades()\Notation("4") = "D"
        Grades()\Notation("5") = "F"
      EndIf
      
      If AddMapElement(Grades(), "GB")
        Grades()\Flag   = #Grades_Character
        Grades()\Best   = 1
        Grades()\Worst  = 6
        Grades()\Term   = "Beyond{3|5}"
        Grades()\Notation("1") = "A"
        Grades()\Notation("2") = "B"
        Grades()\Notation("3") = "C"
        Grades()\Notation("4") = "D"
        Grades()\Notation("5") = "E"
        Grades()\Notation("6") = "F"
      EndIf
      
      If AddMapElement(Grades(), "FR")
        Grades()\Flag   = #Grades_Points
        Grades()\Best   = 20
        Grades()\Worst  = 0
        Grades()\Term   = "Beyond{10|14}"
      EndIf
      
    EndProcedure
  
    Procedure.s ConvertUSTime_(Time.s, Seperator.s=":")
      Define apm$, Second$, Hour.i
      
      apm$  = LCase(RemoveString(StringField(Time, 2, " "), "."))
      Time = ReplaceString(StringField(Time, 1, " "), ".", " ")
      
      Hour = Val(StringField(Time, 1, Seperator))
      If CountString(apm$, "pm") = 1
        Hour + 12
      EndIf
      
      Second$ = StringField(Time, 3, Seperator)
      If Trim(Second$) = ""
        ProcedureReturn Str(Hour) + Seperator + StringField(Time, 2, Seperator)
      Else
        ProcedureReturn Str(Hour) + Seperator + StringField(Time, 2, Seperator) + Seperator + Second$
      EndIf
      
    EndProcedure

    Procedure.s GetTimeString_(Time.s, Mask.s, Seperator.s=":") 
      Define i.i, Hour$, Minute$, Second$, Parse$
      
      Parse$ = ListEx()\Cols()\Mask
      If Parse$ = "" : Parse$ = ListEx()\Country\TimeMask : EndIf
      
      Time  = ConvertUSTime_(Time)
      
      For i=1 To 3
        Select StringField(Parse$, i, Seperator)
          Case "%hh"
            Hour$   = RSet(StringField(Time, i, Seperator), 2, " ")
          Case "%ii"
            Minute$ = RSet(StringField(Time, i, Seperator), 2, "0")
          Case "%ss"
            Second$ = RSet(StringField(Time, i, Seperator), 2, "0")
        EndSelect
      Next
      
      Time = ReplaceString(Mask, "%0h", Hour$)
      Time = ReplaceString(Time, "%hh", Hour$)
      Time = ReplaceString(Time, "%ii", Minute$)
      Time = ReplaceString(Time, "%ss", Second$)
      
      ProcedureReturn Time
    EndProcedure    
  
    Procedure.i IsInteger(Value.s, UnSigned=#False)
      Define.i i
      
      For i=1 To Len(Value)
        Select Asc(Mid(Value, i, 1))
          Case 48 To 57
            Continue
          Case 43, 45
            If UnSigned
              ProcedureReturn #False
            EndIf
          Default
            ProcedureReturn #False
        EndSelect    
      Next
      
      ProcedureReturn #True
    EndProcedure
  
    Procedure.i IsFloat(Value.s)
      Define.i i
      
      Value = ReplaceString(Value, ",", ".") 
      
      If CountString(Value, ".") <> 1 : ProcedureReturn #False : EndIf
      
      For i=1 To Len(Value)
        Select Asc(Mid(Value, i, 1))
          Case 48 To 57 ; 0 - 9
            Continue
          Case 43, 45   ; + / -
            Continue
          Case 46
            Continue
          Default
            ProcedureReturn #False
        EndSelect    
      Next
      
      ProcedureReturn #True
    EndProcedure
  
    Procedure.i IsCash(Value.s)
      
      Value = Trim(RemoveString(Value, ListEx()\Cols()\Currency))
      Value = ReplaceString(Value, ",", ".")
      
      If IsFloat(Value)
        If Len(StringField(Value, 2, ".")) = 2
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      Else
        ProcedureReturn #False
      EndIf
      
    EndProcedure
  
    Procedure.i IsGrade(Value.s)
      
      If FindMapElement(Grades(), ListEx()\Country\Code)
        
        If Grades()\Flag & #Grades_Number Or Grades()\Flag & #Grades_Points ;{ Grades are numbers
          
          If IsInteger(Value, #True) = #False : ProcedureReturn #False : EndIf
          
          If Grades()\Best < Grades()\Worst  ; 1 - 6
            If Val(Value) >= Grades()\Best And Val(Value) <= Grades()\Worst
              ProcedureReturn #True
            EndIf 
          Else ; 12 - 0
            If Val(Value) >= Grades()\Worst And Val(Value) <= Grades()\Best
              ProcedureReturn #True
            EndIf
          EndIf
          ProcedureReturn #False
          ;}
        ElseIf Grades()\Flag & #Grades_Character ;{ Grades are characters
          If Grades()\Best < Grades()\Worst
            If Value >= Grades()\Notation(Str(Grades()\Best)) And Value  <= Grades()\Notation(Str(Grades()\Worst))
              ProcedureReturn #True
            EndIf 
          Else
            If Value >= Grades()\Notation(Str(Grades()\Worst)) And Value <= Grades()\Notation(Str(Grades()\Best))
              ProcedureReturn #True
            EndIf
          EndIf
          ProcedureReturn #False
          ;}
        EndIf
        
        ProcedureReturn #True
      Else
        ProcedureReturn #True
      EndIf
      
    EndProcedure
  
    Procedure IsTime(Value.s)
      Define Time$, Hour.s, Minute.s, Second.s
      
      Time$ = Trim(RemoveString(Value, ListEx()\Country\Clock))
      Time$ = GetTimeString_(Time$, "%hh|%ii|%ss")
      
      Hour   = StringField(Time$, 1, "|")
      Minute = StringField(Time$, 2, "|")
      Second = StringField(Time$, 3, "|")
      
      If IsInteger(Hour,   #True) = #False Or Val(Hour)   > 24 : ProcedureReturn #False : EndIf
      If IsInteger(Minute, #True) = #False Or Val(Minute) > 59 : ProcedureReturn #False : EndIf
      If IsInteger(Second, #True) = #False Or Val(Second) > 59 : ProcedureReturn #False : EndIf
      
      ProcedureReturn #True
    EndProcedure
  
    Procedure.i IsContentValid_(Value.s)
      
      If Value = "" : ProcedureReturn #True : EndIf
      
      If ListEx()\Cols()\Flags & #Number
        ProcedureReturn IsInteger(Value, #True) 
      ElseIf ListEx()\Cols()\Flags & #Integer
        ProcedureReturn IsInteger(Value) 
      ElseIf ListEx()\Cols()\Flags & #Float
        ProcedureReturn IsFloat(Value)
      ElseIf ListEx()\Cols()\Flags & #Grades
        ProcedureReturn IsGrade(Value)
      ElseIf ListEx()\Cols()\Flags & #Cash
        ProcedureReturn IsCash(Value)
      ElseIf ListEx()\Cols()\Flags & #Time
        ProcedureReturn IsTime(Value)
      EndIf  
      
      ProcedureReturn #True
    EndProcedure
  
  CompilerElse
    
    Procedure.i IsContentValid_(Value.s)
      ProcedureReturn #True
    EndProcedure
    
  CompilerEndIf
  
  ;- _____ Mark Content _____
  
  CompilerIf #Enable_MarkContent
    
    Procedure   MarkContent_(Term.s, Color1.i, Color2.i, FontID.i)
      
      If AddMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
       
        ListEx()\Mark()\Term   = Term
        
        If Color1 = #PB_Default
          ListEx()\Mark()\Color1 = ListEx()\Color\Mark1
        Else 
          ListEx()\Mark()\Color1 = Color1
        EndIf
        
        If Color2 = #PB_Default
          ListEx()\Mark()\Color2 = ListEx()\Color\Mark2
        Else 
          ListEx()\Mark()\Color2 = Color2
        EndIf
        
        ListEx()\Mark()\FontID = FontID

        ListEx()\Cols()\Flags | #MarkContent
        
      EndIf
  
    EndProcedure
    
    Procedure.s ExtractTag_(Text.s, Left.s, Right.s)
      Define.i idxL, idxR
    
      idxL = FindString(Text, Left,  1)
      idxR = FindString(Text, Right, idxL + 1)
      
      If idxL And idxR
        idxL + Len(Left)
        ProcedureReturn Mid(Text, idxL, idxR-idxL)
      EndIf
    
    EndProcedure
    
    Procedure.i CompareValues_(Value1.s, Compare.s, Value2.s, Flag.i)
      
      Select Flag
        Case #Number, #Integer, #Grades ;{
          Select Compare
            Case "="
              If Val(Value1) =  Val(Value2) : ProcedureReturn #True : EndIf
            Case "<"
              If Val(Value1) <  Val(Value2) : ProcedureReturn #True : EndIf
            Case ">"
              If Val(Value1) >  Val(Value2) : ProcedureReturn #True : EndIf
            Case ">="
              If Val(Value1) >= Val(Value2) : ProcedureReturn #True : EndIf
            Case "<="
              If Val(Value1) <= Val(Value2) : ProcedureReturn #True : EndIf
            Case "<>"
              If Val(Value1) <> Val(Value2) : ProcedureReturn #True : EndIf
          EndSelect ;}        
        Case #Float, #Cash              ;{
          Value1 = ReplaceString(Value1, ListEx()\Country\DecimalSeperator, ".")
          Value2 = ReplaceString(Value2, ListEx()\Country\DecimalSeperator, ".")
          Select Compare
            Case "="
              If ValF(Value1) =  ValF(Value2) : ProcedureReturn #True : EndIf
            Case "<"
              If ValF(Value1) <  ValF(Value2) : ProcedureReturn #True : EndIf
            Case ">"
              If ValF(Value1) >  ValF(Value2) : ProcedureReturn #True : EndIf
            Case ">="
              If ValF(Value1) >= ValF(Value2) : ProcedureReturn #True : EndIf
            Case "<="
              If ValF(Value1) <= ValF(Value2) : ProcedureReturn #True : EndIf
            Case "<>"
              If ValF(Value1) <> ValF(Value2) : ProcedureReturn #True : EndIf
          EndSelect ;}
        Default                         ;{
          Select Compare
            Case "="
              If Value1 =  Value2 : ProcedureReturn #True : EndIf
            Case "<"
              If Value1 <  Value2 : ProcedureReturn #True : EndIf
            Case ">"
              If Value1 >  Value2 : ProcedureReturn #True : EndIf
            Case ">="
              If Value1 >= Value2 : ProcedureReturn #True : EndIf
            Case "<="
              If Value1 <= Value2 : ProcedureReturn #True : EndIf
            Case "<>"
              If Value1 <> Value2 : ProcedureReturn #True : EndIf
          EndSelect ;}
      EndSelect
    
      ProcedureReturn #False
    EndProcedure  
    
    Procedure.i IsMarked_(Content.s, Term.s, Flag.i)
      ; Flag: #Number, #Integer, #Grades, #Float, #Cash
      Define.i Result1, Result2, Row, Column
      Define   Type$, Expr$, Compare$, Link$
      Type$ = StringField(Term, 1, "{")
      Expr$ = ExtractTag_(Term, "{", "}")
      Link$ = ExtractTag_(Term, "[", "]")
      
      If Link$ ;{ Link to another cell
        
        Row    = ListIndex(ListEx()\Rows())
        Column = ListIndex(ListEx()\Cols())
        
        Select Left(Link$, 1) 
          Case "R"
            Row    = Val(LTrim(Link$, "R"))
          Case "C"
            Column = Val(LTrim(Link$, "C"))
          Default
            Row    = Val(StringField(Link$, 1, ":"))
            Column = Val(StringField(Link$, 2, ":"))
        EndSelect
        
        PushListPosition(ListEx()\Rows())
        
        If SelectElement(ListEx()\Rows(), Row)
          PushListPosition(ListEx()\Cols())
          If SelectElement(ListEx()\Cols(), Column)
            Content = ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value
          EndIf
          PopListPosition(ListEx()\Cols())
        EndIf 
        
        PopListPosition(ListEx()\Rows())
        ;}
      EndIf
        
      Select UCase(Type$)
        Case "NEGATIVE", "NEGATIV"  ;{ NEGATIVE
          If CompareValues_(Content, "<", "0", Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "POSITIVE", "POSITIV"  ;{ POSITIVE
          If CompareValues_(Content, ">", "0", Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "EQUAL", "GLEICH"      ;{ EQUAL{3.95} / EQUAL{String}
          If CompareValues_(Content, "=", Expr$, Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "LIKE"                 ;{ LIKE{*end} / LIKE{start*} / LIKE{*part*}
          If Left(Expr$, 1) = "*" And Right(Expr$, 1) = "*"
            Expr$ = Trim(Expr$, "*")
            If CountString(Content, Expr$) : ProcedureReturn #Condition1 : EndIf
          ElseIf Left(Expr$, 1)  = "*"
            Expr$ = LTrim(Expr$, "*")
            If Right(Content, Len(Expr$)) = Expr$ : ProcedureReturn #Condition1 : EndIf
          ElseIf Right(Expr$, 1) = "*"
            Expr$ = RTrim(Expr$, "*")
            If Left(Content, Len(Expr$))  = Expr$ : ProcedureReturn #Condition1 : EndIf
          Else
            If Left(Content, Len(Expr$))  = Expr$ : ProcedureReturn #Condition1 : EndIf
          EndIf ;}
        Case "COMPARE", "VERGLEICH" ;{ COMPARE{<|12}  =>  [?] < 12
          If CompareValues_(Content, StringField(Expr$, 1, "|"), StringField(Expr$, 2, "|"), Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "BETWEEN", "ZWISCHEN"  ;{ BETWEEN{10|20}  =>  10 < [?] < 20
          Result1 = CompareValues_(Content, ">", StringField(Expr$, 1, "|"), Flag)
          Result2 = CompareValues_(Content, "<", StringField(Expr$, 2, "|"), Flag)
          If Result1 And Result2
            ProcedureReturn #Condition1
          EndIf ;}
        Case "BEYOND"               ;{ BEYOND{3|4}  =>  3 > [?] OR [?] > 4
          Result1 = CompareValues_(Content, "<", StringField(Expr$, 1, "|"), Flag)
          Result2 = CompareValues_(Content, ">", StringField(Expr$, 2, "|"), Flag)
          If Result1
            ProcedureReturn #Condition1
          ElseIf Result2
            ProcedureReturn #Condition2
          EndIf ;}
        Case "CHOICE", "AUSWAHL"    ;{ CHOICE{m|f}[C4]
          Result1 = CompareValues_(Content, "=", StringField(Expr$, 1, "|"), Flag)
          Result2 = CompareValues_(Content, "=", StringField(Expr$, 2, "|"), Flag)
          If Result1
            ProcedureReturn #Condition1
          ElseIf Result2
            ProcedureReturn #Condition2
          EndIf ;}
      EndSelect
      
      ProcedureReturn #False
    EndProcedure
    
  CompilerEndIf   
  
  ;- _____ Sorting _____
  
  Procedure.f GetCashFloat_(String.s, Currency.s)

    String = ReplaceString(String, ",", ".")
    String = RemoveString(String, Currency)
    
    ProcedureReturn ValF(Trim(String)) 
  EndProcedure
  
  Procedure.s SortDEU_(Text.s, Flags.i=#Lexikon) ; german charakters (DIN 5007)
    
    If Flags & #Namen
      Text = ReplaceString(Text, "Ä", "Ae")
      Text = ReplaceString(Text, "Ö", "Oe")
      Text = ReplaceString(Text, "Ü", "Ue")
      Text = ReplaceString(Text, "ä", "ae")
      Text = ReplaceString(Text, "ö", "oe")
      Text = ReplaceString(Text, "ü", "ue")
      Text = ReplaceString(Text, "ß", "ss")
    ElseIf Flags & #Lexikon Or Flags & #Deutsch
      Text = ReplaceString(Text, "Ä", "A")
      Text = ReplaceString(Text, "Ö", "O")
      Text = ReplaceString(Text, "Ü", "U")
      Text = ReplaceString(Text, "ä", "a")
      Text = ReplaceString(Text, "ö", "o")
      Text = ReplaceString(Text, "ü", "u")
      Text = ReplaceString(Text, "ß", "ss")
    EndIf
    
    ProcedureReturn Text
  EndProcedure 
  
  Procedure   SortColumn_()
    Define.s String$
    
    If ListEx()\Sort\Flags & #SortNumber       ;{ Sort number (integer)
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\iSort = Val(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\iSort), #PB_Integer)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortFloat    ;{ Sort number (float)
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\fSort = ValF(ReplaceString(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value, ",", "."))
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\fSort), #PB_Float)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortDate     ;{ Sort date   (integer)

      If ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
        String$ = ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
      Else  
        String$ = ListEx()\Date\Mask
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\iSort = ParseDate(String$, ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\iSort), #PB_Integer)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortBirthday ;{ Sort birthday   (string)

      If ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
        String$ = ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
      Else  
        String$ = ListEx()\Date\Mask
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\Sort = FormatDate("%mm%dd", ParseDate(String$, ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value))
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\Sort), #PB_String)
      ;}  
    ElseIf ListEx()\Sort\Flags & #SortCash     ;{ Sort cash   (float)

      String$ = ListEx()\Country\Currency
      If SelectElement(ListEx()\Cols(), ListEx()\Sort\Column)
        If ListEx()\Cols()\Currency : String$ = ListEx()\Cols()\Currency : EndIf
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\fSort = GetCashFloat_(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value, String$)
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\fSort), #PB_Float)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortTime     ;{ Sort time   (integer)
      
      String$ = ListEx()\Country\TimeMask
      If SelectElement(ListEx()\Cols(), ListEx()\Sort\Column)
        If ListEx()\Cols()\Mask : String$ = ListEx()\Cols()\Mask : EndIf
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\iSort = ParseDate(String$, ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\iSort), #PB_Integer)
      ;}
    Else                                       ;{ Sort text   (string)
      
      ForEach ListEx()\Rows()
        If ListEx()\Sort\Flags & #Deutsch
          ListEx()\Rows()\Sort = SortDEU_(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
        Else
          ListEx()\Rows()\Sort = ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value
        EndIf
      Next  
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\Sort), #PB_String)
      ;}
    EndIf
  
  EndProcedure
  
  ;- __________ Theme __________ 
  
  Procedure   ColorTheme_(Theme.i)

    Select Theme
      Case #Theme_Blue
        
        ListEx()\Color\Front        = 0
        ListEx()\Color\Back         = 16645114
        ListEx()\Color\Line         = 13092807
        ListEx()\Color\HeaderFront  = 4270875
        ListEx()\Color\HeaderBack   = 14599344
        ListEx()\Color\HeaderLine   = 8750469
        ListEx()\Color\ProgressBar  = 11369795
        ListEx()\Color\Gradient     = 13874833
        ListEx()\Color\AlternateRow = ListEx()\Color\Back
        
      Case #Theme_Green
        
        ListEx()\Color\Front        = 0
        ListEx()\Color\Back         = 16383222
        ListEx()\Color\Line         = 13092807
        ListEx()\Color\HeaderFront  = 2374163
        ListEx()\Color\HeaderBack   = 6674533
        ListEx()\Color\HeaderLine   = 8750469
        ListEx()\Color\ProgressBar  = 2263842
        ListEx()\Color\Gradient     = 7527538
        ListEx()\Color\AlternateRow = ListEx()\Color\Back
        
      Default
        
        ListEx()\Color\Front        = $000000
        ListEx()\Color\Back         = $FFFFFF
        ListEx()\Color\Line         = $E3E3E3
        ListEx()\Color\HeaderFront  = $000000
        ListEx()\Color\HeaderBack   = $FAFAFA
        ListEx()\Color\HeaderLine   = $A0A0A0
        ListEx()\Color\AlternateRow = ListEx()\Color\Back

        CompilerSelect  #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
          ListEx()\Color\HeaderFront  = GetSysColor_(#COLOR_WINDOWTEXT)
          ListEx()\Color\HeaderLine   = GetSysColor_(#COLOR_3DSHADOW)
          ListEx()\Color\Front        = GetSysColor_(#COLOR_WINDOWTEXT)
          ListEx()\Color\Back         = GetSysColor_(#COLOR_WINDOW)
          ListEx()\Color\Line         = GetSysColor_(#COLOR_3DLIGHT)
        CompilerCase #PB_OS_MacOS
          ListEx()\Color\HeaderFront  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
          ListEx()\Color\HeaderLine   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          ListEx()\Color\Front        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
          ListEx()\Color\Back         = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
          ListEx()\Color\Line         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
        CompilerCase #PB_OS_Linux
       
      CompilerEndSelect
    EndSelect
    
  EndProcedure  
  
  Procedure   SetColor_(ColorTyp.i, Value.i, Column.i=#PB_Ignore)

    Select ColorTyp
      Case #ButtonBorderColor
        ListEx()\Color\ButtonBorder = Value
      Case #ActiveLinkColor  
        ListEx()\Color\ActiveLink   = Value
      Case #FrontColor
        If Column = #PB_Ignore
          ListEx()\Color\Front      = Value
        Else
          If SelectElement(ListEx()\Cols(), Column)
            ListEx()\Cols()\FrontColor = Value
          EndIf
        EndIf 
      Case #BackColor
        If Column = #PB_Ignore
          ListEx()\Color\Back = Value
        Else
          If SelectElement(ListEx()\Cols(), Column)
            ListEx()\Cols()\BackColor = Value
          EndIf
        EndIf 
      Case #ButtonColor  
        ListEx()\Color\ButtonBack   = Value
      Case #ProgressBarColor
        ListEx()\Color\ProgressBar  = Value
      Case #GradientColor
        ListEx()\Color\Gradient     = Value
      Case #LineColor
        ListEx()\Color\Line         = Value
      Case #FocusColor
        ListEx()\Color\Focus        = Value
      Case #EditColor
        ListEx()\Color\Edit         = Value
      Case #LinkColor
        ListEx()\Color\Link         = Value
      Case #HeaderFrontColor
        ListEx()\Color\HeaderFront  = Value
      Case #HeaderBackColor
        ListEx()\Color\HeaderBack   = Value
      Case #HeaderLineColor
        ListEx()\Color\HeaderLine   = Value
      Case #GadgetBackColor
        ListEx()\Color\Canvas       = Value
      Case #AlternateRowColor
        ListEx()\Color\AlternateRow = Value
    EndSelect

  EndProcedure
  
  ;- __________ Drawing __________ 
 
  Procedure.f GetAlignOffset_(Text.s, Width.f, Flags.i)
    Define.f Offset
    
    If Flags & #Right
      Offset = Width - TextWidth(Text) - dpiX(4)
    ElseIf Flags & #Center
      Offset = (Width - TextWidth(Text)) / 2
    Else
      Offset = dpiX(4)
    EndIf
    
    If Offset < 0 : Offset = 0 : EndIf
    
    ProcedureReturn Offset
  EndProcedure
  
  Procedure.i CurrentColumn_()
    ProcedureReturn ListIndex(ListEx()\Cols())
  EndProcedure  
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  
  Procedure   FitColumns_()
    Define.i Flags, imgWidth, FontID
    Define.s Key$, Text$
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      PushListPosition(ListEx()\Rows())
      PushListPosition(ListEx()\Cols())
      
      ;{ _____ Header _____
      If ListEx()\Flags & #NoRowHeader = #False
  
        ForEach ListEx()\Cols()
          
          If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
          
          If ListEx()\Cols()\Header\FontID = #PB_Default
            DrawingFont(ListEx()\Header\FontID)
          Else
            DrawingFont(ListEx()\Cols()\Header\FontID)
          EndIf
          
          If ListEx()\Cols()\Header\Flags & #Image 
            ListEx()\Cols()\MaxWidth = TextWidth(ListEx()\Cols()\Header\Title) + ListEx()\Cols()\Header\Image\Width + 4
          Else
            ListEx()\Cols()\MaxWidth = TextWidth(ListEx()\Cols()\Header\Title)
          EndIf          

        Next
        
      EndIf ;}
      
      DrawingFont(ListEx()\Row\FontID)

      ; _____ Rows _____

      ForEach ListEx()\Rows()
        
        If ListEx()\Rows()\FontID : DrawingFont(ListEx()\Rows()\FontID) : EndIf
        
        DrawingMode(#PB_2DDrawing_Default)
        
        ;{ Columns of current row
        ForEach ListEx()\Cols()
          
          If ListEx()\Cols()\Flags & #Hide : Continue : EndIf

          Key$ = ListEx()\Cols()\Key
          If Key$ = "" : Key$ = Str(ListIndex(ListEx()\Cols())) : EndIf
          
          Flags = ListEx()\Rows()\Column(Key$)\Flags
          
          If ListEx()\Cols()\FontID
            FontID = ListEx()\Cols()\FontID
          ElseIf ListEx()\Rows()\FontID
            FontID = ListEx()\Rows()\FontID
          Else
            FontID = ListEx()\Row\FontID
          EndIf
          If FontID : DrawingFont(FontID) : EndIf
          
          If CurrentColumn_() = 0 And ListEx()\Flags & #NumberedColumn ;{ Numbering column 0
            
            If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
            
            Text$ = Str(ListIndex(ListEx()\Rows()) + 1)
            If TextWidth(Text$) > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth(Text$) : EndIf
            
            If Flags & #CellFont : DrawingFont(FontID) : EndIf
            
            ;}
          Else  
            
            Flags = ListEx()\Rows()\Column(Key$)\Flags
           
            If ListEx()\Cols()\Flags & #CheckBoxes      ;{ CheckBox
              If ListEx()\Cols()\Width > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = ListEx()\Cols()\Width : EndIf
              ;}
            ElseIf ListEx()\Cols()\Flags & #Buttons     ;{ Button
              
              If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              
              If Flags & #Image
                If TextWidth(Text$) + ListEx()\Rows()\Column(Key$)\Image\Width > ListEx()\Cols()\MaxWidth
                  ListEx()\Cols()\MaxWidth = TextWidth(Text$) + ListEx()\Rows()\Column(Key$)\Image\Width
                EndIf
              Else
                If TextWidth(Text$) > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth(Text$) : EndIf
              EndIf
              
              If Flags & #CellFont : DrawingFont(FontID) : EndIf
              ;}
            ElseIf ListEx()\Cols()\Flags & #ProgressBar ;{ ProgressBar
              If ListEx()\Cols()\Width > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = ListEx()\Cols()\Width : EndIf
              ;}
            ElseIf Flags & #Image                       ;{ Image

              imgWidth = ListEx()\Rows()\Column(Key$)\Image\Width + 4
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""
                
                If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
                
                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsMarked_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                If TextWidth(Text$) + imgWidth > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth(Text$) + imgWidth : EndIf
                If Flags & #CellFont : DrawingFont(FontID) : EndIf
                
              Else
                
                If imgWidth > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = imgWidth : EndIf

              EndIf  
              ;}
            Else                                        ;{ Text
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""

                If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
                
                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsMarked_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                If TextWidth(Text$) > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth(Text$) : EndIf
                
                If Flags & #CellFont : DrawingFont(FontID) : EndIf
                
              EndIf
              ;}  
            EndIf

          EndIf
          
        Next ;}
        
      Next
      
      ListEx()\Size\Cols = 0
      
      ForEach ListEx()\Cols()
        
        If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
      
        If ListEx()\Cols()\Flags & #FitColumn
          ListEx()\Cols()\Width = ListEx()\Cols()\MaxWidth + (ListEx()\Col\Padding * 2)
        EndIf  
        
        ListEx()\Cols()\X  = ListEx()\Size\Cols
        ListEx()\Size\Cols + ListEx()\Cols()\Width
        
      Next


      PopListPosition(ListEx()\Cols())
      PopListPosition(ListEx()\Rows())

      StopDrawing()
    EndIf  
  
  EndProcedure
  
  
  Procedure.i Arrow_(X.i, Y.i, Width.i, Height.i, Direction.i, Color.i=#PB_Default)
    Define.i aX, aY, aWidth, aHeight
    
    If Color = #PB_Default : Color = BlendColor_($000000, ListEx()\Color\HeaderBack) : EndIf
    
    aWidth  = dpiX(8)
    aHeight = dpiX(4)
    
    aX = X + Width - aWidth - dpiX(5)
    aY = Y + (Height - aHeight) / 2
    
    If aWidth < Width And aHeight < Height 
    
      If Direction & #PB_Sort_Descending
        
        DrawingMode(#PB_2DDrawing_Default)
        Line(aX, aY, aWidth, 1, Color)
        LineXY(aX, aY, aX + (aWidth / 2), aY + aHeight, Color)
        LineXY(aX + (aWidth / 2), aY + aHeight, aX + aWidth, aY, Color)
        FillArea(aX + (aWidth / 2), aY + dpiY(2), -1, Color)

      Else

        DrawingMode(#PB_2DDrawing_Default)
        Line(aX, aY + aHeight, aWidth, 1, Color)
        LineXY(aX, aY + aHeight, aX + (aWidth / 2), aY, Color)
        LineXY(aX + (aWidth / 2), aY, aX + aWidth, aY + aHeight, Color)
        FillArea(aX + (aWidth / 2), aY + aHeight - dpiY(2), -1, Color)
        
      EndIf
      
    EndIf
    
  EndProcedure

  Procedure.i Button_(X.f, Y.f, Width.f, Height.f, Text.s, ColorFlag.i=#False, TextColor.i=#PB_Default, FontID.i=#PB_Default)
    Define.f textX, textY
    Define.i BackColor, BorderColor
    
    If TextColor = #PB_Default : TextColor = ListEx()\Color\Front : EndIf
    
    If ColorFlag & #Click
      BackColor   = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 20)
      BorderColor = ListEx()\Color\Focus
    ElseIf ColorFlag & #Focus
      BackColor   = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10)
      BorderColor = ListEx()\Color\Focus
    Else  
      BackColor   = ListEx()\Color\ButtonBack
      BorderColor = ListEx()\Color\ButtonBorder
    EndIf
    
    If FontID = #PB_Default
      DrawingFont(ListEx()\Row\FontID)
    ElseIf FontID
      DrawingFont(FontID)
    EndIf
    
    X + dpiX(2)
    Y + dpiY(3)
    Width  - dpiX(5)
    Height - dpiY(5)
    
    DrawingMode(#PB_2DDrawing_Default)
    Box(X, Y, Width, Height, BackColor)
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(X, Y, Width, Height, BorderColor)
    
    DrawingMode(#PB_2DDrawing_Transparent)
    textX = GetAlignOffset_(Text, Width, #Center)
    textY = (Height - TextHeight("Abc")) / 2
    DrawText(X + textX, Y + textY, Text, TextColor)
    
  EndProcedure
  
  Procedure.i CheckBox_(X.i, Y.i, Width.i, Height.i, boxWidth.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
    
    If boxWidth <= Width And boxWidth <= Height
      
      X + ((Width  - boxWidth) / 2)
      Y + ((Height - boxWidth) / 2) + 1
      
      LineColor = BlendColor_(ListEx()\Color\Front, BackColor, 60)
      
      If State & #Checked

        bColor = BlendColor_(LineColor, ListEx()\Color\ButtonBack)
        
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
        
      ElseIf State & #Inbetween
        
        Box(X, Y, boxWidth, boxWidth, BlendColor_(LineColor, BackColor, 50))
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X + 2, Y + 2, boxWidth - 4, boxWidth - 4, BlendColor_(LineColor, BackColor, 5))
      Box(X + 1, Y + 1, boxWidth - 2, boxWidth - 2, BlendColor_(LineColor, BackColor, 25))
      Box(X, Y, boxWidth, boxWidth, LineColor)
      
    EndIf
    
  EndProcedure
  
  CompilerIf #Enable_ProgressBar
    
    Procedure   DrawProgressBar_(X.f, Y.f, Width.f, Height.f, State.i, Text.s, TextColor.i, Align.i, FontID.i)
      Define.f Factor
      Define.i pbWidth, pbHeight, textX, textY, Progress, Percent
      
      If State < ListEx()\ProgressBar\Minimum : State = ListEx()\ProgressBar\Minimum : EndIf
      If State > ListEx()\ProgressBar\Maximum : State = ListEx()\ProgressBar\Maximum : EndIf
      
      pbWidth  = dpiX(Width  - 4)
      pbHeight = dpiY(Height - 4)
      
      If State > ListEx()\ProgressBar\Minimum
        
        If State = ListEx()\ProgressBar\Maximum
          Progress = pbWidth
        Else
          Factor   = pbWidth / (ListEx()\ProgressBar\Maximum - ListEx()\ProgressBar\Minimum)
          Progress = dpiX((State - ListEx()\ProgressBar\Minimum) * Factor)
        EndIf
        
        DrawingMode(#PB_2DDrawing_Gradient)
        FrontColor(ListEx()\Color\Gradient)
        BackColor(ListEx()\Color\ProgressBar)
        LinearGradient(dpiX(X + 2), dpiY(Y + 2), dpiX(X + 2) + Progress, dpiX(Y + 2) + pbHeight)
        Box(dpiX(X + 2), dpiY(Y + 2), Progress, pbHeight)
  
      EndIf
      
      Percent = ((State - ListEx()\ProgressBar\Minimum) * 100) /  (ListEx()\ProgressBar\Maximum - ListEx()\ProgressBar\Minimum)
      
      If Text
        
        DrawingFont(FontID)
        
        Text  = ReplaceString(Text, #Progress$, Str(Percent) + "%")
        textX = GetAlignOffset_(Text, pbWidth, Align)
        textY = (dpiY(Height) - TextHeight(Text)) / 2
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(dpiX(X) + textX, dpiY(Y) + textY, Text, TextColor)
        
      ElseIf ListEx()\ProgressBar\Flags & #ShowPercent
        
        DrawingFont(FontID)
        
        Text  = Str(Percent) + "%"
        textX = Progress - TextWidth(Text)
        textY = (dpiY(Height) - TextHeight(Text)) / 2
        
        If textX < dpiX(5) : textX = dpiX(5) : EndIf
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(dpiX(X) + textX, dpiY(Y) + textY, Text, TextColor)
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(dpiX(X + 2),  dpiY(Y + 2), pbWidth, pbHeight, ListEx()\Color\ButtonBorder)
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure   DrawButton_(X.f, Y.f, Width.f, Height.f, Text.s, ColorFlag.i, TextColor.i, FontID.i, *Image.Image_Structure)
    Define.f colX, rowY, imgX, imgY
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      X = dpiX(X)
      Y = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If FontID > 0
        Button_(X, Y, Width, Height, Text, ColorFlag, TextColor, FontID)
      Else
        Button_(X, Y, Width, Height, Text, ColorFlag, TextColor)
      EndIf
      
      If *Image\ID ;{ Image 
        
        If *Image\Flags & #Center
          imgX = (Width - dpiX(*Image\Width)) / 2
        ElseIf *Image\Flags & #Right
          imgX = Width - dpiX(*Image\Width) - dpiX(4)
        Else 
          imgX = dpiX(4)
        EndIf
        
        imgY  = (Height - dpiY(*Image\Height)) / 2 + dpiY(1)
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawImage(*Image\ID, X + imgX, Y + imgY, dpiX(*Image\Width), dpiY(*Image\Height)) 
        ;}
      EndIf
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  Procedure   DrawLink_(X.f, Y.f, Width.f, Height.f, Text.s, LinkColor.i, Align.i, FontID.i, *Image.Image_Structure)
    Define.f colX, rowY, textX, textY, imgX, imgY
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      X = dpiX(X)
      Y = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      UpdateRowY_()

      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(X, Y, Width, Height)
      CompilerEndIf

      DrawingMode(#PB_2DDrawing_Default)
      Box(X + dpiX(1), Y + dpiY(1), Width - dpiX(2), Height - dpiY(2), BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10))
      
      If *Image\ID ;{ Image 
        
        If *Image\Flags & #Center
          imgX = (Width - dpiX(*Image\Width)) / 2
        ElseIf *Image\Flags & #Right
          imgX = Width - dpiX(*Image\Width - 4)
        Else 
          imgX = dpiX(4)
        EndIf
        
        imgY  = (Height - dpiY(*Image\Height)) / 2 + dpiY(1)
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawImage(*Image\ID, X + imgX + dpiX(1), Y + imgY + dpiY(1), dpiX(*Image\Width - 2), dpiY(*Image\Height - 2)) 
        
        If Text <> ""
          
          If FontID > 0
            DrawingFont(FontID)
          Else
            DrawingFont(ListEx()\Row\FontID)
          EndIf
          
          If *Image\Flags & #Center
            textX = GetAlignOffset_(Text, Width, #Center)
          ElseIf *Image\Flags & #Right
            textX = GetAlignOffset_(Text, Width, #Left)
          Else 
            textX = dpiX(*Image\Width + 8)
          EndIf
          
          textY = (Height - TextHeight("Abc")) / 2 + dpiY(1)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(X + textX, Y + textY, Text, LinkColor)
          
        EndIf
        ;}
      Else         ;{ Text
        
        If Text <> ""
          
          If FontID > 0
            DrawingFont(FontID)
          Else
            DrawingFont(ListEx()\Row\FontID)
          EndIf
          
          textX = GetAlignOffset_(Text, Width, Align)
          textY = (Height - TextHeight("Abc")) / 2 + dpiY(1)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(X + textX, Y + textY, Text, LinkColor)
          
        EndIf
        ;}
      EndIf 
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput()
      CompilerEndIf  
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  Procedure   DrawString_()
    Define.i p, PosX, PosY, txtHeight, CursorX, maxPosX
    Define.i TextColor, BackColor, BorderColor
    Define.s Text
    
    ;{ --- Color ---
    If ListEx()\String\Wrong
      TextColor = ListEx()\Color\WrongFront
      BackColor = ListEx()\Color\WrongBack
    Else  
      TextColor = ListEx()\Color\Front
      If SelectElement(ListEx()\Cols(), ListEx()\String\Col)
        If ListEx()\Cols()\FrontColor <> #PB_Default
          TextColor = ListEx()\Cols()\FrontColor
        EndIf
      EndIf   
      BackColor = $FFFFFF
    EndIf 
    BorderColor = ListEx()\Color\Focus
    ;}
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      DrawingFont(ListEx()\String\FontID)

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(dpiX(ListEx()\String\X), dpiY(ListEx()\String\Y), dpiX(ListEx()\String\Width), dpiY(ListEx()\String\Height), BackColor)
      ;}
      
      Text      = ListEx()\String\Text
      txtHeight = TextHeight(ListEx()\String\Text)
      
      PosX    = dpiX(ListEx()\String\X + 3)
      PosY    = dpiY(ListEx()\String\Y) + ((dpiY(ListEx()\String\Height) - txtHeight) / 2) 
      maxPosX = dpiX(ListEx()\String\X + ListEx()\String\Width - 1)
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(dpiX(ListEx()\String\X), dpiY(ListEx()\String\Y), dpiX(ListEx()\String\Width), dpiY(ListEx()\String\Height)) 
      CompilerEndIf
    
      ListEx()\Cursor\X = PosX + TextWidth(Left(Text, ListEx()\String\CursorPos)) - 1
      ListEx()\Cursor\Pos = ListEx()\String\CursorPos
      ListEx()\Cursor\Y   = PosY
      ListEx()\Cursor\ClipX     = maxPosX
      ListEx()\Cursor\Height    = txtHeight
      ListEx()\Cursor\BackColor = BackColor
      
      If ListEx()\Cursor\X > maxPosX
        
        Text = Left(Text, ListEx()\String\CursorPos)
        
        For p = Len(Text) To 0 Step -1
          If PosX + TextWidth(Right(Text, p)) <= maxPosX
            Text = Right(Text, p)
            ListEx()\Cursor\X = PosX + TextWidth(Text) - 1
            Break  
          EndIf 
        Next
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(PosX, PosY, Text, TextColor)

      Line(ListEx()\Cursor\X, PosY, 1, txtHeight, $000000)
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput()
      CompilerEndIf
      
      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(dpiX(ListEx()\String\X), dpiY(ListEx()\String\Y), dpiX(ListEx()\String\Width), dpiY(ListEx()\String\Height), BorderColor)
      ;}
      
      StopDrawing()
    EndIf
  
  EndProcedure  

  Procedure   Draw_()
    Define.f colX, rowY, textY, textX, colW0, colWidth, rowHeight, imgY, imgX, imgWidth
    Define.i Width, Height
    Define.i Flags, imgFlags, Align, Mark, Row
    Define.i FrontColor, FocusColor, RowColor, FontID, RowFontID, Time
    Define.s Key$, Text$
    
    If ListEx()\Hide : ProcedureReturn #False : EndIf
    
    AdjustScrollBars_()
    
    If ListEx()\HScroll\Hide
      Height = dpiY(GadgetWidth(ListEx()\CanvasNum))
    Else  
      Height = dpiY(GadgetWidth(ListEx()\CanvasNum)) - dpiY(#ScrollBar_Width)
    EndIf
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      PushListPosition(ListEx()\Rows())
      PushListPosition(ListEx()\Cols())
      
      colX = 0
      rowY = 0
      colWidth  = 0
      rowHeight = 0
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, dpiX(GadgetWidth(ListEx()\CanvasNum)), dpiY(GadgetHeight(ListEx()\CanvasNum)), ListEx()\Color\Canvas)
      ;}

      colX     = dpiX(ListEx()\Size\X)    - dpiX(ListEx()\Col\OffsetX)
      colWidth = dpiX(ListEx()\Size\Cols) - dpiX(ListEx()\Col\OffsetX)

      ;{ _____ Header _____
      If ListEx()\Flags & #NoRowHeader
        
        rowY = dpiY(ListEx()\Size\Y)
        
      Else

        DrawingMode(#PB_2DDrawing_Default)
        Box(colX, rowY, dpiX(ListEx()\Size\Cols), dpiY(ListEx()\Header\Height), ListEx()\Color\HeaderBack)
        
        ForEach ListEx()\Cols()
          
          If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
          
          If ListEx()\Cols()\Header\FontID = #PB_Default
            DrawingFont(ListEx()\Header\FontID)
          Else
            DrawingFont(ListEx()\Cols()\Header\FontID)
          EndIf

          If ListEx()\Cols()\Header\BackColor <> #PB_Default
            DrawingMode(#PB_2DDrawing_Default)
            Box(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Header\Height), ListEx()\Cols()\Header\BackColor)
          EndIf 
          
          If CurrentColumn_() = ListEx()\Sort\Column And ListEx()\Cols()\Header\Sort & #SortArrows
            Arrow_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Header\Height), ListEx()\Cols()\Header\Direction) 
          EndIf
          
          If ListEx()\Cols()\Header\Flags & #Image ;{ Image
            
            imgFlags = ListEx()\Cols()\Header\Image\Flags
            
            If imgFlags & #Center
              imgX = (dpiX(ListEx()\Cols()\Width) - dpiX(ListEx()\Cols()\Header\Image\Width)) / 2
            ElseIf imgFlags & #Right
              imgX = dpiX(ListEx()\Cols()\Width) - dpiX(ListEx()\Cols()\Header\Image\Width) - dpiX(4)
            Else 
              imgX = dpiX(4)
            EndIf

            imgY  = (dpiY(ListEx()\Header\Height) - dpiY(ListEx()\Cols()\Header\Image\Height)) / 2 + dpiY(1)
          
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            DrawImage(ListEx()\Cols()\Header\Image\ID, colX + imgX, rowY + imgY, dpiX(ListEx()\Cols()\Header\Image\Width), dpiY(ListEx()\Cols()\Header\Image\Height)) 
            
            ListEx()\Cols()\MaxWidth = TextWidth(ListEx()\Cols()\Header\Title) + dpiX(ListEx()\Cols()\Header\Image\Width) + dpiX(4)
            
          Else
            
            ListEx()\Cols()\MaxWidth = TextWidth(ListEx()\Cols()\Header\Title)
            ;}
          EndIf          
          
          If ListEx()\Cols()\Header\Align = #PB_Default
            Align = ListEx()\Header\Align
          Else
            Align = ListEx()\Cols()\Header\Align
          EndIf
          
          If ListEx()\Cols()\Header\FrontColor = #PB_Default
            FrontColor = ListEx()\Color\HeaderFront
          Else
            FrontColor = ListEx()\Cols()\Header\FrontColor
          EndIf
          
          If ListEx()\Cols()\Header\Title
            textX = GetAlignOffset_(ListEx()\Cols()\Header\Title, dpiX(ListEx()\Cols()\Width), Align)
            textY = (dpiY(ListEx()\Header\Height) - TextHeight("Abc")) / 2 + 0.5
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(colX + textX, rowY + textY, ListEx()\Cols()\Header\Title, FrontColor)
          EndIf
          
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(colX - 1, rowY, dpiX(ListEx()\Cols()\Width) + 1, dpiY(ListEx()\Header\Height) + 1, ListEx()\Color\HeaderLine)
          colX + dpiX(ListEx()\Cols()\Width)
          
        Next
      
        rowY = dpiY(ListEx()\Size\Y) + dpiY(ListEx()\Header\Height)
      EndIf ;}
      
      DrawingFont(ListEx()\Row\FontID)
      FontID = ListEx()\Row\FontID
     
      ; _____ Rows _____
      ListEx()\Row\OffSetY = 0

      ForEach ListEx()\Rows()
        
        If ListIndex(ListEx()\Rows()) < ListEx()\Row\Offset
          ListEx()\Row\OffSetY + ListEx()\Rows()\Height
          Continue
        EndIf
        
        If ListEx()\Rows()\FontID : FontID = ListEx()\Rows()\FontID : EndIf
        RowFontID = FontID

        rowHeight + dpiY(ListEx()\Rows()\Height)
        
        colX = dpiX(ListEx()\Size\X) - dpiX(ListEx()\Col\OffsetX)
        
        DrawingMode(#PB_2DDrawing_Default)
        
        Row = ListIndex(ListEx()\Rows())
        
        ;{ Alternate Color
        If ListEx()\Color\Back <> ListEx()\Color\AlternateRow 
          If Mod(ListIndex(ListEx()\Rows()), 2)
            Box(colX, rowY, dpiX(ListEx()\Size\Cols), dpiY(ListEx()\Rows()\Height), ListEx()\Color\AlternateRow)
          Else
            Box(colX, rowY, dpiX(ListEx()\Size\Cols), dpiY(ListEx()\Rows()\Height), ListEx()\Color\Back)
          EndIf
        Else
          Box(colX, rowY, dpiX(ListEx()\Size\Cols), dpiY(ListEx()\Rows()\Height), ListEx()\Color\Back)  
        EndIf ;}
        
        ;{ Focus row
        FocusColor = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10)
        If ListEx()\Flags & #MultiSelect And ListEx()\MultiSelect = #True
          If ListEx()\Rows()\State & #Selected
            Box(colX, rowY, dpiX(ListEx()\Size\Cols), dpiY(ListEx()\Rows()\Height), FocusColor)
          EndIf
        ElseIf ListEx()\Focus And ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
          Box(colX, rowY, dpiX(ListEx()\Size\Cols), dpiY(ListEx()\Rows()\Height), FocusColor)
        EndIf ;}

        ForEach ListEx()\Cols() ;{ Columns of current row
          
          If ListEx()\Cols()\Flags & #Hide : Continue : EndIf

          Key$ = ListEx()\Cols()\Key
          If Key$ = "" : Key$ = Str(ListIndex(ListEx()\Cols())) : EndIf
          
          Flags = ListEx()\Rows()\Column(Key$)\Flags
          
          FontID = RowFontID
          
          If ListEx()\Cols()\FontID : FontID = ListEx()\Cols()\FontID : EndIf

          If CurrentColumn_() = 0 And ListEx()\Flags & #NumberedColumn ;{ Numbering column 0
            
            If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
            
            DrawingFont(FontID)
            
            Text$    = Str(ListIndex(ListEx()\Rows()) + 1)
            textX    = GetAlignOffset_(Text$, dpiX(ListEx()\Cols()\Width), #Right)
            textY    = (dpiY(ListEx()\Rows()\Height) - TextHeight("Abc")) / 2 + dpiY(1)
            colW0    = dpiX(ListEx()\Cols()\Width)
            
            DrawingMode(#PB_2DDrawing_Default)
            Box(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Row\Height), ListEx()\Color\HeaderBack)
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(colX + textX, rowY + textY, Text$, ListEx()\Color\HeaderFront, ListEx()\Color\HeaderBack)
            
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height + 1), ListEx()\Color\HeaderLine)
            
            If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
            ;}
          Else  
            
            If ListEx()\Cols()\Flags & #Links
              FrontColor = ListEx()\Color\Link
            ElseIf Flags & #CellFront
              FrontColor = ListEx()\Rows()\Column(Key$)\Color\Front
            ElseIf ListEx()\Rows()\Color\Front <> #PB_Default
              FrontColor = ListEx()\Rows()\Color\Front
            ElseIf ListEx()\Cols()\FrontColor <> #PB_Default
              FrontColor = ListEx()\Cols()\FrontColor
            Else
              FrontColor = ListEx()\Color\Front
            EndIf
            
            ;{ Colored cell background
            If ListIndex(ListEx()\Rows()) <> ListEx()\Row\Current
              If Flags & #CellBack
                DrawingMode(#PB_2DDrawing_Default)
                Box(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), ListEx()\Rows()\Column(Key$)\Color\Back)
              ElseIf ListEx()\Rows()\Color\Back <> #PB_Default
                DrawingMode(#PB_2DDrawing_Default)
                Box(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), ListEx()\Rows()\Color\Back)
              ElseIf ListEx()\Cols()\BackColor <> #PB_Default
                DrawingMode(#PB_2DDrawing_Default)
                Box(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), ListEx()\Cols()\BackColor)
              EndIf
            EndIf ;}
            
            If ListEx()\Cols()\Flags & #CheckBoxes      ;{ CheckBox
              
              If ListEx()\Focus And ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
                CheckBox_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), TextHeight("X") - dpiY(3), FocusColor, ListEx()\Rows()\Column(Key$)\State)
              Else
                CheckBox_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), TextHeight("X") - dpiY(3), ListEx()\Color\Back, ListEx()\Rows()\Column(Key$)\State)
              EndIf
            
            ElseIf ListEx()\Flags & #CheckBoxes And CurrentColumn_() = ListEx()\Col\CheckBoxes
              
              If ListEx()\Focus And ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
                CheckBox_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), TextHeight("X") - dpiY(3), FocusColor, ListEx()\Rows()\State)
              Else
                CheckBox_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), TextHeight("X") - dpiY(3), ListEx()\Color\Back,  ListEx()\Rows()\State)
              EndIf
              ;}
            ElseIf Flags & #Buttons Or Flags & #Strings Or Flags & #Dates ;{ Single cells
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""
                
                CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                  ClipOutput(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height)) 
                CompilerEndIf
                
                If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
                
                DrawingFont(FontID)
                
                If Flags & #Buttons
                  Button_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), ListEx()\Rows()\Column(Key$)\Value, #False, FrontColor, FontID)
                EndIf 
                
                textY = (dpiY(ListEx()\Rows()\Height) - TextHeight("Abc")) / 2 + dpiY(1)
                
                DrawingMode(#PB_2DDrawing_Transparent)
                
                textX = GetAlignOffset_(Text$, dpiX(ListEx()\Cols()\Width), ListEx()\Cols()\Align)

                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsMarked_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          FrontColor = ListEx()\Mark()\Color1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          FrontColor = ListEx()\Mark()\Color2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                DrawText(colX + textX, rowY + textY, Text$, FrontColor)
                
                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
                
                CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                  UnclipOutput()
                CompilerEndIf
                
              EndIf
              ;}
            ElseIf ListEx()\Cols()\Flags & #Buttons     ;{ Button
              
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                ClipOutput(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height))
              CompilerEndIf
              
              If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf

              Button_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), ListEx()\Rows()\Column(Key$)\Value, #False, FrontColor, FontID)
              
              If Flags & #Image
                
                imgFlags = ListEx()\Rows()\Column(Key$)\Image\Flags
              
                If imgFlags & #Center
                  imgX  = (dpiX(ListEx()\Cols()\Width) - dpiX(ListEx()\Rows()\Column(Key$)\Image\Width)) / 2
                ElseIf imgFlags & #Right
                  imgX  = dpiX(ListEx()\Cols()\Width)  - dpiX(ListEx()\Rows()\Column(Key$)\Image\Width) - dpiX(4)
                Else 
                  imgX = dpiX(4)
                EndIf

                imgY = (dpiY(ListEx()\Rows()\Height) - dpiY(ListEx()\Rows()\Column(Key$)\Image\Height)) / 2 + dpiY(1)
              
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                DrawImage(ListEx()\Rows()\Column(Key$)\Image\ID, colX + imgX, rowY + imgY, dpiX(ListEx()\Rows()\Column(Key$)\Image\Width), dpiY(ListEx()\Rows()\Column(Key$)\Image\Height)) 
                
              EndIf
              
              If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
              
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                UnclipOutput()
              CompilerEndIf  
              ;}
            ElseIf ListEx()\Cols()\Flags & #ProgressBar ;  ProgressBar
              CompilerIf #Enable_ProgressBar
                
                If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
              
                DrawProgressBar_(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height), ListEx()\Rows()\Column(Key$)\State, ListEx()\Rows()\Column(Key$)\Value, FrontColor, ListEx()\Cols()\Align, FontID)

                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
                
              CompilerEndIf 
            ElseIf Flags & #Image                       ;{ Image
              
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                ClipOutput(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height))
              CompilerEndIf
              
              imgFlags = ListEx()\Rows()\Column(Key$)\Image\Flags
              
              If imgFlags & #Center
                imgX  = (dpiX(ListEx()\Cols()\Width) - dpiX(ListEx()\Rows()\Column(Key$)\Image\Width)) / 2
              ElseIf imgFlags & #Right
                imgX  = dpiX(ListEx()\Cols()\Width)  - dpiX(ListEx()\Rows()\Column(Key$)\Image\Width) - dpiX(4)
              Else 
                imgX = dpiX(4)
              EndIf
              
              imgWidth = dpiX(ListEx()\Rows()\Column(Key$)\Image\Width) + dpiX(4)
              imgY     = (dpiY(ListEx()\Rows()\Height) - dpiY(ListEx()\Rows()\Column(Key$)\Image\Height)) / 2 + dpiY(1)
              
              DrawingMode(#PB_2DDrawing_AlphaBlend)
              DrawImage(ListEx()\Rows()\Column(Key$)\Image\ID, colX + imgX, rowY + imgY, dpiX(ListEx()\Rows()\Column(Key$)\Image\Width), dpiY(ListEx()\Rows()\Column(Key$)\Image\Height)) 
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""
                
                If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
                
                DrawingFont(FontID)
                
                textY = (dpiY(ListEx()\Rows()\Height) - TextHeight("Abc")) / 2 + dpiY(1)
                
                If imgFlags & #Center
                  textX = GetAlignOffset_(Text$, dpiX(ListEx()\Cols()\Width), #Center)
                ElseIf imgFlags & #Right
                  textX = GetAlignOffset_(Text$, dpiX(ListEx()\Cols()\Width), #Left)
                Else 
                  textX = dpiX(ListEx()\Rows()\Column(Key$)\Image\Width) + dpiX(8)
                EndIf
                
                DrawingMode(#PB_2DDrawing_Transparent)
                
                If ListEx()\Cols()\Flags & #Links
                  FrontColor = ListEx()\Color\Link
                ElseIf Flags & #CellFront
                  FrontColor = ListEx()\Rows()\Column(Key$)\Color\Front
                Else
                  FrontColor = ListEx()\Color\Front
                EndIf
                
                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsMarked_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          FrontColor = ListEx()\Mark()\Color1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          FrontColor = ListEx()\Mark()\Color2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                DrawText(colX + textX, rowY + textY, Text$, FrontColor)
                
                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
                
              EndIf  
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                UnclipOutput()
              CompilerEndIf
              ;}
            Else                                        ;{ Text
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""
                
                CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                  ClipOutput(colX, rowY, dpiX(ListEx()\Cols()\Width), dpiY(ListEx()\Rows()\Height)) 
                CompilerEndIf
                
                If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
                
                DrawingFont(FontID)
                
                textY = (dpiY(ListEx()\Rows()\Height) - TextHeight("Abc")) / 2 + dpiY(1)
                
                DrawingMode(#PB_2DDrawing_Transparent)
                
                textX = GetAlignOffset_(Text$, dpiX(ListEx()\Cols()\Width), ListEx()\Cols()\Align)

                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsMarked_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          FrontColor = ListEx()\Mark()\Color1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          FrontColor = ListEx()\Mark()\Color2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                DrawText(colX + textX, rowY + textY, Text$, FrontColor)
                
                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
                
                CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                  UnclipOutput()
                CompilerEndIf
                
              EndIf
              ;}  
            EndIf
          
            If ListEx()\Flags & #GridLines
              DrawingMode(#PB_2DDrawing_Outlined)
              Box(colX - dpiX(1), rowY, dpiX(ListEx()\Cols()\Width) + dpiX(1), dpiY(ListEx()\Rows()\Height) + dpiY(1), ListEx()\Color\Line)
            EndIf
            
          EndIf
          
          colX + dpiX(ListEx()\Cols()\Width)
          ;}
        Next
        
        rowY + dpiY(ListEx()\Row\Height)
        
        If rowY > Height : Break : EndIf
        
      Next

      colX = dpiX(ListEx()\Size\X) - dpiX(ListEx()\Col\OffsetX)
      rowY = dpiY(ListEx()\Size\Y)
      
      DrawingMode(#PB_2DDrawing_Default)
      
      Line(0, dpiX(ListEx()\Header\Height), colWidth, dpiY(1), ListEx()\Color\HeaderLine) 
      
      ;{ _____ ScrollBars ______
      If ListEx()\VScroll\Hide = #False
        Box(dpiX(GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width), 0, dpiX(#ScrollBar_Width + 1), dpiY(GadgetHeight(ListEx()\CanvasNum)), ListEx()\Color\ScrollBar)
      EndIf
      
      If  ListEx()\HScroll\Hide = #False
        Box(0, dpiY(GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width), dpiX(GadgetWidth(ListEx()\CanvasNum)), dpiY(#ScrollBar_Width + 1), ListEx()\Color\ScrollBar)
      EndIf ;}
      
      ;{ _____ Border _____
      If ListEx()\Flags & #NumberedColumn
        Line(colX + colW0 - dpiY(1), dpiY(ListEx()\Header\Height), dpiY(1), rowHeight + dpiY(1), ListEx()\Color\HeaderLine)
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, dpiX(GadgetWidth(ListEx()\CanvasNum)), dpiY(GadgetHeight(ListEx()\CanvasNum)), ListEx()\Color\HeaderLine)
      ;}
      
      PopListPosition(ListEx()\Cols())
      PopListPosition(ListEx()\Rows())

      StopDrawing()
    EndIf  
    
  EndProcedure
 
  ;- __________ ScrollBars _________
  
  Procedure   AdjustScrollBars_(Force.i=#False)
    Define.f WidthOffset
    Define.i Width
    Define.i PageRows
    
    If IsGadget(ListEx()\VScrollNum) ;{ Vertical ScrollBar
      
      If ListEx()\Size\Rows > (GadgetHeight(ListEx()\CanvasNum) - ListEx()\Header\Height)
      
        PageRows = GetPageRows_()
        
        If ListEx()\VScroll\Hide Or Force
          If ListEx()\HScroll\Hide
            ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
          Else
            ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
          EndIf
          HideGadget(ListEx()\VScrollNum, #False)
          ListEx()\VScroll\Hide = #False
        EndIf
        
        SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_Maximum,    ListEx()\Row\Number - 1)
        SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_PageLength, PageRows)
        
        ListEx()\VScroll\MinPos = 0
        ListEx()\VScroll\MaxPos = ListEx()\Row\Number - PageRows + 2
        
        If ListEx()\VScroll\Hide = #False
          If GadgetHeight(ListEx()\VScrollNum) < GadgetHeight(ListEx()\CanvasNum) - 2
            
            If ListEx()\HScroll\Hide
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
            Else
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
            EndIf
            
          ElseIf GadgetHeight(ListEx()\VScrollNum) > GadgetHeight(ListEx()\CanvasNum)
            
            If ListEx()\HScroll\Hide
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
            Else
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
            EndIf
            
          EndIf
          
        EndIf
        
      ElseIf Not ListEx()\VScroll\Hide And ListEx()\Size\Rows < (GadgetHeight(ListEx()\CanvasNum) - ListEx()\Header\Height)
        
        ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 2)
        HideGadget(ListEx()\VScrollNum, #True)
        ListEx()\Row\Offset   = 0
        ListEx()\VScroll\Hide = #True
        
        If ListSize(ListEx()\Rows()) = 0
          SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_Maximum,    0)
          SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_PageLength, 0)
        EndIf 
        
      EndIf
      ;}
    EndIf
    
    If ListEx()\VScroll\Hide
      Width = GadgetWidth(ListEx()\CanvasNum)
    Else
      Width = GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width 
    EndIf
    
    If ListEx()\AutoResize\Column <> #PB_Ignore ;{ Resize column

      If ListEx()\Size\Cols > Width
        
        If SelectElement(ListEx()\Cols(), ListEx()\AutoResize\Column)
          
          WidthOffset = ListEx()\Size\Cols - Width
          If ListEx()\Cols()\Width - WidthOffset >= ListEx()\AutoResize\MinWidth
            ListEx()\Cols()\Width  - WidthOffset
            ListEx()\Size\Cols     - WidthOffset
            ListEx()\HScroll\Hide  = #True
            UpdateColumnX_()
            HideGadget(ListEx()\HScrollNum, #True) 
            ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
          Else  
            WidthOffset = ListEx()\AutoResize\Width - ListEx()\Cols()\Width
            ListEx()\Cols()\Width = ListEx()\AutoResize\Width
            UpdateColumnX_()
          EndIf
          
        EndIf
        
      ElseIf ListEx()\Size\Cols < Width
        
        If SelectElement(ListEx()\Cols(), ListEx()\AutoResize\Column)
          
          WidthOffset = Width - ListEx()\Size\Cols
          
          If ListEx()\AutoResize\maxWidth > #PB_Default And ListEx()\Cols()\Width + WidthOffset > ListEx()\AutoResize\maxWidth
            ListEx()\Cols()\Width = ListEx()\AutoResize\maxWidth
          Else  
            ListEx()\Cols()\Width + WidthOffset
          EndIf
          
          UpdateColumnX_()
          
        EndIf
        
      EndIf
      ;}
    EndIf    
    
    If IsGadget(ListEx()\HScrollNum)            ;{ Horizontal Scrollbar
      
      If ListEx()\Size\Cols > Width
        
        If ListEx()\HScroll\Hide
          If ListEx()\VScroll\Hide
            ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
          Else
            ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
          EndIf
          HideGadget(ListEx()\HScrollNum, #False)
          ListEx()\HScroll\Hide = #False
        EndIf
        
        SetGadgetAttribute(ListEx()\HScrollNum, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(ListEx()\HScrollNum, #PB_ScrollBar_Maximum,    ListEx()\Size\Cols)
        SetGadgetAttribute(ListEx()\HScrollNum, #PB_ScrollBar_PageLength, Width)
        
        ListEx()\HScroll\MinPos = 0
        ListEx()\HScroll\MaxPos = ListEx()\Size\Cols - Width + 1
        
        If ListEx()\HScroll\Hide = #False
          If GadgetWidth(ListEx()\HScrollNum) < Width - 2
            If ListEx()\VScroll\Hide
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
            Else  
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
            EndIf  
          ElseIf GadgetWidth(ListEx()\HScrollNum) > Width - 1
            If ListEx()\VScroll\Hide
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
            Else  
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
            EndIf 
          EndIf
          
        EndIf
        
      ElseIf ListEx()\Size\Cols < Width
        
        If ListEx()\HScroll\Hide = #False
          ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
          HideGadget(ListEx()\HScrollNum, #True)
          ListEx()\HScroll\Hide = #True
        EndIf
        
      EndIf 
      ;}
    EndIf
    
  EndProcedure
  
  Procedure   SetHScrollPosition_()
    Define.f ScrollPos
    
    If IsGadget(ListEx()\HScrollNum)
      
      ScrollPos = ListEx()\Col\OffsetX
      
      If ScrollPos < ListEx()\HScroll\MinPos : ScrollPos = ListEx()\HScroll\MinPos : EndIf
      If ScrollPos > ListEx()\HScroll\MaxPos : ScrollPos = ListEx()\HScroll\MaxPos : EndIf
      
      ListEx()\Col\OffsetX      = ScrollPos
      ListEx()\HScroll\Position = ScrollPos
      
      SetGadgetState(ListEx()\HScrollNum, ScrollPos)
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetVScrollPosition_()
    Define.f ScrollPos
    
    If IsGadget(ListEx()\VScrollNum)
      
      ScrollPos = ListEx()\Row\Offset
      If ScrollPos > ListEx()\VScroll\MaxPos : ScrollPos = ListEx()\VScroll\MaxPos : EndIf
      
      ListEx()\VScroll\Position = ScrollPos
      
      SetGadgetState(ListEx()\VScrollNum, ScrollPos)
      
    EndIf
    
  EndProcedure  
  
  
  Procedure   SetRowFocus_(Row.i)
    Define.i PageRows
    
    PageRows = GetPageRows_()
    If Row > PageRows + ListEx()\Row\Offset - 1
      ListEx()\Row\Offset = Row - PageRows + 1
      SetVScrollPosition_()
    ElseIf Row < ListEx()\Row\Offset
      ListEx()\Row\Offset = Row - 1
      SetVScrollPosition_()
    EndIf
    
  EndProcedure
  
  ;- __________ Events __________
  
  Procedure   UpdateEventData_(Type.i, Row.i=#NotValid, Column.i=#NotValid, Value.s="", State.i=#NotValid, ID.s="")
    
    ListEx()\Event\Type   = Type
    ListEx()\Event\Row    = Row
    ListEx()\Event\Column = Column
    ListEx()\Event\Value  = Value
    ListEx()\Event\State  = State
    ListEx()\Event\ID     = ID
    
  EndProcedure    
  
  Procedure   LoadComboItems_(Column.i)
    
    If IsGadget(ListEx()\ComboNum)
      
      ClearGadgetItems(ListEx()\ComboNum)
      
      If SelectElement(ListEx()\Cols(), Column)
        
        If FindMapElement(ListEx()\ComboBox\Column(), ListEx()\Cols()\Key)
          
          ForEach ListEx()\ComboBox\Column()\Items()
            AddGadgetItem(ListEx()\ComboNum, -1, ListEx()\ComboBox\Column()\Items())
          Next
          
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i ManageEditGadgets_(Row.i, Column.i)
    Define.f X, Y
    Define.i Date
    Define.s Value$, Key$, Mask$
    
    If ListEx()\String\Flag   = #True : ProcedureReturn #False : EndIf
    If ListEx()\ComboBox\Flag = #True : ProcedureReturn #False : EndIf
    If ListEx()\Date\Flag     = #True : ProcedureReturn #False : EndIf
    
    If SelectElement(ListEx()\Rows(), Row)
      If SelectElement(ListEx()\Cols(), Column)
        
        Y = ListEx()\Rows()\Y - ListEx()\Row\OffsetY
        X = ListEx()\Cols()\X - ListEx()\Col\OffsetX
        
        Key$ = ListEx()\Cols()\Key
        
        If ListEx()\Rows()\Column(Key$)\Flags & #LockCell : ProcedureReturn #False : EndIf
        
        If ListEx()\Cols()\Flags & #Strings Or ListEx()\Rows()\Column(Key$)\Flags & #Strings           ;{ Editable Cells
  
          If ListEx()\Editable

            If ListEx()\Cols()\FontID
              ListEx()\String\FontID = ListEx()\Cols()\FontID
            Else
              ListEx()\String\FontID = ListEx()\Row\FontID
            EndIf  
            
            ListEx()\String\Row    = Row
            ListEx()\String\Col    = Column
            ListEx()\String\X      = ListEx()\Cols()\X
            ListEx()\String\Y      = ListEx()\Rows()\Y
            ListEx()\String\Width  = ListEx()\Cols()\Width
            ListEx()\String\Height = ListEx()\Rows()\Height
            ListEx()\String\Label  = ListEx()\Cols()\Key
            ListEx()\String\Text   = ListEx()\Rows()\Column(Key$)\Value
            ListEx()\String\Flag   = #True

            ListEx()\String\CursorPos = Len(ListEx()\String\Text)
            
            DrawString_()
            
            BindTabulator_(#False)
            
          EndIf
          ;}
        ElseIf ListEx()\Cols()\Flags & #ComboBoxes Or ListEx()\Rows()\Column(Key$)\Flags & #ComboBoxes ;{ ComboCoxes

          If IsGadget(ListEx()\ComboNum)
            
            If ListEx()\Editable
              
              ResizeGadget(ListEx()\ComboNum, X, Y + 1, ListEx()\Cols()\Width - 1,  ListEx()\Rows()\Height)
              LoadComboItems_(Column)
              SetGadgetText(ListEx()\ComboNum, ListEx()\Rows()\Column(Key$)\Value)
              ListEx()\ComboBox\Row    = Row
              ListEx()\ComboBox\Col    = Column
              ListEx()\ComboBox\X      = ListEx()\Cols()\X
              ListEx()\ComboBox\Y      = ListEx()\Rows()\Y
              ListEx()\ComboBox\Width  = ListEx()\Cols()\Width
              ListEx()\ComboBox\Height = ListEx()\Rows()\Height
              ListEx()\ComboBox\Label  = ListEx()\Cols()\Key
              ListEx()\ComboBox\Flag   = #True
              
              BindShortcuts_(#True)
              HideGadget(ListEx()\ComboNum, #False)
              
              SetActiveGadget(ListEx()\ComboNum)
              
            EndIf  
          
          EndIf
          ;}
        ElseIf ListEx()\Cols()\Flags & #Dates Or ListEx()\Rows()\Column(Key$)\Flags & #Dates           ;{ DateGadget

          If IsGadget(ListEx()\DateNum)
            
            If ListEx()\Editable
              
              Mask$ = ListEx()\Date\Mask
              
              If FindMapElement(ListEx()\Date\Column(), Key$)
                If ListEx()\Date\Column()\Min  : SetGadgetAttribute(ListEx()\DateNum, #PB_Date_Minimum, ListEx()\Date\Column()\Min) : EndIf
                If ListEx()\Date\Column()\Max  : SetGadgetAttribute(ListEx()\DateNum, #PB_Date_Maximum, ListEx()\Date\Column()\Max) : EndIf
                If ListEx()\Date\Column()\Mask : Mask$ = ListEx()\Date\Column()\Mask : EndIf
              EndIf

              ResizeGadget(ListEx()\DateNum, X, Y, ListEx()\Cols()\Width - 1, ListEx()\Rows()\Height)
              SetGadgetText(ListEx()\DateNum, Mask$)

              Value$ = ListEx()\Rows()\Column(Key$)\Value
              If Value$
                Date = ParseDate(Mask$, Value$)
                If Date > 0 : SetGadgetState(ListEx()\DateNum, Date) : EndIf
              EndIf

              ListEx()\Date\Row    = Row
              ListEx()\Date\Col    = Column
              ListEx()\Date\X      = ListEx()\Cols()\X
              ListEx()\Date\Y      = ListEx()\Rows()\Y
              ListEx()\Date\Width  = ListEx()\Cols()\Width
              ListEx()\Date\Height = ListEx()\Rows()\Height
              ListEx()\Date\Label  = ListEx()\Cols()\Key
              ListEx()\Date\Flag   = #True
            
              BindShortcuts_(#True)
              HideGadget(ListEx()\DateNum, #False)
              
              SetActiveGadget(ListEx()\DateNum)
              
            EndIf  
         
          EndIf
          ;}
        Else 
          UpdateEventData_(#PB_EventType_LeftDoubleClick, Row, Column, ListEx()\Rows()\Column(Key$)\Value, ListEx()\Rows()\State, ListEx()\Rows()\ID)
          PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #PB_EventType_LeftDoubleClick, Row)
        EndIf  

      EndIf
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure   ScrollEditGadgets_() 
    Define.f X, Y
    
    If ListEx()\String\Flag : CloseString_() : EndIf
    
    If ListEx()\ComboBox\Flag
      If IsGadget(ListEx()\ComboNum)
        X = ListEx()\ComboBox\X - ListEx()\Col\OffsetX
        Y = ListEx()\ComboBox\Y - ListEx()\Row\OffSetY
        ResizeGadget(ListEx()\ComboNum, X, Y + 1, #PB_Ignore, #PB_Ignore)
        If X + ListEx()\ComboBox\Width > GadgetWidth(ListEx()\CanvasNum) Or Y + ListEx()\ComboBox\Height > GadgetHeight(ListEx()\CanvasNum) Or Y < ListEx()\Header\Height
          HideGadget(ListEx()\ComboNum, #True) 
        Else  
          HideGadget(ListEx()\ComboNum, #False)
        EndIf
      EndIf
    EndIf
    
    If ListEx()\Date\Flag
      If IsGadget(ListEx()\DateNum)
        X = ListEx()\Date\X - ListEx()\Col\OffsetX
        Y = ListEx()\Date\Y - ListEx()\Row\OffSetY
        ResizeGadget(ListEx()\DateNum, X, Y + 1, #PB_Ignore, #PB_Ignore)
        If X + ListEx()\Date\Width > GadgetWidth(ListEx()\CanvasNum) Or Y + ListEx()\Date\Height > GadgetHeight(ListEx()\CanvasNum) Or Y < ListEx()\Header\Height
          HideGadget(ListEx()\DateNum, #True) 
        Else  
          HideGadget(ListEx()\DateNum, #False)
        EndIf
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure.i NextEditColumn_(Column.i)
    
    If Column = #PB_Default
      
      If FirstElement(ListEx()\Cols())
        Repeat
          If ListEx()\Cols()\Flags & #Strings
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #ComboBoxes
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #Dates
            ProcedureReturn ListIndex(ListEx()\Cols())
          EndIf
        Until NextElement(ListEx()\Cols()) = #False
      EndIf
      
    Else
    
      If SelectElement(ListEx()\Cols(), Column)
        While NextElement(ListEx()\Cols())
          If ListEx()\Cols()\Flags & #Strings
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #ComboBoxes
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #Dates
            ProcedureReturn ListIndex(ListEx()\Cols())
          EndIf
        Wend
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.i PreviousEditColumn_(Column.i)
    
    If Column = #PB_Default
      
      If LastElement(ListEx()\Cols())
        Repeat
          If ListEx()\Cols()\Flags & #Strings
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #ComboBoxes
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #Dates
            ProcedureReturn ListIndex(ListEx()\Cols())
          EndIf
        Until PreviousElement(ListEx()\Cols()) = #False
      EndIf
      
    Else
    
      If SelectElement(ListEx()\Cols(), Column)
        While PreviousElement(ListEx()\Cols())
          If ListEx()\Cols()\Flags & #Strings
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #ComboBoxes
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #Dates
            ProcedureReturn ListIndex(ListEx()\Cols())
          EndIf
        Wend
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure

  ;- ----------------------------
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ListEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ListEx()\Row\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf  
        
        ListEx()\Color\Focus        = ModuleEx::ThemeGUI\Focus\BackColor
        ListEx()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
        ListEx()\Color\Back         = ModuleEx::ThemeGUI\BackColor
        ListEx()\Color\Line         = ModuleEx::ThemeGUI\LineColor
        ListEx()\Color\ScrollBar    = ModuleEx::ThemeGUI\ScrollbarColor
        ListEx()\Color\AlternateRow = ModuleEx::ThemeGUI\RowColor
        ListEx()\Color\HeaderFront  = ModuleEx::ThemeGUI\Header\FrontColor
        ListEx()\Color\HeaderBack   = ModuleEx::ThemeGUI\Header\BackColor
        ListEx()\Color\HeaderLine   = ModuleEx::ThemeGUI\Header\BorderColor
        ListEx()\Color\ProgressBar  = ModuleEx::ThemeGUI\Progress\BackColor
        ListEx()\Color\Gradient     = ModuleEx::ThemeGUI\Progress\GradientColor
        ListEx()\Color\ButtonBack   = ModuleEx::ThemeGUI\Button\BackColor
        ListEx()\Color\ButtonBorder = ModuleEx::ThemeGUI\Button\BorderColor
        
        If ModuleEx::ThemeGUI\WindowColor > 0
          If IsWindow(ListEx()\Window\Num)
            SetWindowColor(ListEx()\Window\Num, ModuleEx::ThemeGUI\WindowColor) 
          EndIf  
        EndIf 
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf  
  
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
  
  Procedure _CursorDrawing() ; Trigger from Thread (PostEvent Change)
    Define.i WindowNum = EventWindow()
    
    ForEach ListEx()
      
      If ListEx()\Cursor\X >= ListEx()\Cursor\ClipX : Continue : EndIf
      
      If ListEx()\String\Flag

        ListEx()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          If ListEx()\Cursor\State
            Line(ListEx()\Cursor\X, ListEx()\Cursor\Y, 1, ListEx()\Cursor\Height, $000000)
          Else
            Line(ListEx()\Cursor\X, ListEx()\Cursor\Y, 1, ListEx()\Cursor\Height, ListEx()\Cursor\BackColor)
          EndIf
          StopDrawing()
        EndIf

      EndIf
      
    Next
    
  EndProcedure  
  
  
  Procedure _KeyShiftTabHandler()
    Define.i GNum, Column, Row
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      
      If FindMapElement(ListEx(), Str(GNum))  

        Select ActiveID 
          Case ListEx()\ComboNum
            CloseComboBox_()
            Column = PreviousEditColumn_(ListEx()\ComboBox\Col)
            If Column = #NotValid
              Row = ListEx()\ComboBox\Row - 1
              If SelectElement(ListEx()\Rows(), Row)
                Column = PreviousEditColumn_(#PB_Default)
                If Column <> #NotValid
                  ManageEditGadgets_(Row, Column)
                EndIf 
              EndIf
            Else
              ManageEditGadgets_(ListEx()\ComboBox\Row, Column)
            EndIf
          Case ListEx()\DateNum
            CloseDate_()
            Column = PreviousEditColumn_(ListEx()\Date\Col)
            If Column = #NotValid
              Row = ListEx()\Date\Row - 1
              If SelectElement(ListEx()\Rows(), Row)
                Column = PreviousEditColumn_(#PB_Default)
                If Column <> #NotValid
                  ManageEditGadgets_(Row, Column)
                EndIf 
              EndIf
            Else
              ManageEditGadgets_(ListEx()\Date\Row, Column)
            EndIf
        EndSelect
        
      EndIf
      
    EndIf
  
  EndProcedure
  
  Procedure _KeyTabHandler()
    Define.i GNum, Column, Row
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      
      If FindMapElement(ListEx(), Str(GNum))  
        
        Select ActiveID 
          Case ListEx()\ComboNum
            CloseComboBox_()
            Column = NextEditColumn_(ListEx()\ComboBox\Col)
            If Column = #NotValid
              Row = ListEx()\ComboBox\Row + 1
              If SelectElement(ListEx()\Rows(), Row)
                Column = NextEditColumn_(#PB_Default)
                If Column <> #NotValid
                  ManageEditGadgets_(Row, Column)
                EndIf 
              EndIf
            Else
              ManageEditGadgets_(ListEx()\ComboBox\Row, Column)
            EndIf
          Case ListEx()\DateNum
            CloseDate_()
            Column = NextEditColumn_(ListEx()\Date\Col)
            If Column = #NotValid
              Row = ListEx()\Date\Row + 1
              If SelectElement(ListEx()\Rows(), Row)
                Column = NextEditColumn_(#PB_Default)
                If Column <> #NotValid
                  ManageEditGadgets_(Row, Column)
                EndIf 
              EndIf
            Else
              ManageEditGadgets_(ListEx()\Date\Row, Column)
            EndIf
        EndSelect
        
      EndIf
      
    EndIf
  
  EndProcedure
  
  Procedure _KeyReturnHandler()
    Define.i GNum
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      If FindMapElement(ListEx(), Str(GNum))  
        
        Select ActiveID 
          Case ListEx()\ComboNum
            
            CloseComboBox_()
            
          Case ListEx()\DateNum
            
            CloseDate_()
            
        EndSelect
        
      EndIf
      
    EndIf
  
  EndProcedure
  
  Procedure _KeyEscapeHandler()
    Define.i GNum
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      If FindMapElement(ListEx(), Str(GNum))  
 
        Select ActiveID 
          Case ListEx()\ComboNum
            
            CloseComboBox_(#True)
            
          Case ListEx()\DateNum
            
            CloseDate_(#True)

        EndSelect
        
      EndIf
      
    EndIf
  EndProcedure
  
  Procedure _KeyDownHandler()
    Define.i Row, Column, PageRows, Key, Modifier
    Define.s Text
    Define.i GNum = EventGadget()

    If FindMapElement(ListEx(), Str(GNum))
      
      Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
      Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
      
      Select Key
        Case #PB_Shortcut_Left     ;{ Left
          If ListEx()\String\Flag
            If ListEx()\String\CursorPos > 0
              ListEx()\String\CursorPos - 1
            EndIf
          Else  
            ListEx()\Col\OffsetX - 20
            SetHScrollPosition_()
          EndIf 
          ;}
        Case #PB_Shortcut_Right    ;{ Right
          If ListEx()\String\Flag
            If ListEx()\String\CursorPos < Len(ListEx()\String\Text)
              ListEx()\String\CursorPos + 1
            EndIf
          Else 
            ListEx()\Col\OffsetX + 20
            SetHScrollPosition_()
          EndIf  
          ;}
        Case #PB_Shortcut_Up       ;{ Up
          If ListEx()\String\Flag = #False
            ListEx()\Focus = #True
            If PreviousElement(ListEx()\Rows())
              ListEx()\Row\Current = ListIndex(ListEx()\Rows())
            ElseIf FirstElement(ListEx()\Rows())
              ListEx()\Row\Current = ListIndex(ListEx()\Rows())
            EndIf
            ListEx()\Row\Focus = ListEx()\Row\Current
            SetRowFocus_(ListEx()\Row\Focus)
          EndIf
          ;}
        Case #PB_Shortcut_Down     ;{ Down
          If ListEx()\String\Flag = #False
            ListEx()\Focus = #True
            If NextElement(ListEx()\Rows())
              ListEx()\Row\Current = ListIndex(ListEx()\Rows())
            ElseIf LastElement(ListEx()\Rows())
              ListEx()\Row\Current = ListIndex(ListEx()\Rows())
            EndIf
            ListEx()\Row\Focus = ListEx()\Row\Current
            SetRowFocus_(ListEx()\Row\Focus)
          EndIf  
          ;}
        Case #PB_Shortcut_PageUp   ;{ PageUp
          If ListEx()\String\Flag = #False
            PageRows = GetPageRows_()
            ListEx()\Row\Current = ListEx()\Row\Focus - PageRows
            If ListEx()\Row\Current < 0 : ListEx()\Row\Current = 0 : EndIf
            If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
              ListEx()\Row\Focus = ListEx()\Row\Current
              ListEx()\Row\Offset = ListEx()\Row\Focus
              If ListEx()\Row\Offset > ListSize(ListEx()\Rows()) - PageRows
                ListEx()\Row\Offset = ListSize(ListEx()\Rows()) - PageRows
              EndIf
              SetVScrollPosition_()
            EndIf
          EndIf  
          ;}
        Case #PB_Shortcut_PageDown ;{ PageDown
          If ListEx()\String\Flag = #False
            PageRows = GetPageRows_()
            ListEx()\Row\Current = ListEx()\Row\Focus + PageRows
            If ListEx()\Row\Current >= ListSize(ListEx()\Rows()) : ListEx()\Row\Current = ListSize(ListEx()\Rows()) - 1 : EndIf 
            If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
              ListEx()\Row\Focus = ListEx()\Row\Current
              ListEx()\Row\Offset = ListEx()\Row\Focus
              If ListEx()\Row\Offset >= ListSize(ListEx()\Rows()) - PageRows
                ListEx()\Row\Offset = ListSize(ListEx()\Rows()) - PageRows
              EndIf
              SetVScrollPosition_()
            EndIf
          EndIf  
          ;}
        Case #PB_Shortcut_Home     ;{ Home
          If ListEx()\String\Flag
            ListEx()\String\CursorPos = 0
          Else
            If Modifier & #PB_Canvas_Control
              If FirstElement(ListEx()\Rows())
                ListEx()\Focus = #True
                ListEx()\Row\Current = ListIndex(ListEx()\Rows())
                ListEx()\Row\Focus = ListEx()\Row\Current
                SetRowFocus_(ListEx()\Row\Focus)
              EndIf
            EndIf
          EndIf ;}
        Case #PB_Shortcut_End      ;{ End
          If ListEx()\String\Flag
            ListEx()\String\CursorPos = Len(ListEx()\String\Text)
          Else          
            If Modifier & #PB_Canvas_Control
              If LastElement(ListEx()\Rows())
                ListEx()\Row\Current = ListIndex(ListEx()\Rows())
                ListEx()\Row\Focus = ListEx()\Row\Current
                SetRowFocus_(ListEx()\Row\Focus)
              EndIf
            EndIf
          EndIf  
          ;}
        Case #PB_Shortcut_Back     ;{ Delete Back
          If ListEx()\String\Flag
            If ListEx()\String\CursorPos > 0
              ListEx()\String\Text = DeleteStringPart_(ListEx()\String\Text, ListEx()\String\CursorPos)
              ListEx()\String\CursorPos - 1
            EndIf
          EndIf   
          ;}
        Case #PB_Shortcut_Delete   ;{ Delete
          If ListEx()\String\Flag
            If ListEx()\String\CursorPos < Len(ListEx()\String\Text)
              ListEx()\String\Text = DeleteStringPart_(ListEx()\String\Text, ListEx()\String\CursorPos + 1)
            EndIf
          EndIf   
          ;} 
        Case #PB_Shortcut_Insert   ;{ Paste (Shift-Ins)
          If ListEx()\String\Flag
            If Modifier & #PB_Canvas_Shift
              Text = GetClipboardText()
              ListEx()\String\Text = InsertString(ListEx()\String\Text, Text, ListEx()\String\CursorPos + 1)
              ListEx()\String\CursorPos + Len(Text)
            EndIf
          EndIf
          ;}  
        Case #PB_Shortcut_V        ;{ Paste (Ctrl-V) 
          If ListEx()\String\Flag
            Text = GetClipboardText()
            ListEx()\String\Text = InsertString(ListEx()\String\Text, Text, ListEx()\String\CursorPos + 1)
            ListEx()\String\CursorPos + Len(Text)
          EndIf  
          ;} 
        Case #PB_Shortcut_Return   ;{ Return
          If ListEx()\String\Flag
            CloseString_()
          EndIf  
          ;}
        Case #PB_Shortcut_Tab      ;{ Tabulator
          
          If ListEx()\String\Flag
            
            CloseString_()
            
            If Modifier & #PB_Canvas_Shift
              Column = PreviousEditColumn_(ListEx()\String\Col)
              If Column = #NotValid
                Row = ListEx()\String\Row - 1
                If SelectElement(ListEx()\Rows(), Row)
                  Column = PreviousEditColumn_(#PB_Default)
                  If Column <> #NotValid
                    ManageEditGadgets_(Row, Column)
                  EndIf 
                EndIf
              Else
                ManageEditGadgets_(ListEx()\String\Row, Column)
              EndIf
            Else
              Column = NextEditColumn_(ListEx()\String\Col)
              If Column = #NotValid
                Row = ListEx()\String\Row + 1
                If SelectElement(ListEx()\Rows(), Row)
                  Column = NextEditColumn_(#PB_Default)
                  If Column <> #NotValid
                    ManageEditGadgets_(Row, Column)
                  EndIf 
                EndIf
              Else
                ManageEditGadgets_(ListEx()\String\Row, Column)
              EndIf
            EndIf
          EndIf    
          ;}
      EndSelect
      
      If ListEx()\String\Flag
        DrawString_()
      Else
        Draw_()
      EndIf  

    EndIf
    
  EndProcedure
  
  
  Procedure _InputHandler()
    Define   Char.i, Char$
    Define.i GNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))

      If ListEx()\String\Flag
        
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
        If Char >= 32
          
          Char$ = Chr(Char)
          ListEx()\String\CursorPos + 1  
          ListEx()\String\Text = InsertString(ListEx()\String\Text, Char$, ListEx()\String\CursorPos)

          DrawString_()
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure   

  Procedure _RightClickHandler()
    Define.i X, Y
    Define.i GNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      If X < GadgetWidth(GNum) And X < ListEx()\Size\Cols 
        If Y > ListEx()\Header\Height And Y < (ListEx()\Size\Rows + ListEx()\Header\Height)
          
          ListEx()\Row\Current = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
          
          If ListEx()\Flags & #MultiSelect
           
            If GetGadgetAttribute(GNum, #PB_Canvas_Modifiers) <> #PB_Canvas_Control And GetGadgetAttribute(GNum, #PB_Canvas_Modifiers) <> #PB_Canvas_Shift

              ForEach ListEx()\Rows()
                If ListIndex(ListEx()\Rows()) = ListEx()\Row\Current
                  ListEx()\Rows()\State | #Selected
                Else  
                  ListEx()\Rows()\State & ~#Selected
                EndIf
              Next

              ListEx()\MultiSelect     = #False
              ListEx()\Row\StartSelect = #PB_Default
              
              ListEx()\Focus = #True
              If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
                ListEx()\Row\Focus = ListEx()\Row\Current
              EndIf
              
            EndIf
            
          Else
           
            ListEx()\Focus = #True
            If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
              ListEx()\Row\Focus = ListEx()\Row\Current
            EndIf
            
          EndIf
          
          If IsWindow(ListEx()\Window\Num) And IsMenu(ListEx()\PopUpID)
            DisplayPopupMenu(ListEx()\PopUpID, WindowID(ListEx()\Window\Num))
          Else
            UpdateEventData_(#PB_EventType_RightClick, ListEx()\Row\Current, #NotValid, "", #NotValid, ListEx()\Rows()\ID)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #PB_EventType_RightClick, ListEx()\Row\Current)
          EndIf
          
        EndIf
      EndIf  
      
    EndIf  

  EndProcedure  

  Procedure _LeftButtonDownHandler()
    Define.f X, Y, Width, Height
    Define.i Flags, FontID, Row, StartRow, EndRow, FrontColor
    Define.s Key$, Value$
    Define   Image.Image_Structure
    Define   GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ;{ Resize column with mouse
      If ListEx()\Cursor = #PB_Cursor_LeftRight
        ListEx()\Col\MouseX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
        ProcedureReturn #True
      EndIf ;}
      
      If ListEx()\String\Flag   ;{ Close String
        CloseString_()
        Draw_()
      EndIf ;}
      
      If ListEx()\ComboBox\Flag ;{ Close ComboBox
        CloseComboBox_()
        Draw_()
      EndIf ;}
      
      If ListEx()\Date\Flag     ;{ Close DateGadget
        CloseDate_()
        Draw_()
      EndIf ;}
      
      ListEx()\Row\Current = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
      ListEx()\Col\Current = GetColumn_(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      If ListEx()\Row\Current = #Header ;{ Header clicked
        
        If ListEx()\Col\Current < 0 : ProcedureReturn #False : EndIf
        
        If SelectElement(ListEx()\Cols(), ListEx()\Col\Current)
          
          ListEx()\Header\Col = ListEx()\Col\Current
          
          If ListEx()\Cols()\Header\Sort & #HeaderSort
            
            ListEx()\Sort\Label     = ListEx()\Cols()\Key
            ListEx()\Sort\Column    = ListEx()\Col\Current
            ListEx()\Sort\Direction = ListEx()\Cols()\Header\Direction
            ListEx()\Sort\Flags     = ListEx()\Cols()\Header\Sort
            
            If ListEx()\Cols()\Header\Sort & #SwitchDirection
              ListEx()\Cols()\Header\Direction ! #PB_Sort_Descending ; Switch Bit 1
            EndIf
            
            SortColumn_()
            
            ListEx()\Focus = #False
            ListEx()\Row\Focus = #NotValid
            
            UpdateRowY_()
            
            Draw_()
            
            UpdateEventData_(#EventType_Header, #Header, ListEx()\Col\Current, "", ListEx()\Cols()\Header\Direction, ListEx()\Sort\Label)
            
          Else
            UpdateEventData_(#EventType_Header, #Header, ListEx()\Col\Current, "", #NotValid, ListEx()\Cols()\Key)
          EndIf

          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Header, ListEx()\Col\Current)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Header, ListEx()\Col\Current)
          EndIf
        EndIf 
        ;}
      Else                              ;{ Row clicked
        
        If ListEx()\Flags & #SingleClickEdit
          ManageEditGadgets_(ListEx()\Row\Current, ListEx()\Col\Current)
        EndIf
        
        If ListEx()\Row\Current < 0  Or ListEx()\Col\Current < 0 : ProcedureReturn #False : EndIf
        
        If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
          If SelectElement(ListEx()\Cols(), ListEx()\Col\Current)
            
            Y = ListEx()\Rows()\Y - ListEx()\Row\OffsetY
            X = ListEx()\Cols()\X - ListEx()\Col\OffsetX
            
            Key$  = ListEx()\Cols()\Key
            Flags = ListEx()\Rows()\Column(Key$)\Flags
            
            If ListEx()\Cols()\Flags & #CheckBoxes  ;{ CheckBox

              If ListEx()\Editable
                
                If ListEx()\Flags & #ThreeState
                  
                  If ListEx()\Rows()\Column(Key$)\State & #Checked
                    ListEx()\Rows()\Column(Key$)\State & ~#Checked
                    ListEx()\Rows()\Column(Key$)\State | #Inbetween
                  ElseIf ListEx()\Rows()\Column(Key$)\State & #Inbetween
                    ListEx()\Rows()\Column(Key$)\State & ~#Inbetween
                  Else
                    ListEx()\Rows()\Column(Key$)\State | #Checked
                  EndIf
                  
                Else
                  
                  If ListEx()\Rows()\Column(Key$)\State & #Checked
                    ListEx()\Rows()\Column(Key$)\State & ~#Checked
                  Else
                    ListEx()\Rows()\Column(Key$)\State | #Checked
                  EndIf
                  
                EndIf
                
                ListEx()\Changed = #True
                
                ListEx()\CheckBox\Row   = ListEx()\Row\Current
                ListEx()\CheckBox\Col   = ListEx()\Col\Current
                ListEx()\CheckBox\Label = Key$
                ListEx()\CheckBox\State = ListEx()\Rows()\Column(Key$)\State
                
                UpdateEventData_(#EventType_CheckBox, ListEx()\Row\Current, ListEx()\Col\Current, "", ListEx()\CheckBox\State, ListEx()\Rows()\ID)
                If IsWindow(ListEx()\Window\Num)
                  PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                  PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                EndIf
                
                Draw_()
              EndIf
              
            ElseIf ListEx()\Flags & #CheckBoxes And ListEx()\Col\CheckBoxes = ListEx()\Col\Current
              
              If ListEx()\Editable
                
                If ListEx()\Flags & #ThreeState
                  
                  If ListEx()\Rows()\State & #Checked
                    ListEx()\Rows()\State & ~#Checked
                    ListEx()\Rows()\State | #Inbetween
                  ElseIf ListEx()\Rows()\State & #Inbetween
                    ListEx()\Rows()\State & ~#Inbetween
                  Else
                    ListEx()\Rows()\State | #Checked
                  EndIf
                  
                Else
                  
                  If ListEx()\Rows()\State & #Checked
                    ListEx()\Rows()\State & ~#Checked
                  Else
                    ListEx()\Rows()\State | #Checked
                  EndIf
                  
                EndIf
                
                ListEx()\Changed = #True
                
                ListEx()\CheckBox\Row   = ListEx()\Row\Current
                ListEx()\CheckBox\Col   = ListEx()\Col\Current
                ListEx()\CheckBox\Label = Key$
                ListEx()\CheckBox\State = ListEx()\Rows()\Column(Key$)\State
                
                UpdateEventData_(#EventType_CheckBox, ListEx()\Row\Current, ListEx()\Col\Current, "", ListEx()\CheckBox\State, ListEx()\Rows()\ID)
                If IsWindow(ListEx()\Window\Num)
                  PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                  PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                EndIf
                
                Draw_()
              EndIf  
              ;}
            ElseIf Flags & #Buttons Or Flags & #Strings Or Flags & #Dates ;{ Single cells
              
              ListEx()\Focus = #True
              
              ;{ MultiSelect
              If ListEx()\Flags & #MultiSelect
                
                If GetGadgetAttribute(GNum, #PB_Canvas_Modifiers) = #PB_Canvas_Control
                
                  If ListEx()\MultiSelect = #False
                    PushListPosition(ListEx()\Rows())
                    If SelectElement(ListEx()\Rows(), ListEx()\Row\Focus)
                      ListEx()\Rows()\State | #Selected
                    EndIf
                    PopListPosition(ListEx()\Rows())
                    ListEx()\MultiSelect = #True
                  EndIf
                  
                  ListEx()\Rows()\State ! #Selected
                  ListEx()\Row\StartSelect = #PB_Default
                  
                ElseIf GetGadgetAttribute(GNum, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
                  
                  If ListEx()\Row\StartSelect = #PB_Default :  ListEx()\Row\StartSelect = ListEx()\Row\Focus : EndIf
                  
                  If ListEx()\Row\Focus >= 0
                    
                    If ListEx()\Row\Current >= ListEx()\Row\StartSelect
                      StartRow = ListEx()\Row\StartSelect
                      EndRow   = ListEx()\Row\Current
                    Else
                      StartRow = ListEx()\Row\Current
                      EndRow   = ListEx()\Row\StartSelect
                    EndIf
                    
                    PushListPosition(ListEx()\Rows())
                    ForEach ListEx()\Rows()
                      Row = ListIndex(ListEx()\Rows())
                      If Row >= StartRow And Row <= EndRow
                        ListEx()\Rows()\State | #Selected
                      Else
                        ListEx()\Rows()\State & ~#Selected
                      EndIf  
                    Next
                    PopListPosition(ListEx()\Rows())
                    
                    ListEx()\MultiSelect = #True
                  EndIf
                  
                Else
                  
                  PushListPosition(ListEx()\Rows())
                  
                  ForEach ListEx()\Rows()
                    If ListIndex(ListEx()\Rows()) = ListEx()\Row\Current
                      ListEx()\Rows()\State | #Selected
                    Else  
                      ListEx()\Rows()\State & ~#Selected
                    EndIf
                  Next
                  
                  PopListPosition(ListEx()\Rows())
                  
                  ListEx()\MultiSelect     = #False
                  ListEx()\Row\StartSelect = #PB_Default

                EndIf
                
              EndIf ;}
              
              If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
                ListEx()\Row\Focus = ListEx()\Row\Current
              EndIf
              
              Draw_() ; Draw Focus
              If ListEx()\String\Flag : DrawString_() : EndIf
             ;}              
            ElseIf ListEx()\Cols()\Flags & #Buttons ;{ Button
              
              Value$ = ListEx()\Rows()\Column(Key$)\Value
              
              If Flags & #Image
                Image\ID     = ListEx()\Rows()\Column(Key$)\Image\ID
                Image\Width  = ListEx()\Rows()\Column(Key$)\Image\Width
                Image\Height = ListEx()\Rows()\Column(Key$)\Image\Height
                Image\Flags  = ListEx()\Rows()\Column(Key$)\Image\Flags
              Else
                Image\ID = #False
              EndIf
              
              If Flags & #CellFront
                Debug "#CellFront"
                FrontColor = ListEx()\Rows()\Column(Key$)\Color\Front
              ElseIf ListEx()\Rows()\Color\Front <> #PB_Default
                Debug "ListEx()\Rows()\Color\Front"
                FrontColor = ListEx()\Rows()\Color\Front
              ElseIf ListEx()\Cols()\FrontColor <> #PB_Default
                Debug "ListEx()\Cols()\FrontColor"
                FrontColor = ListEx()\Cols()\FrontColor
              Else
                Debug "ListEx()\Color\Front: " + Str(ListEx()\Color\Front)
                FrontColor = ListEx()\Color\Front
              EndIf
              
              DrawButton_(X, Y, ListEx()\Cols()\Width, ListEx()\Rows()\Height, Value$, #Click, FrontColor, ListEx()\Rows()\FontID, @Image)
              
              ListEx()\Button\Row   = ListEx()\Row\Current
              ListEx()\Button\Col   = ListEx()\Col\Current
              ListEx()\Button\Label = ListEx()\Cols()\Key
              ListEx()\Button\Value = Value$
              ListEx()\Button\RowID = ListEx()\Rows()\ID
              ListEx()\Button\Pressed = #True
              ;}
            ElseIf ListEx()\Cols()\Flags & #Links   ;{ Link
              
              ListEx()\Focus = #True
              ListEx()\Row\Focus = ListEx()\Row\Current
              
              Draw_()
              
              Value$ = ListEx()\Rows()\Column(Key$)\Value
              
              If ListEx()\Rows()\FontID : FontID = ListEx()\Rows()\FontID : EndIf
              If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
              
              ListEx()\Link\Row     = ListEx()\Row\Current
              ListEx()\Link\Col     = ListEx()\Col\Current
              ListEx()\Link\Label   = ListEx()\Cols()\Key
              ListEx()\Link\Value   = Value$
              ListEx()\Link\RowID   = ListEx()\Rows()\ID
              ListEx()\Link\Pressed = #True
              
              If Flags & #Image
                Image\ID     = ListEx()\Rows()\Column(Key$)\Image\ID
                Image\Width  = ListEx()\Rows()\Column(Key$)\Image\Width
                Image\Height = ListEx()\Rows()\Column(Key$)\Image\Height
                Image\Flags  = ListEx()\Rows()\Column(Key$)\Image\Flags
              Else
                Image\ID = #False
              EndIf
              
              DrawLink_(X, Y, ListEx()\Cols()\Width, ListEx()\Rows()\Height, Value$, ListEx()\Color\ActiveLink, ListEx()\Cols()\Align, FontID, @Image)
              ;}
            Else                                    ;{ Select row(s)
              
              ListEx()\Focus = #True
              
              ;{ MultiSelect
              If ListEx()\Flags & #MultiSelect
                
                If GetGadgetAttribute(GNum, #PB_Canvas_Modifiers) = #PB_Canvas_Control
                
                  If ListEx()\MultiSelect = #False
                    PushListPosition(ListEx()\Rows())
                    If SelectElement(ListEx()\Rows(), ListEx()\Row\Focus)
                      ListEx()\Rows()\State | #Selected
                    EndIf
                    PopListPosition(ListEx()\Rows())
                    ListEx()\MultiSelect = #True
                  EndIf
                  
                  ListEx()\Rows()\State ! #Selected
                  ListEx()\Row\StartSelect = #PB_Default
                  
                ElseIf GetGadgetAttribute(GNum, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
                  
                  If ListEx()\Row\StartSelect = #PB_Default :  ListEx()\Row\StartSelect = ListEx()\Row\Focus : EndIf
                  
                  If ListEx()\Row\Focus >= 0
                    
                    If ListEx()\Row\Current >= ListEx()\Row\StartSelect
                      StartRow = ListEx()\Row\StartSelect
                      EndRow   = ListEx()\Row\Current
                    Else
                      StartRow = ListEx()\Row\Current
                      EndRow   = ListEx()\Row\StartSelect
                    EndIf
                    
                    PushListPosition(ListEx()\Rows())
                    ForEach ListEx()\Rows()
                      Row = ListIndex(ListEx()\Rows())
                      If Row >= StartRow And Row <= EndRow
                        ListEx()\Rows()\State | #Selected
                      Else
                        ListEx()\Rows()\State & ~#Selected
                      EndIf  
                    Next
                    PopListPosition(ListEx()\Rows())
                    
                    ListEx()\MultiSelect = #True
                  EndIf
                  
                Else
                  
                  PushListPosition(ListEx()\Rows())
                  
                  ForEach ListEx()\Rows()
                    If ListIndex(ListEx()\Rows()) = ListEx()\Row\Current
                      ListEx()\Rows()\State | #Selected
                    Else  
                      ListEx()\Rows()\State & ~#Selected
                    EndIf
                  Next
                  
                  PopListPosition(ListEx()\Rows())
                  
                  ListEx()\MultiSelect     = #False
                  ListEx()\Row\StartSelect = #PB_Default

                EndIf
                
              EndIf ;}
              
              If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
                ListEx()\Row\Focus = ListEx()\Row\Current
              EndIf
              
              Draw_() ; Draw Focus
              If ListEx()\String\Flag : DrawString_() : EndIf
             ;}
            EndIf
            
            If IsWindow(ListEx()\Window\Num)
              PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Row, ListEx()\Row\Current)
              PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Row, ListEx()\Row\Current)
            EndIf 
            
          EndIf
        EndIf 
        ;}        
      EndIf          
      
    EndIf  
      
  EndProcedure
  
  Procedure _LeftButtonUpHandler()
    Define GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Row\Current = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
      ListEx()\Col\Current = GetColumn_(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      If ListEx()\CanvasCursor = #PB_Cursor_LeftRight Or ListEx()\Col\MouseX
        ListEx()\CanvasCursor = #Cursor_Default
        ListEx()\Col\MouseX = 0
      EndIf
      
      If ListEx()\Row\Current < 0 Or ListEx()\Col\Current < 0 : ProcedureReturn #False : EndIf
      
      If ListEx()\Button\Pressed ;{ Button pressed
        
        If ListEx()\Button\Row = ListEx()\Row\Current And ListEx()\Button\Col = ListEx()\Col\Current
          UpdateEventData_(#EventType_Button, ListEx()\Button\Row, ListEx()\Button\Col, ListEx()\Button\Value, #NotValid, ListEx()\Button\RowID)
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Button)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Button)
          EndIf
        Else
          UpdateEventData_(#EventType_Button, #NotValid, #NotValid, "", #NotValid, "")
        EndIf  
        
        ListEx()\Button\Pressed = #False
        
        Draw_()
        ;}
      EndIf  
      
      If ListEx()\Link\Pressed   ;{ Link pressed
        
        If ListEx()\Link\Row = ListEx()\Row\Current And ListEx()\Link\Col = ListEx()\Col\Current
          UpdateEventData_(#EventType_Button, ListEx()\Link\Row, ListEx()\Link\Col, ListEx()\Link\Value, #NotValid, ListEx()\Link\RowID)
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Link)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Link)
          EndIf
        Else  
          UpdateEventData_(#EventType_Button, #NotValid, #NotValid, "", #NotValid, "")
        EndIf
        
        ListEx()\Link\Pressed = #False
        
        Draw_()
        ;}
      EndIf
      
      UpdateEventData_(#PB_EventType_LeftClick, ListEx()\Row\Current, ListEx()\Col\Current, "", #NotValid, ListEx()\Rows()\ID)
      PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #PB_EventType_LeftClick, ListEx()\Row\Current)
      
    EndIf
    
    
  EndProcedure  
  
  Procedure _LeftDoubleClickHandler()
    Define GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If ListEx()\String\Flag   ;{ Close String
        CloseString_()
      EndIf ;}
      
      If ListEx()\ComboBox\Flag ;{ Close ComboBox
        CloseComboBox_()
      EndIf ;}
      
      If ListEx()\Date\Flag     ;{ Close DateGadget
        CloseDate_()
      EndIf ;}
      
      ListEx()\Row\Current = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
      ListEx()\Col\Current = GetColumn_(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      If ListEx()\Row\Current < 0 Or ListEx()\Col\Current < 0 : ProcedureReturn #False : EndIf
      
      If ListEx()\Row\Current = #Header
        
      Else
        
        ManageEditGadgets_(ListEx()\Row\Current, ListEx()\Col\Current)
 
      EndIf
      
      Draw_()
      
      If ListEx()\String\Flag : DrawString_() : EndIf
   
    EndIf
    
  EndProcedure
  
  
  Procedure _MouseMoveHandler()
    Define.i Row, Column, Flags
    Define.f X, Y
    Define.s Key$, Value$, Focus$
    Define   Image.Image_Structure
    Define.i GNum = EventGadget()

    If FindMapElement(ListEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      If ListEx()\Flags & #ResizeColumn ;{ Resize column with mouse
        
        If ListEx()\CanvasCursor = #PB_Cursor_LeftRight
          
          If ListEx()\Col\MouseX ;{ Resize column
            
            If SelectElement(ListEx()\Cols(), ListEx()\Col\Resize - 1)
              ListEx()\Cols()\Width - (ListEx()\Col\MouseX - X)   
            EndIf
          
            If SelectElement(ListEx()\Cols(), ListEx()\Col\Resize)
              ListEx()\Cols()\X     = X
              ListEx()\Cols()\Width + (ListEx()\Col\MouseX - X) 
            EndIf
           
            ListEx()\Col\MouseX = X
            
            Draw_()
            
            ProcedureReturn #True
          EndIf
          ;}
        Else                                      ;{ Change cursor to #PB_Cursor_LeftRight
          ForEach ListEx()\Cols()
            If X = ListEx()\Cols()\X
              ListEx()\CanvasCursor = #PB_Cursor_LeftRight
              ListEx()\Col\Resize = ListIndex(ListEx()\Cols())
              SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
              ProcedureReturn #True
            EndIf  
          Next ;}
        EndIf
        
      EndIf ;}
      
      Row    = GetRow_(Y)
      Column = GetColumn_(X)
      
      Focus$ = Str(Row)+"|"+Str(Column)
      
      If ListEx()\Button\Focus And ListEx()\Button\Focus <> Focus$
        ListEx()\Button\Focus = ""
        Draw_()
      EndIf
      
      If Row = #NotValid Or Column = #NotValid
        
        If ListEx()\CanvasCursor <> #Cursor_Default
          ListEx()\CanvasCursor = #Cursor_Default
          SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
        EndIf
        
      Else
        
        If Row = #Header ;{ Header
          
          If SelectElement(ListEx()\Cols(), Column)
            If ListEx()\Cols()\Header\Sort & #HeaderSort
              
              If ListEx()\CanvasCursor <> #Cursor_Sort
                ListEx()\CanvasCursor = #Cursor_Sort
                SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
              EndIf
              
            Else
              
              If ListEx()\CanvasCursor <> #Cursor_Default
                ListEx()\CanvasCursor = #Cursor_Default
                SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
              EndIf
              
            EndIf
            
          EndIf
          ;}
        Else             ;{ Rows
          
          If Row < 0 Or Column < 0 : ProcedureReturn #False : EndIf
          
          If SelectElement(ListEx()\Rows(), Row)
            If SelectElement(ListEx()\Cols(), Column)
              
              Y = ListEx()\Rows()\Y - ListEx()\Row\OffsetY
              X = ListEx()\Cols()\X - ListEx()\Col\OffsetX
              
              Key$   = ListEx()\Cols()\Key
              Flags  = ListEx()\Rows()\Column(Key$)\Flags
              
              ; Change Cursor
              If ListEx()\Cols()\Flags & #Strings Or Flags & #Strings
                
                If ListEx()\CanvasCursor <> #Cursor_Edit
                  ListEx()\CanvasCursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #ComboBoxes Or Flags & #ComboBoxes
                
                If ListEx()\CanvasCursor <> #Cursor_Edit
                  ListEx()\CanvasCursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #CheckBoxes
                
                If ListEx()\CanvasCursor <> #Cursor_Edit
                  ListEx()\CanvasCursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Dates Or Flags & #Dates
                
                If ListEx()\CanvasCursor <> #Cursor_Edit
                  ListEx()\CanvasCursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Links
                
                If ListEx()\CanvasCursor <> #Cursor_Click
                  ListEx()\CanvasCursor = #Cursor_Click
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Buttons

                ListEx()\Button\Focus = Focus$
                
                Value$ = ListEx()\Rows()\Column(Key$)\Value
                
                If Flags & #Image
                  Image\ID     = ListEx()\Rows()\Column(Key$)\Image\ID
                  Image\Width  = ListEx()\Rows()\Column(Key$)\Image\Width
                  Image\Height = ListEx()\Rows()\Column(Key$)\Image\Height
                  Image\Flags  = ListEx()\Rows()\Column(Key$)\Image\Flags
                Else
                  Image\ID = #False
                EndIf
              
                DrawButton_(X, Y, ListEx()\Cols()\Width, ListEx()\Rows()\Height, Value$, #Focus, ListEx()\Rows()\Color\Front, ListEx()\Rows()\FontID, @Image)
                
                If ListEx()\CanvasCursor <> #Cursor_Button
                  ListEx()\CanvasCursor = #Cursor_Button
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              Else
                
                If ListEx()\CanvasCursor <> #Cursor_Default
                  ListEx()\CanvasCursor = #Cursor_Default
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              EndIf
              
            EndIf  
          EndIf
          ;}
        EndIf
        
      EndIf
    EndIf  
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      Draw_()
      If ListEx()\String\Flag : DrawString_() : EndIf 
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta
    Define.f ScrollPos
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(ListEx()\VScrollNum) And ListEx()\VScroll\Hide = #False
        
        ScrollPos = GetGadgetState(ListEx()\VScrollNum) - Delta
        
        If ScrollPos > ListEx()\VScroll\MaxPos : ScrollPos = ListEx()\VScroll\MaxPos : EndIf
        If ScrollPos < ListEx()\VScroll\MinPos : ScrollPos = ListEx()\VScroll\MinPos : EndIf
        
        If ScrollPos <> ListEx()\VScroll\Position
          
          ListEx()\Row\Offset = ScrollPos
          SetVScrollPosition_()
          
          UpdateRowY_()
          
          ScrollEditGadgets_() 
          
          Draw_()
          If ListEx()\String\Flag : DrawString_() : EndIf 
          
        EndIf

      EndIf

    EndIf
    
  EndProcedure
  
  CompilerIf #Enable_DragAndDrop
    
    Procedure _GadgetDropHandler()
      Define.s Key$, Text$
      Define.i GadgetNum = EventGadget()
      
      If FindMapElement(ListEx(), Str(GadgetNum))

        ListEx()\Row\Current = GetRow_(EventDropY())
        ListEx()\Col\Current = GetColumn_(EventDropX())
        
        If ListEx()\Row\Current >= 0 And ListEx()\Col\Current >= 0
          
          If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
            If SelectElement(ListEx()\Cols(), ListEx()\Col\Current)
              
              Key$ = ListEx()\Cols()\Key
              
              If ListEx()\Cols()\Flags & #Strings And ListEx()\Rows()\Column(Key$)\Flags & #LockCell = #False
                Text$ = ListEx()\Rows()\Column(Key$)\Value
                If Text$
                  ListEx()\Rows()\Column(Key$)\Value + " " + EventDropText()
                Else
                  ListEx()\Rows()\Column(Key$)\Value = EventDropText()
                EndIf  
                Draw_()
              EndIf
              
            EndIf 
          EndIf
          
        EndIf  
    
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure _ResizeHandler()
    Define.i OffsetX, OffSetY
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      If ListEx()\VScroll\Hide = #False Or ListEx()\HScroll\Hide = #False
        
        If ListEx()\VScroll\Hide
          ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
        Else
          ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
        EndIf
        
        If ListEx()\HScroll\Hide
          ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
        Else  
          ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
        EndIf
        
      EndIf
      
      UpdateColumnX_()
      UpdateRowY_()
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.i  OffSetX, OffsetY

    ForEach ListEx()
      
      If IsGadget(ListEx()\CanvasNum)
        
        If ListEx()\Flags & #AutoResize
          
          If IsWindow(ListEx()\Window\Num)
            
            OffSetX = WindowWidth(ListEx()\Window\Num)  - ListEx()\Window\Width
            OffsetY = WindowHeight(ListEx()\Window\Num) - ListEx()\Window\Height
            
            If ListEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width  = #PB_Ignore : Height = #PB_Ignore
              
              If ListEx()\Size\Flags & #MoveX : X = ListEx()\Size\X + OffSetX : EndIf
              If ListEx()\Size\Flags & #MoveY : Y = ListEx()\Size\Y + OffSetY : EndIf
              If ListEx()\Size\Flags & #Width  : Width  = ListEx()\Size\Width  + OffSetX : EndIf
              If ListEx()\Size\Flags & #Height : Height = ListEx()\Size\Height + OffSetY : EndIf
              
              ResizeGadget(ListEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              
              ResizeGadget(ListEx()\CanvasNum, #PB_Ignore, #PB_Ignore, ListEx()\Size\Width + OffSetX, Height + OffsetY)
              
            EndIf
            
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach ListEx()
    
      If ListEx()\Window\Num = Window
        
        CompilerIf Defined(ModuleEx, #PB_Module) = #False
          If MapSize(ListEx()) = 1
            Thread\Exit = #True
            Delay(100)
            If IsThread(Thread\Num) : KillThread(Thread\Num) : EndIf
            Thread\Active = #False
          EndIf
        CompilerEndIf
        
        DeleteMapElement(ListEx())
        
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure _SynchronizeScrollCols()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.f ScrollPos
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      ScrollPos = GetGadgetState(ScrollNum)
      If ScrollPos <> ListEx()\HScroll\Position
        
        If ScrollPos < ListEx()\Col\OffsetX
          ListEx()\Col\OffsetX = ScrollPos ; - dpiX(20)
        ElseIf ScrollPos > ListEx()\Col\OffsetX
          ListEx()\Col\OffsetX = ScrollPos ;+ dpiX(20)
        EndIf
        
        If ListEx()\Col\OffsetX < ListEx()\HScroll\MinPos : ListEx()\Col\OffsetX = ListEx()\HScroll\MinPos : EndIf
        If ListEx()\Col\OffsetX > ListEx()\HScroll\MaxPos : ListEx()\Col\OffsetX = ListEx()\HScroll\MaxPos : EndIf
        
        SetGadgetState(ScrollNum, ListEx()\Col\OffsetX)
        SetHScrollPosition_()
        
        UpdateRowY_()
        
        ScrollEditGadgets_() 
        
        Draw_()
        If ListEx()\String\Flag : DrawString_() : EndIf 
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _SynchronizeScrollRows()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.f X, Y, ScrollPos
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      ScrollPos = GetGadgetState(ScrollNum)
      If ScrollPos <> ListEx()\VScroll\Position
        
        ListEx()\Row\Offset = ScrollPos

        SetVScrollPosition_()
        
        UpdateRowY_()
        
        ScrollEditGadgets_()
        
        Draw_()
        If ListEx()\String\Flag : DrawString_() : EndIf 
        
      EndIf
      
    EndIf
    
  EndProcedure 
  
  ;- __________ Editing Cells __________
  
  Procedure  BindShortcuts_(Flag.i=#True)
    
    If IsWindow(ListEx()\Window\Num)
      If Flag
        AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Return, #Key_Return)
        AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Escape, #Key_Escape)
        AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab,    #Key_Tab)
        AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab|#PB_Shortcut_Shift, #Key_ShiftTab)
        BindMenuEvent(ListEx()\ShortCutID, #Key_Return,   @_KeyReturnHandler())
        BindMenuEvent(ListEx()\ShortCutID, #Key_Escape,   @_KeyEscapeHandler())
        BindMenuEvent(ListEx()\ShortCutID, #Key_Tab,      @_KeyTabHandler())
        BindMenuEvent(ListEx()\ShortCutID, #Key_ShiftTab, @_KeyShiftTabHandler())
      Else
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_Return,   @_KeyReturnHandler())
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_Escape,   @_KeyEscapeHandler())
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_Tab,      @_KeyTabHandler())
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_ShiftTab, @_KeyShiftTabHandler())
        RemoveKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Return)
        RemoveKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Escape)
        RemoveKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab)
        RemoveKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab|#PB_Shortcut_Shift)
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure  BindTabulator_(Flag.i=#True)
    
    If IsWindow(ListEx()\Window\Num)
      If Flag
        AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab,    #Key_Tab)
        AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab|#PB_Shortcut_Shift, #Key_ShiftTab)
      Else
        RemoveKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab)
        RemoveKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab|#PB_Shortcut_Shift)
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure  CloseString_(Escape.i=#False)
    
    PushListPosition(ListEx()\Rows())
    
    If SelectElement(ListEx()\Rows(), ListEx()\String\Row)
      If SelectElement(ListEx()\Cols(), ListEx()\String\Col)
        
        If IsContentValid_(ListEx()\String\Text) Or Escape

          ListEx()\String\Wrong = #False   
          
          If Escape
            
            UpdateEventData_(#EventType_String, #NotValid, #NotValid, "", #NotValid, "")
            
          Else

            ListEx()\Rows()\Column(ListEx()\String\Label)\Value = ListEx()\String\Text
            
            UpdateEventData_(#EventType_String, ListEx()\String\Row, ListEx()\String\Col, ListEx()\String\Text, #NotValid, ListEx()\Rows()\ID)
            
            If IsWindow(ListEx()\Window\Num)
              PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
              PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
            EndIf 
            
            ListEx()\Changed = #True
          EndIf

          ListEx()\String\Text  = ""
          ListEx()\String\Label = ""
          ListEx()\String\Flag  = #False

        Else

          ListEx()\String\Wrong = #True
          
        EndIf

      EndIf
    EndIf

    PopListPosition(ListEx()\Rows())

    Draw_()
    
  EndProcedure
  
  Procedure  CloseDate_(Escape.i=#False)
    
    If IsGadget(ListEx()\DateNum)
      
      PushListPosition(ListEx()\Rows())
      
      If Escape
        UpdateEventData_(#EventType_Date, #NotValid, #NotValid, "", #NotValid, "")
      Else  
        If SelectElement(ListEx()\Rows(), ListEx()\Date\Row)
          ListEx()\Rows()\Column(ListEx()\Date\Label)\Value = GetGadgetText(ListEx()\DateNum)
          ListEx()\Changed = #True
          UpdateEventData_(#EventType_Date, ListEx()\Date\Row, ListEx()\Date\Col, GetGadgetText(ListEx()\DateNum), GetGadgetState(ListEx()\DateNum), ListEx()\Rows()\ID)
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Date)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Date)
          EndIf    
        EndIf
      EndIf
      
      HideGadget(ListEx()\DateNum, #True)
      BindShortcuts_(#False)
      
      ListEx()\Date\Label = ""
      ListEx()\Date\Flag  = #False
      
      PopListPosition(ListEx()\Rows())
      
      Draw_()        
    EndIf
    
  EndProcedure
  
  Procedure  CloseComboBox_(Escape.i=#False)
    
    If IsGadget(ListEx()\ComboNum)
      
      PushListPosition(ListEx()\Rows())
      
      If Escape
        UpdateEventData_(#EventType_ComboBox, #NotValid, #NotValid, "", #NotValid, "")
      Else
        If SelectElement(ListEx()\Rows(), ListEx()\ComboBox\Row)
          If GetGadgetState(ListEx()\ComboNum) <> #NotSelected
            ListEx()\Rows()\Column(ListEx()\ComboBox\Label)\Value = GetGadgetText(ListEx()\ComboNum)
            ListEx()\Changed = #True
            UpdateEventData_(#EventType_ComboBox,ListEx()\ComboBox\Row, ListEx()\ComboBox\Col, GetGadgetText(ListEx()\ComboNum), GetGadgetState(ListEx()\ComboNum), ListEx()\Rows()\ID)
            If IsWindow(ListEx()\Window\Num)
              PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_ComboBox)
              PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_ComboBox)
            EndIf
          Else
            UpdateEventData_(#EventType_ComboBox, #NotValid, #NotValid, "", #NotValid, "")
          EndIf
        EndIf
      EndIf
      
      HideGadget(ListEx()\ComboNum, #True)
      BindShortcuts_(#False)
      
      ListEx()\ComboBox\Label = ""
      ListEx()\ComboBox\Flag  = #False
      
      PopListPosition(ListEx()\Rows())
      
      Draw_()        
    EndIf
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================  
  
  Procedure DebugList(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Debug "----- Debug -----"
      
      ForEach ListEx()\Rows()
        
        Debug ">>> Row " + Str(ListIndex(ListEx()\Rows()))
        
        ForEach ListEx()\Rows()\Column()
          Debug "Column " + MapKey(ListEx()\Rows()\Column()) + ": " + ListEx()\Rows()\Column()\Value
        Next
        
      Next
      
      Debug "-----------------"
      
    EndIf
    
  EndProcedure  
  
  CompilerIf #Enable_CSV_Support
    
    Procedure ClipBoard(GNum.i, Flags.i=#False, Separator.s=";", DQuote.s=#DQUOTE$)
      ; Flags: #HeaderRow | #Selected/#Checked/#Inbetween
      Define.s CSV$
      
      If FindMapElement(ListEx(), Str(GNum))
        
        If Flags & #HeaderRow
          CSV$ = Export_CSV_Header(Separator, DQuote) + #LF$
        EndIf
        
        PushListPosition(ListEx()\Rows())
        
        ForEach ListEx()\Rows()
          
          If Flags & #Selected
            If ListEx()\Rows()\State & #Selected
              CSV$ + Export_CSV_Row(Separator, DQuote) + #LF$
            EndIf
          ElseIf Flags & #Checked
            If ListEx()\Rows()\State & #Checked
              CSV$ + Export_CSV_Row(Separator, DQuote) + #LF$
            EndIf  
          ElseIf Flags & #Inbetween
            If ListEx()\Rows()\State & #Inbetween
              CSV$ + Export_CSV_Row(Separator, DQuote) + #LF$
            EndIf   
          Else  
            If ListEx()\Rows()\State & #Selected Or ListEx()\Rows()\State & #Checked
              CSV$ + Export_CSV_Row(Separator, DQuote) + #LF$
            EndIf
          EndIf

        Next
        
        PopListPosition(ListEx()\Rows())
        
        SetClipboardText(CSV$)
        
      EndIf
      
    EndProcedure
    
    Procedure ExportCSV(GNum.i, File.s, Flags.i=#False, Separator.s=";", DQuote.s=#DQUOTE$)
      ; Flags: #HeaderRow | #Selected/#Checked/#Inbetween
      Define.i FileID
      Define.s Row$
      
      If FindMapElement(ListEx(), Str(GNum))
        
        FileID = CreateFile(#PB_Any, File)
        If FileID
          
          WriteStringFormat(FileID, #PB_UTF8)
          
          If Flags & #HeaderRow
            Row$ = Export_CSV_Header(Separator, DQuote)
            WriteStringN(FileID, Row$)
          EndIf
          
          PushListPosition(ListEx()\Rows())
          
          ForEach ListEx()\Rows()
            
            If Flags & #Selected
              If ListEx()\Rows()\State & #Selected
               Row$ = Export_CSV_Row(Separator, DQuote)
                WriteStringN(FileID, Row$)
              EndIf
            ElseIf Flags & #Checked
              If ListEx()\Rows()\State & #Checked
                Row$ = Export_CSV_Row(Separator, DQuote)
                WriteStringN(FileID, Row$)
              EndIf  
            ElseIf Flags & #Inbetween
              If ListEx()\Rows()\State & #Inbetween
                Row$ = Export_CSV_Row(Separator, DQuote)
                WriteStringN(FileID, Row$)
              EndIf   
            Else
              Row$ = Export_CSV_Row(Separator, DQuote)
              WriteStringN(FileID, Row$)
            EndIf

          Next
          
          PopListPosition(ListEx()\Rows())
          
          CloseFile(FileID)
        EndIf

      EndIf  
      
    EndProcedure  
    
    Procedure ImportCSV(GNum.i, File.s, Flags.i=#False, Separator.s=";", DQuote.s=#DQUOTE$)
      ; Flags: #HeaderRow
      Define.i FileID, BOM
      Define.s Row$
      
      If FindMapElement(ListEx(), Str(GNum))
        
        FileID = ReadFile(#PB_Any, File)
        If FileID
          
          BOM = ReadStringFormat(FileID)
          
          If Flags & #HeaderRow
            Row$ = ReadString(FileID, BOM)
            Import_CSV_Header(Row$, Separator, DQuote)
          EndIf
          
          While Eof(FileID) = #False
            Row$ = ReadString(FileID, BOM)
            Import_CSV_Row(Row$, Separator, DQuote)
          Wend

          CloseFile(FileID)
        EndIf
        
        If ListEx()\ReDraw
          If ListEx()\FitCols : FitColumns_() : EndIf
          UpdateRowY_()
          Draw_()
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf  
  
  CompilerIf #Enable_MarkContent
 
    Procedure   MarkContent(GNum.i, Column.i, Term.s, Color1.i=#PB_Default, Color2.i=#PB_Default, FontID.i=#PB_Default)
      
      If FindMapElement(ListEx(), Str(GNum))
        
        If SelectElement(ListEx()\Cols(), Column)
          MarkContent_(Term, Color1, Color2, FontID)
          If ListEx()\FitCols : FitColumns_() : EndIf
          Draw_()
        EndIf
        
      EndIf  
   
    EndProcedure
    
  CompilerEndIf

  Procedure.i AddColumn(GNum.i, Column.i, Title.s, Width.f, Label.s="", Flags.i=#False)
    Define.s Term
    Define.i Result
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ;{ Add Column
      Select Column
        Case #FirstItem
          FirstElement(ListEx()\Cols())
          Result = InsertElement(ListEx()\Cols()) 
        Case #LastItem
          LastElement(ListEx()\Cols())
          Result = AddElement(ListEx()\Cols())
        Default
          If SelectElement(ListEx()\Cols(), Column)
            Result = InsertElement(ListEx()\Cols()) 
          Else
            LastElement(ListEx()\Cols())
            Result = AddElement(ListEx()\Cols())
          EndIf
      EndSelect ;}
      
      If Result
        
        If Flags & #Right
          ListEx()\Cols()\Align = #Right
          Flags & ~#Right
        ElseIf Flags & #Center
          ListEx()\Cols()\Align = #Center
          Flags & ~#Center
        ElseIf Flags & #Left
          ListEx()\Cols()\Align = #Left
          Flags & ~#Left
        EndIf
        
        If Flags & #FitColumn : ListEx()\FitCols = #True : EndIf
        
        ListEx()\Col\Number               = ListSize(ListEx()\Cols())
        ListEx()\Cols()\Header\Title      = Title
        ListEx()\Cols()\Header\Align      = #PB_Default
        ListEx()\Cols()\Header\FontID     = #PB_Default
        ListEx()\Cols()\Header\FrontColor = #PB_Default
        ListEx()\Cols()\Header\BackColor  = #PB_Default
        ListEx()\Cols()\Width             = Width
        ListEx()\Cols()\Currency          = ListEx()\Country\Currency
        ListEx()\Cols()\FrontColor        = #PB_Default
        ListEx()\Cols()\BackColor         = #PB_Default
        ListEx()\Cols()\Flags             = Flags

        If Label
          ListEx()\Cols()\Key = Label
        Else
          ListEx()\Cols()\Key = Str(ListEx()\Col\Number - 1)
        EndIf
        
        CompilerIf #Enable_Validation
          If ListEx()\Cols()\Flags & #Grades : LoadGrades() : EndIf 
        CompilerEndIf
        
        CompilerIf #Enable_MarkContent
          If ListEx()\Cols()\Flags & #Grades
            Term = Grades(ListEx()\Country\Code)\Term
            If Term : MarkContent_(Term, $008000, $0000FF, #PB_Default) : EndIf
          EndIf
        CompilerEndIf  
        
        If ListEx()\ReDraw
          UpdateColumnX_()
          Draw_()
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn ListEx()\Col\Number
  EndProcedure
  
  Procedure.i AddComboBoxItems(GNum.i, Column.i, Text.s)
    Define.i i, Count
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Key$ = ListEx()\Cols()\Key
        
        Count = CountString(Text, #LF$) + 1
        For i = 1 To Count
          AddElement(ListEx()\ComboBox\Column(Key$)\Items())
          ListEx()\ComboBox\Column(Key$)\Items() = StringField(Text, i, #LF$)
        Next
        
      EndIf  
        
      ProcedureReturn ListSize(ListEx()\ComboBox\Column(Key$)\Items())      
    EndIf
    
  EndProcedure
  
  Procedure.i AddCells(GNum.i, Row.i=-1, Labels.s="", Text.s="", RowID.s="", Flags.i=#False) 
    Define.i i, Result, FitColumn, CountLabel, CountText
    Define.s Text$, Label$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ;{ Add item
      Select Row
        Case #FirstItem
          FirstElement(ListEx()\Rows())
          Result = InsertElement(ListEx()\Rows()) 
        Case #LastItem
          LastElement(ListEx()\Rows())
          Result = AddElement(ListEx()\Rows())
        Default
          If SelectElement(ListEx()\Rows(), Row)
            Result = InsertElement(ListEx()\Rows()) 
          Else
            LastElement(ListEx()\Rows())
            Result = AddElement(ListEx()\Rows())
          EndIf
      EndSelect ;}
      
      If Result
      
        ListEx()\Row\Number    = ListSize(ListEx()\Rows())
        ListEx()\Rows()\ID     = RowID
        ListEx()\Rows()\Height = ListEx()\Row\Height
        
        ListEx()\Rows()\FontID = ListEx()\Row\FontID
        
        ListEx()\Rows()\Color\Front = ListEx()\Color\Front
        ListEx()\Rows()\Color\Back  = ListEx()\Color\Back
        ListEx()\Rows()\Color\Line  = ListEx()\Color\Line
          
        If Text <> ""
          
          CountText  = CountString(Text,   #LF$) + 1
          CountLabel = CountString(Labels, "|")  + 1
          
          If CountText <> CountLabel : ProcedureReturn #False : EndIf
          
          FitColumn = #False
          
          For i=1 To CountText
            
            Label$ = StringField(Labels, i, "|")
            Text$  = StringField(Text,  i, #LF$)
            
            ListEx()\Rows()\Column(Label$)\Value = Text$

          Next
          
        EndIf
        
      EndIf

      If ListEx()\ReDraw
        If ListEx()\FitCols : FitColumns_() : EndIf
        UpdateRowY_()
        Draw_()
      EndIf

    EndIf
    
    ProcedureReturn ListIndex(ListEx()\Rows())
  EndProcedure
  
  Procedure.i AddItem(GNum.i, Row.i=-1, Text.s="", Label.s="", Flags.i=#False) 
    Define.i Index = #PB_Default
    
    If FindMapElement(ListEx(), Str(GNum))

      Index = AddItem_(Row, Text, Label, Flags) 

      If ListEx()\ReDraw
        If ListEx()\FitCols : FitColumns_() : EndIf
        UpdateRowY_()
        Draw_()
      EndIf

    EndIf
    
    ProcedureReturn Index
  EndProcedure
  
  Procedure   AttachPopupMenu(GNum.i, Popup.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\PopUpID = Popup
      
    EndIf
    
  EndProcedure
  
  Procedure   ChangeCountrySettings(GNum.i, CountryCode.s, Currency.s="", Clock.s="", DecimalSeperator.s="", TimeSeperator.s="", DateSeperator.s="")
    
    If CountryCode : ListEx()\Country\Code     = CountryCode : EndIf
    If Currency    : ListEx()\Country\Currency = Currency    : EndIf
    If Clock       : ListEx()\Country\Clock    = Clock       : EndIf
    
    If TimeSeperator    : ListEx()\Country\TimeSeparator    = TimeSeperator    : EndIf
    If DateSeperator    : ListEx()\Country\DateSeperator    = DateSeperator    : EndIf
    If DecimalSeperator : ListEx()\Country\DecimalSeperator = DecimalSeperator : EndIf
   
  EndProcedure
  
  Procedure   ClearComboBoxItems(GNum.i, Column.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        If FindMapElement(ListEx()\ComboBox\Column(), ListEx()\Cols()\Key)
          ClearList(ListEx()\ComboBox\Column()\Items())
        EndIf  
      
      EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure   ClearItems(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ClearList(ListEx()\Rows())
      
      ListEx()\Row\Number = 0
      UpdateRowY_()
      
      Draw_()
    EndIf
    
  EndProcedure    
  
  Procedure   CloseEdit(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If ListEx()\String\Flag   ;{ Close String
        CloseString_()
      EndIf ;}
      
      If ListEx()\ComboBox\Flag ;{ Close ComboBox
        CloseComboBox_()
      EndIf ;}
      
      If ListEx()\Date\Flag     ;{ Close DateGadget
        CloseDate_()
      EndIf ;}
      
      Draw_()
      
    EndIf
      
  EndProcedure
  
  Procedure.i CountItems(GNum.i, Flag.i=#False)     ; [#Selected/#Checked/#Inbetween]
    Define.i Count
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Flag
        Case #Selected
          If ListEx()\MultiSelect
            ForEach ListEx()\Rows()
              If ListEx()\Rows()\State & #Selected : Count + 1 : EndIf
            Next
          ElseIf ListEx()\Focus 
            Count = 1
          EndIf  
          ProcedureReturn Count
        Case #Checked
          ForEach ListEx()\Rows()
            If ListEx()\Rows()\State & #Checked : Count + 1 : EndIf
          Next  
          ProcedureReturn Count
        Case #Inbetween
          ForEach ListEx()\Rows()
            If ListEx()\Rows()\State & #Inbetween : Count + 1 : EndIf
          Next   
          ProcedureReturn Count
        Default
          ProcedureReturn ListSize(ListEx()\Rows())
      EndSelect
    EndIf  
 
  EndProcedure  
  
  Procedure   DisableEditing(GNum.i, State.i=#True)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If State = #True
        ListEx()\Editable = #False
      Else
        ListEx()\Editable = #True
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   DisableReDraw(GNum.i, State.i=#True)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If State
        ListEx()\ReDraw = #False
      Else
        ListEx()\ReDraw = #True
        UpdateRowY_()
        UpdateColumnX_()
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure.i EventRow(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ProcedureReturn ListEx()\Event\Row
    
    EndIf
    
  EndProcedure
  
  Procedure.i EventColumn(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\Column
    EndIf  
    
  EndProcedure
  
  Procedure.i EventState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\State
    EndIf  
    
  EndProcedure  
  
  Procedure.s EventValue(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\Value
    EndIf  
    
  EndProcedure
  
  Procedure.s EventID(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\ID
    EndIf  
    
  EndProcedure
  
  
  Procedure.i Gadget(GNum.i, X.f, Y.f, Width.f, Height.f, ColTitle.s, ColWidth.f, ColLabel.s="", Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result
    
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
    
    CompilerIf Defined(ModuleEx, #PB_Module)
      If #Version < ModuleEx::#Version : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf  
    
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf

      If ColLabel = "" : ColLabel = "0" : EndIf
      
      If AddMapElement(ListEx(), Str(GNum))

        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default  
            ListEx()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            ListEx()\Window\Num = WindowNum
          EndIf  
        CompilerElse
          If WindowNum = #PB_Default 
            ListEx()\Window\Num = GetActiveWindow()
          Else
            ListEx()\Window\Num = WindowNum
          EndIf  
        CompilerEndIf
        
        ListEx()\CanvasNum = GNum
        
        CompilerIf Defined(ModuleEx, #PB_Module)

          If ModuleEx::AddWindow(ListEx()\Window\Num, ModuleEx::#Tabulator|ModuleEx::#CursorEvent)
            ModuleEx::AddGadget(GNum, ListEx()\Window\Num, ModuleEx::#UseTabulator)
          EndIf
          
        CompilerElse
          
          If Thread\Active = #False
            Thread\Exit   = #False
            Thread\Num    = CreateThread(@_CursorThread(), #CursorFrequency)
            Thread\Active = #True
          EndIf
          
        CompilerEndIf
        
        ListEx()\Flags  = Flags
        ListEx()\ReDraw = #True
        
        ListEx()\Row\Height = 20 ; Default row height
        ListEx()\Col\Width  = 50 ; Default column width
        
        If Flags & #NumberedColumn : ListEx()\Col\CheckBoxes = 1 : EndIf
        
        ListEx()\CanvasCursor = #Cursor_Default
        ListEx()\Editable     = #True
        
        ListEx()\ProgressBar\Minimum = 0
        ListEx()\ProgressBar\Maximum = 100
        
        ListEx()\PopUpID = -1
        
        ;{ Country defaults
        ListEx()\Country\Code     = #DefaultCountry
        ListEx()\Country\Currency = #DefaultCurrency
        ListEx()\Country\Clock    = #DefaultClock
        ListEx()\Country\TimeSeparator    = #DefaultTimeSeparator
        ListEx()\Country\DateSeperator    = #DefaultDateSeparator
        ListEx()\Country\DecimalSeperator = #DefaultDecimalSeperator
        ListEx()\Country\TimeMask         = #DefaultTimeMask
        ListEx()\Country\DateMask         = #DefaultDateMask
        ;}
        
        ;{ Event Data
        ListEx()\Event\Type   = #NotValid
        ListEx()\Event\Row    = #NotValid
        ListEx()\Event\Column = #NotValid
        ListEx()\Event\State  = #NotValid
        ;}
        
        ;{ Size
        ListEx()\Size\X = 0
        ListEx()\Size\Y = 0
        ListEx()\Size\Width  = Width
        ListEx()\Size\Height = Height
        If IsWindow(ListEx()\Window\Num)
          ListEx()\Window\Width  = WindowWidth(ListEx()\Window\Num)
          ListEx()\Window\Height = WindowHeight(ListEx()\Window\Num)
        EndIf
        ;}        

        ;{ Gadgets
        ListEx()\ComboNum = ComboBoxGadget(#PB_Any, 0, 0, 0, 0, #PB_ComboBox_Editable)
        If IsGadget(ListEx()\ComboNum)
          SetGadgetData(ListEx()\ComboNum, ListEx()\CanvasNum)
          HideGadget(ListEx()\ComboNum, #True)
        EndIf
        
        ListEx()\DateNum = DateGadget(#PB_Any, 0, 0, 0, 0, ListEx()\Country\DateMask)
        If IsGadget(ListEx()\DateNum)
          SetGadgetData(ListEx()\DateNum, ListEx()\CanvasNum)
          HideGadget(ListEx()\DateNum, #True)
        EndIf
        ListEx()\Date\Mask = ListEx()\Country\DateMask
        
        ListEx()\HScrollNum = ScrollBarGadget(#PB_Any, 0, 0, 0, 0, 0, 0, 0)
        If IsGadget(ListEx()\HScrollNum)
          SetGadgetData(ListEx()\HScrollNum, ListEx()\CanvasNum)
          ListEx()\HScroll\Hide = #True
          HideGadget(ListEx()\HScrollNum, #True)
        EndIf
        
        ListEx()\VScrollNum = ScrollBarGadget(#PB_Any, 0, 0, 0, 0, 0, 0, 0, #PB_ScrollBar_Vertical)
        If IsGadget(ListEx()\VScrollNum)
          SetGadgetData(ListEx()\VScrollNum, ListEx()\CanvasNum)
          ListEx()\VScroll\Hide = #True
          HideGadget(ListEx()\VScrollNum, #True)
        EndIf ;}
        
        ;{ Shortcuts
        If IsWindow(ListEx()\Window\Num)
          ListEx()\ShortCutID = CreateMenu(#PB_Any, WindowID(ListEx()\Window\Num))
          If Flags & #AutoResize
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ListEx()\Window\Num)
          EndIf
          BindEvent(#PB_Event_CloseWindow,  @_CloseWindowHandler(),  ListEx()\Window\Num)
        Else
          Debug "ERROR: No active Window"
        EndIf ;}
        
        ;{ Header
        If Flags & #NoRowHeader
          ListEx()\Header\Height = 0
        Else  
          ListEx()\Header\Height = 20
        EndIf
        ListEx()\Header\FontID   = FontID(LoadFont(#PB_Any, "Arial", 9))  
        ListEx()\Header\Align    = #False
        ;}
        
        ;{ Rows
        ListEx()\Row\Focus       = #NotValid
        ListEx()\Row\Current     = #NoFocus
        ListEx()\Row\StartSelect = #PB_Default
        ListEx()\Row\FontID  = ListEx()\Header\FontID
        ListEx()\Size\Rows   = ListEx()\Row\Height ; Height of all rows
        ;}
        
        ;{ Column
        ListEx()\Col\Padding = 5
        
        If AddElement(ListEx()\Cols())
          ListEx()\Cols()\Header\Title      = ColTitle
          ListEx()\Cols()\Header\Align      = #PB_Default
          ListEx()\Cols()\Header\FontID     = #PB_Default
          ListEx()\Cols()\Header\FrontColor = #PB_Default
          ListEx()\Cols()\Header\BackColor  = #PB_Default
          ListEx()\Cols()\Width             = ColWidth
          ListEx()\Cols()\Key               = ColLabel
          ListEx()\Cols()\FrontColor        = #PB_Default
          ListEx()\Cols()\BackColor         = #PB_Default
          ListEx()\Col\Number = 1      ; Number of columns
        EndIf
        
        ListEx()\Size\Cols           = ListEx()\Cols()\Width ; Width of all columns
        ListEx()\Sort\Column         = #NotValid
        ListEx()\AutoResize\MinWidth = ListEx()\Col\Width
        ListEx()\AutoResize\Column   = #PB_Ignore
        ;} 
        
        ;{ Default Colors
        ListEx()\Color\Front        = $000000
        ListEx()\Color\Back         = $FFFFFF
        ListEx()\Color\Canvas       = $FFFFFF
        ListEx()\Color\ScrollBar    = $F0F0F0
        ListEx()\Color\Focus        = $D77800
        ListEx()\Color\HeaderFront  = $000000
        ListEx()\Color\HeaderBack   = $FAFAFA
        ListEx()\Color\HeaderLine   = $A0A0A0
        ListEx()\Color\Line         = $E3E3E3
        ListEx()\Color\ButtonBack   = $E3E3E3
        ListEx()\Color\ButtonBorder = $A0A0A0
        ListEx()\Color\ProgressBar  = $32CD32
        ListEx()\Color\Gradient     = $00FC7C
        ListEx()\Color\Edit         = $BE7D61
        ListEx()\Color\Link         = $8B0000
        ListEx()\Color\ActiveLink   = $FF0000
        ListEx()\Color\WrongFront   = $0000FF
        ListEx()\Color\WrongBack    = $FFFFFF
        ListEx()\Color\Mark1        = $008B45
        ListEx()\Color\Mark2        = $0000FF
        
        CompilerSelect  #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            ListEx()\Color\HeaderFront  = GetSysColor_(#COLOR_WINDOWTEXT)
            ;ListEx()\Color\HeaderBack   = GetSysColor_(#COLOR_3DLIGHT)
            ListEx()\Color\HeaderLine   = GetSysColor_(#COLOR_3DSHADOW)
            ListEx()\Color\Front        = GetSysColor_(#COLOR_WINDOWTEXT)
            ListEx()\Color\Back         = GetSysColor_(#COLOR_WINDOW)
            ListEx()\Color\Line         = GetSysColor_(#COLOR_3DLIGHT)
            ListEx()\Color\Canvas       = GetSysColor_(#COLOR_WINDOW)
            ListEx()\Color\ScrollBar    = GetSysColor_(#COLOR_MENU)
            ListEx()\Color\Focus        = GetSysColor_(#COLOR_MENUHILIGHT)
            ListEx()\Color\ButtonBack   = GetSysColor_(#COLOR_3DLIGHT)
            ListEx()\Color\ButtonBorder = GetSysColor_(#COLOR_3DSHADOW) 
          CompilerCase #PB_OS_MacOS
            ListEx()\Color\HeaderFront  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ;ListEx()\Color\HeaderBack   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ListEx()\Color\HeaderLine   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ListEx()\Color\Front        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ListEx()\Color\Back         = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ListEx()\Color\Canvas       = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ListEx()\Color\Line         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ListEx()\Color\ScrollBar    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            ListEx()\Color\Focus        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
            ListEx()\Color\ButtonBack   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ListEx()\Color\ButtonBorder = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux
            
        CompilerEndSelect
        
        ListEx()\Color\AlternateRow = ListEx()\Color\Back
        ;}
        
        BindGadgetEvent(ListEx()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(ListEx()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
        BindGadgetEvent(ListEx()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        BindGadgetEvent(ListEx()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(ListEx()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        BindGadgetEvent(ListEx()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
        BindGadgetEvent(ListEx()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
        BindGadgetEvent(ListEx()\CanvasNum,  @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
        BindGadgetEvent(ListEx()\CanvasNum,  @_KeyDownHandler(),         #PB_EventType_KeyDown)  
        BindGadgetEvent(ListEx()\CanvasNum,  @_InputHandler(),           #PB_EventType_Input)
        BindGadgetEvent(ListEx()\HScrollNum, @_SynchronizeScrollCols(),  #PB_All)
        BindGadgetEvent(ListEx()\VScrollNum, @_SynchronizeScrollRows(),  #PB_All) 
        
        BindEvent(#Event_Cursor, @_CursorDrawing())

        CompilerIf #Enable_DragAndDrop
          EnableGadgetDrop(ListEx()\CanvasNum, #PB_Drop_Text, #PB_Drag_Copy)
          BindEvent(#PB_Event_GadgetDrop, @_GadgetDropHandler(), ListEx()\Window\Num, ListEx()\CanvasNum)
        CompilerEndIf
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
        
        Draw_()
        
      EndIf 
      
      CloseGadgetList()
    EndIf
    
    ProcedureReturn ListEx()\CanvasNum
  EndProcedure  
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Attribute
        Case #ColumnCount  
          ProcedureReturn ListSize(ListEx()\Cols())
        Case #Gadget  
          ProcedureReturn ListEx()\CanvasNum
      EndSelect
  
    EndIf
    
  EndProcedure  
  
  Procedure.s GetCellText(GNum.i, Row.i, Label.s)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\Column(Label)\Value
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetCellState(GNum.i, Row.i, Label.s) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\Column(Label)\State
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   GetChangedState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Changed
    EndIf
    
  EndProcedure
  
  Procedure.i GetColumnAttribute(GNum.i, Column.i, Attribute.i)
    ; Attrib: #Align / #ColumnWidth / #FontID
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Select Attribute
          Case #Align
            ProcedureReturn ListEx()\Cols()\Align 
          Case #FontID
            ProcedureReturn ListEx()\Cols()\FontID 
          Case #ColumnWidth
            ProcedureReturn ListEx()\Cols()\Width
        EndSelect
      
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure.i GetColumnFromLabel(GNum.i, Label.s)
    Define.i Column = #PB_Default
    
    If FindMapElement(ListEx(), Str(GNum))

      PushListPosition(ListEx()\Cols())
      
      ForEach ListEx()\Cols()
        If ListEx()\Cols()\Key = Label
          Column = ListIndex(ListEx()\Cols())
          Break
        EndIf
      Next
      
      PopListPosition(ListEx()\Cols())
      
    EndIf
    
    ProcedureReturn Column
  EndProcedure
  
  Procedure.s GetColumnLabel(GNum.i, Column.i)

    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        ProcedureReturn ListEx()\Cols()\Key 
      EndIf
      
    EndIf
    
  EndProcedure    
  
  Procedure.i GetColumnState(GNum.i, Row.i, Column.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row < 0 : ProcedureReturn #False : EndIf
      
      If SelectElement(ListEx()\Rows(), Row)
        If SelectElement(ListEx()\Cols(), Column)
          ProcedureReturn ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State
        EndIf  
      EndIf
      
    EndIf   
 
  EndProcedure

  Procedure.i GetItemData(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row < 0 : ProcedureReturn #False : EndIf
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\iData
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.s GetItemID(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row < 0 : ProcedureReturn "" : EndIf
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\ID
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure.i GetRowFromLabel(GNum.i, Label.s)
    Define.i Row = #PB_Default
    
    If FindMapElement(ListEx(), Str(GNum))
      
      PushListPosition(ListEx()\Rows())
      
      ForEach ListEx()\Rows()
        If ListEx()\Rows()\ID = Label
          Row = ListIndex(ListEx()\Rows())
          Break
        EndIf
      Next
      
      PopListPosition(ListEx()\Rows())
      
    EndIf
    
    ProcedureReturn Row
  EndProcedure
  
  Procedure.s GetRowLabel(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn GetItemID(GNum, Row)
    EndIf
    
  EndProcedure
  
  Procedure.i GetItemState(GNum.i, Row.i, Column.i=#PB_Ignore) ; [#Selected/#Checked/#Inbetween]
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row < 0 : ProcedureReturn #False : EndIf
      
      If SelectElement(ListEx()\Rows(), Row)
        If Column = #PB_Ignore
          ProcedureReturn ListEx()\Rows()\State
        Else
          If SelectElement(ListEx()\Cols(), Column)
            If ListEx()\Flags & #CheckBoxes And Column = 0
              ProcedureReturn ListEx()\Rows()\State
            Else  
              ProcedureReturn ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State
            EndIf
          EndIf 
        EndIf
      EndIf
      
    EndIf  
    
  EndProcedure   
  
  Procedure.s GetItemText(GNum.i, Row.i, Column.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #Header
        If SelectElement(ListEx()\Cols(), Column)
          ProcedureReturn ListEx()\Cols()\Header\Title
        EndIf
      Else  
        If SelectElement(ListEx()\Rows(), Row)
          If SelectElement(ListEx()\Cols(), Column)
            ProcedureReturn ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Row\Focus
    EndIf
    
  EndProcedure
  
  
  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Hide  = State
      HideGadget(GNum, State)

    EndIf
    
  EndProcedure
  
  Procedure.i HideColumn(GNum.i, Column.i, State.i=#True)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        If State
          ListEx()\Cols()\Flags | #Hide 
        Else
          ListEx()\Cols()\Flags & ~#Hide
        EndIf
      EndIf
      
      If ListEx()\ReDraw
        UpdateColumnX_()
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure   LoadColorTheme(GNum.i, File.s)
    Define.i JSON
    
    If FindMapElement(ListEx(), Str(GNum))
      
      JSON = LoadJSON(#PB_Any, File)
      If JSON
        ExtractJSONStructure(JSONValue(JSON), @ListEx()\Color, ListEx_Color_Structure)
        FreeJSON(JSON)
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   Refresh(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\ReDraw = #True
      UpdateRowY_()
      UpdateColumnX_()
      If ListEx()\FitCols : FitColumns_() : EndIf
      Draw_()
      
    EndIf  
   
  EndProcedure
  
  Procedure   RemoveCellFlag(GNum.i, Row.i, Column.i, Flag.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        If SelectElement(ListEx()\Cols(), Column)
  
          ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags & ~Flag
          
          If ListEx()\ReDraw
            If ListEx()\FitCols : FitColumns_() : EndIf
            Draw_()
          EndIf
          
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   RemoveFlag(GNum.i, Flag.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Flags & ~Flag
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf  
    
  EndProcedure  
  
  Procedure   RemoveColumnFlag(GNum.i, Column.i, Flag.i)

    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        ListEx()\Cols()\Flags & ~Flag
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   RemoveColumn(GNum.i, Column.i)
    Define.s Key$, Col$ 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Col$ = Str(Column)
        Key$ = ListEx()\Cols()\Key
        
        ForEach ListEx()\Rows()
          DeleteMapElement(ListEx()\Rows()\Column(), Key$)
        Next
        
        DeleteMapElement(ListEx()\ComboBox\Column(), Key$)
        DeleteMapElement(ListEx()\Date\Column(), Key$)
        
        DeleteElement(ListEx()\Cols())
        
        ListEx()\Col\Number = ListSize(ListEx()\Cols())
        
        UpdateColumnX_()
        
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
  
  EndProcedure
  
  Procedure   RemoveItem(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        DeleteElement(ListEx()\Rows())
        UpdateRowY_()
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
   
  EndProcedure  
  
  Procedure   RemoveItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore) ; [#Selected/#Checked/#Inbetween]
    
    If FindMapElement(ListEx(), Str(GNum))

      If Row >= 0
        
        If SelectElement(ListEx()\Rows(), Row)
          If Column = #PB_Ignore
            
            ListEx()\Rows()\State & ~State
            
          Else
            
            If ListEx()\Flags & #CheckBoxes And Column = 0
              ListEx()\Rows()\State & ~State
              If ListEx()\ReDraw : Draw_() : EndIf 
            Else  
              If SelectElement(ListEx()\Cols(), Column)
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State & ~State
              EndIf 
            EndIf
            
          EndIf
          
          If ListEx()\ReDraw : Draw_() : EndIf
        EndIf
        
      EndIf
    EndIf
    
  EndProcedure
  
  
  Procedure   ResetChangedState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ListEx()\Changed = #False
    EndIf
    
  EndProcedure  
  
  
  Procedure   SaveColorTheme(GNum.i, File.s)
    Define.i JSON
    
    If FindMapElement(ListEx(), Str(GNum))
      
      JSON = CreateJSON(#PB_Any)
      If JSON
        InsertJSONStructure(JSONValue(JSON), @ListEx()\Color, ListEx_Color_Structure)
        SaveJSON(JSON, File)
        FreeJSON(JSON)
      EndIf
     
    EndIf  
    
  EndProcedure  
  
  
  Procedure.i SelectItems(GNum.i, Flag.i=#All)
    ; #All / #None
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If ListEx()\Flags & #MultiSelect
        
        PushListPosition(ListEx()\Rows())
        
        ForEach ListEx()\Rows()
          If Flag = #All
            ListEx()\Rows()\State | #Selected
          Else
            ListEx()\Rows()\State & ~#Selected
          EndIf
        Next
        
        PopListPosition(ListEx()\Rows())
        
        ListEx()\MultiSelect = Flag
        
      Else
        ProcedureReturn #False
      EndIf
      
      If ListEx()\ReDraw : Draw_() : EndIf
      
    EndIf  
      
  EndProcedure
  
  
  Procedure   SetAttribute(GNum.i, Attrib.i, Value.i)
    ; Attrib: #Padding
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Attrib
        Case #Padding
          ListEx()\Col\Padding = Value
      EndSelect
      
      If ListEx()\ReDraw : Draw_() : EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetAutoResizeColumn(GNum.i, Column.i, minWidth.f=#PB_Default, maxWidth.f=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If minWidth = #PB_Default : minWidth = ListEx()\Col\Width : EndIf
      
      ListEx()\AutoResize\Column   = Column
      ListEx()\AutoResize\minWidth = minWidth
      ListEx()\AutoResize\maxWidth = maxWidth
      If SelectElement(ListEx()\Cols(), Column) : ListEx()\AutoResize\Width = ListEx()\Cols()\Width : EndIf
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf  
 
  EndProcedure  
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure

  Procedure   SetCellFlags(GNum.i, Row.i, Column.i, Flags.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        If SelectElement(ListEx()\Cols(), Column)
  
          ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags | Flags
          
          If ListEx()\ReDraw
            If ListEx()\FitCols : FitColumns_() : EndIf
            Draw_()
          EndIf
          
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure

  Procedure   SetCellText(GNum.i, Row.i, Label.s, Text.s)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        
        If ListEx()\Rows()\Column(Label)\Value <> Text
          
          ListEx()\Rows()\Column(Label)\Value = Text
          
          If ListEx()\ReDraw
            If ListEx()\FitCols : FitColumns_() : EndIf
            Draw_()
          EndIf
          
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetCellState(GNum.i, Row.i, Label.s, State.i) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\Column(Label)\State = State
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)         ; GNum: #Theme => change all gadgets
    
    If GNum = #Theme 
      
      ForEach ListEx()
        
        SetColor_(ColorTyp, Value)
        
        If ListEx()\ReDraw : Draw_() : EndIf
      Next
      
    ElseIf FindMapElement(ListEx(), Str(GNum))
      
      SetColor_(ColorTyp, Value, Column)

      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetColorTheme(GNum.i, Theme.i=#Theme_Default, File.s="")           ; GNum: #Theme => change all gadgets
    Define.i JSON
    
    If GNum = #Theme 
      
      If Theme = #Theme_Custom
        JSON = LoadJSON(#PB_Any, File)
      EndIf  
      
      ForEach ListEx()
        
        If Theme = #Theme_Custom 
          If IsJSON(JSON) : ExtractJSONStructure(JSONValue(JSON), @ListEx()\Color, ListEx_Color_Structure) : EndIf
        Else
          ColorTheme_(Theme)
        EndIf
        
        Draw_()
      Next
      
      If Theme = #Theme_Custom
        If IsJSON(JSON) : FreeJSON(JSON) : EndIf
      EndIf  
      
    ElseIf FindMapElement(ListEx(), Str(GNum))

      If Theme = #Theme_Custom 
        JSON = LoadJSON(#PB_Any, File)
        If JSON
          ExtractJSONStructure(JSONValue(JSON), @ListEx()\Color, ListEx_Color_Structure)
          FreeJSON(JSON)
        EndIf
      Else
        ColorTheme_(Theme)
      EndIf
    
      Draw_()
    EndIf  
    
  EndProcedure  
  
  Procedure   SetColumnAttribute(GNum.i, Column.i, Attrib.i, Value.i)
    ; Attrib: #Align (#Left/#Right/#Center) / #ColumnWidth / #Font
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Select Attrib
          Case #Align
            ListEx()\Cols()\Align  = Value
          Case #ColumnWidth
            ListEx()\Cols()\Width  = Value
            UpdateColumnX_()
          Case #FontID
            ListEx()\Cols()\FontID = Value
          Case #Font  
            ListEx()\Cols()\FontID = FontID(Value)
        EndSelect
        
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf 
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetColumnFlags(GNum.i, Column.i, Flags.i)

    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        ListEx()\Cols()\Flags | Flags
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetColumnState(GNum.i, Row.i, Column.i, State.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State = State
          If ListEx()\ReDraw : Draw_() : EndIf
        EndIf  
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetCurrency(GNum.i, String.s, Column.i=#PB_Ignore)                 ; GNum: #Theme => change all gadgets
    
    If GNum = #Theme 
      
      ForEach ListEx()
        ListEx()\Country\Currency = String
      Next
      
    ElseIf FindMapElement(ListEx(), Str(GNum))
    
      If Column = #PB_Ignore 
        ListEx()\Country\Currency = String
      Else
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Cols()\Currency = String
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure  

  Procedure   SetDateAttribute(GNum.i, Column.i, Attrib.i, Value.i)
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Key$ = ListEx()\Cols()\Key
        
        Select Attrib
          Case #Minimum
            ListEx()\Date\Column(Key$)\Min = Value
          Case #Maximum
            ListEx()\Date\Column(Key$)\Max = Value
        EndSelect
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetDateMask(GNum.i, Mask.s, Column.i=#PB_Ignore)                   ; GNum: #Theme => change all gadgets
    
    If GNum = #Theme 
      
      ForEach ListEx()
        ListEx()\Date\Mask = Mask
      Next
      
    ElseIf FindMapElement(ListEx(), Str(GNum))
    
      If Column = #PB_Ignore 
        ListEx()\Date\Mask = Mask
      Else
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Date\Column(ListEx()\Cols()\Key)\Mask = Mask
        EndIf
      EndIf
      
    EndIf
   
  EndProcedure
  
  Procedure   SetFlags(GNum.i, Flags.i)                                          ; GNum: #Theme => change all gadgets
    
    If GNum = #Theme 
      
      ForEach ListEx()
        
        ListEx()\Flags | Flags
        
        If ListEx()\ReDraw : Draw_() : EndIf
      Next
      
    ElseIf FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Flags | Flags
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf  
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i, Type.i=#False, Column.i=#PB_Ignore)      ; GNum: #Theme => change all gadgets

    If GNum = #Theme 
      
      ForEach ListEx()
        
        Select Type
          Case #HeaderFont
            ListEx()\Header\FontID = FontID
          Default
            ListEx()\Row\FontID    = FontID
        EndSelect    
        
        If ListEx()\ReDraw
          If ListEx()\FitCols : FitColumns_() : EndIf
          Draw_()
        EndIf

      Next  

    ElseIf FindMapElement(ListEx(), Str(GNum))
      
      Select Type
        Case #HeaderFont
          If Column = #PB_Ignore
            ListEx()\Header\FontID = FontID
          Else
            If SelectElement(ListEx()\Cols(), Column)
              ListEx()\Cols()\Header\FontID = FontID
            EndIf
          EndIf
        Default
          If Column = #PB_Ignore
            ListEx()\Row\FontID = FontID
          Else
            If SelectElement(ListEx()\Cols(), Column)
              ListEx()\Cols()\FontID = FontID
            EndIf
          EndIf
      EndSelect
      
      
      If ListEx()\ReDraw
        If ListEx()\FitCols : FitColumns_() : EndIf
        Draw_()
      EndIf
      
    EndIf

  EndProcedure  
  
  Procedure   SetHeaderAttribute(GNum.i, Attrib.i, Value.i, Column.i=#PB_Ignore) ; GNum: #Theme => change all gadgets
    ; Attrib: #Align / #ColumnWidth / #FontID / #Font
    ; Value:  #Left / #Right / #Center
    
    If GNum = #Theme 
      
      ForEach ListEx()
        
        Select Attrib
          Case #Align
            If SelectElement(ListEx()\Cols(), Column)
              ListEx()\Cols()\Header\Align = Value
            EndIf
          Case #HeaderHeight
            ListEx()\Header\Height = Value
            UpdateRowY_()
          Case #FontID
            ListEx()\Header\FontID = Value
          Case #Font
            ListEx()\Header\FontID = FontID(Value)
        EndSelect        
        
        If ListEx()\ReDraw
          If ListEx()\FitCols : FitColumns_() : EndIf
          Draw_()
        EndIf

      Next  
 
    ElseIf FindMapElement(ListEx(), Str(GNum))
      
      Select Attrib
        Case #Align
          If Column = #PB_Ignore
            ListEx()\Header\Align = Value
          Else
            If SelectElement(ListEx()\Cols(), Column)
              ListEx()\Cols()\Header\Align = Value
            EndIf
          EndIf
        Case #HeaderHeight
          ListEx()\Header\Height = Value
          UpdateRowY_()
        Case #FontID
          If Column = #PB_Ignore
            ListEx()\Header\FontID = Value
          Else
            If SelectElement(ListEx()\Cols(), Column)
              ListEx()\Cols()\Header\FontID = Value
            EndIf
          EndIf 
        Case #Font
          If Column = #PB_Ignore
            ListEx()\Header\FontID = FontID(Value)
          Else
            If SelectElement(ListEx()\Cols(), Column)
              ListEx()\Cols()\Header\FontID = FontID(Value)
            EndIf
          EndIf
      EndSelect

      If ListEx()\ReDraw
        If ListEx()\FitCols : FitColumns_() : EndIf
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetHeaderHeight(GNum.i, Height.i)                                  ; GNum: #Theme => change all gadgets

    If GNum = #Theme 
      
      ForEach ListEx()
        
        ListEx()\Header\Height = Height
        UpdateRowY_()
        
        If ListEx()\ReDraw : Draw_() : EndIf
      Next

    ElseIf FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Header\Height = Height
      UpdateRowY_()

      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetHeaderSort(GNum.i, Column.i, Direction.i=#PB_Sort_Ascending, Flags.i=#True)
    ; Direction: #Sort_Ascending|#Sort_Descending|#Sort_NoCase
    ; Flags:     #SortString|#SortNumber|#SortFloat|#SortDate|#SortBirthday|#SortTime|#SortCash / #Deutsch / #Lexikon|#Namen
    ; Flags:     #True    (#HeaderSort|SwitchDirection|#SortArrows)
    ; Flags:     #Deutsch (#HeaderSort|SwitchDirection|#SortArrows|#Deutsch)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        ListEx()\Cols()\Header\Direction = Direction
        
        If Flags = #True
          ListEx()\Cols()\Header\Sort = #HeaderSort|#SortArrows|#SwitchDirection
        ElseIf Flags = #Deutsch
          ListEx()\Cols()\Header\Sort = #HeaderSort|#SortArrows|#SwitchDirection|#Deutsch
        Else
          ListEx()\Cols()\Header\Sort = Flags
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor ;{ FrontColor
          If Row = #Header
            If Column = #PB_Ignore
              ListEx()\Color\HeaderFront = Value
            Else
              If SelectElement(ListEx()\Cols(), Column)
                ListEx()\Cols()\Header\FrontColor = Value
              EndIf  
            EndIf
          Else
            If SelectElement(ListEx()\Rows(), Row)
              If Column = #PB_Ignore
                ListEx()\Rows()\Color\Front = Value
              Else
                If SelectElement(ListEx()\Cols(), Column)
                  Key$ = ListEx()\Cols()\Key
                  ListEx()\Rows()\Column(Key$)\Color\Front = Value
                  ListEx()\Rows()\Column(Key$)\Flags | #CellFront
                EndIf
              EndIf 
            EndIf
          EndIf ;}
        Case #BackColor  ;{ BackColor
          If Row = #Header
            If Column = #PB_Ignore
              ListEx()\Color\HeaderBack = Value
            Else
              If SelectElement(ListEx()\Cols(), Column)
                ListEx()\Cols()\Header\BackColor = Value
              EndIf 
            EndIf
          Else
            If SelectElement(ListEx()\Rows(), Row)
              If Column = #PB_Ignore
                ListEx()\Rows()\Color\Back = Value
              Else
                If SelectElement(ListEx()\Cols(), Column)
                  Key$ = ListEx()\Cols()\Key
                  ListEx()\Rows()\Column(Key$)\Color\Back = Value
                  ListEx()\Rows()\Column(Key$)\Flags | #CellBack
                EndIf  
              EndIf 
            EndIf
          EndIf ;}
        Case #LineColor  ;{ LineColor
          If Row = #Header
            ListEx()\Color\HeaderLine = Value
          Else
            If SelectElement(ListEx()\Rows(), Row)
              If Column = #PB_Ignore
                ListEx()\Rows()\Color\Line = Value
              Else
                If SelectElement(ListEx()\Cols(), Column)
                  Key$ = ListEx()\Cols()\Key
                  ListEx()\Rows()\Column(Key$)\Color\Line = Value
                  ListEx()\Rows()\Column(Key$)\Flags | #CellLine
                EndIf  
              EndIf
            EndIf
          EndIf ;}
        Case #HeaderFrontColor
          ListEx()\Color\HeaderFront = Value
        Case #HeaderBackColor
          ListEx()\Color\HeaderBack = Value
        Case #HeaderLineColor
          ListEx()\Color\HeaderLine = Value  
      EndSelect
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure.i SetItemData(GNum.i, Row.i, Value.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\iData = Value
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemFont(GNum.i, Row.i, FontID.i, Column.i=#PB_Ignore)
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #Header
        If Column = #PB_Ignore
          ListEx()\Header\FontID = FontID
        Else
          If SelectElement(ListEx()\Cols(), Column)
            ListEx()\Cols()\Header\FontID = FontID
          EndIf
        EndIf
      Else
        If SelectElement(ListEx()\Rows(), Row)
          If Column = #PB_Ignore
            ListEx()\Rows()\FontID = FontID
          Else
            If SelectElement(ListEx()\Cols(), Column)
              Key$ = ListEx()\Cols()\Key
              ListEx()\Rows()\Column(Key$)\FontID = FontID
              ListEx()\Rows()\Column(Key$)\Flags | #CellFont
            EndIf
          EndIf
        EndIf
      EndIf

      If ListEx()\ReDraw
        If ListEx()\FitCols : FitColumns_() : EndIf
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetItemID(GNum.i, Row.i, String.s)
    
    If FindMapElement(ListEx(), Str(GNum))
    
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\ID = String
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetItemImage(GNum.i, Row.i, Column.i, Width.f, Height.f, Image.i, Align.i=#Left)
    
    If FindMapElement(ListEx(), Str(GNum))                    
      
      If Row = #Header
        
        If SelectElement(ListEx()\Cols(), Column)
          If IsImage(Image)
            ListEx()\Cols()\Header\Image\ID     = ImageID(Image)
            ListEx()\Cols()\Header\Image\Width  = Width
            ListEx()\Cols()\Header\Image\Height = Height
            ListEx()\Cols()\Header\Image\Flags  = Align
            ListEx()\Cols()\Header\Flags | #Image
          Else
            ListEx()\Cols()\Header\Flags & ~#Image
          EndIf
          If ListEx()\FitCols : FitColumns_() : EndIf
          If ListEx()\ReDraw  : Draw_()       : EndIf
        EndIf
        
      Else
        
        If SelectElement(ListEx()\Rows(), Row)
          If SelectElement(ListEx()\Cols(), Column)
            
            If IsImage(Image)
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\ID     = ImageID(Image)
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Width  = Width
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Height = Height
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Flags  = Align
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags | #Image
            Else
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags & ~#Image
            EndIf

            If ListEx()\ReDraw
              If ListEx()\FitCols : FitColumns_() : EndIf
              Draw_()
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore)          ; [#Selected/#Checked/#Inbetween]
    
    If FindMapElement(ListEx(), Str(GNum))

      If Row >= 0
        
        If SelectElement(ListEx()\Rows(), Row)
          If Column = #PB_Ignore
            ListEx()\Rows()\State = State
            If ListEx()\ReDraw : Draw_() : EndIf
          Else
            If ListEx()\Flags & #CheckBoxes And Column = 0
              ListEx()\Rows()\State = State
              If ListEx()\ReDraw : Draw_() : EndIf 
            Else  
              If SelectElement(ListEx()\Cols(), Column)
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State = State
                If ListEx()\ReDraw : Draw_() : EndIf
              EndIf 
            EndIf
          EndIf
        EndIf
        
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetItemText(GNum.i, Row.i, Text.s , Column.i)
    
    ;Define.i Time = ElapsedMilliseconds()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #Header
        If SelectElement(ListEx()\Cols(), Column)
          
          If ListEx()\Cols()\Header\Title <> Text
            ListEx()\Cols()\Header\Title = Text
            If ListEx()\ReDraw
              If ListEx()\Cols()\Flags & #FitColumn : FitColumns_() : EndIf
              Draw_()
            EndIf
          EndIf
          
        EndIf
      Else  
        If SelectElement(ListEx()\Rows(), Row)
          If SelectElement(ListEx()\Cols(), Column)
            
            If ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value <> Text
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value = Text
              If ListEx()\ReDraw
                If ListEx()\Cols()\Flags & #FitColumn : FitColumns_() : EndIf
                Draw_()
              EndIf
            EndIf
            
          EndIf
        EndIf
      EndIf

    EndIf
    
    ;Debug Str(ElapsedMilliseconds() - Time)+"ms"
    
  EndProcedure  
  
  CompilerIf #Enable_ProgressBar
    
    Procedure   SetProgressBarAttribute(GNum.i, Attrib.i, Value.i)
      
      If FindMapElement(ListEx(), Str(GNum))
        
        Select Attrib
          Case #Minimum
            ListEx()\ProgressBar\Minimum  = Value
          Case #Maximum
            ListEx()\ProgressBar\Maximum = Value
        EndSelect
        
      EndIf
      
    EndProcedure
  
    Procedure   SetProgressBarFlags(GNum.i, Flags.i)
      
      If FindMapElement(ListEx(), Str(GNum))
        ListEx()\ProgressBar\Flags = Flags
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure   SetRowsHeight(GNum.i, Height.f)

    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Row\Height = Height
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\Height = ListEx()\Row\Height
      Next
      
      UpdateRowY_()

      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetState(GNum.i, Row.i=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #PB_Default
        
        ListEx()\Focus = #False
        
        If ListEx()\MultiSelect = #True
          PushListPosition(ListEx()\Rows())
          ForEach ListEx()\Rows()
            ListEx()\Rows()\State & ~#Selected
          Next
          PopListPosition(ListEx()\Rows())
          ListEx()\MultiSelect = #False
        EndIf
        
        ListEx()\Row\Focus = #NotValid
        
      Else 

        If SelectElement(ListEx()\Rows(), Row)
          ListEx()\Focus = #True
          ListEx()\Row\Current = Row
          ListEx()\Row\Focus = ListEx()\Row\Current
          SetRowFocus_(ListEx()\Row\Focus)
        EndIf
        
      EndIf
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  Procedure   SetTimeMask(GNum.i, Mask.s, Column.i=#PB_Ignore)                   ; GNum: #Theme => change all gadgets
    
    If GNum = #Theme 
      
      ForEach ListEx()
        ListEx()\Country\TimeMask = Mask
      Next
      
    ElseIf FindMapElement(ListEx(), Str(GNum))
    
      If Column = #PB_Ignore 
        ListEx()\Country\TimeMask = Mask
      Else
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Cols()\Mask = Mask
        EndIf
      EndIf
      
    EndIf
   
  EndProcedure
  
  
  Procedure   Sort(GNum.i, Column.i, Direction.i, Flags.i)
    ; Direction: #Sort_Ascending|#Sort_Descending|#Sort_NoCase
    ; Flags: #SortString|#SortNumber|#SortFloat|#SortDate|#SortBirthday|#SortTime|#SortCash / #Deutsch / #Lexikon|#Namen
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        ListEx()\Sort\Column    = Column
        ListEx()\Sort\Direction = Direction
        
        If Flags = #True
          ListEx()\Sort\Flags = #HeaderSort|#SortArrows|#SwitchDirection
        ElseIf Flags = #Deutsch
          ListEx()\Sort\Flags = #HeaderSort|#SortArrows|#SwitchDirection|#Deutsch
        Else
          ListEx()\Sort\Flags = Flags
        EndIf
        
        SortColumn_()
        
        ListEx()\Focus = #False
        ListEx()\Row\Focus = #NotValid
        
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  

EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Window  = 0
  Enumeration 1
    #List
    #Button
    #Export
    #PopupMenu
    #MenuItem0
    #MenuItem1
    #MenuItem2
    #MenuItem3
    #MenuItem4
    #MenuItem5
    #B_Green
    #B_Grey
    #B_Blue
    #B_Dark
  EndEnumeration

  #Image = 0
  #Font_Arial9  = 1
  #Font_Arial9B = 2
  #Font_Arial9U = 3
  
  LoadFont(#Font_Arial9,  "Arial", 9)
  LoadFont(#Font_Arial9B, "Arial", 9, #PB_Font_Bold)
  LoadFont(#Font_Arial9U, "Arial", 9, #PB_Font_Underline)
  
  If OpenWindow(#Window, 0, 0, 500, 250, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#PopupMenu)
      MenuItem(#MenuItem5, "Copy to clipboard")
      MenuBar()
      MenuItem(#MenuItem0, "Clear List")
      MenuBar()
      MenuItem(#MenuItem1, "Theme 'Blue'")
      MenuItem(#MenuItem2, "Theme 'Green'")
      MenuItem(#MenuItem3, "Theme 'Default'")
      MenuBar()
      MenuItem(#MenuItem4, "Reset gadget size")
    EndIf
    
    ButtonGadget(#Button,  420,  10, 70, 20, "Resize")
    ButtonGadget(#B_Dark,  420,  50, 70, 20, "Dark")
    ButtonGadget(#B_Green, 420,  75, 70, 20, "Green")
    ButtonGadget(#B_Blue,  420, 100, 70, 20, "Blue")
    ButtonGadget(#Export,  420, 140, 70, 20, "Export")
    
    ListEx::Gadget(#List, 10, 10, 395, 230, "", 25, "", ListEx::#GridLines|ListEx::#CheckBoxes|ListEx::#AutoResize|ListEx::#MultiSelect|ListEx::#ResizeColumn, #Window) ; ListEx::#NoRowHeader|ListEx::#ThreeState|ListEx::#NumberedColumn|ListEx::#SingleClickEdit 
    
    ListEx::DisableReDraw(#List, #True) 
    
    ListEx::AddColumn(#List, 1, "Link", 75, "link",   ListEx::#Links)    ; |ListEx::#FitColumn
    ListEx::AddColumn(#List, 2, "Edit", 85, "edit",   ListEx::#Editable) ; |ListEx::#FitColumn
    ListEx::AddColumn(#List, ListEx::#LastItem, "Combo",   78, "combo",  ListEx::#ComboBoxes)
    ListEx::AddColumn(#List, ListEx::#LastItem, "Date",    76, "date",   ListEx::#Dates)
    ListEx::AddColumn(#List, ListEx::#LastItem, "Buttons", 60, "button", ListEx::#Buttons) ; ListEx::#Hide

    ; --- Test ProgressBar ---
    ;CompilerIf ListEx::#Enable_ProgressBar
    ;  ListEx::AddColumn(#List, ListEx::#LastItem, "Progress", 60, "progress", ListEx::#ProgressBar)
    ;  ListEx::SetProgressBarFlags(#List, ListEx::#ShowPercent)
    ;CompilerEndIf
    
    ListEx::SetHeaderAttribute(#List, ListEx::#Align, ListEx::#Center)
    
    ;ListEx::SetItemColor(#List, ListEx::#Header, ListEx::#FrontColor, $0000FF, 1)
    
    ListEx::SetFont(#List, FontID(#Font_Arial9))
    ListEx::SetFont(#List, FontID(#Font_Arial9B), ListEx::#HeaderFont)
    
    ListEx::AddItem(#List, ListEx::#LastItem, "Image"    + #LF$ + "no Image" + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Thorsten" + #LF$ + "Hoeppner" + #LF$ + "male" + #LF$ + "18.07.1967" + #LF$ + "", "PureBasic")
    ListEx::AddItem(#List, ListEx::#LastItem, "Amelia"   + #LF$ + "Smith"    + #LF$ + "female"+ #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Jack"     + #LF$ + "Jones"    + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Isla"     + #LF$ + "Williams" + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Harry"    + #LF$ + "Brown"    + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Emily"    + #LF$ + "Taylor"   + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Jacob"    + #LF$ + "Wilson"   + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Ava"      + #LF$ + "Evans"    + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Thomas"   + #LF$ + "Roberts"  + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Harriet"  + #LF$ + "Smith"    + #LF$ + #LF$ + #LF$ + "Push")

    ListEx::SetItemState(#List, 3, ListEx::#Inbetween)
    
    ListEx::DisableReDraw(#List, #False) 
    
    ListEx::SetRowsHeight(#List, 22)
    
    ListEx::AttachPopupMenu(#List, #PopupMenu)
    
    ListEx::AddComboBoxItems(#List, 3, "male" + #LF$ + "female")

    ListEx::SetAutoResizeColumn(#List, 2, 50)
    
    ListEx::SetColumnAttribute(#List, 1, ListEx::#FontID, FontID(#Font_Arial9U))
    ListEx::SetColumnAttribute(#List, 5, ListEx::#Align, ListEx::#Center)
    
    ListEx::SetHeaderSort(#List, 2, ListEx::#Ascending, ListEx::#Deutsch)
    
    ListEx::SetColor(#List, ListEx::#FrontColor, $82004B, 2) ; front color for column 2
    
    ;ListEx::SetItemColor(#List, 5, ListEx::#FrontColor, $228B22, 2)
    ;ListEx::SetItemColor(#List, 5, ListEx::#BackColor, $FAFFF5)
    ListEx::SetItemFont(#List,  0, FontID(#Font_Arial9B), 2)
    
    ListEx::SetAutoResizeFlags(#List, ListEx::#Height)
    
    CompilerIf ListEx::#Enable_MarkContent
      ListEx::MarkContent(#List, 1, "CHOICE{male|female}[C3]", $D30094, $9314FF, FontID(#Font_Arial9B))
    CompilerEndIf
    
    ListEx::SetColorTheme(#List, ListEx::#Theme_Blue) ; #List
    ListEx::SetColor(#List, ListEx::#AlternateRowColor, $FBF7F5)
    
    If LoadImage(#Image, "Delete.png")
      ListEx::SetItemImage(#List, 0, 1, 16, 16, #Image)
      ListEx::SetItemImage(#List, 1, 5, 14, 14, #Image, ListEx::#Center)
      ListEx::SetItemImage(#List, ListEx::#Header, 2, 14, 14, #Image, ListEx::#Right)
    EndIf
    
    ; --- Test single cell flags ---
    ;ListEx::SetCellFlags(#List, 2, 5, ListEx::#Strings)
    
    ; --- Test ProgressBar ---
    ;CompilerIf ListEx::#Enable_ProgressBar
    ;  ListEx::SetCellState(#List, 1, "progress", 100) ; or SetItemState(#List, 1, 75, 5)
    ;  ListEx::SetCellState(#List, 2, "progress", 50) ; or SetItemState(#List, 2, 50, 5)
    ;  ListEx::SetCellState(#List, 3, "progress", 25) ; or SetItemState(#List, 3, 25, 5)
    ;CompilerEndIf
    
    ;ListEx::SetState(#List, 9)
    
    ;ModuleEx::LoadTheme("Theme_Green.xml")
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case ListEx::#Event_Gadget ; works with or without EventType()
          Select EventType()
            Case #PB_EventType_RightClick 
              Debug "RightClick: " + Str(EventData())
            Case ListEx::#EventType_Row
              Debug ">>> Row: " + Str(EventData())
          EndSelect
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #List      ;{ only in use with EventType()
              Select EventType()
                Case ListEx::#EventType_Header
                  Debug ">>> Header Click: " + Str(EventData()) ; Str(ListEx::EventColumn(#List))  
                Case ListEx::#EventType_Button
                  Debug ">>> Button pressed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + ")"
                Case ListEx::#EventType_Link
                  Debug ">>> Link pressed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)
                  If ListEx::EventID(#List) = "PureBasic" : RunProgram("http://www.purebasic.com") :  EndIf
                Case ListEx::#EventType_String
                  Debug ">>> Cell edited (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)
                Case ListEx::#EventType_Date
                  Debug ">>> Date changed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)  
                Case ListEx::#EventType_CheckBox
                  Debug ">>> CheckBox state changed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "):" + Str(ListEx::EventState(#List)) 
                Case ListEx::#EventType_ComboBox
                  Debug ">>> ComboBox state changed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)
              EndSelect ;}
            Case #Button    ;{ Buttons
              HideGadget(#Button,  #True)
              HideGadget(#B_Green, #True)
              HideGadget(#B_Grey,  #True)
              HideGadget(#B_Blue,  #True)
              ResizeGadget(#List, #PB_Ignore, #PB_Ignore, 480, #PB_Ignore)
            Case #B_Green
              CompilerIf Defined(ModuleEx, #PB_Module)
                ModuleEx::SetTheme(ModuleEx::#Theme_Green)
              CompilerEndIf  
              ;ListEx::SetColorTheme(#List, ListEx::#Theme_Green)
              ;ListEx::LoadColorTheme(#List, "Theme_Green.json")
             Case #B_Dark
              CompilerIf Defined(ModuleEx, #PB_Module)
                ModuleEx::SetTheme(ModuleEx::#Theme_Dark)
              CompilerEndIf  
              ;ListEx::SetColorTheme(#List, #PB_Default)
              ;ListEx::LoadColorTheme(#List, "Theme_Grey.json")    
            Case #B_Grey
              CompilerIf Defined(ModuleEx, #PB_Module)
                ModuleEx::SetTheme()
              CompilerEndIf  
              ;ListEx::SetColorTheme(#List, #PB_Default)
              ;ListEx::LoadColorTheme(#List, "Theme_Grey.json")  
            Case #B_Blue
              CompilerIf Defined(ModuleEx, #PB_Module)
                ModuleEx::SetTheme(ModuleEx::#Theme_Blue)
              CompilerEndIf  
              ;ListEx::SetColorTheme(#List, ListEx::#Theme_Blue)
              ;ListEx::LoadColorTheme(#List, "Theme_Blue.json")
            Case #Export
              ListEx::ExportCSV(#List, "ListEx.csv", ListEx::#HeaderRow)
              ;}
          EndSelect
        Case #PB_Event_Menu ;{ PopupMenu
          Select EventMenu()
            Case #MenuItem0 
              ListEx::DebugList(#List)
              ListEx::ClearItems(#List)
              ListEx::DebugList(#List)
            Case #MenuItem1
              ListEx::LoadColorTheme(#List, "Theme_Blue.json")
            Case #MenuItem2
              ListEx::LoadColorTheme(#List, "Theme_Green.json")
            Case #MenuItem3  
              ListEx::LoadColorTheme(#List, "Theme_Grey.json")
            Case #MenuItem4
              HideGadget(#Button,  #False)
              HideGadget(#B_Green, #False)
              HideGadget(#B_Grey,  #False)
              HideGadget(#B_Blue,  #False)
              ResizeGadget(#List, #PB_Ignore, #PB_Ignore, 400, #PB_Ignore)
            Case #MenuItem5
              CompilerIf ListEx::#Enable_CSV_Support
                ListEx::ClipBoard(#List)
              CompilerEndIf  
          EndSelect ;}
      EndSelect
    Until Event = #PB_Event_CloseWindow

    ;ListEx::SaveColorTheme(#List, "Theme_Test.json")
    
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 7302
; FirstLine = 1033
; Folding = 9HQJCAACAF5-8--xfABFq4nJigXUgjA9-PAVY4nAACcAcAAAcAAAAAAAEAEIf-
; EnableXP
; DPIAware
; EnableUnicode