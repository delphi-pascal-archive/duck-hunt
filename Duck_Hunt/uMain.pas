unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,uSprite,uDuck,uDog,uExplosion,uGround,uStream,uSign,uSpriteXY,uCursor,
  uSpriteText,ExtCtrls;

type
  TState =
  (
    appli_Init,
    appli_NewRound ,
    appli_CptDuck,
    appli_Menu ,
    appli_Game ,
    appli_GameOver ,
    appli_Quit
    );

  TOption =
  (
    OneDuck ,
    TwoDuck
  );

  TDuckForm = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    sSaveWidthScreen,fSaveHeightScreen : integer;
    fState : TState;
    fOption : TOption;
    IntroStream , GameOverStream  : TBASSStream;
    fScore : integer;
    // nombre de canard(s) sur le plateau
    fNbAliveCanard : integer;
    // total canard (1 ou 2 )
    fTotOptionCanard : Integer;
    // nombre total de canard laché pdt le round
    // (doit être = à NB_CANARD_ROUND pr cloturer un Round )
    fTotCanard : integer;
    // nombre de canard(s) tué(s) par laché de canard
    fKillCanardLache : integer;
    // nombre total de canard tué  par Round
    fKillCanardRound : integer;
    // nombre de canard a tué par round , l'objectif a atteindre ...
    fReqCanard : integer;
    // nombre de tir
    fNbTir : integer;
    // numéro du round
    fCptRound : integer;
    // Barre (avec le score , munitions et canards tués
    Barre : TSprite;
    // barre de tir
    BarreShot : TSprite;
    // score 
    ScoreText : TSpriteText;
  public
    property Score : integer read fScore write fScore;
    property NombreDeCanard : integer read fNbAliveCanard write fNbAliveCanard;
    property NombreDeCanardTue : integer read fKillCanardLache write fKillCanardLache;
    procedure SetSize (AWidth , AHeight : integer );

    procedure Init;
    procedure GenerateMAP;
    procedure Menu ;
    procedure NewGame;

    procedure CheckAction ;

    procedure NewRound;
    procedure NewDuck;
    procedure GameOver;

    procedure MAJGaugeShoot;
    procedure Quit;
  end;

const
  NB_CANARD_ROUND = 10;
  // tag special , utile vous verrez ;) 
  TO_DELETE_EACH_ROUND = 5555;
  TO_DELETE_EACH_LACHE = 5556;
var
  DuckForm: TDuckForm;
  SpriteEngine : TSpriteEngine;
  fCursor : TMyCursor ;
implementation

uses Math,uGameDEF;
{$R *.dfm}

//http://delphi.developpez.com/faq/?page=moniteur#changerresolution
//ATTENTION : ne pas mettre une resolution non supporté par l'ecran
// cette fonction ne le detecte pas ! 
Function ChangeResolution(Width,Height:Integer):Boolean;
Var Dev:TDeviceMode;
begin
  Dev.dmPelsWidth := Width;
  Dev.dmPelsHeight:= Height;
  Dev.dmFields     := DM_PELSWIDTH Or DM_PELSHEIGHT;
  Result:=ChangeDisplaySettings(Dev,0)=DISP_CHANGE_SUCCESSFUL;
end;

procedure TDuckForm.SetSize(AWidth , AHeight  : integer);
begin
  if (Screen.Width<>AWidth) or (Screen.Height<>AHeight) then begin
    sSaveWidthScreen:=Screen.Width;
    fSaveHeightScreen:=Screen.Height;
    ChangeResolution(AWidth,AHeight);
  end;
  Width := AWidth;
  Height := AHeight;
  Top := Screen.Height div 2 - Height div 2;
  Left := Screen.Width div 2 - Width div 2;
end;

