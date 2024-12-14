import 'package:floor/floor.dart';
import 'package:nfc_sync/models/quote.dart';

@dao
abstract class QuoteDao {
  @insert
  Future<void> insertQuote(Quote quote);

  @delete
  Future<void> deleteQuote(Quote quote);

  @Query('SELECT * FROM Quote')
  Stream<List<Quote>> findAllQuotes();
}