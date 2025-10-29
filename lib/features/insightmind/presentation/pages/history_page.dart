import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_providers.dart';
import '../../data/local/screening_record.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync =
        ref.watch(historyListProvider); // WEEK6: load semua riwayat

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Screening')),
      body: historyAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada riwayat.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final ScreeningRecord r = items[i];
              return Card(
                child: ListTile(
                  title: Text('Skor: ${r.score} • ${r.riskLevel}'),
                  subtitle: Text(
                    // WEEK6: tampilkan timestamp & id sebagai informasi teknis
                    'Waktu: ${r.timestamp}\nID: ${r.id}',
                    maxLines: 2,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // WEEK6: hapus item ini
                      await ref
                          .read(historyRepositoryProvider)
                          .deleteById(r.id);
                      // WEEK6: refresh future agar UI update
                      // ignore: unused_result
                      ref.refresh(historyListProvider);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Riwayat dihapus')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),

      // WEEK6: tombol "Kosongkan Semua" di bawah
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Kosongkan Semua Riwayat'),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Yakin ingin menghapus semua riwayat?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus')),
                ],
              ),
            );
            if (ok == true) {
              await ref
                  .read(historyRepositoryProvider)
                  .clearAll(); // hapus semua
              // ignore: unused_result
              ref.refresh(historyListProvider); // refresh UI
            }
          },
        ),
      ),
    );
  }
}
