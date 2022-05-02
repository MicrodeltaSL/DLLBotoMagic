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
  DMExecProc in 'DMExecProc.pas', FireDAC.Comp.Client {dmoExecProc: TDataModule};

{$R *.res}

function Inicio(Sender: TObject): Boolean; stdcall;
const
     MUSR_ERR = 'No se ha encontrado el dset de la ventana.';
var
  FormLlamada: TForm;
  ButtonName: string;
  TableName: string;
  DMProc: TdmoExecProc;
  Qry: TFDQuery;
  Grid: TDBGrid;
begin
  FormLlamada := TForm(TComponent(sender).Owner);
  ButtonName  := TComponent(Sender).Name;
  TableName   := TControl(Sender).helpKeyWord;
  Grid        := TDBGrid(FormLlamada.FindComponent('dbgrdLista'));
  Qry         := TFDQuery(Grid.DataSource.DataSet);

  if not Assigned(Qry) then
    raise Exception.Create(MUSR_ERR);

  try
    DMProc           := TdmoExecProc.Create(nil);
    DMProc.ProcName  := ButtonName;
    DMProc.TableName := TableName;
    DMProc.CargarProcedimiento(Qry);
  finally
    DMProc.Free;
    result := true;
  end;
end;

exports Inicio;

begin
end.
