import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_sync/bloc/quote_bloc.dart';
import 'package:nfc_sync/bloc/quote_event.dart';
import 'package:nfc_sync/dao/quote_dao.dart';
import 'package:nfc_sync/database.dart';
import 'package:nfc_sync/screens/custom_quote_input.dart';
import 'package:nfc_sync/screens/home_screen.dart';
import 'package:nfc_sync/screens/quotes_screen.dart';
import 'package:nfc_sync/services/nfc_service.dart';
import 'package:nfc_sync/services/quote_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final quoteDao = database.quoteDao;

  runApp(MyApp(quoteDao));
}

class MyApp extends StatelessWidget {
  const MyApp(this.quoteDao, {super.key});

  final QuoteDao quoteDao;

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<QuoteDao>(create: (_) => quoteDao),
        RepositoryProvider<QuoteService>(create: (_) => QuoteService(dio)),
        RepositoryProvider<NFCService>(create: (_) => NFCService()),
        BlocProvider(
          create: (context) => QuoteBloc(
            context.read<QuoteService>(),
            context.read<NFCService>(),
            quoteDao,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'NFC Motivational Quotes',
        theme: ThemeData(
          // primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
        routes: {
          '/': (context) => const HomeScreen(),
          '/quotes': (context) => const QuotesScreen(),
          '/add-quote': (context) => AddQuoteInput(
                onAddQuote: (quote) {
                  context.read<QuoteBloc>().add(AddQuote(quote));
                  Navigator.of(context).pop();
                },
              ),
        },
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
