;/ ==================================
;/ =    MarkupLanguageModule.pbi    =
;/ ==================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/  Gadget to display markup languages
;/
;/ © 2019  by Thorsten Hoeppner (12/2019)
;/

; Last Update:


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


;{ _____ MarkUp - Commands _____

; MarkUp::Clear()              - similar to 'ClearGadgetItems()'
; MarkUp::EventValue()         - returns links
; MarkUp::Gadget()             - new markup gadget
; MarkUp::GetData()            - similar to 'GetGadgetData()'
; MarkUp::GetID()              - similar to 'GetGadgetData()', but string
; MarkUp::Hide()               - similar to 'HideGadget()'
; MarkUp::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; MarkUp::SetAttribute()       - similar to 'SetGadgetAttribute()'
; MarkUp::SetColor()           - similar to 'SetGadgetColor()'
; MarkUp::SetData()            - similar to 'SetGadgetData()'
; MarkUp::SetFont()            - similar to 'SetGadgetFont()'
; MarkUp::SetID()              - similar to 'SetGadgetData()', but string
; MarkUp::SetText()            - similar to 'SetGadgetText()'

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule MarkUp
  
  #Version  = 19122600
  #ModuleEx = 19112100
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  #Enable_MarkDown = #True
  #Enable_BBCode   = #False
  
  ;{ _____ Constants _____
  #Bullet$ = "•"
  
	EnumerationBinary ;{ GadgetFlags
		#AutoResize        ; Automatic resizing of the gadget
		#Borderless        ; Draw no border
		#ToolTips          ; Show tooltips
		#UseExistingCanvas ; e.g. for dialogs
	EndEnumeration ;}
	
	Enumeration 1 ;{ Parse
	  #MarkDown
	  #BBCode
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
  Declare.s EventValue(GNum.i)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.q GetData(GNum.i)
  Declare.s GetID(GNum.i)
  Declare   Hide(GNum.i, State.i=#True) 
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, Name.s, Size.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetText(GNum.i, Text.s, Type.i=#MarkDown)
  
EndDeclareModule

Module MarkUp

	EnableExplicit
	
	UsePNGImageDecoder()
	UseJPEGImageDecoder()
	
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
	
  Enumeration 1 ;{ MarkUp
    #Bold
    #BoldItalic
    #Code
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
    #Table
    #Text
    #URL
  EndEnumeration ;}

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================	
	
  Structure Footnote_Structure         ;{ MarkUp()\Footnote()\...
    Note.s
    String.s
  EndStructure ;}

  Structure Image_Structure            ;{ MarkUp()\Image()\...
    Num.i
    Width.i
    Height.i
    Source.s
    Title.s
  EndStructure ;}
  
  Structure Link_Structure             ;{ MarkUp()\Link()\...
    X.i
    Y.i
    Width.i
    Height.i
    URL.s
    Title.s
    State.i
  EndStructure ;}
  
  Structure Item_Structure             ;{ MarkUp()\Row()\Item()\...
    Type.i
    String.s
    Level.i
    Index.i
  EndStructure ;}
  
  Structure Row_Structure              ;{ MarkUp()\Row()\...
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
  
  
  Structure MarkUp_Required_Structure  ;{ MarkUp()\Required\...
    Width.i
    Height.i
  EndStructure ;}
  
  Structure MarkUp_Font_Structure      ;{ MarkUp()\Font\...
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
	
	Structure MarkUp_Margin_Structure    ;{ MarkUp()\Margin\...
		Top.i
		Left.i
		Right.i
		Bottom.i
	EndStructure ;}
	
	Structure MarkUp_Color_Structure     ;{ MarkUp()\Color\...
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
	
	Structure MarkUp_Scroll_Structure    ;{ MarkUp()\Scroll\...
	  Num.i
	  MinPos.i
    MaxPos.i
    Offset.i
    Height.i
    Hide.i
  EndStructure ;}
	
	Structure MarkUp_Window_Structure    ;{ MarkUp()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure MarkUp_Size_Structure      ;{ MarkUp()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}


	Structure MarkUp_Structure           ;{ MarkUp()\...
		CanvasNum.i
		PopupNum.i
		
		ID.s
		Quad.i

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

		Color.MarkUp_Color_Structure
		Font.MarkUp_Font_Structure
		Margin.MarkUp_Margin_Structure
		Required.MarkUp_Required_Structure
		Size.MarkUp_Size_Structure
		Scroll.MarkUp_Scroll_Structure
		Window.MarkUp_Window_Structure

    Map  FootIdx.i()
    List Footnote.Footnote_Structure()
    List Image.Image_Structure()
    List Link.Link_Structure()
    List Row.Row_Structure()
		
	EndStructure ;}
	Global NewMap MarkUp.MarkUp_Structure()

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
	
	
	Procedure   FreeFonts_()
	  
	  If IsFont(MarkUp()\Font\Normal)       : FreeFont(MarkUp()\Font\Normal)       : EndIf
	  If IsFont(MarkUp()\Font\Bold)         : FreeFont( MarkUp()\Font\Bold)        : EndIf
	  If IsFont(MarkUp()\Font\Italic)       : FreeFont(MarkUp()\Font\Italic)       : EndIf
	  If IsFont(MarkUp()\Font\BoldItalic)   : FreeFont(MarkUp()\Font\BoldItalic)   : EndIf
	  If IsFont(MarkUp()\Font\Code)         : FreeFont(MarkUp()\Font\Code)         : EndIf
	  If IsFont(MarkUp()\Font\FootNote)     : FreeFont(MarkUp()\Font\FootNote)     : EndIf
	  If IsFont(MarkUp()\Font\FootNoteText) : FreeFont(MarkUp()\Font\FootNoteText) : EndIf
	  
	  If IsFont(MarkUp()\Font\H6) : FreeFont(MarkUp()\Font\H6) : EndIf
	  If IsFont(MarkUp()\Font\H5) : FreeFont(MarkUp()\Font\H5) : EndIf
	  If IsFont(MarkUp()\Font\H4) : FreeFont(MarkUp()\Font\H4) : EndIf
	  If IsFont(MarkUp()\Font\H3) : FreeFont(MarkUp()\Font\H3) : EndIf
	  If IsFont(MarkUp()\Font\H2) : FreeFont(MarkUp()\Font\H2) : EndIf
	  If IsFont(MarkUp()\Font\H1) : FreeFont(MarkUp()\Font\H1) : EndIf
	  
	EndProcedure
	
	Procedure   LoadFonts_(Name.s, Size.i)

	  MarkUp()\Font\Normal     = LoadFont(#PB_Any, Name, Size)
	  MarkUp()\Font\Bold       = LoadFont(#PB_Any, Name, Size, #PB_Font_Bold)
	  MarkUp()\Font\Italic     = LoadFont(#PB_Any, Name, Size, #PB_Font_Italic)
	  MarkUp()\Font\BoldItalic = LoadFont(#PB_Any, Name, Size, #PB_Font_Bold|#PB_Font_Italic)
	  MarkUp()\Font\Code       = LoadFont(#PB_Any, "Courier New", Size)
	  
	  MarkUp()\Font\FootNote     = LoadFont(#PB_Any, Name, Round(Size / 1.5, #PB_Round_Up))
	  MarkUp()\Font\FootNoteText = LoadFont(#PB_Any, Name, Size - 2)
	  
	  MarkUp()\Font\H6 = LoadFont(#PB_Any, Name, Size + 1, #PB_Font_Bold)
	  MarkUp()\Font\H5 = LoadFont(#PB_Any, Name, Size + 2, #PB_Font_Bold)
	  MarkUp()\Font\H4 = LoadFont(#PB_Any, Name, Size + 3, #PB_Font_Bold)
	  MarkUp()\Font\H3 = LoadFont(#PB_Any, Name, Size + 4, #PB_Font_Bold)
	  MarkUp()\Font\H2 = LoadFont(#PB_Any, Name, Size + 5, #PB_Font_Bold)
	  MarkUp()\Font\H1 = LoadFont(#PB_Any, Name, Size + 6, #PB_Font_Bold)
	  
	EndProcedure
	
	Procedure.i AdjustScrollBars_()
	  Define.i Height
	  
	  If IsGadget(MarkUp()\Scroll\Num)
	    
	    Height = GadgetHeight(MarkUp()\CanvasNum) 
	    
	    If MarkUp()\Required\Height > Height
	      
	      If MarkUp()\Scroll\Hide
	        
	        ResizeGadget(MarkUp()\Scroll\Num, GadgetWidth(MarkUp()\CanvasNum) - #ScrollBarSize - 1, 1, #ScrollBarSize, GadgetHeight(MarkUp()\CanvasNum) - 2)
	        
	        SetGadgetAttribute(MarkUp()\Scroll\Num, #PB_ScrollBar_Minimum,    0)
          SetGadgetAttribute(MarkUp()\Scroll\Num, #PB_ScrollBar_Maximum,    MarkUp()\Required\Height)
          SetGadgetAttribute(MarkUp()\Scroll\Num, #PB_ScrollBar_PageLength, Height)
          
          MarkUp()\Scroll\MinPos = 0
          MarkUp()\Scroll\MaxPos = MarkUp()\Required\Height - Height + 1
          
          HideGadget(MarkUp()\Scroll\Num, #False)
          
          MarkUp()\Scroll\Hide = #False
          
          ProcedureReturn #True
        Else 
          
          ResizeGadget(MarkUp()\Scroll\Num, GadgetWidth(MarkUp()\CanvasNum) - #ScrollBarSize - 1, 1, #ScrollBarSize, GadgetHeight(MarkUp()\CanvasNum) - 2)
          
          SetGadgetAttribute(MarkUp()\Scroll\Num, #PB_ScrollBar_Maximum,    MarkUp()\Required\Height)
          SetGadgetAttribute(MarkUp()\Scroll\Num, #PB_ScrollBar_PageLength, Height)
          
          MarkUp()\Scroll\MaxPos = MarkUp()\Required\Height - Height + 1
          
          ProcedureReturn #True
	      EndIf   
	      
	    Else
	      
	      If MarkUp()\Scroll\Hide = #False
	        HideGadget(MarkUp()\Scroll\Num, #True)
	        MarkUp()\Scroll\Hide = #True
	      EndIf  
	      
	      ProcedureReturn #True
	    EndIf
	    
	  EndIf
	  
	  ProcedureReturn #False
	EndProcedure  

	Procedure   Clear_()
	  
	  ClearMap(MarkUp()\FootIdx())
	  ClearList(MarkUp()\Footnote())
	  ClearList(MarkUp()\Image())
	  ClearList(MarkUp()\Link())
	  ClearList(MarkUp()\Row())

	EndProcedure
	
	Procedure   AddText_(Row.s, BQ.i)
    
    If ListSize(MarkUp()\Row()) = 0 Or MarkUp()\Row()\Type <> #Text
      If AddElement(MarkUp()\Row())
        MarkUp()\Row()\Type       = #Text
        MarkUp()\Row()\String     = Row
        MarkUp()\Row()\BlockQuote = BQ
      Else
        If AddElement(MarkUp()\Row()\Item())
          MarkUp()\Row()\Item()\Type   = #Text
          MarkUp()\Row()\Item()\String = Row
        EndIf   
      EndIf
    EndIf
    
  EndProcedure
  
  
  ;- __________ MarkDown __________
  
  CompilerIf #Enable_MarkDown
  
    Procedure.i Footnote_(Row.s, sPos.i)
      Define.s Note$
      Define.i ePos
    
      ePos = FindString(Row, "]:", sPos + 2)
      If ePos
        Note$ = Mid(Row, sPos + 2, ePos - sPos - 2)
        If AddElement(MarkUp()\FootNote())
          MarkUp()\FootNote()\Note   = Note$
          MarkUp()\FootNote()\String = Mid(Row, ePos + 2)
          MarkUp()\FootIdx(Note$) = ListIndex(MarkUp()\FootNote())
        EndIf
        ePos = Len(Row)
      Else
        ePos = FindString(Row, "]", sPos + 2)
        If AddElement(MarkUp()\Row()\Item())
          MarkUp()\Row()\Item()\Type   = #FootNote
          MarkUp()\Row()\Item()\String = Mid(Row, sPos + 2, ePos - sPos - 2)
        EndIf
      EndIf
      
      ProcedureReturn ePos
    EndProcedure
    
    Procedure   Image_(Row.s, sPos.i) 
      Define.i ePos
      Define.s Image$
      
      MarkUp()\Row()\Type = #Image
      
      ePos = FindString(Row, "]", sPos + 1)
      MarkUp()\Row()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
      
      sPos = FindString(Row, "(", ePos + 1)
      ePos = FindString(Row, ")", sPos + 1)
      
      Image$ = Mid(Row, sPos + 1, ePos - sPos - 1)
      
      If AddElement(MarkUp()\Image())
        MarkUp()\Row()\Index    = ListIndex(MarkUp()\Image())
        MarkUp()\Image()\Source = StringField(Image$, 1, " " + #DQUOTE$)
        MarkUp()\Image()\Title  = RTrim(StringField(Image$, 2, " " + #DQUOTE$), #DQUOTE$)
      EndIf 
    
    EndProcedure
    
    Procedure.i TextImage_(Row.s, sPos.i) 
      Define.i ePos
      Define.s Image$
      
      MarkUp()\Row()\Item()\Type = #Image
      
      ePos = FindString(Row, "]", sPos + 1)
      MarkUp()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
      
      sPos = FindString(Row, "(", ePos + 1)
      ePos = FindString(Row, ")", sPos + 1)
      
      Image$ = Mid(Row, sPos + 1, ePos - sPos - 1)
      
      If AddElement(MarkUp()\Image())
        MarkUp()\Row()\Item()\Index = ListIndex(MarkUp()\Image())
        MarkUp()\Image()\Source = StringField(Image$, 1, " " + #DQUOTE$)
        MarkUp()\Image()\Title  = RTrim(StringField(Image$, 2, " " + #DQUOTE$), #DQUOTE$)
      EndIf 
    
      ProcedureReturn ePos
    EndProcedure
    
    Procedure.i Link_(Row.s, sPos.i) 
      Define.i ePos
      Define.s Link$
      
      MarkUp()\Row()\Item()\Type = #Link
      
      ePos = FindString(Row, "]", sPos + 1)
      MarkUp()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
      
      sPos = FindString(Row, "(", ePos + 1)
      ePos = FindString(Row, ")", sPos + 1)
      
      Link$ = Mid(Row, sPos + 1, ePos - sPos - 1)
      
      If AddElement(MarkUp()\Link())
        MarkUp()\Row()\Item()\Index = ListIndex(MarkUp()\Link())
        MarkUp()\Link()\URL   = StringField(Link$, 1, " " + #DQUOTE$)
        MarkUp()\Link()\Title = RTrim(StringField(Link$, 2, " " + #DQUOTE$), #DQUOTE$)
      EndIf
    
      ProcedureReturn ePos
    EndProcedure
    
    Procedure.i URL_(Row.s, sPos.i) 
      Define.i ePos
      
      MarkUp()\Row()\Item()\Type = #URL
      
      ePos = FindString(Row, ">", sPos + 1)
      
      ProcedureReturn ePos
    EndProcedure
    
    Procedure.i Code_(Row.s, sPos.i) 
      Define.i ePos
      
      MarkUp()\Row()\Item()\Type = #Code
      
      ePos = FindString(Row, "`", sPos + 1)
    
      ProcedureReturn ePos
    EndProcedure
    
    Procedure.i Headings_(Row.s, sPos.i) 
      Define.i ePos
      
      MarkUp()\Row()\Type = #Heading
      
      If Mid(Row, sPos, 6) = "######"
        MarkUp()\Row()\Level = 6
        ePos = FindString(Row, "######", sPos + 6)
        If ePos : ProcedureReturn ePos + 5 : EndIf
      ElseIf Mid(Row, sPos, 5) = "#####"
        MarkUp()\Row()\Level = 5
        ePos = FindString(Row, "#####", sPos + 5)
        If ePos : ProcedureReturn ePos + 4 : EndIf
      ElseIf Mid(Row, sPos, 4) = "####"
        MarkUp()\Row()\Level = 4
        ePos = FindString(Row, "####", sPos + 4)
        If ePos : ProcedureReturn ePos + 3 : EndIf
      ElseIf Mid(Row, sPos, 3) = "###"
        MarkUp()\Row()\Level = 3
        ePos = FindString(Row, "###", sPos + 3)
        If ePos : ProcedureReturn ePos + 2 : EndIf
      ElseIf Mid(Row, sPos, 2) = "##"  
        MarkUp()\Row()\Level = 2
        ePos = FindString(Row, "##", sPos + 2)
        If ePos : ProcedureReturn ePos + 1 : EndIf
      Else
        MarkUp()\Row()\Level = 1
        ePos = FindString(Row, "#", sPos + 1)
        If ePos : ProcedureReturn ePos : EndIf
      EndIf
    
      ProcedureReturn Len(Row)
    EndProcedure
    
    Procedure.i Emphasis_(Row.s, sPos.i)
      Define.i ePos
    
      If Mid(Row, sPos, 3) = "***"
        MarkUp()\Row()\Item()\Type = #BoldItalic
        ePos = FindString(Row, "***", sPos + 3)
        MarkUp()\Row()\Item()\String = Mid(Row, sPos + 3, ePos - sPos - 3)
        ProcedureReturn ePos + 2
      ElseIf Mid(Row, sPos, 2) = "**"
        MarkUp()\Row()\Item()\Type = #Bold
        ePos = FindString(Row, "**", sPos + 2)
        MarkUp()\Row()\Item()\String = Mid(Row, sPos + 2, ePos - sPos - 2)
        ProcedureReturn ePos + 1
      Else 
        MarkUp()\Row()\Item()\Type = #Italic
        ePos = FindString(Row, "*", sPos + 1)
        MarkUp()\Row()\Item()\String = Mid(Row, sPos + 1, ePos - sPos - 1)
        ProcedureReturn ePos
      EndIf  
      
    EndProcedure
    
    
    Procedure   ParseMarkDown_(Text.s)
      Define.i r, Rows, c, Cols, Length, Pos, sPos, ePos, BQ, newRow, LineBreak, Type
      Define.s Row$, Num$, trimRow$, Col$, Text$
      
      Text = ReplaceString(Text, #CRLF$, #LF$)
      Text = ReplaceString(Text, #CR$, #LF$)
      Text = ReplaceString(Text, "_", "*")
    
      Rows = CountString(Text, #LF$) + 1
      
      For r = 1 To Rows
        
        newRow = 0 : Pos = 1 : sPos = 1 : BQ = 0
        
        Row$   = StringField(Text, r, #LF$)
        Length = Len(Row$)
        
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
       
            If AddElement(MarkUp()\Row())
              ePos = Headings_(Row$, sPos)
              MarkUp()\Row()\String = Trim(RemoveString(Mid(Row$, Pos, ePos - Pos + 1), "#"))
              MarkUp()\Row()\BlockQuote = BQ
              If ePos : Pos = ePos : EndIf
            EndIf
            ;}        
          Case "="         ;{ Heading level 1
            
            If ListSize(MarkUp()\Row()) And MarkUp()\Row()\Type = #Text And CountString(Row$, "=") = Len(Row$)
              MarkUp()\Row()\Type  = #Heading
              MarkUp()\Row()\Level = 1
            Else
              AddText_(Row$, BQ)
            EndIf
            ;}
          Case "-"         ;{ Heading level 2 / Unordered Lists
            
            If CountString(Row$, "-") = Len(Row$) ;{ Heading level 2
              
              If ListSize(MarkUp()\Row()) : Type = MarkUp()\Row()\Type : EndIf
  
              Select Type
                Case #Text
                  
                  If ListSize(MarkUp()\Row()\Item())
                    MarkUp()\Row()\Type = #LineBreak
                    LastElement(MarkUp()\Row()\Item())
                    Text$ = MarkUp()\Row()\Item()\String
                    DeleteElement(MarkUp()\Row()\Item())
                    If AddElement(MarkUp()\Row())
                      MarkUp()\Row()\String = Text$
                    EndIf  
                  EndIf
                  
                  MarkUp()\Row()\Type  = #Heading
                  MarkUp()\Row()\Level = 2
                  
                Default
                  
                  If AddElement(MarkUp()\Row())
                    MarkUp()\Row()\Type = #HLine
                  EndIf 
                  
              EndSelect  
              ;}
            Else                                  ;{ Unordered Lists
              
              If Left(Row$, 2) = "- "
                
                If ListSize(MarkUp()\Row()) = #False Or (MarkUp()\Row()\Type <> #List And MarkUp()\Row()\Type <> #OrderedList)
                  AddElement(MarkUp()\Row())
                  MarkUp()\Row()\Type = #List
                  MarkUp()\Row()\BlockQuote = BQ
                EndIf  
                
                If AddElement(MarkUp()\Row()\Item())
                  MarkUp()\Row()\Item()\Type   = #List
                  MarkUp()\Row()\Item()\String = LTrim(Mid(Row$, 3))
                  MarkUp()\Row()\Item()\Level  = 0
                EndIf
                
              Else
                AddText_(Row$, BQ)
              EndIf  
              ;}
            EndIf  
            ;}  
          Case "*", "+"    ;{ Unordered Lists
    
            If Left(Row$, 2) = "* " Or Left(Row$, 2) = "+ "
              
              If ListSize(MarkUp()\Row()) = #False Or (MarkUp()\Row()\Type <> #List And MarkUp()\Row()\Type <> #OrderedList)
                AddElement(MarkUp()\Row())
                MarkUp()\Row()\Type = #List
                MarkUp()\Row()\BlockQuote = BQ
              EndIf  
              
              If AddElement(MarkUp()\Row()\Item())
                MarkUp()\Row()\Item()\Type   = #List
                MarkUp()\Row()\Item()\String = LTrim(Mid(Row$, 3))
                MarkUp()\Row()\Item()\Level  = 0
              EndIf
              
            ElseIf CountString(Row$, Left(Row$, 1)) = Len(Row$)
              
              MarkUp()\Row()\Type = #HLine
              
            Else
              
              If AddElement(MarkUp()\Row()\Item())
                MarkUp()\Row()\Item()\Type = #Text
                MarkUp()\Row()\String      = Row$
              EndIf
              
            EndIf  
            ;}
          Case "1", "2", "3", "4", "5", "6", "7", "8", "9" ;{ Ordered List
            
            Num$ = StringField(Row$, 1, " ")
            If Right(Num$, 1) = "."
              
              If ListSize(MarkUp()\Row()) = #False Or (MarkUp()\Row()\Type <> #List And MarkUp()\Row()\Type <> #OrderedList)
                AddElement(MarkUp()\Row())
                MarkUp()\Row()\Type = #OrderedList
                MarkUp()\Row()\BlockQuote = BQ
              EndIf  
              
              If AddElement(MarkUp()\Row()\Item())
                MarkUp()\Row()\Item()\Type   = #OrderedList
                MarkUp()\Row()\Item()\String = Mid(Row$, Len(Num$) + 1)
                MarkUp()\Row()\Item()\Level  = 0
              EndIf
              
            Else
              
              If AddElement(MarkUp()\Row()\Item())
                MarkUp()\Row()\Item()\Type = #Text
                MarkUp()\Row()\String      = Row$
              EndIf 
              
            EndIf
            
            ; TODO: Parse remaining text 
            
            ;}
          Case "!"         ;{ Image
            
            If Mid(Row$, Pos, 2) = "!["
              If AddElement(MarkUp()\Row())
                Image_(Row$, Pos + 1)
              EndIf
            EndIf
            ;}
          Case "|"         ;{ Table
            
            If ListSize(MarkUp()\Row()) = 0 Or MarkUp()\Row()\Type <> #Table
              AddElement(MarkUp()\Row())
              MarkUp()\Row()\Type = #Table
              MarkUp()\Row()\BlockQuote = BQ
            EndIf
            
            trimRow$ = Trim(RTrim(Mid(Row$, 2), "|"))
            
            If Left(trimRow$, 3) = "---" Or Left(trimRow$, 4) = ":---" ;{ Header 
              If FirstElement(MarkUp()\Row()\Item())
                MarkUp()\Row()\Item()\Type = #Header
                MarkUp()\Row()\String = ""
                Cols = CountString(trimRow$, "|") + 1
                For c=1 To Cols
                  Col$ = Trim(StringField(trimRow$, c, "|"))
                  If Left(Col$, 1) = ":" And Right(Col$, 1) = ":"
                    MarkUp()\Row()\String + "C|"
                  ElseIf Right(Col$, 1) = ":"
                    MarkUp()\Row()\String + "R|"
                  Else
                    MarkUp()\Row()\String + "L|"
                  EndIf
                Next 
                MarkUp()\Row()\String = RTrim(MarkUp()\Row()\String, "|")
              EndIf  
              ;}
            Else                                                       ;{ Table rows
              
              If AddElement(MarkUp()\Row()\Item())
                MarkUp()\Row()\Item()\Type   = #Table 
                MarkUp()\Row()\Item()\String = trimRow$
              EndIf  
              ;}
            EndIf
            ;}
          Case "["         ;{ Footnote text
            ePos = FindString(Row$, "]:", Pos + 2)
            If ePos
              Text$ = Mid(Row$, sPos + 2, ePos - Pos - 2)
              If AddElement(MarkUp()\FootNote())
                MarkUp()\FootNote()\Note   = Text$
                MarkUp()\FootNote()\String = Mid(Row$, ePos + 2)
                MarkUp()\FootIdx(Text$) = ListIndex(MarkUp()\FootNote())
              EndIf
            EndIf  
            ;}
          Case " ", #TAB$  ;{ Indented
            
            trimRow$ = LTrim(Row$, #TAB$)
            trimRow$ = LTrim(trimRow$)
            
            If Left(Row$, 4) = "    " Or Left(Row$, 1) = #TAB$
              Select Mid(Row$, 5, 1)
                Case "-", "+", "*"                               ;{ Unordered Lists (indented)
                  
                  If ListSize(MarkUp()\Row()) = #False Or (MarkUp()\Row()\Type <> #List And MarkUp()\Row()\Type <> #OrderedList)
                    AddElement(MarkUp()\Row())
                    MarkUp()\Row()\Type = #List
                    MarkUp()\Row()\BlockQuote = BQ
                  EndIf
                  
                  If AddElement(MarkUp()\Row()\Item())
                    MarkUp()\Row()\Item()\Type   = #List
                    MarkUp()\Row()\Item()\String = LTrim(Mid(trimRow$, 3))
                    MarkUp()\Row()\Item()\Level  = 1
                  EndIf
                  ;}
                Case "1", "2", "3", "4", "5", "6", "7", "8", "9" ;{ Ordered List    (indented)
                  Num$ = StringField(trimRow$, 1, " ")
                  If Right(Num$, 1) = "."
                    
                    If ListSize(MarkUp()\Row()) = #False Or (MarkUp()\Row()\Type <> #List And MarkUp()\Row()\Type <> #OrderedList)
                      AddElement(MarkUp()\Row())
                      MarkUp()\Row()\Type = #OrderedList
                      MarkUp()\Row()\BlockQuote = BQ
                    EndIf  
                    
                    If AddElement(MarkUp()\Row()\Item())
                      MarkUp()\Row()\Item()\Type   = #OrderedList
                      MarkUp()\Row()\Item()\String = Mid(trimRow$, Len(Num$) + 1)
                      MarkUp()\Row()\Item()\Level  = 1
                    EndIf
                    
                  Else
                    
                    If AddElement(MarkUp()\Row()\Item())
                      MarkUp()\Row()\Item()\Type = #Text
                      MarkUp()\Row()\String      = Row$
                    EndIf 
                    
                  EndIf
                  ;}
                Default                                          ;{ Text
                  AddText_(trimRow$, BQ)
                  ;}
              EndSelect
            ElseIf Left(trimRow$, 2) = "!["                      ;{ Image
              
              If AddElement(MarkUp()\Row())
                Image_(trimRow$, Pos + 1)
              EndIf
              ;}
            Else                                                 ;{ Text
              AddText_(trimRow$, BQ)
              ;}
            EndIf 
            ;}
          Case ""          ;{ Paragraph
            
            If AddElement(MarkUp()\Row())
              MarkUp()\Row()\Type = #Paragraph
              MarkUp()\Row()\BlockQuote = BQ
            EndIf  
            ;}
          Default          ;{ Text (Emphasis / ...)
  
            If LineBreak = #False : Row$ = RTrim(Row$) + " " : EndIf  
            
            If ListSize(MarkUp()\Row()) = 0 Or MarkUp()\Row()\Type <> #Text
              If AddElement(MarkUp()\Row())
                MarkUp()\Row()\Type       = #Text
                MarkUp()\Row()\BlockQuote = BQ
                newRow = #True
              EndIf
            EndIf
            
            Repeat
    
              Select Mid(Row$, Pos, 1)
                Case "\" ;{ EscapingCharacters 
                  
                  Select Mid(Row$, Pos, 2)
                    Case "\\", "\`", "\*", "\_", "\#", "\+", "\-", "\.", "\!", "\|"
                      Row$ = RemoveString(Row$, "\", #PB_String_CaseSensitive, Pos, 1)
                      Pos + 1
                    Case "\{", "\}", "\[", "\]", "\(", "\)"
                      Row$ = RemoveString(Row$, "\", #PB_String_CaseSensitive, Pos, 1)
                      Pos + 1
                  EndSelect
                  ;}
                Case "*" ;{ Emphasis
                  
                  If sPos <= Pos 
                    If newRow
                      MarkUp()\Row()\String = Mid(Row$, sPos, Pos - sPos)
                    ElseIf AddElement(MarkUp()\Row()\Item())
                      MarkUp()\Row()\Item()\Type   = #Text
                      MarkUp()\Row()\Item()\String = Mid(Row$, sPos, Pos - sPos)
                    EndIf
                  EndIf
      
                  If AddElement(MarkUp()\Row()\Item())
                    ePos = Emphasis_(Row$, Pos)
                    If ePos = 0 : ePos = Pos : Else : Pos = ePos : EndIf
                  EndIf
      
                  sPos = Pos + 1
                  ;}
                Case "`" ;{ Code
                  
                  If sPos <= Pos 
                    If newRow
                      MarkUp()\Row()\String = Mid(Row$, sPos, Pos - sPos)
                    ElseIf AddElement(MarkUp()\Row()\Item())
                      MarkUp()\Row()\Item()\Type   = #Text
                      MarkUp()\Row()\Item()\String = Mid(Row$, sPos, Pos - sPos)  
                    EndIf   
                  EndIf
      
                  If AddElement(MarkUp()\Row()\Item())
                    
                    ePos = Code_(Row$, Pos)
                    If ePos = 0 : ePos = Pos : EndIf
                    MarkUp()\Row()\Item()\String = RemoveString(Mid(Row$, Pos, ePos - Pos + 1), "`")
    
                    If ePos : Pos = ePos : EndIf
                  EndIf
      
                  sPos = Pos + 1
                  ;}
                Case "[" ;{ Links / Footnote
                  
                  ; TODO: [Heading IDs](#heading-ids) / <a href="#heading-ids">Heading IDs</a>
                  
                  If sPos <= Pos 
                    If newRow
                      MarkUp()\Row()\String = Mid(Row$, sPos, Pos - sPos)
                      newRow = #False
                    ElseIf AddElement(MarkUp()\Row()\Item())
                      MarkUp()\Row()\Item()\Type   = #Text
                      MarkUp()\Row()\Item()\String = Mid(Row$, sPos, Pos - sPos)
                    EndIf   
                  EndIf
                  
                  If Mid(Row$, Pos, 2) = "[^" ;{ Footnote
                    
                    ePos = Footnote_(Row$, Pos)
                    If ePos = 0 : ePos = Pos : Else : Pos = ePos : EndIf
                    
                    ;}
                  Else                        ;{ Links
                    
                    If AddElement(MarkUp()\Row()\Item())
                      ePos = Link_(Row$, Pos)
                      If ePos = 0 : ePos = Pos : Else : Pos = ePos : EndIf
                    EndIf
                    ;}
                  EndIf
                  
                  sPos = Pos + 1
                  ;}
                Case "<" ;{ URL / Email
  
                  If sPos <= Pos 
                    If newRow
                      MarkUp()\Row()\String = Mid(Row$, sPos, Pos - sPos)
                    ElseIf AddElement(MarkUp()\Row()\Item())
                      MarkUp()\Row()\Item()\Type   = #Text
                      MarkUp()\Row()\Item()\String = Mid(Row$, sPos, Pos - sPos)  
                    EndIf   
                  EndIf
                  
                  If AddElement(MarkUp()\Row()\Item())
                    
                    ePos = URL_(Row$, Pos)
                    
                    If ePos = 0 : ePos = Pos : EndIf
                    
                    MarkUp()\Row()\Item()\String = Mid(Row$, Pos + 1, ePos - Pos - 1)
                    
                    If AddElement(MarkUp()\Link())
                      MarkUp()\Row()\Item()\Index = ListIndex(MarkUp()\Link())
                      MarkUp()\Link()\URL = MarkUp()\Row()\Item()\String
                    EndIf
                    
                    If ePos : Pos = ePos : EndIf
                  EndIf
      
                  sPos = Pos + 1
                  ;}
                Case "!" ;{ Image
                  
                  If Mid(Row$, Pos, 2) = "!["
    
                    If sPos <= Pos
                      If newRow
                        MarkUp()\Row()\String = Mid(Row$, sPos, Pos - sPos)
                      ElseIf AddElement(MarkUp()\Row()\Item())
                        MarkUp()\Row()\Item()\Type   = #Text
                        MarkUp()\Row()\Item()\String = Mid(Row$, sPos, Pos - sPos)  
                      EndIf   
                    EndIf
                    
                    Pos + 1
                    
                    If AddElement(MarkUp()\Row()\Item())
                      ePos = TextImage_(Row$, Pos)
                      If ePos = 0 : ePos = Pos : Else : Pos = ePos : EndIf
                    EndIf
        
                    sPos = Pos + 1
                  EndIf  
                  ;}
              EndSelect
              
              Pos + 1
              
            Until Pos > Length
  
            If sPos <= Pos  ;{ Remaining text
              If newRow And MarkUp()\Row()\String = ""
                MarkUp()\Row()\String = Mid(Row$, sPos)
              Else
                If AddElement(MarkUp()\Row()\Item())
                  MarkUp()\Row()\Item()\Type   = #Text
                  
                  MarkUp()\Row()\Item()\String = Mid(Row$, sPos)
                EndIf
              EndIf ;}
            EndIf
            
            If LineBreak
              MarkUp()\Row()\Type = #LineBreak
              LineBreak = #False
            EndIf 
            ;}
        EndSelect
        
      Next
      
    EndProcedure  

  CompilerEndIf
  
  ;- __________ BB Code __________
  
  CompilerIf #Enable_BBCode
    
  CompilerEndIf
  
	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure
	

	Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i)
  
    If MarkUp()\Radius
  		RoundBox(X, Y, Width, Height, MarkUp()\Radius, MarkUp()\Radius, Color)
  	Else
  		Box(X, Y, Width, Height, Color)
  	EndIf
  	
  EndProcedure
  
  
  Procedure.i DrawText_(X.i, Y.i, Text.s, FrontColor.i, Indent.i=0, maxCol.i=0, Link.i=#PB_Default) ; WordWrap
    Define.i w, PosX, txtWidth, txtHeight, Words, Rows, bqY, OffSetBQ, maxWidth
    Define.s Word$

    If MarkUp()\BlockQuote : OffSetBQ = dpiX(10) * MarkUp()\BlockQuote : EndIf 
    
    X + OffSetBQ
    Y + MarkUp()\WrapHeight
    
    bqY = Y
    
    If maxCol
      maxWidth = maxCol - dpiX(5)
    Else
      maxWidth = MarkUp()\WrapPos
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
              PosX = MarkUp()\LeftBorder + Indent + OffSetBQ
            EndIf 
            
            Rows + 1
            Y + TextHeight("Abc")
            MarkUp()\WrapHeight + TextHeight("Abc")
          EndIf
          
          If w < Words : Word$ + " " : EndIf
  
          PosX = DrawText(PosX, Y, Word$, FrontColor)
  
        Next
        ;}
      Else                  ;{ Move to next line
        
        PosX = MarkUp()\LeftBorder + Indent + OffSetBQ
        Y + TextHeight(Text)
        Rows + 1
        MarkUp()\WrapHeight + TextHeight("Abc")
        
        If SelectElement(MarkUp()\Link(), Link)
          MarkUp()\Link()\X      = PosX
          MarkUp()\Link()\Y      = Y
          MarkUp()\Link()\Width  = TextWidth(Text)
          MarkUp()\Link()\Height = TextHeight(Text)
          If MarkUp()\Link()\State : FrontColor = MarkUp()\Color\LinkHighlight : EndIf 
        EndIf

        PosX = DrawText(PosX, Y, Text, FrontColor)
        ;}
      EndIf
      
      If MarkUp()\BlockQuote
        DrawingMode(#PB_2DDrawing_Default)
        Box(MarkUp()\LeftBorder, bqY, dpiX(5), TextHeight("Abc") * Rows, MarkUp()\Color\BlockQuote)
        If MarkUp()\BlockQuote = 2
          Box(MarkUp()\LeftBorder + dpiX(10), bqY, dpiX(5), TextHeight("Abc") * Rows, MarkUp()\Color\BlockQuote)
        EndIf  
      EndIf 
      
      ProcedureReturn PosX - OffSetBQ
    Else

      If Link <> #PB_Default
        If SelectElement(MarkUp()\Link(), Link)
          MarkUp()\Link()\X      = X
          MarkUp()\Link()\Y      = Y
          MarkUp()\Link()\Width  = TextWidth(Text)
          MarkUp()\Link()\Height = TextHeight(Text)
          If MarkUp()\Link()\State : FrontColor = MarkUp()\Color\LinkHighlight : EndIf 
        EndIf
      EndIf

      X = DrawText(X, Y, Text, FrontColor)
      
      If MarkUp()\BlockQuote
        DrawingMode(#PB_2DDrawing_Default)
        Box(MarkUp()\LeftBorder, bqY, dpiX(5), TextHeight(Text), MarkUp()\Color\BlockQuote)
        If MarkUp()\BlockQuote = 2
          Box(MarkUp()\LeftBorder + dpiX(10), bqY, dpiX(5), TextHeight(Text), MarkUp()\Color\BlockQuote)
        EndIf 
      EndIf  
     
      ProcedureReturn X - OffSetBQ
    EndIf  

    
  EndProcedure
  
	Procedure   Draw_()
	  Define.i X, Y, Width, Height, LeftBorder, WrapPos, TextHeight, Cols
	  Define.i Indent, Level, Offset, OffSetX, OffSetY, maxCol
	  Define.i c, OffsetList, NumWidth, ColWidth, TableWidth
		Define.i FrontColor, BackColor, BorderColor, LinkColor
		Define.s Text$, Num$
		
		NewMap ListNum.i()
		
		If MarkUp()\Hide : ProcedureReturn #False : EndIf 
		
		X = dpiX(MarkUp()\Margin\Left)
		Y = dpiY(MarkUp()\Margin\Top)

		Width   = dpiX(GadgetWidth(MarkUp()\CanvasNum))  - dpiX(MarkUp()\Margin\Left + MarkUp()\Margin\Right)
		Height  = dpiY(GadgetHeight(MarkUp()\CanvasNum)) - dpiY(MarkUp()\Margin\Top  + MarkUp()\Margin\Bottom)
		
		If Not MarkUp()\Scroll\Hide : Width - dpiX(#ScrollBarSize) : EndIf 
		
		MarkUp()\LeftBorder = X
		MarkUp()\WrapPos    = dpiX(GadgetWidth(MarkUp()\CanvasNum)) - dpiX(MarkUp()\Margin\Right)
		
		If Not MarkUp()\Scroll\Hide : MarkUp()\WrapPos - dpiX(#ScrollBarSize) : EndIf 
		
		If StartDrawing(CanvasOutput(MarkUp()\CanvasNum))
		  
		  DrawingFont(FontID(MarkUp()\Font\Normal))
			MarkUp()\Scroll\Height = TextHeight("Abc")
		  
		  Y - MarkUp()\Scroll\Offset
		  
		  ;{ _____ Colors _____
		  FrontColor  = MarkUp()\Color\Front
		  BackColor   = MarkUp()\Color\Back
		  BorderColor = MarkUp()\Color\Border
		  LinkColor   = MarkUp()\Color\Link
		  
		  If MarkUp()\Disable
		    FrontColor  = MarkUp()\Color\DisableFront
		    LinkColor   = MarkUp()\Color\DisableFront
		    BackColor   = MarkUp()\Color\DisableBack
		    BorderColor = MarkUp()\Color\DisableFront ; or MarkUp()\Color\DisableBack
		  EndIf ;} 
		  
			;{ _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  Box(0, 0, dpiX(GadgetWidth(MarkUp()\CanvasNum)), dpiY(GadgetHeight(MarkUp()\CanvasNum)), MarkUp()\Color\Gadget) ; needed for rounded corners
			Box_(0, 0, dpiX(GadgetWidth(MarkUp()\CanvasNum)), dpiY(GadgetHeight(MarkUp()\CanvasNum)), BackColor)
			;}

			ForEach MarkUp()\Row()
	
			  DrawingFont(FontID(MarkUp()\Font\Normal))
			  TextHeight = TextHeight("Abc")
			  
			  X = MarkUp()\LeftBorder
			  
			  MarkUp()\BlockQuote = MarkUp()\Row()\BlockQuote
			  MarkUp()\WrapHeight = 0
			  
			  Select MarkUp()\Row()\Type
			    Case #Heading     ;{ Heading  
			      DrawingMode(#PB_2DDrawing_Transparent)
			      Select MarkUp()\Row()\Level
			        Case 1
			          DrawingFont(FontID(MarkUp()\Font\H1))
			        Case 2
			          DrawingFont(FontID(MarkUp()\Font\H2))
			        Case 3
			          DrawingFont(FontID(MarkUp()\Font\H3))
			        Case 4
			          DrawingFont(FontID(MarkUp()\Font\H4))
			        Case 5
			          DrawingFont(FontID(MarkUp()\Font\H5))
			        Case 6
			          DrawingFont(FontID(MarkUp()\Font\H6))
			      EndSelect
			      
			      DrawText_(X, Y, MarkUp()\Row()\String, FrontColor)
			      
			      If TextWidth(MarkUp()\Row()\String) > MarkUp()\Required\Width : MarkUp()\Required\Width = TextWidth(MarkUp()\Row()\String) : EndIf 
			      
			      Y + TextHeight(MarkUp()\Row()\String) + MarkUp()\WrapHeight
            ;}
			    Case #OrderedList ;{ Ordered List  
			      
			      ClearMap(ListNum())
			      
			      DrawingMode(#PB_2DDrawing_Transparent)

			      NumWidth   = Len(Str(ListSize(MarkUp()\Row()\Item()))) * TextWidth("0")
			      
			      Y + (TextHeight / 2)
			      
			      ForEach MarkUp()\Row()\Item()
			        
			        Offset = 0
			        Level  = MarkUp()\Row()\Item()\Level
			        Indent = (NumWidth + TextWidth(". ")) * (Level)
			        
			        If Level
			          If MarkUp()\Row()\Item()\Type = #List
			            Num$ = "- "
			          Else  
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level-1))) + "." + Str(ListNum(Str(Level))) + ". "
			          EndIf 
			        Else
			          If MarkUp()\Row()\Item()\Type = #List
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

			        DrawText_(X + Offset + MarkUp()\Indent + Indent, Y, Num$ + MarkUp()\Row()\Item()\String, FrontColor, Offset + MarkUp()\Indent + Indent + TextWidth(Num$))

			        Y + TextHeight
			      Next
			      
			      Y + MarkUp()\WrapHeight + (TextHeight / 2)
			      ;}
			    Case #List        ;{ Unordered List
			      
			      ClearMap(ListNum())
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      NumWidth   = TextWidth("0")

			      Y + (TextHeight / 2)
			      
			      ForEach MarkUp()\Row()\Item()
			        
			        Offset = 0
			        Level  = MarkUp()\Row()\Item()\Level
			        Indent = TextWidth(#Bullet$ + " ") * MarkUp()\Row()\Item()\Level
			        
			        If Level
			          If MarkUp()\Row()\Item()\Type = #OrderedList
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level))) + ". "
			          Else  
			            Num$ = "- "
			          EndIf
			        Else
			          If MarkUp()\Row()\Item()\Type = #OrderedList
			            ListNum(Str(Level)) + 1
			            Num$ = Str(ListNum(Str(Level))) + ". "
			          Else  
			            Num$ = #Bullet$ + " "
			          EndIf 
			        EndIf  
			        
			        DrawText_(X + MarkUp()\Indent + Offset + Indent, Y, Num$ + MarkUp()\Row()\Item()\String, FrontColor, MarkUp()\Indent + Offset + Indent + TextWidth(Num$))
			        
			        Y + TextHeight
			      Next
			      
			      Y + MarkUp()\WrapHeight + (TextHeight / 2)
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
			      If SelectElement(MarkUp()\Image(), MarkUp()\Row()\Index)
			        
			        If MarkUp()\Image()\Num = #False ;{ Load Image
			          MarkUp()\Image()\Num = LoadImage(#PB_Any, MarkUp()\Image()\Source)
			          If MarkUp()\Image()\Num
			            MarkUp()\Image()\Width  = ImageWidth(MarkUp()\Image()\Num)
			            MarkUp()\Image()\Height = ImageHeight(MarkUp()\Image()\Num)
			          EndIf ;}
			        EndIf
			        
			        If IsImage(MarkUp()\Image()\Num)
			          
			          OffSetX = (Width - MarkUp()\Image()\Width) / 2
			          
			          DrawingMode(#PB_2DDrawing_AlphaBlend)
			          DrawImage(ImageID(MarkUp()\Image()\Num), X + OffSetX, Y)
			          Y + MarkUp()\Image()\Height
			          
			          If MarkUp()\Row()\String
			            OffSetX = (Width - TextWidth(MarkUp()\Row()\String)) / 2
			            DrawingMode(#PB_2DDrawing_Transparent)
			            DrawText(X + OffSetX, Y, MarkUp()\Row()\String, FrontColor)
			            Y + TextHeight(MarkUp()\Row()\String)
			          EndIf
			          
			        ElseIf MarkUp()\Image()\Title
			          OffSetX = (Width - TextWidth(MarkUp()\Image()\Title)) / 2
		            DrawingMode(#PB_2DDrawing_Transparent)
		            DrawText(X + OffSetX, Y, MarkUp()\Image()\Title, FrontColor)
		            Y + TextHeight(MarkUp()\Image()\Title)
			        EndIf 
			        
			        If MarkUp()\Image()\Width > MarkUp()\Required\Width : MarkUp()\Required\Width = MarkUp()\Image()\Width : EndIf 
			        
			      EndIf  
			      ;}
			    Case #Table       ;{ Table
	
			      DrawingFont(FontID(MarkUp()\Font\Normal))
			      TextHeight = TextHeight("Abc")
			      
			      X = MarkUp()\LeftBorder + dpiX(20)
			      Y + (TextHeight / 2)
			      
			      TableWidth = Width - dpiX(40)
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      ForEach MarkUp()\Row()\Item()
			        
			        Text$ = MarkUp()\Row()\Item()\String
			        
			        Cols     = CountString(Text$, "|") + 1
			        ColWidth = TableWidth / Cols

			        If MarkUp()\Row()\Item()\Type = #Header
			          DrawingFont(FontID(MarkUp()\Font\Bold))
			        Else
			          DrawingFont(FontID(MarkUp()\Font\Normal))
			        EndIf  
			        
			        For c=0 To Cols - 1
			          maxCol = ColWidth * (c + 1)
		            DrawText_(X + (ColWidth * c), Y, Trim(StringField(Text$, c+1, "|")), FrontColor, 0, maxCol)
		          Next 
		          
		          Y + TextHeight + MarkUp()\WrapHeight
		          
		          If MarkUp()\Row()\Item()\Type = #Header
  		          OffSetY = TextHeight / 2
  		          Line(X, Y + OffSetY, TableWidth, 1, FrontColor)
  		          Y + TextHeight 
			        EndIf  
			        
			      Next
			      
			      Y + (TextHeight / 2)
			      ;}
			    Default           ;{ Text
			      
			      DrawingMode(#PB_2DDrawing_Transparent)
			      
			      DrawingFont(FontID(MarkUp()\Font\Normal))
			      
			      TextHeight = TextHeight("Abc")

			      If MarkUp()\Row()\String
			        X = DrawText_(X, Y, MarkUp()\Row()\String, FrontColor)
  			    EndIf
			    
			      ForEach MarkUp()\Row()\Item()
			        
			        Select MarkUp()\Row()\Item()\Type
                Case #Bold     ;{ Emphasis
                  DrawingFont(FontID(MarkUp()\Font\Bold))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, FrontColor)
                Case #Italic
                  DrawingFont(FontID(MarkUp()\Font\Italic))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, FrontColor)
                Case #BoldItalic 
                  DrawingFont(FontID(MarkUp()\Font\BoldItalic))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, FrontColor)
                  ;}
                Case #Code     ;{ Code
                  DrawingFont(FontID(MarkUp()\Font\Code))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, FrontColor)
                  ;}
                Case #URL      ;{ URL / EMail
                  DrawingFont(FontID(MarkUp()\Font\Normal))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, LinkColor, #False, 0, MarkUp()\Row()\Item()\Index)
                  ;}
                Case #Link     ;{ Link
                  DrawingFont(FontID(MarkUp()\Font\Normal))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, LinkColor, #False, 0, MarkUp()\Row()\Item()\Index)  
                  ;}
                Case #FootNote ;{ Footnote
                  DrawingFont(FontID(MarkUp()\Font\FootNote))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, FrontColor)
                  ;}
                Default        ;{ Text
                  DrawingFont(FontID(MarkUp()\Font\Normal))
                  X = DrawText_(X, Y, MarkUp()\Row()\Item()\String, FrontColor)
                  ;}
              EndSelect

            Next 
            
            Y + TextHeight + MarkUp()\WrapHeight
			      ;}
			  EndSelect

			Next  
			
			If ListSize(MarkUp()\Footnote()) ;{ Footnotes
			  
			  X = MarkUp()\LeftBorder
			  MarkUp()\WrapHeight = 0

			  DrawingFont(FontID(MarkUp()\Font\Normal))
			  TextHeight = TextHeight("Abc")
			  Y + (TextHeight / 2)
			  
			  DrawingFont(FontID(MarkUp()\Font\FootNoteText))
			  TextHeight = TextHeight("Abc")
			  
			  OffSetY = TextHeight / 2
			  Line(X, Y + OffSetY, Width / 3, 1, FrontColor)

			  Y + TextHeight
			  
			  ForEach MarkUp()\Footnote()
			    
          DrawingFont(FontID(MarkUp()\Font\FootNote))
          X = DrawText_(MarkUp()\LeftBorder, Y, MarkUp()\Footnote()\Note + " ", FrontColor)
          Indent = TextWidth(MarkUp()\Footnote()\Note + "  ")
          
          DrawingFont(FontID(MarkUp()\Font\FootNoteText))
          DrawText_(X, Y, MarkUp()\Footnote()\String, FrontColor, Indent)
          
			    Y + TextHeight
			  Next
			  ;}
			EndIf  
			
			MarkUp()\Required\Width + MarkUp()\Margin\Left + MarkUp()\Margin\Right
			MarkUp()\Required\Height = Y + MarkUp()\Margin\Bottom
			
			;{ _____ Border ____
			If MarkUp()\Flags & #Borderless = #False
				DrawingMode(#PB_2DDrawing_Outlined)
				Box_(0, 0, dpiX(GadgetWidth(MarkUp()\CanvasNum)), dpiY(GadgetHeight(MarkUp()\CanvasNum)), BorderColor)
			EndIf ;}

			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach MarkUp()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          MarkUp()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf

        MarkUp()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
				MarkUp()\Color\Back         = ModuleEx::ThemeGUI\BackColor
				MarkUp()\Color\Border       = ModuleEx::ThemeGUI\BorderColor
				MarkUp()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
				MarkUp()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
		    MarkUp()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
				
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
	
	Procedure _RightClickHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(MarkUp(), Str(GNum))

			X = GetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_MouseY)


			If X > = MarkUp()\Size\X And X <= MarkUp()\Size\X + MarkUp()\Size\Width
				If Y >= MarkUp()\Size\Y And Y <= MarkUp()\Size\Y + MarkUp()\Size\Height

					If IsWindow(MarkUp()\Window\Num) And IsMenu(MarkUp()\PopUpNum)
						DisplayPopupMenu(MarkUp()\PopUpNum, WindowID(MarkUp()\Window\Num))
					EndIf

				EndIf
			EndIf

		EndIf

	EndProcedure

	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(MarkUp(), Str(GNum))

			X = GetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_MouseY)
			
			ForEach MarkUp()\Link()
			  If Y >= MarkUp()\Link()\Y And Y <= MarkUp()\Link()\Y + MarkUp()\Link()\Height 
			    If X >= MarkUp()\Link()\X And X <= MarkUp()\Link()\X + MarkUp()\Link()\Width
			      MarkUp()\Link()\State = #True
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

		If FindMapElement(MarkUp(), Str(GNum))

			X = GetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_MouseY)

			ForEach MarkUp()\Link()
			  
			  If Y >= MarkUp()\Link()\Y And Y <= MarkUp()\Link()\Y + MarkUp()\Link()\Height 
			    If X >= MarkUp()\Link()\X And X <= MarkUp()\Link()\X + MarkUp()\Link()\Width
			      
			      MarkUp()\EventValue = MarkUp()\Link()\URL
			      
			      PostEvent(#Event_Gadget,    MarkUp()\Window\Num, MarkUp()\CanvasNum, #EventType_Link)
			      PostEvent(#PB_Event_Gadget, MarkUp()\Window\Num, MarkUp()\CanvasNum, #EventType_Link)
			      
			      MarkUp()\Link()\State = #False
			      
			      Draw_()
			      
  			    ProcedureReturn #True
  			  EndIf
  			EndIf
  			
			Next  
			
			ForEach MarkUp()\Link()
			  MarkUp()\Link()\State = #False
			Next
			
			Draw_()
			
		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If FindMapElement(MarkUp(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)

			ForEach MarkUp()\Link()
			  If Y >= MarkUp()\Link()\Y And Y <= MarkUp()\Link()\Y + MarkUp()\Link()\Height 
			    If X >= MarkUp()\Link()\X And X <= MarkUp()\Link()\X + MarkUp()\Link()\Width
  			    SetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
  			    ProcedureReturn #True
  			  EndIf
			  EndIf
			Next  
			
			SetGadgetAttribute(MarkUp()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)

		EndIf

	EndProcedure
	
	Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta, ScrollPos
    
    If FindMapElement(MarkUp(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(MarkUp()\Scroll\Num) And MarkUp()\Scroll\Hide = #False
        
        ScrollPos = GetGadgetState(MarkUp()\Scroll\Num) - (MarkUp()\Scroll\Height * Delta)

        If ScrollPos > MarkUp()\Scroll\MaxPos : ScrollPos = MarkUp()\Scroll\MaxPos : EndIf
        If ScrollPos < MarkUp()\Scroll\MinPos : ScrollPos = MarkUp()\Scroll\MinPos : EndIf

        MarkUp()\Scroll\Offset = ScrollPos
        
        SetGadgetState(MarkUp()\Scroll\Num, ScrollPos)

        Draw_()
      EndIf

    EndIf
    
  EndProcedure
	
	Procedure _SynchronizeScrollBar()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.i X, Y, ScrollPos
    
    If FindMapElement(MarkUp(), Str(GadgetNum))

      ScrollPos = GetGadgetState(ScrollNum)
      If ScrollPos <> MarkUp()\Scroll\Offset
        
        If ScrollPos < MarkUp()\Scroll\Offset
          ScrollPos - MarkUp()\Scroll\Height
        ElseIf ScrollPos > MarkUp()\Scroll\Offset
          ScrollPos + MarkUp()\Scroll\Height
        EndIf
      
        If ScrollPos > MarkUp()\Scroll\MaxPos : ScrollPos = MarkUp()\Scroll\MaxPos : EndIf
        If ScrollPos < MarkUp()\Scroll\MinPos : ScrollPos = MarkUp()\Scroll\MinPos : EndIf
        
        MarkUp()\Scroll\Offset = ScrollPos
        
        SetGadgetState(MarkUp()\Scroll\Num, ScrollPos)

        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure 

	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(MarkUp(), Str(GadgetID))
		  
		  Draw_()
		  
		  If AdjustScrollBars_() : Draw_() : EndIf 
		  
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach MarkUp()

			If IsGadget(MarkUp()\CanvasNum)

				If MarkUp()\Flags & #AutoResize

					If IsWindow(MarkUp()\Window\Num)

						OffSetX = WindowWidth(MarkUp()\Window\Num)  - MarkUp()\Window\Width
						OffsetY = WindowHeight(MarkUp()\Window\Num) - MarkUp()\Window\Height

						If MarkUp()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If MarkUp()\Size\Flags & #MoveX  : X = MarkUp()\Size\X + OffSetX : EndIf
							If MarkUp()\Size\Flags & #MoveY  : Y = MarkUp()\Size\Y + OffSetY : EndIf
							If MarkUp()\Size\Flags & #Width  : Width  = MarkUp()\Size\Width + OffSetX : EndIf
							If MarkUp()\Size\Flags & #Height : Height = MarkUp()\Size\Height + OffSetY : EndIf

							ResizeGadget(MarkUp()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(MarkUp()\CanvasNum, #PB_Ignore, #PB_Ignore, MarkUp()\Size\Width + OffSetX, MarkUp()\Size\Height + OffsetY)
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

		If FindMapElement(MarkUp(), Str(GNum))
			MarkUp()\PopupNum = PopUpNum
		EndIf

	EndProcedure
	
	Procedure   Clear(GNum.i)
	  
	  If FindMapElement(MarkUp(), Str(GNum))
	    
	    Clear_()
	    
	    Draw_()
	  EndIf
	  
	EndProcedure  
	
	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(MarkUp(), Str(GNum))

      MarkUp()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
    EndIf  
    
  EndProcedure 	
	
	Procedure.s EventValue(GNum.i)
    
   If FindMapElement(MarkUp(), Str(GNum))
      ProcedureReturn MarkUp()\EventValue
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

			If AddMapElement(MarkUp(), Str(GNum))

				MarkUp()\CanvasNum = GNum
				
				If WindowNum = #PB_Default
          MarkUp()\Window\Num = GetGadgetWindow()
        Else
          MarkUp()\Window\Num = WindowNum
        EndIf

				MarkUp()\Scroll\Num = ScrollBarGadget(#PB_Any, 0, 0, 0, Height, 0, Height, Height, #PB_ScrollBar_Vertical)
				If MarkUp()\Scroll\Num
				  SetGadgetData(MarkUp()\Scroll\Num, MarkUp()\CanvasNum)
				  HideGadget(MarkUp()\Scroll\Num, #True)
				EndIf
				
				CloseGadgetList()
				
				LoadFonts_("Arial", 9)
				
				MarkUp()\Size\X = X
				MarkUp()\Size\Y = Y
				MarkUp()\Size\Width  = Width
				MarkUp()\Size\Height = Height
				
				MarkUp()\Margin\Top    = 5
				MarkUp()\Margin\Left   = 5
				MarkUp()\Margin\Right  = 5
				MarkUp()\Margin\Bottom = 5
				
				MarkUp()\Indent = 10
				
				MarkUp()\Flags  = Flags

				MarkUp()\Color\Front         = $000000
				MarkUp()\Color\Back          = $FFFFFF
				MarkUp()\Color\Gadget        = $F0F0F0
				MarkUp()\Color\Border        = $A0A0A0
				MarkUp()\Color\Link          = $8B0000
				MarkUp()\Color\LinkHighlight = $FF0000
				MarkUp()\Color\BlockQuote    = $C0C0C0
				MarkUp()\Color\DisableFront  = $72727D
				MarkUp()\Color\DisableBack   = $CCCCCA
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						MarkUp()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
						MarkUp()\Color\Back   = GetSysColor_(#COLOR_WINDOW)
						MarkUp()\Color\Border = GetSysColor_(#COLOR_WINDOWFRAME)
						MarkUp()\Color\Gadget = GetSysColor_(#COLOR_MENU)
					CompilerCase #PB_OS_MacOS
						MarkUp()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						MarkUp()\Color\Back   = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
						MarkUp()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						MarkUp()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(MarkUp()\CanvasNum,  @_ResizeHandler(),         #PB_EventType_Resize)
				BindGadgetEvent(MarkUp()\CanvasNum,  @_RightClickHandler(),     #PB_EventType_RightClick)
				BindGadgetEvent(MarkUp()\CanvasNum,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
				BindGadgetEvent(MarkUp()\CanvasNum,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
				BindGadgetEvent(MarkUp()\CanvasNum,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
				BindGadgetEvent(MarkUp()\CanvasNum,  @_MouseWheelHandler(),     #PB_EventType_MouseWheel)
				
				BindGadgetEvent(MarkUp()\Scroll\Num, @_SynchronizeScrollBar(),  #PB_All) 
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(MarkUp()\Window\Num)
						MarkUp()\Window\Width  = WindowWidth(MarkUp()\Window\Num)
						MarkUp()\Window\Height = WindowHeight(MarkUp()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), MarkUp()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(MarkUp(), Str(GNum))
	    ProcedureReturn MarkUp()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(MarkUp(), Str(GNum))
	    ProcedureReturn MarkUp()\ID
	  EndIf
	  
	EndProcedure
	
	
	Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(MarkUp(), Str(GNum))
	    
	    If State
	      MarkUp()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      MarkUp()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(MarkUp(), Str(GNum))
      
      Select Attribute
        Case #Corner
          MarkUp()\Radius  = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure	
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(MarkUp(), Str(GNum))
      
      MarkUp()\Size\Flags = Flags
      MarkUp()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(MarkUp(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          MarkUp()\Color\Front       = Value
        Case #BackColor
          MarkUp()\Color\Back        = Value
        Case #BorderColor
          MarkUp()\Color\Border      = Value
        Case #LinkColor
          MarkUp()\Color\Link        = Value  
        Case #LinkHighlightColor
          MarkUp()\Color\LinkHighlight = Value    
        Case #BlockQuoteColor 
          MarkUp()\Color\BlockQuote  = Value 
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(MarkUp(), Str(GNum))
	    MarkUp()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetFont(GNum.i, Name.s, Size.i) 
    
    If FindMapElement(MarkUp(), Str(GNum))
      
      FreeFonts_()
      
      LoadFonts_(Name, Size)
      
      Draw_()
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(MarkUp(), Str(GNum))
	    MarkUp()\ID = String
	  EndIf
	  
	EndProcedure

	Procedure   SetText(GNum.i, Text.s, Type.i=#MarkDown)
	  
	  If FindMapElement(MarkUp(), Str(GNum))

	    Clear_()
	    
	    Select Type
	      Case #MarkDown
	        CompilerIf #Enable_MarkDown
	          ParseMarkDown_(Text)
	        CompilerEndIf  
	      Case #BBCode  
	        CompilerIf #Enable_BBCode
    
          CompilerEndIf
	    EndSelect
	    
	    Draw_()
	    
	    If AdjustScrollBars_() : Draw_() : EndIf 
	    
	  EndIf
	  
	EndProcedure
  
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Define.s Text$
  
  ;Text$ + "Heading level 1"+ #LF$
  ;Text$ + "==============="+ #LF$
  ;Text$ + "Heading level 2"+ #LF$
  ;Text$ + "---------------"+ #LF$
  ;Text$ + "### Heading level 3 ###"  + #LF$
  ;Text$ + "#### Heading level 4 ####"  + #LF$
  ;Text$ + "##### Heading level 5 #####"  + #LF$
  ;Text$ + "###### Heading level 6 #####"  + #LF$
  ;Text$ + "I just love **bold text**." + #LF$
  ;Text$ + "Italicized text is the *cat's meow*.  "+ #LF$
  ;Text$ + "This text is __*really important*__.  "+ #LF$
  ;Text$ + "At the command prompt, type `nano`.  "+ #LF$
  ;Text$ + "URL: <https://www.markdownguide.org>  "+ #LF$
  ;Text$ + "EMail: <fake@example.com>  "+ #LF$
  ;Text$ + "Link:  [Duck Duck Go](https://duckduckgo.com "+#DQUOTE$+"My search engine!"+#DQUOTE$+")  "+ #LF$
  ;Text$ + " ![Programmer](Test.png " + #DQUOTE$ + "Programmer Image" + #DQUOTE$ + ")"
  ;Text$ + "> Das ist Textzeile 1" + #LF$ +  "und das ist Textzeile 2.  " + #LF$
  ;Text$ + "1. First list item"+#LF$+"    * Second list item"+#LF$+"    * Third list item"+#LF$+"4. Fourth list item"+ #LF$
  ;Text$ + "-----" + #LF$
  ;Text$ + "- First list item" + #LF$ + "    1. Second list item" + #LF$ + "    2. Third list item" + #LF$ + "- Fourth list item" + #LF$
  ;Text$ + ">> Das ist Textzeile 3" + #LF$ +  "und das ist Textzeile 4.  "+ #LF$
  ;Text$ + "-----"+ #LF$
  ;Text$ + "Here's a simple footnote,[^1] and here's a longer one.[^bignote]" + #LF$
  ;Text$ + "[^1]: This is the first footnote." + #LF$
  ;Text$ + "[^bignote]: Here's one with multiple paragraphs and code."
  ;Text$ + "This is a test text for checking the WordWrap function."
  
  ;Text$ = "| Syntax | Description 2 |" + #LF$ + "| ----------- | ----------- |" + #LF$ + "| Header | Title |" + #LF$ + "| Paragraph | Text |" + #LF$ 
  
  Text$ = "### 1. MarkDown ###" + #LF$  + #LF$ + "The gadget can display text formatted with the [MarkDown Syntax](https://www.markdownguide.org/basic-syntax/).  "+ #LF$
  Text$ + "Markdown[^1] is a lightweight markup language that you can use to add formatting elements to plaintext text documents."+ #LF$
  Text$ + "- Markdown files can be read even if it isn’t rendered."  + #LF$
  Text$ + "- Markdown is portable." + #LF$ + "- Markdown is platform independent." + #LF$
  Text$ + "[^1]: Created by John Gruber in 2004."
  
  
  
  Enumeration 
    #Window
    #MarkDown
    #Editor
    #Button1
    #Button2
    #Font 
  EndEnumeration
  
  LoadFont(#Font, "Arial", 10)
  
  If OpenWindow(#Window, 0, 0, 300, 290, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    EditorGadget(#Editor, 10, 10, 280, 250)
    SetGadgetFont(#Editor, FontID(#Font))
    HideGadget(#Editor, #True)
    SetGadgetText(#Editor, Text$)
    
    ButtonGadget(#Button1, 10, 265, 60, 20, "Edit")
    ButtonGadget(#Button2, 230, 265, 60, 20, "View")
    DisableGadget(#Button2, #True)
    
    If MarkUp::Gadget(#MarkDown, 10, 10, 280, 250, MarkUp::#AutoResize)
      MarkUp::SetText(#MarkDown, Text$)
      MarkUp::SetFont(#MarkDown, "Arial", 10)
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case MarkUp::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #MarkDown
              Select EventType()
                Case MarkUp::#EventType_Link       ;{ Left mouse click
                  Debug "Link: " + MarkUp::EventValue(#MarkDown)
                  RunProgram(MarkUp::EventValue(#MarkDown))
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
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 47
; FirstLine = 5
; Folding = YpAAAIAAADAAEGBAAEAACAg6
; EnableXP
; DPIAware