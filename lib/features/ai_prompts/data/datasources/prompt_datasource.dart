import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/prompt_config.dart';
import '../constants/default_post_writing_prompt.dart';

class PromptDataSource {
  PromptDataSource(this._prefs);
  final SharedPreferences _prefs;

  String loadTemplate() =>
      _prefs.getString(AppConstants.promptTemplateKey) ??
      kDefaultPostWritingPrompt;

  Future<void> saveTemplate(String template) async {
    await _prefs.setString(AppConstants.promptTemplateKey, template);
  }

  Future<void> resetTemplate() async {
    await _prefs.remove(AppConstants.promptTemplateKey);
  }

  PromptConfig loadLastConfig() {
    final raw = _prefs.getString(AppConstants.promptLastConfigKey);
    if (raw == null) return const PromptConfig();
    try {
      return PromptConfig.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PromptConfig();
    }
  }

  Future<void> saveLastConfig(PromptConfig config) async {
    await _prefs.setString(
      AppConstants.promptLastConfigKey,
      jsonEncode(config.toJson()),
    );
  }

  List<PromptPreset> loadPresets() {
    final raw = _prefs.getString(AppConstants.promptPresetsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PromptPreset.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePresets(List<PromptPreset> presets) async {
    await _prefs.setString(
      AppConstants.promptPresetsKey,
      jsonEncode(presets.map((p) => p.toJson()).toList()),
    );
  }
}