import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(BuildContext context,String item) {
  Clipboard.setData(ClipboardData(text: item));
  HapticFeedback.lightImpact(); // 添加轻微震动反馈
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('已复制到剪贴板'),
    ),
  );
}