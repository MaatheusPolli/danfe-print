unit UI.Main;

{ Janela principal (GUI VCL): casca fina sobre os servicos montados em App.Container.
  Nenhuma regra de negocio aqui; so coleta entrada, chama o servico e mostra o resultado. }

interface

uses
  Winapi.Messages, Winapi.ShellAPI, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Domain.Interfaces, App.Config;

type
  TFormMain = class(TForm)
  private
    FConfig: TAppConfig;
    FService: IDanfeService;
    FBatch: IBatchProcessor;
    FLog: ILogService;
    FEdtXml: TEdit;
    FEdtSaida: TEdit;
    FMemo: TMemo;
    FBtnGerar: TButton;
    FBtnAbrir: TButton;
    FUltimoPdf: string;
    procedure BtnXmlClick(Sender: TObject);
    procedure BtnGerarClick(Sender: TObject);
    procedure BtnAbrirClick(Sender: TObject);
    procedure BtnLoteClick(Sender: TObject);
    procedure BtnConfigClick(Sender: TObject);
    procedure Mostrar(const ATexto: string);
    procedure CarregarXml(const AArquivo: string);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.SysUtils, Vcl.Dialogs, Vcl.Buttons, Vcl.Controls, Winapi.Windows,
  App.Container, Service.Danfe, Domain.Danfe, UI.Batch, UI.Settings;

procedure TFormMain.DoCreate;
var
  Lbl: TLabel;
  BtnXml, BtnLote, BtnConfig: TButton;
begin
  inherited;
  Caption := 'DanfePrint';
  Position := poScreenCenter;
  ClientWidth := 640;
  ClientHeight := 420;
  DragAcceptFiles(Handle, True);

  FConfig := TAppConfig.Create(TAppConfig.ArquivoPadrao);
  FConfig.Carregar;
  FLog := TAppContainer.CriarLog(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'logs');
  FService := TAppContainer.CriarService(FLog);
  FBatch := TAppContainer.CriarBatch(FService, FLog);

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Caption := 'XML da NF-e/NFC-e (ou arraste aqui):';
  Lbl.SetBounds(12, 12, 300, 15);

  FEdtXml := TEdit.Create(Self);
  FEdtXml.Parent := Self;
  FEdtXml.SetBounds(12, 30, 520, 23);

  BtnXml := TButton.Create(Self);
  BtnXml.Parent := Self;
  BtnXml.Caption := 'Procurar...';
  BtnXml.SetBounds(538, 29, 90, 25);
  BtnXml.OnClick := BtnXmlClick;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Caption := 'PDF de saída (opcional):';
  Lbl.SetBounds(12, 62, 300, 15);

  FEdtSaida := TEdit.Create(Self);
  FEdtSaida.Parent := Self;
  FEdtSaida.SetBounds(12, 80, 616, 23);

  FBtnGerar := TButton.Create(Self);
  FBtnGerar.Parent := Self;
  FBtnGerar.Caption := 'Gerar PDF';
  FBtnGerar.SetBounds(12, 114, 120, 27);
  FBtnGerar.OnClick := BtnGerarClick;

  FBtnAbrir := TButton.Create(Self);
  FBtnAbrir.Parent := Self;
  FBtnAbrir.Caption := 'Abrir PDF';
  FBtnAbrir.Enabled := False;
  FBtnAbrir.SetBounds(140, 114, 120, 27);
  FBtnAbrir.OnClick := BtnAbrirClick;

  BtnLote := TButton.Create(Self);
  BtnLote.Parent := Self;
  BtnLote.Caption := 'Gerar em lote...';
  BtnLote.SetBounds(268, 114, 130, 27);
  BtnLote.OnClick := BtnLoteClick;

  BtnConfig := TButton.Create(Self);
  BtnConfig.Parent := Self;
  BtnConfig.Caption := 'Configurações...';
  BtnConfig.SetBounds(406, 114, 130, 27);
  BtnConfig.OnClick := BtnConfigClick;

  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.ReadOnly := True;
  FMemo.ScrollBars := ssVertical;
  FMemo.SetBounds(12, 152, 616, 256);
end;

procedure TFormMain.DoDestroy;
begin
  DragAcceptFiles(Handle, False);
  FreeAndNil(FConfig);
  inherited;
end;

procedure TFormMain.Mostrar(const ATexto: string);
begin
  FMemo.Lines.Add(ATexto);
end;

procedure TFormMain.CarregarXml(const AArquivo: string);
begin
  FEdtXml.Text := AArquivo;
  FEdtSaida.Text := OutputPadrao(AArquivo, '');
  FBtnAbrir.Enabled := False;
end;

procedure TFormMain.WMDropFiles(var Msg: TWMDropFiles);
var
  Arquivo: array[0..MAX_PATH] of Char;
begin
  try
    if DragQueryFile(Msg.Drop, 0, Arquivo, MAX_PATH) > 0 then
      CarregarXml(Arquivo);
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TFormMain.BtnXmlClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Filter := 'XML de NF-e/NFC-e|*.xml';
    if Dlg.Execute then
      CarregarXml(Dlg.FileName);
  finally
    Dlg.Free;
  end;
end;

procedure TFormMain.BtnGerarClick(Sender: TObject);
var
  R: TDanfeResult;
  Saida: string;
begin
  if Trim(FEdtXml.Text) = '' then
  begin
    ShowMessage('Escolha um arquivo XML primeiro.');
    Exit;
  end;
  Saida := Trim(FEdtSaida.Text);
  if Saida = '' then
    Saida := OutputPadrao(FEdtXml.Text, '');

  FBtnGerar.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    R := FService.GerarPdf(FEdtXml.Text, Saida, FConfig.DanfeOptions);
  finally
    Screen.Cursor := crDefault;
    FBtnGerar.Enabled := True;
  end;

  if R.Success then
  begin
    FUltimoPdf := R.OutputFile;
    FBtnAbrir.Enabled := True;
    Mostrar('Gerado: ' + R.OutputFile);
  end
  else
    Mostrar('Erro: ' + R.ErrorMessage);
end;

procedure TFormMain.BtnAbrirClick(Sender: TObject);
begin
  if FUltimoPdf <> '' then
    ShellExecute(Handle, 'open', PChar(FUltimoPdf), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormMain.BtnLoteClick(Sender: TObject);
var
  Dlg: TFormBatch;
begin
  Dlg := TFormBatch.CreateWithServices(Self, FBatch, FConfig);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TFormMain.BtnConfigClick(Sender: TObject);
var
  Dlg: TFormSettings;
begin
  Dlg := TFormSettings.CreateWithConfig(Self, FConfig);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

end.
