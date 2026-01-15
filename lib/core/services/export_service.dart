import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> shareQuoteImage(Widget widget, String text) async {
    final Uint8List? imageBytes = await screenshotController.captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 100),
    );

    if (imageBytes != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/quote_share.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(imagePath.path)], text: text);
    }
  }
}
