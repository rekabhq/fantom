part of 'model.dart';

class RequestBody {
  final Map<String, MediaType> content;

  final bool? required;

  const RequestBody({
    required this.content,
    required this.required,
  });

  factory RequestBody.fromMap(Map<String, dynamic> map) {
    // TODO: implement method
    throw UnimplementedError();
  }
}
