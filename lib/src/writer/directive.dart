enum DirectiveType { import, export, part, partOf }

DirectiveType? _directiveTypeFrom(String string) {
  if (string == 'import') {
    return DirectiveType.import;
  }
  if (string == 'export') {
    return DirectiveType.export;
  }
  if (string == 'part') {
    return DirectiveType.part;
  }
  if (string == 'part of') {
    return DirectiveType.partOf;
  }
  return null;
}

class Directive {
  final String uri;
  final DirectiveType type;

  Directive._(this.type, this.uri);

  Directive.part(this.uri) : type = DirectiveType.part;
  Directive.partOf(this.uri) : type = DirectiveType.partOf;
  Directive.import(this.uri) : type = DirectiveType.import;
  Directive.export(this.uri) : type = DirectiveType.export;

  static Directive? tryToCreateFromLine(String line) {
    DirectiveType? type;
    String? uri;
    if (line.startsWith('import')) {
      type = _directiveTypeFrom(line.substring(0, 6));
      uri = line.substring(6);
    }
    if (line.startsWith('export')) {
      type = _directiveTypeFrom(line.substring(0, 6));
      uri = line.substring(6);
    }
    if (line.startsWith('part')) {
      type = _directiveTypeFrom(line.substring(0, 4));
      uri = line.substring(4);
    }
    if (line.startsWith('part of')) {
      type = _directiveTypeFrom(line.substring(0, 7));
      uri = line.substring(7);
    }
    if (uri == null || type == null) {
      return null;
    }
    uri = uri.replaceAll(';', '').replaceAll("'", "").trim();
    return Directive._(type, uri);
  }

  factory Directive.relative({
    required String filePath,
    required String directiveFilePath,
    required DirectiveType type,
  }) {
    filePath = filePath.replaceAll('//', '/');
    directiveFilePath = directiveFilePath.replaceAll('//', '/');
    var filePathParts = filePath.split('/');
    var directiveFilePathParts = directiveFilePath.split('/');
    bool pathsBranchFound = false;
    while (!pathsBranchFound) {
      String part1 = filePathParts[0];
      String part2 = directiveFilePathParts[0];
      if (part1 == part2) {
        filePathParts.removeAt(0);
        directiveFilePathParts.removeAt(0);
      } else {
        pathsBranchFound = true;
      }
    }
    if (directiveFilePathParts.length > filePathParts.length) {
      return Directive._(type, directiveFilePathParts.join('/'));
    } else {
      var subDirCount = filePathParts.length - directiveFilePathParts.length;
      while (subDirCount > 0) {
        directiveFilePathParts.insert(0, '..');
        subDirCount--;
      }
      return Directive._(type, directiveFilePathParts.join('/'));
    }
  }

  factory Directive.absolute({
    required String directiveFilePath,
    required DirectiveType type,
    required String package,
  }) {
    directiveFilePath = directiveFilePath.replaceAll('//', '/');
    directiveFilePath = directiveFilePath.split('lib/').last;
    final uri = 'package:$package/$directiveFilePath';
    return Directive._(type, uri);
  }

  String _getDirectiveStringValue() {
    if (type == DirectiveType.import) {
      return 'import';
    } else if (type == DirectiveType.export) {
      return 'export';
    } else if (type == DirectiveType.part) {
      return 'part';
    } else {
      return 'part of';
    }
  }

  @override
  String toString() => "${_getDirectiveStringValue()} '$uri';";

  @override
  bool operator ==(other) {
    if (other is! Directive) {
      return false;
    } else {
      return toString() == other.toString();
    }
  }

  @override
  int get hashCode => toString().hashCode;
}
