;/ ============================
;/ =    ListViewModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x - V6.0 / 64Bit / All OS / DPI ]
;/
;/ ListView - Gadget
;/
;/ © 2022 by Thorsten Hoeppner (11/2019)
;/

; Last Update: 15.05.2022
;
; - New Scrollbars
; - New DPI - Managmment
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


;{ _____ ListView - Commands _____

; ListView::AddItem()            - similar to 'AddGadgetItem()'
; ListView::AttachPopupMenu()    - attach a popup menu to the list
; ListView::ClearItems()         - similar to 'ClearGadgetItems()'
; ListView::CountItems()         - similar to 'CountGadgetItems()'
; ListView::DisableReDraw()      - disable/enable redrawing of the gadget
; ListView::Gadget()             - similar to 'ListViewGadget()'
; ListView::GetData()            - similar to 'GetGadgetData()'
; ListView::GetID()              - similar to 'GetGadgetData()', but string instead of quad
; ListView::GetItemData()        - similar to 'GetGadgetItemData()'
; ListView::GetItemLabel()       - similar to 'GetGadgetItemData()', but string instead of quad
; ListView::GetItemState()       - similar to 'GetGadgetItemState()'
; ListView::GetItemText()        - similar to 'GetGadgetItemText()'
; ListView::GetLabelText()       - similar to 'GetGadgetItemText()', but label instead of row
; ListView::GetState()           - similar to 'GetGadgetState()'
; ListView::GetText()            - similar to 'GetGadgetText()'
; ListView::Hide()               - similar to 'HideGadget()'
; ListView::RemoveItem()         - similar to 'RemoveGadgetItem()'
; ListView::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; ListView::SetColor()           - similar to 'SetGadgetColor()'
; ListView::SetData()            - similar to 'SetGadgetData()'
; ListView::SetFont()            - similar to 'SetGadgetFont()'
; ListView::SetID()              - similar to 'SetGadgetData()', but string instead of quad
; ListView::SetItemColor()       - similar to 'SetGadgetItemColor()'
; ListView::SetItemData()        - similar to 'SetGadgetItemData()'
; ListView::SetItemImage()       - similar to 'SetGadgetItemImage()'
; ListView::SetItemLabel()       - similar to 'SetGadgetItemData()', but string instead of quad
; ListView::SetItemState()       - similar to 'SetGadgetItemState()'
; ListView::SetItemText()        - similar to 'SetGadgetItemText()'
; ListView::SetLabelText()       - similar to 'SetGadgetItemText()', but label instead of row
; ListView::SetRowHeight()       - change the rows height
; ListView::SetState()           - similar to 'SetGadgetState()'
; ListView::SetText()            - similar to 'SetGadgetText()'
; ListView::UpdatePopupText()    - define dynamic menu item text [#Label$/#Index$/#Row$/#String$]

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule ListView
  
  #Version  = 22051700
  #ModuleEx = 19120100

	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  #Enable_SyntaxHighlight = #True

  ; _____ Constants _____
  #FirstItem = 0
  #LastItem  = -1
  
  #Label$  = "{Value}"
	#Index$  = "{Index}"
	#Row$    = "{Row}"
	#String$ = "{String}"
  
	EnumerationBinary ;{ GadgetFlags
		#AutoResize        ; Automatic resizing of the gadget
		#Borderless        ; Draw no border
		#ClickSelect = #PB_ListView_ClickSelect ; must be 8
		#GridLines                              ; Draw gridlines
		#ThreeState
		#CheckBoxes
		#Style_RoundThumb
    #Style_Win11
		#UseExistingCanvas ; e.g. for dialogs
		#MultiSelect = #PB_ListView_MultiSelect ; must be 2048
	EndEnumeration ;}
	
	#Left = 0
	EnumerationBinary ;{ Flags: Item & Image 
    #Right
    #Center 
    #Image
    #FitRows
	EndEnumeration ;}
	
	EnumerationBinary ;{ CheckBox status 
    #Selected   = #PB_ListIcon_Selected
    #Checked    = #PB_ListIcon_Checked
    #Inbetween  = #PB_ListIcon_Inbetween
  EndEnumeration ;}
	
	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}

	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
		#GridColor
		#ScrollBar_FrontColor
    #ScrollBar_BackColor 
    #ScrollBar_ButtonColor
	EndEnumeration ;}
	
	#ScrollBar = 1
	
	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget = ModuleEx::#Event_Gadget
		#Event_Theme  = ModuleEx::#Event_Theme
		#Event_Timer  = ModuleEx::#Event_Timer
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
		  #Event_Gadget
		  #Event_Timer
		EndEnumeration

	CompilerEndIf


	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
	
	Declare.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Flags.i=#False)
	Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
	Declare   ClearItems(GNum.i)
	Declare.i CountItems(GNum.i)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default) 
  Declare.q GetData(GNum.i)
  Declare.s GetID(GNum.i)
  Declare.q GetItemData(GNum.i, Row.i)
  Declare.s GetItemLabel(GNum.i, Row.i)
  Declare.i GetItemState(GNum.i, Row.i)
  Declare.s GetItemText(GNum.i, Row.i)
  Declare.s GetLabelText(GNum.i, Label.s)
  Declare.i GetState(GNum.i)
  Declare.s GetText(GNum.i, Text.s)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   SetAttribute(GNum.i, Attrib.i, Value.i)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontID.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i)
  Declare   SetItemData(GNum.i, Row.i, Value.q)
  Declare   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False)
  Declare   SetItemLabel(GNum.i, Row.i, Label.s)
  Declare   SetItemState(GNum.i, Row.i, State.i=#True)
  Declare   SetItemText(GNum.i, Row.i, Text.s)
  Declare   SetLabelText(GNum.i, Label.s, Text.s)
  Declare   SetRowHeight(GNum.i, Height.i=#PB_Default)
  Declare   SetState(GNum.i, Row.i)
  Declare   SetText(GNum.i, Text.s)
  Declare   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
  
  CompilerIf #Enable_SyntaxHighlight
    
    Declare AddWord(GNum.i, Word.s, Color.i)
    Declare DeleteWord(GNum.i, Word.s)
    Declare ClearWords(GNum.i)
    
  CompilerEndIf

EndDeclareModule

Module ListView

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	; _____ ScrollBar _____
	#ScrollBarSize   = 16
	
	#AutoScrollTimer = 1867
	#Frequency       = 100  ; 100ms
	#TimerDelay      = 3    ; 100ms * 3
	
	Enumeration 1     ;{ Mouse State
	  #Focus
	  #Click
	  #Hover
	EndEnumeration ;}
	
	EnumerationBinary ;{ Direction
	  #Vertical
    #Horizontal
	  #Scrollbar_Up
	  #Scrollbar_Left
	  #Scrollbar_Right
	  #Scrollbar_Down
	  #Forwards
	  #Backwards
	EndEnumeration ;}

	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	;{ _____ ScrollBar _____
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
	
	
	Structure ScrollBar_Thumb_Structure     ;{ ListView()\HScroll\Forwards\Thumb\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  State.i
	EndStructure ;}
	
	Structure ScrollBar_Button_Structure    ;{ ListView()\HScroll\Buttons\...
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
	
	Structure ScrollBar_Color_Structure     ;{ ListView()\HScroll\Color\...
	  Front.i
	  Back.i
		Button.i
		Focus.i
		Hover.i
		Arrow.i
	EndStructure ;}
	
	Structure ListView_ScrollBar_Structure  ;{ ListView()\HScroll\...
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

	Structure ListView_ScrollBars_Structure ;{ ListView()\ScrollBar\...
	  Color.ScrollBar_Color_Structure
	  Size.i       ; Scrollbar width (vertical) / height (horizontal)
	  ;ScrollV.i
	  ScrollH.i
	  TimerDelay.i ; Autoscroll Delay
	  Flags.i      ; Flag: #Vertical | #Horizontal
	EndStructure ;}
	;}
	
  Structure CheckBox_Structure         ;{ 
    X.i
    Y.i
    Size.i
  EndStructure ;}
  
  Structure Image_Structure            ;{ ListView()\Item()\Image\...
    Num.i
    Width.f
    Height.f
    Flags.i
  EndStructure ;}
  
  Structure Color_Structure            ;{ ListView()\Item()\Color\...
    Front.i
    Back.i
  EndStructure ;}
  
  Structure ListView_Item_Structure    ;{ ListView()\Item()\...
    ID.s
    Quad.q
    Y.i
    String.s
    CheckBox.CheckBox_Structure
    Image.Image_Structure
    Color.Color_Structure
    State.i
    Flags.i
  EndStructure ;}

  Structure ListView_Rows_Structure    ;{ ListView()\Rows\...
    Height.i
    Offset.i
  EndStructure ;}
	
	Structure ListView_Color_Structure   ;{ ListView()\Color\...
		Front.i
		Back.i
		Border.i
		Gadget.i
		Grid.i
		CheckBox.i
		FocusFront.i
		FocusBack.i
		DisableFront.i
		DisableBack.i
	EndStructure  ;}

	Structure ListView_Window_Structure  ;{ ListView()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure ListView_Size_Structure    ;{ ListView()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}


	Structure ListView_Structure         ;{ ListView()\...
		CanvasNum.i
		PopupNum.i
		
		ID.s
		Quad.i
		
		FontID.i
		
		ReDraw.i
		
		Disable.i
		Focus.i
		Hide.i
		State.i
		
		Flags.i

		ToolTip.i
		ToolTipText.s
		
		maxWidth.i
		
		Color.ListView_Color_Structure
		Window.ListView_Window_Structure
		Rows.ListView_Rows_Structure
		Size.ListView_Size_Structure

		; ----- Scrollbars -----
		OffsetH.i
	  Scrollbar.ListView_ScrollBars_Structure
	  HScroll.ListView_ScrollBar_Structure
	  VScroll.ListView_ScrollBar_Structure
		Area.Area_Structure ; available area
		
		
		List Item.ListView_Item_Structure()
		Map  Index.i() 
		Map  Syntax.i()
		Map  PopUpItem.s()
    
	EndStructure ;}
	Global NewMap ListView.ListView_Structure()
	
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
  

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
	
	Procedure.s GetPopUpText_(Text.s)
		Define.f Percent
		Define.s Text$ = ""

		If Text
		  Text$ = ReplaceString(Text, #Label$,  ListView()\Item()\ID)
		  Text$ = ReplaceString(Text$, #Index$,  Str(ListIndex(ListView()\Item())))
		  Text$ = ReplaceString(Text$, #Row$,    Str(ListIndex(ListView()\Item()) + 1))
		  Text$ = ReplaceString(Text$, #String$, ListView()\Item()\String)
		EndIf

		ProcedureReturn Text$
	EndProcedure

	Procedure   UpdatePopUpMenu_()
		Define.s Text$

		ForEach ListView()\PopUpItem()
		  Text$ = GetPopUpText_(ListView()\PopUpItem())
			SetMenuItemText(ListView()\PopupNum, Val(MapKey(ListView()\PopUpItem())), Text$)
		Next

	EndProcedure
	
	;{ _____ ScrollBar _____
	Procedure   CalcScrollBar_()
	  Define.i Width, Height, ScrollbarSize
	  
	  ; current canvas ScrollbarSize
	  Width         = GadgetWidth(ListView()\CanvasNum)
	  Height        = GadgetHeight(ListView()\CanvasNum)
	  ScrollbarSize = ListView()\Scrollbar\Size
	  
	  ;{ Calc available canvas area
	  If ListView()\Scrollbar\Flags & #Horizontal And ListView()\Scrollbar\Flags & #Vertical
	    If ListView()\HScroll\Hide And ListView()\VScroll\Hide
	      ListView()\Area\Width  = Width  - 2
        ListView()\Area\Height = Height - 2
	    ElseIf ListView()\HScroll\Hide
	      ListView()\Area\Width  = Width  - ScrollbarSize - 2
        ListView()\Area\Height = Height
	    ElseIf ListView()\VScroll\Hide
	      ListView()\Area\Width  = Width
        ListView()\Area\Height = Height - ScrollbarSize - 2
	    Else
	      ListView()\Area\Width  = Width  - ScrollbarSize - 2
        ListView()\Area\Height = Height - ScrollbarSize - 2
	    EndIf  
	  ElseIf ListView()\Scrollbar\Flags & #Horizontal
      ListView()\Area\Width  = Width
      ListView()\Area\Height = Height - ScrollbarSize - 2
    ElseIf ListView()\Scrollbar\Flags & #Vertical
      ListView()\Area\Width  = Width  - ScrollbarSize - 2
      ListView()\Area\Height = Height
    Else
      ListView()\Area\Width  = Width  - 2
      ListView()\Area\Height = Height - 2
    EndIf ;}
    
    ;{ Calc scrollbar size
    If ListView()\Scrollbar\Flags & #Horizontal And ListView()\Scrollbar\Flags & #Vertical
      If ListView()\HScroll\Hide      ;{ only vertical visible
        
        ListView()\VScroll\X        = Width - ScrollbarSize - 1
        ListView()\VScroll\Y        = 1
        ListView()\VScroll\Width    = ScrollbarSize
        ListView()\VScroll\Height   = Height - 2
        ;}
      ElseIf ListView()\VScroll\Hide  ;{ only horizontal visible
        
        ListView()\HScroll\X        = 1
        ListView()\HScroll\Y        = Height - ScrollbarSize - 1
        ListView()\HScroll\Width    = Width - 2
        ListView()\HScroll\Height   = ScrollbarSize
        ;}
      Else                            ;{ both scrollbars visible
        
        ListView()\HScroll\X        = 1
        ListView()\HScroll\Y        = Height - ScrollbarSize - 1
        ListView()\HScroll\Width    = Width  - ScrollbarSize - 2
        ListView()\HScroll\Height   = ScrollbarSize
        
        ListView()\VScroll\X        = Width - ScrollbarSize  - 1
        ListView()\VScroll\Y        = 1
        ListView()\VScroll\Width    = ScrollbarSize
        ListView()\VScroll\Height   = Height - ScrollbarSize - 2
        ;}
      EndIf  
    ElseIf ListView()\Scrollbar\Flags & #Horizontal        ;{ only horizontal availible
      
      ListView()\HScroll\X        = 1
      ListView()\HScroll\Y        = Height - ScrollbarSize -1
      ListView()\HScroll\Width    = Width - 2
      ListView()\HScroll\Height   = ScrollbarSize
      ;}
    ElseIf ListView()\Scrollbar\Flags & #Vertical          ;{ only vertical availible
      
      ListView()\VScroll\X        = Width - ScrollbarSize - 1
      ListView()\VScroll\Y        = 1
      ListView()\VScroll\Width    = ScrollbarSize
      ListView()\VScroll\Height   = Height - 2
      ;}
    EndIf ;} 
    
    ;{ Calc scroll buttons
    If ListView()\Scrollbar\Flags & #Horizontal
      ListView()\HScroll\Buttons\Width  = ScrollbarSize
      ListView()\HScroll\Buttons\Height = ScrollbarSize
      ; forward: right
      ListView()\HScroll\Buttons\fX     = ListView()\HScroll\X + ListView()\HScroll\Width - ScrollbarSize
      ListView()\HScroll\Buttons\fY     = ListView()\HScroll\Y
      ; backward: left
      ListView()\HScroll\Buttons\bX     = ListView()\HScroll\X
      ListView()\HScroll\Buttons\bY     = ListView()\HScroll\Y
    EndIf
    
    If ListView()\Scrollbar\Flags & #Vertical
      ListView()\VScroll\Buttons\Width  = ScrollbarSize
      ListView()\VScroll\Buttons\Height = ScrollbarSize
      ; forward: down
      ListView()\VScroll\Buttons\fX     = ListView()\VScroll\X
      ListView()\VScroll\Buttons\fY     = ListView()\VScroll\Y + ListView()\VScroll\Height - ScrollbarSize
      ; backward: up
      ListView()\VScroll\Buttons\bX     = ListView()\VScroll\X
      ListView()\VScroll\Buttons\bY     = ListView()\VScroll\Y
    EndIf
    ;}
    
    ;{ Calc scroll area between buttons
    If ListView()\Scrollbar\Flags & #Horizontal
      ListView()\HScroll\Area\X      = ListView()\HScroll\X + ScrollbarSize
  		ListView()\HScroll\Area\Y      = ListView()\HScroll\Y
  		ListView()\HScroll\Area\Width  = ListView()\HScroll\Width - (ScrollbarSize * 2)
  		ListView()\HScroll\Area\Height = ScrollbarSize
    EndIf   
    
    If ListView()\Scrollbar\Flags & #Vertical
      ListView()\VScroll\Area\X      = ListView()\VScroll\X
  		ListView()\VScroll\Area\Y      = ListView()\VScroll\Y + ScrollbarSize 
  		ListView()\VScroll\Area\Width  = ScrollbarSize
  		ListView()\VScroll\Area\Height = ListView()\VScroll\Height - (ScrollbarSize * 2)
    EndIf  		
    ;}

    ;{ Calc thumb size
    If ListView()\Scrollbar\Flags & #Horizontal

		  ListView()\HScroll\Thumb\Y      = ListView()\HScroll\Area\Y
		  ListView()\HScroll\Thumb\Width  = Round(ListView()\HScroll\Area\Width * ListView()\HScroll\Ratio, #PB_Round_Nearest)
		  ListView()\HScroll\Thumb\Height = ScrollbarSize
		  ListView()\HScroll\Factor       = (ListView()\HScroll\Area\Width - ListView()\HScroll\Thumb\Width) / ListView()\HScroll\Range
		  
		  If ListView()\Scrollbar\Flags & #Style_Win11
		    ListView()\HScroll\Thumb\Height - 10
		    ListView()\HScroll\Thumb\Y      +  5 
		  Else
		    ListView()\HScroll\Thumb\Height - 4
		    ListView()\HScroll\Thumb\Y      + 2 
		  EndIf
		  
    EndIf
    
    If ListView()\Scrollbar\Flags & #Vertical
      
      ListView()\VScroll\Thumb\X      = ListView()\VScroll\Area\X
		  ListView()\VScroll\Thumb\Width  = ScrollbarSize
		  ListView()\VScroll\Thumb\Height = Round(ListView()\VScroll\Area\Height * ListView()\VScroll\Ratio, #PB_Round_Nearest) 
		  ListView()\VScroll\Factor       = (ListView()\VScroll\Area\Height - ListView()\VScroll\Thumb\Height) /  ListView()\VScroll\Range
		  
		  If ListView()\Scrollbar\Flags & #Style_Win11
		    ListView()\VScroll\Thumb\Width - 10
		    ListView()\VScroll\Thumb\X     +  5 
		  Else
		    ListView()\VScroll\Thumb\Width - 4
		    ListView()\VScroll\Thumb\X     + 2 
		  EndIf
		  
    EndIf  
    ;}
    
	EndProcedure
	
	Procedure   CalcScrollRange_()
	  
		If ListView()\Scrollbar\Flags & #Horizontal
		  
		  If ListView()\HScroll\PageLength
        ListView()\HScroll\Pos    = ListView()\HScroll\Minimum
  		  ListView()\HScroll\minPos = ListView()\HScroll\Minimum
  		  ListView()\HScroll\maxPos = ListView()\HScroll\Maximum - ListView()\HScroll\PageLength + 1
  		  ListView()\HScroll\Ratio  = ListView()\HScroll\PageLength / ListView()\HScroll\Maximum
  		  ListView()\HScroll\Range  = ListView()\HScroll\maxPos - ListView()\HScroll\minPos
  		EndIf 
  		
    EndIf
    
    If ListView()\Scrollbar\Flags & #Vertical
      
      If ListView()\VScroll\PageLength
        ListView()\VScroll\Pos    = ListView()\VScroll\Minimum
  		  ListView()\VScroll\minPos = ListView()\VScroll\Minimum
  		  ListView()\VScroll\maxPos = ListView()\VScroll\Maximum - ListView()\VScroll\PageLength + 1
  		  ListView()\VScroll\Ratio  = ListView()\VScroll\PageLength / ListView()\VScroll\Maximum
  		  ListView()\VScroll\Range  = ListView()\VScroll\maxPos - ListView()\VScroll\minPos
  		EndIf

    EndIf 
    
    CalcScrollBar_()
    
    ListView()\HScroll\Thumb\X = ListView()\HScroll\Area\X
  	ListView()\VScroll\Thumb\Y = ListView()\VScroll\Area\Y
    
	EndProcedure
	
	
	Procedure.i GetThumbPosX_(X.i)   ; Horizontal Scrollbar
	  Define.i Delta, Offset
	  
	  Delta = X - ListView()\HScroll\CursorPos
	  ListView()\HScroll\Thumb\X + Delta 
	  
	  If ListView()\HScroll\Thumb\X < ListView()\HScroll\Area\X
	    ListView()\HScroll\Thumb\X = ListView()\HScroll\Area\X
	  EndIf 
	  
	  If ListView()\HScroll\Thumb\X + ListView()\HScroll\Thumb\Width > ListView()\HScroll\Area\X + ListView()\HScroll\Area\Width
	    ListView()\HScroll\Thumb\X = ListView()\HScroll\Area\X + ListView()\HScroll\Area\Width - ListView()\HScroll\Thumb\Width
	  EndIf

	  Offset = ListView()\HScroll\Thumb\X - ListView()\HScroll\Area\X
	  ListView()\HScroll\Pos = Round(Offset / ListView()\HScroll\Factor, #PB_Round_Nearest) + ListView()\HScroll\minPos
	  
	  If ListView()\HScroll\Pos > ListView()\HScroll\maxPos : ListView()\HScroll\Pos = ListView()\HScroll\maxPos : EndIf
  	If ListView()\HScroll\Pos < ListView()\HScroll\minPos : ListView()\HScroll\Pos = ListView()\HScroll\minPos : EndIf
	  
	  ProcedureReturn ListView()\HScroll\Pos
	EndProcedure  
	
	Procedure.i GetThumbPosY_(Y.i)   ; Vertical Scrollbar
	  Define.i Delta, Offset

	  Delta = Y - ListView()\VScroll\CursorPos
	  ListView()\VScroll\Thumb\Y + Delta 
	  
	  If ListView()\VScroll\Thumb\Y < ListView()\VScroll\Area\Y
	    ListView()\VScroll\Thumb\Y =  ListView()\VScroll\Area\Y
	  EndIf 
	  
	  If ListView()\VScroll\Thumb\Y + ListView()\VScroll\Thumb\Height >  ListView()\VScroll\Area\Y + ListView()\VScroll\Area\Height
	    ListView()\VScroll\Thumb\Y =  ListView()\VScroll\Area\Y + ListView()\VScroll\Area\Height - ListView()\VScroll\Thumb\Height
	  EndIf
	  
	  Offset = ListView()\VScroll\Thumb\Y - ListView()\VScroll\Area\Y
	  ListView()\VScroll\Pos = Round(Offset / ListView()\VScroll\Factor, #PB_Round_Nearest) + ListView()\VScroll\minPos
	  
	  If ListView()\VScroll\Pos > ListView()\VScroll\maxPos : ListView()\VScroll\Pos = ListView()\VScroll\maxPos : EndIf
  	If ListView()\VScroll\Pos < ListView()\VScroll\minPos : ListView()\VScroll\Pos = ListView()\VScroll\minPos : EndIf
	  
	  ProcedureReturn ListView()\VScroll\Pos
	EndProcedure  
	
	
	Procedure   SetThumbPosX_(Pos.i) ; Horizontal Scrollbar
	  Define.i  Offset
	  
	  ListView()\HScroll\Pos = Pos

	  If ListView()\HScroll\Pos < ListView()\HScroll\minPos : ListView()\HScroll\Pos = ListView()\HScroll\minPos : EndIf
	  If ListView()\HScroll\Pos > ListView()\HScroll\maxPos : ListView()\HScroll\Pos = ListView()\HScroll\maxPos : EndIf
	  
    Offset = Round((ListView()\HScroll\Pos - ListView()\HScroll\minPos) * ListView()\HScroll\Factor, #PB_Round_Nearest)
    ListView()\HScroll\Thumb\X = ListView()\HScroll\Area\X + Offset

	EndProcedure
	
	Procedure   SetThumbPosY_(Pos.i) ; Vertical Scrollbar
	  Define.i  Offset
	  
	  ListView()\VScroll\Pos = Pos

	  If ListView()\VScroll\Pos < ListView()\VScroll\minPos : ListView()\VScroll\Pos = ListView()\VScroll\minPos : EndIf
	  If ListView()\VScroll\Pos > ListView()\VScroll\maxPos : ListView()\VScroll\Pos = ListView()\VScroll\maxPos : EndIf
	  
    Offset = Round((ListView()\VScroll\Pos - ListView()\VScroll\minPos) * ListView()\VScroll\Factor, #PB_Round_Nearest)
    ListView()\VScroll\Thumb\Y = ListView()\VScroll\Area\Y + Offset

	EndProcedure	
	

	Procedure.i CalcWidth_()
	  Define.i Width, RowHeight, TextHeight, OffsetX, imgHeight, imgWidth, Factor
	  
	  ListView()\maxWidth = 0
	  
	  If StartDrawing(CanvasOutput(ListView()\CanvasNum))
	    
	    DrawingFont(ListView()\FontID)
      TextHeight = TextHeight_("Abc")
      
      ;{ RowHeight & Vertical Center
      If ListView()\Rows\Height <> #PB_Default
        RowHeight = ListView()\Rows\Height
      Else
        If ListView()\Flags & #GridLines
          RowHeight = TextHeight + 6
        Else
          RowHeight = TextHeight + 2
        EndIf
        ListView()\Rows\Height = RowHeight
      EndIf ;}
      
  	  ForEach ListView()\Item()
  	    
  	    Width   = 5
  	    
        If ListView()\Flags & #CheckBoxes
          Width + (TextHeight - 1)
        EndIf  

        If ListView()\Item()\Flags & #Image
          
          If IsImage(ListView()\Item()\Image\Num)
            
            imgHeight = RowHeight - 2
            
            If ListView()\Item()\Image\Height <= imgHeight
              imgWidth  = ListView()\Item()\Image\Height
              imgHeight = ListView()\Item()\Image\Width
            Else
              Factor    = imgHeight / ListView()\Item()\Image\Height
              imgWidth  = imgHeight * Factor
            EndIf
            
            Width + imgWidth + 5
            
          EndIf
        EndIf
        
        Width + TextWidth_(ListView()\Item()\String)
        
        If Width > ListView()\maxWidth : ListView()\maxWidth = Width : EndIf 
        
      Next
        
      StopDrawing() 
    EndIf    
 
	EndProcedure  

  Procedure   AdjustScrollBars_()
    Define.i maxHeight, Height, Width, PageRows
    Define.i ScrollbarSize
    
    Width  = GadgetWidth(ListView()\CanvasNum)  - 2
    Height = GadgetHeight(ListView()\CanvasNum) - 2
    
    ScrollbarSize = ListView()\Scrollbar\Size
    
    CalcWidth_()
    
    maxHeight = ListSize(ListView()\Item()) * ListView()\Rows\Height
    
    ; --- Size without Scrollbars ---
    If maxHeight > Height
      Width - ScrollbarSize
    EndIf  
    
    If ListView()\maxWidth > Width
      Height - ScrollbarSize
    EndIf
    
    PageRows = Round((Height - 6) / ListView()\Rows\Height, #PB_Round_Down)
    
    ; --- Size with Scrollbars ---
    If maxHeight > Height ; Vertical Scrollbar
      ListView()\VScroll\Minimum    = 0
      ListView()\VScroll\Maximum    = ListSize(ListView()\Item())
      ListView()\VScroll\PageLength = PageRows
      ListView()\VScroll\Hide       = #False
    Else
      ListView()\VScroll\Minimum    = 0
      ListView()\VScroll\Maximum    = 0
      ListView()\VScroll\PageLength = 0
      ListView()\VScroll\Hide       = #True
    EndIf  
    
    If ListView()\maxWidth > Width ; Horizontal Scrollbar
      ListView()\HScroll\Minimum    = 0
      ListView()\HScroll\Maximum    = ListView()\maxWidth
      ListView()\HScroll\PageLength = ListView()\Area\Width
      ListView()\HScroll\Hide       = #False
    Else
      ListView()\HScroll\Minimum    = 0
      ListView()\HScroll\Maximum    = 0
      ListView()\HScroll\PageLength = 0
      ListView()\HScroll\Hide       = #True
    EndIf

    CalcScrollRange_()
    
  EndProcedure
	;}

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
	    Case #Scrollbar_Down
	      X       = ListView()\VScroll\Buttons\fX
	      Y       = ListView()\VScroll\Buttons\fY
	      Width   = ListView()\VScroll\Buttons\Width
	      Height  = ListView()\VScroll\Buttons\Height
	    Case #Scrollbar_Up
	      X       = ListView()\VScroll\Buttons\bX
	      Y       = ListView()\VScroll\Buttons\bY
	      Width   = ListView()\VScroll\Buttons\Width
	      Height  = ListView()\VScroll\Buttons\Height
	    Case #Scrollbar_Left
	      X       = ListView()\HScroll\Buttons\bX
	      Y       = ListView()\HScroll\Buttons\bY
	      Width   = ListView()\HScroll\Buttons\Width
	      Height  = ListView()\HScroll\Buttons\Height
	    Case #Scrollbar_Right
	      X       = ListView()\HScroll\Buttons\fX
	      Y       = ListView()\HScroll\Buttons\fY
	      Width   = ListView()\HScroll\Buttons\Width
	      Height  = ListView()\HScroll\Buttons\Height 
	  EndSelect ;}
	  
	  If ListView()\Scrollbar\Flags & #Style_Win11 ;{ Arrow Size
	    
	    If Direction = #Scrollbar_Down Or Direction = #Scrollbar_Up 
	      aWidth  = 10
    	  aHeight =  7
	    Else
	      aWidth  =  7
        aHeight = 10  
	    EndIf   
	    
	    If ListView()\HScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If ListView()\HScroll\Buttons\fState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	    If ListView()\VScroll\Buttons\bState = #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf 
	    
	    If ListView()\VScroll\Buttons\fState= #Click
	      aWidth  - 2
        aHeight - 2 
	    EndIf
	    
	  Else
	    
	    If Direction = #Scrollbar_Down Or Direction = #Scrollbar_Up
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
	  
	  If StartVectorDrawing(CanvasVectorOutput(ListView()\CanvasNum))

      If ListView()\Scrollbar\Flags & #Style_Win11 ;{ solid

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
  
	Procedure   DrawScrollButton_(Scrollbar.i, Type.i)
	  Define.i X, Y, Width, Height
	  Define.i ArrowColor, ButtonColor, Direction, State
	  
	  Select Scrollbar ;{ Position, Size, State & Direction
	    Case #Horizontal
	      
	      If ListView()\HScroll\Hide : ProcedureReturn #False : EndIf
	      
        Width  = ListView()\HScroll\Buttons\Width
        Height = ListView()\HScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X      = ListView()\HScroll\Buttons\fX
            Y      = ListView()\HScroll\Buttons\fY
            State  = ListView()\HScroll\Buttons\fState
            Direction = #Scrollbar_Right
  	      Case #Backwards
  	        X     = ListView()\HScroll\Buttons\bX
            Y     = ListView()\HScroll\Buttons\bY
            State = ListView()\HScroll\Buttons\bState
            Direction = #Scrollbar_Left
  	    EndSelect 
        
      Case #Vertical
        
        If ListView()\VScroll\Hide : ProcedureReturn #False : EndIf
        
        Width  = ListView()\VScroll\Buttons\Width
        Height = ListView()\VScroll\Buttons\Height
        
        Select Type
          Case #Forwards
            X     = ListView()\VScroll\Buttons\fX
            Y     = ListView()\VScroll\Buttons\fY
            State = ListView()\VScroll\Buttons\fState
            Direction = #Scrollbar_Down
  	      Case #Backwards
  	        X     = ListView()\VScroll\Buttons\bX
            Y     = ListView()\VScroll\Buttons\bY
            State = ListView()\VScroll\Buttons\bState
            Direction = #Scrollbar_Up
        EndSelect
        ;}
    EndSelect    
    
    ;{ ----- Colors -----
    If ListView()\Scrollbar\Flags & #Style_Win11
      
      ButtonColor = ListView()\Scrollbar\Color\Back
      
      Select State
	      Case #Focus
	        ArrowColor = ListView()\Scrollbar\Color\Focus
	      Case #Hover
	        ArrowColor = ListView()\Scrollbar\Color\Hover
	      Case #Click  
	        ArrowColor = ListView()\Scrollbar\Color\Arrow
	      Default
	        ArrowColor = #PB_Default
	    EndSelect    

    Else
      
      Select State
	      Case #Hover
	        ButtonColor  = BlendColor_(ListView()\Scrollbar\Color\Focus, ListView()\Scrollbar\Color\Button, 10)
	      Case #Click
	        ButtonColor  = BlendColor_(ListView()\Scrollbar\Color\Focus, ListView()\Scrollbar\Color\Button, 20)
	      Default
	        ButtonColor  = ListView()\Scrollbar\Color\Button
	    EndSelect  
	    
	    ArrowColor = ListView()\Scrollbar\Color\Arrow
	    
	  EndIf 
	  ;}
    
	  ;{ ----- Draw button -----
	  If StartDrawing(CanvasOutput(ListView()\CanvasNum))
	    
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
	      
	      If ListView()\HScroll\Hide : ProcedureReturn #False : EndIf
	      
	      ThumbState = ListView()\HScroll\Thumb\State
	      
	    Case #Vertical
	      
	      If ListView()\VScroll\Hide : ProcedureReturn #False : EndIf
	      
  	    ThumbState = ListView()\VScroll\Thumb\State
  	    
  	EndSelect ;}    
  	
  	;{ ----- Colors -----
	  If ListView()\Scrollbar\Flags & #Style_Win11 
	    
	    BackColor = ListView()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = ListView()\Scrollbar\Color\Focus
	      Case #Hover
	        ThumbColor = ListView()\Scrollbar\Color\Hover
	      Case #Click
	        ThumbColor = ListView()\Scrollbar\Color\Hover
	      Default
	        ThumbColor = ListView()\Scrollbar\Color\Focus
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
	    
	    BackColor = ListView()\Scrollbar\Color\Back
	    
	    Select ThumbState
	      Case #Focus
	        ThumbColor = BlendColor_(ListView()\Scrollbar\Color\Focus, ListView()\Scrollbar\Color\Front, 10)
	      Case #Hover
	        ThumbColor = BlendColor_(ListView()\Scrollbar\Color\Focus, ListView()\Scrollbar\Color\Hover, 10)
	      Case #Click
	        ThumbColor = BlendColor_(ListView()\Scrollbar\Color\Focus, ListView()\Scrollbar\Color\Front, 20)
	      Default
	        ThumbColor = ListView()\Scrollbar\Color\Front
	    EndSelect 
	    
	    If ListView()\Scrollbar\Flags & #Style_RoundThumb
	      Round = 4
	    Else
	      Round = #False
	    EndIf
	    
	  EndIf ;}  
	  
	  If StartDrawing(CanvasOutput(ListView()\CanvasNum))
	    
	    DrawingMode(#PB_2DDrawing_Default)

	    Select Scrollbar 
  	    Case #Horizontal
  	      
  	      Box_(ListView()\HScroll\Area\X, ListView()\HScroll\Area\Y, ListView()\HScroll\Area\Width, ListView()\HScroll\Area\Height, BackColor)
  	      
      	  Box_(ListView()\HScroll\Thumb\X, ListView()\HScroll\Thumb\Y + OffsetPos, ListView()\HScroll\Thumb\Width, ListView()\HScroll\Thumb\Height + OffsetSize, ThumbColor, Round)
      	  
      	Case #Vertical

      	  Box_(ListView()\VScroll\Area\X, ListView()\VScroll\Area\Y, ListView()\VScroll\Area\Width, ListView()\VScroll\Area\Height, BackColor)

      	  Box_(ListView()\VScroll\Thumb\X + OffsetPos, ListView()\VScroll\Thumb\Y, ListView()\VScroll\Thumb\Width + OffsetSize, ListView()\VScroll\Thumb\Height, ThumbColor, Round)

  	  EndSelect

  	  StopDrawing()
	  EndIf  
  	
	EndProcedure  
	
	Procedure   DrawScrollBar_(ScrollBar.i=#False)
		Define.i OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		CalcScrollBar_()

  	;{ ----- thumb position -----
		If ListView()\Scrollbar\Flags & #Horizontal
		  OffsetX = Round((ListView()\HScroll\Pos - ListView()\HScroll\minPos) * ListView()\HScroll\Factor, #PB_Round_Nearest)
		  ListView()\HScroll\Thumb\X = ListView()\HScroll\Area\X + OffsetX
  	EndIf
		
		If ListView()\Scrollbar\Flags & #Vertical
		  OffsetY = Round((ListView()\VScroll\Pos - ListView()\VScroll\minPos) * ListView()\VScroll\Factor, #PB_Round_Nearest)
		  ListView()\VScroll\Thumb\Y = ListView()\VScroll\Area\Y + OffsetY
		EndIf ;}
		
		If StartDrawing(CanvasOutput(ListView()\CanvasNum)) ; Draw scrollbar background
      
		  DrawingMode(#PB_2DDrawing_Default)
		  
		  If ListView()\Scrollbar\Flags & #Horizontal And ListView()\Scrollbar\Flags & #Vertical
		    
  		  If ScrollBar = #Horizontal|#Vertical
      		
  		    If ListView()\HScroll\Hide = #False
  		      Box_(ListView()\HScroll\X, ListView()\HScroll\Y, GadgetWidth(ListView()\CanvasNum) - 2, ListView()\HScroll\Height, ListView()\Color\Gadget)
  		    EndIf 
  
  		    If ListView()\VScroll\Hide = #False
  		      Box_(ListView()\VScroll\X, ListView()\VScroll\Y, ListView()\VScroll\Width, GadgetHeight(ListView()\CanvasNum) - 2, ListView()\Color\Gadget)
  		    EndIf
  		    
  		  EndIf 
  		  
  		ElseIf ListView()\Scrollbar\Flags & #Horizontal
  		  
  		  If ScrollBar = #Horizontal
  		    If ListView()\HScroll\Hide = #False
  		      Box_(ListView()\HScroll\X, ListView()\HScroll\Y, GadgetWidth(ListView()\CanvasNum) - 2, ListView()\HScroll\Height, ListView()\Color\Gadget)
  		    EndIf
  		  EndIf
  		    
		  ElseIf ListView()\Scrollbar\Flags & #Vertical
		    
		    If ScrollBar = #Vertical
  		    If ListView()\VScroll\Hide = #False
  		      Box_(ListView()\VScroll\X, ListView()\VScroll\Y, ListView()\VScroll\Width, GadgetHeight(ListView()\CanvasNum) - 2, ListView()\Color\Gadget)
  		    EndIf
  		  EndIf
  		  
		  EndIf  
		  
		  StopDrawing()
		EndIf
		
		Select ScrollBar
		  Case #Horizontal  
		    If ListView()\HScroll\Hide = #False
      		DrawThumb_(#Horizontal)
        EndIf		
  		Case #Vertical
  		  If ListView()\VScroll\Hide = #False
      		DrawThumb_(#Vertical)
    		EndIf 
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
		  Case #Horizontal|#Vertical
		    If ListView()\HScroll\Hide = #False
    		  DrawScrollButton_(#Horizontal, #Forwards)
    		  DrawScrollButton_(#Horizontal, #Backwards)
    		  DrawThumb_(#Horizontal)
    		EndIf
    		If ListView()\VScroll\Hide = #False
    		  DrawScrollButton_(#Vertical, #Forwards)
    		  DrawScrollButton_(#Vertical, #Backwards)
    		  DrawThumb_(#Vertical)
    		EndIf 
		EndSelect    

	EndProcedure
	
  
	Procedure.i CheckBox_(X.i, Y.i, Width.i, Height.i, boxWidth.i, FrontColor.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
    
    If boxWidth <= Width And boxWidth <= Height
      
      Y + ((Height - boxWidth) / 2)
      
      Box_(X, Y, boxWidth, boxWidth, BackColor)
      
      LineColor = BlendColor_(FrontColor, BackColor, 60)
      
      If State & #Checked

        bColor = BlendColor_(LineColor, ListView()\Color\CheckBox)
        
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
        
        Box_(X, Y, boxWidth, boxWidth, BlendColor_(LineColor, BackColor, 50))
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(X + 2, Y + 2, boxWidth - 4, boxWidth - 4, BlendColor_(LineColor, BackColor, 5))
      Box_(X + 1, Y + 1, boxWidth - 2, boxWidth - 2, BlendColor_(LineColor, BackColor, 25))
      Box_(X, Y, boxWidth, boxWidth, LineColor)
      
      ListView()\Item()\CheckBox\X    = X
      ListView()\Item()\CheckBox\Y    = Y
      ListView()\Item()\CheckBox\Size = boxWidth
      
    EndIf
    
  EndProcedure

	Procedure   Draw_(ScrollBar.i=#False)
	  Define.i X, Y, Width, Height, OffsetX, OffsetY
	  Define.i imgX, imgY, imgHeight, imgWidth, Pos, wordX
		Define.i TextHeight, RowHeight, boxSize, maxHeight, PageRows
    Define.i FrontColor, BackColor, BorderColor, ItemFrontColor, ItemBackColor
    Define.f Factor
    
		If ListView()\Hide : ProcedureReturn #False : EndIf 

    ;{ --- Color --- 
    FrontColor  = ListView()\Color\Front
    BackColor   = ListView()\Color\Back
    BorderColor = ListView()\Color\Border
    
    If ListView()\Disable
      FrontColor  = ListView()\Color\DisableFront
      BackColor   = ListView()\Color\DisableBack
      BorderColor = ListView()\Color\DisableFront
      ListView()\State = #PB_Default
      ListView()\Focus = #PB_Default
    EndIf  
    ;}
    
    If StartDrawing(CanvasOutput(ListView()\CanvasNum))
      
      Width  = ListView()\Area\Width
      Height = ListView()\Area\Height
      
      ClipOutput_(1, 1, Width, Height)
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(1, 1, Width, Height, BackColor)
      ;}
      
      X = 0
      Y = 3
      
      If ListView()\Flags & #GridLines : Y = 0 : EndIf 
      
      DrawingFont(ListView()\FontID)
      
      TextHeight = TextHeight_("X")
      
      ;ListView()\Scrollbar\ScrollV = TextHeight
      ListView()\Scrollbar\ScrollH = TextWidth_("ABC")
      
      ListView()\Rows\Offset = ListView()\VScroll\Pos
      ListView()\OffsetH     = ListView()\HScroll\Pos
      
      ;{ RowHeight & Vertical Center
      If ListView()\Rows\Height <> #PB_Default
        RowHeight = ListView()\Rows\Height
        OffsetY   = (RowHeight - TextHeight) / 2
      Else
        If ListView()\Flags & #GridLines
          RowHeight = TextHeight + 6
          OffsetY   = 3
        Else
          RowHeight = TextHeight + 2
          OffsetY   = 1
        EndIf
        ListView()\Rows\Height = RowHeight
      EndIf ;}
      
      If OffsetY < 0 : OffsetY = 0 : EndIf
      
      ;{ _____ Rows _____
      ClipOutput_(0, 0, Width, Height)
      
      ListView()\maxWidth = 0
      
      ForEach ListView()\Item()
        
        If ListIndex(ListView()\Item()) < ListView()\Rows\Offset
          ListView()\Item()\Y = 0
          Continue
        EndIf  
        
        ;{ Colors
        If ListView()\Disable
          ItemFrontColor = ListView()\Color\DisableFront
          ItemBackColor  = ListView()\Color\DisableBack
        Else
          If ListView()\Item()\Color\Front = #PB_Default
            ItemFrontColor = FrontColor
          Else
            ItemFrontColor = ListView()\Item()\Color\Front
          EndIf   
          If ListView()\Item()\Color\Back = #PB_Default
            ItemBackColor = BackColor
          Else
            ItemBackColor = ListView()\Item()\Color\Back
          EndIf  
        EndIf ;}  
        
        ListView()\Item()\Y = Y
        
        ;{ Row background
        DrawingMode(#PB_2DDrawing_Default)
        If ListView()\Flags & #ClickSelect And ListView()\Item()\State & #Selected
          ItemBackColor = ListView()\Color\FocusBack
          Box_(0, Y, Width, RowHeight, ItemBackColor)
        ElseIf ListView()\State = ListIndex(ListView()\Item()) Or ListView()\Item()\State & #Selected
          ItemBackColor = ListView()\Color\FocusBack
          Box_(0, Y, Width, RowHeight, ItemBackColor)
        Else  
          If ListView()\Focus = ListIndex(ListView()\Item())
            ItemBackColor = BlendColor_(ListView()\Color\FocusBack, BackColor, 10)
            Box_(X - 2, Y, TextWidth_(ListView()\Item()\String) + 6, RowHeight, ItemBackColor)
          ElseIf ListView()\Item()\Color\Back <> #PB_Default
            Box_(X - 2, Y, Width, RowHeight, ItemBackColor)
          EndIf
        EndIf ;}
        
        ;{ Checkboxes
        If ListView()\Flags & #CheckBoxes
          boxSize = TextHeight - 2
          X = 3 
          CheckBox_(X - ListView()\OffsetH, Y, Width, RowHeight, boxSize, FrontColor, BackColor, ListView()\Item()\State)
          X + boxSize
        EndIf  
        ;}
        
        ;{ Text Align
        If ListView()\Item()\Flags & #Center
          OffsetX = (Width - TextWidth_(ListView()\Item()\String)) / 2
        ElseIf ListView()\Item()\Flags & #Right
          OffsetX = Width - TextWidth_(ListView()\Item()\String) - 5
        Else
          OffsetX = 5
        EndIf ;}        
        
        If ListView()\Item()\Flags & #Image
          
          If IsImage(ListView()\Item()\Image\Num)
            
            ;{ Image Height
            imgHeight = RowHeight - 2
            
            If ListView()\Item()\Image\Height <= imgHeight
              imgWidth  = ListView()\Item()\Image\Height
              imgHeight = ListView()\Item()\Image\Width
            Else
              Factor    = imgHeight / ListView()\Item()\Image\Height
              imgWidth  = imgHeight * Factor
            EndIf ;}
            
            ;{ Horizontal Align
            If ListView()\Item()\Image\Flags & #Center
              ImgX = (Width - imgWidth) / 2
            ElseIf ListView()\Item()\Image\Flags & #Right
              If ListView()\Item()\String
                If Not ListView()\Item()\Flags & #Center And Not ListView()\Item()\Flags & #Right
                  ImgX = TextWidth_(ListView()\Item()\String) + 10
                Else
                  ImgX = Width - imgWidth - 5
                EndIf 
              Else  
                ImgX = Width - imgWidth - 5
              EndIf  
            Else
              ImgX = 5
              If Not ListView()\Item()\Flags & #Center And Not ListView()\Item()\Flags & #Right
                OffsetX + imgWidth + 5
              EndIf   
            EndIf ;}
            
            ;{ Vertical Align
            If ListView()\Item()\Image\Height < imgHeight
              imgY = (RowHeight - ListView()\Item()\Image\Height) / 2
            Else
              imgY = 1
            EndIf ;}

          Else  
            ListView()\Item()\Flags & ~#Image
          EndIf
          
        EndIf
        
        X - ListView()\OffsetH
        
        ;{ Text
        DrawingMode(#PB_2DDrawing_Transparent)
        If ListView()\Flags & #ClickSelect And ListView()\Item()\State & #Selected
          DrawText_(X + OffsetX, Y + OffsetY, ListView()\Item()\String, ListView()\Color\FocusFront)
        ElseIf ListView()\State = ListIndex(ListView()\Item()) Or ListView()\Item()\State & #Selected
          DrawText_(X + OffsetX, Y + OffsetY, ListView()\Item()\String, ListView()\Color\FocusFront)
        Else
          If ListView()\Item()\Color\Front <> #PB_Default
            DrawText_(X + OffsetX, Y + OffsetY, ListView()\Item()\String, ItemFrontColor)
          Else
            DrawText_(X + OffsetX, Y + OffsetY, ListView()\Item()\String, FrontColor)
          EndIf
        EndIf ;}
        
        CompilerIf #Enable_SyntaxHighlight
          ForEach ListView()\Syntax()
            Pos = FindString(ListView()\Item()\String, MapKey(ListView()\Syntax()))
            If Pos
              DrawingMode(#PB_2DDrawing_Default)
              wordX = TextWidth_(Left(ListView()\Item()\String, Pos - 1))
              DrawText_(X + OffsetX + wordX, Y + OffsetY, MapKey(ListView()\Syntax()), ListView()\Syntax(), ItemBackColor)
            EndIf  
          Next   
        CompilerEndIf
        
        If ListView()\Item()\Flags & #Image
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          DrawImage(ImageID(ListView()\Item()\Image\Num), X + imgX, Y + imgY, imgWidth, imgHeight)  
        EndIf  
        
        If ListView()\Flags & #GridLines ;{ Draw GridLines
          DrawingMode(#PB_2DDrawing_Outlined)
          If ListIndex(ListView()\Item()) < ListSize(ListView()\Item()) - 1
            Box_(0, Y, Width, RowHeight + 1, ListView()\Color\Grid)
          Else  
            Box_(0, Y, Width, RowHeight, ListView()\Color\Grid)
          EndIf  
        EndIf ;}
        
        Y + RowHeight
        
        If Y > Height : Break : EndIf
      Next
      
      UnclipOutput_()
      ;}
      
      UnclipOutput_()
      
      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(0, 0, GadgetWidth(ListView()\CanvasNum), GadgetHeight(ListView()\CanvasNum), BorderColor)
      ;}
      
      StopDrawing()
    EndIf
    
    DrawScrollBar_(ScrollBar)
    
	EndProcedure
	
	
	;- ============================================================================
	;-   Module - Events
	;- ============================================================================
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ListView()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ListView()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        If ModuleEx::ThemeGUI\ScrollBar : ListView()\ScrollBar\Flags = ModuleEx::ThemeGUI\ScrollBar : EndIf 
        
        ListView()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
				ListView()\Color\Back         = ModuleEx::ThemeGUI\BackColor
				ListView()\Color\Border       = ModuleEx::ThemeGUI\BorderColor
				ListView()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
				ListView()\Color\Grid         = ModuleEx::ThemeGUI\LineColor
				ListView()\Color\CheckBox     = ModuleEx::ThemeGUI\Button\BackColor
				ListView()\Color\FocusBack    = ModuleEx::ThemeGUI\Focus\FrontColor
        ListView()\Color\FocusFront   = ModuleEx::ThemeGUI\Focus\BackColor
				ListView()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
		    ListView()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
		    
		    ListView()\ScrollBar\Color\Front        = ModuleEx::ThemeGUI\FrontColor
  			ListView()\ScrollBar\Color\Back         = ModuleEx::ThemeGUI\BackColor
  			ListView()\ScrollBar\Color\Border       = ModuleEx::ThemeGUI\BorderColor
  			ListView()\ScrollBar\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
  			ListView()\ScrollBar\Color\Focus        = ModuleEx::ThemeGUI\FocusBack
        ListView()\ScrollBar\Color\Button       = ModuleEx::ThemeGUI\Button\BackColor
        ListView()\ScrollBar\Color\ScrollBar    = ModuleEx::ThemeGUI\ScrollbarColor
		    
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
  
  
  Procedure _AutoScroll()
    Define.i X, Y
    
    LockMutex(Mutex)
    
    ForEach ListView()

      If ListView()\HScroll\Timer ;{ Horizontal Scrollbar
        
        If ListView()\HScroll\Delay
          ListView()\HScroll\Delay - 1
          Continue
        EndIf  
        
        Select ListView()\HScroll\Timer
          Case #Scrollbar_Left
            SetThumbPosX_(ListView()\HScroll\Pos - 1)
          Case #Scrollbar_Right
            SetThumbPosX_(ListView()\HScroll\Pos + 1)
        EndSelect
        
        Draw_(#Horizontal)
  			;}
      EndIf   
      
      If ListView()\VScroll\Timer ;{ Vertical Scrollbar
        
        If ListView()\VScroll\Delay
          ListView()\VScroll\Delay - 1
          Continue
        EndIf  
        
        Select ListView()\VScroll\Timer
          Case #Scrollbar_Up
            SetThumbPosY_(ListView()\VScroll\Pos - 1)
          Case #Scrollbar_Down
            SetThumbPosY_(ListView()\VScroll\Pos + 1)
  			EndSelect
  			
  			Draw_(#Vertical)
  			;}
      EndIf   
      
    Next
    
    UnlockMutex(Mutex)
    
  EndProcedure
  
  
	Procedure _LeftDoubleClickHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(ListView(), Str(GNum))

			X = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseY)
			
			ForEach ListView()\Item()
			  
        If Y >= ListView()\Item()\Y And Y <= ListView()\Item()\Y + ListView()\Rows\Height
          PostEvent(#Event_Gadget, ListView()\Window\Num, ListView()\CanvasNum, #PB_EventType_LeftDoubleClick, ListIndex(ListView()\Item()))
          ProcedureReturn #True
        EndIf
        
      Next
			
		EndIf

	EndProcedure

	Procedure _RightClickHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(ListView(), Str(GNum))

			X = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseY)
			
			ForEach ListView()\Item()
			  
        If Y >= ListView()\Item()\Y And Y <= ListView()\Item()\Y + ListView()\Rows\Height
          
          ListView()\State = ListIndex(ListView()\Item())
          
          If IsMenu(ListView()\PopUpNum) : UpdatePopUpMenu_() : EndIf
          
          Draw_()
          
          If IsWindow(ListView()\Window\Num) And IsMenu(ListView()\PopUpNum)
    				DisplayPopupMenu(ListView()\PopUpNum, WindowID(ListView()\Window\Num))
    			Else
    			  PostEvent(#Event_Gadget, ListView()\Window\Num, ListView()\CanvasNum, #PB_EventType_RightClick, ListIndex(ListView()\Item()))
    			EndIf

          Break
        EndIf
        
      Next

		EndIf

	EndProcedure
	
	
	Procedure _LeftButtonDownHandler()
	  Define.i X, Y, dX, dY, Index, Clear
	  Define.i Row = #PB_Default
		Define.i GNum = EventGadget()

		If FindMapElement(ListView(), Str(GNum))

			dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
			
			X = DesktopUnscaledX(dX)
			Y = DesktopUnscaledY(dY)
			
		  ;{ Horizontal Scrollbar
		  If ListView()\HScroll\Hide = #False
		    
		    If dY > dpiY(ListView()\HScroll\Y) And dY < dpiY(ListView()\HScroll\Y + ListView()\HScroll\Height)
			    If dX > dpiX(ListView()\HScroll\X) And dX < dpiX(ListView()\HScroll\X + ListView()\HScroll\Width)
		    
    			  ListView()\HScroll\CursorPos = #PB_Default
    			  
    			  If ListView()\HScroll\Focus
    			    
      			  If dX > dpiX(ListView()\HScroll\Buttons\bX) And  dX < dpiX(ListView()\HScroll\Buttons\bX + ListView()\HScroll\Buttons\Width)
      			    
      			    ; --- Backwards Button ---
      			    If ListView()\HScroll\Buttons\bState <> #Click
      			      ListView()\HScroll\Delay = ListView()\Scrollbar\TimerDelay
      			      ListView()\HScroll\Timer = #Scrollbar_Left
      			      ListView()\HScroll\Buttons\bState = #Click
      			      DrawScrollButton_(#Horizontal, #Backwards)
      			    EndIf
      			    
      			  ElseIf dX > dpiX(ListView()\HScroll\Buttons\fX) And  dX < dpiX(ListView()\HScroll\Buttons\fX + ListView()\HScroll\Buttons\Width)
      			    
      			    ; --- Forwards Button ---
      			    If ListView()\HScroll\Buttons\fState <> #Click
      			      ListView()\HScroll\Delay = ListView()\Scrollbar\TimerDelay
      			      ListView()\HScroll\Timer = #Scrollbar_Right
      			      ListView()\HScroll\Buttons\fState = #Click
      			      DrawScrollButton_(#Horizontal, #Forwards)
      			    EndIf
      			    
      			  ElseIf  dX > dpiX(ListView()\HScroll\Thumb\X) And dX < dpiX(ListView()\HScroll\Thumb\X + ListView()\HScroll\Thumb\Width)
      			    
      			    ; --- Thumb Button ---
      			    If ListView()\HScroll\Thumb\State <> #Click
      			      ListView()\HScroll\Thumb\State = #Click
      			      ListView()\HScroll\CursorPos = X
      			      Draw_(#Horizontal)
      			    EndIf
    			    
      			  EndIf
      			  
      			EndIf
      			
      			ProcedureReturn #True
      		EndIf
      	EndIf	
  			
  		EndIf ;}
			 
		  ;{ Vertical Scrollbar
		  If ListView()\VScroll\Hide = #False
		    
		    If dX > dpiX(ListView()\VScroll\X) And dX < dpiX(ListView()\VScroll\X + ListView()\VScroll\Width)
			    If dY > dpiY(ListView()\VScroll\Y) And dY < dpiY(ListView()\VScroll\Y + ListView()\VScroll\Height)
		    
    			  ListView()\VScroll\CursorPos = #PB_Default
    			  
    			  If ListView()\VScroll\Focus
    			    
    			    If dY > dpiY(ListView()\VScroll\Buttons\bY) And dY < dpiY(ListView()\VScroll\Buttons\bY + ListView()\VScroll\Buttons\Height)
    
    			      If ListView()\VScroll\Buttons\bState <> #Click
    			        ; --- Backwards Button ---
      			      ListView()\VScroll\Delay = ListView()\Scrollbar\TimerDelay
      			      ListView()\VScroll\Timer = #Scrollbar_Up
      			      ListView()\VScroll\Buttons\bState = #Click
      			      DrawScrollButton_(#Vertical, #Backwards)
      			    EndIf
      			    
    			    ElseIf dY > dpiY(ListView()\VScroll\Buttons\fY) And dY < dpiY(ListView()\VScroll\Buttons\fY + ListView()\VScroll\Buttons\Height)
    			      
    			      ; --- Forwards Button ---
      			    If ListView()\VScroll\Buttons\fState <> #Click
      			      ListView()\VScroll\Delay = ListView()\Scrollbar\TimerDelay
      			      ListView()\VScroll\Timer = #Scrollbar_Down
      			      ListView()\VScroll\Buttons\fState = #Click
      			      DrawScrollButton_(#Vertical, #Forwards)
      			    EndIf
    			      
    			    ElseIf  dY > dpiY(ListView()\VScroll\Thumb\Y) And dY < dpiY(ListView()\VScroll\Thumb\Y + ListView()\VScroll\Thumb\Height)
    			      
    			      ; --- Thumb Button ---
      			    If ListView()\VScroll\Thumb\State <> #Click
      			      ListView()\VScroll\Thumb\State = #Click
      			      ListView()\VScroll\CursorPos = Y
      			      Draw_(#Vertical)
      			    EndIf
    			      
    			    EndIf  
    
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf
    		EndIf
    		
			EndIf ;}
			
			ForEach ListView()\Item()   ;{ List

			  If Y >= ListView()\Item()\Y And Y <= ListView()\Item()\Y + ListView()\Rows\Height
			    
			    If ListView()\Flags & #CheckBoxes ;{ #CheckBoxes enabled
			      
  			    If X >= ListView()\Item()\CheckBox\X And X <= ListView()\Item()\CheckBox\X + ListView()\Item()\CheckBox\Size
  			      
  			      If ListView()\Flags & #ThreeState ;{ #ThreeState
  			        
  			        If ListView()\Item()\State & #Checked
  			          ListView()\Item()\State & ~#Checked
  			          ListView()\Item()\State | #Inbetween
  			        ElseIf ListView()\Item()\State & #Inbetween
  			          ListView()\Item()\State & ~#Inbetween
  			        Else
  			          ListView()\Item()\State | #Checked
  			        EndIf
  			        ;}
  			      Else
  			        
  			        If ListView()\Item()\State & #Checked
  			          ListView()\Item()\State & ~#Checked
  			        Else
  			          ListView()\Item()\State | #Checked
  			        EndIf  
  			        
  			      EndIf
  			      
  			      Draw_()
  			      
  			      ProcedureReturn #True
  			    EndIf
  			    ;}
  			  EndIf
			  
			    Select GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_Modifiers)
			      Case #PB_Canvas_Shift   ;{ Shift-Select
			        
			        If ListView()\Flags & #MultiSelect
			          Row = ListIndex(ListView()\Item())
			        EndIf  
			        ;}
			      Case #PB_Canvas_Control ;{ Ctrl-Select

			        If ListView()\Flags & #MultiSelect
			          If ListView()\State = ListIndex(ListView()\Item())
			            ListView()\Item()\State = #False
			            ListView()\State = #PB_Default
			          Else
			            If ListView()\Item()\State & #Selected
			              ListView()\Item()\State & ~#Selected
			            Else
			              ListView()\Item()\State | #Selected
			            EndIf   
			          EndIf
			        EndIf 
			        ;}
			      Default                 ;{ Click
			        
			        If ListView()\Flags & #ClickSelect
			          
			          If ListView()\Item()\State & #Selected
		              ListView()\Item()\State & ~#Selected
		            Else
		              ListView()\Item()\State | #Selected
		            EndIf  
			          
  		          If ListView()\Item()\State & #Selected
  		            ListView()\State = ListIndex(ListView()\Item())
  		            PostEvent(#Event_Gadget, ListView()\Window\Num, ListView()\CanvasNum, #PB_EventType_LeftClick, ListIndex(ListView()\Item()))
  		          Else
  		            ListView()\State = #PB_Default
  		          EndIf
  		          
  		        Else
  		          Clear = #True
  		          ListView()\State = ListIndex(ListView()\Item())
  		          PostEvent(#Event_Gadget, ListView()\Window\Num, ListView()\CanvasNum, #PB_EventType_LeftClick, ListIndex(ListView()\Item()))
  		        EndIf  
              ;}
			    EndSelect
			    
			    Break
        EndIf 
        ;}
      Next
      
      If ListView()\Flags & #MultiSelect
        
        If Clear                  ;{ Reset Selection
          
          ForEach ListView()\Item()
            ListView()\Item()\State & ~#Selected
          Next  
          ;}
        ElseIf Row <> #PB_Default ;{ Shift - Select
          
          If Row > ListView()\State
            
            ForEach ListView()\Item()
              Index = ListIndex(ListView()\Item())
              If Index >= ListView()\State And Index <= Row
                ListView()\Item()\State | #Selected
              Else
                ListView()\Item()\State & ~#Selected
              EndIf
            Next
            
          ElseIf Row < ListView()\State
            
            ForEach ListView()\Item()
              Index = ListIndex(ListView()\Item())
              If Index >= Row And Index <= ListView()\State
                ListView()\Item()\State | #Selected
              Else
                ListView()\Item()\State & ~#Selected
              EndIf
            Next 
            
          Else
            
            If SelectElement(ListView()\Item(), ListView()\State)
              ListView()\Item()\State | #Selected
            EndIf  
            
          EndIf
          ;} 
        EndIf
        
		  EndIf
  	
		  Draw_()
		  
		EndIf

	EndProcedure
	
	Procedure _LeftButtonUpHandler()
	  Define.i X, Y, dX, dY
	  Define.i GNum = EventGadget()
	  
		If FindMapElement(ListView(), Str(GNum))

			dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
			
			X = DesktopUnscaledX(dX)
			Y = DesktopUnscaledY(dY)
		
		  ;{ Horizontal Scrollbar
		  If ListView()\HScroll\Hide = #False
		    
		    If dY > dpiY(ListView()\HScroll\Y) And dY < dpiY(ListView()\HScroll\Y + ListView()\HScroll\Height)
			    If dX > dpiX(ListView()\HScroll\X) And dX < dpiX(ListView()\HScroll\X + ListView()\HScroll\Width)
		    
    			  ListView()\HScroll\CursorPos = #PB_Default
    			  ListView()\HScroll\Timer     = #False
    			  
    			  If ListView()\HScroll\Focus
    			    
      			  If dX > dpiX(ListView()\HScroll\Buttons\bX) And  dX < dpiX(ListView()\HScroll\Buttons\bX + ListView()\HScroll\Buttons\Width)
      			    ; --- Backwards Button ---
      			    SetThumbPosX_(ListView()\HScroll\Pos - ListView()\Scrollbar\ScrollH)
      			    Draw_(#Horizontal)
      			  ElseIf dX > dpiX(ListView()\HScroll\Buttons\fX) And  dX < dpiX(ListView()\HScroll\Buttons\fX + ListView()\HScroll\Buttons\Width)
      			    ; --- Forwards Button ---
      			    SetThumbPosX_(ListView()\HScroll\Pos + ListView()\Scrollbar\ScrollH)
      			    Draw_(#Horizontal)
      			  ElseIf dX > dpiX(ListView()\HScroll\Area\X) And dX < dpiX(ListView()\HScroll\Thumb\X)
      			    ; --- Page left ---
      			    SetThumbPosX_(ListView()\HScroll\Pos - ListView()\HScroll\PageLength)
      			    Draw_(#Horizontal)
      			  ElseIf dX > dpiX(ListView()\HScroll\Thumb\X + ListView()\HScroll\Thumb\Width) And dX < dpiX(ListView()\HScroll\Area\X + ListView()\HScroll\Area\Width)
      			    ; --- Page right ---
      			    SetThumbPosX_(ListView()\HScroll\Pos + ListView()\HScroll\PageLength)
      			    Draw_(#Horizontal)
      			  EndIf
        			
      			EndIf 
      			
      			ProcedureReturn #True
      		EndIf
      	EndIf
      	
  		EndIf ;}  
		  
      ;{ Vertical Scrollbar
      If ListView()\VScroll\Hide = #False
        
        If dX > dpiX(ListView()\VScroll\X) And dX < dpiX(ListView()\VScroll\X + ListView()\VScroll\Width)
			    If dY > dpiY(ListView()\VScroll\Y) And dY < dpiY(ListView()\VScroll\Y + ListView()\VScroll\Height)
        
    			  ListView()\VScroll\CursorPos = #PB_Default
    			  ListView()\VScroll\Timer     = #False
    			  
    			  If ListView()\VScroll\Focus
    			    
      			  If dY > dpiY(ListView()\VScroll\Buttons\bY) And  dY < dpiY(ListView()\VScroll\Buttons\bY + ListView()\VScroll\Buttons\Height)
      			    ; --- Backwards Button ---
      			    SetThumbPosY_(ListView()\VScroll\Pos - 1)
      			    Draw_(#Vertical)
      			  ElseIf dY > dpiY(ListView()\VScroll\Buttons\fY) And  dY < dpiY(ListView()\VScroll\Buttons\fY + ListView()\VScroll\Buttons\Height)
      			    ; --- Forwards Button ---
      			    SetThumbPosY_(ListView()\VScroll\Pos + 1)
      			    Draw_(#Vertical)
      			  ElseIf dY > dpiY(ListView()\VScroll\Area\Y) And dY < dpiY(ListView()\VScroll\Thumb\Y)
      			    ; --- Page up ---
      			    SetThumbPosY_(ListView()\VScroll\Pos - ListView()\VScroll\PageLength)
      			    Draw_(#Vertical)
      			  ElseIf dY > dpiY(ListView()\VScroll\Thumb\Y + ListView()\VScroll\Thumb\Height) And dY < dpiY(ListView()\VScroll\Area\Y + ListView()\VScroll\Area\Height)
      			    ; --- Page down ---
      			    SetThumbPosY_(ListView()\VScroll\Pos + ListView()\VScroll\PageLength)
      			    Draw_(#Vertical)
      			  EndIf
        			
      			EndIf 
      			
      			ProcedureReturn #True
      		EndIf
      	EndIf
      	
  		EndIf	;}
	
    EndIf

	EndProcedure
	
	Procedure _MouseMoveHandler()
	  Define.i X, Y, dX, dY, Backwards, Forwards, Thumb, CursorPos
	  Define.i GNum = EventGadget()
	  
		If FindMapElement(ListView(), Str(GNum))

			dX = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			dY = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
			
			X = DesktopUnscaledX(dX)
			Y = DesktopUnscaledY(dY)

		  ;{ Horizontal Scrollbar
		  If ListView()\HScroll\Hide = #False
		  
			  ListView()\HScroll\Focus = #False
			  
			  Backwards = ListView()\HScroll\Buttons\bState
			  Forwards  = ListView()\HScroll\Buttons\fState
			  Thumb     = ListView()\HScroll\Thumb\State
			  
			  If dY > dpiY(ListView()\HScroll\Y) And dY < dpiY(ListView()\HScroll\Y + ListView()\HScroll\Height)
			    If dX > dpiX(ListView()\HScroll\X) And dX < dpiX(ListView()\HScroll\X + ListView()\HScroll\Width)
			      
			      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
			      
			      ; --- Focus Scrollbar ---  
			      ListView()\HScroll\Buttons\bState = #Focus
			      ListView()\HScroll\Buttons\fState = #Focus
			      ListView()\HScroll\Thumb\State    = #Focus
			      
			      ; --- Hover Buttons & Thumb ---
			      If dX > dpiX(ListView()\HScroll\Buttons\bX) And  dX < dpiX(ListView()\HScroll\Buttons\bX + ListView()\HScroll\Buttons\Width)
			        
			        ListView()\HScroll\Buttons\bState = #Hover
			        
			      ElseIf dX > dpiX(ListView()\HScroll\Buttons\fX) And  dX < dpiX(ListView()\HScroll\Buttons\fX + ListView()\HScroll\Buttons\Width)
			        
			        ListView()\HScroll\Buttons\fState = #Hover
			        
			      ElseIf dX > dpiX(ListView()\HScroll\Thumb\X) And dX < dpiX(ListView()\HScroll\Thumb\X + ListView()\HScroll\Thumb\Width)
			        
			        ListView()\HScroll\Thumb\State = #Hover
			        
			        ;{ --- Move thumb with cursor 
			        If ListView()\HScroll\CursorPos <> #PB_Default
			          
			          CursorPos = ListView()\HScroll\Pos
			          
  			        ListView()\HScroll\Pos = GetThumbPosX_(X)
  			        ListView()\HScroll\CursorPos = X
  			        
  			        If CursorPos <> ListView()\HScroll\Pos
  			          
  			          Draw_(#Horizontal)

  			        EndIf
  			        
  			      EndIf ;}
  			      
			      EndIf
			      
			      ListView()\HScroll\Focus = #True
			      
    		    If Backwards <> ListView()\HScroll\Buttons\bState : DrawScrollButton_(#Horizontal, #Backwards) : EndIf 
    		    If Forwards  <> ListView()\HScroll\Buttons\fState : DrawScrollButton_(#Horizontal, #Forwards)  : EndIf 
    		    If Thumb     <> ListView()\HScroll\Thumb\State    : DrawThumb_(#Horizontal)                    : EndIf

    		    ProcedureReturn #True
			    EndIf
  			EndIf
  		
    		If Not ListView()\HScroll\Focus
    		  
	        ListView()\HScroll\Buttons\bState = #False
	        ListView()\HScroll\Buttons\fState = #False
	        ListView()\HScroll\Thumb\State    = #False
	        
	        ListView()\HScroll\Timer = #False
	      EndIf
    		
    		If Backwards <> ListView()\HScroll\Buttons\bState : DrawScrollButton_(#Horizontal, #Backwards) : EndIf 
		    If Forwards  <> ListView()\HScroll\Buttons\fState : DrawScrollButton_(#Horizontal, #Forwards)  : EndIf 
		    If Thumb     <> ListView()\HScroll\Thumb\State    : DrawThumb_(#Horizontal)              : EndIf 
		    
		    ListView()\HScroll\CursorPos = #PB_Default
		    
		  EndIf ;} 
		
		  ;{ Vertikal Scrollbar
		  If ListView()\VScroll\Hide = #False
  		  ListView()\VScroll\Focus = #False
  		  
  		  Backwards = ListView()\VScroll\Buttons\bState
  		  Forwards  = ListView()\VScroll\Buttons\fState
  		  Thumb     = ListView()\VScroll\Thumb\State
  		  
  		  If dX > dpiX(ListView()\VScroll\X) And dX < dpiX(ListView()\VScroll\X + ListView()\VScroll\Width)
  		    If dY > dpiY(ListView()\VScroll\Y) And dY < dpiY(ListView()\VScroll\Y + ListView()\VScroll\Height)
  		     
  		      SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
  		      
  		      ; --- Focus Scrollbar ---  
  		      ListView()\VScroll\Buttons\bState = #Focus
  		      ListView()\VScroll\Buttons\fState = #Focus
  		      ListView()\VScroll\Thumb\State    = #Focus
  		      
  		      ; --- Hover Buttons & Thumb ---
  		      If dY > dpiY(ListView()\VScroll\Buttons\bY) And dY < dpiY(ListView()\VScroll\Buttons\bY + ListView()\VScroll\Buttons\Height)
  		        
  		        ListView()\VScroll\Buttons\bState = #Hover
  		        
  		      ElseIf dY > dpiY(ListView()\VScroll\Buttons\fY) And dY < dpiY(ListView()\VScroll\Buttons\fY + ListView()\VScroll\Buttons\Height)
  		        
  		        ListView()\VScroll\Buttons\fState = #Hover
  
  		      ElseIf dY > dpiY(ListView()\VScroll\Thumb\Y) And dY < dpiY(ListView()\VScroll\Thumb\Y + ListView()\VScroll\Thumb\Height)
  		        
  		        ListView()\VScroll\Thumb\State = #Hover
  		        
  		        ;{ --- Move thumb with cursor 
  		        If ListView()\VScroll\CursorPos <> #PB_Default
  		          
  		          CursorPos = ListView()\VScroll\Pos
  		          
  			        ListView()\VScroll\Pos       = GetThumbPosY_(Y)
  			        ListView()\VScroll\CursorPos = Y
  			        
  			        If CursorPos <> ListView()\VScroll\Pos
  			     
  			          Draw_(#Vertical)
  
  			        EndIf
  			        
  			      EndIf ;}
  
  			    EndIf   
  			    
  			    ListView()\VScroll\Focus = #True
  			    
  			    If Backwards <> ListView()\VScroll\Buttons\bState : DrawScrollButton_(#Vertical, #Backwards) : EndIf 
            If Forwards  <> ListView()\VScroll\Buttons\fState : DrawScrollButton_(#Vertical, #Forwards)  : EndIf 
            If Thumb     <> ListView()\VScroll\Thumb\State    : DrawThumb_(#Vertical)              : EndIf 
            
            ProcedureReturn #True
    			EndIf
    		EndIf
    		
    		If Not ListView()\VScroll\Focus
  
          ListView()\VScroll\Buttons\bState = #False
          ListView()\VScroll\Buttons\fState = #False
          ListView()\VScroll\Thumb\State    = #False
          
          ListView()\VScroll\Timer = #False
          
        EndIf   
        
        If Backwards <> ListView()\VScroll\Buttons\bState : DrawScrollButton_(#Vertical, #Backwards) : EndIf 
        If Forwards  <> ListView()\VScroll\Buttons\fState : DrawScrollButton_(#Vertical, #Forwards)  : EndIf 
        If Thumb     <> ListView()\VScroll\Thumb\State    : DrawThumb_(#Vertical)              : EndIf 
        
        ListView()\VScroll\CursorPos = #PB_Default
  		 
      EndIf ;}
      
    EndIf 

	EndProcedure
	
	Procedure _MouseWheelHandler()
	  Define.i Delta
    Define.i GNum = EventGadget()
    
    If FindMapElement(ListView(), Str(GNum))

  	  Delta = GetGadgetAttribute(GNum, #PB_Canvas_WheelDelta)
      
      If ListView()\HScroll\Focus
        ;{ Horizontal Scrollbar
        If ListView()\HScroll\Focus And ListView()\HScroll\Hide = #False
          SetThumbPosX_(ListView()\HScroll\Pos - (Delta * ListView()\Scrollbar\ScrollH))
          Draw_(#Horizontal)
        EndIf  
        ;}
      Else
        ;{ Vertical Scrollbar
        If ListView()\VScroll\Hide = #False
          SetThumbPosY_(ListView()\VScroll\Pos - Delta)
          Draw_(#Vertical)
        EndIf
        ;}
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.s ScrollBar
	  Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ListView(), Str(GadgetNum))
    
      ;{ Horizontal Scrollbar
      ListView()\HScroll\Buttons\bState = #False
      ListView()\HScroll\Buttons\fState = #False
      ListView()\HScroll\Thumb\State    = #False
      ;}

      ;{ Vertikal Scrollbar
      ListView()\VScroll\Buttons\bState = #False
      ListView()\VScroll\Buttons\fState = #False
      ListView()\VScroll\Thumb\State    = #False
      ;}
      
      DrawScrollBar_(#Horizontal|#Vertical) 
      
	  EndIf
	  
	EndProcedure
	
	
	Procedure _ResizeHandler()
	  Define.s ScrollBar
		Define.i GadgetID = EventGadget()

		If FindMapElement(ListView(), Str(GadgetID))

		  Draw_()

		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach ListView()

			If IsGadget(ListView()\CanvasNum)

				If ListView()\Flags & #AutoResize

					If IsWindow(ListView()\Window\Num)

						OffSetX = WindowWidth(ListView()\Window\Num)  - ListView()\Window\Width
						OffsetY = WindowHeight(ListView()\Window\Num) - ListView()\Window\Height

						If ListView()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If ListView()\Size\Flags & #MoveX  : X = ListView()\Size\X + OffSetX : EndIf
							If ListView()\Size\Flags & #MoveY  : Y = ListView()\Size\Y + OffSetY : EndIf
							If ListView()\Size\Flags & #Width  : Width  = ListView()\Size\Width  + OffSetX : EndIf
							If ListView()\Size\Flags & #Height : Height = ListView()\Size\Height + OffSetY : EndIf

							ResizeGadget(ListView()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(ListView()\CanvasNum, #PB_Ignore, #PB_Ignore, ListView()\Size\Width + OffSetX, ListView()\Size\Height + OffsetY)
						EndIf

						Draw_()
					EndIf

				EndIf

			EndIf

		Next

	EndProcedure
	
	Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach ListView()
     
      If ListView()\Window\Num = Window
        
        CompilerIf Defined(ModuleEx, #PB_Module) = #False
          
          
          
        CompilerEndIf

        DeleteMapElement(ListView())
        
      EndIf
      
    Next
    
  EndProcedure
	
  ; _____ ScrollBar _____
  Procedure.i ScrollBar()

    ListView()\Scrollbar\Flags | #Horizontal
    ListView()\HScroll\CursorPos      = #PB_Default
    ListView()\HScroll\Buttons\fState = #PB_Default
    ListView()\HScroll\Buttons\bState = #PB_Default

    ListView()\Scrollbar\Flags | #Vertical
    ListView()\VScroll\CursorPos      = #PB_Default
    ListView()\VScroll\Buttons\fState = #PB_Default
    ListView()\VScroll\Buttons\bState = #PB_Default 
    
    ListView()\Scrollbar\Size       = #ScrollBarSize
    ListView()\Scrollbar\TimerDelay = #TimerDelay
   
    ; ----- Styles -----
    If ListView()\Flags & #Style_Win11      : ListView()\Scrollbar\Flags | #Style_Win11      : EndIf
    If ListView()\Flags & #Style_RoundThumb : ListView()\Scrollbar\Flags | #Style_RoundThumb : EndIf
    
    CompilerIf #PB_Compiler_Version >= 600
      If OSVersion() = #PB_OS_Windows_11  : ListView()\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerElse
      If OSVersion() >= #PB_OS_Windows_10 : ListView()\Scrollbar\Flags | #Style_Win11 : EndIf
    CompilerEndIf  
    
    ;{ ----- Colors -----
    ListView()\Scrollbar\Color\Front  = $C8C8C8
    ListView()\Scrollbar\Color\Back   = $F0F0F0
	  ListView()\Scrollbar\Color\Button = $F0F0F0
	  ListView()\Scrollbar\Color\Focus  = $D77800
	  ListView()\Scrollbar\Color\Hover  = $666666
	  ListView()\Scrollbar\Color\Arrow  = $696969
	  
	  CompilerSelect #PB_Compiler_OS
		  CompilerCase #PB_OS_Windows
				ListView()\Scrollbar\Color\Front  = GetSysColor_(#COLOR_SCROLLBAR)
				ListView()\Scrollbar\Color\Back   = GetSysColor_(#COLOR_MENU)
				ListView()\Scrollbar\Color\Button = GetSysColor_(#COLOR_BTNFACE)
				ListView()\Scrollbar\Color\Focus  = GetSysColor_(#COLOR_MENUHILIGHT)
				ListView()\Scrollbar\Color\Hover  = GetSysColor_(#COLOR_ACTIVEBORDER)
				ListView()\Scrollbar\Color\Arrow  = GetSysColor_(#COLOR_GRAYTEXT)
			CompilerCase #PB_OS_MacOS
				ListView()\Scrollbar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ListView()\Scrollbar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ListView()\Scrollbar\Color\Button = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ListView()\Scrollbar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				ListView()\Scrollbar\Color\Hover  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ListView()\Scrollbar\Color\Arrow  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
			CompilerCase #PB_OS_Linux

		CompilerEndSelect
		
		If ListView()\Scrollbar\Flags & #Style_Win11
		  ListView()\Scrollbar\Color\Hover = $666666
		  ListView()\Scrollbar\Color\Focus = $8C8C8C
		EndIf   
    ;}

		CalcScrollBar_()

	EndProcedure

	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
	
	CompilerIf #Enable_SyntaxHighlight
    
    Procedure AddWord(GNum.i, Word.s, Color.i)
      
      If FindMapElement(ListView(), Str(GNum))
        ListView()\Syntax(Word)  = Color
      EndIf
    
    EndProcedure
  
    Procedure DeleteWord(GNum.i, Word.s)
      
      If FindMapElement(ListView(), Str(GNum))
        DeleteMapElement(ListView()\Syntax(), Word) 
      EndIf  
   
    EndProcedure
  
    Procedure ClearWords(GNum.i)
      
      If FindMapElement(ListView(), Str(GNum))
        ClearMap(ListView()\Syntax())
      EndIf
      
    EndProcedure
    
  CompilerEndIf
	
	
	Procedure.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Flags.i=#False)
	  Define.i r, Result
	  
		If FindMapElement(ListView(), Str(GNum))
		  
		  ;{ Add item
      Select Row
        Case #FirstItem
          FirstElement(ListView()\Item())
          Result = InsertElement(ListView()\Item()) 
        Case #LastItem
          LastElement(ListView()\Item())
          Result = AddElement(ListView()\Item())
        Default
          If SelectElement(ListView()\Item(), Row)
            Result = InsertElement(ListView()\Item()) 
          Else
            LastElement(ListView()\Item())
            Result = AddElement(ListView()\Item())
          EndIf
      EndSelect ;}
   
      If Result

		    ListView()\Item()\ID     = Label
		    ListView()\Item()\String = Text
		    ListView()\Item()\Flags  = Flags
		    
		    ListView()\Item()\Color\Front = #PB_Default
		    ListView()\Item()\Color\Back  = #PB_Default
		    
		    If Label
		      ListView()\Index(Label) = ListIndex(ListView()\Item())
		    EndIf
		    
		    AdjustScrollBars_()
		    
  		  If ListView()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
  		EndIf
  		
		EndIf
		
    ProcedureReturn ListIndex(ListView()\Item())
	EndProcedure
	
	Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)

		If FindMapElement(ListView(), Str(GNum))
			ListView()\PopupNum = PopUpNum
		EndIf

	EndProcedure
	
	Procedure   ClearItems(GNum.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    ClearList(ListView()\Item())
	    
	    AdjustScrollBars_()
	    
	    If ListView()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
	  EndIf  
	  
	EndProcedure
	
	Procedure.i CountItems(GNum.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    ProcedureReturn ListSize(ListView()\Item())
	  EndIf  
	    
	EndProcedure
	
	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(ListView(), Str(GNum))

      ListView()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 	
	
	Procedure   DisableReDraw(GNum.i, State.i=#False)

		If FindMapElement(ListView(), Str(GNum))

			If State
				ListView()\ReDraw = #False
			Else
				ListView()\ReDraw = #True
				Draw_()
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
		Define DummyNum, Result.i
		
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

			If AddMapElement(ListView(), Str(GNum))

				ListView()\CanvasNum = GNum

        If WindowNum = #PB_Default
          ListView()\Window\Num = GetGadgetWindow()
        Else
          ListView()\Window\Num = WindowNum
        EndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						ListView()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							ListView()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						ListView()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				ListView()\Size\X = X
				ListView()\Size\Y = Y
				ListView()\Size\Width  = Width
				ListView()\Size\Height = Height
				
				ListView()\Focus = #PB_Default
				ListView()\State = #PB_Default
				
				ListView()\Rows\Height = #PB_Default
				ListView()\Flags       = Flags
				
				ScrollBar()
				
				ListView()\ReDraw = #True

				ListView()\Color\Front        = $000000
				ListView()\Color\Back         = $FFFFFF
				ListView()\Color\Gadget       = $F0F0F0
				ListView()\Color\Border       = $A0A0A0
				ListView()\Color\Grid         = $E3E3E3
				ListView()\Color\CheckBox     = $E3E3E3
				ListView()\Color\FocusBack    = $D77800
        ListView()\Color\FocusFront   = $FFFFFF
				ListView()\Color\DisableFront = $72727D
				ListView()\Color\DisableBack  = $CCCCCA
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						ListView()\Color\Front     = GetSysColor_(#COLOR_WINDOWTEXT)
						ListView()\Color\Back      = GetSysColor_(#COLOR_WINDOW)
						ListView()\Color\Border    = GetSysColor_(#COLOR_3DSHADOW) 
						ListView()\Color\Gadget    = GetSysColor_(#COLOR_MENU)
						ListView()\Color\Grid      = GetSysColor_(#COLOR_3DLIGHT)
						ListView()\Color\FocusBack = GetSysColor_(#COLOR_MENUHILIGHT)
						ListView()\Color\CheckBox  = GetSysColor_(#COLOR_3DLIGHT)
					CompilerCase #PB_OS_MacOS
						ListView()\Color\Front     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						ListView()\Color\Back      = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
						ListView()\Color\Border    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						ListView()\Color\Gadget    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						ListView()\Color\Grid      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						ListView()\Color\FocusBack = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
						ListView()\Color\CheckBox  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(ListView()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent(ListView()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
				BindGadgetEvent(ListView()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
				BindGadgetEvent(ListView()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
				BindGadgetEvent(ListView()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
				BindGadgetEvent(ListView()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
				BindGadgetEvent(ListView()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
				BindGadgetEvent(ListView()\CanvasNum,  @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enable AutoResize
					If IsWindow(ListView()\Window\Num)
						ListView()\Window\Width  = WindowWidth(ListView()\Window\Num)
						ListView()\Window\Height = WindowHeight(ListView()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ListView()\Window\Num)
					EndIf
				EndIf ;}
				
				AddWindowTimer(ListView()\Window\Num, #AutoScrollTimer, #Frequency)
	      BindEvent(#PB_Event_Timer, @_AutoScroll(), ListView()\Window\Num)

				BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), ListView()\Window\Num)
				
				CloseGadgetList()
				
				CalcScrollBar_()
				
				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    ProcedureReturn ListView()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    ProcedureReturn ListView()\ID
	  EndIf
	  
	EndProcedure
	
  Procedure.q GetItemData(GNum.i, Row.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      ProcedureReturn ListView()\Item()\Quad
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemLabel(GNum.i, Row.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      ProcedureReturn ListView()\Item()\ID
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
  Procedure.i GetItemState(GNum.i, Row.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      ProcedureReturn ListView()\Item()\State
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemText(GNum.i, Row.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      ProcedureReturn ListView()\Item()\String
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetLabelText(GNum.i, Label.s)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If FindMapElement(ListView()\Index(), Label)
	      If SelectElement(ListView()\Item(), ListView()\Index())
  	      ProcedureReturn ListView()\Item()\String
  	    EndIf
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetState(GNum.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    ProcedureReturn ListView()\State
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetText(GNum.i, Text.s)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), ListView()\State)
	      ProcedureReturn ListView()\Item()\String
	    EndIf  

	  EndIf
	  
	EndProcedure
	
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If State
	      ListView()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      ListView()\Hide = #False
	      HideGadget(GNum, #False)
	      AdjustScrollBars_()
	      Draw_(#Horizontal|#Vertical)
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	Procedure   RemoveItem(GNum.i, Row.i)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      DeleteElement(ListView()\Item())
	      ListView()\State = #PB_Default
	    EndIf  
	    
	    If ListView()\ReDraw : Draw_() : EndIf
	  EndIf  
	
	EndProcedure
	
	
	Procedure   SetAttribute(GNum.i, Attrib.i, Value.i)

    If FindMapElement(ListView(), Str(GNum))

      Select Attrib
        Case #ScrollBar
          ListView()\ScrollBar\Flags | Value
      EndSelect

    EndIf  

  EndProcedure
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ListView(), Str(GNum))
      
      ListView()\Size\Flags = Flags
      ListView()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(ListView(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          ListView()\Color\Front  = Value
        Case #BackColor
          ListView()\Color\Back   = Value
        Case #BorderColor
          ListView()\Color\Border = Value
        Case #GridColor 
          ListView()\Color\Grid   = Value
        Case #ScrollBar_FrontColor
          ListView()\ScrollBar\Color\Front  = Value
        Case #ScrollBar_BackColor 
          ListView()\ScrollBar\Color\Back   = Value
        Case #ScrollBar_ButtonColor
          ListView()\ScrollBar\Color\Button = Value 
      EndSelect
      
      If ListView()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    ListView()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    ListView()\ID = String
	  EndIf
	  
	EndProcedure

  Procedure   SetFont(GNum.i, FontID.i) 
    
    If FindMapElement(ListView(), Str(GNum))
      
      ListView()\FontID = FontID
      
      AdjustScrollBars_()
      
      If ListView()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i)
    
    If FindMapElement(ListView(), Str(GNum))
      
      If SelectElement(ListView()\Item(), Row)
        Select ColorTyp
          Case #FrontColor
            ListView()\Item()\Color\Front = Value
          Case #BackColor
            ListView()\Item()\Color\Back  = Value
        EndSelect
      EndIf
      
      If ListView()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetItemData(GNum.i, Row.i, Value.q)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      ListView()\Item()\Quad = Value
	    EndIf
	    
	  EndIf
	  
	EndProcedure

	Procedure   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
  	  If SelectElement(ListView()\Item(), Row)
  	    
  	    If IsImage(Image)  
  	      ListView()\Item()\Image\Num    = Image
  	      ListView()\Item()\Image\Width  = ImageWidth(Image)
  	      ListView()\Item()\Image\Height = ImageHeight(Image)
  	      ListView()\Item()\Image\Flags  = Flags
  	      ListView()\Item()\Flags | #Image
  	      
  	      If Flags & #FitRows
  	        If ListView()\Item()\Image\Height + 4 > ListView()\Rows\Height
  	          ListView()\Rows\Height = ListView()\Item()\Image\Height + 4
  	        EndIf  
  	      EndIf
  	      
  	    Else  
  	      
  	      ListView()\Item()\Flags & ~#Image
  	      
  	    EndIf
  	    
  	    If ListView()\ReDraw : Draw_() : EndIf
  	  EndIf 
  	  
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemLabel(GNum.i, Row.i, Label.s)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      ListView()\Item()\ID = Label
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
  Procedure   SetItemState(GNum.i, Row.i, State.i=#True)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      
	      If ListView()\Flags & #MultiSelect
	        ListView()\Item()\State = State
	      ElseIf ListView()\Flags & #ClickSelect
	        ListView()\Item()\State ! State
	      EndIf
	      
	      If ListView()\ReDraw : Draw_() : EndIf
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemText(GNum.i, Row.i, Text.s)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If SelectElement(ListView()\Item(), Row)
	      ListView()\Item()\String = Text
	    EndIf
	    
	    AdjustScrollBars_()
	    
	    If ListView()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
	  EndIf
	  
	EndProcedure
	
	Procedure   SetLabelText(GNum.i, Label.s, Text.s)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    If FindMapElement(ListView()\Index(), Label)
	      If SelectElement(ListView()\Item(), ListView()\Index())
  	      ListView()\Item()\String = Text
  	    EndIf
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetRowHeight(GNum.i, Height.i=#PB_Default)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    ListView()\Rows\Height = Height
	    
	    AdjustScrollBars_()
	    
	    If ListView()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
	  EndIf
	  
	EndProcedure  
	
  Procedure   SetState(GNum.i, Row.i)
	  
    If FindMapElement(ListView(), Str(GNum))
      
	    ListView()\State = Row
	    
	    If ListView()\ReDraw : Draw_() : EndIf
	  EndIf
	  
	EndProcedure
  
	Procedure   SetText(GNum.i, Text.s)
	  
	  If FindMapElement(ListView(), Str(GNum))
	    
	    ForEach ListView()\Item()
	      If ListView()\Item()\String = Text
	        ListView()\State = ListIndex(ListView()\Item())
	        AdjustScrollBars_()
	        Break
	      EndIf
	    Next  
	    
	    If ListView()\ReDraw : Draw_(#Horizontal|#Vertical) : EndIf
	  EndIf
	  
	EndProcedure
	
	
  Procedure   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
    
    If FindMapElement(ListView(), Str(GNum))
      
      If AddMapElement(ListView()\PopUpItem(), Str(MenuItem))
        ListView()\PopUpItem() = Text
      EndIf 
      
    EndIf
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  Define.i Selected
  
  Enumeration 
    #Window
    #ListView
    #PopUpMenu
    #MenuItem1
    #MenuItem2
    #Image
  EndEnumeration
  
  LoadImage(#Image, "Test.png")
  
  If OpenWindow(#Window, 0, 0, 140, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#PopUpMenu)
      MenuItem(#MenuItem1, "Remove row" )
      MenuBar()
      MenuItem(#MenuItem2, "Clear items")
    EndIf
    
    If ListView::Gadget(#ListView, 10, 10, 120, 180, ListView::#CheckBoxes, #Window) ; ListView::#GridLines|ListView::#ClickSelect|ListView::#MultiSelect

      ListView::AttachPopupMenu(#ListView, #PopUpMenu)
      ListView::UpdatePopupText(#ListView, #MenuItem1,  "Remove row " + ListView::#Row$)
      
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 1")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 2")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 3")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 4")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 5")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 6")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 7")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 8")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 9")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 10")
      
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 11")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 12")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 13")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 14")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 15")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 16")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 17")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 18")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 19")
      ListView::AddItem(#ListView, ListView::#LastItem, "Row 20")
      
      ListView::SetItemColor(#ListView, 3, ListView::#FrontColor, $006400)
      ListView::SetItemColor(#ListView, 5, ListView::#FrontColor, $800080)
      
      CompilerIf ListView::#Enable_SyntaxHighlight
        ListView::AddWord(#ListView, "Row", $006400)
      CompilerEndIf
    
      ListView::SetItemImage(#ListView, 1, #Image) ; , ListView::#Right|ListView::#FitRows
      
    EndIf
    
    ;ListView::SetText(#ListView, "Row 5")
    ;Debug ListView::CountItems(#ListView)
    
    ;ModuleEx::SetTheme(ModuleEx::#Theme_Green)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case ListView::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #ListView
              Select EventType()
                Case #PB_EventType_LeftClick       ;{ Left mouse click
                  Debug "Left Click: " + Str(EventData())
                  ;}
                Case #PB_EventType_RightClick      ;{ Right mouse click
                  Debug "Right Click: " + Str(EventData())
                  ;}
              EndSelect
          EndSelect ;}
        Case #PB_Event_Menu
          Select EventMenu()  
            Case #MenuItem1
              Debug "MenuItem 1"
              Selected = ListView::GetState(#ListView)
              If Selected <> -1
                ListView::RemoveItem(#ListView, Selected)
              EndIf  
            Case #MenuItem2
              ListView::ClearItems(#ListView)
          EndSelect    
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 6.00 Beta 7 (Windows - x64)
; CursorPosition = 13
; Folding = IgEAAAAoo-HIenDKAADAgADUAAwAgAAw-
; Markers = 1678
; EnableXP
; DPIAware