;/ ================================
;/ = ButtonExModule.pbi =
;/ ================================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2020 Thorsten1867 (03/2019)
;/

; Last Update: 22.05.2020
;
; Added: ButtonEx::CombineToggle()
; Added: ButtonEx::Free()

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

;{ ===== Additional tea & pizza license =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ ButtonEx - Commands _____

; ButtonEx::AddDropDown()        - adds a dropdown menue to the button
; ButtonEx::AddImage()           - adds an image to the button
; ButtonEx::CombineToggle()      - combine a group of toggle buttons
; ButtonEx::Disable()            - similar to 'DisableGadget()'
; ButtonEx::Free()               - similar to 'FreeGadget()'
; ButtonEx::Gadget()             - similar to 'ButtonGadget()'
; ButtonEx::GetData()            - similar to 'GetGadgetData()'
; ButtonEx::GetID()              - similar to 'GetGadgetData()', but string
; ButtonEx::GetState()           - similar to 'GetGadgetState()'
; ButtonEx::GetText()            - similar to 'GetGadgetText()'

; ButtonEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; ButtonEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; ButtonEx::SetColor()           - similar to 'SetGadgetColor()'
; ButtonEx::SetData()            - similar to 'SetGadgetData()'
; ButtonEx::SetFont()            - similar to 'SetGadgetFont()'
; ButtonEx::SetID()              - similar to 'SetGadgetData()', but string
; ButtonEx::SetState()           - similar to 'SetGadgetState()'
; ButtonEx::SetText()            - similar to 'SetGadgetText()'
; ButtonEx::Hide()               - similar to 'HideGadget()'

; _____ ModuleEx.pbi _____
; ButtonEx::FitTextEx()          - fits text size                  [needs SetFontEx() before]
; ButtonEx::SetFontEx()          - sets a font that can be fitted  
; ButtonEx::SetTextEx()          - change text and fit its size    [needs SetFontEx() before]

;}

;XIncludeFile "ModuleEx.pbi"

