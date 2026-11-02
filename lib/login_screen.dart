import 'package:flutter/material.dart';
import '../services/database_helper.dart'; // ကိုယ့်ဖိုင်လမ်းကြောင်းအတိုင်း စစ်ဆေးရန်

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Username နှင့် Password ထည့်ရန် လိုအပ်ပါသည်။';
      });
      return;
    }

    // Database မှ User ကို စစ်ဆေးခြင်း
    final user = await DatabaseHelper.instance.loginUser(username, password);

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      String role = user['role']; // 'principal', 'teacher', 'student'
      
      // Role အလိုက် သက်ဆိုင်ရာ Dashboard သို့ ပို့ဆောင်ခြင်း
      if (role == 'principal') {
        // TODO: Principal Dashboard သို့ သွားရန်
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PrincipalDashboard()));
      } else if (role == 'teacher') {
        // TODO: Teacher Dashboard သို့ သွားရန်
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TeacherDashboard()));
      } else if (role == 'student') {
        // TODO: Student Dashboard သို့ သွားရန်
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentDashboard()));
      }
    } else {
      setState(() {
        _errorMessage = 'Username သို့မဟုတ် Password မှားယွင်းနေပါသည်။';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Navy Blue Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo & App Title
              const Icon(Icons.school, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                "CHINDWIN FUTURE BRIGHT SCHOOL",
                style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                "CFBS SMART EXAM SYSTEM",
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Login Card Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF112240),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "အကောင့်ဝင်ရန် (Login)",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    // Username Field
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.person, color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_errorMessage.isNotEmpty)
                      Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Color(0xFF0A192F))
                            : const Text(
                                "ဝင်မည် (Login)",
                                style: TextStyle(color: Color(0xFF0A192F), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
