;/ =================================
;/ =    SpellCheck - Module.pbi    =
;/ =================================
;/
;/ [ PB V5.7x / 64Bit / All OS ]
;/
;/ SpellCheck - Modul
;/
;/ © 2019 Thorsten1867 (06/2019)
;/

; Last Update: 27.07.2019
;
; Added: correction suggestions on the basis of  the 'Damerau-Levenshtein-Distance'
;

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

;{ _____ SpellCheck - Commands _____

; SpellCheck::AddToUserDictionary()   - add a word to the user dictionary
; SpellCheck::ClearCheckedWords()     - clears all check words from map
; SpellCheck::CorrectionSuggestions() - returns a list with correction suggestions (Damerau-Levenshtein-Distance)
; SpellCheck::FreeDictionary()        - removes dictionary from memory
; SpellCheck::LoadDictionary()        - loads a dictionary
; SpellCheck::Query()                 - returns whether a word is right, misspelled or unknown.
; SpellCheck::SaveUserDictionary()    - saves user dictionary
; SpellCheck::Text()                  - checks a text for spelling mistakes
; SpellCheck::Word()                  - checks if a word is spelled correctly

;}

DeclareModule SpellCheck
  
  #Version  = 19072700
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants
  ;- =========================================================================== 
  
  Enumeration
    #Unknown
    #Correct
    #Misspelled
  EndEnumeration
 
  ;- ===========================================================================
  ;-   DeclareModule
  ;- =========================================================================== 
  
  Declare   AddToUserDictionary(Word.s)
  Declare   ClearCheckedWords()
  Declare.i CorrectionSuggestions(Word.s, List Suggestions.s())
  Declare   FreeDictionary()
  Declare.i LoadDictionary(DicFile.s, AddDicFile.s="")
  Declare.i Query(Word.s)
  Declare   SaveUserDictionary(Path.s="")
  Declare.i Text(Text.s, List Wrong.s())
  Declare.i Word(Word.s)
  
EndDeclareModule

