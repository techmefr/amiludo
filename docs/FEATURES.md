# Catalogue fonctionnel d’amiLudo

Statut : **[x] = implémenté dans l’alpha Flutter**, avec validation des parcours et limites décrites dans APP-STATUS.md ; **[ ] = prévu ou incomplet**. Les tests sur appareils physiques restent distincts. MVP = première version ; V1 = enrichissement individuel ; V2 = services partagés et extensions. Les priorités au sein des blocs restent ajustables.

Le produit combine un accès immédiat aux outils et un mode partie qui partage joueurs, temps et scores.

## Accès et expérience — MVP

- [x] F001 — Outils rapides sans créer de partie
- [x] F002 — Mode partie combinant les outils utiles
- [x] F003 — Accueil personnalisable et favoris
- [x] F004 — Reprise automatique de la dernière partie
- [x] F005 — Fonctionnement hors connexion du cœur
- [x] F006 — Aucun compte obligatoire
- [x] F007 — Aucune publicité
- [ ] F008 — Français et anglais
- [x] F009 — Mode clair et sombre
- [ ] F010 — Téléphone et tablette, portrait et paysage
- [x] F011 — Grandes commandes utilisables autour de la table
- [x] F012 — Couleurs accompagnées de noms ou symboles
- [ ] F013 — Taille du texte et lecteurs d’écran
- [x] F014 — Animations, sons et vibrations désactivables
- [x] F015 — Maintien de l’écran allumé pendant une partie

## Joueurs et préparation — MVP

- [ ] F016 — Profils locaux avec pseudo, couleur et avatar
- [x] F017 — Joueurs invités sans profil permanent
- [ ] F018 — Groupes de joueurs réutilisables
- [ ] F019 — Équipes manuelles ou aléatoires
- [ ] F020 — Nombre et taille des équipes paramétrables
- [x] F021 — Tirage du premier joueur par liste
- [x] F022 — Sélection par doigts avec compte à rebours
- [x] F023 — Ordre de passage aléatoire ou manuel
- [x] F024 — Relancer une partie avec les mêmes joueurs
- [ ] F025 — Configuration rapide du jeu, des manches et outils

## Hasard et dés — MVP

- [x] F026 — Dés d4, d6, d8, d10, d12, d20 et d100
- [x] F027 — Plusieurs dés et total automatique
- [x] F028 — Verrouiller certains dés et relancer les autres
- [x] F029 — Historique des résultats de la session
- [x] F030 — Pile ou face
- [x] F031 — Tirage d’un nom, nombre ou élément de liste
- [x] F032 — Tirage avec ou sans remise
- [x] F033 — Roue à options personnalisées
- [ ] F034 — Enregistrer des jeux de dés et listes
- [x] F035 — Aléatoire fourni par une source sécurisée du système

## Scores et ressources — MVP

- [x] F036 — Scores par joueur ou équipe
- [x] F037 — Ajout et retrait rapides, valeur libre
- [x] F038 — Scores négatifs et décimaux configurables
- [x] F039 — Scores par manche et total cumulé
- [x] F040 — Classement au plus haut ou au plus bas score
- [x] F041 — Gestion des égalités et ex æquo
- [x] F042 — Objectif de points ou nombre de manches
- [x] F043 — Annuler et rétablir une modification
- [x] F044 — Journal des modifications de score
- [x] F045 — Compteurs de vies, monnaie et ressources indépendants
- [x] F046 — Bonus et malus identifiés
- [x] F047 — Résumé final et revanche

## Temps et tours — MVP

- [ ] F048 — Chronomètre de partie
- [x] F049 — Compte à rebours commun
- [x] F050 — Temps fixe par tour
- [x] F051 — Réserve de temps par joueur, de 2 à plusieurs joueurs
- [x] F052 — Pause et reprise globales
- [x] F053 — Joueur actif et bouton de passage de tour
- [ ] F054 — Avertissement de temps faible configurable
- [x] F055 — Son et vibration à expiration
- [ ] F056 — Temps différent par joueur
- [ ] F057 — Incrément Fischer et délai simple
- [ ] F058 — Compteur de tours et de manches
- [ ] F059 — Sens de rotation et premier joueur tournant

## Fiabilité et données — MVP

- [x] F060 — Sauvegarde locale après chaque action significative
- [x] F061 — Récupération après fermeture de l’application
- [x] F062 — Historique local des parties terminées
- [x] F063 — Export et import JSON des parties
- [x] F064 — Export CSV des scores
- [x] F065 — Suppression individuelle et effacement complet
- [x] F066 — Confirmation avant remise à zéro destructive
- [ ] F067 — Migration versionnée des données locales

## Personnalisation avancée — V1

