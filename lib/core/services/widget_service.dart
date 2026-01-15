import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote_entity.dart';

class WidgetService {
  Future<void> updateWidget(QuoteEntity quote) async {
    try {
      await HomeWidget.saveWidgetData<String>('quote_content', quote.content);
      await HomeWidget.saveWidgetData<String>('quote_author', quote.author);
      await HomeWidget.updateWidget(
        name: 'QuoteWidgetProvider',
        androidName: 'QuoteWidgetProvider',
        iOSName: 'QuoteWidget',
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
}
