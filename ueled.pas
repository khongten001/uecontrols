{------------------------------------------------------------------------------
  TuELED v1.0 2015-05-15
  Author:Miguel A. Risco-Castillo
  http://ue.accesus.com/uecontrols

  Properties:
  Active:boolean, for On/Off the LED
  Bright:boolean, enable/disable halo (for improve performance)
  Color:TColor, actual color of the LED, automatic darken color for off state
  LedType:ledRound/ledSquare, shape of the LED
  Reflection:boolean, enable 3D/flat effect (for improve performance)

  This software may not be included into library collections and similar compilations
  which are sold. If you want to distribute this code for money then contact me
  first and ask for my permission.

  These copyright notices in the source code may not be removed or modified.
  If you modify and/or distribute the code to any third party then you must not
  veil the original author. It must always be clearly identifiable.

  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in compliance
  with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/MPL-1.1.html

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
  the specific language governing rights and limitations under the License.

------------------------------------------------------------------------------}

unit ueled;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  LCLIntf, LCLType, Types, BGRABitmap, BGRABitmapTypes, uEBase;

type

  TLedType = (ledRound, ledSquare);

{ TuELED }
  TCustomuELED = class(TuEBaseControl)
  private
    FActive: Boolean;
    FColor: TColor;
    FBright : Boolean;
    FReflection : Boolean;
    FLedType : TLedType;
    FOnChange: TNotifyEvent;
    FChanging:Boolean;
    procedure DrawLedRound(const r: integer; const LColor: TColor);
    procedure DrawLedSquare(const r: integer; const LColor: TColor);
    procedure SetActive(AValue:Boolean);
  protected
    class procedure WSRegisterClass; override;
    class function GetControlClassDefaultSize: TSize; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure SetColor(AValue: TColor); override;
    procedure SetBright(Avalue:Boolean); virtual;
    procedure SetReflection(Avalue:Boolean); virtual;
    procedure SetLedType(AValue:TLedType); virtual;
//    procedure DrawControl; override;
    procedure RenderControl; override;
    procedure DoChange; virtual;
    property Active: boolean read FActive write SetActive;
    property LedType: TLedType read FLedType write SetLedType;
    property Bright: boolean read FBright write SetBright;
    property Reflection: boolean read FReflection write SetReflection;
    property Color: tcolor read FColor write SetColor default clDefault;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TuELED = class(TCustomuELED)
  published
    property About;
    property Debug;
    property Active;
    property LedType;
    property Bright;
    property Reflection;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnChange;
    property OnChangeBounds;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnPaint;
    property OnClick;
    property OnConstrainedResize;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  end;


procedure Register;
function Darker(Color:TColor; Percent:Byte):TBGRAPixel;

implementation

constructor TCustomuELED.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable, csCaptureMouse, csClickEvents, csDoubleClicks];
  with GetControlClassDefaultSize do SetInitialBounds(0, 0, CX, CY);
  FChanging:=false;
  FActive:=true;
  FBright:=true;
  FReflection:=true;
  FColor:=clLime;
  FLedType:=ledRound;
end;

//procedure TCustomuELED.DrawControl;
//begin
//  if assigned(Bitmap) then
//  begin
//    Bitmap.Draw(inherited Canvas,0,0,false);
//  end;
//  inherited DrawControl;
//end;

procedure TCustomuELED.Loaded;
begin
  inherited Loaded;
end;

procedure TCustomuELED.Resize;
begin
  inherited Resize;
  RenderControl;
  Invalidate;
  DoChange;
end;

procedure TCustomuELED.SetColor(AValue: TColor);
begin
  if FColor = AValue then exit;
  FColor := AValue;
  RenderControl;
  inherited SetColor(AValue);
  Invalidate;
  DoChange;
end;

procedure TCustomuELED.SetBright(Avalue: Boolean);
begin
  if FBright = AValue then exit;
  FBright := AValue;
  RenderControl;
  Invalidate;
  DoChange;
end;

procedure TCustomuELED.SetReflection(Avalue: Boolean);
begin
  if FReflection = AValue then exit;
  FReflection := AValue;
  RenderControl;
  Invalidate;
  DoChange;
end;

procedure TCustomuELED.SetLedType(AValue: TLedType);
begin
  if FLedType = AValue then exit;
  FLedType := AValue;
  RenderControl;
  Invalidate;
  DoChange;
end;


procedure TCustomuELED.RenderControl;
var r:integer;
begin
  Bitmap.SetSize(width,height);
  Bitmap.Fill(BGRAPixelTransparent);
  if Width < Height then r:=Width else r:=Height;
  r:=r div 10;
  Case FLedType of
    ledSquare : DrawLedSquare(r+2, FColor);
  else
    DrawLedRound(r+3, FColor)
  end;
  inherited RenderControl;
end;

procedure TCustomuELED.DrawLedRound(const r: integer; const LColor: TColor);
var
  mask: TBGRABitmap;
  layer: TBGRABitmap;
begin
  //Bright
  if FActive and FBright then
  begin
    layer:=TBGRABitmap.Create(Width, Height);
    layer.GradientFill(0,0,layer.Width,layer.Height,
                       ColorToBGRA(ColortoRGB(LColor),240),ColorToBGRA(ColortoRGB(LColor),0),
                       gtRadial,PointF(layer.Width/2,layer.Height/2),PointF(0,layer.Height/2),
                       dmSet);
    Bitmap.PutImage(0,0,layer,dmDrawWithTransparency);
    layer.free;
  end;

  // Solid Led
  if FActive then
  begin
    layer:=TBGRABitmap.Create(Width-2*r, Height-2*r);
    layer.GradientFill(0,0,layer.Width,layer.Height,
                       ColorToBGRA(ColortoRGB(LColor)),BGRA(0,0,0),
                       gtRadial,PointF(layer.Width/2,layer.Height*8/15),PointF(layer.Width*1.5,layer.Height*1.5),
                       dmSet);
    mask := TBGRABitmap.Create(layer.Width,layer.Height,BGRABlack);
    mask.FillEllipseAntialias((layer.Width-1)/2,(layer.Height-1)/2,layer.Width/2,layer.Height/2,BGRAWhite);
    layer.ApplyMask(mask);
    mask.Free;
    Bitmap.PutImage(r,r,layer,dmDrawWithTransparency);
    layer.free;
  end else Bitmap.FillEllipseAntialias((Width-1)/2,(Height-1)/2,Width/2-r,Height/2-r, Darker(LColor,80));

  //Reflexion
  if FReflection then
  begin
    layer:=TBGRABitmap.Create((Width-1)-2*r, 5*(Height-2*r) div 8);
    layer.GradientFill(0,0,layer.Width,layer.Height,
                       BGRA(255,255,255,128),BGRA(255,255,255,0),
                       gtLinear,PointF(layer.Width/2,0),PointF(layer.Width/2,layer.Height*6/10),
                       dmSet);
    mask := TBGRABitmap.Create(layer.Width,layer.Height,BGRABlack);
    mask.FillEllipseAntialias(layer.Width/2,layer.Height/2,(layer.Width/2)*(4/5),(layer.Height/2)*(9/10),BGRAWhite);
    layer.ApplyMask(mask);
    mask.Free;
    Bitmap.PutImage(r,r,layer,dmDrawWithTransparency);
    layer.free;
  end;
end;

procedure TCustomuELED.DrawLedSquare(const r: integer; const LColor: TColor);
var
  mask: TBGRABitmap;
  layer: TBGRABitmap;
begin
  //Bright
  if FActive and FBright then
  begin
    layer:=TBGRABitmap.Create(Width, Height);
    layer.GradientFill(0,0,layer.Width,layer.Height,
                       ColorToBGRA(ColortoRGB(LColor),255),ColorToBGRA(ColortoRGB(LColor),0),
                       gtRadial,PointF(layer.Width/2,layer.Height/2),PointF(0,3*layer.Height/4),
                       dmSet);
    Bitmap.PutImage(0,0,layer,dmDrawWithTransparency);
    layer.free;
  end;


  // Solid Led
  if FActive then
  begin
    layer:=TBGRABitmap.Create(Width-2*r, Height-2*r);
    layer.GradientFill(0,0,layer.Width,layer.Height,
                       ColorToBGRA(ColortoRGB(LColor)),BGRA(0,0,0),
                       gtRadial,PointF(layer.Width/2,layer.Height/2),PointF(layer.Width*1.5,layer.Height*1.5),
                       dmSet);
    mask := TBGRABitmap.Create(layer.Width,layer.Height,BGRABlack);
    mask.FillRoundRectAntialias(0,0,layer.Width,layer.Height,r/2,r/2,BGRAWhite);
    layer.ApplyMask(mask);
    mask.Free;
    Bitmap.PutImage(r,r,layer,dmDrawWithTransparency);
    layer.free;
  end else Bitmap.FillRoundRectAntialias(r,r,Width-r,Height-r,r,r, Darker(LColor,80));

  //Reflexion
  if FReflection then
  begin
    layer:=TBGRABitmap.Create((Width-1)-2*r, 5*(Height-2*r) div 8);
    layer.GradientFill(0,0,layer.Width,layer.Height,
                       BGRA(255,255,255,160),BGRA(255,255,255,0),
                       gtLinear,PointF(layer.Width/2,0),PointF(layer.Width/2,layer.Height*6/10),
                       dmSet);
    mask := TBGRABitmap.Create(layer.Width,layer.Height,BGRABlack);
    mask.FillRoundRectAntialias(layer.Width*(1/20),layer.Height*(1/20),layer.Width*(19/20),layer.Height*(19/20),r,r,BGRAWhite);
    layer.ApplyMask(mask);
    mask.Free;
    Bitmap.PutImage(r,r,layer,dmDrawWithTransparency);
    layer.free;
  end;

end;

procedure TCustomuELED.SetActive(AValue: Boolean);
begin
  if AValue <> FActive then
  begin
    FActive := AValue;
    RenderControl;
    Invalidate;
    DoChange;
  end;
end;

class function TCustomuELED.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 24;
  Result.CY := 24;
end;

procedure TCustomuELED.DoChange;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

class procedure TCustomuELED.WSRegisterClass;
begin
  inherited WSRegisterClass;
end;

function Darker(Color:TColor; Percent:Byte):TBGRAPixel;
begin
  Result:=ColorToBGRA(ColorToRGB(Color));
  With Result do
  begin
    red:=red-muldiv(red,Percent,100);  //Percent% closer to black
    green:=green-muldiv(green,Percent,100);
    blue:=blue-muldiv(blue,Percent,100);
  end;
end;

procedure Register;
begin
  {$I ueled_icon.lrs}
  RegisterComponents('uEControls', [TuELED]);
end;

end.


