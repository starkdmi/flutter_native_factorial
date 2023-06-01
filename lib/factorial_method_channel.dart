import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'factorial_platform_interface.dart';
import 'factorial_state.dart';

/// An implementation of [FactorialPlatform] that uses method channels.
class MethodChannelFactorial extends FactorialPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.starkdev.factorial');

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  /// Calculate Factorial for `number` with process unique id - `id`
  /// Returns [Stream] of [FactorialState] populating factorial computation states
  @override
  Stream<FactorialState> calculate({ required String id, required int number }) async* {
    try {
      await methodChannel.invokeMethod<bool>('factorial', {
        'id': id,
        'number': number
      }); // nil

      final stream = EventChannel('com.starkdev.factorial.$id')
        .receiveBroadcastStream();

      await for (var event in stream) {
        if (event is bool) {
          if (event) {
            // started
            yield FactorialStartedState(id: id);
          } else {
            // cancelled
            yield FactorialCancelledState(id: id);
          }
        } else if (event is double) {
          // progress
          yield FactorialProgressState(id: id, progress: event);
        } else if (event is String) {
          // completed
          yield FactorialCompletedState(id: id, number: BigInt.parse(event));
        } else {
          throw 'Unknown data type received from Native platform';
        }
      }
    } catch (error) {
      // failed
      yield FactorialFailedState(id: id, error: error.toString());
    }
  }

  /// Returns true for successfull cancellation, false for invalid ID and throw an exception for invalid arguments
  @override
  Future<bool> cancel({ required String id }) async {
    return await methodChannel.invokeMethod<bool>('cancel', { 'id': id }) ?? false;
  }
}
