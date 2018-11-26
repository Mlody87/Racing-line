unit Board;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls, BGRABitmap, BGRASVG, BGRABitmapTypes;

type

  TPiece = record
  Piece:string;
  Color:string;
  Image: TBGRASVG;
  MoveCount:integer;
  Field:string;
  Pos:TPoint;
  end;

  TDAD = record
  DAD:boolean;
  DADCordsIJ:TPoint;
  DADCordsXY:TPoint;
  DADBoardPoint:TPoint;
  end;

  TBoardDesc = array[0..7,0..7] of string;
  TPieces = array[0..8] of string;
  TBoardPieces = array[0..7,0..7] of TPiece;

  TBoard = class(TPaintBox)
  private
    { Private declarations }
    FBottomColor:String;
    Board:TBoardPieces;
    DAD:TDAD;
  protected
    { Protected declarations }
    BoardDesc : TBoardDesc;
        Pieces : TPieces;
        PiecesBlack : TPieces;

    procedure Paint(); override;
    function BoardRotation(arr : TBoardDesc): TBoardDesc;
    function BoardRotationPieces(arr : TBoardPieces): TBoardPieces;
    function FieldSize():integer;
    procedure DrawBoard();
    procedure DrawLines();
    procedure DrawPosition();
    procedure SetStartPosition();
    procedure SetVariables();
    function GetFieldIJ(X,Y:integer):TPoint; //by point on board
    function GetFieldXY(X,Y:integer):TPoint; //by point on board
    function GetFieldName(Field:TPoint):string; //by ij
    function GetIJByName(name:string):TPoint;
   procedure DADCancelMoving();
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure SetBottomColor(botcolor:string);
    procedure MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Additional',[TBoard]);
end;

function TBoard.GetFieldIJ(X,Y:integer):TPoint; 
begin

  GetFieldIJ.X:=(X div FieldSize());
  GetFieldIJ.Y:=(Y div FieldSize());

end;


function TBoard.GetFieldXY(X,Y:integer):TPoint; 
var
Point:TPoint;
begin

  Point:=GetFieldIJ(X,Y);

  GetFieldXY.X:=(Point.X)*FieldSize();
  GetFieldXY.Y:=(Point.Y)*FieldSize();

end;

function TBoard.GetFieldName(Field:TPoint):string; 
begin
  GetFieldName:=BoardDesc[Field.x,Field.y].Field;
end;

function TBoard.GetIJByName(name:string):TPoint;
var
i,j:integer;
begin

for i:=0 to 7 do
  for j:=0 to 7 do
    begin
      if (BoardDesc[i,j].Field=name) then
      begin
        GetIJByName:=Point(i,j);
        Exit;
      end;
    end;

end;

procedure TBoard.MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var
test:TPoint;
begin
  inherited;
  
  test:=GetFieldIJ(X,Y);
  
  if Board[test.X,test.Y]=nil then
    Exit;
  

  DAD.DAD:=true;

  DAD.DADCordsIJ:=test;

  DAD.DADCordsXY:=GetFieldXY(X,Y);

  DAD.DADBoardPoint:=Point(X,Y);

end;

procedure TBoard.MouseMove(Shift: TShiftState; X,Y: Integer);
begin
  inherited;

   if (DAD.DAD) then
            begin
            if X>DAD.DADBoardPoint.X then
            begin
                 Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.x := Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.x+(X-DAD.DADBoardPoint.x);
                 DAD.DADBoardPoint.x:=X;
            end;
            if X<DAD.DADBoardPoint.X then
            begin
                 Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.x := Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.x-(DAD.DADBoardPoint.x-X);
                 DAD.DADBoardPoint.x:=X;
            end;
            if Y<DAD.DADBoardPoint.Y then
            begin
                 Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.y := Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.y-(DAD.DADBoardPoint.y-Y);
                 DAD.DADBoardPoint.y:=Y;
            end;
            if Y>DAD.DADBoardPoint.Y then
            begin
                 Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.y := Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.y+(Y-DAD.DADBoardPoint.y);
                 DAD.DADBoardPoint.y:=Y;
            end;

            Self.Invalidate;
            end;


end;

procedure TBoard.DADCancelMoving();
begin
  Board[DAD.DADCordsIJ.X,DAD.DADCordsIJ.Y].Pos:=DAD.DADCordsXY;
  DAD.DAD:=false;
  Self.Repaint;
end;

