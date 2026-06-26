import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/clipboard_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/prompt_config.dart';
import '../../domain/repositories/prompt_repository.dart';
import '../../domain/services/prompt_builder.dart';
import '../../domain/services/prompt_config_sanitizer.dart';
import '../../domain/usecases/prompt_usecases.dart';

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
  AiPromptCubit({
    required PromptRepository repository,
    required LoadLastPromptConfig loadLastConfig,
    required SaveLastPromptConfig saveLastConfig,
    required LoadPromptTemplate loadTemplate,
    required SavePromptTemplate saveTemplate,
    required ResetPromptTemplate resetTemplate,
    required LoadPromptPresets loadPresets,
    required SavePromptPresets savePresets,
    required ClipboardService clipboard,
    PromptConfig? initialConfig,
  })  : _repository = repository,
        _saveLastConfig = saveLastConfig,
        _clipboard = clipboard,
        _saveTemplate = saveTemplate,
        _resetTemplate = resetTemplate,
        _savePresets = savePresets,
        super(AiPromptState(
          config: sanitizePromptConfig(
              initialConfig ?? repository.loadLastConfig()),
          template: repository.loadTemplate(),
          presets: repository
              .loadPresets()
              .map((p) => PromptPreset(
                    id: p.id,
                    name: p.name,
                    config: sanitizePromptConfig(p.config),
                  ))
              .toList(),
        ));

  final PromptRepository _repository;
  final SaveLastPromptConfig _saveLastConfig;
  final SavePromptTemplate _saveTemplate;
  final ResetPromptTemplate _resetTemplate;
  final SavePromptPresets _savePresets;
  final ClipboardService _clipboard;
  final PromptBuilder _builder = const PromptBuilder();
  Timer? _persistDebounce;
  PromptConfig? _pendingPersist;

  void updateConfig(PromptConfig config) {
    final safe = sanitizePromptConfig(config);
    emit(state.copyWith(config: safe));
    _schedulePersist(safe);
  }

  void _schedulePersist(PromptConfig config) {
    _pendingPersist = config;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 400), () {
      final pending = _pendingPersist;
      if (pending != null) {
        _saveLastConfig(pending);
        _pendingPersist = null;
      }
    });
  }

  /// Immediately persists any pending config (e.g. before navigation).
  void flushPersist() => _flushPersist();

  /// Reloads persisted config from the repository (e.g. after returning from studio).
  void reloadLastConfig() {
    final config = sanitizePromptConfig(_repository.loadLastConfig());
    emit(state.copyWith(config: config));
  }

  void _flushPersist() {
    _persistDebounce?.cancel();
    final pending = _pendingPersist;
    if (pending != null) {
      _saveLastConfig(pending);
      _pendingPersist = null;
    }
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
    updateConfig(sanitizePromptConfig(preset.config));
  }

  Future<void> savePreset(String name) async {
    final preset = PromptPreset(
      id: const Uuid().v4(),
      name: name,
      config: state.config,
    );
    final updated = [...state.presets, preset];
    emit(state.copyWith(presets: updated));
    await _savePresets(updated);
  }

  Future<void> deletePreset(String id) async {
    final updated = state.presets.where((p) => p.id != id).toList();
    emit(state.copyWith(presets: updated));
    await _savePresets(updated);
  }

  void updateTemplate(String template) {
    emit(state.copyWith(template: template));
  }

  Future<void> persistTemplate() async {
    await _saveTemplate(state.template);
  }

  Future<void> resetTemplate() async {
    final r = await _resetTemplate(const NoParams());
    r.fold((_) {}, (template) => emit(state.copyWith(template: template)));
  }

  void toggleTemplateEditor([bool? value]) {
    emit(state.copyWith(
      isEditingTemplate: value ?? !state.isEditingTemplate,
    ));
  }

  String _buildPromptString() => _builder.build(
        template: state.template,
        config: state.config,
      );

  /// Builds prompt for clipboard/copy flows without triggering preview UI.
  String buildPromptForCopy() => _buildPromptString();

  String buildPrompt() {
    final built = _buildPromptString();
    emit(state.copyWith(builtPrompt: built, showPreview: true));
    return built;
  }

  void hidePreview() => emit(state.copyWith(showPreview: false));

  Future<void> copyPrompt(BuildContext context, String prompt) =>
      _clipboard.copyText(context, prompt);

  @override
  Future<void> close() {
    _flushPersist();
    return super.close();
  }
}