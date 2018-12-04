TPossibleMoves = array of TPoint;
PossibleMoves:TPossibleMoves;

procedure TBoard.AddPossibleMove(move:TPoint);
begin
  SetLength(PossibleMoves,Length(PossibleMoves)+1);
  PossibleMoves[High(PossibleMoves)]:=move;
end;

procedure TBoard.RookMoves(field:TPoint);
var
color:string;
i:integer;
begin
color:=Board[field.x,field.y].color;

//down
for i:=field.x to 7 do
  begin
    if (Board[i,field.y]='') then
    begin
      AddPossibleMove(Point(i,field.y));
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
          AddPossibleMove(Point(i,field.y));
          Break;
        end;
      end;
    end;
  end;
  
  //up
for i:=field.x downto 0 do
  begin
    if (Board[i,field.y]='') then
    begin
      AddPossibleMove(Point(i,field.y));
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
          AddPossibleMove(Point(i,field.y));
          Break;
        end;
      end;
    end;
  end;
  
    //right
for i:=field.y to 7 do
  begin
    if (Board[field.x,i]='') then
    begin
      AddPossibleMove(Point(field.x,i));
    end
    else
    begin
      if (Board[field.x,i]<>'') then
      begin
        if (Board[field.x,i].color=color) then
        begin
          Break;
        end
        else
        begin
          AddPossibleMove(Point(field.x,i));
          Break;
        end;
      end;
    end;
  end;
  
      //left
for i:=field.y downto 0 do
  begin
    if (Board[field.x,i]='') then
    begin
      AddPossibleMove(Point(field.x,i));
    end
    else
    begin
      if (Board[field.x,i]<>'') then
      begin
        if (Board[field.x,i].color=color) then
        begin
          Break;
        end
        else
        begin
          AddPossibleMove(Point(field.x,i));
          Break;
        end;
      end;
    end;
  end;


end;
