param(
    [string]$Project
)

if(-not (Test-Path $Project)){

    Write-Host ""
    Write-Host "PROJECT NOT FOUND"
    exit

}

$timestamp =
    Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

New-Item `
    -ItemType Directory `
    -Force `
    ".\checkpoints" | Out-Null

$destination =
    ".\checkpoints\$timestamp.zip"

Compress-Archive `
    -Path "$Project\*" `
    -DestinationPath $destination `
    -Force

Write-Host ""
Write-Host "======================================"
Write-Host "CHECKPOINT CREATED"
Write-Host "======================================"
Write-Host ""
Write-Host $destination