class ToolDefinition {
  const ToolDefinition(this.id, this.category);
  final String id, category;
}

const toolCategories = ['all', 'chance', 'match', 'time', 'story'];

const toolDefinitions = [
  ToolDefinition('picker', 'chance'),
  ToolDefinition('dice', 'chance'),
  ToolDefinition('scores', 'match'),
  ToolDefinition('timer', 'time'),
  ToolDefinition('hourglass', 'time'),
  ToolDefinition('teams', 'chance'),
  ToolDefinition('wheel', 'chance'),
  ToolDefinition('coin', 'chance'),
  ToolDefinition('order', 'match'),
  ToolDefinition('number', 'chance'),
  ToolDefinition('bag', 'chance'),
  ToolDefinition('roles', 'match'),
  ToolDefinition('heroes', 'match'),
  ToolDefinition('character', 'story'),
  ToolDefinition('npc', 'story'),
  ToolDefinition('tavern', 'story'),
  ToolDefinition('encounter', 'story'),
  ToolDefinition('quest', 'story'),
  ToolDefinition('treasure', 'story'),
  ToolDefinition('villain', 'story'),
  ToolDefinition('town', 'story'),
  ToolDefinition('magicitem', 'story'),
  ToolDefinition('weather', 'story'),
  ToolDefinition('place', 'story'),
  ToolDefinition('dilemma', 'story'),
  ToolDefinition('rumour', 'story'),
  ToolDefinition('trait', 'story'),
  ToolDefinition('twist', 'story'),
];
