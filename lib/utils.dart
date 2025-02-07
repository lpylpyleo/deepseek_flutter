import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

void copyToClipboard(BuildContext context, String item) {
  Clipboard.setData(ClipboardData(text: item));
  HapticFeedback.lightImpact(); // 添加轻微震动反馈
  showSnackBar(context, '已复制到剪贴板');
}
