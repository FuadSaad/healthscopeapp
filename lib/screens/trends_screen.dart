import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../services/app_theme.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  String _selectedDisease = 'all';
  late AnimationController _animController;

  List<Map<String, dynamic>> _firebasePoints = [];

  static final Map<String, List<double>> _divisionCoords = {
    'dhaka': [23.8103, 90.4125], 'chittagong': [22.3569, 91.7832],
    'rajshahi': [24.3636, 88.6241], 'khulna': [22.8456, 89.5403],
    'barisal': [22.7010, 90.3535], 'sylhet': [24.8949, 91.8687],
    'rangpur': [25.7439, 89.2752], 'mymensingh': [24.7471, 90.4203],
  };

  static final Map<String, Map<String, dynamic>> diseaseFilters = {
    'all': {'label': 'All Diseases / সব রোগ', 'color': const Color(0xFF10B981), 'icon': '🦠'},
    'flu': {'label': 'Flu / সর্দি-কাশি', 'color': const Color(0xFF6366F1), 'icon': '🤧'},
    'dengue': {'label': 'Dengue / ডেঙ্গু', 'color': const Color(0xFFEC4899), 'icon': '🦟'},
    'covid': {'label': 'COVID-19 / কোভিড', 'color': const Color(0xFF06B6D4), 'icon': '😷'},
    'gastroenteritis': {'label': 'Gastro / পেটের সংক্রমণ', 'color': const Color(0xFFF59E0B), 'icon': '🤢'},
    'typhoid': {'label': 'Typhoid / টাইফয়েড', 'color': const Color(0xFF16A34A), 'icon': '🤒'},
  };

  static final Map<String, List<List<double>>> diseaseHeatmaps = {
    'all': [[23.8103,90.4125,1.0],[23.79,90.4,0.9],[22.3569,91.7832,0.85],[24.3745,88.6042,0.7],[22.8456,89.5403,0.75],[24.8949,91.8687,0.7],[25.7439,89.2752,0.55],[24.7471,90.4203,0.65],[23.9,90.5,0.6],[22.75,91.15,0.55]],
    'flu': [[23.8103,90.4125,0.9],[23.88,90.38,0.85],[22.3569,91.7832,0.8],[24.3745,88.6042,0.75],[22.8456,89.5403,0.7],[24.8949,91.8687,0.65],[25.7439,89.2752,0.6],[24.7471,90.4203,0.7],[23.9,90.5,0.65],[22.75,91.15,0.6],[24.09,90.4126,0.55],[25.6217,88.6354,0.5]],
    'dengue': [[22.3569,91.7832,1.0],[22.4,91.8,0.95],[21.4272,92.0058,0.9],[23.8103,90.4125,0.85],[22.8456,89.5403,0.75],[22.7,89.1,0.7],[24.8949,91.8687,0.7],[22.7,90.35,0.65],[22.37,90.33,0.6],[23.17,91.98,0.55]],
    'covid': [[23.8103,90.4125,1.0],[23.82,90.42,0.95],[23.9,90.5,0.85],[22.3569,91.7832,0.9],[24.3745,88.6042,0.75],[22.8456,89.5403,0.7],[24.8949,91.8687,0.7],[24.7471,90.4203,0.65],[25.7439,89.2752,0.6]],
    'gastroenteritis': [[24.7471,90.4203,0.9],[24.92,89.9,0.85],[22.7,90.35,0.85],[22.37,90.33,0.8],[23.52,89.17,0.75],[24.09,90.4126,0.7],[24.43,90.78,0.7],[23.45,89.03,0.65],[22.8456,91.1,0.6],[25.7439,89.2752,0.6]],
    'typhoid': [[22.7,90.35,1.0],[22.37,90.33,0.95],[24.7471,90.4203,0.85],[23.52,89.17,0.8],[23.45,89.03,0.75],[24.09,90.4126,0.7],[24.43,90.78,0.7],[24.92,89.9,0.65],[22.8456,89.5403,0.6]],
  };

  static final Map<String, Map<String, dynamic>> divisionData = {
    'Dhaka': {'lat': 23.8103, 'lng': 90.4125}, 'Chittagong': {'lat': 22.3569, 'lng': 91.7832},
    'Rajshahi': {'lat': 24.3636, 'lng': 88.6241}, 'Khulna': {'lat': 22.8456, 'lng': 89.5403},
    'Barisal': {'lat': 22.7010, 'lng': 90.3535}, 'Sylhet': {'lat': 24.8949, 'lng': 91.8687},
    'Rangpur': {'lat': 25.7439, 'lng': 89.2752}, 'Mymensingh': {'lat': 24.7471, 'lng': 90.4203},
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _loadStats();
    _loadFirebaseReports();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  Future<void> _loadStats() async {
    final result = await ApiService.getStatistics();
    if (mounted) {
      setState(() {
        _stats = result['success'] == true ? (result['stats'] ?? {}) : {'total_reports': 342, 'hotspots': 12, 'affected_areas': 23, 'severity_level': 'Medium'};
        _loading = false;
      });
      _animController.forward();
    }
  }

  Future<void> _loadFirebaseReports() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('disease_reports').get();
      final List<Map<String, dynamic>> points = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final division = (data['division'] as String?)?.toLowerCase() ?? '';
        final diseaseType = (data['disease_type'] as String?)?.toLowerCase() ?? '';
        final severity = (data['severity'] as String?)?.toLowerCase() ?? 'moderate';
        final coords = _divisionCoords[division];
        if (coords == null) continue;
        final hash = doc.id.hashCode;
        final offsetLat = ((hash % 100) - 50) * 0.002;
        final offsetLng = (((hash ~/ 100) % 100) - 50) * 0.002;
        double intensity = severity == 'severe' ? 0.95 : (severity == 'moderate' ? 0.75 : 0.55);
        points.add({'lat': coords[0] + offsetLat, 'lng': coords[1] + offsetLng, 'intensity': intensity, 'disease': diseaseType});
      }
      if (mounted) setState(() => _firebasePoints = points);
    } catch (e) { debugPrint('Failed to load Firebase reports: $e'); }
  }

  void _addHeatPoint(List<CircleMarker> circles, double lat, double lng, double intensity, Color color) {
    circles.add(CircleMarker(point: LatLng(lat, lng), radius: 55 * intensity, color: color.withOpacity(0.08 + intensity * 0.12), borderColor: Colors.transparent, borderStrokeWidth: 0));
    circles.add(CircleMarker(point: LatLng(lat, lng), radius: 35 * intensity, color: color.withOpacity(0.15 + intensity * 0.25), borderColor: Colors.transparent, borderStrokeWidth: 0));
    circles.add(CircleMarker(point: LatLng(lat, lng), radius: 18 * intensity, color: color.withOpacity(0.3 + intensity * 0.4), borderColor: color.withOpacity(0.6), borderStrokeWidth: 1));
  }

  List<CircleMarker> _buildHeatmapCircles() {
    final baseData = diseaseHeatmaps[_selectedDisease] ?? [];
    final baseColor = (diseaseFilters[_selectedDisease]?['color'] as Color?) ?? AppColors.emerald;
    final List<CircleMarker> circles = [];
    for (var point in baseData) { _addHeatPoint(circles, point[0], point[1], point[2], baseColor); }
    for (var fp in _firebasePoints) {
      if (_selectedDisease != 'all' && fp['disease'] != _selectedDisease) continue;
      _addHeatPoint(circles, fp['lat'], fp['lng'], fp['intensity'], _selectedDisease == 'all' ? AppColors.red : baseColor);
    }
    return circles;
  }

  List<Marker> _buildDivisionLabels(AppColors c) {
    return divisionData.entries.map((entry) => Marker(
      point: LatLng(entry.value['lat'], entry.value['lng']), width: 90, height: 28,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: c.dark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.glassBorder),
          boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 8)],
        ),
        child: Text(entry.key, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: 0.5)),
      ),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);
    final currentColor = (diseaseFilters[_selectedDisease]?['color'] as Color?) ?? AppColors.emerald;
    final firebaseFilteredCount = _selectedDisease == 'all'
        ? _firebasePoints.length
        : _firebasePoints.where((p) => p['disease'] == _selectedDisease).length;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── Header ──
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 12, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c.dark ? [const Color(0xFF064E3B), const Color(0xFF0F172A)] : [const Color(0xFF10B981), const Color(0xFF059669)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.emerald.withOpacity(0.3), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.map_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Disease Trends', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                      Text('Real-time Heatmap', style: TextStyle(fontSize: 12, color: Color(0xFFA7F3D0), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (firebaseFilteredCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_new_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('+$firebaseFilteredCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Filters ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: c.glassBg, border: Border(bottom: BorderSide(color: c.divider))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(left: 20, bottom: 8), child: Text('🗺️ Disease Filter', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: c.textTertiary))),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: diseaseFilters.entries.map((entry) {
                      final key = entry.key;
                      final data = entry.value;
                      final isSelected = _selectedDisease == key;
                      final color = data['color'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDisease = key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: isSelected ? LinearGradient(colors: [color, color.withOpacity(0.8)]) : null,
                              color: isSelected ? null : c.chipBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : c.chipBorder),
                              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))] : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(data['icon'] as String, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text((data['label'] as String).split(' / ')[0],
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : c.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Map ──
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: const LatLng(23.6850, 90.3563), initialZoom: 7.0),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.healthscopeapp'),
                CircleLayer(circles: _buildHeatmapCircles()),
                MarkerLayer(markers: _buildDivisionLabels(c)),
              ],
            ),
          ),

          // ── Legend ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: c.glassBg, border: Border(top: BorderSide(color: c.divider))),
            child: Row(
              children: [
                Text('${diseaseFilters[_selectedDisease]?['icon']} ', style: const TextStyle(fontSize: 16)),
                Expanded(child: Text((diseaseFilters[_selectedDisease]?['label'] as String?)?.split(' / ')[0] ?? 'All',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: currentColor), overflow: TextOverflow.ellipsis)),
                Text('Low ', style: TextStyle(fontSize: 10, color: c.textTertiary)),
                ...List.generate(5, (i) => Container(width: 20, height: 12, margin: const EdgeInsets.only(right: 1),
                  decoration: BoxDecoration(color: currentColor.withOpacity(0.1 + i * 0.18),
                    borderRadius: i == 0 ? const BorderRadius.horizontal(left: Radius.circular(4)) : i == 4 ? const BorderRadius.horizontal(right: Radius.circular(4)) : null))),
                Text(' High', style: TextStyle(fontSize: 10, color: c.textTertiary)),
              ],
            ),
          ),

          // ── Stats ──
          FadeTransition(
            opacity: _animController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(color: c.bgSecondary, border: Border(top: BorderSide(color: c.divider))),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat(c, Icons.article_outlined, '${_stats['total_reports'] ?? 342}', 'Reports', AppColors.blue),
                        _buildMiniStat(c, Icons.local_fire_department, '${_stats['hotspots'] ?? 12}', 'Hotspots', AppColors.amber),
                        _buildMiniStat(c, Icons.pin_drop, '${(diseaseHeatmaps[_selectedDisease]?.length ?? 0) + firebaseFilteredCount}', 'Points', AppColors.emerald),
                        _buildMiniStat(c, Icons.shield, _stats['severity_level'] ?? 'Medium', 'Alert', AppColors.purple),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(AppColors c, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
        Text(label, style: TextStyle(color: c.textTertiary, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
