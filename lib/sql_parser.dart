import 'package:dart_application_20/operand.dart';
import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/where_clause.dart';
import 'package:dart_application_20/where_clause_element.dart';

SelectStatement toSelectStatement(String sqlText) {
  final parts = sqlText.split(' WHERE ');
  final selectPart = parts[0].trim();
  final wherePart = parts.length > 1 ? parts[1].trim() : null;

  final selectStatement = SelectStatement(where: []);

  // Parse SELECT part
  final selectClause = selectPart.substring(6).trim(); // Remove "SELECT "
  final fromIndex = selectClause.toUpperCase().indexOf(' FROM ');
  final columns =
      selectClause.substring(0, fromIndex).split(',').map((col) => col.trim());

  for (final column in columns) {
    if (column == '*') {
      selectStatement.selectedColumns.add(AllColumns());
    } else {
      final parts = column.split('.');
      if (parts.length == 2) {
        selectStatement.selectedColumns.add(
          ColumnReference(parts[1], tableName: parts[0]),
        );
      } else {
        selectStatement.selectedColumns.add(ColumnReference(parts[0]));
      }
    }
  }

  // Parse WHERE part
  if (wherePart != null) {
    final tokens = _tokenizeWhere(wherePart);
    selectStatement.where.addAll(_parseWhereClause(tokens));
  }

  return selectStatement;
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
          elements.add(
            _parseCondition(tokens[i], tokens[i + 1], tokens[i + 2]),
          );
          i += 2;
        }
    }
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
      throw FormatException('Unsupported operator: $operator');
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
