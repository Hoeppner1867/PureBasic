;/ ===========================
;/ =    EasyHelp - Viewer    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ © 2020  by Thorsten Hoeppner (02/2020)
;/

; Last Update: 09.02.2020

;{ ===== Tea & Pizza Ware =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}

XIncludeFile "TreeExModule.pbi"
XIncludeFile "MarkDownModule.pbi"

HelpFile$ = ProgramParameter(0)
Title$    = ProgramParameter(1)
Label$    = ProgramParameter(2)

If Title$ = "" : Title$ = "EasyHelp" : EndIf 

If HelpFile$ = "" : HelpFile$ = "Help.mdh" : EndIf

Markdown::Help(Title$, HelpFile$, Label$, Markdown::#AutoResize)

End
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 21
; Folding = +
; EnableXP
; DPIAware
; UseIcon = EasyHelp.ico
; Executable = EasyHelp.exe