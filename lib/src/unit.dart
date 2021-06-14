import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import 'base_unit.dart';
import 'length_base_unit.dart';
import 'mass_base_unit.dart';
import 'time_base_unit.dart';
import 'unit_prefix.dart';

final meter = Unit.nonDerived(LengthBaseUnit.meter);

final inch = Unit.nonDerived(LengthBaseUnit.inch);

final squareMeter = meter * meter;

final gram = Unit.nonDerived(MassBaseUnit.gram);

final pound = Unit.nonDerived(MassBaseUnit.pound);

final second = Unit.nonDerived(TimeBaseUnit.second);

final hour = Unit.nonDerived(TimeBaseUnit.hour);

final day = Unit.nonDerived(TimeBaseUnit.day);

final week = Unit.nonDerived(TimeBaseUnit.week);

final month = Unit.nonDerived(TimeBaseUnit.month);

final year = Unit.nonDerived(TimeBaseUnit.year);

class _SameQuantityTupleEquality
    implements Equality<Tuple2<BaseUnit, UnitPrefix?>> {
  const _SameQuantityTupleEquality();

  @override
  bool equals(Tuple2<BaseUnit, UnitPrefix?> unit1,
          Tuple2<BaseUnit, UnitPrefix?> unit2) =>
      unit1.item1.hasSameQuantity(unit2.item1);

  @override
  int hash(Tuple2<BaseUnit, UnitPrefix?> unit) => unit.item1.id;

  @override
  bool isValidKey(Object? obj) => obj is Tuple2<BaseUnit, UnitPrefix?>;
}

class Unit {
  const Unit._(this.unitsUp, this.unitsDown);

  @internal
  Unit.nonDerived(BaseUnit baseUnit, [UnitPrefix? prefix])
      : unitsUp = [Tuple2(baseUnit, prefix)],
        unitsDown = const [];

  @internal
  factory Unit.derived(List<Tuple2<BaseUnit, UnitPrefix?>> unitsUp,
      List<Tuple2<BaseUnit, UnitPrefix?>> unitsDown) {
    final newUnitsUp = unitsUp.toList();
    final newUnitsDown = unitsDown.toList();

    for (final tuple in unitsUp) {
      if (newUnitsDown.remove(tuple)) {
        newUnitsUp.remove(tuple);
      }
    }

    return Unit._(newUnitsUp, newUnitsDown);
  }

  static const unity = Unit._([], []);

  /// Parses [string] to a unit and adds it to [list] if necessary.
  ///
  /// Returns `false` if parsing failed.
  static bool _parseAndAddTupleToList(
      List<Tuple2<BaseUnit, UnitPrefix?>> list, String string) {
    if (string == '1') {
      return true;
    }

    if (string.isEmpty) {
      return false;
    }

    final initialBaseUnit = BaseUnit.tryParse(string);

    if (initialBaseUnit != null) {
      list.add(Tuple2(initialBaseUnit, null));
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

    final baseUnit = BaseUnit.tryParse(baseUnitString);
    if (baseUnit != null) {
      list.add(Tuple2(baseUnit, prefix));
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
    final unitsUp = <Tuple2<BaseUnit, UnitPrefix?>>[];
    final unitsDown = <Tuple2<BaseUnit, UnitPrefix?>>[];

    final list = string.split(RegExp('(?=[*/])'));

    if (!_parseAndAddTupleToList(unitsUp, list[0])) {
      return null;
    }

    for (final string in list.skip(1)) {
      final List<Tuple2<BaseUnit, UnitPrefix?>> list;

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

      if (!_parseAndAddTupleToList(list, string.substring(1))) {
        return null;
      }
    }

    return Unit.derived(unitsUp, unitsDown);
  }

  @internal
  Tuple2<Unit, double> simplify() {
    final newUnitsUp = unitsUp.toList();
    final newUnitsDown = unitsDown.toList();
    var valueMultiple = 1.0;

    for (final upTuple in unitsUp) {
      if (newUnitsDown.remove(upTuple)) {
        newUnitsUp.remove(upTuple);
        continue;
      }

      final downTuple = newUnitsDown.firstWhereOrNull(
        (elem) => upTuple.item1.hasSameQuantity(elem.item1),
      );

      if (downTuple != null) {
        newUnitsUp.remove(upTuple);
        newUnitsDown.remove(downTuple);
        valueMultiple *= (upTuple.item1.value * (upTuple.item2?.value ?? 1)) /
            (downTuple.item1.value * (downTuple.item2?.value ?? 1));
      }
    }

    return Tuple2(Unit._(newUnitsUp, newUnitsDown), valueMultiple);
  }

  @internal
  final List<Tuple2<BaseUnit, UnitPrefix?>> unitsUp;

  @internal
  final List<Tuple2<BaseUnit, UnitPrefix?>> unitsDown;

  Unit get reciprocal => Unit._(unitsDown, unitsUp);

  Unit operator *(Unit that) => Unit.derived(
        [...unitsUp, ...that.unitsUp],
        [...unitsDown, ...that.unitsDown],
      );

  Unit operator /(Unit that) => Unit.derived(
        [...unitsUp, ...that.unitsDown],
        [...unitsDown, ...that.unitsUp],
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

  Iterable<String> _tupleListToStrings(
      List<Tuple2<BaseUnit, UnitPrefix?>> list) sync* {
    final map = <Tuple2<BaseUnit, UnitPrefix?>, int>{};

    for (final tuple in list) {
      if (map.containsKey(tuple)) {
        map[tuple] = map[tuple]! + 1;
      } else {
        map[tuple] = 1;
      }
    }

    for (final entry in map.entries) {
      final unitString = _unitTupleToString(entry.key);

      if (entry.value == 1) {
        yield unitString;
        continue;
      }

      yield '$unitString${_intToSuperscript(entry.value)}';
    }
  }

  String _unitTupleToString(Tuple2<BaseUnit, UnitPrefix?> tuple) {
    if (tuple.item2 == null) return tuple.item1.toString();

    return '${tuple.item2}${tuple.item1}';
  }

  @override
  String toString() {
    if (this == unity) {
      return '1';
    }

    final buffer = StringBuffer();

    if (unitsUp.isEmpty) {
      buffer.write('1');
    } else {
      buffer.writeAll(_tupleListToStrings(unitsUp), ' · ');
    }

    if (unitsDown.isNotEmpty) {
      buffer.write(' / ');
      final stringList = _tupleListToStrings(unitsDown).toList(growable: false);

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

  bool canBeConvertedTo(Unit other) {
    const equality = UnorderedIterableEquality(_SameQuantityTupleEquality());

    return equality.equals(unitsUp, other.unitsUp) &&
        equality.equals(unitsDown, other.unitsDown);
  }

  @override
  int get hashCode {
    const equality = UnorderedIterableEquality<Tuple2<BaseUnit, UnitPrefix?>>();

    return runtimeType.hashCode ^
        equality.hash(unitsUp) ^
        equality.hash(unitsDown);
  }

  @override
  bool operator ==(dynamic that) {
    const equality = UnorderedIterableEquality<Tuple2<BaseUnit, UnitPrefix?>>();

    return identical(this, that) ||
        (that is Unit &&
            that.runtimeType == runtimeType &&
            equality.equals(that.unitsUp, unitsUp) &&
            equality.equals(that.unitsDown, unitsDown));
  }
}
