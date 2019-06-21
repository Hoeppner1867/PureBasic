XIncludeFile "..\pbPDFModule.pbi"

Define File$="pbPDF-EmbedFile.pdf"

#PDF = 1

If PDF::Create(#PDF)

  PDF::AddPage(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "B", 16)
  
  PDF::Cell(#PDF, "Hello World!", 40, 10, #True)
  
  PDF::EmbedFile(#PDF, "20k_c1.txt")
  PDF::EmbedFile(#PDF, "20k_c2.txt")
  PDF::EmbedFile(#PDF, "PureBasic.png")
  
  PDF::Save(#PDF, File$)
  
EndIf

RunProgram(File$)
; IDE Options = PureBasic 5.70 LTS (Windows - x64)