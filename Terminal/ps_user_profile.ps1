# Load prompt config
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }
$PROMPT_CONFIG = Join-Path (Get-ScriptDirectory) 'tg.omp.json'
oh-my-posh init pwsh --config $PROMPT_CONFIG | Invoke-Expression

# Icons
Import-Module Terminal-Icons

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias .. cd..
Set-Alias g git
Set-Alias grep findstr
Set-Alias volt volt.bat
Set-Alias sortdir sortdir.ps1
Set-Alias colors listcolors.ps1
Set-Alias upcon updateConfig.ps1
function jbfoo {
  code ~/coding/Repos/advent-of-code
}
Set-Alias jingle-bells jbfoo