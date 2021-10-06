extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this?.trim().isEmpty ?? true;

  bool get isNotNullOrBlank => !isNullOrBlank;

  bool get isValidUrl {
    if (this != null) {
      return Uri.tryParse(this!)?.isAbsolute ?? false;
    } else {
      return false;
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

  String kb2Mb() {
    var num = int.tryParse(this);
    if (num == null) {
      return this;
    } else {
      num = (num / 1000000).floor();
      return '${num}MB';
    }
  }

  String take(int count) {
    if (length > count) {
      return substring(0, count);
    } else {
      return this;
    }
  }

  bool get isValidUrl {
    if (this == 'null') {
      return false;
    }
    return Uri.parse(this).isAbsolute;
  }

  bool get isValidEmail =>
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(this);

  int? findFirstNumber() {
    for (var i = 0; i < length; i++) {
      var character = this[i];
      if (isNumeric()) {
        return int.tryParse(character);
      }
    }
    return null;
  }

  String get uppercaseFirstLetter {
    if (isEmpty) {
      return this;
    } else {
      var firstLetter = this[0];
      var fixed = replaceFirst(firstLetter, firstLetter.toUpperCase());
      return fixed;
    }
  }
}
