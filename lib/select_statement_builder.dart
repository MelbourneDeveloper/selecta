sealed class SelectedColumn {}

final class AllColumns extends SelectedColumn {
  AllColumns([this.tableName]);

  final String? tableName;

  @override
  String toString() =>
      // ignore: no_runtimetype_tostring
      '$runtimeType (${tableName ?? '[All]'})';
}

final class ColumnReference extends SelectedColumn {
  ColumnReference(this.columnName, {this.tableName});
  final String columnName;
  final String? tableName;

  @override
  String toString() =>
      // ignore: no_runtimetype_tostring
      '$runtimeType (${tableName != null ? '$tableName.' : ''}$columnName)';
}

class SelectStatementBuilder {
  final _selectedColumns = <SelectedColumn>[];

  void selectAll() {
    _selectedColumns.add(AllColumns());
  }

  void selectColumn(String columnName, {String? tableName}) {
    _selectedColumns.add(ColumnReference(columnName, tableName: tableName));
  }

  List<SelectedColumn> build() => _selectedColumns;
}
