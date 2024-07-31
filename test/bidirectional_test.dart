import 'package:collection/collection.dart';
import 'package:dart_application_20/functions.dart';
import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/sql_parser.dart';
import 'package:dart_application_20/where_clause_element.dart';
import 'package:test/test.dart';

const listEquality = ListEquality<SelectedColumn>();
const whereClauseEuality = ListEquality<WhereClauseElement>();

void testBidirectionalConversion(String sql) {
  // ignore: avoid_print
  print('Original:\n$sql\n');

  // SQL to SelectStatement
  final statement1 = toSelectStatement(sql);

  // SelectStatement to SQL
  final generatedSql = statementToSQL(statement1);

  // SQL back to SelectStatement
  final statement2 = toSelectStatement(generatedSql);

  // Compare the two SelectStatements
  expect(
    listEquality.equals(
      statement1.select,
      statement2.select,
    ),
    true,
  );

  // ignore: avoid_print
  print('Output:\n\n');

  // ignore: avoid_print
  print(statement1.where);
  // ignore: avoid_print
  print(statement1.select);

  expect(statement1.from, equals(statement2.from));
  expect(statement1.where.length, statement2.where.length);
  expect(
    whereClauseEuality.equals(statement1.where, statement2.where),
    true,
  );

  // Optional: Compare the generated SQL with the original
  // Note: This might fail due to formatting differences, so it's commented
  // out
  // expect(generatedSql.replaceAll(RegExp(r'\s+'), ' '), equals(sql.replaceAll(RegExp(r'\s+'), ' ')));
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
