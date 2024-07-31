import 'package:dart_application_20/operand.dart';
import 'package:dart_application_20/select_statement.dart';
import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/where_clause_element.dart';

SelectStatement toSelectStatement(String sqlText) {
  final parts = sqlText.split(' WHERE ');
  final selectPart = parts[0].trim();
  final wherePart = parts.length > 1 ? parts[1].trim() : null;

  // Parse SELECT part
  final selectClause = selectPart.substring(6).trim(); // Remove "SELECT "
  final fromIndex = selectClause.toUpperCase().indexOf(' FROM ');
  final columns =
      selectClause.substring(0, fromIndex).split(',').map((col) => col.trim());
  final fromClause =
      selectClause.substring(fromIndex + 6).trim(); // Remove " FROM "

  final selectedColumns = <SelectedColumn>[];
  for (final column in columns) {
    if (column == '*') {
      selectedColumns.add(AllColumns());
    } else {
      final parts = column.split('.');
      if (parts.length == 2) {
        selectedColumns.add(ColumnReference(parts[1], tableName: parts[0]));
      } else {
        selectedColumns.add(ColumnReference(parts[0]));
      }
    }
  }

  // Parse WHERE part
  final where = <WhereClauseElement>[];
  if (wherePart != null) {
    final tokens = _tokenizeWhere(wherePart);
    where.addAll(_parseWhereClause(tokens));
  }

  return SelectStatement(fromClause, selectedColumns, where: where);
}

List<String> _tokenizeWhere(String wherePart) {
  final regex = RegExp(r'''\s+|\(|\)|=|!=|>|<|AND|OR|\'.*?\'|\d+''');
  return wherePart
      .splitMapJoin(
        regex,
        onMatch: (m) => '${m.group(0)}',
        onNonMatch: (s) => s.isNotEmpty ? s : '',
      )
      .split(' ')
      .where((s) => s.isNotEmpty)
      .toList();
}

List<WhereClauseElement> _parseWhereClause(List<String> tokens) {
  final elements = <WhereClauseElement>[];
  final stack = <List<WhereClauseElement>>[];
  var current = elements;

  for (var i = 0; i < tokens.length; i++) {
    switch (tokens[i].toUpperCase()) {
      case 'AND':
        current.add(LogicalOperator.and);
      case 'OR':
        current.add(LogicalOperator.or);
      case '(':
        stack.add(current);
        current = [];
        elements.add(GroupingOperator.open);
      case ')':
        if (stack.isNotEmpty) {
          final groupedElements = current;
          current = stack.removeLast()
            ..addAll(groupedElements)
            ..add(GroupingOperator.close);
        } else {
          throw const FormatException('Unmatched closing parenthesis');
        }
      case '=':
      case '!=':
      case '>':
      case '<':
        if (i > 0 && i + 1 < tokens.length) {
          current.add(
            _parseCondition(tokens[i - 1], tokens[i], tokens[i + 1]),
          );
          i++; // Skip the next token as it's part of this condition
        } else {
          throw FormatException('Invalid condition format near: ${tokens[i]}');
        }
      default:
        // Skip other tokens (column names, values) as they're handled in the
        //condition parsing
        continue;
    }
  }

  if (stack.isNotEmpty) {
    throw const FormatException('Unmatched opening parenthesis');
  }

  return elements;
}

WhereCondition _parseCondition(String left, String operator, String right) {
  final leftOperand = ColumnReferenceOperand(left);
  final clauseOperator = _parseClauseOperator(operator);
  final rightOperand = _parseRightOperand(right);

  return WhereCondition(leftOperand, clauseOperator, rightOperand);
}

ClauseOperator _parseClauseOperator(String operator) {
  switch (operator) {
    case '=':
      return ClauseOperator.equals;
    case '!=':
      return ClauseOperator.notEquals;
    case '>':
      return ClauseOperator.greaterThan;
    case '<':
      return ClauseOperator.lessThan;
    default:
      throw FormatException('Unsupported clause operator: $operator');
  }
}

Operand _parseRightOperand(String value) {
  if (value.startsWith("'") && value.endsWith("'")) {
    return StringLiteralOperand(value.substring(1, value.length - 1));
  } else if (int.tryParse(value) != null) {
    return NumberLiteralOperand(int.parse(value));
  } else if (double.tryParse(value) != null) {
    return NumberLiteralOperand(double.parse(value));
  } else {
    return ColumnReferenceOperand(value);
  }
}
