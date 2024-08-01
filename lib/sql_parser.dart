
import 'package:selecta/model/model.dart';

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
  final regex =
      RegExp(r'''\s+|\(|\)|=|!=|>|<|AND|OR|"[^"]*"|'[^']*'|\d+(\.\d+)?|\w+''');
  return wherePart
      .splitMapJoin(
        regex,
        onMatch: (m) => '${m.group(0)}',
        onNonMatch: (s) => '',
      )
      .split(' ')
      .where((s) => s.isNotEmpty)
      .toList();
}

List<WhereClauseElement> _parseWhereClause(List<String> tokens) {
  final elements = <WhereClauseElement>[];
  for (var i = 0; i < tokens.length; i++) {
    switch (tokens[i].toUpperCase()) {
      case 'AND':
        elements.add(LogicalOperator.and);
      case 'OR':
        elements.add(LogicalOperator.or);
      case '(':
        elements.add(GroupingOperator.open);
      case ')':
        elements.add(GroupingOperator.close);
      default:
        if (i + 2 < tokens.length) {
          if (_isClauseOperator(tokens[i + 1])) {
            elements.add(
              _parseCondition(tokens[i], tokens[i + 1], tokens[i + 2]),
            );
            i +=
                2; // Skip the next two tokens as they're part of this condition
          }
        }
    }
  }
  return elements;
}

bool _isClauseOperator(String token) =>
    ['=', '!=', '>', '<', '>=', '<='].contains(token);

Operand _parseRightOperand(String value) {
  if (value.startsWith('"') && value.endsWith('"')) {
    return StringLiteralOperand(value.substring(1, value.length - 1));
  } else if (int.tryParse(value) != null) {
    return NumberLiteralOperand(int.parse(value));
  } else if (double.tryParse(value) != null) {
    return NumberLiteralOperand(double.parse(value));
  } else {
    return ColumnReferenceOperand(value);
  }
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
    case '>=':
      return ClauseOperator.greaterThanEqualTo;
    case '<':
      return ClauseOperator.lessThan;
    case '<=':
      return ClauseOperator.lessThanEqualTo;
    default:
      throw FormatException('Unsupported clause operator: $operator');
  }
}
