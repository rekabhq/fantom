part of 'model.dart';

class Listable<T extends Object> {
  /// should not be a collection.
  final T? _single;

  final List<T>? _list;

  const Listable.single(T single)
      : _single = single,
        _list = null;

  const Listable.list(List<T> list)
      : _single = null,
        _list = list;

  bool get isSingle => _single != null;

  T get single => _single!;

  T? get singleOrNull => _single;

  bool get isList => _list != null;

  List<T> get list => _list!;

  List<T>? get listOrNull => _list;

  R match<R extends Object?>({
    required R Function(T single) single,
    required R Function(List<T> list) list,
  }) =>
      _single != null ? single(_single!) : list(_list!);

  factory Listable.fromMap(dynamic json) => json is List<dynamic>
      ? Listable<T>.list(json.cast<T>())
      : Listable<T>.single(json as T);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Listable<T> &&
          runtimeType == other.runtimeType &&
          _single == other._single &&
          listEquals(_list, other._list);

  @override
  int get hashCode => runtimeType.hashCode ^ _single.hashCode ^ listHash(_list);
}

extension ListableExt<T extends Object> on Listable<T> {
  /// wrap listable in a list
  List<T> wrap() => match<List<T>>(
        single: (T single) => <T>[single],
        list: (List<T> list) => list,
      );
}
