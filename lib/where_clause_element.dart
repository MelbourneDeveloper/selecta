import 'package:dart_application_20/operand.dart';

sealed class WhereClauseElement {}

final class WhereCondition implements WhereClauseElement {

  WhereCondition(this.leftOperand, this.clauseOperator, this.rightOperand);
  final Operand leftOperand;
  final Operand rightOperand;
  final ClauseOperator clauseOperator;
}

enum ClauseOperator { equals, notEquals, greaterThan, lessThan }

enum LogicalOperator implements WhereClauseElement { and, or }

enum GroupingOperator implements WhereClauseElement { open, close }
