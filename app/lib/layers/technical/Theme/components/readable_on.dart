import 'package:flutter/material.dart';

const _lightInk = Color(0xFFFFFFFF);
const _darkInk = Color(0xFF151515);

Color readableOn(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? _lightInk
    : _darkInk;
