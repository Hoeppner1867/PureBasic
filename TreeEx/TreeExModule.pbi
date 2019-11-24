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
;/ © 2019  by Thorsten Hoeppner (11/2019)
;/

; Last Update:

; TODO: ScrollBars


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

; TreeEx::AddColumn()          - similar to 'AddGadgetColumn()'
; TreeEx::AddItem()            - similar to 'AddGadgetItem()'
; TreeEx::ClearItems()         - similar to 'ClearGadgetItems()'
; TreeEx::CountItems()         - similar to 'CountGadgetItems()'
; TreeEx::DisableReDraw()      - disable redraw
; TreeEx::Gadget()             - similar to 'TreeGadget()'
; TreeEx::GetItemColor()       - similar to 'GetGadgetItemColor()'
; TreeEx::GetItemData()        - similar to 'GetGadgetItemData()'
; TreeEx::GetItemState()       - similar to 'GetGadgetItemState()'
; TreeEx::GetItemText()        - similar to 'GetGadgetItemText()'
; TreeEx::GetLabelState()      - similar to 'GetGadgetItemState()', but label instead of column
; TreeEx::GetLabelText()       - similar to 'GetGadgetItemText()',  but label instead of column
; TreeEx::GetState()           - similar to 'GetGadgetState()'
; TreeEx::Hide()               - similar to 'HideGadget()'
; TreeEx::RemoveItem()         - similar to 'RemoveGadgetItem()'
; TreeEx::SaveColorTheme()     - save a custom color theme
; TreeEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; TreeEx::SetColor()           - similar to 'SetGadgetColor()'
; TreeEx::SetColorTheme()      - set or load a color theme
; TreeEx::SetFont()            - similar to 'SetGadgetFont()'
; TreeEx::SetHeaderAttribute() - set header attribute (e.g. align)
; TreeEx::SetHeaderFont()      - set header font
; TreeEx::SetItemColor()       - similar to 'SetGadgetItemColor()'
; TreeEx::SetItemData()        - similar to 'SetGadgetItemData()'
; TreeEx::SetItemImage()       - similar to 'SetGadgetItemImage()'
; TreeEx::SetItemState()       - similar to 'SetGadgetItemState()'
; TreeEx::SetItemText()        - similar to 'SetGadgetItemText()'
; TreeEx::SetLabelState()      - similar to 'SetGadgetItemState()', but label instead of column
; TreeEx::SetLabelText()       - similar to 'SetGadgetItemText()',  but label instead of column
; TreeEx::SetState()           - similar to 'SetGadgetState()'
;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule TreeEx
  
  #Version  = 19112200
  #ModuleEx = 19112002
  
  #Enable_ProgressBar = #True
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

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
		#ProgressText
		#ProgressFront
		#ProgressBack
		#ProgressGradient
		#ProgressBorder
	EndEnumeration ;}

	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget = ModuleEx::#Event_Gadget
		#Event_Theme  = ModuleEx::#Event_Theme
		
		#EventType_Row       = ModuleEx::#EventType_Row
		#EventType_CheckBox  = ModuleEx::#EventType_CheckBox
		#EventType_Collapsed = ModuleEx::#EventType_Collapsed
		#EventType_Expanded  = ModuleEx::#EventType_Expanded
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
			#Event_Gadget
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
	Declare.i GetItemColor(GNum.i, Row.i, ColorTyp.i, Column.i=#PB_Ignore)
  Declare.i GetItemData(GNum.i, Row.i)
  Declare.i GetItemState(GNum.i, Row.i, Column.i=#PB_Ignore)
  Declare.s GetItemText(GNum.i, Row.i, Column.i=#PB_Ignore)
  Declare.i GetLabelState(GNum.i, Row.i, Label.s=#Tree$)
  Declare.s GetLabelText(GNum.i, Row.i, Label.s=#Tree$) 
  Declare.i GetState(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   SaveColorTheme(GNum.i, File.s)
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
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================

	Structure Tree_Structure               ;{ ...\Tree\...
	  X.i
	  Y.i
	  Level.i
	  Button.i
	EndStructure ;}
	
	Structure Image_Structure              ;{ ...\Image\...
    Num.i
    Width.f
    Height.f
    Flags.i
  EndStructure ;}
  
  Structure Color_Structure              ;{ ...\Color\...
    Front.i
    Back.i
    Border.i
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
    Offset.i
    OffSetY.i
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
  
  
  Structure TreeEx_Scroll_Structure         ;{ TreeEx()\VScroll\...
    MinPos.f
    MaxPos.f
    Position.f
    Hide.i
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
		VScrollNum.i
		HScrollNum.i
		
		FontID.i

		ReDraw.i
		Hide.i
		
		Flags.i

		ToolTip.i
		ToolTipText.s

		Color.TreeEx_Color_Structure
		Window.TreeEx_Window_Structure
		Size.TreeEx_Size_Structure
		
		ProgressBar.TreeEx_Rows_ProgressBar
		
		Row.TreeEx_Row_Structure
		Col.TreeEx_Col_Structure
		VScroll.TreeEx_Scroll_Structure
    HScroll.TreeEx_Scroll_Structure
		
		List Cols.TreeEx_Cols_Structure()
		List Rows.TreeEx_Rows_Structure()

	EndStructure ;}
	Global NewMap TreeEx.TreeEx_Structure()

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
        TreeEx()\Color\Front        = Value
      Case #BackColor
        TreeEx()\Color\Back         = Value
      Case #BorderColor
        TreeEx()\Color\Border       = Value
      Case #LineColor  
        TreeEx()\Color\Line         = Value
      Case #FocusFrontColor
        TreeEx()\Color\FocusFront   = Value
      Case #FocusBackColor
        TreeEx()\Color\FocusBack    = Value
      Case #ButtonFrontColor
        TreeEx()\Color\ButtonFront  = Value
      Case #ButtonBackColor
        TreeEx()\Color\ButtonBack   = Value
      Case #ButtonBorderColor
        TreeEx()\Color\ButtonBorder = Value
      Case #HeaderFrontColor
        TreeEx()\Color\HeaderFront  = Value
      Case #HeaderBackColor
        TreeEx()\Color\HeaderBack   = Value
      Case #HeaderBorderColor
        TreeEx()\Color\HeaderBorder = Value
      Case #ProgressText
        TreeEx()\Color\ProgressText  = Value
      Case #ProgressFront
        TreeEx()\Color\ProgressFront = Value
      Case #ProgressBack
        TreeEx()\Color\ProgressBack  = Value
      Case #ProgressGradient
        TreeEx()\Color\ProgressGradient = Value
      Case #ProgressBorder  
        TreeEx()\Color\ProgressBorder   = Value
    EndSelect
	  
	EndProcedure  
	
	Procedure.i GetPageRows_()    ; all visible Rows
	  Define.i Height
	  
	  Height = GadgetHeight(TreeEx()\CanvasNum)
	  
	  If TreeEx()\Flags & #ShowHeader
	    Height - TreeEx()\Row\Header\Height  
	  EndIf
	  
	  If TreeEx()\HScroll\Hide = #False
	    Height - #ScrollBarSize
	  EndIf  
	  
	  ProcedureReturn Int(Height / TreeEx()\Row\Height)
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
	
	Procedure   CalcTreeWidth()
    Define.i TreeWidth, maxWidth, LevelWidth, Level, NextLevel, FontID
    Define.i btX, txtX, OffsetX, ImageWidth, ImageHeight, RowHeight, CheckBoxSize
    Define.f Factor

    If StartDrawing(CanvasOutput(TreeEx()\CanvasNum))
     
      LevelWidth   = dpiX(#ButtonSize) + dpiX(5)
      CheckBoxSize = TextHeight("Abc") - dpiX(2)
      
      ForEach TreeEx()\Rows()
        
        TreeWidth = 0
        
        If TreeEx()\Rows()\Level < Level : Level = TreeEx()\Rows()\Level : EndIf
        
  		  If TreeEx()\Rows()\Level = Level And TreeEx()\Rows()\Button\State
  		    Level = TreeEx()\Rows()\Level + 1
  		  EndIf
  		  
  		  If TreeEx()\Rows()\Level > Level : Continue : EndIf
  		  
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
			  
			  OffsetX   = LevelWidth * TreeEx()\Rows()\Level + dpiX(6)
			  TreeWidth = dpiX(#ButtonSize + 5) + OffsetX

			  If TreeEx()\Flags & #CheckBoxes : TreeWidth + CheckBoxSize : EndIf
			  
			  If IsImage(TreeEx()\Rows()\Column(#Tree$)\Image\Num) ;{ Image
			    
			    RowHeight   = dpiY(TreeEx()\Row\Height)
			    
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
			  
			Next
			
			TreeEx()\Col\TreeWidth = maxWidth
			
    	StopDrawing()
    EndIf
    
  EndProcedure
	
	Procedure   CalcRows()
    Define.i Level
    
    TreeEx()\Size\Rows   = 0
    TreeEx()\Row\Visible = 0
    
    ForEach TreeEx()\Rows()
      
      If TreeEx()\Rows()\Level < Level : Level = TreeEx()\Rows()\Level : EndIf
      
		  If TreeEx()\Rows()\Level = Level And TreeEx()\Rows()\Button\State
		    Level = TreeEx()\Rows()\Level + 1
		  EndIf
		  
		  If TreeEx()\Rows()\Level > Level
		    TreeEx()\Rows()\Visible      = #False
		    TreeEx()\Rows()\Button\State = #False
		    Continue
		  EndIf

		  TreeEx()\Rows()\Visible = #True
		  
		  TreeEx()\Row\Visible + 1
  		TreeEx()\Size\Rows + TreeEx()\Row\Height
		  
    Next
    
  EndProcedure
	
	Procedure   AdjustScrollBars_()
    Define.i Width
    Define.i PageRows
    
    If IsGadget(TreeEx()\VScrollNum) ;{ Vertical ScrollBar
      
      If TreeEx()\Size\Rows > (GadgetHeight(TreeEx()\CanvasNum) - TreeEx()\Row\Header\Height)
      
        PageRows = GetPageRows_()
        
        If TreeEx()\VScroll\Hide
          If TreeEx()\HScroll\Hide
            ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - 2)
          Else
            ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize - 2)
          EndIf
          HideGadget(TreeEx()\VScrollNum, #False)
          TreeEx()\VScroll\Hide = #False
        EndIf
        
        SetGadgetAttribute(TreeEx()\VScrollNum, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(TreeEx()\VScrollNum, #PB_ScrollBar_Maximum,    ListSize(TreeEx()\Rows()) - 1)
        SetGadgetAttribute(TreeEx()\VScrollNum, #PB_ScrollBar_PageLength, PageRows)
        
        TreeEx()\VScroll\MinPos = 0
        TreeEx()\VScroll\MaxPos = ListSize(TreeEx()\Rows()) - PageRows + 2
        
        If TreeEx()\VScroll\Hide = #False
          If GadgetHeight(TreeEx()\VScrollNum) < GadgetHeight(TreeEx()\CanvasNum) - 2
            
            If TreeEx()\HScroll\Hide
              ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - 2)
            Else
              ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize - 2)
            EndIf
            
          ElseIf GadgetHeight(TreeEx()\VScrollNum) > GadgetHeight(TreeEx()\CanvasNum)
            
            If TreeEx()\HScroll\Hide
              ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - 2)
            Else
              ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize - 2)
            EndIf
            
          EndIf
          
        EndIf
        
      ElseIf Not TreeEx()\VScroll\Hide And TreeEx()\Size\Rows < (GadgetHeight(TreeEx()\CanvasNum) - TreeEx()\Row\Header\Height)
        
        ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - 1, #ScrollBarSize - 2)
        HideGadget(TreeEx()\VScrollNum, #True)
        TreeEx()\Row\Offset   = 0
        TreeEx()\VScroll\Hide = #True
        
        If ListSize(TreeEx()\Rows()) = 0
          SetGadgetAttribute(TreeEx()\VScrollNum, #PB_ScrollBar_Maximum,    0)
          SetGadgetAttribute(TreeEx()\VScrollNum, #PB_ScrollBar_PageLength, 0)
        EndIf 
        
      EndIf
      ;}
    EndIf
    
    If TreeEx()\VScroll\Hide
      Width = GadgetWidth(TreeEx()\CanvasNum)
    Else
      Width = GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize 
    EndIf
    
    If IsGadget(TreeEx()\HScrollNum) ;{ Horizontal Scrollbar
      
      If TreeEx()\Size\Cols > Width
        
        If TreeEx()\HScroll\Hide
          If TreeEx()\VScroll\Hide
            ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - 1, #ScrollBarSize - 1)
          Else
            ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize - 1, #ScrollBarSize - 1)
          EndIf
          HideGadget(TreeEx()\HScrollNum, #False)
          TreeEx()\HScroll\Hide = #False
        EndIf
        
        SetGadgetAttribute(TreeEx()\HScrollNum, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(TreeEx()\HScrollNum, #PB_ScrollBar_Maximum,    TreeEx()\Size\Cols)
        SetGadgetAttribute(TreeEx()\HScrollNum, #PB_ScrollBar_PageLength, Width)
        
        TreeEx()\HScroll\MinPos = 0
        TreeEx()\HScroll\MaxPos = TreeEx()\Size\Cols - Width + 1
        
        If TreeEx()\HScroll\Hide = #False
          If GadgetWidth(TreeEx()\HScrollNum) < Width - 2
            If TreeEx()\VScroll\Hide
              ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - 1, #ScrollBarSize - 1)
            Else  
              ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize - 1, #ScrollBarSize - 1)
            EndIf  
          ElseIf GadgetWidth(TreeEx()\HScrollNum) > Width - 1
            If TreeEx()\VScroll\Hide
              ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - 1, #ScrollBarSize - 1)
            Else  
              ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize - 1, #ScrollBarSize - 1)
            EndIf 
          EndIf
          
        EndIf
        
      ElseIf TreeEx()\Size\Cols < Width
        
        If TreeEx()\HScroll\Hide = #False
          ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - 2)
          HideGadget(TreeEx()\HScrollNum, #True)
          TreeEx()\HScroll\Hide = #True
        EndIf
        
      EndIf 
      ;}
    EndIf
    
  EndProcedure
	
	Procedure   SetHScrollPosition_()
    Define.f ScrollPos
    
    If IsGadget(TreeEx()\HScrollNum)
      
      ScrollPos = TreeEx()\Col\OffsetX
      
      If ScrollPos < TreeEx()\HScroll\MinPos : ScrollPos = TreeEx()\HScroll\MinPos : EndIf
      If ScrollPos > TreeEx()\HScroll\MaxPos : ScrollPos = TreeEx()\HScroll\MaxPos : EndIf
      
      TreeEx()\Col\OffsetX      = ScrollPos
      TreeEx()\HScroll\Position = ScrollPos
      
      SetGadgetState(TreeEx()\HScrollNum, ScrollPos)
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetVScrollPosition_()
    Define.f ScrollPos
    
    If IsGadget(TreeEx()\VScrollNum)
      
      ScrollPos = TreeEx()\Row\Offset
      If ScrollPos > TreeEx()\VScroll\MaxPos : ScrollPos = TreeEx()\VScroll\MaxPos : EndIf
      
      TreeEx()\VScroll\Position = ScrollPos
      
      SetGadgetState(TreeEx()\VScrollNum, ScrollPos)
      
    EndIf
    
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
				TreeEx()\Color\ScrollBar        = $C8C8C8
				TreeEx()\Color\Gadget           = $C8C8C8
				TreeEx()\Color\FocusFront       = $43321C
				TreeEx()\Color\FocusBack        = $B06400
				TreeEx()\Color\ButtonFront      = $490000
				TreeEx()\Color\ButtonBack       = $E3E3E3
				TreeEx()\Color\ButtonBorder     = $B48246
				TreeEx()\Color\HeaderFront      = $43321C
        TreeEx()\Color\HeaderBack       = $E5CBAA
        TreeEx()\Color\HeaderBorder     = $A0A0A0
        TreeEx()\Color\ProgressText     = $FCF9F5
        TreeEx()\Color\ProgressFront    = $E5CBAA
        TreeEx()\Color\ProgressBack     = #PB_Default
        TreeEx()\Color\ProgressGradient = $CB9755
        TreeEx()\Color\ProgressBorder   = $764200
        
      Case #Theme_Green
        
        TreeEx()\Color\Front            = $0F2203
				TreeEx()\Color\Back             = $FCFDFC
				TreeEx()\Color\Border           = $9B9B9B
				TreeEx()\Color\Line             = $CCCCCC
				TreeEx()\Color\ScrollBar        = $C8C8C8
				TreeEx()\Color\Gadget           = $C8C8C8
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
				TreeEx()\Color\Border           = $8C8C8C
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
				    TreeEx()\Color\Border       = GetSysColor_(#COLOR_WINDOWFRAME)
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
        Box(X, Y, pbWidth, pbHeight, BlendColor_(TreeEx()\Color\ProgressFront, TreeEx()\Color\Gadget, 30))
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

	Procedure   DrawCheckBox_(X.i, Y.i, Height.i, boxSize.i, BackColor.i, State.i)
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

	Procedure   Draw_()
	  Define.f X, Y, Width, Height, TreeWidth, ColumnWidth, txtHeight, RowHeight, ImageWidth, ImageHeight, LineHeight
	  Define.f btY, txtX, txtY, OffsetX, OffsetY, LastX, LastY, LineY
	  Define.i Row, PageRows, VisibleRows, FrontColor, BackColor, CheckBoxSize, FontID
	  Define.i LevelWidth, NextLevel, LevelX, Level = 0
	  Define.f Factor
		Define.s Key$, Level$, Text$

		NewList Tree.Tree_Structure()
		NewMap  LineY.i()
		
		If TreeEx()\Hide : ProcedureReturn #False : EndIf
		
    TreeEx()\Row\OffSetY = 0
		
		Width  = dpiX(GadgetWidth(TreeEx()\CanvasNum))
		Height = dpiY(GadgetHeight(TreeEx()\CanvasNum))
		
		LineY = 0
		LineHeight = Height 
		
		If StartDrawing(CanvasOutput(TreeEx()\CanvasNum))
		  
		  PageRows = GetPageRows_()
		  
			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			Box(0, 0, Width, Height, TreeEx()\Color\Back) ; 
			;}
			
			FontID    = TreeEx()\FontID
			TreeWidth = TreeColumnWidth()

			;{ _____ Draw Header _____
			If TreeEx()\Flags & #ShowHeader
			  
			  RowHeight = dpiY(TreeEx()\Row\Header\Height)
			  
			  LineY = RowHeight
			  LineHeight - RowHeight
			  
			  DrawingMode(#PB_2DDrawing_Default)
			  Box(0, 0, dpiX(Width), RowHeight, TreeEx()\Color\HeaderBack)
			  
			  ForEach TreeEx()\Cols()
			    
			    If TreeEx()\Cols()\Header\FontID
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
			      If TreeEx()\Flags & #FitTreeColumn
			        If ColumnWidth < dpiX(TreeEx()\Col\TreeWidth) : ColumnWidth = dpiX(TreeEx()\Col\TreeWidth) : EndIf
			      EndIf  
			    EndIf
			    
			    ;{ ----- Column BackColor -----
			    If TreeEx()\Cols()\Header\Color\Back <> #PB_Default 
			      DrawingMode(#PB_2DDrawing_Default)
			      Box(X, 0, ColumnWidth, RowHeight, TreeEx()\Cols()\Header\Color\Back)
			    EndIf ;}
			    
			    ;{ ----- Cell Border -----
			    DrawingMode(#PB_2DDrawing_Outlined)                
			    If ListIndex(TreeEx()\Cols()) < ListSize(TreeEx()\Cols()) - 1
			      Box(X, 0, ColumnWidth + 1, RowHeight, TreeEx()\Color\HeaderBorder)
			      TreeEx()\Cols()\X = X
			    Else
			      Box(X, 0, ColumnWidth, RowHeight, TreeEx()\Color\HeaderBorder)
			      TreeEx()\Cols()\X = X
			    EndIf ;}
			    
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
  			    
  			    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
              ClipOutput(X, Y, ColumnWidth, RowHeight) 
            CompilerEndIf
            
  			    ;{ ----- Draw Text -----
  			    txtY = (RowHeight - TextHeight(TreeEx()\Cols()\Header\Title)) / 2

  			    DrawingMode(#PB_2DDrawing_Transparent)
  			    If TreeEx()\Cols()\Header\Color\Front <> #PB_Default
  			      DrawText(X + txtX, Y + txtY, TreeEx()\Cols()\Header\Title, TreeEx()\Cols()\Header\Color\Front)
  			    Else
  			      DrawText(X + txtX, Y + txtY, TreeEx()\Cols()\Header\Title, TreeEx()\Color\HeaderFront)
  			    EndIf ;}
  			    
  			    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
              UnclipOutput()
            CompilerEndIf
  			    
  			  EndIf
			  
			    X + ColumnWidth
			  Next
			  
			  Y = dpiY(TreeEx()\Row\Header\Height) 
			Else
			  Y = dpiY(2)
			EndIf ;}
			
		  Y + dpiY(2)
		  
		  RowHeight  = dpiY(TreeEx()\Row\Height)
		  LevelWidth = dpiX(#ButtonSize) + dpiX(5)
		  txtHeight  = TextHeight("Abc")
		  
			txtY = (RowHeight - txtHeight) / 2
			
			CheckBoxSize = txtHeight - dpiX(2)
			
			;{ _____ Draw Rows _____	
			VisibleRows = 0
			
			ForEach TreeEx()\Rows()

			  X = 0
			  
        TreeEx()\Rows()\Y = 0
			  TreeEx()\Rows()\Visible = #False
			  
			  BackColor = TreeEx()\Color\Back
			  
			  ;{ --- Reset Level & Button ---
			  TreeEx()\Rows()\Button\X = 0
			  TreeEx()\Rows()\Button\Y = 0
			  
			  If TreeEx()\Rows()\Level < Level : Level = TreeEx()\Rows()\Level : EndIf
			  ;}

			  If TreeEx()\Rows()\Level = Level And TreeEx()\Rows()\Button\State
			    Level = TreeEx()\Rows()\Level + 1
			  EndIf
			  
			  If TreeEx()\Rows()\Level > Level
			    TreeEx()\Rows()\Button\State = #False
			    Continue
			  EndIf
			  
			  VisibleRows + 1
			  
			  If VisibleRows <= TreeEx()\Row\Offset : Continue : EndIf
			  
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
			      btY  = (RowHeight - dpiY(#ButtonSize)) / 2
			      
			      If TreeEx()\Cols()\Width = #PB_Default : ColumnWidth = dpiX(TreeWidth) : EndIf
			      
			      If TreeEx()\Flags & #FitTreeColumn
			        If ColumnWidth < dpiX(TreeEx()\Col\TreeWidth) : ColumnWidth = dpiX(TreeEx()\Col\TreeWidth) : EndIf
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
      			
    			  If AddElement(Tree())
    			    Tree()\Level = TreeEx()\Rows()\Level
    			    Tree()\X     = X + OffsetX + dpiX(#ButtonSize / 2)
    			    Tree()\Y     = Y + (RowHeight / 2)
    			    If NextLevel = Tree()\Level + 1 : Tree()\Button = #True : EndIf
    			  EndIf  
    			  
    			  ;{ ----- Column BackColor -----
  			    If TreeEx()\Cols()\Color\Back <> #PB_Default 
  			      DrawingMode(#PB_2DDrawing_Default)
  			      BackColor = TreeEx()\Cols()\Color\Back
  			      Box(X, 0, ColumnWidth, RowHeight, BackColor)
  			    EndIf ;}
  			    
  			    ;{ ----- Focus -----
  			    If TreeEx()\Row\Focus = ListIndex(TreeEx()\Rows())
  			      DrawingMode(#PB_2DDrawing_Default)
  			      BackColor = BlendColor_(TreeEx()\Color\FocusBack, TreeEx()\Color\Back, 12)
  			      If TreeEx()\Flags & #SelectRow
  			        Box(TreeEx()\Rows()\Text\X - dpiX(3), Y + dpiX(2), ColumnWidth - TreeEx()\Rows()\Text\X + dpiX(3), RowHeight - dpiX(4), BackColor)
  			      Else
  			        Box(TreeEx()\Rows()\Text\X - dpiX(3), Y + dpiX(2), TreeEx()\Rows()\Text\Width + dpiX(6), RowHeight - dpiX(4), BackColor)
  			      EndIf  
    			  EndIf ;}
    			  
    			  TreeEx()\Rows()\Text\X = X + txtX + OffsetX
    			  
    			  If TreeEx()\Flags & #CheckBoxes
    			    DrawCheckBox_(TreeEx()\Rows()\Text\X, Y, RowHeight, CheckBoxSize, BackColor, TreeEx()\Rows()\State)
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
		          
		          OffsetX = TreeEx()\Rows()\Text\X + dpiX(3)
		          OffsetY = (RowHeight - ImageHeight) / 2
		          
		          If IsImage(TreeEx()\Rows()\Column(#Tree$)\Image\Num)
		            DrawingMode(#PB_2DDrawing_AlphaBlend)
		            DrawImage(ImageID(TreeEx()\Rows()\Column(#Tree$)\Image\Num), X + OffsetX, Y + OffsetY, ImageWidth, ImageHeight)
		          EndIf  
		          
		          TreeEx()\Rows()\Text\X + ImageWidth
		        EndIf 
		        
    			  TreeEx()\Rows()\Text\X + dpiX(5)
			      TreeEx()\Rows()\Text\Width = TextWidth(TreeEx()\Rows()\Column(#Tree$)\Value)
			      
			      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
              ClipOutput(TreeEx()\Rows()\Text\X, Y, ColumnWidth - TreeEx()\Rows()\Text\X, RowHeight) 
            CompilerEndIf
			      
    			  DrawingMode(#PB_2DDrawing_Transparent)
    			  If TreeEx()\Cols()\Color\Front <> #PB_Default
    			    DrawText(TreeEx()\Rows()\Text\X, Y + txtY, TreeEx()\Rows()\Column(#Tree$)\Value, TreeEx()\Cols()\Color\Front)
    			  Else  
    			    DrawText(TreeEx()\Rows()\Text\X, Y + txtY, TreeEx()\Rows()\Column(#Tree$)\Value, TreeEx()\Color\Front)
    			  EndIf
    			  
    			  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
              UnclipOutput()
            CompilerEndIf
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
    			  
    			  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
              ClipOutput(X, Y, ColumnWidth, RowHeight) 
            CompilerEndIf
    			  
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
    			  
    			  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
              UnclipOutput()
            CompilerEndIf
    			  
			      ;}
          EndIf 

          X + ColumnWidth
			  Next ;}

  			TreeEx()\Rows()\Y = Y
  			
  			If VisibleRows > PageRows : Break : EndIf
  			
			  Y + dpiY(TreeEx()\Row\Height)
  		Next ;}
  		
  		TreeEx()\Size\Cols = 0
  		ForEach TreeEx()\Cols()
  		  TreeEx()\Size\Cols + TreeEx()\Cols()\Width
  		Next
  		
  		;{ _____ Lines _____
  		If Not TreeEx()\Flags & #NoLines
    		ForEach Tree()
  
    		  If Tree()\Level < Level
    		    Level$ = Str(Level)
    		    LineXY(LevelX, LineY(Level$), LevelX, LastY, TreeEx()\Color\Line)
    		    LineY(Level$) = 0
    		  EndIf
    		  
    		  Level$ = Str(Tree()\Level)
    		  If LineY(Level$)
    		    LineXY(Tree()\X, LineY(Level$), Tree()\X, Tree()\Y, TreeEx()\Color\Line)
    		    LineY(Level$) = Tree()\Y
    		  Else
    		    LineY(Level$) = Tree()\Y
    		  EndIf
    		  
    		  If Tree()\Level > Level
  		      LineXY(LevelX, Tree()\Y, Tree()\X, Tree()\Y, TreeEx()\Color\Line)
  		    EndIf
    		  
  		    If Tree()\Button
    		    Level  = Tree()\Level
    		    LevelX = Tree()\X
    		    Line(Tree()\X, Tree()\Y, dpiX(4), 1, TreeEx()\Color\Line)
    		  Else
    		    If Tree()\Level > Level : LineY(Level$) = 0 : EndIf
    		  EndIf
  
    		  LastX = Tree()\X
    		  LastY = Tree()\Y
    		  
    		Next  
  		
    		If LastElement(Tree())
    		  If Tree()\Level > Level
    		    Level$ = Str(Level)
    		    LineXY(LevelX, LineY(Level$), LevelX, Tree()\Y, TreeEx()\Color\Line)
    	    EndIf
    	  EndIf
    	  
    	EndIf
    	
    	If TreeEx()\Flags & #ColumnLines
    	  ForEach TreeEx()\Cols()
    	    Line(TreeEx()\Cols()\X, LineY, 1, LineHeight, TreeEx()\Color\HeaderBorder)
    	  Next 
    	  Line(TreeEx()\Cols()\X + TreeEx()\Cols()\Width - 1, LineY, 1, LineHeight, TreeEx()\Color\HeaderBorder)
	    EndIf
    	;}
  	  
  	  ;{ _____ Buttons _____
  	  If Not TreeEx()\Flags & #NoButtons
    	  ForEach TreeEx()\Rows()
    	    If TreeEx()\Rows()\Button\X And TreeEx()\Rows()\Button\Y
    	      DrawButton_(TreeEx()\Rows()\Button\X, TreeEx()\Rows()\Button\Y, TreeEx()\Rows()\Button\State)
    	    EndIf  
    	  Next
  	  EndIf ;}

			;{ _____ Border ____
			If Not TreeEx()\Flags & #Borderless
				DrawingMode(#PB_2DDrawing_Outlined)
				Box(0, 0, Width, Height, TreeEx()\Color\Border)
			EndIf ;}

			StopDrawing()
		EndIf

	EndProcedure
	
	Procedure   ReDraw_()
	  
	  CalcRows()
	  
	  If TreeEx()\Flags & #FitTreeColumn : CalcTreeWidth() : EndIf 
	  
	  AdjustScrollBars_()
	  
	  Draw_()
	  
	EndProcedure
	
	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Procedure _ThemeHandler()

      ForEach TreeEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          TreeEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
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
				
        ReDraw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
  
	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(TreeEx(), Str(GNum))

			X = GetGadgetAttribute(TreeEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(TreeEx()\CanvasNum, #PB_Canvas_MouseY)
			
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
			    If Y >= TreeEx()\Rows()\Y And Y <= TreeEx()\Rows()\Y + TreeEx()\Row\Height
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

	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(TreeEx(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)



			;TreeEx()\ToolTip = #False
			;GadgetToolTip(GNum, "")

			;SetGadgetAttribute(GNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure
	
	Procedure _MouseLeaveHandler()
	  Define.i GNum = EventGadget()

	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    If Not TreeEx()\Flags & #AlwaysShowSelection
	      TreeEx()\Row\Focus = #PB_Default
	      ReDraw_()
	    EndIf
	    
	  EndIf 
	EndProcedure
	
	Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta
    Define.f ScrollPos
    
    If FindMapElement(TreeEx(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(TreeEx()\VScrollNum) And TreeEx()\VScroll\Hide = #False
        
        ScrollPos = GetGadgetState(TreeEx()\VScrollNum) - Delta
        
        If ScrollPos > TreeEx()\VScroll\MaxPos : ScrollPos = TreeEx()\VScroll\MaxPos : EndIf
        If ScrollPos < TreeEx()\VScroll\MinPos : ScrollPos = TreeEx()\VScroll\MinPos : EndIf
        
        If ScrollPos <> TreeEx()\VScroll\Position
          
          TreeEx()\Row\Offset = ScrollPos
          SetVScrollPosition_()
          
          ReDraw_()          
        EndIf

      EndIf

    EndIf
    
  EndProcedure
	
	Procedure _SynchronizeScrollCols()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.f ScrollPos
    
    If FindMapElement(TreeEx(), Str(GadgetNum))
      
      ScrollPos = GetGadgetState(ScrollNum)
      If ScrollPos <> TreeEx()\HScroll\Position
        
        If ScrollPos < TreeEx()\Col\OffsetX
          TreeEx()\Col\OffsetX = ScrollPos
        ElseIf ScrollPos > TreeEx()\Col\OffsetX
          TreeEx()\Col\OffsetX = ScrollPos
        EndIf
        
        If TreeEx()\Col\OffsetX < TreeEx()\HScroll\MinPos : TreeEx()\Col\OffsetX = TreeEx()\HScroll\MinPos : EndIf
        If TreeEx()\Col\OffsetX > TreeEx()\HScroll\MaxPos : TreeEx()\Col\OffsetX = TreeEx()\HScroll\MaxPos : EndIf
        
        SetGadgetState(ScrollNum, TreeEx()\Col\OffsetX)
        SetHScrollPosition_()

        ReDraw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _SynchronizeScrollRows()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.f X, Y, ScrollPos
    
    If FindMapElement(TreeEx(), Str(GadgetNum))
      
      ScrollPos = GetGadgetState(ScrollNum)
      Debug "ScrollPos: " + Str(ScrollPos)
      If ScrollPos <> TreeEx()\VScroll\Position
        
        TreeEx()\Row\Offset = ScrollPos 

        SetVScrollPosition_()

        ReDraw_()
      EndIf
      
    EndIf
    
  EndProcedure 
	
  Procedure _ResizeHandler()
    Define.i OffsetX, OffSetY
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(TreeEx(), Str(GadgetNum))
      
      If TreeEx()\VScroll\Hide = #False Or TreeEx()\HScroll\Hide = #False
        
        If TreeEx()\VScroll\Hide
          ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - 1, #ScrollBarSize - 1)
        Else
          ResizeGadget(TreeEx()\HScrollNum, 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize - 1, #ScrollBarSize - 1)
        EndIf
        
        If TreeEx()\HScroll\Hide
          ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - 2)
        Else  
          ResizeGadget(TreeEx()\VScrollNum, GadgetWidth(TreeEx()\CanvasNum) - #ScrollBarSize, 1, #ScrollBarSize - 1, GadgetHeight(TreeEx()\CanvasNum) - #ScrollBarSize - 2)
        EndIf
        
      EndIf

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

	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
	
	Procedure.i AddColumn(GNum.i, Column.i, Width.f, Title.s="", Label.s="", Flags.i=#False)
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
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Container)
    EndIf
		
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(TreeEx(), Str(GNum))

				TreeEx()\CanvasNum = GNum
				
				TreeEx()\HScrollNum = ScrollBarGadget(#PB_Any, 0, 0, 0, 0, 0, 0, 0)
        If IsGadget(TreeEx()\HScrollNum)
          SetGadgetData(TreeEx()\HScrollNum, TreeEx()\CanvasNum)
          TreeEx()\HScroll\Hide = #True
          HideGadget(TreeEx()\HScrollNum, #True)
        EndIf
        
        TreeEx()\VScrollNum = ScrollBarGadget(#PB_Any, 0, 0, 0, 0, 0, 0, 0, #PB_ScrollBar_Vertical)
        If IsGadget(TreeEx()\VScrollNum)
          SetGadgetData(TreeEx()\VScrollNum, TreeEx()\CanvasNum)
          TreeEx()\VScroll\Hide = #True
          HideGadget(TreeEx()\VScrollNum, #True)
        EndIf
        
        CloseGadgetList()
        
				CompilerIf Defined(ModuleEx, #PB_Module) ; WindowNum = #Default
					If WindowNum = #PB_Default
						TreeEx()\Window\Num = ModuleEx::GetGadgetWindow()
					Else
						TreeEx()\Window\Num = WindowNum
					EndIf
				CompilerElse
					If WindowNum = #PB_Default
						TreeEx()\Window\Num = GetActiveWindow()
					Else
						TreeEx()\Window\Num = WindowNum
					EndIf
				CompilerEndIf

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
				  TreeEx()\Cols()\Key               = #Tree$
				  TreeEx()\Cols()\Flags             = #Tree
				  TreeEx()\Cols()\Width             = #PB_Default
				  TreeEx()\Cols()\Color\Front       = #PB_Default
				  TreeEx()\Cols()\Color\Back        = #PB_Default
				  TreeEx()\Cols()\Color\Border      = #PB_Default
				  TreeEx()\Cols()\Header\Title      = Title
				  TreeEx()\Cols()\Header\FontID     = #PB_Default
          TreeEx()\Cols()\Header\Color\Front = #PB_Default
          TreeEx()\Cols()\Header\Color\Back  = #PB_Default
				EndIf	;}	
				
				BindGadgetEvent(TreeEx()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent(TreeEx()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
				BindGadgetEvent(TreeEx()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
				BindGadgetEvent(TreeEx()\CanvasNum,  @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
				BindGadgetEvent(TreeEx()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
				BindGadgetEvent(TreeEx()\HScrollNum, @_SynchronizeScrollCols(),  #PB_All)
        BindGadgetEvent(TreeEx()\VScrollNum, @_SynchronizeScrollRows(),  #PB_All) 
				
				
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
	  Define.i ImageID
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
	    EndIf
  	  
	  EndIf  
	 
	EndProcedure
	
	
	Procedure   SetState(GNum.i, State.i)
	  
	  If FindMapElement(TreeEx(), Str(GNum))
	    
	    TreeEx()\Row\Focus = State
	    
	    If TreeEx()\ReDraw : ReDraw_() : EndIf
	  EndIf
	  
	EndProcedure
	
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()

  Enumeration 
    #Window
    #Button
    #TreeEx
    #Image
    #Font
  EndEnumeration
  
  LoadFont(#Font, "Arial", 8, #PB_Font_Bold)
  LoadImage(#Image, "test.png")
  
  If OpenWindow(#Window, 0, 0, 300, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If TreeEx::Gadget(#TreeEx, 10, 10, 280, 180, "Tree", TreeEx::#ShowHeader|TreeEx::#CheckBoxes|TreeEx::#ColumnLines|TreeEx::#FitTreeColumn|TreeEx::#AutoResize, #Window) ; |TreeEx::#SelectRow|TreeEx::#NoButtons|TreeEx::#NoLines
      
      TreeEx::AddColumn(#TreeEx, TreeEx::#LastColumn, 24, "",         "image",    TreeEx::#Image)
      TreeEx::AddColumn(#TreeEx, TreeEx::#LastColumn, 50, "Number",   "number",   TreeEx::#Right)    
      TreeEx::AddColumn(#TreeEx, TreeEx::#LastColumn, 80, "Progress", "progress", TreeEx::#ProgressBar|TreeEx::#ShowPercent)
      
      TreeEx::SetHeaderAttribute(#TreeEx, TreeEx::#Align, TreeEx::#Center, 2)
      TreeEx::SetHeaderFont(#TreeEx, FontID(#Font))
      
      ;TreeEx::SetFont(#TreeEx, FontID(#Font), 3)
      
      ; _____ Add content _____
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "Item" + #LF$ + #LF$ + "1")
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1",   "", #False, 1)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1.1", "", #False, 2)
      TreeEx::AddItem(#TreeEx, TreeEx::#LastRow, "SubItem" + #LF$ + #LF$ + "1.1.2", "", #False, 2)
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
    
    TreeEx::SetItemState(#TreeEx, 4, TreeEx::#Expanded)
    
    ;TreeEx::SetColorTheme(#TreeEx, TreeEx::#Theme_Green)
    
    ; ModuleEx::SetTheme(ModuleEx::#Theme_DarkBlue)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case TreeEx::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #TreeEx
              Select EventType()
                Case TreeEx::#EventType_Row      ; Select row
                  Debug "Row seleced: " + Str(EventData())
                Case TreeEx::#EventType_CheckBox ; Checkbox click
                  Debug "CheckBox clicked"
                Case TreeEx::#EventType_Collapsed
                  Debug "Collapsed: " + Str(EventData())
                Case TreeEx::#EventType_Expanded
                  Debug "Expanded: " + Str(EventData())
                  ;}
              EndSelect
          EndSelect ;}
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 1332
; FirstLine = 539
; Folding = 96IAABIAQqhGDjlOAEABBAAGgh-
; EnableXP
; DPIAware