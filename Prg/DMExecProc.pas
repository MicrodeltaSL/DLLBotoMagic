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

  TDllData = record
    { string identificativo de un data modulo }
    DmoComp: string;
    { string identificativo de un data source }
    DsrcComp: string;
  end;

  TdmoExecProc = class(TDataModule)
    qryGetPKFields: TFDQuery;
    fdConnection: TFDConnection;
    qryGetPKFieldsINDEX_NAME: TStringField;
    qryGetPKFieldsFIELD_NAME: TStringField;
    qryGetPKFieldsTABLE_NAME: TStringField;
    qryProc: TFDQuery;
    fdStoredProc: TFDStoredProc;
  private
    { Private declarations }
    FProcName  : string;
    procedure AsignConectionFromDM(Qry: TFDQuery);
    procedure FormatearProcedimiento(Qry: TFDQuery; CodEjercicio: integer);
    function ExecProcedimiento : boolean;
  public
    { Public declarations }
    property ProcName  : string read FProcName write FProcName;
    procedure CargarProcedimiento(Qry: TFDQuery; CodEjercicio: integer);
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

{ TdmoExecProc }

procedure TdmoExecProc.AsignConectionFromDM(Qry: TFDQuery);
const
     MUSR_ERR = 'No se ha podido assignar la conexión a la BD. No se ha encontrado el componente de conexión.';
begin
  if not Assigned(Qry.Connection) then
    raise Exception.Create(MUSR_ERR);

  { Transferir la conexión entrante a la conexión de la DLL  }
  fdConnection.SharedCliHandle := Qry.Connection.CliHandle;
  { Usará la misma dirección física o sessión del SGBD que la conexión entrante
    y compartirá el mismo estado de la transacción. }
  fdConnection.Connected       := True;
end;

procedure TdmoExecProc.FormatearProcedimiento(Qry: TFDQuery; CodEjercicio: integer);
const
     NAME_PROC = 'USR$_%s';
     MUSR_ERR = 'No se ha encontrada ningún dataset dónde recoger los datos';
var
   prcName: string;
   I: integer;
begin
  { Componer el nombre del procedimiento. }
  prcName := Format(NAME_PROC, [FProcName]);

  fdStoredProc.Params.Clear;
  fdStoredProc.StoredProcName := prcName;
  fdStoredProc.Prepare;
  fdStoredProc.Params[0].Value := CodEjercicio;
  { Recorrer los parámetros del procedimiento }
  for I := 1 to fdStoredProc.Params.Count - 1 do
  begin
    { Asignar los parametros de entrada. }
    if fdStoredProc.Params[I].ParamType = ptInput then
      fdStoredProc.Params[I].Value := Qry.FieldByName(fdStoredProc.Params[I].Name).Value;
  end;
end;

procedure TdmoExecProc.CargarProcedimiento(Qry: TFDQuery; CodEjercicio: integer);
begin
  AsignConectionFromDM(Qry);
  FormatearProcedimiento(Qry, CodEjercicio);

  if ExecProcedimiento then
    Qry.Refresh;
end;

function TdmoExecProc.ExecProcedimiento: boolean;
const
     ERR_EJECUTANDO_PROC = 'Se ha producido un error ejecutando el procedimiento %s.' + #10#13;
begin
  Result := false;
  try
    fdStoredProc.ExecProc;
    Result := fdStoredProc.Params.ParamByName(RES_FIELD).AsBoolean;
  except
    on E: Exception do
      Application.MessageBox(PCHar(Format(ERR_EJECUTANDO_PROC, [FProcName]) + E.Message), PChar(''), MB_ICONERROR);
  end;
end;

end.
