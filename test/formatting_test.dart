import 'package:selecta/functions.dart';
import 'package:selecta/sql_parser.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Format Basic',
    () => testFormatting(
      'select * from users where id = 1 order by name desc',
      'SELECT *\n'
          'FROM users\n'
          'WHERE id=1\n'
          'ORDER BY name DESC',
      (
        newline: '\n',
        indent: '\t',
        uppercaseKeywords: true,
        subClauseIndent: 1,
      ),
    ),
  );

  test(
    'More Good',
    () => testFormatting(
      'SELECT Employees.name, Departments.name FROM Employees '
          'INNER JOIN Departments ON Employees.department_id=Departments.id '
          'WHERE Employees.salary>50000 ORDER BY Employees.name ASC',
      'SELECT Employees.name,\n'
          '      Departments.name\n'
          'FROM Employees\n'
          'INNER JOIN Departments\n'
          'ON Employees.department_id=Departments.id\n'
          'WHERE Employees.salary>50000\n'
          'ORDER BY Employees.name ASC',
      (newline: '\n', indent: ' ', uppercaseKeywords: true, subClauseIndent: 6),
    ),
  );
}

void testFormatting(
  String inputSql,
  String expected,
  FormattingOptions options,
) {
  final select = toSelectStatement(inputSql);
  final formatted = statementToSql(
    select,
    allClausesFormatter: (clauses) => sqlFormatter(clauses, options),
  );

  // ignore: avoid_print
  print(formatted);

  expect(formatted, equals(expected));
}
