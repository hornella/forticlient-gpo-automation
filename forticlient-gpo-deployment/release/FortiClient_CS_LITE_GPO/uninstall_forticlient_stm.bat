@echo off
setlocal enabledelayedexpansion

REM FortiClient EMS Cloud uninstall script for STM GPO rollback usage.
REM Uninstall behavior may depend on EMS policy, tamper protection, and administrative controls.
REM Designed for computer/system context. No interactive prompt is used and no reboot is forced.

set "LOG_DIR=C:\ProgramData\Fortinet\FortiClient\InstallLogs"
set "LOG_FILE=%LOG_DIR%\FortiClient_STM_uninstall.log"
set "PRODUCT_CODE_FILE=%TEMP%\forticlient_product_code.txt"

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)

echo ============================================================ >> "%LOG_FILE%"
echo FortiClient STM uninstall started: %DATE% %TIME% >> "%LOG_FILE%"
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
