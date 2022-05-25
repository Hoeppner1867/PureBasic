;/ ============================
;/ =    BarcodeModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x - V6x / 64Bit / All OS / DPI ]
;/
;/ Based on the code of TI-994A (2017)
;/ 
;/ © 2022  by Thorsten Hoeppner (05/2022)
;/

; Last Update: 


;{ ===== MIT License =====
;
; Copyright (c) 2017 TI-994A
; Copyright (c) 2022 Thorsten Hoeppner
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


;{ _____ BarCode - Commands _____

; BarCode::Gadget()             - similar to 'BarCodeGadget()'

; BarCode::GetText()            - similar to 'GetGadgetText()'
; BarCode::GetColor()           - similar to 'GetGadgetColor()'

; BarCode::Hide()               - similar to 'HideGadget()'

; BarCode::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; BarCode::SetColor()           - similar to 'SetGadgetColor()'
; BarCode::SetText()            - similar to 'SetGadgetText()'
;}


DeclareModule BarCode
  
  EnumerationBinary ;{ Flags
    #Code_39
    #UPC_A
    #Label
    #AutoResize
    #MoveX
		#MoveY
		#Width
		#Height
  EndEnumeration ;}
  
  Enumeration 1     ;{ Color
    #FrontColor
    #BackColor
    #TextColor
  EndEnumeration ;}
  
  
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  
  Declare.s GetText(GNum.i)
  Declare.i GetColor(GNum.i, ColorTyp.i)
  
  Declare   Hide(GNum.i, State.i=#True)
  
  Declare   SetText(GNum.i, Text.s, Flags.i=#Code_39)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  
EndDeclareModule

Module BarCode
  
  EnableExplicit
  
  ;- =================================================
	;-   Module - Structures & Global
	;- =================================================
  
  Structure Barcode_Color_Structure  ;{ Barcode()\Color\...
		Front.i
		Back.i
		Text.i
		Gadget.i
	EndStructure  ;}
  
  Structure Barcode_Size_Structure   ;{ Barcode()\Size\...
		X.f
		Y.f
		Width.f
		Height.f
		Flags.i
	EndStructure ;}
	
  Structure Barcode_Structure        ;{ Barcode()\...
    
    Window.i
    Gadget.i
	  
	  Text.s
	  Font.i
	  Hide.i
	  Flags.i
	  
	  WinWidth.i
	  WinHeight.i
	  
	  Color.Barcode_Color_Structure
	  Size.Barcode_Size_Structure
	  
	  LBin.s[10]
	  RBin.s[10]
	  Map BinDec.i()
	EndStructure ;}
	Global NewMap BarCode.Barcode_Structure() 
	
	
	;- =================================================
	;-   Module - Internal
	;- =================================================
	
	
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
	
	
	Procedure.i IsValidUPC_A(Text.s)
	  Define.i c, Char

	  For c = 1 To Len(Text)
	    
	    Char = Asc(Mid(Text, c, 1))
	    
	    Select Char
	      Case 48 To 57 ; 0 - 9
	        Continue
	      Default
	        ProcedureReturn #False
	    EndSelect
	    
	  Next
	  
    ProcedureReturn #True
	EndProcedure

	Procedure.i IsValidCode_39(Text.s)
	  Define.i c, Char

	  For c = 1 To Len(Text)
	    
	    Char = Asc(Mid(Text, c, 1))
	    
	    Select Char
	      Case 32, 36, 37, 42, 43, 45, 46, 47 ; Space $  % * + - . /
	        Continue
	      Case 48 To 57, 65 To 90             ; 0 - 9 / A - Z
	        Continue
	      Default
	        ProcedureReturn #False
	    EndSelect
	    
	  Next
	  
    ProcedureReturn #True
	EndProcedure
	
	
	Procedure   LoadData()
	  Define.i d, ASC, BIN
	  Define.s ASC$
	  
	  ; Code-39
	  Restore ascBinData
	  
	  For d=0 To 43
	    
      Read ASC
      Read BIN
      
      ASC$ = Chr(ASC)
      
      BarCode()\BinDec(ASC$) = AllocateMemory(32) 
      PokeL(BarCode()\BinDec(ASC$), BIN)
      
    Next
    
    BarCode()\LBin[0] = "0001101"
    BarCode()\LBin[1] = "0011001"
    BarCode()\LBin[2] = "0010011"
    BarCode()\LBin[3] = "0111101"
    BarCode()\LBin[4] = "0100011"
    BarCode()\LBin[5] = "0110001"
    BarCode()\LBin[6] = "0101111"
    BarCode()\LBin[7] = "0111011"
    BarCode()\LBin[8] = "0110111"
    BarCode()\LBin[9] = "0001011"

    BarCode()\RBin[0] = "1110010"
    BarCode()\RBin[1] = "1100110"
    BarCode()\RBin[2] = "1101100"
    BarCode()\RBin[3] = "1000010"
    BarCode()\RBin[4] = "1011100"
    BarCode()\RBin[5] = "1001110"
    BarCode()\RBin[6] = "1010000"
    BarCode()\RBin[7] = "1000100"
    BarCode()\RBin[8] = "1001000"
    BarCode()\RBin[9] = "1110100"

	EndProcedure
	
	Procedure.s UPC_A()
	  Define.s Text, LDigits, RDigits, Modulo, BarCode
	  Define.i Mod1, Mod2, ChkSum, i
	  
    Text = BarCode()\Text
    Text = RSet(Text, 11, "0")
    
    LDigits = Left(Text,  6)
    RDigits = Right(Text, 5)
    Modulo  = LDigits + RDigits
    
    For i=1 To Len(Modulo) Step 2
      Mod1 + Val(Mid(Modulo, i, 1))
    Next
    
    For i=2 To Len(Modulo) Step 2
      Mod2 + Val(Mid(Modulo, i, 1))
    Next
    
    ChkSum = (Mod1 * 3) + Mod2
    If Mod(ChkSum, 10)
      ChkSum = 10 - (Mod(ChkSum, 10))
    Else
      ChkSum = 0
    EndIf 
    
    Text + Str(ChkSum)
    
    BarCode = "101"
    
    For i = 1 To Len(LDigits)
      BarCode + BarCode()\LBin[Val(Mid(LDigits, i, 1))]
    Next
    
    BarCode + "01010"
    
    For i = 1 To Len(RDigits)
      BarCode + BarCode()\RBin[Val(Mid(RDigits, i, 1))]
    Next
    
    BarCode + BarCode()\RBin[ChkSum]
    BarCode + "101"
    
	  ProcedureReturn BarCode 
	EndProcedure
	
	;- =================================================
	;-   Module - Drawing
	;- =================================================
	
	Procedure Draw_()
	  Define.i X, Y, Width, Height, OffsetX, OffsetY, c, i
	  Define.i charWidth, rawWidth, bcHeight, dpiWidth, dpiHeight
	  Define.i MF, IsValid, txtLen, Unit, Color
	  Define   *TB.byte
	  Define.s Text, Char, BarCode, Label = ""
	  
	  If BarCode()\Hide : ProcedureReturn #False : EndIf
	  
	  X      = 10
	  Y      = 10
	  Width  = GadgetWidth(BarCode()\Gadget)
	  Height = GadgetHeight(BarCode()\Gadget)

	  If StartDrawing(CanvasOutput(BarCode()\Gadget))
	    
	    Box(0, 0, dpiX(Width), dpiY(Height), #White)
	    
	    bcHeight = Height - 20
	    
	    If BarCode()\Flags & #UPC_A    ;{ UPC-A Barcode
	      
	      IsValid = IsValidUPC_A(BarCode()\Text)
	      
	      If IsValid = #False
  	      DrawText(dpiX(10), dpiY(10), "> INVALID CHARACTER IN BARCODE <", #White, #Red)
  	      StopDrawing()
  	      ProcedureReturn #False
  	    EndIf
	      
	      Text    = BarCode()\Text
	      BarCode = UPC_A()
        
        Unit = 2
        
        rawWidth = Len(BarCode) * Unit 
        OffsetX  = (Width - rawWidth) / 2
    	  
    	  If OffsetX > X : X = OffsetX : EndIf
        
        For i = 1 To Len(BarCode)
          
          If Mid(BarCode, i, 1) = "0"
            Color = #White
          ElseIf Mid(BarCode, i, 1) = "1"
            Color = BarCode()\Color\Front
          EndIf  
          
          Box(dpiX(Unit * (i - 1) + X), Y, Unit, bcHeight, Color)
          
        Next
	      ;}
	    EndIf
	    
  	  If BarCode()\Flags & #Code_39  ;{ Code-39 Barcode
  	    
  	    IsValid = IsValidCode_39(BarCode()\Text)
  	    
  	    If IsValid = #False
  	      DrawText(dpiX(10), dpiY(10), "> INVALID CHARACTER IN BARCODE <", #White, #Red)
  	      StopDrawing()
  	      ProcedureReturn #False
  	    EndIf  
  	    
  	    Text = "*" + BarCode()\Text + "*"
  	    
    	  charWidth = 19
    	  txtLen    = Len(BarCode()\Text) + 1
    	  rawWidth  = (txtLen * charWidth) + 18
    	  OffsetX   = (Width - rawWidth) / 2
    	  
    	  If OffsetX > X : X = OffsetX : EndIf

  	    For c=0 To txtLen
  	      Char = Mid(Text, c+1, 1)
          For i = 0 To 18
            MF = (i % 8)
            *TB = BarCode()\binDec(Char) + (i >> 3)
            If (*TB\b & (1 << MF)) >> MF
              Line(dpiX(c * charWidth + i + X), dpiY(Y), dpiX(1), dpiY(bcHeight), BarCode()\Color\Front)
            EndIf
          Next
        Next
        ;}
      EndIf
      
      If BarCode()\Flags & #Label    ;{ Label
        
        For c = 1 To Len(Text)
          Label + Mid(Text, c, 1) + " "
        Next
        
        Text = "  " + Label + " "
        
        DrawingFont(FontID(BarCode()\Font))
        
        dpiWidth  = TextWidth(Text)
        dpiHeight = TextHeight(Text)
        
        OffsetX = (dpiX(rawWidth) - dpiWidth) / 2
        
        DrawText(dpiX(X) + OffsetX , dpiY(Y + bcHeight) - dpiHeight, Text, BarCode()\Color\Text, BarCode()\Color\Back)
        ;}
      EndIf
      
      
  	  StopDrawing()
  	EndIf
  	
	EndProcedure  
	
	
	;- =================================================
	;-   Module - Events
	;- =================================================
	
	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(BarCode(), Str(GadgetID))
		  Draw_()
		EndIf

	EndProcedure
	
	Procedure _ResizeWindowHandler()
		Define.f X, Y, Width, Height
		Define.f OffSetX, OffSetY

		ForEach BarCode()

			If IsGadget(BarCode()\Gadget)

				If BarCode()\Flags & #AutoResize

					If IsWindow(BarCode()\Window)

						OffSetX = WindowWidth(BarCode()\Window)  - BarCode()\WinWidth
						OffsetY = WindowHeight(BarCode()\Window) - BarCode()\WinHeight

						If BarCode()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If BarCode()\Size\Flags & #MoveX  : X = BarCode()\Size\X + OffSetX : EndIf
							If BarCode()\Size\Flags & #MoveY  : Y = BarCode()\Size\Y + OffSetY : EndIf
							If BarCode()\Size\Flags & #Width  : Width  = BarCode()\Size\Width  + OffSetX : EndIf
							If BarCode()\Size\Flags & #Height : Height = BarCode()\Size\Height + OffSetY : EndIf

							ResizeGadget(BarCode()\Gadget, X, Y, Width, Height)

						Else
							ResizeGadget(BarCode()\Gadget, #PB_Ignore, #PB_Ignore, BarCode()\Size\Width + OffSetX, BarCode()\Size\Height + OffsetY)
						EndIf

						Draw_()
					EndIf

				EndIf

			EndIf

		Next

	EndProcedure
	
	Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach BarCode()
     
      If BarCode()\Window = Window
        DeleteMapElement(BarCode())
      EndIf
      
    Next
    
  EndProcedure
  
  
  ;- =================================================
	;-   Module - Declared Procedures
	;- =================================================
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i c, Result
    
    Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Container)
    If Result

      If GNum = #PB_Any : GNum = Result : EndIf
      
      If AddMapElement(BarCode(), Str(GNum))
        
        BarCode()\Gadget = GNum
        
        If WindowNum = #PB_Default
          BarCode()\Window = GetGadgetWindow()
        Else
          BarCode()\Window = WindowNum
        EndIf
        
        If Flags & #AutoResize
          If IsWindow(BarCode()\Window)
            BarCode()\WinWidth  = WindowWidth(BarCode()\Window)
            BarCode()\WinHeight = WindowHeight(BarCode()\Window)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), BarCode()\Window)
          EndIf   
        EndIf 
        
        BarCode()\Flags  = Flags
        
        BarCode()\Size\X      = X
        BarCode()\Size\Y      = Y
        BarCode()\Size\Width  = Width
        BarCode()\Size\Height = Height

        BarCode()\Font = LoadFont(#PB_Any, "Arial", 10)
        
        ;{ Color
        BarCode()\Color\Front         = $000000
        BarCode()\Color\Text          = $000000
				BarCode()\Color\Back          = $FFFFFF
				BarCode()\Color\Gadget        = $F0F0F0
        
        CompilerSelect #PB_Compiler_OS 
					CompilerCase #PB_OS_Windows
						BarCode()\Color\Front     = GetSysColor_(#COLOR_WINDOWTEXT)
						BarCode()\Color\Back      = GetSysColor_(#COLOR_WINDOW)
						BarCode()\Color\Text      = GetSysColor_(#COLOR_WINDOWTEXT) 
						BarCode()\Color\Gadget    = GetSysColor_(#COLOR_MENU)
					CompilerCase #PB_OS_MacOS
						BarCode()\Color\Front     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						BarCode()\Color\Back      = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
						BarCode()\Color\Text      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
						BarCode()\Color\Gadget    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
					CompilerCase #PB_OS_Linux

				CompilerEndSelect ;}
				
				BindGadgetEvent(BarCode()\Gadget,  @_ResizeHandler(), #PB_EventType_Resize)
				
				BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), BarCode()\Window)
				
				LoadData()
				
				ProcedureReturn BarCode()\Gadget
      EndIf
      
		EndIf
		
  EndProcedure  
  
  
  Procedure.s GetText(GNum.i)
    
    If FindMapElement(BarCode(), Str(GNum))
      ProcedureReturn BarCode()\Text
    EndIf  
    
  EndProcedure  
  
  Procedure.i GetColor(GNum.i, ColorTyp.i)
    
    If FindMapElement(BarCode(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          ProcedureReturn BarCode()\Color\Front
        Case #BackColor
          ProcedureReturn BarCode()\Color\Back
        Case #TextColor
          ProcedureReturn BarCode()\Color\Text
      EndSelect

    EndIf
    
  EndProcedure
  
  
  Procedure   SetText(GNum.i, Text.s, Flags.i=#Code_39)
    
    If FindMapElement(BarCode(), Str(GNum))
      
      BarCode()\Text = UCase(Text)
      
      If Flags & #Code_39
        BarCode()\Flags | #Code_39
        BarCode()\Flags & ~#UPC_A
      ElseIf Flags & #UPC_A
        BarCode()\Flags | #UPC_A
        BarCode()\Flags & ~#Code_39
      EndIf   
      
      Draw_()
      
    EndIf  
    
  EndProcedure  
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(BarCode(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor
          BarCode()\Color\Front  = Value
        Case #BackColor
          BarCode()\Color\Back   = Value
        Case #TextColor
          BarCode()\Color\Text   = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(BarCode(), Str(GNum))
      BarCode()\Size\Flags = Flags
    EndIf  
   
  EndProcedure
  
  
  Procedure   Hide(GNum.i, State.i=#True)
	  
	  If FindMapElement(BarCode(), Str(GNum))
	    
	    If State
	      BarCode()\Hide = #True
	      HideGadget(GNum, #True)
	    Else
	      BarCode()\Hide = #False
	      HideGadget(GNum, #False)
	      Draw_()
	    EndIf  
	    
	  EndIf  
	  
	EndProcedure
  
  
  ;- =================================================
	;-   Module - DataSection
	;- =================================================
  
  ;the data block is included within the procedure for portability - can be positioned anywhere in the code
  DataSection 
  ascBinData:
    Data.i 65, 250031, 66, 250045, 67, 181743, 68, 250341, 69, 182191, 70, 182205, 71, 252965, 72, 159919
    Data.i 73, 159933, 74, 192997, 75, 246959, 76, 246973, 77, 136687, 78, 247269, 79, 137135, 80, 137149
    Data.i 81, 247717, 82, 138415, 83, 138429, 84, 138725, 85, 251023, 86, 251361, 87, 186255, 88, 251809
    Data.i 89, 155279, 90, 188385, 48, 194437, 49, 250927, 50, 250941, 51, 184815, 52, 251781, 53, 187951
    Data.i 54, 187965, 55, 253061, 56, 193583, 57, 193597, 32, 194017, 36, 181281, 37, 135301, 42, 194465
    Data.i 43, 135329, 45, 253089, 46, 160911, 47, 136225
  EndDataSection  
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 1
    #Window
    #Gadget
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 400, 100, "Barcode - Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    BarCode::Gadget(#Gadget, 10, 10, 380, 80, BarCode::#Label|BarCode::#AutoResize)
    BarCode::SetText(#Gadget, "Code-39 Barcode", BarCode::#Code_39)
    ;BarCode::SetText(#Gadget, "12234567899", BarCode::#UPC_A)
    BarCode::SetColor(#Gadget, BarCode::#TextColor, $800000)
  EndIf   
  
  Repeat
    Event = WaitWindowEvent()
  Until Event = #PB_Event_CloseWindow
  
CompilerEndIf  
; IDE Options = PureBasic 6.00 Beta 7 (Windows - x64)
; CursorPosition = 44
; Folding = iBOAAA9
; EnableXP