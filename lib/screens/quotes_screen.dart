import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_sync/dao/quote_dao.dart';
import 'package:nfc_sync/models/quote.dart';

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Quotes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-quote');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Quote>>(
        stream: context.read<QuoteDao>().findAllQuotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final quotes = snapshot.data as List<Quote>;
          if (quotes.isEmpty) {
            return const Center(child: Text('No quotes found'));
          }
          quotes.sort((a, b) => b.id!.compareTo(a.id!));
          return QuotesList(quotes);
        },
      ),
    );
  }
}

class QuotesList extends StatelessWidget {
  const QuotesList(this.quotes, {super.key});

  final List<Quote> quotes;

  Future<bool?> _onConfirmDismiss(BuildContext context, Quote quote) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Quote'),
          content: Text(
            'Are you sure you want to delete "${quote.content}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final quote = quotes[index];
          return Dismissible(
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            key: ValueKey(quote.id),
            onDismissed: (_) => context.read<QuoteDao>().deleteQuote(quote),
            confirmDismiss: (_) => _onConfirmDismiss(context, quote),
            child: ListTile(
              title: Text(quote.content!),
              subtitle: Text(quote.author!),
            ),
          );
        },
      ),
    );
  }
}
