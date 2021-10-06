extension MapExt<K, V> on Map<K, V> {
  V? getValue(K key) {
    if (containsKey(key)) {
      return this[key];
    }
  }
}
