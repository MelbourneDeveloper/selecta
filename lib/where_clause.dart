import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/where_clause_element.dart';

class SelectStatement {
  SelectStatement(
    this.from,
    this.selectedColumns, {
    required this.where,
  });

  final List<WhereClauseElement> where;
  final List<SelectedColumn> selectedColumns;
  final String from;
}
