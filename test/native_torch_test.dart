import 'package:flutter_test/flutter_test.dart';
import 'package:native_torch/native_torch.dart';
import 'package:native_torch/native_torch_platform_interface.dart';
import 'package:native_torch/native_torch_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeTorchPlatform
    with MockPlatformInterfaceMixin
    implements NativeTorchPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> isTorchAvailable() => Future.value(true);

  @override
  Future<void> turnOn() async {}

  @override
  Future<void> turnOff() async {}

  @override
  Future<void> toggle() async {}

  @override
  Future<bool> isTorchOn() => Future.value(false);

  @override
  Future<bool> setIntensity(double intensity) => Future.value(true);

  @override
  Future<int> getMaxIntensity() => Future.value(5);
}

void main() {
  final NativeTorchPlatform initialPlatform = NativeTorchPlatform.instance;

  test('$MethodChannelNativeTorch is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeTorch>());
  });

  test('getPlatformVersion', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    expect(await nativeTorchPlugin.getPlatformVersion(), '42');
  });

  test('isTorchAvailable', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    expect(await nativeTorchPlugin.isTorchAvailable(), true);
  });

  test('turnOn', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    await nativeTorchPlugin.turnOn();
  });

  test('turnOff', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    await nativeTorchPlugin.turnOff();
  });

  test('toggle', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    await nativeTorchPlugin.toggle();
  });

  test('isTorchOn', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    expect(await nativeTorchPlugin.isTorchOn(), false);
  });

  test('setIntensity', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    expect(await nativeTorchPlugin.setIntensity(0.5), true);
  });

  test('getMaxIntensity', () async {
    NativeTorch nativeTorchPlugin = NativeTorch();
    MockNativeTorchPlatform fakePlatform = MockNativeTorchPlatform();
    NativeTorchPlatform.instance = fakePlatform;

    expect(await nativeTorchPlugin.getMaxIntensity(), 5);
  });
}
