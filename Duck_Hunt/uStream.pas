unit uStream;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,BASS;

type
  TBASSStream = class (TObject)
  private
    fStream : HStream;
    fFileName : String;
    fLoop : boolean;
    procedure LoadStream(AFileName : String);
    procedure SetLoop(ALoop : boolean);

  public
    class function  GetNbStream : integer;

    property Loop : boolean read fLoop write SetLoop;
    property FileName : String read fFileName write LoadStream;
    property Stream : HStream read fStream;
    
    constructor Create;overload;
    constructor Create(AFileName : String ; ALoop : boolean);overload;
    destructor Destroy;override;

    procedure Play ;overload;
    procedure Play(Restart:boolean);overload;
    procedure Pause;
    procedure Stop;

    function IsStoped : boolean;
    function IsPlaying : boolean;
    function IsPaused : boolean;

  end;

implementation

var
  NbStream : integer = 0;

class function TBASSStream.GetNbStream : integer;
begin
  result := NbStream;
end;

constructor TBASSStream.Create;
begin
  inherited Create;
  inc(NbStream,1);
end;

constructor TBASSStream.Create(AFileName : String ; ALoop : boolean);
begin
  Create;
  LoadStream(AFileName);
  SetLoop(ALoop);
end;

destructor TBASSStream.Destroy;
begin
  BASS_StreamFree(fStream);
  dec(NbStream,1);
  inherited Destroy;
end;

procedure TBASSStream.LoadStream(AFileName : String);
begin
  if not FileExists(AFileName) then exit;
  BASS_StreamFree(fStream);
  fStream := BASS_StreamCreateFile(false,PChar(AFileName),0,0,0);
end;

procedure TBASSStream.SetLoop(ALoop : boolean);
begin
  fLoop := ALoop;
  if fLoop then
    BASS_ChannelFlags(fStream, BASS_SAMPLE_LOOP, BASS_SAMPLE_LOOP)
  else
    BASS_ChannelFlags(fStream, 0, BASS_SAMPLE_LOOP);
end;


procedure TBASSStream.Play;
begin
  // si le son est joué en ce moment , on quitte
  if isPlaying then exit;
  // on joue le son
  BASS_ChannelPlay(fStream,True);
end;

procedure TBASSStream.Play(Restart:boolean);
begin
  BASS_ChannelPlay(fStream,Restart);
end;

procedure TBASSStream.Stop;
begin
  BASS_ChannelStop(fStream);
end;

procedure TBASSStream.Pause;
begin
  BASS_ChannelPause(fStream);
end;



function TBASSStream.IsStoped : boolean;
begin
  if BASS_ChannelIsActive(fStream) = BASS_ACTIVE_STOPPED then
    result:=true
  else
    result:=false;
end;

function TBASSStream.IsPlaying : boolean;
begin
  if BASS_ChannelIsActive(fStream) = BASS_ACTIVE_PLAYING then
    result:=true
  else
    result:=false;
end;

function TBASSStream.IsPaused : boolean;
begin
  if BASS_ChannelIsActive(fStream) = BASS_ACTIVE_PAUSED then
    result:=true
  else
    result:=false;
end;



end.
