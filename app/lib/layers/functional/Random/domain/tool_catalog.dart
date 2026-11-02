class ToolDefinition {
  const ToolDefinition(this.id, this.title, this.subtitle, this.category);
  final String id, title, subtitle, category;
}

const toolDefinitions = [
  ToolDefinition(
    'picker',
    'Qui commence ?',
    'Un doigt ou un nom. Le hasard choisit.',
    'Hasard',
  ),
  ToolDefinition(
    'dice',
    'Lancer les dés',
    'Dés multiples, verrouillage et expressions.',
    'Hasard',
  ),
  ToolDefinition(
    'scores',
    'Compter les points',
    'Scores, manches et catégories.',
    'Partie',
  ),
  ToolDefinition(
    'timer',
    'Garder le tempo',
    'Temps par tour ou réserve par joueur.',
    'Temps',
  ),
  ToolDefinition(
    'teams',
    'Faire les équipes',
    'De 2 à plusieurs équipes aléatoires.',
    'Hasard',
  ),
  ToolDefinition(
    'wheel',
    'Tourner la roue',
    'Options personnalisées et probabilités.',
    'Hasard',
  ),
  ToolDefinition(
    'coin',
    'Pile ou face',
    'Une décision en un instant.',
    'Hasard',
  ),
  ToolDefinition('order', 'Ordre de passage', 'À chacun son tour.', 'Partie'),
  ToolDefinition(
    'number',
    'Nombre aléatoire',
    'Un intervalle, un résultat.',
    'Hasard',
  ),
  ToolDefinition(
    'bag',
    'Sac de jetons',
    'Tirer sans remise, puis recommencer.',
    'Hasard',
  ),
  ToolDefinition(
    'roles',
    'Rôles secrets',
    'Un téléphone, des rôles à découvrir.',
    'Partie',
  ),
  ToolDefinition(
    'character',
    'Créer un personnage',
    'Listes et boosters : vos cartes composent une fiche.',
    'Partie',
  ),
];
