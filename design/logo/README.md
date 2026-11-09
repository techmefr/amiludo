# Logos amiLudo

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="amiludo-logo-horizontal-dark.png">
  <img src="amiludo-logo-horizontal.png" width="420" alt="amiLudo - La boîte">
</picture>

Une boîte ouverte, un pion et une étincelle. Le couvercle est relié au rebord ; les faces de la boîte restent séparées par un espace visible. Les SVG sont faits de formes pleines, sans masque, filtre, image incorporée ni police externe.

## Choisir le bon fichier

| Usage | SVG | PNG |
|---|---|---|
| Symbole couleur sur fond clair | [Symbole](amiludo-mark.svg) | [1024 px](amiludo-mark.png) |
| Signature avec le nom, fond clair | [Signature](amiludo-logo-horizontal.svg) | [Haute définition](amiludo-logo-horizontal.png) |
| Signature avec le nom, fond sombre | [Signature inversée](amiludo-logo-horizontal-dark.svg) | [Haute définition](amiludo-logo-horizontal-dark.png) |
| Impression en une couleur | [Symbole monochrome](amiludo-mark-mono.svg) | [1024 px](amiludo-mark-mono.png) |
| Symbole blanc sur fond sombre | [Symbole blanc](amiludo-mark-white.svg) | [1024 px](amiludo-mark-white.png) |
| Icône d’application | [Icône carrée](amiludo-app-icon.svg) | [1024 px](amiludo-app-icon.png) |
| Icône Android/web avec découpe | [Icône maskable](amiludo-app-icon-maskable.svg) | [1024 px](amiludo-app-icon-maskable.png) |
| Très petites tailles | [Symbole simplifié](amiludo-mark-small.svg) | — |
| Favicon (icône d’application à 32 px) | [Favicon](amiludo-favicon.svg) | [32 px](../../app/web/favicon.png) |

## Règles d’usage

- Violet : `#6644D6`. Jaune : `#F6C445`. Encre : `#2A1F44`. Blanc : `#FFFFFF`.
- Garder les proportions et une marge libre d’au moins la moitié du diamètre de la tête du pion.
- Symbole standard à partir de 32 px ; symbole simplifié pour les plus petites tailles. Signature avec le nom à partir de 180 px de large.
- Choisir la version claire ou sombre selon le fond. Ne pas déplacer le couvercle, le pion ou les faces séparément.
- L’icône est carrée et opaque : Android et iOS appliquent leur propre forme. La version maskable conserve le dessin dans la zone de sécurité circulaire.
- Le nom est vectorisé depuis Bricolage Grotesque Bold. Sa licence OFL est conservée dans `app/assets/fonts/`.

## Régénérer les fichiers

Le maître est `amiludo-mark.svg`. Ne pas corriger chaque PNG séparément.

Depuis la racine du projet :

```sh
python3 -m venv .venv-brand
.venv-brand/bin/pip install -r scripts/requirements-brand.txt
.venv-brand/bin/python scripts/build_brand.py
.venv-brand/bin/python scripts/test_brand_assets.py
```

La génération produit les signatures, les PNG et les icônes Flutter, web, Android et iOS. Les README utilisent les PNG avec une variante pour le mode sombre afin de garder un rendu constant.
