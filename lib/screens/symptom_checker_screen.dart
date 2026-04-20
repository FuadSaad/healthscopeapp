import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/symptom_predictor.dart';
import '../services/api_service.dart';
import '../services/app_theme.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> with SingleTickerProviderStateMixin {
  final List<String> _selectedSymptomIds = [];
  List<Map<String, dynamic>> _results = [];
  bool _hasEmergency = false;
  bool _showResults = false;
  String _searchQuery = '';
  late AnimationController _resultAnimController;
  late Animation<double> _resultFadeAnim;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _resultFadeAnim = CurvedAnimation(parent: _resultAnimController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    super.dispose();
  }

  void _toggleSymptom(String id) {
    setState(() {
      if (_selectedSymptomIds.contains(id)) {
        _selectedSymptomIds.remove(id);
      } else {
        _selectedSymptomIds.add(id);
      }
      _showResults = false;
    });
  }

  void _analyzeSymptoms() {
    if (_selectedSymptomIds.isEmpty) return;
    setState(() {
      _results = SymptomPredictor.predict(_selectedSymptomIds);
      _hasEmergency = SymptomPredictor.hasEmergencySymptoms(_selectedSymptomIds);
      _showResults = true;
    });
    _resultAnimController.reset();
    _resultAnimController.forward();

    if (_results.isNotEmpty) {
      ApiService.saveSymptomCheck(
        symptoms: _selectedSymptomIds,
        predictedDisease: _results.first['name'],
        severity: _results.first['triage'],
        recommendations: (_results.first['recommendations'] as List).join('; '),
      );
    }
  }

  Color _getTriageColor(String triage) {
    switch (triage) {
      case 'emergency': return AppColors.red;
      case 'high': return const Color(0xFFF97316);
      case 'medium': return AppColors.amber;
      default: return AppColors.emerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);
    final categories = SymptomPredictor.getSymptomsByCategory();

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── Premium Header ──
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 16, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c.dark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                    : [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Symptom Checker', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                    Text('Powered by ML Engine', style: TextStyle(fontSize: 12, color: Color(0xFFD8B4FE), fontWeight: FontWeight.w500)),
                  ],
                ),
                const Spacer(),
                if (_selectedSymptomIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${_selectedSymptomIds.length} selected',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // ── Selected Symptoms Strip ──
          if (_selectedSymptomIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(c.dark ? 0.06 : 0.05),
                border: Border(bottom: BorderSide(color: c.divider)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedSymptomIds.map((id) {
                  final allSymptoms = categories.values.expand((list) => list).toList();
                  final symptom = allSymptoms.firstWhere((s) => s['id'] == id, orElse: () => {'id': id, 'name': id});
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.emerald.withOpacity(0.2), blurRadius: 8)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(symptom['name']!.split(' / ')[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _toggleSymptom(id),
                          child: const Icon(Icons.close, color: Colors.white70, size: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.inputBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.glassBorderSubtle),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    style: TextStyle(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search symptoms...',
                      hintStyle: TextStyle(color: c.inputHint),
                      prefixIcon: Icon(Icons.search, color: c.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──
          Expanded(
            child: _showResults
                ? FadeTransition(opacity: _resultFadeAnim, child: _buildResults(c))
                : _buildSymptomList(c, categories),
          ),

          // ── Analyze Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: c.bg,
              border: Border(top: BorderSide(color: c.divider)),
            ),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: _selectedSymptomIds.isEmpty
                      ? [c.chipBg, c.chipBg]
                      : _showResults
                          ? [c.bgSecondary, c.bgSecondary]
                          : [AppColors.purple, AppColors.purpleDark],
                ),
                boxShadow: _selectedSymptomIds.isNotEmpty && !_showResults
                    ? [BoxShadow(color: AppColors.purple.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]
                    : [],
                border: _showResults ? Border.all(color: c.cardBorder) : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _selectedSymptomIds.isEmpty ? null : _showResults ? () => setState(() => _showResults = false) : _analyzeSymptoms,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_showResults ? Icons.arrow_back_rounded : Icons.auto_awesome,
                            color: _showResults ? c.textPrimary : Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          _showResults ? 'Back to Symptoms' : 'Analyze Symptoms (${_selectedSymptomIds.length})',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _showResults ? c.textPrimary : Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomList(AppColors c, Map<String, List<Map<String, String>>> categories) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: categories.entries.map((entry) {
        final filteredSymptoms = entry.value.where((s) {
          if (_searchQuery.isEmpty) return true;
          return s['name']!.toLowerCase().contains(_searchQuery);
        }).toList();
        if (filteredSymptoms.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Text(entry.key, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.textPrimary)),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredSymptoms.map((s) {
                final isSelected = _selectedSymptomIds.contains(s['id']);
                return GestureDetector(
                  onTap: () => _toggleSymptom(s['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: isSelected ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]) : null,
                      color: isSelected ? null : c.chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : c.chipBorder),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.emerald.withOpacity(0.2), blurRadius: 10)] : [],
                    ),
                    child: Text(
                      s['name']!,
                      style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : c.textSecondary),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildResults(AppColors c) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        if (_hasEmergency)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.red.withOpacity(0.12), AppColors.redDark.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.warning_amber, color: Color(0xFFEF4444), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🚨 Emergency Warning', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFEF4444), fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Critical symptoms detected. Seek immediate medical attention.', style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            Container(width: 4, height: 22, decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 10),
            Text('AI Analysis Results', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: c.textPrimary)),
            const SizedBox(width: 8),
            const Text('🧬', style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 16),

        ..._results.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          final color = _getTriageColor(result['triage']);
          final isTop = index == 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isTop ? c.glassBgStrong : c.glassBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isTop ? color.withOpacity(0.3) : c.cardBorder),
              boxShadow: isTop ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)] : [BoxShadow(color: c.cardShadow, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withOpacity(0.08), Colors.transparent]),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      if (isTop)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text('#${index + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                      Expanded(child: Text(result['name'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: isTop ? 18 : 16, color: c.textPrimary))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
                        ),
                        child: Text('${result['confidence']}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(result['description'], style: TextStyle(color: c.textSecondary, fontSize: 13)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recommendations', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.textSecondary)),
                      const SizedBox(height: 8),
                      ...List<String>.from(result['recommendations']).map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(3))),
                              const SizedBox(width: 10),
                              Expanded(child: Text(r, style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.4))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
