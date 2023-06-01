#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

public extension FlutterError {
    convenience init(message: String) {
        self.init(
            code: "FactorialError",
            message: message,
            details: nil
        )
    }
}
