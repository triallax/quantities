import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import 'base_unit.dart';
import 'prefixed_base_unit.dart';
import 'unit_prefix.dart';
import 'units.dart';

final _baseUnitsMap = {
  for (final unit in [
    meter,
    inch,
    liter,
    mole,
    gram,
    pound,
    second,
    hour,
    day,
    week,
    month,
    year,
  ])
    unit.toString(): unit.baseUnit,
};

class _SameQuantityEquality implements Equality<BaseUnit> {
  const _SameQuantityEquality();

  @override
  bool equals(BaseUnit unit1, BaseUnit unit2) => unit1.hasSameQuantity(unit2);

  @override
  int hash(BaseUnit unit) => unit.hashCode;

  @override
  bool isValidKey(Object? obj) => obj is BaseUnit;
}

@internal
class NonDerivedUnit extends Unit {
  NonDerivedUnit(this.baseUnit) : super._([baseUnit], const []);

  final PrefixedBaseUnit baseUnit;

  NonDerivedUnit withPrefix(UnitPrefix newPrefix) =>
      NonDerivedUnit(baseUnit.withPrefix(newPrefix));
}

class Unit {
  const Unit._(this._unitsUp, this._unitsDown);

  factory Unit._derived(
      List<PrefixedBaseUnit> unitsUp, List<PrefixedBaseUnit> unitsDown) {
    final newUnitsUp = unitsUp.toList();
    final newUnitsDown = unitsDown.toList();

    for (final unit in unitsUp) {
      if (newUnitsDown.remove(unit)) {
        newUnitsUp.remove(unit);
      }
    }

    return Unit._(newUnitsUp, newUnitsDown);
  }

  static const unity = Unit._([], []);

  /// Parses [string] to a unit and adds it to [list] if necessary.
  ///
  /// Returns `false` if parsing failed.
  static bool _parseAndAddPrefixedBaseUnitToList(
      List<PrefixedBaseUnit> list, String string) {
    if (string == '1') {
      return true;
    }

    if (string.isEmpty) {
      return false;
    }

    if (_baseUnitsMap.containsKey(string)) {
      list.add(_baseUnitsMap[string]!);
      return true;
    }

    final firstBaseUnitChar = string[0];

    final unitPrefixMatch = UnitPrefix.values
        .firstWhereOrNull((prefix) => prefix.symbol == firstBaseUnitChar);

    final UnitPrefix? prefix;
    final String baseUnitString;

    if (unitPrefixMatch != null) {
      baseUnitString = string.substring(1);
      prefix = unitPrefixMatch;
    } else {
      baseUnitString = string;
      prefix = null;
    }

    if (_baseUnitsMap.containsKey(baseUnitString)) {
      list.add(_baseUnitsMap[baseUnitString]!.withPrefix(prefix));
      return true;
    }

    return false;
  }

  /// Convert [string] to a unit, returning null in case the string couldn't
  /// be parsed.
  ///
  /// This method and [toString()] are *NOT* the opposite of each other. This
  /// is intentionally, since writing a method that can parse the string
  /// returned by [toString()] is not very easy and this method isn't intended
  /// to parse units from the user. Here are the differences:
  /// - [toString()] uses `·` as a multiplication symbol, while this method
  ///   uses `*`.
  /// - [toString()] uses parenthesis sometimes, while this method can't parse
  ///   them.
  /// - [toString()] can print powers, while this method can't parse them. You
  ///   can repeat the units instead.
  @factory
  // ignore: prefer_constructors_over_static_methods
  static Unit? tryParse(String string) {
    final unitsUp = <PrefixedBaseUnit>[];
    final unitsDown = <PrefixedBaseUnit>[];

    final list = string.split(RegExp('(?=[*/])'));

    if (!_parseAndAddPrefixedBaseUnitToList(unitsUp, list[0])) {
      return null;
    }

    for (final string in list.skip(1)) {
      final List<PrefixedBaseUnit> list;

      switch (string[0]) {
        case '/':
          list = unitsDown;
          break;

        case '*':
          list = unitsUp;
          break;

        default:
          return null;
      }

      if (!_parseAndAddPrefixedBaseUnitToList(list, string.substring(1))) {
        return null;
      }
    }

    return Unit._derived(unitsUp, unitsDown);
  }

  final List<PrefixedBaseUnit> _unitsUp;

  final List<PrefixedBaseUnit> _unitsDown;

  Unit get reciprocal => Unit._(_unitsDown, _unitsUp);

  Unit operator *(Unit that) => Unit._derived(
        [..._unitsUp, ...that._unitsUp],
        [..._unitsDown, ...that._unitsDown],
      );

  Unit operator /(Unit that) => Unit._derived(
        [..._unitsUp, ...that._unitsDown],
        [..._unitsDown, ...that._unitsUp],
      );

