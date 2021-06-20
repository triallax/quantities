import 'package:quantities/quantities.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  const tolerance = 0.0001;

  group('Quantity', () {
    test('constructs correct quantity', () {
      final quantity1 = Quantity(5, meter);
      expect(quantity1.value, 5);
      expect(quantity1.unit, meter);

      final quantity2 = Quantity(10, kilo(gram) * meter / second);
      expect(quantity2.value, 10);
      expect(quantity2.unit, kilo(gram) * meter / second);

      final quantity3 = Quantity(13, kilo(meter) * day / second);
      expect(quantity3.value, 1123200);
      expect(quantity3.unit, kilo(meter));
    });

    test('toString works correctly', () {
      expect(Quantity(10, kilo(gram) * meter / second).toString(),
          '10 kg · m / s');

      expect(3().toString(), '3');
      expect(6.6(pound).toString(), '6.6 lb');
    });

    test('== works correctly', () {
      expect(90(centi(meter)), isNot(0.9(meter)));
      expect(Quantity(1), Quantity(1));
      expect(Quantity(50, kilo(meter)), 50(kilo(meter)));
      expect(10(inch), 10(inch));

      expect(Quantity(30, day), isNot(Quantity(25, day)));
      expect(Quantity(50, meter), isNot(Quantity(30, gram)));
    });

    test('hashCode works correctly', () {
      expect(50(kilo(gram)).hashCode, 50(kilo(gram)).hashCode);
      expect(1000(meter).hashCode, Quantity(1000, meter).hashCode);
      expect((1000(kilo(meter)) / 0.7(day)).hashCode,
          (1000(kilo(meter)) / 0.7(day)).hashCode);
    });

    test('negation works correctly', () {
      expect(-30(meter), (-30)(meter));
      expect(-5(meter / second), (-5)(meter / second));
    });

    test('subtraction works correctly', () {
      expect(5(kilo(meter)) - 300(meter), 4.7(kilo(meter)));
      expect(5() - 300(), -295());
    });

    test('addition works correctly', () {
      expect(500(second) + 3(day), 259700(second));
      expectQuantity(5(meter / second) + 1000(kilo(meter) / day),
          16.5741(meter / second), tolerance);
      expect((5(inch) + -6(meter)).to(inch), closeTo(-231.22, 0.001));
    });

    test('multiplication works correctly', () {
      final quantity1 = 50(meter) * 100(meter);

      expect(quantity1, 5000(squareMeter));
      expect(quantity1, 1000(meter) * 5(meter));

      final quantity2 = (50(kilo(meter)) / 0.1(day)) * 270(second);
      expectQuantity(quantity2, 1.5625(kilo(meter)), tolerance);
    });

    test('division works correctly', () {
      final quantity1 = 45(meter) / 6(second);

      expect(quantity1, 7.5(meter / second));

      final quantity2 = 50(kilo(gram)) / 165(squareMeter);

      expect(quantity2.value, 50 / 165);
      expect(quantity2.unit, kilo(gram) / squareMeter);
    });

    test('converts between units correctly', () {
      expect(90(centi(meter)).to(meter), 0.9);
      expect(5.3(pound).to(kilo(gram)), closeTo(2.40404, 0.000001));
      expect(3(week).to(day), 21);
      expect(1(meter).to(centi(meter)), 100);
      expect(500(centi(meter)).to(meter), 5);
      expect(25(day).to(month), 0.8213721020965523);
      expect(12(month).to(year), 1);
      expect(2(year).to(month), 24);
      expect(() => 1(meter).to(second), throwsArgumentError);
      expect(351(kilo(meter) / day).to(meter / second), 4.0625);
      expect(6(hour).to(day), 0.25);
      expect(
          (4(kilo(gram)) * 55(meter) / (44(second) * 3(second)))
              .to(gram * kilo(meter) / (day * day)),
          closeTo(12441600000, tolerance));
    });
  });

  group('NumToQuantity', () {
    test('call is same as default Quantity constructor', () {
      expect(5(meter / second), Quantity(5, meter / second));
      expect(3(meter), Quantity(3, meter));
      expect(3(Unit.unity), Quantity(3));
      expect(4(), Quantity(4));
    });
  });
}
