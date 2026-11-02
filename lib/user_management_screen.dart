import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class UserManagementScreen extends StatefulWidget {
  final String currentRole; // 'principal' သို့မဟုတ် 'teacher'
  const UserManagementScreen({Key? key, required this.currentRole}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _userIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _gradeController = TextEditingController();
  
  // ဖန်တီးမည့် Role (Principal က teacher ဖန်တီးမည်၊ Teacher က student ဖန်တီးမည်)
  late String _targetRole;
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    // ဝင်ရောက်လာသူ၏ Role အပေါ်မူတည်၍ ဘယ်သူ့အကောင့်ဆောက်မည်ကို သတ်မှတ်ခြင်း
    _targetRole = widget.currentRole == 'principal' ? 'teacher' : 'student';
  }

  void _saveUser() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    String userId = _userIdController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String fullName = _fullNameController.text.trim();
    String grade = _gradeController.text.trim();

    if (userId.isEmpty || username.isEmpty || password.isEmpty || fullName.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'အချက်အလက်များကို အပြည့်အစုံ ဖြည့်စွက်ပါ။';
      });
      return;
    }

    try {
      await DatabaseHelper.instance.insertUser(
        userId: userId,
        username: username,
        password: password,
        fullName: fullName,
        role: _targetRole,
        grade: _targetRole == 'student' ? grade : null,
      );

      setState(() {
        _isLoading = false;
        _message = 'အကောင့်အသစ် ဖန်တီးခြင်း အောင်မြင်ပါသည်။';
      });

      // Form များကို ရှင်းလင်းခြင်း
      _userIdController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _fullNameController.clear();
      _gradeController.clear();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'မှားယွင်းမှု ရှိ습니다 (Username ထပ်နေနိုင်သည်)။';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112240),
        title: Text(
          _targetRole == 'teacher' ? 'ဆရာ/မ အကောင့်အသစ်ထည့်ရန်' : 'ကျောင်းသား အကောင့်အသစ်ထည့်ရန်',
          style: const TextStyle(color: Colors.amber),
        ),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF112240),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ဖန်တီးမည့်သူအမျိုးအစား: ${_targetRole.toUpperCase()}",
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),

              // User ID
              TextField(
                controller: _userIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'User ID (ဥပမာ- T001 သို့ S001)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber300)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                ),
              ),
              const SizedBox(height: 16),

              // Username
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber300)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber300)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                ),
              ),
              const SizedBox(height: 16),

              // Full Name
              TextField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'အမည်အပြည့်အစုံ (Full Name)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber300)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                ),
              ),
              const SizedBox(height: 16),

              // Grade (ကျောင်းသားအတွက်ဆိုလျှင် Grade ထည့်ရန်)
              if (_targetRole == 'student') ...[
                TextField(
                  controller: _gradeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'အတန်း (Grade 12)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber300)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('အောင်မြင်') ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : _saveUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF0A192F))
                      : const Text(
                          "အကောင့်သိမ်းဆည်းမည် (Save User)",
                          style: TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
