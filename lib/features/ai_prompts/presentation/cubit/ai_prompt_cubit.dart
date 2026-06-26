import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/prompt_datasource.dart';
import '../../domain/entities/prompt_config.dart';
import '../../domain/services/prompt_builder.dart';

class AiPromptState {
  const AiPromptState({
    required this.config,
    required this.template,
    required this.presets,
    this.builtPrompt = '',
    this.showPreview = false,
    this.isEditingTemplate = false,
  });

  final PromptConfig config;
  final String template;
  final List<PromptPreset> presets;
  final String builtPrompt;
  final bool showPreview;
  final bool isEditingTemplate;

  AiPromptState copyWith({
    PromptConfig? config,
    String? template,
    List<PromptPreset>? presets,
    String? builtPrompt,
    bool? showPreview,
    bool? isEditingTemplate,
  }) =>
      AiPromptState(
        config: config ?? this.config,
        template: template ?? this.template,
        presets: presets ?? this.presets,
        builtPrompt: builtPrompt ?? this.builtPrompt,
        showPreview: showPreview ?? this.showPreview,
        isEditingTemplate: isEditingTemplate ?? this.isEditingTemplate,
      );
}

class AiPromptCubit extends Cubit<AiPromptState> {
  AiPromptCubit(PromptDataSource ds, {PromptConfig? initialConfig})
      : _ds = ds,
        super(AiPromptState(
          config: initialConfig ?? ds.loadLastConfig(),
          template: ds.loadTemplate(),
          presets: ds.loadPresets(),
        ));

  final PromptDataSource _ds;
  final PromptBuilder _builder = const PromptBuilder();

  void updateConfig(PromptConfig config) {
    emit(state.copyWith(config: config));
    _ds.saveLastConfig(config);
  }

  void updateField({
    String? topic,
    String? primaryKeyword,
    String? secondaryKeywords,
    String? platform,
    String? targetAudience,
    String? brandArchetype,
    String? postGoal,
    String? wordLimit,
    String? emojiRange,
    String? hashtagRange,
    String? contentMode,
    String? contentPillar,
  }) {
    updateConfig(state.config.copyWith(
      topic: topic,
      primaryKeyword: primaryKeyword,
      secondaryKeywords: secondaryKeywords,
      platform: platform,
      targetAudience: targetAudience,
      brandArchetype: brandArchetype,
      postGoal: postGoal,
      wordLimit: wordLimit,
      emojiRange: emojiRange,
      hashtagRange: hashtagRange,
      contentMode: contentMode,
      contentPillar: contentPillar,
    ));
  }

  void loadPreset(PromptPreset preset) {
    updateConfig(preset.config);
  }

  Future<void> savePreset(String name) async {
    final preset = PromptPreset(
      id: const Uuid().v4(),
      name: name,
      config: state.config,
    );
    final updated = [...state.presets, preset];
    emit(state.copyWith(presets: updated));
    await _ds.savePresets(updated);
  }

  Future<void> deletePreset(String id) async {
    final updated = state.presets.where((p) => p.id != id).toList();
    emit(state.copyWith(presets: updated));
    await _ds.savePresets(updated);
  }

  void updateTemplate(String template) {
    emit(state.copyWith(template: template));
  }

  Future<void> persistTemplate() async {
    await _ds.saveTemplate(state.template);
  }

  Future<void> resetTemplate() async {
    await _ds.resetTemplate();
    emit(state.copyWith(template: _ds.loadTemplate()));
  }

  void toggleTemplateEditor([bool? value]) {
    emit(state.copyWith(
      isEditingTemplate: value ?? !state.isEditingTemplate,
    ));
  }

  String buildPrompt() {
    final built = _builder.build(
      template: state.template,
      config: state.config,
    );
    emit(state.copyWith(builtPrompt: built, showPreview: true));
    return built;
  }

  void hidePreview() => emit(state.copyWith(showPreview: false));
}