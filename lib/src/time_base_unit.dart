import 'quantities.dart';

class TimeBaseUnit extends BaseUnit {
  const TimeBaseUnit._(
    double value,
    String symbol,
  ) : super(value, 0, symbol);

  static const second = TimeBaseUnit._(1, 's');

  static const _secondsPerDay = 60.0 * 60 * 24;

  static const day = TimeBaseUnit._(_secondsPerDay, 'd');

  static const _secondsPerWeek = _secondsPerDay * 7;

  static const week = TimeBaseUnit._(_secondsPerWeek, 'wk');

  static const _secondsPerMonth = _secondsPerDay * 30.436875;

  static const month = TimeBaseUnit._(_secondsPerMonth, 'mo');

  static const _secondsPerYear = _secondsPerMonth * 12;

  static const year = TimeBaseUnit._(_secondsPerYear, 'yr');

  static const values = [second, day, week, month, year];
}
