{------------------------------------------------------------------------------
  uEBase v1.0  2015-05-17
  Author: Miguel A. Risco-Castillo
  http://ue.accesus.com/uecontrols

  Base unit for uE Controls

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

unit uEBase;
{$mode objfpc}{$H+}

interface

uses
  Dialogs,
  Classes, SysUtils, Controls, LCLProc, Graphics, BGRABitmap, BGRABitmapTypes;

const
  cAbout='uEControls v6.0 (c) Miguel A. Risco-Castillo'+LineEnding+'http://ue.accesus.com/uecontrols';

type

  { TuEBaseControl }

  TuEBaseControl = class(TGraphicControl)
  private
    FAbout:string;
    FDebug:boolean;
    FUpdateCount: Integer;
    function GetAbout: string;
    procedure SetDebug(AValue: boolean);
  protected
    procedure DoOnResize; override;
    function DestRect: TRect; virtual;
    procedure Paint; override;
    procedure DrawControl; virtual;
    procedure RenderControl; virtual;
  public
    Bitmap: TBGRABitmap;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    procedure UpdateControl; virtual;
    procedure ReDraw; virtual;
    function IsUpdating: Boolean;
//  This property allow to use rulers for properly alignment of images
    property Debug:boolean read FDebug write SetDebug;
//  uEControls v6.0 (c) Miguel A. Risco-Castillo http://ue.accesus.com/uecontrols'
    property About:string read FAbout;
  end;

{support}

procedure AssignFontToBGRA(Source: TFont; Dest: TBGRABitmap);
procedure AssignBGRAtoImage(Source:TBGRABitmap; Image:TBitmap);

implementation

{ TuEBaseControl }

function TuEBaseControl.GetAbout: string;
begin
  Result:=About;
end;

procedure TuEBaseControl.SetDebug(AValue: boolean);
begin
  if FDebug=AValue then Exit;
  FDebug:=AValue;
  RenderControl;
  invalidate;
end;

procedure TuEBaseControl.DoOnResize;
begin
  inherited DoOnResize;
  RenderControl;
end;

function TuEBaseControl.DestRect: TRect;
begin
  Result:=Rect(0,0,ClientWidth,ClientHeight);
end;

procedure TuEBaseControl.Paint;
begin
  inherited Paint;
  if (csCreating in FControlState) or IsUpdating then Exit;
  DrawControl;
end;

procedure TuEBaseControl.DrawControl;
var R:TRect;
  procedure DrawFrame;
  begin
    with inherited Canvas do
    begin
      Pen.Color := clBlack;
      Pen.Style := psDash;
      MoveTo(0, 0);
      LineTo(Self.Width-1, 0);
      LineTo(Self.Width-1, Self.Height-1);
      LineTo(0, Self.Height-1);
      LineTo(0, 0);
    end;
  end;
  procedure DrawRuler;
  begin
    with inherited Canvas do
    begin
      Pen.Color := clRed;
      Pen.Style := psDot;
      MoveTo(0, 0);
      LineTo(Self.Width-1, 0);
      LineTo(Self.Width-1, Self.Height-1);
      LineTo(0, Self.Height-1);
      LineTo(0, 0);
      MoveTo(round(Self.Width/2)-1,0);
      LineTo(round(Self.Width/2)-1,Self.Height-1);
      MoveTo(0,round(Self.Height/2)-1);
      LineTo(Self.Width-1,round(Self.Height/2)-1);
    end;
  end;
begin
  if assigned(Bitmap) then
  begin
    R:=DestRect;
    Bitmap.Draw(Canvas,R,false);
  end;
  if csDesigning in ComponentState then DrawFrame;
  if FDebug then DrawRuler;
end;

procedure TuEBaseControl.RenderControl;
var
  xc,yc:extended;
  w,h:integer;
begin
  if not FDebug then exit;
  xc:=Width/2;
  yc:=Height/2;
  w:=Bitmap.width;
  h:=Bitmap.height;
  xc:=w/2;
  yc:=h/2;
  Bitmap.XorHorizLine(0,round(yc)-1,w-1,ColorToBGRA(clRed));
  Bitmap.XorVertLine(round(xc)-1,0,h-1,ColorToBGRA(clRed));
  Bitmap.Rectangle(0,0,w,h,ColorToBGRA(clRed),dmXor);
end;

constructor TuEBaseControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDebug:=false;
  FAbout:=cAbout;
  Bitmap:=TBGRABitmap.Create(width,height);
end;

destructor TuEBaseControl.Destroy;
begin
  if Assigned(Bitmap) then FreeAndNil(BitMap);
  inherited Destroy;
end;

procedure TuEBaseControl.BeginUpdate;
begin
  FUpdateCount += 1;
end;

procedure TuEBaseControl.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    FUpdateCount -= 1;
    if FUpdateCount=0 then
      UpdateControl;
  end;
end;

procedure TuEBaseControl.UpdateControl;
begin
  Invalidate;
end;

function TuEBaseControl.IsUpdating: Boolean;
begin
  Result := FUpdateCount>0;
end;

procedure TuEBaseControl.ReDraw;
begin
  RenderControl;
  Invalidate;
end;

{support}
procedure AssignFontToBGRA(Source: TFont; Dest: TBGRABitmap);
begin
  Dest.FontAntialias := True;

  Dest.FontName := Source.Name;
  Dest.FontStyle := Source.Style;
  Dest.FontOrientation := Source.Orientation;

  case Source.Quality of
    fqNonAntialiased: Dest.FontQuality := fqSystem;
    fqAntialiased: Dest.FontQuality := fqFineAntialiasing;
    fqProof: Dest.FontQuality := fqFineClearTypeRGB;
    fqDefault, fqDraft, fqCleartype, fqCleartypeNatural: Dest.FontQuality :=
        fqSystemClearType;
  end;

  Dest.FontHeight := -Source.Height;
end;

procedure AssignBGRAtoImage(Source: TBGRABitmap; Image: TBitmap);
var TempBitmap:TBitmap;
begin
  try
    TempBitmap := TBitmap.Create;
    With TempBitmap
    do begin
      PixelFormat:=pf32bit;
      SetSize(Source.Width,Source.Height);
      Canvas.Pixels[0,0]:=clblack;
    end;
    Source.Draw(TempBitmap.Canvas,0,0);
    Image.Assign(TempBitmap);
  finally
    FreeThenNil(TempBitmap);
  end;
end;


end.

