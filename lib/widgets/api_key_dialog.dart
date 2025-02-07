import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/client.dart';

class ApiKeyDialog extends HookConsumerWidget {
  const ApiKeyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final mounted = context.mounted;

    return AlertDialog(
      title: const Text('设置 API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('请输入您的 DeepSeek API Key'),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '在此输入 API Key',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (controller.text.isEmpty) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key 不能为空')),
              );
              return;
            }
            
            final box = Hive.box('settings');
            await box.put('apiKey', controller.text);
            if (!mounted) return;
            ref.read(apiKeyProvider.notifier).state = controller.text;
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
} 