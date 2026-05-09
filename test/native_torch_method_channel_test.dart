import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_torch/native_torch_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNativeTorch platform = MethodChannelNativeTorch();
  const MethodChannel channel = MethodChannel('native_torch');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getPlatformVersion':
              return 'Android 13';
            case 'isTorchAvailable':
              return true;
            case 'turnOn':
              return null;
            case 'turnOff':
              return null;
            case 'toggle':
              return null;
            case 'isTorchOn':
              return false;
            case 'setIntensity':
              return true;
            case 'getMaxIntensity':
              return 5;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), 'Android 13');
  });

  test('isTorchAvailable', () async {
    expect(await platform.isTorchAvailable(), true);
  });

  test('turnOn', () async {
    expect(await platform.turnOn(), null);
  });

  test('turnOff', () async {
    expect(await platform.turnOff(), null);
  });

  test('toggle', () async {
    expect(await platform.toggle(), null);
  });

  test('isTorchOn', () async {
    expect(await platform.isTorchOn(), false);
  });

  test('setIntensity', () async {
    expect(await platform.setIntensity(0.5), true);
  });

  test('setIntensity with invalid value (>1.0)', () async {
    expect(() => platform.setIntensity(1.5), throwsA(isA<ArgumentError>()));
  });

  test('setIntensity with invalid value (<0.0)', () async {
    expect(() => platform.setIntensity(-0.5), throwsA(isA<ArgumentError>()));
  });

  test('getMaxIntensity', () async {
    expect(await platform.getMaxIntensity(), 5);
  });
}
