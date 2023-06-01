#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

public class FactorialPlugin: NSObject, FlutterPlugin {
    static var messenger: FlutterBinaryMessenger?

    /// Currently executed operations
    private var operations: [String: FactorialOperation] = [:]

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
            result("iOS " + UIDevice.current.systemVersion)
            #elseif os(OSX)
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
            #endif
        case "factorial":
            factorial(call, result: result)
        case "cancel":
            cancel(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func factorial(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Parse the arguments
        guard let messenger = Self.messenger, let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(message: "Invalid arguments passed to the call"))
            return
        }
        // Process ID
        guard let uid = arguments["id"] as? String, operations[uid] == nil else {
            result(FlutterError(message: "Invalid or non-unique ID"))
            return
        }
        // Input number
        guard let number = arguments["number"] as? Int, number >= 0, number < 256 else {
            result(FlutterError(message: "Invalid number, must be in range [0, 255]"))
            return
        }

        // Intialize the event channel
        let stream = QueuedStreamHandler(name: "com.starkdev.factorial.\(uid)", messenger: messenger)
        let sink: (FactorialState) -> Void = { stream.sink($0.rawValue) }
        let endOfStream = { stream.sink(FlutterEndOfEventStream) }

        // Execution initialized
        result(nil)
        sink(.started)

        do {
            // Start the process
            let queue = DispatchQueue(label: "com.starkdev.factorial.\(uid)")
            let task = try Factorial.calculate(
                UInt8(number),
                queue: queue,
                onProgress: { progress in
                    sink(.progress(progress))
                },
                completion: { value in
                    self.operations[uid] = nil
                    if let value = value {
                        sink(.completed(value))
                    } else {
                        sink(.cancelled)
                    }
                    endOfStream()
                }
            )
            // Store the task
            operations[uid] = FactorialOperation(task: task, stream: stream)
        } catch let error {
            operations[uid] = nil
            sink(.failed(error))
            endOfStream()
        }
    }

    private func cancel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let uid = arguments["id"] as? String else {
            result(FlutterError(message: "Invalid arguments passed to the call"))
            return
        }

        guard let operation = operations[uid] else {
            // operation with provided ID doesn't exists
            result(false)
            return
        }

        // Cancel the operation
        operation.task.cancel()
        operations[uid] = nil

        // Complete with success
        result(true)
    }
}
