import 'dart:convert';
import 'package:flutter/material.dart';

extension StringListJson on List<String> {
  String toJsonString() => jsonEncode(map((e) => e).toList());

  static List<String> fromJsonString(String? json) {
    if (json == null || json.isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
    return <String>[];
  }
}

extension IntListJson on List<int> {
  String toJsonString() => jsonEncode(map((e) => e).toList());

  static List<int> fromJsonString(String? json) {
    if (json == null || json.isEmpty) return <int>[];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => int.tryParse(e.toString()) ?? 0).toList()
          ..removeWhere((e) => e == 0);
      }
    } catch (_) {}
    return <int>[];
  }
}

extension ColorFromHex on Color {
  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.parse('FF$cleaned', radix: 16);
    return Color(value);
  }
}

extension StringCapitalize on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension BuildContextSpacing on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textStyles => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}
