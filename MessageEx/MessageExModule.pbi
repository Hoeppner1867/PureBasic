;/ =============================
;/ =    MessageExModule.pbi    =
;/ =============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ MessageEx - Gadget
;/
;/ © 2020 by Thorsten Hoeppner (12/2019)
;/


; Last Update: 23.03.2020


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


;{ _____ MsgEx - Commands _____

; MessageEx::Create()       - create a message requester style
; MessageEx::Requester()    - similar to 'MessageRequester()'
; MessageEx::SetAttribute() - change attributte
; MessageEx::SetColor()     - change default colors
; MessageEx::SetFont()      - change default font
; MessageEx::SetImage()     - set your own image     (style)
; MessageEx::SetItemColor() - set the color of a row (style)
; MessageEx::SetItemFont()  - set the font of a row  (style)
; MessageEx::SetItemFlags() - set the align of a row (style)

;}

; XIncludeFile "ModuleEx.pbi"

UseZipPacker()

DeclareModule MessageEx
  
  #Version  = 20032300
  #ModuleEx = 19112100
  
  #Include_DefaultImages = #True
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	;{ _____ Constants _____
	Enumeration 1     ;{ Buttons
	  #Click
	  #Focus
	EndEnumeration ;}
	
	Enumeration 2     ;{ Result
  	#Result_Yes
  	#Result_No
  	#Result_Cancel
  EndEnumeration ;}
  
  #OK = 0
	EnumerationBinary ;{ Requester Flags
	  #YesNo
	  #YesNoCancel
	  #Info
	  #Question
	  #Error 
	  #Warning
	EndEnumeration ;} 
	
	#Left = 0
	EnumerationBinary ;{ Style Flags
	  #Center
	  #Right
	EndEnumeration ;}
	
	Enumeration 1     ;{ Attribute
	  #Padding
	EndEnumeration ;}
	
	Enumeration 1     ;{ Color
		#FrontColor
		#BackColor
		#BorderColor
	EndEnumeration ;}

	CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Gadget = ModuleEx::#Event_Gadget
		#Event_Theme  = ModuleEx::#Event_Theme
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
			#Event_Gadget
		EndEnumeration

	CompilerEndIf
	;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
	
	Declare   Create(Label.s, Color.i=#PB_Default, Font.i=#PB_Default, Flags.i=#False)
  Declare.i Requester(Title.s, Text.s, Label.s="", Flags.i=#False, ParentID.i=#PB_Default)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetFont(GNum.i, FontID.i) 
  Declare   SetImage(Label.s, Image.i)
  Declare   SetItemColor(Label.s, Row.i, Color.i)
  Declare   SetItemFont(Label.s, Row.i, Font.i)
  Declare   SetItemFlags(Label.s, Row.i, Flags.i)
  
EndDeclareModule

Module MessageEx

	EnableExplicit
	
	UsePNGImageDecoder()
  UseZipPacker()
	
	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================

	#ButtonWidth  = 60
	#ButtonHeight = 20
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	Structure Style_Row_Structure  ;{ ...\Style()\Row('idx')...
	  FontID.i
	  Color.i
	  Flags.i
	EndStructure ;}  
	
	Structure Style_Structure      ;{ ...\Style('label')\...
	  FontID.i
	  Color.i
	  Image.i
	  Flags.i
	  Map Row.Style_Row_Structure()
	EndStructure ;}
	
	
	Structure Color_Structure      ;{ ...\Color\...
		Front.i
		Back.i
		Border.i
		Gadget.i
		Button.i
		Focus.i
	EndStructure  ;}
	
	Structure Margin_Structure     ;{ ...\Margin\...
	  Left.i
	  Top.i
	  Bottom.i
	  Right.i
	EndStructure ;}

	Structure Size_Structure       ;{ ...\Size\...
	  X.i
	  Y.i
		Width.i
		Height.i
		Text.i
	EndStructure ;}

	Structure Image_Structur       ;{ ...\Image\...
	  Num.i
	  Width.i
	  Height.i
	EndStructure ;}
	
	Structure Button_Structure     ;{ ...\Button\...
	  X.i
	  Text.s
	  State.i
	  Result.i
	  Visible.i
	EndStructure ;}
	
	Structure Row_Structure        ;{ ...\Row()\... 
	  String.s
	  Color.i
	  FontID.i
	  Flags.i
	EndStructure ;}

	Structure Requester_Structure  ;{ Requester\...
	  Label.s
	  Window.i
	  Gadget.i
	  FontID.i
	  Padding.i
	  Titel.s
	  ButtonY.i
	  Result.i
	  Flags.i
	  Color.Color_Structure
	  Image.Image_Structur
	  Margin.Margin_Structure
	  Size.Size_Structure
	  Map Button.Button_Structure()
	  Map Style.Style_Structure()
	  List Row.Row_Structure()
	EndStructure ;}
	Global Requester.Requester_Structure
	
  Global NewMap Image.i()
	
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
	
	
	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure	
	
	Procedure InitDefault_()
	  Define  *Buffer
	  
	  ;{ _____ Margins  _____
	  Requester\Margin\Left   = 10
	  Requester\Margin\Top    = 15
	  Requester\Margin\Bottom = 15
	  Requester\Margin\Right  = 10
	  
	  Requester\Padding = 10
	  ;}
	  
	  ;{ _____ Colors _____
	  Requester\Color\Front  = $000000
		Requester\Color\Back   = $FFFFFF
		Requester\Color\Gadget = $F0F0F0
		Requester\Color\Border = $A0A0A0
		Requester\Color\Button = $E3E3E3
		Requester\Color\Focus  = $D77800
		
		CompilerSelect #PB_Compiler_OS
			CompilerCase #PB_OS_Windows
				Requester\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
				Requester\Color\Back   = GetSysColor_(#COLOR_WINDOW)
				Requester\Color\Border = GetSysColor_(#COLOR_WINDOWFRAME)
				Requester\Color\Gadget = GetSysColor_(#COLOR_MENU)
				Requester\Color\Button = GetSysColor_(#COLOR_3DLIGHT)
		    Requester\Color\Focus  = GetSysColor_(#COLOR_HIGHLIGHT)
			CompilerCase #PB_OS_MacOS
				Requester\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
				Requester\Color\Back   = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
				Requester\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				Requester\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
				Requester\Color\Button = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
		    Requester\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor keyboardFocusIndicatorColor"))
			CompilerCase #PB_OS_Linux

		CompilerEndSelect
    ;}
		
		;{ _____ Buttons _____
		If AddMapElement(Requester\Button(), "OK")
		  Requester\Button()\Text   = "OK"
		  Requester\Button()\Result = #True
		EndIf
		
		If AddMapElement(Requester\Button(), "Yes")
		  Requester\Button()\Text   = "Yes"
		  Requester\Button()\Result = #Result_Yes
		EndIf 
		
		If AddMapElement(Requester\Button(), "No")  
		  Requester\Button()\Text   = "No"
		  Requester\Button()\Result = #Result_No
		EndIf 
		
		If AddMapElement(Requester\Button(), "Cancel")  
		  Requester\Button()\Text   = "Cancel" 
		  Requester\Button()\Result = #Result_Cancel
		EndIf   
		;}
		
		;{ _____ Images _____
		CompilerIf #Include_DefaultImages
		  
		  If AddMapElement(Image(), "Info")
    		*Buffer = AllocateMemory(2221)
    		If *Buffer
          UncompressMemory(?Info, 2197, *Buffer, 2221, #PB_PackerPlugin_Zip)
          Image() = CatchImage(#PB_Any, *Buffer, 2221)
          FreeMemory(*Buffer)
        EndIf
      EndIf
      
      If AddMapElement(Image(), "Question")
        *Buffer = AllocateMemory(2372)
        If *Buffer
          UncompressMemory(?Question, 2352, *Buffer, 2372, #PB_PackerPlugin_Zip)
          Image() = CatchImage(#PB_Any, *Buffer, 2372)
          FreeMemory(*Buffer)
        EndIf  
      EndIf  
      
      If AddMapElement(Image(), "Error")
        *Buffer = AllocateMemory(1949)
        If *Buffer
          UncompressMemory(?Error, 1929, *Buffer, 1949, #PB_PackerPlugin_Zip)
          Image() = CatchImage(#PB_Any, *Buffer, 1949)
          FreeMemory(*Buffer)
        EndIf 
      EndIf
      
      If AddMapElement(Image(), "Warning")
        *Buffer = AllocateMemory(1984)
        If *Buffer
          UncompressMemory(?Warning, 1965, *Buffer, 1984, #PB_PackerPlugin_Zip)
          Image() = CatchImage(#PB_Any, *Buffer, 1984)
          FreeMemory(*Buffer)
        EndIf 
      EndIf
      
    CompilerEndIf
		;}
		
	EndProcedure
	
	;- __________ Drawing __________
	
	Procedure   CalcSize_()
	  Define.i maxWidth, buttonWidth, maxHeight, textHeight
	  
	  If StartDrawing(CanvasOutput(Requester\Gadget))
  	 
	    DrawingFont(Requester\FontID)
	    
	    ;{ _____ Buttons _____
	    If Requester\Flags & #YesNoCancel
	      buttonWidth = dpiX(#ButtonWidth) * 3 + dpiX(30)
	    ElseIf Requester\Flags & #YesNo
	      buttonWidth = dpiX(#ButtonWidth) * 2 + dpiX(10)
	    Else
	      buttonWidth = dpiX(#ButtonWidth)
	    EndIf ;}
	    
	    ;{ _____ Text _____
	    maxWidth = TextWidth(Requester\Titel) + dpiX(20)  
	    
	    Requester\Size\Text = 0
	    
	    ForEach Requester\Row()
	      
	      If Requester\Row()\FontID
  	      DrawingFont(Requester\Row()\FontID)
  	    Else
  	      DrawingFont(Requester\FontID)
  	    EndIf
	    
	      If TextWidth(Requester\Row()\String) > maxWidth
	        maxWidth = TextWidth(Requester\Row()\String)
	      EndIf 
	      
	      Requester\Size\Text + TextHeight(Requester\Row()\String)
	    Next ;}
	    
	    ;{ _____ Image _____
	    If IsImage(Requester\Image\Num)
	      If dpiY(Requester\Image\Height) > Requester\Size\Text : maxHeight = dpiY(Requester\Image\Height) : EndIf 
	      maxWidth + dpiX(Requester\Image\Width + Requester\Padding)
	    EndIf ;}
	    
	    If buttonWidth > maxWidth : maxWidth = buttonWidth : EndIf
	    
	    Requester\Size\Width  = DesktopUnscaledX(maxWidth)  + Requester\Margin\Left + Requester\Margin\Right
	    Requester\Size\Height = DesktopUnscaledY(maxHeight) + Requester\Margin\Top  + Requester\Margin\Bottom + 40

	    StopDrawing()
	  EndIf
	  
	EndProcedure  

	Procedure   Button_(Key.s, X.i, Y.i)
	  Define.i Width, Height, OffSetX, OffsetY
	  Define.i BackColor, BorderColor
	  Define.s Text
	  
	  Width  = dpiX(#ButtonWidth)
	  Height = dpiY(#ButtonHeight)
	  
	  Text = Requester\Button(Key)\Text
	  
	  Select Requester\Button(Key)\State
	    Case #Focus
	      BackColor   = BlendColor_(Requester\Color\Focus, Requester\Color\Button, 10)
	      BorderColor = Requester\Color\Border
	    Case #Click
	      BackColor   = BlendColor_(Requester\Color\Focus, Requester\Color\Button, 20)
	      BorderColor = Requester\Color\Focus
	    Default
	      BackColor   = Requester\Color\Button
	      BorderColor = Requester\Color\Border
	  EndSelect
	  
  	;{ _____ Background _____
	  DrawingMode(#PB_2DDrawing_Default)
	  Box(X, Y, Width, Height, BackColor)
		;}
	  
	  Requester\Button(Key)\X = X
	  
	  OffSetX = (Width - TextWidth(Text)) / 2
	  OffsetY = (Height - TextHeight(Text)) / 2
	  
	  DrawingMode(#PB_2DDrawing_Transparent)
	  DrawText(X + OffSetX, Y + OffsetY, Text, Requester\Color\Front)

	  ;{ _____ Border _____
	  DrawingMode(#PB_2DDrawing_Outlined)
	  Box(X, Y, Width, Height, BorderColor)
	  ;}
	  
	EndProcedure
	
	Procedure   Draw_()
	  Define.i X, Y, Width, Height, MsgHeight, OffsetX, OffsetY
	  Define.i MsgHeight,  imgID, imgWidth, imgHeight
		Define.i FrontColor, BackColor, BorderColor
		
		X = dpiX(Requester\Margin\Left)
		Y = 0

		Width     = dpiX(GadgetWidth(Requester\Gadget)) 
		Height    = dpiY(GadgetHeight(Requester\Gadget))
		MsgHeight = Height - dpiY(40)
		
		OffsetX = 0

		If StartDrawing(CanvasOutput(Requester\Gadget))
		  
			;{ _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  Box(0, 0, Width, Height,    Requester\Color\Gadget)
		  Box(0, 0, Width, MsgHeight, Requester\Color\Back)
			;}
		  
		  ;{ _____ Image _____
		  If IsImage(Requester\Image\Num)
		    OffsetY = (MsgHeight - Requester\Image\Height) / 2
  		  DrawingMode(#PB_2DDrawing_AlphaBlend)
  		  DrawImage(ImageID(Requester\Image\Num), X, Y + OffsetY, Requester\Image\Width, Requester\Image\Height)
  		  X + Requester\Image\Width + Requester\Padding
		  EndIf 
		  ;}
		  
		  ;{ _____ Text _____
		  OffsetY = (MsgHeight - Requester\Size\Text) / 2
		  
			ForEach Requester\Row()
			  
  			DrawingFont(Requester\Row()\FontID)
  			
  			DrawingMode(#PB_2DDrawing_Transparent)
  			If Requester\Row()\Flags & #Center
  			  OffsetX = (Width - TextWidth(Requester\Row()\String) - X - dpiX(Requester\Margin\Right)) / 2
  			  DrawText(X + OffsetX, Y + OffsetY, Requester\Row()\String, Requester\Row()\Color)
  			ElseIf Requester\Row()\Flags & #Right
  			  OffsetX = Width - TextWidth(Requester\Row()\String) - dpiX(Requester\Margin\Right)
  			  DrawText(OffsetX, Y + OffsetY, Requester\Row()\String, Requester\Row()\Color)
  			Else
  			  DrawText(X + OffsetX, Y + OffsetY, Requester\Row()\String, Requester\Row()\Color)
  			EndIf  

			  Y + TextHeight(Requester\Row()\String)
			Next ;}
			
			;{ _____ Buttons _____
			Requester\ButtonY = MsgHeight + dpiY(10)
			
			DrawingFont(Requester\FontID)
			
			If Requester\Flags & #YesNo
			  X = (Width - (dpiX(#ButtonWidth) * 2) - dpiX(10)) / 2
			  Button_("Yes", X, Requester\ButtonY)
			  X + dpiX(#ButtonWidth) + dpiX(10)
			  Button_("No", X, Requester\ButtonY)
			ElseIf Requester\Flags & #YesNoCancel
			  X = dpiX(Requester\Margin\Left)
			  Button_("Yes", X, Requester\ButtonY)
			  X + dpiX(#ButtonWidth) + dpiX(10)
			  Button_("No", X, Requester\ButtonY)
			  X = Width - dpiX(#ButtonWidth) - dpiX(Requester\Margin\Right)
			  Button_("Cancel", X, Requester\ButtonY)
			Else
			  X = (Width - dpiX(#ButtonWidth)) / 2
			  Button_("OK", X, Requester\ButtonY)
			EndIf ;}
			
			;{ _____ Border ____
			DrawingMode(#PB_2DDrawing_Outlined)
			Line(0, MsgHeight, Width, 1, Requester\Color\Border)
			Box(0, 0, Width, Height, Requester\Color\Border)
      ;}

			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
	CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      If IsFont(ModuleEx::ThemeGUI\Font\Num)
        Requester\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
      EndIf

      Requester\Color\Front  = ModuleEx::ThemeGUI\FrontColor
			Requester\Color\Back   = ModuleEx::ThemeGUI\BackColor
			Requester\Color\Border = ModuleEx::ThemeGUI\BorderColor
			Requester\Color\Gadget = ModuleEx::ThemeGUI\GadgetColor
			Requester\Color\Button = ModuleEx::ThemeGUI\Button\BackColor
			Requester\Color\Focus  = ModuleEx::ThemeGUI\Focus\BackColor
			
    EndProcedure
    
  CompilerEndIf 
  
  
	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If IsGadget(Requester\Gadget) And GNum = Requester\Gadget

			X = GetGadgetAttribute(Requester\Gadget, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(Requester\Gadget, #PB_Canvas_MouseY)
			
			ForEach Requester\Button()
			  
  			If Not Requester\Button()\Visible : Continue : EndIf
  		
  			If Y >= Requester\ButtonY And Y <= Requester\ButtonY + dpiY(#ButtonHeight)  
  			  If X >= Requester\Button()\X And X <= Requester\Button()\X + dpiX(#ButtonWidth)
  			    Requester\Button()\State = #Click
  			    Draw_()
			      ProcedureReturn #True 
  			  EndIf
  			EndIf 

  	  Next

		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If IsGadget(Requester\Gadget) And GNum = Requester\Gadget

			X = GetGadgetAttribute(Requester\Gadget, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(Requester\Gadget, #PB_Canvas_MouseY)

			ForEach Requester\Button()

  			If Not Requester\Button()\Visible : Continue : EndIf

  			If Y >= Requester\ButtonY And Y <= Requester\ButtonY + dpiY(#ButtonHeight)  
  			  If X >= Requester\Button()\X And X <= Requester\Button()\X + dpiX(#ButtonWidth)
  			    Requester\Button()\State = #Focus
  			    Requester\Result = Requester\Button()\Result
  			    Draw_()
  			    PostEvent(#Event_Gadget, Requester\Window, Requester\Gadget, #PB_EventType_LeftClick, Requester\Button()\Result)
  			    ProcedureReturn #True
  			  EndIf
  			EndIf 

  	  Next

		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GNum = EventGadget()

		If IsGadget(Requester\Gadget) And GNum = Requester\Gadget

			X = GetGadgetAttribute(Requester\Gadget, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(Requester\Gadget, #PB_Canvas_MouseY)

			ForEach Requester\Button()
			  
  			If Not Requester\Button()\Visible : Continue : EndIf
  			
  			If Y >= Requester\ButtonY And Y <= Requester\ButtonY + dpiY(#ButtonHeight)  
  			  If X >= Requester\Button()\X And X <= Requester\Button()\X + dpiX(#ButtonWidth)
  			    If Requester\Button()\State <> #Focus
  			      Requester\Button()\State = #Focus
  			      Draw_()
  			    EndIf
			      ProcedureReturn #True 
  			  EndIf
  			EndIf 
  			
			  If Requester\Button()\State
			    Requester\Button()\State = #False
			    Draw_()
			  EndIf
  		 
  	  Next

		EndIf

	EndProcedure
	
	;- __________ Requester Window __________
	
  InitDefault_()
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    BindEvent(#Event_Theme, @_ThemeHandler())
  CompilerEndIf
  
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================

	Procedure.i Requester(Title.s, Text.s, Label.s="", Flags.i=#False, ParentID.i=#PB_Default)
	  Define.i DummyNum, quitWindow, Result
	  Define.i r, Rows
	  
	  CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
	  
	  If ParentID = #PB_Default
	    Requester\Window = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_Tool|#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
	  Else
	    Requester\Window = OpenWindow(#PB_Any, 0, 0, 0, 0, "", #PB_Window_Tool|#PB_Window_SystemMenu|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(ParentID))
	  EndIf
	  
	  If Requester\Window
	    
	    SetWindowTitle(Requester\Window, " " +Title)
	    
	    Requester\Gadget = CanvasGadget(#PB_Any, 0, 0, 0, 0)
	    If Requester\Gadget

  	    CompilerSelect #PB_Compiler_OS ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						Requester\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							Requester\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						Requester\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}
				
				ClearList(Requester\Row())
				
				;{ Buttons
				If Flags & #YesNo 
				  Requester\Button("OK")\Visible     = #False
				  Requester\Button("Yes")\Visible    = #True
				  Requester\Button("No")\Visible     = #True
				  Requester\Button("Cancel")\Visible = #False
				ElseIf Flags & #YesNoCancel
				  Requester\Button("OK")\Visible     = #False
				  Requester\Button("Yes")\Visible    = #True
				  Requester\Button("No")\Visible     = #True
				  Requester\Button("Cancel")\Visible = #True		  
				Else
				  Requester\Button("OK")\Visible     = #True
				  Requester\Button("Yes")\Visible    = #False
				  Requester\Button("No")\Visible     = #False
				  Requester\Button("Cancel")\Visible = #False		  
				EndIf ;}

				Rows = CountString(Text, #LF$) + 1
				If Rows
				  For r=1 To Rows
				    If AddElement(Requester\Row())
				      Requester\Row()\String = StringField(Text, r, #LF$)
				      Requester\Row()\Color  = Requester\Color\Front
  		        Requester\Row()\FontID = Requester\FontID
  		        Requester\Row()\Flags  = #False
				    EndIf  
  				Next
				EndIf
				
				Requester\Flags  = Flags
				Requester\Result = #False

				;{ ____ Image _____
				If Requester\Flags & #Info
				  Requester\Image\Num = Image("Info")
				ElseIf Requester\Flags & #Question
				  Requester\Image\Num = Image("Question")
				ElseIf Requester\Flags & #Error
  		    Requester\Image\Num = Image("Error")
  		  ElseIf Requester\Flags & #Warning
  		    Requester\Image\Num = Image("Warning")
  		  Else  
  		    Requester\Image\Num = #PB_Default
  		  EndIf ;}
  		  
  		  ;{ _____ Label (Style) _____
  		  If FindMapElement(Requester\Style(), Label)
  		    
  		    If IsImage(Requester\Style()\Image)
  		      Requester\Image\Num = Requester\Style()\Image
  		    EndIf  
  		    
  		    ForEach Requester\Row()

  		      If FindMapElement(Requester\Style()\Row(), Str(ListIndex(Requester\Row())))
  		        Requester\Row()\Color  = Requester\Style()\Row()\Color
  		        Requester\Row()\FontID = Requester\Style()\Row()\FontID
  		        Requester\Row()\Flags  = Requester\Style()\Row()\Flags
  		      Else
  		        Requester\Row()\Color  = Requester\Style()\Color
  		        Requester\Row()\FontID = Requester\Style()\FontID
  		        Requester\Row()\Flags  = Requester\Style()\Flags
  		      EndIf
  		      
  		      If Requester\Row()\FontID = #PB_Default : Requester\Row()\FontID = Requester\FontID : EndIf
  		      
  		    Next  
  		    
  		  EndIf ;}
  		  
  		  If IsImage(Requester\Image\Num)
  		    Requester\Image\Width  = ImageWidth(Requester\Image\Num)
  		    Requester\Image\Height = ImageHeight(Requester\Image\Num)
  		  EndIf  
  		  
  		  CalcSize_()
  		  
        ResizeWindow(Requester\Window, #PB_Ignore, #PB_Ignore, Requester\Size\Width, Requester\Size\Height)
        ResizeGadget(Requester\Gadget, 0, 0, Requester\Size\Width, Requester\Size\Height)
        
				BindGadgetEvent(Requester\Gadget,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
				BindGadgetEvent(Requester\Gadget,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
				BindGadgetEvent(Requester\Gadget,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)

				Draw_()
				
				HideWindow(Requester\Window, #False)				
	    EndIf
	    
	    Repeat

        Select WaitWindowEvent()
          Case #PB_Event_CloseWindow           ;{ Close window
            If EventWindow() = Requester\Window
              quitWindow = #True
            EndIf ;}
          Case #Event_Gadget
            Select EventGadget()  
              Case Requester\Gadget
                Select EventType()
                  Case #PB_EventType_LeftClick ;{ Left mouse click
                    quitWindow = #True
                    ;}
                EndSelect
            EndSelect
        EndSelect
        
      Until quitWindow
      
      UnbindGadgetEvent(Requester\Gadget,  @_MouseMoveHandler(),      #PB_EventType_MouseMove)
			UnbindGadgetEvent(Requester\Gadget,  @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
			UnbindGadgetEvent(Requester\Gadget,  @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
      
	    CloseWindow(Requester\Window)
	  EndIf
	  
	  ProcedureReturn Requester\Result
	EndProcedure
	
	
	Procedure.i Create(Label.s, Color.i=#PB_Default, Font.i=#PB_Default, Flags.i=#False)

		If AddMapElement(Requester\Style(), Label)
		  
		  If Color = #PB_Default
		    Requester\Style()\Color  = Requester\Color\Front
		  Else
		    Requester\Style()\Color  = Color
		  EndIf  
		  
		  If Font = #PB_Default
		    Requester\Style()\FontID = #PB_Default
		  ElseIf IsFont(Font)
		    Requester\Style()\FontID = FontID(Font)
		  Else
		    Requester\Style()\FontID = #PB_Default
		  EndIf  
		  
		  Requester\Style()\Flags = Flags
		  
		  ProcedureReturn #True
		EndIf

	EndProcedure
	
	Procedure   SetImage(Label.s, Image.i)
	  
	  If FindMapElement(Requester\Style(), Label)
	    
	    If IsImage(Image)
	      Requester\Style()\Image = Image
	    EndIf  
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemColor(Label.s, Row.i, Color.i)
	  
	  If FindMapElement(Requester\Style(), Label)
	    
	    If FindMapElement(Requester\Style()\Row(), Str(Row))
	      Requester\Style()\Row()\Color  = Color
	    ElseIf AddMapElement(Requester\Style()\Row(), Str(Row))
	      Requester\Style()\Row()\Color  = Color
	      Requester\Style()\Row()\FontID = Requester\Style()\FontID
	      Requester\Style()\Row()\Flags  = Requester\Style()\Flags
	    EndIf
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemFont(Label.s, Row.i, Font.i)
	  
	  If FindMapElement(Requester\Style(), Label)

      If FindMapElement(Requester\Style()\Row(), Str(Row))
        
        If IsFont(Font)
          Requester\Style()\Row()\FontID = FontID(Font)
        Else
          Requester\Style()\Row()\FontID = Requester\Style()\FontID
        EndIf  
        
      ElseIf AddMapElement(Requester\Style()\Row(), Str(Row))
        
        If IsFont(Font)
          Requester\Style()\Row()\FontID = FontID(Font)
        Else
          Requester\Style()\Row()\FontID = Requester\Style()\FontID
        EndIf
        
	      Requester\Style()\Row()\Color = Requester\Style()\Color
	      Requester\Style()\Row()\Flags = Requester\Style()\Flags
	      
	    EndIf
  	  
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemFlags(Label.s, Row.i, Flags.i)
	  
	  If FindMapElement(Requester\Style()\Row(), Str(Row))
      Requester\Style()\Row()\Flags  = Flags
    ElseIf AddMapElement(Requester\Style()\Row(), Str(Row))
      Requester\Style()\Row()\Flags  = Flags
      Requester\Style()\Row()\Color  = Requester\Style()\Color
      Requester\Style()\Row()\FontID = Requester\Style()\FontID
    EndIf
	  
	EndProcedure	
	
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)

    Select Attribute
      Case #Padding
        Requester\Padding  = Value
    EndSelect
    
  EndProcedure	
	
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    Select ColorTyp
      Case #FrontColor
        Requester\Color\Front  = Value
      Case #BackColor
        Requester\Color\Back   = Value
      Case #BorderColor
        Requester\Color\Border = Value
    EndSelect
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, Font.i) 
    
    If IsFont(Font)
      Requester\FontID = FontID(Font)
    EndIf
  
  EndProcedure  
  
  
  ; _____ Image Data _____
  
  CompilerIf #Include_DefaultImages
    
    ; License: http://creativecommons.org/licenses/GPL/2.0/
    ; Source:  www.inkscape.org / GNOME-Colors
 
    DataSection
      Info:
      Data.q $5A143C7996559C78,$42ED724758CFC71B,$1964D631BB2446DC,$631A1443592C614C,$36F4C4D6B1832667,$5C4496495B95B5EA,
             $A3BDE5912C8CD429,$C94296B83BA90649,$BCF977A8EE0DAFBE,$E79CF9F7E73CF3E7,$349CE7AFE79CFDF7,$0007B203A16B4727,
             $C28E172836B64200,$090909D9C7CA13F6,$028D6768BBE11CAB,$088E15E35596D63F,$9FB5821C08BC6DE0,$58C3FDB8BC954B10,
             $FB7D70787FD045BC,$0B28B692FC003E41,$72E161BBFCF6CF37,$F377CC1B7B1D921E,$9159E4AAC30D2AEF,$50D05D225FF87D17,
             $1A3EB94DA42C95E7,$F1748C5986CF7689,$098CF06EA4C48B93,$44F12AF36C598A16,$A88ACB26CDE3AFBC,$A848252878C05BB9,
             $30CBC94141504A33,$584ED99E63A677C3,$10734231D7BA4D30,$5818199FA81E5BAF,$8B4A244C2ADBDBC9,$086A38AAFF4CBE7E,
             $069BE03B9A850DC2,$FC9371AA97A83EA7,$601AD47DC282D517,$CD263FEC4FC11364,$81809A07132617D5,$FD038713F6F3CAF9,
             $FABDD8E3A027BFAC,$1EC38BAB638462D7,$2CDFBFCA42A57576,$33B72EB4B759BF8F,$15815C6B9F4355D5,$AECF6A6ED37BA38F,
             $79A8AFDD5D48E1ED,$91DD5619AEFCDD84,$DAC5548249E08351,$6CD78AA137F177A9,$20F266F139920054,$7F1E09E6F8CA51B5,
             $E7FD977857DBAB32,$FDBE4384D32E055F,$64C1D1FD5C2BF9C4,$FB7C275AB3F33E19,$D38D76F63839A7BF,$7E308D47232BDC51,
             $F56934B48B40FD07,$45F06832428A0530,$6F63DB2534FD2424,$F9171DE8E25DFBBA,$BEBF7161F350E8A6,$CDADBDE97A77BED6,
             $5D75440B56A687CC,$4F0F8212FB733CC8,$CA005AA050C89ACF,$DB5D5F0A6DF01145,$DD70B1C55565CF47,$6121E96AD6E84B6C,
             $866B5D5A5D84D2AA,$63A334F270A6A550,$C8A27DB9687BB5E8,$DBD596634F6DD80D,$86CEE30885BF093F,$CB83C38842AE9BF6,
             $F1BF37444BFD8622,$B35636C79D8DAEAB,$5AFCE1C9ED1A5ECB,$A5D7BE870D4DF90F,$083FCD2721113A2F,$008DCDF1ED39B882,
             $D474942AAD885745,$5A4831182C5B4192,$DABF4F553D90CDF8,$697D57CDEF9C2659,$1ACF162CC13AF6CF,$2AD6BB9433C092FF,
             $834844CB61A93DC3,$170BEB0F75A631CD,$16906D79B5FBEB50,$52AE248A01225CB8,$CC76E3DD1FFCFA7A,$3F189739C8A9ADD8,
             $47B38745C2EA3D51,$F89F02FBBF1E46AE,$696226EC89554F9C,$00A1886D04A15560,$943B02AD2880C905,$B1861AC1CD9BE5A5,
             $3A7906BE77DB6746,$6868589305B8A87C,$0D8C1C1C2FE04414,$93B6916CCAEEB41B,$2FCFDF4BFD8AA6EB,$0FC838305C3B888E,
             $CFBCEA8725871936,$316673AE4E680048,$60AF4656CEEBE1E6,$92EB4EDBCEF9694C,$700375B3FAF76A5C,$290BFAD56BEF23F0,
             $D18ACC13D23139D4,$5512A28373F65BFA,$2F72028C7C58C86F,$BCF77B88B9F9D0F4,$F4F00CA1B4F97FFA,$4D5FE3A89999CAF5,
             $A0803C956E5B0FA0,$68F22FF55D472A6B,$485F3A6C95A158CC,$F3C5983313F02890,$41B9C7B568DDE7E7,$CC57749F6E17D3F5,
             $576A0BDD687E39C8,$9B62123F6C5000B8,$4936F998B1ED6B34,$604BF109E2106AD9,$001BB4C8B537D75A,$67A21F42E2ACA638,
             $2EE22E8DE0AA1931,$021A6B0D8537B341,$4CDC3201D733DBC6,$5BC59C75EFA975C1,$A970E814BD54D113,$3775500C935B895C,
             $EA9644E5087EBA30,$1733B0781F04252B,$28DD9006F0B0B953,$B40A8B0D11DB70E4,$6D42C25FD90946C9,$0906D8AF426BB6C4,
             $E88D64A8EE0A3FAD,$C5E8A4CE8E45EB53,$622A4930471194DF,$8A96D3D5C2E25EB9,$3799EC0D7EC778DF,$A4D1AA05082C94B9,
             $AA5429831317C9BA,$4B4F29A587548AE6,$FD9C504A5E280385,$2A9E550EFF98F452,$DA880A810FB8770F,$05E47C7A55517306,
             $75BD01E30E70FF6A,$C8F4B4BAAE826D91,$95DB63FD0947969A,$4FCE579F170D9E73,$4AC4D7E4D1142705,$A5BCB9193375E29C,
             $EA4E9A0FDC450D39,$467BCF778E495E37,$10F9E0357F6290BA,$FB40B2E1EDAE7DF7,$D320F1D6396F7F5D,$E961933C4D5E0FD2,
             $7AF9F180F29AA2C0,$4EFC58577B68C7F1,$D8C2E9AC679281D5,$5F4E8B251436DC7F,$5663A30233726012,$766577381D516CBD,
             $F99474ADC2AF0A46,$13FBACACEC8DAEE9,$86A054494A3C0188,$40E7CDE17FD1383D,$4CC32AA3AA079B6C,$D273A469A014975D,
             $548117951CD92377,$221656E72C763DE5,$CC6AE1FE73E9694D,$997E09D31AAF920C,$A598A584133507EB,$53190C0A7280EA0D,
             $DE61F7F1CBB6F5FB,$DF0FD4CD5E4CB397,$7B399D19EA32BEC1,$F66B8507BB2792C8,$7EB8774F511DA631,$7CCA656D32EC4A9A,
             $5268EC35F71D873B,$3C9BB559DAAFE311,$89E5BBE7AD4803CB,$0AC958D5AC9343B3,$B362EC9A1B36B341,$289F2290ABEA6CF5,
             $70BD857DADD324FC,$3433B5F5EEE06F61,$8F77F210146BA700,$46DB325C755BAF37,$7C59C62A82FECB12,$A22CF23DC8D90F78,
             $CAB4D678EF69A68D,$42E4E5EFA9F86F79,$92F3971583007F31,$3CCFFFD078210274,$A2B51FCB8C8ED1C7,$E90AB6D5DAEF3567,
             $B6AAC752FE24A9B5,$FBA625BD4FC948CF,$FB3BF850EE561EB1,$166411C08D875E6B,$17E90D5FC9651AD9,$DE6D440FCCB77320,
             $6A4ADE58F27D6476,$247B4C999098D4F6,$1032776E3AAA8149,$8E9F2C7353B71A46,$BBBBCAAB3E615340,$5B3763E3BBC99CE9,
             $7F37C0E37CFA8166,$E4A9CDF313F406C9,$72D1B874CBE1777A,$37F6C1C663DE446D,$B4A46FEFCE12A205,$FCF4CC126EA5A0C1,
             $984F6DFCAFA486BC,$8BAF68B18A188C61,$8BAF04396C1DB4B0,$D6B41CA13CBE697B,$85DE8F8C6B7A467E,$AAB2186C0A2D3F18,
             $7F7FB25ED7A9EA3A,$5A2749FD71A0BAF2,$4078E7C841480F83,$D9E8247BA59B6828,$5E1ED7A5C9659721,$3CB728D182E5B48B,
             $79FAABC47A8DE7ED,$B0C6F8CC16A485D5,$21E04D40218FE6DE,$7BF5BD2328520A04,$EA1B170767ADC290,$3CA7D163CA5E713E,
             $2898C6B1A3FC03A3,$84D703AE0200472C,$31AE843770113423,$343709A10F58CF42,$3FFD9D5ED333C386,$6FFF181210170220,
             $C27E0DC747534740,$3292013F139F4758,$10FB01F6F401CA0B,$D1D1C1058092360C,$C485771FED6D6378,$41245C0888B83162,
             $42D3FE1DA415170B,$C16846D7B276B6D0,$CCBC39CAF943C3B5,$47FA268C0B8AEF3E,$0C890AD448910161,$6F2C7DD8F1FC6023,
             $8A69FF12639644DE,$8719E3B58160C289,$A1145C70B8569A53,$AFFCEB29C6351722,$7036DFFF62EEEBEC,$1C282E1C20AD5801,
             $141DAF1B4569C5AB,$DAB07E626AC08B89,$ED875FFD99B4F24E,$BF94BF4B33D44729
      Data.b $01,$F7,$09,$F1,$AD
      Question:
      Data.q $FBD33C7B96559C78,$AD93A15B73BFC71F,$09736C3AEE8CBF72,$3F6CCD1CB0986B33,$0973636318D9A109,$B8E7513514B91B69,
             $EDCF7211342A63A7,$E74A244C7112E4B8,$9BF0747E3A90A2AC,$BC78F3EFC7977E73,$3F3D7EF3E3C7AF3E,$4693E7CFF3E3F79F,
             $0008A9A8A5DC7570,$B0EA511C27672EC0,$D8D8ECCE9050ED6D,$0711CA7F3853522F,$6D492E9BECD635FC,$DBC4252D93C9CB27,
             $8C5ED98BC91DD902,$D6520787FE06D962,$B38CE15C00000BF3,$B18BD1F82CE99D25,$18181925B3D1AC57,$103168864E0D121A,
             $EE93F587BDAC8272,$6F93B64F7337AA00,$C6B1C709DB9F33E2,$1E9DBB9D873ED868,$0C1C0CC682BF13AC,$258A192523D065C9,
             $26A85E5412789966,$8A29102A8FE7CABF,$E9ABD3715F6021ED,$6160662B767C8586,$E0D2E6AA208CE261,$867AC4825AFE40C2,
             $AFF9D59E60810C9A,$438FDD8D36039A56,$4F242551522A6734,$E37D3E9250ACD860,$3EBBC05DC165FACA,$D38FF415E7F5ADE6,
             $065B549E573AFCBB,$06A3EDFCD89F537E,$60E107CBFAB67D7A,$1D07CA9F5B7A9205,$ABAE8A182F6726B1,$E293B0D1D1FC5BBE,
             $8BFC377C2B6232A0,$195A292D2DFCB7C7,$F3CE38BAA4FF973A,$B6075A0DD35E7943,$2FB2B1D45DA1DBD5,$412E9D053D7A58BE,
             $D7DB4BBA208D7841,$4DCF46E0D626FCF8,$D6E53792B5A3AF37,$769B22F981A75BAE,$C5CB455A5EBD0CB3,$D74487EE9AC7A2D3,
             $243CE9B3E535083D,$30D3E080FC500417,$EA7C8F364E501503,$2FAE32DF3A123DF9,$0276FA48453278C7,$CE66E1F149F5975D,
             $2BDFA7D4D6B88B9C,$4D0FE9FB262AF1F6,$74D9E51432E179EA,$EC1971D76C1D1AFD,$E879747B8D802E5E,$862F776FC2D701D6,
             $DBD51DBFE8EBACC6,$E22063C6276B108C,$98662BC5E0B91E09,$D3D85D87A5BADE4F,$37B866F0469C8264,$95B8755E56E5A871,
             $EB72F714ABDD4747,$5E3BE2F014DE2D47,$27B11A7ED0B5D364,$DF396C6348CB44FA,$8FD62B4D2BFB91D3,$F6EFE35E35E9A5EA,
             $C03C893026393B14,$C1837F6AE77696B9,$0F6DACB12805CC66,$DA357654726217B0,$F929B946C9ED566C,$29FBC2E6E5A682DE,
             $B1C87C383A23FC60,$26300BC61187C2F0,$8E9CA256434DBC2F,$C136FE14652F7564,$9C5B334479D7EDF1,$C8044D7C264BD25D,
             $241DEBA620B8B057,$8CB13371E566DB48,$D907780EFEC5DB3D,$0838CB38AF0AD9D9,$0DB74BF15C764855,$7EF6A2717FC44EFF,
             $F29E96A778C47C58,$E6AAA8793E4E375C,$7AEB86C7461FC745,$E73CDA572E2BAABB,$8302D1FC12746E99,$B8E9B228AAEC9774,
             $B6EEDD4C069F0F74,$F6E3454CCFD477EB,$BAECA2BF12D0D9DF,$9D122817C25FAAA6,$CF743CBA92C31476,$F72F040DDF3F0742,
             $C23C336F91CE4139,$08766C5A8B526B23,$DA13D9037A989865,$7AECD6D004929387,$064663C8D2AED9D4,$2A41555316EA4F93,
             $84FB0135DC43A76E,$E4FA7ED7F58534F1,$395C9487BDC36680,$12BE2AC4FCCBA52D,$91F3B3FDDC172ED0,$7371CD645C3E81B7,
             $C7F1343001AC6A6E,$F5D6F273EE5EFDAF,$4FA36BC13C83BF0D,$A9463012A0D767BA,$E1C87737A7AADE2D,$94FF4DE8001D505D,
             $FB4513D2BB882603,$B08CCA3152951C1E,$75004F08CE3592BE,$CE3906CCF07C42A9,$87349E5745557468,$B5ED3ABBDF7CC995,
             $BA3C949292E14F28,$AD25F87154ED2B5F,$6B9EE1913F3EEE63,$2DECCB12E1083C9A,$917391B56DF948CC,$ABF63B6564DF98DC,
             $C7FB65BC8BA27AA3,$D8142CDFF96B816C,$F00499118A6EFEA6,$8C4054206A8C7AFD,$D769CC7FA42501C4,$DE01E717A1BBDBCD,
             $8C6AF9F62C15D545,$ED9F8AE0146BCA1A,$6937C7E7EA71BD7E,$B6033D3168E3005D,$53519E5669B4438F,$A1DDD35DC1DE33B1,
             $1ACD5161C7267BAF,$EA622FB668FA2C04,$A97B4C5ECF93CD75,$B7F3856A0F932F57,$0532B8BDADFBAABE,$39A20EA5F9224952,
             $7782EF33B382DAAB,$9373FCAF9246795D,$FCAB20849FF0FA92,$70359D2A50397AF8,$246B0C17DEF806CB,$9379D749B474628B,
             $955ADCF33AF321E9,$2DBAAC02768F27E6,$4F0922AD4A9EED05,$1A1B65674FA21953,$46B2369374C73963,$CFFB56CDBBF79185,
             $5956CA0ED918A9C9,$D371F60730915C02,$E835F34062EE1F74,$691205BB9C9C35E2,$53BAE708DC4D9E53,$7CD55D1E9BAD4CB2,
             $A89BCB7DB70A9BA3,$209520599A0F062A,$98144A75DB828432,$098187E8A599A665,$B284F583E5F77DFC,$9732951421B4D67A,
             $DF3E5582B6AE8176,$CF4DD8271CFE4AFF,$163AF63FDC096B6B,$7AF86A9DEA1DB4F3,$4739A74400ED4736,$CF728B64F4773A2B,
             $0EC3C4827BBE6B6A,$9EA322FEB972B852,$86E97B0F44BC3F89,$1F73F6C3359F8303,$B3D3A5BD1EE76AAA,$01BFCD9DBB182C3C,
             $406E93E0693B3BC5,$9FA53D610F8CCE89,$ACA7F2F57017B8FE,$21D8B7940DE6B676,$B51C129880ADF4A1,$6FBA71CBE16C5B9F,
             $05F98E4D44A6C163,$76F6812DEF9DE32B,$7E7D2F5A36C5B58C,$DB4869D1E1ADB3D5,$8A0F15476104A5D3,$CC883F7E5BEC4FB2,
             $A1D5FBF2FD349ECB,$B7753F197C400050,$95F5B89B468D15BC,$68837B54CED752EC,$C5F7366F494D886F,$BE0DB4150F62CC77,
             $762F4270B87E118C,$474CDC9533C5685E,$7A69251B4F7096D2,$2F9EE1C05757767F,$3DA2E21860C5946F,$000F14C24B11B5F1,
             $386B8B08823CFCD8,$E9FCD7899639BB04,$BC929FE128A9DEA7,$EDA950B40A564DC5,$E000CA00EFA5C1A0,$CDEBF57911327207,
             $06F3C03634046D6C,$448DACDF8A8B980F,$DE1D3897B71F4DB7,$9FA6B2F9479E2043,$8B0AC276FCBDF58F,$2CD2438E125E04B7,
             $C0E043D249AC50B1,$3E76BCB235660594,$0ACF41919B9E94AE,$EE4E290323593DD7,$B21E4ED20FF56CEC,$F279A231449317C5,
             $DAE584E809D3E5C7,$AF5ED4DC82E494C7,$532EE3F78D70D961,$997CD4CF332667FB,$23ECE5943FF6EDCA,$140DF0588FA529CE,
             $2BECC2C692056D4D,$955978FBEFBD1DCD,$B3EDD71AE9BED64A,$DDDF1EE1EF7F52D3,$FADF7EAB4F369151,$40F0D15C5D41FE60,
             $C3243D28FC5D5837,$FA7FB9147A1FB156,$C31D6BB3B7A1B1C5,$CE06400F9278B271,$9FF73C00A17318B9,$C4448D54FD344576,
             $C0CA3858AFE7E7F9,$E14D1A9DC9ED9F28,$C6A52D3B76B44A9D,$20E6AB3D19B7C9EB,$76170C80F3C1E2AE,$B3DEA04BA7E4FAC7,
             $03E9246369EFB948,$CFE0138670E3907E,$2601A9541128A2A1,$3484626108C22408,$842856E650209925,$95D8408502C21185,
             $E803328407FFB972,$2448469006FF0BB4,$9690A39A42856109,$80A57AEB97AF037F,$D8C350A742E036D9,$F0E0A161C3882054,
             $D0CC295147A2CEBF,$08111998DB186650,$2E091DC3611DFC67,$70AC119C04631370,$1A4CEEF36C6BCA4F,$4747440A823FDA27,
             $167F14D842C3D31B,$8694D684FBCB1B75,$0150A08C8A1DFCF6,$33D918383FD3D747,$8DEE0E597608CC19,$744C97D95FFC8CB4,
             $2071AA00CC1B6FF9,$815B4B1AA0C81993,$11AA50CC6181E0B3,$DF9DA9D04E162FE5,$7644E2B83B390CFE,$2A2D7BE9017FFC7E    
      Error:
      Data.q $FBD3387BD5559C78,$65C8CDB5AFF0001F,$D765D1CB91258B73,$B99AD2C26B644C26,$244D9B612E666DCB,$9D08BF34D7264A44,
             $8A98E7558A13CB93,$71CF30E9D4A709DF,$919597248F225CAD,$3EFCF2EFD4DFA95A,$7EF3E79FBCFEF3CF,$9D2E77BFFBCF9EBF,
             $400007548EA9AAE6,$8DD36650C28DDDD3,$15A9D4E0B7954180,$DF00A5761F868265,$C6A4CA196D83A7CF,$A846C8C528100B73,
             $F1263C6E4E2BAD90,$B2A28E40F1FF5148,$FFB79214EE21494A,$C31F3D5CC17E2D1F,$0339AAAAF2F2D2D3,$70B5DC73A065A8C9,
             $A91ACE720BB9184F,$DEF1AA8E35BDD669,$42C5B8DF7C2593DC,$711CD9BDDF9D1AA1,$2838722CED016B17,$85171523C56D6EDC,
             $3EC303C7C889A6E7,$48172AAF2F1F1EDF,$81639C7D39491FE7,$EDE124125E7F766E,$1FDB6954B2FDF265,$5B62C3EBA366D842,
             $EEA33CEDFCEA6E20,$3A05EE77CDC71DC8,$55C6644E09955834,$B794F8A78431B24F,$147C472D81FC8665,$898736261273138C,
             $D8D9F62A7721C2DB,$ACB23AF3D9FD0534,$6B9441B3C16017B7,$A8ABD233A693FD99,$60ED7A4A26EE5694,$C991F6B3ED656614,
             $BE85CCBBD4D896A2,$091767C59237B1B8,$C7EED335D4C26ABA,$8ADDC4CA0EA01224,$CBD8F023309319D0,$4207C6F940C0CE7B,
             $CF8BA8BD4B240E4C,$A655819C2C665F87,$B7568564D6EA36BD,$7AE43B25B694D6AC,$65A0F646F83E77AB,$DE0C81AC2D3CA0E1,
             $DD0C2C239C31B147,$72169D8C7098A440,$B77ED73B5DD0AC58,$22F7A63E75CB3AC3,$8D5554BB1FA735BB,$4D868E8B1A9EA68E,
             $FD23B49834B9E3BD,$E4C0FF5B80D523B7,$6F6D77335E144D0C,$98C90B36B34B6AD8,$EFC0CD333F7A5A7B,$6E4E4D6928911D43,
             $6440B43422CF919B,$CF7F347E0B599C80,$BE8924EAE88287D9,$AC69C8E8E8BADD7D,$8877CD2C526C3961,$07A7255AB10E3A8F,
             $6DA97B3DA67EBF56,$B89A57CFB4DF6F6F,$10A0DEEB7E8E805A,$20ADAAADDBCE0CDD,$AB6F348D7FA4D7A1,$9C1272D2965E4D20,
             $043D9F22C9B4ACBE,$BBD430A8B1314F57,$01461CA579237020,$8473028F7587D433,$CC65454681226366,$39FE5082703C4E28,
             $8EE2223F8C7E8CD7,$6D7B67E97DF09567,$E70F8202347CFBA2,$87C6CDB3CEC34586,$6B8A49824D378066,$D489F241CFDDA74E,
             $D50D75C8ADDE6886,$F5566D9F7DB8A1F0,$8763D4576B82EEC4,$FAEA2DD1DB186976,$0311D2FDA213B947,$AFFE6BF826C80A87,
             $758A0B7B074A8A37,$A855689855D71918,$880805E8966F7969,$D6CBB4353BF749EC,$2A89DA1DC9765B70,$41FD2A478A9B11FE,
             $9792E7013F1EDFC0,$2E1417CFAEA212C2,$EFEC4992365DDE81,$17EEB6AF8515A845,$B67E9BED9686C3A3,$B88FB855BF9627D4,
             $CAA3DF3C97435C9C,$DD8FC5162AD588AA,$4BA1ABC674A88B81,$1E326BC32F6ACD3F,$BAB6C7496A19096B,$2BE7D92C5520953D,
             $923999527E656AAC,$1EF0300D9D962D4A,$2972310D65ADDF73,$77D60439538262DD,$BC73F202F52BB169,$05AC9DCED7A54CBC,
             $886C7029E4C2CDEB,$356F7A0D4F98A000,$D269CAD513A25B3C,$1A1CCB176F97CD1F,$DCB6D2BDBBC50C5D,$080D914C55935745,
             $91A74282CEEAE33A,$F7BF50A71F2EFEC1,$566A2DA297C54A27,$406476DA697F8EF5,$97BA7D49E46C69E2,$2725F5B47B26A678,
             $E277D2B6AEA13EE4,$6B3C8DAD0F01964D,$D79F765764BEE26B,$D1D698426930C5E9,$247BDB6985757554,$75E2C8C2A9628E66,
             $1AC9EF39B2749842,$8094DB485323C3C2,$AC16AC44B599EA58,$94050303B5B88BCB,$4E05F4FC6ED5DF36,$CF3B91CD21FC485A,
             $D2528F323AC6B3FB,$731F8BD16A29E41D,$98480F35F3329FBC,$BF65E9ABC177CF07,$5C9BD6864058996A,$B60E954BC1739CF2,
             $49148F796D5FCA34,$35C706D4147BC163,$AB72CCE9B287E874,$49EBE58127B1785A,$346EB72D3AE63F58,$83A1AEAB1B001D8E,
             $E379CEC6D48C4597,$CEB51F6B705942FA,$C1615EB8C866E7A9,$31597E85B31E2E99,$DE5F650CE3B298E7,$8E0E0EBF877E1BED,
             $A9B672BF88864F70,$E925D72A82959774,$589FEE18BF8E630F,$42E647695D9DF6A2,$3D9231A5DC0EAB7E,$D1E17CB918CCBF75,
             $1D3C26C9ACED06AB,$3D58042FAEAAB74A,$CD9E53302DC049A0,$E4EF7ED6E2BFEF4E,$1D3AF02BCCB53BF3,$DCE07F39BD543D6F,
             $BADBF96210E92A45,$FA1EAE5FE7BAEFDF,$27780D50A3E549DB,$6A704A012E037B74,$FA69B8ACCC7CCEAA,$1BD89C17F9B9F4CB,
             $6A80B64C668786F1,$02C2FD2AA29D17BD,$3E6BF59122C17326,$4562A96CF6577FC9,$EE07D9F4187A7750,$906AA26889B1BD89,
             $270E0EC5B1D3E4F1,$7E4E958C6DB056E0,$9D57C17BD3195585,$590721D2FE9A130A,$2F194A1F894DC782,$45CA2ABC81CB2027,
             $4927543E686DFD61,$B599AFBA0178AB5F,$51E1121377784A50,$858477F5F3C0091D,$ED1E8CADBAEF0C83,$683E74CB311BB6C8,
             $BD1A75D74CE2ACE4,$A91FCDD870F1E01E,$2ECC1A07070A79A1,$CA7B56246B89C220,$A0FAA3319980C283,$9B2437A804104551,
             $F3DB65F71DB0029B,$276FB1A86B40A9BF,$E2E89960CDCA9834,$7C5913644CC1189F,$C28B0E2C780132B6,$112F7E37AC7851E2,
             $112DAC28F012204F,$103FFDF76DCA2D8B,$C037F94C89888DCF,$67113DAC6F3870A1,$25EF5300FDD9C443,$58623C01B080944F,
             $F22627440D808E6C,$D89262BFF7CC1888,$734023973C7C6E2C,$8C022D1FB89851F9,$713163478303DD2B,$BDE1B46F4AF5A1C7,
             $481B3E4CC98991B8,$2C056270C7464E4E,$23F6962AC1BD8F26,$59F04E9A3FBA4D95,$EA0B88F47695C06C,$53963417CB8E3720,
             $7D4395FFB8CB295E,$46C11B831DFF1E18,$72B46C7151B97147,$B3C6E1C5130F0C14,$32D6DF4316EFAC51,$6694685DDD65B1BF,
             $47146100BFD65872
      Data.b $B8
      Warning:
      Data.q $D9DB340995559C78,$696A309621FFC71E,$1244CA5B520D2D3D,$6348A4A221746BEB,$792452C44578C529,$4190F10DD6FB1892,
             $2B5542E955495B5B,$1963465AF0FB18FA,$84528D3B4696956D,$779CB79D1351A258,$EFDFBFB9EFDDF9CF,$D9BDCF73DCF7BE73,
             $0012B6928AB38244,$F554A79C17782A00,$1313D33A5E514377,$003BB83B87015245,$749CB049657CC3C0,$E78681633A7BA20D,
             $EE9E2E493B76E707,$0117E9000C689000,$130000174A9A4B60,$1D730000829F0005,$A5471EADE568B400,$6DF01C675710F905,
             $B9A102A4D2DB1D88,$8403772FD6A5D1F8,$0E68E326EFC59785,$BCAB657008D9FFE1,$B3EF0738F1828A42,$85F07FA2FCD7CDBD,
             $0894B7A29C7DA7F6,$26B59C3C2DF9AF73,$F5706D47E196D804,$D9B0D70E466C7099,$C3BEE6B293E6D47B,$EA32388715594D59,
             $30A605050AA34559,$C48A06A797C38798,$EE3B90B640AFC3C3,$7C8A0F32C2C11860,$AAF142669979F534,$E8B71832779747C1,
             $5A271B291B4BE54B,$9B64EEA3ADEB1437,$AF6D27632E887B80,$6947675EBE8D6C4E,$9D2B7E943A04309C,$B51928DEEE97FBB5,
             $838DDDD01F33EE7B,$D9D85CEA18DD9E17,$7AA6549199EF34B4,$7CC8EEA7EBF9FBDD,$5700F5A7F8F15D5F,$BC968FD3E3B8CB99,
             $6392858988C78BCC,$87F4930D8694ADAA,$A86E2168E47C87AF,$18C24A5E7CDC55D0,$01A586D5A95C7877,$2A3C9D563EA9B683,
             $A594FB80DDF1336E,$E6CA2CF7B5ADB8D7,$7D62F7C80CA95875,$CA72E3079F986309,$E5F99E02DAFF543A,$1DB8BEB1937D177A,
             $1B207D4DFD07AB29,$D17C90DEA172CDA4,$AB71D13A7B3973C3,$DD1B0514671BEF87,$CED59BD5D4945A18,$92EB32D5141CC26A,
             $DD6B9C1B0E9EF27F,$758D7D040B0FB79E,$1A7784B5864BB199,$BF0137EA48326944,$D598383A09235957,$C73C69463B59D45F,
             $32ECE2361D4D25AB,$AD8405057B6177D7,$50FA728DBE3FCFD5,$C8976FA918A5B6A8,$7D2340E31A25489E,$D8ADE218D03ECF78,
             $980AF67D2B56788A,$5F4DAE92454EBBFB,$228DAC0114ABC4CF,$44602A6118CC520B,$2D66FD811E5801DD,$7E2ECD3D39EDB5D8,
             $BC50628338C51F76,$8098A076D1161A1D,$C35AED4DC016C015,$B54F0CF99316D655,$DEB923E19968C12D,$809D25FB7D84DD39,
             $F79DAA6234C28871,$6498B7D10660347E,$3610935964057B33,$82A6D136A3D20D70,$B9260A1116989555,$59F3679C37A29B2F,
             $7F4D2B586F40B2CD,$8D90DAA9D648D1EC,$531ABEEC01A13E67,$3D6C541E6284C1DE,$DC0F67528D0E4E38,$76DDC1CE4BACAC74,
             $87ADC327A0663D6A,$C6C6928832C26CCC,$60AEF1440AD654D5,$8074E70F66F057B8,$4EDE1DF3081386A7,$A366AD5DBFDE2A03,
             $14CB7DF6697BD75F,$BE2664DC2C526CD9,$A8D9BFD7FAE4844B,$0338E08670384A6D,$AF4F05404753B00B,$60D13F1FBD0BF5C0,
             $D32E7B3988FCEC00,$4CB98778443EA051,$BB340317812CB563,$49D515D5A5401D36,$E82BE017E2EF29D1,$EAEADEB295B093AD,
             $815B25E91442C33E,$3A37F4A0346E8F93,$DCCCB396A773D158,$B446493D6B493D85,$F48C176C37F98ACA,$0D1DE64B5565AB68,
             $941B0C2F4F3843FD,$A45C3F63FE1A9F71,$E6ECFD875A3F5E7F,$AAF2EB17F6C69E47,$47FEF1F01D25B2CC,$94FA5DAF7A407EFC,
             $F185891635CC7E2B,$6F139A8628906824,$EEB926A874387F46,$5F88A35DDCBFA65C,$2234A03EEC5CF239,$5094F3C5D967BCAC,
             $8F44165BF86A2CD2,$91F38E61A17EDAB6,$57BE0C5433041587,$F2AF7E8AF897F1EE,$1DE0A75B8C59DB09,$F586509F68F3BF1B,
             $920F0D049FCA6FE0,$3E1441F877160417,$2DBC6B41B084F742,$CBC235223F2796FB,$D578C9815EC4B4A2,$20FC4725BF009825,
             $B21198F6D4C9069F,$74E2476E2BB109A6,$2A07F7F6EB4D552E,$EA985EBFCCC1E58E,$8D5ABBD5FB4B6222,$997587D9994906BB,
             $9E2D2AC8CE72EDAB,$C728BF4F2D79D123,$B8FC2BC2BF84F189,$5E991E5FBDA567C9,$34A53AD81D1B98DD,$FF7726BC31A3AB90,
             $F146F1A8EFE33664,$C55845A99B4BF3AF,$4B8515EF55C06A8B,$3FB194AF32DEBF5F,$7A58BE3F3A89A7BB,$8C9FF8FE1FD12CA8,
             $3CBF7BA9C7D142F0,$01802FEAE2DDAA98,$A327A2B6A1950F8F,$F8A7040F5B909D56,$0A7B8E8FBD0739BE,$802029188DBAFDDC,
             $C467BC7A9EC3B344,$5B4FEB37772C2F8C,$166428D822255147,$21955D6667DE134A,$9CC71ECBCEA009C1,$6E531DF15C832F27,
             $E49190A393EC5CE7,$89EAE37029CFD303,$07EBD6805C78E2B9,$E3C5D40FD7D36D9C,$1706BBD36D769CC5,$92F66ED9BBDF5FB4,
             $F039F05E3D3F85FF,$C05ED382AF3D93A1,$E9810114ED526A2C,$E55AE9CCB76174C4,$B94CA9C3DEF3BCC0,$7AB19A2F9ACFB4AE,
             $F7311E21EBCB84A4,$ABB8107ECB4AC52B,$3B9E56239E30CD90,$22CA119486751DD7,$74B9324501EBCBF9,$8A6DA97F9B76A496,
             $EC6E77B1D4B23203,$A1521E2ABA649837,$38396890F128ED7B,$B1BE9A7E21FB90C8,$0B545D8074CD8AB2,$5DA17D5CEAE13771,
             $CEDC87325C12906F,$866C019C933635A8,$A0ECC9CC9D43DFE5,$7DAACFC19517989A,$2EE0044146B2E154,$9A8B7F7BDC786D84,
             $BAC759AF64FFD5F4,$FDE2FC487D741D7D,$4764302BFD939C4E,$DE7FCB67D594D201,$19674E188C18FD2E,$964B1486320CC1A1,
             $0B2810A34281600A,$3EB18502DBD2DA04,$1418B65022D94182,$1880FFFD3D3B7B0A,$3401BFC25864686A,$ADA0C11D46F68D02,
             $BE75D9813FCB6831,$4922DC05DAB01485,$341830440C9D0A64,$4C8E322BCDF9120C,$6A73742950C4C6A2,$D23A16CFFA32386C,
             $A3214730B486E899,$BCBBBDF949D7CBCF,$84CE03224B199517,$35346A47084EEED3,$D19697C704B77E96,$5FF6E9E33B9F2BFF,
             $0D4A9C3CD9286A07,$6434905D4B9B268F,$B1BE9046431A8538,$C4FFF77E79B42248,$3FCCA0D80D70113B
      Data.b $00,$7E,$21,$7C,$8E
    EndDataSection
    
  CompilerEndIf  

EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Font  = 1
  #Image = 2
  
  LoadFont(#Font, "Arial", 8, #PB_Font_Bold)
  LoadImage(#Image, "Test.png")
  
  If MessageEx::Create("User", $701919)
    ;MessageEx::SetImage("User", #Image)
    MessageEx::SetItemFont("User",  0, #Font)
    MessageEx::SetItemColor("User", 1, $008CFF)
    MessageEx::SetItemFlags("User", 1, MessageEx::#Center)
  EndIf
  
  Result = MessageEx::Requester("Message Requester", "Message requester text." + #LF$ + "Second message row.", "User", MessageEx::#OK|MessageEx::#Info)
  Select Result
    Case #True
      Debug "OK"
    Case MessageEx::#Result_Yes
      Debug "Yes"
    Case MessageEx::#Result_No
      Debug "No"
    Case MessageEx::#Result_Cancel
      Debug "Cancel"
    Default
      Debug "Close window"
  EndSelect    

CompilerEndIf

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 8
; Folding = YABAQsgOgZA5
; EnableXP
; DPIAware