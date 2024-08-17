# selecta

A model that represents SQL Select queries, and tools to convert from SQL/JSON to the model and back

Try it out [here](https://melbournedeveloper.github.io/selecta/). This example uses the [arborio](https://pub.dev/packages/arborio) package to display the tree view.

![Video](https://github.com/MelbourneDeveloper/selecta/blob/main/documents/example.mov)

You can do like this:

```dart
final selectStatement = toSelectStatement('SELECT id, name FROM Users');
print('Columns: ${selectStatement.select} From: ${selectStatement.from}');
```

Output
```
Columns: [ColumnReference (id), ColumnReference (name)] From: Users
```