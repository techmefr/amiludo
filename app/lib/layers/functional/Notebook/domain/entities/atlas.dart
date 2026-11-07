import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';

class AtlasNode {
  const AtlasNode(this.entry, this.depth);
  final NotebookEntry entry;
  final int depth;
}

String atlasMapKey(String campaignId, String placeId) =>
    'nb:$campaignId:$placeId';

String pinKey(String placeId, String markerId) => '$placeId/$markerId';

List<NotebookEntry> placesOf(NotebookCampaign campaign) => [
  for (final e in campaign.entries)
    if (e.kind == EntryKind.place) e,
];

List<AtlasNode> atlasTree(NotebookCampaign campaign) {
  final places = placesOf(campaign);
  final ids = {for (final p in places) p.id};
  final result = <AtlasNode>[];
  final seen = <String>{};
  void walk(NotebookEntry place, int depth) {
    if (!seen.add(place.id)) return;
    result.add(AtlasNode(place, depth));
    for (final child in places.where((p) => p.parentId == place.id)) {
      walk(child, depth + 1);
    }
  }

  for (final root in places) {
    if (root.parentId == null || !ids.contains(root.parentId)) walk(root, 0);
  }
  for (final loose in places) {
    walk(loose, 0);
  }
  return result;
}

Set<String> descendantIds(NotebookCampaign campaign, String placeId) {
  final found = <String>{};
  void visit(String id) {
    for (final p in placesOf(campaign).where((p) => p.parentId == id)) {
      if (found.add(p.id)) visit(p.id);
    }
  }

  visit(placeId);
  return found;
}

List<NotebookEntry> parentCandidates(
  NotebookCampaign campaign,
  String placeId,
) {
  final blocked = {placeId, ...descendantIds(campaign, placeId)};
  return [
    for (final p in placesOf(campaign))
      if (!blocked.contains(p.id)) p,
  ];
}

NotebookCampaign withParent(
  NotebookCampaign campaign,
  String placeId,
  String? parentId,
) {
  final place = campaign.entry(placeId);
  if (place == null) return campaign;
  if (parentId == null) return campaign.withEntry(place.withoutParent());
  final allowed = parentCandidates(
    campaign,
    placeId,
  ).any((p) => p.id == parentId);
  return allowed
      ? campaign.withEntry(place.copyWith(parentId: parentId))
      : campaign;
}

NotebookCampaign withPinLink(
  NotebookCampaign campaign,
  String placeId,
  String markerId,
  String? targetId,
) {
  final links = {...campaign.pinLinks}..remove(pinKey(placeId, markerId));
  if (targetId != null) links[pinKey(placeId, markerId)] = targetId;
  return campaign.copyWith(pinLinks: links);
}
