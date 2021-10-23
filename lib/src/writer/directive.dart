enum DirectiveType { import, export, part, partOf }

class Directive {
  final String string;
  final DirectiveType type;
  Directive.import(this.string) : type = DirectiveType.import;
  Directive.export(this.string) : type = DirectiveType.export;
  Directive.part(this.string) : type = DirectiveType.part;
  Directive.partOf(this.string) : type = DirectiveType.partOf;
}
