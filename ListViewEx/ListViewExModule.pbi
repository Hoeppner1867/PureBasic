;/ ============================
;/ =    ListViewModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ ListView - Gadget
;/
;/ © 2019  by Thorsten Hoeppner (11/2019)
;/

; Last Update: 02.03.2020
;
; Changed: ScrollBarGadget() replaced by drawing routine
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
  
  #Version  = 20030200
  #ModuleEx = 19120100

	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  #Enable_SyntaxHighlight = #True
  
  ;{ _____ ScrollBar _____
	Enumeration 1
	  #ScrollBar_Up
	  #ScrollBar_Down
	  #ScrollBar_Left
	  #ScrollBar_Right
	EndEnumeration 
	
	EnumerationBinary 
		#ScrollBar_Border            ; Draw gadget border
		#ScrollBar_ButtonBorder      ; Draw button borders
		#ScrollBar_ThumbBorder       ; Draw thumb border
		#ScrollBar_DragLines         ; Draw drag lines
	EndEnumeration
	;}
  
  ;{ _____ Constants _____
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
		;#ToolTips         ; Show tooltips
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
	EndEnumeration ;}

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
	;}

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
	
	;{ _____ ScrollBar _____
	#ScrollBarSize = 16
	#ScrollBar_ButtonSize = 16
  
  #ScrollBar_Timer      = 100
	#ScrollBar_TimerDelay = 3
	
	Enumeration 1 
	  #ScrollBar_Forwards
	  #ScrollBar_Backwards
	  #ScrollBar_Focus
	  #ScrollBar_Click
	EndEnumeration
	;}
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	;{ _____ ScrollBar _____
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
	  Num.i
	  
	  Adjust.i
	  Radius.i

	  Flags.i
	  
	  Color.ScrollBar_Color_Structure

    Map Item.ScrollBar_Item_Structure()
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

		Color.ListView_Color_Structure
		Window.ListView_Window_Structure
		Rows.ListView_Rows_Structure
		ScrollBar.ScrollBar_Structure
		Size.ListView_Size_Structure
		
		List Item.ListView_Item_Structure()
		Map  Index.i() 
		Map  Syntax.i()
		Map  PopUpItem.s()
    
	EndStructure ;}
	Global NewMap ListView.ListView_Structure()

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
  Procedure.i CalcScrollBarThumb_(ScrollBar.s)
	  Define.i Size, Range, HRange
	  
	  If FindMapElement(ListView()\ScrollBar\Item(), ScrollBar)
	    
  	  ListView()\ScrollBar\Item()\minPos   = ListView()\ScrollBar\Item()\Minimum
  	  ListView()\ScrollBar\Item()\maxPos   = ListView()\ScrollBar\Item()\Maximum - ListView()\ScrollBar\Item()\PageLength + 1
  	  ListView()\ScrollBar\Item()\Ratio    = ListView()\ScrollBar\Item()\PageLength / ListView()\ScrollBar\Item()\Maximum
  	  ListView()\ScrollBar\Item()\Pos      = ListView()\ScrollBar\Item()\Minimum
  	  
  	  Range = ListView()\ScrollBar\Item()\maxPos - ListView()\ScrollBar\Item()\minPos
  	  
	    ListView()\ScrollBar\Item()\Area\X       = dpiX(ListView()\ScrollBar\Item()\X)
  	  ListView()\ScrollBar\Item()\Area\Y       = dpiY(ListView()\ScrollBar\Item()\Y) + dpiY(#ScrollBar_ButtonSize) + dpiY(1)
  	  ListView()\ScrollBar\Item()\Area\Width   = dpiX(ListView()\ScrollBar\Item()\Width)
  	  ListView()\ScrollBar\Item()\Area\Height  = dpiY(ListView()\ScrollBar\Item()\Height) - dpiY(ListView()\ScrollBar\Adjust) - dpiY(#ScrollBar_ButtonSize * 2) - dpiY(2)
  	  ListView()\ScrollBar\Item()\Thumb\Y      = ListView()\ScrollBar\Item()\Area\Y
  	  ListView()\ScrollBar\Item()\Thumb\Size   = Round(ListView()\ScrollBar\Item()\Area\Height * ListView()\ScrollBar\Item()\Ratio, #PB_Round_Down)
  	  ListView()\ScrollBar\Item()\Thumb\Factor = (ListView()\ScrollBar\Item()\Area\Height - ListView()\ScrollBar\Item()\Thumb\Size) / Range  
  	  
	  EndIf   

	EndProcedure
	
	Procedure.i GetSteps_(Cursor.i)
	  Define.i Steps
	  
	  Steps = (Cursor - ListView()\ScrollBar\Item()\Cursor) / ListView()\ScrollBar\Item()\Thumb\Factor
	  
	  If Steps = 0
	    If Cursor < ListView()\ScrollBar\Item()\Cursor
	      Steps = -1
	    Else
	      Steps = 1
	    EndIf
	  EndIf
	  
	  ProcedureReturn Steps
	EndProcedure
	;}
	
	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
	;{ _____ ScrollBar _____
	Procedure   DrawScrollArrow_(X.i, Y.i, Width.i, Height.i, Color.i, Flag.i)
	  Define.i aWidth, aHeight, aColor

	  If StartVectorDrawing(CanvasVectorOutput(ListView()\ScrollBar\Num))

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
	  
	  If StartDrawing(CanvasOutput(ListView()\ScrollBar\Num))
	    
	    DrawingMode(#PB_2DDrawing_Default)
	    
	    Select State
	      Case #ScrollBar_Focus
	        Color  = BlendColor_(ListView()\ScrollBar\Color\Focus, ListView()\ScrollBar\Color\Button, 10)
	        Border = BlendColor_(ListView()\ScrollBar\Color\Focus, ListView()\ScrollBar\Color\Border, 10)
	      Case #ScrollBar_Click
	        Color  = BlendColor_(ListView()\ScrollBar\Color\Focus, ListView()\ScrollBar\Color\Button, 20)
	        Border = BlendColor_(ListView()\ScrollBar\Color\Focus, ListView()\ScrollBar\Color\Border, 20)
	      Default
	        Color  = ListView()\ScrollBar\Color\Button
	        Border = ListView()\ScrollBar\Color\Border
	    EndSelect    
	    
	    If FindMapElement(ListView()\ScrollBar\Item(), ScrollBar)
	      
	      If ListView()\ScrollBar\Item()\Hide : ProcedureReturn #False : EndIf 
	      
	      Select Type
  	      Case #ScrollBar_Forwards
  	        Box(ListView()\ScrollBar\Item()\Buttons\Forwards\X,  ListView()\ScrollBar\Item()\Buttons\Forwards\Y,  ListView()\ScrollBar\Item()\Buttons\Forwards\Width, ListView()\ScrollBar\Item()\Buttons\Forwards\Height,  Color)
  	      Case #ScrollBar_Backwards
  	        Box(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, Color)
  	    EndSelect    
	      
	      If ListView()\ScrollBar\Flags & #ScrollBar_ButtonBorder
	      
  	      DrawingMode(#PB_2DDrawing_Outlined)
  	      
  	      Select Type
  	        Case #ScrollBar_Forwards
  	          Box(ListView()\ScrollBar\Item()\Buttons\Forwards\X - dpiX(1), ListView()\ScrollBar\Item()\Buttons\Forwards\Y, ListView()\ScrollBar\Item()\Buttons\Forwards\Width + dpiX(2), ListView()\ScrollBar\Item()\Buttons\Forwards\Height + dpiY(1), Border)  
    	      Case #ScrollBar_Backwards
    	        Box(ListView()\ScrollBar\Item()\Buttons\Backwards\X - dpiX(1), ListView()\ScrollBar\Item()\Buttons\Backwards\Y - dpiY(1), ListView()\ScrollBar\Item()\Buttons\Backwards\Width + dpiX(2), ListView()\ScrollBar\Item()\Buttons\Backwards\Height + dpiY(1), Border)
    	    EndSelect 
    	    
  	    EndIf 
	    
	    EndIf

	    StopDrawing()
	  EndIf
	  
	  ;{ ----- Draw Arrows -----
	  If FindMapElement(ListView()\ScrollBar\Item(), ScrollBar)
	    
  	  Select Type
        Case #ScrollBar_Forwards
          DrawScrollArrow_(ListView()\ScrollBar\Item()\Buttons\Forwards\X, ListView()\ScrollBar\Item()\Buttons\Forwards\Y, ListView()\ScrollBar\Item()\Buttons\Forwards\Width, ListView()\ScrollBar\Item()\Buttons\Forwards\Height, ListView()\ScrollBar\Color\Front, #ScrollBar_Down)
        Case #ScrollBar_Backwards
          DrawScrollArrow_(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, ListView()\ScrollBar\Color\Front, #ScrollBar_Up)
      EndSelect
    
    EndIf ;}

	EndProcedure
	
	Procedure   DrawScrollBar_(ScrollBar.s)
		Define.i X, Y, Width, Height, Offset, OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		If FindMapElement(ListView()\ScrollBar\Item(), ScrollBar)
		  
      If ListView()\ScrollBar\Item()\Hide : ProcedureReturn #False : EndIf 
  	 
      ;{ ----- Size -----
		  X      = dpiX(ListView()\ScrollBar\Item()\X)
		  Y      = dpiY(ListView()\ScrollBar\Item()\Y)
		  Width  = dpiX(ListView()\ScrollBar\Item()\Width) 
		  Height = dpiY(ListView()\ScrollBar\Item()\Height)
		  ;}
		  
		  Offset = (ListView()\ScrollBar\Item()\Pos - ListView()\ScrollBar\Item()\minPos) * ListView()\ScrollBar\Item()\Thumb\Factor
		  
      ;{ ----- Buttons -----
		  ListView()\ScrollBar\Item()\Buttons\Forwards\X       = X + dpiX(1)
  		ListView()\ScrollBar\Item()\Buttons\Forwards\Y       = Y + Height - dpiY(#ScrollBar_ButtonSize) - dpiY(ListView()\ScrollBar\Adjust) - dpiY(1)
  		ListView()\ScrollBar\Item()\Buttons\Forwards\Width   = Width - dpiX(2)
  		ListView()\ScrollBar\Item()\Buttons\Forwards\Height  = dpiY(#ScrollBar_ButtonSize)	
  		ListView()\ScrollBar\Item()\Buttons\Backwards\X      = X + dpiX(1)
  		ListView()\ScrollBar\Item()\Buttons\Backwards\Y      = Y + dpiY(1)
  		ListView()\ScrollBar\Item()\Buttons\Backwards\Width  = Width - dpiX(2)
  		ListView()\ScrollBar\Item()\Buttons\Backwards\Height = dpiY(#ScrollBar_ButtonSize)
  		;}
      ;{ ----- ScrollArea -----
  		ListView()\ScrollBar\Item()\Area\X = X
  	  ListView()\ScrollBar\Item()\Area\Y = Y + dpiY(#ScrollBar_ButtonSize) + dpiY(1)
  	  ListView()\ScrollBar\Item()\Area\Width  = Width
  	  ListView()\ScrollBar\Item()\Area\Height = Height - dpiY(#ScrollBar_ButtonSize * 2) - dpiY(2)
  	  ;}
      ;{ ----- Thumb -----
  	  ListView()\ScrollBar\Item()\Thumb\X      = X
  	  ListView()\ScrollBar\Item()\Thumb\Y      = ListView()\ScrollBar\Item()\Area\Y + Offset
  	  ListView()\ScrollBar\Item()\Thumb\Width  = Width
  	  ListView()\ScrollBar\Item()\Thumb\Height = ListView()\ScrollBar\Item()\Thumb\Size
  	  If ListView()\ScrollBar\Flags & #ScrollBar_ButtonBorder
  	    ListView()\ScrollBar\Item()\Thumb\Y + dpiY(1)
  	    ListView()\ScrollBar\Item()\Thumb\Height - dpiY(2)
  	  EndIf ;}

  		If StartDrawing(CanvasOutput(ListView()\ScrollBar\Num))
  		  
  		  ;{ _____ Color _____
  		  FrontColor  = ListView()\ScrollBar\Color\Front
  		  BackColor   = ListView()\ScrollBar\Color\Back
  		  BorderColor = ListView()\ScrollBar\Color\Border
  		  
  		  If ListView()\ScrollBar\Item()\Disable
  		    FrontColor  = ListView()\ScrollBar\Color\DisableFront
  		    BackColor   = ListView()\ScrollBar\Color\DisableBack
  		    BorderColor = ListView()\ScrollBar\Color\DisableFront
  		  EndIf
  		  ;}
  		  
  		  DrawingMode(#PB_2DDrawing_Default)
  		  
  		  ;{ _____ Background _____
  		  Box(X, Y, Width, Height, ListView()\ScrollBar\Color\Gadget) ; needed for rounded corners
  		  Box(ListView()\ScrollBar\Item()\Area\X, ListView()\ScrollBar\Item()\Area\Y, ListView()\ScrollBar\Item()\Area\Width, ListView()\ScrollBar\Item()\Area\Height, ListView()\ScrollBar\Color\Back)
  			;}
  			
  		  ;{ _____ Draw Thumb _____
  		  Select ListView()\ScrollBar\Item()\Thumb\State
  			  Case #ScrollBar_Focus
  			    Box(ListView()\ScrollBar\Item()\Thumb\X, ListView()\ScrollBar\Item()\Thumb\Y, ListView()\ScrollBar\Item()\Thumb\Width, ListView()\ScrollBar\Item()\Thumb\Height, BlendColor_(ListView()\ScrollBar\Color\Focus, ListView()\ScrollBar\Color\ScrollBar, 10))
  			  Case #ScrollBar_Click
  			    Box(ListView()\ScrollBar\Item()\Thumb\X, ListView()\ScrollBar\Item()\Thumb\Y, ListView()\ScrollBar\Item()\Thumb\Width, ListView()\ScrollBar\Item()\Thumb\Height, BlendColor_(ListView()\ScrollBar\Color\Focus, ListView()\ScrollBar\Color\ScrollBar, 20))
  			  Default
  			    Box(ListView()\ScrollBar\Item()\Thumb\X, ListView()\ScrollBar\Item()\Thumb\Y, ListView()\ScrollBar\Item()\Thumb\Width, ListView()\ScrollBar\Item()\Thumb\Height, ListView()\ScrollBar\Color\ScrollBar)
  			EndSelect
  			
  		  If ListView()\ScrollBar\Flags & #ScrollBar_DragLines   ;{ Drag Lines
  		    
  			  If ListView()\ScrollBar\Item()\Thumb\Size > dpiY(10)
  		      OffsetY = (ListView()\ScrollBar\Item()\Thumb\Size - dpiY(7)) / 2			      
  		      Line(ListView()\ScrollBar\Item()\Thumb\X + dpiX(4), ListView()\ScrollBar\Item()\Thumb\Y + OffsetY, ListView()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), ListView()\ScrollBar\Color\Front)
  		      Line(ListView()\ScrollBar\Item()\Thumb\X + dpiX(4), ListView()\ScrollBar\Item()\Thumb\Y + OffsetY + dpiY(3), ListView()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), ListView()\ScrollBar\Color\Front)
  		      Line(ListView()\ScrollBar\Item()\Thumb\X + dpiX(4), ListView()\ScrollBar\Item()\Thumb\Y + OffsetY + dpiY(6), ListView()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), ListView()\ScrollBar\Color\Front)
  		    EndIf
  			  ;}
  			EndIf
  			
  			If ListView()\ScrollBar\Flags & #ScrollBar_ThumbBorder ;{ Thumb Border
  			  DrawingMode(#PB_2DDrawing_Outlined)
  			  Box(ListView()\ScrollBar\Item()\Thumb\X, ListView()\ScrollBar\Item()\Thumb\Y, ListView()\ScrollBar\Item()\Thumb\Width, ListView()\ScrollBar\Item()\Thumb\Height, ListView()\ScrollBar\Color\Border)
  			  ;}
  			EndIf
  			;}
  			
  			;{ _____ Border ____
  			If ListView()\ScrollBar\Flags & #ScrollBar_Border
  				DrawingMode(#PB_2DDrawing_Outlined)
  				Box(X, Y, Width, Height, BorderColor)
  			EndIf ;}
  
  			StopDrawing()
  		EndIf
  		
    	DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Forwards\X,  ListView()\ScrollBar\Item()\Buttons\Forwards\Y,  ListView()\ScrollBar\Item()\Buttons\Forwards\Width,  ListView()\ScrollBar\Item()\Buttons\Forwards\Height,  ScrollBar, #ScrollBar_Forwards,  ListView()\ScrollBar\Item()\Buttons\Forwards\State)
    	DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, ListView()\ScrollBar\Item()\Buttons\Backwards\State)

    EndIf
    
	EndProcedure  
	;}
	
	Procedure.i CheckBox_(X.i, Y.i, Width.i, Height.i, boxWidth.i, FrontColor.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
    
    If boxWidth <= Width And boxWidth <= Height
      
      Y + ((Height - boxWidth) / 2)
      
      Box(X, Y, boxWidth, boxWidth, BackColor)
      
      LineColor = BlendColor_(FrontColor, BackColor, 60)
      
      If State & #Checked

        bColor = BlendColor_(LineColor, ListView()\Color\CheckBox)
        
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
      
      ListView()\Item()\CheckBox\X    = X
      ListView()\Item()\CheckBox\Y    = Y
      ListView()\Item()\CheckBox\Size = boxWidth
      
    EndIf
    
  EndProcedure

	Procedure   Draw_()
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
      
      Width  = dpiX(GadgetWidth(ListView()\CanvasNum)) 
      Height = dpiY(GadgetHeight(ListView()\CanvasNum))
      
      
		  If Not ListView()\ScrollBar\Item("VScroll")\Hide : Width - dpiX(#ScrollBarSize) : EndIf
		  
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, dpiX(GadgetWidth(ListView()\CanvasNum)), dpiY(GadgetHeight(ListView()\CanvasNum)), BackColor)
      ;}
      
      X = 0
      Y = dpiY(3)
      
      If ListView()\Flags & #GridLines : Y = 0 : EndIf 
      
      DrawingFont(ListView()\FontID)
      
      TextHeight = TextHeight("Abc")
      
      ;{ RowHeight & Vertical Center
      If ListView()\Rows\Height <> #PB_Default
        RowHeight = dpiY(ListView()\Rows\Height)
        OffsetY   = (RowHeight - TextHeight) / 2
      Else
        If ListView()\Flags & #GridLines
          RowHeight = TextHeight + dpiY(6)
          OffsetY   = dpiY(3)
        Else
          RowHeight = TextHeight + dpiY(2)
          OffsetY   = dpiY(1)
        EndIf
        ListView()\Rows\Height = RowHeight
      EndIf ;}
      
      If OffsetY < 0 : OffsetY = 0 : EndIf
      
      ;{ _____ ScrollBar _____
      If FindMapElement(ListView()\ScrollBar\Item(), "VScroll")
      
        PageRows = Round((Height - dpiY(6)) / RowHeight, #PB_Round_Down)
        
        If PageRows < ListSize(ListView()\Item())
          
          ListView()\ScrollBar\Item()\X          = GadgetWidth(ListView()\CanvasNum) - #ScrollBarSize - 1
          ListView()\ScrollBar\Item()\Y          = 1
          ListView()\ScrollBar\Item()\Height     = GadgetHeight(ListView()\CanvasNum) - 2
          ListView()\ScrollBar\Item()\Maximum    = ListSize(ListView()\Item())
          ListView()\ScrollBar\Item()\PageLength = PageRows
           
          If ListView()\ScrollBar\Item()\Hide
            CalcScrollBarThumb_("VScroll")
            ListView()\ScrollBar\Item()\Hide = #False
          EndIf
          
          ListView()\Rows\Offset = ListView()\ScrollBar\Item()\Pos - 1
          
        Else
          ListView()\Rows\Offset = 0
          ListView()\ScrollBar\Item()\Hide = #True
        EndIf
        
      EndIf ;}
      
      ;{ _____ Rows _____
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(0, 0, Width, Height) 
      CompilerEndIf
      
      ForEach ListView()\Item()
        
        If ListIndex(ListView()\Item()) < ListView()\Rows\Offset
          ListView()\Item()\Y = 0
          Continue
        EndIf  

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
        EndIf   
        
        ListView()\Item()\Y = Y
        
        ;{ Row background
        DrawingMode(#PB_2DDrawing_Default)
        If ListView()\Flags & #ClickSelect And ListView()\Item()\State & #Selected
          ItemBackColor = ListView()\Color\FocusBack
          Box(0, Y, Width, RowHeight, ItemBackColor)
        ElseIf ListView()\State = ListIndex(ListView()\Item()) Or ListView()\Item()\State & #Selected
          ItemBackColor = ListView()\Color\FocusBack
          Box(0, Y, Width, RowHeight, ItemBackColor)
        Else  
          If ListView()\Focus = ListIndex(ListView()\Item())
            ItemBackColor = BlendColor_(ListView()\Color\FocusBack, BackColor, 10)
            Box(X - dpiX(2), Y, TextWidth(ListView()\Item()\String) + dpiX(6), RowHeight, ItemBackColor)
          ElseIf ListView()\Item()\Color\Back <> #PB_Default
            Box(X - dpiX(2), Y, Width, RowHeight, ItemBackColor)
          EndIf
        EndIf ;}
        
        ;{ Checkboxes
        If ListView()\Flags & #CheckBoxes
          boxSize = TextHeight - dpiY(2)
          X = dpiX(3)
          CheckBox_(X, Y, Width, RowHeight, boxSize, FrontColor, BackColor, ListView()\Item()\State)
          X + boxSize
        EndIf  
        ;}
        
        ;{ Text Align
        If ListView()\Item()\Flags & #Center
          OffsetX = (Width - TextWidth(ListView()\Item()\String)) / 2
        ElseIf ListView()\Item()\Flags & #Right
          OffsetX = Width - TextWidth(ListView()\Item()\String) - dpiX(5) 
        Else
          OffsetX = dpiX(5) 
        EndIf ;}        
        
        If ListView()\Item()\Flags & #Image
          
          If IsImage(ListView()\Item()\Image\Num)
            
            ;{ Image Height
            imgHeight = RowHeight - dpiY(2)
            
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
                  ImgX = TextWidth(ListView()\Item()\String) + dpiX(10)
                Else
                  ImgX = Width - imgWidth - dpiX(5)
                EndIf 
              Else  
                ImgX = Width - imgWidth - dpiX(5)
              EndIf  
            Else
              ImgX = dpiX(5)
              If Not ListView()\Item()\Flags & #Center And Not ListView()\Item()\Flags & #Right
                OffsetX + imgWidth + dpiX(5)
              EndIf   
            EndIf ;}
            
            ;{ Vertical Align
            If ListView()\Item()\Image\Height < imgHeight
              imgY = (RowHeight - ListView()\Item()\Image\Height) / 2
            Else
              imgY = dpiY(1)
            EndIf ;}

          Else  
            ListView()\Item()\Flags & ~#Image
          EndIf
          
        EndIf
        
        ;{ Text
        DrawingMode(#PB_2DDrawing_Transparent)
        If ListView()\Flags & #ClickSelect And ListView()\Item()\State & #Selected
          DrawText(X + OffsetX, Y + OffsetY, ListView()\Item()\String, ListView()\Color\FocusFront)
        ElseIf ListView()\State = ListIndex(ListView()\Item()) Or ListView()\Item()\State & #Selected
          DrawText(X + OffsetX, Y + OffsetY, ListView()\Item()\String, ListView()\Color\FocusFront)
        Else
          If ListView()\Item()\Color\Front <> #PB_Default
            DrawText(X + OffsetX, Y + OffsetY, ListView()\Item()\String, ItemFrontColor)
          Else
            DrawText(X + OffsetX, Y + OffsetY, ListView()\Item()\String, FrontColor)
          EndIf
        EndIf ;}
        
        CompilerIf #Enable_SyntaxHighlight
          ForEach ListView()\Syntax()
            Pos = FindString(ListView()\Item()\String, MapKey(ListView()\Syntax()))
            If Pos
              DrawingMode(#PB_2DDrawing_Default)
              wordX = TextWidth(Left(ListView()\Item()\String, Pos - 1))
              DrawText(X + OffsetX + wordX, Y + OffsetY, MapKey(ListView()\Syntax()), ListView()\Syntax(), ItemBackColor)
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
            Box(0, Y, Width, RowHeight+ dpiY(1), ListView()\Color\Grid)
          Else  
            Box(0, Y, Width, RowHeight, ListView()\Color\Grid)
          EndIf  
        EndIf ;}
        
        Y + RowHeight
        
        If Y > Height : Break : EndIf
      Next
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput() 
      CompilerEndIf
      ;}

      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, dpiX(GadgetWidth(ListView()\CanvasNum)), dpiY(GadgetHeight(ListView()\CanvasNum)), BorderColor)
      ;}
      
      StopDrawing()
    EndIf
    
    DrawScrollBar_("VScroll")
    
	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ListView()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ListView()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
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
    
    ForEach ListView()
      
      ForEach ListView()\ScrollBar\Item()
        
        If ListView()\ScrollBar\Item()\Timer
          
          If ListView()\ScrollBar\Item()\TimerDelay
            ListView()\ScrollBar\Item()\TimerDelay - 1
            Continue
          EndIf  
          
          Select ListView()\ScrollBar\Item()\Timer
            Case #ScrollBar_Up, #ScrollBar_Left
              ListView()\ScrollBar\Item()\Pos - 1
              If ListView()\ScrollBar\Item()\Pos < ListView()\ScrollBar\Item()\minPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\minPos : EndIf
            Case #ScrollBar_Down, #ScrollBar_Right
              ListView()\ScrollBar\Item()\Pos + 1
              If ListView()\ScrollBar\Item()\Pos > ListView()\ScrollBar\Item()\maxPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\maxPos : EndIf
          EndSelect
          
          DrawScrollBar_(MapKey(ListView()\ScrollBar\Item()))
          
    		EndIf 
    		
      Next
      
    Next
    
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
	  Define.s ScrollBar
	  Define.i X, Y, Index, Clear
	  Define.i Row = #PB_Default
		Define.i GNum = EventGadget()

		If FindMapElement(ListView(), Str(GNum))

			X = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseY)
			
		  ;{ _____ ScrollBar _____
		  ForEach ListView()\ScrollBar\Item()
    
        If ListView()\ScrollBar\Item()\Hide : Continue : EndIf 
        
        ListView()\ScrollBar\Item()\Cursor = #PB_Default
        
        ScrollBar = MapKey(ListView()\ScrollBar\Item())
  
			  If X >= ListView()\ScrollBar\Item()\X And X <= ListView()\ScrollBar\Item()\X + ListView()\ScrollBar\Item()\Width
			    
  			  If Y <= ListView()\ScrollBar\Item()\Buttons\Backwards\Y + ListView()\ScrollBar\Item()\Buttons\Backwards\Height
  			    ;{ Backwards Button
  			    If ListView()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Click
  			      DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Click)
  			      ListView()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
  			      ListView()\ScrollBar\Item()\Timer      = #ScrollBar_Up
  			      ListView()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Click
  			    EndIf ;}
  			  ElseIf Y >= ListView()\ScrollBar\Item()\Buttons\Forwards\Y
  			    ;{ Forwards Button
  			    If ListView()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Click
  			      DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Forwards\X, ListView()\ScrollBar\Item()\Buttons\Forwards\Y, ListView()\ScrollBar\Item()\Buttons\Forwards\Width, ListView()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Click)
  			      ListView()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
  			      ListView()\ScrollBar\Item()\Timer      = #ScrollBar_Down
  			      ListView()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Click
  			    EndIf ;}
  			  ElseIf Y >= ListView()\ScrollBar\Item()\Thumb\Y And Y <= ListView()\ScrollBar\Item()\Thumb\Y + ListView()\ScrollBar\Item()\Thumb\Height
  			    ;{ Thumb Button
  			    If ListView()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Click
  			      ListView()\ScrollBar\Item()\Thumb\State = #ScrollBar_Click
  			      ListView()\ScrollBar\Item()\Cursor = Y
  			      DrawScrollBar_(ScrollBar) 
  			    EndIf ;} 
  			  EndIf
  			  
  			  ProcedureReturn #True
			  EndIf

      Next
      ;}
      
			ForEach ListView()\Item()

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
        
      Next
      
      If ListView()\Flags & #MultiSelect
        
        If Clear ;{ Reset Selection
          
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
	  Define.i X, Y
	  Define.s ScrollBar
	  Define.i GNum = EventGadget()
	  
		If FindMapElement(ListView(), Str(GNum))

			X = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseY)
		
  		ForEach ListView()\ScrollBar\Item()
        
  		  If ListView()\ScrollBar\Item()\Hide : Continue : EndIf 
  		  
  			ListView()\ScrollBar\Item()\Cursor = #PB_Default
  			ListView()\ScrollBar\Item()\Timer  = #False
  			
  			ScrollBar = MapKey(ListView()\ScrollBar\Item())

			  If X >= ListView()\ScrollBar\Item()\X And X <= ListView()\ScrollBar\Item()\X + ListView()\ScrollBar\Item()\Width
			   
			    If Y >= ListView()\ScrollBar\Item()\Buttons\Backwards\Y And Y <= ListView()\ScrollBar\Item()\Buttons\Backwards\Y + ListView()\ScrollBar\Item()\Buttons\Backwards\Height
  			    ListView()\ScrollBar\Item()\Pos - 1
  			    If ListView()\ScrollBar\Item()\Pos < ListView()\ScrollBar\Item()\minPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\minPos : EndIf
  			    Draw_()
  			  ElseIf Y >= ListView()\ScrollBar\Item()\Buttons\Forwards\Y And Y <= ListView()\ScrollBar\Item()\Buttons\Forwards\Y + ListView()\ScrollBar\Item()\Buttons\Forwards\Height
  			    ListView()\ScrollBar\Item()\Pos + 1
  			    If ListView()\ScrollBar\Item()\Pos > ListView()\ScrollBar\Item()\maxPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\maxPos : EndIf
  			   Draw_()
  			  ElseIf Y < ListView()\ScrollBar\Item()\Thumb\Y
  			    ListView()\ScrollBar\Item()\Pos - ListView()\ScrollBar\Item()\PageLength
  			    If ListView()\ScrollBar\Item()\Pos < ListView()\ScrollBar\Item()\minPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\minPos : EndIf
  			    Draw_()
  			  ElseIf Y > ListView()\ScrollBar\Item()\Thumb\Y + ListView()\ScrollBar\Item()\Thumb\Height
  			    ListView()\ScrollBar\Item()\Pos + ListView()\ScrollBar\Item()\PageLength
  			    If ListView()\ScrollBar\Item()\Pos > ListView()\ScrollBar\Item()\maxPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\maxPos : EndIf
  			    Draw_()
  			  EndIf
  			  
  			  ProcedureReturn #True
  			EndIf 
    			
  		Next
		
    EndIf

	EndProcedure
	
	Procedure _MouseMoveHandler()
	  Define.s ScrollBar
	  Define.i X, Y
	  Define.i GNum = EventGadget()
	  
		If FindMapElement(ListView(), Str(GNum))

			X = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseY)
	  
  	  ForEach ListView()\ScrollBar\Item()
        
  	    If ListView()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(ListView()\ScrollBar\Item())
  	    
	      If X >= ListView()\ScrollBar\Item()\X And X <= ListView()\ScrollBar\Item()\X + ListView()\ScrollBar\Item()\Width
	      
  	      If Y <= ListView()\ScrollBar\Item()\Buttons\Backwards\Y + ListView()\ScrollBar\Item()\Buttons\Backwards\Height
  			    ;{ Backwards Button
  			    If ListView()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Focus
  			      
  			      ListView()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Focus
  			      
  			      If ListView()\ScrollBar\Item()\Thumb\State <> #False
  			        ListView()\ScrollBar\Item()\Thumb\State = #False
  			        DrawScrollBar_(ScrollBar)
  			      Else 
  			        DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Focus)
  			      EndIf 
  			      
  			    EndIf
  			    
  			    
			    ;}
  			    ProcedureReturn #True
  			  ElseIf Y >= ListView()\ScrollBar\Item()\Buttons\Forwards\Y
  			    ;{ Forwards Button
  			    If ListView()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Focus
  			      
  			      ListView()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Focus
  			      
  			      If ListView()\ScrollBar\Item()\Thumb\State <> #False
  			        ListView()\ScrollBar\Item()\Thumb\State = #False
  			        DrawScrollBar_(ScrollBar)
  			      Else 
  			        DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Forwards\X, ListView()\ScrollBar\Item()\Buttons\Forwards\Y, ListView()\ScrollBar\Item()\Buttons\Forwards\Width, ListView()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Focus)
  			      EndIf
  			      
  			    EndIf ;}
  			    ProcedureReturn #True
  			  EndIf

  			  ListView()\ScrollBar\Item()\Timer = #False
  			  
  			  If ListView()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
  			    ListView()\ScrollBar\Item()\Buttons\Backwards\State = #False
  			    DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
    			  ;}
    			EndIf
    			
    			If ListView()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
    			  ListView()\ScrollBar\Item()\Buttons\Forwards\State = #False
    			  DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Forwards\X, ListView()\ScrollBar\Item()\Buttons\Forwards\Y, ListView()\ScrollBar\Item()\Buttons\Forwards\Width, ListView()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
    			  ;}
    			EndIf
  
  			  If Y >= ListView()\ScrollBar\Item()\Thumb\Y And Y <= ListView()\ScrollBar\Item()\Thumb\Y + ListView()\ScrollBar\Item()\Thumb\Height
  			    ;{ Move Thumb
  			    If ListView()\ScrollBar\Item()\Cursor <> #PB_Default
  			      
  			      ListView()\ScrollBar\Item()\Pos + GetSteps_(Y)
  			      
  			      If ListView()\ScrollBar\Item()\Pos > ListView()\ScrollBar\Item()\maxPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\maxPos : EndIf
  			      If ListView()\ScrollBar\Item()\Pos < ListView()\ScrollBar\Item()\minPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\minPos : EndIf
  			      
  			      ListView()\ScrollBar\Item()\Cursor = Y
  		        
  		        Draw_()
  		        ProcedureReturn #True
  		      EndIf ;}
  			    ;{ Thumb Focus
  			    If ListView()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Focus
  			      ListView()\ScrollBar\Item()\Thumb\State = #ScrollBar_Focus
  			      DrawScrollBar_(ScrollBar)
  			    EndIf ;} 
  			    ProcedureReturn #True
  			  EndIf

  			EndIf
  			
  			If ListView()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
  			  DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
  			  ListView()\ScrollBar\Item()\Buttons\Backwards\State = #False
  			  ;}
  			EndIf
  			
  			If ListView()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
  			  DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Forwards\X, ListView()\ScrollBar\Item()\Buttons\Forwards\Y, ListView()\ScrollBar\Item()\Buttons\Forwards\Width, ListView()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
  			  ListView()\ScrollBar\Item()\Buttons\Forwards\State = #False
  			  ;}
  			EndIf
  			
  			If ListView()\ScrollBar\Item()\Thumb\State <> #False             ;{ Thumb Button
  			  ListView()\ScrollBar\Item()\Thumb\State = #False
  			  DrawScrollBar_(ScrollBar)
  			  ;}
  			EndIf
  
  		Next
		
		EndIf

	EndProcedure
	
	Procedure _MouseWheelHandler()
	  Define.s ScrollBar
	  Define.i X, Y
	  Define.i Delta, ScrollPos
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ListView(), Str(GadgetNum))
      
      X = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ListView()\CanvasNum, #PB_Canvas_MouseY)
      
  	  Delta = GetGadgetAttribute(ListView()\ScrollBar\Num, #PB_Canvas_WheelDelta)
  	  
  	  ForEach ListView()\ScrollBar\Item()
        
  	    If ListView()\ScrollBar\Item()\Hide : Continue : EndIf
  
  	    If X >= ListView()\ScrollBar\Item()\X And X <= ListView()\ScrollBar\Item()\X + ListView()\ScrollBar\Item()\Width
  	      If Y >= ListView()\ScrollBar\Item()\Y And Y <= ListView()\ScrollBar\Item()\Y + ListView()\ScrollBar\Item()\Height
  	        
  	        ScrollBar = MapKey(ListView()\ScrollBar\Item())
  	        
  	        ListView()\ScrollBar\Item()\Pos - Delta
  
            If ListView()\ScrollBar\Item()\Pos > ListView()\ScrollBar\Item()\maxPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\maxPos : EndIf
            If ListView()\ScrollBar\Item()\Pos < ListView()\ScrollBar\Item()\minPos : ListView()\ScrollBar\Item()\Pos = ListView()\ScrollBar\Item()\minPos : EndIf
            
            Draw_()
            
  	        ProcedureReturn #True
  	      EndIf 
  	    EndIf
  	    
  	  Next
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.s ScrollBar
	  Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ListView(), Str(GadgetNum))
    
      ForEach ListView()\ScrollBar\Item()
        
  	    If ListView()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(ListView()\ScrollBar\Item())
  	    
  	    If ListView()\ScrollBar\Item()\Buttons\Backwards\State <> #False
  			  DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Backwards\X, ListView()\ScrollBar\Item()\Buttons\Backwards\Y, ListView()\ScrollBar\Item()\Buttons\Backwards\Width, ListView()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
  			  ListView()\ScrollBar\Item()\Buttons\Backwards\State = #False
  			EndIf
  			
  			If ListView()\ScrollBar\Item()\Buttons\Forwards\State <> #False
  			  DrawScrollButton_(ListView()\ScrollBar\Item()\Buttons\Forwards\X, ListView()\ScrollBar\Item()\Buttons\Forwards\Y, ListView()\ScrollBar\Item()\Buttons\Forwards\Width, ListView()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
  			  ListView()\ScrollBar\Item()\Buttons\Forwards\State = #False
  			EndIf
  			
  	    If ListView()\ScrollBar\Item()\Thumb\State <> #False
  	      ListView()\ScrollBar\Item()\Thumb\State = #False
  	      DrawScrollBar_(ScrollBar)
  	    EndIf  
  	    
      Next

	  EndIf
	  
	EndProcedure

	Procedure _ResizeHandler()
	  Define.s ScrollBar
		Define.i GadgetID = EventGadget()

		If FindMapElement(ListView(), Str(GadgetID))

		  Draw_()
		  
		  ForEach ListView()\ScrollBar\Item()
      
  	    If ListView()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(ListView()\ScrollBar\Item())
  	    
  		  CalcScrollBarThumb_(ScrollBar)
  		  DrawScrollBar_(ScrollBar)
  		  
  	  Next
		  
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
          
          If MapSize(ListView()) = 1
            TimerThread\Exit = #True
            Delay(100)
            If IsThread(TimerThread\Num) : KillThread(TimerThread\Num) : EndIf
            TimerThread\Active = #False
          EndIf
          
        CompilerEndIf

        DeleteMapElement(ListView())
        
      EndIf
      
    Next
    
  EndProcedure
	
  ;{ _____ ScrollBar _____
	Procedure InitScrollBar_(CanvasNum.i, Flags.i=#False)
	  
	  ListView()\ScrollBar\Num = CanvasNum
	  
	  ListView()\ScrollBar\Flags = Flags
	  
	  If TimerThread\Active = #False 
      TimerThread\Exit   = #False
      TimerThread\Num    = CreateThread(@_TimerThread(), #ScrollBar_Timer)
      TimerThread\Active = #True
    EndIf
	  
		ListView()\ScrollBar\Color\Back         = $F0F0F0
		ListView()\ScrollBar\Color\Border       = $A0A0A0
		ListView()\ScrollBar\Color\Button       = $F0F0F0
		ListView()\ScrollBar\Color\Focus        = $D77800
		ListView()\ScrollBar\Color\Front        = $646464
		ListView()\ScrollBar\Color\Gadget       = $F0F0F0
		ListView()\ScrollBar\Color\ScrollBar    = $C8C8C8
		ListView()\ScrollBar\Color\DisableFront = $72727D
		ListView()\ScrollBar\Color\DisableBack  = $CCCCCA
		
		CompilerSelect #PB_Compiler_OS ;{ Color
			CompilerCase #PB_OS_Windows
				ListView()\ScrollBar\Color\Front     = GetSysColor_(#COLOR_GRAYTEXT)
				ListView()\ScrollBar\Color\Back      = GetSysColor_(#COLOR_MENU)
				ListView()\ScrollBar\Color\Border    = GetSysColor_(#COLOR_3DSHADOW)
				ListView()\ScrollBar\Color\Gadget    = GetSysColor_(#COLOR_MENU)
				ListView()\ScrollBar\Color\Focus     = GetSysColor_(#COLOR_MENUHILIGHT)
				ListView()\ScrollBar\Color\ScrollBar = GetSysColor_(#COLOR_SCROLLBAR)
			CompilerCase #PB_OS_MacOS
				ListView()\ScrollBar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ListView()\ScrollBar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ListView()\ScrollBar\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				ListView()\ScrollBar\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				ListView()\ScrollBar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				; ListView()\ScrollBar\Color\ScrollBar = 
			CompilerCase #PB_OS_Linux

		CompilerEndSelect ;}
    
		BindEvent(#Event_Timer, @_AutoScroll())
		
	EndProcedure
	
  Procedure CreateScrollBar_(Label.s, X.i, Y.i, Width.i, Height.i, Minimum.i, Maximum.i, PageLength.i, Type.i=#False)
    
    If AddMapElement(ListView()\ScrollBar\Item(), Label)
    
      ListView()\ScrollBar\Item()\X = X
      ListView()\ScrollBar\Item()\Y = Y
      ListView()\ScrollBar\Item()\Width      = Width
      ListView()\ScrollBar\Item()\Height     = Height
      ListView()\ScrollBar\Item()\Minimum    = Minimum
      ListView()\ScrollBar\Item()\Maximum    = Maximum
      ListView()\ScrollBar\Item()\PageLength = PageLength
      ListView()\ScrollBar\Item()\Hide       = #True
      ListView()\ScrollBar\Item()\Type       = Type
      
      ListView()\ScrollBar\Item()\Cursor = #PB_Default
		
			ListView()\ScrollBar\Item()\Buttons\Forwards\State  = #PB_Default
			ListView()\ScrollBar\Item()\Buttons\Backwards\State = #PB_Default
			
			CalcScrollBarThumb_(Label)
		  DrawScrollBar_(Label)
			
    EndIf
    
  EndProcedure 
  ;}
	
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
		    
  		  If ListView()\ReDraw : Draw_() : EndIf
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
	    
	    If ListView()\ReDraw : Draw_() : EndIf
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
				
				InitScrollBar_(GNum)
				
				CreateScrollBar_("VScroll", Width - #ScrollBarSize - 1, 1, #ScrollBarSize, Height - 2, 1, 0, 0)

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
						ListView()\Color\Border    = GetSysColor_(#COLOR_WINDOWFRAME)
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
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(ListView()\Window\Num)
						ListView()\Window\Width  = WindowWidth(ListView()\Window\Num)
						ListView()\Window\Height = WindowHeight(ListView()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ListView()\Window\Num)
					EndIf
				EndIf ;}
				
				BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), ListView()\Window\Num)
				
				CloseGadgetList()
				
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
	      Draw_()
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
      
      If ListView()\ReDraw : Draw_() : EndIf
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
	        Break
	      EndIf
	    Next  
	    
	    If ListView()\ReDraw : Draw_() : EndIf
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
      ;|ListView::#GridLines
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

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 2532
; FirstLine = 527
; Folding = 5TGAAABE0gQijQwAwAAIAAhAAAAw-
; Markers = 1105
; EnableXP
; DPIAware