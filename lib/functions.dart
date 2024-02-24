import 'package:dart_application_20/operand.dart';
import 'package:dart_application_20/where_clause_element.dart';

///This is an oversimplication. It may be slightly different for each
///db platform. However, it will be mostly the same for each platform and
///the key is only hooking into the platform specifics where necessary
String toSQL(List<WhereClauseElement> where) => 'WHERE ${where.map(
      (element) => switch (element) {
        (final WhereCondition condition) => '${condition.leftOperand}'
            '${getClauseOperatorSymbol(condition.clauseOperator)}'
            '${condition.rightOperand}',
        (final LogicalOperator logicalOperator) =>
          getLogicalOperatorSymbol(logicalOperator),
        (final GroupingOperator groupingOperator) =>
          getGroupingOperatorSymbol(groupingOperator),
      },
    ).join(' ')}';

String getClauseOperatorSymbol(ClauseOperator clauseOperator) =>
    switch (clauseOperator) {
      ClauseOperator.equals => '=',
      ClauseOperator.notEquals => '!=',
      ClauseOperator.greaterThan => '>',
      ClauseOperator.lessThan => '<',
    };

String getGroupingOperatorSymbol(GroupingOperator groupingOperator) =>
    switch (groupingOperator) {
      GroupingOperator.open => '(',
      GroupingOperator.close => ')',
    };

String getLogicalOperatorSymbol(LogicalOperator logicalOperator) =>
    switch (logicalOperator) {
      LogicalOperator.and => 'AND',
      LogicalOperator.or => 'OR',
    };

class WhereClauseBuilder {
  final List<WhereClauseElement> _whereClause = [];

  void condition(
    Operand leftOperand,
    ClauseOperator clauseOperator,
    Operand rightOperand,
  ) {
    _whereClause.add(WhereCondition(leftOperand, clauseOperator, rightOperand));
  }

  void logicalOperator(LogicalOperator logicalOperator) {
    _whereClause.add(logicalOperator);
  }

  void groupingOperator(GroupingOperator groupingOperator) {
    _whereClause.add(groupingOperator);
  }

  List<WhereClauseElement> build() => _whereClause;
}

extension Aasdasd on WhereClauseBuilder {
  void and() => logicalOperator(LogicalOperator.and);
  void or() => logicalOperator(LogicalOperator.or);

  void openBracket() => groupingOperator(GroupingOperator.open);
  void closeBracket() => groupingOperator(GroupingOperator.close);

  void equalsNumber(
          ColumnReferenceOperand columnReferenceOperand, num number,) =>
      condition(
        columnReferenceOperand,
        ClauseOperator.equals,
        NumberLiteralOperand(number),
      );

  void equalsText(ColumnReferenceOperand columnReferenceOperand, String text) =>
      condition(
        columnReferenceOperand,
        ClauseOperator.equals,
        StringLiteralOperand(text),
      );
}
