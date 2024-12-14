import 'package:nfc_sync/models/quote.dart';

abstract class QuoteEvent {}

class StartNFCScan extends QuoteEvent {}

class AddQuote extends QuoteEvent {
  final Quote quote;
  AddQuote(this.quote);
}
