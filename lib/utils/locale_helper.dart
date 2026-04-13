import 'package:flutter/material.dart';

String getLocalizedName(dynamic name, BuildContext context) {
  if (name is Map) {
    final lang = Localizations.localeOf(context).languageCode;
    return name[lang] ?? name['en'] ?? name.values.first ?? '';
  }
  return name?.toString() ?? '';
}
