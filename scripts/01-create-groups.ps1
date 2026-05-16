<#
.SYNOPSIS
    Creates the five Entra ID groups required by the MDE Foundations baseline.

.DESCRIPTION
    Creates the following groups in Entra ID:
    - MDE-CatchAll-Windows (dynamic)
    - MDE-Pilot-Workstations (static)
    - MDE-Production-Workstations (dynamic)
    - MDE-Pilot-Servers (static)
    - MDE-Production-Servers (dynamic)

    The dynamic rules use device name prefixes that can be customized via
    the $WorkstationPrefix and $ServerPrefix parameters below.

    The script is idempotent: re-running it will not create duplicates and
    will update dynamic rules if they have changed.

.PARAMETER WorkstationPrefix
    Device name prefix used to identify workstations. Default: "WRK-".

.PARAMETER ServerPrefix
    Device name prefix used to identify servers. Default: "SRV-".

.PARAMETER WhatIf
    Preview the actions that would be performed without making changes.

.EXAMPLE
    .\01-create-groups.ps1

    Creates the five groups using default prefixes.

.EXAMPLE
    .\01-create-groups.ps1 -WorkstationPrefix "LAP-" -ServerPrefix "SRV-"

    Creates the groups using custom prefixes for workstations.

.EXAMPLE
    .\01-create-groups.ps1 -WhatIf

    Shows what would be done without applying changes.

.NOTES
    Author: Sébastien Miro
    License: MIT
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$WorkstationPrefix = "WRK-",

    [Parameter()]
    [string]$ServerPrefix = "SRV-"
)

$ErrorActionPreference = "Stop"

# Source common helpers
. (Join-Path $PSScriptRoot "lib\common.ps1")

Write-Header "MDE Foundations - Create Entra ID groups"

# Verify modules
$missing = Test-RequiredModules
if ($missing.Count -gt 0) {
    Write-ErrorMessage "Required modules missing: $($missing -join ', ')"
    Write-Info "Run .\00-install-prerequisites.ps1 first"
    exit 1
}

# Connect to Graph
Connect-GraphIfNeeded

# Define groups
$groups = @(
    @{
        DisplayName    = "MDE-CatchAll-Windows"
        Description    = "MDE Foundations - Catch-all - All Windows devices"
        MembershipType = "Dynamic"
        DynamicRule    = '(device.deviceOSType -eq "Windows")'
    },
    @{
        DisplayName    = "MDE-Pilot-Workstations"
        Description    = "MDE Foundations - Pilot workstations for pre-production validation"
        MembershipType = "Static"
    },
    @{
        DisplayName    = "MDE-Production-Workstations"
        Description    = "MDE Foundations - Workstations in production (excluding pilots)"
        MembershipType = "Dynamic"
        DynamicRule    = "(device.deviceOSType -eq `"Windows`") and (device.displayName -startsWith `"$WorkstationPrefix`")"
    },
    @{
        DisplayName    = "MDE-Pilot-Servers"
        Description    = "MDE Foundations - Pilot servers for pre-production validation"
        MembershipType = "Static"
    },
    @{
        DisplayName    = "MDE-Production-Servers"
        Description    = "MDE Foundations - Servers in production (excluding pilots)"
        MembershipType = "Dynamic"
        DynamicRule    = "(device.deviceOSType -eq `"Windows`") and (device.displayName -startsWith `"$ServerPrefix`")"
    }
)

Write-Step "Creating groups (prefixes: workstation='$WorkstationPrefix', server='$ServerPrefix')"

$created = 0
$skipped = 0
$errors = 0

foreach ($groupDef in $groups) {
    try {
        $existing = Get-MdeGroup -DisplayName $groupDef.DisplayName
        $result = New-MdeGroupIfMissing @groupDef -WhatIf:$WhatIfPreference

        if ($existing) {
            $skipped++
        }
        else {
            if (-not $WhatIfPreference) {
                $created++
            }
        }
    }
    catch {
        $errors++
        Write-ErrorMessage "Error processing '$($groupDef.DisplayName)'"
    }
}

Write-Summary -Created $created -Skipped $skipped -Errors $errors

if ($WhatIfPreference) {
    Write-Host ""
    Write-Host "Dry-run completed. No changes were applied." -ForegroundColor Magenta
}
else {
    Write-Host ""
    Write-Host "Note: dynamic group rules can take 5 to 15 minutes to populate." -ForegroundColor Gray
    Write-Host ""
    Write-Host "Next step: run .\02-create-edr-onboarding.ps1" -ForegroundColor Cyan
}

Write-Host ""
