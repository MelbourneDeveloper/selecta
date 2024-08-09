import 'package:selecta/model/model.dart';

/// A type that represents an SQL Select statement.
class SelectStatement {

  /// Creates a new select statement.
  SelectStatement(
    this.from,
    this.select, {
    required this.where,
  });

  /// The where clause of the statement.
  final WhereClauseGroup where;

  /// The selected columns of the statement.
  final List<SelectedColumn> select;

  /// The table to select from.
  final String from;

  @override
  String toString() => 'SelectStatement (selectedColumns: '
      '${select.map((c) => c.toString())}, '
      'from: $from, where: $where)';

  @override
  bool operator ==(Object other) =>
      other is SelectStatement &&
      other.from == from &&
      other.select == select &&
      other.where == where;

  @override
  int get hashCode => Object.hash(from, select, where);
}
