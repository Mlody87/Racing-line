unit Board;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls, BGRABitmap, BGRASVG, BGRABitmapTypes,typinfo;

const
  START_WHITE_PIECES : array[0..8] of string = ('Pawn', 'Rook', 'Knight', 'Bishop', 'Queen', 'King', 'Bishop', 'Knight', 'Rook');
  START_BLACK_PIECES : array[0..8] of string = ('Pawn', 'Rook', 'Knight', 'Bishop', 'King', 'Queen', 'Bishop', 'Knight', 'Rook');

type

  TPieces = (Pawn, Rook, Knight, Bishop, Queen, King);

  TPieceColor = (White, Black);

  TPiece = record
  Piece:TPieces;
  Color:TPieceColor;
  MoveCount:integer;
  DAD:boolean;
  Tied:boolean;
  end;

  TDAD = record
  active:boolean;
  Piece:Pointer;
  FromCordsIJ:TPoint;
  ActualCordsXY:TPoint;
  BoardPoint:TPoint;
  end;
  
  TPieceImage = record
    svg:TBGRASVG;
    bmp:TBGRABitmap;
  end;
  
  TPiecesImages = array[0..5] of TPieceImage;

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
    WhiteImages,BlackImages:TPiecesImages;
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
    function BoardRotationPieces;
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
    procedure LoadPiecesImages();
    procedure SetPiecesSize();
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
begin
  DAD.active:=false;
  Board[DAD.FromCordsIJ.x,DAD.FromCordsIJ.y]^.DAD:=false;
  Self.Repaint;
end;

procedure TBoard.ClearField(Field:TPoint);
begin
  Board[Field.X,Field.Y]:=nil;
end;

procedure TBoard.AssignField(FFromIJ,FToIJ:TPoint);
begin
  Board[FToIJ.X,FToIJ.Y]:=Board[FFromIJ.X,FFromIJ.Y];
end;

procedure TBoard.Move(From,Too:string);
var
FromIJ,ToIJ:TPoint;
begin

FromIJ:=GetIJByName(From);
ToIJ:=GetIJByName(Too);

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

    SetPiecesSize();

    if (FirstRun=false) then
       GenerateBitmapBoard();

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

  DAD.FromCordsIJ:=test;

  DAD.ActualCordsXY:=GetFieldXY(X,Y);

  DAD.BoardPoint:=Point(X,Y);

end;

procedure TBoard.MouseMove(Shift: TShiftState; X,Y: Integer);
begin
  inherited;

   if (DAD.active) then
     begin
       DAD.ActualCordsXY.X:=DAD.ActualCordsXY.X+(X-DAD.BoardPoint.X);
       DAD.ActualCordsXY.Y:=DAD.ActualCordsXY.Y+(Y-DAD.BoardPoint.Y);                 
       DAD.BoardPoint.x:=X;
       DAD.BoardPoint.y:=Y;

       Self.Invalidate;
     end;
end;

procedure TBoard.MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var
ActualField:TPoint;
begin
  inherited;

if (DAD.active) then
begin

  if (X>Width)or(X<0)or(Y>Height)or(Y<0) then
  begin
    DADCancelMoving;
    Exit;
  end;

  ActualField:=GetFieldIJ(X,Y);

  if (PointsEqual(ActualField,DAD.FromCordsIJ)) then
  begin
    DADCancelMoving;
    Exit;
  end
  else
  begin
    ColorMove.color:=true;
    ColorMove.from:=DAD.FromCordsIJ;
    ColorMove.too:=ActualField;
    Move(GetFieldName(DAD.FromCordsIJ),GetFieldName(ActualField));
  end;

DAD.active:=False;

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

function TBoard.BoardRotationPieces;
var
X,Y:integer;
Temp:^TPiece;
begin
for X := 0 to 3 do
  for Y := 0 to 7 do
  begin
    Temp := Board[X, Y];
    Board[X, Y] := Board[7 - X, 7 - Y];
    Board[7 - X, 7 - Y] := Temp;
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
  Canvas.Pen.Color := clWhite;
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
i:integer;
tmp:^TPiece;
begin

for i:=0 to 7 do
begin
  //set white Pawns
  new(tmp);
  ReadStr(TStartWhitePieces[0], tmp.Piece);
  tmp.Color:=White;
  tmp.MoveCount:=0;
  tmp.Tied:=false;
  tmp.DAD:=false;
  Board[i,6]:=tmp;
  
  //set black Pawns
  new(tmp);
  ReadStr(TStartBlackPieces[0], tmp.Piece);
  tmp.Color:=White;
  tmp.MoveCount:=0;
  tmp.Tied:=false;
  tmp.DAD:=false;
  Board[i,1]:=tmp;
end;

//set white Pices
for i:=0 to 7 do
begin
  new(tmp);
  ReadStr(TStartWhitePieces[i+1], tmp.Piece);
  tmp.Color:=White;
  tmp.MoveCount:=0;
  tmp.Tied:=false;
  tmp.DAD:=false;
  Board[i,7]:=tmp;

//set black Pices
  new(tmp);
  ReadStr(TStartBlackPieces[i+1], tmp.Piece);
  tmp.Color:=White;
  tmp.MoveCount:=0;
  tmp.Tied:=false;
  tmp.DAD:=false;
  Board[i,0]:=tmp;
end;

end;

