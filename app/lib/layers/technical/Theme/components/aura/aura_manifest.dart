import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_layer.dart';

const _tl = Alignment(-.9, -.9);
const _br = Alignment(1, .8);
const _mid = Alignment(.1, -.2);
const _tr = Alignment(.9, -.7);
const _bl = Alignment(-.8, .9);

const auraSkins = <String, AuraPreset>{
  'clean': AuraPreset(
    light: [
      AuraLayer(_tl, .9, .05, BlendMode.srcOver, tint: AuraTint.primary),
      AuraLayer(_br, .8, .04, BlendMode.softLight, rgb: 0xff8fb8),
    ],
    dark: [
      AuraLayer(_tl, .9, .12, BlendMode.screen, tint: AuraTint.primary),
      AuraLayer(_br, .8, .12, BlendMode.plus, rgb: 0x3b3f9e),
    ],
    drift: .5,
  ),
  'play': AuraPreset(
    light: [
      AuraLayer(_tl, .85, .2, BlendMode.srcOver, rgb: 0xc7aeff),
      AuraLayer(_br, .8, .18, BlendMode.srcOver, rgb: 0xffb38a),
      AuraLayer(_mid, .5, .1, BlendMode.softLight, rgb: 0xffd84d),
    ],
    dark: [
      AuraLayer(_tl, .85, .26, BlendMode.screen, rgb: 0x7150cc),
      AuraLayer(_br, .8, .2, BlendMode.plus, rgb: 0xa14a2f),
      AuraLayer(_mid, .5, .1, BlendMode.screen, rgb: 0xe0a92a),
    ],
    drift: .9,
  ),
  'cyber': AuraPreset(
    light: [
      AuraLayer(_tr, .85, .2, BlendMode.srcOver, rgb: 0x35c4da),
      AuraLayer(_bl, .8, .16, BlendMode.srcOver, rgb: 0xf873d2),
    ],
    dark: [
      AuraLayer(_tr, .85, .26, BlendMode.screen, rgb: 0x0b8fa8),
      AuraLayer(_bl, .8, .22, BlendMode.plus, rgb: 0x9c2a82),
      AuraLayer(_mid, .45, .1, BlendMode.screen, rgb: 0x35c4da),
    ],
    grain: .05,
    drift: .7,
  ),
  'orbital': AuraPreset(
    light: [
      AuraLayer(_tl, .9, .24, BlendMode.srcOver, rgb: 0xf2b84b),
      AuraLayer(_br, .75, .14, BlendMode.softLight, rgb: 0xd9822b),
    ],
    dark: [
      AuraLayer(_tl, .9, .24, BlendMode.screen, rgb: 0xa86a12),
      AuraLayer(_br, .75, .16, BlendMode.plus, rgb: 0x7a3d12),
    ],
    grain: .06,
    drift: .4,
  ),
  'paper': AuraPreset(
    light: [
      AuraLayer(_tl, .85, .2, BlendMode.srcOver, rgb: 0xa6ca67),
      AuraLayer(_br, .8, .16, BlendMode.srcOver, rgb: 0xf0b8a0),
      AuraLayer(_mid, .5, .1, BlendMode.softLight, rgb: 0xf3d77a),
    ],
    dark: [
      AuraLayer(_tl, .85, .22, BlendMode.screen, rgb: 0x4f7a2c),
      AuraLayer(_br, .8, .18, BlendMode.plus, rgb: 0x8a4a35),
    ],
    grain: .06,
    drift: .5,
  ),
  'game': AuraPreset(
    light: [
      AuraLayer(_tl, .9, .24, BlendMode.screen, rgb: 0x8a6a12),
      AuraLayer(_br, .8, .2, BlendMode.plus, rgb: 0x4b2a78),
    ],
    dark: [
      AuraLayer(_tl, .9, .24, BlendMode.screen, rgb: 0x8a6a12),
      AuraLayer(_br, .8, .2, BlendMode.plus, rgb: 0x4b2a78),
    ],
    grain: .05,
    drift: .6,
  ),
};

const auraShelfColors = <String, (int, int)>{
  'time': (0xf2a33a, 0xe8742c),
  'chance': (0x8b5cf6, 0x5b3fd0),
  'scores': (0x14b8a6, 0x0e7490),
  'cards': (0xa855f7, 0xc026d3),
  'rules': (0xd9b779, 0xa67c3d),
  'votes': (0xf43f5e, 0xfb7185),
  'ambience': (0x6366f1, 0x0ea5e9),
  'party': (0xfb923c, 0xf472b6),
  'map': (0x84a63a, 0x2f8f6b),
  'story': (0xa66ba8, 0xe09f5c),
  'generators': (0x06b6d4, 0x6366f1),
  'gm': (0xdc2626, 0x7f1d1d),
  'characters': (0x38bdf8, 0x818cf8),
  'players': (0x3b82f6, 0x14b8a6),
};

const auraShelfTools = <String, List<String>>{
  'time': [
    'stopwatch',
    'countdown',
    'turn-timer',
    'phases',
    'metronome',
    'timer',
    'chess-clock',
    'hourglass',
  ],
  'chance': ['dice', 'dice-tray', 'wheel', 'coin', 'number'],
  'scores': [
    'scores',
    'life',
    'tally',
    'ranking',
    'stats',
    'clocks',
    'sport',
    'bank',
    'league',
    'auction',
    'sheet',
    'counter-life',
    'counter-points',
    'counter-chips',
    'counter-pot',
  ],
  'cards': ['deck', 'bag'],
  'rules': ['rules'],
  'votes': ['vote', 'impostor'],
  'ambience': ['ambience'],
  'party': ['challenges'],
  'map': ['map'],
  'story': ['journal', 'oracle', 'town', 'place', 'weather'],
  'generators': ['magicitem', 'dilemma', 'trait', 'twist'],
  'gm': [
    'worldmap',
    'gmtables',
    'scenes',
    'bestiary',
    'combat',
    'npc',
    'encounter',
    'treasure',
    'tavern',
    'rumour',
    'villain',
    'quest',
  ],
  'characters': ['character', 'card-packs', 'heroes'],
  'players': [
    'picker',
    'first-player',
    'buzzer',
    'markers',
    'tournament',
    'solo',
    'units',
    'balance',
    'turns',
    'teams',
    'order',
    'roles',
  ],
};
