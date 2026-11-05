import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/technical/Locale/supported_languages.dart';

Map<String, String> _messages(String code) {
  final json = jsonDecode(
    File('lib/l10n/app_$code.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

final _placeholder = RegExp(r'\{(\w+)\}');

Set<String> _placeholders(String text) =>
    _placeholder.allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  final template = _messages('en');

  test('every supported language has a language file', () {
    for (final language in supportedLanguages) {
      expect(
        File('lib/l10n/app_${language.code}.arb').existsSync(),
        isTrue,
        reason: language.code,
      );
    }
  });

  for (final language in supportedLanguages) {
    test('${language.code} has exactly the keys of the template', () {
      final messages = _messages(language.code);
      expect(
        template.keys.toSet().difference(messages.keys.toSet()),
        isEmpty,
        reason: 'missing in ${language.code}',
      );
      expect(
        messages.keys.toSet().difference(template.keys.toSet()),
        isEmpty,
        reason: 'unknown in ${language.code}',
      );
    });

    test('${language.code} uses the same placeholders as the template', () {
      final messages = _messages(language.code);
      for (final key in template.keys) {
        expect(
          _placeholders(messages[key] ?? ''),
          _placeholders(template[key]!),
          reason: '${language.code}: $key',
        );
      }
    });

    test('${language.code} has no empty text', () {
      for (final entry in _messages(language.code).entries) {
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
      }
    });
  }

  test('a stored language is valid when supported or automatic', () {
    expect(isValidLanguage('de'), isTrue);
    expect(isValidLanguage(autoLanguage), isTrue);
    expect(isValidLanguage('xx'), isFalse);
  });

  test('generated localizations resolve each language', () {
    expect(lookupAppLocalizations(const Locale('de')).workspaceHome, 'Start');
    expect(
      lookupAppLocalizations(const Locale('es')).workspaceFriends,
      'Amigos',
    );
    expect(lookupAppLocalizations(const Locale('nl')).themeSave, 'Opslaan');
    expect(
      lookupAppLocalizations(const Locale('it'))
          .qrJoinOnAmiludoCode('A', 'u', 'c'),
      contains('codice c'),
    );
  });
}
