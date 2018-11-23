    {--- rysowanie planszy ---}

  

  {--- rysujemy mozliwe ruchy jezeli takie sa---}

if Length(TablicaRuchow)>0 then
begin

     for a:=0 to Length(TablicaRuchow)-1 do
     begin
           pole:=ZnajdzIJbyPole(TablicaRuchow[a]);

           PaintBox1.Canvas.brush.Color:=$00AAFFFF;

            t.Left:=(80*(pole.y-1));
            t.Top:=(80*(pole.x-1));
            t.Right:=(80*(pole.y-1))+81;
            t.Bottom:=(80*(pole.x-1))+81;

             PaintBox1.Canvas.rectangle(t);
     end;

end;

{-- kolorujey szacha jezeli jest --}
     if KolorowanieSzach.ok=true then
     begin
       PaintBox1.Canvas.brush.Color:=$006A67FA;

        t.Left:=(80*(KolorowanieSzach.Pole.y-1));
        t.Top:=(80*(KolorowanieSzach.Pole.x-1));
        t.Right:=(80*(KolorowanieSzach.Pole.y-1))+81;
        t.Bottom:=(80*(KolorowanieSzach.Pole.x-1))+81;

         PaintBox1.Canvas.rectangle(t);

     end;

{---}

  PaintBox1.Canvas.Pen.Color := clBlack;

     PaintBox1.Canvas.MoveTo(0,0);
     PaintBox1.Canvas.LineTo(640,0);

     PaintBox1.Canvas.MoveTo(640,0);
     PaintBox1.Canvas.LineTo(640,640);

     PaintBox1.Canvas.MoveTo(0,0);
     PaintBox1.Canvas.LineTo(0,640);

     PaintBox1.Canvas.MoveTo(0,640);
     PaintBox1.Canvas.LineTo(640,640);


{----    rysowanie figur -----}

      with PaintBox1.Canvas do
   begin
   for i:=1 to 8 do
   begin
       for j:=1 to 8 do
       begin
       if Board[i,j]<>nil then begin
             Draw(Board[i,j].pozycja.X+5, Board[i,j].pozycja.Y+5, Board[i,j].obraz);
       end;
       end;
       end;
   end;         


unit Board;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  TBoardDesc = array[0..7,0..7] of string;
  TPieces = array[0..8] of string;
  
  TPiece = record
  Piece:integer;
  Color:string;
  Image:TPortableNetworkGraphic;
  MoveCount:integer;
  Field:string;
  Width:integer;
  Height:integer;
  end;

  TBoard = class(TPaintBox)
  private
    { Private declarations }
    FBottomColor:String;
    BoardDesc : TBoardDesc =
    (('A8','B8','C8','D8','E8','F8','G8','H8'),
    ('A7','B7','C7','D7','E7','F7','G7','H7'),
    ('A6','B6','C6','D6','E6','F6','G6','H6'),
    ('A5','B5','C5','D5','E5','F5','G5','H5'),
    ('A4','B4','C4','D4','E4','F4','G4','H4'),
    ('A3','B3','C3','D3','E3','F3','G3','H3'),
    ('A2','B2','C2','D2','E2','F2','G2','H2'),
    ('A1','B1','C1','D1','E1','F1','G1','H1'));
    Pieces : TPieces =
    ('Pawn', 'Roock', 'Knight', 'Bishop', 'Queen', 'King', 'Bishop', 'Knight', 'Rock');
    PiecesBlack : TPieces =
    ('Pawn', 'Roock', 'Knight', 'Bishop', 'King', 'Queen', 'Bishop', 'Knight', 'Rock');
    Board:array[0..7,0..7] of TPiece;
  protected
    { Protected declarations }
    procedure Paint(); override;
    function BoardRotation(arr : TBoardDesc): TBoardDesc;
    function FieldSize():integer;
    procedure DrawBoard();
    procedure DrawLines();
    procedure SetStartPosition();
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property BottomColor : String read FBottomColor write FBottomColor;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Additional',[TBoard]);
end;

