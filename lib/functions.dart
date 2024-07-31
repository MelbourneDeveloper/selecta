import 'package:dart_application_20/operand.dart';
import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/where_clause_builder.dart';
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

/// Converts a list of selected columns to a SQL SELECT clause 
String toSelectSQL(List<SelectedColumn> selectedColumns) =>
    'SELECT ${selectedColumns.map(
          (column) => switch (column) {
            // ignore: unused_local_variable
            (final AllColumns allColumns) =>
              '${allColumns.tableName != null ? '${allColumns.tableName}'
                  '.' : ''}*',
            (final ColumnReference columnReference) =>
              _columnReferenceToString(columnReference),
          },
        ).join(', ')}';

String _columnReferenceToString(ColumnReference columnReference) =>
    '${columnReference.tableName != null ? '${columnReference.tableName}'
        '.' : ''}${columnReference.columnName}';

/// Converts a [ClauseOperator] to a SQL operator symbol.
String getClauseOperatorSymbol(ClauseOperator clauseOperator) =>
    switch (clauseOperator) {
      ClauseOperator.equals => '=',
      ClauseOperator.notEquals => '!=',
      ClauseOperator.greaterThan => '>',
      ClauseOperator.lessThan => '<',
    };

/// Converts a [GroupingOperator] to a SQL grouping operator symbol.
String getGroupingOperatorSymbol(GroupingOperator groupingOperator) =>
    switch (groupingOperator) {
      GroupingOperator.open => '(',
      GroupingOperator.close => ')',
    };

/// Converts a [LogicalOperator] to a SQL logical operator symbol.
String getLogicalOperatorSymbol(LogicalOperator logicalOperator) =>
    switch (logicalOperator) {
      LogicalOperator.and => 'AND',
      LogicalOperator.or => 'OR',
    };

/// An extension on [SelectStatementBuilder] that provides a fluent API for
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
