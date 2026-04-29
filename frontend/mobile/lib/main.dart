import 'package:flutter/material.dart';

import 'app.dart';
import 'core/db/local_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.open();
  runApp(const ExamBankApp());
}
