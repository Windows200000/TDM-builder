::::::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights V2
::::::::::::::::::::::::::::::::::::::::::::
@echo off
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
REM Run shell as admin (example) - put here code as you like


REM Own code
setlocal enabledelayedexpansion

for /f "delims=" %%i in (./settings.txt) do (
    set "line=%%i"
    rem Skip empty lines
    if not "!line!"=="" (
        set "!line!"
    )
)

cd %BUILD%
@for /f %%i in ('git ls-remote %REPO% HEAD') do @set HEAD=%%i
@set /p LastHEAD=<HEAD.txt
@if %HEAD%==%LastHEAD% (
    echo No update available
    cd %DESTINATION%
    start "" ".\Twitch Drops Miner (by DevilXD).exe"
    @cmd /k
) else (
    rmdir /s /q ".\TwitchDropsMiner"
    call git clone %REPO%
    cd TwitchDropsMiner
    echo .|call setup_env.bat
    call build.bat
    copy ".\dist\Twitch Drops Miner (by DevilXD).exe" %DESTINATION% /Y
    cd..
    >"HEAD.txt" echo(%HEAD%
    @echo "Twitch Drops Miner (by DevilXD).exe" updated
    @echo %HEAD%
    cd %DESTINATION%
        start "" ".\Twitch Drops Miner (by DevilXD).exe"
    @cmd /k
    )
)

endlocal