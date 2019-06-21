XIncludeFile "..\pbPDFModule.pbi"

Define File$="pbPDF-PageFormat.pdf"

#PDF = 1

Procedure Header()
  PDF::SetFont(#PDF, "Arial","B", 15)
  PDF::SetPosX(#PDF, PDF::GetPageWidth(#PDF) / 2 - 15)
  PDF::Cell(#PDF, "Title", 30, 10, 1, 0, PDF::#CenterAlign)
  PDF::Ln(#PDF, 20)
EndProcedure

Procedure Footer()
  PDF::SetFont(#PDF, "Arial", "I", 8)
  PDF::SetPosY(#PDF, -15)
  PDF::Cell(#PDF, "Page {p} / {t}", #False, 10, #False, PDF::#Right, PDF::#CenterAlign)
EndProcedure

If PDF::Create(#PDF)
  
  PDF::SetAliasTotalPages(#PDF, "{t}")
  
  PDF::SetHeaderProcedure(#PDF, @Header())  
  PDF::SetFooterProcedure(#PDF, @Footer())

  PDF::AddPage(#PDF)

  PDF::SetFont(#PDF, "Arial", "B", 16)
  PDF::Cell(#PDF, StrF(PDF::GetPageWidth(#PDF), 0) + "x" + StrF(PDF::GetPageHeight(#PDF), 0) + " mm", 40, 10, #True)

  PDF::AddPage(#PDF, "L", PDF::#Format_A5)
  PDF::SetFont(#PDF, "Arial","B", 16)
  PDF::Cell(#PDF, StrF(PDF::GetPageWidth(#PDF), 0) + "x" + StrF(PDF::GetPageHeight(#PDF), 0) + " mm", 40, 10, #True)

  PDF::AddPage(#PDF, "P", PDF::#Format_A6)
  PDF::SetFont(#PDF, "Arial", "B", 16)
  PDF::Cell(#PDF, StrF(PDF::GetPageWidth(#PDF), 0) + "x" + StrF(PDF::GetPageHeight(#PDF), 0) + " mm", 40, 10, #True)
  
  PDF::Close(#PDF, File$)
EndIf

RunProgram(File$)
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 39
; Folding = -
; EnableXP