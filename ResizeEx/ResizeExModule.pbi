;/ ============================
;/ =   ResizeExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ [Resize] Automatic size adjustment for gadgets
;/ [Window] Save & restore window size, position and state
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; Last Update: 31.08.2019
;
; - Added:   Resize gadget text
; - Added:   _CloseWindowHandler()
; - Changed: Free() / Remove() / RemoveWindow() removed
; - Internal improvements
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


;{ _____ Window-Commands _____

  ; Window::Free()                - Delete all data
  ; Window::RestoreData()         - Restore position, size and state of the window
  ; Window::StoreData()           - Store position, size and state of the window
  ; Window::Save()                - Save data off all windows
  ; Window::Load()                - Load data off all windows

;}

DeclareModule Window
  
  ;- ===========================================================================
  ;-   DeclareModule (Window)
  ;- ===========================================================================
  
  EnumerationBinary 
    #IgnoreState
    #IgnorePosition
    #IgnoreSize
  EndEnumeration
  
  Declare Load(File.s="ResizeData.win")
  Declare RestoreSize(WindowNum.i, WindowState.i=#False)
  Declare Save(File.s="ResizeData.win")
  Declare StoreSize(WindowNum.i)

EndDeclareModule

Module Window
 
  EnableExplicit
  
  Structure Window_Structure    ;{ Win()\...
    X.i
    Y.i
    Width.i
    Height.i
    State.i
  EndStructure ;}
  Global NewMap Win.Window_Structure()
  
  
  Procedure _CloseWindowHandler()
    Define.i WindowNum = EventWindow(), Count
    
    If FindMapElement(Win(), Str(WindowNum))
      
      UnbindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(),  WindowNum)
      
      DeleteMapElement(Win())
      
    EndIf 
    
  EndProcedure

  ;- ==========================================================================
  ;-   Module - Declared Procedures (Window)
  ;- ========================================================================== 
  
  Procedure Load(File.s="ResizeData.win")
    Define.i JSON
    
    JSON = LoadJSON(#PB_Any, File)
    If JSON
      ExtractJSONMap(JSONValue(JSON), Win())
    EndIf
    
    ForEach Win()
      BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(),  Val(MapKey(Win())))
    Next
    
  EndProcedure  
  
  Procedure RestoreSize(WindowNum.i, Flags.i=#False)
    ; Flags: #IgnoreState / #IgnorePosition
    
    If IsWindow(WindowNum)
      
      If FindMapElement(Win(), Str(WindowNum))  
        
        If Win()\State = #PB_Window_Normal Or Flags & #IgnoreState
          If Flags & #IgnorePosition
            ResizeWindow(WindowNum, #PB_Ignore, #PB_Ignore, Win()\Width, Win()\Height)
          ElseIf Flags & #IgnoreSize
            ResizeWindow(WindowNum, Win()\X, Win()\Y, #PB_Ignore, #PB_Ignore)
          Else
            ResizeWindow(WindowNum, Win()\X, Win()\Y, Win()\Width, Win()\Height)
          EndIf
        Else
          SetWindowState(WindowNum, Win()\State)
        EndIf

      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure Save(File.s="ResizeData.win")
    Define.i JSON
    
    JSON = CreateJSON(#PB_Any)
    If JSON
      InsertJSONMap(JSONValue(JSON), Win())
      SaveJSON(JSON, File)
      FreeJSON(JSON)
    EndIf
    
  EndProcedure
  
  Procedure StoreSize(WindowNum.i)
    
    If IsWindow(WindowNum)
      
      If FindMapElement(Win(), Str(WindowNum)) = #False
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(),  WindowNum)
      EndIf 

      Win(Str(WindowNum))\X = WindowX(WindowNum)
      Win(Str(WindowNum))\Y = WindowY(WindowNum)
      Win(Str(WindowNum))\Width  = WindowWidth(WindowNum)
      Win(Str(WindowNum))\Height = WindowHeight(WindowNum)
      Win(Str(WindowNum))\State  = GetWindowState(WindowNum)
      
    EndIf
    
  EndProcedure
  
EndModule


;{ _____ Resize-Commands _____

  ; Resize::AddContainer()        - Add container for automatic size adjustment of the contained gadgets
  ; Resize::AddWindow()           - Add window for automatic resizing
  ; Resize::AddGadget()           - Add gadget for automatic resizing
  ; Resize::ChangeTextFont()
  ; Resize::Free()                - Delete all data
  ; Resize::RemoveContainer()     - Remove all resize data for this container
  ; Resize::RemoveGadget()        - Stop resizing gadget and remove resize data
  ; Resize::RemoveWindow()        - Remove all resize data for this window (-> CloseWindow)
  ; Resize::RestoreWindow()       - Restore original window & gadgets size
  ; Resize::SelectWindow()        - Select a previously added window
  ; Resize::SetFactor()           - Set the factor for the movement and size adjustment (Default: 100%)
  ; Resize::SetListColumn()       - Define ListIcon column for automatic resizing
;}

DeclareModule Resize
  
  ;- ===========================================================================
  ;-   DeclareModule (Resize)
  ;- ===========================================================================  

  ;{ ____ Constants_____
  EnumerationBinary Resize
    #MoveX
    #MoveY
    #Width
    #Height
    #HCenter
    #VCenter
    #HFactor
    #VFactor
    #Column
    #FitText
    #FixPadding
  EndEnumeration
  
  #Horizontal = #HFactor
  #Vertical   = #VFactor
  
  Enumeration 1
    #PaddingX
    #PaddingY
    #MinWidth
    #MaxWidth
    #MinHeight
    #MaxHeight
  EndEnumeration
  
  Enumeration #PB_Event_FirstCustomValue
    #Event_Proportional
  EndEnumeration
  ;}
  
  Declare.i AddContainer(GNum.i, WindowNum.i=#PB_Default)
  Declare.i AddWindow(WindowNum.i, minWidth.i=#PB_Default, minHeight.i=#PB_Default , maxWidth.i=#PB_Default , maxHeight.i=#PB_Default , Flags.i=#False)
  Declare.i AddGadget(GNum.i, Flags.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
  Declare.i AddGadgetFont(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i ChangeGadgetFont(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i RemoveContainer(GNum.i, WindowNum.i=#PB_Default)
  Declare.i RemoveGadget(GNum.i, WindowNum.i=#PB_Default)
  Declare.i RestoreWindow(WindowNum.i)
  Declare.i SelectWindow(WindowNum.i)
  Declare.i SetFactor(GNum.i, Type.i, Percent.s, WindowNum.i=#PB_Default)
  Declare.i SetListIconColumn(GNum.i, Column.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
  
EndDeclareModule  
  
Module Resize
  
  EnableExplicit

  ;- ===========================================================================
  ;-   Module - Structures (Resize)
  ;- ===========================================================================  
  
  Structure Padding_Structure
    X.i
    Y.i
    Factor.f
  EndStructure
  
  Structure RGEx_Font_Structure         ;{ RGEx()\Font(NameStyle)\...
	  Name.s
	  Style.i
	  Map Size.i()
	EndStructure ;}
  
  Structure RGEx_Gadget_Font_Structure  ;{ RGEx()\Gadget()\Font\...
	  Num.i
	  Name.s
	  Style.i
	  Size.i
	EndStructure ;}

  Structure RGEx_Gadgets_Structure      ;{ RGEx()\Gadget(gNum)\...
    X.i
    Y.i
    Width.i
    Height.i
    HFactor.f
    VFactor.f
    Column.i
    ColWidth.i
    Font.RGEx_Gadget_Font_Structure
    PaddingX.i
    PaddingY.i
    PFactor.f
    Container.i
    Flags.i
  EndStructure ;}
  
  Structure RGEx_Container_Structure    ;{ RGEx()\Container(gGum)\...
    X.i
    Y.i
    Width.i
    Height.i
    List GNum.i()
  EndStructure ;}

  Structure ResizeEx_Structure          ;{ RGEx(winNum)\...
    X.i
    Y.i
    Width.i
    Height.i
    minWidth.i
    minHeight.i
    maxWidth.i
    maxHeight.i
    PaddingX.i
    PaddingY.i
    Resize.i
    Flags.i
    Map Container.RGEx_Container_Structure()
    Map Gadget.RGEx_Gadgets_Structure()
    Map Font.RGEx_Font_Structure()
  EndStructure ;}  
  Global NewMap RGEx.ResizeEx_Structure()
  
  ;- ============================================================================
	;-   Module - Internal
	;- ============================================================================
  
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

	
  Procedure.d Pixel_(Points.i)
	  ; Pixel = Points * 96 / 72
	  ProcedureReturn Round(Points * 96 / 72, #PB_Round_Up)
	EndProcedure
	
	Procedure.i Point_(Pixel.f)
	  ; Points = Pixel * 72 / 96
	  ProcedureReturn Round(Pixel * 72 / 96, #PB_Round_Nearest)
	EndProcedure
	
	; _____ Fit Text (Font) _____
	
  CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Procedure.i LoadFont_(FontName.s, Style.i, Size.i) 
	    ProcedureReturn ModuleEx::Font(FontName, Size, Style)
	  EndProcedure
	  
	CompilerElse
	
    Procedure.i LoadFont_(Name.s, Style.i, Size.i) 
  	  Define.i Font
  	  
  	  Font = RGEx()\Font(Name+"|"+Str(Style))\Size(Str(Size))
      If IsFont(Font)
        ProcedureReturn Font
      Else  
        Font = LoadFont(#PB_Any, Name, Size, Style)
        If IsFont(Font)
          RGEx()\Font(Name+"|"+Str(Style))\Size(Str(Size)) = Font
          ProcedureReturn Font
        EndIf   
      EndIf 
  	  
  	  ProcedureReturn #False
  	EndProcedure
  	
  CompilerEndIf
	
	
	Procedure   GetPadding_(Text.s, Height.i, FontNum.i, FontSize.i, *Padding.Padding_Structure)
    Define.i ImgNum
    
    If Text = ""           : ProcedureReturn #False : EndIf
    If Not IsFont(FontNum) : ProcedureReturn #False : EndIf 
    If FontSize <= 0       : ProcedureReturn #False : EndIf 
    If Height   <= 0       : ProcedureReturn #False : EndIf 

    If FindString(Text, #CR$)
      Text = ReplaceString(Text, #CRLF$, #LF$)
      Text = ReplaceString(Text, #LFCR$, #LF$)
      ReplaceString(Text, #CR$, #LF$, #PB_String_InPlace)
    EndIf
    
    ImgNum = CreateImage(#PB_Any, 16, 16)
    If ImgNum

      If StartVectorDrawing(ImageVectorOutput(ImgNum))
        
        VectorFont(FontID(FontNum), Pixel_(FontSize))

        *Padding\X = RGEx()\PaddingX
        *Padding\Y = dpiY(Height - (VectorTextHeight(Text, #PB_VectorText_Default)))
        If *Padding\Y < 0 : *Padding\Y = 0 : EndIf 
        *Padding\Factor = *Padding\Y / Height
        
        StopVectorDrawing()
      EndIf
      
      FreeImage(ImgNum)
    EndIf
    
  EndProcedure
	
	Procedure.i CalcFitFontSize_(Text.s, Width.i, Height.i, FontNum.i)
	  Define.i FontSize, ImgNum, r, Rows 
	  Define.i txtWidth, txtHeight, maxWidth, hSize, vSize, DiffW
	  Define.f FactorW, FactorH
    Define.s maxText
    
    If Width <= 0 Or Height <= 0 : ProcedureReturn 1 : EndIf 
    
    Width  = dpiX(Width)
    Height = dpiY(Height) 
    
    If IsFont(FontNum) = #False : ProcedureReturn #False : EndIf 
    If Text = "" : ProcedureReturn #False : EndIf
    
    If FindString(Text, #CR$)
      Text = ReplaceString(Text, #CRLF$, #LF$)
      Text = ReplaceString(Text, #LFCR$, #LF$)
      ReplaceString(Text, #CR$, #LF$, #PB_String_InPlace)
    EndIf

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
        
        Rows = CountString(Text, #LF$) + 1
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

        If txtWidth < Width And txtHeight < Height ;{ enlarge text
          
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
          ;}
        Else                                       ;{ reduce text
         
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
            
            If FontSize <= 1 : Break : EndIf
            
          Wend
          ;}
        EndIf
       
        StopVectorDrawing()
      EndIf
      
      FreeImage(ImgNum)
    EndIf
    
    ProcedureReturn FontSize
  EndProcedure	
	
  ;- __________ Events __________
  
  Procedure _ResizeHandler()
    Define.i X, Y, Width, Height
    Define.i OffSetX, OffSetY
    Define.i GNum
    Define.i ContainerNum = EventGadget() 
    
    If FindMapElement(RGEx(), Str(GetGadgetData(ContainerNum)))
      
      If FindMapElement(RGEx()\Container(), Str(ContainerNum))
      
        ForEach RGEx()\Container()\GNum()
          
          If FindMapElement(RGEx()\Gadget(), Str(RGEx()\Container()\GNum()))
            
            GNum = RGEx()\Container()\GNum()
            
            OffSetX = GadgetWidth(ContainerNum)  - RGEx()\Container()\Width
            OffsetY = GadgetHeight(ContainerNum) - RGEx()\Container()\Height
            
            If RGEx()\Gadget()\Flags & #HFactor : OffSetX * RGEx()\Gadget()\HFactor : EndIf
            If RGEx()\Gadget()\Flags & #VFactor : OffSetY * RGEx()\Gadget()\VFactor : EndIf
            
            X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
            
            If RGEx()\Gadget()\Flags & #MoveX : X = RGEx()\Gadget()\X + OffSetX : EndIf
            If RGEx()\Gadget()\Flags & #MoveY : Y = RGEx()\Gadget()\Y + OffSetY : EndIf
            
            If RGEx()\Gadget()\Flags & #HCenter : X = (GadgetWidth(ContainerNum)  - GadgetWidth(GNum))  / 2 : EndIf
            If RGEx()\Gadget()\Flags & #VCenter : Y = (GadgetHeight(ContainerNum) - GadgetHeight(GNum)) / 2 : EndIf
            
            If RGEx()\Gadget()\Flags & #Column
              SetGadgetItemAttribute(GNum, -1, #PB_ListIcon_ColumnWidth, RGEx()\Gadget()\ColWidth + OffSetX, RGEx()\Gadget()\Column)
            EndIf
            
            If RGEx()\Gadget()\Flags & #Width  : Width  = RGEx()\Gadget()\Width  + OffSetX : EndIf
            If RGEx()\Gadget()\Flags & #Height : Height = RGEx()\Gadget()\Height + OffSetY : EndIf
            
            ResizeGadget(GNum, X, Y, Width, Height)
            
          EndIf  
          
        Next
      EndIf
      
    EndIf  
    
  EndProcedure 
  
  Procedure _ResizeWindowHandler()
    Define.i X, Y, Width, Height, FontSize
    Define.f HFactor, VFactor
    Define.i OffSetX, OffSetY
    Define.i GNum, WinNum = EventWindow() 
    
    If FindMapElement(RGEx(), Str(WinNum))

      OffSetX = WindowWidth(WinNum)  - RGEx()\Width
      OffsetY = WindowHeight(WinNum) - RGEx()\Height      
      
      ForEach RGEx()\Gadget()
        
        GNum = Val(MapKey(RGEx()\Gadget()))
        If IsGadget(GNum)

          If RGEx()\Gadget()\Flags & #HFactor : HFactor = RGEx()\Gadget()\HFactor : Else : HFactor = 1 : EndIf
          If RGEx()\Gadget()\Flags & #VFactor : VFactor = RGEx()\Gadget()\VFactor : Else : VFactor = 1 : EndIf

          X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
          
          If RGEx()\Gadget()\Flags & #MoveX : X = RGEx()\Gadget()\X + (OffSetX * HFactor) : EndIf
          If RGEx()\Gadget()\Flags & #MoveY : Y = RGEx()\Gadget()\Y + (OffSetY * VFactor) : EndIf
          
          If RGEx()\Gadget()\Flags & #HCenter : X = (WindowWidth(WinNum)  - GadgetWidth(GNum))  / 2 : EndIf
          If RGEx()\Gadget()\Flags & #VCenter : Y = (WindowHeight(WinNum) - GadgetHeight(GNum)) / 2 : EndIf
          
          If RGEx()\Gadget()\Flags & #Column And RGEx()\Gadget()\Flags & #Width
            SetGadgetItemAttribute(GNum, -1, #PB_ListIcon_ColumnWidth, RGEx()\Gadget()\ColWidth + (OffSetX * HFactor), RGEx()\Gadget()\Column)
          EndIf
          
          If RGEx()\Gadget()\Flags & #Width  : Width  = RGEx()\Gadget()\Width  + (OffSetX * HFactor) : EndIf
          If RGEx()\Gadget()\Flags & #Height : Height = RGEx()\Gadget()\Height + (OffSetY * VFactor) : EndIf
          
          If Height < 0 : Height = #PB_Ignore : EndIf
					If Width  < 0 : Width  = #PB_Ignore : EndIf
          
          ResizeGadget(GNum, X, Y, Width, Height)
          
          If RGEx()\Gadget()\Flags & #FitText
            
            If RGEx()\Gadget()\Flags & #FixPadding
              Width  = GadgetWidth(GNum)  - RGEx()\Gadget()\PaddingX
              Height = GadgetHeight(GNum) - RGEx()\Gadget()\PaddingY
            Else  
              Width  = GadgetWidth(GNum)  - RGEx()\Gadget()\PaddingX
              Height = GadgetHeight(GNum) - (GadgetHeight(GNum) * RGEx()\Gadget()\PFactor)
            EndIf
            
            FontSize = CalcFitFontSize_(GetGadgetText(GNum), Width, Height, RGEx()\Gadget()\Font\Num)  
            If FontSize <> RGEx()\Gadget()\Font\Size
              RGEx()\Gadget()\Font\Size = FontSize
              RGEx()\Gadget()\Font\Num  = LoadFont_(RGEx()\Gadget()\Font\Name, RGEx()\Gadget()\Font\Style, FontSize)
              SetGadgetFont(GNum, FontID(RGEx()\Gadget()\Font\Num))
            EndIf   
          EndIf    

        EndIf  
        
      Next
      
    EndIf  
    
  EndProcedure 
  
  
  Procedure _CloseWindowHandler()
    Define.i WindowNum = EventWindow(), Count
    
    If FindMapElement(RGEx(), Str(WindowNum))
      
      ForEach RGEx()\Font()
        ForEach RGEx()\Font()\Size()
          FreeFont(RGEx()\Font()\Size())
          Count + 1
        Next
      Next
      
      UnbindEvent(#PB_Event_SizeWindow,  @_ResizeWindowHandler(), WindowNum)
      UnbindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(),  WindowNum)
      
      DeleteMapElement(RGEx())
     
    EndIf 
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures (Resize)
  ;- ========================================================================== 
  
  Procedure.i AddContainer(GNum.i, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
    
    If IsGadget(GNum)
      
      If AddMapElement(RGEx()\Container(), Str(GNum))
        
        RGEx()\Container()\X      = GadgetX(GNum)
        RGEx()\Container()\Y      = GadgetY(GNum)
        RGEx()\Container()\Width  = GadgetWidth(GNum)
        RGEx()\Container()\Height = GadgetHeight(GNum)
        
        SetGadgetData(GNum, WindowNum)
        BindGadgetEvent(GNum, @_ResizeHandler(), #PB_EventType_Resize)
        
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn  #False
  EndProcedure
  
  Procedure.i AddWindow(WindowNum.i, minWidth.i=#PB_Default, minHeight.i=#PB_Default , maxWidth.i=#PB_Default , maxHeight.i=#PB_Default , Flags.i=#False)
    
    If IsWindow(WindowNum)
      
      If AddMapElement(RGEx(), Str(WindowNum))
        
        RGEx()\X = WindowX(WindowNum)
        RGEx()\Y = WindowY(WindowNum)
        RGEx()\Width     = WindowWidth(WindowNum)
        RGEx()\Height    = WindowHeight(WindowNum)
        RGEx()\minWidth  = minWidth
        RGEx()\minHeight = minHeight
        RGEx()\maxWidth  = maxWidth
        RGEx()\maxHeight = maxHeight
        RGEx()\Flags     = GetWindowState(WindowNum)
        RGEx()\PaddingX  = 12
        RGEx()\PaddingY  = 8
        RGEx()\Flags     = Flags
        
        WindowBounds(WindowNum, minWidth, minHeight, maxWidth, maxHeight) 
        
        BindEvent(#PB_Event_SizeWindow,  @_ResizeWindowHandler(), WindowNum)
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(),  WindowNum)
        
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn  #False
  EndProcedure
  
  Procedure.i AddGadget(GNum.i, Flags.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
    Define.i X, Y
    
    If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
 
    If IsGadget(GNum)
      
      If AddMapElement(RGEx()\Gadget(), Str(GNum))
      
        RGEx()\Gadget()\X = GadgetX(GNum)
        RGEx()\Gadget()\Y = GadgetY(GNum)
        RGEx()\Gadget()\Width   = GadgetWidth(GNum)
        RGEx()\Gadget()\Height  = GadgetHeight(GNum)
        RGEx()\Gadget()\Flags   = Flags
        RGEx()\Gadget()\HFactor = 1
        RGEx()\Gadget()\VFActor = 1
        
        If RGEx()\Gadget()\Flags & #HCenter
          X = (WindowWidth(WindowNum) - GadgetWidth(GNum))  / 2
          ResizeGadget(GNum, X, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        EndIf
        
        If RGEx()\Gadget()\Flags & #VCenter
          Y = (WindowHeight(WindowNum) - GadgetHeight(GNum)) / 2
          ResizeGadget(GNum, #PB_Ignore, Y, #PB_Ignore, #PB_Ignore)
        EndIf
        
        If ContainerNum <> #PB_Ignore
          RGEx()\Gadget()\Container = ContainerNum
          If FindMapElement(RGEx()\Container(), Str(ContainerNum))
            If AddElement(RGEx()\Container()\GNum())
              RGEx()\Container()\GNum() = GNum
            EndIf
          EndIf  
        EndIf
        
        ProcedureReturn #True
      EndIf

    EndIf
    
    ProcedureReturn  #False
  EndProcedure
  
  Procedure.i AddGadgetFont(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i FontNum, Width, Height
    Define   Padding.Padding_Structure
    
    If WindowNum <> #PB_Default
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf

    If FindMapElement(RGEx()\Gadget(), Str(GNum))

      FontNum = LoadFont_(FontName, Style, Size)
      If IsFont(FontNum)
        
        RGEx()\Gadget()\Flags | #FitText
        
        RGEx()\Gadget()\Font\Num   = FontNum
        RGEx()\Gadget()\Font\Name  = FontName
        RGEx()\Gadget()\Font\Size  = Size
        RGEx()\Gadget()\Font\Style = Style

        If Flags & #FitText
          
          RGEx()\Gadget()\PaddingX = RGEx()\PaddingX
          RGEx()\Gadget()\PaddingY = RGEx()\PaddingY
          
          Width  = GadgetWidth(GNum)  - RGEx()\PaddingX
          Height = GadgetHeight(GNum) - RGEx()\PaddingY
          
          Size = CalcFitFontSize_(GetGadgetText(GNum), Width, Height, RGEx()\Gadget()\Font\Num)  
          If Size <> RGEx()\Gadget()\Font\Size
            RGEx()\Gadget()\Font\Size = Size
            RGEx()\Gadget()\Font\Num  = LoadFont_(RGEx()\Gadget()\Font\Name, RGEx()\Gadget()\Font\Style, Size)
          EndIf   
          
        EndIf
        
        GetPadding_(GetGadgetText(GNum), GadgetHeight(GNum), RGEx()\Gadget()\Font\Num, Size, @Padding)
        
        RGEx()\Gadget()\PaddingX = Padding\X
        RGEx()\Gadget()\PaddingY = Padding\Y
        RGEx()\Gadget()\PFactor  = Padding\Factor
        
        If Flags & #FixPadding : RGEx()\Gadget()\Flags | #FixPadding : EndIf
        
        SetGadgetFont(GNum, FontID(RGEx()\Gadget()\Font\Num))
        
        ProcedureReturn RGEx()\Gadget()\Font\Num
      EndIf
      
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  
  Procedure.i RemoveGadget(GNum.i, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      
      If DeleteMapElement(RGEx()\Gadget(), Str(GNum))
        ProcedureReturn #True
      EndIf
      
    Else
      
      If DeleteMapElement(RGEx(Str(WindowNum))\Gadget(), Str(GNum))
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i RemoveContainer(GNum.i, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      
      If DeleteMapElement(RGEx()\Container(), Str(GNum))
        UnbindGadgetEvent(GNum, @_ResizeHandler(), #PB_EventType_Resize)
        ProcedureReturn #True
      EndIf
      
    Else
      
      If DeleteMapElement(RGEx(Str(WindowNum))\Container(), Str(GNum))
        UnbindGadgetEvent(GNum, @_ResizeHandler(), #PB_EventType_Resize)
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  

  Procedure.i RestoreWindow(WindowNum.i)
    Define.i GNum
    
    If FindMapElement(RGEx(), Str(WindowNum))
      
      If IsWindow(WindowNum)
        ResizeWindow(WindowNum, #PB_Ignore, #PB_Ignore, RGEx()\Width, RGEx()\Height)
        ForEach RGEx()\Container()
          GNum = Val(MapKey(RGEx()\Container()))
          If IsGadget(GNum) : ResizeGadget(GNum, RGEx()\Container()\X, RGEx()\Container()\Y, RGEx()\Container()\Width, RGEx()\Container()\Height) : EndIf
        Next
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure.i SelectWindow(WindowNum.i)
    
    If FindMapElement(RGEx(), Str(WindowNum))
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetFactor(GNum.i, Type.i, Percent.s, WindowNum.i=#PB_Default)
    
    If WindowNum <> #PB_Default : FindMapElement(RGEx(), Str(WindowNum)) : EndIf
 
    If FindMapElement(RGEx()\Gadget(), Str(GNum))
      
      Percent = Trim(RemoveString(Percent, "%"))
      Select Type
        Case #Horizontal
          RGEx()\Gadget()\HFactor = Val(Percent) / 100
          RGEx()\Gadget()\Flags | #HFactor
          ProcedureReturn #True
        Case #Vertical
          RGEx()\Gadget()\VFactor = Val(Percent) / 100
          RGEx()\Gadget()\Flags | #VFactor
          ProcedureReturn #True
      EndSelect
      
    EndIf

    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetListIconColumn(GNum.i, Column.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
 
    If IsGadget(GNum)
      
      If FindMapElement(RGEx()\Gadget(), Str(GNum))
        RGEx()\Gadget()\Column   = Column
        RGEx()\Gadget()\ColWidth = GetGadgetItemAttribute(GNum, -1, #PB_ListIcon_ColumnWidth, Column)
        RGEx()\Gadget()\Flags | #Column
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  
	Procedure.i ChangeGadgetFont(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False, WindowNum.i=#PB_Default)
	  Define.i FontNum, Width, Height
	  Define   Padding.Padding_Structure
	  
	  If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
      
    If FindMapElement(RGEx()\Gadget(), Str(GNum))

      FontNum = LoadFont_(FontName, Style, Size)
      If IsFont(FontNum)
        RGEx()\Gadget()\Font\Num = FontNum
        RGEx()\Gadget()\Font\Name  = FontName
        RGEx()\Gadget()\Font\Size  = Size
        RGEx()\Gadget()\Font\Style = Style
        
        If Flags & #FitText
          
          RGEx()\Gadget()\PaddingX = RGEx()\PaddingX
          RGEx()\Gadget()\PaddingY = RGEx()\PaddingY
          
          Width  = GadgetWidth(GNum)  - RGEx()\PaddingX
          Height = GadgetHeight(GNum) - RGEx()\PaddingY
          
          Size = CalcFitFontSize_(GetGadgetText(GNum), Width, Height, RGEx()\Gadget()\Font\Num)  
          If Size <> RGEx()\Gadget()\Font\Size
            RGEx()\Gadget()\Font\Size = Size
            RGEx()\Gadget()\Font\Num  = LoadFont_(RGEx()\Gadget()\Font\Name, RGEx()\Gadget()\Font\Style, Size)
          EndIf   
          
        Else
          
          GetPadding_(GetGadgetText(GNum), Height, RGEx()\Gadget()\Font\Num, Size, @Padding)
          RGEx()\Gadget()\PaddingX = Padding\X
          RGEx()\Gadget()\PaddingY = Padding\Y
          
        EndIf 
        
        SetGadgetFont(GNum, FontID(RGEx()\Gadget()\Font\Num))
      EndIf
      
    EndIf
	  
	  ProcedureReturn FontNum
	EndProcedure
	
	Procedure   SetAttribute(Attribute.i, Value.i, WindowNum.i=#PB_Default)
	  
	  If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
    
    Select Attribute
      Case #MinWidth
        RGEx()\minWidth  = Value
      Case #MaxWidth
        RGEx()\maxWidth  = Value
      Case #MinHeight
        RGEx()\minHeight = Value
      Case #MaxHeight
        RGEx()\maxHeight = Value
      Case #PaddingX
        RGEx()\PaddingX  = Value
      Case #PaddingY
        RGEx()\PaddingY  = Value
    EndSelect    
	  
	EndProcedure
	
EndModule 


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 2
  
  ; 1: Resize gadgets demo
  ; 2: Resize gadget text demo
  
  #Window = 1
  #StatusBar = 1
  
  Enumeration 1
    #Button_0
    #Button_1
    #Button_2
    #Button_3
    #Button_4
    #Button_5
    #List
    #Editor1
    #Editor2
    #Container
  EndEnumeration 
  
  Window::Load()
  
  If OpenWindow(#Window, 0, 0, 300, 275, " Example", #PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_TitleBar|#PB_Window_ScreenCentered |#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget)
    
    CompilerSelect #Example
      CompilerCase 1  ;{ Resize gadgets 
        ButtonGadget(#Button_0,   5,   5, 50, 25, "Resize -")
        ButtonGadget(#Button_1, 245,   5, 50, 25, "Resize +")
        ButtonGadget(#Button_2,   5, 240, 50, 25, "Reset")
        ButtonGadget(#Button_3, 250, 125, 45, 20, "Button")
        ListIconGadget(#List, 55, 30, 190, 210, "Column", 56, #PB_ListIcon_GridLines)
          AddGadgetColumn(#List, 1, "Column 1", 130)
        ButtonGadget(#Button_4, 55, 245, 80, 25, "Container")
        EditorGadget(#Editor1, 250,  35, 45, 85)
        EditorGadget(#Editor2, 250, 150, 45, 90)
        If ContainerGadget(#Container, 57, 30, 186, 210, #PB_Container_Single)
          ButtonGadget(#Button_5, 0, 0, 50, 25, "List")
          CloseGadgetList()
          HideGadget(#Container, #True)
        EndIf

        If Resize::AddWindow(#Window, 300, 275, 400, 375)
          Resize::AddGadget(#Button_1,  Resize::#MoveX)
          Resize::AddGadget(#Button_2,  Resize::#MoveY)
          Resize::AddGadget(#Button_3,  Resize::#MoveX|Resize::#MoveY)
          Resize::SetFactor(#Button_3,  Resize::#VFactor, "50%")
          Resize::AddGadget(#Button_4,  Resize::#HCenter|Resize::#MoveY)
          Resize::AddGadget(#Editor1,   Resize::#MoveX|Resize::#Height)
          Resize::SetFactor(#Editor1,   Resize::#VFactor, "50%")
          Resize::AddGadget(#Editor2,   Resize::#MoveX|Resize::#MoveY|Resize::#Height)
          Resize::SetFactor(#Editor2,   Resize::#VFactor, "50%")
          Resize::AddGadget(#List,      Resize::#Height|Resize::#Width)
          Resize::AddGadget(#Container, Resize::#Height|Resize::#Width)
          If Resize::AddContainer(#Container, #Window)
            Resize::AddGadget(#Button_5, Resize::#HCenter|Resize::#VCenter, #Container)
          EndIf
          Resize::SetListIconColumn(#List, 1)
        EndIf
        
        ;}
      CompilerCase 2  ;{ Resize gadget text
        
        ButtonGadget(#Button_0, 100, 230, 100, 24, "Reset")
        ButtonGadget(#Button_1,  20, 20, 120, 40, "Arial Bold")
        ButtonGadget(#Button_2, 160, 20, 120, 40, "Times New Roman")
        ButtonGadget(#Button_3, 20, 80, 260, 80, "Resize"+#LF$+"multiline text", #PB_Button_MultiLine)
        
        If Resize::AddWindow(#Window) ; 260, 265, 400, 375
          Resize::AddGadget(#Button_0, Resize::#HCenter|Resize::#MoveY)
          Resize::AddGadget(#Button_1, Resize::#Width|Resize::#Height)
          Resize::SetFactor(#Button_1, Resize::#HFactor, "50%")
          Resize::SetFactor(#Button_1, Resize::#VFactor, "50%")
          Resize::AddGadgetFont(#Button_1, "Arial", 11)
          Resize::AddGadget(#Button_2, Resize::#MoveX|Resize::#Width|Resize::#Height)
          Resize::AddGadgetFont(#Button_2, "Times New Roman", 9)
          Resize::SetFactor(#Button_2, Resize::#HFactor, "50%")
          Resize::SetFactor(#Button_2, Resize::#VFactor, "50%")
          Resize::AddGadget(#Button_3, Resize::#MoveY|Resize::#Width|Resize::#Height)
          Resize::SetFactor(#Button_3, Resize::#VFactor, "50%")
          Resize::AddGadgetFont(#Button_3, "Arial", 14, #False) ;  , Resize::#FitText| Resize::#FixPadding
        EndIf
        ;}
    CompilerEndSelect
    
    CompilerIf #Example = 1
      Window::RestoreSize(#Window)
    CompilerEndIf
 
    ExitWindow = #False
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          Window::StoreSize(#Window)
          ExitWindow = #True
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button_0
              CompilerSelect  #Example
                CompilerCase 1
                  ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 300, 275)
                CompilerCase 2
                  ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 300, 275) 
              CompilerEndSelect
            Case #Button_1
              CompilerIf #Example = 1 : ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 350, 400) : CompilerEndIf
            Case #Button_2
              CompilerIf #Example = 1 : Resize::RestoreWindow(#Window) : CompilerEndIf
            Case #Button_4
              HideGadget(#List, #True)
              HideGadget(#Container, #False)
            Case #Button_5
              HideGadget(#List, #False)
              HideGadget(#Container, #True)
          EndSelect
      EndSelect
    Until ExitWindow
    
    CompilerIf #Example = 1 : Window::Save() : CompilerEndIf
    
    CloseWindow(#Window)
  EndIf
  
  
 
CompilerEndIf   

; IDE Options = PureBasic 5.71 LTS (Windows - x86)
; CursorPosition = 1120
; FirstLine = 264
; Folding = AgDgHAAAy-
; EnableXP
; DPIAware