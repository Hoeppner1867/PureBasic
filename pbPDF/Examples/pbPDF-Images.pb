XIncludeFile "..\pbPDFModule.pbi"

Define LinkID.i, File$ = "pbPDF-Images.pdf"

#PDF = 1

If PDF::Create(#PDF)
  
  PDF::AddPage(#PDF)
  
  LinkID = PDF::AddLinkURL(#PDF, "https://www.purebasic.com/")
  
  PDF::Image(#PDF, "PureBasic.png", 10,  10, 30, 0, LinkID)
  PDF::Image(#PDF, "PureBasic.jpg", 10, 110, 60, 0, LinkID)
  PDF::Image(#PDF, "PureBasic.jp2", 10, 210, 80, 0, LinkID)
  
  PDF::Close(#PDF, File$)
EndIf

RunProgram(File$)
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 18