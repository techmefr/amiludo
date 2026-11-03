<p align="center">
  <img src="design/logo/amiludo-app-icon.svg" width="112" alt="Logo amiLudo : une boîte de jeu violette qui s’ouvre">
</p>

<h1 align="center">amiLudo</h1>

<p align="center">
  <strong>Tous les outils. Autour de la table.</strong><br>
  Le compagnon open source des soirées jeux de société : scores, dés, chronos, équipes,<br>
  ludothèque, amis, salons à rejoindre par QR code et soirées avec inscriptions.
</p>

<p align="center">
  <a href="https://techmefr.github.io/amiludo/app/"><img alt="Ouvrir l’application" src="https://img.shields.io/badge/ouvrir-l’application-6f4fd0?style=for-the-badge"></a>
  <a href="https://github.com/techmefr/amiludo/releases"><img alt="APK Android" src="https://img.shields.io/badge/Android-APK%20de%20test-3ddc84?style=for-the-badge&logo=android&logoColor=white"></a>
</p>

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-0.4.0--alpha-orange?style=flat-square">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter">
  <img alt="Plateformes" src="https://img.shields.io/badge/Android%20·%20iOS%20·%20Web-un%20seul%20code-8250df?style=flat-square">
  <img alt="Tests" src="https://img.shields.io/badge/tests-109-1a7f37?style=flat-square">
  <img alt="Sans pub" src="https://img.shields.io/badge/publicité-aucune-1a7f37?style=flat-square">
  <a href="LICENSE"><img alt="Licence MIT" src="https://img.shields.io/badge/licence-MIT-blue?style=flat-square"></a>
</p>

<p align="center">
  <a href="#-ce-quon-peut-faire">Fonctions</a> ·
  <a href="#-jouer-ensemble">Jouer ensemble</a> ·
  <a href="#-démarrer">Démarrer</a> ·
  <a href="#-architecture">Architecture</a> ·
  <a href="#-documents">Documents</a> ·
  <a href="README.en.md">English</a>
</p>

<p align="center">
  <img src="design/screenshots/home-desktop.png" width="820" alt="Accueil d’amiLudo sur ordinateur : « On joue à quoi, aujourd’hui ? », boutons Mode libre, Ouvrir un salon et Rejoindre une partie, et outils de la table">
</p>

---

## 🎲 Pourquoi amiLudo

Une soirée jeux, c’est souvent un téléphone pour les dés, un papier pour les scores, un autre téléphone pour le chrono et un débat sur « qui commence ». amiLudo réunit tout ça dans une seule app pensée pour être posée **au milieu de la table** : grandes commandes, gestes simples, et des thèmes qui se règlent pour chaque joueur.

- **Hors connexion d’abord** : tout ce qui sert pendant la partie marche sans réseau, avec les données gardées sur l’appareil.
- **Sans compte obligatoire, sans publicité**. Le compte ne sert qu’aux soirées en ligne.
- **Un seul code Flutter** pour Android, iOS et le web.

## ✨ Ce qu’on peut faire

| | |
|---|---|
| 🧮 **Scores** | Manches, catégories, scores négatifs ou décimaux, objectifs coopératifs, ressources et statuts, annuler et rétablir, classement, égalités, revanche |
| 🎲 **Hasard** | Dés multiples verrouillables, expressions (`2d6+1`), qui commence (au doigt ou par nom), ordre du tour, pièce, roue pondérée, sac de jetons, rôles secrets |
| 👥 **Équipes** | À partir des noms saisis, des joueurs du salon ou des **doigts posés sur l’écran** |
| ⏱️ **Temps** | Chrono libre, temps par tour, réserve par joueur avec incrément, réglages gardés par table |
| 📚 **Ludothèque** | Vos jeux rangés sur des étagères, avec genres, nombre de joueurs, durée et packs liés |
| ❤️ **Amis** | Genres aimés ou évités, temps disponible, jeux refusés ou adorés malgré le genre |
| 🤔 **On joue à quoi ce soir ?** | Suggestions selon les amis présents, leurs envies et le temps dont vous disposez |
| 📸 **Souvenirs** | Notes, moments forts et photos, et une galerie privée échangée en fichier chiffré |
| 🧩 **Packs de jeu** | Dés, rôles, règles de décompte, personnages par listes ou boosters, et une galerie communautaire installable |
| 🎨 **Apparence** | Quatre univers (Playroom, Cyberdeck, Orbital, Carnet), onze palettes, sept polices, mode sombre, animations, sons et vibrations désactivables |
| 💾 **Données** | SQLite local, historique, export CSV et JSON, sauvegarde et restauration complètes |

<p align="center">
  <img src="design/screenshots/home-mobile.png" width="200" alt="Accueil sur téléphone">
  <img src="design/screenshots/dice-mobile.png" width="200" alt="Lancer de dés sur téléphone">
  <img src="design/screenshots/teams-mobile.png" width="200" alt="Formation d’équipes par noms ou au doigt">
  <img src="design/screenshots/lobby-mobile.png" width="200" alt="Ouverture d’un salon : même Wi-Fi ou à distance">
</p>

## 📡 Jouer ensemble

**Salons de partie.** L’hôte ouvre un salon et le partage par **QR code, code court ou lien**. Les autres rejoignent :

