pion*E2*E4*ruch#
pion*F7*F5*ruch#
pion*E4*E5*ruch#
pion*D7*D5*ruch#
pion*E5*D6*przelot*D5#
pion*E7*E6*ruch#
goniec*F1*D3*ruch#
goniec*F8*E7*ruch#
skoczek*G1*F3*ruch#
skoczek*G8*F6*ruch#
krol*E1*G1*roszada#
krol*E8*G8*roszada#
pion*D6*C7*ruch#
pion*B7*B5*ruch#
pion*C2*C4*ruch#
pion*B5*B4*ruch#
pion*A2*A4*ruch#
pion*B4*A3*przelot*A4#
pion*C7*D8*promocja*hetman#


unit partia;

{$mode objfpc}{$H+}



interface

uses
 Classes, SysUtils, Dialogs, Windows, LCLType, FileUtil, Forms, Controls,
 Graphics, ExtCtrls, StdCtrls, Grids, types, StrUtils, promocja, syncobjs,
 WyslijWiadomosc, ChessPanel;

type

 TKolorowanieRuchu=record
    ok:boolean;
    Z:TPoint;
    NA:TPoint;
  end;

 TKolorowanieSzach=record   //np przy szachu
   ok:boolean;
   pole:TPoint;
 end;

  TDaneBoard=record
    pole:string;
    KolorPola:string;
    X:integer;
    Y:integer;
  end;


  TBierka = class(TObject)
    public
      pole:string;
      kolor:string;
      rodzaj:string;
      obraz:TPortableNetworkGraphic;
      pozycja:TPoint;
  end;

  TRuch = record
     figura:string;
     kolor:string;
     Z:string;
     NA:string;
     uwagi:string;
   end;

  TWPrzelocie = record
     ok:boolean;
     Z:string;
     NA:string;
     bite:string;
  end;

    TUstawienia = record
     GramKolorem:string;
     KogoRuch:string;
     KolorNaDole:string;
     KolorNaGorze:string;
  end;

  TMapaRuchow=array of string;

  TBoard=array[1..8,1..8] of TBierka;

  TTablicaPunktow=array of TPoint;

  { TForm3 }

  TForm3 = class(TForm)
    LUpdateRankBiale: TLabel;
    LUpdateRankCzarne: TLabel;
    PanelPartia: TChessPanel;
    ZaproponujRemis: TButton;
    PoddajPartie: TButton;
    PrzyjmijRemis: TButton;
    OdrzucRemis: TButton;
    ECzasCzarne: TPanel;
    BialeMini: TImage;
    CzarneMini: TImage;
    Label3: TLabel;
    Label4: TLabel;
    ECzasBiale: TPanel;
    PartiaInfo: TPanel;
    TimerCzasBiale: TTimer;
    TimerCzasCzarne: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    PaintBox1: TPaintBox;
    przebieg: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure OdrzucRemisClick(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PoddajPartieClick(Sender: TObject);
    procedure PrzyjmijRemisClick(Sender: TObject);
    procedure ZaproponujRemisClick(Sender: TObject);
    function ZnajdzIJbyPole(pole:string):TPoint;
    function ZnajdzXYbyPole(poz:string):TPoint;
    function ZnajdzPolebyXY(X,Y:integer):string;
    function ZnajdzXYbyIJ(i,j:integer):TPoint;
    function KtoAtakujePole(pol,kol:string; szachownica:Pointer):TTablicaPunktow;
    function KtoBroniPole(p:TPoint; kol:string; szachownica:Pointer):TTablicaPunktow;
    function CzySieRuszal(polozenie:TPoint):boolean;
    function CzyCosStanieNaPolu(pozycja,kolor:string;szachownica:Pointer):boolean;
    function CzyMoznaZaslonic(atakowany,atakujacy:TPoint):boolean;
    function MozliweRuchy(WyjsciowePole:string):TMapaRuchow;
    function CzyLegalnyRuch(NaPole:string):boolean;
    function CzySzach(kolor:string):boolean;
    function ZapiszRuch(Z,Na,rodzaj,kolor,Uwagi:string):boolean;
    function OdswiezPrzebieg:boolean;
    function WykonajRuch(Z,Na,Uwagi:string):boolean;
    function CzyKrolMaGdzieUciec(K:TPoint):boolean;
    function CzyMat(kolor:string):boolean;
    function CzyPat(kol:string):boolean;
    function CzyRemis(kol:string):boolean;
    function ZostalTylkoKrol(kolor:string):boolean;

    function OdswiezCzas:boolean;

    procedure TimerCzasBialeTimer(Sender: TObject);
    procedure TimerCzasCzarneTimer(Sender: TObject);

    //procedure UstawTimerek(kolor,co:string);

  private
    { private declarations }
    CzasBiale:integer;
    CzasCzarne:integer;
    start:boolean;
    id_partii:integer;
    ObslugaKomunikatuPartii:string;
    Send:TWyslijWiadomosc;

    sgCellBg:TPortableNetworkGraphic;


    Board : TBoard;
  DaneBoard : array[1..8,1..8] of TDaneBoard;

  DAD:boolean;
  DadBierka:^TBierka;

  PunktPlansza,PolePlansza:TPoint;

  MozliweWPrzelocie:TWPrzelocie;

  KolorowanieRuchu:TKolorowanieRuchu;
  KolorowanieSzach:TKolorowanieSzach;

  TablicaRuchow:TMapaRuchow; //lista dozwolonych ruchow na planszy dla bierki

  PrzebiegPartii:array of TRuch; //lista ruchow podczas partii
    Ustawienia:TUstawienia;

  public
    { public declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure PrzekazDaneNaStart(linia:string);
    procedure PrzekazKomunikat(kom:string);
    procedure komunikat;
    procedure PokazForme;
  end;

  CONST

  POLA : array[1..8,1..8] of string =
    (('A8','B8','C8','D8','E8','F8','G8','H8'),
    ('A7','B7','C7','D7','E7','F7','G7','H7'),
    ('A6','B6','C6','D6','E6','F6','G6','H6'),
    ('A5','B5','C5','D5','E5','F5','G5','H5'),
    ('A4','B4','C4','D4','E4','F4','G4','H4'),
    ('A3','B3','C3','D3','E3','F3','G3','H3'),
    ('A2','B2','C2','D2','E2','F2','G2','H2'),
    ('A1','B1','C1','D1','E1','F1','G1','H1'));

  OBRAZYFIGUR : array[1..18] of string =
    ('PionBialy.png','WiezaBiala.png','SkoczekBialy.png','GoniecBialy.png','HetmanBialy.png','KrolBialy.png','GoniecBialy.png','SkoczekBialy.png','WiezaBiala.png',
     'PionCzarny.png','WiezaCzarna.png','SkoczekCzarny.png','GoniecCzarny.png','HetmanCzarny.png','KrolCzarny.png','GoniecCzarny.png','SkoczekCzarny.png','WiezaCzarna.png');

  FIGURY : array[1..9] of string =
    ('pion','wieza','skoczek','goniec','hetman','krol','goniec','skoczek','wieza');



var
  Form3: TForm3;

implementation
uses unit1;
{$R *.lfm}


procedure TForm3.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if (FormStyle = fsNormal) then begin
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
    Params.WndParent := GetDesktopWindow;
  end;
end;


{ ---- pomocnicze -----}


function TForm3.ZnajdzXYbyPole(poz:string):TPoint;
var
  i,j:integer;
  punkt:TPoint;
begin

for i:=1 to 8 do
    for j:=1 to 8 do
    begin
     if DaneBoard[i,j].pole=poz then
      begin
           punkt.x:=DaneBoard[i,j].X;
           punkt.y:=DaneBoard[i,j].Y;
           Result:=punkt;
           Break;
      end;
    end;
end;

function TForm3.ZnajdzPolebyXY(X,Y:integer):string;
var
  a,b:integer;
begin

a:=(X div 80)+1;
b:=(Y div 80)+1;

Result:=DaneBoard[b,a].pole;
end;

function TForm3.ZnajdzXYbyIJ(i,j:integer):TPoint;
begin
Result:=Point(DaneBoard[i,j].X, DaneBoard[i,j].Y);
end;

function TForm3.ZnajdzIJbyPole(pole:string):TPoint;
var
i,j:integer;
begin

for i:=1 to 8 do
for j:=1 to 8 do
  if DaneBoard[i,j].pole=pole then Result:=Point(i,j);

end;

procedure TForm3.FormCreate(Sender: TObject);
begin

//Tworzymy forme
Send:=TWyslijWiadomosc.Create();

end;

procedure TForm3.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;



{-------------}

function TForm3.OdswiezCzas:boolean;
begin
  ECzasBiale.Caption:=IntToStr(CzasBiale div 60);
  ECzasBiale.Caption:=ECzasBiale.Caption+':';
  if (CzasBiale mod 60)<10 then ECzasBiale.Caption:=ECzasBiale.Caption+'0';
  ECzasBiale.Caption:=ECzasBiale.Caption+IntToStr(CzasBiale mod 60);


  ECzasCzarne.Caption:=IntToStr(CzasCzarne div 60);
  ECzasCzarne.Caption:=ECzasCzarne.Caption+':';
  if (CzasCzarne mod 60)<10 then ECzasCzarne.Caption:=ECzasCzarne.Caption+'0';
  ECzasCzarne.Caption:=ECzasCzarne.Caption+IntToStr(CzasCzarne mod 60);
end;

function TForm3.KtoAtakujePole(pol,kol:string; szachownica:Pointer):TTablicaPunktow;
var
i,j,tmpX:integer;
wynik:array of TPoint;
B:^TBoard;
KolorPola:string;
p:TPoint;
begin

  p:=ZnajdzIJbyPole(pol);

  SetLength(wynik, 0);

B:=szachownica;

if B^[p.X,p.Y]=nil then
begin
  KolorPola:=kol;
end
else
begin
  KolorPola:=B^[p.X,p.Y].kolor;
end;

//sprawdzamy na lewo od pola
   for i:=1 to 8 do
   begin
      if p.Y-i<1 then Break;

      if B^[p.X, p.Y-i]<> nil then
      begin
          if B^[p.X, p.Y-i].kolor = KolorPola then begin Break; end else
          begin
             if (B^[p.X, p.Y-i].rodzaj='wieza') or (B^[p.X, p.Y-i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x,p.y-i);
		end;
             Break;
          end;
      end;

   end;

   //sprawdzamy na prawo od pola
      for i:=1 to 8 do
      begin
         if p.Y+i>8 then Break;

         if B^[p.X, p.Y+i]<> nil then
         begin
             if B^[p.X, p.Y+i].kolor = KolorPola then begin Break; end else
             begin
                if (B^[p.X, p.Y+i].rodzaj='wieza') or (B^[p.X, p.Y+i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x,p.y+i);
		end;
                Break;
             end;
         end;

      end;

      //sprawdzamy w gore od pola
         for i:=1 to 8 do
         begin
            if p.X-i<1 then Break;

            if B^[p.X-i, p.Y]<> nil then
            begin
                if B^[p.X-i, p.Y].kolor = KolorPola then begin Break; end else
                begin
                   if (B^[p.X-i, p.Y].rodzaj='wieza') or (B^[p.X-i, p.Y].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-i,p.y);
		end;
                   Break;
                end;
            end;

         end;

         //sprawdzamy w dol od pola
            for i:=1 to 8 do
            begin
               if p.X+i>8 then Break;

               if B^[p.X+i, p.Y]<> nil then
               begin
                   if B^[p.X+i, p.Y].kolor = KolorPola then begin Break; end else
                   begin
                      if (B^[p.X+i, p.Y].rodzaj='wieza') or (B^[p.X+i, p.Y].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+i,p.y);
		end;
                      Break;
                   end;
               end;

            end;

         //sprawdzamy na lewo w gore od pola
            for i:=1 to 8 do
            begin
               if (p.X-i<1) or (p.Y-i<1) then Break;

               if B^[p.X-i, p.Y-i]<> nil then
               begin
                   if B^[p.X-i, p.Y-i].kolor = KolorPola then begin Break; end else
                   begin
                      if (B^[p.X-i, p.Y-i].rodzaj='goniec') or (B^[p.X-i, p.Y-i].rodzaj='hetman') then
                      begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-i,p.y-i);
		end;
                      Break;
                   end;
               end;

            end;

            //sprawdzamy na prawo w gore od pola
               for i:=1 to 8 do
               begin
                  if (p.X-i<1) or (p.Y+i>8) then Break;

                  if B^[p.X-i, p.Y+i]<> nil then
                  begin
                      if B^[p.X-i, p.Y+i].kolor = KolorPola then begin Break; end else
                      begin
                         if (B^[p.X-i, p.Y+i].rodzaj='goniec') or (B^[p.X-i, p.Y+i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-i,p.y+i);
		end;
                         Break;
                      end;
                  end;

               end;

               //sprawdzamy na prawo w dol od pola
                  for i:=1 to 8 do
                  begin
                     if (p.X+i>8) or (p.Y+i>8) then Break;

                     if B^[p.X+i, p.Y+i]<> nil then
                     begin
                         if B^[p.X+i, p.Y+i].kolor = KolorPola then begin Break; end else
                         begin
                            if (B^[p.X+i, p.Y+i].rodzaj='goniec') or (B^[p.X+i, p.Y+i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+i,p.y+i);
		end;
                            Break;
                         end;
                     end;

                  end;

                  //sprawdzamy na lewo w dol od pola

                  for i:=1 to 8 do
                  begin
                     if (p.X+i>8) or (p.Y-i<1) then Break;

                     if B^[p.X+i, p.Y-i]<> nil then
                     begin
                         if B^[p.X+i, p.Y-i].kolor = KolorPola then begin Break; end else
                         begin
                            if (B^[p.X+i, p.Y-i].rodzaj='goniec') or (B^[p.X+i, p.Y-i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+i,p.y-i);
		end;
                            Break;
                         end;
                     end;

                  end;

//sprawdzamy piony

if Ustawienia.KolorNaDole=KolorPola then
begin
tmpX:=-1;
end
else
begin
tmpX:=1;
end;

if ((p.X+tmpX>=1) and (p.X+tmpX<=8)  and (p.y-1>=1)) then begin
    if B^[p.X+tmpX,p.Y-1]<>nil then
    begin
        if (B^[p.X+tmpX,p.Y-1].rodzaj='pion') and (B^[p.X+tmpX,p.Y-1].kolor<>KolorPola) then
        begin
	SetLength(wynik, Length(wynik)+1);
	wynik[High(wynik)]:=Point(p.x+tmpX,p.y-1);
        end;
    end;
end;

if ((p.X+tmpX>=1) and (p.X+tmpX<=8) and (p.y+1<=8)) then begin
    if B^[p.X+tmpX,p.Y+1]<>nil then
    begin
        if (B^[p.X+tmpX,p.Y+1].rodzaj='pion') and (B^[p.X+tmpX,p.Y+1].kolor<>KolorPola) then
        begin
	SetLength(wynik, Length(wynik)+1);
	wynik[High(wynik)]:=Point(p.x+tmpX,p.y+1);
        end;
    end;
end;



//sprawdzamy konie

   if (p.X-2>=1) and (p.Y+1<=8) then begin
if B^[p.X-2,p.Y+1]<>nil then
begin
    if B^[p.X-2,p.Y+1].kolor<>KolorPola then
    begin
       if B^[p.X-2,p.Y+1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-2,p.y+1);
		end;
    end;
end;  end;

    if (p.X-1>=1) and (p.Y+2<=8) then begin
 if B^[p.X-1,p.Y+2]<>nil then
 begin
     if B^[p.X-1,p.Y+2].kolor<>KolorPola then
     begin
        if B^[p.X-1,p.Y+2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-1,p.y+2);
		end;
     end;
 end; end;

    if (p.X+1<=8) and (p.Y+2<=8) then begin
 if B^[p.X+1,p.Y+2]<>nil then
 begin
     if B^[p.X+1,p.Y+2].kolor<>KolorPola then
     begin
        if B^[p.X+1,p.Y+2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+1,p.y+2);
		end;
     end;
 end; end;

    if (p.X+2<=8) and (p.Y+1<=8) then begin
 if B^[p.X+2,p.Y+1]<>nil then
 begin
     if B^[p.X+2,p.Y+1].kolor<>KolorPola then
     begin
        if B^[p.X+2,p.Y+1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+2,p.y+1);
		end;
     end;
 end; end;

    if (p.X+2<=8) and (p.Y-1>=1) then begin
 if B^[p.X+2,p.Y-1]<>nil then
 begin
     if B^[p.X+2,p.Y-1].kolor<>KolorPola then
     begin
        if B^[p.X+2,p.Y-1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+2,p.y-1);
		end;
     end;
 end; end;

    if (p.X+1<=8) and (p.Y-2>=1) then begin
 if B^[p.X+1,p.Y-2]<>nil then
 begin
     if B^[p.X+1,p.Y-2].kolor<>KolorPola then
     begin
        if B^[p.X+1,p.Y-2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+1,p.y-2);
		end;
     end;
 end; end;

    if (p.X-1>=1) and (p.Y-2>=1) then begin
 if B^[p.X-1,p.Y-2]<>nil then
 begin
     if B^[p.X-1,p.Y-2].kolor<>KolorPola then
     begin
        if B^[p.X-1,p.Y-2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-1,p.y-2);
		end;
     end;
 end; end;

    if (p.X-2>=1) and (p.Y-1>=1) then begin
 if B^[p.X-2,p.Y-1]<>nil then
 begin
     if B^[p.X-2,p.Y-1].kolor<>KolorPola then
     begin
        if B^[p.X-2,p.Y-1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-2,p.y-1);
		end;
     end;
 end; end;


    //sprawdzamy czy broni atakuje
    if (p.x-1>=1) then begin
    if (B^[p.x-1,p.y]<>nil) then begin
    if (B^[p.x-1,p.y].rodzaj='krol') and (B^[p.x-1,p.y].kolor<>KolorPola) then
begin
    		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-1,p.y);
end;
end;
end;

    if (p.x+1<=8) then begin
    if (B^[p.x+1,p.y]<>nil) then begin
    if (B^[p.x+1,p.y].rodzaj='krol') and (B^[p.x+1,p.y].kolor<>KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x+1,p.y);
    end;
    end;
    end;

    if (p.y-1>=1) then begin
    if (B^[p.x,p.y-1]<>nil) then begin
    if (B^[p.x,p.y-1].rodzaj='krol') and (B^[p.x,p.y-1].kolor<>KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x,p.y-1);
    end;
    end;
    end;

    if (p.y+1<=8) then begin
    if (B^[p.x,p.y+1]<>nil) then begin
    if (B^[p.x,p.y+1].rodzaj='krol') and (B^[p.x,p.y+1].kolor<>KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x,p.y+1);
    end;
    end;
    end;

    if (p.x-1>=1) and (p.y-1>=1) then begin
    if (B^[p.x-1,p.y-1]<>nil) then begin
    if (B^[p.x-1,p.y-1].rodzaj='krol') and (B^[p.x-1,p.y-1].kolor<>KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x-1,p.y-1);
    end;
    end;
    end;

    if (p.x-1>=1) and (p.y+1<=8) then begin
    if (B^[p.x-1,p.y+1]<>nil) then begin
    if (B^[p.x-1,p.y+1].rodzaj='krol') and (B^[p.x-1,p.y+1].kolor<>KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x-1,p.y+1);
    end;
    end;
    end;

    if (p.x+1<=8) and (p.y-1>=1) then begin
    if (B^[p.x+1,p.y-1]<>nil) then begin
    if (B^[p.x+1,p.y-1].rodzaj='krol') and (B^[p.x+1,p.y-1].kolor<>KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x+1,p.y-1);
    end;
    end;
    end;

    if (p.x+1<=8) and (p.y+1<=8) then begin
    if (B^[p.x+1,p.y+1]<>nil) then begin
    if (B^[p.x+1,p.y+1].rodzaj='krol') and (B^[p.x+1,p.y+1].kolor<>KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x+1,p.y+1);
    end;
    end;
    end;


      Result:=wynik;


end;

function TForm3.KtoBroniPole(p:TPoint; kol:string; szachownica:Pointer):TTablicaPunktow;
var
i,j,tmpX:integer;
wynik:array of TPoint;
B:^TBoard;
KolorPola:string;
begin

  SetLength(wynik, 0);

B:=szachownica;

    if B^[p.X,p.Y]=nil then
    begin
      KolorPola:=kol;
    end
    else
    begin
      KolorPola:=B^[p.X,p.Y].kolor;
    end;

//sprawdzamy na lewo od pola
   for i:=1 to 8 do
   begin
      if p.Y-i<1 then Break;

      if B^[p.X, p.Y-i]<> nil then
      begin
          if B^[p.X, p.Y-i].kolor = KolorPola then
          begin
             if (B^[p.X, p.Y-i].rodzaj='wieza') or (B^[p.X, p.Y-i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x,p.y-i);
		end;
          end; Break;
      end;

   end;

   //sprawdzamy na prawo od pola
      for i:=1 to 8 do
      begin
         if p.Y+i>8 then Break;

         if B^[p.X, p.Y+i]<> nil then
         begin
             if B^[p.X, p.Y+i].kolor = KolorPola then
             begin
                if (B^[p.X, p.Y+i].rodzaj='wieza') or (B^[p.X, p.Y+i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x,p.y+i);
		end;
             end; Break;
         end;

      end;

      //sprawdzamy w gore od pola
         for i:=1 to 8 do
         begin
            if p.X-i<1 then Break;

            if B^[p.X-i, p.Y]<> nil then
            begin
                if B^[p.X-i, p.Y].kolor = KolorPola then
                begin
                   if (B^[p.X-i, p.Y].rodzaj='wieza') or (B^[p.X-i, p.Y].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-i,p.y);
		end;
                end;  Break;
            end;

         end;

         //sprawdzamy w dol od pola
            for i:=1 to 8 do
            begin
               if p.X+i>8 then Break;

               if B^[p.X+i, p.Y]<> nil then
               begin
                   if B^[p.X+i, p.Y].kolor = KolorPola then
                   begin
                      if (B^[p.X+i, p.Y].rodzaj='wieza') or (B^[p.X+i, p.Y].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+i,p.y);
		end;
                   end;  Break;
               end;

            end;

         //sprawdzamy na lewo w gore od pola
            for i:=1 to 8 do
            begin
               if (p.X-i<1) or (p.Y-i<1) then Break;

               if B^[p.X-i, p.Y-i]<> nil then
               begin
                   if B^[p.X-i, p.Y-i].kolor = KolorPola then
                   begin
                      if (B^[p.X-i, p.Y-i].rodzaj='goniec') or (B^[p.X-i, p.Y-i].rodzaj='hetman') then
                      begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-i,p.y-i);
		end;
                   end;  Break;
               end;

            end;

            //sprawdzamy na prawo w gore od pola
               for i:=1 to 8 do
               begin
                  if (p.X-i<1) or (p.Y+i>8) then Break;

                  if B^[p.X-i, p.Y+i]<> nil then
                  begin
                      if B^[p.X-i, p.Y+i].kolor = KolorPola then
                      begin
                         if (B^[p.X-i, p.Y+i].rodzaj='goniec') or (B^[p.X-i, p.Y+i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-i,p.y+i);
		end;
                      end; Break;
                  end;

               end;

               //sprawdzamy na prawo w dol od pola
                  for i:=1 to 8 do
                  begin
                     if (p.X+i>8) or (p.Y+i>8) then Break;

                     if B^[p.X+i, p.Y+i]<> nil then
                     begin
                         if B^[p.X+i, p.Y+i].kolor = KolorPola then
                         begin
                            if (B^[p.X+i, p.Y+i].rodzaj='goniec') or (B^[p.X+i, p.Y+i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+i,p.y+i);
		end;
                         end; Break;
                     end;

                  end;

                  //sprawdzamy na lewo w dol od pola

                  for i:=1 to 8 do
                  begin
                     if (p.X+i>8) or (p.Y-i<1) then Break;

                     if B^[p.X+i, p.Y-i]<> nil then
                     begin
                         if B^[p.X+i, p.Y-i].kolor = KolorPola then
                         begin
                            if (B^[p.X+i, p.Y-i].rodzaj='goniec') or (B^[p.X+i, p.Y-i].rodzaj='hetman') then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+i,p.y-i);
		end;
                       end;  Break;
                     end;

                  end;

//sprawdzamy piony

if Ustawienia.KolorNaDole=KolorPola then
begin
tmpX:=1;
end
else
begin
tmpX:=-1;
end;

if ((p.X+tmpX>=1) and (p.X+tmpX<=8)  and (p.y-1>=1)) then begin
    if B^[p.X+tmpX,p.Y-1]<>nil then
    begin
        if (B^[p.X+tmpX,p.Y-1].rodzaj='pion') and (B^[p.X+tmpX,p.Y-1].kolor=KolorPola) then
        begin
	SetLength(wynik, Length(wynik)+1);
	wynik[High(wynik)]:=Point(p.x+tmpX,p.y-1);
        end;
    end;
end;

if ((p.X+tmpX>=1) and (p.X+tmpX<=8) and (p.y+1<=8)) then begin
    if B^[p.X+tmpX,p.Y+1]<>nil then
    begin
        if (B^[p.X+tmpX,p.Y+1].rodzaj='pion') and (B^[p.X+tmpX,p.Y+1].kolor=KolorPola) then
        begin
	SetLength(wynik, Length(wynik)+1);
	wynik[High(wynik)]:=Point(p.x+tmpX,p.y+1);
        end;
    end;
end;



//sprawdzamy konie

   if (p.X-2>=1) and (p.Y+1<=8) then begin
if B^[p.X-2,p.Y+1]<>nil then
begin
    if B^[p.X-2,p.Y+1].kolor=KolorPola then
    begin
       if B^[p.X-2,p.Y+1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-2,p.y+1);
		end;
    end;
end;  end;

    if (p.X-1>=1) and (p.Y+2<=8) then begin
 if B^[p.X-1,p.Y+2]<>nil then
 begin
     if B^[p.X-1,p.Y+2].kolor=KolorPola then
     begin
        if B^[p.X-1,p.Y+2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-1,p.y+2);
		end;
     end;
 end; end;

    if (p.X+1<=8) and (p.Y+2<=8) then begin
 if B^[p.X+1,p.Y+2]<>nil then
 begin
     if B^[p.X+1,p.Y+2].kolor=KolorPola then
     begin
        if B^[p.X+1,p.Y+2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+1,p.y+2);
		end;
     end;
 end; end;

    if (p.X+2<=8) and (p.Y+1<=8) then begin
 if B^[p.X+2,p.Y+1]<>nil then
 begin
     if B^[p.X+2,p.Y+1].kolor=KolorPola then
     begin
        if B^[p.X+2,p.Y+1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+2,p.y+1);
		end;
     end;
 end; end;

    if (p.X+2<=8) and (p.Y-1>=1) then begin
 if B^[p.X+2,p.Y-1]<>nil then
 begin
     if B^[p.X+2,p.Y-1].kolor=KolorPola then
     begin
        if B^[p.X+2,p.Y-1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+2,p.y-1);
		end;
     end;
 end; end;

    if (p.X+1<=8) and (p.Y-2>=1) then begin
 if B^[p.X+1,p.Y-2]<>nil then
 begin
     if B^[p.X+1,p.Y-2].kolor=KolorPola then
     begin
        if B^[p.X+1,p.Y-2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x+1,p.y-2);
		end;
     end;
 end; end;

    if (p.X-1>=1) and (p.Y-2>=1) then begin
 if B^[p.X-1,p.Y-2]<>nil then
 begin
     if B^[p.X-1,p.Y-2].kolor=KolorPola then
     begin
        if B^[p.X-1,p.Y-2].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-1,p.y-2);
		end;
     end;
 end; end;

    if (p.X-2>=1) and (p.Y-1>=1) then begin
 if B^[p.X-2,p.Y-1]<>nil then
 begin
     if B^[p.X-2,p.Y-1].kolor=KolorPola then
     begin
        if B^[p.X-2,p.Y-1].rodzaj='skoczek' then begin
		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-2,p.y-1);
		end;
     end;
 end; end;


    //sprawdzamy czy broni krol
    if (p.x-1>=1) then begin
    if (B^[p.x-1,p.y]<>nil) then begin
    if (B^[p.x-1,p.y].rodzaj='krol') and (B^[p.x-1,p.y].kolor=KolorPola) then
begin
    		SetLength(wynik, Length(wynik)+1);
		wynik[High(wynik)]:=Point(p.x-1,p.y);
end;
end;
end;

    if (p.x+1<=8) then begin
    if (B^[p.x+1,p.y]<>nil) then begin
    if (B^[p.x+1,p.y].rodzaj='krol') and (B^[p.x+1,p.y].kolor=KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x+1,p.y);
    end;
    end;
    end;

    if (p.y-1>=1) then begin
    if (B^[p.x,p.y-1]<>nil) then begin
    if (B^[p.x,p.y-1].rodzaj='krol') and (B^[p.x,p.y-1].kolor=KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x,p.y-1);
    end;
    end;
    end;

    if (p.y+1<=8) then begin
    if (B^[p.x,p.y+1]<>nil) then begin
    if (B^[p.x,p.y+1].rodzaj='krol') and (B^[p.x,p.y+1].kolor=KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x,p.y+1);
    end;
    end;
    end;

    if (p.x-1>=1) and (p.y-1>=1) then begin
    if (B^[p.x-1,p.y-1]<>nil) then begin
    if (B^[p.x-1,p.y-1].rodzaj='krol') and (B^[p.x-1,p.y-1].kolor=KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x-1,p.y-1);
    end;
    end;
    end;

    if (p.x-1>=1) and (p.y+1<=8) then begin
    if (B^[p.x-1,p.y+1]<>nil) then begin
    if (B^[p.x-1,p.y+1].rodzaj='krol') and (B^[p.x-1,p.y+1].kolor=KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x-1,p.y+1);
    end;
    end;
    end;

    if (p.x+1<=8) and (p.y-1>=1) then begin
    if (B^[p.x+1,p.y-1]<>nil) then begin
    if (B^[p.x+1,p.y-1].rodzaj='krol') and (B^[p.x+1,p.y-1].kolor=KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x+1,p.y-1);
    end;
    end;
    end;

    if (p.x+1<=8) and (p.y+1<=8) then begin
    if (B^[p.x+1,p.y+1]<>nil) then begin
    if (B^[p.x+1,p.y+1].rodzaj='krol') and (B^[p.x+1,p.y+1].kolor=KolorPola) then
    begin
        		SetLength(wynik, Length(wynik)+1);
    		wynik[High(wynik)]:=Point(p.x+1,p.y+1);
    end;
    end;
    end;


      Result:=wynik;


end;

{ ---- do matowania ---- }

function TForm3.CzyCosStanieNaPolu(pozycja,kolor:string;szachownica:Pointer):boolean;
var
p,PozycjaKrola:TPoint;
i,j,tmpX:integer;
wynik:boolean;
B:^TBoard;
tmpBoard:TBoard;
tmpBierka:TBierka;
begin
wynik:=false;
p:=ZnajdzIJbyPole(pozycja);

B:=szachownica;

//szukamy pozycji krola na szachownicy
for i:=1 to 8 do
for j:=1 to 8 do
  if B^[i,j]<>nil then begin if (B^[i,j].rodzaj='krol') and (B^[i,j].kolor=kolor) then PozycjaKrola:=Point(i,j); end;

//sprawdzamy na lewo od pola
   for i:=1 to 8 do
   begin
      if p.Y-i<1 then Break;

      if B^[p.X, p.Y-i]<> nil then
      begin
          if B^[p.X, p.Y-i].kolor = kolor then begin
             if (B^[p.X, p.Y-i].rodzaj='wieza') or (B^[p.X, p.Y-i].rodzaj='hetman') then
             begin
                  tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X, p.Y-i];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X, p.Y-i]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
             end;
             Break;
      end;
     end;
   end;

   //sprawdzamy na prawo od pola
      for i:=1 to 8 do
      begin
         if p.Y+i>8 then Break;

         if B^[p.X, p.Y+i]<> nil then
         begin
             if B^[p.X, p.Y+i].kolor = kolor then begin
                if (B^[p.X, p.Y+i].rodzaj='wieza') or (B^[p.X, p.Y+i].rodzaj='hetman') then
                             begin
                  tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X, p.Y+i];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X, p.Y+i]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
             end;
                Break;
         end;
       end;
      end;

      //sprawdzamy w gore od pola
         for i:=1 to 8 do
         begin
            if p.X-i<1 then Break;

            if B^[p.X-i, p.Y]<> nil then
            begin
                if B^[p.X-i, p.Y].kolor = kolor then begin
                   if (B^[p.X-i, p.Y].rodzaj='wieza') or (B^[p.X-i, p.Y].rodzaj='hetman') then
                                begin
                  tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X-i, p.Y];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X-i, p.Y]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
             end;
                   Break;
            end;
           end;
         end;

         //sprawdzamy w dol od pola
            for i:=1 to 8 do
            begin
               if p.X+i>8 then Break;

               if B^[p.X+i, p.Y]<> nil then
               begin
                   if B^[p.X+i, p.Y].kolor = kolor then begin
                      if (B^[p.X+i, p.Y].rodzaj='wieza') or (B^[p.X+i, p.Y].rodzaj='hetman') then
                                   begin
                  tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+i, p.Y];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+i, p.Y]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
             end;
                      Break;
               end;
            end;
            end;

         //sprawdzamy na lewo w gore od pola
            for i:=1 to 8 do
            begin
               if (p.X-i<1) or (p.Y-i<1) then Break;

               if B^[p.X-i, p.Y-i]<> nil then
               begin
                   if B^[p.X-i, p.Y-i].kolor = kolor then begin
                      if (B^[p.X-i, p.Y-i].rodzaj='goniec') or (B^[p.X-i, p.Y-i].rodzaj='hetman') then
                      begin
                                        tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X-i, p.Y-i];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X-i, p.Y-i]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
                      end;
                      Break;
               end;
               end;
            end;

            //sprawdzamy na prawo w gore od pola
               for i:=1 to 8 do
               begin
                  if (p.X-i<1) or (p.Y+i>8) then Break;

                  if B^[p.X-i, p.Y+i]<> nil then
                  begin
                      if B^[p.X-i, p.Y+i].kolor = kolor then begin
                         if (B^[p.X-i, p.Y+i].rodzaj='goniec') or (B^[p.X-i, p.Y+i].rodzaj='hetman') then
                         begin
                                           tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X-i, p.Y+i];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X-i, p.Y+i]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
                         end;
                         Break;
                  end;
                  end;
               end;

               //sprawdzamy na prawo w dol od pola
                  for i:=1 to 8 do
                  begin
                     if (p.X+i>8) or (p.Y+i>8) then Break;

                     if B^[p.X+i, p.Y+i]<> nil then
                     begin
                         if B^[p.X+i, p.Y+i].kolor = kolor then begin
                            if (B^[p.X+i, p.Y+i].rodzaj='goniec') or (B^[p.X+i, p.Y+i].rodzaj='hetman') then
                            begin
                                              tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+i, p.Y+i];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+i, p.Y+i]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
                            end;
                            Break;
                     end;
                    end;
                  end;

                  //sprawdzamy na lewo w dol od pola

                  for i:=1 to 8 do
                  begin
                     if (p.X+i>8) or (p.Y-i<1) then Break;

                     if B^[p.X+i, p.Y-i]<> nil then
                     begin
                         if B^[p.X+i, p.Y-i].kolor = kolor then begin
                            if (B^[p.X+i, p.Y-i].rodzaj='goniec') or (B^[p.X+i, p.Y-i].rodzaj='hetman') then
                            begin
                                              tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+i, p.Y-i];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+i, p.Y-i]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
                            end;
                            Break;
                         end;
                  end;
                      end;

