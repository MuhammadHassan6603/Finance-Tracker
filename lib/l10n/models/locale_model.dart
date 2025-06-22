import 'package:flutter/material.dart';

class LocaleModel {
  final Locale locale;
  final bool isSystemDefault;

  LocaleModel({
    required this.locale,
    this.isSystemDefault = false,
  });
}
