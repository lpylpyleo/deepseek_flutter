import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:openai_dart/openai_dart.dart';
import '../utils.dart';

class MessageWidget extends StatelessWidget {
  final ChatCompletionMessage message;
  final bool isLoading;

  const MessageWidget({super.key, required this.message, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final content = message.map(
      system: (m) => m.content,
      user: (m) => m.content.value.toString(),
      assistant: (m) => m.content ?? '...',
      tool: (m) => m.content,
      function: (m) => m.content ?? '...',
    );
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.copy, size: 20),
                      title: const Text('复制', style: TextStyle(fontSize: 14)),
                      onTap: () {
                        copyToClipboard(context, content);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.role.name.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Responding...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  )
                : GptMarkdown(
                    content,
                    style: const TextStyle(fontSize: 16),
                    textScaler: TextScaler.linear(1),
                  ),
          ],
        ),
      ),
    );
  }
} 