/// Minimal fast_check shim matching the API used in property tests.
/// Provides fc.assert, fc.property, and arbitraries: fc.double, fc.integer,
/// fc.string, fc.boolean, fc.record, fc.subarray, fc.constantFrom, fc.dictionary.
library fast_check;

import 'dart:math';

// ─── Arbitrary ───────────────────────────────────────────────────────────────

abstract class Arbitrary<T> {
  T generate(Random rng, int size);
}

// ─── Primitives ──────────────────────────────────────────────────────────────

class _DoubleArbitrary extends Arbitrary<double> {
  final double min;
  final double max;
  _DoubleArbitrary({required this.min, required this.max});

  @override
  double generate(Random rng, int size) => min + rng.nextDouble() * (max - min);
}

class _IntegerArbitrary extends Arbitrary<int> {
  final int min;
  final int max;
  _IntegerArbitrary({required this.min, required this.max});

  @override
  int generate(Random rng, int size) => min + rng.nextInt(max - min + 1);
}

class _StringArbitrary extends Arbitrary<String> {
  static const _chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-';

  @override
  String generate(Random rng, int size) {
    final len = rng.nextInt(size.clamp(1, 20) + 1);
    return List.generate(len, (_) => _chars[rng.nextInt(_chars.length)]).join();
  }
}

class _BooleanArbitrary extends Arbitrary<bool> {
  @override
  bool generate(Random rng, int size) => rng.nextBool();
}

class _ConstantFromArbitrary<T> extends Arbitrary<T> {
  final List<T> values;
  _ConstantFromArbitrary(this.values);

  @override
  T generate(Random rng, int size) => values[rng.nextInt(values.length)];
}

class _SubarrayArbitrary<T> extends Arbitrary<List<T>> {
  final List<T> source;
  _SubarrayArbitrary(this.source);

  @override
  List<T> generate(Random rng, int size) {
    final result = <T>[];
    for (final item in source) {
      if (rng.nextBool()) result.add(item);
    }
    return result;
  }
}

class _RecordArbitrary extends Arbitrary<Map<String, dynamic>> {
  final Map<String, Arbitrary<dynamic>> fields;
  _RecordArbitrary(this.fields);

  @override
  Map<String, dynamic> generate(Random rng, int size) {
    return fields.map((k, v) => MapEntry(k, v.generate(rng, size)));
  }
}

class _DictionaryArbitrary<K, V> extends Arbitrary<Map<K, V>> {
  final Arbitrary<K> keyArb;
  final Arbitrary<V> valueArb;
  _DictionaryArbitrary(this.keyArb, this.valueArb);

  @override
  Map<K, V> generate(Random rng, int size) {
    final count = rng.nextInt(size.clamp(1, 8) + 1);
    final result = <K, V>{};
    for (var i = 0; i < count; i++) {
      result[keyArb.generate(rng, size)] = valueArb.generate(rng, size);
    }
    return result;
  }
}

// ─── Property ────────────────────────────────────────────────────────────────

class Property1<A> {
  final Arbitrary<A> arb;
  final void Function(A) predicate;
  Property1(this.arb, this.predicate);
}

class Property2<A, B> {
  final Arbitrary<A> arbA;
  final Arbitrary<B> arbB;
  final void Function(A, B) predicate;
  Property2(this.arbA, this.arbB, this.predicate);
}

// ─── Public API ──────────────────────────────────────────────────────────────

Arbitrary<double> double_({double min = 0, double max = 1}) =>
    _DoubleArbitrary(min: min, max: max);

Arbitrary<int> integer({int min = 0, int max = 100}) =>
    _IntegerArbitrary(min: min, max: max);

Arbitrary<String> string() => _StringArbitrary();

Arbitrary<bool> boolean() => _BooleanArbitrary();

Arbitrary<T> constantFrom<T>(List<T> values) =>
    _ConstantFromArbitrary<T>(values);

Arbitrary<List<T>> subarray<T>(List<T> source) =>
    _SubarrayArbitrary<T>(source);

Arbitrary<Map<String, dynamic>> record(Map<String, Arbitrary<dynamic>> fields) =>
    _RecordArbitrary(fields);

Arbitrary<Map<K, V>> dictionary<K, V>(
        Arbitrary<K> keyArb, Arbitrary<V> valueArb) =>
    _DictionaryArbitrary<K, V>(keyArb, valueArb);

Property1<A> property<A>(Arbitrary<A> arb, void Function(A) predicate) =>
    Property1<A>(arb, predicate);

void assertProperty<A>(Property1<A> prop, {int numRuns = 100}) {
  final rng = Random(42);
  for (var i = 0; i < numRuns; i++) {
    final value = prop.arb.generate(rng, i ~/ 10 + 1);
    prop.predicate(value);
  }
}

// Alias matching the prompt's fc.assert usage
void assertProp<A>(Property1<A> prop, {int numRuns = 100}) =>
    assertProperty(prop, numRuns: numRuns);
