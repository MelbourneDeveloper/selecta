import 'package:selecta/model/join.dart';
import 'package:selecta/model/where_clause_element.dart';

/// A builder for creating [Join] clauses.
class JoinBuilder {
  final List<Join> _joins = [];

  /// Adds a join clause to the builder.
  void addJoin({
    required JoinType type,
    required String table,
    required WhereClauseGroup on,
  }) {
    _joins.add(
      Join(
        type: type,
        table: table,
        on: on,
      ),
    );
  }

  /// Builds the list of joins.
  List<Join> build() => _joins;
}

/// Extension methods for a more fluent API on JoinBuilder
extension JoinBuilderExtensions on JoinBuilder {
  /// Adds an INNER JOIN clause
  JoinBuilder innerJoin({
    required String table,
    required WhereClauseGroup on,
  }) {
    addJoin(
      type: JoinType.inner,
      table: table,
      on: on,
    );
    return this;
  }

  /// Adds a LEFT JOIN clause
  JoinBuilder leftJoin({
    required String table,
    required WhereClauseGroup on,
  }) {
    addJoin(
      type: JoinType.left,
      table: table,
      on: on,
    );
    return this;
  }

  /// Adds a RIGHT JOIN clause
  JoinBuilder rightJoin({
    required String table,
    required WhereClauseGroup on,
  }) {
    addJoin(
      type: JoinType.right,
      table: table,
      on: on,
    );
    return this;
  }

  /// Adds a FULL JOIN clause
  JoinBuilder fullJoin({
    required String table,
    required WhereClauseGroup on,
  }) {
    addJoin(
      type: JoinType.full,
      table: table,
      on: on,
    );
    return this;
  }
}
