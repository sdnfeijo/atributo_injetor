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
$end = $start

for($i=$start; $i -lt $content.Count; $i++){

    if($content[$i] -match "^\s*def\b"){
        $depth++
    }

    if($content[$i] -match "^\s*end\s*$"){
        $depth--
    }

    if($depth -eq 0){
        $end = $i
        break
    }

}

Write-Host ""
Write-Host "=================================================="
Write-Host "DEV LINEAR IZI"
Write-Host "=================================================="
Write-Host ""
Write-Host "PASTE METHOD BELOW"
Write-Host ""
Write-Host "FINISH WITH:"
Write-Host "END_METHOD"
Write-Host ""

$buffer = @()

while($true){

    $line = Read-Host

    if($line -eq "END_METHOD"){
        break
    }

    $buffer += $line

}

$before =
    if($start -gt 0){
        $content[0..($start-1)]
    }else{
        @()
    }

$after =
    if($end -lt ($content.Count-1)){
        $content[($end+1)..($content.Count-1)]
    }else{
        @()
    }

(
    $before +
    $buffer +
    $after
) | Set-Content $File

Write-Host ""
Write-Host "METHOD REPLACED"
Write-Host ""
Write-Host "FILE:"
Write-Host $File