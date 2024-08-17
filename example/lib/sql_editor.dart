import 'package:code_text_field/code_text_field.dart';
import 'package:example/sql_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/sql.dart';

/// An SQL editor.
class SQLTextEditor extends StatefulWidget {
  /// Creates a new SQL text editor.
  const SQLTextEditor({
    required this.sqlNotifier,
    required this.isFormatted,
    super.key,
  });

  /// The SQL notifier
  final SqlNotifier sqlNotifier;

  /// Whether the SQL statement is formatted
  final bool isFormatted;

  @override
  State<SQLTextEditor> createState() => _SQLTextEditorState();
}

class _SQLTextEditorState extends State<SQLTextEditor> {
  late final CodeController _codeController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '',
      language: sql,
    );

    widget.sqlNotifier.addListener(_updateControllerText);

    _updateControllerText();
  }

  void _updateControllerText() {
    if (!_isUpdating) {
      _isUpdating = true;
      final newText = widget.isFormatted
          ? widget.sqlNotifier.formattedSql
          : widget.sqlNotifier.sql;

      if (_codeController.text != newText) {
        _codeController.value = _codeController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
      _isUpdating = false;
    }
  }

  void _handleTextChanged(String newText) {
    if (!_isUpdating) {
      _isUpdating = true;
      widget.sqlNotifier.sql = newText;
      _isUpdating = false;
    }
  }

  @override
  void dispose() {
    widget.sqlNotifier.removeListener(_updateControllerText);
    _codeController.dispose();
    super.dispose();
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
              child: CodeField(
                controller: _codeController,
                onChanged: _handleTextChanged,
                textStyle: const TextStyle(fontFamily: 'Inconsolata'),
              ),
            ),
          ),
        ),
      );
}
