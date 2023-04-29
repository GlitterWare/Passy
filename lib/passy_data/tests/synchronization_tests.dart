import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';

void synchronizationTest({
  void Function()? onConnected,
  void Function()? onComplete,
  void Function(String error)? onError,
}) {
  data.loadAccount('syn', getPassyEncrypter('syn'));
  data.loadedAccount!
      .getSynchronization(
          onConnected: onConnected, onComplete: onComplete, onError: onError)
      .host()
      .then(
          (value) => data.loadedAccount!.getSynchronization().connect(value!));
}
