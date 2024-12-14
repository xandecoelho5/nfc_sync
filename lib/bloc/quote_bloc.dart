import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_sync/bloc/quote_event.dart';
import 'package:nfc_sync/bloc/quote_state.dart';
import 'package:nfc_sync/dao/quote_dao.dart';
import 'package:nfc_sync/services/nfc_service.dart';
import 'package:nfc_sync/services/quote_service.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final QuoteService _quoteService;
  final NFCService _nfcService;
  final QuoteDao _quoteDao;

  QuoteBloc(this._quoteService, this._nfcService, this._quoteDao)
      : super(const QuoteState()) {
    on<StartNFCScan>(_onStartNFCScan);
    on<AddQuote>(_onAddQuote);
  }

  Future<void> _onStartNFCScan(
    StartNFCScan event,
    Emitter<QuoteState> emit,
  ) async {
    try {
      emit(state.copyWith(status: QuoteStatus.scanning));

      final isQuoteTag = await _nfcService.listenForQuoteTag();
      if (isQuoteTag) {
        final quote = await _quoteService.getRandomQuote();
        add(AddQuote(quote));
      } else {
        emit(state.copyWith(
          status: QuoteStatus.error,
          error: 'This is not a quote tag',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: QuoteStatus.error, error: e.toString()));
    }
  }

  Future<void> _onAddQuote(AddQuote event, Emitter<QuoteState> emit) async {
    await _quoteDao.insertQuote(event.quote);
    emit(state.copyWith(status: QuoteStatus.loaded, quote: event.quote));
  }
}
