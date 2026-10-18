final _liPattern = RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true, caseSensitive: false);
final _tagPattern = RegExp(r'<[^>]+>');
final _whitespacePattern = RegExp(r'\s+');

const _htmlEntities = {
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
  '&apos;': "'",
  '&nbsp;': ' ',
};

String _stripTags(String input) {
  var text = input.replaceAll(_tagPattern, ' ');
  _htmlEntities.forEach((entity, replacement) => text = text.replaceAll(entity, replacement));
  return text.replaceAll(_whitespacePattern, ' ').trim();
}

/// Extracts plain-text bullet lines out of an advisory `<ul><li>...</li></ul>`
/// HTML string. Falls back to the whole string (tags stripped) as a single
/// bullet when there's no `<li>` markup to split on.
List<String> parseHtmlBullets(String html) {
  if (html.trim().isEmpty) return const [];

  final items = _liPattern
      .allMatches(html)
      .map((m) => _stripTags(m.group(1) ?? ''))
      .where((s) => s.isNotEmpty)
      .toList();
  if (items.isNotEmpty) return items;

  final stripped = _stripTags(html);
  return stripped.isEmpty ? const [] : [stripped];
}
