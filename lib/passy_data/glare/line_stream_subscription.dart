import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// A stream subscription delimited by newline characters.
/// When a newline character is detected, the handler supplied through [onData] is fired
/// for the received byte sequence.
class LineByteStreamSubscription implements StreamSubscription<List<int>> {
  final StreamSubscription<Uint8List> _subscription;
  List<int> _data = [];
  void Function(List<int>)? _handleData;
  Function? _handleError;

  LineByteStreamSubscription(this._subscription) {
    bool isExceeded = false;
    bool isEscaped = false;
    List<int> command = [];
    List<int> leftToReadList = [];
    bool isCommand = false;
    int? leftToReadState;
    int leftToRead = 0;
    _subscription.onData((data) {
      int i = 0;
      for (i; i != data.length; i++) {
        int n = data[i];
        if (leftToReadState != null) {
          switch (leftToReadState) {
            case 0:
              if (n == 60) {
                isCommand = true;
                leftToReadState = null;
                n = 44;
              }
              if (n == 44) {
                String leftToReadString;
                try {
                  leftToReadString = utf8.decode(leftToReadList);
                  leftToRead = int.parse(leftToReadString);
                } catch (_) {
                  _handleError?.call('Failed to parse left to read.');
                  leftToReadList.clear();
                  leftToReadState = null;
                  continue;
                }
                leftToReadList.clear();
                continue;
              }
              if (leftToReadList.length > 67108864) {
                leftToReadList.clear();
                leftToReadState = null;
                isExceeded = true;
              } else {
                leftToReadList.add(n);
              }
              continue;
            case 1:
              _data.add(n);
              leftToRead -= 1;
              if (leftToRead == 0) {
                leftToReadState = null;
                continue;
              }
              if (_data.length > 4 * 134217728) {
                leftToReadState = null;
                leftToRead = 0;
                isExceeded = true;
              }
              continue;
          }
        }
        if (isCommand) {
          if (n == 62) {
            isCommand = false;
            if (command.isEmpty) continue;
            String commandString;
            try {
              commandString = utf8.decode(command);
            } catch (_) {
              _handleError?.call('Failed to parse stream command.');
              command.clear();
              continue;
            }
            command.clear();
            switch (commandString) {
              case 'r':
                leftToReadState = 0;
                break;
              case '/r':
                leftToReadState = 1;
                break;
            }
          } else if (command.length < 8) {
            command.add(n);
          }
          continue;
        }
        if (isEscaped) {
          isEscaped = false;
          if (_data.length > 67108864) {
            isExceeded = true;
          } else {
            _data.add(n);
          }
          continue;
        }
        if (n == 10) {
          if (isExceeded) {
            try {
              _handleError?.call(
                  'Maximum data length exceeded: ${_data.length} > ${4 * 134217728}');
            } catch (_) {
              _handleError?.call(
                  'Maximum data length exceeded: ${_data.length} > ${4 * 134217728}',
                  null);
            }
            isExceeded = false;
          }
          _handleData?.call(_data);
          _data = [];
          continue;
        }
        if (_data.length > 4 * 134217728) {
          isExceeded = true;
        } else {
          switch (n) {
            case 60:
              isCommand = true;
              break;
            case 92:
              isEscaped = true;
              break;
            default:
              _data.add(n);
          }
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
  void onError(Function? handleError) {
    _subscription.onError(handleError);
    _handleError = handleError;
  }

  @override
  void pause([Future<void>? resumeSignal]) => _subscription.pause(resumeSignal);

  @override
  void resume() => _subscription.resume();
}
