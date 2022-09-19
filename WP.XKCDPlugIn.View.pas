{===============================================================================
 Author: Danny Wind
 License: Creative Commons CC-BY

 Loads and displays the latest XKCD comic.

 Use of the XKCD comic is allowed by their own license
 (https://xkcd.com/license.html) which is a Creative Commons Attribution
 Non Commercial 2.5 license (https://creativecommons.org/licenses/by-nc/2.5/).
 In their own words:
   "This means that you are free to copy and reuse any of my drawings
    (noncommercially) as long as you tell people where they're from."
 As such please keep the Label in the left corner that shows the XKCD site url
 and allows the end user to see where the comic is form and also allows the
 user to visit the main XKCD page.
===============================================================================}

unit WP.XKCDPlugIn.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.Imaging.pnglang, Vcl.Imaging.jpeg,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  System.JSON, Vcl.WinXCtrls;

type
  TMainFrame = class(TFrame)
    Label1: TLabel;
    Image1: TImage;
    Panel1: TPanel;
    Label2: TLabel;
    ActivityIndicator1: TActivityIndicator;
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
    NetHTTPClient: TNetHTTPClient;
    NetHTTPRequestJSON: TNetHTTPRequest;
    NetHTTPRequestImage: TNetHTTPRequest;
    procedure SetupNetHTTPRequest;
    procedure ExecuteNetHTTPRequest;
  protected
    procedure PaintWindow(DC: HDC); override;
  public
    procedure NetHTTPClientRequestImageCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    procedure NetHTTPClientRequestJSONCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}


{$IFDEF DEBUG}
uses
  WinAPI.ShellAPI;

constructor TMainFrame.Create(AOwner: TComponent);
begin
  inherited;
  SetupNetHTTPRequest;
  ExecuteNetHTTPRequest;
  ActivityIndicator1.Visible := True;
  ActivityIndicator1.Animate := True;
end;

procedure TMainFrame.PaintWindow(DC: HDC);
begin
  inherited;
end;
{$ENDIF}

{$IFNDEF DEBUG}
uses
  WinAPI.ShellAPI, ToolsAPI, ToolsAPI.WelcomePage;

constructor TMainFrame.Create(AOwner: TComponent);
var
  LThemingServices: IOTAIDEThemingServices;
begin
  inherited;
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, LThemingServices) and
    LThemingServices.IDEThemingEnabled then
  begin
    {Color the bottom Panel same as the Windows Frame; grey like XKCD}
    Panel1.StyleElements := Panel1.StyleElements - [seClient];
    Panel1.ParentBackground := False;
    Panel1.Color := LThemingServices.StyleServices.GetSystemColor(clWindowFrame);
    Panel1.BevelOuter := TBevelCut.bvNone;
  end;
  SetupNetHTTPRequest;
  ExecuteNetHTTPRequest;
  Image1.Visible := False;
  ActivityIndicator1.Visible := True;
  ActivityIndicator1.Animate := True;
end;

procedure TMainFrame.PaintWindow(DC: HDC);
const
  cCaptionOpacity = 64;
var
  LCanvas: TCanvas;
  LColor: TColor;
begin
  inherited;
  LCanvas := TCanvas.Create;
  try
    LCanvas.Handle := DC;
    if Assigned(BorlandIDEServices) then
      LColor := (BorlandIDEServices as IOTAIDEThemingServices).StyleServices.GetSystemColor(Color)
    else
      LColor := clNone;
    (WelcomePagePluginService as INTAWelcomePageBackgroundService).PaintBackgroundTo(LCanvas, Self, LColor, cCaptionOpacity);
  finally
    LCanvas.Handle := 0;
    FreeAndNil(LCanvas);
  end;
end;

{$ENDIF}

destructor TMainFrame.Destroy;
begin
  NetHTTPRequestJSON.Free;
  NetHTTPRequestImage.Free;
  NetHTTPClient.Free;
  inherited;
end;


procedure TMainFrame.ExecuteNetHTTPRequest;
begin
  NetHTTPRequestJSON.Execute;
end;

procedure TMainFrame.Label1Click(Sender: TObject);
begin
  ShellExecute(0,'OPEN',PChar('https://xkcd.com'),'','', SW_SHOWNORMAL);
end;

procedure TMainFrame.NetHTTPClientRequestImageCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
var
  lStream: TStream;
  lWICImage: TWICImage;
begin
  ActivityIndicator1.Animate := False;
  ActivityIndicator1.Visible := False;
  Image1.Visible := True;
  lStream := AResponse.ContentStream;
  lStream.Position := 0;
  if lStream.Size > 0 then
  begin
    lWICImage := TWICImage.Create;
    try
      {WICImage supports .bmp, .jpg and .png in one container with a header,
       by using WICImage as an intermediate we can load it from a generic blob
       that has the image type in its header}
      lWICImage.LoadFromStream(lStream);
      if lWICImage.ImageFormat IN [TWICImageFormat.wifBmp,
                                   TWICImageFormat.wifPng,
                                   TWICImageFormat.wifJpeg] then
      begin
        Image1.Picture.Assign(lWICImage);
      end;
    finally
      lWICImage.Free;
    end;
  end;
end;

procedure TMainFrame.NetHTTPClientRequestJSONCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
var
  lJSONString: string;
  lJSONValue: TJSONValue;
  lJSONObject: TJSONObject;
  lXKCDAlt: string;
  lXKCDImageUrl: string;
begin
  lJSONString := AResponse.ContentAsString;
  lJSONValue := TJSONObject.ParseJSONValue(lJSONString, True, False);
  if Assigned(lJSONValue)
     and lJSONValue.TryGetValue<TJSONObject>(lJSONObject) then
  begin
   if lJSONObject.TryGetValue<string>('alt', lXKCDAlt) then
     Label2.Caption := lXKCDAlt;
   if lJSONObject.TryGetValue<string>('img', lXKCDImageUrl) then
   begin
     NetHTTPRequestImage.URL := lXKCDImageUrl;
     NetHTTPRequestImage.Execute;
   end;
  end;
end;

procedure TMainFrame.SetupNetHTTPRequest;
begin
  {Get XKCD async}
  NetHTTPClient := TNetHTTPClient.Create(nil);

  NetHTTPRequestImage := TNetHTTPRequest.Create(nil);
  NetHTTPRequestImage.OnRequestCompleted := NetHTTPClientRequestImageCompleted;
  NetHTTPRequestImage.Asynchronous := True;
  NetHTTPRequestImage.Client := NetHTTPClient;
  NetHTTPRequestImage.MethodString := 'GET';
  NetHTTPRequestImage.Accept := 'image/png';

  NetHTTPRequestJSON := TNetHTTPRequest.Create(nil);
  NetHTTPRequestJSON.OnRequestCompleted := NetHTTPClientRequestJSONCompleted;
  NetHTTPRequestJSON.Asynchronous := True;
  NetHTTPRequestJSON.Client := NetHTTPClient;
  NetHTTPRequestJSON.MethodString := 'GET';
  NetHTTPRequestJSON.Accept := 'application/json';
  NetHTTPRequestJSON.URL := 'https://xkcd.com/info.0.json';
end;

end.
