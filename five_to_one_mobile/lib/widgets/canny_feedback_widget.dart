import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'dart:html' as html;
import '../config/canny_config.dart';

/// Embedded Canny feedback widget for web
/// Shows Canny feedback board inside the app
class CannyFeedbackWidget extends StatefulWidget {
  const CannyFeedbackWidget({super.key});

  @override
  State<CannyFeedbackWidget> createState() => _CannyFeedbackWidgetState();
}

class _CannyFeedbackWidgetState extends State<CannyFeedbackWidget> {
  final String viewType = 'canny-iframe-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerIframe();
    }
  }

  void _registerIframe() {
    // Register the iframe view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = CannyConfig.feedbackUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'fullscreen';

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // For mobile, show a message or use webview_flutter
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Feedback widget is available on web'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    if (!CannyConfig.isConfigured) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Canny feedback is not configured'),
            const SizedBox(height: 8),
            const Text(
              'Please set CANNY_SUBDOMAIN environment variable',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    return HtmlElementView(viewType: viewType);
  }
}

/// Dialog to show Canny feedback widget
class CannyFeedbackDialog extends StatelessWidget {
  const CannyFeedbackDialog({super.key});

  /// Show the feedback dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CannyFeedbackDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.feedback_outlined),
                  const SizedBox(width: 12),
                  const Text(
                    'Send Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Canny widget
            const Expanded(
              child: CannyFeedbackWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen Canny feedback page
class CannyFeedbackScreen extends StatelessWidget {
  const CannyFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in new tab',
            onPressed: () {
              // Could open in external browser if needed
            },
          ),
        ],
      ),
      body: const CannyFeedbackWidget(),
    );
  }
}
