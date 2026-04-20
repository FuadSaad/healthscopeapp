import 'dart:math';

/// Dart port of the TensorFlow.js symptom prediction model.
/// Uses the same training data and a simple scoring algorithm
/// to predict diseases from selected symptoms — no TFLite needed.
class SymptomPredictor {
  static const Map<String, int> symptomIndex = {
    'fever': 0, 'cough': 1, 'headache': 2, 'fatigue': 3, 'body_ache': 4,
    'sore_throat': 5, 'shortness_of_breath': 6, 'chest_pain': 7, 'wheezing': 8,
    'runny_nose': 9, 'nausea': 10, 'vomiting': 11, 'diarrhea': 12,
    'abdominal_pain': 13, 'loss_of_appetite': 14, 'rash': 15, 'joint_pain': 16,
    'chills': 17, 'dizziness': 18, 'sweating': 19,
    'muscle_pain': 20, 'sneezing': 21, 'nasal_congestion': 22,
    'loss_of_taste': 23, 'loss_of_smell': 24, 'eye_redness': 25,
    'skin_itching': 26, 'back_pain': 27, 'high_fever': 28, 'bleeding': 29,
  };

  static const List<String> emergencySymptoms = [
    'shortness_of_breath', 'chest_pain', 'high_fever', 'bleeding'
  ];

