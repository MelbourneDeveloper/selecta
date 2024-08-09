import 'package:selecta/model/model.dart';

SelectStatement toSelectStatement(String sql) {
  // Remove any leading/trailing whitespace and ensure the statement ends with a semicolon
  // ignore: parameter_assignments
  sql = sql.trim();
  if (!sql.endsWith(';')) {
    // ignore: parameter_assignments
    sql += ';';
  }

  // Split the SQL statement into its main components
  final selectIndex = sql.indexOf('SELECT');
  final fromIndex = sql.indexOf('FROM');
  final whereIndex = sql.indexOf('WHERE');
  final endIndex = sql.indexOf(';');

  if (selectIndex == -1 || fromIndex == -1) {
    throw const FormatException(
      'Invalid SQL statement: SELECT and FROM clauses are required',
    );
  }

  // Parse the SELECT clause
  final selectClause = sql.substring(selectIndex + 6, fromIndex).trim();
  final selectedColumns = parseSelectedColumns(selectClause);

  // Parse the FROM clause
  final fromClause = whereIndex == -1
      ? sql.substring(fromIndex + 4, endIndex).trim()
      : sql.substring(fromIndex + 4, whereIndex).trim();

  // Parse the WHERE clause if it exists
  WhereClauseGroup whereClause;
  if (whereIndex != -1) {
    final whereClauseString = sql.substring(whereIndex + 5, endIndex).trim();
    whereClause = parseWhereClause(whereClauseString);
  } else {
    whereClause = WhereClauseGroup([]);
  }

  return SelectStatement(
    fromClause,
    selectedColumns,
    where: whereClause,
  );
}

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

WhereClauseGroup parseWhereClause(String whereClause) {
  final elements = <WhereClauseElement>[];
  final tokens = tokenizeWhereClause(whereClause);

  for (var i = 0; i < tokens.length; i++) {
    if (tokens[i] == '(') {
      final closingIndex = findClosingParenthesis(tokens, i);
      elements
          .add(parseWhereClause(tokens.sublist(i + 1, closingIndex).join(' ')));
      i = closingIndex;
    } else if (tokens[i].toUpperCase() == 'AND' ||
        tokens[i].toUpperCase() == 'OR') {
      elements.add(
        tokens[i].toUpperCase() == 'AND'
            ? LogicalOperator.and
            : LogicalOperator.or,
      );
    } else {
      // Find the next logical operator or end of clause
      final nextLogicalOpIndex = tokens.indexWhere(
        (t) => t.toUpperCase() == 'AND' || t.toUpperCase() == 'OR',
        i + 1,
      );
      final conditionEndIndex =
          nextLogicalOpIndex == -1 ? tokens.length : nextLogicalOpIndex;

      // Parse the condition
      elements.add(parseCondition(tokens.sublist(i, conditionEndIndex)));

      // Move the index to the end of this condition
      i = conditionEndIndex - 1;
    }
  }

  return WhereClauseGroup(elements);
}

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

int findClosingParenthesis(List<String> tokens, int openIndex) {
  var count = 1;
  for (var i = openIndex + 1; i < tokens.length; i++) {
    if (tokens[i] == '(') count++;
    if (tokens[i] == ')') count--;
    if (count == 0) return i;
  }
  throw const FormatException('Mismatched parentheses');
}

WhereCondition parseCondition(List<String> conditionTokens) {
  if (conditionTokens.length < 3) {
    throw FormatException(
      'Invalid condition format: ${conditionTokens.join(' ')}',
    );
  }

  final operatorIndex = conditionTokens
      .indexWhere((t) => ['=', '!=', '>', '>=', '<', '<='].contains(t));

  if (operatorIndex == -1) {
    throw FormatException(
      'No valid operator found in condition: ${conditionTokens.join(' ')}',
    );
  }

  final leftOperand = conditionTokens.sublist(0, operatorIndex).join(' ');
  final operator = conditionTokens[operatorIndex];
  final rightOperand = conditionTokens.sublist(operatorIndex + 1).join(' ');

  return WhereCondition(
    parseOperand(leftOperand),
    parseOperator(operator),
    parseOperand(rightOperand),
  );
}

ClauseOperator parseOperator(String op) {
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

Operand parseOperand(String value) {
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

String whereClauseGroupToSQL(WhereClauseGroup group) {
  final parts = <String>[];
  for (final element in group.elements) {
    if (element is WhereCondition) {
      parts.add(conditionToSQL(element));
    } else if (element is LogicalOperator) {
      parts.add(element.name.toUpperCase());
    } else if (element is WhereClauseGroup) {
      parts.add('(${whereClauseGroupToSQL(element)})');
    }
  }
  return parts.join(' ');
}

String conditionToSQL(WhereCondition condition) {
  final operator = clauseOperatorToStringSymbol(condition.clauseOperator);
  return '${operandToSQL(condition.leftOperand)}'
      '$operator${operandToSQL(condition.rightOperand)}';
}

String operandToSQL(Operand operand) {
  if (operand is StringLiteralOperand) {
    return '"${operand.value}"';
  } else if (operand is NumberLiteralOperand) {
    return operand.value.toString();
  } else if (operand is ColumnReferenceOperand) {
    return operand.value;
  }
  throw ArgumentError('Unknown Operand type');
}

String clauseOperatorToStringSymbol(ClauseOperator op) {
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