function TBoard.BoardRotation(arr : TBoardDesc): TBoardDesc;
var
X,Y:integer;
Temp:string;
begin
for X := 0 to 3 do
  for Y := 0 to 7 do
  begin
    Temp := arr[X, Y];
    BoardRotation[X, Y] := arr[7 - X, 7 - Y];
    BoardRotation[7 - X, 7 - Y] := Temp;
  end;
end;

function TBoard.FieldSize():integer;
begin
FieldSize := Round(Width div 8);
end;

procedure TBoard.DrawBoard();
var
iswhite:boolean;
i,j,FieldSize:integer;
field:TRect;
begin

iswhite:=false;
Canvas.Pen.Color := clWhite;

for i:=0 to 7 do
begin

  if iswhite then
  begin
     iswhite:=false;
  end
  else
  begin
     iswhite:=true;
  end;

  for j:=0 to 7 do
  begin

     field.Left:=(FieldSize()*j);
     field.Top:=(FieldSize()*i);
     field.Right:=(FieldSize()*j)+(FieldSize()+1);
     field.Bottom:=(FieldSize()*i)+(FieldSize()+1);

     if iswhite then
     begin
       Canvas.brush.Color := cl3DLight;
     end
     else
     begin
       Canvas.brush.Color := clAppWorkspace;
     end;

     Canvas.rectangle(field);

      if white then
      begin
         white:=false;
      end
      else
      begin
         white:=true;
      end;
      
      end;
   end;
end;

procedure TBoard.DrawLines();
begin

Canvas.Pen.Color := clBlack;

Canvas.MoveTo(0,0);
Canvas.LineTo(Width-1,0);

Canvas.MoveTo(Width-1,0);
Canvas.LineTo(Width-1,Width-1);

Canvas.MoveTo(0,0);
Canvas.LineTo(0,Width-1);

Canvas.MoveTo(0,Width-1);
Canvas.LineTo(Width-1,Width-1);

end;


procedure TBoard.SetStartPosition();
var
i:integer;
begin
//set white Pawns
for i:=0 to 7 do
begin
  Board[7,i].Piece:=Pieces[0];
  Board[7,i].Color:='white';
  Board[7,i].Image:=TPortableNetworkGraphic.Create;
  Board[7,i].Image:=LoadFromFile('img/'+Pieces[0]+'White.png');
  Board[7,i].MoveCount:=0;
  Board[7,i].Field:=BoardDesc[7,i];
  Board[7,i].Width:=50;
  Board[7,i].Height:=50;
end;


//set black Pawns
for i:=0 to 7 do
begin
  Board[1,i].Piece:=Pieces[0];
  Board[1,i].Color:='black';
  Board[1,i].Image:=TPortableNetworkGraphic.Create;
  Board[1,i].Image:=LoadFromFile('img/'+Pieces[0]+'Black.png');
  Board[1,i].MoveCount:=0;
  Board[1,i].Field:=BoardDesc[1,i];
  Board[1,i].Width:=50;
  Board[1,i].Height:=50;
end;

//set white Pices
for i:=0 to 7 do
begin
  Board[8,i].Piece:=Pieces[i+1];
  Board[8,i].Color:='white';
  Board[8,i].Image:=TPortableNetworkGraphic.Create;
  Board[8,i].Image:=LoadFromFile('img/'+Pieces[i+1]+'White.png');
  Board[8,i].MoveCount:=0;
  Board[8,i].Field:=BoardDesc[8,i];
  Board[8,i].Width:=50;
  Board[8,i].Height:=50;
end;

//set black Pices
for i:=0 to 7 do
begin
  Board[0,i].Piece:=PiecesBlack[i+1];
  Board[0,i].Color:='black';
  Board[0,i].Image:=TPortableNetworkGraphic.Create;
  Board[0,i].Image:=LoadFromFile('img/'+Pieces[i+1]+'Black.png');
  Board[0,i].MoveCount:=0;
  Board[0,i].Field:=BoardDesc[0,i];
  Board[0,i].Width:=50;
  Board[0,i].Height:=50;
end;


end;


constructor TBoard.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  
  if (FBottomColor='black') then 
      BoardDesc := BoardRotation(BoardDesc);
  
end;

destructor TBoard.Destroy;
begin
  inherited;
end;

procedure TBoard.Paint();
begin

DrawBoard();
DrawLines();

end;

end.

