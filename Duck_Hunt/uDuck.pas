unit uDuck;

interface
uses
  Windows,SysUtils,uSprite,uSpriteText,uStream;

type
  TTypeDuck =
  (
   BLUE ,
   BLACK ,
   BROWN
  );
  TTypeAnimation  =
  (
    FLY_UP,
    FLY_DOWN,
    FLY_RIGHT,
    FLY_LEFT,
    FLY_U_RIGHT,
    FLY_U_LEFT,
    FLY_D_RIGHT,
    FLY_D_LEFT,
    FLY_AWAY ,
    DEAD_RIGHT,
    DEAD_LEFT,
    FALLING
  );

  TDuck = class (TSprite)

  private
    fVitesse : integer;
    fNbCycleNothing : integer;
    fCountFlyAway : integer;
    fMaxFlyAway : integer;
    fTypeDuck : TTypeDuck;
    fTypeAnimation : TTypeAnimation;
    SpritePtText : TSpriteText;
    fPoint : integer;
    procedure SetTypeAnimation (AAnimation : TTypeAnimation);
    procedure CollisionClientRect ;
    procedure Collide;
    procedure CheckAnim;
  public
    constructor Create (ATypeDuck : TTYpeDuck ; X,Y : integer);reintroduce;
    destructor Destroy ; override;
    procedure GetRandomTypeAnimation;
    procedure Progress; override;
  end;
const
  MIN_CYCLE_FLY_AWAY = 10;
  MIN_CYCLE_NOTHING = 30;
implementation

uses uMain,uExplosion,uSign,uGameDEF;

constructor TDuck.Create(ATypeDuck : TTYpeDuck ; X,Y : integer);
begin
  fTypeDuck := ATypeDuck;
  //chaque type de canard est différent...
  case fTypeDuck of
    BLUE :
     begin
      inherited Create (BLUE_DUCK_GFX,DUCK_WIDTH,DUCK_HEIGHT);
      fVitesse := 7;
      fMaxFlyAway := MIN_CYCLE_FLY_AWAY + Random(MIN_CYCLE_FLY_AWAY div 2);
      fPoint:=POINT_BLUE_DUCK;
     end;
    BLACK :
     begin
      inherited Create (BLACK_DUCK_GFX,DUCK_WIDTH,DUCK_HEIGHT);
      fVitesse := 8;
      fMaxFlyAway := MIN_CYCLE_FLY_AWAY;
      fPoint:=POINT_BLACK_DUCK;
     end;
    BROWN :
     begin
      inherited Create (BROWN_DUCK_GFX,DUCK_WIDTH,DUCK_HEIGHT);
      fVitesse := 10;
      fMaxFlyAway := MIN_CYCLE_FLY_AWAY div 2;
      fPoint:=POINT_BROWN_DUCK;
     end;
  end;  
  Randomize;
  SetCoord(X,Y);
  GetRandomTypeAnimation;
  fCountFlyAway := 0;
  fNbCycleNothing := 0;
  SetZCoord(Z_DUCK);
  // pr afficher les points qu'il rapporte quand il se fait tué
  SpritePtText := TSpriteText.Create('X000X',0,0,RGB(255,255,255));
  SpritePtText.Hide;
  SpritePtText.SetZCoord(Z_SIGN);
end;

destructor TDuck.Destroy;
begin
  // on kill le texte des points
  SpritePtText.Kill;
  // on detruit notre sprite
  inherited Destroy;
end;
// ca me semble assez clair ;)
procedure TDuck.GetRandomTypeAnimation;
var
 i : integer;
begin
  i := Random(8);
  case i of
   1 : SetTypeAnimation(FLY_UP);
   2 : SetTypeAnimation(FLY_DOWN);
   3 : SetTypeAnimation(FLY_LEFT);
   4 : SetTypeAnimation(FLY_RIGHT);
   5 : SetTypeAnimation(FLY_U_RIGHT);
   6 : SetTypeAnimation(FLY_U_LEFT);
   7 : SetTypeAnimation(FLY_D_RIGHT);
   8 : SetTypeAnimation(FLY_D_LEFT);
  end;
end;