procedure TDuckForm.Init;
begin
  fState := appli_Init;
  // initialisation à -1
  // si val differente de -1, c'est qu'on a changé la réso de l'écran...
  // servira à remettre comme avant
  sSaveWidthScreen:=-1;
  fSaveHeightScreen:=-1;
  // on cache la souris
  ShowCursor(False);
  // on evite les scintillements
  DoubleBuffered:=True;
  // Par defaut , Plein ecran dans ca resolution
  // le jeu accepte un resolution min de 640x480
  // maximum , y'en a pas , mais le taux de FPS va chuter !
  // NB : pr voir les FPS appuyer sur F1
  SetSize(Screen.Width,Screen.Height);
 // SetSize(640,480);
  //Creation du "moteur "
  SpriteEngine := TSpriteEngine.Create(Canvas,ClientRect);

  //Creation du Curseur (represente le viseur )
  fCursor := TMyCursor.Create(0,0);
  // on l'ajoute
  SpriteEngine.AddSprite(fCursor);

  // On charge la musique d'intro...
  IntroStream := TBASSStream.Create(INTRO_SOUND,false);
  // ... et celle du game over
  GameOverStream := TBASSStream.Create(GAME_OVER_SOUND,false);

  (*Creation du Sprite Text SCORE
   Mais prq ce Score : XXXXXX ...
  Cette classe est loin d'être parfaite mais elle m'a bien dépannée sur le coup
   il faut spécifié au moment de la création la taille maximul que peut avoir
   le texte , d'ou ce SCORE : XXXXXXXX....
   je pourrais faire mieux mais ... ca serat une prochaine fois !
   *)
  ScoreText:=TSpriteText.Create('SCORE : XXXXXXXXXXXX',0,0,RGB(255,255,255));
  // le clear n'aura pas d'effet sur lui 
  ScoreText.Tag := INVINCIBLE;
  SpriteEngine.AddSprite(ScoreText);
end;

procedure TDuckForm.Quit;
begin
  // remet la resolution initiale , si il y a lieu ...
  // voila l'importance de l'ini à -1
  if (sSaveWidthScreen<>-1) or (fSaveHeightScreen<>-1) then begin
    ChangeResolution(sSaveWidthScreen,fSaveHeightScreen);
  end;
  // on libère les ressources
  // NB : ts les Sprites seront libérés que SpriteEngine sera libéré ...
  IntroStream.Free;
  GameOverStream.Free;
  SpriteEngine.Free;
end;

procedure TDuckForm.Menu;
var
  Choix : TSpriteXY;
  Canard1,Canard2,Canard3,Canard4 : TSprite;
  pX,pY : integer;
