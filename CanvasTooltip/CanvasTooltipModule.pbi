﻿;/ ============================
;/ =    ToolTipModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ ToolTip - Gadget
;/
;/ © {Year}  by {Name} ({Month}/{Year})
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


;{ _____ ToolTip - Commands _____

; ToolTip::Gadget()       - Add tooltip gadget
; ToolTip::SetAttribute() - similar to SetGadgetAttribute()
; ToolTip::SetColor()     - similar to SetGadgetColor()
; ToolTip::SetContent()   - set tooltip text & Title and define tooltip area
; ToolTip::SetFont()      - similar to SetGadgetFont()
; ToolTip::SetImage()     - adds an image to the tooltip
; ToolTip::SetState()     - activates/deactivates tooltip

;}

DeclareModule ToolTip

	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  ;{ _____ Constants _____
  Enumeration 1  ; Type
	  #Gadget
	EndEnumeration
	
	Enumeration 1  ; Attribute
	  #PaddingX
	  #PaddingY
	  #Spacing
	  #Title
	  #Text
	EndEnumeration
	
	Enumeration 1  ; Color
	  #FrontColor
	  #BackColor
	  #BorderColor
	  #TitleColor
	  #TitleBackColor
	  #TitleBorderColor
	EndEnumeration
  
	EnumerationBinary ; GadgetFlags
		#Border ; Draw a border
	EndEnumeration

  Enumeration #PB_Event_FirstCustomValue
		#Event_ToolTip
	EndEnumeration ;}
	
	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================

	Declare.i Gadget(Gadget.i, Window.i, Flags.i=#False)
	Declare   SetAttribute(GNum.i, Attribute.i, Value.i) 
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetContent(GNum.i, Text.s, Title.s="", X.i=#PB_Default, Y.i=#PB_Default, Width.i=#PB_Default, Height.i=#PB_Default)
  Declare   SetFont(GNum.i, FontNum.i, FontType.i=#Text)
  Declare   SetImage(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Flags.i=#False)
  Declare   SetState(GNum.i, State.i)
  
EndDeclareModule

Module ToolTip

	EnableExplicit
	
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	Structure Timer_Structure           ;{ Timer()\...
	  GadgetNum.i
	  WindowNum.i
	  Focus.i
	  State.i
	  Active.i
	  Delay.i
	  Value.i
	EndStructure ;}
	
	Structure ToolTip_Image_Structure   ;{ ToolTip\Image\...
	  Num.i
	  Width.i
	  Height.i
	  Flags.i
	EndStructure ;}
	
	Structure ToolTip_Area_Structure    ;{ ToolTip\Area\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	EndStructure   ;}
	
	Structure ToolTip_Content_Structure ;{ ToolTip\Content\...
	  Title.s
	  TitleFont.i
	  TextFont.i
	  List Text.s()
	EndStructure ;}
	
	Structure ToolTip_Color_Structure   ;{ ToolTip()\Color\...
		Front.i
		Back.i
		TitleFront.i
		TitleBack.i
		TitleBorder.i
		Border.i
	EndStructure  ;}

	Structure ToolTip_Size_Structure    ;{ ToolTip()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}
	
	Structure ToolTip_Window_Structure  ;{ ToolTip()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
	Structure ToolTip_Structure         ;{ ToolTip()\...
	  CanvasNum.i
	  GadgetNum.i

	  
	  MouseX.i
	  MouseY.i
	  
	  Type.i

	  FontID.i
	  
	  PaddingX.f
	  PaddingY.f
	  Spacing.i
	  
	  Visible.i
	  
	  State.i
	  
	  Flags.i
	  
		Area.ToolTip_Area_Structure
		Color.ToolTip_Color_Structure
		Content.ToolTip_Content_Structure
		Image.ToolTip_Image_Structure
		Size.ToolTip_Size_Structure
		Window.ToolTip_Window_Structure
		
	EndStructure ;}
	Global NewMap ToolTip.ToolTip_Structure()
	
	Global ThreadID.i, ExitThread.i
	Global Mutex.i = CreateMutex()
	Global NewMap Timer.Timer_Structure()
	
	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================
	Declare _TimerThread(Map *Timer())
	
	UsePNGImageDecoder()
	
	Procedure.f dpiX(Num.i)
		ProcedureReturn DesktopScaledX(Num)
	EndProcedure

	Procedure.f dpiY(Num.i)
		ProcedureReturn DesktopScaledY(Num)
	EndProcedure
	
	Procedure StartTimerThread()

    If Not IsThread(ThreadID)
      ThreadID = CreateThread(@_TimerThread(), @Timer())
    EndIf
    
  EndProcedure
  
  Procedure StopTimerThread()

    ExitThread = #True
    
    Delay(200)
    
    While IsThread(ThreadID)
      KillThread(ThreadID)
      Delay(50)
    Wend
    
    ThreadID   = 0
    ExitThread = #False

  EndProcedure
  
	
	Procedure   GetFontID_(FontNum.i) 
	  
	  If FontNum = #PB_Default
	    ProcedureReturn ToolTip()\FontID
	  ElseIf IsFont(FontNum)
	    ProcedureReturn FontID(FontNum)
	  Else
	    ProcedureReturn ToolTip()\FontID
	  EndIf
	  
	EndProcedure
	
	Procedure.i MaxTextWidth(MaxWidth.i)
  	
	  ForEach ToolTip()\Content\Text()
	    If TextWidth(ToolTip()\Content\Text()) > MaxWidth
	      MaxWidth = TextWidth(ToolTip()\Content\Text())
	    EndIf
	  Next
	  
	  ProcedureReturn MaxWidth
	EndProcedure  
	
	Procedure   DeterminePosition_(X.i, Y.i, gWidth, gHeight)
	  Define.i gX, gY, wWidth, wHeigth, PosX, PosY, Reverse
	  
	  If IsGadget(ToolTip()\GadgetNum)
  	  gX = GadgetX(ToolTip()\GadgetNum)
  	  gY = GadgetY(ToolTip()\GadgetNum)
  	EndIf 
  	
  	If IsWindow(ToolTip()\Window\Num)
  	  wWidth  = WindowWidth(ToolTip()\Window\Num)
  	  wHeigth = WindowHeight(ToolTip()\Window\Num)
  	EndIf
  	
  	PosX = X + gX + ToolTip()\Size\Width
  	PosY = Y + gY
  	
  	If PosX < wWidth
  	  ToolTip()\Size\X = X + gX
  	Else
  	  ToolTip()\Size\X = X + gX - ToolTip()\Size\Width 
  	  Reverse = #True
  	EndIf
  	
  	If PosY - ToolTip()\Size\Height > 0 
  	  ToolTip()\Size\Y = Y + gY - ToolTip()\Size\Height + dpiY(1)
  	  ToolTip()\Size\X + dpiX(2)
  	ElseIf PosY + ToolTip()\Size\Height > wHeigth
  	  ToolTip()\Size\Y = Y + gY - ToolTip()\Size\Height + dpiY(1)
  	  ToolTip()\Size\X + dpiX(2)
  	Else
  	  ToolTip()\Size\Y = Y + gY + dpiY(2)
  	  If Reverse = #False
  	    ToolTip()\Size\X + dpiX(8)
  	  EndIf
  	EndIf
  	
	EndProcedure
	
  Procedure   DetermineSize_()
	  Define.i Rows
	  Define.f MaxWidth, TitleWidth, TitleHeight, textHeight
	  
	  If StartDrawing(CanvasOutput(ToolTip()\CanvasNum))
	    
		  If ToolTip()\Content\Title
		    DrawingFont(GetFontID_(ToolTip()\Content\TitleFont))
  	    TitleWidth  = TextWidth(ToolTip()\Content\Title)  + dpiX(2)
  	    TitleHeight = TextHeight(ToolTip()\Content\Title) + dpiY(2)
    	EndIf
    	
    	Rows = ListSize(ToolTip()\Content\Text())
    	
    	DrawingFont(GetFontID_(ToolTip()\Content\TextFont))
    	
    	textHeight = TextHeight("Abc")
    	MaxWidth   = MaxTextWidth(TitleWidth)
    	
    	ToolTip()\Size\Width  = MaxWidth + (ToolTip()\PaddingX * 2)
    	ToolTip()\Size\Height = TitleHeight + (textHeight * Rows) + (ToolTip()\PaddingY * 2)
    	
    	If IsImage(ToolTip()\Image\Num)
    	  
    	  ToolTip()\Size\Width + ToolTip()\Image\Width + ToolTip()\PaddingY

    	  If ToolTip()\Image\Height + (ToolTip()\PaddingY * 2) > ToolTip()\Size\Height
      	  ToolTip()\Size\Height = ToolTip()\Image\Height + (ToolTip()\PaddingY * 2)
      	EndIf

    	EndIf

	    StopDrawing()
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
	
	Procedure   Draw_()
		Define.i X, Y, Rows, TitleHeight, TextHeight, txtX, txtY, imgY
		
		If StartDrawing(CanvasOutput(ToolTip()\CanvasNum))

		  Rows = ListSize(ToolTip()\Content\Text())
		  
			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			Box(0, 0, ToolTip()\Size\Width, ToolTip()\Size\Height, ToolTip()\Color\Back)
			;}
			
			X = ToolTip()\PaddingX

			If ToolTip()\Content\Title
			  Y = dpiY(2)
			  TitleHeight = TextHeight(ToolTip()\Content\Title) + dpiY(2)
			  If ToolTip()\Color\TitleBack <> #PB_Default
			    DrawingMode(#PB_2DDrawing_Default)
			    Box(0, 0, ToolTip()\Size\Width, TitleHeight, ToolTip()\Color\TitleBack)
			  EndIf 
			  DrawingMode(#PB_2DDrawing_Transparent)
			  DrawingFont(GetFontID_(ToolTip()\Content\TitleFont))
			  txtX = (ToolTip()\Size\Width - (ToolTip()\PaddingX * 2) - TextWidth(ToolTip()\Content\Title)) / 2
			  DrawText(X + txtX, Y, ToolTip()\Content\Title, ToolTip()\Color\TitleFront)
			  Y + TextHeight(ToolTip()\Content\Title)
			EndIf
			
			Y + ToolTip()\PaddingY
			
			If IsImage(ToolTip()\Image\Num)
			  TextHeight = ToolTip()\Size\Height - TitleHeight - (ToolTip()\PaddingX * 2)
			  imgY = (TextHeight - ToolTip()\Image\Height) / 2
			  txtY = (TextHeight - (TextHeight("Abc") * ListSize(ToolTip()\Content\Text()))) / 2
			  DrawingMode(#PB_2DDrawing_AlphaBlend)
			  DrawImage(ImageID(ToolTip()\Image\Num), X, Y + imgY, ToolTip()\Image\Width, ToolTip()\Image\Height) 
			  X + ToolTip()\Image\Width + ToolTip()\PaddingX
			EndIf
			
			DrawingMode(#PB_2DDrawing_Transparent)
			DrawingFont(GetFontID_(ToolTip()\Content\TextFont))
			
			ForEach ToolTip()\Content\Text()
			  DrawText(X, Y + txtY, ToolTip()\Content\Text(), ToolTip()\Color\Front)
			  Y + TextHeight(ToolTip()\Content\Text())
			Next
			
			;{ _____ Border ____
			DrawingMode(#PB_2DDrawing_Outlined)
			Box(0, 0, ToolTip()\Size\Width, ToolTip()\Size\Height, BlendColor_(ToolTip()\Color\Border, ToolTip()\Color\Back, 40))
			If ToolTip()\Content\Title
			  If ToolTip()\Color\TitleBorder <> #PB_Default
			    DrawingMode(#PB_2DDrawing_Outlined)
			    Box(0, 0, ToolTip()\Size\Width, TitleHeight, BlendColor_(ToolTip()\Color\Border, ToolTip()\Color\Back, 40))
			  EndIf 
			  
			EndIf
			;}
			
			StopDrawing()
		EndIf

	EndProcedure

	;- __________ Events __________
	
	Procedure _TimerThread(Map *Timer())
	  
	  While Not ExitThread
	    
	    Delay(100)
	    
	    LockMutex(Mutex)

	    ForEach Timer()
	      
	      If Timer()\Focus And Timer()\State
	        If Timer()\Active
	          
	          Timer()\Value + 100
	          
	          If Timer()\Value >= Timer()\Delay
	            PostEvent(#Event_ToolTip, Timer()\WindowNum, Timer()\GadgetNum)
	            Timer()\Value  = 0
	            Timer()\Active = #False
	          EndIf
	          
	        EndIf
	      EndIf
	      
	    Next  
	    
	    UnlockMutex(Mutex)

	  Wend
	  
	EndProcedure
	
	Procedure _ToolTipHandler()
	  Define.i X, Y, gWidth, gHeight
	  Define.i GadgetNum = EventGadget()
	  
	  If FindMapElement(ToolTip(), Str(GadgetNum))
	    
	    If ToolTip()\State = #True
        ResizeGadget(ToolTip()\CanvasNum, DesktopUnscaledX(ToolTip()\Size\X), DesktopUnscaledY(ToolTip()\Size\Y), DesktopUnscaledX(ToolTip()\Size\Width), DesktopUnscaledY(ToolTip()\Size\Height))
        Draw_()
        ToolTip()\Visible = #True
        HideGadget(ToolTip()\CanvasNum, #False)
      EndIf
      
	  EndIf
	  
	EndProcedure
	
  Procedure _MouseEnterHandler()
	  Define.i GadgetNum = EventGadget()
	  Define.i X, Y, aX, aY, aWidth, aHeight, gX, gY, gWidth, gHeight
	  
	  If FindMapElement(ToolTip(), Str(GadgetNum))

	    LockMutex(Mutex)
	    Timer(Str(GadgetNum))\Focus = #True
	    Timer(Str(GadgetNum))\Value  = 0
	    Timer(Str(GadgetNum))\State = #False
	    UnlockMutex(Mutex)
	    
	  EndIf
	  
	EndProcedure
	
	Procedure _MouseLeaveHandler()
	  Define.i GadgetNum = EventGadget()
	  
	  If FindMapElement(ToolTip(), Str(GadgetNum))
	    
	    LockMutex(Mutex)
	    Timer(Str(GadgetNum))\Focus  = #False
	    Timer(Str(GadgetNum))\Active = #True
	    Timer(Str(GadgetNum))\Value  = 0
	    Timer(Str(GadgetNum))\State  = #False
      UnlockMutex(Mutex)
      
      ToolTip()\Visible = #False

	    HideGadget(ToolTip()\CanvasNum, #True)
	  EndIf
	  
	EndProcedure
	
	Procedure _MouseMoveHandler()
    Define.i X, Y, aX, aY, aWidth, aHeight, gWidth, gHeight
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ToolTip(), Str(GadgetNum))
      
      X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)
      
      If X <> ToolTip()\MouseX Or Y <> ToolTip()\MouseY
       
        ToolTip()\MouseX = X
        ToolTip()\MouseY = Y
        
        ;{ Cursor move
        LockMutex(Mutex)
        Timer(Str(GadgetNum))\Active = #True
        Timer(Str(GadgetNum))\Value  = 0
        UnlockMutex(Mutex)

        If ToolTip()\Visible
          ToolTip()\Visible = #False
          HideGadget(ToolTip()\CanvasNum, #True)
        EndIf
        ;}
  
        If IsGadget(GadgetNum)
          gWidth  = GadgetWidth(GadgetNum)
          gHeight = GadgetHeight(GadgetNum)
        EndIf
  
        ;{ ToolTip area
        aX = ToolTip()\Area\X
        If aX = #PB_Default : aX = 0 : EndIf
        aY = ToolTip()\Area\Y
        If aY = #PB_Default : aY = 0 : EndIf
        aWidth  = ToolTip()\Area\Width
        If aWidth  = #PB_Default : aWidth  = gWidth : EndIf
        aHeight = ToolTip()\Area\Height
        If aHeight = #PB_Default : aHeight = gHeight : EndIf
        ;}
        
        If X >= aX And X <= aX + aWidth
          If Y >= aY And Y <= aY + aHeight
            
      	    DetermineSize_() 
            DeterminePosition_(X, Y, GadgetWidth(GadgetNum), GadgetHeight(GadgetNum))                 
            LockMutex(Mutex)
            Timer(Str(GadgetNum))\State = #True
            UnlockMutex(Mutex)
              
            ProcedureReturn #True
          EndIf 
        EndIf  
        
        Timer()\State = #False
        
      EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure _CloseWindowHandler()
    Define.i WindowNum = EventWindow()
    
    ForEach ToolTip()
      
      If ToolTip()\Window\Num
        StopTimerThread()
      EndIf  
      
    Next
    
  EndProcedure
  
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================

	Procedure.i Gadget(Gadget.i, Window.i, Flags.i=#False)
		Define DummyNum, GNum.i

		GNum = CanvasGadget(#PB_Any, 10, 10, 200, 100)
		If GNum
		  
			If AddMapElement(ToolTip(), Str(Gadget))

				ToolTip()\CanvasNum  = GNum
				ToolTip()\GadgetNum  = Gadget
				ToolTip()\Window\Num = Window
				
				ToolTip()\Type = #Gadget
				
				CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						ToolTip()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							ToolTip()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						ToolTip()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}
				
				ToolTip()\Content\TitleFont = #PB_Default
				ToolTip()\Content\TextFont  = #PB_Default
				
				ToolTip()\Area\X = #PB_Default
				ToolTip()\Area\Y = #PB_Default
				ToolTip()\Area\Width  = #PB_Default
				ToolTip()\Area\Height = #PB_Default
				
				ToolTip()\PaddingX = dpiX(5)
				ToolTip()\PaddingY = dpiY(5)
				ToolTip()\Spacing  = 0
				
				ToolTip()\Flags   = Flags

				ToolTip()\Color\Front       = $000000
				ToolTip()\Color\Back        = $F0FFFF
				ToolTip()\Color\Border      = $B4B4B4
				ToolTip()\Color\TitleFront  = $000000
				ToolTip()\Color\TitleBack   = #PB_Default
				ToolTip()\Color\TitleBorder = #PB_Default
				
				If IsGadget(ToolTip()\GadgetNum)
				  BindGadgetEvent(ToolTip()\GadgetNum, @_MouseEnterHandler(), #PB_EventType_MouseEnter)
				  BindGadgetEvent(ToolTip()\GadgetNum, @_MouseLeaveHandler(), #PB_EventType_MouseLeave)
				  BindGadgetEvent(ToolTip()\GadgetNum, @_MouseMoveHandler(),  #PB_EventType_MouseMove)
				EndIf
				
				BindEvent(#Event_ToolTip, @_ToolTipHandler())
				
				If IsWindow(ToolTip()\Window\Num)
          ToolTip()\Window\Width  = WindowWidth(ToolTip()\Window\Num)
          ToolTip()\Window\Height = WindowHeight(ToolTip()\Window\Num)
          BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), ToolTip()\Window\Num)
        EndIf
        
        If AddMapElement(Timer(), Str(Gadget))
          Timer()\Delay = 500
          Timer()\GadgetNum = ToolTip()\GadgetNum
          Timer()\WindowNum = ToolTip()\Window\Num
        EndIf
      
        StartTimerThread()
        
				HideGadget(ToolTip()\CanvasNum, #True)

				ProcedureReturn GNum
			EndIf

		EndIf

	EndProcedure
	
	Procedure   SetAttribute(GNum.i, Attribute.i, Value.i) 
    
    If FindMapElement(ToolTip(), Str(GNum))
      
      Select Attribute
        Case #PaddingX
          ToolTip()\PaddingX = dpiX(Value)
        Case #PaddingY  
          ToolTip()\PaddingY = dpiY(Value)
        Case #Spacing  
          ToolTip()\Spacing  = dpiY(Value)
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure 
	
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(ToolTip(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          ToolTip()\Color\Front  = Value
        Case #BackColor
          ToolTip()\Color\Back   = Value
        Case #BorderColor
          ToolTip()\Color\Border = Value
        Case #TitleColor
          ToolTip()\Color\TitleFront  = Value
	      Case #TitleBackColor  
	        ToolTip()\Color\TitleBack   = Value
	      Case #TitleBorderColor
	        ToolTip()\Color\TitleBorder = Value
      EndSelect

    EndIf
    
  EndProcedure
  
  Procedure   SetContent(GNum.i, Text.s, Title.s="", X.i=#PB_Default, Y.i=#PB_Default, Width.i=#PB_Default, Height.i=#PB_Default)
    Define.i r, Rows
    
    If FindMapElement(ToolTip(), Str(GNum))

      ToolTip()\Content\Title = Title
      
      Rows = CountString(Text, #LF$) + 1
      
      ClearList(ToolTip()\Content\Text())
      For r=1 To Rows
        If AddElement(ToolTip()\Content\Text())
          ToolTip()\Content\Text() = RTrim(StringField(Text, r, #LF$), #CR$)
        EndIf
      Next
      
      ToolTip()\Area\X = X
      ToolTip()\Area\Y = Y
      ToolTip()\Area\Width  = Width
      ToolTip()\Area\Height = Height
      
      DetermineSize_()
      
      ToolTip()\State = #True
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontNum.i, FontType.i=#Text) 
    
    If FindMapElement(ToolTip(), Str(GNum))
      
      Select FontType
        Case #Title
          ToolTip()\Content\TitleFont = FontNum
        Case #Text
          ToolTip()\Content\TextFont  = FontNum
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetImage(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Flags.i=#False)
    
    If FindMapElement(ToolTip(), Str(GNum))
      
      If IsImage(ImageNum)
        
        If Width  = #PB_Default : Width  = ImageWidth(ImageNum)  : EndIf 
        If Height = #PB_Default : Height = ImageHeight(ImageNum) : EndIf
         
        ToolTip()\Image\Num    = ImageNum
        ToolTip()\Image\Width  = Width
        ToolTip()\Image\Height = Height
        ToolTip()\Image\Flags  = Flags
      EndIf
    
    EndIf  
      
  EndProcedure
  
  Procedure   SetState(GNum.i, State.i)
    
    If FindMapElement(ToolTip(), Str(GNum))
      ToolTip()\State = State
    EndIf
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  Enumeration 
    #Window
    #Gadget
    #Font
    #Image
  EndEnumeration
  
  LoadFont(#Font, "Arial", 9, #PB_Font_Bold)
  ;LoadImage(#Image, "Paper.png")
  
  
  If OpenWindow(#Window, 0, 0, 200, 100, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CanvasGadget(#Gadget, 10, 10, 180, 80, #PB_Canvas_Border)
      If StartDrawing(CanvasOutput(#Gadget))
        DrawingMode(#PB_2DDrawing_Outlined)
			  Box(80, 30, 20, 20, $800080)
        StopDrawing()
      EndIf  
    EndIf
    
    If ToolTip::Gadget(#Gadget, #Window)
      ;ToolTip::SetContent(#Gadget, "This is a tooltip.", "Title")
      ToolTip::SetContent(#Gadget, "Tooltip area.", "Title", 80, 30, 20, 20)
      ToolTip::SetFont(#Gadget, #Font, ToolTip::#Title) 
      ToolTip::SetColor(#Gadget, ToolTip::#BorderColor,      $800000)
      ToolTip::SetColor(#Gadget, ToolTip::#BackColor,        $FFFFFA)
      ToolTip::SetColor(#Gadget, ToolTip::#TitleBorderColor, $800000)
      ToolTip::SetColor(#Gadget, ToolTip::#TitleBackColor,   $B48246)
      ToolTip::SetColor(#Gadget, ToolTip::#TitleColor,       $FFFFFF)
      ;ToolTip::SetImage(#Gadget, #Image)
    EndIf

    Repeat
      Event = WaitWindowEvent()    
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf
; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 806
; FirstLine = 196
; Folding = WAAUAAg-
; EnableXP
; DPIAware