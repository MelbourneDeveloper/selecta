// import 'package:selecta/functions.dart';
import 'package:selecta/model/operand.dart';
import 'package:selecta/model/select_statement.dart';

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
      '$leftOperand $clauseOperator $rightOperand';

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

/// A type that represents a group of where clause elements.
/// It's kinda questionable whether this is necessary or not.
/// The [SelectStatement] could just have a list of [WhereClauseElement]s.
final class WhereClauseGroup implements WhereClauseElement {
  /// Creates a new where clause group.
  WhereClauseGroup(this.elements);

  /// The elements of the group.
  final List<WhereClauseElement> elements;

  @override
  String toString() => '(${elements.join(' ')})';

  @override
  bool operator ==(Object other) =>
      other is WhereClauseGroup &&
      elements.length == other.elements.length &&
      elements.every((element) => other.elements.contains(element));

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(elements));
}
