import 'package:amiludo/layers/functional/Scenes/domain/entities/storyline.dart';
import 'package:amiludo/layers/functional/Scenes/domain/gateways/storyline_gateway.dart';

class ReadStorylineUseCase {
  ReadStorylineUseCase(this._storyline);
  final StorylineGateway _storyline;

  Storyline call() => _storyline.current;
}

class SaveStorylineUseCase {
  SaveStorylineUseCase(this._storyline);
  final StorylineGateway _storyline;

  Future<void> call(Storyline storyline) => _storyline.save(storyline);
}
