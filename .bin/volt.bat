@echo off
set ips[0]=volt.zet.pw.edu.pl
set ips[1]=volt.zet
set ips[2]=vol.zet.pw.edu.pl
set ips[3]=vol.zet
setlocal enabledelayedexpansion
for /l %%a in (0,1,3) do (
    ping -n 1 !ips[%%a]! | find "TTL" > nul
    if errorlevel 1 set msg=is not availible
    if not errorlevel 1 set msg=right
    if !msg!==right (
        echo !ips[%%a]! is availible.
        echo Connecting...
        ssh gryszkat@!ips[%%a]!
        exit /B
    )
    echo !ips[%%a]! !msg!
)