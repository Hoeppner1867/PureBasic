XIncludeFile "..\pbPDFModule.pbi"

Define File$="pbPDF-EmbedFont.pdf"
Define Font$

#PDF = 1

If PDF::Create(#PDF)
  
  PDF::AddPage(#PDF)
  
  PDF::EmbedFont(#PDF, "Playball.ttf", "Playball")
  PDF::EmbedFont(#PDF, "l_10646.ttf", "LucidaSans", "", PDF::#Unicode)
  
  PDF::SetFont(#PDF, "Playball", "", 18)
  PDF::PlaceText(#PDF, "This is an embedded TrueType-font (Playball)", 10, 20) 
  
  PDF::SetFont(#PDF, "Playball", "U", 20)
  PDF::PlaceText(#PDF, "This is an embedded TrueType-font (Playball Underlined)", 10, 35) 
  
  PDF::SetFont(#PDF, "LucidaSans", "", 14)
  PDF::PlaceText(#PDF, "This is an embedded Unicode-font (LucidaSans)", 10, 50)
  
  PDF::SetFont(#PDF, "LucidaSans", "U", 11)
  PDF::PlaceText(#PDF, "This is an embedded Unicode-font  (LucidaSans Underlined)", 10, 60)
  
  PDF::Close(#PDF, File$)
  
EndIf

RunProgram(File$)
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 23
; DisablePurifier = 1,1,1,1