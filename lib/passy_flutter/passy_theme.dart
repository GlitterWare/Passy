import 'package:flutter/material.dart';

class PassyTheme extends ThemeExtension<PassyTheme> {
  final EdgeInsets passyPadding;
  final Color contentColor;
  final Color contentSecondaryColor;
  final Color contentTextColor;
  final Color secondaryContentColor;
  final Color highlightContentColor;
  final Color highlightContentSecondaryColor;
  final Color highlightContentTextColor;
  final Color accentContentColor;
  final Color accentContentTextColor;
  final ColorScheme datePickerColorScheme;

  const PassyTheme({
    this.passyPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.contentColor = const Color.fromRGBO(38, 50, 56, 1),
    this.secondaryContentColor = const Color.fromRGBO(0, 0, 0, 1),
    this.contentSecondaryColor = const Color.fromRGBO(84, 110, 122, 1),
    this.contentTextColor = const Color.fromRGBO(227, 242, 253, 1),
    this.highlightContentColor = const Color.fromRGBO(227, 242, 253, 1),
    this.highlightContentSecondaryColor =
        const Color.fromRGBO(144, 202, 249, 1),
    this.highlightContentTextColor = const Color.fromRGBO(38, 50, 56, 1),
    this.accentContentColor = darkPassyPurple,
    this.accentContentTextColor = const Color.fromRGBO(38, 50, 56, 1),
    this.datePickerColorScheme = const ColorScheme.dark(
      primary: Color.fromRGBO(144, 202, 249, 1),
      onPrimary: Color.fromRGBO(227, 242, 253, 1),
    ),
  });

  static PassyTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<PassyTheme>();

  static PassyTheme of(BuildContext context) {
    final PassyTheme? result = maybeOf(context);
    assert(result != null, 'No PassyTheme found in the context');
    return result!;
  }

