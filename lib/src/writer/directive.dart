class Directive {
  final String uri;
  final String type;

  Directive.part(this.uri) : type = 'part ';
  Directive.partOf(this.uri) : type = 'part of ';
  Directive.import(this.uri) : type = 'import ';
  Directive.export(this.uri) : type = 'export ';

  @override
  String toString() => "$type '$uri';";
}
