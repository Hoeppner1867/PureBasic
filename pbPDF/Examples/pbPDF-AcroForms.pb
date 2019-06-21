XIncludeFile "..\pbPDFModule.pbi"

Define.s Options
Define File$="pbPDF-Acroforms.pdf"

#PDF = 1

If PDF::Create(#PDF)

  PDF::AddPage(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "B", 16) 
  PDF::Cell(#PDF, "PDF Forms (AcroForms)", #PB_Default, #PB_Default, #False, PDF::#NextLine, PDF::#CenterAlign)
  
  PDF::Ln(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "B", 11)  
  PDF::Cell(#PDF, "Text field (single line)", 80, 10, #False, PDF::#NextLine)
  
  PDF::SetFont(#PDF, "Arial", "", 11) 
  PDF::SetColorRGB(#PDF, PDF::#TextColor, 0, 0, 139)
  PDF::TextField(#PDF, "TextField 1", "Enter a single line of text.", PDF::#Form_Required|PDF::#Form_SingleLine, 80, 7, #True, PDF::#NextLine, PDF::#CenterAlign)
  
  PDF::Ln(#PDF)
  
  PDF::SetFont(#PDF, "Arial", "B", 11)
  PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
  PDF::Cell(#PDF, "Text field (multiple lines)", 80, 10, #False, PDF::#NextLine)
  
  PDF::SetFont(#PDF, "Arial", "", 11)
  PDF::TextField(#PDF, "TextField 2", "Enter multiple lines of Text.", PDF::#Form_MultiLine, 80, 15, PDF::#Border, PDF::#NextLine, PDF::#LeftAlign, #True)
  
  PDF::Ln(#PDF, 6)
  
  PDF::SetFont(#PDF, "Arial", "B", 11)
  PDF::Cell(#PDF, "Buttons", 80, 10, #False, PDF::#NextLine)
  
  PDF::ButtonField(#PDF, "CheckBox", #False, PDF::#Form_CheckBox, 4, 4)
  PDF::SetFont(#PDF, "Arial", "", 11)
  PDF::Cell(#PDF, " CheckBox", 10, 4, #False, PDF::#NextLine)
  
  PDF::Ln(#PDF)
  
  PDF::ButtonField(#PDF, "RadioButton", #False, PDF::#Form_RadioButton, 4, 4)
  PDF::Cell(#PDF, " RadioButton", 10, 5, #False, PDF::#NextLine)
 
  PDF::Ln(#PDF)
  
  Options = "Orange Apple Banana Pear Melon Cherry"
  
  PDF::SetFont(#PDF, "Arial", "B", 11)
  PDF::Cell(#PDF, "ComboBox", 80, 10, #False, PDF::#NextLine)
  PDF::SetFont(#PDF, "Arial", "", 11)
  PDF::ChoiceField(#PDF, "ChoiceField 1", "Banana", Options, 1, PDF::#Form_ComboBox , 40, 5, PDF::#NextLine)
  
  PDF::Close(#PDF, File$)
  
EndIf

RunProgram(File$)

; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 47
; EnableXP