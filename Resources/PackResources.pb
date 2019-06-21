;/ Created with PureVision v5.61
;/ Wed, 29 Nov 2017 13:12:10
;/ by Thorsten Hoeppner

#PackResource = #True

XIncludeFile "ResourcesModule.pbi"

EnableExplicit

UsePNGImageDecoder()

Global NewMap Files.s()

#ResPack = 1

#Window_Resource = 1

Enumeration 1
  #Gadget_FileList
  #Gadget_B_Delete
  #Gadget_B_Create
  #Gadget_B_Add
EndEnumeration

Enumeration 1
  #Image_B_Add
  #Image_B_Delete
  #Image_B_Create 
EndEnumeration

;{ ----- Load Resources -----
If Resource::Open(#ResPack, "PackResource.res")
  Resource::GetImage(#ResPack, #Image_B_Add,    "ADD.png")
  Resource::GetImage(#ResPack, #Image_B_Delete, "DEL.png")
  Resource::GetImage(#ResPack, #Image_B_Create, "OK.png")
  Resource::Close(#ResPack)
EndIf
;} --------------------------


Procedure.i Window_Resource()
  If OpenWindow(#Window_Resource,282,109,400,400,"Create resource file",#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
      ListIconGadget(#Gadget_FileList,10,10,380,350,"Filename",120,#PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
      AddGadgetColumn(#Gadget_FileList,1,"Path",256)
      ButtonImageGadget(#Gadget_B_Add,10,365,25,25,ImageID(#Image_B_Add))
        GadgetToolTip(#Gadget_B_Add,"Add file")      
      ButtonImageGadget(#Gadget_B_Delete,55,365,25,25,ImageID(#Image_B_Delete))
        GadgetToolTip(#Gadget_B_Delete,"Delete file")
      ButtonImageGadget(#Gadget_B_Create,365,365,25,25,ImageID(#Image_B_Create))
        GadgetToolTip(#Gadget_B_Create,"Create resource file")
      HideWindow(#Window_Resource,0)
    ProcedureReturn WindowID(#Window_Resource)
  EndIf
EndProcedure

Procedure RefreshList()
  ClearGadgetItems(#Gadget_FileList)
  ForEach Files()
    AddGadgetItem(#Gadget_FileList, -1, GetFilePart(Files())+#LF$+Files())
  Next
EndProcedure

;- Main Loop
If Window_Resource()
  Define quitWindow = #False
  Define Result$, File$, Item.i
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow ;{ Exit
        If EventWindow() = #Window_Resource
          quitWindow = #True
        EndIf ;}
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gadget_FileList
            Select EventType()
              Case #PB_EventType_LeftDoubleClick
              Case #PB_EventType_RightDoubleClick
              Case #PB_EventType_RightClick
              Default
            EndSelect
          Case #Gadget_B_Add
            File$ = OpenFileRequester("Please select file", "", "Resource files|*.*", 0, #PB_Requester_MultiSelection)
            While File$ 
              If AddMapElement(Files(), GetFilePart(File$))
                Files() = File$
              EndIf
              File$ = NextSelectedFileName()
            Wend
            RefreshList()
          Case #Gadget_B_Delete
            Item = GetGadgetState(#Gadget_FileList)
            If Item <> -1
              If FindMapElement(Files(), GetGadgetItemText(#Gadget_FileList, Item, 0))
                DeleteMapElement(Files())
              EndIf
              RefreshList()
            EndIf
          Case #Gadget_B_Create
            File$ = SaveFileRequester("Create Resource File", "", "Resource (*.res)|*.res", 0)
            If File$
              If PackResource::Open(File$, "Pack")
                ForEach Files()
                  PackResource::Add("Pack", Files())
                Next
                PackResource::Create("Pack")
                PackResource::Close("Pack")
              EndIf
            EndIf
        EndSelect
    EndSelect
  Until quitWindow
  CloseWindow(#Window_Resource)
EndIf
End

; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 33
; FirstLine = 20
; Folding = 4
; EnableXP
; UseIcon = Typicons_e061(0).ico
; Executable = PackResources.exe