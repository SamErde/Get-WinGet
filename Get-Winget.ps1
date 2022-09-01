if (!(Test-Path -Path "$Env:WinDir\Temp\WinGetInstall")) {
    New-Item -ItemType Directory -Name "WinGetInstall" -Path "$Env:WinDir\Temp"
}
Set-Location -Path "$Env:WinDir\Temp\WinGetInstall"

$DownloadLinks = ( ((Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest" -UseBasicParsing).Links).Where({
    $_.outerHtml -like "*/releases/download/*" }) ).href | ForEach {
        -join ("https://github.com", $_)
    }

ForEach ($Link in $DownloadLinks) {
    $FileName = $Link -replace '^.*/'
    Invoke-WebRequest -Uri $Link -OutFile $FileName
}

# Why does this create an empty item as the first object in the array?
$Packages = $DownloadLinks.Where({ $_ -like "*.msixbundle" }) | ForEach {
    $_ -replace '^.*/'
}

# Add step to install the package.
# Add-AppxPackage only works in Windows PowerShell (not PowerShell 7).
