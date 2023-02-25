; Define:

#define InstallerName "Redis - Windows Installer"
#define InstallerSlug "redis-windows-installer"
#define InstallerVersion "1.0.0"
#define InstallerPublisher "Jihad Sinnaour (Jakiboy)"
#define InstallerURL "https://github.com/Jakiboy/redis-windows-installer"
#define InstallerExeName "redis-windows-installer.exe"
#define InstallerRoot "."

; Setup:

[Setup]
AppId={{407C8EF1-43D0-466F-A957-69EECD440C4B}
AppName={#InstallerName}
AppVersion={#InstallerVersion}
;AppVerName={#InstallerName} {#InstallerVersion}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerURL}
AppSupportURL={#InstallerURL}
AppUpdatesURL={#InstallerURL}
CreateAppDir=no
LicenseFile={#InstallerRoot}\LICENSE
InfoBeforeFile={#InstallerRoot}\redis.txt
OutputDir={#InstallerRoot}\build
OutputBaseFilename={#InstallerSlug}
SetupIconFile={#InstallerRoot}\assets\redis.ico
WizardImageFile={#InstallerRoot}\assets\large.bmp
WizardSmallImageFile={#InstallerRoot}\assets\small.bmp
Compression=lzma
SolidCompression=yes
WizardStyle=modern
;PrivilegesRequired=lowest

; Languages:

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

; Files:

[Files]
;Source: "{tmp}/debian.appx"; DestDir: "{tmp}"; Flags: external;
Source: "{tmp}/wsl.msi"; DestDir: {tmp}; Flags: deleteafterinstall external;

; Run:

[Run]
; Install debian package
;...
; Install WSL update
; (msiexec.exe /i 'C:\tmp\wsl.msi' /qb)
Filename: "msiexec.exe"; Parameters: "/i '{tmp}\\wsl.msi' /qb"; WorkingDir: {tmp};

; Code:

[Code]

// Download external files:

var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then begin
    DownloadPage.Clear;
    // Download debian package for WSL (https://aka.ms/wsl-debian-gnulinux)
    // DownloadPage.Add('https://aka.ms/wsl-debian-gnulinux', 'debian.appx', '');
    // Download WSL updater
    DownloadPage.Add('https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi', 'wsl.msi', '');
    DownloadPage.Show;
    try
      try
        DownloadPage.Download;
        Result := True;
      except
        SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end else
    Result := True;
end;
