import 'package:example/my_app.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';

final sqlNotifier = SqlNotifier();

void main() => runApp(
      MyApp(
        sqlNotifier: sqlNotifier,
      ),
    );