// on definit les <> type d'animation ...
// penible a faire !
procedure TDuck.SetTypeAnimation( AAnimation : TTypeAnimation);
begin
  fTypeAnimation:= AAnimation;
  case fTypeAnimation of
    FLY_UP :
     begin
      Speed := -fVitesse;
      Direction := 90;
      SetAnimation(12,14,1,5,True,CANARD_VOLE_SOUND,false);
     end;
    FLY_AWAY :
     begin
      Speed := -fVitesse *2;
      Direction := 90;
      SetAnimation(12,14,1,5,True,CANARD_VOLE_SOUND,false);
     end;

    FLY_DOWN:
     begin
      Speed := fVitesse;
      Direction := 90;
      SetAnimation(15,17,1,5,True,CANARD_VOLE_SOUND,false);
     end;
    FLY_RIGHT:
     begin
      Speed := fVitesse;
      Direction := 0;
      SetAnimation(0,2,1,5,True,CANARD_VOLE_SOUND,false);
     end;
    FLY_LEFT:
     begin
      Speed := -fVitesse;
      Direction := 0;
      SetAnimation(3,5,1,5,True,CANARD_VOLE_SOUND,false);
     end;
    FLY_U_RIGHT:
     begin
      Speed := fVitesse;
      Direction := -45;
      SetAnimation(6,8,1,5,True,CANARD_VOLE_SOUND,false);
     end;
    FLY_U_LEFT:
     begin
      Speed := -fVitesse;
      Direction := 45;
      SetAnimation(9,11,1,5,True,CANARD_VOLE_SOUND,false);
     end;
     FLY_D_RIGHT:
     begin
      Speed := fVitesse;
      Direction := 45;
      SetAnimation(6,8,1,5,True,CANARD_VOLE_SOUND,false);
     end;
    FLY_D_LEFT:
     begin
      Speed := -fVitesse;
      Direction := -45;
      SetAnimation(9,11,1,5,True,CANARD_VOLE_SOUND,false);
     end;

     DEAD_RIGHT:
     begin
      Speed := 0;
      SetAnimation(18,18,1,10,false);
     end;

    DEAD_LEFT:
     begin
      Speed := 0;
      SetAnimation(23,23,1,10,false);
     end;

    FALLING:
     begin
      Speed := fVitesse*2;
      Direction := 90;
      SetAnimation(19,22,1,5,True,CANARD_TOMBE_SOUND,false);
     end;
  end;
end;

procedure TDuck.CollisionClientRect;
var
  i,e : integer;
  SolStream : TBASSStream;
begin
  (*
      en bas , on ne peut pas se servir de cBottom car cBottom represente la zone de dessin
      la collision doit se faire sur le sol ...
      
     choix : en haut , en haut a droite , en haut à gauche , a gauche , a droite
     total = 5
     *)

  for e:=0 to ParentList.Count-1 do begin
   // si on touche le sol 
    if (ParentList.Items[e].ClassName = 'TGround') and (isCollide(ParentList.Items[e])) then begin
      // si il tombe, ca veut dire qu'il a été tué  , donc quand il touche le sol
      // on joue le son du sol et on Kill notre Canard

      if fTypeAnimation = FALLING then begin
       if Dead then exit;
       // cjarge et joue le son du sol
       SolStream := TBASSStream.Create(CANARD_SOL_SOUND,false);
       SolStream.Play;
       // modifie le nombre de canard dans le jeu
       uMain.DuckForm.NombreDeCanard:=uMain.DuckForm.NombreDeCanard-1;
       // +1 pr nombre de canard tué
       uMain.DuckForm.NombreDeCanardTue:=uMain.DuckForm.NombreDeCanardTue+1;
       Kill;
       // pas la peine de regarder ces choix il est mort ;)
       Exit;
       if SolStream.IsStoped then SolStream.Free;
    end;

      i := Random(4);
      case i of
        0: SetTypeAnimation(FLY_UP);
        1: SetTypeAnimation(FLY_DOWN);
        2: SetTypeAnimation(FLY_RIGHT);
        3: SetTypeAnimation(FLY_U_RIGHT);
        4: SetTypeAnimation(FLY_U_LEFT);
      end;
    end;
  end;

  case TypeCollisionClientRect of
    (*
      a droite
      choix : En Haut , en Bas , a gauche , en haut a gauche , en bas a gauche
      total = 5
    *)
    cRight :
     begin
      i := Random(4);
      case i of
        0: SetTypeAnimation(FLY_UP);
        1: SetTypeAnimation(FLY_DOWN);
        2: SetTypeAnimation(FLY_LEFT);
        3: SetTypeAnimation(FLY_U_LEFT);
        4: SetTypeAnimation(FLY_D_LEFT);
      end;
    end;
      (*
      a gauche
      choix : a droite, en bas ,en haut , a droite en haut , a droite en bas
      total = 5
       *)
    cLeft :
     begin
      i := Random(4);
      case i of
        0: SetTypeAnimation(FLY_UP);
        1: SetTypeAnimation(FLY_DOWN);
        2: SetTypeAnimation(FLY_RIGHT);
        3: SetTypeAnimation(FLY_U_RIGHT);
        4: SetTypeAnimation(FLY_D_RIGHT);
      end;
    end;
    (* en haut
     choix : en bas , en bas a droite , en bas a gauche , a droite , a gauche
     total = 5
     *)
    cTop :
     begin
      // s'il est en mode "FLY AWAY" , il doit pouvoir "s'echapper "
      if fTypeAnimation = FLY_AWAY then exit;

      inc(fCountFlyAway,1);

      i := Random(4);
      case i of
        0: SetTypeAnimation(FLY_DOWN);
        1: SetTypeAnimation(FLY_D_RIGHT);
        2: SetTypeAnimation(FLY_D_LEFT);
        3: SetTypeAnimation(FLY_RIGHT);
        4: SetTypeAnimation(FLY_LEFT);
      end;
     end;
    // dans le cas improblable ou il toucherait le bas de l'ecran
    cBottom : SetTypeAnimation(FLY_UP);
    cNothing :
     begin
      // s'il est mort , ou s'il tombe , surtout on ne doit ps passer ici
      // il risquerait de ressusciter !
      if (fTypeAnimation = DEAD_LEFT) or (fTypeAnimation = DEAD_RIGHT)
      or (fTypeAnimation = FALLING) then exit;

      // change de position , moins statique !
      if Animation.fStream.IsStoped then GetRandomTypeAnimation;

      inc(fNbCycleNothing,1);

      if fNbCycleNothing>MIN_CYCLE_NOTHING then begin
        fNbCycleNothing:=0;
        // et il pense de plus en plus à se barrer au loin :)
        inc(fCountFlyAway,1);
      end;
     end;
  end;

