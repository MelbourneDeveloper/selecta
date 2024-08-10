import 'package:selecta/builders/join_builder.dart';
import 'package:selecta/builders/order_by_builder.dart';
import 'package:selecta/builders/select_statement_builder.dart';
import 'package:selecta/builders/where_clause_builder.dart';
import 'package:selecta/functions.dart';
import 'package:selecta/model/model.dart';
import 'package:test/test.dart';

const name = ColumnReferenceOperand('NAME');
const id = ColumnReferenceOperand('ID');

void main() {
  test('Go', () {
    final whereClause = WhereClauseGroup(
      [
        WhereCondition(
          const ColumnReferenceOperand('NAME'),
          ClauseOperator.equals,
          StringLiteralOperand('JIM'),
        ),
        LogicalOperator.and,
        GroupingOperator.open,
        WhereCondition(
          const ColumnReferenceOperand('ID'),
          ClauseOperator.equals,
          NumberLiteralOperand(123),
        ),
        LogicalOperator.or,
        WhereCondition(
          const ColumnReferenceOperand('ID'),
          ClauseOperator.equals,
          NumberLiteralOperand(321),
        ),
        GroupingOperator.close,
      ],
    );

    final sql = whereClauseGroupToSQL(whereClause);

    expect(sql, 'NAME="JIM" AND ( ID=123 OR ID=321 )');
  });

  test('Builder Go', () {
    final builder = WhereClauseBuilder()
      ..equalsText(
        name,
        'JIM',
      )
      ..and()
      ..openBracket()
      ..equalsNumber(
        id,
        123,
      )
      ..or()
      ..equalsNumber(
        id,
        321,
      )
      ..closeBracket();

    final sql = whereClauseGroupToSQL(builder.build());

    expect(sql, 'NAME="JIM" AND ( ID=123 OR ID=321 )');
  });

  group('whereClauseGroupToSQL', () {
    test('handles simple conditions', () {
      final group = WhereClauseGroup([
        WhereCondition(
          const ColumnReferenceOperand('age'),
          ClauseOperator.greaterThan,
          NumberLiteralOperand(18),
        ),
      ]);
      expect(whereClauseGroupToSQL(group), 'age>18');
    });

    test('handles multiple conditions with logical operators', () {
      final group = WhereClauseGroup([
        WhereCondition(
          const ColumnReferenceOperand('age'),
          ClauseOperator.greaterThan,
          NumberLiteralOperand(18),
        ),
        LogicalOperator.and,
        WhereCondition(
          const ColumnReferenceOperand('name'),
          ClauseOperator.equals,
          StringLiteralOperand('John'),
        ),
      ]);
      expect(whereClauseGroupToSQL(group), 'age>18 AND name="John"');
    });

    test('handles nested groups', () {
      final group = WhereClauseGroup([
        WhereClauseGroup([
          WhereCondition(
            const ColumnReferenceOperand('age'),
            ClauseOperator.greaterThan,
            NumberLiteralOperand(18),
          ),
          LogicalOperator.or,
          WhereCondition(
            const ColumnReferenceOperand('status'),
            ClauseOperator.equals,
            StringLiteralOperand('adult'),
          ),
        ]),
        LogicalOperator.and,
        WhereCondition(
          const ColumnReferenceOperand('country'),
          ClauseOperator.equals,
          StringLiteralOperand('USA'),
        ),
      ]);
      expect(
        whereClauseGroupToSQL(group),
        '(age>18 OR status="adult") AND country="USA"',
      );
    });
  });

  group('OrderByBuilder and SQL generation tests', () {
    test('Simple ascending order', () {
      final builder = SelectStatementBuilder(from: 'Users')
        ..selectColumn('name')
        ..orderBy.asc('name');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT name FROM Users ORDER BY name ASC',
      );
    });

    test('Simple descending order', () {
      final builder = SelectStatementBuilder(from: 'Products')
        ..selectColumn('price')
        ..orderBy.desc('price');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT price FROM Products ORDER BY price DESC',
      );
    });

    test('Multiple columns order', () {
      final builder = SelectStatementBuilder(from: 'Employees')
        ..selectColumn('lastName')
        ..selectColumn('firstName')
        ..orderBy.asc('lastName')
        ..orderBy.asc('firstName');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT lastName, firstName FROM Employees '
        'ORDER BY lastName ASC, firstName ASC',
      );
    });

    test('Mixed ascending and descending order', () {
      final builder = SelectStatementBuilder(from: 'Orders')
        ..selectColumn('orderDate')
        ..selectColumn('total')
        ..orderBy.desc('orderDate')
        ..orderBy.asc('total');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT orderDate, total FROM Orders '
        'ORDER BY orderDate DESC, total ASC',
      );
    });

    test('Order with table name', () {
      final builder = SelectStatementBuilder(from: 'Users')
        ..selectColumn('name', tableName: 'Users')
        ..orderBy.ascWithTable('Users', 'name');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Users.name FROM Users ORDER BY Users.name ASC',
      );
    });

    test('Complex order with multiple tables', () {
      final builder = SelectStatementBuilder(from: 'Orders')
        ..selectColumn('orderDate', tableName: 'Orders')
        ..selectColumn('name', tableName: 'Customers')
        ..orderBy.descWithTable('Orders', 'orderDate')
        ..orderBy.ascWithTable('Customers', 'name');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Orders.orderDate, Customers.name FROM '
        'Orders ORDER BY Orders.orderDate DESC, Customers.name ASC',
      );
    });

    test('Order by with WHERE clause', () {
      final builder = SelectStatementBuilder(from: 'Products')
        ..selectColumn('name')
        ..selectColumn('price')
        ..where
            .equalsText(const ColumnReferenceOperand('category'), 'Electronics')
        ..orderBy.desc('price');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT name, price FROM Products WHERE category="Electronics" '
        'ORDER BY price DESC',
      );
    });

    test('Order by with complex WHERE clause', () {
      final builder = SelectStatementBuilder(from: 'Employees')
        ..selectColumn('name')
        ..selectColumn('salary')
        ..where.openBracket()
        ..where.equalsText(const ColumnReferenceOperand('department'), 'Sales')
        ..where.or()
        ..where
            .equalsText(const ColumnReferenceOperand('department'), 'Marketing')
        ..where.closeBracket()
        ..where.and()
        ..where.condition(
          const ColumnReferenceOperand('salary'),
          ClauseOperator.greaterThan,
          NumberLiteralOperand(50000),
        )
        ..orderBy.desc('salary')
        ..orderBy.asc('name');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT name, salary FROM Employees WHERE ( department="Sales" OR '
        'department="Marketing" ) AND salary>50000 '
        'ORDER BY salary DESC, name ASC',
      );
    });

    test('Order by with all columns selected', () {
      final builder = SelectStatementBuilder(from: 'Users')
        ..selectAll()
        ..orderBy.asc('registrationDate')
        ..orderBy.desc('lastLoginDate');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT * FROM Users ORDER BY registrationDate ASC, lastLoginDate DESC',
      );
    });

    test('Order by with no columns (should not generate ORDER BY clause)', () {
      final builder = SelectStatementBuilder(from: 'Logs')
        ..selectColumn('message');
      final statement = builder.build();
      expect(statementToSql(statement), 'SELECT message FROM Logs');
    });

    test('Order by with repeated columns (should allow and not deduplicate)',
        () {
      final builder = SelectStatementBuilder(from: 'Transactions')
        ..selectColumn('amount')
        ..orderBy.asc('amount')
        ..orderBy.desc('amount');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT amount FROM Transactions ORDER BY amount ASC, amount DESC',
      );
    });

    test('Order by with case-insensitive column names', () {
      final builder = SelectStatementBuilder(from: 'Users')
        ..selectColumn('Name')
        ..orderBy.asc('name');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Name FROM Users ORDER BY name ASC',
      );
    });

    test('Order by with numeric column name', () {
      final builder = SelectStatementBuilder(from: 'Data')
        ..selectColumn('1stColumn')
        ..orderBy.desc('1stColumn');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT 1stColumn FROM Data ORDER BY 1stColumn DESC',
      );
    });

    //It's questionable what should happen
    // test('Order by with quoted column names', () {
    //   final builder = SelectStatementBuilder(from: 'Weird Table')
    //     ..selectColumn('Weird Column')
    //     ..orderBy.asc('Weird Column');
    //   final statement = builder.build();
    //   expect(
    //     statementToSQL(statement),
    //     'SELECT Weird Column FROM Weird Table ORDER BY Weird Column ASC',
    //   );
    // });

    test('Stress test with many order by columns', () {
      final builder = SelectStatementBuilder(from: 'BigTable');
      for (var i = 1; i <= 20; i++) {
        builder.selectColumn('col$i');
        builder.orderBy.asc('col$i');
      }
      final statement = builder.build();
      final expectedColumns =
          List.generate(20, (i) => 'col${i + 1}').join(', ');
      final expectedOrderBy =
          List.generate(20, (i) => 'col${i + 1} ASC').join(', ');
      expect(
        statementToSql(statement),
        'SELECT $expectedColumns FROM BigTable ORDER BY $expectedOrderBy',
      );
    });
  });

  group('JoinBuilder tests', () {
    test('Simple INNER JOIN', () {
      final builder = SelectStatementBuilder(from: 'Users')
        ..selectColumn('Users.name')
        ..selectColumn('Orders.id')
        ..join.innerJoin(
          table: 'Orders',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Users.id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Orders.user_id'),
            ),
          ]),
        );
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Users.name, Orders.id FROM Users INNER JOIN Orders ON '
        'Users.id=Orders.user_id',
      );
    });

    test('LEFT JOIN with multiple conditions', () {
      final builder = SelectStatementBuilder(from: 'Products')
        ..selectColumn('Products.name')
        ..selectColumn('Categories.name', tableName: 'category_name')
        ..join.leftJoin(
          table: 'Categories',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Products.category_id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Categories.id'),
            ),
            LogicalOperator.and,
            WhereCondition(
              const ColumnReferenceOperand('Categories.active'),
              ClauseOperator.equals,
              NumberLiteralOperand(1),
            ),
          ]),
        );
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Products.name, category_name.Categories.name FROM Products '
        'LEFT JOIN Categories ON Products.category_id=Categories.id AND '
        'Categories.active=1',
      );
    });

    test('Multiple JOINs', () {
      final builder = SelectStatementBuilder(from: 'Orders')
        ..selectColumn('Orders.id')
        ..selectColumn('Customers.name')
        ..selectColumn('Products.name', tableName: 'product_name')
        ..join.innerJoin(
          table: 'Customers',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Orders.customer_id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Customers.id'),
            ),
          ]),
        )
        ..join.leftJoin(
          table: 'OrderItems',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Orders.id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('OrderItems.order_id'),
            ),
          ]),
        )
        ..join.innerJoin(
          table: 'Products',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('OrderItems.product_id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Products.id'),
            ),
          ]),
        );
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Orders.id, Customers.name, product_name.Products.name '
        'FROM Orders INNER JOIN Customers ON '
        'Orders.customer_id=Customers.id LEFT JOIN OrderItems ON '
        'Orders.id=OrderItems.order_id INNER JOIN Products ON '
        'OrderItems.product_id=Products.id',
      );
    });

    test('JOIN with WHERE clause', () {
      final builder = SelectStatementBuilder(from: 'Employees')
        ..selectColumn('Employees.name')
        ..selectColumn('Departments.name', tableName: 'department_name')
        ..join.innerJoin(
          table: 'Departments',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Employees.department_id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Departments.id'),
            ),
          ]),
        )
        ..where.condition(
          const ColumnReferenceOperand('Employees.salary'),
          ClauseOperator.greaterThan,
          NumberLiteralOperand(50000),
        );
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Employees.name, department_name.Departments.name FROM Employees'
        ' INNER JOIN Departments ON Employees.department_id=Departments.id '
        'WHERE Employees.salary>50000',
      );
    });

    test('JOIN with ORDER BY', () {
      final builder = SelectStatementBuilder(from: 'Books')
        ..selectColumn('Books.title')
        ..selectColumn('Authors.name')
        ..join.leftJoin(
          table: 'Authors',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Books.author_id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Authors.id'),
            ),
          ]),
        )
        ..orderBy.ascWithTable('Authors', 'name')
        ..orderBy.descWithTable('Books', 'title');
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Books.title, Authors.name FROM Books LEFT JOIN Authors '
        'ON Books.author_id=Authors.id '
        'ORDER BY Authors.name ASC, Books.title DESC',
      );
    });

    test('FULL JOIN', () {
      final builder = SelectStatementBuilder(from: 'Students')
        ..selectColumn('Students.name')
        ..selectColumn('Courses.name', tableName: 'course_name')
        ..join.fullJoin(
          table: 'Enrollments',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Students.id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Enrollments.student_id'),
            ),
          ]),
        )
        ..join.fullJoin(
          table: 'Courses',
          on: WhereClauseGroup([
            WhereCondition(
              const ColumnReferenceOperand('Enrollments.course_id'),
              ClauseOperator.equals,
              const ColumnReferenceOperand('Courses.id'),
            ),
          ]),
        );
      final statement = builder.build();
      expect(
        statementToSql(statement),
        'SELECT Students.name, course_name.Courses.name FROM Students '
        'FULL JOIN Enrollments ON Students.id=Enrollments.student_id '
        'FULL JOIN Courses ON Enrollments.course_id=Courses.id',
      );
    });
  });
}
