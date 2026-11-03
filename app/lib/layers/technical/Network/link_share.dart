import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareLink(String text, {String? subject}) =>
    SharePlus.instance.share(ShareParams(text: text, subject: subject));

Future<void> copyText(String text) =>
    Clipboard.setData(ClipboardData(text: text));
