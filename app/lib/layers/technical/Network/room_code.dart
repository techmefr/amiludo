import 'dart:math';

const roomAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

String newRoomCode(int length, [Random? random]) {
  final source = random ?? Random.secure();
  return List.generate(
    length,
    (_) => roomAlphabet[source.nextInt(roomAlphabet.length)],
  ).join();
}

String? normalizeRoomCode(String input) {
  final code = input.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  if (code.length < 6 || code.length > 8) return null;
  return code.split('').every(roomAlphabet.contains) ? code : null;
}
