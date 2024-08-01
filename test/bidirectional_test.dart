import 'package:dart_application_20/functions.dart';
import 'package:dart_application_20/sql_parser.dart';
import 'package:test/test.dart';

void testBidirectionalConversion(String sql, [String? expectedSql]) {
  expectedSql ??= sql;

  final statement1 = toSelectStatement(sql);

  final actualSql = statementToSQL(statement1);

  expect(
    expectedSql,
    actualSql,
  );
}

void main() {
  test(
    'Simple SELECT *',
    () => testBidirectionalConversion('SELECT * FROM Users'),
  );

  test(
    'SELECT with specific columns',
    () => testBidirectionalConversion('SELECT id, name, email FROM Customers'),
  );

  test(
    'SELECT with table-qualified columns',
    () => testBidirectionalConversion('SELECT Users.id, Users.name FROM Users'),
  );

  test(
    'SELECT with WHERE clause',
    () => testBidirectionalConversion(
      '''SELECT * FROM Products WHERE category = "Electronics" AND price > 100''',
      '''SELECT * FROM Products WHERE category="Electronics" AND price>100''',
    ),
  );

  test(
    'Complex SELECT with JOIN and WHERE',
    () => testBidirectionalConversion(
      ''''SELECT Orders.id, Customers.name FROM Orders JOIN Customers ON Orders.customer_id = Customers.id WHERE Orders.status = "Shipped"''',
    ),
  );

  test(
    'SELECT with multiple conditions and grouping',
    () => testBidirectionalConversion(
      '''SELECT * FROM Employees WHERE (department = "Sales" OR department = "Marketing") AND salary > 50000''',
    ),
  );

  test(
    'SELECT with ORDER BY and LIMIT',
    () => testBidirectionalConversion(
      '''SELECT name, age FROM Students WHERE age >= 18 ORDER BY age DESC LIMIT 10''',
    ),
  );
}
