object DuckForm: TDuckForm
  Left = 227
  Top = 136
  BorderStyle = bsNone
  Caption = 'Delphi Duck Hunt'
  ClientHeight = 774
  ClientWidth = 1068
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnPaint = FormPaint
  PixelsPerInch = 120
  TextHeight = 16
  object Timer1: TTimer
    Interval = 15
    OnTimer = Timer1Timer
    Left = 40
    Top = 32
  end
end
