import 'package:test/test.dart';

sealed class WhereClauseElement {}

enum ClauseOperator { equals, notEquals, greaterThan, lessThan }

enum LogicalOperator implements WhereClauseElement { and, or }

enum GroupingOperator implements WhereClauseElement { open, close }

class WhereCondition implements WhereClauseElement {
  final Operand leftOperand;
  final Operand rightOperand;
  final ClauseOperator clauseOperator;

  WhereCondition(this.leftOperand, this.clauseOperator, this.rightOperand);
}

sealed class Operand {}

class ColumnReferenceOperand implements Operand {
  final String value;
  ColumnReferenceOperand(this.value);
  @override
  String toString() => value;
}

class StringLiteralOperand implements Operand {
  final String value;
  StringLiteralOperand(this.value);
  @override
  String toString() => '"$value"';
}

class NumberLiteralOperand implements Operand {
  final num value;
  NumberLiteralOperand(this.value);
  @override
  String toString() => value.toString();
}

///This is an oversimplication. It may be slightly different for each
///db platform. However, it will be mostly the same for each platform and
///the key is only hooking into the platform specifics where necessary
String toSQL(List<WhereClauseElement> where) => 'WHERE ${where.map((element) {
      return switch (element) {
        (WhereCondition condition) =>
          '${condition.leftOperand}${getClauseOperatorSymbol(condition.clauseOperator)}${condition.rightOperand}',
        (LogicalOperator logicalOperator) =>
          getLogicalOperatorSymbol(logicalOperator),
        (GroupingOperator groupingOperator) =>
          getGroupingOperatorSymbol(groupingOperator),
      };
    }).join(' ')}';

String getClauseOperatorSymbol(ClauseOperator clauseOperator) =>
    switch (clauseOperator) {
      ClauseOperator.equals => '=',
      ClauseOperator.notEquals => '!=',
      ClauseOperator.greaterThan => '>',
      ClauseOperator.lessThan => '<',
    };

String getGroupingOperatorSymbol(GroupingOperator groupingOperator) =>
    switch (groupingOperator) {
      GroupingOperator.open => '(',
      GroupingOperator.close => ')',
    };

String getLogicalOperatorSymbol(LogicalOperator logicalOperator) =>
    switch (logicalOperator) {
      LogicalOperator.and => 'AND',
      LogicalOperator.or => 'OR',
    };

class WhereClauseBuilder {
  final List<WhereClauseElement> _whereClause = [];

  void condition(Operand leftOperand, ClauseOperator clauseOperator,
      Operand rightOperand) {
    _whereClause.add(WhereCondition(leftOperand, clauseOperator, rightOperand));
  }

  void logicalOperator(LogicalOperator logicalOperator) {
    _whereClause.add(logicalOperator);
  }

  void groupingOperator(GroupingOperator groupingOperator) {
    _whereClause.add(groupingOperator);
  }

  List<WhereClauseElement> build() {
    return _whereClause;
  }
}

void main() {
  test('Go', () {
    var whereClause = [
      WhereCondition(ColumnReferenceOperand('NAME'), ClauseOperator.equals,
          StringLiteralOperand('JIM')),
      LogicalOperator.and,
      GroupingOperator.open,
      WhereCondition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(123)),
      LogicalOperator.or,
      WhereCondition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(321)),
      GroupingOperator.close,
    ];

    var sql = toSQL((whereClause));

    expect(sql, 'WHERE NAME="JIM" AND ( ID=123 OR ID=321 )');
  });

  test('Builder Go', () {
    final builder = WhereClauseBuilder()
      ..condition(ColumnReferenceOperand('NAME'), ClauseOperator.equals,
          StringLiteralOperand('JIM'))
      ..logicalOperator(LogicalOperator.and)
      ..groupingOperator(GroupingOperator.open)
      ..condition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(123))
      ..logicalOperator(LogicalOperator.or)
      ..condition(ColumnReferenceOperand('ID'), ClauseOperator.equals,
          NumberLiteralOperand(321))
      ..groupingOperator(GroupingOperator.close);

    var sql = toSQL((builder.build()));

    expect(sql, 'WHERE NAME="JIM" AND ( ID=123 OR ID=321 )');
  });
}
