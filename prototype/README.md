# Maquettes interactives

Nom volontairement provisoire : « compagnon ». Prototype web autonome, destiné à valider l’expérience avant son portage Flutter. Il ne remplace pas l’application de production.

## Essayer

Ouvrir https://techmefr.github.io/ludoply/ ou lancer `python3 -m http.server 4173 --directory prototype` à la racine du dépôt, puis ouvrir http://localhost:4173.

## Écrans

Accueil, partie en cours, outils, bibliothèque de modèles, historique, apparence. Les modèles spécifiques sont explicitement des aperçus. Le catalogue de 140 fonctions est accessible depuis les outils et peut être filtré. Sur mobile, bibliothèque et historique restent accessibles par les liens de l’accueil ; les accès fréquents figurent dans la barre du bas.

## Votre style

Palettes : Lichen, Lavande, Terre cuite, Marée, Miel, Rosée. Polices : DM Sans, Manrope, Nunito Sans, Space Grotesk. Modes clair, sombre et système ; formes nettes, douces ou rondes ; densité et lecture agrandie ; animations désactivables. Les profils sont locaux à chaque navigateur : pas de compte ou de synchronisation. Export JSON versionné et import validé.

Les polices sont chargées depuis Google Fonts et nécessitent une connexion au premier chargement ; une police système prend le relais. Prévoir l’auto-hébergement des polices dans l’application. Le prototype n’inclut pas de service worker et ne promet pas un chargement hors connexion.

## Interactions

Scores de 2 à 8 joueurs, annulation, manches, passage de tour, minuteur de premier plan, lancer de dés, pile ou face, sélection de joueur, équipes, ordre et roue. Les valeurs initiales et deux entrées d’historique sont des exemples signalés. Le tirage multi-touch dépend de l’appareil. La roue montre un résultat textuel : ses secteurs décoratifs ne représentent pas les options.

Le minuteur n’est pas une alarme système ; il s’arrête au départ de la page et n’est pas restauré après fermeture. L’historique et les scores sont locaux ; un effacement des données du navigateur les supprime. L’annulation des scores concerne la session courante.

## Vérifications

Navigation des six écrans, conservation des thèmes après rechargement, profil enregistré, ajout/annulation de points, passage de tour, minuteur, dés, équipes et recherche du catalogue testés dans Chromium. Affichage vérifié à 1440 px et 390 px, sans débordement horizontal sur les quatre écrans principaux mobiles. Captures dans design/mockups. Les appareils iOS/Android physiques et les lecteurs d’écran restent à vérifier.
