sealed class Operand {}

class ColumnReferenceOperand implements Operand {
  final String value;
  ColumnReferenceOperand(this.value);
  @override
  String toString() => value;
}

class StringLiteralOperand implements Operand {
  final String value;
  StringLiteralOperand(this.value);
  @override
  String toString() => '"$value"';
}

class NumberLiteralOperand implements Operand {
  final num value;
  NumberLiteralOperand(this.value);
  @override
  String toString() => value.toString();
}
