; Script Inno Setup pour Prospectius CRM
; Créé par APEXNova Labs

[Setup]
; Informations de l'application
AppName=Prospectius
AppVersion=1.1.0
AppPublisher=APEXNova Labs
AppPublisherURL=https://github.com/josoavj/ProspectiusFinal
DefaultDirName={autopf}\Prospectius
DefaultGroupName=Prospectius
; Icône de l'application (si vous en avez une au format .ico)
; SetupIconFile=..\..\assets\app_icon.ico
Compression=lzma2
SolidCompression=yes
OutputDir=..\..\installers
OutputBaseFilename=Prospectius_Setup_v1.1.0
; Permet une installation sans droits admin si besoin
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\prospectius.exe

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; IMPORTANT : On inclut l'exécutable ET toutes les DLL nécessaires
; Les chemins sont relatifs à l'emplacement de ce fichier .iss
Source: "..\..\build\windows\x64\runner\Release\prospectius.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Note: L'astuce ci-dessus copie tout le contenu du dossier Release (DLLs, dossier data/, etc.)

[Icons]
Name: "{group}\Prospectius"; Filename: "{app}\prospectius.exe"
Name: "{commondesktop}\Prospectius"; Filename: "{app}\prospectius.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\prospectius.exe"; Description: "{cm:LaunchProgram,Prospectius}"; Flags: nowait postinstall skipifsilent
