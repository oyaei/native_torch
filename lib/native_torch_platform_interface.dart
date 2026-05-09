import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_torch_method_channel.dart';

abstract class NativeTorchPlatform extends PlatformInterface {
  /// Constructs a NativeTorchPlatform.
  NativeTorchPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeTorchPlatform _instance = MethodChannelNativeTorch();

  /// The default instance of [NativeTorchPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeTorch].
  static NativeTorchPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeTorchPlatform] when
  /// they register themselves.
  static set instance(NativeTorchPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Check if torch/flashlight is available on this device
  Future<bool> isTorchAvailable() {
    throw UnimplementedError('isTorchAvailable() has not been implemented.');
  }

  /// Turn on the torch/flashlight
  Future<void> turnOn() {
    throw UnimplementedError('turnOn() has not been implemented.');
  }

  /// Turn off the torch/flashlight
  Future<void> turnOff() {
    throw UnimplementedError('turnOff() has not been implemented.');
  }

  /// Toggle torch on/off
  Future<void> toggle() {
    throw UnimplementedError('toggle() has not been implemented.');
  }

  /// Get current torch state (true = on, false = off)
  Future<bool> isTorchOn() {
    throw UnimplementedError('isTorchOn() has not been implemented.');
  }

  /// Set torch intensity/brightness (0.0 to 1.0)
  /// Returns true if supported, false otherwise
  Future<bool> setIntensity(double intensity) {
    throw UnimplementedError('setIntensity() has not been implemented.');
  }

  /// Get maximum supported torch intensity levels
  Future<int> getMaxIntensity() {
    throw UnimplementedError('getMaxIntensity() has not been implemented.');
  }
}
