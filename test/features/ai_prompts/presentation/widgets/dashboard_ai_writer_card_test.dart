import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socialbox/core/services/clipboard_service.dart';
import 'package:socialbox/core/usecases/usecase.dart';
import 'package:socialbox/features/ai_prompts/domain/entities/prompt_config.dart';
import 'package:socialbox/features/ai_prompts/domain/usecases/prompt_usecases.dart';
import 'package:socialbox/features/ai_prompts/presentation/cubit/ai_prompt_cubit.dart';
import 'package:socialbox/features/ai_prompts/presentation/widgets/dashboard_ai_writer_card.dart';
import 'package:socialbox/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:socialbox/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:socialbox/features/dashboard/presentation/cubit/dashboard_cubit.dart';

import '../../../../helpers/fake_prompt_repository.dart';

class _FakeClipboard extends ClipboardService {}

class MockGetDashboardStats extends Mock implements GetDashboardStats {}

class MockClipboardService extends Mock implements ClipboardService {}

DashboardStats _emptyStats() => const DashboardStats(
      totalPosts: 1,
      draftPosts: 0,
      scheduledPosts: 0,
      postedPosts: 0,
      failedPosts: 0,
      totalCommentCategories: 0,
      totalComments: 0,
      totalCopies: 0,
      totalLogs: 0,
      upcomingPosts: [],
      upcomingReminders: [],
      recentActivity: [],
      platformCounts: {},
    );

AiPromptCubit _buildAiCubit(FakePromptRepository repo) => AiPromptCubit(
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
  late MockGetDashboardStats getStats;
  late MockClipboardService clipboard;

  setUp(() {
    getStats = MockGetDashboardStats();
    clipboard = MockClipboardService();
    registerFallbackValue(const NoParams());
  });

  testWidgets('retains topic text when platform chip is tapped', (tester) async {
    final repo = FakePromptRepository();
    final cubit = _buildAiCubit(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AiPromptCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: DashboardAiWriterCard(),
            ),
          ),
        ),
      ),
    );

    const topic = 'Riverpod vs Bloc for state management';
    await tester.enterText(find.byType(TextField), topic);
    await tester.pump();

    expect(cubit.state.config.topic, topic);
    expect(find.text(topic), findsOneWidget);

    await tester.tap(find.text('X'));
    await tester.pump();

    expect(cubit.state.config.platform, 'X');
    expect(cubit.state.config.topic, topic);
    expect(find.text(topic), findsOneWidget);

    cubit.flushPersist();
    await tester.pump(const Duration(milliseconds: 500));
    await cubit.close();
  });

  testWidgets('retains topic during dashboard refresh while typing',
      (tester) async {
    when(() => getStats(any()))
        .thenAnswer((_) async => Right(_emptyStats()));

    final dashboardCubit = DashboardCubit(
      getStats: getStats,
      clipboard: clipboard,
    );
    final repo = FakePromptRepository();
    final aiCubit = _buildAiCubit(repo);
    addTearDown(dashboardCubit.close);
    addTearDown(aiCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
            BlocProvider<AiPromptCubit>.value(value: aiCubit),
          ],
          child: const Scaffold(
            body: SingleChildScrollView(
              child: DashboardAiWriterCard(),
            ),
          ),
        ),
      ),
    );

    dashboardCubit.emit(DashboardLoaded(_emptyStats()));
    await tester.pump();

    const topic = 'typing during refresh';
    await tester.enterText(find.byType(TextField), topic);
    await tester.pump();

    expect(aiCubit.state.config.topic, topic);

    await dashboardCubit.load();
    await tester.pump();

    expect(find.text(topic), findsOneWidget);
    expect(aiCubit.state.config.topic, topic);
    expect(dashboardCubit.state, isA<DashboardLoaded>());

    aiCubit.flushPersist();
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('preset cancel leaves config and text field unchanged',
      (tester) async {
    const currentTopic = 'keep this topic';
    const presetTopic = 'preset topic';
    final repo = FakePromptRepository(
      lastConfig: const PromptConfig(topic: currentTopic),
      presets: const [
        PromptPreset(
          id: 'preset-1',
          name: 'My Preset',
          config: PromptConfig(topic: presetTopic, platform: 'X'),
        ),
      ],
    );
    final cubit = _buildAiCubit(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AiPromptCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: DashboardAiWriterCard(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(currentTopic), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'My Preset'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Load preset?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(cubit.state.config.topic, currentTopic);
    expect(cubit.state.config.platform, 'LinkedIn');
    expect(find.text(currentTopic), findsOneWidget);
    expect(find.text(presetTopic), findsNothing);

    cubit.flushPersist();
    await tester.pump(const Duration(milliseconds: 500));
    await cubit.close();
  });
}