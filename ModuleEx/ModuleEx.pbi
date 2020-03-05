;/ ========================
;/ =    MetaModule.pbi    =
;/ ========================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; - Manage tabulator shortcut (#Tabulator) and gadgets can use the tab key if they have the focus (#UseTabulator).
; - Creates cursor events for gadgets of a window (#CursorEvent)
; - Provides event types for PostEvent() for other modules

; Last Update: 03.03.2020
;
; Added: GUI theme for all supportet gadgets
;
; Added: Font management -> ModuleEx::Font()
; Added: Dynamic fonts for custom gadgets
; Added: RequiredFontSize() & CalcPadding()
; Added: SetFont() with '#FitText'-Flag

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


;{ _____ ModuleEx - Commands _____

; ModuleEx::AddGadget()                - add a gadget for tabulator handling  (#UseTabulator|#IgnoreTabulator)
; ModuleEx::AddWindow()                - enables the tabulator handling for this window  (#Tabulator|#CursorEvent)
; ModuleEx::CursorFrequency()          - changes the cursor frequency (default: 600ms)
; ModuleEx::ExitCursorThread()         - exit cursor thread
; ModuleEx::Font()                     - similar to 'LoadFont()' (supports dynamic fonts)
; ModuleEx::FreeFonts()                - free dynamic font data
; ModuleEx::GetGadgetWindow()          - returns the number of the window in which the gadget is located
; ModuleEx::LoadTheme()                - load a theme for all supportet gadgets
; ModuleEx::RequiredFontSize()         - calculates the required font size
; ModuleEx::SetAttribute()             - [#Padding/#PaddingX/#PaddingY]
; ModuleEx::SetFont()                  - similar to 'SetGadgetFont()' (supports dynamic fonts)
; ModuleEx::SaveTheme()                - save current theme
; ModuleEx::SetColor()                 - change the theme color of all supported gadgets
; ModuleEx::SetTheme()                 - set a theme for all supportet gadgets

;}

DeclareModule ModuleEx
  
  #Version = 20030400
  
  #Enable_Tabulator_Management = #True
  
  EnumerationBinary ;{ Flags
    #Tabulator
    #CursorEvent
    #UseTabulator
    #IgnoreTabulator
    #FitText
  EndEnumeration ;}
  
  Enumeration 1     ;{ Attribute
    #Gadget
    #Drawing
    #VectorDrawing
    #Padding
    #PaddingX
    #PaddingY
  EndEnumeration ;}

  Enumeration #PB_Event_FirstCustomValue     ;{ #Event
    #Event_Gadget
    #Event_Cursor
    #Event_Theme
    #Event_Timer
    #Event_ToolTip
  EndEnumeration ;}
  
  Enumeration #PB_EventType_FirstCustomValue ;{ #EventType
    #EventType_Button
    #EventType_Change
    #EventType_CheckBox
    #EventType_Collapsed
    #EventType_ComboBox
    #EventType_Date
    #EventType_Day
    #EventType_DropDown
    #EventType_Expanded
    #EventType_Focus
    #EventType_Header
    #EventType_HyperLink
    #EventType_ImageButton
    #EventType_Link
    #EventType_LostFocus
    #EventType_Month
    #EventType_NewLine
    #EventType_RightClick
    #EventType_Row
    #EventType_Select
    #EventType_SpinBox
    #EventType_String
    #EventType_ScrollBar
    #EventType_TextButton
    #EventType_TrackBar
    #EventType_Year
  EndEnumeration ;}
  
  #Event_Tabulator      = 64000
  #Event_ShiftTabulator = 63999
  
  ; _____ Theme-Support _____
  
  Enumeration
    #Theme_Default
    #Theme_Blue  
    #Theme_Green
    #Theme_Dark
    #Theme_DarkBlue
  EndEnumeration
  
  Enumeration 1     ;{ Theme - Color
    #Color_Front
    #Color_Back
    #Color_Line
    #Color_Border
    #Color_Row
    #Color_Gadget
    #Color_FocusFront
    #Color_FocusBack
    #Color_HeaderFront
    #Color_HeaderBack
    #Color_HeaderLight
    #Color_ButtonFront
    #Color_ButtonBack
    #Color_ButtonBorder
    #Color_TitleFront
    #Color_TitleBack
    #Color_ProgressFront
    #Color_ProgressBack
    #Color_ProgressGradient
  EndEnumeration ;}
  
  Structure Theme_Font_Structure
    Num.i
    Name.s
    Size.i
    Style.i
  EndStructure  
  
  Structure Theme_Disable_Structure  ;{ ThemeGUI\...
    FrontColor.i
    BackColor.i
    BorderColor.i
  EndStructure ;}
  
  Structure Theme_Progress_Structure ;{ ThemeGUI\Progress\...
    TextColor.i
    FrontColor.i
    BackColor.i
    GradientColor.i
    BorderColor.i
  EndStructure ;}
  
  Structure Theme_Header_Structure   ;{ ThemeGUI\Header\...
    FrontColor.i
    BackColor.i
    BorderColor.i
    LightColor.i
  EndStructure ;}
  
  Structure Theme_Border_Structure   ;{ ThemeGUI\...
    FrontColor.i
    BackColor.i
    BorderColor.i
  EndStructure ;}
  
  Structure Theme_Button_Structure   ;{ ThemeGUI\...
    FrontColor.i
    BackColor.i
    BorderColor.i
    SwitchColor.i
  EndStructure ;}
  
  Structure Theme_Color_Structure    ;{ ThemeGUI\...
    FrontColor.i
    BackColor.i
  EndStructure ;}
  
  Structure Theme_Structure          ;{ ThemeGUI\...
    FrontColor.i
    BackColor.i
    BorderColor.i
    RowColor.i
    LineColor.i
    GreyTextColor.i
    Button.Theme_Button_Structure
    Disable.Theme_Disable_Structure
    Focus.Theme_Color_Structure
    Header.Theme_Header_Structure
    Progress.Theme_Progress_Structure
    Title.Theme_Border_Structure
    ScrollbarColor.i
    GadgetColor.i
    WindowColor.i
    Font.Theme_Font_Structure
    ScrollBar.i ; Flags
  EndStructure ;}
  Global ThemeGUI.Theme_Structure
  
  ; _____ Fit Font _____
  
  Structure Padding_Structure        ;{ Padding\...
    X.i
    Y.i
    Factor.f
  EndStructure ;}
  Padding.Padding_Structure

  ;- ============================================================================
  ;-   DeclareModule
  ;- ============================================================================
  
  Declare.i AddGadget(GNum.i, WindowNum.i=#PB_Default, Flags.i=#False)
  Declare.i AddWindow(WindowNum.i, Flags.i=#False)
  Declare   CalcPadding(Text.s, Height.i, FontNum.i, FontSize.i, *Padding.Padding_Structure)
  Declare   CursorFrequency(Frequency.i)
  Declare   ExitCursorThread()
  Declare   Font(Name.s, Size.i, Style.i=#False)
  Declare   FreeFonts()
  Declare.i GetGadgetWindow()
  Declare.i LoadTheme(File.s="ThemeGUI.xml")
  Declare.i RequiredFontSize(Text.s, Width.i, Height.i, FontNum.i)
  Declare.i SaveTheme(File.s="ThemeGUI.xml")
  Declare   SetAttribute(GNum.i, Type.i, Value.i)
  Declare.i SetFont(GNum.i, Name.s, Size.i, Style.i=#False, Flags.i=#False, Type.i=#Gadget) 
  Declare   SetTheme(Theme.i=#PB_Default)
  
  Macro LoadFont(Font, Name, Height, Style = 0)
    Font(Font, Name, Height, Style = 0)
  EndMacro
  
  Macro PB(Function)
    Function
  EndMacro
  
EndDeclareModule

Module ModuleEx

  EnableExplicit  
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================    
  
  #CursorFrequency = 600
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================    
  
  Structure ModuleEx_Thread_Structure        ;{ ModuleEx\Thread\...
    Num.i
    Active.i
    Frequency.i
    Exit.i
  EndStructure ;}
  
  Structure ModuleEx_Font_Structure          ;{ ModuleEx\Font('Name|Style')\
    Style.i
    Map Size.i()  ; ('Size')
  EndStructure ;}
  
  Structure ModuleEx_Gadget_Structure        ;{ ModuleEx\Gadget()\...
    Window.i
    FontNum.i
    FontName.s
    FontSize.i
    FontStyle.i
    PaddingX.i
    PaddingY.i
    Idx.i
    Flags.i
  EndStructure ;}
  
  Structure ModuleEx_Window_Gadget_Structure ;{ ModuleEx\Window()\...
    Map  Font.i()   ; ('Name|Size|Style')
    List Gadget.i()
  EndStructure ;}
  
  Structure ModuleEx_Active_Structure        ;{ ModuleEx\Active\...
    Window.i
    Gadget.i
  EndStructure ;}
  
  Structure ModuleEx_Structure               ;{ ModuleEx\...
    
    Menu.i

    Active.ModuleEx_Active_Structure
    Thread.ModuleEx_Thread_Structure
    
    Map Window.ModuleEx_Window_Gadget_Structure()
    Map Gadget.ModuleEx_Gadget_Structure()
    
    Map Font.ModuleEx_Font_Structure()
    Map ID.s()
    ;Map Num.s()
    
  EndStructure ;}
  Global ModuleEx.ModuleEx_Structure
  
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
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; Thanks to mk-soft
    Import ""
      PB_Object_EnumerateStart(PB_Objects)
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      ;PB_Object_GetObject( PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      ;PB_Gadget_Objects.i
      ;PB_Image_Objects.i
    EndImport
  CompilerElse
    ImportC ""
      PB_Object_EnumerateStart( PB_Objects )
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      ;PB_Object_GetObject( PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      ;PB_Gadget_Objects.i
      ;PB_Image_Objects.i
    EndImport
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
	
  ; _____ Fit Text/Font _____
  
  Procedure.d Pixel_(Points.i)
	  ; Pixel = Points * 96 / 72
	  ProcedureReturn Points * 96 / 72
	EndProcedure
	
	Procedure.i Point_(Pixel.f)
	  ; Points = Pixel * 72 / 96
	  ProcedureReturn Round(Pixel * 72 / 96, #PB_Round_Nearest)
	EndProcedure
	

	Procedure.i CalcFitFontSize_(Text.s, Width.i, Height.i, FontNum.i)
	  Define.i FontSize, ImgNum, r, Rows 
	  Define.i txtWidth, txtHeight, maxWidth, hSize, vSize, DiffW
	  Define.f FactorW, FactorH
    Define.s maxText
    
    If Width <= 0 Or Height <= 0 : ProcedureReturn 1 : EndIf
    
    Width  = dpiX(Width)
    Height = dpiY(Height) 
    
    If Text = ""     : ProcedureReturn #False : EndIf
    
    If IsFont(FontNum) = #False : ProcedureReturn #False : EndIf 
    
    If FindString(Text, #CR$)
      Text = ReplaceString(Text, #CRLF$, #LF$)
      Text = ReplaceString(Text, #LFCR$, #LF$)
      ReplaceString(Text, #CR$, #LF$, #PB_String_InPlace)
    EndIf
    
    Rows = CountString(Text, #LF$) + 1
    
    ;{ Calculate start font size
    vSize = Point_(Height / Rows)
    hSize = Point_(Width / Len(Text)) 
    FontSize = (vSize + hSize) / 2
    If FontSize < 3 : FontSize = 3 : EndIf
    ;}
    
    ImgNum = CreateImage(#PB_Any, 16, 16)
    If ImgNum

      If StartVectorDrawing(ImageVectorOutput(ImgNum))
        
        VectorFont(FontID(FontNum), Pixel_(FontSize))
        
        If Rows > 1       ;{ multiple rows
          For r=1 To Rows ;{ max. text width
            txtWidth = VectorTextWidth(StringField(Text, r, #LF$), #PB_VectorText_Visible)
            If txtWidth > maxWidth
              maxWidth = txtWidth
              maxText  = StringField(Text, r, #LF$)
            EndIf
            ;} 
          Next
          Text = "0" + maxText + "0"          
          txtWidth  = dpiX(VectorTextWidth(Text,  #PB_VectorText_Visible))
          txtHeight = dpiY(VectorTextHeight(Text, #PB_VectorText_Default)) * Rows
          ;}
        Else              ;{ single row
          txtWidth  = dpiX(VectorTextWidth(Text,  #PB_VectorText_Visible))
          txtHeight = dpiY(VectorTextHeight(Text, #PB_VectorText_Default))
          ;}
        EndIf 
        
        If txtWidth < Width And txtHeight < Height ; enlarge text
          
          Repeat
            
            FontSize + 2
            
            VectorFont(FontID(FontNum), Pixel_(FontSize))
            txtWidth  = dpiX(VectorTextWidth(Text, #PB_VectorText_Visible))
            txtHeight = dpiY(VectorTextHeight(Text, #PB_VectorText_Default)) * Rows
            
            If txtWidth > Width Or txtHeight > Height
              FontSize - 1
              VectorFont(FontID(FontNum), Pixel_(FontSize))
              txtWidth  = dpiX(VectorTextWidth(Text, #PB_VectorText_Visible))
              txtHeight = dpiY(VectorTextHeight(Text, #PB_VectorText_Default)) * Rows
            EndIf

          Until txtWidth > Width Or txtHeight > Height
          
          FontSize - 1
         
        Else                                      ; reduce text
         
          While txtWidth > Width Or txtHeight > Height

            FontSize - 2
            
            If FontSize <= 1 : FontSize = 1 : Break : EndIf
            
            VectorFont(FontID(FontNum), Pixel_(FontSize))
            txtWidth  = dpiX(VectorTextWidth(Text,  #PB_VectorText_Visible))
            txtHeight = dpiY(VectorTextHeight(Text, #PB_VectorText_Default)) * Rows
            
            If txtWidth < Width And txtHeight < Height
              FontSize + 1
              VectorFont(FontID(FontNum), Pixel_(FontSize))
              txtWidth  = dpiX(VectorTextWidth(Text,  #PB_VectorText_Visible))
              txtHeight = dpiY(VectorTextHeight(Text, #PB_VectorText_Default)) * Rows
            EndIf   
            
          Wend
         
        EndIf
       
        StopVectorDrawing()
      EndIf
      
      FreeImage(ImgNum)
    EndIf
    
    ProcedureReturn FontSize
  EndProcedure	
  
  ; _____ Font Management _____
  
  Procedure.i LoadFont_(Name.s, Size.i, Style.i, Font.i=#PB_Any) 
	  Define.i FontNum
	  Define.s Key = Name + "|" + Str(Style)
	  
	  FontNum = ModuleEx\Font(Key)\Size(Str(Size))
	  If IsFont(Font)
      ProcedureReturn Font
    Else  
      FontNum = PB(LoadFont)(Font, Name, Size, Style)
        If Font = #PB_Any : Font = FontNum : EndIf
      If IsFont(Font)
        ModuleEx\Font(Key)\Size(Str(Size)) = Font
        ModuleEx\ID(Str(FontID(Font))) = Key
        ProcedureReturn Font
      EndIf 
    EndIf 
	  
	  ProcedureReturn #False
	EndProcedure
	
	; _____ GUI Theme _____
	
	Procedure SaveTheme_(File.s)
	  Define.i XML, FontNum
	  
	  FontNum = ThemeGUI\Font\Num
	  
	  ThemeGUI\Font\Num = #False
	  
	  XML = CreateXML(#PB_Any)
    If XML
      InsertXMLStructure(RootXMLNode(XML), @ThemeGUI, Theme_Structure)
      FormatXML(XML, #PB_XML_ReFormat)
      SaveXML(XML, File)
      FreeXML(XML)
    EndIf
    
    ThemeGUI\Font\Num = FontNum
	  
	EndProcedure
	
  ;- __________ Events __________
  
  Procedure _CursorThread(ElapsedTime.i)

    Repeat
      
      If ElapsedTime >= ModuleEx\Thread\Frequency
        PostEvent(#Event_Cursor)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until ModuleEx\Thread\Exit
    
  EndProcedure
  
  CompilerIf #Enable_Tabulator_Management
    
    Procedure _TabulatorHandler()
      Define.i Window.i, Gadget, NextGadget
      
      Window = GetActiveWindow()
      If IsWindow(Window)
        
        If FindMapElement(ModuleEx\Window(), Str(Window))
          If NextElement(ModuleEx\Window()\Gadget())
            If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
          Else
            FirstElement(ModuleEx\Window()\Gadget())
            If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure _ShiftTabulatorHandler()
      Define.i Window.i, Gadget, NextGadget
      
      Window = GetActiveWindow()
      If IsWindow(Window)
        
        If FindMapElement(ModuleEx\Window(), Str(Window))
          If PreviousElement(ModuleEx\Window()\Gadget())
            If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
          Else
            LastElement(ModuleEx\Window()\Gadget())
            If IsGadget(ModuleEx\Window()\Gadget()) : SetActiveGadget(ModuleEx\Window()\Gadget()) : EndIf
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
  
    Procedure _FocusHandler()
      Define.i GNum = EventGadget()
      
      If FindMapElement(ModuleEx\Gadget(), Str(GNum))
  
        If ModuleEx\Gadget()\Flags & #UseTabulator
          
          If IsMenu(ModuleEx\Menu)
            UnbindMenuEvent(ModuleEx\Menu, #Event_Tabulator,       @_TabulatorHandler())
            UnbindMenuEvent(ModuleEx\Menu, #Event_ShiftTabulator,  @_ShiftTabulatorHandler())
          EndIf 
          
          If IsWindow(ModuleEx\Gadget()\Window)
            RemoveKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Tab)
            RemoveKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Shift|#PB_Shortcut_Tab)
          EndIf
          
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure _LostFocusHandler()
      Define.i GNum = EventGadget()
      
      If FindMapElement(ModuleEx\Gadget(), Str(GNum))
        
        If ModuleEx\Gadget()\Flags & #UseTabulator
          
          If IsWindow(ModuleEx\Gadget()\Window)
            AddKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Tab, #Event_Tabulator)
            AddKeyboardShortcut(ModuleEx\Gadget()\Window, #PB_Shortcut_Shift|#PB_Shortcut_Tab, #Event_ShiftTabulator)
          EndIf
          
          If IsMenu(ModuleEx\Menu)
            BindMenuEvent(ModuleEx\Menu, #Event_Tabulator,      @_TabulatorHandler())
            BindMenuEvent(ModuleEx\Menu, #Event_ShiftTabulator, @_ShiftTabulatorHandler())
          EndIf
          
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf  
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    If FindMapElement(ModuleEx\Window(), Str(Window))
      
      ;{ ___ Exit Thread ___
      If ModuleEx\Thread\Active
        If MapSize(ModuleEx\Window()) = 1
          ModuleEx\Thread\Exit   = #True
          ModuleEx\Thread\Active = #False
        EndIf
      EndIf ;}
      
      ;{ ___ Remove gadgets ___
      ForEach ModuleEx\Gadget()
        If ModuleEx\Gadget()\Window = Window
          DeleteMapElement(ModuleEx\Gadget())
        EndIf
      Next ;}
      
      ;{ ___ Free Fonts ___
      ForEach ModuleEx\Window()\Font()
        FreeFont(ModuleEx\Window()\Font())
      Next
      
      ForEach ModuleEx\Font()
        ForEach ModuleEx\Font()\Size()
          If IsFont(ModuleEx\Font()\Size()) = #False
            DeleteMapElement(ModuleEx\Font()\Size())
          EndIf  
        Next
        If MapSize(ModuleEx\Font()\Size()) = 0
          DeleteMapElement(ModuleEx\Font())
        EndIf
      Next ;}
      
      DeleteMapElement(ModuleEx\Window())
      
      ;{ ___ Kill Thread ___
      If ModuleEx\Thread\Exit
        Delay(100)
        If IsThread(ModuleEx\Thread\Num)
          KillThread(ModuleEx\Thread\Num)
        EndIf
      EndIf ;}
      
    EndIf 
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================      

  Procedure.i GetGadgetWindow() ; Thanks to mk-soft
    Define.i WindowID, Window, Result = #PB_Default
    
    WindowID = UseGadgetList(0)
    
    PB_Object_EnumerateStart(PB_Window_Objects)
    
    While PB_Object_EnumerateNext(PB_Window_Objects, @Window)
      If WindowID = WindowID(Window)
        result = Window
        Break
      EndIf
    Wend
    
    PB_Object_EnumerateAbort(PB_Window_Objects)
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddGadget(GNum.i, WindowNum.i=#PB_Default, Flags.i=#False)
    ; Flags: #UseTabulator    - Gadget uses the tab key when it has the focus.
    ; Flags: #IgnoreTabulator - Gadget is ignored when tab key is used to jump to the next gadget
    
    If AddMapElement(ModuleEx\Gadget(), Str(GNum))
      
      ModuleEx\Gadget()\PaddingX = 8
      ModuleEx\Gadget()\PaddingY = 8
      
      If WindowNum = #PB_Default : WindowNum = GetGadgetWindow() : EndIf
    
      If FindMapElement(ModuleEx\Window(), Str(WindowNum)) = #False
        AddWindow(WindowNum)
      EndIf  
     
      ModuleEx\Gadget()\Window = WindowNum
      ModuleEx\Gadget()\Flags  = Flags
      
      If AddElement(ModuleEx\Window(Str(WindowNum))\Gadget())
        ModuleEx\Window(Str(WindowNum))\Gadget() = GNum
      EndIf
      
      If Flags & #IgnoreTabulator
        ModuleEx\Gadget()\Idx = -1
      Else
        ModuleEx\Gadget()\Idx = ListIndex(ModuleEx\Window(Str(WindowNum))\Gadget())
      EndIf
      
      CompilerIf #Enable_Tabulator_Management
        If IsGadget(GNum)
          BindGadgetEvent(GNum, @_FocusHandler(),     #PB_EventType_Focus)
          BindGadgetEvent(GNum, @_LostFocusHandler(), #PB_EventType_LostFocus)
        EndIf
      CompilerEndIf
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i AddWindow(WindowNum.i, Flags.i=#False)
    ; Flags: #Tabulator   - tabulator shortcut for this window
    ; Flags: #CursorEvent - create cursor event for gadgets in this window
    
    If IsWindow(WindowNum)
      
      If FindMapElement(ModuleEx\Window(), Str(WindowNum))
        
        If Flags & #CursorEvent ;{ Create cursor event for gadgets in this window
          
          If ModuleEx\Thread\Frequency = 0 : ModuleEx\Thread\Frequency = #CursorFrequency : EndIf
          
          If ModuleEx\Thread\Active = #False
            ModuleEx\Thread\Active = #True
            ModuleEx\Thread\Exit   = #False
            ModuleEx\Thread\Num    = CreateThread(@_CursorThread(), ModuleEx\Thread\Frequency)
          EndIf
          ;}  
        EndIf
        
        CompilerIf #Enable_Tabulator_Management

          If Flags & #Tabulator   ;{ Manage tabulator shortcut for this window
            
            ModuleEx\Menu = CreateMenu(#PB_Any, WindowID(WindowNum))
            If IsMenu(ModuleEx\Menu)
              
              RemoveKeyboardShortcut(WindowNum, #PB_Shortcut_Tab)
              RemoveKeyboardShortcut(WindowNum, #PB_Shortcut_Shift|#PB_Shortcut_Tab)
              
              AddKeyboardShortcut(WindowNum, #PB_Shortcut_Tab, #Event_Tabulator)
              AddKeyboardShortcut(WindowNum, #PB_Shortcut_Shift|#PB_Shortcut_Tab, #Event_ShiftTabulator)
              
              BindMenuEvent(ModuleEx\Menu, #Event_Tabulator,       @_TabulatorHandler())
              BindMenuEvent(ModuleEx\Menu, #Event_ShiftTabulator,  @_ShiftTabulatorHandler())
      
            EndIf
            ;}
          EndIf
          
        CompilerEndIf
        
        ProcedureReturn #True
        
      ElseIf AddMapElement(ModuleEx\Window(), Str(WindowNum))
        
        If Flags & #CursorEvent ;{ Create cursor event for gadgets in this window
          
          If ModuleEx\Thread\Frequency = 0 : ModuleEx\Thread\Frequency = #CursorFrequency : EndIf
          
          If ModuleEx\Thread\Active = #False
            ModuleEx\Thread\Active = #True
            ModuleEx\Thread\Exit   = #False
            ModuleEx\Thread\Num    = CreateThread(@_CursorThread(), ModuleEx\Thread\Frequency)
          EndIf
          ;}  
        EndIf
        
        CompilerIf #Enable_Tabulator_Management
          
          If Flags & #Tabulator   ;{ Manage tabulator shortcut for this window
            
            ModuleEx\Menu = CreateMenu(#PB_Any, WindowID(WindowNum))
            If IsMenu(ModuleEx\Menu)
              
              RemoveKeyboardShortcut(WindowNum, #PB_Shortcut_Tab)
              RemoveKeyboardShortcut(WindowNum, #PB_Shortcut_Shift|#PB_Shortcut_Tab)
              
              AddKeyboardShortcut(WindowNum, #PB_Shortcut_Tab, #Event_Tabulator)
              AddKeyboardShortcut(WindowNum, #PB_Shortcut_Shift|#PB_Shortcut_Tab, #Event_ShiftTabulator)
              
              BindMenuEvent(ModuleEx\Menu, #Event_Tabulator,       @_TabulatorHandler())
              BindMenuEvent(ModuleEx\Menu, #Event_ShiftTabulator,  @_ShiftTabulatorHandler())
      
            EndIf
            ;}
          EndIf
          
        CompilerEndIf
      
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), WindowNum)
        
        ProcedureReturn #True
      EndIf

    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  ; _____ Cursor Thread _____
  
  Procedure   CursorFrequency(Frequency.i)
    
    If Frequency < 100 : Frequency = 100 : EndIf 
    
    ModuleEx\Thread\Frequency = Frequency
    
  EndProcedure
  
  Procedure   ExitCursorThread() 
    
    ModuleEx\Thread\Exit   = #True
    ModuleEx\Thread\Active = #False
    
    If ModuleEx\Thread\Exit
      Delay(100)
      If IsThread(ModuleEx\Thread\Num) 
        KillThread(ModuleEx\Thread\Num)
      EndIf
    EndIf
    
  EndProcedure
  
  ; _____ Font Management _____
  
  Procedure.i Font(Name.s, Size.i, Style.i=#False)
    Define.i Font, WindowNum
    
    Font = LoadFont_(Name, Size, Style)
    
    WindowNum = GetGadgetWindow()
    If FindMapElement(ModuleEx\Window(), Str(WindowNum))
      ModuleEx\Window()\Font(Name+"|"+Str(Style)+"|"+Str(Size)) = Font
    Else
      If AddWindow(WindowNum)
        ModuleEx\Window()\Font(Name+"|"+Str(Style)+"|"+Str(Size)) = Font
      EndIf  
    EndIf
    
    ProcedureReturn Font
  EndProcedure
  
  Procedure   FreeFonts()
    
    ForEach ModuleEx\Font()
      ForEach ModuleEx\Font()\Size()
        FreeFont(ModuleEx\Font()\Size())
      Next
    Next
    
    ClearMap(ModuleEx\Font())
    
  EndProcedure
  
  ; _____ Fit Text/Font _____
  
  Procedure   CalcPadding(Text.s, Height.i, FontNum.i, FontSize.i, *Padding.Padding_Structure)
    Define.i ImgNum

    If Text = ""           : ProcedureReturn #False : EndIf
    If FontSize <= 0       : ProcedureReturn #False : EndIf 
    If Not IsFont(FontNum) : ProcedureReturn #False : EndIf 
    
    If FindString(Text, #CR$)
      Text = ReplaceString(Text, #CRLF$, #LF$)
      Text = ReplaceString(Text, #LFCR$, #LF$)
      ReplaceString(Text, #CR$, #LF$, #PB_String_InPlace)
    EndIf

    ImgNum = CreateImage(#PB_Any, 16, 16)
    If ImgNum
     
      If StartVectorDrawing(ImageVectorOutput(ImgNum))
        
        VectorFont(FontID(FontNum), Pixel_(FontSize))
        *Padding\X = 8
        If MapSize(ModuleEx\Gadget()) :*Padding\X = ModuleEx\Gadget()\PaddingX : EndIf 
        If *Padding\X < 0 : *Padding\X = 0 : EndIf 
        *Padding\Y = Height - VectorTextHeight(Text, #PB_VectorText_Default)
        If *Padding\Y < 0 : *Padding\Y = 0 : EndIf 
        *Padding\Factor = *Padding\Y / Height
        
        StopVectorDrawing()
      EndIf
      
      FreeImage(ImgNum)
    EndIf
    
  EndProcedure
  
  Procedure.i RequiredFontSize(Text.s, Width.i, Height.i, FontNum.i)
    
    If IsFont(FontNum)
      ProcedureReturn CalcFitFontSize_(Text, Width, Height, FontNum)
    EndIf 
    
  EndProcedure
  
  Procedure.i SetFont(GNum.i, Name.s, Size.i, Style.i=#False, Flags.i=#False, Type.i=#Gadget) 
    Define.i FontNum, FontSize
    
    FontNum = LoadFont_(Name, Size, Style)
    
    Select Type
      Case #Gadget  

        If IsGadget(GNum) ;{ PB Gadget
          
          If FindMapElement(ModuleEx\Gadget(), Str(GNum)) = #False : AddGadget(GNum) : EndIf
          
          If Flags & #FitText
            Size    = RequiredFontSize(GetGadgetText(GNum), GadgetWidth(GNum) - ModuleEx\Gadget(Str(GNum))\PaddingX, GadgetHeight(GNum) - ModuleEx\Gadget(Str(GNum))\PaddingY, FontNum)
            FontNum = Font(Name, Size, Style)
          EndIf
          
          ModuleEx\Gadget(Str(GNum))\FontNum   = FontNum
          ModuleEx\Gadget(Str(GNum))\FontName  = Name
          ModuleEx\Gadget(Str(GNum))\FontSize  = Size
          ModuleEx\Gadget(Str(GNum))\FontStyle = Style
          
          SetGadgetFont(GNum, FontID(FontNum))
          ;}
        EndIf
      
      Case #Drawing
        
        DrawingFont(FontID(FontNum)) 

      Case #VectorDrawing
        
        VectorFont(FontID(FontNum))

    EndSelect
    
    ProcedureReturn FontNum
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Type.i, Value.i)
    
    If FindMapElement(ModuleEx\Gadget(), Str(GNum)) = #False : AddGadget(GNum) : EndIf
    
    Select Type
      Case #Padding  
        ModuleEx\Gadget(Str(GNum))\PaddingX = Value
        ModuleEx\Gadget(Str(GNum))\PaddingY = Value
      Case #PaddingX
        ModuleEx\Gadget(Str(GNum))\PaddingX = Value
      Case #PaddingY
        ModuleEx\Gadget(Str(GNum))\PaddingY = Value
    EndSelect
    
  EndProcedure  
  
  ; _____ GUI Theme _____
  
  Procedure   SetScrollBar(Flags.i)
    
    ThemeGUI\ScrollBar = Flags
    
    PostEvent(#Event_Theme)
    
  EndProcedure
  
  Procedure   SetTheme(Theme.i=#PB_Default)
    ; On request and with the sponsorship of Cyllceaux
    
    ThemeGUI\Font\Num    = #PB_Default
    ThemeGUI\WindowColor = #PB_Default
    
    CompilerSelect  #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ThemeGUI\GadgetColor    = GetSysColor_(#COLOR_MENU)
        ThemeGUI\ScrollbarColor = GetSysColor_(#COLOR_MENU)
      CompilerCase #PB_OS_MacOS
        ThemeGUI\GadgetColor    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
        ThemeGUI\ScrollbarColor = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
      CompilerCase #PB_OS_Linux
        ThemeGUI\GadgetColor    = $EDEDED
        ThemeGUI\ScrollbarColor = $C8C8C8
    CompilerEndSelect
    
    Select Theme
      Case #Theme_Blue     ;{ Blue Theme
        ;  $3A2100 $43321C $764200 $B06400 $CB9755 $E5CBAA $EDDCC6 $F6EDE2 $FCF9F5
        ThemeGUI\FrontColor             = $490000
        ThemeGUI\BackColor              = $FEFDFB
        ThemeGUI\BorderColor            = $8C8C8C
        ThemeGUI\LineColor              = $C5C5C5
        ThemeGUI\GreyTextColor          = $6D6D6D
        ThemeGUI\RowColor               = $FAF5EE
        ThemeGUI\Focus\FrontColor       = $FCF9F5
        ThemeGUI\Focus\BackColor        = $B06400
        ThemeGUI\Header\FrontColor      = $43321C
        ThemeGUI\Header\BackColor       = $E5CBAA
        ThemeGUI\Header\BorderColor     = $A0A0A0
        ThemeGUI\Header\LightColor      = $F6EDE2
        ThemeGUI\Button\FrontColor      = $490000
        ThemeGUI\Button\BackColor       = $E3E3E3
        ThemeGUI\Button\BorderColor     = $B48246
        ThemeGUI\Button\SwitchColor     = $C8C8C8
        ThemeGUI\Title\FrontColor       = $FCF9F5
        ThemeGUI\Title\BackColor        = $764200
        ThemeGUI\Title\BorderColor      = $3A2100
        ThemeGUI\Progress\TextColor     = $FCF9F5
        ThemeGUI\Progress\FrontColor    = $CB9755
        ThemeGUI\Progress\BackColor     = #PB_Default 
        ThemeGUI\Progress\GradientColor = $B06400
        ThemeGUI\Progress\BorderColor   = $764200
        ThemeGUI\Disable\FrontColor     = $72727D
        ThemeGUI\Disable\BackColor      = $CCCCCA
        ThemeGUI\Disable\BorderColor    = $72727D
        ;}

      Case #Theme_Green    ;{ Green Theme
        ; $2A3A1F $142D05 $295B0A $3E8910 $7EB05F $BED7AF $D4E4C9 $E2EDDB $F5F9F3
        ThemeGUI\FrontColor             = $0F2203
        ThemeGUI\BackColor              = $FCFDFC
        ThemeGUI\BorderColor            = $9B9B9B
        ThemeGUI\LineColor              = $CCCCCC
        ThemeGUI\GreyTextColor          = $6D6D6D
        ThemeGUI\RowColor               = $F3F7F0
        ThemeGUI\Focus\FrontColor       = $3E8910 
        ThemeGUI\Focus\BackColor        = $F5F9F3
        ThemeGUI\Header\FrontColor      = $142D05
        ThemeGUI\Header\BackColor       = $BED7AF
        ThemeGUI\Header\BorderColor     = $A0A0A0
        ThemeGUI\Header\LightColor      = $E2EDDB
        ThemeGUI\Button\FrontColor      = $0F2203
        ThemeGUI\Button\BackColor       = $E3E3E3
        ThemeGUI\Button\BorderColor     = $A0A0A0
        ThemeGUI\Button\SwitchColor     = $C8C8C8
        ThemeGUI\Title\FrontColor       = $F5F9F3
        ThemeGUI\Title\BackColor        = $295B0A
        ThemeGUI\Title\BorderColor      = $142D05
        ThemeGUI\Progress\TextColor     = $F5F9F3
        ThemeGUI\Progress\FrontColor    = $BED7AF
        ThemeGUI\Progress\BackColor     = #PB_Default
        ThemeGUI\Progress\GradientColor = $7EB05F
        ThemeGUI\Progress\BorderColor   = $295B0A
        ThemeGUI\Disable\FrontColor     = $72727D
        ThemeGUI\Disable\BackColor      = $CCCCCA
        ThemeGUI\Disable\BorderColor    = $72727D
        ;}
        
      Case #Theme_DarkBlue ;{ Dark Blue Theme
        ;  $3A2100 $43321C $764200 $B06400 $CB9755 $E5CBAA $EDDCC6 $F6EDE2 $FCF9F5
        ThemeGUI\FrontColor             = $FCF9F5
        ThemeGUI\BackColor              = $764200
        ThemeGUI\BorderColor            = $8C8C8C
        ThemeGUI\LineColor              = $E5CBAA
        ThemeGUI\GreyTextColor          = $6D6D6D
        ThemeGUI\RowColor               = $814700
        ThemeGUI\Focus\FrontColor       = $FFFFFF
        ThemeGUI\Focus\BackColor        = $4AFFB7
        ThemeGUI\Header\FrontColor      = $EDDCC6
        ThemeGUI\Header\BackColor       = $B06400
        ThemeGUI\Header\BorderColor     = $CB9755
        ThemeGUI\Header\LightColor      = $C2863B
        ThemeGUI\Button\FrontColor      = $43321C
        ThemeGUI\Button\BackColor       = $F6EDE2
        ThemeGUI\Button\BorderColor     = $A87433
        ThemeGUI\Button\SwitchColor     = $C8C8C8
        ThemeGUI\Title\FrontColor       = $EDDCC6
        ThemeGUI\Title\BackColor        = $B06400
        ThemeGUI\Title\BorderColor      = $3A2100
        ThemeGUI\Progress\TextColor     = $EDDCC6
        ThemeGUI\Progress\FrontColor    = $CB9755
        ThemeGUI\Progress\BackColor     = #PB_Default 
        ThemeGUI\Progress\GradientColor = $B06400
        ThemeGUI\Progress\BorderColor   = $B88038
        ThemeGUI\Disable\FrontColor     = $72727D
        ThemeGUI\Disable\BackColor      = $CCCCCA
        ThemeGUI\Disable\BorderColor    = $72727D
        ;}  
        
      Case #Theme_Dark  ;{ Dark 
        ;  $3A2100 $43321C $764200 $B06400 $CB9755 $E5CBAA $EDDCC6 $F6EDE2 $FCF9F5
        ThemeGUI\FrontColor             = $FCF9F5
        ThemeGUI\BackColor              = $3A2100
        ThemeGUI\BorderColor            = $8C8C8C
        ThemeGUI\LineColor              = $764200
        ThemeGUI\GreyTextColor          = $6D6D6D
        ThemeGUI\RowColor               = $422500
        ThemeGUI\Focus\FrontColor       = $764200
        ThemeGUI\Focus\BackColor        = $FFFFFF
        ThemeGUI\Header\FrontColor      = $E5CBAA
        ThemeGUI\Header\BackColor       = $764200
        ThemeGUI\Header\BorderColor     = $CB9755
        ThemeGUI\Header\LightColor      = $F6EDE2
        ThemeGUI\Button\FrontColor      = $FCF9F5
        ThemeGUI\Button\BackColor       = $5E3400
        ThemeGUI\Button\BorderColor     = $B06400
        ThemeGUI\Button\SwitchColor     = $C8C8C8
        ThemeGUI\Title\FrontColor       = $FCF9F5
        ThemeGUI\Title\BackColor        = $764200
        ThemeGUI\Title\BorderColor      = $3A2100
        ThemeGUI\Progress\TextColor     = $F6EDE2
        ThemeGUI\Progress\FrontColor    =  $CB9755
        ThemeGUI\Progress\BackColor     = #PB_Default
        ThemeGUI\Progress\GradientColor = $B06400
        ThemeGUI\Progress\BorderColor   = $B06400
        ThemeGUI\WindowColor            = $342B1D
        ThemeGUI\GadgetColor            = $342B1D
        ThemeGUI\Disable\FrontColor     = $72727D
        ThemeGUI\Disable\BackColor      = $CCCCCA
        ThemeGUI\Disable\BorderColor    = $72727D
        ;}
        
      Default           ;{ Default Theme
        
        ThemeGUI\RowColor               = $FCFCFC
        ThemeGUI\GreyTextColor          = $6D6D6D
        
        ThemeGUI\Title\FrontColor       = $FFFFFF
        ThemeGUI\Title\BackColor        = $FCF9F5
        
        ThemeGUI\Header\LightColor      = $F6EDE2
        
        ThemeGUI\Disable\FrontColor     = $72727D
        ThemeGUI\Disable\BackColor      = $CCCCCA
        ThemeGUI\Disable\BorderColor    = $72727D
        
        ThemeGUI\Progress\TextColor     = $F9FEF8
        ThemeGUI\Progress\FrontColor    = $31EE07
        ThemeGUI\Progress\BackColor     = #PB_Default
        ThemeGUI\Progress\GradientColor = $25B006
        ThemeGUI\Progress\BorderColor   = $A0A0A0
        
        ThemeGUI\Button\SwitchColor     = $C8C8C8
        
        CompilerSelect  #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            ThemeGUI\FrontColor         = GetSysColor_(#COLOR_WINDOWTEXT)
            ThemeGUI\BackColor          = GetSysColor_(#COLOR_WINDOW)
            ThemeGUI\LineColor          = GetSysColor_(#COLOR_3DLIGHT)
            ThemeGUI\BorderColor        = GetSysColor_(#COLOR_WINDOWFRAME)
            ThemeGUI\Focus\FrontColor   = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
            ThemeGUI\Focus\BackColor    = GetSysColor_(#COLOR_HIGHLIGHT)
            ThemeGUI\Header\FrontColor  = GetSysColor_(#COLOR_WINDOWTEXT)
            ThemeGUI\Header\BackColor   = GetSysColor_(#COLOR_WINDOW)
            ThemeGUI\Button\FrontColor  = GetSysColor_(#COLOR_WINDOWTEXT)
            ThemeGUI\Button\BackColor   = GetSysColor_(#COLOR_3DLIGHT) 
            ThemeGUI\Button\BorderColor = GetSysColor_(#COLOR_3DSHADOW)
            ThemeGUI\Button\SwitchColor = GetSysColor_(#COLOR_SCROLLBAR)
            ThemeGUI\Title\BorderColor  = GetSysColor_(#COLOR_WINDOWFRAME)
            ThemeGUI\ScrollbarColor     = GetSysColor_(#COLOR_MENU)
          CompilerCase #PB_OS_MacOS
            ThemeGUI\FrontColor         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ThemeGUI\BackColor          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ThemeGUI\LineColor          = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ThemeGUI\BorderColor        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ThemeGUI\Focus\FrontColor   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
            ThemeGUI\Focus\BackColor    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
            ThemeGUI\Header\FrontColor  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ThemeGUI\Header\BackColor   = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ThemeGUI\Button\FrontColor  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor")) 
            ThemeGUI\Button\BackColor   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ThemeGUI\Button\BorderColor = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ThemeGUI\Button\SwitchColor = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ThemeGUI\Title\BorderColor  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux
            ThemeGUI\FrontColor          = $000000
            ThemeGUI\BackColor           = $FFFFFF
            ThemeGUI\LineColor           = $B4B4B4
            ThemeGUI\BorderColor         = $A0A0A0
            ThemeGUI\Focus\FrontColor    = $FFFFFF
            ThemeGUI\Focus\BackColor     = $D77800
            ThemeGUI\Header\FrontColor   = $000000
            ThemeGUI\Header\BackColor    = $FFFFFF
            ThemeGUI\Button\FrontColor   = $000000
            ThemeGUI\Button\BackColor    = $E3E3E3
            ThemeGUI\Button\BorderColor  = $A0A0A0
            ThemeGUI\Title\BorderColor   = $B4B4B4
            ThemeGUI\ScrollbarColor      = $C8C8C8
        CompilerEndSelect
        ;}
      ;SaveTheme_("Theme_Default.xml")
    EndSelect
    
    PostEvent(#Event_Theme)
    
  EndProcedure
  
  Procedure.i LoadTheme(File.s="ThemeGUI.xml")
    Define.i XML
    
    XML = LoadXML(#PB_Any, File)
    If XML
      ExtractXMLStructure(MainXMLNode(XML), @ThemeGUI, Theme_Structure)
      FreeXML(XML)
       PostEvent(#Event_Theme)
      ProcedureReturn #True
    EndIf
    
  EndProcedure
  
  Procedure.i SaveTheme(File.s="ThemeGUI.xml")
    
    ProcedureReturn SaveTheme_(File)
    
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Window  = 1
  
  Enumeration 1 
    #String
    #Button
    #Combo
  EndEnumeration
  
  LoadFont(0, "Arial", 12, 0)
  
  If OpenWindow(#Window, 0, 0, 310, 60, "Meta - Module", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    ButtonGadget(#Button,   10,  15,  80, 24, "Button", #PB_Button_Toggle) 
    StringGadget(#String,  110, 15,  80, 24, "") 
    ComboBoxGadget(#Combo, 210, 15, 90, 24)
    AddGadgetItem(#Combo, -1, "Test")
    SetGadgetState(#Combo, 0)
    
    If ModuleEx::AddWindow(#Window, ModuleEx::#Tabulator)
      ModuleEx::AddGadget(#Button, #Window)
      ModuleEx::AddGadget(#String, #Window) ; , ModuleEx::#IgnoreTabulator
      ModuleEx::AddGadget(#Combo,  #Window)
    EndIf
    
    Arial11B = FontID(ModuleEx::Font("Arial", 9, #PB_Font_Bold))
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button
              If GetGadgetState(#Button)
                ModuleEx::SetFont(#Button, "Arial", 9, #PB_Font_Bold, ModuleEx::#FitText) 
              Else
                SetGadgetFont(#Button, FontID(ModuleEx::Font("Arial", 9)))
              EndIf  
            Case #String
              
            Case #Combo
              
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 67
; FirstLine = 11
; Folding = kBABAAAACwBAA9
; EnableXP
; DPIAware