import 'package:quantities/quantities.dart';
import 'package:quantities/src/base_unit.dart' show BaseUnit;
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void checkNonDerivedUnit(
  Unit unit, {
  UnitPrefix? prefix,
  required BaseUnit baseUnit,
}) {
  expect(unit.unitsUp, [Tuple2(baseUnit, prefix)]);
  expect(unit.unitsDown, isEmpty);
}

void checkDerivedUnit(
  Unit unit, {
  required List<Tuple2<BaseUnit, UnitPrefix?>> unitsUp,
  required List<Tuple2<BaseUnit, UnitPrefix?>> unitsDown,
}) {
  expect(unit.unitsUp, unorderedEquals(unitsUp));
  expect(unit.unitsDown, unorderedEquals(unitsDown));
}

void expectQuantity(Quantity actual, Quantity expected, double tolerance) {
  expect(actual.unit, expected.unit);
  expect(actual.value, closeTo(expected.value, tolerance));
}
