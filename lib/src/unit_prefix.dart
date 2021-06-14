import 'package:meta/meta.dart';

import 'length_base_unit.dart';
import 'mass_base_unit.dart';
import 'unit.dart';

const kilo = UnitPrefix._(1000, 'k');

const deci = UnitPrefix._(1 / 10, 'd');

const centi = UnitPrefix._(1 / 100, 'c');

const milli = UnitPrefix._(1 / 1000, 'm');

const micro = UnitPrefix._(1 / 1000000, 'μ');

class UnitPrefix {
  const UnitPrefix._(this.value, this.symbol);

  final double value;

  @internal
  final String symbol;

  Unit get meter => Unit.nonDerived(LengthBaseUnit.meter, this);

  Unit get gram => Unit.nonDerived(MassBaseUnit.gram, this);

  static const values = [kilo, deci, centi, milli, micro];

  @override
  String toString() => symbol;
}
