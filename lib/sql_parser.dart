import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

/// Converts a list of [SelectedColumn]s to a SQL SELECT statement.
SelectStatement toSelectStatement(String sql) {
  final cleanSql = sql.trim().endsWith(';') ? sql.trim() : '${sql.trim()};';

  final clauses = _extractClauses(cleanSql);

  return SelectStatement(
    clauses['FROM'] ?? '',
    parseSelectedColumns(clauses['SELECT'] ?? ''),
    where: parseWhereClause(clauses['WHERE'] ?? ''),
    orderBy: parseOrderByClause(clauses['ORDER BY'] ?? ''),
  );
}

Map<String, String> _extractClauses(String sql) {
  final upperSql = sql.toUpperCase();
  final clauseKeywords = ['SELECT', 'FROM', 'WHERE', 'ORDER BY'];

  return Map.fromEntries(
    clauseKeywords.map((keyword) {
      final start = upperSql.indexOf(keyword);
      if (start == -1) return MapEntry(keyword, '');

      final nextKeywordIndex = clauseKeywords
          .skip(clauseKeywords.indexOf(keyword) + 1)
          .map((k) => upperSql.indexOf(k, start + keyword.length))
          .where((idx) => idx != -1)
          .fold<int?>(null, (min, idx) => min == null || idx < min ? idx : min);

      final end = nextKeywordIndex ?? sql.length - 1;
      return MapEntry(
        keyword,
        sql.substring(start + keyword.length, end).trim(),
      );
    }),
  );
}

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
  final tokens = tokenizeWhereClause(whereClause);

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

/// Tokenizes a where clause string into individual tokens.
List<String> tokenizeWhereClause(String whereClause) {
  // Split the where clause into tokens, preserving quoted strings
  final regex = RegExp(r'''(\s+)|("[^"]*")|('[^']*')|([!<>=]+)''');
  return whereClause
      .splitMapJoin(
        regex,
        onMatch: (m) =>
            '${m.group(2) ?? ''}${m.group(3) ?? ''}${m.group(4) ?? ''} ',
        onNonMatch: (s) => '$s ',
      )
      .trim()
      .split(RegExp(r'\s+'));
}

/// Finds the index of the closing parenthesis for an open parenthesis at
/// [openIndex].
int _findClosingParenthesis(List<String> tokens, int openIndex) {
  var count = 1;
  for (var i = openIndex + 1; i < tokens.length; i++) {
    if (tokens[i] == '(') count++;
    if (tokens[i] == ')') count--;
    if (count == 0) return i;
  }
  throw const FormatException('Mismatched parentheses');
}

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

///
ClauseOperator _parseOperator(String op) {
  switch (op) {
    case '=':
      return ClauseOperator.equals;
    case '!=':
      return ClauseOperator.notEquals;
    case '>':
      return ClauseOperator.greaterThan;
    case '>=':
      return ClauseOperator.greaterThanEqualTo;
    case '<':
      return ClauseOperator.lessThan;
    case '<=':
      return ClauseOperator.lessThanEqualTo;
    default:
      throw FormatException('Unknown operator: $op');
  }
}

/// Parses a string value into an [Operand].
Operand _parseOperand(String value) {
  if (value.startsWith('"') && value.endsWith('"')) {
    return StringLiteralOperand(value.substring(1, value.length - 1));
  }
  if (value.startsWith("'") && value.endsWith("'")) {
    return StringLiteralOperand(value.substring(1, value.length - 1));
  }
  if (num.tryParse(value) != null) {
    return NumberLiteralOperand(num.parse(value));
  }
  return ColumnReferenceOperand(value);
}

/// Converts a [WhereClauseGroup] to a SQL WHERE clause string.
String conditionToSQL(WhereCondition condition) {
  final operator = _clauseOperatorToStringSymbol(condition.clauseOperator);
  return '${_operandToSQL(condition.leftOperand)}'
      '$operator${_operandToSQL(condition.rightOperand)}';
}

/// Converts a [Operand] to a string.
String _operandToSQL(Operand operand) {
  if (operand is StringLiteralOperand) {
    return '"${operand.value}"';
  } else if (operand is NumberLiteralOperand) {
    return operand.value.toString();
  } else if (operand is ColumnReferenceOperand) {
    return operand.value;
  }
  throw ArgumentError('Unknown Operand type');
}

String _clauseOperatorToStringSymbol(ClauseOperator op) {
  switch (op) {
    case ClauseOperator.equals:
      return '=';
    case ClauseOperator.notEquals:
      return '!=';
    case ClauseOperator.greaterThan:
      return '>';
    case ClauseOperator.greaterThanEqualTo:
      return '>=';
    case ClauseOperator.lessThan:
      return '<';
    case ClauseOperator.lessThanEqualTo:
      return '<=';
  }
}
