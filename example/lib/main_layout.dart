import 'package:example/firestore/firestore_setup_dialog.dart';
import 'package:example/main.dart';
import 'package:example/select_statment_treeview.dart';
import 'package:example/sql_editor.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';

/// A layout that displays an SQL editor and a tree view of the SQL statement.
class MainLayout extends StatefulWidget {
  /// Creates a new main layout.
  const MainLayout({
    required this.sqlNotifier,
    super.key,
  });

  /// The SQL notifier
  final SqlNotifier sqlNotifier;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  double _horizontalDividerPosition = 0.55;
  double _verticalDividerPosition = 0.4;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('selecta'),
          actions: [
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: () async => connectToFirestoreDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: (_verticalDividerPosition * 100).round(),
              child: Row(
                children: [
                  Expanded(
                    flex: (_horizontalDividerPosition * 100).round(),
                    child: _buildSqlEditorTabs(),
                  ),
                  _verticalDivider(context),
                  Expanded(
                    flex: ((1 - _horizontalDividerPosition) * 100).round(),
                    child: _treeViewPanel(),
                  ),
                ],
              ),
            ),
            _horizontalDivider(context),
            Expanded(
              flex: ((1 - _verticalDividerPosition) * 100).round(),
              child: _dataGridPlaceholder(),
            ),
          ],
        ),
      );

  Container _treeViewPanel() => Container(
        color: Colors.grey[200],
        child: ListenableBuilder(
          listenable: sqlNotifier,
          builder: (context, child) => SelectStatementTreeView(
            selectStatement: sqlNotifier.selectStatement,
          ),
        ),
      );

  MouseRegion _verticalDivider(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _horizontalDividerPosition +=
                  details.delta.dx / context.size!.width;
              _horizontalDividerPosition =
                  _horizontalDividerPosition.clamp(0.2, 0.8);
            });
          },
          child: Container(width: 8, color: Colors.grey),
        ),
      );

  MouseRegion _horizontalDivider(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            setState(() {
              _verticalDividerPosition +=
                  details.delta.dy / context.size!.height;
              _verticalDividerPosition =
                  _verticalDividerPosition.clamp(0.2, 0.8);
            });
          },
          child: Container(height: 8, color: Colors.grey),
        ),
      );

  Widget _buildSqlEditorTabs() => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'SQL Editor'),
                Tab(text: 'Formatted SQL'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SQLTextEditor(
                    sqlNotifier: widget.sqlNotifier,
                    isFormatted: false,
                  ),
                  SQLTextEditor(
                    sqlNotifier: widget.sqlNotifier,
                    isFormatted: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _dataGridPlaceholder() => Container(
        color: Colors.grey[100],
        child: const Center(
          child: Text(
            'Data Grid Placeholder',
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ),
      );
}
