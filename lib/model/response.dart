part of 'model.dart';

class Response {
  final Map<String, Referenceable<Header>>? headers;

  final Map<String, MediaType>? content;

  const Response({
    required this.headers,
    required this.content,
  });

  factory Response.fromMap(Map<String, dynamic> map) {
    // Mapping headers object
    final headers = map['headers'] == null
        ? null
        : (map['headers'] as Map<String, dynamic>).map<String, Referenceable<Header>>(
            (key, value) => MapEntry(
              key,
              !value.contain('\$ref')
                  ? Referenceable.left(Header.fromMap(value))
                  : Referenceable.right(Reference.fromMap(value)),
            ),
          );

    // Mapping content object
    final content = map['content'] == null
        ? null
        : (map['content'] as Map<String, dynamic>).map<String, MediaType>(
            (key, value) => MapEntry(key, MediaType.fromMap(value)),
          );

    return Response(headers: headers, content: content);
  }
}
