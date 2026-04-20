import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedDisease;
  String _selectedSeverity = 'moderate';
  String? _selectedDivision;
  String? _selectedDistrict;
  final _locationController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _additionalController = TextEditingController();
  bool _submitting = false;

  static const Map<String, List<String>> divisions = {
    'dhaka': ['Dhaka', 'Gazipur', 'Narayanganj', 'Tangail', 'Kishoreganj', 'Manikganj'],
    'chittagong': ['Chittagong', "Cox's Bazar", 'Rangamati', 'Comilla', 'Feni'],
    'rajshahi': ['Rajshahi', 'Natore', 'Naogaon', 'Bogra', 'Pabna'],
    'khulna': ['Khulna', 'Bagerhat', 'Satkhira', 'Jessore'],
    'barisal': ['Barisal', 'Patuakhali', 'Barguna', 'Bhola'],
    'sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'],
    'rangpur': ['Rangpur', 'Dinajpur', 'Gaibandha', 'Kurigram'],
    'mymensingh': ['Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'],
  };

  static const Map<String, Map<String, dynamic>> diseaseOptions = {
    'flu': {'label': 'Seasonal Flu', 'icon': '🤧', 'color': Color(0xFF6366F1)},
    'dengue': {'label': 'Dengue Fever', 'icon': '🦟', 'color': Color(0xFFEC4899)},
    'covid': {'label': 'COVID-19', 'icon': '😷', 'color': Color(0xFF06B6D4)},
    'gastroenteritis': {'label': 'Gastroenteritis', 'icon': '🤢', 'color': Color(0xFFF59E0B)},
    'typhoid': {'label': 'Typhoid', 'icon': '🤒', 'color': Color(0xFF16A34A)},
    'chickenpox': {'label': 'Chickenpox', 'icon': '😣', 'color': Color(0xFFEF4444)},
    'other': {'label': 'Other', 'icon': '🏥', 'color': Color(0xFF64748B)},
  };

  @override
  void dispose() {
    _locationController.dispose();
    _symptomsController.dispose();
    _additionalController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedDisease == null || _selectedDivision == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please fill all required fields'), backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _submitting = true);
    final result = await ApiService.saveDiseaseReport(
      diseaseType: _selectedDisease!, severity: _selectedSeverity,
      division: _selectedDivision!, district: _selectedDistrict!,
      location: _locationController.text, symptoms: _symptomsController.text,
      additionalInfo: _additionalController.text,
    );
    setState(() => _submitting = false);
    if (mounted) {
      if (result['success'] == true) {
        final updatedStats = await ApiService.getStatistics();
        final totalReports = updatedStats['stats']?['total_reports'] ?? '?';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('✅ Report submitted! Total reports: $totalReports'), backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
        setState(() { _selectedDisease = null; _selectedDivision = null; _selectedDistrict = null;
          _locationController.clear(); _symptomsController.clear(); _additionalController.clear(); });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ ${result['message']}'), backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
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
                colors: c.dark ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)] : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.3), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.assignment_add, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report a Disease', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                    Text('Help your community', style: TextStyle(fontSize: 12, color: Color(0xFFFECACA), fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),

          // ── Form ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(c, '🦠', 'Disease Type', required: true),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.2,
                    children: diseaseOptions.entries.map((e) {
                      final isSelected = _selectedDisease == e.key;
                      final data = e.value;
                      final color = data['color'] as Color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDisease = e.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: isSelected ? LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.08)]) : null,
                            color: isSelected ? null : c.chipBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? color.withOpacity(0.5) : c.chipBorder, width: isSelected ? 2 : 1),
                            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 12)] : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data['icon'] as String, style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 6),
                              Text(data['label'] as String, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected ? color : c.textSecondary), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionLabel(c, '⚡', 'Severity Level', required: true),
                  const SizedBox(height: 12),
                  Row(children: [
                    _buildSeverityOption(c, 'mild', '😊', 'Mild', AppColors.emerald),
                    const SizedBox(width: 10),
                    _buildSeverityOption(c, 'moderate', '😐', 'Moderate', AppColors.amber),
                    const SizedBox(width: 10),
                    _buildSeverityOption(c, 'severe', '🤒', 'Severe', AppColors.red),
                  ]),
                  const SizedBox(height: 24),

                  _buildSectionLabel(c, '📍', 'Division', required: true),
                  const SizedBox(height: 12),
                  _buildGlassDropdown<String>(c, value: _selectedDivision, hint: 'Select division',
                    items: divisions.keys.map((d) => DropdownMenuItem(value: d, child: Text(d[0].toUpperCase() + d.substring(1), style: TextStyle(color: c.textPrimary)))).toList(),
                    onChanged: (v) => setState(() { _selectedDivision = v; _selectedDistrict = null; })),
                  const SizedBox(height: 16),

                  _buildSectionLabel(c, '🏢', 'District', required: true),
                  const SizedBox(height: 12),
                  _buildGlassDropdown<String>(c, value: _selectedDistrict, hint: 'Select district',
                    items: (_selectedDivision != null ? divisions[_selectedDivision]! : <String>[])
                        .map((d) => DropdownMenuItem(value: d, child: Text(d, style: TextStyle(color: c.textPrimary)))).toList(),
                    onChanged: (v) => setState(() => _selectedDistrict = v)),
                  const SizedBox(height: 16),

                  _buildSectionLabel(c, '📌', 'Specific Location'),
                  const SizedBox(height: 12),
                  _buildGlassTextField(c, controller: _locationController, hint: 'e.g., Mirpur, Sector 10', icon: Icons.location_on_outlined),
                  const SizedBox(height: 16),

                  _buildSectionLabel(c, '🩺', 'Symptoms Observed'),
                  const SizedBox(height: 12),
                  _buildGlassTextField(c, controller: _symptomsController, hint: 'Describe the symptoms...', maxLines: 2),
                  const SizedBox(height: 16),

                  _buildSectionLabel(c, '📝', 'Additional Information'),
                  const SizedBox(height: 12),
                  _buildGlassTextField(c, controller: _additionalController, hint: 'Any other relevant details...', maxLines: 2),
                  const SizedBox(height: 28),

                  // Submit
                  Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                      boxShadow: [BoxShadow(color: AppColors.emerald.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _submitting ? null : _submitReport,
                        child: Center(
                          child: _submitting
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                              : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.send_rounded, color: Colors.white, size: 20), SizedBox(width: 10),
                                  Text('Submit Report', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
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
        ],
      ),
    );
  }

  Widget _buildSectionLabel(AppColors c, String emoji, String text, {bool required = false}) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 16)), const SizedBox(width: 8),
      Text(text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: c.textPrimary)),
      if (required) Text(' *', style: TextStyle(color: AppColors.red.withOpacity(0.7), fontWeight: FontWeight.w800)),
    ]);
  }

  Widget _buildSeverityOption(AppColors c, String value, String emoji, String label, Color color) {
    bool isSelected = _selectedSeverity == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSeverity = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.08)]) : null,
            color: isSelected ? null : c.chipBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? color.withOpacity(0.5) : c.chipBorder, width: isSelected ? 2 : 1),
            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 10)] : [],
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)), const SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, fontSize: 13,
              color: isSelected ? color : c.textSecondary)),
          ]),
        ),
      ),
    );
  }

  Widget _buildGlassDropdown<T>(AppColors c, {required T? value, required String hint, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: c.inputBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.glassBorderSubtle)),
          child: DropdownButtonFormField<T>(
            value: value, dropdownColor: c.dropdownBg,
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: c.inputHint),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            items: items, onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down, color: c.textTertiary),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField(AppColors c, {required TextEditingController controller, required String hint, IconData? icon, int maxLines = 1}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: c.inputBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.glassBorderSubtle)),
          child: TextField(
            controller: controller, maxLines: maxLines, style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: c.inputHint),
              prefixIcon: icon != null ? Icon(icon, color: c.textTertiary) : null,
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
          ),
        ),
      ),
    );
  }
}
