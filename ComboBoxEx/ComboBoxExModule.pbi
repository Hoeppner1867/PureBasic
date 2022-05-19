;/ ==============================
;/ =    ComboBoxExModule.pbi    =
;/ ==============================
;/
;/ [ PB V5.7x - 6.0 / 64Bit / all OS / DPI ]
;/
;/ © 2022 Thorsten1867 (12/2019)
;/

; Last Update: 18.05.2022
;
; - New Scrollbar
; - New DPI-management
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


;{ _____ ComboBoxEx - Commands _____

; ComboBoxEx::AddItem()            - similar to 'AddGadgetItem()'
; ComboBoxEx::AttachPopupMenu()    - attach a popup menu to the list
; ComboBoxEx::Copy()               - copy selection to clipboard
; ComboBoxEx::Cut()                - cut selection to clipboard
; ComboBoxEx::Delete()             - delete selection
; ComboBoxEx::ClearItems()         - similar to 'ClearGadgetItems()'
; ComboBoxEx::CountItems()         - similar to 'CountGadgetItems()'
; ComboBoxEx::Disable()            - similar to 'DisableGadget()'
; ComboBoxEx::GetData()            - similar to 'GetGadgetData()'
; ComboBoxEx::GetID()              - similar to 'GetGadgetData()', but string instead of quad
; ComboBoxEx::GetColor()           - similar to 'GetGadgetColor()'
; ComboBoxEx::GetItemData()        - similar to 'GetGadgetItemData()'
; ComboBoxEx::GetItemLabel()       - similar to 'GetGadgetItemData()', but string instead of quad
; ComboBoxEx::GetItemText()        - similar to 'GetGadgetItemText()'
; ComboBoxEx::GetLabelText()       - similar to 'GetGadgetItemText()', but label instead of row
; ComboBoxEx::GetState()           - similar to 'GetGadgetState()'
; ComboBoxEx::GetText()            - similar to 'GetGadgetText()'
; ComboBoxEx::Gadget()             - similar to 'ComboBoxGadget()'
; ComboBoxEx::Hide()               - similar to 'HideGadget()'
; ComboBoxEx::Paste()              - paste clipboard
; ComboBoxEx::RemoveItem()         - similar to 'RemoveGadgetItem()'
; ComboBoxEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; ComboBoxEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; ComboBoxEx::SetColor()           - similar to 'SetGadgetColor()'
; ComboBoxEx::SetData()            - similar to 'SetGadgetData()'
; ComboBoxEx::SetFont()            - similar to 'SetGadgetFont()'
; ComboBoxEx::SetID()              - similar to 'SetGadgetData()', but string instead of quad
; ComboBoxEx::SetImage()           - replace the arrow with an image
; ComboBoxEx::SetItemColor()       - similar to 'SetGadgetItemColor()'
; ComboBoxEx::SetItemData()        - similar to 'SetGadgetItemData()'
; ComboBoxEx::SetItemImage()       - similar to 'SetGadgetItemImage()'
; ComboBoxEx::SetItemText()        - similar to 'SetGadgetItemText()'
; ComboBoxEx::SetLabelText()       - similar to 'SetGadgetItemText()', but label instead of row
; ComboBoxEx::SetState()           - similar to 'SetGadgetState()'
; ComboBoxEx::SetText()            - similar to 'SetGadgetText()'

;}

;XIncludeFile "ModuleEx.pbi"

