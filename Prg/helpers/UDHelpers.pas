unit UDHelpers;

interface

uses
  System.Classes, Data.DB;

function HasDataSource(AComponent : TComponent; var ADataSource : TDataSource) : Boolean;

implementation

uses
  System.TypInfo;

function HasDataSource(AComponent : TComponent; var ADataSource : TDataSource) : Boolean;

  function GetDataSource(APropName : String) : TDataSource;
  var
    AObject : TObject;
    PInfo : PPropInfo;
  begin
    Result :=  Nil;
    PInfo := GetPropInfo(AComponent, APropName);
    if PInfo = Nil then
      exit;
    AObject := GetObjectProp(AComponent, PInfo);
    Result := TDataSource(AObject);
  end;

begin
  Result :=  False;
  ADataSource := GetDataSource('DataSource');
  if ADataSource <> Nil then
    Result := True;
  if Result then exit;

  ADataSource := GetDataSource('MasterSource');
  if ADataSource <> Nil then
    Result := True;
end;

end.
