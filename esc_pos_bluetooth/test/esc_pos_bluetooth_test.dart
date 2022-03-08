import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';

void main() {
  Map<String, dynamic> value = {
    "name": "akuu",
    "address": "siapp",
    "type": 1,
  };

  print("${value['name']}");

  PrinterBluetooth printerBluetooth = new PrinterBluetooth.fromPlayer(value);

  test('Tests not implemented', () {
    expect("akuu", printerBluetooth.name);
  });
}
