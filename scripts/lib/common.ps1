<#
.SYNOPSIS
    Common functions shared across MDE Foundations deployment scripts.

.DESCRIPTION
    This file is dot-sourced by each deployment script and exposes helper
    functions for Microsoft Graph connection, logging, idempotent operations,
    and dry-run support.

.NOTES
    Author: Sébastien Miro
    License: MIT
    Repository: https://github.com/sebastienmiro/mde-foundations
#>

# ----------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------

$script:RequiredScopes = @(
    "Group.ReadWrite.All",
    "DeviceManagementConfiguration.ReadWrite.All",
    "DeviceManagementServiceConfig.ReadWrite.All",
    "DeviceManagementApps.ReadWrite.All",
    "Directory.Read.All"
)

$script:RequiredModules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Identity.DirectoryManagement",
    "Microsoft.Graph.DeviceManagement"
)

# ----------------------------------------------------------------------------
# Logging functions
# ----------------------------------------------------------------------------

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "> $Message" -ForegroundColor White
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-WarningMessage {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "  [ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Gray
}

function Write-DryRun {
    param([string]$Message)
    Write-Host "  [DRY-RUN] Would $Message" -ForegroundColor Magenta
}

# ----------------------------------------------------------------------------
# Graph connection
# ----------------------------------------------------------------------------

function Test-GraphConnection {
    <#
    .SYNOPSIS
        Tests whether a Microsoft Graph connection is active with the required scopes.
    #>
    try {
        $context = Get-MgContext -ErrorAction SilentlyContinue
        if ($null -eq $context) {
            return $false
        }
        $missingScopes = $script:RequiredScopes | Where-Object { $_ -notin $context.Scopes }
        if ($missingScopes.Count -gt 0) {
            Write-WarningMessage "Active connection but missing scopes: $($missingScopes -join ', ')"
            return $false
        }
        return $true
    }
    catch {
        return $false
    }
}

function Connect-GraphIfNeeded {
    <#
    .SYNOPSIS
        Connects to Microsoft Graph with the required scopes if not already connected.
    #>
    if (Test-GraphConnection) {
        $context = Get-MgContext
        Write-Info "Already connected to tenant: $($context.TenantId)"
        Write-Info "Account: $($context.Account)"
        return
    }

    Write-Step "Connecting to Microsoft Graph"
    try {
        Connect-MgGraph -Scopes $script:RequiredScopes -NoWelcome -ErrorAction Stop | Out-Null
        $context = Get-MgContext
        Write-Success "Connected to tenant: $($context.TenantId)"
        Write-Info "Account: $($context.Account)"
    }
    catch {
        Write-ErrorMessage "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
        throw
    }
}

# ----------------------------------------------------------------------------
# Module verification
# ----------------------------------------------------------------------------

function Test-RequiredModules {
    <#
    .SYNOPSIS
        Verifies that all required Microsoft Graph modules are installed.
    #>
    $missing = @()
    foreach ($module in $script:RequiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            $missing += $module
        }
    }
    return $missing
}

# ----------------------------------------------------------------------------
# Group helpers
# ----------------------------------------------------------------------------

function Get-MdeGroup {
    <#
    .SYNOPSIS
        Retrieves an Entra ID group by display name. Returns $null if not found.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$DisplayName
    )
    try {
        $group = Get-MgGroup -Filter "displayName eq '$DisplayName'" -ErrorAction Stop
        return $group
    }
    catch {
        return $null
    }
}

function New-MdeGroupIfMissing {
    <#
    .SYNOPSIS
        Creates an Entra ID group if it does not already exist. Idempotent.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [ValidateSet("Static", "Dynamic")]
        [string]$MembershipType,

        [Parameter()]
        [string]$DynamicRule
    )

    $existing = Get-MdeGroup -DisplayName $DisplayName

    if ($existing) {
        Write-Info "Group '$DisplayName' already exists (id: $($existing.Id))"

        # If dynamic, check whether the rule needs updating
        if ($MembershipType -eq "Dynamic" -and $existing.MembershipRule -ne $DynamicRule) {
            if ($PSCmdlet.ShouldProcess($DisplayName, "Update dynamic membership rule")) {
                Update-MgGroup -GroupId $existing.Id -MembershipRule $DynamicRule
                Write-Success "Updated dynamic rule for '$DisplayName'"
            }
            else {
                Write-DryRun "update dynamic rule for '$DisplayName'"
            }
        }
        return $existing
    }

    if (-not $PSCmdlet.ShouldProcess($DisplayName, "Create group")) {
        Write-DryRun "create group '$DisplayName' ($MembershipType)"
        return $null
    }

    $mailNickname = $DisplayName -replace "[^a-zA-Z0-9]", ""

    $params = @{
        DisplayName     = $DisplayName
        Description     = $Description
        MailEnabled     = $false
        SecurityEnabled = $true
        MailNickname    = $mailNickname
    }

    if ($MembershipType -eq "Dynamic") {
        $params.GroupTypes = @("DynamicMembership")
        $params.MembershipRule = $DynamicRule
        $params.MembershipRuleProcessingState = "On"
    }

    try {
        $group = New-MgGroup @params -ErrorAction Stop
        Write-Success "Created group '$DisplayName' (id: $($group.Id))"
        return $group
    }
    catch {
        Write-ErrorMessage "Failed to create group '$DisplayName': $($_.Exception.Message)"
        throw
    }
}

