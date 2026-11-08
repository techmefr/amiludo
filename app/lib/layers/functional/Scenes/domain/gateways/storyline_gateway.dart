import 'package:amiludo/layers/functional/Scenes/domain/entities/storyline.dart';

abstract class StorylineGateway {
  Storyline get current;
  Stream<Storyline> get changes;
  Future<void> save(Storyline storyline);
}
