part of 'model.dart';

/// checks equality through one level
bool listEquals<T extends Object?>(
  final List<T>? list1,
  final List<T>? list2,
) {
  if (identical(list1, list2)) return true;
  if (list1 == null && list2 == null) return true;
  if (list1 == null || list2 == null) return false;

  final length = list1.length;
  if (list2.length != length) return false;
  for (var index = 0; index < length; index++) {
    if (list1[index] != list2[index]) return false;
  }
  return true;
}

/// computes hash code through one level
int listHash<T extends Object?>(
  final List<T>? list,
) {
  const int mask = 0x7fffffff;

  if (list == null) return null.hashCode;

  var hash = 0;
  for (var index = 0; index < list.length; index++) {
    final c = list[index].hashCode;
    hash = (hash + c) & mask;
    hash = (hash + (hash << 10)) & mask;
    hash ^= (hash >> 6);
  }
  hash = (hash + (hash << 3)) & mask;
  hash ^= (hash >> 11);
  hash = (hash + (hash << 15)) & mask;
  return hash;
}

/// checks equality through one level
bool mapEquals<V extends Object?>(
  final Map<String, V>? map1,
  final Map<String, V>? map2,
) {
  if (identical(map1, map2)) return true;
  if (map1 == null && map2 == null) return true;
  if (map1 == null || map2 == null) return false;

  if (map2.length != map1.length) return false;
  for (final key1 in map1.keys) {
    if (!map2.containsKey(key1)) return false;
    if (map1[key1] != map2[key1]) return false;
  }
  return true;
}

/// computes hash code through one level
int mapHash<V extends Object?>(
  final Map<String, V>? map,
) {
  const int mask = 0x7fffffff;

  if (map == null) return null.hashCode;

  var hash = 0;
  for (final key in map.keys) {
    final keyHash = key.hashCode;
    final valueHash = map[key].hashCode;
    hash = (hash + 3 * keyHash + 7 * valueHash) & mask;
  }
  hash = (hash + (hash << 3)) & mask;
  hash ^= (hash >> 11);
  hash = (hash + (hash << 15)) & mask;
  return hash;
}

/// check equality for List<Object>, Map<String, Object> and non-collection Object
bool itemEquals(
  final Object? item1,
  final Object? item2,
) {
  if (identical(item1, item2)) return true;
  if (item1 == null && item2 == null) return true;
  if (item1 == null || item2 == null) return false;

  if (item1 is List<Object?> && item2 is List<Object?>) {
    return listEquals<Object?>(item1, item2);
  }

  if (item1 is Map<String, Object?> && item2 is Map<String, Object?>) {
    return mapEquals<Object?>(item1, item2);
  }

  return item1 == item2;
}

/// hashCode for List<Object>, Map<String, Object> and non-collection Object
int itemHash(
  final Object? item,
) {
  if (item == null) return null.hashCode;

  if (item is List<Object?>) {
    return listHash<Object?>(item);
  }

  if (item is Map<String, Object?>) {
    return mapHash<Object?>(item);
  }

  return item.hashCode;
}
