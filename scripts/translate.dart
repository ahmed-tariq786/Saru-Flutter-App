import 'dart:convert';
import 'dart:io';

import 'package:translator/translator.dart';

void main() async {
  final translator = GoogleTranslator();

  // Read English ARB file
  final enFile = File('lib/l10n/intl_en.arb');
  final enContent = await enFile.readAsString();
  final enData = jsonDecode(enContent) as Map<String, dynamic>;

  // Read Arabic ARB file
  final arFile = File('lib/l10n/intl_ar.arb');
  final arContent = await arFile.readAsString();
  final arData = jsonDecode(arContent) as Map<String, dynamic>;

  // Translate missing keys
  for (final entry in enData.entries) {
    final key = entry.key;
    final value = entry.value;

    // Skip metadata keys
    if (key.startsWith('@@') || key.startsWith('@')) continue;

    // If key doesn't exist in Arabic or is same as English, translate it
    if (!arData.containsKey(key) || arData[key] == value) {
      try {
        print('Translating: $value');
        final translation = await translator.translate(value, from: 'en', to: 'ar');
        arData[key] = translation.text;
        print('✓ $key: ${translation.text}');

        // Add a small delay to respect API limits
        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        print('✗ Failed to translate $key: $e');
        arData[key] = value; // Keep original if translation fails
      }
    }
  }

  // Write updated Arabic ARB file
  final encoder = JsonEncoder.withIndent('  ');
  await arFile.writeAsString(encoder.convert(arData));

  print('\n🎉 Translation complete! Updated ${arFile.path}');
}
