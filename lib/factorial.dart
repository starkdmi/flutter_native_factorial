import 'factorial_platform_interface.dart';
import 'factorial_state.dart';

class Factorial {
  Future<String?> getPlatformVersion() {
    return FactorialPlatform.instance.getPlatformVersion();
  }

  Stream<FactorialState> calculate({ required String id, required int number }) {
    return FactorialPlatform.instance.calculate(id: id, number: number);
  }

  Future<bool> cancel({ required String id }) {
    return FactorialPlatform.instance.cancel(id: id);
  }
}
