import 'base_unit.dart';
import 'prefixed_base_unit.dart';
import 'unit.dart';

NonDerivedUnit _mkStandard(BaseStandardUnit baseUnit) =>
    NonDerivedUnit(PrefixedBaseUnit(baseUnit));

NonDerivedUnit _mkNonStandard(
  String symbol,
  double factor,
  List<BaseStandardUnit> unitsUp, [
  List<BaseStandardUnit> unitsDown = const [],
]) =>
    NonDerivedUnit(
        PrefixedBaseUnit(BaseUnit(symbol, factor, unitsUp, unitsDown)));

/// Base unit of length.
final meter = _mkStandard(meterBaseUnit);

/// Unit of length; `1 in. = 0.0254 m`.
final inch = _mkNonStandard('in', 0.0254, [meterBaseUnit]);

/// Unit of area.
final squareMeter = meter * meter;

/// Base unit of mass (note that the kilogram is the standard unit of mass in
/// SI, *NOT* the gram).
final gram = _mkStandard(gramBaseUnit);

/// Unit of mass; `1 lb = 453.59237 g`.
final pound = _mkNonStandard('lb', 453.59237, [gramBaseUnit]);

/// Base unit of time.
final second = _mkStandard(secondBaseUnit);

const _secondsPerHour = 60.0 * 60;

/// Unit of time; `1 hr = 3600 s`.
final hour = _mkNonStandard('hr', _secondsPerHour, [secondBaseUnit]);

const _secondsPerDay = _secondsPerHour * 24;

/// Unit of time; `1 d = 24 h`.
final day = _mkNonStandard('d', _secondsPerDay, [secondBaseUnit]);

const _secondsPerWeek = _secondsPerDay * 7;

/// Unit of time; `1 wk = 7 d`.
final week = _mkNonStandard('wk', _secondsPerWeek, [secondBaseUnit]);

const _secondsPerMonth = _secondsPerDay * 30.436875;

/// Unit of time; `1 mo = 30.436875 d`.
final month = _mkNonStandard('mo', _secondsPerMonth, [secondBaseUnit]);

const _secondsPerYear = _secondsPerMonth * 12;

/// Unit of time; `1 yr = 12 mo`.
final year = _mkNonStandard('yr', _secondsPerYear, [secondBaseUnit]);
