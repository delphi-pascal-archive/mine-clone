unit Customer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TCustomerForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edHigh: TEdit;
    edWidth: TEdit;
    edMines: TEdit;
    BtnOk: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure edHighKeyPress(Sender: TObject; var Key: Char);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  CustomerForm: TCustomerForm;

  CustomHeight,             // hauteur de la grille,
  CustomWidth,              // largeur de lagrille,
  CustomMines: Integer;     // et nombre de mines choisies par utilisateur

implementation

uses Main;

{$R *.DFM}

procedure TCustomerForm.btnCancelClick(Sender: TObject);
begin
  CustomWidth  := MainForm.DrawGrid1.ColCount;
  CustomHeight := MainForm.DrawGrid1.RowCount;
  CustomMines  := MainForm.seNumMines.Value;
  Close;
end;

procedure TCustomerForm.FormShow(Sender: TObject);
begin
  Left := Application.MainForm.Left + 4;
  Top := Application.MainForm.Top + 90;
  edHigh.Text := IntToStr(MainForm.DrawGrid1.RowCount);
  edWidth.Text := IntToStr(MainForm.DrawGrid1.ColCount);
  edMines.Text := IntToStr(MainForm.seNumMines.Value);
end;

{ dimensions mini/maxi : je suis un peu plus généreux que WinMine }
const
  COL_MINI = 9;
  COL_MAXI = 50;  // 30 pour WinMine
  ROW_MINI = 9;
  ROW_MAXI = 36;  // 24 pour WinMine

procedure TCustomerForm.BtnOkClick(Sender: TObject);
begin
  CustomWidth   := StrToIntDef(edWidth.Text, COL_MINI);
  if CustomWidth < COL_MINI then
    CustomWidth := COL_MINI
  else
  if CustomWidth > COL_MAXI then
    CustomWidth := COL_MAXI;
  edWidth.Text := IntToStr(CustomWidth);

  CustomHeight  := StrToIntDef(edHigh.Text, ROW_MINI);
  if CustomHeight < ROW_MINI then
    CustomHeight := ROW_MINI
  else
  if CustomHeight > ROW_MAXI then
    CustomHeight := ROW_MAXI;
  edHigh.Text := IntToStr(CustomHeight);

  { pas de limitation, il peut être amusant de tester 0 ou > n cellules }
  CustomMines   := StrToIntDef(edMines.Text, 0);
  
  Close;
end;

{ contrôle basique de la saisie et passage à l'Edit suivant }
procedure TCustomerForm.edHighKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in [#8, #13, '0'..'9']) then Key := #0;
  if Key = #13 then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

end.
