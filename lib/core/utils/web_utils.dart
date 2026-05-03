import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebUtils {
  static void updateFavicon(String url) {
    if (!kIsWeb) return;
    try {
      final head = html.document.head;
      if (head == null) return;

      // Find existing favicon links
      final links = head.querySelectorAll('link[rel*="icon"]');
      
      if (links.isEmpty) {
        // Create new link if not found
        final link = html.LinkElement()
          ..rel = 'icon'
          ..type = 'image/png'
          ..href = url;
        head.append(link);
      } else {
        // Update existing links
        for (final link in links) {
          (link as html.LinkElement).href = url;
        }
      }
    } catch (e) {
      debugPrint('Error updating favicon: $e');
    }
  }

  static void updateTitle(String title) {
    if (!kIsWeb) return;
    try {
      html.document.title = title;
    } catch (e) {
      debugPrint('Error updating title: $e');
    }
  }
}
