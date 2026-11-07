import 'dart:convert';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';

const campaignFileFormat = 'amiludo-campaign';

class CampaignFile {
  const CampaignFile(this.campaign, this.images);

  factory CampaignFile.decode(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException {
      throw const FormatException('Not a campaign file');
    }
    if (json is! Map || json['format'] != campaignFileFormat) {
      throw const FormatException('Not a campaign file');
    }
    final campaign = NotebookCampaign.fromJson(
      Map<String, dynamic>.from(json['campaign'] as Map),
    );
    return CampaignFile(
      campaign,
      Map<String, String>.from(json['images'] as Map? ?? const {}),
    );
  }

  final NotebookCampaign campaign;
  final Map<String, String> images;

  String encode() => jsonEncode({
    'format': campaignFileFormat,
    'version': 1,
    'campaign': campaign.toJson(),
    'images': images,
  });

  CampaignFile fresh() {
    final renamed = {for (final id in images.keys) id: notebookId()};
    String? swap(String? id) => id == null ? null : renamed[id] ?? id;
    final copy = NotebookCampaign.fromJson(campaign.toJson());
    return CampaignFile(
      NotebookCampaign(
        id: notebookId(),
        title: copy.title,
        kind: copy.kind,
        palette: copy.palette,
        headerImageId: swap(copy.headerImageId),
        chaos: copy.chaos,
        sessions: copy.sessions,
        entries: [
          for (final e in copy.entries)
            e.copyWith(
              sections: [
                for (final s in e.sections)
                  s.copyWith(pictures: [for (final p in s.pictures) swap(p)!]),
              ],
            ),
        ],
        pinLinks: copy.pinLinks,
      ),
      {for (final e in images.entries) renamed[e.key]!: e.value},
    );
  }
}
