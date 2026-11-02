import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class QuestionExamScreen extends StatefulWidget {
  const QuestionExamScreen({Key? key}) : super(key: key);

  @override
  _QuestionExamScreenState createState() => _QuestionExamScreenState();
}

class _QuestionExamScreenState extends State<QuestionExamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Question Form Controllers
  final _qIdController = TextEditingController();
  final _subjIdController = TextEditingController();
  final _gradeController = TextEditingController();
  final _chapterController = TextEditingController();
  final _qTextController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _optCController = TextEditingController();
  final _optDController = TextEditingController();
  String _correctOpt = 'A';
  int _marks = 1;

  // Exam Form Controllers
  final _examIdController = TextEditingController();
  final _examTitleController = TextEditingController();
  final _examSubjController = TextEditingController();
  final _examGradeController = TextEditingController();
  final _c1Controller = TextEditingController(text: '0');
  final _c3Controller = TextEditingController(text: '0');
  final _c5Controller = TextEditingController(text: '0');
  final _durationController = TextEditingController(text: '60');
  final _creatorController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _saveQuestion() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      await DatabaseHelper.instance.insertQuestion(
        questionId: _qIdController.text.trim(),
        subjectId: _subjIdController.text.trim(),
        grade: _gradeController.text.trim(),
        chapter: _chapterController.text.trim(),
        questionText: _qTextController.text.trim(),
        optionA: _optAController.text.trim(),
        optionB: _optBController.text.trim(),
        optionC: _optCController.text.trim(),
        optionD: _optDController.text.trim(),
        correctOption: _correctOpt,
        marks: _marks,
      );
      setState(() { _isLoading = false; _message = 'မေးခွန်း သိမ်းဆည်းခြင်း အောင်မြင်ပါသည်။'; });
    } catch (e) {
      setState(() { _isLoading = false; _message = 'မှားယွင်းမှု ရှိပါသည်။'; });
    }
  }

  void _saveExam() async {
    setState(() { _isLoading = true; _message = ''; });
    try {
      int c1 = int.parse(_c1Controller.text.trim());
      int c3 = int.parse(_c3Controller.text.trim());
      int c5 = int.parse(_c5Controller.text.trim());
      int total = (c1 * 1) + (c3 * 3) + (c5 * 5);

      await DatabaseHelper.instance.insertExam(
        examId: _examIdController.text.trim(),
        title: _examTitleController.text.trim(),
        subjectId: _examSubjController.text.trim(),
        grade: _examGradeController.text.trim(),
        count1Mark: c1,
        count3Mark: c3,
        count5Mark: c5,
        totalMarks: total,
        durationMinutes: int.parse(_durationController.text.trim()),
        createdBy: _creatorController.text.trim(),
      );
      setState(() { _isLoading = false; _message = 'စာမေးပွဲ ဖန်တီးခြင်း အောင်မြင်ပါသည်။ (စုစုပေါင်းအမှတ်: $total)'; });
    } catch (e) {
      setState(() { _isLoading = false; _message = 'အချက်အလက်များ စစ်ဆေးပါ။'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112240),
        title: const Text('မေးခွန်းနှင့် စာမေးပွဲ စီမံရန်', style: TextStyle(color: Colors.amber)),
        iconTheme: const IconThemeData(color: Colors.amber),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'မေးခွန်းထည့်ရန်'),
            Tab(text: 'စာမေးပွဲဖန်တီးရန်'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Question Bank Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  TextField(controller: _qIdController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Question ID (ဥပမာ- Q001)', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _subjIdController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Subject ID', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _gradeController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Grade', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _chapterController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Chapter', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _qTextController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'မေးခွန်းစာသား (Question Text)', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _optAController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Option A', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _optBController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Option B', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _optCController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Option C', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _optDController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Option D', labelStyle: TextStyle(color: Colors.white70))),
                  DropdownButtonFormField<String>(
                    value: _correctOpt,
                    dropdownColor: const Color(0xFF112240),
                    style: const TextStyle(color: Colors.white),
                    items: ['A', 'B', 'C', 'D'].map((val) => DropdownMenuItem(value: val, child: Text('Correct: $val'))).toList(),
                    onChanged: (val) => setState(() => _correctOpt = val!),
                  ),
                  DropdownButtonFormField<int>(
                    value: _marks,
                    dropdownColor: const Color(0xFF112240),
                    style: const TextStyle(color: Colors.white),
                    items: [1, 3, 5].map((val) => DropdownMenuItem(value: val, child: Text('$val မှတ်'))).toList(),
                    onChanged: (val) => setState(() => _marks = val!),
                  ),
                  const SizedBox(height: 16),
                  if (_message.isNotEmpty) Text(_message, style: const TextStyle(color: Colors.amber)),
                  const SizedBox(height: 10),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), onPressed: _saveQuestion, child: const Text('မေးခွန်း သိမ်းမည်', style: TextStyle(color: Color(0xFF0A192F)))),
                ],
              ),
            ),
          ),

          // Tab 2: Exam Blueprint Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF112240), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  TextField(controller: _examIdController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Exam ID', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _examTitleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'စာမေးပွဲခေါင်းစဉ် (Title)', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _examSubjController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Subject ID', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _examGradeController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Grade', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _c1Controller, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: '၁ မှတ်တန် အရေအတွက်', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _c3Controller, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: '၃ မှတ်တန် အရေအတွက်', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _c5Controller, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: '၅ မှတ်တန် အရေအတွက်', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _durationController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'ကြာမြင့်ချိန် (မိနစ်)', labelStyle: TextStyle(color: Colors.white70))),
                  TextField(controller: _creatorController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'ဖန်တီးသူ (Created By)', labelStyle: TextStyle(color: Colors.white70))),
                  const SizedBox(height: 16),
                  if (_message.isNotEmpty) Text(_message, style: const TextStyle(color: Colors.amber)),
                  const SizedBox(height: 10),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), onPressed: _saveExam, child: const Text('စာမေးပွဲ ဖန်တီးမည်', style: TextStyle(color: Color(0xFF0A192F)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
