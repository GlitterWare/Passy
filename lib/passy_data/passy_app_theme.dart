enum PassyAppTheme {
  classicDark,
  classicLight,
  emeraldDark,
  emeraldLight,
  custom,
}

PassyAppTheme? passyAppThemeFromName(String name) {
  switch (name) {
    case 'classicDark':
      return PassyAppTheme.classicDark;
    case 'classicLight':
      return PassyAppTheme.classicLight;
    case 'emeraldDark':
      return PassyAppTheme.emeraldDark;
    case 'emeraldLight':
      return PassyAppTheme.emeraldLight;
    case 'custom':
      return PassyAppTheme.custom;
  }
  return null;
}
