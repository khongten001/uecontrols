{-------------------------------------------------------------------------------------
  TuETilePanel v1.0  2015-05-20
  Author: Miguel A. Risco-Castillo
  http://ue.accesus.com/uecontrols

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

-------------------------------------------------------------------------------------}
unit uETilePanel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Controls, ExtCtrls, LCLProc, Graphics, uETileImage;

type

  { TuETilePanel }

  { TCustomuETilePanel }

  TCustomuETilePanel = class(TPanel)
  private
    FImage: TBitmap;
    FTile: TuETileImage;
    FAbout: String;
    procedure SetImage(AValue: TBitmap);
    procedure SetTile(AValue: TuETileImage);
  protected
    property About:string read FAbout;
    property Tile: TuETileImage read FTile write SetTile;
    property Image: TBitmap read FImage write SetImage;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TuETilePanel = class(TCustomuETilePanel)
  published
    property About;
    property Image;
    property Tile;
  end;


procedure Register;

implementation

{ TuETilePanel }

procedure TCustomuETilePanel.SetTile(AValue: TuETileImage);
begin
  if FTile=AValue then Exit;
  FTile:=AValue;
end;

procedure TCustomuETilePanel.SetImage(AValue: TBitmap);
begin
  if FImage=AValue then Exit;
  FTile.Image.Assign(AValue);
end;

constructor TCustomuETilePanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTile:=TuETileImage.Create(Self);
  FTile.Parent:=Self;
  FTile.Align:=alClient;
  FAbout:=FTile.About;
  FImage:=FTile.Image;
end;

destructor TCustomuETilePanel.Destroy;
begin
  FreeThenNil(FTile);
  inherited Destroy;
end;

procedure Register;
begin
  {$I uetilepanel_icon.lrs}
  RegisterComponents('uEControls',[TuETilePanel]);
end;


end.

