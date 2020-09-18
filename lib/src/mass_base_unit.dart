import 'quantities.dart';

class MassBaseUnit extends BaseUnit {
  const MassBaseUnit._(
    double value,
    String symbol,
  ) : super(value, 2, symbol);

  static const gram = MassBaseUnit._(1, 'g');

  static const pound = MassBaseUnit._(453.59237, 'lb');

  static const values = [gram, pound];
}
