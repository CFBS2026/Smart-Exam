
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartExamApp());
}

class SmartExamApp extends StatelessWidget {
  const SmartExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CFBS Smart Exam',
      home: SmartExamHome(),
    );
  }
}

class SmartExamHome extends StatefulWidget {
  const SmartExamHome({super.key});

  @override
  State<SmartExamHome> createState() => _SmartExamHomeState();
}

class _SmartExamHomeState extends State<SmartExamHome> {
  late final WebViewController controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A192F))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() => loading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadFlutterAsset('index.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (loading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
