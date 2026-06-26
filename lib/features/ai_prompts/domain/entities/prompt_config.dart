import 'package:equatable/equatable.dart';

import '../../../../core/utils/platform_utils.dart';

class PromptConfig extends Equatable {
  static const aiPlatforms = ['LinkedIn', 'X', 'Facebook'];

  /// Maps [SocialPlatform] / legacy display names to AI writer dropdown values.
  static String normalizePlatform(String value) {
    final p = value.trim();
    if (aiPlatforms.contains(p)) return p;
    if (p.toLowerCase().contains('twitter') || p == 'X') return 'X';
    if (p.toLowerCase().contains('linkedin')) return 'LinkedIn';
    if (p.toLowerCase().contains('facebook')) return 'Facebook';
    return 'LinkedIn';
  }

  static String platformFromSocial(SocialPlatform platform) =>
      switch (platform) {
        SocialPlatform.facebook => 'Facebook',
        SocialPlatform.linkedin => 'LinkedIn',
        SocialPlatform.twitter => 'X',
      };

  const PromptConfig({
    this.topic = '',
    this.primaryKeyword = '',
    this.secondaryKeywords = '',
    this.platform = 'LinkedIn',
    this.targetAudience =
        'Aspiring Flutter developers, Junior Flutter engineers, Self-taught developers',
    this.brandArchetype = 'The Builder',
    this.postGoal = 'Maximize Comments + Thought Leadership',
    this.wordLimit =
        '180–280 words for technical storytelling. Under 160 for quick tips.',
    this.emojiRange = '3 to 5 (placed at emotional peaks)',
    this.hashtagRange = '5 to 7 total (3 broad + 2–4 niche)',
    this.contentMode = '',
    this.contentPillar = '',
  });

  final String topic;
  final String primaryKeyword;
  final String secondaryKeywords;
  final String platform;
  final String targetAudience;
  final String brandArchetype;
  final String postGoal;
  final String wordLimit;
  final String emojiRange;
  final String hashtagRange;
  final String contentMode;
  final String contentPillar;

  bool get isReady => topic.trim().isNotEmpty;

  PromptConfig copyWith({
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
  }) =>
      PromptConfig(
        topic: topic ?? this.topic,
        primaryKeyword: primaryKeyword ?? this.primaryKeyword,
        secondaryKeywords: secondaryKeywords ?? this.secondaryKeywords,
        platform: platform ?? this.platform,
        targetAudience: targetAudience ?? this.targetAudience,
        brandArchetype: brandArchetype ?? this.brandArchetype,
        postGoal: postGoal ?? this.postGoal,
        wordLimit: wordLimit ?? this.wordLimit,
        emojiRange: emojiRange ?? this.emojiRange,
        hashtagRange: hashtagRange ?? this.hashtagRange,
        contentMode: contentMode ?? this.contentMode,
        contentPillar: contentPillar ?? this.contentPillar,
      );

  factory PromptConfig.fromJson(Map<String, dynamic> json) => PromptConfig(
        topic: json['topic'] as String? ?? '',
        primaryKeyword: json['primaryKeyword'] as String? ?? '',
        secondaryKeywords: json['secondaryKeywords'] as String? ?? '',
        platform: normalizePlatform(json['platform'] as String? ?? 'LinkedIn'),
        targetAudience: json['targetAudience'] as String? ?? '',
        brandArchetype: json['brandArchetype'] as String? ?? 'The Builder',
        postGoal: json['postGoal'] as String? ?? '',
        wordLimit: json['wordLimit'] as String? ?? '',
        emojiRange: json['emojiRange'] as String? ?? '',
        hashtagRange: json['hashtagRange'] as String? ?? '',
        contentMode: json['contentMode'] as String? ?? '',
        contentPillar: json['contentPillar'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'primaryKeyword': primaryKeyword,
        'secondaryKeywords': secondaryKeywords,
        'platform': platform,
        'targetAudience': targetAudience,
        'brandArchetype': brandArchetype,
        'postGoal': postGoal,
        'wordLimit': wordLimit,
        'emojiRange': emojiRange,
        'hashtagRange': hashtagRange,
        'contentMode': contentMode,
        'contentPillar': contentPillar,
      };

  factory PromptConfig.fromPost({
    required String title,
    String? content,
    List<SocialPlatform>? platforms,
    List<String>? tags,
  }) {
    final platform = platforms != null && platforms.isNotEmpty
        ? platformFromSocial(platforms.first)
        : 'LinkedIn';
    final keywords = tags?.take(3).map((t) => t.replaceAll('#', '')).join(', ');
    return PromptConfig(
      topic: title,
      primaryKeyword: keywords?.split(',').first.trim() ?? '',
      secondaryKeywords: keywords ?? '',
      platform: platform,
    );
  }

  @override
  List<Object?> get props => [
        topic,
        primaryKeyword,
        secondaryKeywords,
        platform,
        targetAudience,
        brandArchetype,
        postGoal,
        wordLimit,
        emojiRange,
        hashtagRange,
        contentMode,
        contentPillar,
      ];
}

class PromptPreset extends Equatable {
  const PromptPreset({
    required this.id,
    required this.name,
    required this.config,
  });

  final String id;
  final String name;
  final PromptConfig config;

  factory PromptPreset.fromJson(Map<String, dynamic> json) => PromptPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        config: PromptConfig.fromJson(json['config'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'config': config.toJson(),
      };

  @override
  List<Object?> get props => [id, name, config];
}