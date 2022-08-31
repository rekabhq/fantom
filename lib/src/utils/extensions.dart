import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:fantom/src/utils/constants.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/utililty_functions.dart';

extension MapExt<K, V> on Map<K, V> {
  V? getValue(K key) {
    if (containsKey(key)) {
      return this[key];
    }
    return null;
  }

  bool? getBool(K key) {
    if (containsKey(key)) {
      Log.debug(this[key]);
      
      if (this[key] is bool) {
        return this[key] as bool;
      } else {
        return null;
      }
    }
    return null;
  }

  Map<K, V> clone() => Map.fromEntries(entries);

  void removeItemInNestedMapsWithKeys(Iterable<String> keys) {
    Map<K, V>? map = this;
    for (var key in keys) {
      if (key == keys.last) {
        map?.remove(key);
      } else {
        map = map?[key] as Map<K, V>?;
      }
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

  bool get isValidUrl => Uri.parse(this).isAbsolute && startsWith('http');
}

extension DirectoryExtensions on Directory {
  bool get isDartOrFlutterProject {
    var flag = false;
    var children = kCurrentDirectory.listSync();
    for (var element in children) {
      if (element.path.endsWith('pubspec.yaml')) {
        flag = true;
      }
    }
    return flag;
  }
}

extension FileExtensions on File {
  Future<bool> get isOpenApiFile async {
    try {
      var map = await readJsonOrYamlFile(this);
      if (map.containsKey('openapi')) {
        return true;
      } else {
        return false;
      }
    } catch (e, _) {
      return false;
    }
  }

  Future<bool> get isFantomConfigFile async {
    try {
      var map = await readJsonOrYamlFile(this);
      if (map.containsKey('fantom')) {
        return true;
      } else {
        return false;
      }
    } catch (e, _) {
      return false;
    }
  }
}

extension Formatter on DartFormatter {
  String tryFormat(
    String source, {
    String? fileName,
    Exception? throwException,
  }) {
    try {
      var formatted = format(source);
      return formatted;
    } catch (e, _) {
      if (throwException != null) {
        throw throwException;
      }
      return source;
    }
  }
}

extension ListExt<T> on List<T> {
  void insertAtEnd(T value) => insert(length, value);
}
