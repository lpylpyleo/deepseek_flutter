import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openai_dart/openai_dart.dart';

import '../providers/client.dart';
import '../singletons/widget.dart';
import '../utils.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/highlight_button.dart';
import '../widgets/message_widget.dart';

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useState('DeepSeek Demo');
    final messages = useState(<ChatCompletionMessage>[]);
    final textController = useTextEditingController();
    final responding = useState(false);
    final firstAnswerFinished = useState(false);
    final apiKey = ref.watch(apiKeyProvider);

    final sendMessage = useCallback(
      () async {
        if (textController.text.isEmpty) return;

        final userMessage = ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(textController.text),
        );

        messages.value = [...messages.value, userMessage];
        textController.clear();
        responding.value = true;

        try {
          final stream = ref.watch(clientProvider).createChatCompletionStream(
                request: CreateChatCompletionRequest(
                  model: ChatCompletionModel.modelId('deepseek-chat'),
                  messages: [...messages.value],
                ),
              );

          messages.value = [
            ...messages.value,
            ChatCompletionAssistantMessage(content: '')
          ];

          await for (final res in stream) {
            final delta = res.choices.first.delta.content;
            final msg = ((messages.value.last as ChatCompletionAssistantMessage)
                        .content ??
                    '') +
                (delta ?? '');
            messages.value = messages.value
                .sublist(0, messages.value.length - 1)
              ..add(ChatCompletionAssistantMessage(content: msg));
          }
          firstAnswerFinished.value = true;
        } catch (e) {
          showSnackBar(context, '发生错误: ${e.toString()}');
        } finally {
          responding.value = false;
        }
      },
      [messages.value],
    );

    useEffect(() {
      () async {
        if (!firstAnswerFinished.value) return;
        final msg = ChatCompletionMessage.system(
            content: '请根据用户的问题生成一个没有标点的简短标题，不超过8个字。');

        final stream = ref.watch(clientProvider).createChatCompletionStream(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(LlmModel.v3.modelId),
                messages: [msg, ...messages.value],
                maxTokens: 20,
              ),
            );

        title.value = '';
        await for (final res in stream) {
          final delta = res.choices.first.delta.content;
          if (delta != null) {
            title.value += delta.replaceAll('"', '').replaceAll('\n', '');
          }
        }
      }();
      return null;
    }, [firstAnswerFinished.value]);

    useEffect(() {
      if (apiKey == null) {
        Future.microtask(() => showDialog(
              context: navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (_) => const ApiKeyDialog(),
            ));
      }
      return null;
    }, [apiKey]);

    if (apiKey == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const ApiKeyDialog(),
            ),
            child: const Text('设置 API Key'),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title.value),
        ),
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ListView.builder(
                      reverse: true,
                      itemCount: messages.value.length,
                      itemBuilder: (context, index) {
                        final ChatCompletionMessage message =
                            messages.value.reversed.toList()[index];
                        return MessageWidget(
                            message: message,
                            isLoading: index == 0 && responding.value);
                      },
                    ),
                  ],
                ),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  messages.value = [];
                  title.value = 'DeepSeek Demo';
                  responding.value = false;
                  firstAnswerFinished.value = false;
                },
                elevation: 1,
                highlightElevation: 2,
                icon: const Icon(Icons.delete_outline),
                label: const Text('清空对话'),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (_) {
                              if (!responding.value) {
                                sendMessage();
                              }
                            },
                            controller: textController,
                            decoration: InputDecoration(
                              hintText: '输入你的消息',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              responding.value ? null : () => sendMessage(),
                          child: const Text('发送'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    HighlightButton(
                      icon: Icons.model_training,
                      label: 'DeepSeek R1',
                      isSelected: ref.watch(llmModelProvider) == LlmModel.r1,
                      onPressed: () {
                        ref.read(llmModelProvider.notifier).state =
                            ref.read(llmModelProvider) == LlmModel.r1
                                ? LlmModel.v3
                                : LlmModel.r1;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
