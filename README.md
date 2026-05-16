# MDE Foundations

> 🇫🇷 [Version française](README.fr.md)

A community-driven baseline to deploy Microsoft Defender for Endpoint via Microsoft Intune, covering Windows workstations and servers, with a structured group-based approach and progressive deployment strategy.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Blog](https://img.shields.io/badge/Read%20the%20blog-blog.sebastienmiro.fr-blue)](https://blog.sebastienmiro.fr)

> ⚠️ **Important** - This baseline is a starting point. It has been designed based on common audit findings and Microsoft recommendations, but it does not fit every context as-is. Each policy must be reviewed against business requirements before deployment.

## Why this project

MDE configurations encountered in real-world audits are rarely consistent. Common issues:

- Tamper Protection disabled
- ASR rules stuck in Audit mode indefinitely
- Antivirus exclusions inherited from legacy products, never reviewed
- Onboarding scripts deployed via GPO with no consistent inventory
- Mixed management methods (Intune + GPO + local scripts) without a clear source of truth
- No distinction between workstations and servers in policy targeting

This project provides a baseline that addresses these issues, with clear separation between catch-all minimums, production policies, and pilot policies, for both workstations and servers.

## What this baseline contains

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
- **Attack Surface Reduction** - four policies organized by risk category (low-risk rules in Block, Office rules in progressive Audit / Warn / Block deployment)

### Tenant-level configuration

- Tamper Protection at tenant level
- Security Management for MDE (for devices without an Intune license)
- Automated Investigation in Semi mode

## Deployment methods

Three methods are supported.

### Option 1 - PowerShell scripts (recommended)

Deployment via Microsoft Graph PowerShell scripts. Reproducible, auditable, version-controlled.

```powershell
cd scripts
.\00-install-prerequisites.ps1
.\01-create-groups.ps1
.\02-create-edr-onboarding.ps1
# ...etc
```

See [scripts/README.md](scripts/README.md) for the full sequence.

### Option 2 - Manual deployment

For administrators who prefer the Intune admin center UI, every step is documented with the exact paths, parameters, and values to apply.

See [manual-deployment/en/README.md](manual-deployment/en/README.md).

### Option 3 - IntuneManagement imports (coming soon)

Exports generated via the IntuneManagement tool, importable in a few clicks.

This option will be added after sandbox validation. See [intunemanagement-exports/README.md](intunemanagement-exports/README.md).

## Documentation

| Document | Topic |
|---|---|
| [01-prerequisites.md](docs/en/01-prerequisites.md) | Licensing, tenant activation, MDE/Intune connection |
| [02-architecture.md](docs/en/02-architecture.md) | Group structure, policy layering logic |
| [03-policies-reference.md](docs/en/03-policies-reference.md) | Exhaustive reference of every parameter |
| [04-deployment-plan.md](docs/en/04-deployment-plan.md) | 11-week progressive deployment calendar |
| [05-verification.md](docs/en/05-verification.md) | PowerShell commands and portal checks |
| [06-customization.md](docs/en/06-customization.md) | Adapting the baseline to your context |
| [07-troubleshooting.md](docs/en/07-troubleshooting.md) | Common issues and resolutions |

## Quick start

1. Verify [prerequisites](docs/en/01-prerequisites.md) are in place
2. Clone this repository
3. Choose a deployment method (scripts, manual, or imports)
4. Follow the [deployment plan](docs/en/04-deployment-plan.md)
5. Validate using the [verification guide](docs/en/05-verification.md)

## Companion blog series

This baseline is accompanied by an 11-part technical series on [blog.sebastienmiro.fr](https://blog.sebastienmiro.fr) (in French), explaining the rationale behind each policy and each parameter.

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

Issues and pull requests are welcome. Identifying missing parameters, incorrect values, or better approaches is encouraged through issue submissions.

Particularly valuable contributions:

- Validation in real-world environments (sandbox or production tenant feedback)
- Server-specific edge cases (Domain Controllers, Exchange, SQL Server)
- IntuneManagement exports (once initial validation is complete)
- Translations and documentation improvements

## Disclaimer

This baseline is provided as-is. No liability is assumed for its use in production. Always review and test in a controlled environment before deploying.

## License

[MIT](LICENSE)

## Author

Sébastien Miro - [blog.sebastienmiro.fr](https://blog.sebastienmiro.fr)

CISSP, specializing in Microsoft cloud security.
