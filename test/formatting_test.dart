import 'package:selecta/functions.dart';
import 'package:selecta/sql_parser.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Format Basic',
    () => testFormatting(
      'select * from users where id = 1 order by name desc',
      '''
SELECT\t*
FROM\tusers
WHERE\tid=1
ORDER BY\tname DESC''',
    ),
  );
}

void testFormatting(
  String inputSql,
  String expected,
) {
  final select = toSelectStatement(
    inputSql,
  );

  final formatted = statementToSql(
    select,
    allClausesFormatter: formattedAllClausesFormatter,
  );

  // ignore: avoid_print
  print(formatted);

  expect(
    formatted,
    equals(expected),
  );
}
