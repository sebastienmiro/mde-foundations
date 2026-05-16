# Prérequis

Avant de déployer le socle MDE Foundations, vérifier que les éléments suivants sont en place dans ton tenant.

## Licences

### Pour les postes de travail

Au moins une des licences suivantes par utilisateur :

- Microsoft 365 Business Premium (inclut Defender for Business)
- Microsoft 365 E3 + add-on Microsoft Defender for Endpoint Plan 1
- Microsoft 365 E5 (inclut Microsoft Defender for Endpoint Plan 2)
- Microsoft 365 E5 Security (inclut Microsoft Defender for Endpoint Plan 2)
- Microsoft Defender for Business (standalone, pour les tenants de moins de 300 utilisateurs)

### Pour les serveurs

Les serveurs nécessitent une licence dédiée, distincte des licences utilisateur. Trois options :

| Licence | Périmètre | Plafond | Cas d'usage |
|---|---|---|---|
| Microsoft Defender for Endpoint for Servers (P1/P2) | On-premises, par OSE | Aucun | Serveurs on-premises classiques |
| Microsoft Defender for Business Servers | Add-on pour les tenants Business Premium / Defender for Business | 60 serveurs | Petites et moyennes infrastructures |
| Microsoft Defender for Servers (P1/P2) via Defender for Cloud | Azure, Arc, AWS, GCP | Aucun | Serveurs déjà supervisés par Defender for Cloud |

## Initialisation du tenant

### Tenant MDE

Le tenant MDE doit être initialisé. Aller dans `security.microsoft.com > Paramètres > Points de terminaison`. Si MDE n'a jamais été activé, la première connexion déclenche un assistant d'initialisation. Le compléter avant de continuer.

### Connexion MDE/Intune

Indispensable pour que les policies Intune poussent les paramètres MDE.

`security.microsoft.com > Paramètres > Points de terminaison > Caractéristiques avancées > Connexion Microsoft Intune`

Mettre sur **On**.

### Security Management for MDE

Permet aux appareils sans licence Intune de recevoir les policies de sécurité gérées via Intune, dès lors qu'ils sont onboardés dans MDE et enregistrés dans Entra ID.

`security.microsoft.com > Paramètres > Points de terminaison > Configuration management > Enforcement Scope`

Activer le périmètre pour les types d'appareils concernés (Workstations, Servers). Indispensable pour les environnements où Intune n'est pas déployé sur toutes les machines.

## Permissions administratives

Pour déployer le socle, il faut au moins l'un des rôles suivants dans Entra ID :

- Global Administrator
- Intune Administrator + Security Administrator

Pour l'exploitation au quotidien après déploiement, suivre le principe du moindre privilège. Séparation des rôles recommandée :

- **Endpoint Security Manager** - gère MDE et les policies Endpoint Security
- **Intune Service Administrator** - gère les autres policies Intune et les applications

Les deux rôles doivent être activés à la demande via Privileged Identity Management (PIM), avec MFA imposée par accès conditionnel.

## Prérequis réseau

Les appareils doivent atteindre les endpoints Microsoft nécessaires au fonctionnement de MDE. La liste complète est maintenue par Microsoft : [Configurer les paramètres proxy et de connectivité Internet](https://learn.microsoft.com/fr-fr/defender-endpoint/configure-proxy-internet).

Points d'attention courants :

- L'inspection TLS sur les URLs MDE doit être désactivée
- Des exceptions de proxy peuvent être nécessaires pour les endpoints MDE
- Les URLs diffèrent selon la région du tenant (EU, US, UK)

Valider la connectivité avec l'outil `MDATPClientAnalyzer` disponible dans le portail MDE avant un déploiement à grande échelle.

## Convention de nommage

Les règles de groupes dynamiques de ce socle reposent sur les préfixes de nom d'appareil :

- Postes : généralement `WRK-`, `LAP-`, `PC-`, ou similaire
- Serveurs : généralement `SRV-`, `SQL-`, `WEB-`, ou similaire

Si ton environnement ne suit pas une convention stricte, deux alternatives :

- **Utiliser un extensionAttribute** dans Active Directory (pour les appareils hybrid join), renseigné via un script. Cet attribut se synchronise vers Entra ID via Entra Connect et peut servir dans les règles de groupes dynamiques.
- **Utiliser des affectations statiques** en mesure transitoire le temps de mettre en place une convention.

Voir [06-personnalisation.md](06-personnalisation.md) pour les stratégies d'adaptation.

## Checklist de vérification

Avant de déployer, vérifier :

- [ ] Le tenant MDE est initialisé
- [ ] La connexion MDE/Intune est On
- [ ] Security Management for MDE est activé (si nécessaire)
- [ ] Tu disposes du rôle administratif requis
- [ ] La connectivité réseau vers les endpoints MDE est validée
- [ ] La convention de nommage ou une stratégie de ciblage alternative est définie

Une fois ces points en place, passer à [02-architecture.md](02-architecture.md) pour la vue d'ensemble du design.
