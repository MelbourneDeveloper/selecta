import 'package:selecta/model/join.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

/// A type that represents an SQL Select statement.
class SelectStatement {
  /// Creates a new select statement.
  SelectStatement(
    this.from,
    this.select, {
    required this.where,
    this.orderBy = const [],
    this.joins = const [],
  });

  /// The where clause of the statement.
  final WhereClauseGroup where;

  /// The selected columns of the statement.
  final List<SelectedColumn> select;

  /// The table to select from.
  final String from;

  /// The order by clause of the statement.
  final List<OrderByElement> orderBy;

  /// The joins in the statement.
  final List<Join> joins;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectStatement &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          select == other.select &&
          where == other.where &&
          orderBy == other.orderBy &&
          joins == other.joins;

  @override
  int get hashCode =>
      Object.hash(runtimeType, from, select, where, orderBy, joins);

  @override
  String toString() =>
      'SelectStatement(from: $from, select: $select, where: $where, '
      'orderBy: $orderBy, joins: $joins)';
}
