import 'dart:async';
import 'dart:typed_data';

/// A stream subscription delimited by 0 bytes.
/// When a 0 byte character is detected, the handler supplied through [onData] is fired
/// for the received byte sequence.
class PassyStreamSubscription extends StreamSubscription<List<int>> {
  final StreamSubscription<Uint8List> _subscription;
  List<int> _data = [];
  void Function(List<int>)? _handleData;

  PassyStreamSubscription(this._subscription) {
    _subscription.onData((data) {
      for (int n in data) {
        _data.add(n);
        if (n == 0) {
          _data.removeLast();
          if (_handleData != null) {
            _handleData!(_data);
          }
          _data = [];
        }
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
