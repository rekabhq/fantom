part of 'model.dart';

class Response {
  final Map<String, Either<Header, Reference<Header>>>? headers;

  final Map<String, MediaType>? content;

  const Response({
    required this.headers,
    required this.content,
  });
}
