<#
.SYNOPSIS
    Stoppt alle laufenden Station-Instanzen
    
.DESCRIPTION
    Liest die gespeicherten Process-IDs und beendet alle Station-Prozesse sauber
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$stateFile = Join-Path $projectRoot "station-processes.json"

Write-Host "??????????????????????????????????????????????????" -ForegroundColor Red
Write-Host "?  Stoppe alle Stationen...                     ?" -ForegroundColor Red
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Red
Write-Host ""

if (-not (Test-Path $stateFile)) {
    Write-Host "[WARNUNG] Keine station-processes.json gefunden!" -ForegroundColor Yellow
    Write-Host "          Versuche alle 'dotnet' Station-Prozesse zu finden..." -ForegroundColor Yellow
    
    $stationProcs = Get-Process | Where-Object { 
        $_.ProcessName -eq 'dotnet' -and 
        $_.CommandLine -like '*station*'
    }
    
    if ($stationProcs.Count -eq 0) {
        Write-Host "[INFO] Keine Station-Prozesse gefunden." -ForegroundColor Green
        exit
    }
    
    foreach ($proc in $stationProcs) {
        Write-Host "  Stoppe PID $($proc.Id)..." -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force
    }
    
    Write-Host ""
    Write-Host "? Alle gefundenen Station-Prozesse beendet." -ForegroundColor Green
    exit
}

# Lade gespeicherte PIDs
$state = Get-Content $stateFile | ConvertFrom-Json

Write-Host "Gefundene Stationen aus dem letzten Start:" -ForegroundColor Cyan
Write-Host "  Zeitpunkt: $($state.Timestamp)" -ForegroundColor Gray
Write-Host ""

$stopped = 0
$notFound = 0

foreach ($station in $state.Stations) {
    $pid = $station.Id
    $stationId = $station.StationId
    
    try {
        $proc = Get-Process -Id $pid -ErrorAction Stop
        Write-Host "  [?] Stoppe $stationId (PID: $pid)..." -ForegroundColor Yellow
        Stop-Process -Id $pid -Force
        $stopped++
    } catch {
        Write-Host "  [?] $stationId (PID: $pid) läuft nicht mehr" -ForegroundColor DarkGray
        $notFound++
    }
}

Write-Host ""
Write-Host "????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "  Beendet: $stopped Station(en)" -ForegroundColor Green
Write-Host "  Bereits beendet: $notFound Station(en)" -ForegroundColor Gray
Write-Host "????????????????????????????????????????????????" -ForegroundColor Green

# Lösche state file
Remove-Item $stateFile -Force
Write-Host ""
Write-Host "State-Datei gelöscht." -ForegroundColor DarkGray
