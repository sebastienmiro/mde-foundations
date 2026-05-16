# Architecture

Ce document décrit les choix structurels du socle MDE Foundations : organisation des groupes, superposition des policies, et interaction entre les deux.

## Principes de conception

Le socle repose sur trois principes.

**Un filet de sécurité d'abord.** Un groupe catch-all avec des paramètres minimaux non négociables (antivirus actif, Tamper Protection, onboarding EDR) garantit que tout appareil Windows du tenant dispose d'un socle de protection, qu'il tombe ou non dans un groupe de ciblage spécifique.

**Des policies en couches plutôt qu'une policy monolithique.** Plutôt qu'une grosse policy par domaine, le socle utilise plusieurs petites policies qui se superposent. Le catch-all pose le minimum, les policies de production ajoutent les paramètres plus stricts, les policies pilote ajoutent les plus stricts. Cette logique de superposition s'appuie sur le comportement de fusion des policies Endpoint Security d'Intune.

**Séparation postes et serveurs.** Postes de travail et serveurs exposent des surfaces d'attaque différentes et ont des contraintes opérationnelles distinctes. Leurs policies sont séparées dès le départ, même lorsque les paramètres sont identiques, pour éviter d'avoir à scinder les affectations ultérieurement.

## Structure des groupes

Cinq groupes Entra ID, chacun avec un rôle clair.

```mermaid
graph TD
    A[Tenant Entra ID] --> B[MDE-CatchAll-Windows<br/>dynamique]
    A --> C[MDE-Pilot-Workstations<br/>statique - 5 à 20 postes]
    A --> D[MDE-Production-Workstations<br/>dynamique]
    A --> E[MDE-Pilot-Servers<br/>statique - 2 à 5 serveurs]
    A --> F[MDE-Production-Servers<br/>dynamique]

    B -.couvre.-> G[Tous les appareils Windows]
    C -.couvre.-> H[Postes de validation]
    D -.couvre.-> I[Postes en production hors pilote]
    E -.couvre.-> J[Serveurs de validation]
    F -.couvre.-> K[Serveurs en production hors pilote]

    style B fill:#cfe8ff,stroke:#0066cc
    style C fill:#ffe8cc,stroke:#cc6600
    style D fill:#d4f4d4,stroke:#006600
    style E fill:#ffe8cc,stroke:#cc6600
    style F fill:#d4f4d4,stroke:#006600
```

### Pourquoi dynamique pour catch-all et production, statique pour les pilotes

Les groupes catch-all et production doivent être autonomes. Les nouveaux appareils joignant le tenant doivent recevoir automatiquement leurs policies sans intervention manuelle. C'est ce que permettent les groupes dynamiques.

Les groupes pilote sont volontairement gérés manuellement. Ajouter un appareil à un groupe pilote est un acte délibéré : il indique que cet appareil accepte de recevoir les paramètres les plus stricts en premier, en échange d'un avertissement préalable en cas de configuration cassante.

## Superposition des policies

Les policies Endpoint Security d'Intune fusionnent lorsque plusieurs policies ciblent un même appareil.

```mermaid
flowchart LR
    A[Plusieurs policies<br/>sur un même appareil] --> B{Type de paramètre ?}
    B -->|Liste<br/>exclusions, règles ASR| C[Fusion<br/>Union des valeurs]
    B -->|Valeur simple<br/>Tamper, Cloud Block| D{Valeurs<br/>identiques ?}
    D -->|Oui| E[Application normale]
    D -->|Non| F[Conflit<br/>La valeur la plus sécurisée gagne]

    style C fill:#d4f4d4,stroke:#006600
    style E fill:#d4f4d4,stroke:#006600
    style F fill:#ffd4d4,stroke:#cc0000
```

Ce comportement est ce qui rend l'approche en couches sécurisée. Le catch-all pose un plancher ; les policies de production ne peuvent que relever ce plancher, jamais l'abaisser.

## Hiérarchie des policies

Trois niveaux superposés, du plus large au plus restrictif.

