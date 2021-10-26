// path - /pet
// method - POST
//TODO: this file & sample.json should be deleted later on
abstract class PostPetBody {
  void postPetApplicationJson(String body);

  void postPetApplicationXml(PostPetApplicationJsonXml body);

  void postPetPlainText(User body);

  void postPetFormUrlEncoded(dynamic body);

  void postPetImageDefault(dynamic body);

  void postPetDefault(dynamic body);
}

class PostPetApplicationJsonXml {}

class User {}
