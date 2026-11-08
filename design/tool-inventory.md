# Inventaire des outils amiLudo (surensemble du marché)

Méthode : union des fonctions relevées chez les concurrents (design/competitor-audit.md ; fiches App Store trouvées par recherche web le 08/11/2026 : Scory, Board Game Now, Board Game Kit, RoundsKeeper, Gamer Uncle, ScoreMaster, TableTop Tool, Time for Settlers) et d'apps connues de mémoire, non revérifiées, marquées * (Life Counter, Lifetap, Dice by PCalc, D&D Beyond, Mythic GME, Kanka, BGG, Board Game Stats, Shelfie, Roll20, Tabletop Audio, Spyfall). Descriptions paraphrasées.

**État du code** (rapproché de origin/main, 08/11/2026) : le registre  déclare neuf catégories (Temps, Dés & hasard, Scores & compteurs, Cartes & pioche, Carte & plateau, Récit, Générateurs, Personnages, Joueurs & tours) ; les outils sont dans , les thèmes dans , la route est . Ajouter un outil = une ligne de catalogue, une de registre, un thème, des textes l10n.

## 1. Existant : 32 outils enregistrés + fonctions voisines

| Catégorie | Outils enregistrés |
|---|---|
| Temps | chronomètre, minuteur, horloge d'échecs, sablier |
| Dés & hasard | plateau de dés, dés, roue, pile ou face, nombre aléatoire |
| Scores & compteurs | feuille de scores, compteurs vie / points / jetons / cagnotte |
| Cartes & pioche | sac de jetons (sans remise) |
| Carte & plateau | carte (marqueurs) |
| Récit | taverne, ville, lieu, météo |
| Générateurs | PNJ, rencontre, quête, trésor, méchant, objet magique, dilemme, rumeur, trait, rebondissement |
| Personnages | créer un personnage, héros et pouvoirs |
| Joueurs & tours | qui commence (doigts), équipes, ordre de passage, rôles secrets |

Fonctions voisines hors registre d'outils : étagère de jeux et « ce soir » (Library), soirées et RSVP (Evenings), historique (History), souvenirs (Memories), salon multi-appareils (Lobby, Sharing), amis (Friends), paquets et marché (Templates), scan de code-barres d'une boîte (Library).

