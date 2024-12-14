import 'package:flutter/material.dart';

import '../models/quote.dart';

class AddQuoteInput extends StatefulWidget {
  final Function(Quote) onAddQuote;

  const AddQuoteInput({required this.onAddQuote, super.key});

  @override
  State<AddQuoteInput> createState() => _AddQuoteInputState();
}

class _AddQuoteInputState extends State<AddQuoteInput> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  void _submit() {
    if (_contentController.text.isNotEmpty &&
        _authorController.text.isNotEmpty) {
      widget.onAddQuote(Quote(
        content: _contentController.text,
        author: _authorController.text,
      ));
      _contentController.clear();
      _authorController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Quote')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Quote'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add Quote'),
            ),
          ],
        ),
      ),
    );
  }
}
