import 'package:selecta/model/order_by.dart';

/// A builder for creating ORDER BY clauses.
class OrderByBuilder {
  final List<OrderByElement> _orderByElements = [];

  /// Adds an ORDER BY column to the clause.
  void addColumn(
    String columnName, {
    String? tableName,
    SortDirection direction = SortDirection.ascending,
  }) {
    _orderByElements.add(
      OrderByColumn(
        columnName,
        tableName: tableName,
        direction: direction,
      ),
    );
  }

  /// Builds the ORDER BY clause.
  List<OrderByElement> build() => _orderByElements;
}

/// An extension on [OrderByBuilder] that provides a fluent API for
/// building ORDER BY clauses.
extension OrderByBuilderExtensions on OrderByBuilder {
  /// Adds an ascending ORDER BY column to the clause.
  void asc(String columnName, {String? tableName}) => addColumn(
        columnName,
        tableName: tableName,
      );

  /// Adds a descending ORDER BY column to the clause.
  void desc(String columnName, {String? tableName}) => addColumn(
        columnName,
        tableName: tableName,
        direction: SortDirection.descending,
      );

  /// Adds an ascending ORDER BY column to the clause with table name.
  void ascWithTable(String tableName, String columnName) => addColumn(
        columnName,
        tableName: tableName,
      );

  /// Adds a descending ORDER BY column to the clause with table name.
  void descWithTable(String tableName, String columnName) => addColumn(
        columnName,
        tableName: tableName,
        direction: SortDirection.descending,
      );
}
