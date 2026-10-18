unit Infra.XmlDom;

{ Adaptador minimo de XML: isola a diferenca entre o DOM do FPC (fcl-xml)
  e o Xml.XMLDoc do Delphi. Extrai apenas os campos que o XmlLoader usa. }

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

type
  TNFeXmlDados = record
    RootName: string;
    HasInfNFe: Boolean;
    InfNFeId: string;
    IdeMod: string;
    IdeNNF: string;
    IdeSerie: string;
    EmitCNPJ: string;
    HasProtNFe: Boolean;
  end;

{ Retorna False e preenche AErro se o arquivo nao for um XML bem formado. }
function LerDadosNFe(const AFile: string; out ADados: TNFeXmlDados;
  out AErro: string): Boolean;

implementation

uses
  SysUtils,
{$IFDEF FPC}
  DOM, XMLRead;
{$ELSE}
  Winapi.ActiveX, Xml.XMLIntf, Xml.XMLDoc;
{$ENDIF}

type
{$IFDEF FPC}
  TNode = TDOMNode;
{$ELSE}
  TNode = IXMLNode;
{$ENDIF}

function LocalName(const AName: string): string;
var
  P: Integer;
begin
  P := Pos(':', AName);
  if P > 0 then
    Result := Copy(AName, P + 1, MaxInt)
  else
    Result := AName;
end;

function NodeName(N: TNode): string;
begin
  Result := LocalName(string(N.NodeName));
end;

function IsElement(N: TNode): Boolean;
begin
{$IFDEF FPC}
  Result := N.NodeType = ELEMENT_NODE;
{$ELSE}
  Result := N.NodeType = ntElement;
{$ENDIF}
end;

function Child(N: TNode; const AName: string): TNode;
var
{$IFNDEF FPC}
  I: Integer;
{$ENDIF}
  C: TNode;
begin
  Result := nil;
  if N = nil then
    Exit;
{$IFDEF FPC}
  C := N.FirstChild;
  while C <> nil do
  begin
    if IsElement(C) and (NodeName(C) = AName) then
      Exit(C);
    C := C.NextSibling;
  end;
{$ELSE}
  for I := 0 to N.ChildNodes.Count - 1 do
  begin
    C := N.ChildNodes[I];
    if IsElement(C) and (NodeName(C) = AName) then
      Exit(C);
  end;
{$ENDIF}
end;

function Text(N: TNode): string;
begin
  if N = nil then
    Result := ''
  else
    Result := Trim(string(N.TextContent));
end;

function Attr(N: TNode; const AName: string): string;
begin
  Result := '';
  if N = nil then
    Exit;
{$IFDEF FPC}
  if N is TDOMElement then
    Result := string(TDOMElement(N).GetAttribute(DOMString(AName)));
{$ELSE}
  if N.HasAttribute(AName) then
    Result := N.Attributes[AName];
{$ENDIF}
end;

procedure Extrair(Root: TNode; out ADados: TNFeXmlDados);
var
  NFe, Inf, Ide: TNode;
begin
  ADados := Default(TNFeXmlDados);
  ADados.RootName := NodeName(Root);
  if ADados.RootName = 'nfeProc' then
  begin
    NFe := Child(Root, 'NFe');
    ADados.HasProtNFe := Child(Root, 'protNFe') <> nil;
  end
  else
    NFe := Root;
  Inf := Child(NFe, 'infNFe');
  ADados.HasInfNFe := Inf <> nil;
  if Inf = nil then
    Exit;
  ADados.InfNFeId := Attr(Inf, 'Id');
  Ide := Child(Inf, 'ide');
  ADados.IdeMod := Text(Child(Ide, 'mod'));
  ADados.IdeNNF := Text(Child(Ide, 'nNF'));
  ADados.IdeSerie := Text(Child(Ide, 'serie'));
  ADados.EmitCNPJ := Text(Child(Child(Inf, 'emit'), 'CNPJ'));
end;

{$IFDEF FPC}
function LerDadosNFe(const AFile: string; out ADados: TNFeXmlDados;
  out AErro: string): Boolean;
var
  Doc: TXMLDocument;
begin
  ADados := Default(TNFeXmlDados);
  AErro := '';
  Doc := nil;
  try
    try
      ReadXMLFile(Doc, AFile);
      Extrair(Doc.DocumentElement, ADados);
      Result := True;
    except
      on E: Exception do
      begin
        AErro := E.Message;
        Result := False;
      end;
    end;
  finally
    Doc.Free;
  end;
end;
{$ELSE}
function LerDadosNFe(const AFile: string; out ADados: TNFeXmlDados;
  out AErro: string): Boolean;
var
  Doc: IXMLDocument;
  NeedUninit: Boolean;
begin
  ADados := Default(TNFeXmlDados);
  AErro := '';
  NeedUninit := Succeeded(CoInitialize(nil));
  try
    try
      Doc := TXMLDocument.Create(nil);
      Doc.LoadFromFile(AFile);
      Extrair(Doc.DocumentElement, ADados);
      Result := True;
    except
      on E: Exception do
      begin
        AErro := E.Message;
        Result := False;
      end;
    end;
  finally
    Doc := nil;
    if NeedUninit then
      CoUninitialize;
  end;
end;
{$ENDIF}

end.
