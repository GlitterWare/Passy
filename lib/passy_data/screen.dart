enum Screen {
  main,
  passwords,
  notes,
  paymentCards,
  idCards,
  identities,
}

const screenToJson = {
  Screen.main: 'main',
  Screen.passwords: 'passwords',
  Screen.paymentCards: 'paymentCards',
  Screen.notes: 'notes',
  Screen.idCards: 'idCards',
  Screen.identities: 'identities',
};
const screenFromJson = {
  'main': Screen.main,
  'passwords': Screen.passwords,
  'paymentCards': Screen.paymentCards,
  'notes': Screen.notes,
  'idCards': Screen.idCards,
  'identities': Screen.identities,
};
