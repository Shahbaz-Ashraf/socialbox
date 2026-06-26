import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialbox/core/services/clipboard_service.dart';
import 'package:socialbox/features/ai_prompts/domain/entities/prompt_config.dart';
import 'package:socialbox/features/ai_prompts/domain/usecases/prompt_usecases.dart';
import 'package:socialbox/features/ai_prompts/presentation/cubit/ai_prompt_cubit.dart';

import '../../../../helpers/fake_prompt_repository.dart';

class _FakeClipboard extends ClipboardService {}

AiPromptCubit _buildCubit(FakePromptRepository repo) => AiPromptCubit(
      repository: repo,
      loadLastConfig: LoadLastPromptConfig(repo),
      saveLastConfig: SaveLastPromptConfig(repo),
      loadTemplate: LoadPromptTemplate(repo),
      saveTemplate: SavePromptTemplate(repo),
      resetTemplate: ResetPromptTemplate(repo),
      loadPresets: LoadPromptPresets(repo),
      savePresets: SavePromptPresets(repo),
      clipboard: _FakeClipboard(),
    );

void main() {
  group('AiPromptCubit persist', () {
    test('debounces saveLastConfig by 400ms', () {
      fakeAsync((async) {
        final repo = FakePromptRepository();
        final cubit = _buildCubit(repo);

        cubit.updateField(topic: 'first');
        expect(repo.saveLastConfigCallCount, 0);

        async.elapse(const Duration(milliseconds: 399));
        expect(repo.saveLastConfigCallCount, 0);

        async.elapse(const Duration(milliseconds: 1));
        expect(repo.saveLastConfigCallCount, 1);
        expect(repo.lastSavedConfig?.topic, 'first');

        cubit.close();
      });
    });

    test('flushPersist saves immediately without waiting for debounce', () {
      fakeAsync((async) {
        final repo = FakePromptRepository();
        final cubit = _buildCubit(repo);

        cubit.updateField(topic: 'flush me');
        cubit.flushPersist();

        expect(repo.saveLastConfigCallCount, 1);
        expect(repo.lastSavedConfig?.topic, 'flush me');

        async.elapse(const Duration(milliseconds: 500));
        expect(repo.saveLastConfigCallCount, 1);

        cubit.close();
      });
    });

    test('close flushes pending persist', () {
      fakeAsync((async) {
        final repo = FakePromptRepository();
        final cubit = _buildCubit(repo);

        cubit.updateField(topic: 'on close');
        cubit.close();

        expect(repo.saveLastConfigCallCount, 1);
        expect(repo.lastSavedConfig?.topic, 'on close');

        async.elapse(const Duration(milliseconds: 500));
        expect(repo.saveLastConfigCallCount, 1);
      });
    });

    test('coalesces rapid keystrokes into a single save', () {
      fakeAsync((async) {
        final repo = FakePromptRepository();
        final cubit = _buildCubit(repo);

        cubit.updateField(topic: 'a');
        cubit.updateField(topic: 'ab');
        cubit.updateField(topic: 'abc');

        expect(repo.saveLastConfigCallCount, 0);
        async.elapse(const Duration(milliseconds: 400));
        expect(repo.saveLastConfigCallCount, 1);
        expect(repo.lastSavedConfig?.topic, 'abc');

        cubit.close();
      });
    });

    test('buildPromptForCopy does not set showPreview', () {
      final repo = FakePromptRepository();
      final cubit = _buildCubit(repo);

      cubit.updateField(topic: 'copy topic');
      cubit.buildPromptForCopy();

      expect(cubit.state.showPreview, isFalse);
      cubit.close();
    });

    test('reloadLastConfig reads persisted config from repository', () {
      final repo = FakePromptRepository(
        lastConfig: const PromptConfig(topic: 'stored topic'),
      );
      final cubit = _buildCubit(repo);

      cubit.updateField(topic: 'in memory');
      repo.lastConfig = const PromptConfig(topic: 'stored topic');
      cubit.reloadLastConfig();

      expect(cubit.state.config.topic, 'stored topic');
      cubit.close();
    });
  });
}