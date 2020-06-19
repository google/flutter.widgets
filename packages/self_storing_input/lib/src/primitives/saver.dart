import 'operation_result.dart';

/// Loads and saves a value of an input widget.
abstract class Saver {
  /// Loads value  of a data item from the storage.
  ///
  /// [address] defines address of the item. It can be of any form:
  /// resource url, guid, tuple <db, table, row, column> etc.
  Future<T> load<T>(Object address);

  /// Saves value to the storage by [address].
  ///
  /// See [load] for [address].
  Future<OperationResult> save<T>(Object address, T value);

  /// Validates correctness of the value of a data item.
  ///
  /// See [load] for [address].
  OperationResult validate<T>(Object address, T value);
}

/// Trivial implementation of [Saver]. Always returns null value and
/// successful operation result.
class NoOpSaver implements Saver {
  const NoOpSaver();

  @override
  Future<T> load<T>(Object address) async => null;

  @override
  OperationResult validate<T>(Object address, T value) =>
      OperationResult.success();

  @override
  Future<OperationResult> save<T>(Object address, T value) async =>
      OperationResult.success();
}
