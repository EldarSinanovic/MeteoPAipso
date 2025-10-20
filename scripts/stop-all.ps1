<#
.SYNOPSIS
    Stoppt das komplette MeteoIpso-System
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir
$stateFile = Join-Path $projectRoot "system-processes.json"

Write-Host ""
Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Red
Write-Host "?                                                      ?" -ForegroundColor Red
Write-Host "?          Stoppe MeteoIpso System...                  ?" -ForegroundColor Red
Write-Host "?                                                      ?" -ForegroundColor Red
Write-Host "????????????????????????????????????????????????????????" -ForegroundColor Red
Write-Host ""

if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
    
    Write-Host "Gefundene Prozesse vom letzten Start:" -ForegroundColor Cyan
    Write-Host "  Zeitpunkt: $($state.Timestamp)" -ForegroundColor Gray
    Write-Host ""
    
    $stopped = 0
    $notFound = 0
    
    # Stoppe LocalNode
    Write-Host "[1/3] Stoppe LocalNode..." -ForegroundColor Yellow
    try {
        Stop-Process -Id $state.LocalNode -Force -ErrorAction Stop
        Write-Host "      ? LocalNode beendet (PID: $($state.LocalNode))" -ForegroundColor Green
        $stopped++
    } catch {
        Write-Host "      ? Bereits beendet" -ForegroundColor DarkGray
        $notFound++
    }
    Write-Host ""
    
    # Stoppe Central
    Write-Host "[2/3] Stoppe Central..." -ForegroundColor Yellow
    try {
        Stop-Process -Id $state.Central -Force -ErrorAction Stop
        Write-Host "      ? Central beendet (PID: $($state.Central))" -ForegroundColor Green
        $stopped++
    } catch {
        Write-Host "      ? Bereits beendet" -ForegroundColor DarkGray
        $notFound++
    }
    Write-Host ""
    
    # Stoppe Stationen
    Write-Host "[3/3] Stoppe Stationen..." -ForegroundColor Yellow
    foreach ($station in $state.Stations) {
        try {
            Stop-Process -Id $station.Id -Force -ErrorAction Stop
            Write-Host "      ? $($station.StationId) beendet (PID: $($station.Id))" -ForegroundColor Green
            $stopped++
        } catch {
            Write-Host "      ? $($station.StationId) bereits beendet" -ForegroundColor DarkGray
            $notFound++
        }
    }
    
    Write-Host ""
    Write-Host "????????????????????????????????????????????????" -ForegroundColor Green
    Write-Host "  Beendet: $stopped Prozess(e)" -ForegroundColor Green
    Write-Host "  Bereits beendet: $notFound Prozess(e)" -ForegroundColor Gray
    Write-Host "????????????????????????????????????????????????" -ForegroundColor Green
    
    Remove-Item $stateFile -Force
    Write-Host ""
    Write-Host "State-Datei gelöscht." -ForegroundColor DarkGray
} else {
    Write-Host "[WARNUNG] Keine system-processes.json gefunden!" -ForegroundColor Yellow
    Write-Host "          Versuche alle MeteoIpso-Prozesse zu finden..." -ForegroundColor Yellow
    Write-Host ""
    
    $allProcs = Get-Process | Where-Object { 
        $_.ProcessName -eq 'dotnet' -and 
        ($_.CommandLine -like '*localnode*' -or 
         $_.CommandLine -like '*central*' -or 
         $_.CommandLine -like '*station*')
    }
    
    if ($allProcs.Count -eq 0) {
        Write-Host "? Keine MeteoIpso-Prozesse gefunden." -ForegroundColor Green
    } else {
        Write-Host "Gefundene Prozesse: $($allProcs.Count)" -ForegroundColor Yellow
        foreach ($proc in $allProcs) {
            Write-Host "  Stoppe PID $($proc.Id)..." -ForegroundColor Yellow
            Stop-Process -Id $proc.Id -Force
        }
        Write-Host ""
        Write-Host "? Alle gefundenen Prozesse beendet." -ForegroundColor Green
    }
}

Write-Host ""
