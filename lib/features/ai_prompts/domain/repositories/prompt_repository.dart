import '../entities/prompt_config.dart';

abstract class PromptRepository {
  String loadTemplate();
  Future<void> saveTemplate(String template);
  Future<void> resetTemplate();

  PromptConfig loadLastConfig();
  Future<void> saveLastConfig(PromptConfig config);

  List<PromptPreset> loadPresets();
  Future<void> savePresets(List<PromptPreset> presets);
}