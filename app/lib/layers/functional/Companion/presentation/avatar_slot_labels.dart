import 'package:amiludo/l10n/app_localizations.dart';

String avatarSlotLabel(AppLocalizations l10n, String slot) => switch (slot) {
  'base' => l10n.avatarSlotBase,
  'head' => l10n.avatarSlotHead,
  'eyes' => l10n.avatarSlotEyes,
  'eyebrows' => l10n.avatarSlotEyebrows,
  'nose' => l10n.avatarSlotNose,
  'mouth' => l10n.avatarSlotMouth,
  'hair' => l10n.avatarSlotHair,
  'beard' => l10n.avatarSlotBeard,
  'marks' => l10n.avatarSlotMarks,
  'outfit' => l10n.avatarSlotOutfit,
  'shoes' => l10n.avatarSlotShoes,
  'accessory' => l10n.avatarSlotAccessory,
  'implant' => l10n.avatarSlotImplant,
  'equipment' => l10n.avatarSlotEquipment,
  'weapon' => l10n.avatarSlotWeapon,
  _ => slot,
};
