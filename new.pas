TPossibleMoves = array of TPoint;
PossibleMoves:TPossibleMoves;


function TBoard.RookMoves(field:TPoint):TPossibleMoves;
var
color:string;
i:integer;
begin
color:=Board[field.x,field.y].color;

for i:=field.x to 7 do
  begin
    if (Board[i,field.y]='') then
    begin
      SetLength(PossibleMoves,Length(PossibleMoves)+1);
      PossibleMoves[High(PossibleMoves)]:=Point(i,field.y);
    end
    else
    begin
      if (Board[i,field.y]<>'') then
      begin
        if (Board[i,field.y].color=color) then
        begin
          Break;
        end
        else
        begin
          SetLength(PossibleMoves,Length(PossibleMoves)+1);
          PossibleMoves[High(PossibleMoves)]:=Point(i,field.y);
          Break;
        end;
      end;
    end;
  end;


end;
