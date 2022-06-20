;/ ================================
;/ =    JsonDatabaseModule.pbi    =
;/ ================================
;/
;/ Small JSON-Database
;/ 
;/ [ PB V5.7x - V6.0 / 64Bit / All OS]
;/
;/ © 2022 Thorsten1 Hoeppner (08/2019)
;/

; Last Update: 20.06.2022
;
; - Added: #Compressed for Save() & Open() 
; - Added: Blob
;
; - AES-Encryption
; - Encryption directly in the memory without diversions via a file.
; - Reading and writing the database directly from or to an archive 


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

;{ ===== Tea & Pizza Ware =====
; <Thorsten1867> has created this code. 
; If you find the code useful and you want to use it for your programs, 
; you are welcome to support my work with a cup of tea or a pizza
; (or the amount of money for it). 
; [ https://www.paypal.me/Hoeppner1867 ]
;}


;{ _____ JSON-Database - Commands _____
;
; jDB::Create()          - Create a new database
; jDB::Open()            - Open a database file
; jDB::Save()            - Save database as file
; jDB::AddPack()         - Save database in an archive
; jDB::UncompressPack()  - Load database from an archive
; jDB::Close()           - Close database
;
; jDB::Create()          - Create a new database
; jDB::AddTable()        - Add a database table
; jDB::AddColumn()       - Add a table column
; jDB::AddDataset()      - Add new database row with column data
; 
; jDB::Drop()            - Delete database table
; jDB::Table()           - Select a table
;
; jDB::AffectedRows()    - Number of database rows affected or selected
; jDB::ColumnType()      - Returns the type of the column (#String/#Integer/#Quad/#Float/#Double/#Blob)
; jDB::CheckNull()       - Returns #True if column = literal zero
;
; jDB::SelectRow()       - Select a row with its ID
; jDB::Query()           - Select several rows by means of an expression
; jDB::FinishQuery()     - Resets the selection and releases the resources
; jDB::Update()          - Update selected row(s) by means of an expression
; jDB::FinishUpdate()    - Resets the selection and releases the resources
; jDB::Combine()         - Combine two tables
; jDB::FinishCombine()   - Resets the selection and and removes the temporary table
; jDB::Join()            - Combine two tables and create a new table
;
; jDB::Delete()          - Delete selected row(s) by means of an expressio
; jDB::Sort()            - Change the order of the selected rows
;
; jDB::FirstRow          - Go to the first selected row
; jDB::PreviousRow()     - Go to the previous selected row
; jDB::NextRow()         - Go to the next selected row
; jDB::LastRow()         - Go to the last selected row
; jDB::ResetRows()       - Go before the first row to process all rows with NextRow()
;
; jDB::GetBoolean()      - Get the content of the column from the current row (Boolean)
; jDB::GetInteger()      - Get the content of the column from the current row (Integer)
; jDB::GetQuad()         - Get the content of the column from the current row (Quad)
; jDB::GetFloat()        - Get the content of the column from the current row (Float)
; jDB::GetDouble()       - Get the content of the column from the current row (Double)
; jDB::GetString()       - Get the content of the column from the current row (String)
;
; jDB::UpdateDataset()   - Change the value of all column from the current row
;
; jDB::SetBoolean()      - Change the value of the column from the current row (Boolean)
; jDB::SetInteger()      - Change the value of the column from the current row (Integer)
; jDB::SetQuad()         - Change the value of the column from the current row (Quad)
; jDB::SetFloat()        - Change the value of the column from the current row (Float)
; jDB::SetDouble()       - Change the value of the column from the current row (Double)
; jDB::SetString()       - Change the value of the column from the current row (String)
;
; jDB::GetBlob()         - Loads the blob into the memory
; jDB::BlobSize()        - Returns the size of the blob for allocating the memory 
; jDB::SaveBlob()        - Saves the blob as a file
;
; jDB::SetBlob()         - Saves the memory as a blob in the column
; jDB::LoadBlob()        - Saves the file as a blob in the column

; jDB::FileToBlob()      - Returns file as blob string for the use with DataSet()
; jDB::MemoryToBlob()    - Returns memory as blob string for the use with DataSet()
;
;}


DeclareModule jDB
  
  #Enable_Encryption = #True
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants
  ;- ===========================================================================
  
  #UID  = "jUID"
  #UUID = "jUUID"
  
  EnumerationBinary ;{ Flags
    #Ascendig   = #PB_Sort_Ascending
    #Descending = #PB_Sort_Descending
    #NoCase     = #PB_Sort_NoCase
    #CopyToList
    #Compressed 
  EndEnumeration ;}
  
  Enumeration 1     ;{ Database Errors
    #ERROR_DATABASE_ALREADY_EXISTS
    #ERROR_DATABASE_NOT_EXISTS
    #ERROR_DATABASE_NOT_FOUND
    #ERROR_TABLE_ALREADY_EXISTS
    #ERROR_TABLE_NOT_EXISTS
    #ERROR_COLUMN_ALREADY_EXISTS
    #ERROR_LABEL_NOT_FOUND
    #ERROR_PASSWORD_INVALID
  EndEnumeration ;}
  
  Enumeration       ;{ JSON
    #Empty   = #PB_JSON_Null
    #String  = #PB_JSON_String
    #Boolean = #PB_JSON_Boolean
    #Integer
    #Quad
    #Float
    #Double
    #Blob
  EndEnumeration ;}
  
  ;- ===========================================================================
  ;-   DeclareModule - Structures
  ;- ===========================================================================
  
  Structure Row_Structure ;{ jDB::Row()\...
    ID.s
    Map Column.s()
  EndStructure ;}
  Global NewList Row.Row_Structure()
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i AddColumn(DB.i, Label.s, Type.i) 
  Declare.i AddDataset(DB.i, DataSet.s, ID.s=#UID, Separator.s="|")
  Declare.i AddTable(DB.i, Table.s)
  
  Declare   Drop(DB.i, Table.s)
  
  Declare   Close(DB.i)
  Declare.i Create(DB.i, DatabaseName.s, Key.s="")
  Declare.i Open(DB.i, File.s, Key.s="", Flags.i=#False)
  Declare.i Save(DB.i, File.s="", Flags.i=#False)
  
  Declare   Table(DB.i, Table.s)
  Declare   SelectRow(DB.i, ID.s, Table.s="", Flags.i=#False)
  
  Declare.i AffectedRows(DB.i, Table.s="")
  Declare.i ColumnType(DB.i, Column.s)
  Declare.i CheckNull(DB.i, Column.s)
  
  Declare.i Combine(DB.i, Columns.s, Where.s, Order.s="", Flags.i=#False)
  Declare   FinishCombine(DB.i)
  Declare.i Delete(DB.i, Expression.s="*", Table.s="")
  Declare.i Update(DB.i, Column.s, Value.s, Expression.s="*", Table.s="", Flags.i=#False)
  Declare   FinishUpdate(DB.i, Table.s)
  Declare.i Query(DB.i, Expression.s="*", Order.s="", Table.s="", Flags.i=#False)
  Declare   FinishQuery(DB.i, Table.s)
  Declare.i Join(DB.i, Columns.s, Where.s, Table.s)
  
  Declare   Sort(DB.i, Order.s, Table.s="", Flags.i=#False)
  
  Declare.i UpdateDataset(DB.i, DataSet.s, Separator.s="|", Flags=#False)
  
  Declare   FirstRow(DB.i)
  Declare   PreviousRow(DB.i)
  Declare.i NextRow(DB.i)
  Declare   LastRow(DB.i)
  Declare   ResetRows(DB.i)
  
  Declare   GetBoolean(DB.i, Column.s)
  Declare.i GetInteger(DB.i, Column.s)
  Declare.q GetQuad(DB.i, Column.s)
  Declare.d GetDouble(DB.i, Column.s)
  Declare.f GetFloat(DB.i, Column.s)
  Declare.s GetString(DB.i, Column.s)
  
  Declare.i BlobSize(DB.i, Column.s)
  Declare.i GetBlob(DB.i, Column.s, *Buffer, Size.i)
  Declare.i SaveBlob(DB.i, Column.s, File.s)
  
  Declare   SetBoolean(DB.i, Column.s, Value.i)
  Declare   SetInteger(DB.i, Column.s, Value.i)
  Declare   SetQuad(DB.i, Column.s, Value.q)
  Declare   SetFloat(DB.i, Column.s, Value.f)
  Declare   SetString(DB.i, Column.s, Value.s)
  Declare   SetDouble(DB.i, Column.s, Value.d)
  
  Declare   SetBlob(DB.i, Column.s, *Buffer, Size)
  Declare   LoadBlob(DB.i, Column.s, File.s)
  
  Declare.s FileToBlob(File.s)
  Declare.s MemoryToBlob(*Buffer, Size)
  
  Declare.i AddPack(DB.i, Pack.i, PackedFileName.s="") 
  Declare.i UncompressPack(DB.i, Pack.i, PackedFileName.s, Key.s="")
  
EndDeclareModule

Module jDB
  
  EnableExplicit
  
  UseCRC32Fingerprint()
  UseSHA3Fingerprint()
  
  
  ;- ==================================
  ;-   Module - Constants
	;- ==================================
  
  #Label     = -1
  #Combined  = "jDB-Combined" 
  #Structure = "jDB-Structure"
  
  CompilerIf #Enable_Encryption
    
    Enumeration
      #Binary
      #Ascii
      #Unicode
    EndEnumeration
  
    #qAES  = 113656983
    #Salt$ = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"
    
  CompilerEndIf
  
  
  ;- ==================================
  ;-   Module - Structures
	;- ==================================
  
  CompilerIf #Enable_Encryption
    
    Structure Footer_Structure
	    ID.q
	    Counter.q
	    Hash.s
	  EndStructure
    
    Structure AES_Structure         ;{ qAES\...
      Salt.s
      KeyStretching.i
      Loops.i
      Hash.s
      *ProcPtr
    EndStructure ;}
    Global qAES.AES_Structure
    
  CompilerEndIf
  
  Structure UID_Structure              ;{
    Map Table.i()
  EndStructure ;}
  Global NewMap UID.UID_Structure()
  
  Structure Expr_Structure             ;{
    Column.s
    Operator.s
    Value.s
    Idx.i
    Type.i
  EndStructure ;}
  
  Structure Parse_Structure            ;{
    Expression.Expr_Structure
    Operator.s
  EndStructure ;}
  
  Structure Combine_Structure          ;{ 
    Table.s
    Column.s
    Label.s
  EndStructure ;}
  
  
  Structure jDB_Value_Structure  ;{ DB()\Selected()\Column()\...
    Value.s
    Type.i
  EndStructure ;}
  
  
  Structure jDB_Combine_Structure      ;{ jDB('DB')\Selected()\...
    *Row
    ID.s
    Map Column.jDB_Value_Structure()
    ; Sort
    String.s
    Integer.i
    Double.d
    Quad.q
    Float.f
  EndStructure ;}
  
  Structure jDB_Column_Structure       ;{ jDB()\Table()\Column\...
    Label.s
    Type.i
  EndStructure ;}

  Structure jDB_Row_Structure          ;{ jDB('DB')\Selected()\...
    *Row
    ID.s
    ; Sort / Compare
    String.s
    Integer.i
    Double.d
    Quad.q
    Float.f
  EndStructure ;}
  
  Structure jDB_Table_Structure        ;{ jDB()\Table('name')\...
    *jTable
    *jStruc
    Rows.i
    Map *Row()
    Map ColIdx.i()
    List Selected.jDB_Row_Structure()
    List Column.jDB_Column_Structure()
  EndStructure ;}
  
  Structure jDB_Structure              ;{ jDB('DB')\...
    JSON.i                             ; json number
    
    Name.s    ; database name
    File.s    ; file name
    Key.s     ; password

    *Root     ; root json pointer
    *jRow     ; current row json pointer
    
    cTable.s  ; current table
    cRow.i   ; current row
    
    Map Table.jDB_Table_Structure()
    Error.i
  EndStructure ;}
  Global NewMap jDB.jDB_Structure()
  
  
  ;- ==================================
	;-   Module - Internal Procedures
  ;- ==================================
  
  Procedure.s UUID_()
    Define.i Idx
    Define.a Byte
    Define.s UUID_String
    
    For Idx=0 To 15
      
      If Idx = 7 
        Byte = 64 + Random(15)
      ElseIf Idx = 9
        Byte = 128 + Random(63)
      Else
        Byte = Random(255)
      EndIf
      
      UUID_String + RSet(Hex(Byte, #PB_Ascii), 2, "0")
      
    Next
  
    ProcedureReturn StringFingerprint(UUID_String, #PB_Cipher_CRC32)
  EndProcedure
  
  Procedure.i DetermineUID_(Table.s)
    Define.s Key = MapKey(jDB())
    Define.i ID, UID = 0
    
    PushMapPosition(jDB()\Table())
    
    If FindMapElement(jDB()\Table(), Table)
      
      UID(Key)\Table(Table) = 0
      
      ForEach jDB()\Table()\Row()
        ID = Val(MapKey(jDB()\Table()\Row()))
        If ID > UID : UID = ID : EndIf
      Next
      
      UID(Key)\Table(Table) = UID
      
    EndIf
    
    PopMapPosition(jDB()\Table())
    
    ProcedureReturn UID
  EndProcedure
  
  Procedure.s EscapeStrg_(String.s)
    
    String = ReplaceString(String, "ä", "a'")
    String = ReplaceString(String, "ö", "o'")
    String = ReplaceString(String, "ü", "u'")
    String = ReplaceString(String, "Ä", "A'")
    String = ReplaceString(String, "Ö", "O'")
    String = ReplaceString(String, "Ü", "U'")
    
    ProcedureReturn ReplaceString(String, "ß", "!3")
  EndProcedure
  
  Procedure.s UnEscapeStrg_(String.s)
    
    String = ReplaceString(String, "a'", "ä")
    String = ReplaceString(String, "o'", "ö")
    String = ReplaceString(String, "u'", "ü")
    String = ReplaceString(String, "A'", "Ä")
    String = ReplaceString(String, "O'", "Ö")
    String = ReplaceString(String, "U'", "Ü")
    
    ProcedureReturn ReplaceString(String, "!3", "ß")
  EndProcedure
  
  Procedure.s GetOperator_(String.s) 
    
    If CountString(String, "<>")
      ProcedureReturn "<>"
    ElseIf CountString(String, "<=")
      ProcedureReturn "<="
    ElseIf CountString(String, ">=")
      ProcedureReturn ">="
    ElseIf CountString(String, "<")
      ProcedureReturn "<"
    ElseIf CountString(String, ">")
      ProcedureReturn ">"
    ElseIf CountString(String, "=")
      ProcedureReturn "="
    EndIf
    
  EndProcedure
  
  ;- ----- Encryption -----
  
  CompilerIf #Enable_Encryption

    Procedure.q GetCounter_()
  	  Define.q Counter
  	  
  	  If OpenCryptRandom()
        CryptRandomData(@Counter, 8)
      Else
        RandomData(@Counter, 8)
      EndIf
      
      ProcedureReturn Counter
  	EndProcedure 
    
    Procedure.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
  	  ; Author: Werner Albus - www.nachtoptik.de (No warranty whatsoever - Use at your own risk)
      ; CounterKey: If you cipher a file blockwise, always set the current block number with this counter (consecutive numbering).
      ; CounterAES: This counter will be automatically used by the coder, but you can change the startpoint.
  	  Define.i i, ii, iii, cStep
  	  Define.q Rounds, Remaining
  	  Define.s Hash$, Salt$
  	  Define   *aRegister.ascii, *wRegister.word, *aBufferIn.ascii, *aBufferOut.ascii, *qBufferIn.quad, *qBufferOut.quad
  	  Static   FixedKey${64}
  	  Static   Dim Register.q(3)
  	  
  	  If qAES\Salt = ""
  	    Salt$ = #Salt$
  	  Else
  	    Salt$ = qAES\Salt + #Salt$   
  	  EndIf
  	  
  	  Hash$     = Salt$ + Key + Str(CounterKey) + ReverseString(Salt$)
  	  FixedKey$ = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, 256)	  
  	  
  	  cStep     = SizeOf(character) << 1
  	  Rounds    = Size >> 4
  	  Remaining = Size % 16
  	  
  	  For ii = 0 To 31
  	    PokeA(@Register(0) + ii, Val("$" + PeekS(@FixedKey$ + iii, 2)))
  	    iii + cStep
  	  Next
  	  
  	  Register(1) + CounterAES
  
  	  Select Mode
  	    Case #Binary  ;{ Binary content
  	      
  	      *qBufferIn  = *Input
  	      *qBufferOut = *Output
  	      
  	      If Size < 16 ;{ Size < 16
  	        
  	        *aBufferOut = *qBufferOut
  	        *aBufferIn  = *qBufferIn
  	        *aRegister  = @register(0)
  	        
  	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
  	          ProcedureReturn #False
  	        EndIf
  	        
            For ii=0 To Size - 1
              *aBufferOut\a = *aBufferIn\a ! *aRegister\a
              *aBufferIn  + 1
              *aBufferOut + 1
              *aRegister  + 1
            Next
            
            ProcedureReturn #True
            ;}
          EndIf
          
          While i < Rounds ;{ >= 16 Byte
            
            If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
              ProcedureReturn #False
            EndIf
            
            *qBufferOut\q=*qBufferIn\q ! register(0)
            *qBufferIn  + 8
            *qBufferOut + 8
            *qBufferOut\q = *qBufferIn\q ! register(1)
            *qBufferIn  + 8
            *qBufferOut + 8
            
            i + 1
          Wend ;}
          
          If Remaining
            
            *aBufferOut = *qBufferOut
            *aBufferIn  = *qBufferIn
            *aRegister  = @Register(0)
            
            If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
              ProcedureReturn #False
            EndIf
            
            For ii=0 To Remaining - 1
              *aBufferOut\a = *aBufferIn\a ! *aRegister\a
              *aBufferIn  + 1
              *aBufferOut + 1
              *aRegister  + 1
            Next
            
          EndIf
  	      ;}
  	    Case #Ascii   ;{ Ascii content
  	      
  	      *aBufferIn  = *Input
  	      *aBufferOut = *Output
  	      
  	      Repeat
  	        
  	        If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
  	          ProcedureReturn #False
  	        EndIf
  	        
  	        *aRegister = @Register(0)
  	        
  	        For ii=0 To 15
  	          
              If *aBufferIn\a And *aBufferIn\a ! *aRegister\a
                *aBufferOut\a = *aBufferIn\a ! *aRegister\a
              Else
                *aBufferOut\a = *aBufferIn\a
              EndIf
              
              If i > Size - 2 : Break 2 : EndIf
              
              *aBufferIn  + 1
              *aBufferOut + 1
              *aRegister  + 1
              
              i + 1
            Next ii
            
          ForEver
    	    ;}
  	    Case #Unicode ;{ Unicode content
  	      
  	      Repeat
  	        
  	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
  	          ProcedureReturn #False
  	        EndIf
  	        
  	        *wRegister = @Register(0)
            
  	        For ii=0 To 15 Step 2
  	          
              If *Input\w And *Input\w ! *wRegister\w
                *Output\w = *Input\w ! *wRegister\w
              Else
                *Output\w = *Input\w
              EndIf
              
              If i > Size - 3 : Break 2 : EndIf
              
              *Input + 2
              *Output + 2
              *wRegister + 2
              
              i + 2
            Next ii
            
          ForEver
  	      
  	      ;}
  	  EndSelect
  	  
  	  ProcedureReturn #True
  	EndProcedure
  	
  	Procedure.s DecodeHash_(Counter.q, *Hash, FreeMemory.i=#True)
      Define.i i
      Define.s Hash$
      
      Static Dim Hash.q(31)
      
      If *Hash
        
        SmartCoder(#Binary, *Hash, @Hash(0), 32, Str(Counter))
        
        For i = 0 To 31
          Hash$ + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
        Next i
        
        If FreeMemory : FreeMemory(*Hash) : EndIf
      EndIf
      
      ProcedureReturn LCase(Hash$)
    EndProcedure
  	
    Procedure   EncodeHash_(Hash.s, Counter.q, *Hash)
      Define.i i
      
      Static Dim Hash.q(31)
      
      For i=0 To 31
        PokeA(@Hash(0) + i, Val("$" + PeekS(@Hash + i * SizeOf(character) << 1, 2)))
      Next
      
      SmartCoder(#Binary, @Hash(0), *Hash, 32, Str(Counter))
      
    EndProcedure  	
  	
  	Procedure   CryptBlockwise(*Input, *Output, Size.i, Key.s, Counter.q)
      Define.i BlockSize, Bytes
      
      Define.q Timer, CounterAES
      BlockSize = 4096 << 2
  	  Bytes = 0

  	  Repeat
  	    
  	    If Bytes + BlockSize <= Size
  	      SmartCoder(#Binary, *Input + Bytes, *Output + Bytes, BlockSize, Key, Counter, CounterAES)
  	    Else
  	      SmartCoder(#Binary, *Input + Bytes, *Output + Bytes, Size - Bytes, Key, Counter, CounterAES)
  	    EndIf 
  	    
  	    Bytes + BlockSize
  	    
  	    Counter + 1
  	    CounterAES + 1
  	    
  	  Until Bytes >= Size

    EndProcedure
    
    Procedure.i DecryptMemory_(*Buffer, Size.i, Key.s)
  	  Define.q Counter, qAES_ID
  	  
  	  Counter   = PeekQ(*Buffer + Size - 8)
      qAES_ID   = PeekQ(*Buffer + Size - 16)
      qAES\Hash = DecodeHash_(Counter, *Buffer + Size - 48, #False)
      
      SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
      
      If qAES_ID = #qAES
        
        Size - 48
        
        CryptBlockwise(*Buffer, *Buffer, Size, Key, Counter)
        
        If qAES\Hash <> Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
          qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
          ProcedureReturn #False
        EndIf
  
      EndIf 
    
	  ProcedureReturn Size
	EndProcedure
    
    Procedure.i AddCryptMemory_(PackID, *Buffer, Size.i, PackedFileName.s, Key.s)
  	  Define.i Size, Result
  	  Define.q Counter,qAES_ID = #qAES
  	  Define   *Buffer, *Hash
  
  	  Counter = GetCounter_()
      
      qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
      *Hash = AllocateMemory(32)
      If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
      
      CryptBlockwise(*Buffer, *Buffer, Size, Key, Counter)
      
      SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
      
      CopyMemory(*Hash, *Buffer + Size, 32)
      PokeQ(*Buffer + Size + 32, qAES_ID)
      PokeQ(*Buffer + Size + 40, Counter)
  
      Size + 48

      Result = AddPackMemory(PackID, *Buffer, Size, PackedFileName)
      
      ProcedureReturn Result
  	EndProcedure
  	
    Procedure.i DecryptBuffer_(*Buffer, Size.i, Key.s, Counter.q) 
	  
  	  CryptBlockwise(*Buffer, *Buffer, Size, Key, Counter)
  	  
      If qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        ProcedureReturn #True
      Else  
        qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        ProcedureReturn #False
      EndIf
    
    EndProcedure
  	
  	Procedure.i ReadFileFooter_(FileID.i, FileSize.i, *Footer.Footer_Structure)
      Define i.i, qAES_ID.q 
      Define *Hash
      Static Dim Hash.q(31)
  
      *Hash = AllocateMemory(32)
      If *Hash
        
        FileSeek(FileID, FileSize - 48)
        ReadData(FileID, *Hash, 32)
        qAES_ID = ReadQuad(FileID) 
        *Footer\Counter = ReadQuad(FileID)
        FileSeek(FileID, 0)
        
        SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(*Footer\Counter))
        SmartCoder(#Binary, *Hash, @Hash(0), 32, Str(*Footer\Counter))
        
        *Footer\ID = qAES_ID
        
        *Footer\Hash = ""
        For i = 0 To 31
          *Footer\Hash + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
        Next
        *Footer\Hash = LCase(*Footer\Hash)
        
        FreeMemory(*Hash)
        
        ProcedureReturn #True
      EndIf
      
      ProcedureReturn #False
    EndProcedure
  	
    Procedure.i WriteEncryptedFile_(File.s, *Buffer, Size.i, Key.s) 
  	  Define.i FileID, Size, Result
      Define.q Counter, qAES_ID = #qAES
      Define   *Buffer, *Hash
      
      Counter = GetCounter_()
      
      qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
      *Hash = AllocateMemory(32)
      If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
      SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
      
      CryptBlockwise(*Buffer, *Buffer, Size, Key, Counter)
      
      FileID = CreateFile(#PB_Any, File)
      If FileID 
        Result = WriteData(FileID, *Buffer, Size)
        WriteData(FileID, *Hash, 32)
        WriteQuad(FileID, qAES_ID)
        WriteQuad(FileID, Counter)
        CloseFile(FileID)
      EndIf
      
      If *Hash : FreeMemory(*Hash) : EndIf
      
      ProcedureReturn Result
  	EndProcedure

  CompilerEndIf
  
  ;- ----- Parse -----
  
  Procedure   ParseString_(Expression.s, Index.i, Array Parse.Parse_Structure(1))
 
    If CountString(Expression, ">=")
      Parse(Index)\Expression\Column   = Trim(StringField(Expression, 1, ">="))
      Parse(Index)\Expression\Operator = ">="
      Parse(Index)\Expression\Value    = Trim(StringField(Expression, 2, ">="))
    ElseIf CountString(Expression, "<=")
      Parse(Index)\Expression\Column   = Trim(StringField(Expression, 1, "<="))
      Parse(Index)\Expression\Operator = "<="
      Parse(Index)\Expression\Value    = Trim(StringField(Expression, 2, "<="))
    ElseIf CountString(Expression, "=")
      Parse(Index)\Expression\Column   = Trim(StringField(Expression, 1, "="))
      Parse(Index)\Expression\Operator = "="
      Parse(Index)\Expression\Value    = Trim(StringField(Expression, 2, "="))
    ElseIf CountString(Expression, ">")
      Parse(Index)\Expression\Column   = Trim(StringField(Expression, 1, ">"))
      Parse(Index)\Expression\Operator = ">"
      Parse(Index)\Expression\Value    = Trim(StringField(Expression, 2, ">"))
    ElseIf CountString(Expression, "<")
      Parse(Index)\Expression\Column   = Trim(StringField(Expression, 1, "<"))
      Parse(Index)\Expression\Operator = "<"
      Parse(Index)\Expression\Value    = Trim(StringField(Expression, 2, "<"))
    ElseIf CountString(UCase(Expression), "LIKE")
      Parse(Index)\Expression\Column   = StringField(Expression, 1, " ")
      Parse(Index)\Expression\Operator = "LIKE"
      Parse(Index)\Expression\Value    = StringField(Expression, 3, " ")
    EndIf 
    
    ;Debug Parse(Index)\Expression\Column + " " + Parse(Index)\Expression\Operator + " '" + Parse(Index)\Expression\Value + "'"
    
  EndProcedure
  
  Procedure   ParseExpression_(Expression.s, Array Parse.Parse_Structure(1))
    Define.i aSize, aPos, oPos, a, StartPos, EndPos
    
    Expression = ReplaceString(Expression, " And ", " AND ", #PB_String_NoCase)
    Expression = ReplaceString(Expression, " Or ",  " OR ",  #PB_String_NoCase)
    
    aSize = CountString(Expression, "AND") + CountString(Expression, "OR")
   
    ReDim Parse(aSize)
    
    If aSize = 0
      
      Parse(0)\Operator = ""
      ParseString_(Expression, 0, Parse())
      
    Else
      
      StartPos = 1
      
      For a=0 To aSize
        
        aPos = FindString(UCase(Expression), "AND", StartPos)
        oPos = FindString(UCase(Expression), "OR",  StartPos)
        
        If aPos And oPos
          
          If aPos < oPos
            EndPos = aPos
            Parse(a)\Operator = "AND"
            ParseString_(Trim(Mid(Expression, StartPos, EndPos - StartPos)), a, Parse())
            StartPos = EndPos + 3
          Else
            EndPos = oPos
            Parse(a)\Operator = "OR"
            ParseString_(Trim(Mid(Expression, StartPos, EndPos - StartPos)), a, Parse())
            StartPos = EndPos + 2
          EndIf  
          
        ElseIf aPos
          EndPos = aPos
          Parse(a)\Operator = "AND"
          ParseString_(Trim(Mid(Expression, StartPos, EndPos - StartPos)), a, Parse())
          StartPos = EndPos + 3
        ElseIf oPos
          EndPos = oPos
          Parse(a)\Operator = "OR"
          ParseString_(Trim(Mid(Expression, StartPos, EndPos - StartPos)), a, Parse())
          StartPos = EndPos + 2
        Else
          EndPos = Len(Expression)
          Parse(a)\Operator = ""
          ParseString_(Trim(Mid(Expression, StartPos, EndPos - StartPos + 1)), a, Parse())
        EndIf  

      Next

    EndIf  
    
    For a=0 To ArraySize(Parse())
     
      If UCase(Parse(a)\Expression\Column) = "ID" Or UCase(Parse(a)\Expression\Column) = "ROW"
        Parse(a)\Expression\Type = #Label
      ElseIf FindMapElement(jDB()\Table()\ColIdx(), Parse(a)\Expression\Column)
        Parse(a)\Expression\Idx = jDB()\Table()\ColIdx()
        If SelectElement(jDB()\Table()\Column(), jDB()\Table()\ColIdx())
          Parse(a)\Expression\Type = jDB()\Table()\Column()\Type
        EndIf 
      EndIf

    Next 
    
  EndProcedure
  
  Procedure   ParseColumns_(Columns.s, List Parse.Combine_Structure())
    Define.i i, Count, Col$
    
    Columns = ReplaceString(Columns, " As ", " AS ", #PB_String_NoCase)
    
    Count = CountString(Columns, ",") + 1
    For i=1 To Count
      If AddElement(Parse())
        Col$ = Trim(StringField(Columns, i, ","))
        Parse()\Table  = StringField(Col$, 1, ".")
        Col$ = Trim(StringField(Col$, 2, "."))
        Parse()\Column = Trim(StringField(Col$, 1, "AS"))
        Parse()\Label  = Trim(StringField(Col$, 2, "AS"))
      EndIf
    Next  
    
  EndProcedure
  
  ;- ----- Compare -----
  
  Procedure.i CompareInteger_(Value1.i, Value2.i, Operator.s)
    
    Select Operator
      Case "="
        If Value1 = Value2  : ProcedureReturn #True : EndIf
      Case "<"
        If Value1 < Value2  : ProcedureReturn #True : EndIf
      Case ">"
        If Value1 > Value2  : ProcedureReturn #True : EndIf
      Case "<>"
        If Value1 <> Value2 : ProcedureReturn #True : EndIf  
      Case "<="
        If Value1 <= Value2 : ProcedureReturn #True : EndIf
      Case ">="
        If Value1 >= Value2 : ProcedureReturn #True : EndIf
    EndSelect
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i CompareDouble_(Value1.d, Value2.d, Operator.s)
  
    Select Operator
      Case "="
        If Value1 = Value2  : ProcedureReturn #True : EndIf
      Case "<"
        If Value1 < Value2  : ProcedureReturn #True : EndIf
      Case ">"
        If Value1 > Value2  : ProcedureReturn #True : EndIf
      Case "<>"
        If Value1 <> Value2 : ProcedureReturn #True : EndIf  
      Case "<="
        If Value1 <= Value2 : ProcedureReturn #True : EndIf
      Case ">="
        If Value1 >= Value2 : ProcedureReturn #True : EndIf
    EndSelect
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i CompareQuad_(Value1.q, Value2.q, Operator.s)
  
    Select Operator
      Case "="
        If Value1 = Value2  : ProcedureReturn #True : EndIf
      Case "<"
        If Value1 < Value2  : ProcedureReturn #True : EndIf
      Case ">"
        If Value1 > Value2  : ProcedureReturn #True : EndIf
      Case "<>"
        If Value1 <> Value2 : ProcedureReturn #True : EndIf  
      Case "<="
        If Value1 <= Value2 : ProcedureReturn #True : EndIf
      Case ">="
        If Value1 >= Value2 : ProcedureReturn #True : EndIf
    EndSelect
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.i CompareFloat_(Value1.f, Value2.f, Operator.s)
  
    Select Operator
      Case "="
        If Value1 = Value2  : ProcedureReturn #True : EndIf
      Case "<"
        If Value1 < Value2  : ProcedureReturn #True : EndIf
      Case ">"
        If Value1 > Value2  : ProcedureReturn #True : EndIf
      Case "<>"
        If Value1 <> Value2 : ProcedureReturn #True : EndIf  
      Case "<="
        If Value1 <= Value2 : ProcedureReturn #True : EndIf
      Case ">="
        If Value1 >= Value2 : ProcedureReturn #True : EndIf
    EndSelect
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.i CompareString_(Value1.s, Value2.s, Operator.s)
    Define.s Strg
    
    Value2 = Trim(Value2, "'")
    Value2 = Trim(Value2, Chr(34))

    Select Operator
      Case "="
        If Value1 = Value2  : ProcedureReturn #True : EndIf
      Case "<"
        If Value1 < Value2  : ProcedureReturn #True : EndIf
      Case ">"
        If Value1 > Value2  : ProcedureReturn #True : EndIf
      Case "<>"
        If Value1 <> Value2 : ProcedureReturn #True : EndIf
      Case "<="
        If Value1 <= Value2 : ProcedureReturn #True : EndIf
      Case ">="
        If Value1 >= Value2 : ProcedureReturn #True : EndIf
      Case "LIKE"
        Strg = Trim(Value2, "*")
        If Left(Value2, 1) = "*" And Right(Value2, 1) = "*"
          If CountString(Value1, Value2) : ProcedureReturn #True : EndIf
        ElseIf Left(Value2, 1) = "*"
          If Right(Value1, Len(Strg)) = Strg : ProcedureReturn #True : EndIf
        ElseIf Right(Value2, 1) = "*"
          If Left(Value1, Len(Strg))  = Strg : ProcedureReturn #True : EndIf
        EndIf   
    EndSelect
    
    ProcedureReturn #False
  EndProcedure
  

  Procedure.i Compare_(Index.i, Array Parse.Parse_Structure(1))
    Define.i Result
    Define *Element
    
    If Parse(Index)\Expression\Idx = #Label ; "ID = UID"
      
      Result = CompareString_(MapKey(jDB()\Table()\Row()), Parse(Index)\Expression\Value, Parse(Index)\Expression\Operator)
      
    Else
      
      *Element = GetJSONElement(jDB()\Table()\Row(), Parse(Index)\Expression\Idx)
      If *Element
        
        Select Parse(Index)\Expression\Type
          Case #Boolean
            If JSONType(*Element) = #PB_JSON_Boolean
              If GetJSONBoolean(*Element) = Val(Parse(Index)\Expression\Value)
                Result = #True
              Else
                Result = #False
              EndIf  
            EndIf  
          Case #Integer
            If JSONType(*Element) = #PB_JSON_Number 
              Result = CompareInteger_(GetJSONInteger(*Element), Val(Parse(Index)\Expression\Value), Parse(Index)\Expression\Operator)
            EndIf  
          Case #Double
            If JSONType(*Element) = #PB_JSON_Number   
              Result = CompareDouble_(GetJSONDouble(*Element), ValD(Parse(Index)\Expression\Value), Parse(Index)\Expression\Operator)
            EndIf   
          Case #Quad
            If JSONType(*Element) = #PB_JSON_Number 
              Result = CompareQuad_(GetJSONQuad(*Element), Val(Parse(Index)\Expression\Value), Parse(Index)\Expression\Operator)
            EndIf   
          Case #Float
            If JSONType(*Element) = #PB_JSON_Number 
              Result = CompareFloat_(GetJSONFloat(*Element), ValF(Parse(Index)\Expression\Value), Parse(Index)\Expression\Operator)
            EndIf   
          Case #String
            If JSONType(*Element) = #PB_JSON_String
              Result = CompareString_(GetJSONString(*Element), Parse(Index)\Expression\Value, Parse(Index)\Expression\Operator) 
            EndIf   
        EndSelect
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i CompareColumns_(Table1.s, Table2.s, Operator.s, ColType.i) 

    Select ColType
      Case #Boolean
        If jDB()\Table(Table1)\Selected()\Integer = jDB()\Table(Table2)\Selected()\Integer
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf  
      Case #Integer
        ProcedureReturn CompareInteger_(jDB()\Table(Table1)\Selected()\Integer, jDB()\Table(Table2)\Selected()\Integer, Operator)
      Case #Quad
        ProcedureReturn CompareQuad_(jDB()\Table(Table1)\Selected()\Quad, jDB()\Table(Table2)\Selected()\Quad, Operator) 
      Case #Float
        ProcedureReturn CompareFloat_(jDB()\Table(Table1)\Selected()\Float, jDB()\Table(Table2)\Selected()\Float, Operator)   
      Case #Double
        ProcedureReturn CompareDouble_(jDB()\Table(Table1)\Selected()\Double, jDB()\Table(Table2)\Selected()\Double, Operator)  
      Case #String
        ProcedureReturn CompareString_(jDB()\Table(Table1)\Selected()\String, jDB()\Table(Table2)\Selected()\String, Operator)     
    EndSelect

  EndProcedure
  
  
  ;- ----- Database -----
  
  Procedure.i InitDatabase_(Key.s="")
    Define  *jDBLabel, *jDBType
    Define.i c, Idx
    Define.s Label
    
    jDB()\Root = JSONValue(jDB()\JSON)
    jDB()\Name = GetJSONString(GetJSONMember(jDB()\Root, "Database"))
    
    jDB()\Key = GetJSONString(GetJSONMember(jDB()\Root, "Password"))
    
    If jDB()\Key
      If jDB()\Key <> StringFingerprint(Key, #PB_Cipher_SHA3)
        jDB()\Error = #ERROR_PASSWORD_INVALID
        FreeJSON(jDB()\JSON)
        ProcedureReturn #False
      EndIf
    EndIf  
    
    If ExamineJSONMembers(jDB()\Root)

      While NextJSONMember(jDB()\Root)
        
        If JSONType(JSONMemberValue(jDB()\Root)) = #PB_JSON_Object
          
          If AddMapElement(jDB()\Table(), JSONMemberKey(jDB()\Root))
            
            jDB()\Table()\jTable = JSONMemberValue(jDB()\Root)
            jDB()\Table()\jStruc = GetJSONMember(jDB()\Table()\jTable, "jDB-Structure")
            
            *jDBLabel = GetJSONMember(jDB()\Table()\jStruc, "Label")
            *jDBType  = GetJSONMember(jDB()\Table()\jStruc, "Type")
            
            ;{ Read columns info
            For c=0 To JSONArraySize(*jDBLabel) - 1
              If AddElement(jDB()\Table()\Column())
                Idx   = ListIndex(jDB()\Table()\Column())
                Label = GetJSONString(GetJSONElement(*jDBLabel, Idx))
                jDB()\Table()\Column()\Label = Label
                jDB()\Table()\Column()\Type  = GetJSONInteger(GetJSONElement(*jDBType, Idx))
                jDB()\Table()\ColIdx(Label) = Idx
              EndIf
            Next ;}
            
            ;{ Read rows pointer
            ClearMap(jDB()\Table()\Row())
      
            If ExamineJSONMembers(jDB()\Table()\jTable)
              While NextJSONMember(jDB()\Table()\jTable)
                If JSONType(JSONMemberValue(jDB()\Table()\jTable)) = #PB_JSON_Array
                  jDB()\Table()\Row(JSONMemberKey(jDB()\Table()\jTable)) = JSONMemberValue(jDB()\Table()\jTable)            
                EndIf 
              Wend
            EndIf ;}
            
            DetermineUID_(MapKey(jDB()\Table()))
            
          EndIf
          
        EndIf 
        
      Wend

      ProcedureReturn #True
    EndIf  

  EndProcedure
  
  
  Procedure.i IsSelected_(Table.s) 
    Define.i Rows
    
    PushMapPosition(jDB()\Table())
    
    If FindMapElement(jDB()\Table(), Table)
      Rows = ListSize(jDB()\Table()\Selected())
    EndIf
    
    PopMapPosition(jDB()\Table())
    
    ProcedureReturn Rows
  EndProcedure  
  
  
  Procedure.i SelectTable_(Table.s)
    
    If FindMapElement(jDB()\Table(), Table)
     
      jDB()\cTable = Table
    
      ProcedureReturn MapSize(jDB()\Table()\Row())
    Else
      
      jDB()\cTable  = ""
      jDB()\Error  = #ERROR_TABLE_NOT_EXISTS
      
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  Procedure.i SelectAll_(Table.s)
    Define.i Rows
    
    PushMapPosition(jDB()\Table())
    
    If FindMapElement(jDB()\Table(), Table)
      
      ClearList(jDB()\Table()\Selected())
      
      ForEach jDB()\Table()\Row()
        If AddElement(jDB()\Table()\Selected())
          jDB()\Table()\Selected()\Row   = jDB()\Table()\Row()
          jDB()\Table()\Selected()\ID = MapKey(jDB()\Table()\Row())
        EndIf   
      Next
      
      Rows = ListSize(jDB()\Table()\Selected())
    EndIf
    
    PopMapPosition(jDB()\Table())
    
    ProcedureReturn Rows
  EndProcedure
  
  
  Procedure CopyToList_()
    Define.i Idx
    Define.s Label
    Define   *Element
    
    ClearList(Row())
    
    ForEach jDB()\Table()\Selected()
      
      If AddElement(Row())
        
        Row()\ID = jDB()\Table()\Selected()\ID
        
        ForEach jDB()\Table()\Column()
          
          Idx   = ListIndex(jDB()\Table()\Column())
          Label = jDB()\Table()\Column()\Label
          
          *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
          If *Element
            
            Select jDB()\Table()\Column()\Type
              Case #Boolean
                If JSONType(*Element) = #PB_JSON_Boolean
                  Row()\Column(Label) = Str(GetJSONBoolean(*Element))
                EndIf  
              Case #Integer
                If JSONType(*Element) = #PB_JSON_Number
                  Row()\Column(Label) = Str(GetJSONInteger(*Element))
                EndIf  
              Case #Double
                If JSONType(*Element) = #PB_JSON_Number
                  Row()\Column(Label) = Str(GetJSONDouble(*Element))
                EndIf  
              Case #Quad
                If JSONType(*Element) = #PB_JSON_Number
                  Row()\Column(Label) = StrD(GetJSONQuad(*Element))
                EndIf  
              Case #Float  
                If JSONType(*Element) = #PB_JSON_Number
                  Row()\Column(Label) = StrF(GetJSONFloat(*Element))
                EndIf  
              Case #String
                If JSONType(*Element) = #PB_JSON_String
                  Row()\Column(Label) = GetJSONString(*Element)  
                EndIf  
            EndSelect
            
          EndIf
          
        Next 
        
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure SortValue_(Idx.i, Type.i)
    Define *Element

    *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
    If *Element
      
      Select Type
        Case #Integer
          If JSONType(*Element) = #PB_JSON_Number
            jDB()\Table()\Selected()\Integer = GetJSONInteger(*Element)
          EndIf   
        Case #Double
          If JSONType(*Element) = #PB_JSON_Number
            jDB()\Table()\Selected()\Double  = GetJSONDouble(*Element)
          EndIf  
        Case #Quad
          If JSONType(*Element) = #PB_JSON_Number
            jDB()\Table()\Selected()\Quad    = GetJSONQuad(*Element)
          EndIf  
        Case #Float
          If JSONType(*Element) = #PB_JSON_Number
            jDB()\Table()\Selected()\Float   = GetJSONFloat(*Element)
          EndIf  
        Case #String  
          If JSONType(*Element) = #PB_JSON_String
            jDB()\Table()\Selected()\String  = GetJSONString(*Element)
          EndIf  
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure SortList_(Type, Flags)
    
    Select Type
      Case #Integer
        SortStructuredList(jDB()\Table()\Selected(), Flags, OffsetOf(jDB_Row_Structure\Integer),  #PB_Integer)
      Case #Double  
        SortStructuredList(jDB()\Table()\Selected(), Flags, OffsetOf(jDB_Row_Structure\Double), #PB_Double)
      Case #Quad
        SortStructuredList(jDB()\Table()\Selected(), Flags, OffsetOf(jDB_Row_Structure\Quad),   #PB_Quad)
      Case #Float  
        SortStructuredList(jDB()\Table()\Selected(), Flags, OffsetOf(jDB_Row_Structure\Float),  #PB_Float)
      Case #String
        SortStructuredList(jDB()\Table()\Selected(), Flags, OffsetOf(jDB_Row_Structure\String), #PB_String)
    EndSelect
    
  EndProcedure
 
  ;- ----- Compress -----
  
  Procedure.i CompressJSON_(Pack.i, PackedFileName.s)
    Define.i Size, MemSize, Result
    Define   *JSON
    
    If PackedFileName = "" : PackedFileName = jDB()\Name + ".dbj" : EndIf 
    PackedFileName = EscapeStrg_(PackedFileName)
   
    If IsJSON(jDB()\JSON)
      
      Size = ExportJSONSize(jDB()\JSON)
      If Size
        
        MemSize = Size
        If jDB()\Key : MemSize + 48 : EndIf
        
        *JSON = AllocateMemory(MemSize)
        If *JSON
          If ExportJSON(jDB()\JSON, *JSON, Size)
            
            If jDB()\Key
              
              CompilerIf #Enable_Encryption
                Result = AddCryptMemory_(Pack, *JSON, Size, PackedFileName, jDB()\Key)
              CompilerElse
                Result = AddPackMemory(Pack, *JSON, Size, PackedFileName)
              CompilerEndIf
              
            Else  
              Result = AddPackMemory(Pack, *JSON, Size, PackedFileName)
            EndIf
          
          EndIf 
          FreeMemory(*JSON)
        EndIf
      EndIf   
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i UncompressJSON(Pack.i, PackedFileName.s, Key.s="")
    Define.i Size, Result
    Define   *JSON
    
    PackedFileName = EscapeStrg_(PackedFileName)
    
    If ExaminePack(Pack)
      
      While NextPackEntry(Pack)
        
        If PackEntryName(Pack) = GetFilePart(PackedFileName)
          
          Size = PackEntrySize(Pack)
          
          *JSON = AllocateMemory(Size)
          If *JSON
            
            If UncompressPackMemory(Pack, *JSON, Size)
              
              CompilerIf #Enable_Encryption
                
                If Key : Size = DecryptMemory_(*JSON, Size, StringFingerprint(Key, #PB_Cipher_SHA3)) : EndIf
                
              CompilerEndIf
              
              If Size > 0
                Result = CatchJSON(jDB()\JSON, *JSON, Size)
                If Result : InitDatabase_(Key) : EndIf
              EndIf
            EndIf 

            FreeMemory(*JSON)
          EndIf
          
          ProcedureReturn Result
        EndIf
        
      Wend
      
    EndIf
    
  EndProcedure
  
  ;- ==================================
	;-   Module - Declared Procedures
	;- ==================================
  
  ;- ----- Open & Save Database -----
  
  Procedure.i Open(DB.i, File.s, Key.s="", Flags.i=#False)
    Define.i FileID, PackID, FileSize, Encrypted, Result
    Define   Footer.Footer_Structure
    Define   *JSON
    
    If FindMapElement(jDB(), Str(DB)) ;{ ERROR: DB exists
      jDB()\Error = #ERROR_DATABASE_ALREADY_EXISTS
      ProcedureReturn #False
    EndIf ;}
    
    If DB = #PB_Any
      DB = 1 : While FindMapElement(jDB(), Str(DB)) : DB + 1 : Wend
    EndIf
    
    If AddMapElement(jDB(), Str(DB))
      
      jDB()\JSON = DB
      jDB()\File = File
      
      CompilerIf #Enable_Encryption
        
        If Flags & #Compressed
          
          PackID = OpenPack(#PB_Any, File, #PB_PackerPlugin_Zip)
          If PackID
            UncompressJSON(PackID, File, Key)
            ClosePack(PackID) 
          EndIf

        ElseIf Key
          
          FileID = ReadFile(#PB_Any, File)
          If FileID
            
            FileSize = Lof(FileID)
            
            ReadFileFooter_(FileID, FileSize, @Footer)
            
            If Footer\ID = #qAES ;{ Check file footer
              FileSize - 48
              qAES\Hash = Footer\Hash
              Encrypted = #True
            Else  
              qAES\Hash  = ""
              ;}
            EndIf 
            
            *JSON = AllocateMemory(FileSize)
            If *JSON
              
              If ReadData(FileID, *JSON, FileSize)
                
                If Encrypted
                  
                  If DecryptBuffer_(*JSON, FileSize, StringFingerprint(Key, #PB_Cipher_SHA3), Footer\Counter) 
                    jDB()\JSON = CatchJSON(#PB_Any, *JSON, FileSize)
                  EndIf
                  
                Else
                  jDB()\JSON = CatchJSON(#PB_Any, *JSON, FileSize)
                EndIf      
                
                CloseFile(FileID)
              EndIf  
            
              FreeMemory(*JSON)
            EndIf 
            
          EndIf
          
        Else
          
          jDB()\JSON = LoadJSON(#PB_Any, File)
          
        EndIf  
        
      CompilerElse
        
        If Flags & #Compressed
          
          PackID = OpenPack(#PB_Any, File, #PB_PackerPlugin_Zip)
          If PackID
            UncompressJSON(PackID, File, Key)
            ClosePack(PackID) 
          EndIf
          
        Else
          
          jDB()\JSON = LoadJSON(#PB_Any, File)
          
        EndIf
        
      CompilerEndIf
      
      If jDB()\JSON : InitDatabase_(Key) : EndIf
      
    EndIf
    
    ProcedureReturn jDB()\Root
  EndProcedure
  
  Procedure.i Save(DB.i, File.s="", Flags.i=#False) 
    ; Flags: #Compressed / #PB_JSON_PrettyPrint 
    Define.i Result, Size, Pack
    Define   *JSON
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If File = "" : File = jDB()\File : EndIf 
      If File
        
        CompilerIf #Enable_Encryption

          If Flags & #Compressed
          
            Pack = CreatePack(#PB_Any, File) 
            If Pack
              CompressJSON_(Pack, File)
              ClosePack(Pack) 
            EndIf
            
          ElseIf jDB()\Key
            
            Size = ExportJSONSize(jDB()\JSON)
            If Size
              *JSON = AllocateMemory(Size + 48)
              If *JSON
                If ExportJSON(jDB()\JSON, *JSON, Size)
                  Result = WriteEncryptedFile_(File, *JSON, Size, jDB()\Key) 
                EndIf
                FreeMemory(*JSON)
              EndIf
            EndIf  
            
          Else
            
            Result = SaveJSON(jDB()\JSON, File, Flags)

          EndIf
          
          ProcedureReturn Result
        CompilerElse
          
          If Flags & #Compressed
           
            Pack = CreatePack(#PB_Any, File) 
            If Pack
              CompressJSON_(Pack, File)
              ClosePack(Pack) 
            EndIf
            
          Else  
            Result = SaveJSON(jDB()\JSON, File, Flags)
          EndIf
          
          ProcedureReturn Result
        CompilerEndIf
        
      EndIf
      
    Else
      
      jDB()\Error = #ERROR_DATABASE_NOT_EXISTS
      
      ProcedureReturn #False
    EndIf
    
  EndProcedure  

  Procedure.i AddPack(DB.i, Pack.i, PackedFileName.s="") 
    Define.i Result
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Result = CompressJSON_(Pack, PackedFileName)
      
    EndIf  
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i UncompressPack(DB.i, Pack.i, PackedFileName.s, Key.s="")
    Define.i Result
    
    If FindMapElement(jDB(), Str(DB)) ;{ ERROR: DB exists
      jDB()\Error = #ERROR_DATABASE_ALREADY_EXISTS
      ProcedureReturn #False
    EndIf ;}
    
    If DB = #PB_Any
      DB = 1 : While FindMapElement(jDB(), Str(DB)) : DB + 1 : Wend
    EndIf
    
    If AddMapElement(jDB(), Str(DB))
      
      jDB()\JSON = DB
      jDB()\File = PackedFileName
      
      Result = UncompressJSON(Pack, PackedFileName, Key)
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure  
 
  Procedure   Close(DB.i)
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)

      FreeJSON(jDB()\JSON)
      
      DeleteMapElement(jDB())
      
    EndIf
    
  EndProcedure  
  
  
  ;- ----- Create Database -----
  
  Procedure.i Create(DB.i, DatabaseName.s, Key.s="")
    
    If FindMapElement(jDB(), Str(DB)) ;{ ERROR: DB exists
      jDB()\Error = #ERROR_DATABASE_ALREADY_EXISTS
      ProcedureReturn #False
    EndIf ;}
    
    If DB = #PB_Any
      DB = 1 : While FindMapElement(jDB(), Str(DB)) : DB + 1 : Wend
    EndIf
    
    If AddMapElement(jDB(), Str(DB))
      
      jDB()\Name = DatabaseName
      
      If Key : jDB()\Key  = StringFingerprint(Key, #PB_Cipher_SHA3) : EndIf 

      jDB()\JSON = CreateJSON(#PB_Any)
      If jDB()\JSON
        jDB()\Root = JSONValue(jDB()\JSON)
        SetJSONObject(jDB()\Root)
        SetJSONString(AddJSONMember(jDB()\Root, "Database"), jDB()\Name)
        SetJSONString(AddJSONMember(jDB()\Root, "Password"), jDB()\Key)
        
        ; Internal Table 'jDB-Combine'
        If AddMapElement(jDB()\Table(), #Combined)
          jDB()\Table()\jTable = SetJSONObject(AddJSONMember(jDB()\Root, #Combined))
          jDB()\Table()\jStruc = SetJSONObject(AddJSONMember(jDB()\Table()\jTable, #Structure))
          SetJSONArray(AddJSONMember(jDB()\Table()\jStruc,   "Label"))
          SetJSONArray(AddJSONMember(jDB()\Table()\jStruc,   "Type"))
          SetJSONInteger(AddJSONMember(jDB()\Table()\jStruc, "Rows"), 0)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn jDB()\Root
  EndProcedure
  
  Procedure   AddTable(DB.i, Table.s)
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If FindMapElement(jDB()\Table(), Table) ;{ ERROR Table exists
        jDB()\Error = #ERROR_TABLE_ALREADY_EXISTS
        ProcedureReturn #False
      EndIf ;}
      
      If AddMapElement(jDB()\Table(), Table)
        jDB()\Table()\jTable = SetJSONObject(AddJSONMember(jDB()\Root, Table))
        jDB()\Table()\jStruc = SetJSONObject(AddJSONMember(jDB()\Table()\jTable, #Structure))
        SetJSONArray(AddJSONMember(jDB()\Table()\jStruc,   "Label"))
        SetJSONArray(AddJSONMember(jDB()\Table()\jStruc,   "Type"))
        SetJSONInteger(AddJSONMember(jDB()\Table()\jStruc, "Rows"), 0)
      EndIf

    EndIf 
    
    ProcedureReturn jDB()\Table()\jTable
  EndProcedure
  
  Procedure.i AddColumn(DB.i, Label.s, Type.i) 
    Define.i Idx
    Define.s Label
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If FindMapElement(jDB()\Table()\ColIdx(), Label) ;{ ERROR Label exists
        jDB()\Error = #ERROR_COLUMN_ALREADY_EXISTS
        ProcedureReturn #False
      EndIf ;}
      
      If AddElement(jDB()\Table()\Column())
        Idx   = ListIndex(jDB()\Table()\Column())
        jDB()\Table()\Column()\Label = Label
        jDB()\Table()\Column()\Type  = Type
        jDB()\Table()\ColIdx(Label)  = Idx
        SetJSONString(AddJSONElement(GetJSONMember(jDB()\Table()\jStruc,  "Label"), Idx), Label)
        SetJSONInteger(AddJSONElement(GetJSONMember(jDB()\Table()\jStruc, "Type"),  Idx), Type)
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_EXISTS
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  Procedure.i AddDataset(DB.i, DataSet.s, ID.s=#UID, Separator.s="|")
    ; DataSet: "ColumnContent1|ColumnContent2|ColumnContent3"
    Define.s Table
    Define.i UID, Col = 1
    Define   *DBRow, *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Table = MapKey(jDB()\Table())

      If ID = "" Or ID = #UID
        UID(Str(DB))\Table(Table) + 1
        ID = Str(UID(Str(DB))\Table(Table))
      ElseIf  ID = #UUID  
        ID = UUID_()
      EndIf 

      *DBRow = SetJSONArray(AddJSONMember(jDB()\Table()\jTable, ID))
      If *DBRow
        
        jDB()\Table()\Row(ID) = *DBRow
        
        jDB()\Table()\Rows + 1
        
        ForEach jDB()\Table()\Column()
          
          *Element = AddJSONElement(*DBRow)
          If *Element
            
            Select jDB()\Table()\Column()\Type
              Case #String, #Blob
                SetJSONString(*Element,  StringField(DataSet, Col, Separator))
              Case #Integer
                SetJSONInteger(*Element, Val(StringField(DataSet, Col, Separator)))
              Case #Boolean
                SetJSONBoolean(*Element, Val(StringField(DataSet, Col, Separator)))
              Case #Float
                SetJSONFloat(*Element,   ValF(StringField(DataSet, Col, Separator)))
              Case #Double
                SetJSONDouble(*Element,  ValD(StringField(DataSet, Col, Separator)))
              Case #Quad
                SetJSONQuad(*Element,    Val(StringField(DataSet, Col, Separator)))
              Default  
                SetJSONNull(*Element)
            EndSelect
            
          EndIf
          
          Col + 1
        Next
        
        SetJSONInteger(GetJSONMember(jDB()\Table()\jStruc, "Rows"), jDB()\Table()\Rows)
        
      EndIf
      
      ProcedureReturn #True
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_EXISTS
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  
  Procedure.i UpdateDataset(DB.i, DataSet.s, Separator.s="|", Flags=#False) 
    ; DataSet: "ColumnContent1|ColumnContent2|ColumnContent3"
    Define.i UID, Col = 0
    Define   *DBRow, *Element
    Define.s Value
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      ForEach jDB()\Table()\Column() ;{ Change columns
        
        Value = StringField(DataSet, Col + 1, Separator)
        If Value
          
          *Element = GetJSONElement(jDB()\Table()\Row(), Col)
          If *Element
            
            Select jDB()\Table()\Column()\Type
              Case #String, #Blob
                If JSONType(*Element) = #PB_JSON_String
                  SetJSONString(*Element, Value)
                EndIf   
              Case #Integer
                If JSONType(*Element) = #PB_JSON_Number
                  SetJSONInteger(*Element, Val(Value))
                EndIf  
              Case #Boolean
                If JSONType(*Element) = #PB_JSON_Number
                  SetJSONBoolean(*Element, Val(Value))
                EndIf  
              Case #Float
                If JSONType(*Element) = #PB_JSON_Number
                  SetJSONFloat(*Element,   ValF(Value))
                EndIf  
              Case #Double
                If JSONType(*Element) = #PB_JSON_Number
                  SetJSONDouble(*Element,  ValD(Value))
                EndIf  
              Case #Quad
                If JSONType(*Element) = #PB_JSON_Number
                  SetJSONQuad(*Element,    Val(Value))
                EndIf
              Default  
                SetJSONNull(*Element)
            EndSelect
            
          EndIf
          
        EndIf
        
        Col + 1 ;}
      Next
      
      ClearList(jDB()\Table()\Selected())
      
      If AddElement(jDB()\Table()\Selected()) ;{ Selected rows
        Debug ">>>"
        jDB()\Table()\Selected()\Row = jDB()\Table()\Row()
        jDB()\Table()\Selected()\ID = MapKey(jDB()\Table()\Row())
        ;}
      EndIf
      
      If Flags & #CopyToList : CopyToList_() : EndIf
      
      ResetList(jDB()\Table()\Selected())
      
      jDB()\cRow  = #PB_Default
      jDB()\jRow  = #False
      
      ProcedureReturn #True
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_EXISTS
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  
  ;- ----- Delete Table & Rows -----  
  
  Procedure   Drop(DB.i, Table.s)
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If FindMapElement(jDB()\Table(), Table)
        RemoveJSONMember(jDB()\Root, Table)
        DeleteMapElement(jDB()\Table())
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
    EndIf
  EndProcedure  
  
  Procedure.i Delete(DB.i, Expression.s="*", Table.s="")
    ; Expression: "Col1 = Content" or "Col2 >= 18 AND Col2 <= 21"
    Define.i Deleted
    Define *Table
    
    Dim Parse.Parse_Structure(0)
    
    Expression = Trim(Expression)
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If Table : SelectTable_(Table) : EndIf
      
      ClearList(jDB()\Table()\Selected())

      If Expression <> "*" : ParseExpression_(Expression, Parse()) : EndIf
      
      *Table = GetJSONMember(jDB()\Root, Table)

      ForEach jDB()\Table()\Row()
        
        If Expression <> "*"              ;{ Expression

          Select Parse(0)\Operator
            Case "AND"
              If Not (Compare_(0, Parse()) And Compare_(1, Parse())) : Continue : EndIf   
            Case "OR"
              If Not (Compare_(0, Parse()) Or Compare_(1, Parse()))  : Continue : EndIf   
            Default
              If Not Compare_(0, Parse()) : Continue : EndIf
          EndSelect
          ;}
        EndIf
        
        RemoveJSONMember(*Table, MapKey(jDB()\Table()\Row()))
        DeleteMapElement(jDB()\Table()\Row())
        
        Deleted + 1
      Next
      
      jDB()\jRow = #False
      jDB()\cRow  = #PB_Default
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False  
    EndIf
    
    ProcedureReturn Deleted
  EndProcedure  
  
  
  ;- ----- Select & Update -----  

  Procedure.i Table(DB.i, Table.s)
    Define.i Rows
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)

      Rows = SelectTable_(Table)
      
      ProcedureReturn Rows
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False  
    EndIf
    
    ProcedureReturn MapSize(jDB()\Table()\Row())
  EndProcedure
  
  
  Procedure.i SelectRow(DB.i, ID.s, Table.s="", Flags.i=#False)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If Table : SelectTable_(Table) : EndIf 
      
      ClearList(jDB()\Table()\Selected())
      
      If FindMapElement(jDB()\Table()\Row(), ID)

        jDB()\jRow = jDB()\Table()\Row()
        
        If AddElement(jDB()\Table()\Selected())
          jDB()\Table()\Selected()\Row = jDB()\Table()\Row()
          jDB()\jRow = jDB()\Table()\Row()
          jDB()\cRow = ListIndex(jDB()\Table()\Selected())
        EndIf 

        If Flags & #CopyToList : CopyToList_() : EndIf
        
        ProcedureReturn ListSize(jDB()\Table()\Selected())
      Else
        jDB()\Error = #ERROR_LABEL_NOT_FOUND
        jDB()\cRow  = #PB_Default
        ProcedureReturn #False
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False
    EndIf  
    
  EndProcedure
  

  Procedure.i Update(DB.i, Column.s, Value.s, Expression.s="*", Table.s="", Flags.i=#False)
    ; Expression: "Col1 = Content" or "Col2 >= 18 AND Col2 <= 21"
    ; Flags: #CopyToList
    Define.i Idx, ColumnType
    Define.s Label
    Define   *Element
    
    Dim Parse.Parse_Structure(0)
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If Table : SelectTable_(Table) : EndIf

      Idx = jDB()\Table()\ColIdx(Column)
      If SelectElement(jDB()\Table()\Column(), Idx) : ColumnType = jDB()\Table()\Column()\Type : EndIf  
      
      ClearList(jDB()\Table()\Selected())

      If Expression <> "*" : ParseExpression_(Expression, Parse()) : EndIf
      
      ForEach jDB()\Table()\Row()
        
        If Trim(Expression) <> "*"              ;{ Expression

          Select Parse(0)\Operator
            Case "AND"
              If Not (Compare_(0, Parse()) And Compare_(1, Parse())) : Continue : EndIf   
            Case "OR"
              If Not (Compare_(0, Parse()) Or Compare_(1, Parse()))  : Continue : EndIf   
            Default
              If Not Compare_(0, Parse()) : Continue : EndIf
          EndSelect
          ;}
        EndIf
        
        *Element = GetJSONElement(jDB()\Table()\Row(), Idx)
        If *Element
          
          Select ColumnType ;{ Update Column
            Case #Boolean  
              If JSONType(*Element) = #PB_JSON_Boolean
                If Val(Value)
                  SetJSONBoolean(*Element, #True)
                Else
                  SetJSONBoolean(*Element, #False)
                EndIf  
              EndIf  
            Case #Integer 
              If JSONType(*Element) = #PB_JSON_Number
                SetJSONInteger(*Element, Val(Value))
              EndIf  
            Case #Quad
              If JSONType(*Element) = #PB_JSON_Number
                SetJSONQuad(*Element,    Val(Value))
              EndIf  
            Case #Float
              If JSONType(*Element) = #PB_JSON_Number
                SetJSONFloat(*Element,   ValF(Value))
              EndIf  
            Case #Double
              If JSONType(*Element) = #PB_JSON_Number
                SetJSONDouble(*Element,  ValD(Value))
              EndIf  
            Case #String
              If JSONType(*Element) = #PB_JSON_String
                SetJSONString(*Element,  Value)
              EndIf  
          EndSelect ;}
          
        EndIf
        
        If AddElement(jDB()\Table()\Selected()) ;{ Selected rows
          
          jDB()\Table()\Selected()\Row = jDB()\Table()\Row()
          jDB()\Table()\Selected()\ID = MapKey(jDB()\Table()\Row())
          ;}
        EndIf  

      Next
      
      If Flags & #CopyToList : CopyToList_() : EndIf
      
      ResetList(jDB()\Table()\Selected())
      
      jDB()\cRow  = #PB_Default
      jDB()\jRow  = #False
      
      ProcedureReturn ListSize(jDB()\Table()\Selected())
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False  
    EndIf
    
  EndProcedure  
  
  Procedure   FinishUpdate(DB.i, Table.s)
    
    If FindMapElement(jDB(), Str(DB))
      
      If FindMapElement(jDB()\Table(), Table)
        ClearList(jDB()\Table()\Selected())
      EndIf  
      
      jDB()\cTable = ""
      jDB()\cRow   = #PB_Default
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf
    
  EndProcedure   

  
  Procedure.i Query(DB.i, Expression.s="*", Order.s="", Table.s="", Flags.i=#False)
    ; Expression: "Col1 = Content" or "Col2 >= 18 AND Col2 <= 21"
    ; Order: "Col3"
    ; Flags: #CopyToList | #NoCase | #Ascendig / #Descending
    Define.i Idx, SortFlags, SortType, SortIdx, a
    Define.i Result1, Result2
    Define.s Label
    Define   *Element
    
    Dim Parse.Parse_Structure(0)
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If Table : SelectTable_(Table) : EndIf
      
      ClearList(jDB()\Table()\Selected())

      If Flags & #CopyToList : ClearList(Row()) : EndIf

      If Expression <> "*" : ParseExpression_(Expression, Parse()) : EndIf
      
      If Order                                   ;{ SortTyp, SortIndex & SortFlags
        
        If Flags & #Descending
          SortFlags = #Descending
        Else
          SortFlags = #Ascendig
        EndIf
        
        If Flags & #NoCase : SortFlags | #NoCase : EndIf
        
        SortIdx = jDB()\Table()\ColIdx(Order)
        If SelectElement(jDB()\Table()\Column(), SortIdx)
          SortType = jDB()\Table()\Column()\Type
        EndIf
        ;}
      EndIf  
      
      ForEach jDB()\Table()\Row()
        
        If Trim(Expression) <> "*"              ;{ Expression

          Select Parse(0)\Operator
            Case "AND"
              If Not (Compare_(0, Parse()) And Compare_(1, Parse())) : Continue : EndIf   
            Case "OR"
              If Not (Compare_(0, Parse()) Or Compare_(1, Parse()))  : Continue : EndIf   
            Default
              If Not Compare_(0, Parse()) : Continue : EndIf
          EndSelect
          ;}
        EndIf

        If AddElement(jDB()\Table()\Selected()) ;{ Selected rows
          
          jDB()\Table()\Selected()\Row = jDB()\Table()\Row()
          jDB()\Table()\Selected()\ID  = MapKey(jDB()\Table()\Row())
          
          If Order : SortValue_(SortIdx, SortType) : EndIf
          ;}
        EndIf  

      Next
      
      If Order : SortList_(SortType, SortFlags) : EndIf  
      
      If Flags & #CopyToList : CopyToList_() : EndIf

      ResetList(jDB()\Table()\Selected())
      
      jDB()\cRow = #PB_Default
      jDB()\jRow = #False
      
      ProcedureReturn ListSize(jDB()\Table()\Selected())
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf
    
    ProcedureReturn ListSize(jDB()\Table()\Selected())
  EndProcedure
  
  Procedure   FinishQuery(DB.i, Table.s)
    
    If FindMapElement(jDB(), Str(DB))
      
      If FindMapElement(jDB()\Table(), Table)
        ClearList(jDB()\Table()\Selected())
      EndIf  
      
      jDB()\cTable = ""
      jDB()\cRow   = #PB_Default
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf
    
  EndProcedure  
  
  
  Procedure.i Combine(DB.i, Columns.s, Where.s, Order.s="", Flags.i=#False)
    ; Columns: "Table1.Col1, Table2.Col3, Table1.Col5, ..."
    ; Where:   "Table1.Col2 = Table2.Col1"
    ; Order: "Col3"
    Define.s Table1$, Table2$, Column1$, Column2$, Operator$, Column$, ColTyp, Label
    Define.i Idx, ColIdx1, ColIdx2, newCol, ColType, SortIdx, SortType, SortFlags
    Define   *jTable, *jStruc, *Element, *DBRow
    
    NewList Parse.Combine_Structure()
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      ClearMap(jDB()\Table(#Combined)\Row())
      ClearList(jDB()\Table(#Combined)\Selected())
      
      ParseColumns_(Columns, Parse())

      If Where ;{ Parse Where
        
        Operator$ = GetOperator_(Where)
        Column$   = Trim(StringField(Where, 1, Operator$))
        Table1$   = StringField(Column$, 1, ".")
        Column1$  = StringField(Column$, 2, ".")
        Column$   = Trim(StringField(Where, 2, Operator$))
        Table2$   = StringField(Column$, 1, ".")
        Column2$  = StringField(Column$, 2, ".")
        ;}
      EndIf 
      
      If IsSelected_(Table1$) = #False : SelectAll_(Table1$) : EndIf ; all rows if none were previously selected
      If IsSelected_(Table2$) = #False : SelectAll_(Table2$) : EndIf ; all rows if none were previously selected

      ;{ Columns for combining the tables
      ColIdx1 = jDB()\Table(Table1$)\ColIdx(Column1$)
      ColIdx2 = jDB()\Table(Table2$)\ColIdx(Column2$)
      
      If UCase(Column1$) = "ID" Or UCase(Column1$) = "ROW"
        ColType = #String
      ElseIf UCase(Column2$) = "ID" Or UCase(Column2$) = "ROW"
        ColType = #String
      Else  
        If SelectElement(jDB()\Table(Table1$)\Column(), ColIdx1) : ColType = jDB()\Table(Table1$)\Column()\Type : EndIf 
      EndIf ;}
      
      ClearJSONMembers(jDB()\Table(#Combined)\jTable)
      
      jDB()\Table(#Combined)\jStruc = SetJSONObject(AddJSONMember(jDB()\Table(#Combined)\jTable, #Structure))
      SetJSONArray(AddJSONMember(jDB()\Table(#Combined)\jStruc,   "Label"))
      SetJSONArray(AddJSONMember(jDB()\Table(#Combined)\jStruc,   "Type"))
      SetJSONInteger(AddJSONMember(jDB()\Table(#Combined)\jStruc, "Rows"), 0)
      
      ;{ New Columns
      newCol = 0
      
      ClearList(jDB()\Table(#Combined)\Column())
      
      ForEach Parse()
        
        ;{ Name of the new column
        Column$ = Parse()\Column
        If Parse()\Label : Column$ = Parse()\Label : EndIf
        ;}
        
        If AddElement(jDB()\Table(#Combined)\Column())
          
          Idx = jDB()\Table(Parse()\Table)\ColIdx(Parse()\Column)
          If SelectElement(jDB()\Table(Parse()\Table)\Column(), Idx)
          
            jDB()\Table(#Combined)\Column()\Label  = Column$
            jDB()\Table(#Combined)\Column()\Type   = jDB()\Table(Parse()\Table)\Column()\Type
            jDB()\Table(#Combined)\ColIdx(Column$) = newCol

            SetJSONString(AddJSONElement(GetJSONMember(jDB()\Table(#Combined)\jStruc,  "Label"), newCol), jDB()\Table(#Combined)\Column()\Label)
            SetJSONInteger(AddJSONElement(GetJSONMember(jDB()\Table(#Combined)\jStruc, "Type"),  newCol), jDB()\Table(#Combined)\Column()\Type)
          EndIf
          
          newCol + 1
        EndIf
        
      Next ;}
      
      jDB()\Table(#Combined)\Rows = 0
      
      ;{ Combine Tables
      ForEach jDB()\Table(Table1$)\Selected()
        
        ;{ Read value of table 1
        If UCase(Column1$) = "ID" Or UCase(Column1$) = "LABEL" Or UCase(Column1$) = "ROW"
          jDB()\Table(Table1$)\Selected()\String = jDB()\Table(Table1$)\Selected()\ID
        Else  
          *Element = GetJSONElement(jDB()\Table(Table1$)\Selected()\Row, ColIdx1)
          If *Element
            Select ColType
              Case #Integer
                jDB()\Table(Table1$)\Selected()\Integer = GetJSONInteger(*Element)
              Case #Quad
                jDB()\Table(Table1$)\Selected()\Quad    = GetJSONQuad(*Element)
              Case #Float
                jDB()\Table(Table1$)\Selected()\Float   = GetJSONFloat(*Element)
              Case #Double
                jDB()\Table(Table1$)\Selected()\Double  = GetJSONDouble(*Element)
              Default
                jDB()\Table(Table1$)\Selected()\String  = GetJSONString(*Element)
            EndSelect    
          EndIf
        EndIf ;}

        ForEach jDB()\Table(Table2$)\Selected() 
          
          ;{ Read value of table 2
          If UCase(Column2$) = "ID" Or UCase(Column2$) = "LABEL" Or UCase(Column2$) = "ROW"
            jDB()\Table(Table2$)\Selected()\String = jDB()\Table(Table2$)\Selected()\ID
          Else  
            *Element = GetJSONElement(jDB()\Table(Table2$)\Selected()\Row, ColIdx2)
            If *Element
              Select ColType
                Case #Integer
                  jDB()\Table(Table2$)\Selected()\Integer = GetJSONInteger(*Element)
                Case #Quad
                  jDB()\Table(Table2$)\Selected()\Quad    = GetJSONQuad(*Element)
                Case #Float
                  jDB()\Table(Table2$)\Selected()\Float   = GetJSONFloat(*Element)
                Case #Double
                  jDB()\Table(Table2$)\Selected()\Double  = GetJSONDouble(*Element)
                Default
                  jDB()\Table(Table2$)\Selected()\String  = GetJSONString(*Element)
              EndSelect    
            EndIf
          EndIf ;}
          
          If CompareColumns_(Table1$, Table2$, Operator$, ColType)
            
            If AddMapElement(jDB()\Table(#Combined)\Row(), jDB()\Table(Table1$)\Selected()\ID)
              
              *DBRow = SetJSONArray(AddJSONMember(jDB()\Table(#Combined)\jTable, jDB()\Table(Table1$)\Selected()\ID))
              If *DBRow

                jDB()\Table(#Combined)\Row() = *DBRow

                jDB()\Table(#Combined)\Rows + 1
                
                ;{ Selected columns
                ForEach Parse()
                  
                  Idx = jDB()\Table(Parse()\Table)\ColIdx(Parse()\Column)
                  If SelectElement(jDB()\Table(Parse()\Table)\Column(), Idx)
                  
                    ;{ Value & type of the new column
                    *Element = GetJSONElement(jDB()\Table(Parse()\Table)\Selected()\Row, Idx)
                    If *Element
                      Select jDB()\Table(Parse()\Table)\Column()\Type
                        Case #Integer
                          SetJSONInteger(AddJSONElement(*DBRow), GetJSONInteger(*Element))
                        Case #Quad
                          SetJSONQuad(AddJSONElement(*DBRow),    GetJSONQuad(*Element))
                        Case #Float
                          SetJSONFloat(AddJSONElement(*DBRow),   GetJSONFloat(*Element))
                        Case #Double
                          SetJSONDouble(AddJSONElement(*DBRow),  GetJSONDouble(*Element))
                        Default
                          SetJSONString(AddJSONElement(*DBRow),  GetJSONString(*Element))
                      EndSelect 
                    EndIf ;} 
                    
                  EndIf
                  
                Next
                ;}
                
              EndIf
            
            EndIf  
            
          EndIf         
          
        Next 
        
      Next ;}
      
      SetJSONInteger(GetJSONMember(jDB()\Table(#Combined)\jStruc, "Rows"), jDB()\Table(#Combined)\Rows)
      
      SelectTable_(#Combined)
      
      If Order                                   ;{ SortTyp, SortIndex & SortFlags
        
        If Flags & #Descending
          SortFlags = #Descending
        Else
          SortFlags = #Ascendig
        EndIf
        
        If Flags & #NoCase : SortFlags | #NoCase : EndIf
        
        SortIdx = jDB()\Table()\ColIdx(Order)
        If SelectElement(jDB()\Table()\Column(), SortIdx)
          SortType = jDB()\Table()\Column()\Type
        EndIf
        ;}
      EndIf  
      
      ForEach jDB()\Table()\Row()                ;{ Select all rows
        
        If AddElement(jDB()\Table()\Selected())
          
          jDB()\Table()\Selected()\Row   = jDB()\Table()\Row()
          jDB()\Table()\Selected()\ID = MapKey(jDB()\Table()\Row())
          
          If Order : SortValue_(SortIdx, SortType) : EndIf
          
        EndIf ;}
      Next
      
      If Order : SortList_(SortType, SortFlags) : EndIf 
      
      If Flags & #CopyToList : CopyToList_() : EndIf

      jDB()\cTable = #Combined
      jDB()\cRow   = #PB_Default  
     
      ResetList(jDB()\Table()\Selected())
      
      ProcedureReturn ListSize(jDB()\Table()\Selected())
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf
    
  EndProcedure
  
  Procedure   FinishCombine(DB.i)
    
    If FindMapElement(jDB(), Str(DB))
      
      If FindMapElement(jDB()\Table(), #Combined)
        ClearList(jDB()\Table()\Selected())
        ClearMap(jDB()\Table(#Combined)\Row())
        If IsJSON(jDB()\JSON) : ClearJSONMembers(jDB()\Table(#Combined)\jTable) : EndIf
      EndIf  
      
      jDB()\cTable = ""
      jDB()\cRow   = #PB_Default
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf
    
  EndProcedure 
  
  
  Procedure.i Join(DB.i, Columns.s, Where.s, Table.s)
    ; Columns: "Table1.Col1, Table2.Col3, Table1.Col5, ..."
    ; Where:   "Table1.Col2 = Table2.Col1"
    ; Table:   Name of the new table
    Define.s Table1$, Table2$, Column1$, Column2$, Operator$, Column$, ColTyp, Label
    Define.i Idx, ColIdx1, ColIdx2, newCol, ColType
    Define   *jTable, *jStruc, *Element, *DBRow
    
    NewList Parse.Combine_Structure()
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If FindMapElement(jDB()\Table(), Table) ;{ ERROR Table exists
        jDB()\Error = #ERROR_TABLE_ALREADY_EXISTS
        ProcedureReturn #False
      EndIf ;}
      
      If AddMapElement(jDB()\Table(), Table)
        
        ParseColumns_(Columns, Parse())
  
        If Where ;{ Parse Where
          
          Operator$ = GetOperator_(Where)
          Column$   = Trim(StringField(Where, 1, Operator$))
          Table1$   = StringField(Column$, 1, ".")
          Column1$  = StringField(Column$, 2, ".")
          Column$   = Trim(StringField(Where, 2, Operator$))
          Table2$   = StringField(Column$, 1, ".")
          Column2$  = StringField(Column$, 2, ".")
          ;}
        EndIf 
      
        If IsSelected_(Table1$) = #False : SelectAll_(Table1$) : EndIf ; all rows if none were previously selected
        If IsSelected_(Table2$) = #False : SelectAll_(Table2$) : EndIf ; all rows if none were previously selected
  
        ;{ Columns for combining the tables
        ColIdx1 = jDB()\Table(Table1$)\ColIdx(Column1$)
        ColIdx2 = jDB()\Table(Table2$)\ColIdx(Column2$)
        
        If UCase(Column1$) = "ID" Or UCase(Column1$) = "ROW"
          ColType = #String
        ElseIf UCase(Column2$) = "ID" Or UCase(Column2$) = "LABEL" Or UCase(Column2$) = "ROW"
          ColType = #String
        Else  
          If SelectElement(jDB()\Table(Table1$)\Column(), ColIdx1) : ColType = jDB()\Table(Table1$)\Column()\Type : EndIf 
        EndIf ;}
        
        ;{ Add new JSON table
        If FindMapElement(jDB()\Table(), Table)
          
          jDB()\Table()\jTable = SetJSONObject(AddJSONMember(jDB()\Root, Table))
          jDB()\Table()\jStruc = SetJSONObject(AddJSONMember(jDB()\Table()\jTable, #Structure))
          SetJSONArray(AddJSONMember(jDB()\Table()\jStruc,   "Label"))
          SetJSONArray(AddJSONMember(jDB()\Table()\jStruc,   "Type"))
          SetJSONInteger(AddJSONMember(jDB()\Table()\jStruc, "Rows"), 0)
        
          newCol = 0
          
          ForEach Parse()
            
            Column$ = Parse()\Column
            If Parse()\Label : Column$ = Parse()\Label : EndIf
            
            If AddElement(jDB()\Table(Table)\Column())
              
              Idx = jDB()\Table(Parse()\Table)\ColIdx(Parse()\Column)
              If SelectElement(jDB()\Table(Parse()\Table)\Column(), Idx) 
                jDB()\Table(Table)\Column()\Label  = Column$
                jDB()\Table(Table)\Column()\Type   = jDB()\Table(Parse()\Table)\Column()\Type
                jDB()\Table(Table)\ColIdx(Column$) = newCol
                SetJSONString(AddJSONElement(GetJSONMember(jDB()\Table(Table)\jStruc,  "Label"), newCol), jDB()\Table(Table)\Column()\Label)
                SetJSONInteger(AddJSONElement(GetJSONMember(jDB()\Table(Table)\jStruc, "Type"),  newCol), jDB()\Table(Table)\Column()\Type)
              EndIf
              
              newCol + 1
            EndIf
            
          Next
      
          jDB()\Table()\Rows = 0
        EndIf ;}
        
        ;{ Join Tables
        ForEach jDB()\Table(Table1$)\Selected()
          
          ;{ Read value of table 1
          If UCase(Column1$) = "ID" Or UCase(Column1$) = "LABEL" Or UCase(Column1$) = "ROW"
            jDB()\Table(Table1$)\Selected()\String = jDB()\Table(Table1$)\Selected()\ID
          Else  
            *Element = GetJSONElement(jDB()\Table(Table1$)\Selected()\Row, ColIdx1)
            If *Element
              Select ColType
                Case #Integer
                  jDB()\Table(Table1$)\Selected()\Integer = GetJSONInteger(*Element)
                Case #Quad
                  jDB()\Table(Table1$)\Selected()\Quad    = GetJSONQuad(*Element)
                Case #Float
                  jDB()\Table(Table1$)\Selected()\Float   = GetJSONFloat(*Element)
                Case #Double
                  jDB()\Table(Table1$)\Selected()\Double  = GetJSONDouble(*Element)
                Default
                  jDB()\Table(Table1$)\Selected()\String  = GetJSONString(*Element)
              EndSelect    
            EndIf
          EndIf ;}

          ForEach jDB()\Table(Table2$)\Selected() 
            
            ;{ Read value of table 2
            If UCase(Column2$) = "ID" Or UCase(Column2$) = "LABEL" Or UCase(Column2$) = "ROW"
              jDB()\Table(Table2$)\Selected()\String = jDB()\Table(Table2$)\Selected()\ID
            Else  
              *Element = GetJSONElement(jDB()\Table(Table2$)\Selected()\Row, ColIdx2)
              If *Element
                Select ColType
                  Case #Integer
                    jDB()\Table(Table2$)\Selected()\Integer = GetJSONInteger(*Element)
                  Case #Quad
                    jDB()\Table(Table2$)\Selected()\Quad    = GetJSONQuad(*Element)
                  Case #Float
                    jDB()\Table(Table2$)\Selected()\Float   = GetJSONFloat(*Element)
                  Case #Double
                    jDB()\Table(Table2$)\Selected()\Double  = GetJSONDouble(*Element)
                  Default
                    jDB()\Table(Table2$)\Selected()\String  = GetJSONString(*Element)
                EndSelect    
              EndIf
            EndIf ;}
            
            If CompareColumns_(Table1$, Table2$, Operator$, ColType)
              
              If AddMapElement(jDB()\Table(Table)\Row(), jDB()\Table(Table1$)\Selected()\ID)
                
                *DBRow = SetJSONArray(AddJSONMember(jDB()\Table(Table)\jTable, jDB()\Table(Table1$)\Selected()\ID))
                If *DBRow
  
                  jDB()\Table(Table)\Row() = *DBRow
  
                  jDB()\Table(Table)\Rows + 1
                  
                  ;{ Selected columns
                  ForEach Parse()
                    
                    Idx = jDB()\Table(Parse()\Table)\ColIdx(Parse()\Column)
                    If SelectElement(jDB()\Table(Parse()\Table)\Column(), Idx)
                    
                      ;{ Value & type of the new column
                      *Element = GetJSONElement(jDB()\Table(Parse()\Table)\Selected()\Row, Idx)
                      If *Element
                        Select jDB()\Table(Parse()\Table)\Column()\Type
                          Case #Integer
                            SetJSONInteger(AddJSONElement(*DBRow), GetJSONInteger(*Element))
                          Case #Quad
                            SetJSONQuad(AddJSONElement(*DBRow),    GetJSONQuad(*Element))
                          Case #Float
                            SetJSONFloat(AddJSONElement(*DBRow),   GetJSONFloat(*Element))
                          Case #Double
                            SetJSONDouble(AddJSONElement(*DBRow),  GetJSONDouble(*Element))
                          Default
                            SetJSONString(AddJSONElement(*DBRow),  GetJSONString(*Element))
                        EndSelect 
                      EndIf ;} 
                      
                    EndIf
                    
                  Next
                  ;}
                  
                EndIf
              
              EndIf  
              
            EndIf         
            
          Next 
          
        Next ;}
      
        SetJSONInteger(GetJSONMember(jDB()\Table(Table)\jStruc, "Rows"), jDB()\Table(Table)\Rows)
        
        SelectTable_(Table)
  
        jDB()\cTable = Table
        jDB()\cRow   = #PB_Default  
        
        ProcedureReturn jDB()\Table(Table)\Rows
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf
    
  EndProcedure  
  
  
  Procedure.i AffectedRows(DB.i, Table.s="")
    Define.i Rows
    
    If FindMapElement(jDB(), Str(DB))
      
      PushMapPosition(jDB()\Table())
      
      If FindMapElement(jDB()\Table(), Table)
        Rows = ListSize(jDB()\Table()\Selected())
      EndIf 
      
      PopMapPosition(jDB()\Table())
      
      ProcedureReturn Rows
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False   
    EndIf
    
  EndProcedure

  Procedure   Sort(DB.i, Order.s, Table.s="", Flags.i=#False)
    Define.i Idx, SortFlags, SortType, SortIdx
    Define.s Label
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If Table : SelectTable_(Table) : EndIf

      If Flags & #Descending
        SortFlags = #Descending
      Else
        SortFlags = #Ascendig
      EndIf
      
      If Flags & #NoCase : SortFlags | #NoCase : EndIf
      
      SortIdx = jDB()\Table()\ColIdx(Order)
      If SelectElement(jDB()\Table()\Column(), SortIdx)
        SortType = jDB()\Table()\Column()\Type
      EndIf
      
      ForEach jDB()\Table()\Selected()
        SortValue_(SortIdx, SortType)
      Next
      
      If Order : SortList_(SortType, SortFlags) : EndIf 
      
      If Flags & #CopyToList : CopyToList_() : EndIf
      
      ResetList(jDB()\Table()\Selected())
      
      jDB()\cRow = #PB_Default
      jDB()\jRow = #False
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf  
      
  EndProcedure
  
  
  ;- ----- Query rows & columns -----  
 
  Procedure   ResetRows(DB.i)
    
    If FindMapElement(jDB(), Str(DB))
      ResetList(jDB()\Table()\Selected())
      jDB()\jRow = #False
      jDB()\cRow = #PB_Default 
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
    EndIf

  EndProcedure   
  
  Procedure   FirstRow(DB.i)
    
    If FindMapElement(jDB(), Str(DB))
      
      If FirstElement(jDB()\Table()\Selected())
        jDB()\jRow = jDB()\Table()\Selected()\Row
        jDB()\cRow = ListIndex(jDB()\Table()\Selected())
        ProcedureReturn jDB()\cRow
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf

  EndProcedure   

  Procedure   PreviousRow(DB.i)
    
    If FindMapElement(jDB(), Str(DB))
      
      If PreviousElement(jDB()\Table()\Selected())
        jDB()\jRow = jDB()\Table()\Selected()\Row
        jDB()\cRow = ListIndex(jDB()\Table()\Selected())
        ProcedureReturn jDB()\cRow
      EndIf 
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf

  EndProcedure  
  
  Procedure.i NextRow(DB.i)
    
    If FindMapElement(jDB(), Str(DB))

      If NextElement(jDB()\Table()\Selected())
        jDB()\jRow = jDB()\Table()\Selected()\Row
        jDB()\cRow = ListIndex(jDB()\Table()\Selected())
        ProcedureReturn #True
      EndIf 
      
      ProcedureReturn #False
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False  
    EndIf

  EndProcedure
  
  Procedure   LastRow(DB.i)
    
    If FindMapElement(jDB(), Str(DB))
      
      If LastElement(jDB()\Table()\Selected())
        jDB()\jRow = jDB()\Table()\Selected()\Row
        jDB()\cRow = ListIndex(jDB()\Table()\Selected())
        ProcedureReturn jDB()\cRow
      EndIf  
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False 
    EndIf

  EndProcedure
  
  
  Procedure.i ColumnType(DB.i, Column.s)
    Define.i Idx
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)

      Idx = jDB()\Table()\ColIdx(Column)
      
      If SelectElement(jDB()\Table()\Column(), Idx)
        ProcedureReturn jDB()\Table()\Column()\Type  
      EndIf 
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False   
    EndIf 
    
  EndProcedure
  
  Procedure.i CheckNull(DB.i, Column.s)
    Define.i Idx 
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Null 
        ProcedureReturn #True
      EndIf
      
      ProcedureReturn #False
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
    EndIf  
  
  EndProcedure
 
  
  Procedure   GetBoolean(DB.i, Column.s)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Boolean
        ProcedureReturn GetJSONBoolean(*Element)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #PB_Default   
    EndIf   
    
    ProcedureReturn #PB_Default
  EndProcedure
  
  Procedure.i GetInteger(DB.i, Column.s)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        ProcedureReturn GetJSONInteger(*Element)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False   
    EndIf   
    
  EndProcedure
  
  Procedure.q GetQuad(DB.i, Column.s)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
     
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        ProcedureReturn GetJSONQuad(*Element)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False   
    EndIf   
    
  EndProcedure
  
  Procedure.f GetFloat(DB.i, Column.s)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)

      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        ProcedureReturn GetJSONFloat(*Element)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False   
    EndIf   
    
  EndProcedure
  
  Procedure.d GetDouble(DB.i, Column.s)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
     
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        ProcedureReturn GetJSONDouble(*Element)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False   
    EndIf   
    
  EndProcedure
  
  Procedure.s GetString(DB.i, Column.s)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_String
        ProcedureReturn GetJSONString(*Element)
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
    EndIf   
    
  EndProcedure
  

  Procedure.i SaveBlob(DB.i, Column.s, File.s)
    Define.i Idx, Size, FileID, FileSize, Result
    Define.s Blob
    Define   *Buffer, *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_String
        
        Blob = GetJSONString(*Element)
        Size = StringByteLength(Blob, #PB_Ascii)
        
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          FileSize = Base64Decoder(Blob, *Buffer, Size)
          
          FileID = CreateFile(#PB_Any, File)
          If FileID
            Result = WriteData(FileID, *Buffer, FileSize)
            CloseFile(FileID)
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False
    EndIf     
   
  EndProcedure
  
  Procedure.i BlobSize(DB.i, Column.s)
    Define.i Idx, Size
    Define.s Blob
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx  = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_String
        Blob = GetJSONString(*Element)
        Size = StringByteLength(Blob, #PB_Ascii)
      EndIf

      ProcedureReturn Size
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False
    EndIf 
    
  EndProcedure
  
  Procedure.i GetBlob(DB.i, Column.s, *Buffer, Size.i)
    Define.i Idx
    Define.s Blob
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx  = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_String
        Blob = GetJSONString(*Element)
        Size = Base64Decoder(Blob, *Buffer, Size)
      Else
        Size = #False
      EndIf
    
      ProcedureReturn Size
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
      ProcedureReturn #False
    EndIf 
  EndProcedure
  
  
  ;- ----- Change column content -----  
  
  Procedure   SetBoolean(DB.i, Column.s, Value.i)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Boolean
        If Value
          SetJSONBoolean(*Element, #True)
        Else
          SetJSONBoolean(*Element, #False)
        EndIf   
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
    EndIf   
    
  EndProcedure  
  
  Procedure   SetInteger(DB.i, Column.s, Value.i)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        SetJSONInteger(*Element, Value)
      EndIf
      
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND
    EndIf   
    
  EndProcedure
  
  Procedure   SetQuad(DB.i, Column.s, Value.q)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        SetJSONQuad(*Element, Value)
      EndIf
    
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND  
    EndIf   
    
  EndProcedure
  
  Procedure   SetFloat(DB.i, Column.s, Value.f)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        SetJSONFloat(*Element, Value)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND  
    EndIf   
    
  EndProcedure
  
  Procedure   SetDouble(DB.i, Column.s, Value.d)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_Number
        SetJSONDouble(*Element, Value)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND  
    EndIf   
    
  EndProcedure
  
  Procedure   SetString(DB.i, Column.s, Value.s)
    Define.i Idx
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
      If JSONType(*Element) = #PB_JSON_String
        SetJSONString(*Element, Value)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND  
    EndIf   
    
  EndProcedure
  
  
  Procedure   LoadBlob(DB.i, Column.s, File.s)
    Define.i FileID, FileSize, Idx
    Define.s Blob
    Define  *Buffer, *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      Idx = jDB()\Table()\ColIdx(Column)
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        *Buffer = AllocateMemory(FileSize)
        If *Buffer
          
          ReadData(FileID, *Buffer, FileSize)
          Blob = Base64Encoder(*Buffer, FileSize)
          
          *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
          
          SetJSONString(*Element, Blob)
          
          FreeMemory(*Buffer) 
        EndIf
        
        CloseFile(FileID)
      EndIf

    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND  
    EndIf  
   
  EndProcedure
  
  Procedure   SetBlob(DB.i, Column.s, *Buffer, Size)
    Define.i Idx
    Define.s Blob
    Define   *Element
    
    If FindMapElement(jDB(), Str(DB)) And IsJSON(jDB()\JSON)
      
      If *Buffer
        
        Blob = Base64Encoder(*Buffer, Size)
      
        Idx = jDB()\Table()\ColIdx(Column)
        
        *Element = GetJSONElement(jDB()\Table()\Selected()\Row, Idx)
        
        SetJSONString(*Element, Blob)
        
      EndIf
    
    Else
      jDB()\Error = #ERROR_DATABASE_NOT_FOUND  
    EndIf  
    
  EndProcedure
  
  
  Procedure.s MemoryToBlob(*Buffer, Size)
    Define.s Blob

    If *Buffer
      Blob = Base64Encoder(*Buffer, Size)
    EndIf
    
    ProcedureReturn Blob
  EndProcedure
  
  Procedure.s FileToBlob(File.s)
    Define.i FileID, FileSize
    Define.s Blob
    Define  *Buffer

    FileID = ReadFile(#PB_Any, File)
    If FileID
      
      FileSize = Lof(FileID)
      
      *Buffer = AllocateMemory(FileSize)
      If *Buffer
        ReadData(FileID, *Buffer, FileSize)
        Blob = Base64Encoder(*Buffer, FileSize)
        FreeMemory(*Buffer) 
      EndIf
      
      CloseFile(FileID)
    EndIf

    ProcedureReturn Blob
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UseZipPacker()

  #Example = 3
  
  ;  1: jDB::Create()  =>  needed for examples 3 - 6
  ;  2: jDB::AddDataset() with jDB::#UID
  ;  3: jDB::Query() => #CopyToList
  ;  4: jDB::GetString() / jDB::GetInteger()
  ;  5: jDB::NextRow()
  ;  6: jDB::Query() & Sort
  ;  7: jDB::AddPack()   =>  needed for example 8
  ;  8: jDB::UncompressPack()
  ;  9: jDB::Update()
  ; 10: jDB::Delete()
  ; 11: jDB::Combine()
  ; 12: jDB::Join()
  ; 13: jDB::LoadBlob() & jDB::SaveBlob()
  ; 14: jDB::GetBlob()
  ; 15: jDB::SetBlob()
  
  #DB    = 1
  #Pack  = 1
  #Image = 1
  #File  = 1
  
  Select #Example
    Case  1 ;{ jDB::Create()
      
      If jDB::Create(#DB, "Test") ; , "Password"
        
        jDB::AddTable(#DB, "Table")
        
        jDB::AddColumn(#DB, "Name",   jDB::#String)
        jDB::AddColumn(#DB, "Gender", jDB::#String)
        jDB::AddColumn(#DB, "Age",    jDB::#Integer)
        
        jDB::AddDataset(#DB, "Peter|m|18", "Row1")
        jDB::AddDataset(#DB, "Sarah|f|24", "Row2")
        jDB::AddDataset(#DB, "James|m|67", "Row3")
        jDB::AddDataset(#DB, "Megan|f|14", "Row4")
        
        jDB::Save(#DB, "DB_Test.jdb") ; , jDB::#Compressed
        
        jDB::Close(#DB)
      EndIf
      ;}
    Case  2 ;{ jDB::AddDataset() with jDB::#UID
      
      If jDB::Create(#DB, "Test") ; , "Password"
        
        jDB::AddTable(#DB, "Table")
        
        jDB::AddColumn(#DB, "Name",   jDB::#String)
        jDB::AddColumn(#DB, "Gender", jDB::#String)
        jDB::AddColumn(#DB, "Age",    jDB::#Integer)
        
        jDB::AddDataset(#DB, "Peter|m|18", jDB::#UID)
        jDB::AddDataset(#DB, "Sarah|f|24", jDB::#UID)
        jDB::AddDataset(#DB, "James|m|67", jDB::#UID)
        jDB::AddDataset(#DB, "Megan|f|14", jDB::#UID)
        
        jDB::Save(#DB, "DB_UID.jdb")
        
        jDB::Close(#DB)
      EndIf
      ;}
    Case  3 ;{ jDB::Query() => #CopyToList
      
      If jDB::Open(#DB, "DB_Test.jdb") ; , "Password" , jDB::#Compressed

        jDB::Table(#DB, "Table")
        jDB::Query(#DB, "*", "", "", jDB::#CopyToList) ; "Age >= 14 AND Gender = f"
        ;jDB::SelectRow(#DB, "Row2", jDB::#CopyToList)
        
        ForEach jDB::Row()
          Row$ = jDB::Row()\ID + ":"
          ForEach jDB::Row()\Column()
            Row$ + " [" + MapKey(jDB::Row()\Column()) +" : " + jDB::Row()\Column() + "]"
          Next
          Debug Row$
        Next
        
        jDB::FinishQuery(#DB, "Table")
        
        jDB::Close(#DB)
      EndIf
      ;}
    Case  4 ;{ jDB::GetString() / jDB::GetInteger()
      
      If jDB::Open(#DB, "DB_Test.jdb")
        
        jDB::Table(#DB, "Table")
        jDB::SelectRow(#DB, "Row2")
        Debug "Name: " + jDB::GetString(#DB, "Name")
        Debug "Age: "  + Str(jDB::GetInteger(#DB, "Age"))
        
        jDB::Close(#DB)
      EndIf  
      ;}
    Case  5 ;{ jDB::NextRow()
      
      If jDB::Open(#DB, "DB_Test.jdb")
        
        jDB::Query(#DB, "Age >= 18 And Age <= 30", "Name", "Table")
        
        Debug "------------------------"
        
        While jDB::NextRow(#DB)
          Debug "Name: " + jDB::GetString(#DB, "Name")
          Debug "Age: " + Str(jDB::GetInteger(#DB, "Age"))
          Debug "------------------------"
        Wend
        
        jDB::FinishQuery(#DB, "Table")
        
        jDB::Close(#DB)
      EndIf  
      ;}
    Case  6 ;{ jDB::Query() & Sort
      
      If jDB::Open(#DB, "DB_Test.jdb")
        
        jDB::Query(#DB, "*", "Age", "Table", jDB::#Descending)
        
        While jDB::NextRow(#DB)
          Debug "Name: " + jDB::GetString(#DB, "Name")
          Debug "Age: "  + Str(jDB::GetInteger(#DB, "Age"))
          Debug "------------------------"
        Wend
        
        jDB::FinishQuery(#DB, "Table")
        
        jDB::Close(#DB)
      EndIf 
      ;}
    Case  7 ;{ jDB::AddPack()
      
      If jDB::Create(#DB, "Test") ; , "Password"
        
        jDB::AddTable(#DB, "Table")
        
        jDB::AddColumn(#DB, "Name",   jDB::#String)
        jDB::AddColumn(#DB, "Gender", jDB::#String)
        jDB::AddColumn(#DB, "Age",    jDB::#Integer)
        
        jDB::AddDataset(#DB, "Peter|m|18", "Row1")
        jDB::AddDataset(#DB, "Sarah|f|24", "Row2")
        jDB::AddDataset(#DB, "James|m|67", "Row3")
        jDB::AddDataset(#DB, "Megan|f|14", "Row4")
        
        If CreatePack(#Pack, "Test.zip") 
          
          jDB::AddPack(#DB, #Pack, "Test.dbj")
        
          ClosePack(#Pack) 
        EndIf
        
        jDB::Close(#DB)
      EndIf
      ;}
    Case  8 ;{ jDB::UncompressPack()
      
      If OpenPack(#Pack, "Test.zip", #PB_PackerPlugin_Zip)
        
        jDB::UncompressPack(#DB, #Pack, "Test.dbj") ; , "Password"
        
        ClosePack(#Pack) 
      EndIf
      
      If jDB::Table(#DB, "Table")
        
        jDB::Query(#DB, "*", "Name", "", jDB::#CopyToList)
        
        ForEach jDB::Row()
          Row$ = jDB::Row()\ID + ":"
          ForEach jDB::Row()\Column()
            Row$ + " [" + MapKey(jDB::Row()\Column()) +" : " + jDB::Row()\Column() + "]"
          Next
          Debug Row$
        Next
        
        jDB::FinishQuery(#DB, "Table")

        jDB::Close(#DB)
      EndIf
      ;}
    Case  9 ;{ jDB::Update()
      
      If jDB::Open(#DB, "DB_Test.jdb") ; , "Password"

        jDB::Update(#DB, "Age", "21", "Name = Sarah", "Table", jDB::#CopyToList)
        
        ;If jDB::SelectRow(#DB, "Row2", "Table")
        ;  jDB::UpdateDataset(#DB, "Sara|f|21", "|", jDB::#CopyToList)
        ;EndIf
        
        ForEach jDB::Row()
          Row$ = jDB::Row()\ID + ":"
          ForEach jDB::Row()\Column()
            Row$ + " [" + MapKey(jDB::Row()\Column()) +" : " + jDB::Row()\Column() + "]"
          Next
          Debug Row$
        Next
        
        jDB::FinishUpdate(#DB, "Table")
        
        jDB::Close(#DB)
      EndIf
      ;}
    Case 10 ;{ jDB::Delete()
      
      If jDB::Open(#DB, "DB_Test.jdb")
        
        jDB::Delete(#DB, "Age >= 18 AND Age <= 30", "Table")
        
        jDB::Query(#DB, "*", "Name", "Table", jDB::#CopyToList)
        
        ForEach jDB::Row()
          Row$ = jDB::Row()\ID + ":"
          ForEach jDB::Row()\Column()
            Row$ + " [" + MapKey(jDB::Row()\Column()) +" : " + jDB::Row()\Column() + "]"
          Next
          Debug Row$
        Next
        
        jDB::Save(#DB, "DB_Test.jdb")
        
        jDB::Close(#DB)
      EndIf  
      ;}
    Case 11 ;{ jDB::Combine()

      If jDB::Create(#DB, "Test2") ;{ Create database with two tables
        
        jDB::AddTable(#DB, "Table1")
        
        jDB::AddColumn(#DB, "FirstName", jDB::#String)
        jDB::AddColumn(#DB, "LastName",  jDB::#String)
        jDB::AddColumn(#DB, "Position",  jDB::#Integer)
        
        jDB::AddDataset(#DB, "John|Smith|1",     "Row1")
        jDB::AddDataset(#DB, "Sarah|Anderson|3", "Row2")
        jDB::AddDataset(#DB, "James|Doe|2",      "Row3")
        jDB::AddDataset(#DB, "Megan|Hunt|4",     "Row4")
        
        
        jDB::AddTable(#DB, "Table2")
        jDB::AddColumn(#DB, "Position",  jDB::#Integer)
        jDB::AddColumn(#DB, "Title",     jDB::#String)
        
        jDB::AddDataset(#DB, "1|Manager")
        jDB::AddDataset(#DB, "2|Project Planner")
        jDB::AddDataset(#DB, "3|Programmer")
        jDB::AddDataset(#DB, "4|Data Analyst")
        
        jDB::Save(#DB, "DB_Combine.jdb", #PB_JSON_PrettyPrint)

        jDB::Close(#DB) ;}
      EndIf
      
      If jDB::Open(#DB, "DB_Combine.jdb") 

        jDB::Combine(#DB, "Table1.FirstName, Table1.LastName, Table2.Title", "Table1.Position = Table2.Position", "FirstName", jDB::#CopyToList)
        
        ForEach jDB::Row()
          Debug jDB::Row()\Column("FirstName") + " " + jDB::Row()\Column("LastName") + " (" + jDB::Row()\Column("Title") + ")"
        Next

        jDB::FinishCombine(#DB)
        
        jDB::Close(#DB)
      EndIf
      ;}  
    Case 12 ;{ jDB::Join()
      
      If jDB::Create(#DB, "Test3") ;{ Create database with two tables
        
        jDB::AddTable(#DB, "Table1")
        
        jDB::AddColumn(#DB, "FirstName", jDB::#String)
        jDB::AddColumn(#DB, "LastName",  jDB::#String)
        jDB::AddColumn(#DB, "Position",  jDB::#Integer)
        
        jDB::AddDataset(#DB, "John|Smith|1",     "Row1")
        jDB::AddDataset(#DB, "Sarah|Anderson|3", "Row2")
        jDB::AddDataset(#DB, "James|Doe|2",      "Row3")
        jDB::AddDataset(#DB, "Megan|Hunt|4",     "Row4")
        
        
        jDB::AddTable(#DB, "Table2")
        jDB::AddColumn(#DB, "Position", jDB::#Integer)
        jDB::AddColumn(#DB, "Title",    jDB::#String)
        
        jDB::AddDataset(#DB, "1|Manager")
        jDB::AddDataset(#DB, "2|Project Planner")
        jDB::AddDataset(#DB, "3|Programmer")
        jDB::AddDataset(#DB, "4|Data Analyst")
        
        jDB::Save(#DB, "DB_Join.jdb", #PB_JSON_PrettyPrint)

        jDB::Close(#DB) ;}
      EndIf
      
      If jDB::Open(#DB, "DB_Join.jdb") 

        jDB::Join(#DB, "Table1.FirstName, Table1.LastName, Table2.Title", "Table1.Position = Table2.Position", "Table3")
        
        jDB::Query(#DB, "*", "FirstName", "Table3", jDB::#CopyToList) 
        
        ForEach jDB::Row()
          Debug jDB::Row()\Column("FirstName") + " " + jDB::Row()\Column("LastName") + " (" + jDB::Row()\Column("Title") + ")"
        Next
        
        jDB::FinishQuery(#DB, "Table3")
        
        jDB::Save(#DB, "DB_Join.jdb", #PB_JSON_PrettyPrint)
        
        jDB::Close(#DB)
      EndIf
      ;}  
    Case 13 ;{ jDB::LoadBlob() & jDB::SaveBlob()
      
      If jDB::Create(#DB, "Blob") ;{ Create database
        
        jDB::AddTable(#DB, "Table")
        
        jDB::AddColumn(#DB, "Image", jDB::#String)
        jDB::AddColumn(#DB, "Blob",  jDB::#Blob)
        
        Blob$ = jDB::FileToBlob("Test.jpg")
        
        jDB::AddDataset(#DB, "Screen|" + Blob$, "Row1")
        
        jDB::Save(#DB, "DB_Blob.jdb")
        
        jDB::Close(#DB) ;}
      EndIf
      
      If jDB::Open(#DB, "DB_Blob.jdb") 
        
        If jDB::SelectRow(#DB, "Row1", "Table")
          jDB::SaveBlob(#DB, "Blob", "Blob.jpg") 
        EndIf
        
        jDB::Close(#DB)
      EndIf
      ;}
    Case 14 ;{ jDB::GetBlob()
      
      UseJPEGImageEncoder()
      UseJPEGImageDecoder()
      
      If jDB::Create(#DB, "Blob") ;{ Create database
        
        jDB::AddTable(#DB, "Table")
        
        jDB::AddColumn(#DB, "Image", jDB::#String)
        jDB::AddColumn(#DB, "Blob",  jDB::#Blob)
        
        Blob$ = jDB::FileToBlob("Test.jpg")
        
        jDB::AddDataset(#DB, "Screen|" + Blob$, "Row1")
        
        jDB::Save(#DB, "DB_Blob.jdb")
        
        jDB::Close(#DB) ;}
      EndIf
      
      If jDB::Open(#DB, "DB_Blob.jdb") 
        
        If jDB::SelectRow(#DB, "Row1", "Table")
          
          Size.i = jDB::BlobSize(#DB, "Blob")
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            ImgSize.i = jDB::GetBlob(#DB, "Blob", *Buffer, Size)
            If CatchImage(#Image, *Buffer, ImgSize)
              SaveImage(#Image, "Catch.jpg", #PB_ImagePlugin_JPEG)
            EndIf
          EndIf

        EndIf
        
        jDB::Close(#DB)
      EndIf
      ;}
    Case 15 ;{ jDB::SetBlob()

      If jDB::Create(#DB, "Blob") ;{ Create database
        
        jDB::AddTable(#DB, "Table")
        
        jDB::AddColumn(#DB,  "Image", jDB::#String)
        jDB::AddColumn(#DB,  "Blob",  jDB::#Blob)

        jDB::AddDataset(#DB, "Screen|", "Row1")
        
        jDB::Save(#DB, "DB_Blob.jdb")
        
        jDB::Close(#DB) ;}
      EndIf
      
      If jDB::Open(#DB, "DB_Blob.jdb") 
        
        If jDB::SelectRow(#DB, "Row1", "Table")
          
          If ReadFile(#File, "Test.jpg")
            
            Size.i = Lof(#File)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              ReadData(#File, *Buffer, Size)
              
              jDB::SetBlob(#DB, "Blob", *Buffer, Size)
              
              FreeMemory(*Buffer)  
            EndIf 
            CloseFile(#File)
          EndIf 

          jDB::SaveBlob(#DB, "Blob", "Blob.jpg")
          
        EndIf
        
        jDB::Close(#DB)
      EndIf
      ;}
  EndSelect
  
CompilerEndIf

; IDE Options = PureBasic 6.00 Beta 10 (Windows - x64)
; CursorPosition = 1861
; Folding = IEAAAfgAABgAgyTAICWgAAAAAEAU2
; EnableXP
; DPIAware