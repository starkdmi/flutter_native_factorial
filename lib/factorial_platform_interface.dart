import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'factorial_method_channel.dart';
import 'factorial_state.dart';

abstract class FactorialPlatform extends PlatformInterface {
  /// Constructs a FactorialPlatform.
  FactorialPlatform() : super(token: _token);

  static final Object _token = Object();

  static FactorialPlatform _instance = MethodChannelFactorial();

  /// The default instance of [FactorialPlatform] to use.
  ///
  /// Defaults to [MethodChannelFactorial].
  static FactorialPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FactorialPlatform] when
  /// they register themselves.
  static set instance(FactorialPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Stream<FactorialState> calculate({ required String id, required int number }) {
    throw UnimplementedError('calculate() has not been implemented.');
  }

  Future<bool> cancel({ required String id }) async {
    throw UnimplementedError('cancel() has not been implemented.');
  }
}
