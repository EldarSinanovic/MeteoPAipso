<#
.SYNOPSIS
    Diagnostiziert das MeteoIpso System
    
.DESCRIPTION
    Prüft ob alle Komponenten laufen und Daten fließen
#>

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?  MeteoIpso - System Diagnose                  ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$issues = @()
$warnings = @()

# 1. Prüfe dotnet Prozesse
Write-Host "[1/6] Prüfe laufende Prozesse..." -ForegroundColor Yellow

$processes = Get-Process | Where-Object { 
    $_.ProcessName -eq 'dotnet' -and 
    ($_.CommandLine -like '*localnode*' -or 
     $_.CommandLine -like '*central*' -or 
     $_.CommandLine -like '*station*')
}

if ($processes.Count -eq 0) {
    Write-Host "  ? FEHLER: Keine MeteoIpso-Prozesse laufen!" -ForegroundColor Red
    $issues += "Keine Prozesse gefunden. Starte System mit: .\scripts\start-all.ps1"
} else {
    Write-Host "  ? Gefunden: $($processes.Count) Prozesse" -ForegroundColor Green
    
    $localnode = $processes | Where-Object { $_.CommandLine -like '*localnode*' }
    $central = $processes | Where-Object { $_.CommandLine -like '*central*' }
    $stations = $processes | Where-Object { $_.CommandLine -like '*station*' }
    
    if ($localnode.Count -eq 0) {
        Write-Host "    ? LocalNode läuft NICHT" -ForegroundColor Red
        $issues += "LocalNode nicht gefunden"
    } else {
        Write-Host "    ? LocalNode läuft (PID: $($localnode[0].Id))" -ForegroundColor Green
    }
    
    if ($central.Count -eq 0) {
        Write-Host "    ? Central läuft NICHT" -ForegroundColor Red
        $issues += "Central nicht gefunden"
    } else {
        Write-Host "    ? Central läuft (PID: $($central[0].Id))" -ForegroundColor Green
    }
    
    if ($stations.Count -eq 0) {
        Write-Host "    ? KEINE Stationen laufen" -ForegroundColor Red
        $issues += "Keine Stations-Prozesse gefunden"
    } elseif ($stations.Count -eq 1) {
        Write-Host "    ? Nur 1 Station läuft (PID: $($stations[0].Id))" -ForegroundColor Yellow
        $warnings += "Nur 1 Station aktiv - erwartet mindestens 2"
    } else {
        Write-Host "    ? $($stations.Count) Stationen laufen" -ForegroundColor Green
        foreach ($s in $stations) {
            Write-Host "      - PID: $($s.Id)" -ForegroundColor Gray
        }
    }
}

Write-Host ""

# 2. Prüfe LocalNode Erreichbarkeit
Write-Host "[2/6] Prüfe LocalNode Erreichbarkeit..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5001" -TimeoutSec 3 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ? LocalNode antwortet auf Port 5001" -ForegroundColor Green
    }
} catch {
    Write-Host "  ? LocalNode nicht erreichbar auf Port 5001" -ForegroundColor Red
    $issues += "LocalNode nicht erreichbar"
}

Write-Host ""

# 3. Prüfe Central Erreichbarkeit
Write-Host "[3/6] Prüfe Central Erreichbarkeit..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -TimeoutSec 3 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ? Central antwortet auf Port 5000" -ForegroundColor Green
    }
} catch {
    Write-Host "  ? Central nicht erreichbar auf Port 5000" -ForegroundColor Red
    $issues += "Central nicht erreichbar"
}

Write-Host ""

# 4. Prüfe Ports
Write-Host "[4/6] Prüfe Port-Belegung..." -ForegroundColor Yellow

$port5001 = netstat -ano | Select-String ":5001" | Select-String "LISTENING"
$port5000 = netstat -ano | Select-String ":5000" | Select-String "LISTENING"

if ($port5001) {
    Write-Host "  ? Port 5001 (LocalNode) ist belegt" -ForegroundColor Green
} else {
    Write-Host "  ? Port 5001 ist NICHT belegt" -ForegroundColor Red
    $issues += "Port 5001 nicht belegt"
}

