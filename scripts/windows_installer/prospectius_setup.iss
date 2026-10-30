; Script Inno Setup pour Prospectius CRM
; Créé par APEXNova Labs

#ifndef AppVersion
#define AppVersion "1.2.0"
#endif

#ifndef OutputBaseFilename
#define OutputBaseFilename "Prospectius_Setup_v" + AppVersion
#endif

[Setup]
; Informations de l'application
AppName=Prospectius
AppVersion={#AppVersion}
AppPublisher=APEXNova Labs
AppPublisherURL=https://github.com/josoavj/ProspectiusFinal
DefaultDirName={autopf}\Prospectius
DefaultGroupName=Prospectius
; On utilise l'icône générée par Flutter pour l'installeur
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
OutputDir=..\..\installers
OutputBaseFilename={#OutputBaseFilename}
PrivilegesRequired=admin
UninstallDisplayIcon={app}\prospectius.exe

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; IMPORTANT : On inclut l'exécutable ET toutes les DLL nécessaires
; Les chemins sont relatifs à l'emplacement de ce fichier .iss
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Database\*"; DestDir: "{app}\Database"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\VC_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\Prospectius"; Filename: "{app}\prospectius.exe"
Name: "{commondesktop}\Prospectius"; Filename: "{app}\prospectius.exe"; Tasks: desktopicon

[Run]
Filename: "{tmp}\VC_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installation du runtime Visual C++..."; Flags: waituntilterminated runhidden skipifdoesntexist
Filename: "{app}\prospectius.exe"; Description: "{cm:LaunchProgram,Prospectius}"; Flags: nowait postinstall skipifsilent

[Code]
const
  MariaDbDownloadUrl = 'https://mariadb.org/download/';
  DatabaseName = 'Prospectius';

var
  DatabasePage: TInputQueryWizardPage;
  DatabaseClient: String;

function Quote(const Value: String): String;
begin
  Result := '"' + Value + '"';
end;

function FindDatabaseClient(): String;
var
  Candidates: Array[0..9] of String;
  I: Integer;
begin
  Candidates[0] := ExpandConstant('{pf}\MariaDB 11.0\bin\mysql.exe');
  Candidates[1] := ExpandConstant('{pf}\MariaDB 11.4\bin\mysql.exe');
  Candidates[2] := ExpandConstant('{pf}\MariaDB 11.8\bin\mysql.exe');
  Candidates[3] := ExpandConstant('{pf}\MariaDB 10.11\bin\mysql.exe');
  Candidates[4] := ExpandConstant('{pf}\MariaDB 10.6\bin\mysql.exe');
  Candidates[5] := ExpandConstant('{pf}\MySQL\MySQL Server 8.0\bin\mysql.exe');
  Candidates[6] := ExpandConstant('{pf}\MySQL\MySQL Server 8.4\bin\mysql.exe');
  Candidates[7] := ExpandConstant('{pf32}\MariaDB 11.4\bin\mysql.exe');
  Candidates[8] := ExpandConstant('{pf32}\MariaDB 10.11\bin\mysql.exe');
  Candidates[9] := ExpandConstant('{pf32}\MySQL\MySQL Server 8.0\bin\mysql.exe');
  Result := '';
  for I := 0 to GetArrayLength(Candidates) - 1 do
    if FileExists(Candidates[I]) then
    begin
      Result := Candidates[I];
      Exit;
    end;
end;

function DatabaseServerDetected(): Boolean;
begin
  Result := FindDatabaseClient() <> '';
end;

function RunDatabaseCommand(const Arguments: String): Boolean;
var
  ResultCode: Integer;
begin
  Result := (DatabaseClient <> '') and
    Exec(ExpandConstant('{cmd}'), '/C ""' + DatabaseClient + '" ' +
      Arguments + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and
    (ResultCode = 0);
end;

function DatabaseExists(): Boolean;
begin
  Result := RunDatabaseCommand(
    '-h ' + Quote(DatabasePage.Values[0]) +
    ' -P ' + Quote(DatabasePage.Values[1]) +
    ' -u ' + Quote(DatabasePage.Values[2]) +
    ' --password=' + Quote(DatabasePage.Values[3]) +
    ' -e "USE ' + DatabaseName + '"');
end;

procedure ImportDatabaseIfNeeded();
var
  SqlPath: String;
  ShellResult: Integer;
begin
  DatabaseClient := FindDatabaseClient();
  if DatabaseClient = '' then
  begin
    MsgBox(
      'MariaDB/MySQL n''a pas été détecté. Prospectius est installé, mais la base ' +
      'ne peut pas encore être initialisée.' + #13#10#13#10 +
      'Installez MariaDB, puis configurez la connexion dans Prospectius.',
      mbInformation, MB_OK);
    ShellExec(
      'open', MariaDbDownloadUrl, '', '', SW_SHOWNORMAL, ewNoWait, ShellResult);
    Exit;
  end;

  if DatabaseExists() then
  begin
    MsgBox(
      'La base Prospectius existe déjà. Aucun script destructif n''a été exécuté.',
      mbInformation, MB_OK);
    Exit;
  end;

  SqlPath := ExpandConstant('{app}\Database\Prospectius.sql');
  if not FileExists(SqlPath) then
  begin
    MsgBox('Le fichier Database\Prospectius.sql est absent.', mbError, MB_OK);
    Exit;
  end;

  if RunDatabaseCommand(
    '-h ' + Quote(DatabasePage.Values[0]) +
    ' -P ' + Quote(DatabasePage.Values[1]) +
    ' -u ' + Quote(DatabasePage.Values[2]) +
    ' --password=' + Quote(DatabasePage.Values[3]) +
    ' < ' + Quote(SqlPath)) then
    MsgBox('La base Prospectius a été initialisée avec succès.', mbInformation, MB_OK)
  else
    MsgBox(
      'Impossible d''initialiser la base Prospectius. Vérifiez les paramètres ' +
      'MariaDB et réessayez depuis l''application.',
      mbError, MB_OK);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard();
begin
  DatabasePage := CreateInputQueryPage(
    wpSelectDir,
    'Configuration de MariaDB',
    'Paramètres de connexion',
    'Ces informations servent uniquement à initialiser la base Prospectius.');
  DatabasePage.Add('Hôte :', False);
  DatabasePage.Add('Port :', False);
  DatabasePage.Add('Utilisateur :', False);
  DatabasePage.Add('Mot de passe :', True);
  DatabasePage.Values[0] := 'localhost';
  DatabasePage.Values[1] := '3306';
  DatabasePage.Values[2] := 'root';
  DatabasePage.Values[3] := '';
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    ImportDatabaseIfNeeded();
  end;
end;
