program DuckHunt;

uses
  Forms,
  uMain in 'uMain.pas' {DuckForm},
  uDuck in 'uDuck.pas',
  uDog in 'uDog.pas',
  uSign in 'uSign.pas',
  uGameDEF in 'uGameDEF.pas',
  uGround in 'uGround.pas',
  uCursor in 'uCursor.pas',
  uExplosion in 'uExplosion.pas',
  uSpriteXY in 'uSpriteXY.pas',
  uSpriteText in 'uSpriteText.pas',
  uSprite in 'uSprite.pas',
  uSpriteFPS in 'uSpriteFPS.pas',
  Bass in 'Bass.pas',
  uBass in 'uBass.pas',
  uAudioEngine in 'uAudioEngine.pas',
  uStream in 'uStream.pas';
{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Duck Hunt Delphi';
  Application.CreateForm(TDuckForm, DuckForm);
  Application.Run;
end.
