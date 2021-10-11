unit InputName;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TInputNameForm = class(TForm)
    Panel1: TPanel;
    lblInformation: TLabel;
    edName: TEdit;
    btnOk: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure edNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edNameKeyPress(Sender: TObject; var Key: Char);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  InputNameForm: TInputNameForm;

implementation

{$R *.DFM}

uses Main;

procedure TInputNameForm.FormShow(Sender: TObject);
const
  Levl: array[1..3] of string = (' débutant.',' intermédiaire.',' expert.');
  Br = #13#10;
begin
  Left := Application.MainForm.Left + 4;
  Top := Application.MainForm.Top + 90;
  lblInformation.Caption :=
  'Vous avez fait le meilleur' + Br +
  'temps' + Br +
  'du niveau' + Levl[GameLevel] + Br +
  'Entrez votre nom.';
  edName.SetFocus;
  edName.SelectAll;
end;

procedure TInputNameForm.btnOkClick(Sender: TObject);
begin
  case GameLevel of
    1: BestBeginnerName := edName.Text;
    2: BestIntermediateName := edName.Text;
    3: BestExpertName := edName.Text;
  end;
  Close;
end;

procedure TInputNameForm.edNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //if Key = VK_RETURN then
  //  btnOk.Click;
end;

procedure TInputNameForm.edNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnOk.Click;
  end;
end;

end.
