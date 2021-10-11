unit uGround;
// la classe la plus simple !
interface
uses
  Windows,uSprite;

type
  TGround = class (TSprite)
  private
  public
    constructor Create (X,Y : integer);reintroduce;
  end;

implementation
uses uGameDEF;

constructor TGround.Create (X,Y : integer);
begin
  inherited Create(GROUND_GFX,GROUND_WIDTH,GROUND_HEIGHT);
  SetCoord(X,Y);
  SetZCoord(Z_GROUND);
  Show;
end;

end.
 