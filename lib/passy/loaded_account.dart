import 'package:encrypt/encrypt.dart';
import 'package:passy/passy/account_data.dart';
import 'package:universal_io/io.dart';

import 'account_info.dart';

class LoadedAccount {
  final AccountInfo accountInfo;
  final AccountData accountData;

  LoadedAccount(this.accountInfo, File dataFile, Encrypter encrypter)
      : accountData = AccountData(dataFile, encrypter);
}
