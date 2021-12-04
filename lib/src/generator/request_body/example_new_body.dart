//TODO- just remove this

class User {}

class UserRequestBody {
  final User? jsonBody;
  final User? anyBody;
  final dynamic customBody;

  UserRequestBody.body(this.jsonBody)
      : anyBody = null,
        customBody = null;

  UserRequestBody.xmlJson(this.anyBody)
      : jsonBody = null,
        customBody = null;

  UserRequestBody.customBody(this.customBody)
      : anyBody = null,
        jsonBody = null;

  dynamic toBody() {
    if (jsonBody != null) {
      // serialize to json and return
    }
    if (anyBody != null) {
      // serialize to json and return
    }
    if (customBody != null) {
      // just return
    }
  }
}
