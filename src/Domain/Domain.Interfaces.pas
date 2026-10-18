unit Domain.Interfaces;

{$IFDEF FPC}{$mode delphi}{$H+}{$ENDIF}

interface

uses
  Domain.Danfe;

type
  IXmlLoader = interface
    ['{7B1D5C0E-3F2A-4B8E-9E61-2C4A1F0D8A11}']
    function Carregar(const AXmlFile: string): TXmlLoadResult;
  end;

  { Unico ponto que gera o PDF; implementado pela facade do ACBr ou mockado nos testes. }
  IDanfeGenerator = interface
    ['{C2E0A9B4-6D71-4F3C-8B25-5A9E7D3F1B22}']
    function Gerar(const AXmlFile: string; const ANota: TNotaInfo;
      const AOutputFile: string; const AOptions: TDanfeOptions): TDanfeResult;
  end;

  ILogService = interface
    ['{E4F1B7C3-9A28-4D6E-A0B3-7C1D2E5F3C33}']
    procedure Info(const AMessage: string);
    procedure Error(const AMessage: string);
  end;

  IDanfeService = interface
    ['{1A9C3E5F-7B2D-4C8A-B6E4-9D0F2A4C6E44}']
    function GerarPdf(const AXmlFile, AOutputFile: string;
      const AOptions: TDanfeOptions): TDanfeResult;
  end;

  IBatchProcessor = interface
    ['{5D3B7F9A-2C4E-4A6B-8D0F-1E3A5C7E9F55}']
    function GerarLote(const AInputDir, AOutputDir: string;
      const AOptions: TDanfeOptions): TArray<TDanfeResult>;
  end;

implementation

end.
