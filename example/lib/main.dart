import 'package:example/app_root.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';

/// A notifier for SQL statements.
final sqlNotifier = SqlNotifier();

void main() => runApp(
      AppRoot(
        sqlNotifier: sqlNotifier,
      ),
    );
