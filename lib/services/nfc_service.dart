import 'dart:async';

import 'package:nfc_manager/nfc_manager.dart';

const kQuoteTag = 'MOTIVATIONAL_QUOTE_TAG';

class NFCService {
  Future<bool> isNFCAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  Future<void> writeQuoteTag() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        NfcManager.instance.stopSession(errorMessage: 'Tag not writable');
        return;
      }

      final message = NdefMessage([NdefRecord.createText(kQuoteTag)]);
      try {
        await ndef.write(message);
        NfcManager.instance
            .stopSession(alertMessage: 'Tag written successfully');
      } catch (e) {
        NfcManager.instance.stopSession(errorMessage: 'Write failed: $e');
        return;
      }
    });
  }

  Future<bool> listenForQuoteTag() {
    final completer = Completer<bool>();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef != null) {
          final message = await ndef.read();

          bool isQuoteTag = message.records.any((record) {
            try {
              final payload = String.fromCharCodes(record.payload.skip(3));
              return payload == kQuoteTag;
            } catch (e) {
              return false;
            }
          });

          NfcManager.instance.stopSession();
          completer.complete(isQuoteTag);
        } else {
          NfcManager.instance.stopSession();
          completer.complete(false);
        }
      },
      onError: (error) async {
        NfcManager.instance.stopSession();
        completer.completeError(error);
      },
    );

    return completer.future;
  }
}
