import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';

class Notebook {
  const Notebook({this.campaigns = const []});

  factory Notebook.fromJson(Map<String, dynamic> j) => Notebook(
    campaigns: [
      for (final c in j['campaigns'] as List? ?? const [])
        NotebookCampaign.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
  );

  final List<NotebookCampaign> campaigns;

  bool get isEmpty => campaigns.isEmpty;

  List<NotebookCampaign> get sorted => [
    ...campaigns.where((c) => c.favorite),
    ...campaigns.where((c) => !c.favorite),
  ];

  NotebookCampaign? of(String id) =>
      campaigns.where((c) => c.id == id).firstOrNull;

  Set<String> get imageIds => {for (final c in campaigns) ...c.imageIds};

  Notebook put(NotebookCampaign next) {
    final known = campaigns.any((c) => c.id == next.id);
    return Notebook(
      campaigns: known
          ? [for (final c in campaigns) c.id == next.id ? next : c]
          : [...campaigns, next],
    );
  }

  Notebook remove(String id) => Notebook(
    campaigns: [
      for (final c in campaigns)
        if (c.id != id) c,
    ],
  );

  Map<String, Object?> toJson() => {
    'campaigns': [for (final c in campaigns) c.toJson()],
  };
}
