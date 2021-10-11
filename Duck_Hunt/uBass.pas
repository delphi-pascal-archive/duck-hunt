unit uBass;

interface
uses
  Windows,SysUtils,BASS;

type
  TBASS = class(TObject)
  private
    fWin : HWND;
    function GetVolumeMaster : single;
    procedure SetVolumeMaster(AVolume : single);

    //Stream global volume level... 0 (silent) to 10000 (full).
    function GetVolumeStream : DWORD;
    procedure SetVolumeStream(AVolume : DWORD);
    //volume MOD music global volume level... 0 (silent) to 10000 (full).
    function GetVolumeMusic : DWORD;
    procedure SetVolumeMusic(AVolume : DWORD);

    function GetCPU : single;

    constructor Create;overload;
    function BASS_GetError : PChar;
  public
    property CPU : single read GetCPU;

    property VolumeMaster : single read GetVolumeMaster write SetVolumeMaster;
    property VolumeStream : DWORD read GetVolumeStream write SetVolumeStream;
    property VolumeMusic: DWORD  read GetVolumeMusic write SetVolumeMusic;

    constructor Create(Device : integer;Freq , Flags : DWORD ; Win : HWND);overload;
    destructor Destroy;override;

    procedure Init(Device : integer;Freq , Flags : DWORD ; Win : HWND);
    procedure Start;
    procedure Stop;
    procedure Pause;
  end;


implementation

constructor TBASS.Create;
begin
  inherited Create;
end;

constructor TBASS.Create(Device : integer;Freq , Flags : DWORD ; Win : HWND);
begin
  Create;
  fWin := Win;
  Init(Device,Freq,Flags,fWin);
  // facultatif ... 
  Start;
end;

destructor TBASS.Destroy;
begin
  BASS_Free();
  inherited Destroy;
end;

function TBASS.BASS_GetError : PChar;
var
  msg : PChar;
begin
  msg:='';
  case BASS_ErrorGetCode of
    0 : msg:=PChar('BASS_OK');
    1 : msg:=PChar('BASS_ERROR_MEM');
    2 : msg:=PChar('BASS_ERROR_FILEOPEN');
    3 : msg:=PChar('BASS_ERROR_DRIVER');
    4 : msg:=PChar('BASS_ERROR_BUFLOST');
    5 : msg:=PChar('BASS_ERROR_HANDLE');
    6 : msg:=PChar('BASS_ERROR_FORMAT');
    7 : msg:=PChar('BASS_ERROR_POSITION');
    8 : msg:=PChar('BASS_ERROR_INIT');
    9 : msg:=PChar('BASS_ERROR_START');
    14 : msg:=PChar('BASS_ERROR_ALREADY');
    18 : msg:=PChar('BASS_ERROR_NOCHAN');
    19 : msg:=PChar('BASS_ERROR_ILLTYPE');
    20 : msg:=PChar('BASS_ERROR_ILLPARAM');
    21 : msg:=PChar('BASS_ERROR_NO3D');
    22 : msg:=PChar('BASS_ERROR_NOEAX');
    23 : msg:=PChar('BASS_ERROR_DEVICE');
    24 : msg:=PChar('BASS_ERROR_NOPLAY');
    25 : msg:=PChar('BASS_ERROR_FREQ');
    27 : msg:=PChar('BASS_ERROR_NOTFILE');
    29 : msg:=PChar('BASS_ERROR_NOHW');
    31 : msg:=PChar('BASS_ERROR_EMPTY');
    32 : msg:=PChar('BASS_ERROR_NONET');
    33 : msg:=PChar('BASS_ERROR_CREATE');
    34 : msg:=PChar('BASS_ERROR_NOFX');
    37 : msg:=PChar('BASS_ERROR_NOTAVAIL');
    38 : msg:=PChar('BASS_ERROR_DECODE');
    39 : msg:=PChar('BASS_ERROR_DX');
    40 : msg:=PChar('BASS_ERROR_TIMEOUT');
    41 : msg:=PChar('BASS_ERROR_FILEFORM');
    42 : msg:=PChar('BASS_ERROR_SPEAKER');
    43 : msg:=PChar('BASS_ERROR_VERSION');
    44 : msg:=PChar('BASS_ERROR_CODEC');
    45 : msg:=PChar('BASS_ERROR_ENDED');
    -1 : msg:=PChar('BASS_ERROR_UNKNOWN');
  end;
  result := msg;
end;
function TBASS.GetCPU : single;
begin
  result := BASS_GetCPU();
end;

function TBASS.GetVolumeMaster : single;
begin
  result := BASS_GetVolume()
end;

procedure TBASS.SetVolumeMaster(AVolume : single);
begin
  if not BASS_SetVolume(AVolume) then begin
    MessageBox(fWin,PChar('Erreur : '+BASS_GetError),'Erreur',MB_OK);
  end;
end;

function TBASS.GetVolumeStream : DWORD;
begin
  result := BASS_GetConfig(BASS_CONFIG_GVOL_STREAM);
end;

procedure TBASS.SetVolumeStream(AVolume : DWORD);
begin
  BASS_SetConfig(BASS_CONFIG_GVOL_STREAM,AVolume);
end;

function TBASS.GetVolumeMusic : DWORD;
begin
  result := BASS_GetConfig(BASS_CONFIG_GVOL_MUSIC);
end;

procedure TBASS.SetVolumeMusic(AVolume : DWORD);
begin
  BASS_SetConfig(BASS_CONFIG_GVOL_MUSIC,AVolume);
end;



procedure TBASS.Init(Device : integer;Freq , Flags : DWORD ; Win : HWND);
begin
  if not BASS_Init(Device,Freq,Flags,Win,nil) then begin
    MessageBox(Win,PChar('Erreur : '+BASS_GetError),'Erreur',MB_OK);
    Halt;
  end;
end;

procedure TBASS.Start;
begin
  if not BASS_Start() then begin
    MessageBox(fWin,PChar('Erreur : '+BASS_GetError),'Erreur',MB_OK);
    Halt;
  end;
end;

procedure TBASS.Stop;
begin
  if not BASS_Stop() then begin
    MessageBox(fWin,PChar('Erreur : '+BASS_GetError),'Erreur',MB_OK);
    Halt;
  end;
end;

procedure TBASS.Pause;
begin
  if not BASS_Pause()then begin
    MessageBox(fWin,PChar('Erreur : '+BASS_GetError),'Erreur',MB_OK);
    Halt;
  end;
end;

end.
 