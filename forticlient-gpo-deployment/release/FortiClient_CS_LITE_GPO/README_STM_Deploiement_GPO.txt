# Déploiement FortiClient EMS Cloud par GPO - STM

## Objectif

Ce dossier fournit un paquet de déploiement pour installer FortiClient sur des postes Windows STM au moyen d'une stratégie de groupe Microsoft GPO.

Le paquet est prévu pour une installation silencieuse en contexte ordinateur, avec les fichiers MSI/MST générés depuis FortiClient EMS Cloud et fournis par ARTM.

Les fichiers binaires FortiClient sont inclus dans ce dépôt.

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
install_forticlient_stm.bat
```

Le script doit être exécuté en contexte ordinateur, avant l'ouverture de session utilisateur. Cela évite de dépendre des droits de l'utilisateur connecté.

## Disposition attendue côté STM

Le script suppose que le MSI et le MST se trouvent dans le même dossier que le fichier `.bat`.

Disposition minimale recommandée dans le partage ou l'emplacement GPO:

```text
FortiClient_GPO_STM/
├── install_forticlient_stm.bat
├── uninstall_forticlient_stm.bat
├── forticlient.msi
├── forticlient.mst
└── forticlientsetup_7.4.7_x64.exe
```

## Commande d'installation

Le script lance l'installation silencieuse avec:

```cmd
msiexec.exe /i "%MSI_FILE%" TRANSFORMS="%MST_FILE%" GROUP_TAG="%GROUP_TAG%" /qn /norestart /L*v "%LOG_FILE%"
```

Codes de retour traités comme succès:

- `0`: succès
- `3010`: succès, redémarrage requis mais non forcé
- `1641`: succès, redémarrage initié par Windows Installer

Tout autre code est retourné par le script afin que STM puisse diagnostiquer l'échec.

## Exigence MSI/MST

STM a demandé un MSI, les fichiers nécessaires et un script `.bat` pour installation silencieuse par GPO.

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
GROUP_TAG=VP_CS_LEGER
```

Ce paramètre sert à identifier le groupe ou l'Installer ID attendu. Si l'Installer ID est déjà intégré dans le paquet généré par EMS Cloud, STM/ARTM peut retirer le paramètre `GROUP_TAG="%GROUP_TAG%"` de la commande `msiexec.exe`.

## Journalisation

Les journaux sont écrits ici:

```text
C:\ProgramData\Fortinet\FortiClient\InstallLogs
```

Journal d'installation:

```text
C:\ProgramData\Fortinet\FortiClient\InstallLogs\FortiClient_STM_install.log
```

Journal de désinstallation:

```text
C:\ProgramData\Fortinet\FortiClient\InstallLogs\FortiClient_STM_uninstall.log
```

## Validation après déploiement

Sur un poste cible:

- Confirmer que FortiClient apparaît dans les applications installées Windows.
- Vérifier le journal d'installation dans `C:\ProgramData\Fortinet\FortiClient\InstallLogs`.
- Confirmer que le poste apparaît dans FortiClient EMS Cloud.
- Confirmer que le poste rejoint le bon groupe EMS.
- Confirmer que le profil `VPN-CERT` est reçu.
- Tester une connexion VPN par certificat.

## Rollback / désinstallation

Le script `uninstall_forticlient_stm.bat` tente de détecter FortiClient par PowerShell, récupère le `ProductCode`, puis lance:

```cmd
msiexec.exe /x {ProductCode} /qn /norestart
```

La désinstallation peut dépendre des politiques EMS, de la protection contre l'altération, des contrôles administratifs ou de paramètres appliqués au client.

## Limites connues et points à valider

- Le poste apparaît correctement dans EMS.
- Le poste est placé dans le bon groupe EMS.
