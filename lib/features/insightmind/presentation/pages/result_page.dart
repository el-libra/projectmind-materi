import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart'; // pipeline skor/result (M2)
import '../providers/history_providers.dart'; // WEEK6: simpan riwayat (Hive)

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  bool _saved = false; // WEEK6: flag agar tidak simpan dobel saat rebuild

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // WEEK6: autosave 1x ketika halaman pertama kali siap
    if (!_saved) {
      final result =
          ref.read(resultProvider); // ambil hasil akhir (skor + risk)
      ref
          .read(historyRepositoryProvider)
          .addRecord(score: result.score, riskLevel: result.riskLevel);
      _saved = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(resultProvider);

    // (UI M5 tetap) — ditambah teks info "hasil disimpan"
    String recommendation;
    switch (result.riskLevel) {
      case 'Tinggi':
        recommendation = 'Pertimbangkan berbicara dengan konselor/psikolog. '
            'Kurangi beban, istirahat cukup, dan hubungi layanan kampus.';
        break;
      case 'Sedang':
        recommendation =
            'Lakukan relaksasi rutin, olahraga ringan, dan evaluasi beban harian.';
        break;
      default:
        recommendation =
            'Pertahankan kebiasaan baik. Jaga pola tidur, makan, dan olahraga.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Screening')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_objects,
                      size: 60, color: Colors.indigo),
                  const SizedBox(height: 12),
                  Text('Skor Anda: ${result.score}',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    'Tingkat Risiko: ${result.riskLevel}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: result.riskLevel == 'Tinggi'
                          ? Colors.red
                          : result.riskLevel == 'Sedang'
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(recommendation, textAlign: TextAlign.center),
                  const SizedBox(height: 16),

                  // WEEK6: informasi bahwa hasil otomatis disimpan
                  const Text(
                    'Hasil telah disimpan di perangkat (Riwayat).',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),

                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
