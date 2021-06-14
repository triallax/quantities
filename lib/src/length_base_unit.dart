import 'package:meta/meta.dart';

import 'base_unit.dart';

@internal
class LengthBaseUnit extends BaseUnit {
  const LengthBaseUnit._(
    double value,
    String symbol,
  ) : super(value, 1, symbol);

  static const meter = LengthBaseUnit._(1, 'm');

  static const inch = LengthBaseUnit._(0.0254, 'in');

  static const values = [meter, inch];
}
