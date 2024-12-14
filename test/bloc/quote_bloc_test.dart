import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nfc_sync/bloc/quote_bloc.dart';
import 'package:nfc_sync/bloc/quote_event.dart';
import 'package:nfc_sync/bloc/quote_state.dart';
import 'package:nfc_sync/dao/quote_dao.dart';
import 'package:nfc_sync/models/quote.dart';
import 'package:nfc_sync/services/nfc_service.dart';
import 'package:nfc_sync/services/quote_service.dart';

@GenerateMocks([QuoteService, NFCService, QuoteDao])
import 'quote_bloc_test.mocks.dart';

void main() {
  group('QuoteBloc', () {
    late QuoteBloc quoteBloc;
    late MockQuoteService mockQuoteService;
    late MockNFCService mockNfcService;
    late MockQuoteDao mockQuoteDao;

    setUp(() {
      mockQuoteService = MockQuoteService();
      mockNfcService = MockNFCService();
      mockQuoteDao = MockQuoteDao();
      quoteBloc = QuoteBloc(
        mockQuoteService,
        mockNfcService,
        mockQuoteDao,
      );
    });

    test('initial state is correct', () {
      expect(quoteBloc.state.status, QuoteStatus.initial);
    });

    blocTest<QuoteBloc, QuoteState>(
      'emits [scanning, loaded] when NFC scan is successful',
      build: () {
        when(mockNfcService.listenForQuoteTag()).thenAnswer((_) async => true);
        when(mockQuoteService.getRandomQuote()).thenAnswer((_) async =>
            const Quote(content: 'Test quote', author: 'Test Author'));
        return quoteBloc;
      },
      act: (bloc) => bloc.add(StartNFCScan()),
      expect: () => [
        const QuoteState(status: QuoteStatus.scanning),
        const QuoteState(
          status: QuoteStatus.loaded,
          quote: Quote(content: 'Test quote', author: 'Test Author'),
        ),
      ],
    );
  });
}