//sprawdzamy piony

    if Ustawienia.KolorNaDole=Kolor then
    begin
    tmpX:=1;
    end
    else
    begin
    tmpX:=-1;
    end;


if ((p.X+tmpX<=8) and (p.X+tmpX>=1)) then
begin
   if B^[p.X+tmpX, p.Y]<>nil then begin
     if B^[p.X+tmpX, p.Y].kolor=kolor then
     begin
        if B^[p.x+tmpX, p.Y].rodzaj='pion' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+tmpX, p.Y];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+tmpX, p.Y]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
   end;
end;


//sprawdzamy konie

   if (p.X-2>=1) and (p.Y+1<=8) then begin
if B^[p.X-2,p.Y+1]<>nil then
begin
    if B^[p.X-2,p.Y+1].kolor=kolor then
    begin
       if B^[p.X-2,p.Y+1].rodzaj='skoczek' then begin
                         tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X-2, p.Y+1];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X-2, p.Y+1]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
       end;
    end;
end;  end;

    if (p.X-1>=1) and (p.Y+2<=8) then begin
 if B^[p.X-1,p.Y+2]<>nil then
 begin
     if B^[p.X-1,p.Y+2].kolor=kolor then
     begin
        if B^[p.X-1,p.Y+2].rodzaj='skoczek' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X-1, p.Y+2];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X-1, p.Y+2]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
 end; end;

    if (p.X+1<=8) and (p.Y+2<=8) then begin
 if B^[p.X+1,p.Y+2]<>nil then
 begin
     if B^[p.X+1,p.Y+2].kolor=kolor then
     begin
        if B^[p.X+1,p.Y+2].rodzaj='skoczek' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+1, p.Y+2];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+1, p.Y+2]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
 end; end;

    if (p.X+2<=8) and (p.Y+1<=8) then begin
 if B^[p.X+2,p.Y+1]<>nil then
 begin
     if B^[p.X+2,p.Y+1].kolor=kolor then
     begin
        if B^[p.X+2,p.Y+1].rodzaj='skoczek' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+2, p.Y+1];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+2, p.Y+1]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
 end; end;

    if (p.X+2<=8) and (p.Y-1>=1) then begin
 if B^[p.X+2,p.Y-1]<>nil then
 begin
     if B^[p.X+2,p.Y-1].kolor=kolor then
     begin
        if B^[p.X+2,p.Y-1].rodzaj='skoczek' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+2, p.Y-1];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+2, p.Y-1]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
 end; end;

    if (p.X+1<=8) and (p.Y-2>=1) then begin
 if B^[p.X+1,p.Y-2]<>nil then
 begin
     if B^[p.X+1,p.Y-2].kolor=kolor then
     begin
        if B^[p.X+1,p.Y-2].rodzaj='skoczek' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X+1, p.Y-2];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X+1, p.Y-2]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
 end; end;

    if (p.X-1>=1) and (p.Y-2>=1) then begin
 if B^[p.X-1,p.Y-2]<>nil then
 begin
     if B^[p.X-1,p.Y-2].kolor=kolor then
     begin
        if B^[p.X-1,p.Y-2].rodzaj='skoczek' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X-1, p.Y-2];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X-1, p.Y-2]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
 end; end;

    if (p.X-2>=1) and (p.Y-1>=1) then begin
 if B^[p.X-2,p.Y-1]<>nil then
 begin
     if B^[p.X-2,p.Y-1].kolor=kolor then
     begin
        if B^[p.X-2,p.Y-1].rodzaj='skoczek' then begin
                          tmpBoard:=B^;
                  tmpBierka:=tmpBoard[p.X-2, p.Y-1];
                  tmpBoard[p.X,p.Y]:=tmpBierka;
                  tmpBoard[p.X-2, p.Y-1]:=nil; //sprawdzamy czy po zaslonieciu krola nie odslaniamy innego ataku
                      if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                      Exit (True);
        end;
     end;
 end; end;



      Result:=wynik; //jezeli false to nie stanie nic