- **sur le même Wi‑Fi**, sans serveur : l’app trouve le salon toute seule ;
- **à distance**, par Internet, avec le lien ou le code.

L’hôte accepte ou refuse chaque demande, ferme le salon, puis lance la partie avec les joueurs acceptés.

**Soirées.** Date, lieu, nombre de places et jeux prévus. Chaque invité répond *oui*, *peut-être* ou *non*. Les places partent dans l’ordre des réponses, puis on passe en liste d’attente. L’invitation se partage par lien, code ou QR. Sans serveur, l’hôte peut aussi noter lui-même les réponses de ses amis.

**Partage hors ligne.** Une session complète (packs, dés, fiches, joueurs) passe d’un téléphone à l’autre en **QR code animé**. Le codage fontaine permet de commencer le scan en cours de route et de rater des images.

<p align="center">
  <img src="design/screenshots/evenings-desktop.png" width="820" alt="Écran des soirées sur ordinateur">
</p>

## 🚀 Démarrer

**Jouer tout de suite** : [ouvrir l’application web](https://techmefr.github.io/amiludo/app/). Ouvrez-la une première fois avec une connexion pour qu’elle se mette en cache, après quoi elle fonctionne hors ligne. Sur iPhone et iPad, utilisez la version web. Sur Android, un [APK de test](https://github.com/techmefr/amiludo/releases) est disponible.

**Développer** : Flutter **3.47.9** et Dart **3.13.7**. Les dépendances sont verrouillées dans `app/pubspec.lock`.

```sh
cd app
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

**Compiler le web** : depuis la racine, lancez `bash scripts/build_web.sh`. Le chemin public se règle avec `APP_BASE_PATH`.

**Fonctions en ligne (facultatives)** : les salons à distance, les comptes et les soirées en ligne utilisent [Supabase](https://supabase.com). Il suffit de fournir le projet au build :

```sh
SUPABASE_URL=https://xxxx.supabase.co \
SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxx \
AMILUDO_LINK_BASE=https://votre-site/app/# \
bash scripts/build_web.sh
```

Le schéma de la base se trouve dans [`server/supabase/migrations`](server/supabase/migrations). Sans ces variables, l’app reste entièrement locale. Le salon Wi‑Fi marche dans tous les cas, sauf dans un navigateur.

**Intégration continue** : à chaque push sur `main`, GitHub Actions analyse le code, lance les tests, publie la version web sur GitHub Pages et construit un APK Android de test. Les variables du projet Supabase sont lues depuis les *variables* du dépôt.

## 🏗️ Architecture

Le code suit l’architecture **OSDD** en couches indépendantes :

```
app/lib/
├── layers/
│   ├── functional/   Account · Appearance · Evenings · Friends · Game · History · Library
│   │                 Lobby · Memories · Random · Sharing · Templates · Timer · Workspace
│   │     └── <Feature>/domain (entities, gateways, use_cases) → data → presentation (cubit, écrans)
│   └── technical/    About · Appearance · Feedback · Files · Network · Qr · Storage · Theme · Transfer
├── dependencies.dart  injection (get_it)
├── router.dart        navigation (go_router)
└── main.dart
```

- L’état passe par `flutter_bloc` (Cubit), puis par les cas d’usage, puis par des gateways sous contrat.
- Une feature ne voit que le `domain` d’une autre, et `technical/` n’importe jamais `functional/`.
- Les données sont stockées avec Drift et SQLite, en natif sur mobile et en Wasm sur le web.
- Le réseau passe par WebSocket et une découverte UDP sur le Wi‑Fi local, ou par Supabase Realtime à distance.

Le détail est dans [docs/TECHNOLOGY.md](docs/TECHNOLOGY.md).

## 📍 Où en est le projet

**Alpha publique 0.4.0.** Le catalogue compte **170 fonctions : 113 sont livrées, 57 sont prévues ou incomplètes**. Les tests sur vrais téléphones restent à faire : découverte Wi‑Fi, caméra, veille, lecteurs d’écran. La traduction anglaise est partielle. Le point complet est dans [docs/APP-STATUS.md](docs/APP-STATUS.md), et la suite dans [la feuille de route](docs/ROADMAP.md).

## 🤝 Contribuer

Les retours de joueurs sont aussi précieux que le code. Le [guide de test](TESTING.md) explique quoi essayer, et le [guide de contribution](CONTRIBUTING.md) comment proposer un pack ou une correction. Les [issues](https://github.com/techmefr/amiludo/issues) sont ouvertes en français comme en anglais. Une faille ? Voir [SECURITY.md](SECURITY.md).

## 📄 Documents

- [Catalogue fonctionnel et statut](docs/FEATURES.md)
- [État réel de l’application](docs/APP-STATUS.md)
- [Feuille de route](docs/ROADMAP.md)
- [Choix techniques](docs/TECHNOLOGY.md)
- [Packs et builders](docs/PACKS.md)
- [Catalogue cible élargi](docs/VISION-COMPLETE.md)
- [Présentation pour les joueurs (PDF)](docs/presentation/Amiludo-presentation-joueurs.pdf)
- [Guide de l’application Flutter](app/README.md)

## Licence

Le code et les concepts originaux sont sous [licence MIT](LICENSE). Les polices embarquées gardent leurs licences OFL, et leurs mentions sont aussi visibles dans l’écran « À propos ». Le logo s’appelle « La boîte » ([design/logo](design/logo)).
