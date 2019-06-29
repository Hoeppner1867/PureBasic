;-TOP

; Comment : Module System
; Author  : mk-soft
; Version : v1.04
; Create  : 30.03.2019
; Update  : 08.06.2019

; Link DE : https://www.purebasic.fr/german/viewtopic.php?f=8&t=31380
; Link EN : https://www.purebasic.fr/english/viewtopic.php?f=12&t=72980

; OS      : All

; *************************************************************************************************

DeclareModule System
  ;- Begin of Declare Module
  
  Declare WindowPB(WindowID)
  Declare GadgetPB(GadgetID)
  Declare ImagePB(ImageID)
  
  Declare GetParentWindowID(Gadget)
  Declare GetPreviousGadget(Gadget, WindowID)
  Declare GetNextGadget(Gadget, WindowID)
  
  Declare GetWindowList(List Windows())
  Declare GetGadgetList(List Gadgets(), WindowID=0)
  Declare GetImageList(List Images())
  Declare GetFontList(List Fonts())
  
  Declare MouseOver()
  
  ;- End of Declare Module
EndDeclareModule

; ---------------------------------------------------------------------------------------

Module System
  ;- Begin of Module
  
  EnableExplicit
  
  ;-- Import internal function
  
  ; Force Import Fonts
  Global __Dummy = LoadFont(#PB_Any, "", 9) : FreeFont(__Dummy)
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Import ""
      PB_Object_EnumerateStart( PB_Objects )
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      PB_Object_GetObject( PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      PB_Gadget_Objects.i
      PB_Image_Objects.i
      PB_Font_Objects.i
    EndImport
  CompilerElse
    ImportC ""
      PB_Object_EnumerateStart( PB_Objects )
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      PB_Object_GetObject( PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      PB_Gadget_Objects.i
      PB_Image_Objects.i
      PB_Font_Objects.i
    EndImport
  CompilerEndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    ; PB Interne Struktur Gadget MacOS
    Structure sdkGadget
      *gadget
      *container
      *vt
      UserData.i
      Window.i
      Type.i
      Flags.i
    EndStructure
  CompilerEndIf
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure WindowPB(WindowID) ; Find pb-id over handle
    Protected result, window
    result = -1
    PB_Object_EnumerateStart(PB_Window_Objects)
    While PB_Object_EnumerateNext(PB_Window_Objects, @window)
      If WindowID = WindowID(window)
        result = window
        Break
      EndIf
    Wend
    PB_Object_EnumerateAbort(PB_Window_Objects)
    ProcedureReturn result
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GadgetPB(GadgetID) ; Find pb-id over handle
    Protected result, gadget
    result = -1
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @gadget)
      If GadgetID = GadgetID(gadget)
        result = gadget
        Break
      EndIf
    Wend
    PB_Object_EnumerateAbort(PB_Gadget_Objects)
    ProcedureReturn result
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure ImagePB(ImageID) ; Find pb-id over handle
    Protected result, image
    result = -1
    PB_Object_EnumerateStart(PB_Image_Objects)
    While PB_Object_EnumerateNext(PB_Image_Objects, @image)
      If ImageID = ImageID(image)
        result = image
        Break
      EndIf
    Wend
    PB_Object_EnumerateAbort(PB_Image_Objects)
    ProcedureReturn result
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetParentWindowID(Gadget)
    Protected GadgetID, WindowID
    
    If IsGadget(Gadget)
      CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_MacOS
          Protected *Gadget.sdkGadget = IsGadget(Gadget)
          WindowID = WindowID(*Gadget\Window)
        CompilerCase #PB_OS_Linux
          GadgetID = GadgetID(Gadget)
          WindowID = gtk_widget_get_toplevel_ (GadgetID)
        CompilerCase #PB_OS_Windows
          GadgetID = GadgetID(Gadget)
          WindowID = GetAncestor_(GadgetID, #GA_ROOT)
      CompilerEndSelect
    EndIf
    ProcedureReturn WindowID
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetPreviousGadget(Gadget, WindowID)
    Protected object, prev_id, type
    
    prev_id = -1
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
      type = GadgetType(object)
      If type <> #PB_GadgetType_Text And type <> #PB_GadgetType_Frame
        If GetParentWindowID(object) = WindowID
          If gadget = object
            If prev_id >= 0
              PB_Object_EnumerateAbort(PB_Gadget_Objects)
              Break
            EndIf
          Else
            prev_id = object
          EndIf
        EndIf
      EndIf
    Wend
    ProcedureReturn prev_id
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetNextGadget(Gadget, WindowID)
    Protected object, next_id, type
    
    next_id = -1
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
      type = GadgetType(object)
      If type <> #PB_GadgetType_Text And type <> #PB_GadgetType_Frame
        If GetParentWindowID(object) = WindowID
          If next_id < 0
            next_id = object
          EndIf
          If gadget = object
            If PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
              If GetParentWindowID(object) = WindowID
                next_id = object
                PB_Object_EnumerateAbort(PB_Gadget_Objects)
                Break
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Wend
    ProcedureReturn next_id
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetWindowList(List Windows())
    Protected object
    ClearList(Windows())
    PB_Object_EnumerateStart(PB_Window_Objects)
    While PB_Object_EnumerateNext(PB_Window_Objects, @object)
      AddElement(Windows())
      Windows() = object
    Wend
    ProcedureReturn ListSize(Windows())
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetGadgetList(List Gadgets(), WindowID=0)
    Protected object
    ClearList(Gadgets())
    PB_Object_EnumerateStart(PB_Gadget_Objects)
    While PB_Object_EnumerateNext(PB_Gadget_Objects, @object)
      If WindowID = 0 Or GetParentWindowID(object) = WindowID
        AddElement(Gadgets())
        Gadgets() = object
      EndIf
    Wend
    ProcedureReturn ListSize(Gadgets())
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetImageList(List Images())
    Protected object
    ClearList(Images())
    PB_Object_EnumerateStart(PB_Image_Objects)
    While PB_Object_EnumerateNext(PB_Image_Objects, @object)
      AddElement(Images())
      Images() = object
    Wend
    ProcedureReturn ListSize(Images())
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetFontList(List Fonts())
    Protected object
    ClearList(Fonts())
    PB_Object_EnumerateStart(PB_Font_Objects)
    While PB_Object_EnumerateNext(PB_Font_Objects, @object)
      AddElement(Fonts())
      Fonts() = object
    Wend
    ProcedureReturn ListSize(Fonts())
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure MouseOver() ; Result handle
    Protected handle, window
    window = GetActiveWindow()
    If window < 0
      ProcedureReturn 0
    EndIf
    ; Get handle under mouse
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Protected pt.q
        GetCursorPos_(@pt)
        handle = WindowFromPoint_(pt)
        ; handle = WindowFromPoint_(DesktopMouseY() << 32 | DesktopMouseX())
      CompilerCase #PB_OS_MacOS
        Protected win_id, win_cv, pt.NSPoint
        win_id = WindowID(window)
        win_cv = CocoaMessage(0, win_id, "contentView")
        CocoaMessage(@pt, win_id, "mouseLocationOutsideOfEventStream")
        handle = CocoaMessage(0, win_cv, "hitTest:@", @pt)
      CompilerCase #PB_OS_Linux
        Protected desktop_x, desktop_y, *GdkWindow.GdkWindowObject
        *GdkWindow.GdkWindowObject = gdk_window_at_pointer_(@desktop_x,@desktop_y)
        If *GdkWindow
          gdk_window_get_user_data_(*GdkWindow, @handle)
        Else
          handle = 0
        EndIf
    CompilerEndSelect
    ProcedureReturn handle
  EndProcedure
  
  ; ---------------------------------------------------------------------------
  
EndModule

;- Example
CompilerIf #PB_Compiler_IsMainFile
  
  UseModule System
  
  Procedure CheckMouseOver()
    Static last_handle = 0
    Static last_gadget = -1
    
    Protected handle, gadget
    
    handle = MouseOver()
    If handle <> last_handle
      last_handle = handle
      If last_gadget >= 0
        Debug "Mouse leave gadget " + last_gadget
        last_gadget = -1
      EndIf
      If handle
        gadget = GadgetPB(handle)
        If gadget >= 0
          Debug "Mouse enter gadget " + gadget
          last_gadget = gadget
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  If OpenWindow(1, 0, 0, 222, 280, "ButtonGadgets", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ButtonGadget(0, 10, 10, 200, 20, "Standard Button")
    ButtonGadget(1, 10, 40, 200, 20, "Left Button", #PB_Button_Left)
    ButtonGadget(2, 10, 70, 200, 20, "Right Button", #PB_Button_Right)
    ButtonGadget(3, 10,100, 200, 60, "Multiline Button  (längerer Text wird automatisch umgebrochen)", #PB_Button_MultiLine)
    ButtonGadget(4, 10,170, 200, 20, "Toggle Button", #PB_Button_Toggle)
    ButtonImageGadget(5, 10, 200, 200, 60, LoadImage(2, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp"))
    
    handle = WindowID(1)
    Debug "Window = " + WindowPB(handle)
    
    NewList Gadgets()
    Debug "Count of Gadgegts = " + GetGadgetList(Gadgets())
    ForEach Gadgets()
      Debug "Text of Gadget " + Gadgets() + " = " + GetGadgetText(Gadgets())
    Next
    
    handle = GetParentWindowID(3)
    Debug "Parent window handle from gadget 3 = " + GetParentWindowID(3)
    Debug "PB WindowID from handle " + handle + " = " + WindowPB(handle)
    
    handle = GetGadgetAttribute(5, #PB_Button_Image)
    Debug "Image handle from gadget 5 = " + handle
    Debug "PB ImageID from handle " + handle + " = " + ImagePB(handle)
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          Break
        Default
          CheckMouseOver()
      EndSelect
    ForEver
    
  EndIf
CompilerEndIf
; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x64)
; CursorPosition = 9
; Folding = ---
; EnableXP
; DPIAware