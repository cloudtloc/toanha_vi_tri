import 'package:flutter/material.dart';

/// Hien thi thong bao noi phia tren, tranh che cac nut ben duoi.
void showThongBao(
  BuildContext context,
  String message, {
  bool isLoi = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
      backgroundColor: isLoi ? Colors.red.shade700 : null,
    ),
  );
}
