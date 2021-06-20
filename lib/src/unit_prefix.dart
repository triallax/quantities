import 'package:meta/meta.dart';

import 'unit.dart' show Unit;
import 'unit.dart' as u;

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

  Unit get meter => u.meter.withPrefix(this);

  Unit get gram => u.gram.withPrefix(this);

  static const values = [kilo, deci, centi, milli, micro];

  @override
  String toString() => symbol;
}
