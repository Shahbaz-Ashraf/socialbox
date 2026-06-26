import '../../../../core/utils/platform_utils.dart';
import '../entities/ai_post_prefill.dart';

class ParsedAiResponse {
  const ParsedAiResponse({
    required this.content,
    this.title,
    this.tags = const [],
    this.visualIdea,
    this.seoAltText,
    this.hooks = const [],
  });

  final String content;
  final String? title;
  final List<String> tags;
  final String? visualIdea;
  final String? seoAltText;
  final List<String> hooks;

  bool get hasContent => content.trim().isNotEmpty;
}

class AiResponseParser {
  const AiResponseParser();

  ParsedAiResponse parse(String raw, {String? fallbackTitle}) {
    final text = raw.trim();
    if (text.isEmpty) {
      return const ParsedAiResponse(content: '');
    }

    final hooks = _extractHooks(text);
    final content = _extractPostContent(text) ?? text;
    final visualIdea = _extractField(text, 'Visual Idea');
    final seoAltText = _extractField(text, 'SEO Alt-Text');
    final tags = _extractHashtags(content);
    final title = _deriveTitle(content, fallbackTitle);

    return ParsedAiResponse(
      content: content.trim(),
      title: title,
      tags: tags,
      visualIdea: visualIdea,
      seoAltText: seoAltText,
      hooks: hooks,
    );
  }

  AiPostPrefill toPrefill(
    ParsedAiResponse parsed, {
    String platform = 'LinkedIn',
    String? topic,
  }) {
    final notes = <String>[
      if (parsed.visualIdea != null) 'Visual: ${parsed.visualIdea}',
      if (parsed.seoAltText != null) 'Alt-text: ${parsed.seoAltText}',
      if (parsed.hooks.isNotEmpty)
        'Hooks:\n${parsed.hooks.map((h) => '• $h').join('\n')}',
    ].join('\n');

    return AiPostPrefill(
      title: parsed.title ?? topic,
      content: parsed.content,
      tags: parsed.tags,
      platforms: [_platformFromLabel(platform)],
      notes: notes.isEmpty ? null : notes,
    );
  }

  String? _extractPostContent(String text) {
    final textBlock = RegExp(
      r'```text\s*\n([\s\S]*?)\n```',
      caseSensitive: false,
    ).firstMatch(text);
    if (textBlock != null) {
      return textBlock.group(1)?.trim();
    }

    final anyBlock = RegExp(
      r'```(?:\w+)?\s*\n([\s\S]*?)\n```',
    ).allMatches(text);
    for (final m in anyBlock) {
      final body = m.group(1)?.trim() ?? '';
      if (body.length > 40 && !body.startsWith('You are')) {
        return body;
      }
    }

    final postSection = RegExp(
      r'(?:\*\*)?📱\s*The Post(?:\*\*)?\s*\n+([\s\S]*?)(?=\n\*\*🖼️|\n---|\n\*\*✅|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (postSection != null) {
      var body = postSection.group(1)?.trim() ?? '';
      body = body.replaceAll(RegExp(r'^```\w*\n?|```$'), '').trim();
      if (body.isNotEmpty) return body;
    }

    final afterPostLabel = RegExp(
      r'The Post\s*\n+([\s\S]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (afterPostLabel != null) {
      var body = afterPostLabel.group(1)?.trim() ?? '';
      final cut = body.indexOf('**🖼️');
      if (cut > 0) body = body.substring(0, cut).trim();
      body = body.replaceAll(RegExp(r'^```\w*\n?|```$'), '').trim();
      if (body.length > 40) return body;
    }

    return null;
  }

  List<String> _extractHooks(String text) {
    final section = RegExp(
      r'🎣\s*A/B Hooks[\s\S]*?(?=📱|🖼️|\*\*📱|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (section == null) return [];

    final hooks = <String>[];
    final lines = section.group(0)!.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Hook')) {
        final hook = trimmed.replaceFirst(RegExp(r'^- Hook \d+\s*'), '').trim();
        if (hook.isNotEmpty) hooks.add(hook);
      }
    }
    return hooks;
  }

  String? _extractField(String text, String label) {
    final match = RegExp(
      '$label\\*\\*?:\\s*\\[?([^\\]\\n]+)\\]?',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }

  List<String> _extractHashtags(String content) {
    final tags = RegExp(r'#(\w+)')
        .allMatches(content)
        .map((m) => m.group(1)!)
        .toSet()
        .take(10)
        .toList();
    return tags;
  }

  String? _deriveTitle(String content, String? fallback) {
    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }
    final firstLine = content.split('\n').firstWhere(
          (l) => l.trim().isNotEmpty,
          orElse: () => '',
        );
    if (firstLine.isEmpty) return null;
    final cleaned = firstLine
        .replaceAll(RegExp(r'[^\w\s\-.,!?&]'), '')
        .trim();
    if (cleaned.length > 80) return '${cleaned.substring(0, 77)}...';
    return cleaned.isEmpty ? null : cleaned;
  }

  SocialPlatform _platformFromLabel(String label) {
    return switch (label.toLowerCase()) {
      'facebook' => SocialPlatform.facebook,
      'x' || 'twitter' => SocialPlatform.twitter,
      _ => SocialPlatform.linkedin,
    };
  }
}