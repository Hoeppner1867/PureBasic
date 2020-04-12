;/ ===============================
;/ =    UseSVGImageModule.pbi    =
;/ ===============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/ 
;/ based on "VectorGraphic.pbi" of STARGÅTE 
;/ 
;/ © 2020 Thorsten1867 (04/2020)
;/ 

; https://my.pcloud.com/publink/show?code=kZfx8PkZtwdJunPnucpjyXAdCrpovFxYhJzX


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

;{ _____ Module - Commands _____

; SVG::Load()        - similar to LoadImage()
; SVG::Resize()      - similar to ResizeImage()
;
; SVG::Catch()       - uses an already loaded SVG file (XML) 
; SVG::CatchMemory() - uses a SVG file (XML) loaded into memory
; SVG::CatchString() - reads the SVG data from a string
;
; SVG::DrawVector()  - converts a loaded SVG file to 'VectorDrawing' commands

;}


DeclareModule SVG
  
  EnumerationBinary ; Image Flags
    #Proportional    ; scales the image proportionally
    #ForceSizeRatio  ; uses the specified aspect ratio (even if #Proportional has been set)
    #KeepImage       ; keeps the previous image after resizing (only if #PB_Any was used)
    #CreateNoImage   ; loads the SVG file without creating an image [=> 'SVG::DrawVector()']
  EndEnumeration
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================

  Declare.i Load(Image.i, File.s, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0.0, Height.d=0.0, Font.i=#False)
  Declare.i Catch(Image.i, svgXML.i, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0, Height.d=0, Font.i=#False) 
  Declare.i CatchMemory(Image.i, *MemorySVG, SizeSVG.i, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0, Height.d=0, Font.i=#False)
  Declare.i CatchString(Image.i, StringSVG.s, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0, Height.d=0, Font.i=#False)
  Declare.i Resize(Image.i, Width.d, Height.d, Flags.i=#False)
  Declare   DrawVector(Image.i, Width.d=0, Height.d=0, Flags.i=#False)
  
EndDeclareModule

Module SVG
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants / Structures
  ;- ============================================================================  
  
  Structure RegEx_Structure                 ;{ RegEx\...
    Color.i
    Command.i
    Definition.i
    Length.i
    Points.i
    Style.i
    Value.i
  EndStructure ;}
  Global RegEx.RegEx_Structure
  
  Structure ViewBox_Structure               ;{ SVG()\ViewBox\...
    X.d
    Y.d
    Width.d
    Height.d
    State.i
  EndStructure ;}
  
  Structure Image_Structure                 ;{ SVG()\Image\...
    Num.i
    Width.d
    Height.d
    Depth.i
    BackColor.q
    PB_Any.i
  EndStructure ;}
  
  Structure Style_Structure                 ;{ SVG()\CurrentStyle\...
  	Opacity.d
  	Fill.i
  	FillRule.i
  	FillOpacity.d
  	Stroke.i
  	StrokeWidth.d
  	StrokeOpacity.d
  	StrokeLineCap.i
  	StrokeLineJoin.i
  	Array StrokeDashArray.d(0)
  	StrokeDashOffset.d
  EndStructure ;}
  
  Structure StyleSheet_Class_Structure      ;{ SVG()\StyleSheet\Element()\...
  	Style.s
  EndStructure ;}
  
  Structure StyleSheet_Element_Structure    ;{ SVG()\StyleSheet\Element()\...
  	Map Class.StyleSheet_Class_Structure()
  EndStructure ;}
  
  Structure StyleSheet_Structure            ;{ SVG()\StyleSheet\...
  	Map Element.StyleSheet_Element_Structure()
  EndStructure ;}

  Structure SVG_Structure ;{ SVG('image')\...

  	ResX.d
  	ResY.d 
  	
  	Width.d
  	Height.d
  	
  	strgXML.s
  	
  	Font.i
  	
  	Flags.i
  	
    CurrentStyle.Style_Structure
  	
  	StyleSheet.StyleSheet_Structure
  	ViewBox.ViewBox_Structure
  	Image.Image_Structure
  	
  EndStructure ;}
  Global NewMap SVG.SVG_Structure()
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Declare Draw(*Node, Indent.i=0)
  
  
  Procedure.i X11Color_(Name.s)
    Select LCase(Name)
      Case "aliceblue"
        ProcedureReturn $FFF8F0
      Case "antiquewhite"
        ProcedureReturn $D7EBFA
      Case "aqua"
        ProcedureReturn $FFFF00
      Case "aquamarine"
        ProcedureReturn $D4FF7F
      Case "azure"
        ProcedureReturn $FFFFF0
      Case "beige"
        ProcedureReturn $DCF5F5
      Case "bisque"
        ProcedureReturn $C4E4FF
      Case "black"
        ProcedureReturn $000000
      Case "blanchedalmond"
        ProcedureReturn $CDEBFF
      Case "blue"
        ProcedureReturn $FF0000
      Case "blueviolet"
        ProcedureReturn $E22B8A
      Case "brown"
        ProcedureReturn $2A2AA5
      Case "burlywood"
        ProcedureReturn $87B8DE
      Case "cadetblue"
        ProcedureReturn $A09E5F
      Case "chartreuse"
        ProcedureReturn $00FF7F
      Case "chocolate"
        ProcedureReturn $1E69D2
      Case "coral"
        ProcedureReturn $507FFF
      Case "cornflowerblue"
        ProcedureReturn $ED9564
      Case "cornsilk"
        ProcedureReturn $DCF8FF
      Case "crimson"
        ProcedureReturn $3C14DC
      Case "cyan"
        ProcedureReturn $FFFF00
      Case "darkblue"
        ProcedureReturn $8B0000
      Case "darkcyan"
        ProcedureReturn $8B8B00
      Case "darkgoldenrod"
        ProcedureReturn $0B86B8
      Case "darkgray", "darkgrey"
        ProcedureReturn $A9A9A9
      Case "darkgreen"
        ProcedureReturn $006400
      Case "darkkhaki"
        ProcedureReturn $6BB7BD
      Case "darkmagenta"
        ProcedureReturn $8B008B
      Case "darkolivegreen"
        ProcedureReturn $2F6B55
      Case "darkorange"
        ProcedureReturn $008CFF
      Case "darkorchid"
        ProcedureReturn $CC3299
      Case "darkred"
        ProcedureReturn $00008B
      Case "darksalmon"
        ProcedureReturn $7A96E9
      Case "darkseagreen"
        ProcedureReturn $8FBC8F
      Case "darkslateblue"
        ProcedureReturn $8B3D48
      Case "darkslategrey", "darkslategray"
        ProcedureReturn $4F4F2F
      Case "darkturquoise"
        ProcedureReturn $D1CE00
      Case "darkviolet"
        ProcedureReturn $D30094
      Case "deeppink"
        ProcedureReturn $9314FF
      Case "deepskyblue"
        ProcedureReturn $FFBF00
      Case "dimgray", "dimgrey"
        ProcedureReturn $696969
      Case "dodgerblue"
        ProcedureReturn $FF901E
      Case "firebrick"
        ProcedureReturn $2222B2
      Case "floralwhite"
        ProcedureReturn $F0FAFF
      Case "forestgreen"
        ProcedureReturn $228B22
      Case "fuchsia"
        ProcedureReturn $FF00FF
      Case "gainsboro"
        ProcedureReturn $DCDCDC
      Case "ghostwhite"
        ProcedureReturn $FFF8F8
      Case "gold"
        ProcedureReturn $00D7FF
      Case "goldenrod"
        ProcedureReturn $20A5DA
      Case "gray", "grey"
        ProcedureReturn $808080
      Case "green"
        ProcedureReturn $008000
      Case "greenyellow"
        ProcedureReturn $2FFFAD
      Case "honeydew"
        ProcedureReturn $F0FFF0
      Case "hotpink"
        ProcedureReturn $B469FF
      Case "indianred"
        ProcedureReturn $5C5CCD
      Case "indigo"
        ProcedureReturn $82004B
      Case "ivory"
        ProcedureReturn $F0FFFF
      Case "khaki"
        ProcedureReturn $8CE6F0
      Case "lavender"
        ProcedureReturn $FAE6E6
      Case "lavenderblush"
        ProcedureReturn $F5F0FF
      Case "lawngreen"
        ProcedureReturn $00FC7C
      Case "lemonchiffon"
        ProcedureReturn $CDFAFF
      Case "lightblue"
        ProcedureReturn $E6D8AD
      Case "lightcoral"
        ProcedureReturn $8080F0
      Case "lightcyan"
        ProcedureReturn $FFFFE0 
      Case "lightgoldenrodyellow"
        ProcedureReturn $D2FAFA 
      Case "lightgray","lightgrey"
        ProcedureReturn $D3D3D3
      Case "lightgreen"
        ProcedureReturn $90EE90
      Case "lightpink"
        ProcedureReturn $C1B6FF
      Case "lightsalmon"
        ProcedureReturn $7AA0FF
      Case "lightseagreen"
        ProcedureReturn $AAB220
      Case "lightskyblue"
        ProcedureReturn $FACE87
      Case "lightslategray", "lightslategrey"
        ProcedureReturn $998877
      Case "lightsteelblue"
        ProcedureReturn $DEC4B0
      Case "lightyellow"
        ProcedureReturn $E0FFFF
      Case "lime"
        ProcedureReturn $00FF00
      Case "limegreen"
        ProcedureReturn $32CD32
      Case "linen"
        ProcedureReturn $E6F0FA
      Case "magenta"
        ProcedureReturn $FF00FF
      Case "maroon"
        ProcedureReturn $000080
      Case "mediumaquamarine"
        ProcedureReturn $AACD66
      Case "mediumblue"
        ProcedureReturn $CD0000
      Case "mediumorchid"
        ProcedureReturn $D355BA
      Case "mediumpurple"
        ProcedureReturn $DB7093
      Case "mediumseagreen"
        ProcedureReturn $71B33C
      Case "mediumslateblue"
        ProcedureReturn $EE687B
      Case "mediumspringgreen"
        ProcedureReturn $9AFA00
      Case "mediumturquoise"
        ProcedureReturn $CCD148
      Case "mediumvioletred"
        ProcedureReturn $8515C7
      Case "midnightblue"
        ProcedureReturn $701919
      Case "mintcream"
        ProcedureReturn $FAFFF5
      Case "mistyrose"
        ProcedureReturn $E1E4FF
      Case "moccasin"
        ProcedureReturn $B5E4FF
      Case "navajowhite"
        ProcedureReturn $ADDEFF
      Case "navy"
        ProcedureReturn $800000
      Case "oldlace"
        ProcedureReturn $E6F5FD
      Case "olive"
        ProcedureReturn $008080  
      Case "olivedrab"
        ProcedureReturn $238E6B
      Case "orange"
        ProcedureReturn $00A5FF
      Case "orangered"
        ProcedureReturn $0045FF
      Case "orchid"
        ProcedureReturn $D670DA
      Case "palegoldenrod"
        ProcedureReturn $AAE8EE
      Case "palegreen"
        ProcedureReturn $98FB98
      Case "paleturquoise"
        ProcedureReturn $EEEEAF
      Case "palevioletred"
        ProcedureReturn $9370DB
      Case "papayawhip"
        ProcedureReturn $D5EFFF
      Case "peachpuff"
        ProcedureReturn $B9DAFF
      Case "peru"
        ProcedureReturn $3F85CD
      Case "pink"
        ProcedureReturn $CBC0FF
      Case "plum"
        ProcedureReturn $DDA0DD
      Case "powderblue"
        ProcedureReturn $E6E0B0
      Case "purple"
        ProcedureReturn $800080
      Case "red"
        ProcedureReturn $0000FF
      Case "rosybrown"
        ProcedureReturn $8F8FBC
      Case "royalblue"
        ProcedureReturn $E16941
      Case "saddlebrown"
        ProcedureReturn $13458B
      Case "salmon"
        ProcedureReturn $7280FA
      Case "sandybrown"
        ProcedureReturn $60A4F4
      Case "seagreen"
        ProcedureReturn $578B2E
      Case "seashell"
        ProcedureReturn $EEF5FF
      Case "sienna"
        ProcedureReturn $2D52A0
      Case "silver"
        ProcedureReturn $C0C0C0
      Case "skyblue"
        ProcedureReturn $EBCE87
      Case "slateblue"
        ProcedureReturn $CD5A6A
      Case "slategray", "slategrey"
        ProcedureReturn $908070
      Case "snow"
        ProcedureReturn $FAFAFF
      Case "springgreen"
        ProcedureReturn $7FFF00
      Case "steelblue"
        ProcedureReturn $B48246
      Case "tan"
        ProcedureReturn $8CB4D2
      Case "teal"
        ProcedureReturn $808000
      Case "thistle"
        ProcedureReturn $D8BFD8
      Case "tomato"
        ProcedureReturn $4763FF
      Case "turquoise"
        ProcedureReturn $D0E040
      Case "violet"
        ProcedureReturn $EE82EE
      Case "wheat"
        ProcedureReturn $B3DEF5
      Case "white"
        ProcedureReturn $FFFFFF
      Case "whitesmoke"
        ProcedureReturn $F5F5F5
      Case "yellow"
        ProcedureReturn $00FFFF
      Case "yellowgreen"
        ProcedureReturn $32CD9A 
      Default
        ProcedureReturn #PB_Default
    EndSelect    
  EndProcedure  
  
  Procedure   TransformCoordinates(A.d, B.d, C.d, D.d, E.d, F.d, System.i=#PB_Coordinate_User)
	
  	; Single matrices:
  	;   Translation: {{1, 0, Tx}, {0, 1, Ty}, {0, 0, 1}}
  	;   Rotation:    {{Cos[Phi], -Sin[Phi], 0}, {Sin[Phi], Cos[Phi], 0}, {0, 0, 1}}
  	;   Skew:        {{1+Tan[ThetaX]*Tan[ThetaY], Tan[ThetaX], 0}, {Tan[ThetaY], 1, 0}, {0, 0, 1}}
  	;   Scale:       {{Sx, 0, 0}, {0, Sy, 0}, {0, 0, 1}}
  	; Transformation = Translation * Rotation * Skew * Scale
  	
  	; Transformation(A,B,C,D,E,F) -> Translation(Tx,Ty) * Rotation(Phi) * Skew(ThetaX,ThetaY) * Scale(Sx,Sy)
  	;   Simplification: ThetaY = 0, because ThetaY can be represented with ThetaX together with Scale and Rotation
  	
  	Protected Tx.d, Ty.d, Phi.d, ThetaX.d, Sx.d, Sy.d
  	Protected Column.d = 1.0 / Sqr( A*A + B*B ) 
  	
  	Tx       = E
  	Ty       = F
  	Sx       = A*A*Column + B*B*Column
  	Sy       = A*D*Column - B*C*Column
  	Phi.d    = Degree(ATan2(A*Column, B*Column))
  	ThetaX.d = Degree(ATan((-A*C-B*D)/(B*C-A*D)))
  	
  	TranslateCoordinates(Tx, Ty, System)
  	RotateCoordinates(0.0, 0.0, Phi, System)
  	SkewCoordinates(ThetaX, 0.0, System)
  	ScaleCoordinates(Sx, Sy, System)
  	
  EndProcedure
  
  ;- __________ Parsing __________
  
  Procedure.i Parse_Attribute_Color(String.s)
  	; http://www.w3.org/TR/2008/REC-SVGTiny12-20081222/painting.html#colorSyntax
  	Protected Color.s
  	
  	If RegEx\Color = #Null
  		RegEx\Color = CreateRegularExpression(#PB_Any, "((?<=\#)[0-9A-Fa-f]{3}\b) | ((?<=\#)[0-9A-Fa-f]{6}\b) | (rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)) | (rgb\(\s*(\d+\.?\d*)%\s*,\s*(\d+\.?\d*)%\s*,\s*(\d+\.?\d*)%\s*\))", #PB_RegularExpression_Extended)
  	EndIf
  	
  	If ExamineRegularExpression(RegEx\Color, String) And NextRegularExpressionMatch(RegEx\Color)
  		If RegularExpressionGroup(RegEx\Color, 1) ; Three digit hex - #rgb
  			Color.s = RegularExpressionGroup(RegEx\Color, 1)
  			ProcedureReturn RGB(Val("$"+Mid(Color,1,1))*17, Val("$"+Mid(Color,2,1))*17, Val("$"+Mid(Color,3,1))*17)
  		EndIf
  		If RegularExpressionGroup(RegEx\Color, 2) ; Six digit hex - #rrggbb
  			Color.s = RegularExpressionGroup(RegEx\Color, 2)
  			ProcedureReturn RGB(Val("$"+Mid(Color,1,2)), Val("$"+Mid(Color,3,2)), Val("$"+Mid(Color,5,2)))
  		EndIf
  		If RegularExpressionGroup(RegEx\Color, 3) ; Integer functional - rgb(rrr, ggg, bbb)
  			ProcedureReturn RGB(Val(RegularExpressionGroup(RegEx\Color, 4)), Val(RegularExpressionGroup(RegEx\Color, 5)), Val(RegularExpressionGroup(RegEx\Color, 6)))
  		EndIf
  		If RegularExpressionGroup(RegEx\Color, 7) ; Integer functional - rgb(rrr, ggg, bbb)
  			ProcedureReturn RGB(2.55*ValD(RegularExpressionGroup(RegEx\Color, 8)), 2.55*ValD(RegularExpressionGroup(RegEx\Color, 9)), 2.55*ValD(RegularExpressionGroup(RegEx\Color, 10)))
  		EndIf
  	EndIf

  	ProcedureReturn X11Color_(String)
  EndProcedure
  
  Procedure   Parse_Attribute_Transform(String.s)
  	; http://www.w3.org/TR/2008/REC-SVGTiny12-20081222/coords.html#TransformAttribute
  	Protected X.d, Y.d, Angle.d
  	Protected A.d, B.d, C.d, D.d, E.d, F.f
  	
  	If RegEx\Command = #Null
  		RegEx\Command = CreateRegularExpression(#PB_Any, "(\w+)\(([^\)]*)\)")
  	EndIf
  	If RegEx\Value = #Null
  		RegEx\Value = CreateRegularExpression(#PB_Any, "\-?\d+\.?\d*|\-?\.\d+")
  	EndIf
  	
  	If ExamineRegularExpression(RegEx\Command, String)
  		While NextRegularExpressionMatch(RegEx\Command)
  			Select LCase(RegularExpressionGroup(RegEx\Command, 1))
  				
  				Case "matrix"
  					If ExamineRegularExpression(RegEx\Value, RegularExpressionGroup(RegEx\Command, 2))
  						A = 0.0 : B = 0.0 : C = 0.0 : D = 0.0 : E = 0.0 : F = 0.0
  						If NextRegularExpressionMatch(RegEx\Value) : A = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : B = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : C = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : D = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : E = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : F = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						TransformCoordinates(A, B, C, D, E, F) ;: Debug "matrix("+StrD(A)+", "+StrD(B)+", "+StrD(C)+", "+StrD(D)+", "+StrD(E)+", "+StrD(F)+")"
  					EndIf
  					
  				Case "translate"
  					If ExamineRegularExpression(RegEx\Value, RegularExpressionGroup(RegEx\Command, 2))
  						X = 0.0 : Y = 0.0
  						If NextRegularExpressionMatch(RegEx\Value) : X = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : Y = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						TranslateCoordinates(X, Y) ;: Debug "translate("+StrD(X)+", "+StrD(Y)+")"
  					EndIf
  					
  				Case "scale"
  					If ExamineRegularExpression(RegEx\Value, RegularExpressionGroup(RegEx\Command, 2))
  						X = 0.0 : Y = 0.0
  						If NextRegularExpressionMatch(RegEx\Value) : X = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : Y = ValD(RegularExpressionMatchString(RegEx\Value)) : Else : Y = X : EndIf
  						ScaleCoordinates(X, Y) ;: Debug "scale("+StrD(X)+", "+StrD(Y)+")"
  					EndIf
  				
  				Case "rotate"
  					If ExamineRegularExpression(RegEx\Value, RegularExpressionGroup(RegEx\Command, 2))
  						X = 0.0 : Y = 0.0 : Angle = 0.0
  						If NextRegularExpressionMatch(RegEx\Value) : Angle = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : X = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						If NextRegularExpressionMatch(RegEx\Value) : Y = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						RotateCoordinates(X, Y, Angle) ;: Debug "rotate("+StrD(Angle)+", "+StrD(X)+", "+StrD(Y)+")"
  					EndIf
  					
  				Case "skewx"
  					If ExamineRegularExpression(RegEx\Value, RegularExpressionGroup(RegEx\Command, 2))
  						Angle = 0.0
  						If NextRegularExpressionMatch(RegEx\Value) : Angle = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						SkewCoordinates(Angle, 0) ;: Debug "skewX("+StrD(Angle)+")"
  					EndIf
  					
  				Case "skewy"
  					If ExamineRegularExpression(RegEx\Value, RegularExpressionGroup(RegEx\Command, 2))
  						Angle = 0.0
  						If NextRegularExpressionMatch(RegEx\Value) : Angle = ValD(RegularExpressionMatchString(RegEx\Value)) : EndIf
  						SkewCoordinates(0, Angle) ;: Debug "skewY("+StrD(Angle)+")"
  					EndIf
  				
  			EndSelect
  		Wend
  	EndIf
  	
  	ProcedureReturn ValD(String)
  	
  EndProcedure
  
  Procedure.d Parse_Attribute_Value(*Node, String.s="")
  	
  	If String = ""
  		String = XMLAttributeValue(*Node)
  	EndIf
  	
  	ProcedureReturn ValD(String)
  	
  EndProcedure  
  
  Procedure   Parse_Attribute_Style(String.s) ; , *Style.Style_Structure=#Null

  	If RegEx\Style = #Null
  		RegEx\Style = CreateRegularExpression(#PB_Any, "([\w\-]+)\s*\:\s*([^;]*);?")
  	EndIf
  	
  	;If Not *Style = #Null
  	;	*Style = SVG()\CurrentStyle
  	;EndIf
  	
  	With SVG()\CurrentStyle
  		If ExamineRegularExpression(RegEx\Style, String)
  			While NextRegularExpressionMatch(RegEx\Style)
  				Select LCase(RegularExpressionGroup(RegEx\Style, 1))
  					Case "opacity"
  						\Opacity     = Parse_Attribute_Value(#Null, RegularExpressionGroup(RegEx\Style, 2))
  					Case "fill"
  						\Fill        = Parse_Attribute_Color(RegularExpressionGroup(RegEx\Style, 2))
  					Case "fill-rule"
  						Select LCase(Trim(RegularExpressionGroup(RegEx\Style, 2)))
  							Case "nonzero"
  								\FillRule = #PB_Path_Winding
  							Case "evenodd"
  								\FillRule = #PB_Path_Default
  						EndSelect
  					Case "fill-opacity"
  						\FillOpacity = Parse_Attribute_Value(#Null, RegularExpressionGroup(RegEx\Style, 2))
  					Case "stroke"
  						\Stroke      = Parse_Attribute_Color(RegularExpressionGroup(RegEx\Style, 2))
  					Case "stroke-opacity"
  						\StrokeOpacity = Parse_Attribute_Value(#Null, RegularExpressionGroup(RegEx\Style, 2))
  					Case "stroke-width"
  						\StrokeWidth = Parse_Attribute_Value(#Null, RegularExpressionGroup(RegEx\Style, 2))
  					Case "stroke-linecap"
  						Select LCase(Trim(RegularExpressionGroup(RegEx\Style, 2)))
  							Case "butt"
  								\StrokeLineCap = #PB_Path_Default
  							Case "round"
  								\StrokeLineCap = #PB_Path_RoundEnd
  							Case "square"
  								\StrokeLineCap = #PB_Path_SquareEnd
  						EndSelect
  					Case "stroke-linejoin"
  						Select LCase(Trim(RegularExpressionGroup(RegEx\Style, 2)))
  							Case "miter"
  								\StrokeLineJoin = #PB_Path_Default
  							Case "round"
  								\StrokeLineJoin = #PB_Path_RoundCorner
  							Case "bevel"
  								\StrokeLineJoin = #PB_Path_DiagonalCorner
  						EndSelect
  				EndSelect
  			Wend
  		EndIf
  	EndWith
  	
  EndProcedure

  Procedure.d Parse_Attribute_Length(String.s, Reference.d=0.0)
  	Protected Value.d

  	If Not RegEx\Length
  		RegEx\Length = CreateRegularExpression(#PB_Any, "(\d+\.?\d*|\.\d+)\s*(px|in|cm|mm|pt|\%)?", #PB_RegularExpression_NoCase)
  	EndIf

  	If ExamineRegularExpression(RegEx\Length, String) And NextRegularExpressionMatch(RegEx\Length)
  	  
  	  Value = ValD(RegularExpressionGroup(RegEx\Length, 1))
  	 
  		Select LCase(RegularExpressionGroup(RegEx\Length, 2))
  			Case "px"
  				ProcedureReturn Value
  			Case "in"
  				ProcedureReturn Value * SVG()\ResX
  			Case "cm"
  				ProcedureReturn Value * SVG()\ResX / 2.54
  			Case "mm"
  				ProcedureReturn Value * SVG()\ResX / 25.4
  			Case "pt"
  				ProcedureReturn Value * SVG()\ResX / 72.0
  			Case "%"
  				ProcedureReturn Reference * Value / 100.0
  		EndSelect
  	EndIf
  	
  	ProcedureReturn Value
  	
  EndProcedure
  
  Procedure.s Parse_Attribute_String(*Node, String.s="")
  	
  	If String = ""
  		String = XMLAttributeValue(*Node)
  	EndIf
  	
  	ProcedureReturn String
  	
  EndProcedure
  
  Procedure.i Parse_Attribute_Presentation(*Node)

  	If RegEx\Value = #Null
  		RegEx\Value = CreateRegularExpression(#PB_Any, "\-?\d+\.?\d*|\-?\.\d+")
  	EndIf
  	
  	With SVG()\CurrentStyle
  		Select LCase(XMLAttributeName(*Node))
  			Case "transform"
  				Parse_Attribute_Transform(XMLAttributeValue(*Node))
  			Case "style"
  				Parse_Attribute_Style(XMLAttributeValue(*Node))
  			Case "opacity"
  				\Opacity = Parse_Attribute_Value(*Node)
  			Case "stroke"
  				\Stroke      = Parse_Attribute_Color(XMLAttributeValue(*Node))
  			Case "stroke-opacity"
  				\StrokeOpacity = Parse_Attribute_Value(*Node)
  			Case "stroke-width"
  				\StrokeWidth = Parse_Attribute_Value(*Node)
  			Case "stroke-linecap"
  				Select LCase(Trim(XMLAttributeValue(*Node)))
  					Case "butt"
  						\StrokeLineCap = #PB_Path_Default
  					Case "round"
  						\StrokeLineCap = #PB_Path_RoundEnd
  					Case "square"
  						\StrokeLineCap = #PB_Path_SquareEnd
  				EndSelect
  			Case "stroke-linejoin"
  				Select LCase(Trim(XMLAttributeValue(*Node)))
  					Case "miter"
  						\StrokeLineJoin = #PB_Path_Default
  					Case "round"
  						\StrokeLineJoin = #PB_Path_RoundCorner
  					Case "bevel"
  						\StrokeLineJoin = #PB_Path_DiagonalCorner
  				EndSelect
  			Case "stroke-dashoffset"
  				\StrokeDashOffset = Parse_Attribute_Value(*Node)
  			Case "stroke-dasharray"
  				If ExamineRegularExpression(RegEx\Value, XMLAttributeValue(*Node))
  					While NextRegularExpressionMatch(RegEx\Value)
  						If ArraySize(\StrokeDashArray()) = -1
  							Dim \StrokeDashArray(0)
  						Else
  							ReDim \StrokeDashArray(ArraySize(\StrokeDashArray())+1)
  						EndIf
  						\StrokeDashArray(ArraySize(\StrokeDashArray())) = ValD(RegularExpressionMatchString(RegEx\Value))
  					Wend
  				EndIf
  			Case "fill"
  				\Fill        = Parse_Attribute_Color(XMLAttributeValue(*Node))
  			Case "fill-opacity"
  				\FillOpacity = Parse_Attribute_Value(*Node)
  			Case "fill-rule"
  				Select LCase(Trim(XMLAttributeValue(*Node)))
  					Case "nonzero"
  						\FillRule = #PB_Path_Winding
  					Case "evenodd"
  						\FillRule = #PB_Path_Default
  				EndSelect
  		EndSelect
  	EndWith
  	
  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure   StyleSheets(Element.s="", Class.s="")
  	
  	With SVG()\CurrentStyle
  		
  		If Element And FindMapElement(SVG()\StyleSheet\Element(), Element) 
  			If FindMapElement(SVG()\StyleSheet\Element()\Class(), "")
  				Parse_Attribute_Style(SVG()\StyleSheet\Element()\Class()\Style)
  			EndIf
  			If Class And FindMapElement(SVG()\StyleSheet\Element()\Class(), Class)
  				Parse_Attribute_Style(SVG()\StyleSheet\Element()\Class()\Style)
  			EndIf
  		EndIf
  		If Class And FindMapElement(SVG()\StyleSheet\Element(), "") And FindMapElement(SVG()\StyleSheet\Element()\Class(), Class)
  			Parse_Attribute_Style(SVG()\StyleSheet\Element()\Class()\Style)
  		EndIf
  		
  	EndWith
  	
  EndProcedure
  
  Procedure   Rendering()
  	
  	With SVG()\CurrentStyle
  		
  		If \Opacity = 1.0
  			If \Fill <> -1
  				VectorSourceColor(\Fill | Int(255*\FillOpacity)<<24)
  				FillPath(\FillRule|#PB_Path_Preserve)
  			EndIf
  			If \Stroke <> -1
  				VectorSourceColor(\Stroke | Int(255*\StrokeOpacity)<<24)
  				If ArraySize(\StrokeDashArray()) <> -1
  					CustomDashPath(\StrokeWidth, \StrokeDashArray(), \StrokeLineCap|\StrokeLineJoin|#PB_Path_Preserve, \StrokeDashOffset)
  				Else
  					StrokePath(\StrokeWidth, \StrokeLineCap|\StrokeLineJoin|#PB_Path_Preserve)
  				EndIf
  			EndIf
  		ElseIf \Opacity > 0.0
  			BeginVectorLayer(255*\Opacity)
  			If \Fill <> -1
  				VectorSourceColor(\Fill | Int(255*\FillOpacity)<<24)
  				FillPath(\FillRule|#PB_Path_Preserve)
  			EndIf
  			If \Stroke <> -1
  				VectorSourceColor(\Stroke | Int(255*\StrokeOpacity)<<24)
  				If ArraySize(\StrokeDashArray()) <> -1
  					CustomDashPath(\StrokeWidth, \StrokeDashArray(), \StrokeLineCap|\StrokeLineJoin|#PB_Path_Preserve, \StrokeDashOffset)
  				Else
  					StrokePath(\StrokeWidth, \StrokeLineCap|\StrokeLineJoin|#PB_Path_Preserve)
  				EndIf
  			EndIf
  			EndVectorLayer()
  		EndIf
  		
  		ResetPath()
  	EndWith
  	
  EndProcedure
  
  Procedure   Draw_Group(*Node, Indent.i=0)
  	
  	Protected *ChildNode
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	BeginVectorLayer()
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "transform"
  					Parse_Attribute_Transform(XMLAttributeValue(*Node))
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	*ChildNode = ChildXMLNode(*Node)
  	While *ChildNode
  		Draw(*ChildNode, Indent+1)
  		*ChildNode = NextXMLNode(*ChildNode)
  	Wend
  	
  	EndVectorLayer()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Circle(*Node)
  	
  	Protected CX.d, CY.d, R.d
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("circle", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "cx"
  					CX = Parse_Attribute_Value(*Node)
  				Case "cy"
  					CY = Parse_Attribute_Value(*Node)
  				Case "r"
  					R = Parse_Attribute_Value(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	AddPathCircle(CX, CY, R)
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Ellipse(*Node)
  	
  	Protected CX.d, CY.d, RX.d, RY.d
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("ellipse", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "cx"
  					CX = Parse_Attribute_Value(*Node)
  				Case "cy"
  					CY = Parse_Attribute_Value(*Node)
  				Case "rx"
  					RX = Parse_Attribute_Value(*Node)
  				Case "ry"
  					RY = Parse_Attribute_Value(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	AddPathEllipse(CX, CY, RX, RY)
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Rectangle(*Node)
  	
  	Protected Width.d, Height.d, X.d=0.0, Y.d=0.0, RX.d=0.0, RY.d=0.0
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("rect", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "x"
  					X = Parse_Attribute_Value(*Node)
  				Case "y"
  					Y = Parse_Attribute_Value(*Node)
  				Case "width"
  					Width = Parse_Attribute_Value(*Node)
  				Case "height"
  					Height = Parse_Attribute_Value(*Node)
  				Case "rx"
  					RX = Parse_Attribute_Value(*Node)
  				Case "ry"
  					RY = Parse_Attribute_Value(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	If RX = 0.0 And RY = 0.0
  		AddPathBox(X, Y, Width, Height)
  	Else
  		If RX = 0.0 : RX = RY : EndIf
  		If RY = 0.0 : RY = RX : EndIf
  		If RX > Width/2 : RX = Width/2 : EndIf
  		If RY > Height/2 : RY = Height/2 : EndIf
  		If Width < 0 :  X + Width : Width = -Width : EndIf
  		If Height < 0 : Y + Height : Height = -Height : EndIf
  		MovePathCursor(X, Y+RY)
  		AddPathEllipse(RX, 0, RX, RY, 180, 270, #PB_Path_Relative)
  		AddPathEllipse(Width-2*RX, RY, RX, RY, 270, 360, #PB_Path_Relative|#PB_Path_Connected)
  		AddPathEllipse(-RX, Height-2*RY, RX, RY, 0, 90, #PB_Path_Relative|#PB_Path_Connected)
  		AddPathEllipse(-Width+2*RX, -RY, RX, RY, 90, 180, #PB_Path_Relative|#PB_Path_Connected)
  		ClosePath()
  	EndIf
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Line(*Node)
  	
  	Protected X1.d, Y1.d, X2.d, Y2.d
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("line", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "x1"
  					X1 = Parse_Attribute_Value(*Node)
  				Case "y1"
  					Y1 = Parse_Attribute_Value(*Node)
  				Case "x2"
  					X2 = Parse_Attribute_Value(*Node)
  				Case "y2"
  					Y2 = Parse_Attribute_Value(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	MovePathCursor(X1, Y1)
  	AddPathLine(X2, Y2)
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Text(*Node)
  	
  	Protected X.d, Y.d, Text.s
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("text", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	Text = GetXMLNodeText(*Node)
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "x"
  					X = Parse_Attribute_Value(*Node)
  				Case "y"
  					Y = Parse_Attribute_Value(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	MovePathCursor(X, Y)
  	AddPathText(Text)
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Polyline(*Node)
  	Protected Points.s, X.d, Y.d
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("polyline", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	If RegEx\Points = #Null
  		RegEx\Points = CreateRegularExpression(#PB_Any, "\-?\d+\.?\d*|\.\d+")
  	EndIf
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "points"
  					Points = Parse_Attribute_String(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	If ExamineRegularExpression(RegEx\Points, Points)
  		If NextRegularExpressionMatch(RegEx\Points) : X = ValD(RegularExpressionMatchString(RegEx\Points)) : EndIf
  		If NextRegularExpressionMatch(RegEx\Points) : Y = ValD(RegularExpressionMatchString(RegEx\Points)) : EndIf
  		MovePathCursor(X, Y)
  		Repeat
  			If NextRegularExpressionMatch(RegEx\Points) : X = ValD(RegularExpressionMatchString(RegEx\Points)) : Else : Break : EndIf
  			If NextRegularExpressionMatch(RegEx\Points) : Y = ValD(RegularExpressionMatchString(RegEx\Points)) : Else : Break : EndIf
  			AddPathLine(X, Y)
  		ForEver
  	EndIf
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Polygon(*Node)
  	Protected Points.s, X.d, Y.d
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("polygon", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	If RegEx\Points = #Null
  		RegEx\Points = CreateRegularExpression(#PB_Any, "\-?\d+\.?\d*")
  	EndIf
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "points"
  					Points = Parse_Attribute_String(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	If ExamineRegularExpression(RegEx\Points, Points)
  		If NextRegularExpressionMatch(RegEx\Points) : X = ValD(RegularExpressionMatchString(RegEx\Points)) : EndIf
  		If NextRegularExpressionMatch(RegEx\Points) : Y = ValD(RegularExpressionMatchString(RegEx\Points)) : EndIf
  		MovePathCursor(X, Y)
  		Repeat
  			If NextRegularExpressionMatch(RegEx\Points) : X = ValD(RegularExpressionMatchString(RegEx\Points)) : Else : Break : EndIf
  			If NextRegularExpressionMatch(RegEx\Points) : Y = ValD(RegularExpressionMatchString(RegEx\Points)) : Else : Break : EndIf
  			AddPathLine(X, Y)
  		ForEver
  		ClosePath()
  	EndIf
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Path(*Node)
  	
  	Protected Path.s
  	Protected PushedStyle.Style_Structure
  	
  	PushedStyle.Style_Structure = SVG()\CurrentStyle
  	SaveVectorState()
  	
  	StyleSheets("path", Trim(LCase(GetXMLAttribute(*Node, "class"))))
  	
  	If ExamineXMLAttributes(*Node)
  		While NextXMLAttribute(*Node)
  			Select LCase(XMLAttributeName(*Node))
  				Case "d"
  					Path = Parse_Attribute_String(*Node)
  				Default
  					Parse_Attribute_Presentation(*Node)
  			EndSelect
  		Wend
  	EndIf
  	
  	AddPathSegments(Path)
  	
  	Rendering()
  	
  	RestoreVectorState()
  	SVG()\CurrentStyle = PushedStyle
  	
  EndProcedure
  
  Procedure   Draw_Definition(*Node)
  	
  	Protected *ChildNode
  	
  	*ChildNode = ChildXMLNode(*Node)
  	While *ChildNode
  		Draw(*ChildNode)
  		*ChildNode = NextXMLNode(*ChildNode)
  	Wend
  	
  EndProcedure
  
  Procedure   Draw_Style(*Node)
  	Protected StyleSheet.s
  	Protected Element.s, Class.s, Style.s
  	
  	If RegEx\Definition = #Null
  		RegEx\Definition = CreateRegularExpression(#PB_Any, "(\w*)(?:\.(\w+))?\s*\{([^\}]*)\}")
  	EndIf
  	
  	If ChildXMLNode(*Node)
  		StyleSheet = GetXMLNodeText(ChildXMLNode(*Node))
  	Else
  		StyleSheet = GetXMLNodeText(*Node)
  	EndIf
  	
  	If ExamineRegularExpression(RegEx\Definition, StyleSheet)
  		While NextRegularExpressionMatch(RegEx\Definition)
  			Element = LCase(RegularExpressionGroup(RegEx\Definition, 1))
  			Class   = LCase(RegularExpressionGroup(RegEx\Definition, 2))
  			Style   = RegularExpressionGroup(RegEx\Definition, 3)
  			SVG()\StyleSheet\Element(Element)\Class(Class)\Style = Style
  		Wend
  	EndIf
  	
  EndProcedure
  
  Procedure   Draw(*Node, Indent.i=0)
  	Protected *ChildNode
  	
  	If XMLNodeType(*Node) = #PB_XML_Normal

  		Select LCase(GetXMLNodeName(*Node))
  			Case "circle"
  				Draw_Circle(*Node)
  			Case "ellipse"
  				Draw_Ellipse(*Node)
  			Case "rect"
  				Draw_Rectangle(*Node)
  			Case "line"
  				Draw_Line(*Node)
  			Case "polyline"
  				Draw_Polyline(*Node)
  			Case "polygon"
  				Draw_Polygon(*Node)
  			Case "path"
  				Draw_Path(*Node)
  			Case "text"
  				Draw_Text(*Node)
  			Case "g"
  				Draw_Group(*Node, Indent)
  			Case "defs"
  				Draw_Definition(*Node)
  			Case "style"
  			  Draw_Style(*Node)
  			Default
  				*ChildNode = ChildXMLNode(*Node)
  				While *ChildNode
  					Draw(*ChildNode, Indent + 1)
  					*ChildNode = NextXMLNode(*ChildNode)
  				Wend
  		EndSelect
  		
  	EndIf
  	
  EndProcedure
  
  Procedure   DrawSVGImage_(XML.i)
    Define.s Width$, Height$
    Define   *MainNode
    
  	With SVG()\CurrentStyle
  		\Opacity          = 1.0
  		\Fill             = $000000
  		\FillRule         = #PB_Path_Winding
  		\FillOpacity      = 1.0
  		\Stroke           = -1
  		\StrokeWidth      = 1.0
  		\StrokeLineCap    = #PB_Path_Default
  		\StrokeLineJoin   = #PB_Path_Default
  		FreeArray(\StrokeDashArray())
  		\StrokeDashOffset = 0.0
  		\StrokeOpacity    = 1.0
  	EndWith

  	If IsXML(XML)

  	  *MainNode = MainXMLNode(XML)  
  	  If *MainNode
  	    
      	;SVG()\Width  = Parse_Attribute_Length(GetXMLAttribute(*MainNode, "width"),  SVG()\Image\Width)
      	;SVG()\Height = Parse_Attribute_Length(GetXMLAttribute(*MainNode, "height"), SVG()\Image\Height)
  	    
      	BeginVectorLayer()
      	
      	If SVG()\ViewBox\State
      		ScaleCoordinates(SVG()\Image\Width / SVG()\ViewBox\Width, SVG()\Image\Height / SVG()\ViewBox\Height)
      		TranslateCoordinates(-SVG()\ViewBox\X, -SVG()\ViewBox\Y)
      		AddPathBox(SVG()\ViewBox\X, SVG()\ViewBox\Y, SVG()\ViewBox\Width, SVG()\ViewBox\Height)
      		ClipPath()
      	Else
      	  ScaleCoordinates(SVG()\Image\Width / SVG()\Width, SVG()\Image\Height / SVG()\Height)
      		AddPathBox(0, 0, SVG()\Width, SVG()\Height)
      		ClipPath()
      	EndIf
  	 
    	  Draw(*MainNode)

    	  EndVectorLayer()
    	  
    	EndIf
    	
  	EndIf
  	
  EndProcedure
  
  ;- __________ Tools __________  

  Procedure ParseViewBox(XML.i)
    Define.s viewBox$
    Define *MainNode
    
    If IsXML(XML)

    	*MainNode = MainXMLNode(XML)
    	If *MainNode
    	  
    	  viewBox$ = GetXMLAttribute(*MainNode, "viewBox")
    	  If viewBox$
    	    SVG()\ViewBox\X      = ValD(StringField(viewBox$, 1, " "))
    	    SVG()\ViewBox\Y      = ValD(StringField(viewBox$, 2, " "))
    	    SVG()\ViewBox\Width  = ValD(StringField(viewBox$, 3, " "))
    	    SVG()\ViewBox\Height = ValD(StringField(viewBox$, 4, " "))
    	    SVG()\Width          = Parse_Attribute_Length(GetXMLAttribute(*MainNode, "width"),  SVG()\ViewBox\Width)
    	    SVG()\Height         = Parse_Attribute_Length(GetXMLAttribute(*MainNode, "height"), SVG()\ViewBox\Height)
    	    If SVG()\Width = 0 Or SVG()\Height = 0
    	      SVG()\Width  = SVG()\ViewBox\Width
    	      SVG()\Height = SVG()\ViewBox\Height
    	    EndIf  
    	    SVG()\ViewBox\State  = #True
    	  Else
    	    SVG()\Width          = Parse_Attribute_Length(GetXMLAttribute(*MainNode, "width"))
    	    SVG()\Height         = Parse_Attribute_Length(GetXMLAttribute(*MainNode, "height"))
    	    SVG()\ViewBox\State  = #False
    	  EndIf

  		EndIf
  		
    EndIf
    
  EndProcedure
 
  Procedure AdjustSizeRatio()
    Define.f Factor, wFactor, hFactor
    
    If SVG()\Width = SVG()\Height
  
      If SVG()\Image\Height > SVG()\Image\Width
        SVG()\Image\Height = SVG()\Image\Width
      ElseIf SVG()\Image\Height < SVG()\Image\Width
        SVG()\Image\Width = SVG()\Image\Height
      EndIf

    Else
      
      wFactor = SVG()\Image\Width / SVG()\Width
      hFactor = SVG()\Image\Height/ SVG()\Height

      If hFactor > wFactor
        Factor = SVG()\Height / SVG()\Width
        SVG()\Image\Height = SVG()\Image\Width * Factor
      ElseIf hFactor < wFactor
        Factor = SVG()\Width / SVG()\Height
        SVG()\Image\Width = SVG()\Image\Height * Factor
      EndIf
 
    EndIf

  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure   DrawVector(Image.i, Width.d=0, Height.d=0, Flags.i=#False)
    ; Flags: #Proportional / #ForceSizeRatio
    Define.f Factor, wFactor, hFactor
    Define.i XML
    
    If FindMapElement(SVG(), Str(Image))

      SVG()\Image\Width  = Width
      SVG()\Image\Height = Height
      
      If Flags & #ForceSizeRatio = #False
        If SVG()\Flags & #Proportional Or Flags  & #Proportional
          AdjustSizeRatio()
        EndIf  
      EndIf
      
      XML = ParseXML(#PB_Any, SVG()\strgXML)
      If IsXML(XML)
        
        DrawSVGImage_(XML)

        FreeXML(XML)
      EndIf   

    EndIf
    
  EndProcedure
  
  
  Procedure.i Resize(Image.i, Width.d, Height.d, Flags.i=#False)
    ; Flags: #Proportional / #ForceSizeRatio
    Define.f Factor, wFactor, hFactor
    Define.i XML
    
    If FindMapElement(SVG(), Str(Image))
      
      If SVG()\Image\PB_Any 
        ; An image loaded with #PB_Any must be freed and recreated
        If IsImage(Image)
          If Flags & #KeepImage = #False : FreeImage(Image) : EndIf
        EndIf
        Image = CreateImage(#PB_Any, Width, Height, SVG()\Image\Depth, #PB_Image_Transparent)
      Else  
        CreateImage(Image, Width, Height, SVG()\Image\Depth, #PB_Image_Transparent)
      EndIf
    
      If IsImage(Image)
        
        SVG()\Image\Width  = Width
        SVG()\Image\Height = Height
        
        If Flags & #ForceSizeRatio = #False
          If SVG()\Flags & #Proportional Or Flags  & #Proportional
            AdjustSizeRatio()
          EndIf  
        EndIf
        
        XML = ParseXML(#PB_Any, SVG()\strgXML)
        If IsXML(XML)
          
          If StartVectorDrawing(ImageVectorOutput(Image))

            If SVG()\Image\BackColor <> #PB_Image_Transparent
              VectorSourceColor(SVG()\Image\BackColor)
              FillVectorOutput()
            EndIf
            
        		If IsFont(SVG()\Font) : VectorFont(FontID(SVG()\Font)) : EndIf 
        		
        		DrawSVGImage_(XML)
        		
            StopVectorDrawing()
          EndIf
          
          FreeXML(XML)
        EndIf   

      EndIf

    EndIf
    
    ProcedureReturn Image
  EndProcedure
  
  
  Procedure.i Catch(Image.i, svgXML.i, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0, Height.d=0, Font.i=#False)  
    ; Flags:     #Proportional / #CreateNoImage
    ; BackColor: #PB_Image_Transparent
    Define.f Factor, wFactor, hFactor
    Define.i Result, Depth, PB_Any

    If IsXML(svgXML)
      
      ;{ Create Image
      If #PB_Image_Transparent Or Alpha(BackColor)
        Depth  = 32
        Result = CreateImage(Image, 16, 16, 32, #PB_Image_Transparent)
      Else
        Depth  = 24
        Result = CreateImage(Image, 16, 16, 24)
      EndIf 
      
      If Image = #PB_Any
        Image = Result
        PB_Any = #True
      EndIf ;}

      If AddMapElement(SVG(), Str(Image))

        SVG()\strgXML = ComposeXML(svgXML)
        SVG()\Font    = Font
        SVG()\Flags   = Flags

        SVG()\Image\Num    = Image
        SVG()\Image\Width  = Width
        SVG()\Image\Height = Height
        SVG()\Image\Depth  = Depth
        SVG()\Image\PB_Any = PB_Any
      
        ;{ ---- Get Image Data -----
        If StartVectorDrawing(ImageVectorOutput(Image))
          
          SVG()\ResX = VectorResolutionX()
          SVG()\ResY = VectorResolutionY()
          
          ParseViewBox(svgXML)
          
          StopVectorDrawing()
        EndIf ;}
        
        If Flags & #CreateNoImage
          If IsImage(Image) : FreeImage(Image) : EndIf
        EndIf 
        
        If SVG()\Image\Width = 0 Or SVG()\Image\Height = 0
          SVG()\Image\Width  = SVG()\Width
          SVG()\Image\Height = SVG()\Height
        EndIf

        If Flags & #Proportional : AdjustSizeRatio() : EndIf  
        
        If IsImage(Image) And Flags & #CreateNoImage = #False
        
          If SVG()\Image\Width And SVG()\Image\Height
            ResizeImage(Image, SVG()\Image\Width, SVG()\Image\Height, #PB_Image_Raw)
          EndIf
          
          If StartVectorDrawing(ImageVectorOutput(Image))
          
            If BackColor = #PB_Image_Transparent ;{ Backcolor
              SVG()\Image\BackColor = #PB_Image_Transparent
            Else  
              
              If Alpha(BackColor) = #False
                SVG()\Image\BackColor = BackColor | 255 << 24
              Else
                SVG()\Image\BackColor = BackColor
              EndIf
 
              VectorSourceColor(SVG()\Image\BackColor)
              FillVectorOutput()
              
            EndIf ;}
            
        		If IsFont(SVG()\Font) : VectorFont(FontID(SVG()\Font)) : EndIf 
        		
        		DrawSVGImage_(svgXML)
        		
            StopVectorDrawing()
          EndIf
          
        EndIf
        
      EndIf

      FreeXML(svgXML)
    EndIf
    
    ProcedureReturn Result
  EndProcedure
    
  Procedure.i CatchString(Image.i, StringSVG.s, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0, Height.d=0, Font.i=#False)
    ; Flags:     #Proportional / #CreateNoImage
    ; BackColor: #PB_Image_Transparent
    Define.i XML, Result
    
    XML = ParseXML(#PB_Any, StringSVG)
    If IsXML(XML)
      Result = Catch(Image, XML, Flags, BackColor, Width, Height, Font)  
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i CatchMemory(Image.i, *MemorySVG, SizeSVG.i, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0, Height.d=0, Font.i=#False)
    ; Flags:     #Proportional / #CreateNoImage
    ; BackColor: #PB_Image_Transparent
    Define.i XML, Result
    
    XML = CatchXML(#PB_Any, *MemorySVG, SizeSVG)
    If IsXML(XML)
      Result = Catch(Image, XML, Flags, BackColor, Width, Height, Font)  
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i Load(Image.i, File.s, Flags.i=#False, BackColor.q=#PB_Image_Transparent, Width.d=0, Height.d=0, Font.i=#False)
    ; Flags:     #Proportional / #CreateNoImage
    ; BackColor: #PB_Image_Transparent
    Define.i XML, Result

    XML = LoadXML(#PB_Any, File)
    If IsXML(XML)
      Result = Catch(Image, XML, Flags, BackColor, Width, Height, Font)  
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  Define.i Image, Width, Height, xmlSVG
  Define.s SVG$
  Define.i quitWindow = #False
  
  #Example = 6
  
  ;  0: Load a SVG to the image gadget
  ;  1: Load a SVG to the image gadget (transparent)
  ;  2: Load adjusted image
  ;  3: Load & Resize
  ;  4: Load & Resize (#PB_Any)
  ;  5: Adjust size ratio 
  ;  6: SVG::Catch()
  ;  7: Load image form URL
  ; 10: Draw image on a CanvasGadget
 
  Enumeration
  	#Window
  	#Gadget
  	#Canvas
  	#Font
  	#Image
  	#Frame
  EndEnumeration

  LoadFont(#Font, "Arial", 8)
  
  If OpenWindow(#Window, 0, 0, 600, 600, "SVG Example", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
    
    ImageGadget(#Gadget, 10, 10, 580, 580, #False)
    FrameGadget(#Frame,   9,  9, 582, 582, "", #PB_Frame_Flat)
    
    CompilerSelect #Example
      CompilerCase 1 
        
        SVG::Load(#Image, "Test.svg", #False, #PB_Image_Transparent)
        SetGadgetState(#Gadget, ImageID(#Image))
        
      CompilerCase 2
        
        SVG::Load(#Image, "Test.svg", #False, $FFFFFF, 580, 580) ; SVG::#Proportional
        SetGadgetState(#Gadget, ImageID(#Image))
        
      CompilerCase 3
        
        SVG::Load(#Image, "Test.svg", #False, $FFFFFF)
        SVG::Resize(#Image, 480, 480)
        SetGadgetState(#Gadget, ImageID(#Image))
        
      CompilerCase 4  
        
        Image = SVG::Load(#PB_Any, "Test.svg", #False, $FFFFFF)
        Image = SVG::Resize(Image, 480, 480)
        SetGadgetState(#Gadget, ImageID(Image))
        
      CompilerCase 5   
        
        ; SVG::Load(#Image, "ReadingGirl.svg", #False, $FFFFFF, 580, 580) ; no adjust
        SVG::Load(#Image, "ReadingGirl.svg", SVG::#Proportional, $FFFFFF, 580, 580)
        
        SetGadgetState(#Gadget, ImageID(#Image))
        
      CompilerCase 6
        
        xmlSVG = LoadXML(#PB_Any, "Test.svg")
        If IsXML(xmlSVG)
          
          SVG::Catch(#Image, xmlSVG, #False, #PB_Image_Transparent)
          
          SetGadgetState(#Gadget, ImageID(#Image))
        EndIf  
        
      CompilerCase 7
        
        HideGadget(#Frame, #True)
        
        InitNetwork()
        
        SVG$ = PeekS(ReceiveHTTPMemory("https://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg"), -1, #PB_Ascii)
        
        SVG::CatchString(#Image, SVG$, #False, #PB_Image_Transparent, 580, 580)
        
        SetGadgetState(#Gadget, ImageID(#Image))  
        
      CompilerCase 10
        
        HideGadget(#Gadget, #True)
        
        CanvasGadget(#Canvas, 10, 10, 580, 580)
        
        SVG::Load(#Image, "ReadingGirl.svg", SVG::#CreateNoImage)
        
        If StartVectorDrawing(CanvasVectorOutput(#Canvas))
          
          SVG::DrawVector(#Image, 580, 580, SVG::#Proportional)
        
          StopVectorDrawing()
        EndIf
        
      CompilerDefault
        
        SVG::Load(#Image, "Test.svg", #False, $FFFFFFFF)
        SetGadgetState(#Gadget, ImageID(#Image))

    CompilerEndSelect
   
    Repeat
    	
    	Select WaitWindowEvent()
    		Case #PB_Event_CloseWindow
    			quitWindow = #True
    	EndSelect
    	
    Until quitWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 50
; Folding = AAAAAAAD-
; EnableXP
; DPIAware