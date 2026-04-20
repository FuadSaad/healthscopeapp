import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class InsightDetailsScreen extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final List<String> details;
  final List<Color> gradient;

  const InsightDetailsScreen({
    super.key,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.details,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium Header ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: c.bg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: c.dark
                            ? [gradient[0].withOpacity(0.6), const Color(0xFF0F172A)]
                            : [gradient[0].withOpacity(0.8), gradient[1].withOpacity(0.9)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40, right: -40,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 20)],
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 48)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: c.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: gradient[0].withOpacity(c.dark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: gradient[0].withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: gradient[0], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            desc,
                            style: TextStyle(color: c.textPrimary, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Container(width: 4, height: 20, decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 10),
                      Text('Actionable Steps', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...details.map((point) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: c.glassBgStrong,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.glassBorder),
                      boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 10)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: gradient[0].withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_rounded, color: gradient[0], size: 14),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              point,
                              style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
