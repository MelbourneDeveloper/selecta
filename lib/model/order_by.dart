import 'package:selecta/model/select_column.dart';

/// Represents an ORDER BY clause element
sealed class OrderByElement {}

/// Represents a column in an ORDER BY clause
class OrderByColumn implements OrderByElement {
  /// Creates a new instance of [OrderByColumn].
  OrderByColumn(
    this.columnName, {
    this.tableName,
    this.direction = SortDirection.ascending,
  });

  /// TODO: we should be able to use [ColumnReference]
  /// instead of [columnName] and [tableName]

  /// The name of the column.
  final String columnName;

  /// The name of the table that the column belongs to.
  final String? tableName;

  /// The direction to sort the column in.
  final SortDirection direction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderByColumn &&
          runtimeType == other.runtimeType &&
          columnName == other.columnName &&
          tableName == other.tableName &&
          direction == other.direction;

  @override
  int get hashCode =>
      Object.hash(runtimeType, columnName, tableName, direction);

  @override
  String toString() =>
      'OrderByColumn(columnName: $columnName, tableName: $tableName, '
      'direction: $direction)';
}

/// Represents the sort direction in an ORDER BY clause
enum SortDirection {
  /// Sort in ascending order
  ascending,

  /// Sort in descending order
  descending,
}

/// Extensions on [SortDirection].
extension OrderByColumnExtensions on OrderByColumn {
  /// Converts the [OrderByColumn] to an SQL string.
  String toSql() => direction == SortDirection.ascending ? 'ASC' : 'DESC';
}