end;

function TForm3.CzyMoznaZaslonic(atakowany,atakujacy:TPoint):boolean;
var
i,j:integer;
CzyMozna,tmp:boolean;
a,b:TPoint;
begin
CzyMozna:=false;

if (atakowany.X-atakujacy.X<0) and (atakowany.Y-atakujacy.Y<0) then //atak po skosie z dolu z prawej
begin
  //  tmp:=false;
    for i:=1 to atakujacy.X-atakowany.X do
    begin
         if (atakowany.X+i=atakujacy.X) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X+i,atakowany.Y+i].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;

if (atakowany.X-atakujacy.X<0) and (atakowany.Y-atakujacy.Y>0) then //atak po skosie z dolu z lewej
begin
  //  tmp:=false;
    for i:=1 to atakujacy.X-atakowany.X do
    begin
         if (atakowany.X+i=atakujacy.X) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X+i,atakowany.Y-i].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;

if (atakowany.X-atakujacy.X>0) and (atakowany.Y-atakujacy.Y>0) then //atak po skosie z gory z lewej
begin
 //   tmp:=false;
    for i:=1 to atakowany.X-atakujacy.X do
    begin
         if (atakujacy.X+i=atakowany.X) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X-i,atakowany.Y-i].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;

if (atakowany.X-atakujacy.X>0) and (atakowany.Y-atakujacy.Y<0) then //atak po skosie z gory z prawej
begin
 //   tmp:=false;
    for i:=1 to atakowany.X-atakujacy.X do
    begin
         if (atakujacy.X+i=atakowany.X) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X-i,atakowany.Y+i].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;

if (atakowany.X-atakujacy.X>0) and (atakowany.Y-atakujacy.Y=0) then //atak z gory
begin
 //   tmp:=false;
    for i:=1 to atakowany.X-atakujacy.X do
    begin
         if (atakujacy.X+i=atakowany.X) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X-i,atakowany.Y].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;

if (atakowany.X-atakujacy.X<0) and (atakowany.Y-atakujacy.Y=0) then //atak z dolu
begin
 //   tmp:=false;
    for i:=1 to atakujacy.X-atakowany.X do
    begin
         if (atakowany.X+i=atakujacy.X) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X+i,atakowany.Y].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;

if (atakowany.X-atakujacy.X=0) and (atakowany.Y-atakujacy.Y>0) then //atak z lewej
begin
  //  tmp:=false;
   j:=atakowany.Y-atakujacy.Y;

    for i:=1 to j do
    begin
         if (atakujacy.Y+i=atakowany.Y) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X,atakowany.Y-i].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;

if (atakowany.X-atakujacy.X=0) and (atakowany.Y-atakujacy.Y<0) then //atak z prawej
begin
 //   tmp:=false;
    for i:=1 to atakujacy.Y-atakowany.Y do
    begin
         if (atakowany.Y+i=atakujacy.Y) then Break;
         if (CzyCosStanieNaPolu(DaneBoard[atakowany.X,atakowany.Y+i].pole, Board[atakowany.X,atakowany.Y].kolor,@Board)=true) then
         Exit (true);
    end;
 //   if tmp=false then Exit (false);
end;



    Result:=CzyMozna;
end;

{------}

function TForm3.CzySieRuszal(polozenie:TPoint):boolean;
var
RuszalSie:boolean;
rodzaj,kolor:string;
i:integer;
begin
rodzaj:=Board[polozenie.X,polozenie.Y].rodzaj;
kolor:=Board[polozenie.X,polozenie.Y].kolor;

RuszalSie:=false;
for i:=0 to Length(PrzebiegPartii)-1 do
begin
   if (PrzebiegPartii[i].figura=rodzaj) and (PrzebiegPartii[i].kolor=kolor) then begin RuszalSie:=true; Break; end;
end;

Result:=RuszalSie;  //jak false to sie nie ruszal

end;

{--- sprawdzanie ruchow ---}


function TForm3.MozliweRuchy(WyjsciowePole:string):TMapaRuchow;
var
ruchy:TMapaRuchow;
pole:TPoint;
i,j,tmpX:integer;
kolor,bierka:string;
tmp,tmp2,tmp3,PozycjaKrola:TPoint;
tmpBoard:TBoard;
begin

pole:=ZnajdzIJbyPole(WyjsciowePole);
kolor:=Board[pole.X, pole.Y].kolor;
bierka:=Board[pole.X, pole.Y].rodzaj;

for i:=1 to 8 do
for j:=1 to 8 do
  if Board[i,j]<>nil then begin if (Board[i,j].rodzaj='krol') and (Board[i,j].kolor=kolor) then PozycjaKrola:=Point(i,j); end;


{SPRAWDZAMY MOZLIWE RUCHY DLA WIEZY}

if bierka = 'wieza' then
 begin

      for i:=1 to 8 do {na prawo do bierki}
         begin

               if pole.Y+i<=8 then
                begin
                     if Board[pole.X, pole.Y+i]=nil then
                      begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X,pole.y+i]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y+i].pole;
                           end;
                      end
                     else
                     begin
                           if Board[pole.X, pole.Y+i].kolor = kolor then begin Break; end
                           else
                            begin
                            tmpBoard:=Board;
                            tmpBoard[pole.X,pole.y+i]:=tmpBoard[pole.X,pole.Y];
                            tmpBoard[pole.X,pole.Y]:=nil;
                            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                             begin
                            SetLength(ruchy, Length(ruchy)+1);
                            ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y+i].pole;
                            end;
                              Break;
                            end;
                     end;
                end;
         end;

      for i:=1 to 8 do {na lewo do bierki}
         begin


               if pole.Y-i>=1 then
                begin
                     if Board[pole.X, pole.Y-i]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X,pole.y-i]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y-i].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X, pole.Y-i].kolor = kolor then begin Break; end
                           else
                           begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X,pole.y-i]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y-i].pole;
                           end;
                              Break;
                            end;
                     end;
                end;
         end;

      for i:=1 to 8 do {do gory bierki}
         begin


               if pole.X+i<=8 then
                begin
                     if Board[pole.X+i, pole.Y]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X+i,pole.y]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X+i, pole.Y].kolor = kolor then begin Break; end
                           else
                           begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X+i,pole.y]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y].pole;
                           end;
                              Break;
                            end;
                     end;
                end;
         end;

      for i:=1 to 8 do {w dol bierki}
         begin

               if pole.X-i>=1 then
                begin
                     if Board[pole.X-i, pole.Y]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X-i,pole.y]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X-i, pole.Y].kolor = kolor then begin Break; end
                           else
                           begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X-i,pole.y]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y].pole;
                           end;
                              Break;
                            end;
                     end;
                end;
         end;

      Result:=ruchy;

 end;

{SPRAWDZAMY MOZLIWE RUCHY DLA PIONA}

