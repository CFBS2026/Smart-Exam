Import 'package:sqflite/sqflite.dart';
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
}
