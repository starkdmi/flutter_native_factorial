import 'package:factorial/factorial_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:factorial/factorial.dart';
import 'package:factorial/factorial_platform_interface.dart';
import 'package:factorial/factorial_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFactorialPlatform with MockPlatformInterfaceMixin implements FactorialPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Stream<FactorialState> calculate({ required String id, required int number }) => throw UnimplementedError();

  @override
  Future<bool> cancel({ required String id }) => throw UnimplementedError();
}

void main() {
  final FactorialPlatform initialPlatform = FactorialPlatform.instance;

  test('$MethodChannelFactorial is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFactorial>());
  });

  test('getPlatformVersion', () async {
    Factorial factorialPlugin = Factorial();
    MockFactorialPlatform fakePlatform = MockFactorialPlatform();
    FactorialPlatform.instance = fakePlatform;

    expect(await factorialPlugin.getPlatformVersion(), '42');
  });
}
