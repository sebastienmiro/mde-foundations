# Prerequisites

Before deploying the MDE Foundations baseline, the following must be in place in the tenant.

## Licensing

### For workstations

At least one of the following licenses per user:

- Microsoft 365 Business Premium (includes Defender for Business)
- Microsoft 365 E3 + Microsoft Defender for Endpoint Plan 1 add-on
- Microsoft 365 E5 (includes Microsoft Defender for Endpoint Plan 2)
- Microsoft 365 E5 Security (includes Microsoft Defender for Endpoint Plan 2)
- Microsoft Defender for Business (standalone, for tenants with fewer than 300 users)

### For servers

Servers require dedicated licensing, separate from user licenses. Three options:

| License | Scope | Cap | Use case |
|---|---|---|---|
| Microsoft Defender for Endpoint for Servers (P1/P2) | On-premises, per OSE | None | Standard on-premises servers |
| Microsoft Defender for Business Servers | Add-on for Business Premium / Defender for Business tenants | 60 servers | Small to medium environments |
| Microsoft Defender for Servers (P1/P2) via Defender for Cloud | Azure, Arc, AWS, GCP | None | Servers already monitored by Defender for Cloud |

## Tenant initialization

### MDE tenant

The MDE tenant must be initialized. The initialization page is at `security.microsoft.com > Settings > Endpoints`. If MDE has never been activated, the first connection triggers an initialization wizard which must be completed before proceeding.

### MDE/Intune connection

Required for Intune policies to push MDE settings.

`security.microsoft.com > Settings > Endpoints > Advanced features > Microsoft Intune connection`

State: **On**.

### Security Management for MDE

Allows devices without an Intune license to receive Intune-managed security policies, as long as they are onboarded into MDE and registered in Entra ID.

`security.microsoft.com > Settings > Endpoints > Configuration management > Enforcement Scope`

Enable the scope for the relevant device types (Workstations, Servers). Essential for environments where Intune is not deployed on all machines.

## Administrative permissions

To deploy the baseline, at least one of the following Entra ID roles is required:

- Global Administrator
- Intune Administrator + Security Administrator

For daily operations after deployment, least privilege principles apply. Recommended role separation:

- **Endpoint Security Manager** - manages MDE and Endpoint Security policies
- **Intune Service Administrator** - manages other Intune policies and applications

Both roles should be activated on-demand via Privileged Identity Management (PIM), with MFA enforced through Conditional Access.

## Network requirements

Devices must reach the Microsoft endpoints required for MDE to function. The full list is maintained by Microsoft: [Configure proxy and Internet connectivity settings](https://learn.microsoft.com/defender-endpoint/configure-proxy-internet).

Common points of attention:

- TLS inspection on MDE URLs must be disabled
- Proxy exceptions may be required for the MDE endpoints
- Endpoint URLs differ by tenant region (EU, US, UK)

The `MDATPClientAnalyzer` tool, available in the MDE portal, can be used to validate connectivity before large-scale deployment.

## Naming convention

The dynamic group rules in this baseline rely on device name prefixes:

- Workstations: typically `WRK-`, `LAP-`, `PC-`, or similar
- Servers: typically `SRV-`, `SQL-`, `WEB-`, or similar

If the environment does not follow a strict naming convention, two alternatives:

- **Use an extensionAttribute** in Active Directory (for hybrid-joined devices), populated via a script. This attribute syncs to Entra ID via Entra Connect and can be used in dynamic group rules.
- **Use static group assignments** as a temporary measure while implementing a naming convention.

See [06-customization.md](06-customization.md) for adaptation strategies.

## Verification checklist

Before deployment:

- [ ] MDE tenant is initialized
- [ ] MDE/Intune connection is On
- [ ] Security Management for MDE is enabled (if needed)
- [ ] Required administrative role is available
- [ ] Network connectivity to MDE endpoints is validated
- [ ] Naming convention or alternative targeting strategy is defined

Once these are in place, proceed to [02-architecture.md](02-architecture.md) for the overall design.
