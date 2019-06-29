;-TOP
; Comment : Modul Timer for Gadget
; Author  : mk-soft
; Version : v1.04
; Create  : 16.06.2019
; Update  : 23.06.2019
; Link    : https://www.purebasic.fr/english/viewtopic.php?f=12&t=73031

; OS      : All

; *****************************************************************************

;- Begin Module GadgetTimer

DeclareModule GadgetTimer
  
  Declare AddGadgetTimer(Window, Gadget, EventType, Time, Count = 0)
  Declare RemoveGadgetTimer(Gadget, EventType = #PB_All)
  Declare StartGadgetTimer()
  Declare StopGadgetTimer()
  
EndDeclareModule

Module GadgetTimer
  
  EnableExplicit
  
  Structure udtGadgetTimer
    EventType.i
    Time.i
    Count.i
    StartTime.i
    Counter.i
  EndStructure
  
  Structure udtGadget
    Window.i
    Gadget.i
    Map Timer.udtGadgetTimer()
  EndStructure
  
  Structure udtData
    ThreadID.i
    Exit.i
  EndStructure
  
  
  Global NewMap Gadgets.udtGadget()
  Global Mutex = CreateMutex()
  Global thData.udtData
  
  Declare thGadgetTimer(*data.udtData)
  
  ; ----
  
  Procedure AddGadgetTimer(Window, Gadget, EventType, Time, Count = 0)
    With Gadgets()
      LockMutex(Mutex)
      If Not FindMapElement(Gadgets(), Hex(Gadget))
        AddMapElement(Gadgets(), Hex(Gadget))
      EndIf
      \Window = Window
      \Gadget = Gadget
      If AddMapElement(\Timer(), Hex(EventType))
        \Timer()\EventType = EventType
        \Timer()\Time = Time
        \Timer()\Count = Count
        \Timer()\StartTime = ElapsedMilliseconds()
        \Timer()\Counter = 1
      EndIf
      UnlockMutex(Mutex)
    EndWith
  EndProcedure
  
  ; ----
  
  Procedure RemoveGadgetTimer(Gadget, EventType = #PB_All)
    LockMutex(Mutex)
    If FindMapElement(Gadgets(), Hex(Gadget))
      If EventType = #PB_All
        DeleteMapElement(Gadgets())
      Else
        If FindMapElement(Gadgets()\Timer(), Hex(EventType))
          DeleteMapElement(Gadgets()\Timer())
          If MapSize(Gadgets()\Timer()) = 0
            DeleteMapElement(Gadgets())
          EndIf
        EndIf
      EndIf
    EndIf
    UnlockMutex(Mutex)
  EndProcedure
  
  ; ----
  
  Procedure StartGadgetTimer()
    With thData
      If Not IsThread(\ThreadID)
        \ThreadID = CreateThread(@thGadgetTimer(), @thData)
      EndIf
    EndWith
  EndProcedure
  
  ; ----
  
  Procedure StopGadgetTimer()
    Protected time
    With thData
      If IsThread(\ThreadID)
        time = ElapsedMilliseconds()
        \Exit = #True
        Delay(20)
        While IsThread(\ThreadID)
          If ElapsedMilliseconds() - time > 200
            KillThread(\ThreadID)
            Break
          EndIf
          Delay(50)
        Wend
      EndIf
      \ThreadID = 0
      \Exit = #False
    EndWith
  EndProcedure
  
  ; ----
  
  Procedure thGadgetTimer(*data.udtData)
    Protected time, difftime, eventtime
    Protected th_time, th_difftime, th_delay
    
    With Gadgets()
      While Not *data\Exit
        th_time = ElapsedMilliseconds()
        LockMutex(Mutex)
        time = ElapsedMilliseconds()
        ForEach Gadgets()
          If IsGadget(\Gadget)
            ForEach \Timer()
              difftime = time - \Timer()\StartTime
              eventtime = \Timer()\Time * \Timer()\Counter
              If difftime >= eventtime
                PostEvent(#PB_Event_Gadget, \Window, \Gadget, \Timer()\EventType, \Timer()\Counter)
                \Timer()\Counter + 1
              EndIf
              If \Timer()\Count > 0 And \Timer()\Counter > \Timer()\Count
                DeleteMapElement(Gadgets()\Timer())
                If MapSize(Gadgets()\Timer()) = 0
                  DeleteMapElement(Gadgets())
                  Break
                EndIf
              EndIf
            Next
          Else
            DeleteMapElement(Gadgets())
          EndIf
        Next
        UnlockMutex(Mutex)
        th_difftime = ElapsedMilliseconds() - th_time
        th_delay = 25 - th_difftime
        If th_delay < 0
          th_delay = 0
        EndIf
        Delay(th_delay)
      Wend
    EndWith   
  EndProcedure
  
EndModule

;- End Module GadgetTimer

; *****************************************************************************

;- Example

CompilerIf #PB_Compiler_IsMainFile
  
  UseModule GadgetTimer
  
  Enumeration #PB_EventType_FirstCustomValue
    #EventType_Timer1
    #EventType_Timer2
    #EventType_Timer3
    #EventType_Timer4
  EndEnumeration
  
  Enumeration FormWindow
    #Main
  EndEnumeration
  
  Enumeration FormGadget
    #ProgressBar
    #Canvas1
    #Canvas2
    #Text
    #Button0
    #Button1
    #Button2
    #Button3
  EndEnumeration
  
  Procedure OpenMain(x = 0, y = 0, width = 530, height = 170)
    OpenWindow(#Main, x, y, width, height, "Trigger for Gadgets", #PB_Window_SystemMenu)
    ProgressBarGadget(#ProgressBar, 10, 10, 510, 30, 0, 40)
    CanvasGadget(#Canvas1, 10, 50, 40, 40)
    CanvasGadget(#Canvas2, 60, 50, 40, 40)
    TextGadget(#Text, 110, 50, 410, 40, "Trigger Off", #PB_Text_Center)
    ButtonGadget(#Button0, 10, 110, 120, 40, "Progress")
    ButtonGadget(#Button1, 140, 110, 120, 40, "Canvas On")
    ButtonGadget(#Button2, 270, 110, 120, 40, "Canvas Off")
    ButtonGadget(#Button3, 400, 110, 120, 40, "Text", #PB_Button_Toggle)
  EndProcedure
  
  Procedure.i BlendColor(Color1.i, Color2.i, Scale.i = 50) ; Thanks to Thorsten
    Protected.i R1, G1, B1, R2, G2, B2
    Protected.f Blend = Scale / 100
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    ProcedureReturn RGB((R1*Blend) + (R2 * (1 - Blend)), (G1*Blend) + (G2 * (1 - Blend)), (B1*Blend) + (B2 * (1 - Blend)))
  EndProcedure
  
  Procedure DrawOn(Counter)
    Protected dx, dy, scale , color
    If StartDrawing(CanvasOutput(#Canvas1))
      scale = Counter * 4
      color = BlendColor(#Green, #Gray, scale)
      dx = GadgetWidth(#Canvas1)
      dy = GadgetHeight(#Canvas1)
      Box(0, 0, dx, dy, #Black)
      Box(1, 1, dx-2, dy-2, color)
      StopDrawing()
    EndIf
  EndProcedure
  
  Procedure DrawOff(Counter)
    Protected dx, dy, scale , color
    If StartDrawing(CanvasOutput(#Canvas1))
      scale = Counter * 4
      color = BlendColor(#Gray, #Green, scale)
      dx = GadgetWidth(#Canvas1)
      dy = GadgetHeight(#Canvas1)
      Box(0, 0, dx, dy, #Black)
      Box(1, 1, dx-2, dy-2, color)
      StopDrawing()
    EndIf
  EndProcedure
  
  Procedure Draw2(Counter)
    Protected dx, dy
    If StartDrawing(CanvasOutput(#Canvas2))
      scale = Counter * 4
      dx = GadgetWidth(#Canvas1)
      dy = GadgetHeight(#Canvas1)
      Box(0, 0, dx, dy, #Black)
      Box(1, 1, dx-2, dy-2, #Gray)
      Circle(dx/2, dy/2, dx/3, #Black)
      If Counter % 2
        Circle(dx/2, dy/2, dx/3-2, #Red)
      Else
        Circle(dx/2, dy/2, dx/3-2, #Gray)
      EndIf  
      StopDrawing()
    EndIf
  EndProcedure
  
  LoadFont(0, "Arial", 28, #PB_Font_Italic) 
  Global Dim Text.s(10)
  For i = 0 To 8
    Text(i) = "Count " + Str(i+1)
  Next
  Text(9) = "I like Purebasic!"
  
  Procedure Main()
    
    OpenMain()
    If IsWindow(#Main)
      
      DrawOn(0)
      Draw2(0)
      
      SetGadgetFont(#Text, FontID(0))
      
      StartGadgetTimer()
      
      Repeat
        Select WaitWindowEvent()
          Case #PB_Event_CloseWindow
            Break
          Case #PB_Event_Gadget
            Select EventGadget()
              Case #Button0
                AddGadgetTimer(#Main, #ProgressBar, #EventType_Timer1, 50, 40)
                RemoveGadgetTimer(#ProgressBar, #EventType_Timer3)
              Case #Button1
                RemoveGadgetTimer(#Canvas1)
                AddGadgetTimer(#Main, #Canvas1, #EventType_Timer1, 25, 25)
              Case #Button2
                RemoveGadgetTimer(#Canvas1)
                AddGadgetTimer(#Main, #Canvas1, #EventType_Timer2, 25, 25)
              Case #Button3
                If GetGadgetState(#Button3) = 1
                  AddGadgetTimer(#Main, #Text, #EventType_Timer1, 1000, 0)
                  AddGadgetTimer(#Main, #Canvas2, #EventType_Timer1, 500, 0)
                  SetGadgetText(#Text, "Trigger On")
                Else
                  RemoveGadgetTimer(#Text)
                  RemoveGadgetTimer(#Canvas2)
                  SetGadgetText(#Text, "Trigger Off")
                  draw2(0)
                EndIf
                
              Case #ProgressBar
                Select EventType()
                  Case #EventType_Timer1
                    SetGadgetState(#ProgressBar, EventData())
                EndSelect
              Case #Canvas1
                Select EventType()
                  Case #EventType_Timer1 : DrawOn(EventData())
                  Case #EventType_Timer2 : DrawOff(EventData())
                EndSelect
              Case #Canvas2
                If EventType() = #EventType_Timer1
                  Draw2(EventData()+1)
                EndIf
                
              Case #Text
                If EventType() = #EventType_Timer1
                  SetGadgetText(#Text, Text((EventData() - 1) % 10))
                EndIf
                
            EndSelect
            
        EndSelect
        
      ForEver
      
      StopGadgetTimer()
      
    EndIf
    
  EndProcedure : Main()
  
CompilerEndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 344
; Folding = 90-
; EnableXP
; DPIAware
