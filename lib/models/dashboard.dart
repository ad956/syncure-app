class DashboardResponse {
  final Patient patient;
  final HealthMetrics healthMetrics;
  final NextAppointment? nextAppointment;
  final List<VitalSign> todaysVitals;
  final List<VitalSign> recentVitals;
  final List<Medication> medications;
  final Progress progress;

  DashboardResponse({
    required this.patient,
    required this.healthMetrics,
    this.nextAppointment,
    required this.todaysVitals,
    required this.recentVitals,
    required this.medications,
    required this.progress,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      patient: Patient.fromJson(json['patient'] ?? {}),
      healthMetrics: HealthMetrics.fromJson(json['healthMetrics'] ?? {}),
      nextAppointment: json['nextAppointment'] != null 
          ? NextAppointment.fromJson(json['nextAppointment']) 
          : null,
      todaysVitals: (json['todaysVitals'] as List?)
          ?.map((v) => VitalSign.fromJson(v))
          .toList() ?? [],
      recentVitals: (json['recentVitals'] as List?)
          ?.map((v) => VitalSign.fromJson(v))
          .toList() ?? [],
      medications: (json['medications'] as List?)
          ?.map((m) => Medication.fromJson(m))
          .toList() ?? [],
      progress: Progress.fromJson(json['progress'] ?? {}),
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

  Patient({
    required this.id,
    required this.name,
    required this.firstname,
    required this.email,
    required this.contact,
    this.profile,
    this.physicalDetails,
    required this.updatedAt,
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
    );
  }
}

class PhysicalDetails {
  final double height;
  final double weight;

  PhysicalDetails({required this.height, required this.weight});

  factory PhysicalDetails.fromJson(Map<String, dynamic> json) {
    return PhysicalDetails(
      height: (json['height'] ?? 175).toDouble(),
      weight: (json['weight'] ?? 70).toDouble(),
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
      doctor: json['doctor'] ?? 'Dr. Smith',
      hospital: json['hospital'] ?? 'General Hospital',
      specialty: json['specialty'] ?? 'General Medicine',
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