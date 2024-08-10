import 'package:selecta/builders/join_builder.dart';
import 'package:selecta/builders/order_by_builder.dart';
import 'package:selecta/builders/where_clause_builder.dart';
import 'package:selecta/model/select_column.dart';
import 'package:selecta/model/select_statement.dart';

/// Create a [SelectStatement] using a builder
class SelectStatementBuilder {
  /// Create a new [SelectStatementBuilder] with a FROM clause
  SelectStatementBuilder({required this.from});

  final List<SelectedColumn> _selectedColumns = [];
  final WhereClauseBuilder _whereClauseBuilder = WhereClauseBuilder();
  final OrderByBuilder _orderByBuilder = OrderByBuilder();
  final JoinBuilder _joinBuilder = JoinBuilder();

  /// Set the FROM clause
  final String from;

  /// Add all columns to the select statement
  void selectAll() {
    _selectedColumns.add(AllColumns());
  }

  /// Add a specific column to the select statement
  void selectColumn(String columnName, {String? tableName}) {
    _selectedColumns.add(ColumnReference(columnName, tableName: tableName));
  }

  /// Access the WHERE clause builder
  WhereClauseBuilder get where => _whereClauseBuilder;

  /// Access the ORDER BY clause builder
  OrderByBuilder get orderBy => _orderByBuilder;

  /// Access the JOIN clause builder
  JoinBuilder get join => _joinBuilder;

  /// Build the [SelectStatement]
  SelectStatement build() => SelectStatement(
        from,
        _selectedColumns,
        where: _whereClauseBuilder.build(),
        orderBy: _orderByBuilder.build(),
        joins: _joinBuilder.build(),
      );
}

/// Extension methods for a more fluent API on SelectStatementBuilder
extension SelectStatementBuilderExtensions on SelectStatementBuilder {
  /// Fluent method to add a selected column
  SelectStatementBuilder withColumn(String columnName, {String? tableName}) {
    selectColumn(columnName, tableName: tableName);
    return this;
  }

  /// Fluent method to select all columns
  SelectStatementBuilder withAllColumns() {
    selectAll();
    return this;
  }
}
