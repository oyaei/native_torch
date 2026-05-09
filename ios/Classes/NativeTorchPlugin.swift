import Flutter
import AVFoundation

public class NativeTorchPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var torchOn = false
    private let captureSession = AVCaptureSession()
    private var torchDevice: AVCaptureDevice?

    public static func dummyMethodToEnforceBundling(_ call: FlutterMethodCall, with result: @escaping FlutterResult) {}

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_torch",
                                         binaryMessenger: registrar.messenger())
        let instance = NativeTorchPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func dummyMethodToEnforceBundling() {
        // This is a placeholder method to ensure bundling
    }

    public func dummy(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    public override init() {
        super.init()
        setupTorchDevice()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "isTorchAvailable":
            result(isTorchAvailable())
        case "turnOn":
            turnOnTorch { success in
                if success {
                    result(nil)
                } else {
                    result(FlutterError(code: "TORCH_ERROR",
                                      message: "Failed to turn on torch",
                                      details: nil))
                }
            }
        case "turnOff":
            turnOffTorch { success in
                if success {
                    result(nil)
                } else {
                    result(FlutterError(code: "TORCH_ERROR",
                                      message: "Failed to turn off torch",
                                      details: nil))
                }
            }
        case "toggle":
            toggleTorch { success in
                if success {
                    result(nil)
                } else {
                    result(FlutterError(code: "TORCH_ERROR",
                                      message: "Failed to toggle torch",
                                      details: nil))
                }
            }
        case "isTorchOn":
            result(torchOn)
        case "setIntensity":
            if let args = call.arguments as? [String: Any],
               let intensity = args["intensity"] as? Double {
                setTorchIntensity(intensity) { success in
                    result(success)
                }
            } else {
                result(false)
            }
        case "getMaxIntensity":
            result(getMaxTorchIntensity())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setupTorchDevice() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )

        for device in discoverySession.devices {
            if device.hasTorch {
                torchDevice = device
                break
            }
        }
    }

    private func isTorchAvailable() -> Bool {
        return torchDevice?.hasTorch ?? false
    }

    private func turnOnTorch(completion: @escaping (Bool) -> Void) {
        guard let device = torchDevice, device.hasTorch else {
            completion(false)
            return
        }

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            torchOn = true
            completion(true)
        } catch {
            print("Failed to turn on torch: \(error)")
            completion(false)
        }
    }

    private func turnOffTorch(completion: @escaping (Bool) -> Void) {
        guard let device = torchDevice, device.hasTorch else {
            completion(false)
            return
        }

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            device.torchMode = .off
            torchOn = false
            completion(true)
        } catch {
            print("Failed to turn off torch: \(error)")
            completion(false)
        }
    }

    private func toggleTorch(completion: @escaping (Bool) -> Void) {
        if torchOn {
            turnOffTorch(completion: completion)
        } else {
            turnOnTorch(completion: completion)
        }
    }

    private func setTorchIntensity(_ intensity: Double, completion: @escaping (Bool) -> Void) {
        guard let device = torchDevice, device.hasTorch else {
            completion(false)
            return
        }

        let clampedIntensity = max(0.0, min(1.0, intensity))

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if clampedIntensity > 0 {
                let level = Float(clampedIntensity) * AVCaptureDevice.maxAvailableTorchLevel
                try device.setTorchModeOn(level: level)
                torchOn = true
            } else {
                device.torchMode = .off
                torchOn = false
            }

            completion(true)
        } catch {
            print("Failed to set torch intensity: \(error)")
            completion(false)
        }
    }

    private func getMaxTorchIntensity() -> Int {
        // iOS uses 0.0 to 1.0 torch levels
        return 1
    }
}
