// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:factorial/factorial.dart';
import 'package:factorial/factorial_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getPlatformVersion test', (WidgetTester tester) async {
    final Factorial plugin = Factorial(); 
    final String? version = await plugin.getPlatformVersion();
    // The version string depends on the host platform running the test, so
    // just assert that some non-empty string is returned.
    expect(version?.isNotEmpty, true);
  });

  group('Factorial', () {
    final plugin = Factorial(); // Factorial() is a singletone, always same intance is returned

    test('single execution', () async {
      expect(plugin.calculate(id: '10001', number: 10), emitsThrough(
        FactorialCompletedState(id: '10001', number: BigInt.from(3628800)) // 10!
      ));
    });

    test('queued execution', () async {
      expect(plugin.calculate(id: '10002', number: 5), emitsThrough(
        FactorialCompletedState(id: '10002', number: BigInt.from(120)) // 5!
      ));

      expect(plugin.calculate(id: '10003', number: 10), emitsThrough(
        FactorialCompletedState(id: '10003', number: BigInt.from(3628800)) // 10!
      ));

      expect(plugin.calculate(id: '10004', number: 15), emitsThrough(
        FactorialCompletedState(id: '10004', number: BigInt.from(1307674368000)) // 15!
      ));
    });

    test('parallel execution', () async {
      Future<BigInt> getFuture({ required String id, required int number }) async {
        await for (final state in plugin.calculate(id: id, number: number)) {
          if (state is FactorialCompletedState) {
            return state.number;
          }
        }
        return BigInt.zero;
      }

      List<Future<BigInt>> futures = [];
      futures.add(getFuture(id: '10005', number: 20));
      futures.add(getFuture(id: '10006', number: 5));
      futures.add(getFuture(id: '10007', number: 15));

      final values = await Future.wait(futures);
      expect(values[0], equals(BigInt.from(2432902008176640000))); // 20!
      expect(values[1], equals(BigInt.from(120))); // 5!
      expect(values[2], equals(BigInt.from(1307674368000))); // 15!
    });

    test('progress & cancellation', () async {        
      const id = '10008';
      Future.delayed(const Duration(milliseconds: 500), () async {
        await plugin.cancel(id: id);
      });

      expect(
        plugin.calculate(id: id, number: 20),
        emitsInOrder(const [
          FactorialStartedState(id: id),
          FactorialProgressState(id: id, progress: 0.05),
          FactorialProgressState(id: id, progress: 0.10),
          FactorialProgressState(id: id, progress: 0.15),
          FactorialProgressState(id: id, progress: 0.20),
          FactorialProgressState(id: id, progress: 0.25),
          FactorialCancelledState(id: id),
        ]),
      );
    });
  });
}
