import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/config/error_stack_log_level.dart';

void main() {
  group('ErrorStackLogLevel', () {
    test('has minimal and verbose values', () {
      expect(ErrorStackLogLevel.values.length, 2);
      expect(ErrorStackLogLevel.values, contains(ErrorStackLogLevel.minimal));
      expect(ErrorStackLogLevel.values, contains(ErrorStackLogLevel.verbose));
    });

    test('minimal has correct index', () {
      expect(ErrorStackLogLevel.minimal.index, 0);
    });

    test('verbose has correct index', () {
      expect(ErrorStackLogLevel.verbose.index, 1);
    });

    test('enum name property returns correct string', () {
      expect(ErrorStackLogLevel.minimal.name, 'minimal');
      expect(ErrorStackLogLevel.verbose.name, 'verbose');
    });
  });
}
