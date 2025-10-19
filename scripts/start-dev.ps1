<#
Starts local development environment:
- localnode (gRPC server on localhost:5001)
- central (Blazor server)
- multiple station simulator instances

Usage: .\scripts\start-dev.ps1 -Stations 3
#>
param(
    [int]$Stations = 3
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptDir\..\

Write-Host "Starting LocalNode (port 5001)..."
$localnode = Start-Process -FilePath dotnet -ArgumentList 'run','--project','localnode\localnode.csproj' -NoNewWindow -PassThru

Start-Sleep -Seconds 2

Write-Host "Starting Central (Blazor)..."
$central = Start-Process -FilePath dotnet -ArgumentList 'run','--project','central\central.csproj' -NoNewWindow -PassThru

Start-Sleep -Seconds 2

$stationProcs = @()
for ($i = 1; $i -le $Stations; $i++) {
    $id = "station-$([string]::Format('{0:000}',$i))"
    Write-Host "Starting Station $id..."
    $p = Start-Process -FilePath dotnet -ArgumentList 'run','--project','station\station.csproj','--','$id' -NoNewWindow -PassThru
    $stationProcs += $p
    Start-Sleep -Milliseconds 500
}

# Save PIDs for stop script
$state = @{
    LocalNode = $localnode.Id
    Central = $central.Id
    Stations = $stationProcs | ForEach-Object { $_.Id }
}
$state | ConvertTo-Json | Out-File -FilePath ".\dev-processes.json" -Encoding utf8

Write-Host "Started processes. PIDs saved to dev-processes.json"
Write-Host "LocalNode: http://localhost:5001 (gRPC endpoint)", "Central (Blazor): http://localhost:5000 or https://localhost:5001"
Write-Host "Open http://localhost:5000/aggregates after services are running to see aggregated data (may take a minute)."
Write-Host "To stop: .\scripts\stop-dev.ps1"