import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/score_provider.dart';
import 'screening_page.dart'; // alur Minggu 2–5
import 'biometric_page.dart'; // alur Minggu 6–8

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InsightMind'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Kartu 1: Screening Kuisioner (M2–M5)
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Screening Kuisioner',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jawab beberapa pertanyaan sederhana untuk mendapatkan '
                    'skor indikasi awal kesehatan mental.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ScreeningPage()),
                      );
                    },
                    child: const Text('Mulai Screening'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Skor terakhir: $score',
                    style: const TextStyle(
                        fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Kartu 2: Sensor & Biometrik (M6 + M7)
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sensor & Biometrik + AI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gunakan sensor accelerometer dan kamera untuk mendapatkan '
                    'fitur biometrik, lalu hitung prediksi risiko dengan AI on-device.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.sensors),
                    label: const Text('Buka Modul Sensor & AI'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BiometricPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Disarankan: lakukan screening dulu, kemudian lanjut ke modul ini.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
