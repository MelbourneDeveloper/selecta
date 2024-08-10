import 'package:selecta/builders/select_statement_builder.dart';
import 'package:selecta/functions.dart';
import 'package:test/test.dart';

void main() {
  test('Convert select all columns to SQL', () {
    final selectedColumns =
        (SelectStatementBuilder(from: 'users')..selectAll()).build();
    final sql = selectColumnsToSql(selectedColumns.select);
    expect(sql, equals('SELECT *'));
  });

  test('Convert multiple columns to SQL', () {
    final builder = SelectStatementBuilder(from: 'users')
      ..selectColumn('one')
      ..selectColumn('two');
    final selectedColumns = builder.build();
    final sql = selectColumnsToSql(selectedColumns.select);
    expect(sql, equals('SELECT one, two'));
  });
}
