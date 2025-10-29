import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';
import 'screening_page.dart';
import 'history_page.dart'; // WEEK5: import halaman riwayat

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InsightMind'),
        actions: [
          // WEEK5: tombol menuju halaman riwayat
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Screening',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.psychology_alt,
                      size: 60, color: Colors.indigo),
                  const SizedBox(height: 16),
                  const Text(
                    'Selamat Datang di InsightMind',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai screening sederhana untuk memprediksi risiko '
                    'kesehatan mental secara cepat dan mudah.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (answers.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Riwayat Simulasi Minggu 2',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final a in answers) Chip(label: Text('$a'))
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          // (materi M2) — simulasi tambah angka 0..3
          final newValue = (DateTime.now().millisecondsSinceEpoch % 4).toInt();
          final current = [...ref.read(answersProvider)];
          current.add(newValue);
          ref.read(answersProvider.notifier).state = current;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
