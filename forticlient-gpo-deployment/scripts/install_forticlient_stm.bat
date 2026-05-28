@echo off
setlocal enabledelayedexpansion

REM FortiClient EMS Cloud install script for STM GPO deployment.
REM Designed for computer startup script usage in Local System/admin context.
REM No interactive prompt is used and no reboot is forced.

set "PACKAGE_DIR=%~dp0"
set "MSI_FILE=%PACKAGE_DIR%FortiClient.msi"
set "MST_FILE=%PACKAGE_DIR%FortiClient.mst"
set "GROUP_TAG=STM-VPN-CERT"
set "LOG_DIR=C:\ProgramData\Fortinet\FortiClient\InstallLogs"
set "LOG_FILE=%LOG_DIR%\FortiClient_STM_install.log"
set "FORTICLIENT_EXE=C:\Program Files\Fortinet\FortiClient\FortiClient.exe"

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)

echo ============================================================ >> "%LOG_FILE%"
echo FortiClient STM installation started: %DATE% %TIME% >> "%LOG_FILE%"
echo Hostname: %COMPUTERNAME% >> "%LOG_FILE%"
echo Package path: %PACKAGE_DIR% >> "%LOG_FILE%"
echo Group tag / Installer ID: %GROUP_TAG% >> "%LOG_FILE%"

if exist "%FORTICLIENT_EXE%" (
    echo FortiClient is already installed at "%FORTICLIENT_EXE%". Exiting with success. >> "%LOG_FILE%"
    exit /b 0
)

if not exist "%MSI_FILE%" (
    echo ERROR: Missing MSI file: "%MSI_FILE%" >> "%LOG_FILE%"
    exit /b 2
)

if not exist "%MST_FILE%" (
    echo ERROR: Missing MST file: "%MST_FILE%" >> "%LOG_FILE%"
    exit /b 3
)

REM If the EMS-generated package already embeds the Installer ID, STM/ARTM may remove
REM GROUP_TAG="%GROUP_TAG%" from the msiexec command below.
echo Running silent FortiClient installation. >> "%LOG_FILE%"
msiexec.exe /i "%MSI_FILE%" TRANSFORMS="%MST_FILE%" GROUP_TAG="%GROUP_TAG%" /qn /norestart /L*v "%LOG_FILE%"
set "INSTALL_EXIT_CODE=%ERRORLEVEL%"

echo FortiClient installer exit code: %INSTALL_EXIT_CODE% >> "%LOG_FILE%"

if "%INSTALL_EXIT_CODE%"=="0" (
    echo Installation completed successfully. >> "%LOG_FILE%"
    exit /b 0
)

if "%INSTALL_EXIT_CODE%"=="3010" (
    echo Installation completed successfully. Reboot required but not forced. >> "%LOG_FILE%"
    exit /b 0
)

if "%INSTALL_EXIT_CODE%"=="1641" (
    echo Installation completed successfully. Windows Installer reported reboot initiated. >> "%LOG_FILE%"
    exit /b 0
)

echo ERROR: Installation failed with exit code %INSTALL_EXIT_CODE%. >> "%LOG_FILE%"
exit /b %INSTALL_EXIT_CODE%
