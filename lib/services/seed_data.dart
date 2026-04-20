import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// One-time seed script to populate Firebase with 100 demo disease reports
/// for testing the heatmap and statistics features.
class SeedData {
  static final _firestore = FirebaseFirestore.instance;
  static final _random = Random();

  static const List<String> _divisions = [
    'dhaka', 'chittagong', 'rajshahi', 'khulna',
    'barisal', 'sylhet', 'rangpur', 'mymensingh',
  ];

  static const Map<String, List<String>> _districts = {
    'dhaka': ['Dhaka', 'Gazipur', 'Narayanganj', 'Tangail', 'Kishoreganj', 'Manikganj'],
    'chittagong': ['Chittagong', "Cox's Bazar", 'Rangamati', 'Comilla', 'Feni'],
    'rajshahi': ['Rajshahi', 'Natore', 'Naogaon', 'Bogra', 'Pabna'],
    'khulna': ['Khulna', 'Bagerhat', 'Satkhira', 'Jessore'],
    'barisal': ['Barisal', 'Patuakhali', 'Barguna', 'Bhola'],
    'sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'],
    'rangpur': ['Rangpur', 'Dinajpur', 'Gaibandha', 'Kurigram'],
    'mymensingh': ['Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'],
  };

  static const List<String> _diseaseTypes = [
    'flu', 'dengue', 'covid', 'gastroenteritis', 'typhoid', 'chickenpox',
  ];

  static const List<int> _diseaseWeights = [25, 25, 15, 15, 12, 8];

  static const Map<String, String> _symptomsByDisease = {
    'flu': 'Fever, cough, headache, body ache, sore throat',
    'dengue': 'High fever, severe headache, rash, joint pain, bleeding gums',
    'covid': 'Fever, dry cough, loss of taste/smell, fatigue, shortness of breath',
    'gastroenteritis': 'Nausea, vomiting, diarrhea, abdominal pain, dehydration',
    'typhoid': 'Prolonged fever, headache, abdominal pain, loss of appetite',
    'chickenpox': 'Itchy rash, fever, blisters, fatigue, loss of appetite',
  };

  static String _pickDisease() {
    final totalWeight = _diseaseWeights.reduce((a, b) => a + b);
    var roll = _random.nextInt(totalWeight);
    for (int i = 0; i < _diseaseTypes.length; i++) {
      roll -= _diseaseWeights[i];
      if (roll < 0) return _diseaseTypes[i];
    }
    return _diseaseTypes[0];
  }

  /// Generate 100 demo disease reports and save to Firebase.
  /// Returns -1 if demo data already exists, or the count of reports added.
  static Future<int> seedDemoReports() async {
    try {
      debugPrint('🌱 SeedData: Checking if demo data already exists...');

      // Check if demo data already exists
      final existing = await _firestore
          .collection('disease_reports')
          .where('is_demo', isEqualTo: true)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint('⚠️ SeedData: Demo data already exists (${existing.docs.length}+ docs). Returning -1.');
        return -1;
      }

      debugPrint('🌱 SeedData: No existing demo data. Creating 100 reports...');

      final now = DateTime.now();

      // Firestore batches are limited to 500 writes, 100 is fine
      final batch = _firestore.batch();

      for (int i = 0; i < 100; i++) {
        final disease = _pickDisease();
        final division = _divisions[_random.nextInt(_divisions.length)];
        final districtList = _districts[division]!;
        final district = districtList[_random.nextInt(districtList.length)];

        // Pick severity based on disease
        String severity;
        final roll = _random.nextDouble();
        if (disease == 'dengue' || disease == 'covid' || disease == 'typhoid') {
          severity = roll < 0.3 ? 'severe' : (roll < 0.7 ? 'moderate' : 'mild');
        } else {
          severity = roll < 0.1 ? 'severe' : (roll < 0.5 ? 'moderate' : 'mild');
        }

        // Spread reports over last 30 days
        final daysAgo = _random.nextInt(30);
        final hoursAgo = _random.nextInt(24);
        final reportTime = now.subtract(Duration(days: daysAgo, hours: hoursAgo));

        final ref = _firestore.collection('disease_reports').doc();
        batch.set(ref, {
          'user_id': 'demo_user_${_random.nextInt(50)}',
          'disease_type': disease,
          'severity': severity,
          'division': division,
          'district': district,
          'location': '$district area ${_random.nextInt(20) + 1}',
          'symptoms': _symptomsByDisease[disease] ?? 'General symptoms',
          'additional_info': 'Demo report #${i + 1}',
          'latitude': null,
          'longitude': null,
          'timestamp': Timestamp.fromDate(reportTime),
          'is_demo': true,
        });
      }

      debugPrint('🌱 SeedData: Committing batch of 100 reports to Firebase...');
      await batch.commit();
      debugPrint('✅ SeedData: Successfully seeded 100 demo reports!');
      return 100;
    } catch (e, stack) {
      debugPrint('❌ SeedData: FAILED to seed demo reports: $e');
      debugPrint('Stack trace: $stack');
      return -2; // Error code
    }
  }

  /// Remove all demo data (cleanup)
  static Future<int> removeDemoReports() async {
    try {
      debugPrint('🗑️ SeedData: Looking for demo reports to remove...');
      final snapshot = await _firestore
          .collection('disease_reports')
          .where('is_demo', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ SeedData: No demo data found to remove.');
        return 0;
      }

      debugPrint('🗑️ SeedData: Found ${snapshot.docs.length} demo reports. Deleting...');
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('✅ SeedData: Removed ${snapshot.docs.length} demo reports.');
      return snapshot.docs.length;
    } catch (e, stack) {
      debugPrint('❌ SeedData: FAILED to remove demo reports: $e');
      debugPrint('Stack trace: $stack');
      return -1;
    }
  }

  /// Seed 10 demo reports for the CURRENT logged-in user.
  /// These will appear in "My Report History".
  static Future<int> seedUserReports() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ SeedData: No logged-in user found.');
        return -1;
      }

      final uid = user.uid;
      debugPrint('🌱 SeedData: Creating 10 personal reports for user: $uid');

      final now = DateTime.now();
      final batch = _firestore.batch();

      final personalReports = [
        {'disease': 'dengue', 'severity': 'severe', 'division': 'dhaka', 'district': 'Dhaka', 'symptoms': 'High fever, severe headache, rash, joint pain', 'days': 2},
        {'disease': 'flu', 'severity': 'mild', 'division': 'dhaka', 'district': 'Gazipur', 'symptoms': 'Fever, cough, runny nose, body ache', 'days': 5},
        {'disease': 'covid', 'severity': 'moderate', 'division': 'chittagong', 'district': 'Chittagong', 'symptoms': 'Fever, dry cough, loss of taste, fatigue', 'days': 8},
        {'disease': 'gastroenteritis', 'severity': 'moderate', 'division': 'sylhet', 'district': 'Sylhet', 'symptoms': 'Nausea, vomiting, diarrhea, abdominal pain', 'days': 12},
        {'disease': 'typhoid', 'severity': 'severe', 'division': 'rajshahi', 'district': 'Rajshahi', 'symptoms': 'Prolonged fever, headache, abdominal pain, loss of appetite', 'days': 15},
        {'disease': 'flu', 'severity': 'moderate', 'division': 'khulna', 'district': 'Khulna', 'symptoms': 'Fever, sore throat, body ache, fatigue', 'days': 18},
        {'disease': 'dengue', 'severity': 'moderate', 'division': 'chittagong', 'district': "Cox's Bazar", 'symptoms': 'High fever, rash, joint pain, bleeding gums', 'days': 20},
        {'disease': 'chickenpox', 'severity': 'mild', 'division': 'mymensingh', 'district': 'Mymensingh', 'symptoms': 'Itchy rash, fever, blisters, fatigue', 'days': 22},
        {'disease': 'covid', 'severity': 'mild', 'division': 'rangpur', 'district': 'Rangpur', 'symptoms': 'Mild cough, fatigue, loss of smell', 'days': 25},
        {'disease': 'flu', 'severity': 'severe', 'division': 'barisal', 'district': 'Barisal', 'symptoms': 'High fever, severe cough, chest pain, chills', 'days': 28},
      ];

      for (var r in personalReports) {
        final ref = _firestore.collection('disease_reports').doc();
        batch.set(ref, {
          'user_id': uid,
          'disease_type': r['disease'],
          'severity': r['severity'],
          'division': r['division'],
          'district': r['district'],
          'location': '${r['district']} area',
          'symptoms': r['symptoms'],
          'additional_info': 'Personal report',
          'latitude': null,
          'longitude': null,
          'timestamp': Timestamp.fromDate(now.subtract(Duration(days: r['days'] as int))),
          'is_demo': true,
        });
      }

      await batch.commit();
      debugPrint('✅ SeedData: Seeded 10 personal reports for user $uid');
      return 10;
    } catch (e, stack) {
      debugPrint('❌ SeedData: FAILED to seed user reports: $e');
      debugPrint('Stack trace: $stack');
      return -2;
    }
  }
}
