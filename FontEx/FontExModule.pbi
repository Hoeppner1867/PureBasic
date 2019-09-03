;/ ==========================
;/ =    FontExModule.pbi    =
;/ ==========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ based on code of Werner Albus - www.nachtoptik.de (GFX_Wizzard_BF) 
;/
;/ © 2019 by Thorsten Hoeppner (08/2019)
;/


; Last Update:


;{ ===== MIT License =====
;
; Copyright (c) 2019 Werner Albus - www.nachtoptik.de
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


;{ _____ FontEx - Commands _____

; FontEx::RequiredSize()   - returns the required font size
; 
; --- Gadgets ---
;
; FontEx::AddGadget()      - add gadget to work with FontEx and load the required font if necessary.
; FontEx::FitText()        - fit font size for current text
; FontEx::SetAttribute()   - [#Minimum / #Maximum / #Padding / #PaddingX / #PaddingY]
; FontEx::SetFont()        - change the font of the gadget and load the required font if necessary.
; FontEx::SetText()        - set text and fit font size
;}


DeclareModule FontEx

	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  ;{ _____ Constants _____
  EnumerationBinary
    #Minimum
    #Maximum
    #PaddingX
    #PaddingY
    #FitText
    #FixPadding
  EndEnumeration
  #Padding = #PaddingX | #PaddingY
  ;}

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
  
  Declare.i RequiredSize(Text.s, Width.i, Height.i, FontNum.i)
  
  ; ____ Gadget _____
  
  Declare.i AddGadget(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False)
  Declare.i FitText(GNum.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare.i SetFont(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False)
  Declare.i SetText(GNum.i, Text.s)
  Declare   FreeFonts()
  Declare   FreeGadgetFonts(GNum.i)
  
EndDeclareModule

Module FontEx
  
	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
	
	Structure Gadget_Font_Structure   ;{ FontEx\Gadget()\Font\...
	  Num.i
	  Name.s
	  Style.i
	  Size.i
	  minSize.i
	  maxSize.i
	EndStructure ;}
	
	Structure FontEx_Gadget_Structure ;{ FontEx\Gadget('GNum')\...
	  Num.i
	  X.i
	  Y.i
	  Width.i
	  Height.i
	  PaddingX.i
	  PaddingY.i
	  PFActor.f
	  Font.Gadget_Font_Structure
	  Text.s
	  Flags.i
	EndStructure ;}
	
	Structure FontEx_Font_Structure   ;{ FontEx\Font('NameStyle')\...
	  Name.s
	  Style.i
	  Map Size.i()
	EndStructure ;}
	
	Structure FontEx_Structure        ;{ FontEx\...

	  Map Gadget.FontEx_Gadget_Structure()
	  
    Map Font.FontEx_Font_Structure()
    
	EndStructure ;}
	Global FontEx.FontEx_Structure
	
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

	
	Procedure.i Pixel_(Points.i)
	  ; Pixel = Points * 96 / 72
	  ProcedureReturn Round(Points * 96 / 72, #PB_Round_Up)
	EndProcedure
	
	Procedure.i Point_(Pixel.f)
	  ; Points = Pixel * 72 / 96
	  ProcedureReturn Round(Pixel * 72 / 96, #PB_Round_Nearest)
	EndProcedure
	
	
	CompilerIf Defined(ModuleEx, #PB_Module)
	  
	  Procedure.i LoadFont_(FontName.s, Style.i, Size.i) 
	    ProcedureReturn ModuleEx::Font(FontName, Size, Style)
	  EndProcedure
	  
	CompilerElse
	  
  	Procedure.i LoadFont_(FontName.s, Style.i, Size.i) 
  	  Define.i FontNum
  	  
  	  FontNum = FontEx\Font(FontName + Str(Style))\Size(Str(Size)) ; 
      If IsFont(FontNum)
        ProcedureReturn FontNum
      Else  
        FontNum = LoadFont(#PB_Any, FontName, Size, Style)
        If IsFont(FontNum)
          FontEx\Font(FontName+Str(Style))\Size(Str(Size)) = FontNum
          ProcedureReturn FontNum
        EndIf   
      EndIf 
  	  
  	  ProcedureReturn #False
  	EndProcedure
  	
  CompilerEndIf
  
  
	Procedure   SetPadding_()
    Define.i FontSize, ImgNum
    
    If FontEx\Gadget()\Text = "" : ProcedureReturn #False : EndIf
    If IsFont(FontEx\Gadget()\Font\Num) = #False : ProcedureReturn #False : EndIf 
    
    FontSize = FontEx\Gadget()\Font\Size
    If FontSize <= 0 : ProcedureReturn #False : EndIf 
    
    If FindString(FontEx\Gadget()\Text, #CR$)
      FontEx\Gadget()\Text = ReplaceString(FontEx\Gadget()\Text, #CRLF$, #LF$)
      FontEx\Gadget()\Text = ReplaceString(FontEx\Gadget()\Text, #LFCR$, #LF$)
      ReplaceString(FontEx\Gadget()\Text, #CR$, #LF$, #PB_String_InPlace)
    EndIf

    FontEx\Gadget()\PaddingX = 8
    FontEx\Gadget()\PaddingY = 8
    
    ImgNum = CreateImage(#PB_Any, 16, 16)
    If ImgNum

      If StartVectorDrawing(ImageVectorOutput(ImgNum))
        
        VectorFont(FontID(FontEx\Gadget()\Font\Num), Pixel_(FontSize))
        If FontEx\Gadget()\Flags & #PaddingX
          FontEx\Gadget()\PaddingX = (FontEx\Gadget()\Width  - VectorTextWidth(FontEx\Gadget()\Text,  #PB_VectorText_Visible)) / 2
          If FontEx\Gadget()\PaddingX < 1 : FontEx\Gadget()\PaddingX = 1 : EndIf 
        EndIf
        
        If FontEx\Gadget()\Flags & #PaddingY
          FontEx\Gadget()\PaddingY = (FontEx\Gadget()\Height - VectorTextHeight(FontEx\Gadget()\Text, #PB_VectorText_Default)) / 2
          If FontEx\Gadget()\PaddingY < 1 : FontEx\Gadget()\PaddingY = 1 : EndIf 
        EndIf

        StopVectorDrawing()
      EndIf
      
      FreeImage(ImgNum)
    EndIf
    
    FontEx\Gadget()\PFactor = FontEx\Gadget()\PaddingY / FontEx\Gadget()\Height
    
    ProcedureReturn FontSize
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
  
  
  Procedure.i FitGadgetText_(GNum.i, Text.s)
	  Define.i FontSize, Width, Height
	  
    FontEx\Gadget()\X      = GadgetX(GNum)
    FontEx\Gadget()\Y      = GadgetY(GNum)
    FontEx\Gadget()\Width  = GadgetWidth(GNum)
    FontEx\Gadget()\Height = GadgetHeight(GNum)
    
    If FontEx\Gadget()\Flags & #FixPadding
      Width  = FontEx\Gadget()\Width  - FontEx\Gadget()\PaddingX
      Height = FontEx\Gadget()\Height - FontEx\Gadget()\PaddingY
    Else
      Width  = FontEx\Gadget()\Width  - FontEx\Gadget()\PaddingX
      Height = FontEx\Gadget()\Height - (FontEx\Gadget()\Height * FontEx\Gadget()\PFactor)
    EndIf 
    
    FontSize = CalcFitFontSize_(FontEx\Gadget()\Text, Width, Height, FontEx\Gadget()\Font\Num) 
    
    If FontSize <> FontEx\Gadget()\Font\Size
      
      If FontEx\Gadget()\Font\maxSize <> #PB_Default And FontSize > FontEx\Gadget()\Font\maxSize : FontSize = FontEx\Gadget()\Font\maxSize : EndIf
      If FontEx\Gadget()\Font\minSize <> #PB_Default And FontSize < FontEx\Gadget()\Font\minSize : FontSize = FontEx\Gadget()\Font\minSize : EndIf
      
      FontEx\Gadget()\Font\Size = FontSize
      If FontSize >= 1
        FontEx\Gadget()\Font\Num  = LoadFont_(FontEx\Gadget()\Font\Name, FontEx\Gadget()\Font\Style, FontSize)
        SetGadgetFont(GNum, FontID(FontEx\Gadget()\Font\Num))
      EndIf
    
    EndIf
	  
	  ProcedureReturn FontSize
	EndProcedure
	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================	
	
	Procedure.i AddGadget(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False)
	  Define.i FontSize
	  Define.s FontKey
	  
	  If IsGadget(GNum)
	    
	    If AddMapElement(FontEx\Gadget(), Str(GNum))
	      
	      FontEx\Gadget()\Num    = GNum
	      FontEx\Gadget()\X      = GadgetX(GNum)
	      FontEx\Gadget()\Y      = GadgetY(GNum)
	      FontEx\Gadget()\Width  = GadgetWidth(GNum)
	      FontEx\Gadget()\Height = GadgetHeight(GNum)
	      FontEx\Gadget()\Text   = GetGadgetText(GNum)
	      FontEx\Gadget()\Flags  = Flags
	      
	      FontEx\Gadget()\Font\Num     = LoadFont_(FontName, Style, Size) 
	      FontEx\Gadget()\Font\Name    = FontName
	      FontEx\Gadget()\Font\Style   = Style
	      FontEx\Gadget()\Font\Size    = Size
	      FontEx\Gadget()\Font\minSize = #PB_Default
	      FontEx\Gadget()\Font\maxSize = #PB_Default
	      
	      SetPadding_() 
	      
	      If Flags & #FitText
          FitGadgetText_(GNum, GetGadgetText(GNum))
        EndIf
	      
	      If IsFont(FontEx\Gadget()\Font\Num)
	        SetGadgetFont(GNum, FontID(FontEx\Gadget()\Font\Num))
	      EndIf

	    EndIf
	   
      ProcedureReturn FontEx\Gadget()\Font\Num
	  EndIf
	  
	EndProcedure
	
	
	Procedure.i FitText(GNum.i)
	  Define.i FontSize
	  
	  If FindMapElement(FontEx\Gadget(), Str(GNum))
	    
      FontEx\Gadget()\Text = GetGadgetText(GNum)

      FontSize = FitGadgetText_(GNum, FontEx\Gadget()\Text)
	    
  	EndIf
	
	  ProcedureReturn FontSize
	EndProcedure
	
	Procedure.i SetText(GNum.i, Text.s)
	  Define.i FontSize
	  
	  If FindMapElement(FontEx\Gadget(), Str(GNum))
	    
      FontEx\Gadget()\Text = Text

      FontSize = FitGadgetText_(GNum, FontEx\Gadget()\Text)
      
	    SetGadgetText(GNum, Text)
	    
  	EndIf
	
	  ProcedureReturn FontSize
	EndProcedure
	
	Procedure.i SetFont(GNum.i, FontName.s, Size.i, Style.i=#False, Flags.i=#False)
	  
	  If FindMapElement(FontEx\Gadget(), Str(GNum))
	    
	    FontEx\Gadget()\Font\Num   = LoadFont_(FontName, Style, Size) 
      FontEx\Gadget()\Font\Name  = FontName
      FontEx\Gadget()\Font\Style = Style
      FontEx\Gadget()\Font\Size  = Size
      
      If Flags & #FitText
        FitGadgetText_(GNum, GetGadgetText(GNum))
      EndIf
      
      If IsFont(FontEx\Gadget()\Font\Num)
        SetGadgetFont(GNum, FontID(FontEx\Gadget()\Font\Num))
      EndIf
      
    EndIf
    
	  ProcedureReturn FontEx\Gadget()\Font\Num
	EndProcedure
	
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(FontEx\Gadget(), Str(GNum))
      
      Select Attribute
        Case #Minimum  
          FontEx\Gadget()\Font\minSize = Value
        Case #Maximum
          FontEx\Gadget()\Font\maxSize = Value
        Case #Padding
          FontEx\Gadget()\PaddingX = Value
          If Value < 4 : Value = 4 : EndIf
          FontEx\Gadget()\PaddingY = Value
        Case #PaddingX
          FontEx\Gadget()\PaddingX = Value
        Case #PaddingY
          If Value < 4 : Value = 4 : EndIf
          FontEx\Gadget()\PaddingY = Value
      EndSelect
  
    EndIf
    
  EndProcedure  
  
  Procedure.i RequiredSize(Text.s, Width.i, Height.i, FontNum.i)
    
    If IsFont(FontNum)
      ProcedureReturn CalcFitFontSize_(Text, Width, Height, FontNum)
    EndIf 
    
  EndProcedure
  
  Procedure   FreeGadgetFonts(GNum.i)
    
    If FindMapElement(FontEx\Gadget(), Str(GNum))
      
      If FindMapElement(FontEx\Font(), FontEx\Gadget()\Font\Name + Str(FontEx\Gadget()\Font\Style))
        ForEach FontEx\Font()\Size()
          FreeFont(FontEx\Font()\Size())
        Next
        DeleteMapElement(FontEx\Font())
      EndIf 
      
    EndIf

  EndProcedure
  
  Procedure   FreeFonts()
    
    ForEach FontEx\Font()
      ForEach FontEx\Font()\Size()
        FreeFont(FontEx\Font()\Size())
      Next
    Next
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 
    #Window
    #Change
    #Adjust
    #NewFont
    #Button
  EndEnumeration
  
  If OpenWindow(#Window, 0, 0, 200, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered)
    
    ButtonGadget(#Change,  40, 20, 120, 40, "Change Text", #PB_Button_Toggle) ; |#PB_Button_MultiLine
    ButtonGadget(#NewFont, 40, 80, 120, 40, "Change Font", #PB_Button_Toggle)
    ButtonGadget(#Adjust,  10, 140, 130, 24, "Adjust Text")
    ButtonGadget(#Button, 145, 140,  45, 24, "Resize", #PB_Button_Toggle)
    
    FontEx::AddGadget(#Change, "Arial", 12, #False, FontEx::#PaddingX) ; #FitText
    FontEx::SetAttribute(#Change, FontEx::#PaddingY, 5)
    
    FontEx::AddGadget(#NewFont, "Arial", 12, #False, FontEx::#PaddingX)
    
    FontEx::AddGadget(#Adjust, "Arial", 10, #False, FontEx::#PaddingY)
    FontEx::SetAttribute(#Adjust, FontEx::#PaddingX, 6)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Change   ;{ Change Text
              If GetGadgetState(#Change)
                FontEx::SetText(#Change, "Text")
              Else
                FontEx::SetText(#Change, "Change Text")
              EndIf   
              ;}
            Case #NewFont  ;{ Change Font
              If GetGadgetState(#NewFont)
                FontEx::SetFont(#NewFont, "Comic Sans MS", 12, #PB_Font_Bold, FontEx::#FitText)
              Else
                FontEx::SetFont(#NewFont, "Arial", 12)
              EndIf ;}
            Case #Button   ;{ Resize Gadget
              If GetGadgetState(#Button)
                ResizeGadget(#Adjust, #PB_Ignore, #PB_Ignore, #PB_Ignore, 40)
                ResizeGadget(#Button, #PB_Ignore, 148, #PB_Ignore, #PB_Ignore)
              Else
                ResizeGadget(#Adjust, #PB_Ignore, #PB_Ignore, #PB_Ignore, 24)
                ResizeGadget(#Button, #PB_Ignore, 140, #PB_Ignore, #PB_Ignore)
              EndIf  
              FontEx::FitText(#Adjust) ;}
          EndSelect    
      EndSelect
    Until Event = #PB_Event_CloseWindow
    
    FontEx::FreeFonts()

    CloseWindow(#Window)
  EndIf 
  
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x86)
; CursorPosition = 191
; FirstLine = 106
; Folding = cAyBA9
; EnableXP
; DPIAware