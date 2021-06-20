import 'package:quantities/quantities.dart';
import 'package:quantities/src/prefixed_base_unit.dart';
import 'package:quantities/src/unit.dart';
import 'package:test/test.dart';

void checkNonDerivedUnit(
  Unit unit,
  PrefixedBaseUnit baseUnit,
) {
  expect(unit.unitsUp, [baseUnit]);
  expect(unit.unitsDown, isEmpty);
}

void checkDerivedUnit(
  Unit unit, {
  required List<PrefixedBaseUnit> unitsUp,
  required List<PrefixedBaseUnit> unitsDown,
}) {
  expect(unit.unitsUp, unorderedEquals(unitsUp));
  expect(unit.unitsDown, unorderedEquals(unitsDown));
}

void expectQuantity(Quantity actual, Quantity expected, double tolerance) {
  expect(actual.unit, expected.unit);
  expect(actual.value, closeTo(expected.value, tolerance));
}
