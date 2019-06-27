XIncludeFile "..\pbPDFModule.pbi"

Define File$="pbPDF-Watermark.pdf"
Define Text$, i.i

#PDF = 1

Procedure Header()
  
  PDF::SetFont(#PDF, "Arial", "B", 50)
  PDF::SetColorRGB(#PDF, PDF::#TextColor, 255, 192, 203)
  PDF::Rotate(#PDF, 45, 30, 190)
  PDF::PlaceText(#PDF, "W a t e r m a r k  D e m o", 30, 190)
  PDF::Rotate(#PDF, 0)
  
EndProcedure

PDF::HeaderProcedure(@Header())

If PDF::Create(#PDF)
  
  PDF::EnableHeader(#PDF)
  
  PDF::AddPage(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "", 12)
  
  Text$ = "PureBasic is a programming language based on established BASIC rules. The key features of PureBasic are portability "
  Text$ + "(Windows, AmigaOS and Linux are currently fully supported), the production of very fast and highly optimized executables "
  Text$ + "and, of course, the very simple BASIC syntax. PureBasic has been created for the beginner and expert alike. We have put "
  Text$ + "a lot of effort into its realization to produce a fast, reliable and system friendly language."
  
  For i = 1 To 15 
    PDF::Write(#PDF, Text$, 5) 
  Next 

  PDF::Close(#PDF, File$)
  
EndIf

RunProgram(File$)
; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x64)
; CursorPosition = 8
; FirstLine = 3
; Folding = -