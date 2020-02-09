;/ ===========================
;/ =    EasyHelp - Viewer    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/  Gadget to display MarkDown languages
;/
;/ © 2020  by Thorsten Hoeppner (02/2020)
;/

; Last Update: 

;{ ===== Tea & Pizza Ware =====
; <purebasic@thprogs.de> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}

HelpFile$ = ProgramParameter(0)
Title$    = ProgramParameter(1)
Label$    = ProgramParameter(2)

XIncludeFile "ResizeExModule.pbi"
XIncludeFile "MarkDownModule.pbi"
XIncludeFile "TreeExModule.pbi"

EnableExplicit

UsePNGImageDecoder()
UseLZMAPacker()

;- __________ Constants __________

#JSON   = 1
#Pack   = 1

;{ Window Constants
Enumeration 1
  #Window_MarkDown
EndEnumeration
;}

;{ Gadget Constants
Enumeration 1

  ;{ #Window_MarkDown  
  #Gadget_MarkDown_Tree
  #Gadget_MarkDown_Viewer
  ;}

EndEnumeration
;}

;- __________ Fonts __________

;{ Font Constants

Enumeration 1
  #Font_Arial10
  #Font_Arial11
EndEnumeration  
;}
LoadFont(#Font_Arial10, "Arial", 10)
LoadFont(#Font_Arial11, "Arial", 11)

;- __________ Structures __________

Structure Topic_Structure ;{ Topic()\...
  Titel.s
  Label.s
  Text.s
  Level.i
EndStructure ;}
Global NewList Topic.Topic_Structure()

Global NewMap Label.i()
Global NewMap Image.i()

;- __________ Windows __________

Procedure.i Window_MarkDown()
  
  If OpenWindow(#Window_MarkDown, 0, 0, 630, 520, " EasyHelp", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered|#PB_Window_Invisible)

    If TreeEx::Gadget(#Gadget_MarkDown_Tree, 10, 10, 185, 500, "", #False, #Window_MarkDown)
      TreeEx::SetFont(#Gadget_MarkDown_Tree, FontID(#Font_Arial10))
    EndIf
    
    If MarkDown::Gadget(#Gadget_MarkDown_Viewer, 200, 10, 420, 500)
      MarkDown::SetFont(#Gadget_MarkDown_Viewer, "Arial", 11)
      MarkDown::SetMargins(#Gadget_MarkDown_Viewer, 10, 10)
    EndIf

    If Resize::AddWindow(#Window_MarkDown, 445, 330)
      Resize::AddGadget(#Gadget_MarkDown_Tree,        Resize::#Height)
      Resize::AddGadget(#Gadget_MarkDown_Viewer,      Resize::#Width|Resize::#Height)
    EndIf

    HideWindow(#Window_MarkDown, #False)
    
    ProcedureReturn WindowID(#Window_MarkDown)
  EndIf
  
EndProcedure

;- __________ Procedures __________

Procedure   SelectLink(Label.s)
  
  If FindMapElement(Label(), Label)
    
    If SelectElement(Topic(), Label())
      TreeEx::SetState(#Gadget_MarkDown_Tree, Label())
      Markdown::SetText(#Gadget_MarkDown_Viewer, Topic()\Text)
    EndIf
  
  EndIf  
  
EndProcedure  

Procedure   SelectEntry(Index.i)

  If Index >= 0
    
    If SelectElement(Topic(), Index)
      Markdown::SetText(#Gadget_MarkDown_Viewer, Topic()\Text)
    EndIf   
    
  EndIf  
  
EndProcedure

Procedure.s Load_(File$)
  Define.s FileName$
  Define.i Size
  Define   *Buffer
  
  If OpenPack(#Pack, File$, #PB_PackerPlugin_Lzma) ;{ unpack files
    
    If ExaminePack(#Pack)
      
      While NextPackEntry(#Pack)
        
        FileName$ = PackEntryName(#Pack)
        
        Size = PackEntrySize(#Pack, #PB_Packer_UncompressedSize)
        
        *Buffer = AllocateMemory(Size)
        If *Buffer
          If UncompressPackMemory(#Pack, *Buffer, Size, FileName$) <> -1
            Select FileName$
              Case "Help.json" ;{ Help file
                If CatchJSON(#JSON, *Buffer, Size)
                  ExtractJSONList(JSONValue(#JSON), Topic())
                  FreeJSON(#JSON)
                EndIf ;}
              Default          ;{ Image
                If AddMapElement(Image(), FileName$)
                  Image() = CatchImage(#PB_Any, *Buffer, Size)
                  Markdown::UseImage(#Gadget_MarkDown_Viewer, FileName$, Image())
                EndIf ;}
            EndSelect
          EndIf
          FreeMemory(*Buffer)
        EndIf
        
      Wend
      
    EndIf
    
    ClosePack(#Pack) ;}
  EndIf
  
  ForEach Topic()
    If Topic()\Label : Label(Topic()\Label) = ListIndex(Topic()) : EndIf
    TreeEx::AddItem(#Gadget_MarkDown_Tree, TreeEx::#LastRow, Topic()\Titel, Topic()\Label, #False, Topic()\Level)
  Next  
  
  If FirstElement(Topic())
    TreeEx::SetState(#Gadget_MarkDown_Tree, 0)
    Markdown::SetText(#Gadget_MarkDown_Viewer, Topic()\Text)
  EndIf  

EndProcedure

;- __________ Main - Loop __________

Define.s Link$
Define.i quitWindow = #False

If HelpFile$ = "" : HelpFile$ = "Help.mdh" : EndIf

Window::Load("EasyHelp.win")

If Window_MarkDown()
  
  If Title$ : SetWindowTitle(#Window_MarkDown, Title$) : EndIf
  
  Window::RestoreSize(#Window_MarkDown)
  
  Load_(HelpFile$)
  
  If Label$ : SelectLink(Label$) : EndIf
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow            ;{ Close Window
        Select EventWindow()
          Case #Window_MarkDown
            quitWindow = #True
        EndSelect ;}  
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gadget_MarkDown_Tree        ;{ Select entry
            Select EventType()
              Case TreeEx::#EventType_Row
                SelectEntry(EventData()) 
            EndSelect ;}
          Case #Gadget_MarkDown_Viewer      ;{ Links
            Select EventType()
              Case Markdown::#EventType_Link
                Link$ = MarkDown::EventValue(#Gadget_MarkDown_Viewer)
                If Left(Link$, 1) = "#"
                  SelectLink(LTrim(Link$, "#"))
                Else
                  RunProgram(Link$)
                EndIf  
            EndSelect ;}
        EndSelect
    EndSelect
  Until quitWindow
  
  Window::Save("EasyHelp.win")
  
  CloseWindow(#Window_MarkDown)
EndIf

End
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 210
; FirstLine = 88
; Folding = 6Cx
; EnableXP
; DPIAware
; UseIcon = EasyHelp.ico
; Executable = EasyHelp.exe