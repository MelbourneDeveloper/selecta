import 'package:arborio/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:selecta/model/model.dart';
import 'package:selecta/model/order_by.dart';

/// A tree view of a select statement.
class SelectStatementTreeView extends StatelessWidget {
  /// Creates a new select statement tree view.
  const SelectStatementTreeView({required this.selectStatement, super.key});

  /// The select statement to display.
  final SelectStatement selectStatement;

  @override
  Widget build(BuildContext context) => TreeView<String>(
        nodes: _buildNodes(),
        builder: (context, node, isSelected, expansionAnimation, select) =>
            AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color:
                    _getColor(node.data).withOpacity(expansionAnimation.value),
                width: 2,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: true,
            leading: _getIcon(node.data),
            title: Text(
              node.data,
              style: TextStyle(
                color: _getColor(node.data),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onTap: () => select(node),
          ),
        ),
        expanderBuilder: (context, isExpanded, animationValue) =>
            TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: isExpanded ? 0.5 : 0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) => Transform.rotate(
            angle: value * 3.14159,
            child: Icon(
              Icons.chevron_right,
              color: Color.lerp(Colors.grey, Colors.blue, value),
              size: 18,
            ),
          ),
        ),
      );

  Color _getColor(String nodeData) => switch (nodeData.split(' ').first) {
        'SELECT' => Colors.green,
        'FROM' => Colors.orange,
        'JOINS' => Colors.purple,
        'WHERE' => Colors.red,
        'ORDER' => Colors.blue,
        _ => Colors.black,
      };

  Widget _getIcon(String nodeData) => Icon(
        switch (nodeData.split(' ').first) {
          'SELECT' => Icons.list_alt,
          'FROM' => Icons.table_chart,
          'JOINS' => Icons.link,
          'WHERE' => Icons.filter_alt,
          'ORDER' => Icons.sort,
          _ => Icons.code,
        },
        color: _getColor(nodeData),
        size: 18,
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
