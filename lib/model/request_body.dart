part of 'model.dart';

class RequestBody {
  final String? description;

  final Map<String, MediaType> content;

  final bool? required;

  const RequestBody({
    required this.description,
    required this.content,
    required this.required,
  });
}
