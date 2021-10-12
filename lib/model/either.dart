part of 'model.dart';

class Either<Left extends Object, Right extends Object> {
  final Left? _left;

  final Right? _right;

  const Either.left(Left left)
      : _left = left,
        _right = null;

  const Either.right(Right right)
      : _left = null,
        _right = right;

  bool get isLeft => _left != null;

  Left get left => _left!;

  Left? get leftOrNull => _left;

  bool get isRight => _right != null;

  Right get right => _right!;

  Right? get rightOrNull => _right;

  R match<R extends Object?>({
    required R Function(Left left) left,
    required R Function(Right right) right,
  }) =>
      _left != null ? left(_left!) : right(_right!);
}
