import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String successUrl;
  final String failUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    this.successUrl = 'https://yoursite.com/success',
    this.failUrl = 'https://yoursite.com/fail',
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkUrl(url);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _checkUrl(url);
          },
          onNavigationRequest: (request) {
            if (_checkUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _checkUrl(String url) {
    if (url.startsWith(widget.successUrl)) {
      Navigator.of(context).pop(true);
      return true;
    } else if (url.startsWith(widget.failUrl)) {
      Navigator.of(context).pop(false);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Վճարում'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
