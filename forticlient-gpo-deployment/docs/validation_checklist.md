# Liste de validation - Déploiement FortiClient GPO STM

## 1. Pré-déploiement

- [ ] Le paquet FortiClient a été généré depuis FortiClient EMS Cloud.
- [ ] Les fichiers `FortiClient.msi` et `FortiClient.mst` ont été fournis par ARTM.
- [ ] Les fichiers MSI/MST sont placés dans le même dossier que `install_forticlient_stm.bat`, ou les chemins du script ont été ajustés.
- [ ] Le group tag / Installer ID attendu est `STM-VPN-CERT`.
- [ ] Le profil attendu est `VPN-CERT`.
- [ ] Le déploiement ne contient pas de configuration breakglass VPN par défaut.
- [ ] Le comportement Always-On est exclu de ce script et sera validé plus tard.

## 2. Déploiement GPO

- [ ] La GPO cible uniquement les postes prévus pour le déploiement.
- [ ] Le script est configuré comme script de démarrage ordinateur.
- [ ] Le script s'exécute en contexte `Local System` ou administratif équivalent.
- [ ] Les postes ciblés ont accès au chemin contenant le script et les fichiers MSI/MST.
- [ ] Le déploiement ne force pas de redémarrage.

## 3. Validation poste Windows

- [ ] FortiClient est installé sur le poste.
- [ ] Le fichier `C:\Program Files\Fortinet\FortiClient\FortiClient.exe` existe.
- [ ] Le journal d'installation existe dans `C:\ProgramData\Fortinet\FortiClient\InstallLogs`.
- [ ] Le journal ne contient pas d'erreur bloquante.
- [ ] Le code de retour GPO ou Windows Installer est `0`, `3010` ou `1641`.
- [ ] Aucun prompt interactif n'est affiché pendant l'installation.

## 4. Validation EMS

- [ ] Le poste apparaît dans FortiClient EMS Cloud.
- [ ] Le poste est associé au bon groupe EMS.
- [ ] L'Installer ID / group tag `STM-VPN-CERT` est reconnu comme prévu.
- [ ] Les politiques attendues sont appliquées au poste.

## 5. Validation VPN-CERT

- [ ] Le profil `VPN-CERT` est reçu par FortiClient.
- [ ] Le poste possède le certificat requis pour le test VPN.
- [ ] La connexion VPN par certificat fonctionne.
- [ ] Le comportement de sélection du certificat est validé si plusieurs certificats existent sur le poste.
- [ ] Les journaux côté FortiClient et EMS sont disponibles pour analyse en cas d'échec.

## 6. Points à documenter pendant le déploiement

- [ ] Nombre de postes ciblés par la GPO.
- [ ] Nombre de postes installés avec succès.
- [ ] Codes d'erreur observés, le cas échéant.
- [ ] Temps moyen avant apparition dans EMS.
- [ ] Groupe EMS réellement attribué.
- [ ] Réception du profil `VPN-CERT`.
- [ ] Résultats des tests VPN par certificat.
- [ ] Cas avec plusieurs certificats sur le poste.
- [ ] Résultat de la validation Always-On lorsqu'elle sera effectuée.
- [ ] Résultat d'un test de rollback/désinstallation.
