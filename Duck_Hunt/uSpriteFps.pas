unit uSpriteFps;
(* Merci Bacterius ;) *)
interface
uses Windows;
  procedure FPS;
  function GetFPS : integer;

implementation
var
  LastT: Integer=0;
  FPSCount: Integer=0;
  FramesPerSecond: Integer=0;

procedure FPS;
var
  T: Integer;
begin
  T := GetTickCount;

  if T-LastT >= 1000 then
  begin
    FramesPerSecond := FPSCount;
    LastT := T;
    fpsCount := 0;
  end
  else
  Inc(FPSCount);
end;

function GetFPS : integer;
begin
  result :=FramesPerSecond;
end;


end.
 