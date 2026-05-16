# Référence des policies

Ce document liste de manière exhaustive chaque paramètre de chaque policy du socle MDE Foundations. Il sert de référence pour le déploiement manuel et pour la validation des scripts PowerShell.

## Vue d'ensemble

| Catégorie | Policies | Nombre total |
|---|---|---|
| EDR | MDE-EDR-Onboarding | 1 |
| Antivirus | CatchAll, Workstations-Production, Servers-Production, Workstations-Pilot, Servers-Pilot | 5 |
| Firewall | CatchAll, Rules-Workstations, Rules-Servers | 3 |
| ASR | LowRisk-Block, Office-Audit, Office-Warn, Office-Block | 4 |

Total : 13 policies.

---

## MDE-EDR-Onboarding

Policy d'onboarding EDR appliquée à tous les appareils Windows.

### Création

`Sécurité des points de terminaison > Détection de point de terminaison et réponse > Créer une policy`

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Endpoint detection and response |
| Nom | MDE-EDR-Onboarding |

### Paramètres

| Paramètre | Valeur |
|---|---|
| Microsoft Defender for Endpoint client configuration package type | Auto from connector |
| Sample sharing | All |
| Telemetry Reporting Frequency | Expedite |

### Affectation

| Groupe |
|---|
| MDE-CatchAll-Windows |

---

## MDE-AV-CatchAll

Socle antivirus minimal appliqué à tous les appareils Windows.

### Création

`Sécurité des points de terminaison > Antivirus > Créer une policy`

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Microsoft Defender Antivirus |
| Nom | MDE-AV-CatchAll |

### Paramètres - Protection temps réel

| Paramètre | Valeur |
|---|---|
| Allow Realtime Monitoring | Allowed |
| Allow Behavior Monitoring | Allowed |
| Allow IOAV Protection | Allowed |
| Allow Script Scanning | Allowed |
| Allow On Access Protection | Allowed |
| Real Time Scan Direction | Monitor all files (bi-directional) |

### Paramètres - Protection cloud

| Paramètre | Valeur |
|---|---|
| Allow Cloud Protection | Allowed |
| Cloud Block Level | High |
| Cloud Extended Timeout | 50 |
| Submit Samples Consent | Send safe samples automatically |

### Paramètres - Scans

| Paramètre | Valeur |
|---|---|
| Allow Archive Scanning | Allowed |
| Allow Email Scanning | Allowed |
| Allow Full Scan On Mapped Network Drives | Not Allowed |
| Allow Scanning Network Files | Not Allowed |
| Disable Catchup Quick Scan | Disabled |
| Disable Catchup Full Scan | Disabled |

### Paramètres - Sécurité

| Paramètre | Valeur |
|---|---|
| Tamper Protection | Enabled |
| Disable Local Admin Merge | Disabled |
| Days To Retain Cleaned Malware | 30 |
| Disable Auto Exclusions | Not Configured |

### Affectation

| Groupe |
|---|
| MDE-CatchAll-Windows |

### Remarques

Aucune exclusion à ce niveau. Les exclusions spécifiques doivent vivre dans des policies dédiées, justifiées et revues tous les six mois.

---

## MDE-AV-Workstations-Production

Couche antivirus spécifique aux postes de travail. Hérite du catch-all et ajoute des paramètres orientés usage utilisateur.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Microsoft Defender Antivirus |
| Nom | MDE-AV-Workstations-Production |

### Paramètres

| Paramètre | Valeur |
|---|---|
| Scan Parameter | Full scan |
| Schedule Scan Day | Saturday |
| Schedule Quick Scan Time | 720 (12:00) |
| Schedule Scan Time | 120 (02:00) |
| Avg CPU Load Factor | 25 |
| Disable CPU Throttle On Idle Scans | Disabled |
| Check For Signatures Before Running Scan | Enabled |
| Signature Update Interval | 4 |

### Affectation

| Groupe |
|---|
| MDE-Production-Workstations |

---

## MDE-AV-Servers-Production

Couche antivirus spécifique aux serveurs.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Microsoft Defender Antivirus |
| Nom | MDE-AV-Servers-Production |

### Paramètres

| Paramètre | Valeur |
|---|---|
| Scan Parameter | Quick scan |
| Schedule Scan Day | Sunday |
| Schedule Quick Scan Time | 180 (03:00) |
| Avg CPU Load Factor | 10 |
| Disable CPU Throttle On Idle Scans | Disabled |
| Disable Auto Exclusions | Not Configured |
| Allow On Access Protection | Allowed |

### Affectation

