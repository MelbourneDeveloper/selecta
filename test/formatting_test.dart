import 'package:selecta/functions.dart';
import 'package:selecta/sql_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Format Basic', () {
    final select = toSelectStatement(
      'select * from users where id = 1 order by name desc',
    );

    final formatted = statementToSql(
      select,
      allClausesFormatter: defaultAllClausesFormatter2,
    );

    expect(
      formatted,
      equals('SELECT\n'
          '\t*\n'
          'FROM\n'
          '\tusers\n'
          '\n'
          'WHERE\n'
          '\tid=1\n'
          '\n'
          'ORDER BY\n'
          '\tname DESC'),
    );

    // ignore: avoid_print
    print(formatted);
  });
}
