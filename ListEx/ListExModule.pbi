;/ ===========================
;/ =    ListEx-Module.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x - V6.0 / 64Bit / all OS / DPI ]
;/
;/ Editable and sortable ListGadget
;/
;/ © 2022 Thorsten1867 (03/2019)
;/
 
; Last Update: 14.05.2022
; 
;  Fixed: Resize & Scrollbar
;  DPI adjustment & Bugfixes
;
; Adjust row height (#AdjustRows)
; Support for the "MarkdownModule" (#MarkDown) 
;
; Changed: New DPI management
; Changed: Timer for Cursor & Autoscroll
; Changed: New ScrollBars
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


;{ _____ ListEx - Commands _____

; ListEx::AddCells()                - adds a new row and insert text in cells with label
; ListEx::AddColumn()               - similar to 'AddGadgetColumn()'
; ListEx::AddComboBoxItems()        - add items to the comboboxes of the column (items seperated by #LF$)
; ListEx::AddComboBoxItem()         - add a single item to the comboboxes of the column (color possible)
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
; ListEx::GetItemLabel()            - similar to 'GetGadgetItemData()' but with string data
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
; ListEx::ResetSort()               - reset sort
; ListEx::SelectItems()             - select all rows [#All/#None]
; ListEx::SetAttribute()            - similar to SetGadgetAttribute()  [#Padding] 
; ListEx::SetAutoResizeColumn()     - column that is reduced when the vertical scrollbar is displayed.
; ListEx::SetAutoResizeFlags()      - [#MoveX|#MoveY|#Width|#Height]
; ListEx::SetCellFlags()            - [#LockCell|#Strings|#ComboBoxes|#DateGadget]
; ListEx::SetCellState()            - similar to 'SetGadgetItemState()' with labels
; ListEx::SetCellText()             - similar to 'SetGadgetItemText()'  with labels
; ListEx::SetColor()                - similar to 'SetGadgetColor()'
; ListEx::SetColorTheme()           - change the color theme
; ListEx::SetColumnAttribute()      - [#Align/#ColumnWidth]
; ListEx::SetColumnFlags()          - [#FitColumn | #Left/#Right/#Center]
; ListEx::SetColumnImage()          - set image for all rows of column
; ListEx::SetColumnMask()           - Format content
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
; ListEx::SetItemLabel()            - similar to 'SetGadgetItemData()' but with string data
; ListEx::SetItemImage( )           - add a image at row/column
; ListEx::SetItemState()            - similar to 'SetGadgetItemState()' [#Selected/#Checked/#Inbetween]
; ListEx::SetItemText()             - similar to 'SetGadgetItemText()'
; ListEx::SetMarkdownFont()         - loads the required fonts for Markdown
; ListEx::SetProgressBarAttribute() - set minimum or maximum value for progress bars
; ListEx::SetProgressBarFlags()     - set flags for progressbar (#ShowPercent)
; ListEx::SetRowsHeight()           - change height of rows
; ListEx::SetTimeMask()             - change mask for time (sorting)
; ListEx::Sort()                    - sort rows by column [#SortString|#SortNumber|#SortFloat|#SortDate|#SortBirthday|#SortTime|#SortCash / #Deutsch]

;} -----------------------------


;{ ___ Format Content (Mask) ___

; Floats:  "0.00" or "0,000"
; Integer: "." or "," or "1.000" or "1,000"
; Date:    "%dd.%mm.%yyyy"
; Time:    "%hh:%ii:%ss"
; Cash:    "0,00 €" or "$ 0.00"

;}


; XIncludeFile "ModuleEx.pbi"
; XIncludeFile "DateExModule.pbi"
; XIncludeFile "MarkDownModule.pbi"

DeclareModule ListEx
  
  #Version  = 22051100
  #ModuleEx = 20030400
  
  #Enable_CSV_Support   = #True
  #Enable_DragAndDrop   = #True
  #Enable_FormatContent = #True
  #Enable_MarkContent   = #True
  #Enable_ProgressBar   = #True
  #Enable_Validation    = #True
  
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

  ;{ Sorting
  #Sort_Ascending  = #PB_Sort_Ascending
  #Sort_Descending = #PB_Sort_Descending
  #Sort_NoCase     = #PB_Sort_NoCase
  ;}
  
  #ColumnCount = #PB_ListIcon_ColumnCount

  #Minimum     = #PB_Date_Minimum
  #Maximum     = #PB_Date_Maximum
  
  #Progress$ = "{Percent}"
  
  EnumerationBinary ;{ Gadget Flags
    #Left    = 1
    #Right   = 1<<1
    #Center  = 1<<2
    #ChBFlag = 1<<3
    ; --- Gadget ---
    #GridLines
    #NoRowHeader
    #NumberedColumn
    #SingleClickEdit
    #AutoResize
    #ResizeColumn      ; resize column with mouse (changes the width)
    #AdjustColumns     ; resize column with mouse (no change in width)
    #AdjustRows        ; adjust the row height
    #UseExistingCanvas
    #ThreeState
    #MultiSelect
    #FitColumn
    #EditableCombobox
    ; --- Scrollbars ---
    #Vertical 
    #Horizontal
    #ListView
    #Style_RoundThumb
    #Style_Win11
  EndEnumeration ;}
  
  Enumeration 1     ;{ Color
    #ActiveLinkColor
    #BackColor
    #ButtonColor
    #ButtonBorderColor
    #ProgressBarColor
    #GradientColor
    #EditFrontColor
    #EditBackColor
    #FocusColor
    #FocusTextColor
    #FrontColor
    #GadgetBackColor
    #LineColor
    #LinkColor
    #HeaderFrontColor
    #HeaderBackColor
    #HeaderLineColor
    #AlternateRowColor
    #ComboFrontColor
    #ComboBackColor
    #StringFrontColor
    #StringBackColor
    #ScrollBar_FrontColor
    #ScrollBar_BackColor 
    #ScrollBar_ButtonColor
    #ScrollBar_ThumbColor
  EndEnumeration ;}
  
  EnumerationBinary ;{ State 
    #Selected   = #PB_ListIcon_Selected
    #Checked    = #PB_ListIcon_Checked
    #Inbetween  = #PB_ListIcon_Inbetween
    #HeaderRow
    #Edit
    #NoButtons
    #NoCheckBoxes
  EndEnumeration ;}
  
  EnumerationBinary ;{ ProgressBars
    #ShowPercent
  EndEnumeration ;}
  
  EnumerationBinary ;{ Sort Header
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
  EndEnumeration ;}
  
  Enumeration       ;{ Attribute
    #Align
    #Font
    #FontID
    #ColumnWidth
    #MaxChars
    #HeaderHeight
    #Padding
    #Gadget
    #HeaderFont
    #GadgetFont
    #FirstVisibleRow
    #VisibleRows
    #ScrollBar       ; Set scrollbar flags
    #MinimumSize     ; Minimum size of scrollbar thumb
    #ParentGadget    ; Parent gadget for resizing
  EndEnumeration ;}
  
  EnumerationBinary ;{ Column Flags
    #Left    = 1
    #Right   = 1<<1
    #Center  = 1<<2
    #CheckBoxes  ; checkbox gadget
    #ComboBoxes  ; combobox gadget
    #DateGadget  ; date gadget
    #Strings     ; string gadget
    #Buttons     ; button
    #Links       ; link
    #MarkDown    ; MarkDown text
    #Image
    #ProgressBar
    #MarkContent
    #Hide
    #CellFont
    #CellFront
    #CellBack
    #CellLine
    #LockCell
    #StartSelected
    ; --------
    #Date        ; contains dates
    #Cash        ; contains cash
    #Float       ; contains float
    #Grades      ; contains grades
    #Integer     ; contains integers
    #Number      ; contains unsigned integer
    #Time        ; contains time
    #Text        ; contains text
  EndEnumeration ;}
  #Editable = #Strings
  
  EnumerationBinary ;{ AutoResize
    #MoveX
    #MoveY
    #Width
    #Height  
  EndEnumeration ;}
  
  Enumeration 1     ;{ Money / Time / Date
    #Currency
    #Clock
    #TimeSeperator
    #DateSeperator
    #DecimalSeperator
  EndEnumeration ;}
  
  Enumeration       ;{ Themes
    #Theme_Default
    #Theme_Custom
    #Theme_Blue  
    #Theme_Green
  EndEnumeration ;}

	
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Cursor        = ModuleEx::#Event_Cursor
    #Event_Gadget        = ModuleEx::#Event_Gadget
    ;#Event_Theme         = ModuleEx::#Event_Theme
    #Event_Timer         = ModuleEx::#Event_Timer
    
    #EventType_Button    = ModuleEx::#EventType_Button
    #EventType_Change    = ModuleEx::#EventType_Change
    #EventType_CheckBox  = ModuleEx::#EventType_CheckBox
    #EventType_ComboBox  = ModuleEx::#EventType_ComboBox 
    #EventType_Date      = ModuleEx::#EventType_Date
    #EventType_Header    = ModuleEx::#EventType_Header
    #EventType_Link      = ModuleEx::#EventType_Link
    #EventType_Row       = ModuleEx::#EventType_Row
    #EventType_String    = ModuleEx::#EventType_String
    #EventType_ScrollBar = ModuleEx::#EventType_ScrollBar
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
      #Event_Gadget
      ;#Event_Timer
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Button
      #EventType_Change
      #EventType_CheckBox
      #EventType_ComboBox
      #EventType_Date
      #EventType_Header
      #EventType_Link
      #EventType_Row
      #EventType_String
      #EventType_ScrollBar
    EndEnumeration
    
  CompilerEndIf
  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
 
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare   SetData(GNum.i, Value.q)
	Declare   SetID(GNum.i, String.s)
  
  Declare.i AddColumn(GNum.i, Column.i, Title.s, Width.f, Label.s="", Flags.i=#False)
  Declare.i AddComboBoxItems(GNum.i, Column.i, Items.s)
  Declare.i AddComboBoxItem(GNum.i, Column.i, Item.s, Color.i=#PB_Default)
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
  Declare.s GetItemLabel(GNum.i, Row.i)
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
  Declare   ResetSort(GNum.i)
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
  Declare   SetColumnImage(GNum.i, Column.i, Image.i, Align.i=#Left, Width.i=#PB_Default, Height.i=#PB_Default)
  Declare   SetColumnMask(GNum.i, Column.i, Mask.s)
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
  Declare   SetItemLabel(GNum.i, Row.i, String.s)
  Declare   SetItemImage(GNum.i, Row.i, Column.i, Image.i, Align.i=#Left, Width.i=#PB_Default, Height.i=#PB_Default)
  Declare   SetItemImageID(GNum.i, Row.i, Column.i, Width.f, Height.f, ImageID.i, Align.i=#Left)
  Declare   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore)
  Declare   SetItemText(GNum.i, Row.i, Text.s, Column.i)
  Declare   SetRowsHeight(GNum.i, Height.f)
  Declare   SetState(GNum.i, Row.i=#PB_Default, Column.i=#PB_Ignore)
  Declare   SetTimeMask(GNum.i, Mask.s, Column.i=#PB_Ignore)
  Declare   Sort(GNum.i, Column.i, Direction.i, Flags.i)
  
  CompilerIf Defined(MarkDown, #PB_Module)
    Declare SetMarkdownFont(GNum.i, Name.s, Size.i)
  CompilerEndIf
  
  CompilerIf #Enable_MarkContent
    Declare MarkContent(GNum.i, Column.i, Term.s, Color1.i=#PB_Default, Color2.i=#PB_Default, FontID.i=#PB_Default)
  CompilerEndIf
  
  CompilerIf #Enable_Validation
    Declare SetCondition(GNum.i, Column.i, Term.s)
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

  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================  
  
  ;{ Defaults
  #DefaultCountry          = "DE"
  #DefaultDateMask         = "%dd.%mm.%yyyy"
  #DefaultTimeMask         = "%hh:%ii:%ss"
  #DefaultCurrency         = "€"
  #DefaultClock            = "Uhr"
  #DefaultTimeSeparator    = ":"
  #DefaultDateSeparator    = "."
  #DefaultDecimalSeperator = ","
  ;}
  
  #ScrollBarSize = 16
  
  #Timer         = 1867
	#Frequency     = 100  ; 100ms
	#TimerDelay    = 3    ; 100ms * 3

  #ButtonWidth     = 18
  #CursorFrequency = 600
  
  #NoFocus = -1
  #NotSelected = -1
  
  #TextSelected = #True
  
  ;{ Cursor
  #Cursor_Default = #PB_Cursor_Default
  #Cursor_Edit    = #PB_Cursor_Hand
  #Cursor_Sort    = #PB_Cursor_Hand
  #Cursor_Click   = #PB_Cursor_Hand
  #Cursor_Button  = #PB_Cursor_Default
  #Cursor_Text    = #PB_Cursor_IBeam
  ;}
  
  Enumeration 1 ;{ Mouse
    #Focus
    #Click
    #Hover
  EndEnumeration ;}
  
  Enumeration 1 ;{ Direction
	  #Scrollbar_Up
	  #Scrollbar_Left
	  #Scrollbar_Right
	  #Scrollbar_Down
	  #Forwards
	  #Backwards
	  #ListView_Up
	  #ListView_Down
	EndEnumeration ;}
	
	
  Enumeration 1 ;{ Grades
    #Grades_Number
    #Grades_Character
    #Grades_Points
  EndEnumeration ;}
  
  Enumeration 1 ;{ Keys
    #Key_Return
    #Key_Escape
    #Key_Tab
    #Key_ShiftTab
  EndEnumeration ;}
  
  #Condition1 = 1
  #Condition2 = 2
  

  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================  
  
  ; ===== Structures =====  
  
  ;{ ----- ScrollBars -----
  Structure Area_Structure               ;{
	  X.i
	  Y.i
	  Width.i
	  Height.i
	EndStructure ;} 
	
	Structure Size_Structure                ;{
	  Width.i
	  Height.i
	EndStructure ;}
	
	
	Structure ScrollBar_Thumb_Structure     ;{ ListEx()\HScroll\Forwards\Thumb\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollBar_Button_Structure    ;{ ListEx()\HScroll\Buttons\...
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
	
	Structure ScrollBar_Color_Structure     ;{ ListEx()\HScroll\Color\...
	  Front.i
	  Back.i
		Button.i
		Focus.i
		Hover.i
		Arrow.i
	EndStructure ;}

	
	Structure ListEx_ScrollBar_Structure  ;{ ListEx()\HScroll\...
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

	Structure ListEx_ScrollBars_Structure ;{ ListEx()\ScrollBar\...
	  Color.ScrollBar_Color_Structure
	  Size.i       ; Scrollbar width (vertical) / height (horizontal)
	  MinSize.i    ; Minimum size for thumb
	  TimerDelay.i ; Autoscroll Delay
	  Flags.i      ; Flag: #Vertical | #Horizontal
	EndStructure ;}
  ;}
  
  Structure ListView_Structure          ;{ ListView\...
    Window.i
    Gadget.i
    ScrollBar.i
  EndStructure ;}
  Global ListView.ListView_Structure

  Structure ListEx_Cursor_Structure     ;{ ListEx()\Cursor\...
    Pos.i ; 0: "|abc" / 1: "a|bc" / 2: "ab|c"  / 3: "abc|"
    X.i
    Y.i
    Height.i
    ClipX.i
    State.i
    Pause.i
    Frequency.i
    Delay.i
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

  Structure Event_Structure             ;{ ListEx()\Event\...
    Type.i
    Row.i
    Column.i
    Value.s
    State.i
    ID.s
  EndStructure  ;}
  
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
  
  ; ----- Gadgets -----

  Structure ListEx_ProgressBar          ;{ ListEx()\ProgressBar\...
    Minimum.i
    Maximum.i
    Flags.i
  EndStructure ;}
  
  Structure Selection_Structure         ;{ ListEx()\String\Selection\
    Pos1.i
    Pos2.i
    Flag.i
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
    MaxChars.i
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
  
  Structure ListEx_CheckBox_Structure   ;{ ListEx()\CheckBox\...
    Row.i
    Col.i
    Label.s
    State.i
  EndStructure ;}
  
  ; ----- Date Gadget -----
  
  Structure Date_Structure              ;{ ListEx()\Date\Column('num')\...
    Min.i
    Max.i
    Mask.s
  EndStructure ;}
  
  Structure ListEx_Date_Structure       ;{ ListEx()\Date\...
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
  
  ; ----- ComboBox -----

  Structure ListView_Item_Structure     ;{ ListEx()\ListView\Item()\...
    ;ID.s
    ;Quad.q
    Y.i
    String.s
    Color.i
    Flags.i
  EndStructure ;}
  
  Structure ListEx_ListView_Structure   ;{ ListEx()\ListView\...
    Num.i
    Window.i
    Width.f
    Height.f
    Offset.i
    RowHeight.i
    FontID.i
    FrontColor.i
    Focus.i
    State.i
    Hide.i
    Map  Index.i() 
    List Item.ListView_Item_Structure()
  EndStructure ;}
  
  Structure ComboBox_Item_Structure     ;{ ListEx()\ComboBox\Column('num')\Items()\...
    String.s
    Color.i
  EndStructure ;}
  
  Structure ComboBox_Items_Structure    ;{ ListEx()\ComboBox\Column('num')\...
    List Items.ComboBox_Item_Structure()
  EndStructure ;}
  
  Structure ListEx_ComboBox_Structure   ;{ ListEx()\ComboBox\...
    Row.i
    Col.i
    X.i
    Y.i
    Width.i
    Height.i
    ButtonX.i
    Label.s
    Text.s
    MaxChars.i
    FontID.i
    CursorPos.i
    State.i
    Flag.i
    Map Column.ComboBox_Items_Structure()
  EndStructure ;}

  ; ----- Header -----
  
  Structure ListEx_Header_Structure     ;{ ListEx()\Header\...
    Col.i
    Height.f
    Align.i
    FontID.i
  EndStructure ;}   
  
  ; ----- Columns -----
  
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
   
  Structure ListEx_Col_Structure        ;{ ListEx()\Col\...
    Current.i
    Counter.i
    Width.f
    Padding.i
    OffsetX.f
    MouseX.i
    Resize.i
    CheckBoxes.i
  EndStructure ;}

  Structure ListEx_Cols_Structure       ;{ ListEx()\Cols()\...
    ;Type.i
    X.f
    Key.s
    Width.f
    Align.i
    FontID.i
    Mask.s
    Format.s
    minWidth.i
    MaxWidth.i
    MaxChars.i
    Currency.s
    Term.s
    Flags.i
    FrontColor.i
    BackColor.i
    Header.Cols_Header_Structure
    Image.Image_Structure
  EndStructure ;}  
  
  ; ----- Rows -----
  
  Structure ListEx_Row_Structure        ;{ ListEx()\Row\...
    Current.i
    CurrentKey.i
    Number.i
    Height.f
    FontID.i
    Offset.i
    OffSetY.f
    ScrollUp.i
    ScrollDown.i
    Focus.i
    StartSelect.i
    Color.Color_Structure ; Default colors
  EndStructure ;}  
  
  Structure Rows_Column_Structure       ;{ ListEx()\Rows()\Column('label')\...
    Value.s
    FontID.i
    State.i ; e.g. CheckBoxes
    Flags.i
    Image.Image_Structure
    Color.Color_Structure
  EndStructure ;}
  
  Structure ListEx_Rows_Structure       ;{ ListEx()\Rows()\...
    ID.s
    iData.i
    Idx.i
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
  
  ; ---------------
  
  Structure ListEx_Color_Structure      ;{ ListEx()\Color\...
    AlternateRow.i
    Front.i
    Back.i
    ComboFront.i
    ComboBack.i
    Gadget.i
    Line.i
    HeaderFront.i
    HeaderBack.i
    HeaderLine.i
    Canvas.i
    Focus.i
    FocusText.i
    EditFront.i
    EditBack.i
    ButtonFront.i
    ButtonBack.i
    ButtonBorder.i
    ProgressBar.i
    Gradient.i
    Link.i
    ActiveLink.i
    ScrollBar.i
    StringFront.i
    StringBack.i
    WrongFront.i
    WrongBack.i
    Mark1.i
    Mark2.i
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
  
  Structure ListEx_Parent_Structure     ;{ ListEx()\Parent\...
    Num.i
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure ;}
  
  Structure ListEx_Window_Structure     ;{ ListEx()\Window\...
    Num.i
    Width.f
    Height.i
  EndStructure ;}

  Structure ListEx_Structure            ;{ ListEx()\...
    ID.s
    Quad.i
    
    CanvasNum.i
    
    ;ComboNum.i
    DateNum.i
    PopUpID.i
    HScrollNum.i
    VScrollNum.i
    ShortCutID.i
    
    FontID.i
    
    Editable.i
    MarkDown.i
    
    ReDraw.i
    Hide.i
    
    CanvasCursor.i
    Cursor.ListEx_Cursor_Structure
    
    RowIdx.i
    Focus.i
    MultiSelect.i
    Changed.i
    FitCols.i
    Flags.i
    
    Size.ListEx_Size_Structure
    
    AutoResize.ListEx_AutoResize_Structure
    Window.ListEx_Window_Structure
    Parent.ListEx_Parent_Structure
    Header.ListEx_Header_Structure
    Row.ListEx_Row_Structure
    Col.ListEx_Col_Structure
    
    Color.ListEx_Color_Structure
    
    Sort.ListEx_Sort_Structure

    Button.ListEx_Button_Structure
    CheckBox.ListEx_CheckBox_Structure
    ComboBox.ListEx_ComboBox_Structure
    ListView.ListEx_ListView_Structure
    ProgressBar.ListEx_ProgressBar
    Country.Country_Structure
    Date.ListEx_Date_Structure
    Event.Event_Structure
    Link.ListEx_Link_Structure
    String.ListEx_String_Structure
    Selection.Selection_Structure
    
    ; --- ScrollBars ---
    Scrollbar.ListEx_ScrollBars_Structure
    
	  HScroll.ListEx_ScrollBar_Structure
	  VScroll.ListEx_ScrollBar_Structure
	  LScroll.ListEx_ScrollBar_Structure
	  
    Area.Area_Structure ; available area
    ; ------------------
    
    Map Mark.ListEx_Mark_Structure()
    
    List Cols.ListEx_Cols_Structure()
    List Rows.ListEx_Rows_Structure()
    
  EndStructure ;}
  Global NewMap ListEx.ListEx_Structure()
  
  Global NewMap Font.Font_Structure()
  Global NewMap Grades.Grades_Structure()
  
  Global Mutex.i = CreateMutex()
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Declare BindShortcuts_(Flag.i=#True)
  Declare BindTabulator_(Flag.i=#True)
  Declare CloseString_(Escape.i=#False)
  Declare CloseComboBox_(Escape.i=#False)
  Declare CloseDate_(Escape.i=#False)
  Declare CloseListView_()
  Declare SetRowFocus_(Row.i)
  
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
  
  ;- ----- DPI -----
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  Procedure TextHeight_(Text.s)
    ProcedureReturn DesktopUnscaledY(TextHeight(Text))
  EndProcedure  
  
  Procedure TextWidth_(Text.s)
    ProcedureReturn DesktopUnscaledX(TextWidth(Text))
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

  ;- ----------------
  
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
    
    PushListPosition(ListEx()\Cols())
    
    ListEx()\Size\Cols = 0
    
    ForEach ListEx()\Cols()
      If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
      ListEx()\Cols()\X  = ListEx()\Size\Cols - ListEx()\Col\OffsetX
      ListEx()\Size\Cols + ListEx()\Cols()\Width
    Next  
    
    PopListPosition(ListEx()\Cols())
    
  EndProcedure
  
  Procedure   UpdateRowY_()
    Define.i PosY
    
    ListEx()\Size\Rows   = 0
    
    If ListEx()\Flags & #NoRowHeader
      PosY = ListEx()\Area\Y - ListEx()\Row\OffSetY
    Else
      PosY = ListEx()\Area\Y + ListEx()\Header\Height - ListEx()\Row\OffSetY
    EndIf
    
    PushListPosition(ListEx()\Rows())

    ForEach ListEx()\Rows()
      ListEx()\Rows()\Y = PosY + ListEx()\Size\Rows
      ListEx()\Size\Rows + ListEx()\Rows()\Height
    Next
    
    PopListPosition(ListEx()\Rows())
    
  EndProcedure
  
  Procedure   UpdateEditPos_()
    Define.i X, Y 
    
    UpdateRowY_()
    UpdateColumnX_()
    
    Y = ListEx()\Rows()\Y
    X = ListEx()\Cols()\X
    
    If ListEx()\String\Flag   = #True
      ListEx()\String\X = X
      ListEx()\String\Y = Y
    EndIf
    
    If ListEx()\ComboBox\Flag = #True
      ListEx()\ComboBox\X       = X
      ListEx()\ComboBox\Y       = Y
    EndIf
    
    If ListEx()\Date\Flag     = #True
      ListEx()\Date\X       = X
      ListEx()\Date\Y       = Y
    EndIf
    
  EndProcedure
  
  Procedure.i GetPageRows_()    ; all visible Rows
    Define.i Y1, Y2, Count = 0
    
    PushListPosition(ListEx()\Rows())
    
    Y1 = ListEx()\Size\Y + ListEx()\Header\Height
    Y2 = ListEx()\Size\Y + ListEx()\Area\Height
    
    ForEach ListEx()\Rows()
      
      If ListEx()\Rows()\Y >= Y1 And ListEx()\Rows()\Y + ListEx()\Rows()\Height < Y2
        Count + 1
      EndIf

    Next  

    PopListPosition(ListEx()\Rows())
    
    ProcedureReturn Round((GadgetHeight(ListEx()\CanvasNum) - ListEx()\Header\Height) / ListEx()\Row\Height, #PB_Round_Down)
  EndProcedure  
  
  
  
  Procedure.i GetRowDPI_(dY.i)

    If dY <= dpiY(ListEx()\Header\Height)
      ProcedureReturn #Header 
    EndIf 
    
    If dY > dpiY(ListEx()\Size\Y) And dY < dpiY(ListEx()\Size\Rows + ListEx()\Header\Height)

      ForEach ListEx()\Rows()
        If dY >= dpiY(ListEx()\Rows()\Y) And dY <= dpiY(ListEx()\Rows()\Y + ListEx()\Rows()\Height)
          ProcedureReturn ListIndex(ListEx()\Rows())
        EndIf
      Next

    Else
      ProcedureReturn #NotValid
    EndIf
    
  EndProcedure

  Procedure.i GetColumnDPI_(dX.i)
    
    If dX > dpiX(ListEx()\Size\X) And dX < dpiX(ListEx()\Size\Cols)
      
      ForEach ListEx()\Cols()
        If dpiX(ListEx()\Cols()\X) >= dX
          ProcedureReturn ListIndex(ListEx()\Cols()) - 1
        EndIf
      Next
      
      ProcedureReturn ListIndex(ListEx()\Cols())
    Else
      ProcedureReturn #NotValid
    EndIf
    
  EndProcedure
  
  
  Procedure   RemoveSelection_() ; Remove & Reset selection 
    ListEx()\Selection\Flag = #False
    ListEx()\Selection\Pos1 = #False
    ListEx()\Selection\Pos2 = #False
    ListEx()\Selection\Flag = #False
  EndProcedure  
  
  Procedure   DeleteSelection_() 
    Define.s Text
    
    If ListEx()\Selection\Flag = #TextSelected
      
      If ListEx()\String\Flag
        
        If ListEx()\Selection\Pos1 > ListEx()\Selection\Pos2
          ListEx()\String\Text = Left(ListEx()\String\Text, ListEx()\Selection\Pos2) + Mid(ListEx()\String\Text, ListEx()\Selection\Pos1 + 1)
          ListEx()\Cursor\Pos = ListEx()\Selection\Pos2
        Else
          ListEx()\String\Text = Left(ListEx()\String\Text, ListEx()\Selection\Pos1) + Mid(ListEx()\String\Text, ListEx()\Selection\Pos2 + 1)
          ListEx()\Cursor\Pos = ListEx()\Selection\Pos1
        EndIf  

      ElseIf ListEx()\ComboBox\Flag
        
        If ListEx()\Selection\Pos1 > ListEx()\Selection\Pos2
          ListEx()\ComboBox\Text = Left(ListEx()\ComboBox\Text, ListEx()\Selection\Pos2) + Mid(ListEx()\ComboBox\Text, ListEx()\Selection\Pos1 + 1)
          ListEx()\Cursor\Pos = ListEx()\Selection\Pos2
        Else
          ListEx()\ComboBox\Text = Left(ListEx()\ComboBox\Text, ListEx()\Selection\Pos1) + Mid(ListEx()\ComboBox\Text, ListEx()\Selection\Pos2 + 1)
          ListEx()\Cursor\Pos = ListEx()\Selection\Pos1
        EndIf 
        
      EndIf

      RemoveSelection_() 
    EndIf
    
  EndProcedure
  
  Procedure.s DeleteStringPart_(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf
    
    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure
  
  Procedure.s StringSegment_(String.s, Pos1.i, Pos2.i=#PB_Ignore) ; Return String from Pos1 to Pos2 
    Define.i Length = Pos2 - Pos1
    If Pos2 = #PB_Ignore
      ProcedureReturn Mid(String, Pos1, Len(String) - Pos1 + 1)
    Else
      ProcedureReturn Mid(String, Pos1, Pos2 - Pos1 + 1)
    EndIf
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
      
      ListEx()\Row\Number         = ListSize(ListEx()\Rows())
      ListEx()\Rows()\ID          = Label
      ListEx()\Rows()\Idx         = ListEx()\RowIdx
      ListEx()\Rows()\Height      = ListEx()\Row\Height
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
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value = ReplaceString(StringField(Text, i, #LF$), "|", #LF$)
          EndIf
        Next
        
      EndIf
      
      ListEx()\RowIdx + 1
      
    EndIf

    ProcedureReturn ListIndex(ListEx()\Rows())
  EndProcedure 
  
  ;- __________ ScrollBar __________
	
	Procedure   CalcScrollBar_()
	  Define.i LVNum, Width, Height, ScrollbarSize
	  
	  LVNum = ListEx()\ListView\Num
	  
	  ; current canvas ScrollbarSize
	  Width         = GadgetWidth(ListEx()\CanvasNum)
	  Height        = GadgetHeight(ListEx()\CanvasNum)

	  ScrollbarSize = ListEx()\Scrollbar\Size

	  ;{ Calc available canvas area
	  If ListEx()\HScroll\Hide And ListEx()\VScroll\Hide
	    ListEx()\Area\Width  = Width
      ListEx()\Area\Height = Height
    ElseIf ListEx()\HScroll\Hide
      ListEx()\Area\Width  = Width  - ScrollbarSize - 2
      ListEx()\Area\Height = Height
    ElseIf ListEx()\VScroll\Hide
      ListEx()\Area\Width  = Width
      ListEx()\Area\Height = Height - ScrollbarSize - 2
    Else
      ListEx()\Area\Width  = Width  - ScrollbarSize - 2
      ListEx()\Area\Height = Height - ScrollbarSize - 2
    EndIf  
    ;}
    
    ;{ Calc scrollbar size
    If ListEx()\ListView\Hide = #False
	    ListEx()\LScroll\X        = GadgetWidth(LVNum) - ScrollbarSize + 2
      ListEx()\LScroll\Y        = 1
      ListEx()\LScroll\Width    = ScrollbarSize - 2
      ListEx()\LScroll\Height   = GadgetHeight(LVNum) - 2
	  EndIf
    
    If ListEx()\Scrollbar\Flags & #Horizontal And ListEx()\Scrollbar\Flags & #Vertical
      
      If ListEx()\HScroll\Hide      ;{ only vertical visible
        
        ListEx()\VScroll\X        = Width - ScrollbarSize - 1
        ListEx()\VScroll\Y        = 1
        ListEx()\VScroll\Width    = ScrollbarSize
        ListEx()\VScroll\Height   = Height - 2
        ;}
      ElseIf ListEx()\VScroll\Hide  ;{ only horizontal visible
        
        ListEx()\HScroll\X        = 1
        ListEx()\HScroll\Y        = Height - ScrollbarSize - 1
        ListEx()\HScroll\Width    = Width - 2
        ListEx()\HScroll\Height   = ScrollbarSize
        ;}
      Else                          ;{ both scrollbars visible
        
        ListEx()\HScroll\X        = 1
        ListEx()\HScroll\Y        = Height - ScrollbarSize - 1
        ListEx()\HScroll\Width    = Width  - ScrollbarSize - 2
        ListEx()\HScroll\Height   = ScrollbarSize
        
        ListEx()\VScroll\X        = Width - ScrollbarSize - 1
        ListEx()\VScroll\Y        = 1
        ListEx()\VScroll\Width    = ScrollbarSize
        ListEx()\VScroll\Height   = Height - ScrollbarSize - 2
        ;}
      EndIf 
      
    ElseIf ListEx()\Scrollbar\Flags & #Horizontal        ;{ only horizontal availible
      
      ListEx()\HScroll\X        = 1
      ListEx()\HScroll\Y        = Height - ScrollbarSize - 1
      ListEx()\HScroll\Width    = Width - 2
      ListEx()\HScroll\Height   = ScrollbarSize
      ;}
    ElseIf ListEx()\Scrollbar\Flags & #Vertical          ;{ only vertical availible
      
      ListEx()\VScroll\X        = Width - ScrollbarSize - 1
      ListEx()\VScroll\Y        = 1
      ListEx()\VScroll\Width    = ScrollbarSize
      ListEx()\VScroll\Height   = Height - 2
      ;}
    EndIf
    ;} 

    ;{ Calc scroll buttons
    If ListEx()\ListView\Hide = #False
      ListEx()\LScroll\Buttons\Width  = ScrollbarSize - 2
      ListEx()\LScroll\Buttons\Height = ScrollbarSize - 2
      ; forward: down
      ListEx()\LScroll\Buttons\fX     = ListEx()\LScroll\X
      ListEx()\LScroll\Buttons\fY     = ListEx()\LScroll\Height - ScrollbarSize - 2
      ; backward: up
      ListEx()\LScroll\Buttons\bX     = ListEx()\LScroll\X
      ListEx()\LScroll\Buttons\bY     = 1
    EndIf  
    
    If ListEx()\Scrollbar\Flags & #Horizontal
      ListEx()\HScroll\Buttons\Width  = ScrollbarSize
      ListEx()\HScroll\Buttons\Height = ScrollbarSize
      ; forward: right
      ListEx()\HScroll\Buttons\fX     = ListEx()\HScroll\Width - ScrollbarSize + 1
      ListEx()\HScroll\Buttons\fY     = ListEx()\HScroll\Y
      ; backward: left
      ListEx()\HScroll\Buttons\bX     = 1
      ListEx()\HScroll\Buttons\bY     = ListEx()\HScroll\Y
    EndIf
    
    If ListEx()\Scrollbar\Flags & #Vertical
      ListEx()\VScroll\Buttons\Width  = ScrollbarSize
      ListEx()\VScroll\Buttons\Height = ScrollbarSize
      ; forward: down
      ListEx()\VScroll\Buttons\fX     = ListEx()\VScroll\X
      ListEx()\VScroll\Buttons\fY     = ListEx()\VScroll\Height - ScrollbarSize + 1
      ; backward: up
      ListEx()\VScroll\Buttons\bX     = ListEx()\VScroll\X
      ListEx()\VScroll\Buttons\bY     = 1
    EndIf
    ;}
    
    ;{ Calc scroll area between buttons
    If ListEx()\ListView\Hide = #False
      ListEx()\LScroll\Area\X      = ListEx()\LScroll\X
  		ListEx()\LScroll\Area\Y      = ScrollbarSize - 2
  		ListEx()\LScroll\Area\Width  = ScrollbarSize - 2
  		ListEx()\LScroll\Area\Height = ListEx()\LScroll\Height - (ScrollbarSize - 2) * 2
    EndIf   
    
    If ListEx()\Scrollbar\Flags & #Horizontal
      ListEx()\HScroll\Area\X      = ScrollbarSize + 1
  		ListEx()\HScroll\Area\Y      = ListEx()\HScroll\Y
  		ListEx()\HScroll\Area\Width  = ListEx()\HScroll\Width - ScrollbarSize * 2 
  		ListEx()\HScroll\Area\Height = ScrollbarSize
    EndIf   
    
    If ListEx()\Scrollbar\Flags & #Vertical
      ListEx()\VScroll\Area\X      = ListEx()\VScroll\X
  		ListEx()\VScroll\Area\Y      = ScrollbarSize + 1
  		ListEx()\VScroll\Area\Width  = ScrollbarSize
  		ListEx()\VScroll\Area\Height = ListEx()\VScroll\Height - ScrollbarSize * 2
    EndIf  		
    ;}

    ;{ Calc thumb size
    If ListEx()\ListView\Hide = #False
      
      ListEx()\LScroll\Thumb\X      = ListEx()\LScroll\Area\X
		  ListEx()\LScroll\Thumb\Width  = ScrollbarSize - 2
		  ListEx()\LScroll\Thumb\Height = Round(ListEx()\LScroll\Area\Height * ListEx()\LScroll\Ratio, #PB_Round_Nearest) 
		  ListEx()\LScroll\Factor       = (ListEx()\LScroll\Area\Height - ListEx()\LScroll\Thumb\Height) /  ListEx()\LScroll\Range
		  
		  If ListEx()\Scrollbar\Flags & #Style_Win11
		    ListEx()\LScroll\Thumb\Width - 10
		    ListEx()\LScroll\Thumb\X     + 5
		  Else
		    ListEx()\LScroll\Thumb\Width - 4
		    ListEx()\LScroll\Thumb\X     + 2
		  EndIf
		  
    EndIf   
    
    If ListEx()\Scrollbar\Flags & #Horizontal

		  ListEx()\HScroll\Thumb\Y      = ListEx()\HScroll\Area\Y
		  ListEx()\HScroll\Thumb\Width  = Round(ListEx()\HScroll\Area\Width * ListEx()\HScroll\Ratio, #PB_Round_Nearest)
		  ListEx()\HScroll\Thumb\Height = ScrollbarSize
		  ListEx()\HScroll\Factor       = (ListEx()\HScroll\Area\Width - ListEx()\HScroll\Thumb\Width) / ListEx()\HScroll\Range
		  
		  If ListEx()\Scrollbar\Flags & #Style_Win11
		    ListEx()\HScroll\Thumb\Height - 10
		    ListEx()\HScroll\Thumb\Y      + 5
		  Else
		    ListEx()\HScroll\Thumb\Height - 4
		    ListEx()\HScroll\Thumb\Y      + 2
		  EndIf

    EndIf
    
    If ListEx()\Scrollbar\Flags & #Vertical
      
      ListEx()\VScroll\Thumb\X      = ListEx()\VScroll\Area\X
		  ListEx()\VScroll\Thumb\Width  = ScrollbarSize
		  ListEx()\VScroll\Thumb\Height = Round(ListEx()\VScroll\Area\Height * ListEx()\VScroll\Ratio, #PB_Round_Nearest) 
		  ListEx()\VScroll\Factor       = (ListEx()\VScroll\Area\Height - ListEx()\VScroll\Thumb\Height) /  ListEx()\VScroll\Range

		  If ListEx()\Scrollbar\Flags & #Style_Win11
		    ListEx()\VScroll\Thumb\Width - 10
		    ListEx()\VScroll\Thumb\X     + 5
		  Else
		    ListEx()\VScroll\Thumb\Width - 4
		    ListEx()\VScroll\Thumb\X     + 2
		  EndIf

    EndIf  
    ;}
    
	EndProcedure
	
	Procedure   CalcScrollRange_()
	  
	  If ListEx()\ListView\Hide = #False
	    ListEx()\LScroll\Pos    = ListEx()\LScroll\Minimum
		  ListEx()\LScroll\minPos = ListEx()\LScroll\Minimum
		  ListEx()\LScroll\maxPos = ListEx()\LScroll\Maximum - ListEx()\LScroll\PageLength + 1
		  ListEx()\LScroll\Ratio  = ListEx()\LScroll\PageLength / ListEx()\LScroll\Maximum
		  ListEx()\LScroll\Range  = ListEx()\LScroll\maxPos - ListEx()\LScroll\minPos
		  
		  CalcScrollBar_()
		  
  	  ListEx()\LScroll\Thumb\Y = ListEx()\LScroll\Area\Y
		  
		  ProcedureReturn #True
	  EndIf  
	  
		If ListEx()\Scrollbar\Flags & #Horizontal
		  
		  If ListEx()\HScroll\PageLength
        ListEx()\HScroll\Pos    = ListEx()\HScroll\Minimum
  		  ListEx()\HScroll\minPos = ListEx()\HScroll\Minimum
  		  ListEx()\HScroll\maxPos = ListEx()\HScroll\Maximum - ListEx()\HScroll\PageLength + 1
  		  ListEx()\HScroll\Ratio  = ListEx()\HScroll\PageLength / ListEx()\HScroll\Maximum
  		  ListEx()\HScroll\Range  = ListEx()\HScroll\maxPos - ListEx()\HScroll\minPos
  		EndIf 

    EndIf
    
    If ListEx()\Scrollbar\Flags & #Vertical
      
      If ListEx()\VScroll\PageLength
        ListEx()\VScroll\Pos    = ListEx()\VScroll\Minimum
  		  ListEx()\VScroll\minPos = ListEx()\VScroll\Minimum
  		  ListEx()\VScroll\maxPos = ListEx()\VScroll\Maximum - ListEx()\VScroll\PageLength + 1
  		  ListEx()\VScroll\Ratio  = ListEx()\VScroll\PageLength / ListEx()\VScroll\Maximum
  		  ListEx()\VScroll\Range  = ListEx()\VScroll\maxPos - ListEx()\VScroll\minPos
  		EndIf
  		
    EndIf 
    
    CalcScrollBar_()
    
    ListEx()\HScroll\Thumb\X = ListEx()\HScroll\Area\X
  	ListEx()\VScroll\Thumb\Y = ListEx()\VScroll\Area\Y
    
	EndProcedure
	
	
	Procedure.i GetThumbPosX_(X.i)   ; Horizontal Scrollbar
	  Define.i Delta, Offset
	  
	  Delta = X - ListEx()\HScroll\CursorPos
	  ListEx()\HScroll\Thumb\X + Delta 
	  
	  If ListEx()\HScroll\Thumb\X < ListEx()\HScroll\Area\X
	    ListEx()\HScroll\Thumb\X = ListEx()\HScroll\Area\X
	  EndIf 
	  
	  If ListEx()\HScroll\Thumb\X + ListEx()\HScroll\Thumb\Width > ListEx()\HScroll\Area\X + ListEx()\HScroll\Area\Width
	    ListEx()\HScroll\Thumb\X = ListEx()\HScroll\Area\X + ListEx()\HScroll\Area\Width - ListEx()\HScroll\Thumb\Width
	  EndIf

	  Offset = ListEx()\HScroll\Thumb\X - ListEx()\HScroll\Area\X
	  ListEx()\HScroll\Pos = Round(Offset / ListEx()\HScroll\Factor, #PB_Round_Nearest) + ListEx()\HScroll\minPos
	  
	  
	  If ListEx()\HScroll\Pos > ListEx()\HScroll\maxPos : ListEx()\HScroll\Pos = ListEx()\HScroll\maxPos : EndIf
  	If ListEx()\HScroll\Pos < ListEx()\HScroll\minPos : ListEx()\HScroll\Pos = ListEx()\HScroll\minPos : EndIf
	  
  	ProcedureReturn ListEx()\HScroll\Pos
  	
	EndProcedure  
	
	Procedure.i GetThumbPosY_(Y.i)   ; Vertical Scrollbar
	  Define.i Delta, Offset

	  Delta = Y - ListEx()\VScroll\CursorPos
	  ListEx()\VScroll\Thumb\Y + Delta 

	  If ListEx()\VScroll\Thumb\Y < ListEx()\VScroll\Area\Y
	    ListEx()\VScroll\Thumb\Y =  ListEx()\VScroll\Area\Y
	  EndIf 
	  
	  If ListEx()\VScroll\Thumb\Y + ListEx()\VScroll\Thumb\Height >  ListEx()\VScroll\Area\Y + ListEx()\VScroll\Area\Height
	    ListEx()\VScroll\Thumb\Y =  ListEx()\VScroll\Area\Y + ListEx()\VScroll\Area\Height - ListEx()\VScroll\Thumb\Height
	  EndIf

	  Offset = ListEx()\VScroll\Thumb\Y - ListEx()\VScroll\Area\Y
	  ListEx()\VScroll\Pos = Round(Offset / ListEx()\VScroll\Factor, #PB_Round_Nearest) + ListEx()\VScroll\minPos

	  If ListEx()\VScroll\Pos > ListEx()\VScroll\maxPos : ListEx()\VScroll\Pos = ListEx()\VScroll\maxPos : EndIf
	  If ListEx()\VScroll\Pos < ListEx()\VScroll\minPos : ListEx()\VScroll\Pos = ListEx()\VScroll\minPos : EndIf
	  
	  ProcedureReturn ListEx()\VScroll\Pos
	EndProcedure  
	
  Procedure.i GetThumbPosL_(Y.i)   ; ListView Scrollbar
	  Define.i Delta, Offset

	  Delta = Y - ListEx()\LScroll\CursorPos
	  ListEx()\LScroll\Thumb\Y + Delta 

	  If ListEx()\LScroll\Thumb\Y < ListEx()\LScroll\Area\Y
	    ListEx()\LScroll\Thumb\Y =  ListEx()\LScroll\Area\Y
	  EndIf 
	  
	  If ListEx()\LScroll\Thumb\Y + ListEx()\LScroll\Thumb\Height >  ListEx()\LScroll\Area\Y + ListEx()\LScroll\Area\Height
	    ListEx()\LScroll\Thumb\Y =  ListEx()\LScroll\Area\Y + ListEx()\LScroll\Area\Height - ListEx()\LScroll\Thumb\Height
	  EndIf

	  Offset = ListEx()\LScroll\Thumb\Y - ListEx()\LScroll\Area\Y
	  ListEx()\LScroll\Pos = Round(Offset / ListEx()\LScroll\Factor, #PB_Round_Nearest) + ListEx()\LScroll\minPos

	  If ListEx()\LScroll\Pos > ListEx()\LScroll\maxPos : ListEx()\LScroll\Pos = ListEx()\LScroll\maxPos : EndIf
	  If ListEx()\LScroll\Pos < ListEx()\LScroll\minPos : ListEx()\LScroll\Pos = ListEx()\LScroll\minPos : EndIf
	  
	  ProcedureReturn ListEx()\LScroll\Pos
	EndProcedure 
	
	
	Procedure   SetThumbPosX_(Pos.i) ; Horizontal Scrollbar
	  Define.i  Offset
	  
	  ListEx()\HScroll\Pos = Pos

	  If ListEx()\HScroll\Pos < ListEx()\HScroll\minPos : ListEx()\HScroll\Pos = ListEx()\HScroll\minPos : EndIf
	  If ListEx()\HScroll\Pos > ListEx()\HScroll\maxPos : ListEx()\HScroll\Pos = ListEx()\HScroll\maxPos : EndIf
	  
    Offset = Round((ListEx()\HScroll\Pos - ListEx()\HScroll\minPos) * ListEx()\HScroll\Factor, #PB_Round_Nearest)
    ListEx()\HScroll\Thumb\X = ListEx()\HScroll\Area\X + Offset

	EndProcedure
	
	Procedure   SetThumbPosY_(Pos.i) ; Vertical Scrollbar
	  Define.i  Offset
	  
	  ListEx()\VScroll\Pos = Pos

	  If ListEx()\VScroll\Pos < ListEx()\VScroll\minPos : ListEx()\VScroll\Pos = ListEx()\VScroll\minPos : EndIf
	  If ListEx()\VScroll\Pos > ListEx()\VScroll\maxPos : ListEx()\VScroll\Pos = ListEx()\VScroll\maxPos : EndIf
	  
    Offset = Round((ListEx()\VScroll\Pos - ListEx()\VScroll\minPos) * ListEx()\VScroll\Factor, #PB_Round_Nearest)
    ListEx()\VScroll\Thumb\Y = ListEx()\VScroll\Area\Y + Offset

	EndProcedure
	
	Procedure   SetThumbPosL_(Pos.i) ; ListView Scrollbar
	  Define.i  Offset
	  
	  ListEx()\LScroll\Pos = Pos

	  If ListEx()\LScroll\Pos < ListEx()\LScroll\minPos : ListEx()\LScroll\Pos = ListEx()\LScroll\minPos : EndIf
	  If ListEx()\LScroll\Pos > ListEx()\LScroll\maxPos : ListEx()\LScroll\Pos = ListEx()\LScroll\maxPos : EndIf
	  
    Offset = Round((ListEx()\LScroll\Pos - ListEx()\LScroll\minPos) * ListEx()\LScroll\Factor, #PB_Round_Nearest)
    ListEx()\LScroll\Thumb\Y = ListEx()\LScroll\Area\Y + Offset

	EndProcedure
	
 
  Procedure.i CalcColsSize() 
    
    PushListPosition(ListEx()\Cols())
    
    ListEx()\Size\Cols = 0
  
    ForEach ListEx()\Cols() 
      If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
      ListEx()\Size\Cols + ListEx()\Cols()\Width
    Next
    
    PopListPosition(ListEx()\Cols())
    
  EndProcedure
  
	
	Procedure   AdjustScrollBars_()
    Define.i WidthOffset, Height, Width, RowsHeight
    Define.i VScroll, HScroll, ScrollbarSize
    
    Width  = GadgetWidth(ListEx()\CanvasNum)  - 2
    Height = GadgetHeight(ListEx()\CanvasNum) - 2
    
    ScrollbarSize = ListEx()\Scrollbar\Size
    
    ; --- Size without Scrollbars ---
    If ListEx()\Size\Rows > (Height - ListEx()\Header\Height)
      Width - ScrollbarSize
    EndIf  
    
    If ListEx()\Size\Cols > Width
      Height - ScrollbarSize
    EndIf
    
    
    ;{ AutoResize column
    If ListEx()\AutoResize\Column <> #PB_Ignore 
      
      If ListEx()\Size\Cols > Width
        
        WidthOffset = ListEx()\Size\Cols - Width

        If SelectElement(ListEx()\Cols(), ListEx()\AutoResize\Column)
          If ListEx()\Cols()\Width - WidthOffset >= ListEx()\AutoResize\MinWidth
            ListEx()\Cols()\Width  - WidthOffset
            ListEx()\Size\Cols     - WidthOffset
            UpdateColumnX_()
          Else 
            WidthOffset = ListEx()\Cols()\Width - ListEx()\AutoResize\MinWidth
            ListEx()\Size\Cols - WidthOffset
            ListEx()\Cols()\Width = ListEx()\AutoResize\MinWidth
            UpdateColumnX_()
          EndIf
          
          Height = GadgetHeight(ListEx()\CanvasNum) - 2
          
          ListEx()\HScroll\Hide = #True
        EndIf
        
      ElseIf ListEx()\Size\Cols And ListEx()\Size\Cols < Width
        
        WidthOffset = Width - ListEx()\Size\Cols
        
        If SelectElement(ListEx()\Cols(), ListEx()\AutoResize\Column)

          If ListEx()\AutoResize\maxWidth > #PB_Default And ListEx()\Cols()\Width + WidthOffset > ListEx()\AutoResize\maxWidth
            WidthOffset = ListEx()\AutoResize\maxWidth - ListEx()\Cols()\Width
            ListEx()\Cols()\Width  + WidthOffset
            ListEx()\Size\Cols     + WidthOffset
          Else  
            ListEx()\Cols()\Width  + WidthOffset
            ListEx()\Size\Cols     + WidthOffset
          EndIf
          
          UpdateColumnX_()
          
          Height = GadgetHeight(ListEx()\CanvasNum) - 2
          
          ListEx()\HScroll\Hide = #True
        EndIf
        
      EndIf
      
    EndIf ;}  
    
    ; --- Size with Scrollbars ---
    If ListEx()\Size\Rows + ListEx()\Header\Height > Height ;{ Vertical Scrollbar
      ListEx()\VScroll\Maximum    = ListEx()\Size\Rows + ListEx()\Header\Height + 3
      ListEx()\VScroll\PageLength = Height - ListEx()\Header\Height - 3
      ListEx()\VScroll\Hide = #False
    Else
      ListEx()\Row\OffSetY = 0
      If ListSize(ListEx()\Rows())  = 0
        ListEx()\VScroll\Maximum    = 0
        ListEx()\VScroll\PageLength = 0
      EndIf 
      ListEx()\VScroll\Hide = #True
      ;}
    EndIf  
    
    If ListEx()\Size\Cols > Width ;{ Horizontal Scrollbar
      CalcColsSize() 
      ListEx()\HScroll\Maximum    = ListEx()\Size\Cols
      ListEx()\HScroll\PageLength = Width
      ListEx()\HScroll\Hide = #False
    Else
      ListEx()\Col\OffsetX = 0
      ListEx()\HScroll\Hide = #True
      ;}
    EndIf

    CalcScrollRange_()
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Functions
  ;- ========================================================================== 

  ;- _____ CSV - Support _____
  
  CompilerIf #Enable_CSV_Support
    
    Procedure.s Export_CSV_Header(Separator.s, DQuote.s, Flags.i=#False)
      Define.s CSV$ 
      
      
      ForEach ListEx()\Cols()
        
        If Flags & #NoButtons And ListEx()\Cols()\Flags & #Buttons : Continue : EndIf
        If Flags & #NoCheckBoxes And ListEx()\Cols()\Flags & #CheckBoxes : Continue : EndIf
        
        If Flags & #NoCheckBoxes And ListEx()\Flags & #CheckBoxes 
          
          Select ListIndex(ListEx()\Cols())
            Case 0  
              Continue
            Case 1
              CSV$ = DQuote + ListEx()\Cols()\Header\Title
            Default
              CSV$ + DQuote + Separator + DQuote + ListEx()\Cols()\Header\Title
          EndSelect    
          
        Else  
          
          If ListIndex(ListEx()\Cols()) = 0
            CSV$ = DQuote + ListEx()\Cols()\Header\Title
          Else  
            CSV$ + DQuote + Separator + DQuote + ListEx()\Cols()\Header\Title
          EndIf
          
        EndIf
        
      Next

      ProcedureReturn CSV$ + DQuote
    EndProcedure
    
    Procedure.s Export_CSV_Row(Separator.s, DQuote.s, Flags.i=#False)
      Define.s Key$, CSV$ 
      
      ForEach ListEx()\Cols()
        
        If Flags & #NoButtons And ListEx()\Cols()\Flags & #Buttons : Continue : EndIf
        If Flags & #NoCheckBoxes And ListEx()\Cols()\Flags & #CheckBoxes : Continue : EndIf
        
        Key$ = ListEx()\Cols()\Key
        
        
        If Flags & #NoCheckBoxes And ListEx()\Flags & #CheckBoxes 
          
          Select ListIndex(ListEx()\Cols())
            Case 0
              Continue
            Case 1
              CSV$ = DQuote + ListEx()\Rows()\Column(Key$)\Value
            Default
              If ListEx()\Cols()\Flags & #CheckBoxes
                CSV$ + DQuote + Separator + DQuote + Str(ListEx()\Rows()\Column(Key$)\State)
              Else
                CSV$ + DQuote + Separator + DQuote + ListEx()\Rows()\Column(Key$)\Value
              EndIf
          EndSelect

        Else
          
          If ListIndex(ListEx()\Cols()) = 0
  
            If ListEx()\Flags & #CheckBoxes
              CSV$ = DQuote + Str(ListEx()\Rows()\State)
            ElseIf ListEx()\Cols()\Flags & #CheckBoxes
              CSV$ = DQuote + Str(ListEx()\Rows()\Column(Key$)\State)
            Else
              CSV$ = DQuote + ListEx()\Rows()\Column(Key$)\Value
            EndIf
            
          Else
            
            If ListEx()\Cols()\Flags & #CheckBoxes
              CSV$ + DQuote + Separator + DQuote + Str(ListEx()\Rows()\Column(Key$)\State)
            Else
              CSV$ + DQuote + Separator + DQuote + ListEx()\Rows()\Column(Key$)\Value
            EndIf
            
          EndIf

        EndIf

      Next

      ProcedureReturn CSV$ + DQuote
    EndProcedure
    
    Procedure.i Import_CSV_Header(String.s, Separator.s, DQuote.s, Flags.i=#False)
      Define.i idx = 0
      Define.s Column$
      
      String = ReplaceString(String, DQuote + Separator + DQuote, #LF$)
      String = Trim(String, DQuote)
      
      ForEach ListEx()\Cols()
        
        If Flags & #NoButtons And ListEx()\Cols()\Flags & #Buttons : Continue : EndIf
        If Flags & #NoCheckBoxes And ListEx()\Cols()\Flags & #CheckBoxes : Continue : EndIf
        If Flags & #NoCheckBoxes And ListEx()\Flags & #CheckBoxes And ListIndex(ListEx()\Cols()) = 0 : Continue : EndIf
        
        idx + 1
        
        Column$ = StringField(String, idx, #LF$)
        ListEx()\Cols()\Header\Title = Column$

      Next
    
    EndProcedure
    
    Procedure.i Import_CSV_Row(String.s, Separator.s, DQuote.s, Flags.i=#False)
      Define.i i
      
      If AddElement(ListEx()\Rows())

        ListEx()\Row\Number    = ListSize(ListEx()\Rows())
        ListEx()\Rows()\ID     = ""
        ListEx()\Rows()\Idx    = ListEx()\RowIdx
        ListEx()\Rows()\Height = ListEx()\Row\Height
        ListEx()\Rows()\Color\Front = #PB_Default
        ListEx()\Rows()\Color\Back  = #PB_Default
        ListEx()\Rows()\Color\Line  = ListEx()\Color\Line
        
        String = ReplaceString(String, DQuote + Separator + DQuote, #LF$)
        String = Trim(String, DQuote)
        
        If String <> ""

          For i=0 To CountString(String, #LF$)
            
            If SelectElement(ListEx()\Cols(), i)
              
              If Flags & #NoButtons And ListEx()\Cols()\Flags & #Buttons : Continue : EndIf
              If Flags & #NoCheckBoxes And ListEx()\Cols()\Flags & #CheckBoxes : Continue : EndIf
              If Flags & #NoCheckBoxes And ListEx()\Flags & #CheckBoxes And ListIndex(ListEx()\Cols()) = 0 : Continue : EndIf
              
              If i=0 And ListEx()\Flags & #CheckBoxes
                ListEx()\Rows()\State = Val(StringField(String, i + 1, #LF$))
              ElseIf ListEx()\Cols()\Flags & #CheckBoxes
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State = Val(StringField(String, i + 1, #LF$))
              Else
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value = StringField(String, i + 1, #LF$)
              EndIf
            
            EndIf

          Next
          
        EndIf

        ListEx()\RowIdx + 1
        
      EndIf
      
      ProcedureReturn 
    EndProcedure
    
  CompilerEndIf  
  
  ;- _____ Check Content _____
  
  CompilerIf #Enable_Validation Or #Enable_MarkContent
    
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
    
    Procedure.i IsCondition_(Content.s, Term.s, Flag.i=#False)
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
  
  ;- _____ Validate Content _____
  
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
      
      ;If CountString(Value, ".") <> 1 : ProcedureReturn #False : EndIf
      
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
  
    Procedure.i IsContentValid_(Value.s, Flag.i=#False)
      
      If Value = "" : ProcedureReturn #True : EndIf
      
      If Flag = #Strings : SelectElement(ListEx()\Cols(), ListEx()\String\Col) : EndIf  
      
      If ListEx()\Cols()\Flags & #Number      ;{ Number
        If ListEx()\Cols()\Term
          ProcedureReturn IsCondition_(Value, ListEx()\Cols()\Term, #Number)
        Else  
          ProcedureReturn IsInteger(Value, #True) 
        EndIf ;}
      ElseIf ListEx()\Cols()\Flags & #Integer ;{ Integer
        If ListEx()\Cols()\Term
          ProcedureReturn IsCondition_(Value, ListEx()\Cols()\Term, #Integer)
        Else  
          ProcedureReturn IsInteger(Value) 
        EndIf ;}
      ElseIf ListEx()\Cols()\Flags & #Float   ;{ Float
        If ListEx()\Cols()\Term
          ProcedureReturn IsCondition_(Value, ListEx()\Cols()\Term, #Float)
        Else
         ProcedureReturn IsFloat(Value)
        EndIf ;}
      ElseIf ListEx()\Cols()\Flags & #Grades
        ProcedureReturn IsGrade(Value)
      ElseIf ListEx()\Cols()\Flags & #Cash
        ProcedureReturn IsCash(Value)
      ElseIf ListEx()\Cols()\Flags & #Time
        ProcedureReturn IsTime(Value)
      Else                                    ;{ String
        If ListEx()\Cols()\Term
          ProcedureReturn IsCondition_(Value, ListEx()\Cols()\Term)
        EndIf   
        ;}
      EndIf  
      
      ProcedureReturn #True
    EndProcedure
  
  CompilerElse
    
    Procedure.i IsContentValid_(Value.s)
      ProcedureReturn #True
    EndProcedure
    
  CompilerEndIf
  
  ;- _____ Format Content _____
  
  CompilerIf #Enable_FormatContent
    
    Procedure.s FormatInteger_(String.s, Mask.s)
      Define.i Decimals
      Define.s TSep$, DSep$

      String = ReplaceString(String, ",", ".")
      
      If CountString(Mask, ",")
        TSep$ = ","
      ElseIf CountString(Mask, ".")
        TSep$ = "."
      EndIf  
      
      Decimals = CountString(StringField(Mask, 2, DSep$), "0")
      
      ProcedureReturn FormatNumber(ValF(String), 0, ".", TSep$)
    EndProcedure    
    
    Procedure.s FormatFloat_(String.s, Mask.s)
      Define.i Decimals
      Define.s DSep$, TSep$
      
      String = ReplaceString(String, ",", ".")
      
      If CountString(Mask, ",") = 1
        DSep$ = ","
        TSep$ = "."
      ElseIf CountString(Mask, ".") = 1
        DSep$ = "."
        TSep$ = ","
      EndIf  
      
      Decimals = CountString(StringField(Mask, 2, DSep$), "0")
      
      ProcedureReturn FormatNumber(ValF(String), Decimals, DSep$, TSep$)
    EndProcedure
    
    Procedure.s FormatCash_(String.s, Mask.s) 
      Define.i Decimals
      Define.s DSep$, TSep$, sMask$, eMask$
      
      String = ReplaceString(String, ",", ".")
      
      If CountString(Mask, ",") = 1
        DSep$ = ","
        TSep$ = "."
      ElseIf CountString(Mask, ".") = 1
        DSep$ = "."
        TSep$ = ","
      EndIf  
      
      sMask$ = RemoveString(StringField(Mask, 1, DSep$), "0")
      eMask$ = RemoveString(StringField(Mask, 2, DSep$), "0")
      
      Decimals = CountString(StringField(Mask, 2, DSep$), "0")
      
      ProcedureReturn sMask$ + FormatNumber(ValF(String), Decimals, DSep$, TSep$) + eMask$
    EndProcedure  
    
    
    Procedure.s FormatContent(String.s, Mask.s, Flags.i)
      
      If Flags & #Float
        ProcedureReturn FormatFloat_(String, Mask)
      ElseIf Flags & #Cash
        ProcedureReturn FormatCash_(String, Mask) 
      ElseIf Flags & #Integer
        ProcedureReturn String
      ElseIf Flags & #Number
        ProcedureReturn String
      ElseIf Flags & #Date Or Flags & #Time
        ProcedureReturn FormatDate(Mask, Val(String))
      ElseIf Flags & #Grades
        ProcedureReturn String
      Else
        ProcedureReturn String
      EndIf
     
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

  CompilerEndIf   
  
  ;- _____ Sorting _____
  
  Procedure.i GetFocusIdx_()
    Define.i Index = #PB_Default
    
    If ListEx()\Row\Focus >= 0
      
      PushListPosition(ListEx()\Rows())
      
      If SelectElement(ListEx()\Rows(), ListEx()\Row\Focus)
        Index = ListEx()\Rows()\Idx
      EndIf  
      
      PopListPosition(ListEx()\Rows())
      
    EndIf
    
    ProcedureReturn Index
  EndProcedure  
  
  Procedure   SetFocusIdx_(Index.i)

    If ListEx()\Focus
      
      ListEx()\Row\Focus = #NotValid
      
      ForEach ListEx()\Rows()
        If ListEx()\Rows()\Idx = Index
          ListEx()\Row\Focus = ListIndex(ListEx()\Rows())
          Break
        EndIf
      Next
      
    EndIf
    
  EndProcedure  
  
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
    Define.i Index
    Define.s String$
    
    Index = GetFocusIdx_()
    
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
    
    If ListEx()\Focus
      SetFocusIdx_(Index)
      SetRowFocus_(ListEx()\Row\Focus)
    EndIf
    
  EndProcedure
  
  ;- __________ Theme __________ 
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure   ColorTheme_(Theme.i)

    ListEx()\Color\Front        = $000000
    ListEx()\Color\Back         = $FFFFFF
    ListEx()\Color\Canvas       = $FFFFFF
    ListEx()\Color\Gadget       = $C8C8C8
    ListEx()\Color\ScrollBar    = $F0F0F0
    ListEx()\Color\Focus        = $D77800
    ListEx()\Color\FocusText    = $FFFFFF
    ListEx()\Color\HeaderFront  = $000000
    ListEx()\Color\HeaderBack   = $FAFAFA
    ListEx()\Color\HeaderLine   = $A0A0A0
    ListEx()\Color\Line         = $E3E3E3
    ListEx()\Color\ButtonFront  = $000000
    ListEx()\Color\ButtonBack   = $E3E3E3
    ListEx()\Color\ButtonBorder = $A0A0A0
    ListEx()\Color\ProgressBar  = $32CD32
    ListEx()\Color\Gradient     = $00FC7C
    ListEx()\Color\EditFront    = $000000
    ListEx()\Color\EditBack     = $FFFFFF
    ListEx()\Color\Link         = $8B0000
    ListEx()\Color\ActiveLink   = $FF0000
    ListEx()\Color\WrongFront   = $0000FF
    ListEx()\Color\WrongBack    = $FFFFFF
    ListEx()\Color\Mark1        = $008B45
    ListEx()\Color\Mark2        = $0000FF
    ListEx()\Color\StringFront  = #PB_Default
    ListEx()\Color\StringBack   = #PB_Default
    ListEx()\Color\ComboFront   = #PB_Default
    ListEx()\Color\ComboBack    = #PB_Default
    
    CompilerSelect  #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ListEx()\Color\Gadget       = GetSysColor_(#COLOR_MENU)
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
        ListEx()\Color\Gadget       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
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
    
    ListEx()\Color\AlternateRow = #PB_Default
    
    Select Theme
      Case #Theme_Blue
        
        ListEx()\Color\Front        = $000000
        ListEx()\Color\Back         = 16645114
        ListEx()\Color\Line         = 13092807
        ListEx()\Color\HeaderFront  = 4270875
        ListEx()\Color\HeaderBack   = 14599344
        ListEx()\Color\HeaderLine   = 8750469
        ListEx()\Color\ProgressBar  = 11369795
        ListEx()\Color\Gradient     = 13874833
        ListEx()\Color\AlternateRow = #PB_Default
        ListEx()\Color\ButtonFront  = $490000
        ListEx()\Color\ButtonBack   = $E3E3E3
        ListEx()\Color\ButtonBorder = $B48246

      Case #Theme_Green
        
        ListEx()\Color\Front        = $000000
        ListEx()\Color\Back         = 16383222
        ListEx()\Color\Line         = 13092807
        ListEx()\Color\HeaderFront  = 2374163
        ListEx()\Color\HeaderBack   = 6674533
        ListEx()\Color\HeaderLine   = 8750469
        ListEx()\Color\ProgressBar  = 2263842
        ListEx()\Color\Gradient     = 7527538
        ListEx()\Color\AlternateRow = #PB_Default
        ListEx()\Color\ButtonFront  = $0F2203
        ListEx()\Color\ButtonBack   = $E3E3E3
        ListEx()\Color\ButtonBorder = $A0A0A0
        
    EndSelect

  EndProcedure  
  
  Procedure   SetColor_(ColorTyp.i, Value.i, Column.i=#PB_Ignore)

    Select ColorTyp
      Case #ButtonBorderColor
        ListEx()\Color\ButtonBorder     = Value
      Case #ActiveLinkColor  
        ListEx()\Color\ActiveLink       = Value
      Case #FrontColor
        If Column = #PB_Ignore
          ListEx()\Color\Front          = Value
        Else
          If SelectElement(ListEx()\Cols(), Column)
            ListEx()\Cols()\FrontColor = Value
          EndIf
        EndIf 
      Case #BackColor
        If Column = #PB_Ignore
          ListEx()\Color\Back           = Value
        Else
          If SelectElement(ListEx()\Cols(), Column)
            ListEx()\Cols()\BackColor = Value
          EndIf
        EndIf 
      Case #ButtonColor  
        ListEx()\Color\ButtonBack       = Value
      Case #ProgressBarColor
        ListEx()\Color\ProgressBar      = Value
      Case #GradientColor
        ListEx()\Color\Gradient         = Value
      Case #LineColor
        ListEx()\Color\Line             = Value
      Case #FocusColor
        ListEx()\Color\Focus            = Value
        ListEx()\ScrollBar\Color\Focus  = Value
      Case #FocusTextColor
        ListEx()\Color\FocusText        = Value  
      Case #EditFrontColor
        ListEx()\Color\EditFront        = Value
      Case #EditBackColor
        ListEx()\Color\EditBack         = Value  
      Case #LinkColor
        ListEx()\Color\Link             = Value
      Case #HeaderFrontColor
        ListEx()\Color\HeaderFront      = Value
      Case #HeaderBackColor
        ListEx()\Color\HeaderBack       = Value
      Case #HeaderLineColor
        ListEx()\Color\HeaderLine       = Value
      Case #GadgetBackColor
        ListEx()\Color\Canvas           = Value
      Case #AlternateRowColor
        ListEx()\Color\AlternateRow     = Value
      Case #ComboFrontColor
        ListEx()\Color\ComboFront       = Value
      Case #ComboBackColor
        ListEx()\Color\ComboBack        = Value
      Case #StringFrontColor
        ListEx()\Color\StringFront      = Value
      Case #StringBackColor
        ListEx()\Color\StringBack       = Value
      Case #ScrollBar_FrontColor
        ListEx()\ScrollBar\Color\Front  = Value
      Case #ScrollBar_BackColor 
        ListEx()\Scrollbar\Color\Back   = Value
      Case #ScrollBar_ButtonColor
        ListEx()\ScrollBar\Color\Button = Value
      Case #ScrollBar_ThumbColor
        ListEx()\ScrollBar\Color\Focus = Value  
    EndSelect

  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Drawing (DPI)
  ;- ========================================================================== 
  
  ;- ----- Scrollbars -----

	Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i, Round.i=#False) ; DPI
	  
	  If Round
	    RoundBox(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), dpiX(Round), dpiY(Round), Color)  
  	Else
  		Box(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), Color)
  	EndIf
  	
  EndProcedure	
	
  Procedure   DrawArrow_(Color.i, Direction.i)       ; DPI
	  Define.i X, Y, Width, Height, aWidth, aHeight, aColor, GNum
	  
	  GNum = ListEx()\CanvasNum
	  
	  aColor = RGBA(Red(Color), Green(Color), Blue(Color), 255)
	  
	  Select Direction ;{ Position & Size
	    Case #Scrollbar_Down
	      X       = ListEx()\VScroll\Buttons\fX
	      Y       = ListEx()\VScroll\Buttons\fY
	      Width   = ListEx()\VScroll\Buttons\Width
	      Height  = ListEx()\VScroll\Buttons\Height
	    Case #Scrollbar_Up
	      X       = ListEx()\VScroll\Buttons\bX
	      Y       = ListEx()\VScroll\Buttons\bY
	      Width   = ListEx()\VScroll\Buttons\Width
	      Height  = ListEx()\VScroll\Buttons\Height
	    Case #Scrollbar_Left
	      X       = ListEx()\HScroll\Buttons\bX
	      Y       = ListEx()\HScroll\Buttons\bY
	      Width   = ListEx()\HScroll\Buttons\Width
	      Height  = ListEx()\HScroll\Buttons\Height
	    Case #Scrollbar_Right
	      X       = ListEx()\HScroll\Buttons\fX
	      Y       = ListEx()\HScroll\Buttons\fY
	      Width   = ListEx()\HScroll\Buttons\Width
	      Height  = ListEx()\HScroll\Buttons\Height 
	    Case #ListView_Down
	      X       = ListEx()\LScroll\Buttons\fX
	      Y       = ListEx()\LScroll\Buttons\fY
	      Width   = ListEx()\LScroll\Buttons\Width
	      Height  = ListEx()\LScroll\Buttons\Height
	      GNum = ListEx()\ListView\Num
	    Case #ListView_Up  
	      X       = ListEx()\LScroll\Buttons\bX
	      Y       = ListEx()\LScroll\Buttons\bY
	      Width   = ListEx()\LScroll\Buttons\Width
	      Height  = ListEx()\LScroll\Buttons\Height
	      GNum = ListEx()\ListView\Num
	  EndSelect ;}
	  
	  If ListEx()\Scrollbar\Flags & #Style_Win11 ;{ Arrow Size 
	    
	    Select Direction
	      Case #Scrollbar_Down, #Scrollbar_Up
	        aWidth  = 10
    	    aHeight =  7
	      Case #Scrollbar_Left, #Scrollbar_Right
          aWidth  =  7
          aHeight = 10 
	      Case #ListView_Down, #ListView_Up
	        aWidth  = 10
    	    aHeight =  7
	    EndSelect      
	    
	    If ListEx()\HScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If ListEx()\HScroll\Buttons\fState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	    If ListEx()\VScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If ListEx()\VScroll\Buttons\fState= #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	  Else
	    
	    If Direction = #Scrollbar_Down Or Direction = #Scrollbar_Up
  	    aWidth  = 8
  	    aHeight = 4
  	  Else
        aWidth  = 4
        aHeight = 8  
	    EndIf  
      ;}
	  EndIf  
	  
	  X + (Width  - aWidth) / 2
    Y + (Height - aHeight) / 2
	  
	  If StartVectorDrawing(CanvasVectorOutput(GNum))

      If ListEx()\Scrollbar\Flags & #Style_Win11 ;{ solid

        Select Direction
          Case #Scrollbar_Up, #ListView_Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
            ClosePath()
          Case #Scrollbar_Down, #ListView_Down
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
            ClosePath()
          Case #Scrollbar_Left
            MovePathCursor(dpiX(X + aWidth), dpiY(Y))
            AddPathLine(dpiX(X), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
            ClosePath()
          Case #Scrollbar_Right
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X), dpiY(Y + aHeight))
            ClosePath()
        EndSelect
        
        VectorSourceColor(aColor)
        FillPath()
        StrokePath(1)
        ;}
      Else                                       ;{ /\

        Select Direction
          Case #Scrollbar_Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
          Case #Scrollbar_Down 
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
          Case #Scrollbar_Left
            MovePathCursor(dpiX(X + aWidth), dpiY(Y))
            AddPathLine(dpiX(X), dpiY(Y + aHeight / 2))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
          Case #Scrollbar_Right
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
  
	Procedure   DrawScrollButton_(Scrollbar.i, Type.i) ; DPI
	  Define.i X, Y, Width, Height
	  Define.i ArrowColor, ButtonColor, Direction, State
	  
	  Select Scrollbar   ; Position, Size, State & Direction
	    Case #Horizontal ;{ Horizontal Scrollbar
	      
	      If ListEx()\HScroll\Hide : ProcedureReturn  #False : EndIf 
	      
        Width  = ListEx()\HScroll\Buttons\Width
        Height = ListEx()\HScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X      = ListEx()\HScroll\Buttons\fX
            Y      = ListEx()\HScroll\Buttons\fY
            State  = ListEx()\HScroll\Buttons\fState
            Direction = #Scrollbar_Right
  	      Case #Backwards
  	        X     = ListEx()\HScroll\Buttons\bX
            Y     = ListEx()\HScroll\Buttons\bY
            State = ListEx()\HScroll\Buttons\bState
            Direction = #Scrollbar_Left
  	    EndSelect 
        ;}
      Case #Vertical   ;{ Vertical Scrollbar
        
        If ListEx()\VScroll\Hide : ProcedureReturn  #False : EndIf 
        
        Width  = ListEx()\VScroll\Buttons\Width
        Height = ListEx()\VScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X     = ListEx()\VScroll\Buttons\fX
            Y     = ListEx()\VScroll\Buttons\fY
            State = ListEx()\VScroll\Buttons\fState
            Direction = #Scrollbar_Down
  	      Case #Backwards
  	        X     = ListEx()\VScroll\Buttons\bX
            Y     = ListEx()\VScroll\Buttons\bY
            State = ListEx()\VScroll\Buttons\bState
            Direction = #Scrollbar_Up
        EndSelect
        ;}
      Case #ListView   ;{ ListView  Scrollbar
        
        If ListEx()\ListView\Hide : ProcedureReturn  #False : EndIf 
        
        Width  = ListEx()\LScroll\Buttons\Width
        Height = ListEx()\LScroll\Buttons\Height
        
        Select Type
          Case #ListView_Down
            X     = ListEx()\LScroll\Buttons\fX
            Y     = ListEx()\LScroll\Buttons\fY
            State = ListEx()\LScroll\Buttons\fState
            Direction = #ListView_Down
  	      Case #ListView_Up
  	        X     = ListEx()\LScroll\Buttons\bX
            Y     = ListEx()\LScroll\Buttons\bY
            State = ListEx()\LScroll\Buttons\bState
            Direction = #ListView_Up
        EndSelect
        ;}
    EndSelect 
    
    ;{ ----- Colors -----
    If ListEx()\Scrollbar\Flags & #Style_Win11
      
      ButtonColor = ListEx()\Scrollbar\Color\Back
      
      Select State
	      Case #Focus
	        ArrowColor = ListEx()\Scrollbar\Color\Focus
	      Case #Hover
	        ArrowColor = ListEx()\Scrollbar\Color\Hover
	      Case #Click  
	        ArrowColor = ListEx()\Scrollbar\Color\Arrow
	      Default
	        ArrowColor = #PB_Default
	    EndSelect    

    Else
      
      Select State
	      Case #Hover
	        ButtonColor  = BlendColor_(ListEx()\Scrollbar\Color\Focus, ListEx()\Scrollbar\Color\Button, 10)
	      Case #Click
	        ButtonColor  = BlendColor_(ListEx()\Scrollbar\Color\Focus, ListEx()\Scrollbar\Color\Button, 20)
	      Default
	        ButtonColor  = ListEx()\Scrollbar\Color\Button
	    EndSelect  
	    
	    ArrowColor = ListEx()\Scrollbar\Color\Arrow
	    
	  EndIf 
	  ;}
    
	  ;{ ----- Draw button -----
	  Select Scrollbar
	    Case #ListView
	     
	      If StartDrawing(CanvasOutput(ListEx()\ListView\Num))
    	    DrawingMode(#PB_2DDrawing_Default)
    	    Box_(X, Y, Width, Height, ButtonColor)
    	    StopDrawing()
    	  EndIf
    	  
	    Default
	      
	      If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
    	    DrawingMode(#PB_2DDrawing_Default)
    	    Box_(X, Y, Width, Height, ButtonColor)
    	    StopDrawing()
    	  EndIf
    	  
	  EndSelect    
	  ;}
	  
	  ;{ ----- Draw Arrows -----
	  If ArrowColor <> #PB_Default
	    DrawArrow_(ArrowColor, Direction)
	  EndIf ;} 

	EndProcedure
	
	Procedure   DrawThumb_(Scrollbar.i)                ; DPI
	  Define.i BackColor, ThumbColor, ThumbState, Round
	  Define.i OffsetPos, OffsetSize, ThumbSize
	  
	  ;{ ----- Thumb cursor state -----
	  Select Scrollbar 
	    Case #Horizontal
	      If ListEx()\HScroll\Hide : ProcedureReturn #False : EndIf 
	      ThumbState = ListEx()\HScroll\Thumb\State
	    Case #Vertical
	      If ListEx()\VScroll\Hide : ProcedureReturn #False : EndIf 
	      ThumbState = ListEx()\VScroll\Thumb\State
	    Case #ListView
	      If ListEx()\LScroll\Hide : ProcedureReturn #False : EndIf 
	      ThumbState = ListEx()\LScroll\Thumb\State
  	EndSelect ;}    
  	
  	;{ ----- Colors -----
	  If ListEx()\Scrollbar\Flags & #Style_Win11 
	    
	    BackColor = ListEx()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = ListEx()\Scrollbar\Color\Focus
	      Case #Hover
	        ThumbColor = ListEx()\Scrollbar\Color\Hover
	      Case #Click
	        ThumbColor = ListEx()\Scrollbar\Color\Hover
	      Default
	        ThumbColor = ListEx()\Scrollbar\Color\Focus
	    EndSelect 
	    
	    If ThumbState ;{ Thumb size
	      Round = 4
	    Else
	      If Scrollbar = #ListView
	        OffsetPos  =  1
  	      OffsetSize = -2
	      Else  
  	      OffsetPos  =  2
  	      OffsetSize = -4
	      EndIf
	      Round = 0
  	    ;}
	    EndIf

	  Else
	    
	    BackColor = ListEx()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = BlendColor_(ListEx()\Scrollbar\Color\Focus, ListEx()\Scrollbar\Color\Front, 10)
	      Case #Hover
	        ThumbColor = BlendColor_(ListEx()\Scrollbar\Color\Focus, ListEx()\Scrollbar\Color\Hover, 10)
	      Case #Click
	        ThumbColor = BlendColor_(ListEx()\Scrollbar\Color\Focus, ListEx()\Scrollbar\Color\Front, 20)
	      Default
	        ThumbColor = ListEx()\Scrollbar\Color\Front
	    EndSelect 
	    
	    If ListEx()\Scrollbar\Flags & #Style_RoundThumb
	      Round = 4
	    Else
	      Round = #False
	    EndIf
	    
	  EndIf ;}  
	  
	  Select Scrollbar
	    Case #ListView ;{ ListView
	      
	      If StartDrawing(CanvasOutput(ListEx()\ListView\Num))
    	    
    	    DrawingMode(#PB_2DDrawing_Default)

        	Box_(ListEx()\LScroll\Area\X, ListEx()\LScroll\Area\Y, ListEx()\LScroll\Area\Width, ListEx()\LScroll\Area\Height, BackColor)
        	Box_(ListEx()\LScroll\Thumb\X + OffsetPos, ListEx()\LScroll\Thumb\Y, ListEx()\LScroll\Thumb\Width + OffsetSize, ListEx()\LScroll\Thumb\Height, ThumbColor, Round)

      	  StopDrawing()
      	EndIf
      	;}
	    Default
	      
	      If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
    	    
    	    DrawingMode(#PB_2DDrawing_Default)
    
    	    Select Scrollbar 
    	      Case #Horizontal
    	        ThumbSize = ListEx()\HScroll\Thumb\Width
    	        If ThumbSize < ListEx()\Scrollbar\MinSize : ThumbSize = ListEx()\Scrollbar\MinSize : EndIf 
      	      Box_(ListEx()\HScroll\Area\X, ListEx()\HScroll\Area\Y, ListEx()\HScroll\Area\Width, ListEx()\HScroll\Area\Height, BackColor)
          	  Box_(ListEx()\HScroll\Thumb\X, ListEx()\HScroll\Thumb\Y + OffsetPos, ThumbSize, ListEx()\HScroll\Thumb\Height + OffsetSize, ThumbColor, Round)
          	Case #Vertical
          	  ThumbSize = ListEx()\VScroll\Thumb\Height
          	  If ThumbSize < ListEx()\Scrollbar\MinSize : ThumbSize = ListEx()\Scrollbar\MinSize : EndIf 
          	  Box_(ListEx()\VScroll\Area\X, ListEx()\VScroll\Area\Y, ListEx()\VScroll\Area\Width, ListEx()\VScroll\Area\Height, BackColor)
          	  Box_(ListEx()\VScroll\Thumb\X + OffsetPos, ListEx()\VScroll\Thumb\Y, ListEx()\VScroll\Thumb\Width + OffsetSize, ThumbSize, ThumbColor, Round)
          EndSelect
    
      	  StopDrawing()
    	  EndIf  

	  EndSelect

	EndProcedure  
	
	Procedure   DrawScrollBar_(ScrollBar.i=#False)     ; DPI
		Define.i OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		Select ScrollBar
		  Case #ListView, #ListView_Down, #ListView_Up ;{ ListView 
		  
		    If ListEx()\ListView\Hide = #False
		      
    		  OffsetY = Round((ListEx()\LScroll\Pos - ListEx()\LScroll\minPos) * ListEx()\LScroll\Factor, #PB_Round_Nearest)
    		  ListEx()\LScroll\Thumb\Y = ListEx()\LScroll\Area\Y + OffsetY

      		If StartDrawing(CanvasOutput(ListEx()\ListView\Num)) ; Draw scrollbar background
            
      		  DrawingMode(#PB_2DDrawing_Default)
      		  
    		    If ListEx()\LScroll\Hide = #False
      		    Box_(ListEx()\LScroll\X, 1, ListEx()\LScroll\Width, GadgetHeight(ListEx()\ListView\Num) - 2, ListEx()\Color\Gadget) ; ListEx()\Color\Gadget
      		  EndIf  
  
      		  StopDrawing()
      		EndIf
      		
      	EndIf
      	;}
		  Default
		    
		    ;{ ----- thumb position -----
    		If ListEx()\Scrollbar\Flags & #Horizontal
    		  OffsetX = Round((ListEx()\HScroll\Pos - ListEx()\HScroll\minPos) * ListEx()\HScroll\Factor, #PB_Round_Nearest)
    		  ListEx()\HScroll\Thumb\X = ListEx()\HScroll\Area\X + OffsetX
      	EndIf
    		
    		If ListEx()\Scrollbar\Flags & #Vertical
    		  OffsetY = Round((ListEx()\VScroll\Pos - ListEx()\VScroll\minPos) * ListEx()\VScroll\Factor, #PB_Round_Nearest)
    		  ListEx()\VScroll\Thumb\Y = ListEx()\VScroll\Area\Y + OffsetY
    		EndIf ;}
    		

    		If StartDrawing(CanvasOutput(ListEx()\CanvasNum)) ; Draw scrollbar background
      
    		  DrawingMode(#PB_2DDrawing_Default)
    		  
    		  If ScrollBar = #Horizontal|#Vertical
    		    
    		    If ListEx()\HScroll\Hide = #False
    		      Box_(0, ListEx()\HScroll\Y, GadgetWidth(ListEx()\CanvasNum), ListEx()\HScroll\Height + 1, ListEx()\Color\Gadget) ; ListEx()\Color\Gadget
    		    EndIf 

    		    If ListEx()\HScroll\Hide = #False
    		      Box_(ListEx()\VScroll\X, 0, ListEx()\VScroll\Width, GadgetHeight(ListEx()\CanvasNum) + 1, ListEx()\Color\Gadget)
    		    EndIf
    		    
    		  EndIf  
    		  
    		  StopDrawing()
    		EndIf

      	
		EndSelect    

		Select ScrollBar
		  Case #Horizontal  
		    DrawScrollButton_(#ListView, #ListView_Down)
    		DrawScrollButton_(#ListView, #ListView_Up)
		    DrawThumb_(#Horizontal) 
		  Case #Vertical
		    DrawScrollButton_(#ListView, #ListView_Down)
    		DrawScrollButton_(#ListView, #ListView_Up)
		    DrawThumb_(#Vertical)
		  Case #Scrollbar_Left
		    DrawThumb_(#Horizontal)
		    DrawScrollButton_(#Horizontal, #Backwards)
		  Case #Scrollbar_Right
		    DrawThumb_(#Horizontal)
		    DrawScrollButton_(#Horizontal, #Forwards)
		  Case #Scrollbar_Up
		    DrawThumb_(#Vertical)
		    DrawScrollButton_(#Vertical, #Backwards)
		  Case #Scrollbar_Down
		    DrawThumb_(#Vertical)
		    DrawScrollButton_(#Vertical, #Forwards)
		  Case #ListView
		    DrawThumb_(#ListView)
		  Case #ListView_Down
		    DrawThumb_(#ListView)
		    DrawScrollButton_(#ListView, #ListView_Down)
		  Case #ListView_Up  
		    DrawThumb_(#ListView)
		    DrawScrollButton_(#ListView, #ListView_Up)
		  Case #Horizontal|#Vertical
		    
		    If ListEx()\LScroll\Hide = #False
		      DrawScrollButton_(#ListView, #ListView_Down)
    		  DrawScrollButton_(#ListView, #ListView_Up)
    		  DrawThumb_(#ListView)
		    EndIf   
		    
		    If ListEx()\HScroll\Hide = #False
    		  DrawScrollButton_(#Horizontal, #Forwards)
    		  DrawScrollButton_(#Horizontal, #Backwards)
    		  DrawThumb_(#Horizontal)
    		EndIf
    		
    		If ListEx()\VScroll\Hide = #False
    		  DrawScrollButton_(#Vertical, #Forwards)
    		  DrawScrollButton_(#Vertical, #Backwards)
    		  DrawThumb_(#Vertical)
    		EndIf 
    		
		EndSelect    
		

	EndProcedure

  ;- ----- ListEx -----
  
  Procedure.f GetAlignOffset_(Text.s, Width.f, Flags.i) ; DPI
    Define.f Offset
    
    If Flags & #Right
      Offset = Width - TextWidth_(Text) - 4
    ElseIf Flags & #Center
      Offset = (Width - TextWidth_(Text)) / 2
    Else
      Offset = 4
    EndIf
    
    If Offset < 0 : Offset = 0 : EndIf
    
    ProcedureReturn Offset
  EndProcedure
  
  Procedure.i CurrentColumn_()
    ProcedureReturn ListIndex(ListEx()\Cols())
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
            ListEx()\Cols()\MaxWidth = TextWidth_(ListEx()\Cols()\Header\Title) + ListEx()\Cols()\Header\Image\Width + 4
          Else
            ListEx()\Cols()\MaxWidth = TextWidth_(ListEx()\Cols()\Header\Title)
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
            If TextWidth_(Text$) > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth_(Text$) : EndIf
            
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
                If TextWidth_(Text$) + ListEx()\Rows()\Column(Key$)\Image\Width > ListEx()\Cols()\MaxWidth
                  ListEx()\Cols()\MaxWidth = TextWidth_(Text$) + ListEx()\Rows()\Column(Key$)\Image\Width
                EndIf
              Else
                If TextWidth_(Text$) > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth_(Text$) : EndIf
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
                      Select IsCondition_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                If TextWidth_(Text$) + imgWidth > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth_(Text$) + imgWidth : EndIf
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
                      Select IsCondition_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                If TextWidth_(Text$) > ListEx()\Cols()\MaxWidth : ListEx()\Cols()\MaxWidth = TextWidth_(Text$) : EndIf
                
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
        
        ListEx()\Cols()\X  = ListEx()\Size\Cols - ListEx()\Col\OffsetX
        ListEx()\Size\Cols + ListEx()\Cols()\Width
        
      Next


      PopListPosition(ListEx()\Cols())
      PopListPosition(ListEx()\Rows())

      StopDrawing()
    EndIf  
  
  EndProcedure
  
  Procedure   AdjustRowsHeight_()
    Define.i FontID, RowFontID, textRows, rowHeight, maxHeight, maxColsHeight, r
    Define.s Key$
    
    If ListEx()\Flags & #AdjustRows ; Adjust row height
      
      If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
        
        PushListPosition(ListEx()\Rows())
        PushListPosition(ListEx()\Cols())
        
        ForEach ListEx()\Rows()
          
          If ListEx()\Rows()\FontID
            FontID = ListEx()\Rows()\FontID
          Else
            FontID = ListEx()\Row\FontID
          EndIf
          
          RowFontID = FontID
          
          maxColsHeight = ListEx()\Row\Height
          
          ForEach ListEx()\Cols()
            
            Key$ = ListEx()\Cols()\Key
            If Key$ = "" : Key$ = Str(ListIndex(ListEx()\Cols())) : EndIf
            
            FontID = RowFontID
            If ListEx()\Cols()\FontID : FontID = ListEx()\Cols()\FontID : EndIf
            If ListEx()\Rows()\Column(Key$)\Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
            
            DrawingFont(FontID)
            
            textRows = CountString(ListEx()\Rows()\Column(Key$)\Value, #LF$) + 1
            If textRows > 1
              
              maxHeight = 0
              rowHeight = TextHeight_("X")
 
              For r=1 To textRows
                maxHeight + rowHeight
              Next
              
              If maxColsHeight < maxHeight + 4
                maxColsHeight = maxHeight  + 4
              EndIf
              
            EndIf
            
            If maxColsHeight > ListEx()\Rows()\Height
              ListEx()\Rows()\Height = maxColsHeight
            ElseIf ListEx()\Rows()\Height > maxColsHeight
              ListEx()\Rows()\Height = maxColsHeight
            EndIf
            
          Next  
 
        Next  
        
        PopListPosition(ListEx()\Cols())
        PopListPosition(ListEx()\Rows())
  
        StopDrawing()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  
  Procedure.i HeaderArrow_(X.i, Y.i, Width.i, Height.i, Direction.i, Color.i=#PB_Default) ; DPI
    Define.i aX, aY, aWidth, aHeight
    
    If Color = #PB_Default : Color = BlendColor_($000000, ListEx()\Color\HeaderBack) : EndIf
    
    aWidth  = dpiX(8)
    aHeight = dpiX(4)
    
    aX = X + Width - aWidth - dpiX(5)
    aY = Y + (Height - aHeight) / 2
    
    If aWidth < Width And aHeight < Height 
    
      If Direction & #PB_Sort_Descending
        
        DrawingMode(#PB_2DDrawing_Default)
        Line(dpiX(aX), dpiY(aY), dpiX(aWidth), dpiY(1), Color)
        LineXY(dpiX(aX), dpiY(aY), dpiX(aX + (aWidth / 2)), dpiY(aY + aHeight), Color)
        LineXY(dpiX(aX + (aWidth / 2)), dpiY(aY + aHeight), dpiX(aX + aWidth), dpiY(aY), Color)
        FillArea(dpiX(aX + (aWidth / 2)), dpiY(aY + 2), -1, Color)

      Else

        DrawingMode(#PB_2DDrawing_Default)
        Line(dpiX(aX), dpiY(aY + aHeight), dpiX(aWidth), dpiY(1), Color)
        LineXY(dpiX(aX), dpiY(aY + aHeight), dpiX(aX + (aWidth / 2)), dpiY(aY), Color)
        LineXY(dpiX(aX + (aWidth / 2)), dpiY(aY), dpiX(aX + aWidth), dpiY(aY + aHeight), Color)
        FillArea(dpiX(aX + (aWidth / 2)), dpiY(aY + aHeight - 2), -1, Color)
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   ComboArrow_(X.i, Y.i, Width.i, Height.i, Color.i) ; DPI
	  Define.i aWidth, aHeight, aColor

	  If StartVectorDrawing(CanvasVectorOutput(ListEx()\CanvasNum))

      aColor  = RGBA(Red(Color), Green(Color), Blue(Color), 255)
      
	    aWidth  = 8
      aHeight = 4
      
      X + ((Width  - aWidth) / 2)
      Y + ((Height - aHeight) / 2)
      
      MovePathCursor(dpiX(X), dpiY(Y))
	    
      AddPathLine(dpiX(X + 4), dpiY(Y + aHeight))
      AddPathLine(dpiX(X + aWidth), dpiY(Y))
      VectorSourceColor(aColor)
      StrokePath(1, #PB_Path_RoundCorner)

	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
  
  Procedure   ComboButton_(ColorFlag.i=#False)                  ; DPI
    Define.i BackColor, BorderColor
    Define.i X, Y, Width, Height
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      X      = ListEx()\ComboBox\ButtonX
      Y      = ListEx()\ComboBox\Y
      Width  = #ButtonWidth
      Height = ListEx()\ComboBox\Height
      
      If ListEx()\Color\ComboBack = #PB_Default
        BackColor = ListEx()\Color\EditBack
      Else  
        BackColor = ListEx()\Color\ComboBack
      EndIf 
      
      If ColorFlag = #Click
        BackColor   = BlendColor_(ListEx()\Color\Focus, BackColor, 20)
        BorderColor = ListEx()\Color\Focus
      ElseIf ColorFlag = #Focus
        BackColor   = BlendColor_(ListEx()\Color\Focus, BackColor, 10)
        BorderColor = ListEx()\Color\Focus
      Else  
        BorderColor = ListEx()\Color\ButtonBorder
      EndIf
      
      DrawingMode(#PB_2DDrawing_Default)
      
      If ColorFlag & #Click Or ColorFlag & #Focus
        
        Box_(X, Y, Width, Height, BackColor)
        
        DrawingMode(#PB_2DDrawing_Outlined)
        Box_(X, Y, Width, Height, BorderColor)
        
      Else
        Box_(X, Y + 1, Width - 1, Height - 2, BackColor)
      EndIf
      
      StopDrawing()
    EndIf
    
    ComboArrow_(X, Y, Width, Height, ListEx()\Color\Front)
    
  EndProcedure
  
  Procedure.i Button_(X.i, Y.i, Width.i, Height.i, Text.s, ColorFlag.i=#False, FontID.i=#PB_Default) ; DPI
    Define.i textX, textY
    Define.i BackColor, BorderColor

    If ColorFlag = #Click
      BackColor   = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\ButtonBack, 20)
      BorderColor = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\ButtonBorder, 20)
    ElseIf ColorFlag = #Focus
      BackColor   = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\ButtonBack, 10)
      BorderColor = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\ButtonBorder, 10)
    Else
      BackColor   = ListEx()\Color\ButtonBack
      BorderColor = ListEx()\Color\ButtonBorder
    EndIf
     
    If FontID = #PB_Default
      DrawingFont(ListEx()\Row\FontID)
    ElseIf FontID
      DrawingFont(FontID)
    EndIf
    
    X + 2
    Y + 3
    Width  - 5
    Height - 5
    
    DrawingMode(#PB_2DDrawing_Default)
    Box_(X, Y, Width, Height, BackColor)
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box_(X, Y, Width, Height, BorderColor)
    
    DrawingMode(#PB_2DDrawing_Transparent)
    textX = GetAlignOffset_(Text, Width, #Center)
    textY = (Height - TextHeight_("Abc")) / 2
    DrawText(dpiX(X + textX), dpiY(Y + textY), Text, ListEx()\Color\ButtonFront)
    
  EndProcedure
  
  Procedure.i CheckBox_(X.i, Y.i, Width.i, Height.i, boxWidth.i, BackColor.i, State.i) ; DPI
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
    
    If boxWidth <= Width And boxWidth <= Height
      
      X + ((Width  - boxWidth) / 2)
      Y + ((Height - boxWidth) / 2) + 1
      
      LineColor = BlendColor_(ListEx()\Color\Front, BackColor, 60)
      
      If State & #Checked

        bColor = BlendColor_(LineColor, ListEx()\Color\ButtonBack, 80)
        
        X1 = X + 1
        X2 = X + boxWidth - 2
        Y1 = Y + 1
        Y2 = Y + boxWidth - 2
        
        LineXY(dpiX(X1 + 1), dpiY(Y1), dpiX(X2 + 1), dpiY(Y2), bColor)
        LineXY(dpiX(X1 - 1), dpiY(Y1), dpiX(X2 - 1), dpiY(Y2), bColor)
        LineXY(dpiX(X2 + 1), dpiY(Y1), dpiX(X1 + 1), dpiY(Y2), bColor)
        LineXY(dpiX(X2 - 1), dpiY(Y1), dpiX(X1 - 1), dpiY(Y2), bColor)
        LineXY(dpiX(X2),     dpiY(Y1), dpiX(X1),     dpiY(Y2), LineColor)
        LineXY(dpiX(X1),     dpiY(Y1), dpiX(X2),     dpiY(Y2), LineColor)
        
      ElseIf State & #Inbetween
        
        Box_(X, Y, boxWidth, boxWidth, BlendColor_(LineColor, BackColor, 50))
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(X + 2, Y + 2, boxWidth - 4, boxWidth - 4, BlendColor_(LineColor, BackColor, 5))
      Box_(X + 1, Y + 1, boxWidth - 2, boxWidth - 2, BlendColor_(LineColor, BackColor, 25))
      Box_(X,     Y,     boxWidth,     boxWidth, LineColor)
      
    EndIf
    
  EndProcedure
  
  Procedure.i String_(X.i, Y.i, Width.i, Height.i, Text.s, CursorPos.i, TextColor.i, BackColor.i, BorderColor.i, FontID.i) ; DPI
    Define.i p, PosX, PosY, txtHeight, CursorX, maxPosX, startX
    Define.s strgPart
    
    ClipOutput_(X, Y, Width, Height)
    
    ;{ _____ Background _____
    DrawingMode(#PB_2DDrawing_Default)
    Box_(X, Y, Width, Height, BackColor)
    ;}
    
    DrawingFont(FontID)
    txtHeight = TextHeight_("X")
    
    ;X + ListEx()\Col\OffsetX
    
    PosX    = X + 3
    PosY    = Y + ((Height - txtHeight) / 2) 
    maxPosX = X + Width - 1

    If Text
      
      CursorX = PosX + TextWidth_(Left(Text, CursorPos)) - 1
      
      If CursorX > maxPosX
        
        Text = Left(Text, CursorPos)
        
        For p = Len(Text) To 0 Step -1
          If PosX + TextWidth_(Right(Text, p)) <= maxPosX
            Text    = Right(Text, p)
            CursorX = PosX + TextWidth_(Text) - 1
            Break  
          EndIf 
        Next

      EndIf
      
      DrawingMode(#PB_2DDrawing_Transparent)
      
      DrawText(dpiX(PosX), dpiY(PosY), Text, TextColor)

    Else
      CursorX = PosX
    EndIf  
    
    ListEx()\Cursor\Pos = CursorPos
    
    ;{ _____ Selection ______
    If ListEx()\Selection\Flag = #TextSelected
 
      If ListEx()\Selection\Pos1 >  ListEx()\Selection\Pos2
        startX   = TextWidth_(Left(Text, ListEx()\Selection\Pos2))
        strgPart = StringSegment_(Text, ListEx()\Selection\Pos2 + 1, ListEx()\Selection\Pos1)
      Else
        startX   = TextWidth_(Left(Text, ListEx()\Selection\Pos1))
        strgPart = StringSegment_(Text, ListEx()\Selection\Pos1 + 1, ListEx()\Selection\Pos2)
      EndIf

      DrawingMode(#PB_2DDrawing_Default)
      DrawText(dpiX(PosX + startX), dpiY(PosY), strgPart, ListEx()\Color\FocusText, ListEx()\Color\Focus)
      
    EndIf 
    ;}

    UnclipOutput_()

    ;{ _____ Border _____
    DrawingMode(#PB_2DDrawing_Outlined)
    Box_(X, Y, Width, Height, BorderColor)
    ;}

    ProcedureReturn CursorX
  EndProcedure  
  

  CompilerIf #Enable_ProgressBar
    
    Procedure   DrawProgressBar_(X.f, Y.f, Width.f, Height.f, State.i, Text.s, TextColor.i, Align.i, FontID.i) ; DPI
      Define.f Factor
      Define.i pbWidth, pbHeight, textX, textY, Progress, Percent
      
      If State < ListEx()\ProgressBar\Minimum : State = ListEx()\ProgressBar\Minimum : EndIf
      If State > ListEx()\ProgressBar\Maximum : State = ListEx()\ProgressBar\Maximum : EndIf
      
      pbWidth  = Width  - 4
      pbHeight = Height - 4
      
      If State > ListEx()\ProgressBar\Minimum
        
        If State = ListEx()\ProgressBar\Maximum
          Progress = pbWidth
        Else
          Factor   = pbWidth / (ListEx()\ProgressBar\Maximum - ListEx()\ProgressBar\Minimum)
          Progress = (State - ListEx()\ProgressBar\Minimum) * Factor
        EndIf
        
        DrawingMode(#PB_2DDrawing_Gradient)
        
        FrontColor(ListEx()\Color\Gradient)
        BackColor(ListEx()\Color\ProgressBar)
        
        LinearGradient(dpiX(X + 2), dpiY(Y + 2), dpiX(X + 2) + Progress, dpiX(Y + 2) + pbHeight)
        
        Box(dpiX(X + 2), dpiY(Y + 2), dpiX(Progress), dpiY(pbHeight))
  
      EndIf
      
      Percent = ((State - ListEx()\ProgressBar\Minimum) * 100) /  (ListEx()\ProgressBar\Maximum - ListEx()\ProgressBar\Minimum)
      
      If Text
        
        DrawingFont(FontID)
        
        Text  = ReplaceString(Text, #Progress$, Str(Percent) + "%")
        textX = GetAlignOffset_(Text, pbWidth, Align)
        textY = (Height - TextHeight_(Text)) / 2
        
        DrawingMode(#PB_2DDrawing_Transparent)
        
        DrawText(dpiX(X + textX), dpiY(Y + textY), Text, TextColor)
        
      ElseIf ListEx()\ProgressBar\Flags & #ShowPercent
        
        DrawingFont(FontID)
        
        Text  = Str(Percent) + "%"
        textX = Progress - TextWidth_(Text)
        textY = (Height - TextHeight_(Text)) / 2
        
        If textX < 5 : textX = 5 : EndIf
        
        DrawingMode(#PB_2DDrawing_Transparent)
        
        DrawText(dpiX(X + textX), dpiY(Y + textY), Text, TextColor)
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      
      Box_(X + 2, Y + 2, pbWidth, pbHeight, ListEx()\Color\ButtonBorder)
      
    EndProcedure
    
  CompilerEndIf
  
  
  Procedure   DrawListView_() ; DPI
    Define.i X, Y, Width, Height, OffsetX, OffsetY, TextHeight, RowHeight
    Define.i FrontColor, BackColor, BorderColor, FocusBack

    If ListEx()\ListView\Hide : ProcedureReturn #False : EndIf 
    
    ;{ --- Color --- 
    If ListEx()\Color\ComboBack = #PB_Default
      BackColor = ListEx()\Color\EditBack
    Else  
      BackColor = ListEx()\Color\ComboBack
    EndIf 
    FrontColor  = ListEx()\Color\EditFront
    BorderColor = ListEx()\Color\ButtonBorder
    FocusBack   = BlendColor_(ListEx()\Color\Focus, BackColor, 10)
    ;}
    
    If StartDrawing(CanvasOutput(ListEx()\ListView\Num))
      
      Width  = GadgetWidth(ListEx()\ListView\Num)
      Height = GadgetHeight(ListEx()\ListView\Num)
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(0, 0, Width, Height, BackColor)
      ;}
      
      X = 0
      Y = 2
      
      DrawingFont(ListEx()\FontID)
      
      TextHeight = TextHeight_("X")
      RowHeight  = TextHeight + 4
      OffsetY    = 1
      
      ;{ _____ ScrollBar _____
      If ListEx()\LScroll\Hide = #False
        ListEx()\ListView\Offset = ListEx()\LScroll\Pos
      EndIf ;}
      
      ;{ _____ Rows _____
      ClipOutput_(0, 0, Width, Height) 

      ForEach ListEx()\ListView\Item()
        
        OffSetX = 5
        
        If ListIndex(ListEx()\ListView\Item()) < ListEx()\ListView\Offset
          ListEx()\ListView\Item()\Y = 0
          Continue
        EndIf  
        
        If ListEx()\ListView\Item()\Color <> #PB_Default
          FrontColor = ListEx()\ListView\Item()\Color
        Else
          FrontColor = ListEx()\Color\Front
        EndIf        

        If ListEx()\ListView\Focus = ListIndex(ListEx()\ListView\Item())
          Box_(X + 3, Y, Width - 6, RowHeight, BlendColor_(ListEx()\Color\Focus, BackColor, 10))
        EndIf
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(dpiX(X + OffsetX), dpiY(Y + OffsetY), ListEx()\ListView\Item()\String, FrontColor)

        ListEx()\ListView\Item()\Y = Y

        Y + RowHeight

        If Y > Y + Height : Break : EndIf
        
      Next
      
      ListEx()\ListView\RowHeight = RowHeight
      
      UnclipOutput_() 
      ;}
      
      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(0, 0, Width, Height, BorderColor)
      ;}
      
      StopDrawing()
    EndIf
    
    If ListEx()\LScroll\Hide = #False
      DrawScrollBar_(#ListView)
    EndIf
    
  EndProcedure
  
  Procedure   DrawComboBox_() ; DPI
    Define.i X, Y, Width, Height, txtHeight
    Define.i TextColor, BackColor, BorderColor
    
    If ListEx()\ComboBox\X < 0 Or ListEx()\ComboBox\Y < 0 : ProcedureReturn #False : EndIf 
    
    X      = ListEx()\ComboBox\X
    Y      = ListEx()\ComboBox\Y
    Width  = ListEx()\ComboBox\Width
    Height = ListEx()\ComboBox\Height
    
    If Y < ListEx()\Header\Height : ProcedureReturn #False : EndIf 
    
    ;{ --- Color ---
    If ListEx()\Color\ComboFront = #PB_Default
      TextColor = ListEx()\Color\EditFront
    Else  
      TextColor = ListEx()\Color\ComboFront
    EndIf   
    
    If SelectElement(ListEx()\Cols(), ListEx()\String\Col)
      If ListEx()\Cols()\FrontColor <> #PB_Default
        TextColor = ListEx()\Cols()\FrontColor
      EndIf
    EndIf   
    
    If ListEx()\Color\ComboBack = #PB_Default
      BackColor = ListEx()\Color\EditBack
    Else  
      BackColor = ListEx()\Color\ComboBack
    EndIf  

    BorderColor = ListEx()\Color\Focus
    ;}
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      DrawingFont(ListEx()\ComboBox\FontID)

      txtHeight = TextHeight_("X")

      ListEx()\Cursor\X         = String_(X, Y, Width, Height, ListEx()\ComboBox\Text, ListEx()\ComboBox\CursorPos, TextColor, BackColor, BorderColor, ListEx()\ComboBox\FontID)
      ListEx()\Cursor\Y         = Y + ((Height - txtHeight) / 2) 
      ListEx()\Cursor\ClipX     = X + Width - 1
      ListEx()\Cursor\Height    = txtHeight
      ListEx()\Cursor\BackColor = BackColor
      ListEx()\Cursor\Pos       = ListEx()\ComboBox\CursorPos
      
      ListEx()\ComboBox\ButtonX = X + Width - #ButtonWidth

      StopDrawing()
    EndIf
    
    ComboArrow_(ListEx()\ComboBox\ButtonX, Y, #ButtonWidth, Height, ListEx()\Color\Front)
    
  EndProcedure
  
  Procedure   DrawButton_(X.i, Y.i, Width.i, Height.i, Text.s, ColorFlag.i, TextColor.i, FontID.i, *Image.Image_Structure) ; DPI
    Define.i colX, rowY, imgX, imgY, Color

    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))

      If FontID > 0
        Button_(X, Y, Width, Height, Text, ColorFlag, FontID)
      Else
        Button_(X, Y, Width, Height, Text, ColorFlag)
      EndIf
      
      If *Image\ID ;{ Image 
        
        If *Image\Flags & #Center
          imgX = (Width - *Image\Width) / 2
        ElseIf *Image\Flags & #Right
          imgX = Width - *Image\Width - 4
        Else 
          imgX = 4
        EndIf
        
        imgY  = (Height - *Image\Height) / 2 + 1
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        
        If *Image\ID
          DrawImage(*Image\ID, dpiX(X + imgX), dpiY(Y + imgY), dpiX(*Image\Width), dpiY(*Image\Height))
        EndIf  
        ;}
      EndIf
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  Procedure   DrawLink_(X.i, Y.i, Width.i, Height.i, Text.s, LinkColor.i, Align.i, FontID.i, *Image.Image_Structure) ; DPI
    Define.f colX, rowY, textX, textY, imgX, imgY
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      UpdateRowY_()

      DrawingMode(#PB_2DDrawing_Default)
      
      Box_(X + 1, Y + 1, Width - 2, Height - 2, BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10))
      
      If *Image\ID ;{ Image 
        
        If *Image\Flags & #Center
          imgX = (Width - *Image\Width) / 2
        ElseIf *Image\Flags & #Right
          imgX = Width - *Image\Width - 4
        Else 
          imgX = 4
        EndIf
        
        imgY  = (Height - *Image\Height) / 2 + 1
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        
        If *Image\ID
          DrawImage(*Image\ID, dpiX(X + imgX + 1), dpiY(Y + imgY + 1), dpiX(*Image\Width - 2), dpiY(*Image\Height - 2)) 
        EndIf 
      
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
            textX = *Image\Width + 8
          EndIf
          
          textY = (Height - TextHeight_("Abc")) / 2 + 1
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          DrawText(dpiX(X + textX), dpiY(Y + textY), Text, LinkColor)
          
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
          textY = (Height - TextHeight_("Abc")) / 2 + 1
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          DrawText(dpiX(X + textX), dpiY(Y + textY), Text, LinkColor)
          
        EndIf
        ;}
      EndIf 

      StopDrawing()
    EndIf
    
  EndProcedure
  
  Procedure   DrawString_() ; DPI
    Define.i X, Y, Width, Height, txtHeight
    Define.i TextColor, BackColor, BorderColor
    
    If ListEx()\String\X < 0 Or ListEx()\String\Y < 0 : ProcedureReturn #False : EndIf 
    
    X      = ListEx()\String\X
    Y      = ListEx()\String\Y
    Width  = ListEx()\String\Width
    Height = ListEx()\String\Height
    
    If Y < 0 Or Y < ListEx()\Header\Height : ProcedureReturn #False : EndIf
    
    ;{ --- Color ---
    If IsContentValid_(ListEx()\String\Text, #Strings) = #False
      
      TextColor = ListEx()\Color\WrongFront
      BackColor = ListEx()\Color\WrongBack
      
    Else
      
      If ListEx()\Color\StringFront = #PB_Default
        TextColor = ListEx()\Color\EditFront
      Else  
        TextColor = ListEx()\Color\StringFront
      EndIf       
      
      If SelectElement(ListEx()\Cols(), ListEx()\String\Col)
        If ListEx()\Cols()\FrontColor <> #PB_Default
          TextColor = ListEx()\Cols()\FrontColor
        EndIf
      EndIf
      
      If ListEx()\Color\StringBack = #PB_Default
        BackColor = ListEx()\Color\EditBack
      Else
        BackColor = ListEx()\Color\StringBack
      EndIf
    
    EndIf 
    BorderColor = ListEx()\Color\Focus
    ;}
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      ClipOutput_(0, 0, Width, Height)
      
      DrawingFont(ListEx()\String\FontID)

      txtHeight = TextHeight_("X")
    
      ListEx()\Cursor\X         = String_(X, Y, Width, Height, ListEx()\String\Text, ListEx()\String\CursorPos, TextColor, BackColor, BorderColor, ListEx()\String\FontID)
      ListEx()\Cursor\Y         = Y + ((Height - txtHeight) / 2) 
      ListEx()\Cursor\ClipX     = X + Width - 1
      ListEx()\Cursor\Height    = txtHeight
      ListEx()\Cursor\BackColor = BackColor
      ListEx()\Cursor\Pos       = ListEx()\String\CursorPos
      
      UnclipOutput_()
      
      StopDrawing()
    EndIf
  
  EndProcedure  

  Procedure   Draw_(ScrollBar.i=#False) ; DPI
    Define.f colX, rowY, textY, textX, colW0, rowHeight, imgY, imgX, imgWidth, imgHeight
    Define.i r, Width, Height, textRows, maxHeight, OffsetY
    Define.i Flags, imgFlags, Align, Mark, Row
    Define.i FrontColor, BackColor, RowColor, FontID, RowFontID, Time
    Define.s Key$, Text$
    
    If ListEx()\Hide : ProcedureReturn #False : EndIf
  
    ;{ _____ ScrollBar _____
    CalcScrollBar_()

    Width  = ListEx()\Area\Width
    Height = ListEx()\Area\Height
    
    If ListEx()\HScroll\Hide
      ListEx()\Col\OffsetX = 0
    Else
      ListEx()\Col\OffsetX = ListEx()\HScroll\Pos
    EndIf   
    
    If ListEx()\VScroll\Hide
      ListEx()\Row\OffSetY = 0
    Else
      ListEx()\Row\OffSetY = ListEx()\VScroll\Pos
    EndIf   
    ;}

    colX = 0
    rowY = 0
    rowHeight = 0    
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      PushListPosition(ListEx()\Rows())
      PushListPosition(ListEx()\Cols())

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(0, 0, Width, Height, ListEx()\Color\Back)
      ;}
      
      ListEx()\Size\Cols = 0
      
      colX = ListEx()\Size\X - ListEx()\Col\OffsetX
      
      ClipOutput_(0, 0, Width, Height)
      
      ;{ _____ Header _____
      If ListEx()\Flags & #NoRowHeader

        ForEach ListEx()\Cols()
          
          ListEx()\Cols()\minWidth = 10
          
          If ListEx()\Cols()\Flags & #Hide Or ListEx()\Cols()\Width = 0 : Continue : EndIf
          
          ListEx()\Size\Cols + ListEx()\Cols()\Width 
          
        Next  
        
        rowY = ListEx()\Size\Y

      Else
        
        ForEach ListEx()\Cols()
          
          If ListEx()\Cols()\Flags & #Hide Or ListEx()\Cols()\Width = 0 : Continue : EndIf
          
          ListEx()\Size\Cols + ListEx()\Cols()\Width
         
          ListEx()\Cols()\minWidth = 0
          
          If ListEx()\Cols()\Header\FontID = #PB_Default
            DrawingFont(ListEx()\Header\FontID)
          Else
            DrawingFont(ListEx()\Cols()\Header\FontID)
          EndIf
          
          DrawingMode(#PB_2DDrawing_Default)
           
          If ListEx()\Cols()\Header\BackColor <> #PB_Default
            Box_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Header\Height, ListEx()\Cols()\Header\BackColor)
          Else
            Box_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Header\Height, ListEx()\Color\HeaderBack)
          EndIf
          
          DrawingMode(#PB_2DDrawing_Outlined)
          
          If ListIndex(ListEx()\Cols()) = ListSize(ListEx()\Cols()) - 1
            Box_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Header\Height + 1, ListEx()\Color\HeaderLine)
          Else  
            Box_(colX, rowY, ListEx()\Cols()\Width + 1, ListEx()\Header\Height + 1, ListEx()\Color\HeaderLine)
          EndIf
        
          If CurrentColumn_() = ListEx()\Sort\Column And ListEx()\Cols()\Header\Sort & #SortArrows
            HeaderArrow_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Header\Height, ListEx()\Cols()\Header\Direction) 
          EndIf
          
          If ListEx()\Cols()\Header\Flags & #Image ;{ Image
            
            imgFlags = ListEx()\Cols()\Header\Image\Flags
            
            If imgFlags & #Center
              imgX = (ListEx()\Cols()\Width - ListEx()\Cols()\Header\Image\Width) / 2
            ElseIf imgFlags & #Right
              imgX = ListEx()\Cols()\Width - ListEx()\Cols()\Header\Image\Width - 4
            Else 
              imgX = 4
            EndIf

            imgY  = (ListEx()\Header\Height - ListEx()\Cols()\Header\Image\Height) / 2 + 1

            DrawingMode(#PB_2DDrawing_AlphaBlend)
            
            If ListEx()\Cols()\Header\Image\ID
              DrawImage(ListEx()\Cols()\Header\Image\ID, dpiX(colX + imgX), dpiY(rowY + imgY), dpiX(ListEx()\Cols()\Header\Image\Width), dpiY(ListEx()\Cols()\Header\Image\Height)) 
            EndIf
            
            ListEx()\Cols()\minWidth = TextWidth_(ListEx()\Cols()\Header\Title) + ListEx()\Cols()\Header\Image\Width + 10
            ListEx()\Cols()\MaxWidth = TextWidth_(ListEx()\Cols()\Header\Title) + ListEx()\Cols()\Header\Image\Width + 4
            
          Else
            ListEx()\Cols()\minWidth = TextWidth_(ListEx()\Cols()\Header\Title) + 6
            ListEx()\Cols()\MaxWidth = TextWidth_(ListEx()\Cols()\Header\Title)
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
            
            textX = GetAlignOffset_(ListEx()\Cols()\Header\Title, ListEx()\Cols()\Width, Align)
            textY = (ListEx()\Header\Height - TextHeight_("Abc")) / 2 + 0.5
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(dpiX(colX + textX), dpiX(rowY + textY), ListEx()\Cols()\Header\Title, FrontColor)
          EndIf

          colX + ListEx()\Cols()\Width
          
        Next

        rowY = ListEx()\Size\Y + ListEx()\Header\Height

      EndIf ;}
      
      UnclipOutput_()
      
      DrawingFont(ListEx()\Row\FontID)
      FontID = ListEx()\Row\FontID
     
      ; _____ Rows _____
      
      ClipOutput_(0, ListEx()\Size\Y + ListEx()\Header\Height, Width, Height - ListEx()\Size\Y - ListEx()\Header\Height)
      
      rowY - ListEx()\Row\OffSetY
      
      ForEach ListEx()\Rows()
        
        If rowY + ListEx()\Rows()\Height < ListEx()\Header\Height
          OffsetY = rowY + ListEx()\Rows()\Height
          ListEx()\Row\Offset   = ListIndex(ListEx()\Rows()) + 1
          ListEx()\Row\ScrollUp = ListEx()\Rows()\Height - OffsetY
          rowY + ListEx()\Rows()\Height
          Continue
        EndIf   
        
        If ListEx()\Row\ScrollUp = 0
          ListEx()\Row\ScrollUp = ListEx()\Rows()\Height
        EndIf   
        
        If ListIndex(ListEx()\Rows()) = ListEx()\Row\Offset 
          ListEx()\Row\ScrollDown = ListEx()\Rows()\Height
        EndIf
      
        If ListEx()\Rows()\FontID
          FontID = ListEx()\Rows()\FontID
        Else
          FontID = ListEx()\Row\FontID
        EndIf
        
        RowFontID = FontID

        rowHeight + ListEx()\Rows()\Height
        
        colX = ListEx()\Size\X - ListEx()\Col\OffsetX
        
        DrawingMode(#PB_2DDrawing_Default)
        
        Row = ListIndex(ListEx()\Rows())

        ;{ Alternate Color
        If ListEx()\Color\AlternateRow <> #PB_Default
          If Mod(ListIndex(ListEx()\Rows()), 2)
            BackColor = ListEx()\Color\AlternateRow
          Else
            BackColor = ListEx()\Color\Back
          EndIf
        Else
          BackColor = ListEx()\Color\Back
        EndIf ;}

        ForEach ListEx()\Cols() ;{ Columns of current row

          If ListEx()\Cols()\Flags & #Hide Or ListEx()\Cols()\Width = 0 : Continue : EndIf

          Key$ = ListEx()\Cols()\Key
          If Key$ = "" : Key$ = Str(ListIndex(ListEx()\Cols())) : EndIf
          
          Flags = ListEx()\Rows()\Column(Key$)\Flags
          
          FontID = RowFontID
          
          If ListEx()\Cols()\FontID : FontID = ListEx()\Cols()\FontID : EndIf

          If CurrentColumn_() = 0 And ListEx()\Flags & #NumberedColumn ;{ Numbering column 0
            
            If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
            
            DrawingFont(FontID)
            
            Text$    = Str(ListIndex(ListEx()\Rows()) + 1)
            textX    = GetAlignOffset_(Text$, ListEx()\Cols()\Width, #Right)
            textY    = (ListEx()\Rows()\Height - TextHeight_("Abc")) / 2 + 1
            colW0    = ListEx()\Cols()\Width
            
            DrawingMode(#PB_2DDrawing_Default)
            Box_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Row\Height, ListEx()\Color\HeaderBack)
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(dpiX(colX + textX), dpiY(rowY + textY), Text$, ListEx()\Color\HeaderFront, ListEx()\Color\HeaderBack)
            
            DrawingMode(#PB_2DDrawing_Outlined)
            Box_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height + 1, ListEx()\Color\HeaderLine)
            
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
            
            ;{ Cell background
            DrawingMode(#PB_2DDrawing_Default)
            
            If ListEx()\Flags & #MultiSelect And ListEx()\MultiSelect = #True
              If ListEx()\Rows()\State & #Selected : BackColor = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10) : EndIf
            ElseIf ListEx()\Focus And ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
              BackColor = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10)
            ElseIf Flags & #CellBack
              BackColor = ListEx()\Rows()\Column(Key$)\Color\Back
            ElseIf ListEx()\Rows()\Color\Back <> #PB_Default
              BackColor = ListEx()\Rows()\Color\Back
            ElseIf ListEx()\Cols()\BackColor <> #PB_Default
              BackColor = ListEx()\Cols()\BackColor
            Else
              BackColor = ListEx()\Color\Back
            EndIf
            
            Box_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, BackColor) ; 
            ;}
            
            ListEx()\Cols()\X = colX
            
            If ListEx()\Cols()\Flags & #CheckBoxes                             ;{ CheckBox
              
              CheckBox_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, TextHeight_("X") - 3, BackColor, ListEx()\Rows()\Column(Key$)\State)

            ElseIf ListEx()\Flags & #CheckBoxes And CurrentColumn_() = ListEx()\Col\CheckBoxes

              CheckBox_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, TextHeight_("X") - 3, BackColor, ListEx()\Rows()\State)
              ;}
            ElseIf Flags & #Buttons Or Flags & #Strings Or Flags & #DateGadget Or Flags & #MarkDown ;{ Single cells

              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""
                
                If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
                
                DrawingFont(FontID)
                
                If Flags & #Buttons
                  Button_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\Value, #False, FontID)
                EndIf 
                
                textY = (ListEx()\Rows()\Height - TextHeight_("Abc")) / 2 + 1
                
                DrawingMode(#PB_2DDrawing_Transparent)
                
                textX = GetAlignOffset_(Text$, ListEx()\Cols()\Width, ListEx()\Cols()\Align)

                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsCondition_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
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
                
                CompilerIf Defined(MarkDown, #PB_Module)
                  
                  If Flags & #MarkDown And ListEx()\MarkDown ; Markdown Text
                    MarkDown::Text(dpiX(colX + textX), dpiY(rowY + textY), Text$, FrontColor)
                  Else
                    DrawText(dpiX(colX + textX), dpiY(rowY + textY), Text$, FrontColor)
                  EndIf  
                  
                CompilerElse
                  
                  DrawText(dpiX(colX + textX), dpiY(rowY + textY), Text$, FrontColor)
                  
                CompilerEndIf
                
                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
                
              EndIf
              ;}
            ElseIf ListEx()\Cols()\Flags & #Buttons                            ;{ Button
              
              If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf

              Button_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\Value, #False, FontID)
              
              If Flags & #Image ;{ Image
                
                imgFlags = ListEx()\Rows()\Column(Key$)\Image\Flags
                
                If imgFlags & #Center
                  imgX  = (ListEx()\Cols()\Width - ListEx()\Rows()\Column(Key$)\Image\Width) / 2
                ElseIf imgFlags & #Right
                  imgX  = ListEx()\Cols()\Width  - ListEx()\Rows()\Column(Key$)\Image\Width - 4
                Else 
                  imgX = 4
                EndIf
                
                imgWidth  = ListEx()\Rows()\Column(Key$)\Image\Width
                imgHeight = ListEx()\Rows()\Column(Key$)\Image\Height
                imgY      = (ListEx()\Rows()\Height - ListEx()\Rows()\Column(Key$)\Image\Height) / 2 + 1
                
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                If ListEx()\Rows()\Column(Key$)\Image\ID
                  DrawImage(ListEx()\Rows()\Column(Key$)\Image\ID, dpiX(colX + imgX), dpiY(rowY + imgY), dpiX(imgWidth), dpiY(imgHeight)) 
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Image
                
                imgFlags = ListEx()\Cols()\Image\Flags
                
                If imgFlags & #Center
                  imgX  = (ListEx()\Cols()\Width - ListEx()\Cols()\Image\Width) / 2
                ElseIf imgFlags & #Right
                  imgX  = ListEx()\Cols()\Width  -ListEx()\Cols()\Image\Width - 4
                Else 
                  imgX = 4
                EndIf
                
                imgWidth  = ListEx()\Cols()\Image\Width
                imgHeight = ListEx()\Cols()\Image\Height
                imgY      = (ListEx()\Rows()\Height - ListEx()\Cols()\Image\Height) / 2 + 1
                
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                If ListEx()\Cols()\Image\ID
                  DrawImage(ListEx()\Cols()\Image\ID, dpiX(colX + imgX), dpiY(rowY + imgY), dpiX(imgWidth), dpiY(imgHeight))
                EndIf  
                ;}
              EndIf

              If Flags & #CellFont : FontID = RowFontID : EndIf
              ;}
            ElseIf ListEx()\Cols()\Flags & #ProgressBar                        ;  ProgressBar
              CompilerIf #Enable_ProgressBar
                
                If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
              
                DrawProgressBar_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\State, ListEx()\Rows()\Column(Key$)\Value, FrontColor, ListEx()\Cols()\Align, FontID)

                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
                
              CompilerEndIf 
            ElseIf Flags & #Image Or ListEx()\Cols()\Flags & #Image            ;{ Image

              If Flags & #Image
                
                imgFlags = ListEx()\Rows()\Column(Key$)\Image\Flags
                
                If imgFlags & #Center
                  imgX  = (ListEx()\Cols()\Width - ListEx()\Rows()\Column(Key$)\Image\Width) / 2
                ElseIf imgFlags & #Right
                  imgX  = ListEx()\Cols()\Width  - ListEx()\Rows()\Column(Key$)\Image\Width - 4
                Else 
                  imgX = 4
                EndIf
                
                imgWidth  = ListEx()\Rows()\Column(Key$)\Image\Width
                imgHeight = ListEx()\Rows()\Column(Key$)\Image\Height
                imgY      = (ListEx()\Rows()\Height - ListEx()\Rows()\Column(Key$)\Image\Height) / 2 + 1
                
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                If ListEx()\Rows()\Column(Key$)\Image\ID
                  DrawImage(ListEx()\Rows()\Column(Key$)\Image\ID, dpiX(colX + imgX), dpiY(rowY + imgY), dpiX(imgWidth), dpiY(imgHeight)) 
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Image
                
                imgFlags = ListEx()\Cols()\Image\Flags
                
                If imgFlags & #Center
                  imgX  = (ListEx()\Cols()\Width - ListEx()\Cols()\Image\Width) / 2
                ElseIf imgFlags & #Right
                  imgX  = ListEx()\Cols()\Width  - ListEx()\Cols()\Image\Width - 4
                Else 
                  imgX = 4
                EndIf
                
                imgWidth  = ListEx()\Cols()\Image\Width
                imgHeight = ListEx()\Cols()\Image\Height
                imgY      = (ListEx()\Rows()\Height - ListEx()\Cols()\Image\Height) / 2 + 1
                
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                If ListEx()\Cols()\Image\ID
                  DrawImage(ListEx()\Cols()\Image\ID, dpiX(colX + imgX), dpiY(rowY + imgY), dpiX(imgWidth), dpiY(imgHeight)) 
                EndIf
              EndIf

              Text$ = ListEx()\Rows()\Column(Key$)\Value 
              If Text$ <> "" ;{ Text & Image
                
                If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
                
                DrawingFont(FontID)

                If imgFlags & #Center
                  textX = GetAlignOffset_(Text$, ListEx()\Cols()\Width, #Center)
                ElseIf imgFlags & #Right
                  textX = GetAlignOffset_(Text$, ListEx()\Cols()\Width, #Left)
                Else 
                  textX = imgWidth + 8
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
                      Select IsCondition_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
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
                
                textRows = CountString(Text$, #LF$) + 1
                textY    = (ListEx()\Rows()\Height - (TextHeight_("Abc") * textRows)) / 2 + 1
                
                If textRows > 1
                  For r=1 To textRows
                    DrawText(dpiX(colX + textX), dpiY(rowY + textY), StringField(Text$, r, #LF$), FrontColor)
                    textY + TextHeight_("Abc")
                  Next
                Else
                  DrawText(dpiX(colX + textX), dpiX(rowY + textY), Text$, FrontColor)
                EndIf
              
                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf
                ;}
              EndIf
              ;}
            Else                                                               ;{ Text
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""

                If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
                
                DrawingFont(FontID)

                DrawingMode(#PB_2DDrawing_Transparent)
                
                textX = GetAlignOffset_(Text$, ListEx()\Cols()\Width, ListEx()\Cols()\Align)

                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsCondition_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
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
                
                textRows = CountString(Text$, #LF$) + 1
                textY = (ListEx()\Rows()\Height - (TextHeight_("X") * textRows)) / 2 + 1
                
                CompilerIf #Enable_FormatContent
                  
                  If ListEx()\Cols()\Format
                    Text$ = FormatContent(Text$, ListEx()\Cols()\Format, ListEx()\Cols()\Flags)
                  EndIf  
                  
                CompilerEndIf
                
                CompilerIf Defined(MarkDown, #PB_Module)
                  
                  If ListEx()\Cols()\Flags & #MarkDown And ListEx()\MarkDown ;{ Markdown Text
                    MarkDown::Text(dpiX(colX + textX), dpiY(rowY + textY), Text$, FrontColor)
                    ;}
                  Else ;{ Normal text
                    
                    If textRows > 1
                    
                      For r=1 To textRows
                        DrawText(dpiX(colX + textX), dpiY(rowY + textY), StringField(Text$, r, #LF$), FrontColor)
                        textY + TextHeight_("Abc")
                      Next
                      
                    Else
                      DrawText(dpiX(colX + textX), dpiY(rowY + textY), Text$, FrontColor)
                    EndIf
                    ;}
                  EndIf  

                CompilerElse

                  If textRows > 1
                    
                    For r=1 To textRows
                      DrawText(dpiX(colX + textX), dpiY(rowY + textY), StringField(Text$, r, #LF$), FrontColor)
                      textY + TextHeight_("X")
                    Next
                    
                  Else
                    DrawText(dpiX(colX + textX), dpiY(rowY + textY), Text$, FrontColor)
                  EndIf
                  
                CompilerEndIf
                
                If Flags & #CellFont : DrawingFont(RowFontID) : EndIf

              EndIf
              ;}  
            EndIf
          
            If ListEx()\Flags & #GridLines ;{ Draw Gridlines
              
              DrawingMode(#PB_2DDrawing_Outlined)
              
              If ListIndex(ListEx()\Cols()) = ListSize(ListEx()\Cols()) - 1
                Box_(colX, rowY,ListEx()\Cols()\Width, ListEx()\Rows()\Height + 1, ListEx()\Color\Line)
              Else   
                Box_(colX, rowY, ListEx()\Cols()\Width + 1, ListEx()\Rows()\Height + 1, ListEx()\Color\Line)
              EndIf 
              ;}
            EndIf
            
          EndIf
          
          colX + ListEx()\Cols()\Width
          ;}
        Next
        
        ListEx()\Rows()\Y = rowY
        
        If rowY > ListEx()\Area\Y + ListEx()\Area\Height : Break : EndIf 
        
        rowY + ListEx()\Rows()\Height

      Next
      
      colX = ListEx()\Size\X - ListEx()\Col\OffsetX
      
      If ListEx()\Flags & #NoRowHeader = #False
        Line(colX, dpiY(ListEx()\Size\Y + ListEx()\Header\Height), dpiX(ListEx()\Size\Cols), dpiY(1), ListEx()\Color\HeaderLine)
      EndIf
    
      DrawingMode(#PB_2DDrawing_Default)
      Box_(ListEx()\Size\Cols, 0, Width - ListEx()\Size\Cols, Height, ListEx()\Color\Back) 
      
      If ListEx()\Flags & #NumberedColumn
        Line(dpiX(colX + colW0 - 1), dpiY(ListEx()\Header\Height), dpiY(1), dpiY(rowHeight + 1), ListEx()\Color\Back)
      EndIf
      
      UnclipOutput_()
      
      PopListPosition(ListEx()\Cols())
      PopListPosition(ListEx()\Rows())

      StopDrawing()
    EndIf  
    
    If ListEx()\String\Flag   : DrawString_()   : EndIf
    If ListEx()\ComboBox\Flag : DrawComboBox_() : EndIf
    
    DrawScrollBar_(ScrollBar)
    
    ;{ _____ Border _____
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))

      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(0, 0, GadgetWidth(ListEx()\CanvasNum), GadgetHeight(ListEx()\CanvasNum), ListEx()\Color\HeaderLine) ; ListEx()\Color\HeaderLine
      
      StopDrawing()
    EndIf
    ;}
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - ComboBox
  ;- ========================================================================== 
  
  Procedure   CalcListViewRowHeight() ; DPI
    
    If StartDrawing(CanvasOutput(ListEx()\ListView\Num))
      DrawingFont(ListEx()\FontID)
      ListEx()\ListView\RowHeight = TextHeight_("X") + 4
      StopDrawing()
    EndIf
    
  EndProcedure 
  
  Procedure   OpenListView_()
    Define.i X, Y, PageRows, RowsHeight, Width, Height, SubItems
    
    ListEx()\Cursor\Pause = #True
    
    X      = GadgetX(ListEx()\CanvasNum, #PB_Gadget_ScreenCoordinate) + ListEx()\ComboBox\X
    Y      = GadgetY(ListEx()\CanvasNum, #PB_Gadget_ScreenCoordinate) + ListEx()\ComboBox\Y
    Width  = ListEx()\ComboBox\Width
    Height = ListEx()\ListView\Height
    
    ForEach ListEx()\ListView\Item()
      If ListEx()\ListView\Item()\String = ListEx()\ComboBox\Text
        ListEx()\ListView\State = ListIndex(ListEx()\ListView\Item())
        Break
      EndIf   
    Next
    
    CalcListViewRowHeight()

    RowsHeight = ListSize(ListEx()\ListView\Item()) * ListEx()\ListView\RowHeight + 2
    If RowsHeight = 2 : RowsHeight = ListEx()\ListView\RowHeight : EndIf
    
    If RowsHeight < Height : Height = RowsHeight : EndIf

    SetGadgetData(ListEx()\ListView\Num, ListEx()\CanvasNum)
    
    If IsWindow(ListEx()\ListView\Window)
      ResizeWindow(ListEx()\ListView\Window, X, Y + ListEx()\ComboBox\Height, Width, Height)
      ResizeGadget(ListEx()\ListView\Num, 0, 0, Width, Height)
    EndIf
    
    HideWindow(ListEx()\ListView\Window, #False)
    
    SetActiveGadget(ListEx()\ListView\Num)
    
    ListEx()\ListView\Focus    = #PB_Default
    ListEx()\ListView\Hide     = #False
    ListEx()\ListView\Offset   = 0
    ListEx()\ListView\State    = #PB_Default
    ListEx()\LScroll\CursorPos = #PB_Default
    ListEx()\LScroll\Pos       = 0
    
    If RowsHeight > Height

      ListEx()\LScroll\Hide = #False
      
      PageRows = Height / ListEx()\ListView\RowHeight

      ListEx()\LScroll\Minimum    = 0
      ListEx()\LScroll\Maximum    = ListSize(ListEx()\ListView\Item())
      ListEx()\LScroll\PageLength = PageRows

      CalcScrollRange_()
      
    Else
      ListEx()\LScroll\Hide = #True
    EndIf  
    
    DrawListView_()
    
  EndProcedure
  
  Procedure   CloseListView_()
    
    HideWindow(ListEx()\ListView\Window, #True)
    
    ListEx()\ListView\Hide = #True
    ListEx()\LScroll\Hide  = #True
    ListEx()\Cursor\Pause  = #False
    
    Draw_()
    
  EndProcedure  
  

  ;- ==========================================================================
  ;-   Module - Events
  ;- ==========================================================================   
  
  Procedure   UpdateEventData_(Type.i, Row.i=#NotValid, Column.i=#NotValid, Value.s="", State.i=#NotValid, ID.s="")
    
    ListEx()\Event\Type   = Type
    ListEx()\Event\Row    = Row
    ListEx()\Event\Column = Column
    ListEx()\Event\Value  = Value
    ListEx()\Event\State  = State
    ListEx()\Event\ID     = ID
    
  EndProcedure    
  
  Procedure.i ManageEditGadgets_(Row.i, Column.i)
    Define.f X, Y
    Define.i Date
    Define.s Value$, Key$, Mask$
    
    If ListEx()\String\Flag   = #True : ProcedureReturn #False : EndIf
    If ListEx()\ComboBox\Flag = #True : ProcedureReturn #False : EndIf
    If ListEx()\Date\Flag     = #True : ProcedureReturn #False : EndIf
    
    If Row < 0 Or Column < 0 : ProcedureReturn #False : EndIf 
    
    If SelectElement(ListEx()\Rows(), Row)
      If SelectElement(ListEx()\Cols(), Column)
        
        ListEx()\Row\Current = Row
        ListEx()\Col\Current = Column
        
        Y = ListEx()\Rows()\Y
        X = ListEx()\Cols()\X
        
        Key$ = ListEx()\Cols()\Key
        
        If ListEx()\Rows()\Column(Key$)\Flags & #LockCell : ProcedureReturn #False : EndIf
        
        If ListEx()\Cols()\Flags & #Strings Or ListEx()\Rows()\Column(Key$)\Flags & #Strings    ;{ String Gadget
  
          If ListEx()\Editable
            
            ListEx()\Cursor\Pause = #False
            
            If ListEx()\Cols()\FontID
              ListEx()\String\FontID = ListEx()\Cols()\FontID
            Else
              ListEx()\String\FontID = ListEx()\Row\FontID
            EndIf  
            
            ListEx()\String\Row     = Row
            ListEx()\String\Col     = Column
            ListEx()\String\X       = X
            ListEx()\String\Y       = Y
            ListEx()\String\Width   = ListEx()\Cols()\Width
            ListEx()\String\Height  = ListEx()\Rows()\Height
            ListEx()\String\Label   = ListEx()\Cols()\Key
            ListEx()\String\Text    = ListEx()\Rows()\Column(Key$)\Value
            ListEx()\String\Flag    = #True
            ListEx()\String\Wrong   = #False
            
            ListEx()\String\CursorPos = Len(ListEx()\String\Text)
            
            BindTabulator_(#False)
            
            If ListEx()\Cols()\Flags & #StartSelected Or ListEx()\Rows()\Column(Key$)\Flags & #StartSelected
              ListEx()\Selection\Pos1 = 0
              ListEx()\Selection\Pos2 = Len(ListEx()\String\Text)
              ListEx()\Selection\Flag = #TextSelected
            EndIf
          
            DrawString_()

          EndIf
          ;}
        ElseIf ListEx()\Cols()\Flags & #ComboBoxes Or ListEx()\Rows()\Column(Key$)\Flags & #ComboBoxes ;{ ComboCoxes
 
          If ListEx()\Editable
            
            ListEx()\Cursor\Pause = #False

            If ListEx()\Cols()\FontID
              ListEx()\ComboBox\FontID = ListEx()\Cols()\FontID
            Else
              ListEx()\ComboBox\FontID = ListEx()\Row\FontID
            EndIf 
            
            ListEx()\ComboBox\Row     = Row
            ListEx()\ComboBox\Col     = Column
            ListEx()\ComboBox\X       = X
            ListEx()\ComboBox\Y       = Y
            ListEx()\ComboBox\Width   = ListEx()\Cols()\Width
            ListEx()\ComboBox\Height  = ListEx()\Rows()\Height
            ListEx()\ComboBox\Label   = ListEx()\Cols()\Key
            ListEx()\ComboBox\Text    = ListEx()\Rows()\Column(Key$)\Value
            ListEx()\ComboBox\Flag    = #True
            
            If ListEx()\Cols()\Flags & #StartSelected Or ListEx()\Rows()\Column(Key$)\Flags & #StartSelected
              ListEx()\Selection\Pos1 = 0
              ListEx()\Selection\Pos2 = Len(ListEx()\String\Text)
              ListEx()\Selection\Flag = #TextSelected
            EndIf
            
            ;{ Load Items
            ClearList(ListEx()\ListView\Item())
            
            If FindMapElement(ListEx()\ComboBox\Column(), ListEx()\Cols()\Key)
              
              ForEach ListEx()\ComboBox\Column()\Items()
                If AddElement(ListEx()\ListView\Item())
                  ListEx()\ListView\Item()\String = ListEx()\ComboBox\Column()\Items()\String
                  ListEx()\ListView\Item()\Color  = ListEx()\ComboBox\Column()\Items()\Color
                EndIf  
              Next
              
            EndIf  
            ;}

            ListEx()\ComboBox\CursorPos = Len(ListEx()\ComboBox\Text)
            
            BindTabulator_(#False)
            
            DrawComboBox_()
            
          EndIf  
          ;}
        ElseIf ListEx()\Cols()\Flags & #DateGadget Or ListEx()\Rows()\Column(Key$)\Flags & #DateGadget ;{ DateGadget

          If IsGadget(ListEx()\DateNum)
            
            If ListEx()\Editable
              
              Mask$ = ListEx()\Date\Mask
              
              If FindMapElement(ListEx()\Date\Column(), Key$)
                CompilerIf Defined(DateEx, #PB_Module)
                  If ListEx()\Date\Column()\Min  : DateEx::SetAttribute(ListEx()\DateNum, DateEx::#Minimum, ListEx()\Date\Column()\Min) : EndIf
                  If ListEx()\Date\Column()\Max  : DateEx::SetAttribute(ListEx()\DateNum, DateEx::#Maximum, ListEx()\Date\Column()\Max) : EndIf
                CompilerElse  
                  If ListEx()\Date\Column()\Min  : SetGadgetAttribute(ListEx()\DateNum, #PB_Date_Minimum, ListEx()\Date\Column()\Min) : EndIf
                  If ListEx()\Date\Column()\Max  : SetGadgetAttribute(ListEx()\DateNum, #PB_Date_Maximum, ListEx()\Date\Column()\Max) : EndIf
                CompilerEndIf
                If ListEx()\Date\Column()\Mask : Mask$ = ListEx()\Date\Column()\Mask : EndIf
              EndIf

              ResizeGadget(ListEx()\DateNum, X, Y, ListEx()\Cols()\Width - 1, ListEx()\Rows()\Height)
              
              CompilerIf Defined(DateEx, #PB_Module)
                DateEx::SetText(ListEx()\DateNum, Mask$)
              CompilerElse    
                SetGadgetText(ListEx()\DateNum, Mask$)
              CompilerEndIf
              
              Value$ = ListEx()\Rows()\Column(Key$)\Value
              If Value$
                Date = ParseDate(Mask$, Value$)
                CompilerIf Defined(DateEx, #PB_Module)
                  If Date > 0 : DateEx::SetState(ListEx()\DateNum, Date) : EndIf
                CompilerElse   
                  If Date > 0 : SetGadgetState(ListEx()\DateNum, Date) : EndIf
                CompilerEndIf
              EndIf

              ListEx()\Date\Row     = Row
              ListEx()\Date\Col     = Column
              ListEx()\Date\X       = X
              ListEx()\Date\Y       = Y
              ListEx()\Date\Width   = ListEx()\Cols()\Width
              ListEx()\Date\Height  = ListEx()\Rows()\Height
              ListEx()\Date\Label   = ListEx()\Cols()\Key
              ListEx()\Date\Flag    = #True
            
              BindShortcuts_(#True)
              
              CompilerIf Defined(DateEx, #PB_Module)
                DateEx::Hide(ListEx()\DateNum, #False)
              CompilerElse  
                HideGadget(ListEx()\DateNum, #False)
              CompilerEndIf
              
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
  

  
  Procedure.i NextEditColumn_(Column.i)
    
    If Column = #PB_Default
      
      If FirstElement(ListEx()\Cols())
        Repeat
          If ListEx()\Cols()\Flags & #Strings
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #ComboBoxes
            ProcedureReturn ListIndex(ListEx()\Cols())
          ElseIf ListEx()\Cols()\Flags & #DateGadget
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
          ElseIf ListEx()\Cols()\Flags & #DateGadget
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
          ElseIf ListEx()\Cols()\Flags & #DateGadget
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
          ElseIf ListEx()\Cols()\Flags & #DateGadget
            ProcedureReturn ListIndex(ListEx()\Cols())
          EndIf
        Wend
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  ;- ---------------------
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ListEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ListEx()\Row\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf  
        
        ListEx()\Color\Focus        = ModuleEx::ThemeGUI\Focus\BackColor
        ListEx()\Color\FocusText    = ModuleEx::ThemeGUI\Focus\FrontColor
        ListEx()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
        ListEx()\Color\Back         = ModuleEx::ThemeGUI\BackColor
        ListEx()\Color\Line         = ModuleEx::ThemeGUI\LineColor
        ListEx()\Color\ScrollBar    = ModuleEx::ThemeGUI\ScrollbarColor
        ListEx()\Color\AlternateRow = ModuleEx::ThemeGUI\RowColor
        ListEx()\Color\HeaderFront  = ModuleEx::ThemeGUI\Header\FrontColor
        ListEx()\Color\HeaderBack   = ModuleEx::ThemeGUI\Header\BackColor
        ListEx()\Color\HeaderLine   = ModuleEx::ThemeGUI\Header\BorderColor
        ListEx()\Color\ProgressBar  = ModuleEx::ThemeGUI\Progress\FrontColor
        ListEx()\Color\Gradient     = ModuleEx::ThemeGUI\Progress\GradientColor
        ListEx()\Color\ButtonFront  = ModuleEx::ThemeGUI\Button\FrontColor
        ListEx()\Color\ButtonBack   = ModuleEx::ThemeGUI\Button\BackColor
        ListEx()\Color\ButtonBorder = ModuleEx::ThemeGUI\Button\BorderColor
        ListEx()\Color\EditFront    = ModuleEx::ThemeGUI\FrontColor
        ListEx()\Color\EditBack     = ModuleEx::ThemeGUI\BackColor
        
        ListEx()\ScrollBar\Color\Front        = ModuleEx::ThemeGUI\FrontColor
  			ListEx()\ScrollBar\Color\Back         = ModuleEx::ThemeGUI\BackColor
  			ListEx()\ScrollBar\Color\Border       = ModuleEx::ThemeGUI\BorderColor
  			ListEx()\ScrollBar\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
  			ListEx()\ScrollBar\Color\Focus        = ModuleEx::ThemeGUI\Focus\BackColor
        ListEx()\ScrollBar\Color\Button       = ModuleEx::ThemeGUI\Button\BackColor
        ListEx()\ScrollBar\Color\ScrollBar    = ModuleEx::ThemeGUI\ScrollbarColor
        
        Draw_(#Vertical|#Horizontal)
      Next
      
    EndProcedure
    
  CompilerEndIf  
  
  
  Procedure _TimerHandler()
    
    LockMutex(Mutex)
    
    ForEach ListEx()
      
      ;{ ----- Cursor -----
      If ListEx()\Cursor\Pause = #False
        
        ListEx()\Cursor\Delay + 100
        If ListEx()\Cursor\Delay >= ListEx()\Cursor\Frequency
          ListEx()\Cursor\Delay = 0
        Else
          Continue
        EndIf   
        
        If ListEx()\Cursor\X >= ListEx()\Cursor\ClipX : Continue : EndIf
        
        ;{ Draw Cursor
        If ListEx()\String\Flag Or ListEx()\ComboBox\Flag

          ListEx()\Cursor\State ! #True
        
          If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
            
            DrawingMode(#PB_2DDrawing_Default)
            
            If ListEx()\Cursor\Pause
              
              Line(dpiX(ListEx()\Cursor\X), dpiY(ListEx()\Cursor\Y), dpiX(1), dpiY(ListEx()\Cursor\Height), ListEx()\Cursor\BackColor)
              
            Else
              
              If ListEx()\Cursor\State
                Line(dpiX(ListEx()\Cursor\X), dpiY(ListEx()\Cursor\Y), dpiX(1), dpiY(ListEx()\Cursor\Height), $000000)
              Else
                Line(dpiX(ListEx()\Cursor\X), dpiY(ListEx()\Cursor\Y), dpiX(1), dpiY(ListEx()\Cursor\Height), ListEx()\Cursor\BackColor)
              EndIf
              
            EndIf
            
            StopDrawing()
          EndIf

        EndIf ;}
        
      EndIf ;}
      
      ;{ ----- AutoScroll -----
      If ListEx()\HScroll\Timer ;{ Horizontal Scrollbar
        
        If ListEx()\HScroll\Delay
          ListEx()\HScroll\Delay - 1
          Continue
        EndIf  
        
        Select ListEx()\HScroll\Timer
          Case #Scrollbar_Left
            SetThumbPosX_(ListEx()\HScroll\Pos - 1)
            Draw_(#Horizontal)
          Case #Scrollbar_Right
            SetThumbPosX_(ListEx()\HScroll\Pos + 1)
            Draw_(#Horizontal)
        EndSelect

  			;}
      EndIf   
      
      If ListEx()\VScroll\Timer ;{ Vertical Scrollbar
        
        If ListEx()\VScroll\Delay
          ListEx()\VScroll\Delay - 1
          Continue
        EndIf  
        
        Select ListEx()\VScroll\Timer
          Case #Scrollbar_Up
            SetThumbPosY_(ListEx()\VScroll\Pos - 1)
            Draw_(#Vertical)
          Case #Scrollbar_Down
            SetThumbPosY_(ListEx()\VScroll\Pos + 1)
            Draw_(#Vertical)
  			EndSelect
  			;}
      EndIf   
      ;}
      
    Next  
    
    UnlockMutex(Mutex)
    
  EndProcedure
  
  
  Procedure _ListViewHandler()
    Define.i GNum, X, Y, Delta, Backwards, Forwards, Thumb, CursorPos
    Define.i ComboExNum = EventGadget()
    
    GNum = GetGadgetData(ComboExNum)
    If FindMapElement(ListEx(), Str(GNum))

      If ComboExNum = ListEx()\ListView\Num 
        
        X = DesktopUnscaledX(GetGadgetAttribute(ComboExNum, #PB_Canvas_MouseX))
        Y = DesktopUnscaledY(GetGadgetAttribute(ComboExNum, #PB_Canvas_MouseY))

        Select EventType()
          Case #PB_EventType_LeftButtonDown ;{ Left Button Down
            
    			  If ListEx()\LScroll\Hide = #False ;{ ListView Scrollbar
    			    
    			    If X > ListEx()\LScroll\X And X < ListEx()\LScroll\X + ListEx()\LScroll\Width
      			    If Y > ListEx()\LScroll\Y And Y < ListEx()\LScroll\Y + ListEx()\LScroll\Height
    			    
          			  ListEx()\LScroll\CursorPos = #PB_Default
          			  
          			  If ListEx()\LScroll\Focus
          			    
          			    If Y > ListEx()\LScroll\Buttons\bY And Y < ListEx()\LScroll\Buttons\bY + ListEx()\LScroll\Buttons\Height
          
          			      If ListEx()\LScroll\Buttons\bState <> #Click
          			        ; --- Backwards Button ---
            			      ListEx()\LScroll\Delay = ListEx()\Scrollbar\TimerDelay
            			      ListEx()\LScroll\Timer = #Scrollbar_Up
            			      ListEx()\LScroll\Buttons\bState = #Click
            			      DrawListView_()
            			    EndIf
            			    
          			    ElseIf Y > ListEx()\LScroll\Buttons\fY And Y < ListEx()\LScroll\Buttons\fY + ListEx()\LScroll\Buttons\Height
          			      
          			      ; --- Forwards Button ---
            			    If ListEx()\LScroll\Buttons\fState <> #Click
            			      ListEx()\LScroll\Delay = ListEx()\Scrollbar\TimerDelay
            			      ListEx()\LScroll\Timer = #Scrollbar_Down
            			      ListEx()\LScroll\Buttons\fState = #Click
            			      DrawListView_()
            			    EndIf
          			      
          			    ElseIf  Y > ListEx()\LScroll\Thumb\Y And Y < ListEx()\LScroll\Thumb\Y + ListEx()\LScroll\Thumb\Height
          			      
          			      ; --- Thumb Button ---
            			    If ListEx()\LScroll\Thumb\State <> #Click
            			      ListEx()\LScroll\Thumb\State = #Click
            			      ListEx()\LScroll\CursorPos = Y
            			      DrawListView_()
            			    EndIf
          			      
          			    EndIf  
          
          			  EndIf
          			  
          			  ProcedureReturn #True
          			EndIf
          		EndIf
          		;}
      			EndIf  

            ForEach ListEx()\ListView\Item()
              If Y >= ListEx()\ListView\Item()\Y And Y <= ListEx()\ListView\Item()\Y + ListEx()\ListView\RowHeight
                ListEx()\ListView\State = ListIndex(ListEx()\ListView\Item())
                DrawListView_()
                ProcedureReturn #True
              EndIf
            Next 
            ;}
          Case #PB_EventType_LeftButtonUp   ;{ Left Button Up

            If ListEx()\LScroll\Hide = #False ;{ ListView Scrollbar
              
              If X > ListEx()\LScroll\X And X < ListEx()\LScroll\X + ListEx()\LScroll\Width
      			    If Y > ListEx()\LScroll\Y And Y < ListEx()\LScroll\Y + ListEx()\LScroll\Height
              
          			  ListEx()\LScroll\CursorPos = #PB_Default
          			  ListEx()\LScroll\Timer     = #False
          			  
          			  If ListEx()\LScroll\Focus
          			    
            			  If Y > ListEx()\LScroll\Buttons\bY And  Y < ListEx()\LScroll\Buttons\bY + ListEx()\LScroll\Buttons\Height
            			    
            			    ; --- Backwards Button ---
            			    SetThumbPosL_(ListEx()\LScroll\Pos - 1)
                      DrawListView_()
        
            			  ElseIf Y > ListEx()\LScroll\Buttons\fY And  Y < ListEx()\LScroll\Buttons\fY + ListEx()\LScroll\Buttons\Height
            			    
            			    ; --- Forwards Button ---
            			    SetThumbPosL_(ListEx()\LScroll\Pos + 1)
            			    DrawListView_()
           
            			  ElseIf Y > ListEx()\LScroll\Area\Y And Y < ListEx()\LScroll\Thumb\Y
            			    
            			    ; --- Page up ---
            			    SetThumbPosL_(ListEx()\LScroll\Pos - ListEx()\LScroll\PageLength)
            			    DrawListView_()
        
            			  ElseIf Y > ListEx()\LScroll\Thumb\Y + ListEx()\LScroll\Thumb\Height And Y < ListEx()\LScroll\Area\Y + ListEx()\LScroll\Area\Height
            			    
            			    ; --- Page down ---
            			    SetThumbPosL_(ListEx()\LScroll\Pos + ListEx()\LScroll\PageLength)
            			    DrawListView_()
            			   
            			  EndIf
              			
            			EndIf 
            			
            			ProcedureReturn #True
            		EndIf
            	EndIf
            	;}
        		EndIf	
          	
            ForEach ListEx()\ListView\Item()
              If Y >= ListEx()\ListView\Item()\Y And Y <= ListEx()\ListView\Item()\Y + ListEx()\ListView\RowHeight
                If ListEx()\ListView\State <> ListIndex(ListEx()\ListView\Item())
                  ListEx()\ListView\State = #PB_Default
                  ProcedureReturn  #False
                EndIf
                ListEx()\ComboBox\Text      = ListEx()\ListView\Item()\String
                ListEx()\ComboBox\CursorPos = Len(ListEx()\ComboBox\Text)
                ListEx()\ListView\State = ListIndex(ListEx()\ListView\Item())
                DrawListView_()
                CloseListView_()
                PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Change, ListEx()\ListView\State)
                PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Change, ListEx()\ListView\State)
                ProcedureReturn #True
              EndIf
            Next 
            ;}
          Case #PB_EventType_MouseMove      ;{ Mouse Move
 
    			  If ListEx()\LScroll\Hide = #False ;{ ListView Scrollbar
    			    
      			  ListEx()\LScroll\Focus = #False
      			  
      			  Backwards = ListEx()\LScroll\Buttons\bState
      			  Forwards  = ListEx()\LScroll\Buttons\fState
      			  Thumb     = ListEx()\LScroll\Thumb\State
      			  
      			  If X > ListEx()\LScroll\X And X < ListEx()\LScroll\X + ListEx()\LScroll\Width
      			    If Y > ListEx()\LScroll\Y And Y < ListEx()\LScroll\Y + ListEx()\LScroll\Height
                  
      			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
      			      
      			      ; --- Focus Scrollbar ---  
      			      ListEx()\LScroll\Buttons\bState = #Focus
      			      ListEx()\LScroll\Buttons\fState = #Focus
      			      ListEx()\LScroll\Thumb\State    = #Focus
      			      
      			      ; --- Hover Buttons & Thumb ---
      			      If Y > ListEx()\LScroll\Buttons\bY And Y < ListEx()\LScroll\Buttons\bY + ListEx()\LScroll\Buttons\Height
      			        
      			        ListEx()\LScroll\Buttons\bState = #Hover
      			        
      			      ElseIf Y > ListEx()\LScroll\Buttons\fY And Y < ListEx()\LScroll\Buttons\fY + ListEx()\LScroll\Buttons\Height
      			        
      			        ListEx()\LScroll\Buttons\fState = #Hover
      
      			      ElseIf Y > ListEx()\LScroll\Thumb\Y And Y < ListEx()\LScroll\Thumb\Y + ListEx()\LScroll\Thumb\Height
      			        
      			        ListEx()\LScroll\Thumb\State = #Hover
      			        
      			        ;{ --- Move thumb with cursor 
      			        If ListEx()\LScroll\CursorPos <> #PB_Default
      			          
      			          CursorPos = ListEx()\LScroll\Pos
      			          
        			        ListEx()\LScroll\Pos       = GetThumbPosY_(Y)
        			        ListEx()\LScroll\CursorPos = Y
        			        
        			        If CursorPos <> ListEx()\LScroll\Pos 
        			          DrawListView_()
        			        EndIf
        			        
        			      EndIf ;}
      
        			    EndIf   
        			    
        			    If Backwards <> ListEx()\LScroll\Buttons\bState : DrawScrollButton_(#ListView, #ListView_Up)   : EndIf 
                  If Forwards  <> ListEx()\LScroll\Buttons\fState : DrawScrollButton_(#ListView, #ListView_Down) : EndIf 
                  If Thumb     <> ListEx()\LScroll\Thumb\State    : DrawThumb_(#ListView) : EndIf 
        			    
                  ListEx()\LScroll\Focus = #True
                  
                  ProcedureReturn #True
          			EndIf
          		EndIf
    		
          		If Not ListEx()\LScroll\Focus
                ListEx()\LScroll\Buttons\bState = #False
                ListEx()\LScroll\Buttons\fState = #False
                ListEx()\LScroll\Thumb\State    = #False
                ListEx()\LScroll\Timer = #False
              EndIf   
              
              If Backwards <> ListEx()\LScroll\Buttons\bState : DrawScrollButton_(#ListView, #ListView_Up)   : EndIf 
              If Forwards  <> ListEx()\LScroll\Buttons\fState : DrawScrollButton_(#ListView, #ListView_Down) : EndIf 
              If Thumb     <> ListEx()\LScroll\Thumb\State    : DrawThumb_(#ListView) : EndIf 
      			  ;}
      			EndIf
            
            ForEach ListEx()\ListView\Item()
              If Y >= ListEx()\ListView\Item()\Y And Y <= ListEx()\ListView\Item()\Y + ListEx()\ListView\RowHeight
                ListEx()\ListView\Focus = ListIndex(ListEx()\ListView\Item())
                DrawListView_()
                ProcedureReturn #True
              EndIf
            Next 
            ;}
          Case #PB_EventType_MouseLeave     ;{ Mouse Leave

            ListEx()\LScroll\Buttons\bState = #False
            ListEx()\LScroll\Buttons\fState = #False
            ListEx()\LScroll\Thumb\State    = #False
            ListEx()\ListView\Focus = #PB_Default
            
            DrawListView_()
            
            ProcedureReturn #True
            ;}
          Case #PB_EventType_MouseWheel     ;{ Mouse 
            
            Delta = GetGadgetAttribute(ComboExNum, #PB_Canvas_WheelDelta)

            If ListEx()\LScroll\Focus And ListEx()\LScroll\Hide = #False
              SetThumbPosY_(ListEx()\LScroll\Pos - Delta)
              DrawListView_()
            EndIf            
            ;}
        EndSelect 
        
      EndIf
   
    EndIf
    
  EndProcedure
  

  Procedure _KeyShiftTabHandler()
    Define.i GNum, Column, Row
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      
      If FindMapElement(ListEx(), Str(GNum))  

        Select ActiveID 
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
          Case ListEx()\DateNum
            CloseDate_(#True)
        EndSelect
        
      EndIf
      
    EndIf
  EndProcedure
  
  Procedure _KeyDownHandler()
    Define.i Row, Column, PageRows, Key, Modifier, Scrollbar
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
            RemoveSelection_()
          ElseIf ListEx()\ComboBox\Flag
            If ListEx()\ComboBox\CursorPos > 0
              ListEx()\ComboBox\CursorPos - 1
            EndIf 
            RemoveSelection_()
          Else  
            ListEx()\Col\OffsetX - 20
          EndIf 
          ScrollBar = #Horizontal
          ;}
        Case #PB_Shortcut_Right    ;{ Right
          If ListEx()\String\Flag
            If ListEx()\String\CursorPos < Len(ListEx()\String\Text)
              ListEx()\String\CursorPos + 1
            EndIf
            RemoveSelection_()
          ElseIf ListEx()\ComboBox\Flag 
            If ListEx()\ComboBox\CursorPos < Len(ListEx()\ComboBox\Text)
              ListEx()\ComboBox\CursorPos + 1
            EndIf  
            RemoveSelection_()
          Else 
            ListEx()\Col\OffsetX + 20
          EndIf
          ScrollBar = #Horizontal
          ;}
        Case #PB_Shortcut_Up       ;{ Up
          
          If ListEx()\String\Flag = #False And ListEx()\ComboBox\Flag = #False
            
            If ListEx()\Focus = #True 
              
              If PreviousElement(ListEx()\Rows())
                ListEx()\Row\Current = ListIndex(ListEx()\Rows())
              ElseIf FirstElement(ListEx()\Rows())
                ListEx()\Row\Current = ListIndex(ListEx()\Rows())
              EndIf
              
              ListEx()\Row\Focus = ListEx()\Row\Current
              SetRowFocus_(ListEx()\Row\Focus)
              
            EndIf
            
          EndIf
          ScrollBar = #Vertical
          ;}
        Case #PB_Shortcut_Down     ;{ Down
          
          If ListEx()\String\Flag = #False And ListEx()\ComboBox\Flag = #False
            
            If ListEx()\Focus = #True 
              
              If NextElement(ListEx()\Rows())
                ListEx()\Row\Current = ListIndex(ListEx()\Rows())
                ListEx()\Row\Focus = ListEx()\Row\Current
                SetRowFocus_(ListEx()\Row\Focus)
              EndIf

            EndIf
            
          EndIf 
          ScrollBar = #Vertical
          ;}
        Case #PB_Shortcut_PageUp   ;{ PageUp
          If ListEx()\String\Flag = #False And ListEx()\ComboBox\Flag = #False
            
            PageRows = GetPageRows_()
            
            ListEx()\Row\Current = ListEx()\Row\Focus - PageRows
            If ListEx()\Row\Current < 0 : ListEx()\Row\Current = 0 : EndIf
            
            If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
              ListEx()\Row\Focus  = ListEx()\Row\Current
              SetRowFocus_(ListEx()\Row\Focus)              
            EndIf
            
          EndIf
          ScrollBar = #Vertical
          ;}
        Case #PB_Shortcut_PageDown ;{ PageDown

          If ListEx()\String\Flag = #False And ListEx()\ComboBox\Flag = #False
            
            PageRows = GetPageRows_()
            
            ListEx()\Row\Current = ListEx()\Row\Focus + PageRows
            If ListEx()\Row\Current >= ListSize(ListEx()\Rows()) : ListEx()\Row\Current = ListSize(ListEx()\Rows()) - 1 : EndIf 
            
            If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
              ListEx()\Row\Focus = ListEx()\Row\Current
              SetRowFocus_(ListEx()\Row\Focus)
            EndIf
            
          EndIf  
          ScrollBar = #Vertical
          ;}
        Case #PB_Shortcut_Home     ;{ Home
          If ListEx()\String\Flag
            ListEx()\String\CursorPos = 0
            RemoveSelection_()
            ScrollBar = #Horizontal
          ElseIf ListEx()\ComboBox\Flag
            ListEx()\ComboBox\CursorPos = 0
            RemoveSelection_()
            ScrollBar = #Horizontal
          Else
            If Modifier & #PB_Canvas_Control
              If FirstElement(ListEx()\Rows())
                ListEx()\Focus = #True
                ListEx()\Row\Current = ListIndex(ListEx()\Rows())
                ListEx()\Row\Focus   = ListEx()\Row\Current
                SetRowFocus_(ListEx()\Row\Focus)
              EndIf
            EndIf
            ScrollBar = #Vertical
          EndIf 
          ;}
        Case #PB_Shortcut_End      ;{ End
          If ListEx()\String\Flag
            ListEx()\String\CursorPos = Len(ListEx()\String\Text)
            RemoveSelection_()
            ScrollBar = #Horizontal
          ElseIf ListEx()\ComboBox\Flag
            ListEx()\ComboBox\CursorPos = Len(ListEx()\ComboBox\Text)
            RemoveSelection_()
            ScrollBar = #Horizontal
          Else          
            If Modifier & #PB_Canvas_Control
              If LastElement(ListEx()\Rows())
                ListEx()\Row\Current = ListIndex(ListEx()\Rows())
                ListEx()\Row\Focus = ListEx()\Row\Current
                SetRowFocus_(ListEx()\Row\Focus)
              EndIf
              ScrollBar = #Vertical
            EndIf
          EndIf  
          ;}
        Case #PB_Shortcut_Back     ;{ Delete Back
          If ListEx()\String\Flag
            If ListEx()\String\CursorPos > 0
              If ListEx()\Selection\Flag = #TextSelected
                DeleteSelection_()
              Else  
                ListEx()\String\Text = DeleteStringPart_(ListEx()\String\Text, ListEx()\String\CursorPos)
                ListEx()\String\CursorPos - 1
              EndIf  
            EndIf
          ElseIf ListEx()\ComboBox\Flag
            If ListEx()\ComboBox\CursorPos > 0
              If ListEx()\Selection\Flag = #TextSelected
                DeleteSelection_()
              Else
                ListEx()\ComboBox\Text = DeleteStringPart_(ListEx()\ComboBox\Text, ListEx()\ComboBox\CursorPos)
                ListEx()\ComboBox\CursorPos - 1
              EndIf  
            EndIf
          EndIf  
          ;}
        Case #PB_Shortcut_Delete   ;{ Delete
          If ListEx()\String\Flag
            If ListEx()\String\CursorPos < Len(ListEx()\String\Text)
              If ListEx()\Selection\Flag = #TextSelected
                DeleteSelection_()
              Else 
                ListEx()\String\Text = DeleteStringPart_(ListEx()\String\Text, ListEx()\String\CursorPos + 1)
              EndIf  
            EndIf
          ElseIf ListEx()\ComboBox\Flag  
            If ListEx()\ComboBox\CursorPos < Len(ListEx()\ComboBox\Text)
              If ListEx()\Selection\Flag = #TextSelected
                DeleteSelection_()
              Else 
                ListEx()\ComboBox\Text = DeleteStringPart_(ListEx()\ComboBox\Text, ListEx()\ComboBox\CursorPos + 1)
              EndIf  
            EndIf
          EndIf   
          ;} 
        Case #PB_Shortcut_Insert   ;{ Paste (Shift-Ins)
          If Modifier & #PB_Canvas_Shift
            Text = GetClipboardText()
            If ListEx()\String\Flag
              If ListEx()\Selection\Flag = #TextSelected : DeleteSelection_() : EndIf
              ListEx()\String\Text = InsertString(ListEx()\String\Text, Text, ListEx()\String\CursorPos + 1)
              ListEx()\String\CursorPos + Len(Text)
            ElseIf ListEx()\ComboBox\Flag
              If ListEx()\Selection\Flag = #TextSelected : DeleteSelection_() : EndIf
              ListEx()\ComboBox\Text = InsertString(ListEx()\ComboBox\Text, Text, ListEx()\ComboBox\CursorPos + 1)
              ListEx()\ComboBox\CursorPos + Len(Text)
            EndIf
          EndIf
          ;}  
        Case #PB_Shortcut_V        ;{ Paste (Ctrl-V) 
          If Modifier & #PB_Canvas_Control
            Text = GetClipboardText()
            If ListEx()\String\Flag
              If ListEx()\Selection\Flag = #TextSelected : DeleteSelection_() : EndIf
              ListEx()\String\Text = InsertString(ListEx()\String\Text, Text, ListEx()\String\CursorPos + 1)
              ListEx()\String\CursorPos + Len(Text)
            ElseIf ListEx()\ComboBox\Flag
              If ListEx()\Selection\Flag = #TextSelected : DeleteSelection_() : EndIf
              ListEx()\ComboBox\Text = InsertString(ListEx()\ComboBox\Text, Text, ListEx()\ComboBox\CursorPos + 1)
              ListEx()\ComboBox\CursorPos + Len(Text)
            EndIf 
          EndIf
          ;} 
        Case #PB_Shortcut_Return   ;{ Return

          If ListEx()\String\Flag   : CloseString_()   : EndIf 
          If ListEx()\ComboBox\Flag : CloseComboBox_() : EndIf  
          ;}
        Case #PB_Shortcut_Escape   ;{ Escape
          If ListEx()\String\Flag   : CloseString_(#True)   : EndIf 
          If ListEx()\ComboBox\Flag : CloseComboBox_(#True) : EndIf
          ;}  
        Case #PB_Shortcut_Tab      ;{ Tabulator

          If Modifier & #PB_Canvas_Shift
          
            If ListEx()\String\Flag       ;{ String Gadget
              
              CloseString_()
  
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
              ;}
            ElseIf ListEx()\ComboBox\Flag ;{ ComboBox
              
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
              ;}
            EndIf
            
          Else
            
            If ListEx()\String\Flag       ;{ String Gadget
              
              CloseString_()
  
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
              ;}
            ElseIf ListEx()\ComboBox\Flag ;{ ComboBox
            
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
              ;}  
            EndIf

          EndIf    
          ;}
      EndSelect
      
      If ListEx()\String\Flag
        DrawString_()
      ElseIf ListEx()\ComboBox\Flag
        DrawComboBox_()
      Else
        Draw_(Scrollbar)
      EndIf  

    EndIf
    
  EndProcedure
  
  
  Procedure _InputHandler()
    Define   Char.i, Char$
    Define.i GNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))

      If ListEx()\String\Flag ;{ String Gadget
        
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
        If Char >= 32
          
          If ListEx()\Selection\Flag = #TextSelected : DeleteSelection_() : EndIf
          
          Char$ = Chr(Char)
          ListEx()\String\CursorPos + 1  
          
          If ListEx()\String\MaxChars
            ListEx()\String\Text = Left(InsertString(ListEx()\String\Text, Char$, ListEx()\String\CursorPos), ListEx()\String\MaxChars)
          Else
            
            ListEx()\String\Text = InsertString(ListEx()\String\Text, Char$, ListEx()\String\CursorPos)

            If SelectElement(ListEx()\Cols(), ListEx()\String\Col)
              If ListEx()\Cols()\MaxChars
                ListEx()\String\Text = Left(ListEx()\String\Text, ListEx()\Cols()\MaxChars)
              EndIf  
            EndIf
          
          EndIf   
          
          PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Change)
          PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Change)
          
          DrawString_()
          
        EndIf
        ;}
      ElseIf ListEx()\ComboBox\Flag ;{ ComboBox
        
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
        If Char >= 32
          
          Char$ = Chr(Char)
          ListEx()\ComboBox\CursorPos + 1  
          
          If ListEx()\ComboBox\MaxChars
            ListEx()\ComboBox\Text = Left(InsertString(ListEx()\ComboBox\Text, Char$, ListEx()\ComboBox\CursorPos), ListEx()\ComboBox\MaxChars)
          Else
            
            ListEx()\ComboBox\Text = InsertString(ListEx()\ComboBox\Text, Char$, ListEx()\ComboBox\CursorPos)
            
            If SelectElement(ListEx()\Cols(), ListEx()\ComboBox\Col)
              If ListEx()\Cols()\MaxChars
                ListEx()\ComboBox\Text = Left(ListEx()\ComboBox\Text, ListEx()\Cols()\MaxChars)
              EndIf  
            EndIf
          
          EndIf   
          
          PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Change)
          PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Change)
          
          DrawComboBox_()
          
        EndIf
        ;}
      EndIf
      
    EndIf
    
  EndProcedure   
  

  Procedure _RightClickHandler()
    Define.i X, Y, dX, dY
    Define.i GNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      X = DesktopUnscaledX(dX)
      Y = DesktopUnscaledY(dY)
      
      If dX < dpiX(ListEx()\Area\X) And dX < dpiX(ListEx()\Area\Width) 
        If dY > dpiY(ListEx()\Area\Y + ListEx()\Header\Height) And dY < dpiY(ListEx()\Area\Height)
          
          ListEx()\Row\Current = GetRowDPI_(dY)
          
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
    Define.i X, Y, dX, dY,ColX, Width, Height
    Define.i Flags, FontID, Row, StartRow, EndRow, FrontColor
    Define.s Key$, Value$, ScrollBar
    Define   Image.Image_Structure
    Define   GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      X = DesktopUnscaledX(dX)
      Y = DesktopUnscaledY(dY)
      
      ListEx()\Row\Current = GetRowDPI_(dY)
      ListEx()\Col\Current = GetColumnDPI_(dX)

      If ListEx()\String\Flag And (ListEx()\String\Row <> ListEx()\Row\Current Or ListEx()\String\Col <> ListEx()\Col\Current)       ;{ Close String
        CloseString_()
        Draw_()
      EndIf ;}
      
      If ListEx()\ComboBox\Flag       ;{ Close ComboBox
        
        If ListEx()\ComboBox\Row = ListEx()\Row\Current And ListEx()\ComboBox\Col = ListEx()\Col\Current
          
          If X >= ListEx()\ComboBox\ButtonX - ListEx()\Col\OffsetX
            ComboButton_(#Click)
            ProcedureReturn #True
          EndIf
          
        Else  
          CloseComboBox_()
          Draw_()
        EndIf
        
      EndIf ;}
      
      If ListEx()\Date\Flag           ;{ Close DateGadget
        CloseDate_()
        Draw_()
      EndIf ;}
      
      ; _____ Scrollbar _____     
			If ListEx()\Flags & #Horizontal ;{ Horizontal Scrollbar
			  
			  If ListEx()\HScroll\Hide = #False
			    
			    If dY > dpiY(ListEx()\HScroll\Y) And dY < dpiY(ListEx()\HScroll\Y + ListEx()\HScroll\Height)
  			    If dX > dpiX(ListEx()\HScroll\X) And dX < dpiX(ListEx()\HScroll\X + ListEx()\HScroll\Width)
			    
      			  ListEx()\HScroll\CursorPos = #PB_Default
      			  
      			  If ListEx()\HScroll\Focus
      			    
        			  If dX > dpiX(ListEx()\HScroll\Buttons\bX) And  dX < dpiX(ListEx()\HScroll\Buttons\bX + ListEx()\HScroll\Buttons\Width)
        			    
        			    ; --- Backwards Button ---
        			    If ListEx()\HScroll\Buttons\bState <> #Click
        			      ListEx()\HScroll\Delay = ListEx()\Scrollbar\TimerDelay
        			      ListEx()\HScroll\Timer = #Scrollbar_Left
        			      ListEx()\HScroll\Buttons\bState = #Click
        			      Draw_(#Horizontal)
        			    EndIf
        			    
        			  ElseIf dX > dpiX(ListEx()\HScroll\Buttons\fX) And  dX < dpiX(ListEx()\HScroll\Buttons\fX + ListEx()\HScroll\Buttons\Width)
        			    
        			    ; --- Forwards Button ---
        			    If ListEx()\HScroll\Buttons\fState <> #Click
        			      ListEx()\HScroll\Delay = ListEx()\Scrollbar\TimerDelay
        			      ListEx()\HScroll\Timer = #Scrollbar_Right
        			      ListEx()\HScroll\Buttons\fState = #Click
        			      Draw_(#Horizontal)
        			    EndIf
        			    
        			  ElseIf  dX > dpiX(ListEx()\HScroll\Thumb\X) And X < dpiX(ListEx()\HScroll\Thumb\X + ListEx()\HScroll\Thumb\Width)
        			    
        			    ; --- Thumb Button ---
        			    If ListEx()\HScroll\Thumb\State <> #Click
        			      ListEx()\HScroll\Thumb\State = #Click
        			      ListEx()\HScroll\CursorPos = X
        			      Draw_(#Horizontal)
        			    EndIf
      			    
        			  EndIf
        			  
        			EndIf
        			
        			ProcedureReturn #True
        		EndIf
        	EndIf
        	
    		EndIf	
  			;}
			EndIf 
			
			If ListEx()\Flags & #Vertical   ;{ Vertical Scrollbar
			  
			  If ListEx()\VScroll\Hide = #False
			    
			    If dX > dpiX(ListEx()\VScroll\X) And dX < dpiX(ListEx()\VScroll\X + ListEx()\VScroll\Width)
  			    If dY > dpiY(ListEx()\VScroll\Y) And dY < dpiY(ListEx()\VScroll\Y + ListEx()\VScroll\Height)
			    
      			  ListEx()\VScroll\CursorPos = #PB_Default
      			  
      			  If ListEx()\VScroll\Focus
      			    
      			    If dY > dpiY(ListEx()\VScroll\Buttons\bY) And dY < dpiY(ListEx()\VScroll\Buttons\bY + ListEx()\VScroll\Buttons\Height)
      
      			      If ListEx()\VScroll\Buttons\bState <> #Click
      			        ; --- Backwards Button ---
        			      ListEx()\VScroll\Delay = ListEx()\Scrollbar\TimerDelay
        			      ListEx()\VScroll\Timer = #Scrollbar_Up
        			      ListEx()\VScroll\Buttons\bState = #Click
        			      Draw_(#Vertical)
        			    EndIf
        			    
      			    ElseIf dY > dpiY(ListEx()\VScroll\Buttons\fY) And dY < dpiY(ListEx()\VScroll\Buttons\fY + ListEx()\VScroll\Buttons\Height)
      			      
      			      ; --- Forwards Button ---
        			    If ListEx()\VScroll\Buttons\fState <> #Click
        			      ListEx()\VScroll\Delay = ListEx()\Scrollbar\TimerDelay
        			      ListEx()\VScroll\Timer = #Scrollbar_Down
        			      ListEx()\VScroll\Buttons\fState = #Click
        			      Draw_(#Vertical)
        			    EndIf
      			      
      			    ElseIf  dY > dpiY(ListEx()\VScroll\Thumb\Y) And dY < dpiY(ListEx()\VScroll\Thumb\Y + ListEx()\VScroll\Thumb\Height)
      			      
      			      ; --- Thumb Button ---
        			    If ListEx()\VScroll\Thumb\State <> #Click
        			      ListEx()\VScroll\Thumb\State = #Click
        			      ListEx()\VScroll\CursorPos = Y
        			      Draw_(#Vertical)
        			    EndIf
      			      
      			    EndIf  
      
      			  EndIf
      			  
      			  ProcedureReturn #True
      			EndIf
      		EndIf
      		
  			EndIf  
			  ;}
			EndIf
			; ______________________
			
      ;{ Resize column with mouse
      If ListEx()\Row\Current = #Header
        
        ForEach ListEx()\Cols()
          ColX = ListEx()\Cols()\X - ListEx()\Col\OffsetX
          If X >= ColX - 2 And X <= ColX + 2 ; "|<- |"
            ListEx()\Col\Resize = ListIndex(ListEx()\Cols()) - 1
            ListEx()\Col\MouseX = ListEx()\Cols()\X - ListEx()\Col\OffsetX
            ProcedureReturn #True
          ElseIf X >= ColX + ListEx()\Cols()\Width - 2 And X <= ColX + ListEx()\Cols()\Width + 2 ; "| ->|"
            ListEx()\Col\Resize = ListIndex(ListEx()\Cols())
            ListEx()\Col\MouseX = ListEx()\Cols()\X + ListEx()\Cols()\Width - ListEx()\Col\OffsetX
            ProcedureReturn #True
          EndIf
        Next

      EndIf ;}
      
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
            
            UpdateRowY_()
            AdjustScrollBars_()
            Draw_(#Horizontal)
            
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
            ElseIf Flags & #Buttons Or Flags & #Strings Or Flags & #DateGadget ;{ Single cells
              
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
                FrontColor = ListEx()\Rows()\Column(Key$)\Color\Front
              ElseIf ListEx()\Rows()\Color\Front <> #PB_Default
                FrontColor = ListEx()\Rows()\Color\Front
              ElseIf ListEx()\Cols()\FrontColor <> #PB_Default
                FrontColor = ListEx()\Cols()\FrontColor
              Else
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
    Define.i X, Y, dX, dY
    Define GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      X = DesktopUnscaledX(dX)
      Y = DesktopUnscaledY(dY)
      
      ListEx()\Row\Current = GetRowDPI_(dY)
      ListEx()\Col\Current = GetColumnDPI_(dX)
      
      If ListEx()\CanvasCursor <> #Cursor_Default
        ListEx()\CanvasCursor = #Cursor_Default
        ListEx()\Col\Resize   = #PB_Default 
        ListEx()\Col\MouseX   = 0
      EndIf
      
      ; _____ Scrollbar _____
			If ListEx()\Flags & #Horizontal   ;{ Horizontal Scrollbar
			  
			  If ListEx()\HScroll\Hide = #False
			    
			    If dY > dpiY(ListEx()\HScroll\Y) And dY < dpiY(ListEx()\HScroll\Y + ListEx()\HScroll\Height)
  			    If dX > dpiX(ListEx()\HScroll\X) And dX < dpiX(ListEx()\HScroll\X + ListEx()\HScroll\Width)
			    
      			  ListEx()\HScroll\CursorPos = #PB_Default
      			  ListEx()\HScroll\Timer     = #False
      			  
      			  If ListEx()\HScroll\Focus
      			    
        			  If dX > dpiX(ListEx()\HScroll\Buttons\bX) And  dX < dpiX(ListEx()\HScroll\Buttons\bX + ListEx()\HScroll\Buttons\Width)
        			    
        			    ; --- Backwards Button ---
        			    SetThumbPosX_(ListEx()\HScroll\Pos - 1)
        			    Draw_(#Horizontal)
        			    
        			  ElseIf dX > dpiX(ListEx()\HScroll\Buttons\fX) And  dX < dpiX(ListEx()\HScroll\Buttons\fX + ListEx()\HScroll\Buttons\Width)
        			    
        			    ; --- Forwards Button ---
        			    SetThumbPosX_(ListEx()\HScroll\Pos + 1)
        			    Draw_(#Horizontal)
    
        			  ElseIf dX > dpiX(ListEx()\HScroll\Area\X) And dX < dpiX(ListEx()\HScroll\Thumb\X)
        			    
        			    ; --- Page left ---
        			    SetThumbPosX_(ListEx()\HScroll\Pos - ListEx()\HScroll\PageLength)
        			    Draw_(#Horizontal)
    
        			  ElseIf dX > dpiX(ListEx()\HScroll\Thumb\X + ListEx()\HScroll\Thumb\Width) And dX < dpiX(ListEx()\HScroll\Area\X + ListEx()\HScroll\Area\Width)
        			    
        			    ; --- Page right ---
        			    SetThumbPosX_(ListEx()\HScroll\Pos + ListEx()\HScroll\PageLength)
        			    Draw_(#Horizontal)
    
        			  EndIf
          			
        			EndIf
        			
        			ProcedureReturn #True
        		EndIf
        	EndIf

    		EndIf	
			  ;}
			EndIf   
		
      If ListEx()\Flags & #Vertical     ;{ Vertical Scrollbar
        
        If ListEx()\VScroll\Hide = #False
          
          If dX > dpiX(ListEx()\VScroll\X) And dX < dpiX(ListEx()\VScroll\X + ListEx()\VScroll\Width)
  			    If dY > dpiY(ListEx()\VScroll\Y) And dY < dpiY(ListEx()\VScroll\Y + ListEx()\VScroll\Height)
          
      			  ListEx()\VScroll\CursorPos = #PB_Default
      			  ListEx()\VScroll\Timer     = #False
      			  
      			  If ListEx()\VScroll\Focus
      			    
        			  If dY > dpiY(ListEx()\VScroll\Buttons\bY) And  dY < dpiY(ListEx()\VScroll\Buttons\bY + ListEx()\VScroll\Buttons\Height)
        			    
        			    ; --- Backwards Button ---
        			    SetThumbPosY_(ListEx()\VScroll\Pos - ListEx()\Row\ScrollUp) ;  - 1
        			    Draw_(#Vertical)
    
        			  ElseIf dY > dpiY(ListEx()\VScroll\Buttons\fY) And  dY < dpiY(ListEx()\VScroll\Buttons\fY + ListEx()\VScroll\Buttons\Height)
        			    
        			    ; --- Forwards Button ---
        			    SetThumbPosY_(ListEx()\VScroll\Pos + ListEx()\Row\ScrollDown) ; + 1
        			    Draw_(#Vertical)
       
        			  ElseIf dY > dpiY(ListEx()\VScroll\Area\Y) And dY < dpiY(ListEx()\VScroll\Thumb\Y)
        			    
        			    ; --- Page up ---
        			    SetThumbPosY_(ListEx()\VScroll\Pos - ListEx()\VScroll\PageLength)
        			    Draw_(#Vertical)
    
        			  ElseIf dY > dpiY(ListEx()\VScroll\Thumb\Y + ListEx()\VScroll\Thumb\Height) And dY < dpiY(ListEx()\VScroll\Area\Y + ListEx()\VScroll\Area\Height)
        			    
        			    ; --- Page down ---
        			    SetThumbPosY_(ListEx()\VScroll\Pos + ListEx()\VScroll\PageLength)
        			    Draw_(#Vertical)
        			   
        			  EndIf
          			
        			EndIf 
        			
        			ProcedureReturn #True
        		EndIf
        	EndIf
        	
    		EndIf	
			  ;}
			EndIf
			; _____________________
			
      If ListEx()\Row\Current < 0 Or ListEx()\Col\Current < 0 : ProcedureReturn #False : EndIf
      
      If ListEx()\ComboBox\Flag  ;{ ComboBox
        
        If ListEx()\ComboBox\Row = ListEx()\Row\Current And ListEx()\ComboBox\Col = ListEx()\Col\Current
          
          If X >= ListEx()\ComboBox\ButtonX - ListEx()\Col\OffsetX
            
            If ListEx()\ListView\Hide
              OpenListView_()
            Else
              CloseListView_()
            EndIf
            
            ComboButton_(#Focus)
            
            ProcedureReturn #True
          EndIf

        EndIf
        
        ComboButton_(#False)
        ;}
      EndIf

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
    Define.i dX, dY
    Define GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      If ListEx()\String\Flag   ;{ Close String
        CloseString_()
      EndIf ;}
      
      If ListEx()\ComboBox\Flag ;{ Close ComboBox
        CloseComboBox_()
      EndIf ;}
      
      If ListEx()\Date\Flag     ;{ Close DateGadget
        CloseDate_()
      EndIf ;}
      
      ListEx()\Row\Current = GetRowDPI_(dY)
      ListEx()\Col\Current = GetColumnDPI_(dX)
      
      If ListEx()\Row\Current < 0 Or ListEx()\Col\Current < 0 : ProcedureReturn #False : EndIf
      
      If ListEx()\Row\Current = #Header
        
      Else
   
        ManageEditGadgets_(ListEx()\Row\Current, ListEx()\Col\Current)
 
      EndIf
      
      Draw_()

    EndIf
    
  EndProcedure
  
  Procedure _MouseMoveHandler() ; DPI Aanpassung
    Define.i Row, Column, Flags, Backwards, Forwards, Thumb, CursorPos
    Define.f X, Y, dX, dY, ColX, ColWidth, RowY, Color
    Define.s Key$, Value$, Focus$, ScrollBar
    Define   Image.Image_Structure
    Define.i GNum = EventGadget()

    If FindMapElement(ListEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX) ; DPI
      dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY) ; DPI
      
      X = DesktopUnscaledX(dX)
      Y = DesktopUnscaledY(dY)
      
      ; ---- Scrollbar ----
			If ListEx()\Scrollbar\Flags & #Horizontal ;{ Horizontal Scrollbar
			  
			  If ListEx()\HScroll\Hide = #False
			  
  			  ListEx()\HScroll\Focus = #False
  			  
  			  Backwards = ListEx()\HScroll\Buttons\bState
  			  Forwards  = ListEx()\HScroll\Buttons\fState
  			  Thumb     = ListEx()\HScroll\Thumb\State
  			  
  			  If dY > dpiY(ListEx()\HScroll\Y) And dY < dpiY(ListEx()\HScroll\Y + ListEx()\HScroll\Height)
  			    If dX > dpiX(ListEx()\HScroll\X) And dX < dpiX(ListEx()\HScroll\X + ListEx()\HScroll\Width)
  			      
  			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
  			      
  			      ; --- Focus Scrollbar ---  
  			      ListEx()\HScroll\Buttons\bState = #Focus
  			      ListEx()\HScroll\Buttons\fState = #Focus
  			      ListEx()\HScroll\Thumb\State    = #Focus
  			      
  			      ; --- Hover Buttons & Thumb ---
  			      If dX > dpiX(ListEx()\HScroll\Buttons\bX) And  dX < dpiX(ListEx()\HScroll\Buttons\bX + ListEx()\HScroll\Buttons\Width)
  			        
  			        ListEx()\HScroll\Buttons\bState = #Hover
  			        
  			      ElseIf dX > dpiX(ListEx()\HScroll\Buttons\fX) And  dX < dpiX(ListEx()\HScroll\Buttons\fX + ListEx()\HScroll\Buttons\Width)
  			        
  			        ListEx()\HScroll\Buttons\fState = #Hover
  			        
  			      ElseIf dX > dpiX(ListEx()\HScroll\Thumb\X) And dX < dpiX(ListEx()\HScroll\Thumb\X + ListEx()\HScroll\Thumb\Width)
  			        
  			        ListEx()\HScroll\Thumb\State = #Hover
  			        
  			        ;{ --- Move thumb with cursor 
  			        If ListEx()\HScroll\CursorPos <> #PB_Default
  			          
  			          CursorPos = ListEx()\HScroll\Pos
  			          
    			        ListEx()\HScroll\Pos = GetThumbPosX_(X)
    			        ListEx()\HScroll\CursorPos = X
    			        
    			        If CursorPos <> ListEx()\HScroll\Pos
    			          Draw_(#Horizontal)
    			        Else
    			          DrawThumb_(#Horizontal)
    			        EndIf  
    			        
    			      EndIf ;}
  			        
    			    EndIf

    			    ListEx()\HScroll\Focus = #True

    			    If Backwards <> ListEx()\HScroll\Buttons\bState : DrawScrollButton_(#Horizontal, #Backwards) : EndIf 
      		    If Forwards  <> ListEx()\HScroll\Buttons\fState : DrawScrollButton_(#Horizontal, #Forwards)  : EndIf 
      		    If Thumb     <> ListEx()\HScroll\Thumb\State    : DrawThumb_(#Horizontal)                    : EndIf 
      		    
      		    ProcedureReturn #True
      			EndIf
      		EndIf
      		
      		If Not ListEx()\HScroll\Focus
      		  
  	        ListEx()\HScroll\Buttons\bState = #False
  	        ListEx()\HScroll\Buttons\fState = #False
  	        ListEx()\HScroll\Thumb\State    = #False
  	        
  	        ListEx()\HScroll\Timer = #False
  	      EndIf
      		
      		If Backwards <> ListEx()\HScroll\Buttons\bState : DrawScrollButton_(#Horizontal, #Backwards) : EndIf 
  		    If Forwards  <> ListEx()\HScroll\Buttons\fState : DrawScrollButton_(#Horizontal, #Forwards)  : EndIf 
  		    If Thumb     <> ListEx()\HScroll\Thumb\State    : DrawThumb_(#Horizontal)                   : EndIf 
      	
  		  EndIf   
			  ;}
			EndIf   
		
			If ListEx()\Scrollbar\Flags & #Vertical   ;{ Vertikal Scrollbar
			  
			  If ListEx()\VScroll\Hide = #False
			    
  			  ListEx()\VScroll\Focus = #False
  			  
  			  Backwards = ListEx()\VScroll\Buttons\bState
  			  Forwards  = ListEx()\VScroll\Buttons\fState
  			  Thumb     = ListEx()\VScroll\Thumb\State
  			  
  			  If dX > dpiX(ListEx()\VScroll\X) And dX < dpiX(ListEx()\VScroll\X + ListEx()\VScroll\Width)
  			    If dY > dpiY(ListEx()\VScroll\Y) And dY < dpiY(ListEx()\VScroll\Y + ListEx()\VScroll\Height)

  			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
  			      
  			      ; --- Focus Scrollbar ---  
  			      ListEx()\VScroll\Buttons\bState = #Focus
  			      ListEx()\VScroll\Buttons\fState = #Focus
  			      ListEx()\VScroll\Thumb\State    = #Focus
  			      
  			      ; --- Hover Buttons & Thumb ---
  			      If dY > dpiY(ListEx()\VScroll\Buttons\bY) And dY < dpiY(ListEx()\VScroll\Buttons\bY + ListEx()\VScroll\Buttons\Height)
  			        
  			        ListEx()\VScroll\Buttons\bState = #Hover
  			        
  			      ElseIf dY > dpiY(ListEx()\VScroll\Buttons\fY) And dY < dpiY(ListEx()\VScroll\Buttons\fY + ListEx()\VScroll\Buttons\Height)
  			        
  			        ListEx()\VScroll\Buttons\fState = #Hover
  
  			      ElseIf dY > dpiY(ListEx()\VScroll\Thumb\Y) And dY < dpiY(ListEx()\VScroll\Thumb\Y + ListEx()\VScroll\Thumb\Height)
  			        
  			        ListEx()\VScroll\Thumb\State = #Hover
  			        
  			        ;{ --- Move thumb with cursor 
  			        If ListEx()\VScroll\CursorPos <> #PB_Default
  			          
  			          CursorPos = ListEx()\VScroll\Pos
  			          
    			        ListEx()\VScroll\Pos       = GetThumbPosY_(Y)
    			        ListEx()\VScroll\CursorPos = Y
    			        
    			        If CursorPos <> ListEx()\VScroll\Pos
    			          Draw_(#Vertical)
    			        Else
    			          DrawThumb_(#Vertical)
    			        EndIf
    			        
    			      EndIf ;}
  
    			    EndIf   
    			    
    			    If Backwards <> ListEx()\VScroll\Buttons\bState : DrawScrollButton_(#Vertical, #Backwards) : EndIf 
              If Forwards  <> ListEx()\VScroll\Buttons\fState : DrawScrollButton_(#Vertical, #Forwards)  : EndIf 
              If Thumb     <> ListEx()\VScroll\Thumb\State    : DrawThumb_(#Vertical)                    : EndIf 
    			    
              ListEx()\VScroll\Focus = #True
              
              ProcedureReturn #True
      			EndIf
      		EndIf
      		
      		If Not ListEx()\VScroll\Focus
  
            ListEx()\VScroll\Buttons\bState = #False
            ListEx()\VScroll\Buttons\fState = #False
            ListEx()\VScroll\Thumb\State    = #False
            
            ListEx()\VScroll\Timer = #False
            
          EndIf   
          
          If Backwards <> ListEx()\VScroll\Buttons\bState : DrawScrollButton_(#Vertical, #Backwards) : EndIf 
          If Forwards  <> ListEx()\VScroll\Buttons\fState : DrawScrollButton_(#Vertical, #Forwards)  : EndIf 
          If Thumb     <> ListEx()\VScroll\Thumb\State    : DrawThumb_(#Vertical)                    : EndIf 
          
        EndIf  
			  ;}
			EndIf 
			
			ListEx()\HScroll\CursorPos = #PB_Default
			
			Row    = GetRowDPI_(dY)
      Column = GetColumnDPI_(dX)
			
      If Row = #Header
        
        If ListEx()\Flags & #ResizeColumn Or ListEx()\Flags & #AdjustColumns ;{ Resize column with mouse
          
          If ListEx()\CanvasCursor = #PB_Cursor_LeftRight
            
            If ListEx()\Col\MouseX ;{ Resize column
              
              If SelectElement(ListEx()\Cols(), ListEx()\Col\Resize)
                
                If ListEx()\Cols()\Width + (X - ListEx()\Col\MouseX) <= ListEx()\Cols()\minWidth
                  ProcedureReturn #False
                EndIf   
                
                ColX     = ListEx()\Cols()\X
                ColWidth = ListEx()\Cols()\Width
                
                ListEx()\Cols()\Width + (X - ListEx()\Col\MouseX) 
  
              EndIf
  
              If ListEx()\Flags & #AdjustColumns
            
                If SelectElement(ListEx()\Cols(), ListEx()\Col\Resize + 1)
                  
                  If ListEx()\Cols()\Width + (ListEx()\Col\MouseX - X) <= ListEx()\Cols()\minWidth
                    If SelectElement(ListEx()\Cols(), ListEx()\Col\Resize - 1)
                      ListEx()\Cols()\Width = ColWidth
                      ListEx()\Cols()\X     = ColX
                    EndIf
                    UpdateColumnX_()
                    Draw_(#Horizontal)
                    ProcedureReturn #False
                  EndIf   
    
                  ListEx()\Cols()\X = X
                  ListEx()\Cols()\Width + (ListEx()\Col\MouseX - X) 
                EndIf
              EndIf 
              
              ListEx()\Col\MouseX = X
              
              UpdateColumnX_()
              Draw_(#Horizontal)
              
              ProcedureReturn #True ;}
            EndIf
            
          Else                     ;{ Change cursor to #PB_Cursor_LeftRight
            
            ForEach ListEx()\Cols()
              If X >= ListEx()\Cols()\X- ListEx()\Col\OffsetX - 2 And X <= ListEx()\Cols()\X- ListEx()\Col\OffsetX + 2 ; "|<- |"
                ListEx()\CanvasCursor = #PB_Cursor_LeftRight
                SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                ProcedureReturn #True
              ElseIf X >= ListEx()\Cols()\X - ListEx()\Col\OffsetX + ListEx()\Cols()\Width - 2 And X <= ListEx()\Cols()\X - ListEx()\Col\OffsetX + ListEx()\Cols()\Width + 2 ; "| ->|"
                ListEx()\CanvasCursor = #PB_Cursor_LeftRight
                SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                ProcedureReturn #True
              EndIf
            Next
            ;}
          EndIf
          ;}
        EndIf
        
      Else  
        ListEx()\Col\MouseX = 0
      EndIf 

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
            
            If ListEx()\Flags & #ResizeColumn Or ListEx()\Flags & #AdjustColumns
              If X <= ListEx()\Cols()\X - ListEx()\Col\OffsetX + 2 Or X >= ListEx()\Cols()\X - ListEx()\Col\OffsetX + ListEx()\Cols()\Width - 2
                ProcedureReturn #False
              EndIf  
            EndIf 
            
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
              
              RowY = ListEx()\Rows()\Y - ListEx()\Row\OffsetY
              ColX = ListEx()\Cols()\X - ListEx()\Col\OffsetX
              
              Key$   = ListEx()\Cols()\Key
              Flags  = ListEx()\Rows()\Column(Key$)\Flags
              
              ; Change Cursor
              If ListEx()\Cols()\Flags & #Strings Or Flags & #Strings            ;{ String Gadget

                If ListEx()\String\Flag And ListEx()\String\Row = Row And ListEx()\String\Col = Column
                  
                  If ListEx()\CanvasCursor <> #Cursor_Text
                    ListEx()\CanvasCursor = #Cursor_Text
                    SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                  EndIf
                  
                Else
                  
                  If ListEx()\CanvasCursor <> #Cursor_Edit
                    ListEx()\CanvasCursor = #Cursor_Edit
                    SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                  EndIf
                
                EndIf
                ;}
              ElseIf ListEx()\Cols()\Flags & #ComboBoxes Or Flags & #ComboBoxes  ;{ ComboBox
                
                If ListEx()\ComboBox\Flag
                  
                  If ListEx()\ComboBox\Row = Row And ListEx()\ComboBox\Col = Column
                  
                    If X < ListEx()\ComboBox\ButtonX - ListEx()\Col\OffsetX
                      
                      If ListEx()\CanvasCursor <> #Cursor_Text
                        ListEx()\CanvasCursor = #Cursor_Text
                        SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                      EndIf

                    Else
  
                      If ListEx()\CanvasCursor <> #Cursor_Button
                        ListEx()\CanvasCursor = #Cursor_Button
                        SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                      EndIf
                      
                      ComboButton_(#Focus)
                      
                      ProcedureReturn #True
                    EndIf
                    
                  EndIf
                  
                Else

                  If ListEx()\CanvasCursor <> #Cursor_Edit
                    ListEx()\CanvasCursor = #Cursor_Edit
                    SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                  EndIf
                  
                EndIf
                ;}
              ElseIf ListEx()\Cols()\Flags & #CheckBoxes                         ;{ CheckBox
                
                If ListEx()\CanvasCursor <> #Cursor_Edit
                  ListEx()\CanvasCursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                ;}
              ElseIf ListEx()\Cols()\Flags & #DateGadget Or Flags & #DateGadget  ;{ Date Gadget
                
                If ListEx()\CanvasCursor <> #Cursor_Edit
                  ListEx()\CanvasCursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                ;}
              ElseIf ListEx()\Cols()\Flags & #Links                              ;{ Links
                
                If ListEx()\CanvasCursor <> #Cursor_Click
                  ListEx()\CanvasCursor = #Cursor_Click
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                ;}
              ElseIf ListEx()\Cols()\Flags & #Buttons                            ;{ Buttons

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
                
                DrawButton_(ColX, RowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, Value$, #Focus, ListEx()\Rows()\Color\Front, ListEx()\Rows()\FontID, @Image)
                
                If ListEx()\CanvasCursor <> #Cursor_Button
                  ListEx()\CanvasCursor = #Cursor_Button
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                ;}
              Else
                
                If ListEx()\CanvasCursor <> #Cursor_Default
                  ListEx()\CanvasCursor = #Cursor_Default
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\CanvasCursor)
                EndIf
                
              EndIf
              
              If ListEx()\ComboBox\Flag : ComboButton_(#False) : EndIf
              
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
      
      ; --- Scrollbar ---
      If ListEx()\Scrollbar\Flags & #Horizontal ;{ Horizontal Scrollbar
	      
	      ListEx()\HScroll\Buttons\bState = #False
        ListEx()\HScroll\Buttons\fState = #False
        ListEx()\HScroll\Thumb\State    = #False
        ListEx()\HScroll\CursorPos      = #PB_Default
	      ;}
	    EndIf
	    
	    If ListEx()\Scrollbar\Flags & #Vertical   ;{ Vertikal Scrollbar
	      
        ListEx()\VScroll\Buttons\bState = #False
        ListEx()\VScroll\Buttons\fState = #False
        ListEx()\VScroll\Thumb\State    = #False
        ListEx()\VScroll\CursorPos      = #PB_Default
	      ;}
      EndIf
      
      UpdateColumnX_()

      If ListEx()\ListView\Hide
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i GNum = EventGadget()
    Define.i Delta, Offset, Steps

    If FindMapElement(ListEx(), Str(GNum))
      
      Delta = GetGadgetAttribute(GNum, #PB_Canvas_WheelDelta)
      Steps = ListEx()\Row\Height * Delta
      
      If ListEx()\Scrollbar\Flags & #Horizontal ;{ Horizontal Scrollbar
        
        If ListEx()\HScroll\Focus And ListEx()\HScroll\Hide = #False
          SetThumbPosX_(ListEx()\HScroll\Pos - Steps)
          Draw_(#Horizontal)
          ProcedureReturn #True
        EndIf  
        ;}
      EndIf
      
      If ListEx()\Scrollbar\Flags & #Vertical   ;{ Vertical Scrollbar
        
        If ListEx()\VScroll\Hide = #False
          SetThumbPosY_(ListEx()\VScroll\Pos - Steps)
          Draw_(#Vertical)
        EndIf
        ;}
      EndIf
      
    EndIf
    
  EndProcedure
  

  CompilerIf #Enable_DragAndDrop
    
    Procedure _GadgetDropHandler()
      Define.s Key$, Text$
      Define.i GadgetNum = EventGadget()
      
      If FindMapElement(ListEx(), Str(GadgetNum))

        ListEx()\Row\Current = GetRowDPI_(EventDropY())
        ListEx()\Col\Current = GetColumnDPI_(EventDropX())
        
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
      
      If ListEx()\String\Flag   : CloseString_()   : EndIf
      If ListEx()\ComboBox\Flag : CloseComboBox_() : EndIf
      If ListEx()\Date\Flag     : CloseDate_()     : EndIf
      
      ; --- Scrollbar ---
      
      UpdateColumnX_()
      UpdateRowY_()
      AdjustScrollBars_()
      Draw_(#Vertical|#Horizontal)
  
    EndIf
    
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.i  OffSetX, OffsetY

    ForEach ListEx()
      
      If IsGadget(ListEx()\CanvasNum)
 
        If ListEx()\Flags & #AutoResize
          
          If ListEx()\Parent\Num <> #PB_Default
            
            If IsGadget(ListEx()\Parent\Num)
              OffSetX = GadgetWidth(ListEx()\Parent\Num)  - ListEx()\Parent\Width
              OffsetY = GadgetHeight(ListEx()\Parent\Num) - ListEx()\Parent\Height
            EndIf
            
          Else
            
            If IsWindow(ListEx()\Window\Num)
              OffSetX = WindowWidth(ListEx()\Window\Num)  - ListEx()\Window\Width
              OffsetY = WindowHeight(ListEx()\Window\Num) - ListEx()\Window\Height
            EndIf
          
          EndIf

          If ListEx()\Size\Flags
            
            X = #PB_Ignore : Y = #PB_Ignore : Width  = #PB_Ignore : Height = #PB_Ignore
            
            If ListEx()\Size\Flags & #MoveX : X = ListEx()\Size\X + OffSetX : EndIf
            If ListEx()\Size\Flags & #MoveY : Y = ListEx()\Size\Y + OffSetY : EndIf
            If ListEx()\Size\Flags & #Width  : Width  = ListEx()\Size\Width  + OffSetX : EndIf
            If ListEx()\Size\Flags & #Height : Height = ListEx()\Size\Height + OffSetY : EndIf
            
            ResizeGadget(ListEx()\CanvasNum, X, Y, Width, Height)
            
          Else
            
            ResizeGadget(ListEx()\CanvasNum, #PB_Ignore, #PB_Ignore, ListEx()\Size\Width + OffSetX, ListEx()\Size\Height + OffsetY)
            
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure _MoveWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach ListEx()

      If Window = ListEx()\Window\Num
        If ListEx()\ComboBox\Flag : CloseListView_() : EndIf 
      EndIf  

    Next
    
  EndProcedure 
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach ListEx()
    
      If ListEx()\Window\Num = Window

        DeleteMapElement(ListEx())
        
      EndIf
      
    Next
    
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
          
          ListEx()\Cursor\Pause = #True
          
          ListEx()\String\Wrong = #False   
          
          If Escape
            
            UpdateEventData_(#EventType_String, #NotValid, #NotValid, "", #NotValid, "")
            
          Else

            ListEx()\Rows()\Column(ListEx()\String\Label)\Value = ListEx()\String\Text
            
            UpdateEventData_(#EventType_String, ListEx()\String\Row, ListEx()\String\Col, ListEx()\String\Text, #NotValid, ListEx()\Rows()\ID)
            
            If IsWindow(ListEx()\Window\Num)
              PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
              PostEvent(#Event_Gadget,    ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
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
    
    RemoveSelection_()
    
    Draw_()
    
  EndProcedure
  
  Procedure  CloseDate_(Escape.i=#False)
    Define.i State
    Define.s Text$
    
    If IsGadget(ListEx()\DateNum)
      
      PushListPosition(ListEx()\Rows())
      
      If Escape
        UpdateEventData_(#EventType_Date, #NotValid, #NotValid, "", #NotValid, "")
      Else  
        If SelectElement(ListEx()\Rows(), ListEx()\Date\Row)
          
          CompilerIf Defined(DateEx, #PB_Module)
            State = DateEx::GetState(ListEx()\DateNum)
            Text$ = DateEx::GetText(ListEx()\DateNum)
          CompilerElse  
            State = GetGadgetState(ListEx()\DateNum)
            Text$ = GetGadgetText(ListEx()\DateNum)
          CompilerEndIf
        
          ListEx()\Rows()\Column(ListEx()\Date\Label)\Value = Text$
          ListEx()\Changed = #True
          UpdateEventData_(#EventType_Date, ListEx()\Date\Row, ListEx()\Date\Col, Text$, State, ListEx()\Rows()\ID)
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Date)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Date)
          EndIf    
        EndIf
      EndIf
      
      CompilerIf Defined(DateEx, #PB_Module)
        DateEx::Hide(ListEx()\DateNum, #True)
      CompilerElse  
        HideGadget(ListEx()\DateNum, #True)
      CompilerEndIf
      
      ListEx()\Date\Label = ""
      ListEx()\Date\Flag  = #False
      
      PopListPosition(ListEx()\Rows())
      
      BindShortcuts_(#False)
      
      Draw_()        
    EndIf
    
  EndProcedure
  
  Procedure  CloseComboBox_(Escape.i=#False)
    Define.i State
    Define.s Text$
    
    If ListEx()\ListView\Hide = #False : CloseListView_() : EndIf
    
    ListEx()\Cursor\Pause = #True
    
    PushListPosition(ListEx()\Rows())
    
    If SelectElement(ListEx()\Rows(), ListEx()\ComboBox\Row)
      If SelectElement(ListEx()\Cols(), ListEx()\ComboBox\Col)
        
        If Escape
        
          UpdateEventData_(#EventType_String, #NotValid, #NotValid, "", #NotValid, "")
          
        Else

          ListEx()\Rows()\Column(ListEx()\ComboBox\Label)\Value = ListEx()\ComboBox\Text
          
          UpdateEventData_(#EventType_String, ListEx()\ComboBox\Row, ListEx()\ComboBox\Col, ListEx()\ComboBox\Text, #NotValid, ListEx()\Rows()\ID)
          
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
          EndIf 
          
          ListEx()\Changed = #True
        EndIf

        ListEx()\ComboBox\Text  = ""
        ListEx()\ComboBox\Label = ""
        ListEx()\ComboBox\Flag  = #False

      EndIf
    EndIf

    PopListPosition(ListEx()\Rows())
    
    RemoveSelection_()
    
    Draw_()

  EndProcedure
  
  ;- _________ Internal _________

  Procedure   InitList_()

    ListEx()\ListView\Window = ListView\Window
    
    If IsWindow(ListEx()\ListView\Window)
      
      ListEx()\ListView\Num = ListView\Gadget
      
      If IsGadget(ListEx()\ListView\Num)
        
        ; ScrollBar 
        BindGadgetEvent(ListEx()\ListView\Num, @_ListViewHandler())
        
      EndIf 
      
      ListEx()\LScroll\Minimum = 0
      ListEx()\ListView\Height = 80
      
      ListEx()\LScroll\Hide  = #True
      ListEx()\ListView\Hide = #True
    EndIf
  
  EndProcedure 
  
  Procedure   ListViewWindow_()
    
    ListView\Window = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_BorderLess|#PB_Window_Invisible) 
    If ListView\Window
      ListView\Gadget = CanvasGadget(#PB_Any, 0, 0, 0, 0)
      StickyWindow(ListView\Window, #True)
    EndIf  

  EndProcedure
  

  ;- ==========================================================================
  ;-   Module - Scrollbars
  ;- ==========================================================================  

  Procedure.i ScrollBar()
    
    If ListEx()\Flags & #Horizontal
      ListEx()\Scrollbar\Flags | #Horizontal
      ListEx()\HScroll\CursorPos      = #PB_Default
      ListEx()\HScroll\Buttons\fState = #PB_Default
      ListEx()\HScroll\Buttons\bState = #PB_Default
    EndIf
    
    If ListEx()\Flags & #Vertical
      ListEx()\Scrollbar\Flags | #Vertical
      ListEx()\VScroll\CursorPos      = #PB_Default
      ListEx()\VScroll\Buttons\fState = #PB_Default
      ListEx()\VScroll\Buttons\bState = #PB_Default
    EndIf
    
    ListEx()\Scrollbar\Size         = #ScrollBarSize
    ListEx()\Scrollbar\TimerDelay   = #TimerDelay
     
    ; ----- Styles -----
    If ListEx()\Flags & #Style_Win11      : ListEx()\Scrollbar\Flags | #Style_Win11      : EndIf
    If ListEx()\Flags & #Style_RoundThumb : ListEx()\Scrollbar\Flags | #Style_RoundThumb : EndIf

    CompilerIf #PB_Compiler_Version >= 600
      If OSVersion() = #PB_OS_Windows_11  : ListEx()\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerElse
      If OSVersion() >= #PB_OS_Windows_10 : ListEx()\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerEndIf  
   
    ;{ ----- Colors -----
    ListEx()\Scrollbar\Color\Front  = $C8C8C8
    ListEx()\Scrollbar\Color\Back   = $F0F0F0
	  ListEx()\Scrollbar\Color\Button = $F0F0F0
	  ListEx()\Scrollbar\Color\Focus  = $D77800
	  ListEx()\Scrollbar\Color\Hover  = $666666
	  ListEx()\Scrollbar\Color\Arrow  = $696969

	  CompilerSelect #PB_Compiler_OS
		  CompilerCase #PB_OS_Windows
				ListEx()\Scrollbar\Color\Front  = GetSysColor_(#COLOR_SCROLLBAR)
				ListEx()\Scrollbar\Color\Back   = GetSysColor_(#COLOR_MENU)
				ListEx()\Scrollbar\Color\Button = GetSysColor_(#COLOR_BTNFACE)
				ListEx()\Scrollbar\Color\Focus  = GetSysColor_(#COLOR_MENUHILIGHT)
				ListEx()\Scrollbar\Color\Hover  = GetSysColor_(#COLOR_ACTIVEBORDER)
				ListEx()\Scrollbar\Color\Arrow  = GetSysColor_(#COLOR_GRAYTEXT)
			CompilerCase #PB_OS_MacOS
				ListEx()\Scrollbar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ListEx()\Scrollbar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ListEx()\Scrollbar\Color\Button = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ListEx()\Scrollbar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				ListEx()\Scrollbar\Color\Hover  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ListEx()\Scrollbar\Color\Arrow  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
			CompilerCase #PB_OS_Linux

		CompilerEndSelect
  
		If ListEx()\Scrollbar\Flags & #Style_Win11
		  ListEx()\Scrollbar\Color\Hover = $666666
		  ListEx()\Scrollbar\Color\Focus = $8C8C8C
		EndIf   
    ;}

  	BindGadgetEvent(ListEx()\CanvasNum, @_MouseWheelHandler(), #PB_EventType_MouseWheel)

	  ;BindEvent(#PB_Event_Timer, @_AutoScroll(), ListEx()\Window\Num)
		
		CalcScrollBar_()

	  DrawScrollBar_()

	EndProcedure
	
  Procedure   SetRowFocus_(Row.i)
    Define.i Y1, Y2, Difference
    
    Y1 = ListEx()\Area\Y + ListEx()\Header\Height
    Y2 = ListEx()\Area\Y + ListEx()\Area\Height
    
    PushListPosition(ListEx()\Rows())
    
    If SelectElement(ListEx()\Rows(), Row)

      If ListEx()\Rows()\Y < Y1
        Difference = Y1 - ListEx()\Rows()\Y
        SetThumbPosY_(ListEx()\VScroll\Pos - Difference - 2)
      ElseIf ListEx()\Rows()\Y + ListEx()\Rows()\Height > Y2
        Difference = Y2 - ListEx()\Rows()\Y - ListEx()\Rows()\Height - 2
        SetThumbPosY_(ListEx()\VScroll\Pos - Difference)
      EndIf 
      
    EndIf
    
    PopListPosition(ListEx()\Rows())
    
  EndProcedure
  

  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================  
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(ListEx(), Str(GNum))
	    ProcedureReturn ListEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(ListEx(), Str(GNum))
	    ProcedureReturn ListEx()\ID
	  EndIf
	  
	EndProcedure
	
	Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(ListEx(), Str(GNum))
	    ListEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(ListEx(), Str(GNum))
	    ListEx()\ID = String
	  EndIf
	  
	EndProcedure
  
  
  Procedure   DebugList(GNum.i)
    
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
          CSV$ = Export_CSV_Header(Separator, DQuote, Flags) + #LF$
        EndIf
        
        PushListPosition(ListEx()\Rows())
        
        ForEach ListEx()\Rows()
          
          If Flags & #Selected
            If ListEx()\Rows()\State & #Selected
              CSV$ + Export_CSV_Row(Separator, DQuote, Flags) + #LF$
            EndIf
          ElseIf Flags & #Checked
            If ListEx()\Rows()\State & #Checked
              CSV$ + Export_CSV_Row(Separator, DQuote, Flags) + #LF$
            EndIf  
          ElseIf Flags & #Inbetween
            If ListEx()\Rows()\State & #Inbetween
              CSV$ + Export_CSV_Row(Separator, DQuote, Flags) + #LF$
            EndIf   
          Else  
            If ListEx()\Rows()\State & #Selected Or ListEx()\Rows()\State & #Checked
              CSV$ + Export_CSV_Row(Separator, DQuote, Flags) + #LF$
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
            Row$ = Export_CSV_Header(Separator, DQuote, Flags)
            WriteStringN(FileID, Row$)
          EndIf
          
          PushListPosition(ListEx()\Rows())
          
          ForEach ListEx()\Rows()
            
            If Flags & #Selected
              If ListEx()\Rows()\State & #Selected
               Row$ = Export_CSV_Row(Separator, DQuote, Flags)
                WriteStringN(FileID, Row$)
              EndIf
            ElseIf Flags & #Checked
              If ListEx()\Rows()\State & #Checked
                Row$ = Export_CSV_Row(Separator, DQuote, Flags)
                WriteStringN(FileID, Row$)
              EndIf  
            ElseIf Flags & #Inbetween
              If ListEx()\Rows()\State & #Inbetween
                Row$ = Export_CSV_Row(Separator, DQuote, Flags)
                WriteStringN(FileID, Row$)
              EndIf   
            Else
              Row$ = Export_CSV_Row(Separator, DQuote, Flags)
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
        
        ClearList(ListEx()\Rows())
      
        ListEx()\Row\Number = 0
        ListEx()\RowIdx     = 1
        
        FileID = ReadFile(#PB_Any, File)
        If FileID
          
          BOM = ReadStringFormat(FileID)
          
          If Flags & #HeaderRow
            Row$ = ReadString(FileID, BOM)
            Import_CSV_Header(Row$, Separator, DQuote, Flags)
          EndIf
          
          While Eof(FileID) = #False
            Row$ = ReadString(FileID, BOM)
            Import_CSV_Row(Row$, Separator, DQuote, Flags)
          Wend

          CloseFile(FileID)
        EndIf
        
        If ListEx()\ReDraw
          If ListEx()\FitCols : FitColumns_() : EndIf
          UpdateRowY_()
          AdjustScrollBars_()
          Draw_(#Vertical|#Vertical)
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
  
  CompilerIf #Enable_Validation
    
    Procedure   SetCondition(GNum.i, Column.i, Term.s)
      
      If FindMapElement(ListEx(), Str(GNum))
        
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Cols()\Term = Term
        EndIf
        
      EndIf  
   
    EndProcedure
    
  CompilerEndIf  
  
  ;-  ----- Markdown -----
  CompilerIf Defined(MarkDown, #PB_Module)
    
    Procedure SetMarkdownFont(GNum.i, Name.s, Size.i)
      
      If FindMapElement(ListEx(), Str(GNum))
        
        MarkDown::LoadFonts(Name, Size)
        
        ListEx()\MarkDown = #True

      EndIf  
      
    EndProcedure
 
  CompilerEndIf
  ;-  --------------------

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
        
        ListEx()\Col\Counter + 1
        
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
          ListEx()\Cols()\Key = Str(ListEx()\Col\Counter)
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
        
        UpdateColumnX_()
        AdjustScrollBars_()
        
        If ListEx()\ReDraw
          Draw_(#Horizontal|#Vertical)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn ListIndex(ListEx()\Cols())
  EndProcedure
  
  Procedure.i AddComboBoxItems(GNum.i, Column.i, Items.s)
    Define.i i, Count
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Key$ = ListEx()\Cols()\Key
        
        Count = CountString(Items, #LF$) + 1
        For i = 1 To Count
          AddElement(ListEx()\ComboBox\Column(Key$)\Items())
          ListEx()\ComboBox\Column(Key$)\Items()\String = StringField(Items, i, #LF$)
          ListEx()\ComboBox\Column(Key$)\Items()\Color  = #PB_Default
        Next
        
      EndIf  
        
      ProcedureReturn ListSize(ListEx()\ComboBox\Column(Key$)\Items())      
    EndIf
    
  EndProcedure
  
  Procedure.i AddComboBoxItem(GNum.i, Column.i, Item.s, Color.i=#PB_Default)
    Define.i i, Count
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Key$ = ListEx()\Cols()\Key

        If AddElement(ListEx()\ComboBox\Column(Key$)\Items())
          ListEx()\ComboBox\Column(Key$)\Items()\String = Item
          ListEx()\ComboBox\Column(Key$)\Items()\Color  = Color
        EndIf
        
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
      
      If ListEx()\FitCols : FitColumns_() : EndIf
      
      AdjustRowsHeight_()
      UpdateRowY_()
      AdjustScrollBars_()
      
      If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf

    EndIf
    
    ProcedureReturn ListIndex(ListEx()\Rows())
  EndProcedure
  
  Procedure.i AddItem(GNum.i, Row.i=-1, Text.s="", Label.s="", Flags.i=#False) 
    Define.i Index = #PB_Default
    
    If FindMapElement(ListEx(), Str(GNum))

      Index = AddItem_(Row, Text, Label, Flags) 
      
      If ListEx()\FitCols : FitColumns_() : EndIf
      
      AdjustRowsHeight_()
      UpdateRowY_()
      AdjustScrollBars_()

      If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf

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
      ListEx()\RowIdx     = 0
      UpdateRowY_()
      AdjustScrollBars_()
      Draw_(#Horizontal|#Vertical)
 
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
        AdjustScrollBars_()
        Draw_(#Horizontal|#Vertical)
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
  
  ;- -----------------------------
  Procedure.i Gadget(GNum.i, X.f, Y.f, Width.f, Height.f, ColTitle.s, ColWidth.f, ColLabel.s="", Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum

    CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If WindowNum = #PB_Default : WindowNum = GetGadgetWindow() : EndIf
    
    If IsWindow(WindowNum)
      
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

        If ColLabel = "" : ColLabel = "0" : EndIf
        
        If AddMapElement(ListEx(), Str(GNum))
          
          ListEx()\Window\Num = WindowNum
          ListEx()\CanvasNum  = GNum
          
          ListEx()\Parent\Num = #PB_Default

          ListEx()\Cursor\Pause = #True
          
          CompilerSelect #PB_Compiler_OS ;{ Font
            CompilerCase #PB_OS_Windows
              ListEx()\FontID = GetGadgetFont(#PB_Default)
            CompilerCase #PB_OS_MacOS
              txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
              If txtNum
                ListEx()\FontID = GetGadgetFont(txtNum)
                FreeGadget(txtNum)
              EndIf
            CompilerCase #PB_OS_Linux
              ListEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerEndSelect ;}

          ListEx()\Flags  = Flags
          ListEx()\ReDraw = #True
          
          ListEx()\Row\Height = 20 ; Default row height
          ListEx()\Col\Width  = 50 ; Default column width
          
          If Flags & #NumberedColumn : ListEx()\Col\CheckBoxes = 1 : EndIf
          
          ListEx()\CanvasCursor = #Cursor_Default
          ListEx()\Editable     = #True
          
          ListEx()\ProgressBar\Minimum = 0
          ListEx()\ProgressBar\Maximum = 100
          
          InitList_()
          
          ListEx()\ListView\FontID = ListEx()\FontID
          
          ListEx()\PopUpID = -1
          
          ;{ Country defaults
          ListEx()\Country\Code             = #DefaultCountry
          ListEx()\Country\Currency         = #DefaultCurrency
          ListEx()\Country\Clock            = #DefaultClock
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
          
          ListEx()\Window\Width  = WindowWidth(ListEx()\Window\Num)
          ListEx()\Window\Height = WindowHeight(ListEx()\Window\Num)
          
          ListEx()\ScrollBar\MinSize = 6
          ;}        
  
          ;{ Gadgets
          CompilerIf Defined(DateEx, #PB_Module)
            ListEx()\DateNum = DateEx::Gadget(#PB_Any, 0, 0, 0, 0, ListEx()\Country\DateMask)
            If IsGadget(ListEx()\DateNum)
              DateEx::SetData(ListEx()\DateNum, ListEx()\CanvasNum)
              DateEx::Hide(ListEx()\DateNum, #True)
            EndIf  
          CompilerElse  
            ListEx()\DateNum = DateGadget(#PB_Any, 0, 0, 0, 0, ListEx()\Country\DateMask)
            If IsGadget(ListEx()\DateNum)
              SetGadgetData(ListEx()\DateNum, ListEx()\CanvasNum)
              HideGadget(ListEx()\DateNum, #True)
            EndIf
          CompilerEndIf
          ListEx()\Date\Mask = ListEx()\Country\DateMask
          ;}
          
          ;{ Scrollbars
          ListEx()\Flags | #Vertical|#Horizontal
          ListEx()\HScroll\Hide = #True
          ListEx()\VScroll\Hide = #True  
          
          ListEx()\HScroll\Minimum = ListEx()\Size\X
          ListEx()\VScroll\Minimum = ListEx()\Size\Y
          
          ScrollBar()
          ;}
          
          ;{ Shortcuts
          If IsWindow(ListEx()\Window\Num)
            ListEx()\ShortCutID = CreateMenu(#PB_Any, WindowID(ListEx()\Window\Num))
            If Flags & #AutoResize
              BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ListEx()\Window\Num)
            EndIf
            BindEvent(#PB_Event_MoveWindow,  @_MoveWindowHandler(),  ListEx()\Window\Num) 
            BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), ListEx()\Window\Num)
          Else
            Debug "ERROR: No active Window"
          EndIf ;}
          
          ;{ Header
          If Flags & #NoRowHeader
            ListEx()\Header\Height = 0
          Else  
            ListEx()\Header\Height = 20
          EndIf
          ListEx()\Header\FontID   = ListEx()\FontID
          ListEx()\Header\Align    = #False
          ;}
          
          ;{ Rows
          ListEx()\Row\Focus       = #NotValid
          ListEx()\Row\Current     = #NoFocus
          ListEx()\Row\StartSelect = #PB_Default
          ListEx()\Row\FontID      = ListEx()\FontID
          ListEx()\Size\Rows       = ListEx()\Row\Height ; Height of all rows
          ;}
          
          ;{ Column
          ListEx()\Col\Resize  = #PB_Default
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
            ListEx()\Col\Counter = 1
          EndIf
          
          ListEx()\Size\Cols           = ListEx()\Cols()\Width ; Width of all columns
          ListEx()\Sort\Column         = #NotValid
          ListEx()\AutoResize\MinWidth = ListEx()\Col\Width
          ListEx()\AutoResize\Column   = #PB_Ignore
          ;} 
          
          ColorTheme_(#Theme_Default)
  
          ListEx()\ListView\FrontColor = ListEx()\Color\Front
          
          BindGadgetEvent(ListEx()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
          BindGadgetEvent(ListEx()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
          BindGadgetEvent(ListEx()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
          BindGadgetEvent(ListEx()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
          BindGadgetEvent(ListEx()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
          BindGadgetEvent(ListEx()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
          BindGadgetEvent(ListEx()\CanvasNum,  @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
          BindGadgetEvent(ListEx()\CanvasNum,  @_KeyDownHandler(),         #PB_EventType_KeyDown)  
          BindGadgetEvent(ListEx()\CanvasNum,  @_InputHandler(),           #PB_EventType_Input)
          
          ;BindGadgetEvent(ListEx()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
          
          CompilerIf #Enable_DragAndDrop
            EnableGadgetDrop(ListEx()\CanvasNum, #PB_Drop_Text, #PB_Drag_Copy)
            BindEvent(#PB_Event_GadgetDrop, @_GadgetDropHandler(), ListEx()\Window\Num, ListEx()\CanvasNum)
          CompilerEndIf
          
          CompilerIf Defined(ModuleEx, #PB_Module)
            BindEvent(#Event_Theme, @_ThemeHandler())
          CompilerEndIf
          
          ; Cursor & AutoScroll Timer
          ListEx()\Cursor\Frequency = #CursorFrequency
          AddWindowTimer(ListEx()\Window\Num, #Timer, #Frequency)
          BindEvent(#PB_Event_Timer, @_TimerHandler(), ListEx()\Window\Num)
          
          Draw_()
          
        EndIf 
        
      EndIf
      
      CloseGadgetList()
    EndIf
    
    ProcedureReturn ListEx()\CanvasNum
  EndProcedure  
  ;- -----------------------------  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Attribute
        Case #FirstVisibleRow
          ProcedureReturn ListEx()\Row\Offset
        Case #VisibleRows
          ProcedureReturn GetPageRows_()
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
  
  Procedure.s GetItemLabel(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row < 0 : ProcedureReturn "" : EndIf
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\ID
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
      ProcedureReturn GetItemLabel(GNum, Row)
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
      
      If Column < 0 : ProcedureReturn "" : EndIf 
      
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
      
      If State
        ListEx()\Hide = #True
        HideGadget(GNum, #True)
      Else
        ListEx()\Hide = #False
        HideGadget(GNum, #False)
        AdjustScrollBars_()
        Draw_(#Vertical|#Horizontal)
      EndIf   

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
      
      UpdateColumnX_()
      AdjustScrollBars_()
      
      If ListEx()\ReDraw
        Draw_(#Horizontal|#Vertical)
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
        If ListEx()\ReDraw : Draw_(#Vertical|#Horizontal) : EndIf
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   Refresh(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\ReDraw = #True
      UpdateRowY_()
      UpdateColumnX_()
      If ListEx()\FitCols : FitColumns_() : EndIf
      AdjustScrollBars_()
      Draw_(#Horizontal|#Vertical)
      
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
        
        UpdateColumnX_()
        AdjustScrollBars_()
        
        If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
      EndIf
      
    EndIf  
  
  EndProcedure
  
  Procedure   RemoveItem(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        DeleteElement(ListEx()\Rows())
        UpdateRowY_()
        AdjustScrollBars_()
        If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
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
  
  Procedure   ResetSort(GNum.i)
    Define.i Index

    If FindMapElement(ListEx(), Str(GNum))
      
      Index = GetFocusIdx_()
      
      SortStructuredList(ListEx()\Rows(),#PB_Sort_Ascending, OffsetOf(ListEx_Rows_Structure\Idx), #PB_Integer)
      
      If ListEx()\Focus
        SetFocusIdx_(Index)
        SetRowFocus_(ListEx()\Row\Focus)
      EndIf
      
      If ListEx()\ReDraw : Draw_() : EndIf
      
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
        
        If ListEx()\String\Flag   ;{ Close String
          CloseString_(#True)
        EndIf ;}
        
        If ListEx()\ComboBox\Flag ;{ Close ComboBox
          CloseComboBox_(#True)
        EndIf ;}
        
        If ListEx()\Date\Flag     ;{ Close DateGadget
          CloseDate_(#True)
        EndIf ;}
        
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
        
        ListEx()\Focus     = #PB_Default
        ListEx()\Row\Focus = #PB_Default
        
      Else
        ProcedureReturn #False
      EndIf
      
      If ListEx()\ReDraw : Draw_() : EndIf
      
    EndIf  
      
  EndProcedure
  
  
  Procedure   SetAttribute(GNum.i, Attrib.i, Value.i)

    If FindMapElement(ListEx(), Str(GNum))
      
      Select Attrib
        Case #Padding
          ListEx()\Col\Padding         = Value
        Case #MaxChars      ; maximum number of characters for StringGadget/ComboBox 
          ListEx()\String\MaxChars     = Value
          ListEx()\ComboBox\MaxChars   = Value
          Case #ScrollBar   ; Flags for scrollbar
            ListEx()\ScrollBar\Flags   = Value
          Case #MinimumSize ; Minimum size of scrollbar thumb
            ListEx()\ScrollBar\MinSize = Value
        Case #ParentGadget  ; Parent gadget for resizing  
          If IsGadget(Value)
            ListEx()\Parent\Num        = Value
            ListEx()\Parent\X          = GadgetX(Value)
            ListEx()\Parent\Y          = GadgetY(Value)
            ListEx()\Parent\Width      = GadgetWidth(Value)
            ListEx()\Parent\Height     = GadgetHeight(Value)
          EndIf  
      EndSelect
      
      If ListEx()\ReDraw : Draw_(#Vertical|#Horizontal) : EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetAutoResizeColumn(GNum.i, Column.i, minWidth.f=#PB_Default, maxWidth.f=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Flags & ~#ResizeColumn
      
      If minWidth = #PB_Default : minWidth = ListEx()\Col\Width : EndIf
      
      ListEx()\AutoResize\Column   = Column
      ListEx()\AutoResize\minWidth = minWidth
      ListEx()\AutoResize\maxWidth = maxWidth
      If SelectElement(ListEx()\Cols(), Column) : ListEx()\AutoResize\Width = ListEx()\Cols()\Width : EndIf
      
      AdjustScrollBars_()
      
      If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
    EndIf  
 
  EndProcedure  
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure

  Procedure   SetCellFlags(GNum.i, Row.i, Column.i, Flags.i)
    ; #Buttons / #Editable / #Strings / #DateGadget / #LockCell
    
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
          
          If ListEx()\FitCols : FitColumns_() : EndIf
          
          AdjustRowsHeight_()
          UpdateRowY_()
          AdjustScrollBars_()
          
          If ListEx()\ReDraw : Draw_(#Vertical|#Horizontal) : EndIf
          
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
    ; #FrontColor | #BackColor | #LineColor | #FocusColor | #AlternateRowColor | #EditColor
    ; #HeaderFrontColor | #HeaderBackColor | #HeaderLineColor
    ; #ButtonColor | ButtonBorderColor
    ; #ComboFrontColor | #ComboBackColor
    ; #ProgressBarColor | #GradientColor
    ; #StringFrontColor | #StringBackColor
    ; #LinkColor | #ActiveLinkColor 
    
    If GNum = #Theme 
      
      ForEach ListEx()
        
        SetColor_(ColorTyp, Value)
        
        If ListEx()\ReDraw : Draw_(#Vertical|#Horizontal) : EndIf
      Next
      
    ElseIf FindMapElement(ListEx(), Str(GNum))
      
      SetColor_(ColorTyp, Value, Column)

      If ListEx()\ReDraw : Draw_(#Vertical|#Horizontal) : EndIf
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
        
        Draw_(#Vertical|#Horizontal)
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
    
      Draw_(#Vertical|#Horizontal)
    EndIf  
    
  EndProcedure  
  
  
  Procedure   SetColumnAttribute(GNum.i, Column.i, Attrib.i, Value.i)
    ; Attrib: #Align (#Left/#Right/#Center) / #ColumnWidth / #Font
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Select Attrib
          Case #Align
            ListEx()\Cols()\Align    = Value
          Case #ColumnWidth
            ListEx()\Cols()\Width    = Value
            UpdateColumnX_()
            AdjustScrollBars_()
          Case #MaxChars
            ListEx()\Cols()\MaxChars = Value
          Case #FontID
            ListEx()\Cols()\FontID   = Value
            AdjustScrollBars_()
          Case #Font  
            ListEx()\Cols()\FontID   = FontID(Value)
            AdjustScrollBars_()
        EndSelect
        
        If ListEx()\ReDraw : Draw_(#Vertical|#Horizontal) : EndIf
      EndIf 
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetColumnFlags(GNum.i, Column.i, Flags.i)

    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        If Flags < 0
          ListEx()\Cols()\Flags & Flags
        Else  
          ListEx()\Cols()\Flags | Flags
        EndIf
        
        If ListEx()\ReDraw : Draw_() : EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetColumnImage(GNum.i, Column.i, Image.i, Align.i=#Left, Width.i=#PB_Default, Height.i=#PB_Default)

    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)

        If IsImage(Image)
          
          If Width  = #PB_Default : Width  = ImageWidth(Image)  : EndIf 
          If Height = #PB_Default : Height = ImageHeight(Image) : EndIf 
          
          ListEx()\Cols()\Image\ID     = ImageID(Image)
          ListEx()\Cols()\Image\Width  = Width
          ListEx()\Cols()\Image\Height = Height
          ListEx()\Cols()\Image\Flags  = Align
          ListEx()\Cols()\Flags | #Image

        Else
          ListEx()\Cols()\Flags & ~#Image
        EndIf
        
        If ListEx()\FitCols : FitColumns_() : EndIf
        
        AdjustScrollBars_()
        
        If ListEx()\ReDraw  : Draw_(#Horizontal|#Vertical) : EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetColumnMask(GNum.i, Column.i, Mask.s)

    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        ListEx()\Cols()\Format = Mask
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

    If GNum = #Theme ;{ Theme
      
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
      ;}
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
        AdjustScrollBars_()
        Draw_(#Vertical|#Horizontal)
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
      
      AdjustScrollBars_()
      
      If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
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
  
  Procedure   SetItemLabel(GNum.i, Row.i, String.s)
    
    If FindMapElement(ListEx(), Str(GNum))
    
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\ID = String
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetItemImage(GNum.i, Row.i, Column.i, Image.i, Align.i=#Left, Width.i=#PB_Default, Height.i=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))                    
      
      If Row = #Header
        
        If SelectElement(ListEx()\Cols(), Column)
          If IsImage(Image)
            
            If Width  = #PB_Default : Width  = ImageWidth(Image)  : EndIf 
            If Height = #PB_Default : Height = ImageHeight(Image) : EndIf 
            
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
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\ID = ImageID(Image)
              If Width = #PB_Default
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Width = ImageWidth(Image)
              Else
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Width = Width
              EndIf  
              If Width = #PB_Default
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Height = ImageHeight(Image)
              Else
                ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Height = Height
              EndIf  
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Flags = Align
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags | #Image
            Else
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags & ~#Image
            EndIf

            If ListEx()\ReDraw
              If ListEx()\FitCols : FitColumns_() : EndIf
              AdjustScrollBars_()
              Draw_(#Vertical|#Horizontal)
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemImageID(GNum.i, Row.i, Column.i, Width.f, Height.f, ImageID.i, Align.i=#Left)
    
    If FindMapElement(ListEx(), Str(GNum))                    
      
      If Row = #Header
        
        If SelectElement(ListEx()\Cols(), Column)
          If ImageID
            ListEx()\Cols()\Header\Image\ID     = ImageID
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
            
            If ImageID
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\ID     = ImageID
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Width  = Width
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Height = Height
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Flags  = Align
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags | #Image
            Else
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags & ~#Image
            EndIf

            If ListEx()\ReDraw
              If ListEx()\FitCols : FitColumns_() : EndIf
              AdjustScrollBars_()
              Draw_(#Vertical|#Horizontal)
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore)          ; [#Selected/#Checked/#Inbetween]
    
    If FindMapElement(ListEx(), Str(GNum))

      If Row >= 0
        
        If ListEx()\String\Flag   ;{ Close String
          CloseString_(#True)
        EndIf ;}
        
        If ListEx()\ComboBox\Flag ;{ Close ComboBox
          CloseComboBox_(#True)
        EndIf ;}
        
        If ListEx()\Date\Flag     ;{ Close DateGadget
          CloseDate_(#True)
        EndIf ;}
      
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
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #Header
        If SelectElement(ListEx()\Cols(), Column)
          
          If ListEx()\Cols()\Header\Title <> Text
            ListEx()\Cols()\Header\Title = Text
            If ListEx()\Cols()\Flags & #FitColumn : FitColumns_() : EndIf
            AdjustRowsHeight_()
            UpdateRowY_()
            AdjustScrollBars_()
            If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
          EndIf
          
        EndIf
      Else  
        If SelectElement(ListEx()\Rows(), Row)
          If SelectElement(ListEx()\Cols(), Column)
            
            If ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value <> Text
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value = Text
              If ListEx()\Cols()\Flags & #FitColumn : FitColumns_() : EndIf
              AdjustRowsHeight_()
              UpdateRowY_()
              AdjustScrollBars_()
              If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
            EndIf
            
          EndIf
        EndIf
      EndIf

    EndIf

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
      
      AdjustRowsHeight_()
      UpdateRowY_()
      AdjustScrollBars_()
      If ListEx()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetState(GNum.i, Row.i=#PB_Default, Column.i=#PB_Ignore)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If ListEx()\String\Flag   ;{ Close String
        CloseString_(#True)
      EndIf ;}
      
      If ListEx()\ComboBox\Flag ;{ Close ComboBox
        CloseComboBox_(#True)
      EndIf ;}
      
      If ListEx()\Date\Flag     ;{ Close DateGadget
        CloseDate_(#True)
      EndIf ;}
      
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
        Draw_()
      Else 

        If SelectElement(ListEx()\Rows(), Row)
          
          ListEx()\Focus = #True
          ListEx()\Row\Current = Row
          ListEx()\Row\Focus = ListEx()\Row\Current
          
          
          If Column <> #PB_Ignore And Column >= 0
            ManageEditGadgets_(Row, Column)
            SetActiveGadget(ListEx()\CanvasNum)
          EndIf 
          
          SetRowFocus_(ListEx()\Row\Focus)

          Draw_()
          
        EndIf
        
      EndIf

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
        
        ListEx()\Sort\Label     = ListEx()\Cols()\Key
        ListEx()\Sort\Column    = Column
        ListEx()\Sort\Direction = Direction
        
        If Flags = #True
          ListEx()\Sort\Flags = #SortString
        ElseIf Flags = #Deutsch
          ListEx()\Sort\Flags = #SortString|#Deutsch
        Else
          ListEx()\Sort\Flags = Flags
        EndIf
        
        SortColumn_()
        
        UpdateRowY_()
        
        ;ListEx()\Focus = #False
        ;ListEx()\Row\Focus = #NotValid
        
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  ; __________ Init _________
  
  ListViewWindow_()
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 0
  
  UsePNGImageDecoder()
  
  #Window  = 0
  Enumeration 1 ;{ Constants
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
    #MenuItem6
    #B_Green
    #B_Blue
    #B_Default
  EndEnumeration ;}

  #Image = 0
  #Font_Arial9  = 1
  #Font_Arial9B = 2
  #Font_Arial9U = 3
  
  LoadFont(#Font_Arial9,  "Arial", 9)
  LoadFont(#Font_Arial9B, "Arial", 9, #PB_Font_Bold)
  LoadFont(#Font_Arial9U, "Arial", 9, #PB_Font_Underline)
  
  If OpenWindow(#Window, 0, 0, 500, 250, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#PopupMenu) ;{ Popup menu
      MenuItem(#MenuItem5, "Copy to clipboard")
      MenuBar()
      MenuItem(#MenuItem0, "Clear List")
      MenuBar()
      MenuItem(#MenuItem1, "Theme 'Blue'")
      MenuItem(#MenuItem2, "Theme 'Green'")
      MenuItem(#MenuItem3, "Theme 'Default'")
      MenuBar()
      MenuItem(#MenuItem4, "Reset gadget size")
      MenuItem(#MenuItem6, "Reset sort")
    EndIf ;}
    
    ButtonGadget(#Button,    420,  10, 70, 22, "Resize")
    ButtonGadget(#B_Default, 420,  50, 70, 22, "Default")
    ButtonGadget(#B_Green,   420,  75, 70, 22, "Green")
    ButtonGadget(#B_Blue,    420, 100, 70, 22, "Blue")
    ButtonGadget(#Export,    420, 140, 70, 22, "Export")
    
    If ListEx::Gadget(#List, 10, 10, 395, 230, "", 25, "", ListEx::#GridLines|ListEx::#CheckBoxes|ListEx::#AutoResize|ListEx::#MultiSelect|ListEx::#ResizeColumn|ListEx::#AdjustRows, #Window)
      
      ; ListEx::#NoRowHeader|ListEx::#ThreeState|ListEx::#NumberedColumn|ListEx::#SingleClickEdit|ListEx::#AdjustColumns
      
      ListEx::DisableReDraw(#List, #True) 
      
      CompilerIf #Example = 1
        
        ; If the text contains #LF$, the text is output in multiple lines, if the line height is sufficient.
        
        ListEx::AddColumn(#List, 1, "Text", 275, "text") 
        ListEx::SetRowsHeight(#List, 40)
        ListEx::AddItem(#List, ListEx::#LastItem, "Row 1|Row 2") ; | is replaced in the column text by #LF$
        
        If LoadImage(#Image, "Delete.png")
          ;ListEx::SetItemImage(#List, 0, 1, #Image)
          ListEx::SetItemImageID(#List, 0, 1, 16, 16, ImageID(#Image))
        EndIf 
        
        ;ListEx::SetItemText(#List, 0, "Row 1" + #LF$ + "Row 2" + #LF$ + "Row 3" + #LF$ + "Row 4", 1) ; #LF$ = new row
        ;ListEx::SetItemText(#List, 0, "Row 1" + #LF$ + "Row 2" + #LF$ + "Row 3", 1) ; #LF$ = new row
        
      CompilerElse
        
        ;{ ===== Add different types of columns =====
        ListEx::AddColumn(#List, 1, "Link", 75, "link",   ListEx::#Links)     ; |ListEx::#FitColumn
        ListEx::AddColumn(#List, 2, "Edit", 85, "edit",   ListEx::#Editable|ListEx::#StartSelected)  ; |ListEx::#FitColumn                                                                      
        ListEx::AddColumn(#List, ListEx::#LastItem, "Combo",   60, "combo",  ListEx::#ComboBoxes)
        ListEx::AddColumn(#List, ListEx::#LastItem, "Date",    76, "date",   ListEx::#DateGadget)
        ListEx::AddColumn(#List, ListEx::#LastItem, "Buttons", 55, "button", ListEx::#Buttons) ; ListEx::#Hide
        
        ListEx::AddColumn(#List, ListEx::#LastItem, "Test 1", 75) 
        ListEx::AddColumn(#List, ListEx::#LastItem, "Test 2", 60) 
        
        ; --- Test ProgressBar ---
        CompilerIf ListEx::#Enable_ProgressBar
          ;ListEx::AddColumn(#List, ListEx::#LastItem, "Progress", 60, "progress", ListEx::#ProgressBar)
          ;ListEx::SetProgressBarFlags(#List, ListEx::#ShowPercent)
        CompilerEndIf
        ;}
        
        ; --- Use column attributes ---
        ListEx::SetColumnAttribute(#List, 1, ListEx::#FontID, FontID(#Font_Arial9U))
        ListEx::SetColumnAttribute(#List, 5, ListEx::#Align, ListEx::#Center)
        
        ; --- Design of Header Row & List ---
        ListEx::SetHeaderAttribute(#List, ListEx::#Align, ListEx::#Center)
        ListEx::SetFont(#List, FontID(#Font_Arial9B), ListEx::#HeaderFont)
        ListEx::SetItemColor(#List, ListEx::#Header, ListEx::#FrontColor, $0000FF, 1)

        ListEx::SetFont(#List, FontID(#Font_Arial9))
        ListEx::SetFont(#List, FontID(#Font_Arial9B), #False, 6)
        ListEx::SetItemFont(#List,  0, FontID(#Font_Arial9B), 2)
        
        ; --- Change row height ---
        ListEx::SetRowsHeight(#List, 22)
        
        ;{ ===== Add Content =====
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
        ;}
        
        ;{ --- ComboBox in column 3 ---
        ;ListEx::AddComboBoxItems(#List, 3, "male" + #LF$ + "female")
        ListEx::AddComboBoxItem(#List, 3, "male",   $8B0000)
        ListEx::AddComboBoxItem(#List, 3, "female", $9314FF)
        ;}
        
        ; --- Set focus to row 9 ---
        ; ListEx::SetState(#List, 9)
        
        ; --- Change item state of row 3 ---
        ;ListEx::SetItemState(#List, 3, ListEx::#Inbetween)
        
        ; --- Use PopupMenu ---
        ListEx::AttachPopupMenu(#List, #PopupMenu)

        ; --- Test sorting ---
        ListEx::SetHeaderSort(#List, 2, ListEx::#Sort_Ascending|ListEx::#Sort_NoCase)
        
        ; --- Test colors ---
        ;ListEx::SetColor(#List, ListEx::#FrontColor, $82004B, 2) ; front color for column 2
        ;ListEx::SetItemColor(#List, 5, ListEx::#FrontColor, $228B22, 2)
        ;ListEx::SetItemColor(#List, 5, ListEx::#BackColor, $FAFFF5)
        ;ListEx::SetColor(#List, ListEx::#AlternateRowColor, $F0FFF0)
        
        ; --- Define AutoResize ---
        ;ListEx::SetAutoResizeColumn(#List, 2, 50)
        ListEx::SetAutoResizeFlags(#List, ListEx::#Height|ListEx::#Width) ; 
        
        ; --- Mark content in accordance with certain rules   ---
        CompilerIf ListEx::#Enable_MarkContent
          ListEx::MarkContent(#List, 1, "CHOICE{male|female}[C3]", $D30094, $9314FF, FontID(#Font_Arial9B))
        CompilerEndIf
        
        ; --- Test validation ---
        CompilerIf ListEx::#Enable_Validation
          ;ListEx::SetCondition(#List, 2, "BETWEEN{0|9}")
        CompilerEndIf
        
        ; --- Use color theme ---
        ListEx::SetColorTheme(#List, ListEx::#Theme_Blue)
        ListEx::SetColor(#List, ListEx::#AlternateRowColor, $FBF7F5)
        
        ; --- Use images ---
        If LoadImage(#Image, "Delete.png")
          ;Debug "Delete.png"
          ListEx::SetItemImage(#List, 0, 1, #Image)
          ListEx::SetItemImage(#List, 1, 5, #Image, ListEx::#Center, 14, 14)
          ListEx::SetItemImage(#List, ListEx::#Header, 2, #Image, ListEx::#Right, 14, 14)
        EndIf
        
        ; --- Test single cell flags ---
        ;ListEx::SetCellFlags(#List, 2, 5, ListEx::#Strings)
        
        ; --- Test ProgressBar ---
        CompilerIf ListEx::#Enable_ProgressBar
          ListEx::SetCellState(#List, 1, "progress", 100) ; or SetItemState(#List, 1, 75, 5)
          ListEx::SetCellState(#List, 2, "progress", 50) ; or SetItemState(#List, 2, 50, 5)
          ListEx::SetCellState(#List, 3, "progress", 25) ; or SetItemState(#List, 3, 25, 5)
        CompilerEndIf
  
        ; --- max. number of characters ---
        ;ListEx::SetAttribute(#List, ListEx::#MaxChars, 6)
        ;ListEx::SetColumnAttribute(#List, 2, ListEx::#MaxChars, 14)
        
      CompilerEndIf  
     
      ; --- GUI theme support ---
      ;ModuleEx::SetTheme(ModuleEx::#Theme_DarkBlue)

      ListEx::DisableReDraw(#List, #False) 

      ;ListEx::ExportCSV(#List, "Export.csv", ListEx::#NoButtons|ListEx::#NoCheckBoxes|ListEx::#HeaderRow)
      
      ; ------ Change color -----
      ;ListEx::SetItemColor(#List, 5, ListEx::#BackColor, $008CFF, 3)
      
      ; ------ Cell & Column flags -----
      ;ListEx::SetCellFlags(#List, 3, 1, ListEx::#Editable)
      
      ;ListEx::SetColumnFlags(#List, 5, ListEx::#Hide)      
      
      ; ----- Test Markdown -----
      CompilerIf Defined(MarkDown, #PB_Module)
        
        ListEx::SetMarkdownFont(#List, "Arial", 9)
        ListEx::SetCellFlags(#List, 4, 2, ListEx::#MarkDown)
        ListEx::SetItemText(#List, 4, "**Markdown**", 2)
        
      CompilerEndIf
      
      ListEx::SetItemText(#List, 3, "Row 1" + #LF$ + "Row 2" + #LF$ + "Row 3", 2) 
      
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case ListEx::#Event_Gadget ;{ works with or without EventType()
          Select EventType()
            Case #PB_EventType_RightClick 
              Debug "RightClick: " + Str(EventData())
            Case ListEx::#EventType_Row
              Debug ">>> Row: " + Str(EventData())
          EndSelect ;}
        Case #PB_Event_Gadget      ;{ only in use with EventType() 
          Select EventGadget()
            Case #List   ;{ List 
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
            Case #Button ;{ Buttons
              HideGadget(#Button,  #True)
              HideGadget(#B_Green, #True)
              HideGadget(#B_Default,  #True)
              HideGadget(#B_Blue,  #True)
              ResizeGadget(#List, #PB_Ignore, #PB_Ignore, 480, #PB_Ignore)
            Case #B_Green
              CompilerIf Defined(ModuleEx, #PB_Module)
                ModuleEx::SetTheme(ModuleEx::#Theme_Green)
              CompilerEndIf  
              ListEx::SetColorTheme(#List, ListEx::#Theme_Green)
              ListEx::SaveColorTheme(#List, "Theme_Green.json")
             Case #B_Default
              CompilerIf Defined(ModuleEx, #PB_Module)
                ;ModuleEx::SetTheme(ModuleEx::#Theme_Dark)
              CompilerEndIf  
              ListEx::SetColorTheme(#List, #PB_Default)
              ListEx::SaveColorTheme(#List, "Theme_Default.json") 
            Case #B_Blue
              CompilerIf Defined(ModuleEx, #PB_Module)
                ;ModuleEx::SetTheme(ModuleEx::#Theme_Blue)
              CompilerEndIf  
              ListEx::SetColorTheme(#List, ListEx::#Theme_Blue)
              ListEx::SaveColorTheme(#List, "Theme_Blue.json")
            Case #Export
              ListEx::ExportCSV(#List, "ListEx.csv", ListEx::#HeaderRow)
              ;}
          EndSelect ;}
        Case #PB_Event_Menu        ;{ PopupMenu
          Select EventMenu()
            Case #MenuItem0 
              ListEx::ClearItems(#List)
            Case #MenuItem1
              ListEx::LoadColorTheme(#List, "Theme_Blue.json")
            Case #MenuItem2
              ListEx::LoadColorTheme(#List, "Theme_Green.json")
            Case #MenuItem3  
              ListEx::LoadColorTheme(#List, "Theme_Default.json")
            Case #MenuItem4
              HideGadget(#Button,    #False)
              HideGadget(#B_Green,   #False)
              HideGadget(#B_Default, #False)
              HideGadget(#B_Blue,    #False)
              ResizeGadget(#List, #PB_Ignore, #PB_Ignore, 400, #PB_Ignore)
            Case #MenuItem5
              CompilerIf ListEx::#Enable_CSV_Support
                ListEx::ClipBoard(#List)
              CompilerEndIf 
            Case #MenuItem6
              ListEx::ResetSort(#List)
          EndSelect ;}
      EndSelect
    Until Event = #PB_Event_CloseWindow

    ;ListEx::SaveColorTheme(#List, "Theme_Test.json")
    
  EndIf
  
CompilerEndIf

; IDE Options = PureBasic 6.00 Beta 7 (Windows - x64)
; CursorPosition = 13
; FirstLine = 1
; Folding = QAAhAAAAAAAAAAoAAUIAAAAAAAAAAAAAQAACAAjkamAIAIYAU4FAACAAAiAAIQAYAAAAAAAAAwAAAAA1ui0-YCgAAAW5A+
; Markers = 3095,5306,7853
; EnableThread
; EnableXP
; DPIAware
; EnableUnicode