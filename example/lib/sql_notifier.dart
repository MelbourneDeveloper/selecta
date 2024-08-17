import 'package:flutter/material.dart';
import 'package:selecta/functions.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/sql_parser.dart';

/// An empty SQL Statement
const _emptySelectStatement =
    SelectStatement('N/A', [], where: WhereClauseGroup([]));

/// A class that notifies listeners when the SQL statement changes.
class SqlNotifier extends ChangeNotifier {

  /// Creates a new SQL notifier.
  SqlNotifier() {
    sql =
        '''SELECT employees.name, Departments.name FROM Employees INNER JOIN Departments ON Employees.department_id=Departments.id WHERE Employees.salary>50000 ORDER BY Employees.name ASC''';
  }

  String _sql = '';

  /// The SQL statement as text
  String get sql => _sql;
  set sql(String value) {
    _sql = value;

    try {
      _selectStatement = toSelectStatement(_sql);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _selectStatement = selectStatement;
    }

    try {
      _formattedSql = statementToSql(
        _selectStatement,
        allClausesFormatter: (clauses) => sqlFormatter(clauses, defaultOptions),
      );
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } catch (e) {}

    notifyListeners();
  }

  String _formattedSql = '';
  SelectStatement _selectStatement = _emptySelectStatement;

  /// The SQL statement as a [SelectStatement]
  SelectStatement get selectStatement => _selectStatement;

  /// The SQL statement as formatted text
  String get formattedSql => _formattedSql;
}