begin
  if not Assigned(SpriteEngine) then exit;
  // si on vient de gameover ,il se peut qu'on rencontre ce cas
  // donc on coupe la musique de GameOver si elle est jouée
  if GameOverStream.IsPlaying then GameOverStream.Stop;

  fState := appli_Menu;
  // on joue l'intro
  IntroStream.Play;
  // on efface ts les sprites, Rappel : le curseur n'est pas efface
  // car TAG := INVINCIBLE ...
  SpriteEngine.Clear;
  // on cache le score
  ScoreText.Hide;

  // ajout de l'image du menu
  Choix := TSpriteXY.Create(OPTION_GFX,OPTION_WIDTH,OPTION_HEIGHT,tHORIZONTAL,SpriteEngine.ClientRect.Right div 2 - OPTION_WIDTH,SpriteEngine.ClientRect.Bottom - OPTION_HEIGHT - OPTION_HEIGHT div 4 ,OPTION_WIDTH,1);
  SpriteEngine.AddSprite(Choix);
  // arrière plan
  SpriteEngine.SetBackground(BLACK_BACKGROUND_GFX);

  (* on a 4 canards sur la scène pour "animer" 1 peu tout ca...
   Attention , ici les Canards ne sont que des simples Sprites, donc pas des TDuck mais
   bien des TSprite , c'est juste pour faire "beau" et montrer que la fonction
   SetAnimation s'utilise très facilement ;)
  *)
  Canard1 := TSprite.Create(BLACK_DUCK_GFX,DUCK_WIDTH,DUCK_HEIGHT);
  Canard1.SetAnimation(6,8,1,5,True);
  Canard1.SetCoord(SpriteEngine.ClientRect.Left , SpriteEngine.ClientRect.Top);
  SpriteEngine.AddSprite(Canard1);

  Canard2 := TSprite.Create(BLACK_DUCK_GFX,DUCK_WIDTH,DUCK_HEIGHT);
  Canard2.SetAnimation(9,11,1,5,True);
  Canard2.SetCoord(SpriteEngine.ClientRect.Right - Canard2.Width , SpriteEngine.ClientRect.Top);
  SpriteEngine.AddSprite(Canard2);

  Canard3 := TSprite.Create(BROWN_DUCK_GFX,DUCK_WIDTH,DUCK_HEIGHT);
  Canard3.SetAnimation(6,8,1,5,True);
  Canard3.SetCoord(SpriteEngine.ClientRect.Left , SpriteEngine.ClientRect.Bottom - Canard3.Height);
  SpriteEngine.AddSprite(Canard3);

  Canard4 := TSprite.Create(BROWN_DUCK_GFX,DUCK_WIDTH,DUCK_HEIGHT);
  Canard4.SetAnimation(9,11,1,5,True);
  Canard4.SetCoord(SpriteEngine.ClientRect.Right - Canard4.Width , SpriteEngine.ClientRect.Bottom - Canard4.Height);
  SpriteEngine.AddSprite(Canard4);

  // on ecrit Duck Hunt ...
  // c'est une horreur a lire mais c'est parfaitement aligner et ca dans tts les resolutions ...
  pX := SpriteEngine.ClientRect.Right div 2 - (4*LETTRE_WIDTH) + (4*LETTRE_WIDTH) div 2 - DUCK_WIDTH;
  pY := SpriteEngine.ClientRect.Bottom div 2 - (2*LETTRE_HEIGHT) + (2*LETTRE_HEIGHT)div 2 - OPTION_HEIGHT;
  //duck
  SpriteEngine.AddSprite(TSpriteXY.Create(D_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH ,pY,15,1));
  SpriteEngine.AddSprite(TSpriteXY.Create(U_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH + LETTRE_WIDTH ,pY+15,15,1));
  SpriteEngine.AddSprite(TSpriteXY.Create(C_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH + 2*LETTRE_WIDTH,pY,15,1));
  SpriteEngine.AddSprite(TSpriteXY.Create(K_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH + 3*LETTRE_WIDTH,pY+15,15,1));
  //hunt
  SpriteEngine.AddSprite(TSpriteXY.Create(H_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH,pY+LETTRE_HEIGHT+LETTRE_HEIGHT div 4 +15,15,1));
  SpriteEngine.AddSprite(TSpriteXY.Create(U_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH + LETTRE_WIDTH,pY+LETTRE_HEIGHT+LETTRE_HEIGHT div 4 +5,15,1));
  SpriteEngine.AddSprite(TSpriteXY.Create(N_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH + 2*LETTRE_WIDTH,pY+LETTRE_HEIGHT+LETTRE_HEIGHT div 4 +15,15,1));
  SpriteEngine.AddSprite(TSpriteXY.Create(T_GFX,LETTRE_WIDTH,LETTRE_HEIGHT,tVERTICAL,pX+DUCK_WIDTH + 3*LETTRE_WIDTH,pY+LETTRE_HEIGHT+LETTRE_HEIGHT div 4,15,1));
end;

// cree la "map" , le decor
procedure TDuckForm.GenerateMAP;
var
  Arbre : TSprite;
  Buisson : TSprite;
  Grass : TSprite;
  i:integer;
