import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';

class CampaignProgress {
  const CampaignProgress({this.completed = const [], this.choices = const {}});

  factory CampaignProgress.fromJson(Map<String, dynamic> json) =>
      CampaignProgress(
        completed: [
          for (final id in json['completed'] as List? ?? const [])
            if (campaignMissions.any((m) => m.id == id)) id as String,
        ],
        choices: {
          for (final entry in (json['choices'] as Map? ?? const {}).entries)
            entry.key as String: (entry.value as num).toInt(),
        },
      );

  final List<String> completed;
  final Map<String, int> choices;

  int get doneCount => completed.length;

  bool get finished => doneCount == campaignMissions.length;

  bool isDone(String id) => completed.contains(id);

  bool isUnlocked(Mission mission) {
    final index = campaignMissions.indexOf(mission);
    return index == 0 || isDone(campaignMissions[index - 1].id);
  }

  Mission? get next =>
      campaignMissions.where((m) => !isDone(m.id)).firstOrNull;

  CampaignProgress withCompleted(String id, {int? choice}) =>
      CampaignProgress(
        completed: isDone(id) ? completed : [...completed, id],
        choices: choice == null ? choices : {...choices, id: choice},
      );

  Map<String, Object?> toJson() => {'completed': completed, 'choices': choices};
}
