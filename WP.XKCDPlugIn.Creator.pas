{===============================================================================
 Author: Danny Wind
 License: Creative Commons CC-BY
===============================================================================}

unit WP.XKCDPlugIn.Creator;

interface

uses
  System.SysUtils, Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  ToolsAPI.WelcomePage, WP.XKCDPlugin.Constants;

type
  TWPXKCDPlugInCreator = class(TInterfacedObject, INTAWelcomePagePlugin,
    INTAWelcomePageContentPluginCreator)
  private
    FWPPluginView: TFrame;
    FIconIndex: Integer;
    { INTAWelcomePageContentPluginCreator }
    function GetView: TFrame;
    function GetIconIndex: Integer;
    procedure SetIconIndex(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    class procedure PlugInStartup;
    class procedure PlugInFinish;
    { INTAWelcomePagePlugin }
    function GetPluginID: string;
    function GetPluginName: string;
    function GetPluginVisible: boolean;
    { INTAWelcomePageContentPluginCreator }
    function CreateView: TFrame;
    procedure DestroyView;
    function GetIcon: TGraphicArray;
  end;

procedure Register;

implementation

uses
  WP.XKCDPlugIn.View;

procedure Register;
begin
  TWPXKCDPlugInCreator.PlugInStartup;
end;

{ TWPDemoPlugInCreator }

function TWPXKCDPlugInCreator.GetPluginID: string;
begin
  Result := sPluginID;
end;

function TWPXKCDPlugInCreator.GetPluginName: string;
begin
  Result := sPluginName;
end;

function TWPXKCDPlugInCreator.GetPluginVisible: boolean;
begin
  Result := True;
end;

constructor TWPXKCDPlugInCreator.Create;
begin
  FIconIndex := -1;
end;

destructor TWPXKCDPlugInCreator.Destroy;
begin
  DestroyView;
  inherited;
end;

function TWPXKCDPlugInCreator.CreateView: TFrame;
(*
begin
  if not Assigned(FWPPluginView) then
    FWPPluginView := TMainFrame.Create(nil);
  Result := FWPPluginView;
end;
*)
var
  LPluginView: INTAWelcomePageCaptionFrame;
  LFrame: TMainFrame;
begin
  if not Assigned(FWPPluginView) then
    FWPPluginView := WelcomePagePluginService.CreateCaptionFrame(sPluginID,
    sPluginName, nil);

  if Supports(FWPPluginView, INTAWelcomePageCaptionFrame, LPluginView) then
  begin
    LFrame := TMainFrame.Create(FWPPluginView);
    LPluginView.SetClientFrame(LFrame);
  end;
  Result := FWPPluginView;
end;

procedure TWPXKCDPlugInCreator.DestroyView;
begin
  FreeAndNil(FWPPluginView);
end;

function TWPXKCDPlugInCreator.GetIcon: TGraphicArray;
begin
  Result := [];
end;

function TWPXKCDPlugInCreator.GetIconIndex: Integer;
begin
  Result := FIconIndex;
end;

procedure TWPXKCDPlugInCreator.SetIconIndex(const Value: Integer);
begin
  FIconIndex := Value;
end;

function TWPXKCDPlugInCreator.GetView: TFrame;
begin
  Result := FWPPluginView;
end;

class procedure TWPXKCDPlugInCreator.PlugInStartup;
begin
  WelcomePagePluginService.RegisterPluginCreator(TWPXKCDPlugInCreator.Create);
end;

class procedure TWPXKCDPlugInCreator.PlugInFinish;
begin
  if Assigned(WelcomePagePluginService) then
    WelcomePagePluginService.UnRegisterPlugin(sPluginID);
end;

initialization

finalization
  TWPXKCDPlugInCreator.PlugInFinish;

end.
