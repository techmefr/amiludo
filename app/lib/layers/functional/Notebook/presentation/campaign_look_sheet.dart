import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Notebook/presentation/campaign_theme.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/cubit/notebook_cubit.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/notebook_images.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<void> showCampaignLookSheet(BuildContext context, String id) {
  final cubit = context.read<NotebookCubit>();
  final images = context.read<NotebookImages>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => MultiRepositoryProvider(
      providers: [
        BlocProvider.value(value: cubit),
        RepositoryProvider.value(value: images),
      ],
      child: CampaignLookSheet(id: id),
    ),
  );
}

class CampaignLookSheet extends StatelessWidget {
  const CampaignLookSheet({super.key, required this.id});
  final String id;

  Future<void> _pickImage(BuildContext context) async {
    final cubit = context.read<NotebookCubit>();
    final imageId = await context.read<NotebookImages>().pickAndImport();
    if (imageId == null) return;
    await cubit.update(
      id,
      (c) => c.withLook(palette: c.palette, headerImageId: imageId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<NotebookCubit>();
    final campaign = context.watch<NotebookCubit>().state.of(id);
    if (campaign == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.notebookLook, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: Space.lg),
          Text(l.notebookPalette),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final color in notebookPalettes)
                Semantics(
                  button: true,
                  selected: campaign.palette == color,
                  label: l.notebookPalette,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Radii.pill),
                    onTap: () => cubit.update(
                      id,
                      (c) => c.withLook(
                        palette: color,
                        headerImageId: c.headerImageId,
                      ),
                    ),
                    child: Container(
                      width: Targets.minimum,
                      height: Targets.minimum,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: campaign.palette == color
                            ? Border.all(
                                width: Space.xs,
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.image_outlined),
                label: Text(l.notebookHeaderImage),
              ),
              if (campaign.headerImageId != null)
                TextButton(
                  onPressed: () =>
                      cubit.update(id, (c) => c.withLook(palette: c.palette)),
                  child: Text(l.notebookRemoveImage),
                ),
              if (campaign.palette != null)
                TextButton(
                  onPressed: () => cubit.update(
                    id,
                    (c) => c.withLook(headerImageId: c.headerImageId),
                  ),
                  child: Text(l.notebookDefaultPalette),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