```mermaid
flowchart TB
    subgraph "Niveau 3 - Pilote (le plus strict)"
        P1[AV Cloud Block High Plus]
        P2[Règles ASR Office progressives]
    end

    subgraph "Niveau 2 - Production"
        Pr1[Paramètres AV par type d'appareil]
        Pr2[Règles firewall WS/Srv]
    end

    subgraph "Niveau 1 - Catch-all (plancher)"
        C1[Onboarding EDR]
        C2[AV Cloud Block High]
        C3[Tamper Protection]
        C4[Configuration firewall globale]
        C5[Règles ASR faible risque en Block]
    end

    Niveau1 --> Niveau2 --> Niveau3

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

## Flux d'application sur un appareil

Vue concrète de ce qu'un appareil reçoit selon son appartenance aux groupes.

```mermaid
flowchart TD
    Device[Nouveau poste Windows<br/>WRK-001 enregistré dans Entra ID]
    
    Device --> G1{Dans MDE-CatchAll-Windows ?}
    G1 -->|Oui automatique| L1[Reçoit le socle catch-all<br/>EDR + AV minimal + FW global + ASR low risk]
    
    L1 --> G2{Dans MDE-Production-Workstations ?}
    G2 -->|Oui via règle dynamique<br/>nom commence par WRK-| L2[Reçoit la couche production WS<br/>AV WS + FW rules WS]
    
    L2 --> G3{Dans MDE-Pilot-Workstations ?}
    G3 -->|Non par défaut| L3[Configuration finale appliquée]
    G3 -->|Oui ajout manuel| L4[Reçoit en plus<br/>AV Cloud Block High Plus<br/>ASR Office en cours de validation]
    
    L4 --> L3

    style L1 fill:#cfe8ff
    style L2 fill:#d4f4d4
    style L4 fill:#ffe8cc
    style L3 fill:#ffffff,stroke:#000,stroke-width:2px
```

## Matrice d'affectation

Affectation de chaque policy aux groupes correspondants.

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
| MDE-ASR-Office-Audit (phase initiale) | | ✓ | | | |
| MDE-ASR-Office-Warn (après pilote) | | | ✓ | | |
| MDE-ASR-Office-Block (après Warn) | | | ✓ | | |

## Pourquoi pas de policies ASR Office sur serveurs

Les règles ASR ciblant les applications Office (`Block all Office applications from creating child processes`, `Block Win32 API calls from Office macros`, etc.) n'ont pas de sens dans un contexte serveur classique. Les serveurs n'exécutent pas d'applications Office sous session interactive.

Des exceptions existent (SharePoint legacy avec automation Office côté serveur), mais elles sont rares et doivent être gérées avec des policies dédiées, en dehors du socle standard.

## Pourquoi une seule policy d'onboarding EDR pour postes et serveurs

La policy d'onboarding est identique pour les deux : même package, même configuration de partage d'échantillons, même fréquence de remontée télémétrique. La séparer ajouterait de la complexité sans bénéfice.

La différenciation postes / serveurs se fait dans les policies suivantes (antivirus, firewall, ASR), pas dans l'onboarding.

## Convention de nommage

Toutes les policies suivent ce schéma :

```
MDE-<Catégorie>-<Périmètre>[-<Sous-périmètre>]
```

Exemples :

- `MDE-EDR-Onboarding`
- `MDE-AV-CatchAll`
- `MDE-AV-Workstations-Production`
- `MDE-FW-Rules-Servers`
- `MDE-ASR-LowRisk-Block`
- `MDE-ASR-Office-Audit`

Cette nomenclature facilite l'identification, le filtrage et la lisibilité des policies. Renommer une policy après déploiement est à éviter, car cela peut casser les références documentaires.

## Étapes suivantes

- [03-reference-policies.md](03-reference-policies.md) - liste exhaustive de chaque paramètre dans chaque policy
- [04-plan-deploiement.md](04-plan-deploiement.md) - calendrier de déploiement semaine par semaine
