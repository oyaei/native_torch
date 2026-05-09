import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:native_torch/native_torch.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Native Torch Integration Tests', () {
    late NativeTorch torch;

    setUp(() {
      torch = NativeTorch();
    });

    testWidgets('Check torch availability', (WidgetTester tester) async {
      final available = await torch.isTorchAvailable();
      expect(available, isA<bool>());
    });

    testWidgets('Get platform version', (WidgetTester tester) async {
      final version = await torch.getPlatformVersion();
      expect(version, isNotNull);
      expect(version, isA<String>());
    });

    testWidgets('Turn on torch', (WidgetTester tester) async {
      final available = await torch.isTorchAvailable();
      if (available) {
        await torch.turnOn();
        final isOn = await torch.isTorchOn();
        expect(isOn, true);
      } else {
        print('Torch not available on this device');
      }
    });

    testWidgets('Turn off torch', (WidgetTester tester) async {
      final available = await torch.isTorchAvailable();
      if (available) {
        await torch.turnOff();
        final isOn = await torch.isTorchOn();
        expect(isOn, false);
      } else {
        print('Torch not available on this device');
      }
    });

    testWidgets('Toggle torch', (WidgetTester tester) async {
      final available = await torch.isTorchAvailable();
      if (available) {
        final initialState = await torch.isTorchOn();
        await torch.toggle();
        final newState = await torch.isTorchOn();
        expect(newState, !initialState);

        // Toggle back
        await torch.toggle();
        final backToInitial = await torch.isTorchOn();
        expect(backToInitial, initialState);
      } else {
        print('Torch not available on this device');
      }
    });

    testWidgets('Get torch status', (WidgetTester tester) async {
      final status = await torch.isTorchOn();
      expect(status, isA<bool>());
    });

    testWidgets('Set and get intensity', (WidgetTester tester) async {
      final available = await torch.isTorchAvailable();
      final maxIntensity = await torch.getMaxIntensity();

      if (available && maxIntensity > 1) {
        // Test valid intensities
        bool success = await torch.setIntensity(0.5);
        expect(success, isA<bool>());

        success = await torch.setIntensity(0.0);
        expect(success, isA<bool>());

        success = await torch.setIntensity(1.0);
        expect(success, isA<bool>());
      } else {
        print('Intensity control not supported on this device');
      }
    });

    testWidgets('Get max intensity', (WidgetTester tester) async {
      final maxIntensity = await torch.getMaxIntensity();
      expect(maxIntensity, isA<int>());
      expect(maxIntensity, greaterThan(0));
    });

    testWidgets('Turn off torch on cleanup', (WidgetTester tester) async {
      final available = await torch.isTorchAvailable();
      if (available) {
        await torch.turnOff();
        final isOn = await torch.isTorchOn();
        expect(isOn, false);
      }
    });
  });
}
