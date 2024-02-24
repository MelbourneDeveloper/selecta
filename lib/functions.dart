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

extension WhereClauseBuilderExtensions on WhereClauseBuilder {
  void and() => logicalOperator(LogicalOperator.and);
  void or() => logicalOperator(LogicalOperator.or);

  void openBracket() => groupingOperator(GroupingOperator.open);
  void closeBracket() => groupingOperator(GroupingOperator.close);

  void equalsNumber(
    ColumnReferenceOperand columnReferenceOperand,
    num number,
  ) =>
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
