import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_sync/bloc/quote_bloc.dart';
import 'package:nfc_sync/bloc/quote_event.dart';
import 'package:nfc_sync/models/quote.dart';

import '../bloc/quote_state.dart';
import '../services/nfc_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivational Quotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.of(context).pushNamed('/quotes'),
          ),
          IconButton(
            icon: const Icon(Icons.nfc),
            onPressed: () => context.read<NFCService>().writeQuoteTag(),
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<QuoteBloc, QuoteState>(
          listener: (context, state) {
            if (state.status == QuoteStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error ?? 'An error occurred')),
              );
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case QuoteStatus.initial:
                return ElevatedButton(
                  onPressed: () =>
                      context.read<QuoteBloc>().add(StartNFCScan()),
                  child: const Text('Start NFC Scan'),
                );
              case QuoteStatus.scanning:
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Hold phone near NFC tag'),
                  ],
                );
              case QuoteStatus.error:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<QuoteBloc>().add(StartNFCScan()),
                      child: const Text('Try Again'),
                    ),
                  ],
                );
              case QuoteStatus.loaded:
                return QuoteText(state.quote!);
            }
          },
        ),
      ),
    );
  }
}

class QuoteText extends StatelessWidget {
  const QuoteText(this.quote, {super.key});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '"${quote.content}"',
            style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '- ${quote.author}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.read<QuoteBloc>().add(StartNFCScan()),
            child: const Text('Scan Another Tag'),
          ),
        ],
      ),
    );
  }
}
