﻿;/ ============================
;/ =    StringExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x - V6.0 / 64Bit / all OS / DPI ]
;/
;/ © 2022 Thorsten1867 (03/2019)
;/

; Last Update: 20.06.22
;
; Bugfixxes
;
; - AddImage()
; - #Search & #ShowImage
;
; - #Style_Win11
; - InsertText()
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


;{ _____ StringEx - Commands _____

; StringEx::AddButton()          - adds a button to the gadget
; StringEx::AddImage()           - adds a image to the gadget
; StringEx::AddWords()           - add words to the autocomplete list
; StringEx::AttachPopupMenu()    - attach a popup menu to the gadget
; StringEx::Clear()              - clear gadget
; StringEx::Copy()               - copy selection to clipboard
; StringEx::Cut()                - cut selection to clipboard
; StringEx::Delete()             - delete selection
; StringEx::Free()               - similar To 'FreeGadget()'
; StringEx::GetAttribute()       - similar to 'GetGadgetAttribute()'
; StringEx::GetColor()           - similar to 'GetGadgetColor()'
; StringEx::GetText()            - similar to 'GetGadgetText()'
; StringEx::Gadget()             - similar to 'StringGadget()'
; StringEx::Hide()               - similar to 'HideGadget()'
; StringEx::InsertText()         - insert text at cursor position
; StringEx::Paste()              - paste clipboard
; StringEx::RemoveFlag()         - removes a flag
; StringEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; StringEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; StringEx::SetColor()           - similar to 'SetGadgetColor()'
; StringEx::SetFlags()           - sets one or more flags
; StringEx::SetInputMask()       - defines a input mask (e.g. time: "__:__" or money: "*.__$")
; StringEx::SetText()            - similar to 'SetGadgetText()'
; StringEx::Undo()               - undo last input

;}


;{ _____ Input Masks _____

; Floats:  "0.00" or "0,000"
; Time:    "00:00"
; Date:    "0000/00/00" or "00.00.0000")
; Cash:    "0.00$"
; License number: "____:____:____:____"

;}


; XIncludeFile "ModuleEx.pbi"

