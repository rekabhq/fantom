import 'package:dio/dio.dart';

class User {}

class UserXml {}

class Error {}

class SealedPetResponse {
  final User? userApplicationJson200;
  final UserXml? userXmlApplicationXml200;
  final Error? errorApplicationJson404;

  SealedPetResponse._(
    this.userApplicationJson200,
    this.userXmlApplicationXml200,
    this.errorApplicationJson404,
  );

  void fold({
    required void Function(User) applicationJson200,
    required void Function(UserXml) applicationXml200,
    required void Function(Error) applicationJson404,
  }) {
    if (userApplicationJson200 != null) {
      applicationJson200(userApplicationJson200!);
    } else if (userXmlApplicationXml200 != null) {
      applicationXml200(userXmlApplicationXml200!);
    } else if (errorApplicationJson404 != null) {
      applicationJson404(errorApplicationJson404!);
    }
  }

  static SealedPetResponse from(Response response, String contentType) {
    if (contentType == 'application/json' && response.statusCode == 200) {
      return SealedPetResponse._(
        _deserializaFromType<User>(User, response.data),
        null,
        null,
      );
    }
    if (contentType == 'application/xml' && response.statusCode == 200) {
      return SealedPetResponse._(
        null,
        _deserializaFromType<UserXml>(UserXml, response.data),
        null,
      );
    }
    if (contentType == 'application/json' && response.statusCode == 400) {
      return SealedPetResponse._(
        null,
        null,
        _deserializaFromType<Error>(Error, response.data),
      );
    }
    throw Exception('could not create a SealedPetResponse from status code and response');
  }
}

usage() {
  final response = SealedPetResponse._(null, null, null);
  response.fold(
    applicationJson200: (user) {},
    applicationXml200: (userXml) {},
    applicationJson404: (error) {},
  );
}

void main() {
  _deserializaFromType(User, 'user object');
}

T _deserializaFromType<T extends Object>(Type type, object) {
  if (type == User) {
    print('type is User');
  } else {
    print('unknown type');
  }
  throw UnimplementedError();
}
