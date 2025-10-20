<#
.SYNOPSIS
    Quick Fix für das "Zweite Station fehlt" Problem
    
.DESCRIPTION
    Stoppt alles, startet neu mit 2 Stationen, wartet, öffnet Browser
#>

Write-Host ""
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?                                                ?" -ForegroundColor Cyan
Write-Host "?  ?? Quick Fix: Zweite Station Problem         ?" -ForegroundColor Cyan
Write-Host "?                                                ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot

# Schritt 1: Alles stoppen
Write-Host "[1/5] Stoppe alle laufenden Prozesse..." -ForegroundColor Yellow
& "$scriptDir\stop-all.ps1" | Out-Null
Start-Sleep -Seconds 3
Write-Host "      ? Alle Prozesse beendet" -ForegroundColor Green
Write-Host ""

# Schritt 2: Cleanup
Write-Host "[2/5] Räume auf..." -ForegroundColor Yellow
Remove-Item ".\system-processes.json" -ErrorAction SilentlyContinue
Remove-Item ".\station-processes.json" -ErrorAction SilentlyContinue
Write-Host "      ? State-Dateien gelöscht" -ForegroundColor Green
Write-Host ""

# Schritt 3: System neu starten
Write-Host "[3/5] Starte System mit 2 Stationen..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit -File `"$scriptDir\start-all.ps1`" -Stations 2" -WindowStyle Minimized
Write-Host "      ? System gestartet" -ForegroundColor Green
Write-Host ""

# Schritt 4: Warten
Write-Host "[4/5] Warte auf Initialisierung..." -ForegroundColor Yellow
Write-Host "      Die Stationen brauchen Zeit zum Senden..." -ForegroundColor Gray

for ($i = 15; $i -gt 0; $i--) {
    Write-Host "`r      Warte... $i Sekunden " -NoNewline -ForegroundColor Cyan
    Start-Sleep -Seconds 1
}
Write-Host "`r      ? Initialisierung abgeschlossen (15 Sekunden)          " -ForegroundColor Green
Write-Host ""

# Schritt 5: Diagnose
Write-Host "[5/5] Führe Diagnose aus..." -ForegroundColor Yellow
Write-Host ""
& "$scriptDir\diagnose.ps1"

Write-Host ""
Write-Host "????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""
Write-Host "?? Öffne jetzt den Browser:" -ForegroundColor Yellow
Write-Host "   http://localhost:5000" -ForegroundColor White
Write-Host ""
Write-Host "?? Was du sehen solltest:" -ForegroundColor Yellow
Write-Host "   • Debug Info Box mit 'Eindeutige Stationen: 2'" -ForegroundColor White
Write-Host "   • 8 Sensor-Einträge in der Tabelle" -ForegroundColor White
Write-Host "   • station-001 und station-002" -ForegroundColor White
Write-Host ""
Write-Host "?? Die Seite aktualisiert sich automatisch alle 5 Sekunden" -ForegroundColor Gray
Write-Host ""
Write-Host "??  Falls immer noch nur 1 Station:" -ForegroundColor Yellow
Write-Host "   1. Drücke Ctrl+F5 (Hard Refresh)" -ForegroundColor White
Write-Host "   2. Prüfe die PowerShell-Fenster auf Fehler" -ForegroundColor White
Write-Host "   3. Lies: FIX-ZWEITE-STATION.md" -ForegroundColor White
Write-Host ""

# Browser öffnen
Start-Sleep -Seconds 2
Write-Host "Öffne Browser..." -ForegroundColor Cyan
Start-Process "http://localhost:5000"

Write-Host ""
Write-Host "? Quick Fix abgeschlossen!" -ForegroundColor Green
Write-Host ""
