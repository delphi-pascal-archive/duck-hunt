unit uSprite;

interface
uses
  Windows,SysUtils,Graphics,Contnrs,uBASS,uStream;

const
  DEFAULT_TRANSPARENT_COLOR = $ff00ff;
  // Resiste au KILL utiliser ForceKill pr le détruire quand même
  INVINCIBLE = 2147483647;
  ALL = 0;
  // sans groupe
  OTHER = -1;
  // quelques groupes vite fait ;)
  DECORATION = 2;
  BACKGROUND = 3;
  FLOOR = 4;
  LIGHT = 5;

  GRAVITY = 255;

  CURRENT_AUDIO_DEVICE = -1;
type
  // type de collision possible avec la zone de dessin
  // déso pr le nom a rallonge mais j'ai pas trouvé mieux ;)
  TTypeCollisionClientRect = (cTop,cBottom,cLeft,cRight,cNothing);

  (*
  Structure permettant d'animer 1 sprite très facilement

  FrameStart =
    Frame de départ de l'animation ,
    comprise entre [0 , fNumberOfFrames [

  FrameEnd =
    Frame de fin d'animation ,
    doit être plus grand que FrameStart et plus petit que fNumberOfFrames

  Speed , Cpt et Delay sont la pour controller la vitesse d'animation du Sprite
  Voir Animate pour plus de détail

  PingPong , si true , quand arrive à FrameEnd , se décremente pour arriver a FrameStart puis repart
  Ex :
  PingPong := false

  FrameStart = 0
  FrameEnd = 5

  Animation :
  0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5

  Si PingPong = True

  0 1 2 3 4 5 4 3 2 1 0 1 2 3 4 5
  *)

  TAnimation = record
    FrameStart: integer;
    FrameEnd  : integer;
    Speed : integer;
    Cpt : integer;
    Delay : integer;
    PingPong : boolean;
    Up : boolean;
    LoadSound : boolean;
    fStream : TBASSStream;
  end;


  (*
   x,y -> coordonées sur l'ecran
   z : quand z=0 , l'object est affiché au plus bas
   Affecter manuellement True à la propriété Sort de TSpriteEngine
   pour forcer le tri selon Z
   Par defaut , chaque fois que l'on ajoute 1 Sprite dans TSpriteEngine
   le vecteur est trié par Z 
  *)

  T3dPoint = record
    X,Y,Z : integer;
  end;

  TSpriteList = class;
  { - TSprite ---------------------------------------------------------- }

  TSprite = class(TObject)

  private
    fTag : Longint;

    // référence vers la liste de sprite comprise dans TSpriteEngine
    // utile pour gérer facilement les collisions vu que chaque sprite
    // connait l'existence de ts les autres sprites !
    fParentList : TSpriteList;

    fCanvas : TCanvas;
    isEnable : boolean;
    fClientRect : TRect;

    fBitmap : TBitmap;
    //http://msdn.microsoft.com/en-us/library/aa452889.aspx
    fBlend : BLENDFUNCTION;

    isEnableAlphaBlend : boolean;

    fRect : TRect;
    fDestRect : TRect;
    fTypeCollisionClientRect : TTypeCollisionClientRect;
    fAnimation : TAnimation;

    fShadowBitmap : TBitmap;
    fCoordShadow : TPoint;
    isShadow : boolean;
    fCoord : T3dPoint;
    fWidth , fHeight : integer;
    fNumberOfFrames : integer;
    fNbframeX,fNbFrameY : integer;
    fIndexFrames : integer;

    fSpeed       : single;
    fDirection   : single;
    _SpCosMul    : integer;
    _SpSinMul    : integer;

    isDead : boolean;
    fVisible : boolean;

    procedure MAJDestRect;
    procedure SetIndexFrames (AIndexFrames : integer);
    procedure SetParentList(AParentList : TSpriteList);

    procedure SetAlpha (AOpaque : byte);
    function GetAlpha : byte;

    procedure SetBitmap (ABitmap : TBitmap);
    procedure MakeShadow;
    procedure SetCanvas (ACanvas : TCanvas);

    procedure SetSingle(index : integer; val : single);
    procedure Move;
    procedure ComputeSPD;
    procedure SetTag (ATag : longint);

    procedure SetClientRect(AClientRect : TRect);
    constructor Create;overload;
  public
    // methode de classe
    class function CountSprite : integer;

    property ParentList : TSpriteList read fParentList;
    property Canvas : TCanvas read fCanvas write SetCanvas;
    property ClientRect : TRect read fClientRect write SetClientRect;
    property TypeCollisionClientRect : TTypeCollisionClientRect read fTypeCollisionClientRect write fTypeCollisionClientRect;
    property Bitmap : TBitmap read fBitmap write SetBitmap;
    property Alpha : byte read GetAlpha write SetAlpha;
    property EnableAlphaBlend : boolean read isEnableAlphaBlend write isEnableAlphaBlend;
    property NumberOfFrames : integer read fNumberOfFrames;
    property IndexFrames : integer read fIndexFrames write SetIndexFrames;
    property Animation : TAnimation read fAnimation;
    property Shadow : boolean read isShadow write isShadow;
    property Coord : T3dPoint read fCoord;
    property Rect : TRect read fRect;
    property DestRect : TRect read fDestRect;
    property Width : integer read fWidth;
    property Height : integer read fHeight;
    property Speed       : single  index 0 read fSpeed       write SetSingle;
    property Direction   : single  index 1 read fDirection   write SetSingle;
    property Dead : boolean read isDead;
    property Tag : longint read fTag write SetTag;

    procedure Hide ;
    procedure Show;

    procedure Kill;
    procedure ForceKill ;
    procedure SetAnimation (AAnimation : TAnimation);overload;
    procedure SetAnimation (AFrameStart,AFrameEnd,ASpeed,ADelay : integer ; APingPong : boolean);overload;
    procedure SetAnimation (AFrameStart,AFrameEnd,ASpeed,ADelay : integer ; APingPong : boolean ; AFileName : String; ALoop: boolean);overload;

    function  isCollide (ASprite : TSprite) : boolean;
    procedure SetCoord (APoint : TPoint);overload;
    procedure SetCoord (X,Y : integer);overload;
    procedure SetZCoord(Z : integer);
    procedure  SetCoordShadow (X,Y : integer);
    destructor Destroy;override;

    procedure CheckClientRect;virtual;
    procedure Progress;virtual;
    procedure Animate;virtual;
    procedure Draw;virtual;

    constructor Create(ABitmap : TBitmap ; AWidth,AHeight : integer);overload;
    constructor Create(AFileName : TFileName;AWidth,AHeight : integer);overload;
  end;

  { - TSpriteList ---------------------------------------------------------- }
  TSpriteList = class(TObjectList)
  protected
    function  Get( Index : Integer ) : TSprite;
    procedure Put( Index : Integer; Item : TSprite );
  public
    property Items[ Index : Integer ] : TSprite read Get write Put; default;
    constructor Create;
  end;

  { - TSpriteEngine ---------------------------------------------------------- }
  TSpriteEngine = class(TObject)
  private
    fCanvas : TCanvas;
    fBackground : TBitmap;
    isBackgroundLoad : boolean;
    isLock : boolean ;
    isEnable : boolean;
    fClientRect : TRect;
    fListSprites : TSpriteList;
    isNeedSort : boolean;
    isTransparent : boolean;
    fTransparentColor : TColor;
    isSupportAlphaBlend : boolean;

    isAutoCapacity : boolean;
    fTag : longint;
    isShowFPS : boolean;
    isShowFocusRect : boolean;
	fBASS : TBASS;

    procedure SetCanvas(ACanvas : TCanvas );

    procedure SetClientRect(AClientRect : TRect);
    function  GetMaxSprite : integer;
    procedure SetTransparentColor (ATransparentColor : TColor);
    procedure SetTransparent(Transparent : boolean);
    function GetCapacity : integer;
    procedure SortZSprites; // trié sur z
    function GetFramePerSecond : integer;

  public
    // me sert juste pour voir les collisions...
    property ShowFocusRect : boolean read isShowFocusRect write isShowFocusRect;

    property ShowFPS : boolean  read isShowFPS write isShowFPS;
    property FPS : integer read GetFramePerSecond;
    property Sort : boolean read isNeedSort write isNeedSort;
    property Transparent : boolean read isTransparent write SetTransparent;
    property TransparentColor : TColor read fTransparentColor write SetTransparentColor;

    property ListSprites : TSpriteList read fListSprites;
    property CountSprite : integer read GetMaxSprite;
    property AutoCapacity : boolean read isAutoCapacity  write isAutoCapacity;
    property Capacity : integer read GetCapacity;
    property Canvas : TCanvas read fCanvas write SetCanvas;
    property ClientRect : TRect read fClientRect write SetClientRect;
    property Tag :longint read fTag write fTag;

    property SupportAlphaBlend : boolean read isSupportAlphaBlend;

    property BASS : TBASS read fBASS;
    procedure SetBackground(ABackground : TBitmap);overload;
    procedure SetBackground(FileName : String);overload;
    
    procedure Clear;overload;
    procedure Clear (ForceKill : boolean);overload;
    procedure RemoveKillSprite;
    procedure AddSprite( Item : TSprite );
    procedure RemoveSprite( Item : TSprite );
    procedure Move;
    procedure Lock;
    procedure Unlock;
    procedure Draw;

    constructor Create(ACanvas : TCanvas;AClientRect : TRect);
    destructor Destroy;override;
  end;


implementation

uses Math,Jpeg,BASS,uSpriteFps;

var
  NbSprite : integer = 0;


{ - Cirec  ---------------------------------------------------------- }
procedure PreMultiply(aBmp: TBitmap);
var PData       : PRGBQuad;
  I, BytesTotal : Integer;
begin
  BytesTotal := aBMP.Width * aBMP.Height;
  If aBmp.PixelFormat = pf32Bit then
  begin
    PData := aBMP.ScanLine[aBMP.Height-1];
    for I := 0 to BytesTotal - 1 do
    begin
      with PData^ do
      begin
      // préparation des pixels avant l'appel a AlphaBlend
      // http://msdn.microsoft.com/en-us/library/ms532306(VS.85).aspx
        RGBRed := (RGBRed * rgbReserved) div 255;
        RGBGreen := (RGBGreen * rgbReserved) div 255;
        RGBBlue := (RGBBlue * rgbReserved) div 255;
      end;
      Inc(PData);
    end;
  end;
end;

Function Bmp24To32(Const aBitmap: TBitmap; Const TrsColor: Cardinal): Boolean;
Var PData : PRGBQuad;
  I, BytesTotal : Integer;
Begin
  Result := False;
  If Not Assigned(aBitmap) Then
    Exit;
  aBitmap.PixelFormat := pf32Bit;
  BytesTotal := aBitmap.Width * aBitmap.Height;
  Try
    Result := True;
    PData := aBitmap.ScanLine[aBitmap.Height-1];
    For I := 0To BytesTotal - 1Do
    Begin
      If Integer(PData^) <> TrsColor Then
        PData^.rgbReserved := 255;
      Inc(PData);
    End;
  Except
    Result := False;
  End;
End;

{ - TSprite ---------------------------------------------------------- }
class function TSprite.CountSprite : integer;
begin
  result := NbSprite ;
end;

constructor TSprite.Create;
begin
  inherited Create;
  fBitmap := TBitmap.Create;

  fBlend.BlendOp:=AC_SRC_OVER;
  fBlend.BlendFlags:=0;
  SetAlpha(255);

  fShadowBitmap := TBitmap.Create;

  isShadow:=false;
  SetCoord(0,0);
  fCoord.Z:=-1;
  SetCoordShadow(1,1);

  fAnimation.fStream := TBASSStream.Create;
  
  // pas d'animation par defaut , frame par defaut = premiere
  // pas de son associé
  SetAnimation(0,0,0,0,false);
  Show;

  Tag := OTHER;
  fTypeCollisionClientRect := cNothing;
  inc(NbSprite,1);
end;

constructor TSprite.Create(ABitmap : TBitmap;AWidth,AHeight : integer);
begin
  self.Create;
  fWidth:=AWidth;
  fHeight:=AHeight;
  SetBitmap(ABitmap);
end;

constructor TSprite.Create(AFileName : TFileName;AWidth,AHeight : integer);
var
  ext : String;
  jpg : TJpegImage;
  Bmp : TBitmap;
begin
  self.Create;

  fWidth:=AWidth;
  fHeight:=AHeight;

  Bmp := TBitmap.Create;
  jpg := TJpegImage.Create;

  if FileExists(AFileName) then begin
    ext := UpperCase(ExtractFileExt(AFileName));

    if(ext = '.BMP') then Bmp.LoadFromFile(AFileName)
    else begin
     if(ext = '.JPG') or (ext='.JPEG') then begin
      jpg.LoadFromFile(AFileName);
      Bmp.Assign(jpg);
    end else
    // format inconnu
     MessageBox(0,'Format non supporté !','Erreur Format',MB_OK);
    end;
  end;

  SetBitmap(Bmp);
  jpg.Free;
  Bmp.Free;
end;

destructor TSprite.Destroy;
begin
  fBitmap.Free;
  fShadowBitmap.Free;
  fAnimation.fStream.Free;
  dec(NbSprite,1);
  inherited Destroy;
end;

procedure TSprite.SetTag (ATag : longint);
begin
  if ATag<>ALL then fTag := ATag;
end;

procedure TSprite.SetParentList(AParentList : TSpriteList);
begin
  fParentList := AParentList;
end;

procedure TSprite.SetCanvas (ACanvas : TCanvas);
begin
  fCanvas := ACanvas;
  isEnable := Assigned(fCanvas);
end;

function TSprite.GetAlpha : byte;
begin
  result := fBlend.AlphaFormat;
end;

procedure TSprite.SetAlpha(AOpaque : byte);
begin
  fBlend.SourceConstantAlpha:=AOpaque;
end;

procedure TSprite.SetBitmap(ABitmap : TBitmap);
begin
  fBitmap.Assign(ABitmap);
   
  fNbframeX:=fBitmap.Width div fWidth;
  fNbFrameY:=fBitmap.Height div fHeight;
  fNumberOfFrames :=fNbframeX*fNbframeY;

  SetIndexFrames(fIndexFrames);

  MakeShadow;
end;

procedure TSprite.MakeShadow;
begin
  fShadowBitmap.Assign(Bitmap);
  fShadowBitmap.Mask(Bitmap.TransparentColor);
end;

procedure TSprite.SetClientRect(AClientRect : TRect);
begin
  fClientRect := AClientRect;
end;

procedure TSprite.SetAnimation (AAnimation : TAnimation);
begin
  fAnimation := AAnimation;
  SetIndexFrames(fAnimation.FrameStart);
end;

procedure TSprite.SetAnimation (AFrameStart,AFrameEnd,ASpeed,ADelay : integer ; APingPong : boolean);
begin
  with fAnimation do begin
   FrameStart:=AFrameStart;
   FrameEnd:=AFrameEnd;
   Speed:=ASpeed;
   // mets à zéro le compteur
   Cpt:=0;
   Delay:=ADelay;
   PingPong := APingPong;
   Up := True;
   LoadSound:=False;
  end;
  SetIndexFrames(fAnimation.FrameStart);
end;

procedure TSprite.SetAnimation (AFrameStart,AFrameEnd,ASpeed,ADelay : integer ; APingPong : boolean ; AFileName : String; ALoop : boolean);
begin
  with fAnimation do begin
   FrameStart:=AFrameStart;
   FrameEnd:=AFrameEnd;
   Speed:=ASpeed;
   // mets à zéro le compteur
   Cpt:=0;
   Delay:=ADelay;
   PingPong := APingPong;
   Up := True;
   
   LoadSound := True;
   fStream.FileName :=AFileName;
   fStream.Loop := ALoop;
   fStream.Play;
   
  end;
  SetIndexFrames(fAnimation.FrameStart);
end;

procedure TSprite.SetIndexFrames (AIndexFrames : integer);
var
  posX : integer;

  posY : integer;
  value : integer;
begin
  fIndexFrames :=AIndexFrames;

  (* si l'index déppasse le nombre d'image(s) en horizontal
    |---------|---------|---------|---------|
    |         |         |         |         |
    |    0    |    1    |    2    |    3    |
    |         |         |         |         |
    |         |         |         |         |
    |---------|---------|---------|---------|
    |         |         |         |         |
    |    4    |    5    |    6    |     7   |
    |         |         |         |         |
    |         |         |         |         |
    |---------|---------|---------|---------|
    |         |         |         |         |
    |         |         |         |         |
    |    8    |    9    |   10    |    11   |
    |         |         |         |         |
    |---------|---------|---------|---------|
    exemple :
    NbFrameX = 4 ;
    l'index Frame = 4 -> fIndexFrame = 4; (on se rend bien compte qu'il faut
    mettre - 1 à NbFrameX (on commence à zero )

    condition -> if 4>3 ->OK , on rentre
    value := 4;
    posY:=0;

    faire tant "Toujours"
      1er :
       [
         value := 4-4 := 0;
         posY := 1

         Condition : 0<4 -> oui, on quitte
         on est bien positionné ...
       ]

    si IndexFrame = 10

    NbFrameX = 4 ;
    l'index Frame = 10 -> fIndexFrame = 10; (on se rend bien compte qu'il faut
    mettre - 1 à NbFrameX (on commence à zero )

    condition -> if 10>3 ->OK , on rentre
    value := 10;
    posY:=0;

    faire tant "Toujours"
      1er :
       [
         value := 10-4 := 6;
         posY := 1

         Condition : 6<4 -> non,
       ]
       2eme :
       [
         value := 6-4 := 2;
         posY := 2

         Condition : 2<4 -> oui , on quitte
         bien positionné ;)
       ]

     
  *)

  if(fIndexFrames > (fNbFrameX-1) ) then begin

    value := fIndexFrames;
    posY:=0;
    while(true) do begin
      dec(value,fNbFrameX);
      inc(posY,1);
      if value <(fNbFrameX) then break;
      if posY > fnbFrameY then break;
    end;
    posX := fWidth * value;
    posY := posY * fHeight;

  end else begin
    posX := fWidth * fIndexFrames;
    posY :=0;
  end;

  with fRect do begin
    Left := posX;
    Right :=posX+fWidth;
    Top:=posY;
    Bottom := posY+fHeight;
  end;
end;

procedure TSprite.Animate;
begin
  // si la vitesse d'animation est = 0 ou plus petite, c'est qu'on ne veut pas animer
  // le sprite, donc pas la peine de calculer le reste pour rien !
  if fAnimation.Speed <= 0 then exit;
  // on incremente le compteur avec la vitesse de l'anim
  inc(fAnimation.Cpt,fAnimation.Speed);
  // si le compteur est encore plus petit que le Delay , on se barre
  if fAnimation.Cpt < fAnimation.Delay then exit;
  // sinon on remet le compteur à zero
  fAnimation.Cpt := 0;

  if not fAnimation.PingPong then begin
    // on incremente la frame
    IndexFrames := IndexFrames + 1;
   // si la frame en cours est plus grande que l'animation , on la remet au debut
   if IndexFrames > fAnimation.FrameEnd then IndexFrames := fAnimation.FrameStart;

  end else begin
    if fAnimation.Up then
     IndexFrames := IndexFrames + 1
    else
     IndexFrames := IndexFrames - 1;
     
    if IndexFrames = fAnimation.FrameEnd then
     fAnimation.Up := False
    else
     if IndexFrames = fAnimation.FrameStart then fAnimation.Up := True;

  end;

end;


procedure TSprite.SetCoordShadow (X,Y : integer);
begin
  fCoordShadow.X:=X;
  fCoordShadow.Y:=Y;
end;

procedure TSprite.ComputeSPD;
var ST,CT : extended;
begin
  SinCos(fDirection,ST,CT);
  _SpCosMul := round(fSpeed * CT);
  _SpSinMul := round(fSpeed * ST);
end;

procedure TSprite.SetSingle(index : integer; val : single);
begin
  case index of
    0 : fSpeed     := val;
    1 : fDirection := DegToRad(val);
  end;
  ComputeSPD;
end;

function TSprite.isCollide(ASprite : TSprite):boolean;
var
  Dummy:TRect;
begin
  Result:=IntersectRect(Dummy,fDestRect,ASprite.DestRect);
end;

procedure TSprite.Kill;
begin
  if fTag<>INVINCIBLE then isDead:=True;
end;

procedure TSprite.ForceKill;
begin
  isDead:=True;
end;
procedure TSprite.MAJDestRect;
begin
  fDestRect.Left := fCoord.X;
  fDestRect.Right := fCoord.X + fWidth;
  fDestRect.Top := fCoord.Y;
  fDestRect.Bottom := fCoord.Y + fHeight;
end;

procedure TSprite.SetCoord(APoint : TPoint);
begin
  fCoord.X := APoint.X;
  fCoord.Y := APoint.Y;
  MAJDestRect;
end;

procedure TSprite.SetCoord (X,Y : integer);
begin
  fCoord.X := X;
  fCoord.Y := Y;
  MAJDestRect;
end;

procedure TSprite.SetZCoord(Z : integer);
begin
  fCoord.Z := Z;
end;


procedure TSprite.Move;
var
x,y : integer;
p : TPoint;
begin
  x := fCoord.X;
  y := fCoord.Y;
  x := x + _SpCosMul;
  y := y + _SpSinMul;
  p.X := x;
  p.Y := y;
  SetCoord(P);
end;

procedure TSprite.CheckClientRect;
begin
  if (fCoord.X > fClientRect.Right - fWidth) then fTypeCollisionClientRect:=cRight
  else
   if (fCoord.X < fClientRect.Left) then fTypeCollisionClientRect := cLeft
    else
     if fCoord.Y > fClientRect.Bottom - fHeight then fTypeCollisionClientRect:=cBottom
      else
       if fCoord.Y < fClientRect.Top then fTypeCollisionClientRect := cTop
        else
         fTypeCollisionClientRect:=cNothing;
end;

procedure TSprite.Progress;
begin
  Move;
  CheckClientRect;
end;

procedure TSprite.Hide ;
begin
  fVisible := false;
end;

procedure TSprite.Show;
begin
  fVisible := true;
end;

procedure TSprite.Draw;
begin
  if not isEnable then exit;
  if not fVisible then exit;
  // on l'anime
  Animate;
  with fCanvas do begin
    if isShadow then
      TransparentBlt(fcanvas.Handle,fDestRect.Left+fCoordShadow.X,fDestRect.Top+fCoordShadow.Y,fWidth,fHeight,fShadowBitmap.Canvas.Handle,fRect.Left,fRect.Top,fWidth,fHeight,fShadowBitmap.TransparentColor);

    if not Bitmap.Transparent then
      CopyRect(fDestRect,fBitmap.Canvas,fRect)
    else begin
      if isEnableAlphaBlend then
        AlphaBlend(fcanvas.Handle,fDestRect.Left,fDestRect.Top,fWidth,fHeight,fBitmap.Canvas.Handle,fRect.Left,fRect.Top,fWidth,fHeight,fBlend)
      else
        TransparentBlt(fcanvas.Handle,fDestRect.Left,fDestRect.Top,fWidth,fHeight,fBitmap.Canvas.Handle,fRect.Left,fRect.Top,fWidth,fHeight,fBitmap.TransparentColor);
    end;
  end;
end;

{ - TSpriteList ---------------------------------------------------------- }
constructor TSpriteList.Create;
begin
  inherited Create(True);
end;

function TSpriteList.Get( Index : Integer ) : TSprite;
begin
  Result := inherited Get( Index );
end;

procedure TSpriteList.Put( Index : Integer; Item : TSprite );
begin
  inherited Put( Index, Item );
end;

{ - TSpriteEngine ---------------------------------------------------------- }

constructor TSpriteEngine.Create(ACanvas : TCanvas;AClientRect : TRect);
begin
  inherited Create;
  fBASS := TBASS.Create(CURRENT_AUDIO_DEVICE,44100,0,0);

  fBASS.VolumeMaster := 1.0;
  fBackground := TBitmap.Create;

  fListSprites := TSpriteList.Create;
  SetCanvas(ACanvas);
  isBackgroundLoad:=false;
  Unlock;

  fClientRect:=AClientRect;
  SetTransparent(True);

  SetTransparentColor(DEFAULT_TRANSPARENT_COLOR);
  isAutoCapacity := True;
  Tag := ALL;
  
  // msdn : Device does not support any of these capabilities.
  if  GetDeviceCaps(ACanvas.Handle,SHADEBLENDCAPS)= 0 then
    isSupportAlphaBlend := false
  else
    isSupportAlphaBlend := true;

  isSupportAlphaBlend := true;

  isNeedSort:=false;
  isShowFPS := false;
end;

destructor TSpriteEngine.Destroy;
begin
  fBass.Free;
  // on efface tous les sprites
  Clear(True);
  fListSprites.Free;
  fBackground.Free;
  inherited Destroy;
end;

procedure TSpriteEngine.SetTransparentColor (ATransparentColor : TColor);
var
  i : integer;
begin
  fTransparentColor:=ATransparentColor;
  for i:=0 to GetMaxSprite -1 do
    fListSprites.Items[i].Bitmap.TransparentColor:=fTransparentColor;
end;

procedure TSpriteEngine.SetTransparent(Transparent : boolean);
var
  i : integer;
begin
  isTransparent:=Transparent;
  for i:=0 to GetMaxSprite -1 do
    fListSprites.Items[i].Bitmap.Transparent:=Transparent;
end;

procedure TSpriteEngine.SetBackground (ABackground : TBitmap);
begin
  fBackground.Assign(ABackground);
  isBackgroundLoad:=True;
end;

procedure TSpriteEngine.SetBackground (FileName : String);
var
  ext : String;
  jpg : TJpegImage;
  Bmp : TBitmap;
begin
  jpg := TJpegImage.Create;
  Bmp := TBitmap.Create;

  if FileExists(FileName) then begin
    ext := UpperCase(ExtractFileExt(FileName));
    if(ext = '.BMP') then bmp.LoadFromFile(FileName)
    else begin
      if(ext = '.JPG') or (ext='.JPEG') then begin
      jpg.LoadFromFile(FileName);
      Bmp.Assign(jpg);
    end else
      // format inconnu
      MessageBox(0,'Format non supporté !','Erreur Format',MB_OK);
    end;
  end;

  fBackground.Assign(Bmp);
  isBackgroundLoad:=True;
  jpg.Free;
  Bmp.Free;
end;

procedure TSpriteEngine.SortZSprites;
  function CompareZ( Item1, Item2 : TSprite ) : Integer;
  begin
    if Item1.Coord.Z < Item2.Coord.Z then
      Result := -1
    else if Item1.Coord.Z > Item2.Coord.Z then
      Result := 1
    else
      Result := 0;
  end;
begin
  fListSprites.Sort( @CompareZ );
end;

procedure TSpriteEngine.AddSprite( Item : TSprite );
begin
  Item.SetCanvas(fCanvas);

  if Item.Bitmap.PixelFormat<>pf32bit then begin

    Item.Bitmap.PixelFormat := pf32bit;
    // si on supporte l'alphablend
    if(isSupportAlphaBlend) then begin
      Item.EnableAlphaBlend := True;
      Item.fBlend.AlphaFormat:=AC_SRC_ALPHA;
      Bmp24To32(Item.Bitmap,fTransparentColor);
      PreMultiply(Item.Bitmap);
    end
     else Item.EnableAlphaBlend := False;

  end
  else
    Item.fBlend.AlphaFormat:=AC_SRC_ALPHA;

  Item.ClientRect := fClientRect;
  Item.SetParentList(fListSprites);
  Item.Bitmap.Transparent:=isTransparent;
  Item.Bitmap.TransparentColor:=fTransparentColor;
  fListSprites.Add(Item);
  isNeedSort:=true;
end;

procedure TSpriteEngine.RemoveSprite( Item : TSprite );
begin
  fListSprites.Remove(TSprite(Item));
end;

function TSpriteEngine.GetMaxSprite : integer;
begin
  result := fListSprites.Count;
end;

procedure TSpriteEngine.Move;
var
  i : integer;
begin
  if not isEnable then exit;
  if fListSprites.Count < 0 then exit;

  for i:=0 to GetMaxSprite-1 do begin
    if not fListSprites.Items[i].Dead then fListSprites.Items[i].Progress;
  end;

  if isNeedSort then
  begin
    SortZSprites;
    isNeedSort := false;
  end;

end;

procedure TSpriteEngine.Lock;
begin
  isLock := true;
end;

procedure TSpriteEngine.Unlock;
begin
  isLock := false;
end;

function TSpriteEngine.GetFramePerSecond : integer;
begin
  result := uSpriteFps.GetFPS;
end;

procedure TSpriteEngine.Draw;
var
  i: integer;
begin
  if not isEnable then exit;
  if fListSprites.Count < 0 then exit;
  uSpriteFps.FPS;
  if islock then exit;
  if(isBackgroundLoad) then fCanvas.StretchDraw(fClientRect,fBackground);
  for i := 0 to GetMaxSprite - 1 do begin
    if not fListSprites.Items[i].Dead then begin
      if fTag = ALL then fListSprites[i].Draw else
       begin
        if fListSprites.Items[i].Tag = fTag then fListSprites[i].Draw;
       end;
    end;
    if isShowFocusRect then DrawFocusRect(fCanvas.Handle,fListSprites.Items[i].DestRect);
  end;
  if isShowFPS then fCanvas.TextOut(5,5,Format('FPS : %d',[GetFramePerSecond]));

end;

procedure TSpriteEngine.SetClientRect(AClientRect : TRect);
var
  i : integer;
begin
  fClientRect := AClientRect;
  for i:=0 to GetMaxSprite-1 do
    fListSprites.Items[i].ClientRect:=fClientRect;
end;

procedure TSpriteEngine.SetCanvas(ACanvas : TCanvas );
begin
  fCanvas := ACanvas;
  isEnable:=Assigned(fCanvas);
end;

procedure TSpriteEngine.Clear (ForceKill : boolean);
var
  i : integer;
begin
  if ForceKill then begin
      for i:=0 to GetMaxSprite-1 do begin
        fListSprites.Items[i].ForceKill;
      end;
      RemoveKillSprite;
  end else
    Clear;
end;

procedure TSpriteEngine.Clear;
var
  i : integer;
begin
  for i:=0 to GetMaxSprite-1 do begin
    fListSprites.Items[i].Kill;
  end;
  RemoveKillSprite;
end;

procedure TSpriteEngine.RemoveKillSprite;
var
  i,max : integer;
begin
  max :=GetMaxSprite;
  // cfr http://www.delphifr.com/forum/sujet-TOBJECTLIST-REMOVE_1261196.aspx?p=2
  // rt15
  for i:= (max - 1) downto 0 do begin
    if fListSprites.Items[i].isDead then fListSprites.Remove(fListSprites.Items[i]);
  end;

  if isAutoCapacity then fListSprites.Capacity := fListSprites.Count;
end;

function TSpriteEngine.GetCapacity : integer;
begin
  result := fListSprites.Capacity;
end;

end.
