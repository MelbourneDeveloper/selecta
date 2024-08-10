import 'package:selecta/model/join.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

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
  final orderByClause = orderByToSQL(statement.orderBy);

  return 'SELECT $selectClause FROM ${statement.from}'
      '${whereClause.isNotEmpty ? ' WHERE $whereClause' : ''}'
      '${orderByClause.isNotEmpty ? ' ORDER BY $orderByClause' : ''}';
}

/// Converts a list of [OrderByElement] to a SQL ORDER BY clause.
String orderByToSQL(List<OrderByElement> orderBy) => orderBy
    .map(
      (element) => switch (element) {
        OrderByColumn() =>
          '${element.tableName != null ? '${element.tableName}.' : ''}'
              '${element.columnName} ${element.toSql()}',
      },
    )
    .join(', ');

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

/// Converts a [WhereClauseGroup] to a SQL WHERE clause string.
String conditionToSQL(WhereCondition condition) =>
    '${_operandToSQL(condition.leftOperand)}'
    '${getClauseOperatorSymbol(condition.clauseOperator)}'
    '${_operandToSQL(condition.rightOperand)}';

/// Converts a list of [Join] to a SQL JOIN clause.
String joinToSQL(List<Join> joins) => joins.map((join) {
      final joinTypeStr = switch (join.type) {
        JoinType.inner => 'INNER JOIN',
        JoinType.left => 'LEFT JOIN',
        JoinType.right => 'RIGHT JOIN',
        JoinType.full => 'FULL JOIN',
      };
      return ' $joinTypeStr ${join.table} ON ${conditionToSQL(join.condition)}';
    }).join();

/// Converts an [Operand] to a SQL operand.
String getClauseOperatorSymbol(ClauseOperator op) => switch (op) {
      ClauseOperator.equals => '=',
      ClauseOperator.notEquals => '!=',
      ClauseOperator.greaterThan => '>',
      ClauseOperator.greaterThanEqualTo => '>=',
      ClauseOperator.lessThan => '<',
      ClauseOperator.lessThanEqualTo => '<=',
    };

/// Converts a list of selected columns to a SQL SELECT clause
String selectColumnsToSql(List<SelectedColumn> selectedColumns) =>
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

/// Converts a [Operand] to a string.
String _operandToSQL(Operand operand) => switch (operand) {
      final StringLiteralOperand operand => '"${operand.value}"',
      final NumberLiteralOperand operand => operand.value.toString(),
      final ColumnReferenceOperand operand => operand.value,
    };
