import 'package:example/main.dart';
import 'package:example/select_statment_treeview.dart';
import 'package:example/sql_editor.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';

class SQLEditorLayout extends StatefulWidget {
  const SQLEditorLayout({
    required this.sqlNotifier,
    super.key,
  });

  final SqlNotifier sqlNotifier;

  @override
  State<SQLEditorLayout> createState() => _SQLEditorLayoutState();
}

class _SQLEditorLayoutState extends State<SQLEditorLayout> {
  double _verticalDividerPosition = 0.5;
  double _horizontalDividerPosition = 0.5;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: (_verticalDividerPosition * 100).round(),
              child: SQLEditor(
                sqlNotifier: widget.sqlNotifier,
                isFormatted: false,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _verticalDividerPosition +=
                      details.delta.dy / context.size!.height;
                  _verticalDividerPosition =
                      _verticalDividerPosition.clamp(0.1, 0.9);
                });
              },
              child: _horizontalDivider(),
            ),
            Expanded(
              flex: ((1 - _verticalDividerPosition) * 100).round(),
              child: Row(
                children: [
                  Expanded(
                    flex: (_horizontalDividerPosition * 100).round(),
                    child: _treeViewPanel(),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _horizontalDividerPosition +=
                            details.delta.dx / context.size!.width;
                        _horizontalDividerPosition =
                            _horizontalDividerPosition.clamp(0.1, 0.9);
                      });
                    },
                    child: _verticalDivider(),
                  ),
                  Expanded(
                    flex: ((1 - _horizontalDividerPosition) * 100).round(),
                    child: SQLEditor(
                      sqlNotifier: widget.sqlNotifier,
                      isFormatted: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Container _treeViewPanel() => Container(
        color: Colors.grey[200],
        child: SelectStatementTreeView(
          selectStatement: sqlNotifier.selectStatement,
        ),
      );

  Container _verticalDivider() => Container(
        width: 10,
        color: Colors.grey[300],
        child: Center(
          child: Container(
            width: 5,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );

  Container _horizontalDivider() => Container(
        height: 10,
        color: Colors.grey[300],
        child: Center(
          child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}