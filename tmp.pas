ENUM TO STRING


type
  TThreeColors = (red, green, blue);
 
procedure TForm1.Button1Click(Sender: TObject);
var
  myFavouriteColor: TThreeColors;
  Value: string;
begin
  myFavouriteColor := green;
  WriteStr(Value, myFavouriteColor); // converts TThreeColors to string
  Showmessage(Value);
end;

 ThisDay := tue;
  s := GetEnumName(TypeInfo(TDays), Ord(ThisDay));
  writeln(s);
  readln;
  
  
 // !!!!!!!! to dziala
  Convert to string : WriteStr(AStringVariable, AComponentStyleVariable)
    Convert from string : ReadStr(AStringVariable, AComponentStyleVariable)



program HelloWorld;
uses
typinfo;
type
test = (jeden, dwa);
var
s:string;
begin
    s:=GetEnumName(TypeInfo(test),1);
    write(s);
end.





//fpc 3.0.0

program HelloWorld;

type
typ=array[0..7,0..7] of string;

CONST
CTable : array[0..7,0..7] of string =
(
('A8','B8','C8','D8','E8','F8','G8','H8'),
('A7','B7','C7','D7','E7','F7','G7','H7'),
('A6','B6','C6','D6','E6','F6','G6','H6'),
('A5','B5','C5','D5','E5','F5','G5','H5'),
('A4','B4','C4','D4','E4','F4','G4','H4'),
('A3','B3','C3','D3','E3','F3','G3','H3'),
('A2','B2','C2','D2','E2','F2','G2','H2'),
('A1','B1','C1','D1','E1','F1','G1','H1')
);

var
Table : array[0..7,0..7] of string;
i,j:integer;

function BoardRotation(arr : typ): typ;
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

begin
Table:=CTable;

for i:=0 to 7 do
begin
writeLn(' ');
    for j:=0 to 7 do
      write(Table[i,j]+' ');
end;

Table:=BoardRotation(Table);

writeLn(' ');
writeLn(' ');

for i:=0 to 7 do
begin
writeLn(' ');
    for j:=0 to 7 do
      write(Table[i,j]+' ');
end;

end.




procedure TForm1.BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
begin
  Bitmap.Rectangle(x, y, x2, y2, BGRA(0,0,0,alpha), dmDrawWithTransparency);
end;

