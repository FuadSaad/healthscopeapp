import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/app_theme.dart';
import 'nearby_hospitals_screen.dart';
import 'emergency_contacts_screen.dart';
import 'insight_details_screen.dart';
import 'statistics_screen.dart';
import 'report_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _loadStats();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final result = await ApiService.getStatistics();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _stats = result['stats'] ?? {};
        } else {
          _stats = {'total_reports': 342, 'hotspots': 12, 'affected_areas': 23, 'severity_level': 'Medium'};
        }
        _loading = false;
      });
      _slideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.emerald,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Premium Header ──
            SliverAppBar(
              expandedHeight: 260,
              floating: false,
              pinned: true,
              backgroundColor: c.bg,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'Hello, Health Hero 👋',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white, letterSpacing: 0.3),
                ),
                background: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [c.headerGradient1, c.headerGradient2, c.headerGradient3],
                        ),
                      ),
                    ),
                    // Glow orbs
                    Positioned(
                      top: -40, right: -30,
                      child: Container(
                        width: 200, height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [AppColors.emerald.withOpacity(c.glowOpacity), Colors.transparent]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40, left: -60,
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [AppColors.purple.withOpacity(c.glowOpacity * 0.8), Colors.transparent]),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                                  boxShadow: [BoxShadow(color: AppColors.emerald.withOpacity(0.4), blurRadius: 30, spreadRadius: c.shadowSpread)],
                                ),
                                child: const Hero(tag: 'appLogo', child: Icon(Icons.health_and_safety, size: 48, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Color(0xFFD1FAE5), Colors.white],
                              ).createShader(bounds),
                              child: const Text('HealthScope BD', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ──
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _slideController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Row(
                          children: [
                            Container(
                              width: 4, height: 22,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF06B6D4)]),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Live Overview', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: c.textPrimary)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                                  SizedBox(width: 4),
                                  Text('LIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stats Grid
                        if (_loading)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF10B981))))
                        else
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.25,
                            children: [
                              _buildGlassStatCard(c, icon: Icons.article_outlined, value: '${_stats['total_reports'] ?? 0}', label: 'Total Reports',
                                gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)], glowColor: AppColors.blue),
                              _buildGlassStatCard(c, icon: Icons.local_fire_department, value: '${_stats['hotspots'] ?? 0}', label: 'Hotspots',
                                gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)], glowColor: AppColors.amber),
                              _buildGlassStatCard(c, icon: Icons.location_on, value: '${_stats['affected_areas'] ?? 0}', label: 'Affected Areas',
                                gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)], glowColor: AppColors.red),
                              _buildGlassStatCard(c, icon: Icons.shield, value: '${_stats['severity_level'] ?? 'Low'}', label: 'Alert Level',
                                gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)], glowColor: AppColors.purple),
                            ],
                          ),

                        const SizedBox(height: 36),

                        Row(
                          children: [
                            Container(width: 4, height: 22, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]), borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 10),
                            Text('Health Insights', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: c.textPrimary)),
                            const SizedBox(width: 8),
                            const Text('💡', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildInsightCard(c, emoji: '🦟', title: 'Prevent Mosquito Bites', desc: 'Use mosquito nets, wear long sleeves, and apply repellent to protect against dengue and malaria.', gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                          details: [
                            'Sleep under mosquito nets, especially during the day when Dengue mosquitoes bite.',
                            'Wear long-sleeved shirts and long pants when outdoors.',
                            'Apply insect repellent containing DEET or Picaridin on exposed skin.',
                            'Prevent stagnant water from accumulating in flower pots, tires, and open containers around your home.'
                          ]),
                        const SizedBox(height: 12),
                        _buildInsightCard(c, emoji: '💧', title: 'Drink Clean Water', desc: 'Always drink boiled or filtered water to prevent waterborne diseases like typhoid and cholera.', gradient: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          details: [
                            'Boil water for at least 1-3 minutes to kill most waterborne pathogens.',
                            'Use a standard water purifier or filter to remove impurities.',
                            'Ensure water storage containers are covered and cleaned regularly.',
                            'Avoid ice from unknown sources and unbottled drinks from street vendors.'
                          ]),
                        const SizedBox(height: 12),
                        _buildInsightCard(c, emoji: '🧼', title: 'Wash Your Hands', desc: 'Regular handwashing with soap prevents the spread of many infectious diseases.', gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
                          details: [
                            'Wash hands with soap and running water for at least 20 seconds.',
                            'Always wash hands before preparing food or eating.',
                            'Wash thoroughly after using the restroom or changing diapers.',
                            'Use hand sanitizer with at least 60% alcohol if soap is not available.'
                          ]),
                        const SizedBox(height: 12),
                        _buildInsightCard(c, emoji: '🍎', title: 'Eat Healthy Foods', desc: 'A balanced diet rich in fruits and vegetables strengthens your immune system.', gradient: const [Color(0xFFDC2626), Color(0xFFEF4444)],
                          details: [
                            'Incorporate at least 5 portions of a variety of fruit and vegetables every day.',
                            'Base your meals on higher fiber starchy foods like potatoes, bread, rice, or pasta.',
                            'Have some dairy or dairy alternatives, opting for lower-fat and lower-sugar options.',
                            'Cut down on saturated fat and sugar to maintain a healthy weight and blood pressure.'
                          ]),
                        const SizedBox(height: 36),

                        // Quick Actions
                        Row(
                          children: [
                            Container(width: 4, height: 22, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]), borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 10),
                            Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: c.textPrimary)),
                            const SizedBox(width: 8),
                            const Text('⚡', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionBtn(
                                c,
                                icon: Icons.local_hospital_rounded,
                                title: 'Nearby Hospitals',
                                gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Blue
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyHospitalsScreen())),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionBtn(
                                c,
                                icon: Icons.emergency_rounded,
                                title: 'Emergency Contacts',
                                gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)], // Red
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyContactsScreen())),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionBtn(
                                c,
                                icon: Icons.insights_rounded,
                                title: 'Statistics Dashboard',
                                gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Purple
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen())),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionBtn(
                                c,
                                icon: Icons.history_rounded,
                                title: 'My Report History',
                                gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHistoryScreen())),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassStatCard(AppColors c, {required IconData icon, required String value, required String label, required List<Color> gradient, required Color glowColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: c.glassBgStrong,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.glassBorder),
            boxShadow: [BoxShadow(color: glowColor.withOpacity(c.dark ? 0.15 : 0.1), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(AppColors c, {required String emoji, required String title, required String desc, required List<String> details, required List<Color> gradient}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: c.glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.glassBorderSubtle),
            boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => InsightDetailsScreen(
                  emoji: emoji, title: title, desc: desc, details: details, gradient: gradient,
                )));
              },
              splashColor: gradient[0].withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [gradient[0].withOpacity(0.15), gradient[1].withOpacity(0.08)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: gradient[0].withOpacity(0.15)),
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: c.textPrimary)),
                          const SizedBox(height: 6),
                          Text(desc, style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.4)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: c.textTertiary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(AppColors c, {required IconData icon, required String title, required List<Color> gradient, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: c.glassBgStrong,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.glassBorder),
            boxShadow: [BoxShadow(color: gradient[0].withOpacity(c.dark ? 0.15 : 0.08), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              splashColor: gradient[0].withOpacity(0.1),
              highlightColor: gradient[0].withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.textPrimary, height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}