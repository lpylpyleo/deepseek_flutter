import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_dart/openai_dart.dart';

const deepSeekBaseUrl = 'https://api.deepseek.com';

final apiKeyProvider = StateProvider<String?>((ref) {
  final box = Hive.box('settings');
  return box.get('apiKey');
});

final clientProvider = Provider((ref) {
  final apiKey = ref.watch(apiKeyProvider) ?? '';
  return OpenAIClient(
    baseUrl: deepSeekBaseUrl,
    apiKey: apiKey,
  );
});