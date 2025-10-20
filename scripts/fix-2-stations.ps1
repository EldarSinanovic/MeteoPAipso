<#
.SYNOPSIS
    Garantiert 2 Stationen im Frontend
#>

Write-Host ""
Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?                                                     ?" -ForegroundColor Cyan
Write-Host "?  ?? Fix: 2 Stationen garantiert sichtbar machen    ?" -ForegroundColor Cyan
Write-Host "?                                                     ?" -ForegroundColor Cyan
Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot

# Prüfe aktuelle Situation
Write-Host "[1/4] Analysiere aktuelle Situation..." -ForegroundColor Yellow
$stations = Get-Process -ErrorAction SilentlyContinue | Where-Object { 
    $_.ProcessName -eq 'dotnet' -and 
    $_.CommandLine -like '*station*' -and
    $_.CommandLine -notlike '*localnode*' -and
    $_.CommandLine -notlike '*central*'
}

Write-Host "      Gefunden: $($stations.Count) Station(en)" -ForegroundColor Gray

if ($stations.Count -eq 0) {
    Write-Host "      ? Keine Stationen laufen" -ForegroundColor Red
    Write-Host "      ? Starte komplettes System" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[2/4] Starte System mit 2 Stationen..." -ForegroundColor Yellow
    & "$scriptDir\start-all.ps1" -Stations 2 | Out-Null
    
} elseif ($stations.Count -eq 1) {
    Write-Host "      ? Nur 1 Station läuft" -ForegroundColor Yellow
    Write-Host "      ? Starte zweite Station" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[2/4] Starte Station-002..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList `
        "-NoExit", `
        "-Command", `
        "Set-Location '$projectRoot'; `
         `$Host.UI.RawUI.WindowTitle = 'MeteoIpso - Station-002'; `
         Write-Host 'Station-002 wird gestartet...' -ForegroundColor Yellow; `
         dotnet run --project station -- station-002" `
        -WindowStyle Normal
    
} else {
    Write-Host "      ? $($stations.Count) Stationen laufen bereits" -ForegroundColor Green
    Write-Host "      ? Überspringe Start" -ForegroundColor Gray
    Write-Host ""
    Write-Host "[2/4] Übersprungen (Stationen laufen bereits)" -ForegroundColor Gray
}

Write-Host ""

# Warte auf Daten
Write-Host "[3/4] Warte auf Sensor-Daten..." -ForegroundColor Yellow
Write-Host "      Die Stationen brauchen Zeit zum Senden von Daten" -ForegroundColor Gray
Write-Host ""

for ($i = 15; $i -gt 0; $i--) {
    $bar = "?" * ($i)
    $spaces = " " * (15 - $i)
    Write-Host "`r      [$bar$spaces] $i Sekunden " -NoNewline -ForegroundColor Cyan
    Start-Sleep -Seconds 1
}
Write-Host "`r      [???????????????] Fertig!              " -ForegroundColor Green
Write-Host ""

# Öffne Browser mit Hard Refresh Anweisung
Write-Host "[4/4] Öffne Browser..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Start-Process "http://localhost:5000"
Write-Host "      ? Browser geöffnet" -ForegroundColor Green
Write-Host ""

Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "? SYSTEM BEREIT!" -ForegroundColor Green
Write-Host ""
Write-Host "Im Browser:" -ForegroundColor Cyan
Write-Host "  1. Drücke: Ctrl + F5 (Hard Refresh)" -ForegroundColor White
Write-Host "  2. Prüfe: 'Aktive Stationen' sollte 2 zeigen" -ForegroundColor White
Write-Host "  3. Tabelle sollte station-001 UND station-002 zeigen" -ForegroundColor White
Write-Host ""
Write-Host "Die Seite aktualisiert sich automatisch alle 3 Sekunden." -ForegroundColor Gray
Write-Host ""
Write-Host "Falls trotzdem nur 1 Station sichtbar:" -ForegroundColor Yellow
Write-Host "  • Prüfe die PowerShell-Fenster der Stationen" -ForegroundColor White
Write-Host "  • Steht 'ok=True' in beiden?" -ForegroundColor White
Write-Host "  • Falls 'ok=False', System neu starten:" -ForegroundColor White
Write-Host "    .\scripts\stop-all.ps1" -ForegroundColor Gray
Write-Host "    .\scripts\start-all.ps1 -Stations 2" -ForegroundColor Gray
Write-Host ""
Write-Host "???????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
