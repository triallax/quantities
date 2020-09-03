import 'package:test/test.dart';
import 'package:quantities/src/mass_base_unit.dart';
import 'package:quantities/src/length_base_unit.dart';
import 'package:quantities/src/time_base_unit.dart';
import 'package:quantities/quantities.dart';
import 'package:tuple/tuple.dart';

import 'utils.dart';

void main() {
  group('UnitPrefix', () {
    test('== is reflexive', () {
      expect(UnitPrefix.kilo, UnitPrefix.kilo);
      expect(UnitPrefix.centi, UnitPrefix.centi);
    });

    test('toString returns correct string', () {
      expect(kilo.toString(), 'k');
      expect(centi.toString(), 'c');
    });

    test('gram returns correct unit', () {
      checkNonDerivedUnit(
        kilo.gram,
        prefix: kilo,
        baseUnit: MassBaseUnit.gram,
      );
    });

    test('meter returns correct unit', () {
      checkNonDerivedUnit(
        centi.meter,
        prefix: centi,
        baseUnit: LengthBaseUnit.meter,
      );
    });
  });

  test('global prefix consts are equal to consts in UnitPrefix', () {
    expect(kilo, UnitPrefix.kilo);
    expect(centi, UnitPrefix.centi);
  });

  test('squareMeter is the same as meter * meter', () {
    expect(squareMeter, meter * meter);
  });

  group('Unit', () {
    test('parses units from strings correctly', () {
      expect(Unit.tryParse('1'), Unit.unity);
      expect(Unit.tryParse('g'), gram);
      expect(Unit.tryParse('wk'), week);
      expect(Unit.tryParse('kg'), kilo.gram);
      expect(Unit.tryParse('cm'), centi.meter);
      expect(Unit.tryParse('kg/m/m'), kilo.gram / (meter * meter));
      expect(Unit.tryParse('foo'), null);
    });

    test('constructs correct unit', () {
      checkDerivedUnit(
        Unit.derived(
          const [Tuple2(LengthBaseUnit.meter, null)],
          const [Tuple2(TimeBaseUnit.second, null)],
        ),
        unitsUp: const [Tuple2(LengthBaseUnit.meter, null)],
        unitsDown: const [Tuple2(TimeBaseUnit.second, null)],
      );

      checkNonDerivedUnit(
        Unit.nonDerived(MassBaseUnit.gram, kilo),
        prefix: kilo,
        baseUnit: MassBaseUnit.gram,
      );

      checkNonDerivedUnit(Unit.nonDerived(TimeBaseUnit.second),
          baseUnit: TimeBaseUnit.second);
    });

    test('toString returns correct string', () {
      expect(Unit.unity.toString(), '1');

      expect(second.toString(), 's');
      expect(gram.toString(), 'g');
      expect(meter.toString(), 'm');
      expect(week.toString(), 'wk');

      expect(kilo.gram.toString(), 'kg');
      expect(centi.meter.toString(), 'cm');

      var unit = Unit.unity;

      expect((unit = unit * centi.meter).toString(), 'cm');
      expect((unit = unit * centi.meter).toString(), 'cm²');
      expect((unit = unit * centi.meter).toString(), 'cm³');
      expect((unit = unit * centi.meter).toString(), 'cm⁴');
      expect((unit = unit * centi.meter).toString(), 'cm⁵');
      expect((unit = unit * centi.meter).toString(), 'cm⁶');
      expect((unit = unit * centi.meter).toString(), 'cm⁷');
      expect((unit = unit * centi.meter).toString(), 'cm⁸');
      expect((unit = unit * centi.meter).toString(), 'cm⁹');
      expect((unit = unit * centi.meter).toString(), 'cm¹⁰');

      expect(month.toString(), 'mo');
      expect(year.reciprocal.toString(), '1 / yr');

      expect((kilo.meter / day).toString(), 'km / d');
      expect((kilo.meter / second / second).toString(), 'km / s²');
      expect((kilo.gram * meter / second / second).toString(), 'kg · m / s²');
    });

    test('multiplies two non derived units correctly', () {
      checkDerivedUnit(
        kilo.gram * meter,
        unitsUp: const [
          Tuple2(MassBaseUnit.gram, kilo),
          Tuple2(LengthBaseUnit.meter, null),
        ],
        unitsDown: const [],
      );
    });

    test('multiplies a derived unit and non derived unit correctly', () {
      checkDerivedUnit(
        (kilo.meter / day) * second,
        unitsUp: const [
          Tuple2(LengthBaseUnit.meter, kilo),
          Tuple2(TimeBaseUnit.second, null),
        ],
        unitsDown: const [Tuple2(TimeBaseUnit.day, null)],
      );
    });

    test('multiplies a non derived unit and derived unit correctly', () {
      checkDerivedUnit(
        kilo.meter * (kilo.gram / meter),
        unitsUp: const [
          Tuple2(MassBaseUnit.gram, kilo),
          Tuple2(LengthBaseUnit.meter, kilo),
        ],
        unitsDown: const [
          Tuple2(LengthBaseUnit.meter, null),
        ],
      );
    });

    test('multiplies derived units correctly', () {
      checkDerivedUnit(
        (kilo.meter / second) * (kilo.gram * meter),
        unitsUp: const [
          Tuple2(LengthBaseUnit.meter, kilo),
          Tuple2(MassBaseUnit.gram, kilo),
          Tuple2(LengthBaseUnit.meter, null),
        ],
        unitsDown: const [Tuple2(TimeBaseUnit.second, null)],
      );
    });

    test('divides two non derived units correctly', () {
      checkDerivedUnit(
        meter / second,
        unitsUp: const [Tuple2(LengthBaseUnit.meter, null)],
        unitsDown: const [Tuple2(TimeBaseUnit.second, null)],
      );
    });

    test('divides a derived unit and a non derived unit correctly', () {
      checkDerivedUnit(
        (kilo.meter / second) / meter,
        unitsUp: const [Tuple2(LengthBaseUnit.meter, kilo)],
        unitsDown: const [
          Tuple2(TimeBaseUnit.second, null),
          Tuple2(LengthBaseUnit.meter, null),
        ],
      );
    });

    test('divides a non derived unit and derived unit correctly', () {
      checkDerivedUnit(
        kilo.gram / (meter * meter),
        unitsUp: const [Tuple2(MassBaseUnit.gram, kilo)],
        unitsDown: const [
          Tuple2(LengthBaseUnit.meter, null),
          Tuple2(LengthBaseUnit.meter, null),
        ],
      );
    });

    test('divides derived units correctly', () {
      checkDerivedUnit(
        (kilo.gram * meter) / (second / gram),
        unitsUp: const [
          Tuple2(MassBaseUnit.gram, kilo),
          Tuple2(LengthBaseUnit.meter, null),
          Tuple2(MassBaseUnit.gram, null),
        ],
        unitsDown: const [Tuple2(TimeBaseUnit.second, null)],
      );
    });

    test('gets correct reciprocal', () {
      checkDerivedUnit(
        gram.reciprocal,
        unitsUp: const [],
        unitsDown: const [Tuple2(MassBaseUnit.gram, null)],
      );

      checkDerivedUnit(
        (kilo.meter / day).reciprocal,
        unitsUp: const [Tuple2(TimeBaseUnit.day, null)],
        unitsDown: const [
          Tuple2(LengthBaseUnit.meter, kilo),
        ],
      );
    });

    test('constructs unit without duplicate tuple in unitsUp and unitsDown',
        () {
      checkNonDerivedUnit(
        kilo.meter * second / second,
        baseUnit: LengthBaseUnit.meter,
        prefix: kilo,
      );
    });

    test('simplify works correctly', () {
      final tuple = (meter / second * day).simplify();
      final unit = tuple.item1;
      final multiple = tuple.item2;
      checkNonDerivedUnit(unit, baseUnit: LengthBaseUnit.meter);
      expect(multiple, 86400);
    });

    test('== works correctly', () {
      expect(Unit.unity, Unit.unity);
      expect(Unit.unity, Unit.derived(const [], const []));
      expect(Unit.unity, isNot(second.reciprocal));

      expect(meter / second, meter / second);
      expect(meter / second, isNot(second / meter));

      expect(meter, isNot(second));

      expect(kilo.gram * meter / second, isNot(kilo.gram * meter));
    });

    test('hashCode works correctly', () {
      expect(Unit.unity.hashCode, Unit.derived(const [], const []).hashCode);
      expect((meter / second).hashCode, (meter / second).hashCode);
      expect(kilo.gram.hashCode, kilo.gram.hashCode);
    });
  });

  test('global unit consts have correct values', () {
    expect(meter, Unit.nonDerived(LengthBaseUnit.meter));
    expect(gram, Unit.nonDerived(MassBaseUnit.gram));
    expect(second, Unit.nonDerived(TimeBaseUnit.second));
    expect(day, Unit.nonDerived(TimeBaseUnit.day));
    expect(month, Unit.nonDerived(TimeBaseUnit.month));
    expect(year, Unit.nonDerived(TimeBaseUnit.year));
  });
}
