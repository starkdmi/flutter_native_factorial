/// Cancellable operation
public class FactorialTask {
    private var _isCancelled = false
    public var isCancelled: Bool { _isCancelled }
    public func cancel() {  _isCancelled = true }
}
