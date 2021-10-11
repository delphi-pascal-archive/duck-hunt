unit uCursor;

interface
uses
  Windows,uSprite;

type
  TMyCursor = class (TSprite)
  private
    fKillShoot : boolean;
  public
    // pr savoir si le tir est mortel ou pas ...
    // se declenche % à l'explosion (voir uExplosion)
    property KillShoot : boolean read fKillShoot write fKillShoot;
    constructor Create (X,Y : integer);reintroduce;
  end;

implementation
uses uGameDEF;

constructor TMyCursor.Create (X,Y : integer);
begin
  inherited Create(CURSOR_GFX,CURSOR_WIDTH,CURSOR_HEIGHT);
    // la méthode clear n'aura pas d'effet sur lui, IMPORTANT !
  Tag := INVINCIBLE;
  SetZCoord(Z_CURSOR);
  SetCoord(X,Y);
  // a la creation , il n'est pas mortel ...
  fKillShoot := false;
end;

end.