  // Disease definitions with weighted symptom scoring — matches the website's algorithm
  static const List<Map<String, dynamic>> diseases = [
    {
      'id': 0, 'name': 'Seasonal Flu', 'prior': 1.0, 'triage': 'low',
      'description': 'A contagious viral infection affecting the respiratory system',
      'recommendations': ['Get plenty of rest', 'Stay hydrated with water and warm fluids', 'Take over-the-counter pain relievers if needed', 'Monitor your symptoms and seek medical care if they worsen'],
      'symptoms': {'fever': 1.5, 'cough': 1.2, 'headache': 1.0, 'fatigue': 1.0, 'body_ache': 1.2, 'sore_throat': 1.0, 'runny_nose': 0.6, 'muscle_pain': 1.0, 'chills': 0.8, 'sneezing': 0.5},
    },
    {
      'id': 1, 'name': 'Common Cold', 'prior': 0.9, 'triage': 'low',
      'description': 'A mild viral infection of the upper respiratory tract',
      'recommendations': ['Rest and stay well hydrated', 'Use saline nasal drops for congestion', 'Gargle with warm salt water for sore throat', 'Recovery usually occurs within 7-10 days'],
      'symptoms': {'runny_nose': 1.4, 'sore_throat': 1.0, 'cough': 0.8, 'headache': 0.6, 'fever': 0.5, 'fatigue': 0.4, 'sneezing': 1.2, 'nasal_congestion': 1.3},
    },
    {
      'id': 2, 'name': 'COVID-19', 'prior': 1.0, 'triage': 'high',
      'description': 'A respiratory illness caused by SARS-CoV-2',
      'recommendations': ['Isolate yourself from others immediately', 'Get tested for COVID-19', 'Monitor oxygen levels if possible', 'Seek medical care if breathing difficulty worsens'],
      'symptoms': {'fever': 1.6, 'cough': 1.4, 'shortness_of_breath': 1.6, 'fatigue': 1.0, 'headache': 0.8, 'loss_of_taste': 1.8, 'loss_of_smell': 1.8, 'body_ache': 0.8},
    },
    {
      'id': 3, 'name': 'Pneumonia', 'prior': 0.9, 'triage': 'high',
      'description': 'An infection that inflames air sacs in the lungs',
      'recommendations': ['Seek immediate medical attention', 'Get a chest X-ray and proper diagnosis', 'Antibiotics may be needed if bacterial', 'Stay hydrated and rest'],
      'symptoms': {'fever': 1.4, 'cough': 1.4, 'shortness_of_breath': 2.0, 'chest_pain': 1.8, 'wheezing': 1.0, 'chills': 0.8, 'fatigue': 0.6},
    },
    {
      'id': 4, 'name': 'Bronchitis', 'prior': 0.7, 'triage': 'medium',
      'description': 'Inflammation of the bronchial tubes carrying air to lungs',
      'recommendations': ['Rest and drink plenty of fluids', 'Use a humidifier', 'Avoid lung irritants like smoke', 'See a doctor if symptoms persist beyond 3 weeks'],
      'symptoms': {'cough': 1.6, 'wheezing': 1.0, 'shortness_of_breath': 1.2, 'fever': 0.8, 'fatigue': 0.6, 'chest_pain': 0.6},
    },
    {
      'id': 5, 'name': 'Gastroenteritis', 'prior': 1.0, 'triage': 'medium',
      'description': 'Stomach and intestinal infection, often from contaminated food',
      'recommendations': ['Stay hydrated with oral rehydration solution', 'Rest your stomach - eat bland foods when ready', 'Avoid dairy and fatty foods', 'Seek medical help if severe dehydration'],
      'symptoms': {'nausea': 1.5, 'vomiting': 1.8, 'diarrhea': 2.0, 'abdominal_pain': 1.4, 'loss_of_appetite': 0.8, 'fever': 0.6},
    },
    {
      'id': 6, 'name': 'Dengue Fever', 'prior': 0.8, 'triage': 'high',
      'description': 'A mosquito-borne viral infection common in Bangladesh',
      'recommendations': ['Seek medical attention immediately', 'Get a blood test to confirm dengue', 'Rest and stay well hydrated', 'Monitor for warning signs (bleeding, severe pain)'],
      'symptoms': {'fever': 2.0, 'rash': 1.6, 'joint_pain': 1.8, 'chills': 0.8, 'headache': 1.0, 'sweating': 0.6, 'body_ache': 1.0, 'muscle_pain': 1.0, 'eye_redness': 0.8, 'back_pain': 0.6},
    },
    {
      'id': 7, 'name': 'Chikungunya', 'prior': 0.6, 'triage': 'medium',
      'description': 'A mosquito-borne viral disease causing fever and joint pain',
      'recommendations': ['Consult a doctor for proper diagnosis', 'Rest and drink plenty of fluids', 'Take pain relievers as recommended', 'Joint pain may persist for weeks or months'],
      'symptoms': {'fever': 1.8, 'joint_pain': 2.0, 'rash': 1.4, 'fatigue': 0.8, 'muscle_pain': 1.0},
    },
    {
      'id': 8, 'name': 'Typhoid Fever', 'prior': 0.5, 'triage': 'high',
      'description': 'A bacterial infection spread through contaminated food/water',
      'recommendations': ['Seek medical attention for blood tests', 'Antibiotics are necessary for treatment', 'Drink only boiled or bottled water', 'Maintain good hygiene and handwashing'],
      'symptoms': {'fever': 1.8, 'headache': 1.0, 'loss_of_appetite': 1.0, 'abdominal_pain': 1.0, 'diarrhea': 0.8, 'fatigue': 0.6},
    },
    {
      'id': 9, 'name': 'Asthma Exacerbation', 'prior': 0.6, 'triage': 'high',
      'description': 'Worsening of asthma symptoms including airway inflammation',
      'recommendations': ['Use your rescue inhaler immediately', 'Sit upright and try to stay calm', 'Seek emergency care if symptoms don\'t improve', 'Follow your asthma action plan'],
      'symptoms': {'wheezing': 2.0, 'shortness_of_breath': 1.8, 'chest_pain': 1.2, 'cough': 0.8},
    },
    {
      'id': 10, 'name': 'Appendicitis', 'prior': 0.4, 'triage': 'emergency',
      'description': 'Inflammation of the appendix — EMERGENCY',
      'recommendations': ['🚨 SEEK EMERGENCY MEDICAL CARE IMMEDIATELY', 'Do not eat or drink anything', 'Do not take laxatives or pain medication', 'Surgery is often required'],
      'symptoms': {'abdominal_pain': 2.0, 'nausea': 1.2, 'vomiting': 1.0, 'fever': 0.8},
    },
    {
      'id': 11, 'name': 'Allergic Reaction', 'prior': 0.5, 'triage': 'medium',
      'description': 'Immune system response to allergens',
      'recommendations': ['Identify and avoid the allergen', 'Take antihistamines as directed', 'Seek care if breathing difficulty occurs', 'Consult doctor for severe reactions'],
      'symptoms': {'rash': 1.6, 'skin_itching': 1.8, 'sneezing': 1.2, 'runny_nose': 1.0, 'eye_redness': 1.4, 'nasal_congestion': 1.0, 'wheezing': 0.8, 'cough': 0.6},
    },
    {
      'id': 12, 'name': 'Malaria', 'prior': 0.7, 'triage': 'high',
      'description': 'A mosquito-borne parasitic disease',
      'recommendations': ['Seek medical attention immediately', 'Get a blood test for confirmation', 'Complete the full antimalarial course', 'Use mosquito nets and repellent'],
      'symptoms': {'fever': 1.8, 'chills': 1.6, 'sweating': 1.4, 'headache': 1.0, 'muscle_pain': 1.0, 'joint_pain': 0.8, 'vomiting': 0.6, 'fatigue': 0.8, 'high_fever': 1.6},
    },
  ];

