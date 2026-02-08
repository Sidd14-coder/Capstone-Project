import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:telephony/telephony.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'data/refresh_totals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
