import 'package:dart_application_20/functions.dart';
import 'package:dart_application_20/select_statement_builder.dart';
import 'package:test/test.dart';

void main() {
  test('Convert select all columns to SQL', () {
    final selectedColumns = (SelectStatementBuilder()..selectAll()).build();
    final sql = toSelectSQL(selectedColumns);
    expect(sql, equals('SELECT *'));
  });

  test('Convert multiple columns to SQL', () {
    final builder = SelectStatementBuilder()
      ..selectColumn('one')
      ..selectColumn('two');
    final selectedColumns = builder.build();
    final sql = toSelectSQL(selectedColumns);
    expect(sql, equals('SELECT one, two'));
  });
}
