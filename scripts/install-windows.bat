@echo off
setlocal

REM Lance la version PowerShell, qui télécharge l'archive Windows complète.
where pwsh >nul 2>&1
if %errorlevel% equ 0 (
    pwsh -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1"
) else (
    powershell -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1"
)

if errorlevel 1 (
    echo Installation échouée.
    pause
    exit /b 1
)

pause
