# Fichiers FortiClient à placer ici

Ajouter ici les fichiers générés depuis FortiClient EMS Cloud avant de préparer le paquet de distribution:

- `forticlient.msi`
- `forticlient.mst`
- `forticlientsetup_7.4.7_x64.exe`

Ce dossier sert de zone de préparation. Pour l'exécution réelle par GPO, les fichiers MSI/MST doivent être copiés dans le même dossier que le script `.bat`, ou les chemins relatifs du script doivent être ajustés.

Les noms de fichiers doivent correspondre aux variables utilisées dans le script d'installation. Si les noms changent, mettre à jour les variables `MSI_FILE` et `MST_FILE` dans `scripts/install_forticlient_gpo.bat`.
