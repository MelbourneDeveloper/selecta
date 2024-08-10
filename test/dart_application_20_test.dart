import 'package:selecta/builders/where_clause_builder.dart';
import 'package:selecta/functions.dart';
import 'package:selecta/model/model.dart';
import 'package:test/test.dart';

const name = ColumnReferenceOperand('NAME');
const id = ColumnReferenceOperand('ID');

void main() {
  test('Go', () {
    final whereClause = [
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
    ];

    final sql = toSQL(whereClause);

    expect(sql, 'WHERE NAME="JIM" AND ( ID=123 OR ID=321 )');
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

    final sql = toSQL(builder.build());

    expect(sql, 'WHERE NAME="JIM" AND ( ID=123 OR ID=321 )');
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
}
