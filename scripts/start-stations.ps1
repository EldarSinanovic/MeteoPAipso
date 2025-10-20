<#
.SYNOPSIS
    Startet mehrere Station-Instanzen parallel
    
.DESCRIPTION
    Dieses Script startet mehrere Wetterstation-Simulatoren mit verschiedenen IDs.
    Jede Station läuft in einem eigenen PowerShell-Fenster.
    
.PARAMETER Count
    Anzahl der zu startenden Stationen (Standard: 2)
    
.EXAMPLE
    .\start-stations.ps1 -Count 3
    Startet 3 Stationen: station-001, station-002, station-003
#>

param(
    [int]$Count = 2
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir

Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?  MeteoIpso - Multi-Station Starter            ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# Prüfe ob LocalNode läuft
Write-Host "[INFO] Prüfe LocalNode Verfügbarkeit..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5001" -TimeoutSec 2 -UseBasicParsing
    Write-Host "[OK] LocalNode läuft auf Port 5001" -ForegroundColor Green
} catch {
    Write-Host "[WARNUNG] LocalNode nicht erreichbar!" -ForegroundColor Red
    Write-Host "         Bitte starte zuerst: dotnet run --project localnode" -ForegroundColor Red
    $continue = Read-Host "Trotzdem fortfahren? (j/n)"
    if ($continue -ne 'j') {
        exit
    }
}

Write-Host ""
Write-Host "Starte $Count Wetterstation(en)..." -ForegroundColor Cyan
Write-Host ""

$processes = @()

for ($i = 1; $i -le $Count; $i++) {
    $stationId = "station-{0:000}" -f $i
    $title = "MeteoIpso - $stationId"
    
    Write-Host "  [${i}/${Count}] Starte $stationId..." -ForegroundColor Green
    
    # Starte jede Station in einem neuen PowerShell-Fenster
    $proc = Start-Process powershell -ArgumentList `
        "-NoExit", `
        "-Command", `
        "Set-Location '$projectRoot'; `
         Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
         Write-Host '  Station: $stationId' -ForegroundColor Yellow; `
         Write-Host '  LocalNode: http://localhost:5001' -ForegroundColor Gray; `
         Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
         Write-Host ''; `
         dotnet run --project station --launch-profile '$stationId'" `
        -PassThru `
        -WindowStyle Normal
    
    $processes += @{
        Id = $proc.Id
        StationId = $stationId
    }
    
    Start-Sleep -Milliseconds 800
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "?  ? Alle $Count Station(en) gestartet!          ?" -ForegroundColor Green
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "Gestartete Stationen:" -ForegroundColor Cyan
foreach ($p in $processes) {
    Write-Host "  • $($p.StationId) (PID: $($p.Id))" -ForegroundColor White
}

Write-Host ""
Write-Host "Monitoring:" -ForegroundColor Yellow
Write-Host "  • Central UI: http://localhost:5000" -ForegroundColor Gray
Write-Host "  • Aggregates: http://localhost:5000/aggregates" -ForegroundColor Gray
Write-Host ""
Write-Host "Zum Beenden: Schließe die Station-Fenster oder drücke Ctrl+C" -ForegroundColor Gray
Write-Host ""

# Speichere PIDs für späteres Cleanup
$state = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Stations = $processes
}
$state | ConvertTo-Json | Out-File -FilePath "$projectRoot\station-processes.json" -Encoding utf8

Write-Host "Process IDs gespeichert in: station-processes.json" -ForegroundColor DarkGray
