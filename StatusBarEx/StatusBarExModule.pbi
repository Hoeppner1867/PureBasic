;/ ===============================
;/ =    StatusBarExModule.pbi    =
;/ ===============================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ Extended StatusBar
;/
;/ © 2019 Thorsten1867 (03/2019)
;/
  
; Last Update: 19.11.2019
;
; Bugfix: DPI
;
; Added: #NoWindow (use container or gadget instead of window for resizing)
; Added: ClearItems() / Disable()
; Added: #UseExistingCanvas
; Added: StatusBar::Hide()


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


;{ _____ StatusBarEx - Commands _____

; StatusBar::AddField()           - similar to 'AddStatusBarField()'
; StatusBar::AddItem()            - similar to 'AddGadgetItem()'
; StatusBar::AttachPopupMenu()    - attachs a popup menu to the field
; StatusBar::ClearItems()         - similar to 'ClearGadgetItems()'
; StatusBar::ComboBox()           - similar to 'ComboBoxGadget()'
; StatusBar::Disable()            - similar to 'DisableGadget()'
; StatusBar::DisableRedraw()      - stops redrawing gadget
; StatusBar::EventNumber()        - returns the event number (integer)
; StatusBar::EventID()            - returns the event ID (string)
; StatusBar::EventState()         - returns the state of a statusbar gadget
; StatusBar::Free()               - similar to 'FreeStatusBar()'
; StatusBar::Gadget()             - similar to 'CreateStatusBar()'
; StatusBar::GetState()           - similar to 'GetGadgetState()'
; StatusBar::GetText()            - similar to 'GetGadgetText()'
; StatusBar::Image()              - similar to 'StatusBarImage()'
; StatusBar::ImageButton()        - similar to 'ButtonImageGadget()'
; StatusBar::Height()             - similar to 'StatusBarHeight()'
; StatusBar::Hide()               - similar to 'HideGadget()'
; StatusBar::HyperLink()          - similar to 'HyperLinkGadget()'
; StatusBar::Progress()           - similar to 'StatusBarProgress()'
; StatusBar::SetAttribute()       - similar to 'SetGadgetAttribute()'
; StatusBar::SetColor()           - similar to 'SetGadgetColor()'
; StatusBar::SetFont()            - similar to 'SetGadgetFont()'
; StatusBar::SetHeight()          - change statusbar height
; StatusBar::SetState()           - similar to 'SetGadgetState'
; StatusBar::SetText()            - similar to 'SetGadgetText'
; StatusBar::Text()               - similar to 'StatusBarText()'
; StatusBar::TextButton()         - similar to 'ButtonGadget()'
; StatusBar::ToolTip()            - similar to 'GadgetToolTip()'

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule StatusBar
  
  #Version  = 19111902
  #ModuleEx = 19111703
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  Enumeration Color 1 
    #FrontColor
    #BackColor
    #SeparatorColor
    #BorderColor
  EndEnumeration
  
  EnumerationBinary Flags
    #Raised     = #PB_StatusBar_Raised     ; not used
    #BorderLess = #PB_StatusBar_BorderLess
    #Center     = #PB_StatusBar_Center
    #Right      = #PB_StatusBar_Right
    #Left
    #Border
    #Image
    #Font
    #Gadget
    #Popup
    #SizeHandle
    #NoWindow
    #UseExistingCanvas
  EndEnumeration
  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Theme  = ModuleEx::#Event_Theme
    #Event_Gadget = ModuleEx::#Event_Gadget
    
    #EventType_ComboBox    = ModuleEx::#EventType_ComboBox
    #EventType_TextButton  = ModuleEx::#EventType_Button
    #EventType_ImageButton = ModuleEx::#EventType_ImageButton
    #EventType_HyperLink   = ModuleEx::#EventType_HyperLink
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_ComboBox
      #EventType_TextButton
      #EventType_ImageButton
      #EventType_HyperLink
    EndEnumeration 
    
  CompilerEndIf  
  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare   AddField(GNum.i, Width.i=#PB_Ignore, Flags.i=#False)
  Declare   AddItem(GNum.i, Field.i, Position.i, Text.s, ImageID.i=#False)
  Declare   AttachPopupMenu(GNum.i, Field.i, MenuNum.i) 
  Declare   ClearItems(GNum.i, Field.i)
  Declare.i ComboBox(GNum.i, Field.i, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
  Declare.i Disable(GNum.i, Field.i, State.i=#True)
  Declare   DisableRedraw(GNum.i, State.i=#False)
  Declare.i EventNumber(GNum.i)
  Declare.s EventID(GNum.i)
  Declare.i EventState(GNum.i)
  Declare   Free(GNum.i)
  Declare.i Gadget(GNum.i, WindowNum.i, MenuNum.i=#False, Flags.i=#False)
  Declare.i GetState(GNum.i, Field.i)
  Declare.s GetText(GNum.i, Field.i)
  Declare.i Height(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare.i HyperLink(GNum.i, Field.i, Text.s, Color.i, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
  Declare   Image(GNum.i, Field.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Flags.i=#False)
  Declare.i ImageButton(GNum.i, Field.i, ImageID.i, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
  Declare   Progress(GNum.i, Field.i, Minimum.i=0, Maximum.i=100)
  Declare   SetAttribute(GNum.i, Field.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i, Field.i=#PB_Ignore)
  Declare   SetFont(GNum.i, FontNum.i, Field.i=#PB_Ignore)
  Declare   SetHeight(GNum.i, Height.i)
  Declare   SetState(GNum.i, Field.i, State.i)
  Declare   SetText(GNum.i, Field.i, Text.s)
  Declare   Text(GNum.i, Field.i, Text.s, Flags.i=#False)
  Declare.i TextButton(GNum.i, Field.i, Text.s, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
  Declare   ToolTip(GNum.i, Field.i, Text.s)
  
EndDeclareModule

Module StatusBar

  EnableExplicit
  
  UsePNGImageDecoder()

  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================  
  
  #StatusBar_Height = 28
  #SizeBox_Width    = 18
  
  Enumeration Gadgets 1
    #ProgressBar  
    #TextButton
    #ComboBox
    #ImageButton
    #HyperLink
  EndEnumeration
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure StBEx_Event_Structure     ;{ StBEx()\Event\...
    Type.i
    Field.i
    Num.i
    ID.s
    State.i
  EndStructure ;}
  
  Structure Gadget_Structure           ;{ StBEx()\Gadgets()\...
    Type.i
    Event.i
    EventID.s
    Value.i
    Text.s
    Min.i
    Max.i
  EndStructure ;}
  
  Structure Image_Structure            ;{ StBEx()\Fields()\Image\...
    Width.i
    Height.i
    Flags.i
  EndStructure ;}
  
  Structure Fields_Color_Structure     ;{ StBEx()\Fields()\Color\...
    Front.i
    Back.i
  EndStructure ;}
  
  Structure StBEx_Color_Structure      ;{ StBEx()\Color\...
    Front.i
    Back.i
    Border.i
    Separator.i
  EndStructure ;}
  
  Structure StBEx_Size_Structure       ;{ StBEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Fields.f
  EndStructure ;}
  
  Structure StBEx_Window_Structure     ;{ StBEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure StBEx_Fields_Structure     ;{ StBEx()\Fields()\...
    X.f
    Text.s
    Font.i
    ImageNum.i
    GadgetNum.i
    PopupNum.i
    Width.f
    ToolTip.s
    endX.i
    Color.Fields_Color_Structure
    Flags.i
  EndStructure ;}
  
  Structure StBEx_Structure ;{ StBEx('GNum')\
    CanvasNum.i
    
    IgnoreNum.i ; Number of fields with #PB_Ignore
    FontID.i
    Focus.i
    ToolTip.i
    Menu.i
    Hide.i
    
    Color.StBEx_Color_Structure
    Event.StBEx_Event_Structure
    Size.StBEx_Size_Structure
    Window.StBEx_Window_Structure
    
    List Fields.StBEx_Fields_Structure()
    Map  Gadget.Gadget_Structure()
    Map  Image.Image_Structure()

    ReDraw.i
    Flags.i
  EndStructure ;}
  Global NewMap StBEx.StBEx_Structure()
  
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
  
  Procedure   DisableToolTip_()
    
    If StBEx()\ToolTip
      StBEx()\ToolTip = #False
      GadgetToolTip(StBEx()\CanvasNum, "")
    EndIf

  EndProcedure
  
  Procedure.f GetAvailableSpace_()
    Define.f Space
    
    PushListPosition(StBEx()\Fields())
    
    ForEach StBEx()\Fields()
      If StBEx()\Fields()\Width <> #PB_Ignore
        Space + StBEx()\Fields()\Width - dpiX(1)
      EndIf
    Next
    
    If StBEx()\Flags & #SizeHandle : Space + dpiX(#SizeBox_Width) : EndIf
    
    PopListPosition(StBEx()\Fields())
    
    ProcedureReturn dpiX(GadgetWidth(StBEx()\CanvasNum)) - Space
  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure.f GetAlignOffset_(Text.s, Width.f, Flags.i)
    Define.f Offset
    
    If Flags & #Right
      Offset = Width - TextWidth(Text) - dpiX(4)
    ElseIf Flags & #Center
      Offset = (Width - TextWidth(Text)) / 2
    Else
      Offset = dpiX(4)
    EndIf
    
    If Offset < 0 : Offset = 0 : EndIf
    
    ProcedureReturn Offset
  EndProcedure
  
  Procedure SizeBox_()
    Define.i h, v
    Define.f x, y
    
    X = dpiX(GadgetWidth(StBEx()\CanvasNum)) - 13
    Y = dpiY(GadgetHeight(StBEx()\CanvasNum)) - 4
    
    For h=3 To 1 Step -1
      For v=1 To h
        Box(X + (v * dpiX(3)), Y, dpiX(2), dpiY(2), StBEx()\Color\Border)
      Next
      X + dpiX(3)
      Y - dpiX(3)
    Next
    
  EndProcedure
  
  Procedure Draw_()
    Define.f X, Height, Width, txtY, txtX, imgX, imgY
    Define.i imgFlags, FrontColor, BackColor
    Define.s Text
    
    If StBEx()\Hide : ProcedureReturn #False : EndIf
    
    If StartDrawing(CanvasOutput(StBEx()\CanvasNum))
      
      PushListPosition(StBEx()\Fields())
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, dpiX(GadgetWidth(StBEx()\CanvasNum)), dpiY(GadgetHeight(StBEx()\CanvasNum)), StBEx()\Color\Back)
      ;}
      
      Height = dpiY(GadgetHeight(StBEx()\CanvasNum))
      
      ;  _____ Fields _____
      
      ForEach StBEx()\Fields()
        
        ;{ --- Field width ---
        If StBEx()\Fields()\Width = #PB_Ignore
          If StBEx()\IgnoreNum
            Width = GetAvailableSpace_()
            If Width <= 0
              Width = 0
            Else
              Width = Width / StBEx()\IgnoreNum
            EndIf
          EndIf 
        Else
          Width = StBEx()\Fields()\Width
        EndIf ;}
        
        StBEx()\Fields()\X = X
        
        FrontColor = StBEx()\Color\Front
        If StBEx()\Fields()\Flags & #FrontColor : FrontColor = StBEx()\Fields()\Color\Front : EndIf
        
        BackColor  = StBEx()\Color\Back
        If StBEx()\Fields()\Flags & #BackColor  : BackColor  = StBEx()\Fields()\Color\Back  : EndIf 
        
        DrawingMode(#PB_2DDrawing_Outlined)
        If StBEx()\Flags & #SizeHandle And ListIndex(StBEx()\Fields()) = ListSize(StBEx()\Fields()) - 1
          Box(X, 0, Width + dpiX(#SizeBox_Width), Height, StBEx()\Color\Border)
        Else  
          Box(X, 0, Width, Height, StBEx()\Color\Border)
        EndIf

        ;{ --- Font ---
        If StBEx()\Fields()\Flags & #Font
          DrawingFont(FontID(StBEx()\Fields()\Font))
        Else
          DrawingFont(StBEx()\FontID)
        EndIf ;}
        
        If StBEx()\Fields()\Flags & #Image      ;{ Image
          
          If FindMapElement(StBEx()\Image(), Str(StBEx()\Fields()\ImageNum))
            
            Text = StBEx()\Fields()\Text
            If Text ;{ Text & Image
              
              imgFlags = StBEx()\Image()\Flags
              
              txtX = GetAlignOffset_(Text, Width - dpiX(4) - StBEx()\Image()\Width, StBEx()\Fields()\Flags)
              txtY = (Height - TextHeight(Text)) / 2
              imgY = (Height -  StBEx()\Image()\Height) / 2
              
              If imgFlags & #Right
                DrawingMode(#PB_2DDrawing_Transparent)
                DrawText(X + txtX, txtY, Text, FrontColor, BackColor)
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                If IsImage(StBEx()\Fields()\ImageNum)
                  DrawImage(ImageID(StBEx()\Fields()\ImageNum), X + txtX + TextWidth(Text) + dpiX(4), imgY, StBEx()\Image()\Width, StBEx()\Image()\Height) 
                EndIf
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                If IsImage(StBEx()\Fields()\ImageNum)
                  DrawImage(ImageID(StBEx()\Fields()\ImageNum), X + txtX, imgY, StBEx()\Image()\Width, StBEx()\Image()\Height) 
                EndIf
                DrawingMode(#PB_2DDrawing_Transparent)
                DrawText(X + txtX + dpiX(4) + StBEx()\Image()\Width, txtY, Text, FrontColor, BackColor)
              EndIf
              ;}
            Else    ;{ Image only

              If imgFlags & #Center
                imgX  = (StBEx()\Fields()\Width - StBEx()\Image()\Width) / 2
              ElseIf imgFlags & #Right
                imgX  =  StBEx()\Fields()\Width - StBEx()\Image()\Width - dpiX(4)
              Else 
                imgX = dpiX(4)
              EndIf
              
              imgY  = (Height -  StBEx()\Image()\Height) / 2
              
              DrawingMode(#PB_2DDrawing_AlphaBlend)
              If IsImage(StBEx()\Fields()\ImageNum)
                DrawImage(ImageID(StBEx()\Fields()\ImageNum), X + imgX, imgY, StBEx()\Image()\Width, StBEx()\Image()\Height) 
              EndIf
              ;}
            EndIf
            
          EndIf
          ;}
        ElseIf StBEx()\Fields()\Flags & #Gadget ;{ Gadget
          
          If IsGadget(StBEx()\Fields()\GadgetNum)
            If StBEx()\Fields()\Width = #PB_Ignore
              ResizeGadget(StBEx()\Fields()\GadgetNum, DesktopUnscaledX(X) + 4, #PB_Ignore, DesktopUnscaledX(Width) - 8, GadgetHeight(StBEx()\CanvasNum) - 8)
            Else
              ResizeGadget(StBEx()\Fields()\GadgetNum, DesktopUnscaledX(X) + 4, #PB_Ignore, #PB_Ignore, GadgetHeight(StBEx()\CanvasNum) - 8)
            EndIf
          EndIf
          ;}
        Else                                    ;{ Text
          
          Text = StBEx()\Fields()\Text
          If Text
            txtX = GetAlignOffset_(Text, Width, StBEx()\Fields()\Flags)
            txtY = (Height - TextHeight(Text)) / 2
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(X + txtX, txtY, Text, FrontColor, BackColor)
          EndIf
          ;}
        EndIf
        
        X + Width - dpiX(1)
        
        StBEx()\Fields()\endX = X - dpiX(1)
      Next  
      
      If StBEx()\Flags & #SizeHandle : SizeBox_() : EndIf
      
      ;{ _____ Border _____
      If StBEx()\Flags & #Border
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(0, 0, dpiX(GadgetWidth(StBEx()\CanvasNum)), dpiY(GadgetHeight(StBEx()\CanvasNum)), StBEx()\Color\Border)
      EndIf ;}
      
      PopListPosition(StBEx()\Fields())
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  ;- __________ Events __________
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach StBEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          StBEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        StBEx()\Color\Front     = ModuleEx::ThemeGUI\FrontColor
        StBEx()\Color\Back      = ModuleEx::ThemeGUI\GadgetColor
        StBEx()\Color\Separator = ModuleEx::ThemeGUI\Button\BorderColor
        StBEx()\Color\Border    = ModuleEx::ThemeGUI\BorderColor 
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf   
  
  
  Procedure _GadgetHandler()
    Define.i GadgetNum = EventGadget()
    Define.i GNum = GetGadgetData(GadgetNum)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      ForEach StBEx()\Fields()
        
        If StBEx()\Fields()\GadgetNum = GadgetNum
          
          StBEx()\Event\Num     = StBEx()\Gadget()\Event
          StBEx()\Event\ID      = StBEx()\Gadget()\EventID
          
          If IsWindow(StBEx()\Window\Num)
            
            If FindMapElement(StBEx()\Gadget(), Str(StBEx()\Fields()\GadgetNum))
              
              Select StBEx()\Gadget()\Type
                Case #ComboBox    ;{ ComboBox changed
                  
                  StBEx()\Event\Type  = #EventType_ComboBox
                  StBEx()\Event\State = GetGadgetState(GadgetNum)
                  
                  If StBEx()\Gadget()\Event = #PB_Ignore
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\CanvasNum,     #EventType_ComboBox, ListIndex(StBEx()\Fields()))
                  Else
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\Gadget()\Event, #EventType_ComboBox, StBEx()\Event\State)
                  EndIf
                  ;}
                Case #TextButton  ;{ Textbutton clicked
                  
                  StBEx()\Event\Type  = #EventType_TextButton
                  StBEx()\Event\State = GetGadgetState(GadgetNum)
                  
                  If StBEx()\Gadget()\Event = #PB_Ignore
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\CanvasNum,     #EventType_TextButton, ListIndex(StBEx()\Fields()))
                  Else
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\Gadget()\Event, #EventType_TextButton, StBEx()\Event\State)
                  EndIf
                  ;}
                Case #ImageButton ;{ Imagebutton clicked
                  
                  StBEx()\Event\Type  = #EventType_ImageButton
                  StBEx()\Event\State = GetGadgetState(GadgetNum)
                  
                  If StBEx()\Gadget()\Event = #PB_Ignore
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\CanvasNum,      #EventType_ImageButton, ListIndex(StBEx()\Fields()))
                  Else
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\Gadget()\Event, #EventType_ImageButton, StBEx()\Event\State)
                  EndIf
                  ;}    
                Case #HyperLink   ;{ HyperLink clicked
                  
                  StBEx()\Event\Type  = #EventType_HyperLink
                  StBEx()\Event\State = GetGadgetState(GadgetNum)
                  
                  If StBEx()\Gadget()\Event = #PB_Ignore
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\CanvasNum,      #EventType_HyperLink, ListIndex(StBEx()\Fields()))
                  Else
                    PostEvent(#PB_Event_Gadget, StBEx()\Window\Num, StBEx()\Gadget()\Event, #EventType_HyperLink, StBEx()\Event\State)
                  EndIf
                  ;}
              EndSelect
              
            EndIf
            
          EndIf
          
        EndIf
      
      Next
      
    EndIf
    
  EndProcedure
  
  Procedure _RightClickHandler()
    Define.f X, posX, posY
    Define.i GNum = EventGadget()
    
    If FindMapElement(StBEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If IsWindow(StBEx()\Window\Num)
        ForEach StBEx()\Fields()
          If StBEx()\Fields()\Flags & #Popup And IsMenu(StBEx()\Fields()\PopupNum)
            If X > StBEx()\Fields()\X And X < StBEx()\Fields()\endX
              posX = WindowX(StBEx()\Window\Num, #PB_Window_InnerCoordinate) + StBEx()\Size\X + StBEx()\Fields()\X + dpiX(1)
              posY = WindowY(StBEx()\Window\Num, #PB_Window_InnerCoordinate) + WindowHeight(StBEx()\Window\Num, #PB_Window_InnerCoordinate) - GadgetHeight(StBEx()\CanvasNum)
              DisplayPopupMenu(StBEx()\Fields()\PopupNum, WindowID(StBEx()\Window\Num), dpiX(posX), dpiY(posY))
              Break
            EndIf
          EndIf
        Next
      EndIf
      
    EndIf  

  EndProcedure   
  
  Procedure _MouseMoveHandler()
    Define.f X
    Define.i GNum = EventGadget()
    
    If FindMapElement(StBEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      ForEach StBEx()\Fields()
        
        If X > StBEx()\Fields()\X And X < StBEx()\Fields()\endX
          
          If StBEx()\Focus <> ListIndex(StBEx()\Fields())
            
            StBEx()\Focus = ListIndex(StBEx()\Fields())
            
            If StBEx()\Fields()\Flags & #Gadget
              GadgetToolTip(StBEx()\Fields()\GadgetNum, StBEx()\Fields()\ToolTip)
            Else
              GadgetToolTip(StBEx()\CanvasNum, StBEx()\Fields()\ToolTip)
            EndIf
            
          Else
            DisableToolTip_()  
          EndIf
        
        EndIf
        
      Next
      
    EndIf
    
  EndProcedure
  
  Procedure _ResizeHandler()
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(StBEx(), Str(GadgetNum))
      Draw_() 
    EndIf
    
  EndProcedure
  
  Procedure _ResizeGadgetHandler()
    Define.f OffSetX, OffSetY
    
    ForEach StBEx()
      
      If IsGadget(StBEx()\CanvasNum)
        
        If IsGadget(StBEx()\Window\Num)
          
          OffSetX = GadgetWidth(StBEx()\Window\Num)  - StBEx()\Window\Width
          OffSetY = GadgetHeight(StBEx()\Window\Num) - StBEx()\Window\Height
          
          ResizeGadget(StBEx()\CanvasNum, #PB_Ignore, StBEx()\Size\Y + OffsetY, StBEx()\Size\Width + OffSetX, #PB_Ignore)
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f OffSetX, OffSetY
    
    ForEach StBEx()
      
      If IsGadget(StBEx()\CanvasNum)
        
        If IsWindow(StBEx()\Window\Num)
          
          OffSetX = WindowWidth(StBEx()\Window\Num)  - StBEx()\Window\Width
          OffSetY = WindowHeight(StBEx()\Window\Num) - StBEx()\Window\Height
          
          ResizeGadget(StBEx()\CanvasNum, #PB_Ignore, StBEx()\Size\Y + OffsetY, StBEx()\Size\Width + OffSetX, #PB_Ignore)
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure

  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure   AttachPopupMenu(GNum.i, Field.i, MenuNum.i) 
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        StBEx()\Fields()\PopupNum = MenuNum
        StBEx()\Fields()\Flags | #Popup
        ;If StBEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   AddField(GNum.i, Width.i=#PB_Ignore, Flags.i=#False)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If AddElement(StBEx()\Fields())
        
        StBEx()\Fields()\Flags = Flags
        
        If Width = #PB_Ignore
          StBEx()\IgnoreNum + 1
          StBEx()\Fields()\Width = #PB_Ignore
        Else  
          StBEx()\Fields()\Width = dpiX(Width)
        EndIf
        
      EndIf
      
      If StBEx()\ReDraw : Draw_() : EndIf
    EndIf 
    
  EndProcedure
  
  Procedure   AddItem(GNum.i, Field.i, Position.i, Text.s, ImageID.i=#False)
  
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsGadget(StBEx()\Fields()\GadgetNum)
          AddGadgetItem(StBEx()\Fields()\GadgetNum, Position, Text, ImageID)
        EndIf
        
      EndIf

    EndIf 
    
  EndProcedure  
  
  Procedure.i ComboBox(GNum.i, Field.i, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
    Define.i GadgetList
    
    If FindMapElement(StBEx(), Str(GNum))
      
      OpenGadgetList(StBEx()\CanvasNum)
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If StBEx()\Fields()\Width = #PB_Ignore
          StBEx()\Fields()\GadgetNum = ComboBoxGadget(#PB_Any, 4, 4, 0, #StatusBar_Height - 8, Flags)
        Else
          StBEx()\Fields()\GadgetNum = ComboBoxGadget(#PB_Any, 4, 4, DesktopUnscaledX(StBEx()\Fields()\Width) - 8, #StatusBar_Height - 8, Flags)
        EndIf
        StBEx()\Fields()\Flags | #Gadget
        
        If AddMapElement(StBEx()\Gadget(), Str(StBEx()\Fields()\GadgetNum))
          
          StBEx()\Gadget()\Type    = #ComboBox
          StBEx()\Gadget()\Event   = EventNum
          StBEx()\Gadget()\EventID = EventID
          
          If IsGadget(StBEx()\Fields()\GadgetNum)
            If StBEx()\Fields()\Flags & #Font
              If IsFont(StBEx()\Fields()\Font) : SetGadgetFont(StBEx()\Fields()\GadgetNum, FontID(StBEx()\Fields()\Font)) : EndIf
            Else
              SetGadgetFont(StBEx()\Fields()\GadgetNum, StBEx()\FontID)
            EndIf
            SetGadgetData(StBEx()\Fields()\GadgetNum, StBEx()\CanvasNum)
            BindGadgetEvent(StBEx()\Fields()\GadgetNum, @_GadgetHandler())
          EndIf
          
        EndIf
        
      EndIf
      
      CloseGadgetList()
    EndIf
    
    If StBEx()\ReDraw : Draw_() : EndIf
    
    ProcedureReturn StBEx()\Fields()\GadgetNum
  EndProcedure
  
  Procedure   ClearItems(GNum.i, Field.i) 

    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsGadget(StBEx()\Fields()\GadgetNum) 
          ClearGadgetItems(StBEx()\Fields()\GadgetNum) 
        EndIf  
        
      EndIf  
      
      If StBEx()\ReDraw : Draw_() : EndIf
      
    EndIf  
   
  EndProcedure

  Procedure   DisableRedraw(GNum.i, State.i=#False)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If State
        StBEx()\ReDraw = #False
      Else
        StBEx()\ReDraw = #True
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   Disable(GNum.i, Field.i, State.i=#True)
 
    If FindMapElement(StBEx(), Str(GNum))
     
      If SelectElement(StBEx()\Fields(), Field)
       
        If IsGadget(StBEx()\Fields()\GadgetNum)
          DisableGadget(StBEx()\Fields()\GadgetNum, State)
        EndIf
       
      EndIf

    EndIf
   
  EndProcedure

  Procedure.i EventNumber(GNum.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      ProcedureReturn StBEx()\Event\Num
    EndIf
    
  EndProcedure
  
  Procedure.s EventID(GNum.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      ProcedureReturn StBEx()\Event\ID
    EndIf
    
  EndProcedure
  
  Procedure.i EventState(GNum.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      ProcedureReturn StBEx()\Event\State
    EndIf
    
  EndProcedure  
  
  Procedure   Free(GNum.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      DeleteMapElement(StBEx())
    EndIf
    
  EndProcedure
  
  
  Procedure.i Gadget(GNum.i, WindowNum.i, MenuNum.i=#False, Flags.i=#False)
    ; Flag #NoWindow: WindowNum = Container or Gadget Number for resizing
    Define.i DummyNum, Result, Y, Width, Height
    
    CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If Flags & #NoWindow ;{ Container
      
      If IsGadget(WindowNum)
        Width  = GadgetWidth(WindowNum)
        Height = GadgetHeight(WindowNum)
        Y = Height - #StatusBar_Height
        BindGadgetEvent(WindowNum, @_ResizeGadgetHandler(), #PB_EventType_Resize)
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else                  ;{ Window
      
      If IsWindow(WindowNum)
        Width  = WindowWidth(WindowNum,  #PB_Window_InnerCoordinate)
        Height = WindowHeight(WindowNum, #PB_Window_InnerCoordinate)
        BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
        If IsMenu(MenuNum)
          Y = Height - #StatusBar_Height - MenuHeight()
        Else
          Y = Height - #StatusBar_Height
        EndIf
      Else
        ProcedureReturn #False
      EndIf
      ;}
    EndIf
    
    If Flags & #UseExistingCanvas ;{ Use an existing CanvasGadget
      If IsGadget(GNum)
        Result = #True
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else
      Result = CanvasGadget(GNum, 0, Y, Width, #StatusBar_Height, #PB_Canvas_Keyboard|#PB_Canvas_Container)
    EndIf

    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      If AddMapElement(StBEx(), Str(GNum))
        
        StBEx()\CanvasNum = GNum
        
        If IsMenu(MenuNum) : StBEx()\Menu = #True : EndIf
        
        StBEx()\ReDraw = #True
        StBEx()\Flags  = Flags
        
        StBEx()\Size\X = 0
        StBEx()\Size\Y = Y
        StBEx()\Size\Width  = Width
        StBEx()\Size\Height = #StatusBar_Height
        
        StBEx()\Window\Num    = WindowNum
        StBEx()\Window\Width  = Width
        StBEx()\Window\Height = Height
        
        CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
					CompilerCase #PB_OS_Windows
						StBEx()\FontID = GetGadgetFont(#PB_Default)
					CompilerCase #PB_OS_MacOS
						DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
						If DummyNum
							StBEx()\FontID = GetGadgetFont(DummyNum)
							FreeGadget(DummyNum)
						EndIf
					CompilerCase #PB_OS_Linux
						StBEx()\FontID = GetGadgetFont(#PB_Default)
				CompilerEndSelect ;}
        
        StBEx()\Color\Front     = $000000
        StBEx()\Color\Back      = $EDEDED
        StBEx()\Color\Separator = $A0A0A0
        StBEx()\Color\Border    = $C7C7C7
        
        CompilerSelect #PB_Compiler_OS ;{ window background color (if possible)
          CompilerCase #PB_OS_Windows
            StBEx()\Color\Back      = GetSysColor_(#COLOR_MENU)
            StBEx()\Color\Separator = GetSysColor_(#COLOR_3DSHADOW)
            StBEx()\Color\Border    = GetSysColor_(#COLOR_SCROLLBAR)
          CompilerCase #PB_OS_MacOS
            StBEx()\Color\Back      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            StBEx()\Color\Separator = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor separatorColor"))
            StBEx()\Color\Border    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}
        
      EndIf
      
      BindGadgetEvent(StBEx()\CanvasNum, @_MouseMoveHandler(),  #PB_EventType_MouseMove)
      BindGadgetEvent(StBEx()\CanvasNum, @_RightClickHandler(), #PB_EventType_RightClick)
      BindGadgetEvent(StBEx()\CanvasNum, @_ResizeHandler(),     #PB_EventType_Resize)
      
      CompilerIf Defined(ModuleEx, #PB_Module)
        BindEvent(#Event_Theme, @_ThemeHandler())
      CompilerEndIf
      
      CloseGadgetList()  
    EndIf
    
    Draw_()
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.i GetState(GNum.i, Field.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsGadget(StBEx()\Fields()\GadgetNum)
          ProcedureReturn GetGadgetState(StBEx()\Fields()\GadgetNum)
        EndIf
        
      EndIf

    EndIf 
    
  EndProcedure
  
  Procedure.s GetText(GNum.i, Field.i)
      
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsGadget(StBEx()\Fields()\GadgetNum)
          ProcedureReturn GetGadgetText(StBEx()\Fields()\GadgetNum)
        EndIf
        
      EndIf

    EndIf 
    
  EndProcedure  
  
  Procedure.i Height(GNum.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      ProcedureReturn StBEx()\Size\Height
    EndIf
    
  EndProcedure
  
  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If State
        StBEx()\Hide  = #True
        HideGadget(GNum, #True)
      Else
        StBEx()\Hide  = #False
        HideGadget(GNum, #False)
      EndIf 
      
    EndIf
    
  EndProcedure
  
  Procedure.i HyperLink(GNum.i, Field.i, Text.s, Color.i, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
    Define.i GadgetList, Height, Y
    
    If FindMapElement(StBEx(), Str(GNum))
      
      OpenGadgetList(StBEx()\CanvasNum)
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If StBEx()\Fields()\Width = #PB_Ignore
          StBEx()\Fields()\GadgetNum = HyperLinkGadget(#PB_Any, 4, 4, 0, DesktopUnscaledY(StBEx()\Size\Height) - 8, Text, Color, Flags)
        Else
          StBEx()\Fields()\GadgetNum = HyperLinkGadget(#PB_Any, 4, 4, DesktopUnscaledX(StBEx()\Fields()\Width) - 8, DesktopUnscaledY(StBEx()\Size\Height) - 8, Text, Color, Flags)
        EndIf
        StBEx()\Fields()\Flags | #Gadget
        
        If AddMapElement(StBEx()\Gadget(), Str(StBEx()\Fields()\GadgetNum))
          
          StBEx()\Gadget()\Type    = #HyperLink
          StBEx()\Gadget()\Event   = EventNum
          StBEx()\Gadget()\EventID = EventID
          
          If IsGadget(StBEx()\Fields()\GadgetNum) 
            SetGadgetData(StBEx()\Fields()\GadgetNum, StBEx()\CanvasNum)
            If StBEx()\Fields()\Flags & #Font
              If IsFont(StBEx()\Fields()\Font) : SetGadgetFont(StBEx()\Fields()\GadgetNum, FontID(StBEx()\Fields()\Font)) : EndIf
            Else
              SetGadgetFont(StBEx()\Fields()\GadgetNum, StBEx()\FontID)
            EndIf
            Height = GadgetHeight(StBEx()\Fields()\GadgetNum, #PB_Gadget_RequiredSize)
            If Height < StBEx()\Size\Height - dpiY(8)
              Y = (DesktopUnscaledY(StBEx()\Size\Height) - Height) / 2
              ResizeGadget(StBEx()\Fields()\GadgetNum, #PB_Ignore, Y, #PB_Ignore, Height)
            EndIf
            BindGadgetEvent(StBEx()\Fields()\GadgetNum, @_GadgetHandler())
          EndIf
          
        EndIf
        
      EndIf  
      
      CloseGadgetList()
      
    EndIf
    
    If StBEx()\ReDraw : Draw_() : EndIf
    
    ProcedureReturn StBEx()\Fields()\GadgetNum
  EndProcedure
  
  Procedure   Image(GNum.i, Field.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Flags.i=#False)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsImage(ImageNum)
          StBEx()\Fields()\ImageNum = ImageNum
          StBEx()\Fields()\Flags | #Image
          If AddMapElement(StBEx()\Image(), Str(ImageNum))
            StBEx()\Image()\Width  = dpiX(Width)
            StBEx()\Image()\Height = dpiY(Height)
            StBEx()\Image()\Flags  = Flags
          EndIf
        EndIf
        
        If StBEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i ImageButton(GNum.i, Field.i, ImageID.i, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
    Define.i GadgetList

    If FindMapElement(StBEx(), Str(GNum))
      
      OpenGadgetList(StBEx()\CanvasNum)
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If StBEx()\Fields()\Width = #PB_Ignore
          StBEx()\Fields()\GadgetNum = ButtonImageGadget(#PB_Any, 4, 4, 0, DesktopUnscaledY(StBEx()\Size\Height) - 8, ImageID, Flags)
        Else
          StBEx()\Fields()\GadgetNum = ButtonImageGadget(#PB_Any, 4, 4, DesktopUnscaledX(StBEx()\Fields()\Width) - 8, DesktopUnscaledY(StBEx()\Size\Height) - 8, ImageID, Flags)
        EndIf
        StBEx()\Fields()\Flags | #Gadget
        
        If AddMapElement(StBEx()\Gadget(), Str(StBEx()\Fields()\GadgetNum))
          
          StBEx()\Gadget()\Type    = #ImageButton
          StBEx()\Gadget()\Event   = EventNum
          StBEx()\Gadget()\EventID = EventID
          
          If IsGadget(StBEx()\Fields()\GadgetNum) 
            SetGadgetData(StBEx()\Fields()\GadgetNum, StBEx()\CanvasNum)
            BindGadgetEvent(StBEx()\Fields()\GadgetNum, @_GadgetHandler())
          EndIf
          
        EndIf
        
      EndIf
      
      CloseGadgetList()
    EndIf
    
    If StBEx()\ReDraw : Draw_() : EndIf
    
    ProcedureReturn StBEx()\Fields()\GadgetNum
  EndProcedure
  
  Procedure.i Progress(GNum.i, Field.i, Minimum.i=0, Maximum.i=100)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        OpenGadgetList(StBEx()\CanvasNum)
        
        If StBEx()\Fields()\Width = #PB_Ignore
          StBEx()\Fields()\GadgetNum = ProgressBarGadget(#PB_Any, 4, 4, 0, DesktopUnscaledY(StBEx()\Size\Height) - 8, Minimum, Maximum)
        Else
          StBEx()\Fields()\GadgetNum = ProgressBarGadget(#PB_Any, 4, 4, DesktopUnscaledX(StBEx()\Fields()\Width) - 8, DesktopUnscaledY(StBEx()\Size\Height) - 8, Minimum, Maximum)
        EndIf
        
        If AddMapElement(StBEx()\Gadget(), Str(StBEx()\Fields()\GadgetNum))
          
          StBEx()\Gadget()\Type  = #ProgressBar
          StBEx()\Gadget()\Min   = Minimum
          StBEx()\Gadget()\Max   = Maximum
          
        EndIf
        
        StBEx()\Fields()\Flags | #Gadget
        
        If IsGadget(StBEx()\Fields()\GadgetNum)
          SetGadgetData(StBEx()\Fields()\GadgetNum, StBEx()\CanvasNum)
        EndIf
        
        CloseGadgetList()
        
      EndIf
    
    EndIf
    
    If StBEx()\ReDraw : Draw_() : EndIf
    
    ProcedureReturn StBEx()\Fields()\GadgetNum
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Field.i, Attribute.i, Value.i)
  
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsGadget(StBEx()\Fields()\GadgetNum)
          SetGadgetAttribute(StBEx()\Fields()\GadgetNum, Attribute, Value)
        EndIf
        
      EndIf

    EndIf 
    
  EndProcedure  
 
  Procedure   SetColor(GNum.i, ColorType.i, Color.i, Field.i=#PB_Ignore)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If Field = #PB_Ignore
        
        Select ColorType
          Case #FrontColor
            StBEx()\Color\Front     = Color
          Case #BackColor
            StBEx()\Color\Back      = Color
          Case #SeparatorColor
            StBEx()\Color\Separator = Color
          Case #BorderColor
            StBEx()\Color\Border    = Color
        EndSelect
        
      Else
        
        If SelectElement(StBEx()\Fields(), Field)
          
          If IsGadget(StBEx()\Fields()\GadgetNum)
            SetGadgetColor(StBEx()\Fields()\GadgetNum, ColorType, Color)
          Else
            Select ColorType
              Case #FrontColor
                StBEx()\Fields()\Color\Front = Color
                StBEx()\Fields()\Flags | #FrontColor
              Case #BackColor
                StBEx()\Fields()\Color\Back  = Color
                StBEx()\Fields()\Flags | #BackColor
            EndSelect 
          EndIf
          
        EndIf
        
      EndIf
      
      If StBEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontNum.i, Field.i=#PB_Ignore)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If IsFont(FontNum)
        
        If Field = #PB_Ignore
          StBEx()\FontID = FontID(FontNum)
        Else
          If SelectElement(StBEx()\Fields(), Field)
            StBEx()\Fields()\Font = FontNum
            StBEx()\Fields()\Flags | #Font
          EndIf
        EndIf
        
        If StBEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetHeight(GNum.i, Height.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If StBEx()\Menu
        StBEx()\Size\Y = StBEx()\Window\Height - dpiY(Height + MenuHeight())
      Else
        StBEx()\Size\Y = StBEx()\Window\Height - dpiY(Height)
      EndIf
      StBEx()\Size\Height = dpiY(Height)
      
      ResizeGadget(StBEx()\CanvasNum, 0, DesktopUnscaledY(StBEx()\Size\Y), #PB_Ignore, Height)
      
    EndIf
  
  EndProcedure
  
  Procedure   SetState(GNum.i, Field.i, State.i)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsGadget(StBEx()\Fields()\GadgetNum)
          SetGadgetState(StBEx()\Fields()\GadgetNum, State)
        EndIf
        
      EndIf

    EndIf 
 
  EndProcedure
  
  Procedure   SetText(GNum.i, Field.i, Text.s)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If IsGadget(StBEx()\Fields()\GadgetNum)
          SetGadgetText(StBEx()\Fields()\GadgetNum, Text)
        EndIf
        
      EndIf

    EndIf 
    
  EndProcedure
  
  Procedure   Text(GNum.i, Field.i, Text.s, Flags.i=#False)
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        
        StBEx()\Fields()\Text = Text
        If Flags : StBEx()\Fields()\Flags = Flags : EndIf
        
        If StBEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i TextButton(GNum.i, Field.i, Text.s, EventNum.i=#PB_Ignore, EventID.s="", Flags.i=#False)
    Define.i GadgetList

    If FindMapElement(StBEx(), Str(GNum))
      
      OpenGadgetList(StBEx()\CanvasNum)
      
      If SelectElement(StBEx()\Fields(), Field)
        
        If StBEx()\Fields()\Width = #PB_Ignore
          StBEx()\Fields()\GadgetNum = ButtonGadget(#PB_Any, 4, 4, 0, DesktopUnscaledY(StBEx()\Size\Height) - 8, Text, Flags)
        Else
          StBEx()\Fields()\GadgetNum = ButtonGadget(#PB_Any, 4, 4, DesktopUnscaledX(StBEx()\Fields()\Width) - 8, DesktopUnscaledY(StBEx()\Size\Height) - 8, Text, Flags)
        EndIf
        StBEx()\Fields()\Flags | #Gadget
        
        If AddMapElement(StBEx()\Gadget(), Str(StBEx()\Fields()\GadgetNum))
          
          StBEx()\Gadget()\Type    = #TextButton
          StBEx()\Gadget()\Event   = EventNum
          StBEx()\Gadget()\EventID = EventID
          
          If IsGadget(StBEx()\Fields()\GadgetNum) 
            If StBEx()\Fields()\Flags & #Font
              If IsFont(StBEx()\Fields()\Font) : SetGadgetFont(StBEx()\Fields()\GadgetNum, FontID(StBEx()\Fields()\Font)) : EndIf
            Else
              SetGadgetFont(StBEx()\Fields()\GadgetNum, StBEx()\FontID)
            EndIf
            SetGadgetData(StBEx()\Fields()\GadgetNum, StBEx()\CanvasNum)
            BindGadgetEvent(StBEx()\Fields()\GadgetNum, @_GadgetHandler())
          EndIf
          
        EndIf
        
      EndIf
      
      CloseGadgetList()
    EndIf
    
    If StBEx()\ReDraw : Draw_() : EndIf
    
    ProcedureReturn StBEx()\Fields()\GadgetNum
  EndProcedure    
  
  Procedure   ToolTip(GNum.i, Field.i, Text.s) 
    
    If FindMapElement(StBEx(), Str(GNum))
      
      If SelectElement(StBEx()\Fields(), Field)
        StBEx()\Fields()\ToolTip = Text
      EndIf
      
    EndIf
    
  EndProcedure
  
EndModule
  
;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Window  = 0
  
  Enumeration 1
    #StatusBar
    #Font1
    #Font2
    #Image
    #Popup
    #Menu_Item1
    #Menu_Item2
  EndEnumeration
  
  LoadFont(#Font1, "Arial", 9, #PB_Font_Bold)
  LoadFont(#Font2, "Arial", 8, #PB_Font_Bold)
  LoadImage(#Image, "Akku.png")
  
  
  If OpenWindow(#Window, 0, 0, 500, 100, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget)
    
    If CreatePopupMenu(#Popup)
      MenuItem(#Menu_Item1, "Item 1")
      MenuItem(#Menu_Item2, "Item 2")
    EndIf
    
    If StatusBar::Gadget(#StatusBar, #Window, #False, StatusBar::#Border|StatusBar::#SizeHandle)
      StatusBar::AddField(#StatusBar, 100)
      StatusBar::AddField(#StatusBar, 80)
      StatusBar::AddField(#StatusBar, #PB_Ignore, StatusBar::#Center)
      StatusBar::AddField(#StatusBar, 60, StatusBar::#Right)
      
      StatusBar::SetFont(#StatusBar, #Font1)
      StatusBar::SetFont(#StatusBar, #Font2, 1)
      
      StatusBar::SetColor(#StatusBar, StatusBar::#FrontColor, $800000)
      StatusBar::SetColor(#StatusBar, StatusBar::#FrontColor, $578B2E, 0)
      
      StatusBar::Text(#StatusBar, 0, "90%")
      StatusBar::Text(#StatusBar, 3, "Field 4")
      
      StatusBar::AttachPopupMenu(#StatusBar, 0, #Popup)

      StatusBar::Image(#StatusBar, 0, #Image, 16, 16, StatusBar::#Left)
      
      StatusBar::Progress(#StatusBar, 2)
      StatusBar::SetState(#StatusBar, 2, 75)
      
      ;StatusBar::TextButton(#StatusBar, 1, "Button")
      ;StatusBar::HyperLink(#StatusBar, 2, " http://www.PureBasic.com", $800000, #PB_Ignore, "", #PB_HyperLink_Underline)
      
      StatusBar::ComboBox(#StatusBar, 1)
      StatusBar::AddItem(#StatusBar,  1, -1, "Item 1")
      StatusBar::AddItem(#StatusBar,  1, -1, "Item 2")
      StatusBar::SetState(#StatusBar, 1, 0)
      
      StatusBar::ToolTip(#StatusBar, 0, "Field 1")
      StatusBar::ToolTip(#StatusBar, 2, "ProgressBar")
    EndIf 
    
    ;ModuleEx::SetTheme(ModuleEx::#Theme_Blue)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #StatusBar
              Select EventType()
                Case StatusBar::#EventType_ComboBox
                  Debug "ComboBox changed: " + Str(EventData()) + " (State: " + Str(StatusBar::EventState(#StatusBar)) + ")"
                Case StatusBar::#EventType_TextButton
                  Debug "TextButton clicked: " + Str(EventData())
                Case StatusBar::#EventType_ImageButton
                  Debug "ImageButton clicked: " + Str(EventData())
                Case StatusBar::#EventType_HyperLink 
                  RunProgram("https://www.purebasic.com")
              EndSelect
          EndSelect    
      EndSelect        
    Until Event = #PB_Event_CloseWindow
  
    CloseWindow(#Window)
  EndIf  
  
  
CompilerEndIf  
  
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 83
; FirstLine = 12
; Folding = 9AAIBwAEgYAAAw
; EnableXP
; DPIAware