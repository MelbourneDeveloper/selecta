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
      allClausesFormatter: formattedAllClausesFormatter,
    );

    // ignore: avoid_print
    print(formatted);

//TODO: proper formatting
    expect(
      formatted,
      equals('''
SELECT\t*
FROM\tusers
WHERE\tid=1
ORDER BY\tname DESC'''),
    );
  });
}
