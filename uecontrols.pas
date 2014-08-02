{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit uEControls; 

interface

uses
  uERotImage, ueled, uEKnob, uESelector, uEMultiTurn, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('uERotImage', @uERotImage.Register); 
  RegisterUnit('ueled', @ueled.Register); 
  RegisterUnit('uEKnob', @uEKnob.Register); 
  RegisterUnit('uESelector', @uESelector.Register); 
  RegisterUnit('uEMultiTurn', @uEMultiTurn.Register); 
end; 

initialization
  RegisterPackage('uEControls', @Register); 
end.
