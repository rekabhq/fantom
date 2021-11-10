/// helper class that help us to generate and hold operation methods name
class OperationDetail {
  final String path;
  final String operationType;
  final String? operationId;

  const OperationDetail({
    required this.path,
    required this.operationType,
    this.operationId,
  });
}

class ParameterDetails {
  final String name;
  final String methodName;

  const ParameterDetails({
    required this.name,
    required this.methodName,
  });
}

class RequestBodyDetails {
  final String methodName;
  final String contentType;

  const RequestBodyDetails({
    required this.methodName,
    required this.contentType,
  });
}
