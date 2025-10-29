import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart'; // WEEK6: init Hive
import 'src/app.dart';
import 'features/insightmind/data/local/screening_record.dart'; // WEEK6: model Hive (adapter)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WEEK6: Inisialisasi Hive untuk Flutter (buat direktori penyimpanan)
  await Hive.initFlutter();

  // WEEK6: Registrasi adapter agar Hive tahu cara serialisasi ScreeningRecord
  Hive.registerAdapter(ScreeningRecordAdapter());

  // WEEK6: Buka "box" (database kecil) tempat menyimpan record screening
  // (Bisa juga dibuka lazy di repository; di sini kita pastikan siap pakai)
  await Hive.openBox<ScreeningRecord>('screening_records');

  // Riverpod root scope tetap sama seperti M2–M4
  runApp(const ProviderScope(child: InsightMindApp()));
}