if ($port5000) {
    Write-Host "  ? Port 5000 (Central) ist belegt" -ForegroundColor Green
} else {
    Write-Host "  ? Port 5000 ist NICHT belegt" -ForegroundColor Red
    $issues += "Port 5000 nicht belegt"
}

Write-Host ""

# 5. Prüfe System-Prozess-Datei
Write-Host "[5/6] Prüfe system-processes.json..." -ForegroundColor Yellow

$stateFile = ".\system-processes.json"
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
    Write-Host "  ? State-Datei gefunden" -ForegroundColor Green
    Write-Host "    Zeitstempel: $($state.Timestamp)" -ForegroundColor Gray
    Write-Host "    LocalNode PID: $($state.LocalNode)" -ForegroundColor Gray
    Write-Host "    Central PID: $($state.Central)" -ForegroundColor Gray
    Write-Host "    Stationen: $($state.Stations.Count)" -ForegroundColor Gray
    
    if ($state.Stations.Count -lt 2) {
        Write-Host "    ? Weniger als 2 Stationen registriert" -ForegroundColor Yellow
        $warnings += "Nur $($state.Stations.Count) Station(en) in state file"
    }
} else {
    Write-Host "  ? system-processes.json nicht gefunden" -ForegroundColor Yellow
    $warnings += "Keine State-Datei - System wurde möglicherweise nicht mit start-all.ps1 gestartet"
}

Write-Host ""

# 6. Erweiterte Diagnose (nur wenn Verbose)
if ($Verbose) {
    Write-Host "[6/6] Erweiterte Diagnose..." -ForegroundColor Yellow
    
    # Versuche gRPC Call zu simulieren (PowerShell kann kein gRPC direkt)
    Write-Host "  ? Verwende curl für HTTP-Tests..." -ForegroundColor Gray
    
    try {
        $content = Invoke-RestMethod -Uri "http://localhost:5001" -Method Get -ErrorAction Stop
        Write-Host "  ? LocalNode HTTP Endpunkt antwortet: $content" -ForegroundColor Green
    } catch {
        Write-Host "  ? Fehler beim LocalNode HTTP Call: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[6/6] Erweiterte Diagnose übersprungen (verwende -Verbose)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "????????????????????????????????????????????????" -ForegroundColor Cyan

# Zusammenfassung
if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host ""
    Write-Host "? SYSTEM OK - Keine Probleme gefunden!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Nächste Schritte:" -ForegroundColor Cyan
    Write-Host "  1. Öffne http://localhost:5000" -ForegroundColor White
    Write-Host "  2. Drücke F5 zum Aktualisieren" -ForegroundColor White
    Write-Host "  3. Prüfe 'Debug Info' Box oben auf der Seite" -ForegroundColor White
    Write-Host ""
} else {
    if ($issues.Count -gt 0) {
        Write-Host ""
        Write-Host "? KRITISCHE FEHLER GEFUNDEN:" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "  • $issue" -ForegroundColor Red
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "??  WARNUNGEN:" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "  • $warning" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "?? EMPFOHLENE AKTIONEN:" -ForegroundColor Cyan
    Write-Host ""
    
    if ($issues -contains "Keine Prozesse gefunden") {
        Write-Host "  1. Starte das System:" -ForegroundColor White
        Write-Host "     .\scripts\start-all.ps1 -Stations 2" -ForegroundColor Gray
        Write-Host ""
    } elseif ($warnings -like "*Nur 1 Station*") {
        Write-Host "  1. Starte eine zweite Station manuell:" -ForegroundColor White
        Write-Host "     dotnet run --project station -- station-002" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  ODER System neu starten:" -ForegroundColor White
        Write-Host "     .\scripts\stop-all.ps1" -ForegroundColor Gray
        Write-Host "     .\scripts\start-all.ps1 -Stations 2" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "  1. System neu starten:" -ForegroundColor White
        Write-Host "     .\scripts\stop-all.ps1" -ForegroundColor Gray
        Write-Host "     .\scripts\start-all.ps1 -Stations 2" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host "????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""
