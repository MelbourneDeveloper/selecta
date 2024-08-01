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
        //TODO: formatting like this breaks the parser so fix the parser
        '''SELECT * FROM Products WHERE category="Electronics" AND price>100''',
        (ss) {
      expect(ss.where.length, 3);
      expect(ss.where.first, isA<WhereCondition>());
      expect(ss.from, 'Products');
    }),
  );

  test(
    'SELECT with multiple conditions and grouping',
    () => testBidirectionalConversion(
      '''SELECT * FROM Employees WHERE (department = "Sales" OR department = "Marketing") AND salary > 50000''',
      //TODO: formatting like this breaks the parser so fix the parser
      '''SELECT * FROM Employees WHERE (department="Sales" OR department="Marketing") AND salary>50000''',
    ),
  );

  test(
    'SELECT with two columns and number WHERE clause',
    () => testBidirectionalConversion(
      '''SELECT name, age FROM Students WHERE age >= 18''',
      '''SELECT name, age FROM Students WHERE age>=18''',
    ),
  );

  //TODO:
  // test(
  //   'Complex SELECT with JOIN and WHERE',
  //   () => testBidirectionalConversion(
  // ignore: lines_longer_than_80_chars
  //       ''''SELECT Orders.id, Customers.name FROM Orders JOIN Customers ON Orders.customer_id = Customers.id WHERE Orders.status = "Shipped"''',
  // ignore: lines_longer_than_80_chars
  //       '''SELECT T Orders.id, Customers.name FROM Orders JOIN Customers ON Orders.customer_id = Customers.id WHERE Ordersstatus="Shipped"''',
  //       (ss) {
  //     expect(ss.select.length, 2);
  //     expect(ss.from, 'Orders');
  //   }),
  // );

  //TODO: order by
  // test(
  //   'SELECT with ORDER BY and LIMIT',
  //   () => testBidirectionalConversion(
  // ignore: lines_longer_than_80_chars
  //     '''SELECT name, age FROM Students WHERE age >= 18 ORDER BY age DESC LIMIT 10''',
  //   ),
  // );
}