if bierka = 'pion' then
 begin
      {sprawdzamy ruch piona}

    if Ustawienia.KolorNaDole=Kolor then
    begin
    tmpX:=-1;
    end
    else
    begin
    tmpX:=1;
    end;


            if Board[pole.X+tmpX, pole.Y]=nil then
            begin

                tmpBoard:=Board;
                tmpBoard[pole.X+tmpX,pole.y]:=tmpBoard[pole.X,pole.Y];
                tmpBoard[pole.X,pole.Y]:=nil;
                if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                 begin
                SetLength(ruchy, Length(ruchy)+1);
                ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX, pole.Y].pole;
                end;
            end;

            if (pole.X=7) or (pole.X=2) then  //pierwszy ruch, mozna o dwa, sprawdzamy
            begin

                       if Board[pole.X+tmpX+tmpX, pole.Y]=nil then
                       begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X+tmpX+tmpX,pole.y]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX+tmpX, pole.Y].pole;
                           end;
                       end;

            end;

       {sprawdzamy bicie piona}
            if (pole.X+tmpX>=1) and (pole.Y-1>=1) then    //bicie w lewo
            begin
                if Board[pole.X+tmpX, pole.Y-1]<>nil then
                begin
                    if Board[pole.X+tmpX, pole.Y-1].kolor<>kolor then
                    begin
                        tmpBoard:=Board;
                        tmpBoard[pole.X+tmpX,pole.y-1]:=tmpBoard[pole.X,pole.Y];
                        tmpBoard[pole.X,pole.Y]:=nil;
                        if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                         begin
                        SetLength(ruchy, Length(ruchy)+1);
                        ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX, pole.Y-1].pole;
                        end;
                    end;
                end;

            end;


     if (pole.X+tmpX>=1) and (pole.Y+1<=8) then    //bicie w prawo
     begin
         if Board[pole.X+tmpX, pole.Y+1]<>nil then
         begin
             if Board[pole.X+tmpX, pole.Y+1].kolor<>kolor then
             begin
                 tmpBoard:=Board;
                 tmpBoard[pole.X+tmpX,pole.y+1]:=tmpBoard[pole.X,pole.Y];
                 tmpBoard[pole.X,pole.Y]:=nil;
                 if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                  begin
                 SetLength(ruchy, Length(ruchy)+1);
                 ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX, pole.Y+1].pole;
                 end;
             end;
         end;

     end;

     {sprawdzamy bicie w przelocie}
     MozliweWPrzelocie.ok:=false;

  if Ustawienia.KogoRuch=Ustawienia.KolorNaDole then  //jezeli ruch z dolu
  begin

       if pole.X=4 then  //jezeli pionek na pozycji do przelotu
       begin
             if (pole.Y-1)>=1 then
             begin
                   if (Board[pole.X, pole.Y-1]<>nil) then
                   begin
                        if (Board[pole.X, pole.Y-1].rodzaj='pion') and (Board[pole.X, pole.Y-1].kolor<>Ustawienia.KogoRuch) then
                        begin
                           //jezeli po lewej stoi pion przeciwnika to sprawdzamy czy zrobil ruch o dwa
                             if (PrzebiegPartii[High(PrzebiegPartii)].Z=DaneBoard[pole.X+tmpX+tmpX, pole.Y-1].pole) and
                                (PrzebiegPartii[High(PrzebiegPartii)].NA=DaneBoard[pole.X, pole.Y-1].pole) and
                                (PrzebiegPartii[High(PrzebiegPartii)].figura='pion') then
                                begin
                                  tmpBoard:=Board;
                                  tmp:=pole;
                                  tmp2:=Point(pole.X+tmpX, pole.Y-1);
                                  tmp3:=Point(pole.X, Pole.Y-1);
                                  tmpBoard[tmp2.X-1,tmp2.y+1]:=tmpBoard[tmp.X,tmp.Y];
                                  tmpBoard[tmp.X,tmp.Y]:=nil;
                                  tmpBoard[tmp3.x,tmp3.y]:=nil;
                                  if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                                   begin
                                   SetLength(ruchy, Length(ruchy)+1);
                                   ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX, pole.Y-1].pole;
                                   MozliweWPrzelocie.ok:=true;
                                   MozliweWPrzelocie.bite:=DaneBoard[pole.X, pole.Y-1].pole;
                                   MozliweWPrzelocie.Z:=DaneBoard[Pole.X, Pole.Y].pole;
                                   MozliweWPrzelocie.Na:=DaneBoard[pole.X+tmpX, pole.Y-1].pole;
                                   end;

                                end;

                        end;
                   end;
             end;

             {--}

                          if (pole.Y+1)<=8 then
             begin
                   if (Board[pole.X, pole.Y+1]<>nil) then
                   begin
                        if (Board[pole.X, pole.Y+1].rodzaj='pion') and (Board[pole.X, pole.Y+1].kolor<>Ustawienia.KogoRuch) then
                        begin
                           //jezeli po lewej stoi pion przeciwnika to sprawdzamy czy zrobil ruch o dwa
                             if (PrzebiegPartii[High(PrzebiegPartii)].Z=DaneBoard[pole.X+tmpX+tmpX, pole.Y+1].pole) and
                                (PrzebiegPartii[High(PrzebiegPartii)].NA=DaneBoard[pole.X, pole.Y+1].pole) and
                                (PrzebiegPartii[High(PrzebiegPartii)].figura='pion') then
                                begin
                                  tmpBoard:=Board;
                                  tmp:=pole;
                                  tmp2:=Point(pole.X+tmpX, pole.Y+1);
                                  tmp3:=Point(pole.X, Pole.Y+1);
                                  tmpBoard[tmp2.X-1,tmp2.y+1]:=tmpBoard[tmp.X,tmp.Y];
                                  tmpBoard[tmp.X,tmp.Y]:=nil;
                                  tmpBoard[tmp3.x,tmp3.y]:=nil;
                                  if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                                   begin
                                   SetLength(ruchy, Length(ruchy)+1);
                                   ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX, pole.Y+1].pole;
                                   MozliweWPrzelocie.ok:=true;
                                   MozliweWPrzelocie.bite:=DaneBoard[pole.X, pole.Y+1].pole;
                                   MozliweWPrzelocie.Z:=DaneBoard[Pole.X, Pole.Y].pole;
                                   MozliweWPrzelocie.Na:=DaneBoard[pole.X+tmpX, pole.Y+1].pole;
                                   end;

                                end;

                        end;
                   end;
             end;

             {--}

       end;

  end
  else
  begin  //jezeli ruch z gory

  if pole.X=5 then  //jezeli pionek na pozycji do przelotu
  begin
        if (pole.Y-1)>=1 then
        begin
              if (Board[pole.X, pole.Y-1]<>nil) then
              begin
                   if (Board[pole.X, pole.Y-1].rodzaj='pion') and (Board[pole.X, pole.Y-1].kolor<>Ustawienia.KogoRuch) then
                   begin
                      //jezeli po lewej stoi pion przeciwnika to sprawdzamy czy zrobil ruch o dwa
                        if (PrzebiegPartii[High(PrzebiegPartii)].Z=DaneBoard[pole.X+tmpX+tmpX, pole.Y-1].pole) and
                           (PrzebiegPartii[High(PrzebiegPartii)].NA=DaneBoard[pole.X, pole.Y-1].pole) and
                           (PrzebiegPartii[High(PrzebiegPartii)].figura='pion') then
                           begin
                             tmpBoard:=Board;
                             tmp:=pole;
                             tmp2:=Point(pole.X+tmpX, pole.Y-1);
                             tmp3:=Point(pole.X, Pole.Y-1);
                             tmpBoard[tmp2.X+1,tmp2.y+1]:=tmpBoard[tmp.X,tmp.Y];
                             tmpBoard[tmp.X,tmp.Y]:=nil;
                             tmpBoard[tmp3.x,tmp3.y]:=nil;
                             if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                              begin
                              SetLength(ruchy, Length(ruchy)+1);
                              ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX, pole.Y-1].pole;
                              MozliweWPrzelocie.ok:=true;
                              MozliweWPrzelocie.bite:=DaneBoard[pole.X, pole.Y-1].pole;
                              MozliweWPrzelocie.Z:=DaneBoard[Pole.X, Pole.Y].pole;
                              MozliweWPrzelocie.Na:=DaneBoard[pole.X+tmpX, pole.Y-1].pole;
                              end;

                           end;

                   end;
              end;
        end;

        {--}

                     if (pole.Y+1)<=8 then
        begin
              if (Board[pole.X, pole.Y+1]<>nil) then
              begin
                   if (Board[pole.X, pole.Y+1].rodzaj='pion') and (Board[pole.X, pole.Y+1].kolor<>Ustawienia.KogoRuch) then
                   begin
                      //jezeli po lewej stoi pion przeciwnika to sprawdzamy czy zrobil ruch o dwa
                        if (PrzebiegPartii[High(PrzebiegPartii)].Z=DaneBoard[pole.X+tmpX+tmpX, pole.Y+1].pole) and
                           (PrzebiegPartii[High(PrzebiegPartii)].NA=DaneBoard[pole.X, pole.Y+1].pole) and
                           (PrzebiegPartii[High(PrzebiegPartii)].figura='pion') then
                           begin
                             tmpBoard:=Board;
                             tmp:=pole;
                             tmp2:=Point(pole.X+tmpX, pole.Y+1);
                             tmp3:=Point(pole.X, Pole.Y+1);
                             tmpBoard[tmp2.X+1,tmp2.y+1]:=tmpBoard[tmp.X,tmp.Y];
                             tmpBoard[tmp.X,tmp.Y]:=nil;
                             tmpBoard[tmp3.x,tmp3.y]:=nil;
                             if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '', @tmpBoard))=0 then
                              begin
                              SetLength(ruchy, Length(ruchy)+1);
                              ruchy[High(ruchy)]:=DaneBoard[pole.X+tmpX, pole.Y+1].pole;
                              MozliweWPrzelocie.ok:=true;
                              MozliweWPrzelocie.bite:=DaneBoard[pole.X, pole.Y+1].pole;
                              MozliweWPrzelocie.Z:=DaneBoard[Pole.X, Pole.Y].pole;
                              MozliweWPrzelocie.Na:=DaneBoard[pole.X+tmpX, pole.Y+1].pole;
                              end;

                           end;

                   end;
              end;
        end;

        {--}

  end;


  end;




     {----}


     result:=ruchy;
  end;


{SPRAWDZAMY MOZLIWE RUCHY DLA GONCA}

if bierka = 'goniec' then
begin

   for i:=1 to 8 do    {w lewy gorny rog}
   begin
      if ((pole.X-i)<1) or ((pole.Y-i)<1) then Break;

      if Board[pole.X-i, pole.Y-i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X-i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y-i].pole;
          end;
      end
      else
      begin
         if Board[pole.X-i, pole.Y-i].kolor=kolor then begin Break; end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X-i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
              SetLength(ruchy, Length(ruchy)+1);
              ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y-i].pole;
         end;
              Break;
         end;
      end;

   end;

   for i:=1 to 8 do    {w prawy gorny rog}
   begin
      if ((pole.X-i)<1) or ((pole.Y+i)>8) then Break;

      if Board[pole.X-i, pole.Y+i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X-i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y+i].pole;
          end;
      end
      else
      begin
         if Board[pole.X-i, pole.Y+i].kolor=kolor then begin Break; end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X-i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
         SetLength(ruchy, Length(ruchy)+1);
         ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y+i].pole;
         end;
              Break;
         end;
      end;

   end;

   for i:=1 to 8 do    {w lewy dolny rog}
   begin
      if ((pole.X+i)>8) or ((pole.Y-i)<1) then Break;

      if Board[pole.X+i, pole.Y-i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X+i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y-i].pole;
          end;
      end
      else
      begin
         if Board[pole.X+i, pole.Y-i].kolor=kolor then begin Break end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X+i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
         SetLength(ruchy, Length(ruchy)+1);
         ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y-i].pole;
         end;
              Break;
         end;
      end;

   end;

   for i:=1 to 8 do    {w prawy dolny rog}
   begin
      if ((pole.X+i)>8) or ((pole.Y+i)>8) then Break;

      if Board[pole.X+i, pole.Y+i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X+i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y+i].pole;
          end;
      end
      else
      begin
         if Board[pole.X+i, pole.Y+i].kolor=kolor then begin Break end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X+i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
         SetLength(ruchy, Length(ruchy)+1);
         ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y+i].pole;
         end;
              Break;
         end;
      end;

   end;

   result:=ruchy;

end;

{SPRAWDZAMY MOZLIWE RUCHY DLA SKOCZKA}

if bierka = 'skoczek' then
begin

    if ((pole.X+1<=8) and (pole.Y+2<=8)) then
    begin
        if Board[pole.X+1, pole.Y+2]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X+1,pole.y+2]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y+2].pole;
            end;
        end
        else
        begin
           if Board[pole.X+1, pole.Y+2].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X+1,pole.y+2]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y+2].pole;
               end;
           end;
        end;
    end;


    if ((pole.X-1>=1) and (pole.Y-2>=1)) then
    begin
        if Board[pole.X-1, pole.Y-2]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X-1,pole.y-2]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y-2].pole;
            end;
        end
        else
        begin
           if Board[pole.X-1, pole.Y-2].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X-1,pole.y-2]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y-2].pole;
               end;
           end;
        end;
    end;


    if ((pole.X+2<=8) and (pole.Y+1<=8)) then
    begin
        if Board[pole.X+2, pole.Y+1]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X+2,pole.y+1]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X+2, pole.Y+1].pole;
            end;
        end
        else
        begin
           if Board[pole.X+2, pole.Y+1].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X+2,pole.y+1]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X+2, pole.Y+1].pole;
               end;
           end;
        end;
    end;


    if ((pole.X-2>=1) and (pole.Y+1<=8)) then
    begin
        if Board[pole.X-2, pole.Y+1]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X-2,pole.y+1]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X-2, pole.Y+1].pole;
            end;
        end
        else
        begin
           if Board[pole.X-2, pole.Y+1].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X-2,pole.y+1]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X-2, pole.Y+1].pole;
               end;
           end;
        end;
    end;


    if ((pole.X+1<=8) and (pole.Y-2>=1)) then
    begin
        if Board[pole.X+1, pole.Y-2]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X+1,pole.y-2]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y-2].pole;
            end;
        end
        else
        begin
           if Board[pole.X+1, pole.Y-2].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X+1,pole.y-2]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y-2].pole;
               end;
           end;
        end;
    end;


    if ((pole.X-1>=1) and (pole.Y+2<=8)) then
    begin
        if Board[pole.X-1, pole.Y+2]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X-1,pole.y+2]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y+2].pole;
            end;
        end
        else
        begin
           if Board[pole.X-1, pole.Y+2].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X-1,pole.y+2]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y+2].pole;
               end;
           end;
        end;
    end;


    if ((pole.X+2<=8) and (pole.Y-1>=1)) then
    begin
        if Board[pole.X+2, pole.Y-1]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X+2,pole.y-1]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X+2, pole.Y-1].pole;
            end;
        end
        else
        begin
           if Board[pole.X+2, pole.Y-1].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X+2,pole.y-1]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X+2, pole.Y-1].pole;
               end;
           end;
        end;
    end;


    if ((pole.X-2>=1) and (pole.Y-1>=1))then
    begin
        if Board[pole.X-2, pole.Y-1]=nil then
        begin
            tmpBoard:=Board;
            tmpBoard[pole.X-2,pole.y-1]:=tmpBoard[pole.X,pole.Y];
            tmpBoard[pole.X,pole.Y]:=nil;
            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
             begin
            SetLength(ruchy, Length(ruchy)+1);
            ruchy[High(ruchy)]:=DaneBoard[pole.X-2, pole.Y-1].pole;
            end;
        end
        else
        begin
           if Board[pole.X-2, pole.Y-1].kolor<>kolor then
           begin
               tmpBoard:=Board;
               tmpBoard[pole.X-2,pole.y-1]:=tmpBoard[pole.X,pole.Y];
               tmpBoard[pole.X,pole.Y]:=nil;
               if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                begin
               SetLength(ruchy, Length(ruchy)+1);
               ruchy[High(ruchy)]:=DaneBoard[pole.X-2, pole.Y-1].pole;
               end;
           end;
        end;
    end;

 result:=ruchy;

end;

{SPRAWDZAMY MOZLIWE RUCHY DLA HETMANA}

