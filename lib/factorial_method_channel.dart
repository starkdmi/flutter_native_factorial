import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'factorial_platform_interface.dart';

/// An implementation of [FactorialPlatform] that uses method channels.
class MethodChannelFactorial extends FactorialPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('factorial');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