begin
  if not Assigned(SpriteEngine) then exit;
  // on efface tous les sprites
  SpriteEngine.Clear;
  // on change le background
  SpriteEngine.SetBackground(BLUE_BACKGROUND_GFX);

  // le sol
  for I := 0 to SpriteEngine.ClientRect.Right do begin
    if I mod GROUND_WIDTH = 0 then SpriteEngine.AddSprite(TGround.Create(I,SpriteEngine.ClientRect.Bottom - GROUND_HEIGHT));
  end;

  // l'herbe
  for I := 0 to SpriteEngine.ClientRect.Right do begin
    if I mod GRASS_WIDTH = 0  then begin
      Grass := TSprite.Create(GRASS_GFX,GRASS_WIDTH,GRASS_HEIGHT);
      Grass.SetCoord(i,SpriteEngine.ClientRect.Bottom -GROUND_HEIGHT - GRASS_HEIGHT);
      Grass.SetZCoord(Z_GRASS);
      SpriteEngine.AddSprite(Grass);
    end;
  end;

  // l'arbre
  Arbre := TSprite.Create(TREE_GFX,146,260);
  Arbre.SetCoord(SpriteEngine.ClientRect.Right div 20,SpriteEngine.ClientRect.Bottom - Arbre.Height - GROUND_HEIGHT);
  Arbre.SetZCoord(Z_DECORATION);
  SpriteEngine.AddSprite(Arbre);

  // le buisson
  Buisson := TSprite.Create(BUSH_GFX,90,84);
  Buisson.SetCoord(SpriteEngine.ClientRect.Right - SpriteEngine.ClientRect.Right div 20,SpriteEngine.ClientRect.Bottom - Buisson.Height - GROUND_HEIGHT - Buisson.Height div 2);
  Buisson.SetZCoord(Z_DECORATION);
  SpriteEngine.AddSprite(Buisson);

  // la barre d'information
  Barre := TSprite.Create(INFOBAR_GFX,INFOBAR_WIDTH,INFOBAR_HEIGHT);
  Barre.SetZCoord(Z_BARRE);
  Barre.SetCoord(SpriteEngine.ClientRect.Right div 2 - INFOBAR_WIDTH div 2,SpriteEngine.ClientRect.Bottom - INFOBAR_HEIGHT);
  SpriteEngine.AddSprite(Barre);
  //BarreShot
  BarreShot:=TSprite.Create(BARRE_SHOT_GFX,BARRE_SHOT_WIDTH,BARRE_SHOT_HEIGHT);
  BarreShot.SetZCoord(Z_INFO_BAR);
  BarreShot.SetCoord(Barre.Coord.X + BARRE_SHOT_WIDTH div 2,Barre.Coord.Y + BARRE_SHOT_HEIGHT + BARRE_SHOT_HEIGHT div 2);
  SpriteEngine.AddSprite(BarreShot);
  //ScoreText
  ScoreText.SetCoord(Barre.Coord.X + INFOBAR_WIDTH - ScoreText.Width - 5,Barre.Coord.Y + INFOBAR_HEIGHT div 2);
  ScoreText.SetZCoord(Z_INFO_BAR);
  // remise a balc du score
  ScoreText.Text := '  ';
  // on l'affiche 
  ScoreText.Show;
end;

procedure TDuckForm.NewGame;
begin
  // plus simple , c'est impossible ;)
  if IntroStream.IsPlaying then IntroStream.Stop;
  //remise a zero du round  et du score 
  fCptRound:=0;
  fScore:=0;
  // on créer la map
  GenerateMap;
  // on lance un round 
  NewRound;
end;

// 1 Round = NB_CANARD_ROUND
// On peut changer et mettre 30 mais la mise en forme aura de petit defaut ! 
procedure TDuckForm.NewRound;
var
  Dog : TDog;
  i : integer;
  IndicKillDuck : TSprite;
