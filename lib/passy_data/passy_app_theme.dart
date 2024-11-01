enum PassyAppTheme {
  classicDark,
  classicLight,
  custom,
}

PassyAppTheme? passyAppThemeFromName(String name) {
  switch (name) {
    case 'classicDark':
      return PassyAppTheme.classicDark;
    case 'classicLight':
      return PassyAppTheme.classicLight;
    case 'custom':
      return PassyAppTheme.custom;
  }
  return null;
}
