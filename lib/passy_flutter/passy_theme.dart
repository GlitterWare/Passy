import 'package:flutter/material.dart';
import 'package:passy/passy_data/passy_app_theme.dart';

class PassyTheme extends ThemeExtension<PassyTheme> {
  final EdgeInsets passyPadding;
  final Color logoColor;
  final Color logoTextColor;
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
  final Color? switchThumbColor;
  final Color? switchTrackColor;

  const PassyTheme({
    this.passyPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.logoColor = Colors.purple,
    this.logoTextColor = Colors.white,
    this.contentColor = const Color.fromRGBO(38, 50, 56, 1),
    this.secondaryContentColor = const Color.fromRGBO(0, 0, 0, 1),
    this.contentSecondaryColor = const Color.fromRGBO(84, 110, 122, 1),
    this.contentTextColor = const Color.fromRGBO(227, 242, 253, 1),
    this.highlightContentColor = const Color.fromRGBO(227, 242, 253, 1),
    this.highlightContentSecondaryColor =
        const Color.fromRGBO(144, 202, 249, 1),
    this.highlightContentTextColor = const Color.fromRGBO(38, 50, 56, 1),
    this.accentContentColor = darkPassyPurple,
    this.accentContentTextColor = const Color.fromRGBO(227, 242, 253, 1),
    this.datePickerColorScheme = const ColorScheme.dark(
      primary: Color.fromRGBO(144, 202, 249, 1),
      onPrimary: Color.fromRGBO(227, 242, 253, 1),
    ),
    this.switchThumbColor = const Color.fromRGBO(105, 240, 174, 1),
    this.switchTrackColor = const Color.fromRGBO(90, 130, 157, 1),
  });

  static PassyTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<PassyTheme>();

  static PassyTheme of(BuildContext context) {
    final PassyTheme? result = maybeOf(context);
    assert(result != null, 'No PassyTheme found in the context');
    return result!;
  }