- [x] F068 — Dés à symboles et faces personnalisées
- [ ] F069 — Expressions de dés, modificateurs et succès
- [ ] F070 — Avantage, désavantage et relances conditionnelles
- [ ] F071 — Sacs de jetons avec contenu et remise configurables
- [ ] F072 — Paquets de cartes virtuels personnalisés
- [ ] F073 — Tirages pondérés avec probabilités visibles
- [ ] F074 — Sélection de plusieurs gagnants et classement aléatoire
- [ ] F075 — Contraintes de composition des équipes
- [x] F076 — Rôles secrets avec révélation individuelle
- [ ] F077 — Minuteurs simultanés et temps par équipe
- [ ] F078 — Cadences Bronstein, sablier et byo-yomi
- [ ] F079 — Cadences à plusieurs phases
- [x] F080 — Décompte de score par catégories
- [x] F081 — Formules de score déclaratives sans code exécuté
- [x] F082 — Objectifs coopératifs et résultats victoire/défaite
- [x] F083 — Notes, objectifs et compteurs propres à la partie

## Modèles et communauté — V1

- [x] F084 — Préréglages complets par jeu
- [x] F085 — Éditeur de feuille de score
- [x] F086 — Éditeur de configuration de partie
- [x] F087 — Import et export de modèles JSON versionnés
- [x] F088 — Bibliothèque embarquée utilisable hors ligne
- [x] F089 — Catalogue communautaire avec recherche et filtres
- [x] F090 — Contributions de modèles par pull request
- [x] F091 — Validation automatique des modèles
- [x] F092 — Métadonnées auteur, version, langue et licence
- [ ] F093 — Favoris et variantes personnelles
- [x] F094 — Instructions courtes originales et liens vers les règles officielles
- [ ] F095 — Gestion des versions et compatibilité des modèles

## Historique et soirées — V1

- [x] F096 — Recherche de parties par jeu, joueur et date
- [ ] F097 — Statistiques de victoires, scores et durées
- [ ] F098 — Évolution des scores et comparaison des manches
- [ ] F099 — Séries de parties et classement de soirée
- [x] F100 — Résultats par équipe et coopération
- [ ] F101 — Partage du résumé sous forme d’image
- [x] F102 — Sauvegarde et restauration d’une bibliothèque complète
- [ ] F103 — Accessibilité du mode table et affichage orienté par joueur

## Parties partagées — V2

- [ ] F104 — Rejoindre une salle par QR code ou code court
- [ ] F105 — Pseudonyme invité sans compte personnel
- [ ] F106 — Saisie des scores depuis plusieurs appareils
- [ ] F107 — Écran commun de scores et temps
- [ ] F108 — Hôte et droits de modification explicites
- [ ] F109 — Journal partagé et gestion des actions concurrentes
- [ ] F110 — Reconnexion et rattrapage des événements
- [ ] F111 — Transfert du rôle d’hôte
- [ ] F112 — Rôles et informations privés par joueur
- [ ] F113 — Synchronisation facultative de la bibliothèque personnelle
- [ ] F114 — Serveur auto-hébergeable et documentation de déploiement
- [ ] F115 — Export et suppression des données distantes

## Tournois et extensions — V2

- [ ] F116 — Tournois toutes rondes et élimination directe
- [ ] F117 — Appariements suisses avec règles explicites
- [ ] F118 — Rotation des tables et équipes
- [ ] F119 — Classement avec départages configurables
- [ ] F120 — Mode kiosque ou grand écran
- [ ] F121 — Raccourcis système et widgets selon plateforme
- [ ] F122 — Import de collection via services externes si autorisé
- [ ] F123 — API de modèles stable et outils de contribution

## Contraintes de conception

- Le nombre de doigts simultanés dépend de l’écran, du navigateur et des gestes système : proposer systématiquement le tirage par liste.
- Une minuterie doit utiliser des horodatages et une horloge monotone pendant son exécution ; les rappels en arrière-plan ont des limites selon plateforme. Tester verrouillage, veille et reprise.
- Sur le web, le fonctionnement hors connexion nécessite un cache applicatif explicite. Le stockage du navigateur peut être effacé : proposer une sauvegarde exportable.
- Le tirage aléatoire ne sert pas à des jeux d’argent. L’animation présente le résultat sans modifier les probabilités.
- Les modèles n’embarquent pas d’illustrations ou de règles tierces sans autorisation. Les formules sont des données validées, jamais du code arbitraire.
- Les scores et les temps restent lisibles sans dépendre uniquement de la couleur.

## Personnalisation et profils de style — MVP

