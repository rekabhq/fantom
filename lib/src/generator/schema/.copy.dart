class Optional<T> {
  final T value;

  const Optional(this.value);
}

extension OptionalExt<T> on T {
  Optional<T> get opt => Optional(this);
}
