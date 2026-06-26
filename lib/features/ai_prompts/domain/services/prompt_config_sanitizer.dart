import '../constants/prompt_options.dart';
import '../entities/prompt_config.dart';

PromptConfig sanitizePromptConfig(PromptConfig config) {
  var postGoal = config.postGoal;
  if (!kPostGoals.contains(postGoal)) {
    if (postGoal.contains('Maximize Comments') &&
        postGoal.contains('Thought Leadership')) {
      postGoal = 'Maximize Comments + Thought Leadership';
    } else {
      postGoal = kPostGoals.first;
    }
  }

  final contentMode = config.contentMode.isEmpty
      ? ''
      : (kContentModes.contains(config.contentMode)
          ? config.contentMode
          : kContentModes.first);

  final contentPillar = config.contentPillar.isEmpty
      ? ''
      : (kContentPillars.contains(config.contentPillar)
          ? config.contentPillar
          : '');

  return config.copyWith(
    platform: PromptConfig.normalizePlatform(config.platform),
    brandArchetype: kBrandArchetypes.contains(config.brandArchetype)
        ? config.brandArchetype
        : kBrandArchetypes.first,
    postGoal: postGoal,
    contentMode: contentMode,
    contentPillar: contentPillar,
  );
}