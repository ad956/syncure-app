class DashboardResponse {
  final Patient patient;
  final HealthMetrics healthMetrics;
  final NextAppointment? nextAppointment;
  final List<VitalSign> todaysVitals;
  final List<VitalSign> recentVitals;
  final List<Medication> medications;
  final List<PendingBill> pendingBills;
  final Progress progress;

  DashboardResponse({
    required this.patient,
    required this.healthMetrics,
    this.nextAppointment,
    required this.todaysVitals,
    required this.recentVitals,
    required this.medications,
    required this.pendingBills,
    required this.progress,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return DashboardResponse(
      patient: Patient.fromJson(data['patient'] ?? {}),
      healthMetrics: HealthMetrics.fromJson(data['healthMetrics'] ?? {}),
      nextAppointment: data['nextAppointment'] != null 
          ? NextAppointment.fromJson(data['nextAppointment']) 
          : null,
      todaysVitals: (data['todaysVitals'] as List?)
          ?.map((v) => VitalSign.fromJson(v))
          .toList() ?? [],
      recentVitals: (data['recentVitals'] as List?)
          ?.map((v) => VitalSign.fromJson(v))
          .toList() ?? [],
      medications: (data['medications'] as List?)
          ?.map((m) => Medication.fromJson(m))
          .toList() ?? [],
      pendingBills: (data['pendingBills'] as List?)
          ?.map((b) => PendingBill.fromJson(b))
          .toList() ?? [],
      progress: Progress.fromJson(data['progress'] ?? {}),
    );
  }
}

class Patient {
  final String id;
  final String name;
  final String firstname;
  final String email;
  final String contact;
  final String? profile;
  final PhysicalDetails? physicalDetails;
  final String updatedAt;
  final String? countryCode;

  Patient({
    required this.id,
    required this.name,
    required this.firstname,
    required this.email,
    required this.contact,
    this.profile,
    this.physicalDetails,
    required this.updatedAt,
    this.countryCode,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      name: json['name'] ?? 'John Doe',
      firstname: json['firstname'] ?? 'John',
      email: json['email'] ?? 'john@example.com',
      contact: json['contact'] ?? '+1 9876543210',
      profile: json['profile'],
      physicalDetails: json['physicalDetails'] != null 
          ? PhysicalDetails.fromJson(json['physicalDetails']) 
          : null,
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
      countryCode: json['countryCode'],
    );
  }
}

class PhysicalDetails {
  final int age;
  final String blood;
  final double height;
  final double weight;

  PhysicalDetails({
    required this.age,
    required this.blood,
    required this.height,
    required this.weight,
  });

  factory PhysicalDetails.fromJson(Map<String, dynamic> json) {
    return PhysicalDetails(
      age: json['age'] ?? 21,
      blood: json['blood'] ?? 'O+',
      height: (json['height'] ?? 5.6).toDouble(),
      weight: (json['weight'] ?? 60).toDouble(),
    );
  }
}

class HealthMetrics {
  final int healthScore;
  final int activeMedications;
  final String bmiStatus;
  final String bmi;

  HealthMetrics({
    required this.healthScore,
    required this.activeMedications,
    required this.bmiStatus,
    required this.bmi,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      healthScore: json['healthScore'] ?? 85,
      activeMedications: json['activeMedications'] ?? 0,
      bmiStatus: json['bmiStatus'] ?? 'Normal',
      bmi: json['bmi'] ?? '22.9',
    );
  }
}

class NextAppointment {
  final String date;
  final String doctor;
  final String hospital;
  final String specialty;

  NextAppointment({
    required this.date,
    required this.doctor,
    required this.hospital,
    required this.specialty,
  });

  factory NextAppointment.fromJson(Map<String, dynamic> json) {
    return NextAppointment(
      date: json['date'] ?? DateTime.now().add(Duration(days: 7)).toIso8601String(),
      doctor: json['doctor'] is Map 
          ? json['doctor']['name'] ?? 'Dr. Smith'
          : json['doctor'] ?? 'Dr. Smith',
      hospital: json['hospital'] is Map 
          ? json['hospital']['name'] ?? 'General Hospital'
          : json['hospital'] ?? 'General Hospital',
      specialty: json['doctor'] is Map 
          ? json['doctor']['specialty'] ?? 'General Medicine'
          : json['specialty'] ?? 'General Medicine',
    );
  }
}

class VitalSign {
  final String id;
  final double? weight;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRate;
  final double? temperature;
  final int? bloodSugar;
  final String recordedAt;

  VitalSign({
    required this.id,
    this.weight,
    this.systolicBp,
    this.diastolicBp,
    this.heartRate,
    this.temperature,
    this.bloodSugar,
    required this.recordedAt,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      id: json['_id'] ?? json['id'] ?? '',
      weight: json['weight']?.toDouble(),
      systolicBp: json['systolic_bp']?.toInt(),
      diastolicBp: json['diastolic_bp']?.toInt(),
      heartRate: json['heart_rate']?.toInt(),
      temperature: json['temperature']?.toDouble(),
      bloodSugar: json['blood_sugar']?.toInt(),
      recordedAt: json['recorded_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final String nextDose;
  final bool wasTaken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.nextDose,
    required this.wasTaken,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      instructions: json['instructions'] ?? '',
      nextDose: json['nextDose'] ?? '8:00 AM',
      wasTaken: json['wasTaken'] ?? false,
    );
  }
}

class PendingBill {
  final String id;
  final String hospitalName;
  final String? hospitalProfile;
  final double amount;
  final String description;
  final DateTime dueDate;

  PendingBill({
    required this.id,
    required this.hospitalName,
    this.hospitalProfile,
    required this.amount,
    required this.description,
    required this.dueDate,
  });

  factory PendingBill.fromJson(Map<String, dynamic> json) {
    return PendingBill(
      id: json['id'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      hospitalProfile: json['hospitalProfile'],
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Progress {
  final int generalHealth;
  final int waterBalance;
  final int currentTreatment;
  final int pendingAppointments;

  Progress({
    required this.generalHealth,
    required this.waterBalance,
    required this.currentTreatment,
    required this.pendingAppointments,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      generalHealth: json['generalHealth'] ?? 85,
      waterBalance: json['waterBalance'] ?? 78,
      currentTreatment: json['currentTreatment'] ?? 92,
      pendingAppointments: json['pendingAppointments'] ?? 1,
    );
  }
}