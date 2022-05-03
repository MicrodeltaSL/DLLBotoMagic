object dmoExecProc: TdmoExecProc
  OldCreateOrder = False
  Height = 399
  Width = 512
  object qryGetPKFields: TFDQuery
    Connection = fdConnection
    SQL.Strings = (
      'select'
      '    ix.rdb$index_name as index_name,'
      '    sg.rdb$field_name as field_name,'
      '    rc.rdb$relation_name as table_name'
      'from'
      '    rdb$indices ix'
      
        '    join rdb$index_segments sg on ix.rdb$index_name = sg.rdb$ind' +
        'ex_name'
      
        '    join rdb$relation_constraints rc on rc.rdb$index_name = ix.r' +
        'db$index_name'
      ''
      'where'
      '    rc.rdb$constraint_type = '#39'PRIMARY KEY'#39
      '    and rc.rdb$relation_name = :TABLE_NAME')
    Left = 240
    Top = 184
    ParamData = <
      item
        Name = 'TABLE_NAME'
        DataType = ftFixedChar
        ParamType = ptInput
        Size = 31
      end>
    object qryGetPKFieldsINDEX_NAME: TStringField
      FieldName = 'INDEX_NAME'
      Origin = 'RDB$INDEX_NAME'
      FixedChar = True
      Size = 31
    end
    object qryGetPKFieldsFIELD_NAME: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'FIELD_NAME'
      Origin = 'RDB$FIELD_NAME'
      ProviderFlags = []
      ReadOnly = True
      FixedChar = True
      Size = 31
    end
    object qryGetPKFieldsTABLE_NAME: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'TABLE_NAME'
      Origin = 'RDB$RELATION_NAME'
      ProviderFlags = []
      ReadOnly = True
      FixedChar = True
      Size = 31
    end
  end
  object fdConnection: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'CharacterSet=ISO8859_1'
      'Password=masterkey'
      'PageSize=8192'
      'User_Name=sysdba'
      
        'Database=LOCALHOST:C:\Desarrollo\micTaller\micTaller\Dat\Dat\mic' +
        'Taller.FDB'
      'ExtendedMetadata=True')
    Connected = True
    LoginPrompt = False
    Left = 208
    Top = 56
  end
  object qryProc: TFDQuery
    Connection = fdConnection
    Left = 80
    Top = 168
  end
  object fdStoredProc: TFDStoredProc
    Connection = fdConnection
    Left = 344
    Top = 80
  end
end
