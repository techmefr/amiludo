import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get configured => url.isNotEmpty && publishableKey.isNotEmpty;

  static String get authRedirect => kIsWeb
      ? '${Uri.base.origin}${Uri.base.path}'
      : 'amiludo://amiludo.app/account';

  static Future<void> start() async {
    if (configured) {
      await Supabase.initialize(url: url, publishableKey: publishableKey);
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
