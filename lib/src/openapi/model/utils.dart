part of 'model.dart';

/// extensions for mapping maps
extension MapMappingExt<K, V> on Map<K, V> {
  /// map only values and preserve
  Map<K, U> mapValues<U>(U Function(V e) mapper) => map<K, U>(
        (K key, V value) => MapEntry<K, U>(
          key,
          mapper(value),
        ),
      );
}

/// extensions for mapping Iterables
extension IterableMappingExt<E> on Iterable<E> {
  /// map to list
  List<T> mapToList<T>(T Function(E e) mapping) => map<T>(mapping).toList();
}
