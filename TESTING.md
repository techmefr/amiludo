# Tester le compagnon

L’alpha est publique, gratuite et utilisable sans compte. Le nom reste provisoire.

- **Web, ordinateur et mobile :** https://techmefr.github.io/ludoply/app/
- **Android :** télécharger le fichier APK de la dernière [version de test](https://github.com/techmefr/ludoply/releases). Autoriser son installation depuis votre navigateur si Android le demande.
- **iPhone et iPad :** tester le site dans Safari. Aucune application iOS native n’est distribuée actuellement.

## Un premier essai en dix minutes

1. Créer une partie avec plusieurs joueurs, ajouter des points et une manche.
2. Annuler puis rétablir une modification ; fermer puis rouvrir l’application pour vérifier la reprise.
3. Essayer les dés, un tirage, les équipes et une horloge avec pause.
4. Choisir un univers, une palette et une police ; vérifier leur conservation après rechargement.
5. Désactiver les sons, vibrations et animations selon vos préférences.
6. Exporter une sauvegarde JSON et la conserver. Tester une restauration uniquement avec des données que vous pouvez remplacer.
7. Après un premier chargement complet connecté, passer hors connexion, rouvrir et modifier une partie. Revenir en ligne si les ressources n’ont pas fini de se télécharger.
8. Terminer une partie et retrouver son résultat dans l’historique ; essayer l’export CSV.

## Signaler un problème

Utiliser le [formulaire de bug](https://github.com/techmefr/ludoply/issues/new?template=bug_report.yml). Indiquer la version affichée dans « À propos », l’appareil, le navigateur et les étapes pour reproduire. Ne joindre aucune sauvegarde contenant des informations personnelles ; utiliser des joueurs fictifs.

Les [Discussions](https://github.com/techmefr/ludoply/discussions) accueillent les questions et les retours d’usage. Pour une nouvelle fonction, décrire le jeu concerné et le besoin dans le [formulaire de proposition](https://github.com/techmefr/ludoply/issues/new?template=feature_request.yml).

## Limites de cette alpha

Les parcours Chromium ont été contrôlés, dont les scores persistants et le rechargement hors connexion. Les essais sur téléphones physiques, Safari, le multitouch, les vibrations et les comportements en veille restent à compléter. Les sons dépendent aussi du système. Une horloge ne garantit pas une alarme lorsque le système suspend l’application.

Le navigateur peut effacer le stockage local. Exporter régulièrement une sauvegarde. Les APK de test utilisent une signature de développement ; une mise à jour peut nécessiter une désinstallation. **Sauvegarder avant de mettre à jour**, car désinstaller efface les données locales.

Les salles partagées, tournois et autres fonctions non cochées du [catalogue](docs/FEATURES.md) ne sont pas encore disponibles.
