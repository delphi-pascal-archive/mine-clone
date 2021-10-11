program MineClone;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  About in 'About.pas' {AboutForm},
  Scores in 'Scores.pas' {ScoreForm},
  InputName in 'InputName.pas' {InputNameForm},
  Customer in 'Customer.pas' {CustomerForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Mine Clone';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TScoreForm, ScoreForm);
  Application.CreateForm(TInputNameForm, InputNameForm);
  Application.CreateForm(TCustomerForm, CustomerForm);
  Application.Run;
end.