  String _intToSuperscript(int i) {
    assert(i > 0);

    const superscriptDigitMap = {
      0: '⁰',
      1: '¹',
      2: '²',
      3: '³',
      4: '⁴',
      5: '⁵',
      6: '⁶',
      7: '⁷',
      8: '⁸',
      9: '⁹',
    };

    final list = <String>[];

    while (i > 0) {
      list.insert(0, superscriptDigitMap[i % 10]!);
      // ignore: parameter_assignments
      i = i ~/ 10;
    }

    return list.join();
  }

  Iterable<String> _unitsToStrings(List<PrefixedBaseUnit> list) sync* {
    final map = <PrefixedBaseUnit, int>{};

    for (final prefixedUnit in list) {
      if (map.containsKey(prefixedUnit)) {
        map[prefixedUnit] = map[prefixedUnit]! + 1;
      } else {
        map[prefixedUnit] = 1;
      }
    }

    for (final entry in map.entries) {
      final unitString = entry.key.toString();

      if (entry.value == 1) {
        yield unitString;
        continue;
      }

      yield '$unitString${_intToSuperscript(entry.value)}';
    }
  }

  @override
  String toString() {
    if (this == unity) {
      return '1';
    }

    final buffer = StringBuffer();

    if (_unitsUp.isEmpty) {
      buffer.write('1');
    } else {
      buffer.writeAll(_unitsToStrings(_unitsUp), ' · ');
    }

    if (_unitsDown.isNotEmpty) {
      buffer.write(' / ');
      final stringList = _unitsToStrings(_unitsDown).toList(growable: false);

      if (stringList.length == 1) {
        buffer.write(stringList[0]);
      } else {
        buffer.write('(');
        buffer.writeAll(stringList, ' · ');
        buffer.write(')');
      }
    }

    return buffer.toString();
  }

  bool canBeConvertedTo(Unit other) =>
      toStandardUnits().canBeConvertedTo(other.toStandardUnits());

  @override
  int get hashCode {
    const equality = UnorderedIterableEquality<PrefixedBaseUnit>();

    return equality.hash(_unitsUp) ^ equality.hash(_unitsDown);
  }

  @override
  bool operator ==(dynamic that) {
    const equality = UnorderedIterableEquality<PrefixedBaseUnit>();

    return identical(this, that) ||
        (that is Unit &&
            equality.equals(that._unitsUp, _unitsUp) &&
            equality.equals(that._unitsDown, _unitsDown));
  }
}

@internal
extension UnitUtils on Unit {
  Tuple2<Unit, double> simplify() {
    final newUnitsUp = _unitsUp.toList();
    final newUnitsDown = _unitsDown.toList();
    var valueMultiple = 1.0;

    for (final unitUp in _unitsUp) {
      if (newUnitsDown.remove(unitUp)) {
        newUnitsUp.remove(unitUp);
        continue;
      }

      final unitDown = newUnitsDown.firstWhereOrNull(
        (elem) => unitUp.baseUnit.hasSameQuantity(elem.baseUnit),
      );

      if (unitDown != null) {
        newUnitsUp.remove(unitUp);
        newUnitsDown.remove(unitDown);
        valueMultiple *=
            (unitUp.baseUnit.factor * (unitUp.prefix?.value ?? 1)) /
                (unitDown.baseUnit.factor * (unitDown.prefix?.value ?? 1));
      }
    }

    return Tuple2(Unit._(newUnitsUp, newUnitsDown), valueMultiple);
  }

  Tuple3<List<BaseStandardUnit>, List<BaseStandardUnit>, double>
      toStandardUnits() {
    final standardUnitsUp = <BaseStandardUnit>[];
    final standardUnitsDown = <BaseStandardUnit>[];
    var factor = 1.0;

    for (final unit in _unitsUp) {
      if (unit.prefix != null) {
        factor *= unit.prefix!.value;
      }

      factor *= unit.baseUnit.factor;

      standardUnitsUp.addAll(unit.baseUnit.unitsUp);
      standardUnitsDown.addAll(unit.baseUnit.unitsDown);
    }

    for (final unit in _unitsDown) {
      if (unit.prefix != null) {
        factor /= unit.prefix!.value;
      }

      factor /= unit.baseUnit.factor;

      standardUnitsUp.addAll(unit.baseUnit.unitsDown);
      standardUnitsDown.addAll(unit.baseUnit.unitsUp);
    }

    return Tuple3(standardUnitsUp, standardUnitsDown, factor);
  }

  List<PrefixedBaseUnit> get unitsUp => _unitsUp;

  List<PrefixedBaseUnit> get unitsDown => _unitsDown;
}

@internal
extension CompareStandardUnits
    on Tuple3<List<BaseStandardUnit>, List<BaseStandardUnit>, double> {
  bool canBeConvertedTo(
      Tuple3<List<BaseStandardUnit>, List<BaseStandardUnit>, double> other) {
    const equality = UnorderedIterableEquality(_SameQuantityEquality());

    return equality.equals(item1, other.item1) &&
        equality.equals(item2, other.item2);
  }
}