if bierka = 'hetman' then
begin

 {ruchy gonca - po skosie}

   for i:=1 to 8 do    {w lewy gorny rog}
   begin
      if ((pole.X-i)<1) or ((pole.Y-i)<1) then Break;

      if Board[pole.X-i, pole.Y-i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X-i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y-i].pole;
          end;
      end
      else
      begin
         if Board[pole.X-i, pole.Y-i].kolor=kolor then begin Break; end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X-i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
         SetLength(ruchy, Length(ruchy)+1);
         ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y-i].pole;
         end;
              Break;
         end;
      end;

   end;

   for i:=1 to 8 do    {w prawy gorny rog}
   begin
      if ((pole.X-i)<1) or ((pole.Y+i)>8) then Break;

      if Board[pole.X-i, pole.Y+i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X-i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y+i].pole;
          end;
      end
      else
      begin
         if Board[pole.X-i, pole.Y+i].kolor=kolor then begin Break; end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X-i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
         SetLength(ruchy, Length(ruchy)+1);
         ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y+i].pole;
         end;
              Break;
         end;
      end;

   end;

   for i:=1 to 8 do    {w lewy dolny rog}
   begin
      if ((pole.X+i)>8) or ((pole.Y-i)<1) then Break;

      if Board[pole.X+i, pole.Y-i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X+i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y-i].pole;
          end;
      end
      else
      begin
         if Board[pole.X+i, pole.Y-i].kolor=kolor then begin Break end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X+i,pole.y-i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
         SetLength(ruchy, Length(ruchy)+1);
         ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y-i].pole;
         end;
              Break;
         end;
      end;

   end;

   for i:=1 to 8 do    {w prawy dolny rog}
   begin
      if ((pole.X+i)>8) or ((pole.Y+i)>8) then Break;

      if Board[pole.X+i, pole.Y+i]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X+i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y+i].pole;
          end;
      end
      else
      begin
         if Board[pole.X+i, pole.Y+i].kolor=kolor then begin Break end
         else
         begin
         tmpBoard:=Board;
         tmpBoard[pole.X+i,pole.y+i]:=tmpBoard[pole.X,pole.Y];
         tmpBoard[pole.X,pole.Y]:=nil;
         if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
          begin
         SetLength(ruchy, Length(ruchy)+1);
         ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y+i].pole;
         end;
              Break;
         end;
      end;

      end;

 {-----------------------}

 {-- ruchy wiezy - poziomo pionowo --}

 for i:=1 to 8 do {na prawo do bierki}
         begin

               if pole.Y+i<=8 then
                begin
                     if Board[pole.X, pole.Y+i]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X,pole.y+i]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y+i].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X, pole.Y+i].kolor = kolor then begin Break; end
                           else
                            begin
                            tmpBoard:=Board;
                            tmpBoard[pole.X,pole.y+i]:=tmpBoard[pole.X,pole.Y];
                            tmpBoard[pole.X,pole.Y]:=nil;
                            if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                             begin
                            SetLength(ruchy, Length(ruchy)+1);
                            ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y+i].pole;
                            end;
                              Break;
                            end;
                     end;
                end;
         end;

      for i:=1 to 8 do {na lewo do bierki}
         begin


               if pole.Y-i>=1 then
                begin
                     if Board[pole.X, pole.Y-i]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X,pole.y-i]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y-i].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X, pole.Y-i].kolor = kolor then begin Break; end
                           else
                           begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X,pole.y-i]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y-i].pole;
                           end;
                              Break;
                            end;
                     end;
                end;
         end;

      for i:=1 to 8 do {do gory bierki}
         begin


               if pole.X+i<=8 then
                begin
                     if Board[pole.X+i, pole.Y]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X+i,pole.y]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X+i, pole.Y].kolor = kolor then begin Break; end
                           else
                           begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X+i,pole.y]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X+i, pole.Y].pole;
                           end;
                              Break;
                            end;
                     end;
                end;
         end;

      for i:=1 to 8 do {w dol bierki}
         begin

               if pole.X-i>=1 then
                begin
                     if Board[pole.X-i, pole.Y]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X-i,pole.y]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X-i, pole.Y].kolor = kolor then begin Break; end
                           else
                           begin
                           tmpBoard:=Board;
                           tmpBoard[pole.X-i,pole.y]:=tmpBoard[pole.X,pole.Y];
                           tmpBoard[pole.X,pole.Y]:=nil;
                           if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'',@tmpBoard))=0 then
                            begin
                           SetLength(ruchy, Length(ruchy)+1);
                           ruchy[High(ruchy)]:=DaneBoard[pole.X-i, pole.Y].pole;
                           end;
                              Break;
                            end;
                     end;
                end;
         end;

 {------------------------}

 result:=ruchy;

   end;

{SPRAWDZAMY MOZLIWE RUCHY DLA KROLA}

if bierka = 'krol' then
 begin

  {-- ruchy wiezy - pionowo poziomo --}

               if pole.Y+1<=8 then
                begin
                     if Board[pole.X, pole.Y+1]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X,pole.y+1]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[pole.X,pole.Y+1].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y+1].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X, pole.Y+1].kolor <> kolor then
                            begin
                                tmpBoard:=Board;
                                tmpBoard[pole.X,pole.y+1]:=tmpBoard[pole.X,pole.Y];
                                tmpBoard[pole.X,pole.Y]:=nil;
                                if Length(KtoAtakujePole(DaneBoard[pole.X,pole.Y+1].pole,'',@tmpBoard))=0 then
                                 begin
                                SetLength(ruchy, Length(ruchy)+1);
                                ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y+1].pole;
                                end;
                            end;
                     end;
                end;


               if pole.Y-1>=1 then
                begin
                     if Board[pole.X, pole.Y-1]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X,pole.y-1]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[pole.X,pole.Y-1].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y-1].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X, pole.Y-1].kolor <> kolor then
                           begin
                               tmpBoard:=Board;
                               tmpBoard[pole.X,pole.y-1]:=tmpBoard[pole.X,pole.Y];
                               tmpBoard[pole.X,pole.Y]:=nil;
                               if Length(KtoAtakujePole(DaneBoard[pole.X,pole.Y-1].pole,'',@tmpBoard))=0 then
                                begin
                               SetLength(ruchy, Length(ruchy)+1);
                               ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y-1].pole;
                               end;
                            end;
                     end;
                end;


               if pole.X+1<=8 then
                begin
                     if Board[pole.X+1, pole.Y]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X+1,pole.y]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[pole.X+1,pole.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X+1, pole.Y].kolor <> kolor then
                           begin
                               tmpBoard:=Board;
                               tmpBoard[pole.X+1,pole.y]:=tmpBoard[pole.X,pole.Y];
                               tmpBoard[pole.X,pole.Y]:=nil;
                               if Length(KtoAtakujePole(DaneBoard[pole.X+1,pole.Y].pole,'',@tmpBoard))=0 then
                                begin
                               SetLength(ruchy, Length(ruchy)+1);
                               ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y].pole;
                               end;
                            end;
                     end;
                end;



               if pole.X-1>=1 then
                begin
                     if Board[pole.X-1, pole.Y]=nil then
                      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X-1,pole.y]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[pole.X-1,pole.Y].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y].pole;
                          end;
                      end
                     else
                     begin
                           if Board[pole.X-1, pole.Y].kolor <> kolor then
                           begin
                               tmpBoard:=Board;
                               tmpBoard[pole.X-1,pole.y]:=tmpBoard[pole.X,pole.Y];
                               tmpBoard[pole.X,pole.Y]:=nil;
                               if Length(KtoAtakujePole(DaneBoard[pole.X-1,pole.Y].pole,'',@tmpBoard))=0 then
                                begin
                               SetLength(ruchy, Length(ruchy)+1);
                               ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y].pole;
                               end;
                            end;
                     end;
                end;

  {-----------------------------------}

  {-- ruchy gonca - po skosie --}


      if ((pole.X-1)>=1) and ((pole.Y-1)>=1) then begin

      if Board[pole.X-1, pole.Y-1]=nil then
      begin
                          tmpBoard:=Board;
                          tmpBoard[pole.X-1,pole.y-1]:=tmpBoard[pole.X,pole.Y];
                          tmpBoard[pole.X,pole.Y]:=nil;
                          if Length(KtoAtakujePole(DaneBoard[pole.X-1,pole.Y-1].pole,'',@tmpBoard))=0 then
                           begin
                          SetLength(ruchy, Length(ruchy)+1);
                          ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y-1].pole;
                          end;
      end
      else
      begin
         if Board[pole.X-1, pole.Y-1].kolor<>kolor then
         begin
             tmpBoard:=Board;
             tmpBoard[pole.X-1,pole.y-1]:=tmpBoard[pole.X,pole.Y];
             tmpBoard[pole.X,pole.Y]:=nil;
             if Length(KtoAtakujePole(DaneBoard[pole.X-1,pole.Y-1].pole,'',@tmpBoard))=0 then
              begin
             SetLength(ruchy, Length(ruchy)+1);
             ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y-1].pole;
             end;
         end;
      end;
      end;


      if ((pole.X-1)>=1) and ((pole.Y+1)<=8) then begin

      if Board[pole.X-1, pole.Y+1]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X-1,pole.y+1]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[pole.X-1,pole.Y+1].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y+1].pole;
          end;
      end
      else
      begin
         if Board[pole.X-1, pole.Y+1].kolor<>kolor then
         begin
             tmpBoard:=Board;
             tmpBoard[pole.X-1,pole.y+1]:=tmpBoard[pole.X,pole.Y];
             tmpBoard[pole.X,pole.Y]:=nil;
             if Length(KtoAtakujePole(DaneBoard[pole.X-1,pole.Y+1].pole,'',@tmpBoard))=0 then
              begin
             SetLength(ruchy, Length(ruchy)+1);
             ruchy[High(ruchy)]:=DaneBoard[pole.X-1, pole.Y+1].pole;
             end;
         end;
      end;

   end;


      if ((pole.X+1)<=8) and ((pole.Y-1)>=1) then
      begin

      if Board[pole.X+1, pole.Y-1]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X+1,pole.y-1]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[pole.X+1,pole.Y-1].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y-1].pole;
          end;
      end
      else
      begin
         if Board[pole.X+1, pole.Y-1].kolor<>kolor then
         begin
             tmpBoard:=Board;
             tmpBoard[pole.X+1,pole.y-1]:=tmpBoard[pole.X,pole.Y];
             tmpBoard[pole.X,pole.Y]:=nil;
             if Length(KtoAtakujePole(DaneBoard[pole.X+1,pole.Y-1].pole,'',@tmpBoard))=0 then
              begin
             SetLength(ruchy, Length(ruchy)+1);
             ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y-1].pole;
             end;
         end;
      end;

        end;


      if ((pole.X+1)<=8) and ((pole.Y+1)<=8) then begin

      if Board[pole.X+1, pole.Y+1]=nil then
      begin
          tmpBoard:=Board;
          tmpBoard[pole.X+1,pole.y+1]:=tmpBoard[pole.X,pole.Y];
          tmpBoard[pole.X,pole.Y]:=nil;
          if Length(KtoAtakujePole(DaneBoard[pole.X+1,pole.Y+1].pole,'',@tmpBoard))=0 then
           begin
          SetLength(ruchy, Length(ruchy)+1);
          ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y+1].pole;
          end;
      end
      else
      begin
         if Board[pole.X+1, pole.Y+1].kolor<>kolor then
         begin
             tmpBoard:=Board;
             tmpBoard[pole.X+1,pole.y+1]:=tmpBoard[pole.X,pole.Y];
             tmpBoard[pole.X,pole.Y]:=nil;
             if Length(KtoAtakujePole(DaneBoard[pole.X+1,pole.Y+1].pole,'',@tmpBoard))=0 then
              begin
             SetLength(ruchy, Length(ruchy)+1);
             ruchy[High(ruchy)]:=DaneBoard[pole.X+1, pole.Y+1].pole;
             end;
         end;
      end;

   end;

      {--- sprawdzamy roszade ---}

      if (DaneBoard[pole.X,pole.Y].pole='E1') or (DaneBoard[pole.X,pole.Y].pole='E8') then
      begin
           if CzySieRuszal(pole)=false then //jezeli krol sie nie ruszal
           begin
                if Board[pole.X, 1]<>nil then  //jezeli po lewej jest wieza i sie nie ruszala
                begin
                    if Board[pole.X, 1].rodzaj='wieza' then
                    begin
                          if CzySieRuszal(Point(pole.X, 1))=false then
                          begin
                                if (Board[pole.X, pole.Y-1]=nil) and (Board[pole.X, pole.Y-2]=nil) then  //jezeli nic nie stoi na polach
                                begin
                                   if (Length(KtoAtakujePole(DaneBoard[pole.X, pole.Y-1].pole, Board[pole.X, pole.Y].kolor,@Board))=0) and (Length(KtoAtakujePole(DaneBoard[pole.X, pole.Y-2].pole, Board[pole.X, pole.Y].kolor,@Board))=0) and (Length(KtoAtakujePole(DaneBoard[pole.X, pole.Y].pole, Board[pole.X, pole.Y].kolor,@Board))=0) then
                                   begin  //jezeli nie ma szacha i nic nie atakuje pol to mozna zrobic roszade
                                         SetLength(ruchy, Length(ruchy)+1);
                                         ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y-2].pole;
                                   end;
                                end;
                          end;

                    end;
                end;
              if Board[pole.X, 8]<>nil then  //jezeli po prawej jest wieza i sie nie ruszala
              begin
                  if Board[pole.X, 8].rodzaj='wieza' then
                  begin
                        if CzySieRuszal(Point(pole.X, 8))=false then
                        begin
                              if (Board[pole.X, pole.Y+1]=nil) and (Board[pole.X, pole.Y+2]=nil) then  //jezeli nic nie stoi na polach
                              begin
                                 if (Length(KtoAtakujePole(DaneBoard[pole.X, pole.Y+1].pole, Board[pole.X, pole.Y].kolor,@Board))=0) and (Length(KtoAtakujePole(DaneBoard[pole.X, pole.Y+2].pole, Board[pole.X, pole.Y].kolor,@Board))=0) and (Length(KtoAtakujePole(DaneBoard[pole.X, pole.Y].pole,Board[pole.X, pole.Y].kolor, @Board))=0) then
                                 begin  //jezeli nie ma szacha i nic nie atakuje pol to mozna zrobic roszade
                                       SetLength(ruchy, Length(ruchy)+1);
                                       ruchy[High(ruchy)]:=DaneBoard[pole.X, pole.Y+2].pole;
                                 end;
                              end;
                        end;

                  end;
              end;

           end;
      end;
      {---}

end;

  {------------------------}

    result:=ruchy;
  end;


{-----}

function TForm3.CzyLegalnyRuch(NaPole:string):boolean;
var
i:integer;
ok:boolean;
begin
ok:=false;

for i:=0 to Length(TablicaRuchow)-1 do
    if NaPole = TablicaRuchow[i] then ok:=true;

Result:=ok;
end;

function TForm3.CzySzach(kolor:string):boolean;
var
i,j:integer;
PozycjaKrola:TPoint;
begin

for i:=1 to 8 do
for j:=1 to 8 do
  if Board[i,j]<>nil then begin if (Board[i,j].rodzaj='krol') and (Board[i,j].kolor=kolor) then PozycjaKrola:=Point(i,j); end;

if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole, '',@Board))>0 then
begin
KolorowanieSzach.ok:=true;
KolorowanieSzach.pole:=PozycjaKrola;
end
else
begin
KolorowanieSzach.ok:=false;
end;

end;

function TForm3.WykonajRuch(Z,Na,Uwagi:string):boolean;
var
a,b:TPoint;
begin
if Uwagi='przelot' then
begin
    a:=ZnajdzIJbyPole(Z);
    FreeAndNil(Board[a.x,a.y]);
    Exit;
end;

a:=ZnajdzIJbyPole(Z);
b:=ZnajdzIJbyPole(Na);

if (Uwagi<>'przelot')and(Uwagi<>'wiezaroszada')and(Uwagi<>'promocja') then  //jezeli nie robi roszady i przelotu to zapisujemy normalny ruch
begin
 ZapiszRuch(Z, Na, Board[a.x,a.y].rodzaj, Board[a.x,a.y].kolor,'');
end;

if Uwagi='promocja' then
begin
 ZapiszRuch(Z, Na, Board[a.x,a.y].rodzaj, Board[a.x,a.y].kolor,'promocja');
end;

if Board[b.x,b.y]<>nil then
 FreeAndNil(Board[b.x,b.y]);

Board[b.x,b.y]:=Board[a.x,a.y];

Board[b.x,b.y].pole:=Na;
Board[b.x,b.y].pozycja := ZnajdzXYbyPole(Na);

Board[a.x,a.y]:=nil;

KolorowanieRuchu.ok:=true;
KolorowanieRuchu.Z:=ZnajdzIJbyPole(Z);
KolorowanieRuchu.NA:=ZnajdzIJbyPole(Na);

//sprawdzamy czy roszada i ewentualnie przestawiamy wieze

//sprawdzamy czy dol zrobily roszade krotka
if (Z='E1')and(Na='G1')and(Uwagi='roszada') then
begin
    WykonajRuch('H1','F1','wiezaroszada');
