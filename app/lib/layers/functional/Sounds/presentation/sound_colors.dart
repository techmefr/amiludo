import 'package:flutter/material.dart';

const soundColorNames = ['primary', 'secondary', 'tertiary', 'error'];

Color soundColor(BuildContext context, String name) {
  final scheme = Theme.of(context).colorScheme;
  return switch (name) {
    'secondary' => scheme.secondary,
    'tertiary' => scheme.tertiary,
    'error' => scheme.error,
    _ => scheme.primary,
  };
}

Color soundColorOn(BuildContext context, String name) {
  final scheme = Theme.of(context).colorScheme;
  return switch (name) {
    'secondary' => scheme.onSecondary,
    'tertiary' => scheme.onTertiary,
    'error' => scheme.onError,
    _ => scheme.onPrimary,
  };
}
