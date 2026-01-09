// Dashboard Analytics InsightMind
// Teknologi: Riverpod 2.x + fl_chart + Material 3

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/history_providers.dart';
import '../providers/report_provider.dart';

// Lightweight sparkline card
// Widget ini menampilkan rangkuman skor terakhir dengan sparkline yang
// digambar menggunakan `CustomPaint`. Menggunakan state untuk menyimpan
// animation controller dan posisi hover/tap agar tooltip dapat ditampilkan.
class _SparklineCard extends StatefulWidget {
  final List records;
  const _SparklineCard({required this.records});

  @override
  State<_SparklineCard> createState() => _SparklineCardState();
}

class _SparklineCardState extends State<_SparklineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _drawAnimation;
  Offset? _hoveredPoint;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _drawAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _getTooltipText() {
    if (_hoveredPoint == null) return null;
    final values =
        widget.records.map<double>((r) => (r.score as num).toDouble()).toList();
    if (values.isEmpty) return null;

    final dx = 200 / (values.length - 1).clamp(1, values.length - 1);
    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final distance = (_hoveredPoint!.dx - x).abs();
      if (distance < 20) {
        return values[i].toStringAsFixed(1);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final values =
        widget.records.map<double>((r) => (r.score as num).toDouble()).toList();
    return Card(
      elevation: 0,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skor Terakhir',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Expanded area menempatkan sparkline dan tooltip
            Expanded(
              child: MouseRegion(
                // MouseRegion untuk desktop: update posisi hover
                onHover: (event) {
                  setState(() => _hoveredPoint = event.localPosition);
                },
                onExit: (event) {
                  // Hapus tooltip saat pointer keluar area
                  setState(() => _hoveredPoint = null);
                },
                child: GestureDetector(
                  // GestureDetector untuk menangani tap di mobile
                  onTapDown: (details) {
                    setState(() => _hoveredPoint = details.localPosition);
                  },
                  child: Stack(
                    children: [
                      // AnimatedBuilder menggerakkan progress animasi
                      AnimatedBuilder(
                        animation: _drawAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            // CustomPainter menggambar garis sparkline
                            painter: _SparklinePainter(
                              values,
                              color: Colors.indigo,
                              animationProgress: _drawAnimation.value,
                              hoveredPoint: _hoveredPoint,
                            ),
                            child: Container(),
                          );
                        },
                      ),
                      // Tooltip sebagai widget di atas canvas agar mudah di-style
                      if (_hoveredPoint != null)
                        Positioned(
                          left: _hoveredPoint!.dx - 20,
                          top: _hoveredPoint!.dy - 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getTooltipText() ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    DateFormat('MM/dd/yyyy')
                        .format(widget.records.first.timestamp),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(
                    DateFormat('MM/dd/yyyy')
                        .format(widget.records.last.timestamp),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double animationProgress;
  final Offset? hoveredPoint;

  _SparklinePainter(
    this.values, {
    this.color = Colors.indigo,
    this.animationProgress = 1.0,
    this.hoveredPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Paint untuk garis sparkline
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Paint untuk area gradient di bawah garis
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.25 * animationProgress),
          color.withOpacity(0.02 * animationProgress)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    // Perhitungan koordinat: dx adalah jarak x antar titik,
    // range dipakai untuk normalisasi nilai ke ruang vertikal canvas
    final dx = size.width / (values.length - 1).clamp(1, values.length - 1);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = (max - min) == 0 ? 1.0 : (max - min);

    // Index maksimum yang digambar sesuai progress animasi
    final maxIndex = (values.length * animationProgress).ceil();

    // Build the path with animation
    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final normalized = (values[i] - min) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else if (i <= maxIndex) {
        path.lineTo(x, y);
      }
    }

    // Hanya gambar area dan marker jika progress > 0
    if (maxIndex > 0) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      // Draw data point markers
      for (int i = 0; i < values.length; i++) {
        if (i > maxIndex) break;

        final x = dx * i;
        final normalized = (values[i] - min) / range;
        final y = size.height - (normalized * size.height);

        // Marker kecil di setiap titik data
        final markerPaint = Paint()
          ..color = color.withOpacity(0.6 * animationProgress)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 3.5, markerPaint);

        // Draw highlight circle on hover/tap near this point
        // Jika ada posisi hover/tap, gambarkan highlight di sekitar titik
        if (hoveredPoint != null) {
          final distance = (Offset(x, y) - hoveredPoint!).distance;
          if (distance < 20) {
            final highlightPaint = Paint()
              ..color = color.withOpacity(0.2)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(Offset(x, y), 12, highlightPaint);

            final borderPaint = Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            canvas.drawCircle(Offset(x, y), 12, borderPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.hoveredPoint != hoveredPoint;
  }
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca data histori screening (longitudinal data)
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InsightMind Dashboard'),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Terjadi kesalahan: $e'),
        ),
        data: (records) {
          // Jika belum ada data → edukatif, bukan error
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics,
                      size: 64, color: Colors.indigo.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data analytics.\nLakukan screening terlebih dahulu.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali ke Home'),
                  ),
                ],
              ),
            );
          }

          // ==============================
          // 1. DESCRIPTIVE ANALYTICS
          // ==============================
          final tinggi = records.where((r) => r.riskLevel == 'Tinggi').length;
          final sedang = records.where((r) => r.riskLevel == 'Sedang').length;
          final rendah = records.where((r) => r.riskLevel == 'Rendah').length;

          // ==============================
          // 2. TRANSFORMASI DATA → GRAFIK
          // (grafik dinonaktifkan sementara)
          // ==============================

          // ==============================
          // 3. INSIGHT GENERATION
          // ==============================
          String insight = 'Kondisi mental relatif stabil.';
          if (tinggi > sedang && tinggi > rendah) {
            insight =
                'Terdapat kecenderungan risiko tinggi. Pertimbangkan relaksasi atau konsultasi.';
          } else if (sedang > rendah) {
            insight = 'Risiko berada pada tingkat sedang dan perlu dipantau.';
          }

          // ==============================
          // 4. UI DASHBOARD (Material 3)
          // ==============================
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ---------- SUMMARY CARD ----------
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Risiko',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Risiko Tinggi : $tinggi'),
                      Text('Risiko Sedang : $sedang'),
                      Text('Risiko Rendah : $rendah'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- LINE CHART ----------
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tren Skor Screening',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Modern sparkline (CustomPaint) — lightweight, no external lib
                      SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _SparklineCard(records: records),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- INSIGHT PANEL + ACTIONS ----------
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insight:\n$insight',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            backgroundColor: Colors.red.shade50,
                            label: Text('Tinggi: $tinggi',
                                style: const TextStyle(color: Colors.red)),
                          ),
                          Chip(
                            backgroundColor: Colors.orange.shade50,
                            label: Text('Sedang: $sedang',
                                style: const TextStyle(color: Colors.orange)),
                          ),
                          Chip(
                            backgroundColor: Colors.green.shade50,
                            label: Text('Rendah: $rendah',
                                style: const TextStyle(color: Colors.green)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/history');
                              },
                              child: const Text('Lihat Histori'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('PDF'),
                            onPressed: () async {
                              final generator =
                                  ref.read(reportGeneratorProvider);
                              final previewer = ref.read(reportPreviewProvider);

                              final history = records.map((r) {
                                return {
                                  'tanggal':
                                      r.timestamp.toString().substring(0, 10),
                                  'score': r.score,
                                  'riskLevel': r.riskLevel,
                                };
                              }).toList();

                              final pdfBytes = await generator.generateReport(
                                username: 'User InsightMind',
                                history: history,
                              );

                              await previewer.previewPdf(
                                onLayout: (_) async => pdfBytes,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Bagikan'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
