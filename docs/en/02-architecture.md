# Architecture

This document describes the structural choices behind the MDE Foundations baseline: group organization, policy layering, and the interaction between them.

## Design principles

The baseline is built on three principles.

**A safety net first.** A catch-all group with non-negotiable minimum settings (active antivirus, Tamper Protection, EDR onboarding) ensures every Windows device in the tenant has a baseline of protection, whether or not it falls into a specific targeting group.

**Layered policies over monolithic ones.** Rather than one large policy per area, the baseline uses small policies that layer on top of each other. The catch-all sets the minimum, production policies add stricter settings, pilot policies add the strictest. This layering relies on the merge behavior of Intune Endpoint Security policies.

**Separation of workstations and servers.** Workstations and servers expose different attack surfaces and have different operational constraints. Their policies are kept distinct from the start, even when settings happen to be identical, to avoid splitting policies later.

## Group structure

Five Entra ID groups, with clear roles.

```mermaid
graph TD
    A[Entra ID Tenant] --> B[MDE-CatchAll-Windows<br/>dynamic]
    A --> C[MDE-Pilot-Workstations<br/>static - 5 to 20 devices]
    A --> D[MDE-Production-Workstations<br/>dynamic]
    A --> E[MDE-Pilot-Servers<br/>static - 2 to 5 servers]
    A --> F[MDE-Production-Servers<br/>dynamic]

    B -.covers.-> G[All Windows devices]
    C -.covers.-> H[Validation workstations]
    D -.covers.-> I[Production workstations excl. pilot]
    E -.covers.-> J[Validation servers]
    F -.covers.-> K[Production servers excl. pilot]

    style B fill:#cfe8ff,stroke:#0066cc
    style C fill:#ffe8cc,stroke:#cc6600
    style D fill:#d4f4d4,stroke:#006600
    style E fill:#ffe8cc,stroke:#cc6600
    style F fill:#d4f4d4,stroke:#006600
```

### Why dynamic for catch-all and production, static for pilots

Catch-all and production groups should be self-maintaining. New devices joining the tenant should automatically receive their policies without manual intervention. That is what dynamic groups provide.

Pilot groups are intentionally managed manually. Adding a device to a pilot group is a deliberate act: it indicates that this device is willing to receive the strictest settings first, in exchange for advance warning of any breaking change.

## Policy layering

Intune Endpoint Security policies merge when multiple policies target the same device.

```mermaid
flowchart LR
    A[Multiple policies<br/>on a single device] --> B{Setting type?}
    B -->|List<br/>exclusions, ASR rules| C[Merge<br/>Union of values]
    B -->|Single value<br/>Tamper, Cloud Block| D{Values<br/>identical?}
    D -->|Yes| E[Normal application]
    D -->|No| F[Conflict<br/>Most secure value wins]

    style C fill:#d4f4d4,stroke:#006600
    style E fill:#d4f4d4,stroke:#006600
    style F fill:#ffd4d4,stroke:#cc0000
```

This behavior is what makes the layered approach safe. The catch-all sets a floor; production policies can only raise the floor, never lower it.

## Policy hierarchy

Three layers stacked from broadest to most restrictive.

```mermaid
flowchart TB
    subgraph "Layer 3 - Pilot (strictest)"
        P1[AV Cloud Block High Plus]
        P2[Progressive Office ASR rules]
    end

    subgraph "Layer 2 - Production"
        Pr1[AV parameters by device type]
        Pr2[WS/Srv firewall rules]
    end

    subgraph "Layer 1 - Catch-all (floor)"
        C1[EDR Onboarding]
        C2[AV Cloud Block High]
        C3[Tamper Protection]
        C4[Global firewall configuration]
        C5[Low-risk ASR rules in Block]
    end

    Layer1 --> Layer2 --> Layer3

    style P1 fill:#ffe8cc
    style P2 fill:#ffe8cc
    style Pr1 fill:#d4f4d4
    style Pr2 fill:#d4f4d4
    style C1 fill:#cfe8ff
    style C2 fill:#cfe8ff
    style C3 fill:#cfe8ff
    style C4 fill:#cfe8ff
    style C5 fill:#cfe8ff
```

