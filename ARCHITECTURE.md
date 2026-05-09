# Architecture Overview - native_torch

This document describes the architecture and design of the `native_torch` Flutter plugin.

## Overview

The `native_torch` plugin follows Flutter's plugin architecture with a layered approach:

```
┌─────────────────────────────────────────────────────────┐
│         Dart Application (Flutter App)                   │
├─────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐ │
│  │         NativeTorch (Public API)                   │ │
│  │  - Singleton pattern                               │ │
│  │  - High-level torch control methods                │ │
│  └────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐ │
│  │  NativeTorchPlatform (Platform Interface)          │ │
│  │  - Abstract base class                             │ │
│  │  - Defines method contracts                        │ │
│  └────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐ │
│  │ MethodChannelNativeTorch (Method Channel Bridge)   │ │
│  │  - Implements NativeTorchPlatform                  │ │
│  │  - Handles platform method invocation              │ │
│  │  - Method Channel: "native_torch"                  │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
           ⇅ Method Channel Communication ⇅
┌─────────────────────────────────────────────────────────┐
│         Native Platform Layer                           │
├─────────────────────────────────────────────────────────┤
│  ┌────────────────────┐  ┌──────────────────────────┐  │
│  │   Android (Kotlin) │  │    iOS (Swift)           │  │
│  │ ┌──────────────┐   │  │ ┌────────────────────┐   │  │
│  │ │NativeTorch   │   │  │ │NativeTorchPlugin   │   │  │
│  │ │Plugin        │   │  │ │- AVCaptureDevice   │   │  │
│  │ │- CameraManager   │  │ │- Torch control     │   │  │
│  │ │- Torch control  │  │ │                    │   │  │
│  │ └──────────────┘   │  │ └────────────────────┘   │  │
│  └────────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
           ⇅ Native APIs ⇅
┌─────────────────────────────────────────────────────────┐
│         Device Hardware Layer                           │
├─────────────────────────────────────────────────────────┤
│  ┌────────────────────┐  ┌──────────────────────────┐  │
│  │   Camera Manager   │  │    AVCaptureDevice       │  │
│  │   (Android)        │  │    (iOS)                 │  │
│  └────────────────────┘  └──────────────────────────┘  │
│  ┌────────────────────┐  ┌──────────────────────────┐  │
│  │   Device Flash     │  │    Device Torch          │  │
│  │   (LED)            │  │    (LED)                 │  │
│  └────────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Dart Layer

#### `NativeTorch` (main.dart)

- **Purpose:** Public API for end users
- **Pattern:** Singleton
- **Responsibility:**
  - Provides high-level torch control methods
  - Delegates to `NativeTorchPlatform.instance`
  - Maintains consistent interface

```dart
class NativeTorch {
  static final NativeTorch _instance = NativeTorch._();

  factory NativeTorch() {
    return _instance;
  }

  // Public methods that delegate to platform interface
}
```

#### `NativeTorchPlatform` (platform_interface.dart)

- **Purpose:** Define contract for platform-specific implementations
- **Responsibility:**
  - Abstract method definitions
  - Singleton instance management
  - Platform interface token verification

```dart
abstract class NativeTorchPlatform extends PlatformInterface {
  static NativeTorchPlatform _instance = MethodChannelNativeTorch();

  static NativeTorchPlatform get instance => _instance;

  // Abstract methods to be implemented by platforms
}
```

#### `MethodChannelNativeTorch` (method_channel.dart)

- **Purpose:** Bridge between Dart and native platforms via Method Channel
- **Responsibility:**
  - Implement `NativeTorchPlatform` interface
  - Invoke native methods through Method Channel
  - Handle return values and exceptions
  - Validate input parameters

```dart
class MethodChannelNativeTorch extends NativeTorchPlatform {
  final methodChannel = const MethodChannel('native_torch');

  @override
  Future<void> turnOn() async {
    await methodChannel.invokeMethod<void>('turnOn');
  }

  // Other method implementations
}
```

### 2. Platform Layer

#### Android Implementation (Kotlin)

**File:** `android/app/src/main/kotlin/com/oyaiz/packages/native_torch/NativeTorchPlugin.kt`

**Components:**

- `NativeTorchPlugin` class implementing `FlutterPlugin`
- Method Channel setup in `onAttachedToEngine()`
- Switch statement for handling method calls

**Key Features:**

- Uses `CameraManager` from Android Camera2 API
- Handles camera ID discovery
- Implements torch state management
- Supports intensity control (Android 13+)

**Method Handling:**

```kotlin
when (call.method) {
    "turnOn" -> turnOnTorch(context)
    "turnOff" -> turnOffTorch(context)
    "isTorchOn" -> result.success(torchOn)
    // Other methods...
}
```

#### iOS Implementation (Swift)

**File:** `ios/Classes/NativeTorchPlugin.swift`

**Components:**

- `NativeTorchPlugin` class implementing FlutterPlugin
- Method Channel setup through `handle()` function
- Switch statement for handling method calls

**Key Features:**

- Uses `AVCaptureDevice` for torch control
- Automatic device discovery
- Handles torch intensity with `setTorchModeOn(level:)`
- Proper device locking/unlocking

**Method Handling:**

```swift
switch call.method {
case "turnOn":
    turnOnTorch { success in
        result(success ? nil : FlutterError(...))
    }
case "turnOff":
    turnOffTorch { success in
        result(success ? nil : FlutterError(...))
    }
    // Other cases...
}
```

### 3. Method Channel Communication

#### Channel Specification

- **Name:** `native_torch`
- **Type:** Method Channel (bidirectional)
- **Messages:** Method calls with parameters

#### Message Flow

**Dart to Native:**

```
NativeTorch.turnOn()
    ⇓
