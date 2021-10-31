/// copied from `dart_sealed`'s `sealed_writer` library:
/// https://github.com/6thsolution/dart_sealed/blob/master/sealed_writer/lib/src/utils/string_utils.dart
/// utilities for string iterables
extension StringIterableUtils on Iterable<String> {
  /// if more than one element add trailing ','
  String joinArgs() {
    if (isEmpty) {
      return '';
    } else if (length == 1) {
      return first;
    } else {
      return join(', ') + ',';
    }
  }

  /// add ', ' between
  String joinArgsSimple() => join(', ');

  /// add ', ' between and a trailing ',' if not empty
  String joinArgsFull() {
    if (isEmpty) {
      return '';
    } else {
      return join(', ') + ',';
    }
  }

  /// add '\n\n' between
  String joinMethods() => join('\n\n');

  /// add '\n' between
  String joinLines() => join('\n');

  /// join simply
  String joinParts() => join();

  /// add '// '
  Iterable<String> addComments() => map((str) => str.addComment());

  /// add '/// '
  Iterable<String> addDocComments() => map((str) => str.addDocComment());

  /// add empty lines between
  Iterable<String> insertEmptyLinesBetween() =>
      expand((str) => [str, ''])._removeLast();

  Iterable<String> _removeLast() => isNotEmpty ? take(length - 1) : this;
}

/// copied from `dart_sealed`'s `sealed_writer` library:
/// https://github.com/6thsolution/dart_sealed/blob/master/sealed_writer/lib/src/utils/string_utils.dart
/// utilities for strings
extension StringUtils on String {
  /// add braces
  String withBraces() => '{$this}';

  /// add braces or not if empty
  String withBracesOrNot() => trim().isEmpty ? '' : withBraces();

  /// add parenthesis
  String withParenthesis() => '($this)';

  /// add <>
  String withLtGt() => '<$this>';

  /// add <> or not if empty
  String withLtGtOrNot() => trim().isEmpty ? '' : withLtGt();

  /// add '// '
  String addComment() => '// $this';

  /// add '/// '
  String addDocComment() => '/// $this';

  /// add []
  String withBraKet() => '[$this]';

  /// split lines
  List<String> splitLines() => split('\n');
}

extension StringRemovingExt on String {
  /// assert that string starts with given [start],
  /// and remove [start] from start of string.
  String removeFromStart(final String start) {
    if (!startsWith(start)) {
      throw AssertionError('string "$this" should start with "$start"!');
    }
    return substring(start.length);
  }

  /// assert and remove from last.
  String removeFromLast(final String last) {
    if (!endsWith(last)) {
      throw AssertionError('string "$this" should last with "$last"!');
    }
    return substring(0, length - last.length);
  }

  /// assert and replace from last.
  String replaceFromLast(final String last, final String replace) {
    if (!endsWith(last)) {
      throw AssertionError('string "$this" should last with "$last"!');
    }
    return substring(0, length - last.length) + replace;
  }

  /// assert and remove from last.
  String removeFromLastOrNot(final String last) {
    if (endsWith(last)) {
      return substring(0, length - last.length);
    } else {
      return this;
    }
  }

  /// assert and replace from last.
  String replaceFromLastOrNot(final String last, final String replace) {
    if (endsWith(last)) {
      return substring(0, length - last.length) + replace;
    } else {
      return this;
    }
  }
}

extension StringTypeNullablityExt on String {
  /// nullify or not
  String nullify(final bool isNullable) => isNullable ? this : '$this?';
}
