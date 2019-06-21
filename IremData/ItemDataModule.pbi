;/ ==========================
;/ =   ItemDataModule.pbi   =
;/ ==========================
;/
;/ [ PB V5.7x / all OS / 64Bit ]
;/
;/ Module by Thorsten1867 (02/2019)
;/

; Last Update: 28.04.2019


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;}


DeclareModule Item
  
  Declare   SetData(GId.i, Index.i, Value.s)
  Declare.s GetData(GId.i, Index.i)
  Declare   RemoveData(GId.i)
  Declare   FreeData()
  
EndDeclareModule  


Module Item
  
  Structure Item_Structure
    Map Item.s()
  EndStructure
  Global NewMap IDEx.Item_Structure()

  Procedure SetData(GId.i, Index.i, Value.s)
    IDEx(Str(GId))\Item(Str(Index)) = Value
  EndProcedure
  
  Procedure.s GetData(GId.i, Index.i)
    ProcedureReturn IDEx(Str(GId))\Item(Str(Index))
  EndProcedure
  
  Procedure  RemoveData(GId.i)
    If FindMapElement(IDEx(), Str(GId))
      DeleteMapElement(IDEx())
    EndIf
  EndProcedure
  
  Procedure  FreeData()
    ClearMap(IDEx()) 
  EndProcedure
  
EndModule


CompilerIf #PB_Compiler_IsMainFile
  
  Item::SetData(0, 1, "A")
  Item::SetData(0, 2, "B")
  Item::SetData(0, 3, "C")
  
  Debug Item::GetData(0, 2)
CompilerEndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 39
; Folding = 7-
; EnableXP