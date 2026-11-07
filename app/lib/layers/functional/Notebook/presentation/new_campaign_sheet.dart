import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CampaignDraft {
  const CampaignDraft(this.title, this.kind);
  final String title;
  final CampaignKind kind;
}

Future<CampaignDraft?> showNewCampaignSheet(BuildContext context) =>
    showModalBottomSheet<CampaignDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _NewCampaignSheet(),
    );

class _NewCampaignSheet extends StatefulWidget {
  const _NewCampaignSheet();

  @override
  State<_NewCampaignSheet> createState() => _NewCampaignSheetState();
}

class _NewCampaignSheetState extends State<_NewCampaignSheet> {
  final name = TextEditingController();
  var kind = CampaignKind.solo;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void submit() {
    final title = name.text.trim();
    if (title.isNotEmpty) Navigator.pop(context, CampaignDraft(title, kind));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.notebookNewCampaign,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: Space.lg),
          TextField(
            controller: name,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(labelText: l.notebookCampaignName),
            onSubmitted: (_) => submit(),
          ),
          const SizedBox(height: Space.lg),
          SegmentedButton<CampaignKind>(
            segments: [
              ButtonSegment(
                value: CampaignKind.solo,
                label: Text(l.notebookKindSolo),
              ),
              ButtonSegment(
                value: CampaignKind.gm,
                label: Text(l.notebookKindGm),
              ),
            ],
            selected: {kind},
            onSelectionChanged: (next) => setState(() => kind = next.first),
          ),
          const SizedBox(height: Space.xl),
          FilledButton(onPressed: submit, child: Text(l.notebookCreate)),
        ],
      ),
    );
  }
}
