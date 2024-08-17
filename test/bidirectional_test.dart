import 'package:selecta/functions.dart';
import 'package:selecta/model/join.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';
import 'package:selecta/sql_parser.dart';
import 'package:test/test.dart';

void testBidirectionalConversion(
  String sql, {
  String? expectedSql,
  void Function(SelectStatement)? validateStatement,
}) {
  expectedSql ??= sql;

  final selectStatement = toSelectStatement(sql);

  validateStatement?.call(selectStatement);

  final actualSql = statementToSql(selectStatement);

  expect(
    actualSql,
    expectedSql,
  );
}

void main() {
  test(
    'SELECT id, name FROM Users',
    () => testBidirectionalConversion(
      'SELECT id, name FROM Users',
    ),
  );

  test(
    'Simple SELECT *',
    () => testBidirectionalConversion(
      'SELECT * FROM Users',
      validateStatement: (ss) {
        expect(ss.select.length, 1);
        expect(ss.select.first, isA<AllColumns>());
        expect(ss.from, 'Users');
        expect(ss.where.elements, isEmpty);
        expect(ss.joins, isEmpty);
        expect(ss.orderBy, isEmpty);
      },
    ),
  );

  test(
    'SELECT with specific columns',
    () => testBidirectionalConversion(
      'SELECT id, name, email FROM Customers',
      validateStatement: (ss) {
        expect(ss.select.length, 3);
        expect(ss.select, everyElement(isA<ColumnReference>()));
        expect(
          ss.select.map((c) => (c as ColumnReference).columnName),
          ['id', 'name', 'email'],
        );
        expect(ss.from, 'Customers');
      },
    ),
  );

  test(
    'SELECT with table-qualified columns',
    () => testBidirectionalConversion(
      'SELECT Users.id, Users.name FROM Users',
      validateStatement: (ss) {
        expect(ss.select.length, 2);
        expect(ss.select, everyElement(isA<ColumnReference>()));
        expect(
          ss.select.every((c) => (c as ColumnReference).tableName == 'Users'),
          isTrue,
        );
        expect(ss.from, 'Users');
      },
    ),
  );

  test(
    'SELECT with WHERE clause',
    () => testBidirectionalConversion(
      '''SELECT * FROM Products WHERE category="Electronics" AND price>100''',
      validateStatement: (ss) {
        expect(ss.where.elements.length, 3);
        expect(ss.where.elements.first, isA<WhereCondition>());
        expect(ss.where.elements[1], equals(LogicalOperator.and));
        expect(ss.where.elements.last, isA<WhereCondition>());
        expect(ss.from, 'Products');
      },
    ),
  );

  //TODO: fix
  test(
    'SELECT with multiple conditions and grouping',
    () => testBidirectionalConversion(
      '''SELECT * FROM Employees WHERE ( department="Sales" OR department="Marketing" ) AND salary>50000''',
      validateStatement: (ss) {
        expect(ss.where.elements[0], equals(GroupingOperator.open));
        expect(
          (ss.where.elements[1] as WhereCondition).leftOperand,
          equals(const ColumnReferenceOperand('department')),
        );
        expect(ss.where.elements[2], equals(LogicalOperator.or));
        expect(ss.where.elements[4], equals(GroupingOperator.close));
        expect(ss.where.elements[5], equals(LogicalOperator.and));
        expect(ss.from, 'Employees');
        expect(ss.where.elements.length, 7);
      },
    ),
  );

  test(
    'SELECT with two columns and number WHERE clause',
    () => testBidirectionalConversion(
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
      'SELECT * FROM Products WHERE category!="Clothing"',
    ),
  );

  test(
    'SELECT with WHERE clause using LESS THAN',
    () => testBidirectionalConversion(
      'SELECT name, price FROM Products WHERE price<50',
    ),
  );

  test(
    'SELECT with WHERE clause using GREATER THAN OR EQUAL TO',
    () => testBidirectionalConversion(
      'SELECT * FROM Employees WHERE hire_date>="2023-01-01"',
    ),
  );

  test(
    'SELECT with complex WHERE clause using multiple operators',
    () => testBidirectionalConversion(
      '''SELECT * FROM Orders WHERE status="Pending" AND total>100 AND date<"2024-01-01"''',
    ),
  );

  test(
    'SELECT with WHERE clause using nested parentheses',
    () => testBidirectionalConversion(
      '''SELECT * FROM Products WHERE ( category="Electronics" AND price>500 ) OR ( category="Books" AND price<20 )''',
    ),
  );

  test(
    'SELECT with WHERE clause using multiple OR conditions',
    () => testBidirectionalConversion(
      '''SELECT name, department FROM Employees WHERE department="Sales" OR department="Marketing" OR department="IT"''',
    ),
  );

  test(
    'SELECT with WHERE clause mixing AND and OR without parentheses',
    () => testBidirectionalConversion(
      '''SELECT * FROM Customers WHERE country="USA" AND ( state="California" OR state="New York" )''',
      validateStatement: (ss) {
        expect(ss.where.elements.length, 7);
        expect(ss.orderBy.length, 0);
      },
    ),
  );

  test(
    'SELECT with WHERE clause mixing AND and OR without parentheses '
    'with ORDER BY',
    () => testBidirectionalConversion(
      '''SELECT * FROM Customers WHERE country="USA" AND ( state="California" OR state="New York" ) ORDER BY name DESC''',
    ),
  );

  test(
    'SELECT with WHERE clause using numeric comparisons',
    () => testBidirectionalConversion(
      '''SELECT product_name, stock_quantity FROM Inventory WHERE stock_quantity>0 AND stock_quantity<=100''',
    ),
  );

  test(
    'Complex SELECT with JOIN and WHERE',
    () => testBidirectionalConversion(
      '''SELECT Orders.id, Customers.name FROM Orders INNER JOIN Customers ON Orders.customer_id=Customers.id WHERE Orders.status="Shipped"''',
      validateStatement: (ss) {
        expect(ss.select.length, 2);
        expect(ss.from, 'Orders');
      },
    ),
  );

  test(
    'SELECT with ORDER BY and LIMIT',
    () => testBidirectionalConversion(
      '''SELECT name, age FROM Students WHERE age>=18 ORDER BY age DESC''',
      validateStatement: (selectStatement) {
        expect(selectStatement.orderBy.length, 1);
        final orderByColumn = selectStatement.orderBy.first as OrderByColumn;
        expect(orderByColumn.columnName, 'age');
        expect(orderByColumn.direction, SortDirection.descending);
      },
    ),
  );

  test(
    'SELECT with WHERE clause with LIKE',
    () => testBidirectionalConversion(
      'SELECT * FROM Products WHERE name LIKE "%apple%"',
      validateStatement: (ss) {
        expect(ss.from, 'Products');
        expect(ss.where.elements.length, 1);
        final whereCondition = ss.where.elements.first as WhereCondition;
        expect(whereCondition.clauseOperator, ClauseOperator.like);
        final rightOperand =
            whereCondition.rightOperand as StringLiteralOperand;
        expect(rightOperand.value, '%apple%');
      },
    ),
  );

  group('Joins', () {
    test(
      'SELECT with INNER JOIN',
      () => testBidirectionalConversion(
        'SELECT Orders.id, Customers.name FROM Orders INNER JOIN Customers ON '
        'Orders.customer_id=Customers.id',
        validateStatement: (ss) {
          expect(ss.joins.length, 1);
          expect(ss.joins.first.type, JoinType.inner);
          expect(ss.joins.first.table, 'Customers');
          expect(ss.from, 'Orders');
          expect(ss.joins.first.on.elements.length, 1);
          expect(ss.joins.first.on.elements.first, isA<WhereCondition>());
        },
      ),
    );

    test(
      'SELECT with LEFT JOIN and WHERE clause',
      () => testBidirectionalConversion(
        'SELECT Products.name, Categories.name FROM Products '
        'LEFT JOIN Categories ON Products.category_id=Categories.id '
        'WHERE Products.price>100',
        validateStatement: (ss) {
          expect(ss.joins.length, 1);
          expect(ss.joins.first.type, JoinType.left);
          expect(ss.joins.first.table, 'Categories');
          expect(ss.from, 'Products');
          expect(ss.where.elements.length, 1);
        },
      ),
    );

    test(
      'SELECT with multiple JOINs',
      () => testBidirectionalConversion(
        'SELECT Orders.id, Customers.name, Products.name FROM Orders '
        'INNER JOIN Customers ON Orders.customer_id=Customers.id '
        'INNER JOIN OrderItems ON Orders.id=OrderItems.order_id '
        'INNER JOIN Products ON OrderItems.product_id=Products.id',
        validateStatement: (ss) {
          expect(ss.joins.length, 3);
          expect(ss.joins[0].type, JoinType.inner);
          expect(ss.joins[0].table, 'Customers');
          expect(ss.joins[1].type, JoinType.inner);
          expect(ss.joins[1].table, 'OrderItems');
          expect(ss.joins[2].type, JoinType.inner);
          expect(ss.joins[2].table, 'Products');
          expect(ss.from, 'Orders');
        },
      ),
    );

    //TODO: fix this one
    test(
      'SELECT with JOIN, WHERE, and ORDER BY',
      () => testBidirectionalConversion(
        'SELECT Employees.name, Departments.name FROM Employees '
        'INNER JOIN Departments ON Employees.department_id=Departments.id '
        'WHERE Employees.salary>50000 ORDER BY Employees.name ASC',
        validateStatement: (ss) {
          expect(ss.joins.length, 1);
          expect(ss.joins.first.type, JoinType.inner);
          expect(ss.joins.first.table, 'Departments');
          expect(ss.from, 'Employees');
          expect(ss.where.elements.length, 1);
          expect(ss.orderBy.length, 1);
          final orderByColumn = ss.orderBy.first as OrderByColumn;
          expect(orderByColumn.columnName, 'name');
          expect(orderByColumn.tableName, 'Employees');
          expect(orderByColumn.direction, SortDirection.ascending);
        },
      ),
    );
  });
}
