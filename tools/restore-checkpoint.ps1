param(
    [string]$Checkpoint,
    [string]$Project
)

if(-not (Test-Path $Checkpoint)){

    Write-Host ""
    Write-Host "CHECKPOINT NOT FOUND"
    exit

}

if(-not (Test-Path $Project)){

    Write-Host ""
    Write-Host "PROJECT NOT FOUND"
    exit

}

Expand-Archive `
    -Path $Checkpoint `
    -DestinationPath $Project `
    -Force

Write-Host ""
Write-Host "======================================"
Write-Host "RESTORE COMPLETE"
Write-Host "======================================"
Write-Host ""
Write-Host $Checkpoint