| Groupe |
|---|
| MDE-Production-Servers |

### Remarques

Les exclusions automatiques liées aux rôles serveur (Exchange, SQL Server, AD DS, IIS, Hyper-V) sont appliquées automatiquement par Windows Server 2016 et plus récent tant que `Disable Auto Exclusions` reste à `Not Configured` ou `Disabled`.

---

## MDE-AV-Workstations-Pilot

Couche antivirus la plus stricte, appliquée aux postes pilote pour identification des faux positifs avant rollout production.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Microsoft Defender Antivirus |
| Nom | MDE-AV-Workstations-Pilot |

### Paramètres

| Paramètre | Valeur |
|---|---|
| Cloud Block Level | High Plus |

### Affectation

| Groupe |
|---|
| MDE-Pilot-Workstations |

---

## MDE-AV-Servers-Pilot

Équivalent du pilote postes pour les serveurs.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Microsoft Defender Antivirus |
| Nom | MDE-AV-Servers-Pilot |

### Paramètres

| Paramètre | Valeur |
|---|---|
| Cloud Block Level | High Plus |

### Affectation

| Groupe |
|---|
| MDE-Pilot-Servers |

---

## MDE-FW-CatchAll

Configuration globale du firewall Windows appliquée à tous les appareils Windows.

### Création

`Sécurité des points de terminaison > Pare-feu > Créer une policy`

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Pare-feu Microsoft Defender |
| Nom | MDE-FW-CatchAll |

### Paramètres - Profil Domaine

| Paramètre | Valeur |
|---|---|
| Enable Firewall | True |
| Default Inbound Action | Block |
| Default Outbound Action | Allow |
| Disable Unicast Responses To Multicast Broadcast Traffic | False |
| Disable Stealth Mode | False |
| Disable Stealth Mode IPsec Secured Packet Exemption | False |
| Allow Local Policy Merge | False |
| Allow Local IPsec Policy Merge | False |
| Disable Inbound Notifications | False |

### Paramètres - Profil Privé

Mêmes valeurs que le profil Domaine.

### Paramètres - Profil Public

Mêmes valeurs que le profil Domaine.

### Affectation

| Groupe |
|---|
| MDE-CatchAll-Windows |

### Remarques

Pour les serveurs, une copie de cette policy peut être créée avec `Disable Inbound Notifications = True` (pas de popup utilisateur pertinente sur serveur sans session interactive). Affectation : `MDE-CatchAll-Windows` (mais celle-ci sera filtrée naturellement par l'absence d'utilisateur sur les serveurs).

---

## MDE-FW-Rules-Workstations

Règles firewall spécifiques aux postes de travail.

### Création

`Sécurité des points de terminaison > Pare-feu > Créer une policy`

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Règles de pare-feu Microsoft Defender |
| Nom | MDE-FW-Rules-Workstations |

### Règles

**Block-Outbound-SMB-Internet**

| Paramètre | Valeur |
|---|---|
| Direction | Outbound |
| Action | Block |
| Protocole | TCP |
| Ports distants | 445 |
| Adresses distantes | Internet (groupe prédéfini) |
| Profils | Domaine, Privé, Public |
| Description | Empêche les mouvements latéraux SMB sortants vers Internet |

**Block-Outbound-Legacy-Protocols**

| Paramètre | Valeur |
|---|---|
| Direction | Outbound |
| Action | Block |
| Protocole | TCP |
| Ports distants | 21, 23, 69 |
| Profils | Domaine, Privé, Public |
| Description | Bloque Telnet, FTP et TFTP sortants |

**Block-Inbound-RDP-Public**

| Paramètre | Valeur |
|---|---|
| Direction | Inbound |
| Action | Block |
| Protocole | TCP |
| Ports locaux | 3389 |
| Profils | Public |
| Description | Empêche RDP entrant sur profil Public (café, aéroport) |

**Allow-Inbound-ICMPv4-Echo-Domain**

| Paramètre | Valeur |
|---|---|
| Direction | Inbound |
| Action | Allow |
| Protocole | ICMPv4 |
| Type ICMP | 8 (Echo Request) |
| Profils | Domaine |
| Description | Autorise le ping entrant sur profil Domaine pour supervision |

### Affectation

| Groupe |
|---|
| MDE-Pilot-Workstations |
| MDE-Production-Workstations |

---

## MDE-FW-Rules-Servers

Règles firewall spécifiques aux serveurs.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Règles de pare-feu Microsoft Defender |
| Nom | MDE-FW-Rules-Servers |

### Règles

**Block-Inbound-SMB-Internet**

