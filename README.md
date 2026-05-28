# FortiClient GPO Automation

This repository contains the deployment material for a FortiClient EMS Cloud package intended to be deployed by STM through Microsoft Group Policy.

ARTM prepares the package and scripts. STM receives a small release folder, adds it to the appropriate GPO distribution location, and runs the installer as a computer startup script.

## Context

STM requested an MSI-based FortiClient deployment package with the required supporting files and a `.bat` script for silent installation through GPO.

The current package targets the CS LEGER deployment profile:

- EMS group tag / Installer ID: `VP_CS_LEGER`
- VPN profile expected from EMS: `VPN-CERT`
- Deployment method: Microsoft GPO computer startup script
- Execution context: computer context / Local System / administrative context
- Reboot behavior: do not force reboot
- Logging path: `C:\ProgramData\Fortinet\FortiClient\InstallLogs`

The FortiClient binaries are generated from FortiClient EMS Cloud and are not stored in this repository.

## Repository Layout

```text
forticlient-gpo-automation/
├── README.md
├── .gitignore
└── forticlient-gpo-deployment/
    ├── README_STM_Deploiement_GPO.md
    ├── CHANGELOG.md
    ├── package/
    │   └── README_PLACE_FORTICLIENT_FILES_HERE.md
    ├── scripts/
    │   ├── install_forticlient_stm.bat
    │   └── uninstall_forticlient_stm.bat
    ├── docs/
    │   ├── validation_checklist.md
    │   └── email_instructions_STM.md
    └── release/
        └── FortiClient_CS_LITE_GPO/
            ├── install_forticlient_stm.bat
            ├── uninstall_forticlient_stm.bat
            └── README_STM_Deploiement_GPO.txt
```

`docs/email_instructions_STM.md` is an internal helper note and is ignored by Git. It should not be included in the STM release package.

## EMS Generated Files

The EMS-generated files must be copied manually when building the final package:

```text
forticlient.msi
forticlient.mst
forticlientsetup_7.4.7_x64.exe
```

The install script currently uses the MSI/MST files for installation:

```bat
set "MSI_FILE=%PACKAGE_DIR%forticlient.msi"
set "MST_FILE=%PACKAGE_DIR%forticlient.mst"
set "SETUP_EXE=%PACKAGE_DIR%forticlientsetup_7.4.7_x64.exe"
```

The setup EXE is expected as part of the EMS package, but the GPO installation command is MSI-based.

## What The Install Script Does

[install_forticlient_stm.bat](forticlient-gpo-deployment/scripts/install_forticlient_stm.bat) is designed for GPO startup script usage.

It performs these actions:

- Creates `C:\ProgramData\Fortinet\FortiClient\InstallLogs` if needed.
- Logs the start time, hostname, package path, and group tag.
- Detects an existing FortiClient installation from the Windows uninstall registry.
- Exits successfully if FortiClient is already installed.
- Validates that `forticlient.msi` exists.
- Validates that `forticlient.mst` exists.
- Warns if `forticlientsetup_7.4.7_x64.exe` is missing, but continues because installation uses MSI/MST.
- Runs a silent install with `msiexec.exe`.
- Uses `GROUP_TAG=VP_CS_LEGER`.
- Uses `/qn` and `/norestart`.
- Treats installer exit codes `0`, `3010`, and `1641` as success.
- Returns any other MSI exit code for troubleshooting.

The install command is:

```bat
msiexec.exe /i "%MSI_FILE%" TRANSFORMS="%MST_FILE%" GROUP_TAG="%GROUP_TAG%" /qn /norestart /L*v "%LOG_FILE%"
```

## What The Uninstall Script Does

[uninstall_forticlient_stm.bat](forticlient-gpo-deployment/scripts/uninstall_forticlient_stm.bat) is intended for rollback scenarios.

It performs these actions:

- Creates the same FortiClient install log directory if needed.
- Logs the start time and hostname.
- Looks up the installed FortiClient MSI product code from Windows uninstall registry entries.
- Exits successfully if FortiClient is not found.
- Runs a silent uninstall with `msiexec.exe /x`.
- Uses `/qn` and `/norestart`.
- Treats uninstall exit codes `0`, `3010`, and `1641` as success.
- Returns any other MSI exit code for troubleshooting.

Uninstall behavior may depend on EMS policy, tamper protection, and administrative controls.

## Release Folder

The folder intended to be zipped and sent to STM is:

```text
forticlient-gpo-deployment/release/FortiClient_CS_LITE_GPO/
```

Before zipping, manually copy the EMS-generated files into that release folder:

```text
FortiClient_CS_LITE_GPO/
├── forticlient.msi
├── forticlient.mst
├── forticlientsetup_7.4.7_x64.exe
├── install_forticlient_stm.bat
├── uninstall_forticlient_stm.bat
└── README_STM_Deploiement_GPO.txt
```

Only this release folder should be zipped for STM. The broader repo docs, internal email notes, and staging material are for ARTM/developer use.

## STM Deployment Summary

STM should deploy the install script as a computer startup script:

```text
Computer Configuration
└── Policies
    └── Windows Settings
        └── Scripts (Startup/Shutdown)
            └── Startup
```

The script and EMS-generated files must remain in the same folder unless the script paths are changed.

## Validation

Use [validation_checklist.md](forticlient-gpo-deployment/docs/validation_checklist.md) for the deployment validation steps.

At a minimum, validate that:

- FortiClient installs silently.
- Logs are created under `C:\ProgramData\Fortinet\FortiClient\InstallLogs`.
- The endpoint appears in EMS.
- The endpoint is assigned to the expected EMS group through `VP_CS_LEGER`.
- The appropraite VPN profile is received.

## Notes For Maintainers

- Do not commit FortiClient binaries.
- Do not include credentials or secrets.
- Keep root `README.md` focused on repository/developer context.
- Keep the release folder small and zip-ready.
