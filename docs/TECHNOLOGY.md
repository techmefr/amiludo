# Choix techniques

Décision initiale du 30 octobre 2026. Ces choix sont désormais appliqués dans app/ : Flutter 3.47.9, flutter_bloc (Cubit) + get_it, Drift/SQLite, polices locales et fichiers JSON. Les versions exactes sont dans app/pubspec.lock.

| Besoin | Choix | Motif |
|---|---|---|
| Android, iOS, web interactif | Flutter stable + Dart | Un code applicatif partagé, adapté aux interactions tactiles et au mode table |
| État et dépendances | flutter_bloc (Cubit) + get_it | Cubit par feature, use cases injectés, contrats de gateway testables |
| Navigation | go_router | Navigation déclarative et liens vers les outils |
| Persistance | Drift + SQLite | Données relationnelles, transactions et migrations ; moteur natif sur mobile et Wasm sur web |
| Modèles communautaires | JSON + JSON Schema | Contributions simples, validation et versionnement ; aucune exécution arbitraire |
| Traductions | Flutter l10n, fichiers ARB | Français et anglais dès le départ |
| Identité | SVG originaux | Logo « La boîte » dans design/logo, icônes générées depuis le SVG |
| Vérifications | flutter_test + integration_test | Calculs, annulation, reprise, migrations, parcours essentiels |
| Automatisation | GitHub Actions | Analyse, tests et construction web ; builds mobiles à ajouter après configuration |
| Licence | MIT | Réutilisation et contributions ouvertes ; le nom ne vaut pas autorisation de représenter le projet |

## Structure visée

Le code suit l’architecture OSDD :
- **Couches fonctionnelles**, dans `lib/layers/functional/<Feature>` : Account, Appearance, Evenings, Friends, Game, History, Library, Lobby, Memories, Random, Sharing, Templates, Timer, Workspace.
- **Couches techniques**, dans `lib/layers/technical/<Layer>` : About, Appearance, Feedback, Files, Network, Qr, Storage, Theme, Transfer.
- **Dans chaque feature** : domain (entities, gateways, use_cases), puis data (gateways), puis presentation (cubit, écrans).
- **Règles de dépendance** : une feature n’importe que le domain d’une autre, et technical n’importe jamais functional. `test/architecture_test.dart` fait échouer la CI si l’une de ces règles est enfreinte.
- **Assemblage** : `main.dart`, `router.dart` et `dependencies.dart`.

## Hors connexion

La base locale fait autorité pour une partie individuelle. Les modifications de score passent par des transactions et un journal permettant annulation et reprise. Séparer les données durables de l’animation et du rafraîchissement visuel des horloges.

Sur le web, configurer explicitement le moteur SQLite Wasm et ses fichiers/headers, ainsi qu’un service worker pour le cache applicatif. Vérifier les restrictions de stockage, les modes privés et la compatibilité des navigateurs ciblés. Ne pas promettre d’alarmes persistantes lorsque le système suspend l’application.

## Site de présentation

Le web applicatif sera Flutter. Un site vitrine et des documents indexables pourront être des pages HTML statiques séparées, générées avec Astro si le besoin apparaît. Pas de second framework avant ce besoin.

## Réseau et serveur

**Salon sur le même Wi‑Fi**, sans aucun serveur :
- l’hôte ouvre un `HttpServer` avec WebSocket sur `/room/<empreinte du code>` (dart:io) ;
- les invités trouvent l’adresse par une sonde UDP en broadcast sur le port 47474, qui ne porte qu’une empreinte du code ;
- un lien peut aussi porter l’adresse (`?lan=ip:port`), limitée aux plages privées ;
- indisponible dans le navigateur.

**À distance** : Supabase Realtime, canal broadcast `room:CODE`.

**Contrôle d’accès des salons** :
- le lien et le QR portent un secret d’hôte (`?k=`) ; l’hôte signe chaque état et la fermeture (HMAC-SHA256, numéro de séquence contre le rejeu) ;
- en Wi‑Fi, l’hôte prouve ce secret lors de la découverte et à la connexion ;
- chaque invité joint l’empreinte d’une clé à sa demande et ne libère que son propre siège en révélant cette clé ;
- un invité qui saisit seulement le code ne peut pas vérifier l’hôte.

**Comptes et soirées** :
- Supabase Auth (mot de passe, lien magique en PKCE avec code de secours, retour sur l’app web ou `amiludo://amiludo.app/account`) et PostgreSQL ;
- table `evenings` avec RLS, fonctions `security definer` réservées aux comptes connectés (`server/supabase/migrations`) ;
- l’hôte fait autorité sur l’état du salon.

Le serveur reste facultatif : sans `SUPABASE_URL` ni `SUPABASE_PUBLISHABLE_KEY` au build, tout fonctionne en local.

Realtime seul ne constitue pas une synchronisation hors ligne. Pour partager l’état d’une partie, il faudra prévoir :
- des identifiants d’actions ;
- l’idempotence ;
- l’autorité de l’hôte ;
- la reprise ;
- le contrôle des accès.

## Validation préalable au développement étendu

- Prototype multi-touch sur vrais téléphones, avec solution par liste.
- Horloges en veille et après fermeture/reprise sur chaque plateforme.
- Drift natif et web, migration et import/export.
- Navigation clavier, lecteurs d’écran et texte agrandi.
- Vérifier les versions et licences des paquets au moment de l’installation ; fixer Flutter et conserver pubspec.lock.

## Sources officielles

- https://docs.flutter.dev/platform-integration/web
- https://drift.simonbinder.eu/platforms/
- https://bloclibrary.dev/
