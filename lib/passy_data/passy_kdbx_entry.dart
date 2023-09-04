import 'package:kdbx/kdbx.dart';
import 'package:passy/passy_data/custom_field.dart';

import 'passy_kdbx_value.dart';

class PassyKdbxEntry {
  final List<PassyKdbxValue> values;

  PassyKdbxEntry({
    String? title,
    String? username,
    String? password,
    String? url,
    String? otp,
    List<CustomField> customFields = const [],
  }) : values = [
          if (title != null && title.isNotEmpty)
            PassyKdbxValue(key: KdbxKeyCommon.TITLE, value: PlainValue(title)),
          if (username != null && username.isNotEmpty)
            PassyKdbxValue(
                key: KdbxKeyCommon.USER_NAME, value: PlainValue(username)),
          if (password != null && password.isNotEmpty)
            PassyKdbxValue(
                key: KdbxKeyCommon.PASSWORD,
                value: ProtectedValue.fromString(password)),
          if (url != null && url.isNotEmpty)
            PassyKdbxValue(key: KdbxKeyCommon.URL, value: PlainValue(url)),
          if (otp != null && otp.isNotEmpty)
            PassyKdbxValue(
                key: KdbxKeyCommon.OTP, value: ProtectedValue.fromString(otp)),
          ...customFields.map((e) => PassyKdbxValue(
              key: KdbxKey(e.title),
              value: e.obscured
                  ? ProtectedValue.fromString(e.value)
                  : PlainValue(e.value))),
        ];
}
