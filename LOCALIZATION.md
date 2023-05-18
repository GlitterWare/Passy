# Localization

## Contents

1. [Original (English) localization file with comments](#original-english-localization-file-with-comments)
2. [How to localize](#how-to-localize)
3. [How to submit](#how-to-submit)
    - [Git/GitHub](#gitgithub)
    - [File upload](#file-upload)

## Original (English) localization file with comments

https://github.com/GlitterWare/Passy/blob/dev/lib/l10n/app_en.arb

## How to localize

All keys starting with '@' are comments that may help you understand what each message means, the comments themselves do not need translation as they are not used in the app UI.

The rest of the entries need translation.

If you wish to test your localization, we offer to build the app with your localization files for you to test on Windows/Linux/Android with unlimited test builds, but do make sure that your translation is complete before asking for a new build. If you are familiar with Git/GitHub, you may take advantage of our GitHub build workflow by submitting a pull request (see [How to submit](#how-to-submit)).

Please keep to same capitalization as original if possible, e.g. if the English localization says 'Hello world' then your localization should have the first letter in uppercase and the rest of the first letters in lowercase, if applicable.

Make sure to keep trailing spaces where it makes sense, some localizations make up multiple messages in the app and have to end with a trailing space for word separation.

## How to submit

### Git/GitHub

If you are familiar with Git and GitHub, you may fork the https://github.com/GlitterWare/Passy/tree/dev branch and create a copy of the aforementioned file ending with your language code (e.g. `app_es.arb` for Spanish) in the same directory that you can then begin translating.

When you're done, head to the end of the `main.dart` file in `Passy/lib` and insert support for your localization into the supported locales list like so:
```dart
const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('it'),
  Locale('>>> Your localization code goes here <<<'),
];
```

After this, you may commit and push your changes to your fork and submit a pull request at https://github.com/GlitterWare/Passy/pulls.

Our build workflow should then build our application with your localization included. It is highly advised that you only use workflow artifacts for testing and do not share workflow artifacts with your friends to use, as builds from the development branch may be very unstable and can, in worst case, cause damage to your account data.

### File upload

Otherwise, you may download/copy the file from the [aforementioned link](https://github.com/GlitterWare/Passy/blob/dev/lib/l10n/app_en.arb), translate it fully, upload it to https://gist.github.com (make sure to click the arrow to the right of the `Create secret gist`  button and select `Create public gist` so that a maintainer is able to open and see your file) and create a new issue at https://github.com/GlitterWare/Passy/issues/new/choose.

