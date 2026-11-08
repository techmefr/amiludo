class MetronomeState {
  const MetronomeState({this.bpm = 90, this.beats = 4, this.beat = 0});

  static const int slowest = 30;
  static const int fastest = 240;
  static const int fewest = 2;
  static const int most = 8;

  final int bpm, beats, beat;

  Duration get interval => Duration(microseconds: 60000000 ~/ bpm);

  bool get accented => beat == 0;

  MetronomeState withBpm(int value) =>
      MetronomeState(bpm: value.clamp(slowest, fastest), beats: beats);

  MetronomeState withBeats(int value) =>
      MetronomeState(bpm: bpm, beats: value.clamp(fewest, most));

  MetronomeState next() =>
      MetronomeState(bpm: bpm, beats: beats, beat: (beat + 1) % beats);

  MetronomeState restarted() => MetronomeState(bpm: bpm, beats: beats);
}
