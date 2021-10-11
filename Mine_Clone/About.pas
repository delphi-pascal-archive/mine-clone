unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, jpeg;

type
  TAboutForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Memo1: TMemo;
    Image1: TImage;
    btnOk: TButton;
    lblURL: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  AboutForm: TAboutForm;

implementation

uses ShellApi;

{$R *.DFM}

procedure TAboutForm.btnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.lblURLClick(Sender: TObject);
const
  Url = 'http://www.delphifr.com/';
begin
  ShellExecute(Handle, 'open', PChar(Url), nil, nil, SW_SHOWNORMAL);
end;

end.
