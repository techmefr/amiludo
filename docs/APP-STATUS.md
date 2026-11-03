# Application — état réel

Alpha **0.4.0**. Nom : amiLudo. Le code Flutter est dans `app/`, l’application web est publiée sous `/app/`, et les anciennes maquettes restent à la racine du site.

## Disponible

- **Partie** :
  - scores locaux, manches, catégories, objectifs ;
  - journal annulable, ressources et statuts, notes ;
  - horloges par table, outils de hasard, équipes par noms, joueurs du salon ou doigts.
- **Personnalisation** : thèmes et profils, builders de packs (dés, rôles, calculs déclaratifs, personnages par listes ou boosters) et galerie installable. Voir [PACKS.md](PACKS.md).
- **Ludothèque et amis** :
  - étagères de jeux, profils d’amis avec goûts, temps disponible et avis par jeu ;
  - suggestions « On joue à quoi ce soir ? » ;
  - souvenirs avec photos et galerie chiffrée.
- **Partage hors ligne** : session complète en QR code animé à codage fontaine.
- **Salons** :
  - code court, QR ou lien ;
  - même Wi‑Fi sans serveur, avec découverte UDP et WebSocket ;
  - ou à distance par Supabase Realtime ;
  - l’hôte accepte ou refuse chaque joueur.
- **Comptes facultatifs** : inscription, connexion, mot de passe oublié, prénom.
- **Soirées** : date, lieu, places, jeux prévus, réponses oui / peut-être / non, liste d’attente, invitation par lien, code ou QR. Sans serveur, l’hôte note les réponses.
- **Stockage** : SQLite, historique, CSV et sauvegardes JSON.

Le catalogue compte **170 fonctions : 113 cochées, 57 prévues ou incomplètes**. Les trois packs initiaux sont des exemples originaux du projet. La publication communautaire passe par la relecture des pull requests.

## Serveur

Projet Supabase facultatif, fourni au build par `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` et `AMILUDO_LINK_BASE` (variables du dépôt GitHub dans la CI).

Côté base, le schéma est dans `server/supabase/migrations` :
- table `evenings` protégée par RLS ;
- fonctions `publish_evening`, `get_evening` et `answer_evening`, réservées aux comptes connectés.

Sans ces variables, l’app reste entièrement locale. Le salon Wi‑Fi n’existe pas dans le navigateur.

## Vérifications

- **Tests** : 75 tests Flutter.
  - Partie, hasard et données : scores, imports, stockage, temps, tirages, profils, packs, ludothèque, amis, suggestions, souvenirs, partage QR.
  - Salons : protocole, puis vrais sockets en boucle locale.
  - Soirées, comptes et liens.
  - Un test d’architecture vérifie les dépendances entre couches.
- **CI** : le workflow analyse le code et lance les tests avant de compiler le web et l’APK Android.
- **Version en ligne contrôlée** : la page répond, le bundle pointe vers le bon projet Supabase, les réglages d’auth sont joignables, et un appel anonyme aux soirées est refusé.

Restent à faire :
- les essais sur vrais téléphones : découverte Wi‑Fi, caméra, multitouch, veille, sons, vibrations ;
- Safari et les lecteurs d’écran.

## Limites connues

**Salons** :
- le code du salon est le seul contrôle d’accès ;
- le canal à distance est public et le WebSocket local n’est pas chiffré.

Un secret d’hôte et des canaux privés sont prévus avant une ouverture large (voir la feuille de route).

**E-mails de compte** : ils partent par l’envoi intégré de Supabase, très limité en volume. Un SMTP dédié sera nécessaire pour un vrai usage.

**Données** :
- le document `Workspace` regroupe toutes les données de l’appareil et il est réécrit à chaque modification ;
- un découpage par fonctionnalité est prévu.

**Traduction** : l’anglais est partiel, et certains textes et messages d’erreur restent en français.

**Règles et calculs** :
- les règles distantes sont des liens, sans analyse des livrets ;
- les calculs disponibles ne vérifient pas toutes les règles d’un jeu ;
- une partie garde la copie de son pack.

**Plateformes** :
- iOS natif demande macOS, Xcode et une signature Apple, et n’est pas distribué. Le site est utilisable sur iPhone et iPad.
- Les APK sont des versions de test : exporter une sauvegarde avant toute mise à jour.
- Aucune alarme en arrière-plan n’est garantie.

Les identifiants de stockage, les formats de fichiers et les paquets natifs historiques sont conservés pour la continuité des données.
