enum KeyDerivationType {
  none,
  argon2,
}

KeyDerivationType? keyDerivationTypeFromName(String name) {
  switch (name) {
    case 'none':
      return KeyDerivationType.none;
    case 'argon2':
      return KeyDerivationType.argon2;
  }
  return null;
}
