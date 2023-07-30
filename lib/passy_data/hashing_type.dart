enum HashingType {
  none,
  argon2,
}

HashingType? hashingTypeFromName(String name) {
  switch (name) {
    case 'none':
      return HashingType.none;
    case 'argon2':
      return HashingType.argon2;
  }
  return null;
}
