part of 'model.dart';

class Response {
  final Map<String, Referenceable<Header>>? headers;

  final Map<String, MediaType>? content;

  const Response({
    required this.headers,
    required this.content,
  });

  factory Response.fromMap(Map<String, dynamic> map) => Response(
        headers: (map['headers'] as Map<String, dynamic>?)?.mapValues(
          (e) => Referenceable.fromMap(
            e,
            builder: (m) => Header.fromMap(m),
          ),
        ),
        content: (map['content'] as Map<String, dynamic>?)?.mapValues(
          (e) => MediaType.fromMap(e),
        ),
      );
}
