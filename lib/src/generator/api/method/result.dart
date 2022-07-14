import 'dart:isolate';

import 'package:dio/dio.dart';

typedef Deserializer<T> = T Function(Response value);
typedef Mapper = Exception? Function(Exception e, dynamic stacktrace);

/// [Result] contains result of a Future whether it throw an exception or awaited successfully
/// use extension function Future.toResult() to create convert a Future<T> into  a Future<Result<T,E>>
class Result<T, E extends Exception> {
  final T? _data;
  final E? _error;

  Result._(this._data, this._error);

  factory Result.error(E e) => Result._(null, e);

  factory Result.success(T value) => Result._(value, null);

  /// use this method to consume the [Result] values
  Future fold({
    required Future Function(T value) onSuccess,
    required Future Function(E error) onError,
  }) async {
    if (_data != null) {
      await onSuccess(_data!);
    } else if (_error != null) {
      await onError(_error!);
    }
  }

  bool get isFailure => _error != null;

  bool get isSuccessful => _error == null;

  T get data {
    if (isFailure) {
      throw Exception('you cannot call getter data when Result has an error '
          'please use isSuccessful to check if Result is successful and has a data ');
    }
    return _data!;
  }

  E get error {
    if (isSuccessful) {
      throw Exception('you cannot call getter error when Result isSuccessful'
          'please use isFailure to check if Result has failed and has an error ');
    }
    return _error!;
  }

  @override
  String toString() {
    return 'Result{data: $_data, error: $_error}';
  }
}

extension FutureResultExt on Future<Response> {
  /// awaits the [Future] in a try/catch and returns an instance [Result]
  /// which contains the result value of Future if awaited successfully or the exception if Future throw
  /// an exception while being awaited
  Future<Result<T, Exception>> toResult<T>(
    Deserializer<T> deserializer, [
    bool useCompute = false,
  ]) async {
    try {
      final response = await this;
      if (!useCompute || kIsJs) {
        return Result.success(deserializer(response));
      } else {
        return ResultComputer<T>(response, deserializer).compute();
      }
    } catch (e, stacktrace) {
      return _createCaughtException<T>(e, stacktrace);
    }
  }
}

Future<Result<T, Exception>> _createCaughtException<T>(
  dynamic e,
  StackTrace stacktrace,
) async {
  if (e is DioError) {
    final exception = FantomExceptionMapping._mapping?.call(e, stacktrace) ??
        FantomError(
          exception: e,
          response: e.response,
          statusCode: e.response?.statusCode,
          stacktrace: stacktrace,
        );
    return Result.error(exception);
  }
  if (e is! Exception) {
    e = Exception(e.toString());
  }
  final exception = FantomExceptionMapping._mapping?.call(e, stacktrace) ??
      FantomError(exception: e, stacktrace: stacktrace);
  return Result.error(exception);
}

class FantomError implements Exception {
  final Exception exception;
  final Response? response;
  final int? statusCode;
  final dynamic stacktrace;

  FantomError({
    required this.exception,
    this.response,
    this.statusCode,
    this.stacktrace,
  });
}

class FantomExceptionMapping {
  FantomExceptionMapping._();

  static Mapper? _mapping;

  static bool get hasMapper => _mapping != null;

  static setMapper(Mapper mapper) {
    _mapping = mapper;
  }
}

class ResultComputer<T> {
  final Response<dynamic> response;
  final Deserializer<T> deserializer;

  ResultComputer(this.response, this.deserializer);

  Future<Result<T, Exception>> compute() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_doJob, receivePort.sendPort);
    final List returnedValues = await receivePort.first;
    if (returnedValues.first is T) {
      return Result.success(returnedValues.first);
    } else {
      var e = returnedValues[0];
      if (e is! Exception) {
        e = Exception(e.toString());
      }
      return _createCaughtException(e, returnedValues[1]);
    }
  }

  Future<void> _doJob(SendPort sendPort) async {
    List returnValues = [];
    try {
      final deserializedObject = deserializer(response);
      returnValues.add(deserializedObject);
    } catch (e, stacktrace) {
      returnValues.addAll([e, stacktrace]);
    }
    Isolate.exit(sendPort, returnValues);
  }
}

/// this is hacky as F... BUUUT ...
bool get kIsJs => identical(1, 1.0);

extension FantomExceptionExt on Exception {
  bool get isFantomError => this is FantomError;
}
