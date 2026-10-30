# Choix techniques

Décision initiale du 30 octobre 2026. Ces choix sont désormais appliqués dans app/ : Flutter 3.47.9, Riverpod, Drift/SQLite, polices locales et fichiers JSON. Les versions exactes sont dans app/pubspec.lock.

| Besoin | Choix | Motif |
|---|---|---|
| Android, iOS, web interactif | Flutter stable + Dart | Un code applicatif partagé, adapté aux interactions tactiles et au mode table |
| État et dépendances | Riverpod | États testables et partage des joueurs, scores et outils |
| Navigation | go_router | Navigation déclarative et liens vers les outils |
| Persistance | Drift + SQLite | Données relationnelles, transactions et migrations ; moteur natif sur mobile et Wasm sur web |
| Modèles communautaires | JSON + JSON Schema | Contributions simples, validation et versionnement ; aucune exécution arbitraire |
| Traductions | Flutter l10n, fichiers ARB | Français et anglais dès le départ |
| Identité | SVG originaux | Icônes vectorielles légères, concepts à valider |
| Vérifications | flutter_test + integration_test | Calculs, annulation, reprise, migrations, parcours essentiels |
| Automatisation | GitHub Actions | Analyse, tests et construction web ; builds mobiles à ajouter après configuration |
| Licence | MIT | Réutilisation et contributions ouvertes ; le nom ne vaut pas autorisation de représenter le projet |

## Structure visée

Une application Flutter organisée par fonctions : players, sessions, scores, random, timers, presets, history. Un cœur Dart indépendant de l’interface contient les calculs et les événements de partie. Inutile de créer un monorepo ou plusieurs services au démarrage.

## Hors connexion

La base locale fait autorité pour une partie individuelle. Les modifications de score passent par des transactions et un journal permettant annulation et reprise. Séparer les données durables de l’animation et du rafraîchissement visuel des horloges.

Sur le web, configurer explicitement le moteur SQLite Wasm et ses fichiers/headers, ainsi qu’un service worker pour le cache applicatif. Vérifier les restrictions de stockage, les modes privés et la compatibilité des navigateurs ciblés. Ne pas promettre d’alarmes persistantes lorsque le système suspend l’application.

## Site de présentation

Le web applicatif sera Flutter. Un site vitrine et des documents indexables pourront être des pages HTML statiques séparées, générées avec Astro si le besoin apparaît. Pas de second framework avant ce besoin.

## Serveur : différé

Aucun backend, compte ou abonnement nécessaire pour le MVP. Pour V2, Supabase/PostgreSQL est une piste pour les comptes facultatifs et les salles ; le choix dépendra d’un prototype de synchronisation. Realtime seul ne constitue pas un mécanisme de synchronisation hors ligne. Prévoir identifiants d’actions, idempotence, autorité, reprise et contrôle des accès. Aucun service payant ni projet cloud créé ici.

## Validation préalable au développement étendu

- Prototype multi-touch sur vrais téléphones, avec solution par liste.
- Horloges en veille et après fermeture/reprise sur chaque plateforme.
- Drift natif et web, migration et import/export.
- Navigation clavier, lecteurs d’écran et texte agrandi.
- Vérifier les versions et licences des paquets au moment de l’installation ; fixer Flutter et conserver pubspec.lock.

## Sources officielles

- https://docs.flutter.dev/platform-integration/web
- https://drift.simonbinder.eu/platforms/
- https://riverpod.dev/
