unit uAudioEngine;

interface

uses
  Windows,SysUtils,Graphics,Contnrs,BASS,uSprite,uStream;

type

  TAudioEngine = class(TObject)
  private
    // pour la mise a jour des positions des sons 3d
    fSpriteEngine : TSpriteEngine;
    // musique d'"ambience"
    PositionListener : BASS_3DVECTOR;
    procedure MAJ3DSoundSprite(ASprite : TSprite);
    procedure Apply;
  public
    property SpriteEngine : TSpriteEngine read fSpriteEngine write fSpriteEngine;
    constructor Create (Device : integer ; Freq,Win : HWND) ;

    procedure Set3dPositionListener(X,Y : single);
    destructor Destroy;override;
    procedure Rending;
  end;
implementation


constructor TAudioEngine.Create (Device : integer ; Freq ,Win : HWND ) ;
begin
  inherited Create;
  // on active les sons 3d !
  if not BASS_Init(Device,Freq,BASS_DEVICE_3D,Win,0) then begin
    MessageBox(Win,'Impossible d''init BASS','Error',MB_OK);
    halt;
  end;
  fSpriteEngine := nil;
//  Set3dPositionListener(50,50);

end;

destructor TAudioEngine.Destroy;
begin
  inherited Destroy;
end;
procedure TAudioEngine.Set3dPositionListener(X,Y : single);
var
  vel,front,top :BASS_3DVECTOR;
begin
  PositionListener.x:=X;
  PositionListener.y:=Y;
  PositionListener.z:=0; // up and down -> 2d : 0
  BASS_Set3DPosition(PositionListener,vel,front,top);
  Apply;
end;

procedure TAudioEngine.MAJ3DSoundSprite(ASprite : TSprite);
var
  pos,ori,vel : BASS_3DVECTOR;
begin
  pos.x := ASprite.Coord.X;
  pos.y := ASprite.Coord.Y;
  pos.z := 0;

  BASS_ChannelSet3DPosition(ASprite.Animation.fStream.Stream,pos,ori,vel);
  Apply;
end;

procedure TAudioEngine.Apply;
begin
  BASS_Set3DFactors(1.0,0.0,0.0);
  BASS_Apply3D();
end;

procedure TAudioEngine.Rending;
var
  i:integer;
begin
  if fSpriteEngine = nil then exit;

  // on parcourt la liste des sprites
  for i:=0 to fSpriteEngine.CountSprite-1 do begin
    // si il y a un sprite avec 1 son chargé
    if fSpriteEngine.ListSprites.Items[i].Animation.LoadSound then begin
      //MAJ DES POSITIONS
      MAJ3DSoundSprite(fSpriteEngine.ListSprites.Items[i]);
    end;
  end;

  
end;


end.
 