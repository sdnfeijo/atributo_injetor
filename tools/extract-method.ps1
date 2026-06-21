param(
    [string]$File,
    [string]$Method
)

$content = Get-Content $File

$start = -1

for($i=0; $i -lt $content.Count; $i++){

    if($content[$i] -match "^\s*def\s+$Method\b"){
        $start = $i
        break
    }

}

if($start -lt 0){

    Write-Host ""
    Write-Host "METHOD NOT FOUND"
    exit

}

$depth = 0
$result = @()

for($i=$start; $i -lt $content.Count; $i++){

    $line = $content[$i]

    if($line -match "^\s*def\b"){
        $depth++
    }

    if($line -match "^\s*end\s*$"){
        $depth--
    }

    $result += $line

    if($depth -eq 0){
        break
    }

}

Write-Host ""
Write-Host "=================================================="
Write-Host "DEV LINEAR IZI"
Write-Host "=================================================="
Write-Host ""
Write-Host "METHOD: $Method"
Write-Host "FILE:   $File"
Write-Host ""
Write-Host "BEGIN_METHOD"

$result | ForEach-Object {
    Write-Host $_
}

Write-Host "END_METHOD"