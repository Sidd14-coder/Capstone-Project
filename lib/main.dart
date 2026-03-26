import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:telephony/telephony.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'data/refresh_totals.dart';
import 'services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  await Hive.openBox('emiBox');
  await Hive.openBox('paymentHistory'); // 🔥 IMPORTANT

  await Hive.openBox('customTransactions');

  await Hive.openBox('userBox');

  // ✅ REQUEST SMS PERMISSION ONCE AT APP START
  final telephony = Telephony.instance;
  await telephony.requestSmsPermissions;

  // ✅ CALCULATE TOTALS AFTER PERMISSION
  await refreshTotals();

  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
