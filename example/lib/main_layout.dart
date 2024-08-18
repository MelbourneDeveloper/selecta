import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/firestore/firestore_setup_dialog.dart';
import 'package:example/firestore/functions.dart';
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
  Stream<QuerySnapshot<Map<String, dynamic>>>? _snapshotsStream;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('selecta'),
          actions: [
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: () async {
                final fs = await connectToFirestoreDialog(context);
                setState(() => firestore = fs);
              },
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
              child: _dataPanel(),
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

  Widget _dataPanel() => Container(
        color: Colors.grey[100],
        child: SizedBox.expand(
          child: firestore != null
              ? Column(
                  children: [
                    Expanded(
                      child: _snapshotsStream != null
                          ? _getDataAndTable(_snapshotsStream!)
                          : const SizedBox.expand(),
                    ),
                    SizedBox(
                      width: 100,
                      height: 80,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => setState(
                            () => _snapshotsStream = firestore!
                                .getStream(sqlNotifier.selectStatement),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh),
                              Text('Go'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Text('Connect to Firestore to query'),
        ),
      );

  Widget _getDataAndTable(Stream<QuerySnapshot<Map<String, dynamic>>> stream) =>
      StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return _dataTable(docs);
        },
      );

  SingleChildScrollView _dataTable(
    List<QueryDocumentSnapshot<Object?>> docs,
  ) {
    // Get all unique field names from all documents
    final allFields = getFields(docs);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns:
              allFields.map((field) => DataColumn(label: Text(field))).toList(),
          rows: docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            return DataRow(
              cells: allFields.map((field) {
                final value = data[field]?.toString() ?? '';
                return DataCell(Text(value));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
