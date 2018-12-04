unit Board;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls, BGRABitmap, BGRASVG, BGRABitmapTypes;

const
  START_WHITE_PIECES : array[0..8] of string = ('Pawn', 'Rook', 'Knight', 'Bishop', 'Queen', 'King', 'Bishop', 'Knight', 'Rook');
  START_BLACK_PIECES : array[0..8] of string = ('Pawn', 'Rook', 'Knight', 'Bishop', 'King', 'Queen', 'Bishop', 'Knight', 'Rook');

type

  TPieces = (Pawn=0, Rook=1, Knight=2, Bishop=3, Queen=4, King=5);

  TPieceColor = (White, Black);

  TPiece = record
  Piece:TPieces;
  Color:TPieceColor;
  MoveCount:integer;
  Pos:TPoint;
  Tied:boolean;
  end;

  TDAD = record
  DAD:boolean;
  DADCordsIJ:TPoint;
  DADCordsXY:TPoint;
  DADBoardPoint:TPoint;
  end;

  TBoardDesc = array[0..7,0..7] of string;
  TBoardPieces = array[0..7,0..7] of ^TPiece;

  TColorMove = record
    color:boolean;
    from:TPoint;
    too:TPoint;
  end;

  TBoard = class(TPaintBox)
  private
    { Private declarations }
    FBottomColor:String;
    Board:TBoardPieces;
    DAD:TDAD;
  protected
    { Protected declarations }
    BoardDesc : TBoardDesc;
    BitmapBoard:TBitmap;
    FirstRun:boolean;
    ResizeW,ResizeH:integer;
    ColorMove:TColorMove;

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
    function GetIJByName(FieldName:string):TPoint;
    procedure DADCancelMoving();
    procedure Move(From,Too:string);
    procedure ClearField(Field:TPoint);
    procedure AssignField(FFromIJ,FToIJ:TPoint);
    function IsWhiteBool(tmpcolor:boolean):boolean;
    procedure GenerateBitmapBoard();
    function CalculateFieldPos(point:TPoint):TRect;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure SetBottomColor(botcolor:string);
    procedure MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure CheckResize;
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
var
FSize:integer;
begin
  FSize:=FieldSize();

  GetFieldIJ.X:=(X div FSize);
  GetFieldIJ.Y:=(Y div FSize);

end;


function TBoard.GetFieldXY(X,Y:integer):TPoint;
var
Point:TPoint;
FSize:integer;
begin
  FSize:=FieldSize();
  Point:=GetFieldIJ(X,Y);

  GetFieldXY.X:=(Point.X)*FSize;
  GetFieldXY.Y:=(Point.Y)*FSize;

end;

function TBoard.GetFieldName(Field:TPoint):string;
begin
  GetFieldName:=BoardDesc[Field.x,Field.y];
end;

function TBoard.GetIJByName(FieldName:string):TPoint;
var
i,j:integer;
begin

for i:=0 to 7 do
  for j:=0 to 7 do
    begin
      if (BoardDesc[i,j]=FieldName) then
      begin
        GetIJByName:=Point(i,j);
        Exit;
      end;
    end;

end;

procedure TBoard.DADCancelMoving();
var
FSize:integer;
begin
  FSize:=FieldSize();
  Board[DAD.DADCordsIJ.X,DAD.DADCordsIJ.Y].Pos:=Point(FSize*DAD.DADCordsIJ.X, FSize*DAD.DADCordsIJ.Y);
  DAD.DAD:=false;
  Self.Repaint;
end;

procedure TBoard.ClearField(Field:TPoint);
var
FSize:integer;
begin
  FSize:=FieldSize();
  Board[Field.X,Field.Y].Piece:='';
  Board[Field.X,Field.Y].Color:='';
  Board[Field.X,Field.Y].MoveCount:=0;
  Board[Field.X,Field.Y].Field:='';
  Board[Field.X,Field.Y].Pos:=Point(FSize*Field.x, FSize*Field.y);
end;

procedure TBoard.AssignField(FFromIJ,FToIJ:TPoint);
var
FSize:integer;
begin
FSize:=FieldSize();
Board[FToIJ.X,FToIJ.Y].Piece:=Board[FFromIJ.X,FFromIJ.Y].Piece;
Board[FToIJ.X,FToIJ.Y].Color:=Board[FFromIJ.X,FFromIJ.Y].Color;
Board[FToIJ.X,FToIJ.Y].Image:=TBGRASVG.Create;
Board[FToIJ.X,FToIJ.Y].Image:=Board[FFromIJ.X,FFromIJ.Y].Image;
Board[FToIJ.X,FToIJ.Y].BMP:=Board[FFromIJ.X,FFromIJ.Y].BMP;
Board[FToIJ.X,FToIJ.Y].MoveCount:=Board[FFromIJ.X,FFromIJ.Y].MoveCount+1;
Board[FToIJ.X,FToIJ.Y].Field:=BoardDesc[FToIJ.X,FToIJ.Y];
Board[FToIJ.X,FToIJ.Y].Pos:=Point(FSize*FToIJ.X, FSize*FToIJ.Y);
end;

