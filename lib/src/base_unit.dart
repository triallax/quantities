part of 'quantities.dart';

abstract class BaseUnit {
  const BaseUnit(this.value, this.id, this.symbol);

  final double value;

  final String symbol;

  final int id;

  @factory
  static BaseUnit tryParse(String string) {
    for (final value in _values) {
      if (string == value.symbol) {
        return value;
      }
    }

    return null;
  }

  static const _values = [
    ...LengthBaseUnit.values,
    ...MassBaseUnit.values,
    ...TimeBaseUnit.values
  ];

  bool hasSameQuantity(BaseUnit that) => id == that.id;

  @override
  String toString() => symbol;
}
