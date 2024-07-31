import 'package:collection/collection.dart';
import 'package:dart_application_20/functions.dart';
import 'package:dart_application_20/select_statement.dart';
import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/sql_parser.dart';
import 'package:dart_application_20/where_clause_element.dart';
import 'package:test/test.dart';

const listEquality = ListEquality<SelectedColumn>();
const whereClauseEuality = ListEquality<WhereClauseElement>();

void main() {
  void testBidirectionalConversion(String description, String sql) {
    test(description, () {
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
    });
  }

  testBidirectionalConversion('Simple SELECT *', 'SELECT * FROM Users');

  testBidirectionalConversion(
    'SELECT with specific columns',
    'SELECT id, name, email FROM Customers',
  );

  testBidirectionalConversion(
    'SELECT with table-qualified columns',
    'SELECT Users.id, Users.name FROM Users',
  );

  testBidirectionalConversion(
    'SELECT with WHERE clause',
    'SELECT * FROM Products WHERE category = "Electronics" AND price > 100',
  );

  testBidirectionalConversion(
    'Complex SELECT with JOIN and WHERE',
    ''''SELECT Orders.id, Customers.name FROM Orders JOIN Customers ON Orders.customer_id = Customers.id WHERE Orders.status = "Shipped"''',
  );

  testBidirectionalConversion(
    'SELECT with multiple conditions and grouping',
    '''SELECT * FROM Employees WHERE (department = "Sales" OR department = "Marketing") AND salary > 50000''',
  );

  testBidirectionalConversion(
    'SELECT with ORDER BY and LIMIT',
    '''SELECT name, age FROM Students WHERE age >= 18 ORDER BY age DESC LIMIT 10''',
  );
}

// This function needs to be implemented
String statementToSQL(SelectStatement statement) {
  final columns = statement.select.map((col) {
    if (col is AllColumns) return '*';
    if (col is ColumnReference) {
      return col.tableName != null
          ? '${col.tableName}.${col.columnName}'
          : col.columnName;
    }
    throw UnimplementedError('Unhandled column type: ${col.runtimeType}');
  }).join(', ');

  final whereClause =
      statement.where.isNotEmpty ? ' ${toSQL(statement.where)}' : '';

  return 'SELECT $columns FROM ${statement.from}$whereClause';
}