DeclareModule ComboBoxEx
  
  #Version  = 22051800
  #ModuleEx = 19112600
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #FirstItem = 0
  #LastItem  = -1
  
  EnumerationBinary ;{ Gadget Flags
    #Borderless
    #Editable
    #UpperCase
    #LowerCase
    #Image
    #AutoResize
    #Left
    #Right
    #Center
    #MultiSelect
    #UseExistingCanvas  
    #Style_RoundThumb
    #Style_Win11
  EndEnumeration ;}
  
  Enumeration 1     ;{ Attribute
    #MaximumLength = #PB_String_MaximumLength
    #Padding
    #Corner
    #ScrollBar
  EndEnumeration ;}
  
  Enumeration 1     ;{ Color
    #FrontColor  = #PB_Gadget_FrontColor
    #BackColor   = #PB_Gadget_BackColor
    #BorderColor = #PB_Gadget_LineColor
    #FocusBackColor
    #FocusTextColor
    #CursorColor
    #HighlightColor
    #HighlightTextColor
    #ScrollBar_FrontColor
    #ScrollBar_BackColor 
    #ScrollBar_BorderColor
    #ScrollBar_ButtonColor
    #ScrollBar_ThumbColor
  EndEnumeration ;}
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Gadget        = ModuleEx::#Event_Gadget
    #Event_Theme         = ModuleEx::#Event_Theme
    
    #EventType_Focus     = ModuleEx::#EventType_Focus
    #EventType_LostFocus = ModuleEx::#EventType_LostFocus
    #EventType_Change    = ModuleEx::#EventType_Change
    #EventType_Button    = ModuleEx::#EventType_Button
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Button
      #EventType_Focus
      #EventType_LostFocus
      #EventType_Change
    EndEnumeration
    
  CompilerEndIf

  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Flags.i=#False)
  Declare.i AddSubItem(GNum.i, Item.i, SubItem.i, Text.s, State.i=#False)
  Declare   AttachPopupMenu(GNum.i, MenuNum.i)
  Declare   Copy(GNum.i)
  Declare   Cut(GNum.i)
  Declare   Delete(GNum.i)
  Declare   ClearItems(GNum.i)
  Declare.i CountItems(GNum.i)
  Declare   Disable(GNum.i, State.i=#True)
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare.i GetColor(GNum.i, ColorType.i)
  Declare.q GetItemData(GNum.i, Row.i)
  Declare.s GetItemLabel(GNum.i, Row.i)
  Declare.s GetItemText(GNum.i, Row.i)
  Declare.s GetLabelText(GNum.i, Label.s)
  Declare.i GetState(GNum.i)
  Declare.i GetSubItemState(GNum.i, Item.i, SubItem.i)
  Declare.s GetSubItemText(GNum.i, Item.i, SubItem.i) 
  Declare.s GetText(GNum.i) 
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, maxListHeight.i, Content.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   Paste(GNum.i)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontNum.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetImage(GNum.i, Image.i)
  Declare   SetItemColor(GNum.i, Row.i, Color.i)
  Declare   SetItemData(GNum.i, Row.i, Value.q)
  Declare   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False)
  Declare   SetItemText(GNum.i, Row.i, Text.s, Flags.i=#False)
  Declare   SetLabelText(GNum.i, Label.s, Text.s, Flags.i=#False)
  Declare   SetState(GNum.i, State.i)
  Declare   SetSubItemState(GNum.i, Item.i, SubItem.i, State.i) 
  Declare   SetSubItemText(GNum.i, Item.i, SubItem.i, Text.s) 
  Declare   SetText(GNum.i, Text.s) 

EndDeclareModule

Module ComboBoxEx
  
  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================
  
  #ArrowSize       = 5
  #ButtonWidth     = 18
  
  #CursorTimer     = 1868
  #CursorFrequency = 600
  
  ;{ _____ ScrollBar _____
	#ScrollBarSize   = 14
	
	#AutoScrollTimer = 1867
	#Frequency       = 100  ; 100ms
	#TimerDelay      = 3    ; 100ms * 3
	
	EnumerationBinary Flags   ;{ Direction
	  #Vertical
    #Horizontal
	  #Scrollbar_Up
	  #Scrollbar_Left
	  #Scrollbar_Right
	  #Scrollbar_Down
	  #Forwards
	  #Backwards
	EndEnumeration ;}
	
  ;}
  
  EnumerationBinary ;{ CheckBox status 
    #Selected   = #PB_ListIcon_Selected
    #Checked    = #PB_ListIcon_Checked
    #Inbetween  = #PB_ListIcon_Inbetween
  EndEnumeration ;}
  
  EnumerationBinary State
    #Focus
    #Edit
    #Hover
    #Click
  EndEnumeration
  
  Enumeration Mouse
    #Mouse_Move
    #Mouse_Select
  EndEnumeration 
  
  Enumeration Selection
    #NoSelection
    #Selected
  EndEnumeration
  
  #Cursor = 1
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================

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
		
	Structure ScrollBar_Thumb_Structure     ;{ ComboEx()\ListView\HScroll\Forwards\Thumb\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollBar_Button_Structure    ;{ ComboEx()\ListView\HScroll\Buttons\...
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
	
	Structure ScrollBar_Color_Structure     ;{ ComboEx()\ListView\HScroll\Color\...
	  Front.i
	  Back.i
		Button.i
		Focus.i
		Hover.i
		Arrow.i
	EndStructure ;}
	
	Structure ScrollBar_Structure   ;{ ComboEx()\ListView\HScroll\...
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

	Structure ScrollBars_Structure  ;{ ComboEx()\ListView\ScrollBar\...
	  Color.ScrollBar_Color_Structure
	  Size.i       ; Scrollbar width (vertical) / height (horizontal)
	  TimerDelay.i ; Autoscroll Delay
	  Flags.i      ; Flag: #Vertical | #Horizontal
	EndStructure ;}

  Structure CheckBox_Structure               ;{ ComboEx()\ListView\Item()\CheckBox()\...
    X.i
    Y.i
    String.s
    Size.i
    State.i
  EndStructure ;}
  
  Structure Image_Structure                  ;{ ComboEx()\Button\Image\...
    Num.i
    Width.i
    Height.i
    Flags.i
  EndStructure ;}
  
  Structure ListView_Item_Structure          ;{ ComboEx()\ListView\Item()\...
    ID.s
    Quad.q
    Y.i
    String.s
    Image.Image_Structure
    Color.i
    Flags.i
    List SubItem.CheckBox_Structure()
  EndStructure ;}
  
  Structure ComboEx_ListView_Structure       ;{ ComboEx()\ListView\...
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
    Area.Area_Structure ; available area
    ScrollBar.ScrollBars_Structure
    VScroll.ScrollBar_Structure
    Map  Index.i() 
    List Item.ListView_Item_Structure()
  EndStructure ;}
  

  Structure Selection_Structure              ;{ ComboEx()\Selection\
    Pos1.i
    Pos2.i
    Flag.i
  EndStructure ;}

  Structure ComboEx_Button_Structure         ;{ ComboEx()\Button\...
    X.f
    State.i
    Image.Image_Structure
    Width.f
    Height.f
    Event.i
  EndStructure ;}  
  
  Structure ComboEx_Cursor_Structure         ;{ ComboEx()\Cursor\...
    Pos.i ; 0: "|abc" / 1: "a|bc" / 2: "ab|c"  / 3: "abc|"
    X.i
    Y.i
    Height.i
    State.i
    Frequency.i
    Elapsed.i
    Thread.i
    Pause.i
  EndStructure ;}
  
  Structure ComboEx_Color_Structure          ;{ ComboEx()\Color\...
    Front.i
    Back.i
    FocusText.i
    FocusBack.i
    Border.i
    Cursor.i
    Gadget.i
    CheckBox.i
    DisableFront.i
    DisableBack.i
    Highlight.i
    HighlightText.i
    Button.i
    WordColor.i
  EndStructure ;}
  
  Structure ComboEx_Size_Structure           ;{ ComboEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Text.i
    Flags.i
  EndStructure ;} 
  
  Structure ComboEx_Window_Structure         ;{ ComboEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure ComboEx_Structure                ;{ ComboEx()\...
    CanvasNum.i
    PopupNum.i
    
    Thread.i
    
    ID.s
    Quad.q
    
    FontID.i
    
    Text.s
    
    State.i
    
    OffSetX.i
    Mouse.i
    CanvasCursor.i
    
    Padding.i
    Radius.i
    
    Hide.i

    Disable.i
    Flags.i

    Button.ComboEx_Button_Structure
    Image.Image_Structure
    ListView.ComboEx_ListView_Structure
    
    Color.ComboEx_Color_Structure
    Cursor.ComboEx_Cursor_Structure
    Selection.Selection_Structure
    Size.ComboEx_Size_Structure
    Window.ComboEx_Window_Structure
    
  EndStructure ;}
  Global NewMap ComboEx.ComboEx_Structure()
  
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
  
  Procedure.i dpiX(Num.i)
	  ProcedureReturn DesktopScaledX(Num) 
	EndProcedure

	Procedure.i dpiY(Num.i)
	  ProcedureReturn DesktopScaledY(Num)
	EndProcedure
	
	Procedure   TextHeight_(Text.s)
	  ProcedureReturn DesktopUnscaledY(TextHeight(Text))
	EndProcedure
	
	Procedure   TextWidth_(Text.s)
	  ProcedureReturn DesktopUnscaledX(TextWidth(Text))
	EndProcedure  
	
	Procedure   DrawText_(X.i, Y.i, Text.s, FrontColor.i=#PB_Default, BackColor.i=#PB_Default)
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
	
	Procedure   DrawImage_(ImageID.i, X.i, Y.i, Width.i=#PB_Default, Height.i=#PB_Default)
	  
	  If Height = #PB_Default Or Width = #PB_Default
	    DrawImage(ImageID, dpiX(X), dpiY(Y))
	  Else 
  	  DrawImage(ImageID, dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height))
  	EndIf
	
	EndProcedure
	
	Procedure   Line_(X.i, Y.i, Width.i, Height.i, Color.i=#PB_Default)
	  If Color.i=#PB_Default
	    Line(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height))
	  Else
	    Line(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), Color)
	  EndIf   
	EndProcedure
	
	Procedure   LineXY_(x1.i, y1.i, x2.i, y2.i, Color.i=#PB_Default)
	  If Color.i=#PB_Default
	    LineXY(dpiX(x1), dpiY(y1), dpiX(x2), dpiY(y2))
	  Else
	    LineXY(dpiX(x1), dpiY(y1), dpiX(x2), dpiY(y2), Color)
	  EndIf   
	EndProcedure
	
	
	Procedure   ClipOutput_(X, Y, Width, Height)
    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
      ClipOutput(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height)) 
    CompilerEndIf
  EndProcedure
  
  Procedure   UnclipOutput_()
    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
      UnclipOutput() 
    CompilerEndIf
  EndProcedure
  
  ;- Scrollbar
  
  Procedure   CalcScrollBar_()
	  Define.i Width, Height, ScrollbarSize
	  
	  ; current canvas ScrollbarSize
	  Width         = GadgetWidth(ComboEx()\ListView\Num)
	  Height        = GadgetHeight(ComboEx()\ListView\Num)
	  ScrollbarSize = ComboEx()\ListView\Scrollbar\Size
	  
	  ;{ Calc available canvas area
	  If ComboEx()\ListView\VScroll\Hide
	    ComboEx()\ListView\Area\Width  = Width  - 2
      ComboEx()\ListView\Area\Height = Height - 2
    Else
      ComboEx()\ListView\Area\Width  = Width  - ScrollbarSize - 2
      ComboEx()\ListView\Area\Height = Height - 2
    EndIf ;}
    
    ;{ Calc scrollbar size
    ComboEx()\ListView\VScroll\X        = Width - ScrollbarSize  - 1
    ComboEx()\ListView\VScroll\Y        = 1
    ComboEx()\ListView\VScroll\Width    = ScrollbarSize
    ComboEx()\ListView\VScroll\Height   = Height - 2
    ;} 
    
    ;{ Calc scroll buttons
    ComboEx()\ListView\VScroll\Buttons\Width  = ScrollbarSize
    ComboEx()\ListView\VScroll\Buttons\Height = ScrollbarSize
    ; forward: down
    ComboEx()\ListView\VScroll\Buttons\fX     = ComboEx()\ListView\VScroll\X
    ComboEx()\ListView\VScroll\Buttons\fY     = ComboEx()\ListView\VScroll\Y + ComboEx()\ListView\VScroll\Height - ScrollbarSize
    ; backward: up
    ComboEx()\ListView\VScroll\Buttons\bX     = ComboEx()\ListView\VScroll\X
    ComboEx()\ListView\VScroll\Buttons\bY     = ComboEx()\ListView\VScroll\Y
    ;}

    ;{ Calc scroll area between buttons
    ComboEx()\ListView\VScroll\Area\X      = ComboEx()\ListView\VScroll\X
		ComboEx()\ListView\VScroll\Area\Y      = ComboEx()\ListView\VScroll\Y + ScrollbarSize 
		ComboEx()\ListView\VScroll\Area\Width  = ScrollbarSize
		ComboEx()\ListView\VScroll\Area\Height = ComboEx()\ListView\VScroll\Height - (ScrollbarSize * 2)
    ;}

    ;{ Calc thumb size
    ComboEx()\ListView\VScroll\Thumb\X      = ComboEx()\ListView\VScroll\Area\X
	  ComboEx()\ListView\VScroll\Thumb\Width  = ScrollbarSize
	  ComboEx()\ListView\VScroll\Thumb\Height = Round(ComboEx()\ListView\VScroll\Area\Height * ComboEx()\ListView\VScroll\Ratio, #PB_Round_Nearest) 
	  ComboEx()\ListView\VScroll\Factor       = (ComboEx()\ListView\VScroll\Area\Height - ComboEx()\ListView\VScroll\Thumb\Height) /  ComboEx()\ListView\VScroll\Range
	  
	  If ComboEx()\ListView\Scrollbar\Flags & #Style_Win11
	    ComboEx()\ListView\VScroll\Thumb\Width - 8
	    ComboEx()\ListView\VScroll\Thumb\X     + 4 
	  Else
	    ComboEx()\ListView\VScroll\Thumb\Width - 4
	    ComboEx()\ListView\VScroll\Thumb\X     + 2 
	  EndIf 
    ;}
    
	EndProcedure
	
	Procedure   CalcScrollRange_()

    If ComboEx()\ListView\VScroll\PageLength
      ComboEx()\ListView\VScroll\Pos    = ComboEx()\ListView\VScroll\Minimum
		  ComboEx()\ListView\VScroll\minPos = ComboEx()\ListView\VScroll\Minimum
		  ComboEx()\ListView\VScroll\maxPos = ComboEx()\ListView\VScroll\Maximum - ComboEx()\ListView\VScroll\PageLength + 1
		  ComboEx()\ListView\VScroll\Ratio  = ComboEx()\ListView\VScroll\PageLength / ComboEx()\ListView\VScroll\Maximum
		  ComboEx()\ListView\VScroll\Range  = ComboEx()\ListView\VScroll\maxPos - ComboEx()\ListView\VScroll\minPos
		EndIf

    CalcScrollBar_()

  	ComboEx()\ListView\VScroll\Thumb\Y = ComboEx()\ListView\VScroll\Area\Y
    
	EndProcedure
	
	Procedure.i GetThumbPosY_(Y.i)   ; Vertical Scrollbar
	  Define.i Delta, Offset

	  Delta = Y - ComboEx()\ListView\VScroll\CursorPos
	  ComboEx()\ListView\VScroll\Thumb\Y + Delta 
	  
	  If ComboEx()\ListView\VScroll\Thumb\Y < ComboEx()\ListView\VScroll\Area\Y
	    ComboEx()\ListView\VScroll\Thumb\Y =  ComboEx()\ListView\VScroll\Area\Y
	  EndIf 
	  
	  If ComboEx()\ListView\VScroll\Thumb\Y + ComboEx()\ListView\VScroll\Thumb\Height >  ComboEx()\ListView\VScroll\Area\Y + ComboEx()\ListView\VScroll\Area\Height
	    ComboEx()\ListView\VScroll\Thumb\Y =  ComboEx()\ListView\VScroll\Area\Y + ComboEx()\ListView\VScroll\Area\Height - ComboEx()\ListView\VScroll\Thumb\Height
	  EndIf
	  
	  Offset = ComboEx()\ListView\VScroll\Thumb\Y - ComboEx()\ListView\VScroll\Area\Y
	  ComboEx()\ListView\VScroll\Pos = Round(Offset / ComboEx()\ListView\VScroll\Factor, #PB_Round_Nearest) + ComboEx()\ListView\VScroll\minPos
	  
	  If ComboEx()\ListView\VScroll\Pos > ComboEx()\ListView\VScroll\maxPos : ComboEx()\ListView\VScroll\Pos = ComboEx()\ListView\VScroll\maxPos : EndIf
  	If ComboEx()\ListView\VScroll\Pos < ComboEx()\ListView\VScroll\minPos : ComboEx()\ListView\VScroll\Pos = ComboEx()\ListView\VScroll\minPos : EndIf
	  
	  ProcedureReturn ComboEx()\ListView\VScroll\Pos
	EndProcedure  
	
	Procedure   SetThumbPosY_(Pos.i) ; Vertical Scrollbar
	  Define.i  Offset
	  
	  ComboEx()\ListView\VScroll\Pos = Pos

	  If ComboEx()\ListView\VScroll\Pos < ComboEx()\ListView\VScroll\minPos : ComboEx()\ListView\VScroll\Pos = ComboEx()\ListView\VScroll\minPos : EndIf
	  If ComboEx()\ListView\VScroll\Pos > ComboEx()\ListView\VScroll\maxPos : ComboEx()\ListView\VScroll\Pos = ComboEx()\ListView\VScroll\maxPos : EndIf
	  
    Offset = Round((ComboEx()\ListView\VScroll\Pos - ComboEx()\ListView\VScroll\minPos) * ComboEx()\ListView\VScroll\Factor, #PB_Round_Nearest)
    ComboEx()\ListView\VScroll\Thumb\Y = ComboEx()\ListView\VScroll\Area\Y + Offset

	EndProcedure
	
	
  ;- ============================================================================
  ;-   Module - Edit
  ;- ============================================================================   
  
	
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
  
  
  Procedure   RemoveSelection_()                                  ; Remove & Reset selection 
    ComboEx()\Selection\Pos1 = #False
    ComboEx()\Selection\Pos2 = #False
    ComboEx()\Selection\Flag = #NoSelection
  EndProcedure
  
  Procedure   DeleteSelection_() 
    
    If ComboEx()\Selection\Flag = #Selected
      
      If ComboEx()\Selection\Pos1 > ComboEx()\Selection\Pos2
        ComboEx()\Text = Left(ComboEx()\Text, ComboEx()\Selection\Pos2) + Mid(ComboEx()\Text, ComboEx()\Selection\Pos1 + 1)
        ComboEx()\Cursor\Pos = ComboEx()\Selection\Pos2
      Else
        ComboEx()\Text = Left(ComboEx()\Text, ComboEx()\Selection\Pos1) + Mid(ComboEx()\Text, ComboEx()\Selection\Pos2 + 1)
        ComboEx()\Cursor\Pos = ComboEx()\Selection\Pos1
      EndIf  
      
      RemoveSelection_() 
    EndIf
    
  EndProcedure
  
  
  Procedure   Copy_()
    Define.s Text
    
    If ComboEx()\Selection\Pos1 > ComboEx()\Selection\Pos2
      Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos2 + 1, ComboEx()\Selection\Pos1)
    Else
      Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos1 + 1, ComboEx()\Selection\Pos2)
    EndIf
    
    SetClipboardText(Text)
    RemoveSelection_()
    
  EndProcedure
  
  Procedure   Cut_()
    Define.s Text
    
    If ComboEx()\Flags & #Editable
      
      If ComboEx()\Selection\Pos1 > ComboEx()\Selection\Pos2
        Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos2 + 1, ComboEx()\Selection\Pos1)
      Else
        Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos1 + 1, ComboEx()\Selection\Pos2)
      EndIf
    
      SetClipboardText(Text)
      DeleteSelection_()
      RemoveSelection_()
      
    EndIf

  EndProcedure
  
  Procedure   Paste_()
    Define.i c
    Define.s Text, Num, Char
    
    If ComboEx()\Flags & #Editable

      Text = GetClipboardText()

      If ComboEx()\Flags & #UpperCase : Text = UCase(Text) : EndIf
      If ComboEx()\Flags & #LowerCase : Text = LCase(Text) : EndIf
      
      If ComboEx()\Selection\Flag = #Selected
        DeleteSelection_()
        RemoveSelection_()
      EndIf
      
      ComboEx()\Text = InsertString(ComboEx()\Text, Text, ComboEx()\Cursor\Pos + 1)
      ComboEx()\Cursor\Pos + Len(Text)

    EndIf
    
  EndProcedure

  Procedure.i CursorPos_(CursorX.i)
    Define.s Text
    Define.i p, Pos.i
    
    CursorX = DesktopUnscaledX(CursorX)
    
    If CursorX >= ComboEx()\OffSetX
      
      Text = ComboEx()\Text

      If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
        DrawingFont(ComboEx()\FontID)
        For p=1 To Len(Text)
          Pos = p
          If ComboEx()\OffSetX + TextWidth_(Left(Text, p)) >= CursorX
            Break
          EndIf
        Next
        StopDrawing()
      EndIf
      
      ProcedureReturn Pos
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure.f CursorX_(CursorPos.i) ; [ Needs StartDrawing() ]
    ; Pos 0: '|abc' / Pos1: 'a|bc'
    Define.s Text
    
    Text = ComboEx()\Text
    
    If CursorPos > 0
      ProcedureReturn TextWidth_(Left(Text, CursorPos))
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  
  Procedure.i GetWordStart_(Pos.i) 
    Define.i p
    
    For p = Pos To 0 Step -1
      If Mid(ComboEx()\Text, p, 1) = " "
        ProcedureReturn p
      EndIf
    Next
    
    ProcedureReturn 0
  EndProcedure  
  
  Procedure.i GetWordEnd_(Pos.i) 
    Define.i p
    
    For p = Pos To Len(ComboEx()\Text)
      If Mid(ComboEx()\Text, p, 1) = " "
        ProcedureReturn p - 1
      EndIf
    Next
    
    ProcedureReturn Len(ComboEx()\Text)
  EndProcedure
  
  ;- __________ ScrollBar __________
  
  
  ;- ============================================================================
  ;-   Module - Drawing
  ;- ============================================================================   
  
  Procedure.f GetOffsetX_(Text.s, Width.i, OffsetX.i) 
    
    If ComboEx()\Flags & #Center
      ProcedureReturn (Width - TextWidth_(Text)) / 2
    ElseIf ComboEx()\Flags & #Right
      ProcedureReturn Width - TextWidth_(Text) - OffsetX
    Else
      ProcedureReturn OffsetX
    EndIf
 
  EndProcedure
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  
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
	  
	  Width   = ComboEx()\ListView\VScroll\Buttons\Width
	  Height  = ComboEx()\ListView\VScroll\Buttons\Height
	  
	  Select Direction ;{ Position & Size
	    Case #Scrollbar_Down
	      X       = ComboEx()\ListView\VScroll\Buttons\fX
	      Y       = ComboEx()\ListView\VScroll\Buttons\fY
	    Case #Scrollbar_Up
	      X       = ComboEx()\ListView\VScroll\Buttons\bX
	      Y       = ComboEx()\ListView\VScroll\Buttons\bY
	  EndSelect ;}
	  
	  If ComboEx()\ListView\Scrollbar\Flags & #Style_Win11 ;{ Arrow Sizre
	    
	    If Direction = #Scrollbar_Down Or Direction = #Scrollbar_Up 
	      aWidth  = 10
    	  aHeight =  7
	    Else
	      aWidth  =  7
        aHeight = 10  
	    EndIf   
	    
	    If ComboEx()\ListView\VScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If ComboEx()\ListView\VScroll\Buttons\fState= #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	  Else
	    aWidth  = 8
	    aHeight = 4
      ;}
	  EndIf  
	  
	  X + ((Width  - aWidth) / 2)
    Y + ((Height - aHeight) / 2)
	  
	  If StartVectorDrawing(CanvasVectorOutput(ComboEx()\ListView\Num))

      If ComboEx()\ListView\Scrollbar\Flags & #Style_Win11 ;{ solid

        Select Direction
          Case #Scrollbar_Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
            ClosePath()
          Case #Scrollbar_Down 
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
            ClosePath()
        EndSelect
        
        VectorSourceColor(aColor)
        FillPath()
        StrokePath(1)
        ;}
      Else                               ;{ /\

        Select Direction
          Case #Scrollbar_Up
            MovePathCursor(dpiX(X), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y))
            AddPathLine(dpiX(X + aWidth), dpiY(Y + aHeight))
          Case #Scrollbar_Down 
            MovePathCursor(dpiX(X), dpiY(Y))
            AddPathLine(dpiX(X + aWidth / 2), dpiY(Y + aHeight))
            AddPathLine(dpiX(X + aWidth), dpiY(Y))
        EndSelect
        
        VectorSourceColor(aColor)
        StrokePath(2, #PB_Path_RoundCorner)
        ;}
      EndIf
      
	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
  
	Procedure   DrawScrollButton_(Type.i)
	  Define.i X, Y, Width, Height
	  Define.i ArrowColor, ButtonColor, Direction, State
	  
    If ComboEx()\ListView\VScroll\Hide : ProcedureReturn #False : EndIf
    
    Width  = ComboEx()\ListView\VScroll\Buttons\Width
    Height = ComboEx()\ListView\VScroll\Buttons\Height
    
    Select Type
      Case #Forwards
        X     = ComboEx()\ListView\VScroll\Buttons\fX
        Y     = ComboEx()\ListView\VScroll\Buttons\fY
        State = ComboEx()\ListView\VScroll\Buttons\fState
        Direction = #Scrollbar_Down
      Case #Backwards
        X     = ComboEx()\ListView\VScroll\Buttons\bX
        Y     = ComboEx()\ListView\VScroll\Buttons\bY
        State = ComboEx()\ListView\VScroll\Buttons\bState
        Direction = #Scrollbar_Up
        
    EndSelect
    
    ;{ ----- Colors -----
    If ComboEx()\ListView\Scrollbar\Flags & #Style_Win11
      
      ButtonColor = ComboEx()\ListView\Scrollbar\Color\Back
      
      Select State
	      Case #Focus
	        ArrowColor = ComboEx()\ListView\Scrollbar\Color\Focus
	      Case #Hover
	        ArrowColor = ComboEx()\ListView\Scrollbar\Color\Hover
	      Case #Click  
	        ArrowColor = ComboEx()\ListView\Scrollbar\Color\Arrow
	      Default
	        ArrowColor = #PB_Default
	    EndSelect    

    Else
      
      Select State
	      Case #Hover
	        ButtonColor  = BlendColor_(ComboEx()\ListView\Scrollbar\Color\Focus, ComboEx()\ListView\Scrollbar\Color\Button, 10)
	      Case #Click
	        ButtonColor  = BlendColor_(ComboEx()\ListView\Scrollbar\Color\Focus, ComboEx()\ListView\Scrollbar\Color\Button, 20)
	      Default
	        ButtonColor  = ComboEx()\ListView\Scrollbar\Color\Button
	    EndSelect  
	    
	    ArrowColor = ComboEx()\ListView\Scrollbar\Color\Arrow
	    
	  EndIf 
	  ;}
    
	  ;{ ----- Draw button -----
	  If StartDrawing(CanvasOutput(ComboEx()\ListView\Num))
	    
	    DrawingMode(#PB_2DDrawing_Default)

	    Box_(X, Y, Width, Height, ButtonColor) 
	    StopDrawing()
	  EndIf ;}
	  
	  ;{ ----- Draw Arrows -----
	  If ArrowColor <> #PB_Default
	    DrawArrow_(ArrowColor, Direction)
	  EndIf ;} 

	EndProcedure
	
	Procedure   DrawThumb_()
	  Define.i BackColor, ThumbColor, Round
	  Define.i OffsetPos, OffsetSize
	  
	  ; ----- Thumb cursor state -----

    If ComboEx()\ListView\VScroll\Hide : ProcedureReturn #False : EndIf
    
    ;{ ----- Colors -----
	  If ComboEx()\ListView\Scrollbar\Flags & #Style_Win11 
	    
	    BackColor = ComboEx()\ListView\Scrollbar\Color\Back
	    
	    Select ComboEx()\ListView\VScroll\Thumb\State
	      Case #Focus
	        ThumbColor = ComboEx()\ListView\Scrollbar\Color\Focus
	      Case #Hover
	        ThumbColor = ComboEx()\ListView\Scrollbar\Color\Hover
	      Case #Click
	        ThumbColor = ComboEx()\ListView\Scrollbar\Color\Hover
	      Default
	        ThumbColor = ComboEx()\ListView\Scrollbar\Color\Focus
	    EndSelect 
	    
	    If ComboEx()\ListView\VScroll\Thumb\State ;{ Thumb size
	      Round = 4
	    Else
	      OffsetPos  = 2
	      OffsetSize = 4
	      Round = 0
  	    ;}
	    EndIf

	  Else
	    
	    BackColor = ComboEx()\ListView\Scrollbar\Color\Back
	    
	    Select ComboEx()\ListView\VScroll\Thumb\State
	      Case #Focus
	        ThumbColor = BlendColor_(ComboEx()\ListView\Scrollbar\Color\Focus, ComboEx()\ListView\Scrollbar\Color\Front, 10)
	      Case #Hover
	        ThumbColor = BlendColor_(ComboEx()\ListView\Scrollbar\Color\Focus, ComboEx()\ListView\Scrollbar\Color\Hover, 10)
	      Case #Click
	        ThumbColor = BlendColor_(ComboEx()\ListView\Scrollbar\Color\Focus, ComboEx()\ListView\Scrollbar\Color\Front, 20)
	      Default
	        ThumbColor = ComboEx()\ListView\Scrollbar\Color\Front
	    EndSelect 
	    
	    If ComboEx()\ListView\Scrollbar\Flags & #Style_RoundThumb
	      Round = 4
	    Else
	      Round = #False
	    EndIf
	    
	  EndIf ;}  
	  
	  If StartDrawing(CanvasOutput(ComboEx()\ListView\Num))
	    
	    DrawingMode(#PB_2DDrawing_Default)

  	  Box_(ComboEx()\ListView\VScroll\Area\X, ComboEx()\ListView\VScroll\Area\Y, ComboEx()\ListView\VScroll\Area\Width, ComboEx()\ListView\VScroll\Area\Height, BackColor)
  	  Box_(ComboEx()\ListView\VScroll\Thumb\X + OffsetPos, ComboEx()\ListView\VScroll\Thumb\Y, ComboEx()\ListView\VScroll\Thumb\Width - OffsetSize, ComboEx()\ListView\VScroll\Thumb\Height, ThumbColor, Round)

  	  StopDrawing()
	  EndIf  
  	
	EndProcedure  
	
	Procedure   DrawScrollBar_(ScrollBar.i=#False)
		Define.i OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		CalcScrollBar_()

  	; ----- thumb position -----
	  OffsetY = Round((ComboEx()\ListView\VScroll\Pos - ComboEx()\ListView\VScroll\minPos) * ComboEx()\ListView\VScroll\Factor, #PB_Round_Nearest)
	  ComboEx()\ListView\VScroll\Thumb\Y = ComboEx()\ListView\VScroll\Area\Y + OffsetY
		
		If StartDrawing(CanvasOutput(ComboEx()\ListView\Num)) ; Draw scrollbar background
      
		  DrawingMode(#PB_2DDrawing_Default)

	    If ScrollBar = #Vertical
		    If ComboEx()\ListView\VScroll\Hide = #False
		      Box_(ComboEx()\ListView\VScroll\X, ComboEx()\ListView\VScroll\Y, ComboEx()\ListView\VScroll\Width, GadgetHeight(ComboEx()\ListView\Num) - 2, ComboEx()\Color\Gadget)
		    EndIf
		  EndIf

		  StopDrawing()
		EndIf
		
		Select ScrollBar
  		Case #Vertical
		    DrawScrollButton_(#Forwards)
    		DrawScrollButton_(#Backwards)
    		DrawThumb_()
		  Case #Scrollbar_Up
		    DrawThumb_()
		    DrawScrollButton_(#Backwards)
		  Case #Scrollbar_Down
		    DrawThumb_()
		    DrawScrollButton_(#Forwards)
		EndSelect    

	EndProcedure
	
	
	Procedure   Arrow_(X.i, Y.i, Width.i, Height.i, Color.i)
	  Define.i aWidth, aHeight, aColor, imgHeight, imgWidth
	  Define.f Factor

	  If StartVectorDrawing(CanvasVectorOutput(ComboEx()\CanvasNum))

	    If IsImage(ComboEx()\Button\Image\Num)
	      
	      imgHeight = ComboEx()\Button\Height - 4
	      
	      If ComboEx()\Button\Image\Height <= imgHeight
          imgWidth  = ComboEx()\Button\Image\Height
          imgHeight = ComboEx()\Button\Image\Width
        Else
          Factor    = imgHeight / ComboEx()\Button\Image\Height
          imgWidth  = imgHeight * Factor
        EndIf
        
        X + ((ComboEx()\Button\Width  - imgWidth) / 2)
        Y + ((ComboEx()\Button\Height - imgHeight) / 2)
        
	      MovePathCursor(dpiX(X), dpiY(Y))
        DrawVectorImage(ImageID(ComboEx()\Button\Image\Num), 255, dpiX(imgWidth), dpiY(imgHeight))

	    Else
	      
	      aColor  = RGBA(Red(Color), Green(Color), Blue(Color), 255)
	      
  	    aWidth  = 8
        aHeight = 4
        
        X + ((Width  - aWidth) / 2)
        Y + ((Height - aHeight) / 2)
        
        MovePathCursor(dpiX(X), dpiY(Y))
  	    
        AddPathLine(dpiX(X + 4), dpiY(Y + aHeight))
        AddPathLine(dpiX(X + aWidth), dpiY(Y))
        VectorSourceColor(aColor)
        StrokePath(dpiX(1), #PB_Path_RoundCorner)
        
      EndIf
    
	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
	
	Procedure   CorrectButton_(X.i, Y.i, Radius.i, Height.i, Color.i, BackColor.i)
	  
    DrawingMode(#PB_2DDrawing_Default)
    Box_(X, Y, Radius, Height, BackColor)
    
    Line_(X, Y, Radius, 1, Color)
    Line_(X, Y, 1, Height, Color)
    Line_(X, Y + Height - 1, Radius, 1, Color)

  EndProcedure	
	
  Procedure   Button_()
    Define.i X, Y

    ComboEx()\Button\X = GadgetWidth(ComboEx()\CanvasNum) - #ButtonWidth
    
    DrawingMode(#PB_2DDrawing_Default)
    If ComboEx()\Button\State & #Click
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 20))
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, ComboEx()\Color\FocusBack)
      If ComboEx()\Radius : CorrectButton_(ComboEx()\Button\X, 0, ComboEx()\Radius, ComboEx()\Button\Height, ComboEx()\Color\FocusBack, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 20)) : EndIf
    ElseIf ComboEx()\Button\State & #Focus
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 10))
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, ComboEx()\Color\FocusBack)
      If ComboEx()\Radius : CorrectButton_(ComboEx()\Button\X, 0, ComboEx()\Radius, ComboEx()\Button\Height, ComboEx()\Color\FocusBack, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 10)) : EndIf
    Else
      Box_(ComboEx()\Button\X, 1, ComboEx()\Button\Width - 1, ComboEx()\Button\Height - 2, ComboEx()\Color\Back)
    EndIf  
  EndProcedure
  
  Procedure   CalcRowHeight()
    
    If StartDrawing(CanvasOutput(ComboEx()\ListView\Num))
      DrawingFont(ComboEx()\FontID)
      ComboEx()\ListView\RowHeight = TextHeight_("Abc") + 4
      StopDrawing()
    EndIf
    
  EndProcedure 
  
	Procedure.i CheckBox_(X.i, Y.i, Width.i, Height.i, boxWidth.i, FrontColor.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
    
    If boxWidth <= Width And boxWidth <= Height
      
      Y + ((Height - boxWidth) / 2)
      
      DrawingMode(#PB_2DDrawing_Default)
      Box_(X, Y, boxWidth, boxWidth, BackColor)
      
      LineColor = BlendColor_(FrontColor, BackColor, 60)
      
      If State & #Checked
        
        bColor = BlendColor_(LineColor, ComboEx()\Color\Button)
        
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
        
      ElseIf State & #Inbetween
        
        DrawingMode(#PB_2DDrawing_Default)
        Box_(X, Y, boxWidth, boxWidth, BlendColor_(LineColor, BackColor, 50))
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(X + 2, Y + 2, boxWidth - 4, boxWidth - 4, BlendColor_(LineColor, BackColor, 5))
      Box_(X + 1, Y + 1, boxWidth - 2, boxWidth - 2, BlendColor_(LineColor, BackColor, 25))
      Box_(X, Y, boxWidth, boxWidth, LineColor)
      
      ComboEx()\ListView\Item()\SubItem()\X = X
      ComboEx()\ListView\Item()\SubItem()\Y = Y
      ComboEx()\ListView\Item()\SubItem()\Size = boxWidth
      
    EndIf
    
  EndProcedure  

  Procedure   DrawListView_(ScrollBar.i = #False)
    Define.i X, Y, Width, Height, OffsetX, OffsetY, TextHeight, RowHeight
    Define.i ImgX, ImgY, imgHeight, imgWidth, boxSize
    Define.i FrontColor, BackColor, BorderColor
    Define.f Factor
    
    If ComboEx()\ListView\Hide : ProcedureReturn #False : EndIf 
    
    ;{ --- Color --- 
    FrontColor  = ComboEx()\Color\Front
    BackColor   = ComboEx()\Color\Back
    BorderColor = ComboEx()\Color\Border
    ;}
    
    If StartDrawing(CanvasOutput(ComboEx()\ListView\Num))
      
      Width  = ComboEx()\ListView\Area\Width
      Height = ComboEx()\ListView\Area\Height
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(0, 0, Width, Height, BackColor)
      ;}
      
      X = 0
      Y = 2
      
      DrawingFont(ComboEx()\FontID)
      
      TextHeight = TextHeight_("Abc")
      RowHeight  = TextHeight + 2
      OffsetY    = 1
      
      ; _____ ScrollBar _____
      ComboEx()\ListView\Offset = ComboEx()\ListView\VScroll\Pos
      
      ClipOutput_(0, 0, Width, Height) 
      
      ;{ _____ Rows _____
      ForEach ComboEx()\ListView\Item()
        
        OffSetX = 5
        
        If ListIndex(ComboEx()\ListView\Item()) < ComboEx()\ListView\Offset - 1
          ComboEx()\ListView\Item()\Y = 0
          Continue
        EndIf  
        
        If ComboEx()\ListView\Item()\Color <> #PB_Default
          FrontColor = ComboEx()\ListView\Item()\Color
        Else
          FrontColor = ComboEx()\Color\Front
        EndIf        
        
        If ComboEx()\ListView\Item()\Flags & #Image
          
          If IsImage(ComboEx()\ListView\Item()\Image\Num)
            
            ;{ Image Height
            imgHeight = RowHeight - 4
            
            If ComboEx()\ListView\Item()\Image\Height <= imgHeight
              imgWidth  = ComboEx()\ListView\Item()\Image\Height
              imgHeight = ComboEx()\ListView\Item()\Image\Width
            Else
              Factor    = imgHeight / ComboEx()\ListView\Item()\Image\Height
              imgWidth  = imgHeight * Factor
            EndIf ;}
            
            ;{ Horizontal Align
            If ComboEx()\ListView\Item()\Image\Flags & #Center
              ImgX = (Width - imgWidth) / 2
            ElseIf ComboEx()\ListView\Item()\Image\Flags & #Right
              If ComboEx()\ListView\Item()\String
                If Not ComboEx()\ListView\Item()\Flags & #Center And Not ComboEx()\ListView\Item()\Flags & #Right
                  ImgX = TextWidth_(ComboEx()\ListView\Item()\String) + 10
                Else
                  ImgX = Width - imgWidth - 5
                EndIf 
              Else  
                ImgX = Width - imgWidth - 5
              EndIf  
            Else
              ImgX = 5
              If Not ComboEx()\ListView\Item()\Flags & #Center And Not ComboEx()\ListView\Item()\Flags & #Right
                OffsetX + imgWidth + 5
              EndIf   
            EndIf ;}
            
            ;{ Vertical Align
            If ComboEx()\ListView\Item()\Image\Height < imgHeight
              imgY = (RowHeight - ComboEx()\ListView\Item()\Image\Height) / 2
            Else
              imgY = 2
            EndIf ;}

          Else  
            ComboEx()\ListView\Item()\Flags & ~#Image
          EndIf
          
        EndIf

        DrawingMode(#PB_2DDrawing_Transparent)
        If ComboEx()\ListView\State = ListIndex(ComboEx()\ListView\Item())
          Box_(X + 3, Y, Width - 6, RowHeight, ComboEx()\Color\FocusBack)
          DrawText_(X + OffsetX, Y + OffsetY, ComboEx()\ListView\Item()\String, ComboEx()\Color\FocusText)
        Else
          If ComboEx()\ListView\Focus = ListIndex(ComboEx()\ListView\Item())
            Box_(X + 3, Y, Width - 6, RowHeight, BlendColor_(ComboEx()\Color\FocusBack, BackColor, 10))
          EndIf
          DrawText_(X  + OffsetX, Y + OffsetY, ComboEx()\ListView\Item()\String, FrontColor)
        EndIf

        ComboEx()\ListView\Item()\Y = Y
        
        If ComboEx()\ListView\Item()\Flags & #Image
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          DrawImage_(ImageID(ComboEx()\ListView\Item()\Image\Num), X + imgX, Y + imgY, imgWidth, imgHeight)  
        EndIf 

        Y + RowHeight
        
        If ComboEx()\Flags & #MultiSelect ;{ MultiSelect enabled
          
          If ListSize(ComboEx()\ListView\Item()\SubItem())
            boxSize = TextHeight - 2
            OffSetX = boxSize + 10
            ForEach ComboEx()\ListView\Item()\SubItem()
              CheckBox_(5, Y, Width, RowHeight, boxSize, FrontColor, BackColor, ComboEx()\ListView\Item()\SubItem()\State)
              DrawingMode(#PB_2DDrawing_Transparent)
              DrawText_(X + OffsetX, Y + OffsetY, ComboEx()\ListView\Item()\SubItem()\String, FrontColor)
              Y + RowHeight
            Next
          EndIf
          ;}
        EndIf
        
        If Y > Y + Height : Break : EndIf
      Next
      
      ComboEx()\ListView\RowHeight = RowHeight
      
      UnclipOutput_() 
      ;}

      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(0, 0, GadgetWidth(ComboEx()\ListView\Num), GadgetHeight(ComboEx()\ListView\Num), BorderColor)
      ;}
      
      StopDrawing()
    EndIf
    
    DrawScrollBar_(ScrollBar)
    
  EndProcedure


  Procedure   Draw_()
    Define.i X, Y, Height, Width, startX, CursorX
    Define.s Text, Word, strgPart
    Define.i p, FrontColor, BackColor, BorderColor, CursorColor
    
    If ComboEx()\Hide : ProcedureReturn #False : EndIf

    If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
      
      FrontColor  = ComboEx()\Color\Front
      BorderColor = ComboEx()\Color\Border
      
      If ComboEx()\Flags & #Editable
        BackColor = ComboEx()\Color\Back
      Else
        If ComboEx()\Button\State & #Click
          BackColor   = BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 20)
          BorderColor = ComboEx()\Color\FocusBack
        ElseIf ComboEx()\Button\State & #Focus  
          BackColor = BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 10)
          BorderColor = ComboEx()\Color\FocusBack
        Else  
          BackColor = ComboEx()\Color\Button
        EndIf
      EndIf
      
      If ComboEx()\Disable
        FrontColor  = ComboEx()\Color\DisableFront
        BackColor   = BlendColor_(ComboEx()\Color\DisableBack, ComboEx()\Color\Gadget, 10)
        BorderColor = ComboEx()\Color\DisableBack
      EndIf  

      Height = GadgetHeight(ComboEx()\CanvasNum)
      Width  = GadgetWidth(ComboEx()\CanvasNum)

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(0, 0, Width, Height, BackColor)   
      ;}
      
      ComboEx()\Button\X      = Width - #ButtonWidth
      ComboEx()\Button\Width  = #ButtonWidth
      ComboEx()\Button\Height = Height
      
      Width - ComboEx()\Button\Width - 3
      ComboEx()\Size\Text = Width

      DrawingFont(ComboEx()\FontID)

      ;{ _____ Text _____
      If ComboEx()\Text
        
        Text = ComboEx()\Text

        X = GetOffsetX_(Text, Width, ComboEx()\Padding)
        Y = (Height - TextHeight_(Text)) / 2
        
        ;{ TextWidth > Width
        If ComboEx()\Flags & #Editable
        
          CursorX = X + TextWidth_(Left(Text, ComboEx()\Cursor\Pos))
          If CursorX > Width
            Text = Left(Text, ComboEx()\Cursor\Pos)
            For p = Len(Text) To 0 Step -1
              If X + TextWidth_(Right(Text, p)) < Width
                Text = Right(Text, p)
                Break  
              EndIf 
            Next 
          EndIf
          
        Else
          
          CursorX = X + TextWidth_(Text)
          If CursorX > Width
            For p = Len(Text) To 0 Step -1
              If X + TextWidth_(Right(Text, p)) <= Width
                Text = Right(Text, p)
                Break  
              EndIf 
            Next 
          EndIf
          
        EndIf ;}
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText_(X, Y, Text, FrontColor)
        ComboEx()\OffSetX = X

      Else
        
        If ComboEx()\Flags & #Center
          X = Width / 2
        ElseIf ComboEx()\Flags & #Right
          X = Width - ComboEx()\Padding
        Else
          X = ComboEx()\Padding
        EndIf
        
        Y = (Height - TextHeight_("X")) / 2  
        
      EndIf
      ;}
      
      ;{ _____ Selection ______
      If ComboEx()\Flags & #Editable
        
        If ComboEx()\Selection\Flag = #Selected
          
          If ComboEx()\Selection\Pos1 >  ComboEx()\Selection\Pos2
            startX   = CursorX_(ComboEx()\Selection\Pos2)
            strgPart = StringSegment_(Text, ComboEx()\Selection\Pos2 + 1, ComboEx()\Selection\Pos1)
          Else
            startX   = CursorX_(ComboEx()\Selection\Pos1)
            strgPart = StringSegment_(Text, ComboEx()\Selection\Pos1 + 1, ComboEx()\Selection\Pos2)
          EndIf
          
          ComboEx()\Cursor\Pos = ComboEx()\Selection\Pos2
          
          DrawingMode(#PB_2DDrawing_Default)
          DrawText_(X + startX, Y, strgPart, ComboEx()\Color\HighlightText, ComboEx()\Color\Highlight)
  
        EndIf
        
      EndIf ;}
      
      ;{ _____ Cursor _____
      If ComboEx()\Flags & #Editable
        
        If ComboEx()\Cursor\Pos
          X + TextWidth_(Left(Text, ComboEx()\Cursor\Pos))
        EndIf
        ComboEx()\Cursor\Height = TextHeight_("X")
        ComboEx()\Cursor\X = X
        ComboEx()\Cursor\Y = Y
        If ComboEx()\Cursor\Pause = #False
          Line_(ComboEx()\Cursor\X, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, ComboEx()\Color\Cursor)
        EndIf
        
      EndIf
      ;}

      ;{ _____ Border ____
      If Not ComboEx()\Flags & #Borderless
        DrawingMode(#PB_2DDrawing_Outlined)
        Box_(0, 0, GadgetWidth(ComboEx()\CanvasNum), Height, BorderColor)
      EndIf
      ;}
      
      If ComboEx()\Flags & #Editable : Button_() : EndIf
      
      StopDrawing()
    EndIf
    
    Arrow_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, ComboEx()\Color\Front)
  
  EndProcedure

  ;- ============================================================================
  ;-   Module - ListView
  ;- ============================================================================   
  
  Declare _AutoScroll()
  
	Procedure.i ScrollBar()

    ComboEx()\ListView\VScroll\CursorPos      = #PB_Default
    ComboEx()\ListView\VScroll\Buttons\fState = #PB_Default
    ComboEx()\ListView\VScroll\Buttons\bState = #PB_Default

    ComboEx()\ListView\Scrollbar\Size       = #ScrollBarSize
    ComboEx()\ListView\Scrollbar\TimerDelay = #TimerDelay
  
    ; ----- Styles -----
    If ComboEx()\Flags & #Style_Win11      : ComboEx()\ListView\Scrollbar\Flags | #Style_Win11      : EndIf
    If ComboEx()\Flags & #Style_RoundThumb : ComboEx()\ListView\Scrollbar\Flags | #Style_RoundThumb : EndIf
    
    CompilerIf #PB_Compiler_Version >= 600
      If OSVersion()  = #PB_OS_Windows_11  : ComboEx()\ListView\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerElse
      If OSVersion() >= #PB_OS_Windows_10 : ComboEx()\ListView\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerEndIf  

    ;{ ----- Colors -----
    ComboEx()\ListView\Scrollbar\Color\Front  = $C8C8C8
    ComboEx()\ListView\Scrollbar\Color\Back   = $F0F0F0
	  ComboEx()\ListView\Scrollbar\Color\Button = $F0F0F0
	  ComboEx()\ListView\Scrollbar\Color\Focus  = $D77800
	  ComboEx()\ListView\Scrollbar\Color\Hover  = $666666
	  ComboEx()\ListView\Scrollbar\Color\Arrow  = $696969
	  
	  CompilerSelect #PB_Compiler_OS
		  CompilerCase #PB_OS_Windows
				ComboEx()\ListView\Scrollbar\Color\Front  = GetSysColor_(#COLOR_SCROLLBAR)
				ComboEx()\ListView\Scrollbar\Color\Back   = GetSysColor_(#COLOR_MENU)
				ComboEx()\ListView\Scrollbar\Color\Button = GetSysColor_(#COLOR_BTNFACE)
				ComboEx()\ListView\Scrollbar\Color\Focus  = GetSysColor_(#COLOR_MENUHILIGHT)
				ComboEx()\ListView\Scrollbar\Color\Hover  = GetSysColor_(#COLOR_ACTIVEBORDER)
				ComboEx()\ListView\Scrollbar\Color\Arrow  = GetSysColor_(#COLOR_GRAYTEXT)
			CompilerCase #PB_OS_MacOS
				ComboEx()\ListView\Scrollbar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ComboEx()\ListView\Scrollbar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ComboEx()\ListView\Scrollbar\Color\Button = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ComboEx()\ListView\Scrollbar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				ComboEx()\ListView\Scrollbar\Color\Hover  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ComboEx()\ListView\Scrollbar\Color\Arrow  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
			CompilerCase #PB_OS_Linux

		CompilerEndSelect
		
		If ComboEx()\ListView\Scrollbar\Flags & #Style_Win11
		  ComboEx()\ListView\Scrollbar\Color\Hover = $666666
		  ComboEx()\ListView\Scrollbar\Color\Focus = $8C8C8C
		EndIf   
    ;}

		CalcScrollBar_()

	EndProcedure
	
  Procedure   OpenListView_()
    Define.i X, Y, RowsHeight, Width, Height, SubItems, PageRows
    
    X      = GadgetX(ComboEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
    Y      = GadgetY(ComboEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
    Width  = GadgetWidth(ComboEx()\CanvasNum)
    Height = ComboEx()\ListView\Height
    
    CalcRowHeight()
    
    If ComboEx()\Flags & #MultiSelect
      
      ForEach ComboEx()\ListView\Item()
        SubItems = ListSize(ComboEx()\ListView\Item()\SubItem())
        If SubItems
          RowsHeight + (SubItems * ComboEx()\ListView\RowHeight)
        EndIf  
        RowsHeight + ComboEx()\ListView\RowHeight 
      Next
      
    Else  
      RowsHeight = ListSize(ComboEx()\ListView\Item()) * ComboEx()\ListView\RowHeight 
    EndIf
  
    If RowsHeight < Height : Height = RowsHeight : EndIf

    SetGadgetData(ComboEx()\ListView\Num, ComboEx()\CanvasNum)
    
    ResizeWindow(ComboEx()\ListView\Window, X, Y + GadgetHeight(ComboEx()\CanvasNum) - 1, Width, Height)
    ResizeGadget(ComboEx()\ListView\Num, 0, 0, Width, Height)

	  BindEvent(#PB_Event_Timer, @_AutoScroll(), ComboEx()\ListView\Window)

    SetActiveGadget(ComboEx()\ListView\Num)
    
    ComboEx()\ListView\Focus = #PB_Default
    ComboEx()\ListView\Hide  = #False
    
    ComboEx()\ListView\VScroll\Minimum    = 0
    ComboEx()\ListView\VScroll\Maximum    = ListSize(ComboEx()\ListView\Item())
    ComboEx()\ListView\VScroll\PageLength = Height / ComboEx()\ListView\RowHeight
    
    If RowsHeight > Height
      ComboEx()\ListView\VScroll\Hide = #False
    Else
      ComboEx()\ListView\VScroll\Hide = #True
    EndIf  
    
    CalcScrollRange_()
    
    DrawListView_(#Vertical)
    
    HideWindow(ComboEx()\ListView\Window, #False)
  EndProcedure
  
  Procedure   CloseListView_()
    
    HideWindow(ComboEx()\ListView\Window, #True)
    
    UnbindEvent(#PB_Event_Timer, @_AutoScroll(), ComboEx()\ListView\Window)
    
    ComboEx()\ListView\Hide  = #True
    ComboEx()\Button\State & ~#Click

    Draw_()
    
  EndProcedure  
  
  ;- ============================================================================
  ;-   Module - Events
  ;- ============================================================================   
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ComboEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ComboEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        ;If ModuleEx::ThemeGUI\ScrollBar : ComboEx()\ScrollBar\Flags = ModuleEx::ThemeGUI\ScrollBar : EndIf 
        
        ComboEx()\Color\Front         = ModuleEx::ThemeGUI\FrontColor
        ComboEx()\Color\Back          = ModuleEx::ThemeGUI\BackColor
        ComboEx()\Color\FocusText     = ModuleEx::ThemeGUI\Focus\FrontColor
        ComboEx()\Color\FocusBack     = ModuleEx::ThemeGUI\Focus\BackColor
        ComboEx()\Color\Border        = ModuleEx::ThemeGUI\BorderColor
        ComboEx()\Color\Gadget        = ModuleEx::ThemeGUI\GadgetColor
        ComboEx()\Color\Cursor        = ModuleEx::ThemeGUI\FrontColor
        ComboEx()\Color\Button        = ModuleEx::ThemeGUI\Button\BackColor
        ComboEx()\Color\HighlightText = ModuleEx::ThemeGUI\Focus\FrontColor
        ComboEx()\Color\Highlight     = ModuleEx::ThemeGUI\Focus\BackColor
        ComboEx()\Color\DisableFront  = ModuleEx::ThemeGUI\Disable\FrontColor
        ComboEx()\Color\DisableBack   = ModuleEx::ThemeGUI\Disable\BackColor
        
        ComboEx()\ListView\ScrollBar\Color\Front        = ModuleEx::ThemeGUI\FrontColor
			  ComboEx()\ListView\ScrollBar\Color\Back         = ModuleEx::ThemeGUI\BackColor
			  ComboEx()\ListView\ScrollBar\Color\Border       = ModuleEx::ThemeGUI\BorderColor
			  ComboEx()\ListView\ScrollBar\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
			  ComboEx()\ListView\ScrollBar\Color\Focus        = ModuleEx::ThemeGUI\Focus\BackColor
        ComboEx()\ListView\ScrollBar\Color\Button       = ModuleEx::ThemeGUI\Button\BackColor
        ComboEx()\ListView\ScrollBar\Color\ScrollBar    = ModuleEx::ThemeGUI\ScrollbarColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf   
  
  
  Procedure _AutoScroll()
    Define.i X, Y
    
    LockMutex(Mutex)
    
    ForEach ComboEx()
      
      If ComboEx()\ListView\VScroll\Timer ;{ Vertical Scrollbar
        
        If ComboEx()\ListView\VScroll\Delay
          ComboEx()\ListView\VScroll\Delay - 1
          Continue
        EndIf  
        
        Select ComboEx()\ListView\VScroll\Timer
          Case #Scrollbar_Up
            SetThumbPosY_(ComboEx()\ListView\VScroll\Pos - 1)
          Case #Scrollbar_Down
            SetThumbPosY_(ComboEx()\ListView\VScroll\Pos + 1)
  			EndSelect
  			
  			DrawListView_(#Vertical)
  			;}
      EndIf   
      
    Next
    
    UnlockMutex(Mutex)
    
  EndProcedure
  
  Procedure _CursorDrawing() 
    Define.i BackColor
    Define.i WindowNum = EventWindow()

    ForEach ComboEx()
      
      BackColor = ComboEx()\Color\Back
      If ComboEx()\Disable : BackColor = BlendColor_(ComboEx()\Color\DisableBack, ComboEx()\Color\Gadget, 10) : EndIf
      
      If ComboEx()\Cursor\Pause = #False

        ComboEx()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          If ComboEx()\Cursor\State
            Line_(ComboEx()\Cursor\X, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, ComboEx()\Color\Cursor)
          Else
            Line_(ComboEx()\Cursor\X, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, BackColor)
          EndIf
          StopDrawing()
        EndIf
        
      ElseIf ComboEx()\Cursor\State

        If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          Line_(ComboEx()\Cursor\X - 1, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, BackColor)
          StopDrawing()
        EndIf
      
      EndIf
      
    Next
    
  EndProcedure  
  

  Procedure _ListViewHandler()
    Define.i GNum, X, Y, dX, dY, Backwards, Forwards, Thumb, CursorPos, Delta
    Define.i GadgetNum = EventGadget()
    
    GNum = GetGadgetData(GadgetNum)
    If FindMapElement(ComboEx(), Str(GNum))

      If GadgetNum = ComboEx()\ListView\Num 
        
       	dX = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
  			dY = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)
  			
  			X = DesktopUnscaledX(dX)
  			Y = DesktopUnscaledY(dY)

        Select EventType()
          Case #PB_EventType_LeftButtonDown ;{ Left Button Down
            
            ;{ Vertical Scrollbar
    			  If ComboEx()\ListView\VScroll\Hide = #False
    			    
    			    If dX > dpiX(ComboEx()\ListView\VScroll\X) And dX < dpiX(ComboEx()\ListView\VScroll\X + ComboEx()\ListView\VScroll\Width)
      			    If dY > dpiY(ComboEx()\ListView\VScroll\Y) And dY < dpiY(ComboEx()\ListView\VScroll\Y + ComboEx()\ListView\VScroll\Height)
    			    
          			  ComboEx()\ListView\VScroll\CursorPos = #PB_Default
          			  
          			  If ComboEx()\ListView\VScroll\Focus
          			    
          			    If dY > dpiY(ComboEx()\ListView\VScroll\Buttons\bY) And dY < dpiY(ComboEx()\ListView\VScroll\Buttons\bY + ComboEx()\ListView\VScroll\Buttons\Height)
          
          			      If ComboEx()\ListView\VScroll\Buttons\bState <> #Click
          			        ; --- Backwards Button ---
            			      ComboEx()\ListView\VScroll\Delay = ComboEx()\ListView\Scrollbar\TimerDelay
            			      ComboEx()\ListView\VScroll\Timer = #Scrollbar_Up
            			      ComboEx()\ListView\VScroll\Buttons\bState = #Click
            			      DrawScrollButton_(#Backwards)
            			    EndIf
            			    
          			    ElseIf dY > dpiY(ComboEx()\ListView\VScroll\Buttons\fY) And dY < dpiY(ComboEx()\ListView\VScroll\Buttons\fY + ComboEx()\ListView\VScroll\Buttons\Height)
          			      
          			      ; --- Forwards Button ---
            			    If ComboEx()\ListView\VScroll\Buttons\fState <> #Click
            			      ComboEx()\ListView\VScroll\Delay = ComboEx()\ListView\Scrollbar\TimerDelay
            			      ComboEx()\ListView\VScroll\Timer = #Scrollbar_Down
            			      ComboEx()\ListView\VScroll\Buttons\fState = #Click
            			      DrawScrollButton_(#Forwards)
            			    EndIf
          			      
          			    ElseIf  dY > dpiY(ComboEx()\ListView\VScroll\Thumb\Y) And dY < dpiY(ComboEx()\ListView\VScroll\Thumb\Y + ComboEx()\ListView\VScroll\Thumb\Height)
          			      
          			      ; --- Thumb Button ---
            			    If ComboEx()\ListView\VScroll\Thumb\State <> #Click
            			      ComboEx()\ListView\VScroll\Thumb\State = #Click
            			      ComboEx()\ListView\VScroll\CursorPos = Y
            			      DrawThumb_()
            			    EndIf
          			      
          			    EndIf  
          
          			  EndIf
          			  
          			  ProcedureReturn #True
          			EndIf
          		EndIf
          		
      			EndIf  
    			  ;}
          
            ForEach ComboEx()\ListView\Item()

              If ComboEx()\Flags & #MultiSelect ;{ MultiSelect enabled
                ForEach ComboEx()\ListView\Item()\SubItem()
                  If Y >= ComboEx()\ListView\Item()\SubItem()\Y And Y <= ComboEx()\ListView\Item()\SubItem()\Y + ComboEx()\ListView\Item()\SubItem()\Size
                    If X >= ComboEx()\ListView\Item()\SubItem()\X And X <= ComboEx()\ListView\Item()\SubItem()\X + ComboEx()\ListView\Item()\SubItem()\Size
                      If ComboEx()\ListView\Item()\SubItem()\State & #Checked
                        ComboEx()\ListView\Item()\SubItem()\State & ~#Checked
                      Else
                        ComboEx()\ListView\Item()\SubItem()\State | #Checked
                      EndIf
                      DrawListView_()
                      ProcedureReturn #True
                    EndIf
                  EndIf
                Next ;}
              EndIf
              
              If Y >= ComboEx()\ListView\Item()\Y And Y <= ComboEx()\ListView\Item()\Y + ComboEx()\ListView\RowHeight
                ComboEx()\ListView\State = ListIndex(ComboEx()\ListView\Item())
                DrawListView_()
                ProcedureReturn #True
              EndIf
              
            Next 
            ;}
          Case #PB_EventType_LeftButtonUp   ;{ Left Button Up
            
            ;{ Vertical Scrollbar
            If ComboEx()\ListView\VScroll\Hide = #False
              
              If dX > dpiX(ComboEx()\ListView\VScroll\X) And dX < dpiX(ComboEx()\ListView\VScroll\X + ComboEx()\ListView\VScroll\Width)
      			    If dY > dpiY(ComboEx()\ListView\VScroll\Y) And dY < dpiY(ComboEx()\ListView\VScroll\Y + ComboEx()\ListView\VScroll\Height)
              
          			  ComboEx()\ListView\VScroll\CursorPos = #PB_Default
          			  ComboEx()\ListView\VScroll\Timer     = #False
          			  
          			  If ComboEx()\ListView\VScroll\Focus
          			    
            			  If dY > dpiY(ComboEx()\ListView\VScroll\Buttons\bY) And  dY < dpiY(ComboEx()\ListView\VScroll\Buttons\bY + ComboEx()\ListView\VScroll\Buttons\Height)
            			    ; --- Backwards Button ---
            			    SetThumbPosY_(ComboEx()\ListView\VScroll\Pos - 1)
            			    DrawListView_(#Vertical)
            			  ElseIf dY > dpiY(ComboEx()\ListView\VScroll\Buttons\fY) And  dY < dpiY(ComboEx()\ListView\VScroll\Buttons\fY + ComboEx()\ListView\VScroll\Buttons\Height)
            			    ; --- Forwards Button ---
            			    SetThumbPosY_(ComboEx()\ListView\VScroll\Pos + 1)
            			    DrawListView_(#Vertical)
            			  ElseIf dY > dpiY(ComboEx()\ListView\VScroll\Area\Y) And dY < dpiY(ComboEx()\ListView\VScroll\Thumb\Y)
            			    ; --- Page up ---
            			    SetThumbPosY_(ComboEx()\ListView\VScroll\Pos - ComboEx()\ListView\VScroll\PageLength)
            			    DrawListView_(#Vertical)
            			  ElseIf dY > dpiY(ComboEx()\ListView\VScroll\Thumb\Y + ComboEx()\ListView\VScroll\Thumb\Height) And dY < dpiY(ComboEx()\ListView\VScroll\Area\Y + ComboEx()\ListView\VScroll\Area\Height)
            			    ; --- Page down ---
            			    SetThumbPosY_(ComboEx()\ListView\VScroll\Pos + ComboEx()\ListView\VScroll\PageLength)
            			    DrawListView_(#Vertical)
            			  EndIf
              			
            			EndIf 
            			
            			ProcedureReturn #True
            		EndIf
            	EndIf
            	
        		EndIf	 ;}
    		
            ForEach ComboEx()\ListView\Item()
              If Y >= ComboEx()\ListView\Item()\Y And Y <= ComboEx()\ListView\Item()\Y + ComboEx()\ListView\RowHeight
                If ComboEx()\ListView\State <> ListIndex(ComboEx()\ListView\Item())
                  ComboEx()\ListView\State = #PB_Default
                  ProcedureReturn  #False
                EndIf
                ComboEx()\Text = ComboEx()\ListView\Item()\String
                ComboEx()\ListView\State = ListIndex(ComboEx()\ListView\Item())
                DrawListView_()
                CloseListView_()
                PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change, ComboEx()\ListView\State)
                PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change, ComboEx()\ListView\State)
                ProcedureReturn #True
              EndIf
            Next 
            ;}
          Case #PB_EventType_MouseMove      ;{ Mouse Move
            
            ;{ Vertical Scrollbar
    			  ComboEx()\ListView\VScroll\Focus = #False
    			  
    			  Backwards = ComboEx()\ListView\VScroll\Buttons\bState
    			  Forwards  = ComboEx()\ListView\VScroll\Buttons\fState
    			  Thumb     = ComboEx()\ListView\VScroll\Thumb\State
    			  
    			  If dX > dpiX(ComboEx()\ListView\VScroll\X) And dX < dpiX(ComboEx()\ListView\VScroll\X + ComboEx()\ListView\VScroll\Width)
    			    If dY > dpiY(ComboEx()\ListView\VScroll\Y) And dY < dpiY(ComboEx()\ListView\VScroll\Y + ComboEx()\ListView\VScroll\Height)
    
    			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
    			      
    			      ; --- Focus Scrollbar ---  
    			      ComboEx()\ListView\VScroll\Buttons\bState = #Focus
    			      ComboEx()\ListView\VScroll\Buttons\fState = #Focus
    			      ComboEx()\ListView\VScroll\Thumb\State    = #Focus
    			      
    			      ; --- Hover Buttons & Thumb ---
    			      If dY > dpiY(ComboEx()\ListView\VScroll\Buttons\bY) And dY < dpiY(ComboEx()\ListView\VScroll\Buttons\bY + ComboEx()\ListView\VScroll\Buttons\Height)
    			        
    			        ComboEx()\ListView\VScroll\Buttons\bState = #Hover
    			        
    			      ElseIf dY > dpiY(ComboEx()\ListView\VScroll\Buttons\fY) And dY < dpiY(ComboEx()\ListView\VScroll\Buttons\fY + ComboEx()\ListView\VScroll\Buttons\Height)
    			        
    			        ComboEx()\ListView\VScroll\Buttons\fState = #Hover
    
    			      ElseIf dY > dpiY(ComboEx()\ListView\VScroll\Thumb\Y) And dY < dpiY(ComboEx()\ListView\VScroll\Thumb\Y + ComboEx()\ListView\VScroll\Thumb\Height)
    			        
    			        ComboEx()\ListView\VScroll\Thumb\State = #Hover
    			        
    			        ;{ --- Move thumb with cursor 
    			        If ComboEx()\ListView\VScroll\CursorPos <> #PB_Default
    			          
    			          CursorPos = ComboEx()\ListView\VScroll\Pos
    			          
      			        ComboEx()\ListView\VScroll\Pos       = GetThumbPosY_(Y)
      			        ComboEx()\ListView\VScroll\CursorPos = Y
      			        
      			        If CursorPos <> ComboEx()\ListView\VScroll\Pos
      			          DrawListView_(#Vertical)
      			        EndIf
      			        
      			      EndIf ;}
    
      			    EndIf   
      			    
      			    ComboEx()\ListView\VScroll\Focus = #True
      			    
      			    If Backwards <> ComboEx()\ListView\VScroll\Buttons\bState : DrawScrollButton_(#Backwards) : EndIf 
                If Forwards  <> ComboEx()\ListView\VScroll\Buttons\fState : DrawScrollButton_(#Forwards)  : EndIf 
                If Thumb     <> ComboEx()\ListView\VScroll\Thumb\State    : DrawThumb_()                  : EndIf 
                
                ProcedureReturn #True
        			EndIf
        		EndIf
        		
        		If Not ComboEx()\ListView\VScroll\Focus
    
              ComboEx()\ListView\VScroll\Buttons\bState = #False
              ComboEx()\ListView\VScroll\Buttons\fState = #False
              ComboEx()\ListView\VScroll\Thumb\State    = #False
              
              ComboEx()\ListView\VScroll\Timer = #False
              
            EndIf   
            
            If Backwards <> ComboEx()\ListView\VScroll\Buttons\bState : DrawScrollButton_(#Backwards) : EndIf 
            If Forwards  <> ComboEx()\ListView\VScroll\Buttons\fState : DrawScrollButton_(#Forwards)  : EndIf 
            If Thumb     <> ComboEx()\ListView\VScroll\Thumb\State    : DrawThumb_()                  : EndIf 
            
            ComboEx()\ListView\VScroll\CursorPos = #PB_Default
    			  ;}

            ForEach ComboEx()\ListView\Item() ;{ List Items
              If Y >= ComboEx()\ListView\Item()\Y And Y <= ComboEx()\ListView\Item()\Y + ComboEx()\ListView\RowHeight
                ComboEx()\ListView\Focus = ListIndex(ComboEx()\ListView\Item())
                DrawListView_()
                ProcedureReturn #True
              EndIf ;}
            Next 
            ;}
          Case #PB_EventType_MouseLeave     ;{ Mouse Leave
            
            ComboEx()\ListView\VScroll\Buttons\bState = #False
            ComboEx()\ListView\VScroll\Buttons\fState = #False
            ComboEx()\ListView\VScroll\Thumb\State    = #False
            ComboEx()\ListView\VScroll\CursorPos      = #PB_Default

            ComboEx()\ListView\Focus = #PB_Default
            
            DrawListView_(#Vertical)
            
            ProcedureReturn #True
            ;}
          Case #PB_EventType_MouseWheel     ;{ Mouse Wheel
            
            If ComboEx()\ListView\VScroll\Hide = #False
              Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
              SetThumbPosY_(ComboEx()\ListView\VScroll\Pos - Delta)
              DrawListView_(#Vertical)
            EndIf 
            ;}
        EndSelect 
        
      EndIf
   
    EndIf
    
  EndProcedure
  
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\Flags & #Editable
        ComboEx()\State | #Focus
        Draw_()
        
        ComboEx()\Cursor\State = #False
        ComboEx()\Cursor\Pause = #False
        
        PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Focus)
      EndIf
    
    EndIf
    
  EndProcedure  
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\Flags & #Editable
        ComboEx()\Cursor\Pause = #True
        
        ComboEx()\State & ~#Focus
        ComboEx()\Button\State & ~#Focus

        Draw_()
        
        PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_LostFocus)
      EndIf
      
    EndIf
    
  EndProcedure    
  
  
  Procedure _InputHandler()
    Define.s Char$
    Define.i Char
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))

      If ComboEx()\State & #Focus And ComboEx()\Flags & #Editable
        
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)

        If Char >= 32
          
          If ComboEx()\Selection\Flag = #Selected
            DeleteSelection_()
          EndIf
          
          Char$ =  Chr(Char)
          If ComboEx()\Flags & #UpperCase : Char$ = UCase(Char$) : EndIf
          If ComboEx()\Flags & #LowerCase : Char$ = LCase(Char$) : EndIf
          

          ComboEx()\Cursor\Pos + 1
          ComboEx()\Text = InsertString(ComboEx()\Text, Char$, ComboEx()\Cursor\Pos)
          
          PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
  EndProcedure   
  
  Procedure _KeyDownHandler()
    
    Define.i Key, Modifier
    Define.s Text
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\State & #Focus
        
        Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
        Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
        
        Select Key
          Case #PB_Shortcut_Left      ;{ Cursor left
            If Modifier & #PB_Canvas_Shift
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = ComboEx()\Cursor\Pos
                ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos - 1
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 - 1
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
              If ComboEx()\Cursor\Pos > 0
                ComboEx()\Cursor\Pos - 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = GetWordEnd_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Pos2 = GetWordStart_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 = GetWordStart_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
            Else
              
              If ComboEx()\Cursor\Pos > 0
                ComboEx()\Cursor\Pos - 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_Right     ;{ Cursor right
            If Modifier & #PB_Canvas_Shift
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = ComboEx()\Cursor\Pos
                ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos + 1
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 + 1
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
              If ComboEx()\Cursor\Pos < Len(ComboEx()\Text)
                ComboEx()\Cursor\Pos + 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = GetWordStart_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Pos2 = GetWordEnd_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 = GetWordEnd_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
            Else

              If ComboEx()\Cursor\Pos < Len(ComboEx()\Text)
                ComboEx()\Cursor\Pos + 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_End       ;{ Cursor end of chars
            ComboEx()\Cursor\Pos = Len(ComboEx()\Text)
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Home      ;{ Cursor position 0
            ComboEx()\Cursor\Pos = 0
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Back      ;{ Delete Back
            If ComboEx()\Flags & #Editable
              If ComboEx()\Selection\Flag = #Selected
                DeleteSelection_()
                RemoveSelection_()
              Else
                If ComboEx()\Cursor\Pos > 0
                  ComboEx()\Text = DeleteStringPart_(ComboEx()\Text, ComboEx()\Cursor\Pos) 
                  ComboEx()\Cursor\Pos - 1
                EndIf
                RemoveSelection_()
              EndIf 
              PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            EndIf ;}
          Case #PB_Shortcut_Delete    ;{ Delete / Cut (Shift)
            If Modifier & #PB_Canvas_Shift ;{ Cut selected text
              Cut_()
              ;}
            Else                           ;{ Delete text
              If ComboEx()\Flags & #Editable
                If ComboEx()\Selection\Flag = #Selected
                  DeleteSelection_()
                  RemoveSelection_()
                Else
                  If ComboEx()\Cursor\Pos < Len(ComboEx()\Text) 
                    ComboEx()\Text = DeleteStringPart_(ComboEx()\Text, ComboEx()\Cursor\Pos + 1)
                    RemoveSelection_()
                  EndIf
                EndIf
              EndIf ;}
            EndIf
            PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            ;} 
          Case #PB_Shortcut_Insert    ;{ Copy (Ctrl) / Paste (Shift)
            If Modifier & #PB_Canvas_Shift
              Paste_()
              PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            ElseIf Modifier & #PB_Canvas_Control
              Copy_()
            EndIf ;}  
          Case #PB_Shortcut_A         ;{ Ctrl-A (Select all)
            If Modifier & #PB_Canvas_Control
              ComboEx()\Cursor\Pos = Len(ComboEx()\Text)
              ComboEx()\Selection\Pos1 = 0
              ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos
              ComboEx()\Selection\Flag = #Selected
            EndIf ;}
          Case #PB_Shortcut_C         ;{ Copy   (Ctrl)  
            If Modifier & #PB_Canvas_Control
              Copy_()
            EndIf  
            ;}
          Case #PB_Shortcut_X         ;{ Cut    (Ctrl) 
            If Modifier & #PB_Canvas_Control
              Cut_()
              PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            EndIf
            ;}
          Case #PB_Shortcut_D         ;{ Ctrl-D (Delete selection)
            If ComboEx()\Flags & #Editable
              If Modifier & #PB_Canvas_Control
                DeleteSelection_()
                PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              EndIf 
            EndIf ;} 
          Case #PB_Shortcut_V         ;{ Paste  (Ctrl) 
            If ComboEx()\Flags & #Editable
              If Modifier & #PB_Canvas_Control
                Paste_()
                PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              EndIf
            EndIf ;} 
          Case #PB_Shortcut_Return    ;{ Return

            ;}
          Case #PB_Shortcut_Tab       ;{ Tabulator
 
            ;}
        EndSelect
        
       Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure _RightClickHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      If IsWindow(ComboEx()\Window\Num)
        DisplayPopupMenu(ComboEx()\PopupNum, WindowID(ComboEx()\Window\Num))
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonDownHandler()
    Define.i dX
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)

      If ComboEx()\Flags & #Editable
      
        If ComboEx()\Mouse = #Mouse_Move
          ComboEx()\Cursor\Pos = CursorPos_(dX)
        EndIf
        
      EndIf

      If ComboEx()\Button\State & #Focus
        ComboEx()\Button\State | #Click
      EndIf
      
      If ComboEx()\Selection\Flag = #Selected
        RemoveSelection_()
      EndIf
      
      ComboEx()\State | #Focus
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftButtonUpHandler()
    Define.i dX
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If ComboEx()\Flags & #Editable ;{ editable ComboBox
        
        If dX > dpiX(ComboEx()\Button\X)
          
          If ComboEx()\ListView\Hide
            OpenListView_()
          Else
            CloseListView_()
            PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
          EndIf  
          
        Else 
  
          If ComboEx()\Mouse = #Mouse_Select
            ComboEx()\Cursor\Pos     = CursorPos_(dX)
            ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos
            ComboEx()\Mouse = #Mouse_Move
          EndIf
          
        EndIf 
        ;}
      Else                           ;{ normal ComboBox
        
        If ComboEx()\ListView\Hide
          OpenListView_()
        Else
          CloseListView_()
          PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
        EndIf  
        ;}
      EndIf   
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftDoubleClickHandler()
    Define.i dX, Pos
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      Pos = CursorPos_(dX)
      If Pos
        ComboEx()\Selection\Pos1 = GetWordStart_(Pos)
        ComboEx()\Selection\Pos2 = GetWordEnd_(Pos)
        ComboEx()\Selection\Flag = #Selected
        ComboEx()\Cursor\Pos     = ComboEx()\Selection\Pos2
      EndIf
    
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure _MouseEnterHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If Not ComboEx()\Flags & #Editable
        ComboEx()\Button\State | #Focus
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      ComboEx()\Button\State & ~#Focus
      Draw_()
    EndIf
    
  EndProcedure  
  
  Procedure _MouseMoveHandler()
    Define.i dX, Y, GNum
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GadgetNum))

     	dX = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)

      If ComboEx()\Flags & #Editable ;{ Edit
      
        If GetGadgetAttribute(GadgetNum, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton ;{ Left mouse button pressed
          
          Select ComboEx()\Mouse
            Case #Mouse_Move   ;{ Start selection
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = ComboEx()\Cursor\Pos
                ComboEx()\Selection\Pos2 = CursorPos_(dX)
                ComboEx()\Selection\Flag = #Selected
                ComboEx()\Mouse = #Mouse_Select
                Draw_()
              EndIf ;}
            Case #Mouse_Select ;{ Continue selection
              ComboEx()\Selection\Pos2 = CursorPos_(dX)
              ComboEx()\Cursor\Pos     = ComboEx()\Selection\Pos2
              Draw_() ;}
          EndSelect
          ;}
        Else

          If dX > dpiX(ComboEx()\Button\X)
            ComboEx()\Button\State | #Focus
            If ComboEx()\CanvasCursor <> #PB_Cursor_Default
              SetGadgetAttribute(ComboEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
              ComboEx()\CanvasCursor = #PB_Cursor_Default
            EndIf
          Else
            ComboEx()\Button\State & ~#Focus
            If ComboEx()\CanvasCursor <> #PB_Cursor_IBeam
              SetGadgetAttribute(ComboEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
              ComboEx()\CanvasCursor = #PB_Cursor_IBeam
            EndIf
          EndIf
        
          Draw_()
        EndIf 
        ;}
      EndIf
      
      ComboEx()\Mouse = #Mouse_Move

    EndIf
    
  EndProcedure
    
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GadgetID))      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.i FontSize
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach ComboEx()
      
      If IsGadget(ComboEx()\CanvasNum)
        
        If ComboEx()\Flags & #AutoResize
          
          If IsWindow(ComboEx()\Window\Num)
            
            If ComboEx()\ListView\Hide = #False : CloseListView_() : EndIf
            
            OffSetX = WindowWidth(ComboEx()\Window\Num)  - ComboEx()\Window\Width
            OffsetY = WindowHeight(ComboEx()\Window\Num) - ComboEx()\Window\Height

            If ComboEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If ComboEx()\Size\Flags & #MoveX  : X = ComboEx()\Size\X + OffSetX : EndIf
              If ComboEx()\Size\Flags & #MoveY  : Y = ComboEx()\Size\Y + OffSetY : EndIf
              If ComboEx()\Size\Flags & #Width  : Width  = ComboEx()\Size\Width  + OffSetX : EndIf
              If ComboEx()\Size\Flags & #Height : Height = ComboEx()\Size\Height + OffSetY : EndIf
              
              ResizeGadget(ComboEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(ComboEx()\CanvasNum, #PB_Ignore, #PB_Ignore, ComboEx()\Size\Width + OffSetX, ComboEx()\Size\Height + OffsetY)
            EndIf

            Draw_()
          EndIf

        EndIf
        
      EndIf
      
    Next
    
  EndProcedure  
  
  Procedure _MoveWindowHandler()
    
    ForEach ComboEx()
      
      If IsGadget(ComboEx()\CanvasNum)
        If IsWindow(ComboEx()\Window\Num)
          If ComboEx()\ListView\Hide = #False : CloseListView_() : EndIf
        EndIf  
      EndIf
      
    Next
    
  EndProcedure  
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach ComboEx()
     
      If ComboEx()\Window\Num = Window
        
        If IsWindow(ComboEx()\ListView\Window)
          CloseWindow(ComboEx()\ListView\Window)
        EndIf
      
        DeleteMapElement(ComboEx())
        
      EndIf
      
    Next
    
  EndProcedure
  
  ;{ _____ ScrollBar _____
  
  
  ;}
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure   InitList_()
    
    ComboEx()\ListView\Window = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_BorderLess|#PB_Window_Invisible|#PB_Window_NoActivate, WindowID(ComboEx()\Window\Num)) 
    If ComboEx()\ListView\Window
      
      ;StickyWindow(ComboEx()\ListView\Window, #True)
      
      ComboEx()\ListView\Num = CanvasGadget(#PB_Any, 0, 0, 0, 0)
      
      If IsGadget(ComboEx()\ListView\Num)

        ScrollBar()
        
        AddWindowTimer(ComboEx()\ListView\Window, #AutoScrollTimer, #Frequency)
        
        BindGadgetEvent(ComboEx()\ListView\Num, @_ListViewHandler())
        
      EndIf  
      ComboEx()\ListView\Hide = #True
    EndIf
  
  EndProcedure  

	Procedure.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Flags.i=#False)
	  Define.i r, Result
	  
		If FindMapElement(ComboEx(), Str(GNum))
		  
		  ;{ Add item
      Select Row
        Case #FirstItem
          FirstElement(ComboEx()\ListView\Item())
          Result = InsertElement(ComboEx()\ListView\Item()) 
        Case #LastItem
          LastElement(ComboEx()\ListView\Item())
          Result = AddElement(ComboEx()\ListView\Item())
        Default
          If SelectElement(ComboEx()\ListView\Item(), Row)
            Result = InsertElement(ComboEx()\ListView\Item()) 
          Else
            LastElement(ComboEx()\ListView\Item())
            Result = AddElement(ComboEx()\ListView\Item())
          EndIf
      EndSelect ;}
   
      If Result

		    ComboEx()\ListView\Item()\ID       = Label
		    ComboEx()\ListView\Item()\String   = Text
		    ComboEx()\ListView\Item()\Color    = #PB_Default
		    ComboEx()\ListView\Item()\Flags    = Flags
		    
		    If Label
		      ComboEx()\ListView\Index(Label) = ListIndex(ComboEx()\ListView\Item())
		    EndIf
		    
  		  Draw_()
  		EndIf
  		
		EndIf
		
    ProcedureReturn ListIndex(ComboEx()\ListView\Item())
	EndProcedure
	
	Procedure.i AddSubItem(GNum.i, Item.i, SubItem.i, Text.s, State.i=#False) 
	  Define.i Result
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Item)
	      
	      ;{ Add item
        Select SubItem
          Case #FirstItem
            FirstElement(ComboEx()\ListView\Item()\SubItem())
            Result = InsertElement(ComboEx()\ListView\Item()\SubItem()) 
          Case #LastItem
            LastElement(ComboEx()\ListView\Item()\SubItem())
            Result = AddElement(ComboEx()\ListView\Item()\SubItem())
          Default
            If SelectElement(ComboEx()\ListView\Item()\SubItem(), SubItem)
              Result = InsertElement(ComboEx()\ListView\Item()\SubItem()) 
            Else
              LastElement(ComboEx()\ListView\Item()\SubItem())
              Result = AddElement(ComboEx()\ListView\Item()\SubItem())
            EndIf
        EndSelect ;}
        
        If Result
          ComboEx()\ListView\Item()\SubItem()\String = Text
          ComboEx()\ListView\Item()\SubItem()\State  = State
          Draw_()
        EndIf
      
	    EndIf  
	    
	  EndIf  
	  
	  ProcedureReturn ListIndex(ComboEx()\ListView\Item()\SubItem())
	EndProcedure
	
  Procedure   AttachPopupMenu(GNum.i, MenuNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If IsMenu(MenuNum)
        ComboEx()\PopupNum = MenuNum
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure   Copy(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      Copy_()
    EndIf
    
  EndProcedure
  
  Procedure   Cut(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      Cut_()
      PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Paste(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      Paste_()
      PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Delete(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      DeleteSelection_()
      PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure   ClearItems(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      ClearList(ComboEx()\ListView\Item())
      Draw_()
    EndIf  
    
  EndProcedure 
  
  Procedure.i CountItems(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      ProcedureReturn ListSize(ComboEx()\ListView\Item())
    EndIf  
    
  EndProcedure 
  
  Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(ComboEx(), Str(GNum))

      ComboEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure  

  Procedure   Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, maxListHeight.i, Content.s="", Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum
    
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
      Result = CanvasGadget(GNum, X, Y, Width, 20, #PB_Canvas_Keyboard)
    EndIf
    
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf

      If AddMapElement(ComboEx(), Str(GNum))
        
        ComboEx()\CanvasNum = GNum
        ComboEx()\Text      = Content
        ComboEx()\Flags     = Flags
        
        If WindowNum = #PB_Default
          ComboEx()\Window\Num = GetGadgetWindow()
        Else
          ComboEx()\Window\Num = WindowNum
        EndIf

        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            ComboEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              ComboEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            ComboEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        ComboEx()\Padding = 4
        
        ComboEx()\Button\Image\Num = #PB_Default
        
        ComboEx()\Size\X = X
        ComboEx()\Size\Y = Y
        ComboEx()\Size\Width  = Width
        ComboEx()\Size\Height = Height
        ComboEx()\ListView\Height = maxListHeight
        
        InitList_()
        
        ComboEx()\ListView\State = #PB_Default
        
        ComboEx()\CanvasCursor = #PB_Cursor_Default
        ComboEx()\Cursor\Pause = #True
        ComboEx()\Cursor\State = #True
        
        ComboEx()\Color\Front         = $000000
        ComboEx()\Color\Back          = $FFFFFF
        ComboEx()\Color\FocusText     = $FFFFFF
        ComboEx()\Color\FocusBack     = $D77800
        ComboEx()\Color\Border        = $A0A0A0
        ComboEx()\Color\Gadget        = $EDEDED
        ComboEx()\Color\DisableFront  = $72727D
        ComboEx()\Color\DisableBack   = $CCCCCA
        ComboEx()\Color\Cursor        = $800000
        ComboEx()\Color\Button        = $E3E3E3
        ComboEx()\Color\Highlight     = $D77800
        ComboEx()\Color\HighlightText = $FFFFFF
        ComboEx()\Color\WordColor     = $CC6600
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            ComboEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            ComboEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
            ComboEx()\Color\FocusText     = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
            ComboEx()\Color\FocusBack     = GetSysColor_(#COLOR_HIGHLIGHT)
            ComboEx()\Color\Gadget        = GetSysColor_(#COLOR_MENU)
            ComboEx()\Color\Button        = GetSysColor_(#COLOR_3DLIGHT)
            ComboEx()\Color\Border        = GetSysColor_(#COLOR_ACTIVEBORDER)
            ComboEx()\Color\WordColor     = GetSysColor_(#COLOR_HOTLIGHT)
            ComboEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
            ComboEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
          CompilerCase #PB_OS_MacOS
            ComboEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ComboEx()\Color\FocusBack     = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ComboEx()\Color\FocusBack     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor keyboardFocusIndicatorColor"))
            ComboEx()\Color\Gadget        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            ComboEx()\Color\Button        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ComboEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ComboEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextBackgroundColor"))
            ComboEx()\Color\HighlightText = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}        
        
        BindGadgetEvent(GNum, @_FocusHandler(),           #PB_EventType_Focus)
        BindGadgetEvent(GNum, @_LostFocusHandler(),       #PB_EventType_LostFocus)
        BindGadgetEvent(GNum, @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
        BindGadgetEvent(GNum, @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        BindGadgetEvent(GNum, @_InputHandler(),           #PB_EventType_Input)
        BindGadgetEvent(GNum, @_KeyDownHandler(),         #PB_EventType_KeyDown)
        BindGadgetEvent(GNum, @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        BindGadgetEvent(GNum, @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
        BindGadgetEvent(GNum, @_MouseEnterHandler(),      #PB_EventType_MouseEnter)
        BindGadgetEvent(GNum, @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(GNum, @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(GNum, @_CursorDrawing(),          #PB_EventType_Change)
        BindGadgetEvent(GNum, @_ResizeHandler(),          #PB_EventType_Resize)

        
        
        If IsWindow(WindowNum) : BindEvent(#PB_Event_MoveWindow, @_MoveWindowHandler(), WindowNum) : EndIf
        
        If Flags & #AutoResize
          
          If IsWindow(WindowNum)
            ComboEx()\Window\Width  = WindowWidth(WindowNum)
            ComboEx()\Window\Height = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf
          
        EndIf
        
        AddWindowTimer(ComboEx()\Window\Num, #CursorTimer, #CursorFrequency)
        BindEvent(#PB_Event_Timer, @_CursorDrawing(), ComboEx()\Window\Num)

        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
        
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), ComboEx()\Window\Num)
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select Attribute
        Case #Padding
          ProcedureReturn ComboEx()\Padding
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetColor(GNum.i, ColorType.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn ComboEx()\Color\Front
        Case #BackColor
          ProcedureReturn ComboEx()\Color\Back
        Case #BorderColor
          ProcedureReturn ComboEx()\Color\Border
        Case #FocusTextColor
          ProcedureReturn ComboEx()\Color\FocusText
        Case #FocusBackColor
          ProcedureReturn ComboEx()\Color\FocusBack
        Case #CursorColor
          ProcedureReturn ComboEx()\Color\Cursor
        Case #HighlightColor
          ProcedureReturn ComboEx()\Color\Highlight
        Case #HighlightTextColor
          ProcedureReturn ComboEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ProcedureReturn ComboEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ProcedureReturn ComboEx()\ID
	  EndIf
	  
	EndProcedure
	
  Procedure.q GetItemData(GNum.i, Row.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ProcedureReturn ComboEx()\ListView\Item()\Quad
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemLabel(GNum.i, Row.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ProcedureReturn ComboEx()\ListView\Item()\ID
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemText(GNum.i, Row.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ProcedureReturn ComboEx()\ListView\Item()\String
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetLabelText(GNum.i, Label.s)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If FindMapElement(ComboEx()\ListView\Index(), Label)
    	  If SelectElement(ComboEx()\ListView\Item(), ComboEx()\ListView\Index())
    	    ProcedureReturn ComboEx()\ListView\Item()\String
    	  EndIf 
    	EndIf
    	
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetState(GNum.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
      ProcedureReturn ComboEx()\ListView\State
    EndIf
    
	EndProcedure
	
  Procedure.i GetSubItemState(GNum.i, Item.i, SubItem.i) 
	  Define.i Result
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Item)
	      If SelectElement(ComboEx()\ListView\Item()\SubItem(), SubItem)
	        ProcedureReturn ComboEx()\ListView\Item()\SubItem()\State
        EndIf 
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	Procedure.s GetSubItemText(GNum.i, Item.i, SubItem.i) 
	  Define.i Result
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Item)
	      If SelectElement(ComboEx()\ListView\Item()\SubItem(), SubItem)
	        ProcedureReturn ComboEx()\ListView\Item()\SubItem()\String
        EndIf 
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
  Procedure.s GetText(GNum.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      ProcedureReturn ComboEx()\Text
    EndIf
    
  EndProcedure

  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(ComboEx(), Str(GNum))
      HideGadget(GNum, State)
      ComboEx()\Hide = State 
    EndIf  
  
  EndProcedure
  
  Procedure   RemoveItem(GNum.i, Row.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If SelectElement(ComboEx()\ListView\Item(), Row)
        DeleteElement(ComboEx()\ListView\Item())
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  

  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      ComboEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select Attribute
        Case #Padding
          If Value < 2 : Value = 2 : EndIf 
          ComboEx()\Padding = Value
        Case #Corner
          ComboEx()\Radius  = Value
        Case #ScrollBar
          ComboEx()\ListView\ScrollBar\Flags | Value  
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ComboEx()\Color\Front         = Color
        Case #BackColor
          ComboEx()\Color\Back          = Color
        Case #BorderColor
          ComboEx()\Color\Border        = Color
        Case #FocusTextColor
          ComboEx()\Color\FocusText     = Color
        Case #FocusBackColor
          ComboEx()\Color\FocusBack     = Color
        Case #CursorColor
          ComboEx()\Color\Cursor        = Color
        Case #HighlightColor
          ComboEx()\Color\Highlight     = Color
        Case #HighlightTextColor
          ComboEx()\Color\HighlightText = Color
        Case #ScrollBar_FrontColor
          ComboEx()\ListView\ScrollBar\Color\Front  = Color
        Case #ScrollBar_BackColor 
          ComboEx()\ListView\ScrollBar\Color\Back   = Color
        Case #ScrollBar_ButtonColor
          ComboEx()\ListView\ScrollBar\Color\Button = Color  
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ComboEx()\Quad = Value
	  EndIf  
	  
	EndProcedure

  Procedure   SetFont(GNum.i, FontNum.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If IsFont(FontNum)
        ComboEx()\FontID = FontID(FontNum)
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ComboEx()\ID = String
	  EndIf
	  
	EndProcedure  
	
	Procedure   SetImage(GNum.i, Image.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))

	    If IsImage(Image)  
	      ComboEx()\Button\Image\Num    = Image
	      ComboEx()\Button\Image\Width  = ImageWidth(Image)
	      ComboEx()\Button\Image\Height = ImageHeight(Image)
	    EndIf
	    
	    Draw_()
	    
	  EndIf 

	  
	EndProcedure	
	
  Procedure   SetItemColor(GNum.i, Row.i, Color.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ComboEx()\ListView\Item()\Color = Color
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemData(GNum.i, Row.i, Value.q)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ComboEx()\ListView\Item()\Quad = Value
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
  	  If SelectElement(ComboEx()\ListView\Item(), Row)
  	    
  	    If IsImage(Image)  
  	      ComboEx()\ListView\Item()\Image\Num    = Image
  	      ComboEx()\ListView\Item()\Image\Width  = ImageWidth(Image)
  	      ComboEx()\ListView\Item()\Image\Height = ImageHeight(Image)
  	      ComboEx()\ListView\Item()\Image\Flags  = Flags
  	      ComboEx()\ListView\Item()\Flags | #Image
  	    EndIf
  	    
  	  EndIf 
  	  
	  EndIf
	  
	EndProcedure	
	
	Procedure   SetItemText(GNum.i, Row.i, Text.s, Flags.i=#False)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
  	  If SelectElement(ComboEx()\ListView\Item(), Row)
  	    ComboEx()\ListView\Item()\String = Text
  	    ComboEx()\ListView\Item()\Flags | Flags
  	  EndIf 
  	  
	  EndIf
	  
	EndProcedure	
	
  Procedure   SetLabelText(GNum.i, Label.s, Text.s, Flags.i=#False)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If FindMapElement(ComboEx()\ListView\Index(), Label)
    	  If SelectElement(ComboEx()\ListView\Item(), ComboEx()\ListView\Index())
    	    ComboEx()\ListView\Item()\String = Text
    	    ComboEx()\ListView\Item()\Flags | Flags
    	  EndIf 
    	EndIf
    	
	  EndIf
	  
	EndProcedure
	
  Procedure   SetState(GNum.i, State.i)
	  
    If FindMapElement(ComboEx(), Str(GNum))
      If SelectElement(ComboEx()\ListView\Item(), State)
        ComboEx()\Text = ComboEx()\ListView\Item()\String
  	    ComboEx()\ListView\State = State
  	    Draw_()
  	  EndIf  
    EndIf
    
	EndProcedure
	
	Procedure   SetSubItemState(GNum.i, Item.i, SubItem.i, State.i) 
	  Define.i Result
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Item)
	      If SelectElement(ComboEx()\ListView\Item()\SubItem(), SubItem)
	        ComboEx()\ListView\Item()\SubItem()\State = State
        EndIf 
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetSubItemText(GNum.i, Item.i, SubItem.i, Text.s) 
	  Define.i Result
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Item)
	      If SelectElement(ComboEx()\ListView\Item()\SubItem(), SubItem)
	        ComboEx()\ListView\Item()\SubItem()\String = Text
        EndIf 
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
  Procedure   SetText(GNum.i, Text.s) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\Flags & #Editable
        
        ComboEx()\Text = Text
        
      Else
        
        ForEach ComboEx()\ListView\Item()
          If ComboEx()\ListView\Item()\String = Text
            ComboEx()\Text = Text
            ComboEx()\ListView\State = ListIndex(ComboEx()\ListView\Item())
            Break
          EndIf
        Next
        
      EndIf 
      
      Draw_()
    EndIf
    
  EndProcedure

EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Example = 1
  
  #Window  = 0
  
  Enumeration 1
    #ComboBox
    #ComboEx
    #Font
    #Image
  EndEnumeration
    
  If OpenWindow(#Window, 0, 0, 230, 60, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    LoadImage(#Image, "Test.png")
    
    ComboBoxGadget(#ComboBox, 15, 19, 90, 20) ; , #PB_ComboBox_Editable
    AddGadgetItem(#ComboBox, -1, "Item 1")
    AddGadgetItem(#ComboBox, -1, "Item 2")
    AddGadgetItem(#ComboBox, -1, "Item 3")
    
    Select #Example
      Case 1
        
        If ComboBoxEx::Gadget(#ComboEx, 120, 19, 90, 20, 80, "", ComboBoxEx::#Editable, #Window)
          ; ComboBoxEx::#LowerCase / ComboBoxEx::#UpperCase / ComboBoxEx::#Editable / ComboBoxEx::#BorderLess

          ;ComboBoxEx::SetAttribute(#ComboEx, ComboBoxEx::#Corner, 4)
          ;ComboBoxEx::SetImage(#ComboEx, #Image)
          
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 1")
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 2")          
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 3")
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 4")
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 5")          
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 6")
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 7")          
          ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 8")
           
          ComboBoxEx::SetItemImage(#ComboEx, 1, #Image)
          ComboBoxEx::SetItemImage(#ComboEx, 2, #Image, ComboBoxEx::#Right)
          
          ComboBoxEx::SetItemColor(#ComboEx, 0, #Red)
          
          ComboBoxEx::SetState(#ComboEx, 1)
        EndIf
        
      Case 2
        
        If ComboBoxEx::Gadget(#ComboEx, 120, 19, 95, 20, 80, "", ComboBoxEx::#MultiSelect, #Window)
          ; ComboBoxEx::#LowerCase / ComboBoxEx::#UpperCase / ComboBoxEx::#Editable / ComboBoxEx::#BorderLess

          ComboBoxEx::AddItem(#ComboEx, 0, "All Items")
          ComboBoxEx::AddItem(#ComboEx, 1, "User Selection")
          ComboBoxEx::AddSubItem(#ComboEx, 1, ComboBoxEx::#LastItem, "SubItem 1")
          ComboBoxEx::AddSubItem(#ComboEx, 1, ComboBoxEx::#LastItem, "SubItem 2")
          ComboBoxEx::AddSubItem(#ComboEx, 1, ComboBoxEx::#LastItem, "SubItem 3")

        EndIf
        
    EndSelect
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #ComboEx
              Select EventType()
                Case #PB_EventType_Focus
                 ; Debug ">>> Focus"
                Case #PB_EventType_LostFocus
                 ; Debug ">>> LostFocus"
                Case ComboBoxEx::#EventType_Change
                  Debug ">>> Changed: " + Str(ComboBoxEx::GetState(#ComboEx))
              EndSelect    
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 6.00 Beta 7 (Windows - x64)
; CursorPosition = 2787
; FirstLine = 565
; Folding = 5MAAAAAiCAAAEMFQkfBiEEAAAe+AAASAAAAA+
; EnableThread
; EnableXP
; DPIAware
; EnablePurifier