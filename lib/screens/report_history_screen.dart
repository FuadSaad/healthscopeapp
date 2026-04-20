import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../services/app_theme.dart';
import '../services/seed_data.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory({bool autoSeed = true}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final res = await ApiService.getUserReports();
    if (mounted) {
      if (res['success'] == true) {
        final reports = List<Map<String, dynamic>>.from(res['reports']);
        
        // Auto-seed demo data if no reports exist (first time only)
        if (reports.isEmpty && autoSeed) {
          final count = await SeedData.seedUserReports();
          if (count > 0 && mounted) {
            // Re-fetch after seeding (autoSeed=false to prevent infinite loop)
            return _fetchHistory(autoSeed: false);
          }
        }
        
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res['message'];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDemoData() async {
    setState(() => _isLoading = true);
    final count = await SeedData.seedUserReports();
    if (mounted) {
      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ $count demo reports added!'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        await _fetchHistory();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('❌ Failed to load demo data'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown Date';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      return timestamp.toString();
    }
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String hour = date.hour > 12 ? (date.hour - 12).toString() : (date.hour == 0 ? '12' : date.hour.toString());
    String min = date.minute.toString().padLeft(2, '0');
    String ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]}, $hour:$min $ampm';
  }

  Color _getSeverityColor(String severity) {
    if (severity.toLowerCase() == 'high') return const Color(0xFFEF4444);
    if (severity.toLowerCase() == 'medium') return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('My Report History', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: c.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.purple))
        : _error != null
          ? _buildErrorState(c)
          : _reports.isEmpty
            ? _buildEmptyState(c)
            : RefreshIndicator(
                onRefresh: _fetchHistory,
                color: AppColors.purple,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) => _buildReportCard(c, _reports[index]),
                ),
              ),
    );
  }

  Widget _buildReportCard(AppColors c, Map<String, dynamic> report) {
    final severityColor = _getSeverityColor(report['severity'] ?? 'low');
    final diseaseType = report['disease_type'] ?? 'Unknown';
    final location = report['location']?.toString().isNotEmpty == true 
        ? report['location'] 
        : '${report['district'] ?? ''}, ${report['division'] ?? ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.divider)),
              color: c.glassBgStrong,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.coronavirus_rounded, color: severityColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(diseaseType, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.textPrimary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (report['severity'] ?? 'LOW').toUpperCase(),
                    style: TextStyle(color: severityColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_rounded, color: c.textTertiary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(location, style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.3))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.calendar_today_rounded, color: c.textTertiary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_formatDate(report['timestamp']), style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.3))),
                  ],
                ),
                if (report['symptoms'] != null && report['symptoms'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.chipBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.chipBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.textPrimary)),
                        const SizedBox(height: 4),
                        Text(report['symptoms'], style: TextStyle(color: c.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 60, color: c.textTertiary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No Reports Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textSecondary)),
          const SizedBox(height: 8),
          Text('You haven\'t submitted any disease reports.', style: TextStyle(color: c.textTertiary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDemoData,
            icon: const Icon(Icons.science_rounded),
            label: const Text('Load Demo Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 60, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text('Failed to Load History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(_error ?? 'Unknown error', textAlign: TextAlign.center, style: TextStyle(color: c.textTertiary)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          )
        ],
      ),
    );
  }
}
