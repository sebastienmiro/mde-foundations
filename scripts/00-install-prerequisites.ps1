<#
.SYNOPSIS
    Installs the Microsoft Graph PowerShell modules required for MDE Foundations deployment.

.DESCRIPTION
    Installs the Microsoft.Graph submodules necessary to run the MDE Foundations
    deployment scripts. Installation is scoped to the current user and does not
    require administrative privileges.

    Does not connect to any tenant. The connection is established by the
    subsequent scripts when needed.

.EXAMPLE
    .\00-install-prerequisites.ps1

    Installs the required modules for the current user.

.EXAMPLE
    .\00-install-prerequisites.ps1 -Force

    Reinstalls the modules even if already present.

.NOTES
    Author: Sébastien Miro
    License: MIT
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Source common helpers
. (Join-Path $PSScriptRoot "lib\common.ps1")

Write-Header "MDE Foundations - Install prerequisites"

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-Step "Checking PowerShell version"
if ($psVersion.Major -lt 7) {
    Write-ErrorMessage "PowerShell 7.0 or higher is required (found: $($psVersion.ToString()))"
    Write-Info "Download PowerShell 7: https://aka.ms/powershell"
    exit 1
}
Write-Success "PowerShell version: $($psVersion.ToString())"

# Check execution policy
Write-Step "Checking execution policy"
$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($executionPolicy -eq "Restricted") {
    Write-WarningMessage "Current user execution policy is Restricted"
    Write-Info "Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    exit 1
}
Write-Success "Execution policy: $executionPolicy"

# Install required modules
$modulesToInstall = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Identity.DirectoryManagement",
    "Microsoft.Graph.DeviceManagement"
)

Write-Step "Installing required modules"

$installed = 0
$skipped = 0

foreach ($module in $modulesToInstall) {
    $existing = Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue

    if ($existing -and -not $Force) {
        Write-Info "Module '$module' already installed (version: $($existing[0].Version))"
        $skipped++
        continue
    }

    try {
        Write-Host "  Installing $module..." -ForegroundColor Gray -NoNewline
        Install-Module -Name $module -Scope CurrentUser -Force:$Force -AllowClobber -ErrorAction Stop
        Write-Host " done" -ForegroundColor Green
        $installed++
    }
    catch {
        Write-Host ""
        Write-ErrorMessage "Failed to install '$module': $($_.Exception.Message)"
        throw
    }
}

# Verify installation
Write-Step "Verifying installation"
$missing = Test-RequiredModules
if ($missing.Count -gt 0) {
    Write-ErrorMessage "Some modules are missing after install: $($missing -join ', ')"
    exit 1
}
Write-Success "All required modules are available"

Write-Summary -Created $installed -Skipped $skipped

Write-Host ""
Write-Host "Next step: run .\01-create-groups.ps1" -ForegroundColor Cyan
Write-Host ""
