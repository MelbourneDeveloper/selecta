import 'package:dart_application_20/select_statement_builder.dart';
import 'package:dart_application_20/where_clause_element.dart';

class SelectStatement {
  SelectStatement(
    this.from,
    this.select, {
    required this.where,
  });

  final List<WhereClauseElement> where;
  final List<SelectedColumn> select;
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
