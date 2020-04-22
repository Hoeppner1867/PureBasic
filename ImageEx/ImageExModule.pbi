;/ ===========================
;/ =    ImageExModule.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ ImageEx - Gadget
;/
;/ © 2019  by Thorsten Hoeppner (09/2019)
;/

; Last Update: 22.04.20
;
; Added: Support of multi-frame images (e.g GIF)
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


;{ _____ ImageEx - Commands _____

; ImageEx::AttachPopupMenu()    ; attachs a popup menu to the gadget
; ImageEx::DisableReDraw()      ; enable/disable redrawing of the gadget
; ImageEx::Gadget()             ; creates a new gadget
; ImageEx::SetAutoResizeFlags() ; [#MoveX|#MoveY|#Width|Height]
; ImageEx::SetColor()           ; similar to SetGadgetColor()
; ImageEx::SetFont()            ; similar to SetGadgetFont(), but FontNumber instead of FontID
; ImageEx::SetFlags()           ; adds flags to the gadget
; ImageEx::SetMargins()         ; define margins
; ImageEx::SetState()           ; similar to SetGadgetState(), but ImageNumber instead of ImageID
; ImageEx::SetText()            ; similar to SetGadgetText()
; ImageEx::ToolTip()            ; similar to GadgetToolTip()

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule ImageEx
  
  #Version  = 20042200
  #ModuleEx = 20041700
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

	;{ _____ Constants _____
	EnumerationBinary ;{ Gadget Flags
		#AutoResize        ; Automatic resizing of the gadget           
		#IgnoreProportion  ; ignore proportion of image
		#AdjustBorder      ; fit border to image
		#AdjustBackground  ; fit background color for images with alpha channel
		#ChangeCursor
		#Always24Bit
		#UseExistingCanvas
		#Border = #PB_Image_Border ; Draw a border (512)
	EndEnumeration ;}
	
	EnumerationBinary ;{ Text Flags
	  #Center = #PB_Text_Center
	  #Right  = #PB_Text_Right
	  #Left
	  #Top
	  #Middle
	  #Bottom
	  #FitText
	  #FixPadding
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
	EndEnumeration ;}

	CompilerIf Defined(ModuleEx, #PB_Module)

	  #Event_Gadget = ModuleEx::#Event_Gadget
	  #Event_Timer  = ModuleEx::#Event_Timer
		#Event_Theme  = ModuleEx::#Event_Theme
		
	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
		  #Event_Gadget
		  #Event_Timer
		EndEnumeration
		
		Enumeration #PB_EventType_FirstCustomValue
      #EventType_Image
    EndEnumeration
		
	CompilerEndIf
	;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================

  Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, ImageNum.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontID.i)
  Declare   SetFlags(GNum.i, Flags.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetMargins(GNum.i, Left.i, Top.i, Bottom.i=#PB_Default, Right.i=#PB_Default)
  Declare   SetState(GNum.i, ImageNum.i)
  Declare   SetText(GNum.i, Text.s, Flags.i=#False)
  Declare   ToolTip(GNum.i, Text.s)
  
  CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Declare.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  Declare.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	  Declare.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  
	CompilerEndIf
  
EndDeclareModule

Module ImageEx

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================

	#Frequency = 600
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	Structure ImageEx_Font_Structure    ;{ ImageEx()\Font\...
	  Num.i
	  Name.s
	  Size.i
	  Style.i
	EndStructure ;}
	
	Structure Frame_Structure           ;{ ImageEx()\Frame\...
	  Index.i
	  Delay.i
	  Count.i
	  Pause.i
	EndStructure ;}
	
	Structure ImageEx_Image_Structure   ;{ ImageEx()\Image\
	  Num.i
	  Width.i
	  Height.i
	  Depth.i
	  Factor.f
	EndStructure ;}
	
	Structure ImageEx_Text_Structure    ;{ ImageEx()\Text\
	  Value.s
	  PaddingX.i
	  PaddingY.i
	  PFactor.f
	  Width.i
	  Height.i
	  Flags.i
	EndStructure ;}
	
	Structure ImageEx_Current_Structure ;{ ImageEx()\Current\
	  X.i
	  Y.i
	  Width.i
	  Height.i
	EndStructure ;}
	
	Structure ImageEx_Margins_Structure ;{ ImageEx()\Margin\...
		Top.i
		Left.i
		Right.i
		Bottom.i
	EndStructure ;}

	Structure ImageEx_Color_Structure   ;{ ImageEx()\Color\...
		Front.i
		Back.i
		Gadget.i
		Border.i
	EndStructure  ;}

	Structure ImageEx_Window_Structure  ;{ ImageEx()\Window\...
		Num.i
		Width.f
		Height.f
	EndStructure ;}

	Structure ImageEx_Size_Structure    ;{ ImageEx()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Text.i
		Flags.i
	EndStructure ;}
	
	
	Structure ImageEx_Structure         ;{ ImageEx()\...
		CanvasNum.i
		PopupNum.i
		
		Image.ImageEx_Image_Structure
		Frame.Frame_Structure
		Text.ImageEx_Text_Structure
		
		Quad.q
		ID.s
		
		FontID.i

		ReDraw.i
		Hide.i
		
		Flags.i

		ToolTip.i
		ToolTipText.s

		Color.ImageEx_Color_Structure
		Current.ImageEx_Current_Structure
		Font.ImageEx_Font_Structure
		Margin.ImageEx_Margins_Structure
		Window.ImageEx_Window_Structure
		Size.ImageEx_Size_Structure

	EndStructure ;}
	Global NewMap ImageEx.ImageEx_Structure()
	
	
	Structure Timer_Thread_Structure    ;{ Thread\...
	  Num.i
	  Frequency.i
	  Active.i
    Exit.i
  EndStructure ;}
	Global Thread.Timer_Thread_Structure
	
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
		ProcedureReturn DesktopScaledX(Num)
	EndProcedure

	Procedure.f dpiY(Num.i)
		ProcedureReturn DesktopScaledY(Num)
	EndProcedure

	;- __________ Drawing __________

	Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
		Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
		Define.f Blend = Factor / 100

		Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
		Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)

		ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
	EndProcedure

	Procedure   Draw_()
	  Define.i X, Y, Width, Height, txtX, txtY
	  Define.i imgX, imgY, imgWidth, imgHeight
		Define.f winFactor
		
		If ImageEx()\Hide : ProcedureReturn #False : EndIf
		
		X = ImageEx()\Margin\Left
		Y = ImageEx()\Margin\Top

		Width  = dpiX(GadgetWidth(ImageEx()\CanvasNum)  - ImageEx()\Margin\Left - ImageEx()\Margin\Right)
		Height = dpiY(GadgetHeight(ImageEx()\CanvasNum) - ImageEx()\Margin\Top  - ImageEx()\Margin\Bottom)

		If StartDrawing(CanvasOutput(ImageEx()\CanvasNum))

			DrawingFont(ImageEx()\FontID)
			
			;{ Adjust image width and height
			If ImageEx()\Image\Width > Width Or ImageEx()\Image\Height > Height ;{ Resize Image 
			
  			If ImageEx()\Flags & #IgnoreProportion

			    imgWidth  = Width
			    imgHeight = Height 

  			Else

			    winFactor = Height / Width
			    
  		    If winFactor < ImageEx()\Image\Factor
  		      imgWidth  = Height / ImageEx()\Image\Factor
  		      imgHeight = Height
  		    Else
  		      imgWidth  = Width
  		      imgHeight = Width * ImageEx()\Image\Factor
  		    EndIf

  		  EndIf
  		  ;}
  		Else  
  		 
		    imgWidth  = ImageEx()\Image\Width
		    imgHeight = ImageEx()\Image\Height
		    
		  EndIf ;}
		  
		  If imgWidth  < Width  : imgX = X + ((Width  - imgWidth)  / 2) : EndIf
		  If imgHeight < Height : imgY = Y + ((Height - imgHeight) / 2) : EndIf 
		  
		  ;{ _____ Background _____
		  DrawingMode(#PB_2DDrawing_Default)
		  If ImageEx()\Flags & #AdjustBackground
		    Box(0, 0, dpiX(GadgetWidth(ImageEx()\CanvasNum)), dpiY(GadgetHeight(ImageEx()\CanvasNum)), ImageEx()\Color\Gadget)
		    Box(imgX, imgY, imgWidth, imgHeight, ImageEx()\Color\Back)
		  Else
			  Box(0, 0, dpiX(GadgetWidth(ImageEx()\CanvasNum)), dpiY(GadgetHeight(ImageEx()\CanvasNum)), ImageEx()\Color\Back)
			EndIf 
			;}		  
		  If ImageEx()\Image\Depth = 32
		    DrawingMode(#PB_2DDrawing_AlphaBlend)
		  Else
		    DrawingMode(#PB_2DDrawing_Default)
		  EndIf
		  
		  If IsImage(ImageEx()\Image\Num)
  		  DrawImage(ImageID(ImageEx()\Image\Num), imgX, imgY, imgWidth, imgHeight)
  		EndIf
		
		  ImageEx()\Current\X = imgX
		  ImageEx()\Current\Y = imgY
		  ImageEx()\Current\Width  = imgWidth
		  ImageEx()\Current\Height = imgHeight
		  
		  If ImageEx()\Text\Value ;{ Text
		    
		    ImageEx()\Text\Width  = imgWidth  - (ImageEx()\Text\PaddingX * 2)		    
		    ImageEx()\Size\Text   = TextHeight(ImageEx()\Text\Value)
		    
		    If ImageEx()\Text\Flags & #Left
  		    txtX = imgX + ImageEx()\Text\PaddingX
  		  ElseIf ImageEx()\Text\Flags & #Right
  		    txtX = imgX + imgWidth - TextWidth(ImageEx()\Text\Value) - ImageEx()\Text\PaddingX
  		  Else
  		    txtX = imgX + ((imgWidth - TextWidth(ImageEx()\Text\Value)) / 2)
  		  EndIf   
		    
		    If ImageEx()\Text\Flags & #Top
		      txtY = imgY + ImageEx()\Text\PaddingY
		    ElseIf ImageEx()\Text\Flags & #Middle
		      txtY = imgY + ((imgHeight - TextHeight(ImageEx()\Text\Value)) / 2)
		    Else
		      txtY = imgY + imgHeight - TextHeight(ImageEx()\Text\Value) - ImageEx()\Text\PaddingY
		    EndIf
		    
		    DrawingMode(#PB_2DDrawing_Transparent)
		    DrawText(txtX, txtY, ImageEx()\Text\Value, ImageEx()\Color\Front)
		    ;}
		  EndIf
		  
			;{ _____ Border ____
			If ImageEx()\Flags & #Border
			  DrawingMode(#PB_2DDrawing_Outlined)
			  If ImageEx()\Flags & #AdjustBorder
			    Box(imgX, imgY, imgWidth, imgHeight, ImageEx()\Color\Border)
			  Else
			    Box(0, 0, dpiX(GadgetWidth(ImageEx()\CanvasNum)), dpiY(GadgetHeight(ImageEx()\CanvasNum)), ImageEx()\Color\Border)
			  EndIf  
			EndIf ;}

			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ImageEx()
        
				ImageEx()\Color\Front  = ModuleEx::ThemeGUI\FrontColor
				ImageEx()\Color\Back   = ModuleEx::ThemeGUI\GadgetColor
				ImageEx()\Color\Border = ModuleEx::ThemeGUI\BorderColor
				ImageEx()\Color\Gadget = ModuleEx::ThemeGUI\GadgetColor

        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 	
	
  
  Procedure _TimerThread(Frequency.i)
    Define.i ElapsedTime
    
    Thread\Frequency = Frequency
    
    Repeat
      
      If ElapsedTime >= Thread\Frequency
        PostEvent(#Event_Timer)
        ElapsedTime = 0
      EndIf
      
      Delay(Thread\Frequency)
      
      ElapsedTime + Thread\Frequency
      
    Until Thread\Exit
    
  EndProcedure
  
  Procedure _ImageFrames()
    
    ForEach ImageEx()
      
      If ImageEx()\Frame\Pause = #False
        
        SetImageFrame(ImageEx()\Image\Num, ImageEx()\Frame\Index)
        
        ImageEx()\Frame\Index + 1
        
        Draw_()
        
        If ImageEx()\Frame\Index >= ImageEx()\Frame\Count
          ImageEx()\Frame\Index = 0
        EndIf
        
      EndIf
      
    Next
  
  EndProcedure
  
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()

    If FindMapElement(ImageEx(), Str(GNum))
      ImageEx()\Frame\Pause = #False
    EndIf
    
  EndProcedure 
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()

    If FindMapElement(ImageEx(), Str(GNum))
      Thread\Frequency = ImageEx()\Frame\Delay
      ImageEx()\Frame\Pause = #True
    EndIf
    
  EndProcedure
  
	Procedure _LeftDoubleClickHandler()
		Define.i X, Y
		Define.i GadgetNum = EventGadget()

		If FindMapElement(ImageEx(), Str(GadgetNum))

			X = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseY)
			
			If X >= ImageEx()\Current\X And X <= ImageEx()\Current\X + ImageEx()\Current\Width
			  If Y >= ImageEx()\Current\ Y And Y <= ImageEx()\Current\Y +ImageEx()\Current\Height
			    
			    PostEvent(#Event_Gadget, ImageEx()\Window\Num, GadgetNum, #PB_EventType_LeftDoubleClick)
			    
			  EndIf
			EndIf 
			
		EndIf

	EndProcedure

	Procedure _RightClickHandler()
		Define.i X, Y
		Define.i GadgetNum = EventGadget()

		If FindMapElement(ImageEx(), Str(GadgetNum))

			X = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseY)

			If X >= ImageEx()\Current\X And X <= ImageEx()\Current\X + ImageEx()\Current\Width
			  If Y >= ImageEx()\Current\ Y And Y <= ImageEx()\Current\Y +ImageEx()\Current\Height
			    
			    If IsWindow(ImageEx()\Window\Num) And IsMenu(ImageEx()\PopUpNum)
						DisplayPopupMenu(ImageEx()\PopUpNum, WindowID(ImageEx()\Window\Num))
					Else
					  PostEvent(#Event_Gadget, ImageEx()\Window\Num, GadgetNum, #PB_EventType_RightClick)
					EndIf
			    
			  EndIf
			EndIf 

		EndIf

	EndProcedure

	Procedure _LeftButtonDownHandler()
		Define.i X, Y
		Define.i GadgetNum = EventGadget()

		If FindMapElement(ImageEx(), Str(GadgetNum))

			X = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseY)
			
      If X >= ImageEx()\Current\X And X <= ImageEx()\Current\X + ImageEx()\Current\Width
			  If Y >= ImageEx()\Current\ Y And Y <= ImageEx()\Current\Y +ImageEx()\Current\Height
			    
			    PostEvent(#Event_Gadget, ImageEx()\Window\Num, GadgetNum, #PB_EventType_LeftClick)
			    
			  EndIf
			EndIf 

		EndIf

	EndProcedure

	Procedure _LeftButtonUpHandler()
		Define.i X, Y, Angle
		Define.i GadgetNum = EventGadget()

		If FindMapElement(ImageEx(), Str(GadgetNum))

			X = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_MouseY)
			
			If X >= ImageEx()\Current\X And X <= ImageEx()\Current\X + ImageEx()\Current\Width
			  If Y >= ImageEx()\Current\ Y And Y <= ImageEx()\Current\Y +ImageEx()\Current\Height
			    
			    PostEvent(#Event_Gadget, ImageEx()\Window\Num, GadgetNum, #PB_EventType_LeftClick)
			    
			  EndIf
			EndIf 
			
		EndIf

	EndProcedure

	Procedure _MouseMoveHandler()
		Define.i X, Y
		Define.i GadgetNum = EventGadget()

		If FindMapElement(ImageEx(), Str(GadgetNum))

			X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
			Y = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)

      If X >= ImageEx()\Current\X And X <= ImageEx()\Current\X + ImageEx()\Current\Width
			  If Y >= ImageEx()\Current\ Y And Y <= ImageEx()\Current\Y +ImageEx()\Current\Height
			    
			    If ImageEx()\Flags & #ChangeCursor And GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_Cursor ) = #PB_Cursor_Default
			      SetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
			    EndIf 
			    
			    If ImageEx()\ToolTip = #False
			      GadgetToolTip(ImageEx()\CanvasNum, ImageEx()\ToolTipText)
			      ImageEx()\ToolTip = #True
			    EndIf
			    
			    ProcedureReturn #True
			  EndIf
			EndIf
			
			If ImageEx()\Flags & #ChangeCursor And GetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_Cursor ) = #PB_Cursor_Hand
			  SetGadgetAttribute(ImageEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
			EndIf
			
			If ImageEx()\ToolTip = #True
  			ImageEx()\ToolTip  = #False
  			GadgetToolTip(ImageEx()\CanvasNum, "")
  	  EndIf
	
		EndIf

	EndProcedure


	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(ImageEx(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
		Define.i X, Y, Width, Height, FontSize
		Define.f OffSetX, OffSetY

		ForEach ImageEx()

			If IsGadget(ImageEx()\CanvasNum)

				If ImageEx()\Flags & #AutoResize

					If IsWindow(ImageEx()\Window\Num)

						OffSetX = WindowWidth(ImageEx()\Window\Num)  - ImageEx()\Window\Width
						OffsetY = WindowHeight(ImageEx()\Window\Num) - ImageEx()\Window\Height
						
						If ImageEx()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If ImageEx()\Size\Flags & #MoveX : X = GadgetX(ImageEx()\CanvasNum) + OffSetX : EndIf
							If ImageEx()\Size\Flags & #MoveY : Y = GadgetY(ImageEx()\CanvasNum) + OffSetY : EndIf
							If ImageEx()\Size\Flags & #Width  : Width  = ImageEx()\Size\Width  + OffSetX : EndIf
							If ImageEx()\Size\Flags & #Height : Height = ImageEx()\Size\Height + OffSetY : EndIf

							ResizeGadget(ImageEx()\CanvasNum, X, Y, Width, Height)

						Else
							ResizeGadget(ImageEx()\CanvasNum, #PB_Ignore, #PB_Ignore, ImageEx()\Size\Width + OffSetX, ImageEx()\Size\Height + OffsetY)
						EndIf
						
						CompilerIf Defined(ModuleEx, #PB_Module)
			
        		  If ImageEx()\Text\Flags & #FitText
        		    
        		    If ImageEx()\Text\Flags & #FixPadding
        		      Width  = ImageEx()\Text\Width  - (ImageEx()\Text\PaddingX * 2)
        		      Height = ImageEx()\Current\Height - ImageEx()\Text\Height
        		    Else
        		      Width  = ImageEx()\Text\Width  - (ImageEx()\Text\PaddingX * 2)
        		      Height = ImageEx()\Current\Height - (ImageEx()\Current\Height * ImageEx()\Text\PFactor)
        		    EndIf  
        		    
        		    If Height < 0 : Height = 0 : EndIf 
        		    If Width  < 0 : Width  = 0 : EndIf
        		    
        		    FontSize = ModuleEx::RequiredFontSize(ImageEx()\Text\Value, Width, Height, ImageEx()\Font\Num)
        		    If FontSize <> ImageEx()\Font\Size
                  ImageEx()\Font\Size = FontSize
                  ImageEx()\Font\Num  = ModuleEx::Font(ImageEx()\Font\Name, FontSize, ImageEx()\Font\Style)
                  If IsFont(ImageEx()\Font\Num) : ImageEx()\FontID = FontID(ImageEx()\Font\Num) : EndIf
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
	;-   Module - Declared Procedures
	;- ==========================================================================

	Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)

		If FindMapElement(ImageEx(), Str(GNum))
			ImageEx()\PopupNum = PopUpNum
		EndIf

	EndProcedure

	Procedure   DisableReDraw(GNum.i, State.i=#False)

		If FindMapElement(ImageEx(), Str(GNum))

			If State
				ImageEx()\ReDraw = #False
			Else
				ImageEx()\ReDraw = #True
				Draw_()
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, ImageNum.i, Flags.i=#False, WindowNum.i=#PB_Default)
		Define DummyNum, Result.i
		
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

			If AddMapElement(ImageEx(), Str(GNum))

				ImageEx()\CanvasNum = GNum

  			If WindowNum = #PB_Default
          ImageEx()\Window\Num = GetGadgetWindow()
        Else
          ImageEx()\Window\Num = WindowNum
        EndIf

				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						ImageEx()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							ImageEx()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						ImageEx()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}
				
				If Thread\Active = #False
          Thread\Exit   = #False
          Thread\Num    = CreateThread(@_TimerThread(), #Frequency)
          Thread\Active = #True
        EndIf

				
				ImageEx()\Size\X = X
				ImageEx()\Size\Y = Y
				ImageEx()\Size\Width  = Width
				ImageEx()\Size\Height = Height

				ImageEx()\Margin\Left   = 0
				ImageEx()\Margin\Right  = 0
				ImageEx()\Margin\Top    = 0
				ImageEx()\Margin\Bottom = 0
				
				ImageEx()\Image\Num = ImageNum
				If IsImage(ImageNum)
				  ImageEx()\Image\Width  = ImageWidth(ImageNum)
				  ImageEx()\Image\Height = ImageHeight(ImageNum)
				  ImageEx()\Image\Depth  = ImageDepth(ImageNum)
				  ImageEx()\Image\Factor = ImageEx()\Image\Height / ImageEx()\Image\Width
				EndIf   
				
				ImageEx()\Flags = Flags

				ImageEx()\ReDraw = #True

				ImageEx()\Color\Front  = $000000
				ImageEx()\Color\Back   = $EDEDED
				ImageEx()\Color\Border = $A0A0A0
				ImageEx()\Color\Gadget = $EDEDED
				
				CompilerSelect #PB_Compiler_OS ;{ Color
					CompilerCase #PB_OS_Windows
						ImageEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
						ImageEx()\Color\Back          = GetSysColor_(#COLOR_MENU)
						ImageEx()\Color\Gadget        = GetSysColor_(#COLOR_MENU)
						ImageEx()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
					CompilerCase #PB_OS_MacOS
						ImageEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						ImageEx()\Color\Back          = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						ImageEx()\Color\Gadget        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
						ImageEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}

				BindGadgetEvent(ImageEx()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
				BindGadgetEvent(ImageEx()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
				BindGadgetEvent(ImageEx()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
				BindGadgetEvent(ImageEx()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
				BindGadgetEvent(ImageEx()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
				BindGadgetEvent(ImageEx()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
				BindGadgetEvent(ImageEx()\CanvasNum,  @_LostFocusHandler(),       #PB_EventType_LostFocus)
				BindGadgetEvent(ImageEx()\CanvasNum,  @_FocusHandler(),           #PB_EventType_Focus)
				
				BindEvent(#Event_Timer, @_ImageFrames())
				
        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf				
				
				If Flags & #AutoResize ;{ Enabel AutoResize
					If IsWindow(ImageEx()\Window\Num)
						ImageEx()\Window\Width  = WindowWidth(ImageEx()\Window\Num)
						ImageEx()\Window\Height = WindowHeight(ImageEx()\Window\Num)
						BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ImageEx()\Window\Num)
					EndIf
				EndIf ;}

				Draw_()

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(ImageEx(), Str(GNum))
	    ProcedureReturn ImageEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(ImageEx(), Str(GNum))
	    ProcedureReturn ImageEx()\ID
	  EndIf
	  
	EndProcedure

	
	Procedure   Hide(GNum.i, State.i=#True)
  
    If FindMapElement(ImageEx(), Str(GNum))
      
      If State
        ImageEx()\Hide = #True
        HideGadget(GNum, #True)
      Else
        ImageEx()\Hide = #False
        HideGadget(GNum, #False)
        Draw_()
      EndIf  
      
    EndIf  
    
  EndProcedure	
  
  
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ImageEx(), Str(GNum))
      
      ImageEx()\Size\Flags = Flags
      ImageEx()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(ImageEx(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          ImageEx()\Color\Front  = Value
        Case #BackColor
          ImageEx()\Color\Back   = Value
        Case #BorderColor
          ImageEx()\Color\Border = Value
      EndSelect
      
      If ImageEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(ImageEx(), Str(GNum))
	    ImageEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
  Procedure   SetFlags(GNum.i, Flags.i) 
    
    If FindMapElement(ImageEx(), Str(GNum))
      
      ImageEx()\Flags | Flags

      If ImageEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure 
  
  Procedure   SetFont(GNum.i, FontNum.i) 
    
    If FindMapElement(ImageEx(), Str(GNum))
      
      If IsFont(FontNum)
        ImageEx()\FontID = FontID(FontNum)
      EndIf
    
      If ImageEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(ImageEx(), Str(GNum))
	    ImageEx()\ID = String
	  EndIf
	  
	EndProcedure  
  
  Procedure   SetMargins(GNum.i, Left.i, Top.i, Bottom.i=#PB_Default, Right.i=#PB_Default)
    
    If FindMapElement(ImageEx(), Str(GNum))
      
      ImageEx()\Margin\Left   = Left
      ImageEx()\Margin\Top    = Top
      
      If Bottom = #PB_Default : Bottom = Top  : EndIf
      If Right  = #PB_Default : Right  = Left : EndIf
      
      ImageEx()\Margin\Bottom = Bottom
      ImageEx()\Margin\Right  = Right
      
      If ImageEx()\ReDraw : Draw_() : EndIf
    EndIf  
    
  EndProcedure  
  
  Procedure   SetState(GNum.i, ImageNum.i)
    
    If FindMapElement(ImageEx(), Str(GNum))
      
      ImageEx()\Frame\Pause     = #True
      Thread\Frequency = 600
      
      ImageEx()\Image\Num = ImageNum
      If IsImage(ImageNum)
        
			  ImageEx()\Image\Width  = ImageWidth(ImageNum)
			  ImageEx()\Image\Height = ImageHeight(ImageNum)
			  ImageEx()\Image\Depth  = ImageDepth(ImageNum)
			  ImageEx()\Image\Factor = ImageEx()\Image\Height / ImageEx()\Image\Width
			  ImageEx()\Frame\Count  = ImageFrameCount(ImageNum)
			  ImageEx()\Frame\Delay  = GetImageFrameDelay(ImageNum)
			  ImageEx()\Frame\Index  = 0
			  
			  If ImageEx()\Frame\Count > 1
			    Thread\Frequency = ImageEx()\Frame\Delay
			    ImageEx()\Frame\Pause = #False
			    SetActiveGadget(ImageEx()\CanvasNum)
			  EndIf  

			EndIf  
      
      If ImageEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetText(GNum.i, Text.s, Flags.i=#False)
    
    If FindMapElement(ImageEx(), Str(GNum))
      
      ImageEx()\Text\Value    = Text
      ImageEx()\Text\PaddingX = 6
      ImageEx()\Text\PaddingY = 6
      ImageEx()\Text\Flags    = Flags
      
      If ImageEx()\ReDraw : Draw_() : EndIf
    EndIf
  
  EndProcedure
  
  
  Procedure   ToolTip(GNum.i, Text.s)
    
    If FindMapElement(ImageEx(), Str(GNum))
      ImageEx()\ToolTipText = Text
    EndIf
    
  EndProcedure
  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
	  
    Procedure.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	    Define.i FontNum
	    Define   Padding.ModuleEx::Padding_Structure
	    
	    If FindMapElement(ImageEx(), Str(GNum))
	      
	      FontNum = ModuleEx::Font(Name, Size, Style)
	      If IsFont(FontNum)
	        
	        ImageEx()\Font\Num   = FontNum
	        ImageEx()\Font\Name  = Name
	        ImageEx()\Font\Size  = Size
	        ImageEx()\Font\Style = Style
	        ImageEx()\FontID     = FontID(FontNum)
	        
	        ModuleEx::CalcPadding(ImageEx()\Text\Value, ImageEx()\Current\Height, ImageEx()\Font\Num, ImageEx()\Font\Size, @Padding)
	        ImageEx()\Text\Height  = Padding\Y
	        ImageEx()\Text\PFactor = Padding\Factor
	        
	        Draw_()
	      EndIf
	      
	    EndIf
	    
	    ProcedureReturn FontNum
	  EndProcedure
	  
	  Procedure.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(ImageEx(), Str(GNum))
	      
	      If IsFont(ImageEx()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : ImageEx()\Text\PaddingX = PaddingX : EndIf 
	      If PaddingY <> #PB_Default : ImageEx()\Text\PaddingY = PaddingY : EndIf 
	      
		    Width  = ImageEx()\Text\Width - ImageEx()\Text\PaddingX
        Height = GadgetHeight(ImageEx()\CanvasNum) - ImageEx()\Text\PaddingY
		  
		    FontSize = ModuleEx::RequiredFontSize(ImageEx()\Text\Value, Width, Height, ImageEx()\Font\Num)
		    If FontSize <> ImageEx()\Font\Size
          ImageEx()\Font\Size = FontSize
          ImageEx()\Font\Num  = ModuleEx::Font(ImageEx()\Font\Name, FontSize, ImageEx()\Font\Style)
          ImageEx()\FontID    = FontID(ImageEx()\Font\Num)
        EndIf  
        
        Draw_()
      EndIf
      
	    ProcedureReturn ImageEx()\Font\Num
	  EndProcedure  
	  
	  Procedure.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(ImageEx(), Str(GNum))
	      
	      If IsFont(ImageEx()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : ImageEx()\Text\PaddingX = PaddingX : EndIf 
	      If PaddingY <> #PB_Default : ImageEx()\Text\PaddingY = PaddingY : EndIf 
	      
	      ImageEx()\Text\Value = Text
	      
		    Width  = ImageEx()\Text\Width - ImageEx()\Text\PaddingX
        Height = GadgetHeight(ImageEx()\CanvasNum) - ImageEx()\Text\PaddingY
		    
		    FontSize = ModuleEx::RequiredFontSize(ImageEx()\Text\Value, Width, Height, ImageEx()\Font\Num)
		    If FontSize <> ImageEx()\Font\Size
          ImageEx()\Font\Size = FontSize
          ImageEx()\Font\Num  = ModuleEx::Font(ImageEx()\Font\Name, FontSize, ImageEx()\Font\Style)
          ImageEx()\FontID = FontID(ImageEx()\Font\Num)
        EndIf 
        
        Draw_()
      EndIf
      
	    ProcedureReturn ImageEx()\Font\Num
	  EndProcedure  
	  
	CompilerEndIf 
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 1
  
  UsePNGImageDecoder()
  UseGIFImageDecoder()
  
  Enumeration 1 
    #Window
    #ImageEx
    #Font
  EndEnumeration

  #Image = 1
    
  If OpenWindow(#Window, 0, 0, 300, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If ImageEx::Gadget(#ImageEx, 10, 10, 280, 180, #False, ImageEx::#Border|ImageEx::#ChangeCursor|ImageEx::#AutoResize) ; 
      ;ImageEx::SetFlags(#ImageEx, ImageEx::#AdjustBorder|ImageEx::#AdjustBackground)
      ImageEx::SetColor(#ImageEx, ImageEx::#FrontColor, $B48246)
      ;ImageEx::SetColor(#ImageEx, ImageEx::#BackColor,  $FFFFFF)
      ImageEx::ToolTip(#ImageEx, "This is a image gadget")
    EndIf
    
    Select #Example
      Case 1
        
        LoadImage(#Image, "morph.gif")
        ImageEx::SetState(#ImageEx, #Image)
        
      Default 
        
        LoadImage(#Image, "TestH.png") ; TestH.png
        
        ImageEx::SetState(#ImageEx, #Image)
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          
          ImageEx::SetText(#ImageEx, "Example", ImageEx::#FitText)
          ImageEx::SetDynamicFont(#ImageEx, "Arial", 14, #PB_Font_Bold)
          
        CompilerElse  
          
          ImageEx::SetText(#ImageEx, "Thorsten", ImageEx::#FitText)
          LoadFont(#Font, "Arial", 14, #PB_Font_Bold)
          ImageEx::SetFont(#ImageEx, #Font)
          
        CompilerEndIf  
        
    EndSelect
    
    ; ModuleEx::SetTheme(ModuleEx::#Theme_Green)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case ImageEx::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #ImageEx
              Select EventType()
                Case #PB_EventType_LeftClick       ;{ Left mouse click
                  Debug "Left Click"
                  ;}
                Case #PB_EventType_LeftDoubleClick ;{ LeftDoubleClick
                  Debug "Left DoubleClick"
                  ;}
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

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 13
; Folding = YgCIAA5GQAAgE6-
; EnableThread
; EnableXP
; DPIAware