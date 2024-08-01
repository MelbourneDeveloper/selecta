import 'package:dart_application_20/model/operand.dart';
import 'package:dart_application_20/model/where_clause_element.dart';

class WhereClauseBuilder {
  final List<WhereClauseElement> _whereClause = [];

  void condition(
    Operand leftOperand,
    ClauseOperator clauseOperator,
    Operand rightOperand,
  ) {
    _whereClause.add(WhereCondition(leftOperand, clauseOperator, rightOperand));
  }

  void logicalOperator(LogicalOperator logicalOperator) {
    _whereClause.add(logicalOperator);
  }

  void groupingOperator(GroupingOperator groupingOperator) {
    _whereClause.add(groupingOperator);
  }

  List<WhereClauseElement> build() => _whereClause;
}
