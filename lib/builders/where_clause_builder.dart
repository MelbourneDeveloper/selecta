import 'package:selecta/model/model.dart';

/// A builder for making [WhereClauseElement]s.
class WhereClauseBuilder {
  final List<WhereClauseElement> _whereClause = [];

  /// Adds a where condition to the where clause.
  void condition(
    Operand leftOperand,
    ClauseOperator clauseOperator,
    Operand rightOperand,
  ) {
    _whereClause.add(WhereCondition(leftOperand, clauseOperator, rightOperand));
  }

  /// Adds a logical operator to the where clause.
  void logicalOperator(LogicalOperator logicalOperator) {
    _whereClause.add(logicalOperator);
  }

  /// Adds a grouping operator to the where clause.
  void groupingOperator(GroupingOperator groupingOperator) {
    _whereClause.add(groupingOperator);
  }

  /// Builds the where clause.
  WhereClauseGroup build() => WhereClauseGroup(_whereClause);
}

/// An extension on [WhereClauseBuilder] that provides a fluent API for
extension WhereClauseBuilderExtensions on WhereClauseBuilder {
  /// Adds a where condition to the where clause.
  void and() => logicalOperator(LogicalOperator.and);

  /// Adds a where condition to the where clause.
  void or() => logicalOperator(LogicalOperator.or);

  /// Adds a grouping operator to the where clause.
  void openBracket() => groupingOperator(GroupingOperator.open);

  /// Adds a grouping operator to the where clause.
  void closeBracket() => groupingOperator(GroupingOperator.close);

  /// Adds a where condition to the where clause.
  void equalsNumber(
    ColumnReferenceOperand columnReferenceOperand,
    num number,
  ) =>
      condition(
        columnReferenceOperand,
        ClauseOperator.equals,
        NumberLiteralOperand(number),
      );

  /// Adds a where condition to the where clause.
  void equalsText(ColumnReferenceOperand columnReferenceOperand, String text) =>
      condition(
        columnReferenceOperand,
        ClauseOperator.equals,
        StringLiteralOperand(text),
      );
}