  ThemeData buildThemeData({
    ColorScheme colorScheme = const ColorScheme.dark(),
  }) {
    return ThemeData(
      extensions: [
        PassyTheme(
          passyPadding: passyPadding,
          logoColor: logoColor,
          logoTextColor: logoTextColor,
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
          switchThumbColor: switchThumbColor,
          switchTrackColor: switchTrackColor,
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
      appBarTheme: AppBarTheme(backgroundColor: secondaryContentColor),
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
          iconSize: WidgetStatePropertyAll<double>(24),
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
      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return switchThumbColor;
          }
          return null;
        }),
        trackColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return switchTrackColor;
          }
          return null;
        }),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: switchThumbColor,
        activeTrackColor: switchTrackColor,
      ),
    );
  }

  static final classicDark = const PassyTheme().buildThemeData();
  static final classicLight = const PassyTheme(
    contentColor: Color.fromRGBO(227, 242, 253, 1),
    contentSecondaryColor: Color.fromRGBO(144, 202, 249, 1),
    contentTextColor: Color.fromRGBO(38, 50, 56, 1),
    secondaryContentColor: Color.fromRGBO(255, 255, 255, 1),
    highlightContentColor: Color.fromRGBO(38, 50, 56, 1),
    highlightContentSecondaryColor: Color.fromRGBO(171, 102, 255, 1),
    highlightContentTextColor: Color.fromRGBO(227, 242, 253, 1),
    accentContentColor: Color.fromRGBO(213, 179, 255, 1),
    accentContentTextColor: Color.fromRGBO(38, 50, 56, 1),
    datePickerColorScheme: ColorScheme.light(
      primary: Color.fromRGBO(84, 110, 122, 1),
      onPrimary: Color.fromRGBO(38, 50, 56, 1),
    ),
    switchTrackColor: Color.fromRGBO(38, 50, 56, 1),
  ).buildThemeData(
    colorScheme: const ColorScheme.light(),
  );
  static final emeraldDark = PassyTheme(
    logoColor: const Color.fromRGBO(0, 165, 145, 1),
    contentSecondaryColor: const Color.fromRGBO(0, 107, 94, 1),
    contentTextColor: const Color.fromRGBO(255, 255, 255, 1),
    highlightContentColor: const Color.fromRGBO(255, 255, 255, 1),
    highlightContentSecondaryColor: const Color.fromRGBO(0, 235, 205, 1),
    highlightContentTextColor: const Color.fromRGBO(0, 0, 0, 1),
    accentContentColor: const Color.fromRGBO(0, 105, 95, 1),
    accentContentTextColor: const Color.fromRGBO(255, 255, 255, 1),
    datePickerColorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(84, 110, 122, 1),
      onPrimary: Color.fromRGBO(38, 50, 56, 1),
    ),
    switchThumbColor: Colors.deepPurpleAccent,
    switchTrackColor: Colors.deepPurple[50]!,
  ).buildThemeData();
  static final emeraldLight = PassyTheme(
    logoColor: const Color.fromRGBO(0, 165, 145, 1),
    contentColor: const Color.fromRGBO(227, 255, 252, 1),
    contentSecondaryColor: const Color.fromRGBO(0, 107, 94, 1),
    contentTextColor: const Color.fromRGBO(0, 0, 0, 1),
    secondaryContentColor: const Color.fromRGBO(255, 255, 255, 1),
    highlightContentColor: const Color.fromRGBO(0, 0, 0, 1),
    highlightContentSecondaryColor: const Color.fromRGBO(0, 128, 114, 1),
    highlightContentTextColor: const Color.fromRGBO(227, 255, 252, 1),
    accentContentColor: const Color.fromRGBO(0, 235, 205, 1),
    accentContentTextColor: const Color.fromRGBO(0, 0, 0, 1),
    datePickerColorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(84, 110, 122, 1),
      onPrimary: Color.fromRGBO(38, 50, 56, 1),
    ),
    switchThumbColor: Colors.deepPurpleAccent,
    switchTrackColor: Colors.grey[800],
  ).buildThemeData(
    colorScheme: const ColorScheme.light(),
  );
  static final goldDark = PassyTheme(
    logoColor: const Color.fromRGBO(0, 165, 145, 1),
    contentSecondaryColor: const Color.fromRGBO(0, 107, 94, 1),
    contentTextColor: const Color.fromRGBO(255, 255, 255, 1),
    highlightContentColor: const Color.fromRGBO(255, 255, 255, 1),
    highlightContentSecondaryColor: const Color.fromRGBO(0, 235, 205, 1),
    highlightContentTextColor: const Color.fromRGBO(0, 0, 0, 1),
    accentContentColor: const Color.fromRGBO(0, 138, 120, 1),
    accentContentTextColor: const Color.fromRGBO(255, 255, 255, 1),
    datePickerColorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(84, 110, 122, 1),
      onPrimary: Color.fromRGBO(38, 50, 56, 1),
    ),
    switchThumbColor: Colors.deepPurpleAccent,
    switchTrackColor: Colors.deepPurple[50]!,
  ).buildThemeData();
  static final goldLight = PassyTheme(
    logoColor: const Color.fromRGBO(0, 165, 145, 1),
    contentColor: const Color.fromRGBO(227, 255, 252, 1),
    contentSecondaryColor: const Color.fromRGBO(0, 107, 94, 1),
    contentTextColor: const Color.fromRGBO(0, 0, 0, 1),
    secondaryContentColor: const Color.fromRGBO(255, 255, 255, 1),
    highlightContentColor: const Color.fromRGBO(0, 0, 0, 1),
    highlightContentSecondaryColor: const Color.fromRGBO(0, 128, 114, 1),
    highlightContentTextColor: const Color.fromRGBO(227, 255, 252, 1),
    accentContentColor: const Color.fromRGBO(0, 235, 205, 1),
    accentContentTextColor: const Color.fromRGBO(0, 0, 0, 1),
    datePickerColorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(84, 110, 122, 1),
      onPrimary: Color.fromRGBO(38, 50, 56, 1),
    ),
    switchThumbColor: Colors.deepPurpleAccent,
    switchTrackColor: Colors.grey[800],
  ).buildThemeData(
    colorScheme: const ColorScheme.light(),
  );

  static final themes = {
    PassyAppTheme.classicDark: classicDark,
    PassyAppTheme.classicDarkOLED: (classicDark
                .extension<PassyTheme>()!
                .copyWith(contentColor: const Color.fromRGBO(0, 0, 0, 1))
            as PassyTheme)
        .buildThemeData(),
    PassyAppTheme.classicLight: classicLight,
    PassyAppTheme.emeraldDark: emeraldDark,
    PassyAppTheme.emeraldDarkOLED: (emeraldDark
                .extension<PassyTheme>()!
                .copyWith(contentColor: const Color.fromRGBO(0, 0, 0, 1))
            as PassyTheme)
        .buildThemeData(),
    PassyAppTheme.emeraldLight: emeraldLight,
  };

  static const appBarButtonSplashRadius = 28.0;
  static const appBarButtonPadding = EdgeInsets.all(16.0);

  static const ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  );
  static const darkPassyPurple = Color.fromRGBO(74, 20, 140, 1);

  @override
  ThemeExtension<PassyTheme> copyWith({
    EdgeInsets? passyPadding,
    Color? logoColor,
    Color? logoTextColor,
    Color? contentColor,
    Color? secondaryContentColor,
    Color? contentSecondaryColor,
    Color? contentTextColor,
    Color? highlightContentColor,
    Color? highlightContentSecondaryColor,
    Color? highlightContentTextColor,
    Color? accentContentColor,
    Color? accentContentTextColor,
    ColorScheme? datePickerColorScheme,
    Color? switchThumbColor,
    Color? switchTrackColor,
  }) {
    return PassyTheme(
      passyPadding: passyPadding ?? this.passyPadding,
      logoColor: logoColor ?? this.logoColor,
      logoTextColor: logoTextColor ?? this.logoTextColor,
      contentColor: contentColor ?? this.contentColor,
      secondaryContentColor:
          secondaryContentColor ?? this.secondaryContentColor,
      contentSecondaryColor:
          contentSecondaryColor ?? this.contentSecondaryColor,
      contentTextColor: contentTextColor ?? this.contentTextColor,
      highlightContentColor:
          highlightContentColor ?? this.highlightContentColor,
      highlightContentSecondaryColor:
          highlightContentSecondaryColor ?? this.highlightContentSecondaryColor,
      highlightContentTextColor:
          highlightContentTextColor ?? this.highlightContentTextColor,
      accentContentColor: accentContentColor ?? this.accentContentColor,
      accentContentTextColor:
          accentContentTextColor ?? this.accentContentTextColor,
      datePickerColorScheme:
          datePickerColorScheme ?? this.datePickerColorScheme,
      switchThumbColor: switchThumbColor ?? this.switchThumbColor,
      switchTrackColor: switchTrackColor ?? this.switchTrackColor,
    );
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
    theme = widget.theme ?? PassyTheme.classicDark;
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
