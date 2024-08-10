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
List<Join> parseJoinClauses(String joinClauses) {
  if (joinClauses.isEmpty) return [];

  final joins = <Join>[];
  final joinRegex = RegExp(
    r'\b(INNER|LEFT|RIGHT|FULL)?\s*JOIN\s+(\w+)\s+ON\s+(.+?)(?=\s+(?:INNER|LEFT|RIGHT|FULL)?\s*JOIN|$)',
    caseSensitive: false,
    dotAll: true,
  );

  for (final match in joinRegex.allMatches(joinClauses)) {
    final joinType = _parseJoinType(match.group(1) ?? '');
    final tableName = match.group(2)!.trim();
    final condition = parseWhereClause(match.group(3)!.trim());

    joins.add(
      Join(
        type: joinType,
        table: tableName,
        on: condition,
      ),
    );
  }

  return joins;
}

/// Parse the ORDER BY clause of a SQL SELECT statement.
List<OrderByElement> parseOrderByClause(String orderByClause) =>
    orderByClause.isEmpty
        ? []
        : orderByClause.split(',').map((column) {
            final parts = column.trim().split(RegExp(r'\s+'));
            return OrderByColumn(
              parts[0],
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
        final closingIndex = _findClosingParenthesis(tokens, i);
        elements.add(
          parseWhereClause(tokens.sublist(i + 1, closingIndex).join(' ')),
        );
        i = closingIndex;
      case 'AND':
        elements.add(LogicalOperator.and);
      case 'OR':
        elements.add(LogicalOperator.or);
      default:
        // Find the next logical operator or end of clause
        final nextLogicalOpIndex = tokens.indexWhere(
          (t) => ['AND', 'OR'].contains(t.toUpperCase()),
          i + 1,
        );
        final conditionEndIndex =
            nextLogicalOpIndex == -1 ? tokens.length : nextLogicalOpIndex;

        // Parse the condition
        elements.add(_parseCondition(tokens.sublist(i, conditionEndIndex)));

        // Move the index to the end of this condition
        i = conditionEndIndex - 1;
    }
  }

  return WhereClauseGroup(elements);
}

JoinType _parseJoinType(String joinTypeStr) {
  switch (joinTypeStr.trim().toUpperCase()) {
    case '':
    case 'INNER':
      return JoinType.inner;
    case 'LEFT':
      return JoinType.left;
    case 'RIGHT':
      return JoinType.right;
    case 'FULL':
      return JoinType.full;
    default:
      throw FormatException('Unknown join type: $joinTypeStr');
  }
}

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

  final result = <String, String>{};

  int findNextKeywordIndex(int startIndex, List<String> keywords) => keywords
      .map((k) => upperSql.indexOf(k, startIndex))
      .where((idx) => idx != -1)
      .fold(sql.length, (min, idx) => idx < min ? idx : min);

  var lastEndIndex = 0;
  for (final keyword in clauseKeywords) {
    final start = upperSql.indexOf(keyword, lastEndIndex);
    if (start != -1) {
      final nextClauseIndex = findNextKeywordIndex(
        start + keyword.length,
        clauseKeywords,
      );
      final nextJoinIndex = findNextKeywordIndex(
        start + keyword.length,
        joinKeywords,
      );

      final end = keyword == 'FROM'
          ? (nextJoinIndex < nextClauseIndex ? nextJoinIndex : nextClauseIndex)
          : nextClauseIndex;
          
      result[keyword] = sql.substring(start + keyword.length, end).trim();
      lastEndIndex = end;
    }
  }

  // Handle JOIN clauses
  final joinClauses = joinKeywords
      .expand(
        (keyword) => RegExp(
          '$keyword\\s+.*?(?=${clauseKeywords.join('|')}|\$)',
          caseSensitive: false,
          dotAll: true,
        ).allMatches(sql).map((m) => m.group(0)!),
      )
      .join(' ');

  if (joinClauses.isNotEmpty) {
    result['JOIN'] = joinClauses;
  }

  return result;
}

/// Tokenizes a where clause string into individual tokens.
List<String> _tokenizeWhereClause(String whereClause) =>
    // Split the where clause into tokens, preserving quoted strings
    whereClause
        .splitMapJoin(
          RegExp(r'''(\s+)|("[^"]*")|('[^']*')|([!<>=]+)'''),
          onMatch: (m) =>
              '${m.group(2) ?? ''}${m.group(3) ?? ''}${m.group(4) ?? ''} ',
          onNonMatch: (s) => '$s ',
        )
        .trim()
        .split(RegExp(r'\s+'));

/// Finds the index of the closing parenthesis for an open parenthesis at
/// [openIndex].
int _findClosingParenthesis(List<String> tokens, int openIndex) =>
    _findClosingParenthesisRecursive(tokens, openIndex + 1, 1);

int _findClosingParenthesisRecursive(
  List<String> tokens,
  int currentIndex,
  int count,
) =>
    currentIndex >= tokens.length
        ? throw const FormatException('Mismatched parentheses')
        : switch (tokens[currentIndex]) {
            '(' => _findClosingParenthesisRecursive(
                tokens,
                currentIndex + 1,
                count + 1,
              ),
            ')' when count == 1 => currentIndex,
            ')' => _findClosingParenthesisRecursive(
                tokens,
                currentIndex + 1,
                count - 1,
              ),
            _ =>
              _findClosingParenthesisRecursive(tokens, currentIndex + 1, count),
          };

/// Parses a list of tokens into a [WhereCondition].
WhereCondition _parseCondition(List<String> conditionTokens) {
  if (conditionTokens.isEmpty) {
    throw const FormatException('Empty condition');
  }

  final operatorIndex = conditionTokens
      .indexWhere((t) => ['=', '!=', '>', '>=', '<', '<='].contains(t));

  if (operatorIndex == -1) {
    throw FormatException(
      'No valid operator found in condition: ${conditionTokens.join(' ')}',
    );
  }

  return WhereCondition(
    _parseOperand(conditionTokens.sublist(0, operatorIndex).join(' ')),
    _parseOperator(conditionTokens[operatorIndex]),
    _parseOperand(conditionTokens.sublist(operatorIndex + 1).join(' ')),
  );
}

/// Convert the string representation of an operator to a [ClauseOperator].
ClauseOperator _parseOperator(String op) => switch (op) {
      '=' => ClauseOperator.equals,
      '!=' => ClauseOperator.notEquals,
      '>' => ClauseOperator.greaterThan,
      '>=' => ClauseOperator.greaterThanEqualTo,
      '<' => ClauseOperator.lessThan,
      '<=' => ClauseOperator.lessThanEqualTo,
      _ => throw FormatException('Unknown operator: $op'),
    };

/// Parses a string value into an [Operand].
Operand _parseOperand(String value) =>
    (value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))
        ? StringLiteralOperand(value.substring(1, value.length - 1))
        : num.tryParse(value) != null
            ? NumberLiteralOperand(num.parse(value))
            : ColumnReferenceOperand(value);
