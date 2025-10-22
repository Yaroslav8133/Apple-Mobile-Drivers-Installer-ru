## Apple USB and Mobile Device Ethernet drivers installer!
## Please report any issues at GitHub: https://github.com/NelloKudo/Apple-Mobile-Drivers-Installer

## Download links for Apple USB Drivers and Apple Mobile Ethernet USB Drivers respectively.
## All of these are downloaded from Microsoft's Update Catalog, which you can browse yourself at here: https://www.catalog.update.microsoft.com/

$AppleDri1 = "https://downloader.disk.yandex.ru/disk/e92f44ff206c577c656fa54d731aa568fb5d4ee9624e04e977388088616b344c/68f93eb0/Q2aE2Ho4XamG6jq-JEKFwtlI8OPM_sB7r_21eXNHWrrNjdvuAeDJ409W9Fda1i18nSoMw_ssyJSfDsGYn0rnMg%3D%3D?uid=0&filename=01d96dfd-2f6f-46f7-8bc3-fd82088996d2_a31ff7000e504855b3fa124bf27b3fe5bc4d0893.cab&disposition=attachment&hash=7b22J6/1yPtrrXkVsMsWSXtXclX3o0UHlNvw8cKJ000PaBGF5mvHkIetgB3gDb8Aq/J6bpmRyOJonT3VoXnDag%3D%3D&limit=0&content_type=application%2Fvnd.ms-cab-compressed&owner_uid=1020185368&fsize=88728&hid=6fe41749b87bbe1dcf6dd5854baa237b&media_type=unknown&tknv=v3"
$AppleDri2 = "https://downloader.disk.yandex.ru/disk/f1ec22cce699f3d7808897e6dce038042176d063adf2f3a555109d8e9f61a87a/68f93e7e/Q2aE2Ho4XamG6jq-JEKFwrChSx2v-en8K3X_MuUP3BBh5KQgy8JV-qpFG7GpE-jhRz3oWRloIk6LKgUI1WEAiw%3D%3D?uid=0&filename=netaapl_7503681835e08ce761c52858949731761e1fa5a1.cab&disposition=attachment&hash=aMYICgv24xWgu21tpoFltmAXBFj0WQ/FLuY%2BU6eRcbAZUeh5rmXl9TdMQS11FwOcq/J6bpmRyOJonT3VoXnDag%3D%3D&limit=0&content_type=application%2Fvnd.ms-cab-compressed&owner_uid=1020185368&fsize=1833386&hid=d75a8cabc564f085df0c61ab8dc85662&media_type=unknown&tknv=v3"
$AppleITunesLink = "https://www.apple.com/itunes/download/win64"

Write-Host ""
Write-Host -ForegroundColor Cyan "Welcome to Apple USB and Mobile Device Ethernet drivers installer!!"
Write-Host ""

## Checking if the script is being run as admin..
if (-not ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')) {
    Write-Host -ForegroundColor Yellow "This script requires administrative privileges!"
    Write-Host -ForegroundColor Yellow "Please run the script as an administrator if you want to install drivers."
    pause
    exit 1
}

## Preparing the system to actually download drivers..
$destinationFolder = [System.IO.Path]::Combine($env:TEMP, "AppleDriTemp")
if (-not (Test-Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

try {
    $currentPath = $PWD.Path
    Write-Host -ForegroundColor Yellow "Downloading Apple iTunes and installing AppleMobileDeviceSupport64.msi.."
    Write-Host -ForegroundColor Yellow "(It might take a while! Script is not frozen!)"
    (New-Object System.Net.WebClient).DownloadFile($AppleITunesLink, [System.IO.Path]::Combine($destinationFolder, "iTunes64Setup.exe"))
    cd "$destinationFolder"
    Start-Process -FilePath "$destinationFolder\iTunes64Setup.exe" -ArgumentList "/extract" -Wait
    cd "$currentPath"
    Start-Process -FilePath "$destinationFolder\AppleMobileDeviceSupport64.msi" -ArgumentList "/qn" -Wait

    Write-Host -ForegroundColor Yellow "Downloading Apple USB and Mobile Device Ethernet drivers from Microsoft..."
    Invoke-WebRequest -Uri $AppleDri1 -OutFile ([System.IO.Path]::Combine($destinationFolder, "AppleUSB-486.0.0.0-driv.cab"))
    Invoke-WebRequest -Uri $AppleDri2 -OutFile ([System.IO.Path]::Combine($destinationFolder, "AppleNet-1.8.5.1-driv.cab"))

    Write-Host -ForegroundColor Yellow "Extracting drivers..."
    & expand.exe -F:* "$destinationFolder\AppleUSB-486.0.0.0-driv.cab" "$destinationFolder" >$null 2>&1
    & expand.exe -F:* "$destinationFolder\AppleNet-1.8.5.1-driv.cab" "$destinationFolder" >$null 2>&1

    ## Installing drivers..
    Write-Host -ForegroundColor Yellow "Installing Apple USB and Mobile Device Ethernet drivers!"
    Write-Host -ForegroundColor Yellow "If any of your peripherals stop working for a few seconds that's due to Apple stuff installing."
    Write-Host ""
    Get-ChildItem -Path "$destinationFolder\*.inf" | ForEach-Object {
        pnputil /add-driver $_.FullName /install
        Write-Host ""
        Write-Host -ForegroundColor Yellow "Driver installed.."
        Write-Host ""
    }

    ## Cleaning..
    Remove-Item -Path $destinationFolder -Recurse -Force

} catch {
    Write-Host -ForegroundColor Red "Failed to complete installation. Error: $_"
}

Write-Host ""
Write-Host -ForegroundColor Cyan "Installation complete! Enjoy your Apple devices!!"

Write-Host -ForegroundColor Yellow "(If devices are still not working, a reboot might be needed!!)"
