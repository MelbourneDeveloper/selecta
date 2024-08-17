import 'package:code_text_field/code_text_field.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/sql.dart';

class SQLEditor extends StatefulWidget {
  const SQLEditor({
    required this.sqlNotifier,
    required this.isFormatted,
    super.key,
  });

  final SqlNotifier sqlNotifier;
  final bool isFormatted;

  @override
  State<SQLEditor> createState() => _SQLEditorState();
}

class _SQLEditorState extends State<SQLEditor> {
  late final CodeController codeController;

  @override
  void initState() {
    super.initState();
    codeController = CodeController(
      text: widget.sqlNotifier.sql,
      language: sql,
    );

    widget.sqlNotifier.addListener(() {
      codeController.text = widget.isFormatted
          ? widget.sqlNotifier.formattedSql
          : widget.sqlNotifier.sql;
    });
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.white,
        child: SizedBox(
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CodeTheme(
              data: const CodeThemeData(styles: monokaiSublimeTheme),
              child: ListenableBuilder(
                listenable: widget.sqlNotifier,
                builder: (context, child) => CodeField(
                  onChanged: (t) => widget.sqlNotifier.sql = t,
                  controller: codeController,
                  textStyle: const TextStyle(fontFamily: 'Inconsolata'),
                ),
              ),
            ),
          ),
        ),
      );
}