## Application flow on a device

Concrete view of what a device receives based on its group membership.

```mermaid
flowchart TD
    Device[New Windows workstation<br/>WRK-001 registered in Entra ID]
    
    Device --> G1{In MDE-CatchAll-Windows?}
    G1 -->|Yes - automatic| L1[Receives catch-all baseline<br/>EDR + minimal AV + global FW + low-risk ASR]
    
    L1 --> G2{In MDE-Production-Workstations?}
    G2 -->|Yes - dynamic rule<br/>name starts with WRK-| L2[Receives WS production layer<br/>WS AV + WS FW rules]
    
    L2 --> G3{In MDE-Pilot-Workstations?}
    G3 -->|No - default| L3[Final configuration applied]
    G3 -->|Yes - manual add| L4[Receives in addition<br/>AV Cloud Block High Plus<br/>Office ASR under validation]
    
    L4 --> L3

    style L1 fill:#cfe8ff
    style L2 fill:#d4f4d4
    style L4 fill:#ffe8cc
    style L3 fill:#ffffff,stroke:#000,stroke-width:2px
```

## Assignment matrix

Which policy applies to which group:

| Policy | CatchAll | Pilot WS | Prod WS | Pilot Srv | Prod Srv |
|---|---|---|---|---|---|
| MDE-EDR-Onboarding | ✓ | | | | |
| MDE-AV-CatchAll | ✓ | | | | |
| MDE-AV-Workstations-Production | | | ✓ | | |
| MDE-AV-Servers-Production | | | | | ✓ |
| MDE-AV-Workstations-Pilot | | ✓ | | | |
| MDE-AV-Servers-Pilot | | | | ✓ | |
| MDE-FW-CatchAll | ✓ | | | | |
| MDE-FW-Rules-Workstations | | ✓ | ✓ | | |
| MDE-FW-Rules-Servers | | | | ✓ | ✓ |
| MDE-ASR-LowRisk-Block | ✓ | | | | |
| MDE-ASR-Office-Audit (initial phase) | | ✓ | | | |
| MDE-ASR-Office-Warn (after pilot) | | | ✓ | | |
| MDE-ASR-Office-Block (after Warn) | | | ✓ | | |

## Why no Office ASR policies on servers

ASR rules targeting Office applications (`Block all Office applications from creating child processes`, `Block Win32 API calls from Office macros`, etc.) don't make sense in a typical server context. Servers don't run Office applications under interactive sessions.

Exceptions exist (legacy SharePoint with server-side Office automation), but they are rare and should be handled with dedicated policies, outside the standard baseline.

## Why a single EDR onboarding policy for workstations and servers

The onboarding policy is identical for both: same package, same sample sharing configuration, same telemetry reporting frequency. Splitting it would add complexity without benefit.

Differentiation between workstations and servers happens in subsequent policies (antivirus, firewall, ASR), not in onboarding.

## Naming convention

All policies follow this pattern:

```
MDE-<Category>-<Scope>[-<Subscope>]
```

Examples:

- `MDE-EDR-Onboarding`
- `MDE-AV-CatchAll`
- `MDE-AV-Workstations-Production`
- `MDE-FW-Rules-Servers`
- `MDE-ASR-LowRisk-Block`
- `MDE-ASR-Office-Audit`

This naming makes policies easy to identify, filter, and reason about. Renaming a policy after deployment should be avoided, as it can break documentation references.

## Next steps

- [03-policies-reference.md](03-policies-reference.md) - exhaustive list of every parameter in every policy
- [04-deployment-plan.md](04-deployment-plan.md) - week-by-week deployment calendar
