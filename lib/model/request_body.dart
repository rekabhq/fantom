part of 'model.dart';

class RequestBody {
  final Map<String, MediaType> content;

  final bool? required;

  const RequestBody({
    required this.content,
    required this.required,
  });
}
