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

extension IntExtNullable on int? {
  bool get isClientError {
    if (this == null) return false;
    return this! >= 400 && this! < 500;
  }
}
