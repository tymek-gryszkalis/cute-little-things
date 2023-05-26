# Aeshetic tools
function prettyCom {
    param ($contents, $type)
    if ($type -eq "installed") {
        Write-Host "✓ installed " -ForegroundColor green -NoNewLine
        Write-Host $contents
    } elseif ($type -eq "notInstalled") {
        Write-Host "✘ not installed " -ForegroundColor red -NoNewLine
        Write-Host $contents 
    } elseif ($type -eq "warning") {
        Write-Host "! warning " -ForegroundColor yellow -NoNewLine
        Write-Host $contents
    } elseif ($type -eq "question") {
        Write-Host "? " -ForegroundColor blue -NoNewLine
        Write-Host $contents
    } elseif ($type -eq "success") {
        Write-Host "☺ success " -ForegroundColor magenta -NoNewLine
        Write-Host $contents
    }
}

function br {
    Write-Host ""
}

function writeHelp {
    Write-Host "Hello future Timmy. It's probably you who's using that script anyway."
    Write-Host "Before running make sure you've installed Windows Terminal from Microsoft Store:"
    Write-Host "https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701" -ForegroundColor cyan
    Write-Host "And run it on PowerShell v7 as administrator."
    Write-Host ""
    Write-Host "You run it as:"
    Write-Host "setup.ps1 [arguments]" -ForegroundColor white
    Write-Host ""
    Write-Host "Availible arguments:"
    Write-Host "-skipFonts " -ForegroundColor green -NoNewLine
    Write-Host "skips check of fonts installed"
    Write-Host "-skipPython " -ForegroundColor green -NoNewLine
    Write-Host "skips whole python installation"
    Write-Host "-skipPythonPacks " -ForegroundColor green -NoNewLine
    Write-Host "skips installation of python packages"

    exit
}

# Default settings
$skipFonts = $false
$skipPython = $false
$skipPythonPacks = $false

#Assess input
foreach ($a in $args) {
    if ($a -eq "setup.ps1") {
        % 'foo'
    } elseif ($a -eq "-?" -or $a -eq "-help") {
        writeHelp
    } elseif ($a -eq "-SkipFonts") {
        $skipFonts = $true
    } elseif ($a -eq "-SkipPython") {
        $skipPython = $true
    } elseif ($a -eq "-SkipPythonPacks") {
        $skipPythonPacks = $true
    } else {
        Write-Host "Invalid argument. Use -help or -?."
        exit
    }
}

# Check for PowerShell
Write-host "First things first..."
$ver = [string]$host.Version
if (-Not $ver.substring(0,1) -eq 7) {
    prettyCom -contents "PowerShell version 7" -type "notInstalled"
    Write-Host "You're using an outdated version of PowerShell."
    Write-Host "Download the newest version from " -NoNewLine
    Write-Host "https://apps.microsoft.com/store/detail/powershell/9MZ1SNWT0N5D" -ForegroundColor cyan
} else {
    prettyCom -contents "Powershell version 7" -type "installed"
}

br

# Installed fonts check
if (-Not $skipFonts) { 
    $neededFonts = "CaskaydiaCode","Gohu"
    $neededFontsPaths = "$env:SYSTEMDRIVE\Windows\Fonts\CaskaydiaCoveNerdFontMono-ExtraLight.ttf","~\AppData\Local\Microsoft\Windows\Fonts\GohuFont11NerdFontMono-Regular.ttf"
    $allDone = $true
    Write-Host "Good, let's check them necessary fonts."
    for ($i = 0; $i -le ($neededFontsPaths.length - 1); $i += 1) {
        if (Test-Path -Path $neededFontsPaths[$i]) {
            prettyCom -contents $neededFonts[$i] -type "installed"
        } else {
            prettyCom -contents $neededFonts[$i] -type "notInstalled"
            $allDone = $false
        }
        
    }
    if (-Not $allDone) {
        Write-Host "You can download necessary fonts from:"
        Write-Host "https://github.com/ryanoasis/nerd-fonts/releases" -ForegroundColor cyan
        exit
    }
    prettyCom -contents "All fonts are properly installed" -type "success"
} else {
    prettyCom -contents "You decided to skip the verification of installed fonts!" -type "warning"
    Write-Host "Make sure you installed them on your own, otherwise the provided settings won't work."
}

br

# User configs
Write-Host "Now I'm gonna import some user configs."
Write-Host "Importing config from github."
mkdir ~/.config/powershell -Force | out-null
Invoke-WebRequest "https://raw.githubusercontent.com/tymek-gryszkalis/cute-little-things/main/Settings/ps_user_profile.ps1" -Headers @{"Cache-Control"="no-cache"} -OutFile ~/.config/powershell/user_profile.ps1
mkdir ~/Documents/PowerShell -Force | out-null
New-Item $PROFILE.CurrentUserCurrentHost -Force | out-null
Set-Content $PROFILE.CurrentUserCurrentHost ". $env:USERPROFILE/.config/powershell/user_profile.ps1"
prettyCom -contents "PS User Profile setup!" -type "success"
Write-Host "Importing terminal config from github."
rm ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
Invoke-WebRequest "https://raw.githubusercontent.com/tymek-gryszkalis/cute-little-things/main/Settings/terminal_settings.json" -Headers @{"Cache-Control"="no-cache"} -OutFile ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
prettyCom -contents "Terminal settings setup!" -type "success"

