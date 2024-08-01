import 'package:dart_application_20/functions.dart';
import 'package:dart_application_20/model/model.dart';
import 'package:dart_application_20/sql_parser.dart';
import 'package:test/test.dart';

void testBidirectionalConversion(
  String sql, [
  String? expectedSql,
  void Function(SelectStatement)? validateStatement,
]) {
  expectedSql ??= sql;

  final selectStatement = toSelectStatement(sql);

  validateStatement?.call(selectStatement);

  final actualSql = statementToSQL(selectStatement);

  expect(
    actualSql,
    expectedSql,
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
        (ss) {
      expect(ss.where.length, 3);
      expect(ss.where.first, isA<WhereCondition>());
    }),
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
      '''SELECT * FROM Employees WHERE (department="Sales" OR department="Marketing") AND salary>50000''',
    ),
  );

  test(
    'SELECT with ORDER BY and LIMIT',
    () => testBidirectionalConversion(
      '''SELECT name, age FROM Students WHERE age >= 18 ORDER BY age DESC LIMIT 10''',
    ),
  );
}
