unit DGUtils;

{
Routines utilitaires de gestion de TDrawGrid
by japee
novembre 2007
}

interface

uses Windows, Graphics, Controls, Grids;

  { permet de charger une image dans une TDrawGrid depuis une TImageList }
  procedure DrawImageListInDrawGrid(const ImageList: TImageList; Index: Integer;
    const DrawGrid: TDrawGrid; Rect: TRect);
  { efface visuellement toute sélection dans la TDrawGrid }
  procedure NoSelectionInDrawGrid(const DrawGrid: TDrawGrid);

implementation

{ je n'utilise plus cette méthode beaucoup trop lente, je la laisse pour info }
procedure DrawImageListInDrawGrid(const ImageList: TImageList; Index: Integer;
  const DrawGrid: TDrawGrid; Rect: TRect);
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    ImageList.GetBitmap(Index, Bmp);
    DrawGrid.Canvas.Draw(Rect.Left, Rect.Top, Bmp);
  finally
    Bmp.Free;
  end;
end;

procedure NoSelectionInDrawGrid(const DrawGrid: TDrawGrid);
var { d'après une astuce de Nono40 }
  Select: TGridRect;
begin
  with Select do
  begin
    Top    := 0;
    Bottom := 0;
    Left   := DrawGrid.ColCount + 1;
    Right  := Left;
  end;
  DrawGrid.Selection := Select;
end;

end.
