import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/sql.dart';

class SQLEditor extends StatefulWidget {
  const SQLEditor({required this.title, super.key});
  final String title;

  @override
  State<SQLEditor> createState() => _SQLEditorState();
}

class _SQLEditorState extends State<SQLEditor> {
  final CodeController codeController = CodeController(
    text: 'SELECT * FROM users',
    language: sql,
  );

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CodeTheme(
                  data: const CodeThemeData(styles: monokaiSublimeTheme),
                  child: CodeField(
                    onChanged: (t) {},
                    controller: codeController,
                    textStyle: const TextStyle(fontFamily: 'Inconsolata'),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
