import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

/// 病床清單頁面
class BedListPage extends StatefulWidget {
  const BedListPage({super.key});

  @override
  State<BedListPage> createState() => _BedListPageState();
}

class _BedListPageState extends State<BedListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 登出並更新 SharedPreferences
  void _logout() async {
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('病床狀態'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      /// 使用 StreamBuilder 實時監聽 `beds` 集合
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('beds').snapshots(),
        builder: (context, snapshot) {
          // 若尚未取得資料，顯示轉圈圈
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bedDocs = snapshot.data!.docs;

          // 若集合裡沒有任何文件
          if (bedDocs.isEmpty) {
            return const Center(child: Text('目前沒有任何床位資料'));
          }

          return ListView.builder(
            itemCount: bedDocs.length,
            itemBuilder: (context, index) {
              final bedData = bedDocs[index].data() as Map<String, dynamic>;
              final bedId = bedDocs[index].id; // 文件ID
              final bedName = bedData['name'] ?? '未命名床位';
              final alarmTriggered = bedData['alarm'] ?? false;

              return Card(
                // 如果 alarmTriggered 為 true，整張卡片帶點紅色底
                color: alarmTriggered ? Colors.red[100] : null,
                child: ListTile(
                  title: Text(bedName),
                  subtitle: alarmTriggered
                      ? const Text(
                    '警報觸發中',
                    style: TextStyle(color: Colors.red),
                  )
                      : null,
                  trailing: ElevatedButton(
                    // 此處按鈕示範手動觸發／解除警報
                    onPressed: () async {
                      final newAlarmState = !alarmTriggered;
                      // 將 alarm 欄位更新為相反值
                      await FirebaseFirestore.instance
                          .collection('beds')
                          .doc(bedId)
                          .update({'alarm': newAlarmState});

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '已${newAlarmState ? "觸發" : "解除"}警報: $bedName',
                          ),
                        ),
                      );
                    },
                    child: Text(alarmTriggered ? '解除' : '警報'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
