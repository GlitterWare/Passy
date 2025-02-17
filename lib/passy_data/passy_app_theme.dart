enum PassyAppTheme {
  classicDark,
  classicDarkOLED,
  classicLight,
  emeraldDark,
  emeraldDarkOLED,
  emeraldLight,
  custom,
}

PassyAppTheme? passyAppThemeFromName(String name) {
  switch (name) {
    case 'classicDark':
      return PassyAppTheme.classicDark;
    case 'classicDarkOLED':
      return PassyAppTheme.classicDarkOLED;
    case 'classicLight':
      return PassyAppTheme.classicLight;
    case 'emeraldDark':
      return PassyAppTheme.emeraldDark;
    case 'emeraldDarkOLED':
      return PassyAppTheme.emeraldDarkOLED;
    case 'emeraldLight':
      return PassyAppTheme.emeraldLight;
    case 'custom':
      return PassyAppTheme.custom;
  }
  return null;
}
