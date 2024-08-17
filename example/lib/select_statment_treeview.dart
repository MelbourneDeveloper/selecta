import 'package:arborio/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

class SelectStatementTreeView extends StatelessWidget {
  const SelectStatementTreeView({required this.selectStatement, super.key});

  final SelectStatement selectStatement;

  @override
    @override
  Widget build(BuildContext context) => TreeView<String>(
        nodes: _buildNodes(),
        builder: (context, node, isSelected, expansionAnimation, select) =>
            ListTile(
          title: Text(node.data),
          selected: isSelected,
          onTap: () => select(node),
        ),
        expanderBuilder: (context, isExpanded, animationValue) =>
            RotationTransition(
          turns: animationValue,
          child: const Icon(Icons.chevron_right),
        ),
      );

  List<TreeNode<String>> _buildNodes() => [
        TreeNode<String>(
          const Key('select'),
          'SELECT',
          _buildSelectNodes(),
        ),
        TreeNode<String>(
          const Key('from'),
          'FROM ${selectStatement.from}',
        ),
        if (selectStatement.joins.isNotEmpty)
          TreeNode<String>(
            const Key('joins'),
            'JOINS',
            _buildJoinNodes(),
          ),
        TreeNode<String>(
          const Key('where'),
          'WHERE',
          _buildWhereNodes(selectStatement.where),
        ),
        if (selectStatement.orderBy.isNotEmpty)
          TreeNode<String>(
            const Key('orderBy'),
            'ORDER BY',
            _buildOrderByNodes(),
          ),
      ];

  List<TreeNode<String>> _buildSelectNodes() =>
      selectStatement.select.map((column) {
        if (column is AllColumns) {
          return TreeNode<String>(
            Key(column.toString()),
            column.tableName != null ? '${column.tableName}.*' : '*',
          );
        } else if (column is ColumnReference) {
          return TreeNode<String>(
            Key(column.toString()),
            column.tableName != null
                ? '${column.tableName}.${column.columnName}'
                : column.columnName,
          );
        }
        return TreeNode<String>(Key(column.toString()), column.toString());
      }).toList();

  List<TreeNode<String>> _buildJoinNodes() => selectStatement.joins
      .map(
        (join) => TreeNode<String>(
          Key(join.toString()),
          '${join.type.name.toUpperCase()} JOIN ${join.table}',
          _buildWhereNodes(join.on),
        ),
      )
      .toList();

  List<TreeNode<String>> _buildWhereNodes(WhereClauseGroup whereClause) =>
      whereClause.elements.map((element) {
        if (element is WhereCondition) {
          return TreeNode<String>(
            Key(element.toString()),
            '${_operandToString(element.leftOperand)} '
            '${_operatorToString(element.clauseOperator)} '
            '${_operandToString(element.rightOperand)}',
          );
        } else if (element is LogicalOperator) {
          return TreeNode<String>(
            Key(element.toString()),
            element.name.toUpperCase(),
          );
        } else if (element is GroupingOperator) {
          return TreeNode<String>(
            Key(element.toString()),
            element == GroupingOperator.open ? '(' : ')',
          );
        } else if (element is WhereClauseGroup) {
          return TreeNode<String>(
            Key(element.toString()),
            'Group',
            _buildWhereNodes(element),
          );
        }
        return TreeNode<String>(Key(element.toString()), element.toString());
      }).toList();

  List<TreeNode<String>> _buildOrderByNodes() =>
      selectStatement.orderBy.map((orderBy) {
        if (orderBy is OrderByColumn) {
          return TreeNode<String>(
            Key(orderBy.toString()),
            '${orderBy.tableName != null ? '${orderBy.tableName}.' : ''}'
            '${orderBy.columnName} ${orderBy.direction.name.toUpperCase()}',
          );
        }
        return TreeNode<String>(Key(orderBy.toString()), orderBy.toString());
      }).toList();

  String _operandToString(Operand operand) {
    if (operand is ColumnReferenceOperand) {
      return operand.value;
    } else if (operand is StringLiteralOperand) {
      return "'${operand.value}'";
    } else if (operand is NumberLiteralOperand) {
      return operand.value.toString();
    }
    return operand.toString();
  }

  String _operatorToString(ClauseOperator operator) {
    switch (operator) {
      case ClauseOperator.equals:
        return '=';
      case ClauseOperator.notEquals:
        return '!=';
      case ClauseOperator.greaterThan:
        return '>';
      case ClauseOperator.greaterThanEqualTo:
        return '>=';
      case ClauseOperator.lessThan:
        return '<';
      case ClauseOperator.lessThanEqualTo:
        return '<=';
      case ClauseOperator.like:
        return 'LIKE';
    }
  }
}
