import 'package:example/main.dart';
import 'package:example/sql_editor_layout.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SQL Editor Layout',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SQLEditorLayout(),
      );
}
