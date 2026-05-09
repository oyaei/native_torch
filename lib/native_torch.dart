// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'native_torch_platform_interface.dart';

/// Main API for controlling torch/flashlight functionality
class NativeTorch {
  static final NativeTorch _instance = NativeTorch._();

  factory NativeTorch() {
    return _instance;
  }

  NativeTorch._();

  Future<String?> getPlatformVersion() {
    return NativeTorchPlatform.instance.getPlatformVersion();
  }

  /// Check if torch/flashlight is available on this device
  Future<bool> isTorchAvailable() {
    return NativeTorchPlatform.instance.isTorchAvailable();
  }

  /// Turn on the torch/flashlight
  Future<void> turnOn() {
    return NativeTorchPlatform.instance.turnOn();
  }

  /// Turn off the torch/flashlight
  Future<void> turnOff() {
    return NativeTorchPlatform.instance.turnOff();
  }

  /// Toggle torch on/off
  Future<void> toggle() {
    return NativeTorchPlatform.instance.toggle();
  }

  /// Get current torch state (true = on, false = off)
  Future<bool> isTorchOn() {
    return NativeTorchPlatform.instance.isTorchOn();
  }

  /// Set torch intensity/brightness (0.0 to 1.0)
  /// Returns true if supported, false otherwise
  Future<bool> setIntensity(double intensity) {
    return NativeTorchPlatform.instance.setIntensity(intensity);
  }

  /// Get maximum supported torch intensity levels
  Future<int> getMaxIntensity() {
    return NativeTorchPlatform.instance.getMaxIntensity();
  }
}
