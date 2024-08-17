import 'package:selecta/model/join.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

/// Converts a list of [SelectedColumn]s to a SQL SELECT statement.
SelectStatement toSelectStatement(String sql) {
  final cleanSql = sql.trim();
  final clauses = _extractClauses(cleanSql);

  return SelectStatement(
    clauses['FROM'] ?? '',
    parseSelectedColumns(clauses['SELECT'] ?? ''),
    where: parseWhereClause(clauses['WHERE'] ?? ''),
    orderBy: parseOrderByClause(clauses['ORDER BY'] ?? ''),
    joins: parseJoinClauses(clauses['JOIN'] ?? ''),
  );
}

/// Parse the JOIN clauses of a SQL SELECT statement.
List<Join> parseJoinClauses(String joinClauses) => joinClauses.isEmpty
    ? []
    : RegExp(
        r'\b(INNER\s+JOIN|LEFT\s+JOIN|RIGHT\s+JOIN|FULL\s+JOIN|JOIN)\s+(\w+)\s+ON\s+(.*?)(?=\s+(?:INNER\s+JOIN|LEFT\s+JOIN|RIGHT\s+JOIN|FULL\s+JOIN|JOIN)\b|$)',
        caseSensitive: false,
        dotAll: true,
      )
        .allMatches(joinClauses)
        .map(
          (match) => Join(
            type: _parseJoinType(match.group(1)!.split(RegExp(r'\s+'))[0]),
            table: match.group(2)!,
            on: parseWhereClause(match.group(3)!.trim()),
          ),
        )
        .toList();

/// Parse the ORDER BY clause of a SQL SELECT statement.
List<OrderByElement> parseOrderByClause(String orderByClause) =>
    orderByClause.isEmpty
        ? []
        : orderByClause.split(',').map((column) {
            final parts = column.trim().split(RegExp(r'\s+'));
            final columnParts = parts[0].split('.');
            final columnName =
                columnParts.length > 1 ? columnParts[1] : columnParts[0];
            final tableName = columnParts.length > 1 ? columnParts[0] : null;
            return OrderByColumn(
              columnName,
              tableName: tableName,
              direction: parts.length > 1 && parts[1].toUpperCase() == 'DESC'
                  ? SortDirection.descending
                  : SortDirection.ascending,
            );
          }).toList();

/// Converts the selected columns part of a [SelectStatement] to a list
/// of [SelectedColumn] objects.
List<SelectedColumn> parseSelectedColumns(String selectClause) {
  final columns = selectClause.split(',').map((col) => col.trim()).toList();
  return columns.map((col) {
    if (col == '*') {
      return AllColumns();
    } else if (col.contains('.')) {
      final parts = col.split('.');
      return ColumnReference(parts[1], tableName: parts[0]);
    } else {
      return ColumnReference(col);
    }
  }).toList();
}

/// Converts a [SelectStatement] to a SQL SELECT statement.
WhereClauseGroup parseWhereClause(String whereClause) {
  if (whereClause.isEmpty) {
    return WhereClauseGroup([]);
  }

  final elements = <WhereClauseElement>[];
  final tokens = _tokenizeWhereClause(whereClause);

  for (var i = 0; i < tokens.length; i++) {
    switch (tokens[i].toUpperCase()) {
      case '(':
        elements.add(GroupingOperator.open);
      case ')':
        elements.add(GroupingOperator.close);
      case 'AND':
        elements.add(LogicalOperator.and);
      case 'OR':
        elements.add(LogicalOperator.or);
      default:
        // Find the next logical operator, parenthesis, or end of clause
        final nextSpecialIndex = tokens.indexWhere(
          (t) => ['AND', 'OR', '(', ')'].contains(t.toUpperCase()),
          i + 1,
        );
        final conditionEndIndex =
            nextSpecialIndex == -1 ? tokens.length : nextSpecialIndex;

        // Parse the condition
        elements.add(_parseCondition(tokens.sublist(i, conditionEndIndex)));

        // Move the index to the end of this condition
        i = conditionEndIndex - 1;
    }
  }

  return WhereClauseGroup(elements);
}

JoinType _parseJoinType(String joinTypeStr) =>
    switch (joinTypeStr.trim().toUpperCase()) {
      'INNER' => JoinType.inner,
      'LEFT' => JoinType.left,
      'RIGHT' => JoinType.right,
      'FULL' => JoinType.full,
      'JOIN' => JoinType.inner,
      _ => throw FormatException('Unknown join type: $joinTypeStr'),
    };

