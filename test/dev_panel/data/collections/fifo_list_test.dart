import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/data/collections/fifo_list.dart';

void main() {
  group('FifoList', () {
    group('constructor', () {
      test('creates with specified maxSize', () {
        final list = FifoList<int>(10);
        expect(list.maxSize, 10);
      });

      test('asserts maxSize is positive', () {
        expect(() => FifoList<int>(0), throwsAssertionError);
        expect(() => FifoList<int>(-1), throwsAssertionError);
      });

      test('starts empty', () {
        final list = FifoList<int>(10);
        expect(list.isEmpty, true);
        expect(list.isNotEmpty, false);
        expect(list.length, 0);
      });
    });

    group('add', () {
      test('adds items correctly', () {
        final list = FifoList<int>(5);
        list.add(1);
        list.add(2);
        list.add(3);

        expect(list.length, 3);
        expect(list.toList(), [1, 2, 3]);
      });

      test('removes oldest when at capacity', () {
        final list = FifoList<int>(3);
        list.add(1);
        list.add(2);
        list.add(3);
        list.add(4);

        expect(list.length, 3);
        expect(list.toList(), [2, 3, 4]);
      });

      test('maintains maxSize after multiple overflows', () {
        final list = FifoList<int>(2);
        for (int i = 0; i < 10; i++) {
          list.add(i);
        }

        expect(list.length, 2);
        expect(list.toList(), [8, 9]);
      });
    });

    group('addAll', () {
      test('adds all items', () {
        final list = FifoList<int>(10);
        list.addAll([1, 2, 3]);

        expect(list.length, 3);
        expect(list.toList(), [1, 2, 3]);
      });

      test('respects capacity when adding multiple', () {
        final list = FifoList<int>(3);
        list.addAll([1, 2, 3, 4, 5]);

        expect(list.length, 3);
        expect(list.toList(), [3, 4, 5]);
      });
    });

    group('isFull', () {
      test('returns false when not at capacity', () {
        final list = FifoList<int>(5);
        list.add(1);
        list.add(2);

        expect(list.isFull, false);
      });

      test('returns true when at capacity', () {
        final list = FifoList<int>(3);
        list.add(1);
        list.add(2);
        list.add(3);

        expect(list.isFull, true);
      });
    });

    group('operator []', () {
      test('returns item at index', () {
        final list = FifoList<String>(5);
        list.add('a');
        list.add('b');
        list.add('c');

        expect(list[0], 'a');
        expect(list[1], 'b');
        expect(list[2], 'c');
      });

      test('throws RangeError for invalid index', () {
        final list = FifoList<int>(5);
        list.add(1);

        expect(() => list[5], throwsRangeError);
        expect(() => list[-1], throwsRangeError);
      });
    });

    group('removeFirst', () {
      test('removes and returns first item', () {
        final list = FifoList<int>(5);
        list.add(1);
        list.add(2);
        list.add(3);

        final removed = list.removeFirst();

        expect(removed, 1);
        expect(list.length, 2);
        expect(list.toList(), [2, 3]);
      });

      test('throws StateError when empty', () {
        final list = FifoList<int>(5);
        expect(() => list.removeFirst(), throwsRangeError);
      });
    });

    group('remove', () {
      test('removes specific item', () {
        final list = FifoList<int>(5);
        list.add(1);
        list.add(2);
        list.add(3);

        final removed = list.remove(2);

        expect(removed, true);
        expect(list.toList(), [1, 3]);
      });

      test('returns false if item not found', () {
        final list = FifoList<int>(5);
        list.add(1);

        final removed = list.remove(99);

        expect(removed, false);
        expect(list.length, 1);
      });
    });

    group('removeWhere', () {
      test('removes items matching predicate', () {
        final list = FifoList<int>(10);
        list.addAll([1, 2, 3, 4, 5, 6]);

        list.removeWhere((item) => item.isEven);

        expect(list.toList(), [1, 3, 5]);
      });
    });

    group('clear', () {
      test('removes all items', () {
        final list = FifoList<int>(5);
        list.addAll([1, 2, 3]);

        list.clear();

        expect(list.isEmpty, true);
        expect(list.length, 0);
      });
    });

    group('reversed', () {
      test('returns items in reverse order', () {
        final list = FifoList<int>(5);
        list.add(1);
        list.add(2);
        list.add(3);

        expect(list.reversed, [3, 2, 1]);
      });

      test('returns new list (not affecting original)', () {
        final list = FifoList<int>(5);
        list.add(1);
        list.add(2);

        final reversed = list.reversed;
        reversed.add(99);

        expect(list.length, 2);
        expect(reversed.length, 3);
      });
    });

    group('toList', () {
      test('returns copy of items', () {
        final list = FifoList<int>(5);
        list.add(1);
        list.add(2);

        final copy = list.toList();
        copy.add(99);

        expect(list.length, 2);
        expect(copy.length, 3);
      });
    });

    group('where', () {
      test('returns items matching predicate', () {
        final list = FifoList<int>(10);
        list.addAll([1, 2, 3, 4, 5]);

        final result = list.where((item) => item > 3);

        expect(result.toList(), [4, 5]);
      });
    });

    group('firstWhereOrNull', () {
      test('returns first matching item', () {
        final list = FifoList<int>(10);
        list.addAll([1, 2, 3, 4, 5]);

        final result = list.firstWhereOrNull((item) => item > 2);

        expect(result, 3);
      });

      test('returns null when no match', () {
        final list = FifoList<int>(10);
        list.addAll([1, 2, 3]);

        final result = list.firstWhereOrNull((item) => item > 10);

        expect(result, isNull);
      });
    });

    group('first and last', () {
      test('first returns first item', () {
        final list = FifoList<int>(5);
        list.addAll([1, 2, 3]);

        expect(list.first, 1);
      });

      test('last returns last item', () {
        final list = FifoList<int>(5);
        list.addAll([1, 2, 3]);

        expect(list.last, 3);
      });

      test('first throws StateError when empty', () {
        final list = FifoList<int>(5);
        expect(() => list.first, throwsStateError);
      });

      test('last throws StateError when empty', () {
        final list = FifoList<int>(5);
        expect(() => list.last, throwsStateError);
      });
    });

    group('iterator', () {
      test('allows iteration', () {
        final list = FifoList<int>(5);
        list.addAll([1, 2, 3]);

        final collected = <int>[];
        for (final item in list) {
          collected.add(item);
        }

        expect(collected, [1, 2, 3]);
      });
    });
  });
}
