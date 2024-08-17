import 'package:flutter/material.dart';
import 'package:selecta/functions.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/sql_parser.dart';

class SqlNotifier extends ChangeNotifier {
  String _sql =
      '''SELECT employees.name, Departments.name FROM Employees INNER JOIN Departments ON Employees.department_id=Departments.id WHERE Employees.salary>50000 ORDER BY Employees.name ASC''';
  String get sql => _sql;
  String? _formattedSql;
  SelectStatement get selectStatement => toSelectStatement(_sql);
  String get formattedSql {
    try {
      return _formattedSql = statementToSql(
        selectStatement,
        allClausesFormatter: (clauses) => sqlFormatter(clauses, defaultOptions),
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return _formattedSql ?? _sql;
    }
  }

  set sql(String value) {
    _sql = value;
    notifyListeners();
  }
}
