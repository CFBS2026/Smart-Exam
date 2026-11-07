
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:file_picker/file_picker.dart';

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
  bool filePickerReady = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    controller = WebViewController();

    await controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );

    await controller.setBackgroundColor(
      const Color(0xFF0A192F),
    );

    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
        },
        onWebResourceError: (error) {
          debugPrint(
            'WebView Error: ${error.description}',
          );
        },
      ),
    );

    // Android File Picker Support
    if (Platform.isAndroid) {
      final androidController =
          controller.platform as AndroidWebViewController;

      await androidController.setOnShowFileSelector(
        (params) async {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.any,
              allowMultiple: false,
              withData: false,
            );

            if (result == null || result.files.isEmpty) {
              return <String>[];
            }

            final filePath = result.files.single.path;

            if (filePath == null) {
              return <String>[];
            }

            debugPrint('Selected File: $filePath');

            return <String>[
              Uri.file(filePath).toString(),
            ];
          } catch (e) {
            debugPrint('File Picker Error: $e');
            return <String>[];
          }
        },
      );

      filePickerReady = true;
    }

    await controller.loadFlutterAsset('index.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),

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
