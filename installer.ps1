<#
        
        .SYNOPSIS
        Auto Installer for Oh-My-Posh in PowerShell

        .DESCRIPTION
        Install Oh-My-Posh in PowerShell

        .EXAMPLE
        PS> Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/mvanetten/Oh-My-Posh-AutoInstaller/installer.ps1'))

        .LINK
        Online version: https://github.com/mvanetten/Oh-My-Posh-AutoInstaller/


#>
    
Write-Host " Mr PowerShell says hi! " -NoNewLine
Write-Host "!" -ForegroundColor Yellow
Write-Host " " -ForegroundColor White

if ($PSVersionTable.PSVersion.Major -ne 7){
    Write-Host " This installer is for PowerShell 7.x or newer" -ForegroundColor Yellow
    Write-Host " Download Latest PowerShell verions : https://github.com/PowerShell/PowerShell" -ForegroundColor Yellow
    exit
}

function Install-Fonts($tmpdir){
    $SourceDir   = $tmpdir
    $Source      = $tmpdir
    $Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    $TempFolder  = "$env:windir\Temp\Fonts"

    # Create the source directory if it doesn't already exist
    New-Item -ItemType Directory -Force -Path $SourceDir

    New-Item $TempFolder -Type Directory -Force | Out-Null

    Get-ChildItem -Path $Source -Include '*.ttf','*.ttc','*.otf' -Recurse | ForEach-Object {
        If (-not(Test-Path "$env:windir\Fonts\$($_.Name)")) {

            $Font = "$TempFolder\$($_.Name)"
            
            # Copy font to local temporary folder
            Copy-Item $($_.FullName) -Destination $TempFolder
            
            # Install font
            $Destination.CopyHere($Font,0x10)

            # Delete temporary copy of font
            Remove-Item $Font -Force
        }
    }
}

$installer = ''
$arch = (Get-CimInstance -Class Win32_Processor -Property Architecture).Architecture
switch ($arch) {
    0 { $installer = "install-386.exe" } # x86
    5 { $installer = "install-arm64.exe" } # ARM
    9 {
        if ([Environment]::Is64BitOperatingSystem) {
            $installer = "install-amd64.exe"
        } else {
            $installer = "install-386.exe"
        }
    }
    12 { $installer = "install-amd64.exe" } # x64 emulated on Surface Pro X
}

if ($installer -eq '') {
    Write-Host " The installer for system architecture ($arch) is not available." -ForegroundColor Yellow
    exit
}

Write-Host " Downloading $installer..."
$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'exe' } -PassThru
$url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/$installer"
Invoke-WebRequest -OutFile $tmp $url
Write-Host " Running installer..."
& $tmp /VERYSILENT "/CURRENTUSER" | Out-Null 
$tmp | Remove-Item


$choice = Read-Host " Do you want to install Font Cousine NFM? (y/n)"
if ($choice -ieq 'y'){
    Write-Host " Downloading Cousine Nerd Font..."
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Cousine.zip"
    Invoke-WebRequest -OutFile $tmp $url
    Write-Host " Install Cousine Nerd Font..."
    $tempfolder = $env:TEMP + '\Cousine\'
    Expand-Archive -Path $tmp -DestinationPath $tempfolder -Force
    Write-Host " Installing Font Cousine NFM"
    Install-Fonts($tempfolder) 
}
else{
    Write-Host " Font installation skipped." -ForegroundColor Yellow
}


Write-Host " Installing Module Terminal-Icons."
if (!(Get-Module -Name Terminal-Icons)){
    Install-Module -Name Terminal-Icons -Repository PSGallery -ErrorAction Inquire
}

If (!(Get-Content $PROFILE | %{$_ -match "Generated By Mr PowerShell"})){
    Add-Content -Path $PROFILE -Value "`n### Generated By Mr PowerShell - START ###"
    Add-Content -Path $PROFILE -Value "if ($PSVersionTable.PSVersion -eq 7){"
    if (Get-Module -Name Terminal-Icons){
        Add-Content -Path $PROFILE -Value "   Import-Module -Name Terminal-Icons"    
    }
    Add-Content -Path $PROFILE -Value "   oh-my-posh init pwsh | Invoke-Expression"
    Add-Content -Path $PROFILE -Value "}"
    Add-Content -Path $PROFILE -Value "### Generated By Mr PowerShell - END ###"
    Write-Host " Modified $PROFILE"
}

Write-Host " -------------------------------------------------------------" -ForegroundColor White
Write-Host " "
Write-Host " 1) Restart computer to load new fonts." -ForegroundColor Yellow
Write-Host " 2) Open PowerShell as administrator." -ForegroundColor Yellow
Write-Host " 3) Right Click on PowerShell Title Bar and select Properties." -ForegroundColor Yellow
Write-Host " 4) Select font Cousine NFM in Font Tab." -ForegroundColor Yellow
Write-Host " "
Write-Host " -------------------------- DONE -----------------------------" -ForegroundColor White
