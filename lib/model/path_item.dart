part of 'model.dart';

class PathItem {
  final String? ref;

  final Operation? get;

  final Operation? put;

  final Operation? post;

  final Operation? delete;

  final Operation? options;

  final Operation? head;

  final Operation? patch;

  final Operation? trace;

  // TODO: check the documentation for the implementing this property
  final List<Parameter>? parameters;

  const PathItem({
    required this.ref,
    required this.get,
    required this.put,
    required this.post,
    required this.delete,
    required this.options,
    required this.head,
    required this.patch,
    required this.trace,
    required this.parameters,
  });
}