| Paramètre | Valeur |
|---|---|
| Direction | Inbound |
| Action | Block |
| Protocole | TCP |
| Ports locaux | 445 |
| Adresses distantes | Internet |
| Profils | Domaine, Privé, Public |
| Description | Bloque SMB entrant depuis Internet |

**Block-Inbound-RDP-Public-Servers**

| Paramètre | Valeur |
|---|---|
| Direction | Inbound |
| Action | Block |
| Protocole | TCP |
| Ports locaux | 3389 |
| Profils | Public |
| Description | Bloque RDP sur Public en cas de bascule de profil involontaire |

**Allow-Inbound-RDP-Admin-Subnet**

| Paramètre | Valeur |
|---|---|
| Direction | Inbound |
| Action | Allow |
| Protocole | TCP |
| Ports locaux | 3389 |
| Adresses distantes | À renseigner : subnet d'administration |
| Profils | Domaine |
| Description | Autorise RDP depuis le subnet d'administration uniquement |

**Allow-Inbound-WinRM-Admin-Subnet**

| Paramètre | Valeur |
|---|---|
| Direction | Inbound |
| Action | Allow |
| Protocole | TCP |
| Ports locaux | 5985, 5986 |
| Adresses distantes | À renseigner : subnet d'administration |
| Profils | Domaine |
| Description | Autorise WinRM depuis le subnet d'administration uniquement |

### Affectation

| Groupe |
|---|
| MDE-Pilot-Servers |
| MDE-Production-Servers |

### Remarques

Les règles applicatives liées à des rôles serveur spécifiques (IIS sur 443, SQL Server sur 1433, Exchange sur SMTP/IMAP/HTTPS) doivent vivre dans des policies dédiées par rôle, pas dans le socle commun.

---

## MDE-ASR-LowRisk-Block

Règles ASR à faible risque, activables directement en mode Block.

### Création

`Sécurité des points de terminaison > Réduction de la surface d'attaque > Créer une policy`

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Règles de réduction de la surface d'attaque |
| Nom | MDE-ASR-LowRisk-Block |

### Règles

| Règle | GUID | État |
|---|---|---|
| Block credential stealing from LSASS | 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2 | Block |
| Block abuse of exploited vulnerable signed drivers | 56a863a9-875e-4185-98a7-b882c64b5ce5 | Block |
| Block persistence through WMI event subscription | e6db77e5-3df2-4cf1-b95a-636979351e5b | Block |
| Block execution of potentially obfuscated scripts | 5beb7efe-fd9a-4556-801d-275e5ffc04cc | Block |
| Block JavaScript or VBScript from launching downloaded executable content | d3e037e1-3eb8-44c8-a917-57927947596d | Block |
| Block executable content from email client and webmail | be9ba2d9-53ea-4cdc-84e5-9b1eeee46550 | Block |
| Block untrusted and unsigned processes that run from USB | b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4 | Block |
| Block executable files from running unless they meet a prevalence, age, or trusted list criterion | 01443614-cd74-433a-b99e-2ecdc07bfc25 | Block |
| Use advanced protection against ransomware | c1db55ab-c21a-4637-bb3f-a12568109d35 | Block |

### Affectation

| Groupe |
|---|
| MDE-CatchAll-Windows |

### Remarques

La règle LSASS est activée par défaut depuis 2022 par Microsoft. Elle ne supporte pas le mode Warn et intègre un filtrage interne pour réduire les faux positifs. Si LSA Protection est activée au niveau Windows, la règle ASR est classée "Not Applicable".

---

## MDE-ASR-Office-Audit

Règles ASR Office en mode Audit pour identification des workflows métier impactés.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Règles de réduction de la surface d'attaque |
| Nom | MDE-ASR-Office-Audit |

### Règles

| Règle | GUID | État |
|---|---|---|
| Block all Office applications from creating child processes | d4f940ab-401b-4efc-aadc-ad5f3c50688a | Audit |
| Block Office applications from creating executable content | 3b576869-a4ec-4529-8536-b80a7769e899 | Audit |
| Block Office applications from injecting code into other processes | 75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84 | Audit |
| Block Win32 API calls from Office macros | 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b | Audit |
| Block Adobe Reader from creating child processes | 7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c | Audit |

### Affectation

Phase initiale : `MDE-Pilot-Workstations`

Phase 2 (après validation pilote) : ajout de `MDE-Production-Workstations`

---

## MDE-ASR-Office-Warn

