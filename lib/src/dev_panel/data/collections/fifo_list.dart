import 'dart:collection';

/// A First-In-First-Out list with a maximum capacity.
///
/// When the list reaches capacity, the oldest items are automatically
/// removed to make room for new items.
class FifoList<T> with IterableMixin<T> {
  final int _maxSize;
  final List<T> _items = [];

  /// Creates a [FifoList] with the specified maximum size.
  ///
  /// [maxSize] must be greater than 0.
  FifoList(this._maxSize) : assert(_maxSize > 0, 'maxSize must be positive');

  /// The maximum number of items this list can hold.
  int get maxSize => _maxSize;

  /// The current number of items in the list.
  @override
  int get length => _items.length;

  /// Whether the list is at maximum capacity.
  bool get isFull => _items.length >= _maxSize;

  /// Whether the list is empty.
  @override
  bool get isEmpty => _items.isEmpty;

  /// Whether the list is not empty.
  @override
  bool get isNotEmpty => _items.isNotEmpty;

  /// Adds an item to the end of the list.
  ///
  /// If the list is at capacity, removes the oldest item first.
  void add(T item) {
    if (_items.length >= _maxSize) {
      _items.removeAt(0);
    }
    _items.add(item);
  }

  /// Adds all items to the list, respecting the capacity limit.
  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  /// Returns the item at the specified index.
  T operator [](int index) => _items[index];

  /// Removes and returns the first item.
  T removeFirst() => _items.removeAt(0);

  /// Removes a specific item.
  bool remove(T item) => _items.remove(item);

  /// Removes all items that match the predicate.
  void removeWhere(bool Function(T) test) => _items.removeWhere(test);

  /// Clears all items from the list.
  void clear() => _items.clear();

  /// Returns items in reverse order (newest first).
  List<T> get reversed => _items.reversed.toList();

  /// Returns a copy of the internal list.
  @override
  List<T> toList({bool growable = true}) => List.from(_items);

  /// Finds items matching a predicate.
  @override
  Iterable<T> where(bool Function(T) test) => _items.where(test);

  /// Returns the first item matching a predicate, or null.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in _items) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Returns the first item.
  @override
  T get first => _items.first;

  /// Returns the last item.
  @override
  T get last => _items.last;

  @override
  Iterator<T> get iterator => _items.iterator;
}
