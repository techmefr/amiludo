# Application — état réel

Version alpha 0.1.0. Code Flutter dans app/. Le nom est provisoire. Les maquettes HTML restent disponibles ; l’application est publiée séparément dans /app/.

## Réalisé

Le moteur de scores, les parties locales, les modèles génériques, les ressources, les minuteries et les profils sont reliés à Drift/SQLite. Les données d’historique sont réelles. Les six modèles configurent effectivement les règles du compteur et la durée. Les outils aléatoires ont leurs propres interactions, et les favoris personnalisent l’accueil. Les sauvegardes JSON sont validées avant remplacement.

Trois univers, dix palettes et sept polices embarquées ; le thème s’applique à tous les écrans. Le projet contient les cibles Android, iOS et web. Le workflow vérifie l’analyse et les tests avant publication et construit un APK de test séparé.

## Vérifié

20 tests couvrent les scores par manche et catégorie, égalités, coopération, annulation/rétablissement, rotation, imports, sauvegardes, SQLite, écritures concurrentes, isolation des horloges entre tables, tirages, dés, temps et le parcours de création de partie. Les parcours navigateur et le fonctionnement hors connexion sont également contrôlés avant publication.

## À réaliser

La totalité du catalogue de 141 fonctionnalités n’est pas livrée. Restent notamment les salles multi-appareils et leur serveur, les tournois, les cadences avancées, les formules de score, les profils de joueurs complets, les statistiques détaillées, les exports d’images, les intégrations et la traduction intégrale en anglais. Le comptage de doigts, l’audio, le maintien de l’écran et l’exécution en arrière-plan doivent être vérifiés sur les téléphones physiques ciblés.

La cible iOS n’est pas compilée sur Linux ; la distribution native nécessite Xcode et une signature Apple. Un APK de test n’est pas une publication Google Play.

Une police de secours pour les symboles est également embarquée, et la roue respecte la réduction des animations.
## Validation de la publication

Le lien public a été testé dans Chromium : création de partie, scores persistants, rechargement sans réseau et nouvelle modification de score. Le chargement de l’interface ne sollicite plus de police ou de moteur externe pour les écrans vérifiés. Les sept choix de police ont également été contrôlés.

Les contrôles locaux et GitHub comprennent 20 tests Flutter et un test de régression du paquet hors connexion. Les parcours navigateur couvrent aussi l’éditeur de modèles, le CSV et les onglets mobiles. Les cases du catalogue indiquent ce périmètre alpha, et non une validation exhaustive de tous les appareils.