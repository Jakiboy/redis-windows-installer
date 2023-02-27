; ======================================================================================================================
; Redis - Windows Installer (WSL1)
;
; Author: Jihad Sinnaour (Jakiboy) <j.sinnaour.official@gmail.com>
; URL: https://github.com/Jakiboy/redis-windows-installer
; Copyright (C) 2023 Jihad Sinnaour. All rights reserved.
; ======================================================================================================================

; Define:

#define InstallerName "Redis - Windows Installer"
#define InstallerFile "Redis-Windows-Installer-x64"
#define InstallerVersion "1.0.0"
#define InstallerPublisher "Jihad Sinnaour (Jakiboy)"
#define InstallerURL "https://github.com/Jakiboy/redis-windows-installer"
#define InstallerRoot "."

; Setup:

[Setup]
AppId={{407C8EF1-43D0-466F-A957-69EECD440C4B}
AppName={#InstallerName}
AppVersion={#InstallerVersion}
AppPublisher={#InstallerPublisher}
AppPublisherURL={#InstallerURL}
AppSupportURL={#InstallerURL}
AppUpdatesURL={#InstallerURL}
CreateAppDir=no
LicenseFile={#InstallerRoot}\LICENSE
InfoBeforeFile={#InstallerRoot}\redis.txt
OutputDir={#InstallerRoot}\build
OutputBaseFilename={#InstallerFile}
SetupIconFile={#InstallerRoot}\assets\redis.ico
WizardImageFile={#InstallerRoot}\assets\large.bmp
WizardSmallImageFile={#InstallerRoot}\assets\small.bmp
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
AlwaysRestart=yes

; Languages:

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

; Files:

[Files]
Source: "{tmp}/debian.appx"; DestDir: {tmp}; Flags: deleteafterinstall external;

; Run:

[Run]
; Enable WSL
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""Enable-WindowsOptionalFeature -norestart -Online -FeatureName Microsoft-Windows-Subsystem-Linux"""; Flags: runhidden;

; Install Debian package
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""Add-AppxPackage {tmp}\\debian.appx"""; WorkingDir: {tmp}; Flags: runhidden;

; Setup Debian package
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""Debian install --root"""; Flags: runhidden;

; Install Redis
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d Debian -u root -- apt-get update"""; Flags: runhidden;
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d Debian -u root -- apt-get upgrade -y"""; Flags: runhidden;
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d Debian -u root -- apt-get install redis-server -y"""; Flags: runhidden;
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d Debian -u root -- service redis-server restart"""; Flags: runhidden;

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
    // Download Debian package for WSL
    DownloadPage.Add('https://aka.ms/wsl-debian-gnulinux', 'debian.appx', '');
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
