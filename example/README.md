# native_torch_example

A complete example application demonstrating how to use the `native_torch` plugin.

## Features Demonstrated

- ✅ Checking torch availability
- ✅ Turning torch on/off
- ✅ Toggling torch state
- ✅ Getting torch status
- ✅ Adjusting intensity/brightness
- ✅ Error handling and user feedback
- ✅ Platform detection

## Running the Example

### Prerequisites

- Flutter SDK (version 3.3.0 or higher)
- A physical device with a camera flash or emulator with virtual flash support
- Android SDK (for Android) or Xcode (for iOS)

### Steps

1. Navigate to the example directory:

```bash
cd example
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## App Structure

### Main Components

- **main.dart** - Main application entry point with complete torch control UI
- **integration_test/native_torch_integration_test.dart** - Integration tests

### Features in the Example App

#### 1. Torch Status Display

- Visual indicator showing if torch is on/off
- Color-coded UI (yellow when on, grey when off)
- Glowing effect when torch is active

#### 2. Control Buttons

- **Toggle Button** - Quick switch between on and off
- **Turn On Button** - Explicitly turn torch on
- **Turn Off Button** - Explicitly turn torch off

#### 3. Intensity Slider

- Adjust brightness from 0% to 100%
- Available on supported devices (Android 13+ and all iOS versions)
- Real-time feedback

#### 4. Status Information

- Platform version display
- Torch availability status
- Current torch state

#### 5. Error Handling

- Graceful handling of unavailable torch
- User-friendly error messages
- Safe state management

## Code Examples from the App

### Initialize Torch

```dart
Future<void> _initTorch() async {
  try {
    final platformVersion = await _nativeTorchPlugin.getPlatformVersion();
    final isTorchAvailable = await _nativeTorchPlugin.isTorchAvailable();
    final isTorchOn = await _nativeTorchPlugin.isTorchOn();
    final maxIntensity = await _nativeTorchPlugin.getMaxIntensity();

    setState(() {
      _platformVersion = platformVersion ?? 'Unknown';
      _isTorchAvailable = isTorchAvailable;
      _isTorchOn = isTorchOn;
      _maxIntensity = maxIntensity;
    });
  } catch (e) {
    print('Error initializing torch: $e');
  }
}
```

### Toggle Torch

```dart
Future<void> _toggleTorch() async {
  try {
    await _nativeTorchPlugin.toggle();
    final isTorchOn = await _nativeTorchPlugin.isTorchOn();
    setState(() {
      _isTorchOn = isTorchOn;
    });
  } catch (e) {
    print('Error toggling torch: $e');
  }
}
```

### Adjust Intensity

```dart
Future<void> _setIntensity(double value) async {
  try {
    final success = await _nativeTorchPlugin.setIntensity(value);
    if (success) {
      setState(() {
        _intensity = value;
      });
    }
  } catch (e) {
    print('Error setting intensity: $e');
  }
}
```

## Testing the App

### Manual Testing

1. Launch the app
2. Check if torch is available (should show "Available" or "Not Available")
3. Try turning torch on - device's flashlight should turn on
4. Adjust intensity slider if available
5. Try toggle button - should switch between on and off
6. Observe the visual indicator changing

### Integration Testing

Run integration tests:

```bash
flutter test integration_test/native_torch_integration_test.dart
```

Tests cover:

- Torch availability check
- Turn on/off functionality
- Toggle operation
- Status retrieval
- Intensity control (if supported)
- Proper cleanup

## Platform-Specific Notes

### Android

- Minimum API Level: 21
- Required Permission: `android.permission.CAMERA`
- Intensity control: Available on Android 13+
- The app will work on older versions but intensity control won't be available

### iOS

- Minimum iOS Version: 11.0
- Required: Camera usage description in Info.plist
- Intensity control: Available on all versions
- The app provides full functionality on all supported iOS versions

## Troubleshooting

### App Crashes on Launch

1. Ensure you're running on a physical device or an emulator that supports camera flash
2. Check that permissions are granted
3. Verify the Flutter version meets requirements (3.3.0+)

### Torch Won't Turn On

1. Check the "Torch: Available/Not Available" status
2. If "Not Available", your device doesn't have a flash
3. If available but won't turn on, check app permissions
4. Try turning off torch from other apps first

### Intensity Slider Not Showing

1. This is normal - it appears only on supported devices
2. On Android, requires Android 13 or later
3. On iOS, should appear on all versions

### Permission Errors

1. On Android 6+, the app should request permissions at runtime
2. If still failing, manually check app permissions in settings
3. For iOS, ensure Info.plist has camera usage description

## Next Steps

1. Review the [main package documentation](../README.md) for complete API reference
2. Check [USAGE_GUIDE.md](../USAGE_GUIDE.md) for advanced examples
3. Explore the source code in [main.dart](lib/main.dart)
4. Run integration tests to verify functionality

## Additional Resources

- [Flutter Documentation](https://flutter.dev)
- [Platform Channels Guide](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Android CameraManager Documentation](https://developer.android.com/reference/android/hardware/camera2/CameraManager)
- [iOS AVCaptureDevice Documentation](https://developer.apple.com/documentation/avfoundation/avcapturedevice)

## Support

For issues or questions about the example app, please refer to the main package repository or contact the development team.