end;

//sprawdzamy czy dol zrobily roszade dluga
if (Z='E1')and(Na='C1')and(Uwagi='roszada') then
begin
    WykonajRuch('A1','D1','wiezaroszada');
end;

//sprawdzamy czy gora zrobily roszade krotka
if (Z='E8')and(Na='G8')and(Uwagi='roszada') then
begin
    WykonajRuch('H8','F8','wiezaroszada');
end;

//sprawdzamy czy gora zrobily roszade dluga
if (Z='E8')and(Na='C8')and(Uwagi='roszada') then
begin
    WykonajRuch('A8','D8','wiezaroszada');
end;


CzySzach(Ustawienia.KogoRuch); //jezeli szach to kolorujemy krola
PaintBox1.Invalidate;

end;

function TForm3.CzyKrolMaGdzieUciec(K:TPoint):boolean;
var
ma:boolean;
KolorKrola,KolorPrzeciwnika:string;
begin
ma:=false;

KolorKrola:=Board[K.X,K.Y].kolor;

if KolorKrola='biale' then begin KolorPrzeciwnika:='czarne'; end else begin KolorPrzeciwnika:='biale'; end;


if K.x-1>=1 then begin  //do gory
   if Board[K.X-1, K.Y]=nil then
   begin
      if Length(KtoAtakujePole(DaneBoard[K.X-1,K.Y].pole, KolorKrola, @Board))=0 then ma:=True;
   end
   else
   begin
      if (KolorKrola<>Board[K.X-1,K.Y].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X-1,K.Y), KolorKrola, @Board))=0 then ma:=True;
         end;
   end;
end;

if (K.x-1>=1) and (K.y+1<=8) then begin  //do gory w prawo
   if Board[K.X-1, K.Y+1]=nil then
   begin
       if Length(KtoAtakujePole(DaneBoard[K.X-1,K.Y+1].pole, KolorKrola, @Board))=0 then ma:=True;
   end
      else
   begin
      if (KolorKrola<>Board[K.X-1,K.Y+1].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X-1,K.Y+1), KolorKrola, @Board))=0 then ma:=True;
         end;
   end;
end;

if (K.x-1>=1) and (K.y-1>=1) then begin  //do gory w lewo
   if Board[K.X-1, K.Y-1]=nil then
   begin
      if Length(KtoAtakujePole(DaneBoard[K.X-1,K.Y-1].pole, KolorKrola, @Board))=0 then ma:=True;
   end
      else
   begin
      if (KolorKrola<>Board[K.X-1,K.Y-1].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X-1,K.Y-1), KolorKrola, @Board))=0 then ma:=True;
         end;
   end;
end;

if K.y-1>=1 then begin  //w lewo
   if Board[K.X, K.Y-1]=nil then
   begin
      if Length(KtoAtakujePole(DaneBoard[K.X,K.Y-1].pole, KolorKrola, @Board))=0 then ma:=True;
   end
      else
   begin
      if (KolorKrola<>Board[K.X,K.Y-1].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X,K.Y-1), KolorKrola, @Board))=0 then ma:=True;
         end;
   end;
end;

if (K.x+1<=8) and (K.y-1>=1) then begin  //w lewo w dol
   if Board[K.X+1, K.Y-1]=nil then
   begin
      if Length(KtoAtakujePole(DaneBoard[K.X+1,K.Y-1].pole, KolorKrola, @Board))=0 then ma:=True;
   end
      else
   begin
      if (KolorKrola<>Board[K.X+1,K.Y-1].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X+1,K.Y-1), KolorKrola, @Board))=0 then ma:=True;
         end;
   end;
end;

if K.x+1<=8 then begin  //w dol
   if Board[K.X+1, K.Y]=nil then
   begin
      if Length(KtoAtakujePole(DaneBoard[K.X+1,K.Y].pole, KolorKrola, @Board))=0 then ma:=True;
   end
      else
   begin
      if (KolorKrola<>Board[K.X+1,K.Y].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X+1,K.Y), KolorKrola, @Board))=0 then ma:=True;
         end;
   end;
end;

if K.y+1<=8 then begin  //w prawo
   if Board[K.X, K.Y+1]=nil then
   begin
      if Length(KtoAtakujePole(DaneBoard[K.X,K.Y+1].pole, KolorKrola, @Board))=0 then ma:=True;
   end
      else
   begin
      if (KolorKrola<>Board[K.X,K.Y+1].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X,K.Y+1), KolorKrola, @Board))=0 then ma:=True;
         end;
   end;
end;

if (K.x+1<=8) and (K.y+1<=8) then begin  //w prawo w dol
   if Board[K.X+1, K.Y+1]=nil then
   begin
      if Length(KtoAtakujePole(DaneBoard[K.X+1,K.Y+1].pole, KolorKrola, @Board))=0 then
      ma:=True;
   end
      else
   begin
      if (KolorKrola<>Board[K.X+1,K.Y+1].kolor) then
         begin
             if Length(KtoBroniPole(Point(K.X+1,K.Y+1), KolorKrola, @Board))=0 then
             ma:=True;
         end;
   end;
end;

Result:=ma;

end;

function TForm3.CzyMat(kolor:string):boolean;
var
PozycjaKrola:TPoint;
i,j,z:integer;
atakujacy,atakujacy2:TTablicaPunktow;
KolorPrzeciwnika:string;
nie:boolean;
begin
nie:=false;

for i:=1 to 8 do
for j:=1 to 8 do
  if Board[i,j]<>nil then begin if (Board[i,j].rodzaj='krol') and (Board[i,j].kolor=kolor) then PozycjaKrola:=Point(i,j); end;

if Length(KtoAtakujePole(DaneBoard[PozycjaKrola.X,PozycjaKrola.Y].pole,'', @Board))>0 then   //Po wykonanym ruchu sprawdzamy czy cos atakuje wskazanego krola
begin

   //sprawdzamy najpierw najblizsze pola krola czy moze uciec albo zabic
        if CzyKrolMaGdzieUciec(PozycjaKrola)=true then
        begin
        Exit (False);
        end
        else
        begin

     //jezeli krol nie moze uciec lub zabic z bliska sprawdzamy liste atakujacych
            atakujacy:=KtoAtakujePole(DaneBoard[PozycjaKrola.X, PozycjaKrola.Y].pole, '', @Board);


            for i:=0 to Length(atakujacy)-1 do
            begin
                 //najpierw sprawdzimy czy mozna zabic bierke

                if kolor='biale' then begin KolorPrzeciwnika:='czarne'; end else begin KolorPrzeciwnika:='biale'; end;

                atakujacy2:=KtoAtakujePole(DaneBoard[atakujacy[i].x,atakujacy[i].y].pole, '', @Board); //mamy liste kto moze zabic atakujacego
                //jezeli tu doszlismy to nasz krol nie moze wiec musimy go usunac z listy

                for z:=0 to Length(atakujacy2)-1 do
                begin
                     if Board[atakujacy2[z].x, atakujacy2[z].y].rodzaj='krol' then
                     begin
                          for j:=z To high(atakujacy2)-1 Do
                          atakujacy2[j] := atakujacy2[j+1];
                          SetLength(atakujacy2,high(atakujacy2));
                     Break;
                     end;
                end;
                //usunelismy krola z listy i sprawdzamy reszte


                if Length(atakujacy2)>0 then
                begin
                Exit (False);    //tu trzeba jeszcze zmienic bo moze byc 2 atakujacych i nie wystarczy rozwalic jednego
                end
                else             //jezeli nie mozna zabic bierki sprawdzamy czy mozna zaslonic pola
                begin


                      if CzyMoznaZaslonic(PozycjaKrola, atakujacy[i])=true then
                      begin
                      Exit (False);
                      end
                      else
                      begin
                      Exit (True);
                      end;
                 end;
            end;
        end;
        end;

Result:=nie;
end;

function TForm3.CzyPat(kol:string):boolean;
var
i,j,L:integer;
PozycjaKrola:TPoint;
begin

L:=Length(PrzebiegPartii);

if L>=10 then //sprawdzamy czy trzykrotne powtorzenie ruchow
begin
if (PrzebiegPartii[L-1].Z=PrzebiegPartii[L-3].NA) and (PrzebiegPartii[L-1].NA=PrzebiegPartii[L-3].Z) and //sprawdzamy dla pierwszego
   (PrzebiegPartii[L-3].Z=PrzebiegPartii[L-5].NA) and (PrzebiegPartii[L-3].NA=PrzebiegPartii[L-5].Z) and
   (PrzebiegPartii[L-5].Z=PrzebiegPartii[L-7].NA) and (PrzebiegPartii[L-5].NA=PrzebiegPartii[L-7].Z) and
   (PrzebiegPartii[L-7].Z=PrzebiegPartii[L-9].NA) and (PrzebiegPartii[L-7].NA=PrzebiegPartii[L-9].Z) and

   (PrzebiegPartii[L-2].Z=PrzebiegPartii[L-4].NA) and (PrzebiegPartii[L-2].NA=PrzebiegPartii[L-4].Z) and //sprawdzamy dla drugiego
   (PrzebiegPartii[L-4].Z=PrzebiegPartii[L-6].NA) and (PrzebiegPartii[L-4].NA=PrzebiegPartii[L-6].Z) and
   (PrzebiegPartii[L-6].Z=PrzebiegPartii[L-8].NA) and (PrzebiegPartii[L-6].NA=PrzebiegPartii[L-8].Z) then
 //  (PrzebiegPartii[L-8].Z=PrzebiegPartii[L-10].NA) and (PrzebiegPartii[L-8].NA=PrzebiegPartii[L-10].Z) then
   Exit (True); //jezeli trzykrotne powtorzenie ruchu przez kazdego gracza to remis

end;

for i:=1 to 8 do
for j:=1 to 8 do
begin
    if (Board[i,j]<>nil) then
    begin
         if Board[i,j].kolor=kol then
         begin
              if Length(MozliweRuchy(DaneBoard[i,j].pole))>0 then
              Exit (False);
         end;
    end;
end;

Result:=True;


end;

function TForm3.ZostalTylkoKrol(kolor:string):boolean;
var
i,j:integer;
begin
for i:=1 to 8 do
for j:=1 to 8 do
begin
    if Board[i,j]<>nil then
    begin
         if Board[i,j].kolor=kolor then
         begin
              if (Board[i,j].rodzaj<> 'krol') then
              begin
                  Exit (False);
              end;
         end;
    end;
end;

Result:=True;

end;


function TForm3.CzyRemis(kol:string):boolean;
var
i,j:integer;
JestGoniec,JestSkoczek:boolean;
kolor:string;
ruchy:TMapaRuchow;
begin

//najpierw sprawdzimy czy zostaly odpowiednie bierki


for i:=1 to 8 do
for j:=1 to 8 do
begin
if (Board[i,j]<>nil) and (Board[i,j].kolor=kol) and (Board[i,j].rodzaj<> 'krol') then
begin
    if (Board[i,j].rodzaj='pion') then //jezeli pion to czy moze sie ruszyc
    Exit (False);

    if (Board[i,j].rodzaj='wieza') or (Board[i,j].rodzaj='hetman') then
    Exit (False);

end;

end;

//sprawdzamy czy sa tylko dwa gonce

JestGoniec:=false;

for i:=1 to 8 do
for j:=1 to 8 do
begin
if (Board[i,j]<>nil) and (Board[i,j].kolor=kol) and (Board[i,j].rodzaj<> 'krol') then
begin
    if Board[i,j].rodzaj='goniec' then
    begin
        if (JestGoniec=true) then begin
        if DaneBoard[i,j].KolorPola<>kol then
        Exit (False);
        end;

        JestGoniec:=true;
        kolor:=DaneBoard[i,j].KolorPola;
    end;
end;
end;

//sprawdzamy czy sa goniec i skoczek

JestSkoczek:=false;
JestGoniec:=false;

for i:=1 to 8 do
for j:=1 to 8 do
begin
if (Board[i,j]<>nil) and (Board[i,j].kolor=kol) and (Board[i,j].rodzaj<>'krol') then
begin
    if Board[i,j].rodzaj='skoczek' then
    begin
        if JestGoniec=true then
        Exit (False);
        JestGoniec:=true;
    end;

    if Board[i,j].rodzaj='goniec' then
    begin
        if JestSkoczek=true then
        Exit (False);
        JestSkoczek:=true;
    end;
end;
end;

{
//sprawdzamy czarne {wiem wiem, mozna to zrobic w jednej funkcji... }
for i:=1 to 8 do
for j:=1 to 8 do
begin
if (Board[i,j]<>nil) and (Board[i,j].kolor='czarne') and (Board[i,j].rodzaj<> 'krol') then
begin
    if (Board[i,j].rodzaj='pion') then //jezeli pion to czy moze sie ruszyc
    begin
        if Board[i-1,j]=nil then
        begin
        Exit (False);
        end
        else
        begin
            if (Board[i-1,j].rodzaj<>'pion') then
            Exit (False);
        end;
    end;

    if (Board[i,j].rodzaj='wieza') or (Board[i,j].rodzaj='hetman') then
    Exit (False);

end;

end;

//sprawdzamy czy sa tylko dwa gonce

JestGoniec:=false;

for i:=1 to 8 do
for j:=1 to 8 do
begin
if (Board[i,j]<>nil) and (Board[i,j].kolor='czarne') and (Board[i,j].rodzaj<> 'krol') then
begin
    if Board[i,j].rodzaj='goniec' then
    begin
        if JestGoniec=true then
        Exit (False);

        JestGoniec:=true;
    end;
end;
end;

//sprawdzamy czy sa goniec i skoczek

JestSkoczek:=false;
JestGoniec:=false;

for i:=1 to 8 do
for j:=1 to 8 do
begin
if (Board[i,j]<>nil) and (Board[i,j].kolor='czarne') and (Board[i,j].rodzaj<>'krol') then
begin
    if Board[i,j].rodzaj='skoczek' then
    begin
        if JestGoniec=true then
        Exit (False);
        JestGoniec:=true;
    end;

    if Board[i,j].rodzaj='goniec' then
    begin
        if JestSkoczek=true then
        Exit (False);
        JestSkoczek:=true;
    end;
end;
end;        }



Result:=True;
end;


{---}

function TForm3.ZapiszRuch(Z,Na,rodzaj,kolor,Uwagi:string):boolean;
begin

SetLength(PrzebiegPartii, Length(PrzebiegPartii)+1);

PrzebiegPartii[High(PrzebiegPartii)].Z:=Z;
PrzebiegPartii[High(PrzebiegPartii)].NA:=Na;
PrzebiegPartii[High(PrzebiegPartii)].figura:=rodzaj;
PrzebiegPartii[High(PrzebiegPartii)].kolor:=kolor;
PrzebiegPartii[High(PrzebiegPartii)].uwagi:=Uwagi;

OdswiezPrzebieg;
Result:=true;

end;

function TForm3.OdswiezPrzebieg:boolean;
var
i,j,licznik:integer;
s:string;
begin
//for i:=0 to Przebieg.RowCount-1 do
//Przebieg.Rows[i].Clear;

licznik:=0;
Przebieg.RowCount:=0;

Przebieg.RowCount:=(Length(PrzebiegPartii) div 2)+1;

for i:=0 to Length(PrzebiegPartii)-1 do
begin
//dodajemy ruch jezeli biale
    if PrzebiegPartii[i].kolor='biale' then
    begin
         s:='';
    //Przebieg.RowCount:=licznik+1;
    Przebieg.Cells[0,licznik]:=IntToStr(licznik+1);
    if PrzebiegPartii[i].figura<>'pion' then s:=UpperCase(LeftStr(PrzebiegPartii[i].figura, 1));
    Przebieg.Cells[1,licznik]:=s+''+PrzebiegPartii[i].Z+''+PrzebiegPartii[i].Na;
    end;
