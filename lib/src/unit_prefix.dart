part of 'quantities.dart';

class UnitPrefix {
  const UnitPrefix._(this.value, this._symbol);

  final double value;

  final String _symbol;

  static const kilo = UnitPrefix._(1000, 'k');

  static const centi = UnitPrefix._(1 / 100, 'c');

  Unit get meter => Unit.nonDerived(LengthBaseUnit.meter, this);

  Unit get gram => Unit.nonDerived(MassBaseUnit.gram, this);

  @override
  String toString() => _symbol;
}
