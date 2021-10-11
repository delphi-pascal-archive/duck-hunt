unit uSign;

interface
uses
  Windows,uSprite;
type
  TTypeAnimation  =
  (
   sNEXT_ROUND,
   sFLY_AWAY,
   sGAME_OVER,
   sPERFECT
  ) ;

  TSign = class(TSprite)
  private
    fTypeAnimation : TTypeAnimation;
    procedure SetTypeAnimation(AAnimation : TTypeAnimation );
    procedure CheckAnim;
  public
    constructor Create(AAnimation : TTypeAnimation;X,Y : integer);reintroduce;
    procedure Draw;override;
  end;

implementation
uses uGameDef;

constructor TSign.Create(AAnimation : TTypeAnimation;X,Y : integer);
begin
  inherited Create(SIGN_GFX,SIGN_WIDTH,SIGN_HEIGHT);
  SetTypeAnimation(AAnimation);
  SetCoord(X,Y);
  SetZCoord(Z_SIGN);
end;

procedure TSign.SetTypeAnimation(AAnimation : TTypeAnimation );
begin
  fTypeAnimation := AAnimation;
  case fTypeAnimation of
    sNEXT_ROUND :SetAnimation(1,1,1,350,false);
    sFLY_AWAY :SetAnimation(0,0,1,100,false);
    sGAME_OVER : SetAnimation(2,2,1,350,false);
    sPERFECT : SetAnimation(3,3,1,350,false);
  end;
end;

procedure TSign.CheckAnim;
begin
  // quand le compteur est egale au delay , on le kill (voir uSprite pr bien comprendre...)
  if Animation.Cpt >= Animation.Delay-1 then Kill;
end;

procedure TSign.Draw;
begin
  CheckAnim;
  inherited Draw;
end;


end.

