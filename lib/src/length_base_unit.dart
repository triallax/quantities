import 'quantities.dart';

class LengthBaseUnit extends BaseUnit {
  const LengthBaseUnit._(
    double value,
    String symbol,
  ) : super(value, 1, symbol);

  static const meter = LengthBaseUnit._(1, 'm');

  static const values = [meter];
}
