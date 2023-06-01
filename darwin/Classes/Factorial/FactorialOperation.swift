#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

/// Cancellable operation and the corresponding stream
public struct FactorialOperation {
    let task: FactorialTask
    let stream: FlutterStreamHandler
}