Écarts avec la liste P1 : la vie existe en compteur simple (pas d'écran plein cadre, ni poison ni commandant) ; le minuteur et le face-à-face de Timer/ restent des modules de partie ; l'horloge d'échecs (#2) et le chronomètre sont livrés.

## 2. Manquants P1 (courants : au moins un concurrent majeur l'a)

Effort : S < 1 j, M 2-4 j, L > 1 sem. Look : directions du competitor-audit.

| # | Outil | Catégorie | Qui l'a déjà | Effort | Look signature |
|---|---|---|---|---|---|
| 1 | Compteur de vie plein écran 2-6 joueurs (tap, appui long +5, poison, commandant) | Scores | Life Counter*, Lifetap*, Scoreboard | M | Pierre gravée, chiffres qui roulent, halo braise |
| 2 | Horloge d'échecs, banque de temps par joueur (livrée : 2 joueurs, incrément) | Temps | ScoreMaster, TableTop Tool | S | Deux dalles de pierre, bascule au tap |
| 3 | Minuteur de tour qui passe de joueur en joueur, alerte sonore | Temps | Time for Settlers, Scory | S | Anneau couleur joueur qui se vide |
| 4 | Dés 3D (d4 à d100, avantage/désavantage, historique) | Dés | PCalc*, Dice Ninja*, RoundsKeeper | L | Résine et feutre, rebond sur tapis |
| 5 | Préréglages de dés sauvegardés | Dés | RoundsKeeper | S | Fiches de jet en tiroir |
| 6 | Buzzer « premier à presser » multi-joueurs | Joueurs | Board Game Now | S | Gros boutons cloche, éclair du gagnant |
| 7 | Premier joueur : tirage animé + marqueur | Joueurs | Gamer Uncle, Scory | S | Jeton qui roule vers l'élu |
| 8 | Suivi de tour, manche, phase | Joueurs | Time for Settlers, Lifetap* | M | Frise de phases avec jeton |
| 9 | Pioche : paquet 52 ou perso, mélange, défausse | Cartes | Tabletop Simulator*, apps de cartes | M | Cartes dorées, flip 3D |
| 10 | Compteurs libres par joueur (ressources, PV, jetons) | Scores | TableTop Tool, Tabletop Tally | S | Pastilles gravées, roulement mécanique |
| 11 | Gagnant, classement final, égalités | Scores | Scory, BGG* | S | Podium de pierre, tampon rouge |
| 12 | Barèmes prédéfinis par jeu (Yams, Skyjo, Catan) | Scores | Scory, Board Game Stats*, Shelfie* | M | Feuille de score papier, encre |
| 13 | Statistiques par joueur et par jeu | Bibliothèque | Board Game Stats*, BGG*, Shelfie* | M | Carnet de bord, graphes à l'encre |
| 14 | Import BGG (collection, durée, nb joueurs) | Bibliothèque | BGG*, Shelfie*, Gamer Uncle | L | Étagère, tranches de boîtes |
| 15 | Aide-mémoire de règles (résumé, FAQ, recherche) | Règles | Gamer Uncle (chat de règles) | M | Parchemin, onglets cornés |
| 16 | Vote secret, résultat révélé | Votes | apps loup-garou* | M | Urne, bulletins qui tombent |
| 17 | Imposteur / mot secret | Votes | Spyfall* | M | Cartes à dos gravé |
| 18 | Journal de partie | Récit | Obsidian*, Notion*, Kanka* | M | Carnet de bord papier chaud |

## 3. Manquants P2 (utiles, un concurrent ou niche)

| # | Outil | Catégorie | Qui l'a déjà | Effort | Look |
|---|---|---|---|---|---|
| 19 | Initiative et PV de monstres | JDR | D&D Beyond*, Roll20* | M | Colonne de jetons ronds |
| 20 | Statuts avec durée | Personnages | D&D Beyond*, Roll20* | M | Pastilles-sceaux |
| 21 | Fiche PJ avec jets liés aux dés | Personnages | D&D Beyond*, Pathbuilder* | L | Passeport d'aventurier |
| 22 | Avatar 2D en calques, export pion | Personnages | Hero Forge* (3D) | L | Autocollants encastrés |
| 23 | PNJ aléatoire | Générateurs | Donjon*, Perchance* | S | Carte tirée, glow doux |
| 24 | Noms (fantasy, taverne, ville) | Générateurs | Donjon*, Perchance* | S | Runes qui se stabilisent |
| 25 | Butin et trésor | Générateurs | Donjon* | S | Coffre qui s'ouvre |
| 26 | Rencontre / événement aléatoire | Générateurs | Mythic GME* | M | Cartes de rencontre |
| 27 | Oracle oui/non avec chaos | Récit | Mythic GME* | M | Cartes, cloche selon rareté |
| 28 | Tables personnalisées avec poids | Générateurs | Perchance*, Mythic* | M | Poids en bandes visibles |
| 29 | Graine partageable | Générateurs | aucun trouvé | S | Sceau de cire avec code |
| 30 | Cartes de référence dépliables | Règles | apps d'aide-mémoire* | M | Fiche cartonnée |
| 31 | Carte annotable, pins typés | Carte & plateau | Inkarnate*, Google My Maps* | L | Carte au trésor |
| 32 | Brouillard de guerre manuel | Carte & plateau | Roll20*, Owlbear* | M | Brume balayée au doigt |
| 33 | Photo de plateau recalée + notes | Carte & plateau | aucun trouvé | L | Plateau annoté au crayon |
| 34 | Grille hex/carrée, jetons déplaçables | Carte & plateau | Roll20*, Owlbear* | L | Plateau de bois, pions |
| 35 | Scores sport de table (Mölkky, fléchettes, pétanque) | Scores | apps de sport* | M | Ardoise, cible gravée |
| 36 | Banque (Monopoly) : soldes, transferts | Argent | apps banquier* | M | Billets de papier, tampon |
| 37 | Enchères, mise montante, chrono | Argent | apps d'enchères* | M | Marteau de commissaire |
| 38 | Tournoi : suisse, élimination, poules | Équipes | Challonge* | L | Bracket parchemin |
| 39 | Ligue / saison entre amis | Équipes | Board Game Stats* | M | Tableau de bois, médailles |
| 40 | Équilibrage des équipes selon niveau | Équipes | apps d'équipes* | S | Balance en laiton |
| 41 | Sons d'ambiance (taverne, orage) | Ambiance | Tabletop Audio* | M | Console de mixage bois |
| 42 | Musique de fond liée au minuteur | Ambiance | Tabletop Audio* | S | Platine vinyle |
| 43 | Marqueurs de statut (monarque, premier joueur) | Joueurs | Lifetap* | S | Gros jeton posé |
| 44 | Quiz de soirée | Soirées | apps de soirée* | M | Cartes de salon |
| 45 | Défis et gages | Soirées | apps de soirée* | S | Cartes à bord doré |
| 46 | Qui apporte quoi (snacks) | Soirées | Partiful*, Doodle* | S | Ardoise à craie |
| 47 | Sondage de date et de jeu | Soirées | Doodle*, Gamer Uncle | M | Bulletins, urne |
| 48 | Recommandation de jeu (joueurs, durée, humeur) | Bibliothèque | Gamer Uncle, BGG* | M | Boîtes tirées |

## 4. Manquants P3 (long tail)

| # | Outil | Catégorie | Qui l'a déjà | Effort | Look |
|---|---|---|---|---|---|
| 49 | Probabilités de dés | Dés | Anydice*, Dice Ninja* | M | Courbe à l'encre |
| 50 | Dés spéciaux (Fate, narratifs) | Dés | Roll20* | M | Faces gravées |
| 51 | Dés maison (faces custom) | Dés | PCalc* | M | Atelier de dés |
| 52 | Horloges de progression | Scores | apps Blades* | S | Disques en quartiers |
| 53 | Ressources de campagne (or, rations) | Récit | Kanka* | M | Registre de comptes |
| 54 | Wiki de campagne lié | Récit | Kanka*, World Anvil* | L | Fils rouges |
| 55 | Chronologie, calendrier fantasy | Récit | World Anvil* | M | Frise parchemin |
| 56 | Cartes d'inspiration (dés d'histoire) | Récit | Story Cubes*, Mythic* | S | Tarot doré |
| 57 | Générateur de donjon | Générateurs | Donjon*, Azgaar* | L | Plan à l'encre |
| 58 | Cartes de personnage imprimables | Personnages | Hero Forge* | M | Carte à collectionner |
| 59 | Wargame : mesure et gabarits | Carte & plateau | apps wargame* | L | Règle de laiton |
| 60 | Wargame : listes d'armée, points | Personnages | Battlescribe* | L | Registre de régiment |
| 61 | Wargame : activation d'unités | Joueurs | apps wargame* | M | Dés d'ordre |
| 62 | Scan QR de carte physique | Cartes | aucun trouvé | M | Réticule |
| 63 | Scan code-barres de boîte | Bibliothèque | Shelfie*, BGG* | M | Tranche de boîte |
| 64 | Prêt de jeux entre amis | Bibliothèque | BGG*, Shelfie* | S | Fiche de prêt tamponnée |
| 65 | Wishlist et prix | Bibliothèque | BGG*, Shelfie* | M | Étiquette de prix |
| 66 | Résumé de soirée partageable (image) | Soirées | Board Game Stats* | S | Affiche de soirée |
| 67 | Mode solo (automates, tables) | Joueurs | apps solo* | L | Livret de règles solo |
| 68 | Narrateur vocal | Ambiance | apps audio* | M | Voix de conteur |
| 69 | Accessibilité : gros chiffres, daltonisme | Transverse | rare | M | Contraste renforcé |

