/// [UserRequestBody] {
///
/// ([WeatherSunny] sunny){} with identity equality
///
/// ([WeatherRainy] rainy){[int] rain} with identity equality
///
/// }
abstract class UserRequestBody {
  const UserRequestBody._internal();

  const factory UserRequestBody.sunny() = WeatherSunny;

  const factory UserRequestBody.rainy({
    required int rain,
  }) = WeatherRainy;

  bool get isSunny => this is WeatherSunny;

  bool get isRainy => this is WeatherRainy;

  WeatherSunny get asSunny => this as WeatherSunny;

  WeatherRainy get asRainy => this as WeatherRainy;

  WeatherSunny? get asSunnyOrNull {
    final userRequestBody = this;
    return userRequestBody is WeatherSunny ? userRequestBody : null;
  }

  WeatherRainy? get asRainyOrNull {
    final userRequestBody = this;
    return userRequestBody is WeatherRainy ? userRequestBody : null;
  }

  R when<R extends Object?>({
    required R Function() sunny,
    required R Function(int rain) rainy,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      return sunny();
    } else if (userRequestBody is WeatherRainy) {
      return rainy(userRequestBody.rain);
    } else {
      throw AssertionError();
    }
  }

  R maybeWhen<R extends Object?>({
    R Function()? sunny,
    R Function(int rain)? rainy,
    required R Function(UserRequestBody userRequestBody) orElse,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      return sunny != null ? sunny() : orElse(userRequestBody);
    } else if (userRequestBody is WeatherRainy) {
      return rainy != null
          ? rainy(userRequestBody.rain)
          : orElse(userRequestBody);
    } else {
      throw AssertionError();
    }
  }

  @Deprecated('Use `whenOrNull` instead. Will be removed by next release.')
  void partialWhen({
    void Function()? sunny,
    void Function(int rain)? rainy,
    void Function(UserRequestBody userRequestBody)? orElse,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      if (sunny != null) {
        sunny();
      } else if (orElse != null) {
        orElse(userRequestBody);
      }
    } else if (userRequestBody is WeatherRainy) {
      if (rainy != null) {
        rainy(userRequestBody.rain);
      } else if (orElse != null) {
        orElse(userRequestBody);
      }
    } else {
      throw AssertionError();
    }
  }

  R? whenOrNull<R extends Object?>({
    R Function()? sunny,
    R Function(int rain)? rainy,
    R Function(UserRequestBody userRequestBody)? orElse,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      return sunny != null ? sunny() : orElse?.call(userRequestBody);
    } else if (userRequestBody is WeatherRainy) {
      return rainy != null
          ? rainy(userRequestBody.rain)
          : orElse?.call(userRequestBody);
    } else {
      throw AssertionError();
    }
  }

  R map<R extends Object?>({
    required R Function(WeatherSunny sunny) sunny,
    required R Function(WeatherRainy rainy) rainy,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      return sunny(userRequestBody);
    } else if (userRequestBody is WeatherRainy) {
      return rainy(userRequestBody);
    } else {
      throw AssertionError();
    }
  }

  R maybeMap<R extends Object?>({
    R Function(WeatherSunny sunny)? sunny,
    R Function(WeatherRainy rainy)? rainy,
    required R Function(UserRequestBody userRequestBody) orElse,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      return sunny != null ? sunny(userRequestBody) : orElse(userRequestBody);
    } else if (userRequestBody is WeatherRainy) {
      return rainy != null ? rainy(userRequestBody) : orElse(userRequestBody);
    } else {
      throw AssertionError();
    }
  }

  @Deprecated('Use `mapOrNull` instead. Will be removed by next release.')
  void partialMap({
    void Function(WeatherSunny sunny)? sunny,
    void Function(WeatherRainy rainy)? rainy,
    void Function(UserRequestBody userRequestBody)? orElse,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      if (sunny != null) {
        sunny(userRequestBody);
      } else if (orElse != null) {
        orElse(userRequestBody);
      }
    } else if (userRequestBody is WeatherRainy) {
      if (rainy != null) {
        rainy(userRequestBody);
      } else if (orElse != null) {
        orElse(userRequestBody);
      }
    } else {
      throw AssertionError();
    }
  }

  R? mapOrNull<R extends Object?>({
    R Function(WeatherSunny sunny)? sunny,
    R Function(WeatherRainy rainy)? rainy,
    R Function(UserRequestBody userRequestBody)? orElse,
  }) {
    final userRequestBody = this;
    if (userRequestBody is WeatherSunny) {
      return sunny != null
          ? sunny(userRequestBody)
          : orElse?.call(userRequestBody);
    } else if (userRequestBody is WeatherRainy) {
      return rainy != null
          ? rainy(userRequestBody)
          : orElse?.call(userRequestBody);
    } else {
      throw AssertionError();
    }
  }
}

/// (([WeatherSunny] : [UserRequestBody]) sunny){}
///
/// with identity equality
class WeatherSunny extends UserRequestBody {
  const WeatherSunny() : super._internal();

  @override
  String toString() => 'UserRequestBody.sunny()';
}

/// (([WeatherRainy] : [UserRequestBody]) rainy){[int] rain}
///
/// with identity equality
class WeatherRainy extends UserRequestBody {
  const WeatherRainy({
    required this.rain,
  }) : super._internal();

  final int rain;

  @override
  String toString() => 'UserRequestBody.rainy(rain: $rain)';
}