procedure TBoard.SetPiecesSize();
var
i:integer;
tmp:string;
FSize:integer;
begin
FSize:=FieldSize();

//load white images
for i:=0 to 5 do
begin
  tmp:=GetEnumName(TypeInfo(TPieces),i);
  WhiteImages[i].bmp:=SetSize(FSize,FSize);
  WhiteImages[i].svg.StretchDraw(WhiteImages[i].bmp.Canvas2D, taCenter, tlCenter, 0,0,FSize,FSize);
end;

//load black images
for i:=0 to 5 do
begin
  tmp:=GetEnumName(TypeInfo(TPieces),i);
  BlackImages[i].bmp:=SetSize(FSize,FSize);
  BlackImages[i].svg.StretchDraw(WhiteImages[i].bmp.Canvas2D, taCenter, tlCenter, 0,0,FSize,FSize);
end;


procedure TBoard.LoadPiecesImages();
var
i:integer;
tmp:string;
begin

//load white images
for i:=0 to 5 do
begin
  tmp:=GetEnumName(TypeInfo(TPieces),i);
  WhiteImages[i].svg:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+tmp+'White.svg');
  WhiteImages[i].bmp:=TBGRABitmap.Create;
end;

//load black images
for i:=0 to 5 do
begin
  tmp:=GetEnumName(TypeInfo(TPieces),i);
  BlackImages[i].svg:=TBGRASVG.Create('C:\Users\Mlody\SzachownicaKomponent\img\'+tmp+'Black.svg');
  BlackImages[i].bmp:=TBGRABitmap.Create;
end;

end;


procedure TBoard.SetVariables();
begin

FBottomColor := 'white';
DAD.active := false;

BoardDesc[0,0]:='A8';BoardDesc[1,0]:='B8';BoardDesc[2,0]:='C8';BoardDesc[3,0]:='D8';BoardDesc[4,0]:='E8';BoardDesc[5,0]:='F8';BoardDesc[6,0]:='G8';BoardDesc[7,0]:='H8';
BoardDesc[0,1]:='A7';BoardDesc[1,1]:='B7';BoardDesc[2,1]:='C7';BoardDesc[3,1]:='D7';BoardDesc[4,1]:='E7';BoardDesc[5,1]:='F7';BoardDesc[6,1]:='G7';BoardDesc[7,1]:='H7';
BoardDesc[0,2]:='A6';BoardDesc[1,2]:='B6';BoardDesc[2,2]:='C6';BoardDesc[3,2]:='D6';BoardDesc[4,2]:='E6';BoardDesc[5,2]:='F6';BoardDesc[6,2]:='G6';BoardDesc[7,2]:='H6';
BoardDesc[0,3]:='A5';BoardDesc[1,3]:='B5';BoardDesc[2,3]:='C5';BoardDesc[3,3]:='D5';BoardDesc[4,3]:='E5';BoardDesc[5,3]:='F5';BoardDesc[6,3]:='G5';BoardDesc[7,3]:='H5';
BoardDesc[0,4]:='A4';BoardDesc[1,4]:='B4';BoardDesc[2,4]:='C4';BoardDesc[3,4]:='D4';BoardDesc[4,4]:='E4';BoardDesc[5,4]:='F4';BoardDesc[6,4]:='G4';BoardDesc[7,4]:='H4';
BoardDesc[0,5]:='A3';BoardDesc[1,5]:='B3';BoardDesc[2,5]:='C3';BoardDesc[3,5]:='D3';BoardDesc[4,5]:='E3';BoardDesc[5,5]:='F3';BoardDesc[6,5]:='G3';BoardDesc[7,5]:='H3';
BoardDesc[0,6]:='A2';BoardDesc[1,6]:='B2';BoardDesc[2,6]:='C2';BoardDesc[3,6]:='D2';BoardDesc[4,6]:='E2';BoardDesc[5,6]:='F2';BoardDesc[6,6]:='G2';BoardDesc[7,6]:='H2';
BoardDesc[0,7]:='A1';BoardDesc[1,7]:='B1';BoardDesc[2,7]:='C1';BoardDesc[3,7]:='D1';BoardDesc[4,7]:='E1';BoardDesc[5,7]:='F1';BoardDesc[6,7]:='G1';BoardDesc[7,7]:='H1';

end;


procedure TBoard.DrawPosition();
var
i,j,x,y,FSize:integer;
begin
FSize:=FieldSize();

   for i:=0 to 7 do
   begin
       for j:=0 to 7 do
       begin
       if (Board[i,j]<>nil) then
       begin
       
         if (Board[i,j]^.DAD=true) then
         begin
           x:=DAD.ActualCordsXY.X;
           y:=DAD.ActualCordsXY.Y;
         end
         else
         begin
           x:=FSize*i;
           y:=FSize*j;
         end;
       
         if Board[i,j]^.Color=White then
         begin
           Canvas.Draw(x, y, WhiteImages[Ord(Board[i,j]^.Piece)].bmp.Bitmap);         
         end
         else
         begin
           Canvas.Draw(x, y, BlackImages[Ord(Board[i,j]^.Piece)].bmp.Bitmap);           
         end;
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
         LoadPiecesImages();
         SetPiecesSize();
         GenerateBitmapBoard();
         FirstRun:=false;
    end;

CheckResize();
DrawBoard();
DrawPosition();

end;

end.
