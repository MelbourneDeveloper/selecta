import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/sql_parser.dart';
import 'package:dart_application_20/where_clause_element.dart';
import 'package:test/test.dart';

void main() {
  void testSelectStatement(
    String description,
    String sql, {
    required int expectedColumnCount,
    required String expectedFrom,
    required bool expectedWhereEmpty,
    void Function(List<SelectedColumn>)? validateColumns,
    void Function(List<WhereClauseElement>)? validateWhere,
  }) {
    test(description, () {
      final result = toSelectStatement(sql);

      expect(result.select.length, expectedColumnCount);
      expect(result.from, expectedFrom);
      expect(result.where.isEmpty, expectedWhereEmpty);

      if (validateColumns != null) {
        validateColumns(result.select);
      }

      if (validateWhere != null) {
        validateWhere(result.where);
      }
    });
  }

  testSelectStatement(
    'Parse simple SELECT * statement',
    'SELECT * FROM Users',
    expectedColumnCount: 1,
    expectedFrom: 'Users',
    expectedWhereEmpty: true,
    validateColumns: (columns) {
      final allColumns = columns.first as AllColumns;
      expect(allColumns.tableName, null);
      expect(allColumns.toString(), 'AllColumns ([All])');
    },
  );

  testSelectStatement(
    'Parse SELECT with specific columns',
    'SELECT id, name, email FROM Customers',
    expectedColumnCount: 3,
    expectedFrom: 'Customers',
    expectedWhereEmpty: true,
    validateColumns: (columns) {
      expect(columns.every((col) => col is ColumnReference), true);
      expect(
        columns.map((col) => (col as ColumnReference).columnName).toList(),
        ['id', 'name', 'email'],
      );
    },
  );

  testSelectStatement(
    'Parse SELECT with table-qualified columns',
    'SELECT Users.id, Users.name FROM Users',
    expectedColumnCount: 2,
    expectedFrom: 'Users',
    expectedWhereEmpty: true,
    validateColumns: (columns) {
      expect(columns.every((col) => col is ColumnReference), true);
      for (final col in columns.cast<ColumnReference>()) {
        expect(col.tableName, 'Users');
      }
      expect(
        columns.map((col) => (col as ColumnReference).columnName).toList(),
        ['id', 'name'],
      );
    },
  );

  testSelectStatement(
    'Parse SELECT with WHERE clause',
    'SELECT * FROM Products WHERE category = "Electronics" AND price > 100',
    expectedColumnCount: 1,
    expectedFrom: 'Products',
    expectedWhereEmpty: false,
    validateColumns: (columns) {
      expect(columns.first, isA<AllColumns>());
    },
    validateWhere: (where) {
      expect(where.length, 3);
      expect(where[0], isA<WhereCondition>());
      expect(where[1], equals(LogicalOperator.and));
      expect(where[2], isA<WhereCondition>());
    },
  );

  testSelectStatement(
    'Parse complex SELECT with JOIN and WHERE',
    '''SELECT Orders.id, Customers.name FROM Orders JOIN Customers ON Orders.customer_id = Customers.id WHERE Orders.status = "Shipped"''',
    expectedColumnCount: 2,
    expectedFrom: 'Orders JOIN Customers ON Orders.customer_id = Customers.id',
    expectedWhereEmpty: false,
    validateColumns: (columns) {
      expect(columns[0], isA<ColumnReference>());
      expect((columns[0] as ColumnReference).tableName, 'Orders');
      expect((columns[0] as ColumnReference).columnName, 'id');
      expect(columns[1], isA<ColumnReference>());
      expect((columns[1] as ColumnReference).tableName, 'Customers');
      expect((columns[1] as ColumnReference).columnName, 'name');
    },
    validateWhere: (where) {
      expect(where.length, 1);
      expect(where[0], isA<WhereCondition>());
    },
  );
}
