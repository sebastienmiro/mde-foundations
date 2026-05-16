## Vue d'ensemble

```mermaid
flowchart LR
    subgraph "EDR"
        E1[MDE-EDR-Onboarding]
    end

    subgraph "Antivirus"
        A1[MDE-AV-CatchAll]
        A2[MDE-AV-Workstations-Production]
        A3[MDE-AV-Servers-Production]
        A4[MDE-AV-Workstations-Pilot]
        A5[MDE-AV-Servers-Pilot]
    end

    subgraph "Firewall"
        F1[MDE-FW-CatchAll]
        F2[MDE-FW-Rules-Workstations]
        F3[MDE-FW-Rules-Servers]
    end

    subgraph "ASR"
        R1[MDE-ASR-LowRisk-Block]
        R2[MDE-ASR-Office-Audit]
        R3[MDE-ASR-Office-Warn]
        R4[MDE-ASR-Office-Block]
    end

    style E1 fill:#cfe8ff
    style A1 fill:#cfe8ff
    style F1 fill:#cfe8ff
    style R1 fill:#cfe8ff
    style A2 fill:#d4f4d4
    style A3 fill:#d4f4d4
    style F2 fill:#d4f4d4
    style F3 fill:#d4f4d4
    style A4 fill:#ffe8cc
    style A5 fill:#ffe8cc
    style R2 fill:#ffe8cc
    style R3 fill:#ffe8cc
    style R4 fill:#ffd4d4
```

Code couleur : bleu = socle catch-all, vert = production, orange = pilote / phase intermédiaire, rouge = phase finale Block.

| Catégorie | Policies | Nombre total |
|---|---|---|
| EDR | MDE-EDR-Onboarding | 1 |
| Antivirus | CatchAll, Workstations-Production, Servers-Production, Workstations-Pilot, Servers-Pilot | 5 |
| Firewall | CatchAll, Rules-Workstations, Rules-Servers | 3 |
| ASR | LowRisk-Block, Office-Audit, Office-Warn, Office-Block | 4 |

Total : 13 policies.

## Cycle de vie des règles ASR Office

Les règles ASR Office passent par trois phases de déploiement progressif. Vue d'ensemble du cycle :

```mermaid
stateDiagram-v2
    [*] --> Audit: Déploiement initial<br/>sur pilote
    Audit --> AuditProd: Extension production<br/>après 2-4 semaines
    AuditProd --> Warn: Bascule Warn<br/>après validation
    Warn --> Block: Bascule Block<br/>après validation Warn
    Block --> [*]: Configuration cible
    
    Audit: MDE-ASR-Office-Audit<br/>sur pilote postes
    AuditProd: MDE-ASR-Office-Audit<br/>sur production postes
    Warn: MDE-ASR-Office-Warn<br/>sur production postes
    Block: MDE-ASR-Office-Block<br/>sur production postes
```

Voir [04-plan-deploiement.md](04-plan-deploiement.md) pour le calendrier détaillé.
