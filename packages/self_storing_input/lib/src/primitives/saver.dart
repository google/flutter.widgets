import 'operation_result.dart';

/// Loads and saves a value of an input widget.
abstract class Saver {
  /// Loads the value  of a data item from the storage.
  ///
  /// [itemKey] identifies the data item. [itemKey] can be of any form:
  /// resource url, guid, tuple <db, table, row, column> etc.
  Future<T> load<T>(Object itemKey);

  /// Saves a value to the storage by [itemKey].
  ///
  /// See [load] for [itemKey].
  Future<OperationResult> save<T>(Object itemKey, T value);

  /// Validates whether [value] is allowed to be stored for [itemKey].
  /// Disallowed values will not be passed to [save].
  ///
  /// Use this method only for synchronous validation,
  /// as asynchronous validation should be done in [save].
  ///
  /// See [load] for [itemKey].
  OperationResult validate<T>(Object itemKey, T value);
}

/// Trivial implementation of [Saver]. Always returns null value and
/// successful operation result.
class NoOpSaver implements Saver {
  const NoOpSaver();

  @override
  Future<T> load<T>(Object itemKey) async => null;

  @override
  OperationResult validate<T>(Object itemKey, T value) =>
      OperationResult.success();

  @override
  Future<OperationResult> save<T>(Object itemKey, T value) async =>
      OperationResult.success();
}