Mêmes règles que ci-dessus en mode Warn, à l'exception de `Block Win32 API calls from Office macros` qui ne supporte pas Warn.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Règles de réduction de la surface d'attaque |
| Nom | MDE-ASR-Office-Warn |

### Règles

| Règle | GUID | État |
|---|---|---|
| Block all Office applications from creating child processes | d4f940ab-401b-4efc-aadc-ad5f3c50688a | Warn |
| Block Office applications from creating executable content | 3b576869-a4ec-4529-8536-b80a7769e899 | Warn |
| Block Office applications from injecting code into other processes | 75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84 | Warn |
| Block Win32 API calls from Office macros | 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b | Audit |
| Block Adobe Reader from creating child processes | 7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c | Warn |

### Affectation

| Groupe |
|---|
| MDE-Production-Workstations |

### Remarques

La règle `Block Win32 API calls from Office macros` reste en Audit car elle ne supporte pas Warn. Elle pourra passer en Block dans la policy `MDE-ASR-Office-Block`.

---

## MDE-ASR-Office-Block

Mêmes règles en mode Block, après validation complète de la phase Warn.

### Création

| Champ | Valeur |
|---|---|
| Plateforme | Windows 10, Windows 11 et Windows Server |
| Profil | Règles de réduction de la surface d'attaque |
| Nom | MDE-ASR-Office-Block |

### Règles

| Règle | GUID | État |
|---|---|---|
| Block all Office applications from creating child processes | d4f940ab-401b-4efc-aadc-ad5f3c50688a | Block |
| Block Office applications from creating executable content | 3b576869-a4ec-4529-8536-b80a7769e899 | Block |
| Block Office applications from injecting code into other processes | 75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84 | Block |
| Block Win32 API calls from Office macros | 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b | Block |
| Block Adobe Reader from creating child processes | 7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c | Block |

### Affectation

| Groupe |
|---|
| MDE-Production-Workstations |

### Remarques

Cette policy remplace `MDE-ASR-Office-Warn` après la phase d'observation Warn. Les deux policies ne doivent pas coexister sur le même groupe (risque de Conflit sur les valeurs simples).

---

## Configuration au niveau tenant

Quelques paramètres à activer côté portail Microsoft Defender, indépendants des policies Intune.

### Tamper Protection (niveau tenant)

`security.microsoft.com > Paramètres > Points de terminaison > Caractéristiques avancées > Protection contre les altérations`

État : Activé

### Investigation automatisée

`security.microsoft.com > Paramètres > Points de terminaison > Caractéristiques avancées > Automated Investigation`

État : Activé. Mode initial recommandé : Semi (validation manuelle des remédiations).

### Live Response pour les serveurs

`security.microsoft.com > Paramètres > Points de terminaison > Caractéristiques avancées > Live Response for Servers`

État : Activé (nécessite MDE P2).

### Allow or block file

`security.microsoft.com > Paramètres > Points de terminaison > Caractéristiques avancées > Allow or block file`

État : Activé. Permet de bloquer manuellement des fichiers par hash depuis le portail.

---

## Récapitulatif des règles dynamiques de groupes

Les règles d'appartenance pour les groupes dynamiques se configurent dans le portail Entra ID.

### MDE-CatchAll-Windows

```
(device.deviceOSType -eq "Windows")
```

### MDE-Production-Workstations

```
(device.deviceOSType -eq "Windows") 
and (device.deviceOSVersion -notStartsWith "10.0.17763")
and (device.deviceOSVersion -notStartsWith "10.0.20348")
and (device.displayName -startsWith "WRK-")
```

À adapter selon la convention de nommage et les versions Windows Server présentes dans le parc.

### MDE-Production-Servers

```
(device.deviceOSType -eq "Windows") 
and (device.displayName -startsWith "SRV-")
```

À adapter selon la convention de nommage.

### Groupes pilote

Membres statiques. Pas de règle dynamique.

---

## Notes importantes

Quelques paramètres documentés ici nécessitent une validation en environnement réel avant adoption à grande échelle :

- **Avg CPU Load Factor**, **Signature Update Interval**, **Days To Retain Cleaned Malware** : valeurs raisonnables proposées, à confirmer selon le contexte
- **GUID de la règle "Block executable files unless prevalence..."** : règle au comportement particulier, validation recommandée en mode Audit avant Block
- **Règles dynamiques Entra ID basées sur deviceOSVersion** : les versions d'OS doivent être adaptées au parc réel
- **Nomenclature exacte des paramètres dans Intune** : Microsoft adapte ponctuellement les noms entre versions de l'admin center. Les noms peuvent légèrement différer au moment du déploiement.
