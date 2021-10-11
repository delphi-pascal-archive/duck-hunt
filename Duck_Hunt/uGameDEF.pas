unit uGameDEF;

interface

const
  // Score
  POINT_PERFECT = 10000;
  POINT_BLUE_DUCK = 50;
  POINT_BLACK_DUCK = 75;
  POINT_BROWN_DUCK = 100;

  //taille
  // seul ceux qui me sont utiles sont dedans ...
  // bientot elle seront tt ici...
  CURSOR_WIDTH = 16;
  CURSOR_HEIGHT = 16;

  DUCK_WIDTH = 76;
  DUCK_HEIGHT = 74;

  LITTLE_DUCK_WIDTH = 31;
  LITTLE_DUCK_HEIGHT = 29;

  GROUND_WIDTH = 60;
  GROUND_HEIGHT = 105;

  GRASS_WIDTH  = 115;
  GRASS_HEIGHT = 69;

  SIGN_WIDTH = 128;
  SIGN_HEIGHT = 64;

  LETTRE_WIDTH = 122;
  LETTRE_HEIGHT = 148;
  
  OPTION_WIDTH = 236;
  OPTION_HEIGHT = 81;

  INFOBAR_WIDTH = 637;
  INFOBAR_HEIGHT = 95;
  
  BARRE_SHOT_WIDTH = 42;
  BARRE_SHOT_HEIGHT = 31;

  BALLE_WIDTH = 5;
  BALLE_HEIGHT = 11;

  // valeur Z
  Z_CURSOR = 8;
  Z_SIGN = 5;
  Z_DOG_WALK = 7;
  Z_INFO_BAR = 6;
  Z_TO_KILL_DUCK = 5;
  Z_BARRE = 4;
  Z_GRASS = 4;
  Z_DOG_OTHER =3;
  Z_DECORATION =2;
  Z_DUCK = 1;
  Z_GROUND = 0;

  // Gfx
  CURSOR_GFX = 'MEDIA\GFX\Cursor.bmp';
  BLUE_DUCK_GFX = 'MEDIA\GFX\BlueDuck.bmp';
  BLACK_DUCK_GFX = 'MEDIA\GFX\BlackDuck.bmp';
  BROWN_DUCK_GFX = 'MEDIA\GFX\BrownDuck.bmp';
  LITTLE_KILL_DUCK = 'MEDIA\GFX\LittleDuck.bmp';
  DOG_GFX = 'MEDIA\GFX\DogSet.bmp';
  EXPLOSION_GFX = 'MEDIA/GFX/Explosion1.bmp';
  SIGN_GFX = 'MEDIA/GFX/Sign.bmp';
  GROUND_GFX ='MEDIA\GFX\Ground.bmp';
  BLUE_BACKGROUND_GFX = 'MEDIA\GFX\BlueBackGround.jpg';
  BLACK_BACKGROUND_GFX = 'MEDIA\GFX\BlackBackGround.jpg';
  GRASS_GFX = 'MEDIA\GFX\Grass.bmp';
  TREE_GFX = 'MEDIA\GFX\Arbre.bmp';
  // :)
  BUSH_GFX ='MEDIA\GFX\Buisson.bmp';
  INFOBAR_GFX = 'MEDIA\GFX\Barre.bmp';
  GAUGE_KILL_GFX = 'MEDIA\GFX\GaugeKill.bmp';
  OPTION_GFX = 'MEDIA\GFX\Menu.bmp';

  BARRE_SHOT_GFX = 'MEDIA\GFX\BarreShot.jpg';
  BALLE_GFX = 'MEDIA\GFX\Balle.bmp';

  D_GFX = 'MEDIA\GFX\D.bmp';
  U_GFX = 'MEDIA\GFX\U.bmp';
  C_GFX = 'MEDIA\GFX\C.bmp';
  K_GFX = 'MEDIA\GFX\K.bmp';
  H_GFX = 'MEDIA\GFX\H.bmp';
  N_GFX = 'MEDIA\GFX\N.bmp';
  T_GFX = 'MEDIA\GFX\T.bmp';

  // SONS 
  CHIEN_FOUND_SOUND ='MEDIA\SND\ChienRamasse.mp3';
  CHIEN_CRY_SOUND ='MEDIA\SND\ChienCry.mp3';
  CHIEN_WALK_SOUND ='MEDIA\SND\chienMarche.mp3';
  CHIEN_JUMP_SOUND ='MEDIA\SND\chienSaute.mp3';

  CANARD_VOLE_SOUND ='MEDIA\SND\CanardVole.mp3';
  CANARD_TOMBE_SOUND ='MEDIA\SND\CanardTombe.mp3';
  CANARD_SOL_SOUND ='MEDIA\SND\CanardSol.mp3';

  INTRO_SOUND ='MEDIA\SND\intro.mp3';
  GAME_OVER_SOUND ='MEDIA\SND\gameover.mp3';

  SON_TIR = 'MEDIA\SND\tir.mp3';
implementation

end.
