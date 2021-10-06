class FantomException implements Exception {
  const FantomException(this.message, this.exitCode);

  final String message;

  final int exitCode;
}
