import '../entities/prompt_config.dart';

class PromptBuilder {
  const PromptBuilder();

  String build({
    required String template,
    required PromptConfig config,
  }) {
    var result = template;

    result = _replaceLine(
      result,
      'TOPIC:',
      '[Insert Topic Here]',
      config.topic.isNotEmpty ? config.topic : '[Insert Topic Here]',
    );
    result = _replaceLine(
      result,
      'PRIMARY KEYWORD:',
      '[e.g., B2B Marketing, Python Tutorial, Leadership]',
      config.primaryKeyword.isNotEmpty
          ? config.primaryKeyword
          : '[e.g., B2B Marketing, Python Tutorial, Leadership]',
    );
    result = _replaceLine(
      result,
      'SECONDARY KEYWORDS:',
      '[e.g., lead generation, coding tips, team building]',
      config.secondaryKeywords.isNotEmpty
          ? config.secondaryKeywords
          : '[e.g., lead generation, coding tips, team building]',
    );
    result = _replaceLine(
      result,
      'PLATFORM:',
      '[LinkedIn / X / Facebook - Default: LinkedIn]',
      config.platform,
    );
    result = _replaceLine(
      result,
      'TARGET_AUDIENCE:',
      '[Aspiring Flutter developers, Junior Flutter engineers, Developers transitioning to Flutter, Self-taught developers from emerging countries,  Startup Founders, Burned-out Professionals, IT Professionals, Professionals navigating office politic, Computer Science Students, Global tech community]',
      config.targetAudience,
    );
    result = _replaceLine(
      result,
      'BRAND_ARCHETYPE:',
      '[The Builder (practical, honest journey) or The Mentor (helpful, experienced guide). Prefer "The Builder" for personal story posts and "The Mentor" for teaching posts.,  The Rebel (contrarian), The Sage (educational), The Everyman (relatable)]',
      config.brandArchetype,
    );
    result = _replaceLine(
      result,
      'POST_GOAL:',
      '[Maximize Comments / Maximize Saves / Thought Leadership / Emotional Connection / Build genuine relationships with developers + Maximize Saves + Thought Leadership. Prioritize comments that lead to real conversations.]',
      config.postGoal,
    );
    result = _replaceLine(
      result,
      'WORD_LIMIT:',
      '- WORD_LIMIT: 180–280 words for technical storytelling posts. Keep under 160 words only for quick tips or hot takes. Quality and depth matter more for developer audience.',
      config.wordLimit,
    );
    result = _replaceLine(
      result,
      'EMOJIS:',
      '3 to 5 (placed at emotional peaks)',
      config.emojiRange,
    );
    result = _replaceLine(
      result,
      'HASHTAGS:',
      '5 to 7 total (3 broad + 2–4 niche)',
      config.hashtagRange,
    );

    if (config.contentMode.isNotEmpty &&
        config.contentMode != 'Auto (based on topic)') {
      result =
          '$result\n\n### SELECTED CONTENT MODE\nPrefer: **${config.contentMode}**';
    }

    if (config.contentPillar.isNotEmpty) {
      result =
          '$result\n\n### SELECTED CONTENT PILLAR\nFocus on: **${config.contentPillar}**';
    }

    if (config.topic.isNotEmpty) {
      result =
          '$result\n\n---\n\n**ACTIVE TOPIC:** ${config.topic}\n\nGenerate the post now using the configuration above.';
    }

    return result;
  }

  String _replaceLine(
    String text,
    String key,
    String oldValue,
    String newValue,
  ) {
    final pattern = '- $key $oldValue';
    final replacement = '- $key $newValue';
    if (text.contains(pattern)) {
      return text.replaceFirst(pattern, replacement);
    }
    return text;
  }
}