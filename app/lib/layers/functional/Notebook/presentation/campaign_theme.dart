import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';

const notebookPalettes = [
  0xFF8B3A3A,
  0xFFB5651D,
  0xFF8A7A1E,
  0xFF3E7D4F,
  0xFF1F6F78,
  0xFF3D5A9E,
  0xFF6B4A9E,
  0xFF9E4A7B,
];

ThemeData campaignTheme(ThemeData base, NotebookCampaign campaign) {
  final seed = campaign.palette;
  if (seed == null) return base;
  final scheme = ColorScheme.fromSeed(
    seedColor: Color(seed),
    brightness: base.brightness,
  );
  return base.copyWith(
    colorScheme: scheme,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
    ),
  );
}

class CampaignScope extends StatelessWidget {
  const CampaignScope({super.key, required this.id, required this.builder});

  final String id;
  final Widget Function(BuildContext context, NotebookCampaign campaign)
  builder;

  @override
  Widget build(BuildContext context) {
    final campaign = context.select<NotebookCubit, NotebookCampaign?>(
      (cubit) => cubit.state.of(id),
    );
    if (campaign == null) return const SizedBox.shrink();
    return Theme(
      data: campaignTheme(Theme.of(context), campaign),
      child: Builder(builder: (context) => builder(context, campaign)),
    );
  }
}
