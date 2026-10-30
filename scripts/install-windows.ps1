#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"
$repository = "josoavj/ProspectiusFinal"
$downloadDir = if ($env:PROSPECTIUS_DOWNLOAD_DIR) { $env:PROSPECTIUS_DOWNLOAD_DIR } else { Join-Path $PSScriptRoot "prospectius" }
$archivePath = Join-Path $downloadDir "prospectius-windows-x64.zip"
$extractDir = Join-Path $downloadDir "app"
$sqlPath = Join-Path $extractDir "Database\Prospectius.sql"
$dbUser = if ($env:PROSPECTIUS_DB_USER) { $env:PROSPECTIUS_DB_USER } else { "root" }
$dbPassword = if ($null -ne $env:PROSPECTIUS_DB_PASSWORD) { $env:PROSPECTIUS_DB_PASSWORD } else { "" }
$dbHost = if ($env:PROSPECTIUS_DB_HOST) { $env:PROSPECTIUS_DB_HOST } else { "localhost" }
$dbPort = if ($env:PROSPECTIUS_DB_PORT) { $env:PROSPECTIUS_DB_PORT } else { "3306" }

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Installation de Prospectius" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null
Write-Host "Téléchargement de la dernière release Windows..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://github.com/$repository/releases/latest/download/prospectius-windows-x64.zip" -OutFile $archivePath

if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
Expand-Archive -Path $archivePath -DestinationPath $extractDir -Force

$mysql = Get-Command mysql -ErrorAction SilentlyContinue
if (-not $mysql) { $mysql = Get-Command mariadb -ErrorAction SilentlyContinue }
if (-not $mysql) {
    throw "MariaDB/MySQL est requis et doit être accessible dans le PATH."
}
if (-not (Test-Path $sqlPath)) {
    throw "Le script Database\Prospectius.sql est absent de l'archive."
}

$arguments = @("-h", $dbHost, "-P", $dbPort, "-u", $dbUser)
if ($dbPassword) { $arguments += "-p$dbPassword" }
Write-Host "Importation du schéma Prospectius..." -ForegroundColor Yellow
Get-Content -Raw $sqlPath | & $mysql.Source @arguments
if ($LASTEXITCODE -ne 0) { throw "L'importation du schéma SQL a échoué." }

$exePath = Join-Path $extractDir "prospectius.exe"
Write-Host ""
Write-Host "Installation terminée." -ForegroundColor Green
Write-Host "Application : $exePath"
Write-Host "Lancement : $exePath"
