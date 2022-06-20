;/ ============================
;/ =   TileButtonModule.pbi   =
;/ ============================
;/
;/ [ PB V5.7x - V6.0 / 64Bit / all OS / DPI ]
;/
;/ © 2022 Thorsten1867 (05/2022)
;/
;
; Last Update: 18.06.2022
;
; - Bugfix: Disable()
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

;{ ===== Additional tea & pizza license =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ TileBt - Commands _____

; Tiles::AddImage()           - adds an image to the button
; Tiles::CombineToggle()      - combine a group of toggle buttons
; Tiles::Disable()            - similar to 'DisableGadget()'
; Tiles::Free()               - similar to 'FreeGadget()'
; Tiles::Gadget()             - similar to 'ButtonGadget()'
; Tiles::GetData()            - similar to 'GetGadgetData()'
; Tiles::GetID()              - similar to 'GetGadgetData()', but string
; Tiles::GetState()           - similar to 'GetGadgetState()'
; Tiles::GetText()            - similar to 'GetGadgetText()'
; Tiles::SaveColorTheme()     - saves a custom color theme
; Tiles::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; Tiles::SetAttribute()       - similar to 'SetGadgetAttribute()'
; Tiles::SetColor()           - similar to 'SetGadgetColor()'
; Tiles::SetColorTheme()      - sets a colour theme
; Tiles::SetData()            - similar to 'SetGadgetData()'
; Tiles::SetFont()            - similar to 'SetGadgetFont()'
; Tiles::SetID()              - similar to 'SetGadgetData()', but string
; Tiles::SetState()           - similar to 'SetGadgetState()'
; Tiles::SetText()            - similar to 'SetGadgetText()'
; Tiles::Hide()               - similar to 'HideGadget()'

;}

;XIncludeFile "ModuleEx.pbi"

