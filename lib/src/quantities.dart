import 'package:meta/meta.dart';

import 'unit.dart';

@immutable
class Quantity implements Comparable<Quantity> {
  factory Quantity(double value, [Unit unit = Unit.unity]) {
    if (unit == Unit.unity) {
      return Quantity._(value, unit);
    }

    final tuple = unit.simplify();
    return Quantity._(value * tuple.item2, tuple.item1);
  }

  const Quantity._(this.value, this.unit);

  final double value;

  final Unit unit;

  Quantity operator +(Quantity that) => Quantity._(value + that.to(unit), unit);

  Quantity operator -(Quantity that) => Quantity._(value - that.to(unit), unit);

  Quantity operator -() => Quantity._(-value, unit);

  Quantity operator *(Quantity that) {
    final tuple = (unit * that.unit).simplify();
    final newValue = value * that.value * tuple.item2;

    return Quantity._(newValue, tuple.item1);
  }

  Quantity operator /(Quantity that) {
    final tuple = (unit / that.unit).simplify();
    final newValue = (value / that.value) * tuple.item2;

    return Quantity._(newValue, tuple.item1);
  }

  Quantity abs() {
    if (value.isNegative) {
      return -this;
    }
    return this;
  }

  double to(Unit newUnit) {
    if (unit == newUnit) return value;

    final oldStandardUnits = unit.toStandardUnits();
    final newStandardUnits = newUnit.toStandardUnits();

    if (!oldStandardUnits.canBeConvertedTo(newStandardUnits)) {
      throw ArgumentError("Can't convert $this to $newUnit");
    }

    // Read `isFinite`'s docs.
    if (!value.isFinite) {
      return value;
    }

    return value * oldStandardUnits.item3 / newStandardUnits.item3;
  }

  bool operator <(Quantity that) => value < that.to(unit);

  bool operator <=(Quantity that) => value <= that.to(unit);

  bool operator >(Quantity that) => value > that.to(unit);

  bool operator >=(Quantity that) => value >= that.to(unit);

  @override
  int compareTo(Quantity quantity) => value.compareTo(quantity.to(unit));

  @override
  bool operator ==(Object that) =>
      identical(this, that) ||
      (that is Quantity &&
          runtimeType == that.runtimeType &&
          value == that.value &&
          unit == that.unit);

  @override
  int get hashCode => runtimeType.hashCode ^ value.hashCode ^ unit.hashCode;

  @override
  String toString() {
    var valueString = value.toString();

    if (valueString.endsWith('.0')) {
      valueString = valueString.substring(0, valueString.length - 2);
    }

    if (unit == Unit.unity) return valueString;

    return '$valueString $unit';
  }

  Duration toDuration() =>
      Duration(microseconds: (to(second) * 1000000).truncate());
}

extension NumToQuantity on num {
  Quantity call([Unit unit = Unit.unity]) => Quantity(toDouble(), unit);
}
