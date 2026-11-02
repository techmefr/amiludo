# Contribuer

Le compagnon est une application Flutter en alpha publique, sous licence MIT. Les retours sur appareils réels, corrections, traductions, améliorations d’accessibilité et modèles de jeux sont bienvenus.

Commencer par le [guide de test](TESTING.md). Pour une évolution importante, ouvrir une proposition expliquant le jeu, le problème et le comportement souhaité ; consulter le [catalogue](docs/FEATURES.md) pour éviter les doublons. Les petites corrections peuvent être proposées directement par pull request.

## Développement

Installer Flutter **3.47.9** (Dart **3.13.7**), puis :

```sh
cd app
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
cd ..
python3 -m unittest discover -s scripts -p 'test_*.py'
```

La compilation web complète utilise `bash scripts/build_web.sh`. Android nécessite le SDK Android et JDK 17 ; iOS nécessite macOS et Xcode. Les versions des dépendances sont verrouillées.

Le code est dans `app/lib/layers/functional` et `app/lib/layers/technical`, les tests dans `app/test`, les maquettes dans `prototype` et les outils de publication dans `scripts`.

## Proposer une modification

1. Créer un fork et une branche dédiée.
2. Garder une modification ciblée et expliquer son effet pour les joueurs.
3. Vérifier l’analyse et les tests ; couvrir les règles de scores, temps, imports ou stockage affectées. Pour une interface, joindre une capture et indiquer les appareils testés.
4. Mettre à jour le catalogue si une fonction devient réellement utilisable. Signaler les limites restantes et les changements de format de données.
5. Ouvrir une pull request vers `main`.

Conserver le fonctionnement local sans compte, l’accessibilité et les sauvegardes portables. Ne pas commettre de secrets ou de données personnelles. Les modèles, images, polices et autres contributions doivent avoir une origine et une licence compatibles. Ne pas inclure de livrets de règles, illustrations ou marques de tiers sans autorisation ; conserver les crédits et licences requis.

Les échanges doivent rester respectueux et porter sur les usages et les modifications proposées. Pour une vulnérabilité, suivre [SECURITY.md](SECURITY.md).
