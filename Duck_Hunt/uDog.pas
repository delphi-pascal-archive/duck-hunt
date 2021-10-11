unit uDog;

interface
uses
  Windows,uSprite;

type
  TTypeAnimation  =
  (
    FEEL,
    WALK ,
    JUMP ,
    FOUND1,
    FOUND2 ,
    CRY
   ) ;

  TDog = class (TSprite)
  private
    fTypeAnimation : TTypeAnimation;
    procedure SetTypeAnimation (AAnimation : TTypeAnimation);
    constructor Create;overload;
  public
    constructor Create (AAnimation : TTypeAnimation ; AClientRect : TRect) ; overload;
    procedure Progress; override;
  end;


implementation

uses uMain,uDuck,uGameDEF;

constructor TDog.Create;
begin
  inherited Create(DOG_GFX,124,104);
end;

constructor TDog.Create (AAnimation : TTypeAnimation ; AClientRect : TRect) ;
begin
  self.Create;
  ClientRect := AClientRect;
  SetCoord(AClientRect.Right div 2 - Width div 2,AClientRect.Bottom - Height div 2 - GROUND_HEIGHT - GRASS_HEIGHT);
  SetTypeAnimation(AAnimation);
end;

// definit les <>animations...
procedure TDog.SetTypeAnimation (AAnimation : TTypeAnimation);
begin
  fTypeAnimation := AAnimation;
  case fTypeAnimation of
    FEEL :
     begin
      SetZCoord(Z_DOG_WALK);
      Speed := 0;
      Direction := 0;
      SetAnimation(3,4,1,25,false);
     end;
    WALK :
     begin
      SetZCoord(Z_DOG_WALK);
      // on le positionne à gauche en Bas
      SetCoord(0,ClientRect.Bottom -Height - GROUND_HEIGHT div 2);
      // il avance tranquillement
      Speed := 1;
      Direction := 0;
      SetAnimation(0,3,1,5,True,CHIEN_WALK_SOUND,false);
     end;

    JUMP:
     begin
      SetZCoord(Z_DOG_WALK);
      Speed := -5;
      Direction := 90;
      SetAnimation(6,8,1,10,false,CHIEN_JUMP_SOUND,false);
     end;

    FOUND1:
     begin
      SetZCoord(Z_DOG_OTHER);
      Speed := 0;
      Direction := 90;
      SetAnimation(5,5,1,75,false,CHIEN_FOUND_SOUND,false);
     end;

    FOUND2:
     begin
      SetZCoord(Z_DOG_OTHER);
      Speed := 0;
      Direction := 90;
      SetAnimation(11,11,1,75,false,CHIEN_FOUND_SOUND,false);
     end;

    CRY:
     begin
      SetZCoord(Z_DOG_OTHER);
      Speed := 0;
      Direction := 90;
      SetAnimation(9,10,1,5,false,CHIEN_CRY_SOUND,false);
     end;
  end;
end;

procedure TDog.Progress;
begin

  case fTypeAnimation of
    // quand le son de la marche est terminé ou qu'il est arrivé au millieu de l'ecran
    // il sent , puis il saute
    // 2 tests car <> selon la resoluton de l'ecran
    WALK :
     begin
      if (Coord.X > ClientRect.Right div 2 - Width div 2)or(Animation.fStream.IsStoped) then SetTypeAnimation(FEEL);
     end;

    JUMP :
     begin
      // quand l'animation est finie
      if IndexFrames = Animation.FrameEnd  then begin
        // on le cache
        Hide;
        // quand il a fini d'abboyer
        if Animation.fStream.IsStoped then begin
         // on le tue
         Kill;
         //et on regarde quoi faire !
         uMain.DuckForm.CheckAction;
        end;
      end;
     end;
    // idem ...
    FOUND1..FOUND2 :
     begin
      if Animation.fStream.IsStoped  then begin
        if Dead then exit;
        Kill;
        uMain.DuckForm.CheckAction;
      end;
     end;
    CRY :
     begin
      if Animation.fStream.IsStoped then begin
         if Dead then exit;
         Kill;
         uMain.DuckForm.CheckAction;
      end;
     end;
    FEEL :
     begin
      if (IndexFrames = Animation.FrameEnd) and (Animation.Cpt >= Animation.Delay-1) and (Animation.fStream.IsStoped)  then SetTypeAnimation(JUMP);
     end;
   end;
  // ne pas oublier , sinon il avancera pas !
  inherited Progress;
end;
end.
