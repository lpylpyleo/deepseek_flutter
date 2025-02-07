import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_dart/openai_dart.dart';

const deepSeekBaseUrl = 'https://api.deepseek.com';

enum LlmModel {
  v3(modelId: 'deepseek-chat'),
  r1(modelId: 'deepseek-reasoner');

  final String modelId;

  const LlmModel({required this.modelId});
}

final llmModelProvider = StateProvider<LlmModel>((ref) {
  return LlmModel.v3;
});

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
