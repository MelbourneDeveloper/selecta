import 'package:selecta/functions.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/sql_parser.dart';
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
  test('asdsd', () {
    final selectStatement = toSelectStatement('SELECT id, name FROM Users');
    // ignore: avoid_print
    print('Columns: ${selectStatement.select} From: ${selectStatement.from}');
  });

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

  test(
    'SELECT with multiple table-qualified columns',
    () => testBidirectionalConversion(
      'SELECT Users.id, Users.name, Users.email FROM Users',
    ),
  );

  test(
    'SELECT with mixed qualified and unqualified columns',
    () => testBidirectionalConversion(
      'SELECT Users.id, name, Users.email FROM Users',
    ),
  );

  test(
    'SELECT with WHERE clause using NOT EQUALS',
    () => testBidirectionalConversion(
      'SELECT * FROM Products WHERE category != "Clothing"',
      'SELECT * FROM Products WHERE category!="Clothing"',
    ),
  );

  test(
    'SELECT with WHERE clause using LESS THAN',
    () => testBidirectionalConversion(
      'SELECT name, price FROM Products WHERE price < 50',
      'SELECT name, price FROM Products WHERE price<50',
    ),
  );

  test(
    'SELECT with WHERE clause using GREATER THAN OR EQUAL TO',
    () => testBidirectionalConversion(
      'SELECT * FROM Employees WHERE hire_date >= "2023-01-01"',
      'SELECT * FROM Employees WHERE hire_date>="2023-01-01"',
    ),
  );

  test(
    'SELECT with complex WHERE clause using multiple operators',
    () => testBidirectionalConversion(
      '''SELECT * FROM Orders WHERE status = "Pending" AND total > 100 AND date < "2024-01-01"''',
      '''SELECT * FROM Orders WHERE status="Pending" AND total>100 AND date<"2024-01-01"''',
    ),
  );

  test(
    'SELECT with WHERE clause using nested parentheses',
    () => testBidirectionalConversion(
      '''SELECT * FROM Products WHERE (category = "Electronics" AND price > 500) OR (category = "Books" AND price < 20)''',
      '''SELECT * FROM Products WHERE (category="Electronics" AND price>500) OR (category="Books" AND price<20)''',
    ),
  );

  test(
    'SELECT with WHERE clause using multiple OR conditions',
    () => testBidirectionalConversion(
      '''SELECT name, department FROM Employees WHERE department = "Sales" OR department = "Marketing" OR department = "IT"''',
      '''SELECT name, department FROM Employees WHERE department="Sales" OR department="Marketing" OR department="IT"''',
    ),
  );

  //TODO: get this passing
  test(
    '🪲 - SELECT with WHERE clause mixing AND and OR without parentheses',
    () => testBidirectionalConversion(
      '''SELECT * FROM Customers WHERE country = "USA" AND (state = "California" OR state = "New York")''',
      '''SELECT * FROM Customers WHERE country="USA" AND (state="California" OR state="New York")''',
    ),
  );

  test(
    'SELECT with WHERE clause using numeric comparisons',
    () => testBidirectionalConversion(
      '''SELECT product_name, stock_quantity FROM Inventory WHERE stock_quantity > 0 AND stock_quantity <= 100''',
      '''SELECT product_name, stock_quantity FROM Inventory WHERE stock_quantity>0 AND stock_quantity<=100''',
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
