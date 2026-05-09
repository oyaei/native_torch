import 'package:flutter/material.dart';
import 'package:native_torch/native_torch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nativeTorchPlugin = NativeTorch();
  bool _isTorchAvailable = false;
  bool _isTorchOn = false;
  double _intensity = 1.0;
  int _maxIntensity = 1;
  String _platformVersion = '';

  @override
  void initState() {
    super.initState();
    _initTorch();
  }

  Future<void> _initTorch() async {
    try {
      // Get platform version
      final platformVersion = await _nativeTorchPlugin.getPlatformVersion();

      // Check if torch is available
      final isTorchAvailable = await _nativeTorchPlugin.isTorchAvailable();

      // Get initial torch state
      final isTorchOn = await _nativeTorchPlugin.isTorchOn();

      // Get max intensity
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

  Future<void> _turnOn() async {
    try {
      await _nativeTorchPlugin.turnOn();
      setState(() {
        _isTorchOn = true;
      });
    } catch (e) {
      print('Error turning on torch: $e');
    }
  }

  Future<void> _turnOff() async {
    try {
      await _nativeTorchPlugin.turnOff();
      setState(() {
        _isTorchOn = false;
      });
    } catch (e) {
      print('Error turning off torch: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Torch Plugin')),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Platform: $_platformVersion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isTorchAvailable
                        ? 'Torch: Available'
                        : 'Torch: Not Available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _isTorchAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _isTorchOn ? Colors.yellow : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: _isTorchOn
                          ? [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _isTorchOn ? 'ON' : 'OFF',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: _isTorchOn ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isTorchAvailable) ...[
                    ElevatedButton(
                      onPressed: _toggleTorch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Toggle'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _turnOn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Turn On'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _turnOff,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Turn Off'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_maxIntensity > 1)
                      Column(
                        children: [
                          Text(
                            'Intensity: ${(_intensity * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: _intensity,
                            min: 0.0,
                            max: 1.0,
                            divisions: 100,
                            label: '${(_intensity * 100).toStringAsFixed(0)}%',
                            onChanged: _setIntensity,
                          ),
                        ],
                      ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Torch is not available on this device',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
