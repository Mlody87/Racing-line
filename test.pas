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
  protected
    { Protected declarations }
    procedure Paint(); override;
    function BoardRotation(arr : TBoardDesc): TBoardDesc;
    procedure DrawBoard();
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

procedure TBoard.DrawBoard();
var
iswhite:boolean;
i,j:integer;
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

     field.Left:=(80*j);
     field.Top:=(80*i);
     field.Right:=(80*j)+81;
     field.Bottom:=(80*i)+81;

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

end.

