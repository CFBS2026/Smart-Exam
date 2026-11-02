import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cfbs_exam.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // ၁။ Users Table (ကျောင်းအုပ်၊ ဆရာ/မ၊ ကျောင်းသား)
    await db.execute('''
      CREATE TABLE Users (
        user_id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT CHECK(role IN ('principal', 'teacher', 'student')),
        grade TEXT,
        stream TEXT
      )
    ''');

    // ၂။ Subjects Table (ဘာသာရပ်များ)
    await db.execute('''
      CREATE TABLE Subjects (
        subject_id TEXT PRIMARY KEY,
        subject_name TEXT NOT NULL,
        code TEXT NOT NULL
      )
    ''');

    // ၃။ Questions Table (မေးခွန်းဘဏ် - 1, 3, 5 Marks ပါဝင်သည်)
    await db.execute('''
      CREATE TABLE Questions (
        question_id TEXT PRIMARY KEY,
        subject_id TEXT,
        grade TEXT,
        chapter TEXT,
        question_text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT CHECK(correct_option IN ('A', 'B', 'C', 'D')),
        marks INTEGER DEFAULT 1,
        FOREIGN KEY (subject_id) REFERENCES Subjects (subject_id)
      )
    ''');

    // ၄။ Exams Table (စာမေးပွဲများနှင့် Test Blueprint)
    await db.execute('''
      CREATE TABLE Exams (
        exam_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject_id TEXT,
        grade TEXT,
        count_1_mark INTEGER DEFAULT 0,
        count_3_mark INTEGER DEFAULT 0,
        count_5_mark INTEGER DEFAULT 0,
        total_marks INTEGER,
        duration_minutes INTEGER,
        created_by TEXT,
        FOREIGN KEY (subject_id) REFERENCES Subjects (subject_id)
      )
    ''');

    // ၅။ ExamResults Table (ဖြေဆိုပြီး ရလဒ်ဇယားမှတ်တမ်း)
    await db.execute('''
      CREATE TABLE ExamResults (
        result_id TEXT PRIMARY KEY,
        exam_id TEXT,
        student_id TEXT,
        start_time TEXT,
        submit_time TEXT,
        duration_taken TEXT,
        score_obtained INTEGER,
        total_marks INTEGER,
        grade_achieved TEXT,
        FOREIGN KEY (exam_id) REFERENCES Exams (exam_id),
        FOREIGN KEY (student_id) REFERENCES Users (user_id)
      )
    ''');
  }

  // User Login စစ်ဆေးရန် function
  Future?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'Users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first; // အကောင့်ရှိလျှင် အချက်အလက်များကို Return ပေးမည်
    }
    return null; // အကောင့်မမှန်ပါက null ပေးမည်
  }
}
  // User အသစ်ထည့်သွင်းရန် function (ကျောင်းအုပ်က ဆရာ/မ ထည့်ရန် နှင့် ဆရာ/မက ကျောင်းသား ထည့်ရန်)
  Future<int> insertUser({
    required String userId,
    required String username,
    required String password,
    required String fullName,
    required String role, // 'principal', 'teacher', 'student'
    String? grade,
    String? stream,
  }) async {
    final db = await database;

    Map<String, dynamic> row = {
      'user_id': userId,
      'username': username,
      'password': password,
      'full_name': fullName,
      'role': role,
      'grade': grade,
      'stream': stream,
    };

    return await db.insert('Users', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // ၁။ မေးခွန်းအသစ်ထည့်သွင်းရန် function (Questions Table)
  Future<int> insertQuestion({
    required String questionId,
    required String subjectId,
    required String grade,
    required String chapter,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctOption, // 'A', 'B', 'C', 'D'
    required int marks, // 1, 3, သို့မဟုတ် 5
  }) async {
    final db = await database;

    Map<String, dynamic> row = {
      'question_id': questionId,
      'subject_id': subjectId,
      'grade': grade,
      'chapter': chapter,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
      'marks': marks,
    };

    return await db.insert('Questions', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ၂။ စာမေးပွဲနှင့် Test Blueprint အသစ်ဖန်တီးရန် function (Exams Table)
  Future<int> insertExam({
    required String examId,
    required String title,
    required String subjectId,
    required String grade,
    required int count1Mark,
    required int count2Mark,
    required int count3Mark,
    required int count5Mark,
    required int totalMarks,
    required int durationMinutes,
    required String createdBy,
  }) async {
    final db = await database;

    Map<String, dynamic> row = {
      'exam_id': examId,
      'title': title,
      'subject_id': subjectId,
      'grade': grade,
      'count_1_mark': count1Mark,
      'count_2_mark': count2Mark,
      'count_3_mark': count3Mark,
      'count_5_mark': count5Mark,
      'total_marks': totalMarks,
      'duration_minutes': durationMinutes,
      'created_by': createdBy,
    };

    return await db.insert('Exams', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // ၁။ ဖြေဆိုပြီး ရလဒ်ကို ExamResults Table သို့ သိမ်းဆည်းရန် function
  Future<int> insertExamResult({
    required String resultId,
    required String examId,
    required String studentId,
    required String startTime,
    required String submitTime,
    required String durationTaken,
    required int scoreObtained,
    required int totalMarks,
    required String gradeAchieved,
  }) async {
    final db = await database;

    Map<String, dynamic> row = {
      'result_id': resultId,
      'exam_id': examId,
      'student_id': studentId,
      'start_time': startTime,
      'submit_time': submitTime,
      'duration_taken': durationTaken,
      'score_obtained': scoreObtained,
      'total_marks': totalMarks,
      'grade_achieved': gradeAchieved,
    };

    return await db.insert('ExamResults', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ၂။ ကျောင်းသားတစ်ဦး၏ ဖြေဆိုပြီးစာရင်းများကို ထုတ်ယူရန် function
  Future<List>> getStudentResults(String studentId) async {
    final db = await database;
    return await db.query(
      'ExamResults',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }


