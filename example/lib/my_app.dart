import 'package:example/sql_editor_layout.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    required this.sqlNotifier,
    super.key,
  });

  final SqlNotifier sqlNotifier;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SQL Editor Layout',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SQLEditorLayout(
          sqlNotifier: sqlNotifier,
        ),
      );
}
