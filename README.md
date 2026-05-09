# native_torch

A comprehensive Flutter plugin for controlling the torch/flashlight on mobile devices through native platform integration. This package provides an easy-to-use API for managing torch functionality on both Android and iOS devices.

## Features

- ✅ **Turn torch on/off** - Simple control of the device's flashlight
- ✅ **Toggle torch** - Quick switching between on and off states
- ✅ **Check torch availability** - Detect if the device has a torch/flashlight
- ✅ **Torch status** - Get the current state of the torch
- ✅ **Intensity control** - Adjust torch brightness (supported on Android 13+ and iOS)
- ✅ **Cross-platform** - Seamless support for Android and iOS
- ✅ **Method Channel integration** - Efficient native communication

## Supported Platforms

- **Android** (API level 21+) - Full support with intensity control on Android 13+
- **iOS** (iOS 11+) - Full support with intensity control

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  native_torch:
    path: ./native_torch
```

Or from pub.dev once published:

```yaml
dependencies:
  native_torch: ^0.0.1
```

## Usage

### Basic Usage

```dart
import 'package:native_torch/native_torch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final torch = NativeTorch();
  bool torchAvailable = false;
  bool torchOn = false;

  @override
  void initState() {
    super.initState();
    _initTorch();
  }

  Future<void> _initTorch() async {
    final available = await torch.isTorchAvailable();
    final on = await torch.isTorchOn();
    setState(() {
      torchAvailable = available;
      torchOn = on;
    });
  }

  Future<void> _toggleTorch() async {
    await torch.toggle();
    final on = await torch.isTorchOn();
    setState(() => torchOn = on);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Torch')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (torchAvailable)
                ElevatedButton(
                  onPressed: _toggleTorch,
                  child: Text(torchOn ? 'Turn Off' : 'Turn On'),
                )
              else
                const Text('Torch not available on this device'),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Advanced Usage

#### Turn On/Off

```dart
final torch = NativeTorch();

// Turn on the torch
await torch.turnOn();

// Turn off the torch
await torch.turnOff();

// Toggle torch state
await torch.toggle();
```

#### Check Torch Status

```dart
// Check if device has torch capability
bool isAvailable = await torch.isTorchAvailable();

// Get current torch state
bool isOn = await torch.isTorchOn();
```

#### Intensity Control

```dart
// Set torch intensity (0.0 to 1.0)
// Higher values = brighter
bool success = await torch.setIntensity(0.7);

// Get maximum supported intensity levels
int maxIntensity = await torch.getMaxIntensity();
```

## API Reference

### Methods

#### `isTorchAvailable() → Future<bool>`

Checks if the device has a torch/flashlight.

**Returns:** `true` if torch is available, `false` otherwise

#### `turnOn() → Future<void>`

Turns on the torch/flashlight.

**Throws:** `PlatformException` if the operation fails

#### `turnOff() → Future<void>`

Turns off the torch/flashlight.

**Throws:** `PlatformException` if the operation fails

#### `toggle() → Future<void>`

Toggles the torch between on and off states.

**Throws:** `PlatformException` if the operation fails

#### `isTorchOn() → Future<bool>`

Gets the current torch state.

**Returns:** `true` if torch is on, `false` if off

#### `setIntensity(double intensity) → Future<bool>`

Sets the torch intensity/brightness.

**Parameters:**

- `intensity` (double): A value between 0.0 and 1.0
  - 0.0 = off
  - 1.0 = maximum brightness

**Returns:** `true` if the operation succeeded, `false` otherwise

**Throws:** `ArgumentError` if intensity is not between 0.0 and 1.0

#### `getMaxIntensity() → Future<int>`

Gets the maximum number of intensity levels supported by the device.

**Returns:** The maximum intensity level (1 for iOS, varies for Android)

## Platform Implementation Details

### Android

- Uses `CameraManager` and `CameraCharacteristics` for torch control
- Requires `CAMERA` permission
- Supports intensity control on Android 13+
- Defaults to full brightness on older versions

### iOS

- Uses `AVCaptureDevice` with `hasTorch` property
- Supports intensity control via `setTorchModeOn(level:)`
- Returns `maxAvailableTorchLevel` for intensity scaling

## Required Permissions

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera.flash" />
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to control the flashlight</string>
```

## Examples

See the `example/` directory for a complete working example app.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Testing

Run tests with:

```bash
flutter test
```

## Troubleshooting

### Torch not turning on

1. Verify the device has a torch/flashlight (check with `isTorchAvailable()`)
2. Ensure camera permissions are granted
3. Check that the torch isn't already on from another app

### Intensity control not working

1. On Android, intensity control requires Android 13+
2. On iOS, all versions support intensity control
3. Use `getMaxIntensity()` to verify intensity support

### Permission Denied errors

- Make sure permissions are declared in manifest files
- Request runtime permissions on Android 6+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
