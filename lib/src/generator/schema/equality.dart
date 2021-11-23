// todo: uie, sets ?
bool deepJsonEquals(final Object? o1, final Object? o2) {
  if (identical(o1, o2)) {
    return true;
  } else if (o1 == null && o2 == null) {
    return true;
  } else if (o1 is int && o2 is int) {
    return o1 == o2;
  } else if (o1 is double && o2 is double) {
    return o1 == o2;
  } else if (o1 is bool && o2 is bool) {
    return o1 == o2;
  } else if (o1 is String && o2 is String) {
    return o1 == o2;
  } else if (o1 is List<Object?> && o2 is List<Object?>) {
    if (o1.length == o2.length) {
      for (var index = 0; index < o1.length; index++) {
        if (!deepJsonEquals(o1[index], o2[index])) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  } else if (o1 is Set<Object?> && o2 is Set<Object?>) {
    if (o1.length == o2.length) {
      final acc = Set.of(o2);
      for (final item1 in o1) {
        bool isFound = false;
        Object? found;
        for (final item2 in acc) {
          if (deepJsonEquals(item1, item2)) {
            isFound = true;
            found = item2;
            break;
          }
        }
        if (isFound) {
          acc.remove(found);
        } else {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  } else if (o1 is Map<String, Object?> && o2 is Map<String, Object?>) {
    if (o1.length == o2.length) {
      for (var key in o1.keys) {
        if (!o2.containsKey(key)) {
          return false;
        } else {
          if (!deepJsonEquals(o1[key], o2[key])) {
            return false;
          }
        }
      }
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