Map<String, String> _extractClauses(String sql) {
  final upperSql = sql.toUpperCase();
  final clauseKeywords = ['SELECT', 'FROM', 'WHERE', 'ORDER BY'];
  final joinKeywords = [
    'INNER JOIN',
    'LEFT JOIN',
    'RIGHT JOIN',
    'FULL JOIN',
    'JOIN',
  ];
  final allKeywords = [...clauseKeywords, ...joinKeywords];

  final result = <String, String>{};

  int findNextKeywordIndex(int startIndex, List<String> keywords) => keywords
      .map((k) => upperSql.indexOf(k, startIndex))
      .where((idx) => idx != -1)
      .fold(sql.length, (min, idx) => idx < min ? idx : min);

  var lastEndIndex = 0;
  for (final keyword in clauseKeywords) {
    final start = upperSql.indexOf(keyword, lastEndIndex);
    if (start != -1) {
      final nextKeywordIndex =
          findNextKeywordIndex(start + keyword.length, allKeywords);
      result[keyword] =
          sql.substring(start + keyword.length, nextKeywordIndex).trim();
      lastEndIndex = nextKeywordIndex;
    }
  }

  // Handle JOIN clauses
  final joinStart = findNextKeywordIndex(0, joinKeywords);
  if (joinStart < sql.length) {
    final joinEnd = findNextKeywordIndex(joinStart, ['WHERE', 'ORDER BY']);
    result['JOIN'] = sql.substring(joinStart, joinEnd).trim();

    // Adjust WHERE and ORDER BY if they come after JOIN
    if (joinEnd < sql.length) {
      final remainingClauses = sql.substring(joinEnd);
      final whereMatch = RegExp(r'\bWHERE\b', caseSensitive: false)
          .firstMatch(remainingClauses);
      final orderByMatch = RegExp(r'\bORDER BY\b', caseSensitive: false)
          .firstMatch(remainingClauses);

      if (whereMatch != null) {
        result['WHERE'] = remainingClauses
            .substring(
              whereMatch.end,
              orderByMatch?.start ?? remainingClauses.length,
            )
            .trim();
      }
      if (orderByMatch != null) {
        result['ORDER BY'] =
            remainingClauses.substring(orderByMatch.end).trim();
      }
    }
  }

  return result;
}

/// Tokenizes a where clause string into individual tokens.
List<String> _tokenizeWhereClause(String whereClause) =>
    // Split the where clause into tokens, preserving quoted strings and
    // parentheses
    whereClause
        .splitMapJoin(
          RegExp(r'''(\s+)|("[^"]*")|('[^']*')|([!<>=]+)|(\(|\))'''),
          onMatch: (m) =>
              '${m.group(2) ?? ''}${m.group(3) ?? ''}${m.group(4) ?? ''}'
              '${m.group(5) ?? ''} ',
          onNonMatch: (s) => '$s ',
        )
        .trim()
        .split(RegExp(r'\s+'));

/// Parses a list of tokens into a [WhereCondition].
WhereCondition _parseCondition(List<String> conditionTokens) =>
    conditionTokens.isEmpty
        ? throw const FormatException('Empty condition')
        : _buildWhereCondition(
            conditionTokens,
            _findOperatorIndex(conditionTokens),
          );

int _findOperatorIndex(List<String> tokens) => tokens.indexWhere(
      (t) =>
          ['=', '!=', '>', '>=', '<', '<=', 'LIKE'].contains(t.toUpperCase()),
    );

WhereCondition _buildWhereCondition(List<String> tokens, int operatorIndex) =>
    operatorIndex == -1
        ? throw FormatException(
            'No valid operator found in condition: ${tokens.join(' ')}',
          )
        : WhereCondition(
            _parseOperand(tokens.sublist(0, operatorIndex).join(' ')),
            _parseOperator(tokens[operatorIndex]),
            _parseOperand(tokens.sublist(operatorIndex + 1).join(' ')),
          );

/// Convert the string representation of an operator to a [ClauseOperator].
ClauseOperator _parseOperator(String op) => switch (op.toUpperCase()) {
      '=' => ClauseOperator.equals,
      '!=' => ClauseOperator.notEquals,
      '>' => ClauseOperator.greaterThan,
      '>=' => ClauseOperator.greaterThanEqualTo,
      '<' => ClauseOperator.lessThan,
      '<=' => ClauseOperator.lessThanEqualTo,
      'LIKE' => ClauseOperator.like,
      _ => throw FormatException('Invalid operator: $op'),
    };

/// Parses a string value into an [Operand].
Operand _parseOperand(String operand) =>
    operand.startsWith("'") && operand.endsWith("'")
        ? StringLiteralOperand(operand.substring(1, operand.length - 1))
        : num.tryParse(operand) != null
            ? NumberLiteralOperand(num.parse(operand))
            : ColumnReferenceOperand(operand);
