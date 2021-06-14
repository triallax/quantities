import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart' show Tuple2;

import 'length_base_unit.dart';
import 'mass_base_unit.dart';
import 'time_base_unit.dart';

part 'unit.dart';
part 'base_unit.dart';
part 'unit_prefix.dart';

class Quantity implements Comparable<Quantity> {
  factory Quantity(num value, [Unit unit = Unit.unity]) {
    if (unit == Unit.unity) {
      return Quantity._(value.toDouble(), unit);
    }

    final tuple = unit.simplify();
    return Quantity._(value.toDouble() * tuple.item2, tuple.item1);
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
    if (!unit.canBeConvertedTo(newUnit)) {
      throw ArgumentError("Can't convert $this to $newUnit");
    }

    if (value.isNaN ||
        value == double.negativeInfinity ||
        value == double.infinity) {
      return value;
    }

    if (unit == newUnit) {
      return value;
    }
    int compareTuples(Tuple2<BaseUnit, UnitPrefix?> tuple1,
            Tuple2<BaseUnit, UnitPrefix?> tuple2) =>
        tuple1.item1.id.compareTo(tuple2.item1.id);

    final oldSortedUnitsUp = unit.unitsUp.toList()..sort(compareTuples);
    final oldSortedUnitsDown = unit.unitsDown.toList()..sort(compareTuples);
    final newSortedUnitsUp = newUnit.unitsUp.toList()..sort(compareTuples);
    final newSortedUnitsDown = newUnit.unitsDown.toList()..sort(compareTuples);

    var thisMultiple = 1.0;
    var thatMultiple = 1.0;

    oldSortedUnitsUp.asMap().forEach((index, tuple) {
      if (tuple.item2 != null) {
        thisMultiple *= tuple.item2!.value;
      }

      final newTuple = newSortedUnitsUp[index];
      if (newTuple.item2 != null) {
        thatMultiple *= newTuple.item2!.value;
      }

      if (newTuple.item1 != tuple.item1) {
        thisMultiple *= tuple.item1.value;
        thatMultiple *= newTuple.item1.value;
      }
    });

    oldSortedUnitsDown.asMap().forEach((index, tuple) {
      if (tuple.item2 != null) {
        thisMultiple /= tuple.item2!.value;
      }

      final newTuple = newSortedUnitsDown[index];
      if (newTuple.item2 != null) {
        thatMultiple /= newTuple.item2!.value;
      }

      if (newTuple.item1 != tuple.item1) {
        thisMultiple /= tuple.item1.value;
        thatMultiple /= newTuple.item1.value;
      }
    });

    return value * thisMultiple / thatMultiple;
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
  Quantity call([Unit unit = Unit.unity]) => Quantity(this, unit);
}
