# API Reference - native_torch

Complete API documentation for the `native_torch` Flutter plugin.

## Table of Contents

1. [NativeTorch Class](#nativetorch-class)
2. [Methods](#methods)
3. [Exceptions](#exceptions)
4. [Platform Interface](#platform-interface)
5. [Method Channel](#method-channel)

## NativeTorch Class

The main entry point for the native_torch plugin.

### Overview

```dart
class NativeTorch {
  factory NativeTorch();
}
```

The `NativeTorch` class implements the singleton pattern, ensuring only one instance exists throughout the application lifecycle.

### Instance Usage

```dart
// Get singleton instance
final torch = NativeTorch();

// Always returns the same instance
final torch2 = NativeTorch();
assert(torch == torch2); // true
```

## Methods

### `isTorchAvailable()`

Checks if the device has a torch/flashlight capability.

**Signature:**

```dart
Future<bool> isTorchAvailable()
```

**Returns:**

- `Future<bool>` - Completes with `true` if torch is available, `false` otherwise

**Exceptions:**

- `PlatformException` - If the platform implementation encounters an error

**Example:**

```dart
final torch = NativeTorch();
final available = await torch.isTorchAvailable();
if (available) {
  print('Torch is available');
} else {
  print('Torch is not available on this device');
}
```

### `turnOn()`

Turns on the torch/flashlight.

**Signature:**

```dart
Future<void> turnOn()
```

**Returns:**

- `Future<void>` - Completes when the operation is finished

**Exceptions:**

- `PlatformException` - If the operation fails (e.g., torch not available, permission denied)

**Example:**

```dart
try {
  await torch.turnOn();
  print('Torch is now on');
} catch (e) {
  print('Failed to turn on torch: $e');
}
```

### `turnOff()`

Turns off the torch/flashlight.

**Signature:**

```dart
Future<void> turnOff()
```

**Returns:**

- `Future<void>` - Completes when the operation is finished

**Exceptions:**

- `PlatformException` - If the operation fails

**Example:**

```dart
try {
  await torch.turnOff();
  print('Torch is now off');
} catch (e) {
  print('Failed to turn off torch: $e');
}
```

### `toggle()`

Toggles the torch between on and off states.

**Signature:**

```dart
Future<void> toggle()
```

**Returns:**

- `Future<void>` - Completes when the toggle operation is finished

**Exceptions:**

- `PlatformException` - If the operation fails

**Example:**

```dart
try {
  await torch.toggle();
  // Torch state has been toggled
  final isOn = await torch.isTorchOn();
  print('Torch is now ${isOn ? "on" : "off"}');
} catch (e) {
  print('Failed to toggle torch: $e');
}
```

### `isTorchOn()`

Gets the current state of the torch.

**Signature:**

```dart
Future<bool> isTorchOn()
```

**Returns:**

- `Future<bool>` - Completes with `true` if torch is currently on, `false` if off

**Exceptions:**

- `PlatformException` - If the platform implementation encounters an error

**Example:**

```dart
final isOn = await torch.isTorchOn();
print('Torch is ${isOn ? 'on' : 'off'}');
```

### `setIntensity(double intensity)`

Sets the torch intensity/brightness level.

**Signature:**

```dart
Future<bool> setIntensity(double intensity)
```

**Parameters:**

- `intensity` (double) - A value between 0.0 and 1.0
  - 0.0 = off
  - 0.5 = medium brightness
  - 1.0 = maximum brightness

**Returns:**

- `Future<bool>` - Completes with `true` if the operation succeeded, `false` if intensity control is not supported

**Exceptions:**

- `ArgumentError` - If intensity is not between 0.0 and 1.0
- `PlatformException` - If the platform implementation encounters an error

**Platform Support:**

- Android: Requires Android 13+, returns `false` on older versions
- iOS: Available on all supported versions

**Example:**

```dart
try {
  // Set to 50% brightness
  final success = await torch.setIntensity(0.5);
  if (success) {
    print('Intensity set to 50%');
  } else {
    print('Device does not support intensity control');
  }
} on ArgumentError {
  print('Invalid intensity value (must be 0.0-1.0)');
} catch (e) {
  print('Failed to set intensity: $e');
}
```

### `getMaxIntensity()`

Gets the maximum number of intensity levels supported by the device.

**Signature:**

```dart
Future<int> getMaxIntensity()
```

**Returns:**

- `Future<int>` - The maximum intensity level
  - 1 = Device only supports on/off (intensity control not available)
  - > 1 = Number of discrete intensity levels supported

**Exceptions:**

- `PlatformException` - If the platform implementation encounters an error

**Platform Support:**

- Android 13+: Returns up to 5 levels
- Android <13: Returns 1
- iOS: Returns 1 (uses continuous intensity)

**Example:**

```dart
final maxIntensity = await torch.getMaxIntensity();
if (maxIntensity > 1) {
  print('Device supports intensity control with $maxIntensity levels');
} else {
  print('Intensity control not supported');
}
```

### `getPlatformVersion()`

Gets the platform/OS version string.

**Signature:**

```dart
Future<String?> getPlatformVersion()
```

**Returns:**

- `Future<String?>` - Platform version string (e.g., "Android 13" or "iOS 16.0")
- Returns `null` if unable to determine version

**Example:**

```dart
final version = await torch.getPlatformVersion();
print('Running on: $version');
```

## Exceptions

### PlatformException

Thrown when a platform-specific operation fails.

**Properties:**

- `code` (String) - Error code
- `message` (String?) - Human-readable error message
- `details` (dynamic) - Platform-specific error details

**Common Codes:**

- `'TORCH_ERROR'` - General torch operation failed
- `'PERMISSION_DENIED'` - Required permissions not granted
- `'NOT_AVAILABLE'` - Torch not available on device

**Example:**

```dart
try {
  await torch.turnOn();
} on PlatformException catch (e) {
  print('Platform Error: ${e.code} - ${e.message}');
}
```

### ArgumentError

Thrown when invalid arguments are provided.

**Common Cases:**

- `setIntensity()` called with value outside 0.0-1.0 range

**Example:**

```dart
try {
  await torch.setIntensity(1.5); // Invalid
} on ArgumentError catch (e) {
  print('Invalid argument: $e');
}
```

## Platform Interface

### NativeTorchPlatform

Abstract base class for platform implementations.

**Methods:**

```dart
abstract class NativeTorchPlatform extends PlatformInterface {
  Future<bool> isTorchAvailable();
  Future<void> turnOn();
  Future<void> turnOff();
  Future<void> toggle();
  Future<bool> isTorchOn();
  Future<bool> setIntensity(double intensity);
  Future<int> getMaxIntensity();
  Future<String?> getPlatformVersion();
}
```

**Accessing the Platform Implementation:**

```dart
// Get the current platform instance
final platform = NativeTorchPlatform.instance;

// This is typically MethodChannelNativeTorch
```

## Method Channel

### Channel Name

```dart
const MethodChannel('native_torch')
```

### Supported Methods

| Method               | Parameters          | Returns  | Platform         |
| -------------------- | ------------------- | -------- | ---------------- |
| `getPlatformVersion` | -                   | `String` | Android, iOS     |
| `isTorchAvailable`   | -                   | `bool`   | Android, iOS     |
| `turnOn`             | -                   | `null`   | Android, iOS     |
| `turnOff`            | -                   | `null`   | Android, iOS     |
| `toggle`             | -                   | `null`   | Android, iOS     |
| `isTorchOn`          | -                   | `bool`   | Android, iOS     |
| `setIntensity`       | `intensity: double` | `bool`   | Android 13+, iOS |
| `getMaxIntensity`    | -                   | `int`    | Android, iOS     |

### Implementation Details

**Android (Kotlin):**

- Package: `com.oyaiz.packages.native_torch`
- Class: `NativeTorchPlugin`
- Uses: `CameraManager` and `CameraCharacteristics`

**iOS (Swift):**

- Class: `NativeTorchPlugin`
- Uses: `AVCaptureDevice`

## Best Practices

### 1. Check Availability First

```dart
if (await torch.isTorchAvailable()) {
  await torch.turnOn();
}
```

### 2. Handle Exceptions

```dart
try {
  await torch.turnOn();
} on PlatformException catch (e) {
  // Handle platform-specific error
} on ArgumentError catch (e) {
  // Handle invalid argument
} catch (e) {
  // Handle unexpected error
}
```

### 3. Validate Intensity

```dart
if (intensity >= 0.0 && intensity <= 1.0) {
  await torch.setIntensity(intensity);
}
```

### 4. Check Support Before Using

```dart
final maxIntensity = await torch.getMaxIntensity();
if (maxIntensity > 1) {
  // Intensity control is supported
}
```

### 5. Clean Up Resources

```dart
@override
void dispose() {
  torch.turnOff();
  super.dispose();
}
```

## Changelog

### Version 0.0.1

- Initial release
- Full Android and iOS support
- All core methods implemented
- Comprehensive error handling

## Support

For issues, feature requests, or questions, please visit the GitHub repository or contact the development team.