procedure TBoard.ClearField(Field:TPoint);
begin
  Board[Field.X,Field.Y].Piece:='';
  Board[Field.X,Field.Y].Color:='';
  Board[Field.X,Field.Y].Image.Free;
  Board[Field.X,Field.Y].MoveCount:=0;
  Board[Field.X,Field.Y].Field:='';
  Board[Field.X,Field.Y].Pos:TPoint;
  Board[Field.X,Field.Y]:=nil;
end;

procedure TBoard.Move(From,To:string);
var
FromIJ,ToIJ:TPoint;
begin

FromIJ:=GetIJByName(From);
ToIJ:=GetIJByName(To);

if Board[ToIJ.X,ToIJ.Y]<> nil then
  ClearField(ToIJ);

Board[ToIJ.X,ToIJ.Y].Piece:=Board[FromIJ.X,FromIJ.Y].Piece;
Board[ToIJ.X,ToIJ.Y].Color:=Board[FromIJ.X,FromIJ.Y].Color;
Board[ToIJ.X,ToIJ.Y].Image:=Board[FromIJ.X,FromIJ.Y].Image;
Board[ToIJ.X,ToIJ.Y].MoveCount:=Board[FromIJ.X,FromIJ.Y].MoveCount+1;
Board[ToIJ.X,ToIJ.Y].Field:=BoardDesc[ToIJ.X,ToIJ.Y];
Board[ToIJ.X,ToIJ.Y].Pos:=Point(FieldSize()*ToIJ.X, FieldSize()*ToIJ.Y);

ClearField(FromIJ);

end;


procedure TBoard.MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var
i,j:integer;
ActualField:TPoint;
begin
  inherited;
    function GetFieldIJ(X,Y:integer):TPoint;
    function GetFieldXY(X,Y:integer):TPoint;
  DAD:boolean;
  DADCordsIJ:TPoint;
  DADCordsXY:TPoint;
  DADBoardPoint:TPoint;

if (DAD.DAD) then
begin
  
  ActualField:=GetFieldIJ(X,Y);
  
  if (PointsEqual(ActualField,DAD.DADCordsIJ)) then
  begin
  
  DADCancelMoving;
  Exit;
  
  end
  else
  begin
  
  
  end;
  

end;


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

function TBoard.BoardRotationPieces(arr : TBoardPieces): TBoardPieces;
var
X,Y:integer;
Temp:TPiece;
begin
for X := 0 to 3 do
  for Y := 0 to 7 do
  begin
    Temp := arr[X, Y];
    BoardRotationPieces[X, Y] := arr[7 - X, 7 - Y];
    BoardRotationPieces[7 - X, 7 - Y] := Temp;
  end;
end;

function TBoard.FieldSize():integer;
begin
FieldSize := Round(Width div 8);
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

      if iswhite then
      begin
         iswhite:=false;
      end
      else
      begin
         iswhite:=true;
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

for i:=0 to 7 do
begin
  //set white Pawns
  Board[i,6].Piece:=Pieces[0];
  Board[i,6].Color:='white';
  Board[i,6].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+Pieces[0]+'White.svg');
  Board[i,6].MoveCount:=0;
  Board[i,6].Field:=BoardDesc[i,6];
  Board[i,6].Pos:=Point(FieldSize()*i, FieldSize()*6);
  //set black Pawns
  Board[i,1].Piece:=Pieces[0];
  Board[i,1].Color:='black';
  Board[i,1].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+Pieces[0]+'Black.svg');
  Board[i,1].MoveCount:=0;
  Board[i,1].Field:=BoardDesc[i,1];
  Board[i,1].Pos:=Point(FieldSize()*i, FieldSize()*1);
end;

//set white Pices
for i:=0 to 7 do
begin
  Board[i,7].Piece:=Pieces[i+1];
  Board[i,7].Color:='white';
  Board[i,7].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+Pieces[i+1]+'White.svg');
  Board[i,7].MoveCount:=0;
  Board[i,7].Field:=BoardDesc[i,7];
  Board[i,7].Pos:=Point(FieldSize()*i, FieldSize()*7);
//set black Pices
  Board[i,0].Piece:=PiecesBlack[i+1];
  Board[i,0].Color:='black';
  Board[i,0].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+Pieces[i+1]+'Black.svg');
  Board[i,0].MoveCount:=0;
  Board[i,0].Field:=BoardDesc[i,0];
  Board[i,0].Pos:=Point(FieldSize()*i, 0);
end;

end;

procedure TBoard.SetVariables();
begin

FBottomColor := 'white';

