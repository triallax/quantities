import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@internal
const meterBaseUnit = BaseStandardUnit._('m');

@internal
const secondBaseUnit = BaseStandardUnit._('s');

@internal
const gramBaseUnit = BaseStandardUnit._('g');

@internal
@immutable
@sealed
class BaseUnit {
  const BaseUnit(this.symbol, this.factor, this.unitsUp, this.unitsDown);

  final String symbol;

  final List<BaseStandardUnit> unitsUp;

  final List<BaseStandardUnit> unitsDown;

  final double factor;

  @override
  String toString() => symbol;
}

@internal
class BaseStandardUnit implements BaseUnit {
  const BaseStandardUnit._(this.symbol);

  @override
  final String symbol;

  @override
  List<BaseStandardUnit> get unitsUp => [this];

  @override
  List<BaseStandardUnit> get unitsDown => const [];

  @override
  double get factor => 1;

  @override
  String toString() => symbol;
}

@internal
extension BaseUnitUtils on BaseUnit {
  bool hasSameQuantity(BaseUnit other) {
    const equality = UnorderedIterableEquality<BaseStandardUnit>();

    return identical(this, other) ||
        equality.equals(unitsUp, other.unitsUp) &&
            equality.equals(unitsDown, other.unitsDown);
  }
}
