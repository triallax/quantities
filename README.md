A Dart package that helps you work with physical quantities and units seamlessly.

Created from templates made available by Stagehand under a BSD-style [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## API Status

The API is highly experimental; large changes are planned. Do **NOT** use this package in production code unless you understand and accept the consequences of this.

## Usage

```dart
import 'package:quantities/quantities.dart';

void main() {
  final height = 165(centi.meter);
  final weight = 53(kilo.gram);
  final bmi = weight / (height * height);
  print('${bmi.to(kilo.gram / squareMeter)} kg / m^2');
}
```

## Credits

This package takes huge inspiration from [purescript-quantites](https://github.com/sharkdp/purescript-quantities), especially in its internal design. Kudos to [sharkdp](https://github.com/sharkdp)!
