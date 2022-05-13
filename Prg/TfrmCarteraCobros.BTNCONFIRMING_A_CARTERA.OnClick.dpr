library TfrmCarteraCobros.BTNCONFIRMING_A_CARTERA.OnClick;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.DBGrids,
  StrUtils,
  DMExecProc in 'DMExecProc.pas',
  FireDAC.Comp.Client,
  System.Types,
  System.TypInfo,
  Data.DB {dmoExecProc: TDataModule},
  UDHelpers in 'helpers\UDHelpers.pas',
  IFUserManager in '..\..\..\micTaller\micTaller\micTaller\Prg\interfaces\IFUserManager.pas';

{$R *.res}

function Inicio(Sender: TObject): Boolean; stdcall;
const
     MUSR_ERR = 'No se ha especificado el datamodulo o el datasource de la ventana en la propiedad HelpKeyWord.';
     MUSR_ERR_NO_DATA_SET = 'No se ha encontrado el dataset del data módulo %s con data source %s indicado en la propiedad HelpKeyWord del botón.';
var
  FormLlamada: TForm;
  FormPrincipal: TForm;
  ButtonName: string;
  DllData: TDllData;
  DMProc: TdmoExecProc;
  dsrc: TDataSource;
  Qry: TFDQuery;
  valsHelpKeyword: TStringDynArray;
  I: integer;
  UserManager  : IUserManager;
begin
  FormLlamada     := TForm(TComponent(sender).Owner);
  FormPrincipal   := TForm(FormLlamada.Owner);
  { Sabemos que el formulario principal puede gestionar usuarios }
  Supports(FormPrincipal, IUserManager, UserManager);

  ButtonName      := TComponent(Sender).Name;
  valsHelpKeyword := SplitString(TControl(Sender).helpKeyWord, '.');

  if length(valsHelpKeyword) < 2 then
    raise Exception.Create(MUSR_ERR);

  DllData.DmoComp  := valsHelpKeyword[0];
  DllData.DsrcComp := valsHelpKeyword[1];

  Qry := nil;

  I := 0;
  while I < FormLlamada.ComponentCount do
  begin
    { See if DataSource name = DllData.DsrcComp }
    if HasDataSource(FormLlamada.Components[I], dsrc) then
    begin
      if     (dsrc.Owner.Name = DllData.DmoComp)
         and (dsrc.Name = DllData.DsrcComp) then
      begin
        Qry := TFDQuery(Dsrc.DataSet);
        if Assigned(Qry) then
          { Salir del bucle. }
          I := FormLlamada.ComponentCount;
      end;
    end;
    Inc(I);
  end;

  if not Assigned(Qry) then
    raise Exception.CreateFmt(MUSR_ERR_NO_DATA_SET, [DllData.DmoComp, DllData.DsrcComp]);

  try
    DMProc           := TdmoExecProc.Create(nil);
    DMProc.ProcName  := ButtonName;
    DMProc.CargarProcedimiento(Qry, UserManager.GetActiveUser.Ejercicio);
  finally
    DMProc.Free;
    result := true;
  end;
end;

exports Inicio;

begin
end.
