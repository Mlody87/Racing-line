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
