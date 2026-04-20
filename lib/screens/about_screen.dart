import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/seed_data.dart';
import '../services/app_theme.dart';

class AboutScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const AboutScreen({super.key, this.onLogout});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  bool _seeding = false;
  bool _cleaning = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
            expandedHeight: 200,
            pinned: true,
            backgroundColor: c.bg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Meet The Team', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white, letterSpacing: 0.5)),
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
                  Positioned(
                    top: -40, right: -40,
                    child: Container(width: 200, height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.emerald.withOpacity(c.glowOpacity), Colors.transparent]))),
                  ),
                  Positioned(
                    bottom: -30, left: -30,
                    child: Container(width: 160, height: 160,
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(c.glowOpacity * 0.8), Colors.transparent]))),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                          boxShadow: [BoxShadow(color: AppColors.emerald.withOpacity(0.3), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.groups_rounded, size: 36, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ══════════════ Dark / Light Mode Toggle ══════════════
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: c.glassBgStrong,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.glassBorder),
                            boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 12)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: c.dark
                                        ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)]
                                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(
                                    color: (c.dark ? AppColors.purple : AppColors.amber).withOpacity(0.3),
                                    blurRadius: 10,
                                  )],
                                ),
                                child: Icon(
                                  c.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  color: Colors.white, size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.dark ? 'Dark Mode' : 'Light Mode',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: c.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.dark ? 'Easy on the eyes' : 'Bright & clean',
                                      style: TextStyle(fontSize: 12, color: c.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: c.dark,
                                  onChanged: (_) => AppTheme.toggleTheme(),
                                  activeColor: AppColors.purple,
                                  activeTrackColor: AppColors.purple.withOpacity(0.3),
                                  inactiveThumbColor: AppColors.amber,
                                  inactiveTrackColor: AppColors.amber.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Team Members
                    _buildTeamCard(c, name: 'Md. Fuad Hossain Saad', role: 'Lead Architect & Full-Stack Engineer',
                      desc: 'Designed the complete system architecture, built the Flutter mobile app, developed the AI/ML symptom prediction engine, and integrated the PHP/MySQL backend APIs.',
                      initial: 'F', gradient: const [Color(0xFF10B981), Color(0xFF059669)], isLead: true),
                    const SizedBox(height: 12),
                    _buildTeamCard(c, name: 'Mst Sumaiya Tabassum Roshni', role: 'Flutter Developer & AI Integration',
                      desc: 'Developed responsive mobile UI screens using Flutter widgets, integrated the TensorFlow-based symptom checker, and implemented the community disease reporting module.',
                      initial: 'S', gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                    const SizedBox(height: 12),
                    _buildTeamCard(c, name: 'Mehedi Hasan', role: 'Backend & Database Engineer',
                      desc: 'Built the PHP REST API services including authentication, disease report storage, and statistics aggregation. Designed the MySQL database schema.',
                      initial: 'M', gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),

                    const SizedBox(height: 24),

                    // Project Info
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: c.glassBgStrong,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.glassBorder),
                          ),
                          child: Column(children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF6EE7B7)]).createShader(bounds),
                              child: const Text('HealthScope BD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 8),
                            Text('Department of Computer Science & Engineering', style: TextStyle(color: c.textTertiary, fontSize: 13)),
                            Text('Daffodil International University', style: TextStyle(color: c.textTertiary, fontSize: 13)),
                            const SizedBox(height: 20),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                              _buildProjectStat(c, '30', 'Symptoms', AppColors.emerald),
                              _buildProjectStat(c, '13', 'Diseases', AppColors.purple),
                              _buildProjectStat(c, '8', 'Divisions', AppColors.amber),
                              _buildProjectStat(c, '5', 'Modules', AppColors.red),
                            ]),
                          ]),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Seed/Clean
                    Row(children: [
                      Expanded(child: _buildGlassButton(c, label: _seeding ? 'Seeding...' : 'Seed 100 Demo',
                        icon: _seeding ? null : Icons.cloud_upload_rounded, isLoading: _seeding,
                        gradient: [AppColors.blue, AppColors.blueDark],
                        onTap: _seeding ? null : () async {
                          setState(() => _seeding = true);
                          final count = await SeedData.seedDemoReports();
                          setState(() => _seeding = false);
                          if (mounted) {
                            String msg; Color bgColor;
                            if (count == -2) { msg = '❌ Firebase error! Check console.'; bgColor = Colors.red; }
                            else if (count == -1) { msg = '⚠️ Demo data already exists! Remove first.'; bgColor = Colors.orange; }
                            else { msg = '✅ $count demo reports added!'; bgColor = AppColors.emerald; }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bgColor,
                              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 3)));
                          }
                        })),
                      const SizedBox(width: 12),
                      Expanded(child: _buildGlassButton(c, label: _cleaning ? 'Cleaning...' : 'Remove Demo',
                        icon: _cleaning ? null : Icons.delete_outline_rounded, isLoading: _cleaning,
                        gradient: [AppColors.amberDark, const Color(0xFFB45309)],
                        onTap: _cleaning ? null : () async {
                          setState(() => _cleaning = true);
                          final count = await SeedData.removeDemoReports();
                          setState(() => _cleaning = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(count == 0 ? '⚠️ No demo data found' : '🗑️ $count demo reports removed!'), backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                          }
                        })),
                    ]),

                    const SizedBox(height: 20),

                    // Logout
                    Container(
                      width: double.infinity, height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(colors: [AppColors.red.withOpacity(0.12), AppColors.redDark.withOpacity(0.06)]),
                        border: Border.all(color: AppColors.red.withOpacity(0.25)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: c.bgSecondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text('Logout', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
                                content: Text('Are you sure you want to logout?', style: TextStyle(color: c.textSecondary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: c.textTertiary))),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700))),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              // Re-save theme preference after clearing
                              await prefs.setBool('isDarkMode', AppTheme.themeMode.value == ThemeMode.dark);
                              if (widget.onLogout != null) widget.onLogout!();
                            }
                          },
                          child: const Center(
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                              SizedBox(width: 10),
                              Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(AppColors c, {required String name, required String role, required String desc,
    required String initial, required List<Color> gradient, bool isLead = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLead ? c.glassBgStrong : c.glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isLead ? gradient[0].withOpacity(0.3) : c.glassBorderSubtle),
            boxShadow: isLead ? [BoxShadow(color: gradient[0].withOpacity(0.1), blurRadius: 20)] : [BoxShadow(color: c.cardShadow, blurRadius: 8)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 56, height: 56,
                decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 10)]),
                child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: c.textPrimary))),
                  if (isLead) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: gradient[0].withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text('LEAD', style: TextStyle(color: gradient[0], fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1))),
                ]),
                const SizedBox(height: 4),
                Text(role, style: TextStyle(color: gradient[0], fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 8),
                Text(desc, style: TextStyle(color: c.textTertiary, fontSize: 12, height: 1.4)),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectStat(AppColors c, String value, String label, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: c.textTertiary, fontSize: 11, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildGlassButton(AppColors c, {required String label, IconData? icon, bool isLoading = false,
    required List<Color> gradient, VoidCallback? onTap}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [gradient[0].withOpacity(0.15), gradient[1].withOpacity(0.08)]),
        border: Border.all(color: gradient[0].withOpacity(0.25)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: isLoading
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: gradient[0]))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (icon != null) Icon(icon, color: gradient[0], size: 18),
                    if (icon != null) const SizedBox(width: 6),
                    Text(label, style: TextStyle(color: gradient[0], fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
          ),
        ),
      ),
    );
  }
}
