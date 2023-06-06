import Foundation

/// A singletone
public class Factorial {
    /// The factorial calculation with progress and cancellation
    /// The delay of 0.1 sec is added to slow down the calculation
    public class func calculate(
        _ number: UInt8,
        queue: DispatchQueue = .global(),
        onProgress: ((Double) -> Void)? = nil,
        completion: @escaping (UInt64?) -> Void) throws -> FactorialTask {
        guard number <= 20 else {
            throw FactorialError.bigValue
        }

        // Cancellable object
        let task = FactorialTask()

        let max = Double(number) // all calls
        var index = 0.0 // done calls

        func factorial(_ num: UInt64) throws -> UInt64 {
            // Cancellation
            guard task.isCancelled == false else {
                throw FactorialError.cancelled
            }

            // Progress handling
            if let callback = onProgress {
                index += 1.0
                callback(index / max)
            }

            // Slow down the calculation
            Thread.sleep(forTimeInterval: 0.1) // usleep(100_000)

            // Recursive implementation of factorial algorithm
            return num <= 1 ? 1 : num * (try factorial(num - 1))
        }

        // Execute dispatched
        queue.async {
            do {
                let result = try factorial(UInt64(number))
                completion(result)
            } catch {
                // cancelled
                completion(nil)
            }
        }

        return task
    }
}
