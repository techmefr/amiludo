# Compagnon — nom provisoire

**Tous les outils. Autour de la table.**

Compagnon open source pour les jeux de société, avec une direction rétrofuturiste Cyberdeck. Android, iOS et web à partir du même projet Flutter.

**[Ouvrir l’application](https://techmefr.github.io/ludoply/app/)** · [APK Android de test](https://github.com/techmefr/ludoply/releases/download/v0.1.0-alpha.1/compagnon-0.1.0-alpha.1-android.apk) · [Maquettes](https://techmefr.github.io/ludoply/) · [État réel du développement](docs/APP-STATUS.md)

## Version alpha fonctionnelle

- Parties et scores réels : manches, catégories, ressources, objectifs coopératifs, classement et égalités, notes, annulation/rétablissement et revanche.
- Minuteur libre, temps par tour, réserve par joueur et incrément, avec réglages conservés par table.
- Dés multiples verrouillables, expressions et symboles ; choix du premier joueur, équipes, ordre, pièce, roue pondérée, nombres, sac de jetons et rôles secrets.
- Six modèles intégrés exécutables et éditeur de modèles importables et partageables.
- SQLite local, historique, JSON, CSV, sauvegarde/restauration complète et suppression confirmée.
- Trois univers, dix palettes, sept polices embarquées et profils personnels.

Aucun compte ni serveur requis pour ces fonctions. Aucun affichage publicitaire. La version web possède un cache explicite ; une première ouverture connectée est nécessaire pour télécharger les ressources. La fiabilité native et les comportements en arrière-plan doivent encore être vérifiés sur de vrais téléphones.

Le catalogue comprend aussi des fonctions **non implémentées**, notamment les salles partagées et leur serveur, les tournois, les cadences avancées et les intégrations. Cette alpha ne constitue pas la livraison de la totalité des 141 fonctions prévues. Le nom Ludoply reste uniquement l’identifiant historique du dépôt.

## Développer

Flutter **3.47.9**, Dart **3.13.7**. Les dépendances sont verrouillées dans app/pubspec.lock.

```sh
cd app
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Depuis la racine : `bash scripts/build_web.sh` compile le web avec les ressources du moteur en local et génère le cache hors connexion. Le chemin peut être changé via APP_BASE_PATH.

Le workflow GitHub vérifie le code avant de publier la version web et construit séparément un **APK Android de test**. iOS nécessite macOS, Xcode et une signature pour une distribution native. Voir [le guide de l’application](app/README.md).

## Documents

- [Catalogue fonctionnel et statut](docs/FEATURES.md)
- [Feuille de route](docs/ROADMAP.md)
- [Choix techniques](docs/TECHNOLOGY.md)
- [État de l’application et limites](docs/APP-STATUS.md)
- [Contribuer](CONTRIBUTING.md)
- [Maquettes et captures](design/mockups/)

Code et concepts originaux sous licence MIT. Les polices embarquées conservent leurs licences OFL. Le nom définitif et le logo restent à choisir.
