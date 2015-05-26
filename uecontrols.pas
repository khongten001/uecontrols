{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit uEControls;

interface

uses
  uEBase, uERotImage, ueled, uETileImage, uETilePanel, uEKnob, uESelector, 
  uEMultiTurn, uEGauge, uebutton, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uERotImage', @uERotImage.Register);
  RegisterUnit('ueled', @ueled.Register);
  RegisterUnit('uETileImage', @uETileImage.Register);
  RegisterUnit('uETilePanel', @uETilePanel.Register);
  RegisterUnit('uEKnob', @uEKnob.Register);
  RegisterUnit('uESelector', @uESelector.Register);
  RegisterUnit('uEMultiTurn', @uEMultiTurn.Register);
  RegisterUnit('uEGauge', @uEGauge.Register);
  RegisterUnit('uebutton', @uebutton.Register);
end;

initialization
  RegisterPackage('uEControls', @Register);
end.
