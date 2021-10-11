part of 'model.dart';

class Response {
  final Map<String, Header> headers;

  final Map<String, MediaType> content;

  const Response({
    required this.headers,
    required this.content,
  });
}
