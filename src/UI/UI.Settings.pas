unit UI.Settings;

{ Dialogo de configuracoes (RF08): logo, orientacao padrao. Persiste via TAppConfig. }

interface

uses
  System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, App.Config;

type
  TFormSettings = class(TForm)
  private
    FConfig: TAppConfig;
    FEdtLogo: TEdit;
    FCmbOrientacao: TComboBox;
    procedure BtnLogoClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
  public
    constructor CreateWithConfig(AOwner: TComponent; AConfig: TAppConfig);
  end;

implementation

uses
  System.SysUtils, Vcl.Dialogs, Vcl.Buttons, Domain.Danfe;

constructor TFormSettings.CreateWithConfig(AOwner: TComponent; AConfig: TAppConfig);
var
  Lbl: TLabel;
  BtnLogo, BtnOk, BtnCancel: TButton;
begin
  inherited Create(AOwner);
  FConfig := AConfig;
  Caption := 'Configurações';
  Position := poOwnerFormCenter;
  ClientWidth := 480;
  ClientHeight := 180;
  BorderStyle := bsDialog;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Caption := 'Logo (PNG/JPG):';
  Lbl.SetBounds(16, 20, 120, 15);

  FEdtLogo := TEdit.Create(Self);
  FEdtLogo.Parent := Self;
  FEdtLogo.SetBounds(16, 38, 340, 23);
  FEdtLogo.Text := FConfig.LogoFile;

  BtnLogo := TButton.Create(Self);
  BtnLogo.Parent := Self;
  BtnLogo.Caption := '...';
  BtnLogo.SetBounds(362, 37, 40, 25);
  BtnLogo.OnClick := BtnLogoClick;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Caption := 'Orientação padrão:';
  Lbl.SetBounds(16, 76, 140, 15);

  FCmbOrientacao := TComboBox.Create(Self);
  FCmbOrientacao.Parent := Self;
  FCmbOrientacao.Style := csDropDownList;
  FCmbOrientacao.Items.Add('retrato');
  FCmbOrientacao.Items.Add('paisagem');
  FCmbOrientacao.ItemIndex := Ord(FConfig.Orientacao);
  FCmbOrientacao.SetBounds(16, 94, 180, 23);

  BtnOk := TButton.Create(Self);
  BtnOk.Parent := Self;
  BtnOk.Caption := 'Salvar';
  BtnOk.Default := True;
  BtnOk.ModalResult := mrNone;
  BtnOk.SetBounds(240, 135, 100, 27);
  BtnOk.OnClick := BtnOkClick;

  BtnCancel := TButton.Create(Self);
  BtnCancel.Parent := Self;
  BtnCancel.Caption := 'Cancelar';
  BtnCancel.Cancel := True;
  BtnCancel.ModalResult := mrCancel;
  BtnCancel.SetBounds(346, 135, 100, 27);
end;

procedure TFormSettings.BtnLogoClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Filter := 'Imagens|*.png;*.jpg;*.jpeg;*.bmp';
    if Dlg.Execute then
      FEdtLogo.Text := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

procedure TFormSettings.BtnOkClick(Sender: TObject);
begin
  FConfig.LogoFile := Trim(FEdtLogo.Text);
  if FCmbOrientacao.ItemIndex = Ord(doPaisagem) then
    FConfig.Orientacao := doPaisagem
  else
    FConfig.Orientacao := doRetrato;
  FConfig.Salvar;
  ModalResult := mrOk;
end;

end.
