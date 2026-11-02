import 'package:flutter/material.dart';

IconData toolIcon(String id) => switch (id) {
  'character' => Icons.badge_outlined,
  'dice' => Icons.casino_outlined,
  'picker' => Icons.touch_app_outlined,
  'scores' => Icons.add_chart_outlined,
  'timer' => Icons.timer_outlined,
  'teams' => Icons.groups_outlined,
  'wheel' => Icons.radar,
  'coin' => Icons.toll_outlined,
  'order' => Icons.swap_vert,
  'number' => Icons.numbers,
  'bag' => Icons.shopping_bag_outlined,
  'roles' => Icons.visibility_off_outlined,
  _ => Icons.extension_outlined,
};
