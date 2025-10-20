<#
.SYNOPSIS
    Startet DEFINITIV eine zweite Station
#>

Write-Host ""
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "?  Starte Station-002 (Zweite Station)          ?" -ForegroundColor Green
Write-Host "??????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""

$projectRoot = "C:\Users\sinan\source\repos\MeteoPAipso"

# Prüfe ob schon eine station-002 läuft
$existing = Get-Process | Where-Object { 
    $_.CommandLine -like '*station*station-002*'
}

if ($existing) {
    Write-Host "??  Station-002 läuft bereits (PID: $($existing.Id))" -ForegroundColor Yellow
    Write-Host ""
    $kill = Read-Host "Soll ich sie neu starten? (j/n)"
    if ($kill -eq 'j') {
        Stop-Process -Id $existing.Id -Force
        Write-Host "? Alte Station-002 beendet" -ForegroundColor Green
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Abbruch." -ForegroundColor Gray
        exit
    }
}

Write-Host "Starte Station-002..." -ForegroundColor Cyan
Write-Host ""

# Starte station-002 in neuem Fenster
Start-Process powershell -ArgumentList `
    "-NoExit", `
    "-Command", `
    "Set-Location '$projectRoot'; `
     `$Host.UI.RawUI.WindowTitle = 'MeteoIpso - Station-002'; `
     Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
     Write-Host '  Station-002 wird gestartet...' -ForegroundColor Yellow; `
     Write-Host '????????????????????????????????????' -ForegroundColor Cyan; `
     Write-Host ''; `
     dotnet run --project station -- station-002"

Write-Host "? Station-002 gestartet!" -ForegroundColor Green
Write-Host ""
Write-Host "Ein neues PowerShell-Fenster sollte sich geöffnet haben." -ForegroundColor White
Write-Host ""
Write-Host "Prüfe in diesem Fenster:" -ForegroundColor Yellow
Write-Host "  • Siehst du '[station-002] sent ...'?" -ForegroundColor Gray
Write-Host "  • Steht 'ok=True' dabei?" -ForegroundColor Gray
Write-Host ""
Write-Host "Warte 10 Sekunden, dann:" -ForegroundColor Yellow
Write-Host "  1. Öffne http://localhost:5000" -ForegroundColor White
Write-Host "  2. Drücke Ctrl+F5 (Hard Refresh)" -ForegroundColor White
Write-Host "  3. Beide Stationen sollten sichtbar sein!" -ForegroundColor White
Write-Host ""

# Warte 10 Sekunden
Write-Host "Warte 10 Sekunden auf Initialisierung..." -ForegroundColor Cyan
for ($i = 10; $i -gt 0; $i--) {
    Write-Host "`r  $i Sekunden... " -NoNewline
    Start-Sleep -Seconds 1
}
Write-Host "`r  ? Fertig!        " -ForegroundColor Green
Write-Host ""

# Öffne Browser
Write-Host "Öffne Browser..." -ForegroundColor Cyan
Start-Process "http://localhost:5000"

Write-Host ""
Write-Host "? Station-002 läuft jetzt!" -ForegroundColor Green
Write-Host ""
