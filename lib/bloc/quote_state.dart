import 'package:equatable/equatable.dart';
import 'package:nfc_sync/models/quote.dart';

enum QuoteStatus { initial, scanning, loaded, error }

class QuoteState extends Equatable {
  final QuoteStatus status;
  final Quote? quote;
  final String? error;

  const QuoteState({
    this.status = QuoteStatus.initial,
    this.quote,
    this.error,
  });

  QuoteState copyWith({
    QuoteStatus? status,
    Quote? quote,
    String? error,
  }) {
    return QuoteState(
      status: status ?? this.status,
      quote: quote ?? this.quote,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, quote, error];
}