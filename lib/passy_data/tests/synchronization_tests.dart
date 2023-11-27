import 'package:encrypt/encrypt.dart' as crypt;
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/synchronization.dart';

void synchronizationTest({
  void Function()? onConnected,
  void Function(SynchronizationResults results)? onComplete,
  void Function(String error)? onError,
}) async {
  crypt.Key key = (await data.derivePassword('syn', password: 'syn'))!;
  crypt.Encrypter encrypter = getPassyEncrypterFromBytes(key.bytes);
  LoadedAccount syn = await data.loadAccount('syn', encrypter, key,
      encryptedPassword: encrypt('sync', encrypter: encrypter));
  syn.getSynchronization()!.host().then((value) => syn
      .getSynchronization(
          onConnected: onConnected, onComplete: onComplete, onError: onError)!
      .connect(value!));
}
