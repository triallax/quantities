import 'quantities.dart';

class MassBaseUnit extends BaseUnit {
  const MassBaseUnit._(
    double value,
    String symbol,
  ) : super(value, 2, symbol);

  static const gram = MassBaseUnit._(1, 'g');

  static const values = [gram];
}
