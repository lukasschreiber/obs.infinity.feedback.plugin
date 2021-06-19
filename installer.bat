@echo off

Title Installer

rem check Python

python --version 2>NUL
if ERRORLEVEL 1 GOTO NOPYTHON  
goto :HASPYTHON  
:NOPYTHON  
echo Please install Python Version v3.6.*!
exit 0

:HASPYTHON  
echo Valid Python Installation found.

rem check OBS

if exist "%ProgramFiles%\obs-studio\bin\64bit\obs64.exe" (
    echo Valid 64bit OBS Installation found.
) else (
    echo Please install OBS!
    exit 0
)

rem Create Folder Structure

if not exist "%UserProfile%\obs\scripts\InfinityFeedback" (
    mkdir "%UserProfile%\obs\scripts\InfinityFeedback"
)

if not exist "%UserProfile%\obs\scripts\InfinityFeedback\UI" (
    mkdir "%UserProfile%\obs\scripts\InfinityFeedback\UI"
)

rem Copy Files

echo.
>nul 2>nul dir /a-d "%UserProfile%\obs\scripts\InfinityFeedback\UI\*" && (goto OVERWRITE_UI) || (goto COPY_UI)
:OVERWRITE_UI
SET /P AREYOUSURE=[33mThe UI Files will be updated and therefore overwritten. Do you want to continue (Y/[N])?[0m
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END_UI

echo Overwriting...

goto END_UI

:COPY_UI
echo Copying...

:END_UI

echo.
>nul 2>nul dir /a-d "%UserProfile%\obs\scripts\InfinityFeedback\*" && (goto OVERWRITE) || (goto COPY)
:OVERWRITE
SET /P AREYOUSURE=[33mThe Script Files will be updated and therefore overwritten. Do you want to continue (Y/[N])?[0m
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END

echo Overwriting...

goto END

:COPY
echo Copying...

:END

echo.
echo.
echo [32m####################################################[0m
echo [32m########################Done########################[0m
echo [32m####################################################[0m

rem Output
echo.
echo Please follow the installation guide in the README.md
echo Your UI file: [32m %UserProfile%\obs\scripts\InfinityFeedback\UI\broadcaster_ui.html[0m
echo Your Script file: [32m %UserProfile%\obs\scripts\InfinityFeedback\obs_plugin_socket.py[0m
echo.
echo You have to manually paste both paths in OBS
