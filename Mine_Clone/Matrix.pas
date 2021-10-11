unit Matrix;

{
Unité de manipulation et de calculs sur des tableaux bidimensionnels.
Utilité essentielle : fonctionnement d'un programme de type "démineur".
Certaines routines ont une utilité plus générale.
by japee
novembre 2007
}

interface

type
  TMatrixBool = array of array of Boolean;  // tableau bidimensionnel de booléens
  TMatrixByte = array of array of Byte;     // tableau bidimensionnel de bytes

  { Dimensionnement du tableau de booléens dans les deux dimensions }
  procedure SetLengthMatrixBool(var MatrixBool: TMatrixBool; Horz, Vert: Integer);

  { Dimensionnement du tableau de bytes dans les deux dimensions }
  procedure SetLengthMatrixNumb(var MatrixByte: TMatrixByte; Horz, Vert: Integer);

  { Initialisation du tableau de booléens (valeur par défaut = False) }
  procedure InitializeMatrixBool(var MatrixBool: TMatrixBool;
    const Value: Boolean = False);

  { Initialisation du tableau de bytes (valeur par défaut = 0) }
  procedure InitializeMatrixByte(var MatrixByte: TMatrixByte;
    const Value: Byte = 0);

  { Retourne Num cellules d'un tableau de booléens de manière aléatoire }  
  procedure GetRandomCells(var MatrixBool: TMatrixBool; Num: Word);

  { Comptage des mines avoisinant chaque cellule du tableau }
  procedure SearchForNeighboring(var MatrixByte: TMatrixByte; MatrixBool: TMatrixBool);

  { Dégagement de l'espace non miné - cette procédure est récursive }
  procedure SearchForShowing(var MShow: TMatrixBool; MatrixByte: TMatrixByte;
    x, y: Integer);

  { Retourne True si toutes les cellules ont valeur = True dans un tableau de booléens }
  function MatrixBoolIsTrue(var MatrixBool: TMatrixBool): Boolean;

  { Compte le nombre de cellules dont valeur = False dans un tableau de bytes }
  function CountMatrixBoolFalse(var MatrixBool: TMatrixBool): Word;

  { Compte le nombre d'occurences de Value dans un tableau de bytes }
  function CountMatrixBool(var MatrixBool: TMatrixBool; Value: Boolean): Word;

  { Compte le nombre d'occurences de Value dans un tableau de bytes }
  function CountMatrixByte(var MatrixByte: TMatrixByte; Value: Byte): Word;

  { Compare des valeurs dans un tableau de byte et dans un tableau de booléens }
  function CompareMatrixByteBool(var MatrixByte: TMatrixByte; ValueA: Byte;
    InitA: Byte; MatrixBool: TMatrixBool; const ValueB: Boolean = False): Word;
  
implementation

procedure SetLengthMatrixBool(var MatrixBool: TMatrixBool; Horz, Vert: Integer);
var
  i: Integer;
begin
  SetLength(MatrixBool, Horz);
  for i := 0 to High(MatrixBool) do
    SetLength(MatrixBool[i], Vert);
end;

procedure SetLengthMatrixNumb(var MatrixByte: TMatrixByte; Horz, Vert: Integer);
var
  i: Integer;
begin
  SetLength(MatrixByte, Horz);
  for i := 0 to High(MatrixByte) do
    SetLength(MatrixByte[i], Vert);
end;

procedure InitializeMatrixBool(var MatrixBool: TMatrixBool;
  const Value: Boolean = False);
var
  x, y: Integer;
begin
  for x := 0 to High(MatrixBool) do
    for y := 0 to High(MatrixBool[0]) do
      MatrixBool[x, y] := Value;
end;

procedure InitializeMatrixByte(var MatrixByte: TMatrixByte;
  const Value: Byte = 0);
var
  x, y: Integer;
begin
  for x := 0 to High(MatrixByte) do
    for y := 0 to High(MatrixByte[0]) do
      MatrixByte[x, y] := 0;
end;

procedure GetRandomCells(var MatrixBool: TMatrixBool; Num: Word);
var
  ArrRandom: array of Word;
  i: Integer;
  A, B, Tmp: Word;
  Count: Integer;
  x, y: Integer;
begin
  SetLength(ArrRandom, Length(MatrixBool) * Length(MatrixBool[0]));
  for i := 0 to High(ArrRandom) do
    ArrRandom[i] := i;
  Randomize;
  for i := 0 to High(ArrRandom) do
  begin
    A := Random(Length(ArrRandom));
    B := A;
    while B = A do
      B := Random(Length(ArrRandom));
    Tmp := ArrRandom[A];
    ArrRandom[A] := ArrRandom[B];
    ArrRandom[B] := Tmp;
  end;
  Count := 0;
  for x := 0 to High(MatrixBool) do
    for y := 0 to High(MatrixBool[0]) do
    begin
      for i := 0 to Num - 1 do
        if Count = ArrRandom[i] then
        begin
          MatrixBool[x, y] := True;
          Break;
        end;
      Inc(Count);
    end;
end;

{ Comptage des mines avoisinant chaque cellule du tableau }
procedure SearchForNeighboring(var MatrixByte: TMatrixByte; MatrixBool: TMatrixBool);
var
  x, y: Integer;
  Count: Byte;
begin
  for x := 1 to High(MatrixByte) - 1 do
    for y := 1 to High(MatrixByte[0]) - 1 do
    begin
      Count := 0;
      if MatrixBool[x + 1, y - 1] then Inc(Count);
      if MatrixBool[x + 1, y    ] then Inc(Count);
      if MatrixBool[x + 1, y + 1] then Inc(Count);
      if MatrixBool[x    , y + 1] then Inc(Count);
      if MatrixBool[x - 1, y + 1] then Inc(Count);
      if MatrixBool[x - 1, y    ] then Inc(Count);
      if MatrixBool[x - 1, y - 1] then Inc(Count);
      if MatrixBool[x    , y - 1] then Inc(Count);
      MatrixByte[x, y] := Count;
    end;
  
  { colonne de droite sans les cellules de coin }
  x := High(MatrixByte);
  for y := 1 to High(MatrixByte[0]) - 1 do
  begin
    Count := 0;
    if MatrixBool[x    , y + 1] then Inc(Count);
    if MatrixBool[x - 1, y + 1] then Inc(Count);
    if MatrixBool[x - 1, y    ] then Inc(Count);
    if MatrixBool[x - 1, y - 1] then Inc(Count);
    if MatrixBool[x    , y - 1] then Inc(Count);
    MatrixByte[x, y] := Count;
  end;

  { rangée du bas sans les cellules de coin }
  y := High(MatrixByte[0]);
  for x := 1 to High(MatrixByte) - 1 do
  begin
    Count := 0;
    if MatrixBool[x - 1, y    ] then Inc(Count);
    if MatrixBool[x - 1, y - 1] then Inc(Count);
    if MatrixBool[x    , y - 1] then Inc(Count);
    if MatrixBool[x + 1, y - 1] then Inc(Count);
    if MatrixBool[x + 1, y    ] then Inc(Count);
    MatrixByte[x, y] := Count;
  end;

  { colonne de gauche sans les cellules de coin }
  x := 0;
  for y := 1 to High(MatrixByte[0]) - 1 do
  begin
    Count := 0;
    if MatrixBool[x    , y - 1] then Inc(Count);
    if MatrixBool[x + 1, y - 1] then Inc(Count);
    if MatrixBool[x + 1, y    ] then Inc(Count);
    if MatrixBool[x + 1, y + 1] then Inc(Count);
    if MatrixBool[x    , y + 1] then Inc(Count);
    MatrixByte[x, y] := Count;
  end;

  { rangée du haut sans les cellules de coin }
  y := 0;
  for x := 1 to High(MatrixByte) - 1 do
  begin
    Count := 0;
    if MatrixBool[x + 1, y    ] then Inc(Count);
    if MatrixBool[x + 1, y + 1] then Inc(Count);
    if MatrixBool[x    , y + 1] then Inc(Count);
    if MatrixBool[x - 1, y + 1] then Inc(Count);
    if MatrixBool[x - 1, y    ] then Inc(Count);
    MatrixByte[x, y] := Count;
  end;

  { cellule TopRight }
  x := High(MatrixByte);
  y := 0;
  Count := 0;
  if MatrixBool[x    , y + 1] then Inc(Count);
  if MatrixBool[x - 1, y + 1] then Inc(Count);
  if MatrixBool[x - 1, y    ] then Inc(Count);
  MatrixByte[x, y] := Count;

  { cellule BottomRight }
  x := High(MatrixByte);
  y := High(MatrixByte[0]);
  Count := 0;
  if MatrixBool[x - 1, y    ] then Inc(Count);
  if MatrixBool[x - 1, y - 1] then Inc(Count);
  if MatrixBool[x    , y - 1] then Inc(Count);
  MatrixByte[x, y] := Count;

  { cellule BottomLeft }
  x := 0;
  y := High(MatrixByte[0]);
  Count := 0;
  if MatrixBool[x    , y - 1] then Inc(Count);
  if MatrixBool[x + 1, y - 1] then Inc(Count);
  if MatrixBool[x + 1, y    ] then Inc(Count);
  MatrixByte[x, y] := Count;
  
  { cellule TopLeft }
  Count := 0;
  if MatrixBool[1, 0] then Inc(Count);
  if MatrixBool[1, 1] then Inc(Count);
  if MatrixBool[0, 1] then Inc(Count);
  MatrixByte[0, 0] := Count;
end;

{ Dégagement de l'espace non miné - cette procédure est récursive }
procedure SearchForShowing(var MShow: TMatrixBool; MatrixByte: TMatrixByte;
  x, y: Integer);
begin
  MShow[x, y] := True;

  if MatrixByte[x, y] <> 0 then
    Exit;

  if (x > 0) and (not MShow[x - 1, y]) then
    SearchForShowing(MShow, MatrixByte, x - 1, y);
  if (x > 0) and (y > 0) and (not MShow[x - 1, y - 1]) then
    SearchForShowing(MShow, MatrixByte, x - 1, y - 1);
  if (y > 0) and (not MShow[x, y - 1]) then
    SearchForShowing(MShow, MatrixByte, x, y - 1);
  if (y > 0) and (x + 1 < High(MatrixByte)) and (not MShow[x + 1, y - 1]) then
    SearchForShowing(MShow, MatrixByte, x + 1, y - 1);
  if (x < High(MatrixByte)) and (not MShow[x + 1, y]) then
    SearchForShowing(MShow, MatrixByte, x + 1, y);
  if (x < High(MatrixByte)) and (y + 1 < High(MatrixByte[0])) and (not MShow[x + 1, y + 1]) then
    SearchForShowing(MShow, MatrixByte, x + 1, y + 1);
  if (y < High(MatrixByte[0])) and (not MShow[x, y + 1]) then
    SearchForShowing(MShow, MatrixByte, x, y + 1);
  if (y < High(MatrixByte[0])) and (x - 1 > 0) and (not MShow[x - 1, y + 1]) then
    SearchForShowing(MShow, MatrixByte, x - 1, y + 1);
end;

{ Retourne True si toutes les cellules ont valeur = True dans un tableau de booléens }
function MatrixBoolIsTrue(var MatrixBool: TMatrixBool): Boolean;
var
  x, y: Integer;
begin
  Result := True;
  for x := 0 to High(MatrixBool) do
    for y := 0 to High(MatrixBool[0]) do
      if MatrixBool[x, y] then
      begin
        Result := False;
        Exit;
      end;
end;

{ Compte le nombre de cellules dont valeur = False dans un tableau de bytes }
function CountMatrixBoolFalse(var MatrixBool: TMatrixBool): Word;
var
  x, y: Integer;
begin
  Result := 0;
  for x := 0 to High(MatrixBool) do
    for y := 0 to High(MatrixBool[0]) do
      if not MatrixBool[x, y] then
        Inc(Result);
end;

{ Compte le nombre d'occurences de Value dans un tableau de bytes }
function CountMatrixBool(var MatrixBool: TMatrixBool; Value: Boolean): Word;
var
  x, y: Integer;
begin
  Result := 0;
  for x := 0 to High(MatrixBool) do
    for y := 0 to High(MatrixBool[0]) do
      if MatrixBool[x, y] = Value then
        Inc(Result);
end;

{ Compte le nombre d'occurences de Value dans un tableau de bytes }
function CountMatrixByte(var MatrixByte: TMatrixByte; Value: Byte): Word;
var
  x, y: Integer;
begin
  Result := 0;
  for x := 0 to High(MatrixByte) do
    for y := 0 to High(MatrixByte[0]) do
      if MatrixByte[x, y] = Value then
        Inc(Result);
end;

{ Compare des valeurs dans un tableau de byte et dans un tableau de booléens.

  Calcule le nombre de fois où est trouvée une concordance entre ces 2 valeurs
  aux mêmes coordonnées et dans leurs tableaux respectifs, réinitialise la
  valeur de type byte ValueA := InitA, et retourne le nombre d'occurences.

}
function CompareMatrixByteBool(var MatrixByte: TMatrixByte; ValueA: Byte;
  InitA: Byte; MatrixBool: TMatrixBool; const ValueB: Boolean = False): Word;
var
  x, y: Integer;
begin
  Result := 0;
  for x := 0 to High(MatrixByte) do
    for y := 0 to High(MatrixByte[0]) do
      if (MatrixByte[x, y] = ValueA) and (MatrixBool[x, y] = ValueB) then
      begin
        MatrixByte[x, y] := InitA;  // réinitialisation
        Inc(Result);
      end;
end;

end.
