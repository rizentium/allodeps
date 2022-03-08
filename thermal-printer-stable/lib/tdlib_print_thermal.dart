import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class TdLibThermalPrinter {
  static const int STATE_OFF = 10;
  static const int STATE_TURNING_ON = 11;
  static const int STATE_ON = 12;
  static const int STATE_TURNING_OFF = 13;
  static const int STATE_BLE_TURNING_ON = 14;
  static const int STATE_BLE_ON = 15;
  static const int STATE_BLE_TURNING_OFF = 16;
  static const int ERROR = -1;
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;

  static const String namespace = 'tdlib_print_thermal';

  static const MethodChannel _channel =
      const MethodChannel('$namespace/methods');

  static const EventChannel _readChannel =
      const EventChannel('$namespace/read');

  static const EventChannel _stateChannel =
      const EventChannel('$namespace/state');

  final StreamController<MethodCall> _methodStreamController =
      new StreamController.broadcast();

  TdLibThermalPrinter._() {
    _channel.setMethodCallHandler((MethodCall call) {
      _methodStreamController.add(call);
    });
  }

  static TdLibThermalPrinter _instance = TdLibThermalPrinter._();

  static TdLibThermalPrinter get instance => _instance;

  Stream<int> onStateChanged() =>
      _stateChannel.receiveBroadcastStream().map((buffer) => buffer);

  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool> get isAvailable async =>
      await _channel.invokeMethod('isAvailable');

  Future<bool> get isOn async => await _channel.invokeMethod('isOn');

  Future<bool> get isConnected async =>
      await _channel.invokeMethod('isConnected');

  Future<bool> get openSettings async =>
      await _channel.invokeMethod('openSettings');

  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await _channel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  Future<dynamic> connect(BluetoothDevice device) =>
      _channel.invokeMethod('connect', device.toMap());

  Future<String> getNamePrinter() async => 
      await _channel.invokeMethod('getNamePrinter');

  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  Future<dynamic> write(String message) =>
      _channel.invokeMethod('write', {'message': message});

  Future<dynamic> writeBytes(Uint8List message) =>
      _channel.invokeMethod('writeBytes', {'message': message});

  Future<dynamic> printCustom(String message, int size, int align) =>
      _channel.invokeMethod(
          'printCustom', {'message': message, 'size': size, 'align': align});

  Future<dynamic> printNewLine() => _channel.invokeMethod('printNewLine');

  Future<dynamic> paperCut() => _channel.invokeMethod('paperCut');

  Future<dynamic> printImage(String pathImage) =>
      _channel.invokeMethod('printImage', {'pathImage': pathImage});

  Future<dynamic> printPdf(File pathFile) => _channel.invokeMethod(
        'printPdf',
        {'pdf': pathFile},
      );

  Future<dynamic> printQRcode(
          String textToQR, int width, int height, int align) =>
      _channel.invokeMethod('printQRcode', {
        'textToQR': textToQR,
        'width': width,
        'height': height,
        'align': align,
      });

  Future<dynamic> printLeftRight(String string1, String string2, int size) =>
      _channel.invokeMethod('printLeftRight', {
        'string1': string1,
        'string2': string2,
        'size': size,
      });

  Future<dynamic> printStringContinueNewLine(String string1,  int size) =>
      _channel.invokeMethod('printStringContinueNewLine', {
        'string1': string1,
        'size': size,
      });

  Future<dynamic> printRow3(int no,
          String string1, String string2, int size) =>
      _channel.invokeMethod('printRow3', {
        'no': no,
        'string1': string1,
        'string2': string2,
        'size': size,
      });

  Future<dynamic> printRowCustom2(String format,
          String string1, String string2, int size) =>
      _channel.invokeMethod('printRowCustom2', {
        'format': format,
        'string1': string1,
        'string2': string2,
        'size': size,
      });

  Future<dynamic> printRowCustom3(String format,
          String string1, String string2, String string3, int size) =>
      _channel.invokeMethod('printRowCustom3', {
        'format': format,
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'size': size,
      });

  Future<dynamic> printTitleHeader(
          String string1, String string2, String string3, int size) =>
      _channel.invokeMethod('printTitleHeader', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'size': size,
      });

  Future<dynamic> printLeftRightRow(
          String string1, String string2, String string3, int size) =>
      _channel.invokeMethod('printLeftRight', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'size': size,
        'align': 0,
      });

}

class BluetoothDevice {
  final String name;
  final String address;
  final int type = 0;
  bool connected = false;

  BluetoothDevice(this.name, this.address);

  BluetoothDevice.fromMap(Map map)
      : name = map['name'],
        address = map['address'];

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'address': this.address,
        'type': this.type,
        'connected': this.connected,
      };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
