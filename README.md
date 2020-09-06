A Dart package that helps you work with physical quantities and units seamlessly. 

Created from templates made available by Stagehand under a BSD-style [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
## Installation
---
### 1. Add it to your Dependencies
Add this to your pubspec.yaml file:
```yml
dependencies:
  quantities: ^0.0.1
```
### 2. Install The Package
Install from the Command Line:

with pub:
```
$ pub get
```
with Flutter:
```
$ flutter pub get
```
Alternatively, your editor might support `pub get` or `flutter pub get`. Check the docs for your editor to learn more.
### 3. Import The Package
Now in your Dart code, you can use: 
```dart
import 'package:quantities/quantities.dart';
```

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
