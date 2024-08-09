import 'package:selecta/model/select_column.dart';
import 'package:selecta/model/select_statement.dart';

/// Create a [SelectStatement] using a builder
class SelectStatementBuilder {
  final _selectedColumns = <SelectedColumn>[];

  /// Add all columns to the select statement
  void selectAll() {
    _selectedColumns.add(AllColumns());
  }

  /// Add a specific column to the select statement
  void selectColumn(String columnName, {String? tableName}) {
    _selectedColumns.add(ColumnReference(columnName, tableName: tableName));
  }

  /// Build the [SelectStatement]
  List<SelectedColumn> build() => _selectedColumns;
}
