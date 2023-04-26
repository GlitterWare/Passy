import 'dart:async';
import 'dart:typed_data';

/// A stream subscription delimited by newline characters.
/// When a newline character is detected, the handler supplied through [onData] is fired
/// for the received byte sequence.
class LineByteStreamSubscription extends StreamSubscription<List<int>> {
  final StreamSubscription<Uint8List> _subscription;
  List<int> _data = [];
  void Function(List<int>)? _handleData;

  LineByteStreamSubscription(this._subscription) {
    _subscription.onData((data) {
      for (int n in data) {
        if (n == 10) {
          _handleData?.call(_data);
          _data = [];
          continue;
        }
        _data.add(n);
      }
    });
  }

  @override
  Future<E> asFuture<E>([E? futureValue]) =>
      _subscription.asFuture(futureValue);

  @override
  Future<void> cancel() => _subscription.cancel();

  @override
  bool get isPaused => _subscription.isPaused;

  @override
  void onData(void Function(List<int> data)? handleData) =>
      _handleData = handleData;

  @override
  void onDone(void Function()? handleDone) => _subscription.onDone(handleDone);

  @override
  void onError(Function? handleError) => _subscription.onError(handleError);

  @override
  void pause([Future<void>? resumeSignal]) => _subscription.pause(resumeSignal);

  @override
  void resume() => _subscription.resume();
}
