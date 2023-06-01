#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

/// Factorial computation state
public enum FactorialState {
    case started
    case progress(Double)
    case completed(UInt64)
    case failed(Error)
    case cancelled

    static func == (lhs: FactorialState, rhs: FactorialState) -> Bool {
        switch (lhs, rhs) {
        case (.started, .started):
            return true
        case (.progress(let lhsValue), .progress(let rhsValue)):
            return lhsValue == rhsValue
        case (.completed(let lhsValue), .completed(let rhsValue)):
            return lhsValue == rhsValue
        case (.failed(let lhsValue), .failed(let rhsValue)):
            return lhsValue.localizedDescription == rhsValue.localizedDescription
        case (.cancelled, .cancelled):
            return true
        default:
            return false
        }
    }

    var rawValue: Any {
        switch self {
        case .started:
            return true
        case .progress(let progress):
            return progress
        case .completed(let value):
            return String(value)
        case .failed(let error):
            if let taskError = error as? FactorialError {
                return FlutterError(message: taskError.rawValue)
            } else {
                return error
            }
        case .cancelled:
            return false
        }
    }
}
