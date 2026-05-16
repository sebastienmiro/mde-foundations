# MDE Foundations

> 🇬🇧 [English version](README.md)

Un socle communautaire pour déployer Microsoft Defender for Endpoint via Microsoft Intune, couvrant les postes de travail et serveurs Windows, avec une approche structurée par groupes et une stratégie de déploiement progressive.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Blog](https://img.shields.io/badge/Lire%20le%20blog-blog.sebastienmiro.fr-blue)](https://blog.sebastienmiro.fr)

> ⚠️ **Important** - Ce socle est un point de départ. Il a été conçu à partir des constats récurrents en audit et des recommandations Microsoft, mais il ne convient pas tel quel à tous les contextes. Chaque policy doit être revue par rapport aux exigences métier avant déploiement.

## Pourquoi ce projet

Les configurations MDE rencontrées en audit sont rarement cohérentes. Les problèmes fréquents :

- Tamper Protection désactivée
- Règles ASR figées en mode Audit indéfiniment
- Exclusions antivirus héritées de produits antérieurs, jamais réévaluées
- Scripts d'onboarding déployés via GPO sans inventaire fiable
- Méthodes de gestion mixtes (Intune + GPO + scripts locaux) sans source de vérité claire
- Aucune distinction entre postes de travail et serveurs dans le ciblage

Ce projet fournit un socle qui adresse ces problèmes, avec une séparation claire entre socle minimal catch-all, policies de production et policies pilote, pour les postes de travail et les serveurs.

## Ce que ça contient

### Groupes Entra ID

- `MDE-CatchAll-Windows` - groupe dynamique couvrant tous les appareils Windows du tenant
- `MDE-Pilot-Workstations` - groupe statique pour les postes pilotes
- `MDE-Production-Workstations` - groupe dynamique pour les postes en production
- `MDE-Pilot-Servers` - groupe statique pour les serveurs pilotes
- `MDE-Production-Servers` - groupe dynamique pour les serveurs en production

### Policies Endpoint Security

- **Onboarding EDR** - une policy unique pour les postes et serveurs
- **Antivirus** - cinq policies en couches (catch-all + production postes + production serveurs + pilote postes + pilote serveurs)
- **Firewall** - trois policies (configuration globale + règles postes + règles serveurs)
- **Attack Surface Reduction** - quatre policies organisées par catégorie de risque (règles à faible risque en Block, règles Office en déploiement progressif Audit / Warn / Block)

### Configuration au niveau tenant

- Tamper Protection au niveau tenant
- Security Management for MDE (pour les appareils sans licence Intune)
- Investigation automatisée en mode Semi

## Méthodes de déploiement

Trois méthodes supportées.

### Option 1 - Scripts PowerShell (recommandée)

Déploiement via des scripts PowerShell Microsoft Graph. Reproductible, auditable, versionné.

```powershell
cd scripts
.\00-install-prerequisites.ps1
.\01-create-groups.ps1
.\02-create-edr-onboarding.ps1
# ...etc
```

Voir [scripts/README.md](scripts/README.md) pour la séquence complète.

### Option 2 - Déploiement manuel

Pour ceux qui préfèrent l'interface Intune admin center, chaque étape est documentée avec les chemins, paramètres et valeurs exacts à appliquer.

Voir [manual-deployment/fr/README.md](manual-deployment/fr/README.md).

### Option 3 - Imports IntuneManagement (à venir)

Exports générés via l'outil IntuneManagement, importables en quelques clics.

Cette option sera ajoutée après validation en sandbox. Voir [intunemanagement-exports/README.md](intunemanagement-exports/README.md).

## Documentation

| Document | Sujet |
|---|---|
| [01-prerequis.md](docs/fr/01-prerequis.md) | Licences, activation du tenant, connexion MDE/Intune |
| [02-architecture.md](docs/fr/02-architecture.md) | Structure des groupes, logique de superposition des policies |
| [03-reference-policies.md](docs/fr/03-reference-policies.md) | Référence exhaustive de chaque paramètre |
| [04-plan-deploiement.md](docs/fr/04-plan-deploiement.md) | Calendrier de déploiement progressif sur 11 semaines |
| [05-verification.md](docs/fr/05-verification.md) | Commandes PowerShell et vérifications dans le portail |
| [06-personnalisation.md](docs/fr/06-personnalisation.md) | Comment adapter le socle à son contexte |
| [07-depannage.md](docs/fr/07-depannage.md) | Problèmes courants et résolutions |

## Démarrage rapide

1. Vérifier que les [prérequis](docs/fr/01-prerequis.md) sont en place
2. Cloner ce dépôt
3. Choisir une méthode de déploiement (scripts, manuel ou imports)
4. Suivre le [plan de déploiement](docs/fr/04-plan-deploiement.md)
5. Valider avec le [guide de vérification](docs/fr/05-verification.md)

## Série de blog associée

Ce socle est accompagné d'une série technique en 11 épisodes sur [blog.sebastienmiro.fr](https://blog.sebastienmiro.fr), qui explique la logique derrière chaque policy et chaque paramètre.

| Épisode | Sujet |
|---|---|
| 1 | État des lieux des configurations courantes |
| 2 | Licences et onboarding des postes |
| 3 | Licences et onboarding des serveurs |
| 4 | Stratégie catch-all et superposition des policies |
| 5 | Configuration antivirus |
| 6 | Firewall sur les trois profils réseau |
| 7 | Comprendre les règles ASR |
| 8 | Déploiement progressif des règles ASR |
| 9 | Tamper Protection et verrouillage de la configuration |
| 10 | Investigation et réponse avec MDE |
| 11 | Le template MDE Foundations |

## Contributions

Les issues et pull requests sont les bienvenues. Si tu identifies un paramètre manquant, une valeur incorrecte ou une meilleure approche, n'hésite pas à ouvrir une issue.

Les contributions particulièrement utiles :

- Validation en environnement réel (sandbox ou retour de production)
- Cas particuliers serveurs (contrôleurs de domaine, Exchange, SQL Server)
- Exports IntuneManagement (une fois la validation initiale terminée)
- Traductions et améliorations de la documentation

## Avertissement

Ce socle est fourni en l'état. Aucune responsabilité n'est assumée pour son utilisation en production. Toujours revoir et tester en environnement contrôlé avant déploiement.

## Licence

[MIT](LICENSE)

## Auteur

Sébastien Miro - [blog.sebastienmiro.fr](https://blog.sebastienmiro.fr)

CISSP, spécialisé en sécurité cloud Microsoft.