# ----------------------------------------------------------------------------
# Endpoint Security policy helpers
# ----------------------------------------------------------------------------

function Get-EndpointSecurityPolicy {
    <#
    .SYNOPSIS
        Retrieves an Endpoint Security configuration policy by name.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    try {
        $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies?`$filter=name eq '$Name'"
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri
        if ($response.value.Count -gt 0) {
            return $response.value[0]
        }
        return $null
    }
    catch {
        return $null
    }
}

function New-EndpointSecurityPolicy {
    <#
    .SYNOPSIS
        Creates or updates an Endpoint Security configuration policy. Idempotent.

    .PARAMETER Name
        Policy name.

    .PARAMETER Description
        Policy description.

    .PARAMETER TemplateReference
        Template reference object (id and family).

    .PARAMETER Settings
        Settings array following the configurationPolicies API schema.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [hashtable]$TemplateReference,

        [Parameter(Mandatory)]
        [array]$Settings,

        [Parameter()]
        [string]$Platforms = "windows10",

        [Parameter()]
        [string]$Technologies = "mdm,microsoftSense"
    )

    $existing = Get-EndpointSecurityPolicy -Name $Name

    $body = @{
        name              = $Name
        description       = $Description
        platforms         = $Platforms
        technologies      = $Technologies
        templateReference = $TemplateReference
        settings          = $Settings
    }

    if ($existing) {
        if (-not $PSCmdlet.ShouldProcess($Name, "Update Endpoint Security policy")) {
            Write-DryRun "update Endpoint Security policy '$Name'"
            return $existing
        }

        try {
            $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($existing.id)"
            Invoke-MgGraphRequest -Method PUT -Uri $uri -Body ($body | ConvertTo-Json -Depth 50) -ContentType "application/json"
            Write-Success "Updated policy '$Name'"
            return $existing
        }
        catch {
            Write-ErrorMessage "Failed to update policy '$Name': $($_.Exception.Message)"
            throw
        }
    }
    else {
        if (-not $PSCmdlet.ShouldProcess($Name, "Create Endpoint Security policy")) {
            Write-DryRun "create Endpoint Security policy '$Name'"
            return $null
        }

        try {
            $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
            $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body ($body | ConvertTo-Json -Depth 50) -ContentType "application/json"
            Write-Success "Created policy '$Name' (id: $($response.id))"
            return $response
        }
        catch {
            Write-ErrorMessage "Failed to create policy '$Name': $($_.Exception.Message)"
            throw
        }
    }
}

function Set-EndpointSecurityPolicyAssignment {
    <#
    .SYNOPSIS
        Sets the group assignments of an Endpoint Security policy.

    .DESCRIPTION
        Replaces all existing assignments with the provided list of group IDs.
        Use this to ensure idempotent assignment state.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$PolicyId,

        [Parameter(Mandatory)]
        [string]$PolicyName,

        [Parameter(Mandatory)]
        [string[]]$GroupIds
    )

    if (-not $PSCmdlet.ShouldProcess($PolicyName, "Assign to groups: $($GroupIds -join ', ')")) {
        Write-DryRun "assign policy '$PolicyName' to $($GroupIds.Count) group(s)"
        return
    }

    $assignments = @()
    foreach ($groupId in $GroupIds) {
        $assignments += @{
            target = @{
                "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                groupId       = $groupId
            }
        }
    }

    $body = @{
        assignments = $assignments
    }

    try {
        $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$PolicyId/assign"
        Invoke-MgGraphRequest -Method POST -Uri $uri -Body ($body | ConvertTo-Json -Depth 20) -ContentType "application/json"
        Write-Success "Assigned policy '$PolicyName' to $($GroupIds.Count) group(s)"
    }
    catch {
        Write-ErrorMessage "Failed to assign policy '$PolicyName': $($_.Exception.Message)"
        throw
    }
}

# ----------------------------------------------------------------------------
# Summary helpers
# ----------------------------------------------------------------------------

function Write-Summary {
    <#
    .SYNOPSIS
        Displays a summary of an operation.
    #>
    param(
        [int]$Created = 0,
        [int]$Updated = 0,
        [int]$Skipped = 0,
        [int]$Errors = 0
    )

    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  Created : $Created" -ForegroundColor Green
    Write-Host "  Updated : $Updated" -ForegroundColor Yellow
    Write-Host "  Skipped : $Skipped" -ForegroundColor Gray
    if ($Errors -gt 0) {
        Write-Host "  Errors  : $Errors" -ForegroundColor Red
    }
}
