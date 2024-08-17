import 'package:example/sql_editor_layout.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';

/// The root of the widget tree
class AppRoot extends StatelessWidget {
  /// Creates a new app root
  const AppRoot({
    required this.sqlNotifier,
    super.key,
  });

  /// The SQL notifier
  final SqlNotifier sqlNotifier;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SQL Editor Layout',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainLayout(
          sqlNotifier: sqlNotifier,
        ),
      );
}
