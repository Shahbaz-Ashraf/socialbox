import 'package:socialbox/features/ai_prompts/domain/entities/prompt_config.dart';
import 'package:socialbox/features/ai_prompts/domain/repositories/prompt_repository.dart';

class FakePromptRepository implements PromptRepository {
  FakePromptRepository({
    this.lastConfig = const PromptConfig(),
    this.template = 'test template',
    this.presets = const [],
  });

  PromptConfig lastConfig;
  String template;
  List<PromptPreset> presets;
  int saveLastConfigCallCount = 0;
  PromptConfig? lastSavedConfig;

  @override
  PromptConfig loadLastConfig() => lastConfig;

  @override
  Future<void> saveLastConfig(PromptConfig config) async {
    saveLastConfigCallCount++;
    lastSavedConfig = config;
    lastConfig = config;
  }

  @override
  String loadTemplate() => template;

  @override
  Future<void> saveTemplate(String template) async {
    this.template = template;
  }

  @override
  Future<void> resetTemplate() async {}

  @override
  List<PromptPreset> loadPresets() => presets;

  @override
  Future<void> savePresets(List<PromptPreset> presets) async {
    this.presets = presets;
  }
}