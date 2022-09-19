object MainFrame: TMainFrame
  Left = 0
  Top = 0
  Width = 276
  Height = 183
  TabOrder = 0
  DesignSize = (
    276
    183)
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 276
    Height = 167
    Align = alClient
    Proportional = True
    Stretch = True
    Transparent = True
    ExplicitLeft = 16
    ExplicitTop = 8
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object Panel1: TPanel
    Left = 0
    Top = 167
    Width = 276
    Height = 16
    Align = alBottom
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 119
      Height = 14
      Hint = 'Click to open https://xkcd.com'
      Align = alLeft
      Caption = 'https://xkcd.com/'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = [fsUnderline]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      WordWrap = True
      OnClick = Label1Click
    end
    object Label2: TLabel
      Left = 226
      Top = 1
      Width = 49
      Height = 14
      Align = alRight
      Caption = 'loading...'
      ExplicitHeight = 15
    end
  end
  object ActivityIndicator1: TActivityIndicator
    Left = 112
    Top = 64
    Anchors = [akLeft, akTop, akRight, akBottom]
  end
end
