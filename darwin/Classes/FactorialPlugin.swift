#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

public class FactorialPlugin: NSObject, FlutterPlugin {
    static var messenger: FlutterBinaryMessenger?

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        Self.messenger = registrar.messenger()
        #elseif os(OSX)
        Self.messenger = registrar.messenger
        #endif

        let channel = FlutterMethodChannel(
            name: "com.starkdev.factorial",
            binaryMessenger: Self.messenger!
        )
        let instance = FactorialPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            #if os(iOS)
            result("iOS 16.4")
            #elseif os(OSX)
            result("macOS 13.4")
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
