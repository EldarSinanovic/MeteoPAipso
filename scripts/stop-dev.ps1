<# Stop processes started by start-dev.ps1 #>
$state = Get-Content -Raw .\dev-processes.json | ConvertFrom-Json
if ($state.LocalNode) { Stop-Process -Id $state.LocalNode -Force -ErrorAction SilentlyContinue }
if ($state.Central) { Stop-Process -Id $state.Central -Force -ErrorAction SilentlyContinue }
if ($state.Stations) { foreach ($id in $state.Stations) { Stop-Process -Id $id -Force -ErrorAction SilentlyContinue } }
Remove-Item .\dev-processes.json -ErrorAction SilentlyContinue
Write-Host "Stopped dev processes."