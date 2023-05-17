import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/synchronization.dart';

void synchronizationTest({
  void Function()? onConnected,
  void Function(SynchronizationResults results)? onComplete,
  void Function(String error)? onError,
}) async {
  LoadedAccount syn = await data.loadAccount('syn', getPassyEncrypter('syn'));
  syn.getSynchronization()!.host().then((value) => syn
      .getSynchronization(
          onConnected: onConnected, onComplete: onComplete, onError: onError)!
      .connect(value!));
}
