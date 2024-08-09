sealed class SelectedColumn {}

final class AllColumns extends SelectedColumn {
  AllColumns([this.tableName]);

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


final class ColumnReference extends SelectedColumn {
  ColumnReference(this.columnName, {this.tableName});
  final String columnName;
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
