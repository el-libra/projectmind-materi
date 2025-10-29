// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../domain/entities/question.dart';
// import '../providers/questionnaire_provider.dart';
// import '../providers/score_provider.dart'; // dari Minggu 2 (resultProvider/answersProvider)
// import 'result_page.dart';

// class ScreeningPage extends ConsumerWidget {
//   const ScreeningPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final questions = ref.watch(questionsProvider);
//     final qState = ref.watch(questionnaireProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Screening InsightMind'),
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//       ),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemCount: questions.length,
//         separatorBuilder: (_, __) => const Divider(height: 24),
//         itemBuilder: (context, index) {
//           final q = questions[index];
//           final selected =
//               qState.answers[q.id]; // skor terpilih (0..3) atau null
//           return _QuestionTile(
//             question: q,
//             selectedScore: selected,
//             onSelected: (score) {
//               ref
//                   .read(questionnaireProvider.notifier)
//                   .selectAnswer(questionId: q.id, score: score);
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: SafeArea(
//         minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//         child: FilledButton(
//           onPressed: () {
//             if (!qState.isComplete) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text('Lengkapi semua pertanyaan dulu.')),
//               );
//               return;
//             }

//             // Alirkan jawaban ke "answersProvider" (Minggu 2) agar pipeline lama tetap jalan:
//             final answersOrdered = <int>[];
//             for (final q in questions) {
//               answersOrdered.add(qState.answers[q.id]!);
//             }
//             ref.read(answersProvider.notifier).state = answersOrdered;

//             Navigator.of(context).push(
//               MaterialPageRoute(builder: (_) => const ResultPage()),
//             );
//           },
//           child: const Text('Lihat Hasil'),
//         ),
//       ),
//     );
//   }
// }

// class _QuestionTile extends StatelessWidget {
//   final Question question;
//   final int? selectedScore;
//   final ValueChanged<int> onSelected;

//   const _QuestionTile({
//     required this.question,
//     required this.selectedScore,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           question.text,
//           style: Theme.of(context).textTheme.titleMedium,
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             for (final opt in question.options)
//               ChoiceChip(
//                 label: Text(opt.label),
//                 selected: selectedScore == opt.score,
//                 onSelected: (_) => onSelected(opt.score),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/../features/domain/entities/question.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart';
import 'result_page.dart';

class ScreeningPage extends ConsumerWidget {
  const ScreeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final progress =
        questions.isEmpty ? 0.0 : (qState.answers.length / questions.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening InsightMind'),
        // Warna mengikuti Theme (diatur di src/app.dart)
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Progress bar pengerjaan
          Card(
            elevation: 1.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terisi: ${qState.answers.length}/${questions.length} pertanyaan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Daftar pertanyaan
          for (int i = 0; i < questions.length; i++) ...[
            _QuestionCard(
              index: i,
              question: questions[i],
              selectedScore: qState.answers[questions[i].id],
              onSelected: (score) {
                ref
                    .read(questionnaireProvider.notifier)
                    .selectAnswer(questionId: questions[i].id, score: score);
              },
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),

          // Tombol submit
          FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Lihat Hasil'),
            onPressed: () {
              if (!qState.isComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Lengkapi semua pertanyaan sebelum melihat hasil.'),
                  ),
                );
                return;
              }

              // Sinkronkan ke pipeline Minggu 2:
              // konversi Map<String,int> → List<int> berurutan sesuai urutan questions
              final ordered = <int>[];
              for (final q in questions) {
                ordered.add(qState.answers[q.id]!);
              }
              ref.read(answersProvider.notifier).state = ordered;

              // Navigasi ke halaman hasil
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ResultPage()),
              );
            },
          ),

          const SizedBox(height: 8),
          // Tombol reset opsional
          TextButton.icon(
            onPressed: () {
              ref.read(questionnaireProvider.notifier).reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jawaban direset.')),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Jawaban'),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks pertanyaan
            Text(
              '${index + 1}. ${question.text}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),

            // Opsi jawaban (ChoiceChip)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opt in question.options)
                  ChoiceChip(
                    label: Text(opt.label),
                    selected: selectedScore == opt.score,
                    onSelected: (_) => onSelected(opt.score),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
