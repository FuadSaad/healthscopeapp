import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_theme.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  static const List<Map<String, String>> emergencyNumbers = [
    {'name': 'National Emergency', 'number': '999', 'icon': '🚨', 'desc': 'Police, Fire, Ambulance — Free from any phone', 'color': 'red'},
    {'name': 'Ambulance Service', 'number': '199', 'icon': '🚑', 'desc': 'Government ambulance dispatch service', 'color': 'red'},
    {'name': 'Fire Service', 'number': '16163', 'icon': '🔥', 'desc': 'Fire brigade emergency response', 'color': 'orange'},
    {'name': 'Police Help', 'number': '100', 'icon': '👮', 'desc': 'Bangladesh Police helpline', 'color': 'blue'},
    {'name': 'Women & Child Helpline', 'number': '10921', 'icon': '👩‍👧', 'desc': 'Violence against women & children', 'color': 'purple'},
    {'name': 'DGHS Health Helpline', 'number': '16263', 'icon': '🏥', 'desc': 'Directorate General of Health Services', 'color': 'green'},
    {'name': 'COVID-19 Helpline', 'number': '333', 'icon': '😷', 'desc': 'IEDCR COVID helpline — 24/7', 'color': 'cyan'},
    {'name': 'Blood Bank (Sandhani)', 'number': '+880-2-9116551', 'icon': '🩸', 'desc': 'Emergency blood supply', 'color': 'red'},
    {'name': 'Poison Control', 'number': '+880-2-8626812', 'icon': '☠️', 'desc': 'National Poison Information Centre', 'color': 'amber'},
    {'name': 'Kaan Pete Roi', 'number': '+880-1779-554391', 'icon': '🧠', 'desc': 'Mental health & emotional support', 'color': 'purple'},
  ];

  static const List<Map<String, String>> hospitals24x7 = [
    {'name': 'Dhaka Medical College', 'number': '+880-2-55165088', 'division': 'Dhaka'},
    {'name': 'Square Hospital', 'number': '+880-2-8159457', 'division': 'Dhaka'},
    {'name': 'United Hospital', 'number': '+880-2-8836000', 'division': 'Dhaka'},
    {'name': 'CMCH', 'number': '+880-31-630335', 'division': 'Chittagong'},
    {'name': 'RMCH', 'number': '+880-721-772150', 'division': 'Rajshahi'},
    {'name': 'SMCH', 'number': '+880-821-714234', 'division': 'Sylhet'},
  ];

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'red': return AppColors.red;
      case 'orange': return const Color(0xFFF97316);
      case 'blue': return AppColors.blue;
      case 'purple': return AppColors.purple;
      case 'green': return AppColors.emerald;
      case 'cyan': return AppColors.cyan;
      case 'amber': return AppColors.amber;
      default: return AppColors.emerald;
    }
  }

  void _callPhone(BuildContext context, String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── Header ──
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 16, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: c.dark
                    ? [const Color(0xFF7F1D1D), const Color(0xFF0F172A)]
                    : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                      Text('জরুরি হেল্পলাইন নম্বর', style: TextStyle(fontSize: 12, color: Color(0xFFFECACA), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── SOS Banner ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.red.withOpacity(0.12), AppColors.redDark.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.red.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 14)],
                        ),
                        child: const Text('🆘', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('জরুরি প্রয়োজনে কল করুন', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.textPrimary)),
                            const SizedBox(height: 4),
                            Text('National Emergency: 999\nFree from any phone, 24/7', style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.4)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _callPhone(context, '999'),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 12)],
                          ),
                          child: const Icon(Icons.phone, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Helpline Numbers ──
                Row(
                  children: [
                    Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 10),
                    Text('Emergency Helplines', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.textPrimary)),
                  ],
                ),
                const SizedBox(height: 14),

                ...emergencyNumbers.map((item) {
                  final color = _getColor(item['color']!);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: c.glassBgStrong,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: c.glassBorderSubtle),
                          boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 8)],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _callPhone(context, item['number']!),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: color.withOpacity(0.2)),
                                    ),
                                    child: Center(child: Text(item['icon']!, style: const TextStyle(fontSize: 22))),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text(item['desc']!, style: TextStyle(fontSize: 11, color: c.textTertiary)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8)],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.phone, color: Colors.white, size: 12),
                                            const SizedBox(width: 4),
                                            Text(item['number']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // ── 24/7 Hospital Contacts ──
                Row(
                  children: [
                    Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 10),
                    Text('24/7 Hospital Emergency', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.textPrimary)),
                  ],
                ),
                const SizedBox(height: 14),

                ...hospitals24x7.map((h) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: c.glassBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.glassBorderSubtle),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _callPhone(context, h['number']!),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.local_hospital_rounded, color: AppColors.blue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['name']!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: c.textPrimary)),
                                  Text(h['division']!, style: TextStyle(fontSize: 11, color: c.textTertiary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.phone_rounded, color: AppColors.emerald, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
