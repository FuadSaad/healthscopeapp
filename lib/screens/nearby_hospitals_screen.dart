import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_theme.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  String _selectedDivision = 'dhaka';

  static const Map<String, List<Map<String, String>>> hospitals = {
    'dhaka': [
      {'name': 'Dhaka Medical College Hospital', 'type': 'Government', 'address': 'Secretariat Rd, Dhaka 1000', 'phone': '+880-2-55165088', 'lat': '23.7260', 'lng': '90.3978', 'beds': '2600', 'emergency': 'Yes'},
      {'name': 'Square Hospital', 'type': 'Private', 'address': '18/F Bir Uttam Qazi Nuruzzaman Sarak, Dhaka', 'phone': '+880-2-8159457', 'lat': '23.7520', 'lng': '90.3816', 'beds': '400', 'emergency': 'Yes'},
      {'name': 'United Hospital', 'type': 'Private', 'address': 'Plot 15, Rd 71, Gulshan, Dhaka', 'phone': '+880-2-8836000', 'lat': '23.7950', 'lng': '90.4142', 'beds': '450', 'emergency': 'Yes'},
      {'name': 'Bangabandhu Sheikh Mujib Medical University', 'type': 'Government', 'address': 'Shahbag, Dhaka 1000', 'phone': '+880-2-9661051', 'lat': '23.7386', 'lng': '90.3963', 'beds': '1800', 'emergency': 'Yes'},
      {'name': 'Labaid Hospital', 'type': 'Private', 'address': 'House 1, Rd 4, Dhanmondi, Dhaka', 'phone': '+880-2-9116551', 'lat': '23.7427', 'lng': '90.3738', 'beds': '220', 'emergency': 'Yes'},
      {'name': 'Popular Medical College Hospital', 'type': 'Private', 'address': 'Dhanmondi, Dhaka', 'phone': '+880-2-9116891', 'lat': '23.7465', 'lng': '90.3745', 'beds': '300', 'emergency': 'Yes'},
      {'name': 'National Heart Foundation', 'type': 'Semi-Private', 'address': 'Plot 7/2, Mirpur, Dhaka', 'phone': '+880-2-9006801', 'lat': '23.7968', 'lng': '90.3544', 'beds': '350', 'emergency': 'Yes'},
    ],
    'chittagong': [
      {'name': 'Chittagong Medical College Hospital', 'type': 'Government', 'address': 'K.B. Fazlul Kader Rd, Chittagong', 'phone': '+880-31-630335', 'lat': '22.3593', 'lng': '91.8315', 'beds': '1920', 'emergency': 'Yes'},
      {'name': 'Chevron Clinical Lab & Hospital', 'type': 'Private', 'address': 'O.R. Nizam Rd, Chittagong', 'phone': '+880-31-651271', 'lat': '22.3475', 'lng': '91.8123', 'beds': '150', 'emergency': 'Yes'},
      {'name': 'Parkview Hospital', 'type': 'Private', 'address': 'Mehedibag, Chittagong', 'phone': '+880-31-620201', 'lat': '22.3530', 'lng': '91.8250', 'beds': '200', 'emergency': 'Yes'},
    ],
    'rajshahi': [
      {'name': 'Rajshahi Medical College Hospital', 'type': 'Government', 'address': 'Medical College Rd, Rajshahi', 'phone': '+880-721-772150', 'lat': '24.3721', 'lng': '88.5914', 'beds': '1400', 'emergency': 'Yes'},
      {'name': 'Islami Bank Hospital', 'type': 'Private', 'address': 'Rajshahi', 'phone': '+880-721-775312', 'lat': '24.3669', 'lng': '88.6050', 'beds': '200', 'emergency': 'Yes'},
    ],
    'khulna': [
      {'name': 'Khulna Medical College Hospital', 'type': 'Government', 'address': 'KDA Ave, Khulna', 'phone': '+880-41-723701', 'lat': '22.8123', 'lng': '89.5373', 'beds': '1100', 'emergency': 'Yes'},
      {'name': 'Gazi Medical College Hospital', 'type': 'Private', 'address': 'Khulna', 'phone': '+880-41-731234', 'lat': '22.8200', 'lng': '89.5500', 'beds': '300', 'emergency': 'Yes'},
    ],
    'barisal': [
      {'name': 'Sher-e-Bangla Medical College Hospital', 'type': 'Government', 'address': 'Barisal', 'phone': '+880-431-63051', 'lat': '22.7043', 'lng': '90.3587', 'beds': '800', 'emergency': 'Yes'},
    ],
    'sylhet': [
      {'name': 'Sylhet MAG Osmani Medical College Hospital', 'type': 'Government', 'address': 'Medical College Rd, Sylhet', 'phone': '+880-821-714234', 'lat': '24.8978', 'lng': '91.8714', 'beds': '1200', 'emergency': 'Yes'},
      {'name': 'Mount Adora Hospital', 'type': 'Private', 'address': 'Zindabazar, Sylhet', 'phone': '+880-821-721010', 'lat': '24.8940', 'lng': '91.8680', 'beds': '200', 'emergency': 'Yes'},
    ],
    'rangpur': [
      {'name': 'Rangpur Medical College Hospital', 'type': 'Government', 'address': 'Medical College Rd, Rangpur', 'phone': '+880-521-63400', 'lat': '25.7505', 'lng': '89.2445', 'beds': '1000', 'emergency': 'Yes'},
    ],
    'mymensingh': [
      {'name': 'Mymensingh Medical College Hospital', 'type': 'Government', 'address': 'Mymensingh', 'phone': '+880-91-66110', 'lat': '24.7536', 'lng': '90.4032', 'beds': '1550', 'emergency': 'Yes'},
      {'name': 'Community Based Medical College Hospital', 'type': 'Private', 'address': 'Mymensingh', 'phone': '+880-91-67890', 'lat': '24.7470', 'lng': '90.4180', 'beds': '250', 'emergency': 'Yes'},
    ],
  };

  static const Map<String, String> divisionLabels = {
    'dhaka': '🏢 Dhaka / ঢাকা',
    'chittagong': '⛵ Chittagong / চট্টগ্রাম',
    'rajshahi': '🌾 Rajshahi / রাজশাহী',
    'khulna': '🌳 Khulna / খুলনা',
    'barisal': '🚤 Barisal / বরিশাল',
    'sylhet': '🍃 Sylhet / সিলেট',
    'rangpur': '🌿 Rangpur / রংপুর',
    'mymensingh': '🏞️ Mymensingh / ময়মনসিংহ',
  };

  void _openInMaps(String lat, String lng, String name) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);
    final hospitalList = hospitals[_selectedDivision] ?? [];

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
                    ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                    : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.3), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nearby Hospitals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                          Text('Find hospitals near you', style: TextStyle(fontSize: 12, color: Color(0xFFBFDBFE), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Division Filter ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: c.glassBg, border: Border(bottom: BorderSide(color: c.divider))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Text('📍 Select Division', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: c.textTertiary)),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: divisionLabels.entries.map((entry) {
                      final isSelected = _selectedDivision == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDivision = entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: isSelected ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]) : null,
                              color: isSelected ? null : c.chipBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : c.chipBorder),
                              boxShadow: isSelected ? [BoxShadow(color: AppColors.blue.withOpacity(0.3), blurRadius: 10)] : [],
                            ),
                            child: Text(
                              entry.value.split(' / ')[0],
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : c.textSecondary),
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

          // ── Hospital List ──
          Expanded(
            child: hospitalList.isEmpty
                ? Center(child: Text('No hospitals found for this division', style: TextStyle(color: c.textTertiary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: hospitalList.length,
                    itemBuilder: (context, index) {
                      final h = hospitalList[index];
                      final isGovt = h['type'] == 'Government';
                      final typeColor = isGovt ? AppColors.emerald : AppColors.purple;

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: c.glassBgStrong,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: c.glassBorderSubtle),
                              boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 10)],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [typeColor.withOpacity(0.15), typeColor.withOpacity(0.05)]),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: typeColor.withOpacity(0.2)),
                                        ),
                                        child: Icon(Icons.local_hospital_rounded, color: typeColor, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(h['name']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: c.textPrimary)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                                  child: Text(h['type']!, style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.w700)),
                                                ),
                                                const SizedBox(width: 8),
                                                if (h['emergency'] == 'Yes')
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(color: AppColors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                                    child: const Text('🚑 24/7', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w700)),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, size: 14, color: c.textTertiary),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(h['address']!, style: TextStyle(fontSize: 12, color: c.textSecondary))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.bed_outlined, size: 14, color: c.textTertiary),
                                      const SizedBox(width: 4),
                                      Text('${h['beds']} beds', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionBtn(c, icon: Icons.phone_rounded, label: 'Call', color: AppColors.emerald,
                                          onTap: () => _callPhone(h['phone']!)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildActionBtn(c, icon: Icons.map_rounded, label: 'Directions', color: AppColors.blue,
                                          onTap: () => _openInMaps(h['lat']!, h['lng']!, h['name']!)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(AppColors c, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [color.withOpacity(0.12), color.withOpacity(0.06)]),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