NativeTorchPlatform.turnOn()
    ⇓
MethodChannelNativeTorch.turnOn()
    ⇓
methodChannel.invokeMethod('turnOn')
    ⇓
Platform-specific handler
```

**Native to Dart:**

```
Native result/error
    ⇓
result.success() / result.error()
    ⇓
Method Channel returns
    ⇓
Future completes
    ⇓
Dart code continues
```

## Design Patterns

### 1. Singleton Pattern

- `NativeTorch` uses singleton to ensure single instance
- Reduces resource usage
- Maintains consistent state

### 2. Platform Interface Pattern

- `NativeTorchPlatform` provides abstraction
- Allows multiple implementations
- Enables testing with mocks

### 3. Method Channel Pattern

- Standard Flutter plugin communication
- Supports cross-platform compatibility
- Handles serialization/deserialization

### 4. Factory Pattern

- `NativeTorch()` uses factory constructor
- Returns singleton instance
- Hides implementation details

## Data Flow

### Turning On Torch

```
User Action (Button Tap)
    ⇓
torch.turnOn()
    ⇓
NativeTorchPlatform.instance.turnOn()
    ⇓
MethodChannelNativeTorch.turnOn()
    ⇓
methodChannel.invokeMethod('turnOn')
    ⇓
[Method Channel Boundary]
    ⇓
Android/iOS native code:
  - Get camera device
  - Set torch mode to ON
  - Update torchOn flag
    ⇓
Return success/error
    ⇓
[Method Channel Boundary]
    ⇓
Future resolves
    ⇓
App updates UI
```

### Getting Intensity

```
User Action (Slider Change)
    ⇓
torch.setIntensity(0.5)
    ⇓
Validate: 0.0 ≤ intensity ≤ 1.0
    ⇓
NativeTorchPlatform.instance.setIntensity(0.5)
    ⇓
MethodChannelNativeTorch.setIntensity(0.5)
    ⇓
methodChannel.invokeMethod('setIntensity', {'intensity': 0.5})
    ⇓
[Method Channel Boundary]
    ⇓
Android/iOS native code:
  - Convert 0.0-1.0 to device-specific intensity
  - Set torch intensity level
    ⇓
Return success/failure
    ⇓
[Method Channel Boundary]
    ⇓
Future resolves with bool
    ⇓
App updates UI state
```

## Error Handling

### Layer 1: Dart Validation

- Input parameter validation
- Type checking
- Range validation (e.g., intensity 0.0-1.0)

### Layer 2: Method Channel

- Serialization/deserialization errors
- Channel communication failures
- Timeout handling

### Layer 3: Platform Implementation

- Device API failures
- Permission issues
- Hardware unavailability

### Layer 4: Application

- User-friendly error messages
- Graceful degradation
- State recovery

## Testing Strategy

### Unit Tests (`test/`)

- Mock platform interface
- Test API methods
- Verify method delegation

### Integration Tests (`example/integration_test/`)

- Test actual platform communication
- Verify torch functionality on device
- Test error conditions

### Platform Tests

- Android: Local unit tests
- iOS: XCTest unit tests

## Performance Considerations

### Method Channel Overhead

- Minimal for simple operations (turn on/off)
- Negligible latency (~1-5ms)
- Suitable for real-time torch control

### Resource Usage

- Single camera device reference
- Minimal memory footprint
- Proper cleanup on detach

## Security Considerations

### Permissions

- Android: CAMERA permission required
- iOS: Camera usage description required
- Runtime permission requests (Android 6+)

### Hardening

- Input validation before native calls
- Error code sanitization
- Secure device communication

## Future Extensions

### Potential Features

1. **Torch profiles:** Save/recall intensity settings
2. **Torch scheduling:** Schedule torch on/off times
3. **SOS mode:** Blinking patterns for emergencies
4. **Multi-device:** Support external LED lights
5. **Analytics:** Track torch usage

### Backward Compatibility

- New methods added to platform interface
- Default implementations where possible
- Version checks for platform features

## Dependencies

### Dart/Flutter

- `plugin_platform_interface: ^2.0.2`

### Android

- Kotlin 1.7.10
- Android SDK 33 (compileSdkVersion)
- Minimum API Level 21

### iOS

- Swift 5.0
- iOS 11.0 minimum deployment target

## File Structure

```
native_torch/
├── lib/                                    # Dart source
│   ├── native_torch.dart                  # Main API
│   ├── native_torch_platform_interface.dart  # Platform interface
│   └── native_torch_method_channel.dart   # Method channel impl
├── android/                                # Android platform code
│   └── app/src/main/
│       ├── kotlin/com/oyaiz/packages/native_torch/
│       │   └── NativeTorchPlugin.kt
│       └── AndroidManifest.xml
├── ios/                                    # iOS platform code
│   ├── Classes/
│   │   └── NativeTorchPlugin.swift
│   ├── native_torch.podspec
│   └── Info.plist
├── test/                                   # Unit tests
├── example/                                # Example app
│   ├── lib/main.dart
│   └── integration_test/
└── pubspec.yaml
```

## Summary

The `native_torch` plugin follows Flutter's best practices with:

- Clear separation of concerns
- Platform abstraction layer
- Comprehensive error handling
- Efficient method channel communication
- Full platform support (Android & iOS)
- Comprehensive testing and documentation

This architecture enables maintainability, extensibility, and reliability for torch control functionality across platforms.
