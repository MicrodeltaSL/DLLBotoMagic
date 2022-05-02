unit DMExecProc;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait;

type
  TdmoExecProc = class(TDataModule)
    qryGetPKFields: TFDQuery;
    fdConnection: TFDConnection;
    qryGetPKFieldsINDEX_NAME: TStringField;
    qryGetPKFieldsFIELD_NAME: TStringField;
    qryGetPKFieldsTABLE_NAME: TStringField;
    qryProc: TFDQuery;
  private
    { Private declarations }
    FProcName  : string;
    FTableName : string;
    FParamsStr : string;
    procedure AsignConectionFromDM(Qry: TFDQuery);
    procedure SetTableName(const Value: string);
    procedure FormatearProcedimiento(Qry: TFDQuery);
    function ExecProcedimiento : boolean;
    procedure RefrescarQry(Qry: TFDQuery);
  public
    { Public declarations }
    property ProcName  : string read FProcName write FProcName;
    property TableName : string read FTableName write SetTableName;
    procedure CargarProcedimiento(Qry: TFDQuery);
  end;

var
  dmoExecProc: TdmoExecProc;

implementation

uses
  System.Generics.Collections, Vcl.Forms, Winapi.Windows;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

const
     RES_FIELD = 'CORRECTO';
     sqlProc = 'Select ' + RES_FIELD + ' from %s';

{ TdmoExecProc }

procedure TdmoExecProc.AsignConectionFromDM(Qry: TFDQuery);
const
     MUSR_ERR = 'No se ha podido assignar la conexión a la BD. No se ha encontrado el componente de conexión.';
var
   ConFD: TFDCustomConnection;
begin
  ConFD := Qry.Connection;
  if not Assigned(ConFD) then
  begin
    raise Exception.Create(MUSR_ERR);
  end;
  { Transferir la conexión entrante a la conexión de la DLL  }
  fdConnection.SharedCliHandle := ConFD.CliHandle;
  { Usará la misma dirección física o sessión del SGBD que la conexión entrante
    y compartirá el mismo estado de la transacción. }
  fdConnection.Connected       := True;
end;

procedure TdmoExecProc.FormatearProcedimiento(Qry: TFDQuery);
const
     NAME_PROC = 'USR$_%s';
     MUSR_ERR = 'No se ha encontrada ningún dataset dónde recoger los datos';
var
   FormatedQry: string;
   prcName: string;
   pkFields: TList<String>;
   I: integer;
begin
  pkFields := TList<String>.Create;
  try
    FParamsStr := '';
    { Get primary key fields of table name }
    qryGetPKFields.ParamByName('TABLE_NAME').Value := FTableName;
    qryGetPKFields.Open;
    qryGetPKFields.First;
//    Application.MessageBox(PChar('table ' + FTableName), PChar(''), MB_ICONERROR);
    while not qryGetPKFields.Eof do
    begin

      if FParamsStr = '' then
      begin
        FParamsStr := '(:' + qryGetPKFieldsFIELD_NAME.AsString;
      end
      else
      begin
        FParamsStr := FParamsStr + ', :' + qryGetPKFieldsFIELD_NAME.AsString;
      end;

      if not pkFields.Contains(qryGetPKFieldsFIELD_NAME.AsString) then
         pkFields.Add(qryGetPKFieldsFIELD_NAME.AsString);

      qryGetPKFields.Next;
    end;

    if FParamsStr <> '' then
    begin
      FParamsStr := FParamsStr + ')';
      prcName    := Format(NAME_PROC, [FProcName]);
      prcName    := prcName + FParamsStr;
    end;

    FormatedQry := Format(sqlProc, [prcName]);
    qryProc.SQL.Text := FormatedQry;

    for I := 0 to pkFields.Count - 1 do
    begin
      qryProc.ParamByName(pkFields[I]).Value := Qry.FieldByName(pkFields[I]).Value;
    end;

  finally
    pkFields.Free;
  end;
end;

procedure TdmoExecProc.RefrescarQry(Qry: TFDQuery);
begin
  Qry.Refresh;
end;

procedure TdmoExecProc.CargarProcedimiento(Qry: TFDQuery);
begin
  AsignConectionFromDM(Qry);
  FormatearProcedimiento(Qry);
  if ExecProcedimiento then
  begin
    // Refrescar los datasets del Módulo de datos origen
    RefrescarQry(Qry);
  end;
end;

function TdmoExecProc.ExecProcedimiento: boolean;
const
     ERR_EJECUTANDO_PROC = 'Se ha producido un error ejecutando el procedimiento %s.' + #10#13;
begin
  Result := false;
  try
    { Execute proc. }
    qryProc.Open;
    { Get output parameter to proc }
    Result := qryProc.FieldByName(RES_FIELD).AsInteger = 1;
  except
    on E: Exception do
    begin
       Application.MessageBox(PCHar(Format(ERR_EJECUTANDO_PROC, [FProcName]) + E.Message), PChar(''), MB_ICONERROR);
    end;
  end;
end;

procedure TdmoExecProc.SetTableName(const Value: string);
const
     MUSR_ERR = 'No se ha asignado ningún nombre de tabla.';
begin
  if Value = '' then
    raise Exception.Create(MUSR_ERR);
  FTableName := Value;
end;

end.