DeclareModule Tiles
  
  #Version  = 22061800
  #ModuleEx = 22052900
  
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
		#Top
		#Bottom
		#Image
		#Font
		#Color
		#MacOS
		#Border
		#UseArrow
		#UseSwitch
		#ToggleBar
		#AutoResize
		#FitText
		#FixPadding
		#UseExistingCanvas
	EndEnumeration ;}
	
	Enumeration       ;{ Attribute
	  #Title    ; = 0
	  #Description
	  #PaddingX
	  #PaddingY
	  #ImageSpacing
	  #ToggleWidth
	  #ToggleHeight
	  #ToggleAlign
	  #Switch
	  #Corner
	EndEnumeration ;}
	
	Enumeration 1     ;{ Colors
		#FrontColor
		#BackColor
		#BorderColor
		#FocusColor
		#ToggleColor
	EndEnumeration ;}
	
	EnumerationBinary ;{ AutoResize
		#MoveX
		#MoveY
		#Width
		#Height
	EndEnumeration ;}
	
	#Theme = -1
	Enumeration       ;{ Themes
    #Theme_Default
    #Theme_Custom
    #Theme_Win11
    #Theme_Menue
    #Theme_Blue  
    #Theme_Green
    #Theme_Orange
    #Theme_Red
    #Theme_Pink
  EndEnumeration ;}
  
	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  #Event_Gadget     = ModuleEx::#Event_Gadget
	  #Event_Theme      = ModuleEx::#Event_Theme
	  
		#EventType_Button = ModuleEx::#EventType_Button
		#EventType_Switch = ModuleEx::#EventType_Switch

	CompilerElse

		Enumeration #PB_Event_FirstCustomValue
			#Event_Gadget
		EndEnumeration

		Enumeration #PB_EventType_FirstCustomValue
			#EventType_Button
			#EventType_Switch
		EndEnumeration

	CompilerEndIf
	;}
	
	
	;- ===========================================================================
	;- DeclareModule
	;- ===========================================================================

	Declare   AddImage(GNum.i, ImageNum.i, Flags.i=#False, Width.i=#PB_Default, Height.i=#PB_Default)
	Declare.i CombineToggle(GNum.i, Group.s, State.i=#True)
	Declare   Disable(GNum.i, State.i=#True)
	Declare   Free(GNum.i)
	Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i=#False, WindowNum.i=#PB_Default)
	Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
	Declare.i GetState(GNum.i, Flag.i=#False)
	Declare.s GetText(GNum.i, Flag.i=#Title)
	Declare   Hide(GNum.i, State.i=#True)
	Declare   SaveColorTheme(GNum.i, File.s)
	Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
	Declare   SetAutoResizeFlags(GNum.i, Flags.i)
	Declare   SetColor(GNum.i, ColorType.i, Color.i, Flag.i=#Title)
	Declare   SetColorTheme(GNum.i, Theme.i=#Theme_Default, File.s="")
	Declare   SaveColorTheme(GNum.i, File.s)
	Declare   SetFont(GNum.i, FontNum.i, Flag.i=#Title)
	Declare   SetData(GNum.i, Value.q)
	Declare   SetID(GNum.i, String.s)
	Declare   SetState(GNum.i, State.i, Flag.i=#False)
	Declare   SetText(GNum.i, Text.s, Flag.i=#Title)

	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Declare.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  Declare.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	  Declare.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  
	CompilerEndIf
	
EndDeclareModule

Module Tiles
  
  EnableExplicit
  
	;- ===========================================================================
	;- Module - Constants
	;- ===========================================================================
	
	EnumerationBinary
		#Focus
		#Click
	EndEnumeration
	
	#ArrowWidth  = 5
	#ArrowHeight = 9
	
	;- ============================================================================
	;- Module - Structures
	;- ============================================================================
	
	Structure Toogle_Group_Structure
	  List GadgetNum.i()
	EndStructure  
	Global NewMap Group.Toogle_Group_Structure()
	
	Structure TileBt_Switch_Structure   ;{ TileBt()\Switch\...
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  FontID.i
	  Color.i
	  State.i  ; #Focus / #Click
	  Status.i ; on/off
	  On.s
	  Off.s
	EndStructure ;}
	
	Structure TileBt_Image_Structure   ;{ TileBt()\Image\...
		Num.i
		Width.i
		Height.i
		Spacing.i
		Flags.i
	EndStructure ;}

	Structure TileBt_Color_Structure   ;{ TileBt()\Color\...
		Front.i
		Back.i
		Focus.i
		FocusBorder.i
		ToggleBar.i
		Border.i
		Gadget.i
		DisableFront.i
    DisableBack.i
	EndStructure ;}

	Structure TileBt_Size_Structure    ;{ TileBt()\Size\...
		X.f
		Y.f
		Width.i
		Height.i
		Flags.i
	EndStructure ;}

	Structure TileBt_Window_Structure  ;{ TileBt()\Window\...
		Num.i
		Width.i
		Height.i
	EndStructure ;}
	
	Structure TileBt_Font_Structure    ;{ TileBt()\Font\...
	  Num.i
	  Name.s
	  Size.i
	  Style.i
	EndStructure ;}
	
	Structure TileBt_Text_Structure    ;{ TileBt()\Title\...
	  Text.s
	  FontID.i
	  Color.i
	  Width.i
	  Height.i
	EndStructure ;}
	
	Structure TileBt_Focus_Structure   ;{ TileBt()\Focus\...
	  Width.i
	  Height.i
	  Align.i
	EndStructure ;}
	
	Structure TileBt_Structure         ;{ TileBt()\...
	  ID.s
	  Quad.q
	  
	  CanvasNum.i
		PopupNum.i
		
		FontID.i
		
		Title.TileBt_Text_Structure
		Description.TileBt_Text_Structure
		
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
    
    Switch.TileBt_Switch_Structure
    ToggleBar.TileBt_Focus_Structure
    Font.TileBt_Font_Structure
		Color.TileBt_Color_Structure
		Image.TileBt_Image_Structure
		Size.TileBt_Size_Structure
		Window.TileBt_Window_Structure

	EndStructure ;}
	Global NewMap TileBt.TileBt_Structure()
	
	;- ============================================================================
	;- Module - Internal
	;- ============================================================================

	Declare.i BlendColor_(Color1.i, Color2.i, Factor.i=50) 
	
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
		
		Procedure OSX_NSColorByNameToRGB(NSColorName.s)
      Protected.cgfloat red, green, blue
      Protected nscolorspace, rgb
      nscolorspace = CocoaMessage(0, CocoaMessage(0, 0, "NSColor " + NSColorName), "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
      If nscolorspace
        CocoaMessage(@red, nscolorspace, "redComponent")
        CocoaMessage(@green, nscolorspace, "greenComponent")
        CocoaMessage(@blue, nscolorspace, "blueComponent")
        rgb = RGB(red * 255.0, green * 255.0, blue * 255.0)
        ProcedureReturn rgb
      EndIf
    EndProcedure
		
		Procedure OSX_GadgetColor()
		  Define.i UserDefaults, NSString
		  
		  UserDefaults = CocoaMessage(0, 0, "NSUserDefaults standardUserDefaults")
      NSString = CocoaMessage(0, UserDefaults, "stringForKey:$", @"AppleInterfaceStyle")
      If NSString And PeekS(CocoaMessage(0, NSString, "UTF8String"), -1, #PB_UTF8) = "Dark"
        ProcedureReturn BlendColor_(OSX_NSColorByNameToRGB("controlBackgroundColor"), #White, 85)
      Else
        ProcedureReturn BlendColor_(OSX_NSColorByNameToRGB("windowBackgroundColor"), #White, 85)
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
	
	Procedure TextHeight_(Text.s)
	  ProcedureReturn DesktopUnscaledY(TextHeight(Text))
	EndProcedure
	
	Procedure TextWidth_(Text.s)
	  ProcedureReturn DesktopUnscaledX(TextWidth(Text))
	EndProcedure  
	
	Procedure DrawText_(X.i, Y.i, Text.s, FrontColor.i=#PB_Default, BackColor.i=#PB_Default)
	  Define.i PosX
	  
	  If FrontColor = #PB_Default
	    PosX = DrawText(dpiX(X), dpiY(Y), Text)
	    ProcedureReturn DesktopUnscaledX(PosX)
	  ElseIf BackColor = #PB_Default
	    PosX = DrawText(dpiX(X), dpiY(Y), Text, FrontColor)
	    ProcedureReturn DesktopUnscaledX(PosX)
	  Else
	    PosX = DrawText(dpiX(X), dpiY(Y), Text, FrontColor, BackColor)
	    ProcedureReturn DesktopUnscaledX(PosX)
	  EndIf 
	  
	EndProcedure  
	
	Procedure Box_(X.i, Y.i, Width.i, Height.i, Color.i, Rounded.i=#False)
		If Rounded
			RoundBox(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), dpiX(Rounded), dpiY(Rounded), Color)
		Else
			Box(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), Color)
		EndIf
	EndProcedure
	
	Procedure LineXY_(x1.i, y1.i, x2.i, y2.i, Color.i=#PB_Default)
	  If Color.i=#PB_Default
	    LineXY(dpiX(x1), dpiY(y1), dpiX(x2), dpiY(y2))
	  Else
	    LineXY(dpiX(x1), dpiY(y1), dpiX(x2), dpiY(y2), Color)
	  EndIf   
	EndProcedure
	
	Procedure Line_(X.i, Y.i, Width.i, Height.i, Color.i=#PB_Default)
	  If Color = #PB_Default
	    Line(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height))
	  Else  
	    Line(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height), Color)
	  EndIf   
	EndProcedure  
	
	Procedure DrawImage_(ImageID.i, X.i, Y.i, Width.i=#PB_Default, Height.i=#PB_Default)
	  If Width = #PB_Default And Height = #PB_Default
	    DrawImage(ImageID, dpiX(X), dpiY(Y))
	  Else
	    DrawImage(ImageID, dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height))
	  EndIf  
	EndProcedure  
	
	Procedure FillArea_(X.i, Y.i, OutlineColor.i, FillColor.i=#PB_Default)
	  FillArea(dpiX(X), dpiY(Y), OutlineColor, FillColor)
	EndProcedure  
	
	Procedure ClipOutput_(X, Y, Width, Height)
    ClipOutput(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height)) 
  EndProcedure
  
  Procedure UnclipOutput_()
    UnclipOutput() 
  EndProcedure
  
	;- ============================================================================
	;- Module - Drawing
	;- ============================================================================
  
	Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
		Define.i R1, G1, B1, R2, G2, B2
		Define.f Blend = Scale / 100

		R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
		R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)

		ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
	EndProcedure
  
  Procedure   ColorTheme_(Theme.i)

    TileBt()\Color\Front        = $000000
		TileBt()\Color\Back         = $E3E3E3
		TileBt()\Color\Focus        = $D77800
		TileBt()\Color\FocusBorder  = $A0A0A0
		TileBt()\Color\ToggleBar     = $3399FF
		TileBt()\Color\Border       = $A0A0A0
		TileBt()\Color\Gadget       = $F3F3F3
		TileBt()\Color\DisableFront = $72727D
		TileBt()\Color\DisableBack  = $CCCCCA
		
		
    CompilerSelect  #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        TileBt()\Color\Front       = GetSysColor_(#COLOR_BTNTEXT)
				TileBt()\Color\Back        = GetSysColor_(#COLOR_3DLIGHT)
				TileBt()\Color\Focus       = GetSysColor_(#COLOR_BTNHIGHLIGHT)
				TileBt()\Color\Border      = GetSysColor_(#COLOR_ACTIVEBORDER)
				TileBt()\Color\FocusBorder = GetSysColor_(#COLOR_ACTIVEBORDER)
				TileBt()\Color\ToggleBar   = GetSysColor_(#COLOR_MENUHILIGHT)
				TileBt()\Color\Gadget      = GetSysColor_(#COLOR_MENU)
      CompilerCase #PB_OS_MacOS
        TileBt()\Color\Front       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
				TileBt()\Color\Back        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
				TileBt()\Color\Focus       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
				TileBt()\Color\FocusBorder = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				TileBt()\Color\Border      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
				TileBt()\Color\Gadget      = OSX_GadgetColor()
      CompilerCase #PB_OS_Linux
      
    CompilerEndSelect
    
    TileBt()\Title\Color       = TileBt()\Color\Front
    TileBt()\Description\Color = TileBt()\Color\Front
    TileBt()\Switch\Color      = TileBt()\Color\Front
    
    Select Theme
      Case #Theme_Blue
        TileBt()\Color\Front       = $FFFFFF
        TileBt()\Title\Color       = $FFFFFF
        TileBt()\Description\Color = $FFFFFF
        TileBt()\Color\Back        = $FF901E
        TileBt()\Color\Border      = BlendColor_($000000, $FF901E, 30)
        TileBt()\Color\Focus       = $F2810E
        TileBt()\Color\FocusBorder = BlendColor_($000000, $F2810E, 30)
        TileBt()\Color\ToggleBar   = BlendColor_($FFFFFF, $FF901E, 50)
        TileBt()\Switch\Color      = $FFFFFF
      Case #Theme_Green
        TileBt()\Color\Front       = $FFFFFF
        TileBt()\Title\Color       = $FFFFFF
        TileBt()\Description\Color = $FFFFFF
        TileBt()\Color\Back        = $808000
        TileBt()\Color\Border      = BlendColor_($000000, $808000, 30)
        TileBt()\Color\Focus       = $6D6D00
        TileBt()\Color\FocusBorder = BlendColor_($000000, $6D6D00, 30)
        TileBt()\Color\ToggleBar   = BlendColor_($FFFFFF, $808000, 50)
        TileBt()\Switch\Color      = $FFFFFF
      Case #Theme_Red
        TileBt()\Color\Front       = $FFFFFF
        TileBt()\Title\Color       = $FFFFFF
        TileBt()\Description\Color = $FFFFFF
        TileBt()\Color\Back        = $3C14DC
        TileBt()\Color\Border      = BlendColor_($000000, $3C14DC, 30)
        TileBt()\Color\Focus       = $3B1ABD
        TileBt()\Color\FocusBorder = BlendColor_($000000, $3B1ABD, 30)
        TileBt()\Color\ToggleBar   = BlendColor_($FFFFFF, $3C14DC, 50)
        TileBt()\Switch\Color      = $FFFFFF
      Case #Theme_Pink
        TileBt()\Color\Front       = $FFFFFF
        TileBt()\Title\Color       = $FFFFFF
        TileBt()\Description\Color = $FFFFFF
        TileBt()\Color\Back        = $9213FF
        TileBt()\Color\Border      = BlendColor_($000000, $9213FF, 30)
        TileBt()\Color\Focus       = $830AEB
        TileBt()\Color\FocusBorder = BlendColor_($000000, $830AEB, 30)
        TileBt()\Color\ToggleBar   = BlendColor_($FFFFFF, $9213FF, 50)
        TileBt()\Switch\Color      = $FFFFFF
      Case #Theme_Orange
        TileBt()\Color\Front       = $FFFFFF
        TileBt()\Title\Color       = $FFFFFF
        TileBt()\Description\Color = $FFFFFF
        TileBt()\Color\Back        = $008CFF
        TileBt()\Color\Border      = BlendColor_($000000, $008CFF, 30)
        TileBt()\Color\Focus       = $0A7CDA
        TileBt()\Color\FocusBorder = BlendColor_($000000, $0A7CDA, 30)
        TileBt()\Color\ToggleBar   = BlendColor_($FFFFFF, $008CFF, 50)
        TileBt()\Switch\Color      = $FFFFFF
      Case #Theme_Menue
        TileBt()\Color\Front       = $353535
        TileBt()\Title\Color       = $353535
        TileBt()\Description\Color = $353535
        TileBt()\Color\Back        = TileBt()\Color\Gadget
        TileBt()\Color\Border      = TileBt()\Color\Gadget
        TileBt()\Color\Focus       = $e8e8e8
        TileBt()\Color\FocusBorder = $e8e8e8
        TileBt()\Color\ToggleBar   = BlendColor_($000000, TileBt()\Color\Gadget, 60)
        TileBt()\Switch\Color      = $353535
      Case #Theme_Win11
        TileBt()\Color\Front       = $353535
        TileBt()\Title\Color       = $353535
        TileBt()\Description\Color = $353535
        TileBt()\Color\Back        = $FBFBFB
        TileBt()\Color\Border      = $E5E5E5
        TileBt()\Color\Focus       = $F6F6F6
        TileBt()\Color\FocusBorder = $D5D5D5
        TileBt()\Color\ToggleBar   = BlendColor_($000000, $FBFBFB, 60)
        TileBt()\Switch\Color      = $353535
    EndSelect

  EndProcedure
  
  
  Procedure.i GetOffsetRight()
    Define.i Offset = 0
    
    If TileBt()\Flags & #UseArrow
      Offset + #ArrowWidth + 5
    EndIf
    
    If TileBt()\Flags & #UseSwitch
      
      Offset + TileBt()\Switch\Width + 5
      
      If TileBt()\Switch\On And TileBt()\Switch\Off
        
        If TextWidth_(TileBt()\Switch\On) > TextWidth_(TileBt()\Switch\Off)
          Offset + TextWidth_(TileBt()\Switch\On) + 5
        Else
          Offset + TextWidth_(TileBt()\Switch\Off) + 5
        EndIf 
        
      EndIf 
      
    EndIf
    
    ProcedureReturn Offset
  EndProcedure
  
  
	Procedure.i GetAlignOffset_(imgWidth.i)
		Define.i X, Width, txtWidth, OffsetR
		
		Width   = GadgetWidth(TileBt()\CanvasNum) - (TileBt()\PaddingX * 2)
		OffSetR = GetOffsetRight()
		
		txtWidth = TileBt()\Title\Width
		If TileBt()\Description\Text
		  If TileBt()\Description\Width > txtWidth : txtWidth = TileBt()\Description\Width : EndIf
		EndIf  

		If imgWidth : imgWidth + TileBt()\Image\Spacing : EndIf

		If TileBt()\Image\Flags & #Right
		  
		  If TileBt()\Flags & #Left
		    X = TileBt()\PaddingX 
		  ElseIf TileBt()\Flags & #Right
		    X = GadgetWidth(TileBt()\CanvasNum) - txtWidth - imgWidth - OffSetR - TileBt()\PaddingX
		  Else
		    If OffsetR : OffsetR - 5 : EndIf 
		    X = TileBt()\PaddingX + (Width - imgWidth - OffSetR - txtWidth) / 2
		  EndIf  
		  
		ElseIf TileBt()\Image\Flags & #Left
		  
		  If TileBt()\Flags & #Left
		    X = TileBt()\PaddingX + imgWidth
		  ElseIf TileBt()\Flags & #Right
		    X = GadgetWidth(TileBt()\CanvasNum) - txtWidth - OffSetR - TileBt()\PaddingX
		  Else
		    If OffsetR : OffsetR - 5 : EndIf 
		    X = TileBt()\PaddingX + imgWidth + (Width - imgWidth - txtWidth - OffSetR) / 2
		  EndIf 
		  
		Else
		  
		  If TileBt()\Flags & #Left
		    X = TileBt()\PaddingX + imgWidth
		  ElseIf TileBt()\Flags & #Right
        X = GadgetWidth(TileBt()\CanvasNum) - txtWidth - OffSetR - TileBt()\PaddingX
      Else
        If OffsetR : OffsetR - 5 : EndIf 
		    X = TileBt()\PaddingX + imgWidth + (Width - imgWidth - OffSetR - txtWidth) / 2
		  EndIf
		  
		EndIf

		If X < 0 : X = 0 : EndIf

		ProcedureReturn X
	EndProcedure
	
	Procedure.i ImageAlignOffset_(imgWidth.i)
		Define.i Width, txtWidth, X, ToggleBar, OffSetR
		
		Width   = GadgetWidth(TileBt()\CanvasNum) - (TileBt()\PaddingX * 2)
		OffSetR = GetOffsetRight()
		
		txtWidth = TileBt()\Title\Width
		
		If TileBt()\Description\Text
		  If TileBt()\Description\Width > txtWidth : txtWidth = TileBt()\Description\Width : EndIf
		EndIf  

		imgWidth + TileBt()\Image\Spacing

		If TileBt()\Image\Flags & #Right
			X = GadgetWidth(TileBt()\CanvasNum) - imgWidth - OffSetR - TileBt()\PaddingX
		ElseIf TileBt()\Image\Flags & #Left
			X = TileBt()\PaddingX + ToggleBar
		Else
		  
		  If TileBt()\Flags & #Left
		    X = TileBt()\PaddingX + ToggleBar
		  ElseIf TileBt()\Flags & #Right
		    X = GadgetWidth(TileBt()\CanvasNum) - txtWidth - imgWidth - OffSetR - TileBt()\PaddingX
		  Else
		    If OffsetR : OffsetR - 5 : EndIf 
		    X = TileBt()\PaddingX + (Width - imgWidth - OffSetR - txtWidth) / 2
		  EndIf
		  
		EndIf

		If X < 0 : X = 0 : EndIf

		ProcedureReturn X
	EndProcedure
	
	Procedure.i GetTextOffset(txtWidth.i)
	  Define.i Width, X, ToggleBar, OffSetR
	  
	  Width = GadgetWidth(TileBt()\CanvasNum) - (TileBt()\PaddingX * 2)
	  
	  OffSetR = GetOffsetRight()
	  
	  If TileBt()\Flags & #Left
	    X = TileBt()\PaddingX
	  ElseIf TileBt()\Flags & #Right
	    X = GadgetWidth(TileBt()\CanvasNum) - txtWidth - OffSetR - TileBt()\PaddingX
	  Else
	    If OffsetR : OffsetR - 5 : EndIf 
	    X = (Width - txtWidth - OffSetR ) / 2
	  EndIf  
	  
	  ProcedureReturn X
	EndProcedure
	
	
	Procedure   DrawSwitch_()
	  Define.i X, Y, Width, Height, txtWidth
	  Define.i sRadius, sLines
	  Define.i sButton, sFront, sBack, Front, Back, OffsetX, OffsetY
	  
	  Width  = GadgetWidth(TileBt()\CanvasNum)
	  Height = GadgetHeight(TileBt()\CanvasNum) 
	  
	  ;{ Colors
	  Front  = TileBt()\Switch\Color
	  
	  If TileBt()\Disable
	    Front = TileBt()\Color\DisableFront
			Back  = TileBt()\Color\DisableBack
	  ElseIf TileBt()\State & #Click 
	    Back  = BlendColor_(TileBt()\Color\Focus, TileBt()\Color\Back, 50)
	  ElseIf TileBt()\State & #Focus Or TileBt()\Toggle
	    Back  = TileBt()\Color\Focus
	  Else
	    Back  = TileBt()\Color\Back
	  EndIf

	  sFront = RGBA(Red(Front), Green(Front), Blue(Front), 255)
	  sBack = RGBA(Red(Back), Green(Back), Blue(Back), 255)
	  ;}
	  
	  TileBt()\Switch\X = Width - TileBt()\PaddingX  - TileBt()\Switch\Width
	  If TileBt()\Flags & #UseArrow : TileBt()\Switch\X - #ArrowWidth - 5 : EndIf 

	  TileBt()\Switch\Y = (Height - TileBt()\Switch\Height) / 2
	  
	  sRadius = TileBt()\Switch\Height / 2
	  sLines  = TileBt()\Switch\Width - (sRadius * 2)
	  
	  If TileBt()\Switch\State & #Focus 
	    sButton = sRadius - 2
	    OffsetY = 2
	  Else  
	    sButton = sRadius - 3
	    OffsetY = 3
	  EndIf  
	  
	  If TileBt()\Switch\Status ; On/Off
	    OffsetX = TileBt()\Switch\Width - (sButton * 2) - 3
	  Else
	    OffsetX = 3
	  EndIf   
		
		If StartVectorDrawing(CanvasVectorOutput(TileBt()\CanvasNum))

      AddPathCircle(dpiX(TileBt()\Switch\X + sRadius), dpiY(TileBt()\Switch\Y + sRadius), dpiY(sRadius), 90, 270)
      AddPathCircle(dpiX(TileBt()\Switch\X + TileBt()\Switch\Width - sRadius) , dpiY(TileBt()\Switch\Y + sRadius), dpiY(sRadius), 270, 90, #PB_Path_Connected)
      ClosePath()
      
      VectorSourceColor(sFront)
      StrokePath(1, #PB_Path_Preserve)
      
      VectorSourceColor(sBack)
      FillPath()

      AddPathCircle(dpiX(TileBt()\Switch\X + sButton + OffsetX), dpiY(TileBt()\Switch\Y + sButton + OffsetY), sButton)
      VectorSourceColor(sFront)
		  FillPath()
      StrokePath(1)
      
      ;{ Text
      If TileBt()\Switch\On And TileBt()\Switch\Off
        
        VectorFont(TileBt()\Switch\FontID)
        
        X = dpiX(TileBt()\Switch\X - 5)
        Y = (dpiY(Height) - VectorTextHeight("X")) / 2
        
        If VectorTextWidth(TileBt()\Switch\On) < VectorTextWidth(TileBt()\Switch\Off)
          txtWidth = VectorTextWidth(TileBt()\Switch\Off)
        Else
          txtWidth = VectorTextWidth(TileBt()\Switch\On)
        EndIf 
        
        AddPathBox(X - txtWidth, Y, txtWidth, VectorTextHeight("X"))
        
        VectorSourceColor(sBack)
        FillPath()
        
        VectorSourceColor(sFront)
        
        If TileBt()\Switch\Status
          txtWidth = VectorTextWidth(TileBt()\Switch\On)
          MovePathCursor(X - txtWidth, Y)
          DrawVectorText(TileBt()\Switch\On)
        Else
          txtWidth = VectorTextWidth(TileBt()\Switch\Off)
          MovePathCursor(X - txtWidth, Y)
          DrawVectorText(TileBt()\Switch\Off)
        EndIf   
        
      EndIf ;}
      
      StopVectorDrawing() 
    EndIf

	EndProcedure
	
	Procedure   DrawArrow_()
		Define.i aX, aY, aColor, Color
		Define.i Width, Height  
		
		Color = BlendColor_(TileBt()\Color\Front, TileBt()\Color\Back, 80)
		aColor= RGBA(Red(Color), Green(Color), Blue(Color), 255)
		
		Width  = GadgetWidth(TileBt()\CanvasNum)
		Height = GadgetHeight(TileBt()\CanvasNum)
		
		aX = Width - TileBt()\PaddingX - #ArrowWidth
		aY = (Height - #ArrowHeight) / 2
		
	  If StartVectorDrawing(CanvasVectorOutput(TileBt()\CanvasNum))
	    
      MovePathCursor(dpiX(aX), dpiY(aY))
      AddPathLine(dpiX(aX + #ArrowWidth), dpiY(aY + #ArrowHeight / 2))
      AddPathLine(dpiX(aX), dpiY(aY + #ArrowHeight))
      
      VectorSourceColor(aColor)
      StrokePath(2, #PB_Path_RoundCorner)
      
      StopVectorDrawing()
    EndIf
    
	EndProcedure	
	
	Procedure   Draw_()
		Define.i X, Y, Width, Height, txtWidth, txtHeight, fSize
		Define.s Text, Row
		Define.i lf, s, CountLF, idx, FontID, OffsetX
		Define.i FrontColor, BackColor, BorderColor
		
		If TileBt()\Hide : ProcedureReturn #False : EndIf
		
		If TileBt()\Flags & #MultiLine : NewList Rows.s() : EndIf

		If StartDrawing(CanvasOutput(TileBt()\CanvasNum))
		  
		  Width  = GadgetWidth(TileBt()\CanvasNum)  - (TileBt()\PaddingX * 2)
		  Height = GadgetHeight(TileBt()\CanvasNum) - (TileBt()\PaddingY * 2)
		  
			;{ _____ Background _____
			DrawingMode(#PB_2DDrawing_Default)
			
			If TileBt()\Radius : Box_(0, 0, GadgetWidth(TileBt()\CanvasNum), GadgetHeight(TileBt()\CanvasNum), TileBt()\Color\Gadget) : EndIf 
			
			If TileBt()\Disable                                ;{ Tiles::Disable()
			  FrontColor  = TileBt()\Color\DisableFront
			  BackColor   = TileBt()\Color\DisableBack
			  BorderColor = BackColor
			  Box_(0, 0, GadgetWidth(TileBt()\CanvasNum), GadgetHeight(TileBt()\CanvasNum), BackColor)
        ;}
			ElseIf TileBt()\State & #Click                     ;{ Button - Click / Toggle
			  BorderColor = TileBt()\Color\FocusBorder
			  Box_(0, 0, GadgetWidth(TileBt()\CanvasNum), GadgetHeight(TileBt()\CanvasNum), BlendColor_(TileBt()\Color\Focus, TileBt()\Color\Back, 50))
			  ;}
			ElseIf TileBt()\State & #Focus Or TileBt()\Toggle  ;{ Button - Focus
			  BorderColor = TileBt()\Color\FocusBorder
				Box_(0, 0, GadgetWidth(TileBt()\CanvasNum), GadgetHeight(TileBt()\CanvasNum), TileBt()\Color\Focus)
				;}
			Else
			  BorderColor = TileBt()\Color\Border
				Box_(0, 0, GadgetWidth(TileBt()\CanvasNum), GadgetHeight(TileBt()\CanvasNum), TileBt()\Color\Back)
			EndIf ;}

			;{ _____ Text & Image _____
			txtHeight = 0
			
			If TileBt()\Description\Text ;{ Description
			  
			  FontID = TileBt()\Description\FontID
			  If FontID = #PB_Default : FontID = TileBt()\FontID : EndIf
			
			  DrawingFont(FontID)
			  
			  TileBt()\Description\Width  = TextWidth_(TileBt()\Description\Text)
			  TileBt()\Description\Height = TextHeight_(TileBt()\Description\Text)
			  
			  txtHeight + TileBt()\Description\Height
			  ;}
			EndIf  
			
			If TileBt()\Title\Text       ;{ Title
			  
			  FontID = TileBt()\Title\FontID
			  If FontID = #PB_Default : FontID = TileBt()\FontID : EndIf
			
			  DrawingFont(FontID)
			  
			  TileBt()\Title\Width  = TextWidth_(TileBt()\Title\Text)
			  TileBt()\Title\Height = TextHeight_(TileBt()\Title\Text)
			  
			  txtHeight + TileBt()\Title\Height
			  ;}
			EndIf   
			
			If TileBt()\Flags & #Image   ;{ Button with image

				If TileBt()\Title\Text     ;{ Image & Text

				  X = ImageAlignOffset_(TileBt()\Image\Width)
					Y = (GadgetHeight(TileBt()\CanvasNum) - TileBt()\Image\Height) / 2
					
					DrawingMode(#PB_2DDrawing_AlphaBlend)
					DrawImage_(ImageID(TileBt()\Image\Num), X, Y, TileBt()\Image\Width, TileBt()\Image\Height)
					
					X = GetAlignOffset_(TileBt()\Image\Width)
					Y = (GadgetHeight(TileBt()\CanvasNum) - txtHeight) / 2
					
					DrawingMode(#PB_2DDrawing_Transparent)
					
					If TileBt()\Flags & #Center ;{ Center Text & Image
					  
					  OffsetX = 0
					  
					  If TileBt()\Description\Text And TileBt()\Description\Width > TileBt()\Title\Width
					    OffsetX = (TileBt()\Description\Width - TileBt()\Title\Width) / 2
					  EndIf
					  
					  FrontColor = TileBt()\Title\Color
					  If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
					  
					  DrawingFont(TileBt()\Title\FontID)
					  DrawText_(X + OffsetX, Y, TileBt()\Title\Text, FrontColor)
					  
					  If TileBt()\Description\Text
					    
					    OffsetX = 0
					    
					    FrontColor = TileBt()\Description\Color
					    If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
					    
					    If TileBt()\Description\Width < TileBt()\Title\Width
  					    OffsetX = (TileBt()\Title\Width - TileBt()\Description\Width) / 2
  					  EndIf
  					  
  					  DrawingFont(TileBt()\Description\FontID)
  					  DrawText_(X + OffsetX, Y + TileBt()\Title\Height, TileBt()\Description\Text, FrontColor)
  					  
					  EndIf  
					  ;}
					Else                        ;{ Left or right image

					  FrontColor = TileBt()\Title\Color
					  If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
					  
					  DrawingFont(TileBt()\Title\FontID)
					  DrawText_(X, Y, TileBt()\Title\Text, FrontColor)
					  
					  If TileBt()\Description\Text
					    
					    FrontColor = TileBt()\Description\Color
					    If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf  
					    
					    DrawingFont(TileBt()\Description\FontID)
					    
					    DrawText_(X, Y + TileBt()\Title\Height, TileBt()\Description\Text, FrontColor)
					  EndIf
					  ;}
					EndIf
					;}
				Else ;{ Image only

					X = (GadgetWidth(TileBt()\CanvasNum)  - TileBt()\Image\Width) / 2
					Y = (GadgetHeight(TileBt()\CanvasNum) - TileBt()\Image\Height) / 2
					
					DrawingMode(#PB_2DDrawing_AlphaBlend)
					DrawImage_(ImageID(TileBt()\Image\Num), X, Y, TileBt()\Image\Width, TileBt()\Image\Height)
					;}
				EndIf
				;}
			Else ;{ Text only

				If TileBt()\Title\Text Or TileBt()\Description\Text
          
				  If TileBt()\Flags & #MultiLine ;{ Multiline Text

				    txtWidth  = Width - 8
				    txtHeight = 0
				    
				    CountLF = CountString(TileBt()\Title\Text, #LF$)
				    If CountLF: TileBt()\Title\Text = ReplaceString(TileBt()\Title\Text, #CRLF$, #LF$) : EndIf
				    
				    If TileBt()\Title\Height + 8 > Width ;{ Wrap and LineFeed

				      If CountLF ;{ Text with #LF$
				        
				        For lf=1 To CountLF + 1

				          Row  = Trim(StringField(TileBt()\Title\Text, lf, #LF$))
				          Text = ""
				          
				          If TextWidth_(Row) > txtWidth
				            
				            ;{ Wrap text
				            For s=1 To CountString(Row, " ") + 1
				              If TextWidth_(StringField(Row, s, " ")) >=  txtWidth
				                If AddElement(Rows())
				                  Rows() = StringField(Row, s, " ")
				                  Break
				                EndIf
				              ElseIf TextWidth_(Text + " " + StringField(Row, s, " ")) < txtWidth
				                Text + " " + StringField(Row, s, " ")  
				              Else
        							  If AddElement(Rows())
        									Rows() = Text
        									Text   = StringField(Row, s, " ")
        								EndIf
        							EndIf
				            Next
				            ;}
				            
				            If Text <> ""
				              If AddElement(Rows()) : Rows() = Text : EndIf
        						EndIf
				            
        					Else
        					  
        					  If AddElement(Rows())
        					    Rows() = Row
        					  EndIf
				            
				          EndIf
				          
				        Next  
				        ;}
    					Else       ;{ Wrap textonly
    					  
    					  For s=1 To CountString(TileBt()\Title\Text, " ") + 1
    							If TextWidth_(Text + " " + StringField(TileBt()\Title\Text, s, " ")) < txtWidth
    								Text + " " + StringField(TileBt()\Title\Text, s, " ")
    							Else
    							  If AddElement(Rows())
    									Rows() = Text
    									Text = StringField(TileBt()\Title\Text, s, " ")
    								EndIf
    							EndIf
    						Next
    						
    					  If Text <> ""
    					    If AddElement(Rows())
    					      Rows() = Text
    					    EndIf
    						EndIf
  						  ;}
    					EndIf
          
    					txtHeight = ListSize(Rows()) * TileBt()\Title\Height
    					If TileBt()\Description\Text : txtHeight + TileBt()\Description\Height : EndIf 
    					
    					Y = (GadgetHeight(TileBt()\CanvasNum) - txtHeight) / 2 
    					
    					FrontColor = TileBt()\Title\Color
					    If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
    					
    					DrawingMode(#PB_2DDrawing_Transparent)
    					DrawingFont(TileBt()\Description\FontID)
    					
  						ForEach Rows()
  							X = GetTextOffset(TextWidth_(Rows()))
  							DrawText_(X, Y, Rows(), FrontColor)
  							Y + TextHeight_(Rows())
  						Next
  						
  						If TileBt()\Description\Text
  						  
  						  FrontColor = TileBt()\Description\Color
                If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
  						  
  						  X = GetTextOffset(TileBt()\Description\Width)

    					  DrawText_(X, Y, TileBt()\Description\Text, FrontColor)
    					EndIf 
  						;}
  					ElseIf CountLF                       ;{ LineFeed
  					  
  					  txtHeight = 0
  					  
  					  For s=1 To CountLF + 1
								If AddElement(Rows())
								  Rows() = StringField(TileBt()\Title\Text, s, #LF$)
								  txtHeight + TileBt()\Title\Height
								EndIf
  						Next
  						
  						If TileBt()\Description\Text : txtHeight + TileBt()\Description\Height : EndIf 
  						
  						FrontColor = TileBt()\Title\Color
					    If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
  						
  						Y = (GadgetHeight(TileBt()\CanvasNum) - txtHeight) / 2
  						
  						DrawingMode(#PB_2DDrawing_Transparent)
  						DrawingFont(TileBt()\Title\FontID)

  						ForEach Rows()
  							X = GetTextOffset(TextWidth_(Rows()))
  							DrawText_(X, Y, Rows(), FrontColor)
  							Y + TileBt()\Title\Height
  						Next
  						
  						If TileBt()\Description\Text
  						  
  						  FrontColor = TileBt()\Description\Color
					      If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
  						  
					      X = GetTextOffset(TileBt()\Description\Width)
					    
    					  DrawingFont(TileBt()\Description\FontID)
    					  DrawText_(X, Y, TileBt()\Description\Text, FrontColor)
    					EndIf 
  						;}
  					Else                                 ;{ Single line
  					  
  					  DrawingMode(#PB_2DDrawing_Transparent)
  					  
    					X = GetTextOffset(TileBt()\Title\Width)
    					Y = (GadgetHeight(TileBt()\CanvasNum) - txtHeight) / 2
    					
    					FrontColor = TileBt()\Title\Color
					    If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
    					
    					DrawingFont(TileBt()\Title\FontID)
    					DrawText_(X, Y, TileBt()\Title\Text, FrontColor)
    					
    					If TileBt()\Description\Text
    					  
    					  FrontColor = TileBt()\Description\Color
					      If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
    					  
    					  X = GetTextOffset(TileBt()\Description\Width)
    					  
    					  DrawingFont(TileBt()\Description\FontID)
    					  DrawText_(X, Y + TileBt()\Title\Height, TileBt()\Description\Text, FrontColor)
    					EndIf  
    					;}
  					EndIf
  					;}
				  Else
  					
				    Y = (GadgetHeight(TileBt()\CanvasNum) - txtHeight) / 2
				    
  					DrawingMode(#PB_2DDrawing_Transparent)
  					
  					If TileBt()\Title\Text
  					
  					  X = GetTextOffset(TileBt()\Title\Width)
  					  
  					  FrontColor = TileBt()\Title\Color
					    If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 
  					  
  					  DrawingFont(TileBt()\Title\FontID)
  					  DrawText_(X, Y, TileBt()\Title\Text, FrontColor)
  					  
  					  Y + TileBt()\Title\Height
  					EndIf   
  					
  					If TileBt()\Description\Text
  					  
  					  X = GetTextOffset(TileBt()\Description\Width)
  					  
  					  FrontColor = TileBt()\Description\Color
					    If TileBt()\Disable : FrontColor = TileBt()\Color\DisableFront : EndIf 

  					  DrawingFont(TileBt()\Description\FontID)
  					  DrawText_(X, Y, TileBt()\Description\Text, FrontColor)
  					EndIf   
  					
  				EndIf

				EndIf
				;}
			EndIf
			;}
			
			If TileBt()\Flags & #ToggleBar And (TileBt()\Toggle Or TileBt()\State & #Click)
			  
			  DrawingMode(#PB_2DDrawing_Default)
			  
			  Select TileBt()\ToggleBar\Align ;{ ToggleBar Align
			    Case #Top
			      fSize = TileBt()\ToggleBar\Height
			      If fSize = #PB_Default : fSize = GadgetWidth(TileBt()\CanvasNum) / 1.6 : EndIf 
			      X = (GadgetWidth(TileBt()\CanvasNum) - fSize) / 2
			      Y = 1
			      Box_(X, Y, fSize, TileBt()\ToggleBar\Width, TileBt()\Color\ToggleBar)
			    Case #Bottom
			      fSize = TileBt()\ToggleBar\Height
			      If fSize = #PB_Default : fSize = GadgetWidth(TileBt()\CanvasNum) / 1.6 : EndIf 
			      X = (GadgetWidth(TileBt()\CanvasNum) - fSize) / 2
			      Y = GadgetHeight(TileBt()\CanvasNum) - TileBt()\ToggleBar\Width - 1
			      Box_(X, Y, fSize, TileBt()\ToggleBar\Width, TileBt()\Color\ToggleBar)
			    Case #Right
			      fSize = TileBt()\ToggleBar\Height
			      If fSize = #PB_Default : fSize = GadgetHeight(TileBt()\CanvasNum) / 2 : EndIf 
			      X = GadgetWidth(TileBt()\CanvasNum) - TileBt()\ToggleBar\Width - 1
			      Y = (GadgetHeight(TileBt()\CanvasNum) - fSize) / 2
			      Box_(X, Y, TileBt()\ToggleBar\Width, fSize, TileBt()\Color\ToggleBar)
			    Default
			      fSize = TileBt()\ToggleBar\Height
			      If fSize = #PB_Default : fSize = GadgetHeight(TileBt()\CanvasNum) / 2 : EndIf 
			      X = 1
			      Y = (GadgetHeight(TileBt()\CanvasNum) - fSize) / 2
			      Box_(X, Y, TileBt()\ToggleBar\Width, fSize, TileBt()\Color\ToggleBar)
			  EndSelect ;}

			EndIf  
			
			;{ _____ Border ____
		  If TileBt()\Flags & #Border
			  DrawingMode(#PB_2DDrawing_Outlined)
			  Box_(0, 0, GadgetWidth(TileBt()\CanvasNum), GadgetHeight(TileBt()\CanvasNum), BorderColor, TileBt()\Radius)
			EndIf
			;}

			StopDrawing()
		EndIf
		
		If TileBt()\Flags & #UseSwitch : DrawSwitch_() : EndIf 
		
		If TileBt()\Flags & #UseArrow  : DrawArrow_()  : EndIf 
		
	EndProcedure
	
	;- __________ Events __________
	
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach TileBt()

        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          TileBt()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        TileBt()\Color\Front        = ModuleEx::ThemeGUI\Button\FrontColor
        TileBt()\Color\Back         = ModuleEx::ThemeGUI\Button\BackColor
        TileBt()\Color\Focus        = ModuleEx::ThemeGUI\Focus\BackColor
        TileBt()\Color\Border       = ModuleEx::ThemeGUI\Button\BorderColor
        TileBt()\Color\Gadget       = ModuleEx::ThemeGUI\GadgetColor
        TileBt()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
		    TileBt()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf  	
	
	
	Procedure _LeftButtonDownHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(TileBt(), Str(GNum))
		  
			TileBt()\State | #Click

		  If TileBt()\Flags & #Toggle
		    
		    TileBt()\Toggle ! #True

		    If TileBt()\Group ;{ Toogle group
		      
		      If TileBt()\Toggle = #True
		        If FindMapElement(Group(), TileBt()\Group)
		          
		          ForEach Group()\GadgetNum()
			          If Group()\GadgetNum() = GNum : Continue : EndIf
			          PushMapPosition(TileBt())
			          If FindMapElement(TileBt(), Str(Group()\GadgetNum()))
			            TileBt()\Toggle = #False
			            Draw_()
			          EndIf  
			          PopMapPosition(TileBt())
			        Next 
			        
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
		Define.i GNum = EventGadget()
		
		If FindMapElement(TileBt(), Str(GNum))
		  
		  X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
  	  Y = DesktopUnscaledY(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
  	  
  	  If TileBt()\Flags & #UseSwitch
  	    
    	  If X > TileBt()\Switch\X And X < TileBt()\Switch\X + TileBt()\Switch\Width
    	    If Y > TileBt()\Switch\Y And Y < TileBt()\Switch\Y + TileBt()\Switch\Height
    	      
    	      TileBt()\Switch\Status ! #True
    	      
    	      DrawSwitch_()
    	      
    	      PostEvent(#Event_Gadget, TileBt()\Window\Num, TileBt()\CanvasNum, #EventType_Switch, TileBt()\Switch\Status)
    	      PostEvent(#PB_Event_Gadget, TileBt()\Window\Num, TileBt()\CanvasNum, #EventType_Button)
    	      
    	      ProcedureReturn #True
    	    EndIf  
    	  EndIf
    	  
  	  EndIf
  	  
			If TileBt()\State & #Focus And TileBt()\State & #Click
				PostEvent(#Event_Gadget, TileBt()\Window\Num, TileBt()\CanvasNum, #EventType_Button, TileBt()\Toggle)
				PostEvent(#PB_Event_Gadget, TileBt()\Window\Num, TileBt()\CanvasNum, #EventType_Button)
			EndIf

			TileBt()\State & ~#Click

			Draw_()
		EndIf

	EndProcedure
	
	Procedure _MouseMoveHandler()
	  Define.i X, Y
	  Define.i GNum = EventGadget()
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    
  	  X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
  	  Y = DesktopUnscaledY(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
  	  
  	  If X > TileBt()\Switch\X And X < TileBt()\Switch\X + TileBt()\Switch\Width
  	    If Y > TileBt()\Switch\Y And Y < TileBt()\Switch\Y + TileBt()\Switch\Height
  	      
  	      If TileBt()\Switch\State & #Focus = #False
  	        TileBt()\Switch\State | #Focus
  	        DrawSwitch_()
  	      EndIf
  	      
  	      ProcedureReturn #True
  	    EndIf  
  	  EndIf
  	  
  	  If TileBt()\Switch\State & #Focus
  	    TileBt()\Switch\State & ~#Focus
  	    DrawSwitch_()
  	  EndIf
  	  
  	EndIf 
  	
	EndProcedure
	
	Procedure _MouseEnterHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(TileBt(), Str(GNum))
			TileBt()\State | #Focus
			Draw_()
		EndIf

	EndProcedure

	Procedure _MouseLeaveHandler()
		Define.i GNum = EventGadget()

		If FindMapElement(TileBt(), Str(GNum))
			TileBt()\State & ~#Focus
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeHandler()
		Define.i GadgetID = EventGadget()

		If FindMapElement(TileBt(), Str(GadgetID))
			Draw_()
		EndIf

	EndProcedure

	Procedure _ResizeWindowHandler()
	  Define.f X, Y, Width, Height
	  Define.i FontSize
		Define.f OffSetX, OffSetY

		ForEach TileBt()

			If IsGadget(TileBt()\CanvasNum)

				If TileBt()\Flags & #AutoResize

					If IsWindow(TileBt()\Window\Num)

						OffSetX = WindowWidth(TileBt()\Window\Num)  - TileBt()\Window\Width
						OffsetY = WindowHeight(TileBt()\Window\Num) - TileBt()\Window\Height

						If TileBt()\Size\Flags

							X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore

							If TileBt()\Size\Flags & #MoveX  : X = TileBt()\Size\X + OffSetX : EndIf
							If TileBt()\Size\Flags & #MoveY  : Y = TileBt()\Size\Y + OffSetY : EndIf
							If TileBt()\Size\Flags & #Width  : Width  = TileBt()\Size\Width  + OffSetX : EndIf
							If TileBt()\Size\Flags & #Height : Height = TileBt()\Size\Height + OffSetY : EndIf
							
							ResizeGadget(TileBt()\CanvasNum, X, Y, Width, Height)

						Else
						  
						  ResizeGadget(TileBt()\CanvasNum, #PB_Ignore, #PB_Ignore, TileBt()\Size\Width + OffSetX, TileBt()\Size\Height + OffsetY)
						  
						EndIf
						
						CompilerIf Defined(ModuleEx, #PB_Module)
						  
						  If TileBt()\Size\Flags & #FitText
						    
						    If TileBt()\Size\Flags & #FixPadding
						      Width  = TileBt()\Size\Text - TileBt()\PaddingX
                  Height = GadgetHeight(TileBt()\CanvasNum) - TileBt()\PaddingY
						    Else
						      Width  = TileBt()\Size\Text - TileBt()\PaddingX
                  Height = GadgetHeight(TileBt()\CanvasNum) - (GadgetHeight(TileBt()\CanvasNum) * TileBt()\PFactor)
						    EndIf
						    
						    If Height < 0 : Height = 0 : EndIf 
						    If Width  < 0 : Width  = 0 : EndIf
						    
						    FontSize = ModuleEx::RequiredFontSize(TileBt()\Title\Text, Width, Height, TileBt()\Font\Num)
						    
						    If FontSize <> TileBt()\Font\Size
                  TileBt()\Font\Size = FontSize
                  TileBt()\Font\Num  = ModuleEx::Font(TileBt()\Font\Name, FontSize, TileBt()\Font\Style)
                  If IsFont(TileBt()\Font\Num) : TileBt()\FontID = FontID(TileBt()\Font\Num) : EndIf
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
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    
	    If State
	      
	      TileBt()\Group = Group
	      
	      If AddElement(Group(Group)\GadgetNum())
  	      Group(Group)\GadgetNum() = GNum
  	    EndIf
	    
	    Else
	      
	      TileBt()\Group = ""
	      
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

	Procedure   AddImage(GNum.i, ImageNum.i, Flags.i=#False, Width.i=#PB_Default, Height.i=#PB_Default)

		If FindMapElement(TileBt(), Str(GNum))

		  If IsImage(ImageNum)
		    
				TileBt()\Image\Num   = ImageNum
				TileBt()\Image\Width = Width
				
				If Width = #PB_Default : TileBt()\Image\Width  = ImageWidth(ImageNum)  : EndIf
				TileBt()\Image\Height = Height
				If Width = #PB_Default : TileBt()\Image\Height = ImageHeight(ImageNum) : EndIf
				TileBt()\Image\Flags = Flags
				TileBt()\Flags | #Image
				Draw_()
			EndIf

		EndIf

	EndProcedure
	
	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(TileBt(), Str(GNum))

      TileBt()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure 
  
  Procedure   Free(GNum.i)
    
    If FindMapElement(TileBt(), Str(GNum))
      
      DeleteMapElement(TileBt())
      
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
  
  
	Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i=#False, WindowNum.i=#PB_Default)
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

			If AddMapElement(TileBt(), Str(GNum))

				TileBt()\CanvasNum = GNum

        If WindowNum = #PB_Default
          TileBt()\Window\Num = GetGadgetWindow()
        Else
          TileBt()\Window\Num = WindowNum
        EndIf

				CompilerIf Defined(ModuleEx, #PB_Module)
					If ModuleEx::AddWindow(TileBt()\Window\Num, ModuleEx::#Tabulator)
					  ModuleEx::AddGadget(GNum, TileBt()\Window\Num)
					EndIf
				CompilerEndIf
				
				TileBt()\PaddingX = 10
				TileBt()\PaddingY = 5
				
				TileBt()\ToggleBar\Width  = 3
				TileBt()\ToggleBar\Height = #PB_Default
				TileBt()\Image\Spacing   = 10
				
				TileBt()\Title\Text = Text
				
				If Flags & #Left = #False And Flags & #Right = #False
				  Flags | #Center
				EndIf   
				
				If Flags & #Toggle : Flags | #ToggleBar : EndIf
				
				TileBt()\Flags = Flags
				
				If Flags & #MacOS      : TileBt()\Radius = 7               : EndIf
				If Flags & #FitText    : TileBt()\Size\Flags | #FitText    : EndIf
				If Flags & #FixPadding : TileBt()\Size\Flags | #FixPadding : EndIf
				
				;{ Default Gadget Font
				CompilerSelect #PB_Compiler_OS 
					CompilerCase #PB_OS_Windows
						TileBt()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If txtNum
							TileBt()\FontID = GetGadgetFont(txtNum)
							FreeGadget(txtNum)
						EndIf
					CompilerCase #PB_OS_Linux
						TileBt()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}
				
				TileBt()\Title\FontID       = TileBt()\FontID
				TileBt()\Description\FontID = TileBt()\FontID
				TileBt()\Switch\FontID      = TileBt()\FontID
				
				TileBt()\Size\X = X
				TileBt()\Size\Y = Y
				TileBt()\Size\Width  = Width
				TileBt()\Size\Height = Height
				
				TileBt()\Switch\Width  = 40
				TileBt()\Switch\Height = 18
				
        ColorTheme_(#PB_Default)
				
				BindGadgetEvent(TileBt()\CanvasNum, @_MouseEnterHandler(),     #PB_EventType_MouseEnter)
				BindGadgetEvent(TileBt()\CanvasNum, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)
				BindGadgetEvent(TileBt()\CanvasNum, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
				BindGadgetEvent(TileBt()\CanvasNum, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
				BindGadgetEvent(TileBt()\CanvasNum, @_ResizeHandler(),         #PB_EventType_Resize)
				
				If TileBt()\Flags & #UseSwitch
				  BindGadgetEvent(TileBt()\CanvasNum, @_MouseMoveHandler(),    #PB_EventType_MouseMove)
				EndIf  
				
				CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
				
				If IsWindow(TileBt()\Window\Num)
					TileBt()\Window\Width  = WindowWidth(TileBt()\Window\Num)
					TileBt()\Window\Height = WindowHeight(TileBt()\Window\Num)
					BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), TileBt()\Window\Num)
				EndIf

				Draw_()

			EndIf

		EndIf

		ProcedureReturn TileBt()\CanvasNum
	EndProcedure
	
	
	Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    ProcedureReturn TileBt()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    ProcedureReturn TileBt()\ID
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetState(GNum.i, Flag.i=#False)

	  If FindMapElement(TileBt(), Str(GNum))
	    
	    If Flag = #Switch
	      ProcedureReturn TileBt()\Switch\Status
			ElseIf TileBt()\Flags & #Toggle
				ProcedureReturn TileBt()\Toggle
			Else
				ProcedureReturn #PB_Default
			EndIf
			
		EndIf

	EndProcedure
	
	Procedure.s GetText(GNum.i, Flag.i=#Title)
	  ;Flag: #Title / #Description
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    
	    If Flag = #Description
  	    ProcedureReturn TileBt()\Description\Text
  	  Else
  	    ProcedureReturn TileBt()\Title\Text
  	  EndIf  
	  
	  EndIf  
	  
	EndProcedure
	
	
	Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(TileBt(), Str(GNum))
      
      If State
        TileBt()\Hide = #True
        HideGadget(GNum, #True)
      Else
        TileBt()\Hide = #False
        HideGadget(GNum, #False)
        Draw_()
      EndIf
    
    EndIf  
    
  EndProcedure  
  
  
  Procedure   SaveColorTheme(GNum.i, File.s)
    Define.i JSON
    
    If FindMapElement(TileBt(), Str(GNum))
      
      JSON = CreateJSON(#PB_Any)
      If JSON
        InsertJSONStructure(JSONValue(JSON), @TileBt()\Color, TileBt_Color_Structure)
        SaveJSON(JSON, File)
        FreeJSON(JSON)
      EndIf
     
    EndIf  
    
  EndProcedure  
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
	  
    If FindMapElement(TileBt(), Str(GNum))
     
      Select Attribute
        Case #Corner
          TileBt()\Radius   = Value
        Case #PaddingX
          TileBt()\PaddingX = Value
        Case #PaddingY
          TileBt()\PaddingY = Value
        Case #ImageSpacing
          TileBt()\Image\Spacing    = Value
        Case #ToggleWidth
          TileBt()\ToggleBar\Width  = Value
        Case #ToggleHeight 
          TileBt()\ToggleBar\Height = Value
        Case #ToggleAlign
          TileBt()\ToggleBar\Align  = Value
      EndSelect
      
	    Draw_()
	  EndIf
	  
	EndProcedure
  
	Procedure   SetAutoResizeFlags(GNum.i, Flags.i)

		If FindMapElement(TileBt(), Str(GNum))

			TileBt()\Size\Flags = Flags

		EndIf

	EndProcedure

	Procedure   SetColor(GNum.i, ColorType.i, Color.i, Flag.i=#Title)
	  ;Flag: #Title / #Description
	  
		If FindMapElement(TileBt(), Str(GNum))
		  
			Select ColorType
			  Case #FrontColor
			    
			    If Color = #PB_Default : Color = TileBt()\Color\Front : EndIf 
			    
			    If Flag = #Description
			      TileBt()\Description\Color = Color
			    ElseIf Flag = #Switch
			      TileBt()\Switch\Color      = Color
			    Else
			      TileBt()\Title\Color       = Color
			      TileBt()\Color\Front       = Color
			    EndIf  
			    
				Case #BackColor
					TileBt()\Color\Back      = Color
				Case #BorderColor
					TileBt()\Color\Border    = Color
				Case #FocusColor
				  TileBt()\Color\Focus     = Color
				Case #ToggleColor
				  TileBt()\Color\ToggleBar = Color
			EndSelect

			Draw_()

		EndIf

	EndProcedure
	
	Procedure   SetColorTheme(GNum.i, Theme.i=#Theme_Default, File.s="")           ; GNum: #Theme => change all gadgets
    ; #Theme_Blue / #Theme_Green /  #Theme_Custom (File.s)
    ; #Theme_Custom => Tiles::SaveColorTheme() 
    Define.i JSON
    
    If GNum = #Theme 
      
      If Theme = #Theme_Custom
        JSON = LoadJSON(#PB_Any, File)
      EndIf  
      
      ForEach TileBt()
        
        If Theme = #Theme_Custom 
          If IsJSON(JSON) : ExtractJSONStructure(JSONValue(JSON), @TileBt()\Color, TileBt_Color_Structure) : EndIf
          TileBt()\Title\Color       = TileBt()\Color\Front
          TileBt()\Description\Color = TileBt()\Color\Front
        Else
          ColorTheme_(Theme)
        EndIf
        
        Draw_()
      Next
      
      If Theme = #Theme_Custom
        If IsJSON(JSON) : FreeJSON(JSON) : EndIf
      EndIf  
      
    ElseIf FindMapElement(TileBt(), Str(GNum))

      If Theme = #Theme_Custom 
        JSON = LoadJSON(#PB_Any, File)
        If JSON
          ExtractJSONStructure(JSONValue(JSON), @TileBt()\Color, TileBt_Color_Structure)
          FreeJSON(JSON)
        EndIf
        TileBt()\Title\Color       = TileBt()\Color\Front
        TileBt()\Description\Color = TileBt()\Color\Front
      Else
        ColorTheme_(Theme)
      EndIf
    
      Draw_()
    EndIf  
    
  EndProcedure
	
	
	Procedure   SetFont(GNum.i, FontNum.i, Flag.i=#Title)
	  ; Flag: #Title / #Description / #Switch
	  
		If FindMapElement(TileBt(), Str(GNum))
		  
		  If FontNum = #PB_Default : FontNum = TileBt()\FontID : EndIf
		  
		  If IsFont(FontNum)
		    
		    If Flag = #Description
		      TileBt()\Description\FontID = FontID(FontNum)
		    ElseIf Flag = #Switch
		      TileBt()\Switch\FontID      = FontID(FontNum)
		    Else
		      TileBt()\Title\FontID       = FontID(FontNum)
		    EndIf   

				Draw_()
			EndIf

		EndIf

	EndProcedure	
	
	Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    TileBt()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    TileBt()\ID = String
	  EndIf
	  
	EndProcedure
	
	Procedure   SetState(GNum.i, State.i, Flag.i=#False)

	  If FindMapElement(TileBt(), Str(GNum))
	    
	    If Flag = #Switch
	      TileBt()\Switch\Status = State
	    Else  
	      TileBt()\Toggle = State
	    EndIf
	    
		  Draw_()
		EndIf

	EndProcedure

	Procedure   SetText(GNum.i, Text.s, Flag.i=#Title)
	  ; Flag: #Title / #Description / #Switch
	  ; Switch: e.g. "On|Off" or "An|Aus"
	  
	  If FindMapElement(TileBt(), Str(GNum))
	    
	    If Flag = #Description
	      TileBt()\Description\Text = Text
	    ElseIf Flag = #Switch
	      Text = ReplaceString(Text, #LF$, "|")
	      TileBt()\Switch\On  = StringField(Text, 1, "|")
	      TileBt()\Switch\Off = StringField(Text, 2, "|")
	    Else  
	      TileBt()\Title\Text = Text
	    EndIf  
	    
	    Draw_()
		EndIf

	EndProcedure
	
	
	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Procedure.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	    Define.i FontNum
	    Define   Padding.ModuleEx::Padding_Structure
	    
	    If FindMapElement(TileBt(), Str(GNum))
	      
	      FontNum = ModuleEx::Font(Name, Size, Style)
	      If IsFont(FontNum)
	        
	        TileBt()\Font\Num   = FontNum
	        TileBt()\Font\Name  = Name
	        TileBt()\Font\Size  = Size
	        TileBt()\Font\Style = Style
	        TileBt()\FontID     = FontID(FontNum)

	        ModuleEx::CalcPadding(TileBt()\Title\Text, GadgetHeight(GNum), FontNum, Size, @Padding)
	        TileBt()\PaddingX = Padding\X
	        TileBt()\PaddingY = Padding\Y
	        TileBt()\PFactor  = Padding\Factor
  	      
	        Draw_()
	      EndIf
	      
	    EndIf
	    
	    ProcedureReturn FontNum
	  EndProcedure
	  
	  Procedure.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(TileBt(), Str(GNum))
	      
	      If IsFont(TileBt()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : TileBt()\PaddingX = PaddingX * 2 : EndIf 
	      If PaddingY <> #PB_Default : TileBt()\PaddingY = PaddingY * 2 : EndIf 
	      
	      If TileBt()\Size\Flags & #FixPadding Or PaddingY <> #PB_Default
		      Width  = TileBt()\Size\Text - TileBt()\PaddingX
          Height = GadgetHeight(TileBt()\CanvasNum) - TileBt()\PaddingY
		    Else
		      Width  = TileBt()\Size\Text - TileBt()\PaddingX
          Height = GadgetHeight(TileBt()\CanvasNum) - (GadgetHeight(TileBt()\CanvasNum) * TileBt()\PFactor)
		    EndIf
		    
		    FontSize = ModuleEx::RequiredFontSize(TileBt()\Title\Text, Width, Height, TileBt()\Font\Num)
		    If FontSize <> TileBt()\Font\Size
          TileBt()\Font\Size = FontSize
          TileBt()\Font\Num  = ModuleEx::Font(TileBt()\Font\Name, FontSize, TileBt()\Font\Style)
          TileBt()\FontID    = FontID(TileBt()\Font\Num)
        EndIf  
        
        Draw_()
      EndIf
      
	    ProcedureReturn TileBt()\Font\Num
	  EndProcedure  
	  
	  Procedure.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(TileBt(), Str(GNum))
	      
	      If IsFont(TileBt()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : TileBt()\PaddingX = PaddingX : EndIf 
	      If PaddingY <> #PB_Default : TileBt()\PaddingY = PaddingY : EndIf 
	      
	      TileBt()\Title\Text = Text
	      
	      If TileBt()\Size\Flags & #FixPadding
		      Width  = TileBt()\Size\Text - TileBt()\PaddingX
          Height = GadgetHeight(TileBt()\CanvasNum) - TileBt()\PaddingY
		    Else
		      Width  = TileBt()\Size\Text - TileBt()\PaddingX
          Height = GadgetHeight(TileBt()\CanvasNum) - (GadgetHeight(TileBt()\CanvasNum) * TileBt()\PFactor)
		    EndIf
		    
		    FontSize = ModuleEx::RequiredFontSize(TileBt()\Title\Text, Width, Height, TileBt()\Font\Num)
		    If FontSize <> TileBt()\Font\Size
          TileBt()\Font\Size = FontSize
          TileBt()\Font\Num  = ModuleEx::Font(TileBt()\Font\Name, FontSize, TileBt()\Font\Style)
          TileBt()\FontID    = FontID(TileBt()\Font\Num)
        EndIf 
        
        Draw_()
      EndIf
      
	    ProcedureReturn TileBt()\Font\Num
	  EndProcedure  
	  
	CompilerEndIf  
	
EndModule

;- ======== Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 3
  
  ; 0: Tile with and without description
  ; 1: Tiles with arrows
  ; 2: Tiles with toggle bar
  ; 3: Tiles with toggle buttons
  ; 4: Tiles with switch

  ;{ Functions Example
  EnumerationBinary 
    #ToggleBarAlign
    #ImageLeft
    #ImageRight
    #ImageSpacing
    #CombineToggle
    #OnOffText
    #Theme_Win11
    #Theme_Menue
    #ColorThemes1
    #ColorThemes2
  EndEnumeration ;}
  
  #Functions = #ColorThemes1|#ImageLeft
  
  ; #ImageLeft      - Add button image
  ; #ImageRight     - Add button image
  ; #ImageSpacing   - Change image spacing (needs: #ImageLeft)
  ; #ToggleBarAlign - ToggleBar bottom/right
  ; #CombineToggle  - Combining buttons into a group (needs: #Example 3)
  ; #OnOffText      - Switch with text
  ; --------------------------------------
  ; #Theme_Win11   - Theme: Tile buttons
  ; #Theme_Menue   - Theme: Tile menu
  ; #ColorThemes1  - Theme: blue/red
  ; #ColorThemes2  - Theme: green/orange
  ; ----------------------------------
  
	UsePNGImageDecoder()

	#Window = 0

	Enumeration 1 ;{ Constants
		#Button1
		#Button2
		#Button3
		#Image
		#Font10B
		#Font9I
	EndEnumeration ;}

	LoadFont(#Font10B, "Arial", 10, #PB_Font_Bold)
  LoadFont(#Font9I,  "Arial",  9, #PB_Font_Italic)
	LoadImage(#Image,  "Display.png")

	If OpenWindow(#Window, 0, 0, 520, 100, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
	  
	  Select #Example
	    Case 1
	      Tiles::Gadget(#Button1,  20, 20, 200, 40, "Tile Button",  Tiles::#Border|Tiles::#UseArrow)
	      Tiles::Gadget(#Button2, 230, 20, 260, 50, "Button Title", Tiles::#Border|Tiles::#Left|Tiles::#UseArrow)
	    Case 2
	      Tiles::Gadget(#Button1,  20, 20, 200, 40, "Tile Button",  Tiles::#Border|Tiles::#ToggleBar)
	      Tiles::Gadget(#Button2, 240, 20, 260, 50, "Button Title", Tiles::#Border|Tiles::#ToggleBar|Tiles::#Left)
	    Case 3
	      Tiles::Gadget(#Button1,  20, 20, 200, 40, "Tile Button",  Tiles::#Border|Tiles::#Toggle)
	      Tiles::Gadget(#Button2, 240, 20, 260, 50, "Button Title", Tiles::#Border|Tiles::#Left|Tiles::#Toggle)
	    Case 4
	      Tiles::Gadget(#Button1,  20, 20, 200, 40, "Tile Button",  Tiles::#Border|Tiles::#UseSwitch)
	      Tiles::Gadget(#Button2, 240, 20, 260, 50, "Button Title", Tiles::#Border|Tiles::#Left|Tiles::#UseSwitch)  
	    Default 
	      Tiles::Gadget(#Button1,  20, 20, 200, 40, "Tile Button",  Tiles::#Border)
	      Tiles::Gadget(#Button2, 240, 20, 260, 50, "Button Title", Tiles::#Border|Tiles::#Left) 
	  EndSelect
	  
	  Tiles::Disable(#Button1, #True)
	  
	  Tiles::SetFont(#Button1, #Font10B)
	  
	  Tiles::SetText(#Button2, "Description of the button", Tiles::#Description)
	  Tiles::SetFont(#Button2, #Font10B)
		Tiles::SetFont(#Button2, #Font9I, Tiles::#Description)
		
		If #Functions & #ImageLeft
		  Tiles::AddImage(#Button2, #Image)
		EndIf  
		
		If #Functions & #ImageRight
		  Tiles::AddImage(#Button2, #Image, Tiles::#Right)
		EndIf
		
		If #Functions & #ImageSpacing
		  Tiles::SetAttribute(#Button2, Tiles::#ImageSpacing, 20)
		EndIf  
		
		If #Functions & #ToggleBarAlign
		  Tiles::SetAttribute(#Button1, Tiles::#ToggleAlign, Tiles::#Bottom)
		  Tiles::SetAttribute(#Button2, Tiles::#ToggleAlign, Tiles::#Right)
		EndIf  
		
		If #Functions & #OnOffText
		  Tiles::SetText(#Button1, "On|Off", Tiles::#Switch)
		EndIf  
		
	  If #Functions & #Theme_Win11
	    Tiles::SetColorTheme(#Button1, Tiles::#Theme_Win11)
	    Tiles::SetColorTheme(#Button2, Tiles::#Theme_Win11)
	  ElseIf #Functions & #Theme_Menue
	    Tiles::SetColorTheme(#Button1, Tiles::#Theme_Menue)
	    Tiles::SetColorTheme(#Button2, Tiles::#Theme_Win11)  
	  ElseIf #Functions & #ColorThemes1
	    Tiles::SetColorTheme(#Button1, Tiles::#Theme_Blue)
	    Tiles::SetColorTheme(#Button2, Tiles::#Theme_Red)
	  ElseIf #Functions & #ColorThemes2
	    Tiles::SetColorTheme(#Button1, Tiles::#Theme_Green)
	    Tiles::SetColorTheme(#Button2, Tiles::#Theme_Orange)
	  EndIf
	  
	  If #Functions & #CombineToggle
	    Tiles::CombineToggle(#Button1, "Toggle")
	    Tiles::CombineToggle(#Button2, "Toggle")
	  EndIf
	  
		Repeat
			Event = WaitWindowEvent()
			Select Event
				Case Tiles::#Event_Gadget ; works with or without EventType()
				  Select EventGadget() 
				    Case #Button2
				      If EventType() = Tiles::#EventType_Switch
				        Debug "#Button2 - Switch: " + Str(EventData())
				      Else  
				        Debug "#Button2 pressed"
				      EndIf  
					EndSelect
				Case #PB_Event_Gadget
					Select EventGadget()
						Case #Button1 ; only in use with EventType()
						  If EventType() = Tiles::#EventType_Button
						    If #Example = 4
						      Debug "#Button1 - Switch: " + Str(Tiles::GetState(#Button1, Tiles::#Switch))
						    Else  
						      Debug "#Button1 pressed"
						    EndIf   
							EndIf
					EndSelect
			EndSelect
		Until Event = #PB_Event_CloseWindow

		CloseWindow(#Window)
	EndIf

CompilerEndIf
; IDE Options = PureBasic 6.00 Beta 10 (Windows - x64)
; CursorPosition = 11
; Folding = IABAAAAEgDAAAAAAAAAk
; EnableXP
; DPIAware