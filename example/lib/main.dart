import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/app_root.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';

/// A notifier for SQL statements.
final sqlNotifier = SqlNotifier();

/// The Firestore instance.
// ignore: unreachable_from_main
FirebaseFirestore? firestore;

void main() => runApp(
      AppRoot(
        sqlNotifier: sqlNotifier,
      ),
    );
