sealed class Operand {}

final class ColumnReferenceOperand implements Operand {
  const ColumnReferenceOperand(this.value);
  final String value;
  @override
  String toString() => value;
}

final class StringLiteralOperand implements Operand {
  StringLiteralOperand(this.value);
  final String value;
  @override
  String toString() => '"$value"';
}

final class NumberLiteralOperand implements Operand {
  NumberLiteralOperand(this.value);
  final num value;
  @override
  String toString() => value.toString();
}
