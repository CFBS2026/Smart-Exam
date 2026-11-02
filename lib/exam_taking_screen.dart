import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class ExamTakingScreen extends StatefulWidget {
  const ExamTakingScreen({Key? key}) : super(key: key);

  @override
  _ExamTakingScreenState createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  bool _isSubmitted = false;
  int _score = 15; // ဥပမာ ရရှိသော ရလဒ်အမှတ်
  int _total = 20;

  // ဖြေဆိုပြီးဆုံးကြောင်း အတည်ပြုပြီး Database တွင် သိမ်းဆည်းခြင်း
  void _submitExam() async {
    String startTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().subtract(const Duration(minutes: 30)));
    String submitTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await DatabaseHelper.instance.insertExamResult(
      resultId: 'RES_${DateTime.now().millisecondsSinceEpoch}',
      examId: 'EXAM_001',
      studentId: 'STU_001',
      startTime: startTime,
      submitTime: submitTime,
      durationTaken: '30 mins',
      scoreObtained: _score,
      totalMarks: _total,
      gradeAchieved: 'A',
    );

    setState(() {
      _isSubmitted = true;
    });
  }

  // 2-inch Bluetooth Thermal Printer ဖြင့် ထုတ်ယူရန် တွေးခေါ်ပုံ (Print Format)
  void _printReceipt() {
    // 2-inch Thermal Printer (ပုံမှန်အားဖြင့် 32 character အကျယ်) အတွက် စာသားပုံစံ
    String printData = """
    CHINDWIN FUTURE BRIGHT SCHOOL
    --------------------------------
    EXAM RESULT SLIP
    --------------------------------
    Student ID : STU_001
    Exam ID    : EXAM_001
    Score      : $_score / $_total
    Grade      : A
    Date       : ${DateFormat('yyyy-MM-dd').format(DateTime.now())}
    --------------------------------
       Authorized Signature
    """;
    
    // ဒီနေရာတွင် Bluetooth Thermal Printer package ဖြင့် ပို့ဆောင်ရန်
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bluetooth Printer သို့ ပေးပို့နေပါပြီ...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112240),
        title: const Text('စာမေးပွဲဖြေဆိုရန်', style: TextStyle(color: Colors.amber)),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF112240),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: _isSubmitted
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
                      const SizedBox(height: 16),
                      const Text('စာမေးပွဲ ဖြေဆိုပြီးစီးပါပြီ!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('ရရှိသောရလဒ်: $_score / $_total', style: const TextStyle(color: Colors.amber, fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        onPressed: _printReceipt,
                        icon: const Icon(Icons.print, color: Color(0xFF0A192F)),
                        label: const Text('Thermal Printer ဖြင့် Print ထုတ်မည်', style: TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('မေးခွန်း ၁။ (နမူနာ မေးခွန်း)', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        onPressed: _submitExam,
                        child: const Text('အဖြေတင်သွင်းမည် (Submit Exam)', style: TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
