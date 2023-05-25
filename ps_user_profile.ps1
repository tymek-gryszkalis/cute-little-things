# Prompt
oh-my-posh init pwsh | Invoke-Expression

# Load prompt config
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }
$PROMPT_CONFIG = Join-Path (Get-ScriptDirectory) 'tg.omp.json'

# Alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias .. cd..
Set-Alias g git
Set-Alias grep findstr