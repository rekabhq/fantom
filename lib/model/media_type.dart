part of 'model.dart';

class MediaType {
  final Schema? schema;

  final Map<String, Encoding>? encoding;

  const MediaType({
    required this.schema,
    required this.encoding,
  });

  factory MediaType.fromMap(Map<String, dynamic> map) {
    Schema? schema;
    Map<String, Encoding>? encoding;
    if (map.containsKey('schema')) {
      schema = Schema.fromMap(map['schema']);
    }
    if (map.containsKey('encoding')) {
      encoding = (map['encoding'] as Map<String, dynamic>).map((key, value) {
        var encoding = Encoding.fromMap(value);
        return MapEntry(key, encoding);
      });
    }

    return MediaType(
      schema: schema,
      encoding: encoding,
    );
  }
}