Module SpellCheck
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================  
  
  #File = 1

  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure Dictionary_Structure
    Stem.s
    Endings.s
    Flag.i
  EndStructure
  
  Global DicPath.s
  Global NewList Dictionary.Dictionary_Structure()
  Global NewList UserDic.Dictionary_Structure()
  Global NewMap  Words.i()
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Procedure.s UCase_(Word.s)
    ProcedureReturn UCase(Left(Word, 1)) + Mid(Word, 2)
  EndProcedure
  
  Procedure.i SearchFirstLetter(Char.s)
    Define.i ListPos, StartPos, EndPos
    
    StartPos = 0
    EndPos   = ListSize(Dictionary()) - 1
    
    Char = LCase(Left(Char, 1))
    
    Repeat
      ListPos = StartPos + Round((EndPos - StartPos)  / 2, #PB_Round_Up)
      If SelectElement(Dictionary(), ListPos)
        If Char = Left(Dictionary()\Stem, 1)
          Break
        ElseIf Char < Left(Dictionary()\Stem, 1)
          EndPos   = ListPos - 1
        ElseIf Char > Left(Dictionary()\Stem, 1)
          StartPos = ListPos + 1
        EndIf  
      EndIf
    Until (EndPos - StartPos) < 0
    
    While PreviousElement(Dictionary())
      If Char <> Left(Dictionary()\Stem, 1)
        ProcedureReturn ListIndex(Dictionary()) + 1
      EndIf
    Wend
    
    ProcedureReturn ListIndex(Dictionary())
  EndProcedure
  
  Procedure.s GetWord_(Word.s)
    Define i.i, Char$, Diff1$, Diff2$
    
    For i=1 To 2
      Char$ = Left(Word, 1)
      Select Char$
        Case "{", "[", "(", "<"
          Word = LTrim(Word, Char$)
          Diff1$ + Char$
        Case Chr(34), "«", "»" ; "'", 
          Word = LTrim(Word, Char$)
          Diff1$ + Char$
        Default
          Break
      EndSelect
    Next
    
    For i=1 To 2
      Char$ = Right(Word, 1)
      Select Char$
        Case ".", ":", ",", ";", "!", "?"
          Word = RTrim(Word, Char$)
          Diff2$ + Char$
        Case  ")", "]", "}", ">"
          Word = RTrim(Word, Char$)
          Diff2$ + Char$
        Case Chr(34), "«", "»" ; "'", 
          Word = RTrim(Word, Char$)
          Diff2$ + Char$ 
        Case " "
          Word = LTrim(Word, Char$)
        Default
          Break
      EndSelect
    Next

    ProcedureReturn Word
  EndProcedure
  
  Procedure.i SpellCheckEndings_(Position.i, Word.s, Length.i=4)
    Define.i i, StartPos, Count
    Define.s Pattern$ = LCase(Left(Word, Length))
    NewMap CheckWords.i()
    
    ;{ Search starting position
    StartPos = Position
    While PreviousElement(Dictionary())
      If Left(Dictionary()\Stem, Length) <> Pattern$ : Break : EndIf
      StartPos - 1
    Wend ;}
    
    ;{ Search to end position & expand endings
    If SelectElement(Dictionary(), StartPos)
      Repeat
        If Left(Dictionary()\Stem, Length) <> Pattern$ : Break : EndIf
        CheckWords(Dictionary()\Stem) = Dictionary()\Flag
        If Dictionary()\Endings
          Count = CountString(Dictionary()\Endings, "|") + 1
          For i=1 To Count
            CheckWords(Dictionary()\Stem + StringField(Dictionary()\Endings, i, "|")) = Dictionary()\Flag
          Next
        EndIf
      Until NextElement(Dictionary()) = #False
    EndIf ;}
    
    If FindMapElement(CheckWords(), LCase(Word))
      If CheckWords() ; Upper case required
        If Left(Word, 1) = UCase(Left(Word, 1))
          ProcedureReturn #True
        EndIf
      Else            ; No capitalization required
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SpellCheckWord_(Word.s)
    Define.i ListPos, StartPos, EndPos
    Define.s LWord$ = LCase(Word)
    
    StartPos = 0
    EndPos   = ListSize(Dictionary()) - 1
    
    Repeat
      ListPos = StartPos + Round((EndPos - StartPos)  / 2, #PB_Round_Up)
      If SelectElement(Dictionary(), ListPos)
        If Dictionary()\Stem  = LWord$                      ;{ direct hit
          If Dictionary()\Flag ; Upper case required
            If Left(Word, 1) = UCase(Left(Word, 1))
              ProcedureReturn #True
            Else
              ProcedureReturn #False
            EndIf
          Else           ; No capitalization required
            ProcedureReturn #True
          EndIf ;}
        ElseIf Left(LWord$, 4) < Left(Dictionary()\Stem, 4) ;{ word smaller than current word
          EndPos   = ListPos - 1
          ;}
        ElseIf Left(LWord$, 4) > Left(Dictionary()\Stem, 4) ;{ word greater than current word
          StartPos = ListPos + 1
          ;}
        Else                                          ;{ Search by word endings
          If SpellCheckEndings_(ListPos, Word)
            ProcedureReturn #True
          Else
            ProcedureReturn #False
          EndIf ;}
        EndIf
      EndIf
    Until (EndPos - StartPos) < 0
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure   SpellChecking_(Word.s)
    Define.s Word$
    
    If FindMapElement(Words(), Word)

      Select Words()
        Case #Correct
          ProcedureReturn #True
        Case #Misspelled
          ProcedureReturn #False
        Default
          If SpellCheckWord_(MapKey(Words()))
            Words() = #Correct
            ProcedureReturn #True
          Else
            Words() = #Misspelled
            ProcedureReturn #False
          EndIf
      EndSelect
      
    Else
      
      If AddMapElement(Words(), Word)
        If SpellCheckWord_(Word)
          Words() = #Correct
          ProcedureReturn #True
        Else
          Words() = #Misspelled
          ProcedureReturn #False
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure

  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure   AddToUserDictionary(Word.s)
      
    If SpellCheckWord_(Word) = #False
      
      If AddElement(UserDic())
        UserDic()\Stem    = LCase(Word)
        UserDic()\Endings = ""
        If Left(Word, 1) = UCase(Left(Word, 1))
          UserDic()\Flag  = #True
        Else
          UserDic()\Flag  = #False
        EndIf
      EndIf
      
      If AddElement(Dictionary())
        Dictionary()\Stem    = LCase(Word)
        Dictionary()\Endings = ""
        If Left(Word, 1) = UCase(Left(Word, 1))
          Dictionary()\Flag  = #True
        Else
          Dictionary()\Flag  = #False
        EndIf
      EndIf
      
      SortStructuredList(Dictionary(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))
      
    EndIf
    
  EndProcedure
  
  Procedure   ClearCheckedWords()
    ClearMap(Words())
  EndProcedure
  
  Procedure   FreeDictionary()
    ClearList(Dictionary())
  EndProcedure 
  
  Procedure.i LoadDictionary(DicFile.s, AddDicFile.s="")
    Define Word$
    
    ClearList(Dictionary())
    
    DicPath = GetPathPart(DicFile)
    
    If ReadFile(#File, DicFile)
      While Eof(#File) = #False
        Word$ = ReadString(#File)
        AddElement(Dictionary())
        Dictionary()\Stem = StringField(Word$, 1, Chr(127))
        If CountString(Word$, Chr(127)) = 2
          Dictionary()\Endings = StringField(Word$, 2, Chr(127))
          Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
        Else
          Dictionary()\Endings = ""
          Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
        EndIf
      Wend
      CloseFile(#File)
    EndIf
    
    If AddDicFile
      
      If ReadFile(#File, AddDicFile)
        While Eof(#File) = #False
          Word$ = ReadString(#File)
          AddElement(Dictionary())
          Dictionary()\Stem = StringField(Word$, 1, Chr(127))
          If CountString(Word$, Chr(127)) = 2
            Dictionary()\Endings = StringField(Word$, 2, Chr(127))
            Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
          Else
            Dictionary()\Endings = ""
            Dictionary()\Flag    = Val(StringField(Word$, 3, Chr(127)))
          EndIf
        Wend
        CloseFile(#File)
      EndIf
    EndIf
    
    ;{ Dictionary is required
    If ListSize(Dictionary()) = 0
      Debug "ERROR: No dictionary found"
      ProcedureReturn #False
    EndIf ;}
    
    ClearList(UserDic())
    
    If ReadFile(#File, DicPath + "user.dic")
      While Eof(#File) = #False
        Word$ = ReadString(#File)
        AddElement(UserDic())
        UserDic()\Stem = StringField(Word$, 1, Chr(127))
        If CountString(Word$, Chr(127)) = 2
          UserDic()\Endings = StringField(Word$, 2, Chr(127))
          UserDic()\Flag    = Val(StringField(Word$, 3, Chr(127)))
        Else
          UserDic()\Endings = ""
          UserDic()\Flag    = Val(StringField(Word$, 3, Chr(127)))
        EndIf
      Wend
      
      MergeLists(UserDic(), Dictionary())
      
      CloseFile(#File)
    EndIf
    
    SortStructuredList(Dictionary(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))  
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i Query(Word.s) ; [#Unknown / #Correct / #Misspelled]
    
    If FindMapElement(Words(), Word)
      ProcedureReturn Words()
    EndIf
    
    ProcedureReturn #Unknown
  EndProcedure
  
  Procedure   SaveUserDictionary(Path.s="")
    Define.s File$, Word$
    
    If Path = "" : Path = DicPath : EndIf
    File$ = Path + "user.dic"
    
    If ListSize(UserDic()) = 0 : ProcedureReturn #False : EndIf
    
    If CreateFile(#File, File$)
      
      SortStructuredList(UserDic(), #PB_Sort_Ascending, OffsetOf(Dictionary_Structure\Stem), TypeOf(Dictionary_Structure\Stem))
      
      ForEach UserDic()
        Word$ = UserDic()\Stem + Chr(127) + UserDic()\Endings + Chr(127) + UserDic()\Flag
        WriteStringN(#File, Word$, #PB_UTF8)
      Next
      
      CloseFile(#File)
    EndIf
    
  EndProcedure
 
  Procedure.i CorrectionSuggestions(Word.s, List Suggestions.s())
    Define.i i, Index, UCase, Count
    Define.s FirstChar, dicWord$
    
    FirstChar = Left(Word, 1)
    
    If FirstChar = UCase(FirstChar) : UCase = #True : EndIf
    
    ClearList(Suggestions())
    
    Index = SearchFirstLetter(FirstChar)
    If SelectElement(Dictionary(), Index)
      
      Repeat

        If Left(Dictionary()\Stem, 1) <> LCase(FirstChar) : Break : EndIf
        
        If Dictionary()\Flag = 1 And UCase = #False
          Continue
        EndIf
        
        If UCase
          dicWord$ = UCase_(Dictionary()\Stem)
        Else
          dicWord$ = Dictionary()\Stem
        EndIf
        
        If DamerauLevenshteinDistance(Word, dicWord$) = 1
          
          AddElement(Suggestions())
          Suggestions() = dicWord$
         
        EndIf  
        
        If Dictionary()\Endings
          
          Count = CountString(Dictionary()\Endings, "|") + 1
          
          For i=1 To Count
            
            If DamerauLevenshteinDistance(Word, dicWord$ + StringField(Dictionary()\Endings, i, "|")) = 1
              
              AddElement(Suggestions())
              Suggestions() = dicWord$ + StringField(Dictionary()\Endings, i, "|")
              
            EndIf
            
          Next
          
        EndIf
        
      Until NextElement(Dictionary()) = #False
      
    EndIf
    
  EndProcedure
  
  Procedure.i Text(Text.s, List Wrong.s())
    Define.i s, Spaces
    Define.s Word
    
    Text = ReplaceString(Text, #CRLF$, " ")
    Text = ReplaceString(Text, #LF$, " ")
    Text = ReplaceString(Text, "  ", " ")
    
    Spaces = CountString(Text, " ")
    
    For s=1 To Spaces + 1
      
      Word = GetWord_(StringField(Text, s, " "))
      
      If SpellChecking_(Word) = #False
        If AddElement(Wrong())
          Wrong() = Word
        EndIf
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure.i Word(Word.s)
    
    If FindMapElement(Words(), Word)
      
      ProcedureReturn Words()
    Else
      
      If AddMapElement(Words(), Word)
        
        If SpellChecking_(Word)
          Words() = #Correct
        Else
          Words() = #Misspelled
        EndIf
        
        ProcedureReturn Words()
      EndIf 
    
    EndIf
    
    ProcedureReturn #Unknown
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration 1
    #Deutsch
    #English
    #French
  EndEnumeration

  Enumeration 
    #Window
    #Button1
    #Button2
    #Word
    #Editor
    #List
  EndEnumeration
  
  NewList WrongWords.s()
  NewList Suggestions.s()
  
  ; ===========================
  Language.i = #Deutsch
  ; ===========================
  
  Select Language
    Case #Deutsch
      Text$ = "Die Schule ist ein schönes Ding. Man braucht sie, das ist wahr. Auf einem umgestürzten Baum saß eine Affenschar. Man hatte sie dorthin geschickt, zu bilden den Verstand. Der Lehrer war drei Tonnen schwer, ein gescheiter Elefant. Der Lehrer nahm mit seinem Rüssel die Schüler bei den Ohren. Sie lernten nichts, sie lärmten nur, alle Mühe war verloren."
      SpellCheck::LoadDictionary("german.dic")
      ;SpellCheck::AddToUserDictionary("Rüssel")
      ;SpellCheck::AddToUserDictionary("Affenschar")
    Case #English
      Text$ = "School is a beautiful thing. You need it, that's true. There was a group of monkeys sitting on a fallen tree. They had been sent there to make up the mind. The teacher was three tons heavy, a clever elephant. The teacher took the students by the ears with his trunk. They didn't learn anything, they just made noise, all effort was lost."
      SpellCheck::LoadDictionary("english.dic")
    Case #French
      Text$ = "L'école est une belle chose. Tu en as besoin, c'est vrai. Sur un arbre tombé, un troupeau de singes était assis. Ils avaient été envoyés là-bas pour se décider. Le professeur pesait trois tonnes, un éléphant intelligent. Le professeur a pris les élèves par les oreilles avec son coffre. Ils n'ont rien appris, ils ont juste fait du bruit, tous les efforts ont été perdus."
      SpellCheck::LoadDictionary("french.dic")
      ;SpellCheck::AddToUserDictionary("L'école")
      ;SpellCheck::AddToUserDictionary("là-bas")
      ;SpellCheck::AddToUserDictionary("n'ont")
  EndSelect
  
  If OpenWindow(#Window, 0, 0, 280, 220, "Example", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    StringGadget(#Word, 10, 10, 100, 20, "")
    ButtonGadget(#Button1, 120, 10, 60, 20, "Check")
    
    EditorGadget(#Editor,   10, 50, 170, 160, #PB_Editor_WordWrap)
    ListViewGadget(#List,  190, 50, 80, 130)
    ButtonGadget(#Button2, 190, 190, 80, 20, "Check")
    
    SetGadgetColor(#List, #PB_Gadget_FrontColor, $0000FF)
    SetGadgetText(#Editor, Text$)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Word
              SetGadgetColor(#Word, #PB_Gadget_FrontColor, $000000)
            Case #Button1
              Word$ = GetGadgetText(#Word)
              If SpellCheck::Word(Word$) = SpellCheck::#Correct
                SetGadgetColor(#Word, #PB_Gadget_FrontColor, $008000)
              Else
                SpellCheck::CorrectionSuggestions(Word$, Suggestions())
                SetGadgetColor(#Word, #PB_Gadget_FrontColor, $0000FF)
                ForEach Suggestions()
                  Debug Suggestions()
                Next
              EndIf
            Case #Button2
              Text$ = GetGadgetText(#Editor)
              SpellCheck::Text(Text$, WrongWords())
              ClearGadgetItems(#List)
              ForEach WrongWords()
                AddGadgetItem(#List, -1, WrongWords())
              Next
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    ;SpellCheck::SaveUserDictionary()
    
    CloseWindow(#Window)
  EndIf  
  
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 55
; Folding = UMgg9
; EnableXP
; DPIAware