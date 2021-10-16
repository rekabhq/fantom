part of 'model.dart';

/// extensions for mapping maps
extension MapMappingExt<K, V> on Map<K, V> {
  /// map only values and preserve
  Map<K, U> mapValues<U>(U Function(V) mapper) => map<K, U>(
        (K key, V value) => MapEntry<K, U>(
          key,
          mapper(value),
        ),
      );
}

/// extensions for mapping lists
extension ListMappingExt<E> on List<E> {
  /// map to list
  List<T> mapToList<T>(T Function(E e) mapping) => map<T>(mapping).toList();
}
