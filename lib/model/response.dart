part of 'model.dart';

class Response {
  final Map<String, Referenceable<Header>>? headers;

  final Map<String, MediaType>? content;

  const Response({
    required this.headers,
    required this.content,
  });

  factory Response.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
