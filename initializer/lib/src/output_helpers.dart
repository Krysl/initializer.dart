// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

import 'aggregate_results.dart';

/// Converts [Future], [Iterable], and [Stream] implementations
/// containing [MapEntry<String, R>] to a single [Stream] while ensuring all thrown
/// exceptions are forwarded through the return value.
Stream<MapEntry<String, R>>
    normalizeGeneratorOutput<R extends AggregateResults>(Object? value) {
  if (value == null) {
    return const Stream.empty();
  } else if (value is Future) {
    return StreamCompleter.fromFuture(value.then(normalizeGeneratorOutput<R>));
  } else if (value is MapEntry<String, R>) {
    value = [value];
  }

  if (value is Iterable) {
    value = Stream.fromIterable(value);
  }

  if (value is Stream) {
    return value.where((e) => e != null).map((e) {
      if (e is MapEntry<String, R>) {
        return e;
      }

      throw argError<R>(e as Object);
    });
  }
  throw argError<R>(value);
}

ArgumentError argError<R extends AggregateResults>(Object value) =>
    ArgumentError(
      'Must be a MapEntry<String, $R> or be an Iterable/Stream containing MapEntry<String, $R> values. '
      'Found `${Error.safeToString(value)}` (${value.runtimeType}).',
    );
