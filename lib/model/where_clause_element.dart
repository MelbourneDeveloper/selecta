import 'package:dart_application_20/functions.dart';
import 'package:dart_application_20/model/operand.dart';

/// A type that represents a where clause element.
sealed class WhereClauseElement {}

/// A type that represents a where condition.
final class WhereCondition implements WhereClauseElement {
  /// Creates a new where condition.
  WhereCondition(this.leftOperand, this.clauseOperator, this.rightOperand);

  /// The left operand of the condition.
  final Operand leftOperand;

  /// The right operand of the condition.
  final Operand rightOperand;

  /// The operator of the condition.
  final ClauseOperator clauseOperator;

  @override
  String toString() =>
      // ignore: no_runtimetype_tostring
      '$runtimeType $leftOperand ${getClauseOperatorSymbol(clauseOperator)}'
      ' $rightOperand';

  @override
  bool operator ==(Object other) =>
      other is WhereCondition &&
      leftOperand == other.leftOperand &&
      clauseOperator == other.clauseOperator &&
      rightOperand == other.rightOperand;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        leftOperand,
        clauseOperator,
        rightOperand,
      );
}

/// A type that represents a logical operator.
enum ClauseOperator {
  /// The equals operator.
  equals,

  /// The not equals operator.
  notEquals,

  /// The greater than operator.
  greaterThan,

  /// The greater than or equal to operator.
  greaterThanEqualTo,

  /// The greater than or equals operator.
  lessThan,

  /// The less than or equals operator.
  lessThanEqualTo,
}

/// A type that represents a logical operator.
enum LogicalOperator implements WhereClauseElement {
  /// The and operator.
  and,

  /// The or operator
  or,
}

/// A type that represents a grouping operator.
enum GroupingOperator implements WhereClauseElement {
  /// The open grouping operator.
  open,

  /// The close grouping operator.
  close,
}
