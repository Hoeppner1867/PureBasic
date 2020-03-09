;/ ==============================
;/ =    SpinExModule.pbi    =
;/ ==============================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2020 Thorsten1867 (03/2020)
;/

; Last Update: 07.03.2020
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


;{ _____ SpinEx - Commands _____

; SpinEx::AddItem()            - similar to 'AddGadgetItem()'
; SpinEx::AttachPopupMenu()    - attach a popup menu to the list
; SpinEx::Copy()               - copy selection to clipboard
; SpinEx::Cut()                - cut selection to clipboard
; SpinEx::Delete()             - delete selection
; SpinEx::ClearItems()         - similar to 'ClearGadgetItems()'
; SpinEx::CountItems()         - similar to 'CountGadgetItems()'
; SpinEx::Disable()            - similar to 'DisableGadget()'
; SpinEx::GetData()            - similar to 'GetGadgetData()'
; SpinEx::GetID()              - similar to 'GetGadgetData()', but string instead of quad
; SpinEx::GetColor()           - similar to 'GetGadgetColor()'
; SpinEx::GetItemData()        - similar to 'GetGadgetItemData()'
; SpinEx::GetItemLabel()       - similar to 'GetGadgetItemData()', but string instead of quad
; SpinEx::GetItemText()        - similar to 'GetGadgetItemText()'
; SpinEx::GetLabelText()       - similar to 'GetGadgetItemText()', but label instead of row
; SpinEx::GetState()           - similar to 'GetGadgetState()'
; SpinEx::GetText()            - similar to 'GetGadgetText()'
; SpinEx::Gadget()             - similar to 'ComboBoxGadget()'
; SpinEx::Hide()               - similar to 'HideGadget()'
; SpinEx::Paste()              - paste clipboard
; SpinEx::RemoveItem()         - similar to 'RemoveGadgetItem()'
; SpinEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; SpinEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; SpinEx::SetColor()           - similar to 'SetGadgetColor()'
; SpinEx::SetData()            - similar to 'SetGadgetData()'
; SpinEx::SetFont()            - similar to 'SetGadgetFont()'
; SpinEx::SetID()              - similar to 'SetGadgetData()', but string instead of quad
; SpinEx::SetItemColor()       - similar to 'SetGadgetItemColor()'
; SpinEx::SetItemData()        - similar to 'SetGadgetItemData()'
; SpinEx::SetItemText()        - similar to 'SetGadgetItemText()'
; SpinEx::SetLabelText()       - similar to 'SetGadgetItemText()', but label instead of row
; SpinEx::SetState()           - similar to 'SetGadgetState()'
; SpinEx::SetText()            - similar to 'SetGadgetText()'

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule SpinEx
  
  #Version  = 20030700
  #ModuleEx = 19112600
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #FirstItem = 0
  #LastItem  = -1
  
  EnumerationBinary ;{ Gadget Flags
    #Borderless
    #NoButtons
    #Editable
    #UpperCase
    #LowerCase
    #AutoResize
    #Left
    #Right
    #Center
    #UseExistingCanvas    
  EndEnumeration ;}
  
  Enumeration 1     ;{ Attribute
    #MaximumLength = #PB_String_MaximumLength
    #Padding
    #Corner
    #Minimum
    #Maximum
  EndEnumeration ;}
  
  Enumeration 1     ;{ Color
    #FrontColor  = #PB_Gadget_FrontColor
    #BackColor   = #PB_Gadget_BackColor
    #BorderColor = #PB_Gadget_LineColor
    #FocusBackColor
    #FocusTextColor
    #CursorColor
    #HighlightColor
    #HighlightTextColor
  EndEnumeration ;}
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Cursor        = ModuleEx::#Event_Cursor
    #Event_Gadget        = ModuleEx::#Event_Gadget
    #Event_Theme         = ModuleEx::#Event_Theme
    #Event_Timer         = ModuleEx::#Event_Timer
    
    #EventType_Focus     = ModuleEx::#EventType_Focus
    #EventType_LostFocus = ModuleEx::#EventType_LostFocus
    #EventType_Change    = ModuleEx::#EventType_Change
    #EventType_Button    = ModuleEx::#EventType_Button
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
      #Event_Gadget
      #Event_Timer
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Button
      #EventType_Focus
      #EventType_LostFocus
      #EventType_Change
    EndEnumeration
    
  CompilerEndIf

  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Flags.i=#False)
  Declare   AttachPopupMenu(GNum.i, MenuNum.i)
  Declare   Copy(GNum.i)
  Declare   Cut(GNum.i)
  Declare   Delete(GNum.i)
  Declare   ClearItems(GNum.i)
  Declare.i CountItems(GNum.i)
  Declare   Disable(GNum.i, State.i=#True)
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare.i GetColor(GNum.i, ColorType.i)
  Declare.q GetItemData(GNum.i, Row.i)
  Declare.s GetItemLabel(GNum.i, Row.i)
  Declare.s GetItemText(GNum.i, Row.i)
  Declare.s GetLabelText(GNum.i, Label.s)
  Declare.i GetState(GNum.i)
  Declare.s GetText(GNum.i) 
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, maxListHeight.i, Content.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   Paste(GNum.i)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontNum.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetItemColor(GNum.i, Row.i, Color.i)
  Declare   SetItemData(GNum.i, Row.i, Value.q)
  Declare   SetItemText(GNum.i, Row.i, Text.s, Flags.i=#False)
  Declare   SetLabelText(GNum.i, Label.s, Text.s, Flags.i=#False)
  Declare   SetState(GNum.i, State.i)
  Declare   SetText(GNum.i, Text.s) 

EndDeclareModule

Module SpinEx
  
  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================
  
  #ButtonWidth = 18
  
  #Up   = 1
  #Down = 2
  
  #CursorFrequency = 600

  EnumerationBinary State
    #Focus
    #Edit
    #Click
  EndEnumeration
  
  Enumeration Mouse
    #Mouse_Move
    #Mouse_Select
  EndEnumeration 
  
  Enumeration Selection
    #NoSelection
    #Selected
  EndEnumeration
  
  #Cursor = 1
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
 
  Structure Cursor_Thread_Structure          ;{ Thread\...
    Num.i
    Active.i
    Exit.i
  EndStructure ;}  
  Global Thread.Cursor_Thread_Structure

  Structure Selection_Structure              ;{ SpinEx()\Selection\
    Pos1.i
    Pos2.i
    Flag.i
  EndStructure ;}

  Structure SpinEx_Button_Structure         ;{ SpinEx()\Button\...
    X.i
    Y.i
    Up.i
    Down.i
    Width.f
    Height.f
    Event.i
  EndStructure ;}  
  
  Structure SpinEx_Item_Structure           ;{ SpinEx()\Item()\...
    ID.s
    Quad.q
    String.s
    Color.i
    Flags.i
  EndStructure ;}
  
  Structure SpinEx_Cursor_Structure         ;{ SpinEx()\Cursor\...
    Pos.i ; 0: "|abc" / 1: "a|bc" / 2: "ab|c"  / 3: "abc|"
    X.i
    Y.i
    Height.i
    State.i
    Frequency.i
    Elapsed.i
    Thread.i
    Pause.i
  EndStructure ;}
  
  Structure SpinEx_Color_Structure          ;{ SpinEx()\Color\...
    Front.i
    Back.i
    FocusText.i
    FocusBack.i
    Border.i
    Cursor.i
    Gadget.i
    CheckBox.i
    DisableFront.i
    DisableBack.i
    Highlight.i
    HighlightText.i
    Button.i
    WordColor.i
  EndStructure ;}
  
  Structure SpinEx_Size_Structure           ;{ SpinEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Text.i
    Flags.i
  EndStructure ;} 
  
  Structure SpinEx_Window_Structure         ;{ SpinEx()\Window\...
    Num.i
    Width.i
    Height.i
  EndStructure ;}
  
  Structure SpinEx_Structure                ;{ SpinEx()\...
    CanvasNum.i
    PopupNum.i
    
    Thread.i
    
    ID.s
    Quad.q
    
    FontID.i
    
    Text.s
    
    Focus.i
    State.i
    
    Minimum.i
    Maximum.i
    
    OffSetX.i
    Mouse.i
    CanvasCursor.i
    Padding.i
    Radius.i
    Disable.i
    Hide.i

    Flags.i

    Button.SpinEx_Button_Structure    
    Color.SpinEx_Color_Structure
    Cursor.SpinEx_Cursor_Structure
    Selection.Selection_Structure
    Size.SpinEx_Size_Structure
    Window.SpinEx_Window_Structure
    
    Map  Index.i()
    List Item.SpinEx_Item_Structure()
    
  EndStructure ;}
  Global NewMap SpinEx.SpinEx_Structure()
  
  
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
	
	
  Procedure.s DeleteStringPart_(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf

    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure

  Procedure.s StringSegment_(String.s, Pos1.i, Pos2.i=#PB_Ignore) ; Return String from Pos1 to Pos2 
    Define.i Length = Pos2 - Pos1
    If Pos2 = #PB_Ignore
      ProcedureReturn Mid(String, Pos1, Len(String) - Pos1 + 1)
    Else
      ProcedureReturn Mid(String, Pos1, Pos2 - Pos1 + 1)
    EndIf
  EndProcedure 
  
  
  Procedure   RemoveSelection_()                                  ; Remove & Reset selection 
    SpinEx()\Selection\Pos1 = #False
    SpinEx()\Selection\Pos2 = #False
    SpinEx()\Selection\Flag = #NoSelection
  EndProcedure
  
  Procedure   DeleteSelection_() 
    
    If SpinEx()\Selection\Flag = #Selected
      
      If SpinEx()\Selection\Pos1 > SpinEx()\Selection\Pos2
        SpinEx()\Text = Left(SpinEx()\Text, SpinEx()\Selection\Pos2) + Mid(SpinEx()\Text, SpinEx()\Selection\Pos1 + 1)
        SpinEx()\Cursor\Pos = SpinEx()\Selection\Pos2
      Else
        SpinEx()\Text = Left(SpinEx()\Text, SpinEx()\Selection\Pos1) + Mid(SpinEx()\Text, SpinEx()\Selection\Pos2 + 1)
        SpinEx()\Cursor\Pos = SpinEx()\Selection\Pos1
      EndIf  
      
      RemoveSelection_() 
    EndIf
    
  EndProcedure
  
  
  Procedure   Copy_()
    Define.s Text
    
    If SpinEx()\Selection\Pos1 > SpinEx()\Selection\Pos2
      Text = StringSegment_(SpinEx()\Text, SpinEx()\Selection\Pos2 + 1, SpinEx()\Selection\Pos1)
    Else
      Text = StringSegment_(SpinEx()\Text, SpinEx()\Selection\Pos1 + 1, SpinEx()\Selection\Pos2)
    EndIf
    
    SetClipboardText(Text)
    RemoveSelection_()
    
  EndProcedure
  
  Procedure   Cut_()
    Define.s Text
    
    If SpinEx()\Flags & #Editable
      
      If SpinEx()\Selection\Pos1 > SpinEx()\Selection\Pos2
        Text = StringSegment_(SpinEx()\Text, SpinEx()\Selection\Pos2 + 1, SpinEx()\Selection\Pos1)
      Else
        Text = StringSegment_(SpinEx()\Text, SpinEx()\Selection\Pos1 + 1, SpinEx()\Selection\Pos2)
      EndIf
    
      SetClipboardText(Text)
      DeleteSelection_()
      RemoveSelection_()
      
    EndIf

  EndProcedure
  
  Procedure   Paste_()
    Define.i c
    Define.s Text, Num, Char
    
    If SpinEx()\Flags & #Editable

      Text = GetClipboardText()

      If SpinEx()\Flags & #UpperCase : Text = UCase(Text) : EndIf
      If SpinEx()\Flags & #LowerCase : Text = LCase(Text) : EndIf
      
      If SpinEx()\Selection\Flag = #Selected
        DeleteSelection_()
        RemoveSelection_()
      EndIf
      
      SpinEx()\Text = InsertString(SpinEx()\Text, Text, SpinEx()\Cursor\Pos + 1)
      SpinEx()\Cursor\Pos + Len(Text)

    EndIf
    
  EndProcedure

  Procedure.i CursorPos_(CursorX.i)
    Define.s Text
    Define.i p, Pos.i

    If CursorX >= SpinEx()\OffSetX
      
      Text = SpinEx()\Text

      If StartDrawing(CanvasOutput(SpinEx()\CanvasNum))
        DrawingFont(SpinEx()\FontID)
        For p=1 To Len(Text)
          Pos = p
          If SpinEx()\OffSetX + TextWidth(Left(Text, p)) >= CursorX
            Break
          EndIf
        Next
        StopDrawing()
      EndIf
      
      ProcedureReturn Pos
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure.f CursorX_(CursorPos.i) ; [ Needs StartDrawing() ]
    ; Pos 0: '|abc' / Pos1: 'a|bc'
    Define.s Text
    
    Text = SpinEx()\Text
    
    If CursorPos > 0
      ProcedureReturn TextWidth(Left(Text, CursorPos))
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  
  Procedure.i GetWordStart_(Pos.i) 
    Define.i p
    
    For p = Pos To 0 Step -1
      If Mid(SpinEx()\Text, p, 1) = " "
        ProcedureReturn p
      EndIf
    Next
    
    ProcedureReturn 0
  EndProcedure  
  
  Procedure.i GetWordEnd_(Pos.i) 
    Define.i p
    
    For p = Pos To Len(SpinEx()\Text)
      If Mid(SpinEx()\Text, p, 1) = " "
        ProcedureReturn p - 1
      EndIf
    Next
    
    ProcedureReturn Len(SpinEx()\Text)
  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure.f GetOffsetX_(Text.s, Width.i, OffsetX.i) 
    
    If SpinEx()\Flags & #Center
      ProcedureReturn (Width - TextWidth(Text)) / 2
    ElseIf SpinEx()\Flags & #Right
      ProcedureReturn Width - TextWidth(Text) - OffsetX
    Else
      ProcedureReturn OffsetX
    EndIf
 
  EndProcedure
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure

  Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i)
    
    If SpinEx()\Radius
      Box(X, Y, Width, Height, SpinEx()\Color\Gadget)
			RoundBox(X, Y, Width, Height, SpinEx()\Radius, SpinEx()\Radius, Color)
		Else
			Box(X, Y, Width, Height, Color)
		EndIf
		
	EndProcedure  

	Procedure   DrawArrow_(Type.i, X.i, Y.i, Width.i, Height.i, Color.i)
	  Define.i aWidth, aHeight, aColor, bHeight, OffsetY

	  If StartVectorDrawing(CanvasVectorOutput(SpinEx()\CanvasNum))

      aColor  = RGBA(Red(Color), Green(Color), Blue(Color), 255)
      
  	  aWidth  = dpiX(6)
  	  aHeight = dpiX(3)
  	  
  	  bHeight = Height / 2
  	  
      X + ((Width  - aWidth) / 2)

      Select Type
        Case #Up
          Y + ((bHeight - aHeight) / 2) + dpiY(1)
          MovePathCursor(X, Y + aHeight)
          AddPathLine(X + aWidth / 2, Y)
          AddPathLine(X + aWidth, Y + aHeight)
        Case #Down 
           Y + ((bHeight - aHeight) / 2) - dpiY(1)
          MovePathCursor(X, Y + bHeight)
          AddPathLine(X + aWidth / 2, Y + aHeight + bHeight)
          AddPathLine(X + aWidth, Y + bHeight)
      EndSelect
      
      VectorSourceColor(aColor)
      StrokePath(1, #PB_Path_RoundCorner)

	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure

	Procedure   Button_(Type.i=#False)
	  Define.i BackColor
	  
	  If SpinEx()\Hide : ProcedureReturn #False : EndIf
	  
	  If SpinEx()\Flags & #Editable
	    BackColor = SpinEx()\Color\Back
	  Else
	    BackColor = SpinEx()\Color\Button
	  EndIf
	  
    DrawingMode(#PB_2DDrawing_Default)
    If SpinEx()\Button\Up & #Click
      Box_(SpinEx()\Button\X, dpiY(1), SpinEx()\Button\Width, SpinEx()\Button\Height, BlendColor_(SpinEx()\Color\FocusBack, BackColor, 20))
    ElseIf SpinEx()\Button\Down & #Click
      Box_(SpinEx()\Button\X, SpinEx()\Button\Y, SpinEx()\Button\Width, SpinEx()\Button\Height, BlendColor_(SpinEx()\Color\FocusBack, BackColor, 20))
    ElseIf SpinEx()\Button\Up & #Focus
      Box_(SpinEx()\Button\X, dpiY(1), SpinEx()\Button\Width, SpinEx()\Button\Height, BlendColor_(SpinEx()\Color\FocusBack, BackColor, 10))
    ElseIf SpinEx()\Button\Down & #Focus  
      Box_(SpinEx()\Button\X, SpinEx()\Button\Y, SpinEx()\Button\Width, SpinEx()\Button\Height, BlendColor_(SpinEx()\Color\FocusBack, BackColor, 10))
    Else
      Box_(SpinEx()\Button\X, dpiY(1), SpinEx()\Button\Width, GadgetHeight(SpinEx()\CanvasNum) - dpiY(2), BackColor)
    EndIf  
  EndProcedure

  Procedure   Draw_()
    Define.i X, Y, Height, Width, startX, CursorX
    Define.s Text, Word, strgPart
    Define.i p, FrontColor, BackColor, BorderColor, CursorColor, Color
    
    If SpinEx()\Hide : ProcedureReturn #False : EndIf

    If StartDrawing(CanvasOutput(SpinEx()\CanvasNum))
      
      FrontColor  = SpinEx()\Color\Front
      BorderColor = SpinEx()\Color\Border
      
      If SpinEx()\Flags & #Editable
        BackColor = SpinEx()\Color\Back
      Else
        BackColor = SpinEx()\Color\Button
      EndIf

      If SpinEx()\Focus : BorderColor = BlendColor_(SpinEx()\Color\FocusBack, SpinEx()\Color\Border, 90)  : EndIf
      
      If SpinEx()\Disable
        FrontColor  = SpinEx()\Color\DisableFront
        BackColor   = BlendColor_(SpinEx()\Color\DisableBack, SpinEx()\Color\Gadget, 10)
        BorderColor = SpinEx()\Color\DisableBack
      EndIf  

      Height = dpiY(GadgetHeight(SpinEx()\CanvasNum))
      Width  = dpiX(GadgetWidth(SpinEx()\CanvasNum))

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(0, 0, Width, Height, BackColor)   
      ;}
      
      SpinEx()\Button\X      = Width - dpiX(#ButtonWidth) - dpiX(1)
      SpinEx()\Button\Y      = (Height / 2) - dpiY(1)
      SpinEx()\Button\Width  = dpiX(#ButtonWidth)
      SpinEx()\Button\Height = Height / 2
      
      If Not SpinEx()\Flags & #NoButtons
        Width - SpinEx()\Button\Width - dpiX(3)
      EndIf
      
      SpinEx()\Size\Text = Width

      DrawingFont(SpinEx()\FontID)

      ;{ _____ Text _____
      If SpinEx()\Text
        
        Text = SpinEx()\Text

        X = GetOffsetX_(Text, Width, dpiX(SpinEx()\Padding))
        Y = (Height - TextHeight(Text)) / 2
        
        ;{ TextWidth > Width
        If SpinEx()\Flags & #Editable
        
          CursorX = X + TextWidth(Left(Text, SpinEx()\Cursor\Pos))
          If CursorX > Width
            Text = Left(Text, SpinEx()\Cursor\Pos)
            For p = Len(Text) To 0 Step -1
              If X + TextWidth(Right(Text, p)) < Width
                Text = Right(Text, p)
                Break  
              EndIf 
            Next 
          EndIf
          
        Else
          
          CursorX = X + TextWidth(Text)
          If CursorX > Width
            For p = Len(Text) To 0 Step -1
              If X + TextWidth(Right(Text, p)) <= Width
                Text = Right(Text, p)
                Break  
              EndIf 
            Next 
          EndIf
          
        EndIf ;}
        
        DrawingMode(#PB_2DDrawing_Transparent)
        
        If SpinEx()\Item()\Color <> #PB_Default
          DrawText(X, Y, Text, SpinEx()\Item()\Color)
        Else
          DrawText(X, Y, Text, FrontColor)
        EndIf  
        
        SpinEx()\OffSetX = X

      Else
        
        If SpinEx()\Flags & #Center
          X = Width / 2
        ElseIf SpinEx()\Flags & #Right
          X = Width - dpiX(SpinEx()\Padding)
        Else
          X = dpiX(SpinEx()\Padding)
        EndIf
        
        Y = (Height - TextHeight("X")) / 2  
        
      EndIf
      ;}
      
      ;{ _____ Selection ______
      If SpinEx()\Flags & #Editable
        
        If SpinEx()\Selection\Flag = #Selected
          
          If SpinEx()\Selection\Pos1 >  SpinEx()\Selection\Pos2
            startX   = CursorX_(SpinEx()\Selection\Pos2)
            strgPart = StringSegment_(Text, SpinEx()\Selection\Pos2 + 1, SpinEx()\Selection\Pos1)
          Else
            startX   = CursorX_(SpinEx()\Selection\Pos1)
            strgPart = StringSegment_(Text, SpinEx()\Selection\Pos1 + 1, SpinEx()\Selection\Pos2)
          EndIf
          
          SpinEx()\Cursor\Pos = SpinEx()\Selection\Pos2
          
          DrawingMode(#PB_2DDrawing_Default)
          DrawText(X + startX, Y, strgPart, SpinEx()\Color\HighlightText, SpinEx()\Color\Highlight)
  
        EndIf
        
      EndIf ;}
      
      ;{ _____ Cursor _____
      If SpinEx()\Flags & #Editable
        
        If SpinEx()\Cursor\Pos
          X + TextWidth(Left(Text, SpinEx()\Cursor\Pos))
        EndIf
        SpinEx()\Cursor\Height = TextHeight("X")
        SpinEx()\Cursor\X = X
        SpinEx()\Cursor\Y = Y
        If SpinEx()\Cursor\Pause = #False
          Line(SpinEx()\Cursor\X, SpinEx()\Cursor\Y, 1, SpinEx()\Cursor\Height, SpinEx()\Color\Cursor)
        EndIf
        
      EndIf
      ;}
      
      If Not SpinEx()\Flags & #NoButtons :  Button_() : EndIf

      ;{ _____ Border ____
      If Not SpinEx()\Flags & #Borderless
        DrawingMode(#PB_2DDrawing_Outlined)
        Box_(0, 0, dpiX(GadgetWidth(SpinEx()\CanvasNum)), Height, BorderColor)
      EndIf
      ;}

      StopDrawing()
    EndIf
    
    If Not SpinEx()\Flags & #NoButtons
      DrawArrow_(#Up,   SpinEx()\Button\X, 0, SpinEx()\Button\Width, Height, SpinEx()\Color\Front)
      DrawArrow_(#Down, SpinEx()\Button\X, 0, SpinEx()\Button\Width, Height, SpinEx()\Color\Front)
    EndIf
  
  EndProcedure

  ;- __________ Events __________
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach SpinEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          SpinEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf

        SpinEx()\Color\Front         = ModuleEx::ThemeGUI\FrontColor
        SpinEx()\Color\Back          = ModuleEx::ThemeGUI\BackColor
        SpinEx()\Color\FocusText     = ModuleEx::ThemeGUI\Focus\FrontColor
        SpinEx()\Color\FocusBack     = ModuleEx::ThemeGUI\Focus\BackColor
        SpinEx()\Color\Border        = ModuleEx::ThemeGUI\BorderColor
        SpinEx()\Color\Gadget        = ModuleEx::ThemeGUI\GadgetColor
        SpinEx()\Color\Cursor        = ModuleEx::ThemeGUI\FrontColor
        SpinEx()\Color\Button        = ModuleEx::ThemeGUI\Button\BackColor
        SpinEx()\Color\HighlightText = ModuleEx::ThemeGUI\Focus\FrontColor
        SpinEx()\Color\Highlight     = ModuleEx::ThemeGUI\Focus\BackColor
        SpinEx()\Color\DisableFront  = ModuleEx::ThemeGUI\Disable\FrontColor
        SpinEx()\Color\DisableBack   = ModuleEx::ThemeGUI\Disable\BackColor

        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf   

  Procedure _CursorThread(Frequency.i)
    Define.i ElapsedTime
    
    Repeat
      
      If ElapsedTime >= Frequency
        PostEvent(#Event_Cursor)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until Thread\Exit
    
  EndProcedure  
  
  Procedure _CursorDrawing() ; Trigger from Thread (PostEvent Change)
    Define.i BackColor
    Define.i WindowNum = EventWindow()

    ForEach SpinEx()
      
      BackColor = SpinEx()\Color\Back
      If SpinEx()\Disable : BackColor = BlendColor_(SpinEx()\Color\DisableBack, SpinEx()\Color\Gadget, 10) : EndIf
      
      If SpinEx()\Cursor\Pause = #False

        SpinEx()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(SpinEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          If SpinEx()\Cursor\State
            Line(SpinEx()\Cursor\X, SpinEx()\Cursor\Y, 1, SpinEx()\Cursor\Height, SpinEx()\Color\Cursor)
          Else
            Line(SpinEx()\Cursor\X, SpinEx()\Cursor\Y, 1, SpinEx()\Cursor\Height, BackColor)
          EndIf
          StopDrawing()
        EndIf
        
      ElseIf SpinEx()\Cursor\State

        If StartDrawing(CanvasOutput(SpinEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          Line(SpinEx()\Cursor\X - 1, SpinEx()\Cursor\Y, 1, SpinEx()\Cursor\Height, BackColor)
          StopDrawing()
        EndIf
      
      EndIf
      
    Next
    
  EndProcedure  
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      SpinEx()\Focus = #True
      
      If SpinEx()\Flags & #Editable
        SpinEx()\Cursor\State = #False
        SpinEx()\Cursor\Pause = #False
      EndIf
      
      Draw_()
      
      PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Focus)

    EndIf
    
  EndProcedure  
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      SpinEx()\Focus = #False
      
      SpinEx()\Button\Up   & ~#Focus
      SpinEx()\Button\Down & ~#Focus
      
      If SpinEx()\Flags & #Editable
        SpinEx()\Cursor\Pause = #True
        
      EndIf  

      Draw_()
      
      PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_LostFocus)
    EndIf
    
  EndProcedure    
  
  
  Procedure _InputHandler()
    Define.s Char$
    Define.i Char
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))

      If SpinEx()\Focus And SpinEx()\Flags & #Editable
        
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)

        If Char >= 32
          
          If SpinEx()\Selection\Flag = #Selected
            DeleteSelection_()
          EndIf
          
          Char$ =  Chr(Char)
          If SpinEx()\Flags & #UpperCase : Char$ = UCase(Char$) : EndIf
          If SpinEx()\Flags & #LowerCase : Char$ = LCase(Char$) : EndIf
          

          SpinEx()\Cursor\Pos + 1
          SpinEx()\Text = InsertString(SpinEx()\Text, Char$, SpinEx()\Cursor\Pos)
          
          PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
  EndProcedure   
  
  Procedure _KeyDownHandler()
    Define.i Key, Modifier, Result
    Define.s Text
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      If SpinEx()\Focus
        
        Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
        Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
        Debug Key
        Select Key
          Case #PB_Shortcut_Up        ;{ Cursor up
            Debug "UP"
            If ListSize(SpinEx()\Item())
              Result = PreviousElement(SpinEx()\Item())
              If Result = #False : Result = FirstElement(SpinEx()\Item()) : EndIf
              If Result
                SpinEx()\Text = SpinEx()\Item()\String
                PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
                PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
              EndIf
            Else
              SpinEx()\State - 1
              If SpinEx()\State < SpinEx()\Minimum : SpinEx()\State = SpinEx()\Minimum : EndIf 
              SpinEx()\Text = Str(SpinEx()\State)
              PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
              PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
            EndIf
            ;}
          Case #PB_Shortcut_Down      ;{ Cursor down
            Debug "Down"
            If ListSize(SpinEx()\Item())
              Result = NextElement(SpinEx()\Item())
              If Result = #False : Result = LastElement(SpinEx()\Item()) : EndIf  
              If Result
                SpinEx()\Text = SpinEx()\Item()\String
                PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
                PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
              EndIf 
            Else
              SpinEx()\State + 1
              If SpinEx()\State > SpinEx()\Maximum : SpinEx()\State = SpinEx()\Maximum : EndIf 
              SpinEx()\Text = Str(SpinEx()\State)
              PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
              PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
            EndIf
            ;}
          Case #PB_Shortcut_Left      ;{ Cursor left
            If Modifier & #PB_Canvas_Shift
              
              If SpinEx()\Selection\Flag = #NoSelection
                SpinEx()\Selection\Pos1 = SpinEx()\Cursor\Pos
                SpinEx()\Selection\Pos2 = SpinEx()\Cursor\Pos - 1
                SpinEx()\Selection\Flag = #Selected
              Else
                SpinEx()\Selection\Pos2 - 1
                SpinEx()\Selection\Flag = #Selected
              EndIf
              
              If SpinEx()\Cursor\Pos > 0
                SpinEx()\Cursor\Pos - 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If SpinEx()\Selection\Flag = #NoSelection
                SpinEx()\Selection\Pos1 = GetWordEnd_(SpinEx()\Cursor\Pos)
                SpinEx()\Selection\Pos2 = GetWordStart_(SpinEx()\Cursor\Pos)
                SpinEx()\Selection\Flag = #Selected
              Else
                SpinEx()\Selection\Pos2 = GetWordStart_(SpinEx()\Cursor\Pos)
                SpinEx()\Selection\Flag = #Selected
              EndIf
              
            Else
              
              If SpinEx()\Cursor\Pos > 0
                SpinEx()\Cursor\Pos - 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_Right     ;{ Cursor right
            If Modifier & #PB_Canvas_Shift
              
              If SpinEx()\Selection\Flag = #NoSelection
                SpinEx()\Selection\Pos1 = SpinEx()\Cursor\Pos
                SpinEx()\Selection\Pos2 = SpinEx()\Cursor\Pos + 1
                SpinEx()\Selection\Flag = #Selected
              Else
                SpinEx()\Selection\Pos2 + 1
                SpinEx()\Selection\Flag = #Selected
              EndIf
              
              If SpinEx()\Cursor\Pos < Len(SpinEx()\Text)
                SpinEx()\Cursor\Pos + 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If SpinEx()\Selection\Flag = #NoSelection
                SpinEx()\Selection\Pos1 = GetWordStart_(SpinEx()\Cursor\Pos)
                SpinEx()\Selection\Pos2 = GetWordEnd_(SpinEx()\Cursor\Pos)
                SpinEx()\Selection\Flag = #Selected
              Else
                SpinEx()\Selection\Pos2 = GetWordEnd_(SpinEx()\Cursor\Pos)
                SpinEx()\Selection\Flag = #Selected
              EndIf
              
            Else

              If SpinEx()\Cursor\Pos < Len(SpinEx()\Text)
                SpinEx()\Cursor\Pos + 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_End       ;{ Cursor end of chars
            SpinEx()\Cursor\Pos = Len(SpinEx()\Text)
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Home      ;{ Cursor position 0
            SpinEx()\Cursor\Pos = 0
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Back      ;{ Delete Back
            If SpinEx()\Flags & #Editable
              If SpinEx()\Selection\Flag = #Selected
                DeleteSelection_()
                RemoveSelection_()
              Else
                If SpinEx()\Cursor\Pos > 0
                  SpinEx()\Text = DeleteStringPart_(SpinEx()\Text, SpinEx()\Cursor\Pos) 
                  SpinEx()\Cursor\Pos - 1
                EndIf
                RemoveSelection_()
              EndIf 
              PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
            EndIf ;}
          Case #PB_Shortcut_Delete    ;{ Delete / Cut (Shift)
            If Modifier & #PB_Canvas_Shift ;{ Cut selected text
              Cut_()
              ;}
            Else                           ;{ Delete text
              If SpinEx()\Flags & #Editable
                If SpinEx()\Selection\Flag = #Selected
                  DeleteSelection_()
                  RemoveSelection_()
                Else
                  If SpinEx()\Cursor\Pos < Len(SpinEx()\Text) 
                    SpinEx()\Text = DeleteStringPart_(SpinEx()\Text, SpinEx()\Cursor\Pos + 1)
                    RemoveSelection_()
                  EndIf
                EndIf
              EndIf ;}
            EndIf
            PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
            ;} 
          Case #PB_Shortcut_Insert    ;{ Copy (Ctrl) / Paste (Shift)
            If Modifier & #PB_Canvas_Shift
              Paste_()
              PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
            ElseIf Modifier & #PB_Canvas_Control
              Copy_()
            EndIf ;}  
          Case #PB_Shortcut_A         ;{ Ctrl-A (Select all)
            If Modifier & #PB_Canvas_Control
              SpinEx()\Cursor\Pos = Len(SpinEx()\Text)
              SpinEx()\Selection\Pos1 = 0
              SpinEx()\Selection\Pos2 = SpinEx()\Cursor\Pos
              SpinEx()\Selection\Flag = #Selected
            EndIf ;}
          Case #PB_Shortcut_C         ;{ Copy   (Ctrl)  
            If Modifier & #PB_Canvas_Control
              Copy_()
            EndIf  
            ;}
          Case #PB_Shortcut_X         ;{ Cut    (Ctrl) 
            If Modifier & #PB_Canvas_Control
              Cut_()
              PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
            EndIf
            ;}
          Case #PB_Shortcut_D         ;{ Ctrl-D (Delete selection)
            If SpinEx()\Flags & #Editable
              If Modifier & #PB_Canvas_Control
                DeleteSelection_()
                PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
              EndIf 
            EndIf ;} 
          Case #PB_Shortcut_V         ;{ Paste  (Ctrl) 
            If SpinEx()\Flags & #Editable
              If Modifier & #PB_Canvas_Control
                Paste_()
                PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
              EndIf
            EndIf ;} 
          Case #PB_Shortcut_Return    ;{ Return

            ;}
          Case #PB_Shortcut_Tab       ;{ Tabulator
 
            ;}
        EndSelect
        
       Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure _RightClickHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      If IsWindow(SpinEx()\Window\Num)
        DisplayPopupMenu(SpinEx()\PopupNum, WindowID(SpinEx()\Window\Num))
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonDownHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If SpinEx()\Flags & #Editable 
        
        If X < SpinEx()\Button\X Or SpinEx()\Flags & #NoButtons
          
          SpinEx()\Cursor\Pause = #False
          
          If SpinEx()\Mouse = #Mouse_Move
            SpinEx()\Cursor\Pos = CursorPos_(X)
          EndIf
          
        Else  
          SpinEx()\Cursor\Pause = #True
        EndIf
      
      EndIf

      If SpinEx()\Button\Up & #Focus
        SpinEx()\Button\Up | #Click
      ElseIf SpinEx()\Button\Down & #Focus
        SpinEx()\Button\Down | #Click
      EndIf
      
      If SpinEx()\Selection\Flag = #Selected
        RemoveSelection_()
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftButtonUpHandler()
    Define.i X, Y, Result 
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      If X > SpinEx()\Button\X And SpinEx()\Flags & #NoButtons = #False ;{ Buttons
        
        If Y > SpinEx()\Button\Y
          
          If ListSize(SpinEx()\Item())
            Result = NextElement(SpinEx()\Item())
            If Result = #False : Result = LastElement(SpinEx()\Item()) : EndIf  
            If Result
              SpinEx()\Text = SpinEx()\Item()\String
              PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
              PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
            EndIf 
          Else
            SpinEx()\State + 1
            If SpinEx()\State > SpinEx()\Maximum : SpinEx()\State = SpinEx()\Maximum : EndIf 
            SpinEx()\Text = Str(SpinEx()\State)
            PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
            PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
          EndIf
          
        Else
          
          If ListSize(SpinEx()\Item())
            Result = PreviousElement(SpinEx()\Item())
            If Result = #False : Result = FirstElement(SpinEx()\Item()) : EndIf
            If Result
              SpinEx()\Text = SpinEx()\Item()\String
              PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
              PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
            EndIf
          Else
            SpinEx()\State - 1
            If SpinEx()\State < SpinEx()\Minimum : SpinEx()\State = SpinEx()\Minimum : EndIf 
            SpinEx()\Text = Str(SpinEx()\State)
            PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
            PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
          EndIf
          
        EndIf
        ;}
      ElseIf SpinEx()\Flags & #Editable

        If SpinEx()\Mouse = #Mouse_Select
          SpinEx()\Cursor\Pos     = CursorPos_(X)
          SpinEx()\Selection\Pos2 = SpinEx()\Cursor\Pos
          SpinEx()\Mouse = #Mouse_Move
        EndIf
        
      EndIf 

      SpinEx()\Button\Up   & ~#Click
      SpinEx()\Button\Down & ~#Click
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftDoubleClickHandler()
    Define.i X, Pos
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If X > SpinEx()\Button\X  And SpinEx()\Flags & #NoButtons = #False : ProcedureReturn #False : EndIf 
      
      Pos = CursorPos_(X)
      If Pos
        SpinEx()\Selection\Pos1 = GetWordStart_(Pos)
        SpinEx()\Selection\Pos2 = GetWordEnd_(Pos)
        SpinEx()\Selection\Flag = #Selected
        SpinEx()\Cursor\Pos     = SpinEx()\Selection\Pos2
      EndIf
    
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure _MouseEnterHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      If Not SpinEx()\Flags & #Editable
        SpinEx()\Button\Up   | #Focus
        SpinEx()\Button\Down | #Focus
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      SpinEx()\Button\Up   & ~#Focus
      SpinEx()\Button\Down & ~#Focus
      Draw_()
    EndIf
    
  EndProcedure  
  
  Procedure _MouseMoveHandler()
    Define.i X, Y, GNum
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GadgetNum))

      X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)

      If GetGadgetAttribute(GadgetNum, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton ;{ Left mouse button pressed
        
        If SpinEx()\Flags & #Editable
          
          Select SpinEx()\Mouse
            Case #Mouse_Move   ;{ Start selection
              If SpinEx()\Selection\Flag = #NoSelection
                SpinEx()\Selection\Pos1 = SpinEx()\Cursor\Pos
                SpinEx()\Selection\Pos2 = CursorPos_(X)
                SpinEx()\Selection\Flag = #Selected
                SpinEx()\Mouse = #Mouse_Select
                Draw_()
              EndIf ;}
            Case #Mouse_Select ;{ Continue selection
              SpinEx()\Selection\Pos2 = CursorPos_(X)
              SpinEx()\Cursor\Pos     = SpinEx()\Selection\Pos2
              Draw_() ;}
          EndSelect
          
        EndIf  
        ;}
      Else

        If X > SpinEx()\Button\X And SpinEx()\Flags & #NoButtons = #False
          
          If Y > SpinEx()\Button\Y
            SpinEx()\Button\Up   & ~#Focus
            SpinEx()\Button\Down | #Focus
          Else
            SpinEx()\Button\Up   | #Focus
            SpinEx()\Button\Down & ~#Focus
          EndIf

          If SpinEx()\CanvasCursor <> #PB_Cursor_Default
            SetGadgetAttribute(SpinEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
            SpinEx()\CanvasCursor = #PB_Cursor_Default
          EndIf
          
          SpinEx()\Cursor\Pause = #True
          
        Else
          
          SpinEx()\Button\Up   & ~#Focus
          SpinEx()\Button\Down & ~#Focus
          
          If SpinEx()\CanvasCursor <> #PB_Cursor_IBeam
            SetGadgetAttribute(SpinEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
            SpinEx()\CanvasCursor = #PB_Cursor_IBeam
          EndIf
          
        EndIf
      
        Draw_()
      EndIf 

      SpinEx()\Mouse = #Mouse_Move

    EndIf
    
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i Delta, Result
    Define.i GNum = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      Delta = GetGadgetAttribute(GNum, #PB_Canvas_WheelDelta)
      
      If Delta > 0
        
        If ListSize(SpinEx()\Item())
          Result = PreviousElement(SpinEx()\Item())
          If Result = #False : Result = FirstElement(SpinEx()\Item()) : EndIf
          If Result
            SpinEx()\Text = SpinEx()\Item()\String
            PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
            PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
          EndIf
        Else
          SpinEx()\State - 1
          If SpinEx()\State < SpinEx()\Minimum : SpinEx()\State = SpinEx()\Minimum : EndIf 
          SpinEx()\Text = Str(SpinEx()\State)
          PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
          PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Up)
        EndIf
        
        Draw_()
      ElseIf Delta < 0
        
        If ListSize(SpinEx()\Item())
          Result = NextElement(SpinEx()\Item())
          If Result = #False : Result = LastElement(SpinEx()\Item()) : EndIf  
          If Result
            SpinEx()\Text = SpinEx()\Item()\String
            PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
            PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
          EndIf 
        Else
          SpinEx()\State + 1
          If SpinEx()\State > SpinEx()\Maximum : SpinEx()\State = SpinEx()\Maximum : EndIf 
          SpinEx()\Text = Str(SpinEx()\State)
          PostEvent(#Event_Gadget,    SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
          PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change, #Down)
        EndIf
        
        Draw_()
      EndIf  

    EndIf
    
  EndProcedure  
  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(SpinEx(), Str(GadgetID))      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.i FontSize
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach SpinEx()
      
      If IsGadget(SpinEx()\CanvasNum)
        
        If SpinEx()\Flags & #AutoResize
          
          If IsWindow(SpinEx()\Window\Num)
            
            OffSetX = WindowWidth(SpinEx()\Window\Num)  - SpinEx()\Window\Width
            OffsetY = WindowHeight(SpinEx()\Window\Num) - SpinEx()\Window\Height

            If SpinEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If SpinEx()\Size\Flags & #MoveX  : X = SpinEx()\Size\X + OffSetX : EndIf
              If SpinEx()\Size\Flags & #MoveY  : Y = SpinEx()\Size\Y + OffSetY : EndIf
              If SpinEx()\Size\Flags & #Width  : Width  = SpinEx()\Size\Width  + OffSetX : EndIf
              If SpinEx()\Size\Flags & #Height : Height = SpinEx()\Size\Height + OffSetY : EndIf
              
              ResizeGadget(SpinEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(SpinEx()\CanvasNum, #PB_Ignore, #PB_Ignore, SpinEx()\Size\Width + OffSetX, SpinEx()\Size\Height + OffsetY)
            EndIf

            Draw_()
          EndIf

        EndIf
        
      EndIf
      
    Next
    
  EndProcedure  

  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach SpinEx()
     
      If SpinEx()\Window\Num = Window
        
        CompilerIf Defined(ModuleEx, #PB_Module) = #False
          If MapSize(SpinEx()) = 1
            Thread\Exit      = #True
            Delay(100)
            If IsThread(Thread\Num) : KillThread(Thread\Num) : EndIf
            Thread\Active      = #False
          EndIf
        CompilerEndIf

        DeleteMapElement(SpinEx())
        
      EndIf
      
    Next
    
  EndProcedure

  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 

	Procedure.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Flags.i=#False)
	  Define.i r, Result
	  
		If FindMapElement(SpinEx(), Str(GNum))
		  
		  ;{ Add item
      Select Row
        Case #FirstItem
          FirstElement(SpinEx()\Item())
          Result = InsertElement(SpinEx()\Item()) 
        Case #LastItem
          LastElement(SpinEx()\Item())
          Result = AddElement(SpinEx()\Item())
        Default
          If SelectElement(SpinEx()\Item(), Row)
            Result = InsertElement(SpinEx()\Item()) 
          Else
            LastElement(SpinEx()\Item())
            Result = AddElement(SpinEx()\Item())
          EndIf
      EndSelect ;}
   
      If Result

		    SpinEx()\Item()\ID       = Label
		    SpinEx()\Item()\String   = Text
		    SpinEx()\Item()\Color    = #PB_Default
		    SpinEx()\Item()\Flags    = Flags
		    
		    If Label
		      SpinEx()\Index(Label) = ListIndex(SpinEx()\Item())
		    EndIf
		    
  		  Draw_()
  		EndIf
  		
		EndIf
		
    ProcedureReturn ListIndex(SpinEx()\Item())
	EndProcedure
	
  Procedure   AttachPopupMenu(GNum.i, MenuNum.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      If IsMenu(MenuNum)
        SpinEx()\PopupNum = MenuNum
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure   Copy(GNum.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      Copy_()
    EndIf
    
  EndProcedure
  
  Procedure   Cut(GNum.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      Cut_()
      PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Paste(GNum.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      Paste_()
      PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Delete(GNum.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      DeleteSelection_()
      PostEvent(#Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, SpinEx()\Window\Num, SpinEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure   ClearItems(GNum.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      ClearList(SpinEx()\Item())
      Draw_()
    EndIf  
    
  EndProcedure 
  
  Procedure.i CountItems(GNum.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      ProcedureReturn ListSize(SpinEx()\Item())
    EndIf  
    
  EndProcedure 
  
  Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(SpinEx(), Str(GNum))

      SpinEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure  

  Procedure   Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, maxListHeight.i, Content.s="", Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum
    
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
      Result = CanvasGadget(GNum, X, Y, Width, 20, #PB_Canvas_Keyboard)
    EndIf
    
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf

      If AddMapElement(SpinEx(), Str(GNum))
        
        SpinEx()\CanvasNum = GNum
        SpinEx()\Text      = Content
        SpinEx()\Flags     = Flags
        
        If WindowNum = #PB_Default
          SpinEx()\Window\Num = GetGadgetWindow()
        Else
          SpinEx()\Window\Num = WindowNum
        EndIf

        CompilerIf Defined(ModuleEx, #PB_Module)
          
          If ModuleEx::AddWindow(SpinEx()\Window\Num, ModuleEx::#Tabulator|ModuleEx::#CursorEvent)
            ModuleEx::AddGadget(GNum, SpinEx()\Window\Num, ModuleEx::#UseTabulator)
          EndIf

        CompilerElse  
          
          If IsWindow(SpinEx()\Window\Num)
            RemoveKeyboardShortcut(SpinEx()\Window\Num, #PB_Shortcut_Tab)
          Else
            Debug "ERROR: Invalid window number"
            ProcedureReturn #False
          EndIf
          
          If Thread\Active = #False
            
            Thread\Exit   = #False
            Thread\Num    = CreateThread(@_CursorThread(), #CursorFrequency)
            Thread\Active = #True
            
          EndIf

        CompilerEndIf

        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            SpinEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              SpinEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            SpinEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        SpinEx()\Padding = 3

        SpinEx()\Size\X = X
        SpinEx()\Size\Y = Y
        SpinEx()\Size\Width  = Width
        SpinEx()\Size\Height = Height
        
        SpinEx()\State = #PB_Default
        
        SpinEx()\CanvasCursor = #PB_Cursor_Default
        SpinEx()\Cursor\Pause = #True
        SpinEx()\Cursor\State = #True
        
        SpinEx()\Color\Front         = $000000
        SpinEx()\Color\Back          = $FFFFFF
        SpinEx()\Color\FocusText     = $FFFFFF
        SpinEx()\Color\FocusBack     = $D77800
        SpinEx()\Color\Border        = $A0A0A0
        SpinEx()\Color\Gadget        = $EDEDED
        SpinEx()\Color\DisableFront  = $72727D
        SpinEx()\Color\DisableBack   = $CCCCCA
        SpinEx()\Color\Cursor        = $800000
        SpinEx()\Color\Button        = $E3E3E3
        SpinEx()\Color\Highlight     = $D77800
        SpinEx()\Color\HighlightText = $FFFFFF
        SpinEx()\Color\WordColor     = $CC6600
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            SpinEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            SpinEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
            SpinEx()\Color\FocusText     = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
            SpinEx()\Color\FocusBack     = GetSysColor_(#COLOR_HIGHLIGHT)
            SpinEx()\Color\Gadget        = GetSysColor_(#COLOR_MENU)
            SpinEx()\Color\Button        = GetSysColor_(#COLOR_3DLIGHT)
            SpinEx()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
            SpinEx()\Color\WordColor     = GetSysColor_(#COLOR_HOTLIGHT)
            SpinEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
            SpinEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
          CompilerCase #PB_OS_MacOS
            SpinEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            SpinEx()\Color\FocusBack     = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            SpinEx()\Color\FocusBack     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor keyboardFocusIndicatorColor"))
            SpinEx()\Color\Gadget        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            SpinEx()\Color\Button        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            SpinEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            SpinEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextBackgroundColor"))
            SpinEx()\Color\HighlightText = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}        
        
        BindGadgetEvent(GNum, @_FocusHandler(),           #PB_EventType_Focus)
        BindGadgetEvent(GNum, @_LostFocusHandler(),       #PB_EventType_LostFocus)
        BindGadgetEvent(GNum, @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
        BindGadgetEvent(GNum, @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        BindGadgetEvent(GNum, @_InputHandler(),           #PB_EventType_Input)
        BindGadgetEvent(GNum, @_KeyDownHandler(),         #PB_EventType_KeyDown)
        BindGadgetEvent(GNum, @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        BindGadgetEvent(GNum, @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
        BindGadgetEvent(GNum, @_MouseEnterHandler(),      #PB_EventType_MouseEnter)
        BindGadgetEvent(GNum, @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
        BindGadgetEvent(GNum, @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(GNum, @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(GNum, @_CursorDrawing(),          #PB_EventType_Change)
        BindGadgetEvent(GNum, @_ResizeHandler(),          #PB_EventType_Resize)

        If Flags & #AutoResize
          
          If IsWindow(WindowNum)
            SpinEx()\Window\Width  = WindowWidth(WindowNum)
            SpinEx()\Window\Height = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf
          
        EndIf
        
        BindEvent(#Event_Cursor, @_CursorDrawing())

        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
        
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), SpinEx()\Window\Num)
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      Select Attribute
        Case #Padding
          ProcedureReturn SpinEx()\Padding
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetColor(GNum.i, ColorType.i) 
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn SpinEx()\Color\Front
        Case #BackColor
          ProcedureReturn SpinEx()\Color\Back
        Case #BorderColor
          ProcedureReturn SpinEx()\Color\Border
        Case #FocusTextColor
          ProcedureReturn SpinEx()\Color\FocusText
        Case #FocusBackColor
          ProcedureReturn SpinEx()\Color\FocusBack
        Case #CursorColor
          ProcedureReturn SpinEx()\Color\Cursor
        Case #HighlightColor
          ProcedureReturn SpinEx()\Color\Highlight
        Case #HighlightTextColor
          ProcedureReturn SpinEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    ProcedureReturn SpinEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    ProcedureReturn SpinEx()\ID
	  EndIf
	  
	EndProcedure
	
  Procedure.q GetItemData(GNum.i, Row.i)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
	    If SelectElement(SpinEx()\Item(), Row)
	      ProcedureReturn SpinEx()\Item()\Quad
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemLabel(GNum.i, Row.i)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
	    If SelectElement(SpinEx()\Item(), Row)
	      ProcedureReturn SpinEx()\Item()\ID
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemText(GNum.i, Row.i)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
	    If SelectElement(SpinEx()\Item(), Row)
	      ProcedureReturn SpinEx()\Item()\String
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetLabelText(GNum.i, Label.s)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
	    If FindMapElement(SpinEx()\Index(), Label)
    	  If SelectElement(SpinEx()\Item(), SpinEx()\Index())
    	    ProcedureReturn SpinEx()\Item()\String
    	  EndIf 
    	EndIf
    	
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetState(GNum.i)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
      ProcedureReturn SpinEx()\State
    EndIf
    
	EndProcedure
	
  Procedure.s GetText(GNum.i) 
    
    If FindMapElement(SpinEx(), Str(GNum))
      ProcedureReturn SpinEx()\Text
    EndIf
    
  EndProcedure

  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(SpinEx(), Str(GNum))
      HideGadget(GNum, State)
      SpinEx()\Hide = State 
    EndIf  
  
  EndProcedure
  
  Procedure   RemoveItem(GNum.i, Row.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      If SelectElement(SpinEx()\Item(), Row)
        DeleteElement(SpinEx()\Item())
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  

  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      SpinEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      Select Attribute
        Case #Minimum  
          SpinEx()\Minimum = Value
          If SpinEx()\State < Value : SpinEx()\State = Value : EndIf 
        Case #Maximum
          SpinEx()\Maximum = Value
          If SpinEx()\State > Value : SpinEx()\State = Value : EndIf 
        Case #Padding
          If Value < 2 : Value = 2 : EndIf 
          SpinEx()\Padding = Value
        Case #Corner
          SpinEx()\Radius  = Value  
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i) 
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          SpinEx()\Color\Front         = Color
        Case #BackColor
          SpinEx()\Color\Back          = Color
        Case #BorderColor
          SpinEx()\Color\Border        = Color
        Case #FocusTextColor
          SpinEx()\Color\FocusText     = Color
        Case #FocusBackColor
          SpinEx()\Color\FocusBack     = Color
        Case #CursorColor
          SpinEx()\Color\Cursor        = Color
        Case #HighlightColor
          SpinEx()\Color\Highlight     = Color
        Case #HighlightTextColor
          SpinEx()\Color\HighlightText = Color 
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    SpinEx()\Quad = Value
	  EndIf  
	  
	EndProcedure

  Procedure   SetFont(GNum.i, FontNum.i) 
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      If IsFont(FontNum)
        SpinEx()\FontID = FontID(FontNum)
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    SpinEx()\ID = String
	  EndIf
	  
	EndProcedure  
		
  Procedure   SetItemColor(GNum.i, Row.i, Color.i)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
	    If SelectElement(SpinEx()\Item(), Row)
	      SpinEx()\Item()\Color = Color
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemData(GNum.i, Row.i, Value.q)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
	    If SelectElement(SpinEx()\Item(), Row)
	      SpinEx()\Item()\Quad = Value
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
		
	Procedure   SetItemText(GNum.i, Row.i, Text.s, Flags.i=#False)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
  	  If SelectElement(SpinEx()\Item(), Row)
  	    SpinEx()\Item()\String = Text
  	    SpinEx()\Item()\Flags | Flags
  	  EndIf 
  	  
	  EndIf
	  
	EndProcedure	
	
  Procedure   SetLabelText(GNum.i, Label.s, Text.s, Flags.i=#False)
	  
	  If FindMapElement(SpinEx(), Str(GNum))
	    
	    If FindMapElement(SpinEx()\Index(), Label)
    	  If SelectElement(SpinEx()\Item(), SpinEx()\Index())
    	    SpinEx()\Item()\String = Text
    	    SpinEx()\Item()\Flags | Flags
    	  EndIf 
    	EndIf
    	
	  EndIf
	  
	EndProcedure
	
  Procedure   SetState(GNum.i, State.i)
	  
    If FindMapElement(SpinEx(), Str(GNum))

      If ListSize(SpinEx()\Item())
        If SelectElement(SpinEx()\Item(), State)
          SpinEx()\Text = SpinEx()\Item()\String 
    	  EndIf
    	Else
    	  SpinEx()\Text = Str(State)
    	EndIf

    	SpinEx()\State = State
    	
    	Draw_()
    EndIf
    
	EndProcedure
	
  Procedure   SetText(GNum.i, Text.s) 
    
    If FindMapElement(SpinEx(), Str(GNum))
      
      If SpinEx()\Flags & #Editable 
        
        SpinEx()\Text = Text
        
      Else
        
        If ListSize(SpinEx()\Item())
          
          ForEach SpinEx()\Item()
            If SpinEx()\Item()\String = Text
              SpinEx()\Text = Text
              SpinEx()\State = ListIndex(SpinEx()\Item())
              Break
            EndIf
          Next
          
        Else
          SpinEx()\Text = Text
        EndIf
        
      EndIf 
      
      Draw_()
    EndIf
    
  EndProcedure
  
EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Example = 1

  Enumeration 1
    #SpinEx
    #Font
    #Image
  EndEnumeration
  
  #Window = 0
  
  If OpenWindow(#Window, 0, 0, 130, 60, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    Select #Example
      Case 1
        
        If SpinEx::Gadget(#SpinEx, 20, 19, 90, 20, 80, "", #False, #Window)
          ; SpinEx::#LowerCase / SpinEx::#UpperCase | SpinEx::#Editable | SpinEx::#BorderLess | SpinEx::#NoButtons

          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 1")
          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 2")          
          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 3")
          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 4")
          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 5")          
          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 6")
          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 7")          
          SpinEx::AddItem(#SpinEx, SpinEx::#LastItem, "Item 8")
         
          SpinEx::SetItemColor(#SpinEx, 0, #Red)
          SpinEx::SetItemColor(#SpinEx, 1, #Blue)
          
          SpinEx::SetState(#SpinEx, 1)
        EndIf
        
      Case 2

        If SpinEx::Gadget(#SpinEx, 20, 19, 90, 20, 80, "", SpinEx::#Right, #Window)
          
          SpinEx::SetAttribute(#SpinEx, SpinEx::#Minimum, 1)
          SpinEx::SetAttribute(#SpinEx, SpinEx::#Maximum, 10)
          
          SpinEx::SetState(#SpinEx, 5)
        EndIf
        
    EndSelect
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #SpinEx
              Select EventType()
                Case #PB_EventType_Focus
                 ; Debug ">>> Focus"
                Case #PB_EventType_LostFocus
                 ; Debug ">>> LostFocus"
                Case SpinEx::#EventType_Change
                  Debug ">>> Changed: " + Str(SpinEx::GetState(#SpinEx))
              EndSelect    
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 1840
; Folding = 5LDBAAAGKAAEAAAQAAAAAA9
; EnableThread
; EnableXP
; DPIAware
; EnablePurifier