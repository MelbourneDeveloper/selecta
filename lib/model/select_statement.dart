import 'package:dart_application_20/model/where_clause_element.dart';
import 'package:dart_application_20/model/select_column.dart';


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
