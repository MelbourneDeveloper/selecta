import 'package:selecta/model/model.dart';

/// Converts a [SelectStatement] to a SQL SELECT statement.
String statementToSQL(SelectStatement statement) {
  final selectClause = statement.select
      .map(
        (col) => switch (col) {
          AllColumns() => col.tableName != null ? '${col.tableName}.*' : '*',
          ColumnReference() => col.tableName != null
              ? '${col.tableName}.${col.columnName}'
              : col.columnName,
        },
      )
      .join(', ');

  final whereClause = whereClauseGroupToSQL(statement.where);

  return 'SELECT $selectClause FROM ${statement.from}'
      '${whereClause.isNotEmpty ? ' WHERE $whereClause' : ''}';
}

/// Converts a [WhereClauseGroup] to a SQL WHERE clause.
String whereClauseGroupToSQL(WhereClauseGroup group) => group.elements
    .map(
      (element) => switch (element) {
        WhereCondition() => conditionToSQL(element),
        LogicalOperator() => element.name.toUpperCase(),
        WhereClauseGroup() => '(${whereClauseGroupToSQL(element)})',
        GroupingOperator.open => '(',
        GroupingOperator.close => ')',
      },
    )
    .join(' ');

/// Converts a [WhereCondition] to a SQL WHERE condition.
String conditionToSQL(WhereCondition condition) => '${condition.leftOperand}'
    '${getClauseOperatorSymbol(condition.clauseOperator)}'
    '${condition.rightOperand}';

/// Converts an [Operand] to a SQL operand.
String getClauseOperatorSymbol(ClauseOperator op) => switch (op) {
      ClauseOperator.equals => '=',
      ClauseOperator.notEquals => '!=',
      ClauseOperator.greaterThan => '>',
      ClauseOperator.greaterThanEqualTo => '>=',
      ClauseOperator.lessThan => '<',
      ClauseOperator.lessThanEqualTo => '<=',
    };

/// This is an oversimplification. It may be slightly different for each
/// db platform. However, it will be mostly the same for each platform and
/// the key is only hooking into the platform specifics where necessary
String toSQL(List<WhereClauseElement> where) =>
    'WHERE ${_whereElementsToString(where)}';

String _whereElementsToString(List<WhereClauseElement> elements) => elements
    .map(
      (element) => switch (element) {
        final WhereCondition condition =>
          '${_operandToString(condition.leftOperand)}'
              '${getClauseOperatorSymbol(condition.clauseOperator)}'
              '${_operandToString(condition.rightOperand)}',
        final LogicalOperator logicalOperator =>
          getLogicalOperatorSymbol(logicalOperator),
        final GroupingOperator groupingOperator =>
          getGroupingOperatorSymbol(groupingOperator),
        final WhereClauseGroup group =>
          '(${_whereElementsToString(group.elements)})',
      },
    )
    .join(' ');

String _operandToString(Operand operand) => switch (operand) {
      final StringLiteralOperand strLiteral => '"${strLiteral.value}"',
      final NumberLiteralOperand numLiteral => numLiteral.value.toString(),
      final ColumnReferenceOperand colRef => colRef.value,
    };

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

/// Converts a [GroupingOperator] to a SQL grouping operator symbol.
String getGroupingOperatorSymbol(GroupingOperator op) => switch (op) {
      GroupingOperator.open => '(',
      GroupingOperator.close => ')',
    };

/// Converts a [LogicalOperator] to a SQL logical operator symbol.
String getLogicalOperatorSymbol(LogicalOperator op) => switch (op) {
      LogicalOperator.and => 'AND',
      LogicalOperator.or => 'OR',
    };
