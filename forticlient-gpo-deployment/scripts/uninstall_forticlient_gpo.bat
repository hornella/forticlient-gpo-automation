@echo off
setlocal enabledelayedexpansion

REM FortiClient EMS Cloud uninstall script for GPO rollback usage.
REM Uninstall behavior may depend on EMS policy, tamper protection, and administrative controls.
REM Designed for computer/system context. No interactive prompt is used and no reboot is forced.

set "LOG_DIR=C:\ProgramData\Fortinet\FortiClient\InstallLogs"
set "LOG_FILE=%LOG_DIR%\FortiClient_GPO_uninstall.log"
set "PRODUCT_CODE_FILE=%TEMP%\forticlient_product_code.txt"

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)

echo ============================================================ >> "%LOG_FILE%"
echo FortiClient GPO uninstall started: %DATE% %TIME% >> "%LOG_FILE%"
echo Hostname: %COMPUTERNAME% >> "%LOG_FILE%"

if exist "%PRODUCT_CODE_FILE%" (
    del "%PRODUCT_CODE_FILE%" >nul 2>&1
)

REM Query the Windows Installer uninstall registry entries without triggering Win32_Product repairs.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$paths = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'); $product = Get-ItemProperty $paths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like '*FortiClient*' -and $_.PSChildName -match '^\{[0-9A-Fa-f-]{36}\}$' } | Select-Object -First 1; if ($product) { $product.PSChildName }" > "%PRODUCT_CODE_FILE%"

set "PRODUCT_CODE="
for /f "usebackq delims=" %%A in ("%PRODUCT_CODE_FILE%") do (
    if not defined PRODUCT_CODE set "PRODUCT_CODE=%%A"
)

if exist "%PRODUCT_CODE_FILE%" (
    del "%PRODUCT_CODE_FILE%" >nul 2>&1
)

if not defined PRODUCT_CODE (
    echo FortiClient product code was not found. Nothing to uninstall. >> "%LOG_FILE%"
    exit /b 0
)

REM -----------------------------------------------------------------
REM Simulate FortiClient GUI "Déconnecter" action before uninstall
REM -----------------------------------------------------------------

set "FORTIESNAC=%ProgramFiles%\Fortinet\FortiClient\FortiESNAC.exe"

REM Optional: if your EMS profile requires a key/password to disconnect,
REM put it here or inject it securely through GPO/environment variable.
REM Example:
REM set "DISCONNECT_KEY=YourDisconnectKey"
set "DISCONNECT_KEY="

if not exist "%FORTIESNAC%" (
    set "FORTIESNAC=%ProgramFiles(x86)%\Fortinet\FortiClient\FortiESNAC.exe"
)

if exist "%FORTIESNAC%" (
    echo Attempting FortiClient EMS disconnect using FortiESNAC.exe. >> "%LOG_FILE%"

    if defined DISCONNECT_KEY (
        "%FORTIESNAC%" -u -k "%DISCONNECT_KEY%" >> "%LOG_FILE%" 2>&1
    ) else (
        "%FORTIESNAC%" -u >> "%LOG_FILE%" 2>&1
    )

    set "DISCONNECT_EXIT_CODE=%ERRORLEVEL%"
    echo FortiClient EMS disconnect exit code: %DISCONNECT_EXIT_CODE% >> "%LOG_FILE%"

    REM Give FortiClient services time to process deregistration.
    timeout /t 20 /nobreak >nul

    echo FortiClient telemetry details after disconnect attempt: >> "%LOG_FILE%"
    "%FORTIESNAC%" -d >> "%LOG_FILE%" 2>&1
) else (
    echo FortiESNAC.exe was not found. Skipping EMS disconnect attempt. >> "%LOG_FILE%"
)

REM -----------------------------------------------------------------
REM Proceed with MSI uninstall
REM -----------------------------------------------------------------

echo Detected FortiClient product code: %PRODUCT_CODE% >> "%LOG_FILE%"
echo Running silent FortiClient uninstall. >> "%LOG_FILE%"
msiexec.exe /x "%PRODUCT_CODE%" /qn /norestart /L*v "%LOG_FILE%"
set "UNINSTALL_EXIT_CODE=%ERRORLEVEL%"

echo FortiClient uninstall exit code: %UNINSTALL_EXIT_CODE% >> "%LOG_FILE%"

if "%UNINSTALL_EXIT_CODE%"=="0" (
    echo Uninstall completed successfully. >> "%LOG_FILE%"
    exit /b 0
)

if "%UNINSTALL_EXIT_CODE%"=="3010" (
    echo Uninstall completed successfully. Reboot required but not forced. >> "%LOG_FILE%"
    exit /b 0
)

if "%UNINSTALL_EXIT_CODE%"=="1641" (
    echo Uninstall completed successfully. Windows Installer reported reboot initiated. >> "%LOG_FILE%"
    exit /b 0
)

echo ERROR: Uninstall failed with exit code %UNINSTALL_EXIT_CODE%. >> "%LOG_FILE%"
exit /b %UNINSTALL_EXIT_CODE%
