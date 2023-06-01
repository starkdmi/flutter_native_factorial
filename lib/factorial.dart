
import 'factorial_platform_interface.dart';

class Factorial {
  Future<String?> getPlatformVersion() {
    return FactorialPlatform.instance.getPlatformVersion();
  }
}
