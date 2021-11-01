/// todo copy to output

class Optional<T> {
  final T value;

  const Optional(this.value);
}

extension OptionalExt<T> on T {
  Optional<T> get opt => Optional(this);
}

class List$ {
  const List$._();

  static List<dynamic> toJson(
    final List<dynamic> json,
    final dynamic Function(dynamic json) builder,
  ) {
    return json.map(builder).toList();
  }
}
