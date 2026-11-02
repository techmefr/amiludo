# Packs, builders et galerie

L’alpha 0.2.0 permet de construire un pack par jeu depuis Modèles → Créer un compagnon. Tous les outils s’ouvrent sur une page avec retour ; la sélection au doigt possède une surface tactile qui occupe l’espace disponible. Les confirmations courtes restent des dialogues.

## Contenu d’un pack

- Dés : plusieurs types, nombre d’exemplaires, libellé et valeur de chaque face. Les faces répétées modifient les probabilités ; les lancers permettent de conserver des dés.
- Rôles : nom, effectif et consigne privée. La distribution exige une carte par participant ; les cartes sont révélées une par une, puis masquées. Quitter l’application masque la carte révélée.
- Scores : catégories, multiplication, lots complets, progression triangulaire, seuils et barèmes personnalisés. Les quantités calculées remplacent le total d’une catégorie dans la manche ; elles ne le doublent pas. Le journal reste annulable.
- Personnages : catégories libres (races, métiers, histoires, pouvoirs…), cartes et descriptions, taille du booster, minimum et maximum de cartes à garder. Exemple : proposer quatre races et en garder une ou deux. Le mode liste propose toutes les cartes ; le mode booster tire sans doublon. Les choix forment une fiche locale, exportable et importable.
- Règles : lien HTTPS, édition et notes personnelles incluses dans le pack. Le livret distant reste un lien ; l’application ne le récupère ni ne l’analyse automatiquement.
- Auteur, langue, licence et version du pack.

Une partie conserve une copie de son pack. Modifier un pack de la bibliothèque ne recalcule pas les parties existantes. Les fiches de personnages restent conservées après suppression du pack d’origine ; elles sont incluses dans la sauvegarde globale.

## Galerie communautaire

Le catalogue initial contient trois exemples originaux clairement identifiés. On peut rechercher, filtrer, installer et réinstaller un pack. L’installation copie les données dans la bibliothèque ; une réinstallation demande confirmation avant remplacement. Actualiser charge le catalogue public ; le catalogue embarqué reste consultable sans connexion. Les packs installés restent utilisables hors connexion.

Pour partager : exporter le pack puis proposer son fichier dans le dépôt public. Voir [community/README.md](../community/README.md). La publication suit une pull request et une relecture, sans envoi automatique depuis l’application. Il n’y a pas encore de comptes dédiés, notes, achats ou publication instantanée.

## Limites actuelles

Les calculs sont des opérations déclaratives limitées, pas un arbitre universel de toutes les règles d’un jeu. Les fiches générées contiennent les choix et descriptions ; les caractéristiques numériques, inventaires, combats et progressions libres restent à construire. Les cartes de booster ne constituent pas encore un moteur générique de pioche/main/défausse. Les mains privées sur plusieurs appareils nécessiteront les salles partagées.

Les essais de multitouch sur appareils physiques restent nécessaires. Les créations en cours et tirages d’outils ne sont pas restaurés ; enregistrer une fiche ou un pack pour le conserver.

Le mode libre ouvre les outils sans pack. Un compagnon par jeu rassemble les modules configurés dans un tableau de bord. Les icônes de l’interface utilisent Hugeicons Free, sous licence MIT ; elles sont incluses dans la compilation et ne demandent aucun chargement externe.

Le builder se parcourt par étapes : nom local et anglais, sélection des modes, réglage des seuls modes choisis, résumé. Les métadonnées de publication restent repliées. Les outils non sélectionnés ne sont pas imposés au compagnon du jeu.
