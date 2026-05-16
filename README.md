# MDE Foundations

> 🇫🇷 [Version française](README.fr.md)

A community-driven baseline to deploy Microsoft Defender for Endpoint via Microsoft Intune...

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Blog](https://img.shields.io/badge/Read%20the%20blog-blog.sebastienmiro.fr-blue)](https://blog.sebastienmiro.fr)

> ⚠️ **Important** - This baseline is a starting point. It has been designed against common audit findings and Microsoft recommendations, but it is not a one-size-fits-all solution. Review each policy against your business requirements before deploying.

## Why this project

MDE configurations encountered in real-world audits are rarely consistent. Common issues include:

- Tamper Protection disabled
- ASR rules stuck in Audit mode indefinitely
- Antivirus exclusions inherited from legacy products, never reviewed
- Onboarding scripts deployed via GPO with no inventory consistency
- Mixed management methods (Intune + GPO + local scripts) with no clear source of truth
- No distinction between workstations and servers in policy targeting

This project provides a baseline that addresses these issues, with a clear separation between catch-all minimums, production policies, and pilot policies, for both workstations and servers.

## What you get

### Entra ID groups

- `MDE-CatchAll-Windows` - dynamic group covering all Windows devices in the tenant
- `MDE-Pilot-Workstations` - static group for workstation pilots
- `MDE-Production-Workstations` - dynamic group for production workstations
- `MDE-Pilot-Servers` - static group for server pilots
- `MDE-Production-Servers` - dynamic group for production servers

### Endpoint Security policies

- **EDR Onboarding** - single policy covering workstations and servers
- **Antivirus** - five layered policies (catch-all + production WS + production Srv + pilot WS + pilot Srv)
- **Firewall** - three policies (global configuration + workstation rules + server rules)
- **Attack Surface Reduction** - four policies organized by risk category (low risk in Block, Office rules in Audit / Warn / Block progressive deployment)

### Tenant-level configuration

- Tamper Protection at tenant level
- Security Management for MDE (for devices without Intune license)
- Automated Investigation in Semi mode

## Deployment options

This repository supports two deployment methods:

### Option 1 - PowerShell scripts (recommended)

Deploy everything via Microsoft Graph PowerShell scripts. Reproducible, auditable, version-controlled.

```powershell
cd scripts
.\00-install-prerequisites.ps1
.\01-create-groups.ps1
.\02-create-edr-onboarding.ps1
# ...etc
```

See [scripts/README.md](scripts/README.md) for the full sequence.

### Option 2 - Manual deployment

For those who prefer the Intune admin center UI, every step is documented with the exact paths, parameters, and values to apply.

See [manual-deployment/README.md](manual-deployment/README.md).

### Option 3 - IntuneManagement imports (coming soon)

Exports generated via the IntuneManagement tool, importable in a few clicks.

This option will be added after sandbox validation. See [intunemanagement-exports/README.md](intunemanagement-exports/README.md).

## Documentation

| Document | Topic |
|---|---|
| [01-prerequisites.md](docs/01-prerequisites.md) | Licenses, tenant activation, MDE/Intune connection |
| [02-architecture.md](docs/02-architecture.md) | Group structure, policy layering logic |
| [03-policies-reference.md](docs/03-policies-reference.md) | Exhaustive reference of every parameter |
| [04-deployment-plan.md](docs/04-deployment-plan.md) | 11-week progressive deployment calendar |
| [05-verification.md](docs/05-verification.md) | PowerShell commands and portal checks |
| [06-customization.md](docs/06-customization.md) | How to adapt the baseline to your context |
| [07-troubleshooting.md](docs/07-troubleshooting.md) | Common issues and resolutions |

## Quick start

1. Make sure you meet the [prerequisites](docs/01-prerequisites.md)
2. Clone this repository
3. Choose your deployment option (scripts, manual, or imports)
4. Follow the [deployment plan](docs/04-deployment-plan.md)
5. Validate using the [verification guide](docs/05-verification.md)

## Companion blog series

This baseline is accompanied by an 11-part technical series on [blog.sebastienmiro.fr](https://blog.sebastienmiro.fr), which explains the rationale behind each policy and parameter.

| Episode | Topic |
|---|---|
| 1 | State of the union, common audit findings |
| 2 | Workstation licensing and onboarding |
| 3 | Server licensing and onboarding |
| 4 | Catch-all strategy and policy layering |
| 5 | Antivirus configuration |
| 6 | Firewall on the three network profiles |
| 7 | Understanding ASR rules |
| 8 | Progressive ASR deployment |
| 9 | Tamper Protection and configuration lockdown |
| 10 | Investigation and response with MDE |
| 11 | The MDE Foundations template |

## Contributing

Issues and pull requests are welcome. If you identify a missing setting, an incorrect value, or a better approach, feel free to open an issue.

Areas where contributions are especially valuable:

- Validation in real-world environments (sandbox or production tenant feedback)
- Server-specific edge cases (Domain Controllers, Exchange, SQL Server)
- IntuneManagement exports (once initial validation is complete)
- Translations of the documentation

## Disclaimer

This baseline is provided as-is. No liability is assumed for its application in production tenants. Always review and test in a controlled environment before deploying to production.

## License

[MIT](LICENSE)

## Author

Sébastien Miro - [blog.sebastienmiro.fr](https://blog.sebastienmiro.fr)

CISSP, specializing in Microsoft cloud security.
