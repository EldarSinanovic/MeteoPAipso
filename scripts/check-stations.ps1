<#
.SYNOPSIS
    Zeigt Live-Daten von LocalNode
#>

Write-Host "Prüfe welche Stationen bei LocalNode registriert sind..." -ForegroundColor Cyan
Write-Host ""

# Warte kurz
Start-Sleep -Seconds 1

# Zeige laufende Station-Prozesse
$stations = Get-Process | Where-Object { 
    $_.ProcessName -eq 'dotnet' -and 
    $_.CommandLine -like '*station*' -and
    $_.CommandLine -notlike '*localnode*' -and
    $_.CommandLine -notlike '*central*'
}

Write-Host "???????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "Laufende Station-Prozesse:" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????" -ForegroundColor Cyan

if ($stations.Count -eq 0) {
    Write-Host ""
    Write-Host "? KEINE Stationen laufen!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Starte Stationen mit:" -ForegroundColor Yellow
    Write-Host "  .\scripts\start-all.ps1 -Stations 2" -ForegroundColor White
    Write-Host ""
    exit
}

Write-Host ""
Write-Host "Gefunden: $($stations.Count) Station(en)" -ForegroundColor Green
Write-Host ""

foreach ($s in $stations) {
    $cmdLine = $s.CommandLine
    if ($cmdLine -match 'station-\d+') {
        $stationId = $matches[0]
        Write-Host "  ? $stationId (PID: $($s.Id))" -ForegroundColor Green
    } else {
        Write-Host "  ? PID: $($s.Id)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "???????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

if ($stations.Count -eq 1) {
    Write-Host "??  NUR 1 STATION LÄUFT!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Problem gefunden: Du hast nur eine Station gestartet." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Lösung:" -ForegroundColor Cyan
    Write-Host "  1. Öffne ein NEUES PowerShell-Fenster" -ForegroundColor White
    Write-Host "  2. Führe aus:" -ForegroundColor White
    Write-Host "     cd C:\Users\sinan\source\repos\MeteoPAipso" -ForegroundColor Gray
    Write-Host "     dotnet run --project station -- station-002" -ForegroundColor Gray
    Write-Host ""
    Write-Host "ODER System komplett neu starten:" -ForegroundColor Cyan
    Write-Host "  .\scripts\stop-all.ps1" -ForegroundColor Gray
    Write-Host "  .\scripts\start-all.ps1 -Stations 2" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "? Mehrere Stationen laufen - das ist gut!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Wenn im Frontend trotzdem nur 1 Station sichtbar ist:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Öffne Browser DevTools (F12)" -ForegroundColor White
    Write-Host "2. Gehe zu 'Console' Tab" -ForegroundColor White
    Write-Host "3. Lade die Seite neu (Ctrl+F5)" -ForegroundColor White
    Write-Host "4. Schau nach Fehlern in der Console" -ForegroundColor White
    Write-Host ""
    Write-Host "Prüfe auch die PowerShell-Fenster der Stationen:" -ForegroundColor White
    Write-Host "  • Siehst du 'ok=True' in beiden Fenstern?" -ForegroundColor Gray
    Write-Host "  • Oder 'ok=False' (Fehler beim Senden)?" -ForegroundColor Gray
    Write-Host ""
}
