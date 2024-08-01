# selecta

A model that represents SQL Select queries, and tools to convert from SQL/JSON to the model and back

You can do like this:

```dart
final selectStatement = toSelectStatement('SELECT id, name FROM Users');
print('Columns: ${selectStatement.select} From: ${selectStatement.from}');
```

Output
```
Columns: [ColumnReference (id), ColumnReference (name)] From: Users
```