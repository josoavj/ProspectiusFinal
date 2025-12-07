@echo off
REM Script d'installation de Prospectius sur Windows
REM Télécharge prospectius.exe et Prospectius.sql depuis la latest release GitHub

setlocal enabledelayedexpansion

echo ================================
echo Installation de Prospectius
echo ================================
echo.

REM Télécharger les fichiers depuis la latest release GitHub
echo Telechargement des fichiers depuis GitHub...
echo.

REM Créer le dossier de destination
if not exist "temp_download" mkdir temp_download

REM Télécharger prospectius.exe
echo   Telechargement de prospectius.exe...
powershell -Command "try { $release = Invoke-WebRequest -Uri 'https://api.github.com/repos/josoavj/ProspectiusFinal/releases/latest' -UseBasicParsing | ConvertFrom-Json; $exe = $release.assets | Where-Object { $_.name -eq 'prospectius.exe' }; if ($exe) { Invoke-WebRequest -Uri $exe.browser_download_url -OutFile 'temp_download\prospectius.exe' -UseBasicParsing; Write-Host '  OK: prospectius.exe telecharge'; exit 0 } else { Write-Host '  ERREUR: prospectius.exe non trouve'; exit 1 } } catch { Write-Host ('  ERREUR: ' + $_); exit 1 }"
if errorlevel 1 (
    echo Erreur lors du telechargement de prospectius.exe
    pause
    exit /b 1
)

REM Télécharger Prospectius.sql
echo   Telechargement de Prospectius.sql...
powershell -Command "try { $release = Invoke-WebRequest -Uri 'https://api.github.com/repos/josoavj/ProspectiusFinal/releases/latest' -UseBasicParsing | ConvertFrom-Json; $sql = $release.assets | Where-Object { $_.name -eq 'Prospectius.sql' }; if ($sql) { Invoke-WebRequest -Uri $sql.browser_download_url -OutFile 'temp_download\Prospectius.sql' -UseBasicParsing; Write-Host '  OK: Prospectius.sql telecharge'; exit 0 } else { Write-Host '  ERREUR: Prospectius.sql non trouve'; exit 1 } } catch { Write-Host ('  ERREUR: ' + $_); exit 1 }"
if errorlevel 1 (
    echo Erreur lors du telechargement de Prospectius.sql
    pause
    exit /b 1
)

echo OK: Fichiers telecharges avec succes
echo.

REM Vérifier si MySQL est en cours d'exécution
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if errorlevel 1 (
    echo.
    echo ^!Attention: MySQL/MariaDB n'est pas detecte
    echo.
    echo Assurez-vous que MariaDB est installee et demarree:
    echo   https://mariadb.org/download/
    echo.
    echo Une fois installee, vous pouvez:
    echo   - Lancer MariaDB depuis Services Windows
    echo   - Ou executer: "C:\Program Files\MariaDB Foundation\MariaDB\bin\mysqld.exe"
    echo.
    pause
    exit /b 1
)

echo ^✓ MariaDB detecte
echo.

REM Importer la base de donnees
echo Configuration de la base de donnees Prospectius...
echo.

if not exist "temp_download\Prospectius.sql" (
    echo ^!Attention: Script SQL n'a pas pu etre telecharge
    echo.
    echo Verifiez votre connexion Internet et reessayez
    echo.
    pause
    exit /b 1
)

REM Executer le script SQL
echo Importation du script SQL...
mysql -u root -proot < temp_download\Prospectius.sql
if errorlevel 1 (
    echo ^!Erreur lors de l'importation
    echo.
    echo Verifiez que:
    echo   - MariaDB est bien en cours d'execution
    echo   - L'utilisateur root existe avec le mot de passe 'root'
    echo.
    pause
    exit /b 1
)

echo ^✓ Base de donnees configuree
echo.

echo ================================
echo ^✓ Installation terminee!
echo ================================
echo.
echo Fichiers telecharges:
echo   Executable: temp_download\prospectius.exe
echo   Dossier de telechargement: temp_download\
echo.
echo Prochaines etapes:
echo.
echo 1. Lancez l'application en double-cliquant sur:
echo    temp_download\prospectius.exe
echo.
echo 2. A la premiere execution, configurez la base de donnees:
echo    Host: localhost
echo    Port: 3306
echo    User: root
echo    Password: root
echo    Database: Prospectius
echo.
echo 3. Creez votre compte:
echo    Cliquez sur 'S'inscrire' pour creer un nouveau compte
echo    Remplissez le formulaire avec vos informations
echo.
pause
