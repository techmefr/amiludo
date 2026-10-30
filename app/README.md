# Compagnon — Flutter app (alpha)

Application Android, iOS et web, nom provisoire. Flutter 3.47.9 / Dart 3.13.7. Code en couches fonctionnelles et techniques. Les maquettes HTML restent dans ../prototype.

## Lancer

```sh
flutter pub get
flutter run -d chrome
```

Pour les navigateurs, les composants SQLite et le worker Drift sont inclus dans web/. Les polices sont embarquées avec leurs licences OFL ; aucun chargement de police externe au démarrage.

## Vérifier

```sh
flutter analyze
flutter test
```

Après une modification des tables Drift : `dart run build_runner build`. Les sources générées sont versionnées pour que le projet se lance directement.

## Construire

À la racine du dépôt : `bash scripts/build_web.sh`. APP_BASE_PATH permet de changer le chemin public ; la valeur par défaut est /ludoply/app/. Le script produit un cache hors connexion à partir des fichiers compilés. Une première ouverture connectée et la fin du téléchargement sont nécessaires avant une utilisation sans réseau. Le navigateur peut effacer ses données : exporter une sauvegarde reste utile.

Android : `flutter build apk --debug` pour une installation de test, avec Android SDK et JDK 17. Le workflow GitHub produit cet APK en artefact. Il ne s’agit pas d’une version signée pour les boutiques. Le projet iOS nécessite macOS, Xcode et une identité de signature pour distribuer une application native ; il n’est pas compilé sur Linux.

## Périmètre réel

- Parties locales de 1 à 32 participants ; noms réutilisables et revanche.
- Scores décimaux et négatifs, manches, catégories, journal, annulation et rétablissement, classements et égalités, objectifs individuels et coopératifs, ressources et notes.
- Minuteur libre, temps par tour, réserves par joueur, incrément et pause ; réglages conservés par table.
- Dés polyédriques multiples, verrouillage, expressions et symboles ; tirage sécurisé, équipes, ordre, roue pondérée, pièce, nombres, sac sans remise et rôles secrets.
- Six modèles intégrés réellement utilisés et éditeur de modèles JSON.
- Historique réel, import/export de parties et modèles, CSV, sauvegarde complète, restauration et suppression confirmée.
- Univers Cyberdeck / Orbital / Carnet, dix palettes, sept polices locales, formes, densité, lecture agrandie, animations, profils de style et import/export.
- Interface française et principaux contrôles en anglais. La traduction exhaustive et les tests de lecteurs d’écran restent à compléter.

Les salles multi-appareils, le serveur, les tournois, les cadences avancées, le moteur de formules et les intégrations ne sont pas implémentés. Le catalogue global distingue ces fonctionnalités planifiées. Cette version est une alpha fonctionnelle, pas l’ensemble des 141 fonctions.

## Données et limites

Drift/SQLite enregistre un document de bibliothèque versionné dans une transaction ; les écritures sont sérialisées et les erreurs de sauvegarde sont visibles. Une sauvegarde incompatible est rejetée avant remplacement. Les changements de score peuvent être annulés après rechargement. Les outils aléatoires gardent leur résultat pendant leur ouverture ; leurs configurations ne constituent pas encore une bibliothèque de préréglages.

Les horloges utilisent une horloge monotone pendant l’exécution et un délai persistant pour la reprise. L’application ne promet pas d’alarme sonore lorsque le système suspend ou ferme le navigateur. Le maintien de l’écran allumé dépend des autorisations de la plateforme. La sélection par doigts dépend du matériel. Une roue pondérée affiche des secteurs égaux ; les poids modifient le tirage et sont explicitement indiqués dans son formulaire.

Une police de secours pour les symboles est également embarquée, et la roue respecte la réduction des animations.
