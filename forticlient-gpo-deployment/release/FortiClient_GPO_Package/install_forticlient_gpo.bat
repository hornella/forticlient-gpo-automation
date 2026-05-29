@echo off
setlocal enabledelayedexpansion

REM FortiClient EMS Cloud install script for GPO deployment.
REM Designed for computer startup script usage in Local System/admin context.
REM No interactive prompt is used and no reboot is forced.

set "PACKAGE_DIR=%~dp0"
set "MSI_FILE=%PACKAGE_DIR%forticlient.msi"
set "MST_FILE=%PACKAGE_DIR%forticlient.mst"
set "SETUP_EXE=%PACKAGE_DIR%forticlientsetup_7.4.7_x64.exe"
set "GROUP_TAG=YOUR_EMS_GROUP_TAG"
set "LOG_DIR=C:\ProgramData\Fortinet\FortiClient\InstallLogs"
set "LOG_FILE=%LOG_DIR%\FortiClient_GPO_install.log"
set "PRODUCT_DETECT_FILE=%TEMP%\forticlient_installed.txt"

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)

echo ============================================================ >> "%LOG_FILE%"
echo FortiClient GPO installation started: %DATE% %TIME% >> "%LOG_FILE%"
echo Hostname: %COMPUTERNAME% >> "%LOG_FILE%"
echo Package path: %PACKAGE_DIR% >> "%LOG_FILE%"
echo Group tag / Installer ID: %GROUP_TAG% >> "%LOG_FILE%"

if exist "%PRODUCT_DETECT_FILE%" (
    del "%PRODUCT_DETECT_FILE%" >nul 2>&1
)

REM Detect an existing FortiClient installation from uninstall registry entries.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$paths = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'); $product = Get-ItemProperty $paths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like '*FortiClient*' } | Select-Object -First 1; if ($product) { 'installed' }" > "%PRODUCT_DETECT_FILE%"

set "FORTICLIENT_INSTALLED="
for /f "usebackq delims=" %%A in ("%PRODUCT_DETECT_FILE%") do (
    if not defined FORTICLIENT_INSTALLED set "FORTICLIENT_INSTALLED=%%A"
)

if exist "%PRODUCT_DETECT_FILE%" (
    del "%PRODUCT_DETECT_FILE%" >nul 2>&1
)

if defined FORTICLIENT_INSTALLED (
    echo FortiClient is already installed according to Windows uninstall registry. Exiting with success. >> "%LOG_FILE%"
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

if not exist "%SETUP_EXE%" (
    echo WARNING: EMS setup EXE not found: "%SETUP_EXE%". Continuing because this GPO script installs from MSI/MST. >> "%LOG_FILE%"
)

REM If the EMS-generated package already embeds the Installer ID, you may remove
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