DeclareModule StringEx
  
  #Version  = 22062000
  #ModuleEx = 19120600
  
  #Enable_AutoComplete       = #True
  #Enable_ShowPasswordButton = #True
  #Enable_SearchImageButton  = #True
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  EnumerationBinary Flags
    #UpperCase     = #PB_String_UpperCase
    #LowerCase     = #PB_String_LowerCase
    #Password      = #PB_String_Password
    #NotEditable   = #PB_String_ReadOnly
    #Numeric       = #PB_String_Numeric
    #Borderless    = #PB_String_BorderLess
    #AutoComplete
    #AutoResize
    #ShowButton
    #ShowImage
    #Search
    #EventButton
    #Left
    #Right
    #Center
    #FocusBar
    #FitText
    #FixPadding
    #Background  ; Background text
    #Style_Win11
    #UseExistingCanvas
  EndEnumeration
  
  Enumeration Attribute 1
    #MaximumLength = #PB_String_MaximumLength
    #Padding
    #Corner
  EndEnumeration
  
  Enumeration Color 1 
    #FrontColor  = #PB_Gadget_FrontColor
    #BackColor   = #PB_Gadget_BackColor
    #BorderColor = #PB_Gadget_LineColor
    #FocusColor
    #FocusBarColor
    #CursorColor
    #GreyTextColor
    #HighlightColor
    #HighlightTextColor
  EndEnumeration
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Gadget       = ModuleEx::#Event_Gadget
    #Event_Theme        = ModuleEx::#Event_Theme
    
    #EventType_Focus     = ModuleEx::#EventType_Focus
    #EventType_LostFocus = ModuleEx::#EventType_LostFocus
    #EventType_Change    = ModuleEx::#EventType_Change
    #EventType_Button    = ModuleEx::#EventType_Button
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
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
  
  CompilerIf #Enable_AutoComplete
    
    Declare   AddWords(GNum.i, String.s, NoCase.i=#False, Seperator.s=" ")
    Declare   ClearWords(GNum.i)
    
  CompilerEndIf

  Declare   AddButton(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Event.i=#PB_Default)
  Declare   AddImage(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Event.i=#PB_Default)
  Declare   AttachPopupMenu(GNum.i, MenuNum.i)
  Declare   Clear(GNum.i)
  Declare   Copy(GNum.i)
  Declare   Cut(GNum.i)
  Declare   Delete(GNum.i)
  Declare   Disable(GNum.i, State.i=#True)
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare   Free(GNum.i)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.i GetColor(GNum.i, ColorType.i)
  Declare.s GetText(GNum.i) 
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   InsertText(GNum.i, Text.s)
  Declare   Paste(GNum.i)
  Declare   RemoveFlag(GNum.i, Flag.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFlags(GNum.i, Flags.i)
  Declare   SetFont(GNum.i, FontNum.i) 
  Declare   SetID(GNum.i, String.s)
  Declare   SetInputMask(GNum.i, Mask.s)
  Declare   SetText(GNum.i, Text.s, Type.i=#PB_Default) 
  Declare   Undo(GNum.i)
  
  CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Declare.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  Declare.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	  Declare.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	  
	CompilerEndIf
  
EndDeclareModule

Module StringEx
  
  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================
  
  #Timer           = 1867
	#Frequency       = 100  ; 100ms
	#CursorFrequency = 600  ; 600ms
	
  #ButtonWidth = 22
  
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
  
  CompilerIf #PB_Compiler_Unicode
    #PWChar = Chr($25CF)
  CompilerElse
    #PWChar = "*"
  CompilerEndIf
  
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure StrgEx_Mask_Structure    ;{ StrgEx()\Mask\...
    String.s
    Pos.i
    Delimiter.s
  EndStructure ;}
  
  Structure StrgEx_Font_Structure    ;{ StrgEx()\Font\...
	  Num.i
	  Name.s
	  Size.i
	  Style.i
	EndStructure ;}
  

  
  Structure StrgEx_Words_Structure   ;{ StrgEx()\AutoComplete\...
    Word.s
    NoCase.i
  EndStructure ;}
  
  Structure Selection_Structure      ;{ StrgEx()\Selection\
    Pos1.i
    Pos2.i
    Flag.i
  EndStructure ;}
  
  Structure StrgEx_Button_Structure  ;{ StrgEx()\Button\...
    X.f
    State.i
    ImgNum.i
    Width.f
    Height.f
    Event.i
  EndStructure ;}  
  
  Structure StrgEx_Cursor_Structure  ;{ StrgEx()\Cursor\...
    Pos.i ; 0: "|abc" / 1: "a|bc" / 2: "ab|c"  / 3: "abc|"
    X.i
    Y.i
    Height.i
    State.i
    Frequency.i
    Elapsed.i
    Delay.i
    Pause.i
  EndStructure ;}
  
  Structure StrgEx_Color_Structure   ;{ StrgEx()\Color\...
    Front.i
    Back.i
    Focus.i
    FocusBar.i
    Border.i
    Cursor.i
    Gadget.i
    GreyText.i
    DisableFront.i
    DisableBack.i
    Highlight.i
    HighlightText.i
    Button.i
    WordColor.i
  EndStructure ;}
  
  Structure StrgEx_Size_Structure    ;{ StrgEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Text.i
    Flags.i
  EndStructure ;} 
  
  Structure StrgEx_Window_Structure  ;{ StrgEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure StrgEx_Structure         ;{ StrgEx()\...
    CanvasNum.i
    PopupNum.i
    
    Thread.i
    
    ID.s
    Quad.q
    
    FontID.i
    
    Text.s
    BackText.s
    State.i
    
    OffSetX.i
    Mouse.i
    CanvasCursor.i
    
    Undo.s
    MaxLength.i
    Padding.i
    Radius.i
    
    Hide.i
    Disable.i
    Flags.i
    
    ; Fit Text
    PaddingX.i
    PaddingY.i
    PFactor.f
    
    Font.StrgEx_Font_Structure
    Mask.StrgEx_Mask_Structure
    
    Button.StrgEx_Button_Structure
    Color.StrgEx_Color_Structure
    Cursor.StrgEx_Cursor_Structure
    Selection.Selection_Structure
    Size.StrgEx_Size_Structure
    Window.StrgEx_Window_Structure
    
    List AutoComplete.StrgEx_Words_Structure()
  EndStructure ;}
  Global NewMap StrgEx.StrgEx_Structure()

  Global Mutex.i = CreateMutex()
  
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
  
  ;- ----- DPI -----
  
	Procedure.i dpiX(Num.i)
	  ProcedureReturn DesktopScaledX(Num) 
	EndProcedure

	Procedure.i dpiY(Num.i)
	  ProcedureReturn DesktopScaledY(Num)
	EndProcedure
	
	Procedure   TextHeight_(Text.s)
	  ProcedureReturn DesktopUnscaledY(TextHeight(Text))
	EndProcedure
	
	Procedure   TextWidth_(Text.s)
	  ProcedureReturn DesktopUnscaledX(TextWidth(Text))
	EndProcedure 
	
	Procedure   Line_(X.i, Y.i, Width.i, Height.i, Color.i=#PB_Default)
	  Line(dpiX(X), dpiY(Y), Width, Height, Color) 
	EndProcedure 
	
	Procedure   FillArea_(X.i, Y.i, OutlineColor.i, FillColor.i=#PB_Default)
	  FillArea(dpiX(X), dpiY(Y), OutlineColor, FillColor)
	EndProcedure
	
	Procedure   DrawText_(X.i, Y.i, Text.s, FrontColor.i=#PB_Default, BackColor.i=#PB_Default)
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
	
	Procedure   DrawImage_(Image.i, X.i, Y.i, Width.i=#False, Height.i=#False)
	  DrawImage(Image.i, dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height))	  
	EndProcedure
	
  Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i, Round.i=#False)
    
    If Round
      RoundBox(dpiX(X), dpiY(Y), Width, Height, dpiX(Round), dpiY(Round), Color)
    ElseIf StrgEx()\Radius
      Box(dpiX(X), dpiY(Y), Width, Height, StrgEx()\Color\Gadget)
			RoundBox(dpiX(X), dpiY(Y), Width, Height, dpiX(StrgEx()\Radius), dpiY(StrgEx()\Radius), Color)
		Else
			Box(dpiX(X), dpiY(Y), Width, Height, Color)
		EndIf
		
	EndProcedure  
	
  Procedure   ClipOutput_(X, Y, Width, Height)
    ClipOutput(dpiX(X), dpiY(Y), dpiX(Width), dpiY(Height)) 
  EndProcedure
  
  Procedure   UnclipOutput_()
    UnclipOutput() 
  EndProcedure
  

	
	;- ----------------
  
  CompilerIf #Enable_AutoComplete
    
    Procedure.i SelectAutoCompleteWord_()
      Define.s WordPart$
      
      ForEach StrgEx()\AutoComplete()
        
        WordPart$ = Left(StrgEx()\AutoComplete()\Word, Len(StrgEx()\Text))
        
        If StrgEx()\AutoComplete()\NoCase
  
          If LCase(WordPart$) = LCase(StrgEx()\Text)
            ProcedureReturn #True
          EndIf
          
        Else
          
          If WordPart$ = StrgEx()\Text
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      Next
     
      ResetList(StrgEx()\AutoComplete())
      
    EndProcedure
    
  CompilerEndIf  
  
  
  Procedure.i IsNumber(Char.i)
    Select Char
      Case 48 To 57
        ProcedureReturn #True
      Case 43 To 46
        ProcedureReturn #True
    EndSelect
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s DeleteStringPart_(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf

    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure
  
  Procedure.s DeleteMaskPart_(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    Define.i MaskPos
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf
    
    If StrgEx()\Mask\Delimiter
      
      StrgEx()\Mask\Pos = FindString(String, StrgEx()\Mask\Delimiter)

      MaskPos = (Position - StrgEx()\Mask\Pos) + 2

      If StrgEx()\Mask\Pos And Position < StrgEx()\Mask\Pos
        ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
      Else
        If Position = Len(String) : StrgEx()\Cursor\Pos - 1 : EndIf
        ProcedureReturn Left(String, Position - 1) + Mid(StrgEx()\Mask\String, MaskPos, 1) + Mid(String, Position + Length)
      EndIf 
      
    Else  
      ProcedureReturn Left(String, Position - 1) + Mid(StrgEx()\Mask\String, Position, 1) + Mid(String, Position + Length)
    EndIf
    
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
    StrgEx()\Selection\Pos1 = #False
    StrgEx()\Selection\Pos2 = #False
    StrgEx()\Selection\Flag = #NoSelection
  EndProcedure
  
  Procedure   DeleteSelection_() 
    
    If StrgEx()\Selection\Flag = #Selected
      
      StrgEx()\Undo = StrgEx()\Text
      
      If StrgEx()\Selection\Pos1 > StrgEx()\Selection\Pos2
        StrgEx()\Text = Left(StrgEx()\Text, StrgEx()\Selection\Pos2) + Mid(StrgEx()\Text, StrgEx()\Selection\Pos1 + 1)
        StrgEx()\Cursor\Pos = StrgEx()\Selection\Pos2
      Else
        StrgEx()\Text = Left(StrgEx()\Text, StrgEx()\Selection\Pos1) + Mid(StrgEx()\Text, StrgEx()\Selection\Pos2 + 1)
        StrgEx()\Cursor\Pos = StrgEx()\Selection\Pos1
      EndIf  
      
      RemoveSelection_() 
    EndIf
    
  EndProcedure
  
  
  Procedure   Copy_()
    Define.s Text
    
    StrgEx()\Undo = StrgEx()\Text
    
    If StrgEx()\Selection\Pos1 > StrgEx()\Selection\Pos2
      Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos2 + 1, StrgEx()\Selection\Pos1)
    Else
      Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos1 + 1, StrgEx()\Selection\Pos2)
    EndIf
    
    SetClipboardText(Text)
    RemoveSelection_()
    
  EndProcedure
  
  Procedure   Cut_()
    Define.s Text
    
    If Not StrgEx()\Flags & #NotEditable
      
      StrgEx()\Undo = StrgEx()\Text
      
      If StrgEx()\Selection\Pos1 > StrgEx()\Selection\Pos2
        Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos2 + 1, StrgEx()\Selection\Pos1)
      Else
        Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos1 + 1, StrgEx()\Selection\Pos2)
      EndIf
        
      SetClipboardText(Text)
      DeleteSelection_()
      RemoveSelection_()
      
    EndIf

  EndProcedure
  
  Procedure   Paste_(String.s="")
    Define.i c
    Define.s Text, Num, Char
    
    If Not StrgEx()\Flags & #NotEditable
      
      StrgEx()\Undo = StrgEx()\Text
      
      If String
        Text = String
      Else  
        Text = GetClipboardText()
      EndIf  
      
      If StrgEx()\Flags & #Numeric ;{ Numbers
        For c=1 To Len(Text)
          Char = Mid(Text, c, 1)
          If IsNumber(Asc(Char)) : Num + Char : EndIf
        Next
        Text = Num ;}
      EndIf
      
      If StrgEx()\Flags & #UpperCase : Text = UCase(Text) : EndIf
      If StrgEx()\Flags & #LowerCase : Text = LCase(Text) : EndIf
      
      If StrgEx()\Selection\Flag = #Selected
        DeleteSelection_()
        RemoveSelection_()
      EndIf
      
      StrgEx()\Text = InsertString(StrgEx()\Text, Text, StrgEx()\Cursor\Pos + 1)
      StrgEx()\Cursor\Pos + Len(Text)
      
      CompilerIf #Enable_AutoComplete
        
        If StrgEx()\Flags & #AutoComplete
          SelectAutoCompleteWord_()
        EndIf
        
      CompilerEndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   Undo_()
    Define.s Text
    
    Text = StrgEx()\Text
    StrgEx()\Text = StrgEx()\Undo
    StrgEx()\Undo = Text
    
  EndProcedure
  
  
  Procedure.i CursorPos_(CursorX.i)
    Define.s Text
    Define.i p, Pos.i

    If CursorX >= StrgEx()\OffSetX
      
      Text = StrgEx()\Text
      If StrgEx()\Flags & #Password And StrgEx()\Button\State & #Click = #False
        Text = LSet("", Len(StrgEx()\Text), #PWChar)
      Else
        Text = StrgEx()\Text
      EndIf
      
      If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
        DrawingFont(StrgEx()\FontID)
        For p=1 To Len(Text)
          Pos = p
          If StrgEx()\OffSetX + TextWidth_(Left(Text, p)) >= CursorX
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
  
  Procedure.i CursorX_(CursorPos.i) ; [ Needs StartDrawing() ]
    ; Pos 0: '|abc' / Pos1: 'a|bc'
    Define.s Text
    
    Text = StrgEx()\Text
    If StrgEx()\Flags & #Password And StrgEx()\Button\State & #Click = #False
      Text = LSet("", Len(StrgEx()\Text), #PWChar)
    EndIf
    
    If CursorPos > 0
      ProcedureReturn TextWidth_(Left(Text, CursorPos))
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  
  Procedure.i GetWordStart_(Pos.i) 
    Define.i p
    
    For p = Pos To 0 Step -1
      If Mid(StrgEx()\Text, p, 1) = " "
        ProcedureReturn p
      EndIf
    Next
    
    ProcedureReturn 0
  EndProcedure  
  
  Procedure.i GetWordEnd_(Pos.i) 
    Define.i p
    
    For p = Pos To Len(StrgEx()\Text)
      If Mid(StrgEx()\Text, p, 1) = " "
        ProcedureReturn p - 1
      EndIf
    Next
    
    ProcedureReturn Len(StrgEx()\Text)
  EndProcedure
  
  Procedure   UseInputMask_(Char$)
    Define.i c, txtLen, maskLen, MaskPos
    Define.s Text$
    
    Text$   = StrgEx()\Text
    txtLen  = Len(StrgEx()\Text)
    maskLen = Len(StrgEx()\Mask\String)
    
    If StrgEx()\Mask\Delimiter

      StrgEx()\Mask\Pos = FindString(Text$, StrgEx()\Mask\Delimiter)
      If StrgEx()\Mask\Pos
        
        If Char$ = StrgEx()\Mask\Delimiter
          If Mid(Text$, StrgEx()\Cursor\Pos + 1, 1) = StrgEx()\Mask\Delimiter
            StrgEx()\Cursor\Pos + 1
          EndIf  
          ProcedureReturn #False
        EndIf
        
        If StrgEx()\Cursor\Pos >= StrgEx()\Mask\Pos

          If StrgEx()\Cursor\Pos = txtLen ;{ add at the end
            
            StrgEx()\Cursor\Pos + 1
            
            MaskPos = (StrgEx()\Cursor\Pos - StrgEx()\Mask\Pos) + 2
            For c = MaskPos To maskLen

              If Mid(StrgEx()\Mask\String, c, 1) = "_"
                StrgEx()\Text + Char$
                Break  
              ElseIf Mid(StrgEx()\Mask\String, c, 1) = "0"
                If Char$ = "+" Or Char$ = "-" : Break : EndIf
                If IsNumber(Asc(Char$)) : StrgEx()\Text + Char$ :EndIf 
                Break 
              ElseIf Mid(StrgEx()\Mask\String, c, 1) = Char$
                If Mid(Text$, StrgEx()\Cursor\Pos, 1) <> Char$
                  StrgEx()\Text + Char$
                EndIf  
                Break
              Else
                StrgEx()\Text + Mid(StrgEx()\Mask\String, c, 1)
                StrgEx()\Cursor\Pos + 1
              EndIf

            Next  
            ;}
          Else                            ;{ within the string
            
            MaskPos = (StrgEx()\Cursor\Pos - StrgEx()\Mask\Pos) + 2
            For c = MaskPos To maskLen

              If Mid(StrgEx()\Mask\String, c + 1, 1) = "_"
                StrgEx()\Text = Left(Text$, StrgEx()\Cursor\Pos) + Char$ + Mid(Text$, StrgEx()\Cursor\Pos + 2)
                StrgEx()\Cursor\Pos + 1
                Break  
              ElseIf Mid(StrgEx()\Mask\String, c + 1, 1) = "0"
                If IsNumber(Asc(Char$))
                  If Char$ = "+" Or Char$ = "-" : Break : EndIf
                  StrgEx()\Text = Left(Text$, StrgEx()\Cursor\Pos) + Char$ + Mid(Text$, StrgEx()\Cursor\Pos + 2)
                  StrgEx()\Cursor\Pos + 1
                EndIf  
                Break 
              ElseIf Mid(StrgEx()\Mask\String, c + 1, 1) = Char$
                StrgEx()\Text = Left(Text$, StrgEx()\Cursor\Pos) + Char$ + Mid(Text$, StrgEx()\Cursor\Pos + 2)
                StrgEx()\Cursor\Pos + 1
                Break
              Else
                StrgEx()\Text = Left(Text$, StrgEx()\Cursor\Pos) + Mid(StrgEx()\Mask\String, c + 1, 1) + Mid(Text$, StrgEx()\Cursor\Pos + 2)
                StrgEx()\Cursor\Pos + 1
              EndIf

            Next
             ;}
          EndIf
         
        Else
          
          Select Char$
            Case "-"
              If CountString(Text$, "-") : ProcedureReturn #False : EndIf
            Case "+"
              If CountString(Text$, "+") : ProcedureReturn #False : EndIf
          EndSelect
          
          StrgEx()\Cursor\Pos + 1
          StrgEx()\Text = InsertString(Text$, Char$, StrgEx()\Cursor\Pos)
        EndIf  
        
      Else
        
        Select Char$
          Case "-"
            If CountString(Text$, "-") : ProcedureReturn #False : EndIf
          Case "+"
            If CountString(Text$, "+") : ProcedureReturn #False : EndIf
        EndSelect
        
        StrgEx()\Cursor\Pos + 1
        StrgEx()\Text = InsertString(Text$, Char$, StrgEx()\Cursor\Pos)
        
      EndIf
      
    Else
  
      If StrgEx()\Cursor\Pos = txtLen ;{ add at the end
        
        If StrgEx()\Cursor\Pos >= maskLen : ProcedureReturn #False : EndIf
        
        StrgEx()\Cursor\Pos + 1
        
        For c = StrgEx()\Cursor\Pos To maskLen
  
          If Mid(StrgEx()\Mask\String, c, 1) = "_"
            StrgEx()\Text + Char$
            Break
          ElseIf Mid(StrgEx()\Mask\String, c, 1) = "0"
            Select Char$
              Case "+"
                If CountString(StrgEx()\Text, "+") : Break : EndIf
              Case "-"
                If CountString(StrgEx()\Text, "-") : Break : EndIf
            EndSelect    
            If IsNumber(Asc(Char$)) : StrgEx()\Text + Char$ :EndIf 
            Break 
          ElseIf Mid(StrgEx()\Mask\String, c, 1) = Char$
            StrgEx()\Text + Char$
            Break
          Else 
            StrgEx()\Cursor\Pos + 1
            StrgEx()\Text + Mid(StrgEx()\Mask\String, c, 1)
          EndIf
          
        Next
        ;}
      Else                            ;{ within the string
        
        For c = StrgEx()\Cursor\Pos To maskLen
          
          If Mid(StrgEx()\Mask\String, c + 1, 1) = "_"
            Text$ = Left(Text$, c) + Char$ + Mid(Text$, c + 2)
            StrgEx()\Cursor\Pos + 1
            Break
          ElseIf Mid(StrgEx()\Mask\String, c + 1, 1) = "0"
            Select Char$
              Case "+"
                If CountString(StrgEx()\Text, "+") : Break : EndIf
              Case "-"
                If CountString(StrgEx()\Text, "-") : Break : EndIf
            EndSelect    
            If IsNumber(Asc(Char$))
              StrgEx()\Text + Char$
              Text$ = Left(Text$, c) + Char$ + Mid(Text$, c + 2)
            EndIf 
            Break
          ElseIf Mid(StrgEx()\Mask\String, c + 1, 1) = Char$
            Text$ = Left(Text$, c) + Char$ + Mid(Text$, c + 2)
            StrgEx()\Cursor\Pos + 1
            Break
          Else 
            Text$ = Left(Text$, c) + Mid(StrgEx()\Mask\String, c + 1, 1) + Mid(Text$, c + 2)
            StrgEx()\Cursor\Pos + 1
          EndIf
          
        Next
        
        StrgEx()\Text = Left(Text$, maskLen)
        ;}
      EndIf  
      
    EndIf
    
  EndProcedure
  
  ;- ==================================
  ;-   Module - Drawing
	;- ==================================
  
  Procedure.f GetOffsetX_(Text.s, Width.i, OffsetX.i) 
    
    If StrgEx()\Flags & #Center
      ProcedureReturn (Width - TextWidth_(Text)) / 2
    ElseIf StrgEx()\Flags & #Right
      ProcedureReturn Width - TextWidth_(Text) - OffsetX
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
  
  Procedure   Image_()
    Define.f X, Y, Height
    
    Height = GadgetHeight(StrgEx()\CanvasNum)
    
    StrgEx()\Button\X = GadgetWidth(StrgEx()\CanvasNum) - Height
    
    If IsImage(StrgEx()\Button\ImgNum)
      X = StrgEx()\Button\X + ((Height - StrgEx()\Button\Width - 2)  / 2)
      Y = (Height - StrgEx()\Button\Height) / 2
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      If IsImage(StrgEx()\Button\ImgNum)
        
        If StrgEx()\Button\State & #Click
          DrawImage_(ImageID(StrgEx()\Button\ImgNum), X + 1, Y + 1, StrgEx()\Button\Width - 4, StrgEx()\Button\Height - 4)
        Else
          DrawImage_(ImageID(StrgEx()\Button\ImgNum), X, Y, StrgEx()\Button\Width - 2, StrgEx()\Button\Height - 2)
        EndIf
        
      EndIf  
    EndIf
    
  EndProcedure  
  
  Procedure   Button_(BorderColor.i)
    Define.f X, Y
    
    StrgEx()\Button\X = GadgetWidth(StrgEx()\CanvasNum) - #ButtonWidth
    
    Line_(StrgEx()\Button\X, 0, 1, GadgetHeight(StrgEx()\CanvasNum), BorderColor)
    
    If StrgEx()\Button\State & #Click
      DrawingMode(#PB_2DDrawing_Default)
      FillArea_(StrgEx()\Button\X + 1, 1, BorderColor, BlendColor_(StrgEx()\Color\Focus, StrgEx()\Color\Button, 20))
    ElseIf StrgEx()\Button\State & #Focus
      DrawingMode(#PB_2DDrawing_Default)
      FillArea_(StrgEx()\Button\X + 1, 1, BorderColor, BlendColor_(StrgEx()\Color\Focus, StrgEx()\Color\Button, 15))
    Else
      DrawingMode(#PB_2DDrawing_Default)
      FillArea_(StrgEx()\Button\X + 1, 1, BorderColor, StrgEx()\Color\Button)
    EndIf 
    
    If IsImage(StrgEx()\Button\ImgNum)
      X = StrgEx()\Button\X + ((#ButtonWidth - StrgEx()\Button\Width)  / 2)
      Y = (GadgetHeight(StrgEx()\CanvasNum)  - StrgEx()\Button\Height) / 2
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      If IsImage(StrgEx()\Button\ImgNum)
        DrawImage_(ImageID(StrgEx()\Button\ImgNum), X, Y, StrgEx()\Button\Width, StrgEx()\Button\Height)
      EndIf  
    EndIf
    
  EndProcedure
  
  Procedure   DrawFocusBar()
    Define.i Y, Width
    
    If StrgEx()\Disable : ProcedureReturn #False : EndIf 
    
    Y     = GadgetHeight(StrgEx()\CanvasNum) - 2
    Width = GadgetWidth(StrgEx()\CanvasNum)
    
    If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
      
      If StrgEx()\State & #Focus
        Box_(0, Y, Width, 2, StrgEx()\Color\Focus)
      Else
        Box_(0, Y + 1, Width, 1, StrgEx()\Color\FocusBar)
      EndIf  
      
      StopDrawing()
    EndIf  
    
  EndProcedure
  
  
  Procedure   Draw_()
    Define.i X, Y, Height, Width, startX, CursorX, p
    Define.i TextColor, BackColor, BorderColor, CursorColor
    Define.s Text, Word, strgPart
    
    If StrgEx()\Hide : ProcedureReturn #False : EndIf
    
    If StrgEx()\MaxLength <> #PB_Default
      If Len(StrgEx()\Text) > StrgEx()\MaxLength
        StrgEx()\Text = Left(StrgEx()\Text, StrgEx()\MaxLength)
      EndIf
    EndIf

    If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
      
      TextColor   = StrgEx()\Color\Front
      BackColor   = StrgEx()\Color\Back
      BorderColor = StrgEx()\Color\Border
      
      If StrgEx()\State & #Focus And StrgEx()\Flags & #Style_Win11 = #False
        BorderColor = StrgEx()\Color\Focus
      EndIf
      
      If StrgEx()\Disable
        TextColor   = StrgEx()\Color\DisableFront
        BackColor   = BlendColor_(StrgEx()\Color\DisableBack, StrgEx()\Color\Gadget, 10)
        If StrgEx()\Flags & #Style_Win11
          BorderColor = $FBFBFB
        Else  
          BorderColor = StrgEx()\Color\DisableBack
        EndIf  
      EndIf  

      Height = GadgetHeight(StrgEx()\CanvasNum)
      Width  = GadgetWidth(StrgEx()\CanvasNum)

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box_(0, 0, Width, Height, BackColor)       
      ;}
      
      If StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton Or StrgEx()\Flags & #ShowImage
        Width - StrgEx()\Button\Width - 1
      EndIf

      StrgEx()\Size\Text = Width
      
      ClipOutput_(0, 0, Width, Height)

      DrawingFont(StrgEx()\FontID)

      ;{ _____ Text _____
      If StrgEx()\Text

        If StrgEx()\Flags & #Password And StrgEx()\Button\State & #Click = #False
          Text = LSet("", Len(StrgEx()\Text), #PWChar)
        Else
          Text = StrgEx()\Text
        EndIf
        
        X = GetOffsetX_(Text, Width, StrgEx()\Padding)
        
        CursorX = X + TextWidth_(Left(Text, StrgEx()\Cursor\Pos))
        If CursorX > Width
          Text = Left(Text, StrgEx()\Cursor\Pos)
          For p = Len(Text) To 0 Step -1
            If X + TextWidth_(Right(Text, p)) < Width
              Text = Right(Text, p)
              Break  
            EndIf 
          Next 
        EndIf
        
        Y = (Height - TextHeight_(Text)) / 2
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText_(X, Y, Text, TextColor)
        StrgEx()\OffSetX = X
        
        CompilerIf #Enable_AutoComplete
          
          If StrgEx()\Flags & #AutoComplete And StrgEx()\Flags & #Password = #False
            If ListIndex(StrgEx()\AutoComplete()) <> -1
              Word = Mid(StrgEx()\AutoComplete()\Word, Len(Text) + 1)
              DrawingMode(#PB_2DDrawing_Default)
              DrawText_(X + TextWidth_(Text) + 1, Y, Word, StrgEx()\Color\WordColor, BlendColor_(StrgEx()\Color\Highlight, $FFFFFF, 3))
            EndIf
          EndIf
          
        CompilerEndIf

      Else
        
        If StrgEx()\BackText
          
          X = GetOffsetX_(StrgEx()\BackText, Width, StrgEx()\Padding)
          Y = (Height - TextHeight_(StrgEx()\BackText)) / 2
          
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText_(X, Y, StrgEx()\BackText, StrgEx()\Color\GreyText)
          StrgEx()\OffSetX = X
          
        EndIf  
        
        If StrgEx()\Flags & #Center
          X = Width / 2
        ElseIf StrgEx()\Flags & #Right
          X = Width - StrgEx()\Padding
        Else
          X = StrgEx()\Padding
        EndIf
        
        Y = (Height - TextHeight_("X")) / 2  
        
      EndIf
      ;}
      
      ;{ _____ Selection ______
      If StrgEx()\Selection\Flag = #Selected
        
        If StrgEx()\Selection\Pos1 >  StrgEx()\Selection\Pos2
          startX   = CursorX_(StrgEx()\Selection\Pos2)
          strgPart = StringSegment_(Text, StrgEx()\Selection\Pos2 + 1, StrgEx()\Selection\Pos1)
        Else
          startX   = CursorX_(StrgEx()\Selection\Pos1)
          strgPart = StringSegment_(Text, StrgEx()\Selection\Pos1 + 1, StrgEx()\Selection\Pos2)
        EndIf
        
        StrgEx()\Cursor\Pos = StrgEx()\Selection\Pos2
        
        DrawingMode(#PB_2DDrawing_Default)
        DrawText_(X + startX, Y, strgPart, StrgEx()\Color\HighlightText, StrgEx()\Color\Highlight)

      EndIf 
      ;}
      
      ;{ _____ Cursor _____
      If StrgEx()\Cursor\Pos
        X + TextWidth_(Left(Text, StrgEx()\Cursor\Pos))
      EndIf
      StrgEx()\Cursor\Height = TextHeight_("X")
      StrgEx()\Cursor\X = X
      StrgEx()\Cursor\Y = Y
      If StrgEx()\Cursor\Pause = #False
        Line_(StrgEx()\Cursor\X, StrgEx()\Cursor\Y, 1, StrgEx()\Cursor\Height, StrgEx()\Color\Cursor)
      EndIf   
      ;}
      
      UnClipOutput_()
      
      If StrgEx()\Flags & #ShowImage
        Image_()
      ElseIf StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton
        Button_(BorderColor)
      EndIf

      ;{ _____ Border ____
      If StrgEx()\Flags & #Borderless = #False
        DrawingMode(#PB_2DDrawing_Outlined)
        Box_(0, 0, GadgetWidth(StrgEx()\CanvasNum), Height, BorderColor)
      EndIf
      ;}
      
      StopDrawing()
    EndIf

    If StrgEx()\Flags & #Style_Win11 : DrawFocusBar() : EndIf
    
  EndProcedure
  
  ;- ==================================
  ;-   Module - Events
	;- ==================================
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach StrgEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          StrgEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        StrgEx()\Color\Front         = ModuleEx::ThemeGUI\FrontColor
        StrgEx()\Color\Back          = ModuleEx::ThemeGUI\BackColor
        StrgEx()\Color\Focus         = ModuleEx::ThemeGUI\Focus\BackColor
        StrgEx()\Color\Border        = ModuleEx::ThemeGUI\BorderColor
        StrgEx()\Color\Gadget        = ModuleEx::ThemeGUI\GadgetColor
        StrgEx()\Color\GreyText      = ModuleEx::ThemeGUI\GreyTextColor
        StrgEx()\Color\Cursor        = ModuleEx::ThemeGUI\FrontColor
        StrgEx()\Color\Button        = ModuleEx::ThemeGUI\Button\BackColor
        StrgEx()\Color\HighlightText = ModuleEx::ThemeGUI\Focus\FrontColor
        StrgEx()\Color\Highlight     = ModuleEx::ThemeGUI\Focus\BackColor
        StrgEx()\Color\DisableFront  = ModuleEx::ThemeGUI\Disable\FrontColor
        StrgEx()\Color\DisableBack   = ModuleEx::ThemeGUI\Disable\BackColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf   
  
  
  Procedure _TimerHandler()
  
    LockMutex(Mutex)
    
    ForEach StrgEx()
      
      If StrgEx()\Cursor\Pause = #False
        
        If Not IsGadget(StrgEx()\CanvasNum) : Continue : EndIf 
        
        StrgEx()\Cursor\Delay + 100
        If StrgEx()\Cursor\Delay >= StrgEx()\Cursor\Frequency
          StrgEx()\Cursor\Delay = 0
        Else
          Continue
        EndIf   

        ;{ Draw Cursor
        StrgEx()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
          
          DrawingMode(#PB_2DDrawing_Default)
          
          If StrgEx()\Cursor\Pause
            
            Line_(StrgEx()\Cursor\X, StrgEx()\Cursor\Y, 1, StrgEx()\Cursor\Height, StrgEx()\Color\Back)
            
          Else
            
            If StrgEx()\Cursor\State
              Line_(StrgEx()\Cursor\X, StrgEx()\Cursor\Y, 1, StrgEx()\Cursor\Height, $000000)
            Else
              Line_(StrgEx()\Cursor\X, StrgEx()\Cursor\Y, 1, StrgEx()\Cursor\Height, StrgEx()\Color\Back)
            EndIf
            
          EndIf
          
          StopDrawing()
        EndIf
        ;}
        
      EndIf

    Next  
    
    UnlockMutex(Mutex)
    
  EndProcedure
  
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\State | #Focus
      Draw_()
      
      StrgEx()\Cursor\State = #False
      StrgEx()\Cursor\Pause = #False
      
      PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Focus)
    EndIf
    
  EndProcedure  
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\Cursor\Pause = #True
      
      StrgEx()\State & ~#Focus
      StrgEx()\Button\State & ~#Focus
      ResetList(StrgEx()\AutoComplete())
      Draw_()
      
      PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_LostFocus)
    EndIf
    
  EndProcedure    
  
  
  Procedure _InputHandler()
    Define.s Char$
    Define.i Char
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))

      If StrgEx()\State & #Focus And Not StrgEx()\Flags & #NotEditable
        
        If Len(StrgEx()\Text) < StrgEx()\MaxLength Or StrgEx()\MaxLength = #PB_Default
          
          Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
          
          If StrgEx()\Flags & #Numeric And IsNumber(Char) = #False
            ProcedureReturn #False
          EndIf
          
          If Char >= 32
            
            If StrgEx()\Selection\Flag = #Selected
              DeleteSelection_()
            EndIf
            
            Char$ =  Chr(Char)
            If StrgEx()\Flags & #UpperCase : Char$ = UCase(Char$) : EndIf
            If StrgEx()\Flags & #LowerCase : Char$ = LCase(Char$) : EndIf
            
            If StrgEx()\Mask\String
              UseInputMask_(Char$)
            Else  
              StrgEx()\Cursor\Pos + 1
              StrgEx()\Text = InsertString(StrgEx()\Text, Char$, StrgEx()\Cursor\Pos)
            EndIf

            CompilerIf #Enable_AutoComplete
              
              If StrgEx()\Flags & #AutoComplete
                SelectAutoCompleteWord_()
              EndIf
              
            CompilerEndIf
            
            PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
          EndIf
          
          Draw_()
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure   
  
  Procedure _KeyDownHandler()
    Define.i Key, Modifier
    Define.s Text
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If StrgEx()\State & #Focus
        
        Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
        Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
        
        Select Key
          Case #PB_Shortcut_Left      ;{ Cursor left
            If Modifier & #PB_Canvas_Shift
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = StrgEx()\Cursor\Pos
                StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos - 1
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 - 1
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
              If StrgEx()\Cursor\Pos > 0
                StrgEx()\Cursor\Pos - 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = GetWordEnd_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Pos2 = GetWordStart_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 = GetWordStart_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
            Else
              
              If StrgEx()\Cursor\Pos > 0
                StrgEx()\Cursor\Pos - 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_Right     ;{ Cursor right
            If Modifier & #PB_Canvas_Shift
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = StrgEx()\Cursor\Pos
                StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos + 1
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 + 1
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
              If StrgEx()\Cursor\Pos < Len(StrgEx()\Text)
                StrgEx()\Cursor\Pos + 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = GetWordStart_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Pos2 = GetWordEnd_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 = GetWordEnd_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
            Else
              
              If StrgEx()\Flags & #AutoComplete And ListIndex(StrgEx()\AutoComplete()) <> -1
                StrgEx()\Text = StrgEx()\AutoComplete()\Word
                StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
                ResetList(StrgEx()\AutoComplete())
              Else
                If StrgEx()\Cursor\Pos < Len(StrgEx()\Text)
                  StrgEx()\Cursor\Pos + 1
                EndIf
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_End       ;{ Cursor end of chars
            StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Home      ;{ Cursor position 0
            StrgEx()\Cursor\Pos = 0
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Back      ;{ Delete Back
            If Not StrgEx()\Flags & #NotEditable
              If StrgEx()\Selection\Flag = #Selected
                DeleteSelection_()
                RemoveSelection_()
              Else
                If StrgEx()\Cursor\Pos > 0
                  If StrgEx()\Mask\String
                    StrgEx()\Text = DeleteMaskPart_(StrgEx()\Text, StrgEx()\Cursor\Pos) 
                  Else  
                    StrgEx()\Text = DeleteStringPart_(StrgEx()\Text, StrgEx()\Cursor\Pos) 
                  EndIf
                  StrgEx()\Cursor\Pos - 1
                EndIf
                RemoveSelection_()
              EndIf 
              PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
            EndIf ;}
          Case #PB_Shortcut_Delete    ;{ Delete / Cut (Shift)
            If Modifier & #PB_Canvas_Shift ;{ Cut selected text
              Cut_()
              ;}
            Else                           ;{ Delete text
              If Not StrgEx()\Flags & #NotEditable
                If StrgEx()\Selection\Flag = #Selected
                  DeleteSelection_()
                  RemoveSelection_()
                Else
                  If StrgEx()\Cursor\Pos < Len(StrgEx()\Text)
                    If StrgEx()\Mask\String
                      StrgEx()\Text = DeleteMaskPart_(StrgEx()\Text, StrgEx()\Cursor\Pos + 1)
                    Else  
                      StrgEx()\Text = DeleteStringPart_(StrgEx()\Text, StrgEx()\Cursor\Pos + 1)
                    EndIf  
                    RemoveSelection_()
                  EndIf
                EndIf
              EndIf ;}
            EndIf
            PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
            PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
            ;} 
          Case #PB_Shortcut_Insert    ;{ Copy (Ctrl) / Paste (Shift)
            If Modifier & #PB_Canvas_Shift
              Paste_()
              PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
            ElseIf Modifier & #PB_Canvas_Control
              Copy_()
            EndIf ;}  
          Case #PB_Shortcut_A         ;{ Ctrl-A (Select all)
            If Modifier & #PB_Canvas_Control
              StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
              StrgEx()\Selection\Pos1 = 0
              StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos
              StrgEx()\Selection\Flag = #Selected
            EndIf ;}
          Case #PB_Shortcut_C         ;{ Copy   (Ctrl)  
            If Modifier & #PB_Canvas_Control
              Copy_()
            EndIf  
            ;}
          Case #PB_Shortcut_X         ;{ Cut    (Ctrl) 
            If Modifier & #PB_Canvas_Control
              Cut_()
              PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
              PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
            EndIf
            ;}
          Case #PB_Shortcut_D         ;{ Ctrl-D (Delete selection)
            If Not StrgEx()\Flags & #NotEditable
              If Modifier & #PB_Canvas_Control
                DeleteSelection_()
                PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
              EndIf 
            EndIf ;} 
          Case #PB_Shortcut_V         ;{ Paste  (Ctrl) 
            If Not StrgEx()\Flags & #NotEditable
              If Modifier & #PB_Canvas_Control
                Paste_()
                PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
              EndIf
            EndIf ;} 
          Case #PB_Shortcut_Z         ;{ Crtl-Z (Undo)  
            If Not StrgEx()\Flags & #NotEditable
              If Modifier & #PB_Canvas_Control
                Undo_()
                PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
                PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
              EndIf 
            EndIf
            ;}
          Case #PB_Shortcut_Return    ;{ Return
            If StrgEx()\Flags & #AutoComplete And ListIndex(StrgEx()\AutoComplete()) <> -1
              StrgEx()\Text = StrgEx()\AutoComplete()\Word
              StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
              ResetList(StrgEx()\AutoComplete())
            EndIf  
            ;}
          Case #PB_Shortcut_Tab       ;{ Tabulator
            If StrgEx()\Flags & #AutoComplete And ListIndex(StrgEx()\AutoComplete()) <> -1
              StrgEx()\Text = StrgEx()\AutoComplete()\Word
              StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
              ResetList(StrgEx()\AutoComplete())
            EndIf  
            ;}
        EndSelect
        
       Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure _LeftButtonDownHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))

      If StrgEx()\Mouse = #Mouse_Move
        StrgEx()\Cursor\Pos = CursorPos_(X)
      EndIf
      
      StrgEx()\State | #Focus
      
      If X > StrgEx()\Button\X
      
        If StrgEx()\Button\State & #Focus
          If StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton Or StrgEx()\Flags & #ShowImage
            StrgEx()\Button\State | #Click
          EndIf
        EndIf
        
      EndIf
      
      If StrgEx()\Selection\Flag = #Selected
        RemoveSelection_()
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftButtonUpHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      
      If StrgEx()\Flags & #ShowButton
        
        StrgEx()\Button\State & ~#Click
        
      ElseIf StrgEx()\Flags & #EventButton Or StrgEx()\Flags & #ShowImage

        
        If X > StrgEx()\Button\X And StrgEx()\Button\State & #Click
          
          If IsWindow(StrgEx()\Window\Num)
            If StrgEx()\Button\Event = #PB_Default
              PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Button)
              PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum,    #EventType_Button)
            Else
              PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\Button\Event)
              PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\Button\Event)
            EndIf
          EndIf
          
          StrgEx()\Button\State & ~#Click
        EndIf
        
      EndIf
      
      If StrgEx()\Mouse = #Mouse_Select
        StrgEx()\Cursor\Pos     = CursorPos_(X)
        StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos
        StrgEx()\Mouse = #Mouse_Move
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure 
  
  Procedure _LeftDoubleClickHandler()
    Define.i X, Pos
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      If StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton 
        If X > StrgEx()\Button\X
          ProcedureReturn #False
        EndIf
      EndIf
      
      Pos = CursorPos_(X)
      If Pos
        StrgEx()\Selection\Pos1 = GetWordStart_(Pos)
        StrgEx()\Selection\Pos2 = GetWordEnd_(Pos)
        StrgEx()\Selection\Flag = #Selected
        StrgEx()\Cursor\Pos     = StrgEx()\Selection\Pos2
      EndIf
    
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure _MouseEnterHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\Button\State & #Focus
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))

      StrgEx()\Button\State & ~#Focus
      ResetList(StrgEx()\AutoComplete())
      
      Draw_()
    EndIf
    
  EndProcedure  
  
  Procedure _MouseMoveHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = DesktopUnscaledX(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      If GetGadgetAttribute(GNum, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton ;{ Left mouse button pressed
        
        Select StrgEx()\Mouse
          Case #Mouse_Move   ;{ Start selection
            If StrgEx()\Selection\Flag = #NoSelection
              StrgEx()\Selection\Pos1 = StrgEx()\Cursor\Pos
              StrgEx()\Selection\Pos2 = CursorPos_(X)
              StrgEx()\Selection\Flag = #Selected
              StrgEx()\Mouse = #Mouse_Select
              Draw_()
            EndIf ;}
          Case #Mouse_Select ;{ Continue selection
            StrgEx()\Selection\Pos2 = CursorPos_(X)
            StrgEx()\Cursor\Pos     = StrgEx()\Selection\Pos2
            Draw_() ;}
        EndSelect
        ;}
      Else
        
        If StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton Or StrgEx()\Flags & #ShowImage
          
          If X > StrgEx()\Button\X
            StrgEx()\Button\State | #Focus
            If StrgEx()\CanvasCursor <> #PB_Cursor_Default
              SetGadgetAttribute(StrgEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
              StrgEx()\CanvasCursor = #PB_Cursor_Default
            EndIf
          Else
            StrgEx()\Button\State & ~#Focus
            If StrgEx()\CanvasCursor <> #PB_Cursor_IBeam
              SetGadgetAttribute(StrgEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
              StrgEx()\CanvasCursor = #PB_Cursor_IBeam
            EndIf
          EndIf
        
          Draw_()
        Else
          If StrgEx()\CanvasCursor <> #PB_Cursor_IBeam
            SetGadgetAttribute(StrgEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
            StrgEx()\CanvasCursor = #PB_Cursor_IBeam
          EndIf
        EndIf
        
        StrgEx()\Mouse = #Mouse_Move
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _RightClickHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      If IsWindow(StrgEx()\Window\Num)
        DisplayPopupMenu(StrgEx()\PopupNum, WindowID(StrgEx()\Window\Num))
      EndIf
    EndIf
    
  EndProcedure
  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GadgetID))      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.i FontSize
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach StrgEx()
      
      If IsGadget(StrgEx()\CanvasNum)
        
        If StrgEx()\Flags & #AutoResize
          
          If IsWindow(StrgEx()\Window\Num)
            
            OffSetX = WindowWidth(StrgEx()\Window\Num)  - StrgEx()\Window\Width
            OffsetY = WindowHeight(StrgEx()\Window\Num) - StrgEx()\Window\Height

            If StrgEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If StrgEx()\Size\Flags & #MoveX  : X = StrgEx()\Size\X + OffSetX : EndIf
              If StrgEx()\Size\Flags & #MoveY  : Y = StrgEx()\Size\Y + OffSetY : EndIf
              If StrgEx()\Size\Flags & #Width  : Width  = StrgEx()\Size\Width  + OffSetX : EndIf
              If StrgEx()\Size\Flags & #Height : Height = StrgEx()\Size\Height + OffSetY : EndIf
              
              ResizeGadget(StrgEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(StrgEx()\CanvasNum, #PB_Ignore, #PB_Ignore, StrgEx()\Size\Width + OffSetX, StrgEx()\Size\Height + OffsetY)
            EndIf
            
            CompilerIf Defined(ModuleEx, #PB_Module)
			
        		  If StrgEx()\Size\Flags & #FitText
        		    
        		    If StrgEx()\Size\Flags & #FixPadding
        		      Width  = StrgEx()\Size\Text - StrgEx()\PaddingX
                  Height = GadgetHeight(StrgEx()\CanvasNum) - StrgEx()\PaddingY
        		    Else
        		      Width  = StrgEx()\Size\Text - StrgEx()\PaddingX
                  Height = GadgetHeight(StrgEx()\CanvasNum) - (GadgetHeight(StrgEx()\CanvasNum) * StrgEx()\PFactor)
        		    EndIf
        		    
        		    If Height < 0 : Height = 0 : EndIf 
        		    If Width  < 0 : Width  = 0 : EndIf
        		    
        		    FontSize = ModuleEx::RequiredFontSize(StrgEx()\Text, Width, Height, StrgEx()\Font\Num)
        		    
        		    If FontSize <> StrgEx()\Font\Size
                  StrgEx()\Font\Size = FontSize
                  StrgEx()\Font\Num  = ModuleEx::Font(StrgEx()\Font\Name, FontSize, StrgEx()\Font\Style)
                  If IsFont(StrgEx()\Font\Num) : StrgEx()\FontID = FontID(StrgEx()\Font\Num) : EndIf
                EndIf  
        		    
        		  EndIf  
  		  
  		      CompilerEndIf 
            
            Draw_()
          EndIf

        EndIf
        
      EndIf
      
    Next
    
  EndProcedure  
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach StrgEx()
    
      If StrgEx()\Window\Num = Window

        DeleteMapElement(StrgEx())
        
      EndIf
      
    Next
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  CompilerIf #Enable_AutoComplete
  
    Procedure   AddWords(GNum.i, String.s, NoCase.i=#False, Seperator.s=" ")
      Define.i Count, w
      
      If FindMapElement(StrgEx(), Str(GNum))
        
        Count = CountString(String, Seperator) + 1
        For w=1 To Count
          If AddElement(StrgEx()\AutoComplete())
            StrgEx()\AutoComplete()\Word   = StringField(String, w, Seperator)
            StrgEx()\AutoComplete()\NoCase = NoCase
          EndIf
        Next
        
        SortStructuredList(StrgEx()\AutoComplete(), #PB_Sort_Ascending, OffsetOf(StrgEx_Words_Structure\Word), TypeOf(StrgEx_Words_Structure\Word))
        ResetList(StrgEx()\AutoComplete())
        
      EndIf
      
    EndProcedure
    
    Procedure   ClearWords(GNum.i)
    
      If FindMapElement(StrgEx(), Str(GNum))
        ClearList(StrgEx()\AutoComplete())
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure   AttachPopupMenu(GNum.i, MenuNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If IsMenu(MenuNum)
        StrgEx()\PopupNum = MenuNum
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   AddButton(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Event.i=#PB_Default)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If IsImage(ImageNum)
        StrgEx()\Flags | #EventButton
        StrgEx()\Button\ImgNum  = ImageNum
        If Width = #PB_Default
          StrgEx()\Button\Width = ImageWidth(ImageNum)
        Else
          StrgEx()\Button\Width = Width
        EndIf
        If Height = #PB_Default
          StrgEx()\Button\Height = ImageHeight(ImageNum)
        Else
          StrgEx()\Button\Height = Height
        EndIf
        StrgEx()\Button\Event = Event
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   AddImage(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Event.i=#PB_Default)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If IsImage(ImageNum)
        StrgEx()\Flags | #ShowImage
        StrgEx()\Button\ImgNum  = ImageNum
        If Width = #PB_Default
          StrgEx()\Button\Width = ImageWidth(ImageNum)
        Else
          StrgEx()\Button\Width = Width
        EndIf
        If Height = #PB_Default
          StrgEx()\Button\Height = ImageHeight(ImageNum)
        Else
          StrgEx()\Button\Height = Height
        EndIf
        StrgEx()\Button\Event = Event
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   Clear(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      StrgEx()\Text = ""
      PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Copy(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Copy_()
    EndIf
    
  EndProcedure
  
  Procedure   Cut(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Cut_()
      PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Paste(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Paste_()
      PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Delete(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      DeleteSelection_()
      PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Change)
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(StrgEx(), Str(GNum))

      StrgEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
      
    EndIf  
    
  EndProcedure  
  
  Procedure   Free(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      DeleteMapElement(StrgEx())
      
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
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard)
    EndIf
    
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf

      If AddMapElement(StrgEx(), Str(GNum))
        
        StrgEx()\CanvasNum = GNum
        
        If Flags & #Background
          StrgEx()\BackText = Content
        Else  
          StrgEx()\Text     = Content
        EndIf
        
        StrgEx()\MaxLength = #PB_Default
        StrgEx()\Undo      = Content
        StrgEx()\Flags     = Flags
        
        If WindowNum = #PB_Default
          StrgEx()\Window\Num = GetGadgetWindow()
        Else
          StrgEx()\Window\Num = WindowNum
        EndIf   
        
        CompilerIf #Enable_ShowPasswordButton 
          If StrgEx()\Flags & #Password And StrgEx()\Flags & #ShowButton
            StrgEx()\Button\ImgNum = CatchImage(#PB_Any, ?ImgShow, 591)
            StrgEx()\Button\Width  = 16
            StrgEx()\Button\Height = 10
            StrgEx()\Button\Event  = #PB_Event_LeftClick
          EndIf  
        CompilerEndIf
        
        CompilerIf #Enable_SearchImageButton
          If StrgEx()\Flags & #Search And StrgEx()\Flags & #ShowImage
            StrgEx()\Button\ImgNum = CatchImage(#PB_Any, ?Search, 776)
            StrgEx()\Button\Width  = 16
            StrgEx()\Button\Height = 16
          EndIf   
        CompilerEndIf  
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            StrgEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              StrgEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            StrgEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        CompilerIf #PB_Compiler_Version >= 600
          If OSVersion() = #PB_OS_Windows_11  : StrgEx()\Flags | #Style_Win11 : EndIf
        CompilerElse
          If OSVersion() >= #PB_OS_Windows_10 : StrgEx()\Flags | #Style_Win11 : EndIf
        CompilerEndIf 
        
        StrgEx()\Padding = 4
        
        StrgEx()\Size\X = X
        StrgEx()\Size\Y = Y
        StrgEx()\Size\Width  = Width
        StrgEx()\Size\Height = Height
        
        StrgEx()\CanvasCursor = #PB_Cursor_Default
        StrgEx()\Cursor\Pause = #True
        StrgEx()\Cursor\State = #True
        
        StrgEx()\Color\Front         = $000000
        StrgEx()\Color\Back          = $FFFFFF
        StrgEx()\Color\Focus         = $D77800
        StrgEx()\Color\Border        = $A0A0A0
        StrgEx()\Color\Gadget        = $EDEDED
        StrgEx()\Color\GreyText      = $6D6D6D
        StrgEx()\Color\DisableFront  = $72727D
        StrgEx()\Color\DisableBack   = $CCCCCA
        StrgEx()\Color\Cursor        = $800000
        StrgEx()\Color\Button        = $E3E3E3
        StrgEx()\Color\Highlight     = $D77800
        StrgEx()\Color\HighlightText = $FFFFFF
        StrgEx()\Color\WordColor     = $CC6600
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            StrgEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            StrgEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
            StrgEx()\Color\Focus         = GetSysColor_(#COLOR_HIGHLIGHT)
            StrgEx()\Color\Gadget        = GetSysColor_(#COLOR_MENU)
            StrgEx()\Color\Button        = GetSysColor_(#COLOR_3DLIGHT)
            StrgEx()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
            StrgEx()\Color\WordColor     = GetSysColor_(#COLOR_HOTLIGHT)
            StrgEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
            StrgEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
          CompilerCase #PB_OS_MacOS
            StrgEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            StrgEx()\Color\Back          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            StrgEx()\Color\Focus         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor keyboardFocusIndicatorColor"))
            StrgEx()\Color\Gadget        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            StrgEx()\Color\Button        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            StrgEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            StrgEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextBackgroundColor"))
            StrgEx()\Color\HighlightText = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}        
        
        If StrgEx()\Flags & #Style_Win11 
          StrgEx()\Color\Button      = $F9F9F9
          StrgEx()\Color\Border      = $ECECEC
          StrgEx()\Color\FocusBar    = $A0A0A0
          StrgEx()\Color\DisableBack = StrgEx()\Color\Gadget
        EndIf  
        
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
        BindGadgetEvent(GNum, @_ResizeHandler(),          #PB_EventType_Resize)

        If Flags & #AutoResize
          
          If Flags & #FitText    : StrgEx()\Size\Flags | #FitText    : EndIf
          If Flags & #FixPadding : StrgEx()\Size\Flags | #FixPadding : EndIf
          
          If IsWindow(WindowNum)
            StrgEx()\Window\Width  = WindowWidth(WindowNum)
            StrgEx()\Window\Height = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf
          
        EndIf
        
        StrgEx()\Cursor\Frequency = #CursorFrequency
        AddWindowTimer(StrgEx()\Window\Num, #Timer, #Frequency)
				BindEvent(#PB_Event_Timer, @_TimerHandler(), StrgEx()\Window\Num)

        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
        
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), StrgEx()\Window\Num)
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select Attribute
        Case #MaximumLength
          ProcedureReturn StrgEx()\MaxLength  
        Case #Padding
          ProcedureReturn StrgEx()\Padding
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetColor(GNum.i, ColorType.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn StrgEx()\Color\Front
        Case #BackColor
          ProcedureReturn StrgEx()\Color\Back
        Case #BorderColor
          ProcedureReturn StrgEx()\Color\Border
        Case #FocusColor
          ProcedureReturn StrgEx()\Color\Focus
        Case #CursorColor
          ProcedureReturn StrgEx()\Color\Cursor
        Case #HighlightColor
          ProcedureReturn StrgEx()\Color\Highlight
        Case #HighlightTextColor
          ProcedureReturn StrgEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(StrgEx(), Str(GNum))
	    ProcedureReturn StrgEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(StrgEx(), Str(GNum))
	    ProcedureReturn StrgEx()\ID
	  EndIf
	  
	EndProcedure


  Procedure.s GetText(GNum.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      ProcedureReturn StrgEx()\Text
    EndIf
    
  EndProcedure
  
  
  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(StrgEx(), Str(GNum))
      HideGadget(GNum, State)
      StrgEx()\Hide = State 
    EndIf  
  
  EndProcedure
  
  Procedure   InsertText(GNum.i, Text.s)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Paste_(Text)
      
      Draw_()
    EndIf
    
  EndProcedure   
  
  Procedure   RemoveFlag(GNum.i, Flag.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      StrgEx()\Flags & ~Flag
    EndIf
    
  EndProcedure  
  
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select Attribute
        Case #MaximumLength
          StrgEx()\MaxLength = Value
          Draw_()
        Case #Padding
          If Value < 2 : Value = 2 : EndIf 
          StrgEx()\Padding = Value
        Case #Corner
          StrgEx()\Radius  = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          StrgEx()\Color\Front         = Color
        Case #BackColor
          StrgEx()\Color\Back          = Color
        Case #BorderColor
          StrgEx()\Color\Border        = Color
        Case #GreyTextColor  
          StrgEx()\Color\GreyText      = Color
        Case #FocusColor
          StrgEx()\Color\Focus         = Color
        Case #FocusBarColor
          StrgEx()\Color\FocusBar      = Color  
        Case #CursorColor
          StrgEx()\Color\Cursor        = Color
        Case #HighlightColor
          StrgEx()\Color\Highlight     = Color
        Case #HighlightTextColor
          StrgEx()\Color\HighlightText = Color
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(StrgEx(), Str(GNum))
	    StrgEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
  Procedure   SetFlags(GNum.i, Flags.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      StrgEx()\Flags | Flags
    EndIf
    
  EndProcedure

  Procedure   SetFont(GNum.i, FontNum.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If IsFont(FontNum)
        StrgEx()\FontID = FontID(FontNum)
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure
  
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(StrgEx(), Str(GNum))
	    StrgEx()\ID = String
	  EndIf
	  
	EndProcedure  
  
  Procedure   SetInputMask(GNum.i, Mask.s)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\Mask\String = Mask
      If Left(Mask, 1) = "*" Or Left(Mask, 1) = "0"
        StrgEx()\Mask\Delimiter = Mid(Mask, 2, 1)
      EndIf  
      
    EndIf
    
  EndProcedure
  
  Procedure   SetText(GNum.i, Text.s, Type.i=#PB_Default) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If Type = #Background
        StrgEx()\BackText = Text
      Else  
        StrgEx()\Text = Text
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure   Undo(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Undo_()
      Draw_()
    EndIf
    
  EndProcedure  
  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Procedure.i SetDynamicFont(GNum.i, Name.s, Size.i, Style.i=#False)
	    Define.i FontNum
	    Define   Padding.ModuleEx::Padding_Structure
	    
	    If FindMapElement(StrgEx(), Str(GNum))
	      
	      FontNum = ModuleEx::Font(Name, Size, Style)
	      If IsFont(FontNum)
	        
	        StrgEx()\Font\Num   = FontNum
	        StrgEx()\Font\Name  = Name
	        StrgEx()\Font\Size  = Size
	        StrgEx()\Font\Style = Style
	        StrgEx()\FontID     = FontID(FontNum)

	        ModuleEx::CalcPadding(StrgEx()\Text, GadgetHeight(GNum), FontNum, Size, @Padding)
	        StrgEx()\PaddingX = Padding\X
	        StrgEx()\PaddingY = Padding\Y
	        StrgEx()\PFactor  = Padding\Factor
  	      
	        Draw_()
	      EndIf
	      
	    EndIf
	    
	    ProcedureReturn FontNum
	  EndProcedure
	  
	  Procedure.i FitText(GNum.i, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(StrgEx(), Str(GNum))
	      
	      If IsFont(StrgEx()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : StrgEx()\PaddingX = PaddingX * 2 : EndIf 
	      If PaddingY <> #PB_Default : StrgEx()\PaddingY = PaddingY * 2 : EndIf 
	      
	      If StrgEx()\Size\Flags & #FixPadding Or PaddingY <> #PB_Default
		      Width  = StrgEx()\Size\Text - StrgEx()\PaddingX
          Height = GadgetHeight(StrgEx()\CanvasNum) - StrgEx()\PaddingY
		    Else
		      Width  = StrgEx()\Size\Text - StrgEx()\PaddingX
          Height = GadgetHeight(StrgEx()\CanvasNum) - (GadgetHeight(StrgEx()\CanvasNum) * StrgEx()\PFactor)
		    EndIf
		    
		    FontSize = ModuleEx::RequiredFontSize(StrgEx()\Text, Width, Height, StrgEx()\Font\Num)
		    If FontSize <> StrgEx()\Font\Size
          StrgEx()\Font\Size = FontSize
          StrgEx()\Font\Num  = ModuleEx::Font(StrgEx()\Font\Name, FontSize, StrgEx()\Font\Style)
          StrgEx()\FontID    = FontID(StrgEx()\Font\Num)
        EndIf  
        
        Draw_()
      EndIf
      
	    ProcedureReturn StrgEx()\Font\Num
	  EndProcedure  
	  
	  Procedure.i SetFitText(GNum.i, Text.s, PaddingX.i=#PB_Default, PaddingY.i=#PB_Default)
	    Define.i Width, Height, FontSize
	    
	    If FindMapElement(StrgEx(), Str(GNum))
	      
	      If IsFont(StrgEx()\Font\Num) = #False : ProcedureReturn #False : EndIf 
	      
	      If PaddingX <> #PB_Default : StrgEx()\PaddingX = PaddingX : EndIf 
	      If PaddingY <> #PB_Default : StrgEx()\PaddingY = PaddingY : EndIf 
	      
	      StrgEx()\Text = Text
	      
	      If StrgEx()\Size\Flags & #FixPadding
		      Width  = StrgEx()\Size\Text - StrgEx()\PaddingX
          Height = GadgetHeight(StrgEx()\CanvasNum) - StrgEx()\PaddingY
		    Else
		      Width  = StrgEx()\Size\Text - StrgEx()\PaddingX
          Height = GadgetHeight(StrgEx()\CanvasNum) - (GadgetHeight(StrgEx()\CanvasNum) * StrgEx()\PFactor)
		    EndIf
		    
		    FontSize = ModuleEx::RequiredFontSize(StrgEx()\Text, Width, Height, StrgEx()\Font\Num)
		    If FontSize <> StrgEx()\Font\Size
          StrgEx()\Font\Size = FontSize
          StrgEx()\Font\Num  = ModuleEx::Font(StrgEx()\Font\Name, FontSize, StrgEx()\Font\Style)
          StrgEx()\FontID = FontID(StrgEx()\Font\Num)
        EndIf 
        
        Draw_()
      EndIf
      
	    ProcedureReturn StrgEx()\Font\Num
	  EndProcedure  
	  
	CompilerEndIf 
	
	
	CompilerIf #Enable_SearchImageButton

    DataSection
      Search:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$414449CF02000061,$3010A06463DA7854,
             $44454F305C2C0BA2,$D3F38991918B4858,$B579BF5FAF0FCFE7,$4DA6034133E9A9B1,$C2C395A9A5A22A9B,$BFC49317E5F117C9,
             $98DF8CECBC4C0CFF,$EEFDC1F0F63D7EFE,$EDE80D38E398E8A8,$E1F49CB0B33016E9,$F03EFFF7C3D84F0F,$9FFFEFF3FB7F72F3,
             $49300ACB32BFEFD7,$F5E6E7767FFF0B2A,$D80D5883E8E8A8E4,$EEC92E5FF67B63B9,$B2299BBB9F196F3B,$E7F9FD7DB1B173F3,
             $F33CEF3E3F0FCBFB,$CF028E9318868BE8,$A9AD0BEDF77B93B7,$2D7D4340628779A9,$582F0BFAC78BA3BF,$F24B28DFE434F475,
             $BFF7F3FDFD4D02F0,$CAE07EFEFDBF1FEF,$340E51BE5E2F47EB,$44706AE7747951E4,$98CD6603140ED464,$53E4E3B869ACAAA6,
             $79059F4A460E7FE6,$FBFC7F19985818D8,$EC5EDFD7A3C7FFF7,$B59F8FC7C5EAF2BB,$507BBE7E5DB9F402,$1980C5093017EBE4,
             $38EC99E868A8A6D3,$03EC86BEAFE18F74,$EF4C2CACDF8E4129,$37F5E8E8FDFF7D3E,$DBEBF7C5FA7D5FCF,$DF5F5FDE01A04B17,
             $40628A9E0C080BCB,$DAC07FAFAF295979,$DC63BD6E8DD9AFAB,$FFFFDFE8FBC62724,$EFC7ECF9FC7D5F0F,$E71455FD7F3F7CBF,
             $E574A6CEA2EE15F8,$1843CC8CF4FF69C2,$19116486E369B881,$E4FABA7F2F3B2995,$4C7BF64E0E36C313,$CC2DFCFC7F5F8C8C,
             $EFCC54DFC5D3F0C5,$EE5B2D97176BD3E3,$340618E7EAF57AB7,$F174D8DADAF03434,$D5F3FA7D5F254B08,$9C40C2806E3FB7A3,
             $984D4B8647414D9F,$5C7F2793C9EB1FEB,$EAD76BB5C16572B9,$B521230AF9DCEE77,$8B24EAEAEBF1B5B5,$322A72B131C44B8B,
             $F5E3FDFBFF323230,$D1F0FFBE8F77FBC3,$8FC7E3FD43838384,$EDF6F1B47A3D1EFF,$3587B86C361B25DB,$494B4A4955555729,
             $FC7E3C713131322A,$383A1F0B8582D9E4,$4949F5E9E9EA5838,$F1E195FAFD7FE949,$BF97BBDDEF87C7E3,$FE43508CF38AC562,
             $7F8CD3E9F4F41BA3,$014ECACAC8B1FEFF,$45B1D1D1C080EDF1,$E190505056D15151,$C088AE8147CFE7F3,$E8606060603E0170,
             $F016E6E6E353E3E3,$092C964BEBA7D3E9,$EDEC244BA800C920,$C270F5FAFD7F1DED,$7B48BF1000270984,$000000001D58767C,
             $826042AE444E4549
    EndDataSection

  CompilerEndIf

  CompilerIf #Enable_ShowPasswordButton  

    DataSection
      ImgShow:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0A00000010000000,$DEBEBD0000000608,$414449BE0100009C,$42483D5275DA7854,
             $40BE66A7D7BE1451,$0F2A0617950F9E85,$5CDA9B5CDC9C1C1C,$DD06C706A9A1C9A2,$0D71239A9A5C1104,$12106B7271712687,
             $3F98A21F5114A091,$A232BD1EF7DBD3E9,$CE77EE73DEF7396F,$E380260764A1CEF9,$C588F9E790E003B8,$EBF5EBD7DED23962,
             $66CAA74E9A7F3E7C,$1C6A1FC602DF79B3,$8410592E5CBBCC10,$5615294276CD9B73,$5C3FC2A315F715AB,$468DDCA28A8F972E,
             $58800274CE9067A3,$FBF33BE7CFB756AD,$71451240408117FD,$903ED5AB5255555F,$B219468D127E0F75,$EDDB701BE6CD9B2F,
             $A74E9D406091EF76,$3E7CD3E5965AE1F6,$162C590704D9822F,$7142A54AB32E5CA4,$A269D3A49BB76E67,$3D6AD5BF42850B9D,
             $5783060D2C83060C,$50A1C78F12E78F1E,$2B2196044A952B88,$82448964AAD021DD,$A937B76ED2499326,$22FCDDEBD7A5EA54,
             $D56458B15CBD7AF0,$9D7AF54C8A8B756A,$0E1C097FD5BD05A0,$58B1A7492482DE87,$91CB9734E3C78C4C,$20CD086B95A264C9,
             $F7E85ABF3264C92E,$888BAC28445D59FB,$5B07412224488BA0,$384884C6B0A0D1A3,$E74E9D88BAB0661C,$8799B3668C634447,
             $082988C7D2C432A0,$E31F5F855B97F3DA,$633FC78F1BBC3870,$01E0426354245DDC,$A459FFB76ED0E896,$F6319DF880A66CD9,
             $4B7702BA279F48BD,$490000000005D3EF
      Data.b $45,$4E,$44,$AE,$42,$60,$82
      ImgShowend:
    EndDataSection

  CompilerEndIf

EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Window  = 0
  
  Enumeration 1
    #String
    #StringEx
    #StringPW
    #StringDel
    #StringSearch
    #Font
    #Popup
    #Image
    #Menu_Item1
    #Menu_Item2
    #Menu_Item3
    #Menu_Item4
    #Menu_Item5
  EndEnumeration
  
  LoadImage(#Image, "Delete.png")
  
  If OpenWindow(#Window, 0, 0, 575, 60, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#Popup)
      MenuItem(#Menu_Item1, "Undo")
      MenuBar()
      MenuItem(#Menu_Item2, "Copy")
      MenuItem(#Menu_Item3, "Cut")
      MenuItem(#Menu_Item4, "Paste")
      MenuBar()
      MenuItem(#Menu_Item5, "Delete")
    EndIf
    
    StringGadget(#String, 15, 19, 90, 20, "")
    ;SetGadgetAttribute(#String, #PB_String_MaximumLength, 5)
    
    StringEx::Gadget(#StringEx, 120, 19, 90, 20, "AutoComplete", StringEx::#AutoComplete, #Window) ; StringEx::#ShowButton / StringEx::#Numeric / StringEx::#LowerCase / StringEx::#UpperCase / StringEx::#NotEditable / StringEx::#BorderLess
    StringEx::AttachPopupMenu(#StringEx, #Popup)
    ;StringEx::SetAttribute(#StringEx, StringEx::#MaximumLength, 5)

    StringEx::AddWords(#StringEx, "Default Define Declare Degree Debug AutoComplete")
    
    StringEx::Gadget(#StringPW, 225, 19, 100, 20, "Password", StringEx::#Password|StringEx::#ShowButton, #Window)
    ;StringEx::SetAttribute(#StringPW, StringEx::#Padding, 6)
    ;StringEx::SetAttribute(#StringPW, StringEx::#MaximumLength, 10)
    
    StringEx::Gadget(#StringDel, 340, 19, 100, 20, "", StringEx::#AutoResize|StringEx::#Right, #Window) ; 
    StringEx::AddButton(#StringDel, #Image)
    StringEx::SetAutoResizeFlags(#StringDel, StringEx::#Width)
    
    StringEx::SetText(#StringDel, "Delete Button", StringEx::#Background)
    
    StringEx::SetInputMask(#StringDel, "0.00")
    ;StringEx::SetInputMask(#StringDel, "*.__$")
    ;StringEx::SetInputMask(#StringDel, "*,__ €")
    ;StringEx::SetInputMask(#StringDel, "__.__.____")
    
    StringEx::Gadget(#StringSearch, 455, 19, 100, 20, "", StringEx::#Search|StringEx::#ShowImage, #Window)
    
    CompilerIf Defined(ModuleEx, #PB_Module)
	
  	  StringEx::SetDynamicFont(#StringDel, "Arial", 8)
  	  StringEx::FitText(#StringDel, 3, 3)
  	  
  	  StringEx::SetAutoResizeFlags(#StringDel, StringEx::#Width|StringEx::#FitText)
  	  
  	  ;ModuleEx::SetTheme(ModuleEx::#Theme_Green)
  	  
    CompilerEndIf
    
    ;DisableGadget(#String, #True)
    ;StringEx::Disable(#StringEx, #True)
    
    ;StringEx::SetAttribute(#StringPW, StringEx::#Corner, 4)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #StringEx
              Select EventType()
                Case #PB_EventType_Focus
                  Debug ">>> Focus"
                Case #PB_EventType_LostFocus
                  Debug ">>> LostFocus"
                Case StringEx::#EventType_Change
                  Debug ">>> Changed"
              EndSelect    
            Case #StringDel
              If EventType() = StringEx::#EventType_Button
                Debug "Delete"
                StringEx::Clear(#StringDel)
              EndIf
          EndSelect
        Case #PB_Event_Menu
          Select EventMenu()
            Case #Menu_Item1
              StringEx::Undo(#StringEx)
            Case #Menu_Item2
              StringEx::Copy(#StringEx)
            Case #Menu_Item3
              StringEx::Cut(#StringEx)
            Case #Menu_Item4
              StringEx::Paste(#StringEx)
            Case #Menu_Item5
              StringEx::Delete(#StringEx)
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 6.00 Beta 10 (Windows - x64)
; CursorPosition = 12
; Folding = QdAQAAGAIAAaigBAwAQAACMAAgw-
; EnableThread
; EnableXP
; DPIAware
; EnablePurifier