  static ThemeData buildThemeData({
    ColorScheme colorScheme = const ColorScheme.dark(),
    EdgeInsets passyPadding =
        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    Color contentColor = const Color.fromRGBO(38, 50, 56, 1),
    Color secondaryContentColor = const Color.fromRGBO(0, 0, 0, 1),
    Color contentSecondaryColor = const Color.fromRGBO(84, 110, 122, 1),
    Color contentTextColor = const Color.fromRGBO(227, 242, 253, 1),
    Color highlightContentColor = const Color.fromRGBO(227, 242, 253, 1),
    Color highlightContentSecondaryColor =
        const Color.fromRGBO(144, 202, 249, 1),
    Color highlightContentTextColor = const Color.fromRGBO(38, 50, 56, 1),
    Color accentContentColor = darkPassyPurple,
    Color accentContentTextColor = const Color.fromRGBO(227, 242, 253, 1),
    ColorScheme datePickerColorScheme = const ColorScheme.dark(
      primary: Color.fromRGBO(144, 202, 249, 1),
      onPrimary: Color.fromRGBO(227, 242, 253, 1),
    ),
  }) {
    return ThemeData(
      extensions: [
        PassyTheme(
          passyPadding: passyPadding,
          contentColor: contentColor,
          secondaryContentColor: secondaryContentColor,
          contentSecondaryColor: contentSecondaryColor,
          contentTextColor: contentTextColor,
          highlightContentColor: highlightContentColor,
          highlightContentSecondaryColor: highlightContentSecondaryColor,
          highlightContentTextColor: highlightContentTextColor,
          accentContentColor: accentContentColor,
          accentContentTextColor: accentContentTextColor,
          datePickerColorScheme: datePickerColorScheme,
        )
      ],
      colorScheme: colorScheme.copyWith(
        primary: highlightContentColor,
        onPrimary: contentColor,
        secondary: highlightContentColor,
        onSecondary: highlightContentColor,
        onSurface: highlightContentColor,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: contentTextColor),
        displayMedium: TextStyle(color: contentTextColor),
        displaySmall: TextStyle(color: contentTextColor),
        headlineLarge: TextStyle(color: contentTextColor),
        headlineMedium: TextStyle(color: contentTextColor),
        headlineSmall: TextStyle(color: contentTextColor),
        titleLarge: TextStyle(color: contentTextColor),
        titleMedium: TextStyle(color: contentTextColor),
        titleSmall: TextStyle(color: contentTextColor),
        bodyLarge: TextStyle(color: contentTextColor),
        bodyMedium: TextStyle(color: contentTextColor),
        bodySmall: TextStyle(color: contentTextColor),
        labelLarge: TextStyle(color: contentTextColor),
        labelMedium: TextStyle(color: contentTextColor),
        labelSmall: TextStyle(color: contentTextColor),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: highlightContentColor,
        foregroundColor: highlightContentTextColor,
      ),
      appBarTheme: AppBarTheme(color: secondaryContentColor),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: highlightContentColor,
        actionTextColor: contentColor,
        contentTextStyle: TextStyle(color: highlightContentTextColor),
      ),
      scaffoldBackgroundColor: contentColor,
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(color: highlightContentSecondaryColor),
        hintStyle: TextStyle(color: contentTextColor.withAlpha(180)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: contentSecondaryColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: highlightContentColor)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(accentContentColor),
          foregroundColor:
              WidgetStatePropertyAll<Color>(accentContentTextColor),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: highlightContentColor,
        selectionColor: highlightContentSecondaryColor,
        selectionHandleColor: highlightContentColor,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: secondaryContentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  static final classicTheme = PassyTheme.buildThemeData();
  static final lightTheme = PassyTheme.buildThemeData(
    colorScheme: const ColorScheme.light(),
    contentColor: const Color.fromRGBO(227, 242, 253, 1),
    contentSecondaryColor: const Color.fromRGBO(144, 202, 249, 1),
    contentTextColor: const Color.fromRGBO(38, 50, 56, 1),
    secondaryContentColor: const Color.fromRGBO(255, 255, 255, 1),
    highlightContentColor: const Color.fromRGBO(38, 50, 56, 1),
    highlightContentSecondaryColor: const Color.fromRGBO(171, 102, 255, 1),
    highlightContentTextColor: const Color.fromRGBO(227, 242, 253, 1),
    accentContentColor: const Color.fromRGBO(213, 179, 255, 1),
    accentContentTextColor: const Color.fromRGBO(38, 50, 56, 1),
    datePickerColorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(84, 110, 122, 1),
      onPrimary: Color.fromRGBO(38, 50, 56, 1),
    ),
  );

  static const appBarButtonSplashRadius = 28.0;
  static const appBarButtonPadding = EdgeInsets.all(16.0);

  static const ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  );
  static const darkPassyPurple = Color.fromRGBO(74, 20, 140, 1);

  @override
  ThemeExtension<PassyTheme> copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }

  @override
  ThemeExtension<PassyTheme> lerp(
      covariant ThemeExtension<PassyTheme>? other, double t) {
    if (other == null) return this;
    if (other is! PassyTheme) return this;
    return PassyTheme(
      passyPadding: other.passyPadding,
      contentColor:
          Color.lerp(contentColor, other.contentColor, t) ?? other.contentColor,
      contentSecondaryColor:
          Color.lerp(contentSecondaryColor, other.contentSecondaryColor, t) ??
              other.contentSecondaryColor,
      contentTextColor:
          Color.lerp(contentTextColor, other.contentTextColor, t) ??
              other.contentTextColor,
      secondaryContentColor:
          Color.lerp(secondaryContentColor, other.secondaryContentColor, t) ??
              other.secondaryContentColor,
      highlightContentColor:
          Color.lerp(highlightContentColor, other.highlightContentColor, t) ??
              other.highlightContentColor,
      highlightContentSecondaryColor: Color.lerp(highlightContentSecondaryColor,
              other.highlightContentSecondaryColor, t) ??
          other.highlightContentSecondaryColor,
      highlightContentTextColor: Color.lerp(
              highlightContentTextColor, other.highlightContentTextColor, t) ??
          other.highlightContentTextColor,
      accentContentColor:
          Color.lerp(accentContentColor, other.accentContentColor, t) ??
              other.accentContentColor,
      accentContentTextColor:
          Color.lerp(accentContentTextColor, other.accentContentTextColor, t) ??
              other.accentContentTextColor,
      datePickerColorScheme: ColorScheme.lerp(
          datePickerColorScheme, other.datePickerColorScheme, t),
    );
  }
}

class PassyThemeNotification extends Notification {
  final ThemeData theme;

  PassyThemeNotification(this.theme);
}

class PassyThemeWidget extends StatefulWidget {
  final ThemeData? theme;
  final Widget child;

  const PassyThemeWidget({super.key, this.theme, required this.child});

  @override
  State<StatefulWidget> createState() => _PassyDynamicThemeWidget();
}

class _PassyDynamicThemeWidget extends State<PassyThemeWidget> {
  late ThemeData theme;

  void onChange(ThemeData value) {
    setState(() => theme = value);
  }

  @override
  void initState() {
    super.initState();
    theme = widget.theme ?? PassyTheme.classicTheme;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<PassyThemeNotification>(
        onNotification: (n) {
          onChange(n.theme);
          return false;
        },
        child: Theme(
          data: theme,
          child: widget.child,
        ));
  }
}
