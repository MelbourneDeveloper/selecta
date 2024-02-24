import 'package:dart_application_20/operand.dart';
import 'package:dart_application_20/where_clause_element.dart';
import 'package:dart_application_20/functions.dart';
import 'package:test/test.dart';



void main() {
  test('Go', () {
    var whereClause = [
      WhereCondition(ColumnReferenceOperand('NAME'), ClauseOperator.equals,
          StringLiteralOperand('JIM')),
      LogicalOperator.and,
      GroupingOperator.open,
      WhereCondition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(123)),
      LogicalOperator.or,
      WhereCondition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(321)),
      GroupingOperator.close,
    ];

    var sql = toSQL((whereClause));

    expect(sql, 'WHERE NAME="JIM" AND ( ID=123 OR ID=321 )');
  });

  test('Builder Go', () {
    final builder = WhereClauseBuilder()
      ..condition(ColumnReferenceOperand('NAME'), ClauseOperator.equals,
          StringLiteralOperand('JIM'))
      ..logicalOperator(LogicalOperator.and)
      ..groupingOperator(GroupingOperator.open)
      ..condition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(123))
      ..logicalOperator(LogicalOperator.or)
      ..condition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(321))
      ..groupingOperator(GroupingOperator.close);

    var sql = toSQL((builder.build()));

    expect(sql, 'WHERE NAME="JIM" AND ( ID=123 OR ID=321 )');
  });
}
