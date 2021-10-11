unit Scores;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TScoreForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblLevel1Time: TLabel;
    lblLevel2Time: TLabel;
    lblLevel3Time: TLabel;
    lblLevel1Name: TLabel;
    lblLevel2Name: TLabel;
    lblLevel3Name: TLabel;
    btnOk: TButton;
    btnClearScores: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnClearScoresClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure DisplayScores;
    procedure WriteScore;
  public
    { Déclarations publiques }
  end;

var
  ScoreForm: TScoreForm;

implementation

uses Main, InputName, IniFiles;

{$R *.DFM}

procedure TScoreForm.btnOkClick(Sender: TObject);
begin
  Close;
end;

{ Affichage des meilleurs temps établis et des identités correspondantes }
procedure TScoreForm.DisplayScores;
begin
  lblLevel1Time.Caption := Format('%d secondes', [BestBeginnerTime]);
  lblLevel2Time.Caption := Format('%d secondes', [BestIntermediateTime]);
  lblLevel3Time.Caption := Format('%d secondes', [BestExpertTime]);
  lblLevel1Name.Caption := BestBeginnerName;
  lblLevel2Name.Caption := BestIntermediateName;
  lblLevel3Name.Caption := BestExpertName;
end;

{ Affichage et sauvegarde des scores }
procedure TScoreForm.FormShow(Sender: TObject);
begin
  { positionnement de la fiche par rapport à la fiche principale }
  Left := Application.MainForm.Left + 4;
  Top := Application.MainForm.Top + 90;
  { écriture "en dur" dans le fichier ini }
  WriteScore;
  { actualisation de l'affichage }
  DisplayScores;
end;

{ Initialisation des scores demandée }
procedure TScoreForm.btnClearScoresClick(Sender: TObject);
begin
  BestBeginnerTime     := 999;
  BestIntermediateTime := 999;
  BestExpertTime       := 999;
  BestBeginnerName     := 'Anonyme';
  BestIntermediateName := 'Anonyme';
  BestExpertName       := 'Anonyme';
  { mise à jour de la fenêtre de saisie dans InputNameForm }
  InputNameForm.edName.Text := 'Anonyme';
  { écriture "en dur" dans le fichier ini }
  WriteScore;
  { mise à jour de l'affichage des scores }
  DisplayScores;
end;

{ Ecriture des scores dans le fichier ini }
procedure TScoreForm.WriteScore;
begin
  with TIniFile.Create(PathAppli + 'Data') do
  try
    WriteInteger('SCORE', 'time1', BestBeginnerTime);
    WriteInteger('SCORE', 'time2', BestIntermediateTime);
    WriteInteger('SCORE', 'time3', BestExpertTime);
    WriteString('SCORE', 'name1', BestBeginnerName);
    WriteString('SCORE', 'name2', BestIntermediateName);
    WriteString('SCORE', 'name3', BestExpertName);
  finally
    Free;
  end;
end;

end.
