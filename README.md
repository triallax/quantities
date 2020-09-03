A Dart package that helps you work with physical quantities and units
seamlessly.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

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
