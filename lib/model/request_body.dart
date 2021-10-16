part of 'model.dart';

class RequestBody {
  final Map<String, MediaType> content;

  final bool? required;

  const RequestBody({
    required this.content,
    required this.required,
  });

  factory RequestBody.fromMap(Map<String, dynamic> map) {
    // Mapping content object
    // this is a required parameter so if we have a null object we will get a error
    final content =
        (map['content'] as Map<String, dynamic>).map<String, MediaType>(
      (key, value) => MapEntry(
        key,
        MediaType.fromMap(value),
      ),
    );

    return RequestBody(
      content: content,
      required: map['required'],
    );
  }
}
