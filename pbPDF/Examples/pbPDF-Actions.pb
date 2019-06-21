XIncludeFile "..\pbPDFModule.pbi"

Define File$="pbPDF-Actions.pdf"
Define.i EmbedID, FileLinkID, TextLinkID, LaunchLinkID
#PDF = 1

If PDF::Create(#PDF)

  PDF::AddPage(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "U", 16)
  PDF::SetColorRGB(#PDF, PDF::#FillColor, 224, 235, 255)
  PDF::SetColorRGB(#PDF, PDF::#TextColor,   0,   0, 255)
  
  TextLinkID = PDF::AddTextNote(#PDF, "Text Annotation", "This is the text annotiation!", PDF::#NoteIcon)
  PDF::Cell(#PDF, "Show text annotation ", 80, 10, #True, PDF::#NextLine, PDF::#CenterAlign, #True, "", TextLinkID)
  
  PDF::Ln(#PDF)
 
  LaunchLinkID = PDF::AddLaunchAction(#PDF, "20k_c2.txt")
  PDF::Cell(#PDF, "Launch File", 80, 10, #True, PDF::#NextLine, PDF::#CenterAlign, #True, "", LaunchLinkID)
  
  PDF::Ln(#PDF)
  
  EmbedID    = PDF::EmbedFile(#PDF, "20k_c1.txt", "Area for attachments")
  FileLinkID = PDF::AddFileLink(#PDF, EmbedID, "20k_c1.txt", "Embedded File", PDF::#PaperClipIcon, 3, 6)
  PDF::Cell(#PDF, "This is a file annotation ", 80, 10, #True, PDF::#NextLine, PDF::#CenterAlign, #True, "", FileLinkID)
  
  PDF::Save(#PDF, File$)
  
EndIf

RunProgram(File$)
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 18
; EnableXP