br

# Python
if (-Not $skipPython) {
    Write-Host "Now let's check on python."
    try {
        $pyVer = $(python -c "import sys; print(sys.version_info.major)")
        if ($pyVer -eq 3) {
            Write-Host "✓ installed " -ForegroundColor green -NoNewLine
            Write-Host "Python 3"
        } elseif ($pyVer -eq 2) {
            prettyCom -contents "Python 2 is installed. Some stuff may not work. Install Python 3 instead." -type "warning"
            Write-Host "https://www.python.org/downloads/windows/" -ForegroundColor cyan
        } else {
            prettyCom -contents "Unknown version of Python is installed. Some stuff may not work. Install Python 3 instead." -type "warning"
            Write-Host "https://www.python.org/downloads/windows/" -ForegroundColor cyan
        }
    } catch {
        Write-Host "✘ not installed " -ForegroundColor red -NoNewLine
        Write-Host "Python"
        Write-Host "https://www.python.org/downloads/windows/" -ForegroundColor cyan
        exit
    }

    Write-Host "Checking on pip."
    try {
        $out = pip --version
    } catch {
        Write-Host "Pip not found. Installing."
        python -m ensurepip --upgrade
    }
    prettyCom -contents "Pip" -type "installed"
    if (-Not $skipPythonPacks) {
        Write-Host "Installing essential packages."
        pip install flask
        prettyCom -contents "Flask" -type "installed"
        pip install flask-login
        prettyCom -contents "Flask Login" -type "installed"
        pip install SQLAlchemy
        prettyCom -contents "SQL Alchemy" -type "installed"
        pip install numpy
        prettyCom -contents "Numpy" -type "installed"
        pip install pandas
        prettyCom -contents "Pandas" -type "installed"
        pip install pygame
        prettyCom -contents "Pygame" -type "installed"
        pip install pylatex
        prettyCom -contents "PyLaTeX" -type "installed"
        pip install pysimplegui
        prettyCom -contents "PySimpleGui" -type "installed"
    } else {
        prettyCom -contents "Skipped installing python packages." -type "warning"
    }
    prettyCom -contents "Python successfuly setup!" -type "success"
} else {
    prettyCom -contents "You skipped python verification." -type "warning"
}

br

# Scoop
Write-Host "Time for Scoop and friends."
try {
    scoop info | out-null
} catch {
    Write-Host "Installing Scoop"
    Invoke-WebRequest -Uri "https://github.com/ScoopInstaller/Install/blob/master/install.ps1" -Headers @{"Cache-Control"="no-cache"} -OutFile .\install.ps1
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    rm install.ps1
}
prettyCom -contents "Scoop" -type "installed"
scoop install 7zip
prettyCom -contents "7zip" -type "installed"
scoop install curl
prettyCom -contents "Curl" -type "installed"
scoop install sudo
prettyCom -contents "Sudo" -type "installed"
scoop install jq
prettyCom -contents "JQ" -type "installed"
prettyCom -contents "Scoop successfuly setup!" -type "success"

br

# Git
Write-Host "The one, the only - Git."
try {
    git --version | out-null
} catch {
    Write-Host "Installing."
    winget install -e --id Git.Git
}
prettyCom -contents "Git" -type "installed"
prettyCom -contents "Git successfuly setup!" -type "success"

br

# Neovim
Write-Host "Time for vim. Hope you know how to enter it."
scoop install gcc
prettyCom -contents "gcc" -type "installed"
scoop install neovim
prettyCom -contents "Neovim" -type "installed"
prettyCom -contents "Neovim successfuly setup!" -type "success"

br

# Oh My Posh
Write-Host "Let's make it pretty. Oh My Posh time!"
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
Invoke-WebRequest "https://raw.githubusercontent.com/tymek-gryszkalis/cute-little-things/main/Settings/tg.omp.json" -Headers @{"Cache-Control"="no-cache"} -OutFile ~/.config/powershell/tg.omp.json
. $PROFILE
prettyCom -contents "Oh My Posh" -type "installed"
cd ~/.config/powershell
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
prettyCom -contents "Terminal icons" -type "installed"
cd ~
prettyCom -contents "Oh My Posh setup!" -type "success"

br

# NodeJS
Write-Host "NodeJS time!"
scoop install nvm
nvm install 14.16.0
prettyCom -contents "NodeJS" -type "installed"

br

# Misc
Write-Host "Some misc useful tools"
Install-Module -Name z -Scope CurrentUser -Force
prettyCom -contents "Z" -type "installed"
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
prettyCom -contents "PSReadLine" -type "installed"
scoop install fzf
Install-Module -Name PSFzf -Scope CurrentUser -Force
prettyCom -contents "Fuzzy finder" -type "installed"
prettyCom -contents "Misc tools set up!" -type "success"

br

Write-Host "That's all folks!"