# Instructions courriel pour STM

Bonjour,

Vous trouverez ci-joint le paquet de déploiement FortiClient EMS Cloud par GPO.

Avant le dépôt côté STM, ARTM doit ajouter au paquet les fichiers générés depuis FortiClient EMS Cloud:

- `FortiClient.msi`
- `FortiClient.mst`

Ces fichiers doivent être placés dans le même dossier que le script d'installation, sauf si les chemins relatifs sont ajustés dans le script.

Méthode recommandée:

- Déployer `install_forticlient_stm.bat` comme script de démarrage ordinateur par GPO.
- Exécuter le script en contexte ordinateur / `Local System`.
- Ne pas exécuter le script en contexte utilisateur.

Le script installe FortiClient silencieusement avec `/qn /norestart` et écrit les journaux ici:

```text
C:\ProgramData\Fortinet\FortiClient\InstallLogs
```

Le group tag / Installer ID est:

```text
VP_CS_LEGER
```

Le profil VPN attendu est:

```text
VPN-CERT
```

Le comportement Always-On et la sélection de certificat en présence de plusieurs certificats devront être validés séparément.

Merci de consulter `README_STM_Deploiement_GPO.md` et `docs/validation_checklist.md` pour les étapes de validation.
