extension MapExt<K, V> on Map<K, V> {
  V? getValue(K key) {
    if (containsKey(key)) {
      return this[key];
    }
  }
}

extension DoubleExt on double {
  Future secondsDelay() async => Future.delayed(seconds());

  Duration seconds() => Duration(milliseconds: ((this * 1000).toInt()));

  Duration milliseconds() => Duration(milliseconds: toInt());
}

extension IntExt on int {
  Future secondsDelay() async => Future.delayed(Duration(seconds: this));

  Duration seconds() => Duration(milliseconds: this);

  Duration milliseconds() => Duration(milliseconds: this);
}

extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this?.trim().isEmpty ?? true;

  bool get isNotNullOrBlank => !isNullOrBlank;

  bool get isValidUrl {
    if (this == null) {
      return false;
    } else {
      return Uri.tryParse(this!)?.isAbsolute ?? false;
    }
  }
}

extension StringExtentions on String {
  bool isNumeric() => num.tryParse(this) != null;

  bool containsAnyOf(List<String> matches) {
    var result = false;
    for (var match in matches) {
      if (contains(match)) result = true;
    }
    return result;
  }

  bool get isValidUrl => Uri.parse(this).isAbsolute;
}
