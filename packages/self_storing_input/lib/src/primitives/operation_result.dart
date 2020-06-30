/// Result of value validation.
class OperationResult {
  bool get isSuccess => error == null;
  final String error;

  const OperationResult.success() : error = null;

  const OperationResult.error(this.error);
}