- [x] F124 — Mode clair, sombre et automatique selon le système
- [x] F125 — Onze palettes coordonnées pour les fonds, textes et accents
- [x] F126 — Choix de sept familles typographiques lisibles
- [x] F127 — Aperçu du thème en temps réel
- [x] F128 — Application du style sur tous les écrans
- [x] F129 — Quatre styles de formes : biseauté, net, doux et très arrondi
- [x] F130 — Densité confortable ou compacte
- [x] F131 — Texte de lecture agrandi
- [x] F132 — Réduction des animations respectant aussi le système
- [x] F133 — Enregistrement de plusieurs profils de style sur un appareil
- [x] F134 — Changement de profil en un geste
- [x] F135 — Nom personnalisé pour chaque profil
- [x] F136 — Suppression individuelle des profils
- [x] F137 — Export du thème au format JSON
- [x] F138 — Import de thème avec validation du format
- [x] F139 — Réinitialisation du style par défaut
- [x] F140 — Conservation du style après fermeture et rechargement

- [x] F141 — Quatre univers visuels : Playroom, Cyberdeck, Orbital 77 et Carnet

## Personnages et cartes — V1

- [x] F142 — Builder de catégories et cartes de création de personnage
- [x] F143 — Génération par listes ou boosters avec minimum et maximum à conserver
- [x] F144 — Fiches issues des choix, sauvegarde, import et export JSON
- [ ] F145 — Fiches libres avec caractéristiques, compétences, inventaire et progression
- [ ] F146 — Builder de paquets de cartes génériques : recto/verso, pioche, main et défausse
- [ ] F147 — Plateaux, pistes et jetons personnalisables
- [ ] F148 — Campagnes, scénarios et progression entre les séances

## Ludothèque, amis et souvenirs — V1

Tout reste sur l’appareil, sans compte ni serveur. Les échanges passent par QR code ou par fichier chiffré.

- [x] F149 — Ludothèque en étagères : chaque jeu possédé est une boîte avec genres, joueurs, durée et packs liés
- [x] F150 — Fiche d’un jeu de la ludothèque : packs, parties jouées, note moyenne, jouer et partager
- [x] F151 — Profils d’amis : prénom, couleur, genres aimés ou évités, durée maximale et jeux refusés
- [x] F152 — Avis et notes de 1 à 5 étoiles par joueur à la fin d’une partie
- [x] F153 — « On joue à quoi ce soir ? » : suggestions de la ludothèque selon les amis présents
- [x] F154 — Souvenirs de partie : note, moments forts et photos
- [x] F155 — Galerie privée exportée en fichier chiffré, clé transmise par QR code à la table
- [x] F156 — Fusion des galeries reçues sans doublons
- [x] F157 — Session partagée (packs, dés, fiches de personnage, joueurs, jeu) en QR code animé à 10 images par seconde
- [x] F158 — Réception par scan avec codage fontaine : on peut commencer en cours de route et rater des images
- [x] F159 — Ressources de départ et statuts définis par le pack, appliqués à chaque joueur
- [x] F160 — Réglage rapide des ressources et des statuts cumulables pendant la partie
- [x] F161 — Avis par jeu sur chaque ami (envie, adore malgré le genre, refusé) et temps disponible pour les suggestions

## Rejoindre, comptes et soirées — V1

Le salon Wi-Fi marche sans serveur. Le jeu à distance, les comptes et les inscriptions en ligne demandent un projet Supabase fourni au build (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`) ; sans lui, l’app reste en mode local.

- [x] F162 — Salon de partie ouvert par l’hôte : code court, QR code et lien partageable
- [x] F163 — Rejoindre par code, lien ou scan, sur le même Wi-Fi (découverte automatique) ou à distance
- [x] F164 — L’hôte accepte ou refuse chaque demande, ferme le salon et lance la partie avec les joueurs acceptés
- [x] F165 — Prénom local et compte en ligne facultatif : inscription, connexion, mot de passe oublié
- [x] F166 — Soirées : date, lieu, places, jeux prévus
- [x] F167 — Inscriptions oui / peut-être / non, premier arrivé premier servi, liste d’attente
- [x] F168 — Invitation à une soirée par lien, code ou QR ; réponses enregistrées sur le serveur
- [x] F169 — Sans serveur, l’hôte note lui-même les réponses de ses amis
- [x] F170 — Équipes à partir des noms saisis, des joueurs du salon ou des doigts posés sur l’écran

**Total : 170 fonctionnalités planifiées.**

La personnalisation est portée dans Flutter. Les cases cochées décrivent une alpha locale ; elles ne valent pas une certification Android/iOS ou une validation complète d’accessibilité.

**Bilan alpha : 113 fonctions cochées ; 57 prévues ou incomplètes.**
