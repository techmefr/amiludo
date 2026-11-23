class LobbyAppMessage {
  const LobbyAppMessage(this.from, this.topic, this.body);

  final String from, topic;
  final Map<String, dynamic> body;
}
