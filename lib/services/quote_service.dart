import 'package:dio/dio.dart';
import 'package:nfc_sync/models/quote.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'quote_service.g.dart';

@RestApi(baseUrl: "https://api.quotable.io")
abstract class QuoteService {
  factory QuoteService(Dio dio) = _QuoteService;

  @GET("/random")
  Future<Quote> getRandomQuote();
}
