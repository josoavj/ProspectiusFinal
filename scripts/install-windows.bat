@echo off
REM Script d'installation de Prospectius sur Windows

setlocal enabledelayedexpansion

echo ================================
echo Installation de Prospectius
echo ================================
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

REM Verifier si Flutter est installe
where flutter >nul 2>nul
if errorlevel 1 (
    echo ^!Attention: Flutter n'est pas installe
    echo Telechargez Flutter depuis: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

echo ^✓ Flutter detecte
echo.

REM Importer la base de donnees
echo Configuration de la base de donnees Prospectius...
echo.

if not exist "scripts\prospectius.sql" (
    echo ^!Attention: Script SQL non trouve: scripts\prospectius.sql
    echo.
    echo Telechargez le script depuis:
    echo   https://raw.githubusercontent.com/josoavj/dbProspectius/master/scriptSQL/Prospectius.sql
    echo.
    echo Et placez-le dans: scripts\prospectius.sql
    echo.
    pause
    exit /b 1
)

REM Executer le script SQL
echo Importe du script SQL...
mysql -u root -proot < scripts\prospectius.sql
if errorlevel 1 (
    echo Erreur lors de l'importation
    pause
    exit /b 1
)

echo ^✓ Base de donnees configuree
echo.

REM Recuperer les dependances Flutter
echo Recuperation des dependances Flutter...
call flutter pub get
echo ^✓ Dependances installes
echo.

echo ================================
echo ^✓ Installation terminee!
echo ================================
echo.
echo Pour lancer l'application:
echo   flutter run -d windows
echo.
echo Configuration de la base de donnees au premier lancement:
echo   Host: localhost
echo   Port: 3306
echo   User: root
echo   Password: root
echo   Database: Prospectius
echo.
pause
