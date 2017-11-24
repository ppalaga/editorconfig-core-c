param(
    [ValidateSet("pcre","core", "all")]
    [string] $proj = "all",

    [switch] $init,

    [switch] $install,

    [ValidateSet("ON","OFF")]
    [string] $static = "ON",

    [ValidateSet("Debug","Release")]
    [string] $config = "Release",

    [ValidateSet("x86","x64")]
    [string] $arch = "x64",


    [ValidateSet("15","14","12")]
    [int] $vsver = 15
)

# $ErrorActionPreference="stop"
Set-PSDebug -Trace 2
echo $PSVersionTable.PSVersion

cmake -h

if ($proj -eq "all"){
    .\build.ps1 -proj pcre -init:$init -install:$install -arch $arch -config $config -static $static
    .\build.ps1 -proj core -init:$init -install:$install -arch $arch -config $config -static $static
    return
}

$PREFIX="../build"

$dest = "bin"

if ((Test-Path $dest) -ne $true){
    throw "Missing build path! Used init?"
}

$dest += "\$arch"

if($static -eq "ON"){
    $dest += "-static"
}

$dest += "\$proj"

if ($init) {
    "Generating $proj build files" | Write-Host -ForegroundColor DarkGreen

    $gen = "Visual Studio "

    switch ($vsver) {
        15 {
            $gen += "15 2017"
        }
        14 {
            $gen += "14 2015"
        }
        12 {
            $gen += "12 2013"
        }
        default {
            throw "Visual Studio version $vsver not supported!"
        }
    }

    if($arch -eq "x64"){
        $gen += " Win64"
    }

    echo "making dir $dest"

    mkdir $dest -ErrorAction SilentlyContinue | Out-Null
    Push-Location $dest

    echo "about to switch $proj"

    switch ($proj) {
        pcre {
            $BUILD_SHARED_LIBS = "ON"
            if ($static -eq "ON"){ $BUILD_SHARED_LIBS = "OFF"}
            echo "about to cmake $proj in $pwd"
            cmake -G "$gen" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DPCRE_STATIC_RUNTIME="$static" -DBUILD_SHARED_LIBS="$BUILD_SHARED_LIBS" -DPCRE_BUILD_PCRECPP=OFF -DPCRE_BUILD_PCREGREP=OFF -DPCRE_BUILD_TESTS=OFF "../../pcre" *>> C:\projects\editorconfig-core-c\bin\pcre-build.log
            # -DPCRE_SUPPORT_JIT=ON -DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON
            echo "cmake $proj finished"
        }
        core {
            $MSVC_MD = "ON"
            if ($static -eq "ON"){ $MSVC_MD = "OFF"}
            cmake -G "$gen" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DMSVC_MD="$MSVC_MD" -DPCRE_STATIC="$static" "../../../."
        }
    }
    Pop-Location
}

if ((Test-Path $dest) -ne $true){
    throw "Missing build path! Used init?"
}

"Compiling $proj" | Write-Host -ForegroundColor DarkGreen

cmake --build $dest `-- /p:Configuration=$config

if ($install) {
    "Installing $proj" | Write-Host -ForegroundColor DarkGreen
    switch ($proj) {
        pcre {
            cmake --build $dest --target install `-- /p:Configuration=$config
        }
        core {
            cmake --build $dest --target install `-- /p:Configuration=$config
        }
    }
}
