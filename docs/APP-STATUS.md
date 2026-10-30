# Application — état réel

Version alpha 0.1.0. Code Flutter dans app/. Le nom est provisoire. Les maquettes HTML restent disponibles ; l’application est publiée séparément dans /app/.

## Réalisé

Le moteur de scores, les parties locales, les modèles génériques, les ressources, les minuteries et les profils sont reliés à Drift/SQLite. Les données d’historique sont réelles. Les six modèles configurent effectivement les règles du compteur et la durée. Les outils aléatoires ont leurs propres interactions, et les favoris personnalisent l’accueil. Les sauvegardes JSON sont validées avant remplacement.

Trois univers, dix palettes et sept polices embarquées ; le thème s’applique à tous les écrans. Le projet contient les cibles Android, iOS et web. Le workflow vérifie l’analyse et les tests avant publication et construit un APK de test séparé.

## Vérifié

19 tests couvrent les scores par manche et catégorie, égalités, coopération, annulation/rétablissement, rotation, imports, sauvegardes, SQLite, écritures concurrentes, isolation des horloges entre tables, tirages, dés, temps et le parcours de création de partie. Les parcours navigateur et le fonctionnement hors connexion sont également contrôlés avant publication.

## À réaliser

La totalité du catalogue de 141 fonctionnalités n’est pas livrée. Restent notamment les salles multi-appareils et leur serveur, les tournois, les cadences avancées, les formules de score, les profils de joueurs complets, les statistiques détaillées, les exports d’images, les intégrations et la traduction intégrale en anglais. Le comptage de doigts, l’audio, le maintien de l’écran et l’exécution en arrière-plan doivent être vérifiés sur les téléphones physiques ciblés.

La cible iOS n’est pas compilée sur Linux ; la distribution native nécessite Xcode et une signature Apple. Un APK de test n’est pas une publication Google Play.
