# Usage Guide for native_torch

## Overview

The `native_torch` package provides a simple and efficient way to control the torch/flashlight on mobile devices. This guide covers common use cases and best practices.

## Installation

1. Add to your `pubspec.yaml`:

```yaml
dependencies:
  native_torch: ^0.0.1
```

2. Run `flutter pub get`

3. For Android, ensure you have the required permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera.flash" android:required="false" />
```

4. For iOS, add to `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to control the flashlight</string>
```

## Basic Examples

### Singleton Pattern

The `NativeTorch` class uses a singleton pattern:

```dart
final torch = NativeTorch();
// This always returns the same instance
final torch2 = NativeTorch();
assert(torch == torch2); // true
```

### Checking Torch Availability

Before attempting to use the torch, check if it's available:

```dart
final torch = NativeTorch();

final isAvailable = await torch.isTorchAvailable();
if (isAvailable) {
  print('Torch is available on this device');
} else {
  print('Torch is not available on this device');
  // Show alternative UI or disable torch features
}
```

### Simple On/Off Control

```dart
// Turn on
await torch.turnOn();

// Turn off
await torch.turnOff();

// Check current state
bool isOn = await torch.isTorchOn();
print('Torch is ${isOn ? 'on' : 'off'}');
```

### Toggle Functionality

```dart
// Toggle the torch without checking current state
await torch.toggle();
```

## Advanced Examples

### Building a Torch Button Widget

```dart
class TorchButton extends StatefulWidget {
  @override
  State<TorchButton> createState() => _TorchButtonState();
}

class _TorchButtonState extends State<TorchButton> {
  final torch = NativeTorch();
  bool _isTorchOn = false;
  bool _isTorchAvailable = false;

  @override
  void initState() {
    super.initState();
    _initTorch();
  }

  Future<void> _initTorch() async {
    final available = await torch.isTorchAvailable();
    final on = await torch.isTorchOn();
    setState(() {
      _isTorchAvailable = available;
      _isTorchOn = on;
    });
  }

  Future<void> _toggleTorch() async {
    try {
      await torch.toggle();
      final isOn = await torch.isTorchOn();
      setState(() => _isTorchOn = isOn);
    } catch (e) {
      print('Error toggling torch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTorchAvailable) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: _toggleTorch,
      backgroundColor: _isTorchOn ? Colors.yellow : Colors.grey,
      child: Icon(_isTorchOn ? Icons.light_mode : Icons.light_mode_outlined),
    );
  }
}
```

### Intensity Control (Advanced)

```dart
class IntensitySlider extends StatefulWidget {
  @override
  State<IntensitySlider> createState() => _IntensitySliderState();
}

class _IntensitySliderState extends State<IntensitySlider> {
  final torch = NativeTorch();
  double _intensity = 1.0;
  int _maxIntensity = 1;
  bool _supportsIntensity = false;

  @override
  void initState() {
    super.initState();
    _initIntensity();
  }

  Future<void> _initIntensity() async {
    final maxLevel = await torch.getMaxIntensity();
    setState(() {
      _maxIntensity = maxLevel;
      _supportsIntensity = maxLevel > 1;
    });
  }

  Future<void> _setIntensity(double value) async {
    try {
      final success = await torch.setIntensity(value);
      if (success) {
        setState(() => _intensity = value);
      }
    } catch (e) {
      print('Error setting intensity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsIntensity) {
      return const Text('Intensity control not supported');
    }

    return Column(
      children: [
        Text('Intensity: ${(_intensity * 100).toStringAsFixed(0)}%'),
        Slider(
          value: _intensity,
          min: 0.0,
          max: 1.0,
          onChanged: _setIntensity,
        ),
      ],
    );
  }
}
```

### Error Handling

```dart
Future<void> safeToggleTorch() async {
  final torch = NativeTorch();

  try {
    // Check availability first
    final isAvailable = await torch.isTorchAvailable();
    if (!isAvailable) {
      throw Exception('Torch not available');
    }

    // Toggle torch
    await torch.toggle();

  } on PlatformException catch (e) {
    print('Platform error: ${e.code} - ${e.message}');
  } on ArgumentError catch (e) {
    print('Invalid argument: $e');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

## Best Practices

### 1. **Always Check Availability**

```dart
final isAvailable = await torch.isTorchAvailable();
if (!isAvailable) {
  // Disable torch UI or provide fallback
}
```

### 2. **Handle Permissions on Android**

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isDenied) {
    // Permission denied
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}
```

### 3. **Clean Up Resources**

```dart
@override
void dispose() {
  // Make sure to turn off torch when app closes
  torch.turnOff();
  super.dispose();
}
```

### 4. **Validate Intensity Values**

```dart
Future<void> setIntensityWithValidation(double intensity) async {
  if (intensity < 0.0 || intensity > 1.0) {
    throw ArgumentError('Intensity must be between 0.0 and 1.0');
  }
  await torch.setIntensity(intensity);
}
```

### 5. **Implement Caching**

```dart
class TorchManager {
  static final TorchManager _instance = TorchManager._();
  final torch = NativeTorch();

  bool? _isAvailable;
  bool? _isOn;

  factory TorchManager() => _instance;

  TorchManager._();

  Future<bool> isTorchAvailable() async {
    _isAvailable ??= await torch.isTorchAvailable();
    return _isAvailable!;
  }

  Future<bool> isTorchOn() async {
    _isOn = await torch.isTorchOn();
    return _isOn!;
  }

  Future<void> turnOn() async {
    await torch.turnOn();
    _isOn = true;
  }

  Future<void> turnOff() async {
    await torch.turnOff();
    _isOn = false;
  }
}
```

## Platform-Specific Notes

### Android

- Minimum SDK: 21
- Torch intensity control available on Android 13+
- Requires `android.permission.CAMERA` permission
- Torch control uses the camera flash directly

### iOS

- Minimum iOS: 11.0
- Full intensity control support on all versions
- Uses `AVCaptureDevice` for torch management
- Requires camera usage description in Info.plist

## Troubleshooting

### Q: Torch won't turn on

**A:**

1. Check if torch is available: `isTorchAvailable()`
2. Verify permissions are granted
3. Check if another app is using the torch

### Q: Intensity control doesn't work

**A:**

1. On Android, ensure you're on Android 13+
2. Check `getMaxIntensity()` > 1
3. Pass intensity values between 0.0 and 1.0

### Q: Permission errors

**A:**

1. Add required permissions to manifest files
2. Request runtime permissions on Android 6+
3. Add camera description to iOS Info.plist

## API Reference Summary

| Method                 | Returns           | Description                   |
| ---------------------- | ----------------- | ----------------------------- |
| `isTorchAvailable()`   | `Future<bool>`    | Check device torch capability |
| `turnOn()`             | `Future<void>`    | Turn torch on                 |
| `turnOff()`            | `Future<void>`    | Turn torch off                |
| `toggle()`             | `Future<void>`    | Toggle torch state            |
| `isTorchOn()`          | `Future<bool>`    | Get current torch state       |
| `setIntensity(double)` | `Future<bool>`    | Set torch brightness (0-1)    |
| `getMaxIntensity()`    | `Future<int>`     | Get max intensity levels      |
| `getPlatformVersion()` | `Future<String?>` | Get platform version          |

## Support

For issues or questions, please visit the GitHub repository or contact the development team.