  /// Predict diseases from a list of symptom IDs.
  /// Uses weighted scoring algorithm (same as website) for consistent confidence values.
  static List<Map<String, dynamic>> predict(List<String> selectedSymptoms) {
    if (selectedSymptoms.isEmpty) return [];

    List<Map<String, dynamic>> results = [];

    for (var disease in diseases) {
      double score = (disease['prior'] as num).toDouble();
      int matchedCount = 0;
      final symptomWeights = disease['symptoms'] as Map<String, dynamic>;

      for (var symptom in selectedSymptoms) {
        if (symptomWeights.containsKey(symptom)) {
          score += (symptomWeights[symptom] as num).toDouble();
          matchedCount++;
        }
      }

      if (matchedCount == 0) continue;

      // Same formula as the website: score / (symptoms.length + 1) * 100
      double confidence = score / (selectedSymptoms.length + 1) * 100;
      int confidencePercent = min(99, confidence.round());

      // Filter out very low matches
      if (confidencePercent < 15) continue;

      results.add({
        'name': disease['name'],
        'confidence': confidencePercent,
        'triage': disease['triage'],
        'description': disease['description'],
        'recommendations': disease['recommendations'],
      });
    }

    // Sort by confidence descending
    results.sort((a, b) => (b['confidence'] as int).compareTo(a['confidence'] as int));
    return results;
  }

  /// Check if any selected symptoms are emergency-level.
  static bool hasEmergencySymptoms(List<String> selectedSymptoms) {
    return selectedSymptoms.any((s) => emergencySymptoms.contains(s));
  }

  /// Get all available symptoms grouped by category.
  static Map<String, List<Map<String, String>>> getSymptomsByCategory() {
    return {
      '🔥 Common': [
        {'id': 'fever', 'name': 'Fever / জ্বর'},
        {'id': 'cough', 'name': 'Cough / কাশি'},
        {'id': 'headache', 'name': 'Headache / মাথা ব্যথা'},
        {'id': 'fatigue', 'name': 'Fatigue / ক্লান্তি'},
        {'id': 'body_ache', 'name': 'Body Ache / শরীর ব্যথা'},
        {'id': 'sore_throat', 'name': 'Sore Throat / গলা ব্যথা'},
        {'id': 'muscle_pain', 'name': 'Muscle Pain / মাংসপেশী ব্যথা'},
      ],
      '🫁 Respiratory': [
        {'id': 'shortness_of_breath', 'name': 'Shortness of Breath / শ্বাসকষ্ট'},
        {'id': 'chest_pain', 'name': 'Chest Pain / বুকে ব্যথা'},
        {'id': 'wheezing', 'name': 'Wheezing / শ্বাসে শব্দ'},
        {'id': 'runny_nose', 'name': 'Runny Nose / নাক দিয়ে পানি'},
        {'id': 'sneezing', 'name': 'Sneezing / হাঁচি'},
        {'id': 'nasal_congestion', 'name': 'Nasal Congestion / নাক বন্ধ'},
      ],
      '🍽️ Digestive': [
        {'id': 'nausea', 'name': 'Nausea / বমি ভাব'},
        {'id': 'vomiting', 'name': 'Vomiting / বমি'},
        {'id': 'diarrhea', 'name': 'Diarrhea / ডায়রিয়া'},
        {'id': 'abdominal_pain', 'name': 'Abdominal Pain / পেট ব্যথা'},
        {'id': 'loss_of_appetite', 'name': 'Loss of Appetite / ক্ষুধামন্দা'},
      ],
      '🧠 Neurological': [
        {'id': 'loss_of_taste', 'name': 'Loss of Taste / স্বাদ না পাওয়া'},
        {'id': 'loss_of_smell', 'name': 'Loss of Smell / গন্ধ না পাওয়া'},
        {'id': 'dizziness', 'name': 'Dizziness / মাথা ঘোরা'},
      ],
      '⚡ Other': [
        {'id': 'rash', 'name': 'Rash / ফুসকুড়ি'},
        {'id': 'joint_pain', 'name': 'Joint Pain / গাঁটে ব্যথা'},
        {'id': 'chills', 'name': 'Chills / কাঁপুনি'},
        {'id': 'sweating', 'name': 'Sweating / ঘাম'},
        {'id': 'eye_redness', 'name': 'Red Eyes / চোখ লাল'},
        {'id': 'skin_itching', 'name': 'Skin Itching / চামড়া চুলকানি'},
        {'id': 'back_pain', 'name': 'Back Pain / পিঠে ব্যথা'},
        {'id': 'high_fever', 'name': 'High Fever (>103°F) / তীব্র জ্বর'},
        {'id': 'bleeding', 'name': 'Unusual Bleeding / রক্তপাত'},
      ],
    };
  }
}
