part of 'model.dart';

class MediaType {
  final Schema? schema;

  final Map<String, Encoding>? encoding;

  const MediaType({
    required this.schema,
    required this.encoding,
  });

  factory MediaType.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
