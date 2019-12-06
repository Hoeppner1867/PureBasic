;/ ============================
;/ =    ComboBoxExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; Last Update: 6.12.2019
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


;{ _____ ComboBoxEx - Commands _____

; ComboBoxEx::AddItem()            - similar to 'AddGadgetItem()'
; ComboBoxEx::AttachPopupMenu()    - attach a popup menu to the list
; ComboBoxEx::Copy()               - copy selection to clipboard
; ComboBoxEx::Cut()                - cut selection to clipboard
; ComboBoxEx::Delete()             - delete selection
; ComboBoxEx::ClearItems()         - similar to 'ClearGadgetItems()'
; ComboBoxEx::CountItems()         - similar to 'CountGadgetItems()'
; ComboBoxEx::Disable()            - similar to 'DisableGadget()'
; ComboBoxEx::GetData()            - similar to 'GetGadgetData()'
; ComboBoxEx::GetID()              - similar to 'GetGadgetData()', but string instead of quad
; ComboBoxEx::GetColor()           - similar to 'GetGadgetColor()'
; ComboBoxEx::GetItemData()        - similar to 'GetGadgetItemData()'
; ComboBoxEx::GetItemLabel()       - similar to 'GetGadgetItemData()', but string instead of quad
; ComboBoxEx::GetItemText()        - similar to 'GetGadgetItemText()'
; ComboBoxEx::GetLabelText()       - similar to 'GetGadgetItemText()', but label instead of row
; ComboBoxEx::GetState()           - similar to 'GetGadgetState()'
; ComboBoxEx::GetText()            - similar to 'GetGadgetText()'
; ComboBoxEx::Gadget()             - similar to 'ComboBoxGadget()'
; ComboBoxEx::Hide()               - similar to 'HideGadget()'
; ComboBoxEx::Paste()              - paste clipboard
; ComboBoxEx::RemoveItem()         - similar to 'RemoveGadgetItem()'
; ComboBoxEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; ComboBoxEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; ComboBoxEx::SetColor()           - similar to 'SetGadgetColor()'
; ComboBoxEx::SetData()            - similar to 'SetGadgetData()'
; ComboBoxEx::SetFont()            - similar to 'SetGadgetFont()'
; ComboBoxEx::SetID()              - similar to 'SetGadgetData()', but string instead of quad
; ComboBoxEx::SetImage()           - replace the arrow with an image
; ComboBoxEx::SetItemColor()       - similar to 'SetGadgetItemColor()'
; ComboBoxEx::SetItemData()        - similar to 'SetGadgetItemData()'
; ComboBoxEx::SetItemImage()       - similar to 'SetGadgetItemImage()'
; ComboBoxEx::SetItemText()        - similar to 'SetGadgetItemText()'
; ComboBoxEx::SetLabelText()       - similar to 'SetGadgetItemText()', but label instead of row
; ComboBoxEx::SetState()           - similar to 'SetGadgetState()'
; ComboBoxEx::SetText()            - similar to 'SetGadgetText()'

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule ComboBoxEx
  
  #Version  = 19120600
  #ModuleEx = 19112600
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #FirstItem = 0
  #LastItem  = -1
  
  EnumerationBinary ;{ Gadget Flags
    #Borderless
    #Editable
    #UpperCase
    #LowerCase
    #Image
    #AutoResize
    #ShowButton
    #EventButton
    #Left
    #Right
    #Center
    #FitText
    #FixPadding
    #UseExistingCanvas    
  EndEnumeration ;}
  
  Enumeration 1     ;{ Attribute
    #MaximumLength = #PB_String_MaximumLength
    #Padding
    #Corner
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
    
    #Event_Cursor       = ModuleEx::#Event_Cursor
    #Event_Gadget       = ModuleEx::#Event_Gadget
    #Event_Theme        = ModuleEx::#Event_Theme
    
    #EventType_Focus     = ModuleEx::#EventType_Focus
    #EventType_LostFocus = ModuleEx::#EventType_LostFocus
    #EventType_Change    = ModuleEx::#EventType_Change
    #EventType_Button    = ModuleEx::#EventType_Button
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
      #Event_Gadget
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
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   Paste(GNum.i)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontNum.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetImage(GNum.i, Image.i)
  Declare   SetItemColor(GNum.i, Row.i, Color.i)
  Declare   SetItemData(GNum.i, Row.i, Value.q)
  Declare   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False)
  Declare   SetItemText(GNum.i, Row.i, Text.s, Flags.i=#False)
  Declare   SetLabelText(GNum.i, Label.s, Text.s, Flags.i=#False)
  Declare   SetState(GNum.i, State.i)
  Declare   SetText(GNum.i, Text.s) 

EndDeclareModule

Module ComboBoxEx
  
  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================
  
  #ArrowSize       = 5
  #ButtonWidth     = 18
  #ScrollBarSize   = 16
  
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
  
  Structure ComboEx_Scroll_Structure  ;{ ComboEx()\ListView\ScrollBar\...
    Num.i
    Pos.i
    Hide.i
  EndStructure ;}
  
  Structure Image_Structure            ;{ ComboEx()\Button\Image\...
    Num.i
    Width.i
    Height.i
    Flags.i
  EndStructure ;}
  
  Structure ListView_Item_Structure    ;{ ComboEx()\ListView\Item()\...
    ID.s
    Quad.q
    Y.i
    String.s
    Image.Image_Structure
    Color.i
    Flags.i
  EndStructure ;}
  
  Structure ComboEx_ListView_Structure ;{ ComboEx()\ListView\...
    Num.i
    Window.i
    Width.f
    Height.f
    Offset.i
    RowHeight.i
    FontID.i
    FrontColor.i
    Focus.i
    State.i
    Hide.i
    ScrollBar.ComboEx_Scroll_Structure
    Map  Index.i() 
    List Item.ListView_Item_Structure()
  EndStructure ;}
  
  Structure Cursor_Thread_Structure    ;{
    Num.i
    Active.i
    Exit.i
  EndStructure ;}

  Structure Selection_Structure        ;{ ComboEx()\Selection\
    Pos1.i
    Pos2.i
    Flag.i
  EndStructure ;}

  Structure ComboEx_Button_Structure   ;{ ComboEx()\Button\...
    X.f
    State.i
    Image.Image_Structure
    Width.f
    Height.f
    Event.i
  EndStructure ;}  
  
  Structure ComboEx_Cursor_Structure   ;{ ComboEx()\Cursor\...
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
  
  Structure ComboEx_Color_Structure    ;{ ComboEx()\Color\...
    Front.i
    Back.i
    FocusText.i
    FocusBack.i
    Border.i
    Cursor.i
    Gadget.i
    DisableFront.i
    DisableBack.i
    Highlight.i
    HighlightText.i
    Button.i
    WordColor.i
  EndStructure ;}
  
  Structure ComboEx_Size_Structure     ;{ ComboEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Text.i
    Flags.i
  EndStructure ;} 
  
  Structure ComboEx_Window_Structure   ;{ ComboEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure ComboEx_Structure          ;{ ComboEx()\...
    CanvasNum.i
    PopupNum.i
    
    Thread.i
    
    ID.s
    Quad.q
    
    FontID.i
    
    Text.s
    
    State.i
    
    OffSetX.i
    Mouse.i
    CanvasCursor.i
    
    Padding.i
    Radius.i
    
    Hide.i

    Disable.i
    Flags.i

    Button.ComboEx_Button_Structure
    Image.Image_Structure
    ListView.ComboEx_ListView_Structure
    
    Color.ComboEx_Color_Structure
    Cursor.ComboEx_Cursor_Structure
    Selection.Selection_Structure
    Size.ComboEx_Size_Structure
    Window.ComboEx_Window_Structure
    
  EndStructure ;}
  Global NewMap ComboEx.ComboEx_Structure()

  Global Thread.Cursor_Thread_Structure

  
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
    ComboEx()\Selection\Pos1 = #False
    ComboEx()\Selection\Pos2 = #False
    ComboEx()\Selection\Flag = #NoSelection
  EndProcedure
  
  Procedure   DeleteSelection_() 
    
    If ComboEx()\Selection\Flag = #Selected
      
      If ComboEx()\Selection\Pos1 > ComboEx()\Selection\Pos2
        ComboEx()\Text = Left(ComboEx()\Text, ComboEx()\Selection\Pos2) + Mid(ComboEx()\Text, ComboEx()\Selection\Pos1 + 1)
        ComboEx()\Cursor\Pos = ComboEx()\Selection\Pos2
      Else
        ComboEx()\Text = Left(ComboEx()\Text, ComboEx()\Selection\Pos1) + Mid(ComboEx()\Text, ComboEx()\Selection\Pos2 + 1)
        ComboEx()\Cursor\Pos = ComboEx()\Selection\Pos1
      EndIf  
      
      RemoveSelection_() 
    EndIf
    
  EndProcedure
  
  
  Procedure   Copy_()
    Define.s Text
    
    If ComboEx()\Selection\Pos1 > ComboEx()\Selection\Pos2
      Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos2 + 1, ComboEx()\Selection\Pos1)
    Else
      Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos1 + 1, ComboEx()\Selection\Pos2)
    EndIf
    
    SetClipboardText(Text)
    RemoveSelection_()
    
  EndProcedure
  
  Procedure   Cut_()
    Define.s Text
    
    If ComboEx()\Flags & #Editable
      
      If ComboEx()\Selection\Pos1 > ComboEx()\Selection\Pos2
        Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos2 + 1, ComboEx()\Selection\Pos1)
      Else
        Text = StringSegment_(ComboEx()\Text, ComboEx()\Selection\Pos1 + 1, ComboEx()\Selection\Pos2)
      EndIf
    
      SetClipboardText(Text)
      DeleteSelection_()
      RemoveSelection_()
      
    EndIf

  EndProcedure
  
  Procedure   Paste_()
    Define.i c
    Define.s Text, Num, Char
    
    If ComboEx()\Flags & #Editable

      Text = GetClipboardText()

      If ComboEx()\Flags & #UpperCase : Text = UCase(Text) : EndIf
      If ComboEx()\Flags & #LowerCase : Text = LCase(Text) : EndIf
      
      If ComboEx()\Selection\Flag = #Selected
        DeleteSelection_()
        RemoveSelection_()
      EndIf
      
      ComboEx()\Text = InsertString(ComboEx()\Text, Text, ComboEx()\Cursor\Pos + 1)
      ComboEx()\Cursor\Pos + Len(Text)

    EndIf
    
  EndProcedure

  Procedure.i CursorPos_(CursorX.i)
    Define.s Text
    Define.i p, Pos.i

    If CursorX >= ComboEx()\OffSetX
      
      Text = ComboEx()\Text

      If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
        DrawingFont(ComboEx()\FontID)
        For p=1 To Len(Text)
          Pos = p
          If ComboEx()\OffSetX + TextWidth(Left(Text, p)) >= CursorX
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
    
    Text = ComboEx()\Text
    
    If CursorPos > 0
      ProcedureReturn TextWidth(Left(Text, CursorPos))
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  
  Procedure.i GetWordStart_(Pos.i) 
    Define.i p
    
    For p = Pos To 0 Step -1
      If Mid(ComboEx()\Text, p, 1) = " "
        ProcedureReturn p
      EndIf
    Next
    
    ProcedureReturn 0
  EndProcedure  
  
  Procedure.i GetWordEnd_(Pos.i) 
    Define.i p
    
    For p = Pos To Len(ComboEx()\Text)
      If Mid(ComboEx()\Text, p, 1) = " "
        ProcedureReturn p - 1
      EndIf
    Next
    
    ProcedureReturn Len(ComboEx()\Text)
  EndProcedure

  ;- __________ Drawing __________
  
  Procedure.f GetOffsetX_(Text.s, Width.i, OffsetX.i) 
    
    If ComboEx()\Flags & #Center
      ProcedureReturn (Width - TextWidth(Text)) / 2
    ElseIf ComboEx()\Flags & #Right
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
    
    If ComboEx()\Radius
      Box(X, Y, Width, Height, ComboEx()\Color\Gadget)
			RoundBox(X, Y, Width, Height, ComboEx()\Radius, ComboEx()\Radius, Color)
		Else
			Box(X, Y, Width, Height, Color)
		EndIf
		
	EndProcedure  
	
	
	Procedure   Arrow_(X.i, Y.i, Width.i, Height.i, Color.i)
	  Define.i aWidth, aHeight, aColor, imgHeight, imgWidth
	  Define.f Factor

	  If StartVectorDrawing(CanvasVectorOutput(ComboEx()\CanvasNum))

	    If IsImage(ComboEx()\Button\Image\Num)
	      
	      imgHeight = ComboEx()\Button\Height - dpiY(4)
	      
	      If ComboEx()\Button\Image\Height <= imgHeight
          imgWidth  = ComboEx()\Button\Image\Height
          imgHeight = ComboEx()\Button\Image\Width
        Else
          Factor    = imgHeight / ComboEx()\Button\Image\Height
          imgWidth  = imgHeight * Factor
        EndIf
        
        X + ((ComboEx()\Button\Width  - imgWidth) / 2)
        Y + ((ComboEx()\Button\Height - imgHeight) / 2)
        
	      MovePathCursor(X, Y)
        DrawVectorImage(ImageID(ComboEx()\Button\Image\Num), 255, imgWidth, imgHeight)

	    Else
	      
	      aColor  = RGBA(Red(Color), Green(Color), Blue(Color), 255)
	      
  	    aWidth  = dpiX(8)
        aHeight = dpiX(4)
        
        X + ((Width  - aWidth) / 2)
        Y + ((Height - aHeight) / 2)
        
        MovePathCursor(X, Y)
  	    
        AddPathLine(X + dpiX(4), Y + aHeight)
        AddPathLine(X + aWidth, Y)
        VectorSourceColor(aColor)
        StrokePath(1, #PB_Path_RoundCorner)
        
      EndIf
    
	    StopVectorDrawing()
	  EndIf
	  
	EndProcedure
	
	Procedure   CorrectButton_(X.i, Y.i, Radius.i, Height.i, Color.i, BackColor.i)
	  
    DrawingMode(#PB_2DDrawing_Default)
    Box(X, Y, Radius, Height, BackColor)
    
    Line(X, Y, Radius, 1, Color)
    Line(X, Y, 1, Height, Color)
    Line(X, Y + Height - dpiY(1), Radius, 1, Color)

  EndProcedure	
	
  Procedure   Button_()
    Define.i X, Y

    ComboEx()\Button\X = dpiX(GadgetWidth(ComboEx()\CanvasNum) - #ButtonWidth)
    
    DrawingMode(#PB_2DDrawing_Default)
    If ComboEx()\Button\State & #Click
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 20))
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, ComboEx()\Color\FocusBack)
      If ComboEx()\Radius : CorrectButton_(ComboEx()\Button\X, 0, ComboEx()\Radius, ComboEx()\Button\Height, ComboEx()\Color\FocusBack, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 20)) : EndIf
    ElseIf ComboEx()\Button\State & #Focus
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 10))
      DrawingMode(#PB_2DDrawing_Outlined)
      Box_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, ComboEx()\Color\FocusBack)
      If ComboEx()\Radius : CorrectButton_(ComboEx()\Button\X, 0, ComboEx()\Radius, ComboEx()\Button\Height, ComboEx()\Color\FocusBack, BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 10)) : EndIf
    Else
      Box_(ComboEx()\Button\X, dpiY(1), ComboEx()\Button\Width - dpiX(1), ComboEx()\Button\Height - dpiY(2), ComboEx()\Color\Back)
    EndIf  
  EndProcedure
  
  Procedure   CalcRowHeight()
    
    If StartDrawing(CanvasOutput(ComboEx()\ListView\Num))
      DrawingFont(ComboEx()\FontID)
      ComboEx()\ListView\RowHeight = TextHeight("Abc") + dpiY(4)
      StopDrawing()
    EndIf
    
  EndProcedure 
  
  Procedure   DrawListView_()
    Define.i X, Y, Width, Height, OffsetX, OffsetY, RowHeight, maxHeight, PageRows, scrollX
    Define.i ImgX, ImgY, imgHeight, imgWidth
    Define.i FrontColor, BackColor, BorderColor
    Define.f Factor
    
    If ComboEx()\ListView\Hide : ProcedureReturn #False : EndIf 
    
    ;{ --- Color --- 
    FrontColor  = ComboEx()\Color\Front
    BackColor   = ComboEx()\Color\Back
    BorderColor = ComboEx()\Color\Border
    ;}
    
    If StartDrawing(CanvasOutput(ComboEx()\ListView\Num))
      
      Width  = dpiX(GadgetWidth(ComboEx()\ListView\Num))
      Height = dpiY(GadgetHeight(ComboEx()\ListView\Num))
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, Width, Height, BackColor)
      ;}
      
      X = 0
      Y = dpiY(2)
      
      DrawingFont(ComboEx()\FontID)
      
      RowHeight = TextHeight("Abc") + dpiY(2)
      OffsetY   = dpiY(2) 
      
      ;{ _____ ScrollBar _____
      PageRows  = Height / RowHeight

      If PageRows < ListSize(ComboEx()\ListView\Item())
        
        If ComboEx()\ListView\ScrollBar\Hide
          
          If IsGadget(ComboEx()\ListView\ScrollBar\Num)
            scrollX = Width - #ScrollBarSize - 1
            SetGadgetAttribute(ComboEx()\ListView\ScrollBar\Num, #PB_ScrollBar_PageLength, PageRows)
            ResizeGadget(ComboEx()\ListView\ScrollBar\Num, scrollX, 1, #PB_Ignore, GadgetHeight(ComboEx()\ListView\Num - 2))
            HideGadget(ComboEx()\ListView\ScrollBar\Num, #False)
            ComboEx()\ListView\ScrollBar\Hide = #False
          EndIf
          
        EndIf  
        
      EndIf ;}
      
      ;{ _____ Rows _____
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(0, 0, Width, Height) 
      CompilerEndIf

      ForEach ComboEx()\ListView\Item()
        
        OffSetX = dpiX(5)
        
        If ListIndex(ComboEx()\ListView\Item()) < ComboEx()\ListView\Offset - 1
          ComboEx()\ListView\Item()\Y = 0
          Continue
        EndIf  
        
        If ComboEx()\ListView\Item()\Color <> #PB_Default
          FrontColor = ComboEx()\ListView\Item()\Color
        Else
          FrontColor = ComboEx()\Color\Front
        EndIf        
        
        If ComboEx()\ListView\Item()\Flags & #Image
          
          If IsImage(ComboEx()\ListView\Item()\Image\Num)
            
            ;{ Image Height
            imgHeight = RowHeight - dpiY(4)
            
            If ComboEx()\ListView\Item()\Image\Height <= imgHeight
              imgWidth  = ComboEx()\ListView\Item()\Image\Height
              imgHeight = ComboEx()\ListView\Item()\Image\Width
            Else
              Factor    = imgHeight / ComboEx()\ListView\Item()\Image\Height
              imgWidth  = imgHeight * Factor
            EndIf ;}
            
            ;{ Horizontal Align
            If ComboEx()\ListView\Item()\Image\Flags & #Center
              ImgX = (Width - imgWidth) / 2
            ElseIf ComboEx()\ListView\Item()\Image\Flags & #Right
              If ComboEx()\ListView\Item()\String
                If Not ComboEx()\ListView\Item()\Flags & #Center And Not ComboEx()\ListView\Item()\Flags & #Right
                  ImgX = TextWidth(ComboEx()\ListView\Item()\String) + dpiX(10)
                Else
                  ImgX = Width - imgWidth - dpiX(5)
                EndIf 
              Else  
                ImgX = Width - imgWidth - dpiX(5)
              EndIf  
            Else
              ImgX = dpiX(5)
              If Not ComboEx()\ListView\Item()\Flags & #Center And Not ComboEx()\ListView\Item()\Flags & #Right
                OffsetX + imgWidth + dpiX(5)
              EndIf   
            EndIf ;}
            
            ;{ Vertical Align
            If ComboEx()\ListView\Item()\Image\Height < imgHeight
              imgY = (RowHeight - ComboEx()\ListView\Item()\Image\Height) / 2
            Else
              imgY = dpiY(2)
            EndIf ;}

          Else  
            ComboEx()\ListView\Item()\Flags & ~#Image
          EndIf
          
        EndIf

        DrawingMode(#PB_2DDrawing_Transparent)
        If ComboEx()\ListView\State = ListIndex(ComboEx()\ListView\Item())
          Box(X - dpiX(2), Y, Width - dpiX(6), RowHeight, ComboEx()\Color\FocusBack)
          DrawText(X + OffsetX, Y + OffsetY, ComboEx()\ListView\Item()\String, ComboEx()\Color\FocusText)
        Else
          If ComboEx()\ListView\Focus = ListIndex(ComboEx()\ListView\Item())
            Box(X - dpiX(2), Y, Width - dpiX(6), RowHeight, BlendColor_(ComboEx()\Color\FocusBack, BackColor, 10))
          EndIf
          DrawText(X + OffsetX, Y + OffsetY, ComboEx()\ListView\Item()\String, FrontColor)
        EndIf

        ComboEx()\ListView\Item()\Y = Y
        
        If ComboEx()\ListView\Item()\Flags & #Image
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          DrawImage(ImageID(ComboEx()\ListView\Item()\Image\Num), X + imgX, Y + imgY, imgWidth, imgHeight)  
        EndIf 
        
        Y + RowHeight
        If Y > Y + Height : Break : EndIf
      Next
      
      ComboEx()\ListView\RowHeight = RowHeight
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput() 
      CompilerEndIf
      ;}

      ;{ _____ Border _____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, Width, Height, BorderColor)
      ;}
      
      StopDrawing()
    EndIf
    
  EndProcedure
 
  Procedure   Draw_()
    Define.i X, Y, Height, Width, startX, CursorX
    Define.s Text, Word, strgPart
    Define.i p, FrontColor, BackColor, BorderColor, CursorColor
    
    If ComboEx()\Hide : ProcedureReturn #False : EndIf

    If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
      
      FrontColor  = ComboEx()\Color\Front
      BorderColor = ComboEx()\Color\Border
      
      If ComboEx()\Flags & #Editable
        BackColor = ComboEx()\Color\Back
      Else
        If ComboEx()\Button\State & #Click
          BackColor   = BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 20)
          BorderColor = ComboEx()\Color\FocusBack
        ElseIf ComboEx()\Button\State & #Focus  
          BackColor = BlendColor_(ComboEx()\Color\FocusBack, ComboEx()\Color\Back, 10)
          BorderColor = ComboEx()\Color\FocusBack
        Else  
          BackColor = ComboEx()\Color\Button
        EndIf
      EndIf
      
      If ComboEx()\Disable
        FrontColor  = ComboEx()\Color\DisableFront
        BackColor   = BlendColor_(ComboEx()\Color\DisableBack, ComboEx()\Color\Gadget, 10)
        BorderColor = ComboEx()\Color\DisableBack
      EndIf  

      Height = dpiY(GadgetHeight(ComboEx()\CanvasNum))
      Width  = dpiX(GadgetWidth(ComboEx()\CanvasNum))

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(0, 0, Width, Height, BackColor)   
      ;}
      
      ComboEx()\Button\X      = Width - dpiX(#ButtonWidth)
      ComboEx()\Button\Width  = dpiX(#ButtonWidth)
      ComboEx()\Button\Height = Height
      
      Width - ComboEx()\Button\Width - dpiX(3)
      ComboEx()\Size\Text = Width

      DrawingFont(ComboEx()\FontID)

      ;{ _____ Text _____
      If ComboEx()\Text
        
        Text = ComboEx()\Text

        X = GetOffsetX_(Text, Width, dpiX(ComboEx()\Padding))
        Y = (Height - TextHeight(Text)) / 2
        
        ;{ TextWidth > Width
        If ComboEx()\Flags & #Editable
        
          CursorX = X + TextWidth(Left(Text, ComboEx()\Cursor\Pos))
          If CursorX > Width
            Text = Left(Text, ComboEx()\Cursor\Pos)
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
        DrawText(X, Y, Text, FrontColor)
        ComboEx()\OffSetX = X

      Else
        
        If ComboEx()\Flags & #Center
          X = Width / 2
        ElseIf ComboEx()\Flags & #Right
          X = Width - dpiX(ComboEx()\Padding)
        Else
          X = dpiX(ComboEx()\Padding)
        EndIf
        
        Y = (Height - TextHeight("X")) / 2  
        
      EndIf
      ;}
      
      ;{ _____ Selection ______
      If ComboEx()\Flags & #Editable
        
        If ComboEx()\Selection\Flag = #Selected
          
          If ComboEx()\Selection\Pos1 >  ComboEx()\Selection\Pos2
            startX   = CursorX_(ComboEx()\Selection\Pos2)
            strgPart = StringSegment_(Text, ComboEx()\Selection\Pos2 + 1, ComboEx()\Selection\Pos1)
          Else
            startX   = CursorX_(ComboEx()\Selection\Pos1)
            strgPart = StringSegment_(Text, ComboEx()\Selection\Pos1 + 1, ComboEx()\Selection\Pos2)
          EndIf
          
          ComboEx()\Cursor\Pos = ComboEx()\Selection\Pos2
          
          DrawingMode(#PB_2DDrawing_Default)
          DrawText(X + startX, Y, strgPart, ComboEx()\Color\HighlightText, ComboEx()\Color\Highlight)
  
        EndIf
        
      EndIf ;}
      
      ;{ _____ Cursor _____
      If ComboEx()\Flags & #Editable
        
        If ComboEx()\Cursor\Pos
          X + TextWidth(Left(Text, ComboEx()\Cursor\Pos))
        EndIf
        ComboEx()\Cursor\Height = TextHeight("X")
        ComboEx()\Cursor\X = X
        ComboEx()\Cursor\Y = Y
        If ComboEx()\Cursor\Pause = #False
          Line(ComboEx()\Cursor\X, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, ComboEx()\Color\Cursor)
        EndIf
        
      EndIf
      ;}

      ;{ _____ Border ____
      If Not ComboEx()\Flags & #Borderless
        DrawingMode(#PB_2DDrawing_Outlined)
        Box_(0, 0, dpiX(GadgetWidth(ComboEx()\CanvasNum)), Height, BorderColor)
      EndIf
      ;}
      
      If ComboEx()\Flags & #Editable : Button_() : EndIf
      
      StopDrawing()
    EndIf
    
    Arrow_(ComboEx()\Button\X, 0, ComboEx()\Button\Width, ComboEx()\Button\Height, ComboEx()\Color\Front)
  
  EndProcedure
  
  ;- __________ ComboEx __________
  
  Procedure OpenComboEx_()
    Define.i X, Y, RowsHeight, Width, Height
    
    X      = GadgetX(ComboEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
    Y      = GadgetY(ComboEx()\CanvasNum, #PB_Gadget_ScreenCoordinate)
    Width  = GadgetWidth(ComboEx()\CanvasNum)
    Height = ComboEx()\ListView\Height
    
    If ComboEx()\ListView\RowHeight = 0 : CalcRowHeight() : EndIf
    
    RowsHeight = ListSize(ComboEx()\ListView\Item()) * ComboEx()\ListView\RowHeight
    RowsHeight + dpiX(4)
    If RowsHeight < Height : Height = RowsHeight : EndIf  
  
    ResizeWindow(ComboEx()\ListView\Window, X, Y + 20, Width, Height)
    ResizeGadget(ComboEx()\ListView\Num, 0, 0, Width, Height)

    HideWindow(ComboEx()\ListView\Window, #False)
    
    SetActiveGadget(ComboEx()\ListView\Num)
    
    ComboEx()\ListView\Focus = #PB_Default
    ComboEx()\ListView\Hide  = #False
    
    DrawListView_()
    
  EndProcedure
  
  Procedure CloseComboEx_()
    
    HideWindow(ComboEx()\ListView\Window, #True)
    
    ComboEx()\ListView\Hide  = #True
    ComboEx()\ListView\State = #PB_Default
    ComboEx()\Button\State & ~#Click

    Draw_()
    
  EndProcedure  
  
  ;- __________ Events __________
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach ComboEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          ComboEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        ComboEx()\Color\Front         = ModuleEx::ThemeGUI\FrontColor
        ComboEx()\Color\Back          = ModuleEx::ThemeGUI\BackColor
        ComboEx()\Color\FocusText     = ModuleEx::ThemeGUI\Focus\FrontColor
        ComboEx()\Color\FocusBack     = ModuleEx::ThemeGUI\Focus\BackColor
        ComboEx()\Color\Border        = ModuleEx::ThemeGUI\BorderColor
        ComboEx()\Color\Gadget        = ModuleEx::ThemeGUI\GadgetColor
        ComboEx()\Color\Cursor        = ModuleEx::ThemeGUI\FrontColor
        ComboEx()\Color\Button        = ModuleEx::ThemeGUI\Button\BackColor
        ComboEx()\Color\HighlightText = ModuleEx::ThemeGUI\Focus\FrontColor
        ComboEx()\Color\Highlight     = ModuleEx::ThemeGUI\Focus\BackColor
        ComboEx()\Color\DisableFront  = ModuleEx::ThemeGUI\Disable\FrontColor
        ComboEx()\Color\DisableBack   = ModuleEx::ThemeGUI\Disable\BackColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf   
  
  
  Procedure _CursorDrawing() ; Trigger from Thread (PostEvent Change)
    Define.i BackColor
    Define.i WindowNum = EventWindow()

    ForEach ComboEx()
      
      BackColor = ComboEx()\Color\Back
      If ComboEx()\Disable : BackColor = BlendColor_(ComboEx()\Color\DisableBack, ComboEx()\Color\Gadget, 10) : EndIf
      
      If ComboEx()\Cursor\Pause = #False

        ComboEx()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          If ComboEx()\Cursor\State
            Line(ComboEx()\Cursor\X, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, ComboEx()\Color\Cursor)
          Else
            Line(ComboEx()\Cursor\X, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, BackColor)
          EndIf
          StopDrawing()
        EndIf
        
      ElseIf ComboEx()\Cursor\State

        If StartDrawing(CanvasOutput(ComboEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          Line(ComboEx()\Cursor\X - 1, ComboEx()\Cursor\Y, 1, ComboEx()\Cursor\Height, BackColor)
          StopDrawing()
        EndIf
      
      EndIf
      
    Next
    
  EndProcedure  
  
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
  
  
  Procedure _ListViewHandler()
    Define.i GNum, Y
    Define.i ComboExNum = EventGadget()
    
    GNum = GetGadgetData(ComboExNum)
    If FindMapElement(ComboEx(), Str(GNum))

      If ComboExNum = ComboEx()\ListView\Num 
        
        Y = GetGadgetAttribute(ComboExNum, #PB_Canvas_MouseY)

        Select EventType()
          Case #PB_EventType_LeftButtonDown ;{ Left Button Down
            
            ForEach ComboEx()\ListView\Item()
              If Y >= ComboEx()\ListView\Item()\Y And Y <= ComboEx()\ListView\Item()\Y + ComboEx()\ListView\RowHeight
                ComboEx()\ListView\State = ListIndex(ComboEx()\ListView\Item())
                DrawListView_()
                ProcedureReturn #True
              EndIf
            Next 
            ;}
          Case #PB_EventType_LeftButtonUp   ;{ Left Button Up
            
            ForEach ComboEx()\ListView\Item()
              If Y >= ComboEx()\ListView\Item()\Y And Y <= ComboEx()\ListView\Item()\Y + ComboEx()\ListView\RowHeight
                If ComboEx()\ListView\State <> ListIndex(ComboEx()\ListView\Item())
                  ComboEx()\ListView\State = #PB_Default
                  ProcedureReturn  #False
                EndIf
                ComboEx()\Text = ComboEx()\ListView\Item()\String
                DrawListView_()
                CloseComboEx_()
                ProcedureReturn #True
              EndIf
            Next 
            ;}
          Case #PB_EventType_MouseMove      ;{ Mouse Move

            ForEach ComboEx()\ListView\Item()
              If Y >= ComboEx()\ListView\Item()\Y And Y <= ComboEx()\ListView\Item()\Y + ComboEx()\ListView\RowHeight
                ComboEx()\ListView\Focus = ListIndex(ComboEx()\ListView\Item())
                DrawListView_()
                ProcedureReturn #True
              EndIf
            Next 
            ;}
          Case #PB_EventType_MouseLeave     ;{ Mouse Leave
            ComboEx()\ListView\Focus = #PB_Default
            DrawListView_()
            ProcedureReturn #True
            ;}
        EndSelect 
        
      EndIf
   
    EndIf
    
  EndProcedure
  
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\Flags & #Editable
        ComboEx()\State | #Focus
        Draw_()
        
        ComboEx()\Cursor\State = #False
        ComboEx()\Cursor\Pause = #False
        
        PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Focus)
      EndIf
    
    EndIf
    
  EndProcedure  
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\Flags & #Editable
        ComboEx()\Cursor\Pause = #True
        
        ComboEx()\State & ~#Focus
        ComboEx()\Button\State & ~#Focus

        Draw_()
        
        PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_LostFocus)
      EndIf
      
    EndIf
    
  EndProcedure    
  
  
  Procedure _InputHandler()
    Define.s Char$
    Define.i Char
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))

      If ComboEx()\State & #Focus And ComboEx()\Flags & #Editable
        
        Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)

        If Char >= 32
          
          If ComboEx()\Selection\Flag = #Selected
            DeleteSelection_()
          EndIf
          
          Char$ =  Chr(Char)
          If ComboEx()\Flags & #UpperCase : Char$ = UCase(Char$) : EndIf
          If ComboEx()\Flags & #LowerCase : Char$ = LCase(Char$) : EndIf
          

          ComboEx()\Cursor\Pos + 1
          ComboEx()\Text = InsertString(ComboEx()\Text, Char$, ComboEx()\Cursor\Pos)
          
          PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
  EndProcedure   
  
  Procedure _KeyDownHandler()
    
    Define.i Key, Modifier
    Define.s Text
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\State & #Focus
        
        Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
        Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
        
        Select Key
          Case #PB_Shortcut_Left      ;{ Cursor left
            If Modifier & #PB_Canvas_Shift
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = ComboEx()\Cursor\Pos
                ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos - 1
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 - 1
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
              If ComboEx()\Cursor\Pos > 0
                ComboEx()\Cursor\Pos - 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = GetWordEnd_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Pos2 = GetWordStart_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 = GetWordStart_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
            Else
              
              If ComboEx()\Cursor\Pos > 0
                ComboEx()\Cursor\Pos - 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_Right     ;{ Cursor right
            If Modifier & #PB_Canvas_Shift
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = ComboEx()\Cursor\Pos
                ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos + 1
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 + 1
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
              If ComboEx()\Cursor\Pos < Len(ComboEx()\Text)
                ComboEx()\Cursor\Pos + 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = GetWordStart_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Pos2 = GetWordEnd_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              Else
                ComboEx()\Selection\Pos2 = GetWordEnd_(ComboEx()\Cursor\Pos)
                ComboEx()\Selection\Flag = #Selected
              EndIf
              
            Else

              If ComboEx()\Cursor\Pos < Len(ComboEx()\Text)
                ComboEx()\Cursor\Pos + 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_End       ;{ Cursor end of chars
            ComboEx()\Cursor\Pos = Len(ComboEx()\Text)
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Home      ;{ Cursor position 0
            ComboEx()\Cursor\Pos = 0
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Back      ;{ Delete Back
            If ComboEx()\Flags & #Editable
              If ComboEx()\Selection\Flag = #Selected
                DeleteSelection_()
                RemoveSelection_()
              Else
                If ComboEx()\Cursor\Pos > 0
                  ComboEx()\Text = DeleteStringPart_(ComboEx()\Text, ComboEx()\Cursor\Pos) 
                  ComboEx()\Cursor\Pos - 1
                EndIf
                RemoveSelection_()
              EndIf 
              PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            EndIf ;}
          Case #PB_Shortcut_Delete    ;{ Delete / Cut (Shift)
            If Modifier & #PB_Canvas_Shift ;{ Cut selected text
              Cut_()
              ;}
            Else                           ;{ Delete text
              If ComboEx()\Flags & #Editable
                If ComboEx()\Selection\Flag = #Selected
                  DeleteSelection_()
                  RemoveSelection_()
                Else
                  If ComboEx()\Cursor\Pos < Len(ComboEx()\Text) 
                    ComboEx()\Text = DeleteStringPart_(ComboEx()\Text, ComboEx()\Cursor\Pos + 1)
                    RemoveSelection_()
                  EndIf
                EndIf
              EndIf ;}
            EndIf
            PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            ;} 
          Case #PB_Shortcut_Insert    ;{ Copy (Ctrl) / Paste (Shift)
            If Modifier & #PB_Canvas_Shift
              Paste_()
              PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            ElseIf Modifier & #PB_Canvas_Control
              Copy_()
            EndIf ;}  
          Case #PB_Shortcut_A         ;{ Ctrl-A (Select all)
            If Modifier & #PB_Canvas_Control
              ComboEx()\Cursor\Pos = Len(ComboEx()\Text)
              ComboEx()\Selection\Pos1 = 0
              ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos
              ComboEx()\Selection\Flag = #Selected
            EndIf ;}
          Case #PB_Shortcut_C         ;{ Copy   (Ctrl)  
            If Modifier & #PB_Canvas_Control
              Copy_()
            EndIf  
            ;}
          Case #PB_Shortcut_X         ;{ Cut    (Ctrl) 
            If Modifier & #PB_Canvas_Control
              Cut_()
              PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            EndIf
            ;}
          Case #PB_Shortcut_D         ;{ Ctrl-D (Delete selection)
            If ComboEx()\Flags & #Editable
              If Modifier & #PB_Canvas_Control
                DeleteSelection_()
                PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
              EndIf 
            EndIf ;} 
          Case #PB_Shortcut_V         ;{ Paste  (Ctrl) 
            If ComboEx()\Flags & #Editable
              If Modifier & #PB_Canvas_Control
                Paste_()
                PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
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
    
    If FindMapElement(ComboEx(), Str(GNum))
      If IsWindow(ComboEx()\Window\Num)
        DisplayPopupMenu(ComboEx()\PopupNum, WindowID(ComboEx()\Window\Num))
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonDownHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)

      If ComboEx()\Flags & #Editable
      
        If ComboEx()\Mouse = #Mouse_Move
          ComboEx()\Cursor\Pos = CursorPos_(X)
        EndIf
        
      EndIf

      If ComboEx()\Button\State & #Focus
        ComboEx()\Button\State | #Click
      EndIf
      
      If ComboEx()\Selection\Flag = #Selected
        RemoveSelection_()
      EndIf
      
      ComboEx()\State | #Focus
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftButtonUpHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If ComboEx()\Flags & #Editable ;{ editable ComboBox
        
        If X > ComboEx()\Button\X 
          
          If ComboEx()\ListView\Hide
            OpenComboEx_()
          Else
            CloseComboEx_()
            PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
          EndIf  
          
        Else 
  
          If ComboEx()\Mouse = #Mouse_Select
            ComboEx()\Cursor\Pos     = CursorPos_(X)
            ComboEx()\Selection\Pos2 = ComboEx()\Cursor\Pos
            ComboEx()\Mouse = #Mouse_Move
          EndIf
          
        EndIf 
        ;}
      Else                           ;{ normal ComboBox
        
        If ComboEx()\ListView\Hide
          OpenComboEx_()
        Else
          CloseComboEx_()
          PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
          PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
        EndIf  
        ;}
      EndIf   
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftDoubleClickHandler()
    Define.i X, Pos
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      Pos = CursorPos_(X)
      If Pos
        ComboEx()\Selection\Pos1 = GetWordStart_(Pos)
        ComboEx()\Selection\Pos2 = GetWordEnd_(Pos)
        ComboEx()\Selection\Flag = #Selected
        ComboEx()\Cursor\Pos     = ComboEx()\Selection\Pos2
      EndIf
    
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure _MouseEnterHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If Not ComboEx()\Flags & #Editable
        ComboEx()\Button\State | #Focus
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GNum))
      ComboEx()\Button\State & ~#Focus
      Draw_()
    EndIf
    
  EndProcedure  
  
  Procedure _MouseMoveHandler()
    Define.i X, Y, GNum
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GadgetNum))

      X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
      
      If ComboEx()\Flags & #Editable
      
        If GetGadgetAttribute(GadgetNum, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton ;{ Left mouse button pressed
          
          Select ComboEx()\Mouse
            Case #Mouse_Move   ;{ Start selection
              If ComboEx()\Selection\Flag = #NoSelection
                ComboEx()\Selection\Pos1 = ComboEx()\Cursor\Pos
                ComboEx()\Selection\Pos2 = CursorPos_(X)
                ComboEx()\Selection\Flag = #Selected
                ComboEx()\Mouse = #Mouse_Select
                Draw_()
              EndIf ;}
            Case #Mouse_Select ;{ Continue selection
              ComboEx()\Selection\Pos2 = CursorPos_(X)
              ComboEx()\Cursor\Pos     = ComboEx()\Selection\Pos2
              Draw_() ;}
          EndSelect
          ;}
        Else

          If X > ComboEx()\Button\X
            ComboEx()\Button\State | #Focus
            If ComboEx()\CanvasCursor <> #PB_Cursor_Default
              SetGadgetAttribute(ComboEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
              ComboEx()\CanvasCursor = #PB_Cursor_Default
            EndIf
          Else
            ComboEx()\Button\State & ~#Focus
            If ComboEx()\CanvasCursor <> #PB_Cursor_IBeam
              SetGadgetAttribute(ComboEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
              ComboEx()\CanvasCursor = #PB_Cursor_IBeam
            EndIf
          EndIf
        
          Draw_()
        EndIf 

      EndIf
      
      ComboEx()\Mouse = #Mouse_Move

    EndIf
    
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta, ScrollPos
    
    If FindMapElement(ComboEx(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(ComboEx()\ListView\ScrollBar\Num) And ComboEx()\ListView\ScrollBar\Hide = #False
        
        ScrollPos = GetGadgetState(ComboEx()\ListView\ScrollBar\Num) - Delta
        
        If ScrollPos <> ComboEx()\ListView\ScrollBar\Pos

          ComboEx()\ListView\ScrollBar\Pos = ScrollPos
          ComboEx()\ListView\Offset        = ScrollPos
          
          SetGadgetState(ComboEx()\ListView\ScrollBar\Num, ScrollPos)
          
          DrawListView_()      
  
        EndIf

      EndIf

    EndIf
    
  EndProcedure
  
  
  Procedure _SynchronizeScrollBar()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.i ScrollPos
    
    If FindMapElement(ComboEx(), Str(GadgetNum))
      
      If Not ComboEx()\ListView\Hide
        
        ScrollPos = GetGadgetState(ScrollNum)
        If ScrollPos <> ComboEx()\ListView\ScrollBar\Pos
          
          ComboEx()\ListView\ScrollBar\Pos = ScrollPos
          ComboEx()\ListView\Offset        = ScrollPos
          
          DrawListView_()      
        EndIf
        
      EndIf 
      
    EndIf
    
  EndProcedure ;}
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(ComboEx(), Str(GadgetID))      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.i FontSize
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach ComboEx()
      
      If IsGadget(ComboEx()\CanvasNum)
        
        If ComboEx()\Flags & #AutoResize
          
          If IsWindow(ComboEx()\Window\Num)
            
            OffSetX = WindowWidth(ComboEx()\Window\Num)  - ComboEx()\Window\Width
            OffsetY = WindowHeight(ComboEx()\Window\Num) - ComboEx()\Window\Height

            If ComboEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If ComboEx()\Size\Flags & #MoveX  : X = ComboEx()\Size\X + OffSetX : EndIf
              If ComboEx()\Size\Flags & #MoveY  : Y = ComboEx()\Size\Y + OffSetY : EndIf
              If ComboEx()\Size\Flags & #Width  : Width  = ComboEx()\Size\Width  + OffSetX : EndIf
              If ComboEx()\Size\Flags & #Height : Height = ComboEx()\Size\Height + OffSetY : EndIf
              
              ResizeGadget(ComboEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(ComboEx()\CanvasNum, #PB_Ignore, #PB_Ignore, ComboEx()\Size\Width + OffSetX, ComboEx()\Size\Height + OffsetY)
            EndIf

            Draw_()
          EndIf

        EndIf
        
      EndIf
      
    Next
    
  EndProcedure  
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach ComboEx()
    
      If ComboEx()\Window\Num = Window
        
        CompilerIf Defined(ModuleEx, #PB_Module) = #False
          If MapSize(ComboEx()) = 1
            Thread\Exit = #True
            Delay(100)
            If IsThread(Thread\Num) : KillThread(Thread\Num) : EndIf
            Thread\Active = #False
          EndIf
        CompilerEndIf
        
        DeleteMapElement(ComboEx())
        
      EndIf
      
    Next
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure   InitList_()

    ComboEx()\ListView\Window = OpenWindow(#PB_Any, 0, 0, ComboEx()\Size\Width, ComboEx()\Size\Height, "", #PB_Window_BorderLess|#PB_Window_Invisible, WindowID(ComboEx()\Window\Num)) 
    If ComboEx()\ListView\Window
      ComboEx()\ListView\Num = CanvasGadget(#PB_Any, 0, 0, ComboEx()\Size\Width, ComboEx()\Size\Height, #PB_Canvas_Container)
      If ComboEx()\ListView\Num
        
        SetGadgetData(ComboEx()\ListView\Num, ComboEx()\CanvasNum)
        
        ComboEx()\ListView\ScrollBar\Num = ScrollBarGadget(#PB_Any, 0, 0, #ScrollBarSize, 0, 1, 100, 0, #PB_ScrollBar_Vertical)
        If IsGadget(ComboEx()\ListView\ScrollBar\Num)
          SetGadgetData(ComboEx()\ListView\ScrollBar\Num, ComboEx()\CanvasNum)
          HideGadget(ComboEx()\ListView\ScrollBar\Num, #True)
        EndIf
        
        BindGadgetEvent(ComboEx()\ListView\Num, @_ListViewHandler())
        
        ComboEx()\ListView\Hide = #True
        CloseGadgetList()
      EndIf
    EndIf  
  
  EndProcedure  
  
  
	Procedure.i AddItem(GNum.i, Row.i, Text.s, Label.s="", Flags.i=#False)
	  Define.i r, Result
	  
		If FindMapElement(ComboEx(), Str(GNum))
		  
		  ;{ Add item
      Select Row
        Case #FirstItem
          FirstElement(ComboEx()\ListView\Item())
          Result = InsertElement(ComboEx()\ListView\Item()) 
        Case #LastItem
          LastElement(ComboEx()\ListView\Item())
          Result = AddElement(ComboEx()\ListView\Item())
        Default
          If SelectElement(ComboEx()\ListView\Item(), Row)
            Result = InsertElement(ComboEx()\ListView\Item()) 
          Else
            LastElement(ComboEx()\ListView\Item())
            Result = AddElement(ComboEx()\ListView\Item())
          EndIf
      EndSelect ;}
   
      If Result

		    ComboEx()\ListView\Item()\ID       = Label
		    ComboEx()\ListView\Item()\String   = Text
		    ComboEx()\ListView\Item()\Color    = #PB_Default
		    ComboEx()\ListView\Item()\Flags    = Flags
		    
		    If Label
		      ComboEx()\ListView\Index(Label) = ListIndex(ComboEx()\ListView\Item())
		    EndIf
		    
  		  Draw_()
  		EndIf
  		
		EndIf
		
    ProcedureReturn ListIndex(ComboEx()\ListView\Item())
	EndProcedure
  
  Procedure   AttachPopupMenu(GNum.i, MenuNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If IsMenu(MenuNum)
        ComboEx()\PopupNum = MenuNum
      EndIf
      
    EndIf
    
  EndProcedure

  Procedure   Copy(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      Copy_()
    EndIf
    
  EndProcedure
  
  Procedure   Cut(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      Cut_()
      PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Paste(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      Paste_()
      PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Delete(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      DeleteSelection_()
      PostEvent(#Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, ComboEx()\Window\Num, ComboEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure   ClearItems(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      ClearList(ComboEx()\ListView\Item())
      Draw_()
    EndIf  
    
  EndProcedure 
  
  Procedure.i CountItems(GNum.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      ProcedureReturn ListSize(ComboEx()\ListView\Item())
    EndIf  
    
  EndProcedure 
  
  Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(ComboEx(), Str(GNum))

      ComboEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure  

  Procedure   Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Content.s="", Flags.i=#False, WindowNum.i=#PB_Default)
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

      If AddMapElement(ComboEx(), Str(GNum))
        
        ComboEx()\CanvasNum = GNum
        ComboEx()\Text      = Content
        ComboEx()\Flags     = Flags
        
        If WindowNum = #PB_Default
          ComboEx()\Window\Num = GetGadgetWindow()
        Else
          ComboEx()\Window\Num = WindowNum
        EndIf

        CompilerIf Defined(ModuleEx, #PB_Module)
          
          If ModuleEx::AddWindow(ComboEx()\Window\Num, ModuleEx::#Tabulator|ModuleEx::#CursorEvent)
            ModuleEx::AddGadget(GNum, ComboEx()\Window\Num, ModuleEx::#UseTabulator)
          EndIf

        CompilerElse  
          
          If IsWindow(ComboEx()\Window\Num)
            RemoveKeyboardShortcut(ComboEx()\Window\Num, #PB_Shortcut_Tab)
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
            ComboEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              ComboEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            ComboEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        ComboEx()\Padding = 4
        
        ComboEx()\Size\X = X
        ComboEx()\Size\Y = Y
        ComboEx()\Size\Width  = Width
        ComboEx()\Size\Height = 25
        
        InitList_()
        
        ComboEx()\ListView\Height = Height
        ComboEx()\ListView\State  = #PB_Default
        
        ComboEx()\CanvasCursor = #PB_Cursor_Default
        ComboEx()\Cursor\Pause = #True
        ComboEx()\Cursor\State = #True
        
        ComboEx()\Color\Front         = $000000
        ComboEx()\Color\Back          = $FFFFFF
        ComboEx()\Color\FocusText     = $FFFFFF
        ComboEx()\Color\FocusBack     = $D77800
        ComboEx()\Color\Border        = $A0A0A0
        ComboEx()\Color\Gadget        = $EDEDED
        ComboEx()\Color\DisableFront  = $72727D
        ComboEx()\Color\DisableBack   = $CCCCCA
        ComboEx()\Color\Cursor        = $800000
        ComboEx()\Color\Button        = $E3E3E3
        ComboEx()\Color\Highlight     = $D77800
        ComboEx()\Color\HighlightText = $FFFFFF
        ComboEx()\Color\WordColor     = $CC6600
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            ComboEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            ComboEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
            ComboEx()\Color\FocusText     = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
            ComboEx()\Color\FocusBack     = GetSysColor_(#COLOR_HIGHLIGHT)
            ComboEx()\Color\Gadget        = GetSysColor_(#COLOR_MENU)
            ComboEx()\Color\Button        = GetSysColor_(#COLOR_3DLIGHT)
            ComboEx()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
            ComboEx()\Color\WordColor     = GetSysColor_(#COLOR_HOTLIGHT)
            ComboEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
            ComboEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
          CompilerCase #PB_OS_MacOS
            ComboEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ComboEx()\Color\FocusBack     = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ComboEx()\Color\FocusBack         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor keyboardFocusIndicatorColor"))
            ComboEx()\Color\Gadget        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            ComboEx()\Color\Button        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ComboEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ComboEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextBackgroundColor"))
            ComboEx()\Color\HighlightText = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
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
        BindGadgetEvent(GNum, @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(GNum, @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(GNum, @_CursorDrawing(),          #PB_EventType_Change)
        BindGadgetEvent(GNum, @_ResizeHandler(),          #PB_EventType_Resize)
        
        ;BindGadgetEvent(ComboEx()\ListView\Num,  @_MouseWheelHandler(), #PB_EventType_MouseWheel)
        BindGadgetEvent(ComboEx()\ListView\ScrollBar\Num, @_SynchronizeScrollBar(), #PB_All) 
        
        If Flags & #AutoResize
          
          If Flags & #FitText    : ComboEx()\Size\Flags | #FitText    : EndIf
          If Flags & #FixPadding : ComboEx()\Size\Flags | #FixPadding : EndIf
          
          If IsWindow(WindowNum)
            ComboEx()\Window\Width  = WindowWidth(WindowNum)
            ComboEx()\Window\Height = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf
          
        EndIf
        
        BindEvent(#Event_Cursor, @_CursorDrawing())

        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
        
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), ComboEx()\Window\Num)
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select Attribute
        Case #Padding
          ProcedureReturn ComboEx()\Padding
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetColor(GNum.i, ColorType.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn ComboEx()\Color\Front
        Case #BackColor
          ProcedureReturn ComboEx()\Color\Back
        Case #BorderColor
          ProcedureReturn ComboEx()\Color\Border
        Case #FocusTextColor
          ProcedureReturn ComboEx()\Color\FocusText
        Case #FocusBackColor
          ProcedureReturn ComboEx()\Color\FocusBack
        Case #CursorColor
          ProcedureReturn ComboEx()\Color\Cursor
        Case #HighlightColor
          ProcedureReturn ComboEx()\Color\Highlight
        Case #HighlightTextColor
          ProcedureReturn ComboEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ProcedureReturn ComboEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ProcedureReturn ComboEx()\ID
	  EndIf
	  
	EndProcedure
	
  Procedure.q GetItemData(GNum.i, Row.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ProcedureReturn ComboEx()\ListView\Item()\Quad
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemLabel(GNum.i, Row.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ProcedureReturn ComboEx()\ListView\Item()\ID
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetItemText(GNum.i, Row.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ProcedureReturn ComboEx()\ListView\Item()\String
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure.s GetLabelText(GNum.i, Label.s)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If FindMapElement(ComboEx()\ListView\Index(), Label)
    	  If SelectElement(ComboEx()\ListView\Item(), ComboEx()\ListView\Index())
    	    ProcedureReturn ComboEx()\ListView\Item()\String
    	  EndIf 
    	EndIf
    	
	  EndIf
	  
	EndProcedure
	
	Procedure.i GetState(GNum.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
      ProcedureReturn ComboEx()\ListView\State
    EndIf
    
	EndProcedure
	
  Procedure.s GetText(GNum.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      ProcedureReturn ComboEx()\Text
    EndIf
    
  EndProcedure

  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(ComboEx(), Str(GNum))
      HideGadget(GNum, State)
      ComboEx()\Hide = State 
    EndIf  
  
  EndProcedure
  
  Procedure   RemoveItem(GNum.i, Row.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If SelectElement(ComboEx()\ListView\Item(), Row)
        DeleteElement(ComboEx()\ListView\Item())
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  

  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      ComboEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select Attribute
        Case #Padding
          If Value < 2 : Value = 2 : EndIf 
          ComboEx()\Padding = Value
        Case #Corner
          ComboEx()\Radius  = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ComboEx()\Color\Front         = Color
        Case #BackColor
          ComboEx()\Color\Back          = Color
        Case #BorderColor
          ComboEx()\Color\Border        = Color
        Case #FocusTextColor
          ComboEx()\Color\FocusText     = Color
        Case #FocusBackColor
          ComboEx()\Color\FocusBack     = Color
        Case #CursorColor
          ComboEx()\Color\Cursor        = Color
        Case #HighlightColor
          ComboEx()\Color\Highlight     = Color
        Case #HighlightTextColor
          ComboEx()\Color\HighlightText = Color
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ComboEx()\Quad = Value
	  EndIf  
	  
	EndProcedure

  Procedure   SetFont(GNum.i, FontNum.i) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If IsFont(FontNum)
        ComboEx()\FontID = FontID(FontNum)
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    ComboEx()\ID = String
	  EndIf
	  
	EndProcedure  
	
	Procedure   SetImage(GNum.i, Image.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))

	    If IsImage(Image)  
	      ComboEx()\Button\Image\Num    = Image
	      ComboEx()\Button\Image\Width  = ImageWidth(Image)
	      ComboEx()\Button\Image\Height = ImageHeight(Image)
	    EndIf
	    
	    Draw_()
	    
	  EndIf 

	  
	EndProcedure	
	
  Procedure   SetItemColor(GNum.i, Row.i, Color.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ComboEx()\ListView\Item()\Color = Color
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemData(GNum.i, Row.i, Value.q)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If SelectElement(ComboEx()\ListView\Item(), Row)
	      ComboEx()\ListView\Item()\Quad = Value
	    EndIf 
	    
	  EndIf
	  
	EndProcedure
	
	Procedure   SetItemImage(GNum.i, Row.i, Image.i, Flags.i=#False)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
  	  If SelectElement(ComboEx()\ListView\Item(), Row)
  	    
  	    If IsImage(Image)  
  	      ComboEx()\ListView\Item()\Image\Num    = Image
  	      ComboEx()\ListView\Item()\Image\Width  = ImageWidth(Image)
  	      ComboEx()\ListView\Item()\Image\Height = ImageHeight(Image)
  	      ComboEx()\ListView\Item()\Image\Flags  = Flags
  	      ComboEx()\ListView\Item()\Flags | #Image
  	    EndIf
  	    
  	  EndIf 
  	  
	  EndIf
	  
	EndProcedure	
	
	Procedure   SetItemText(GNum.i, Row.i, Text.s, Flags.i=#False)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
  	  If SelectElement(ComboEx()\ListView\Item(), Row)
  	    ComboEx()\ListView\Item()\String = Text
  	    ComboEx()\ListView\Item()\Flags | Flags
  	  EndIf 
  	  
	  EndIf
	  
	EndProcedure	
	
  Procedure   SetLabelText(GNum.i, Label.s, Text.s, Flags.i=#False)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
	    
	    If FindMapElement(ComboEx()\ListView\Index(), Label)
    	  If SelectElement(ComboEx()\ListView\Item(), ComboEx()\ListView\Index())
    	    ComboEx()\ListView\Item()\String = Text
    	    ComboEx()\ListView\Item()\Flags | Flags
    	  EndIf 
    	EndIf
    	
	  EndIf
	  
	EndProcedure
	
  Procedure   SetState(GNum.i, State.i)
	  
	  If FindMapElement(ComboEx(), Str(GNum))
      ComboEx()\ListView\State = State
    EndIf
    
	EndProcedure
	
  Procedure   SetText(GNum.i, Text.s) 
    
    If FindMapElement(ComboEx(), Str(GNum))
      
      If ComboEx()\Flags & #Editable
        
        ComboEx()\Text = Text
        
      Else
        
        ForEach ComboEx()\ListView\Item()
          If ComboEx()\ListView\Item()\String = Text
            ComboEx()\Text = Text
            ComboEx()\ListView\State = ListIndex(ComboEx()\ListView\Item())
            Break
          EndIf
        Next
        
      EndIf   
      Draw_()
    EndIf
    
  EndProcedure
  
EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Window  = 0
  
  Enumeration 1
    #ComboBox
    #ComboEx
    #Font
    #Image
  EndEnumeration
    
  If OpenWindow(#Window, 0, 0, 225, 60, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    LoadImage(#Image, "Test.png")
    
    ComboBoxGadget(#ComboBox, 15, 19, 90, 20) ; , #PB_ComboBox_Editable
    AddGadgetItem(#ComboBox, -1, "Item 1")
    AddGadgetItem(#ComboBox, -1, "Item 2")
    AddGadgetItem(#ComboBox, -1, "Item 3")
    
    If ComboBoxEx::Gadget(#ComboEx, 120, 19, 90, 80, "", #False, #Window)
      ; ComboBoxEx::#LowerCase / ComboBoxEx::#UpperCase / ComboBoxEx::#Editable / ComboBoxEx::#BorderLess
      
      ;ComboBoxEx::SetAttribute(#ComboEx, ComboBoxEx::#Corner, 4)
      ;ComboBoxEx::SetImage(#ComboEx, #Image)
      
      ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 1")
      ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 2")
      ComboBoxEx::AddItem(#ComboEx, ComboBoxEx::#LastItem, "Item 3")
      
      ComboBoxEx::SetItemImage(#ComboEx, 1, #Image)
      ComboBoxEx::SetItemImage(#ComboEx, 2, #Image, ComboBoxEx::#Right)
      
      ComboBoxEx::SetItemColor(#ComboEx, 0, #Red)
      
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #ComboEx
              Select EventType()
                Case #PB_EventType_Focus
                 ; Debug ">>> Focus"
                Case #PB_EventType_LostFocus
                 ; Debug ">>> LostFocus"
                Case ComboBoxEx::#EventType_Change
                  Debug ">>> Changed"
              EndSelect    
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 85
; FirstLine = 5
; Folding = IMAgAAAAAAAS9AAAgBgDAECAAAw
; EnableThread
; EnableXP
; DPIAware
; EnablePurifier