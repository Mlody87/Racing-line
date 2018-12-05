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