procedure TBoard.Move(From,Too:string);
var
FromIJ,ToIJ:TPoint;
begin

FromIJ:=GetIJByName(From);
ToIJ:=GetIJByName(Too);

if Board[ToIJ.X,ToIJ.Y].Piece<> '' then
  ClearField(ToIJ);

AssignField(FromIJ,ToIJ);

ClearField(FromIJ);

Self.Invalidate;

end;


procedure TBoard.CheckResize();
var
i,j,size:integer;
begin

    if ((ResizeW = Width) and (ResizeH = Height)) then Exit;

    ResizeW:=Width;
    ResizeH:=Height;

    size:=FieldSize();

    for i:=0 to 7 do
      for j:=0 to 7 do
        begin
          if Board[i,j].Piece<>'' then
          begin
            Board[i,j].Pos:=Point(size*i, size*j);
            Board[i,j].BMP.SetSize(size,size);
            Board[i,j].Image.StretchDraw(Board[i,j].BMP.Canvas2D, taCenter, tlCenter, 0,0,size,size);
          end;
        end;

    if (FirstRun=false) then
       GenerateBitmapBoard();

end;

procedure TBoard.MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var
test:TPoint;
begin
  inherited;

  test:=GetFieldIJ(X,Y);

  if Board[test.X,test.Y].Piece='' then
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

                 Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.x := Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.x+(X-DAD.DADBoardPoint.x);
                 Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.y := Board[DAD.DADCordsIJ.x,DAD.DADCordsIJ.y].Pos.y+(Y-DAD.DADBoardPoint.y);
                 DAD.DADBoardPoint.x:=X;
                 DAD.DADBoardPoint.y:=Y;

            Self.Invalidate;
            end;

end;

procedure TBoard.MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var
ActualField:TPoint;
begin
  inherited;

if (DAD.DAD) then
begin

if (X>Width)or(X<0)or(Y>Height)or(Y<0) then
begin
    DADCancelMoving;
    Exit;
end;

  ActualField:=GetFieldIJ(X,Y);

  if (PointsEqual(ActualField,DAD.DADCordsIJ)) then
  begin
    DADCancelMoving;
    Exit;
  end
  else
  begin
    ColorMove.color:=true;
    ColorMove.from:=DAD.DADCordsIJ;
    ColorMove.too:=ActualField;
    Move(GetFieldName(DAD.DADCordsIJ),GetFieldName(ActualField));
  end;

DAD.DAD:=False;

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
X,Y,i,j:integer;
Temp:TPiece;
FSize:integer;
begin
FSize:=FieldSize();
for X := 0 to 3 do
  for Y := 0 to 7 do
  begin
    Temp := arr[X, Y];
    BoardRotationPieces[X, Y] := arr[7 - X, 7 - Y];
    BoardRotationPieces[7 - X, 7 - Y] := Temp;

    for i:=0 to 7 do
        for j:=0 to 7 do
            BoardRotationPieces[i,j].Pos:=Point(FSize*i, FSize*j);

  end;
end;

function TBoard.FieldSize():integer;
begin
FieldSize := Round(Width div 8);
end;

function TBoard.IsWhiteBool(tmpcolor:boolean):boolean;
begin
    if tmpcolor then
  begin
     IsWhiteBool:=false;
  end
  else
  begin
     IsWhiteBool:=true;
  end;
end;

function TBoard.CalculateFieldPos(point:TPoint):TRect;
var
size:integer;
begin
  size:=FieldSize();

  CalculateFieldPos.Left:=(Size*point.x);
  CalculateFieldPos.Top:=(Size*point.y);
  CalculateFieldPos.Right:=(Size*point.x)+(Size+1);
  CalculateFieldPos.Bottom:=(Size*point.y)+(Size+1);
end;

procedure TBoard.DrawBoard();
var
field:TRect;
begin
Canvas.Clear;
Canvas.Draw(0,0,BitmapBoard);

if ColorMove.color then
begin
  Canvas.Pen.Color := clWhite;  //AAFFFF
  Canvas.brush.Color := TColor($0036bab9);

  field:=CalculateFieldPos(ColorMove.from);
  Canvas.rectangle(field);

  field:=CalculateFieldPos(ColorMove.too);
  Canvas.rectangle(field);
