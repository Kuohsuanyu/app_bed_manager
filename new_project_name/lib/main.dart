import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'bed_list_page.dart';

/// 初始化並啟動 App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 Firebase
  await Firebase.initializeApp();
  runApp(const MyApp());
}

/// App 主組件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '病床監測系統',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

/// 啟動畫面，用來判斷要進入登入頁面或病床列表
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  /// 檢查是否已登入
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // 模擬載入或顯示 Logo 等待
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? const BedListPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('載入中...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
