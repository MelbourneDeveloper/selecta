/// Represents a column in a SQL SELECT statement.
sealed class SelectedColumn {}

/// Represents all columns in a SQL SELECT statement.
final class AllColumns extends SelectedColumn {

  /// Creates a new instance of [AllColumns].
  AllColumns([this.tableName]);

  /// The name of the table that the columns belong to.
  final String? tableName;

  @override
  String toString() =>
      // ignore: no_runtimetype_tostring
      '$runtimeType (${tableName ?? '[All]'})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllColumns &&
          runtimeType == other.runtimeType &&
          tableName == other.tableName;

  @override
  int get hashCode => Object.hash('AllColumns', tableName);
}

/// Represents a reference to a column in a SQL SELECT statement.
final class ColumnReference extends SelectedColumn {

  /// Creates a new column reference.
  ColumnReference(this.columnName, {this.tableName});

  /// The name of the column.
  final String columnName;

  /// The name of the table that the column belongs to.
  final String? tableName;

  @override
  String toString() =>
      // ignore: no_runtimetype_tostring
      '$runtimeType (${tableName != null ? '$tableName.' : ''}$columnName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnReference &&
          runtimeType == other.runtimeType &&
          columnName == other.columnName &&
          tableName == other.tableName;

  @override
  int get hashCode => Object.hash('ColumnReference', columnName, tableName);
}