Total manquants : 69 (P1 : 18, P2 : 30, P3 : 21).

## 5. Différenciateurs que personne n'a (aucun concurrent trouvé)

1. Tirage qui devient une carte conservée dans le carnet (générateurs reliés au journal).
2. Matière de dé mémorisée par joueur (ambre, os, obsidienne).
3. Graine partageable pour rejouer un tirage identique à distance.
4. Photo de plateau recalée avec brouillard de guerre pendant la partie.
5. Sablier retourné par geste (accéléromètre), sable qui change de teinte au dernier tiers.
6. Avatar 2D en calques exportable en pion, relié aux boosters de personnage.
7. Paquets et marché de paquets (déjà dans le code) reliés aux générateurs.
8. Soirée complète sans compte obligatoire : RSVP, jeu, scores, souvenirs, stats.
9. Historique annulable en runes sur les compteurs, rejouable en fin de partie.
10. Choix du jeu du soir par sondage, joueurs présents et durée, branché sur l'étagère.

## 6. Plan de PR par lots

| Lot | Contenu | Effort |
|---|---|---|
| A | Compteur de vie (#1), compteurs libres (#10), classement (#11) | M+S+S |
| B | Horloge d'échecs (#2), minuteur de tour (#3), suivi de phase (#8), premier joueur animé (#7) | S+S+M+S |
| C | Dés 3D (#4), préréglages (#5), buzzer (#6) | L+S+S |
| D | Pioche (#9), vote secret (#16), imposteur (#17) | M+M+M |
| E | Barèmes (#12), statistiques (#13), import BGG (#14) | M+M+L |
| F | Aide-mémoire (#15), cartes de référence (#30), journal de partie (#18) | M+M+M |
| G | PNJ (#23), noms (#24), butin (#25), tables à poids (#28) | S+S+S+M |
| H | Oracle (#27), rencontre (#26), graine partageable (#29) | M+M+S |
| I | JDR : initiative (#19), statuts (#20), fiche (#21), avatar (#22) | M+M+L+L |
| J | Carte : pins (#31), brouillard (#32), photo (#33), grille (#34) | L+M+L+L |
| K | Banque (#36), enchères (#37), scores sport (#35) | M+M+M |
| L | Tournoi (#38), ligue (#39), équilibrage (#40) | L+M+S |
| M | Sons (#41), musique (#42), quiz (#44), gages (#45) | M+S+M+S |
| N | Sondage (#47), snacks (#46), recommandation (#48), prêt (#64) | M+S+M+S |
| O+ | P3 par thème : wargame, wiki, dés spéciaux, scans | L |

Prérequis : réécrire `tool_catalog.dart` en neuf catégories (filtres de `tools_screen.dart` figés sur Hasard/Partie/Temps) ; sons et haptique via la couche technique Feedback ; i18n pour tous les libellés ; un fichier par outil sous 200 lignes.

Sources : https://apps.apple.com/app/id6538715670 (Scory) ; https://apps.apple.com/app/id6759579818 (Board Game Now) ; https://apps.apple.com/us/app/id6754217431 (RoundsKeeper) ; https://apps.apple.com/sa/app/tabletop-tool/id1636512114 ; https://www.producthunt.com/products/gamer-uncle
