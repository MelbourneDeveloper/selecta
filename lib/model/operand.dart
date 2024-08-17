/// Represents an operand in a SQL expression.
sealed class Operand {}

/// Represents a column reference operand in a SQL expression.
final class ColumnReferenceOperand implements Operand {
  /// Creates a new column reference operand.
  const ColumnReferenceOperand(this.value);

  /// The value of the column reference operand.
  final String value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnReferenceOperand && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Represents a string literal operand in a SQL expression.
final class StringLiteralOperand implements Operand {
  /// Creates a new string literal operand.
  StringLiteralOperand(this.value);

  /// The value of the string literal operand.
  final String value;

  @override
  String toString() => '"$value"';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringLiteralOperand && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Represents a number literal operand in a SQL expression.
final class NumberLiteralOperand implements Operand {
  /// Creates a new number literal operand.
  NumberLiteralOperand(this.value);

  /// The value of the number literal operand.
  final num value;

  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberLiteralOperand && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
