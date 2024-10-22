// ignore_for_file: lines_longer_than_80_chars

import 'package:selecta/model/join.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

/// Type alias for a function that formats a value of type [T] to a [String].
typedef Formatter<T> = String Function(T);

/// The clause text for each part of the statement
typedef AllClauses = ({
  String selectClause,
  String fromClause,
  String joinClause,
  String whereClause,
  String orderByClause
});

/// Formatting options for the SQL formatter.
typedef FormattingOptions = ({
  String newline,
  String indent,
  bool uppercaseKeywords,
  int subClauseIndent
});

/// Default formatting options
const defaultOptions =
    (newline: '\n', indent: ' ', uppercaseKeywords: true, subClauseIndent: 6);

/// A function that returns the input string as is.
String identity(String s) => s;

/// Converts a [SelectStatement] to an SQL string.
String statementToSql(
  SelectStatement statement, {
  Formatter<List<SelectedColumn>> selectFormatter = defaultSelectFormatter,
  Formatter<String> fromFormatter = identity,
  Formatter<List<Join>> joinFormatter = defaultJoinFormatter,
  Formatter<WhereClauseGroup> whereFormatter = defaultWhereFormatter,
  Formatter<List<OrderByElement>> orderByFormatter = defaultOrderByFormatter,
  Formatter<AllClauses> allClausesFormatter = defaultAllClausesFormatter,
}) =>
    allClausesFormatter(
      (
        selectClause: selectFormatter(statement.select),
        fromClause: fromFormatter(statement.from),
        joinClause: joinFormatter(statement.joins),
        whereClause: whereFormatter(statement.where),
        orderByClause: orderByFormatter(statement.orderBy)
      ),
    );

/// Converts [AllClauses] to an SQL string.
String defaultAllClausesFormatter(AllClauses clauses) =>
    'SELECT ${clauses.selectClause} FROM '
    '${clauses.fromClause}${clauses.joinClause}'
    '${clauses.whereClause.isNotEmpty ? ' WHERE ${clauses.whereClause}' : ''}'
    '${clauses.orderByClause.isNotEmpty ? ' ORDER BY ${clauses.orderByClause}' : ''}';

/// Converts [AllClauses] to an SQL string with default formatting options.
String formattedAllClausesFormatter(AllClauses clauses) =>
    sqlFormatter(clauses, defaultOptions);

/// Converts a list of [SelectedColumn]s to a SQL SELECT statement.
String defaultSelectFormatter(List<SelectedColumn> columns) =>
    columns.map(columnToSql).join(', ');

/// Converts a [SelectedColumn] to a SQL string.
String columnToSql(SelectedColumn col) => switch (col) {
      AllColumns() => col.tableName != null ? '${col.tableName}.*' : '*',
      ColumnReference() => col.tableName != null
          ? '${col.tableName}.${col.columnName}'
          : col.columnName,
    };

/// The default formatter for the ORDER BY clause.
String defaultOrderByFormatter(List<OrderByElement> orderBy) =>
    orderBy.map(orderByElementToSql).join(', ');

/// Converts an [OrderByElement] to a SQL string.
String orderByElementToSql(OrderByElement element) => switch (element) {
      OrderByColumn() =>
        '${element.tableName != null ? '${element.tableName}.' : ''}'
            '${element.columnName} ${element.toSql()}',
    };

/// The default formatter for the WHERE clause.
String defaultWhereFormatter(WhereClauseGroup group) =>
    group.elements.map(whereClauseElementToSql).join(' ');

/// Converts a [WhereClauseElement] to a SQL string.
String whereClauseElementToSql(WhereClauseElement element) => switch (element) {
      WhereCondition() => conditionToSQL(element),
      LogicalOperator() => element.name.toUpperCase(),
      WhereClauseGroup() => '(${defaultWhereFormatter(element)})',
      GroupingOperator.open => '(',
      GroupingOperator.close => ')',
    };

/// Converts a [WhereCondition] to a SQL string.
String conditionToSQL(
  WhereCondition condition, {
  Formatter<Operand> operandFormatter = defaultOperandFormatter,
  Formatter<ClauseOperator> operatorFormatter = defaultOperatorFormatter,
}) =>
    '${operandFormatter(condition.leftOperand)}'
    '${operatorFormatter(condition.clauseOperator)}'
    '${operandFormatter(condition.rightOperand)}';

/// The default formatter for a list of [Join]s.
String defaultJoinFormatter(List<Join> joins) => joins.map(joinToSql).join();

/// Converts a [Join] to a SQL string.
String joinToSql(
  Join join, {
  Formatter<JoinType> typeFormatter = defaultJoinTypeFormatter,
  Formatter<String> tableFormatter = identity,
  Formatter<WhereClauseGroup> onFormatter = defaultWhereFormatter,
}) =>
    ' ${typeFormatter(join.type)} ${tableFormatter(join.table)} ON ${onFormatter(join.on)}';

/// The default formatter for a [JoinType].
String defaultJoinTypeFormatter(JoinType type) => switch (type) {
      JoinType.inner => 'INNER JOIN',
      JoinType.left => 'LEFT JOIN',
      JoinType.right => 'RIGHT JOIN',
      JoinType.full => 'FULL JOIN',
    };

/// The default formatter for a [ClauseOperator].
String defaultOperatorFormatter(ClauseOperator op) => switch (op) {
      ClauseOperator.equals => '=',
      ClauseOperator.notEquals => '!=',
      ClauseOperator.greaterThan => '>',
      ClauseOperator.greaterThanEqualTo => '>=',
      ClauseOperator.lessThan => '<',
      ClauseOperator.lessThanEqualTo => '<=',
      ClauseOperator.like => ' LIKE ',
    };

/// The default formatter for an [Operand].
String defaultOperandFormatter(Operand operand) => switch (operand) {
      StringLiteralOperand() => '"${operand.value}"',
      NumberLiteralOperand() => operand.value.toString(),
      ColumnReferenceOperand() => operand.value,
    };

/// A function that applies formatting options to a string.
String Function(String) applyFormatting(FormattingOptions options) =>
    (s) => options.uppercaseKeywords ? s.toUpperCase() : s;

/// Formats the SELECT clause.
String formatClause(
  String keyword,
  String clause,
  FormattingOptions options, {
  bool isSubclause = false,
}) =>
    '${options.uppercaseKeywords ? keyword.toUpperCase() : keyword} '
    '${clause.contains(',') ? clause.split(',').map((s) => s.trim()).join(
          ',${options.newline}${options.indent * options.subClauseIndent}',
        ) : clause.trim()}';

/// Compose all formatters
String sqlFormatter(AllClauses clauses, FormattingOptions options) => [
      formatClause('SELECT', clauses.selectClause, options),
      formatClause('FROM', clauses.fromClause, options),
      if (clauses.joinClause.isNotEmpty)
        formatClause(
          'INNER JOIN',
          clauses.joinClause
              .trim()
              .split(' ON ')[0]
              .replaceAll('INNER JOIN ', ''),
          options,
        ),
      if (clauses.joinClause.isNotEmpty)
        formatClause(
          'ON',
          clauses.joinClause.trim().split(' ON ')[1],
          options,
          isSubclause: true,
        ),
      formatClause('WHERE', clauses.whereClause, options, isSubclause: true),
      formatClause(
        'ORDER BY',
        clauses.orderByClause,
        options,
        isSubclause: true,
      ),
    ].where((s) => s.isNotEmpty).join(options.newline);