end;

end;

procedure TBoard.GenerateBitmapBoard();
var
iswhite:boolean;
i,j:integer;
field:TRect;
color1,color2:TColor;
begin


BitmapBoard.Clear;
BitmapBoard.Width:=Width;
BitmapBoard.Height:=Height;

iswhite:=false;
BitmapBoard.Canvas.Pen.Color := clWhite;


color1:=(181 shl 16)+ (217 shl 8)+ 240;
color2:=(99 shl 16)+ (136 shl 8)+ 181;

for i:=0 to 7 do
begin

iswhite:=IsWhiteBool(iswhite);

for j:=0 to 7 do
  begin

  field:=CalculateFieldPos(Point(i,j));

     if iswhite then
     begin
       BitmapBoard.Canvas.brush.Color := color1; //cl3DLight;
     end
     else
     begin
       BitmapBoard.Canvas.brush.Color := color2; //clAppWorkspace;
     end;

     BitmapBoard.Canvas.rectangle(field);

     iswhite:=IsWhiteBool(iswhite);

      end;
   end;

DrawLines();

end;


procedure TBoard.DrawLines();
begin

BitmapBoard.Canvas.Pen.Color := clBlack;

BitmapBoard.Canvas.Line(0,0,Width-1,0);
BitmapBoard.Canvas.Line(Width-1,0,Width-1,Width-1);
BitmapBoard.Canvas.Line(0,0,0,Width-1);
BitmapBoard.Canvas.Line(0,Width-1,Width-1,Width-1);

end;


procedure TBoard.SetStartPosition();
var
i,FSize:integer;
begin
FSize:=FieldSize();

for i:=0 to 7 do
begin
  //set white Pawns
  Board[i,6].Piece:=TStartWhitePieces[0];
  Board[i,6].Color:='white';
  Board[i,6].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+TStartWhitePieces[0]+'White.svg');
  Board[i,6].BMP:=TBGRABitmap.Create;
  Board[i,6].BMP.SetSize(FSize,FSize);
  Board[i,6].Image.StretchDraw(Board[i,6].BMP.Canvas2D, taCenter, tlCenter, 0,0,FSize,FSize);
  Board[i,6].MoveCount:=0;
  Board[i,6].Field:=BoardDesc[i,6];
  Board[i,6].Pos:=Point(FSize*i, FSize*6);
  //set black Pawns
  Board[i,1].Piece:=TStartBlackPieces[0];
  Board[i,1].Color:='black';
  Board[i,1].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+TStartBlackPieces[0]+'Black.svg');
  Board[i,1].BMP:=TBGRABitmap.Create;
  Board[i,1].BMP.SetSize(FSize,FSize);
  Board[i,1].Image.StretchDraw(Board[i,1].BMP.Canvas2D, taCenter, tlCenter, 0,0,FSize,FSize);
  Board[i,1].MoveCount:=0;
  Board[i,1].Field:=BoardDesc[i,1];
  Board[i,1].Pos:=Point(FSize*i, FSize*1);
end;

//set white Pices
for i:=0 to 7 do
begin
  Board[i,7].Piece:=TStartWhitePieces[i+1];
  Board[i,7].Color:='white';
  Board[i,7].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+TStartWhitePieces[i+1]+'White.svg');
  Board[i,7].BMP:=TBGRABitmap.Create;
  Board[i,7].BMP.SetSize(FSize,FSize);
  Board[i,7].Image.StretchDraw(Board[i,7].BMP.Canvas2D, taCenter, tlCenter, 0,0,FSize,FSize);
  Board[i,7].MoveCount:=0;
  Board[i,7].Field:=BoardDesc[i,7];
  Board[i,7].Pos:=Point(FSize*i, FSize*7);
//set black Pices
  Board[i,0].Piece:=TStartBlackPieces[i+1];
  Board[i,0].Color:='black';
  Board[i,0].Image:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+TStartBlackPieces[i+1]+'Black.svg');
  Board[i,0].BMP:=TBGRABitmap.Create;
  Board[i,0].BMP.SetSize(FSize,FSize);
  Board[i,0].Image.StretchDraw(Board[i,0].BMP.Canvas2D, taCenter, tlCenter, 0,0,FSize,FSize);
  Board[i,0].MoveCount:=0;
  Board[i,0].Field:=BoardDesc[i,0];
  Board[i,0].Pos:=Point(FSize*i, 0);
end;

end;

procedure TBoard.SetVariables();
begin

