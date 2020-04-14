;/ ============================
;/ =    TreeExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ TreeEx - Gadget
;/
;/ On request and with the sponsorship of Cyllceaux
;/
;/ © 2020  by Thorsten Hoeppner (11/2019)
;/

; Last Update: 06.04.2020
;
; Bugfixes
; 
; Added: Keys up/down/left/right/home/end
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


;{ _____ TreeEx - Commands _____

; TreeEx::AddColumn()           - similar to 'AddGadgetColumn()'
; TreeEx::AddItem()             - similar to 'AddGadgetItem()'
; TreeEx::ClearItems()          - similar to 'ClearGadgetItems()'
; TreeEx::CountItems()          - similar to 'CountGadgetItems()'
; TreeEx::DisableReDraw()       - disable redraw
; TreeEx::Gadget()              - similar to 'TreeGadget()'
; TreeEx::GetItemColor()        - similar to 'GetGadgetItemColor()'
; TreeEx::GetItemData()         - similar to 'GetGadgetItemData()'
; TreeEx::GetItemLabel()        - similar to 'GetGadgetItemData()', but string (label)
; TreeEx::GetItemState()        - similar to 'GetGadgetItemState()'
; TreeEx::GetItemText()         - similar to 'GetGadgetItemText()'
; TreeEx::GetLabelState()       - similar to 'GetGadgetItemState()', but label instead of column
; TreeEx::GetLabelText()        - similar to 'GetGadgetItemText()',  but label instead of column
; TreeEx::GetState()            - similar to 'GetGadgetState()'
; TreeEx::Hide()                - similar to 'HideGadget()'
; TreeEx::RemoveItem()          - similar to 'RemoveGadgetItem()'
; TreeEx::SaveColorTheme()      - save a custom color theme
; TreeEx::SetAutoResizeColumn() - column that is reduced when the vertical scrollbar is displayed.
; TreeEx::SetAutoResizeFlags()  - [#MoveX|#MoveY|#Width|#Height]
; TreeEx::SetColor()            - similar to 'SetGadgetColor()'
; TreeEx::SetColorTheme()       - set or load a color theme
; TreeEx::SetFont()             - similar to 'SetGadgetFont()'
; TreeEx::SetHeaderAttribute()  - set header attribute (e.g. align)
; TreeEx::SetHeaderFont()       - set header font
; TreeEx::SetItemColor()        - similar to 'SetGadgetItemColor()'
; TreeEx::SetItemData()         - similar to 'SetGadgetItemData()'
; TreeEx::SetItemImage()        - similar to 'SetGadgetItemImage()'
; TreeEx::SetItemState()        - similar to 'SetGadgetItemState()'
; TreeEx::SetItemText()         - similar to 'SetGadgetItemText()'
; TreeEx::SetLabelState()       - similar to 'SetGadgetItemState()', but label instead of column
; TreeEx::SetLabelText()        - similar to 'SetGadgetItemText()',  but label instead of column
; TreeEx::SetState()            - similar to 'SetGadgetState()'
;}


; XIncludeFile "ModuleEx.pbi"

DeclareModule TreeEx
  
  #Version  = 20040600
  #ModuleEx = 19112002
  
  #Enable_ProgressBar = #True
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  ;{ _____ ScrollBar Constants _____
  EnumerationBinary ;{ ScrollBar
		#ScrollBar_Border            ; Draw gadget border
		#ScrollBar_ButtonBorder      ; Draw button borders
		#ScrollBar_ThumbBorder       ; Draw thumb border
		#ScrollBar_DragLines         ; Draw drag lines
	EndEnumeration ;}
	
	Enumeration 1     ;{ ScrollBar Buttons
	  #ScrollBar_Up
	  #ScrollBar_Down
	  #ScrollBar_Left
	  #ScrollBar_Right
	EndEnumeration ;}
	
	#ScrollBar_Default   = #False
	#ScrollBar_Frame     = #ScrollBar_Border
	#ScrollBar_DragPoint = #ScrollBar_ButtonBorder|#ScrollBar_ThumbBorder|#ScrollBar_DragLines|#ScrollBar_Border 
	;}
	
  ;{ _____ Constants _____
  #TreeColumn = 0
  
  #Header      = -1
  
  #FirstRow    =  0
  #LastRow     = -1
  #LastItem    = -1
  #FirstColumn =  1
  #LastColumn  = -1
  
  #Theme       = -1
  
  #Tree$     = "tree"
  #Progress$ = "{Percent}"
  
  EnumerationBinary ;{ Gadget Flags
    #NoButtons = #PB_Tree_NoButtons
    #NoLines   = #PB_Tree_NoLines
    #Hide
    #AutoResize 
		#Borderless
		#ColumnLines
		#CheckBoxes
		#ThreeState
		;#ToolTips 
		#ShowHeader
		#SelectRow
		#FitTreeColumn
		#AlwaysShowSelection
		#UseExistingCanvas
	EndEnumeration ;}
	
	#Left = 0
	EnumerationBinary  
    #Right
    #Center
    #Tree
    #ProgressBar
    #ShowPercent
		#Image
	EndEnumeration
	
	Enumeration 1     ;{ Attribute
	  #SubLevel = #PB_Tree_SubLevel ; = 1
	  #Align
	  #ScrollBar
	EndEnumeration ;}
	
	Enumeration
    #Theme_Default
    #Theme_Custom
    #Theme_Blue  
    #Theme_Green
  EndEnumeration
	
	EnumerationBinary ;{ State 
	  #Selected  = #PB_Tree_Selected  
    #Expanded  = #PB_Tree_Expanded
    #Checked   = #PB_Tree_Checked
    #Collapsed = #PB_Tree_Collapsed
    #Inbetween = #PB_Tree_Inbetween
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
		#LineColor
		#FocusFrontColor
		#FocusBackColor
		#ButtonFrontColor
		#ButtonBackColor
		#ButtonBorderColor
		#HeaderFrontColor
		#HeaderBackColor
		#HeaderBorderColor
		#ProgressTextColor
		#ProgressFrontColor
		#ProgressBackColor
		#ProgressGradientColor
		#ProgressBorderColor
		#ScrollBarFrontColor
    #ScrollBarBackColor 
    #ScrollBarBorderColor
    #ScrollBarButtonColor
    #ScrollBarThumbColor
	EndEnumeration ;}

	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget       = ModuleEx::#Event_Gadget
		#Event_Theme         = ModuleEx::#Event_Theme
		#Event_Timer         = ModuleEx::#Event_Timer
		
		#EventType_Row       = ModuleEx::#EventType_Row
		#EventType_CheckBox  = ModuleEx::#EventType_CheckBox
		#EventType_Collapsed = ModuleEx::#EventType_Collapsed
		#EventType_Expanded  = ModuleEx::#EventType_Expanded
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
		  #Event_Gadget
		  #Event_Timer
		EndEnumeration
		
		Enumeration #PB_EventType_FirstCustomValue
		  #EventType_Row
		  #EventType_CheckBox
		  #EventType_Collapsed
      #EventType_Expanded
    EndEnumeration
    
	CompilerEndIf
	;}

	;- ===========================================================================
	;-   DeclareModule
  ;- ===========================================================================
	
	Declare.i AddColumn(GNum.i, Column.i, Width.f, Title.s="", Label.s="", Flags.i=#False)
	Declare.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Image.i=#False, Sublevel.i=0, Flags.i=#False)
	Declare   ClearItems(GNum.i)
	Declare.i CountItems(GNum.i)
	Declare   DisableReDraw(GNum.i, State.i=#False)
	Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Title.s="", Flags.i=#False, WindowNum.i=#PB_Default)
	Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetID(GNum.i, String.s)
  Declare.i GetItemAttribute(GNum.i, Row.i, Attribute.i)
	Declare.i GetItemColor(GNum.i, Row.i, ColorTyp.i, Column.i=#PB_Ignore)
	Declare.i GetItemData(GNum.i, Row.i)
	Declare.s GetItemLabel(GNum.i, Row.i)
  Declare.i GetItemState(GNum.i, Row.i, Column.i=#PB_Ignore)
  Declare.s GetItemText(GNum.i, Row.i, Column.i=#PB_Ignore)
  Declare.i GetLabelState(GNum.i, Row.i, Label.s=#Tree$)
  Declare.s GetLabelText(GNum.i, Row.i, Label.s=#Tree$) 
  Declare.i GetState(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   SaveColorTheme(GNum.i, File.s)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeColumn(GNum.i, Column.i, minWidth.f=#PB_Default, maxWidth.f=#PB_Default)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
  Declare   SetColorTheme(GNum.i, Theme.i=#Theme_Default, File.s="")
  Declare   SetFont(GNum.i, FontID.i, Column.i=#PB_Ignore)
  Declare   SetHeaderAttribute(GNum.i, Attribute.i, Value.i, Column.i=#PB_Ignore)
  Declare   SetHeaderFont(GNum.i, FontID.i, Column.i=#PB_Ignore)
  Declare   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
  Declare   SetItemData(GNum.i, Row.i, Value.i)
  Declare   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False, Column.i=#TreeColumn)
  Declare   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore)
  Declare   SetItemText(GNum.i, Row.i, Text.s, Column.i=#TreeColumn)
  Declare   SetLabelState(GNum.i, Row.i, State.i, Label.s=#Tree$)
  Declare   SetLabelText(GNum.i, Row.i, Text.s, Label.s=#Tree$)
  Declare   SetState(GNum.i, State.i)
  
EndDeclareModule

Module TreeEx

	EnableExplicit
	
	;{ OS specific contants
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #ScrollBarSize  = 18
    CompilerCase #PB_OS_MacOS
      #ScrollBarSize  = 18
    CompilerCase #PB_OS_Linux
      #ScrollBarSize  = 18
  CompilerEndSelect ;}
	
	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#ButtonSize = 9
	
	#ScrollBar_ButtonSize = 18
  
  #ScrollBar_Horizontal = 0
  #ScrollBar_Vertical   = #PB_ScrollBar_Vertical

  #ScrollBar_Timer      = 100
	#ScrollBar_TimerDelay = 3
	
	Enumeration 1                              ;{ ScrollBar Buttons
	  #ScrollBar_Forwards
	  #ScrollBar_Backwards
	  #ScrollBar_Focus
	  #ScrollBar_Click
	EndEnumeration ;}
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
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
	  Offset.i
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
  
  
	Structure Tree_Structure                  ;{ ...\Tree\...
	  X.i
	  Y.i
	  Level.i
	  NextLevel.i
	  Button.i
	EndStructure ;}
	
	Structure Image_Structure                 ;{ ...\Image\...
    Num.i
    Width.f
    Height.f
    Flags.i
  EndStructure ;}
  
  Structure Color_Structure                 ;{ ...\Color\...
    Front.i
    Back.i
    Border.i
  EndStructure ;}

  Structure TreeEx_AutoResize_Structure     ;{ TreeEx()\AutoResize\...
    Column.i
    Width.f
    minWidth.f
    maxWidth.f
  EndStructure ;}
  
  Structure TreeEx_Col_Structure            ;{ TreeEx()\Col\...
    Counter.i
    TreeWidth.i
    OffsetX.i
  EndStructure ;}
  
  Structure Cols_Header_Structure           ;{ TreeEx()\Cols()\Header\...
    Title.s
    FontID.i
    Flags.i
    Color.Color_Structure
    Image.Image_Structure
  EndStructure ;}
  
  Structure TreeEx_Cols_Structure           ;{ TreeEx()\Cols()\...
    X.f
    Key.s    ; = Label
    Width.f
    FontID.i
    Color.Color_Structure
    Flags.i
    Header.Cols_Header_Structure
  EndStructure ;}    
  
  
  Structure Row_Header_Structure            ;{ TreeEx()\Row\Header\...
    Height.i
  EndStructure ;}
  
  Structure TreeEx_Row_Structure            ;{ TreeEx()\Row\...
    Height.i
    Focus.i
    Visible.i
    vFocus.i
    Offset.i
    OffSetY.i
    LastVisible.i
    Header.Row_Header_Structure
  EndStructure ;}  
  
  
  Structure TreeEx_Rows_ProgressBar         ;{ TreeEx()\ProgressBar\...
    Minimum.i
    Maximum.i
    Flags.i
  EndStructure ;}
  
  Structure TreeEx_Rows_Text_Structure      ;{ TreeEx()\Rows()\Text\...
    X.i
    Width.i
  EndStructure ;}  
  
  Structure TreeEx_Rows_CheckBox_Structure  ;{ TreeEx()\Rows()\CheckBox\...
    X.i
    Y.i
    Size.i
  EndStructure ;}  

  Structure TreeEx_Rows_Button_Structure    ;{ TreeEx()\Rows()\Button\...
    X.i
    Y.i
    State.i
  EndStructure ;}
  
  Structure TreeEx_Rows_Column_Structure    ;{ TreeEx()\Rows()\Column('label')\...
    Value.s
    ;FontID.i
    State.i
    Color.Color_Structure
    Image.Image_Structure
  EndStructure ;}
	
  Structure TreeEx_Rows_Structure           ;{ TreeEx()\Rows()\...
    ID.s
    iData.i
    
    Y.f

    Level.i
    State.i
    
    Visible.i
    
    Button.TreeEx_Rows_Button_Structure
    CheckBox.TreeEx_Rows_CheckBox_Structure
    Color.Color_Structure
    Text.TreeEx_Rows_Text_Structure

    Map Column.TreeEx_Rows_Column_Structure()
    
  EndStructure ;}  	

	Structure TreeEx_Color_Structure          ;{ TreeEx()\Color\...
		Front.i
		Back.i
		Border.i
		Line.i
		ScrollBar.i
		ButtonFront.i
		ButtonBack.i
    ButtonBorder.i
    FocusFront.i
    FocusBack.i
    HeaderFront.i
    HeaderBack.i
    HeaderBorder.i
    ProgressText.i
    ProgressFront.i
    ProgressBack.i
    ProgressGradient.i
    ProgressBorder.i
    Gadget.i
	EndStructure  ;}

	Structure TreeEx_Window_Structure         ;{ TreeEx()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure TreeEx_Size_Structure           ;{ TreeEx()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Rows.i
		Cols.i
		Flags.i
	EndStructure ;}

	Structure TreeEx_Structure                ;{ TreeEx()\...
		CanvasNum.i
		
		Quad.q
		ID.s
		
		FontID.i

		ReDraw.i
		Hide.i
		
		Flags.i

		ToolTip.i
		ToolTipText.s
		
		AutoResize.TreeEx_AutoResize_Structure
		Color.TreeEx_Color_Structure
		Window.TreeEx_Window_Structure
		Size.TreeEx_Size_Structure
		
		
		ProgressBar.TreeEx_Rows_ProgressBar
		
		Row.TreeEx_Row_Structure
		Col.TreeEx_Col_Structure
		ScrollBar.ScrollBar_Structure
    
    List Lines.Tree_Structure()
		List Cols.TreeEx_Cols_Structure()
		List Rows.TreeEx_Rows_Structure()

	EndStructure ;}
	Global NewMap TreeEx.TreeEx_Structure()

	;- ============================================================================
	;-   Module - Internal
  ;- ============================================================================
	
	Declare CalcRows()
	Declare CalcScrollBarThumb_(ScrollBar.s, Reset.i=#True)
	Declare AdjustScrollBars_()
	Declare ReDraw_(ThumbOnly.i=#False)
	
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
	
	Procedure   SetColor_(ColorTyp.i, Value.i)
	  
	  Select ColorTyp
      Case #FrontColor
        TreeEx()\Color\Front              = Value
      Case #BackColor
        TreeEx()\Color\Back               = Value
      Case #BorderColor
        TreeEx()\Color\Border             = Value
      Case #LineColor  
        TreeEx()\Color\Line               = Value
      Case #FocusFrontColor
        TreeEx()\Color\FocusFront         = Value
      Case #FocusBackColor
        TreeEx()\Color\FocusBack          = Value
      Case #ButtonFrontColor
        TreeEx()\Color\ButtonFront        = Value
      Case #ButtonBackColor
        TreeEx()\Color\ButtonBack         = Value
      Case #ButtonBorderColor
        TreeEx()\Color\ButtonBorder       = Value
      Case #HeaderFrontColor
        TreeEx()\Color\HeaderFront        = Value
      Case #HeaderBackColor
        TreeEx()\Color\HeaderBack         = Value
      Case #HeaderBorderColor
        TreeEx()\Color\HeaderBorder       = Value
      Case #ProgressTextColor
        TreeEx()\Color\ProgressText       = Value
      Case #ProgressFrontColor
        TreeEx()\Color\ProgressFront      = Value
      Case #ProgressBackColor
        TreeEx()\Color\ProgressBack        = Value
      Case #ProgressGradientColor
        TreeEx()\Color\ProgressGradient    = Value
      Case #ProgressBorderColor  
        TreeEx()\Color\ProgressBorder      = Value
      Case #ScrollBarFrontColor
        TreeEx()\ScrollBar\Color\Front     = Value
      Case #ScrollBarBackColor 
        TreeEx()\ScrollBar\Color\Back      = Value
      Case #ScrollBarBorderColor
        TreeEx()\ScrollBar\Color\Border    = Value
      Case #ScrollBarButtonColor
        TreeEx()\ScrollBar\Color\Button    = Value
      Case #ScrollBarThumbColor
        TreeEx()\ScrollBar\Color\ScrollBar = Value  
    EndSelect
	  
	EndProcedure  
	
	Procedure.i GetPageRows_()    ; all visible Rows
	  Define.i Height
	  
	  Height = GadgetHeight(TreeEx()\CanvasNum)
	  
	  If TreeEx()\Flags & #ShowHeader
	    Height - TreeEx()\Row\Header\Height  
	  EndIf
	  
	  PushMapPosition(TreeEx()\ScrollBar\Item())
	  
	  If TreeEx()\ScrollBar\Item("HScroll")\Hide = #False
	    Height - #ScrollBarSize
	  EndIf  
	  
	  PopMapPosition(TreeEx()\ScrollBar\Item())
	  
	  ProcedureReturn Int(Height / TreeEx()\Row\Height)
  EndProcedure 
  
  Procedure   SetRowFocus_()
    Define.i PageRows
    
    If TreeEx()\ScrollBar\Item("VScroll")\Hide : ProcedureReturn #False :  EndIf 
    
    CalcRows()
    
    PageRows = GetPageRows_()

    If TreeEx()\Row\vFocus + TreeEx()\Row\Offset >= PageRows 
      If TreeEx()\Row\vFocus < PageRows
        TreeEx()\ScrollBar\Item("VScroll")\Pos = 0
      Else
        TreeEx()\ScrollBar\Item("VScroll")\Pos = TreeEx()\Row\vFocus - PageRows + 1
      EndIf  
    ElseIf TreeEx()\Row\vFocus <= TreeEx()\Row\Offset
      TreeEx()\ScrollBar\Item("VScroll")\Pos = TreeEx()\Row\vFocus
    EndIf

  EndProcedure
  
  Procedure   ExpandFocus_(State.i)
    Define.i Level
    
    If State < 0 : ProcedureReturn #False : EndIf
    
    If SelectElement(TreeEx()\Rows(), State)
      
      Level = TreeEx()\Rows()\Level
      If Level
        
        Repeat
        
          If PreviousElement(TreeEx()\Rows())
            
            If TreeEx()\Rows()\Level < Level
              TreeEx()\Rows()\Button\State = #True
    	        TreeEx()\Rows()\State | #Expanded
    	        TreeEx()\Rows()\State & ~#Collapsed
              Level = TreeEx()\Rows()\Level
            EndIf  
            
            If TreeEx()\Rows()\Level = 0 : Break : EndIf
            
          Else
            Break
          EndIf   
          
        Until ListIndex(TreeEx()\Rows()) <= 0  
        
      EndIf
      
      CalcRows()
      CalcScrollBarThumb_("VScroll", #False)
      
    EndIf  
    
  EndProcedure
  
	Procedure.i TreeColumnWidth()   
	  Define.i Width
	  
	  Width = GadgetWidth(TreeEx()\CanvasNum)

	  ForEach TreeEx()\Cols()
	    If ListIndex(TreeEx()\Cols()) = 0 : Continue : EndIf ; Ignore tree coloumn
	    Width - TreeEx()\Cols()\Width
	  Next 

	  ProcedureReturn Width
	EndProcedure
	
	;- __________ ScrollBars __________
	
	Procedure   CalcRows()
    Define.i TreeWidth, maxWidth, LevelWidth, Level, NextLevel, LastLevel, FontID
    Define.i X, Y, btX, txtX, OffsetX, OffsetY, ImageWidth, ImageHeight, RowHeight, CheckBoxSize
    Define.f Factor
    
    If TreeEx()\ScrollBar\Item("VScroll")\Hide
      TreeEx()\Row\Offset = 0
    Else  
      TreeEx()\Row\Offset = TreeEx()\ScrollBar\Item("VScroll")\Pos
    EndIf  
    
    If TreeEx()\ScrollBar\Item("HScroll")\Hide
      TreeEx()\Col\OffsetX = 0
    Else  
      TreeEx()\Col\OffsetX = TreeEx()\ScrollBar\Item("HScroll")\Pos
    EndIf
    
    If StartDrawing(CanvasOutput(TreeEx()\CanvasNum))
      
      ClearList(TreeEx()\Lines())

      RowHeight    = dpiY(TreeEx()\Row\Height)
      LevelWidth   = dpiX(#ButtonSize) + dpiX(5)
      CheckBoxSize = TextHeight("Abc") - dpiX(2)
      
      OffsetY = TreeEx()\Row\Offset * RowHeight
      
      X = -dpiX(TreeEx()\Col\OffsetX)
      
      If TreeEx()\Flags & #ShowHeader
        Y = dpiY(TreeEx()\Row\Header\Height)
      Else
        Y = dpiY(2)
      EndIf  

      Y + dpiY(2)
      
      TreeEx()\Size\Rows   = 0
      TreeEx()\Row\Visible = 0

      ForEach TreeEx()\Rows()
        
        TreeWidth = 0
 
        If TreeEx()\Rows()\Level < Level : Level = TreeEx()\Rows()\Level : EndIf

  		  If TreeEx()\Rows()\Level = Level And TreeEx()\Rows()\Button\State
  		    Level = TreeEx()\Rows()\Level + 1
  		  EndIf
  		  
  		  If TreeEx()\Rows()\Level - LastLevel > 1
		      TreeEx()\Rows()\Level = LastLevel + 1
		    EndIf
  		  
  		  LastLevel = TreeEx()\Rows()\Level
  		  
        If TreeEx()\Rows()\Level > Level
  		    TreeEx()\Rows()\Visible      = #False
  		    TreeEx()\Rows()\Button\State = #False
  		    Continue
  		  EndIf

  		  TreeEx()\Rows()\Visible = #True
  		  
  		  TreeEx()\Row\LastVisible = ListIndex(TreeEx()\Rows())
  		  If TreeEx()\Row\Focus = ListIndex(TreeEx()\Rows()) : TreeEx()\Row\vFocus = TreeEx()\Row\Visible  : EndIf
  		  
		    TreeEx()\Row\Visible + 1
  		  TreeEx()\Size\Rows   + TreeEx()\Row\Height

  		  If TreeEx()\Cols()\FontID
		      FontID = TreeEx()\Cols()\FontID
		    Else
		     	FontID = TreeEx()\FontID
		    EndIf
		   
		    DrawingFont(FontID)
		    
		    ;{ --- Level of the next line ---
			  PushListPosition(TreeEx()\Rows())
			  If NextElement(TreeEx()\Rows())
			    NextLevel = TreeEx()\Rows()\Level
			  Else
			    NextLevel = -1
			  EndIf  

			  PopListPosition(TreeEx()\Rows())
			  ;}
			  
			  OffsetX = LevelWidth * TreeEx()\Rows()\Level + dpiX(6)
			  
	      If AddElement(TreeEx()\Lines())
			    TreeEx()\Lines()\X         = X + OffsetX + dpiX(#ButtonSize / 2)
			    TreeEx()\Lines()\Y         = Y + (RowHeight / 2) - OffsetY
			    TreeEx()\Lines()\Level     = TreeEx()\Rows()\Level
			    TreeEx()\Lines()\NextLevel = NextLevel
			    If NextLevel = TreeEx()\Lines()\Level + 1
			      TreeEx()\Lines()\Button = #True
			    EndIf
			  EndIf 
	  
			  TreeWidth = dpiX(#ButtonSize + 5) + OffsetX
			  
			  If TreeEx()\Flags & #CheckBoxes : TreeWidth + CheckBoxSize : EndIf
			  
			  If IsImage(TreeEx()\Rows()\Column(#Tree$)\Image\Num) ;{ Image

			    ImageWidth  = TreeEx()\Rows()\Column(#Tree$)\Image\Width
          ImageHeight = TreeEx()\Rows()\Column(#Tree$)\Image\Height
          
          If TreeEx()\Rows()\Column(#Tree$)\Image\Height > RowHeight - dpiY(2)
            ImageHeight = RowHeight - dpiY(2)
            Factor      = ImageHeight / TreeEx()\Rows()\Column(#Tree$)\Image\Height
            ImageWidth  = ImageWidth * Factor
          EndIf  
          
          TreeWidth + ImageWidth + dpiX(3)
			    ;}
			  EndIf  
			  
			  TreeWidth + TextWidth(TreeEx()\Rows()\Column(#Tree$)\Value) + dpiX(10)
			  
			  If TreeWidth > maxWidth : maxWidth = TreeWidth : EndIf
			  
			  Y + dpiY(TreeEx()\Row\Height)
			Next
			
			TreeEx()\Col\TreeWidth = maxWidth
			
    	StopDrawing()
    EndIf
     
  EndProcedure
  
  Procedure   CalcCols()
    Define.i TreeColumnWidth.i, ColumnWidth
    
    TreeColumnWidth = TreeColumnWidth() 
    
    TreeEx()\Size\Cols = 0
    
    ForEach TreeEx()\Cols()
      
      If TreeEx()\Cols()\Width = #PB_Default
	      ColumnWidth = TreeColumnWidth
	    Else
	      ColumnWidth = TreeEx()\Cols()\Width
	    EndIf  
      
      If ListIndex(TreeEx()\Cols()) = #TreeColumn
        If TreeEx()\Flags & #FitTreeColumn Or ColumnWidth < TreeEx()\Col\TreeWidth
	        ColumnWidth = TreeEx()\Col\TreeWidth
	      EndIf
	    EndIf  
	    
      TreeEx()\Size\Cols + ColumnWidth
      
    Next
    
  EndProcedure
  
  Procedure.i CalcScrollBarThumb_(ScrollBar.s, Reset.i=#True)
	  Define.i Size, Range, HRange
	 
	  If FindMapElement(TreeEx()\ScrollBar\Item(), ScrollBar)
	    
  	  TreeEx()\ScrollBar\Item()\minPos   = TreeEx()\ScrollBar\Item()\Minimum
  	  TreeEx()\ScrollBar\Item()\maxPos   = TreeEx()\ScrollBar\Item()\Maximum - TreeEx()\ScrollBar\Item()\PageLength + 1
  	  TreeEx()\ScrollBar\Item()\Ratio    = TreeEx()\ScrollBar\Item()\PageLength / TreeEx()\ScrollBar\Item()\Maximum
  	  If Reset : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\Minimum : EndIf 
  	  
  	  Range = TreeEx()\ScrollBar\Item()\maxPos - TreeEx()\ScrollBar\Item()\minPos
  	  
  	  If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	    TreeEx()\ScrollBar\Item()\Area\X       = TreeEx()\ScrollBar\Item()\X
    	  TreeEx()\ScrollBar\Item()\Area\Y       = TreeEx()\ScrollBar\Item()\Y + dpiY(#ScrollBar_ButtonSize) + dpiY(1)
    	  TreeEx()\ScrollBar\Item()\Area\Width   = TreeEx()\ScrollBar\Item()\Width
    	  TreeEx()\ScrollBar\Item()\Area\Height  = TreeEx()\ScrollBar\Item()\Height - dpiY(TreeEx()\ScrollBar\Adjust) - dpiY(#ScrollBar_ButtonSize * 2) - dpiY(2)
    	  TreeEx()\ScrollBar\Item()\Thumb\Y      = TreeEx()\ScrollBar\Item()\Area\Y
    	  TreeEx()\ScrollBar\Item()\Thumb\Size   = Round(TreeEx()\ScrollBar\Item()\Area\Height * TreeEx()\ScrollBar\Item()\Ratio, #PB_Round_Down)
    	  TreeEx()\ScrollBar\Item()\Thumb\Factor = (TreeEx()\ScrollBar\Item()\Area\Height - TreeEx()\ScrollBar\Item()\Thumb\Size) / Range
  	  Else
  	    TreeEx()\ScrollBar\Item()\Area\X       = TreeEx()\ScrollBar\Item()\X + dpiX(#ScrollBar_ButtonSize) + dpiX(1)
    	  TreeEx()\ScrollBar\Item()\Area\Y       = TreeEx()\ScrollBar\Item()\Y
    	  TreeEx()\ScrollBar\Item()\Area\Width   = TreeEx()\ScrollBar\Item()\Width - dpiX(TreeEx()\ScrollBar\Adjust) - dpiX(#ScrollBar_ButtonSize * 2) - dpiX(2)
    	  TreeEx()\ScrollBar\Item()\Area\Height  = TreeEx()\ScrollBar\Item()\Height
    	  TreeEx()\ScrollBar\Item()\Thumb\X      = TreeEx()\ScrollBar\Item()\Area\X
    	  TreeEx()\ScrollBar\Item()\Thumb\Size   = Round(TreeEx()\ScrollBar\Item()\Area\Width * TreeEx()\ScrollBar\Item()\Ratio, #PB_Round_Down)
    	  TreeEx()\ScrollBar\Item()\Thumb\Factor = (TreeEx()\ScrollBar\Item()\Area\Width - TreeEx()\ScrollBar\Item()\Thumb\Size) / Range
  	  EndIf  

	  EndIf   

	EndProcedure  
  
	Procedure   AdjustScrollBars_()
	  Define.i Width, WidthOffset, PageRows, Result
	  
	  PageRows = GetPageRows_()
	  
    If FindMapElement(TreeEx()\ScrollBar\Item(), "VScroll") ;{ Vertical ScrollBar
      
      If PageRows < TreeEx()\Row\Visible

        TreeEx()\ScrollBar\Item()\Minimum    = 0
        TreeEx()\ScrollBar\Item()\Maximum    = TreeEx()\Row\Visible - 1
        TreeEx()\ScrollBar\Item()\PageLength = PageRows
        
        If TreeEx()\ScrollBar\Item()\Hide
          TreeEx()\ScrollBar\Item()\Hide = #False
          CalcScrollBarThumb_("VScroll") 
          Result = #True
        EndIf
        
      Else
  
        If TreeEx()\ScrollBar\Item()\Hide = #False
          
          TreeEx()\Row\Offset = 0
          TreeEx()\ScrollBar\Item()\Hide = #True
          
          If ListSize(TreeEx()\Rows()) = 0
            TreeEx()\ScrollBar\Item()\Minimum    = 0
            TreeEx()\ScrollBar\Item()\Maximum    = 0
            TreeEx()\ScrollBar\Item()\PageLength = 0
          EndIf 
          
        EndIf
        
        Result = #True
      EndIf
      ;}
    EndIf
   
    If TreeEx()\ScrollBar\Item("VScroll")\Hide
      Width = GadgetWidth(TreeEx()\CanvasNum)
    Else
      Width = GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize - 2
    EndIf
    
    If TreeEx()\AutoResize\Column <> #PB_Ignore ;{ Resize column

      If TreeEx()\Size\Cols > Width
        
        WidthOffset = TreeEx()\Size\Cols - Width

        If SelectElement(TreeEx()\Cols(), TreeEx()\AutoResize\Column)

          If TreeEx()\Cols()\Width - WidthOffset >= TreeEx()\AutoResize\MinWidth
            TreeEx()\Cols()\Width  - WidthOffset
            TreeEx()\ScrollBar\Item("HScroll")\Hide  = #True
            Result = #True
          Else 
            TreeEx()\Cols()\Width = TreeEx()\AutoResize\MinWidth
          EndIf
          CalcCols()
        EndIf
 
      ElseIf TreeEx()\Size\Cols And TreeEx()\Size\Cols < Width
        
        WidthOffset = Width - TreeEx()\Size\Cols

        If SelectElement(TreeEx()\Cols(), TreeEx()\AutoResize\Column)

          If TreeEx()\AutoResize\maxWidth > #PB_Default And TreeEx()\Cols()\Width + WidthOffset > TreeEx()\AutoResize\maxWidth
            TreeEx()\Cols()\Width = TreeEx()\AutoResize\maxWidth
          Else  
            TreeEx()\Cols()\Width + WidthOffset
          EndIf
          
          CalcCols()
        EndIf

      EndIf
      ;}
    EndIf  
    
    If FindMapElement(TreeEx()\ScrollBar\Item(), "HScroll") ;{ Horizontal Scrollbar
      
      If TreeEx()\Size\Cols > Width
        
        TreeEx()\ScrollBar\Item()\Minimum    = 0
        TreeEx()\ScrollBar\Item()\Maximum    = TreeEx()\Size\Cols
        TreeEx()\ScrollBar\Item()\PageLength = Width
        
        If TreeEx()\ScrollBar\Item()\Hide
          TreeEx()\ScrollBar\Item()\Hide = #False
          CalcScrollBarThumb_("HScroll")
          Result = #True
        EndIf

      ElseIf TreeEx()\Size\Cols <= Width
        
        If TreeEx()\ScrollBar\Item()\Hide = #False
          TreeEx()\ScrollBar\Item("HScroll")\Hide = #True
          Result = #True
        EndIf
        
      EndIf 
      ;}
    EndIf
    
    If TreeEx()\ScrollBar\Item("HScroll")\Hide = #False And TreeEx()\ScrollBar\Item("VScroll")\Hide = #False
      TreeEx()\ScrollBar\Adjust = #ScrollBarSize
    Else
      TreeEx()\ScrollBar\Adjust = 0
    EndIf  
    
    ProcedureReturn Result
  EndProcedure

	Procedure GetScrollBarPos(XY.i)
	  ProcedureReturn (XY / TreeEx()\ScrollBar\Item()\Thumb\Factor) + TreeEx()\ScrollBar\Item()\minPos 
	EndProcedure  
	
	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	
  Procedure   ColorTheme_(Theme.i)

    Select Theme
      Case #Theme_Blue
        
        TreeEx()\Color\Front            = $490000
				TreeEx()\Color\Back             = $FEFDFB
				TreeEx()\Color\Border           = $8C8C8C
				TreeEx()\Color\Line             = $C5C5C5
				TreeEx()\Color\ScrollBar        = $F0F0F0
				TreeEx()\Color\Gadget           = $F0F0F0
				TreeEx()\Color\FocusFront       = $43321C
				TreeEx()\Color\FocusBack        = $B06400
				TreeEx()\Color\ButtonFront      = $490000
				TreeEx()\Color\ButtonBack       = $E3E3E3
				TreeEx()\Color\ButtonBorder     = $B48246
				TreeEx()\Color\HeaderFront      = $43321C
        TreeEx()\Color\HeaderBack       = $E5CBAA
        TreeEx()\Color\HeaderBorder     = $A0A0A0
        TreeEx()\Color\ProgressText     = $490000
        TreeEx()\Color\ProgressFront    = $E5CBAA
        TreeEx()\Color\ProgressBack     = #PB_Default
        TreeEx()\Color\ProgressGradient = $CB9755
        TreeEx()\Color\ProgressBorder   = $764200
        
      Case #Theme_Green
        
        TreeEx()\Color\Front            = $0F2203
				TreeEx()\Color\Back             = $FCFDFC
				TreeEx()\Color\Border           = $9B9B9B
				TreeEx()\Color\Line             = $CCCCCC
				TreeEx()\Color\ScrollBar        = $F0F0F0
				TreeEx()\Color\Gadget           = $F0F0F0
				TreeEx()\Color\FocusFront       = $142D05
				TreeEx()\Color\FocusBack        = $3E8910
				TreeEx()\Color\ButtonFront      = $0F2203
				TreeEx()\Color\ButtonBack       = $E3E3E3
				TreeEx()\Color\ButtonBorder     = $A0A0A0
				TreeEx()\Color\HeaderFront      = $142D05
        TreeEx()\Color\HeaderBack       = $BED7AF
        TreeEx()\Color\HeaderBorder     = $A0A0A0
        TreeEx()\Color\ProgressText     = $F5F9F3
        TreeEx()\Color\ProgressFront    = $BED7AF
        TreeEx()\Color\ProgressBack     = #PB_Default
        TreeEx()\Color\ProgressGradient = $7EB05F
        TreeEx()\Color\ProgressBorder   = $295B0A
        
      Default
        
        TreeEx()\Color\Front            = $000000
				TreeEx()\Color\Back             = $FFFFFF
				TreeEx()\Color\Border           = $E3E3E3
				TreeEx()\Color\Line             = $A0A0A0
				TreeEx()\Color\ScrollBar        = $F0F0F0
				TreeEx()\Color\Gadget           = $F0F0F0
				TreeEx()\Color\FocusFront       = $670000
				TreeEx()\Color\FocusBack        = $D77800
				TreeEx()\Color\ButtonFront      = $000000
				TreeEx()\Color\ButtonBack       = $E3E3E3
				TreeEx()\Color\ButtonBorder     = $A0A0A0
				TreeEx()\Color\HeaderFront      = $000000
        TreeEx()\Color\HeaderBack       = $FAFAFA
        TreeEx()\Color\HeaderBorder     = $A0A0A0
        TreeEx()\Color\ProgressText     = $0F2203
        TreeEx()\Color\ProgressFront    = $32CD32
        TreeEx()\Color\ProgressBack     = #PB_Default
        TreeEx()\Color\ProgressGradient = $00FC7C
        TreeEx()\Color\ProgressBorder   = $A0A0A0
        
        CompilerSelect  #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            TreeEx()\Color\Front        = GetSysColor_(#COLOR_WINDOWTEXT)
				    TreeEx()\Color\Back         = GetSysColor_(#COLOR_WINDOW)
				    TreeEx()\Color\Border       = GetSysColor_(#COLOR_ACTIVEBORDER)
				    TreeEx()\Color\ScrollBar    = GetSysColor_(#COLOR_MENU)
				    TreeEx()\Color\FocusBack    = GetSysColor_(#COLOR_MENUHILIGHT)
						TreeEx()\Color\ButtonFront  = GetSysColor_(#COLOR_BTNTEXT)
						TreeEx()\Color\ButtonBack   = GetSysColor_(#COLOR_3DLIGHT)
						TreeEx()\Color\ButtonBorder = GetSysColor_(#COLOR_3DSHADOW)
						TreeEx()\Color\HeaderFront  = GetSysColor_(#COLOR_WINDOWTEXT)
						TreeEx()\Color\HeaderBack   = GetSysColor_(#COLOR_WINDOW)
						TreeEx()\Color\HeaderBorder = GetSysColor_(#COLOR_3DSHADOW)
						TreeEx()\Color\Gadget       = GetSysColor_(#COLOR_MENU)
        CompilerCase #PB_OS_MacOS
            TreeEx()\Color\Front        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
				    TreeEx()\Color\Back         = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
				    TreeEx()\Color\Border       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				    TreeEx()\Color\ScrollBar    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
				    TreeEx()\Color\FocusBack    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
						TreeEx()\Color\ButtonFront  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						TreeEx()\Color\ButtonBack   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
						TreeEx()\Color\ButtonBorder = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						TreeEx()\Color\HeaderFront  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						TreeEx()\Color\HeaderBack   = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
						TreeEx()\Color\HeaderBorder = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						TreeEx()\Color\Gadget       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
        CompilerCase #PB_OS_Linux
       
      CompilerEndSelect
    EndSelect
    
  EndProcedure  
  
	
	Procedure   DrawScrollArrow_(X.i, Y.i, Width.i, Height.i, Color.i, Flag.i)
	  Define.i aWidth, aHeight, aColor

	  If StartVectorDrawing(CanvasVectorOutput(TreeEx()\CanvasNum))

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
	  
	  If StartDrawing(CanvasOutput(TreeEx()\CanvasNum))
	    
	    DrawingMode(#PB_2DDrawing_Default)
	    
	    Select State
	      Case #ScrollBar_Focus
	        Color  = BlendColor_(TreeEx()\ScrollBar\Color\Focus, TreeEx()\ScrollBar\Color\Button, 10)
	        Border = BlendColor_(TreeEx()\ScrollBar\Color\Focus, TreeEx()\ScrollBar\Color\Border, 10)
	      Case #ScrollBar_Click
	        Color  = BlendColor_(TreeEx()\ScrollBar\Color\Focus, TreeEx()\ScrollBar\Color\Button, 20)
	        Border = BlendColor_(TreeEx()\ScrollBar\Color\Focus, TreeEx()\ScrollBar\Color\Border, 20)
	      Default
	        Color  = TreeEx()\ScrollBar\Color\Button
	        Border = TreeEx()\ScrollBar\Color\Border
	    EndSelect    
	    
	    If FindMapElement(TreeEx()\ScrollBar\Item(), ScrollBar)
	      
	      If TreeEx()\ScrollBar\Item()\Hide : ProcedureReturn #False : EndIf 
	      
	      Select Type
  	      Case #ScrollBar_Forwards
  	        If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	          Box(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height,  Color)
  	        Else
  	          Box(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height,  Color)
  	        EndIf  
  	      Case #ScrollBar_Backwards
  	        If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	          Box(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, Color)
  	        Else
  	          Box(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, Color)
  	        EndIf   
  	    EndSelect    
	      
	      If TreeEx()\ScrollBar\Flags & #ScrollBar_ButtonBorder
	      
  	      DrawingMode(#PB_2DDrawing_Outlined)
  	      
  	      Select Type
  	        Case #ScrollBar_Forwards
  	          If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  	            Box(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X - dpiX(1), TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width + dpiX(2), TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height + dpiY(2), Border)
  	          Else
  	            Box(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y - dpiY(1), TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width + dpiX(2), TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height + dpiY(2), Border)
  	          EndIf  
    	      Case #ScrollBar_Backwards
    	        If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
    	          Box(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X - dpiX(1), TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y - dpiY(1), TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width + dpiX(2), TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height + dpiY(1), Border)
    	        Else
  	            Box(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X - dpiX(1), TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y - dpiY(1), TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width + dpiX(1), TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height + dpiY(2), Border)
  	          EndIf   
    	    EndSelect 
    	    
  	    EndIf 
	    
	    EndIf

	    StopDrawing()
	  EndIf
	  
	  ;{ ----- Draw Arrows -----
	  If FindMapElement(TreeEx()\ScrollBar\Item(), ScrollBar)
	    
  	  Select Type
        Case #ScrollBar_Forwards
          If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
            DrawScrollArrow_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, TreeEx()\ScrollBar\Color\Front, #ScrollBar_Down)
          Else
            DrawScrollArrow_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, TreeEx()\ScrollBar\Color\Front, #ScrollBar_Right)
          EndIf  
        Case #ScrollBar_Backwards
          If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
        		DrawScrollArrow_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, TreeEx()\ScrollBar\Color\Front, #ScrollBar_Up)
        	Else
        	  DrawScrollArrow_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, TreeEx()\ScrollBar\Color\Front, #ScrollBar_Left)
        	EndIf  
      EndSelect
    
    EndIf ;}

	EndProcedure
	
	Procedure   DrawScrollBar_(ScrollBar.s, ThumbOnly.i=#False)
		Define.i X, Y, Width, Height, Offset, OffsetX, OffsetY
		Define.i FrontColor, BackColor, BorderColor, ScrollBorderColor
		
		If FindMapElement(TreeEx()\ScrollBar\Item(), ScrollBar)
		  
      If TreeEx()\ScrollBar\Item()\Hide : ProcedureReturn #False : EndIf 
  	 
      ;{ ----- Size -----
		  X      = TreeEx()\ScrollBar\Item()\X
		  Y      = TreeEx()\ScrollBar\Item()\Y
		  Width  = TreeEx()\ScrollBar\Item()\Width 
		  Height = TreeEx()\ScrollBar\Item()\Height
		  ;}
		  
		  Offset = (TreeEx()\ScrollBar\Item()\Pos - TreeEx()\ScrollBar\Item()\minPos) * TreeEx()\ScrollBar\Item()\Thumb\Factor
		  
		  If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
		    
        ;{ ----- Buttons -----
  		  TreeEx()\ScrollBar\Item()\Buttons\Forwards\X       = X
    		TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y       = Y + Height - dpiY(#ScrollBar_ButtonSize) - dpiY(TreeEx()\ScrollBar\Adjust) + dpiY(1)
    		TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width   = Width
    		TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height  = dpiY(#ScrollBar_ButtonSize)	
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\X      = X
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y      = Y
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width  = Width
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height = dpiY(#ScrollBar_ButtonSize)
    		;}
        ;{ ----- ScrollArea -----
    		TreeEx()\ScrollBar\Item()\Area\X      = X
    	  TreeEx()\ScrollBar\Item()\Area\Y      = Y + dpiY(#ScrollBar_ButtonSize)
    	  TreeEx()\ScrollBar\Item()\Area\Width  = Width
    	  TreeEx()\ScrollBar\Item()\Area\Height = Height - dpiY(#ScrollBar_ButtonSize * 2) - dpiY(TreeEx()\ScrollBar\Adjust) + dpiY(1)
    	  ;}
        ;{ ----- Thumb -----
    	  TreeEx()\ScrollBar\Item()\Thumb\X      = X
    	  TreeEx()\ScrollBar\Item()\Thumb\Y      = TreeEx()\ScrollBar\Item()\Area\Y + Offset + dpiY(1)
    	  TreeEx()\ScrollBar\Item()\Thumb\Width  = Width
    	  TreeEx()\ScrollBar\Item()\Thumb\Height = TreeEx()\ScrollBar\Item()\Thumb\Size
    	  If TreeEx()\ScrollBar\Flags & #ScrollBar_ButtonBorder
    	    TreeEx()\ScrollBar\Item()\Thumb\Y + dpiY(1)
    	    TreeEx()\ScrollBar\Item()\Thumb\Height - dpiY(2)
    	  EndIf ;}
    	  
    	Else
    	  
  		  ;{ ----- Buttons -----
  		  TreeEx()\ScrollBar\Item()\Buttons\Forwards\X       = X + Width - dpiX(#ScrollBar_ButtonSize) - dpiX(TreeEx()\ScrollBar\Adjust)
    		TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y       = Y
    		TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width   = dpiX(#ScrollBar_ButtonSize)
    		TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height  = Height
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\X      = X
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y      = Y
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width  = dpiX(#ScrollBar_ButtonSize)
    		TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height = Height
    		;}
    		;{ ----- ScrollArea -----
    		TreeEx()\ScrollBar\Item()\Area\X = X + dpiX(#ScrollBar_ButtonSize)
    	  TreeEx()\ScrollBar\Item()\Area\Y = Y
    	  TreeEx()\ScrollBar\Item()\Area\Width  = Width - dpiX(#ScrollBar_ButtonSize * 2) - dpiY(TreeEx()\ScrollBar\Adjust)
    	  TreeEx()\ScrollBar\Item()\Area\Height = Height
    	  ;}
    	  ;{ ----- Thumb -----
    	  TreeEx()\ScrollBar\Item()\Thumb\X      = TreeEx()\ScrollBar\Item()\Area\X + Offset + dpiX(1)
    	  TreeEx()\ScrollBar\Item()\Thumb\Y      = Y
    	  TreeEx()\ScrollBar\Item()\Thumb\Width  = TreeEx()\ScrollBar\Item()\Thumb\Size
    	  TreeEx()\ScrollBar\Item()\Thumb\Height = Height
    	  If TreeEx()\ScrollBar\Flags & #ScrollBar_ButtonBorder
    	    TreeEx()\ScrollBar\Item()\Thumb\X + dpiX(1)
    	    TreeEx()\ScrollBar\Item()\Thumb\Width - dpiX(2)
    	  EndIf ;}	
  	  
		  EndIf

  		If StartDrawing(CanvasOutput(TreeEx()\CanvasNum))
  		  
  		  ;{ _____ Color _____
  		  FrontColor  = TreeEx()\ScrollBar\Color\Front
  		  BackColor   = TreeEx()\ScrollBar\Color\Back
  		  BorderColor = TreeEx()\ScrollBar\Color\Border
  		  
  		  If TreeEx()\ScrollBar\Item()\Disable
  		    FrontColor  = TreeEx()\ScrollBar\Color\DisableFront
  		    BackColor   = TreeEx()\ScrollBar\Color\DisableBack
  		    BorderColor = TreeEx()\ScrollBar\Color\DisableFront
  		  EndIf
  		  ;}
  		  
  		  DrawingMode(#PB_2DDrawing_Default)
  		  
  		  ;{ _____ Background _____
  		  Box(TreeEx()\ScrollBar\Item()\Area\X, TreeEx()\ScrollBar\Item()\Area\Y, TreeEx()\ScrollBar\Item()\Area\Width, TreeEx()\ScrollBar\Item()\Area\Height, TreeEx()\ScrollBar\Color\Back)
  			;}
  			
  		  ;{ _____ Draw Thumb _____
  		  Select TreeEx()\ScrollBar\Item()\Thumb\State
  			  Case #ScrollBar_Focus
  			    Box(TreeEx()\ScrollBar\Item()\Thumb\X, TreeEx()\ScrollBar\Item()\Thumb\Y, TreeEx()\ScrollBar\Item()\Thumb\Width, TreeEx()\ScrollBar\Item()\Thumb\Height, BlendColor_(TreeEx()\ScrollBar\Color\Focus, TreeEx()\ScrollBar\Color\ScrollBar, 10))
  			  Case #ScrollBar_Click
  			    Box(TreeEx()\ScrollBar\Item()\Thumb\X, TreeEx()\ScrollBar\Item()\Thumb\Y, TreeEx()\ScrollBar\Item()\Thumb\Width, TreeEx()\ScrollBar\Item()\Thumb\Height, BlendColor_(TreeEx()\ScrollBar\Color\Focus, TreeEx()\ScrollBar\Color\ScrollBar, 20))
  			  Default
  			    Box(TreeEx()\ScrollBar\Item()\Thumb\X, TreeEx()\ScrollBar\Item()\Thumb\Y, TreeEx()\ScrollBar\Item()\Thumb\Width, TreeEx()\ScrollBar\Item()\Thumb\Height, TreeEx()\ScrollBar\Color\ScrollBar)
  			EndSelect
  			
  		  If TreeEx()\ScrollBar\Flags & #ScrollBar_DragLines   ;{ Drag Lines
  		    
  		    If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  		      
    			  If TreeEx()\ScrollBar\Item()\Thumb\Size > dpiY(10)
    		      OffsetY = (TreeEx()\ScrollBar\Item()\Thumb\Size - dpiY(7)) / 2			      
    		      Line(TreeEx()\ScrollBar\Item()\Thumb\X + dpiX(4), TreeEx()\ScrollBar\Item()\Thumb\Y + OffsetY, TreeEx()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), TreeEx()\ScrollBar\Color\Front)
    		      Line(TreeEx()\ScrollBar\Item()\Thumb\X + dpiX(4), TreeEx()\ScrollBar\Item()\Thumb\Y + OffsetY + dpiY(3), TreeEx()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), TreeEx()\ScrollBar\Color\Front)
    		      Line(TreeEx()\ScrollBar\Item()\Thumb\X + dpiX(4), TreeEx()\ScrollBar\Item()\Thumb\Y + OffsetY + dpiY(6), TreeEx()\ScrollBar\Item()\Thumb\Width - dpiX(8), dpiY(1), TreeEx()\ScrollBar\Color\Front)
    		    EndIf
    		    
    		  Else
  
    			  If TreeEx()\ScrollBar\Item()\Thumb\Size > dpiX(10)
      		    OffsetX = (TreeEx()\ScrollBar\Item()\Thumb\Size - dpiX(7)) / 2
      		    Line(TreeEx()\ScrollBar\Item()\Thumb\X + OffsetX, TreeEx()\ScrollBar\Item()\Thumb\Y + dpiX(4), dpiX(1), TreeEx()\ScrollBar\Item()\Thumb\Height - dpiY(8), TreeEx()\ScrollBar\Color\Front)
  			      Line(TreeEx()\ScrollBar\Item()\Thumb\X + OffsetX + dpiX(3), TreeEx()\ScrollBar\Item()\Thumb\Y + dpiX(4), dpiX(1), TreeEx()\ScrollBar\Item()\Thumb\Height - dpiY(8), TreeEx()\ScrollBar\Color\Front)
  			      Line(TreeEx()\ScrollBar\Item()\Thumb\X + OffsetX + dpiX(6), TreeEx()\ScrollBar\Item()\Thumb\Y + dpiX(4), dpiX(1), TreeEx()\ScrollBar\Item()\Thumb\Height - dpiY(8), TreeEx()\ScrollBar\Color\Front)
  			    EndIf
  			    
  			  EndIf
  			  ;}
  			EndIf
  			
  			If TreeEx()\ScrollBar\Flags & #ScrollBar_ThumbBorder ;{ Thumb Border
  			  DrawingMode(#PB_2DDrawing_Outlined)
  			  Box(TreeEx()\ScrollBar\Item()\Thumb\X, TreeEx()\ScrollBar\Item()\Thumb\Y, TreeEx()\ScrollBar\Item()\Thumb\Width, TreeEx()\ScrollBar\Item()\Thumb\Height, TreeEx()\ScrollBar\Color\Border)
  			  ;}
  			EndIf
  			;}
  			
  			If TreeEx()\ScrollBar\Adjust
  			  Box(dpiX(GadgetWidth(TreeEx()\CanvasNum)) - dpiX(#ScrollBar_ButtonSize) - dpiX(1), dpiY(GadgetHeight(TreeEx()\CanvasNum)) - dpiY(#ScrollBar_ButtonSize) - dpiY(1), dpiX(#ScrollBar_ButtonSize), dpiY(#ScrollBar_ButtonSize), TreeEx()\ScrollBar\Color\Gadget)
  			EndIf 
  			
  			;{ _____ Border ____
  			If TreeEx()\ScrollBar\Flags & #ScrollBar_Border
  			  DrawingMode(#PB_2DDrawing_Outlined)
  			  Box(X, Y, Width, Height, BorderColor)
  			  If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  			    Line(X, Height - dpiY(TreeEx()\ScrollBar\Adjust), Width, 1, BorderColor)
  			  Else
  			    Line(Width - dpiX(TreeEx()\ScrollBar\Adjust), Y, 1, Height, BorderColor)
  			  EndIf   
  			EndIf ;}
  
  			StopDrawing()
  		EndIf
  		
  		If ThumbOnly = #False
      	DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height,  ScrollBar, #ScrollBar_Forwards,  TreeEx()\ScrollBar\Item()\Buttons\Forwards\State)
      	DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, TreeEx()\ScrollBar\Item()\Buttons\Backwards\State)
      EndIf
    
    EndIf
    
	EndProcedure  
  
  
  CompilerIf #Enable_ProgressBar
    
    Procedure   DrawProgressBar_(X.f, Y.f, Width.f, Height.f, State.i, Text.s, Flags.i, FontID.i)
      Define.f Factor, pbWidth, pbHeight, txtX, txtY
      Define.i BorderColor, Progress, Percent, TextColor
      
      If State < TreeEx()\ProgressBar\Minimum : State = TreeEx()\ProgressBar\Minimum : EndIf
      If State > TreeEx()\ProgressBar\Maximum : State = TreeEx()\ProgressBar\Maximum : EndIf
      
      X + dpiX(3)
      Y + dpiX(3)
      
      pbWidth  = Width  - dpiX(6)
      pbHeight = Height - dpiY(6)

      DrawingMode(#PB_2DDrawing_Default)
      If TreeEx()\Color\ProgressBack <> #PB_Default
        Box(X, Y, pbWidth, pbHeight, TreeEx()\Color\ProgressBack)
      Else  
        Box(X, Y, pbWidth, pbHeight, BlendColor_(TreeEx()\Color\ProgressFront, TreeEx()\Color\Back, 20))
      EndIf   
      
      If State > TreeEx()\ProgressBar\Minimum
        
        If State = TreeEx()\ProgressBar\Maximum
          Progress = pbWidth
        Else
          Factor   = pbWidth / (TreeEx()\ProgressBar\Maximum - TreeEx()\ProgressBar\Minimum)
          Progress = (State - TreeEx()\ProgressBar\Minimum) * Factor
        EndIf
        
        DrawingMode(#PB_2DDrawing_Gradient)
        FrontColor(TreeEx()\Color\ProgressFront)
        BackColor(TreeEx()\Color\ProgressGradient)
        LinearGradient(X, Y, X + Progress, Y + pbHeight)
        Box(X, Y, Progress, pbHeight)
  
      EndIf
      
      Percent = ((State - TreeEx()\ProgressBar\Minimum) * 100) /  (TreeEx()\ProgressBar\Maximum - TreeEx()\ProgressBar\Minimum)
      
      TextColor = TreeEx()\Color\ProgressText
      If TreeEx()\Cols()\Color\Front <> #PB_Default
        TextColor = TreeEx()\Cols()\Color\Front
      EndIf
      
      If Text ;{ Draw Text

        DrawingFont(FontID)
        
        Text = ReplaceString(Text, #Progress$, Str(Percent) + "%")
        
        If Flags & #Center
          txtX = (Width - TextWidth(Text)) / 2
        ElseIf Flags & #Right
          txtX = Width - TextWidth(Text) - dpiX(4)
        Else
          txtX = dpiX(4)
        EndIf  
        
        txtY = (pbHeight - TextHeight(Text)) / 2
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(X + txtX, Y + txtY, Text, TextColor)
        
      ElseIf Flags & #ShowPercent
        
        DrawingFont(FontID)
        
        Text  = Str(Percent) + "%"
        txtX = Progress - TextWidth(Text) - dpiX(2)
        txtY = (pbHeight - TextHeight(Text)) / 2
        
        If txtX < dpiX(5) : txtX = dpiX(5) : EndIf
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(X + txtX, Y + txtY, Text, TextColor)
        ;}
      EndIf
      
      If TreeEx()\Cols()\Color\Border <> #PB_Default
        BorderColor = TreeEx()\Cols()\Color\Border
      Else  
        BorderColor = TreeEx()\Color\ProgressBorder
      EndIf  
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X, Y, pbWidth, pbHeight, BorderColor)
      
    EndProcedure
    
  CompilerEndIf	

	Procedure   DrawCheckBox(X.i, Y.i, Height.i, boxSize.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor, LineColor
    
    If boxSize <= Height
      
      Y + ((Height - boxSize) / 2)
      
      LineColor = BlendColor_(TreeEx()\Color\Front, BackColor, 60)
      
      If State & #Checked

        bColor = BlendColor_(LineColor, TreeEx()\Color\ButtonBack)
        
        X1 = X + 1
        X2 = X + boxSize - 2
        Y1 = Y + 1
        Y2 = Y + boxSize - 2
        
        LineXY(X1 + 1, Y1, X2 + 1, Y2, bColor)
        LineXY(X1 - 1, Y1, X2 - 1, Y2, bColor)
        LineXY(X2 + 1, Y1, X1 + 1, Y2, bColor)
        LineXY(X2 - 1, Y1, X1 - 1, Y2, bColor)
        LineXY(X2, Y1, X1, Y2, LineColor)
        LineXY(X1, Y1, X2, Y2, LineColor)
        
      ElseIf State & #Inbetween
        
        Box(X, Y, boxSize, boxSize, BlendColor_(LineColor, BackColor, 50))
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X + 2, Y + 2, boxSize - 4, boxSize - 4, BlendColor_(LineColor, BackColor, 5))
      Box(X + 1, Y + 1, boxSize - 2, boxSize - 2, BlendColor_(LineColor, BackColor, 25))
      Box(X, Y, boxSize, boxSize, LineColor)
      
      TreeEx()\Rows()\CheckBox\X    = X
      TreeEx()\Rows()\CheckBox\Y    = Y
      TreeEx()\Rows()\CheckBox\Size = boxSize
      
    EndIf
    
  EndProcedure

	Procedure   DrawButton_(X.i, Y.i, State.i=#False)
	  Define.i Width, Height
	  
	  Width  = dpiX(#ButtonSize)
	  Height = dpiY(#ButtonSize)

	  DrawingMode(#PB_2DDrawing_Default)
	  RoundBox(X, Y, Width, Height, dpiX(2), dpiY(2), TreeEx()\Color\ButtonBack)
	  
	  DrawingMode(#PB_2DDrawing_Outlined)
	  RoundBox(X, Y, Width, Height, dpiX(2), dpiY(2), TreeEx()\Color\ButtonBorder)
	  
	  If State
	    Line(X + dpiY(2), Y + dpiY(4), dpiX(#ButtonSize - 4), 1, TreeEx()\Color\ButtonFront) 
	  Else
	    Line(X + dpiX(2), Y + dpiY(4), dpiX(#ButtonSize - 4), 1, TreeEx()\Color\ButtonFront) 
	    Line(X + dpiY(4), Y + dpiX(2), 1, dpiX(#ButtonSize - 4), TreeEx()\Color\ButtonFront)
	  EndIf  

	EndProcedure  

	Procedure   Draw_(ThumbOnly.i=#False)
	  Define.f X, Y, Width, Height, TreeWidth, ColumnWidth, txtHeight, RowHeight, ImageWidth, ImageHeight
	  Define.f btY, txtX, txtY, OffsetX, OffsetY, LastX, LastY, LineY, LineHeight, LineWidth
	  Define.i Row, PageRows, FrontColor, BackColor, CheckBoxSize, FontID, Visible, Button
	  Define.i l, LevelWidth, NextLevel, LevelX, Level = 0
	  Define.f Factor
		Define.s Key$, Level$, Text$

		NewMap  LineX.i()
		NewMap  LineY.i()

		If TreeEx()\Hide : ProcedureReturn #False : EndIf

    TreeEx()\Row\OffSetY = 0
		
		Width  = dpiX(GadgetWidth(TreeEx()\CanvasNum))
		Height = dpiY(GadgetHeight(TreeEx()\CanvasNum))
		
		LineY = 0
		LineHeight = Height 
		
		If StartDrawing(CanvasOutput(TreeEx()\CanvasNum))
		  
		  PageRows = GetPageRows_()
		  
		  ;{ ScrollBar
		  If TreeEx()\ScrollBar\Item("HScroll")\Hide = #False

		    If TreeEx()\ScrollBar\Flags = #False
  		    TreeEx()\ScrollBar\Item("HScroll")\X      = dpiX(1)
  		    TreeEx()\ScrollBar\Item("HScroll")\Y      = Height - dpiY(#ScrollBarSize) - dpiY(1)
  		    TreeEx()\ScrollBar\Item("HScroll")\Width  = Width - dpiX(2)
  		    TreeEx()\ScrollBar\Item("HScroll")\Height = dpiY(#ScrollBarSize)
  		  Else
  		    TreeEx()\ScrollBar\Item("HScroll")\X      = 0
  		    TreeEx()\ScrollBar\Item("HScroll")\Y      = Height - dpiY(#ScrollBarSize)
  		    TreeEx()\ScrollBar\Item("HScroll")\Width  = Width
  		    TreeEx()\ScrollBar\Item("HScroll")\Height = dpiY(#ScrollBarSize)
  		  EndIf
  		  
  		  CalcScrollBarThumb_("HScroll", #False)
		  EndIf
		  
		  If TreeEx()\ScrollBar\Item("VScroll")\Hide = #False

		    If TreeEx()\ScrollBar\Flags = #False
  		    TreeEx()\ScrollBar\Item("VScroll")\X      = Width - dpiX(#ScrollBarSize) - dpiX(1)
  		    TreeEx()\ScrollBar\Item("VScroll")\Y      = dpiY(1)
  		    TreeEx()\ScrollBar\Item("VScroll")\Width  = dpiX(#ScrollBarSize)
  		    TreeEx()\ScrollBar\Item("VScroll")\Height = Height - dpiY(2)
  		  Else
  		    TreeEx()\ScrollBar\Item("VScroll")\X      = Width - dpiX(#ScrollBarSize)
  		    TreeEx()\ScrollBar\Item("VScroll")\Y      = 0
  		    TreeEx()\ScrollBar\Item("VScroll")\Width  = dpiX(#ScrollBarSize)
  		    TreeEx()\ScrollBar\Item("VScroll")\Height = Height
		    EndIf
		    
		    CalcScrollBarThumb_("VScroll", #False)
		  EndIf ;}
		  
		  If TreeEx()\ScrollBar\Item("VScroll")\Hide = #False : Width  - dpiX(#ScrollBarSize) : EndIf 
		  If TreeEx()\ScrollBar\Item("HScroll")\Hide = #False : Height - dpiY(#ScrollBarSize) : EndIf 
		  
		  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
		    ClipOutput(0, 0, Width, Height) 
      CompilerEndIf
		  
			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			Box(0, 0, Width, Height, TreeEx()\Color\Back) ; 
			;}
			
			FontID    = TreeEx()\FontID
			TreeWidth = TreeColumnWidth()

			;{ _____ Header _____
			If TreeEx()\Flags & #ShowHeader
			  Y = dpiY(TreeEx()\Row\Header\Height) 
			Else
			  Y = dpiY(2)
			EndIf ;}

		  RowHeight  = dpiY(TreeEx()\Row\Height)
		  LevelWidth = dpiX(#ButtonSize) + dpiX(5)
		  txtHeight  = TextHeight("Abc")
		  
		  OffsetY = TreeEx()\Row\Offset * RowHeight
		  
		  Y - OffsetY + dpiY(2)
		  
			txtY = (RowHeight - txtHeight) / 2
			
			CheckBoxSize = txtHeight - dpiX(2)
			
			;{ _____ Draw Rows _____	
			Visible = 0
			
			;{ --- Reset Buttons ---
			ForEach TreeEx()\Rows()
			  TreeEx()\Rows()\Button\X = #PB_Default
			  TreeEx()\Rows()\Button\Y = #PB_Default
			Next ;}
			
			ForEach TreeEx()\Rows()

			  X = -dpiX(TreeEx()\Col\OffsetX)
			  
        TreeEx()\Rows()\Y = 0
			  TreeEx()\Rows()\Visible = #False
			  
			  BackColor = TreeEx()\Color\Back
			  
			  If TreeEx()\Rows()\Level < Level : Level = TreeEx()\Rows()\Level : EndIf

			  If TreeEx()\Rows()\Level = Level And TreeEx()\Rows()\Button\State
			    Level = TreeEx()\Rows()\Level + 1
			  EndIf
			  
			  If TreeEx()\Rows()\Level > Level
			    TreeEx()\Rows()\Button\State = #False
			    Continue
			  EndIf

			  TreeEx()\Rows()\Visible = #True

			  ForEach TreeEx()\Cols() ;{ Columns
			    
			    Key$ = TreeEx()\Cols()\Key
			    
			    TreeEx()\Cols()\X = X
			    
			    If TreeEx()\Cols()\FontID
			      FontID = TreeEx()\Cols()\FontID
			    Else
			     	FontID = TreeEx()\FontID
			    EndIf
			    DrawingFont(FontID)
			    
			    If TreeEx()\Cols()\Color\Front
			      FrontColor = TreeEx()\Cols()\Color\Front
			    Else  
			      FrontColor = TreeEx()\Color\Front
			    EndIf  

			    ColumnWidth = dpiX(TreeEx()\Cols()\Width)
			    
			    If ListIndex(TreeEx()\Cols()) = #TreeColumn ;{ Tree column
			      
			      txtX = dpiX(#ButtonSize + 5)
			      txtY = (RowHeight - TextHeight("X")) / 2
			      btY  = (RowHeight - dpiY(#ButtonSize)) / 2
			      
			      If TreeEx()\Cols()\Width = #PB_Default : ColumnWidth = dpiX(TreeWidth) : EndIf
			      
			      If TreeEx()\Flags & #FitTreeColumn Or ColumnWidth < dpiX(TreeEx()\Col\TreeWidth)
			        ColumnWidth = dpiX(TreeEx()\Col\TreeWidth)
			      EndIf 
			      
    			  ;{ --- Level of the next line ---
    			  PushListPosition(TreeEx()\Rows())
    			  If NextElement(TreeEx()\Rows())
    			    NextLevel = TreeEx()\Rows()\Level
    			  Else
    			    NextLevel = -1
    			  EndIf  
    			  PopListPosition(TreeEx()\Rows())
    			  ;}
    			  
    			  OffsetX = LevelWidth * TreeEx()\Rows()\Level + dpiX(6)
			  
    			  If NextLevel = TreeEx()\Rows()\Level + 1
    			    TreeEx()\Rows()\Button\X = X + OffsetX
    		      TreeEx()\Rows()\Button\Y = Y + btY
    		    EndIf 
    		    
    		    TreeEx()\Rows()\Text\X = X + txtX + OffsetX
    		    
    			  ;{ ----- Column BackColor -----
  			    If TreeEx()\Cols()\Color\Back <> #PB_Default 
  			      DrawingMode(#PB_2DDrawing_Default)
  			      BackColor = TreeEx()\Cols()\Color\Back
  			      Box(X, 0, ColumnWidth, RowHeight, BackColor)
  			    EndIf ;}

    			  TreeEx()\Rows()\Text\X = X + txtX + OffsetX
    			  
    			  If TreeEx()\Flags & #CheckBoxes
    			    DrawCheckBox(TreeEx()\Rows()\Text\X, Y, RowHeight, CheckBoxSize, BackColor, TreeEx()\Rows()\State)
    			    TreeEx()\Rows()\Text\X + CheckBoxSize
    			  EndIf  
    			  
    			  If IsImage(TreeEx()\Rows()\Column(#Tree$)\Image\Num)
    			    
    			    ImageWidth  = TreeEx()\Rows()\Column(#Tree$)\Image\Width
		          ImageHeight = TreeEx()\Rows()\Column(#Tree$)\Image\Height
		          
		          If TreeEx()\Rows()\Column(#Tree$)\Image\Height > RowHeight - dpiY(2)
		            ImageHeight = RowHeight - dpiY(2)
		            Factor      = ImageHeight / TreeEx()\Rows()\Column(#Tree$)\Image\Height
		            ImageWidth  = ImageWidth * Factor
		          EndIf  
		          
		          OffsetY = (RowHeight - ImageHeight) / 2
		          
		          If IsImage(TreeEx()\Rows()\Column(#Tree$)\Image\Num)
		            DrawingMode(#PB_2DDrawing_AlphaBlend)
		            DrawImage(ImageID(TreeEx()\Rows()\Column(#Tree$)\Image\Num), TreeEx()\Rows()\Text\X + dpiX(3), Y + OffsetY, ImageWidth, ImageHeight)
		          EndIf  
		          
		          TreeEx()\Rows()\Text\X + ImageWidth
		        EndIf 
		        
		        TreeEx()\Rows()\Text\X + dpiX(5)
			      TreeEx()\Rows()\Text\Width = TextWidth(TreeEx()\Rows()\Column(#Tree$)\Value)
		        
		        ;{ ----- Focus -----
  			    If TreeEx()\Row\Focus = ListIndex(TreeEx()\Rows())
  			      
  			      DrawingMode(#PB_2DDrawing_Default)
  			      
  			      BackColor = BlendColor_(TreeEx()\Color\FocusBack, TreeEx()\Color\Back, 12)

  			      If TreeEx()\Flags & #SelectRow
  			        Box(TreeEx()\Rows()\Text\X - dpiX(2), Y + dpiX(2), ColumnWidth - TreeEx()\Rows()\Text\X - dpiX(2), RowHeight - dpiX(4), BackColor)
  			      Else
  			        Box(TreeEx()\Rows()\Text\X - dpiX(2), Y + dpiX(2), TreeEx()\Rows()\Text\Width + dpiX(4), RowHeight - dpiX(4), BackColor)
  			      EndIf  
  			      
    			  EndIf ;}

    			  DrawingMode(#PB_2DDrawing_Transparent)
    			  If TreeEx()\Cols()\Color\Front <> #PB_Default
    			    DrawText(TreeEx()\Rows()\Text\X, Y + txtY, TreeEx()\Rows()\Column(#Tree$)\Value, TreeEx()\Cols()\Color\Front)
    			  Else  
    			    DrawText(TreeEx()\Rows()\Text\X, Y + txtY, TreeEx()\Rows()\Column(#Tree$)\Value, TreeEx()\Color\Front)
    			  EndIf
			      ;}
			    Else                                        ;{ Additional columns
			      
  			    ;{ ----- Column BackColor -----
  			    If TreeEx()\Cols()\Color\Back <> #PB_Default 
  			      DrawingMode(#PB_2DDrawing_Default)
  			      Box(X, Y, ColumnWidth, RowHeight, TreeEx()\Cols()\Color\Back)
  			    EndIf ;}			      
  			    
  			    ;{ ----- Focus -----
  			    If TreeEx()\Row\Focus = ListIndex(TreeEx()\Rows())
  			      DrawingMode(#PB_2DDrawing_Default)
  			      BackColor = BlendColor_(TreeEx()\Color\FocusBack, TreeEx()\Color\Back, 12)
  			      If TreeEx()\Flags & #SelectRow
  			        Box(X, Y + dpiX(2), ColumnWidth, RowHeight - dpiX(4), BackColor)
  			      EndIf  
    			  EndIf ;}
    			  
			      If TreeEx()\Cols()\Flags & #ProgressBar ;{ #ProgressBar
		
		          CompilerIf #Enable_ProgressBar
		            
		            DrawProgressBar_(X, Y, ColumnWidth, RowHeight, TreeEx()\Rows()\Column(Key$)\State, TreeEx()\Rows()\Column(Key$)\Value, TreeEx()\Cols()\Flags, FontID)
		            
		          CompilerEndIf
			        ;}  
		        ElseIf TreeEx()\Cols()\Flags & #Image   ;{ #Image
		        
		          ImageWidth  = TreeEx()\Rows()\Column(Key$)\Image\Width
		          ImageHeight = TreeEx()\Rows()\Column(Key$)\Image\Height
		          
		          If TreeEx()\Rows()\Column(Key$)\Image\Height > RowHeight - dpiY(2)
		            ImageHeight = RowHeight - dpiY(2)
		            Factor      = ImageHeight / TreeEx()\Rows()\Column(Key$)\Image\Height
		            ImageWidth  = ImageWidth * Factor
		          EndIf  
		          
		          If TreeEx()\Rows()\Column(Key$)\Image\Flags & #Center
		            OffsetX = (ColumnWidth - ImageWidth) / 2
		          ElseIf TreeEx()\Rows()\Column(Key$)\Image\Flags & #Right
		            OffsetX = ColumnWidth - ImageWidth - dpiX(2)
		          Else  
		            OffsetX = dpiX(2)
		          EndIf 
		          
		          OffsetY = (RowHeight - ImageHeight) / 2

		          If IsImage(TreeEx()\Rows()\Column(Key$)\Image\Num)
		            
		            DrawingMode(#PB_2DDrawing_AlphaBlend)
		            DrawImage(ImageID(TreeEx()\Rows()\Column(Key$)\Image\Num), X + OffsetX, Y + OffsetY, ImageWidth, ImageHeight)
		          EndIf  
		          ;}
		        Else                                    ;{ Text

  			      Text$ = TreeEx()\Rows()\Column(Key$)\Value
  			      
  			      ;{ ----- Text Align -----
    			    If TreeEx()\Cols()\Flags & #Center
    			      txtX = (ColumnWidth - TextWidth(Text$)) / 2
    			    ElseIf TreeEx()\Cols()\Flags & #Right
    			      txtX = ColumnWidth - TextWidth(Text$) - dpiX(5)
    			    Else
    			      txtX = dpiX(5)
    			    EndIf ;}
    			    
    			    txtY = (RowHeight - TextHeight(Text$)) / 2

    			    DrawingMode(#PB_2DDrawing_Transparent)
    			    If TreeEx()\Cols()\Color\Front <> #PB_Default
    			      DrawText(X + txtX, Y + txtY, Text$, TreeEx()\Cols()\Color\Front)	
    			    Else
    			      DrawText(X + txtX, Y + txtY, Text$, TreeEx()\Color\Front)	
    			    EndIf
    			    ;}
    			  EndIf      			  
			      ;}
          EndIf 

          X + ColumnWidth
			  Next ;}

  			TreeEx()\Rows()\Y = Y
  			
  			Y + dpiY(TreeEx()\Row\Height)
  			
  			If Y > Height : Break : EndIf
  			
  		Next ;}
  		
  		;{ _____ Lines _____
  		If Not TreeEx()\Flags & #NoLines
  		  
  		  FrontColor(TreeEx()\Color\Line)

  		  LineWidth = dpiX(#ButtonSize - 1) ; Round( / 2, #PB_Round_Up)
  		  
    		ForEach TreeEx()\Lines()

    		  If TreeEx()\Lines()\Button 
    		    
    		    Button = #True
    		    
    		    If Level < TreeEx()\Lines()\Level
    		      Level$ = Str(Level)
    		      If LineY(Level$)
    		        Line(LineX(Level$), LineY(Level$), 1, TreeEx()\Lines()\Y - LineY(Level$))
    		        Line(LineX(Level$), TreeEx()\Lines()\Y, TreeEx()\Lines()\X - LineX(Level$), 1)
    		      EndIf
    		    EndIf

    		    Level$ = Str(TreeEx()\Lines()\Level)
    		    
    		    If LineY(Level$) : Line(TreeEx()\Lines()\X, LineY(Level$), 1, TreeEx()\Lines()\Y - LineY(Level$)) : EndIf  
    		    
    		    LineX(Level$) = TreeEx()\Lines()\X
    		    
    		    PushListPosition(TreeEx()\Lines())
    		  
      		  If NextElement(TreeEx()\Lines())
      		    NextLevel = TreeEx()\Lines()\Level
      		  Else
      		    NextLevel = -1
      		  EndIf
      		  
      		  PopListPosition(TreeEx()\Lines())

      		  If NextLevel <> -1 And  NextLevel < TreeEx()\Lines()\Level
      		    For l = NextLevel + 1 To Level
      		      LineY(Str(l)) = 0
      		    Next  
      		    Level = NextLevel
    		    Else  
    		      LineY(Level$) = TreeEx()\Lines()\Y
    		      Level = TreeEx()\Lines()\Level
    		    EndIf  
    		    
    		  Else
    		    
    		    Level$ = Str(TreeEx()\Lines()\Level)
    		    If LineY(Level$) : Line(TreeEx()\Lines()\X, LineY(Level$), 1, TreeEx()\Lines()\Y - LineY(Level$)) : EndIf  
    		    LineX(Level$) = TreeEx()\Lines()\X
    		    
    		    If TreeEx()\Lines()\NextLevel <> -1 And TreeEx()\Lines()\NextLevel < TreeEx()\Lines()\Level ; Line ends without button
    		      Level$ = Str(Level)
      		    If LineY(Level$) : Line(LineX(Level$), LineY(Level$), 1, TreeEx()\Lines()\Y - LineY(Level$)) : EndIf
      		    Line(LineX(Level$), TreeEx()\Lines()\Y, TreeEx()\Lines()\X - LineX(Level$) + LineWidth, 1)
      		    If TreeEx()\Lines()\NextLevel >= 0
        		    For l = TreeEx()\Lines()\NextLevel + 1 To Level
        		      LineY(Str(l)) = 0
        		    Next  
        		    Level = TreeEx()\Lines()\NextLevel
        		  EndIf  
        		ElseIf TreeEx()\Lines()\Level > Level
      		    Level$ = Str(Level)
    		      Line(LineX(Level$), TreeEx()\Lines()\Y, TreeEx()\Lines()\X - LineX(Level$) + LineWidth, 1)
    		    ElseIf Button  
      		    Level$ = Str(TreeEx()\Lines()\Level)
      		    Line(LineX(Level$), TreeEx()\Lines()\Y, TreeEx()\Lines()\X - LineX(Level$) + LineWidth, 1)
      		  ElseIf TreeEx()\Lines()\Level = 0 
      		    LineY("0") = TreeEx()\Lines()\Y
      		    Line(LineX("0"), TreeEx()\Lines()\Y, LineWidth, 1)
    		    EndIf
    		    
    		  EndIf
    		  
    		Next  
  		
    		If LastElement(TreeEx()\Lines())
    		  If TreeEx()\Lines()\Level > Level
    		    Level$ = Str(Level)
    		    If LineY(Level$)
    		      If LineY(Level$) : Line(LineX(Level$), LineY(Level$), 1, TreeEx()\Lines()\Y - LineY(Level$)) : EndIf
    		    EndIf  
    	    EndIf
    	  EndIf
    	  
    	EndIf
    	
    	If TreeEx()\Flags & #ColumnLines
    	  ForEach TreeEx()\Cols()
    	    Line(TreeEx()\Cols()\X, LineY, 1, LineHeight, TreeEx()\Color\HeaderBorder)
    	  Next 
    	  Line(TreeEx()\Cols()\X + dpiX(TreeEx()\Cols()\Width), LineY, 1, LineHeight, TreeEx()\Color\HeaderBorder)
	    EndIf
    	;}
  	  
  	  ;{ _____ Buttons _____
  	  If Not TreeEx()\Flags & #NoButtons
    	  ForEach TreeEx()\Rows()
    	    If TreeEx()\Rows()\Button\X <> #PB_Default And TreeEx()\Rows()\Button\Y <> #PB_Default
    	      DrawButton_(TreeEx()\Rows()\Button\X, TreeEx()\Rows()\Button\Y, TreeEx()\Rows()\Button\State)
    	    EndIf  
    	  Next
  	  EndIf ;}
  	  
  	  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput()
      CompilerEndIf
  	  
  	  ;{ _____ Header _____
  	  If TreeEx()\Flags & #ShowHeader
  	    
  	    X = -dpiX(TreeEx()\Col\OffsetX)
  	    Y = 0
  	    
			  RowHeight = dpiY(TreeEx()\Row\Header\Height)
			  
			  LineY = RowHeight
			  LineHeight - RowHeight
			  
			  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
			    ClipOutput(0, 0, Width, Height) 
        CompilerEndIf
			  
			  DrawingMode(#PB_2DDrawing_Default)
			  Box(0, 0, dpiX(Width), RowHeight, TreeEx()\Color\HeaderBack)
			  
			  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
          UnclipOutput()
        CompilerEndIf
			  
			  ForEach TreeEx()\Cols()
			    
			    If IsFont(TreeEx()\Cols()\Header\FontID)
			      FontID = TreeEx()\Cols()\Header\FontID
			    Else
			     	FontID = TreeEx()\FontID
			    EndIf
			    DrawingFont(FontID)
			    
			    If TreeEx()\Cols()\Width = #PB_Default
			      ColumnWidth = dpiX(TreeWidth)
			    Else
			      ColumnWidth = dpiX(TreeEx()\Cols()\Width)
			    EndIf  
			    
			    If ListIndex(TreeEx()\Cols()) = #TreeColumn
			      If TreeEx()\Flags & #FitTreeColumn Or ColumnWidth < dpiX(TreeEx()\Col\TreeWidth)
			        ColumnWidth = dpiX(TreeEx()\Col\TreeWidth)
			      EndIf  
			    EndIf
			    
		      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
			      If X + ColumnWidth > Width  : ColumnWidth = Width  - X : EndIf
			      If Y + RowHeight   > Height : RowHeight   = Height - Y : EndIf
            ClipOutput(X, Y, ColumnWidth, RowHeight) 
          CompilerEndIf
			    
			    ;{ ----- Column BackColor -----
			    If TreeEx()\Cols()\Header\Color\Back <> #PB_Default 
			      DrawingMode(#PB_2DDrawing_Default)
			      Box(X, 0, ColumnWidth, RowHeight, TreeEx()\Cols()\Header\Color\Back)
			    EndIf ;}
			    
			    ;{ ----- Cell Border -----
			    DrawingMode(#PB_2DDrawing_Outlined) 
			    If ListIndex(TreeEx()\Cols()) < ListSize(TreeEx()\Cols()) - 1
			      Box(X, 0, ColumnWidth + 1, RowHeight, TreeEx()\Color\HeaderBorder)
			    Else
			      Box(X, 0, ColumnWidth, RowHeight, TreeEx()\Color\HeaderBorder)
			    EndIf   
			    TreeEx()\Cols()\X = X
          ;}
			    
			    If IsImage(TreeEx()\Cols()\Header\Image\Num) ;{ Image
			      
			      ImageWidth  = TreeEx()\Cols()\Header\Image\Width
	          ImageHeight = TreeEx()\Cols()\Header\Image\Height
	          
	          If TreeEx()\Cols()\Header\Image\Height > RowHeight - dpiY(2)
	            ImageHeight = RowHeight - dpiY(2)
	            Factor      = ImageHeight / TreeEx()\Cols()\Header\Image\Height
	            ImageWidth  = ImageWidth * Factor
	          EndIf  
	          
	          If TreeEx()\Cols()\Header\Image\Flags & #Center
	            OffsetX = (ColumnWidth - ImageWidth) / 2
	          ElseIf TreeEx()\Cols()\Header\Image\Flags & #Right
	            OffsetX = ColumnWidth - ImageWidth - dpiX(2)
	          Else  
	            OffsetX = dpiX(2)
	          EndIf 
	          
	          OffsetY = (RowHeight - ImageHeight) / 2
	          
	          If IsImage(TreeEx()\Cols()\Header\Image\Num)
	            DrawingMode(#PB_2DDrawing_AlphaBlend)
	            DrawImage(ImageID(TreeEx()\Cols()\Header\Image\Num), X + OffsetX, Y + OffsetY, ImageWidth, ImageHeight)
	          EndIf  
			      ;}
			    Else  

  			    ;{ ----- Text Align -----
			      If TreeEx()\Cols()\Header\Flags & #Center
			        
  			      txtX = (ColumnWidth - TextWidth(TreeEx()\Cols()\Header\Title)) / 2
  			    ElseIf TreeEx()\Cols()\Header\Flags & #Right
  			      txtX = ColumnWidth - TextWidth(TreeEx()\Cols()\Header\Title) -dpiX(5)
  			    Else
  			      txtX = dpiX(5)
  			    EndIf ;}

  			    ;{ ----- Draw Text -----
  			    txtY = (RowHeight - TextHeight(TreeEx()\Cols()\Header\Title)) / 2

  			    DrawingMode(#PB_2DDrawing_Transparent)
  			    If TreeEx()\Cols()\Header\Color\Front <> #PB_Default
  			      DrawText(X + txtX, Y + txtY, TreeEx()\Cols()\Header\Title, TreeEx()\Cols()\Header\Color\Front)
  			    Else
  			      DrawText(X + txtX, Y + txtY, TreeEx()\Cols()\Header\Title, TreeEx()\Color\HeaderFront)
  			    EndIf ;}

  			  EndIf
  			  
			    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
            UnclipOutput()
          CompilerEndIf
            
			    X + ColumnWidth
			  Next
			  
  	  EndIf ;}

			;{ _____ Border ____
			If Not TreeEx()\Flags & #Borderless
				DrawingMode(#PB_2DDrawing_Outlined)
				Box(0, 0, dpiX(GadgetWidth(TreeEx()\CanvasNum)), dpiY(GadgetHeight(TreeEx()\CanvasNum)), TreeEx()\Color\Border)
			EndIf ;}
			
			StopDrawing()
		EndIf
		
		If TreeEx()\ScrollBar\Item("HScroll")\Hide = #False : DrawScrollBar_("HScroll", ThumbOnly) : EndIf ; 
		If TreeEx()\ScrollBar\Item("VScroll")\Hide = #False : DrawScrollBar_("VScroll", ThumbOnly) : EndIf ; 
		
	EndProcedure
	
	Procedure   ReDraw_(ThumbOnly.i=#False)
	  
	  CalcRows() ; Height of all visible rows
	  CalcCols() ; Width  of all columns
	  
	  If AdjustScrollBars_()
	    CalcRows() ; Height of all visible rows
	    CalcCols() ; Width  of all columns
	  EndIf

	  Draw_(ThumbOnly)

	EndProcedure
	
	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Procedure _ThemeHandler()

      ForEach TreeEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          TreeEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        If ModuleEx::ThemeGUI\ScrollBar : TreeEx()\ScrollBar\Flags = ModuleEx::ThemeGUI\ScrollBar : EndIf 
        
        TreeEx()\Color\Front            = ModuleEx::ThemeGUI\FrontColor
				TreeEx()\Color\Back             = ModuleEx::ThemeGUI\BackColor
				TreeEx()\Color\Border           = ModuleEx::ThemeGUI\BorderColor
				TreeEx()\Color\Line             = ModuleEx::ThemeGUI\LineColor
				TreeEx()\Color\ScrollBar        = ModuleEx::ThemeGUI\ScrollbarColor
				TreeEx()\Color\Gadget           = ModuleEx::ThemeGUI\GadgetColor
				TreeEx()\Color\FocusFront       = ModuleEx::ThemeGUI\Focus\FrontColor
				TreeEx()\Color\FocusBack        = ModuleEx::ThemeGUI\Focus\BackColor
				TreeEx()\Color\ButtonFront      = ModuleEx::ThemeGUI\Button\FrontColor
				TreeEx()\Color\ButtonBack       = ModuleEx::ThemeGUI\Button\BackColor
				TreeEx()\Color\ButtonBorder     = ModuleEx::ThemeGUI\Button\BorderColor
				TreeEx()\Color\HeaderFront      = ModuleEx::ThemeGUI\Header\FrontColor
        TreeEx()\Color\HeaderBack       = ModuleEx::ThemeGUI\Header\BackColor
        TreeEx()\Color\HeaderBorder     = ModuleEx::ThemeGUI\Header\BorderColor
        TreeEx()\Color\ProgressText     = ModuleEx::ThemeGUI\Progress\TextColor 
        TreeEx()\Color\ProgressFront    = ModuleEx::ThemeGUI\Progress\FrontColor
        TreeEx()\Color\ProgressBack     = #PB_Default
        TreeEx()\Color\ProgressGradient = ModuleEx::ThemeGUI\Progress\GradientColor
        TreeEx()\Color\ProgressBorder   = ModuleEx::ThemeGUI\Progress\BorderColor
        
        TreeEx()\ScrollBar\Color\Front        = ModuleEx::ThemeGUI\FrontColor
  			TreeEx()\ScrollBar\Color\Back         = ModuleEx::ThemeGUI\BackColor
  			TreeEx()\ScrollBar\Color\Border       = ModuleEx::ThemeGUI\BorderColor
  			TreeEx()\ScrollBar\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
  			TreeEx()\ScrollBar\Color\Focus        = ModuleEx::ThemeGUI\FocusBack
        TreeEx()\ScrollBar\Color\Button       = ModuleEx::ThemeGUI\Button\BackColor
        TreeEx()\ScrollBar\Color\ScrollBar    = ModuleEx::ThemeGUI\ScrollbarColor
        
        ReDraw_()
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
    
    ForEach TreeEx()
      
      ForEach TreeEx()\ScrollBar\Item()
        
        If TreeEx()\ScrollBar\Item()\Timer
          
          If TreeEx()\ScrollBar\Item()\TimerDelay
            TreeEx()\ScrollBar\Item()\TimerDelay - 1
            Continue
          EndIf  
          
          Select TreeEx()\ScrollBar\Item()\Timer
            Case #ScrollBar_Up, #ScrollBar_Left
              TreeEx()\ScrollBar\Item()\Pos - 1
              If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
            Case #ScrollBar_Down, #ScrollBar_Right
              TreeEx()\ScrollBar\Item()\Pos + 1
              If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
          EndSelect
          
          Redraw_()
          
    		EndIf 
    		
      Next
      
    Next
    
  EndProcedure
  
  
  Procedure _KeyDownHandler()
    Define.i GNum = EventGadget()
    Define.i Key, Modifier, Focus
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
      Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)

      Select Key
        Case #PB_Shortcut_Up    ;{ Up
          
          If Not Modifier
            Focus = TreeEx()\Row\Focus - 1
            If Focus < 0 : Focus = 0 : EndIf
            
            If SelectElement(TreeEx()\Rows(), Focus)
              If Not TreeEx()\Rows()\Visible 
                While PreviousElement(TreeEx()\Rows())
                  If TreeEx()\Rows()\Visible 
                    Focus = ListIndex(TreeEx()\Rows())
                    Break
                  EndIf  
                Wend  
              EndIf  
            EndIf
            If Focus <> TreeEx()\Row\Focus
              TreeEx()\Row\Focus = Focus
              PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              SetRowFocus_()
              ReDraw_()
            EndIf 
            
          EndIf  
          ;}
        Case #PB_Shortcut_Down  ;{ Down
          
          If Not Modifier
            
            Focus = TreeEx()\Row\Focus + 1
            
            If Focus > TreeEx()\Row\LastVisible : Focus = TreeEx()\Row\LastVisible : EndIf
            
            If SelectElement(TreeEx()\Rows(), Focus)
              If Not TreeEx()\Rows()\Visible 
                While NextElement(TreeEx()\Rows())
                  If TreeEx()\Rows()\Visible 
                    Focus = ListIndex(TreeEx()\Rows())
                    Break
                  EndIf  
                Wend  
              EndIf  
            EndIf
            
            If Focus <> TreeEx()\Row\Focus
              TreeEx()\Row\Focus = Focus
              PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              SetRowFocus_()
              ReDraw_()
            EndIf 
          EndIf  
          ;}
        Case #PB_Shortcut_Left  ;{ Left
          
          If Not Modifier
            If SelectElement(TreeEx()\Rows(), TreeEx()\Row\Focus)
              If TreeEx()\Rows()\Button\X <> #PB_Default And TreeEx()\Rows()\Button\Y <> #PB_Default
                TreeEx()\Rows()\Button\State = #False
    	          TreeEx()\Rows()\State | #Collapsed
    	          TreeEx()\Rows()\State & ~#Expanded
                ReDraw_()
              EndIf  
            EndIf   
          EndIf  
          ;}
        Case #PB_Shortcut_Right ;{ Right
          
          If Not Modifier
            If SelectElement(TreeEx()\Rows(), TreeEx()\Row\Focus)
              If TreeEx()\Rows()\Button\X <> #PB_Default And TreeEx()\Rows()\Button\Y <> #PB_Default
                TreeEx()\Rows()\Button\State = #True
    	          TreeEx()\Rows()\State | #Expanded
    	          TreeEx()\Rows()\State & ~#Collapsed
    	          ReDraw_()
              EndIf  
            EndIf
          EndIf   
          ;}
        Case #PB_Shortcut_Home  ;{ Home / Pos1
          
          If Not Modifier
            Focus = 0
            
            If Focus <> TreeEx()\Row\Focus
              ExpandFocus_(Focus)
              TreeEx()\Row\Focus = Focus
              PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              SetRowFocus_()
              ReDraw_()
            EndIf 
          EndIf  
          ;}
        Case #PB_Shortcut_End   ;{ End
          
          If Not Modifier
            Focus = ListSize(TreeEx()\Rows()) - 1
            
            If Focus <> TreeEx()\Row\Focus
              ExpandFocus_(Focus)
              TreeEx()\Row\Focus = Focus
              PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
              SetRowFocus_()
              ReDraw_()
            EndIf 
          EndIf  
          ;}
      EndSelect
      
    EndIf
    
  EndProcedure

  Procedure _LeftButtonDownHandler()
    Define.s ScrollBar
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(TreeEx(), Str(GNum))

			X = GetGadgetAttribute(TreeEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(TreeEx()\CanvasNum, #PB_Canvas_MouseY)
			
			ForEach TreeEx()\ScrollBar\Item() ;{ ScrollBars
      
        If TreeEx()\ScrollBar\Item()\Hide : Continue : EndIf 
        
        TreeEx()\ScrollBar\Item()\Cursor = #PB_Default
        
        ScrollBar = MapKey(TreeEx()\ScrollBar\Item())
  
  			If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical
  			  
  			  If X >= TreeEx()\ScrollBar\Item()\X And X <= TreeEx()\ScrollBar\Item()\X + TreeEx()\ScrollBar\Item()\Width
  			    
    			  If Y >= TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y And Y <= TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y + TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height
    			    ;{ Backwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Click)
    			      TreeEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      TreeEx()\ScrollBar\Item()\Timer      = #ScrollBar_Up
    			      TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Click 
    			    EndIf ;}
    			  ElseIf Y >= TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y And Y <= TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y + TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height
    			    ;{ Forwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Click)
    			      TreeEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      TreeEx()\ScrollBar\Item()\Timer      = #ScrollBar_Down
    			      TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Click
    			    EndIf ;}
    			  ElseIf Y >= TreeEx()\ScrollBar\Item()\Thumb\Y And Y <= TreeEx()\ScrollBar\Item()\Thumb\Y + TreeEx()\ScrollBar\Item()\Thumb\Height
    			    ;{ Thumb Button
    			    If TreeEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Click
    			      TreeEx()\ScrollBar\Item()\Thumb\State  = #ScrollBar_Click
    			      TreeEx()\ScrollBar\Item()\Thumb\Offset = TreeEx()\ScrollBar\Item()\Thumb\Y - Y
    			      TreeEx()\ScrollBar\Item()\Cursor = Y
    			      DrawScrollBar_(ScrollBar)
    			    EndIf ;} 
    			  EndIf
    			  
    			  ProcedureReturn #True
  			  EndIf
  			  
  			Else
  			  
  			  If Y >= TreeEx()\ScrollBar\Item()\Y And Y <= TreeEx()\ScrollBar\Item()\Y + TreeEx()\ScrollBar\Item()\Height
  			    
    			  If X >= TreeEx()\ScrollBar\Item()\Buttons\Backwards\X And X <= TreeEx()\ScrollBar\Item()\Buttons\Backwards\X + TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width
    			    ;{ Backwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Click)
    			      TreeEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      TreeEx()\ScrollBar\Item()\Timer      = #ScrollBar_Left
    			      TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Click
    			    EndIf ;}
    			  ElseIf X >= TreeEx()\ScrollBar\Item()\Buttons\Forwards\X And X <= TreeEx()\ScrollBar\Item()\Buttons\Forwards\X + TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height
    			    ;{ Forwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Click
    			      DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Click)
    			      TreeEx()\ScrollBar\Item()\TimerDelay = #ScrollBar_TimerDelay
    			      TreeEx()\ScrollBar\Item()\Timer      = #ScrollBar_Right
    			      TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Click
    			    EndIf ;}
    			  ElseIf X >= TreeEx()\ScrollBar\Item()\Thumb\X And X <= TreeEx()\ScrollBar\Item()\Thumb\X + TreeEx()\ScrollBar\Item()\Thumb\Width
    			    ;{ Thumb Button
    			    If TreeEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Click
    			      TreeEx()\ScrollBar\Item()\Thumb\State  = #ScrollBar_Click
    			      TreeEx()\ScrollBar\Item()\Thumb\Offset = TreeEx()\ScrollBar\Item()\Thumb\X - X
    			      TreeEx()\ScrollBar\Item()\Cursor = X
    			      DrawScrollBar_(ScrollBar)
    			    EndIf ;} 
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf
    			
  			EndIf
        ;}
      Next 
			
			ForEach TreeEx()\Rows()
			  
			  If X >= TreeEx()\Rows()\Button\X And X <= TreeEx()\Rows()\Button\X + dpiX(#ButtonSize)                       ;{ Button
			    If Y >= TreeEx()\Rows()\Button\Y And Y <= TreeEx()\Rows()\Button\Y + dpiX(#ButtonSize)
			      
			      TreeEx()\Rows()\Button\State ! #True
			      
			      If TreeEx()\Rows()\Button\State
			        TreeEx()\Rows()\State | #Expanded
    	        TreeEx()\Rows()\State & ~#Collapsed
			        PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Expanded, ListIndex(TreeEx()\Rows()))
              PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Expanded, ListIndex(TreeEx()\Rows()))
            Else
              TreeEx()\Rows()\State | #Collapsed
    	        TreeEx()\Rows()\State & ~#Expanded
			        PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Collapsed, ListIndex(TreeEx()\Rows()))
              PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Collapsed, ListIndex(TreeEx()\Rows()))
			      EndIf  
			      
			      ReDraw_()
			      Break
			    EndIf
			    ;}
			  ElseIf  X >= TreeEx()\Rows()\CheckBox\X And X <= TreeEx()\Rows()\CheckBox\X + TreeEx()\Rows()\CheckBox\Size  ;{ CheckBox 
			    If Y >= TreeEx()\Rows()\CheckBox\Y And Y <= TreeEx()\Rows()\CheckBox\Y + TreeEx()\Rows()\CheckBox\Size
			      If TreeEx()\Rows()\State & #Checked
			        TreeEx()\Rows()\State & ~#Checked
			        If TreeEx()\Flags & #ThreeState : TreeEx()\Rows()\State | #Inbetween : EndIf
			      ElseIf TreeEx()\Rows()\State & #Inbetween
			        TreeEx()\Rows()\State & ~#Inbetween
			      Else  
			        TreeEx()\Rows()\State | #Checked
			      EndIf
			      PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_CheckBox)
            PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_CheckBox)
			      ReDraw_()
			      Break
			    EndIf  
			    ;}
			  ElseIf X >= TreeEx()\Rows()\Text\X And X <= TreeEx()\Rows()\Text\X + TreeEx()\Rows()\Text\Width              ;{ Select row
			    If Y >= TreeEx()\Rows()\Y And Y <= TreeEx()\Rows()\Y + dpiY(TreeEx()\Row\Height)
			      TreeEx()\Row\Focus = ListIndex(TreeEx()\Rows())
            PostEvent(#PB_Event_Gadget, TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
            PostEvent(#Event_Gadget,    TreeEx()\Window\Num, TreeEx()\CanvasNum, #EventType_Row, TreeEx()\Row\Focus)
			      ReDraw_()
			      Break
			    EndIf ;}
			  EndIf  
			  
			Next

		EndIf

	EndProcedure
	
	Procedure _LeftButtonUpHandler()
    Define.s ScrollBar
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(TreeEx(), Str(GNum))

			X = GetGadgetAttribute(TreeEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(TreeEx()\CanvasNum, #PB_Canvas_MouseY)
			
			ForEach TreeEx()\ScrollBar\Item()
      
  		  If TreeEx()\ScrollBar\Item()\Hide : Continue : EndIf 
  		  
  		  TreeEx()\ScrollBar\Item()\Cursor = #PB_Default
  			TreeEx()\ScrollBar\Item()\Timer  = #False
  			
  			ScrollBar = MapKey(TreeEx()\ScrollBar\Item())
  			
  			If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical ;{ Vertical Scrollbar
  			  
  			  If X >= TreeEx()\ScrollBar\Item()\X And X <= TreeEx()\ScrollBar\Item()\X + TreeEx()\ScrollBar\Item()\Width
  			    
    			  If Y >= TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y And Y <= TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y + TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height
    			    TreeEx()\ScrollBar\Item()\Pos - 1
    			    If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
    			    Redraw_()
    			  ElseIf Y >= TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y And Y <= TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y + TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height
    			    TreeEx()\ScrollBar\Item()\Pos + 1
    			    If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
    			    Redraw_()
    			  ElseIf Y < TreeEx()\ScrollBar\Item()\Thumb\Y
    			    TreeEx()\ScrollBar\Item()\Pos - TreeEx()\ScrollBar\Item()\PageLength
    			    If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
    			    Redraw_()
    			  ElseIf Y > TreeEx()\ScrollBar\Item()\Thumb\Y + TreeEx()\ScrollBar\Item()\Thumb\Height
    			    TreeEx()\ScrollBar\Item()\Pos + TreeEx()\ScrollBar\Item()\PageLength
    			    If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
    			    Redraw_()
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf  
  			  ;}
  			Else                                                    ;{ Horizontal Scrollbar
  			  
  			  If Y >= TreeEx()\ScrollBar\Item()\Y And Y <= TreeEx()\ScrollBar\Item()\Y + TreeEx()\ScrollBar\Item()\Height
  			    
    			  If X <= TreeEx()\ScrollBar\Item()\Buttons\Backwards\X + TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width
    			    TreeEx()\ScrollBar\Item()\Pos - 1
    			    If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
    			    Redraw_()
    			  ElseIf X >= TreeEx()\ScrollBar\Item()\Buttons\Forwards\X
    			    TreeEx()\ScrollBar\Item()\Pos + 1
    			    If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
    			    Redraw_()
    			  ElseIf X < TreeEx()\ScrollBar\Item()\Thumb\X
    			    TreeEx()\ScrollBar\Item()\Pos - TreeEx()\ScrollBar\Item()\PageLength
    			    If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
    			    Redraw_()
    			  ElseIf X > TreeEx()\ScrollBar\Item()\Thumb\X + TreeEx()\ScrollBar\Item()\Thumb\Width
    			    TreeEx()\ScrollBar\Item()\Pos + TreeEx()\ScrollBar\Item()\PageLength
    			    If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
    			    Redraw_()
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf  
  			  ;}
  			EndIf
  			
  		Next
			
		EndIf
		
	EndProcedure	
	
	Procedure _MouseMoveHandler()
	  Define.s ScrollBar
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(TreeEx(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)

      ForEach TreeEx()\ScrollBar\Item()

  	    If TreeEx()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(TreeEx()\ScrollBar\Item())
        
  	    If TreeEx()\ScrollBar\Item()\Type = #ScrollBar_Vertical       ;{ Vertical Scrollbar
  	      
  	      If X >= TreeEx()\ScrollBar\Item()\X And X <= TreeEx()\ScrollBar\Item()\X + TreeEx()\ScrollBar\Item()\Width
  	      
    	      If Y <= TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y + TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height
    	        ;{ Backwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Focus
    			      
    			      TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Focus
 
    			      DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Focus)
    			      
    			    EndIf
  			      ;}
    			    ProcedureReturn #True
    			  ElseIf Y >= TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y
    			    ;{ Forwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Focus
    			      
    			      TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Focus
    			      
    			      If TreeEx()\ScrollBar\Item()\Thumb\State <> #False
    			        TreeEx()\ScrollBar\Item()\Thumb\State = #False
    			        DrawScrollBar_(ScrollBar)
    			      Else 
    			        DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Focus)
    			      EndIf
    			      
    			    EndIf ;}
    			    ProcedureReturn #True
    			  EndIf
  
    			  TreeEx()\ScrollBar\Item()\Timer = #False
    			  
    			  If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
    			    TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
    			    DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
      			  ;}
      			EndIf
      			
      			If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
      			  TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
      			  DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
      			  ;}
      			EndIf
    
    			  If Y >= TreeEx()\ScrollBar\Item()\Thumb\Y And Y <= TreeEx()\ScrollBar\Item()\Thumb\Y + TreeEx()\ScrollBar\Item()\Thumb\Height
    			    ;{ Move Thumb
    			    If TreeEx()\ScrollBar\Item()\Cursor <> #PB_Default
    			      
    			      ;TreeEx()\ScrollBar\Item()\Pos + GetSteps_(Y)
    			      TreeEx()\ScrollBar\Item()\Pos = GetScrollBarPos(Y + TreeEx()\ScrollBar\Item()\Thumb\Offset)
    			      
    			      If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
    			      If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
    			      
    			      TreeEx()\ScrollBar\Item()\Cursor = Y
    		        
    			      Redraw_(#True)
    			      
    		        ProcedureReturn #True
    		      EndIf ;}
    			    ;{ Thumb Focus
    			    If TreeEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Focus
    			      TreeEx()\ScrollBar\Item()\Thumb\State = #ScrollBar_Focus
    			      DrawScrollBar_(ScrollBar, #True)
    			    EndIf ;} 
    			    ProcedureReturn #True
    			  EndIf
    			  
    			  ProcedureReturn #True
    			EndIf  
  			  ;}
  	    Else                                                          ;{ Horizontal Scrollbar
  	      
  	      If Y >= TreeEx()\ScrollBar\Item()\Y And Y <= TreeEx()\ScrollBar\Item()\Y + TreeEx()\ScrollBar\Item()\Height

    	      If X <= TreeEx()\ScrollBar\Item()\Buttons\Backwards\X + TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width
    			    ;{ Backwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #ScrollBar_Focus
    			      DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards, #ScrollBar_Focus)
    			      TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #ScrollBar_Focus
    			    EndIf ;}
    			    ProcedureReturn #True
    			  ElseIf X >= TreeEx()\ScrollBar\Item()\Buttons\Forwards\X
    			    ;{ Forwards Button
    			    If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #ScrollBar_Focus
    			      DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards, #ScrollBar_Focus)
    			      TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #ScrollBar_Focus
    			    EndIf ;}
    			    ProcedureReturn #True
    			  EndIf
  
    			  TreeEx()\ScrollBar\Item()\Timer = #False
    			  
      			If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
      			  DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
      			  TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
      			  ;}
      			EndIf
      			
      			If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
      			  DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
      			  TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
      			  ;}
      			EndIf
    			  
    			  If X >= TreeEx()\ScrollBar\Item()\Thumb\X And X <= TreeEx()\ScrollBar\Item()\Thumb\X + TreeEx()\ScrollBar\Item()\Thumb\Width
    			    ;{ Thumb Button
    			    If TreeEx()\ScrollBar\Item()\Cursor <> #PB_Default
    
    		        ;TreeEx()\ScrollBar\Item()\Pos + GetSteps_(X)
    			      TreeEx()\ScrollBar\Item()\Pos = GetScrollBarPos(X + TreeEx()\ScrollBar\Item()\Thumb\Offset)
    			      
    		        If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
    		        If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
    		        
    		        TreeEx()\ScrollBar\Item()\Cursor = X
    		        
    		        Redraw_(#True)
    		        
    		        ProcedureReturn #True
    		      EndIf ;}
    			    ;{ Thumb Focus
    			    If TreeEx()\ScrollBar\Item()\Thumb\State <> #ScrollBar_Focus
    			      TreeEx()\ScrollBar\Item()\Thumb\State = #ScrollBar_Focus
    			      DrawScrollBar_(ScrollBar, #True)
    			    EndIf ;} 
    			    ProcedureReturn #True
    			  EndIf
    			  
    			  ProcedureReturn #True
  			  EndIf
  			  ;}
  			EndIf

  			If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False ;{ Backwards Button
  			  DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
  			  TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
  			  ;}
  			EndIf
  			
  			If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False  ;{ Forwards Button
  			  DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
  			  TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
  			  ;}
  			EndIf
  			
  			If TreeEx()\ScrollBar\Item()\Thumb\State <> #False             ;{ Thumb Button
  			  TreeEx()\ScrollBar\Item()\Thumb\State = #False
  			  DrawScrollBar_(ScrollBar, #True)
  			  ;}
  			EndIf
  
  		Next
  		
  		;{ Thumb Focus vertical/horizontal
			If TreeEx()\ScrollBar\Item("HScroll")\Cursor <> #PB_Default
  
        TreeEx()\ScrollBar\Item()\Pos = GetScrollBarPos(X + TreeEx()\ScrollBar\Item()\Thumb\Offset)
        
        If TreeEx()\ScrollBar\Item("HScroll")\Pos > TreeEx()\ScrollBar\Item("HScroll")\maxPos : TreeEx()\ScrollBar\Item("HScroll")\Pos = TreeEx()\ScrollBar\Item("HScroll")\maxPos : EndIf
        If TreeEx()\ScrollBar\Item("HScroll")\Pos < TreeEx()\ScrollBar\Item("HScroll")\minPos : TreeEx()\ScrollBar\Item("HScroll")\Pos = TreeEx()\ScrollBar\Item("HScroll")\minPos : EndIf
        
        TreeEx()\ScrollBar\Item("HScroll")\Cursor = X
        
        Redraw_(#True)
        
        ProcedureReturn #True
      EndIf
			
			If TreeEx()\ScrollBar\Item("VScroll")\Cursor <> #PB_Default

	      TreeEx()\ScrollBar\Item()\Pos = GetScrollBarPos(Y + TreeEx()\ScrollBar\Item()\Thumb\Offset)
	      
	      If TreeEx()\ScrollBar\Item("VScroll")\Pos > TreeEx()\ScrollBar\Item("VScroll")\maxPos : TreeEx()\ScrollBar\Item("VScroll")\Pos = TreeEx()\ScrollBar\Item("VScroll")\maxPos : EndIf
	      If TreeEx()\ScrollBar\Item("VScroll")\Pos < TreeEx()\ScrollBar\Item("VScroll")\minPos : TreeEx()\ScrollBar\Item("VScroll")\Pos = TreeEx()\ScrollBar\Item("VScroll")\minPos : EndIf
	      
	      TreeEx()\ScrollBar\Item("VScroll")\Cursor = Y
        
	      Redraw_(#True)
	      
        ProcedureReturn #True
      EndIf ;}

		EndIf

	EndProcedure
	
	Procedure _MouseLeaveHandler()
	  Define.s ScrollBar
	  Define.i GNum = EventGadget()

	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    ForEach TreeEx()\ScrollBar\Item()
      
  	    If TreeEx()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(TreeEx()\ScrollBar\Item())
  	    
  	    If TreeEx()\ScrollBar\Item()\Buttons\Backwards\State <> #False
  			  DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Backwards\X, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Backwards\Height, ScrollBar, #ScrollBar_Backwards)
  			  TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #False
  			EndIf
  			
  			If TreeEx()\ScrollBar\Item()\Buttons\Forwards\State <> #False
  			  DrawScrollButton_(TreeEx()\ScrollBar\Item()\Buttons\Forwards\X, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Y, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Width, TreeEx()\ScrollBar\Item()\Buttons\Forwards\Height, ScrollBar, #ScrollBar_Forwards)
  			  TreeEx()\ScrollBar\Item()\Buttons\Forwards\State = #False
  			EndIf
  			
  	    If TreeEx()\ScrollBar\Item()\Thumb\State <> #False
  	      TreeEx()\ScrollBar\Item()\Thumb\State = #False
  	      DrawScrollBar_(ScrollBar)
  	    EndIf  
  	    
      Next
	    
      If TreeEx()\Flags & #AlwaysShowSelection = #False
	      TreeEx()\Row\Focus = #PB_Default
	      ReDraw_()
	    EndIf
	    
	  EndIf 
	EndProcedure
	
	Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta
    Define.s ScrollBar
    
    If FindMapElement(TreeEx(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
  	  
  	  If FindMapElement(TreeEx()\ScrollBar\Item(), "VScroll")
        
  	    If TreeEx()\ScrollBar\Item()\Hide = #False

          TreeEx()\ScrollBar\Item()\Pos - Delta
  
          If TreeEx()\ScrollBar\Item()\Pos > TreeEx()\ScrollBar\Item()\maxPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\maxPos : EndIf
          If TreeEx()\ScrollBar\Item()\Pos < TreeEx()\ScrollBar\Item()\minPos : TreeEx()\ScrollBar\Item()\Pos = TreeEx()\ScrollBar\Item()\minPos : EndIf
          
          ReDraw_(#True)
        EndIf
        
	    EndIf

    EndIf
    
  EndProcedure
  
  
  Procedure _ResizeHandler()
    Define.s ScrollBar
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(TreeEx(), Str(GadgetNum))
      
      ForEach TreeEx()\ScrollBar\Item()
      
  	    If TreeEx()\ScrollBar\Item()\Hide : Continue : EndIf
  	    
  	    ScrollBar = MapKey(TreeEx()\ScrollBar\Item())
  	    
  		  CalcScrollBarThumb_(ScrollBar, #False)
  		  DrawScrollBar_(ScrollBar)
  		  
  	  Next

      ReDraw_()
    EndIf
    
  EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach TreeEx()

			If IsGadget(TreeEx()\CanvasNum)

				If TreeEx()\Flags & #AutoResize

					If IsWindow(TreeEx()\Window\Num)

						OffSetX = WindowWidth(TreeEx()\Window\Num)  - TreeEx()\Window\Width
						OffsetY = WindowHeight(TreeEx()\Window\Num) - TreeEx()\Window\Height

						If TreeEx()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If TreeEx()\Size\Flags & #MoveX  : X = TreeEx()\Size\X + OffSetX : EndIf
							If TreeEx()\Size\Flags & #MoveY  : Y = TreeEx()\Size\Y + OffSetY : EndIf
							If TreeEx()\Size\Flags & #Width  : Width  = TreeEx()\Size\Width + OffSetX : EndIf
							If TreeEx()\Size\Flags & #Height : Height = TreeEx()\Size\Height + OffSetY : EndIf

							ResizeGadget(TreeEx()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(TreeEx()\CanvasNum, #PB_Ignore, #PB_Ignore, TreeEx()\Size\Width + OffSetX, TreeEx()\Size\Height + OffsetY)
						EndIf

						ReDraw_()
					EndIf

				EndIf

			EndIf

		Next

	EndProcedure
	
	;- __________ ScrollBar __________
	
	Procedure InitScrollBar_(Flags.i=#False)

	  TreeEx()\ScrollBar\Flags = Flags
	  
	  If TimerThread\Active = #False 
      TimerThread\Exit   = #False
      TimerThread\Num    = CreateThread(@_TimerThread(), #ScrollBar_Timer)
      TimerThread\Active = #True
    EndIf
	  
		TreeEx()\ScrollBar\Color\Back         = $F0F0F0
		TreeEx()\ScrollBar\Color\Border       = $A0A0A0
		TreeEx()\ScrollBar\Color\Button       = $F0F0F0
		TreeEx()\ScrollBar\Color\Focus        = $D77800
		TreeEx()\ScrollBar\Color\Front        = $646464
		TreeEx()\ScrollBar\Color\Gadget       = $F0F0F0
		TreeEx()\ScrollBar\Color\ScrollBar    = $C8C8C8
		TreeEx()\ScrollBar\Color\DisableFront = $72727D
		TreeEx()\ScrollBar\Color\DisableBack  = $CCCCCA
		
		CompilerSelect #PB_Compiler_OS ;{ Color
			CompilerCase #PB_OS_Windows
				TreeEx()\ScrollBar\Color\Front     = GetSysColor_(#COLOR_GRAYTEXT)
				TreeEx()\ScrollBar\Color\Back      = GetSysColor_(#COLOR_MENU)
				TreeEx()\ScrollBar\Color\Border    = GetSysColor_(#COLOR_3DSHADOW)
				TreeEx()\ScrollBar\Color\Gadget    = GetSysColor_(#COLOR_MENU)
				TreeEx()\ScrollBar\Color\Focus     = GetSysColor_(#COLOR_MENUHILIGHT)
				TreeEx()\ScrollBar\Color\ScrollBar = GetSysColor_(#COLOR_SCROLLBAR)
			CompilerCase #PB_OS_MacOS
				TreeEx()\ScrollBar\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				TreeEx()\ScrollBar\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				TreeEx()\ScrollBar\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				TreeEx()\ScrollBar\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				TreeEx()\ScrollBar\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				; TreeEx()\ScrollBar\Color\ScrollBar = 
			CompilerCase #PB_OS_Linux

		CompilerEndSelect ;}
    
		BindEvent(#Event_Timer, @_AutoScroll())
		
	EndProcedure
	
  Procedure CreateScrollBar_(Label.s, CanvasNum.i, X.i, Y.i, Width.i, Height.i, Minimum.i, Maximum.i, PageLength.i, Type.i=#False)
    
    If AddMapElement(TreeEx()\ScrollBar\Item(), Label)
      
      TreeEx()\ScrollBar\Item()\Num = CanvasNum
      TreeEx()\ScrollBar\Item()\X          = dpiX(X)
      TreeEx()\ScrollBar\Item()\Y          = dpiY(Y)
      TreeEx()\ScrollBar\Item()\Width      = dpiX(Width)
      TreeEx()\ScrollBar\Item()\Height     = dpiY(Height)
      TreeEx()\ScrollBar\Item()\Minimum    = Minimum
      TreeEx()\ScrollBar\Item()\Maximum    = Maximum
      TreeEx()\ScrollBar\Item()\PageLength = PageLength
      TreeEx()\ScrollBar\Item()\Hide       = #True
      TreeEx()\ScrollBar\Item()\Type       = Type
      
      TreeEx()\ScrollBar\Item()\Cursor = #PB_Default
		
			TreeEx()\ScrollBar\Item()\Buttons\Forwards\State  = #PB_Default
			TreeEx()\ScrollBar\Item()\Buttons\Backwards\State = #PB_Default
			
			CalcScrollBarThumb_(Label)
		  DrawScrollBar_(Label)
			
    EndIf
    
  EndProcedure 
  
	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
	
  Procedure.i AddColumn(GNum.i, Column.i, Width.f, Title.s="", Label.s="", Flags.i=#False)
    ; 
	  Define.i Result
	  
	  If Column = 0 : ProcedureReturn #False : EndIf
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    ;{ Add Column
      Select Column
        Case #LastColumn
          LastElement(TreeEx()\Cols())
          Result = AddElement(TreeEx()\Cols())
        Default
          If ListSize(TreeEx()\Cols()) > 1
            SelectElement(TreeEx()\Cols(), Column)
            Result = InsertElement(TreeEx()\Cols()) 
          Else
            LastElement(TreeEx()\Cols())
            Result = AddElement(TreeEx()\Cols())
          EndIf
      EndSelect ;}
      
      If Result
        
        TreeEx()\Col\Counter + 1
        TreeEx()\Cols()\Width        = Width
        TreeEx()\Cols()\Color\Front  = #PB_Default
				TreeEx()\Cols()\Color\Back   = #PB_Default
				TreeEx()\Cols()\Color\Border = #PB_Default
        TreeEx()\Cols()\Flags        = Flags
        
        If Label
          TreeEx()\Cols()\Key = Label
        Else
          TreeEx()\Cols()\Key = Str(TreeEx()\Col\Counter)
        EndIf         
        
        TreeEx()\Cols()\Header\Title       = Title
        TreeEx()\Cols()\Header\FontID      = #PB_Default
        TreeEx()\Cols()\Header\Color\Front = #PB_Default
        TreeEx()\Cols()\Header\Color\Back  = #PB_Default
        
      EndIf
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
      
      ProcedureReturn ListIndex(TreeEx()\Cols())
	  EndIf
	  
	EndProcedure
	
	Procedure.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Image.i=#False, Sublevel.i=0, Flags.i=#False)
	  Define.i c, Num, Result
	  Define.s Key$, String$
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    ;{ Add item
      Select Row
        Case #FirstRow
          FirstElement(TreeEx()\Rows())
          Result = InsertElement(TreeEx()\Rows()) 
        Case #LastRow
          LastElement(TreeEx()\Rows())
          Result = AddElement(TreeEx()\Rows())
        Default
          If SelectElement(TreeEx()\Rows(), Row)
            Result = InsertElement(TreeEx()\Rows()) 
          Else
            LastElement(TreeEx()\Rows())
            Result = AddElement(TreeEx()\Rows())
          EndIf
      EndSelect ;}
      
      If Result
        
        TreeEx()\Rows()\ID    = Label
        TreeEx()\Rows()\Level = Sublevel
        
        c = 1
        
        ForEach TreeEx()\Cols()
          Key$    = TreeEx()\Cols()\Key
          String$ = StringField(Text, c, #LF$)
          If String$
            TreeEx()\Rows()\Column(Key$)\Value = String$
          EndIf  
          c + 1
        Next
      
      EndIf
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
      
      ProcedureReturn ListSize(TreeEx()\Rows())
	  EndIf
	  
	EndProcedure
	
  Procedure   ClearItems(GNum.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    ClearList(TreeEx()\Rows())
	    
	    If TreeEx()\ReDraw : ReDraw_() : EndIf
	    
	  EndIf  
	  
	EndProcedure
	
	Procedure.i CountItems(GNum.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    ProcedureReturn ListSize(TreeEx()\Rows())
	  EndIf 
	  
	EndProcedure
	
	Procedure   DisableReDraw(GNum.i, State.i=#False)

		If FindMapElement(TreeEx(), Str(GNum))

			If State
				TreeEx()\ReDraw = #False
			Else
				TreeEx()\ReDraw = #True
				ReDraw_()
			EndIf
			
		EndIf
		
	EndProcedure
	
	
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Title.s="", Flags.i=#False, WindowNum.i=#PB_Default)
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
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard)
    EndIf
		
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(TreeEx(), Str(GNum))

				TreeEx()\CanvasNum = GNum
				
				InitScrollBar_()
				
				CreateScrollBar_("HScroll", GNum, 0, 0, 0, 0, 0, 0, 0)
        CreateScrollBar_("VScroll", GNum, 0, 0, 0, 0, 0, 0, 0, #ScrollBar_Vertical)

				If WindowNum = #PB_Default
          TreeEx()\Window\Num = GetGadgetWindow()
        Else
          TreeEx()\Window\Num = WindowNum
        EndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						TreeEx()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							TreeEx()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						TreeEx()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				TreeEx()\Size\X = X
				TreeEx()\Size\Y = Y
				TreeEx()\Size\Width  = Width
				TreeEx()\Size\Height = Height
				
				TreeEx()\Row\Height = 20
				TreeEx()\Row\Focus  = #PB_Default
				TreeEx()\Row\Header\Height = 20
				
				TreeEx()\ProgressBar\Minimum = 0
        TreeEx()\ProgressBar\Maximum = 100
				
				TreeEx()\Flags  = Flags

				TreeEx()\ReDraw = #True
				
				ColorTheme_(#Theme_Default)

				;{ _____ Tree Column _____
				If AddElement(TreeEx()\Cols())
				  TreeEx()\Cols()\Key                = #Tree$
				  TreeEx()\Cols()\Flags              = #Tree
				  TreeEx()\Cols()\Width              = #PB_Default
				  TreeEx()\Cols()\Color\Front        = #PB_Default
				  TreeEx()\Cols()\Color\Back         = #PB_Default
				  TreeEx()\Cols()\Color\Border       = #PB_Default
				  TreeEx()\Cols()\Header\Title       = Title
				  TreeEx()\Cols()\Header\FontID      = #PB_Default
          TreeEx()\Cols()\Header\Color\Front = #PB_Default
          TreeEx()\Cols()\Header\Color\Back  = #PB_Default
				EndIf	;}	
				
				BindGadgetEvent(TreeEx()\CanvasNum, @_ResizeHandler(),         #PB_EventType_Resize)
				BindGadgetEvent(TreeEx()\CanvasNum, @_MouseMoveHandler(),      #PB_EventType_MouseMove)
				BindGadgetEvent(TreeEx()\CanvasNum, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
				BindGadgetEvent(TreeEx()\CanvasNum, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
				BindGadgetEvent(TreeEx()\CanvasNum, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)
				BindGadgetEvent(TreeEx()\CanvasNum, @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
				BindGadgetEvent(TreeEx()\CanvasNum, @_KeyDownHandler(),        #PB_EventType_KeyDown)
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(TreeEx()\Window\Num)
						TreeEx()\Window\Width  = WindowWidth(TreeEx()\Window\Num)
						TreeEx()\Window\Height = WindowHeight(TreeEx()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), TreeEx()\Window\Num)
					EndIf
				EndIf ;}

				ReDraw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    ProcedureReturn TreeEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    ProcedureReturn TreeEx()\ID
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetItemAttribute(GNum.i, Row.i, Attribute.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	    Else 
	      
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      
  	      Select Attribute
  	        Case #SubLevel
  	          ProcedureReturn TreeEx()\Rows()\Level
  	      EndSelect
  	      
    	  EndIf
    	  
    	EndIf
    	
	  EndIf  
	
	EndProcedure  
	
	Procedure.i GetItemColor(GNum.i, Row.i, ColorTyp.i, Column.i=#PB_Ignore)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header ;{ Header row
	      
	      If Column = #PB_Default : Column = #TreeColumn : EndIf
	      
	      If SelectElement(TreeEx()\Cols(), Column)
	        
	        Select ColorTyp
  	        Case #FrontColor
  	          ProcedureReturn TreeEx()\Cols()\Header\Color\Front
  	        Case #BackColor
      	      ProcedureReturn TreeEx()\Cols()\Header\Color\Back
      	  EndSelect
          
        EndIf
	      ;}
	    Else 
	      
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      
  	      If Column = #PB_Default ;{ Row
  	        
    	      Select ColorTyp
    	        Case #FrontColor
    	          ProcedureReturn TreeEx()\Rows()\Color\Front
    	        Case #BackColor
        	      ProcedureReturn TreeEx()\Rows()\Color\Back
        	  EndSelect
        	  ;}
        	Else                    ;{ Column of row
        	  
        	  If SelectElement(TreeEx()\Cols(), Column)
        	    Select ColorTyp
      	        Case #FrontColor
      	          ProcedureReturn TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\Color\Front
      	        Case #BackColor
          	      ProcedureReturn TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\Color\Back
          	  EndSelect 
        	  EndIf  
        	  ;}
        	EndIf
        	
  	    EndIf
  	    
  	  EndIf
  	  
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetItemData(GNum.i, Row.i)

	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	    Else 
	      
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      ProcedureReturn TreeEx()\Rows()\iData
  	    EndIf
  	    
  	  EndIf
  	  
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemLabel(GNum.i, Row.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	    Else 
	      
	      If SelectElement(TreeEx()\Rows(), Row)
	        ProcedureReturn TreeEx()\Rows()\ID
      	EndIf
      	
  	  EndIf
  	  
	  EndIf  
	 
	EndProcedure
	
	
	Procedure.i GetItemState(GNum.i, Row.i, Column.i=#PB_Ignore)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	    Else 
	      
	      If SelectElement(TreeEx()\Rows(), Row)
	        
  	      If Column = #PB_Ignore
      	    ProcedureReturn TreeEx()\Rows()\State
      	  Else
      	    If SelectElement(TreeEx()\Cols(), Column)
      	      ProcedureReturn TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\State
      	    EndIf
      	  EndIf 
      	  
      	EndIf
      	
  	  EndIf
  	  
	  EndIf  
	 
	EndProcedure
	
	Procedure.s GetItemText(GNum.i, Row.i, Column.i=#PB_Ignore)
	  
	  If Column = #PB_Ignore : Column = #TreeColumn : EndIf
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	      
        If SelectElement(TreeEx()\Cols(), Column)
          ProcedureReturn TreeEx()\Cols()\Header\Title
        EndIf
        
      Else
        
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      If SelectElement(TreeEx()\Cols(), Column)
  	        ProcedureReturn TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\Value
  	      EndIf
  	    EndIf
  	    
  	  EndIf
  	  
	  EndIf  
	 
	EndProcedure
	
	
	Procedure.i GetLabelState(GNum.i, Row.i, Label.s=#Tree$)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	    Else 
	      
	      If SelectElement(TreeEx()\Rows(), Row)
      	  ProcedureReturn TreeEx()\Rows()\Column(Label)\State
      	EndIf
      	
  	  EndIf
  	  
	  EndIf  
	 
	EndProcedure
	
	Procedure.s GetLabelText(GNum.i, Row.i, Label.s=#Tree$) 
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
      Else
        
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      ProcedureReturn TreeEx()\Rows()\Column(Label)\Value
  	    EndIf
  	    
  	  EndIf
  	  
  	EndIf 
  	
  EndProcedure
  
  
	Procedure.i GetState(GNum.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    ProcedureReturn TreeEx()\Row\Focus
	  EndIf
	  
	EndProcedure
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If State
	      TreeEx()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      TreeEx()\Hide = #False
	      HideGadget(GNum, #False)
	      ReDraw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	Procedure   RemoveItem(GNum.i, Row.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	    Else 
	      
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      
  	      DeleteElement(TreeEx()\Rows())
  	      
  	      If TreeEx()\ReDraw : ReDraw_() : EndIf
  	      
  	    EndIf 
  	    
  	  EndIf
  	  
	  EndIf  
	  
	EndProcedure
	
	Procedure   SaveColorTheme(GNum.i, File.s)
    Define.i JSON
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      JSON = CreateJSON(#PB_Any)
      If JSON
        InsertJSONStructure(JSONValue(JSON), @TreeEx()\Color, TreeEx_Color_Structure)
        SaveJSON(JSON, File)
        FreeJSON(JSON)
      EndIf
     
    EndIf  
    
  EndProcedure 
  
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      Select Attribute
        Case #ScrollBar
          TreeEx()\ScrollBar\Flags = Value
      EndSelect
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
      
    EndIf
    
  EndProcedure

  Procedure   SetAutoResizeColumn(GNum.i, Column.i, minWidth.f=#PB_Default, maxWidth.f=#PB_Default)
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      If SelectElement(TreeEx()\Cols(), Column)
        
        If minWidth = #PB_Default : minWidth = TreeEx()\Cols()\Width : EndIf

        TreeEx()\AutoResize\Column   = Column
        TreeEx()\AutoResize\minWidth = minWidth
        TreeEx()\AutoResize\maxWidth = maxWidth
        TreeEx()\AutoResize\Width    = TreeEx()\Cols()\Width
      EndIf
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
    EndIf  
 
  EndProcedure  
  
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      TreeEx()\Size\Flags = Flags
      TreeEx()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore) ; GNum: #Theme => change all gadgets
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      If GNum = #Theme
        
        ForEach TreeEx()
          SetColor_(ColorTyp, Value)
        Next
        
      Else
        
        If Column = #PB_Ignore

          SetColor_(ColorTyp, Value)

        Else
          
          If SelectElement(TreeEx()\Cols(), Column)
            Select ColorTyp
              Case #FrontColor
                TreeEx()\Cols()\Color\Front  = Value
              Case #BackColor
                TreeEx()\Cols()\Color\Back   = Value
              Case #BorderColor  
                TreeEx()\Cols()\Color\Border = Value
            EndSelect
          EndIf
          
        EndIf
        
      EndIf
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetColorTheme(GNum.i, Theme.i=#Theme_Default, File.s="")   ; GNum: #Theme => change all gadgets
    Define.i JSON
    
    If GNum = #Theme 
      
      If Theme = #Theme_Custom
        JSON = LoadJSON(#PB_Any, File)
      EndIf  
      
      ForEach TreeEx()
        
        If Theme = #Theme_Custom 
          If IsJSON(JSON) : ExtractJSONStructure(JSONValue(JSON), @TreeEx()\Color, TreeEx_Color_Structure) : EndIf
        Else
          ColorTheme_(Theme)
        EndIf
        
        ReDraw_()
      Next
      
      If Theme = #Theme_Custom
        If IsJSON(JSON) : FreeJSON(JSON) : EndIf
      EndIf  
      
    ElseIf FindMapElement(TreeEx(), Str(GNum))

      If Theme = #Theme_Custom 
        JSON = LoadJSON(#PB_Any, File)
        If JSON
          ExtractJSONStructure(JSONValue(JSON), @TreeEx()\Color, TreeEx_Color_Structure)
          FreeJSON(JSON)
        EndIf
      Else
        ColorTheme_(Theme)
      EndIf
    
      ReDraw_()
    EndIf  
    
  EndProcedure  
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    TreeEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
  Procedure   SetHeaderAttribute(GNum.i, Attribute.i, Value.i, Column.i=#PB_Ignore)
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      If Column = #PB_Ignore ;{ Header row
        
        Select Attribute
          Case #Align ;{ Align of header row
            ForEach TreeEx()\Cols()
              Select Value
                Case #Left
                  TreeEx()\Cols()\Header\Flags & ~#Right
                  TreeEx()\Cols()\Header\Flags & ~#Center
                Case #Right
                  TreeEx()\Cols()\Header\Flags | #Right
                  TreeEx()\Cols()\Header\Flags & ~#Center
                Case #Center
                  TreeEx()\Cols()\Header\Flags | #Center
                  TreeEx()\Cols()\Header\Flags & ~#Right
              EndSelect
            Next ;}
        EndSelect    
        ;}
      Else                   ;{ Header column
        
        If SelectElement(TreeEx()\Cols(), Column)
          Select Attribute
            Case #Align ;{ Align of header column
              Select Value
                Case #Left
                  TreeEx()\Cols()\Header\Flags & ~#Right
                  TreeEx()\Cols()\Header\Flags & ~#Center
                Case #Right
                  TreeEx()\Cols()\Header\Flags | #Right
                  TreeEx()\Cols()\Header\Flags & ~#Center
                Case #Center
                  TreeEx()\Cols()\Header\Flags | #Center
                  TreeEx()\Cols()\Header\Flags & ~#Right
              EndSelect ;}
          EndSelect
          
        EndIf
        ;}
      EndIf
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetHeaderFont(GNum.i, FontID.i, Column.i=#PB_Ignore)       ; GNum: #Theme => change all gadgets
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      If GNum = #Theme 
        
        ForEach TreeEx()
          ForEach TreeEx()\Cols()
            TreeEx()\Cols()\Header\FontID = FontID
          Next  
        Next
        
      Else  

        If Column = #PB_Ignore ;{ Header row
  
          ForEach TreeEx()\Cols()
            TreeEx()\Cols()\Header\FontID = FontID
          Next  
          ;}
        Else                   ;{ Header column
          
          If SelectElement(TreeEx()\Cols(), Column)
            TreeEx()\Cols()\Header\FontID = FontID
          EndIf
          ;}
        EndIf
        
      EndIf
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
      
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    TreeEx()\ID = String
	  EndIf
	  
	EndProcedure  
  
  Procedure   SetFont(GNum.i, FontID.i, Column.i=#PB_Ignore)             ; GNum: #Theme => change all gadgets
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      If GNum = #Theme 
        
        ForEach TreeEx()
          TreeEx()\FontID = FontID
        Next  
        
      Else  
        
        If Column = #PB_Ignore
          TreeEx()\FontID = FontID
        Else
          If SelectElement(TreeEx()\Cols(), Column)
            TreeEx()\Cols()\FontID = FontID
          EndIf  
        EndIf 
        
      EndIf
      
      If TreeEx()\ReDraw : ReDraw_() : EndIf
      
    EndIf
    
  EndProcedure  
  
	Procedure   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	      
	      If Column = #PB_Ignore : Column = #TreeColumn : EndIf
	      
	      If SelectElement(TreeEx()\Cols(), Column)
	        Select ColorTyp
  	        Case #FrontColor
  	          TreeEx()\Cols()\Header\Color\Front = Value
  	        Case #BackColor
      	      TreeEx()\Cols()\Header\Color\Back  = Value
      	  EndSelect
        EndIf
	      
	    Else 

  	    If Row = #Header
  	    Else 
  	     
	        If SelectElement(TreeEx()\Rows(), Row)
	          
    	      If Column = #PB_Ignore ;{ Row
    	        
      	      Select ColorTyp
      	        Case #FrontColor
      	          TreeEx()\Rows()\Color\Front = Value
      	        Case #BackColor
          	      TreeEx()\Rows()\Color\Back  = Value
          	  EndSelect
          	  ;}
          	Else                   ;{ Column of row
        	  
        	    If SelectElement(TreeEx()\Cols(), Column)
          	    Select ColorTyp
        	        Case #FrontColor
        	          ProcedureReturn TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\Color\Front
        	        Case #BackColor
            	      ProcedureReturn TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\Color\Back
            	  EndSelect
            	EndIf
            	;}
            EndIf	
        	  
        	EndIf
          
  	    EndIf
  	    
  	  EndIf
  	  
  	  If TreeEx()\ReDraw : ReDraw_() : EndIf
  	  
	  EndIf
	  
	EndProcedure  
  
  Procedure   SetItemData(GNum.i, Row.i, Value.i)

	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	    Else 
	      
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      TreeEx()\Rows()\iData = Value
  	    EndIf
  	    
  	  EndIf
  	  
	  EndIf
	  
	EndProcedure  
	
		
	Procedure   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False, Column.i=#TreeColumn)
    Define.s Key$
    
    If FindMapElement(TreeEx(), Str(GNum))
      
      If Row = #Header ;{ Header row
        
        If SelectElement(TreeEx()\Cols(), Column)
          
          If IsImage(Image)
            TreeEx()\Cols()\Header\Image\Num    = Image
            TreeEx()\Cols()\Header\Image\Width  = ImageWidth(Image)
            TreeEx()\Cols()\Header\Image\Height = ImageHeight(Image)
            TreeEx()\Cols()\Header\Image\Flags  = Flags
          EndIf
          
        EndIf
        ;}
      Else 
        
        If SelectElement(TreeEx()\Rows(), Row)
          If SelectElement(TreeEx()\Cols(), Column)
            
            Key$ = TreeEx()\Cols()\Key
            If IsImage(Image)
              TreeEx()\Rows()\Column(Key$)\Image\Num    = Image
              TreeEx()\Rows()\Column(Key$)\Image\Width  = ImageWidth(Image)
              TreeEx()\Rows()\Column(Key$)\Image\Height = ImageHeight(Image)
              TreeEx()\Rows()\Column(Key$)\Image\Flags  = Flags
            EndIf
            
          EndIf
        EndIf  
        
        If TreeEx()\ReDraw : ReDraw_() : EndIf
        
      EndIf
      
	  EndIf   
   
  EndProcedure
  
  Procedure   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Ignore)
    Define.s Key$
    
    If FindMapElement(TreeEx(), Str(GNum))
      
	    If Row = #Header
	    Else 
	      
	      If SelectElement(TreeEx()\Rows(), Row)
	        
	        If Column = #PB_Ignore ;{ Row

    	      TreeEx()\Rows()\State = State
    	      
    	      If State & #Selected
    	        TreeEx()\Row\Focus = Row
    	      EndIf  
    
    	      If State & #Expanded
    	        TreeEx()\Rows()\Button\State = #True
    	        TreeEx()\Rows()\State | #Expanded
    	        TreeEx()\Rows()\State & ~#Collapsed
    	      ElseIf State & #Collapsed
    	        TreeEx()\Rows()\Button\State = #False
    	        TreeEx()\Rows()\State | #Collapsed
    	        TreeEx()\Rows()\State & ~#Expanded
    	      EndIf
    	      ;}
    	    Else                   ;{ Column of row
    	    
      	    If SelectElement(TreeEx()\Cols(), Column)
      	      TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\State = State
      	    EndIf   
    	      ;}
    	    EndIf
    	    
    	  EndIf
    	  
  	  EndIf  
	    
  	  If TreeEx()\ReDraw : ReDraw_() : EndIf
  	  
	  EndIf  
	 
	EndProcedure
  
	Procedure   SetItemText(GNum.i, Row.i, Text.s, Column.i=#TreeColumn)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Row = #Header
	      
        If SelectElement(TreeEx()\Cols(), Column)
          TreeEx()\Cols()\Header\Title = Text
        EndIf
        
      Else
        
  	    If SelectElement(TreeEx()\Rows(), Row)
  	      If SelectElement(TreeEx()\Cols(), Column)
    	      TreeEx()\Rows()\Column(TreeEx()\Cols()\Key)\Value = Text
    	    EndIf  
  	    EndIf
  	    
  	  EndIf
  	  
  	  If TreeEx()\ReDraw : ReDraw_() : EndIf
  	  
	  EndIf  
	 
	EndProcedure
	
	
  Procedure   SetLabelState(GNum.i, Row.i, State.i, Label.s=#Tree$)
    
    If FindMapElement(TreeEx(), Str(GNum))
      
	    If Row = #Header
	    Else 
	      
	      If SelectElement(TreeEx()\Rows(), Row)
      	  TreeEx()\Rows()\Column(Label)\State = State
    	  EndIf
    	  
  	  EndIf  
	    
  	  If TreeEx()\ReDraw : ReDraw_() : EndIf
  	  
	  EndIf  
	 
	EndProcedure	
	
	Procedure   SetLabelText(GNum.i, Row.i, Text.s, Label.s=#Tree$)
	  
	  If FindMapElement(TreeEx(), Str(GNum))

	    If SelectElement(TreeEx()\Rows(), Row)
	      
	      TreeEx()\Rows()\Column(Label)\Value = Text
	      
	      If TreeEx()\ReDraw : ReDraw_() : EndIf
	      
	    EndIf
  	  
	  EndIf  
	 
	EndProcedure
	
	
	Procedure   SetState(GNum.i, State.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))

	    ExpandFocus_(State)
	    
	    TreeEx()\Row\Focus = State
	    
	    SetRowFocus_()
	    
	    If TreeEx()\ReDraw : ReDraw_() : EndIf

	  EndIf
	  
	EndProcedure
	
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()

  Enumeration 1
    #Window
    #Button
    #TreeEx
    #Image
    #Font
  EndEnumeration
  
  LoadFont(#Font, "Arial", 7, #PB_Font_Bold)
  LoadImage(#Image, "test.png")
  
  If OpenWindow(#Window, 0, 0, 300, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If TreeEx::Gadget(#TreeEx, 10, 10, 280, 180, "Tree", TreeEx::#ShowHeader|TreeEx::#AlwaysShowSelection|TreeEx::#CheckBoxes|TreeEx::#ColumnLines|TreeEx::#AutoResize, #Window)
      ; |TreeEx::#FitTreeColumn|TreeEx::#FitTreeColumn|TreeEx::#SelectRow|TreeEx::#NoButtons|TreeEx::#NoLines
      TreeEx::AddColumn(#TreeEx, TreeEx::#LastColumn, 24, "",         "image",    TreeEx::#Image)
      TreeEx::AddColumn(#TreeEx, TreeEx::#LastColumn, 70, "Number",   "number",   TreeEx::#Right)    
      TreeEx::AddColumn(#TreeEx, TreeEx::#LastColumn, 80, "Progress", "progress", TreeEx::#ProgressBar|TreeEx::#ShowPercent)
      
      TreeEx::SetAutoResizeColumn(#TreeEx, 2, 50)
      
      TreeEx::SetHeaderAttribute(#TreeEx, TreeEx::#Align, TreeEx::#Center, 2)
      TreeEx::SetHeaderFont(#TreeEx, FontID(#Font))
      
      ; _____ Add content _____
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "Item" + #LF$ + #LF$ + "1")
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "Item" + #LF$ + #LF$ + "1",   "", #False, 3)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1",   "", #False, 1)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1.1", "", #False, 2)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1.1", "", #False, 3)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1.1.1", "", #False, 4)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1.2", "", #False, 0)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "Item"    + #LF$ + #LF$ + "2")
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "2.1",   "", #False, 1)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "2.2",   "", #False, 1)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "2.3",   "", #False, 1)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "2.3",   "", #False, 1)
      
      ; _____ Image _____
      TreeEx::SetItemImage(#TreeEx, TreeEx::#Header, #Image, TreeEx::#Center, 1)
      TreeEx::SetItemImage(#TreeEx, 4, #Image, TreeEx::#Center, 0)
      TreeEx::SetItemImage(#TreeEx, 5, #Image, TreeEx::#Center, 1)
      
      ; _____ ProgressBar _____
      TreeEx::SetItemState(#TreeEx, 0, 50, 3)
      TreeEx::SetItemState(#TreeEx, 1, 30, 3)
      TreeEx::SetItemState(#TreeEx, 4, 75, 3)
      TreeEx::SetItemState(#TreeEx, 5, 25, 3)
      TreeEx::SetItemState(#TreeEx, 6, 40, 3)
    EndIf
    
    ;TreeEx::SetItemState(#TreeEx, 1, TreeEx::#Expanded)
    
    TreeEx::SetColorTheme(#TreeEx, TreeEx::#Theme_Blue)
    
    ; ModuleEx::SetTheme(ModuleEx::#Theme_DarkBlue)
    
    TreeEx::SetState(#TreeEx, 3)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case TreeEx::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #TreeEx
              Select EventType()
                Case TreeEx::#EventType_Row      ; Select row
                  ;Debug "Row seleced: " + Str(EventData())
                Case TreeEx::#EventType_CheckBox ; Checkbox click
                  Debug "CheckBox clicked"
                Case TreeEx::#EventType_Collapsed
                  Debug "Collapsed: " + Str(EventData())
                Case TreeEx::#EventType_Expanded
                  Debug "Expanded: " + Str(EventData())
              EndSelect
          EndSelect ;}
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 3329
; FirstLine = 1087
; Folding = MDTAAAAAAIBlOIeCFCHBDABZhFKMCqzIgQX4+Gn-
; Markers = 2028
; EnableXP
; DPIAware