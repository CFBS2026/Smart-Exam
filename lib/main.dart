import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    controller = WebViewController();

    // JavaScript Support
    await controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );

    await controller.setBackgroundColor(
      const Color(0xFF0A192F),
    );

    // Question Export Channel
    await controller.addJavaScriptChannel(
      'ExportChannel',
      onMessageReceived: (JavaScriptMessage message) async {
        try {
          final dynamic decoded = jsonDecode(message.message);

          if (decoded is! Map) {
            throw Exception('Invalid export data');
          }

          final String filename =
              decoded['filename']?.toString() ??
              'CFBS_Question_File.json';

          final String content =
              decoded['content']?.toString() ?? '';

          if (content.isEmpty) {
            throw Exception('Question data is empty');
          }

          final String? savedPath =
              await FilePicker.platform.saveFile(
            dialogTitle: 'Save Question File',
            fileName: filename,
            type: FileType.custom,
            allowedExtensions: ['json'],
            bytes: Uint8List.fromList(
              utf8.encode(content),
            ),
          );

          if (!mounted) return;

          if (savedPath != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Question File သိမ်းဆည်းပြီးပါပြီ။',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          debugPrint('Question Export Error: $e');

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    // Page Navigation and Loading
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

    // Android File Import Support
    if (Platform.isAndroid) {
      final androidController =
          controller.platform as AndroidWebViewController;

      await androidController.setOnShowFileSelector(
        (FileSelectorParams params) async {
          try {
            final result =
                await FilePicker.platform.pickFiles(
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
            debugPrint('File Import Error: $e');
            return <String>[];
          }
        },
      );
    }

    // Load HTML Application
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