Pieces[0]:='Pawn'; Pieces[1]:='Rook'; Pieces[2]:='Knight'; Pieces[3]:='Bishop';
Pieces[4]:='Queen'; Pieces[5]:='King'; Pieces[6]:='Bishop'; Pieces[7]:='Knight'; Pieces[8]:='Rook';

BoardDesc[0,0]:='A8';BoardDesc[0,1]:='B8';BoardDesc[0,2]:='C8';BoardDesc[0,3]:='D8';BoardDesc[0,4]:='E8';BoardDesc[0,5]:='F8';BoardDesc[0,6]:='G8';BoardDesc[0,7]:='H8';
BoardDesc[1,0]:='A7';BoardDesc[1,1]:='B7';BoardDesc[1,2]:='C7';BoardDesc[1,3]:='D7';BoardDesc[1,4]:='E7';BoardDesc[1,5]:='F7';BoardDesc[1,6]:='G7';BoardDesc[1,7]:='H7';
BoardDesc[2,0]:='A6';BoardDesc[2,1]:='B6';BoardDesc[2,2]:='C6';BoardDesc[2,3]:='D6';BoardDesc[2,4]:='E6';BoardDesc[2,5]:='F6';BoardDesc[2,6]:='G6';BoardDesc[2,7]:='H6';
BoardDesc[3,0]:='A5';BoardDesc[3,1]:='B5';BoardDesc[3,2]:='C5';BoardDesc[3,3]:='D5';BoardDesc[3,4]:='E5';BoardDesc[3,5]:='F5';BoardDesc[3,6]:='G5';BoardDesc[3,7]:='H5';
BoardDesc[4,0]:='A4';BoardDesc[4,1]:='B4';BoardDesc[4,2]:='C4';BoardDesc[4,3]:='D4';BoardDesc[4,4]:='E4';BoardDesc[4,5]:='F4';BoardDesc[4,6]:='G4';BoardDesc[4,7]:='H4';
BoardDesc[5,0]:='A3';BoardDesc[5,1]:='B3';BoardDesc[5,2]:='C3';BoardDesc[5,3]:='D3';BoardDesc[5,4]:='E3';BoardDesc[5,5]:='F3';BoardDesc[5,6]:='G3';BoardDesc[5,7]:='H3';
BoardDesc[6,0]:='A2';BoardDesc[6,1]:='B2';BoardDesc[6,2]:='C2';BoardDesc[6,3]:='D2';BoardDesc[6,4]:='E2';BoardDesc[6,5]:='F2';BoardDesc[6,6]:='G2';BoardDesc[6,7]:='H2';
BoardDesc[7,0]:='A1';BoardDesc[7,1]:='B1';BoardDesc[7,2]:='C1';BoardDesc[7,3]:='D1';BoardDesc[7,4]:='E1';BoardDesc[7,5]:='F1';BoardDesc[7,6]:='G1';BoardDesc[7,7]:='H1';

PiecesBlack[0]:='Pawn';PiecesBlack[1]:='Rook';PiecesBlack[2]:='Knight';PiecesBlack[3]:='Bishop';
PiecesBlack[4]:='King';PiecesBlack[4]:='Queen';PiecesBlack[5]:='Bishop';PiecesBlack[6]:='Knight';PiecesBlack[7]:='Rook';

end;


procedure TBoard.DrawPosition();
var
i,j:integer;
lockX,lockY:integer;
BMP:TBGRABitmap;
begin

   for i:=0 to 7 do
   begin
       for j:=0 to 7 do
       begin
       if (Board[i,j].Image<>nil) then
       begin

         BMP:=TBGRABitmap.Create;

         BMP.SetSize(FieldSize(),FieldSize());

         Board[i,j].Image.StretchDraw(BMP.Canvas2D, taCenter, tlCenter, 0,0,FieldSize(),FieldSize());
         
         Canvas.Draw(Board[i,j].Pos.x, Board[i,j].Pos.y, BMP.Bitmap);
         
         BMP.Free;

       end;
   end;

end;

end;

constructor TBoard.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Self.Width:=500;
Self.Height:=500;
  SetVariables();
  SetStartPosition();

end;

procedure TBoard.SetBottomColor(botcolor:string);
begin

   if (FBottomColor<>botcolor) then
      begin
      BoardDesc := BoardRotation(BoardDesc);
      Board := BoardRotationPieces(Board);
      end;

   FBottomColor:=botcolor;

   Self.Repaint;

end;

destructor TBoard.Destroy;
begin
  inherited;
end;

procedure TBoard.Paint();
begin
DrawBoard();
DrawLines();
DrawPosition();

end;

end.
