;/ ============================
;/ =    PreViewModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ PreView - Gadget
;/
;/ © 2019  by Thorsten Hoeppner (08/2019)
;/


; Last Update: 8.09.2019

; - Bugfixes


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


;{ _____ PreView - Commands _____

; PreView::Gadget()             - create gadget
; PreView::FileImage()          - load a image file and preview it
; PreView::FileJSON()           - load a json file and preview it
; PreView::FileText()           - load a text file and preview it
; PreView::FileXML()            - load a xml file and preview it
; PreView::Image()              - preview image
; PreView::JSON()               - preview JSON
; PreView::Text()               - preview text string
; PreView::XML()                - previev xml  
; PreView::SetAutoResizeFlags() - [#MoveX|#MoveY|#ResizeWidth|#ResizeHeight]
; PreView::SetColor()           - similar to 'SetGadgetColor()'
; PreView::SetFont()            - similar to 'SetFont()'
  
;}


DeclareModule PreView

	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	; _____ Constants _____
  EnumerationBinary ;{ GadgetFlags
		#AutoResize ; Automatic resizing of the gadget
		#Border     ; Draw a border
		#ResizeWindow
	EndEnumeration ;}
	
	Enumeration 1     ;{ PreView()\Mode
	  #Image
	  #Text
	  #XML
	  #JSON
	EndEnumeration
	
	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#ResizeWidth
		#ResizeHeight
		#FixWidth
		#FixHeight
	EndEnumeration ;}

	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
	EndEnumeration ;}

	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget = ModuleEx::#Event_Gadget

	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
			#Event_Gadget
		EndEnumeration

	CompilerEndIf
	;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================

  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetFont(GNum.i, Font.i)
  
  Declare   FileImage(GNum.i, File.s)
  Declare   FileJSON(GNum.i, File.s, Font.i=#PB_Default, Flags.i=#PB_UTF8)
  Declare   FileText(GNum.i, File.s, Font.i=#PB_Default, FontSize.i=#PB_Default, Flags.i=#PB_UTF8)
  Declare   FileXML(GNum.i,  File.s, Font.i=#PB_Default, Flags.i=#PB_UTF8)
  
  Declare   Image(GNum.i, Image.i)
  Declare   JSON(GNum.i, JSON.i, Font.i=#PB_Default)
  Declare   Text(GNum.i, Text.s, Font.i=#PB_Default, FontSize.i=#PB_Default)
  Declare   XML(GNum.i,  XML.i, Font.i=#PB_Default)
  
EndDeclareModule

Module PreView

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================

  #ScrollBarSize = 16
  #Attr3432      = Chr(34) + " "
  
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
  
  Structure Tag_Structure               ;{ Tag\...
    First.s
    Content.s
    Last.s
  EndStructure ;}
  
  Structure XML_Structure               ;{ PreView()\XML()\...
    List Item.s()
  EndStructure ;}
  

	Structure Content_Structure           ;{ PreView()\Content\...
	  Font.i
	  Size.i
	  Height.i
	  Width.i
	EndStructure ;}
	
	Structure Resize_Structure            ;{ PreView()\Resize\...
	  Width.i
	  Height.i
	  Flags.i
	EndStructure ;}
	
	
	Structure PreView_Color_Structure     ;{ PreView()\Color\...
		Front.i
		Back.i
		Border.i
		ScrollBar.i
	EndStructure  ;}

	Structure PreView_Window_Structure    ;{ PreView()\Window\...
		Num.i
		Width.f
		Height.f
		OffsetX.i
		OffsetY.i
	EndStructure ;}
	
  Structure PreView_Margins_Structure   ;{ PreView()\Margin\...
		Top.i
		Left.i
		Right.i
		Bottom.i
	EndStructure ;}
	
	Structure PreView_Size_Structure      ;{ PreView()\Size\...
		X.f
		Y.f
		Width.i
		Height.i
		maxWidth.i
		maxHeight.i
		OffsetH.i
		OffsetV.i
		Flags.i
	EndStructure ;}
	
	Structure PreView_ScrollBar_Structure ;{ PreView()\ScrollBar\...
    Num.i
    Pos.i
    Hide.i
    MaxPos.i
  EndStructure ;}

	Structure PreView_Structure           ;{ PreView()\...
		CanvasNum.i
		PopupNum.i
		
		ImageNum.i
		
		FontID.i
		Mode.i
		Flags.i

    Content.Content_Structure
		Color.PreView_Color_Structure
		Margin.PreView_Margins_Structure
		Resize.Resize_Structure
		Size.PreView_Size_Structure
		Window.PreView_Window_Structure
		
		HScrollBar.PreView_ScrollBar_Structure
		VScrollBar.PreView_ScrollBar_Structure
		
		List JSON.s()
		List Text.s()
		List XML.XML_Structure()
		
	EndStructure ;}
	Global NewMap PreView.PreView_Structure()

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
		ProcedureReturn DesktopScaledX(Num)
	EndProcedure

	Procedure.f dpiY(Num.i)
		ProcedureReturn DesktopScaledY(Num)
	EndProcedure
	
	
  Procedure   CalcDrawSize_()
	  Define.i Width, Height, TextWidth, TextHeight
	  Define.i MaxWidth, MaxHeight
	  Define.s String

	  Select PreView()\Mode
	    Case #Text  ;{ Draw Text
	      
	      Width  = PreView()\Size\maxWidth  - PreView()\Margin\Left - PreView()\Margin\Right
		    Height = PreView()\Size\maxHeight - PreView()\Margin\Top  - PreView()\Margin\Bottom
	      
		    If StartVectorDrawing(CanvasVectorOutput(PreView()\CanvasNum))
		      
		      If IsFont(PreView()\Content\Font)
		        If PreView()\Content\Size <> #PB_Default
		          VectorFont(FontID(PreView()\Content\Font), PreView()\Content\Size)
		        Else
		          VectorFont(FontID(PreView()\Content\Font))
		        EndIf
		      Else
		        If PreView()\Content\Size <> #PB_Default
		          VectorFont(PreView()\FontID, PreView()\Content\Size)
		        Else
		          VectorFont(PreView()\FontID)
		        EndIf 
		      EndIf  

		      ForEach PreView()\Text()
			      MaxHeight + VectorParagraphHeight(PreView()\Text(), Width, Height)
			    Next 
			    
			    PreView()\Content\Width  = Width
			    PreView()\Content\Height = MaxHeight + (PreView()\Margin\Top + PreView()\Margin\Bottom) * 4
			    
			    PreView()\Resize\Width  = PreView()\Content\Width
			    PreView()\Resize\Height = PreView()\Content\Height

			    StopVectorDrawing()
	      EndIf  
		    ;}
	    Case #XML   ;{ Draw XML
	      
	      If StartDrawing(CanvasOutput(PreView()\CanvasNum))

			    If IsFont(PreView()\Content\Font)
		        DrawingFont(FontID(PreView()\Content\Font))
		      Else
		        DrawingFont(PreView()\FontID)
		      EndIf
		      
			    TextHeight = TextHeight("Abc")
			    
			    ForEach PreView()\XML()
			      
			      TextWidth = 0
			      
			      ForEach PreView()\XML()\Item()
			        TextWidth + TextWidth(ReplaceString(PreView()\XML()\Item(), "'", Chr(34)))
			      Next
			      
			      If TextWidth > MaxWidth : MaxWidth = TextWidth : EndIf 
			      
			      MaxHeight + TextHeight
			    Next
			    
			    PreView()\Content\Width  = MaxWidth  + PreView()\Margin\Left + PreView()\Margin\Right
			    PreView()\Content\Height = MaxHeight + PreView()\Margin\Top + PreView()\Margin\Bottom + dpiY(2)
			    
			    PreView()\Resize\Width  = PreView()\Content\Width
			    PreView()\Resize\Height = PreView()\Content\Height
			    
		      StopDrawing()
		    EndIf
		    ;}
		  Case #JSON  ;{ Draw JSON
		    
		    If StartDrawing(CanvasOutput(PreView()\CanvasNum))
		      
		      DrawingMode(#PB_2DDrawing_Transparent)
		      
  		    If IsFont(PreView()\Content\Font)
  	        DrawingFont(FontID(PreView()\Content\Font))
  	      Else
  	        DrawingFont(PreView()\FontID)
  	      EndIf
  	      
  		    TextHeight = TextHeight("Abc")
          MaxHeight + TextHeight
  		    
  		    ForEach PreView()\JSON()
  		      TextWidth = TextWidth(PreView()\JSON()) + dpiX(4)
  		      If TextWidth > MaxWidth : MaxWidth = TextWidth : EndIf 
  		      MaxHeight + TextHeight
  		    Next
  		    
  		    MaxHeight + TextHeight
  		    
  		    PreView()\Content\Width  = MaxWidth  + PreView()\Margin\Left + PreView()\Margin\Right
  		    PreView()\Content\Height = MaxHeight + PreView()\Margin\Top  + PreView()\Margin\Bottom + dpiY(2)
  		    
  		    PreView()\Resize\Width  = PreView()\Content\Width
			    PreView()\Resize\Height = PreView()\Content\Height
  		    
  		    StopDrawing()
  		  EndIf 
	      ;}
		EndSelect
		
		PreView()\Resize\Flags = #False
		
		If PreView()\Resize\Width > PreView()\Size\maxWidth
		  PreView()\Resize\Width = PreView()\Size\maxWidth 
		Else
		  PreView()\Resize\Flags | #FixWidth
		EndIf
		
		If PreView()\Resize\Height > PreView()\Size\maxHeight
		  PreView()\Resize\Height = PreView()\Size\maxHeight - dpiY(#ScrollBarSize)
		Else
		  PreView()\Resize\Flags | #FixHeight
		EndIf

	EndProcedure
	
	Procedure   ResizeContent_(ResizeHandler.i=#False)
	  Define.i Width, Height, WinWidth, WinHeight
	  Define.d Factor
	  
	  If ResizeHandler
	    Height = GadgetHeight(PreView()\CanvasNum)
	    Width  = GadgetWidth(PreView()\CanvasNum)
	  Else
	    Height = PreView()\Size\maxHeight
	    If Height > PreView()\Content\Height : Height = PreView()\Content\Height : EndIf 
	    Width  = PreView()\Size\maxWidth
	    If Width > PreView()\Content\Width   : Width  = PreView()\Content\Width  : EndIf 
	  EndIf
    
	  Select PreView()\Mode
	    Case #Image   ;{ Image

	      If PreView()\Content\Width > PreView()\Content\Height
	        Factor = Width / PreView()\Content\Width
	        PreView()\Resize\Flags = #FixHeight
	      Else
          Factor = Height / PreView()\Content\Height
          PreView()\Resize\Flags = #FixWidth
        EndIf
        
        PreView()\Resize\Width  = PreView()\Content\Width  * Factor
        PreView()\Resize\Height = PreView()\Content\Height * Factor
        ;}
      Default    ;{ Text / XML / JSON
        
        If ResizeHandler = #False
          
          CalcDrawSize_()

          ;{ --- Show/Hide ScrollBar ---
          If PreView()\Content\Width > PreView()\Resize\Width
            PreView()\HScrollBar\Hide  = #False
            HideGadget(PreView()\HScrollBar\Num, #False)
            PreView()\Resize\Height + dpiY(#ScrollBarSize)
          Else
            PreView()\HScrollBar\Hide = #True
          EndIf 
          
          If PreView()\Content\Height > PreView()\Resize\Height
            PreView()\VScrollBar\Hide = #False
            HideGadget(PreView()\VScrollBar\Num, #False)
            PreView()\Resize\Width  + dpiX(#ScrollBarSize)
          Else
            PreView()\VScrollBar\Hide = #True
          EndIf ;}
          
        Else

          ;{ --- Show/Hide ScrollBar ---
          If PreView()\Content\Width > Width
            Debug ""
            If PreView()\HScrollBar\Hide = #True
              PreView()\HScrollBar\Hide  = #False
              HideGadget(PreView()\HScrollBar\Num, #False)
            EndIf
          Else
            If PreView()\HScrollBar\Hide = #False
              PreView()\HScrollBar\Hide  = #True
              HideGadget(PreView()\HScrollBar\Num, #True)
            EndIf
          EndIf
          
          If PreView()\Content\Height > Height
            If PreView()\VScrollBar\Hide = #True
              PreView()\VScrollBar\Hide = #False
              HideGadget(PreView()\VScrollBar\Num, #False)
            EndIf 
          Else
            If PreView()\VScrollBar\Hide = #False
              PreView()\VScrollBar\Hide = #True
              HideGadget(PreView()\VScrollBar\Num, #True)
            EndIf
          EndIf
          ;}
          
        EndIf
        
        Width  = DesktopUnscaledX(Width)
        Height = DesktopUnscaledY(Height)

        If PreView()\HScrollBar\Hide = #False And PreView()\VScrollBar\Hide = #False
          ResizeGadget(PreView()\HScrollBar\Num, 2, Height - #ScrollBarSize - 2, Width - #ScrollBarSize - 4, #ScrollBarSize)
          ResizeGadget(PreView()\VScrollBar\Num, Width - #ScrollBarSize - 2, 2, #ScrollBarSize, Height - #ScrollBarSize - 4)
        ElseIf PreView()\HScrollBar\Hide = #False
          ResizeGadget(PreView()\HScrollBar\Num, 2, Height - #ScrollBarSize - 2, Width - 4, #ScrollBarSize)
        ElseIf PreView()\VScrollBar\Hide = #False
          ResizeGadget(PreView()\VScrollBar\Num, Width - #ScrollBarSize - 2, 2, #ScrollBarSize, Height - 4)
        EndIf 
        
        SetGadgetAttribute(PreView()\HScrollBar\Num, #PB_ScrollBar_Maximum,    PreView()\Content\Width)
        SetGadgetAttribute(PreView()\HScrollBar\Num, #PB_ScrollBar_PageLength, dpiX(Width - #ScrollBarSize - 2))
        SetGadgetAttribute(PreView()\VScrollBar\Num, #PB_ScrollBar_Maximum,    PreView()\Content\Height)
        SetGadgetAttribute(PreView()\VScrollBar\Num, #PB_ScrollBar_PageLength, dpiY(Height - #ScrollBarSize - 2))
        
        PreView()\HScrollBar\MaxPos = PreView()\Content\Width
        PreView()\VScrollBar\MaxPos = PreView()\Content\Height
        ;}
	  EndSelect
	  
	  If PreView()\Flags & #ResizeWindow ;{ Resize parent window
	    
	    If ResizeHandler And PreView()\Mode <> #Image
	      WinWidth  = GadgetWidth(PreView()\CanvasNum)  + PreView()\Window\OffsetX
	      WinHeight = GadgetHeight(PreView()\CanvasNum) + PreView()\Window\OffsetY
	    Else
	      WinWidth  = DesktopUnscaledX(PreView()\Resize\Width)  + PreView()\Window\OffsetX
	      WinHeight = DesktopUnscaledY(PreView()\Resize\Height) + PreView()\Window\OffsetY
	    EndIf

	    ResizeWindow(PreView()\Window\Num, #PB_Ignore, #PB_Ignore, WinWidth, WinHeight)

	    If PreView()\Resize\Flags & #FixHeight And PreView()\Resize\Flags & #FixWidth
	      WindowBounds(PreView()\Window\Num, WinWidth, WinHeight, WinWidth, WinHeight)
	    ElseIf PreView()\Resize\Flags = #FixHeight
	      WindowBounds(PreView()\Window\Num, #PB_Default, WinHeight, #PB_Default, WinHeight)
	    ElseIf PreView()\Resize\Flags = #FixWidth
	      WindowBounds(PreView()\Window\Num, WinWidth, #PB_Default, WinWidth, #PB_Default)
	    Else
	      WindowBounds(PreView()\Window\Num, #PB_Default, #PB_Default, #PB_Default, #PB_Default)
	    EndIf
	    
	    If PreView()\Flags & #AutoResize = #False
	      ResizeGadget(PreView()\CanvasNum, #PB_Ignore, #PB_Ignore, DesktopUnscaledX(PreView()\Resize\Width), DesktopUnscaledY(PreView()\Resize\Height))
	    EndIf 
	    ;}
    Else  
      ResizeGadget(PreView()\CanvasNum, #PB_Ignore, #PB_Ignore, DesktopUnscaledX(PreView()\Resize\Width), DesktopUnscaledY(PreView()\Resize\Height))
    EndIf
  	
	EndProcedure
	
	
	Procedure   ParseXMLTag(String.s, *Tag.Tag_Structure)
    Define.i Spaces
    
    Spaces = Len(String) - Len(LTrim(String))
    
    *Tag\First = Space(Spaces) + StringField(Trim(String), 1, " ")

    If Right(RTrim(String), 2) = "/>"
      *Tag\Last = "/>"
    Else
      *Tag\Last = ">"
    EndIf
    
    *Tag\Content = Mid(String, Len(*Tag\First) + 1, Len(String) - Len(*Tag\First) - Len(*Tag\Last))
    
  EndProcedure
  
	Procedure   ParseXML_(Row.s)
    Define.i c, Space, Ignore
    Define.s Char$

    If AddElement(PreView()\XML())
      
      For c=1 To Len(Row)
        
        Char$ = Mid(Row, c, 1)
        
        Ignore = #False
        
        Select Char$
          Case "<"
            AddElement(PreView()\XML()\Item())
            PreView()\XML()\Item() = Space(Space) + "<"
            Space  = 0
            Ignore = #True 
          Case ">"
            PreView()\XML()\Item() + ">"
            If Mid(Row, c+1, 1) <> "<"
              AddElement(PreView()\XML()\Item())
              Ignore = #False
            EndIf
          Case " "
            If ListIndex(PreView()\XML()\Item()) >= 0
              PreView()\XML()\Item() + " "
            EndIf 
            If Not Ignore : Space + 1 : EndIf
          Default
            If ListIndex(PreView()\XML()\Item()) >= 0
              PreView()\XML()\Item() + Char$
            EndIf 
            Space = 0
        EndSelect
      Next
      
      If ListIndex(PreView()\XML()\Item()) >= 0
        DeleteElement(PreView()\XML()\Item())
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure   ParseJSON_(String.s)
    Define.i Pos, fPos, StrgLen
    
    String = Trim(String)
    String = Mid(String, 2, Len(String) - 2)
    
    Pos = 1
    StrgLen = Len(String)
    
    AddElement(PreView()\JSON())
    
    Repeat

      Select Mid(String, Pos, 1)
        Case Chr(34)
          fPos = FindString(String, Chr(34), Pos + 1)
          PreView()\JSON() + Mid(String, Pos, fPos - Pos + 1)
          If fPos > 0 : Pos + (fPos - Pos) : EndIf 
        Case "["
          fPos = FindString(String, "]", Pos + 1)
          PreView()\JSON() + Mid(String, Pos, fPos - Pos + 1)
          If fPos > 0 : Pos + (fPos - Pos) : EndIf
        Case ":"
          PreView()\JSON() + ":"
        Case "{"
          fPos = FindString(String, "}", Pos + 1)
          PreView()\JSON() + Mid(String, Pos, fPos - Pos + 1)
          If fPos > 0 : Pos + (fPos - Pos) : EndIf
        Case ","
          PreView()\JSON() + ","
          AddElement(PreView()\JSON())
        Default
          PreView()\JSON() + Mid(String, Pos, 1)
      EndSelect  
      
      Pos + 1
      
    Until Pos > StrgLen

  EndProcedure
  
	;- __________ Drawing __________
	
	Procedure.i DrawJSON_(X.i, Y.i, String.s)
	  Define.i i, Count, Pos, fPos, StrgLen
	  Define.s  Char$, Last$, Content$, Item$
	  
	  Pos = 1
    StrgLen = Len(String)
	  
    Repeat
      
      Char$ = Mid(String, Pos, 1)
      
	    Select Char$
        Case Chr(34)
          fPos = FindString(String, Chr(34), Pos + 1)
	        X = DrawText(X, Y, Mid(String, Pos, fPos - Pos + 1), $800000)
          If fPos > 0 : Pos + (fPos - Pos) : EndIf 
        Case "{", "[", ",", ":", "]", "}"
          X = DrawText(X, Y, Char$, $8B008B)
        Default
          X = DrawText(X, Y, Char$, $007EE6)
      EndSelect  
	  
	    Pos + 1
      
	  Until Pos > StrgLen  
	  
	  ProcedureReturn X
	EndProcedure
	
	Procedure.i DrawXMLAttribute(X.i, Y.i, String.s)
	  Define.i i, Count
	  Define.s Attribute
	  
	  String = ReplaceString(String, "'", Chr(34))

	  Count = CountString(String, #Attr3432)
	  For i=1 To Count + 1
	    
	    Attribute = StringField(String, i, #Attr3432)
	    If i <= Count : Attribute + #Attr3432 : EndIf

	    X = DrawText(X, Y, StringField(Attribute, 1, "="), $0000E8)
	    X = DrawText(X, Y, "=", $000000)
	    X = DrawText(X, Y, StringField(Attribute, 2, "="), $800080)
	    
	  Next
	  
	  ProcedureReturn X
	EndProcedure
	
	Procedure.i DrawXML_(X.i, Y.i, String.s)
	  Define Tag.Tag_Structure
	  
	  Select Left(Trim(String), 2)
	    Case "<!"
	      X = DrawText(X, Y, String, $006400)
	    Case "<?"
	      X = DrawText(X, Y, "<?", $0000FF) + dpiX(2)
	      X = DrawText(X, Y, "xml", $CD0000)
	      X = DrawXMLAttribute(X, Y, Mid(String, 6, Len(String) - 7))
	      X = DrawText(X + dpiX(2), Y, "?>", $0000FF)
	    Case "</"
	      X = DrawText(X, Y, String, $CD0000)
	    Default
	      ParseXMLTag(String, @Tag)
	      X = DrawText(X, Y, Tag\First, $CD0000)
	      X = DrawXMLAttribute(X, Y, Tag\Content)
	      X = DrawText(X, Y, Tag\Last, $CD0000)
	  EndSelect
	  
	  ProcedureReturn X
	EndProcedure
	
	Procedure   Draw_()
	  Define.i X, Y, Width, Height, TextHeight
	  Define.d imgWidth, imgHeight, Factor
	  Define.s String, First$, Last$
	  
		X = dpiX(PreView()\Margin\Left - PreView()\Size\OffsetH)
		Y = dpiY(PreView()\Margin\Top  - PreView()\Size\OffsetV)
    
		Width  = dpiX(GadgetWidth(PreView()\CanvasNum)  - PreView()\Margin\Left - PreView()\Margin\Right)
		Height = dpiY(GadgetHeight(PreView()\CanvasNum) - PreView()\Margin\Top  - PreView()\Margin\Bottom)
		
		If PreView()\VScrollBar\Hide = #False : Width  - dpiX(#ScrollBarSize) : EndIf
		If PreView()\VScrollBar\Hide = #False : Height - dpiY(#ScrollBarSize) : EndIf

		If StartDrawing(CanvasOutput(PreView()\CanvasNum))
		  
		  ;{ _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  Box(0, 0, dpiX(GadgetWidth(PreView()\CanvasNum)), dpiY(GadgetHeight(PreView()\CanvasNum)), PreView()\Color\Back)
		  ;}
		 
		  If PreView()\Mode = #Image
		    DrawingMode(#PB_2DDrawing_AlphaBlend)
		    DrawImage(ImageID(PreView()\ImageNum), 0, 0, dpiX(GadgetWidth(PreView()\CanvasNum)), dpiY(GadgetHeight(PreView()\CanvasNum)))
		  EndIf   
		  
		  StopDrawing()
		EndIf
		
	  Select PreView()\Mode
	    Case #Text  ;{ Draw Text
	      
		    If StartVectorDrawing(CanvasVectorOutput(PreView()\CanvasNum))
		      
		      If IsFont(PreView()\Content\Font)
		        If PreView()\Content\Size <> #PB_Default
		          VectorFont(FontID(PreView()\Content\Font), dpiY(PreView()\Content\Size))
		        Else
		          VectorFont(FontID(PreView()\Content\Font))
		        EndIf
		      Else
		        If PreView()\Content\Size <> #PB_Default
		          VectorFont(PreView()\FontID, PreView()\Content\Size)
		        Else
		          VectorFont(PreView()\FontID)
		        EndIf 
		      EndIf  
		      
		      MovePathCursor(X, Y)
		      
		      ForEach PreView()\Text()
			      DrawVectorParagraph(PreView()\Text(), Width, Height)
			      VectorParagraphHeight(PreView()\Text(), Width, Height)
			    Next 
			    
			    StopVectorDrawing()
	      EndIf  
		    ;}
	    Case #XML   ;{ Draw XML
	      
	      If StartDrawing(CanvasOutput(PreView()\CanvasNum))
	        
	        DrawingMode(#PB_2DDrawing_Transparent)
	        
			    If IsFont(PreView()\Content\Font)
		        DrawingFont(FontID(PreView()\Content\Font))
		      Else
		        DrawingFont(PreView()\FontID)
		      EndIf
		      
			    TextHeight = TextHeight("Abc")
			    
			    ForEach PreView()\XML()
			      
			      X = PreView()\Margin\Left - PreView()\Size\OffsetH
			      
			      ForEach PreView()\XML()\Item()
			        
			        String = PreView()\XML()\Item()
			        
			        If Left(Trim(String), 1) = "<"
			          X = DrawXML_(X, Y, String)
			        Else
			          X = DrawText(X, Y, String, $000000)
			        EndIf
			        
			      Next
			      Y + TextHeight
			    Next
			    
		      StopDrawing()
		    EndIf
		    ;}
		  Case #JSON  ;{ Draw JSON
		    
		    If StartDrawing(CanvasOutput(PreView()\CanvasNum))
		      
		      DrawingMode(#PB_2DDrawing_Transparent)
		      
  		    If IsFont(PreView()\Content\Font)
  	        DrawingFont(FontID(PreView()\Content\Font))
  	      Else
  	        DrawingFont(PreView()\FontID)
  	      EndIf
  	      
  		    TextHeight = TextHeight("Abc")
  		    
          DrawText(X, Y, "{", $0000FF)
          Y + TextHeight
  		    
  		    ForEach PreView()\JSON()
  		      
  		      X = PreView()\Margin\Left - PreView()\Size\OffsetH
  		      
  	        First$ = Trim(StringField(PreView()\JSON(), 1, ":"))
  	        Last$  = Mid(PreView()\JSON(), Len(First$) + 2)
  	        
  	        X = DrawText(X, Y, First$, $800000)
  	        X = DrawText(X + dpiX(2), Y, ":", $8B008B) + dpiX(2)
  	        X = DrawJSON_(X, Y, Last$)
  
  		      Y + TextHeight
  		    Next
  		    
  		    X = PreView()\Margin\Left
  		    DrawText(X, Y, "}", $0000FF)
  		    
  		    StopDrawing()
  		  EndIf 
	      ;}
		EndSelect

	  If StartDrawing(CanvasOutput(PreView()\CanvasNum))
			
	    ;{ _____ Border ____
	    If PreView()\VScrollBar\Hide = #False
	      DrawingMode(#PB_2DDrawing_Default)
	      Box(dpiX(GadgetWidth(PreView()\CanvasNum) - #ScrollBarSize), 0, dpiX(#ScrollBarSize) + 1, dpiY(GadgetHeight(PreView()\CanvasNum)), PreView()\Color\ScrollBar)
	    EndIf 
	    
	    If PreView()\HScrollBar\Hide = #False
	      DrawingMode(#PB_2DDrawing_Default)
	      Box(0, dpiY(GadgetHeight(PreView()\CanvasNum) - #ScrollBarSize), dpiX(GadgetWidth(PreView()\CanvasNum)), dpiY(#ScrollBarSize + 1), PreView()\Color\ScrollBar)
	    EndIf 
	    
			If PreView()\Flags & #Border
				DrawingMode(#PB_2DDrawing_Outlined)
				Box(0, 0, dpiX(GadgetWidth(PreView()\CanvasNum)), dpiY(GadgetHeight(PreView()\CanvasNum)), PreView()\Color\Border)
			EndIf ;}

			StopDrawing()
		EndIf
  	
	EndProcedure
	
	;- __________ Events __________

	Procedure _RightClickHandler()
		Define.i X, Y
		Define.i GadgetNum = EventGadget()

		If FindMapElement(PreView(), Str(GadgetNum))

			X = GetGadgetAttribute(PreView()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(PreView()\CanvasNum, #PB_Canvas_MouseY)


			If X > = PreView()\Size\X And X <= PreView()\Size\X + PreView()\Size\Width
				If Y >= PreView()\Size\Y And Y <= PreView()\Size\Y + PreView()\Size\Height


				EndIf
			EndIf

		EndIf

	EndProcedure
	
	Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta
    Define.f ScrollPos
    
    If FindMapElement(PreView(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(PreView()\VScrollBar\Num) And PreView()\VScrollBar\Hide = #False
        
        ScrollPos = GetGadgetState(PreView()\VScrollBar\Num) - (Delta * 10)
        
        If ScrollPos > PreView()\VScrollBar\MaxPos : ScrollPos = PreView()\VScrollBar\MaxPos : EndIf
        If ScrollPos < 0 : ScrollPos = 0 : EndIf
        
        If ScrollPos <> PreView()\VScrollBar\Pos
          
          PreView()\Size\OffsetV = ScrollPos

          If IsGadget(PreView()\VScrollBar\Num)
      
            ScrollPos = PreView()\Size\OffsetV
            If ScrollPos > PreView()\VScrollBar\MaxPos : ScrollPos = PreView()\VScrollBar\MaxPos : EndIf
            
            PreView()\VScrollBar\Pos = ScrollPos
            
            SetGadgetState(PreView()\VScrollBar\Num, ScrollPos)
            
          EndIf
          
          Draw_()
        EndIf

      EndIf

    EndIf
    
  EndProcedure
  
	Procedure _SynchronizeHScrollBar()
    Define.i ScrollBar = EventGadget()
    Define.i GNum = GetGadgetData(ScrollBar)
    Define.i ScrollPos, maxOffset, Margins
    
    If FindMapElement(PreView(), Str(GNum))
      
      If PreView()\VScrollBar\Hide
        maxOffset = PreView()\Content\Width - PreView()\Size\Width + dpiX(1)
      Else
        maxOffset = PreView()\Content\Width - (PreView()\Size\Width - dpiX(#ScrollBarSize + 2)) + dpiX(1)
      EndIf
      If maxOffset < 0 : maxOffset = 0 : EndIf
      
      ScrollPos = GetGadgetState(ScrollBar)
      If ScrollPos <> PreView()\HScrollBar\Pos
        
        If ScrollPos < PreView()\HScrollBar\Pos
          PreView()\Size\OffSetH = ScrollPos - dpiY(10)
        ElseIf ScrollPos > PreView()\HScrollBar\Pos
          PreView()\Size\OffSetH = ScrollPos + dpiX(10)
        EndIf
        
        If PreView()\Size\OffSetH < 0 : PreView()\Size\OffSetH = 0 : EndIf
        If PreView()\Size\OffSetH > maxOffset : PreView()\Size\OffSetH = maxOffset : EndIf
        
        PreView()\HScrollBar\Pos = PreView()\Size\OffSetH
        SetGadgetState(ScrollBar, PreView()\Size\OffSetH)
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
	
	Procedure _SynchronizeVScrollBar()
    Define.i ScrollBar = EventGadget()
    Define.i GNum = GetGadgetData(ScrollBar)
    Define.i ScrollPos, maxOffset, Margins
    
    If FindMapElement(PreView(), Str(GNum))
      
      If PreView()\VScrollBar\Hide
        maxOffset = PreView()\Content\Height - PreView()\Size\Height + dpiY(1)
      Else
        maxOffset = PreView()\Content\Height - (PreView()\Size\Height - dpiY(#ScrollBarSize + 2)) + dpiY(1)
      EndIf
      
      If maxOffset < 0 : maxOffset = 0 : EndIf
      
      ScrollPos = GetGadgetState(ScrollBar)
      If ScrollPos <> PreView()\VScrollBar\Pos
        
        If ScrollPos < PreView()\VScrollBar\Pos
          PreView()\Size\OffSetV = ScrollPos - dpiY(10)
        ElseIf ScrollPos > PreView()\VScrollBar\Pos
          PreView()\Size\OffSetV = ScrollPos + dpiY(10)
        EndIf
        
        If PreView()\Size\OffSetV < 0 : PreView()\Size\OffSetV = 0 : EndIf
        If PreView()\Size\OffSetV > maxOffset : PreView()\Size\OffSetV = maxOffset : EndIf
        
        PreView()\VScrollBar\Pos = PreView()\Size\OffSetV
        SetGadgetState(ScrollBar, PreView()\Size\OffSetV)
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(PreView(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
	  Define.i GNum
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY
		
		PushMapPosition(PreView())
		
		ForEach PreView()

			If IsGadget(PreView()\CanvasNum)
			  
			  GNum = Val(MapKey(PreView()))
			  
				If PreView()\Flags & #AutoResize

					If IsWindow(PreView()\Window\Num)

						OffSetX = WindowWidth(PreView()\Window\Num)  - PreView()\Window\Width
						OffsetY = WindowHeight(PreView()\Window\Num) - PreView()\Window\Height

						If PreView()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If PreView()\Size\Flags & #MoveX        : X      = PreView()\Size\X + OffSetX      : EndIf
							If PreView()\Size\Flags & #MoveY        : Y      = PreView()\Size\Y + OffSetY      : EndIf
							If PreView()\Size\Flags & #ResizeWidth  : Width  = PreView()\Size\Width  + OffSetX : EndIf
							If PreView()\Size\Flags & #ResizeHeight : Height = PreView()\Size\Height + OffSetY : EndIf
							
							ResizeGadget(PreView()\CanvasNum, X, Y, Width, Height)
							ResizeContent_(#True)
							
						Else
						  
						  ResizeGadget(PreView()\CanvasNum, #PB_Ignore, #PB_Ignore, PreView()\Size\Width + OffSetX, PreView()\Size\Height + OffsetY)
						  ResizeContent_(#True)
						  
						EndIf

						Draw_()
					EndIf

				EndIf

			EndIf

		Next
		
		PopMapPosition(PreView())
		
	EndProcedure
	
	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
	
	Procedure   FileImage(GNum.i, File.s)
	  Define.i Image
	  
	  If FindMapElement(PreView(), Str(GNum))   
	    
	    Image = LoadImage(#PB_Any, File) 
      If Image
        PreView()\ImageNum       = Image
        PreView()\Content\Width  = ImageWidth(Image)
        PreView()\Content\Height = ImageHeight(Image)
        PreView()\Mode = #Image
      EndIf
      
      ResizeContent_()
			
      Draw_()
    EndIf 
    
	EndProcedure
	
	Procedure   FileXML(GNum.i, File.s, Font.i=#PB_Default, Flags.i=#PB_UTF8)
	  Define.i FileID
	  
	  If FindMapElement(PreView(), Str(GNum)) 
	    
	    PreView()\Mode = #XML
	    
	    PreView()\Margin\Left   = dpiX(5)
			PreView()\Margin\Right  = dpiX(5)
			PreView()\Margin\Top    = dpiY(5)
			PreView()\Margin\Bottom = dpiY(5)
	    
	    PreView()\Content\Font = Font
	    
	    PreView()\Color\Back = $FFFFFF
	    
  	  ClearList(PreView()\XML())
  	  
  	  FileID = ReadFile(#PB_Any, File, Flags)
      If FileID
        While Eof(FileID) = #False
          ParseXML_(ReadString(FileID)) 
        Wend
        CloseFile(FileID)
      EndIf
      
      ResizeContent_()
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  Procedure   FileJSON(GNum.i, File.s, Font.i=#PB_Default, Flags.i=#PB_UTF8)
	  Define.i FileID
	  Define.s String$
	  
	  If FindMapElement(PreView(), Str(GNum)) 
	    
	    PreView()\Mode = #JSON
	    
	    PreView()\Margin\Left   = dpiX(5)
			PreView()\Margin\Right  = dpiX(5)
			PreView()\Margin\Top    = dpiY(5)
			PreView()\Margin\Bottom = dpiY(5)
	    
	    PreView()\Content\Font  = Font
	    
	    PreView()\Color\Back = $FFFFFF
	    
  	  ClearList(PreView()\JSON())
  	  
  	  FileID = ReadFile(#PB_Any, File, Flags)
      If FileID
        While Eof(FileID) = #False
          String$ + ReadString(FileID)
        Wend
        CloseFile(FileID)
      EndIf
      
      ParseJSON_(String$)
      
      ResizeContent_()
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  Procedure   FileText(GNum.i, File.s, Font.i=#PB_Default, FontSize.i=#PB_Default, Flags.i=#PB_UTF8)
    Define.i FileID, Count, r
    Define.s Text$
    
    If FindMapElement(PreView(), Str(GNum))   
      
      FileID = ReadFile(#PB_Any, File, Flags)
      If FileID
        Text$ = ReadString(FileID, #PB_File_IgnoreEOL)
        CloseFile(FileID)
      EndIf
      
      If Text$
        
        Text$ = ReplaceString(Text$, #CRLF$, #LF$)
        
        ClearList(PreView()\Text())
        
        PreView()\Mode = #Text
        
        If IsFont(Font)
          PreView()\Content\Font = Font
        Else
          PreView()\Content\Font = #False
        EndIf  
        PreView()\Content\Size = FontSize
        
        PreView()\Margin\Left   = dpiX(5)
				PreView()\Margin\Right  = dpiX(5)
				PreView()\Margin\Top    = dpiY(5)
				PreView()\Margin\Bottom = dpiY(5)
				
				PreView()\Color\Back = $FFFFFF

        Count = CountString(Text$, #LF$) + 1
        For r=1 To Count 
          If AddElement(PreView()\Text())
            PreView()\Text() = StringField(Text$, r, #LF$)
          EndIf 
        Next  
        
        ResizeContent_()
        
        Draw_()
      EndIf
      
    EndIf

  EndProcedure
  
  
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
		Define DummyNum, Result.i

		Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Container)
		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(PreView(), Str(GNum))

				PreView()\CanvasNum = GNum
				
				PreView()\HScrollBar\Num = ScrollBarGadget(#PB_Any,2, Height - #ScrollBarSize - 2, Width - 4, #ScrollBarSize, 0, 0, 0)
				If PreView()\HScrollBar\Num
				  SetGadgetData(PreView()\HScrollBar\Num, GNum)
				  SetGadgetAttribute(PreView()\HScrollBar\Num, #PB_ScrollBar_PageLength, dpiX(Width))
          SetGadgetAttribute(PreView()\HScrollBar\Num, #PB_ScrollBar_Maximum,    dpiX(Width))
				  BindGadgetEvent(PreView()\HScrollBar\Num, @_SynchronizeHScrollBar(), #PB_All)
          HideGadget(PreView()\HScrollBar\Num, #True)
          PreView()\HScrollBar\Hide = #True
				EndIf
				
				PreView()\VScrollBar\Num = ScrollBarGadget(#PB_Any, Width - #ScrollBarSize - 2, 2, #ScrollBarSize, Height - 4, 0, 0, 0, #PB_ScrollBar_Vertical)
        If PreView()\VScrollBar\Num
				  SetGadgetData(PreView()\VScrollBar\Num, GNum)
				  SetGadgetAttribute(PreView()\VScrollBar\Num, #PB_ScrollBar_PageLength, dpiY(Height))
          SetGadgetAttribute(PreView()\VScrollBar\Num, #PB_ScrollBar_Maximum,    dpiY(Height))
				  BindGadgetEvent(PreView()\VScrollBar\Num, @_SynchronizeVScrollBar(), #PB_All)
          HideGadget(PreView()\VScrollBar\Num, #True)
          PreView()\VScrollBar\Hide = #True
        EndIf
        
        
				CompilerIf Defined(ModuleEx, #PB_Module) ; WindowNum = #Default
					If WindowNum = #PB_Default
						PreView()\Window\Num = ModuleEx::GetGadgetWindow()
					Else
						PreView()\Window\Num = WindowNum
					EndIf
				CompilerElse
					If WindowNum = #PB_Default
						PreView()\Window\Num = GetActiveWindow()
					Else
						PreView()\Window\Num = WindowNum
					EndIf
				CompilerEndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						PreView()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							PreView()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						PreView()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				PreView()\Size\X         = X
				PreView()\Size\Y         = Y
				PreView()\Size\Width     = Width
				PreView()\Size\Height    = Height
				PreView()\Size\maxWidth  = Width
				PreView()\Size\maxHeight = Height

				PreView()\Margin\Left   = 0
				PreView()\Margin\Right  = 0
				PreView()\Margin\Top    = 0
				PreView()\Margin\Bottom = 0
				
				PreView()\Flags = Flags

				PreView()\Color\Front     = $000000
				PreView()\Color\Back      = $EDEDED
				PreView()\Color\Border    = $A0A0A0
				PreView()\Color\ScrollBar = $F0F0F0
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						PreView()\Color\Front     = GetSysColor_(#COLOR_WINDOWTEXT)
						PreView()\Color\Back      = GetSysColor_(#COLOR_MENU)
						PreView()\Color\Border    = GetSysColor_(#COLOR_WINDOWFRAME)
						PreView()\Color\ScrollBar = GetSysColor_(#COLOR_MENU)
					CompilerCase #PB_OS_MacOS
						PreView()\Color\Front     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						PreView()\Color\Back      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						PreView()\Color\Border    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						PreView()\Color\ScrollBar = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(PreView()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent(PreView()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
				BindGadgetEvent(PreView()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
				
				If IsWindow(PreView()\Window\Num)
  				PreView()\Window\Width   = WindowWidth(PreView()\Window\Num)
  				PreView()\Window\Height  = WindowHeight(PreView()\Window\Num)
  				PreView()\Window\OffsetX = PreView()\Window\Width  - Width
  				PreView()\Window\OffsetY = PreView()\Window\Height - Height
  				If Flags & #AutoResize ; Enabel AutoResize
  				  BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), PreView()\Window\Num)
  				EndIf   
  			EndIf
  			
  			CloseGadgetList()
  			
				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(PreView(), Str(GNum))
      
      PreView()\Size\Flags = Flags
      PreView()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure

  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(PreView(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          PreView()\Color\Front  = Value
        Case #BackColor
          PreView()\Color\Back   = Value
        Case #BorderColor
          PreView()\Color\Border = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, Font.i) 
    
    If FindMapElement(PreView(), Str(GNum))
      
      If IsFont(Font)
        PreView()\FontID = FontID(Font)
      EndIf
    
      Draw_()
    EndIf
    
  EndProcedure  
  
  
  Procedure   Image(GNum.i, Image.i)

    If FindMapElement(PreView(), Str(GNum))   
      
      If IsImage(Image)
        PreView()\ImageNum       = Image
        PreView()\Content\Width  = dpiX(ImageWidth(Image))
        PreView()\Content\Height = dpiY(ImageHeight(Image))
        PreView()\Mode = #Image
      EndIf
      
      ResizeContent_()
			
      Draw_()
    EndIf 
    
  EndProcedure  
 
  Procedure   Text(GNum.i, Text.s, Font.i=#PB_Default, FontSize.i=#PB_Default)
    Define.i r, Count
    
    If FindMapElement(PreView(), Str(GNum))   
      
      ClearList(PreView()\Text())
      
      If Text
        
        PreView()\Mode = #Text
        
        If IsFont(Font)
          PreView()\Content\Font = Font
        Else
          PreView()\Content\Font = #False
        EndIf 
        
        PreView()\Content\Size = FontSize
        
        PreView()\Margin\Left   = dpiX(5)
				PreView()\Margin\Right  = dpiX(5)
				PreView()\Margin\Top    = dpiY(5)
				PreView()\Margin\Bottom = dpiY(5)
				
				PreView()\Color\Back = $FFFFFF
				
        Text = ReplaceString(Text, #CRLF$, #LF$)
        
        Count = CountString(Text, #LF$) + 1
        For r=1 To Count 
          If AddElement(PreView()\Text())
            PreView()\Text() = StringField(Text, r, #LF$)
          EndIf 
        Next  
        ResizeContent_()
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   JSON(GNum.i, JSON.i, Font.i=#PB_Default)
	  Define.s String$
	  
	  If FindMapElement(PreView(), Str(GNum)) 
	    
	    If IsJSON(JSON)
	      
  	    PreView()\Mode = #JSON
  	    
  	    PreView()\Margin\Left   = dpiX(5)
				PreView()\Margin\Right  = dpiX(5)
				PreView()\Margin\Top    = dpiY(5)
				PreView()\Margin\Bottom = dpiY(5)
  	    
  	    PreView()\Content\Font  = Font

  	    PreView()\Color\Back = $FFFFFF
  	    
    	  ClearList(PreView()\JSON())
    	  
    	  String$ = ComposeJSON(JSON)
        
        ParseJSON_(String$)
        
        ResizeContent_()
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   XML(GNum.i, XML.i, Font.i=#PB_Default)
    Define.i Count, r
    Define.s String
	  
	  If FindMapElement(PreView(), Str(GNum)) 
	    
	    If IsXML(XML)
	      
  	    PreView()\Mode = #XML
  	    
  	    PreView()\Margin\Left   = dpiX(5)
				PreView()\Margin\Right  = dpiX(5)
				PreView()\Margin\Top    = dpiY(5)
				PreView()\Margin\Bottom = dpiY(5)
  	    
  	    PreView()\Content\Font = Font
  	    
  	    PreView()\Color\Back = $FFFFFF
  	    
    	  ClearList(PreView()\XML())
    	  
        FormatXML(XML, #PB_XML_ReFormat|#PB_XML_LinuxNewline|#PB_XML_ReduceNewline|#PB_XML_ReduceSpace, 2)
    	  String = ComposeXML(XML)
    	  
    	  Count = CountString(String, #LF$) + 1
    	  
    	  For r=1 To Count
    	    ParseXML_(StringField(String, r, #LF$)) 
        Next  
        
        ResizeContent_()
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 4
  ;
  ; 1: Text
  ; 2: JSON
  ; 3: XML
  ; 4: Image
  
  #Window = 1
  #File   = 1
  #Arial = 1
  
  Enumeration 1
    #PreView
  EndEnumeration
  
  Enumeration 1
    #Image
    #JSON
    #XML
  EndEnumeration
  
  LoadFont(#Arial, "Arial", 11)

  If OpenWindow(#Window, 0, 0, 400, 500, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If PreView::Gadget(#PreView, 10, 10, 380, 480, PreView::#Border|PreView::#ResizeWindow|PreView::#AutoResize, #Window) ; 
      
      CompilerSelect #Example
        CompilerCase 1 
          
          PreView::FileText(#PreView, "Test.txt", #Arial, 12, #PB_Ascii)
          
        CompilerCase 2
          
          ;PreView::FileJSON(#PreView, "Test.json", #Arial)
      
          If LoadJSON(#JSON, "Test.json")
            PreView::JSON(#PreView, #JSON, #Arial)
            FreeJSON(#JSON)
          EndIf
          
        CompilerCase 3
          
          ;PreView::FileXML(#PreView, "Test.html", #Arial)
          
          If LoadXML(#XML, "Test.xml")
            PreView::XML(#PreView, #XML, #Arial)
            FreeXML(#XML)
          EndIf  
          
        CompilerCase 4
          
          UseJPEGImageDecoder()
          
          ;PreView::FileImage(#PreView, "Test.jpg")
          
          If LoadImage(#Image, "Test.jpg")
            PreView::Image(#PreView, #Image)
          EndIf

      CompilerEndSelect
      
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case PreView::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #PreView
              Select EventType()
                Case #PB_EventType_RightClick      ;{ Right mouse click
                  Debug "Right Click"
                  ;}
              EndSelect
          EndSelect ;}
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x86)
; CursorPosition = 16
; Folding = MEBCzIQAEkAy
; EnableXP
; DPIAware