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
Source: "{tmp}/debian.appx"; DestDir: {tmp}; Flags: deleteafterinstall external;
Source: "{tmp}/wsl.msi"; DestDir: {tmp}; Flags: deleteafterinstall external;

; Run:

[Run]
; Enable WSL (Powershell)
; (powershell.exe -ExecutionPolicy Bypass -Command "Enable-WindowsOptionalFeature -norestart -Online -FeatureName Microsoft-Windows-Subsystem-Linux")
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""Enable-WindowsOptionalFeature -norestart -Online -FeatureName Microsoft-Windows-Subsystem-Linux"" "; WorkingDir: {tmp}; Flags: runhidden;

; Install WSL update
; (msiexec.exe /i "C:/tmp/wsl.msi" /qb)
Filename: "msiexec.exe"; Parameters: "/i ""{tmp}\\wsl.msi"" /qb"; WorkingDir: {tmp}; Flags: runhidden;

; Close Microsoft installer
; (taskkill /im "msiexec.exe" /f)
Filename: "taskkill"; Parameters: "/im ""msiexec.exe"" /f"; Flags: runhidden;

; Install Debian package (Powershell)
; (powershell.exe -ExecutionPolicy Bypass -Command "Add-AppxPackage C:/tmp/debian.appx")
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""Add-AppxPackage {tmp}\\debian.appx"" "; WorkingDir: {tmp}; Flags: runhidden;

; Setup Debian package (Powershell)
; (powershell.exe -ExecutionPolicy Bypass -Command "debian")
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""debian"" "; WorkingDir: {tmp}; Flags: runhidden;

; Install Redis (Powershell)
; (powershell.exe -ExecutionPolicy Bypass -Command "wsl -d debian -u root -- apt-get update")
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d debian -u root -- apt-get update"" "; WorkingDir: {tmp}; Flags: runhidden;
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d debian -u root -- apt-get upgrade -y"" "; WorkingDir: {tmp}; Flags: runhidden;
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d debian -u root -- apt-get install redis-server -y"" "; WorkingDir: {tmp}; Flags: runhidden;
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -Command ""wsl -d debian -u root -- service redis-server restart"" "; WorkingDir: {tmp}; Flags: runhidden;

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
