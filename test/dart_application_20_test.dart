import 'package:dart_application_20/functions.dart';
import 'package:dart_application_20/operand.dart';
import 'package:dart_application_20/where_clause_element.dart';
import 'package:test/test.dart';

const name = ColumnReferenceOperand('NAME');

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
      ..condition(
        name,
        ClauseOperator.equals,
        StringLiteralOperand('JIM'),
      )
      ..logicalOperator(LogicalOperator.and)
      ..groupingOperator(GroupingOperator.open)
      ..condition(
        const ColumnReferenceOperand('ID'),
        ClauseOperator.equals,
        NumberLiteralOperand(123),
      )
      ..logicalOperator(LogicalOperator.or)
      ..condition(
        const ColumnReferenceOperand('ID'),
        ClauseOperator.equals,
        NumberLiteralOperand(321),
      )
      ..groupingOperator(GroupingOperator.close);

    final sql = toSQL(builder.build());

    expect(sql, 'WHERE NAME="JIM" AND ( ID=123 OR ID=321 )');
  });
}
