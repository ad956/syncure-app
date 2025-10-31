class HealthTrend {
  final String date;
  final double? weight;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRate;
  final double? temperature;
  final int? bloodSugar;

  HealthTrend({
    required this.date,
    this.weight,
    this.systolicBp,
    this.diastolicBp,
    this.heartRate,
    this.temperature,
    this.bloodSugar,
  });

  factory HealthTrend.fromJson(Map<String, dynamic> json) {
    return HealthTrend(
      date: json['date'] ?? '',
      weight: json['weight']?.toDouble(),
      systolicBp: json['systolic_bp']?.toInt(),
      diastolicBp: json['diastolic_bp']?.toInt(),
      heartRate: json['heart_rate']?.toInt(),
      temperature: json['temperature']?.toDouble(),
      bloodSugar: json['blood_sugar']?.toInt(),
    );
  }
}

class LabResult {
  final String id;
  final String testName;
  final String testType;
  final String result;
  final String referenceRange;
  final String status;
  final String testDate;
  final String reportDate;
  final String labName;
  final String? reportUrl;

  LabResult({
    required this.id,
    required this.testName,
    required this.testType,
    required this.result,
    required this.referenceRange,
    required this.status,
    required this.testDate,
    required this.reportDate,
    required this.labName,
    this.reportUrl,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'] ?? '',
      testName: json['test_name'] ?? '',
      testType: json['test_type'] ?? '',
      result: json['result'] ?? '',
      referenceRange: json['reference_range'] ?? '',
      status: json['status'] ?? 'Normal',
      testDate: json['test_date'] ?? '',
      reportDate: json['report_date'] ?? '',
      labName: json['lab_name'] ?? '',
      reportUrl: json['report_url'],
    );
  }
}

class MedicalHistoryRecord {
  final String id;
  final String treatmentName;
  final String hospitalName;
  final String doctorName;
  final String status;
  final String startDate;
  final String? endDate;
  final String condition;
  final String? notes;

  MedicalHistoryRecord({
    required this.id,
    required this.treatmentName,
    required this.hospitalName,
    required this.doctorName,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.condition,
    this.notes,
  });

  factory MedicalHistoryRecord.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryRecord(
      id: json['id'] ?? '',
      treatmentName: json['treatment_name'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      status: json['status'] ?? 'Ongoing',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      condition: json['condition'] ?? '',
      notes: json['notes'],
    );
  }
}

class MedicationRecord {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final String prescribedBy;
  final String startDate;
  final String? endDate;
  final bool isActive;
  final List<String> reminderTimes;

  MedicationRecord({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.prescribedBy,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.reminderTimes,
  });

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      instructions: json['instructions'] ?? '',
      prescribedBy: json['prescribed_by'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      isActive: json['is_active'] ?? true,
      reminderTimes: List<String>.from(json['reminder_times'] ?? []),
    );
  }
}