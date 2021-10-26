// path - /pet
// method - POST

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
