import 'package:meta/meta.dart';

import 'base_unit.dart';
import 'unit_prefix.dart';

@sealed
@internal
@immutable
class PrefixedBaseUnit {
  const PrefixedBaseUnit(this.baseUnit, [this.prefix]);

  final BaseUnit baseUnit;

  final UnitPrefix? prefix;

  PrefixedBaseUnit withPrefix(UnitPrefix? newPrefix) {
    if (prefix != null && newPrefix != null) {
      throw ArgumentError('$this already has prefix $prefix');
    }

    return PrefixedBaseUnit(baseUnit, newPrefix);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrefixedBaseUnit &&
          baseUnit == other.baseUnit &&
          prefix == other.prefix);

  @override
  int get hashCode => baseUnit.hashCode ^ prefix.hashCode;

  @override
  String toString() {
    if (prefix == null) {
      return baseUnit.toString();
    }

    return '$prefix$baseUnit';
  }
}
