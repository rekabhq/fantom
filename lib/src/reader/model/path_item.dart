part of 'model.dart';

class PathItem extends Equatable {
  final Operation? get;

  final Operation? put;

  final Operation? post;

  final Operation? delete;

  final Operation? options;

  final Operation? head;

  final Operation? patch;

  final Operation? trace;

  final List<ReferenceOr<Parameter>>? parameters;

  const PathItem({
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

  factory PathItem.fromMap(Map<String, dynamic> map) => PathItem(
        get: map['get'] == null ? null : Operation.fromMap(map['get']),
        put: map['put'] == null ? null : Operation.fromMap(map['put']),
        post: map['post'] == null ? null : Operation.fromMap(map['post']),
        delete: map['delete'] == null ? null : Operation.fromMap(map['delete']),
        options:
            map['options'] == null ? null : Operation.fromMap(map['options']),
        head: map['head'] == null ? null : Operation.fromMap(map['head']),
        patch: map['patch'] == null ? null : Operation.fromMap(map['patch']),
        trace: map['trace'] == null ? null : Operation.fromMap(map['trace']),
        parameters: (map['parameters'] as List<dynamic>?)?.mapToList(
          (e) => ReferenceOr.fromMap(
            e,
            builder: (m) => Parameter.fromMap(m),
          ),
        ),
      );

  @override
  List<Object?> get props => [
        get,
        put,
        post,
        delete,
        options,
        head,
        patch,
        trace,
        parameters,
      ];

  @override
  String toString() => 'PathItem{get: $get, put: $put, '
      'post: $post, delete: $delete, options: $options, '
      'head: $head, patch: $patch, trace: $trace, '
      'parameters: $parameters}';
}

extension PathItemExt on PathItem {
  Map<String, Operation> get operations {
    final resultMap = <String, Operation>{};

    final map = {
      'get': get,
      'put': put,
      'post': post,
      'delete': delete,
      'options': options,
      'head': head,
      'patch': patch,
      'trace': trace,
    };

    map.forEach((key, value) {
      if (value != null) {
        resultMap[key] = value;
      }
    });

    return resultMap;
  }
}

extension PathItemStringExt on String {
  bool get hasPathParameter => contains('{') && contains('}');

  int get countPathParameter => '{'.allMatches(this).length;
}
