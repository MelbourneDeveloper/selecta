import 'package:selecta/model/join.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';
import 'package:selecta/sql_parser.dart';
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
      expect(result.where.elements.isEmpty, expectedWhereEmpty);

      if (validateColumns != null) {
        validateColumns(result.select);
      }

      if (validateWhere != null) {
        validateWhere(result.where.elements);
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

  test('toSelectStatement parses basic SELECT', () {
    const sql = 'SELECT id, name FROM users WHERE age > 18';
    final result = toSelectStatement(sql);

    expect(result.from, equals('users'));
    expect(result.select.length, equals(2));
    expect(result.where.elements.length, equals(1));
    expect(result.joins.isEmpty, isTrue);
  });

  test('toSelectStatement parses SELECT with JOIN', () {
    const sql =
        'SELECT users.name, orders.id FROM users JOIN orders ON users.id = '
        'orders.user_id';
    final result = toSelectStatement(sql);

    expect(result.from, equals('users'));
    expect(result.select.length, equals(2));
    expect(result.joins.length, equals(1));
    expect(result.joins.first.type, equals(JoinType.inner));
    expect(result.joins.first.table, equals('orders'));
  });

  test('parseJoinClauses handles multiple JOINs', () {
    const joinClauses =
        'JOIN orders ON users.id = orders.user_id LEFT JOIN products '
        'ON orders.product_id = products.id';
    final result = parseJoinClauses(joinClauses);

    expect(result.length, equals(2));
    expect(result[0].type, equals(JoinType.inner));
    expect(result[0].table, equals('orders'));
    expect(result[1].type, equals(JoinType.left));
    expect(result[1].table, equals('products'));
  });

  test('parseJoinClauses handles complex ON conditions', () {
    const joinClause = 'JOIN orders ON users.id = orders.user_id AND '
        'orders.status = "active"';
    final result = parseJoinClauses(joinClause);

    expect(result.length, equals(1));
    expect(result[0].type, equals(JoinType.inner));
    expect(result[0].table, equals('orders'));
    expect(
      result[0].on.elements.length,
      equals(3),
    );
  });

  group('parseOrderByClause', () {
    test('parses single column ascending', () {
      final result = parseOrderByClause('name ASC');
      expect(result.length, 1);
      expect(result[0], isA<OrderByColumn>());
      final orderByColumn = result[0] as OrderByColumn;
      expect(orderByColumn.columnName, 'name');
      expect(orderByColumn.direction, SortDirection.ascending);
      expect(orderByColumn.tableName, isNull);
    });

    test('parses single column descending', () {
      final result = parseOrderByClause('age DESC');
      expect(result.length, 1);
      expect(result[0], isA<OrderByColumn>());
      final orderByColumn = result[0] as OrderByColumn;
      expect(orderByColumn.columnName, 'age');
      expect(orderByColumn.direction, SortDirection.descending);
      expect(orderByColumn.tableName, isNull);
    });

    test('parses multiple columns', () {
      final result = parseOrderByClause('name ASC, age DESC');
      expect(result.length, 2);
      expect(result[0], isA<OrderByColumn>());
      expect(result[1], isA<OrderByColumn>());
      expect((result[0] as OrderByColumn).columnName, 'name');
      expect((result[0] as OrderByColumn).direction, SortDirection.ascending);
      expect((result[1] as OrderByColumn).columnName, 'age');
      expect((result[1] as OrderByColumn).direction, SortDirection.descending);
    });

    test('handles table-qualified columns', () {
      final result = parseOrderByClause('Users.name ASC, Orders.date DESC');
      expect(result.length, 2);
      expect(result[0], isA<OrderByColumn>());
      expect(result[1], isA<OrderByColumn>());
      expect((result[0] as OrderByColumn).columnName, 'name');
      expect((result[0] as OrderByColumn).tableName, 'Users');
      expect((result[1] as OrderByColumn).columnName, 'date');
      expect((result[1] as OrderByColumn).tableName, 'Orders');
    });

    test('defaults to ascending when direction not specified', () {
      final result = parseOrderByClause('name');
      expect(result.length, 1);
      expect((result[0] as OrderByColumn).direction, SortDirection.ascending);
    });

    test('handles mixed qualified and unqualified columns', () {
      final result = parseOrderByClause('Users.name ASC, age DESC');
      expect(result.length, 2);
      expect((result[0] as OrderByColumn).columnName, 'name');
      expect((result[0] as OrderByColumn).tableName, 'Users');
      expect((result[1] as OrderByColumn).columnName, 'age');
      expect((result[1] as OrderByColumn).tableName, isNull);
    });
  });
}
