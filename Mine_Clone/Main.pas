unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, Spin, Buttons, ImgList, Menus;

type
  TMainForm = class(TForm)
    Timer: TTimer;
    ImgListSmiley: TImageList;
    pnlSheat: TPanel;
    lblFound: TLabel;
    lblHide: TLabel;
    cbxIndications: TCheckBox;
    cbxMines: TCheckBox;
    cbxUnderMine: TCheckBox;
    cbxCheat: TCheckBox;
    Label1: TLabel;
    seNumMines: TSpinEdit;
    imgBomb: TImage;
    imgBombRed: TImage;
    imgCover: TImage;
    imgFlag: TImage;
    imgQuest: TImage;
    pnlGame: TPanel;
    MainMenu1: TMainMenu;
    miGame: TMenuItem;
    miQuestionMark: TMenuItem;
    miNew: TMenuItem;
    N2: TMenuItem;
    miBeginner: TMenuItem;
    miIntermediate: TMenuItem;
    miExpert: TMenuItem;
    miCustom: TMenuItem;
    N3: TMenuItem;
    miMarks: TMenuItem;
    miSound: TMenuItem;
    N4: TMenuItem;
    miScore: TMenuItem;
    N5: TMenuItem;
    miClose: TMenuItem;
    pnlInfo: TPanel;
    lblMines: TLabel;
    btnNewPlay: TSpeedButton;
    lblTime: TLabel;
    pnlGrid: TPanel;
    DrawGrid1: TDrawGrid;
    miAbout: TMenuItem;
    miCheat: TMenuItem;
    N6: TMenuItem;
    Label5: TLabel;
    Label6: TLabel;
    procedure btnNewGameClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerTimer(Sender: TObject);
    procedure cbxIndicationsClick(Sender: TObject);
    procedure cbxMinesClick(Sender: TObject);
    procedure cbxUnderMineClick(Sender: TObject);
    procedure cbxCheatClick(Sender: TObject);
    procedure miCheatClick(Sender: TObject);
    procedure miBeginnerClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miSoundClick(Sender: TObject);
    procedure miNewClick(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure miScoreClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { D�clarations priv�es }
    procedure DefineGame;
    procedure ReadData;
    procedure WriteData;
    procedure UpdateBestScores(Time: Word);
  public
    { D�clarations publiques }
  end;

var
  MainForm: TMainForm;

  PathAppli: string;    // chemin de l'application
  
  BestBeginnerTime, BestIntermediateTime, BestExpertTime: Word;   // temps
  BestBeginnerName, BestIntermediateName, BestExpertName: string; // id

  GameLevel: Byte;      // niveau de jeu

implementation

uses
  ShellApi, MMSystem, IniFiles,
  Matrix, DGUtils, About, Scores, InputName, Customer;

{$R *.DFM} {$R WindowsXP.res}

const
  { marquage des cellules }
  TAG_NULL  = 0;  // case non marqu�e
  TAG_FLAG  = 1;  // case marqu�e d'un drapeau
  TAG_QMARK = 2;  // case marqu�e d'un '?'

  { GameLevel (niveau de jeu) }
  BEGINNER     = 1;
  INTERMEDIATE = 2;
  EXPERT       = 3;
  CUSTOM       = 4;
  
var
  MatrixMine      : TMatrixBool;  // tableau emplacement mines
  MatrixNumb      : TMatrixByte;  // tableau indications de proximit�
  MatrixShow      : TMatrixBool;  // tableau des cellules d�couvertes
  MatrixFlag      : TMatrixByte;  // tableau d'�tat des cellules

  MinesTotal      : Integer;      // nombre total de mines
  MinesRemaining  : Integer;      // mines restant � trouver (estimation joueur)
  MinesFound      : Integer;      // mines r�ellement trouv�es

  ElapsedTime     : Integer;      // temps �coul�
  TimerCanGo      : Boolean;      // le timer sera activ� au premier clic

  ExplodingZone   : TPoint;       // zone min�e o� le joueur a cliqu�

  HORZ_CELLS      : Integer;      // nombre de colonnes
  VERT_CELLS      : Integer;      // nombre de rang�es
  CellsCount      : Integer;      // nombre de cellules

  Tic, Tac,
  Boom, Win       : string;       // emplacement des sons

{ Commencer un nouveau jeu }
procedure TMainForm.btnNewGameClick(Sender: TObject);
begin
  { initialisation des variables }
  MinesTotal     := seNumMines.Value;
  MinesRemaining := MinesTotal;
  MinesFound     := 0;
  ElapsedTime    := 0;
  ExplodingZone  := Point(Length(MatrixMine), Length(MatrixMine[0]));

  { initialisation des tableaux, mise en place des mines et infos de proximit� }
  InitializeMatrixBool(MatrixMine);               // valeur = False
  GetRandomCells(MatrixMine, MinesTotal);         // placement al�atoire des mines
  InitializeMatrixBool(MatrixShow);               // valeur = False
  InitializeMatrixByte(MatrixFlag);               // valeur = 0
  SearchForNeighboring(MatrixNumb, MatrixMine);   // indicateurs proximit� mine

  { actualisation de la grille }
  DrawGrid1.Invalidate;

  { affichage des informations }
  CellsCount := HORZ_CELLS * VERT_CELLS;
  lblMines.Caption := Format('%.3d', [MinesTotal]);
  lblTime.Caption  := Format('%.3d', [ElapsedTime]);
  lblFound.Caption := Format('%.3d/%.3d', [MinesFound, MinesTotal]);
  lblHide.Caption  := Format('%.3d/%.3d', [CountMatrixBool(MatrixShow, False), CellsCount]);

  { dessin du bouton = smiley souriant }
  btnNewPlay.Glyph := nil;
  ImgListSmiley.GetBitmap(0, btnNewPlay.Glyph);

  DrawGrid1.Enabled := True;
  
  { le timer pourra d�marrer au premier clic gauche }
  Timer.Enabled := False;
  TimerCanGo := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  { chemin de l'application }
  PathAppli := ExtractFilePath(Application.ExeName);
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  { suppression d'un �ventuel effet de scintillement }
  DrawGrid1.DoubleBuffered := True;
  { lecture des donn�es depuis le fichier ini }
  ReadData;
  { dissimulation des indications de "triche" }
  pnlSheat.Width := 0;
  { d�finition du niveau de jeu et dimensionnement }
  DefineGame;
  { pas de s�lection de la cellules car c'est inesth�tique }
  NoSelectionInDrawGrid(DrawGrid1);
  { lancement du jeu }
  btnNewGameClick(nil);
  { chemin des fichiers son }
  Tic  := PathAppli + 'Sounds\Tic.wav';
  Tac  := PathAppli + 'Sounds\Tac.wav';
  Boom := PathAppli + 'Sounds\Boom.wav';
  Win  := PathAppli + 'Sounds\Win.wav';
  { clic menu tricher }
  miCheatClick(nil);
end;

{ C'est pendant cet �v�nement que se dessinent les cellules de la StringGrid }
procedure TMainForm.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Indication: Integer;
begin
  { chiffre indiquant le nombre de mines autour de la cellule }
  Indication := MatrixNumb[ACol, ARow];
  if (not MatrixMine[ACol, ARow] or cbxUnderMine.Checked) and
     (Indication <> 0) and cbxIndications.Checked then
    DrawGrid1.Canvas.TextOut(Rect.Left + 4, Rect.Top + 1, IntToStr(Indication));
  { affichage de l'image correspondant � l'�tat en cours de la cellule }
  if not MatrixShow[ACol, ARow] and not cbxCheat.Checked then
    with DrawGrid1.Canvas do
    case MatrixFlag[ACol, ARow] of
      0: Draw(Rect.Left, Rect.Top, imgCover.Picture.Graphic);  // cache
      1: Draw(Rect.Left, Rect.Top, imgFlag.Picture.Graphic);   // drapeau
      2: Draw(Rect.Left, Rect.Top, imgQuest.Picture.Graphic);  // '?'
    end
  else
  if MatrixMine[ACol, ARow] and cbxMines.Checked then
    DrawGrid1.Canvas.Draw(Rect.Left, Rect.Top, imgBomb.Picture.Graphic);  // mine
  { si le joueur a cliqu� sur une mine }
  if (ACol = ExplodingZone.x) and (ARow = ExplodingZone.y) then
    DrawGrid1.Canvas.Draw(Rect.Left, Rect.Top, imgBombRed.Picture.Graphic); // mine rouge
end;

var
  Losing: Boolean;  // partie perdue

procedure TMainForm.DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { dessin du bouton = smiley souriant }
  btnNewPlay.Glyph := nil;
  ImgListSmiley.GetBitmap(0, btnNewPlay.Glyph);
  { emp�che la s�lection de la cellules car c'est inesth�tique }
  NoSelectionInDrawGrid(DrawGrid1);
  { c'est finalement le meilleur endroit pour placer les blocs de code qui suivent }
  { si cases masqu�es = nombre de mines r�el et cases marqu�es d'un drapeau }
  if (CountMatrixBool(MatrixShow, False) = MinesTotal) and
     (CountMatrixByte(MatrixFlag, 1) = MinesTotal) then
  { la partie est gagn�e }
  begin
    { dessin du bouton = smiley cool }
    btnNewPlay.Glyph := nil;
    ImgListSmiley.GetBitmap(3, btnNewPlay.Glyph);
    { on fige le jeu }
    Timer.Enabled := False;
    DrawGrid1.Enabled := False;
    { on joue le son si l'option est coch�e }
    if miSound.Checked then
      sndPlaySound(PChar(Win), SND_ASYNC);
    DrawGrid1.Invalidate;           // <-
    UpdateBestScores(StrToInt(lblTime.Caption));   // <-
  end;
  { la partie est perdue }
  if Losing then
  begin
    { dessin du bouton = smiley kaput }
    btnNewPlay.Glyph := nil;
    ImgListSmiley.GetBitmap(2, btnNewPlay.Glyph);
    { on fige le jeu }
    Timer.Enabled := False;
    DrawGrid1.Enabled := False;
    { on joue le son si l'option est coch�e }
    if miSound.Checked then
      sndPlaySound(PChar(Boom), SND_ASYNC);
  end;
end;

procedure TMainForm.DrawGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  WrongFlags: Integer;  // drapeaux erron�s, � effacer si cases correspondantes d�couvertes
begin Losing := False;
  { la case devient une case d�couverte }
  MatrixShow[ACol, ARow] := True;
  { si on est tomb� sur une mine... }
  if MatrixMine[ACol, ARow] then
  begin
    { on d�termine la zone de l'explosion }
    ExplodingZone := Point(ACol, ARow);
    { on d�clare la partie perdue }
    Losing := True;
  end
  { sinon �a baigne... }
  else
  begin
    { d�gagement �ventuel des cases vides autour de la case cliqu�e }
    SearchForShowing(MatrixShow, MatrixNumb, ACol, ARow);
    { ici il faut mettre � jour le compte des cases marqu�es par erreur d'un
    drapeau et qui ont �t� d�gag�es ! }
    WrongFlags := CompareMatrixByteBool(MatrixFlag, 1, 0, MatrixShow, True);
    { mise � jour du compte de mines restantes estim�es par le joueur }
    Inc(MinesRemaining, WrongFlags);
    lblMines.Caption := Format('%.3d', [MinesRemaining]);
    { rafra�chissement de la grille }
    DrawGrid1.Invalidate;
  end;
  lblHide.Caption  := Format('%.3d/%.3d', [CountMatrixBool(MatrixShow, False), CellsCount]);
end;

procedure TMainForm.DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;
  Wdth: Integer;
begin
  if ssRight in Shift then        // si clic droit...
  begin
    { petit calcul pour situer la cellule cliqu�e }
    ACol := X div (DrawGrid1.DefaultColWidth + 1);
    ARow := Y div (DrawGrid1.DefaultRowHeight + 1);
    if MatrixShow[ACol, ARow] then Exit;  // si case d�couverte, sortie ->
    { changement de l'�tat de la cellule (3 �tats) }
    case MatrixFlag[ACol, ARow] of
      TAG_NULL :    // �tat trouv� : case non marqu�e
      begin
        MatrixFlag[ACol, ARow] := TAG_FLAG;   // r�sultat : case marqu�e (drapeau)
        Dec(MinesRemaining);                  // estimation mines � trouver : - 1
        if MatrixMine[ACol, ARow] then        // si mine dans la case...
          Inc(MinesFound);                    // mines trouv�es : + 1
        { pr�vision d'un affichage n�gatif si le joueur a plac� trop de drapeaux }
        if MinesRemaining < 0 then Wdth := 2 else Wdth := 3;
        lblMines.Caption := Format('%.*d', [Wdth, MinesRemaining]);
        lblFound.Caption := Format('%.3d/%.3d', [MinesFound, MinesTotal]);
      end;
      TAG_FLAG :    // �tat trouv� : case marqu�e (drapeau)
      begin
        if miMarks.Checked then               // en fonction de l'option menu...
          MatrixFlag[ACol, ARow] := TAG_QMARK // r�sultat : case marqu�e (?)
        else
          MatrixFlag[ACol, ARow] := TAG_NULL; // r�sultat : case non marqu�e
        Inc(MinesRemaining);                  // estimation mines � trouver : + 1
        if MatrixMine[ACol, ARow] then        // si mine dans la case...
          Dec(MinesFound);                    // mines trouv�es : - 1
        if MinesRemaining < 0 then Wdth := 2 else Wdth := 3;
        lblMines.Caption := Format('%.*d', [Wdth, MinesRemaining]);
        lblFound.Caption := Format('%.3d/%.3d', [MinesFound, MinesTotal]);
      end;
      TAG_QMARK :   // �tat trouv� : case marqu�e (?)
      begin
        MatrixFlag[ACol, ARow] := TAG_NULL;   // r�sultat : case non marqu�e
      end;
    end;
    DrawGrid1.Invalidate;
  end
  else if ssLeft in Shift then    // si clic gauche...
  begin
    btnNewPlay.Glyph := nil;
    ImgListSmiley.GetBitmap(1, btnNewPlay.Glyph);   // smiley Oooh...
    if TimerCanGo then
    begin
      Timer.Enabled := True;
      TimerCanGo := False;
    end;
  end;
end;

{ Gestion du temps �coul�, affichage et son }
var
  IsTic: Boolean = True;
{ je remplace la constante typ�e par une variable d�localis�e (afin de pouvoir
lui affecter une valeur), pour assurer la compatibilit� avec une option de
compilation qui semble activ�e par d�faut sous D7 en particulier }
procedure TMainForm.TimerTimer(Sender: TObject);
//const
//   IsTic: Boolean = True;
begin
  Inc(ElapsedTime);
  lblTime.Caption := Format('%.3d', [ElapsedTime]);
  if miSound.Checked then
  begin
    if IsTic then
      sndPlaySound(PChar(Tic), SND_ASYNC)
    else
      sndPlaySound(PChar(Tac), SND_ASYNC);
  end;
  IsTic := not IsTic;
end;

{ Rafra�chissement de la TDrawGrid }
procedure TMainForm.cbxIndicationsClick(Sender: TObject);
begin
  DrawGrid1.Invalidate;
end;

procedure TMainForm.cbxMinesClick(Sender: TObject);
begin
  DrawGrid1.Invalidate;
end;

procedure TMainForm.cbxUnderMineClick(Sender: TObject);
begin
  DrawGrid1.Invalidate;
end;

procedure TMainForm.cbxCheatClick(Sender: TObject);
begin
  DrawGrid1.Invalidate;
end;

{ ************ PARTIE CONCERNANT LA GESTION DES CHOIX UTILISATEUR ************ }

{ Montrer/cacher le panel des indications de "cheat" }
procedure TMainForm.miCheatClick(Sender: TObject);
const
  PANEL_CHEAT_WIDTH = 169;
begin
  miCheat.Checked := not miCheat.Checked;
  if miCheat.Checked then
  begin
    ClientWidth := pnlGame.Width + PANEL_CHEAT_WIDTH;
    pnlSheat.Width := PANEL_CHEAT_WIDTH;
  end
  else
  begin
    pnlSheat.Width := 0;
    ClientWidth := pnlGame.Width;
  end;
end;

{ D�finition des param�tres et dimensions du jeu en fonction du niveau choisi }
procedure TMainForm.DefineGame;
begin
  case GameLevel of
    BEGINNER :
    begin
      HORZ_CELLS := 9;
      VERT_CELLS := 9;
      seNumMines.Value := 10;
    end;
    INTERMEDIATE :
    begin
      HORZ_CELLS := 16;
      VERT_CELLS := 16;
      seNumMines.Value := 40;
    end;
    EXPERT :
    begin
      HORZ_CELLS := 30;
      VERT_CELLS := 16;
      seNumMines.Value := 99;
    end;
    CUSTOM :
    begin
      HORZ_CELLS := CustomWidth;
      VERT_CELLS := CustomHeight;
      seNumMines.Value := CustomMines;
    end;
  end;
  { ATTENTION ! ne pas oublier de dimensionner les tableaux ! }
  SetLengthMatrixBool(MatrixMine, HORZ_CELLS, VERT_CELLS);
  SetLengthMatrixNumb(MatrixNumb, HORZ_CELLS, VERT_CELLS);
  SetLengthMatrixBool(MatrixShow, HORZ_CELLS, VERT_CELLS);
  SetLengthMatrixNumb(MatrixFlag, HORZ_CELLS, VERT_CELLS);
  with DrawGrid1 do
  begin
    Width    := HORZ_CELLS * (DefaultColWidth + 1) + 2;
    Height   := VERT_CELLS * (DefaultRowHeight + 1) + 2;
    ColCount := HORZ_CELLS;
    RowCount := VERT_CELLS;
  end;
  { positionnement des �l�ments autour de la DrawGrid }
  pnlGame.Width := pnlGrid.Width + 12;
  pnlGame.Height := pnlGrid.Height + 56;
  pnlSheat.Height := pnlGame.Height;
  pnlInfo.Width := pnlGrid.Width;
  btnNewPlay.Left := (pnlInfo.Width - btnNewPlay.Width) div 2;
  ClientWidth := pnlGame.Width + pnlSheat.Width;
  ClientHeight := pnlGame.Height;
end;

procedure TMainForm.miBeginnerClick(Sender: TObject);
var
  i: Integer;
begin
  { j'aurais pu utiliser la propri�t� RadioItem, mais je voulais garder le
  cochage en 'V' et pas en '.' pour des raisons esth�tiques }
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TMenuItem then
      if (Components[i] as TMenuItem).Tag > 0 then
        (Components[i] as TMenuItem).Checked := False;
  (Sender as TMenuItem).Checked := True;
  GameLevel := (Sender as TMenuItem).Tag;
  { param�trage �ventuel du jeu custom }
  if miCustom.Checked then
    CustomerForm.ShowModal;
  { d�finition du niveau de jeu et dimensionnement }
  DefineGame;
  { lancement du jeu }
  btnNewGameClick(nil);
end;

procedure TMainForm.miAboutClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.miSoundClick(Sender: TObject);
begin
  with Sender as TMenuItem do
    Checked := not Checked;
end;

procedure TMainForm.miNewClick(Sender: TObject);
begin
  btnNewGameClick(nil);
end;

procedure TMainForm.miCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.miScoreClick(Sender: TObject);
begin
  ScoreForm.ShowModal;
end;

{ Lecture des donn�es depuis le fichier ini }
procedure TMainForm.ReadData;
var
  i: Integer;
begin
  with TIniFile.Create(PathAppli + 'Data') do
  try
    { position de la fiche }
    Left := ReadInteger('USER', 'left', 300);
    Top := ReadInteger('USER', 'top', 100);
    { niveau de jeu et cochage du menus correspondant }
    GameLevel := ReadInteger('USER', 'level', 1);
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TMenuItem then
        if (Components[i] as TMenuItem).Tag > 0 then
        begin
          if (Components[i] as TMenuItem).Tag = GameLevel then
            (Components[i] as TMenuItem).Checked := True
          else
            (Components[i] as TMenuItem).Checked := False;
        end;
    { lecture des param�tres de jeu selon pr�f�rences joueur (custom) }
    CustomWidth  := ReadInteger('USER', 'customwidth', 9);
    CustomHeight := ReadInteger('USER', 'customheight', 9);
    CustomMines  := ReadInteger('USER', 'custommine', 10);
    { cochage des divers menus � option }
    miMarks.Checked       := ReadBool('USER', 'marks', False);
    miSound.Checked       := ReadBool('USER', 'sound', True);
    miCheat.Checked       := ReadBool('USER', 'cheat', False);
    { actualisation selon param�tre pr�c�dent }
    miCheat.Click;
    { lecture des meilleurs scores }
    BestBeginnerTime      := ReadInteger('SCORE', 'time1', 999);
    BestIntermediateTime  := ReadInteger('SCORE', 'time2', 999);
    BestExpertTime        := ReadInteger('SCORE', 'time3', 999);
    BestBeginnerName      := ReadString('SCORE', 'name1', 'Anonyme');
    BestIntermediateName  := ReadString('SCORE', 'name2', 'Anonyme');
    BestExpertName        := ReadString('SCORE', 'name3', 'Anonyme');
  finally
    Free;
  end;
end;

{ �criture des donn�es vers le fichier ini }
procedure TMainForm.WriteData;
begin
  with TIniFile.Create(PathAppli + 'Data') do
  try
    WriteInteger('USER', 'left', Left);
    WriteInteger('USER', 'top', Top);
    WriteInteger('USER', 'level', GameLevel);
    WriteBool('USER', 'marks', miMarks.Checked);
    WriteBool('USER', 'sound', miSound.Checked);
    WriteBool('USER', 'cheat', miCheat.Checked);
    WriteInteger('USER', 'customwidth', CustomWidth);
    WriteInteger('USER', 'customheight', CustomHeight);
    WriteInteger('USER', 'custommine', CustomMines);
  finally
    Free;
  end;
end;

{ Comparaison du temps r�alis� avec le meilleur score �tabli }
procedure TMainForm.UpdateBestScores(Time: Word);
var
  BestScoreChange: Boolean;
begin
  BestScoreChange := False;
  { comparaison des scores en fonction du niveau }
  case GameLevel of
    BEGINNER :
      if Time < BestBeginnerTime then
      begin
        BestBeginnerTime := Time;
        BestScoreChange := True;
      end;
    INTERMEDIATE :
      if Time < BestIntermediateTime then
      begin
        BestIntermediateTime := Time;
        BestScoreChange := True;
      end;
    EXPERT :
      if Time < BestExpertTime then
      begin
        BestExpertTime := Time;
        BestScoreChange := True;
      end;
    CUSTOM: Exit;
  end;
  { un meilleur temps a �t� �tabli }
  if BestScoreChange then
  begin
    { appel de la fen�tre d'entr�e du nom }
    InputNameForm.ShowModal;
    { affichage et enregistrement des nouveaux meilleurs temps }
    ScoreForm.ShowModal;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteData;
end;

end.
