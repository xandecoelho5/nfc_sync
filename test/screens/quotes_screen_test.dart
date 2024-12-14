import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:nfc_sync/dao/quote_dao.dart';
import 'package:nfc_sync/models/quote.dart';
import 'package:nfc_sync/screens/quotes_screen.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([QuoteDao])
import 'quotes_screen_test.mocks.dart';

void main() {
  late MockQuoteDao mockQuoteDao;

  setUp(() {
    mockQuoteDao = MockQuoteDao();
  });

  Widget createWidgetUnderTest() {
    return Provider<QuoteDao>(
      create: (_) => mockQuoteDao,
      child: const MaterialApp(
        home: QuotesScreen(),
      ),
    );
  }

  group('QuotesScreen', () {
    testWidgets('displays loading indicator while waiting for data', (WidgetTester tester) async {
      final completer = Completer<List<Quote>>();

      when(mockQuoteDao.findAllQuotes()).thenAnswer((_) => Stream.fromFuture(completer.future));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('displays error message when there is an error', (WidgetTester tester) async {
      when(mockQuoteDao.findAllQuotes()).thenAnswer((_) => Stream.error('Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Error: Error'), findsOneWidget);
    });

    testWidgets('displays no quotes found message when there are no quotes', (WidgetTester tester) async {
      when(mockQuoteDao.findAllQuotes()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('No quotes found'), findsOneWidget);
    });

    testWidgets('displays list of quotes when data is available', (WidgetTester tester) async {
      final quotes = [
        const Quote(id: 1, content: 'Quote 1', author: 'Author 1'),
        const Quote(id: 2, content: 'Quote 2', author: 'Author 2'),
      ];
      when(mockQuoteDao.findAllQuotes()).thenAnswer((_) => Stream.value(quotes));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Quote 1'), findsOneWidget);
      expect(find.text('Quote 2'), findsOneWidget);
    });
  });

  group('QuotesList', () {
    testWidgets('displays confirmation dialog when dismissing a quote', (WidgetTester tester) async {
      const quotes = [
        Quote(id: 1, content: 'Quote 1', author: 'Author 1'),
      ];
      await tester.pumpWidget(const MaterialApp(
        home: QuotesList(quotes),
      ));

      await tester.drag(find.text('Quote 1'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Delete Quote'), findsOneWidget);
    });

    testWidgets('deletes quote when confirmed', (WidgetTester tester) async {
      const quote = Quote(id: 1, content: 'Quote 1', author: 'Author 1');
      const quotes = [ quote];
      when(mockQuoteDao.deleteQuote(quote)).thenAnswer((_) async => {});

      await tester.pumpWidget(Provider<QuoteDao>(
        create: (_) => mockQuoteDao,
        child: const MaterialApp(
          home: QuotesList(quotes),
        ),
      ));

      await tester.drag(find.text('Quote 1'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(mockQuoteDao.deleteQuote(quotes[0])).called(1);
    });
  });
}