end;

procedure TDuck.Collide;
begin
  // si on est en collision avec le viseur et qu'il vient de tirer
  if isCollide(uMain.fCursor) and (uMain.fCursor.KillShoot) then begin
    //ca veut dire que le canard est touché
    // plus on le tue rapidement , plus on a de points ...
    // chaque type de canard a ses points particulier ...
    fPoint :=fPoint - (fCountFlyAway * Round(fPoint/MIN_CYCLE_FLY_AWAY));
    if fPoint<0 then fPoint := 5;
    
    uMain.DuckForm.Score := uMain.DuckForm.Score + fPoint;
    SpritePtText.Show;
    SpritePtText.SetCoord(Coord.X,Coord.Y);
    SpritePtText.Text := ' '+IntToStr(fPoint)+' ';
    uMain.SpriteEngine.AddSprite(SpritePtText);
    if (fTypeAnimation = FLY_RIGHT) or (fTypeAnimation = FLY_U_RIGHT) then
      SetTypeAnimation(DEAD_RIGHT)
    else
     SetTypeAnimation(DEAD_LEFT);
  end;
end;

procedure TDuck.CheckAnim;
begin
  // si il est mort
  if (fTypeAnimation = DEAD_LEFT) or (fTypeAnimation = DEAD_RIGHT) then begin
    if Animation.Cpt >= Animation.Delay-1 then SetTypeAnimation(FALLING);
  end else begin

   // si il est en mode "Fly Away "
   if fTypeAnimation = FLY_AWAY then begin
    if Coord.Y < ClientRect.Top -2*Height then begin
     // retire le canard
     uMain.DuckForm.NombreDeCanard := uMain.DuckForm.NombreDeCanard - 1;
     Kill;
    end;
   end;
  end;
end;

procedure TDuck.Progress;
begin
  CollisionClientRect;
  Collide;
  CheckAnim;
  if (fCountFlyAway > fMaxFlyAway) and (fTypeAnimation<>FLY_AWAY) then begin
    uMain.SpriteEngine.AddSprite(TSign.Create(sFLY_AWAY,uMain.SpriteEngine.ClientRect.Right div 2 - SIGN_WIDTH div 2,uMain.SpriteEngine.ClientRect.Top + 2*SIGN_HEIGHT));
    SetTypeAnimation(FLY_AWAY);
  end;
  inherited Progress;
end;

end.
