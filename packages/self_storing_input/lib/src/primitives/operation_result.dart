/// Result of value validation.
class OperationResult {
  final bool isSuccess;
  final String error;

  OperationResult.success()
      : isSuccess = true,
        error = null;

  OperationResult.error(this.error) : isSuccess = false;
}
