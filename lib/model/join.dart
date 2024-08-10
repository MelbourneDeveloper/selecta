import 'package:selecta/model/where_clause_element.dart';

/// Enum representing different types of SQL joins
enum JoinType {

  /// inner join
  inner,

  /// left join
  left,

  /// right join
  right,

  /// full join
  full,
}

/// A class that represents a join in an SQL statement.
class Join {
  /// Creates a new join.
  const Join({
    required this.type,
    required this.table,
    required this.condition,
  });

  /// The type of join.
  final JoinType type;

  /// The table to join with.
  final String table;

  /// The condition for the join.
  final WhereCondition condition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Join &&
          type == other.type &&
          table == other.table &&
          condition == other.condition;

  @override
  int get hashCode => Object.hash(type, table, condition);

  @override
  String toString() =>
      'Join(type: $type, table: $table, condition: $condition)';
}