//dodajemy ruch jak czarne
    if PrzebiegPartii[i].kolor='czarne' then
    begin
    s:='';
    if PrzebiegPartii[i].figura<>'pion' then s:=UpperCase(LeftStr(PrzebiegPartii[i].figura, 1));
    Przebieg.Cells[2,licznik]:=s+''+PrzebiegPartii[i].Z+''+PrzebiegPartii[i].Na;
    licznik:=licznik+1;
    end;
end;

end;

{---------}
  {
procedure TForm3.UstawTimerek(kolor,co:string);
begin

if kolor='biale' then
 begin
      if co='start' then
       begin
            TimerCzasBiale.Enabled:=true;
       end
      else
      begin
           TimerCzasBiale.Enabled:=false;
      end;
 end;

if kolor='czarne' then
 begin
      if co='start' then
       begin
            TimerCzasCzarne.Enabled:=true;
       end
      else
      begin
           TimerCzasCzarne.Enabled:=false;
      end;
 end;

end; }

procedure TForm3.TimerCzasBialeTimer(Sender: TObject);
begin
if start=false then
begin
     Self.Enabled:=false;
Exit;
end;

  CzasBiale:=CzasBiale-1;
OdswiezCzas;
end;

procedure TForm3.TimerCzasCzarneTimer(Sender: TObject);
begin
if start=false then
begin
Self.Enabled:=false;
Exit;
end;

    CzasCzarne:=CzasCzarne-1;
OdswiezCzas;
end;

{--------------------------------------------------------------------------}

procedure TForm3.PokazForme;
begin
 Self.Show;
end;

procedure TForm3.PrzekazKomunikat(kom:string);
begin
  ObslugaKomunikatuPartii:=kom;
end;


procedure TForm3.komunikat;
var
odczyt,posuniecie:TStrings;
i:TPoint;
r:real;
begin
odczyt:=TStringList.Create;
ExtractStrings(['|'], [], PAnsiChar(ObslugaKomunikatuPartii), odczyt);

//011|58|RuchCzarnych|krol*E8*G8*roszada|3586

if odczyt[0]='040' then  //jezeli gracz sie rozlaczyl
begin
  if Ustawienia.GramKolorem='biale' then
  begin
     Label2.Font.Color:=clRed;
     Label4.Caption:='Rozlaczony...';
  end;

  if Ustawienia.GramKolorem='czarne' then
  begin
     Label1.Font.Color:=clRed;
     Label3.Caption:='Rozlaczony...';
  end;

  Exit;
end;

if odczyt[2]='UpdateRank' then
begin
    //UpdateRank|NewRankBiale|NewRankCzarne

    r:=StrToFloat(odczyt[3])-StrToFloat(Label3.Caption);
    if r<0 then
    begin
     LUpdateRankBiale.Font.Color:=clRed;
     LUpdateRankBiale.Caption:=FloatToStr(r);
    end
    else
    begin
    LUpdateRankBiale.Font.Color:=clGreen;
    LUpdateRankBiale.Caption:='+'+FloatToStr(r);
    end;

    r:=StrToFloat(odczyt[4])-StrToFloat(Label4.Caption);
    if r<0 then
    begin
     LUpdateRankCzarne.Font.Color:=clRed;
     LUpdateRankCzarne.Caption:=FloatToStr(r);
    end
    else
    begin
    LUpdateRankCzarne.Font.Color:=clGreen;
    LUpdateRankCzarne.Caption:='+'+FloatToStr(r);
    end;
Exit;
end;

if odczyt[2]='PropozycjaRemisu' then
begin
  PartiaInfo.Color:=clRed;
  PartiaInfo.Caption:='Przeciwnik proponuje remis';

  PrzyjmijRemis.Visible:=true;
  OdrzucRemis.Visible:=true;

  ZaproponujRemis.Visible:=false;
  PoddajPartie.Visible:=false;
end;

if odczyt[2]='OdrzucamRemis' then
begin
  PartiaInfo.Color:=$003B3B3B;
  PartiaInfo.Caption:='Przeciwnik odrzucil remis';

  ZaproponujRemis.Enabled:=true;

end;

if odczyt[2]='BialeStart' then
begin
    Ustawienia.KogoRuch:='biale';
    PartiaInfo.Caption:='Partia trwa';

    ZaproponujRemis.Enabled:=true;
    PoddajPartie.Enabled:=true;

    start:=true;
    TimerCzasBiale.Enabled:=true;
end;


if odczyt[2]='ZegarBiale' then
begin
     TimerCzasBiale.Enabled:=false;

     CzasBiale:=StrToInt(odczyt[3]);
     OdswiezCzas;

     TimerCzasCzarne.Enabled:=true;

end;

if odczyt[2]='ZegarCzarne' then
begin
     TimerCzasCzarne.Enabled:=false;

     CzasCzarne:=StrToInt(odczyt[3]);
     OdswiezCzas;

     TimerCzasBiale.Enabled:=true;

end;

if odczyt[2]='RuchBialych' then
begin
     TimerCzasBiale.Enabled:=false;
     CzasBiale:=StrToInt(odczyt[4]);
    OdswiezCzas;

    posuniecie:=TStringList.Create;
    ExtractStrings(['*'], [], PAnsiChar(odczyt[3]), posuniecie);
    //figura*Z*NA*UWAGI*UWAGI2

    if posuniecie[3]='przelot' then
    begin
         WykonajRuch(posuniecie[1],posuniecie[2],'');
         WykonajRuch(posuniecie[4],'','przelot');
    end;

    if posuniecie[3]='roszada' then
    begin
        WykonajRuch(posuniecie[1],posuniecie[2],'roszada');
    end;

    if posuniecie[3]='promocja' then
    begin
         WykonajRuch(posuniecie[1],posuniecie[2],'promocja');

         i:=ZnajdzIJbyPole(posuniecie[2]);

        if posuniecie[4]='hetman' then
        begin
         Board[i.x,i.y].obraz.LoadFromFile('img/HetmanBialy.png');
         Board[i.x,i.y].rodzaj:='hetman';
        end;

         if posuniecie[4]='wieza' then
         begin
          Board[i.x,i.y].obraz.LoadFromFile('img/WiezaBiala.png');
          Board[i.x,i.y].rodzaj:='wieza';
         end;

         if posuniecie[4]='goniec' then
         begin
          Board[i.x,i.y].obraz.LoadFromFile('img/GoniecBialy.png');
          Board[i.x,i.y].rodzaj:='goniec';
         end;

         if posuniecie[4]='skoczek' then
         begin
          Board[i.x,i.y].obraz.LoadFromFile('img/SkoczekBialy.png');
          Board[i.x,i.y].rodzaj:='skoczek';
         end;

    end;

    if posuniecie[3]='ruch' then
    begin
        WykonajRuch(posuniecie[1],posuniecie[2],'');
    end;

    Ustawienia.KogoRuch:='czarne';
    CzySzach(Ustawienia.KogoRuch);
    PaintBox1.Invalidate;


    TimerCzasCzarne.Enabled:=true;

end;

if odczyt[2]='RuchCzarnych' then
begin
    TimerCzasCzarne.Enabled:=false;
    CzasCzarne:=StrToInt(odczyt[4]);
    OdswiezCzas;

    posuniecie:=TStringList.Create;
    ExtractStrings(['*'], [], PAnsiChar(odczyt[3]), posuniecie);
    //figura*Z*NA*UWAGI*UWAGI2

    if posuniecie[3]='przelot' then
    begin
         WykonajRuch(posuniecie[1],posuniecie[2],'');
         WykonajRuch(posuniecie[4],'','przelot');
    end;

    if posuniecie[3]='roszada' then
    begin
         WykonajRuch(posuniecie[1],posuniecie[2],'roszada');
    end;

    if posuniecie[3]='promocja' then
    begin

         WykonajRuch(posuniecie[1],posuniecie[2],'');

         i:=ZnajdzIJbyPole(posuniecie[2]);

        if posuniecie[4]='hetman' then
        begin
         Board[i.x,i.y].obraz.LoadFromFile('img/HetmanCzarny.png');
         Board[i.x,i.y].rodzaj:='hetman';
        end;

         if posuniecie[4]='wieza' then
         begin
          Board[i.x,i.y].obraz.LoadFromFile('img/WiezaCzarna.png');
          Board[i.x,i.y].rodzaj:='wieza';
         end;

         if posuniecie[4]='goniec' then
         begin
          Board[i.x,i.y].obraz.LoadFromFile('img/GoniecCzarny.png');
          Board[i.x,i.y].rodzaj:='goniec';
         end;

         if posuniecie[4]='skoczek' then
         begin
          Board[i.x,i.y].obraz.LoadFromFile('img/SkoczekCzarny.png');
          Board[i.x,i.y].rodzaj:='skoczek';
         end;

    end;

    if posuniecie[3]='ruch' then
    begin
        WykonajRuch(posuniecie[1],posuniecie[2],'');
    end;

    Ustawienia.KogoRuch:='biale';
    CzySzach(Ustawienia.KogoRuch);
    PaintBox1.Invalidate;

    TimerCzasBiale.Enabled:=true;
end;




if odczyt[2]='KoniecCzasu' then
begin
TimerCzasBiale.Interval:=360000;
TimerCzasCZarne.Interval:=360000;
Ustawienia.KogoRuch:='nikogo';
start:=false;
TimerCzasBiale.Enabled:=false;
TimerCzasBiale.Enabled:=false;

ZaproponujRemis.Enabled:=false;
PoddajPartie.Enabled:=false;

PartiaInfo.Caption:=odczyt[3];

if odczyt[3]='KoniecCzasuWygralyBiale' then
begin
CzasCzarne:=0;
OdswiezCzas;
end
else
begin
CzasBiale:=0;
OdswiezCzas;
end;

end;

if odczyt[2]='Koniec' then
begin
Ustawienia.KogoRuch:='nikogo';
start:=false;
TimerCzasBiale.Enabled:=false;
TimerCzasBiale.Enabled:=false;

ZaproponujRemis.Enabled:=false;
PoddajPartie.Enabled:=false;

if odczyt[3]='Wygraly' then
begin
PartiaInfo.Caption:='Wygraly '+odczyt[4];
end;


if odczyt[3]='Remis' then
begin
PartiaInfo.Caption:='Remis';
end;

end;

odczyt.Free;

end;


procedure TForm3.PrzekazDaneNaStart(linia:string);
var
      i,j,a,NumerPola,obraz:integer;
  kolor:string;
  white:boolean;
  odczyt:TStrings;
begin  {
KolorowanieRuchu.ok:=false;
KolorowanieKrola.ok:=false;
MozliweWPrzelocie.ok:=false;   }

start:=false;

 odczyt:=TStringList.Create;
 ExtractStrings(['|'], [], PAnsiChar(linia), odczyt);

 //010|'+id_partii+'|'+id_turnieju+'|ZarazStart|GraszBialymi|'+IntToStr(A.zegar.czas)+'|'+B.nick+'|'+B.rank)

 Ustawienia.KogoRuch:='czekamy';


if odczyt[4] = 'GraszBialymi' then
begin
    Ustawienia.GramKolorem:='biale';
    Ustawienia.KolorNaDole:='biale';
    Ustawienia.KolorNaGorze:='czarne';
    Label1.Caption:=User.user;
    Label3.Caption:=User.ranking;
    Label2.Caption:=odczyt[6];
    Label4.Caption:=odczyt[7];
end
    else
begin
    Ustawienia.GramKolorem:='czarne';
    Ustawienia.KolorNaDole:='czarne';
    Ustawienia.KolorNaGorze:='biale';
    Label1.Caption:=odczyt[6];
    Label3.Caption:=odczyt[7];
    Label2.Caption:=User.user;
    Label4.Caption:=User.ranking;
end;


 CzasBiale:=StrToInt(odczyt[5]);
 CzasCzarne:=StrToInt(odczyt[5]);

 id_partii:=StrToInt(odczyt[1]);

OdswiezCzas;


   if Ustawienia.KolorNaDole='biale' then
   begin
       for i:=1 to 8 do
           for j:=1 to 8 do
               begin
                  DaneBoard[i,j].pole:=POLA[i,j];
                  DaneBoard[i,j].X:=(j-1)*80;
                  DaneBoard[i,j].Y:=(i-1)*80;
               end;
   end
   else
   begin
        for i:=1 to 8 do
            for j:=1 to 8 do
               begin
                 DaneBoard[i,j].pole:=POLA[9-i,9-j];
                 DaneBoard[i,j].X:=(j-1)*80;
                 DaneBoard[i,j].Y:=(i-1)*80;
               end;
   end;

     if Ustawienia.KolorNaDole='biale' then
     begin
      kolor:='czarne';
      obraz:=10;
     end
     else
     begin
       kolor:='biale';
       obraz:=1;
     end;


            for i:=1 to 2 do
                for j:=1 to 8 do
                begin
                   if i=1 then  {ustawiamy figury}
                   begin
                     Board[i,j]:=TBierka.Create;
                     Board[i,j].pole:=DaneBoard[i,j].pole;
                     Board[i,j].kolor:=kolor;
                     Board[i,j].rodzaj:=FIGURY[j+1];
                     Board[i,j].obraz:=TPortableNetworkGraphic.Create;
                     Board[i,j].obraz.LoadFromFile('img/'+OBRAZYFIGUR[obraz+j]);
                     Board[i,j].obraz.Width:=70;
                     Board[i,j].obraz.Height:=70;
                     Board[i,j].pozycja:=Point(DaneBoard[i,j].X, DaneBoard[i,j].Y);
                   end
                   else
                   begin
                      for a:=1 to 8 do    {ustawiamy piony}
                      begin
                     Board[i,a]:=TBierka.Create;
                     Board[i,a].pole:=DaneBoard[i,a].pole;
                     Board[i,a].kolor:=kolor;
                     Board[i,a].rodzaj:='pion';
                     Board[i,a].obraz:=TPortableNetworkGraphic.Create;
                     Board[i,a].obraz.LoadFromFile('img/'+OBRAZYFIGUR[obraz]);
                     Board[i,a].obraz.Width:=70;
                     Board[i,a].obraz.Height:=70;
                     Board[i,a].pozycja:=Point(DaneBoard[i,a].X, DaneBoard[i,a].Y);
                      end;
                   end;
                end;

   if Ustawienia.KolorNaGorze='biale' then
   begin
   kolor:='czarne';
   obraz:=10;
   end
   else
   begin
   kolor:='biale';
   obraz:=1;
   end;

            for i:=7 to 8 do
                for j:=1 to 8 do
                begin
                   if i=8 then  {ustawiamy figury u gory}
                   begin
                     Board[i,j]:=TBierka.Create;
                     Board[i,j].pole:=DaneBoard[i,j].pole;
                     Board[i,j].kolor:=kolor;
                     Board[i,j].rodzaj:=FIGURY[j+1];
                     Board[i,j].obraz:=TPortableNetworkGraphic.Create;
                     Board[i,j].obraz.LoadFromFile('img/'+OBRAZYFIGUR[obraz+j]);
                     Board[i,j].obraz.Width:=70;
                     Board[i,j].obraz.Height:=70;
                     Board[i,j].pozycja:=Point(DaneBoard[i,j].X, DaneBoard[i,j].Y);
                   end
                   else
                   begin
                      for a:=1 to 8 do    {ustawiamy piony u gory}
                      begin
                     Board[i,a]:=TBierka.Create;
                     Board[i,a].pole:=DaneBoard[i,a].pole;
                     Board[i,a].kolor:=kolor;
                     Board[i,a].rodzaj:='pion';
                     Board[i,a].obraz:=TPortableNetworkGraphic.Create;
                     Board[i,a].obraz.LoadFromFile('img/'+OBRAZYFIGUR[obraz]);
                     Board[i,a].obraz.Width:=70;
                     Board[i,a].obraz.Height:=70;
                     Board[i,a].pozycja:=Point(DaneBoard[i,a].X, DaneBoard[i,a].Y);
                      end;
                   end;
                end;

            {jezeli gramy czarny odwracamy krola i hetmana}
           if Ustawienia.KolorNaDole='czarne' then
           begin

             Board[4,4]:=Board[1,4];
             Board[1,4]:=Board[1,5];
             Board[1,5]:=Board[4,4];
             Board[4,4]:=nil;

             Board[1,4].pole:=DaneBoard[1,4].pole;
             Board[1,4].pozycja:=Point(DaneBoard[1,4].X, DaneBoard[1,4].Y);
             Board[1,5].pole:=DaneBoard[1,5].pole;
             Board[1,5].pozycja:=Point(DaneBoard[1,5].X, DaneBoard[1,5].Y);

             Board[4,4]:=Board[8,4];
             Board[8,4]:=Board[8,5];
             Board[8,5]:=Board[4,4];
             Board[4,4]:=nil;

             Board[8,4].pole:=DaneBoard[8,4].pole;
             Board[8,4].pozycja:=Point(DaneBoard[8,4].X, DaneBoard[8,4].Y);
             Board[8,5].pole:=DaneBoard[8,5].pole;
             Board[8,5].pozycja:=Point(DaneBoard[8,5].X, DaneBoard[8,5].Y);

           end;

           white:=false;
           for i:=1 to 8 do begin
              if white=true then begin white:=false; end else begin white:=true; end;
           for j:=1 to 8 do begin
           	if white=true then begin
           	DaneBoard[i,j].KolorPola:='biale';
           	end
           	else
           	begin
           	DaneBoard[i,j].KolorPola:='czarne';
           	end;

           	if white=true then begin white:=false; end else begin white:=true; end;
           end;
           end;


            PaintBox1.Enabled:=True;

            PartiaInfo.Caption:='Partia rozpocznie sie za minute';
    odczyt.Free;
