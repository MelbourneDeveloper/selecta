import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/sql_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Parse simple SELECT * statement', () {
    const sql = 'SELECT * FROM Users';
    final result = toSelectStatement(sql);

    // ignore: avoid_print
    print(result.selectedColumns.first);

    expect(result.selectedColumns.length, 1);

    final allColumns = result.selectedColumns.first as AllColumns;
    expect(allColumns.tableName, null);
    expect(allColumns.toString(), 'AllColumns ([All])');
    expect(result.where, isEmpty);
  });
}
