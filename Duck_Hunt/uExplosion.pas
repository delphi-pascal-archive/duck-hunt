unit uExplosion;

interface
uses
  Windows,uSprite;
type
  TTypeAnimation  = (REAL_EXPLODE) ;

  TExplosion = class(TSprite)
  private
    fTypeAnimation : TTypeAnimation;
    procedure CheckAlpha;
    procedure SetTypeAnimation(AAnimation : TTypeAnimation );
    procedure CheckAnim;
  public
    constructor Create(AAnimation : TTypeAnimation;X,Y : integer);reintroduce;
    procedure Draw;override;
  end;

implementation
uses uMain,uGameDef;

constructor TExplosion.Create(AAnimation : TTypeAnimation;X,Y : integer);
begin
  inherited Create(EXPLOSION_GFX,64,64);
  SetTypeAnimation(AAnimation);
  SetCoord(X,Y);
  SetZCoord(500);
  uMain.fCursor.KillShoot := True;
end;

procedure TExplosion.CheckAlpha;
begin
  // au fur et a mesure de l'animation , l'explosion devient invisible
  // effet plus ou moins réaliste ;)
  Alpha := 255-Round(IndexFrames * ( 255 / (Animation.FrameEnd - Animation.FrameStart)  ));
end;

procedure TExplosion.SetTypeAnimation(AAnimation : TTypeAnimation );
begin
  fTypeAnimation := AAnimation;
  case fTypeAnimation of
    REAL_EXPLODE :
     begin
      SetAnimation(0,14,1,1,false,SON_TIR,false);
     end;
  end;
end;

procedure TExplosion.CheckAnim;
begin
  // seul la premiere frappe est mortelle, le reste c'est de l'animation ...
  // mettez true pour comprendre !
  if IndexFrames > Animation.FrameStart -1  then begin
    uMain.fCursor.KillShoot := false;
  end;

  if IndexFrames > Animation.FrameEnd-1 then Hide;
  if Animation.fStream.IsStoped then Kill;

end;

procedure TExplosion.Draw;
begin
  CheckAlpha;
  CheckAnim;
  inherited Draw;
end;


end.
 