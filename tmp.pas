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