DeclareModule ButtonEx
  
  #Version  = 20052200
  #ModuleEx = 19112100
  
	;- ===========================================================================
	;- DeclareModule - Constants / Structures
	;- ===========================================================================

	;{ _____ Constants _____
	EnumerationBinary ;{ GadgetFlags
		#Default   = #PB_Button_Default
		#Left      = #PB_Button_Left
		#Right     = #PB_Button_Right
		#Toggle    = #PB_Button_Toggle
		#MultiLine = #PB_Button_MultiLine
		#Center
		#DropDownButton
		#Image
		#Font
		#Color
		#MacOS
		#Borderless
		#AutoResize
		#FitText
		#FixPadding
		#UseExistingCanvas
	EndEnumeration ;}
	
	Enumeration 1     ;{ Attribute
	  #Corner
	EndEnumeration ;}
	
	Enumeration 1     ;{ Colors
		#FrontColor
		#BackColor
		#BorderColor
		#FocusColor
	EndEnumeration ;}
	
	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}
	
	
	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  #Event_Gadget       = ModuleEx::#Event_Gadget
	  #Event_Theme        = ModuleEx::#Event_Theme
	  
		#EventType_Button   = ModuleEx::#EventType_Button
		#EventType_DropDown = ModuleEx::#EventType_DropDown

	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
			#Event_Gadget
		EndEnumeration

		Enumeration #PB_EventType_FirstCustomValue
			#EventType_Button
			#EventType_DropDown
		EndEnumeration

	CompilerEndIf
	;}
	
	
	;- ===========================================================================
	;- DeclareModule
	;- ===========================================================================

	Declare   AddDropDown(GNum.i, PopupNum.i)
	Declare   AddImage(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Flags.i=#Left)
	Declare.i CombineToggle(GNum.i, Group.s, State.i=#True)
	Declare   Disable(GNum.i, State.i=#True)
	Declare   Free(GNum.i)
	Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i, WindowNum.i=#PB_Default)
	Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
	Declare.i GetState(GNum.i)
	Declare.s GetText(GNum.i)
	Declare   Hide(GNum.i, State.i=#True)
	Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
	Declare   SetAutoResizeFlags(GNum.i, Flags.i)
	Declare   SetColor(GNum.i, ColorType.i, Color.i)
	Declare   SetFont(GNum.i, FontNum.i)
	Declare   SetData(GNum.i, Value.q)
	Declare   SetID(GNum.i, String.s)
	Declare   SetState(GNum.i, State.i)
	Declare   SetText(GNum.i, Text.s)

	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Declare.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  Declare.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	  Declare.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  
	CompilerEndIf
	
EndDeclareModule

Module ButtonEx
  
  EnableExplicit
  
	;- ===========================================================================
	;- Module - Constants
	;- ===========================================================================

	#DropDownWidth  = 18
	
	CompilerSelect #PB_Compiler_OS
		CompilerCase #PB_OS_Windows
			#PopupMenuWidth = 123
		CompilerCase #PB_OS_MacOS
      #PopupMenuWidth = 125
		CompilerCase #PB_OS_Linux
      #PopupMenuWidth = 125
	CompilerEndSelect
	
	EnumerationBinary
		#Focus
		#Click
		#DropDown
	EndEnumeration

	;- ============================================================================
	;- Module - Structures
	;- ============================================================================
	
	Structure Toogle_Group_Structure
	  List GadgetNum.i()
	EndStructure  
	Global NewMap Group.Toogle_Group_Structure()
	
	Structure ButtonEx_Image_Structure   ;{ ButtonEx()\Image\...
		Num.i
		Width.i
		Height.i
		Flags.i
	EndStructure ;}

	Structure ButtonEx_Color_Structure   ;{ ButtonEx()\Color\...
		Front.i
		Back.i
		Focus.i
		Border.i
		Gadget.i
		DisableFront.i
    DisableBack.i
	EndStructure ;}

	Structure ButtonEx_Size_Structure    ;{ ButtonEx()\Size\...
		X.f
		Y.f
		Text.i
		Width.f
		Height.f
		Flags.i
	EndStructure ;}

	Structure ButtonEx_Window_Structure  ;{ ButtonEx()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}
	
	Structure ButtonEx_Font_Structure    ;{ ButtonEx()\Font\...
	  Num.i
	  Name.s
	  Size.i
	  Style.i
	EndStructure ;}
	
	Structure ButtonEx_Structure         ;{ ButtonEx()\...
	  ID.s
	  Quad.q
	  
	  CanvasNum.i
		PopupNum.i
		
		FontID.i
		
		Text.s
		Toggle.i
		State.i
		
		Disable.i
		Hide.i
		Radius.i
		Flags.i
		
		; Fit Text
    PaddingX.i
    PaddingY.i
    PFactor.f
    
    Group.s
    
    Font.ButtonEx_Font_Structure
		Color.ButtonEx_Color_Structure
		Image.ButtonEx_Image_Structure
		Size.ButtonEx_Size_Structure
		Window.ButtonEx_Window_Structure

	EndStructure ;}
	Global NewMap BtEx.ButtonEx_Structure()
	
	;- ============================================================================
	;- Module - Internal
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

	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
		Define.i R1, G1, B1, R2, G2, B2
		Define.f Blend = Scale / 100

		R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
		R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)

		ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
	EndProcedure

	Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i)
		If BtEX()\Radius
			RoundBox(X, Y, Width, Height, BtEx()\Radius, BtEx()\Radius, Color)
		Else
			Box(X, Y, Width, Height, Color)
		EndIf
	EndProcedure

	Procedure.i Arrow_(X.i, Y.i, Width.i, Height.i)
		Define.i aX, aY, aWidth, aHeight, Color

		Color = BlendColor_(BtEx()\Color\Front, BtEx()\Color\Back, 60)

		aWidth = dpiX(8)
		aHeight = dpiX(4)

		aX = X + (Width - aWidth) / 2 - dpiX(1)
		aY = Y + (Height - aHeight) / 2 + dpiX(1)

		If aWidth < Width And aHeight < Height

			DrawingMode(#PB_2DDrawing_Default)
			Line(aX, aY, aWidth, 1, Color)
			LineXY(aX, aY, aX + (aWidth / 2), aY + aHeight, Color)
			LineXY(aX + (aWidth / 2), aY + aHeight, aX + aWidth, aY, Color)
			FillArea(aX + (aWidth / 2), aY + dpiY(2), -1, Color)

		EndIf

	EndProcedure

	Procedure.f GetAlignOffset_(Text.s, Width.f, Flags.i, imgWidth.i=0)
		Define.f Offset

		If imgWidth : imgWidth + dpiX(4) : EndIf

		If Flags & #Right
			Offset = Width - TextWidth(Text) - imgWidth - dpiX(4)
		ElseIf Flags & #Left
			Offset = dpiX(4)
		Else
			Offset = (Width - TextWidth(Text) - imgWidth) / 2
		EndIf

		If Offset < 0 : Offset = 0 : EndIf

		ProcedureReturn Offset
	EndProcedure

	Procedure   Draw_()
		Define.f X, Y, Width, Height, txtWidth
		Define.s Text, Row
		Define.i lf, s, CountLF, idx, FrontColor, BackColor, BorderColor
		
		If BtEx()\Hide : ProcedureReturn #False : EndIf
		
		If BtEx()\Flags & #MultiLine
			NewList Rows.s()
		EndIf

		If StartDrawing(CanvasOutput(BtEx()\CanvasNum))
		  
		  FrontColor = BtEx()\Color\Front
		  
			If BtEX()\Flags & #DropDownButton
			  Width = dpiX(GadgetWidth(BtEx()\CanvasNum)) - dpiX(#DropDownWidth)
			  BtEx()\Size\Text = Width
			Else
				Width = dpiX(GadgetWidth(BtEx()\CanvasNum))
			EndIf
      
			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			Box(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BtEx()\Color\Gadget)
			
			If BtEx()\Disable
			  FrontColor = BtEx()\Color\DisableFront
			  BackColor  = BtEx()\Color\DisableBack
			  Box_(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BackColor)
			  BorderColor = BackColor
			ElseIf BtEx()\State & #Click And BtEx()\State & #DropDown ;{ DropDown-Button - Click
			  BackColor   = BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20)
			  BorderColor = BtEx()\Color\Focus
				If BtEx()\Radius
					If BtEx()\Toggle
						Box_(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20))
					Else
						Box_(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 10))
					EndIf
					Line(Width - dpiX(1), 0, dpiX(1), dpiY(GadgetHeight(BtEx()\CanvasNum)), BorderColor)
					FillArea(Width + dpiX(1), dpiX(1), BorderColor, BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20))
				Else
					If BtEx()\Toggle
						Box_(0, 0, Width, dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20))
					Else
						Box_(0, 0, Width, dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 10))
					EndIf
					Box_(Width, 0, dpiX(#DropDownWidth), dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20))
				EndIf
				;}
			ElseIf BtEx()\Toggle And BtEx()\Flags & #DropDownButton   ;{ DropDown-Button - Toggle
			  BorderColor = BtEx()\Color\Focus
			  If BtEx()\Radius
					Box_(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20))
					Line(Width - dpiX(1), 0, dpiX(1), dpiY(GadgetHeight(BtEx()\CanvasNum)), BorderColor)
					If BtEx()\State & #Focus
						FillArea(Width + dpiX(1), dpiX(1), BorderColor, BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 10))
					Else
						FillArea(Width + dpiX(1), dpiX(1), BorderColor, BtEx()\Color\Back)
					EndIf
				Else
					If BtEx()\State & #Focus
						Box_(Width, 0, dpiX(#DropDownWidth), dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 10))
					Else
						Box_(Width, 0, dpiX(#DropDownWidth), dpiY(GadgetHeight(BtEx()\CanvasNum)), BtEx()\Color\Back)
					EndIf
					Box_(0, 0, Width, dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20))
				EndIf
				;}
			ElseIf BtEx()\State & #Click Or BtEx()\Toggle             ;{ Button - Click / Toggle
				Box_(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 20))
				BorderColor = BtEx()\Color\Focus ;}
			ElseIf BtEx()\State & #Focus                              ;{ Button - Focus
				Box_(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BlendColor_(BtEx()\Color\Focus, BtEx()\Color\Back, 10))
				BorderColor = BtEx()\Color\Focus ;}
			Else
				Box_(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BtEx()\Color\Back)
				BorderColor = BtEx()\Color\Border
			EndIf ;}

			If BtEX()\Flags & #DropDownButton
				Arrow_(Width, 0, dpiX(#DropDownWidth), dpiY(GadgetHeight(BtEx()\CanvasNum)))
			EndIf

			;{ _____ Text & Image _____
			DrawingFont(BtEx()\FontID)

			If BtEx()\Flags & #Image ;{ Image

				If BtEx()\Text

					X = GetAlignOffset_(BtEx()\Text, Width, BtEx()\Flags, BtEx()\Image\Width)

					Y = (dpiY(GadgetHeight(BtEx()\CanvasNum)) - BtEx()\Image\Height) / 2
					DrawingMode(#PB_2DDrawing_AlphaBlend)
					If BtEx()\Image\Flags & #Right
						DrawImage(ImageID(BtEx()\Image\Num), X + TextWidth(BtEx()\Text) + dpiX(4), Y, BtEx()\Image\Width, BtEx()\Image\Height)
					Else
						DrawImage(ImageID(BtEx()\Image\Num), X, Y, BtEx()\Image\Width, BtEx()\Image\Height)
					EndIf

					Y = (dpiY(GadgetHeight(BtEx()\CanvasNum)) - TextHeight(BtEx()\Text)) / 2
					DrawingMode(#PB_2DDrawing_Transparent)
					If BtEx()\Image\Flags & #Right
						DrawText(X, Y, BtEx()\Text, FrontColor)
					Else
						DrawText(X + BtEx()\Image\Width + dpiX(4), Y, BtEx()\Text, FrontColor)
					EndIf
					
					BtEx()\Size\Text = Width - BtEx()\Image\Width
					
				Else

					X = (Width - BtEx()\Image\Width) / 2
					Y = (dpiY(GadgetHeight(BtEx()\CanvasNum)) - BtEx()\Image\Height) / 2
					DrawingMode(#PB_2DDrawing_AlphaBlend)
					DrawImage(ImageID(BtEx()\Image\Num), X, Y, BtEx()\Image\Width, BtEx()\Image\Height)
					
					BtEx()\Size\Text = 0
					
				EndIf
				;}
			Else ;{ Text

				If BtEx()\Text
          
				  If BtEx()\Flags & #MultiLine
				    
				    txtWidth = Width - dpiX(8)
				    
				    CountLF = CountString(BtEx()\Text, #LF$)
				    If CountLF: BtEx()\Text = ReplaceString(BtEx()\Text, #CRLF$, #LF$) : EndIf
				    
				    If TextWidth(BtEx()\Text) + dpiX(8) > Width ;{ MultiLine
				      
				      If CountLF
				        
				        For lf=1 To CountLF + 1

				          Row  = Trim(StringField(BtEx()\Text, lf, #LF$))
				          Text = ""
				          
				          If TextWidth(Row) > txtWidth
				            
				            For s=1 To CountString(Row, " ") + 1
				              
				              If TextWidth(StringField(Row, s, " ")) >=  txtWidth
				                If AddElement(Rows())
				                  Rows() = StringField(Row, s, " ")
				                  Break
				                EndIf
				              ElseIf TextWidth(Text + " " + StringField(Row, s, " ")) < txtWidth
				                Text + " " + StringField(Row, s, " ")  
				              Else
        							  If AddElement(Rows())
        									Rows() = Text
        									Text   = StringField(Row, s, " ")
        								EndIf
        							EndIf
				            Next
				            
				            If Text <> ""
        							If AddElement(Rows()) : Rows() = Text : EndIf
        						EndIf
				            
        					Else
        					  
				            If AddElement(Rows()) : Rows() = Row : EndIf
				            
				          EndIf
				          
				        Next  
				        
    					Else
    					  
    					  For s=1 To CountString(BtEx()\Text, " ") + 1
    							If TextWidth(Text + " " + StringField(BtEx()\Text, s, " ")) < txtWidth
    								Text + " " + StringField(BtEx()\Text, s, " ")
    							Else
    							  If AddElement(Rows())
    									Rows() = Text
    									Text = StringField(BtEx()\Text, s, " ")
    								EndIf
    							EndIf
    						Next
    						
    					  If Text <> ""
    							If AddElement(Rows()) : Rows() = Text : EndIf
    						EndIf
  						
    					EndIf
          
  						Height = ListSize(Rows()) * TextHeight(BtEx()\Text)
  						Y = (dpiY(GadgetHeight(BtEx()\CanvasNum)) - Height) / 2 
  						ForEach Rows()
  							X = GetAlignOffset_(Rows(), Width, BtEx()\Flags)
  							DrawingMode(#PB_2DDrawing_Transparent)
  							DrawText(X, Y, Rows(), FrontColor)
  							Y + TextHeight(Rows())
  						Next
  						;}
  					ElseIf CountLF ;{ LineFeed
  					  
  					  For s=1 To CountLF + 1
								If AddElement(Rows())
									Rows() = StringField(BtEx()\Text, s, #LF$)
								EndIf
  						Next
  						
  						Height = ListSize(Rows()) * TextHeight(BtEx()\Text)
  						Y = (dpiY(GadgetHeight(BtEx()\CanvasNum)) - Height) / 2
  						
  						ForEach Rows()
  							X = GetAlignOffset_(Rows(), Width, BtEx()\Flags)
  							DrawingMode(#PB_2DDrawing_Transparent)
  							DrawText(X, Y, Rows(), FrontColor)
  							Y + TextHeight(Rows())
  						Next
  						;}
  					Else           ;{ Single line
            
    					X = GetAlignOffset_(BtEx()\Text, Width, BtEx()\Flags)
    					Y = (dpiY(GadgetHeight(BtEx()\CanvasNum)) - TextHeight(BtEx()\Text)) / 2
    					DrawingMode(#PB_2DDrawing_Transparent)
    					DrawText(X, Y, BtEx()\Text, FrontColor)
    					;}
  					EndIf
  					
				  Else
          
  					X = GetAlignOffset_(BtEx()\Text, Width, BtEx()\Flags)
  					Y = (dpiY(GadgetHeight(BtEx()\CanvasNum)) - TextHeight(BtEx()\Text)) / 2
  					DrawingMode(#PB_2DDrawing_Transparent)
  					DrawText(X, Y, BtEx()\Text, FrontColor)
  					
  				EndIf
  				
  				BtEx()\Size\Text = Width
  				
				EndIf
				;}
			EndIf
			;}

			;{ _____ Border ____
			If BtEX()\Flags & #Borderless = #False
			  
				DrawingMode(#PB_2DDrawing_Outlined)
				If BtEX()\Radius 
					RoundBox(0, 0, dpiX(GadgetWidth(BtEx()\CanvasNum)), dpiY(GadgetHeight(BtEx()\CanvasNum)), BtEx()\Radius, BtEx()\Radius, BorderColor)
					If BtEX()\Flags & #DropDownButton
						Line(Width - dpiX(1), 0, dpiX(1), dpiY(GadgetHeight(BtEx()\CanvasNum)), BorderColor)
					EndIf
				Else
					Box(0, 0, Width, dpiY(GadgetHeight(BtEx()\CanvasNum)), BorderColor)
					If BtEX()\Flags & #DropDownButton
						Box(Width - dpiX(1), 0, dpiX(#DropDownWidth), dpiY(GadgetHeight(BtEx()\CanvasNum)), BorderColor)
					EndIf
				EndIf
				
			EndIf
			;}

			StopDrawing()
		EndIf

	EndProcedure
	
	;- __________ Events __________
	
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach BtEx()

        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          BtEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        BtEx()\Color\Front        = ModuleEx::ThemeGUI\Button\FrontColor
        BtEx()\Color\Back         = ModuleEx::ThemeGUI\Button\BackColor
        BtEx()\Color\Focus        = ModuleEx::ThemeGUI\Focus\BackColor
        BtEx()\Color\Border       = ModuleEx::ThemeGUI\Button\BorderColor
        BtEx()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
        BtEx()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
		    BtEx()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf  	
	
	
	Procedure _LeftButtonDownHandler()
		Define.i X
		Define.i GNum = EventGadget()

		If FindMapElement(BtEx(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)

			BtEx()\State | #Click

			If BtEx()\Flags & #DropDownButton
			  
				If X > dpiX(GadgetWidth(BtEx()\CanvasNum)) - dpiX(#DropDownWidth)
					BtEx()\State | #DropDown
				Else
					If BtEx()\Flags & #Toggle : BtEx()\Toggle ! #True : EndIf
				EndIf
				
			Else
			  
			  If BtEx()\Flags & #Toggle
			    
			    BtEx()\Toggle ! #True

			    If BtEx()\Group
			      
			      If BtEx()\Toggle = #True
			        
			        If FindMapElement(Group(), BtEx()\Group)
			          
			          ForEach Group()\GadgetNum()
			            
  			          If Group()\GadgetNum() = GNum : Continue : EndIf
  			          
  			          PushMapPosition(BtEx())
  			          
  			          If FindMapElement(BtEx(), Str(Group()\GadgetNum()))
  			            BtEx()\Toggle = #False
  			            Draw_()
  			          EndIf  
  			          
  			          PopMapPosition(BtEx())
  			          
  			        Next 
  			        
  			      EndIf 
  			      
			      EndIf
			      
			    EndIf
			    
			  EndIf
			EndIf

			Draw_()
		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, dX, dY, OffsetX
		Define.i GNum = EventGadget()
		
		If FindMapElement(BtEx(), Str(GNum))

			X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)

			If BtEx()\State & #Focus And BtEx()\State & #Click
				If BtEx()\State & #DropDown
					If IsWindow(BtEx()\Window\Num)
						dX = WindowX(BtEx()\Window\Num, #PB_Window_InnerCoordinate) + GadgetX(BtEx()\CanvasNum)
						dY = WindowY(BtEx()\Window\Num, #PB_Window_InnerCoordinate) + GadgetY(BtEx()\CanvasNum) + GadgetHeight(BtEx()\CanvasNum)
						OffsetX = GadgetWidth(BtEx()\CanvasNum) - #PopupMenuWidth
						DisplayPopupMenu(BtEx()\PopupNum, WindowID(BtEx()\Window\Num), dpiX(dX) + OffsetX, dpiY(dY))
					EndIf
					PostEvent(#Event_Gadget, BtEx()\Window\Num, BtEx()\CanvasNum, #EventType_DropDown)
					PostEvent(#PB_Event_Gadget, BtEx()\Window\Num, BtEx()\CanvasNum, #EventType_DropDown)
				Else
					PostEvent(#Event_Gadget, BtEx()\Window\Num, BtEx()\CanvasNum, #EventType_Button, BtEx()\Toggle)
					PostEvent(#PB_Event_Gadget, BtEx()\Window\Num, BtEx()\CanvasNum, #EventType_Button)
				EndIf
			EndIf

			BtEx()\State & ~#DropDown
			BtEx()\State & ~#Click

			Draw_()
		EndIf

	EndProcedure

	Procedure _MouseEnterHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(BtEx(), Str(GNum))
			BtEx()\State | #Focus
			Draw_()
		EndIf

	EndProcedure

	Procedure _MouseLeaveHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(BtEx(), Str(GNum))
			BtEx()\State & ~#Focus
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(BtEx(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
	  Define.f X, Y, Width, Height
	  Define.i FontSize
		Define.f OffSetX, OffSetY

		ForEach BtEx()

			If IsGadget(BtEx()\CanvasNum)

				If BtEx()\Flags & #AutoResize

					If IsWindow(BtEx()\Window\Num)

						OffSetX = WindowWidth(BtEx()\Window\Num)  - BtEx()\Window\Width
						OffsetY = WindowHeight(BtEx()\Window\Num) - BtEx()\Window\Height

						If BtEx()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If BtEx()\Size\Flags & #MoveX  : X = BtEx()\Size\X + OffSetX : EndIf
							If BtEx()\Size\Flags & #MoveY  : Y = BtEx()\Size\Y + OffSetY : EndIf
							If BtEx()\Size\Flags & #Width  : Width  = BtEx()\Size\Width  + OffSetX : EndIf
							If BtEx()\Size\Flags & #Height : Height = BtEx()\Size\Height + OffSetY : EndIf
							
							ResizeGadget(BtEx()\CanvasNum, X, Y, Width, Height)

						Else
						  
						  ResizeGadget(BtEx()\CanvasNum, #PB_Ignore, #PB_Ignore, BtEx()\Size\Width + OffSetX, BtEx()\Size\Height + OffsetY)
						  
						EndIf
						
						CompilerIf Defined(ModuleEx, #PB_Module)
						  
						  If BtEx()\Size\Flags & #FitText
						    
						    If BtEx()\Size\Flags & #FixPadding
						      Width  = BtEx()\Size\Text - BtEx()\PaddingX
                  Height = GadgetHeight(BtEx()\CanvasNum) - BtEx()\PaddingY
						    Else
						      Width  = BtEx()\Size\Text - BtEx()\PaddingX
                  Height = GadgetHeight(BtEx()\CanvasNum) - (GadgetHeight(BtEx()\CanvasNum) * BtEx()\PFactor)
						    EndIf
						    
						    If Height < 0 : Height = 0 : EndIf 
						    If Width  < 0 : Width  = 0 : EndIf
						    
						    FontSize = ModuleEx::RequiredFontSize(BtEx()\Text, Width, Height, BtEx()\Font\Num)
						    
						    If FontSize <> BtEx()\Font\Size
                  BtEx()\Font\Size = FontSize
                  BtEx()\Font\Num  = ModuleEx::Font(BtEx()\Font\Name, FontSize, BtEx()\Font\Style)
                  If IsFont(BtEx()\Font\Num) : BtEx()\FontID = FontID(BtEx()\Font\Num) : EndIf
                EndIf  
						    
						  EndIf  
						  
						CompilerEndIf 
						
						Draw_()
					EndIf

				EndIf

			EndIf

		Next

	EndProcedure
	
	
	;- ==========================================================================
	;- Module - Declared Procedures
	;- ==========================================================================
	
	Procedure.i CombineToggle(GNum.i, Group.s, State.i=#True)
	  
	  If FindMapElement(BtEx(), Str(GNum))
	    
	    If State
	      
	      BtEx()\Group = Group
	      
	      If AddElement(Group(Group)\GadgetNum())
  	      Group(Group)\GadgetNum() = GNum
  	    EndIf
	    
	    Else
	      
	      BtEx()\Group = ""
	      
	      If FindMapElement(Group(), Group)
	        ForEach Group()
	          If Group()\GadgetNum() = GNum
	            DeleteElement(Group()\GadgetNum())
	          EndIf  
	        Next  
	      EndIf
	      
	    EndIf  
	    
	  EndIf  
	  
	  ProcedureReturn ListSize(Group(Group)\GadgetNum())
	EndProcedure  
	
	Procedure   AddDropDown(GNum.i, PopupNum.i)

		If FindMapElement(BtEx(), Str(GNum))

			If IsMenu(PopupNum)
				BtEx()\PopupNum = PopupNum
				BtEx()\Flags | #DropDownButton
				Draw_()
			EndIf

		EndIf

	EndProcedure

	Procedure   AddImage(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Flags.i=#Left)

		If FindMapElement(BtEx(), Str(GNum))

			If IsImage(ImageNum)
				BtEx()\Image\Num = ImageNum
				BtEx()\Image\Width = dpiX(Width)
				If Width = #PB_Default : BtEx()\Image\Width = ImageWidth(ImageNum) : EndIf
				BtEx()\Image\Height = dpiY(Height)
				If Width = #PB_Default : BtEx()\Image\Height = ImageHeight(ImageNum) : EndIf
				BtEx()\Image\Flags = Flags
				BtEx()\Flags | #Image
				Draw_()
			EndIf

		EndIf

	EndProcedure
	
	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(BtEx(), Str(GNum))

      BtEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 
  
  Procedure   Free(GNum.i)
    
    If FindMapElement(BtEx(), Str(GNum))
      
      DeleteMapElement(BtEx())
      
      ForEach Group()
        
        ForEach Group()\GadgetNum()
          If Group()\GadgetNum() = GNum
            DeleteElement(Group()\GadgetNum())
          EndIf  
        Next
        
        If MapSize(Group()) = 0 : DeleteMapElement(Group()) : EndIf
        
      Next   
      
    EndIf
    
  EndProcedure  
  
  
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i, WindowNum.i=#PB_Default)
		Define Result.i, txtNum
		
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
      Result = CanvasGadget(GNum, X, Y, Width, Height)
    EndIf

		If Result

			If GNum = #PB_Any : GNum = Result : EndIf

			If AddMapElement(BtEx(), Str(GNum))

				BtEx()\CanvasNum = GNum

        If WindowNum = #PB_Default
          BtEx()\Window\Num = GetGadgetWindow()
        Else
          BtEx()\Window\Num = WindowNum
        EndIf

				CompilerIf Defined(ModuleEx, #PB_Module)
					If ModuleEx::AddWindow(BtEx()\Window\Num, ModuleEx::#Tabulator)
					  ModuleEx::AddGadget(GNum, BtEx()\Window\Num)
					EndIf
				CompilerEndIf
				
				BtEx()\PaddingX = 8
				BtEx()\PaddingY = 8
				
				BtEx()\Text  = Text
				BtEx()\Flags = Flags
				
				If Flags & #MacOS : BtEx()\Radius = 7 : EndIf
				
				If Flags & #FitText    : BtEx()\Size\Flags | #FitText    : EndIf
				If Flags & #FixPadding : BtEx()\Size\Flags | #FixPadding : EndIf
				
				CompilerSelect #PB_Compiler_OS ;{ Font
					CompilerCase #PB_OS_Windows
						BtEx()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If txtNum
							BtEx()\FontID = GetGadgetFont(txtNum)
							FreeGadget(txtNum)
						EndIf
					CompilerCase #PB_OS_Linux
						BtEx()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}

				BtEx()\Size\X = X
				BtEx()\Size\Y = Y
				BtEx()\Size\Width  = Width
				BtEx()\Size\Height = Height

				BtEx()\Color\Front        = $000000
				BtEx()\Color\Back         = $E3E3E3
				BtEx()\Color\Focus        = $D77800
				BtEx()\Color\Border       = $A0A0A0
				BtEx()\Color\Gadget       = $F0F0F0
				BtEx()\Color\DisableFront = $72727D
				BtEx()\Color\DisableBack  = $CCCCCA
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						BtEx()\Color\Front  = GetSysColor_(#COLOR_BTNTEXT)
						BtEx()\Color\Back   = GetSysColor_(#COLOR_3DLIGHT)
						BtEx()\Color\Focus  = GetSysColor_(#COLOR_MENUHILIGHT)
						BtEx()\Color\Border = GetSysColor_(#COLOR_3DSHADOW)
						BtEx()\Color\Gadget = GetSysColor_(#COLOR_MENU)
					CompilerCase #PB_OS_MacOS
						BtEx()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						BtEx()\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
						BtEx()\Color\Focus  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
						BtEx()\Color\Border = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
						BtEx()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(BtEx()\CanvasNum, @_MouseEnterHandler(),     #PB_EventType_MouseEnter)
				BindGadgetEvent(BtEx()\CanvasNum, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)
				BindGadgetEvent(BtEx()\CanvasNum, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
				BindGadgetEvent(BtEx()\CanvasNum, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
				BindGadgetEvent(BtEx()\CanvasNum, @_ResizeHandler(),         #PB_EventType_Resize)
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If IsWindow(BtEx()\Window\Num)
					BtEx()\Window\Width = WindowWidth(BtEx()\Window\Num)
					BtEx()\Window\Height = WindowHeight(BtEx()\Window\Num)
					BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), BtEx()\Window\Num)
				EndIf

				Draw_()

			EndIf

		EndIf

		ProcedureReturn BtEx()\CanvasNum
	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(BtEx(), Str(GNum))
	    ProcedureReturn BtEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(BtEx(), Str(GNum))
	    ProcedureReturn BtEx()\ID
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetState(GNum.i)

		If FindMapElement(BtEx(), Str(GNum))
			If BtEx()\Flags & #Toggle
				ProcedureReturn BtEx()\Toggle
			Else
				ProcedureReturn -1
			EndIf
		EndIf

	EndProcedure
	
	Procedure.s GetText(GNum.i)
	  
	  If FindMapElement(BtEx(), Str(GNum))
	    ProcedureReturn BtEx()\Text
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(BtEx(), Str(GNum))
      
      If State
        BtEx()\Hide = #True
        HideGadget(GNum, #True)
      Else
        BtEx()\Hide = #False
        HideGadget(GNum, #False)
        Draw_()
      EndIf
    
    EndIf  
    
  EndProcedure  
  
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
	  
    If FindMapElement(BtEx(), Str(GNum))
     
      Select Attribute
        Case #Corner
          BtEx()\Radius = Value
      EndSelect
      
	    Draw_()
	  EndIf
	  
	EndProcedure
  
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)

		If FindMapElement(BtEx(), Str(GNum))

			BtEx()\Size\Flags = Flags

		EndIf

	EndProcedure

	Procedure   SetColor(GNum.i, ColorType.i, Color.i)

		If FindMapElement(BtEx(), Str(GNum))

			Select ColorType
				Case #FrontColor
					BtEx()\Color\Front = Color
				Case #BackColor
					BtEx()\Color\Back = Color
				Case #BorderColor
					BtEx()\Color\Border = Color
				Case #FocusColor
					BtEx()\Color\Focus = Color
			EndSelect

			Draw_()

		EndIf

	EndProcedure
	
	Procedure   SetFont(GNum.i, FontNum.i)

		If FindMapElement(BtEx(), Str(GNum))

			If IsFont(FontNum)
				BtEx()\FontID = FontID(FontNum)
				Draw_()
			EndIf

		EndIf

	EndProcedure	
	
	Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(BtEx(), Str(GNum))
	    BtEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(BtEx(), Str(GNum))
	    BtEx()\ID = String
	  EndIf
	  
	EndProcedure
	
	Procedure   SetState(GNum.i, State.i)

		If FindMapElement(BtEx(), Str(GNum))
		  BtEx()\Toggle = State
		  Draw_()
		EndIf

	EndProcedure

	Procedure   SetText(GNum.i, Text.s)
	  
		If FindMapElement(BtEx(), Str(GNum))
		  BtEx()\Text = Text
		  Draw_()
		EndIf

	EndProcedure
	
	
	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Procedure.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	    Define.i FontNum
	    Define   Padding.ModuleEx::Padding_Structure
	    
	    If FindMapElement(BtEx(), Str(GNum))
	      
	      FontNum = ModuleEx::Font(Name, Size, Style)
	      If IsFont(FontNum)
	        
	        BtEx()\Font\Num   = FontNum
	        BtEx()\Font\Name  = Name
	        BtEx()\Font\Size  = Size
	        BtEx()\Font\Style = Style
	        BtEx()\FontID     = FontID(FontNum)

	        ModuleEx::CalcPadding(BtEx()\Text, GadgetHeight(GNum), FontNum, Size, @Padding)
	        BtEx()\PaddingX = Padding\X
	        BtEx()\PaddingY = Padding\Y
	        BtEx()\PFactor  = Padding\Factor
  	      
	        Draw_()
	      EndIf
	      
	    EndIf
	    
	    ProcedureReturn FontNum
	  EndProcedure
	  
	  Procedure.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(BtEx(), Str(GNum))
	      
	      If IsFont(BtEx()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : BtEx()\PaddingX = PaddingX * 2 : EndIf 
	      If PaddingY <> #PB_Default : BtEx()\PaddingY = PaddingY * 2 : EndIf 
	      
	      If BtEx()\Size\Flags & #FixPadding Or PaddingY <> #PB_Default
		      Width  = BtEx()\Size\Text - BtEx()\PaddingX
          Height = GadgetHeight(BtEx()\CanvasNum) - BtEx()\PaddingY
		    Else
		      Width  = BtEx()\Size\Text - BtEx()\PaddingX
          Height = GadgetHeight(BtEx()\CanvasNum) - (GadgetHeight(BtEx()\CanvasNum) * BtEx()\PFactor)
		    EndIf
		    
		    FontSize = ModuleEx::RequiredFontSize(BtEx()\Text, Width, Height, BtEx()\Font\Num)
		    If FontSize <> BtEx()\Font\Size
          BtEx()\Font\Size = FontSize
          BtEx()\Font\Num  = ModuleEx::Font(BtEx()\Font\Name, FontSize, BtEx()\Font\Style)
          BtEx()\FontID    = FontID(BtEx()\Font\Num)
        EndIf  
        
        Draw_()
      EndIf
      
	    ProcedureReturn BtEx()\Font\Num
	  EndProcedure  
	  
	  Procedure.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(BtEx(), Str(GNum))
	      
	      If IsFont(BtEx()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : BtEx()\PaddingX = PaddingX : EndIf 
	      If PaddingY <> #PB_Default : BtEx()\PaddingY = PaddingY : EndIf 
	      
	      BtEx()\Text = Text
	      
	      If BtEx()\Size\Flags & #FixPadding
		      Width  = BtEx()\Size\Text - BtEx()\PaddingX
          Height = GadgetHeight(BtEx()\CanvasNum) - BtEx()\PaddingY
		    Else
		      Width  = BtEx()\Size\Text - BtEx()\PaddingX
          Height = GadgetHeight(BtEx()\CanvasNum) - (GadgetHeight(BtEx()\CanvasNum) * BtEx()\PFactor)
		    EndIf
		    
		    FontSize = ModuleEx::RequiredFontSize(BtEx()\Text, Width, Height, BtEx()\Font\Num)
		    If FontSize <> BtEx()\Font\Size
          BtEx()\Font\Size = FontSize
          BtEx()\Font\Num  = ModuleEx::Font(BtEx()\Font\Name, FontSize, BtEx()\Font\Style)
          BtEx()\FontID = FontID(BtEx()\Font\Num)
        EndIf 
        
        Draw_()
      EndIf
      
	    ProcedureReturn BtEx()\Font\Num
	  EndProcedure  
	  
	CompilerEndIf  
	
EndModule

;- ======== Module - Example ========

CompilerIf #PB_Compiler_IsMainFile

	UsePNGImageDecoder()

	#Window = 0

	Enumeration 1
		#Button
		#ButtonEx
		#ButtonImg
		#ButtonML
		#DropDown
		#DropDown_Item1
		#DropDown_Item2
		#Image
		#Font
		#Font11
	EndEnumeration

	LoadFont(#Font, "Arial", 9, #PB_Font_Bold)
  LoadFont(#Font11, "Arial", 11)
	LoadImage(#Image, "Delete.png")

	If OpenWindow(#Window, 0, 0, 450, 80, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)

		If CreatePopupMenu(#DropDown)
			MenuItem(#DropDown_Item1, "Item 1")
			MenuItem(#DropDown_Item2, "Item 2")
		EndIf

		ButtonGadget(#Button, 15, 19, 90, 27, "Button")

		ButtonEx::Gadget(#ButtonEx, 120, 20, 90, 25, "ButtonEx", #False, #Window) ; ButtonEx::#MacOS 
		ButtonEx::AddDropDown(#ButtonEx, #DropDown)
		;ButtonEx::SetColor(#ButtonEx, ButtonEx::#FrontColor, $800000)
		;ButtonEx::SetColor(#ButtonEx, ButtonEx::#BorderColor, $B48246)
		;ButtonEx::SetColor(#ButtonEx, ButtonEx::#BackColor, $E6D8AD)
		
		;ButtonEx::SetAttribute(#ButtonEx, ButtonEx::#Corner, 4)
		
		ButtonEx::Gadget(#ButtonImg, 235, 20, 90, 25, "Delete", ButtonEx::#MacOS, #Window) ; ButtonEx::#Toggle|ButtonEx::#MacOS
		ButtonEx::AddImage(#ButtonImg, #Image, 16, 16, ButtonEx::#Right)
		ButtonEx::SetFont(#ButtonImg, #Font)
		;ButtonEx::SetColor(#ButtonImg, ButtonEx::#BackColor, $E1E4FF)
    ;ButtonEx::SetColor(#ButtonImg, ButtonEx::#BorderColor, $0000FF)
		

		ButtonEx::Gadget(#ButtonML, 345, 20, 90, 40, "MultiLine1 MultiLine2", ButtonEx::#MultiLine|ButtonEx::#AutoResize, #Window) ; ButtonEx::#MacOS
		ButtonEx::SetAutoResizeFlags(#ButtonML, ButtonEx::#Width|ButtonEx::#Height)
		
		CompilerIf Defined(ModuleEx, #PB_Module)
		  
		  ButtonEx::SetDynamicFont(#ButtonEx, "Arial", 9)
		  ButtonEx::FitText(#ButtonEx, 4, 4)
		  
		  ButtonEx::SetText(#ButtonML, "MultiLine1" + #LF$ + "MultiLine2")
		  ButtonEx::SetDynamicFont(#ButtonML, "Arial", 9, #PB_Font_Bold)
		  ButtonEx::SetAutoResizeFlags(#ButtonML, ButtonEx::#Width|ButtonEx::#Height|ButtonEx::#FitText) ; |ButtonEx::#FixPadding

		  ModuleEx::SetTheme(ModuleEx::#Theme_Dark)
		  
		CompilerEndIf
		
		;ButtonEx::SetColor(#ButtonML, ButtonEx::#BackColor, $008000)
		;ButtonEx::SetColor(#ButtonML, ButtonEx::#FrontColor, $00D7FF)
		;ButtonEx::SetColor(#ButtonML, ButtonEx::#BorderColor, $32CD9A)
		;ButtonEx::SetFont(#ButtonML, #Font)
		
		;DisableGadget(#Button, #True)
		;ButtonEx::Disable(#ButtonEx)
		
		Repeat
			Event = WaitWindowEvent()
			Select Event
				Case ButtonEx::#Event_Gadget ; works with or without EventType()
					Select EventGadget()
						Case #ButtonImg
							Debug "Delete button pressed"
						Case #ButtonML
							Debug "Multiline button pressed"
					EndSelect
				Case #PB_Event_Gadget
					Select EventGadget()
						Case #ButtonEx ; only in use with EventType()
							Select EventType()
								Case ButtonEx::#EventType_Button
									Debug "ButtonEx pressed"
								Case ButtonEx::#EventType_DropDown
									Debug "DropDown clicked"
							EndSelect
					EndSelect
				Case #PB_Event_Menu
					Select EventMenu()
						Case #DropDown_Item1
							Debug "DropDown Item 1 clicked"
						Case #DropDown_Item2
							Debug "DropDown Item 2 clicked"
					EndSelect
			EndSelect
		Until Event = #PB_Event_CloseWindow

		CloseWindow(#Window)
	EndIf

CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 80
; FirstLine = 33
; Folding = cgAEA966wAYQAw-
; EnableXP
; DPIAware