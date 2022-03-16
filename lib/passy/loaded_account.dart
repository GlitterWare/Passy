import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy/account_data.dart';

import 'account_info.dart';

class LoadedAccount {
  final AccountInfo accountInfo;
  final AccountData accountData;

  LoadedAccount(this.accountInfo, File dataFile, Encrypter encrypter)
      : accountData = AccountData.loadOrCreate(dataFile, encrypter);
}
