{
Sprite se balancant de 2 facons :
Soit Horizontalement de XStart a XEnd puis de XEnd a XStart

Soit Verticalement de YStart a YEnd ...

Delta represente la difference de chemin a parcourir

X,Y sont les positions sur l'ecran ou le sprite sera affiché 

Ex : Si X = 0 et Y = 0 , En Haut A Gauche
fTypeDeplacement = tHORIZONTAL

Delta = 115

le sprite se deplacera en Horizontal jusque 115 puis de 115 à 0 et ca continue ...

Vitesse represente la vitesse a laquelle il se deplace , Par defaut = 5
}

unit uSpriteXY;

interface
uses
  Windows,uSprite;

type
  TTypeDeplacement = (
    tHORIZONTAL,
    tVERTICAL
  );

  TSpriteXY = class (TSprite)
  private
    fTypeDeplacement : TTypeDeplacement;
    fDelta : integer;
    fVitesse : integer;
    fPosIni,fPosEnd : integer;
    procedure SetDeplacement(ATypeDeplacement :TTypeDeplacement);
  public
    constructor Create (AFileName : String;Width,Height : integer ;ATypeDeplacement :TTypeDeplacement;X,Y,ADelta : integer);overload;
    constructor Create (AFileName : String;Width,Height : integer ;ATypeDeplacement :TTypeDeplacement;X,Y,ADelta,AVitesse : integer);overload;

    procedure Progress;override;
  end;

implementation
uses uGameDEF;

constructor TSpriteXY.Create (AFileName : String;Width,Height : integer ;ATypeDeplacement :TTypeDeplacement;X,Y,ADelta : integer);
begin
  inherited Create(AFileName,Width,Height);
  SetCoord(X,Y);
  fDelta := ADelta;
  fVitesse :=5;

  SetDeplacement(ATypeDeplacement);
end;

constructor TSpriteXY.Create(AFileName : String;Width,Height : integer ;ATypeDeplacement: TTypeDeplacement; X: Integer; Y: Integer; ADelta: Integer; AVitesse: Integer);
begin
  Create(AFileName,Width,Height,ATypeDeplacement,X,Y,ADelta);
  fVitesse := AVitesse;
  SetDeplacement(ATypeDeplacement);
end;
// chaque type de deplacement a une direction <> , on la definit ici
// de plus on calcule la posInitial et la distance a parcourir
procedure TSpriteXY.SetDeplacement(ATypeDeplacement :TTypeDeplacement);
begin
  fTypeDeplacement:=ATypeDeplacement;
  case fTypeDeplacement of
    tHORIZONTAL :
     begin
      Speed := fVitesse;
      Direction := 0;
      fPosIni:=Coord.X;
      fPosEnd:=Coord.X+fDelta;
     end;
    tVERTICAL :
     begin
      Speed := fVitesse;
      Direction := 90;
      fPosIni:=Coord.Y;
      fPosEnd:=Coord.Y+fDelta;
     end;
  end;
end;

procedure TSpriteXY.Progress;
begin
  case fTypeDeplacement of
    tHORIZONTAL:
     begin
      if Coord.X >(fPosEnd) then
        Speed:=-(Speed)
      else
       if Coord.X<fPosIni then Speed := ABS(Speed);
     end;
    tVERTICAL :
     begin
     if Coord.Y >(fPosEnd) then
        Speed:=-(Speed)
      else
       if Coord.Y<fPosIni then Speed := ABS(Speed);
     end;
  end;

  inherited Progress;
end;

end.
