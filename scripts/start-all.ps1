<#
.SYNOPSIS
    Startet das komplette MeteoIpso-System
    
.DESCRIPTION
    Startet in dieser Reihenfolge:
    1. LocalNode (gRPC Server)
    2. Central (Blazor UI)
    3. Mehrere Station-Instanzen
    
.PARAMETER Stations
    Anzahl der zu startenden Stationen (Standard: 2)
    
.EXAMPLE
    .\start-all.ps1 -Stations 3
#>

param(
    [int]$Stations = 2
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir

Write-Host ""
Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?                                                      ?" -ForegroundColor Cyan
Write-Host "?          MeteoIpso - System Starter                  ?" -ForegroundColor Cyan
Write-Host "?                                                      ?" -ForegroundColor Cyan
Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

Set-Location $projectRoot

# Cleanup alte Prozesse
Write-Host "[1/4] Cleanup alte Prozesse..." -ForegroundColor Yellow
$oldProcesses = Get-Process | Where-Object { 
    $_.ProcessName -eq 'dotnet' -and 
    ($_.CommandLine -like '*localnode*' -or 
     $_.CommandLine -like '*central*' -or 
     $_.CommandLine -like '*station*')
}
if ($oldProcesses.Count -gt 0) {
    Write-Host "      Gefunden: $($oldProcesses.Count) alte Prozesse" -ForegroundColor Gray
    $oldProcesses | Stop-Process -Force
    Start-Sleep -Seconds 1
}
Write-Host "      ? Cleanup abgeschlossen" -ForegroundColor Green
Write-Host ""

# Start LocalNode
Write-Host "[2/4] Starte LocalNode (gRPC Server)..." -ForegroundColor Yellow
$localnodeProc = Start-Process powershell -ArgumentList `
    "-NoExit", `
    "-Command", `
    "Set-Location '$projectRoot'; `
     Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
     Write-Host '  LocalNode - gRPC Server' -ForegroundColor Yellow; `
     Write-Host '  Port: 5001' -ForegroundColor Gray; `
     Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
     Write-Host ''; `
     dotnet run --project localnode" `
    -PassThru `
    -WindowStyle Normal

Write-Host "      ? LocalNode gestartet (PID: $($localnodeProc.Id))" -ForegroundColor Green
Write-Host "      Warte auf Initialisierung..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Prüfe LocalNode
$retries = 0
$maxRetries = 10
$localnodeReady = $false

while ($retries -lt $maxRetries -and -not $localnodeReady) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5001" -TimeoutSec 2 -UseBasicParsing
        $localnodeReady = $true
        Write-Host "      ? LocalNode ist bereit!" -ForegroundColor Green
    } catch {
        $retries++
        Write-Host "      Warte... ($retries/$maxRetries)" -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
    }
}

if (-not $localnodeReady) {
    Write-Host "      ? LocalNode konnte nicht gestartet werden!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Start Central
Write-Host "[3/4] Starte Central (Blazor UI)..." -ForegroundColor Yellow
$centralProc = Start-Process powershell -ArgumentList `
    "-NoExit", `
    "-Command", `
    "Set-Location '$projectRoot'; `
     Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
     Write-Host '  Central - Blazor UI' -ForegroundColor Yellow; `
     Write-Host '  URL: http://localhost:5000' -ForegroundColor Gray; `
     Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
     Write-Host ''; `
     dotnet run --project central" `
    -PassThru `
    -WindowStyle Normal

Write-Host "      ? Central gestartet (PID: $($centralProc.Id))" -ForegroundColor Green
Write-Host "      Warte auf Initialisierung..." -ForegroundColor Gray
Start-Sleep -Seconds 3
Write-Host ""

# Start Stationen
Write-Host "[4/4] Starte $Stations Wetterstation(en)..." -ForegroundColor Yellow
$stationProcs = @()

for ($i = 1; $i -le $Stations; $i++) {
    $stationId = "station-{0:000}" -f $i
    
    Write-Host "      [$i/$Stations] Starte $stationId..." -ForegroundColor Green
    
    $proc = Start-Process powershell -ArgumentList `
        "-NoExit", `
        "-Command", `
        "Set-Location '$projectRoot'; `
         Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
         Write-Host '  Station: $stationId' -ForegroundColor Yellow; `
         Write-Host '  LocalNode: http://localhost:5001' -ForegroundColor Gray; `
         Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
         Write-Host ''; `
         dotnet run --project station -- $stationId" `
        -PassThru `
        -WindowStyle Normal
    
    $stationProcs += @{
        Id = $proc.Id
        StationId = $stationId
    }
    
    Start-Sleep -Milliseconds 600
}

Write-Host "      ? Alle Stationen gestartet!" -ForegroundColor Green
Write-Host ""

# Zusammenfassung
Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "?                                                      ?" -ForegroundColor Green
Write-Host "?          ? System erfolgreich gestartet!            ?" -ForegroundColor Green
Write-Host "?                                                      ?" -ForegroundColor Green
Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "Gestartete Komponenten:" -ForegroundColor Cyan
Write-Host "  • LocalNode (gRPC)     - PID: $($localnodeProc.Id)" -ForegroundColor White
Write-Host "  • Central (Blazor)     - PID: $($centralProc.Id)" -ForegroundColor White
foreach ($p in $stationProcs) {
    Write-Host "  • $($p.StationId)      - PID: $($p.Id)" -ForegroundColor White
}
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  • Übersicht:    http://localhost:5000" -ForegroundColor Yellow
Write-Host "  • Aggregates:   http://localhost:5000/aggregates" -ForegroundColor Yellow
Write-Host "  • LocalNode:    http://localhost:5001" -ForegroundColor Yellow
Write-Host ""
Write-Host "Zum Beenden:" -ForegroundColor Red
Write-Host "  • Führe aus: .\scripts\stop-all.ps1" -ForegroundColor Gray
Write-Host "  • Oder schließe alle PowerShell-Fenster" -ForegroundColor Gray
Write-Host ""

# Speichere alle PIDs
$state = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    LocalNode = $localnodeProc.Id
    Central = $centralProc.Id
    Stations = $stationProcs
}
$state | ConvertTo-Json | Out-File -FilePath "$projectRoot\system-processes.json" -Encoding utf8

Write-Host "State gespeichert in: system-processes.json" -ForegroundColor DarkGray
Write-Host ""

# Öffne Browser
Start-Sleep -Seconds 2
Write-Host "Öffne Browser..." -ForegroundColor Cyan
Start-Process "http://localhost:5000"
