import 'package:flutter_test/flutter_test.dart';
import 'package:factorial/factorial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final plugin = Factorial(); // Factorial() is a singletone, always the same intance is returned

  group('Factorial Test', () {
    group('getPlatformVersion', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformVersion = 'iOS 16.4';

        final actualPlatformVersion = await plugin.getPlatformVersion();
        expect(actualPlatformVersion, equals(platformVersion));
      });
    });
  });
}
