unit uSpriteText;
// Exemple parfait de detournement de la classe TSprite !
interface
uses
  Windows,Graphics,uSprite;

type
  TSpriteText = class (TSprite)
  private
    fText : String;
    fColor : TColor;
    procedure SetText(AText : String);
  public
    property Text : String read fText write SetText;
    constructor Create(AText : String;X,Y : integer ; AColor : TColor);reintroduce;
  end;

implementation
uses uGameDEF;

constructor TSpriteText.Create(AText : String;X,Y : integer;AColor : TColor);
var
  BmpTemp : TBitmap;
begin
  fColor := AColor;
  BmpTemp := TBitmap.Create;
  BmpTemp.Width := BmpTemp.Canvas.TextWidth(AText);
  BmpTemp.Height := BmpTemp.Canvas.TextHeight(AText);

  inherited Create(BmpTemp,BmpTemp.Width,BmpTemp.Height);
  BmpTemp.Free;

  SetText(AText);
  SetCoord(X,Y);
end;

procedure TSpriteText.SetText(AText : String);
begin
  fText := AText;
  Bitmap.Canvas.Brush.Color := fColor;
  Bitmap.Canvas.FillRect(Bitmap.Canvas.ClipRect);
  Bitmap.Canvas.TextOut(0,0,fText);
end;

end.

