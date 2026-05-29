# Déploiement FortiClient EMS Cloud par GPO

## Objectif

Ce dossier fournit un paquet de déploiement réutilisable pour installer FortiClient sur des postes Windows au moyen d'une stratégie de groupe Microsoft GPO.

Le paquet est prévu pour une installation silencieuse en contexte ordinateur, avec les fichiers MSI/MST générés depuis FortiClient EMS Cloud.

## Contenu du paquet

```text
forticlient-gpo-deployment/
├── README_Deploiement_GPO.md
├── CHANGELOG.md
├── package/
│   └── README_PLACE_FORTICLIENT_FILES_HERE.md
├── scripts/
│   ├── install_forticlient_gpo.bat
│   └── uninstall_forticlient_gpo.bat
└── docs/
    ├── validation_checklist.md
    └── email_instructions.md
```

Les fichiers binaires FortiClient ne sont pas inclus dans ce dépôt.

## Hypothèses

- Le paquet FortiClient sera généré depuis FortiClient EMS Cloud.
- Les fichiers `forticlient.msi`, `forticlient.mst` et `forticlientsetup_7.4.7_x64.exe` doivent être ajoutés avant la distribution.
- Le script et les fichiers MSI/MST seront déployés via GPO.
- L'installation doit s'exécuter en contexte ordinateur, idéalement `Local System`, ou dans un contexte administratif équivalent.
- L'installation est silencieuse et ne force pas de redémarrage.
- Le profil VPN attendu est `YOUR_VPN_PROFILE`.
- L'Installer ID / group tag attendu est `YOUR_EMS_GROUP_TAG`.
- Le comportement Always-On sera validé séparément et n'est pas codé dans le script.
- Le VPN breakglass n'est pas inclus par défaut dans ce paquet de déploiement.

## Méthode GPO recommandée

La méthode recommandée est un script de démarrage ordinateur:

```text
Computer Configuration
└── Policies
    └── Windows Settings
        └── Scripts (Startup/Shutdown)
            └── Startup
```

Ajouter le script:

```text
install_forticlient_gpo.bat
```

Le script doit être exécuté en contexte ordinateur, avant l'ouverture de session utilisateur. Cela évite de dépendre des droits de l'utilisateur connecté.

## Disposition attendue pour le déploiement

Le script suppose que le MSI et le MST se trouvent dans le même dossier que le fichier `.bat`.
Le dossier `package/` de ce dépôt sert de zone de préparation pour recevoir les fichiers EMS générés. Pour l'exécution réelle par GPO, copier `forticlient.msi` et `forticlient.mst` dans le même dossier que le script, ou ajuster les chemins relatifs dans le script.

Disposition minimale recommandée dans le partage ou l'emplacement GPO:

```text
FortiClient_GPO_Package/
├── install_forticlient_gpo.bat
├── uninstall_forticlient_gpo.bat
├── forticlient.msi
├── forticlient.mst
└── forticlientsetup_7.4.7_x64.exe
```

Si une structure avec sous-dossiers est conservée, il faudra ajuster les variables `MSI_FILE` et `MST_FILE` dans le script.

## Commande d'installation

Le script lance l'installation silencieuse avec:

```cmd
msiexec.exe /i "%MSI_FILE%" TRANSFORMS="%MST_FILE%" GROUP_TAG="%GROUP_TAG%" /qn /norestart /L*v "%LOG_FILE%"
```

Codes de retour traités comme succès:

- `0`: succès
- `3010`: succès, redémarrage requis mais non forcé
- `1641`: succès, redémarrage initié par Windows Installer

Tout autre code est retourné par le script afin de diagnostiquer l'échec.

## Exigence MSI/MST

Le paquet fournit un MSI, les fichiers nécessaires et un script `.bat` pour installation silencieuse par GPO.

Le fichier `forticlient.msi` contient l'installateur utilisé par le script GPO. Le fichier `forticlient.mst` contient les paramètres de transformation générés avec le paquet EMS Cloud. Les deux fichiers doivent être disponibles au moment de l'exécution du script.

Le fichier `forticlientsetup_7.4.7_x64.exe` fait partie du paquet généré par EMS, mais le script GPO fourni ici lance l'installation par `msiexec.exe` avec le MSI/MST.

Les noms doivent correspondre aux variables du script:

```cmd
MSI_FILE=%PACKAGE_DIR%forticlient.msi
MST_FILE=%PACKAGE_DIR%forticlient.mst
```

## GROUP_TAG / Installer ID

Le script définit:

```cmd
GROUP_TAG=YOUR_EMS_GROUP_TAG
```

Ce paramètre sert à identifier le groupe ou l'Installer ID attendu. Si l'Installer ID est déjà intégré dans le paquet généré par EMS Cloud, retirer le paramètre `GROUP_TAG="%GROUP_TAG%"` de la commande `msiexec.exe`.

## Journalisation

Les journaux sont écrits ici:

```text
C:\ProgramData\Fortinet\FortiClient\InstallLogs
```

Journal d'installation:

```text
C:\ProgramData\Fortinet\FortiClient\InstallLogs\FortiClient_GPO_install.log
```

Journal de désinstallation:

```text
C:\ProgramData\Fortinet\FortiClient\InstallLogs\FortiClient_GPO_uninstall.log
```

## Validation après déploiement

Sur un poste cible:

- Confirmer que FortiClient apparaît dans les applications installées Windows.
- Vérifier le journal d'installation dans `C:\ProgramData\Fortinet\FortiClient\InstallLogs`.
- Confirmer que le poste apparaît dans FortiClient EMS Cloud.
- Confirmer que le poste rejoint le bon groupe EMS.
- Confirmer que le profil `YOUR_VPN_PROFILE` est reçu.
- Tester une connexion VPN par certificat.

## Rollback / désinstallation

Le script `uninstall_forticlient_gpo.bat` tente de détecter FortiClient par PowerShell, récupère le `ProductCode`, puis lance:

```cmd
msiexec.exe /x {ProductCode} /qn /norestart
```

La désinstallation peut dépendre des politiques EMS, de la protection contre l'altération, des contrôles administratifs ou de paramètres appliqués au poste.

## Limites connues et points à valider

- Le poste apparaît correctement dans EMS.
- Le poste est placé dans le bon groupe EMS.
- Le profil `YOUR_VPN_PROFILE` est reçu.
- La connexion VPN par certificat fonctionne.
- Le comportement Always-On sera validé plus tard.
- Le comportement de sélection du certificat doit être validé si plusieurs certificats sont présents sur le poste.
