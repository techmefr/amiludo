# Galerie communautaire

Chaque pack JSON peut regrouper dés, rôles, catégories de points, consignes et lien de règles. Les packs installés restent utilisables hors connexion. Les notes sont incluses ; les livrets distants restent chez leur éditeur.

## Publier un pack

1. Créer et tester le pack dans le builder de l’application.
2. Renseigner auteur, version, édition/variante et licence. Utiliser uniquement des textes et contenus que vous pouvez partager.
3. Exporter le JSON depuis « Outils et règles du pack ».
4. Ajouter le fichier dans `community/packs/` avec un nom unique et ouvrir une pull request. Le bouton de proposition ouvre ce dossier dans GitHub ; l’application ne publie rien automatiquement.
5. Décrire le jeu, les calculs vérifiés et les limites. Après relecture et fusion, le catalogue est reconstruit et publié ; les utilisateurs peuvent l’actualiser dans la galerie.

Les trois packs initiaux sont des exemples originaux du projet, pas des créations présentées comme ayant été déposées par d’autres utilisateurs. La galerie ne propose ni achats, ni comptes dédiés, ni évaluations pour le moment. Un compte GitHub est nécessaire pour proposer un ajout ; aucun compte n’est requis pour installer les packs publics.

## Format et vérification

Le format reste `table-companion-template`, version 1. Les anciens modèles sans dés, rôles ou calculs restent lisibles. Un pack possède une version propre (`revision`). Les parties conservent une copie de leur pack pour qu’une modification ultérieure n’en change pas les règles.

Les calculs déclaratifs acceptent : quantité × facteur, lots complets, progression triangulaire, seuil et barème pour quantités entières. Aucun code fourni par un pack n’est exécuté. Une feuille remplace le total d’une catégorie pour une manche, en conservant un journal annulable. Elle ne vérifie pas les coups ou toutes les conditions d’un jeu commercial.

Depuis la racine : `python3 scripts/build_catalog.py`, puis les tests Flutter. Le catalogue généré est embarqué et publié sur le site. Les tests valident chaque pack avec le même lecteur que l’application. Ne modifier aucun fichier généré à la main.

Les packs peuvent aussi inclure `creation` : catégories de cartes de personnage, nombre proposé par booster, minimum et maximum conservés. Les fiches générées appartiennent à la bibliothèque locale, pas au catalogue public.
