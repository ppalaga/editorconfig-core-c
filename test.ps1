param(
    [ValidateSet("pcre","core")]
    [string] $proj = "core",

    [ValidateSet("ON","OFF")]
    [string] $static = "ON",

    [ValidateSet("Debug","Release")]
    [string] $config = "Release",

    [ValidateSet("x86","x64")]
    [string] $arch = "x64"
)

# $ErrorActionPreference="stop"


$dest = "bin"

if ((Test-Path $dest) -ne $true){
    throw "Missing build path! Used init?"
}

$dest += "\$arch"

if($static -eq "ON"){
    $dest += "-static"
}

$dest += "\$proj"

if ((Test-Path $dest) -ne $true){
    throw "Missing build path! Used init?"
}

$env:Path += ";" + (Resolve-Path bin\$arch\build\bin)

"Testing $proj" | Write-Host -ForegroundColor DarkGreen
cmake --build $dest --target run_tests `-- /p:Configuration=$config
