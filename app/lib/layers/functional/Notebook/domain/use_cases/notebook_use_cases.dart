import 'dart:convert';
import 'dart:typed_data';

import 'package:amiludo/layers/functional/Notebook/domain/entities/campaign_file.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_campaign.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/domain/gateways/notebook_gateways.dart';

class ReadNotebookUseCase {
  ReadNotebookUseCase(this._notebook);
  final NotebookGateway _notebook;

  Notebook call() => _notebook.current;
}

class WatchNotebookUseCase {
  WatchNotebookUseCase(this._notebook);
  final NotebookGateway _notebook;

  Stream<Notebook> call() => _notebook.changes;
}

class _ImagePruner {
  _ImagePruner(this._notebook, this._images);
  final NotebookGateway _notebook;
  final NotebookImageGateway _images;

  Future<void> prune(Set<String> candidates) async {
    final used = _notebook.current.imageIds;
    for (final id in candidates.difference(used)) {
      await _images.delete(id);
    }
  }
}

class SaveCampaignUseCase {
  SaveCampaignUseCase(this._notebook, NotebookImageGateway images)
    : _pruner = _ImagePruner(_notebook, images);
  final NotebookGateway _notebook;
  final _ImagePruner _pruner;

  Future<void> call(NotebookCampaign campaign) async {
    final before = _notebook.current.of(campaign.id)?.imageIds ?? const {};
    await _notebook.save(_notebook.current.put(campaign));
    await _pruner.prune(before);
  }
}

class DeleteCampaignUseCase {
  DeleteCampaignUseCase(this._notebook, NotebookImageGateway images)
    : _pruner = _ImagePruner(_notebook, images);
  final NotebookGateway _notebook;
  final _ImagePruner _pruner;

  Future<void> call(String id) async {
    final before = _notebook.current.of(id)?.imageIds ?? const {};
    await _notebook.save(_notebook.current.remove(id));
    await _pruner.prune(before);
  }
}

class ImportNotebookImageUseCase {
  ImportNotebookImageUseCase(this._images);
  final NotebookImageGateway _images;

  Future<String> call(List<int> bytes) async {
    final id = notebookId();
    await _images.write(id, bytes);
    return id;
  }
}

class ReadNotebookImageUseCase {
  ReadNotebookImageUseCase(this._images);
  final NotebookImageGateway _images;

  Future<Uint8List?> call(String id) => _images.read(id);
}

class ExportCampaignUseCase {
  ExportCampaignUseCase(this._notebook, this._images);
  final NotebookGateway _notebook;
  final NotebookImageGateway _images;

  Future<String> call(String id) async {
    final campaign = _notebook.current.of(id);
    if (campaign == null) throw StateError('Unknown campaign');
    final images = <String, String>{};
    for (final imageId in campaign.imageIds) {
      final bytes = await _images.read(imageId);
      if (bytes != null) images[imageId] = base64Encode(bytes);
    }
    return CampaignFile(campaign, images).encode();
  }
}

class ImportCampaignUseCase {
  ImportCampaignUseCase(this._notebook, this._images);
  final NotebookGateway _notebook;
  final NotebookImageGateway _images;

  Future<String> call(String source) async {
    final file = CampaignFile.decode(source).fresh();
    for (final image in file.images.entries) {
      await _images.write(image.key, base64Decode(image.value));
    }
    await _notebook.save(_notebook.current.put(file.campaign));
    return file.campaign.id;
  }
}
