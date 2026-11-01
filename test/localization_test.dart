import 'package:bible_study/data/bible_books.dart';
import 'package:bible_study/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bible Book localization and lookup', () {
    test('book name lookup in English and Amharic', () {
      expect(BibleBooks.getLocalizedName('John', 'am'), 'ዮሐንስ');
      expect(BibleBooks.getLocalizedName('John', 'en'), 'John');
      expect(BibleBooks.getLocalizedName('Genesis', 'am'), 'ዘፍጥረት');
      expect(BibleBooks.getLocalizedName('Genesis', 'en'), 'Genesis');

      // findByName with both languages
      final bookEn = BibleBooks.findByName('Genesis');
      expect(bookEn, isNotNull);
      expect(bookEn?.amharicName, 'ዘፍጥረት');

      final bookAm = BibleBooks.findByName('ዮሐንስ');
      expect(bookAm, isNotNull);
      expect(bookAm?.name, 'John');

      // Bilingual search
      final searchAm = BibleBooks.search('ዘፍ');
      expect(searchAm.any((b) => b.name == 'Genesis'), isTrue);

      final searchEn = BibleBooks.search('Rev');
      expect(searchEn.any((b) => b.name == 'Revelation'), isTrue);
    });
  });

  group('Localization widgets and language switch', () {
    testWidgets('switching locale updates displayed text', (tester) async {
      final localeNotifier = ValueNotifier<Locale>(const Locale('am'));

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('am'),
                Locale('en'),
              ],
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Scaffold(
                    body: Text(l10n.welcomeBack),
                  );
                },
              ),
            );
          },
        ),
      );

      // Default is Amharic
      expect(find.text('እንኳን ደህና መጡ'), findsOneWidget);
      expect(find.text('Welcome Back'), findsNothing);

      // Switch to English
      localeNotifier.value = const Locale('en');
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('እንኳን ደህና መጡ'), findsNothing);
    });
  });
}
