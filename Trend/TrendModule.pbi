;/ ============================
;/ =    Trend - Module.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Trend - Gadget 
;/
;/ © 2019 Thorsten1867 (07/2019)
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


;{ _____ Trend - Commands _____

; Trend::AddItem()             - similar to AddGadgetItem()
; Trend::AttachPopupMenu()     - attachs a popup menu to the chart
; Trend::DisableReDraw()       - disable/enable redrawing
; Trend::EventColor()          - returns the color after the event
; Trend::EventIndex()          - returns the item index after the event
; Trend::EventLabel()          - returns the item label after the event
; Trend::EventValue()          - returns the item DataY after the event
; Trend::Gadget()              - create a new gadget
; Trend::GetErrorMessage()     - get error message [DE/FR/ES/UK]
; Trend::GetItemColor()        - returns the color of the item
; Trend::GetItemLabel()        - get the label of the item
; Trend::GetItemState()        - similar to GetGadgetItemState()
; Trend::GetItemText()         - similar to GetGadgetItemText()
; Trend::GetLabelState()       - similar to GetGadgetItemState(), but 'label' instead of 'position'
; Trend::GetLabelColor()       - returns the color of the item
; Trend::RemoveItem()          - similar to RemoveGadgetItem()
; Trend::RemoveLabel()         - similar to RemoveGadgetItem(), but 'label' instead of 'position'
; Trend::SetAttribute()        - similar to SetGadgetAttribute()
; Trend::SetAutoResizeFlags()  - [#MoveX|#MoveY|#ResizeWidth|#ResizeHeight]
; Trend::SetColor()            - similar to SetGadgetColor()
; Trend::SetFlags()            - set flags for Trend customization
; Trend::SetFont()             - similar to SetGadgetFont()
; Trend::SetItemState()        - similar to SetGadgetItemState()
; Trend::SetItemText()         - similar to SetGadgetItemText()
; Trend::SetLabelState()       - similar to SetGadgetItemState(), but 'label' instead of 'position'
; Trend::SetMargins()          - define top, left, right and bottom margin
; Trend::SetMask()             - define mask for FormatDate()
; Trend::ToolTipText()         - defines the text for tooltips (#Value$ / #Label$ / #Serie$)
; Trend::UpdatePopupText()     - updates the menu item text before the popup menu is displayed

;}

DeclareModule Trend
 
  ;- ===========================================================================
  ;-   DeclareModule - Constants
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #Value$ = "{Value}"
  #Label$ = "{Label}"
  
  EnumerationBinary
    #Gadget          
    #PopUpMenu       ; opens the attached popup menu with a rightclick [#BarChart/#PieChart/#Legend]
    #AutoResize      ; Automatic resizing of the gadget
    #Border          ; Gadget border
    #ShowLines       ; Show horziontal lines (Y-Axis) 
    #ShowValue       ; Show values
    #Colored         ; Colored text
    #NoAutoAdjust    ; Don't adjust the max./min. DataY, if necessary. 
    #Diagonal        ; Gradiant flag for vector drawing
    #Vertical        ; Gradiant flag for vector drawing
    #Horizontal
    #Descending      ; Descending numbering of the y-axis
    #BezierCurve     
    #ToolTips        ; show tooltips
    #ChangeCursor    ; change the cursor for clickable areas
    #OutOfRange      ; shows DataY which are out of ranges
    #DataText
    #AxisX
    #AxisY
  EndEnumeration
  
  EnumerationBinary  
    #Time
    #Labels
  EndEnumeration
  
  Enumeration 1    ; [Attribute]
    #Minimum       ; Minimum DataY
    #Maximum       ; Maximum DataY
    #MinimumX      ; Minimum DataY Y
    #MaximumX      ; Maximum DataY X
    #Diameter      ; Circle diameter for data points 
    #Spacing       ; Spacing between data points (LineChart)
    #Padding       ; Padding between y-axis and first data (LineChart)
    #ScaleLines    ; Number of scale lines for Y-axis
    #ScaleLinesX   ; Number of scale lines for X-axis
    #ScaleSpacing  ; Spacing of scale lines for Y-axis [#Single/#Double]
    #ScaleSpacingX ; Spacing of scale lines for X-axis [#Single/#Double]
    #LineColor     ; (LineChart)
    #FontSize      ; DataY/Percent in Chart
    #Decimals      ; decimal places for scatter plot data
  EndEnumeration

  #ScaleLinesY   = #ScaleLines
  #ScaleSpacingY = #ScaleSpacing
  #MinimumY      = #Minimum
  #MaximumY      = #Maximum
    
  #DataX = 1
  #DataY = 2
  
  #Single = 1
  #Double = 2
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #ResizeWidth
    #ResizeHeight
  EndEnumeration  
  
  Enumeration 1
    #FrontColor
    #BackColor
    #BorderColor
    #AxisColor
    #CircleColor
  EndEnumeration
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Gadget = ModuleEx::#Event_Gadget
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Gadget
    EndEnumeration

  CompilerEndIf
  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================  

  Declare.i AddItem(GNum.i, DataX.q, DataY.i, Label.s="", Color.i=#PB_Default)
  Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare   DisplayValues(GNum.i, StartValue.q, EndValue.q)
  Declare.i EventColor(GNum.i) 
  Declare.i EventIndex(GNum.i) 
  Declare.s EventLabel(GNum.i)
  Declare.i EventValue(GNum.i)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.s GetErrorMessage(GNum.i, Language.s="")
  Declare.i GetItemColor(GNum.i, Position.i)
  Declare.s GetItemLabel(GNum.i, Position.i)
  Declare.i GetItemState(GNum.i, Position.i)
  Declare.s GetItemText(GNum.i, Position.i)
  Declare.i GetLabelColor(GNum.i, Label.s)
  Declare.i GetLabelState(GNum.i, Label.s)
  Declare   LoadValues(GNum.i, File.s)
  Declare.i RemoveItem(GNum.i, Position.i)
  Declare   RemoveLabel(GNum.i, Label.s)
  Declare   SaveValues(GNum.i, File.s)
  Declare   SetAttribute(GNum.i, Attribute.i, DataY.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetFlags(GNum.i, Type.i, Flags.i)
  Declare   SetFont(GNum.i, FontID.i, Flags.i=#False) 
  Declare.i SetItemState(GNum.i, Position.i, State.i)
  Declare.i SetItemText(GNum.i, Position.i, Text.s)
  Declare.i SetLabelState(GNum.i, Label.s, State.i)
  Declare   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
  Declare   SetMask(GNum.i, Type.i, String.s)
  Declare.q Time(Hour.i, Minute.i=0, Second.i=0, CurrentDate.i=#False)
  Declare   ToolTipText(GNum.i, Text.s)
  Declare   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
  
EndDeclareModule

Module Trend
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================  
  
  #NotValid = -1
  #Error    = -2
  
  Enumeration MouseMove
    #Mouse_Released 
    #Mouse_Pressed
  EndEnumeration
  
  Enumeration 1
    #Error_LabelExists
    #Error_LabelUnknown
    #Error_IndexNotValid
    #Error_Minimum
    #Error_Maximum
  EndEnumeration
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure Trend_Axis_Structure
    DateMask.s
    Flags.i
  EndStructure
  
  Structure Trend_EventSize_Structure  ;{
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure ;}
  
  Structure Trend_Line_Structure       ;{ Trend()\Line\...
    StartValue.q
    EndValue.q
    Diameter.i
    RangeX.i
    RangeY.i
    Spacing.i
    Padding.i
    ScaleLines.i
    ScaleSpacing.i
    FontSize.i
    FontID.i
    Color.i
    Flags.i
  EndStructure ;}

  Structure Trend_Item_Structure       ;{ Trend()\Item()\...
    Label.s
    X.i
    Y.i
    Radius.i
    DataY.i
    DataX.q
    Text.s
    Color.i
  EndStructure ;}
  
  Structure Trend_Margins_Structure    ;{ Trend()\Margin\...
    Top.i
    Left.i
    Right.i
    Bottom.i
  EndStructure ;}
  
  Structure Trend_Event_Structure      ;{ Trend()\Event\...
    Series.s ; series label
    Label.s  ; item label
    Index.i  ; item index
    Color.i  ; data series color or item color
    DataX.q
    DataY.i
  EndStructure ;}
  
  Structure Trend_Window_Structure     ;{ Trend()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure Trend_Size_Structure       ;{ Trend()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Flags.i
  EndStructure ;} 
  
  Structure Trend_Color_Structure      ;{ Trend()\Color\...
    Front.i
    Back.i
    Axis.i
    Circle.i
    Border.i
  EndStructure  ;}
  
  Structure Trend_Mouse_Structure      ;{ Trend()\Cursor\...
    downY.i
    Current.i
    State.i
  EndStructure ;}
  
  Structure Trend_Currrent_Structure   ;{ Trend()\Currrent\...
    pFactorY.f
    nFactorY.f
    pFactorX.f
    nFactorX.f
    MinimumY.i
    MaximumY.i
    MinimumX.i
    MaximumX.i
    Offset.i
  EndStructure ;}
  
  Structure Trend_Structure            ;{ Trend()\...
    CanvasNum.i
    PopupNum.i
    
    FontID.i
    
    Minimum.i
    Maximum.i
    Decimals.i
    
    AxisX.Trend_Axis_Structure
    AxisY.Trend_Axis_Structure
    Current.Trend_Currrent_Structure
    Line.Trend_Line_Structure
    
    Color.Trend_Color_Structure
    Mouse.Trend_Mouse_Structure
    Event.Trend_Event_Structure
    Margin.Trend_Margins_Structure
    Window.Trend_Window_Structure
    Size.Trend_Size_Structure
    EventSize.Trend_EventSize_Structure
    
    Flags.i
    
    List Item.Trend_Item_Structure()
    
    Map  Index.i()     ; labels with list index
    Map  PopUpItem.s()
    
    ToolTipText.s
    
    ReDraw.i
    Error.i
    ToolTip.i
  EndStructure ;}
  Global NewMap Trend.Trend_Structure()
  
  
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
  
  
  Procedure.s GetText_(Text.s)
    Define.s Text$ = ""
 
    If Text
      Text$ = ReplaceString(Text, #Value$, Str(Trend()\Item()\DataY))
      Text$ = ReplaceString(Text$, #Label$, Trend()\Item()\Label)
    EndIf

    ProcedureReturn Text$
  EndProcedure
  
  Procedure.s FormatValue_(DataY.f, Type.i=#False) 
   
    Select Type
      Case #AxisX
        If Trend()\AxisX\Flags & #Time
          ProcedureReturn FormatDate(Trend()\AxisX\DateMask, Int(DataY))
        Else
          ProcedureReturn StrF(DataY, Trend()\Decimals)
        EndIf 
      Case #AxisY
        If Trend()\AxisY\Flags & #Time
          ProcedureReturn FormatDate(Trend()\AxisY\DateMask, Int(DataY))
        Else
          ProcedureReturn StrF(DataY, Trend()\Decimals)
        EndIf 
      Default
        ProcedureReturn StrF(DataY, Trend()\Decimals)
    EndSelect
    
  EndProcedure
  
  Procedure   UpdatePopUpMenu_()
    Define.s Text$
    
    ForEach Trend()\PopUpItem()
      Text$ = GetText_(Trend()\PopUpItem())
      SetMenuItemText(Trend()\PopupNum, Val(MapKey(Trend()\PopUpItem())), Text$)
    Next
    
  EndProcedure
    
  Procedure.i MaxLabelWidth_()
    Define.i MaxWidth
    
    ForEach Trend()\Item()
      If TextWidth(Trend()\Item()\Label) > MaxWidth
        MaxWidth = TextWidth(Trend()\Item()\Label)
      EndIf
    Next
    
    ProcedureReturn MaxWidth
  EndProcedure

  Procedure.i MaximumValue_(X.i=#False)
    Define.i MaxValue

    MaxValue = Trend()\Maximum
    
    ForEach Trend()\Item()
      If Trend()\Item()\DataY > MaxValue
        MaxValue = Trend()\Item()\DataY
      EndIf
    Next

    ProcedureReturn MaxValue
  EndProcedure
  
  Procedure.i MinimumValue_(X.i=#False)
    Define.i MinValue

    MinValue = Trend()\Minimum
    
    ForEach Trend()\Item()
      If Trend()\Item()\DataY < MinValue
        MinValue = Trend()\Item()\DataY
      EndIf
    Next

    ProcedureReturn MinValue
  EndProcedure 
  
  Procedure.i CalcScaleLines_(ScaleLines.i, Range.i) 
    Define.i n
    
    If Range >= 10 And Mod(Range, 10) = 0 And Range / 10 <= ScaleLines
      
      ScaleLines = Range / 10
      
    ElseIf Range >= 5 And Mod(Range, 5) = 0 And Range / 5 <= ScaleLines
      
      ScaleLines = Range / 5
      
    Else

      If Range >= ScaleLines
        For n = ScaleLines To Int(ScaleLines / 2) Step -1
          If Mod(Range, n) = 0
            ScaleLines = n
            Break
          EndIf
        Next
      Else
        ScaleLines = Range
      EndIf 
    EndIf 
    
    ProcedureReturn ScaleLines
  EndProcedure
  
  ;- _______ Vector Drawing _______
  
  Procedure Box_(X.i, Y.i, Width.i, Height.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Flags.i=#False)
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    AddPathBox(X, Y, Width, Height)
    VectorSourceColor(Color)
    
    If FillColor <> #PB_Default
      
      If Alpha(FillColor) = #False : FillColor = RGBA(Red(FillColor), Green(FillColor), Blue(FillColor), 255) : EndIf
      
      If GradientColor <> #PB_Default
        If Alpha(GradientColor) = #False : GradientColor = RGBA(Red(GradientColor), Green(GradientColor), Blue(GradientColor), 255) : EndIf
        If Flags & #Horizontal
          VectorSourceLinearGradient(X, Y, X + Width, Y)
        ElseIf Flags & #Diagonal
          VectorSourceLinearGradient(X, Y, X + Width, Y + Height)
        Else
          VectorSourceLinearGradient(X, Y, X, Y + Height)
        EndIf
        VectorSourceGradientColor(FillColor, 1.0)
        VectorSourceGradientColor(GradientColor, 0.0)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(FillColor)
        FillPath(#PB_Path_Preserve)
      EndIf
      
    EndIf
    
    VectorSourceColor(Color)
    StrokePath(1)
    
  EndProcedure
  
  Procedure Circle_(X.i, Y.i, Radius.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default)

    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    AddPathCircle(X, Y, Radius)
    
    If FillColor <> #PB_Default
      
      If Alpha(FillColor) = #False : FillColor = RGBA(Red(FillColor), Green(FillColor), Blue(FillColor), 255) : EndIf
      
      If GradientColor <> #PB_Default
        If Alpha(GradientColor) = #False : GradientColor = RGBA(Red(GradientColor), Green(GradientColor), Blue(GradientColor), 255) : EndIf
        VectorSourceCircularGradient(X, Y, Radius)
        VectorSourceGradientColor(FillColor, 0.0)
        VectorSourceGradientColor(GradientColor, 1.0)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(FillColor)
        FillPath(#PB_Path_Preserve)
      EndIf
      
    EndIf
    
    VectorSourceColor(Color)
    StrokePath(1)
  
  EndProcedure
  
  Procedure LineXY_(X1.f, Y1.f, X2.f, Y2.f, Color.q)
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    MovePathCursor(X1, Y1)
    AddPathLine(X2, Y2)
    VectorSourceColor(Color)
    StrokePath(1)
    
  EndProcedure
  
  Procedure Text_(X.i, Y.i, Text$, Color.q, Angle.i=0)

    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    If Angle : RotateCoordinates(X, Y, Angle) : EndIf
    
    MovePathCursor(X, Y)
    VectorSourceColor(Color)
    DrawVectorText(Text$)

    If Angle : RotateCoordinates(X, Y, -Angle) : EndIf
    
  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure.q AlphaColor_(Color.i, Alpha.i)
    ProcedureReturn RGBA(Red(Color), Green(Color), Blue(Color), Alpha)
  EndProcedure 
  
  Procedure.q Alpha_(Color.i)
    ProcedureReturn RGBA(Red(Color), Green(Color), Blue(Color), 255)
  EndProcedure
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure.i Value_(Y.i) 
    Define.i DataY
    
    Y - Trend()\Margin\Top - Trend()\Current\Offset
    
    If Trend()\Current\MinimumY < 0
      
      If Y < 0
        DataY = Round(Trend()\Current\MinimumY - (Y / Trend()\Current\nFactorY), #PB_Round_Nearest)
      Else
        DataY = Round(Trend()\Current\MaximumY - (Y / Trend()\Current\pFactorY), #PB_Round_Nearest)
      EndIf
      
    Else

      If Trend()\Line\Flags & #Descending
        DataY = Round((Y / Trend()\Current\pFactorY) + Trend()\Current\MinimumY, #PB_Round_Nearest)
      Else
        DataY = Round(Trend()\Current\MaximumY - (Y / Trend()\Current\pFactorY), #PB_Round_Nearest)
      EndIf

    EndIf 
    
    If DataY < Trend()\Current\MinimumY : DataY = Trend()\Current\MinimumY : EndIf 
    If DataY > Trend()\Current\MaximumY : DataY = Trend()\Current\MaximumY : EndIf 
    
    ProcedureReturn DataY
  EndProcedure
  
  Procedure   Draw_()
    Define.i X, Y, Width, Height
    Define.i PosX, PosY, sWidth, cHeight, nHeight, pHeight, lastX, lastY, xW3
    Define.i txtX, txtY, txtWidth, txtHeight, axisY, Radius
    Define.i n, Items, Spaces, ScaleLines, AlphaColor, Color, maxValue, minValue
    Define.f SpaceY, FactorX, FactorY
    Define.s Text$
    
    X = Trend()\Margin\Left
    Y = Trend()\Margin\Top
  
    Width  = Trend()\Size\Width  - Trend()\Margin\Left - Trend()\Margin\Right
    Height = Trend()\Size\Height - Trend()\Margin\Top  - Trend()\Margin\Bottom
    
    If StartDrawing(CanvasOutput(Trend()\CanvasNum))
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, Trend()\Size\Width, Trend()\Size\Height, Trend()\Color\Back)
      ;}
      
      DrawingFont(Trend()\FontID)

      Trend()\Current\MaximumY = Trend()\Maximum ;{ Maximum
      maxValue = MaximumValue_()
      If Trend()\Current\MaximumY = #PB_Default
        Trend()\Current\MaximumY = maxValue
      ElseIf Trend()\Line\Flags & #NoAutoAdjust = #False
        Trend()\Current\MaximumY = Trend()\Maximum
        If maxValue > Trend()\Current\MaximumY : Trend()\Current\MaximumY = maxValue : EndIf
      EndIf ;}
      
      Trend()\Current\MinimumY = Trend()\Minimum ;{ Minimum
      minValue = MinimumValue_()
      If Trend()\Current\MinimumY = #PB_Default
        Trend()\Current\MinimumY = minValue
      ElseIf Trend()\Line\Flags & #NoAutoAdjust = #False
        If minValue < Trend()\Current\MinimumY : Trend()\Current\MinimumY = minValue : EndIf
      EndIf ;}
     
      txtHeight = TextHeight("Abc")
      txtWidth  = TextWidth(Str(Trend()\Current\MaximumY))
      
      X + txtWidth + dpiX(2)
      Y + (txtHeight / 2)

      Width  - txtWidth - dpiX(2)
      Height - (txtHeight * 1.5) - dpiY(4)

      Trend()\Current\Offset = txtHeight / 2
      
      Trend()\EventSize\X = X
      Trend()\EventSize\Y = Y
      Trend()\EventSize\Width  = Width
      Trend()\EventSize\Height = Height
      
      Trend()\Line\RangeY = Trend()\Current\MaximumY - Trend()\Current\MinimumY
      
      ;{ --- Calc Height for positive and negative Values ---
      If Trend()\Current\MinimumY < 0
        FactorY  = Height / Trend()\Line\RangeY
        pHeight  = FactorY * Trend()\Current\MaximumY ; positiv
        nHeight  = FactorY * Trend()\Current\MinimumY ; negativ 
      Else
        pHeight = Height ; positiv
        nHeight = 0      ; negativ
      EndIf ;}

      Items  = ListSize(Trend()\Item())

      ;{ --- Draw Coordinate Axes ---
      DrawingMode(#PB_2DDrawing_Transparent)
      
      ; ----- Y-Axis -----
      
      If Trend()\Line\ScaleLines = #PB_Default
        If Trend()\Line\ScaleSpacing = 0 : Trend()\Line\ScaleSpacing = 1 : EndIf
        ScaleLines = Height / (txtHeight * Trend()\Line\ScaleSpacing)
        ScaleLines = CalcScaleLines_(ScaleLines, Trend()\Line\RangeY)
      Else
        ScaleLines = Trend()\Line\ScaleLines
      EndIf

      If ScaleLines
        
        FactorY = Trend()\Line\RangeY  / ScaleLines
        SpaceY  = Height / ScaleLines

        For n = 0 To ScaleLines
          PosY = Y + Round(n * SpaceY, #PB_Round_Nearest)
          If Trend()\Flags & #ShowLines
            Line(X, PosY, Width, 1, BlendColor_(Trend()\Color\Axis, Trend()\Color\Back, 10))
          EndIf 
          Line(X - dpiX(2), PosY, dpiX(5), 1, Trend()\Color\Axis)
          If Trend()\Line\Flags & #Descending
            Text$ = Str((FactorY * n) + Trend()\Current\MinimumY)
          Else
            Text$ = Str(Trend()\Current\MaximumY - (FactorY * n))
          EndIf
          txtX = X - TextWidth(Text$) - dpix(4)
          txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
          DrawText(txtX, txtY, Text$, Trend()\Color\Front)
        Next
        
        Line(X, Y, 1, Height, Trend()\Color\Axis)
        Line(X, Y + pHeight, Width, 1, Trend()\Color\Axis)
        
      EndIf ;} 
      
      StopDrawing()
    EndIf 
  
    If StartVectorDrawing(CanvasVectorOutput(Trend()\CanvasNum))

      Radius = Trend()\Line\Diameter / 2
      
      FactorX = (Width - (Trend()\Line\Padding * 2)) / Trend()\Line\RangeX
      
      ;{ --- Draw Lines ---
      AlphaColor = RGBA(Red(Trend()\Line\Color), Green(Trend()\Line\Color), Blue(Trend()\Line\Color), 140)

      If Trend()\Line\Flags & #OutOfRange
        SaveVectorState()
        AddPathBox(X, Y, Width, Height)
        ClipPath()
      EndIf
      
      ForEach Trend()\Item()
        
        If Trend()\Item()\DataX < Trend()\Line\StartValue Or Trend()\Item()\DataX > Trend()\Line\EndValue : Continue : EndIf
        
        PosX = X + Round((Trend()\Item()\DataX - Trend()\Line\StartValue) * FactorX, #PB_Round_Nearest) + Trend()\Line\Padding
        If PosX > X + Width : PosX = X + Width : EndIf 
        
        xW3 = Round((PosX - LastX) / 3, #PB_Round_Nearest)
        
        If (Trend()\Item()\DataY >= Trend()\Current\MinimumY And Trend()\Item()\DataY <= Trend()\Current\MaximumY) Or Trend()\Line\Flags & #OutOfRange
          
          ;{ --- Calc Position & Height ---
          If Trend()\Current\MinimumY < 0
            
            If Trend()\Item()\DataY < 0
              PosY = Y + pHeight + dpiY(1)
              FactorY = nHeight / Trend()\Current\MinimumY
              cHeight = Trend()\Item()\DataY * FactorY
              If Trend()\Item()\DataY < Trend()\Current\MinimumY : cHeight = - SpaceY : EndIf 
            Else
              PosY = Y + pHeight
              FactorY  = pHeight / Trend()\Current\MaximumY
              cHeight = Trend()\Item()\DataY * FactorY
              If Trend()\Item()\DataY < Trend()\Current\MinimumY
                cHeight = - SpaceY   
              ElseIf Trend()\Item()\DataY > Trend()\Current\MaximumY
                cHeight = (Trend()\Current\MaximumY - Trend()\Current\MinimumY) * FactorY + SpaceY
              EndIf 
            EndIf
            
            PosY - cHeight
            
          Else
          
            FactorY = Height / Trend()\Line\RangeY
            If Trend()\Line\Flags & #Descending
              cHeight = (Trend()\Current\MaximumY - (Trend()\Item()\DataY)) * FactorY
              If Trend()\Item()\DataY < Trend()\Current\MinimumY
                cHeight = (Trend()\Current\MaximumY - Trend()\Current\MinimumY) * FactorY + SpaceY
              ElseIf Trend()\Item()\DataY > Trend()\Current\MaximumY
                cHeight = - SpaceY   
              EndIf 
            Else
              cHeight = (Trend()\Item()\DataY - Trend()\Current\MinimumY) * FactorY
              If Trend()\Item()\DataY < Trend()\Current\MinimumY
                cHeight = - SpaceY   
              ElseIf Trend()\Item()\DataY > Trend()\Current\MaximumY
                cHeight = (Trend()\Current\MaximumY - Trend()\Current\MinimumY) * FactorY + SpaceY
              EndIf 
            EndIf
            
            PosY = Y + pHeight - cHeight

          EndIf ;} 
          
          If LastX = 0
            MovePathCursor(PosX, PosY)
          Else
            If Trend()\Line\Flags & #BezierCurve
              AddPathCurve(lastX + xW3, LastY, PosX - xW3, PosY, PosX, PosY)
            Else
              AddPathLine(PosX, PosY)
            EndIf  
          EndIf

          LastX = PosX : LastY = PosY
        EndIf
        
      Next 
      
      VectorSourceColor(AlphaColor)
      StrokePath(2, #PB_Path_RoundCorner)
      
      If Trend()\Line\Flags & #OutOfRange : RestoreVectorState() : EndIf
      ;}
      
      ForEach Trend()\Item()
        
        If Trend()\Item()\DataX < Trend()\Line\StartValue Or Trend()\Item()\DataX > Trend()\Line\EndValue : Continue : EndIf
        
        PosX = X + Round((Trend()\Item()\DataX - Trend()\Line\StartValue) * FactorX, #PB_Round_Nearest) + Trend()\Line\Padding
        If PosX > X + Width : PosX = X + Width : EndIf 
        
        ;{ --- Calc Position & Height ---
        If Trend()\Current\MinimumY < 0
          
          If Trend()\Item()\DataY < 0
            PosY = Y + pHeight + dpiY(1)
            FactorY = nHeight / Trend()\Current\MinimumY
            Trend()\Current\nFactorY= FactorY
          Else
            PosY = Y + pHeight
            FactorY = pHeight / Trend()\Current\MaximumY
            Trend()\Current\pFactorY= FactorY
          EndIf
          
          PosY - cHeight
          cHeight = Trend()\Item()\DataY * FactorY
         
        Else
          
          FactorY = Height / Trend()\Line\RangeY
          
          If Trend()\Line\Flags & #Descending
            cHeight = (Trend()\Current\MaximumY - (Trend()\Item()\DataY)) * FactorY
          Else
            cHeight = (Trend()\Item()\DataY - Trend()\Current\MinimumY) * FactorY
          EndIf
          
          PosY = Y + pHeight - cHeight
          Trend()\Current\pFactorY= FactorY
          
        EndIf ;}
        
        If Trend()\Flags & #ShowValue
          Text$ = Str(Trend()\Item()\DataY)
        Else
          Text$ = GetText_(Trend()\Item()\Text)
        EndIf
        
        ;{ --- Draw Circles ---
        Color = Trend()\Item()\Color
        If Color = #PB_Default : Color = Trend()\Color\Circle : EndIf
        
        If Trend()\Item()\DataY >= Trend()\Current\MinimumY And Trend()\Item()\DataY <= Trend()\Current\MaximumY
          
          Circle_(PosX, PosY, Radius, BlendColor_(Color, Trend()\Color\Border, 50), Color)
          
          ;{ --- Set data ----
          Trend()\Item()\X      = PosX
          Trend()\Item()\Y      = PosY
          Trend()\Item()\Radius = Radius
          ;}
          
        Else
          Trend()\Item()\X = 0
          Trend()\Item()\Y = 0
          cHeight = 0
          Trend()\Item()\Radius = Radius
          Color = #Error
        EndIf ;}

        ;{ --- Draw Text ---
        If Text$ 
          
          If Trend()\Line\FontSize = #PB_Default
            VectorFont(Trend()\Line\FontID)
          Else
            VectorFont(Trend()\Line\FontID, dpiY(Trend()\Line\FontSize))
          EndIf
          
          txtX = PosX + ((Trend()\Line\Diameter - VectorTextWidth(Text$)) / 2)
          
          If Trend()\Item()\DataY < 0
            txtY = PosY - VectorTextHeight(Text$) - dpiY(2)
          Else
            txtY = PosY - cHeight - VectorTextHeight(Text$) - dpiY(2)
          EndIf

          If Color = #Error
            Text_(txtX, Y + Height - VectorTextHeight(Text$) - dpiY(2), Text$, $0000FF)
          Else
            Text_(txtX, txtY, Text$, BlendColor_(Trend()\Color\Front, Color, 40))
          EndIf  
          
        EndIf ;}

      Next
      
      StopVectorDrawing()
    EndIf
    
    If StartDrawing(CanvasOutput(Trend()\CanvasNum))
      
      DrawingFont(Trend()\FontID)
      
      FactorX = (Width - (Trend()\Line\Padding * 2)) / Trend()\Line\RangeX
      
      ForEach Trend()\Item()
        
        If Trend()\Item()\DataX < Trend()\Line\StartValue Or Trend()\Item()\DataX > Trend()\Line\EndValue : Continue : EndIf
        
        PosX = X + Round((Trend()\Item()\DataX - Trend()\Line\StartValue) * FactorX, #PB_Round_Nearest) + Trend()\Line\Padding
        If PosX > X + Width : PosX = X + Width : EndIf 

        Line(PosX, Y + pHeight - dpiX(2), 1, dpiX(5), Trend()\Color\Axis)
        
        ;{ --- Draw Labels ---
        Text$ = Trend()\Item()\Label
        txtX  = PosX + ((Radius - TextWidth(Text$)) / 2)
        txtY  = Y + pHeight + dpiY(4)
        
        DrawingMode(#PB_2DDrawing_Transparent)
        
        Color = Trend()\Item()\Color
        If Color = #PB_Default : Color = Trend()\Color\Circle : EndIf
        
        If Trend()\Line\Flags & #Colored
          DrawText(txtX, txtY, Text$, BlendColor_(Trend()\Color\Front, Color, 30))
        Else
          DrawText(txtX, txtY, Text$, Trend()\Color\Front)
        EndIf ;}
        
      Next
      
      ;{ _____ Border ____
      If Trend()\Flags & #Border
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(0, 0, Trend()\Size\Width, Trend()\Size\Height, Trend()\Color\Border)
      EndIf ;}
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  ;- __________ Events __________
  
  Procedure.i GetRadius_(X1.i, Y1.i, X2.i, Y2.i)
    Define.f X, Y
    X = X1 - X2
    Y = Y1 - Y2
    ProcedureReturn Sqr((X * X) + (Y * Y))
  EndProcedure
  
  Procedure   UpdateEventData_(Index.i, Label.s, DataX.q=0, DataY.i=0, Color.i=#PB_Default)
    
    Trend()\Event\Index  = Index
    
    Trend()\Event\DataX  = DataX
    Trend()\Event\DataY  = DataY
    Trend()\Event\Label  = Label
    Trend()\Event\Color  = Color

  EndProcedure
  
  
  Procedure _LeftDoubleClickHandler()
    Define.i X, Y, Angle, Radius
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Trend(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Trend()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Trend()\CanvasNum, #PB_Canvas_MouseY)
      
      ForEach Trend()\Item()
        If X > Trend()\Item()\X - Trend()\Item()\Radius And X < Trend()\Item()\X + Trend()\Item()\Radius
          If Y > Trend()\Item()\Y - Trend()\Item()\Radius And Y < Trend()\Item()\Y + Trend()\Item()\Radius
            
            UpdateEventData_(ListIndex(Trend()\Item()), Trend()\Item()\Label, Trend()\Item()\DataX, Trend()\Item()\DataY, Trend()\Item()\Color)
            PostEvent(#Event_Gadget, Trend()\Window\Num, Trend()\CanvasNum, #PB_EventType_LeftDoubleClick, ListIndex(Trend()\Item()))
            
            ProcedureReturn #True
          EndIf 
        EndIf
      Next  
 
    EndIf
    
  EndProcedure
  
  Procedure _RightClickHandler()
    Define.i X, Y, Angle, Radius
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Trend(), Str(GadgetNum))

      X = GetGadgetAttribute(Trend()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Trend()\CanvasNum, #PB_Canvas_MouseY)

      ForEach Trend()\Item()
        
        If X > Trend()\Item()\X - Trend()\Item()\Radius And X < Trend()\Item()\X + Trend()\Item()\Radius
          If Y > Trend()\Item()\Y - Trend()\Item()\Radius And Y < Trend()\Item()\Y + Trend()\Item()\Radius
            
            UpdateEventData_(ListIndex(Trend()\Item()), Trend()\Item()\Label, Trend()\Item()\DataX, Trend()\Item()\DataY, Trend()\Item()\Color)

            If Trend()\Line\Flags & #PopUpMenu
              If IsWindow(Trend()\Window\Num) And IsMenu(Trend()\PopUpNum)
                UpdatePopUpMenu_()
                DisplayPopupMenu(Trend()\PopUpNum, WindowID(Trend()\Window\Num))
              EndIf
            Else
              PostEvent(#Event_Gadget, Trend()\Window\Num, Trend()\CanvasNum, #PB_EventType_RightClick, ListIndex(Trend()\Item()))
            EndIf
            
            ProcedureReturn #True 
          EndIf 
        EndIf
        
      Next
      
      If Trend()\Flags & #PopUpMenu
        If X > = Trend()\EventSize\X And X <= Trend()\EventSize\X + Trend()\EventSize\Width
          If Y >= Trend()\EventSize\Y And Y <= Trend()\EventSize\Y + Trend()\EventSize\Height
            If IsWindow(Trend()\Window\Num) And IsMenu(Trend()\PopUpNum)
              UpdatePopUpMenu_()
              DisplayPopupMenu(Trend()\PopUpNum, WindowID(Trend()\Window\Num))
            EndIf
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonUpHandler()  
    Define.i X, Y
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Trend(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Trend()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Trend()\CanvasNum, #PB_Canvas_MouseY)

      ForEach Trend()\Item()

        If X > Trend()\Item()\X - Trend()\Item()\Radius And X < Trend()\Item()\X + Trend()\Item()\Radius
          If Y > Trend()\Item()\Y - Trend()\Item()\Radius And Y < Trend()\Item()\Y + Trend()\Item()\Radius
            
            UpdateEventData_(ListIndex(Trend()\Item()), Trend()\Item()\Label, Trend()\Item()\DataX, Trend()\Item()\DataY, Trend()\Item()\Color)
            PostEvent(#Event_Gadget, Trend()\Window\Num, Trend()\CanvasNum, #PB_EventType_LeftClick, ListIndex(Trend()\Item()))
            
            ProcedureReturn #True
          EndIf 
        EndIf

      Next 
      
    EndIf 
    
  EndProcedure

  Procedure _MouseMoveHandler()
    Define.i X, Y
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Trend(), Str(GadgetNum))
      
      X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)

      If X >= Trend()\EventSize\X And X <= Trend()\EventSize\X + Trend()\EventSize\Width
        If Y >= Trend()\EventSize\Y And Y <= Trend()\EventSize\Y + Trend()\EventSize\Height

          ForEach Trend()\Item()
            
            If X >= Trend()\Item()\X  - Trend()\Item()\Radius And X <= Trend()\Item()\X + Trend()\Item()\Radius
              If Y >= Trend()\Item()\Y - Trend()\Item()\Radius And Y <= Trend()\Item()\Y + Trend()\Item()\Radius
                
                If Trend()\Flags & #ToolTips And Trend()\ToolTip = #False
                  GadgetToolTip(GadgetNum, GetText_(Trend()\ToolTipText))
                  Trend()\ToolTip = #True
                EndIf
                
                If Trend()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf
                
                ProcedureReturn #True
              EndIf 
            EndIf
            
          Next  

        EndIf
      EndIf

      Trend()\ToolTip = #False
      GadgetToolTip(GadgetNum, "")
      
      If Trend()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default) : EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(Trend(), Str(GadgetID))
      
      Trend()\Size\Width  = dpiX(GadgetWidth(GadgetID))
      Trend()\Size\Height = dpiY(GadgetHeight(GadgetID))
      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach Trend()
      
      If IsGadget(Trend()\CanvasNum)
        
        If Trend()\Flags & #AutoResize
          
          If IsWindow(Trend()\Window\Num)
            
            OffSetX = WindowWidth(Trend()\Window\Num)  - Trend()\Window\Width
            OffsetY = WindowHeight(Trend()\Window\Num) - Trend()\Window\Height

            Trend()\Window\Width  = WindowWidth(Trend()\Window\Num)
            Trend()\Window\Height = WindowHeight(Trend()\Window\Num)
            
            If Trend()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If Trend()\Size\Flags & #MoveX : X = GadgetX(Trend()\CanvasNum) + OffSetX : EndIf
              If Trend()\Size\Flags & #MoveY : Y = GadgetY(Trend()\CanvasNum) + OffSetY : EndIf
              If Trend()\Size\Flags & #ResizeWidth  : Width  = GadgetWidth(Trend()\CanvasNum)  + OffSetX : EndIf
              If Trend()\Size\Flags & #ResizeHeight : Height = GadgetHeight(Trend()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(Trend()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(Trend()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(Trend()\CanvasNum) + OffSetX, GadgetHeight(Trend()\CanvasNum) + OffsetY)
            EndIf
          
            Draw_()
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure.i AddItem(GNum.i, DataX.q, DataY.i, Label.s="", Color.i=#PB_Default)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If Color = #PB_Default : Color = Trend()\Color\Circle : EndIf
      
      If DataY < Trend()\Minimum ;{ Error: Minimum
        Trend()\Error = #Error_Minimum
        ;}
      EndIf  
      
      If Trend()\Maximum <> #PB_Default And DataY > Trend()\Maximum ;{ Error: Maximum
        Trend()\Error = #Error_Maximum
        ;}
      EndIf
      
      If Label = ""
        If Trend()\AxisX\DateMask
          Label = FormatDate(Trend()\AxisX\DateMask, DataX)
        Else
          Label = Str(DataX)
        EndIf
      EndIf
      
      If FindMapElement(Trend()\Index(), Label) ;{ Error: Label already exists
        Trend()\Error = #Error_LabelExists
        ProcedureReturn #False
        ;}
      EndIf
      
      If AddElement(Trend()\Item())
        
        Trend()\Item()\Label = Label
        Trend()\Item()\DataX = DataX
        Trend()\Item()\DataY = DataY
        Trend()\Item()\Color = Color
        
        If AddMapElement(Trend()\Index(), Label)
          Trend()\Index() = ListIndex(Trend()\Item())
        EndIf
        
        ProcedureReturn #True
      EndIf  
     
    EndIf
    
  EndProcedure
  
  
  Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)
    
    If FindMapElement(Trend(), Str(GNum))
      Trend()\PopupNum = PopUpNum
    EndIf
    
  EndProcedure
  
  Procedure   DisableReDraw(GNum.i, State.i=#False)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If State
        Trend()\ReDraw = #False
      Else
        Trend()\ReDraw = #True
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   DisplayValues(GNum.i, StartValue.q, EndValue.q)
    
    If FindMapElement(Trend(), Str(GNum))
      
      Trend()\Line\StartValue = StartValue
      Trend()\Line\EndValue   = EndValue
      Trend()\Line\RangeX     = EndValue - StartValue
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure.i EventColor(GNum.i)
    
    If FindMapElement(Trend(), Str(GNum))
      ProcedureReturn Trend()\Event\Color
    EndIf 
    
  EndProcedure
  
  Procedure.i EventIndex(GNum.i)
    
    If FindMapElement(Trend(), Str(GNum))
      ProcedureReturn Trend()\Event\Index
    EndIf 
    
  EndProcedure
  
  Procedure.s EventLabel(GNum.i)
    
    If FindMapElement(Trend(), Str(GNum))
      ProcedureReturn Trend()\Event\Label
    EndIf
    
  EndProcedure
  
  Procedure.i EventValue(GNum.i)
    
    If FindMapElement(Trend(), Str(GNum))
      ProcedureReturn Trend()\Event\DataY
    EndIf 
    
  EndProcedure
  
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Define txtNum, Result.i
    
    Result = CanvasGadget(GNum, X, Y, Width, Height)
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X      = dpiX(X)
      Y      = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If AddMapElement(Trend(), Str(GNum))
        
        Trend()\CanvasNum = GNum
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default
            Trend()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            Trend()\Window\Num = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            Trend()\Window\Num = GetActiveWindow()
          Else
            Trend()\Window\Num = WindowNum
          EndIf
        CompilerEndIf   
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            Trend()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              Trend()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            Trend()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        Trend()\Line\FontID = Trend()\FontID
        
        Trend()\Size\X = X
        Trend()\Size\Y = Y
        Trend()\Size\Width  = Width
        Trend()\Size\Height = Height
        
        Trend()\Margin\Left   = 10
        Trend()\Margin\Right  = 10
        Trend()\Margin\Top    = 10
        Trend()\Margin\Bottom = 10
        
        Trend()\Minimum  = 0
        Trend()\Maximum  = #PB_Default
        Trend()\Decimals = 0

        Trend()\Line\ScaleSpacing = #Single
        Trend()\Line\ScaleLines   = #PB_Default
        Trend()\Line\Diameter     = dpiX(6)
        Trend()\Line\Spacing      = #PB_Default
        Trend()\Line\Padding      = 16
        Trend()\Line\Color        = $9F723E
        Trend()\Line\FontSize     = #PB_Default
        
        Trend()\AxisX\DateMask = "%hh:%ii"
        Trend()\AxisY\DateMask = "%hh:%ii"
        
        Trend()\ToolTipText = #Value$
        Trend()\Flags       = Flags

        Trend()\ReDraw = #True
        
        Trend()\Color\Front     = $000000
        Trend()\Color\Back      = $EDEDED
        Trend()\Color\Border    = $A0A0A0
        Trend()\Color\Axis      = $000000
        Trend()\Color\Circle    = $B48246
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            Trend()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            Trend()\Color\Back          = GetSysColor_(#COLOR_MENU)
            Trend()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
          CompilerCase #PB_OS_MacOS
            Trend()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            Trend()\Color\Back          = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            Trend()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}        

        BindGadgetEvent(Trend()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
        BindGadgetEvent(Trend()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(Trend()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        BindGadgetEvent(Trend()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(Trend()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)

        If Flags & #AutoResize
          If IsWindow(Trend()\Window\Num)
            Trend()\Window\Width  = WindowWidth(Trend()\Window\Num)
            Trend()\Window\Height = WindowHeight(Trend()\Window\Num)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), Trend()\Window\Num)
          EndIf  
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.s GetErrorMessage(GNum.i, Language.s="")
    
    If FindMapElement(Trend(), Str(GNum))
      
      Select Left(UCase(Language), 2)
        Case "DE" ;{ German
          Select Trend()\Error
            Case #Error_LabelExists
              ProcedureReturn "Label existiert bereits."
            Case #Error_Minimum
              ProcedureReturn "Wert kleiner als Minimum."
            Case #Error_Maximum
              ProcedureReturn "Wert größer als Maximum."  
            Case #Error_LabelUnknown
              ProcedureReturn "Label unbekannt." 
            Case #Error_IndexNotValid
              ProcedureReturn "Index ungültig." 
          EndSelect
          ;}
        Case "FR" ;{ France
          Select Trend()\Error
            Case #Error_LabelExists
              ProcedureReturn "L'étiquette existe déjà."
            Case #Error_Minimum
              ProcedureReturn "Valeur inférieure à la valeur minimale"
            Case #Error_Maximum
              ProcedureReturn "Valeur supérieure au maximum." 
            Case #Error_LabelUnknown
              ProcedureReturn "." 
            Case #Error_IndexNotValid
              ProcedureReturn "."   
          EndSelect
          ;}
        Case "ES" ;{ Spanish
          Select Trend()\Error
            Case #Error_LabelExists
              ProcedureReturn "La etiqueta ya existe."
            Case #Error_Minimum
              ProcedureReturn "Valor inferior al mínimo."
            Case #Error_Maximum
              ProcedureReturn "Valor superior al máximo" 
            Case #Error_LabelUnknown
              ProcedureReturn "." 
            Case #Error_IndexNotValid
              ProcedureReturn "."   
          EndSelect ;} 
        Default   ;{ English
          Select Trend()\Error
            Case #Error_LabelExists
              ProcedureReturn "Label already exists."
            Case #Error_Minimum
              ProcedureReturn "Value less than minimum"
            Case #Error_Maximum
              ProcedureReturn "Value greater than maximum"
            Case #Error_LabelUnknown
              ProcedureReturn "." 
            Case #Error_IndexNotValid
              ProcedureReturn "."   
          EndSelect
          ;}
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetItemColor(GNum.i, Position.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn #NotValid
        ;}
      EndIf
      
      If SelectElement(Trend()\Item(), Position)
        ProcedureReturn Trend()\Item()\Color
      Else
        Trend()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.s GetItemLabel(GNum.i, Position.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn ""
        ;}
      EndIf
      
      If SelectElement(Trend()\Item(), Position)
        ProcedureReturn Trend()\Item()\Label
      Else
        Trend()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf

  EndProcedure
  
  Procedure.i GetItemState(GNum.i, Position.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn #NotValid
        ;}
      EndIf
      
      If SelectElement(Trend()\Item(), Position)
        ProcedureReturn Trend()\Item()\DataY
      Else
        Trend()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.s GetItemText(GNum.i, Position.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn ""
        ;}
      EndIf
      
      If SelectElement(Trend()\Item(), Position)
        ProcedureReturn Trend()\Item()\Text
      Else
        Trend()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf

  EndProcedure
  
  Procedure.i GetLabelColor(GNum.i, Label.s)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If FindMapElement(Trend()\Index(), Label)
        If SelectElement(Trend()\Item(), Trend()\Index())
          ProcedureReturn Trend()\Item()\Color
        Else
          Trend()\Error = #Error_IndexNotValid
        EndIf
      Else
        Trend()\Error = #Error_LabelUnknown
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.i GetLabelState(GNum.i, Label.s)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If FindMapElement(Trend()\Index(), Label)
        If SelectElement(Trend()\Item(), Trend()\Index())
          ProcedureReturn Trend()\Item()\DataY
        Else
          Trend()\Error = #Error_IndexNotValid
        EndIf
      Else
        Trend()\Error = #Error_LabelUnknown
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure   LoadValues(GNum.i, File.s)
    Define.i JSON
    
    If FindMapElement(Trend(), Str(GNum))
      
      JSON = LoadJSON(#PB_Any, File)
      If JSON
        
        ExtractJSONList(JSONValue(JSON), Trend()\Item())
        FreeJSON(JSON)
        
        ClearMap(Trend()\Index())
        ForEach Trend()\Item()
          Trend()\Index(Trend()\Item()\Label) = ListIndex(Trend()\Item())
        Next  
        
      EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure.i RemoveItem(GNum.i, Position.i)
    
    If FindMapElement(Trend(), Str(GNum))

      If Position < 0            ;{ Error: List Index
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn #False
        ;}
      EndIf
      
      If SelectElement(Trend()\Item(), Position)
        
        DeleteMapElement(Trend()\Index(), Trend()\Item()\Label)
        DeleteElement(Trend()\Item())
        
        If Trend()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      Else
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn #False
      EndIf

    EndIf
    
  EndProcedure
  
  Procedure   RemoveLabel(GNum.i, Label.s)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If FindMapElement(Trend()\Index(), Label)
        
        If SelectElement(Trend()\Item(), Trend()\Index())
          DeleteElement(Trend()\Item())
          DeleteMapElement(Trend()\Index())
        EndIf
        
      Else
        Trend()\Error = #Error_LabelUnknown  
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SaveValues(GNum.i, File.s)
    Define.i JSON
    
    If FindMapElement(Trend(), Str(GNum))
      
      JSON = CreateJSON(#PB_Any)
      If JSON
        InsertJSONList(JSONValue(JSON), Trend()\Item())
        SaveJSON(JSON, File)
        FreeJSON(JSON)
      EndIf
 
    EndIf 
    
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, DataY.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      Select Attribute
        Case #Minimum        ;{ minimum DataY (Y-axis)
          Trend()\Minimum = DataY
          ;}
        Case #Maximum        ;{ maximum DataY (Y-axis)
          Trend()\Maximum = DataY 
          ;}
        Case #MinimumX       ;{ minimum DataY (X-axis)
          Trend()\Minimum = DataY
          ;}
        Case #MaximumX       ;{ maximum DataY (X-axis)
          Trend()\Maximum = DataY 
          ;}
        Case #Diameter          ;{ width (X-axis)
          Trend()\Line\Diameter  = dpiX(DataY)
          ;}
        Case #Spacing        ;{ width of spacing (X-axis)
          Trend()\Line\Spacing = dpiX(DataY)
          ;}
        Case #LineColor      ;{ Color for line chart
          Trend()\Line\Color = DataY
          ;}
        Case #Padding        ;{ padding between data series bars
          Trend()\Line\Padding = DataY
          ;}
        Case #ScaleLines     ;{ Number of scale lines (Y-axis)
          Trend()\Line\ScaleLines = DataY
          ;}
        Case #ScaleSpacing   ;{ Spacing of scale lines [#Single/#Double]
          If DataY > 0 : Trend()\Line\ScaleSpacing = DataY : EndIf
          ;}
        Case #FontSize       ;{ Font size for vector text
          Trend()\Line\FontSize = DataY
          ;}
        Case #Decimals       ;{ Decimal places for scatter plot data
          Trend()\Decimals = DataY
          ;}
      EndSelect
      
      If Trend()\ReDraw : Draw_() : EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      Trend()\Size\Flags = Flags
      Trend()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          Trend()\Color\Front     = Color
        Case #BackColor
          Trend()\Color\Back      = Color
        Case #AxisColor
          Trend()\Color\Axis      = Color   
        Case #CircleColor
          Trend()\Color\Circle    = Color
        Case #BorderColor
          Trend()\Color\Border    = Color
      EndSelect
      
      If Trend()\ReDraw : Draw_() : EndIf
      
    EndIf 
    
  EndProcedure
  
  Procedure   SetFlags(GNum.i, Type.i, Flags.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      Select Type
        Case #Gadget
          Trend()\Line\Flags | Flags
        Case #AxisX
          Trend()\AxisX\Flags | Flags
        Case #AxisY
          Trend()\AxisY\Flags | Flags
      EndSelect
      
      If Trend()\ReDraw : Draw_() : EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i, Flags.i=#False) 
    
    If FindMapElement(Trend(), Str(GNum))
      
      If Flags & #DataText   ;{ Text over data points
        Trend()\Line\FontID = FontID
        ;}
      Else
        Trend()\FontID = FontID
      EndIf
      
      If Trend()\ReDraw : Draw_() : EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure.i SetItemState(GNum.i, Position.i, State.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If State < Trend()\Minimum ;{ Error: Minimum
        Trend()\Error = #Error_Minimum
        ;}
      EndIf  
      
      If Trend()\Maximum <> #PB_Default And State > Trend()\Maximum ;{ Error: Maximum
        Trend()\Error = #Error_Maximum
        ;}
      EndIf
      
      If Position < 0            ;{ Error: List Index
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn #False
        ;}
      EndIf
      
      If SelectElement(Trend()\Item(), Position)
        
        Trend()\Item()\DataY = State
        If Trend()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      Else
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn #False
      EndIf

    EndIf  
    
  EndProcedure  
  
  Procedure.i SetItemText(GNum.i, Position.i, Text.s)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Trend()\Error = #Error_IndexNotValid
        ProcedureReturn #False
        ;}
      EndIf
      
      If SelectElement(Trend()\Item(), Position)
        
        Trend()\Item()\Text = Text
        
        If Trend()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      Else
        Trend()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetLabelState(GNum.i, Label.s, State.i)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If State < Trend()\Minimum ;{ Error: Minimum
        Trend()\Error = #Error_Minimum
        ;}
      EndIf  
      
      If Trend()\Maximum <> #PB_Default And State > Trend()\Maximum ;{ Error: Maximum
        Trend()\Error = #Error_Maximum
        ;}
      EndIf
      
      If FindMapElement(Trend()\Index(), Label)
        If SelectElement(Trend()\Item(), Trend()\Index())
          
          Trend()\Item()\DataY = State
          
          If Trend()\ReDraw : Draw_() : EndIf
          
          ProcedureReturn #True
        Else
          Trend()\Error = #Error_IndexNotValid
          ProcedureReturn #False
        EndIf
      Else
        Trend()\Error = #Error_LabelUnknown
        ProcedureReturn #False
      EndIf
 
    EndIf  
    
  EndProcedure  
  
  Procedure   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
    
    If FindMapElement(Trend(), Str(GNum))
      
      Trend()\Margin\Top    = dpiY(Top)
      Trend()\Margin\Left   = dpiX(Left)
      If Right = #PB_Default
        Trend()\Margin\Right = Trend()\Margin\Left
      Else  
        Trend()\Margin\Right = dpiX(Right)
      EndIf  
      If Bottom = #PB_Default
        Trend()\Margin\Bottom = Trend()\Margin\Top
      Else
        Trend()\Margin\Bottom = dpiY(Bottom)
      EndIf
      
    EndIf 
    
  EndProcedure
  
  Procedure   SetMask(GNum.i, Type.i, String.s)
    
    If FindMapElement(Trend(), Str(GNum))
      
      Select Type
        Case #AxisX
          Trend()\AxisX\DateMask = String
        Case #AxisY
          Trend()\AxisY\DateMask = String
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure   ToolTipText(GNum.i, Text.s) ; #Value$ / #Label$
    
    If FindMapElement(Trend(), Str(GNum))
      
      Trend()\ToolTipText = Text
      
    EndIf  
    
  EndProcedure
  
  Procedure.q Time(Hour.i, Minute.i=0, Second.i=0, CurrentDate.i=#False)
  
    If CurrentDate
      ProcedureReturn Date(Year(Date()), Month(Date()), Day(Date()), Hour, Minute, Second)
    Else
      ProcedureReturn Date(2000, 1, 1, Hour, Minute, Second)
    EndIf
    
  EndProcedure
  
  Procedure   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
    
    If FindMapElement(Trend(), Str(GNum))
      
      If AddMapElement(Trend()\PopUpItem(), Str(MenuItem))
        Trend()\PopUpItem() = Text
      EndIf 
      
    EndIf
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  ; ----- Select Example -----
  
  #Example = 1
 
  Enumeration 
    #Window
    #Trend
    #Label
    #Value
    #Button
    #PopUp
    #Menu_Hide
    #Menu_Display
    #Font
    #FontB
  EndEnumeration
  
  LoadFont(#Font,  "Arial", 8)
  LoadFont(#FontB, "Arial", 10, #PB_Font_Bold)
  
  If OpenWindow(#Window, 0, 0, 315, 230, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#PopUp)
      MenuItem(#Menu_Display, "Display data series")
      MenuBar()
      MenuItem(#Menu_Hide, "Hide data series")
    EndIf 
    
    CompilerSelect #Example
      CompilerCase 1 ; Line Trend (#BezierCurve)
        Trend::Gadget(#Trend, 10, 10, 295, 180, Trend::#Border|Trend::#ShowLines|Trend::#ToolTips|Trend::#ChangeCursor|Trend::#AutoResize, #Window)
        Trend::SetFlags(#Trend, Trend::#Gadget, Trend::#Colored|Trend::#BezierCurve)
        Trend::SetAttribute(#Trend, Trend::#Maximum,  80)
        Trend::SetAttribute(#Trend, Trend::#FontSize, 10)
        Trend::SetFlags(#Trend, Trend::#Gadget, Trend::#NoAutoAdjust|Trend::#OutOfRange)
        Trend::ToolTipText(#Trend, Trend::#Label$ + " Uhr: " + Trend::#Value$)
      CompilerDefault

    CompilerEndSelect    
    
    Trend::SetAutoResizeFlags(#Trend, Trend::#ResizeWidth)
    
    ;Trend::LoadValues(#Trend, "TrendValues.json")
    
    Trend::AddItem(#Trend, Trend::Time(8),  35, "", $FF901E)
    Trend::AddItem(#Trend, Trend::Time(9),  50, "", $0000FF)
    Trend::AddItem(#Trend, Trend::Time(10), 10, "", $32CD32)
    Trend::AddItem(#Trend, Trend::Time(11), 80, "", $00D7FF)
    Trend::AddItem(#Trend, Trend::Time(12), 40, "", $8B008B)
    Trend::AddItem(#Trend, Trend::Time(13), 60, "", $228B22)
    
    Trend::DisplayValues(#Trend, Trend::Time(8), Trend::Time(13))
    
    StringGadget(#Label, 10, 200, 80, 20, "(Click Data)", #PB_String_ReadOnly)
    StringGadget(#Value, 95, 200, 30, 20, "")
    ButtonGadget(#Button, 130, 200, 40, 20, "Apply")

    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case Trend::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #Trend
              Select EventType()
                Case #PB_EventType_LeftClick       ;{ Left mouse click
                  SetGadgetText(#Label, Trend::EventLabel(#Trend))
                  SetGadgetText(#Value, Str(Trend::EventValue(#Trend)))
                  SetGadgetColor(#Value, #PB_Gadget_FrontColor, Trend::EventColor(#Trend))
                  ;}
                Case #PB_EventType_LeftDoubleClick ;{ LeftDoubleClick
                  
                  ;}
                Case #PB_EventType_RightClick      ;{ Right mouse click
                  
                  ;}
              EndSelect
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button
              Trend::SetLabelState(#Trend, GetGadgetText(#Label), Val(GetGadgetText(#Value)))
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    ;Trend::SaveValues(#Trend, "TrendValues.json")
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf  

; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 168
; FirstLine = 9
; Folding = EAAQBACwBBAA5FFi-forhg
; EnableXP
; DPIAware