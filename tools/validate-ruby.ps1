param(
    [string]$File
)

if(-not (Test-Path $File)){

    Write-Host ""
    Write-Host "FILE NOT FOUND"
    exit

}

Write-Host ""
Write-Host "======================================"
Write-Host "RUBY VALIDATION"
Write-Host "======================================"
Write-Host ""

ruby -c $File 