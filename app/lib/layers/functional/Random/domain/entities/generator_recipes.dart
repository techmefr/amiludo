class RecipeSection {
  const RecipeSection(this.label, this.key, [this.count = 1]);
  final String label, key;
  final int count;
}

class GeneratorRecipe {
  const GeneratorRecipe(
    this.group,
    this.titleKeys,
    this.sections, {
    this.separator = ' ',
  });
  final String group, separator;
  final List<String> titleKeys;
  final List<RecipeSection> sections;
}

const generatorRecipes = {
  'magicitem': GeneratorRecipe(
    'magicitem',
    ['kinds', 'epithets'],
    [
      RecipeSection('power', 'powers'),
      RecipeSection('quirk', 'quirks'),
      RecipeSection('origin', 'origins'),
    ],
  ),
  'weather': GeneratorRecipe('weather', ['conditions'], [
    RecipeSection('temperature', 'temperatures'),
    RecipeSection('wind', 'winds'),
    RecipeSection('effect', 'effects', 2),
    RecipeSection('omen', 'omens'),
  ]),
  'place': GeneratorRecipe(
    'place',
    ['starts', 'ends'],
    [
      RecipeSection('placeKind', 'kinds'),
      RecipeSection('feature', 'features'),
    ],
    separator: '',
  ),
  'dilemma': GeneratorRecipe('dilemma', ['situations'], [
    RecipeSection('choiceA', 'optionsA'),
    RecipeSection('choiceB', 'optionsB'),
    RecipeSection('cost', 'costs'),
  ]),
  'rumour': GeneratorRecipe('rumour', ['sources'], [
    RecipeSection('claim', 'claims'),
    RecipeSection('truth', 'truths'),
  ]),
  'trait': GeneratorRecipe('trait', ['traits'], [
    RecipeSection('shows', 'shows'),
    RecipeSection('flaw', 'flaws'),
  ]),
  'twist': GeneratorRecipe('twist', ['twists'], [
    RecipeSection('clue', 'clues'),
    RecipeSection('consequence', 'consequences'),
  ]),
};
