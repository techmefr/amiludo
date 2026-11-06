class ToolDefinition {
  const ToolDefinition(this.id, this.category);
  final String id, category;
}

const toolCategories = ['all', 'chance', 'match', 'time', 'story'];

const toolDefinitions = [
  ToolDefinition('picker', 'chance'),
  ToolDefinition('dice', 'chance'),
  ToolDefinition('dice-tray', 'chance'),
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
  ToolDefinition('character', 'story'),
  ToolDefinition('npc', 'story'),
  ToolDefinition('tavern', 'story'),
  ToolDefinition('encounter', 'story'),
  ToolDefinition('quest', 'story'),
  ToolDefinition('treasure', 'story'),
  ToolDefinition('villain', 'story'),
  ToolDefinition('town', 'story'),
];