FBottomColor := 'white';

Pieces[0]:='Pawn'; Pieces[1]:='Rook'; Pieces[2]:='Knight'; Pieces[3]:='Bishop';
Pieces[4]:='Queen'; Pieces[5]:='King'; Pieces[6]:='Bishop'; Pieces[7]:='Knight'; Pieces[8]:='Rook';

BoardDesc[0,0]:='A8';BoardDesc[1,0]:='B8';BoardDesc[2,0]:='C8';BoardDesc[3,0]:='D8';BoardDesc[4,0]:='E8';BoardDesc[5,0]:='F8';BoardDesc[6,0]:='G8';BoardDesc[7,0]:='H8';
BoardDesc[0,1]:='A7';BoardDesc[1,1]:='B7';BoardDesc[2,1]:='C7';BoardDesc[3,1]:='D7';BoardDesc[4,1]:='E7';BoardDesc[5,1]:='F7';BoardDesc[6,1]:='G7';BoardDesc[7,1]:='H7';
BoardDesc[0,2]:='A6';BoardDesc[1,2]:='B6';BoardDesc[2,2]:='C6';BoardDesc[3,2]:='D6';BoardDesc[4,2]:='E6';BoardDesc[5,2]:='F6';BoardDesc[6,2]:='G6';BoardDesc[7,2]:='H6';
BoardDesc[0,3]:='A5';BoardDesc[1,3]:='B5';BoardDesc[2,3]:='C5';BoardDesc[3,3]:='D5';BoardDesc[4,3]:='E5';BoardDesc[5,3]:='F5';BoardDesc[6,3]:='G5';BoardDesc[7,3]:='H5';
BoardDesc[0,4]:='A4';BoardDesc[1,4]:='B4';BoardDesc[2,4]:='C4';BoardDesc[3,4]:='D4';BoardDesc[4,4]:='E4';BoardDesc[5,4]:='F4';BoardDesc[6,4]:='G4';BoardDesc[7,4]:='H4';
BoardDesc[0,5]:='A3';BoardDesc[1,5]:='B3';BoardDesc[2,5]:='C3';BoardDesc[3,5]:='D3';BoardDesc[4,5]:='E3';BoardDesc[5,5]:='F3';BoardDesc[6,5]:='G3';BoardDesc[7,5]:='H3';
BoardDesc[0,6]:='A2';BoardDesc[1,6]:='B2';BoardDesc[2,6]:='C2';BoardDesc[3,6]:='D2';BoardDesc[4,6]:='E2';BoardDesc[5,6]:='F2';BoardDesc[6,6]:='G2';BoardDesc[7,6]:='H2';
BoardDesc[0,7]:='A1';BoardDesc[1,7]:='B1';BoardDesc[2,7]:='C1';BoardDesc[3,7]:='D1';BoardDesc[4,7]:='E1';BoardDesc[5,7]:='F1';BoardDesc[6,7]:='G1';BoardDesc[7,7]:='H1';

PiecesBlack[0]:='Pawn';PiecesBlack[1]:='Rook';PiecesBlack[2]:='Knight';PiecesBlack[3]:='Bishop';
PiecesBlack[4]:='King';PiecesBlack[5]:='Queen';PiecesBlack[6]:='Bishop';PiecesBlack[7]:='Knight';PiecesBlack[8]:='Rook';

end;


procedure TBoard.DrawPosition();
var
i,j:integer;
begin

   for i:=0 to 7 do
   begin
       for j:=0 to 7 do
       begin
       if (Board[i,j].Piece<>'') then
       begin
         Canvas.Draw(Board[i,j].Pos.x, Board[i,j].Pos.y, Board[i,j].BMP.Bitmap);
       end;
   end;

end;
end;

constructor TBoard.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Self.Width:=496;
  Self.Height:=496;
  ResizeW:=496;
  ResizeH:=496;
  SetVariables();
  SetStartPosition();
  FirstRun:=true;
  ColorMove.color:=false;

end;

procedure TBoard.SetBottomColor(botcolor:string);
begin

   if (FBottomColor<>botcolor) then
      begin
      BoardDesc := BoardRotation(BoardDesc);
      Board := BoardRotationPieces(Board);
      FBottomColor:=botcolor;
      end;

   Self.repaint;

end;

destructor TBoard.Destroy;
begin
  inherited;
end;

procedure TBoard.Paint();
begin
  if FirstRun then
    begin
         BitmapBoard:=TBitmap.Create();
         GenerateBitmapBoard();
         FirstRun:=false;
    end;

CheckResize();
DrawBoard();
DrawPosition();

end;

end.
