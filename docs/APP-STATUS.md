# Application — état réel

Alpha 0.2.0. Nom provisoire. Code Flutter dans `app/`, application web dans `/app/`, anciennes maquettes à la racine du site.

## Disponible

Parties et scores locaux, manches, catégories, objectifs, journal annulable, ressources et notes ; horloges par table ; outils de hasard ; thèmes et profils ; stockage SQLite, historique, CSV et sauvegardes JSON.

L’alpha 0.2.0 ajoute les pages d’outils avec retour, la surface tactile agrandie, les builders de packs par jeu (dés, rôles, calculs déclaratifs, notes et liens de règles), les personnages par listes ou boosters, les fiches sauvegardables/importables/exportables et la galerie installable. Voir [PACKS.md](PACKS.md).

Le catalogue compte 148 fonctions, dont 91 cochées et 57 prévues ou incomplètes. Les trois packs initiaux sont des exemples originaux du projet. La publication communautaire passe par relecture des pull requests ; aucun contenu n’est présenté comme une contribution fictive.

## Vérifications

38 tests Flutter couvrent les scores, imports, stockage, temps, tirages, profils, nouveaux calculs, packs, générations par listes/boosters, sauvegardes de fiches, navigation tactile et sauvegarde d’un pack depuis un lien direct. Un test Python vérifie le paquet hors connexion. Le workflow effectue l’analyse et les tests avant compilation web et APK Android.

Les contrôles Chromium de la version précédente ont validé les scores persistants et le rechargement hors connexion. Les nouveaux parcours navigateur contrôlent l’installation d’un pack, les boosters, le choix de deux races, la fiche après rechargement et les pages dédiées. Les essais sur téléphones physiques, Safari, multitouch, sons, vibrations, veille et lecteurs d’écran restent à compléter.

## Limites

Les salles multi-appareils, mains privées partagées, serveur, tournois, cadences avancées, formules arbitraires, intégrations, statistiques détaillées, export d’images et traduction anglaise exhaustive restent à développer. Les prochaines extensions sont les fiches libres avec inventaire/progression, les paquets de cartes génériques, plateaux et campagnes.

Les règles distantes sont des liens ; leurs livrets ne sont pas aspirés ou analysés. Les calculs disponibles ne vérifient pas toutes les règles d’un jeu. Une fiche générée contient les choix et descriptions du pack, pas encore un système complet de caractéristiques et de combat.

Une partie conserve la copie de son pack. Modifier la bibliothèque ne recalcule pas les parties existantes. Les anciennes sauvegardes restent lisibles ; exporter avant toute mise à jour reste recommandé. Les APK de développement peuvent imposer une désinstallation en cas de changement de signature.

La cible iOS nécessite macOS, Xcode et une signature Apple ; aucune application iOS native n’est distribuée. Le site est accessible aux utilisateurs iPhone/iPad. Aucune alarme en arrière-plan n’est garantie lorsque le système suspend l’application.

La création guidée demande le nom local et le nom anglais, puis ne présente que les réglages des modes choisis. L’accueil distingue mode libre et compagnon par jeu ; les icônes utilisent Hugeicons Free.

La [présentation joueur](presentation/Compagnon-presentation-joueurs.pdf) et le [catalogue cible élargi](VISION-COMPLETE.md) servent à recueillir les retours. Leur inventaire est une vision à enrichir, pas la liste de fonctions déjà livrées.