begin
  if not Assigned(SpriteEngine) then exit;
  if not Assigned(Barre) then exit;

  fState := appli_NewRound;
  // signe ROUND
  SpriteEngine.AddSprite(TSign.Create(sNEXT_ROUND,SpriteEngine.ClientRect.Right div 2 - SIGN_WIDTH div 2,SpriteEngine.ClientRect.Top + 2*SIGN_HEIGHT));
  (* on parcours la liste de sprite
   si il y a des elements a virer a chaque round , on le fait
   pas tres beau , mais tres utile
   d'ailleurs c'est a ca que peut servir la variable TAG
   y mettre n'importe quoi !
   *)
  for i:= 0 to SpriteEngine.CountSprite - 1 do begin
    if SpriteEngine.ListSprites.Items[i].Tag = TO_DELETE_EACH_ROUND then SpriteEngine.ListSprites.Items[i].Kill;
  end;
  // selon l'option , il y a 1 ou 2 canars
  case fOption of
    OneDuck :fTotOptionCanard := 1;
    TwoDuck :fTotOptionCanard := 2;
  end;
  // nombre de canard vivant est egale au nombre de canard tot au debut de chaque round
  fNbAliveCanard := fTotOptionCanard;
  // pas encore de canard de tué au laché de canard
  fKillCanardLache:=0;

  fTotCanard :=0;
  // aucun canard de tué par round au debut du round
  fKillCanardRound:=0;

  // on passe au niveau suivant 
  inc(fCptRound,1);
  // le nombre de canard à tuer pdt le round , c'est l'objectif ...
  fReqCanard := fCptRound +1;
  // petit test pr que ce ne soit pas impossible de gagner !
  if fReqCanard >= NB_CANARD_ROUND then fReqCanard:=NB_CANARD_ROUND;

  (* on boucle sur le nombre de canard a tuer (l'objectif)
   on dessine une "gauge" de canard à tuer *)
  for i := 0 to fReqCanard-1 do begin
    IndicKillDuck := TSprite.Create(GAUGE_KILL_GFX,31,2);
    // on la place...
    IndicKillDuck.SetCoord((Barre.Coord.X+180)+ IndicKillDuck.Width*I , (Barre.Coord.Y+50));
    IndicKillDuck.SetZCoord(Z_TO_KILL_DUCK);
    // on sait qu'on doit effacer cette info a chaque round , voir au dessus ...
    IndicKillDuck.Tag := TO_DELETE_EACH_ROUND;
    SpriteEngine.AddSprite(IndicKillDuck);
  end;

  // on créé notre chien chien , qui découvre plein de canards , le chanceux !
  Dog := TDog.Create(WALK,SpriteEngine.ClientRect);
  // voir dog pr le laché de canard ... 
  SpriteEngine.AddSprite(Dog);
  // on ecrit le score (qui peut être <>de 0 à ce moment ... )
  ScoreText.Text := Format('%d',[fScore]);
end;

procedure TDuckForm.MAJGaugeShoot;
var
  i : integer;
  Balle : TSprite;
begin
  (* meme principe que pr les elements a killer a chaque round , sauf qu'ici
  c'est a chaque laché de canard ...*)
  for i:= 0 to SpriteEngine.CountSprite - 1 do begin
    if SpriteEngine.ListSprites.Items[i].Tag = TO_DELETE_EACH_LACHE then SpriteEngine.ListSprites.Items[i].Kill;
  end;
  //Balles
  for i := 0 to fNbTir - 1 do begin
    Balle:=TSprite.Create(BALLE_GFX,BALLE_WIDTH,BALLE_HEIGHT);
    Balle.SetZCoord(Z_INFO_BAR+1);
    Balle.SetCoord(BarreShot.Coord.X + 2*(i*BALLE_WIDTH) + BARRE_SHOT_WIDTH div 2 - (3*BALLE_WIDTH),BarreShot.Coord.Y + BALLE_HEIGHT div 2);
    Balle.Tag := TO_DELETE_EACH_LACHE;
    SpriteEngine.AddSprite(Balle);
  end;
end;
// on lance soit 1 ou 2 canards , ca depend de fOption ... 
procedure TDuckForm.NewDuck;
var
  i:integer;
begin

  if not Assigned(SpriteEngine) then exit;
  if not Assigned (Barre) then exit;
  if not Assigned(BarreShot) then exit;

  fState := appli_Game;
  // le nombre de canard dans la scène est = au nombre de canard total
  // a chaque lancé de canard
  fNbAliveCanard := fTotOptionCanard;
  // pas encore de canard de tué
  fKillCanardLache:=0;
  // 3 tirs seulement
  fNbTir := 3;
  // on creer les balles...
  MAJGaugeShoot;

  (* on cree nos canards
   selon le niveau , se sont des canard bleux , noir , brun
   forcement la difficulté augmente ...*)
  for i:=1 to fTotOptionCanard do begin
   case fCptRound of
    1..2: SpriteEngine.AddSprite(TDuck.Create(BLUE,Random(SpriteEngine.ClientRect.Right),SpriteEngine.ClientRect.Bottom-GROUND_HEIGHT-DUCK_HEIGHT));
    3..6: SpriteEngine.AddSprite(TDuck.Create(BLACK,Random(SpriteEngine.ClientRect.Right),SpriteEngine.ClientRect.Bottom-GROUND_HEIGHT-DUCK_HEIGHT));
    7..10: SpriteEngine.AddSprite(TDuck.Create(BROWN,Random(SpriteEngine.ClientRect.Right),SpriteEngine.ClientRect.Bottom-GROUND_HEIGHT-DUCK_HEIGHT));
   end;
   // on incremente le total de canard laché par round 
   inc(fTotCanard,1);
  end;
end;

// procedure qui prend une decision
procedure TDuckForm.CheckAction;
begin
  if not Assigned(SpriteEngine) then exit;
  // si on a pas laché assez de canard , on en lance encore !
  if fTotCanard < NB_CANARD_ROUND then
    NewDuck
  else begin
  // sinon , c'est qu'on a fini le round
    // si l'objectif est atteint nouveau round
    if fKillCanardRound>=fReqCanard then begin
      // si on fait un perfect, y'a un bonus :) !
      if fKillCanardRound = NB_CANARD_ROUND then begin
        SpriteEngine.AddSprite(TSign.Create(sPERFECT,SpriteEngine.ClientRect.Right div 2 - SIGN_WIDTH div 2,SpriteEngine.ClientRect.Top + SIGN_HEIGHT));
        fScore := fScore + POINT_PERFECT;
      end;
      NewRound;
    end else
  // si l'objectif n'est pas atteint , GameOver !
      GameOver;
  end;
end;

procedure TDuckForm.GameOver;
var
  Dog : TSprite;
begin
  if not Assigned(SpriteEngine) then exit;

  if fState = appli_GameOver then exit;
  // on joue le son Game Over
  GameOverStream.Play;
  // l'etat de l'application est en "Game Over "
  fState := appli_GameOver;

  // signe Game Over
  SpriteEngine.AddSprite(TSign.Create(sGAME_OVER,SpriteEngine.ClientRect.Right div 2 - SIGN_WIDTH div 2,SpriteEngine.ClientRect.Top + 2*SIGN_HEIGHT));

  // Creation d'un sprite du chien , animation = pleure
  Dog := TSprite.Create(DOG_GFX,124,104);
  Dog.SetAnimation(9,10,1,5,false);
  Dog.SetZCoord(Z_DOG_OTHER);
  Dog.SetCoord(SpriteEngine.ClientRect.Right div 2 - Dog.Width div 2,SpriteEngine.ClientRect.Bottom - Dog.Height - 125);
  SpriteEngine.AddSprite(Dog);

end;

procedure TDuckForm.FormCreate(Sender: TObject);
begin
  // on initialise
  Init;
  // on lance le menu
  Menu;
end;

procedure TDuckForm.FormDestroy(Sender: TObject);
begin
  Quit;
end;

procedure TDuckForm.FormPaint(Sender: TObject);
begin
  if Assigned(SpriteEngine) then SpriteEngine.Draw;
end;

procedure TDuckForm.Timer1Timer(Sender: TObject);
var
  Dog : TDog;
  KillDuck : TSprite;
begin
  if not Assigned(SpriteEngine) then exit;
  SpriteEngine.Move;
  // detruit les sprites qui sont "Killer "
  SpriteEngine.RemoveKillSprite;

  // si on joue et qu'il y a plus de canard vivant sur le plateau
  if (fState = appli_Game) and (fNbAliveCanard = 0) then begin
    // permet d'eviter de rentrer dans la boucle ...
    // pas beau non plus mais ca marche assez bien !
    fState := appli_CptDuck;
    // on MAJ le score
    ScoreText.Text := Format('%d',[fScore]);
    // compte le nombre total de canard tué
    inc(fKillCanardRound,fKillCanardLache);
    //ici on teste si on a tué 1 canards , 2 ou zero 
    case fKillCanardLache of
     0 : Dog:=TDog.Create(CRY,SpriteEngine.ClientRect);
     1 :
      begin
        Dog:=TDog.Create(FOUND1,SpriteEngine.ClientRect);
        // canard tué s'ajiute à la "gauge"
        KillDuck := TSprite.Create(LITTLE_KILL_DUCK,LITTLE_DUCK_WIDTH,LITTLE_DUCK_HEIGHT);
        KillDuck.SetCoord((Barre.Coord.X+150)+ LITTLE_DUCK_WIDTH*fKillCanardRound , (Barre.Coord.Y+50));
        KillDuck.SetZCoord(Z_INFO_BAR);
        KillDuck.Tag := TO_DELETE_EACH_ROUND;
        SpriteEngine.AddSprite(KillDuck);
      end;
     2 :
      begin
        Dog:=TDog.Create(FOUND2,SpriteEngine.ClientRect);

        KillDuck := TSprite.Create(LITTLE_KILL_DUCK,LITTLE_DUCK_WIDTH,LITTLE_DUCK_HEIGHT);
        KillDuck.SetCoord((Barre.Coord.X+150)+ LITTLE_DUCK_WIDTH*(fKillCanardRound-1) , (Barre.Coord.Y+50));
        KillDuck.SetZCoord(Z_INFO_BAR);
        KillDuck.Tag := TO_DELETE_EACH_ROUND;
        SpriteEngine.AddSprite(KillDuck);

        KillDuck := TSprite.Create(LITTLE_KILL_DUCK,LITTLE_DUCK_WIDTH,LITTLE_DUCK_HEIGHT);
        KillDuck.SetCoord((Barre.Coord.X+150)+ LITTLE_DUCK_WIDTH*fKillCanardRound , (Barre.Coord.Y+50));
        KillDuck.SetZCoord(Z_INFO_BAR);
        KillDuck.Tag := TO_DELETE_EACH_ROUND;
        SpriteEngine.AddSprite(KillDuck);

      end;
    end;
    SpriteEngine.AddSprite(Dog);
  end;
  // on appel le paint 
  Invalidate;
end;

procedure TDuckForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if not Assigned(SpriteEngine) then exit;

 if ssLeft in shift then begin

  if fState = appli_Game then begin
    if fNbTir = 0 then exit;
    SpriteEngine.AddSprite(TExplosion.Create(REAL_EXPLODE,fCursor.Coord.X - CURSOR_WIDTH div 2,fCursor.Coord.Y - CURSOR_HEIGHT div 2));
    Dec(fNbTir,1);
    MAJGaugeShoot;
  end;


  if fState = appli_Menu then begin
    fOption:=OneDuck;
    NewGame;
  end;
 end
 else begin
  if ssRight in shift then begin
    if fState = appli_Menu then begin
      fOption:=TwoDuck;
      NewGame;
    end;
  end;
 end;
end;

procedure TDuckForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if not Assigned(SpriteEngine) then exit;
  fCursor.SetCoord(X ,Y);
end;

procedure TDuckForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_ESCAPE :
     begin
      if fState <>appli_Menu  then Menu
      else
       if fState = appli_Menu then Close;
     end;
    // pour tester ...
    VK_F1 : SpriteEngine.ShowFPS := not SpriteEngine.ShowFPS;
    VK_F2 : SpriteEngine.Transparent := not SpriteEngine.Transparent;
    VK_F3 : SpriteEngine.ShowFocusRect := not SpriteEngine.ShowFocusRect;

    //VK_PAUSE : Timer1.Enabled := not Timer1.Enabled;
  end;
end;

end.
