import 'package:quantities/quantities.dart';
import 'package:quantities/src/unit.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('UnitPrefix', () {
    test('gram returns correct unit', () {
      checkNonDerivedUnit(
        kilo.gram,
        gram.baseUnit.withPrefix(kilo),
      );
    });

    test('meter returns correct unit', () {
      checkNonDerivedUnit(
        centi.meter,
        meter.baseUnit.withPrefix(centi),
      );
    });
  });

  group('Unit', () {
    test('parses units from strings correctly', () {
      expect(Unit.tryParse('1'), Unit.unity);
      expect(Unit.tryParse('kg*m/s/s'), kilo.gram * meter / (second * second));
      expect(Unit.tryParse('g'), gram);
      expect(Unit.tryParse('wk'), week);
      expect(Unit.tryParse('kg'), kilo.gram);
      expect(Unit.tryParse('cm'), centi.meter);
      expect(Unit.tryParse('in'), inch);
      expect(Unit.tryParse('lb'), pound);
      expect(Unit.tryParse('kg/m/m'), kilo.gram / (meter * meter));
      expect(Unit.tryParse('vg'), null);
      expect(Unit.tryParse('foo'), null);
      expect(Unit.tryParse('*'), null);
      expect(Unit.tryParse('kg*'), null);
      expect(Unit.tryParse('*/1'), null);

      for (final unitPrefix in UnitPrefix.values) {
        expect(
          Unit.tryParse('${unitPrefix}g'),
          gram.withPrefix(unitPrefix),
        );
        expect(
          Unit.tryParse('${unitPrefix}m/hr'),
          meter.withPrefix(unitPrefix) / hour,
        );
      }
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
      expect((inch * pound).toString(), 'in · lb');
      expect((kilo.meter / second / second).toString(), 'km / s²');
      expect((kilo.gram * meter / second / second).toString(), 'kg · m / s²');
    });

    test('multiplies two non derived units correctly', () {
      checkDerivedUnit(
        kilo.gram * meter,
        unitsUp: [gram.baseUnit.withPrefix(kilo), meter.baseUnit],
        unitsDown: const [],
      );
    });

    test('multiplies a derived unit and non derived unit correctly', () {
      checkDerivedUnit(
        (kilo.meter / day) * second,
        unitsUp: [
          meter.baseUnit.withPrefix(kilo),
          second.baseUnit,
        ],
        unitsDown: [day.baseUnit],
      );
    });

    test('multiplies a non derived unit and derived unit correctly', () {
      checkDerivedUnit(
        kilo.meter * (kilo.gram / meter),
        unitsUp: [
          meter.baseUnit.withPrefix(kilo),
          gram.baseUnit.withPrefix(kilo),
        ],
        unitsDown: [
          meter.baseUnit,
        ],
      );
    });

    test('multiplies derived units correctly', () {
      checkDerivedUnit(
        (kilo.meter / second) * (kilo.gram * meter),
        unitsUp: [
          meter.baseUnit.withPrefix(kilo),
          gram.baseUnit.withPrefix(kilo),
          meter.baseUnit,
        ],
        unitsDown: [second.baseUnit],
      );
    });

    test('divides two non derived units correctly', () {
      checkDerivedUnit(
        meter / second,
        unitsUp: [meter.baseUnit],
        unitsDown: [second.baseUnit],
      );
    });

    test('divides a derived unit and a non derived unit correctly', () {
      checkDerivedUnit(
        (kilo.meter / second) / meter,
        unitsUp: [meter.baseUnit.withPrefix(kilo)],
        unitsDown: [
          second.baseUnit,
          meter.baseUnit,
        ],
      );
    });

    test('divides a non derived unit and derived unit correctly', () {
      checkDerivedUnit(
        kilo.gram / (meter * meter),
        unitsUp: [gram.baseUnit.withPrefix(kilo)],
        unitsDown: [
          meter.baseUnit,
          meter.baseUnit,
        ],
      );
    });

    test('divides derived units correctly', () {
      checkDerivedUnit(
        (kilo.gram * meter) / (second / gram),
        unitsUp: [
          gram.baseUnit.withPrefix(kilo),
          meter.baseUnit,
          gram.baseUnit,
        ],
        unitsDown: [second.baseUnit],
      );
    });

    test('gets correct reciprocal', () {
      checkDerivedUnit(
        gram.reciprocal,
        unitsUp: const [],
        unitsDown: [gram.baseUnit],
      );

      checkDerivedUnit(
        (kilo.meter / day).reciprocal,
        unitsUp: [day.baseUnit],
        unitsDown: [meter.baseUnit.withPrefix(kilo)],
      );
    });

    test('constructs unit without duplicate tuple in unitsUp and unitsDown',
        () {
      checkNonDerivedUnit(
        kilo.meter * second / second,
        meter.baseUnit.withPrefix(kilo),
      );
    });

    test('simplify works correctly', () {
      final tuple = (meter / second * day).simplify();
      final unit = tuple.item1;
      final multiple = tuple.item2;
      checkNonDerivedUnit(unit, meter.baseUnit);
      expect(multiple, 86400);
    });

    test('== works correctly', () {
      expect(Unit.unity, Unit.unity);
      expect(Unit.unity, second / second);
      expect(Unit.unity, isNot(second.reciprocal));

      expect(meter / second, meter / second);
      expect(meter / second, isNot(second / meter));

      expect(meter, isNot(second));

      expect(kilo.gram * meter / second, isNot(kilo.gram * meter));
    });

    test('hashCode works correctly', () {
      expect(Unit.unity.hashCode, (second / second).hashCode);
      expect((meter / second).hashCode, (meter / second).hashCode);
      expect(kilo.gram.hashCode, kilo.gram.hashCode);
    });
  });
}
