import '../../domain/entities/prompt_config.dart';
import '../../domain/repositories/prompt_repository.dart';
import '../datasources/prompt_datasource.dart';

class PromptRepositoryImpl implements PromptRepository {
  PromptRepositoryImpl(this._local);
  final PromptDataSource _local;

  @override
  String loadTemplate() => _local.loadTemplate();

  @override
  Future<void> saveTemplate(String template) => _local.saveTemplate(template);

  @override
  Future<void> resetTemplate() => _local.resetTemplate();

  @override
  PromptConfig loadLastConfig() => _local.loadLastConfig();

  @override
  Future<void> saveLastConfig(PromptConfig config) =>
      _local.saveLastConfig(config);

  @override
  List<PromptPreset> loadPresets() => _local.loadPresets();

  @override
  Future<void> savePresets(List<PromptPreset> presets) =>
      _local.savePresets(presets);
}