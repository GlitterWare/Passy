import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/passwords_screen.dart';

enum Screen {
  main,
  passwords,
  notes,
  paymentCards,
  idCards,
  identities,
}

const screenToRouteName = {
  Screen.main: MainScreen.routeName,
  Screen.passwords: PasswordsScreen.routeName,
  Screen.notes: '',
  Screen.idCards: '',
  Screen.identities: '',
};

const screenToJson = {
  Screen.main: 'main',
  Screen.passwords: 'passwords',
  Screen.notes: 'notes',
  Screen.idCards: 'idCards',
  Screen.identities: 'identities',
};
const screenFromJson = {
  'main': Screen.main,
  'passwords': Screen.passwords,
  'notes': Screen.notes,
  'idCards': Screen.idCards,
  'identities': Screen.identities,
};
