import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ApiService.getStatistics();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);

    // Mock data for beautiful charts since real API might just return raw counts right now.
    // In a real app, this would be computed from the API payload.
    final diseaseData = {
      'Dengue': 145, 'Flu': 382, 'COVID-19': 89, 'Typhoid': 67, 'Other': 45
    };
    final maxDisease = diseaseData.values.reduce((a, b) => a > b ? a : b);

    final severityData = {
      'Mild': 45, 'Moderate': 35, 'Severe': 20
    };

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium Header ──
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: c.bg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: c.dark
                            ? [const Color(0xFF6D28D9), const Color(0xFF0F172A)]
                            : [const Color(0xFF8B5CF6), const Color(0xFF4C1D95)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -20, right: -20,
                    child: Container(width: 150, height: 150,
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white.withOpacity(0.15), Colors.transparent]))),
                  ),
                  Positioned(
                    bottom: -30, left: -20,
                    child: Container(width: 180, height: 180,
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.emerald.withOpacity(0.3), Colors.transparent]))),
                  ),
                ],
              ),
            ),
            title: const Text('Statistics & Insights', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: _loading
                ? Center(child: Padding(padding: const EdgeInsets.all(50), child: CircularProgressIndicator(color: AppColors.purple)))
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Overview Cards ──
                        Row(
                          children: [
                            Expanded(child: _buildStatCard(c, title: 'Total Reports', value: '${_stats['stats']?['total_reports'] ?? 0}', icon: Icons.description_outlined, gradient: [AppColors.blue, AppColors.blueDark])),
                            const SizedBox(width: 14),
                            Expanded(child: _buildStatCard(c, title: 'Affected Areas', value: '${_stats['stats']?['affected_areas'] ?? 0}', icon: Icons.map_outlined, gradient: [AppColors.amber, AppColors.amberDark])),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Disease Distribution ──
                        Row(
                          children: [
                            Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 10),
                            Text('Disease Distribution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: c.glassBgStrong, borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.glassBorder), boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 10)],
                          ),
                          child: Column(
                            children: diseaseData.entries.map((e) {
                              final percentage = e.value / maxDisease;
                              Color barColor;
                              if (e.key == 'Dengue') barColor = AppColors.red;
                              else if (e.key == 'Flu') barColor = AppColors.blue;
                              else if (e.key == 'COVID-19') barColor = AppColors.purple;
                              else barColor = AppColors.amber;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.key, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: c.textPrimary)),
                                        Text('${e.value} cases', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: barColor)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 8, width: double.infinity, color: barColor.withOpacity(0.15),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: percentage,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              gradient: LinearGradient(colors: [barColor, barColor.withOpacity(0.7)]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Severity Breakdown ──
                        Row(
                          children: [
                            Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 10),
                            Text('Severity Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: c.glassBgStrong, borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.glassBorder), boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 10)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: severityData.entries.map((e) {
                              Color sColor = AppColors.emerald;
                              if (e.key == 'Moderate') sColor = AppColors.amber;
                              if (e.key == 'Severe') sColor = AppColors.red;

                              return Column(
                                children: [
                                  SizedBox(
                                    height: 70, width: 70,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(value: e.value / 100, strokeWidth: 8, color: sColor, backgroundColor: sColor.withOpacity(0.15), strokeCap: StrokeCap.round),
                                        Center(child: Text('${e.value}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.textPrimary))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(e.key, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: c.textSecondary)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(AppColors c, {required String title, required String value, required IconData icon, required List<Color> gradient}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.glassBgStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradient[0].withOpacity(0.3)),
        boxShadow: [BoxShadow(color: gradient[0].withOpacity(c.dark ? 0.1 : 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: gradient[0].withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: gradient[0], size: 22),
          ),
          const SizedBox(height: 14),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: c.textPrimary)),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: c.textSecondary)),
        ],
      ),
    );
  }
}