end;

{ --- PAINTBOX --- }

procedure TForm3.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pol:string;
  pozycja:TPoint;
begin
   if Ustawienia.GramKolorem<>Ustawienia.KogoRuch then Exit;

pol:=ZnajdzPolebyXY(X,Y);
pozycja:=znajdzIjbyPole(pol);

if Board[pozycja.X,pozycja.Y]=nil then Exit;
if Board[pozycja.X,pozycja.Y].kolor<>Ustawienia.KogoRuch then Exit;

DAD:=true;
DadBierka:=@Board[pozycja.X,pozycja.Y];
PunktPlansza := Point(X, Y);
PolePlansza:=Point(pozycja.X,pozycja.Y);

    SetLength(TablicaRuchow, 0);
    TablicaRuchow:=MozliweRuchy(Board[pozycja.X,pozycja.Y].pole);

  end;

procedure TForm3.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (DAD) then
         begin
         if X>PunktPlansza.X then
         begin
              DADBierka^.pozycja.X   := DADBierka^.pozycja.X+(X-PunktPlansza.x);
              PunktPlansza.X:=X;
         end;
         if X<PunktPlansza.X then
         begin
         DADBierka^.pozycja.X   := DADBierka^.pozycja.X-(PunktPlansza.x-X);
         PunktPlansza.X:=X;
         end;
         if Y<PunktPlansza.Y then
         begin
              DADBierka^.pozycja.Y    := DADBierka^.pozycja.Y-(PunktPlansza.Y-Y);
              PunktPlansza.y:=Y;
         end;
         if Y>PunktPlansza.Y then
         begin
              DADBierka^.pozycja.Y    := DADBierka^.pozycja.Y+(Y-PunktPlansza.Y);
              PunktPlansza.Y:=Y;
         end;

         PaintBox1.Invalidate;
         end;
end;

procedure TForm3.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tmp:TBierka;
  okRuch,czyDopisane:boolean;
  p,PozycjaKrola,pionek,z:TPoint;
  i,j,czas:integer;
  promocja:TPromocja;
  ruch,wiadomosc:string;
begin

  if DAD then
  begin

  if ZnajdzPolebyXY(X,Y)=DaneBoard[PolePlansza.X,PolePlansza.Y].pole then
 begin
   DadBierka^.pole:=DaneBoard[PolePlansza.X, PolePlansza.Y].pole;
   DadBierka^.pozycja := ZnajdzXYbyPole(DadBierka^.pole);
   DAD:=false;
   SetLength(TablicaRuchow, 0);
   PaintBox1.Invalidate;
   Exit;
 end;

  okRuch:=CzyLegalnyRuch(ZnajdzPolebyXY(X,Y));

if (okRuch) then
begin

  ruch:=DadBierka^.rodzaj+'*'+DaneBoard[PolePlansza.X,PolePlansza.y].pole+'*'+ZnajdzPolebyXY(X,Y)+'*';

  czyDopisane:=false;

//sprawdzamy czy roszada i ewentualnie przestawiamy wieze

//sprawdzamy czy dol zrobily roszade krotka
if (DaneBoard[PolePlansza.X,PolePlansza.y].pole='E1')and(ZnajdzPolebyXY(X,Y)='G1')
and (DadBierka^.rodzaj='krol') then
begin
    WykonajRuch('H1','F1','');
        ruch:=ruch+'roszada';
    czyDopisane:=true;
end;

//sprawdzamy czy dol zrobily roszade dluga
if (DaneBoard[PolePlansza.X,PolePlansza.y].pole='E1')and(ZnajdzPolebyXY(X,Y)='C1')
and (DadBierka^.rodzaj='krol') then
begin
    WykonajRuch('A1','D1','');
        ruch:=ruch+'roszada';
    czyDopisane:=true;
end;

//sprawdzamy czy gora zrobily roszade krotka
if (DaneBoard[PolePlansza.X,PolePlansza.y].pole='E8')and(ZnajdzPolebyXY(X,Y)='G8')
and (DadBierka^.rodzaj='krol') then
begin
    WykonajRuch('H8','F8','');
        ruch:=ruch+'roszada';
    czyDopisane:=true;
end;

//sprawdzamy czy gora zrobily roszade dluga
if (DaneBoard[PolePlansza.X,PolePlansza.y].pole='E8')and(ZnajdzPolebyXY(X,Y)='C8')
and (DadBierka^.rodzaj='krol') then
begin
    WykonajRuch('A8','D8','');
        ruch:=ruch+'roszada';
    czyDopisane:=true;
end;


  if Board[(Y div 80)+1,(X div 80)+1]<> nil then
FreeAndNil(Board[(Y div 80)+1,(X div 80)+1]);

  DadBierka^.pole:=ZnajdzPolebyXY(X,Y);
  DadBierka^.pozycja := ZnajdzXYbyPole(ZnajdzPolebyXY(X,Y));

     tmp:=DadBierka^;
     Board[PolePlansza.X, PolePlansza.Y] := nil;
     Board[(Y div 80)+1,(X div 80)+1] := tmp;


KolorowanieRuchu.ok:=true;
KolorowanieRuchu.Z:=PolePlansza;
KolorowanieRuchu.NA:=Point((Y div 80)+1,(X div 80)+1);


     if MozliweWPrzelocie.ok=true then  //jezeli w przelocie to bijemy
     begin
          if (DaneBoard[PolePlansza.X, PolePlansza.Y].pole=MozliweWPrzelocie.Z) and
             (DaneBoard[(Y div 80)+1,(X div 80)+1].pole=MozliweWPrzelocie.NA) then
             begin
                  ruch:=ruch+'przelot*'+MozliweWPrzelocie.bite;
                  czyDopisane:=true;
                 p:=ZnajdzIJbyPole(MozliweWPrzelocie.bite);
                 FreeAndNil(Board[p.x, p.y]);
             end;
     end;


{---promocja piona}

//sprawdzamy czy pionek doszedl do konca planszy
if tmp.rodzaj='pion' then
begin

     pionek:=ZnajdzIJByPole(tmp.pole);

     if (pionek.x=1) or (pionek.x=8)then
     begin
         promocja:=TPromocja.Create(Application);
         promocja.ShowModal;
             if promocja.wybor='hetman' then
             begin
             if tmp.kolor='biale' then
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/HetmanBialy.png');
             end
             else
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/HetmanCzarny.png');
             end;
             Board[(Y div 80)+1,(X div 80)+1].rodzaj:='hetman';
             end;
             if promocja.wybor='wieza' then
             begin
             if tmp.kolor='biale' then
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/WiezaBiala.png');
             end
             else
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/WiezaCzarna.png');
             end;
             Board[(Y div 80)+1,(X div 80)+1].rodzaj:='wieza';
             end;
             if promocja.wybor='goniec' then
             begin
             if tmp.kolor='biale' then
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/GoniecBialy.png');
             end
             else
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/GoniecCzarny.png');
             end;
             Board[(Y div 80)+1,(X div 80)+1].rodzaj:='goniec';
             end;
             if promocja.wybor='skoczek' then
             begin
             if tmp.kolor='biale' then
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/SkoczekBialy.png');
             end
             else
             begin
             Board[(Y div 80)+1,(X div 80)+1].obraz.LoadFromFile('img/SkoczekCzarny.png');
             end;
             Board[(Y div 80)+1,(X div 80)+1].rodzaj:='skoczek';
             end;
                      ruch:=ruch+'promocja*'+promocja.wybor;
                      czyDopisane:=true;
             promocja.Free;
     end;

end;



     {---}


  if Ustawienia.KogoRuch='biale' then
  begin
  Ustawienia.KogoRuch:='czarne';
  end
  else
  begin
  Ustawienia.KogoRuch:='biale'
  end;

  {-----}

   CzySzach(Ustawienia.KogoRuch); //jezeli szach to kolorujemy krola

       //pobieramy czas do wyslania
     if Ustawienia.GramKolorem='biale' then
     begin
         czas:=CzasBiale;
     end
     else
     begin
          czas:=CzasCzarne;
     end;

      if CzyDopisane=false then
     ruch:=ruch+'ruch';

    wiadomosc:='011|'+IntToStr(id_partii)+'|'+Ustawienia.GramKolorem+'|'+ruch+'|'+IntToStr(czas)+'|';

    czyDopisane:=false;


  {----}

  ZapiszRuch(DaneBoard[PolePlansza.X, PolePlansza.Y].pole, DaneBoard[(Y div 80)+1,(X div 80)+1].pole, Board[(Y div 80)+1,(X div 80)+1].rodzaj, Board[(Y div 80)+1,(X div 80)+1].kolor, '');

  if CzyMat(Ustawienia.KogoRuch)=true then
  begin
       DAD:=false;
       SetLength(TablicaRuchow, 0);
       MozliweWPrzelocie.ok:=false;
       PaintBox1.Invalidate;
          wiadomosc:=wiadomosc+'mat';
          czyDopisane:=true;
          Send.SendMessage(wiadomosc, true);
  Exit;
  end;

  if CzyPat(Ustawienia.KogoRuch)=true then
  begin
         DAD:=false;
         SetLength(TablicaRuchow, 0);
         MozliweWPrzelocie.ok:=false;
       PaintBox1.Invalidate;
       wiadomosc:=wiadomosc+'remis';
       czyDopisane:=true;
       Send.SendMessage(wiadomosc, true);
  Exit;
  end;

  if (ZostalTylkoKrol('biale')) and (ZostalTylkoKrol('czarne')) then
  begin
         DAD:=false;
         SetLength(TablicaRuchow, 0);
         MozliweWPrzelocie.ok:=false;
       PaintBox1.Invalidate;
       wiadomosc:=wiadomosc+'remis';
       czyDopisane:=true;
       Send.SendMessage(wiadomosc, true);
  Exit;
  end;

  if (CzyRemis('biale')=true) and (CzyRemis('czarne')=true) then
  begin
         DAD:=false;
         SetLength(TablicaRuchow, 0);
         MozliweWPrzelocie.ok:=false;
       PaintBox1.Invalidate;
       wiadomosc:=wiadomosc+'remis';
       czyDopisane:=true;
  Send.SendMessage(wiadomosc, true);
  Exit;
  end;

      if czyDopisane=false then
    wiadomosc:=wiadomosc+'ruch';

    Send.SendMessage(wiadomosc, true);


end
else
begin
DadBierka^.pole:=DaneBoard[PolePlansza.X, PolePlansza.Y].pole;
DadBierka^.pozycja := ZnajdzXYbyPole(DadBierka^.pole);
end;

DAD:=false;
SetLength(TablicaRuchow, 0);
MozliweWPrzelocie.ok:=false;

  end;


  PaintBox1.Invalidate;

end;


{-----  PREZENTACJA  -----}

procedure TForm3.PaintBox1Paint(Sender: TObject);
var
  white:boolean;
  i,j,a:integer;
  t:TRect;
  pole:TPoint;
begin

  {--- rysowanie planszy ---}

  white:=false;

   PaintBox1.Canvas.Pen.Color := clWhite;


  for i:=0 to 7 do
  begin

            if white then
            begin
                white:=false;
            end
            else
            begin
                 white:=true;
            end;

                      for j:=0 to 7 do
                      begin

                           t.Left:=(80*j);
                           t.Top:=(80*i);
                           t.Right:=(80*j)+81;
                           t.Bottom:=(80*i)+81;

                                                if white then
                                                begin
                                                  PaintBox1.Canvas.brush.Color := cl3DLight;
                                                end
                                                else
                                                begin
                                                  PaintBox1.Canvas.brush.Color := clAppWorkspace;
                                                 end;

                            PaintBox1.Canvas.rectangle(t);

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

  { --- kolorujemy ostatni ruch na planszy --- }

if KolorowanieRuchu.ok then
begin

 PaintBox1.Canvas.brush.Color:=clMoneyGreen;

 t.Left:=(80*(KolorowanieRuchu.Z.y-1));
 t.Top:=(80*(KolorowanieRuchu.Z.x-1));
 t.Right:=(80*(KolorowanieRuchu.Z.y-1))+81;
 t.Bottom:=(80*(KolorowanieRuchu.Z.x-1))+81;

 PaintBox1.Canvas.rectangle(t);

  PaintBox1.Canvas.brush.Color:=$009FCA9F;   //clGreen;

 t.Left:=(80*(KolorowanieRuchu.NA.y-1));
 t.Top:=(80*(KolorowanieRuchu.NA.x-1));             //optymalizacja - zrobic to odejmowanie
 t.Right:=(80*(KolorowanieRuchu.NA.y-1))+81;         //przy tworzeniu KolorowanieRuchu
 t.Bottom:=(80*(KolorowanieRuchu.NA.x-1))+81;

 PaintBox1.Canvas.rectangle(t);

end;

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
       PaintBox1.Canvas.brush.Color:=clRed;
       //$006A67FA;

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

end;

procedure TForm3.PoddajPartieClick(Sender: TObject);
begin
  Send.SendMessage('011|'+IntToStr(id_partii)+'|'+Ustawienia.GramKolorem+'|trzy|cztery|Poddaje', true);
end;


procedure TForm3.PrzyjmijRemisClick(Sender: TObject);
begin
    Send.SendMessage('011|'+IntToStr(id_partii)+'|'+Ustawienia.GramKolorem+'|trzy|cztery|PrzyjmujeRemis', true);
end;

procedure TForm3.ZaproponujRemisClick(Sender: TObject);
begin
  ZaproponujRemis.Enabled:=false;
  Send.SendMessage('011|'+IntToStr(id_partii)+'|'+Ustawienia.GramKolorem+'|trzy|cztery|PropozycjaRemisu', true);
end;

procedure TForm3.OdrzucRemisClick(Sender: TObject);
begin

    Send.SendMessage('011|'+IntToStr(id_partii)+'|'+Ustawienia.GramKolorem+'|trzy|cztery|OdrzucamRemis', true);

      PrzyjmijRemis.Visible:=false;
  OdrzucRemis.Visible:=false;

  ZaproponujRemis.Visible:=true;
  PoddajPartie.Visible:=true;
  PartiaInfo.Color:=$003B3B3B;
  PartiaInfo.Caption:='Odrzucono remis';
end;

end.
010|8|0|ZarazStart|GraszBialymi|60|Mlody|5000
010|8|0|ZarazStart|GraszCzarnymi|60|Tester|3000

Od serwera
011|8|BialeStart
011|8|BialeStart
011|8|KoniecCzasu|KoniecCzasuWygralyCzarne
011|8|KoniecCzasu|KoniecCzasuWygralyCzarne

012|8|0|PrzebiegPartii
013|8|0|CzasBiale|CzasCzarne|StartKolor
