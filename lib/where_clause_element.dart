import 'package:dart_application_20/operand.dart';

sealed class WhereClauseElement {}

class WhereCondition implements WhereClauseElement {
  final Operand leftOperand;
  final Operand rightOperand;
  final ClauseOperator clauseOperator;

  WhereCondition(this.leftOperand, this.clauseOperator, this.rightOperand);
}

enum ClauseOperator { equals, notEquals, greaterThan, lessThan }

enum LogicalOperator implements WhereClauseElement { and, or }

enum GroupingOperator implements WhereClauseElement { open, close }
