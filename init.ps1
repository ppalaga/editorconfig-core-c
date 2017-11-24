param(
    $pcre="8.41"
)

$ErrorActionPreference="Stop"
$dest = "bin"

if (Test-Path $dest){
    Remove-Item $dest -Recurse -Force -Confirm:$false
}

New-Item $dest -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

#####################################################################
# pcre
#####################################################################
$url = "https://ftp.pcre.org/pub/pcre/pcre-$($pcre).zip"
$output = "$dest\pcre-$($pcre).zip"

"Downloading pcre v$pcre sources" | Write-Host -ForegroundColor DarkGreen
Invoke-WebRequest -Uri $url -OutFile $output

"Extracting pcre v$pcre sources" | Write-Host -ForegroundColor DarkGreen
Expand-Archive -Path $output -DestinationPath $dest
Rename-Item -Path "$dest\pcre-$($pcre)" -NewName "pcre"

if(Test-Path "pcre-$($pcre).patch") {
    "Applying pcre patches" | Write-Host -ForegroundColor DarkGreen
    .\patch.ps1 -patch "pcre-$($pcre).patch" -path $dest\pcre
}
