import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_torch_platform_interface.dart';

/// An implementation of [NativeTorchPlatform] that uses method channels.
class MethodChannelNativeTorch extends NativeTorchPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_torch');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> isTorchAvailable() async {
    final result = await methodChannel.invokeMethod<bool>('isTorchAvailable');
    return result ?? false;
  }

  @override
  Future<void> turnOn() async {
    await methodChannel.invokeMethod<void>('turnOn');
  }

  @override
  Future<void> turnOff() async {
    await methodChannel.invokeMethod<void>('turnOff');
  }

  @override
  Future<void> toggle() async {
    await methodChannel.invokeMethod<void>('toggle');
  }

  @override
  Future<bool> isTorchOn() async {
    final result = await methodChannel.invokeMethod<bool>('isTorchOn');
    return result ?? false;
  }

  @override
  Future<bool> setIntensity(double intensity) async {
    if (intensity < 0.0 || intensity > 1.0) {
      throw ArgumentError('Intensity must be between 0.0 and 1.0');
    }
    final result = await methodChannel.invokeMethod<bool>('setIntensity', {
      'intensity': intensity,
    });
    return result ?? false;
  }

  @override
  Future<int> getMaxIntensity() async {
    final result = await methodChannel.invokeMethod<int>('getMaxIntensity');
    return result ?? 1;
  }
}
