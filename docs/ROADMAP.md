# Feuille de route

Aucune échéance promise ; chaque étape dépend de critères de sortie.

## 0 — Fondations (réalisées, identité provisoire)

Nom de travail, catalogue, choix techniques et logo « La boîte » retenu (design/logo). Le dépôt contient maintenant une application Flutter alpha et les maquettes initiales.

## 1 — Tranche verticale (réalisée et testée)

Créer une partie à trois joueurs, ajouter des points, annuler, fermer et retrouver la partie. Éprouver les migrations de données et l’accessibilité avant d’élargir.

## 2 — MVP hors ligne (alpha en validation)

Fonctions marquées MVP dans le catalogue. Tester sur Android, iPhone et navigateur, dont sélection tactile, veille, reprise des horloges et perte du stockage web. Une partie complète doit fonctionner en mode avion après installation ou premier chargement web mis en cache.

## 3 — V1 personnalisable

Modèles de jeux, scores par catégories, outils avancés et historique enrichi. Importer un modèle communautaire validé et jouer sans réseau. L’éditeur commence par un format déclaratif limité.

## 4 — V2 partagée (en cours)

Réalisé en 0.4.0 :
- salons à rejoindre par code, lien ou QR, sur le même Wi‑Fi ou à distance (Supabase) ;
- comptes facultatifs ;
- soirées avec inscriptions et liste d’attente.

Prochaines étapes :
- secret d’hôte dans le lien, canaux Realtime privés et découverte Wi‑Fi sans code en clair ;
- SMTP pour les e-mails de compte ;
- App Links et Universal Links à la place du schéma `amiludo://` ;
- APK release signé ;
- partage de l’état de partie entre appareils (autorité de l’hôte, ordre des actions, reprise).

Les parties locales restent disponibles sans service distant.

## Qualité du code

- Découper le document `Workspace` en stockages par fonctionnalité ; chaque cubit n’expose alors que son propre état.
- Supprimer le cycle Game ↔ Timer.
- Découper `random_tool.dart` par outil.
- Sortir les textes et erreurs restants vers l’i18n.

## 5 — Tournois et intégrations

Extensions indépendantes, selon les usages observés et les contributions. La priorité reste un compagnon local, accessible et personnalisable.

## Personnages et cartes

Les générateurs par listes/boosters sont disponibles. Prochaines étapes : fiches libres (caractéristiques, inventaire, progression), paquets de cartes génériques (pioche, main, défausse), plateaux/jetons et suivi de campagne. Les mains privées multi-appareils dépendent des futures salles partagées.
