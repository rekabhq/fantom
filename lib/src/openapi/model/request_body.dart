part of 'model.dart';

class RequestBody {
  final String? description;

  final Map<String, MediaType> content;

  /// described as [required] in openapi documentation
  /// but [required] is a keyword in Dart.
  final bool? isRequired;

  const RequestBody({
    required this.description,
    required this.content,
    required this.isRequired,
  });

  factory RequestBody.fromMap(Map<String, dynamic> map) => RequestBody(
        description: map['description'],
        content: (map['content'] as Map<String, dynamic>).mapValues(
          (e) => MediaType.fromMap(e),
        ),
        isRequired: map['required'],
      );
}
