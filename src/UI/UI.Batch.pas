unit UI.Batch;

{ Dialogo do modo lote (RF06): pasta de XMLs -> pasta de PDFs + relatorio.csv. }

interface

uses
  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Domain.Interfaces, App.Config;

type
  TFormBatch = class(TForm)
  private
    FBatch: IBatchProcessor;
    FConfig: TAppConfig;
    FEdtEntrada: TEdit;
    FEdtSaida: TEdit;
    FMemo: TMemo;
    FBtnRun: TButton;
    procedure BtnPastaClick(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
  public
    constructor CreateWithServices(AOwner: TComponent; const ABatch: IBatchProcessor;
      AConfig: TAppConfig);
  end;

implementation

uses
  System.SysUtils, Vcl.Dialogs, Vcl.FileCtrl, Domain.Danfe;

constructor TFormBatch.CreateWithServices(AOwner: TComponent;
  const ABatch: IBatchProcessor; AConfig: TAppConfig);
var
  Lbl: TLabel;
  BtnIn, BtnOut: TButton;
begin
  inherited Create(AOwner);
  FBatch := ABatch;
  FConfig := AConfig;
  Caption := 'Gerar em lote';
  Position := poOwnerFormCenter;
  ClientWidth := 560;
  ClientHeight := 340;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Caption := 'Pasta com os XMLs:';
  Lbl.SetBounds(12, 12, 200, 15);

  FEdtEntrada := TEdit.Create(Self);
  FEdtEntrada.Parent := Self;
  FEdtEntrada.SetBounds(12, 30, 440, 23);
  FEdtEntrada.Text := FConfig.UltimaPasta;

  BtnIn := TButton.Create(Self);
  BtnIn.Parent := Self;
  BtnIn.Caption := '...';
  BtnIn.Tag := 1;
  BtnIn.SetBounds(458, 29, 40, 25);
  BtnIn.OnClick := BtnPastaClick;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Caption := 'Pasta de saída (PDFs + relatorio.csv):';
  Lbl.SetBounds(12, 62, 260, 15);

  FEdtSaida := TEdit.Create(Self);
  FEdtSaida.Parent := Self;
  FEdtSaida.SetBounds(12, 80, 440, 23);
  FEdtSaida.Text := FConfig.UltimaPastaSaida;

  BtnOut := TButton.Create(Self);
  BtnOut.Parent := Self;
  BtnOut.Caption := '...';
  BtnOut.Tag := 2;
  BtnOut.SetBounds(458, 79, 40, 25);
  BtnOut.OnClick := BtnPastaClick;

  FBtnRun := TButton.Create(Self);
  FBtnRun.Parent := Self;
  FBtnRun.Caption := 'Gerar lote';
  FBtnRun.SetBounds(12, 114, 120, 27);
  FBtnRun.OnClick := BtnRunClick;

  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.ReadOnly := True;
  FMemo.ScrollBars := ssVertical;
  FMemo.SetBounds(12, 152, 536, 176);
end;

procedure TFormBatch.BtnPastaClick(Sender: TObject);
var
  Dir: string;
  Edt: TEdit;
begin
  Dir := '';
  if TButton(Sender).Tag = 1 then
    Edt := FEdtEntrada
  else
    Edt := FEdtSaida;
  Dir := Edt.Text;
  if SelectDirectory('Escolha a pasta', '', Dir) then
    Edt.Text := Dir;
end;

procedure TFormBatch.BtnRunClick(Sender: TObject);
var
  Resultados: TArray<TDanfeResult>;
  R: TDanfeResult;
  Ok, Erros: Integer;
  Opts: TDanfeOptions;
begin
  if (Trim(FEdtEntrada.Text) = '') or (Trim(FEdtSaida.Text) = '') then
  begin
    ShowMessage('Informe a pasta de entrada e a de saída.');
    Exit;
  end;
  FConfig.UltimaPasta := FEdtEntrada.Text;
  FConfig.UltimaPastaSaida := FEdtSaida.Text;
  FConfig.Salvar;

  Opts := FConfig.DanfeOptions;
  FBtnRun.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    FMemo.Clear;
    Resultados := FBatch.GerarLote(FEdtEntrada.Text, FEdtSaida.Text, Opts);
    Ok := 0;
    Erros := 0;
    for R in Resultados do
    begin
      if R.Success then
      begin
        Inc(Ok);
        FMemo.Lines.Add('OK    ' + ExtractFileName(R.XmlFile));
      end
      else
      begin
        Inc(Erros);
        FMemo.Lines.Add('ERRO  ' + ExtractFileName(R.XmlFile) + ': ' + R.ErrorMessage);
      end;
    end;
    FMemo.Lines.Add('');
    FMemo.Lines.Add(Format('Lote concluído: %d sucesso(s), %d erro(s)', [Ok, Erros]));
  finally
    Screen.Cursor := crDefault;
    FBtnRun.Enabled := True;
  end;
end;

end.
